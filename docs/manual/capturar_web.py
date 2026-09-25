"""07_web.png: Hekatan LISP web (Playwright sin ventana), con el menú Dibujo abierto y marcas en las
posiciones reales (getBoundingClientRect × escala de la captura).

    python capturar_web.py [url]
"""
import os, sys
from playwright.sync_api import sync_playwright
sys.stdout.reconfigure(encoding="utf-8")
AQUI = os.path.dirname(os.path.abspath(__file__)); IMG = os.path.join(AQUI, "img"); sys.path.insert(0, AQUI)
from anotar import anotar, ROJO, AZUL, VERDE, ORO, MORADO

URL = sys.argv[1] if len(sys.argv) > 1 else "https://giorgioburbanelli89.github.io/hekatan-lisp/"
K = 1.5
TMP = os.path.join(os.environ.get("TEMP", AQUI), "hk_manual"); os.makedirs(TMP, exist_ok=True)

CAJA = """(function(sel,txt){var es=[...document.querySelectorAll(sel)].filter(function(e){var b=e.getBoundingClientRect();
  return b.width>0&&b.height>0&&(!txt||(e.innerText||e.textContent||'').trim().indexOf(txt)===0)});
  if(!es.length)return null;var bs=es.map(function(e){return e.getBoundingClientRect()});
  return [Math.min(...bs.map(b=>b.left)),Math.min(...bs.map(b=>b.top)),Math.max(...bs.map(b=>b.right)),Math.max(...bs.map(b=>b.bottom))]})"""
TEXTOS = """(function(){var o=[],w=document.createTreeWalker(document.body,NodeFilter.SHOW_TEXT),n;
while(n=w.nextNode()){if(!n.textContent.trim())continue;var r=document.createRange();r.selectNodeContents(n);
[...r.getClientRects()].forEach(function(b){if(!(b.width>0&&b.height>0)||b.bottom<0||b.top>innerHeight)return;
var h=document.elementFromPoint((b.left+b.right)/2,(b.top+b.bottom)/2);if(!h||!(h===n.parentNode||h.contains(n)||n.parentNode.contains(h)))return;
o.push([b.left,b.top,b.right,b.bottom])})}return o})()"""

def une2(a, b):
    if not a or not b: return a or b
    return (min(a[0], b[0]), min(a[1], b[1]), max(a[2], b[2]), max(a[3], b[3]))


with sync_playwright() as p:
    b = p.chromium.launch()
    pg = b.new_page(viewport={"width": 1500, "height": 950}, device_scale_factor=K, color_scheme="light")
    pg.goto(URL, wait_until="networkidle"); pg.wait_for_timeout(3000)
    def caja(sel, txt=None):
        r = pg.evaluate(CAJA + "(%r,%r)" % (sel, txt or ""))
        if not r: print("  (no está)", sel, txt); return None
        return tuple(v * K for v in r)
    try: pg.click("#intro-cerrar"); pg.wait_for_timeout(500)   # sin el aviso de bienvenida: deja sitio a los números
    except Exception: pass
    tx = [tuple(v * K for v in t) for t in pg.evaluate(TEXTOS)]
    cruda = os.path.join(TMP, "07_crudo.png"); pg.screenshot(path=cruda)
    marcas = [
        {"caja": caja("#menu .mi > span", "Dibujo"), "n": 1, "color": AZUL, "texto": "Menú Dibujo: ventanas 2D y 3D, bloques de dibujo", "pref": ["arr", "abj"], "pad": 3},
        {"caja": caja("#menu .mi > span", "Ayuda"), "n": 2, "color": AZUL, "texto": "Ayuda: este manual (PDF)", "pref": ["arr", "der"], "pad": 3},
        {"caja": caja("button.mode", "✏"), "n": 3, "color": MORADO, "texto": "Dibujar (CAD): abre la ventana de dibujo", "pref": ["abj", "arr"], "pad": 3},
        {"caja": caja("button.mode", "🔗"), "n": 4, "color": ORO, "texto": "Compartir: copia el enlace con la hoja dentro", "pref": ["abj", "arr"], "pad": 3},
        {"caja": caja("#sel-ejemplos"), "n": 5, "color": VERDE, "texto": "Ejemplos: se cargan y calculan al elegirlos", "pref": ["abj", "arr"], "pad": 3},
        {"caja": une2(caja("#btn-run"), caja("label", "AutoRun") or caja("#btn-run")), "n": 6, "color": ROJO, "texto": "Ejecutar · AutoRun", "pref": ["abj", "arr"], "pad": 3},
    ]
    marcas = [m for m in marcas if m["caja"]]
    anotar(cruda, os.path.join(IMG, "07_web.png"), marcas, textos=tx, escala=1.5, cols=2, margen=60)
    print("07_web.png")
    # el menú Dibujo abierto (un clic: aquí sí es el ratón de Playwright, no el del PC)
    pg.locator("#menu .mi > span", has_text="Dibujo").first.click(); pg.wait_for_timeout(700)
    bs = pg.evaluate("[...document.querySelectorAll('#menu .mi.open > .sub > button')].map(function(e){var b=e.getBoundingClientRect();return [b.left,b.top,b.right,b.bottom,e.textContent.trim()]})")
    sub = caja("#menu .mi.open > .sub")
    tx = [tuple(v * K for v in t) for t in pg.evaluate(TEXTOS)]
    tx = [t for t in tx if not (t[0] < sub[2] and sub[0] < t[2] and t[1] < sub[3] and sub[1] < t[3])]
    cruda = os.path.join(TMP, "07b_crudo.png"); pg.screenshot(path=cruda)
    textos_items = ["Ventana de dibujo 2D (como AutoCAD)", "Ventana de dibujo 3D (vistas, órbita, SCP)", "Bloque AutoLISP (entmake, ssget, polar…)", "Bloque #dibujo con medidas de la hoja"]
    m2 = [{"caja": caja("#menu .mi > span", "Dibujo"), "n": 1, "color": AZUL, "texto": "Menú Dibujo (un clic lo abre)", "pref": ["arr", "izq"], "pad": 3}]
    for i, bb in enumerate(bs[:4]):
        m2.append({"caja": (bb[0] * K + 3, bb[1] * K + 3, bb[2] * K - 3, bb[3] * K - 3), "n": i + 2, "color": MORADO if i < 2 else VERDE,
                   "texto": textos_items[i], "pref": ["der"], "pad": 0})
    anotar(cruda, os.path.join(IMG, "07b_web_menu.png"), m2, textos=tx, escala=1.1, cols=1, recorte=(0, 0, int(sub[2]), int(sub[3] + 60)), margen=40)
    print("07b_web_menu.png")
    b.close()
