#!/usr/bin/env bash
case "$1" in
  ip)     ip -4 -o addr show scope global 2>/dev/null | awk '$2!~/^(tun|tap|wg|docker|br-|veth|lo)/ {print $4}' | head -1 | cut -d/ -f1 ;;
  vpn)    ip -4 -o addr show 2>/dev/null | awk '$2~/^(tun|tap|wg)/ {print $4}' | head -1 | cut -d/ -f1 ;;
  target) cat ~/.config/bspwm/.target 2>/dev/null ;;
esac
