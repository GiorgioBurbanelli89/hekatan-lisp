# Qué es la matriz C: la tabla de un sistema de ecuaciones
## Antes de la viga, lo más simple del mundo. Un sistema de dos ecuaciones con dos incógnitas.
ec_1 = 2·p + 3·q = 8
ec_2 = 1·p + 4·q = 9
## Una matriz no es nada raro: es solo la TABLA de los números que acompañan a las incógnitas.
A_sis = [2 3; 1 4]
## Cada fila es una ecuación. Cada columna es una incógnita. Eso es todo lo que hay que saber.
## Ahora la viga, y es exactamente lo mismo. Las incógnitas son las cuatro perillas de la cúbica.
molde = v_x = c_0 + c_1·x + c_2·x^2 + c_3·x^3
## El giro de la sección es la inclinación de la curva en ese punto. Y la inclinación de una curva es su derivada: por eso el giro es la derivada del molde.
## Y derivar el molde es derivar término a término, despacio. El primer término es una constante: su derivada es cero, así que DESAPARECE.
t_0 = Diff{c_0 @ x}
## El segundo lleva la equis sola: al derivar se queda solo su número.
t_1 = Diff{c_1·x @ x}
## El tercero lleva la equis al cuadrado: BAJA el dos y la potencia se queda en uno.
t_2 = Diff{c_2·x^2 @ x}
## Y el cuarto lleva el cubo: BAJA el tres y la potencia se queda en dos.
t_3 = Diff{c_3·x^3 @ x}
## Juntando los cuatro términos, el giro es esto.
giro = Diff{c_0 + c_1·x + c_2·x^2 + c_3·x^3 @ x}
## Y guarda ese dos y ese tres, porque son los que van a aparecer en la última fila de la tabla. Salieron de bajar las potencias, de ningún otro sitio.
## Los datos conocidos son cuatro: la flecha y el giro de cada punta. Cuatro datos, cuatro incógnitas.
## Primer dato: la flecha en la punta izquierda. Se mete x igual a cero en el molde, y se escriben TODOS los términos, incluso los que se van a cero.
d_1 = v_1 = c_0·1 + c_1·0 + c_2·0 + c_3·0
## Los números que acompañan a las perillas son uno, cero, cero, cero. Esos cuatro números son la primera fila de la tabla.
fila_1 = [1 0 0 0]
## Segundo dato: el giro en la punta izquierda. Se mete cero en la PENDIENTE.
d_2 = th_1 = c_0·0 + c_1·1 + c_2·0 + c_3·0
fila_2 = [0 1 0 0]
## Tercer dato: la flecha en la punta derecha. Se mete el largo, que aquí vale uno, en el molde.
d_3 = v_2 = c_0·1 + c_1·1 + c_2·1 + c_3·1
fila_3 = [1 1 1 1]
## Cuarto dato: el giro en la punta derecha. Se mete uno en la pendiente, y ahí aparecen el dos y el tres, que vienen de derivar el cuadrado y el cubo.
d_4 = th_2 = c_0·0 + c_1·1 + c_2·2 + c_3·3
fila_4 = [0 1 2 3]
## Apilando las cuatro filas queda la tabla del sistema. Eso, y nada más, es la matriz C.
C = [1 0 0 0; 0 1 0 0; 1 1 1 1; 0 1 2 3]
## Escrito corto: los cuatro datos son la tabla por las cuatro perillas.
sistema = datos = C·perillas
## Y para hallar las perillas se le da la vuelta, con la inversa. Hekatan LISP la calcula.
Cinv = C^-1
## Perillas igual a la inversa por los datos. Es despejar, como en cualquier sistema.
despeje = perillas = Cinv·datos
