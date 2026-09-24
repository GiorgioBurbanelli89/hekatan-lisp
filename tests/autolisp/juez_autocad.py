#!/usr/bin/env python3
"""AutoCAD como JUEZ del dibujo AutoLISP de Hekatan LISP.

Para cada bloque `#autolisp(…, autocad = si)` de los ejemplos:
  1. el código del bloque se escribe TAL CUAL en un .lsp;
  2. accoreconsole.exe (AutoCAD 2027, sin ventana) lo carga y saca el dibujo con DXFOUT;
  3. el mismo código corre en el motor de Hekatan LISP (SBCL + engine.lisp) y vuelca sus entidades;
  4. se comparan entidad por entidad, en orden: tipo, capa y coordenadas x y z (tolerancia 1e-9).

Uso: python tests/autolisp/juez_autocad.py [--acad RUTA] [ejemplo.lisp …]
Trampas de accoreconsole (memoria reference_dxf_a_dwg_accoreconsole): rutas SIN espacios (C:/Temp/hkal),
SECURELOAD 0 para cargar un .lsp propio, línea en blanco al final del .scr.
"""
import argparse, glob, os, re, subprocess, sys
import ezdxf
sys.stdout.reconfigure(encoding="utf-8")

AQUI = os.path.dirname(os.path.abspath(__file__))
RAIZ = os.path.normpath(os.path.join(AQUI, "..", ".."))
TMP = "C:/Temp/hkal"
FS, US = "\x1c", "\x1f"
TOL = 1e-9


def bloques(ruta):
    """Bloques #autolisp(…autocad = si…) … #fin del ejemplo: (titulo, código)."""
    out, cur, tit = [], None, None
    for l in open(ruta, encoding="utf-8").read().split("\n"):
        m = re.match(r"^\s*#\s*autolisp\s*\((.*)\)\s*$", l, re.I)
        if m:
            cur = [] if re.search(r"autocad\s*=\s*si", m.group(1), re.I) else None
            tit = m.group(1)
            continue
        if re.match(r"^\s*#\s*fin\s*$", l, re.I):
            if cur is not None: out.append((tit, "\n".join(cur)))
            cur = None
            continue
        if cur is not None: cur.append(l)
    return out


def ascii_lsp(code):
    return "".join(c if ord(c) < 128 else "?" for c in code)


def hekatan(code):
    eng = os.path.join(RAIZ, "engine.lisp").replace("\\", "/")
    esc = code.replace("\\", "\\\\").replace('"', '\\"')
    prog = f'(load "{eng}")\n(setf *print-case* :downcase)\n(hk-al-nuevo)\n(hk-al-ejecuta "{esc}")\n(hk-al-volcar "")\n'
    f = os.path.join(TMP, "hk_run.lisp")
    open(f, "w", encoding="utf-8").write(prog)
    r = subprocess.run(["sbcl", "--script", f], capture_output=True, text=True, encoding="utf-8")
    ents = []
    for l in r.stdout.split("\n"):
        if l.startswith(FS + "E"):
            d = []
            for kv in l.split(US)[1:]:
                k, _, v = kv.partition("=")
                d.append((int(k), v))
            ents.append(d)
    salida = "\n".join(l for l in r.stdout.split("\n") if not l.startswith(FS))
    return ents, salida


def pt(s):
    v = [float(x) for x in s.split(",")]
    return (v + [0.0, 0.0, 0.0])[:3]


def geo_hk(d):
    g = dict()
    for k, v in d:
        g.setdefault(k, []).append(v)
    t = g[0][0]
    capa = g.get(8, ["0"])[0]
    if t == "LINE": P = [pt(g[10][0]), pt(g[11][0])]
    elif t in ("POINT", "TEXT", "MTEXT"): P = [pt(g[10][0])]
    elif t in ("3DFACE", "SOLID"): P = [pt(g[c][0]) for c in (10, 11, 12, 13)]
    elif t == "POLYLINE": P = [pt(v) for v in g.get(1011, [])]
    elif t == "LWPOLYLINE": P = [pt(v) for v in g[10]]
    elif t in ("CIRCLE", "ARC"): P = [pt(g[10][0]), [float(g[40][0]), 0, 0]]
    elif t == "DIMENSION": P = [pt(g[13][0]), pt(g[14][0])]
    else: P = []
    return t, capa, P


