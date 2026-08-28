# Álgebra lineal — de lo básico a lo avanzado (todo simbólico; los números, al final)
#: Regla del ejercicio: **primero el álgebra con letras**, se reduce hasta una fórmula sencilla, y **solo al final se reemplazan los valores**. Así se ve el PROCESO, no solo el número. El motor de Hekatan LISP lo resuelve.

## 1 · Escalar: una ecuación lineal
#: Lo más básico: una ecuación con una incógnita, **p·x + q = r**. Se despeja con álgebra pura:
#|  p·x + q = r   →   p·x = r − q   →   x = (r − q) / p
#: Esa es la fórmula general. **Ahora sí** reemplazo p=3, q=2, r=1 (o sea 3x + 2 = 1):
x = Simplify{(1 - 2)/3}
#: Da {x}. El número aparece SOLO al final; el álgebra (despejar) fue simbólica.

## 2 · Vector: operaciones básicas
#: Un vector columna genérico y otro:
u = [u1; u2]
v = [v1; v2]
#: **Producto punto** (fila·columna) → un escalar, simbólico:
punto = transpose(u) * v
#: **Norma al cuadrado** (largo²) = producto punto consigo mismo:
n2s = transpose(u) * u
#: La norma es su raíz: |u| = √(u1²+u2²). **Ahora reemplazo** u=[3;4], v=[1;2]:
un = [3; 4]
vn = [1; 2]
puntoN = transpose(un) * vn
n2N = transpose(un) * un
normaN = sqrt(transpose(un) * un)
#: Punto = {puntoN}, largo² = {n2N}, y la norma |u| = {normaN} (el 3-4-5 de Pitágoras).

## 3 · Matriz: el determinante (simbólico → número)
#: Una matriz 2×2 genérica:
A = [a11, a12; a21, a22]
#: Su **determinante** por álgebra: |A| = a11·a22 − a12·a21:
detSim = det(A)
#: **Reemplazo** A = [2, 1; 1, 3]:
An = [2, 1; 1, 3]
detNum = det(An)
#: |A| = {detNum} (2·3 − 1·1 = 5).

## 4 · La inversa — FORMA 1: adjunta / determinante
#: La forma clásica para 2×2: **A⁻¹ = adj(A) / det(A)**. La adjunta (diagonal cambiada, otra con signo):
adjSim = adj(A)
#: Y el inverso simbólico:
invAdj = adj(A) * (1/det(A))
#: Queda [a22, −a12; −a21, a11] dividido por el determinante. Todo con letras.

## 5 · La inversa — FORMA 2: Cayley-Hamilton
#: Toda matriz cumple su propia ecuación característica. Para 2×2: A² − tr(A)·A + det(A)·I = 0. Despejando: **A⁻¹ = (tr(A)·I − A) / det(A)**. La traza y la identidad:
tr = trace(A)
I2 = [1, 0; 0, 1]
#: Y el inverso por este otro camino:
invCH = (tr*I2 - A) * (1/det(A))
#: **Es IDÉNTICO al de la adjunta** — dos deducciones distintas, la misma matriz. (tr·I − A resulta ser justo la adjunta.)

## 6 · La inversa — FORMA 3: Gauss-Jordan (el método general)
#: El método que usan los programas: se pega la identidad al lado, [A | I], y se reduce por filas hasta [I | A⁻¹]. Es un PROCEDIMIENTO (paso a paso), lo mejor es verlo con números. Parto de [A | I] con A = [2,1;1,3]:
G0 = [2, 1, 1, 0; 1, 3, 0, 1]
#: **F2 ← F2 − ½·F1** (hago 0 bajo el pivote):
G1 = [2, 1, 1, 0; 0, 5/2, -1/2, 1]
#: **F2 ← (2/5)·F2** (pivote = 1):
G2 = [2, 1, 1, 0; 0, 1, -1/5, 2/5]
#: **F1 ← F1 − F2** (hago 0 arriba del pivote):
G3 = [2, 0, 6/5, -2/5; 0, 1, -1/5, 2/5]
#: **F1 ← ½·F1** (pivote = 1). A la izquierda queda la identidad; a la derecha, la inversa:
G4 = [1, 0, 3/5, -1/5; 0, 1, -1/5, 2/5]
#: La mitad derecha es A⁻¹ = [3/5, −1/5; −1/5, 2/5].

## 7 · Reemplazo final: las TRES formas dan lo mismo
#: Ahora sustituyo A = [2, 1; 1, 3] en las dos simbólicas y comparo con Gauss-Jordan:
invNum = inv(An)
#: **A⁻¹ = {invNum}** — igual que Cayley-Hamilton e igual que la mitad derecha de Gauss-Jordan. La prueba de que es la inversa: A·A⁻¹ = identidad:
chk = An * inv(An)
#: [1 0; 0 1] ✓. Tres caminos distintos, un solo resultado.

## 8 · Avanzado: resolver un sistema A·x = b
#: Lo mismo sirve para resolver. Simbólico: **x = A⁻¹·b**:
b = [b1; b2]
xSim = inv(A) * b
#: **Reemplazo** A = [2,1;1,3] y b = [5; 10]:
bn = [5; 10]
xNum = inv(An) * bn
#: Solución x = {xNum}. (Comprobación: 2·1+1·3=5 ✓, 1·1+3·3=10 ✓.)

## 9 · Resumen
#: · Siempre: **álgebra con letras primero**, número **al final**.
#: · Inversa de 2×2: **adjunta/det** y **Cayley-Hamilton** dan lo mismo simbólicamente; **Gauss-Jordan** lo consigue por reducción de filas.
#: · Resolver A·x = b = montar A, montar b, y x = A⁻¹·b. Es el núcleo del cálculo estructural (K·d = F).
