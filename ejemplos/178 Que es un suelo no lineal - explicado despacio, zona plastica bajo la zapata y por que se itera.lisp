# ¿Qué es un suelo NO lineal? Explicado despacio
#numerico

#: Esta hoja es para ENTENDER, no para diseñar. Es la hermana de la hoja 49 (la zapata que se levanta). Allí la idea era: el suelo puede EMPUJAR a la zapata, pero no puede TIRAR de ella. Aquí la idea es otra, igual de simple: **el suelo aguanta corte solo hasta su resistencia**. Pasado ese tope, se deforma sin dar más fuerza. De ahí sale todo lo demás.

## 1 · Lineal contra no lineal: un resorte con tope

#: LINEAL: el doble de carga da el doble de deformación. Es una recta, como y = m·x + b con b = 0: q = k·δ. Nunca falla: si pones mil toneladas, te da un asiento mil veces más grande, pero ninguna alarma.
#: NO LINEAL: el suelo es un resorte con TOPE. Mientras está lejos de la falla, se porta como la recta. Cuando llega a su capacidad q_f, la curva se vuelve PLANA: puede seguir hundiéndose, pero ya no da más fuerza. Con k = 1 y q_f = 0.6 (gráfica de la izquierda). Se escribe q = mín(k·δ, q_f).
#: La animación (derecha) carga poco a poco: las dos curvas van juntas hasta δ = 0.6; después la del suelo se queda en 0.6 y la lineal sigue subiendo.
#fila
#fplot(lineal = x, suelo = 0.6 - (0.6 - x + abs(0.6 - x))/2, [0 1])
#anim fplot(lineal = x*(1 + sign(n/10 - x))/2, suelo = (0.6 - (0.6 - x + abs(0.6 - x))/2)*(1 + sign(n/10 - x))/2, [0 1]), n = 0:10
#finfila

## 2 · ¿Cuándo llega al tope un punto del suelo? El círculo de Mohr

#: Un punto del suelo bajo la zapata está apretado por dos esfuerzos principales: σ_1 (el mayor, casi vertical) y σ_3 (el menor, de los lados). Con ellos se dibuja un círculo: centro (σ_1 + σ_3)/2, radio (σ_1 − σ_3)/2. El radio es el corte máximo que sufre el punto.
#: El suelo resiste un corte τ = c + σ·tan φ (recta de Mohr-Coulomb, c = cohesión, φ = ángulo de rozamiento). Mientras el círculo quede DEBAJO de la recta, el punto está elástico y el modelo lineal vale. Cuando el círculo TOCA la recta, el punto plastifica.

c = 10 'cohesión [kPa]
phi_g = 25 'ángulo de rozamiento [grados]
phi = phi_g·π/180
s_3 = 50 'esfuerzo de los lados, fijo [kPa]

#: Tres estados del mismo punto, con σ_3 = 50 kPa y σ_1 = 100, 150 y 200 kPa (al subir la carga de la zapata, σ_1 crece). Así se reparte en la gráfica: falla = recta de Mohr-Coulomb; c1, c2, c3 = los círculos.
#fplot(falla = c + x·tan(phi), c1 = sqrt(abs(25^2 - (x - 75)^2))*(1 + sign(25 - abs(x - 75)))/2, c2 = sqrt(abs(50^2 - (x - 100)^2))*(1 + sign(50 - abs(x - 100)))/2, c3 = sqrt(abs(75^2 - (x - 125)^2))*(1 + sign(75 - abs(x - 125)))/2, [0 220])

#: Cuánto le falta a cada círculo para tocar la recta: la «función de falla» F. Con F < 0 el punto es elástico; F = 0 toca; F > 0 sería IMPOSIBLE (el círculo atraviesa la recta): el modelo lineal da esfuerzos que el suelo no puede tener.
F(s1, s3) = (s1 - s3)/2 - (s1 + s3)/2·sin(phi) - c·cos(phi)
F_1 = F(100, s_3)
F_2 = F(150, s_3)
F_3 = F(200, s_3)

## 3 · La zapata corrida: dónde plastifica el suelo

#: Una zapata corrida de ancho B con presión p sobre el suelo. Los esfuerzos ELÁSTICOS bajo ella tienen fórmula cerrada (carga en franja, Boussinesq/Michell, deformación plana): si α es el ángulo con que el punto «ve» la zapata, σ_1,3 = (p/π)·(α ± sin α). Se suma el peso propio γ·d (con K0 = 1, simplificación). d = profundidad.

