#!/usr/bin/env bash
E="$HOME/.local/bin/eww"
if [ "$("$E" get dots_open)" = "true" ]; then
  "$E" update dots_open=false
else
  "$E" update dots_open=true
fi
