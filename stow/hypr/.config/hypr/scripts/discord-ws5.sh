#!/usr/bin/env bash
# Open Discord on workspace 5, moving an existing window there if needed.

set -euo pipefail

if ! command -v hyprctl >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
    exec discord
fi

mapfile -t addresses < <(
    hyprctl clients -j |
        jq -r '.[] | select(.class == "discord") | .address'
)

if ((${#addresses[@]})); then
    for address in "${addresses[@]}"; do
        hyprctl dispatch movetoworkspace "5,address:${address}" >/dev/null 2>&1 || true
    done
    hyprctl dispatch workspace 5 >/dev/null 2>&1 || true
    hyprctl dispatch focuswindow "address:${addresses[0]}" >/dev/null 2>&1 || true
else
    hyprctl dispatch workspace 5 >/dev/null 2>&1 || true
    exec discord
fi
