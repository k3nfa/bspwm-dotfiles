#!/usr/bin/env python3
"""Lee un histograma de ImageMagick por stdin y escribe: acento texto-sobre-acento."""
import colorsys
import re
import sys

cols = []
for line in sys.stdin:
    m = re.match(r"\s*(\d+):.*?#([0-9A-Fa-f]{6})", line)
    if m:
        cols.append((int(m.group(1)), m.group(2)))

total = sum(c for c, _ in cols) or 1
best = None
for cnt, hx in cols:
    r, g, b = (int(hx[i:i + 2], 16) / 255 for i in (0, 2, 4))
    h, s, v = colorsys.rgb_to_hsv(r, g, b)
    if s < 0.28 or v < 0.22:          # ignora grises y casi negros
        continue
    score = (cnt / total) ** 0.4 * s * (0.4 + v)
    if best is None or score > best[0]:
        best = (score, h, s, v)

if best:
    _, h, s, v = best
    s, v = max(s, 0.72), max(v, 0.92)  # lo hace vivo
    r, g, b = colorsys.hsv_to_rgb(h, s, v)
else:
    r, g, b = 0.88, 0.88, 0.92         # fondo sin color: gris claro

acc = "#%02x%02x%02x" % (round(r * 255), round(g * 255), round(b * 255))
lum = 0.2126 * r + 0.7152 * g + 0.0722 * b
print(acc, "#0b0b12" if lum > 0.62 else "#ffffff")
