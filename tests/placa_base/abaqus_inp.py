# -*- coding: utf-8 -*-
"""Modelo de Abaqus de la placa base (mismos nudos, mismas cáscaras S4, mismos muelles no lineales y mismas cargas que la hoja).

    python abaqus_inp.py shs|rhs   → abq_<caso>/pb.inp   (se corre con:  C:\\SIMULIA\\Commands\\abaqus.bat job=pb input=pb.inp interactive)
Los datos salen de params_<caso>.json (el mismo que usa gen_hoja.py). Salidas: U de todos los nudos y las fuerzas nodales (NFORC)
de la fila de elementos del tubo pegada a la placa (la soldadura).
"""
import json, os, sys, math

AQUI = os.path.dirname(os.path.abspath(__file__))
caso = sys.argv[1] if len(sys.argv) > 1 else "shs"
P = json.load(open(os.path.join(AQUI, "params_%s.json" % caso)))
xs, ys, nz, H = P["xs"], P["ys"], P["nz"], P["H"]
nx = len(xs)
np_ = nx * nx
pi_x = [3, 4, 5, 6, 7, 7, 7, 7, 7, 6, 5, 4, 3, 3, 3, 3]
pi_y = [3, 3, 3, 3, 3, 4, 5, 6, 7, 7, 7, 7, 7, 6, 5, 4]
nn = np_ + 16 * nz
X = [(0, 0, 0)] * nn
for j in range(nx):
    for i in range(nx):
        X[j * nx + i] = (xs[i], ys[j], 0.0)
Pn = [(pi_y[k] - 1) * nx + pi_x[k] for k in range(16)]
for l in range(1, nz + 1):
    for k in range(16):
        X[np_ + (l - 1) * 16 + k] = (xs[pi_x[k] - 1], ys[pi_y[k] - 1], H * l / nz)


def tubo(l, k):
    return Pn[k - 1] if l == 0 else np_ + (l - 1) * 16 + k


E = []
for j in range(1, nx):
    for i in range(1, nx):
        q = (j - 1) * nx + i
        E.append([q, q + 1, q + nx + 1, q + nx])
for l in range(1, nz + 1):
    for k in range(1, 17):
        k2 = k % 16 + 1
        E.append([tubo(l - 1, k), tubo(l - 1, k2), tubo(l, k2), tubo(l, k)])
ne_p = (nx - 1) ** 2

kc = []
for j in range(1, nx + 1):
    for i in range(1, nx + 1):
        i0, i1, j0, j1 = max(i - 1, 1), min(i + 1, nx), max(j - 1, 1), min(j + 1, nx)
        kc.append(P["k_c"] * (xs[i1 - 1] - xs[i0 - 1]) / 2 * (ys[j1 - 1] - ys[j0 - 1]) / 2)
nb = [(2 - 1) * nx + 2, (2 - 1) * nx + 8, (8 - 1) * nx + 2, (8 - 1) * nx + 8]

px = [xs[pi_x[k] - 1] for k in range(16)]
py = [ys[pi_y[k] - 1] for k in range(16)]
ell = []
for k in range(16):
    d0 = math.hypot(px[k] - px[k - 1], py[k] - py[k - 1])
    d2 = math.hypot(px[k] - px[(k + 1) % 16], py[k] - py[(k + 1) % 16])
    ell.append((d0 + d2) / 2)
A_t = sum(e * P["t_c"] for e in ell)
I_t = sum(ell[k] * P["t_c"] * py[k] ** 2 for k in range(16))
F = {}
for k in range(16):
    q = np_ + (nz - 1) * 16 + k + 1
    F[q] = (-P["N"] / A_t - P["M"] * py[k] / I_t) * ell[k] * P["t_c"]

o = []
w = o.append
w("*HEADING")
w("Placa base de columna tubular: cáscaras S4, hormigón solo compresión, pernos solo tracción")
w("*NODE")
for q, (x, y, z) in enumerate(X, 1):
    w("%d, %.10g, %.10g, %.10g" % (q, x, y, z))
w("*ELEMENT, TYPE=S4, ELSET=PLATE")
for e in range(ne_p):
    w("%d, %s" % (e + 1, ", ".join(str(v) for v in E[e])))
w("*ELEMENT, TYPE=S4, ELSET=TUBO")
for e in range(ne_p, len(E)):
    w("%d, %s" % (e + 1, ", ".join(str(v) for v in E[e])))
w("*ELSET, ELSET=TUBO1, GENERATE")
w("%d, %d, 1" % (ne_p + 1, ne_p + 16))
w("*MATERIAL, NAME=ACERO")
w("*ELASTIC")
w("%.10g, %.10g" % (P["E"], P["nu"]))
w("*SHELL SECTION, ELSET=PLATE, MATERIAL=ACERO")
w("%.10g, 5" % P["t_p"])
w("*SHELL SECTION, ELSET=TUBO, MATERIAL=ACERO")
w("%.10g, 5" % P["t_c"])
eid = 10000
for q in range(1, np_ + 1):
    w("*ELEMENT, TYPE=SPRING1, ELSET=C%d" % q)
    w("%d, %d" % (eid + q, q))
    w("*SPRING, ELSET=C%d, NONLINEAR" % q)
    w("3")
    w("%.10g, -1.0" % (-kc[q - 1]))
    w("0.0, 0.0")
    w("0.0, 1.0")
for m, q in enumerate(nb, 1):
    w("*ELEMENT, TYPE=SPRING1, ELSET=B%d" % m)
    w("%d, %d" % (eid + 1000 + m, q))
    w("*SPRING, ELSET=B%d, NONLINEAR" % m)
    w("3")
    w("0.0, -1.0")
    w("0.0, 0.0")
    w("%.10g, 1.0" % P["k_b"])
w("*NSET, NSET=TODOS, GENERATE")
w("1, %d, 1" % nn)
w("*BOUNDARY")
w("%d, 1, 2" % 41)
w("%d, 2, 2" % 45)
w("*STEP, NAME=CARGA, NLGEOM=NO, INC=200")
w("*STATIC")
w("0.1, 1.0, 1e-06, 1.0")
w("*CLOAD")
for q, f in sorted(F.items()):
    w("%d, 3, %.12g" % (q, f))
w("*NODE PRINT, NSET=TODOS, FREQUENCY=1")
w("U")
w("*EL PRINT, ELSET=TUBO1, FREQUENCY=1")
w("NFORC")
w("*END STEP")
d = os.path.join(AQUI, "abq_%s" % caso)
os.makedirs(d, exist_ok=True)
open(os.path.join(d, "pb.inp"), "w", encoding="utf8").write("\n".join(o) + "\n")
json.dump({"F": {str(k): v for k, v in F.items()}, "kc": kc, "nb": nb, "ell": ell}, open(os.path.join(d, "datos.json"), "w"))
print("pb.inp escrito en", d, ":", nn, "nudos,", len(E), "cáscaras,", np_ + 4, "muelles")
