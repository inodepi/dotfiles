#!/usr/bin/env bash
# Install the custom Qylock-based SDDM theme system-wide.
# Usage: sudo ./sddm-theme/install.sh
set -euo pipefail

NAME=pixel-coffee-wallpaper
HERE="$(cd "$(dirname "$0")" && pwd)"
SRC="$HERE/$NAME"

[[ -d $SRC ]] || { echo "missing theme dir: $SRC" >&2; exit 1; }

# DEST/CONF are overridable for testing without root.
if [[ -z ${DEST:-} ]]; then
    [[ ${EUID} -eq 0 ]] || { echo "run with sudo: sudo $0" >&2; exit 1; }
    DEST=/usr/share/sddm/themes/$NAME
    CONF=/etc/sddm.conf.d/theme.conf
fi

install -d -m 755 "$DEST"
cp -a "$SRC/." "$DEST/"
chmod -R a+rX "$DEST"
chown -R root:root "$DEST" 2>/dev/null || true

mkdir -p "$(dirname "$CONF")"
cat > "$CONF" <<CONFEOF
[General]
InputMethod=

[Theme]
Current=$NAME
CONFEOF

echo "installed $NAME -> $DEST"
echo "theme set in $CONF; log out to see it (SDDM reads it on the next greeter start)"
