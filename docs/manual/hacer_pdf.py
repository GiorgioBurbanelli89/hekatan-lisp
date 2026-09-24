"""Manual en PDF: completo y solo la parte de dibujo estilo AutoCAD (#solo-dibujo)."""
import os, pathlib
from playwright.sync_api import sync_playwright
aqui = pathlib.Path(__file__).parent.resolve(); url = (aqui / "Manual_Hekatan_LISP.html").as_uri()
with sync_playwright() as p:
    b = p.chromium.launch()
    for sufijo, pdf in (("", "Manual_Hekatan_LISP.pdf"), ("#solo-dibujo", "Hekatan_LISP_Dibujo_estilo_AutoCAD.pdf")):
        pg = b.new_page(color_scheme="light"); pg.goto(url + sufijo); pg.wait_for_load_state("networkidle")
        pg.emulate_media(media="print")
        pg.pdf(path=str(aqui / pdf), format="A4", print_background=True, margin={"top": "12mm", "bottom": "12mm", "left": "10mm", "right": "10mm"})
        print(pdf, os.path.getsize(aqui / pdf) // 1024, "KB")
    b.close()
