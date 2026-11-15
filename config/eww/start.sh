#!/usr/bin/env bash
E="$HOME/.local/bin/eww"
pkill -x eww
pkill -f eww/scripts/ws.sh
sleep 0.5
"$E" daemon
for i in $(seq 1 30); do "$E" ping >/dev/null 2>&1 && break; sleep 0.2; done
"$E" open calendario
"$E" open barra
