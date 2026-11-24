# Sistema de ecuaciones lineales con la matriz inversa
#: Un sistema de ecuaciones se escribe con una **llave**, se pasa a **forma matricial** A·X = b y se resuelve multiplicando los dos lados por la **inversa**: X = A^{-1}·b.
#: Orden de la hoja: primero **con letras** (de dónde sale la fórmula) y después **con números**.

## 1 · Con letras: sistema de 2 × 2
#: El sistema:
#: $a*x + b*y = e; c*x + d*y = f$
#: En forma matricial, los coeficientes van en A, las incógnitas en X y los resultados en b:
A = [a, b; c, d]
X = [x; y]
b_v = [e; f]
#: El producto A·X devuelve las dos ecuaciones (fila por incógnitas):
AX = A*X
#: Se multiplican los dos lados por A^{-1}. Como A^{-1}·A = I y I·X = X, queda X = A^{-1}·b:
X_s = Simplify{inv(A)*b_v}
#: Es la **regla de Cramer**: cada incógnita es un determinante partido por det(A). Por eso det(A) no puede ser cero.
#: **Gráfica 2D.** Con números, por ejemplo 2x + y = 5 y x + 3y = 10, cada ecuación es una **recta** y la solución es el punto donde se **cortan**:
A_2 = [2, 1; 1, 3]
X_2 = inv(A_2)*[5; 10]
#fplot(ec_1 = 5 - 2*x, ec_2 = (10 - x)/3, puntos = [1 3], [-1 4])
#: Si det(A) = 0 las rectas serían **paralelas**: no se cortan y no hay solución (no hay inversa).

## 2 · Con números: sistema de 3 × 3
#: El sistema:
#: $2*x - 2*y + z = 1; -x + y + z = -2; -x + 3*y + 5*z = -4$
#: (Ojo: en muchos apuntes este ejemplo sale con «= 0» en la 2.ª ecuación, pero su solución x = 2, y = 1, z = −1 solo cumple con «= −2». Con «= 0» la solución sería x = −7/3, y = −8/3, z = 1/3.)
#: En forma matricial A·X = b:
A_n = [2, -2, 1; -1, 1, 1; -1, 3, 5]
b_n = [1; -2; -4]
#: **Paso 1 · Determinante** (si fuera 0 no habría inversa):
d_n = det(A_n)
#: **Paso 2 · Adjunta** (cofactores traspuestos):
adj_n = adj(A_n)
#: **Paso 3 · Inversa** = adjunta / determinante. Sale −1/6 por la matriz de enteros:
A_ninv = adj(A_n)/det(A_n)
#: **Paso 4 · Multiplicar los dos lados por la inversa.** A la izquierda A^{-1}·A = I:
I_n = inv(A_n)*A_n
#: Y a la derecha queda la solución:
X_n = inv(A_n)*b_n
#: Es decir: **x = 2, y = 1, z = −1**.
#: **Gráfica 3D.** Con tres incógnitas, cada ecuación es un **plano** (despejando z). Los tres planos se cortan en **un solo punto**, la solución (la cruz):
#surf(plano_1 = 1 - 2*x + 2*y, plano_2 = -2 + x - y, plano_3 = (-4 + x - 3*y)/5, [0 4], [-1 3], punto = [2 1 -1])

## 3 · Comprobación
#: Se ponen los valores en el sistema original: A·X tiene que dar b.
chk = A_n*X_n
#: Da [1; −2; −4] = b: la solución cumple las tres ecuaciones.
