#!/usr/bin/env python3
"""Abre cada archivo que escribió (guardar "x.ext") y dice si está sano.
  DXF → ezdxf.readfile + audit · DWG → AutoCAD 2027 (accoreconsole: AUDIT + DXFOUT, contar entidades)
  PDF → PyMuPDF a PNG · SVG → Chromium (Playwright) a PNG.   Los PNG quedan junto al archivo para MIRARLOS.
Uso: python tests/autolisp/verificar_formatos.py "C:/…/dibujos/zapata Z-1"   (sin extensión)
"""
import os, shutil, subprocess, sys
from collections import Counter
sys.stdout.reconfigure(encoding="utf-8")
base = sys.argv[1]
TMP = "C:/Temp/hkal"; os.makedirs(TMP, exist_ok=True)
ACAD = r"C:\Program Files\Autodesk\AutoCAD 2027\accoreconsole.exe"

if os.path.exists(base + ".dxf"):
    import ezdxf
    doc = ezdxf.readfile(base + ".dxf"); a = doc.audit()
    print(f"DXF {doc.dxfversion}: {len(a.errors)} errores, {len(a.fixes)} arreglos ·", dict(Counter(e.dxftype() for e in doc.modelspace())))

if os.path.exists(base + ".dwg"):
    import ezdxf
    shutil.copy(base + ".dwg", TMP + "/v.dwg")
    out = TMP + "/v_dwg.dxf"
    if os.path.exists(out): os.remove(out)
    open(TMP + "/v.scr", "w").write(f"FILEDIA\n0\n_.AUDIT\nN\n_.DXFOUT\n{out}\n16\n_.QUIT\nY\n\n")
    r = subprocess.run([ACAD, "/i", TMP.replace("/", "\\") + "\\v.dwg", "/s", TMP.replace("/", "\\") + "\\v.scr"], capture_output=True, timeout=600)
    log = r.stdout.decode("utf-16-le", "ignore")
    aud = [l.strip() for l in log.replace("\r", "").split("\n") if "errors found" in l.lower() or "errores" in l.lower()]
    if os.path.exists(out):
        d2 = ezdxf.readfile(out)
        print("DWG abierto por AutoCAD:", aud[-1] if aud else "(AUDIT sin línea de resumen)", "·", dict(Counter(e.dxftype() for e in d2.modelspace())))
    else:
        print("DWG: AutoCAD NO lo abrió\n", log[-1500:])

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
