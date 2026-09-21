# Carga móvil HL-93: líneas de influencia (hoja del vídeo cm_influencia)
#: Números de la alcantarilla cajón de 2 celdas de 9.50 m y 6.00 m de alto, losas de 0.50 y 0.55 m, muros de 0.45 m, franja de 1 m. Salen del motor de Hekatan Struct (validation/carga-movil, 191 casos unitarios, 277 posiciones).

## 1 · Dónde está cada eje
#: El eje delantero manda y los otros dos van detrás, a una distancia fija:
x_k = x_F - d_k
#: El peso total de los tres ejes:
P_tot = P_1 + P_2 + P_3

## 2 · Superposición: una solución por nudo
#: El modelo es lineal, así que la respuesta a varias cargas es la suma de las respuestas a cada una. Se resuelve una vez por nudo del tablero con un kilonewton hacia abajo, y después se suma:
R = P_1*IL_1 + P_2*IL_2 + P_3*IL_3

#salto
## 3 · Con números
P_1 = 35
P_2 = 145
P_3 = 145
a_1 = 4.3
P_tot = dec(P_1 + P_2 + P_3, 1)
#: Los rótulos de la pantalla son esas cargas en toneladas fuerza:
rot_delantero = dec(35/9.80665, 2)
rot_trasero = dec(145/9.80665, 2)

## 4 · El momento en el centro de la primera celda
#: Sección de control en x igual a 4.70 m. Con el eje delantero en 9.00 m, los tres ejes quedan en 9.00, en 4.70 y en 0.40 m: los tres dentro del tablero.
IL_a = 0.08349465
IL_b = 1.52989986
IL_c = 0.09497629
M_max = dec(35*IL_a + 145*IL_b + 145*IL_c, 4)
#: El motor, resolviendo el pórtico entero, da exactamente el mismo número. En toneladas fuerza por metro:
M_tonf = dec(M_max/9.80665, 3)

#salto
## 5 · La envolvente
#: Lo peor de todas las posiciones y de todas las separaciones traseras, de 4.30 a 9.00 m. Camión más carga de carril:
M_3max = 297.61
M_3min = -346.99
U_zmin = -12.323
#: Y solo el camión, sin la carga de carril:
M_3maxcam = 241.84
M_3mincam = -254.45
U_zmincam = -9.694
