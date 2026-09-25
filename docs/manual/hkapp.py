"""La app de escritorio para las capturas del manual: se lanza con --ctl, se maneja por el canal ctl
y por UI Automation (invoke/expand, nunca el ratón real) y se fotografía SOLO su ventana (PrintWindow).

    from hkapp import App
    with App(exe) as a: a.hoja(texto); a.foto(ruta); a.uia("Archivo", "MenuItem") ...

Todas las cajas se devuelven en píxeles de la foto (origen = esquina de la foto)."""
import ctypes, json, os, subprocess, tempfile, time
import win32gui, win32process, win32ui
from PIL import Image

ctypes.windll.user32.SetProcessDPIAware()
SWP_NOACTIVATE, SWP_NOZORDER = 0x0010, 0x0004
BORDE = 8   # marco invisible de Windows 11 (px físicos a izquierda, derecha y abajo)


class App:
    def __init__(self, exe, ancho=1500, alto=950):
        self.exe, self.ancho, self.alto = exe, ancho, alto
        self.ctl = tempfile.mkdtemp(prefix="hl_man_"); self.n = 0; self.proc = None

    # ---------------------------------------------------------------- vida
    def __enter__(self):
        si = subprocess.STARTUPINFO(); si.dwFlags |= subprocess.STARTF_USESHOWWINDOW; si.wShowWindow = 4   # SW_SHOWNOACTIVATE
        self.proc = subprocess.Popen([self.exe, "--ctl", self.ctl], startupinfo=si)
        for _ in range(150):
            if os.path.exists(os.path.join(self.ctl, "ready.txt")): break
            time.sleep(0.2)
        time.sleep(2)
        self.hwnd = None
        def _b(h, _):
            if win32gui.IsWindowVisible(h) and win32process.GetWindowThreadProcessId(h)[1] == self.proc.pid and win32gui.GetWindowText(h): self.hwnd = h
        win32gui.EnumWindows(_b, None)
        self.dpi = ctypes.windll.user32.GetDpiForWindow(self.hwnd) / 96
        win32gui.ShowWindow(self.hwnd, 4)    # restaurada (si estaba maximizada) sin activar
        W, H = int(self.ancho * self.dpi) + 2 * BORDE, int(self.alto * self.dpi) + BORDE
        win32gui.SetWindowPos(self.hwnd, 0, 0, 0, W, H, SWP_NOACTIVATE | SWP_NOZORDER); time.sleep(1)
        from pywinauto import Application
        self.w = Application(backend="uia").connect(process=self.proc.pid).top_window()
        return self

    def __exit__(self, *a):
        try: self.cmd("quit", espera=40)
        except Exception: pass
        time.sleep(1.5)
        try:
            if self.proc.poll() is None: self.proc.kill()
        except Exception: pass

    # ---------------------------------------------------------------- canal ctl
    def cmd(self, op, espera=600, **kw):
        self.n += 1
        c = os.path.join(self.ctl, f"cmd-{self.n:04d}.json"); r = os.path.join(self.ctl, f"resp-{self.n:04d}.json")
        json.dump({"op": op, **kw}, open(c + ".tmp", "w", encoding="utf-8")); os.replace(c + ".tmp", c)
        for _ in range(espera * 10):
            if os.path.exists(r):
                for _k in range(20):
                    try: time.sleep(0.03); return json.load(open(r, encoding="utf-8"))
                    except Exception: time.sleep(0.05)
            time.sleep(0.1)
        raise TimeoutError(op)

    def js(self, code): return self.cmd("js", code=code).get("result")

    def hoja(self, texto, espera_regex=None):
        self.cmd("settext", text=texto); out = self.cmd("getoutput").get("output", "")
        if espera_regex:
            import re
            for _ in range(80):
                if re.search(espera_regex, out): break
                time.sleep(0.5); out = self.cmd("getoutput").get("output", "")
        time.sleep(1.2); return out

    # ---------------------------------------------------------------- foto de la ventana
    def origen(self):
        l, t, r, b = win32gui.GetWindowRect(self.hwnd); return l + BORDE, t

    def asegurar(self):
        """si la ventana quedó minimizada o cambió de tamaño, se restaura SIN activarla"""
        W, H = int(self.ancho * self.dpi) + 2 * BORDE, int(self.alto * self.dpi) + BORDE
        l, t, r, b = win32gui.GetWindowRect(self.hwnd)
        if win32gui.IsIconic(self.hwnd) or (r - l, b - t) != (W, H):
            win32gui.ShowWindow(self.hwnd, 4)
            win32gui.SetWindowPos(self.hwnd, 0, 0, 0, W, H, SWP_NOACTIVATE | SWP_NOZORDER); time.sleep(1.5)
            return True
        return False

    def foto(self, ruta):
        self.asegurar()
        time.sleep(0.6)
        l, t, r, b = win32gui.GetWindowRect(self.hwnd); ww, hh = r - l, b - t
        hdc = win32gui.GetWindowDC(self.hwnd); src = win32ui.CreateDCFromHandle(hdc); mem = src.CreateCompatibleDC()
        bmp = win32ui.CreateBitmap(); bmp.CreateCompatibleBitmap(src, ww, hh); mem.SelectObject(bmp)
        ctypes.windll.user32.PrintWindow(self.hwnd, mem.GetSafeHdc(), 2)   # PW_RENDERFULLCONTENT: trae el WebView2
        info = bmp.GetInfo(); im = Image.frombuffer("RGB", (info["bmWidth"], info["bmHeight"]), bmp.GetBitmapBits(True), "raw", "BGRX", 0, 1)
        win32gui.DeleteObject(bmp.GetHandle()); mem.DeleteDC(); src.DeleteDC(); win32gui.ReleaseDC(self.hwnd, hdc)
        im = im.crop((BORDE, 0, ww - BORDE, hh - BORDE)); im.save(ruta)
        return im

    # ---------------------------------------------------------------- posiciones medidas
    def a_foto(self, r):
        ox, oy = self.origen(); return (r[0] - ox, r[1] - oy, r[2] - ox, r[3] - oy)

    def uia(self, nombre, tipo="Button", i=0, regex=False):
        import re
        es = [e for e in self.w.descendants(control_type=tipo)
              if (re.search(nombre, e.window_text()) if regex else e.window_text() == nombre)]
        r = es[i].rectangle(); return self.a_foto((r.left, r.top, r.right, r.bottom))

    def uia_id(self, aid):
        e = self.w.child_window(auto_id=aid).wrapper_object(); r = e.rectangle()
        return self.a_foto((r.left, r.top, r.right, r.bottom))

    def web(self):
        """Caja del WebView2 (el resultado) en la foto y la escala CSS px → px de la foto."""
        v = self.uia_id("Viewer"); k = self.js("window.devicePixelRatio")
        return v, k

    def dom(self, js_caja):
        """js_caja: expresión JS que devuelve [left, top, right, bottom] en px CSS del viewport (o null)."""
        r = self.js(js_caja)
        if not r: return None
        v, k = self.web()
        return (v[0] + r[0] * k, v[1] + r[1] * k, v[0] + r[2] * k, v[1] + r[3] * k)


def caja_js(selector_o_expr):
    """JS de la caja (getBoundingClientRect) de un elemento: selector CSS o expresión que da el elemento."""
    ex = selector_o_expr if selector_o_expr.startswith("(") else "document.querySelector(%s)" % json.dumps(selector_o_expr)
    return "(function(){var e=%s;if(!e)return null;var b=e.getBoundingClientRect();return [b.left,b.top,b.right,b.bottom]})()" % ex
