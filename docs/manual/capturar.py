"""Capturas del manual de Hekatan LISP (app por --ctl + captura de pantalla de la ventana)."""
import json, os, subprocess, tempfile, time, ctypes, sys
import win32gui, win32process, win32con
from PIL import ImageGrab, Image
ctypes.windll.user32.SetProcessDPIAware()
AQUI = os.path.dirname(os.path.abspath(__file__))
RAIZ = os.path.abspath(os.path.join(AQUI, "..", ".."))
EXE = os.path.join(RAIZ, "bin", "Release", "net8.0-windows", "HekatanLisp.exe")
IMG = os.path.join(AQUI, "img"); EJ = os.path.join(RAIZ, "ejemplos")
CTL = tempfile.mkdtemp(prefix="hl_manual_"); n = 0
def cmd(op, **kw):
    global n; n += 1
    c = os.path.join(CTL, f"cmd-{n:04d}.json"); r = os.path.join(CTL, f"resp-{n:04d}.json")
    json.dump({"op": op, **kw}, open(c, "w", encoding="utf-8"))
    for _ in range(600):
        if os.path.exists(r): time.sleep(0.05); return json.load(open(r, encoding="utf-8"))
        time.sleep(0.1)
    raise TimeoutError(op)
def hoja(ruta):
    cmd("settext", text=open(ruta, encoding="utf-8").read()); cmd("getoutput"); time.sleep(1.5)
def ventana(nombre):
    """Captura de la VENTANA entera (barra, editor y resultado) con PrintWindow(PW_RENDERFULLCONTENT):
    sale aunque otra ventana la tape, y trae también lo que pinta el WebView2."""
    import win32ui
    l, t, r, b = win32gui.GetWindowRect(hwnd); w, h = r - l, b - t
    hdc = win32gui.GetWindowDC(hwnd); src = win32ui.CreateDCFromHandle(hdc); mem = src.CreateCompatibleDC()
    bmp = win32ui.CreateBitmap(); bmp.CreateCompatibleBitmap(src, w, h); mem.SelectObject(bmp)
    time.sleep(0.8); ctypes.windll.user32.PrintWindow(hwnd, mem.GetSafeHdc(), 2)
    info = bmp.GetInfo(); im = Image.frombuffer("RGB", (info["bmWidth"], info["bmHeight"]), bmp.GetBitmapBits(True), "raw", "BGRX", 0, 1)
    im.save(os.path.join(IMG, nombre)); print(" ", nombre)
    win32gui.DeleteObject(bmp.GetHandle()); mem.DeleteDC(); src.DeleteDC(); win32gui.ReleaseDC(hwnd, hdc)
def sin_calculadora():
    from pywinauto import Application
    try:
        w = Application(backend="uia").connect(process=proc.pid).top_window()
        w.child_window(title_re=".*minimizar", control_type="Button").invoke(); time.sleep(0.5)
    except Exception as e: print("  (calculadora)", e)
def render(nombre, alto=None):
    """Captura del RESULTADO (página entera); `alto` recorta a lo que se explica."""
    p = os.path.join(IMG, nombre); cmd("capture", path=p)
    if alto:
        im = Image.open(p); im.crop((0, 0, im.width, min(alto, im.height))).save(p)
    print(" ", nombre)
proc = subprocess.Popen([EXE, "--ctl", CTL]); time.sleep(4)
hwnd = None
def buscar(h, _):
    global hwnd
    if win32gui.IsWindowVisible(h) and win32process.GetWindowThreadProcessId(h)[1] == proc.pid and win32gui.GetWindowText(h): hwnd = h
win32gui.EnumWindows(buscar, None)
win32gui.SetWindowPos(hwnd, 0, 20, 20, 1500, 950, 0)
sin_calculadora()
try:
    hoja(os.path.join(AQUI, "hoja_inicio.lisp"))
    ventana("01_ventana.png"); render("02_primera_hoja.png")
    hoja(os.path.join(EJ, "71 Losa rectangular por elementos finitos (Rectangular Slab FEA de Calcpad).lisp"))
    render("03_numerico.png", 1800)
    hoja(os.path.join(AQUI, "..", "..", "docs", "manual", "demo_dibujo.lisp"))
    render("04_dibujo.png", 2000)
    hoja(os.path.join(EJ, "79 Dibujar con listas - AutoLISP y matematica simbolica.lisp"))
    render("05_autolisp.png", 2200)
    hoja(os.path.join(EJ, "80 Dibujo 3D - cascara alabeada con sus ejes locales (AutoLISP).lisp"))
    render("06_3d.png", 2200)
    hoja(os.path.join(EJ, "81 Dibuja la seccion y el motor la calcula (ventana de dibujo).lisp"))
    render("07_ventana_dibujo_hoja.png")
    print(cmd("js", code="(function(){var b=document.querySelector('.hk-cad-btn'); if(!b) return 'sin boton'; b.scrollIntoView({block:'center'}); b.click(); return 'ok'})()"))
    time.sleep(2.5); ventana("08_ventana_cad.png")
finally:
    try: cmd("quit")
    except Exception: proc.kill()
