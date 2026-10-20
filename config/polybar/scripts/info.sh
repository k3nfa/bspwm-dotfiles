#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"

case "$1" in
  logo)
    pill "%{F#1793d1}$I_LOGO%{F-}" ;;
  ip)
    IP=$(ip -4 -o addr show scope global 2>/dev/null \
      | awk '$2!~/^(tun|tap|wg|docker|br-|veth|lo)/ {print $4}' | head -1 | cut -d/ -f1)
    if [ -n "$IP" ]; then pill "%{F$GREEN}$I_WIFI%{F-} $IP"
    else pill "%{F$RED}$I_WIFI%{F-} Sin red"; fi ;;
  vpn)
    IP=$(ip -4 -o addr show 2>/dev/null \
      | awk '$2~/^(tun|tap|wg)/ {print $4}' | head -1 | cut -d/ -f1)
    if [ -n "$IP" ]; then pill "%{F$GREEN}$I_VPN%{F-} $IP"
    else pill "%{F$GRAY}$I_VPN%{F-} Disconnected"; fi ;;
  target)
    T=$(cat ~/.config/bspwm/.target 2>/dev/null)
    pill "%{F$RED}$I_TARGET%{F-} ${T:-No target}" ;;
  date)
    pill "%{F$BLUE}$I_CAL%{F-} $(date '+%H:%M') | %{F$GRAY}$(date '+%d/%m/%y')%{F-}" ;;
  updates)
    N=$(apt list --upgradable 2>/dev/null | tail -n +2 | wc -l)
    pill "%{F$GREEN}$I_UPD%{F-} $N" ;;
  power)
    pill "%{F$RED}$I_POWER%{F-}" ;;
esac