B = 2 'ancho de la zapata [m]
g_s = 18 'peso específico [kN/m3]
al(x, y) = atan((x + B/2)/(0.001 - y)) - atan((x - B/2)/(0.001 - y))
U(x, y, p) = ((p/π)·sin(al(x, y)))/((p/π·al(x, y) - g_s·y)·sin(phi) + c·cos(phi))

#: U es la UTILIZACIÓN de cada punto: corte que sufre / corte que resiste (radio del círculo entre la distancia a la recta). U < 1: elástico. **U > 1: el modelo lineal pide más de lo que el suelo da: esa zona plastificó.** Fíjate en la isolínea del nivel 1 en los tres mapas.

#: La capacidad de la zapata (Prandtl-Reissner-Vesic, desplante 0):
N_q = exp(π·tan(phi))·tan(π/4 + phi/2)^2
N_c = (N_q - 1)/tan(phi)
N_g = 2·(N_q + 1)·tan(phi)
q_f = c·N_c + 0.5·g_s·B·N_g

#: Tres cargas: un cuarto, la mitad y tres cuartos de q_f. y es la cota (0 en la superficie, −4 a 4 m de profundidad). Ut recorta U en 1 (Ut = mín(U, 1)): así los tres mapas tienen la MISMA escala 0 → 1 y el **magenta es la zona plastificada** (U ≥ 1).
p_1 = q_f/4
p_2 = q_f/2
p_3 = 3·q_f/4
Ut(u) = 1 - (1 - u + abs(1 - u))/2
U_1(x, y) = Ut(U(x, y, p_1))
U_2(x, y) = Ut(U(x, y, p_2))
U_3(x, y) = Ut(U(x, y, p_3))
#fila
#contourf(U_1(x, y), [-4 4], [-4 0])
#contourf(U_2(x, y), [-4 4], [-4 0])
#contourf(U_3(x, y), [-4 4], [-4 0])
#finfila

#: Lo que se ve: ya con p = q_f/4 plastifican dos puntitos en los BORDES de la zapata (ahí el corte elástico se dispara). Con la mitad, las dos manchas ya se juntaron en un bulbo magenta bajo la zapata; con tres cuartos, el bulbo plástico crece hacia abajo y hacia los lados. El modelo lineal no se entera: sus esfuerzos solo se multiplican por la carga, y todo lo magenta es esfuerzo IMPOSIBLE. Ojo: este mapa sale de esfuerzos ELÁSTICOS, por eso exagera la zona plástica; el tamaño real lo da el cálculo no lineal (sección 4), que reparte el exceso a los puntos vecinos.

## 4 · Por qué el ordenador tiene que ITERAR

#: Es la misma razón que en la hoja 49. Allí el programa no sabía qué parte de la zapata apoyaba; aquí no sabe qué puntos del suelo plastificaron. Entonces, en cada paso de carga:
#: 1) prueba elástica: calcula el esfuerzo como si el suelo fuera lineal;
#: 2) mira F en cada punto de Gauss: si F > 0, ese punto se pasó de la recta;
#: 3) retorno: lo devuelve a la recta (F = 0) con un multiplicador plástico Δλ;
#: 4) Newton: como al devolverlo cambió el equilibrio, vuelve a resolver K·ΔU = residuo, hasta que el residuo es cero.
#: Un punto cargado poco a poco (curva q–ε de un ensayo con σ_3 constante, demo del retorno de Mohr-Coulomb del video del suelo): la recta inicial es la del modelo lineal; la curva real se dobla y se queda en q_f = 7.7427 t/m² (la teórica, a 4 decimales).
#fplot(lineal = -0.275 + 24.28·x, suelo = [0 0.381; 0.05 0.938; 0.1 2.153; 0.15 3.367; 0.2 4.581; 0.25 5.795; 0.3 7.009; 0.35 7.743; 0.5 7.743; 1 7.743; 1.5 7.743; 2 7.743], [0 2])

## En una línea

#: NO LINEAL = el suelo tiene TOPE de corte. El lineal sirve mientras todos los círculos de Mohr queden bajo la recta (U < 1, carga de servicio, asientos). Si en algún punto U > 1 (capacidad portante, taludes, empujes), hay que plastificar e iterar.
