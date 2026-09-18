# Window Opacity

Omarchy bar plugin — live transparency and glass-blur control for Hyprland
windows.

![Opacity](https://img.shields.io/badge/plugin-opacity-8a4af3)
![Schema](https://img.shields.io/badge/schemaVersion-1-blue)

## Features

- **Active / Inactive opacity sliders** — set window transparency live from
  30% to 100% using `hyprctl eval` (`decoration:active_opacity`,
  `decoration:inactive_opacity`).
- **Glass blur toggle** — enable frosted-glass blur behind transparent
  windows (`decoration:blur`, size 8, 2 passes).
- Values are read from the running compositor each time the panel opens.
- Fullscreen windows stay opaque.

Values are applied at runtime; a config reload (e.g. a theme change) resets
them to the values in `~/.config/hypr/looknfeel.lua`.

## Install

From GitHub:

```bash
omarchy plugin add https://github.com/<you>/slider.opacity --enable
```

The installer clones straight into `~/.config/omarchy/plugins/slider.opacity/`
(named by the manifest id) and leaves the widget disabled so you can review
the code first. `--enable` skips that step.

To update later:

```bash
omarchy plugin update slider.opacity
```

### Manual install

```bash
mkdir -p ~/.config/omarchy/plugins/slider.opacity
cp manifest.json Widget.qml ~/.config/omarchy/plugins/slider.opacity/
omarchy-shell shell rescanPlugins
omarchy plugin enable slider.opacity
```

## Using it

A "Opacity" button appears in the bar (default section: center; move it with
`omarchy bar move slider.opacity --section right`). Click it to open the
panel, then drag the sliders or toggle the glass switch.

## How it works

The bar-widget entry point is the stock `Panel` base (open/close lifecycle +
IPC) with the bar-located `KeyboardPanel` popup, reusing Omarchy's built-in
`PanelSlider` and `Toggle` components. Opacity and blur are applied through
`hyprctl eval 'hl.config({ decoration = { ... } })'`, which is the supported
runtime path for Hyprland's Lua config provider (`hyprctl keyword` is not).

## Files

| File           | Purpose                                          |
|----------------|--------------------------------------------------|
| `manifest.json`| Plugin manifest (`kinds: ["bar-widget"]`)        |
| `Widget.qml`   | Bar button, popup panel, sliders and glass toggle|

## License

MIT