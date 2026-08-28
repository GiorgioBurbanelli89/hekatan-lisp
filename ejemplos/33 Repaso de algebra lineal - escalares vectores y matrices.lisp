# Repaso de álgebra lineal — todo simbólico (escalares, vectores, matrices)
#: Un repaso de las operaciones del álgebra lineal, TODAS resueltas de forma **simbólica** (con letras, sin números). Es exactamente lo que el FEM usa por dentro: sumar, multiplicar, transponer, invertir y **resolver sistemas**. El motor de Hekatan LISP hace cada operación y muestra el resultado con letras.

## 1 · Escalares: la operación más simple
#: Un escalar es un solo número (aquí, una letra). El álgebra con escalares es la que ya conoces: sumar, multiplicar, y **simplificar**. Por ejemplo, sacar factor común y cancelar:
frac = Simplify{(p*q + p*r)/p}
#: El motor factorizó la {p} arriba y la canceló con la de abajo → queda {frac}. Y despejar es dividir: si m·x = t, entonces x = t/m. Todo con UNA incógnita. El álgebra LINEAL aparece cuando hay VARIAS incógnitas a la vez: ahí entran los vectores y las matrices.

## 2 · Vectores: una lista ordenada de números
#: Un vector agrupa varios números en una columna (piensa en una "flecha" con dirección y largo). Aquí dos vectores de dos componentes:
u = [u1; u2]
v = [v1; v2]
#: **Suma**: componente a componente (juntar dos flechas punta con cola):
suma = u + v
#: **Escalar por vector**: estira o encoge la flecha; multiplica cada componente por el mismo número:
esc = k * u
#: **Transpuesta**: pone la columna en fila (se escribe uᵀ). Es lo que convierte una columna en fila para poder multiplicar:
uf = transpose(u)
#: **Producto punto** uᵀ·v: multiplica pareja a pareja y suma. Da UN solo número (un escalar):
dot = transpose(u) * v
#: ¿Para qué sirve? Mide cuánto **apuntan en la misma dirección** dos vectores. Si el producto punto es 0, son **perpendiculares**. Es la base de proyecciones, ángulos y del trabajo en física (fuerza·desplazamiento).
#: **Norma** (el largo del vector): la raíz del producto punto consigo mismo. Primero el largo al cuadrado:
n2 = transpose(u) * u
#: {n2} es u1²+u2² — el **teorema de Pitágoras**. El largo real es su raíz, |u| = √(u1²+u2²).

## 3 · Matrices: una tabla que TRANSFORMA vectores
#: Una matriz es una tabla de números. Lo importante no es la tabla: es que una matriz **transforma** un vector en otro (lo gira, lo estira, lo refleja). Dos matrices de 2×2:
A = [a11, a12; a21, a22]
Bm = [b11, b12; b21, b22]
#: **Suma**: componente a componente, igual que los vectores:
sumaM = A + Bm
#: **Producto A·B**: cada entrada es el **producto punto** de una fila de A por una columna de B. Encadena dos transformaciones (primero B, luego A):
AB = A * Bm
#: **OJO — el orden importa**: en general A·B ≠ B·A. Míralo:
BA = Bm * A
#: **Transpuesta** Aᵀ: refleja la tabla por la diagonal (las filas se vuelven columnas):
At = transpose(A)

## 4 · Determinante: ¿la matriz aplasta el espacio?
#: El determinante es UN número que dice cuánto **agranda o encoge las áreas** la transformación. Para una 2×2:
dA = det(A)
#: Es a11·a22 − a12·a21. Lo clave: si **det = 0**, la matriz aplasta el plano contra una línea (pierde información) y **no se puede deshacer** → no tiene inversa. Si det ≠ 0, sí la tiene.

## 5 · La inversa: deshacer la transformación
#: La inversa A⁻¹ es la matriz que **deshace** lo que hace A. Se arma con la adjunta y el determinante. **Adjunta** (intercambia la diagonal principal y le cambia el signo a la otra):
adjA = adj(A)
#: **Inversa** = adjunta dividida por el determinante:
iA = inv(A)
#: Y la prueba de que de verdad "deshace": A por su inversa da la **identidad** (la matriz que no hace nada, como el 1 de los números):
chk = A * inv(A)
#: Sale [1 0; 0 1] ✓. Multiplicar por la identidad deja todo igual. Y al revés también: A⁻¹·A = I.

## 6 · Resolver un sistema: A·x = b
#: Esto es para lo que sirve TODO lo anterior: encontrar el vector **x** que la matriz A transforma en un **b** dado. Es el corazón del FEM: **K·d = F** (rigidez × desplazamientos = fuerzas). Se despeja igual que un escalar, pero usando la **inversa** en vez de dividir:
#|  A·x = b   →   x = A⁻¹·b
bb = [b1; b2]
x = inv(A) * bb
#: Ahí está la solución: los desplazamientos en función de la rigidez A y las cargas b —simbólica y exacta—. Eso es, en esencia, lo que hace un programa de estructuras: monta A (la rigidez), monta b (las cargas) y despeja **x = A⁻¹·b**.

## 7 · Resumen
#: · **Escalar**: un número. Se simplifica y se despeja dividiendo.
#: · **Vector**: una lista. Se suma, se escala, y el producto punto (uᵀv) da un escalar que mide alineación.
#: · **Matriz**: una tabla que transforma. Se suma, se multiplica (¡el orden importa!) y se transpone.
#: · **Determinante**: un número; si es 0, la matriz no tiene inversa.
#: · **Inversa**: deshace la transformación (A·A⁻¹ = I).
#: · **Sistema A·x = b**: se resuelve con x = A⁻¹·b. Es el motor de todo cálculo estructural.
