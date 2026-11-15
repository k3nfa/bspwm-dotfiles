#!/usr/bin/env bash
# Lanzador de rofi que usa el fondo de pantalla actual (imagen, fondo y color de acento)
CACHE="$HOME/.cache/rofi-launcher"
mkdir -p "$CACHE"
W=900; H=550; LW=320
IM=magick; command -v magick >/dev/null || IM=convert

wall=$(grep -oE "'[^']+'" ~/.fehbg 2>/dev/null | tail -1 | tr -d "'")
[ -f "$wall" ] || wall=$(ls ~/Wallpapers/* 2>/dev/null | head -1)

if [ -f "$wall" ]; then
  key="$wall $(stat -c %Y "$wall")"
  if [ "$(cat "$CACHE/key" 2>/dev/null)" != "$key" ] || [ ! -f "$CACHE/left.png" ] || [ ! -f "$CACHE/bg.png" ] || [ ! -f "$CACHE/colors.rasi" ]; then
    $IM "$wall" -resize "${LW}x${H}^" -gravity center -extent "${LW}x${H}" "$CACHE/left.png"
    $IM "$wall" -resize "${W}x${H}^" -gravity center -extent "${W}x${H}" -blur 0x14 -fill black -colorize 62% "$CACHE/bg.png"
    read -r ACC FG < <($IM "$wall" -resize 120x120 -colors 12 -format %c histogram:info:- 2>/dev/null | python3 "$HOME/.config/rofi/accent.py")
    printf '* {\n  accent: %s;\n  accent-fg: %s;\n}\n' "${ACC:-#ff1148}" "${FG:-#ffffff}" > "$CACHE/colors.rasi"
    echo "$key" > "$CACHE/key"
  fi
fi
[ -f "$CACHE/colors.rasi" ] || printf '* {\n  accent: #ff1148;\n  accent-fg: #ffffff;\n}\n' > "$CACHE/colors.rasi"

exec rofi -no-config -show drun -modi drun,run,window -theme "$HOME/.config/rofi/launcher2.rasi"
