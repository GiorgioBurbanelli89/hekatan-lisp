#!/usr/bin/env python3
"""Oráculo = CALCPAD (otro programa), misma malla nudo a nudo que las hojas 73…78 de Hekatan LISP.

Parte del ejemplo oficial `Rectangular Slab FEA.cpd` (Ned Ganchovski, elemento BFS de 16 GDL) y
cambia SOLO: datos, malla, apoyos (qué GDL se fijan en qué nudos), carga puntual y, al final, unas
líneas que imprimen los valores a comparar. Se quita el redondeo a 0.001 mm de W_z para comparar a
4 decimales. Cada variante se corre con el Cli de Calcpad y se guarda su HTML.

Uso: python tests/placas_bfs/oraculo_calcpad.py  → tests/placas_bfs/calcpad/<caso>.cpd / .html
"""
import os, subprocess, sys

AQUI = os.path.dirname(os.path.abspath(__file__))
BASE = r"C:\Users\j-b-j\Documents\Calcpad-Suite\Examples\Mechanics\Finite Elements\Rectangular Slab FEA.cpd"
CLI = r"C:\Users\j-b-j\Documents\Calcpad-Suite\Calcpad.Cli\bin\Release\net10.0\Cli.exe"
OUT = os.path.join(AQUI, "calcpad")

# condiciones de apoyo por GDL (w, θx, θy, ψ), en sintaxis de Calcpad sobre el nudo j
BORDE = "x_j.j ≡ 0 ∨ x_j.j ≡ a ∨ y_j.j ≡ 0 ∨ y_j.j ≡ b"
APOYOS = {
    "apoyada": [BORDE, "y_j.j ≡ 0 ∨ y_j.j ≡ b", "x_j.j ≡ 0 ∨ x_j.j ≡ a", None],
    "empotrada": [BORDE, BORDE, BORDE, BORDE],
    "una_direccion": ["x_j.j ≡ 0 ∨ x_j.j ≡ a", None, "x_j.j ≡ 0 ∨ x_j.j ≡ a", None],
    "voladizo": ["x_j.j ≡ 0"] * 4,
}

CASOS = {
    # nombre: (a, b, t, q, E, ν, n_a, n_b, apoyos, P)
    "73_puntual": (4, 4, 0.12, 0, 35000, 0.3, 8, 8, "apoyada", 50),
    "74_empotrada": (4, 6, 0.12, 10, 35000, 0.3, 8, 12, "empotrada", 0),
    "74_empotrada_16x24": (4, 6, 0.12, 10, 35000, 0.3, 16, 24, "empotrada", 0),
    "74_empotrada_12x18": (4, 6, 0.12, 10, 35000, 0.3, 12, 18, "empotrada", 0),
    "75_una_direccion": (4, 8, 0.12, 10, 35000, 0.3, 8, 16, "una_direccion", 0),
    "76_voladizo": (4, 2, 0.12, 10, 35000, 0.0, 8, 4, "voladizo", 0),
    "78_conv_2": (4, 4, 0.12, 10, 35000, 0.3, 2, 2, "apoyada", 0),
    "78_conv_4": (4, 4, 0.12, 10, 35000, 0.3, 4, 4, "apoyada", 0),
    "78_conv_8": (4, 4, 0.12, 10, 35000, 0.3, 8, 8, "apoyada", 0),
    "78_conv_16": (4, 4, 0.12, 10, 35000, 0.3, 16, 16, "apoyada", 0),
    # ejemplo 82 (refinamiento h animado, n = 2:2:16): las mallas que faltaban
    "78_conv_6": (4, 4, 0.12, 10, 35000, 0.3, 6, 6, "apoyada", 0),
    "78_conv_10": (4, 4, 0.12, 10, 35000, 0.3, 10, 10, "apoyada", 0),
    "78_conv_12": (4, 4, 0.12, 10, 35000, 0.3, 12, 12, "apoyada", 0),
    "78_conv_14": (4, 4, 0.12, 10, 35000, 0.3, 14, 14, "apoyada", 0),
}


