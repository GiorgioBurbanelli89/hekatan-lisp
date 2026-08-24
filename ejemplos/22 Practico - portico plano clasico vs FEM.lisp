# Pórtico plano: CLÁSICO vs FEM
#: Un pórtico de un vano con carga lateral, resuelto por los DOS caminos: el clásico a mano (método del portal, aproximado) y el FEM (matriz de rigidez, exacto). Al final se comparan.

## 1 · El problema
#: Dos columnas y una viga, todas de longitud 1 y rigidez EI=1. Bases empotradas. Carga lateral H=1 empujando la esquina superior izquierda. Sin deformar:
#frame(fixed-fixed, H)

## 2 · MÉTODO CLÁSICO — método del portal (a mano, aproximado)
#: El clásico reparte el cortante del piso entre las columnas y supone un punto de inflexión a media altura de cada una. El cortante por columna es la mitad de la carga:
Vcol = 1/2 @@(H repartido entre 2 columnas)
#: Con la inflexión a media altura, el momento en la base es el cortante por media altura:
M_portal = Vcol*(1/2) @@(momento en la base, aproximado)
#: Da 1/4. Es APROXIMADO: supone la inflexión justo a media altura, que no es exacto en bases empotradas.

## 3 · MÉTODO FEM — rigidez (exacto)
#: Los grados de libertad: giro de la esquina izquierda θ_B, giro de la derecha θ_C, y ladeo Δ. Cada barra aporta su rigidez; ensamblada:
K = [8, 2, -6; 2, 8, -6; -6, -6, 24] @@(rigidez del pórtico)
F = [0; 0; 1] @@(carga lateral H en Δ)
Kinv = K^-1 @@(flexibilidad)
u = Kinv*F @@(u = [θ_B ; θ_C ; Δ])
#: Da θ_B = θ_C = 1/28 y Δ = 5/84. La deformada (amplificada, punteado = sin deformar):
#framedef(5/84, 1/28, 1/28)
#: De la solución saco los momentos de extremo de la columna (giro de cuerda ψ = Δ/h):
psi = 5/84 @@(giro de cuerda)
M_base = 2*(1/28 - 3*psi) @@(momento EXACTO en la base)
M_tope = 2*(2/28 - 3*psi) @@(momento EXACTO en el tope)
#: Da M_base = −2/7 ≈ −0.286 y M_tope = −3/14 ≈ −0.214.

## 4 · Comparación
#: En la base: el clásico (portal) dio 0.25 y el FEM exacto dio 0.286 — el método a mano APROXIMA (supone la inflexión a media altura, que no cae ahí). El FEM da el valor exacto y además los dos extremos distintos (0.286 y 0.214), porque la columna se dobla en doble curvatura. Cuanto más complejo el pórtico, peor la aproximación a mano y más necesario el FEM.
#: Y el método clásico EXACTO (pendiente-deflexión) plantea a mano las mismas ecuaciones de equilibrio que, en forma de matriz, son la K de arriba: el FEM es esa pendiente-deflexión automatizada.
