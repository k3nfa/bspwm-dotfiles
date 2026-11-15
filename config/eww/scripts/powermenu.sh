#!/usr/bin/env bash
op=$(printf 'Bloquear\nCerrar sesión\nReiniciar\nApagar\n' | rofi -dmenu -i -p "" -theme ~/.config/rofi/launcher.rasi)
case "$op" in
  Bloquear)         ~/.config/bspwm/scripts/lock.sh ;;
  "Cerrar sesión")  bspc quit ;;
  Reiniciar)        systemctl reboot ;;
  Apagar)           systemctl poweroff ;;
esac
