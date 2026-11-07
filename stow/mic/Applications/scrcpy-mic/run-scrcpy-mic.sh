#!/usr/bin/env bash
# Stream the phone mic over Wi-Fi ADB into the Scrcpy_Sink virtual sink.
set -u

SERIAL=$(adb devices | awk 'NR>1 && $2=="device" && $1 ~ /:/ {print $1; exit}')
if [ -z "${SERIAL:-}" ]; then
    adb connect "${PHONE_ADB:-192.168.254.111:5555}" >/dev/null 2>&1 || true
    SERIAL=$(adb devices | awk 'NR>1 && $2=="device" && $1 ~ /:/ {print $1; exit}')
fi
if [ -z "${SERIAL:-}" ]; then
    echo "No Wi-Fi ADB device found" >&2
    exit 1
fi

exec env PULSE_SINK=Scrcpy_Sink scrcpy --no-video --no-window --audio-source=mic -s "$SERIAL" "$@"
