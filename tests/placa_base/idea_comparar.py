# -*- coding: utf-8 -*-
"""Compara uz del solver de IDEA (pb.nas -> VTK) con Abaqus (pb.dat). python idea_comparar.py shs"""
import os, re, sys, subprocess
import numpy as np
import xml.etree.ElementTree as ET
AQUI = os.path.dirname(os.path.abspath(__file__))
caso = sys.argv[1] if len(sys.argv) > 1 else "shs"
SD = os.path.join(AQUI, "..", "..", "..", "hekatan-idea-bridge", "k2solver-standalone")
d = os.path.join(AQUI, "idea", caso)
env = dict(os.environ); env["PATH"] = SD + os.pathsep + env["PATH"]
subprocess.run([os.path.join(SD, "vtkExporter64.exe"), "pb.nas"], cwd=d, env=env, capture_output=True, timeout=120)
vd = os.path.join(d, "pb_vtk")
f = sorted(x for x in os.listdir(vd) if x.startswith("result06") and x.endswith(".vtu"))[0]
r = ET.parse(os.path.join(vd, f)).getroot()
def arr(name):
    for a in r.iter("DataArray"):
        if a.get("Name") == name:
            return np.array(a.text.split(), float).reshape(-1, int(a.get("NumberOfComponents", 1)))
U = arr("displacement"); pa = r.find(".//Points/DataArray"); pts = np.array(pa.text.split(), float).reshape(-1, 3)
n = int(sys.argv[2]) if len(sys.argv) > 2 else 161
print("nudos en VTK:", len(U))
G = {}
for l in open(os.path.join(d, "pb.nas")):
    if l.startswith("GRID"):
        G[int(l[8:16])] = (float(l[24:32].replace("-", "e-").replace("e-", "-", 1) if False else l[24:32]), float(l[32:40]), float(l[40:48]))
from scipy.spatial import cKDTree
tr = cKDTree(pts)
ids = list(range(1, n + 1))
dd, ix = tr.query([G[k] for k in ids])
print("emparejado: máx distancia %.4f mm" % dd.max())
uz_i = U[ix, 2]
num = r"[-+]?\d*\.?\d+(?:[Ee][-+]?\d+)?"
A = np.zeros((n, 6)); modo = False
for l in open(os.path.join(AQUI, "abq_%s" % caso, "pb.dat"), encoding="utf8", errors="replace"):
    if "NODE" in l and "U1" in l and "RF" not in l and "F1" not in l: modo = True; continue
    if "THE ANALYSIS" in l: modo = False
    if modo:
        m = re.match(r"\s*(\d+)\s+(%s)\s+(%s)\s+(%s)\s+(%s)\s+(%s)\s+(%s)\s*$" % ((num,) * 6), l)
        if m: A[int(m.group(1)) - 1] = [float(m.group(k)) for k in range(2, 8)]
uz_a = A[:, 2] * 1000   # m -> mm
dif = uz_i - uz_a
print("uz máx |Abaqus| %.5f mm   máx |IDEA| %.5f mm   máx |dif| %.5f mm (%.2f %% del máx)" % (abs(uz_a).max(), abs(uz_i).max(), abs(dif).max(), 100 * abs(dif).max() / abs(uz_a).max()))
print("placa: uz mín/máx Abaqus %.5f/%.5f  IDEA %.5f/%.5f mm" % (uz_a[:81].min(), uz_a[:81].max(), uz_i[:81].min(), uz_i[:81].max()))
import json
D = json.load(open(os.path.join(AQUI, "abq_%s" % caso, "datos.json")))
print("pernos (nudo: Abaqus / IDEA uz mm):", ["%d: %.4f / %.4f" % (q, uz_a[q - 1], uz_i[q - 1]) for q in D["nb"]])
print("levantados  Abaqus %d  IDEA %d" % (int((uz_a[:81] > 0).sum()), int((uz_i[:81] > 0).sum())))
kc = np.array(D["kc"]); kb = json.load(open(os.path.join(AQUI, "params_%s.json" % caso)))["k_b"]
for nom, u in (("Abaqus", uz_a), ("IDEA", uz_i)):
    Rc = sum(-kc[q] * u[q] for q in range(81) if u[q] < 0)
    Tb = sum(kb * u[q - 1] for q in D["nb"] if u[q - 1] > 0)
    print("%s: R_conc %.1f kN  T_pernos %.1f kN  -> N equilibrado %.1f kN (aplicado 300)" % (nom, Rc, Tb, Rc - Tb))
