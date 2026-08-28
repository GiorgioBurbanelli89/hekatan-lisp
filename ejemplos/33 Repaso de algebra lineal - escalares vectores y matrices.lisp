# Repaso de álgebra lineal — todo simbólico (escalares, vectores, matrices)
#: Un repaso COMPLETO de las operaciones del álgebra lineal, TODAS resueltas de forma **simbólica** (con letras, sin números). Es exactamente lo que el FEM usa por dentro. El motor de Hekatan LISP hace cada operación y muestra el resultado con letras.

## 1 · Escalares: el álgebra de un solo número
#: Un escalar es un solo número (aquí, una letra). Con escalares se hace el álgebra que ya conoces.
#: **Factor común y cancelar**:
frac = Simplify{(p*q + p*r)/p}
#: **Expandir un binomio** (multiplicar y agrupar):
ex = Expand{(p+q)^2}
#: **Sumar fracciones** (denominador común):
sf = Simplify{1/p + 1/q}
#: Todo con UNA incógnita. El álgebra LINEAL aparece cuando hay VARIAS a la vez: ahí entran vectores y matrices.

## 2 · Vectores: una lista ordenada de números
#: Un vector agrupa varios números en una columna (una "flecha" con dirección y largo):
u = [u1; u2]
v = [v1; v2]
#: **Suma** (componente a componente):
suma = u + v
#: **Resta**:
resta = u - v
#: **Escalar por vector** (estira o encoge la flecha):
esc = k * u
#: **Combinación lineal** (mezcla de dos vectores con pesos al y be):
comb = al*u + be*v
#: **Transpuesta** (columna → fila), se escribe uᵀ:
uf = transpose(u)
#: **Producto punto** uᵀ·v: pareja a pareja y suma. Da UN escalar. Mide cuánto **apuntan igual** dos vectores (si es 0, son perpendiculares):
dot = transpose(u) * v
#: **Norma al cuadrado** (el largo²): producto punto consigo mismo = u1²+u2² (Pitágoras):
n2 = transpose(u) * u
#: **Producto exterior** u·vᵀ (columna × fila): al revés del punto, da una MATRIZ:
ext = u * transpose(v)

## 3 · Producto cruz (vectores en 3D)
#: Solo en 3D. Dos vectores de tres componentes:
w = [w1; w2; w3]
z = [z1; z2; z3]
#: El **producto cruz** w×z da un vector **perpendicular** a los dos (sirve para normales de superficies, momentos, áreas):
cr = cross(w, z)

## 4 · Matrices: una tabla que TRANSFORMA vectores
#: Una matriz transforma un vector en otro (lo gira, lo estira). Dos de 2×2:
A = [a11, a12; a21, a22]
Bm = [b11, b12; b21, b22]
#: **Suma** y **resta** (componente a componente):
sumaM = A + Bm
restaM = A - Bm
#: **Escalar por matriz** (multiplica cada entrada):
kA = k * A
#: **Matriz por vector** A·u: ASÍ transforma un vector (cada componente es un producto punto fila·vector):
Au = A * u
#: **Producto de matrices** A·B (encadena dos transformaciones):
AB = A * Bm
#: **OJO, el orden importa**: en general A·B ≠ B·A:
BA = Bm * A
#: **Potencia** A² = A·A (aplicar la misma transformación dos veces):
A2 = A * A
#: **Transpuesta** Aᵀ (refleja por la diagonal, filas ↔ columnas):
At = transpose(A)
#: **Traza** tr(A): la suma de la diagonal (un escalar; sale en autovalores y en invariantes):
tr = trace(A)

## 5 · Determinante: ¿la matriz aplasta el espacio?
#: El determinante es UN número: cuánto agranda o encoge las áreas la transformación:
dA = det(A)
#: Es a11·a22 − a12·a21. Si **det = 0**, la matriz aplasta el plano a una línea → **no tiene inversa**. Si det ≠ 0, sí.

## 6 · La inversa: deshacer la transformación
#: **Adjunta** (intercambia la diagonal, cambia el signo a la otra):
adjA = adj(A)
#: **Inversa** = adjunta ÷ determinante:
iA = inv(A)
#: Prueba de que "deshace": A por su inversa da la **identidad** (la matriz que no hace nada):
chk = A * inv(A)
#: Sale [1 0; 0 1] ✓. Y al revés también, A⁻¹·A = I.

## 7 · Propiedades que conviene tener a la vista
#: **La transpuesta de un producto invierte el orden**: (A·B)ᵀ = Bᵀ·Aᵀ. Míralo —las dos dan la MISMA matriz—:
lhs = transpose(A * Bm)
rhs = transpose(Bm) * transpose(A)
#: **La identidad no cambia nada**: A·I = A (como multiplicar por 1). Con la identimatriz:
Id = [1, 0; 0, 1]
AI = A * Id

## 8 · Resolver un sistema: A·x = b
#: Para esto sirve TODO lo anterior: encontrar el vector **x** que A transforma en un **b** dado. Es el corazón del FEM: **K·d = F** (rigidez × desplazamientos = fuerzas). Se despeja con la INVERSA (como dividir, pero con matrices):
#|  A·x = b   →   x = A⁻¹·b
bb = [b1; b2]
x = inv(A) * bb
#: Ahí está la solución: los desplazamientos en función de la rigidez A y las cargas b —simbólica y exacta—. Eso es, en esencia, lo que hace un programa de estructuras: monta A, monta b y despeja **x = A⁻¹·b**.

## 9 · Resumen
#: · **Escalar**: sumar, multiplicar, expandir, simplificar, despejar.
#: · **Vector**: suma, resta, escalar, combinación lineal; punto (uᵀv → escalar), exterior (uvᵀ → matriz), cruz (3D → perpendicular).
#: · **Matriz**: suma, resta, escalar, producto (¡el orden importa!), potencia, transpuesta, traza.
#: · **Determinante**: si es 0, no hay inversa. · **Inversa**: deshace (A·A⁻¹ = I).
#: · **Sistema A·x = b** → x = A⁻¹·b. El motor de todo cálculo estructural.
