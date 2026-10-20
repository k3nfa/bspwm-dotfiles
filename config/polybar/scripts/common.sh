#!/usr/bin/env bash
# Colores
PILL="#1e1e2e"; FG="#f5f7ff"; GREEN="#50fa7b"; RED="#ff5c7c"
GRAY="#a3adc2"; BLUE="#4dabff"; PURPLE="#c084ff"; YELLOW="#ffd23f"

# Extremos redondeados de la píldora
L=$'\ue0b6'; R=$'\ue0b4'

# Íconos (cámbialos a tu gusto)
I_LOGO=$'\uf303'; I_WIFI=$'\U000f0a5f'; I_VPN=$'\uf1b2'; I_CAL=$'\uf073'
I_TARGET=$'\uf05b'; I_POWER=$'\uf011'; I_UPD=$'\uf021'

# pill "contenido" [color_texto]
pill() {
  printf '%%{F%s}%s%%{B%s}%%{F%s} %s %%{B-}%%{F%s}%s%%{F-}\n' \
    "$PILL" "$L" "$PILL" "${2:-$FG}" "$1" "$PILL" "$R"
}

# Extremos con fuente grande (T2) e íconos con fuente media (T3)
L=$'%{T2}\ue0b6%{T-}'; R=$'%{T2}\ue0b4%{T-}'
I_LOGO=$'%{T3}\uf303%{T-}'; I_WIFI=$'%{T3}\U000f0a5f%{T-}'; I_VPN=$'%{T3}\uf1b2%{T-}'
I_CAL=$'%{T3}\uf073%{T-}'; I_TARGET=$'%{T3}\uf05b%{T-}'
I_POWER=$'%{T3}\uf011%{T-}'; I_UPD=$'%{T3}\uf021%{T-}'

# Sin glifos: el fondo y el redondeo los pone cada barra
pill() { printf '%s\n' "$1"; }
