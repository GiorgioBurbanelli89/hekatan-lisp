"""Marcas del manual sobre una captura: marco (rectángulo o círculo) + número FUERA del marco + leyenda debajo.

Las posiciones NO se ponen a ojo: las cajas salen de la ventana real (UI Automation, --ctl layout,
getBoundingClientRect) en píxeles de la captura.

El número se coloca solo: se prueban sitios alrededor del marco (encima, a la izquierda, a la derecha,
debajo; deslizándose a lo largo del borde) y se queda el primero que
  · no pisa ninguna caja de texto medida (`textos`),
  · no pisa otro número ni la línea de otro marco,
  · y debajo no tiene letras (píxeles de mucho contraste con el fondo < 1 %).
Si ninguno sirve, avisa por consola (el PNG hay que mirarlo igual).
"""
from PIL import Image, ImageDraw, ImageFont

ROJO, AZUL, VERDE, ORO, MORADO = (215, 50, 40), (25, 100, 215), (20, 140, 60), (205, 125, 0), (140, 60, 190)


def _fuente(nombre, t):
    try: return ImageFont.truetype("C:/Windows/Fonts/" + nombre, int(t))
    except Exception: return ImageFont.load_default()


def _choca(a, b):
    return not (a[2] <= b[0] or b[2] <= a[0] or a[3] <= b[1] or b[3] <= a[1])


def _letras(gris, c, W, H):
    """Fracción de píxeles «de letra» (lejos del fondo típico) dentro de la caja c."""
    x0, y0, x1, y1 = [int(round(v)) for v in c]
    x0, y0, x1, y1 = max(0, x0), max(0, y0), min(W, x1), min(H, y1)
    if x1 <= x0 or y1 <= y0: return 1.0
    reg = gris.crop((x0, y0, x1, y1)); h = reg.histogram(); n = sum(h)
    fondo = max(range(256), key=lambda i: h[i])
    malos = sum(h[i] for i in range(256) if abs(i - fondo) > 80)
    return malos / n


