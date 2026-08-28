# Resolver un sistema de ecuaciones — con NÚMEROS y las incógnitas x, y
#: Sin coeficientes abstractos (nada de a₁₁, a₁₂): números de verdad como coeficientes y las incógnitas **x, y**. Es el uso más práctico del álgebra lineal: resolver un sistema. Solo al final se reemplazan los valores hallados.

## 1 · El sistema (dos ecuaciones, dos incógnitas)
#|  2x +  y = 5
#|   x + 3y = 10

## 2 · En forma matricial: A · X = b
#: Los coeficientes (números) van en la matriz **A**; las incógnitas en el vector **X**; los resultados en **b**:
A = [2, 1; 1, 3]
xy = [x; y]
b = [5; 10]
#: El producto A·X reproduce las ecuaciones —fila por incógnitas—:
AX = A * xy
#: A·X = {AX}. Igualado a b = [5; 10] son justo **2x+y = 5** y **x+3y = 10**. Así una tabla de números y un vector de incógnitas guardan TODO el sistema.

## 3 · ¿Tiene solución? El determinante
#: De A·X = b se despeja **X = A⁻¹·b** (como dividir, pero con matrices). Antes, el determinante dice si A tiene inversa:
detA = det(A)
#: |A| = 5 ≠ 0 → **sí** tiene inversa, el sistema tiene solución única.

## 4 · La inversa de A — FORMA 1: adjunta / determinante
#: **A⁻¹ = adj(A) / det(A)**. La adjunta (diagonal cambiada, la otra con signo):
adjA = adj(A)
#: Y el inverso:
invA = adj(A) * (1/det(A))
#: → (1/5)·[3, −1; −1, 2].

## 5 · La inversa de A — FORMA 2: Cayley-Hamilton
#: Otra vía: A⁻¹ = (tr(A)·I − A) / det(A). La traza y la identidad:
tr = trace(A)
I2 = [1, 0; 0, 1]
invCH = (tr*I2 - A) * (1/det(A))
#: **Idéntico** al de la adjunta — dos caminos, la misma inversa.

## 6 · La inversa de A — FORMA 3: Gauss-Jordan
#: El método general: se pega la identidad, [A | I], y se reduce por filas hasta [I | A⁻¹]. Parto de [A | I]:
G0 = [2, 1, 1, 0; 1, 3, 0, 1]
#: **F2 ← F2 − ½·F1**:
G1 = [2, 1, 1, 0; 0, 5/2, -1/2, 1]
#: **F2 ← (2/5)·F2**, luego **F1 ← F1 − F2**, luego **F1 ← ½·F1**:
G2 = [1, 0, 3/5, -1/5; 0, 1, -1/5, 2/5]
#: A la derecha quedó A⁻¹ = [3/5, −1/5; −1/5, 2/5]. Las tres formas dan lo mismo.

## 7 · La solución: X = A⁻¹·b
sol = inv(A) * b
#: **X = [1; 3]**, es decir **x = 1, y = 3**. La solución de las mismas ecuaciones era A⁻¹·b.

## 8 · Comprobación: reemplazo x = 1, y = 3 en el sistema
#: Recién AHORA pongo los valores hallados en las ecuaciones originales:
eq1 = 2*1 + 1*3
eq2 = 1*1 + 3*3
#: 2x+y = {eq1} = 5 ✓  ·  x+3y = {eq2} = 10 ✓. Las dos se cumplen: la solución es correcta.

## 9 · Resumen
#: · Un sistema **2x+y=5, x+3y=10** se guarda como **A·X = b** (números en A, incógnitas x,y en X).
#: · Se resuelve con la **inversa**: X = A⁻¹·b. La inversa de 2×2 sale por **adjunta/det**, **Cayley-Hamilton** (igual) o **Gauss-Jordan** (por filas).
#: · Resultado x=1, y=3; se comprueba reemplazando en las ecuaciones. Es el mismo A·X=b del FEM (K·d=F).
