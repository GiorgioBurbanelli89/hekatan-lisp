# Álgebra lineal estilo Baldor — ejercicios simbólicos y numéricos
#: Como los ejercicios de Baldor, pero para álgebra lineal: unos con **letras** (álgebra pura), otros con **números**. El motor de Hekatan LISP los resuelve. Cada uno: se plantea y se resuelve.

## Ejercicio 1 — Inversa de una matriz SIMBÓLICA
#: Dada A, hallar det(A), su adjunta, su inversa, y comprobar A·A⁻¹ = I.
A = [x, 1; 1, x]
dA = det(A)
adjA = adj(A)
iA = inv(A)
chkA = A * inv(A)
#: |A| = x²−1; la inversa es [x, −1; −1, x] / (x²−1); y A·A⁻¹ = I (la identidad, simbólica). ✓

## Ejercicio 2 — Con DOS letras
#: Ahora con x e y. Hallar det e inversa de B.
B = [x, y; y, x]
dB = det(B)
iB = inv(B)
#: |B| = x²−y²; inversa = [x, −y; −y, x] / (x²−y²).

## Ejercicio 3 — Entradas que son POLINOMIOS (¡ojo al resultado!)
#: Las entradas son expresiones. Hallar el determinante de C.
C = [x+1, x; x, x-1]
dC = det(C)
#: |C| = (x+1)(x−1) − x·x = x²−1 − x² = **−1**. El álgebra se cancela: sale una constante.

## Ejercicio 4 — Producto de matrices simbólicas
#: Multiplicar dos matrices con letras (cada entrada = fila·columna):
P = [x, 1; 0, x] * [x, 0; 1, x]
#: Da [x²+1, x; x, x²]. El orden importa; aquí quedó así.

## Ejercicio 5 — Determinante de una 3×3 SIMBÓLICA
#: Una matriz tridiagonal 3×3. Hallar su determinante (expansión por cofactores):
D = [x, 1, 0; 1, x, 1; 0, 1, x]
dD = det(D)
#: |D| = x·(x²−1) − 1·(x) = **x³ − 2x**. Todo simbólico, sin un solo número.

## Ejercicio 6 — Ahora con NÚMEROS
#: La misma teoría, con coeficientes numéricos. Hallar det e inversa:
N = [2, 1; 1, 3]
dN = det(N)
iN = inv(N)
#: |N| = 5; inversa = (1/5)·[3, −1; −1, 2] = [3/5, −1/5; −1/5, 2/5].

## Ejercicio 7 — Resolver un sistema SIMBÓLICO A·X = b
#: Con la matriz del ej.1 y un lado derecho con letras p, q. Despejar X = A⁻¹·b:
rhs = [p; q]
sol = inv(A) * rhs
#: X = [ (x·p − q)/(x²−1) ; (x·q − p)/(x²−1) ]. La solución del sistema, con LETRAS. Sustituyendo valores (x, p, q) saldrían los números.

## Cierre
#: · Simbólico y numérico son **el mismo álgebra**: det, adjunta, inversa, producto, sistemas.
#: · Con letras se ve la FÓRMULA general; con números, el resultado concreto. Baldor, pero para matrices.
