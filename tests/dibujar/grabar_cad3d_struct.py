#!/usr/bin/env python3
"""GIF con el CURSOR REAL: la ventana de dibujo de Hekatan LISP en 3D (Frente, Lateral, Iso) y el botón 🏗 Struct,
que abre el dibujo como modelo en Hekatan Struct (navegador).

Mueve el ratón y el teclado DE VERDAD (grabar_gui.py de hekatan-school: pantalla y cursor por separado).

    python tests/dibujar/grabar_cad3d_struct.py <carpeta_salida>
"""
import json, os, re, subprocess, sys, tempfile, time
sys.stdout.reconfigure(encoding="utf-8")
RAIZ = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
sys.path.insert(0, os.path.join(RAIZ, "..", "hekatan-school"))
from grabar_gui import Grabadora, mover, clic, componer          # noqa: E402  (declara DPI antes que pywinauto)
from pywinauto import Application                               # noqa: E402
from pywinauto.keyboard import send_keys                        # noqa: E402
from PIL import Image                                           # noqa: E402

EXE = os.path.join(RAIZ, "bin", "Release", "net8.0-windows", "HekatanLisp.exe")
OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(tempfile.gettempdir(), "hk_gif_cad3d")
os.makedirs(OUT, exist_ok=True)
CTL = tempfile.mkdtemp(prefix="hlisp_ctl_gif_")
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


HOJA = open(os.path.join(RAIZ, "ejemplos", "84 Portico con losa dibujado en 3D (ventana de dibujo como AutoCAD 3D).lisp"), encoding="utf-8").read()
proc = subprocess.Popen([EXE, "--ctl", CTL])
for _ in range(100):
    if os.path.exists(os.path.join(CTL, "ready.txt")): break
    time.sleep(0.2)
time.sleep(2)
w32 = Application(backend="win32").connect(process=proc.pid)
win = w32.top_window(); win.maximize(); time.sleep(1); win.set_focus()
cmd("settext", text=HOJA)
for _ in range(60):
    if re.search(r"L\s*col\s*=", cmd("getoutput")["output"]): break
    time.sleep(0.5)
time.sleep(1)


def lienzo():
    """La ventana de render de WebView2 (la mayor visible): su esquina en píxeles físicos."""
    cs = [c for c in win.descendants() if c.class_name() == "Chrome_RenderWidgetHostHWND" and c.is_visible()]
    return max(cs, key=lambda c: c.rectangle().width() * c.rectangle().height()).rectangle()


def pos(sel):
    """Centro en pantalla del elemento `sel` de la página (CSS px → píxeles físicos)."""
    js("(function(){var e=document.querySelector(%s);if(e&&!e.closest('.hkcad'))e.scrollIntoView({block:'center'});return 1})()" % json.dumps(sel))
    time.sleep(0.4)
    r = json.loads(js("(function(){var e=document.querySelector(%s);if(!e)return null;var b=e.getBoundingClientRect();"
                      "return JSON.stringify([b.left+b.width/2,b.top+b.height/2,window.devicePixelRatio])})()" % json.dumps(sel)))
    R = lienzo()
    return int(R.left + r[0] * r[2]), int(R.top + r[1] * r[2])


def pulsar(sel, dur=0.8, espera=1.2):
    x, y = pos(sel); mover(x, y, dur); time.sleep(0.25); clic(); time.sleep(espera)


g = Grabadora(os.path.join(OUT, "tomas"), fps_pantalla=8)
with g.toma("01_abrir"):
    time.sleep(0.8)
    pulsar(".hk-cad-btn", 1.0, 1.6)
with g.toma("02_vistas"):
    for v in ("FRENTE", "LATERAL", "ISOSO", "ISOSE", "ISOSO"):
        pulsar("[data-v=%s]" % v, 0.7, 1.4)
with g.toma("03_dibujar3d"):
    x, y = pos(".hkcad canvas"); mover(x, y, 0.8); time.sleep(0.3)
    for tramo in ("3P{ENTER}", "0,0,3{ENTER}", "5,4,0{ENTER}", "{ENTER}"):
        send_keys(tramo, pause=0.09); time.sleep(0.6)
    time.sleep(1.0)
with g.toma("04_struct"):
    pulsar(".hkcad-struct", 1.0, 1.0)
    time.sleep(14)                   # el navegador abre Hekatan Struct con el modelo
g.cerrar()
heks = js("window.hkCadStructUltimo ? window.hkCadStructUltimo.heks : null")
open(os.path.join(OUT, "modelo_enviado.heks"), "w", encoding="utf-8").write(heks or "")
print("heks enviado:", (heks or "").count("\nframe"), "barras,", (heks or "").count("\nshell"), "cáscaras,", (heks or "").count("\nsupport"), "apoyos")

# ---- GIF: cada toma a 8 cuadros por segundo, cursor ×1.6, 1200 px de ancho
datos = json.load(open(os.path.join(OUT, "tomas", "tomas.json"), encoding="utf-8"))
cuadros = []
for t in datos["tomas"]:
    k = 0.0
    while k < t["dur"]:
        im, _ = componer(os.path.join(OUT, "tomas"), t, k, escala_cursor=1.6)
        cuadros.append(im.resize((1200, int(im.height * 1200 / im.width)), Image.LANCZOS)); k += 0.125
pal = [c.quantize(colors=160, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE) for c in cuadros]
gif = os.path.join(OUT, "cad3d_a_struct.gif")
pal[0].save(gif, save_all=True, append_images=pal[1:], duration=125, loop=0, optimize=True)
print(gif, len(cuadros), "cuadros", round(os.path.getsize(gif) / 1e6, 2), "MB")
cmd("fuera") if False else None
