#!/usr/bin/env python3
"""Abre cada archivo que escribió (guardar "x.ext") y dice si está sano.
  DXF → ezdxf.readfile + audit · DWG → acadrust (hekatan_dwg.read_dwg: se lee de vuelta y se cuentan entidades)
  PDF → PyMuPDF a PNG · SVG → Chromium (Playwright) a PNG.   Los PNG quedan junto al archivo para MIRARLOS.
Uso: python tests/autolisp/verificar_formatos.py "C:/…/dibujos/zapata Z-1"   (sin extensión)
"""
import os, shutil, subprocess, sys
from collections import Counter
sys.stdout.reconfigure(encoding="utf-8")
base = sys.argv[1]
TMP = "C:/Temp/hkal"; os.makedirs(TMP, exist_ok=True)

if os.path.exists(base + ".dxf"):
    import ezdxf
    doc = ezdxf.readfile(base + ".dxf"); a = doc.audit()
    print(f"DXF {doc.dxfversion}: {len(a.errors)} errores, {len(a.fixes)} arreglos ·", dict(Counter(e.dxftype() for e in doc.modelspace())))

if os.path.exists(base + ".dwg"):
    # DWG leído de vuelta con acadrust (hekatan-dwg, el mismo que lo escribe): sin AutoCAD
    import json, hekatan_dwg
    d = hekatan_dwg.read_dwg(base + ".dwg")
    d = json.loads(d) if isinstance(d, str) else d
    ents = d.get("entities", d.get("entidades", [])) if isinstance(d, dict) else d
    tipos = Counter((e.get("type") or e.get("tipo") or e.get("0") or "?") if isinstance(e, dict) else "?" for e in ents)
    print("DWG leído por acadrust:", len(ents), "entidades ·", dict(tipos))

if os.path.exists(base + ".pdf"):
    import fitz
    d = fitz.open(base + ".pdf"); pg = d[0]
    pg.get_pixmap(dpi=200).save(base + "_pdf.png")
    print(f"PDF: {len(d)} página, {pg.rect.width:.0f}×{pg.rect.height:.0f} pt, texto: {pg.get_text()[:80]!r} → {base}_pdf.png")

if os.path.exists(base + ".svg"):
    from playwright.sync_api import sync_playwright
    with sync_playwright() as p:
        b = p.chromium.launch(); pg = b.new_page(device_scale_factor=2)
        pg.goto("file:///" + os.path.abspath(base + ".svg").replace("\\", "/"))
        pg.locator("svg").screenshot(path=base + "_svg.png"); b.close()
    print(f"SVG → {base}_svg.png")
