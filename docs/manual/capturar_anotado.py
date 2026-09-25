"""Capturas ANOTADAS del manual (escritorio): la ventana real + marcas en las posiciones reales.

    python capturar_anotado.py [exe] [solo…]       p. ej.  python capturar_anotado.py "" 01 02

Reglas: sin ratón ni teclado reales y sin captura de pantalla (el PC está en uso): la app se maneja por
--ctl (settext, js, layout…) y por UI Automation con invoke()/expand(); la foto es SOLO de su ventana
(PrintWindow). Las posiciones salen de UI Automation, de `layout` y de getBoundingClientRect (ctl js).
"""
import json, os, sys, time
from PIL import Image
sys.stdout.reconfigure(encoding="utf-8")
AQUI = os.path.dirname(os.path.abspath(__file__)); IMG = os.path.join(AQUI, "img"); sys.path.insert(0, AQUI)
from anotar import anotar, ROJO, AZUL, VERDE, ORO, MORADO
from hkapp import App, caja_js
import win32gui, win32process, win32ui, ctypes

RAIZ = os.path.abspath(os.path.join(AQUI, "..", ".."))
EXE = (sys.argv[1] if len(sys.argv) > 1 and sys.argv[1] else
       os.path.join(RAIZ, "bin", "Release", "net8.0-windows", "HekatanLisp.exe"))
SOLO = sys.argv[2:]
EJ = os.path.join(RAIZ, "ejemplos")
TMP = os.path.join(os.environ.get("TEMP", AQUI), "hk_manual"); os.makedirs(TMP, exist_ok=True)
def quiero(k): return not SOLO or k in SOLO
def une(*cs): return (min(c[0] for c in cs), min(c[1] for c in cs), max(c[2] for c in cs), max(c[3] for c in cs))

# teclas y ratón DENTRO de la página (eventos del DOM al lienzo de la ventana de dibujo: no el ratón del sistema)
TECLAS = """(function(t){var cv=document.querySelector('.hkcad canvas');cv.focus();
for(const ch of t){cv.focus();var k=ch==='\\n'?'Enter':ch;document.dispatchEvent(new KeyboardEvent('keydown',{key:k,bubbles:true,cancelable:true}));}return true})(%s)"""
MOVER = """(function(x,y,z,dx,dy){var cv=document.querySelector('.hkcad canvas'),q=hkCad.pantalla(x,y,z);
cv.dispatchEvent(new PointerEvent('pointermove',{clientX:q[0]+dx,clientY:q[1]+dy,bubbles:true,pointerId:1}));return hkCad.enganche()})(%s,%s,%s,%s,%s)"""
# cajas de TEXTO de la página (para que ningún número tape letras)
TEXTOS_JS = r"""(function(){var o=[],w=document.createTreeWalker(document.body,NodeFilter.SHOW_TEXT);var n;
while(n=w.nextNode()){if(!n.textContent.trim())continue;var r=document.createRange();r.selectNodeContents(n);
[...r.getClientRects()].forEach(function(b){if(!(b.width>0&&b.height>0))return;
if(VIS){var h=document.elementFromPoint((b.left+b.right)/2,(b.top+b.bottom)/2);if(!h||!(h===n.parentNode||h.contains(n)||n.parentNode.contains(h)))return;}
o.push([b.left,b.top+%s,b.right,b.bottom+%s])})}return o})()"""


def textos_uia(a):
    """Cajas (en la foto) de todo lo que tiene letras en la ventana: textos, botones, menús, casillas."""
    out = []
    for t in ("Text", "Button", "MenuItem", "CheckBox"):
        for e in a.w.descendants(control_type=t):
            if not e.window_text().strip(): continue
            r = e.rectangle()
            if r.width() > 0 and r.height() > 0: out.append(a.a_foto((r.left, r.top, r.right, r.bottom)))
    return out


def textos_web(a, pagina=False):
    """Cajas de texto del WebView, en la foto de la ventana (pagina=False) o en la captura de página entera."""
    v, k = a.web()
    if pagina:
        cajas = a.js(TEXTOS_JS.replace("VIS", "false") % ("scrollY", "scrollY")) or []
        return [tuple(c * k for c in b) for b in cajas]
    cajas = a.js(TEXTOS_JS.replace("VIS", "true") % (0, 0)) or []   # solo lo que se VE (no lo tapado por la ventana de dibujo)
    return [(v[0] + b[0] * k, v[1] + b[1] * k, v[0] + b[2] * k, v[1] + b[3] * k) for b in cajas
            if b[3] > 0 and b[1] * k < v[3] - v[1]]


def popups(a):
    """Ventanas emergentes de la app (menús abiertos): hwnd y su rectángulo."""
    hs = []
    def _b(h, _):
        if h != a.hwnd and win32gui.IsWindowVisible(h) and win32process.GetWindowThreadProcessId(h)[1] == a.proc.pid:
            hs.append(h)
    win32gui.EnumWindows(_b, None)
    return hs


