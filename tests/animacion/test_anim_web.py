#!/usr/bin/env python3
"""Animación + voz en la WEB (el mismo C# compilado a WebAssembly), con Playwright.

Antes:  cd hekatan-lisp/web && python serve.py 8765   (sobre la web publicada: dotnet publish -c Release)
Uso:    python tests/animacion/test_anim_web.py [carpeta_png]

1. tests/animacion/anim_voz.lisp: nº de cuadros de cada animación, que avanza sola, la barra, el
   subtítulo de la voz con {n} sustituido, el lienzo único de #anim surf, el bloque #anim(…) … #finanim.
2. ejemplo 82: las 16 funciones de forma (16 cuadros, 16 textos de voz) y el refinamiento h (8 mallas,
   una malla y un mapa por cuadro, voz con el error de cada malla).
3. voz: Chromium sin voces en español → el botón 🔊 se oculta y la animación sigue sola.
"""
import glob, json, os, re, sys
from playwright.sync_api import sync_playwright
sys.stdout.reconfigure(encoding="utf-8")

URL = os.environ.get("HK_WEB_URL", "http://localhost:8765/")
RAIZ = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.environ.get("TEMP", "."), "hk_anim_web")
os.makedirs(OUT, exist_ok=True)
HOJA = open(os.path.join(RAIZ, "tests", "animacion", "anim_voz.lisp"), encoding="utf-8").read()
E82 = open(glob.glob(os.path.join(RAIZ, "ejemplos", "82 *.lisp"))[0], encoding="utf-8").read()

fallos = []
def ok(cond, msg):
    print(("  ✓ " if cond else "  ✗ ") + msg)
    if not cond: fallos.append(msg)

A = "document.querySelectorAll('.hk-anim')"

with sync_playwright() as p:
    b = p.chromium.launch()
    pg = b.new_page(viewport={"width": 1400, "height": 1500})
    errores = []
    pg.on("pageerror", lambda e: errores.append(str(e)))
    pg.goto(URL)
    pg.wait_for_function("!document.getElementById('carga')", timeout=180000)
    pg.evaluate("document.getElementById('intro')?.classList.add('oculto')")

    def frame():
        return pg.frames[1]
    def cargar(t, n_min):
        pg.evaluate("t => { const e = document.getElementById('code'); e.value = t; e.dispatchEvent(new Event('input')); }", t)
        for _ in range(600):
            pg.wait_for_timeout(500)
            try:
                if frame().evaluate(A + ".length") >= n_min: break
            except Exception:
                pass
        pg.wait_for_timeout(800)
    def js(code):
        return frame().evaluate(code)
    def png(nombre, sel=None, idx=0):
        f = os.path.join(OUT, nombre + ".png")
        if sel is None:
            pg.screenshot(path=f)
        else:
            el = frame().locator(sel).nth(idx)
            el.scroll_into_view_if_needed(); pg.wait_for_timeout(300)
            el.screenshot(path=f)
        print("   PNG", f)

    print("1. hoja de prueba")
    cargar(HOJA, 6)
    ns = js("Array.from(" + A + ").map(r => +r.dataset.n)")
    ok(ns == [4, 4, 4, 3, 5, 3], f"cuadros por animación: {ns}")
    pg.wait_for_timeout(4000)
    i0 = js(A + "[0].hkAnim.i")
    ok(i0 > 0, f"avanza sola: cuadro {i0}")
    js(A + "[0].hkAnim.para(); " + A + "[0].hkAnim.show(1)")
    ok(js(A + "[0].querySelector('.hk-anim-sub').textContent") == "La potencia 2 de x.", "subtítulo del cuadro 2 con {n} = 2")
    ok(js("JSON.parse(" + A + "[1].querySelector('canvas').dataset.frames).length") == 4, "#anim surf: un lienzo con 4 cuadros")
    ok(js(A + "[4].hkAnim.voz[2]") == "Con 3 tramos de carga.", "bloque de dibujo: voz del cuadro 3")
    ok(js(A + "[5].hkAnim.voz") == ["Cuadro 1.", "Cuadro 2.", "Cuadro 3."], "#voz dentro del bloque #anim … #finanim")
    # la barra: un clic real sobre el final de la barra del bloque de dibujo
    bar = frame().locator(".hk-anim-bar").nth(4)
    bar.scroll_into_view_if_needed()
    bb = bar.bounding_box()
    pg.mouse.click(bb["x"] + bb["width"] - 3, bb["y"] + bb["height"] / 2)
    pg.wait_for_timeout(300)
    ok(js(A + "[4].hkAnim.i") == 4, f"clic en la barra → último cuadro ({js(A + '[4].hkAnim.i')})")
    png("w1_bloque_dibujo_cuadro5", ".hk-anim", 4)
    lang = js(A + "[0].dataset.voz")
    disp = js(A + "[0].querySelector('.hk-anim-voz').style.display")
    print(f"     voz del navegador: {lang!r}")
    ok((disp == "") if lang else (disp == "none"), "🔊 visible solo si hay voz en español")
    # imprimir: el cuadro 1
    pg.emulate_media(media="print")
    vis = js("getComputedStyle(" + A + "[4].querySelector('.hkfr[data-i=\"0\"]')).visibility")
    ok(vis == "visible", "al imprimir se ve el cuadro 1")
    pg.emulate_media(media="screen")

    print("2. ejemplo 82")
    cargar(E82, 2)
    ns = js("Array.from(" + A + ").map(r => +r.dataset.n)")
    ok(ns == [16, 8], f"funciones de forma y mallas: {ns}")
    voces = js(A + "[0].hkAnim.voz")
    ok(len(voces) == 16 and all(voces) and voces[0].startswith("Función 1"), "16 textos de voz, uno por función")
    js(A + "[0].hkAnim.para(); " + A + "[0].hkAnim.show(3)")
    png("w2_funcion_forma_4", ".hk-anim", 0)
    js(A + "[0].hkAnim.show(8)")
    png("w3_funcion_forma_9", ".hk-anim", 0)
    ok(js(A + "[1].querySelectorAll('.hkfr img').length") >= 16, "refinamiento: una malla y un mapa por cuadro")
    v1 = js(A + "[1].hkAnim.voz")
    ok(len(v1) == 8 and "Malla de 16 por 16" in v1[7] and "0.00026" in v1[7], f"voz del cuadro 8: {v1[7][:90]}…")
    js(A + "[1].hkAnim.para(); " + A + "[1].hkAnim.show(7)")
    png("w4_malla_16x16", ".hkfr[data-i=\"7\"]", 0)
    txt = js("document.body.innerText")
    m = re.search(r"orden de la flecha entre 14", txt)
    pw = re.findall(r"4\.01\d*", txt.replace("\n", " "))
    ok(m is not None and len(pw) > 0, f"orden de la flecha ≈ 4.01 ({pw[:2]})")
    png("w5_pagina")
    ok(not errores, f"sin errores de JS en la página: {errores[:3]}")
    b.close()

print(f"\nPNG en {OUT}")
print("TODO OK" if not fallos else f"{len(fallos)} FALLARON")
sys.exit(1 if fallos else 0)
