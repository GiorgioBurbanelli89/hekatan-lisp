#!/usr/bin/env python3
"""Órdenes de EDICIÓN de la ventana de dibujo (#dibujar, LispCad.js), con la semántica de AutoCAD,
con ratón y línea de órdenes REALES (Playwright) y la geometría comprobada con números.

Antes:  cd hekatan-lisp/web && python serve.py 8765   (sobre la web publicada: dotnet publish -c Release)
Uso:    python tests/dibujar/test_ordenes_cad.py [carpeta_png] [--local]
        --local: sin la web, una página suelta que carga LispCad.js (para iterar rápido)

Órdenes: DESFASE (O), RECORTAR (TR), ALARGAR (EX), EMPALME (F), CHAFLÁN (CHA), COPIAR (CO), GIRAR (RO),
ESCALA (SC), SIMETRÍA (MI), cotas ANGULAR (DAN), RADIO (DRA) y DIÁMETRO (DDI), enganches CUADRANTE y
TANGENTE, rastreo POLAR, editar texto y cota en su sitio (doble clic / ED). Luego Guardar → la hoja
recalcula y lee lo dibujado; reabrir = mismas entidades. La hoja guardada queda para el juez de AutoCAD.
"""
import math, os, re, sys, json, tempfile
from playwright.sync_api import sync_playwright
sys.stdout.reconfigure(encoding="utf-8")

AQUI = os.path.dirname(os.path.abspath(__file__))
RAIZ = os.path.normpath(os.path.join(AQUI, "..", ".."))
URL = "http://localhost:8765/"
LOCAL = "--local" in sys.argv
args = [a for a in sys.argv[1:] if not a.startswith("--")]
OUT = args[0] if args else os.path.join(os.environ.get("TEMP", "."), "hk_ordenes_cad")
os.makedirs(OUT, exist_ok=True)

HOJA = """# Órdenes de edición de la ventana de dibujo
#dibujar(d, ud = m, cuadricula = 0.05)
#autolisp("Lo dibujado, leído", exporta = n_e A_o)
(setq n_e (if (ssget "_X") (sslength (ssget "_X")) 0))
(setq ss (ssget "_X" '((0 . "LWPOLYLINE"))) A_o 0.0 i 0)
(if ss (repeat (sslength ss) (setq A_o (max A_o (area (ssname ss i))) i (1+ i))))
#fin
"""

fallos = []
def ok(cond, msg):
    print(("  ✓ " if cond else "  ✗ ") + msg)
    if not cond: fallos.append(msg)
def cerca(a, b, tol=1e-9):
    if isinstance(a, (list, tuple)):   # un punto DXF trae z: se compara lo que trae el esperado
        return len(a) >= len(b) and all(cerca(x, y, tol) for x, y in zip(a, b))
    return abs(a - b) <= tol


def ents_de(est):
    """pares DXF → lista de dicts {tipo, codigo: valor (el primero), 10s: [puntos]}"""
    out = []
    for P in est["ents"]:
        d = {"t": P[0][1], "10s": [], "42s": []}
        for k, v in P:
            if k == 10: d["10s"].append(v[:2])
            if k == 42: d["42s"].append(v)
            if k not in d: d[k] = v
        out.append(d)
    return out


def area_pares(P):
    pts, bul = [], []
    for k, v in P:
        if k == 10: pts.append(v[:2]); bul.append(0.0)
        elif k == 42 and bul: bul[-1] = v
    cerr = any(k == 70 and (v & 1) for k, v in P)
    n = len(pts); A = 0.0
    for i in range(n if cerr else n - 1):
        p, q = pts[i], pts[(i + 1) % n]
        A += (p[0] * q[1] - q[0] * p[1]) / 2
        b = bul[i]
        if b:
            th = 4 * math.atan(b); c = math.dist(p, q); r = c / (2 * math.sin(abs(th) / 2))
            A += math.copysign(r * r / 2 * (abs(th) - math.sin(abs(th))), th)
    return abs(A)


