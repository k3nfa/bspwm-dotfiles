#!/usr/bin/env bash
# Entorno bspwm para Parrot y Kali · by k3nfa
# Uso: ./install.sh [--dry-run] [--no-root] [--yes]
set -uo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"
LOG="$HOME/.entorno-install.log"
DRY=0; DO_ROOT=1; ASSUME_YES=0; UNKNOWN=0
for a in "$@"; do
  case "$a" in
    --dry-run) DRY=1 ;;
    --root)    DO_ROOT=1 ;;
    --no-root) DO_ROOT=0 ;;
    -y|--yes)  ASSUME_YES=1 ;;
    -h|--help) echo "Uso: ./install.sh [--dry-run] [--no-root] [--yes]"; exit 0 ;;
  esac
done

# ---------- Colores ----------
X=$'\e[0m'; BOLD=$'\e[1m'; D=$'\e[38;5;245m'
R=$'\e[38;5;203m'; G=$'\e[38;5;114m'; Y=$'\e[38;5;221m'
B=$'\e[38;5;111m'; P=$'\e[38;5;183m'; C=$'\e[38;5;117m'

STEP=0; TOTAL=6; OKS=(); FAILS=(); KEEP=""
SPIN=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)

cleanup() { tput cnorm 2>/dev/null; [ -n "$KEEP" ] && kill "$KEEP" 2>/dev/null; }
trap cleanup EXIT
trap 'echo; echo "  Cancelado."; exit 130' INT

# ---------- Banner ----------
banner() {
  clear
  local col=(177 141 105 69 75 81) i=0 l
  local art=(
'██╗  ██╗██████╗ ███╗   ██╗███████╗ █████╗ '
'██║ ██╔╝╚════██╗████╗  ██║██╔════╝██╔══██╗'
'█████╔╝  █████╔╝██╔██╗ ██║█████╗  ███████║'
'██╔═██╗  ╚═══██╗██║╚██╗██║██╔══╝  ██╔══██║'
'██║  ██╗██████╔╝██║ ╚████║██║     ██║  ██║'
'╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚═╝  ╚═╝'
  )
  echo
  for l in "${art[@]}"; do
    printf '   \e[38;5;%sm%s%s\n' "${col[i]}" "$l" "$X"
    i=$((i+1))
  done
  printf '\n   %s%sbspwm · polybar · picom · rofi · kitty%s\n' "$BOLD" "$P" "$X"
  printf '   %sParrot Security / Kali Linux  ·  github.com/k3nfa%s\n\n' "$D" "$X"
}

# ---------- Helpers de presentación ----------
bar() {
  local f=$(( $1 * 20 / $2 )) i s=""
  for ((i=0; i<20; i++)); do
    if [ "$i" -lt "$f" ]; then s+="▰"; else s+="▱"; fi
  done
  printf '%s' "$s"
}
step() {
  STEP=$((STEP+1))
  printf '\n%s━━ [%d/%d]%s %s%s%s  %s%s%s\n' "$P" "$STEP" "$TOTAL" "$X" "$BOLD" "$1" "$X" "$B" "$(bar "$STEP" "$TOTAL")" "$X"
}
ok()   { printf '  %s✔%s %s\n' "$G" "$X" "$*"; OKS+=("$*"); }
warn() { printf '  %s!%s %s\n' "$Y" "$X" "$*"; }
skip() { printf '  %s•%s %s%s%s\n' "$D" "$X" "$D" "$*" "$X"; }

