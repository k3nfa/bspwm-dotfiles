#!/usr/bin/env bash
DIAS=(domingo lunes martes miércoles jueves viernes sábado)
MESES=(enero febrero marzo abril mayo junio julio agosto septiembre octubre noviembre diciembre)
echo "${DIAS[$(date +%w)]}, $(date +%d) ${MESES[$(( 10#$(date +%m) - 1 ))]}"
