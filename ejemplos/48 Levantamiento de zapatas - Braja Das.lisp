# Cimentaciones con no linealidad: levantamiento de zapatas (suelo sin tracción)

#: Pregunta que llegó de un usuario: «hay situaciones en que las zapatas incurren en rango no lineal, como cuando las columnas son demasiado excéntricas». Sí: el suelo EMPUJA pero no TIRA. Cuando la carga cae lejos del centro, una parte de la zapata se despega del suelo y el problema deja de ser lineal. Esta hoja lo explica con el libro de Braja M. Das, *Principles of Foundation Engineering*, 9.ª ed. (2019), §6.10–6.12, p. 235–249 (en español: *Fundamentos de ingeniería de cimentaciones*, 7.ª ed., §3.9–3.11, p. 157–171), y lo compara con el cálculo por elementos finitos de Hekatan Struct, SAP2000, SAFE y ETABS.

## 1 · Qué es la excentricidad (Das, ec. 6.50, p. 235)

#: Una columna que baja con una carga vertical Q y un momento M hace lo mismo que la carga Q sola corrida una distancia e del centro de la zapata. Esa distancia es la excentricidad:
e_x = M/Q
#: Vista desde ARRIBA (planta). El cuadrado gris del centro es la columna. El punto de doble círculo es donde «cae» de verdad la carga: no en el centro de la columna, sino corrido una distancia e hacia el lado al que empuja el momento. Todo lo que sigue depende de dónde está ese punto.
#dibujo("Planta: la columna está en el centro, pero la carga Q cae corrida una distancia e", ud = m, escala = 1:30, cotas = m, alto = 95)
#  rect(0, 0, 2, 2, "gruesa")
#  achurado(0.8, 0.8, 0.4, 0.4, "diagonal")
#  rect(0.8, 0.8, 0.4, 0.4, "media")
#  linea(1, -0.2, 1, 2.2, "eje")
#  linea(-0.2, 1, 2.2, 1, "eje")
#  circulo(1.45, 1, 0.045)
#  circulo(1.45, 1, 0.02)
#  texto(1.5, 1.22, "Q: la carga cae aquí", 2.6, "i")
#  texto(0.5, 1.28, "columna", 2.4, "c")
#  cota(1, 1, 1.45, 1, -0.32, "e = M/Q")
#  cota(0, 0, 2, 0, -0.35, "B (lado en la dirección de e)")
#  cota(0, 0, 0, 2, 0.35, "L")
#fin
#: Mientras más momento, más lejos cae la carga, y más carga toma el borde de ese lado.

## 2 · La presión si el suelo pudiera tirar (Das, ecs. 6.51 y 6.52, p. 236)

#: Si la zapata es rígida y el suelo responde lineal, la presión es un plano: máxima en el borde cargado y mínima en el opuesto (B es el lado en la dirección de e):
q_max = Q/(B*L)*(1 + 6*e/B)
q_min = Q/(B*L)*(1 - 6*e/B)
#: ¿Con qué excentricidad la presión mínima llega a cero? Es cero cuando el paréntesis es cero; multiplicado por B queda (con e_{c} la excentricidad crítica):
e_c = B/6
#: Vista de LADO (alzado) con e menor que B/6. La flecha roja es la carga, corrida e a la derecha del eje de la columna. Debajo, en azul, la presión del suelo: un TRAPECIO, más alto del lado de la carga. Toda la base está apoyada.
#dibujo("e < B/6 · toda la base empuja: la presión es un trapecio", ud = m, escala = 1:30, cotas = m, alto = 95)
#  rect(0, 0, 2, 0.5, "gruesa")
#  achurado(0.8, 0.5, 0.4, 0.9, "diagonal")
#  rect(0.8, 0.5, 0.4, 0.9, "media")
#  linea(1, -0.1, 1, 1.9, "eje")
#  linea(1.2, 2.0, 1.2, 1.45, "rojo")
#  poligono(1.2, 1.42, 1.15, 1.56, 1.25, 1.56, "rojo")
#  texto(1.27, 1.85, "Q", 3, "i")
#  poligono(0, 0, 2, 0, 2, -0.8, 0, -0.2, "azul")
#  linea(0, -0.2, 2, -0.8, "azul")
#  linea(0.4, 0, 0.4, -0.32, "azul")
#  linea(0.8, 0, 0.8, -0.44, "azul")
#  linea(1.2, 0, 1.2, -0.56, "azul")
#  linea(1.6, 0, 1.6, -0.68, "azul")
#  texto(2.06, -0.8, "q_{max}", 2.6, "i")
#  texto(-0.06, -0.2, "q_{min}", 2.6, "d")
#  texto(1, -1.05, "el suelo empuja en todo el ancho", 2.4, "c")
#  cota(1, 1.62, 1.2, 1.62, 0.22, "e")
#  cota(0, -1.2, 2, -1.2, -0.12, "B")
#fin
#: Ese es el límite del NÚCLEO CENTRAL: con e hasta B/6 toda la base empuja (rectángulo o trapecio de presión). Pasado B/6 la fórmula da presión NEGATIVA, o sea el suelo tendría que TIRAR de la zapata. No lo hace: el borde se levanta, el área de contacto baja y el problema ya no es lineal (Das, p. 236).

