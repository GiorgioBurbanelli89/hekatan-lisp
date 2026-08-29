# Las cuatro funciones de forma, deducidas por el motor
## Todas salen del mismo molde: una cúbica con cuatro perillas. Estos son sus cuatro ingredientes.
base = [1 x x^2 x^3]
## Se evalúa la cúbica y su pendiente en las dos puntas. Cada evaluación es una fila, y las cuatro filas arman esta matriz.
C = [1 0 0 0; 0 1 0 0; 1 1 1 1; 0 1 2 3]
## Los datos de las puntas son esa matriz por las perillas. Para ir al revés hace falta la inversa, y el motor la calcula sola.
Cinv = C^-1
## Y ahora lo importante: cada grado de libertad se pide POR SEPARADO. Para el primero, la flecha de la primera punta vale uno y los otros tres valen cero.
e_1 = [1; 0; 0; 0]
## Las perillas de esa función salen de multiplicar la inversa por ese pedido.
a_1 = Cinv*e_1
## Y la función es la base por esas perillas. Esta es la primera, deducida entera, sin escribir nada a mano.
H_1 = base*a_1
## Segundo grado de libertad: ahora el que vale uno es el GIRO de la primera punta.
e_2 = [0; 1; 0; 0]
a_2 = Cinv*e_2
H_2 = base*a_2
## Tercer grado: la flecha de la segunda punta.
e_3 = [0; 0; 1; 0]
a_3 = Cinv*e_3
H_3 = base*a_3
## Y cuarto grado: el giro de la segunda punta.
e_4 = [0; 0; 0; 1]
a_4 = Cinv*e_4
H_4 = base*a_4
## Cuatro pedidos distintos, cuatro juegos de perillas distintos, cuatro funciones distintas. Por eso cada nodo da la suya y no la del otro.
## Y las cuatro de una sola vez son la base por la inversa entera.
N = base*Cinv
## El método no cambia con el elemento. En una barra que solo se estira hay dos grados, así que el molde es una recta.
base_ax = [1 x]
## Se evalúa en las dos puntas y salen dos filas.
C_ax = [1 0; 1 1]
Cax_inv = C_ax^-1
## Y las dos funciones de forma del axial salen igual de solas.
N_ax = base_ax*Cax_inv
## ¿Y por qué una empieza en uno y la otra en cero? Por la misma regla de siempre: cada función vale UNO en su nudo y CERO en el otro. Se comprueba metiendo los valores.
## La primera, en su propio nudo, donde x vale cero.
chk_1a = 1 - 0/L = 1
## Y la misma, en el otro nudo, donde x vale L.
chk_1b = 1 - L/L = 0
## La segunda al revés: cero en el primer nudo...
chk_2a = 0/L = 0
## ...y uno en el segundo.
chk_2b = L/L = 1
## Por eso una se escribe con un uno menos algo y la otra solo con ese algo. Y hay una comprobación bonita: las dos siempre suman uno.
suma = (1 - x/L) + x/L = 1
## Eso significa que si muevo los dos nudos lo mismo, toda la barra se mueve lo mismo sin estirarse nada.
## Y en el tramo patrón, el que va de menos uno a más uno, esas mismas dos llevan un dos abajo, porque el tramo mide dos en vez de L.
Nn_1 = (1 - xi)/2
Nn_2 = (1 + xi)/2
## Se comprueba igual: la primera vale uno en el nudo de la izquierda...
chk_n1 = (1 + 1)/2 = 1
## ...y cero en el de la derecha.
chk_n2 = (1 - 1)/2 = 0
## Mismo procedimiento, distinto molde y distinto número de grados. Eso es todo el método.
