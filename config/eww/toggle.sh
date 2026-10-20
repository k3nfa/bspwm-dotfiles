#!/usr/bin/env bash
E="$HOME/.local/bin/eww"
if "$E" active-windows 2>/dev/null | grep -q calendario; then
  "$E" close calendario
else
  "$E" open calendario
fi