def foto_hwnd(h):
    l, t, r, b = win32gui.GetWindowRect(h); ww, hh = r - l, b - t
    hdc = win32gui.GetWindowDC(h); src = win32ui.CreateDCFromHandle(hdc); mem = src.CreateCompatibleDC()
    bmp = win32ui.CreateBitmap(); bmp.CreateCompatibleBitmap(src, ww, hh); mem.SelectObject(bmp)
    ctypes.windll.user32.PrintWindow(h, mem.GetSafeHdc(), 2)
    info = bmp.GetInfo(); im = Image.frombuffer("RGB", (info["bmWidth"], info["bmHeight"]), bmp.GetBitmapBits(True), "raw", "BGRX", 0, 1)
    win32gui.DeleteObject(bmp.GetHandle()); mem.DeleteDC(); src.DeleteDC(); win32gui.ReleaseDC(h, hdc)
    return im, (l, t, r, b)


def ventana_y_hoja(a):
    hoja = open(os.path.join(AQUI, "hoja_inicio.lisp"), encoding="utf-8").read()
    a.hoja(hoja); a.js("window.scrollTo(0,0)"); time.sleep(0.5)

    # ------------------------------------------------ 01 · la ventana
    if quiero("01"):
        cruda = os.path.join(TMP, "01_crudo.png"); a.foto(cruda)
        L = a.cmd("layout"); ox, oy = a.origen()
        ed = a.uia_id("Editor"); vw = a.uia_id("Viewer"); W, H = Image.open(cruda).size
        # el panel de resultado entero: desde la cabecera «resultado — render CSS» hasta abajo, todo el ancho
        cab_res = a.uia("^resultado —", "Text", regex=True); cab_ed = a.uia("^escribes", "Text", regex=True)
        res = (vw[0], cab_res[1] - 4, W - 6, H - 6)
        edi = (ed[0], cab_ed[1] - 4, ed[2] - 2, ed[3])
        spl = (L["sx0"] - ox, L["sy0"] - oy, L["sx1"] - ox, L["sy1"] - oy)
        ym = (spl[1] + spl[3]) // 2
        div = (spl[0], ym - 60, spl[2], ym + 60)
        calc = une(a.uia("Calculadora", "Text"), a.uia("defun"), a.uia("−  minimizar"), a.uia("ω"), a.uia("quote"))
        calc = (calc[0] - 6, calc[1] - 6, ed[2] - 2, calc[3] + 10)
        marcas = [
            {"caja": une(a.uia("Archivo", "MenuItem"), a.uia("Ayuda", "MenuItem")), "n": 1, "color": AZUL, "pref": ["der", "abj"],
             "texto": "Menús: Archivo · Ver resultado · Insertar · Dibujo · Motor · Ayuda (manual)"},
            {"caja": a.uia("✏ Dibujar (CAD)"), "n": 2, "color": MORADO, "texto": "Dibujar (CAD): abre la ventana de dibujo"},
            {"caja": a.uia("🔗 Compartir"), "n": 3, "color": ORO, "texto": "Compartir: enlace web con la hoja dentro"},
            {"caja": une(a.uia("▶ Ejecutar"), a.uia("AutoRun", "CheckBox")), "n": 4, "color": ROJO, "texto": "Ejecutar (F5) · AutoRun: calcula al escribir"},
            {"caja": une(a.uia("resultado como:", "Text"), a.uia("Render CSS"), a.uia("3 formas")), "n": 5, "color": VERDE, "pad": 6,
             "texto": "resultado como: matemática dibujada, LISP, texto o las 3"},
            {"caja": une(a.uia("🖩"), a.uia("☀")), "n": 6, "color": ORO, "texto": "Calculadora (mostrar) · tema claro u oscuro", "pref": ["arr", "abj", "izq"]},
            {"caja": une(a.uia("escribo:", "Text"), a.uia("Hekatan Lab")), "n": 7, "color": AZUL, "pad": 6,
             "texto": "escribo: matemática · expr LISP · programa LISP · MATLAB", "pref": ["abj", "arr"]},
            {"caja": une(a.uia("operar:", "Text"), a.uia("despejar"), a.uia("var:", "Text")), "n": 8, "color": VERDE, "pad": 6,
             "texto": "operar: simplify, expand, diff, ∫ int, despejar (var)", "pref": ["abj", "arr"]},
            {"caja": edi, "n": 9, "color": ROJO, "texto": "Editor: datos, fórmulas y texto (Ctrl + rueda = zoom)", "pref": ["dentro"], "pad": 0},
            {"caja": res, "n": 10, "color": ROJO, "texto": "Resultado: se calcula y se dibuja al escribir", "pref": ["dentro"], "pad": 0},
            {"caja": div, "n": 11, "color": ORO, "texto": "Divisor: arrástralo para cambiar los anchos", "pref": ["der", "izq"], "pad": 2, "badge": (spl[0] - 40, ym)},
            {"caja": calc, "n": 12, "color": AZUL, "texto": "Calculadora: griegas, funciones, LISP (− minimizar)", "pref": ["dentro"], "pad": 0},
        ]
        anotar(cruda, os.path.join(IMG, "01_ventana.png"), marcas, textos=textos_uia(a) + textos_web(a), escala=1.6, cols=2)
        print("01_ventana.png")

    # ------------------------------------------------ 02 · la primera hoja (el resultado, página entera)
    if quiero("02"):
        # sin barra de desplazamiento: la captura de página entera sale con el mismo ancho que se mide
        a.js("document.documentElement.style.overflow='hidden'"); time.sleep(0.8)
        cruda = os.path.join(TMP, "02_crudo.png"); a.cmd("capture", path=cruda); time.sleep(0.5)
        im = Image.open(cruda); k = im.width / a.js("document.documentElement.clientWidth")
        def fila(rx, sub=None, i=0):
            """caja del CONTENIDO (texto, no la fila entera) del renglón cuyo texto casa con rx"""
            r = a.js(r"""(function(){var re=new RegExp(%s);var fs=[...document.body.children].filter(function(e){return e.getBoundingClientRect().height>0&&re.test((e.innerText||'').replace(/\s+/g,' ').trim())});
              var e=fs[%d];if(!e)return null;%s
              var g=document.createRange();g.selectNodeContents(e);var b=g.getBoundingClientRect();
              if(e.querySelector('svg,canvas')){b=e.getBoundingClientRect();}
              return [b.left,b.top+scrollY,b.right,b.bottom+scrollY]})()""" % (json.dumps(rx), i,
                  ("e=e.querySelector(%s)||e;" % json.dumps(sub)) if sub else ""))
            if not r: print("  (no encontrado)", rx); return None
            return tuple(v * k for v in r)
        M = [
            (r"^Mi primera hoja$", None, 0, 1, "# Título", AZUL),
            (r"^Datos$", None, 0, 2, "## Subtítulo", AZUL),
            (r"^Viga simplemente", None, 0, 3, "#: párrafo · **negrita**", AZUL),
            (r"^L = 6", None, 0, 4, "L = 6 'largo…: dato y su descripción", VERDE),
            (r"^M = 45", None, 0, 5, "M = q*L^2/8: fórmula con los datos", ROJO),
            (r"^El momento máximo", ".m-expr", 0, 6, "@M: el valor dentro del texto", ORO),
            (r"^f x = x3", None, 0, 7, "f(x) = … define; f(2) evalúa", VERDE),
            (r"^d dx", None, 0, 8, "Derivate{f(x) @ x}: derivada", ROJO),
            (r"^∫ x 3", None, 0, 9, "Integral{f(x) @ x}: integral", ROJO),
            (r"^3 ∫ 0", None, 0, 10, "Area{x^2 @ x = 0 : 3}: área = 9", ROJO),
            (r"^lim", None, 0, 11, "Limit{sin(x)/x @ x = 0}: límite", MORADO),
            (r"^100 Σ", None, 0, 12, "Sum{i @ i = 1 : 100}: suma", MORADO),
            (r"^T7", None, 0, 13, "Taylor{sin(x) @ x = 0 : 7}: serie", MORADO),
            (r"^A = 2 1 1 3", None, 0, 14, "A = [2 1; 1 3]: matriz", VERDE),
            (r"−1 =", None, 0, 15, "A^-1: inversa exacta (fracciones)", VERDE),
            (r"^-4 -3", None, 0, 16, "#fplot: gráfica (sin x y su Taylor)", AZUL),
        ]
        m2 = []
        for rx, sub, i, n, txt, col in M:
            b = fila(rx, sub, i)
            if b: m2.append({"caja": b, "n": n, "texto": txt, "color": col, "pad": 6, "pref": ["der", "izq", "arr", "abj"] if n != 16 else ["arr", "dentro"]})
        # el segundo límite y la segunda suma: marco sin número (mismo color)
        for rx, col in ((r"^lim x→1", MORADO), (r"^n Σ", MORADO)):
            b = fila(rx)
            if b: m2.append({"caja": b, "color": col, "pad": 6})
        tx = [tuple(v * k for v in b) for b in (a.js(TEXTOS_JS.replace("VIS", "false") % ("scrollY", "scrollY")) or [])]
        anotar(cruda, os.path.join(IMG, "02_primera_hoja.png"), m2, textos=tx, escala=1.5, cols=2)
        print("02_primera_hoja.png")


