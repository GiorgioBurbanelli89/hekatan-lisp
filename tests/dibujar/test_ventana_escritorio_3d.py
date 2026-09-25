#!/usr/bin/env python3
"""La ventana de dibujo en 3D en el ESCRITORIO (WPF + WebView2), por el canal --ctl, con el ejemplo 83.

Abre el pórtico, pasa a Iso SO, dibuja una riostra nueva con 3DPOL (x,y,z tecleadas), guarda en la hoja:
el editor recibe POLYLINE + VERTEX + SEQEND, la hoja se recalcula (L_arr no cambia: la 3DPOL no es LINE;
las columnas siguen en 12 m) y reabrir da las mismas entidades.

Uso: python tests/dibujar/test_ventana_escritorio_3d.py [carpeta_png]
"""
import json, os, re, subprocess, sys, tempfile, time
sys.stdout.reconfigure(encoding="utf-8")
RAIZ = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
EXE = os.path.join(RAIZ, "bin", "Release", "net8.0-windows", "HekatanLisp.exe")
OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(tempfile.gettempdir(), "hk_dibujar_escritorio_3d")
os.makedirs(OUT, exist_ok=True)
CTL = tempfile.mkdtemp(prefix="hlisp_ctl_d3_")
_n = 0

def cmd(op, **kw):
    global _n
    _n += 1
    c, r = os.path.join(CTL, f"cmd-{_n:04d}.json"), os.path.join(CTL, f"resp-{_n:04d}.json")
    json.dump({"op": op, **kw}, open(c, "w", encoding="utf-8"))
    for _ in range(600):
        if os.path.exists(r):
            time.sleep(0.05); return json.load(open(r, encoding="utf-8"))
        time.sleep(0.1)
    raise TimeoutError(op)
def js(code): return cmd("js", code=code).get("result")
fallos = []
def ok(c, m):
    print(("  ✓ " if c else "  ✗ ") + m)
    if not c: fallos.append(m)

HOJA = open(os.path.join(RAIZ, "ejemplos", "84 Portico con losa dibujado en 3D (ventana de dibujo como AutoCAD 3D).lisp"), encoding="utf-8").read()
TECLAS = """(function(t){var cv=document.querySelector('.hkcad canvas');cv.focus();
for(const ch of t){cv.focus();var k=ch==='\\n'?'Enter':ch;document.dispatchEvent(new KeyboardEvent('keydown',{key:k,bubbles:true,cancelable:true}));}return true})(%s)"""
MOVER = """(function(x,y,z){var cv=document.querySelector('.hkcad canvas'),q=hkCad.pantalla(x,y,z);
cv.dispatchEvent(new PointerEvent('pointermove',{clientX:q[0]+3,clientY:q[1]-2,bubbles:true,pointerId:1}));return hkCad.enganche()})(%s,%s,%s)"""

proc = subprocess.Popen([EXE, "--ctl", CTL])
try:
    for _ in range(100):
        if os.path.exists(os.path.join(CTL, "ready.txt")): break
        time.sleep(0.2)
    time.sleep(2)
    print("1. la hoja 83: el motor lee el pórtico 3D")
    cmd("settext", text=HOJA)
    for _ in range(60):                      # el cálculo tarda: se espera a que salga L_col
        out = cmd("getoutput")["output"]
        if re.search(r"L\s*col\s*=", out): break
        time.sleep(0.5)
    ok(re.search(r"L\s*col\s*=\s*12(?![\d])", out) is not None, "L_col = 12 (4 columnas de 3 m, LINE con z)")
    ok(re.search(r"A\s*los\s*=\s*20(?![\d])", out) is not None, "A_los = 20 (3DCARA 5 × 4)")
    ok(re.search(r"P\s*vig\s*=\s*18(?![\d])", out) is not None, "P_vig = 18 (3DPOL cerrada)")
    cmd("capture", path=os.path.join(OUT, "d1_hoja83.png"))

    print("2. ✏ abre la ventana; Iso SO; OSNAP 3D en la esquina de la losa")
    js("document.querySelector('.hk-cad-btn').click()"); time.sleep(0.8)
    ok(js("!!document.querySelector('.hkcad')") is True, "ventana abierta")
    js("document.querySelector('[data-v=ISOSO]').click()"); time.sleep(0.3)
    c = js("JSON.stringify(hkCad.camara())"); ok(c and '"az":225' in c, f"cámara Iso SO: {c}")
    js(TECLAS % json.dumps("3P\n"))
    en = js(MOVER % (5, 4, 3)); cur = js("JSON.stringify(hkCad.cursor())")
    ok(en == "fin" and cur == "[5,4,3]", f"enganche {en} en {cur}")
    cmd("capture", path=os.path.join(OUT, "d2_ventana_iso_osnap.png"))
    js(TECLAS % json.dumps("5,4,3\n0,4,0\n\n"))
    ents = json.loads(js("JSON.stringify(hkCad.estado().ents)"))
    e = ents[-1]; v = [p[1] for p in e if p[0] == 1011]
    ok(e[0][1] == "POLYLINE" and v == [[5, 4, 3], [0, 4, 0]], f"3DPOL nueva: {v}")

    print("3. 💾 Guardar → POLYLINE + VERTEX + SEQEND en el editor; la hoja se recalcula")
    js("document.querySelector('.hkcad-guardar').click()"); time.sleep(2)
    txt = cmd("gettext")["input"]
    ok("(entmake '((0 . \"VERTEX\") (8 . \"ARRIOSTRE\") (10 0.0 4.0 0.0) (70 . 32)))" in txt, "VERTEX con z en el editor")
    ok(txt.count("(0 . \"SEQEND\")") == 2, "dos SEQEND (vigas + la nueva)")
    out = cmd("getoutput")["output"]
    ok(re.search(r"L\s*col\s*=\s*12(?![\d])", out) is not None, "recalculada: L_col = 12")
    cmd("capture", path=os.path.join(OUT, "d3_guardado_visor3d.png"))

    print("4. reabrir = mismas entidades")
    js("document.querySelector('.hk-cad-btn').click()"); time.sleep(0.8)
    ents2 = json.loads(js("JSON.stringify(hkCad.estado().ents)"))
    ok(ents2 == ents, "ida y vuelta idéntica")
    js("hkCad.cerrar()"); time.sleep(0.3)
finally:
    try: cmd("quit")
    except Exception: pass
    time.sleep(1)
    try: proc.kill()
    except Exception: pass

print("\n" + ("TODO BIEN" if not fallos else f"{len(fallos)} FALLOS: {fallos}"))
sys.exit(1 if fallos else 0)
