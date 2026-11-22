# Technical drawing: distributed loads, diagrams and fixed supports

#: Three new primitives of the #dibujo … #fin block (23-Sep-2026), made for sheet 69 on the base plate. They work the same in the desktop app and on the web: the same code makes the drawing.
#| Primitiva | Qué dibuja |
#|---|---|
#| carga(x1, y1, x2, y2, q1, q2, "texto", "estilo", n = 9, sentido = 1) | bloque de carga repartida (trapecio) sobre la cara p1→p2, con flechas hacia la cara |
#| curva(xa, xb, expresión en x, "estilo", base = y0, n = 64) | y = f(x); con base y "relleno" queda un DIAGRAMA pintado |
#| empotramiento(x1, y1, x2, y2, lado) | trazo grueso con el rayado del apoyo empotrado |
#: Rules: q1 and q2 are the block height in drawing units; positive = to the LEFT of p1→p2 (same rule as the dimension line). With direction = -1 the arrows leave the face (tension). The curve is cut automatically where the expression does not exist (root of a negative). In addition, circulo(x, y, r) accepts vectors, and there are two fill styles: «denso» and «tenue».
#: And one sheet directive: **#modo memoria** makes formulas appear as they are written (without simplifying or substituting earlier definitions inside them), which is what a calculation report requires. #modo auto, #modo simplify and #modo expand are also valid.

## A cantilever with distributed load

#dibujo("6 m cantilever with uniform load and its moment diagram", ud = m, cotas = m, ancho = 150, alto = 120)
#  rect(0, -0.15, 6, 0.3, "gruesa")
#  empotramiento(0, -0.6, 0, 0.6, 1)
#  carga(0, 0.15, 6, 0.15, 0.8, 0.8, "q = 20 kN/m", "azul", n = 13)
#  linea(0, -2.2, 6, -2.2, "media")
#  curva(0, 6, -2.2 - 1.3*(1 - x/6)^2, "rojo relleno", base = -2.2)
#  texto(3, -1.9, "M(x) = q·(L − x)^{2}/2: maximum at the fixed support", 2.4, "c", estilo = "rojo")
#  cota(0, -3.6, 6, -3.6, -0.3, "L = 6.00")
#fin

## Tension: the arrows point outward

#dibujo("A plate hung from two bolts", ud = mm, cotas = mm, ancho = 120, alto = 80)
#  rect(0, 0, 300, 25, "gruesa")
#  achurado(0, 0, 300, 25, "cruzado")
#  carga(0, 25, 300, 25, 60, 60, "uniform suction", "verde", sentido = -1, n = 7)
#  circulo([50, 250], [12.5, 12.5], 8, "acero denso")
#fin
