#!/usr/bin/env bash
killall -q polybar
while pgrep -u $UID -x polybar > /dev/null; do sleep 0.2; done
for b in logo ip vpn workspaces updates date target power; do
  polybar -q "$b" -c ~/.config/polybar/config.ini &
done
