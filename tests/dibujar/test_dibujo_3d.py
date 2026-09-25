#!/usr/bin/env python3
"""La ventana de dibujo (#dibujar, LispCad.js) en 3D, con la semántica de AutoCAD, con ratón y línea de órdenes
REALES (Playwright) y los números comprobados (coordenadas con z a 1e-9).

Antes (sin --local):  cd web && python serve.py 8765   (sobre la web publicada: dotnet publish -c Release)
Uso:    python tests/dibujar/test_dibujo_3d.py [carpeta_png] [--local]
        --local: sin la web, una página suelta que carga LispCad.js

Qué se prueba: coordenadas x,y,z y @dx,dy,dz; LINEA con z; 3DPOL (POLYLINE 70 = 8, VERTEX 70 = 32); 3DCARA
(3DFACE, cara de 3 lados, caras encadenadas, arista invisible); SCP (XZ, origen, 3 puntos, Universal); el cursor
cae en el plano del SCP (rayo ∩ plano); distancia directa en 3D; vistas Planta/Frente/Lateral/Iso y órbita con
Mayús + botón central; OSNAP en 3D (final, medio, intersección e intersección ficticia) con imán; guardar =
(entmake …) con z. Sin --local: Guardar en la hoja → el #autolisp lee las longitudes 3D y el área de las caras.
"""
import math, os, re, sys, tempfile
from playwright.sync_api import sync_playwright
sys.stdout.reconfigure(encoding="utf-8")

AQUI = os.path.dirname(os.path.abspath(__file__))
RAIZ = os.path.normpath(os.path.join(AQUI, "..", ".."))
URL = "http://localhost:8765/"
LOCAL = "--local" in sys.argv
args = [a for a in sys.argv[1:] if not a.startswith("--")]
OUT = args[0] if args else os.path.join(os.environ.get("TEMP", "."), "hk_dibujo_3d")
os.makedirs(OUT, exist_ok=True)

HOJA = """# La ventana de dibujo en 3D
#dibujar(d3, ud = m, cuadricula = 0.05)
#autolisp("Lo dibujado en 3D, leído", exporta = n_e L_3 A_c)
(setq n_e (if (ssget "_X") (sslength (ssget "_X")) 0) L_3 0.0 A_c 0.0 i 0)
(setq ss (ssget "_X" '((0 . "LINE"))))
(if ss (repeat (sslength ss) (setq e (entget (ssname ss i)) L_3 (+ L_3 (distance (cdr (assoc 10 e)) (cdr (assoc 11 e)))) i (1+ i))))
(defun v- (a b) (mapcar '- a b))
(defun vx (a b) (list (- (* (cadr a) (caddr b)) (* (caddr a) (cadr b))) (- (* (caddr a) (car b)) (* (car a) (caddr b))) (- (* (car a) (cadr b)) (* (cadr a) (car b)))))
(defun vl (a) (sqrt (apply '+ (mapcar '* a a))))
(setq ss (ssget "_X" '((0 . "3DFACE"))) i 0)
(if ss (repeat (sslength ss) (setq e (entget (ssname ss i)) p1 (cdr (assoc 10 e)) p2 (cdr (assoc 11 e)) p3 (cdr (assoc 12 e)) p4 (cdr (assoc 13 e))
  A_c (+ A_c (/ (vl (vx (v- p3 p1) (v- p4 p2))) 2.0)) i (1+ i))))
#fin
"""

fallos = []
def ok(cond, msg):
    print(("  ✓ " if cond else "  ✗ ") + msg)
    if not cond: fallos.append(msg)
def cerca(a, b, tol=1e-9):
    if isinstance(a, (list, tuple)):
        a = list(a) + [0.0] * (len(b) - len(a))
        return len(a) >= len(b) and all(cerca(x, y, tol) for x, y in zip(a, b))
    return abs(a - b) <= tol
def P3(p): return (list(p) + [0.0, 0.0, 0.0])[:3]


def ent(P):
    d = {"t": P[0][1], "1011": []}
    for k, v in P:
        if k == 1011: d["1011"].append(P3(v))
        elif k not in d: d[k] = v
    return d


