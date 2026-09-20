# ¿Qué es una cimentación NO lineal? Explicado despacio

#: Esta hoja es para ENTENDER, no para diseñar. Una sola idea la resume: el suelo puede EMPUJAR a la zapata, pero no puede TIRAR de ella. De ahí sale todo lo demás.

## 1 · Lineal contra no lineal

#: LINEAL: el doble de carga da el doble de respuesta. Es una recta, como y = m·x + b con b = 0: la fuerza de un resorte es su rigidez por lo que se estira o se aplasta.
F_resorte = k*delta
#: NO LINEAL: la regla CAMBIA según lo que pasa. El suelo es un resorte que solo trabaja cuando lo aplastas (δ > 0). Si lo "estiras" (δ < 0, la zapata sube), no hace nada: fuerza cero. Se escribe con la mitad de (δ + |δ|), que vale δ si δ es positivo y 0 si es negativo:
F_suelo = k*(delta + abs(delta))/2
#: Las dos juntas, con k = 1 (gráfica de la izquierda, abajo en la sección 2). La azul es una recta de punta a punta. La del suelo es recta a la derecha y PLANA a la izquierda: tiene un CODO en δ = 0. Ese codo es la no linealidad.

## 2 · Un solo resorte, animado

#: Se aplasta y se estira poco a poco: la curva se va dibujando de izquierda a derecha. Del lado del tirón (izquierda) el resorte normal responde con fuerza negativa; el suelo se queda en cero porque la zapata simplemente se DESPEGA. A la derecha, empujando, los dos responden igual.
#fila
#fplot(resorte = x, suelo = (x + abs(x))/2, [-1 1])
#anim fplot(resorte = x*(1 + sign(n/10 - x))/2, suelo = (x + abs(x))/2*(1 + sign(n/10 - x))/2, [-1 1]), n = -10:10
#finfila

## 3 · La zapata: una fila de resortes

#: El programa pone un resorte debajo de cada punto de la zapata (la cama de Winkler). La presión en cada punto es lo que aprieta su resorte. Si la columna está CENTRADA, la zapata baja parejo y todos los resortes aprietan igual: presión uniforme, Q dividido por el área. Con la zapata del ejemplo 6.10 de Das (1.5 × 1.5 m, Q = 61.795 tonf = 606 kN):
q_media = dec(61.795/(1.5*1.5), 2)
#: En tonf/m², igual en toda la base (x va de un borde al otro):
#fplot(q = 27.46, [0 1.5])

## 4 · La animación clave: la columna se corre (excentricidad e)

#: Si la carga se corre una distancia e hacia un borde, ese borde aprieta más y el otro menos. Con la zapata rígida la presión es una RECTA (Das 9.ª ed., ecs. 6.51 y 6.52, p. 236):
q_max = Q/(B*L)*(1 + 6*e/B)
q_min = Q/(B*L)*(1 - 6*e/B)
#: q_min llega a cero justo cuando e = B/6 (el paréntesis se anula). Pasado ese punto la recta daría presión NEGATIVA: el suelo tendría que TIRAR del borde. Como no puede, el borde se LEVANTA y la presión real es un triángulo más corto y más alto (Das, ec. 6.53, p. 236):
q_real = 4*Q/(3*L*(B - 2*e))
a_contacto = 3*(B/2 - e)
#: La animación: e sube de 0 a B/3 en pasos de B/60 (n = 0 … 20). x se mide desde el borde cargado.
#: • «lineal» = lo que daría un suelo que SÍ tira: recta que, pasado e = B/6 (n = 10), cruza el cero y sigue hacia abajo. Esa parte bajo cero es tracción IMPOSIBLE.
#: • «sin_traccion» = el suelo real: rectángulo → trapecio → triángulo que toca 0 en n = 10; luego el borde queda en CERO (levantado) y el triángulo se acorta y sube.
#anim fplot(lineal = 27.4644*(1 + 0.1*n) - 3.66192*n*x, sin_traccion = ((1 + sign(10.5 - n))/2)*(27.4644*(1 + 0.1*n) - 3.66192*n*x) + ((1 - sign(10.5 - n))/2)*(54.9289/(1.5 - 0.05*n))*((1 - x/(2.25 - 0.075*n)) + abs(1 - x/(2.25 - 0.075*n)))/2, [0 1.5]), n = 0:20
#: Mira el final (n = 20, e = B/3 = 0.5 m): la recta lineal marca 82.4 en el borde y −27.5 al otro lado; la real marca 110 en el borde y el contacto mide solo 3·(0.75 − 0.5) = 0.75 m. El suelo real aprieta MÁS en menos área.
q_n20 = dec(54.9289/(1.5 - 0.05*20), 1)
a_n20 = dec(3*(0.75 - 0.5), 2)

