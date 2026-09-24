#!/usr/bin/env python3
"""Oráculo del ejemplo 77: el Flat Slab FEA.cpd de Calcpad TAL CUAL, con dos cambios: W_z sin
redondear a 0.001 mm (para comparar a 4 decimales) y un bloque ORACULO al final (flecha y momentos
en nudos clave y la suma de reacciones). Se corre con el Cli de Calcpad."""
import os, subprocess
AQUI = os.path.dirname(os.path.abspath(__file__))
BASE = r"C:\Users\j-b-j\Documents\Calcpad-Suite\Examples\Mechanics\Finite Elements\Flat Slab FEA.cpd"
CLI = r"C:\Users\j-b-j\Documents\Calcpad-Suite\Calcpad.Cli\bin\Release\net10.0\Cli.exe"
s = open(BASE, encoding="utf-8").read().replace("\r\n", "\n")
old = "round(w((i - 1)*n_jb + j)*1000)/1000"
assert old in s
s = s.replace(old, "w((i - 1)*n_jb + j)")
s += """
'<h4>ORACULO</h4>
j_o(i_a; i_b) = (i_a - 1)*n_jb + i_b
'PUNTO c'j_c = j_o(n_a.1 + n_a.2 + 1; n_b.1 + 1)
'W c'w_c = Z.(4*j_c - 3)
'MX c'Mx_c = M_j.(1; j_c)
'MY c'My_c = M_j.(2; j_c)
'PUNTO m'j_m = j_o(4; 3)
'W m'w_m = Z.(4*j_m - 3)
'MX m'Mx_m = M_j.(1; j_m)
'MY m'My_m = M_j.(2; j_m)
'PUNTO p'j_p = j_o(11; 9)
'W p'w_p = Z.(4*j_p - 3)
'MX p'Mx_p = M_j.(1; j_p)
'MY p'My_p = M_j.(2; j_p)
'W max'w_max = max(W_z)
'R total'R_t = k_s*sum(extract(Z; 4*s_j - 3))
"""
os.makedirs(os.path.join(AQUI, "calcpad"), exist_ok=True)
cpd = os.path.join(AQUI, "calcpad", "77_flat_slab.cpd")
open(cpd, "w", encoding="utf-8").write(s)
# variante «exacta»: Cholesky (clsolve) en vez del solver iterativo slsolve (Tol = 10^-2) del original
# y las integrales de K_e y F_e a 10^-12 en vez de 10^-4 ($Integral no es exacta con 10^-4)
s2 = s.replace("Z = slsolve(K; F)", "Z = clsolve(K; F)").replace("Precision = 10^-4", "Precision = 10^-12")
assert s2 != s
cpd2 = os.path.join(AQUI, "calcpad", "77_flat_slab_clsolve.cpd")
open(cpd2, "w", encoding="utf-8").write(s2)
subprocess.run([CLI, cpd2, cpd2[:-4] + ".html", "-s"], check=True, timeout=900)
subprocess.run([CLI, cpd, cpd[:-4] + ".html", "-s"], check=True, timeout=900)
from leer_calcpad import adelgaza
for h in (cpd[:-4] + ".html", cpd2[:-4] + ".html"):
    adelgaza(h)
print("ok")
