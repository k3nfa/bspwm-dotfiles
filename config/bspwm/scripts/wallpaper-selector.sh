#!/usr/bin/env bash
pgrep -f wallpicker.py >/dev/null && exit 0
bspc rule -r Wallpicker >/dev/null 2>&1; bspc rule -r "*:wallpicker" >/dev/null 2>&1
bspc rule -a Wallpicker state=fullscreen border=off focus=on
bspc rule -a "*:wallpicker" state=fullscreen border=off focus=on
python3 "$HOME/.config/bspwm/scripts/wallpicker.py" || exec "$HOME/.config/bspwm/scripts/wallpaper-selector-rofi.sh"
