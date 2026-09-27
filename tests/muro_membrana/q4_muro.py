# -*- coding: utf-8 -*-
"""Muro membrana (hoja 92) en numpy: el mismo elemento de la hoja (Q4 de TENSION PLANA con los
modos incompatibles de Wilson-Taylor), misma malla y mismas cargas nodales. Escribe muro_q4.json
(nudos, elementos, cargas, U) para el driver de SAP2000 y para gen_heks.py (Hekatan Struct).
   python q4_muro.py [nx ny]"""
import json, sys
import numpy as np
nx, ny = (int(sys.argv[1]), int(sys.argv[2])) if len(sys.argv) > 2 else (4, 40)
H, t, gam, phi, fc, nu = 4.0, 0.4, 1.8, 30.0, 210.0, 0.2
E = 10 * 15100 * np.sqrt(fc)                       # tonf/m2
Ka = np.tan(np.pi / 4 - np.radians(phi) / 2) ** 2
D = E / (1 - nu ** 2) * np.array([[1, nu, 0], [nu, 1, 0], [0, 0, (1 - nu) / 2]])        # tension plana
a, b = t / nx, H / ny
def B(xi, et):
    return np.array([
        [-(1 - et) / (2 * a), 0, (1 - et) / (2 * a), 0, (1 + et) / (2 * a), 0, -(1 + et) / (2 * a), 0],
        [0, -(1 - xi) / (2 * b), 0, -(1 + xi) / (2 * b), 0, (1 + xi) / (2 * b), 0, (1 - xi) / (2 * b)],
        [-(1 - xi) / (2 * b), -(1 - et) / (2 * a), -(1 + xi) / (2 * b), (1 - et) / (2 * a),
         (1 + xi) / (2 * b), (1 + et) / (2 * a), (1 - xi) / (2 * b), -(1 + et) / (2 * a)]])
def Gm(xi, et):      # modos incompatibles: u y v con (1 - xi^2) y (1 - eta^2)
    return np.array([[-4 * xi / a, 0, 0, 0], [0, 0, 0, -4 * et / b], [0, -4 * xi / a, -4 * et / b, 0]])
g = 1 / np.sqrt(3)
PG = [(xi, et) for xi in (-g, g) for et in (-g, g)]
Kuu = sum(B(*q).T @ D @ B(*q) * a * b / 4 for q in PG)
Kua = sum(B(*q).T @ D @ Gm(*q) * a * b / 4 for q in PG)
Kaa = sum(Gm(*q).T @ D @ Gm(*q) * a * b / 4 for q in PG)
Ke = Kuu - Kua @ np.linalg.solve(Kaa, Kua.T)
nj = (nx + 1) * (ny + 1)
nid = lambda i, k: i * (ny + 1) + k                # 0-based, por columnas (como la hoja)
nodes = [[(j // (ny + 1)) * a, (j % (ny + 1)) * b] for j in range(nj)]
elems = [[nid(i, k), nid(i + 1, k), nid(i + 1, k + 1), nid(i, k + 1)] for i in range(nx) for k in range(ny)]
K = np.zeros((2 * nj, 2 * nj)); F = np.zeros(2 * nj)
for ns in elems:
    dof = sum([[2 * n, 2 * n + 1] for n in ns], [])
    K[np.ix_(dof, dof)] += Ke
p = lambda z: Ka * gam * z
for k in range(ny):
    pa, pb = p(H - k * b), p(H - (k + 1) * b)
    F[2 * nid(0, k)] += b * (2 * pa + pb) / 6
    F[2 * nid(0, k + 1)] += b * (pa + 2 * pb) / 6
free = [d for n in range(nj) if n % (ny + 1) != 0 for d in (2 * n, 2 * n + 1)]
U = np.zeros(2 * nj); U[free] = np.linalg.solve(K[np.ix_(free, free)], F[free])
print("malla %dx%d: u_cor = %.6f mm | sumF = %.4f tonf/m" % (nx, ny, 1000 * U[2 * nid(0, ny)], F.sum()))
json.dump({"E": E, "nu": nu, "nodes": nodes, "elems": elems, "Fx": F[0::2].tolist(),
           "base": [n for n in range(nj) if n % (ny + 1) == 0],
           "U": U.reshape(-1, 2).tolist(), "cor": nid(0, ny)}, open("muro_q4.json", "w"))