def menu_dibujo(a):
    """03 · el menú Dibujo abierto (expand() de UI Automation): el menú emergente es OTRA ventana; se
    fotografía con PrintWindow por su hwnd y se pega en su sitio sobre la foto de la ventana."""
    if not quiero("03"): return
    a.hoja("# Mi dibujo\n#: Menú Dibujo → ventana de dibujo 2D o 3D, bloque AutoLISP o bloque #dibujo.\n")
    antes = set(popups(a))
    mi = a.w.child_window(title="Dibujo", control_type="MenuItem")
    def opciones(): return [e for e in a.w.descendants(control_type="MenuItem") if "Ventana de dibujo" in e.window_text() or "Bloque" in e.window_text()]
    for _ in range(4):
        try: mi.expand()
        except Exception as ex: print("  expand:", ex)
        time.sleep(1.5); items = opciones()
        if len(items) == 4: break
    nuevos = [h for h in popups(a) if h not in antes]
    print("  emergentes:", nuevos)
    cruda = os.path.join(TMP, "03_crudo.png"); base = a.foto(cruda)
    ox, oy = a.origen()
    for h in nuevos:
        try: pim, (l, t, r, b) = foto_hwnd(h)
        except Exception: continue
        base.paste(pim, (l - ox, t - oy))
    base.save(cruda)
    cajas = {e.window_text(): a.a_foto((e.rectangle().left, e.rectangle().top, e.rectangle().right, e.rectangle().bottom)) for e in items}
    print("  menú:", cajas)
    tx = textos_uia(a)
    def cj(sub): v = next(v for k, v in cajas.items() if sub in k); return (v[0] + 2, v[1] + 3, v[2] - 3, v[3] - 3)
    mnu = une(*cajas.values())
    # lo que el menú tapa no se ve: fuera esas cajas de texto (quedan las de las opciones)
    tx = [t for t in textos_uia(a) if not (t[0] < mnu[2] and mnu[0] < t[2] and t[1] < mnu[3] and mnu[1] < t[3])]
    marcas = [
        {"caja": a.uia("Dibujo", "MenuItem"), "n": 1, "color": AZUL, "texto": "Menú Dibujo", "pref": ["arr", "der"]},
        {"caja": cj("2D"), "n": 2, "color": MORADO, "pad": 0, "texto": "Ventana 2D: dibujar en el plano como en AutoCAD", "pref": ["der"]},
        {"caja": cj("3D"), "n": 3, "color": MORADO, "pad": 0, "texto": "Ventana 3D: vistas, órbita, SCP, 3DPol y 3DCara", "pref": ["der"]},
        {"caja": cj("AutoLISP"), "n": 4, "color": VERDE, "pad": 0, "texto": "Bloque AutoLISP: dibujo con entmake, ssget, polar…", "pref": ["der"]},
        {"caja": cj("#dibujo"), "n": 5, "color": VERDE, "pad": 0, "texto": "Bloque #dibujo: medidas tomadas de la hoja", "pref": ["der"]},
    ]
    # solo la esquina del menú (a la derecha del menú empiezan los botones: el número va en el margen)
    rec = (0, 0, mnu[2], mnu[3] + 90)
    anotar(cruda, os.path.join(IMG, "03_menu_dibujo.png"), marcas, textos=tx, escala=1.1, cols=1, recorte=rec, margen=44)
    mi.collapse(); time.sleep(0.5)
    print("03_menu_dibujo.png")


