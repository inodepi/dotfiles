#!/usr/bin/env bash
# Install the Tokyo Night GRUB theme safely.
#
#   sudo ./grub-theme/install.sh            install / refresh
#   sudo ./grub-theme/install.sh --revert   restore the previous configuration
#
# Safety contract:
#   * only GRUB_THEME / GRUB_BACKGROUND in /etc/default/grub are edited
#   * /etc/default/grub and /boot/grub/grub.cfg are backed up first
#   * grub-install is NEVER run (no bootloader/EFI writes)
#   * if update-grub fails, grub.cfg is restored automatically
set -euo pipefail

NAME=qylock-tokyonight
HERE="$(cd "$(dirname "$0")" && pwd)"
SRC="$HERE/$NAME"
DEST=${DEST:-/boot/grub/themes/$NAME}
DEFAULTS=${DEFAULTS:-/etc/default/grub}
CFG=${CFG:-/boot/grub/grub.cfg}
STAMP=$(date +%Y%m%d-%H%M%S)

die() { echo "error: $*" >&2; exit 1; }
[[ -d $SRC ]] || die "missing theme dir: $SRC"

if [[ ${1:-} == --revert ]]; then
    [[ ${EUID} -eq 0 ]] || die "run with sudo: sudo $0 --revert"
    [[ -f $DEFAULTS.bak ]] || die "no backup at $DEFAULTS.bak"
    cp -a "$DEFAULTS.bak" "$DEFAULTS"
    "${UPDATE_GRUB:-/usr/sbin/update-grub}" || die "update-grub failed after revert"
    echo "reverted $DEFAULTS from backup and regenerated grub.cfg"
    exit 0
fi

if [[ -z ${SKIP_ROOT_CHECK:-} && ${EUID} -ne 0 ]]; then
    die "run with sudo: sudo $0"
fi
UPDATE_GRUB=$(command -v update-grub || { [[ -x /usr/sbin/update-grub ]] && echo /usr/sbin/update-grub; } || true)
if [[ -z ${SKIP_UPDATE:-} && -z ${UPDATE_GRUB:-} ]]; then
    die "update-grub not found"
fi

# --- backups ---------------------------------------------------------------
cp -a "$DEFAULTS" "$DEFAULTS.bak.$STAMP"
ln -sfn "$(basename "$DEFAULTS").bak.$STAMP" "$DEFAULTS.bak" 2>/dev/null || true
if [[ -f $CFG ]]; then
    cp -a "$CFG" "$CFG.bak.$STAMP"
    ln -sfn "$(basename "$CFG").bak.$STAMP" "$CFG.bak" 2>/dev/null || true
fi

# --- theme files -----------------------------------------------------------
install -d -m 755 "$DEST"
cp -a "$SRC/." "$DEST/"
chmod -R a+rX "$DEST"
[[ ${EUID} -eq 0 ]] && chown -R root:root "$DEST"

# --- edit /etc/default/grub (theme lines only) -----------------------------
python3 - "$DEFAULTS" "$DEST/theme.txt" "$DEST/background.png" <<'PY'
import re, sys
path, theme, bg = sys.argv[1], sys.argv[2], sys.argv[3]
lines = open(path).read().splitlines()
wanted = {
    "GRUB_THEME": f'GRUB_THEME="{theme}"',
    "GRUB_BACKGROUND": f'GRUB_BACKGROUND="{bg}"',
}
seen = set()
out = []
for line in lines:
    key = line.split("=", 1)[0].strip()
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

if ! "$UPDATE_GRUB"; then
    [[ -f $CFG.bak ]] && cp -a "$CFG.bak" "$CFG"
    die "update-grub failed; grub.cfg restored from backup"
fi
grub-script-check "$CFG" || die "generated grub.cfg has syntax errors - restore $DEFAULTS.bak.$STAMP"
grep -q "set theme=$DEST/theme.txt" "$CFG" \
    || die "theme line missing from grub.cfg - restore $DEFAULTS.bak.$STAMP"

echo
echo "installed: $DEST"
echo "backup:    $DEFAULTS.bak.$STAMP"
echo "rollback:  sudo $0 --revert"
echo "reboot to see it; a broken theme falls back to the text menu, it does not block booting."
