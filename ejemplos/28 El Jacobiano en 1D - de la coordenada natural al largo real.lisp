# El Jacobiano en 1D: la transformación isoparamétrica del elemento lineal
#: Formulación simbólica del elemento lineal de dos nodos. El objetivo es definir el Jacobiano de la transformación isoparamétrica: el escalar que relaciona la coordenada natural con la coordenada física del elemento.

## 1 · La coordenada natural ξ y el elemento de referencia
#: En el método de los elementos finitos cada elemento del dominio físico se formula sobre un elemento de referencia de geometría fija, parametrizado por la coordenada natural {xi}. Para el elemento lineal de dos nodos, {xi} recorre el intervalo [−1, 1], según la convención isoparamétrica estándar (Zienkiewicz, Bathe, Hughes).
#: El intervalo simétrico [−1, 1] no es arbitrario: sitúa el origen paramétrico en el centro del elemento y coincide con el dominio de integración de la cuadratura de Gauss–Legendre, con la que se evalúa la matriz de rigidez. La geometría real, de longitud {L}, se recupera mediante la transformación isoparamétrica, cuyo factor de escala es el Jacobiano. El elemento de referencia {xi} ∈ [−1, 1] y su imagen en el dominio físico [0, {L}]:
#bar1d
#: En esta gráfica se aprecia el mismo elemento visto de dos maneras: arriba, en coordenada natural {xi} (de −1 a +1, siempre igual, mida lo que mida la barra); abajo, en la barra real (de 0 a {L}). La flecha es el mapa que estira el segmento de referencia sobre la barra física.

## 2 · Deducción de las funciones de forma
#: Las funciones de forma no se postulan de memoria: se deducen. El elemento tiene dos nodos, es decir dos grados de libertad, de modo que la función más simple que los interpola es una recta: N = {a} + {b}·{xi}, con dos números por determinar, {a} y {b}.
#: Cuidado con un malentendido común: {a} y {b} NO son puntos de la barra —esa es la geometría, la de arriba—. Son los dos números que definen la recta, igual que en y = m·x + c: {a} es el intercepto (la altura de N en el centro, {xi} = 0) y {b} es la pendiente (cuánto cambia N por cada paso de {xi}). Para la función de forma del nodo 1 se ven así:
#recta
#: En esta gráfica se aprecia que la función de forma es una recta que baja de 1 (en su nodo) a 0 (en el otro). El punto verde es {a}: la altura de la recta en el centro ({xi} = 0). El triángulo ámbar es {b}: la pendiente, cuánto baja la recta al avanzar 1 en {xi}. Ni {a} ni {b} son puntos de la barra; son la altura y la inclinación de esta recta.
#: Esa misma recta se escribe como un producto de la base [1, {xi}] por el vector de coeficientes [{a}; {b}]. No es nada nuevo: el producto fila·columna multiplica término a término y suma —uno por {a}, más {xi} por {b}—, que reproduce exactamente la recta {N_i}:
N_i = [1, xi] * [a; b]
#: Ese producto se llama producto punto. Se hace por partes: se emparejan los elementos en el mismo orden, se multiplica cada pareja y se suman. En el dibujo, cada pareja lleva un color —1 con {a} en azul, {xi} con {b} en coral—:
#punto
#: Lo mismo como operaciones del motor. El primero de la fila (1) con el primero de la columna ({a}); el segundo de la fila ({xi}) con el segundo de la columna ({b}):
p_1 = 1*a
p_2 = xi*b
#: La primera pareja da 1 por {a} = {a}; la segunda da {xi} por {b}. Se suman las dos parejas, y esa suma es la recta completa:
suma = 1*a + xi*b
#: Es decir {suma}. Eso es todo el producto punto: emparejar, multiplicar cada pareja, sumar.
#: ¿Por qué el rodeo? Porque SEPARA dos cosas distintas: la base [1, {xi}] contiene lo que depende de la posición {xi}; el vector [{a}; {b}] contiene los coeficientes que busco. Esa separación hace mecánico el paso siguiente.
#: Los coeficientes se fijan con la propiedad de delta de Kronecker: la función de forma de un nodo vale la unidad en ese nodo y se anula en el otro. Aplicarla es sencillo: evaluar la recta en un nodo significa meter el valor de {xi} de ese nodo. Al hacerlo, solo cambia la base —el vector de coeficientes [{a}; {b}] queda intacto—.
#: Nodo 1 ({xi} = −1): al meter {xi} = −1 la base [1, {xi}] se vuelve [1, −1], de modo que la función de forma en ese punto es:
e_1 = [1, -1] * [a; b]
#: El vector [1, −1] no es nada nuevo: es la recta con {xi} = −1, escrita corta. Como {N_i} debe valer 1 en el nodo 1, se obtiene la primera ecuación: {e_1} = 1. Nodo 2 ({xi} = +1): la base se vuelve [1, +1], y la función en ese punto es:
e_2 = [1, 1] * [a; b]
#: Como debe anularse en el nodo 2, la segunda ecuación es {e_2} = 0. Ya hay dos ecuaciones con dos incógnitas: {a} − {b} = 1 y {a} + {b} = 0. Apilando las dos filas —cada una es la base evaluada en un nodo— se forma la matriz del sistema:
M = [1, -1; 1, 1]
#: El sistema es entonces M·[{a}; {b}] = [1; 0], donde el lado derecho recoge los valores nodales de {N_1} (1 en el nodo 1, 0 en el nodo 2). Se resuelve invirtiendo la matriz:
c_1 = inv(M) * [1; 0]
#: Los coeficientes buscados son {c_1}: {a} = 1/2 y {b} = −1/2. La función de forma del nodo 1 se reconstruye multiplicando la base por su vector de coeficientes:
N_1 = [1, xi] * c_1
#: Repitiendo con el lado derecho [0; 1] se obtiene la del nodo 2. Ambas salen de un solo producto, multiplicando la base por la inversa completa del sistema:
N = [1, xi] * inv(M)
#: El resultado, factorizando 1/2, son las dos funciones de forma lineales en forma cerrada:
N_1 = (1-xi)/2; N_2 = (1+xi)/2
#: Todo campo interpolado —geometría o desplazamiento— se expresa como combinación lineal de las funciones de forma ponderadas por los valores nodales: {N_1} por el valor en el nodo 1 más {N_2} por el valor en el nodo 2. Al ser de primer grado, la interpolación es exacta para campos lineales. Trazadas sobre {xi} ∈ [−1, 1], cada función de forma es una recta que pasa por 1 en su nodo y por 0 en el otro; se cruzan en {xi} = 0, donde ambas valen 1/2:
#fplot((1-x)/2, (1+x)/2, [-1 1])
#: En esta gráfica se aprecian las dos funciones de forma juntas: {N_1} (azul) baja de 1 a 0, {N_2} (naranja) sube de 0 a 1. Cada una vale 1 en su propio nodo y 0 en el otro —la propiedad de delta de Kronecker— y ambas se cruzan en el centro, donde valen 1/2. Que sumen 1 en todo punto garantiza que la interpolación reproduce cualquier campo constante.