## 5 · Por qué el ordenador tiene que ITERAR

#: El programa no sabe de antemano qué parte de la zapata apoya. Entonces prueba: 1) resuelve con TODOS los resortes; 2) los que quedaron tirando (nudo que subió) se APAGAN; 3) vuelve a resolver. Repite hasta que ningún resorte cambie. Estas son las 4 vueltas REALES de Hekatan con el ejemplo 6.10 de Das (1.5 × 1.5 m, e_{B} = 0.15 m y e_{L} = 0.30 m, malla de 961 nudos):
#tabla("Vuelta:0","Resortes activos:0","En tracción:0","Se apagan:0","Se encienden:0","q_max [tonf/m²]:2")([1, 2, 3, 4]; [961, 851, 802, 798]; [110, 49, 4, 0]; [110, 49, 4, 0]; [0, 0, 0, 0]; [76.67, 81.34, 81.91, 81.91])
#: Vuelta 1 = el cálculo lineal: 110 resortes tiran y la presión máxima es 76.67. Se apagan esos 110 → vuelta 2: tiran 49 más. Vuelta 3: 4. Vuelta 4: ninguno → terminó. Quedan 798 de 961 nudos apoyados.
#: La presión a lo largo de la DIAGONAL de la zapata (de la esquina más cargada, x = 0, a la opuesta) en cada vuelta n. En la vuelta 1 la curva baja de cero en el extremo (tracción); en las siguientes esos puntos se apagan y la presión sube donde sí apoya:
#anim fplot(q = (1 - sign(abs(n - 1)))*(76.67*(1 - abs(x - 0)/0.2121 + abs(1 - abs(x - 0)/0.2121))/2 + 66.87*(1 - abs(x - 0.2121)/0.2121 + abs(1 - abs(x - 0.2121)/0.2121))/2 + 57.09*(1 - abs(x - 0.4243)/0.2121 + abs(1 - abs(x - 0.4243)/0.2121))/2 + 47.32*(1 - abs(x - 0.6364)/0.2121 + abs(1 - abs(x - 0.6364)/0.2121))/2 + 37.47*(1 - abs(x - 0.8485)/0.2121 + abs(1 - abs(x - 0.8485)/0.2121))/2 + 27.55*(1 - abs(x - 1.0607)/0.2121 + abs(1 - abs(x - 1.0607)/0.2121))/2 + 17.65*(1 - abs(x - 1.2728)/0.2121 + abs(1 - abs(x - 1.2728)/0.2121))/2 + 7.76*(1 - abs(x - 1.4849)/0.2121 + abs(1 - abs(x - 1.4849)/0.2121))/2 + -2.11*(1 - abs(x - 1.6971)/0.2121 + abs(1 - abs(x - 1.6971)/0.2121))/2 + -11.97*(1 - abs(x - 1.9092)/0.2121 + abs(1 - abs(x - 1.9092)/0.2121))/2 + -21.83*(1 - abs(x - 2.1213)/0.2121 + abs(1 - abs(x - 2.1213)/0.2121))/2) + (1 - sign(abs(n - 2)))*(81.34*(1 - abs(x - 0)/0.2121 + abs(1 - abs(x - 0)/0.2121))/2 + 70.33*(1 - abs(x - 0.2121)/0.2121 + abs(1 - abs(x - 0.2121)/0.2121))/2 + 59.34*(1 - abs(x - 0.4243)/0.2121 + abs(1 - abs(x - 0.4243)/0.2121))/2 + 48.35*(1 - abs(x - 0.6364)/0.2121 + abs(1 - abs(x - 0.6364)/0.2121))/2 + 37.29*(1 - abs(x - 0.8485)/0.2121 + abs(1 - abs(x - 0.8485)/0.2121))/2 + 26.15*(1 - abs(x - 1.0607)/0.2121 + abs(1 - abs(x - 1.0607)/0.2121))/2 + 15.03*(1 - abs(x - 1.2728)/0.2121 + abs(1 - abs(x - 1.2728)/0.2121))/2 + 3.92*(1 - abs(x - 1.4849)/0.2121 + abs(1 - abs(x - 1.4849)/0.2121))/2) + (1 - sign(abs(n - 3)))*(81.91*(1 - abs(x - 0)/0.2121 + abs(1 - abs(x - 0)/0.2121))/2 + 70.74*(1 - abs(x - 0.2121)/0.2121 + abs(1 - abs(x - 0.2121)/0.2121))/2 + 59.58*(1 - abs(x - 0.4243)/0.2121 + abs(1 - abs(x - 0.4243)/0.2121))/2 + 48.43*(1 - abs(x - 0.6364)/0.2121 + abs(1 - abs(x - 0.6364)/0.2121))/2 + 37.21*(1 - abs(x - 0.8485)/0.2121 + abs(1 - abs(x - 0.8485)/0.2121))/2 + 25.91*(1 - abs(x - 1.0607)/0.2121 + abs(1 - abs(x - 1.0607)/0.2121))/2 + 14.63*(1 - abs(x - 1.2728)/0.2121 + abs(1 - abs(x - 1.2728)/0.2121))/2 + 3.35*(1 - abs(x - 1.4849)/0.2121 + abs(1 - abs(x - 1.4849)/0.2121))/2) + (1 - sign(abs(n - 4)))*(81.91*(1 - abs(x - 0)/0.2121 + abs(1 - abs(x - 0)/0.2121))/2 + 70.74*(1 - abs(x - 0.2121)/0.2121 + abs(1 - abs(x - 0.2121)/0.2121))/2 + 59.58*(1 - abs(x - 0.4243)/0.2121 + abs(1 - abs(x - 0.4243)/0.2121))/2 + 48.43*(1 - abs(x - 0.6364)/0.2121 + abs(1 - abs(x - 0.6364)/0.2121))/2 + 37.21*(1 - abs(x - 0.8485)/0.2121 + abs(1 - abs(x - 0.8485)/0.2121))/2 + 25.91*(1 - abs(x - 1.0607)/0.2121 + abs(1 - abs(x - 1.0607)/0.2121))/2 + 14.62*(1 - abs(x - 1.2728)/0.2121 + abs(1 - abs(x - 1.2728)/0.2121))/2 + 3.35*(1 - abs(x - 1.4849)/0.2121 + abs(1 - abs(x - 1.4849)/0.2121))/2), [0 2.1213]), n = 1:4

