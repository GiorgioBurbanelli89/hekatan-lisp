#!/usr/bin/env python3
"""La ventana de dibujo de #dibujar en el ESCRITORIO (WPF + WebView2), por el canal --ctl.

Lo que se prueba aquí es el PUENTE que la web no tiene: chrome.webview.postMessage → C# →
el EDITOR (AvalonEdit) recibe el bloque → la hoja se recalcula. Dentro del WebView2 las teclas y
clics se mandan como eventos del DOM (KeyboardEvent / PointerEvent) al lienzo: no se usa el ratón
del sistema (así no se escribe en otra ventana por error). El ratón/teclado REAL se prueba en la web
(test_ventana_web.py, Playwright).

Uso: python tests/dibujar/test_ventana_escritorio.py [carpeta_png]
"""
import json, os, re, subprocess, sys, tempfile, time
sys.stdout.reconfigure(encoding="utf-8")
RAIZ = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
EXE = os.path.join(RAIZ, "bin", "Release", "net8.0-windows", "HekatanLisp.exe")
OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(tempfile.gettempdir(), "hk_dibujar_escritorio")
os.makedirs(OUT, exist_ok=True)
CTL = tempfile.mkdtemp(prefix="hlisp_ctl_dib_")
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

def js(code):
    return cmd("js", code=code).get("result")

fallos = []
def ok(c, m):
    print(("  ✓ " if c else "  ✗ ") + m)
    if not c: fallos.append(m)

HOJA = open(os.path.join(RAIZ, "tests", "dibujar", "hoja_prueba.lisp"), encoding="utf-8").read()
TECLAS = """(function(t){var cv=document.querySelector('.hkcad canvas');cv.focus();
for(const ch of t){cv.focus();var k=ch==='\\n'?'Enter':ch;document.dispatchEvent(new KeyboardEvent('keydown',{key:k,bubbles:true,cancelable:true}));}return true})(%s)"""
CLIC = """(function(x,y){var cv=document.querySelector('.hkcad canvas'),q=hkCad.pantalla(x,y);
var o={clientX:q[0],clientY:q[1],button:0,bubbles:true,pointerId:1};cv.dispatchEvent(new PointerEvent('pointermove',o));cv.dispatchEvent(new PointerEvent('pointerdown',o));return q})(%s,%s)"""

proc = subprocess.Popen([EXE, "--ctl", CTL])
try:
    for _ in range(100):
        if os.path.exists(os.path.join(CTL, "ready.txt")): break
        time.sleep(0.2)
    time.sleep(2)
    print("1. hoja con #dibujar vacío")
    cmd("settext", text=HOJA)
    out = cmd("getoutput")["output"]
    ok(re.search(r"n\s*e\s*=\s*0", out) is not None, "sin dibujo: n_e = 0")
    cmd("capture", path=os.path.join(OUT, "e1_hoja_vacia.png"))

    print("2. ✏ abre la ventana (y el resultado ocupa todo el ancho)")
    js("document.querySelector('.hk-cad-btn').click()"); time.sleep(0.8)
    ok(js("!!document.querySelector('.hkcad')") is True, "ventana abierta")
    cmd("capture", path=os.path.join(OUT, "e2_ventana.png"))

    print("3. REC por órdenes; LINEA con un clic junto al vértice (OSNAP) y otro a la rejilla")
    js(TECLAS % json.dumps("REC\n0,0\n@0.3,0.5\n"))
    js(TECLAS % json.dumps("L\n")); js(CLIC % (0.3 + 0.004, 0.5 + 0.003)); js(CLIC % (0.6, 0.2)); js(TECLAS % json.dumps("\n"))
    est = js("JSON.stringify(hkCad.estado().ents)")
    ents = json.loads(est)
    ok([e[0][1] for e in ents] == ["LWPOLYLINE", "LINE"], f"entidades: {[e[0][1] for e in ents]}")
    ln = {k: v for k, v in ents[1] if k in (10, 11)}
    ok(ln[10][:2] == [0.3, 0.5] and ln[11][:2] == [0.6, 0.2], f"LINEA {ln[10]} → {ln[11]} (OSNAP y rejilla)")
    cmd("capture", path=os.path.join(OUT, "e3_dibujado.png"))

    print("4. 💾 Guardar en la hoja → el EDITOR recibe el bloque y la hoja se recalcula")
    js("document.querySelector('.hkcad-guardar').click()"); time.sleep(1.5)
    txt = cmd("gettext")["input"]
    ok("(entmake '((0 . \"LWPOLYLINE\")" in txt and "(entmake '((0 . \"LINE\")" in txt, "el editor tiene las listas DXF")
    ok(re.search(r"#dibujar\(r[^\n]*\n(?:[;(][^\n]*\n)+#fin", txt) is not None, "bloque #dibujar … #fin bien cerrado")
    out = cmd("getoutput")["output"]
    ok(re.search(r"A\s*r\s*=\s*0\.15(?![\d])", out) is not None, "A = 0.15 leído del dibujo")
    ok(re.search(r"I\s*r\s*=\s*0\.003125(?![\d])", out) is not None, "I = b·h³/12 = 0.003125")
    ok(re.search(r"n\s*e\s*=\s*2(?![\d])", out) is not None, "n_e = 2")
    lay = cmd("layout")
    print("   layout:", str(lay)[:200])
    cmd("capture", path=os.path.join(OUT, "e4_guardado.png"))

    print("5. reabrir: lo leído de la hoja = lo dibujado")
    js("document.querySelector('.hk-cad-btn').click()"); time.sleep(0.8)
    ents2 = json.loads(js("JSON.stringify(hkCad.estado().ents)"))
    ok(ents2 == ents, "ida y vuelta idéntica")
    js("hkCad.cerrar()"); time.sleep(0.3)
    cmd("capture", path=os.path.join(OUT, "e5_cerrada.png"))
finally:
    try: cmd("quit")
    except Exception: pass
    time.sleep(1)
    try: proc.kill()
    except Exception: pass

print("\n" + ("TODO BIEN" if not fallos else f"{len(fallos)} FALLOS: {fallos}"))
sys.exit(1 if fallos else 0)
