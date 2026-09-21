# Cómo se arma la matriz C, operación por operación
## Antes de la viga, lo más simple del mundo: un sistema de dos ecuaciones con dos incógnitas.
ec_1 = 2·p + 3·q = 8
ec_2 = 1·p + 4·q = 9
## Una matriz no es nada raro: es la TABLA de los números que acompañan a las incógnitas.
A_sis = [2 3; 1 4]
## Cada FILA es una ecuación. Cada COLUMNA es una incógnita. Esa es toda la regla.
## Ahora la viga. Su barra tiene su propio eje: el nudo izquierdo está en la posición cero.
pos_1 = x_1 = 0
## Y el nudo derecho está en la posición del largo, que aquí tomamos igual a uno.
pos_2 = x_2 = L = 1
## Este es el molde, con la equis todavía sin reemplazar. Sus cuatro coeficientes son las incógnitas.
molde = v_x = c_0 + c_1·x + c_2·x^2 + c_3·x^3
## Y esta es la pendiente, que da el giro y sale de derivar el molde.
pend = Diff{c_0 + c_1·x + c_2·x^2 + c_3·x^3 @ x}
## PRIMERA FILA. Dato: la flecha en el nudo izquierdo. Ahí la equis vale cero, así que se reemplaza CADA equis por cero.
sus_1 = c_0 + c_1·(0) + c_2·(0)^2 + c_3·(0)^3
## Se calculan las potencias, y se escribe el número que acompaña a cada coeficiente. Ahí aparecen el uno y los tres ceros.
coef_1 = c_0·1 + c_1·0 + c_2·0 + c_3·0
## Esos cuatro números, en ese orden, son la primera fila de la tabla.
fila_1 = [1 0 0 0]
## SEGUNDA FILA. Dato: el giro en el nudo izquierdo. Se reemplaza la equis por cero, pero ahora en la PENDIENTE.
sus_2 = c_1 + 2·c_2·(0) + 3·c_3·(0)^2
coef_2 = c_0·0 + c_1·1 + c_2·0 + c_3·0
fila_2 = [0 1 0 0]
## TERCERA FILA. Dato: la flecha en el nudo derecho. Ahí la equis vale uno, así que se reemplaza cada equis por uno.
sus_3 = c_0 + c_1·(1) + c_2·(1)^2 + c_3·(1)^3
coef_3 = c_0·1 + c_1·1 + c_2·1 + c_3·1
fila_3 = [1 1 1 1]
## CUARTA FILA. Dato: el giro en el nudo derecho. Se reemplaza por uno en la pendiente, y ahí salen el dos y el tres que bajaron al derivar.
sus_4 = c_1 + 2·c_2·(1) + 3·c_3·(1)^2
coef_4 = c_0·0 + c_1·1 + c_2·2 + c_3·3
fila_4 = [0 1 2 3]
## Y como en cualquier libro de análisis matricial, la tabla se ETIQUETA. Cada FILA lleva el grado de libertad que representa: el desplazamiento o el giro de cada nudo. Cada COLUMNA lleva el coeficiente al que multiplica.
et_v1 = v_1
et_t1 = theta_1
et_v2 = v_2
et_t2 = theta_2
et_c0 = c_0
et_c1 = c_1
et_c2 = c_2
et_c3 = c_3
## Apilando las cuatro filas queda la tabla del sistema. Eso, y nada más, es la matriz C.
C = [1 0 0 0; 0 1 0 0; 1 1 1 1; 0 1 2 3]
## Que dice esto: los cuatro datos de las puntas son la tabla por las cuatro coeficientes.
sistema = datos = C·coeficientes
## Y para hallar las coeficientes se le da la vuelta con la inversa, que calcula Hekatan LISP.
Cinv = C^-1
despeje = coeficientes = Cinv·datos
