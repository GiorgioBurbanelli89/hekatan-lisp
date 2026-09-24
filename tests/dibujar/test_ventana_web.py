#!/usr/bin/env python3
"""La ventana de dibujo de #dibujar en la WEB, con ratón y teclado REALES (Playwright).

Antes:  cd hekatan-lisp/web && python serve.py 8765   (sobre la web publicada: dotnet publish -c Release)
Uso:    python tests/dibujar/test_ventana_web.py [carpeta_png]

Pasos (un PNG por paso en la carpeta):
  1. hoja con #dibujar(r) vacío + un #autolisp que lee lo dibujado → 0 entidades
  2. ✏ abre la ventana
  3. REC por la LÍNEA DE ÓRDENES: 0,0 → @0.3,0.5
  4. LINEA con CLICS: el primer clic cae a 4 px del vértice (0.3,0.5) → OSNAP lo lleva al punto exacto
  5. CIRCULO: clic en el centro + radio tecleado; ARCO por 3 puntos; COTA; TEXTO; mover y deshacer
  6. 💾 Guardar → el bloque entra en el EDITOR, la hoja se recalcula: A = 0.15, I = b·h³/12 = 0.003125
  7. reabrir: las entidades leídas de la hoja = las que se escribieron (ida y vuelta)
  8. ejemplo 81: abrir y guardar sin cambios → la hoja queda IDÉNTICA
"""
import os, re, sys, json
from playwright.sync_api import sync_playwright
sys.stdout.reconfigure(encoding="utf-8")

URL = "http://localhost:8765/"
OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.environ.get("TEMP", "."), "hk_dibujar_web")
os.makedirs(OUT, exist_ok=True)

HOJA = open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "hoja_prueba.lisp"), encoding="utf-8").read()

fallos = []
def ok(cond, msg):
    print(("  ✓ " if cond else "  ✗ ") + msg)
    if not cond: fallos.append(msg)

