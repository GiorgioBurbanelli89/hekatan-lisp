# Presión bajo la zapata del muro: Abaqus por tongadas contra Struct, estático y con sismo
#numerico

#: **Qué se calcula.** El muro de contención de Manabí (fuste de 2.60 m, zapata de 3.00 × 0.40 m) apoyado en arena. Se quiere la **presión del suelo bajo la zapata**: su resultante N, dónde cae (excentricidad e) y los valores en la puntera y en el talón. Es lo que se compara con la capacidad portante.
#: **Dos modelos.** (1) **Hekatan Struct**: el muro sobre muelles de balasto, con las cargas de GEO5 (peso, relleno sobre el talón, empuje de Coulomb y, con sismo, el incremento de Mononobe-Okabe). Da una presión **lineal**. (2) **Abaqus 2017**: el muro y el terreno en deformación plana, suelo Mohr-Coulomb y contacto con rozamiento. La presión sale del contacto, nudo a nudo, y **no** es una recta.
#: **Cómo se comparan.** Esta hoja toma los 7 valores de Abaqus, integra la resultante y su momento con la regla del trapecio, y saca la **recta equivalente**: la presión lineal que tiene la misma N y el mismo momento. Esa recta sí se compara con Struct.
#: **Unidades.** kN, m y kPa, por metro de muro.

## 1 · Por qué el muro se construyó por tongadas en Abaqus
#: Si el muro y el relleno se ponen **de una vez**, el peso del relleno hunde el terreno detrás del muro y arrastra el talón hacia abajo: la presión sale al revés (76.2 kPa en la puntera y 91.8 en el talón), mayor en el talón. En obra no pasa: primero se hace el muro, después se rellena por capas y cada capa asienta antes de la siguiente.
#: En Abaqus/Explicit todo el suelo está desde el principio, pero **sin peso**; el peso de cada parte entra en su turno con una rampa suave de 1.6 s (turnos de 2 s): terreno de apoyo → muro y tierra de delante → banda detrás del talón → cuatro tongadas de relleno de 0.65 m. Al final de cada turno la energía cinética es prácticamente cero frente a la interna: el cálculo es casi estático.
#| Final del turno | N en la base [kN/m] | Empuje en el trasdós [kN/m] | Coronación u_{x} [mm] |
#|---|---:|---:|---:|
#| muro y tierra de delante (4 s) | 47.57 | 0.00 | −3.60 |
#| tongada 2 (10 s) | 87.24 | 10.01 | +1.06 |
#| tongada 4, final (16 s) | 128.58 | 24.10 | +2.21 |
#: Números **citados** de Abaqus (muro_pesos.py, 29-sep-2026), no calculados aquí.

## 2 · Datos
B = 3 [m] 'ancho de la zapata
#: Abscisa de cada nudo del suelo bajo la zapata, medida desde la punta de la puntera. Son los nudos del **suelo** (malla de 0.50 m), la superficie esclava del contacto: en el lado del muro (malla de 0.10 m) Abaqus da picos falsos de 60 a 67 kPa justo donde caen los nudos del suelo.
x = [0; 0.5; 1; 1.5; 2; 2.5; 3] [m]
#: Presión de contacto de Abaqus, estático (peso por tongadas), en kPa:
p_e = [65.243; 45.628; 38.794; 39.803; 38.195; 40.663; 42.934]
#: Presión de contacto de Abaqus con el sismo seudoestático encima (k_{h} = 0.336 como fuerza de volumen k_{h}·γ), en kPa:
p_s = [81.951; 67.584; 53.279; 49.103; 42.539; 39.069; 18.068]
#: Struct (muelles): presión máxima y mínima bajo la zapata, en kPa, y la reacción vertical total N en kN/m (la misma que dan SAP2000 y ETABS con el mismo modelo; con sismo es 47.04 + 91.39 + 6.36 + 7.00 = 151.79, la suma de las cargas verticales):
q_e1 = 58.5
q_e2 = 39.1
q_s1 = 84.7
q_s2 = 28.9
n_se = 144.78
n_ss = 151.78