def caja_dom(a, js):
    """caja (en la foto de la ventana) de un elemento del WebView: js = selector o expresión que da el elemento"""
    return a.dom(caja_js(js))


def texto_dom(a, sel):
    """caja de las LETRAS de un elemento (Range), no del elemento entero"""
    r = a.js("(function(){var e=document.querySelector(%s);if(!e)return null;var g=document.createRange();g.selectNodeContents(e);var b=g.getBoundingClientRect();return [b.left,b.top,b.right,b.bottom]})()" % json.dumps(sel))
    v, k = a.web(); return (v[0] + r[0] * k, v[1] + r[1] * k, v[0] + r[2] * k, v[1] + r[3] * k)


def texto_visible(a, sel):
    """caja de las letras QUE SE VEN de un elemento con desplazamiento (p. ej. el historial de órdenes)"""
    r = a.js("""(function(){var e=document.querySelector(%s),c=e.getBoundingClientRect(),o=null,w=document.createTreeWalker(e,NodeFilter.SHOW_TEXT),n;
      while(n=w.nextNode()){var g=document.createRange();g.selectNodeContents(n);[...g.getClientRects()].forEach(function(b){
        if(b.width<=0||b.bottom<=c.top+1||b.top>=c.bottom-1)return;var q=[b.left,Math.max(b.top,c.top),Math.min(b.right,c.right),Math.min(b.bottom,c.bottom)];
        o=o?[Math.min(o[0],q[0]),Math.min(o[1],q[1]),Math.max(o[2],q[2]),Math.max(o[3],q[3])]:q})}return o})()""" % json.dumps(sel))
    v, k = a.web(); return (v[0] + r[0] * k, v[1] + r[1] * k, v[0] + r[2] * k, v[1] + r[3] * k)


