#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Captura CADA diapositiva del HTML a PNG y recoge los errores de consola.

    python hkslides_shot.py diapositivas.html carpeta_png [--n 22]

No se aprueba una presentación mirando el HTML crudo: hay que ver si el JS
dibujó. Esto avanza con la tecla 'a' (mostrar todos los pasos) + flecha, y
guarda un PNG por diapositiva, más un .errores.txt con lo que dijo la consola.
"""
import sys, os, argparse, asyncio
from playwright.async_api import async_playwright


async def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("html")
    ap.add_argument("out")
    ap.add_argument("--ancho", type=int, default=1920)
    ap.add_argument("--alto", type=int, default=1080)
    a = ap.parse_args()
    os.makedirs(a.out, exist_ok=True)
    errores = []

    async with async_playwright() as p:
        b = await p.chromium.launch()
        pg = await b.new_page(viewport={"width": a.ancho, "height": a.alto})
        pg.on("console", lambda m: errores.append("[%s] %s" % (m.type, m.text))
              if m.type in ("error", "warning") else None)
        pg.on("pageerror", lambda e: errores.append("[pageerror] %s" % e))
        await pg.goto("file:///" + os.path.abspath(a.html).replace("\\", "/"))
        await pg.wait_for_timeout(1200)
        n = await pg.evaluate("document.querySelectorAll('.slide').length")
        for i in range(n):
            await pg.evaluate("window.hkIr(%d)" % i)
            await pg.keyboard.press("a")
            await pg.wait_for_timeout(500)
            await pg.screenshot(path=os.path.join(a.out, "d%02d.png" % (i + 1)))
        await b.close()

    open(os.path.join(a.out, "errores.txt"), "w", encoding="utf-8").write(
        "\n".join(errores) if errores else "sin errores de consola")
    print("%d PNG en %s · %d mensajes de consola" % (n, a.out, len(errores)))


asyncio.run(main())
