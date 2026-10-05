# -*- coding: utf-8 -*-
"""Compara la hoja (volcado HK_NUM_DEBUG) con Abaqus: desplazamientos, reacciones de muelles y fuerzas de soldadura.

    python comparar.py shs|rhs <volcado.txt>
"""
import json, os, re, sys
import numpy as np

AQUI = os.path.dirname(os.path.abspath(__file__))
caso = sys.argv[1] if len(sys.argv) > 1 else "shs"
dbg = sys.argv[2] if len(sys.argv) > 2 else r"C:\Users\j-b-j\AppData\Local\Temp\pb_144.txt"
P = json.load(open(os.path.join(AQUI, "params_%s.json" % caso)))
D = json.load(open(os.path.join(AQUI, "abq_%s" % caso, "datos.json")))
U = Fw = SE = None
for l in open(dbg, encoding="utf8", errors="replace"):
    if re.match(r";; \d+ \[U_f\] ", l):
        U = np.array([float(v) for v in re.findall(r"[-+]?\d+\.?\d*(?:[eE][-+]?\d+)?", l.split("=>", 1)[1])])
    if re.match(r";; \d+ \[sig_el_f\] ", l):
        SE = np.array([float(v) for v in re.findall(r"[-+]?\d+\.?\d*(?:[eE][-+]?\d+)?", l.split("=>", 1)[1])])
    if re.match(r";; \d+ \[Fw_f\] ", l):
        Fw = np.array([float(v) for v in re.findall(r"[-+]?\d+\.?\d*(?:[eE][-+]?\d+)?", l.split("=>", 1)[1])])
n = len(U) // 6
L = U.reshape(n, 6)
A = np.zeros((n, 6))
NF = {}
modo = None
num = r"[-+]?\d*\.?\d+(?:[Ee][-+]?\d+)?"
for l in open(os.path.join(AQUI, "abq_%s" % caso, "pb.dat"), encoding="utf8", errors="replace").read().splitlines():
    if "NODE" in l and "U1" in l and "RF" not in l and "F1" not in l:
        modo = "U"; continue
    if "ELEMENT" in l and "NODE" in l and "NFORC1" in l:
        modo = "NF"; NF = {}; continue
    if "THE ANALYSIS" in l:
        modo = None
    if modo == "U":
        m = re.match(r"\s*(\d+)\s+(%s)\s+(%s)\s+(%s)\s+(%s)\s+(%s)\s+(%s)\s*$" % ((num,) * 6), l)
        if m:
            A[int(m.group(1)) - 1] = [float(m.group(k)) for k in range(2, 8)]
    elif modo == "NF":
        m = re.match(r"\s*(\d+)\s+(\d+)\s+(%s)\s+(%s)\s+(%s)\s+(%s)\s+(%s)\s+(%s)\s*$" % ((num,) * 6), l)
        if m:
            e, q = int(m.group(1)), int(m.group(2))
            NF.setdefault(q, np.zeros(3))
            NF[q] = NF[q] + np.array([float(m.group(k)) for k in range(3, 6)])
dif = L - A
print("== desplazamientos de los %d nudos (hoja - Abaqus) ==" % n)
for k, nom in enumerate(["ux", "uy", "uz", "rx", "ry", "rz"]):
    sc = max(np.abs(A[:, k]).max(), 1e-12)
    print("  %s  máx |Abaqus| %.4e   máx |dif| %.3e   (%.2f %% del máximo)" % (nom, np.abs(A[:, k]).max(), np.abs(dif[:, k]).max(), 100 * np.abs(dif[:, k]).max() / sc))
uz = A[:81, 2]
Rc = sum(-D["kc"][q] * uz[q] for q in range(81) if uz[q] < 0)
Rb = [P["k_b"] * uz[q - 1] for q in D["nb"] if uz[q - 1] > 0]
print("== muelles ==\n  Abaqus: R_conc %.3f kN · T_b %.3f kN · nudos levantados %d · pernos activos %d · T máx %.3f kN" % (Rc, sum(Rb), int(sum(1 for v in uz if v > 0)), len(Rb), max(Rb) if Rb else 0))
Lz = L[:81, 2]
Rc_l = sum(-D["kc"][q] * Lz[q] for q in range(81) if Lz[q] < 0)
Rb_l = [P["k_b"] * Lz[q - 1] for q in D["nb"] if Lz[q - 1] > 0]
print("  hoja:   R_conc %.3f kN · T_b %.3f kN · nudos levantados %d · pernos activos %d · T máx %.3f kN" % (Rc_l, sum(Rb_l), int(sum(1 for v in Lz if v > 0)), len(Rb_l), max(Rb_l) if Rb_l else 0))
if Fw is not None and NF:
    pn = [(r - 1) * 9 + c for r, c in zip([3, 3, 3, 3, 3, 4, 5, 6, 7, 7, 7, 7, 7, 6, 5, 4], [3, 4, 5, 6, 7, 7, 7, 7, 7, 6, 5, 4, 3, 3, 3, 3])]
    hw = Fw.reshape(16, 3)
    aw = np.array([NF[q] for q in pn])
    mh = np.sqrt((hw ** 2).sum(1)); ma = np.sqrt((aw ** 2).sum(1))
    print("== soldadura: fuerza nodal del tubo sobre la placa (|F| por nudo, kN) ==")
    print("  hoja   máx %.2f  suma Fz %.2f" % (mh.max(), hw[:, 2].sum()))
    print("  Abaqus máx %.2f  suma Fz %.2f" % (ma.max(), aw[:, 2].sum()))
    print("  máx |dif| entre nudos: %.3f kN (%.2f %% del máximo)" % (np.abs(mh - ma).max(), 100 * np.abs(mh - ma).max() / ma.max()))
else:
    print("(sin fuerzas nodales de Abaqus que comparar: NF=%d)" % len(NF))

# tensiones de la placa: Von Mises en el centro de cada elemento (extremo de la sección: máximo de los 5 puntos de la sección)
if SE is not None:
    txt = open(os.path.join(AQUI, "abq_%s" % caso, "pb.dat"), encoding="utf8", errors="replace").read().splitlines()
    SV = {}
    ult = None
    for i, l in enumerate(txt):
        if "ELEMENT" in l and "SEC" in l and "S11" in l:
            ult = i
    if ult is not None:
        for l in txt[ult + 1:]:
            m = re.match(r"\s*(\d+)\s+(\d+)\s+(%s)\s+(%s)\s+(%s)\s*$" % ((num,) * 3), l)
            if m:
                e = int(m.group(1)); s11, s22, s12 = [float(m.group(k)) for k in range(3, 6)]
                svm = (s11 * s11 - s11 * s22 + s22 * s22 + 3 * s12 * s12) ** 0.5 / 1000
                SV[e] = max(SV.get(e, 0), svm)
            elif SV and l.strip() == "":
                pass
    if SV:
        a_ = np.array([SV[e] for e in range(1, 65) if e in SV])
        print("== tensión de Von Mises en el centro de los 64 elementos de la placa (MPa) ==")
        print("  hoja   máx %.2f   Abaqus máx %.2f   (dif %.2f %%)" % (SE.max(), a_.max(), 100 * abs(SE.max() - a_.max()) / a_.max()))
        if len(a_) == 64:
            print("  máx |dif| entre elementos: %.2f MPa (%.2f %% del máximo)" % (np.abs(SE[:64] - a_).max(), 100 * np.abs(SE[:64] - a_).max() / a_.max()))
    else:
        print("(no pude leer las tensiones S de Abaqus)")