## 3 · El mapeo isoparamétrico: de ξ a la coordenada física x
#: En la formulación isoparamétrica la geometría y el campo de desplazamientos se interpolan con las mismas funciones de forma. La coordenada física {x} se obtiene interpolando las coordenadas nodales; con el nodo 1 en el origen y el nodo 2 en {L}, subsiste únicamente el término asociado a {N_2}:
x = N_2 * L
#: Se comprueban los valores en los extremos: en {xi} = −1 se recupera el nodo 1 ({x} = 0) y en {xi} = +1 el nodo 2 ({x} = {L}). La transformación aplica el elemento de referencia, de medida 2, sobre el dominio físico de longitud {L}. La relación entre la coordenada física {x} y la natural {xi} es una recta; en gráfica:
#mapa1d
#: En esta gráfica se aprecia que la coordenada física {x} crece en línea recta con la natural {xi}: en {xi} = −1 vale 0, en {xi} = +1 vale {L}, y en el centro {L}/2. Esa recta ES el mapa isoparamétrico; su inclinación constante es justamente el Jacobiano que sigue.

## 4 · El Jacobiano de la transformación
#: El Jacobiano de la transformación isoparamétrica es la derivada de la coordenada física respecto de la coordenada natural: mide la razón de cambio entre ambos dominios. Para el elemento lineal es un escalar:
J = Diff{x @ xi}
#: Resulta {J}, coherente con la relación de medidas: el elemento de referencia mide 2 y el físico {L}, de modo que el Jacobiano es el factor de escala de la transformación. Su valor gobierna el cambio de variable de toda integral sobre el elemento, requisito de la integración por cuadratura de Gauss.

## 5 · La inversa del Jacobiano y la matriz de deformación
#: El Jacobiano interviene en ambos sentidos. En sentido directo, un diferencial de la coordenada natural se transporta al dominio físico escalado por {J} —el factor que acompaña a la integración numérica. En sentido inverso, la matriz de deformación B exige las derivadas de las funciones de forma respecto de la coordenada física {x}; como éstas se definen en {xi}, la regla de la cadena introduce el Jacobiano inverso:
J_inv = 1/J
#: Se obtiene {J_inv}. Con el Jacobiano {J} y su inversa {J_inv} queda definido el operador que transporta las derivadas entre el dominio de referencia y el físico, base para ensamblar la matriz de deformación B y, a partir de ella, la matriz de rigidez del elemento.
