"""Audita TODOS los ejemplos de Hekatan LISP web (sitio público o local).

    python tests/web/auditar_ejemplos_web.py [publico|http://localhost:8080/] [filtro] [desde] [hasta]

Por ejemplo: carga #ej=<archivo>&solo=1, espera el cálculo, y apunta
  - errores de página/consola,
  - marcas de error DEL MOTOR en el render (.hk-dib-err, .hk-al-errl, «⚠», NaN, «no definid…», unbound…),
  - render casi vacío,
  - la palabra «awatif» a la vista (no debe salir salvo en créditos),
y guarda un PNG por ejemplo + hojas de contacto para MIRAR (tests/web/salida/).

«MAL» = fallo de verdad. «ok? » = la prosa dice «error» (p. ej. «el error de la malla»): NO es fallo,
se apunta en `dudas` para mirarlo. Antes esa palabra marcaba MAL y daba 21 falsos positivos de 82.

Memoria: el navegador se REINICIA cada 10 ejemplos y el json se guarda tras cada uno (el 27-sep-2026
la pasada entera se quedó sin memoria en el ejemplo 82 y no dejó json).
"""
import json, os, re, sys, time, urllib.parse
from playwright.sync_api import sync_playwright

AQUI = os.path.dirname(os.path.abspath(__file__))
RAIZ = os.path.abspath(os.path.join(AQUI, "..", ".."))
BASE = sys.argv[1] if len(sys.argv) > 1 and sys.argv[1] != "publico" else "https://giorgioburbanelli89.github.io/hekatan-lisp/"
FILTRO = sys.argv[2] if len(sys.argv) > 2 else ""
OUT = os.path.join(AQUI, "salida"); os.makedirs(OUT, exist_ok=True)
EJ = sorted(f for f in os.listdir(os.path.join(RAIZ, "web", "HekatanLispWeb", "wwwroot", "ejemplos")) if f.endswith(".lisp") and FILTRO in f)
DESDE = int(sys.argv[3]) if len(sys.argv) > 3 else 0
HASTA = int(sys.argv[4]) if len(sys.argv) > 4 else len(EJ)
CADA = 10                                   # ejemplos por navegador
ALTO = 1800                                 # alto de la captura: se ve más hoja

MARCAS = r"""() => {
  const fr = document.querySelectorAll('iframe'); let d = null;
  for (const f of fr) { try { if (f.contentDocument?.body?.innerText?.length > 20) d = f.contentDocument; } catch {} }
  const fuera = document.body.innerText || '';
  if (!d) return { vacio: true, txt: '', awatif: /awatif/i.test(fuera) ? ['(fuera de la hoja)'] : [] };
  const t = d.body.innerText;
  const errs = [...d.querySelectorAll('.hk-dib-err, .hk-al-errl')].map(e => e.innerText.slice(0, 160));
  const L = t.split('\n');
  const lineas = L.filter(l => /⚠|no definid|undefined|\bNaN\b|no se pudo|excepci[oó]n|unbound|not a number|no tiene valor/i.test(l)).map(l => l.slice(0, 160));
  const dudas = L.filter(l => /\berror\b/i.test(l) && !/⚠/.test(l)).map(l => l.slice(0, 120));
  const awatif = L.concat(fuera.split('\n')).filter(l => /awatif/i.test(l)).map(l => l.slice(0, 160));
  return { vacio: t.trim().length < 40, largo: t.length, errs, lineas: lineas.slice(0, 6), dudas: dudas.slice(0, 3),
           awatif: awatif.slice(0, 4), alto: d.documentElement.scrollHeight };
}"""

JSON_OUT = os.path.join(OUT, "auditoria.json")
res = []
if DESDE > 0 and os.path.exists(JSON_OUT):                      # continuar una pasada cortada
    try: res = [r for r in json.load(open(JSON_OUT, encoding="utf-8")) if r["i"] < DESDE]
    except Exception: res = []


def uno(pg, errores, i, f):
    errores.clear()
    t0 = time.time()
    pg.goto(BASE + "#ej=" + urllib.parse.quote(f) + "&solo=1"); pg.reload(wait_until="networkidle")
    ultimo, quieto, m = -1, 0, {"vacio": True}
    for _ in range(90):                                          # espera a que el render deje de crecer
        pg.wait_for_timeout(1000)
        try: m = pg.evaluate(MARCAS)
        except Exception: continue
        n = m.get("largo", 0)
        quieto = quieto + 1 if n == ultimo and n > 0 else 0
        ultimo = n
        if quieto >= 3: break
    pg.screenshot(path=os.path.join(OUT, f"{i:02d}.png"))
    r = {"i": i, "ejemplo": f, "s": round(time.time() - t0, 1), **m, "errores_pagina": list(dict.fromkeys(errores))[:4]}
    r["mal"] = bool(r.get("vacio") or r.get("errs") or r.get("lineas") or r.get("awatif") or r["errores_pagina"])
    return r


with sync_playwright() as p:
    for a in range(DESDE, min(HASTA, len(EJ)), CADA):
        b = p.chromium.launch(args=["--enable-unsafe-swiftshader", "--use-angle=swiftshader"])
        pg = b.new_page(viewport={"width": 1100, "height": ALTO})
        errores = []
        pg.on("pageerror", lambda e: errores.append(str(e)[:200]))
        pg.on("console", lambda m: errores.append("console: " + m.text[:200]) if m.type == "error" else None)
        pg.goto(BASE, wait_until="networkidle"); pg.wait_for_timeout(8000)   # motor WASM cargado
        for i in range(a, min(a + CADA, HASTA, len(EJ))):
            f = EJ[i]
            try: r = uno(pg, errores, i, f)
            except Exception as ex:
                r = {"i": i, "ejemplo": f, "s": 0, "vacio": True, "errores_pagina": ["auditor: " + str(ex)[:160]], "mal": True}
            res.append(r)
            marca = "MAL " if r["mal"] else ("ok? " if r.get("dudas") else "ok  ")
            print(marca + f"{i:02d} {f[:70]}  ({r['s']} s)", flush=True)
            json.dump(res, open(JSON_OUT, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
        b.close()

# hojas de contacto: 8 por hoja (capturas altas), con el número encima
from PIL import Image, ImageDraw
pngs = [os.path.join(OUT, f"{r['i']:02d}.png") for r in res if os.path.exists(os.path.join(OUT, f"{r['i']:02d}.png"))]
for h in range(0, len(pngs), 8):
    lote = pngs[h:h + 8]; W, H = 480, 785
    hoja = Image.new("RGB", (W * 4, H * 2), "white"); d = ImageDraw.Draw(hoja)
    for k, pth in enumerate(lote):
        im = Image.open(pth); im.thumbnail((W, H)); x, y = (k % 4) * W, (k // 4) * H; hoja.paste(im, (x, y))
        d.rectangle([x, y, x + 60, y + 26], fill="black"); d.text((x + 6, y + 5), os.path.basename(pth)[:2], fill="yellow")
    hoja.save(os.path.join(OUT, f"_hoja_{h // 8:02d}.png"))
print(sum(r["mal"] for r in res), "con problemas de", len(res), "|", sum(1 for r in res if r.get("dudas") and not r["mal"]), "con «error» solo en la prosa")