## 3 · Pasado B/6: el triángulo (Das, ec. 6.53, p. 236, Tomlinson 1978)

#: Con el borde levantado la presión es un TRIÁNGULO. Dos condiciones lo fijan. Primera, la resultante del suelo tiene que caer bajo la carga: la resultante de un triángulo está a un tercio de su largo, medido desde el borde cargado, y la carga está a B/2 − e de ese borde, así que el largo de contacto es tres veces esa distancia:
a_c = 3*(B/2 - e)
#: Segunda, equilibrio vertical: el volumen del triángulo de presión (medio q_{t} por el largo por el ancho L) tiene que valer Q. Se despeja la presión máxima:
#: En fórmula: Q = ½ · q_{t} · a_{c} · L. Se despeja q_{t} y se pone a_{c} = 3·(B/2 − e); sale la ecuación 6.53 del libro:
q_t = 4*Q/(3*L*(B - 2*e))
#: Vista de LADO con e MAYOR que B/6. La carga cae tan lejos del centro que el borde opuesto se LEVANTA: en ese tramo (trazos naranja) la zapata ya no toca el suelo y la presión es cero. Solo empuja el largo de contacto a_{c}, y la presión es un TRIÁNGULO cuya resultante (a un tercio de su base) queda justo debajo de la carga.
#dibujo("e > B/6 · el borde se levanta: la presión es un triángulo sobre el largo de contacto", ud = m, escala = 1:30, cotas = m, alto = 105)
#  rect(0, 0, 2, 0.5, "gruesa")
#  achurado(0.8, 0.5, 0.4, 0.9, "diagonal")
#  rect(0.8, 0.5, 0.4, 0.9, "media")
#  linea(1, -0.1, 1, 1.9, "eje")
#  linea(1.6, 2.0, 1.6, 1.45, "rojo")
#  poligono(1.6, 1.42, 1.55, 1.56, 1.65, 1.56, "rojo")
#  texto(1.67, 1.85, "Q", 3, "i")
#  linea(1.6, 1.4, 1.6, -1.0, "puntos")
#  poligono(0.8, 0, 2, 0, 2, -1.0, "azul")
#  linea(1.1, 0, 1.1, -0.25, "azul")
#  linea(1.4, 0, 1.4, -0.5, "azul")
#  linea(1.7, 0, 1.7, -0.75, "azul")
#  linea(0, -0.04, 0.8, -0.04, "naranja")
#  texto(0.4, -0.22, "despegado: presión 0", 2.3, "c")
#  texto(2.06, -1.0, "q_{t}", 2.6, "i")
#  cota(1, 1.62, 1.6, 1.62, 0.22, "e")
#  cota(0.8, -1.2, 2, -1.2, -0.12, "a_{c} = 3·(B/2 − e)")
#  cota(1.6, -0.62, 2, -0.62, -0.05, "a_{c}/3")
#  cota(0, -1.62, 2, -1.62, -0.12, "B")
#fin
#: Al crecer e, el contacto se encoge y q_{t} se dispara; con e = B/2 el contacto es cero: la zapata vuelca.