def union_dom(a, sel):
    """caja que envuelve todos los elementos del selector (en la foto)"""
    r = a.js("(function(){var bs=[...document.querySelectorAll(%s)].map(function(e){return e.getBoundingClientRect()}).filter(function(b){return b.width>0});"
             "if(!bs.length)return null;return [Math.min(...bs.map(b=>b.left)),Math.min(...bs.map(b=>b.top)),Math.max(...bs.map(b=>b.right)),Math.max(...bs.map(b=>b.bottom))]})()" % json.dumps(sel))
    if not r: print("  (sin elementos)", sel); return None
    v, k = a.web(); return (v[0] + r[0] * k, v[1] + r[1] * k, v[0] + r[2] * k, v[1] + r[3] * k)


def punto(a, x, y, z=0):
    """punto del dibujo → píxel de la foto"""
    q = a.js("hkCad.pantalla(%s,%s,%s)" % (x, y, z)); v, k = a.web(); return (v[0] + q[0] * k, v[1] + q[1] * k)


def abrir_cad(a, boton="✏ Dibujar (CAD)"):
    a.w.child_window(title=boton, control_type="Button").invoke()
    for _ in range(60):
        if a.js("!!document.querySelector('.hkcad')&&!!window.hkCad&&!!hkCad.estado()"): break
        time.sleep(0.25)
    time.sleep(0.8)


def tecla(a, k):
    a.js("document.dispatchEvent(new KeyboardEvent('keydown',{key:%s,bubbles:true,cancelable:true}))" % json.dumps(k))


MEDIR_JS = """(function(b,c){var g=document.createElement('canvas').getContext('2d');g.font='bold 14px Consolas,"Cascadia Mono",monospace';
  var L=Math.hypot(c[0]-b[0],c[1]-b[1]),an=Math.atan2(c[1]-b[1],c[0]-b[0])*180/Math.PI;if(an<0)an+=360;
  var t1=L.toFixed(2)+' m',t2=Math.round(an)%%360+'°',g2=document.createElement('canvas').getContext('2d');g2.font='11px "Segoe UI",Arial,sans-serif';
  return [g.measureText(t1).width+36,g.measureText(t2).width+16,g2.measureText('Punto final').width+8,t1,t2]})(%s,%s)"""


