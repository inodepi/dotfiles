# Attribution

`pixel-coffee-wallpaper` is a modified copy of the `pixel-coffee` SDDM theme
from [Darkkal44/qylock](https://github.com/Darkkal44/qylock), which is licensed
under GPL-3.0.

Changes from upstream:

- `BackgroundVideo.qml` now renders a static `Image` instead of a `MediaPlayer`
  video, so no QtMultimedia codec is needed at the greeter.
- `theme.conf` points at `background.jpg` (the local Hyprland wallpaper) with
  `type=image`.
- `metadata.desktop` renamed to `pixel-coffee-wallpaper`.

Everything else (`Main.qml`, font, layout, colors) is unchanged, so the theme
looks the same apart from the background.

Because the upstream QML is GPL-3.0, this directory is distributed under the
same license.
