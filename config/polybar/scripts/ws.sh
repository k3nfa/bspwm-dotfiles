#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"

ACTIVE=$'\U000f0baf'   # Pac-Man: escritorio actual
CIRCLE=$'\u25cf'       # mismo círculo para ocupado y vacío

render() {
  out="  "
  focused=$(bspc query -D -d focused)
  for d in $(bspc query -D); do
    if [ "$d" = "$focused" ]; then out+="%{T4}%{F$YELLOW}$ACTIVE%{F-}%{T-}  "
    elif [ -n "$(bspc query -N -d "$d")" ]; then out+="%{T5}%{F$RED}$CIRCLE%{F-}%{T-}  "
    else out+="%{T5}%{F#a66bff}$CIRCLE%{F-}%{T-}  "; fi
  done
  printf '%s\n' "$out"
}

render
bspc subscribe desktop_focus node_add node_remove node_transfer | while read -r _; do render; done