with sync_playwright() as pw:
    b = pw.chromium.launch()
    pg = b.new_page(viewport={"width": 1500, "height": 950})
    errores = []
    pg.on("pageerror", lambda e: errores.append(str(e)))
    if LOCAL:
        js = open(os.path.join(RAIZ, "LispCad.js"), encoding="utf-8").read()
        html = ('<!doctype html><html><head><meta charset="utf-8"></head><body style="--bg:#0f1115;--fg:#e6e6e6;--mut:#8a8f98;--sep:#333">'
                '<script type="application/json" id="x-cad">{"nombre":"d3","ud":"m","rejilla":0.05,"ents":[],"capas":[{"n":"0","c":7}],"pal":{}}</script>'
                '<script>' + js + '</script><script>hkCadAbrir("x")</script></body></html>')
        f = os.path.join(tempfile.mkdtemp(prefix="hkcad3d_"), "h.html"); open(f, "w", encoding="utf-8").write(html)
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
    def a_pagina(x, y, z=0):
        bx = caja_ifr(); q = frame().evaluate(f"hkCad.pantalla({x},{y},{z})")
        return bx["x"] + q[0], bx["y"] + q[1]
    def lienzo(): frame().evaluate("document.querySelector('.hkcad canvas').focus()")
    def teclear(*ts):
        for t in ts:
            pg.keyboard.type(t); pg.keyboard.press("Enter"); pg.wait_for_timeout(40)
    def intro(): pg.keyboard.press("Enter"); pg.wait_for_timeout(40)
    def pares(): return frame().evaluate("hkCad.estado()")["ents"]
    def ents(): return [ent(P) for P in pares()]
    def png(n, nombre):
        f = os.path.join(OUT, f"{n:02d}_{nombre}.png"); pg.screenshot(path=f); print("   PNG", f)
    def ev(js): return frame().evaluate(js)

    if not LOCAL:
        pg.evaluate("t => { const e = document.getElementById('code'); e.value = t; e.dispatchEvent(new Event('input')); }", HOJA)
        esperar_calculo()
        pg.frame_locator("#render").locator(".hk-cad-btn").click(); pg.wait_for_timeout(500)
    ok(ev("!!document.querySelector('.hkcad')"), "ventana abierta")
    lienzo()

    print("1. Coordenadas x,y,z y @dx,dy,dz (LINE 10/11 con z)")
    teclear("L", "0,0,0", "1,2,3", "@1,0,-1"); intro()
    E = ents()
    ok(len(E) == 2 and E[0]["t"] == "LINE" and cerca(E[0][10], [0, 0, 0]) and cerca(E[0][11], [1, 2, 3]), f"línea 0,0,0 → 1,2,3: {E and (E[0][10], E[0][11])}")
    ok(len(E) == 2 and cerca(E[1][11], [2, 2, 2]), f"@1,0,-1 desde 1,2,3 → 2,2,2: {len(E) > 1 and E[1][11]}")
    teclear("L", "5,5", "6,5"); intro()
    ok(cerca(ents()[-1][10], [5, 5, 0]), "con dos números la z es la del SCP (0)")

    print("2. 3DPOL (3P): POLYLINE 70 = 8|1 con 3 vértices; desHacer")
    teclear("3P", "0,0,0", "1,0,0", "9,9,9", "H", "1,1,1", "C")
    e = ents()[-1]
    ok(e["t"] == "POLYLINE" and e[70] == 9 and len(e["1011"]) == 3, f"POLYLINE 70 = {e.get(70)}, {len(e['1011'])} vértices")
    ok(all(cerca(a, b_) for a, b_ in zip(e["1011"], [[0, 0, 0], [1, 0, 0], [1, 1, 1]])), f"vértices {e['1011']}")

    print("3. 3DCARA (3F): cara de 4, cara encadenada, cara de 3 lados, arista invisible")
    teclear("3F", "0,0,0", "2,0,0", "2,2,1", "0,2,1", "2,4,2", "0,4,2"); intro()
    F = [x for x in ents() if x["t"] == "3DFACE"]
    ok(len(F) == 2, f"2 caras ({len(F)})")
    if len(F) == 2:
        ok(cerca(F[0][10], [0, 0, 0]) and cerca(F[0][12], [2, 2, 1]) and cerca(F[0][13], [0, 2, 1]), f"cara 1: {F[0][10]} {F[0][11]} {F[0][12]} {F[0][13]}")
        ok(cerca(F[1][10], [2, 2, 1]) and cerca(F[1][11], [0, 2, 1]) and cerca(F[1][12], [2, 4, 2]) and cerca(F[1][13], [0, 4, 2]),
           f"cara 2 empieza en el 3.º y 4.º de la 1: {F[1][10]} {F[1][11]} {F[1][12]} {F[1][13]}")
    teclear("3F", "5,0,0", "6,0,0", "6,1,0"); intro(); intro()
    e = ents()[-1]; ok(e["t"] == "3DFACE" and cerca(e[13], e[12]), f"cara de 3 lados: 13 = 12 = {e.get(13)}")
    teclear("3F", "I", "7,0,0", "8,0,0", "8,1,0", "7,1,0"); intro()
    e = ents()[-1]; ok(e.get(70) == 1, f"«I» antes del 1.er punto: arista 1 invisible (70 = {e.get(70)})")

    print("4. SCP: XZ, origen, 3 puntos, Universal")
    teclear("SCP", "XZ"); teclear("L", "0,0", "1,1"); intro()
    e = ents()[-1]; ok(cerca(e[10], [0, 0, 0]) and cerca(e[11], [1, 0, 1]), f"en el SCP XZ, 1,1 → universal 1,0,1: {e[11]}")
    ok(ev("hkCad.scp().plano") == "XZ", "barra: Plano XZ")
    teclear("SCP", "U"); teclear("SCP", "0,0,3"); intro()
    teclear("L", "0,0", "1,0"); intro()
    e = ents()[-1]; ok(cerca(e[10], [0, 0, 3]) and cerca(e[11], [1, 0, 3]), f"SCP con origen 0,0,3: {e[10]} → {e[11]}")
    teclear("SCP", "U"); teclear("SCP", "0,0,0", "0,1,0", "-1,0,0")   # (el origen nuevo se da en el SCP actual, como AutoCAD)
    teclear("L", "1,0", "1,1"); intro()
    e = ents()[-1]; ok(cerca(e[10], [0, 1, 0]) and cerca(e[11], [-1, 1, 0]), f"SCP de 3 puntos (girado 90°): 1,0 → {e[10]}, 1,1 → {e[11]}")
    teclear("L", "0,0", "@1<0"); intro()
    e = ents()[-1]; ok(cerca(e[11], [0, 1, 0]), f"@1<0 va por el eje X del SCP: {e[11]}")
    teclear("SCP"); intro()
    ok(ev("hkCad.scp().nom") == "Universal", "SCP + Intro = Universal")

    print("5. Vistas: Iso SO (cámara 225°/35.26°), la estrella de 3 ejes; el cursor cae en el plano del SCP")
    pg.frame_locator("#render").locator("[data-v=ISOSO]").click() if not LOCAL else pg.locator("[data-v=ISOSO]").click()
    lienzo()
    c = ev("hkCad.camara()")
    ok(c and cerca(c["az"], 225) and cerca(c["el"], 35.26438968), f"cámara iso SO: {c and (c['az'], c['el'])}")
    pg.keyboard.press("F3"); pg.wait_for_timeout(40)          # refent fuera: el cursor, solo con rejilla
    x, y = a_pagina(3, 4, 0); pg.mouse.move(x, y); pg.wait_for_timeout(120)
    cur = ev("hkCad.cursor()"); ok(cur and cerca(cur, [3, 4, 0]), f"rayo ∩ plano XY (z = 0): cursor {cur}")
    png(1, "iso_estrella")
    teclear("SCP", "0,0,3"); intro()
    x, y = a_pagina(2, 1, 3); pg.mouse.move(x, y); pg.wait_for_timeout(120)
    cur = ev("hkCad.cursor()"); ok(cur and cerca(cur, [2, 1, 3]), f"SCP a z = 3: el cursor cae en z = 3: {cur}")
    teclear("SCP", "U")

    print("6. Distancia directa en 3D: desde 0,0,3 hacia el cursor en 3,4,0, «10» → 10 por esa recta")
    teclear("L", "0,0,3")
    x, y = a_pagina(3, 4, 0); pg.mouse.move(x, y); pg.wait_for_timeout(120)
    teclear("10"); intro()
    e = ents()[-1]; u = [3 / math.sqrt(34), 4 / math.sqrt(34), -3 / math.sqrt(34)]
    ok(cerca(e[11], [10 * u[0], 10 * u[1], 3 + 10 * u[2]], 1e-9), f"punto a 10: {e[11]}")
    pg.keyboard.press("F3"); pg.wait_for_timeout(40)

    print("7. OSNAP en 3D: final, medio, intersección e intersección ficticia (imán)")
    ev("hkCad.encuadre()")
    teclear("L")
    x, y = a_pagina(1, 2, 3); pg.mouse.move(x + 4, y - 3); pg.wait_for_timeout(120)
    ok(ev("hkCad.enganche()") == "fin" and cerca(ev("hkCad.cursor()"), [1, 2, 3]), f"Punto final 1,2,3: {ev('hkCad.enganche()')} {ev('hkCad.cursor()')}")
    png(2, "osnap3d_final")
    pg.keyboard.press("Escape")
    teclear("L", "10,5,0", "12,7,2"); intro(); teclear("L", "12,5,0", "10,7,2"); intro()
    teclear("L", "10,0,0", "12,2,0"); intro(); teclear("L", "10,2,1", "12,0,1"); intro()
    ev("hkCad.encuadre()")
    teclear("L")
    x, y = a_pagina(11, 6, 1); pg.mouse.move(x + 3, y + 2); pg.wait_for_timeout(120)
    ok(ev("hkCad.enganche()") == "inter" and cerca(ev("hkCad.cursor()"), [11, 6, 1]), f"intersección real 11,6,1: {ev('hkCad.enganche()')} {ev('hkCad.cursor()')}")
    png(3, "osnap3d_inter")
    pg.keyboard.press("Escape")
    ev("hkCad.vista('PLANTA')"); frame().evaluate("hkCad.ver(9, -0.5, 13, 3)"); lienzo(); teclear("L")
    x, y = a_pagina(11, 1, 0); pg.mouse.move(x + 3, y + 2); pg.wait_for_timeout(120)
    en, cu = ev("hkCad.enganche()"), ev("hkCad.cursor()")
    ok(en == "aparente" and cerca(cu, [11, 1, 0]), f"en planta se cruzan pero en z no (0 y 1): Intersección ficticia ({en}) sobre la primera, {cu}")
    png(4, "osnap_ficticia_planta")
    pg.keyboard.press("Escape"); ev("hkCad.vista('ISOSO')"); lienzo()
    teclear("L")
    x, y = a_pagina(1, 0.5, 0.5); pg.mouse.move(x + 2, y - 2); pg.wait_for_timeout(120)
    ok(ev("hkCad.enganche()") == "medio" and cerca(ev("hkCad.cursor()"), [1, 0.5, 0.5]), f"Punto medio del tramo 3D de la 3DPOL: {ev('hkCad.enganche()')} {ev('hkCad.cursor()')}")
    pg.keyboard.press("Escape")

    print("8. Órbita: Mayús + botón central arrastrando (3DORBITA); Frente y Lateral ponen su SCP")
    az0 = ev("hkCad.camara()")["az"]
    x, y = a_pagina(0, 0, 0)
    pg.keyboard.down("Shift"); pg.mouse.move(x, y); pg.mouse.down(button="middle"); pg.mouse.move(x + 60, y + 20, steps=6); pg.mouse.up(button="middle"); pg.keyboard.up("Shift")
    c = ev("hkCad.camara()"); ok(c and not cerca(c["az"], az0), f"la órbita gira la vista: az {az0} → {c and c['az']:.3f}, el {c and c['el']:.3f}")
    png(5, "orbita")
    ev("hkCad.vista('FRENTE')")
    ok(ev("hkCad.scp().plano") == "XZ", "Frente → SCP XZ (UCSORTHO)")
    png(6, "frente")
    ev("hkCad.vista('LATERAL')")
    ok(ev("hkCad.scp().plano") == "YZ", "Lateral → SCP YZ")
    ev("hkCad.vista('PLANTA')")
    ok(ev("hkCad.camara()") is None and ev("hkCad.scp().nom") == "Universal", "Planta: vuelve la vista 2D y el SCP Universal")
    png(7, "planta")

    print("9. MOVER con z, ESCALA 3D, DESHACER")
    n = len(ents())
    teclear("M", "L"); intro(); teclear("0,0,0", "@0,0,1")
    e = ents()[-1]; ok(cerca(e[10], [10, 2, 2]) and cerca(e[11], [12, 0, 2]), f"MOVER @0,0,1: {e[10]} → {e[11]}")
    teclear("SC", "L"); intro(); teclear("10,2,0", "2")
    e = ents()[-1]; ok(cerca(e[10], [10, 2, 4]) and cerca(e[11], [14, -2, 4]), f"ESCALA ×2 desde 10,2,0 (también la z): {e[10]} → {e[11]}")
    teclear("U"); teclear("U")
    e = ents()[-1]; ok(cerca(e[10], [10, 2, 1]), f"U U: vuelve a {e[10]}")
    ok(len(ents()) == n, "mismo número de entidades")

    print("10. Guardar: (entmake …) con z; 3DPOL como POLYLINE + VERTEX + SEQEND")
    cu = ev("hkCad.cuerpo()")
    ok("(entmake '((0 . \"LINE\") (8 . \"0\") (10 0.0 0.0 0.0) (11 1.0 2.0 3.0)))" in cu, "LINE con z en la lista DXF")
    ok(re.search(r"\(0 \. \"POLYLINE\"\).*\(66 \. 1\).*\(70 \. 9\)\)\) \(entmake '\(\(0 \. \"VERTEX\"\) \(8 \. \"0\"\) \(10 0\.0 0\.0 0\.0\) \(70 \. 32\)\)\)", cu) is not None, "POLYLINE (70 . 9) + VERTEX (70 . 32)")
    ok("(entmake '((0 . \"SEQEND\") (8 . \"0\")))" in cu, "SEQEND")
    ok("(0 . \"3DFACE\") (8 . \"0\") (10 0.0 0.0 0.0) (11 2.0 0.0 0.0) (12 2.0 2.0 1.0) (13 0.0 2.0 1.0)" in cu, "3DFACE 10 11 12 13 con z")
    open(os.path.join(OUT, "cuerpo_3d.lisp"), "w", encoding="utf-8").write("#dibujar(d3)\n" + cu + "\n#fin\n")
    ok(not errores, f"sin errores JS: {errores}")

    if not LOCAL:
        print("11. Guardar en la hoja → el #autolisp lee las longitudes 3D y las áreas; reabrir = mismas entidades")
        E = ents()
        L3 = sum(math.dist(P3(e[10]), P3(e[11])) for e in E if e["t"] == "LINE")
        def area(e):
            p = [P3(e[c]) for c in (10, 11, 12, 13)]
            a = [p[2][i] - p[0][i] for i in range(3)]; b_ = [p[3][i] - p[1][i] for i in range(3)]
            x = [a[1] * b_[2] - a[2] * b_[1], a[2] * b_[0] - a[0] * b_[2], a[0] * b_[1] - a[1] * b_[0]]
            return math.sqrt(sum(t * t for t in x)) / 2
        Ac = sum(area(e) for e in E if e["t"] == "3DFACE")
        antes = pares()
        pg.frame_locator("#render").locator(".hkcad-guardar").click(); esperar_calculo()
        ed = pg.evaluate("document.getElementById('code').value")
        open(os.path.join(OUT, "hoja_3d.lisp"), "w", encoding="utf-8").write(ed)
        s = frame().evaluate("document.body.innerText")
        m = re.search(r"L\s*3\s*=\s*([-\d.]+)", s); ok(m and cerca(float(m.group(1)), L3, 1e-3), f"el motor lee ΣL 3D = {m and m.group(1)} (Python {L3:.4f})")
        m = re.search(r"A\s*c\s*=\s*([-\d.]+)", s); ok(m and cerca(float(m.group(1)), Ac, 1e-3), f"el motor lee ΣA de las caras = {m and m.group(1)} (Python {Ac:.4f})")
        m = re.search(r"n\s*e\s*=\s*(\d+)", s); ok(m and int(m.group(1)) == len(antes), f"n_e = {m and m.group(1)} = {len(antes)}")
        png(8, "hoja_visor3d")
        pg.frame_locator("#render").locator(".hk-cad-btn").click(); pg.wait_for_timeout(400)
        despues = pares()
        def igual(a, b_):
            if isinstance(a, list) and isinstance(b_, list): return len(a) == len(b_) and all(igual(x, y) for x, y in zip(a, b_))
            if isinstance(a, (int, float)) and isinstance(b_, (int, float)): return abs(a - b_) <= 1e-9
            return a == b_
        ok(igual(despues, antes), f"reabrir: las {len(antes)} entidades vuelven iguales (1e-9)")
        if not igual(despues, antes):
            for a_, d_ in zip(antes, despues):
                if not igual(a_, d_): print("     antes  ", a_, "\n     después", d_)
        frame().evaluate("hkCad.cerrar()")
        ok(not errores, f"sin errores JS: {errores}")
    b.close()

print("\n" + ("TODO BIEN" if not fallos else f"{len(fallos)} FALLOS: {fallos}"))
sys.exit(1 if fallos else 0)
