# ¿Por qué una integral? Porque el área bajo la curva es la ENERGÍA
## Un resorte no responde con una fuerza fija: la fuerza crece a medida que se estira.
F = k·u
## Por eso el trabajo no es fuerza por distancia. Es el ÁREA que queda debajo de esa recta: un triángulo.
U_res = Area{k·u @ u=0:d}
## Ahí está la primera integral, y ahí está la energía.
## En la viga es lo mismo pero repartido. Lo que mide cuánto se dobla en cada punto es la curvatura: la segunda derivada de la deformada.
H_1p = Diff{1 - 3·x^2 + 2·x^3 @ x}
H_1pp = Diff{-6·x + 6·x^2 @ x}
## En cada rebanada el momento es la rigidez por la curvatura, y otra vez es fuerza por desplazamiento: aparece el cuadrado.
u_reb = EI·kappa^2/2
## Sumar todas las rebanadas es integrar. Esa es la energía de la viga entera.
U_viga = Area{EI·kappa^2/2 @ x=0:L}
## Con la curvatura de la primera Hermite y rigidez unitaria, esa energía sale seis.
U_H1 = Area{(12·x - 6)^2/2 @ x=0:1}
## Y de ahí sale la rigidez: cada número de la matriz es el área bajo el producto de dos curvaturas.
k_11 = Area{(-6+12·x)^2 @ x=0:1}
k_12 = Area{(-6+12·x)·(-4+6·x) @ x=0:1}
## Ese doce y ese seis son los de la matriz de rigidez de la viga. No son mágicos: son áreas.
K_viga = [12, 6, -12, 6; 6, 4, -6, 2; -12, -6, 12, -6; 6, 2, -6, 4]
## Y aquí cierra el círculo con Gauss: la curvatura de una Hermite es una recta, así que su cuadrado es de grado dos.
cuadrado = (-6+12·x)^2
## Gauss con dos puntos acierta hasta grado tres. Sobra. Por eso la rigidez sale EXACTA, no aproximada.
grado_max = 2·2 - 1