## 3 · Resultante y momento por la regla del trapecio
#: Entre dos nudos seguidos la presión se toma lineal. El tramo i aporta la fuerza F_{i} = (p_{i} + p_{i+1})/2·Δx, aplicada en el centro del tramo, x_{m} = (x_{i} + x_{i+1})/2. Se suman la fuerza y su momento respecto al **centro de la zapata** (x = B/2):
#: N = Σ F_{i}   ·   M_{c} = Σ F_{i}·(x_{m} − B/2)
#: Si M_{c} es negativo, la resultante cae del lado de la puntera. La excentricidad, medida hacia la puntera:
#: e = −M_{c}/N
#hide
N_e = 0
M_e = 0
N_s = 0
M_s = 0
#show
for i = 1:6
  d_x = x(i + 1) - x(i)
  x_m = (x(i) + x(i + 1))/2 - B/2
  N_e = N_e + (p_e(i) + p_e(i + 1))/2·d_x
  M_e = M_e + (p_e(i) + p_e(i + 1))/2·d_x·x_m
  N_s = N_s + (p_s(i) + p_s(i + 1))/2·d_x
  M_s = M_s + (p_s(i) + p_s(i + 1))/2·d_x·x_m
end
#: **Estático:**
N_e
e_e = -M_e/N_e [m]
#: **Con sismo:**
N_s
e_s = -M_s/N_s [m]
#: Comprobación con las fuerzas de contacto que suma Abaqus en la base: 128.58 kN/m (estático) y 150.83 kN/m (sismo). El trapecio da lo mismo, así que los 7 nudos bastan para la resultante.

## 4 · Recta equivalente
#: Una presión lineal con resultante N y excentricidad e (flexión compuesta de la zapata, como una sección de 1 m de fondo):
#: p_{puntera} = N/B·(1 + 6·e/B)   ·   p_{talón} = N/B·(1 − 6·e/B)
#: Mientras e ≤ B/6 = 0.50 m, toda la zapata está comprimida.
p_e1 = N_e/B·(1 + 6·e_e/B) [kPa]
p_e2 = N_e/B·(1 - 6·e_e/B) [kPa]
p_s1 = N_s/B·(1 + 6·e_s/B) [kPa]
p_s2 = N_s/B·(1 - 6·e_s/B) [kPa]
#: **¿Es lineal la presión de Struct?** Si lo fuera, su máximo y su mínimo darían su N: N = (q_{máx} + q_{mín})/2·B.
n_qe = (q_e1 + q_e2)/2·B
n_qs = (q_s1 + q_s2)/2·B
#: En estático sale 146.4 frente a la N real de 144.78: casi lineal. **Con sismo sale 170.4 frente a 151.78**: con sismo la presión de Struct **tampoco es una recta**; el 84.7 es un pico en la puntera, como el de Abaqus. Por eso, con sismo, se compara máximo con máximo y mínimo con mínimo, no rectas.
#: Máximo y mínimo de Abaqus, nudo a nudo:
m_e1 = max(p_e)
m_e2 = min(p_e)
m_s1 = max(p_s)
m_s2 = min(p_s)

## 5 · Dibujo
#dibujo("Presión bajo la zapata. Estático, izquierda; con sismo, derecha. Escala: 100 kPa = 1 m. Negro: Abaqus nudo a nudo; rojo: su recta equivalente; azul a trazos: Struct (solo en estático, donde es casi lineal)", ud = m, ancho = 190, alto = 110)
#  polilinea([0, 3, 3, 1.1, 1.1, 0.85, 0.7, 0, 0], [0, 0, 0.4, 0.4, 3, 3, 0.4, 0.4, 0], "gruesa")
#  linea(1.1, 3, 2.6, 3, "trazos gris")
#  texto(1.85, 3.25, "relleno", 2.4, "c")
#  polilinea([0, 0, 0.5, 1, 1.5, 2, 2.5, 3, 3], [0, -0.652, -0.456, -0.388, -0.398, -0.382, -0.407, -0.429, 0], "gruesa")
#  polilinea([0, 0, 3, 3], [0, -0.493, -0.365, 0], "rojo")
#  polilinea([0, 0, 3, 3], [0, -0.585, -0.391, 0], "trazos azul")
#  texto(-0.1, -0.65, "65.2", 2.2, "d")
#  texto(-0.1, -0.45, "49.3", 2.2, "d", estilo = "rojo")
#  texto(3.1, -0.43, "42.9", 2.2, "i")
#  texto(3.1, -0.25, "36.5", 2.2, "i", estilo = "rojo")
#  texto(1.5, -1.05, "ESTÁTICO", 2.6, "c")
#  polilinea([5, 8, 8, 6.1, 6.1, 5.85, 5.7, 5, 5], [0, 0, 0.4, 0.4, 3, 3, 0.4, 0.4, 0], "gruesa")
#  linea(6.1, 3, 7.6, 3, "trazos gris")
#  flecha(7.8, 1.8, 7.0, 1.8, "naranja")
#  texto(7.9, 1.8, "k_{h} = 0.336", 2.4, "i", estilo = "naranja")
#  polilinea([5, 5, 5.5, 6, 6.5, 7, 7.5, 8, 8], [0, -0.820, -0.676, -0.533, -0.491, -0.425, -0.391, -0.181, 0], "gruesa")
#  polilinea([5, 5, 8, 8], [0, -0.749, -0.257, 0], "rojo")
#  texto(4.9, -0.87, "82.0", 2.2, "d")
#  texto(4.9, -0.67, "74.9", 2.2, "d", estilo = "rojo")
#  texto(8.1, -0.18, "18.1", 2.2, "i")
#  texto(8.1, -0.33, "25.7", 2.2, "i", estilo = "rojo")
#  texto(6.5, -1.05, "CON SISMO", 2.6, "c")
#fin
#: Las ordenadas del dibujo son las presiones de la sección 2 divididas por 100; los rótulos rojos, las de la recta de la sección 4.
#: **Qué se ve.** Abaqus no da una recta. En estático hay un **pico bajo la punta de la puntera** y el resto es casi uniforme (39 a 43 kPa): la zapata es mucho más rígida que la arena y la carga se va al borde. Con sismo el muro empuja hacia delante y la presión se carga hacia la puntera; en el talón cae a 18 kPa.

