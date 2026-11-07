# Bash Cheatsheet

> Run `aliases` for the live list (aliases, expansions, functions).
> This file is the curated reference and may lag behind new additions.

## Aliases

| Alias | Expands to | What it does |
| :--- | :--- | :--- |
| `update` | `pkg_update && pkg_upgrade` | Refresh package lists and upgrade |
| `install` | `pkg_install` | Install packages |
| `remove` | `pkg_remove` | Remove packages |
| `search` | `pkg_search` | Search packages |
| `c` | `clear` | Clear the terminal |
| `ll` | `ls -alF` | Long listing, all files |
| `la` | `ls -A` | List all entries |
| `l` | `ls -CF` | Compact listing |
| `..` | `cd ..` | Go up one directory |
| `reload` | `source ~/.bashrc` | Reload the shell config |
| `basher` | `${EDITOR:-nano} ~/.config/bash/` | Edit the bash config |
| `code` | `opencode` | Launch opencode |
| `edit` | `nvim` | Edit with Neovim |
| `cheat` | `cheatsheet` | Open this file |
| `ls` | `ls --color=auto` | Colorized listing (when available) |

## Functions

| Function | What it does |
| :--- | :--- |
| `wall <image>` | Set the Hyprland wallpaper |
| `download <url>` | Download with aria2 (16 connections) |
| `anime-fast` | Play anime via ani-cli |
| `fdelete <path>...` | Safe `rm -rf` with explicit paths |
| `mic` | Reconnect the phone mic over Wi-Fi and set `Scrcpy_Mic` as default |
| `mic-usb` | USB-once reconnect after a phone reboot (`adb tcpip 5555`) |
| `mic-off` | Switch the default input back to the laptop mic |
| `path_add <dir>` | Add a directory to `PATH` if missing |
| `z <dir>` | Jump to a directory (zoxide) |
| `zi` | Interactive zoxide jump |
| `pkg_update` | Refresh package lists |
| `pkg_upgrade` | Upgrade installed packages |
| `pkg_install <pkgs...>` | Install packages |
| `pkg_remove <pkgs...>` | Remove packages |
| `pkg_search <term>` | Search packages |
| `aliases` | Show the live alias/function list |
| `cheatsheet` | Open this reference |

## Phone mic (scrcpy)

```bash
mic        # reconnect + restart scrcpy + set Scrcpy_Mic as default
mic-usb    # USB once after a phone reboot; switches ADB to TCP 5555
mic-off    # switch back to the built-in laptop mic
```

Override the phone address when needed:

```bash
PHONE_ADB=192.168.1.50:5555 mic
PHONE_IP=192.168.1.50 mic-usb
```

## Package manager

The same commands work on apt, dnf, pacman, zypper, apk and xbps:

```bash
update
install <pkg>...
remove <pkg>...
search <term>
```
