# Las formas de invertir una matriz — todas dan lo mismo
#: No hay UNA sola manera de hallar A⁻¹, hay varias. Aquí, sobre la MISMA matriz, recorremos cuatro caminos y comprobamos que todos llegan a la misma inversa. Uso una matriz con inversa de números enteros para que se lea claro:
A = [4, 3; 1, 1]
#: (Su determinante es 4·1 − 3·1 = 1, así que la inversa saldrá con enteros.)

## Forma 1 — Adjunta / determinante
#: La clásica para 2×2: **A⁻¹ = adj(A) / det(A)**. El determinante y la adjunta:
det1 = det(A)
adj1 = adj(A)
#: Y la inversa (adjunta dividida por el determinante, que aquí es 1):
inv1 = adj(A) * (1/det(A))
#: → [1, −3; −1, 4].

## Forma 2 — Gauss-Jordan (reducción por filas)
#: Se pega la identidad, [A | I], y se reduce por filas hasta [I | A⁻¹]. Parto de [A | I]:
J0 = [4, 3, 1, 0; 1, 1, 0, 1]
#: **F1 ↔ F2** (pongo un 1 arriba para pivotear cómodo):
J1 = [1, 1, 0, 1; 4, 3, 1, 0]
#: **F2 ← F2 − 4·F1**:
J2 = [1, 1, 0, 1; 0, -1, 1, -4]
#: **F2 ← −F2**, luego **F1 ← F1 − F2**:
J3 = [1, 0, 1, -3; 0, 1, -1, 4]
#: A la derecha quedó A⁻¹ = [1, −3; −1, 4]. Igual que la Forma 1.

## Forma 3 — Cayley-Hamilton
#: Toda matriz cumple su ecuación característica; para 2×2 sale **A⁻¹ = (tr(A)·I − A) / det(A)**. La traza y la identidad:
tr = trace(A)
I2 = [1, 0; 0, 1]
#: Y la inversa por este camino:
inv3 = (tr*I2 - A) * (1/det(A))
#: → [1, −3; −1, 4]. Idéntico, otra vez.

## Forma 4 — Columna a columna (resolviendo sistemas)
#: Cada COLUMNA de A⁻¹ es la solución de un sistema: la 1ª columna resuelve A·c = [1;0]; la 2ª, A·c = [0;1]. (Es justo lo que hace Gauss-Jordan, pero por separado.) Las dos columnas:
e1 = [1; 0]
e2 = [0; 1]
col1 = inv(A) * e1
col2 = inv(A) * e2
#: 1ª columna [1; −1], 2ª columna [−3; 4] → juntas dan A⁻¹ = [1, −3; −1, 4].

## Comprobación — las cuatro coinciden y A·A⁻¹ = I
chk = A * inv(A)
#: A·A⁻¹ = [1 0; 0 1] ✓. Los cuatro caminos —adjunta, Gauss-Jordan, Cayley-Hamilton, por columnas— dan **la misma** inversa [1, −3; −1, 4].

## Nota — también funciona con LETRAS
#: Las mismas fórmulas valen simbólicas. Por ejemplo [x, 1; 1, x]:
S = [x, 1; 1, x]
invS = inv(S)
#: → [x, −1; −1, x] / (x²−1). Simbólico o numérico, es el mismo álgebra.