def ventana_2d(a):
    """04 · la ventana de dibujo 2D con una T dibujada por órdenes, una LÍNEA a medio hacer (goma con
    longitud y ángulo) y el cursor enganchado a un punto final (OSNAP). 04b · la mira con su caja x,y."""
    if not (quiero("04") or quiero("04b")): return
    a.hoja("# Sección T dibujada a mano\n#: Botón Dibujar (CAD): se abre la ventana de dibujo y lo dibujado vuelve a la hoja.\n")
    a.cmd("webzoom", factor=0.85)   # la barra de estado en una sola fila
    abrir_cad(a)
    # la T por la línea de órdenes (lo mismo que teclearlo): PL y coordenadas absolutas y relativas
    a.js(TECLAS % json.dumps("PL\n0.175,0\n@0.25,0\n@0,0.45\n@0.175,0\n@0,0.15\n@-0.6,0\n@0,-0.15\n@0.175,0\nC\n"))
    a.js("hkCad.ver(-0.45,-0.25,1.45,0.95)"); time.sleep(0.3)
    ents = json.loads(a.js("JSON.stringify(hkCad.estado().ents)")); print("  entidades:", [e[0][1] for e in ents])
    if quiero("04b"):
        a.js(TECLAS % json.dumps("L\n")); a.js(MOVER % (0.95, 0.75, 0, 0, 0)); time.sleep(0.4)
        cruda = os.path.join(TMP, "04b_crudo.png"); a.foto(cruda)
        cur = json.loads(a.js("JSON.stringify(hkCad.cursor())"))   # con Forzc el cursor salta a la rejilla
        c = punto(a, cur[0], cur[1]); v, k = a.web()
        # la caja de coordenadas va centrada en (cursor + 40, cursor − 52) px CSS (cajaDin de LispCad.js)
        w = a.js("(function(){var g=document.createElement('canvas').getContext('2d');g.font='bold 14px Consolas,monospace';return g.measureText(%s).width+36})()"
                 % json.dumps("%.2f,%.2f" % (cur[0], cur[1])))
        cx, cy = c[0] + 40 * k, c[1] - 52 * k
        cajac = (cx - w * k / 2, cy - 13 * k, cx + w * k / 2, cy + 13 * k)
        mira = (c[0] - 26 * k, c[1] - 26 * k, c[0] + 26 * k, c[1] + 26 * k)
        marcas = [
            {"caja": mira, "n": 1, "color": ROJO, "tipo": "circ", "texto": "Mira: cruz con un cuadrito en el punto", "pref": ["izq", "abj"]},
            {"caja": cajac, "n": 2, "color": AZUL, "texto": "Entrada dinámica: x,y del cursor (antes del 1.er punto)", "pref": ["der", "arr"]},
        ]
        rec = (int(mira[0] - 260), int(cajac[1] - 40), int(cajac[2] + 200), int(mira[3] + 90))
        anotar(cruda, os.path.join(IMG, "04b_mira.png"), marcas, textos=textos_web(a), escala=1.4, cols=1, recorte=rec)
        tecla(a, "Escape"); time.sleep(0.2)
        print("04b_mira.png")
    if quiero("04"):
        base, obj = (0.95, 0.15), (0.6, 0.6)
        a.js(TECLAS % json.dumps("L\n%s,%s\n" % base))
        for _ in range(6):
            a.asegurar(); en = a.js(MOVER % (obj[0], obj[1], 0, 4, -3)); time.sleep(0.5)
            if en == "fin": break
        print("  enganche:", en, a.js("JSON.stringify(hkCad.cursor())"))
        cruda = os.path.join(TMP, "04_crudo.png"); a.foto(cruda)
        v, k = a.web(); pb, pc = punto(a, *base), punto(a, *obj)
        g = a.js(MEDIR_JS % (json.dumps(base), json.dumps(obj)))
        mx, my = (pb[0] + pc[0]) / 2, (pb[1] + pc[1]) / 2
        cL = (mx - g[0] * k / 2, my - 13 * k, mx + g[0] * k / 2, my + 13 * k)
        ax, ay = pc[0], pc[1] + 58 * k
        if abs(mx - ax) < 90 * k and abs(my - ay) < 34 * k: ax = pc[0] + (72 if mx <= pc[0] else -72) * k; ay = pc[1] + 34 * k
        cA = (ax - g[1] * k / 2, ay - 13 * k, ax + g[1] * k / 2, ay + 13 * k)
        cM = (pc[0] - 8 * k, pc[1] - 8 * k, pc[0] + (18 + g[2]) * k, pc[1] + 28 * k)
        print("  goma:", g[3], g[4])
        xyt = texto_dom(a, ".hkcad-xy")
        marcas = [
            {"caja": une(texto_visible(a, ".hkcad-hist"), texto_dom(a, ".hkcad-prompt")), "n": 1, "color": ROJO, "texto": "Línea de órdenes (Orden:) e historial", "pref": ["der"], "pad": 8},
            {"caja": union_dom(a, ".hkcad-herr button[data-o]"), "n": 2, "color": AZUL, "texto": "Barra de órdenes: L, PL, REC, C, A… (con su alias)", "pref": ["abj", "arr"], "pad": 2},
            {"caja": caja_dom(a, "(document.querySelector('.hkcad-capa').parentNode)"), "n": 3, "color": VERDE,
             "texto": "Capa (+ capa nueva) y Color (ACI)", "pref": ["abj", "der", "arr"], "pad": 5},
            {"caja": caja_dom(a, "(document.querySelector('.hkcad-color').parentNode)"), "color": VERDE, "pad": 5},
            {"caja": union_dom(a, ".hkcad-est button[data-t]"), "n": 4, "color": ORO, "texto": "Rejilla F7 · Forzc F9 · Orto F8 · Polar F10 · Refent F3", "pref": ["arr"], "pad": 2},
            {"caja": union_dom(a, ".hkcad-est label"), "n": 5, "color": MORADO, "texto": "Modos de referencia (OSNAP): final, medio, centro…", "pref": ["arr"], "pad": 2},
            {"caja": xyt, "n": 6, "color": VERDE, "texto": "Coordenadas del cursor", "pad": 6,
             "badge": (xyt[2] + 40, (xyt[1] + xyt[3]) / 2), "forzar": True},   # a la derecha del texto (hueco medido hasta «Planta»)
            {"caja": cL, "n": 7, "color": AZUL, "texto": "Goma: longitud del tramo (un número = distancia)", "pref": ["der", "izq", "arr"], "pad": 4},
            {"caja": cA, "n": 8, "color": AZUL, "texto": "Ángulo del tramo", "pref": ["der", "izq", "abj"], "pad": 4},
            {"caja": cM, "n": 9, "color": ORO, "texto": "OSNAP «Punto final»: el cursor salta al vértice (imán)", "pref": ["der", "arr", "abj"], "pad": 4},
            {"caja": (pb[0] - 8 * k, pb[1] - 8 * k, pb[0] + 8 * k, pb[1] + 8 * k), "n": 10, "color": ROJO, "tipo": "circ", "texto": "Punto base (primer punto de la LÍNEA)", "pref": ["der", "abj", "izq"], "pad": 6},
            {"caja": caja_dom(a, ".hkcad-guardar"), "n": 11, "color": ROJO, "texto": "Guardar en la hoja: escribe el dibujo (entmake) y recalcula", "pref": ["abj", "izq"], "pad": 2},
            {"caja": caja_dom(a, ".hkcad-rej"), "n": 12, "color": ORO, "texto": "Paso de la rejilla", "pref": ["arr", "izq"], "pad": 2},
        ]
        anotar(cruda, os.path.join(IMG, "04_ventana_2d.png"), marcas, textos=textos_web(a), escala=1.6, cols=2)
        print("04_ventana_2d.png")
    a.js("hkCad.cerrar()"); time.sleep(0.5); a.cmd("webzoom", factor=1.0)


