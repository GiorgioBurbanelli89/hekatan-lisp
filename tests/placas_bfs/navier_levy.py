#!/usr/bin/env python3
"""Soluciones publicadas (Timoshenko & Woinowsky-Krieger, Theory of Plates and Shells, 2.ª ed.)
evaluadas con sus SERIES, en un programa aparte de la hoja (oráculo analítico):

  * Navier, placa apoyada, carga uniforme ........ §30, Tabla 8 (p. 120)
  * Navier, placa apoyada, carga puntual central .. §34, ec. (147), Tabla 23 (p. 143)
  * Lévy, x = 0, a apoyados, y = ±b/2 libres ...... §47, Tabla 47 (p. 219)

Devuelve coeficientes adimensionales (w = α·q·a⁴/D, M = β·q·a²; w = α·P·a²/D) y los compara con
las tablas del libro (ν = 0.3) para dejar constancia de que la serie es la del libro.
"""
import math, sys
sys.stdout.reconfigure(encoding="utf-8")
import numpy as np


def navier_uniforme(ba, nu=0.3, x=0.5, y=0.5, N=401):
    """α, βx, βy en (x·a, y·b) de la placa apoyada a × b (a = 1) con carga q = 1, D = 1."""
    a, b = 1.0, ba
    m = np.arange(1, N + 1, 2)[:, None]; n = np.arange(1, N + 1, 2)[None, :]
    W = 16 / (math.pi ** 6 * m * n * (m ** 2 / a ** 2 + n ** 2 / b ** 2) ** 2)
    s = np.sin(m * math.pi * x) * np.sin(n * math.pi * y)
    w = (W * s).sum()
    kx, ky = (m * math.pi / a) ** 2, (n * math.pi / b) ** 2
    return w, (W * (kx + nu * ky) * s).sum(), (W * (ky + nu * kx) * s).sum()


def navier_puntual(ba, N=4001):
    """α de w_c = α·P·a²/D (carga P en el centro, a = 1)."""
    a, b = 1.0, ba
    m = np.arange(1, N + 1, 2, dtype=float)[:, None]; n = np.arange(1, N + 1, 2, dtype=float)[None, :]
    s = np.sin(m * math.pi / 2) ** 2 * np.sin(n * math.pi / 2) ** 2
    return (4 / (math.pi ** 4 * a * b) * s / ((m / a) ** 2 + (n / b) ** 2) ** 2).sum()


def levy_dos_libres(ba, nu=0.3, M=201):
    """Tabla 47: x = 0, a apoyados; y = ±b/2 libres (a = 1, q = 1, D = 1).
    w = Σ [4/(π⁵m⁵) + A_m·ch(αy) + B_m·αy·sh(αy)]·sin(αx),  α = mπ/a.
    Bordes libres: M_y = 0 (f'' − ν·α²·f = 0) y V_y = 0 (f''' − (2 − ν)·α²·f' = 0)."""
    a, b = 1.0, ba
    def f_all(al, A, B, p, y):
        ch, sh = math.cosh(al * y), math.sinh(al * y)
        f = p + A * ch + B * al * y * sh
        f1 = A * al * sh + B * (al * sh + al ** 2 * y * ch)
        f2 = A * al ** 2 * ch + B * (2 * al ** 2 * ch + al ** 3 * y * sh)
        f3 = A * al ** 3 * sh + B * (3 * al ** 3 * sh + al ** 4 * y * ch)
        return f, f1, f2, f3
    res = {"w0": 0, "Mx0": 0, "My0": 0, "w_b": 0, "Mx_b": 0}
    for m in range(1, M + 1, 2):
        al = m * math.pi / a
        p = 4 / (math.pi ** 5 * m ** 5)
        y = b / 2
        # sistema lineal en A, B (las condiciones son lineales)
        def cond(A, B, pp):
            f, f1, f2, f3 = f_all(al, A, B, pp, y)
            return np.array([f2 - nu * al ** 2 * f, f3 - (2 - nu) * al ** 2 * f1])
        c0 = cond(0, 0, p); cA = cond(1, 0, 0); cB = cond(0, 1, 0)
        A, B = np.linalg.solve(np.column_stack([cA, cB]), -c0)
        sx = math.sin(al * a / 2)
        for yy, suf in ((0.0, "0"), (b / 2, "_b")):
            f, f1, f2, f3 = f_all(al, A, B, p, yy)
            res["w" + suf] += f * sx
            res["Mx" + suf] += (al ** 2 * f - nu * f2) * sx
            if suf == "0":
                res["My0"] += (nu * al ** 2 * f - f2) * sx
    return res


if __name__ == "__main__":
    print("Tabla 8 (b/a = 1):   α, β, β1 =", ["%.6f" % v for v in navier_uniforme(1.0)], "  libro: 0.00406 0.0479 0.0479")
    print("Tabla 23 (b/a = 1):  α =", "%.6f" % navier_puntual(1.0), "  libro: 0.01160")
    r = levy_dos_libres(1.0)
    print("Tabla 47 (b/a = 1):", {k: round(v, 6) for k, v in r.items()}, "  libro: α1 0.01309 β1 0.1225 β1' 0.0271 α2 0.01509 β2 0.1318")
