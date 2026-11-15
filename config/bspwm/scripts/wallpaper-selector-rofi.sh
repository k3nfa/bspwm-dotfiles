#!/usr/bin/env bash
DIR="$HOME/Wallpapers"
THEME="$HOME/.config/rofi/wallpaper.rasi"

[ -d "$DIR" ] || exit 1

choice=$(find "$DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) -printf '%f\n' | sort | while read -r f; do
  printf '%s\0icon\x1f%s\n' "$f" "$DIR/$f"
done | rofi -dmenu -i -show-icons -theme "$THEME" -p "")

[ -n "$choice" ] && feh --bg-fill "$DIR/$choice"