## 6 · Por qué importa

#: Si se calcula como lineal (suelo que tira), la presión máxima sale 76.67 en vez de 81.91 tonf/m²: un 6.4 % MENOS, del lado inseguro. Y la zona "levantada" aparece tirando del suelo, cosa que no pasa.
dif = dec((76.670/81.914 - 1)*100, 1)
#: Cinco programas con la misma malla dan lo mismo. En la gráfica, x es el número del programa (1 SAP2000, 2 Hekatan, 3 SAFE, 4 ETABS, 5 OpenSeesPy); la línea «rigida» es la zapata rígida de Das (82.21) y «lineal» el suelo que tira (76.67):
#: A la derecha, en función de e (otra zapata, 2 × 2 m, P = 60 tonf): la curva es la fórmula de Das; los puntos, el cálculo por elementos finitos. Siguen a la curva también después de e/L = 1/6, donde empieza el levantamiento.
#fila
#fplot(rigida = 82.211, lineal = 76.670, SAP2000 = [1 81.914], Hekatan = [2 81.915], SAFE = [3 81.915], ETABS = [4 81.915], OpenSeesPy = [5 81.915], [0.5 5.5])
#fplot(Das = 15*(1 + 6*x)*(1 + sign(1/6 - x))/2 + (20/(1 - 2*x))*(1 - sign(1/6 - x))/2, SAP2000 = [0 15.180; 1/12 22.464; 1/6 30.000; 1/4 40.052; 1/3 60.038], Hekatan = [0 15.180; 1/12 22.464; 1/6 30.000; 1/4 40.055; 1/3 60.072], [0 0.4])
#finfila

## En una línea

#: NO LINEAL = el suelo no puede tirar. Por eso hay que recalcular, apagando lo que tira, hasta que la zona de contacto deje de cambiar.
