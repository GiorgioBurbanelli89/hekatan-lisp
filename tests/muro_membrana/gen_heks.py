# -*- coding: utf-8 -*-
"""El muro de la hoja 92 como .heks de Hekatan Struct: plano X-Z, mismos 205 nudos (misma
numeracion), mismas fuerzas nodales. Struct trabaja en kN y m; nu de las cascaras = 0.2 (fijo).
   python gen_heks.py [membrana|completa]  -> muro_struct.heks"""
import json, sys
modo = sys.argv[1] if len(sys.argv) > 1 else "completa"
D = json.load(open("muro_q4.json"))
G = 9.80665
L = ["# Pantalla de muro de contencion, H = 4 m, t = 0.40 m, franja de 1 m (hoja 92 de Hekatan LISP)",
     "# empuje de Rankine repartido a los nudos de la cara del relleno (x = 0)", "selfweight 0"]
for i, (x, z) in enumerate(D["nodes"]):
    L.append("node %d %.10g 0 %.10g" % (i + 1, x, z))
for k, e in enumerate(D["elems"]):
    L.append("shell %d %d %d %d %d 1 %.10g 0 0" % (k + 1, e[0] + 1, e[1] + 1, e[2] + 1, e[3] + 1, D["E"] * G))
    if modo == "membrana":
        L.append("shellmod %d 1 0" % (k + 1))
base = set(D["base"])
for i in range(len(D["nodes"])):
    if i in base:
        L.append("support %d 1 1 1 1 1 1" % (i + 1))
    elif modo == "membrana":
        L.append("support %d 0 1 0 1 0 1" % (i + 1))
for i, fx in enumerate(D["Fx"]):
    if fx:
        L.append("load %d %.10g 0 0 0 0 0" % (i + 1, fx * G))
L.append("solve")
open("muro_struct.heks", "w", encoding="utf-8").write("\n".join(L) + "\n")
print(len(L), "lineas")
