# De la rigidez al resultado: K·u = F
## PRIMERO EL ÁLGEBRA, sin un número.
## La rigidez de un elemento es la doble integral de la B transpuesta por la constitutiva por la B.
## Ensamblando todos los elementos queda UNA ecuación para toda la estructura: la rigidez por los desplazamientos es igual a las fuerzas.
## Para despejar los desplazamientos se multiplica por la INVERSA de la rigidez.
## Y con los desplazamientos ya se vuelve hacia atrás: la deformación es B por u, y la tensión es D por la deformación.
## AHORA CON NÚMEROS, y primero unos redondos para ver el mecanismo. Una rigidez de dos grados.
K_d = [2, 1; 1, 2]
## Y una fuerza de tres en el primer grado.
F_d = [3; 0]
## Su inversa.
Kd_i = K_d^-1
## Que por la original da la identidad: la inversa es la buena.
chk = K_d·Kd_i
## Y los desplazamientos son la inversa por la fuerza.
u_d = Kd_i·F_d
## Dos y menos uno. Fíjate: el segundo grado se mueve HACIA ATRÁS aunque nadie lo empuje, porque está pegado al primero.
## Comprobación al revés: la rigidez por esos desplazamientos devuelve la fuerza de partida.
F_v = K_d·[2; -1]
## Tres y cero. Exactamente lo que pusimos.
## Y con la rigidez de verdad del muro, en miles de tonelada por metro.
K_r = [173.43, 52.485; 52.485, 173.43]
F_r = [10; 0]
u_r = K_r^-1·F_r
## Que en milímetros son seis centésimas y menos dos centésimas.
