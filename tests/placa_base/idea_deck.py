# -*- coding: utf-8 -*-
"""Deck Nastran para el solver CBFEM de IDEA StatiCa (k2fem64, sin red ni licencia): MISMA malla, cargas y muelles que la hoja y Abaqus.

    python idea_deck.py shs|rhs   -> idea/<caso>/pb.nas   (unidades mm, N, MPa)
Cáscaras CQUAD4 (placa y tubo), hormigón = CGAP solo compresión bajo cada nudo de la placa,
pernos = CGAP solo tracción (nudo de tierra ARRIBA), carga = fuerzas nodales en el borde superior del tubo.
"""
import json, os, sys, math

AQUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(AQUI, "..", "..", "..", "hekatan-idea-bridge", "examples"))
from make_baseplate_deck import card  # noqa: E402

caso = sys.argv[1] if len(sys.argv) > 1 else "shs"
P = json.load(open(os.path.join(AQUI, "params_%s.json" % caso)))
D = json.load(open(os.path.join(AQUI, "abq_%s" % caso, "datos.json")))   # F y kc ya calculados por abaqus_inp.py
mm = 1000.0
TH = math.radians(30.0)   # giro del modelo: el lector del solver no admite caras con normal paralela a X
CT, ST = math.cos(TH), math.sin(TH)


def rot(x, y):
    return (CT * x - ST * y, ST * x + CT * y)


xs, ys, nz, H = P["xs"], P["ys"], P["nz"], P["H"]
nx = len(xs)
np_ = nx * nx
pi_x = [3, 4, 5, 6, 7, 7, 7, 7, 7, 6, 5, 4, 3, 3, 3, 3]
pi_y = [3, 3, 3, 3, 3, 4, 5, 6, 7, 7, 7, 7, 7, 6, 5, 4]
nn = np_ + 16 * nz
X = {}
for j in range(nx):
    for i in range(nx):
        X[j * nx + i + 1] = (*rot(xs[i] * mm, ys[j] * mm), 0.0)
Pn = [(pi_y[k] - 1) * nx + pi_x[k] for k in range(16)]
for l in range(1, nz + 1):
    for k in range(16):
        X[np_ + (l - 1) * 16 + k + 1] = (*rot(xs[pi_x[k] - 1] * mm, ys[pi_y[k] - 1] * mm), H * l / nz * mm)


def tubo(l, k):
    return Pn[k - 1] if l == 0 else np_ + (l - 1) * 16 + k


L = ["SOL 106\n", "CEND\n", "SUBCASE 1\n", "  SPC = 1\n", "  LOAD = 1\n", "  NLPARM = 1\n", "BEGIN BULK\n"]
w = L.append
w(card("NLPARM6", 1, 25, 0.001, 1e-7, 5, 3, 10, "YES"))
w(card("MAT1", 1, P["E"] / 1000.0, "", P["nu"]))          # kPa -> MPa
w(card("PSHELL", 1, 1, P["t_p"] * mm, 1, "", 1))
w(card("PSHELL", 4, 1, P["t_c"] * mm, 1, "", 1))
w(card("PGAP", 2, "", "", 1.0, 1e-6))                     # KA se reemplaza por nudo abajo (un PGAP por rigidez)
pid = 10
pg = {}
for q in range(np_):
    pg[q] = pid
    w(card("PGAP", pid, "", "", D["kc"][q] * 1.0, 1e-6))   # kN/m == N/mm
    pid += 1
w(card("PGAP", 3, "", "", P["k_b"], 1e-6))
for k in sorted(X):
    w(card("GRID", k, "", *X[k]))
eid = 1
for j in range(1, nx):
    for i in range(1, nx):
        q = (j - 1) * nx + i
        w(card("CQUAD4", eid, 1, q, q + 1, q + nx + 1, q + nx)); eid += 1
for l in range(1, nz + 1):
    for k in range(1, 17):
        k2 = k % 16 + 1
        w(card("CQUAD4", eid, 4, tubo(l - 1, k), tubo(l - 1, k2), tubo(l, k2), tubo(l, k))); eid += 1
g = 100000
cg = 1000
for q in range(1, np_ + 1):                                 # hormigón: tierra abajo
    x, y, _ = X[q]
    w(card("GRID", g + q, "", x, y, -1.0))
    w(card("CGAP", cg, pg[q - 1], q, g + q)); cg += 1
    w(card("SPC", 1, g + q, 123456, 0.0))
for m, q in enumerate(D["nb"], 1):                          # pernos: tierra ARRIBA (solo tracción)
    x, y, _ = X[q]
    w(card("GRID", g + 5000 + m, "", x, y, 1.0))
    w(card("CGAP", cg, 3, q, g + 5000 + m)); cg += 1
    w(card("SPC", 1, g + 5000 + m, 123456, 0.0))
for q in range(1, nn + 1):                                  # giro alrededor de z (drilling) y movimientos en el plano
    w(card("SPC", 1, q, 6, 0.0))
w(card("SPC", 1, 41, 12, 0.0))
w(card("SPC", 1, 45, 1, 0.0))   # tras el giro de 30 el nudo 45 queda en (173,100): ux basta para frenar el giro
for q, f in sorted((int(a), b) for a, b in D["F"].items()):
    w(card("FORCE", 1, q, "0", 1.0, 0.0, 0.0, f * 1000.0))   # kN -> N
w("ENDDATA\n")
d = os.path.join(AQUI, "idea", caso)
os.makedirs(d, exist_ok=True)
open(os.path.join(d, "pb.nas"), "w", encoding="ascii").writelines(L)
print("deck IDEA ->", d, ":", len(X), "nudos")