## 6 · Comparación
#hide
d_e1 = round(100·(m_e1/q_e1 - 1), 1)
d_e2 = round(100·(m_e2/q_e2 - 1), 1)
d_s1 = round(100·(m_s1/q_s1 - 1), 1)
d_s2 = round(100·(m_s2/q_s2 - 1), 1)
d_ne = round(100·(N_e/n_se - 1), 1)
d_ns = round(100·(N_s/n_ss - 1), 1)
r_ne = round(N_e, 2)
r_ns = round(N_s, 2)
r_e1 = round(p_e1, 1)
r_e2 = round(p_e2, 1)
r_s1 = round(p_s1, 1)
r_s2 = round(p_s2, 1)
r_ee = round(e_e, 3)
r_es = round(e_s, 3)
#show
#| | Abaqus por tongadas | Struct (muelles) | Diferencia [%] | Recta equivalente de Abaqus |
#|---|---:|---:|---:|---:|
#| **Estático**: N [kN/m] | @{r_ne} | 144.78 | @{d_ne} | — |
#| presión máxima (puntera) [kPa] | @{m_e1} | 58.5 | @{d_e1} | @{r_e1} |
#| presión mínima [kPa] | @{m_e2} | 39.1 | @{d_e2} | @{r_e2} |
#| **Con sismo**: N [kN/m] | @{r_ns} | 151.78 | @{d_ns} | — |
#| presión máxima (puntera) [kPa] | @{m_s1} | 84.7 | @{d_s1} | @{r_s1} |
#| presión mínima [kPa] | @{m_s2} | 28.9 | @{d_s2} | @{r_s2} |
#: **Lectura.**
#: • **Con sismo coinciden la N** (menos de 1 %) **y el máximo en la puntera** (82.0 frente a 84.7, un 3 % menos). El mínimo no: 18.1 en Abaqus frente a 28.9. En Abaqus el suelo bajo la punta de la puntera plastifica y la carga se reparte distinto; los muelles de Struct son elásticos.
#: • **En estático Abaqus da menos N** (un 11 % menos) y un pico mayor en la puntera (65.2 frente a 58.5). En Struct todo el peso del relleno que hay sobre el talón baja a la zapata. En Abaqus parte de ese peso se cuelga por rozamiento del terreno de al lado, a través del plano vertical que pasa por la punta del talón, y ese plano los muelles no lo tienen.
#: • Con el sismo la excentricidad de Abaqus crece de @{r_ee} a @{r_es} m y se acerca al borde del tercio central (0.50 m), pero no llega: toda la zapata sigue comprimida.

## 7 · Lo que hay que decir de este modelo
#: • El sismo de Abaqus es **seudoestático aplicado a todo el terreno** (k_{h}·γ en los 30 m de la caja). El suelo plastifica en el borde derecho de la caja, lejos del muro (deformación plástica equivalente de hasta 0.93), y bajo la punta de la puntera (0.86): allí el suelo cede.
#: • El desplazamiento de −53 mm del muro con sismo es casi todo del **terreno**: el pie y la coronación se mueven casi igual y el muro solo se inclina 2.2 mm.
#: • Una tongada que aún no pesa ya está allí y tiene rigidez. Contra el muro casi no cuenta, porque el contacto se abre cuando el muro se aleja del relleno.
#: **Lo siguiente:** el mismo muro por tongadas con el **registro del sismo de Portoviejo** (APO1, 16-abr-2016) en la base, en lugar del k_{h}.