with sync_playwright() as p:
    b = p.chromium.launch()
    pg = b.new_page(viewport={"width": 1500, "height": 950})
    errores = []
    pg.on("pageerror", lambda e: errores.append(str(e)))
    pg.goto(URL)
    pg.wait_for_function("!document.getElementById('carga')", timeout=120000)
    pg.evaluate("document.getElementById('intro')?.classList.add('oculto')")

    def fr():
        return pg.frame_locator("#render")
    def frame():
        return pg.frames[1]
    def esperar_calculo():
        pg.wait_for_timeout(400)
        pg.wait_for_function("!document.getElementById('hk-calc') || document.getElementById('hk-calc').style.display==='none'", timeout=120000)
        pg.wait_for_timeout(300)
    def salida():
        return frame().evaluate("document.body.innerText")
    def a_pagina(x, y):
        bx = pg.locator("#render").bounding_box()
        q = frame().evaluate(f"hkCad.pantalla({x},{y})")
        return bx["x"] + q[0], bx["y"] + q[1]
    def teclear(t):
        pg.keyboard.type(t); pg.keyboard.press("Enter"); pg.wait_for_timeout(60)
    def png(n, nombre):
        f = os.path.join(OUT, f"{n:02d}_{nombre}.png"); pg.screenshot(path=f); print("   PNG", f)

    print("1. hoja con #dibujar vacío")
    pg.evaluate("t => { const e = document.getElementById('code'); e.value = t; e.dispatchEvent(new Event('input')); }", HOJA)
    esperar_calculo()
    s = salida()
    ok("n_e = 0" in s.replace("\n", " ") or re.search(r"n\s*e\s*=\s*0", s) is not None, "sin dibujo: n_e = 0")
    ok(fr().locator(".hk-cad-btn").count() == 1, "hay botón ✏ Dibujar / Editar")
    png(1, "hoja_vacia")

    print("2. abrir la ventana")
    fr().locator(".hk-cad-btn").click()
    pg.wait_for_timeout(500)
    ok(frame().evaluate("!!document.querySelector('.hkcad')"), "la ventana está abierta")
    ok(pg.evaluate("document.body.classList.contains('solo')"), "el resultado pasa a pantalla completa")
    png(2, "ventana_abierta")

    print("3. REC por la línea de órdenes")
    teclear("REC"); teclear("0,0"); teclear("@0.3,0.5")
    est = frame().evaluate("hkCad.estado()")
    ok(len(est["ents"]) == 1 and est["ents"][0][0][1] == "LWPOLYLINE", "un rectángulo (LWPOLYLINE)")
    png(3, "rectangulo_por_ordenes")

    print("4. LINEA con clics y OSNAP")
    teclear("L")
    x, y = a_pagina(0.3, 0.5)
    pg.mouse.move(x + 4, y - 3); pg.wait_for_timeout(120)
    png(4, "osnap_punto_final")
    pg.mouse.click(x + 4, y - 3)
    x2, y2 = a_pagina(0.6, 0.5)
    pg.mouse.click(x2, y2)          # rejilla 0.05 + forzcursor → punto exacto
    pg.keyboard.press("Enter"); pg.wait_for_timeout(80)
    est = frame().evaluate("hkCad.estado()")
    lin = [e for e in est["ents"] if e[0][1] == "LINE"]
    ok(len(lin) == 1, "una línea")
    if lin:
        d = dict((k, v) for k, v in lin[0][2:] if k in (10, 11)) if False else {k: v for k, v in lin[0] if k in (10, 11)}
        ok(abs(d[10][0] - 0.3) < 1e-12 and abs(d[10][1] - 0.5) < 1e-12, f"OSNAP: inicio exacto en (0.3, 0.5) → {d[10]}")
        ok(abs(d[11][0] - 0.6) < 1e-9 and abs(d[11][1] - 0.5) < 1e-9, f"rejilla: fin en (0.6, 0.5) → {d[11]}")

    print("5. círculo, arco, cota, texto, polilínea con @d<ang; mover y deshacer")
    teclear("C"); cx, cy = a_pagina(0.75, 0.25); pg.mouse.click(cx, cy); teclear("0.1")
    teclear("A"); teclear("0.5,-0.1"); teclear("0.6,0"); teclear("0.7,-0.1")
    teclear("DIM"); teclear("0,0"); teclear("0.3,0"); teclear("0.15,-0.15")
    teclear("T"); teclear("0,0.6"); teclear("0.05"); teclear("0"); pg.keyboard.type("Sección 0.3 × 0.5"); pg.keyboard.press("Enter")
    teclear("PL"); teclear("1,0"); teclear("@0.2<0"); teclear("@0.2<90"); teclear("C")
    est = frame().evaluate("hkCad.estado()")
    tipos = [e[0][1] for e in est["ents"]]
    ok(tipos == ["LWPOLYLINE", "LINE", "CIRCLE", "ARC", "DIMENSION", "TEXT", "LWPOLYLINE"], f"entidades: {tipos}")
    circ = {k: v for k, v in est["ents"][2] if k in (10, 40)}
    ok(abs(circ[40] - 0.1) < 1e-12 and abs(circ[10][0] - 0.75) < 1e-9, f"círculo c = {circ[10]}, r = {circ[40]}")
    pl = [v for k, v in est["ents"][6] if k == 10]
    ok(len(pl) == 3 and abs(pl[1][0] - 1.2) < 1e-9 and abs(pl[2][1] - 0.2) < 1e-9, f"polilínea polar @d<ang: {pl}")
    # mover la polilínea polar y deshacer (U): vuelve donde estaba
    teclear("M"); px, py = a_pagina(1.2, 0.1); pg.mouse.click(px, py); pg.keyboard.press("Enter")
    teclear("1,0"); teclear("@0,1")
    est2 = frame().evaluate("hkCad.estado()")
    pl2 = [v for k, v in est2["ents"][6] if k == 10]
    ok(abs(pl2[0][1] - 1.0) < 1e-9, f"MOVER @0,1: {pl2[0]}")
    png(5, "todas_las_herramientas")
    teclear("U")
    est3 = frame().evaluate("hkCad.estado()")
    ok(est3["ents"] == est["ents"], "U deshace el MOVER")
    teclear("E"); ex_, ey_ = a_pagina(1.1, 0.0); pg.mouse.click(ex_, ey_); pg.keyboard.press("Enter")
    ok(len(frame().evaluate("hkCad.estado()")["ents"]) == 6, "BORRAR la polilínea polar")
    antes = frame().evaluate("hkCad.estado()")["ents"]

    print("6. Guardar en la hoja")
    fr().locator(".hkcad-guardar").click()
    esperar_calculo()
    ed = pg.evaluate("document.getElementById('code').value")
    open(os.path.join(OUT, "hoja_guardada.lisp"), "w", encoding="utf-8").write(ed)   # para el juez de AutoCAD
    blk = ed[ed.index("#dibujar(r"):]
    ok("(entmake '((0 . \"LWPOLYLINE\")" in blk and "(entmake '((0 . \"DIMENSION\")" in blk and "\n#fin" in blk, "el bloque entró en el editor con #fin")
    ok(blk.count("(entmake '((0 . ") == 6, f"6 entmake de entidades en la hoja ({blk.count('(entmake')} con capas)")
    s = salida().replace(" ", " ")
    print("   ", re.sub(r"\s+", " ", s[-260:]))
    ok(re.search(r"A\s*r\s*=\s*0\.15\b", s) is not None, "A = 0.15 leído del dibujo")
    ok(re.search(r"I\s*r\s*=\s*0\.003125\b", s) is not None, "I = b·h³/12 = 0.003125 leído del dibujo")
    ok(re.search(r"n\s*e\s*=\s*6\b", s) is not None, "n_e = 6 entidades")
    ok(not pg.evaluate("document.body.classList.contains('solo')"), "al guardar vuelve el editor")
    png(6, "guardado_y_calculado")

    print("7. reabrir: ida y vuelta")
    fr().locator(".hk-cad-btn").click(); pg.wait_for_timeout(400)
    despues = frame().evaluate("hkCad.estado()")["ents"]
    def igual(a, b):   # la hoja guarda 9 decimales (como el volcado del motor): se compara a 1e-9
        if isinstance(a, list) and isinstance(b, list): return len(a) == len(b) and all(igual(x, y) for x, y in zip(a, b))
        if isinstance(a, (int, float)) and isinstance(b, (int, float)): return abs(a - b) <= 1e-9
        return a == b
    ok(igual(despues, antes), f"entidades escritas = entidades leídas ({len(antes)} entidades, tolerancia 1e-9)")
    if not igual(despues, antes):
        for a_, d_ in zip(antes, despues):
            if a_ != d_: print("     antes  ", a_, "\n     después", d_)
    png(7, "reabierta")
    frame().evaluate("hkCad.cerrar()"); pg.wait_for_timeout(200)

    print("8. ejemplo 81: guardar sin cambios no cambia la hoja")
    ej = next(o for o in pg.evaluate("[...document.getElementById('sel-ejemplos').options].map(o => o.value)") if o.startswith("81 "))
    pg.select_option("#sel-ejemplos", ej)
    esperar_calculo(); pg.wait_for_timeout(500)
    png(8, "ejemplo81")
    t0 = pg.evaluate("document.getElementById('code').value")
    fr().locator(".hk-cad-btn").click(); pg.wait_for_timeout(500)
    png(9, "ejemplo81_ventana")
    fr().locator(".hkcad-guardar").click(); esperar_calculo()
    t1 = pg.evaluate("document.getElementById('code').value")
    ok(t0 == t1, "hoja idéntica tras abrir y guardar")
    if t0 != t1:
        import difflib; print("\n".join(list(difflib.unified_diff(t0.split("\n"), t1.split("\n"), lineterm=""))[:30]))
    s = salida()
    if not re.search(r"e\s*I\s*=\s*0", s): print("   ", repr(s[-300:]))
    ok(re.search(r"e\s*I\s*=\s*0(?![\d.])", s) is not None, "ejemplo 81: e_I = 0 (fórmula de la T = polígono dibujado)")
    ok(not errores, f"sin errores JS: {errores}")
    b.close()

print("\n" + ("TODO BIEN" if not fallos else f"{len(fallos)} FALLOS: {fallos}"))
sys.exit(1 if fallos else 0)
