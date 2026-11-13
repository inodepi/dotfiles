#!/usr/bin/env bash
# Start session services reliably after Hyprland is up.
#
# waybar.service ships with Requisite=graphical-session.target, but Hyprland
# never activates that target (and systemd refuses manual starts of it). The
# local drop-in 10-standalone.conf removes that requirement, so waybar can be
# started directly here and supervised by systemd (Restart=on-failure).
# The compositor environment is imported first so waybar can reach WAYLAND.

set -u

ENV_VARS=(WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP)

systemctl --user import-environment "${ENV_VARS[@]}" 2>/dev/null || true
if command -v dbus-update-activation-environment >/dev/null 2>&1; then
    dbus-update-activation-environment --systemd "${ENV_VARS[@]}" 2>/dev/null || true
fi

# restart (not start): the unit must pick up the freshly imported HYPRLAND_INSTANCE_SIGNATURE
systemctl --user restart waybar.service 2>/dev/null || true

# If waybar.service cannot run for some reason, fall back to a direct launch so
# the session still gets a bar.
if ! systemctl --user is-active --quiet waybar.service; then
    pgrep -x waybar >/dev/null 2>&1 || waybar >/dev/null 2>&1 &
fi
