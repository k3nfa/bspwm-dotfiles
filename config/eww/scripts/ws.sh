#!/usr/bin/env bash
render() {
  focused=$(bspc query -D -d focused)
  out="["; sep=""
  for id in $(bspc query -D); do
    n=$(bspc query -D -d "$id" --names)
    if [ "$id" = "$focused" ]; then s="focused"
    elif [ -n "$(bspc query -N -d "$id")" ]; then s="busy"
    else s="empty"; fi
    out+="$sep{\"n\":\"$n\",\"s\":\"$s\"}"; sep=","
  done
  echo "$out]"
}
render
bspc subscribe desktop_focus node_add node_remove node_transfer | while read -r _; do render; done
