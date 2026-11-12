<div align="center">

# inodepi's dotfiles

**Automation-grade shell setup — stow it, run it, move on.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Linux](https://img.shields.io/badge/Platform-Linux-blue.svg)](https://www.linux.org)
[![GNU Stow](https://img.shields.io/badge/Manager-GNU%20Stow-orange.svg)](https://www.gnu.org/software/stow/)

</div>

---

> **Irrational. Just like π.**
> Stow it, run it, and get back to the work.

---

## ⚡ One-liner install

Bootstraps everything (clone + deps + stow) on any supported distro:

```bash
curl -fsSL https://inodepi.github.io/install | sh
```

Prefer to review first? The classic way works too:

```bash
git clone https://github.com/inodepi/dotfiles.git ~/git-projects/dotfiles && cd ~/git-projects/dotfiles && chmod +x install.sh && ./install.sh
```

The shell setup behind [inodepi](https://inodepi.github.io/) — the same config that
runs the automation work. Built for speed: stow packages, honest prompts, and a
prompt that gets out of the way.

---

## 📦 Included configurations

Configurations are isolated into individual modular packages under the `stow/` directory to prevent system clutter and allow selective deployment:

| Package | Description |
| :--- | :--- |
| **`bash`** | Custom Bash shell configurations, prompts, and git aliases |
| **`nvim`** | Neovim setup powered by LazyVim |
| **`starship`** | Minimalist cross-shell prompt preset |
| **`fastfetch`** | Catppuccin-themed system info (boxed layout, custom badge, kitty graphics + ASCII fallback) |
| **`hypr`** | Hyprland dynamic tiling window manager setup (incl. hypridle, hyprlock, cursor env) |
| **`waybar`** | Custom Waybar status bar layout with caffeine mode (󰾪/󰅶 idle inhibitor) |
| **`systemd`** | `caffeine.service` user unit — auto-installed with the `waybar` package |
| **`wofi`** | Wofi application launcher configuration |
| **`wlogout`** | Wlogout power menu — lock, logout, suspend, reboot, shutdown, plus a live USD/GBP/SOL→PHP rates box |
| **`themes`** | Tokyo Night SDDM login theme + GRUB boot theme (system paths, not stowed) |
| **`gtk`** | Bibata Modern Ice cursor theme for GTK3/GTK4 apps |
| **`kitty`** | Kitty terminal configuration |
| **`mic`** | Phone microphone over Wi-Fi via scrcpy (`Scrcpy_Mic` virtual input; `mic`, `mic-usb`, `mic-off`) |

The installer also has an **`apps`** group for the desktop application set:
Brave, Nemo (default GUI file manager), Motrix, opencode, kitty, and yazi.
Brave and Motrix are installed from their official repositories/releases; Nemo
and the XDG desktop portals are installed from distro packages; opencode uses
its official installer. Selecting `apps` also sets Nemo as the default
`inode/directory` handler.

### Phone microphone over Wi-Fi (the `mic` package)

Installs `scrcpy` + `adb`, a `Scrcpy_Mic` PipeWire virtual input, and a
`scrcpy-mic.service` user service. Pair the phone once over USB
(`adb tcpip 5555`), then use:

```bash
mic        # reconnect and set Scrcpy_Mic as the default input
mic-usb    # one-time USB reconnect after a phone reboot
mic-off    # switch back to the laptop mic
```

### Remembering aliases

```bash
aliases     # live list: aliases + expansions + descriptions, and functions
cheatsheet  # curated reference in ~/.config/bash/CHEATSHEET.md
```

---

## 🚀 Installation guide

### Quick One-Liner Install

Bootstraps everything (clone + deps + stow) on any supported distro:

```bash
curl -fsSL https://inodepi.github.io/install | sh
```

Prefer to review first? The classic way works too:

```bash
git clone https://github.com/inodepi/dotfiles.git ~/git-projects/dotfiles && cd ~/git-projects/dotfiles && chmod +x install.sh && ./install.sh
```

### Supported distributions

The installer auto-detects and uses **apt** (Debian/Ubuntu), **dnf** (Fedora),
**pacman** (Arch), **zypper** (openSUSE), **apk** (Alpine), or **xbps** (Void).
On unsupported distros it warns, skips package installation, and still stows
the selected configs. Existing files that would collide (e.g. the distro's
default `~/.bashrc`) are backed up to `<file>.pre-stow.<timestamp>` first.

### Hyprland desktop (the `hypr` + `gtk` packages)

Modular config — `hyprland.conf` sources `conf/{monitors,theme,keybinds,autostart,input}.conf`.

**Idle management (`hypridle`)** — autostarts with Hyprland, each stage resets on any input:

| Idle | Action |
| :--- | :--- |
| 2 min | Brightness → 0% (black screen, no DPMS delay) |
| 10 min | Session locks (same Tokyo Night hyprlock as `Super+L`) |
| 15 min | Display off (DPMS) |
| 25 min | Suspend — **on battery only** |
| 60 min | Suspend regardless of power source |

Power source is checked at timeout time (`/sys/class/power_supply/A*/online`), so
unplugging mid-session switches you to the aggressive schedule without a reload.
Every wake path restores brightness and lands directly on the hyprlock password
prompt. Media/video inhibitors (dbus) are respected. Caffeine mode (see the
`waybar` package below) pauses this entire schedule while active.

**Lock screen (`hyprlock`)** — Tokyo Night palette with live clock (1s),
weekday + date label, and a battery/charging label (10s refresh).

**Cursor theme** — Bibata Modern Ice everywhere: `XCURSOR_THEME`/`XCURSOR_SIZE`
env vars for Hyprland, `gtk-cursor-theme-*` for GTK apps (see the `gtk` package).
`install.sh` tries the distro's Bibata package first, then falls back to the
official GitHub release tarball (user-level, `~/.local/share/icons/`).


### Waybar status bar (the `waybar` package)

Tokyo Night pill layout — workspaces/CPU/RAM/speed on the left, clock in
the center, SSID/bluetooth/notifications/caffeine/volume/battery/tray on the right.
Notifications use **mako**; left-clicking the bell opens the history through
`mako-wofi` (installed with the `bash` and `waybar` packages).

**Caffeine mode (󰾪/󰅶)** — keeps the screen awake by holding a logind `idle`
inhibitor lock (the `caffeine.service` user unit), which `hypridle` respects via
`ignore_dbus_inhibit = false`. Suspend is not inhibited, so closing the lid or
hitting a suspend timer still suspends. Toggle it with `Super+C`
or by clicking the bar icon:

| State | Icon | Meaning |
| :--- | :--- | :--- |
| Off | 󰾪 (dimmed) | Normal idle schedule runs |
| On | 󰅶 (white icon on black pill) | All idle timers paused |

- Icon state syncs instantly (SIGRTMIN+8) no matter how caffeine is toggled —
  keybind, bar click, `make toggle`, or CLI.
- Off by default at login (its `exec-once` line in `conf/autostart.conf` is
  commented out); each toggle sends a desktop notification.
- `install.sh` installs and daemon-reloads `caffeine.service` automatically
  whenever the `waybar` package is selected.
- Handy commands: `make -C ~/.config/waybar toggle` (also `on` / `off` /
  `status` / `install`).

### Wlogout power menu and currency rates (the `wlogout` package)

`Super+M` opens the power menu through `wlogout-rates`. It keeps the five power
actions and adds a single rates box that shows every configured currency on its
own line. The layout and white icons are adapted from
[HyprKenso](https://github.com/aadritobasu/HyprKenso), recolored to Tokyo Night. The six buttons are arranged as a 3x2 square grid on 1920x1080:

- Fiat rates come from `open.er-api.com` (USD base, cross-computed to PHP).
- Crypto rates come from CoinGecko.
- Results are cached for 5 minutes in `~/.cache/wlogout-rates/rates.json`;
  if a refresh fails, the last known rates are shown.
- The rates box uses the same icon/button treatment as the power actions and
  pulses every 10 seconds. Its icon is a custom peso coin, since every rate
  converts to PHP. Rates refresh when the menu opens; wlogout
  labels are static while it stays open.

Add currencies in `~/.config/wlogout/currencies.json`:

```json
{
    "buttons_per_row": 3,
    "fiat": ["USD", "GBP"],
    "crypto": {"SOL": "solana"}
}
```

Append another ISO code under `fiat`, or add `"SYMBOL": "coingecko-id"` under
`crypto`. The wrapper combines them into the same box and generates the CSS
automatically. Run `wlogout-rates --print --refresh` to preview the generated
layout, or `wlogout-rates --refresh` to bypass the cache.

### GRUB boot theme (Tokyo Night)

`grub-theme/inodepi/` is a GRUB 2 gfxmenu theme using the same Tokyo
Night palette as the rest of the desktop: `#1a1b26` base, `#7aa2f7` selection,
JetBrainsMono NF fonts generated with `grub-mkfont`, and the Hyprland wallpaper
darkened 55% as the menu background (1920x1080, matching `GRUB_GFXMODE`).

```sh
sudo ./grub-theme/install.sh
sudo ./grub-theme/install.sh --revert   # rollback
```

Selecting the `themes` package in `./install.sh` copies the theme and runs
`update-grub` automatically (including in `-y` / `-a` runs). Pass `--no-grub`
to the installer to copy the theme files without touching the bootloader
configuration.

The installer also guarantees a visible menu: it sets `GRUB_TIMEOUT` (5s by
default, override with `MENU_TIMEOUT=10 sudo ./grub-theme/install.sh`) and
`GRUB_TIMEOUT_STYLE=menu`, and drops any `GRUB_HIDDEN_TIMEOUT*` keys. GRUB's
directory is detected, so `/boot/grub2` (Fedora, openSUSE) works as well as
`/boot/grub` (Debian, Ubuntu, Arch).

The installer is deliberately narrow:

- backs up `/etc/default/grub` and the generated `grub.cfg` first
- edits `GRUB_THEME`, `GRUB_BACKGROUND`, `GRUB_TIMEOUT`, and `GRUB_TIMEOUT_STYLE`
- never runs `grub-install` (no EFI/bootloader writes)
- restores `grub.cfg` automatically if regeneration fails
- validates the result with `grub-script-check` when available

A theme that fails to load makes GRUB fall back to its text menu; it does not
prevent booting. The previous `Elegant-forest-window-left-dark` theme stays
installed under `/usr/share/grub/themes`, so reverting is just the backup
restore above.

### SDDM login theme (Tokyo Night)

`sddm-theme/inodepi/` is a copy of the
[Qylock](https://github.com/Darkkal44/qylock) `pixel-coffee` greeter layout,
restyled to Tokyo Night: `#1a1b26` base, `#7aa2f7` accent, JetBrainsMono Nerd
Font instead of PixelifySans, rounded password field and buttons. The background
is the current Hyprland wallpaper (static image, so no video decode at login).

Install it system-wide (SDDM reads themes from `/usr/share` as the `sddm` user):

```sh
sudo ./sddm-theme/install.sh
```

Or select the `themes` package in `./install.sh`, which runs this installer for
you when `sddm` is present.

The script copies the theme, fixes permissions, and points
`/etc/sddm.conf.d/theme.conf` at it. It does not restart SDDM, so the theme
appears on the next logout. Preview without logging out:

```sh
cd sddm-theme/inodepi
sddm-greeter-qt6 --test-mode --theme .
```

To change the background, replace `sddm-theme/inodepi/background.jpg`
and re-run the installer. Pass a theme name as the first argument to install a
different theme directory. See `sddm-theme/NOTICE.md` for attribution; the
upstream QML is GPL-3.0.

### Fastfetch theming

The default `config.jsonc` is the [Catppuccin fastfetch](https://github.com/Nukecraft5419/fastfetch)
boxed layout (Hardware/Software sections) with a custom badge
(`catppuccin_logo.png`, rendered via the kitty graphics protocol) and a
one-file ASCII fallback (`potato.ans`, see `config-ascii.jsonc`). Piping
`fastfetch` (e.g. into `less`) automatically drops to the built-in fallback.

All colors are written as raw SGR parameters (`38;2;R;G;B`) instead of `#hex`:
mainline fastfetch accepts both, but some builds only parse SGR — so the theme
renders identically on every distro and build.

Other presets: `config-ascii.jsonc`, `config-compact.jsonc`,
`config-pokemon.jsonc`, `config-v2.jsonc`.

Non-interactive options (great for fresh bare-metal installs):

```bash
./install.sh -y                     # default set: bash, nvim, starship, fastfetch
./install.sh -a                     # everything (including apps)
PACKAGES="bash waybar apps" ./install.sh -y
./install.sh -p "bash hypr wofi"    # explicit list
./install.sh -h                     # all options
```

### Distro-agnostic package commands

The bash config detects your package manager at shell startup
(`~/.config/bash/15-package-manager.sh`) and exposes the same commands
everywhere — no more apt-only aliases:

| Command | Action |
| :--- | :--- |
| `update` | Refresh package lists + upgrade |
| `install <pkg>` | Install packages |
| `remove <pkg>` | Remove packages (with autoremove where applicable) |
| `search <term>` | Search repos |
| `pkg_update` / `pkg_install` / ... | Underlying functions, usable in scripts |

---

## 🗑️ Uninstalling

Every deployed file is a symlink into this repo, so removal is clean. From the
repo root, unstow any package (repeat per package, or use `-D` with the same
paths the installer used):

```bash
stow -d stow -t "$HOME" -D <package>   # e.g. bash, nvim, waybar
```

Files that the installer backed up on first install are still there — restore
any of them by dropping the `.pre-stow.<timestamp>` suffix. Packages pulled in
by the installer can be removed with your distro's package manager.
