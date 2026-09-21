# Derivadas e integrales en ingeniería estructural
#: Dos operaciones, dos direcciones. Se DERIVA para bajar de la pieza al punto. Se INTEGRA para sumar infinitos aportes y subir del punto a la pieza.

## ── EN LA SECCIÓN: se integra sobre el área ──
## El área: la suma de todas las fibras de una sección rectangular
A_r = Simplify{b·h/2 - b·(-h/2)}

## El momento de inercia: cada fibra pesa por su distancia AL CUADRADO
I_r = Integral{b·y^2 @ y = -h/2 : h/2}

## El momento estático de media sección, para el cortante
Q_r = Integral{b·y @ y = 0 : h/2}

## Y con eso, la tensión cortante máxima de Jourawski
tau_m = Simplify{V·(b·h^2/8)/((b·h^3/12)·b)}

## ── A LO LARGO DE LA PIEZA: se integra sobre dx ──
## El cortante, integrando la carga
V_p = Integral{q @ x}

## El momento, integrando el cortante
M_p = Integral{q·x @ x}

## ── Y LAS DERIVADAS, el camino inverso ──
d_1 = dV/dx = -q
d_2 = dM/dx = V
d_3 = theta = dw/dx
d_4 = kappa = d2w/dx2

## La deformación unitaria: la derivada del desplazamiento
d_5 = epsilon = du/dx

## Y la condición de sección crítica
d_6 = dM/dx = V = 0
