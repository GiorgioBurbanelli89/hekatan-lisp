#!/usr/bin/env python3
"""Divisor editor | resultado ARRASTRABLE y Ctrl + rueda = zoom del editor (como Hekatan Lab,
commits 6dc944d y 83d1b3e de hekatan-lab).

1. --ctl «layout»: anchos de las columnas y dónde está el divisor en pantalla.
2. Arrastre con el RATÓN DE VERDAD (SetCursorPos + mouse_event), 300 px a la izquierda.
3. Ctrl + rueda de verdad sobre el editor: +2 pt por paso.
4. --ctl «zoom»: topes 6 y 40.
Antes de tocar el ratón o el teclado se comprueba que la ventana al frente es ESTA app: si no,
no se toca nada (un clic a ciegas cae en otra ventana del usuario).

Uso: python tests/test_splitter_zoom.py [--exe ruta] [--png salida.png]
"""
import argparse, ctypes, json, os, shutil, subprocess, sys, tempfile, time
from ctypes import wintypes

AQUI = os.path.dirname(os.path.abspath(__file__))
EXE = os.path.join(AQUI, "..", "bin", "Release", "net8.0-windows", "HekatanLisp.exe")
u32 = ctypes.windll.user32
u32.SetProcessDPIAware()


class Ctl:
    def __init__(self, exe):
        self.dir = tempfile.mkdtemp(prefix="hklisp_split_")
        self.p = subprocess.Popen([exe, "--ctl", self.dir])
        self.n = 0
        t0 = time.time()
        while not os.path.exists(os.path.join(self.dir, "ready.txt")) and time.time() - t0 < 30:
            time.sleep(0.2)

    def __call__(self, d, espera=30):
        self.n += 1
        c = os.path.join(self.dir, f"cmd-{self.n:04d}.json")
        r = os.path.join(self.dir, f"resp-{self.n:04d}.json")
        json.dump(d, open(c, "w", encoding="utf-8"))
        t0 = time.time()
        while time.time() - t0 < espera:
            if os.path.exists(r):
                time.sleep(0.1)
                return json.load(open(r, encoding="utf-8"))
            time.sleep(0.1)
        raise TimeoutError(d)

    def cerrar(self):
        try: self({"op": "quit"}, espera=5)
        except Exception: pass
        time.sleep(1)
        if self.p.poll() is None: self.p.kill()
        shutil.rmtree(self.dir, ignore_errors=True)


def al_frente_es(pid):
    h = u32.GetForegroundWindow()
    p = wintypes.DWORD()
    u32.GetWindowThreadProcessId(h, ctypes.byref(p))
    return p.value == pid


def ventanas(pid):
    hs = []
    def cb(h, _):
        p = wintypes.DWORD(); u32.GetWindowThreadProcessId(h, ctypes.byref(p))
        if p.value == pid and u32.IsWindowVisible(h): hs.append(h)
        return True
    u32.EnumWindows(ctypes.WINFUNCTYPE(ctypes.c_bool, wintypes.HWND, wintypes.LPARAM)(cb), 0)
    return hs


def traer(pid):
    u32.keybd_event(0x12, 0, 0, 0); u32.keybd_event(0x12, 0, 2, 0)   # ALT suelto: deja robar el foco
    for h in ventanas(pid):
        u32.ShowWindow(h, 9); u32.SetForegroundWindow(h)
        # SIEMPRE ENCIMA mientras dura la prueba: una consola capa (transparente) a pantalla completa
        # quedaba por encima y se llevaba el clic aunque la app estuviera al frente
        u32.SetWindowPos(h, -1, 0, 0, 0, 0, 0x0001 | 0x0002 | 0x0040)   # HWND_TOPMOST, NOSIZE|NOMOVE|SHOWWINDOW
    time.sleep(0.8)


def de_la_app(pid, x, y):
    """¿El punto (x, y) de la pantalla cae en una ventana de ESTA app? (si no, no se hace clic)"""
    h = u32.WindowFromPoint(wintypes.POINT(x, y))
    p = wintypes.DWORD(); u32.GetWindowThreadProcessId(h, ctypes.byref(p))
    return p.value == pid


def arrastrar(x0, y, x1):
    for dy in (-20, -10, 0):                                          # moverse ANTES de apretar (ver ctrl_rueda)
        u32.SetCursorPos(x0, y + dy); time.sleep(0.08)
    u32.mouse_event(0x0001, 0, 1, 0, 0); u32.mouse_event(0x0001, 0, -1 & 0xFFFFFFFF, 0, 0); time.sleep(0.2)
    u32.mouse_event(0x0002, 0, 0, 0, 0); time.sleep(0.15)
    for k in range(1, 21):
        u32.SetCursorPos(int(x0 + (x1 - x0) * k / 20), y); time.sleep(0.03)
    time.sleep(0.15)
    u32.mouse_event(0x0004, 0, 0, 0, 0); time.sleep(0.5)


