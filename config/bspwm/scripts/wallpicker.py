#!/usr/bin/env python3
"""Selector de fondos tipo carrusel (Super + W)."""
import math
import os
import re
import subprocess
import sys

import gi
gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")
from gi.repository import Gtk, Gdk, GdkPixbuf, GLib

DIR = os.path.expanduser("~/Wallpapers")
EXT = (".jpg", ".jpeg", ".png", ".webp")

# --- Aspecto (proporciones de la pantalla) ---
SKEW = 0.17                   # inclinación de los paralelogramos
SEL_W, SEL_H = 0.324, 0.370   # tamaño del seleccionado
SIDE_W, SIDE_H = 0.100, 0.296 # tamaño de los demás
GAP = 0.007                   # separación entre fondos
TOP = 0.294                   # altura a la que empieza la fila
BORDER = (1.0, 0.12, 0.35)    # borde del seleccionado
DIM = 0.62                    # oscuridad del fondo (0 a 1)
SPEED = 0.22                  # velocidad de la animación


def load_items():
    items = []
    if not os.path.isdir(DIR):
        return items
    for f in sorted(os.listdir(DIR), key=str.lower):
        if not f.lower().endswith(EXT):
            continue
        p = os.path.join(DIR, f)
        try:
            pb = GdkPixbuf.Pixbuf.new_from_file_at_scale(p, 1000, 700, True)
        except GLib.Error:
            continue
        items.append((p, pb))
    return items


def current_index(items):
    try:
        txt = open(os.path.expanduser("~/.fehbg")).read()
        found = re.findall(r"'([^']+)'", txt)
        cur = os.path.basename(found[-1])
        for i, (p, _) in enumerate(items):
            if os.path.basename(p) == cur:
                return i
    except Exception:
        pass
    return 0


def cover(cr, pb, x, y, w, h, alpha=1.0, clip=True):
    pw, ph = pb.get_width(), pb.get_height()
    s = max(w / pw, h / ph)
    cr.save()
    if clip:
        cr.rectangle(x, y, w, h)
        cr.clip()
    cr.translate(x + (w - pw * s) / 2, y + (h - ph * s) / 2)
    cr.scale(s, s)
    Gdk.cairo_set_source_pixbuf(cr, pb, 0, 0)
    cr.paint_with_alpha(alpha)
    cr.restore()


def shape(cr, poly):
    cr.new_path()
    cr.move_to(*poly[0])
    for p in poly[1:]:
        cr.line_to(*p)
    cr.close_path()


def inside(poly, x, y):
    sign = None
    for (x1, y1), (x2, y2) in zip(poly, poly[1:] + poly[:1]):
        c = (x2 - x1) * (y - y1) - (y2 - y1) * (x - x1)
        if c == 0:
            continue
        if sign is None:
            sign = c > 0
        elif (c > 0) != sign:
            return False
    return True


