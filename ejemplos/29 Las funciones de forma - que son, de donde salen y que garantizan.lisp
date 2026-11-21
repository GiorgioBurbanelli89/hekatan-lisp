# Las funciones de forma: qué son, de dónde salen y qué garantizan
#: Formulación simbólica del elemento lineal de dos nodos. Las funciones de forma son el corazón del método de los elementos finitos: la receta que reparte los valores nodales por el interior del elemento. Aquí se deducen desde cero, se muestra el procedimiento completo (incluida la inversa de la matriz), y se verifican simbólicamente sus tres propiedades definitorias.

## 1 · Qué es una función de forma
#: En elementos finitos solo se conocen los valores en los nodos. La función de forma es la interpolación que reparte esos valores hacia adentro: cualquier campo —geometría o desplazamiento— se arma como la suma de los valores nodales, cada uno pesado por su función de forma. Para el elemento lineal de dos nodos, un desplazamiento {u} se interpola con {N_1} y {N_2}:
u = [N_1, N_2] * [u1; u2]
#: Es decir {u} = {N_1}·{u1} + {N_2}·{u2}: en el nodo 1 domina {N_1} y en el nodo 2 domina {N_2}. Las dos funciones de forma son rectas que valen 1 en su propio nodo y 0 en el otro. Trazadas sobre {xi} ∈ [−1, 1]:
#fplot((1-x)/2, (1+x)/2, [-1 1])
#: En esta gráfica se aprecian las dos funciones de forma: {N_1} (azul) manda cerca del nodo 1 y se apaga en el nodo 2; {N_2} (naranja) al revés. Donde una vale 1, la otra vale 0; se cruzan en el centro, donde ambas valen 1/2.

## 2 · De dónde salen: la deducción
#: Con dos nodos hay dos grados de libertad, así que la función de forma más simple es una recta con dos coeficientes {a} y {b} por hallar, escrita como la base [1, {xi}] por el vector de coeficientes:
N_i = [1, xi] * [a; b]
#: Los coeficientes se fijan con la propiedad de delta de Kronecker: la función vale 1 en su nodo y 0 en el otro. Al evaluar la base en cada nodo se forman dos ecuaciones. Apilando la base en {xi} = −1 (fila 1) y en {xi} = +1 (fila 2) se obtiene la matriz del sistema:
M = [1, -1; 1, 1]
#: El sistema es M·[{a}; {b}] = [1; 0] para el nodo 1. Para despejar los coeficientes hace falta la INVERSA de M. Y aquí está el procedimiento completo, no solo el resultado. El inverso de una matriz 2×2 se construye en tres pasos: su determinante, su adjunta, y el cociente de una por el otro. El determinante:
detM = det(M)
#: La regla general del inverso 2×2 es {G_inv} = 1/det · adjunta, donde la adjunta intercambia la diagonal y cambia el signo de la otra. Con esa regla, la inversa de M es:
Minv = inv(M)
#: Los coeficientes del nodo 1 salen multiplicando la inversa por el lado derecho [1; 0]:
c_1 = Minv * [1; 0]
#: Y la función de forma del nodo 1 se reconstruye con la base por sus coeficientes. Repitiendo con el lado derecho [0; 1] sale la del nodo 2; ambas de un tiro multiplicando la base por la inversa completa:
N = [1, xi] * Minv
#: Factorizando 1/2, las dos funciones de forma en forma cerrada:
N_1 = (1-xi)/2; N_2 = (1+xi)/2

## 3 · Propiedad 1 — Delta de Kronecker
#: La propiedad que las define: cada función de forma vale 1 en su nodo y 0 en el otro. Se verifica evaluando {N_1} en los dos nodos. Evaluar en {xi} = −1 es multiplicar la base [1, −1] por los coeficientes de {N_1}; en {xi} = +1, la base [1, +1]:
k1 = [1, -1] * c_1
k2 = [1, 1] * c_1
#: Sale {k1} en el nodo 1 y {k2} en el nodo 2: exactamente 1 y 0. La función de forma del nodo 1 «reconoce» su nodo y se anula en el otro. Esto es lo que permite que los valores nodales sean, justamente, los valores de la solución en los nodos.

## 4 · Propiedad 2 — Partición de la unidad
#: La suma de todas las funciones de forma vale 1 en cualquier punto del elemento. Se comprueba sumando las dos —multiplicar la fila [1, 1] por el vector [{N_1}; {N_2}]:
unidad = [1, 1] * [N_1; N_2]
#: El resultado es {unidad}, constante e igual a 1 para todo {xi}. Esta propiedad garantiza que el elemento puede representar un movimiento de cuerpo rígido: si los dos nodos se desplazan lo mismo, {u1} = {u2}, todo el elemento se traslada igual, sin deformarse. Sin ella, el elemento inventaría deformaciones falsas.

## 5 · Propiedad 3 — Reproducen los campos lineales
#: Un elemento lineal debe reproducir EXACTAMENTE cualquier campo de primer grado. Se prueba interpolando un campo lineal de pendiente conocida: si en el nodo 1 ({xi} = −1) el campo vale −1 y en el nodo 2 ({xi} = +1) vale +1, la interpolación debe devolver la recta {xi}:
lineal = [N_1, N_2] * [-1; 1]
#: Sale {lineal}: la interpolación reconstruye el campo lineal sin error. Junto con la partición de la unidad (grado 0), esto asegura que el elemento capta sin error los movimientos de cuerpo rígido y los estados de deformación constante —la condición mínima para que la malla converja a la solución al refinarla.
