# Phone microphone over Wi-Fi via scrcpy.
# The service and PipeWire virtual mic are installed by the `mic` stow package.
# Override the phone address with PHONE_ADB=ip:port or PHONE_IP=ip.

_scrcpy_mic_ensure_source() {
    if ! pactl list short sources 2>/dev/null | grep -q 'Scrcpy_Mic'; then
        pactl load-module module-null-sink sink_name=Scrcpy_Sink \
            sink_properties=device.description=Scrcpy_Sink >/dev/null 2>&1 || true
        pactl load-module module-remap-source master=Scrcpy_Sink.monitor \
            source_name=Scrcpy_Mic \
            source_properties=device.description=Scrcpy_Mic >/dev/null 2>&1 || true
    fi
}

mic() {
    local serial="${PHONE_ADB:-192.168.254.111:5555}"
    command -v adb >/dev/null 2>&1 || { echo "adb not found"; return 1; }

    _scrcpy_mic_ensure_source

    if ! adb devices 2>/dev/null \
        | awk 'NR>1 && $2=="device" && $1 ~ /:/ {found=1} END{exit !found}'; then
        adb connect "$serial" >/dev/null 2>&1 || true
    fi

    systemctl --user restart scrcpy-mic.service 2>/dev/null || true
    pactl set-default-source Scrcpy_Mic 2>/dev/null || true

    local active
    active=$(adb devices 2>/dev/null \
        | awk 'NR>1 && $2=="device" && $1 ~ /:/ {print $1; exit}')
    if [ -n "${active:-}" ]; then
        echo "Phone mic: $active"
    else
        echo "No Wi-Fi ADB device. Plug in USB and run: mic-usb"
    fi
    echo "Default input: $(pactl get-default-source 2>/dev/null)"
}

mic-usb() {
    local ip="${PHONE_IP:-192.168.254.111}"
    local serial
    command -v adb >/dev/null 2>&1 || { echo "adb not found"; return 1; }

    serial=$(adb devices 2>/dev/null \
        | awk 'NR>1 && $2=="device" && $1 !~ /:/ {print $1; exit}')
    if [ -z "${serial:-}" ]; then
        echo "No USB device. Plug in the phone, enable USB debugging, accept the prompt."
        return 1
    fi

    echo "Switching $serial to TCP 5555..."
    adb -s "$serial" tcpip 5555 || return 1
    sleep 2
    adb connect "$ip:5555" || true

    systemctl --user restart scrcpy-mic.service 2>/dev/null || true
    pactl set-default-source Scrcpy_Mic 2>/dev/null || true
    echo "Default input: $(pactl get-default-source 2>/dev/null)"
    echo "You can unplug the USB cable."
}

mic-off() {
    pactl set-default-source alsa_input.pci-0000_00_1f.3.analog-stereo 2>/dev/null || true
    echo "Default input: $(pactl get-default-source 2>/dev/null)"
}
