# -*- coding: utf-8 -*-
"""Compara los desplazamientos de la hoja 144 (volcado HK_NUM_DEBUG) con los de Abaqus (pb.dat)."""
import re, sys, os
import numpy as np
AQUI = os.path.dirname(os.path.abspath(__file__))
dbg = sys.argv[1] if len(sys.argv) > 1 else r"C:\Users\j-b-j\AppData\Local\Temp\pb_dbg.txt"
U = None
for l in open(dbg, encoding="utf8", errors="replace"):
    if re.match(r";; \d+ \[U_f\] ", l):
        U = np.array([float(v) for v in re.findall(r"[-+]?\d+\.?\d*(?:[eE][-+]?\d+)?", l.split("=>", 1)[1])])
n = len(U) // 6
print("hoja 144:", n, "nudos")
A = np.zeros((n, 6)); got = 0
lines = open(os.path.join(AQUI, "abq", "pb.dat"), encoding="utf8", errors="replace").read().splitlines()
modo = False
for l in lines:
    if "NODE" in l and "U1" in l: modo = "U"; continue
    if "NODE" in l and "RF1" in l: modo = "RF"; continue
    m = re.match(r"\s*(\d+)\s+([-+0-9.Ee]+)\s+([-+0-9.Ee]+)\s+([-+0-9.Ee]+)\s+([-+0-9.Ee]+)\s+([-+0-9.Ee]+)\s+([-+0-9.Ee]+)\s*$", l)
    if m and modo == "U":
        A[int(m.group(1)) - 1] = [float(m.group(k)) for k in range(2, 8)]; got += 1
print("Abaqus:", got, "nudos")
L = U.reshape(n, 6)
dif = L - A
for k, nom in enumerate(["ux", "uy", "uz", "rx", "ry", "rz"]):
    sc = max(np.abs(A[:, k]).max(), 1e-12)
    print("%s  máx |Abaqus| %.4e   máx |dif| %.3e   (%.4f %% del máximo)" % (nom, np.abs(A[:, k]).max(), np.abs(dif[:, k]).max(), 100 * np.abs(dif[:, k]).max() / sc))
print("uz de la placa (mm): hoja 144 mín %.4f máx %.4f | Abaqus mín %.4f máx %.4f" % (L[:81, 2].min() * 1e3, L[:81, 2].max() * 1e3, A[:81, 2].min() * 1e3, A[:81, 2].max() * 1e3))
