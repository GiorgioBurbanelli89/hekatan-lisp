# Dónde se mide el giro
#: El giro es la PENDIENTE de la deformada en una sección. No es la curva: es su inclinación.

## La flecha de la viga apoyada
w_x = (q·L·x^3/12 - q·x^4/24 - q·L^3·x/24)/EI

## El giro es su derivada: la PENDIENTE en cada punto
t_x = Diff{q·L·x^3/12 - q·x^4/24 - q·L^3·x/24 @ x}

## En el apoyo de la izquierda, x = 0: el giro es MÁXIMO
t_0 = Simplify{q·L·3·0^2/12 - q·4·0^3/24 - q·L^3/24}

## En el centro, x = L/2: el giro es CERO
t_c = Simplify{q·L·3·(L/2)^2/12 - q·4·(L/2)^3/24 - q·L^3/24}

## Y ahí, en el centro, la flecha es la MÁXIMA
w_c = -5·q·L^4/384

## La curvatura es otra cosa: cómo CAMBIA el giro de una sección a la siguiente
k_x = Diff{Diff{q·L·x^3/12 - q·x^4/24 - q·L^3·x/24 @ x} @ x}
