# La excentricidad no es una carga fuera de la columna

#: En los dibujos de las hojas 48 y 54 aparece un punto de carga CORRIDO respecto al eje de la columna, y la duda es buena: por ahí no baja nada. **La carga baja por la columna, centrada, siempre.** Lo que está corrido es otra cosa, y esta hoja la separa.

## 1 · Lo que de verdad llega a la zapata

#: De la columna bajan DOS cosas a la vez: una fuerza vertical P, centrada en su eje, y un momento M. El momento no lo inventa nadie: viene del sismo, del viento, de la continuidad del pórtico o de que la viga de un lado carga más que la del otro.
#dibujo("Lo que baja por la columna: fuerza centrada P y momento M", ud = m, escala = 1:22, cotas = m, alto = 130)
#  rect(0, 0, 2, 0.3, "gruesa")
#  achurado(0, 0, 2, 0.3, "diagonal")
#  rect(0.85, 0.3, 0.3, 1.1, "gruesa")
#  achurado(0.85, 0.3, 0.3, 1.1, "diagonal")
#  flecha(1, 2.1, 1, 1.48, "rojo")
#  texto(1.12, 1.95, "P", 3.2, "i")
#  flechamomento(1, 1.75, 0.42, 200, 340, "rojo")
#  texto(1.62, 1.78, "M", 3.2, "i")
#  linea(1, -0.15, 1, 2.25, "eje")
#  texto(1, -0.42, "el eje de la columna", 2.4, "c")
#fin
#: Las dos bajan por el MISMO sitio: el eje de la columna. No hay ninguna fuerza aplicada por fuera.

## 2 · Por qué entonces se dibuja corrida

#: Porque una fuerza se puede TRASLADAR, si se paga el precio. Mover P una distancia e de su sitio cambia el momento que produce en la base: aparece un momento de valor P por e. Entonces, si se elige esa distancia de modo que el momento que aparece sea exactamente M, las dos situaciones son la misma para la base:
M_gen = P*e
#: Igualando el momento generado al momento real y despejando la distancia:
e = M/P
#: Eso es la excentricidad: **la distancia a la que habría que poner P, ella sola, para producir la misma fuerza y el mismo momento**. No es dónde está la carga: es dónde está su RESULTANTE.
#dibujo("Las dos situaciones son la misma para el suelo", ud = m, escala = 1:26, cotas = m, alto = 130)
#  rect(0, 0, 2, 0.3, "gruesa")
#  achurado(0, 0, 2, 0.3, "diagonal")
#  rect(0.85, 0.3, 0.3, 1.0, "gruesa")
#  flecha(1, 2.0, 1, 1.44, "rojo")
#  texto(1.1, 1.88, "P", 3, "i")
#  flechamomento(1, 1.68, 0.36, 200, 340, "rojo")
#  texto(1.52, 1.7, "M", 3, "i")
#  linea(1, -0.12, 1, 2.1, "eje")
#  texto(1, -0.45, "P centrada + M", 2.5, "c")
#  texto(2.35, 0.9, "ES LO MISMO", 2.6, "c")
#  texto(2.35, 0.6, "para la base", 2.3, "c")
#  rect(2.7, 0, 2, 0.3, "gruesa")
#  achurado(2.7, 0, 2, 0.3, "diagonal")
#  rect(3.55, 0.3, 0.3, 1.0, "gruesa")
#  flecha(4.0, 2.05, 4.0, 1.38, "rojo")
#  texto(4.14, 1.94, "P", 3, "i")
#  linea(3.7, -0.12, 3.7, 2.1, "eje")
#  cota(3.7, 1.62, 4.0, 1.62, 0.26, "e = M/P")
#  texto(3.7, -0.45, "P corrida una distancia e", 2.5, "c")
#fin
#: Los dos dibujos dan la misma fuerza vertical y el mismo momento en la base de la zapata. Y el suelo no ve columnas ni momentos: ve una resultante. Por eso se trabaja con el de la derecha, que es más fácil de dibujar y de repartir.
#: **La flecha corrida es la resultante equivalente, no una carga colgada del aire.** Si el punto cae fuera de la zapata (e mayor que la mitad del lado) eso ya no es un dibujo raro: significa que la zapata vuelca.

## 3 · La presión, en 3D

#: Aquí se ve por qué importa. La zapata del ejemplo 3.8 mide 1.5 × 1.5 m y le llegan P = 606 kN con excentricidades de 0.15 y 0.30 m. El reparto lineal de una zapata rígida es un PLANO inclinado: presión media más lo que aporta cada momento. Los ejes horizontales son los dos lados de la zapata en metros y el vertical es la presión en [kPa]. **Se arrastra con el ratón para girarlo.**
#surf(269.3 + 215.4*(x - 0.75) + 430.9*(y - 0.75), [0 1.5], [0 1.5])
#: **El eje vertical es la presión sobre el suelo, en [kPa]: cuanto más alto, más aprieta la zapata.** El plano se inclina hacia la esquina a la que se corrió la carga. En esa esquina la presión llega a unos 754 kPa; en la opuesta, el plano baja por debajo de cero: la fórmula pide que el suelo TIRE de la zapata.
#: El suelo no tira. Lo que pasa de verdad es que esa parte se despega y queda con presión cero. La misma superficie, con lo negativo recortado:
#: **Antes de mirarlo, una advertencia, porque se lee al revés con facilidad: la altura de este dibujo es la PRESIÓN, no la zapata.** No es la deformada. Lo ALTO y ROJO es donde la zapata APLASTA el suelo (la esquina cargada, 754 kPa); lo PLANO y AZUL es donde la zapata SE LEVANTA y no toca (presión cero). La esquina levantada aparece abajo porque su presión vale cero, no porque baje la zapata.
#surf((269.3 + 215.4*(x - 0.75) + 430.9*(y - 0.75) + abs(269.3 + 215.4*(x - 0.75) + 430.9*(y - 0.75)))/2, [0 1.5], [0 1.5])
#: La esquina plana del fondo es el trozo levantado. Esa es la no linealidad: no hay material que se rompa ni plastifique, solo una zapata que deja de tocar.
#: Girándolo se ve que el plano no cambia de forma al recortarlo: lo que cambia es el ÁREA que trabaja. Y como la carga sigue siendo la misma, al repartirse en menos superficie la presión de la esquina cargada sube. Es lo que mide la hoja 54.

## En una línea

#: La carga baja por la columna y baja centrada; la excentricidad es la distancia a la que hay que imaginarla, ella sola, para producir también el momento. Y cuando esa distancia saca la resultante del núcleo central, el suelo deja de tocar en una esquina, que es donde empieza la no linealidad.