EJ84 = os.path.join(EJ, "84 Portico con losa dibujado en 3D (ventana de dibujo como AutoCAD 3D).lisp")


def ventana_3d(a):
    """05 · la ventana de dibujo en 3D (Iso SO) con el pórtico del ejemplo 84 y la orden 3P enganchando
    la esquina de la losa (5, 4, 3). 06 · la hoja del ejemplo 84: el dibujo 3D leído y sus medidas."""
    if not (quiero("05") or quiero("06")): return
    a.hoja(open(EJ84, encoding="utf-8").read(), espera_regex=r"L\s*col\s*=")
    if quiero("06"):
        a.js("document.documentElement.style.overflow='hidden';window.scrollTo(0,0)"); time.sleep(0.8)
        cruda = os.path.join(TMP, "06_crudo.png"); a.cmd("capture", path=cruda); time.sleep(0.5)
        k = Image.open(cruda).width / a.js("document.documentElement.clientWidth")
        R = a.js(r"""(function(){function bx(e){var b=e.getBoundingClientRect();return [b.left,b.top+scrollY,b.right,b.bottom+scrollY]}
          function tx(e){var g=document.createRange();g.selectNodeContents(e);var b=g.getBoundingClientRect();return [b.left,b.top+scrollY,b.right,b.bottom+scrollY]}
          function un(l){return [Math.min(...l.map(b=>b[0])),Math.min(...l.map(b=>b[1])),Math.max(...l.map(b=>b[2])),Math.max(...l.map(b=>b[3]))]}
          var al=document.querySelectorAll('.hk-al')[1],o={};
          o.svg=bx(al.querySelector('svg.hk-dib-svg'));
          var bs=[...al.querySelectorAll('button')];
          o.vistas=un(bs.filter(b=>/^(Planta|Frente|Lateral|3D)$/.test(b.textContent.trim())).map(bx));
          o.formatos=un(bs.filter(b=>/^(DXF|SVG|PNG|PDF|DWG)$/.test(b.textContent.trim())).map(bx));
          var ley=[...al.querySelectorAll('svg')].filter(s=>!s.classList.contains('hk-dib-svg')).map(s=>s.parentNode);
          o.capas=un(ley.map(tx));
          var t=[...al.querySelectorAll('*')].find(e=>/^Columnas:/.test((e.innerText||'').trim())&&e.children.length<3);o.resumen=t?tx(t):null;
          var fs=[...document.body.children].filter(e=>e.classList.contains('ws-eq'));
          var med=fs.filter(e=>/^(Lcol|Pvig|Alos|Larr|ncol|hcol)/.test((e.innerText||'').replace(/\s+/g,'')));
          o.medidas=un(med.map(tx)); o.al=bx(al);
          return o})()""")
        def K(b): return tuple(v * k for v in b)
        marcas = [
            {"caja": K(R["svg"]), "n": 1, "color": AZUL, "texto": "Dibujo 3D leído (se gira arrastrando); rótulos con z", "pref": ["der", "izq"]},
            {"caja": K(R["resumen"]), "n": 2, "color": VERDE, "texto": "Resumen medido: columnas, vigas, losa, riostras", "pref": ["der", "abj"], "pad": 8} if R.get("resumen") else None,
            {"caja": K(R["capas"]), "n": 3, "color": ORO, "texto": "Capas del dibujo con su color", "pref": ["abj", "der"], "pad": 7},
            {"caja": K(R["vistas"]), "n": 4, "color": MORADO, "texto": "Vistas: Planta · Frente · Lateral · 3D", "pref": ["izq", "der"], "pad": 4},
            {"caja": K(R["formatos"]), "n": 5, "color": ROJO, "texto": "Guardar el dibujo: DXF · SVG · PNG · PDF · DWG", "pref": ["der", "izq"], "pad": 4},
            {"caja": K(R["medidas"]), "n": 6, "color": VERDE, "texto": "exporta: las medidas vuelven a la hoja (L_col = 12 …)", "pref": ["der"], "pad": 9},
        ]
        marcas = [m for m in marcas if m]
        tx = [K(b) for b in (a.js(TEXTOS_JS.replace("VIS", "false") % ("scrollY", "scrollY")) or [])]
        al = K(R["al"]); med = K(R["medidas"])
        rec = (0, int(al[1] - 8), Image.open(cruda).width, int(med[3] + 20))
        anotar(cruda, os.path.join(IMG, "06_hoja_3d.png"), marcas, textos=tx, escala=1.5, cols=1, recorte=rec)
        a.js("document.documentElement.style.overflow=''")
        print("06_hoja_3d.png")
    if quiero("05"):
        a.cmd("webzoom", factor=0.85)
        a.js("(function(){var b=document.querySelector('.hk-cad-btn');b.scrollIntoView({block:'center'});b.click()})()")
        for _ in range(60):
            if a.js("!!document.querySelector('.hkcad')&&!!window.hkCad&&!!hkCad.estado()"): break
            time.sleep(0.25)
        time.sleep(0.6)
        a.js("document.querySelector('[data-v=ISOSO]').click()"); time.sleep(0.4)
        print("  cámara:", a.js("JSON.stringify(hkCad.camara())"))
        a.js(TECLAS % json.dumps("3P\n"))
        for _ in range(6):   # hasta que el cursor quede enganchado en la esquina de la losa
            a.asegurar(); en = a.js(MOVER % (5, 4, 3, 4, -3)); time.sleep(0.5)
            if en == "fin" and a.js("JSON.stringify(hkCad.cursor())") == "[5,4,3]": break
        print("  enganche 3D:", en, a.js("JSON.stringify(hkCad.cursor())"))
        cruda = os.path.join(TMP, "05_crudo.png"); a.foto(cruda)
        v, k = a.web(); pc = punto(a, 5, 4, 3)
        wm = a.js(MEDIR_JS % ("[0,0]", "[1,1]"))[2]
        cv = caja_dom(a, ".hkcad canvas")
        ico = (cv[0] + (52 - 50) * k, cv[3] - (34 + 50) * k, cv[0] + (52 + 50) * k, cv[3] - (34 - 14) * k)
        estrella = (pc[0] - 30 * k, pc[1] - 24 * k, pc[0] + 30 * k, pc[1] + 26 * k)
        cM = (pc[0] + 8 * k, pc[1] + 8 * k, pc[0] + (20 + wm) * k, pc[1] + 28 * k)
        vt = texto_dom(a, ".hkcad-vista")
        wx = a.js("(function(){var g=document.createElement('canvas').getContext('2d');g.font='bold 14px Consolas,monospace';return g.measureText('5.00,4.00,3.00').width+36})()")
        cXYZ = (pc[0] + 40 * k - wx * k / 2, pc[1] - 65 * k, pc[0] + 40 * k + wx * k / 2, pc[1] - 39 * k)   # cajaDin en (cursor + 40, cursor − 52)
        o3 = union_dom(a, ".hkcad-herr button[data-o=POL3D], .hkcad-herr button[data-o=CARA3D], .hkcad-herr button[data-o=SCP]")
        marcas = [
            {"caja": caja_dom(a, ".hkcad-vistas"), "n": 1, "color": AZUL, "texto": "Vistas: Planta · Frente · Lateral · Iso SO · Iso SE", "pref": ["abj", "izq", "arr"], "pad": 3},
            {"caja": o3, "n": 2, "color": MORADO, "texto": "3DPol (3P) · 3DCara (3F) · SCP", "pref": ["abj", "arr"], "pad": 3},
            {"caja": une(estrella, cM), "n": 3, "color": ROJO, "texto": "Mira 3D (estrella X, Y, Z) enganchada: «Punto final» (5, 4, 3)", "pref": ["der", "izq", "abj"], "pad": 2},
            {"caja": cXYZ, "n": 4, "color": ORO, "texto": "Entrada dinámica: x,y,z del punto", "pref": ["der", "izq"], "pad": 3},
            {"caja": ico, "n": 5, "color": VERDE, "texto": "Icono del SCP (cuadradito = SCP Universal)", "pref": ["der", "arr"], "pad": 2},
            {"caja": vt, "n": 6, "color": AZUL, "texto": "Vista · plano de trabajo · SCP actual", "pad": 3,
             "badge": (vt[0] - 40, (vt[1] + vt[3]) / 2), "forzar": True},   # en el hueco medido entre x,y,z y la vista
            {"caja": (lambda h, o: (h[0], h[1], h[2], o[3] - 6))(caja_dom(a, ".hkcad-hist"), caja_dom(a, ".hkcad-ord")), "n": 7, "color": ROJO,
             "texto": "Orden 3P: pide x,y,z o @dx,dy,dz", "pref": ["dentro"], "pad": 0},
            {"caja": caja_dom(a, ".hkcad-guardar"), "n": 8, "color": ROJO, "texto": "Guardar en la hoja (POLYLINE + VERTEX con z)", "pref": ["abj", "izq"], "pad": 2},
        ]
        anotar(cruda, os.path.join(IMG, "05_ventana_3d.png"), marcas, textos=textos_web(a), escala=1.6, cols=2)
        print("05_ventana_3d.png")
        tecla(a, "Escape"); a.js("hkCad.cerrar()"); time.sleep(0.5); a.cmd("webzoom", factor=1.0)


if __name__ == "__main__":
    with App(EXE) as a:
        a.js("window.scrollTo(0,0)")
        ventana_y_hoja(a)
        menu_dibujo(a)
        ventana_2d(a)
        ventana_3d(a)
