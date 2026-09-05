# El giro no es la curvatura
#: El giro es un ÁNGULO. La curvatura es 1/R, lo cerrado que es el arco.

## El giro: un ángulo, en radianes
t_x = q·L·x^2/4 - q·x^3/6 - q·L^3/24

## La curvatura: cuánto CAMBIA ese ángulo por cada metro que avanzas
k_x = Diff{q·L·x^2/4 - q·x^3/6 - q·L^3/24 @ x}

## EN EL APOYO, x = 0
t_ap = Simplify{q·L·0^2/4 - q·0^3/6 - q·L^3/24} @@(giro MÁXIMO)
k_ap = Simplify{q·L·0/2 - q·0^2/2} @@(curvatura CERO)

## EN EL CENTRO, x = L/2
t_ce = Simplify{q·L·(L/2)^2/4 - q·(L/2)^3/6 - q·L^3/24} @@(giro CERO)
k_ce = Simplify{q·L·(L/2)/2 - q·(L/2)^2/2} @@(curvatura MÁXIMA)

## El radio del arco es el inverso de la curvatura
R_c = 1/kappa

## Y el momento va con la CURVATURA, no con el giro
M_k = M = EI·kappa

## En el apoyo, por eso, el momento es cero
M_ap = EI·0
