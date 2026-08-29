# Las funciones de forma en 2D: el mismo método, en dos direcciones
## En una dimensión el elemento era un tramo con dos nudos y una sola coordenada. En dos dimensiones es un cuadrado patrón con cuatro nudos y dos coordenadas.
## Las dos coordenadas del cuadrado patrón van de menos uno a más uno, igual que el tramo de una dimensión.
## Cuatro nudos, cuatro datos, así que el molde necesita cuatro términos. Este es el molde en dos dimensiones.
base_2 = [1 xi eta xi·eta]
## Se llama bilineal porque es de primer grado en cada dirección por separado: lineal en xi y lineal en eta.
## Ahora se arma la matriz igual que en una dimensión: se evalúa cada término del molde en cada nudo, y cada evaluación es una fila.
## Nudo uno: las dos coordenadas valen menos uno. El primer término sigue valiendo uno, xi vale menos uno, eta vale menos uno, y el producto de los dos vale MÁS uno, porque menos por menos es más.
prod_1 = (-1)·(-1) = 1
fila_1 = [1, -1, -1, 1]
## Nudo dos: xi vale más uno y eta menos uno. El producto vale menos uno.
prod_2 = (1)·(-1) = -1
fila_2 = [1, 1, -1, -1]
## Nudo tres: las dos valen más uno. Todo vale uno.
fila_3 = [1, 1, 1, 1]
## Nudo cuatro: xi menos uno y eta más uno. El producto vuelve a valer menos uno.
fila_4 = [1, -1, 1, -1]
## Apilando las cuatro filas queda la matriz del sistema, igual que en una dimensión.
C_2 = [1, -1, -1, 1; 1, 1, -1, -1; 1, 1, 1, 1; 1, -1, 1, -1]
## Se invierte, y aquí aparecen los cuartos que uno ve en todos los libros.
C2inv = C_2^-1
## Comprobación: la matriz por su inversa da la identidad.
chk = C_2*C2inv
## Y ahora, igual que en una dimensión, cada grado de libertad es un pedido distinto. El primero: el nudo uno vale uno y los otros tres cero.
e_1 = [1; 0; 0; 0]
a_1 = C2inv*e_1
N_1 = base_2*a_1
## Segundo nudo.
e_2 = [0; 1; 0; 0]
a_2 = C2inv*e_2
N_2 = base_2*a_2
## Tercero.
e_3 = [0; 0; 1; 0]
a_3 = C2inv*e_3
N_3 = base_2*a_3
## Y cuarto.
e_4 = [0; 0; 0; 1]
a_4 = C2inv*e_4
N_4 = base_2*a_4
## Y hay una forma más bonita de ver lo mismo: cada función de dos dimensiones es el PRODUCTO de dos funciones de una dimensión, una por cada dirección.
prod_forma = N_1 = (1 - xi)/2·(1 - eta)/2
## Si se expande, sale exactamente lo mismo que dio la matriz.
comp = Expand{(1 - xi)/2·(1 - eta)/2}
## Por eso se llaman bilineales, y por eso el método de una dimensión sirve tal cual en dos.