## 4 · El ejemplo 6.10 de Das (p. 247–248), tal cual el libro

#: Zapata cuadrada de 1.5 × 1.5 m desplantada a 0.7 m en arena (γ = 18 kN/m³, φ' = 30°, c' = 0), con excentricidad en DOS direcciones: e_{L} = 0.3 m y e_{B} = 0.15 m.
B_d = 1.5
L_d = 1.5
e_L = 0.3
e_B = 0.15
r_L = dec(e_L/L_d, 3)
r_B = dec(e_B/B_d, 3)
#: e_{L}/L = {r_L} es MAYOR que 1/6: la resultante sale del núcleo y un borde se levanta. e_{B}/B = {r_B} es menor que 1/6. Con 1/6 < e_{L}/L < 0.5 y e_{B}/B < 1/6 la carga cae en el CASO II de Highter y Anders (1985) (Das, p. 244).
#: La zapata del ejemplo, vista desde arriba y con sus medidas reales. La columna está en el centro; la carga cae corrida 0.15 m en una dirección y 0.30 m en la otra (punto de doble círculo). La zona rayada en azul es el ÁREA EFECTIVA A' del libro: el trapecio cuyo centro de gravedad cae justo debajo de la carga. La parte de abajo, sin rayar, es la que el cálculo de capacidad no cuenta.
#dibujo("Ejemplo 6.10 · zapata 1.5 × 1.5 m: columna, punto de carga y área efectiva (caso II)", ud = m, escala = 1:20, cotas = m, alto = 120)
#  poligono(0, 1.5, 1.5, 1.5, 1.5, 0.225, 0, 1.185, "azul")
#  linea(0.1, 1.5, 0.1, 1.121, "azul")
#  linea(0.2, 1.5, 0.2, 1.057, "azul")
#  linea(0.3, 1.5, 0.3, 0.993, "azul")
#  linea(0.4, 1.5, 0.4, 0.929, "azul")
#  linea(0.5, 1.5, 0.5, 0.865, "azul")
#  linea(0.6, 1.5, 0.6, 0.801, "azul")
#  linea(0.7, 1.5, 0.7, 0.737, "azul")
#  linea(0.8, 1.5, 0.8, 0.673, "azul")
#  linea(0.9, 1.5, 0.9, 0.609, "azul")
#  linea(1.0, 1.5, 1.0, 0.545, "azul")
#  linea(1.1, 1.5, 1.1, 0.481, "azul")
#  linea(1.2, 1.5, 1.2, 0.417, "azul")
#  linea(1.3, 1.5, 1.3, 0.353, "azul")
#  linea(1.4, 1.5, 1.4, 0.289, "azul")
#  rect(0, 0, 1.5, 1.5, "gruesa")
#  rect(0.575, 0.575, 0.35, 0.35, "media")
#  achurado(0.575, 0.575, 0.35, 0.35, "cruzado")
#  linea(0.75, -0.15, 0.75, 1.65, "eje")
#  linea(-0.15, 0.75, 1.65, 0.75, "eje")
#  circulo(0.9, 1.05, 0.035)
#  circulo(0.9, 1.05, 0.015)
#  texto(0.95, 1.12, "Q", 3, "i")
#  texto(0.75, 0.45, "columna", 2.3, "c")
#  texto(0.38, 1.6, "área efectiva A' (rayada)", 2.5, "c")
#  cota(0.75, 0.75, 0.9, 0.75, -0.62, "e_{B} = 0.15")
#  cota(0.9, 0.75, 0.9, 1.05, -0.22, "e_{L} = 0.30")
#  cota(1.5, 0.225, 1.5, 1.5, -0.3, "L_{1} = 0.85·L")
#  cota(0, 1.185, 0, 1.5, 0.3, "L_{2} = 0.21·L")
#  cota(0, 0, 1.5, 0, -0.3, "B = 1.50")
#fin
#: En el caso II el área efectiva es un trapecio (ec. 6.75). El libro lee L₁ y L₂ del ábaco de la figura 6.27b: L₁/L ≈ 0.85 y L₂/L ≈ 0.21, o sea L₁ = 0.85·1.5 = 1.275 m y L₂ = 0.21·1.5 = 0.315 m.
L_1 = 1.275
L_2 = 0.315
Aprime = dec(0.5*(L_1 + L_2)*B_d, 3)
Lprime = L_1
Bprime = dec(Aprime/Lprime, 3)
#: Con el área efectiva, la capacidad última (ec. 6.55 con c' = 0). Los factores los da el propio ejemplo: q₀ = 0.7·18 (la q del libro, sobrecarga γ·D_{f}), N_{q} = 18.4 y N_{γ} = 22.4 (tabla 6.2), y los de forma y profundidad de la tabla 6.3:
q_0 = 12.6
N_q = 18.4
N_γ = 22.4
F_qs = dec(1 + (Bprime/Lprime)*tan(30*pi/180), 3)
F_γs = dec(1 - 0.4*(Bprime/Lprime), 3)
F_qd = dec(1 + 2*tan(30*pi/180)*(1 - sin(30*pi/180))^2*0.7/B_d, 3)
Q_u = dec(Aprime*(q_0*N_q*F_qs*F_qd + 0.5*18*Bprime*N_γ*F_γs), 0)
#: Sin redondear nada sale 605 kN. El libro redondea A' a 1.193 m² y B' a 0.936 m antes de seguir; con SUS redondeos:
Q_ulib = dec(1.193*(q_0*N_q*1.424*1.135 + 0.5*18*0.936*N_γ*0.706), 0)
#: Q_{u} ≈ 606 kN, el número del libro. La diferencia de 1 kN es solo de redondeo.