# task "mensaje" comando...  -> spinner + ✔/✘, salida técnica al log
task() {
  local msg="$1"; shift
  if [ "$DRY" = 1 ]; then
    printf '  %s○%s %s %s(simulado)%s\n' "$D" "$X" "$msg" "$D" "$X"; OKS+=("$msg"); return 0
  fi
  "$@" </dev/null >>"$LOG" 2>&1 &
  local pid=$! i=0 t0=$SECONDS
  tput civis 2>/dev/null
  while kill -0 "$pid" 2>/dev/null; do
    printf '\r  %s%s%s %s %s(%ds)%s\033[K' "$C" "${SPIN[i%10]}" "$X" "$msg" "$D" "$((SECONDS-t0))" "$X"
    i=$((i+1)); sleep 0.1
  done
  wait "$pid"; local rc=$?
  tput cnorm 2>/dev/null
  if [ "$rc" -eq 0 ]; then
    printf '\r  %s✔%s %s %s(%ds)%s\033[K\n' "$G" "$X" "$msg" "$D" "$((SECONDS-t0))" "$X"
    OKS+=("$msg")
  else
    printf '\r  %s✘%s %s %s(mira %s)%s\033[K\n' "$R" "$X" "$msg" "$D" "$LOG" "$X"
    FAILS+=("$msg")
  fi
  return "$rc"
}

# ---------- Pantalla de inicio ----------
banner
if [ "$(id -u)" -eq 0 ]; then
  echo "  ${R}No lo ejecutes como root: usa tu usuario normal.${X}"; exit 1
fi
. /etc/os-release
case "${ID:-}" in parrot|kali) ;; *) UNKNOWN=1 ;; esac
MODO="instalación"; [ "$DRY" = 1 ] && MODO="ensayo (no cambia nada)"

printf '  %s╭─ Resumen%s\n' "$D" "$X"
printf '  %s│%s  Sistema   %s%s%s\n'  "$D" "$X" "$BOLD" "${PRETTY_NAME:-desconocido}" "$X"
printf '  %s│%s  Usuario   %s%s%s\n'  "$D" "$X" "$BOLD" "$USER" "$X"
printf '  %s│%s  Modo      %s%s%s\n'  "$D" "$X" "$BOLD" "$MODO" "$X"
printf '  %s│%s  Registro  %s%s%s\n'  "$D" "$X" "$BOLD" "$LOG" "$X"
printf '  %s╰─%s\n\n' "$D" "$X"
printf '  %sSe va a:%s\n' "$BOLD" "$X"
printf '    %s1%s paquetes base y extra     %s4%s copiar tus configuraciones (con respaldo)\n' "$P" "$X" "$P" "$X"
printf '    %s2%s fuente Nerd Font          %s5%s compilar Eww (calendario)\n' "$P" "$X" "$P" "$X"
printf '    %s3%s Powerlevel10k             %s6%s zsh y prompt (tú y root)\n\n' "$P" "$X" "$P" "$X"

if [ "$ASSUME_YES" = 0 ]; then
  [ "$UNKNOWN" = 1 ] && printf '  %s!%s Sistema no probado (solo Parrot y Kali).\n' "$Y" "$X"
  read -rp "  ¿Continuar? [S/n] " r
  case "${r:-S}" in n|N) echo "  Cancelado."; exit 0 ;; esac
fi

SECONDS=0; : > "$LOG"; echo "Instalación $(date)" >> "$LOG"
if [ "$DRY" = 0 ]; then
  printf '\n  %sNecesito tu contraseña de sudo una vez:%s\n' "$D" "$X"
  sudo -v || exit 1
  ( while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done ) >/dev/null 2>&1 &
  KEEP=$!
fi

# ---------- Datos ----------
BASE=(bspwm sxhkd polybar picom kitty rofi feh zsh git curl wget unzip
  build-essential python3 python3-pip lua5.4 sassc imagemagick fonts-font-awesome
  xdotool xclip brightnessctl playerctl pulseaudio-utils x11-utils mesa-utils i3lock
  zsh-autosuggestions zsh-syntax-highlighting fzf bat python3-gi python3-gi-cairo gir1.2-gtk-3.0)
EXTRA=(cava fastfetch lsd cmatrix)
APT="sudo env DEBIAN_FRONTEND=noninteractive apt-get"
BK="$HOME/.entorno-backup-$(date +%Y%m%d-%H%M%S)"

install_base() {
  $APT install -y "${BASE[@]}" && return 0
  local p rc=0
  for p in "${BASE[@]}"; do
    $APT install -y "$p" || { echo "NO SE PUDO INSTALAR: $p"; rc=1; }
  done
  return $rc
}

get_font() {
  mkdir -p ~/.local/share/fonts &&
  wget -q -O /tmp/Hack.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip &&
  unzip -oq /tmp/Hack.zip -d ~/.local/share/fonts/Hack &&
  fc-cache -f
}