def rep(s, old, new):
    if old not in s:
        raise SystemExit("no está en la plantilla: " + old)
    return s.replace(old, new, 1)


def variante(nombre, a, b, t, q, E, nu, na, nb, apoyos, P):
    s = open(BASE, encoding="utf-8").read().replace("\r\n", "\n")
    s = rep(s, "'Slab dimensions -'a = 6'm,'b = 4'm", f"'Slab dimensions -'a = {a}'m,'b = {b}'m")
    s = rep(s, "'Thickness -'t = 0.1'm", f"'Thickness -'t = {t}'m")
    s = rep(s, "'Load -'q = 10'kN/m²", f"'Load -'q = {q}'kN/m²")
    s = rep(s, "'Modulus of elasticity -'E = 35000'MPa", f"'Modulus of elasticity -'E = {E}'MPa")
    s = rep(s, "'Poisson`s ratio -'ν = 0.15", f"'Poisson`s ratio -'ν = {nu}")
    s = rep(s, "n_a = 6', 'n_b = 4", f"n_a = {na}', 'n_b = {nb}")
    # apoyos: un muelle k_s en cada GDL fijo, nudo por nudo
    i0 = s.index("#for i = 1 : n_s\n\tj = k_1*(s_j.i - 1) + 1")
    i1 = s.index("#loop", i0) + len("#loop")
    cuerpo = ["#for j = 1 : n_j"]
    for k, c in enumerate(APOYOS[apoyos]):
        if c is None:
            continue
        cuerpo += [f"\t#if {c}", f"\t\tK.(k_1*(j - 1) + {k + 1}; k_1*(j - 1) + {k + 1}) = K.(k_1*(j - 1) + {k + 1}; k_1*(j - 1) + {k + 1}) + k_s", "\t#end if"]
    cuerpo.append("#loop")
    s = s[:i0] + "\n".join(cuerpo) + s[i1:]
    # carga puntual en el nudo central
    if P:
        s = rep(s, "#show\nF'kN", f"j_P = n_a/2*(n_b + 1) + n_b/2 + 1\nF.(4*j_P - 3) = F.(4*j_P - 3) + {P}\n#show\nF'kN")
    # W_z sin redondear
    s = rep(s, "round(w((i - 1)*(n_b + 1) + j)*1000)/1000", "w((i - 1)*(n_b + 1) + j)")
    # valores del oráculo (nudos por sus índices: columna i_a, fila i_b)
    s += "\n'<h4>ORACULO</h4>\n"
    s += "j_o(i_a; i_b) = (i_a - 1)*(n_b + 1) + i_b\n"
    pts = {"c": ("n_a/2 + 1", "n_b/2 + 1"), "bx": ("n_a/2 + 1", "1"), "by": ("1", "n_b/2 + 1"),
           "ex": ("n_a + 1", "n_b/2 + 1"), "ez": ("n_a + 1", "1"), "o": ("1", "1")}
    for k, (ia, ib) in pts.items():
        s += f"'PUNTO {k}'j_{k} = j_o({ia}; {ib})\n"
        s += f"'W {k}'w_{k} = Z.(4*j_{k} - 3)\n"
        s += f"'MX {k}'Mx_{k} = M_j.(1; j_{k})\n"
        s += f"'MY {k}'My_{k} = M_j.(2; j_{k})\n"
    os.makedirs(OUT, exist_ok=True)
    cpd = os.path.join(OUT, nombre + ".cpd")
    open(cpd, "w", encoding="utf-8").write(s)
    html = os.path.join(OUT, nombre + ".html")
    subprocess.run([CLI, cpd, html, "-s"], check=True, timeout=600)
    from leer_calcpad import adelgaza
    adelgaza(html)
    return html


if __name__ == "__main__":
    solo = sys.argv[1:]
    for n, p in CASOS.items():
        if solo and n not in solo:
            continue
        print(n, "->", variante(n, *p))