### El ábaco sin leerlo a ojo

#: El trapecio del caso II está elegido para que su centroide caiga JUSTO bajo la carga (eso dibuja la figura 6.27a). Con esa condición el ábaco tiene fórmula cerrada (deducción de esta hoja, no del libro): con m la semisuma de L₁ y L₂,
m_c = (L_d/2 - e_L)/(1/2 + 6*r_B^2)
L_1c = dec(m_c + 6*m_c*r_B, 4)
L_2c = dec(m_c - 6*m_c*r_B, 4)
A_c = dec(0.5*(L_1c + L_2c)*B_d, 4)
#: Da L₁/L = 0.857 y L₂/L = 0.214 (el libro lee 0.85 y 0.21) y un área efectiva un 1 % mayor que la del ábaco.

## 5 · Lo que Das supone y lo que hace el FEM

#: El área efectiva A' de Das es de CAPACIDAD DE CARGA: una presión última UNIFORME sobre la parte de la zapata cuyo centroide cae bajo la carga. No es el área que de verdad toca el suelo en servicio. Para la presión de contacto, Das (ec. 6.53) y la sección 3 suponen una zapata RÍGIDA con reparto LINEAL.
#: El FEM no supone eso: la zapata es una placa (flexible) sobre resortes que solo trabajan a compresión (el «Gap» de CSI: fuerza = k·d si el resorte se comprime, cero si se estira). Se resuelve, se apagan los resortes que quedaron en tracción y se vuelve a resolver hasta que el contacto no cambia. Mismo ejemplo 6.10, con Q = 606 kN; lo que Das no da se eligió: espesor 0.40 m, columna 0.30 m, f'c 240 kgf/cm², ks = 2000 tonf/m³. Malla 30 × 30, la misma nudo a nudo en los cuatro programas.
#tabla("Programa","q_max [tonf/m²]:3","Contacto [m²]:3","Nudos en contacto:0","vs SAP2000 [%]:4")({"SAP2000 24 (juez)","Hekatan Struct","SAFE 20","ETABS 22","Zapata RÍGIDA","Lineal (el suelo tira)"}; [81.914, 81.915, 81.915, 81.915, 82.211, 76.670]; [1.888, 1.888, 1.888, 1.888, 1.884, 2.250]; [798, 798, 798, 798, 0, 961]; [0, 0.0002, 0.0002, 0.0010, 0.36, -6.4])
#: Los cuatro programas dan lo mismo a 4 cifras y despegan el MISMO borde (798 de 961 nudos tocan). La zapata rígida da 0.36 % más de presión máxima: la placa real se flexa un poco y reparte mejor. Si se deja que el suelo tire (análisis lineal) la presión máxima sale un 6 % MENOR y hay tracción bajo el borde levantado: el lineal queda del lado inseguro.

