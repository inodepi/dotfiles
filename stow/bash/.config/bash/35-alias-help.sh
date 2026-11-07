# ~/.config/bash/35-alias-help.sh — discover aliases and functions
# Run: aliases     (live list)
#      cheatsheet  (curated Markdown reference)

declare -A _alias_desc=(
    [update]="Refresh package lists and upgrade"
    [install]="Install packages"
    [remove]="Remove packages"
    [search]="Search packages"
    [c]="Clear the terminal"
    [ll]="Long listing, all files"
    [la]="List all entries"
    [l]="Compact listing"
    [..]="Go up one directory"
    [reload]="Reload ~/.bashrc"
    [basher]="Edit the bash config"
    [code]="Launch opencode"
    [ls]="Colorized ls"
    [edit]="Edit with nvim"
    [cheat]="Open the curated cheat sheet"
)

declare -A _func_desc=(
    [wall]="Set the Hyprland wallpaper"
    [download]="Download with aria2 (16 connections)"
    [anime-fast]="Play anime via ani-cli"
    [fdelete]="Safe rm -rf with explicit paths"
    [mic]="Phone mic over Wi-Fi (scrcpy)"
    [mic-usb]="USB-once reconnect for the phone mic"
    [mic-off]="Switch back to the laptop mic"
    [path_add]="Add a directory to PATH if missing"
    [pkg_update]="Refresh package lists"
    [pkg_upgrade]="Upgrade installed packages"
    [pkg_install]="Install packages"
    [pkg_remove]="Remove packages"
    [pkg_search]="Search packages"
    [z]="Jump to a directory (zoxide)"
    [zi]="Interactive zoxide jump"
    [aliases]="Show this alias/function list"
    [cheatsheet]="Open the curated cheat sheet"
)

aliases() {
    local line name expansion fn
    echo "Aliases"
    echo "======="
    while IFS= read -r line; do
        name=${line#alias }
        name=${name%%=*}
        expansion=${line#*=}
        expansion=${expansion#\'}
        expansion=${expansion%\'}
        printf '  %-12s %-38s %s\n' "$name" "$expansion" "${_alias_desc[$name]:-}"
    done < <(alias -p | sort)
    echo
    echo "Functions"
    echo "========="
    while IFS= read -r fn; do
        case "$fn" in
            _*|__*|starship_*|quote*|dequote|command_not_found_handle) continue ;;
        esac
        printf '  %-12s %s\n' "$fn" "${_func_desc[$fn]:-}"
    done < <(declare -F | awk '{print $3}' | sort)
    echo
    echo "Live list. Curated reference: cheatsheet"
    echo "Tip: aliases | less"
}

cheatsheet() {
    local file="$HOME/.config/bash/CHEATSHEET.md"
    if [ ! -r "$file" ]; then
        echo "cheatsheet: $file not found" >&2
        return 1
    fi
    if [ -t 1 ] && command -v bat >/dev/null 2>&1; then
        bat --style=plain "$file"
    elif [ -t 1 ] && command -v less >/dev/null 2>&1; then
        less "$file"
    else
        cat "$file"
    fi
}

alias cheat='cheatsheet'
