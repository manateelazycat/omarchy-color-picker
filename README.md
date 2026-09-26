# Omarchy Color Picker

English | [简体中文](README.zh-CN.md)

https://github.com/user-attachments/assets/1ee22eef-4369-42eb-83d6-507146b6a505

An Omarchy 4 top bar color picker. Clicking its icon turns the cursor into a circular pixel magnifier. Click any pixel to leave picking mode and copy its color to the system clipboard.

## Features

- Appears on the right side of the Omarchy top bar by default.
- An 8× circular pixel magnifier marks the exact center pixel being sampled.
- Left-click to start picking, click a pixel to finish, or press `Esc` to cancel.
- Right-click to choose a clipboard format; the choice is saved.
- Supports `HEX`, `RGB`, and `HSL`.

Example clipboard results:

```text
#1E90FF
rgb(30, 144, 255)
hsl(210, 100%, 56%)
```

## Requirements

- Omarchy 4 (Quattro) and its Quickshell plugin system
- `hyprpicker`
- `wl-clipboard` (provides `wl-copy`)

## Install

Install and enable the plugin from GitHub with the Omarchy plugin manager:

```bash
omarchy plugin add https://github.com/manateelazycat/omarchy-color-picker.git --enable --yes
```

The plugin appears on the right side of the top bar by default.

## Usage

- Left-click the color picker icon in the top bar to start picking.
- Move the pointer to select the center pixel with the circular magnifier.
- Click to copy the color, or press `Esc` to cancel.
- Right-click the bar icon to switch between `HEX`, `RGB`, and `HSL` in the menu.

## Validation

```bash
omarchy plugin validate .
./tests/color-pickerctl-test.sh
```

## Remove

```bash
omarchy plugin remove io.github.manateelazycat.color-picker --yes
```

Removing the plugin does not remove `hyprpicker` or `wl-clipboard`.

## License

This project is distributed under the [GNU General Public License v3.0](LICENSE), with SPDX identifier `GPL-3.0-only`.
