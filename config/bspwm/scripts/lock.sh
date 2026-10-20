#!/usr/bin/env bash
IMG=/tmp/lock.png
FONT=$(fc-match -f '%{file}' "Hack Nerd Font:bold")
command -v magick > /dev/null && IM=magick || IM=convert

DIAS=(domingo lunes martes miércoles jueves viernes sábado)
MESES=(ene feb mar abr may jun jul ago sep oct nov dic)
HORA=$(date +%H:%M)
FECHA="${DIAS[$(date +%w)]}, $(date +%d) ${MESES[$(( 10#$(date +%m) - 1 ))]}"

import -silent -window root "$IMG"

$IM "$IMG" -blur 0x8 -fill '#cdd6f4' -font "$FONT" -gravity center \
  -pointsize 120 -annotate +0-60 "$HORA" \
  -pointsize 36 -annotate +0+40 "$FECHA" \
  -pointsize 20 -annotate +0+120 "Type the password to unlock" "$IMG"

i3lock -n -f -i "$IMG"
rm -f "$IMG"
