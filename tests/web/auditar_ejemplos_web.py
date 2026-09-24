"""Audita TODOS los ejemplos de Hekatan LISP web (sitio público o local).

    python tests/web/auditar_ejemplos_web.py [publico|http://localhost:8080/] [filtro]

Por ejemplo: carga #ej=<archivo>&solo=1, espera el cálculo, y apunta
  - errores de página/consola,
  - marcas de error en el render (.hk-dib-err, .hk-al-errl, «Error», «⚠», NaN, «no definid…»),
  - render casi vacío,
y guarda un PNG por ejemplo + hojas de contacto para MIRAR (tests/web/salida/).
"""
import json, os, re, sys, time, urllib.parse
from playwright.sync_api import sync_playwright

AQUI = os.path.dirname(os.path.abspath(__file__))
RAIZ = os.path.abspath(os.path.join(AQUI, "..", ".."))
BASE = sys.argv[1] if len(sys.argv) > 1 and sys.argv[1] != "publico" else "https://giorgioburbanelli89.github.io/hekatan-lisp/"
FILTRO = sys.argv[2] if len(sys.argv) > 2 else ""
OUT = os.path.join(AQUI, "salida"); os.makedirs(OUT, exist_ok=True)
EJ = sorted(f for f in os.listdir(os.path.join(RAIZ, "web", "HekatanLispWeb", "wwwroot", "ejemplos")) if f.endswith(".lisp") and FILTRO in f)

MARCAS = r"""() => {
  const fr = document.querySelectorAll('iframe'); let d = null;
  for (const f of fr) { try { if (f.contentDocument?.body?.innerText?.length > 20) d = f.contentDocument; } catch {} }
  if (!d) return { vacio: true, txt: '' };
  const t = d.body.innerText;
  const errs = [...d.querySelectorAll('.hk-dib-err, .hk-al-errl')].map(e => e.innerText.slice(0, 160));
  const lineas = t.split('\n').filter(l => /\berror\b|⚠|no definid|undefined|\bNaN\b|no se pudo|excepci[oó]n|unbound|not a number/i.test(l)).map(l => l.slice(0, 160));
  return { vacio: t.trim().length < 40, largo: t.length, errs, lineas: lineas.slice(0, 6), alto: d.documentElement.scrollHeight };
}"""

res = []
with sync_playwright() as p:
    b = p.chromium.launch(args=["--enable-unsafe-swiftshader", "--use-angle=swiftshader"])
    pg = b.new_page(viewport={"width": 1100, "height": 900})
    errores = []
    pg.on("pageerror", lambda e: errores.append(str(e)[:200]))
    pg.on("console", lambda m: errores.append("console: " + m.text[:200]) if m.type == "error" else None)
    pg.goto(BASE, wait_until="networkidle"); pg.wait_for_timeout(8000)   # motor WASM cargado una vez
    for i, f in enumerate(EJ):
        errores.clear()
        t0 = time.time()
        pg.goto(BASE + "#ej=" + urllib.parse.quote(f) + "&solo=1"); pg.reload(wait_until="networkidle")
        # espera a que el render deje de crecer (hojas largas tardan)
        ultimo, quieto = -1, 0
        for _ in range(90):
            pg.wait_for_timeout(1000)
            try: m = pg.evaluate(MARCAS)
            except Exception: continue
            n = m.get("largo", 0)
            quieto = quieto + 1 if n == ultimo and n > 0 else 0
            ultimo = n
            if quieto >= 3: break
        png = os.path.join(OUT, f"{i:02d}.png"); pg.screenshot(path=png)
        r = {"i": i, "ejemplo": f, "s": round(time.time() - t0, 1), **m, "errores_pagina": list(dict.fromkeys(errores))[:4]}
        r["mal"] = bool(r.get("vacio") or r.get("errs") or r.get("lineas") or r["errores_pagina"])
        res.append(r); print(("MAL " if r["mal"] else "ok  ") + f"{i:02d} {f[:70]}  ({r['s']} s)", flush=True)
    b.close()
json.dump(res, open(os.path.join(OUT, "auditoria.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)

# hojas de contacto: 12 por hoja, con el número encima
from PIL import Image, ImageDraw
pngs = [os.path.join(OUT, f"{r['i']:02d}.png") for r in res]
for h in range(0, len(pngs), 12):
    lote = pngs[h:h + 12]; W, H = 550, 450
    hoja = Image.new("RGB", (W * 4, H * 3), "white"); d = ImageDraw.Draw(hoja)
    for k, pth in enumerate(lote):
        im = Image.open(pth); im.thumbnail((W, H)); x, y = (k % 4) * W, (k // 4) * H; hoja.paste(im, (x, y))
        d.rectangle([x, y, x + 60, y + 26], fill="black"); d.text((x + 6, y + 5), os.path.basename(pth)[:2], fill="yellow")
    hoja.save(os.path.join(OUT, f"_hoja_{h // 12:02d}.png"))
print(sum(r["mal"] for r in res), "con problemas de", len(res))