def geo_acad(e):
    t = e.dxftype(); capa = e.dxf.layer
    if t == "LINE": P = [list(e.dxf.start), list(e.dxf.end)]
    elif t == "POINT": P = [list(e.dxf.location)]
    elif t in ("TEXT", "MTEXT"): P = [list(e.dxf.insert)]
    elif t in ("3DFACE", "SOLID"): P = [list(e.dxf.get(a)) for a in ("vtx0", "vtx1", "vtx2", "vtx3")]
    elif t == "POLYLINE": P = [list(v.dxf.location) for v in e.vertices]
    elif t == "LWPOLYLINE": P = [[p[0], p[1], 0.0] for p in e.get_points("xy")]
    elif t in ("CIRCLE", "ARC"): P = [list(e.dxf.center), [e.dxf.radius, 0, 0]]
    elif t == "DIMENSION": P = [list(e.dxf.defpoint2), list(e.dxf.defpoint3)]
    else: P = []
    return t, capa, [[float(c) for c in p] for p in P]


def acad(code, n, exe):
    os.makedirs(TMP, exist_ok=True)
    lsp, dxf, scr = f"{TMP}/b{n}.lsp", f"{TMP}/b{n}_acad.dxf", f"{TMP}/b{n}.scr"
    open(lsp, "w", encoding="ascii").write(ascii_lsp(code) + "\n")
    if os.path.exists(dxf): os.remove(dxf)
    open(scr, "w", encoding="ascii").write(
        f'SECURELOAD\n0\nFILEDIA\n0\n(load "{lsp}")\n_.DXFOUT\n{dxf}\n16\n_.QUIT\nY\n\n')
    r = subprocess.run([exe, "/s", scr.replace("/", "\\")], capture_output=True, timeout=600, cwd=TMP)
    log = r.stdout.decode("utf-16-le", "ignore") if r.stdout[:2] != b"" else ""
    if not os.path.exists(dxf):
        raise RuntimeError("AutoCAD no escribió el DXF:\n" + log[-2000:])
    doc = ezdxf.readfile(dxf)
    return [geo_acad(e) for e in doc.modelspace()], log


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--acad", default=r"C:\Program Files\Autodesk\AutoCAD 2027\accoreconsole.exe")
    ap.add_argument("hojas", nargs="*")
    a = ap.parse_args()
    hojas = a.hojas or sorted(glob.glob(os.path.join(RAIZ, "ejemplos", "*.lisp")))
    n = 0; fallos = 0
    for h in hojas:
        for tit, code in bloques(h):
            n += 1
            hk, salida = hekatan(code)
            ac, log = acad(code, n, a.acad)
            hk = [geo_hk(d) for d in hk]
            print(f"\n== {os.path.basename(h)} · bloque {n}: Hekatan {len(hk)} entidades, AutoCAD {len(ac)}")
            if len(hk) != len(ac): fallos += 1; print("   ✗ distinto número de entidades")
            dmax = 0.0; malos = 0
            for i, (x, y) in enumerate(zip(hk, ac)):
                if x[0] != y[0] or x[1].upper() != y[1].upper() or len(x[2]) != len(y[2]):
                    malos += 1; print(f"   ✗ #{i}: Hekatan {x[0]}/{x[1]}/{len(x[2])} pts · AutoCAD {y[0]}/{y[1]}/{len(y[2])} pts"); continue
                for p, q in zip(x[2], y[2]):
                    dmax = max(dmax, max(abs(u - v) for u, v in zip(p, q)))
            tipos = {}
            for x in hk: tipos[x[0]] = tipos.get(x[0], 0) + 1
            print(f"   tipos: {tipos}")
            print(f"   diferencia máxima de coordenadas: {dmax:.3e}  ({'✓' if dmax <= TOL else '✗'} tol {TOL})")
            if malos or dmax > TOL: fallos += 1
    print(f"\n{n - fallos}/{n} bloques iguales a AutoCAD")
    sys.exit(1 if fallos else 0)


if __name__ == "__main__":
    main()
