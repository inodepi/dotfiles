#!/usr/bin/env bash
# Install the Tokyo Night GRUB theme and make the boot menu visible.
#
#   sudo ./grub-theme/install.sh            install / refresh
#   sudo ./grub-theme/install.sh --revert   restore the previous configuration
#
# Safety contract:
#   * edits GRUB_THEME / GRUB_BACKGROUND plus menu visibility
#     (GRUB_TIMEOUT, GRUB_TIMEOUT_STYLE=menu; drops GRUB_HIDDEN_TIMEOUT*)
#   * /etc/default/grub and grub.cfg are backed up first
#   * grub-install is NEVER run (no bootloader/EFI writes)
#   * if regeneration fails, grub.cfg is restored automatically
set -euo pipefail

NAME=inodepi
HERE="$(cd "$(dirname "$0")" && pwd)"
SRC="$HERE/$NAME"
STAMP=$(date +%Y%m%d-%H%M%S)

die()  { echo "error: $*" >&2; exit 1; }
warn() { echo "warning: $*" >&2; }

# GRUB keeps its files in /boot/grub on Debian/Ubuntu/Arch and /boot/grub2 on
# Fedora/openSUSE, so detect instead of hardcoding.
detect_grub_dir() {
    local d
    for d in /boot/grub /boot/grub2; do
        if [[ -d $d ]]; then
            printf '%s\n' "$d"
            return 0
        fi
    done
    printf '%s\n' /boot/grub
}

GRUB_DIR=${GRUB_DIR:-$(detect_grub_dir)}
DEST=${DEST:-$GRUB_DIR/themes/$NAME}
DEFAULTS=${DEFAULTS:-/etc/default/grub}
CFG=${CFG:-$GRUB_DIR/grub.cfg}
MENU_TIMEOUT=${MENU_TIMEOUT:-5}

[[ -d $SRC ]] || die "missing theme dir: $SRC"

UPDATE_GRUB=$(command -v update-grub || { [[ -x /usr/sbin/update-grub ]] && echo /usr/sbin/update-grub; } || true)

regen_grub() {
    if [[ -n ${UPDATE_GRUB:-} ]]; then
        "$UPDATE_GRUB"
    elif command -v grub-mkconfig >/dev/null 2>&1; then
        grub-mkconfig -o "$CFG"
    elif command -v grub2-mkconfig >/dev/null 2>&1; then
        grub2-mkconfig -o "$CFG"
    else
        return 1
    fi
}

if [[ ${1:-} == --revert ]]; then
    [[ ${EUID} -eq 0 ]] || die "run with sudo: sudo $0 --revert"
    [[ -f $DEFAULTS.bak ]] || die "no backup at $DEFAULTS.bak"
    cp -a "$DEFAULTS.bak" "$DEFAULTS"
    regen_grub || die "grub regeneration failed after revert"
    echo "reverted $DEFAULTS from backup and regenerated grub.cfg"
    exit 0
fi

if [[ -z ${SKIP_ROOT_CHECK:-} && ${EUID} -ne 0 ]]; then
    die "run with sudo: sudo $0"
fi

if [[ -z ${SKIP_UPDATE:-} ]] && [[ -z ${UPDATE_GRUB:-} ]] \
    && ! command -v grub-mkconfig >/dev/null 2>&1 \
    && ! command -v grub2-mkconfig >/dev/null 2>&1; then
    die "neither update-grub nor grub-mkconfig/grub2-mkconfig found"
fi

# Copy a config aside, but only when it differs from the newest backup so
# repeated installer runs do not pile up identical .bak.* files.
backup_if_changed() {
    local file=$1 latest
    latest=$(ls -1t "$file".bak.* 2>/dev/null | head -1 || true)
    if [[ -n $latest ]] && cmp -s "$file" "$latest"; then
        return 0
    fi
    cp -a "$file" "$file.bak.$STAMP"
    ln -sfn "$(basename "$file").bak.$STAMP" "$file.bak"
}

# --- backups ---------------------------------------------------------------
backup_if_changed "$DEFAULTS"
if [[ -f $CFG ]]; then
    backup_if_changed "$CFG"
fi

# --- theme files -----------------------------------------------------------
install -d -m 755 "$DEST"
cp -a "$SRC/." "$DEST/"
chmod -R a+rX "$DEST"
[[ ${EUID} -eq 0 ]] && chown -R root:root "$DEST"

# --- edit /etc/default/grub ------------------------------------------------
# Theme lines plus a menu that is actually visible: an explicit timeout, no
# "hidden" timeout style, and no hidden-timeout keys left behind.
python3 - "$DEFAULTS" "$DEST/theme.txt" "$DEST/background.png" "$MENU_TIMEOUT" <<'PY'
import sys

path, theme, bg, timeout = sys.argv[1:5]
lines = open(path).read().splitlines()
wanted = {
    "GRUB_THEME": f'GRUB_THEME="{theme}"',
    "GRUB_BACKGROUND": f'GRUB_BACKGROUND="{bg}"',
    "GRUB_TIMEOUT": f"GRUB_TIMEOUT={timeout}",
    "GRUB_TIMEOUT_STYLE": "GRUB_TIMEOUT_STYLE=menu",
}
drop = {"GRUB_HIDDEN_TIMEOUT", "GRUB_HIDDEN_TIMEOUT_QUIET"}
seen = set()
out = []
for line in lines:
    key = line.split("=", 1)[0].strip()
    if key in drop:
        continue
    if key in wanted:
        if key in seen:
            continue
        out.append(wanted[key])
        seen.add(key)
    else:
        out.append(line)
for key, value in wanted.items():
    if key not in seen:
        out.append(value)
open(path, "w").write("\n".join(out) + "\n")
PY

# --- regenerate + validate -------------------------------------------------
if [[ -n ${SKIP_UPDATE:-} ]]; then
    echo "SKIP_UPDATE set; not running update-grub (theme files installed to $DEST)"
    exit 0
fi

if ! regen_grub; then
    [[ -f $CFG.bak ]] && cp -a "$CFG.bak" "$CFG"
    die "grub regeneration failed; grub.cfg restored from backup"
fi

GRUB_SCRIPT_CHECK=$(command -v grub-script-check || command -v grub2-script-check || true)
if [[ -n $GRUB_SCRIPT_CHECK ]]; then
    "$GRUB_SCRIPT_CHECK" "$CFG" \
        || die "generated grub.cfg has syntax errors - restore $DEFAULTS.bak.$STAMP"
else
    warn "grub-script-check not found; skipping grub.cfg syntax validation"
fi

grep -q "theme=.*$DEST/theme.txt" "$CFG" \
    || die "theme line missing from grub.cfg - restore $DEFAULTS.bak.$STAMP"
grep -q '^GRUB_TIMEOUT_STYLE=menu' "$DEFAULTS" \
    || die "GRUB_TIMEOUT_STYLE=menu missing from $DEFAULTS - restore $DEFAULTS.bak.$STAMP"

echo
echo "installed: $DEST"
echo "menu:      visible, ${MENU_TIMEOUT}s timeout (GRUB_TIMEOUT_STYLE=menu)"
echo "backup:    $DEFAULTS.bak.$STAMP"
echo "rollback:  sudo $0 --revert"
echo "reboot to see it; a broken theme falls back to the text menu, it does not block booting."
