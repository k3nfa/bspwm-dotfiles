#!/usr/bin/env bash
# Arranca picom: configuración completa y, si falla o no hay 3D, la ligera
D="$HOME/.config/picom"
pkill -x picom
sleep 0.3

# Ancho de esta pantalla para la animación de deslizar
SW=$(xdpyinfo 2>/dev/null | awk '/dimensions:/{split($2,a,"x"); print a[1]; exit}')
[ -n "$SW" ] && sed -i -E "s/start = \"[0-9]+ - window-x\"/start = \"$SW - window-x\"/" "$D/picom.conf"

start() { picom --config "$1" -b 2>/dev/null; sleep 1; pgrep -x picom >/dev/null; }

GL=$(glxinfo -B 2>/dev/null | grep -i 'OpenGL renderer')
if echo "$GL" | grep -qiE 'llvmpipe|softpipe|swrast'; then
  start "$D/picom-light.conf"
else
  start "$D/picom.conf" || start "$D/picom-light.conf"
fi
