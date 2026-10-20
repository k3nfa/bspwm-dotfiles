# Entorno bspwm para Parrot y Kali

bspwm + sxhkd + polybar (píldoras) + picom (animaciones) + rofi + kitty + Powerlevel10k, con calendario en Eww, bloqueo de pantalla, cava, fastfetch, lsd y bat.

## Instalación

~~~bash
git clone https://github.com/k3nfa/bspwm-dotfiles.git
cd bspwm-dotfiles
./install.sh --dry-run   # solo muestra lo que haría
./install.sh --root      # instala (y deja root con el mismo prompt)
~~~

Después cierra sesión y elige **bspwm** en la pantalla de inicio. Tu configuración anterior queda respaldada en `~/.entorno-backup-FECHA`.

Probado en Parrot Security. En una VM de VMware activa la **aceleración 3D** (si no, picom va sin animaciones).

## Atajos (Super = tecla Windows)

| Atajo | Acción |
|---|---|
| Super + Enter / Q | Abrir / cerrar terminal |
| Super + D | Lanzador (rofi) |
| Super + W | Selector de wallpapers |
| Super + L | Bloquear pantalla |
| Super + C | Mostrar / ocultar calendario |
| Super + Shift + F | Firefox |
| Super + Esc | Recargar atajos |
| Super + Shift + R | Recargar entorno |
| Super + Shift + Q | Cerrar sesión |
| Super + 1-6 / Shift + 1-6 | Ir a escritorio / enviar ventana |
| Super + T / Shift + T / S / F | Encajada / pseudo / flotante / pantalla completa |
| Super + M | Monocle |
| Super + Flechas / Shift + Flechas | Enfocar / intercambiar |
| Super + Alt + Flechas | Cambiar tamaño |
| Super + Ctrl + Flechas | Mover ventana flotante |
| Super + clic izq. / der. | Mover / redimensionar con el ratón |
| Super + Ctrl + Alt + Flechas | Preselector (Espacio lo cancela, Ctrl + 1-9 su tamaño) |
| Super + Ctrl + M, luego Super + Y | Marcar ventana y enviarla al preselector |
| Esc + Esc | Añade `sudo` al comando |
| Ctrl + R / Ctrl + T | fzf: historial / archivos |

Para fijar un objetivo en la barra: `settarget 10.10.11.5 nombre` y `cleartarget`.
