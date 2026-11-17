#!/usr/bin/env bash
# Abre Spotify (Flatpak o paquete) y, si no está instalado, el reproductor web
if flatpak info com.spotify.Client >/dev/null 2>&1; then
  exec flatpak run com.spotify.Client
elif command -v spotify >/dev/null 2>&1; then
  exec spotify
else
  exec "$(command -v firefox-esr || command -v firefox)" https://open.spotify.com
fi
