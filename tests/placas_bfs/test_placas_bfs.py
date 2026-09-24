#!/usr/bin/env python3
"""Ejemplos 73–78 (placas BFS) contra el oráculo: CALCPAD corriendo el mismo modelo nudo a nudo
(tests/placas_bfs/calcpad/*.html, generados con oraculo_calcpad.py y oraculo_flat_slab.py).

Compara a 4 decimales todas las flechas y momentos (W_z, Mx, My) que Calcpad imprime, más la tabla
de convergencia del 78; y que cada hoja corra sin errores. Las tablas de Timoshenko están DENTRO de
cada hoja (tabla final con dif %).

Uso: python tests/placas_bfs/test_placas_bfs.py [--exe ruta]
"""
import argparse, os, re, subprocess, sys, tempfile, shutil
sys.stdout.reconfigure(encoding="utf-8")
AQUI = os.path.dirname(os.path.abspath(__file__))
RAIZ = os.path.normpath(os.path.join(AQUI, "..", ".."))
sys.path.insert(0, AQUI)
from leer_calcpad import oraculo, texto, nums  # noqa: E402

EXE = os.path.join(RAIZ, "bin", "Release", "net8.0-windows", "HekatanLisp.exe")
EJ = os.path.join(RAIZ, "ejemplos")
CASOS = {"73": "73_puntual", "74": "74_empotrada_16x24", "75": "75_una_direccion",
         "76": "76_voladizo", "77": "77_flat_slab_clsolve"}


def corre(exe, hoja):
    tmp = tempfile.mkdtemp(prefix="hkp_")
    out, dbg = os.path.join(tmp, "h.html"), os.path.join(tmp, "dbg.lisp")
    subprocess.run([exe, "--html", out, "--in", hoja], env=dict(os.environ, HK_NUM_DEBUG=dbg), timeout=300)
    vals, errs, sec, t = {}, {}, None, None
    for l in open(dbg, encoding="utf-8"):
        l = l.rstrip("\n")
        if l.startswith(";; ---- valores"): sec = "v"; continue
        if l.startswith(";; ---- errores"): sec = "e"; continue
        m = re.match(r";; ([\d.]+) s total", l)
        if m: t = float(m.group(1))
        if sec == "v":
            m = re.match(r";; (\d+) \[([^\]]*)\] (.*?) => (.*)$", l)
            if m: vals[m.group(3)] = m.group(4); vals.setdefault("@" + m.group(2), m.group(4))
        elif sec == "e":
            m = re.match(r";; (\d+) (.*)$", l)
            if m: errs[int(m.group(1))] = m.group(2)
    graf = open(out, encoding="utf-8").read().count("data:image/png;base64")
    shutil.rmtree(tmp, ignore_errors=True)
    return vals, errs, t, graf


def lit(s):
    s = s.strip()
    if s.startswith("(vector (vector"):
        return [[float(x) for x in r.split()] for r in re.findall(r"\(vector ([^()]*)\)", s)]
    if s.startswith("(vector"):
        return [float(x) for x in s[len("(vector"):-1].split()]
    return float(s)


def compara(nombre, cp, hk, res):
    """cp: filas de Calcpad (pueden venir truncadas con ⋯ → primeras + última); hk: matriz completa."""
    for r, fila in enumerate(cp):
        if r >= len(hk): break
        h = hk[r]
        pares = list(zip(fila, h)) if len(fila) == len(h) else list(zip(fila[:-1], h)) + [(fila[-1], h[-1])]
        for c, (a, b) in enumerate(pares):
            res.append((f"{nombre}[{r+1},{c+1}]", a, b))


def main():
    ap = argparse.ArgumentParser(); ap.add_argument("--exe", default=EXE); a = ap.parse_args()
    fallos = 0
    for num in ("73", "74", "75", "76", "77", "78"):
        hoja = next(os.path.join(EJ, f) for f in os.listdir(EJ) if f.startswith(num + " "))
        vals, errs, t, graf = corre(os.path.abspath(a.exe), hoja)
        res = []
        if num in CASOS:
            o = oraculo(os.path.join(AQUI, "calcpad", CASOS[num] + ".html"))
            for nom in ("W_z", "Mx", "My"):
                compara(nom, o[nom], lit(vals["transpose(" + nom + ")"]), res)
        else:
            C = lit(vals["C"])
            for k, n in enumerate((2, 4, 8, 16)):
                o = oraculo(os.path.join(AQUI, "calcpad", f"78_conv_{n}.html"))
                res += [(f"w_c {n}x{n}", o["w_c"], C[k][2]), (f"Mx_c {n}x{n}", o["Mx_c"], C[k][4])]
        malos = [(n, c, h) for n, c, h in res if abs(round(c, 4) - round(h, 4)) > 1.00001e-4]
        ok = not malos and not errs
        fallos += not ok
        print(f"[{'OK ' if ok else 'MAL'}] {num}: {len(res)} valores de Calcpad, distintos a 4 decimales: {len(malos)}, "
              f"errores en la hoja: {len(errs)}, gráficas: {graf}, {t} s")
        for m in malos[:10]: print("     ", m)
        for k, e in list(errs.items())[:5]: print("      línea", k, e)
    print("TODO OK" if not fallos else f"FALLAN {fallos}")
    sys.exit(1 if fallos else 0)


if __name__ == "__main__":
    main()