def anotar(ruta_in, ruta_out, marcas, textos=(), escala=1.5, cols=2, leyenda=True, margen=0, ancho_final=None, recorte=None):
    """marcas: [{"caja": (x0,y0,x1,y1), "n": 1, "texto": "…", "color": ROJO, "tipo": "rect"|"circ",
                 "pad": 3, "pref": ["arr", "izq", "der", "abj", "dentro"], "sin_leyenda": False}]
       textos: cajas de texto medidas que el número NO debe tapar.
       margen: borde blanco alrededor (para que quepan los números de lo que toca el borde)."""
    im = Image.open(ruta_in).convert("RGB")
    if recorte:   # solo la zona que se explica; las cajas pasan a coordenadas del recorte
        rx, ry = recorte[0], recorte[1]; im = im.crop(recorte)
        marcas = [dict(m, caja=(m["caja"][0] - rx, m["caja"][1] - ry, m["caja"][2] - rx, m["caja"][3] - ry)) for m in marcas]
        if "badge" in str(marcas): marcas = [dict(m, badge=(m["badge"][0] - rx, m["badge"][1] - ry)) if "badge" in m else m for m in marcas]
        cw, ch = im.size   # lo que queda fuera del recorte no se ve: no cuenta
        textos = [(max(0, t[0] - rx), max(0, t[1] - ry), min(cw, t[2] - rx), min(ch, t[3] - ry)) for t in textos]
        textos = [t for t in textos if t[2] > t[0] and t[3] > t[1]]
    if margen:
        base = Image.new("RGB", (im.width + 2 * margen, im.height + 2 * margen), (255, 255, 255)); base.paste(im, (margen, margen)); im = base
    W, H = im.size; gris = im.convert("L")
    r = round(13 * escala); lw = max(3, round(2 * escala)); g = round(3 * escala) + 4
    fN = _fuente("segoeuib.ttf", 17 * escala); fT = _fuente("segoeui.ttf", 15 * escala)
    textos = [tuple(v + margen for v in t) for t in textos]
    for m in marcas:
        x0, y0, x1, y1 = [v + margen for v in m["caja"]]; p = m.get("pad", 3)
        m["_c"] = (x0 - p, y0 - p, x1 + p, y1 + p)
    lineas = []   # franjas de los marcos (para que un número no se ponga encima de la línea de otro)
    for m in marcas:
        a, b, c, d = m["_c"]; e = lw + 2
        lineas += [(a - 2, b - 2, c + 2, b + e), (a - 2, d - e, c + 2, d + 2), (a - 2, b - 2, a + e, d + 2), (c - e, b - 2, c + 2, d + 2)]
    puestos = []
    d = ImageDraw.Draw(im)
    for m in marcas:
        col = m.get("color", ROJO); a, b, c, dd = m["_c"]
        if m.get("tipo", "rect") == "circ": d.ellipse([a, b, c, dd], outline=col, width=lw)
        else: d.rounded_rectangle([a, b, c, dd], radius=round(4 * escala), outline=col, width=lw)
    for m in marcas:
        if m.get("n") is None: continue
        a, b, c, dd = m["_c"]
        cands = []
        paso = r
        def desliza(i0, i1):
            if i1 < i0: mm = (i0 + i1) / 2; return [mm, mm + r / 2, mm - r / 2, mm + r, mm - r]
            vals = []; v = i0
            while v <= i1: vals.append(v); v += paso
            return vals
        for lado in m.get("pref", ["arr", "izq", "der", "abj", "dentro"]):
            if lado == "arr": cands += [(x, b - g - r) for x in desliza(a + r, c - r)]
            elif lado == "abj": cands += [(x, dd + g + r) for x in desliza(a + r, c - r)]
            elif lado == "izq": cands += [(a - g - r, y) for y in sorted(desliza(b + r, dd - r), key=lambda y: abs(y - (b + dd) / 2))]
            elif lado == "der": cands += [(c + g + r, y) for y in sorted(desliza(b + r, dd - r), key=lambda y: abs(y - (b + dd) / 2))]
            elif lado == "esq": cands += [(a - g - r, b - g - r), (c + g + r, b - g - r), (a - g - r, dd + g + r), (c + g + r, dd + g + r)]
            elif lado == "dentro":
                cands += [(x, b + lw + g + r) for x in desliza(a + lw + g + r, c - lw - g - r)]
                cands += [(a + lw + g + r, y) for y in desliza(b + lw + g + r, dd - lw - g - r)]
        if "badge" in m: cands = [tuple(v + margen for v in m["badge"])] + cands
        mejor = None; por = {}
        def libre(cx, cy):
            cb = (cx - r - 2, cy - r - 2, cx + r + 2, cy + r + 2)
            if cb[0] < 0 or cb[1] < 0 or cb[2] > W or cb[3] > H: por["borde"] = por.get("borde", 0) + 1; return False
            if any(_choca(cb, t) for t in textos): por["texto"] = [t for t in textos if _choca(cb, t)][:2]; return False
            if any(_choca(cb, q) for q in puestos): por["número"] = por.get("número", 0) + 1; return False
            if any(_choca(cb, l) for l in lineas): por["línea"] = por.get("línea", 0) + 1; return False
            if _letras(gris, cb, W, H) > 0.01: por["letras"] = por.get("letras", 0) + 1; return False
            return True
        if m.get("forzar") and "badge" in m: mejor = tuple(v + margen for v in m["badge"])
        import os as _os
        for (cx, cy) in ([] if mejor else cands):
            if libre(cx, cy): mejor = (cx, cy); break
            if _os.environ.get("HK_DEBUG") == str(m["n"]): print("   cand", (round(cx), round(cy)), dict(por), "caja", [round(v) for v in m["_c"]])
        guia = None
        if mejor is None and m.get("guia", True):
            # más lejos, con una línea guía hasta el marco (la línea no debe cruzar letras)
            mx, my = (a + c) / 2, (b + dd) / 2
            dirs = {"arr": (0, -1), "abj": (0, 1), "izq": (-1, 0), "der": (1, 0)}
            orden = [l for l in m.get("pref", []) if l in dirs] + [l for l in ("arr", "abj", "der", "izq") if l not in m.get("pref", [])]
            for paso_k in range(1, 14):
                for l in orden:
                    ux, uy = dirs[l]; dist = g + r + paso_k * 1.4 * r
                    px, py = (mx if ux == 0 else (c if ux > 0 else a)), (my if uy == 0 else (dd if uy > 0 else b))
                    cx, cy = px + ux * dist, py + uy * dist
                    if not libre(cx, cy): continue
                    seg = [(px + (cx - px) * t / 20, py + (cy - py) * t / 20) for t in range(1, 20)]
                    if any(t[0] <= sx <= t[2] and t[1] <= sy <= t[3] for sx, sy in seg for t in textos): continue
                    otros = [o["_c"] for o in marcas if o is not m]   # la guía no atraviesa otro marco
                    if any(o[0] <= sx <= o[2] and o[1] <= sy <= o[3] for sx, sy in seg for o in otros): continue
                    mejor = (cx, cy); guia = (px, py); break
                if mejor: break
        if mejor is None:
            print(f"  ! número {m['n']}: sin sitio libre junto al marco {por}; va en la esquina de arriba a la izquierda")
            mejor = (a - g - r, b - g - r) if a - g - 2 * r > 0 and b - g - 2 * r > 0 else (a + lw + g + r, b + lw + g + r)
        cx, cy = mejor; col = m.get("color", ROJO)
        puestos.append((cx - r - 2, cy - r - 2, cx + r + 2, cy + r + 2))
        if guia: d.line([guia, (cx, cy)], fill=col, width=max(2, lw - 1))
        d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=col, outline=(255, 255, 255), width=max(2, lw // 2))
        t = str(m["n"]); tw = d.textlength(t, font=fN); bb = d.textbbox((0, 0), t, font=fN)
        d.text((cx - tw / 2, cy - (bb[1] + bb[3]) / 2), t, font=fN, fill=(255, 255, 255))
    if leyenda:
        items = [m for m in marcas if m.get("n") is not None and not m.get("sin_leyenda")]
        if items:
            filas = (len(items) + cols - 1) // cols; hf = round(26 * escala); lwc = W // cols
            base = Image.new("RGB", (W, H + round(12 * escala) + filas * hf), (255, 255, 255)); base.paste(im, (0, 0))
            im = base; d = ImageDraw.Draw(im)
            for k, m in enumerate(items):
                x = round(10 * escala) + (k // filas) * lwc; y = H + round(8 * escala) + (k % filas) * hf
                cx, cy = x + r, y + hf // 2 - 1
                d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=m.get("color", ROJO))
                t = str(m["n"]); tw = d.textlength(t, font=fN); bb = d.textbbox((0, 0), t, font=fN)
                d.text((cx - tw / 2, cy - (bb[1] + bb[3]) / 2), t, font=fN, fill=(255, 255, 255))
                bb = d.textbbox((0, 0), m["texto"], font=fT)
                d.text((x + 2 * r + round(8 * escala), cy - (bb[1] + bb[3]) / 2), m["texto"], font=fT, fill=(30, 30, 30))
                if d.textlength(m["texto"], font=fT) + 2 * r + 8 * escala > lwc - 10 * escala:
                    print(f"  ! leyenda {m['n']} demasiado larga para su columna")
    if ancho_final and im.width > ancho_final:
        im = im.resize((ancho_final, round(im.height * ancho_final / im.width)), Image.LANCZOS)
    im.save(ruta_out, optimize=True)
    return im.size
