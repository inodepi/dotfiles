# Attribution

`inodepi` is a modified copy of the `pixel-coffee` SDDM theme from
[Darkkal44/qylock](https://github.com/Darkkal44/qylock), licensed GPL-3.0.

Changes from upstream:

- Tokyo Night palette (`#1a1b26` base, `#7aa2f7` accent) replacing the warm
  pixel-coffee colors.
- JetBrainsMono Nerd Font Bold bundled instead of PixelifySans.
- Rounded password field, LOGIN button, and session pills.
- `BackgroundVideo.qml` renders a static `Image` (the local Hyprland wallpaper)
  instead of a video, so QtMultimedia is not needed at the greeter.

Layout, positions, clock/date/user structure are unchanged.

The upstream QML is GPL-3.0, so this directory is distributed under the same
license.