copy_configs() {
  mkdir -p "$BK" ~/.config ~/.local/bin ~/Wallpapers
  for d in "$REPO"/config/*/; do
    n=$(basename "$d")
    [ -e ~/.config/"$n" ] && mv ~/.config/"$n" "$BK/$n"
    cp -r "$d" ~/.config/"$n" || return 1
  done
  for f in .zshrc .p10k.zsh; do
    [ -e ~/"$f" ] && cp ~/"$f" "$BK/$f"
    cp "$REPO/home/$f" ~/"$f" || return 1
  done
  cp "$REPO"/bin/* ~/.local/bin/
  cp -n "$REPO"/wallpapers/* ~/Wallpapers/ 2>/dev/null

  # Rutas de otro usuario (/home/k3nfa/...) -> las del usuario actual
  for d in "$REPO"/config/*/; do
    grep -rIlE "/home/[A-Za-z0-9._-]+/" ~/.config/"$(basename "$d")" 2>/dev/null
  done | xargs -r sed -i -E "s|/home/[A-Za-z0-9._-]+/|$HOME/|g"
  sed -i -E "s|/home/[A-Za-z0-9._-]+/|$HOME/|g" ~/.zshrc ~/.p10k.zsh

  chmod +x ~/.config/bspwm/bspwmrc ~/.config/bspwm/scripts/* \
           ~/.config/polybar/launch.sh ~/.config/polybar/scripts/* \
           ~/.config/eww/*.sh ~/.config/eww/scripts/* ~/.config/picom/start.sh ~/.config/rofi/*.sh ~/.config/rofi/accent.py ~/.local/bin/* 2>/dev/null

  # Ancho de pantalla para la animación de picom
  SW=$(xdpyinfo 2>/dev/null | awk '/dimensions:/{split($2,a,"x"); print a[1]; exit}')
  [ -n "$SW" ] && sed -i -E "s/start = \"[0-9]+ - window-x\"/start = \"$SW - window-x\"/" ~/.config/picom/picom.conf

  # Fondo inicial
  W=$(ls ~/Wallpapers/* 2>/dev/null | head -1)
  if [ -n "$W" ] && [ ! -f ~/.fehbg ]; then
    printf '#!/bin/sh\nfeh --no-fehbg --bg-fill %q\n' "$W" > ~/.fehbg
    chmod +x ~/.fehbg
  fi
  return 0
}

picom_light() {
  cat > ~/.config/picom/picom.conf << 'PICOM'
backend = "xrender";
vsync = false;
corner-radius = 0;
shadow = false;
fading = false;
inactive-opacity = 1.0;
active-opacity = 1.0;
PICOM
}

# ---------- 1 · Paquetes base ----------
step "Paquetes base"
task "Actualizando lista de paquetes" $APT update
task "Instalando ${#BASE[@]} paquetes base" install_base

# ---------- 2 · Paquetes extra ----------
step "Paquetes extra"
for p in "${EXTRA[@]}"; do
  task "Instalando $p" $APT install -y "$p" || true
done

# ---------- 3 · Fuente y prompt ----------
step "Fuente y prompt"
if [ -n "$(fc-list 2>/dev/null | grep -i Hack.Nerd.Font | head -n1)" ]; then
  skip "Hack Nerd Font ya estaba instalada"
else
  task "Instalando Hack Nerd Font" get_font
fi
if [ -f /usr/share/powerlevel10k/powerlevel10k.zsh-theme ]; then
  skip "Powerlevel10k ya estaba instalado"
else
  task "Instalando Powerlevel10k" sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /usr/share/powerlevel10k
fi

# ---------- 4 · Configuraciones ----------
step "Tus configuraciones"
task "Copiando configuraciones (respaldo en $BK)" copy_configs
if [ "$DRY" = 0 ]; then
  GL="$(glxinfo -B 2>/dev/null)"
  if [ -z "$GL" ]; then
    warn "No pude comprobar el 3D (¿sin sesión gráfica?). Picom elegirá su configuración al iniciar bspwm."
  elif echo "$GL" | grep -qiE 'llvmpipe|softpipe|swrast'; then
    warn "Sin aceleración 3D: picom usará la versión ligera (sin animaciones). Actívala en tu VM y reinicia sesión."
  fi
fi

# ---------- 5 · Eww ----------
step "Calendario (Eww)"
if [ -x ~/.local/bin/eww ]; then
  skip "Eww ya estaba instalado"
else
  task "Dependencias de Eww" $APT install -y cargo rustc pkg-config libgtk-3-dev libpango1.0-dev libgdk-pixbuf-2.0-dev libdbusmenu-gtk3-dev libcairo2-dev libglib2.0-dev \
  && task "Descargando Eww" bash -c 'rm -rf /tmp/eww && git clone --depth=1 https://github.com/elkowar/eww /tmp/eww' \
  && task "Compilando Eww (puede tardar varios minutos)" bash -c 'cd /tmp/eww && cargo build --release --no-default-features --features x11' \
  && task "Instalando Eww" bash -c 'mkdir -p ~/.local/bin && cp /tmp/eww/target/release/eww ~/.local/bin/eww' \
  || warn "Eww no se instaló. Si es por la versión de Rust, instala rustup (https://rustup.rs) y repite."
fi

# ---------- 6 · Shell ----------
step "Shell y toques finales"
if [ "$(basename "${SHELL:-}")" != "zsh" ]; then
  if [ "$DRY" = 1 ]; then
    skip "Cambiaría tu shell a zsh (simulado)"
  else
    printf '  %sCambio de shell a zsh: te pedirá tu contraseña%s\n' "$D" "$X"
    if chsh -s "$(command -v zsh)"; then ok "Shell por defecto: zsh"; else FAILS+=("Cambiar el shell a zsh"); fi
  fi
else
  skip "zsh ya es tu shell"
fi
if [ "$DO_ROOT" = 1 ]; then
  task "Configurando root (zsh, prompt y lsd)" bash -c 'sudo cp ~/.zshrc /root/.zshrc && sudo cp ~/.p10k.zsh /root/.p10k.zsh && sudo mkdir -p /root/.config/lsd && sudo cp ~/.config/lsd/*.yaml /root/.config/lsd/ && sudo chsh -s "$(command -v zsh)" root'
else
  skip "Root sin tocar (lo pediste con --no-root)"
fi

# ---------- Resumen ----------
T=$SECONDS
printf '\n%s╭─ Resultado%s\n' "$P" "$X"
printf '%s│%s  %s✔%s %d tareas correctas\n' "$P" "$X" "$G" "$X" "${#OKS[@]}"
if [ "${#FAILS[@]}" -gt 0 ]; then
  printf '%s│%s  %s✘%s %d con problemas:\n' "$P" "$X" "$R" "$X" "${#FAILS[@]}"
  for f in "${FAILS[@]}"; do printf '%s│%s     %s· %s%s\n' "$P" "$X" "$R" "$f" "$X"; done
  printf '%s│%s     %sDetalles en %s%s\n' "$P" "$X" "$D" "$LOG" "$X"
fi
printf '%s│%s  %sTiempo: %dm %ds%s\n' "$P" "$X" "$D" "$((T/60))" "$((T%60))" "$X"
printf '%s╰─%s\n' "$P" "$X"

if [ "$DRY" = 1 ]; then
  printf '\n  %sEnsayo terminado: no se cambió nada.%s\n\n' "$BOLD" "$X"
else
  printf '\n  %sSiguiente paso%s\n' "$BOLD" "$X"
  printf '    1. Cierra sesión y elige %sbspwm%s en la pantalla de inicio\n' "$C" "$X"
  printf '    2. %sSuper + Enter%s terminal   %sSuper + D%s lanzador   %sSuper + W%s wallpapers\n' "$B" "$X" "$B" "$X" "$B" "$X"
  printf '       %sSuper + L%s bloquear      %sSuper + C%s calendario\n' "$B" "$X" "$B" "$X"
  printf '    3. En VMware, activa la %saceleración 3D%s para ver las animaciones\n\n' "$Y" "$X"
fi