with sync_playwright() as pw:
    b = pw.chromium.launch()
    pg = b.new_page(viewport={"width": 1500, "height": 950})
    errores = []
    pg.on("pageerror", lambda e: errores.append(str(e)))

    if LOCAL:
        js = open(os.path.join(RAIZ, "LispCad.js"), encoding="utf-8").read()
        html = ('<!doctype html><html><head><meta charset="utf-8"></head><body style="--bg:#fff;--fg:#222">'
                '<script type="application/json" id="x-cad">{"nombre":"d","ud":"m","rejilla":0.05,"ents":[],"capas":[{"n":"0","c":7}],"pal":{}}</script>'
                '<script>' + js + '</script><script>hkCadAbrir("x")</script></body></html>')
        f = os.path.join(tempfile.mkdtemp(prefix="hkcad_"), "h.html"); open(f, "w", encoding="utf-8").write(html)
        pg.goto("file:///" + f.replace("\\", "/"))
        frame = lambda: pg.main_frame
        caja_ifr = lambda: {"x": 0, "y": 0}
    else:
        pg.goto(URL)
        pg.wait_for_function("!document.getElementById('carga')", timeout=120000)
        pg.evaluate("document.getElementById('intro')?.classList.add('oculto')")
        frame = lambda: pg.frames[1]
        caja_ifr = lambda: pg.locator("#render").bounding_box()

    def esperar_calculo():
        pg.wait_for_timeout(400)
        pg.wait_for_function("!document.getElementById('hk-calc') || document.getElementById('hk-calc').style.display==='none'", timeout=120000)
        pg.wait_for_timeout(300)
    def a_pagina(x, y):
        bx = caja_ifr(); q = frame().evaluate(f"hkCad.pantalla({x},{y})")
        return bx["x"] + q[0], bx["y"] + q[1]
    def lienzo():             # el foco en el lienzo: las teclas van a la línea de órdenes (como AutoCAD)
        frame().evaluate("document.querySelector('.hkcad canvas').focus()")
    def teclear(*ts):
        for t in ts:
            pg.keyboard.type(t); pg.keyboard.press("Enter"); pg.wait_for_timeout(40)
    def intro(): pg.keyboard.press("Enter"); pg.wait_for_timeout(40)
    def ents(): return ents_de(frame().evaluate("hkCad.estado()"))
    def pares(): return frame().evaluate("hkCad.estado()")["ents"]
    def png(n, nombre):
        f = os.path.join(OUT, f"{n:02d}_{nombre}.png"); pg.screenshot(path=f); print("   PNG", f)
    def ver(x0, y0, x1, y1): frame().evaluate(f"hkCad.ver({x0},{y0},{x1},{y1})")

    if not LOCAL:
        pg.evaluate("t => { const e = document.getElementById('code'); e.value = t; e.dispatchEvent(new Event('input')); }", HOJA)
        esperar_calculo()
        pg.frame_locator("#render").locator(".hk-cad-btn").click(); pg.wait_for_timeout(500)
    ok(frame().evaluate("!!document.querySelector('.hkcad')"), "ventana abierta")
    lienzo()

    print("1. DESFASE (O) de un rectángulo 0.3 × 0.5: fuera 0.1 → 0.5 × 0.7; dentro 0.1 → 0.1 × 0.3")
    teclear("REC", "0,0", "@0.3,0.5")
    teclear("O", "0.1", "0.15,0", "0.15,-0.2", "0.15,0", "0.15,0.25"); intro()
    P = pares()
    ok(len(P) == 3, f"3 polilíneas ({len(P)})")
    if len(P) == 3:
        ok(cerca(area_pares(P[1]), 0.35), f"desfase fuera: área {area_pares(P[1]):.12f} = 0.5·0.7 = 0.35")
        ok(cerca(area_pares(P[2]), 0.03), f"desfase dentro: área {area_pares(P[2]):.12f} = 0.1·0.3 = 0.03")
    frame().evaluate("hkCad.orden('Z')"); intro()
    png(1, "desfase")

    print("2. RECORTAR (TR): línea cortada por otra; círculo cortado por una línea")
    teclear("L", "0,1", "1,1"); intro(); teclear("L", "0.5,0.8", "0.5,1.2"); intro()
    teclear("C", "2,0", "0.5"); teclear("L", "1.4,0", "2.6,0"); intro()
    teclear("TR"); intro(); teclear("0.8,1", "2,0.5"); intro()
    E = ents()
    h = [e for e in E if e["t"] == "LINE" and cerca(e[10][1], 1) and cerca(e[11][1], 1)]
    ok(len(h) == 1 and cerca(sorted([h[0][10][0], h[0][11][0]]), [0, 0.5]), f"línea recortada a 0 → 0.5: {h and (h[0][10], h[0][11])}")
    arc = [e for e in E if e["t"] == "ARC"]
    ok(len(arc) == 1 and cerca(arc[0][50], math.pi) and cerca(arc[0][51], 0), f"círculo → arco inferior π → 0: {arc and (arc[0][50], arc[0][51])}")
    ver(-0.2, -0.6, 2.8, 1.4); png(2, "recortar")

    print("3. ALARGAR (EX): la línea llega hasta el borde")
    teclear("L", "0,2", "0.3,2"); intro(); teclear("L", "1,1.5", "1,2.5"); intro()
    teclear("EX"); intro(); teclear("0.25,2"); intro()
    e = [e for e in ents() if e["t"] == "LINE" and cerca(e[10], [0, 2])]
    ok(e and cerca(e[0][11], [1, 2]), f"línea alargada hasta x = 1: {e and e[0][11]}")
    ver(-0.2, 1.3, 1.4, 2.7); png(3, "alargar")

    print("4. EMPALME (F) r = 0.1: dos líneas en L y la esquina de un rectángulo (polilínea)")
    teclear("L", "3,0", "4,0"); intro(); teclear("L", "3,0", "3,1"); intro()
    teclear("F", "R", "0.1", "3.5,0", "3,0.5")
    E = ents(); arc = [e for e in E if e["t"] == "ARC" and cerca(e[40], 0.1)]
    ok(len(arc) == 1 and cerca(arc[0][10][:2], [3.1, 0.1], 1e-12), f"arco de empalme: centro {arc and arc[0][10]}, r = 0.1")
    L1 = [e for e in E if e["t"] == "LINE" and (cerca(e[10], [4, 0]) or cerca(e[11], [4, 0]))]
    L2 = [e for e in E if e["t"] == "LINE" and (cerca(e[10], [3, 1]) or cerca(e[11], [3, 1]))]
    ok(L1 and cerca(L1[0][11], [3.1, 0], 1e-12), f"línea 1 termina en el punto de tangencia (3.1, 0): {L1 and L1[0][11]}")
    ok(L2 and cerca(L2[0][11], [3, 0.1], 1e-12), f"línea 2 termina en el punto de tangencia (3, 0.1): {L2 and L2[0][11]}")
    if arc:
        c = arc[0][10]; a1, a2 = arc[0][50], arc[0][51]
        ext = [[c[0] + 0.1 * math.cos(a1), c[1] + 0.1 * math.sin(a1)], [c[0] + 0.1 * math.cos(a2), c[1] + 0.1 * math.sin(a2)]]
        ok(all(any(cerca(x, t, 1e-12) for x in ext) for t in ([3.1, 0], [3, 0.1])), f"los extremos del arco son los de las líneas: {ext}")
        ok(cerca(abs(c[1] - 0), 0.1) and cerca(abs(c[0] - 3), 0.1), "tangente: distancia del centro a cada línea = r")
    teclear("REC", "5,0", "@1,1"); teclear("F", "R", "0.2", "5.5,0", "6,0.5")
    P = [p for p in pares() if p[0][1] == "LWPOLYLINE"][-1]
    Aesp = 1 - 0.2 ** 2 * (1 - math.pi / 4)
    ok(cerca(area_pares(P), Aesp, 1e-12), f"rectángulo 1×1 con una esquina r = 0.2: área {area_pares(P):.12f} = 1 − r²(1 − π/4) = {Aesp:.12f}")
    ver(2.8, -0.2, 6.3, 1.2); png(4, "empalme")

    print("5. CHAFLÁN (CHA) 0.2 y 0.3")
    teclear("L", "7,0", "8,0"); intro(); teclear("L", "7,0", "7,1"); intro()
    teclear("CHA", "D", "0.2", "0.3", "7.5,0", "7,0.5")
    E = ents()
    ok(any(e["t"] == "LINE" and cerca(e[10], [8, 0]) and cerca(e[11], [7.2, 0]) for e in E), "línea 1 → (7.2, 0)")
    ok(any(e["t"] == "LINE" and cerca(e[10], [7, 1]) and cerca(e[11], [7, 0.3]) for e in E), "línea 2 → (7, 0.3)")
    ok(any(e["t"] == "LINE" and cerca(e[10], [7.2, 0]) and cerca(e[11], [7, 0.3]) for e in E), "chaflán (7.2, 0) → (7, 0.3)")
    ver(6.8, -0.2, 8.2, 1.2); png(5, "chaflan")

    print("6. COPIAR (CO) con el RATÓN: clic en el objeto, Intro, base, dos copias")
    n0 = len(ents())
    teclear("L", "0,4", "1,4"); intro()
    ver(-0.5, 3.5, 1.5, 5.5); teclear("CO"); x, y = a_pagina(0.5, 4); pg.mouse.click(x, y); pg.wait_for_timeout(60); intro(); lienzo()
    teclear("0,4", "@0,0.5", "@0,0.5"); intro()
    E = ents()
    cop = [e for e in E if e["t"] == "LINE" and cerca(e[10][0], 0) and cerca(e[11][0], 1) and e[10][1] >= 4 - 1e-9 and e[10][1] <= 5 + 1e-9]
    ys = sorted(round(e[10][1], 9) for e in cop)
    ok(ys == [4, 4.5, 5], f"original + 2 copias a y = {ys}")
    png(6, "copiar")

    print("7. GIRAR (RO) 90° · ESCALA (SC) ×2 · SIMETRÍA (MI)")
    teclear("L", "0,6", "1,6"); intro(); teclear("RO", "L"); intro(); teclear("0,6", "90")
    e = ents()[-1]; ok(cerca(e[10], [0, 6]) and cerca(e[11], [0, 7], 1e-12), f"girada 90°: {e[10]} → {e[11]}")
    teclear("C", "2,6.5", "0.25"); teclear("SC", "L"); intro(); teclear("2,6.5", "2")
    e = ents()[-1]; ok(e["t"] == "CIRCLE" and cerca(e[40], 0.5), f"escala ×2: r = {e.get(40)}")
    teclear("L", "3,6", "4,7"); intro(); teclear("MI", "L"); intro(); teclear("4.5,5", "4.5,8"); intro()
    e = ents()[-1]; ok(e["t"] == "LINE" and cerca(e[10], [6, 6]) and cerca(e[11], [5, 7]), f"simetría en x = 4.5: {e[10]} → {e[11]}")
    ok(ents()[-2]["t"] == "LINE" and cerca(ents()[-2][10], [3, 6]), "el original se queda (Intro = No borrar)")
    teclear("A", "C", "7,6", "7.5,6", "7,6.5"); teclear("MI", "L"); intro(); teclear("8,5", "8,8"); intro()
    e = ents()[-1]; ok(e["t"] == "ARC" and cerca(e[10][:2], [9, 6]) and cerca(e[50], math.pi / 2) and cerca(e[51], math.pi), f"arco reflejado: c = {e[10]}, {e.get(50)} → {e.get(51)}")
    ver(-0.5, 5, 9.5, 7.5); png(7, "girar_escala_simetria")

    print("8. Cotas ANGULAR (DAN), RADIO (DRA), DIÁMETRO (DDI)")
    teclear("DAN"); intro(); teclear("0,10", "1,10", "0,11", "0.5,10.5")
    e = ents()[-1]; ok(e["t"] == "DIMENSION" and e[70] & 7 == 5 and cerca(e[15], [0, 10, 0]), f"angular de 3 puntos (70 = {e.get(70)}), vértice {e.get(15)}")
    teclear("L", "2,10", "3,10"); intro(); teclear("L", "2,10", "2.5,10.8660254038"); intro()
    teclear("DAN", "2.7,10", "2.25,10.4330127019", "2.6,10.3")
    ang60 = frame().evaluate("hkCad.medida(hkCad.estado().ents.length-1)")
    ok(ang60 is not None and cerca(ang60, 60, 1e-8), f"dos líneas a 60°: la cota mide {ang60}")
    teclear("C", "4,10", "0.5"); teclear("DRA", "4.5,10", "5,10.2")
    e = ents()[-1]; r_ = frame().evaluate("hkCad.medida(hkCad.estado().ents.length-1)")
    ok(e[70] & 7 == 4 and cerca(r_, 0.5), f"radio (70 = {e.get(70)}): mide {r_}")
    teclear("DDI", "3.5,10", "3,10.5")
    e = ents()[-1]; d_ = frame().evaluate("hkCad.medida(hkCad.estado().ents.length-1)")
    ok(e[70] & 7 == 3 and cerca(d_, 1.0), f"diámetro (70 = {e.get(70)}): mide {d_}")
    ver(-0.5, 9.3, 5.5, 11.3); png(8, "cotas")

    print("9. Enganches CUADRANTE y TANGENTE (ratón)")
    teclear("C", "6,10", "0.5"); ver(5, 9.5, 7, 12.2)
    teclear("L"); x, y = a_pagina(6.01, 10.49); pg.mouse.move(x, y); pg.wait_for_timeout(120)
    modo = frame().evaluate("hkCad.enganche()")
    ok(modo == "cuad", f"el enganche junto a (6, 10.5) es Cuadrante: {modo}")
    png(9, "osnap_cuadrante")
    pg.mouse.click(x, y); lienzo(); teclear("@0,1"); intro()
    e = ents()[-1]; ok(cerca(e[10], [6, 10.5]), f"la línea empieza en el cuadrante (6, 10.5): {e[10]}")
    teclear("L", "6,12")
    t = math.pi / 2 + math.acos(0.25); tx, ty = 6 + 0.5 * math.cos(t), 10 + 0.5 * math.sin(t)
    x, y = a_pagina(tx + 0.004, ty - 0.003); pg.mouse.move(x, y); pg.wait_for_timeout(120)
    modo = frame().evaluate("hkCad.enganche()")
    ok(modo == "tan", f"el enganche junto al punto de tangencia es Tangente: {modo}")
    png(10, "osnap_tangente")
    pg.mouse.click(x, y); intro()
    e = ents()[-1]
    p, q = e[10], e[11]
    dcl = abs((q[0] - p[0]) * (p[1] - 10) - (q[1] - p[1]) * (p[0] - 6)) / math.dist(p[:2], q[:2])
    ok(cerca(dcl, 0.5, 1e-9), f"la recta es tangente: distancia del centro = {dcl:.12f} = r")

    print("10. Rastreo POLAR (F10) a 45°: el cursor se pega al rayo y la distancia tecleada va por él")
    lienzo(); teclear("POLAR", "45")
    ver(-0.5, 13.5, 1.5, 15.5); teclear("L", "0,14"); x, y = a_pagina(0.5, 14.49); pg.mouse.move(x, y); pg.wait_for_timeout(120)
    pol = frame().evaluate("hkCad.polar()")
    ok(pol is not None and cerca(pol, 45, 1e-9), f"rastreo polar engancha el rayo de 45°: {pol}")
    png(11, "polar")
    lienzo(); teclear("1"); intro()
    e = ents()[-1]; ok(cerca(e[11], [math.sqrt(0.5), 14 + math.sqrt(0.5)], 1e-9), f"distancia 1 por el rayo de 45°: {e[11]}")
    pg.keyboard.press("F10"); pg.wait_for_timeout(40)
    ok(not frame().evaluate("hkCad.estadoPolar()"), "F10 lo apaga")

    print("11. Editar texto (doble clic, en su sitio) y cota (ED)")
    lienzo(); teclear("T", "0,16", "0.2", "0"); pg.keyboard.type("Hola"); intro()
    ver(-0.5, 15.5, 1.5, 16.8); x, y = a_pagina(0.1, 16.08); pg.mouse.dblclick(x, y); pg.wait_for_timeout(150)
    ok(frame().evaluate("!!document.querySelector('.hkcad-ensitio')"), "doble clic: el cuadro de edición aparece encima del texto")
    png(12, "editar_en_sitio")
    pg.keyboard.press("Control+A"); pg.keyboard.type("Sección A-A"); pg.keyboard.press("Enter"); pg.wait_for_timeout(80)
    e = [e for e in ents() if e["t"] == "TEXT"][-1]; ok(e[1] == "Sección A-A", f"texto editado: «{e[1]}»")
    ok(not frame().evaluate("!!document.querySelector('.hkcad-ensitio')"), "el cuadro se va al aceptar")
    lienzo(); teclear("ED", "4.245145,10.049029"); pg.keyboard.press("Control+A"); pg.keyboard.type("<> m"); pg.keyboard.press("Enter"); pg.wait_for_timeout(80)
    e = [e for e in ents() if e["t"] == "DIMENSION" and e[70] & 7 == 4][-1]; ok(e[1] == "<> m", f"texto de la cota de radio: «{e[1]}»")
    frame().evaluate("hkCad.orden('Z')"); intro()
    png(13, "todo")
    ok(not errores, f"sin errores JS: {errores}")

    if not LOCAL:
        print("12. Guardar en la hoja → recalcula; reabrir = mismas entidades")
        antes = frame().evaluate("hkCad.estado()")["ents"]
        pg.frame_locator("#render").locator(".hkcad-guardar").click(); esperar_calculo()
        ed = pg.evaluate("document.getElementById('code').value")
        open(os.path.join(OUT, "hoja_ordenes.lisp"), "w", encoding="utf-8").write(ed)
        blk = ed[ed.index("#dibujar(d"):]
        ok(blk.count("(entmake '((0 . ") == len(antes), f"{len(antes)} entmake en la hoja")
        s = frame().evaluate("document.body.innerText")
        ok(re.search(r"n\s*e\s*=\s*" + str(len(antes)) + r"\b", s) is not None, f"el motor lee n_e = {len(antes)}")
        png(14, "guardado")
        pg.frame_locator("#render").locator(".hk-cad-btn").click(); pg.wait_for_timeout(400)
        despues = frame().evaluate("hkCad.estado()")["ents"]
        def igual(a, b_):
            if isinstance(a, list) and isinstance(b_, list): return len(a) == len(b_) and all(igual(x, y) for x, y in zip(a, b_))
            if isinstance(a, (int, float)) and isinstance(b_, (int, float)): return abs(a - b_) <= 1e-9
            return a == b_
        ok(igual(despues, antes), f"reabrir: las {len(antes)} entidades vuelven iguales (1e-9)")
        if not igual(despues, antes):
            for a_, d_ in zip(antes, despues):
                if not igual(a_, d_): print("     antes  ", a_, "\n     después", d_)
        png(15, "reabierta")
        frame().evaluate("hkCad.cerrar()")
        ok(not errores, f"sin errores JS: {errores}")
    b.close()

print("\n" + ("TODO BIEN" if not fallos else f"{len(fallos)} FALLOS: {fallos}"))
sys.exit(1 if fallos else 0)
