# -*- coding: utf-8 -*-
"""Modelo de Abaqus de la placa base (mismos nudos, mismas cáscaras S4, mismos muelles no lineales y mismas cargas que la hoja 144).

    python abaqus_inp.py            → pb.inp en abq/   (se corre con:  C:\\SIMULIA\\Commands\\abaqus.bat job=pb input=pb.inp interactive)
Los datos salen de params.json (el mismo que usa gen_hoja.py).
"""
import json, os, math

AQUI = os.path.dirname(os.path.abspath(__file__))
P = json.load(open(os.path.join(AQUI, "params.json")))
xs, nz, H = P["xs"], P["nz"], P["H"]
nx = len(xs)
np_ = nx * nx
pi_x = [3, 4, 5, 6, 7, 7, 7, 7, 7, 6, 5, 4, 3, 3, 3, 3]
pi_y = [3, 3, 3, 3, 3, 4, 5, 6, 7, 7, 7, 7, 7, 6, 5, 4]
nn = np_ + 16 * nz
X = [(0, 0, 0)] * nn
for j in range(nx):
    for i in range(nx):
        X[j * nx + i] = (xs[i], xs[j], 0.0)
Pn = [(pi_y[k] - 1) * nx + pi_x[k] for k in range(16)]          # nudos de la placa en el perímetro (1-based)
for l in range(1, nz + 1):
    for k in range(16):
        X[np_ + (l - 1) * 16 + k] = (xs[pi_x[k] - 1], xs[pi_y[k] - 1], H * l / nz)


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

# rigideces de los muelles
kc = []
for j in range(1, nx + 1):
    for i in range(1, nx + 1):
        i0, i1, j0, j1 = max(i - 1, 1), min(i + 1, nx), max(j - 1, 1), min(j + 1, nx)
        kc.append(P["k_c"] * (xs[i1 - 1] - xs[i0 - 1]) / 2 * (xs[j1 - 1] - xs[j0 - 1]) / 2)
nb = [(2 - 1) * nx + 2, (2 - 1) * nx + 8, (8 - 1) * nx + 2, (8 - 1) * nx + 8]

# cargas: distribución lineal en la cabeza del tubo
ell = 0.0475
a_k = ell * P["t_c"]
A_t = 16 * a_k
I_t = sum(a_k * xs[pi_y[k] - 1] ** 2 for k in range(16))
F = {}
for k in range(16):
    q = np_ + (nz - 1) * 16 + k + 1
    F[q] = (-P["N"] / A_t - P["M"] * xs[pi_y[k] - 1] / I_t) * a_k

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
w("*MATERIAL, NAME=ACERO")
w("*ELASTIC")
w("%.10g, %.10g" % (P["E"], P["nu"]))
w("*SHELL SECTION, ELSET=PLATE, MATERIAL=ACERO")
w("%.10g, 5" % P["t_p"])
w("*SHELL SECTION, ELSET=TUBO, MATERIAL=ACERO")
w("%.10g, 5" % P["t_c"])
# muelles: SPRING1 en la dirección 3; un elemento y un conjunto por muelle (rigidez distinta)
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
w("*NODE PRINT, NSET=TODOS, FREQUENCY=1, TOTALS=YES")
w("RF")
w("*END STEP")
os.makedirs(os.path.join(AQUI, "abq"), exist_ok=True)
open(os.path.join(AQUI, "abq", "pb.inp"), "w", encoding="utf8").write("\n".join(o) + "\n")
json.dump({"F": {str(k): v for k, v in F.items()}, "kc": kc, "nb": nb}, open(os.path.join(AQUI, "abq", "datos.json"), "w"))
print("pb.inp escrito:", nn, "nudos,", len(E), "cáscaras,", np_ + 4, "muelles")