class Picker(Gtk.Window):
    def __init__(self, items):
        super().__init__(title="wallpicker")
        self.items = items
        self.target = current_index(items)
        self.pos = float(self.target)
        self.timer = 0
        self.hit = []

        self.area = Gtk.DrawingArea()
        self.area.add_events(Gdk.EventMask.BUTTON_PRESS_MASK | Gdk.EventMask.SCROLL_MASK)
        self.area.connect("draw", self.on_draw)
        self.area.connect("button-press-event", self.on_click)
        self.area.connect("scroll-event", self.on_scroll)
        self.add(self.area)
        self.connect("key-press-event", self.on_key)
        self.connect("destroy", Gtk.main_quit)
        self.set_decorated(False)
        self.set_keep_above(True)
        disp = Gdk.Display.get_default()
        mon = disp.get_primary_monitor() or disp.get_monitor(0)
        g = mon.get_geometry()
        self.set_default_size(g.width, g.height)
        self.move(g.x, g.y)
        self.fullscreen()
        self.show_all()
        self.present()

    # ---- geometría ----
    def geom(self, d, W, H):
        ad = abs(d)
        t = min(ad, 1.0)
        w = (SEL_W + (SIDE_W - SEL_W) * t) * W
        h = (SEL_H + (SIDE_H - SEL_H) * t) * H
        base = ((SEL_W + SIDE_W) / 2 + GAP) * W
        step = (SIDE_W + GAP) * W
        off = base * ad if ad <= 1 else base + (ad - 1) * step
        if d < 0:
            off = -off
        xc = W / 2 + (SKEW * SEL_H * H) / 2 + off
        return xc, w, h

    # ---- dibujo ----
    def on_draw(self, widget, cr):
        W = widget.get_allocated_width()
        H = widget.get_allocated_height()
        n = len(self.items)
        p0 = max(0, min(n - 1, int(math.floor(self.pos))))
        fr = self.pos - p0

        cr.set_source_rgb(0, 0, 0)
        cr.paint()
        cover(cr, self.items[p0][1], 0, 0, W, H, 1.0)
        if fr > 0.001 and p0 + 1 < n:
            cover(cr, self.items[p0 + 1][1], 0, 0, W, H, fr)
        cr.set_source_rgba(0.02, 0.02, 0.05, DIM)
        cr.paint()

        self.hit = []
        top = TOP * H
        for i in sorted(range(n), key=lambda k: -abs(k - self.pos)):
            d = i - self.pos
            xc, w, h = self.geom(d, W, H)
            sh = SKEW * h
            xl = xc - w / 2
            if xl + w < 0 or xl - sh > W:
                continue
            poly = [(xl, top), (xl + w, top), (xl + w - sh, top + h), (xl - sh, top + h)]
            near = 1.0 - min(abs(d), 1.0)

            cr.save()
            shape(cr, poly)
            cr.clip()
            cover(cr, self.items[i][1], xl - sh, top, w + sh, h, 0.55 + 0.45 * near, clip=False)
            cr.restore()

            if near > 0.02:
                shape(cr, poly)
                cr.set_source_rgba(BORDER[0], BORDER[1], BORDER[2], near)
                cr.set_line_width(3)
                cr.stroke()
            self.hit.append((i, poly))
        return False

    # ---- movimiento ----
    def go(self, target):
        self.target = max(0, min(len(self.items) - 1, target))
        if not self.timer:
            self.timer = GLib.timeout_add(16, self.tick)

    def tick(self):
        diff = self.target - self.pos
        if abs(diff) < 0.003:
            self.pos = float(self.target)
            self.timer = 0
            self.area.queue_draw()
            return False
        self.pos += diff * SPEED
        self.area.queue_draw()
        return True

    def apply(self):
        subprocess.run(["feh", "--bg-fill", self.items[self.target][0]])
        Gtk.main_quit()

    # ---- entrada ----
    def on_key(self, widget, ev):
        k = Gdk.keyval_name(ev.keyval)
        if k in ("Right", "l", "Tab"):
            self.go(self.target + 1)
        elif k in ("Left", "h", "ISO_Left_Tab"):
            self.go(self.target - 1)
        elif k == "Home":
            self.go(0)
        elif k == "End":
            self.go(len(self.items) - 1)
        elif k in ("Return", "KP_Enter", "space"):
            self.apply()
        elif k in ("Escape", "q"):
            Gtk.main_quit()
        return True

    def on_click(self, widget, ev):
        if ev.button != 1:
            return
        for i, poly in reversed(self.hit):
            if inside(poly, ev.x, ev.y):
                if i == self.target:
                    self.apply()
                else:
                    self.go(i)
                return
        Gtk.main_quit()

    def on_scroll(self, widget, ev):
        if ev.direction in (Gdk.ScrollDirection.DOWN, Gdk.ScrollDirection.RIGHT):
            self.go(self.target + 1)
        elif ev.direction in (Gdk.ScrollDirection.UP, Gdk.ScrollDirection.LEFT):
            self.go(self.target - 1)
        elif ev.direction == Gdk.ScrollDirection.SMOOTH:
            self.go(self.target + (1 if ev.delta_y > 0 else -1))


def main():
    GLib.set_prgname("wallpicker")
    items = load_items()
    if not items:
        print("No hay fondos en", DIR, file=sys.stderr)
        return
    Picker(items)
    Gtk.main()


if __name__ == "__main__":
    main()