def ctrl_rueda(x, y, pasos):
    # el ratón tiene que MOVERSE sobre el editor antes de la rueda: WPF sabe qué hay bajo el
    # cursor por los WM_MOUSEMOVE; un SetCursorPos al mismo sitio no manda ninguno
    for dx in (-20, -10, 0):
        u32.SetCursorPos(x + dx, y); time.sleep(0.08)
    u32.mouse_event(0x0001, 1, 0, 0, 0); u32.mouse_event(0x0001, -1 & 0xFFFFFFFF, 0, 0, 0); time.sleep(0.2)
    u32.keybd_event(0x11, 0, 0, 0); time.sleep(0.05)                   # Ctrl abajo
    for _ in range(abs(pasos)):
        u32.mouse_event(0x0800, 0, 0, 120 if pasos > 0 else -120 & 0xFFFFFFFF, 0); time.sleep(0.15)
    u32.keybd_event(0x11, 0, 2, 0); time.sleep(0.3)                    # Ctrl arriba


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--exe", default=EXE)
    ap.add_argument("--png", default=None)
    a = ap.parse_args()
    ctl = Ctl(os.path.abspath(a.exe))
    fallos = 0
    def chk(ok, txt):
        nonlocal fallos
        fallos += not ok
        print(f"  [{'OK ' if ok else 'MAL'}] {txt}")
    try:
        time.sleep(3)
        l0 = ctl({"op": "layout"})
        print("antes:", {k: l0[k] for k in ("editor", "splitter", "web", "fontSize")})
        chk(l0["splitter"] >= 4, f"el divisor tiene ancho para agarrarlo: {l0['splitter']:.1f} px")
        for _ in range(4):                       # robar el foco a veces falla a la primera
            traer(ctl.p.pid)
            if al_frente_es(ctl.p.pid): break
        if not al_frente_es(ctl.p.pid):
            chk(False, "la ventana de prueba NO quedó al frente: no se toca el ratón")
        else:
            cx = (l0["sx0"] + l0["sx1"]) // 2
            cy = (l0["sy0"] + l0["sy1"]) // 2
            chk(de_la_app(ctl.p.pid, cx, cy), "bajo el divisor está la ventana de prueba (y no otra)")
            if de_la_app(ctl.p.pid, cx, cy): arrastrar(cx, cy, cx - 300)
            l1 = ctl({"op": "layout"})
            print("después de arrastrar:", {k: l1[k] for k in ("editor", "splitter", "web")})
            chk(l1["editor"] < l0["editor"] - 100 and l1["web"] > l0["web"] + 100,
                f"arrastrado 300 px a la izquierda: editor {l0['editor']:.0f} -> {l1['editor']:.0f}, "
                f"resultado {l0['web']:.0f} -> {l1['web']:.0f}")
            if al_frente_es(ctl.p.pid):
                f0 = l1["fontSize"]
                ctrl_rueda(l1["ecx"], l1["ecy"], +2)
                f1 = ctl({"op": "layout"})["fontSize"]
                chk(abs(f1 - (f0 + 4)) < 1e-6, f"Ctrl + rueda (2 pasos) sobre el editor: {f0} -> {f1} pt")
                ctrl_rueda(l1["ecx"], l1["ecy"], -2)
                f2 = ctl({"op": "layout"})["fontSize"]
                chk(abs(f2 - f0) < 1e-6, f"Ctrl + rueda (−2 pasos) vuelve: {f1} -> {f2} pt")
            else:
                chk(False, "la ventana perdió el frente: no se manda Ctrl + rueda")
            if a.png:
                ctl({"op": "capture", "path": os.path.abspath(a.png)})
                print("png:", os.path.abspath(a.png))
        z = ctl({"op": "zoom", "steps": 30})
        chk(38 <= z["fontSize"] <= 40, f"tope superior (≤ 40 pt): {z['fontSize']}")
        z = ctl({"op": "zoom", "steps": -30})
        chk(z["fontSize"] == 6 or z["fontSize"] == 7, f"tope inferior (≥ 6 pt): {z['fontSize']}")
    finally:
        ctl.cerrar()
    print("TODO OK" if not fallos else f"FALLAN {fallos}")
    sys.exit(1 if fallos else 0)


if __name__ == "__main__":
    main()
