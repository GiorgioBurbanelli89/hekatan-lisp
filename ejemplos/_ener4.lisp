# La energía
## Energía del resorte: el área bajo la recta de fuerza contra desplazamiento.
U_res = Area{k·x @ x=0:1}
## Lo que se acumula en cada trocito de una barra doblada.
u_tro = EI·kappa^2/2
## Su derivada respecto a la curvatura es el momento.
dU = Partial{EI·kappa^2/2 @ kappa}
## Y la segunda derivada es la rigidez.
d2U = Partial{EI·kappa @ kappa}
## El área bajo la curva de la primera Hermite al cuadrado ES el primer número de la matriz.
kap_1 = Partial{Partial{1 - 3·x^2 + 2·x^3 @ x} @ x}
k_11 = Area{(-6+12·x)^2 @ x=0:1}
