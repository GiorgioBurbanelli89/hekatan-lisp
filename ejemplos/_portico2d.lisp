# La matriz de rigidez de un pórtico plano, desde sus funciones de forma
## En un pórtico plano cada nudo tiene tres grados de libertad: se corre en horizontal, se corre en vertical, y gira.
gdl_nudo = 3
## Cada barra toca dos nudos, así que su matriz de rigidez es de seis por seis.
gdl_barra = 2·3
## Dentro de una barra hay dos físicas que no se mezclan: estirarse a lo largo, y doblarse.
## Para estirarse solo hay dos datos, uno en cada punta. Con dos datos la función de forma es una RECTA.
N_1 = 1 - x/L
N_2 = x/L
## La deformación axial es la derivada de esa recta: sale constante.
eps = Diff{1 - x/L @ x}
## Integrar su energía a lo largo de la barra da la rigidez axial de siempre: la de un resorte.
k_ax = EA/L
## Para doblarse hay CUATRO datos: cuánto baja y cuánto gira cada punta. Con cuatro datos la función de forma es una CÚBICA: las Hermite.
H_1 = 1 - 3·x^2 + 2·x^3
H_2 = x - 2·x^2 + x^3
H_3 = 3·x^2 - 2·x^3
H_4 = -x^2 + x^3
## La curvatura es la segunda derivada, y de integrar los productos de curvaturas salen los números de la flexión.
k_11 = Area{(-6+12·x)^2 @ x=0:1}
k_12 = Area{(-6+12·x)·(-4+6·x) @ x=0:1}
k_22 = Area{(-4+6·x)^2 @ x=0:1}
## Con eso se arma la matriz de la barra en sus propios ejes. El orden es: corre, baja y gira en cada punta.
K_local = [1, 0, 0, -1, 0, 0; 0, 12, 6, 0, -12, 6; 0, 6, 4, 0, -6, 2; -1, 0, 0, 1, 0, 0; 0, -12, -6, 0, 12, -6; 0, 6, 2, 0, -6, 4]
## Fíjate en los ceros: el estirarse y el doblarse no se hablan. Son dos bloques separados dentro de la misma matriz.
## Pero esa matriz está en los ejes de la BARRA, y el pórtico se resuelve en los ejes del edificio. Hay que girarla.
Rot_giro = [c, s, 0; -s, c, 0; 0, 0, 1]
## En una columna la barra está vertical: el coseno vale cero y el seno vale uno.
Rot_col = [0, 1, 0; -1, 0, 0; 0, 0, 1]
## Y la matriz girada es la transpuesta por la matriz por la matriz de giro.
K_giro = transpose(Rot_col)·[1, 0, 0; 0, 12, 6; 0, 6, 4]·Rot_col
## Mira lo que pasó: la rigidez axial, que en la barra estaba en el primer sitio, en el edificio pasó al segundo. La columna aguanta el peso en vertical.
## Y ya en ejes del edificio se ENSAMBLA: en cada nudo se suman las barras que llegan.
k_BB = 4 + 4
k_DD = 12 + 12
K_portico = [8, 2, -6; 2, 8, -6; -6, -6, 24]
## Eso es todo: funciones de forma, integrar, girar y sumar. No hay ningún dato mágico.
