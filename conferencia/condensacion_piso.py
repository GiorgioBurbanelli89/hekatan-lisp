# -*- coding: utf-8 -*-
"""
De n GDL a 3 GDL por planta: la matriz de coordenadas de piso de Aguiar.

Cadena:  K_portico (n x n)  --condensar-->  K_L (1x1 por planta)
         A = [cos.I  sen.I  r]              K_E = suma A' K_L A   (3x3)
         M = diag(m, m, J)                  modos con eig(K_E, M)

Se comprueba con dos edificios: uno SIMETRICO (no debe haber acoplamiento)
y uno ASIMETRICO (tiene que aparecer torsion).
"""
import numpy as np

E = 2.1e7            # kN/m2 (hormigon f'c 240 aprox, 15100 sqrt(f'c))
H = 3.0              # altura de entrepiso [m]

def k_portico_lateral(n_col, b_col, h_col, viga_rigida=True):
    """Rigidez lateral de un portico de 1 planta, condensada a 1 GDL.

    Columnas empotradas abajo. Si la viga es rigida (diafragma en su plano,
    nudos sin giro) cada columna aporta 12EI/H^3. Si no, 3EI/H^3.
    Esto ES la condensacion estatica: se elimina el giro del nudo.
    """
    I = b_col * h_col**3 / 12.0
    c = 12.0 if viga_rigida else 3.0
    return n_col * c * E * I / H**3

def matriz_A(alpha_deg, r):
    """Compatibilidad: u_portico = A * q_piso ,  q_piso = [ux, uy, tz]."""
    a = np.radians(alpha_deg)
    return np.array([[np.cos(a), np.sin(a), r]])

def ensamblar(porticos):
    """K_E = suma A' K_L A   -> 3x3 en coordenadas de piso."""
    KE = np.zeros((3, 3))
    for kL, alpha, r in porticos:
        A = matriz_A(alpha, r)
        KE += A.T @ np.array([[kL]]) @ A
    return KE

def modos(KE, M):
    import scipy.linalg as sla
    w2, phi = sla.eigh(KE, M)
    w = np.sqrt(np.maximum(w2, 0.0))
    T = np.where(w > 1e-9, 2*np.pi/np.maximum(w, 1e-30), np.inf)
    o = np.argsort(-T)
    return T[o], phi[:, o]

def centro_de_rigidez(porticos):
    """Sale de K_E: x_CR = -K_y,tz / K_yy ,  y_CR = K_x,tz / K_xx."""
    K = ensamblar(porticos)
    return -K[1, 2]/K[1, 1], K[0, 2]/K[0, 0]

def informe(nombre, porticos, a, b, masa):
    K = ensamblar(porticos)
    J = masa * (a**2 + b**2) / 12.0
    M = np.diag([masa, masa, J])
    T, phi = modos(K, M)
    print("=" * 66)
    print(nombre)
    print("=" * 66)
    print("K_E [kN/m, kN/rad] =")
    for f in K:
        print("   " + "  ".join(f"{v:14.2f}" for v in f))
    print(f"\nacoplamiento  K_x,tz = {K[0,2]:12.2f}   K_y,tz = {K[1,2]:12.2f}")
    exc = centro_de_rigidez(porticos)
    print(f"centro de rigidez respecto al de masa: ex = {exc[0]:+.3f} m , "
          f"ey = {exc[1]:+.3f} m")
    print(f"\nJ = m(a^2+b^2)/12 = {masa:.1f}*({a}^2+{b}^2)/12 = {J:.2f} t*m2")
    print("\nmodo    T [s]      ux        uy        tz     -> que hace")
    for i in range(3):
        v = phi[:, i] / np.abs(phi[:, i]).max()
        que = ("TRASLADA en X" if abs(v[0]) > 0.9 else
               "TRASLADA en Y" if abs(v[1]) > 0.9 else
               "GIRA (torsion)" if abs(v[2]) > 0.9 else "ACOPLADO")
        print(f"  {i+1}   {T[i]:7.4f}   {v[0]:+7.3f}   {v[1]:+7.3f}   "
              f"{v[2]:+7.3f}   {que}")
    print()
    return T

# ---------------------------------------------------------------- edificio
a, b = 6.0, 4.0          # planta 6 x 4 m
masa = 20.0              # t
# porticos: (K_L, alpha, r)  r = distancia perpendicular al centro de masa
#   los de X (alpha=0)  estan en y = -b/2 y +b/2  ->  r = -y
#   los de Y (alpha=90) estan en x = -a/2 y +a/2  ->  r = +x
kx = k_portico_lateral(2, 0.30, 0.30)
ky = k_portico_lateral(2, 0.30, 0.30)
print(f"\nrigidez lateral de un portico de 2 columnas 30x30: {kx:,.1f} kN/m\n")

sim = [(kx, 0, +b/2), (kx, 0, -b/2), (ky, 90, -a/2), (ky, 90, +a/2)]
informe("1 · EDIFICIO SIMETRICO  (la comprobacion)", sim, a, b, masa)

# una columna de 40x40 en un solo portico -> el centro de rigidez se corre
ky2 = k_portico_lateral(2, 0.40, 0.40)
asi = [(kx, 0, +b/2), (kx, 0, -b/2), (ky, 90, -a/2), (ky2, 90, +a/2)]
informe("2 · EDIFICIO ASIMETRICO (un portico mas rigido)", asi, a, b, masa)

# comprobacion a mano del caso simetrico
import math
Tx = 2*math.pi*math.sqrt(masa/(2*kx))
print(f"COMPROBACION a mano, caso simetrico:")
print(f"  T = 2*pi*sqrt(m/(2*k)) = 2*pi*sqrt({masa}/(2*{kx:.1f})) = {Tx:.4f} s")
print(f"  y el programa dio                                     = "
      f"{informe.__name__ and ''}{max(modos(ensamblar(sim), np.diag([masa,masa,masa*(a*a+b*b)/12]))[0][1:]):.4f} s")