## 6 · La animación: la presión al crecer e (una dirección)

#: La zapata del ejemplo con Q = 61.8 tonf (606 kN) y la carga moviéndose en una sola dirección, de e = 0 a e = B/3 en pasos de B/60. Hasta e = B/6 la presión es un trapecio que se inclina; en e = B/6 es un triángulo justo; pasado ese punto el borde se despega (presión cero) y el triángulo se acorta y sube. x se mide desde el borde cargado. Pasa el ratón por encima para pausar.
#anim fplot(q = ((1+sign(10-n))/2)*(27.4644*(1+0.1*n) - 27.4644*0.133333*n*x) + ((1-sign(10-n))/2)*(54.9289/(1.5-0.05*n))*((1 - x/(2.25-0.075*n)) + abs(1 - x/(2.25-0.075*n)))/2, [0 1.5]), n = 0:20
#: La presión máxima (en el borde, x = 0) y el largo de contacto en función de e, para la misma zapata:
#fila
#fplot(q_max = 27.4644*(1 + 4*x)*(1+sign(0.25-x))/2 + (54.9289/(1.5-2*x))*(1-sign(0.25-x))/2, [0 0.5])
#fplot(contacto = 1.5*(1+sign(0.25-x))/2 + 3*(0.75-x)*(1-sign(0.25-x))/2, [0 0.5])
#finfila

### El FEM sobre el mismo barrido

#: Barrido con otra zapata (2 × 2 × 0.5 m, P = 60 tonf, malla 60 × 60) en Hekatan y SAP2000, frente a la fórmula de la zapata rígida:
#tabla("e/L","Fórmula q_max [tonf/m²]:3","Hekatan [tonf/m²]:3","SAP2000 [tonf/m²]:3","Contacto fórmula [m]:3","Contacto Hekatan [m]:3")({"0","1/12","1/6","1/4","1/3"}; [15.000, 22.500, 30.000, 40.000, 60.000]; [15.180, 22.464, 30.000, 40.055, 60.072]; [15.180, 22.464, 30.000, 40.052, 60.038]; [2.000, 2.000, 2.000, 1.500, 1.000]; [2.000, 2.000, 2.000, 1.502, 1.002])
#: Lo mismo en una gráfica: la curva es la fórmula de la zapata rígida (Das, ecs. 6.51 y 6.53) en función de e/L; los puntos son el FEM (SAP2000 y Hekatan) con la zapata flexible:
#fplot(q_max = 15*(1 + 6*x)*(1+sign(1/6-x))/2 + (20/(1-2*x))*(1-sign(1/6-x))/2, SAP2000 = [0 15.180; 1/12 22.464; 1/6 30.000; 1/4 40.052; 1/3 60.038], Hekatan = [0 15.180; 1/12 22.464; 1/6 30.000; 1/4 40.055; 1/3 60.072], [0 0.4])
#: Hasta e/L = 1/6 el problema es lineal y todo coincide; más allá, el FEM sigue a la fórmula del triángulo con el borde levantado. Hekatan y SAP2000 quedan a menos de 0.06 % (lo que queda es la tolerancia de convergencia de SAP2000, 1e-4).
