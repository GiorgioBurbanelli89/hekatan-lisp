# Coeficientes sísmicos k_h y k_v del análisis pseudoestático: de dónde salen, qué norma pide cada uno y cuánto cambian el FS del talud con anclajes de GEO5
#numerico

#: **Qué se calcula.** El talud con muro y dos anclajes de la hoja 112 (GEO5 Slope Stability, **Demo01.gst**, etapa 3, el círculo del ejemplo) con **sismo pseudoestático**: una fuerza horizontal k_{h}·W y una vertical k_{v}·W en cada dovela. Se calcula el FS de Bishop y de Fellenius con el k_{h} y el k_{v} de cada norma (NEC-15, borrador NEC 2023, AASHTO, Eurocódigo 8, Hynes-Griffin y Franklin, Seed) y el **k_{y}** que da FS = 1, que es la entrada del método de desplazamientos de **Bray y Travasarou (2007)** que cita la NEC.
#: **Por qué.** La NEC-SE-GC 2015 solo da k_{h}; no dice nada de k_{v}. El borrador 2023 sí lo nombra, pero lo pone en cero. Otras normas sí lo usan. Aquí se mide cuánto pesa.
#: **Juez.** Con k_{h} = k_{v} = 0 la hoja reproduce el FS de GEO5 de la hoja 112 (1.78813 Bishop, 1.73651 Fellenius). Con k_{h} = 0.288, GEO5 da Bishop 1.00 y Fellenius 0.95 (capturas de la serie «taludes NEC»). **Los casos con k_{v} ≠ 0 no se han comprobado contra GEO5** (pendiente: GEO5 tiene el campo K_{v}).
#: **Unidades.** kN, m y kPa por metro de talud (como GEO5); los momentos también en tonf·m/m (1 tonf = 9.80665 kN).

## 1 · Qué son k_h y k_v

#: **La idea (Terzaghi, 1950).** Durante el sismo el suelo se acelera. La masa que puede deslizar, de peso W y masa W/g, recibe una fuerza de inercia igual a masa × aceleración y de sentido contrario a la aceleración. El método pseudoestático la cambia por una **fuerza fija** proporcional al peso:
#: F_{h} = (a_{h}/g)·W = k_{h}·W  (horizontal, hacia fuera del talud: la dirección desfavorable)
#: F_{v} = (a_{v}/g)·W = k_{v}·W  (vertical, hacia arriba o hacia abajo)
#: k_{h} y k_{v} son, por tanto, aceleraciones medidas en «g». Terzaghi propuso k_{h} = 0.1 (sismo severo), 0.2 (violento) y 0.5 (catastrófico).
#: **Por qué k_{h} es menor que el PGA.** El pico de aceleración dura una fracción de segundo y no actúa a la vez en toda la masa. Si el FS baja de 1 durante ese instante, la masa se desplaza un poco y se para (**bloque deslizante de Newmark, 1965**). Por eso se usa una fracción del pico:
#: — **Seed (1979)**, presas de tierra: k_{h} = 0.15 con FS ≥ 1.15.
#: — **Marcuson (1981)**: k_{h} entre 1/3 y 1/2 de la aceleración máxima (con su amplificación).
#: — **Hynes-Griffin y Franklin (1984)**, con el bloque de Newmark sobre 354 acelerogramas: k_{h} = 0.5·PGA/g, FS ≥ 1.0 con la resistencia reducida al 80 %; así el desplazamiento queda por debajo de 1 m.
#: — **NEC-SE-GC 2015**, Tabla 4, nota (*), p. 31: k_{h} = 0.6·a_{max}/g con a_{max} = Z·F_{a}, FS ≥ 1.05, y «se deberá evaluar la demanda de deformación sísmica del talud mediante el método de Bray JD and Travasarou T (2007)». **No menciona k_{v}.** No se ha encontrado artículo que justifique el 0.6 (sí el 0.5).
#: — **Borrador NEC-SE-GC 2023** (§8.1.5, p. 131-132, no oficial): «coeficientes de aceleración pseudo estáticos horizontales y verticales (kh y kv)»; a_{max} = Z (sin F_{a}); k_{h} = 0.6·a_{max}; «cuando no se consideren los efectos de licuefacción, el coeficiente pseudoestático vertical, kv, será igual a cero. Este valor de kh presupone una deformación del talud [...] entre 2.5 y 5.0 cm». FS ≥ 1.15 (Tabla 8.2).
#: **Dónde sí entra k_{v}.**
#: — **Eurocódigo 8-5 (EN 1998-5:2004) §4.1.3.3**, taludes: F_{H} = 0.5·α·S·W, F_{V} = ±0.5·F_{H} si a_{vg}/a_{g} > 0.6 y ±0.33·F_{H} si no (Pecker, 2011, lámina 23). α = a_{g}/g, S = factor de suelo; el Anejo A añade la amplificación topográfica S_{T} = 1.2 a 1.4. **Muros** (§7.3.2.2): k_{h} = α·S/r, k_{v} = ±0.5·k_{h} o ±0.33·k_{h}; r = 2 si el muro admite hasta 300·α·S mm, 1.5 si admite 200·α·S mm, 1 para muros anclados, de sótano o estribos.
#: — **AASHTO LRFD BDS §11.6.5** (muros): k_{h0} = F_{pga}·PGA (desplazamiento nulo); k_{h} = 0.5·k_{h0} si el muro admite 1 a 2 in (25 a 50 mm); k_{v} = 0 salvo campo cercano a la falla o aceleraciones verticales altas simultáneas. Taludes: §11.5.8 y Apéndice A11.5 (Kavazanjian et al. 1997; Anderson et al. 2008, NCHRP 611; Bray y Travasarou 2009).
#: — **FHWA-HI-99-012 (1998)**, cap. 7: un k_{v} ≤ k_{h} cambia el k_{y} en **no más del 10 %**, con un signo u otro según su sentido; la aceleración vertical está desfasada de la horizontal: se suele ignorar.
#: — **Muros: Mononobe-Okabe** (Okabe, 1926; Mononobe y Matsuo, 1929), que citan la NEC-15 §5.2 (p. 37) y el borrador 2023 (§8.3.9, Tabla 8.6, «kh y kv son los coeficientes sísmicos en dirección horizontal y vertical»). Es la cuña de Coulomb con las dos inercias: la resultante de peso e inercias se inclina ψ = atan[k_{h}/(1 − k_{v})] y el empuje es P_{AE} = ½·γ·H²·(1 − k_{v})·K_{AE}. Aquí k_{v} sí entra en la fórmula. El borrador da para muros k_{h} = a_{max}·F_{top}·F_{d} (F_{d} = 0.3 a 0.7, Tabla 8.7) y no fija k_{v}.
#: — **NEC-SE-DS 2015 §3.4** (estructuras): E_{v} ≥ 2/3·E_{h}. Es para voladizos de edificios, **no** para taludes, pero hay estudios ecuatorianos que la han aplicado al talud (k_{v} = 2/3·k_{h}).
#: **Signo de k_{v} (convención de GEO5, ayuda «Earthquake Effect - Standard Analysis»).** K_{v} > 0 multiplica el peso de suelo, agua y sobrecarga por (1 − K_{v}): la masa **pesa menos** (inercia hacia arriba); K_{v} < 0 la hace pesar más. «En caso de un k_{h} suficientemente grande, aliviar el talud (K_{v} > 0) es más desfavorable que sobrecargarlo». La fuerza horizontal es K_{h}·W_{i} en el centro de gravedad de la dovela, con la sobrecarga incluida.

## 2 · Qué pide cada norma (para este talud: zona V, suelo D)

#: Z = 0.40, F_{a} = 1.2 (NEC-SE-DS, Tabla 3). Para comparar, en AASHTO y en el EC8 se toma el PGA en superficie igual a Z·F_{a} = 0.48 (en AASHTO es F_{pga}·PGA; en el EC8, α·S). **Esa equivalencia es una suposición de esta hoja.**
#| Fuente | k_{h} | k_{v} | FS mínimo | Desplazamiento que admite |
#|---|---|---|---|---|
#| NEC-SE-GC 2015, Tabla 4 (p. 31) | 0.6·Z·F_{a} = 0.288 | no lo menciona | 1.05 (1.00 con CV máxima) | evaluarlo con Bray y Travasarou (2007) |
#| Borrador NEC-SE-GC 2023, §8.1.5 | 0.6·Z = 0.24 | 0 (sin licuación) | 1.15 (1.10) | 2.5 a 5 cm |
#| AASHTO LRFD §11.6.5 / §11.5.8 | 0.5·F_{pga}·PGA = 0.24 | 0 (salvo campo cercano) | factor de resistencia, no leído | 25 a 50 mm |
#| Eurocódigo 8-5, §4.1.3.3 | 0.5·α·S = 0.24 (×S_{T}) | ±0.5·k_{h} o ±0.33·k_{h} | FS = 1 con factores parciales | no fijado |
#| Hynes-Griffin y Franklin (1984) | 0.5·PGA = 0.24 | no | 1.0 con resistencia al 80 % | < 1 m |
#| Seed (1979) | 0.15 | no | 1.15 | ~1 m (presas) |
#| Bray y Travasarou (2009) | k para D_{a} dado (sección 12) | no | 1.0 | el que se elija (5, 15, 30 cm) |
#| NEC-SE-DS §3.4 (estructuras) | — | 2/3·E_{h} | — | no es para taludes |

## 3 · Datos del ejemplo (Demo01.gst, etapa 3)

#: Ejes de GEO5: x horizontal, z = cota. El talud mira hacia −x: la masa desliza hacia la izquierda.
#: **Los suelos** (leídos del archivo; el cuerpo rígido es el muro de pie):
gamma_1 = 20 'suelo 1, limo (arriba): peso específico [kN/m3]
phi_1 = 21 'suelo 1: ángulo de rozamiento efectivo [grados]
c_1 = 12 'suelo 1: cohesión efectiva [kPa]
gamma_2 = 18 'suelo 2, limo arenoso (debajo): peso específico [kN/m3]
phi_2 = 26.5 'suelo 2: ángulo de rozamiento efectivo [grados]
c_2 = 16 'suelo 2: cohesión efectiva [kPa]
gamma_R = 25 'cuerpo rígido (muro de pie): peso específico [kN/m3]
#: El suelo 3 (arcillolita, φ = 40°, c = 50 kPa) está debajo de la cota 105: el círculo no lo toca. Sin agua (Water: No water) y sin sismo.
#: **El terreno de la etapa 3** (con la excavación de la etapa 2 entre x = 41 y 54). Cada tramo va de (T_{A}, Z_{A}) a (T_{B}, Z_{B}); el escalón vertical del muro en x = 17.25 queda como salto entre el tramo 5 y el 6:
T_A = [-20; 0; 7.89; 11.54; 17.2; 17.25; 19; 20; 21.5; 26.5; 29.8; 32.39; 36.16; 38.69; 41; 41.5; 53; 54] 'abscisa del inicio de cada tramo del terreno [m]
T_B = [0; 7.89; 11.54; 17.2; 17.25; 19; 20; 21.5; 26.5; 29.8; 32.39; 36.16; 38.69; 41; 41.5; 53; 54; 70] 'abscisa del final de cada tramo [m]
Z_A = [115.32; 115.32; 115.2; 116.85; 117.99; 119; 119; 122.98; 122.98; 122.98; 124.92; 125.92; 127.92; 128.51; 128.67; 127.5; 127.5; 128.75] 'cota del inicio de cada tramo [m]
Z_B = [115.32; 115.2; 116.85; 117.99; 118; 119; 122.98; 122.98; 122.98; 124.92; 125.92; 127.92; 128.51; 128.67; 127.5; 127.5; 128.75; 128.75] 'cota del final de cada tramo [m]
#: **El techo del suelo 2.** Por debajo de esta línea hay suelo 2; por encima, el muro (de x = 17.2 a 21.5) o el suelo 1 (desde x = 21.5). Delante del muro coincide con el terreno:
S_A = [-20; 0; 7.89; 11.54; 17.2; 21.5; 36.18; 53.99] 'abscisa del inicio de cada tramo del techo del suelo 2 [m]
S_B = [0; 7.89; 11.54; 17.2; 21.5; 36.18; 53.99; 70] 'abscisa del final [m]
Y_A = [115.32; 115.32; 115.2; 116.85; 117.99; 120.02; 120.75; 121.7] 'cota del inicio [m]
Y_B = [115.32; 115.2; 116.85; 117.99; 117.9; 120.75; 121.7; 122.34] 'cota del final [m]
#: **Sobrecargas en franja** (permanentes, sobre el terreno): 12 kPa de x = 22.40 a 25.90, y 160 kPa de x = 42.00 a 52.00, en el fondo de la excavación.
q_1 = 12 'sobrecarga 1 [kPa]
a_1 = 22.4 'inicio de la sobrecarga 1 [m]
e_1 = 25.9 'final de la sobrecarga 1 [m]
q_2 = 160 'sobrecarga 2 [kPa]
a_2 = 42 'inicio de la sobrecarga 2 [m]
e_2 = 52 'final de la sobrecarga 2 [m]
#: **Anclajes** (etapa 3): dos, de 200 kN, separados 1 m, inclinados 30° bajo la horizontal, con 14 m de longitud libre:
x_h1 = 29.29 'cabeza del anclaje 1, x [m]
z_h1 = 124.62 'cabeza del anclaje 1, z [m]
x_h2 = 33.97 'cabeza del anclaje 2, x [m]
z_h2 = 126.76 'cabeza del anclaje 2, z [m]
P_a = 200 'fuerza de cada anclaje por metro (200 kN cada 1.00 m) [kN/m]
beta_a = 30 'inclinación de los anclajes bajo la horizontal [grados]
#: **El círculo** (Analysis, etapa 3, «Circular slip surface»):
x_c = 14.56 'centro del círculo, x [m]
z_c = 166.63 'centro del círculo, z [m]
R = 51.88 'radio [m]
#: **Lo que pide GEO5 en el ejemplo:** factores de seguridad (ASD), situación permanente, SF_{s} = 1.50.

## 4 · Las funciones del perfil

#: Un tramo recto vale para x entre su inicio y su final. La función «dentro» vale 1 dentro del tramo y 0 fuera (en el borde, ½ con cada vecino):
dentro(x, a, b) = (sign(x - a) + 1).*(sign(b - x) + 1)/4
#: La cota del terreno y la del techo del suelo 2 en cualquier x: la recta de cada tramo, quedándose solo con la del tramo donde cae x:
z_t(x) = sum(dentro(x, T_A, T_B).*(Z_A + (x - T_A).*(Z_B - Z_A)./(T_B - T_A)))
z_s(x) = sum(dentro(x, S_A, S_B).*(Y_A + (x - S_A).*(Y_B - Y_A)./(S_B - S_A)))
#: El círculo por debajo del centro:
z_o(x) = z_c - sqrt(R^2 - (x - x_c)^2)
#: El peso específico de lo que hay **encima** del suelo 2: el muro hasta x = 21.5 y el suelo 1 desde ahí:
g_u(x) = gamma_R + (gamma_1 - gamma_R)·(sign(x - 21.5) + 1)/2

## 5 · Dónde corta el círculo al terreno

#: El círculo entra en el terreno por el pie (a la izquierda) y sale por el fondo de la excavación. Son las raíces de z_{t}(x) − z_{o}(x) = 0; se buscan por bisección (se parte el intervalo por la mitad 60 veces):
#hide
x_L = 5
x_U = 10
for k = 1:60
  x_m = (x_L + x_U)/2
  if (z_t(x_L) - z_o(x_L))·(z_t(x_m) - z_o(x_m)) <= 0
    x_U = x_m
  else
    x_L = x_m
  end
end
x_a = (x_L + x_U)/2
x_L = 45
x_U = 50
for k = 1:60
  x_m = (x_L + x_U)/2
  if (z_t(x_L) - z_o(x_L))·(z_t(x_m) - z_o(x_m)) <= 0
    x_U = x_m
  else
    x_L = x_m
  end
end
x_b = (x_L + x_U)/2
x_L = 36.18
x_U = 53.99
for k = 1:60
  x_m = (x_L + x_U)/2
  if (z_s(x_L) - z_o(x_L))·(z_s(x_m) - z_o(x_m)) <= 0
    x_U = x_m
  else
    x_L = x_m
  end
end
x_x = (x_L + x_U)/2
#show
x_a = x_a 'entrada del círculo, por el pie [m]
z_a = z_o(x_a) 'su cota [m]
x_b = x_b 'salida del círculo, en el fondo de la excavación [m]
z_b = z_o(x_b) 'su cota [m]
#: GEO5 da los dos ángulos desde el centro: −7.57° y 41.04°. Aquí:
a_1g = asin((x_a - x_c)/R)·180/pi 'ángulo de la entrada [grados]
a_2g = asin((x_b - x_c)/R)·180/pi 'ángulo de la salida [grados]
#: El círculo **cruza el contacto** entre el suelo 2 y el suelo 1 en:
x_x = x_x 'cruce del círculo con el techo del suelo 2 [m]
#: A la izquierda de x_{x} la base del círculo está en el suelo 2 (φ = 26.5°); a la derecha, en el suelo 1 (φ = 21°).

## 6 · Las dovelas: cómo las corta GEO5

#: **Medido, no supuesto.** GEO5 guarda en el .gst las 19 fuerzas entre dovelas de su cálculo de Spencer (hoja 113). Sus dos saltos caen en las dovelas 11 y 13, donde están las cabezas de los anclajes (x = 29.29 y 33.97), y eso solo ocurre con **20 dovelas de igual ancho**. Además, GEO5 sustituye el arco por la **cuerda** (base recta) en cada dovela.
n = 20 'número de dovelas
b = (x_b - x_a)/n 'ancho de cada dovela [m]
#hide
X_i = zeros(n + 1, 1)
Z_i = zeros(n + 1, 1)
for i = 1:n + 1
  X_i(i) = x_a + (i - 1)·b
  Z_i(i) = z_o(X_i(i))
end
#show
#dibujo("Etapa 3 del Demo01: suelos, muro, sobrecargas, anclajes y el círculo con sus 20 dovelas", ud = m, cotas = m, ancho = 180, alto = 110)
#  poligono(21.5, 117.9, 21.5, 122.98, 20, 122.98, 19, 119, 17.25, 119, 17.25, 118, 17.2, 117.99, "media")
#  achurado([21.5, 21.5, 20, 19, 17.25, 17.25, 17.2], [117.9, 122.98, 122.98, 119, 119, 118, 117.99], "concreto")
#  polilinea([2, 7.89, 11.54, 17.2, 17.25, 17.25, 19, 20, 21.5, 26.5, 29.8, 32.39, 36.16, 38.69, 41, 41.5, 53, 54, 56], [115.29, 115.2, 116.85, 117.99, 118, 119, 119, 122.98, 122.98, 122.98, 124.92, 125.92, 127.92, 128.51, 128.67, 127.5, 127.5, 128.75, 128.75], "gruesa")
#  polilinea([2, 7.89, 11.54, 17.2, 21.5, 21.5, 36.18, 53.99, 56], [115.29, 115.2, 116.85, 117.99, 117.9, 120.02, 120.75, 121.7, 121.78], "media trazos azul")
#  polilinea([7.722, 7.722, 7.722, 9.768, 9.768, 9.768, 11.813, 11.813, 11.813, 13.858, 13.858, 13.858, 15.903, 15.903, 15.903, 17.948, 17.948, 17.948, 19.993, 19.993, 19.993, 22.038, 22.038, 22.038, 24.083, 24.083, 24.083, 26.128, 26.128, 26.128, 28.173, 28.173, 28.173, 30.218, 30.218, 30.218, 32.264, 32.264, 32.264, 34.309, 34.309, 34.309, 36.354, 36.354, 36.354, 38.399, 38.399, 38.399, 40.444, 40.444, 40.444, 42.489, 42.489, 42.489, 44.534, 44.534, 44.534, 46.579, 46.579, 46.579, 48.624], [115.203, 115.203, 115.203, 114.972, 116.049, 114.972, 114.823, 116.905, 114.823, 114.755, 117.317, 114.755, 114.767, 117.729, 114.767, 114.861, 119.0, 114.861, 115.035, 122.952, 115.035, 115.292, 122.98, 115.292, 115.632, 122.98, 115.632, 116.056, 122.98, 116.056, 116.568, 123.964, 116.568, 117.169, 125.082, 117.169, 117.864, 125.871, 117.864, 118.656, 126.938, 118.656, 119.55, 127.965, 119.55, 120.551, 128.442, 120.551, 121.668, 128.631, 121.668, 122.909, 127.5, 122.909, 124.285, 127.5, 124.285, 125.81, 127.5, 125.81, 127.5], "fina rojo")
#  polilinea([7.722, 9.768, 11.813, 13.858, 15.903, 17.948, 19.993, 22.038, 24.083, 26.128, 28.173, 30.218, 32.264, 34.309, 36.354, 38.399, 40.444, 42.489, 44.534, 46.579, 48.624], [115.203, 114.972, 114.823, 114.755, 114.767, 114.861, 115.035, 115.292, 115.632, 116.056, 116.568, 117.169, 117.864, 118.656, 119.55, 120.551, 121.668, 122.909, 124.285, 125.81, 127.5], "gruesa rojo")
#  linea(29.29, 124.62, 29.29 + 14·cos(pi/6), 124.62 - 7, "media verde")
#  linea(33.97, 126.76, 33.97 + 14·cos(pi/6), 126.76 - 7, "media verde")
#  flecha(26.0, 126.1, 29.29, 124.62, "verde")
#  flecha(30.7, 128.24, 33.97, 126.76, "verde")
#  flecha(23.3, 125.5, 23.3, 123.1, "azul")
#  flecha(25.0, 125.5, 25.0, 123.1, "azul")
#  flecha(43.0, 131.0, 43.0, 127.6, "azul")
#  flecha(45.5, 131.0, 45.5, 127.6, "azul")
#  flecha(48.0, 131.0, 48.0, 127.6, "azul")
#  flecha(50.5, 131.0, 50.5, 127.6, "azul")
#  texto(46.5, 131.6, "q = 160 kPa", 2.4, "c", estilo = "azul")
#  texto(24.2, 126.2, "12 kPa", 2.4, "c", estilo = "azul")
#  texto(38.5, 117.0, "anclajes 2 × 200 kN, 30°", 2.4, "i", estilo = "verde")
#  texto(19.5, 124.0, "muro", 2.4, "c")
#  texto(45.0, 125.0, "suelo 1", 2.4, "c")
#  texto(30.0, 113.0, "suelo 2", 2.4, "c", estilo = "azul")
#  texto(12.0, 112.6, "círculo R = 51.88 m (centro 50 m más arriba)", 2.4, "c", estilo = "rojo")
#  cota(7.722, 112.6, 48.624, 112.6, -0.4, "entrada a salida del círculo: 40.90 m")
#  cota(58.2, 115.29, 58.2, 128.75, 0.4, "13.46")
#  cota(14.0, 117.9, 14.0, 122.98, 0.4, "5.08")
#fin
#: Las líneas rojas finas son los cortes entre dovelas; la gruesa, las 20 cuerdas que forman la base. Las flechas verdes son los anclajes **reemplazados por su fuerza en la cabeza**, como hace GEO5.

## 7 · El peso de cada dovela

#: En una vertical de abscisa x y con la base de la dovela a la cota z_{d}, hay suelo 2 desde z_{d} hasta su techo z_{s}(x), y encima, hasta el terreno z_{t}(x), muro o suelo 1. El peso por metro de ancho de esa columna es:
#: q(x) = γ_{2}·máx(0, z_{s} − z_{d}) + γ_{u}·máx(0, z_{t} − máx(z_{s}, z_{d}))
#: y el peso de la dovela es la integral de q(x) en su ancho. Entre dos quiebres del perfil todas las líneas son rectas, así que q(x) es una recta: la **regla de Simpson** entre quiebres da la integral exacta. Los quiebres son los vértices del terreno y del techo del suelo 2 que caen dentro de la dovela, y el punto donde la cuerda corta al techo del suelo 2.
B_k = [7.89; 11.54; 17.2; 17.25; 19; 20; 21.5; 26.5; 29.8; 32.39; 36.16; 36.18; 38.69; 41; 41.5] 'quiebres del perfil dentro del círculo [m]
#: Lo mismo, multiplicando cada capa por la cota de su centro, da el momento estático y con él la cota del centro de gravedad z_{g} de cada dovela (se usa en la sección 10, con sismo).
#: **Sobrecargas.** La de franja se suma al peso de la dovela por el ancho que cae dentro: q·(min(x_{2}, final) − máx(x_{1}, inicio)).
#hide
q_d(x, a, s) = gamma_2·max(0, z_s(x) - a - s·x) + g_u(x)·max(0, z_t(x) - max(z_s(x), a + s·x))
m_d(x, a, s) = gamma_2·max(0, z_s(x) - a - s·x)·(z_s(x) + a + s·x)/2 + g_u(x)·max(0, z_t(x) - max(z_s(x), a + s·x))·(z_t(x) + max(z_s(x), a + s·x))/2
r_e = 1e-9
W_s = zeros(n, 1)
W_q = zeros(n, 1)
W = zeros(n, 1)
M_z = zeros(n, 1)
z_g = zeros(n, 1)
x_M = zeros(n, 1)
al = zeros(n, 1)
l_b = zeros(n, 1)
d_b = zeros(n, 1)
f_2 = zeros(n, 1)
P_t = zeros(30, 1)
for i = 1:n
  s_i = (Z_i(i + 1) - Z_i(i))/b
  a_i = Z_i(i) - s_i·X_i(i)
  m = 1
  P_t(1) = X_i(i)
  for k = 1:15
    if B_k(k) > X_i(i)
      if B_k(k) < X_i(i + 1)
        m = m + 1
        P_t(m) = B_k(k)
      end
    end
  end
  m = m + 1
  P_t(m) = X_i(i + 1)
  w_i = 0
  y_i = 0
  for j = 1:m - 1
    p = P_t(j) + r_e
    q = P_t(j + 1) - r_e
    g_1 = z_s(p) - a_i - s_i·p
    g_2 = z_s(q) - a_i - s_i·q
    if g_1·g_2 < 0
      r = p + (q - p)·g_1/(g_1 - g_2)
      w_i = w_i + (r - p)·(q_d(p, a_i, s_i) + 4·q_d((p + r)/2, a_i, s_i) + q_d(r, a_i, s_i))/6 + (q - r)·(q_d(r, a_i, s_i) + 4·q_d((r + q)/2, a_i, s_i) + q_d(q, a_i, s_i))/6
      y_i = y_i + (r - p)·(m_d(p, a_i, s_i) + 4·m_d((p + r)/2, a_i, s_i) + m_d(r, a_i, s_i))/6 + (q - r)·(m_d(r, a_i, s_i) + 4·m_d((r + q)/2, a_i, s_i) + m_d(q, a_i, s_i))/6
    else
      w_i = w_i + (q - p)·(q_d(p, a_i, s_i) + 4·q_d((p + q)/2, a_i, s_i) + q_d(q, a_i, s_i))/6
      y_i = y_i + (q - p)·(m_d(p, a_i, s_i) + 4·m_d((p + q)/2, a_i, s_i) + m_d(q, a_i, s_i))/6
    end
  end
  o_1 = max(0, min(X_i(i + 1), e_1) - max(X_i(i), a_1))
  o_2 = max(0, min(X_i(i + 1), e_2) - max(X_i(i), a_2))
  W_s(i) = w_i
  W_q(i) = q_1·o_1 + q_2·o_2
  W(i) = W_s(i) + W_q(i)
  x_m = (X_i(i) + X_i(i + 1))/2
  M_z(i) = y_i + q_1·o_1·z_t(max(X_i(i), a_1) + o_1/2) + q_2·o_2·z_t(max(X_i(i), a_2) + o_2/2)
  z_g(i) = M_z(i)/W(i)
  x_M(i) = x_m
  al(i) = atan(s_i)
  l_b(i) = b/cos(al(i))
  d_b(i) = sqrt(R^2 - l_b(i)^2/4)
  f_2(i) = max(0, min(1, (x_x - X_i(i))/b))
end
#show
#: Así quedan las 20 dovelas (W en kN/m, incluida la sobrecarga; α en grados; f_{2} es la parte de la base que está en el suelo 2):
#hide
Tab_1 = zeros(10, 7)
Tab_2 = zeros(10, 7)
for i = 1:10
  Tab_1(i, :) = [i, round(X_i(i), 3), round(X_i(i + 1), 3), round(W_s(i), 3), round(W_q(i), 3), round(al(i)·180/pi, 3), round(f_2(i), 3)]
  k = i + 10
  Tab_2(i, :) = [k, round(X_i(k), 3), round(X_i(k + 1), 3), round(W_s(k), 3), round(W_q(k), 3), round(al(k)·180/pi, 3), round(f_2(k), 3)]
end
#show
#: Columnas: dovela · x_{1} · x_{2} [m] · peso del suelo y del muro [kN/m] · sobrecarga [kN/m] · α [°] · f_{2}. Dovelas 1 a 10 y 11 a 20:
Tab_1
Tab_2
W_T = sum(W) 'peso total de la masa que desliza, con sobrecargas [kN/m]
#: La dovela 16 (de 38.40 a 40.44) es la que cruza el contacto: su base está un tercio en el suelo 2 y dos tercios en el suelo 1.

## 8 · El momento que hace girar la masa

#: GEO5 (ayuda de Spencer: «the line of action of the weight of block passes through the center of the segment of slip surface») aplica el peso de cada dovela en la vertical del **centro de su base**, x_{M}. El brazo respecto al centro del círculo es x_{M} − x_{c}; las dovelas a la izquierda del centro restan:
#: M_{a} = Σ W_{i}·(x_{M,i} − x_{c})
M_a = sum(W.*(x_M - x_c)) 'momento que hace girar [kN·m/m]
M_at = M_a/9.80665 'el mismo en tonf·m/m

## 9 · Los anclajes

#: GEO5 reemplaza cada anclaje por una **fuerza de compresión en su cabeza**, dirigida a lo largo del anclaje hacia dentro del talud: (P·cos β, −P·sen β). Esa fuerza entra en dos sitios:
#: — **Momento.** Respecto al centro del círculo su momento es r × F, con r el vector del centro a la cabeza. Es de sentido contrario al giro de la masa: **resiste**.
#: — **Normal en la base** de la dovela donde está la cabeza: aprieta la base y da más rozamiento.
c_b = cos(beta_a·pi/180) 'coseno de la inclinación del anclaje
s_b = sin(beta_a·pi/180) 'seno de la inclinación del anclaje
M_an = P_a·((x_c - x_h1)·s_b + (z_c - z_h1)·c_b) + P_a·((x_c - x_h2)·s_b + (z_c - z_h2)·c_b) 'momento resistente de los dos anclajes [kN·m/m]
k_1 = floor((x_h1 - x_a)/b) + 1 'dovela donde está la cabeza del anclaje 1
k_2 = floor((x_h2 - x_a)/b) + 1 'dovela donde está la cabeza del anclaje 2
#hide
F_n = zeros(n, 1)
F_v = zeros(n, 1)
F_n(k_1) = P_a·sin(al(k_1) + beta_a·pi/180)
F_n(k_2) = F_n(k_2) + P_a·sin(al(k_2) + beta_a·pi/180)
F_v(k_1) = P_a·s_b
F_v(k_2) = F_v(k_2) + P_a·s_b
#show
#: En la base de su dovela, la fuerza del anclaje forma con la base el ángulo α + β y aporta a la normal P·sen(α + β) (Fellenius) o, en el equilibrio vertical de Bishop, su componente vertical P·sen β.


## 10 · Las fuerzas sísmicas en cada dovela: el álgebra

#dibujo("Una dovela con sismo: peso W, inercia vertical k_v·W (k_v > 0 hacia arriba, convención de GEO5) e inercia horizontal k_h·W hacia el frente del talud, en su centro de gravedad", ud = m, escala = auto, alto = 90)
#  poligono(0, 0, 4, 1.6, 4, 7, 0, 6, "gruesa")
#  flecha(2, 3.4, 2, 0.9, "negro")
#  texto(2.2, 2.0, "W", 3.0, "i")
#  flecha(2, 3.4, 2, 5.4, "azul")
#  texto(2.2, 4.8, "k_v·W", 2.6, "i", estilo = "azul")
#  flecha(2, 3.4, -1.0, 3.4, "rojo")
#  texto(-2.6, 3.7, "k_h·W", 2.6, "i", estilo = "rojo")
#  linea(2, 0.8, 1.35, 2.43, "fina trazos")
#  texto(1.0, 1.5, "N", 2.6, "c")
#  flecha(1.0, 0.4, 3.2, 1.28, "verde")
#  texto(2.3, 0.4, "T (resiste)", 2.4, "c", estilo = "verde")
#  texto(4.3, 0.6, "base a α", 2.4, "i")
#fin
#: Cada dovela i tiene ahora tres cargas en la vertical del centro de su base o en su centro de gravedad: el peso W_{i}, la inercia vertical k_{v}·W_{i} (hacia arriba si k_{v} > 0) y la inercia horizontal k_{h}·W_{i}, aplicada en el centro de gravedad (cota z_{g,i}) y dirigida hacia el frente del talud (−x).
#: **1) El peso efectivo.** Lo vertical se suma: W_{i} − k_{v}·W_{i} = (1 − k_{v})·W_{i}.
#: **2) El momento que hace girar** respecto al centro (x_{c}, z_{c}). El peso efectivo tiene brazo x_{M,i} − x_{c}; la fuerza horizontal, brazo z_{c} − z_{g,i} (el centro está encima):
#: M_{A}(k_{h}, k_{v}) = Σ (1 − k_{v})·W_{i}·(x_{M,i} − x_{c}) + Σ k_{h}·W_{i}·(z_{c} − z_{g,i})
#: Sacando las constantes de la suma, queda una recta en k_{h} y en k_{v} (como y = m·x + b):
#: M_{A} = (1 − k_{v})·M_{a} + k_{h}·M_{h},  con M_{a} = Σ W_{i}·(x_{M,i} − x_{c}) (sección 8) y M_{h} = Σ W_{i}·(z_{c} − z_{g,i})
M_h = sum(W.*(z_c - z_g)) 'momento de las fuerzas k_h·W por unidad de k_h [kN·m/m]
M_ht = M_h/9.80665 'el mismo en tonf·m/m
#: **3) La resistencia de Bishop.** El equilibrio vertical de la dovela (las fuerzas entre dovelas son horizontales) da la normal; k_{h}·W es horizontal y **no entra**; k_{v} sí, por el peso efectivo:
#: T_{i} = [c·b + ((1 − k_{v})·W_{i} + F_{v,i})·tan φ] / [cos α_{i} + tan φ·sen α_{i}/FS]
#: FS = [Σ d_{i}·T_{i} + M_{an}] / M_{A}(k_{h}, k_{v})
#: **4) Fellenius.** La normal es la proyección de todas las cargas sobre la normal a la base: el peso efectivo da (1 − k_{v})·W·cos α, y la horizontal **le quita** k_{h}·W·sen α:
#: N_{i} = (1 − k_{v})·W_{i}·cos α_{i} − k_{h}·W_{i}·sen α_{i} + F_{n,i}
#: **5) Para Hynes-Griffin y Franklin** la resistencia del suelo va al 80 %: c y tan φ se multiplican por r_{s} = 0.8 (los anclajes no).
#: **Qué esperar de k_{v} antes de calcular.** Con k_{v} > 0 baja a la vez el momento motor (el término (1 − k_{v})·M_{a}) y el rozamiento de la base. El término k_{h}·M_{h} **no baja**. Si el sismo horizontal manda (k_{h}·M_{h} grande frente a M_{a}), pierde más la resistencia que el motor y el FS baja: k_{v} > 0 es el sentido desfavorable, como dice la ayuda de GEO5.
t_1 = tan(phi_1·pi/180) 'tan φ del suelo 1
t_2 = tan(phi_2·pi/180) 'tan φ del suelo 2
#: Las tres fórmulas, como funciones de k_{h}, k_{v} y r_{s} (r_{s} = 1: resistencia completa):
M_A(k_h, k_v) = (1 - k_v)·M_a + k_h·M_h
B_s(F, k_h, k_v, r_s) = (sum(d_b.*(f_2.*(r_s·c_2·b + (W·(1 - k_v) + F_v)·r_s·t_2)./(cos(al) + r_s·t_2·sin(al)/F) + (1 - f_2).*(r_s·c_1·b + (W·(1 - k_v) + F_v)·r_s·t_1)./(cos(al) + r_s·t_1·sin(al)/F))) + M_an)/M_A(k_h, k_v)
F_F(k_h, k_v, r_s) = (sum(d_b.*(r_s·(f_2·c_2 + (1 - f_2)·c_1).*l_b + (W·(1 - k_v).*cos(al) - k_h·W.*sin(al) + F_n)·r_s.*(f_2·t_2 + (1 - f_2)·t_1))) + M_an)/M_A(k_h, k_v)

## 11 · El FS con el k_h y el k_v de cada norma

Z_s = 0.4 'factor de zona sísmica Z (zona V), NEC-SE-DS
F_as = 1.2 'F_a, perfil D, zona V (NEC-SE-DS, Tabla 3)
k_N = 0.6·Z_s·F_as 'k_h de la NEC-15 = 0.6·Z·F_a
k_B = 0.6·Z_s 'k_h del borrador NEC 2023 = 0.6·Z
k_A = 0.5·Z_s·F_as 'k_h = 0.5·PGA en superficie (AASHTO 0.5·k_h0, Hynes-Griffin, EC8 0.5·α·S)
#: Los casos (k_{h}, k_{v}, r_{s}). En cada uno, Bishop se itera desde FS = 1 (60 vueltas):
K_H = [0; k_N; k_N; k_N; k_N; k_N; k_B; k_A; k_A; k_A; k_A; 0.15] 'k_h de cada caso
K_V = [0; 0; 0.5·k_N; -0.5·k_N; 2/3·k_N; -2/3·k_N; 0; 0; 0; 0.5·k_A; -0.5·k_A; 0] 'k_v de cada caso (+ = hacia arriba)
R_S = [1; 1; 1; 1; 1; 1; 1; 1; 0.8; 1; 1; 1] 'factor de resistencia del suelo (0.8 en Hynes-Griffin)
#hide
n_c = 12
S_B = zeros(n_c, 1)
S_F = zeros(n_c, 1)
for j = 1:n_c
  F = 1
  for k = 1:60
    F = B_s(F, K_H(j), K_V(j), R_S(j))
  end
  S_B(j) = F
  S_F(j) = F_F(K_H(j), K_V(j), R_S(j))
end
v_1 = round(S_B(1), 5)
w_1 = round(S_F(1), 5)
v_2 = round(S_B(2), 3)
w_2 = round(S_F(2), 3)
v_3 = round(S_B(3), 3)
w_3 = round(S_F(3), 3)
v_4 = round(S_B(4), 3)
w_4 = round(S_F(4), 3)
v_5 = round(S_B(5), 3)
w_5 = round(S_F(5), 3)
v_6 = round(S_B(6), 3)
w_6 = round(S_F(6), 3)
v_7 = round(S_B(7), 3)
w_7 = round(S_F(7), 3)
v_8 = round(S_B(8), 3)
w_8 = round(S_F(8), 3)
v_9 = round(S_B(9), 3)
w_9 = round(S_F(9), 3)
v_10 = round(S_B(10), 3)
w_10 = round(S_F(10), 3)
v_11 = round(S_B(11), 3)
w_11 = round(S_F(11), 3)
v_12 = round(S_B(12), 3)
w_12 = round(S_F(12), 3)
p_3 = round(100·(S_B(3)/S_B(2) - 1), 1)
p_4 = round(100·(S_B(4)/S_B(2) - 1), 1)
p_5 = round(100·(S_B(5)/S_B(2) - 1), 1)
p_6 = round(100·(S_B(6)/S_B(2) - 1), 1)
p_10 = round(100·(S_B(10)/S_B(8) - 1), 1)
p_11 = round(100·(S_B(11)/S_B(8) - 1), 1)
h_kN = round(k_N, 3)
h_kB = round(k_B, 3)
h_kA = round(k_A, 3)
h_v3 = round(0.5·k_N, 3)
h_v5 = round(2/3·k_N, 3)
h_v10 = round(0.5·k_A, 3)
#show
FS_B0 = S_B(1) 'Bishop sin sismo (GEO5: 1.78813; la hoja 112 da lo mismo)
FS_F0 = S_F(1) 'Fellenius sin sismo (GEO5: 1.73651)
FS_BN = S_B(2) 'Bishop con k_h = 0.288 y k_v = 0 (GEO5: 1.00)
FS_FN = S_F(2) 'Fellenius con k_h = 0.288 y k_v = 0 (GEO5: 0.95)
#| Caso | k_{h} | k_{v} | Bishop | Fellenius | Cambio de Bishop por k_{v} | FS pedido |
#|---|---:|---:|---:|---:|---:|---|
#| Sin sismo (control contra GEO5) | 0 | 0 | @{v_1} | @{w_1} | — | 1.50 (NEC estático) |
#| **NEC-15** (0.6·Z·F_{a}) | @{h_kN} | 0 | **@{v_2}** | @{w_2} | — | 1.05 |
#| NEC-15 + k_{v} = +0.5·k_{h} (arriba) | @{h_kN} | +@{h_v3} | @{v_3} | @{w_3} | @{p_3} % | 1.05 |
#| NEC-15 + k_{v} = −0.5·k_{h} (abajo) | @{h_kN} | −@{h_v3} | @{v_4} | @{w_4} | @{p_4} % | 1.05 |
#| NEC-15 + k_{v} = +2/3·k_{h} (arriba) | @{h_kN} | +@{h_v5} | @{v_5} | @{w_5} | @{p_5} % | 1.05 |
#| NEC-15 + k_{v} = −2/3·k_{h} (abajo) | @{h_kN} | −@{h_v5} | @{v_6} | @{w_6} | @{p_6} % | 1.05 |
#| **Borrador NEC 2023** (0.6·Z) | @{h_kB} | 0 | **@{v_7}** | @{w_7} | — | 1.15 |
#| **AASHTO** 0.5·k_{h0} | @{h_kA} | 0 | **@{v_8}** | @{w_8} | — | no leído |
#| **Hynes-Griffin y Franklin** (0.5·PGA, resistencia × 0.8) | @{h_kA} | 0 | **@{v_9}** | @{w_9} | — | 1.00 |
#| **EC8** 0.5·α·S, k_{v} = +0.5·k_{h} | @{h_kA} | +@{h_v10} | @{v_10} | @{w_10} | @{p_10} % | 1 con factores parciales |
#| **EC8** 0.5·α·S, k_{v} = −0.5·k_{h} | @{h_kA} | −@{h_v10} | @{v_11} | @{w_11} | @{p_11} % | 1 con factores parciales |
#| **Seed (1979)** | 0.15 | 0 | **@{v_12}** | @{w_12} | — | 1.15 |
#: La columna «cambio» compara con el mismo k_{h} y k_{v} = 0. Con el EC8 y la amplificación topográfica S_{T} = 1.2 (Anejo A, talud de más de 15°), k_{h} = 0.5·0.48·1.2 = 0.288: el mismo número de la NEC-15, y entonces k_{v} = ±0.144 son las filas 3 y 4.

## 12 · El k_y (FS = 1) y el desplazamiento de Bray y Travasarou

#: **El coeficiente de fluencia k_{y}** es el k_{h} que deja el FS justo en 1: por encima de k_{y} la masa desliza (Newmark, 1965). Se busca por bisección con Bishop, k_{v} = 0:
#hide
k_L = 0
k_U = 0.6
for i = 1:50
  k_m = (k_L + k_U)/2
  F = 1
  for k = 1:60
    F = B_s(F, k_m, 0, 1)
  end
  if F > 1
    k_L = k_m
  else
    k_U = k_m
  end
end
k_yv = (k_L + k_U)/2
k_L = 0
k_U = 0.6
for i = 1:50
  k_m = (k_L + k_U)/2
  F = 1
  for k = 1:60
    F = B_s(F, k_m, 0.5·k_m, 1)
  end
  if F > 1
    k_L = k_m
  else
    k_U = k_m
  end
end
k_yu = (k_L + k_U)/2
H_m = 0
for i = 1:n
  H_m = max(H_m, z_t(x_M(i)) - z_o(x_M(i)))
end
#show
k_y = k_yv 'coeficiente de fluencia, Bishop, k_v = 0
k_yu = k_yu 'coeficiente de fluencia con k_v = +0.5·k_h a la vez (arriba)
#: **Bray y Travasarou (2007)**, JGGE 133(4), ec. del desplazamiento mediano (ε = 0) para T_{s} ≥ 0.05 s; D en cm, S_{a} en g:
#: ln D = −1.10 − 2.83·ln k_{y} − 0.333·(ln k_{y})² + 0.566·ln k_{y}·ln S_{a} + 3.04·ln S_{a} − 0.244·(ln S_{a})² + 1.5·T_{s} + 0.278·(M − 7)
#: T_{s} = 4·H/V_{s} es el período de la masa que desliza; S_{a} es la aceleración espectral (5 %) en el período «degradado» 1.5·T_{s}; M es la magnitud del sismo de diseño.
#: **Datos que esta hoja SUPONE** (no vienen del Demo01; el ingeniero debe ponerlos del sitio): V_{s} = 250 m/s, M = 7.5, y S_{a} del espectro elástico de la NEC-SE-DS en la Sierra (η = 2.48).
H_s = H_m 'altura máxima de la masa que desliza (vertical entre el terreno y el círculo) [m]
V_s = 250 'velocidad de onda de corte del suelo, SUPUESTA [m/s]
M_w = 7.5 'magnitud de momento del sismo de diseño, SUPUESTA
T_s = 4·H_s/V_s 'período de la masa que desliza [s]
F_ds = 1.19 'F_d, perfil D, zona V (NEC-SE-DS, Tabla 4)
F_ss = 1.28 'F_s, perfil D, zona V (NEC-SE-DS, Tabla 5)
T_0 = 0.1·F_ss·F_ds/F_as 'inicio de la meseta del espectro NEC [s]
T_C = 0.55·F_ss·F_ds/F_as 'fin de la meseta del espectro NEC [s]
T_d = 1.5·T_s 'período degradado 1.5·T_s [s]
#: 1.5·T_{s} cae entre T_{0} y T_{C}, en la meseta del espectro: S_{a} = η·Z·F_{a}.
eta_s = 2.48 'η, provincias de la Sierra (NEC-SE-DS §3.3.1)
S_a = eta_s·Z_s·F_as 'aceleración espectral en 1.5·T_s [g]
l_k = ln(k_y) 'ln k_y
l_a = ln(S_a) 'ln S_a
D_bt = exp(-1.10 - 2.83·l_k - 0.333·l_k^2 + 0.566·l_k·l_a + 3.04·l_a - 0.244·l_a^2 + 1.5·T_s + 0.278·(M_w - 7)) 'desplazamiento mediano de Bray y Travasarou [cm]
D_mm = 10·D_bt 'el mismo en mm
#: **Al revés: el k_{h} para un desplazamiento admitido D_{a}** (Bray y Travasarou, 2009, JGGE 135(9)). Es la misma ecuación despejando x = ln k: queda una parábola 0.333·x² + a·x + (ln D_{a} − C) = 0, con a = 2.83 − 0.566·ln S_{a} y C el resto de términos que no dependen de k. Se toma D_{a} = 5 cm (el tope del borrador NEC 2023):
D_a = 5 'desplazamiento admitido [cm]
a_q = 2.83 - 0.566·l_a 'coeficiente a de la parábola
C_q = -1.10 + 3.04·l_a - 0.244·l_a^2 + 1.5·T_s + 0.278·(M_w - 7) 'términos sin k
k_5 = exp((-a_q + sqrt(a_q^2 - 4·0.333·(ln(D_a) - C_q)))/(2·0.333)) 'k_h que da D_a = 5 cm con FS = 1.0
#hide
F = 1
for k = 1:60
  F = B_s(F, k_5, 0, 1)
end
r_k5 = round(F, 3)
r_ky = round(k_y, 3)
r_kyu = round(k_yu, 3)
r_D = round(D_bt, 1)
r_k5k = round(k_5, 3)
#show
#: Con este k_{h} = @{r_k5k}, el FS de Bishop del círculo es @{r_k5}. Bray y Travasarou piden FS ≥ 1.0 con su k: **no cumple** (k_{y} = @{r_ky} es menor).
#: **Lectura.** El círculo resiste hasta k_{y} = @{r_ky}, casi justo el 0.288 de la NEC-15 (por eso el FS sale 1.00 y no 1.05). Con los datos supuestos, Bray y Travasarou dan **@{r_D} cm** de desplazamiento mediano, más que los 2.5 a 5 cm que el borrador da por aceptados. Un k_{v} hacia arriba igual a la mitad de k_{h} baja k_{y} a @{r_kyu}.

## 13 · Lectura

#: **1) k_{v} pesa poco y su sentido desfavorable es «hacia arriba».** Con k_{h} = 0.288, un k_{v} = ±0.5·k_{h} cambia el FS de Bishop un @{p_3} % (hacia arriba) y un @{p_4} % (hacia abajo); con ±2/3·k_{h}, un @{p_5} % y un @{p_6} %. Es lo que dice la FHWA (≤ 10 % si k_{v} ≤ k_{h}). El sentido desfavorable es k_{v} > 0 (la masa pesa menos), porque aquí el momento de k_{h}·W es grande frente al del peso: la resistencia pierde más que el motor.
#: **2) Lo que más cambia el FS es el k_{h} que se elige,** no el k_{v}: de 0.15 (Seed) a 0.288 (NEC-15) el FS de Bishop va de @{v_12} a @{v_2}. Casi todas las normas con «medio PGA» (AASHTO, Hynes-Griffin, EC8 sin topografía) llevan a 0.24 en este sitio, igual que el borrador NEC 2023 por otro camino (0.6·Z en lugar de 0.5·Z·F_{a}).
#: **3) Con la NEC-15 este círculo no cumple 1.05** (Bishop @{v_2}); con el borrador tampoco cumpliría 1.15 (Bishop @{v_7}). Hynes-Griffin y Franklin, con la resistencia al 80 %, da @{v_9} < 1.0.
#: **4) El FS pseudoestático no dice cuánto se mueve el talud;** por eso la NEC-15 pide además Bray y Travasarou. El puente entre los dos es k_{y}.
#: **Pendiente.** (a) Comprobar en GEO5 un caso con K_{v} ≠ 0 (que la fuerza horizontal sea K_{h}·W y no K_{h}·(1 − K_{v})·W). (b) Buscar el círculo crítico con sismo (es otro). (c) Leer el texto original de AASHTO §11.5.8 / §11.6.5 (factor de resistencia sísmico) y de EN 1998-5 §4.1.3.3 (aquí se citan por fuentes secundarias). (d) V_{s} y M del sitio.

## 14 · Referencias

#: Terzaghi, K. (1950). Mechanism of landslides. En: Application of Geology to Engineering Practice (Berkey Volume), GSA, 83-123.
#: Newmark, N. M. (1965). Effects of earthquakes on dams and embankments. Géotechnique 15(2), 139-160.
#: Seed, H. B. (1979). Considerations in the earthquake-resistant design of earth and rockfill dams. Géotechnique 29(3), 215-263.
#: Marcuson, W. F. (1981). Moderator's report for session on earth dams and stability of slopes under dynamic loads. Int. Conf. Recent Advances in Geotech. Earthq. Eng., St. Louis, vol. 3, p. 1175.
#: Hynes-Griffin, M. E. y Franklin, A. G. (1984). Rationalizing the seismic coefficient method. USACE WES, Misc. Paper GL-84-13.
#: FHWA (1998). Geotechnical Earthquake Engineering, Reference Manual, FHWA-HI-99-012, cap. 7 (§7.2.1) y cap. 9.
#: Bray, J. D. y Travasarou, T. (2007). Simplified procedure for estimating earthquake-induced deviatoric slope displacements. JGGE 133(4), 381-392.
#: Bray, J. D. y Travasarou, T. (2009). Pseudostatic coefficient for use in simplified seismic slope stability evaluation. JGGE 135(9), 1336-1340.
#: Bray, J. D. y Travasarou, T. (2011). Pseudostatic slope stability procedure. 5th ICEGE, Santiago, Chile.
#: Anderson, D. G. et al. (2008). Seismic Analysis and Design of Retaining Walls, Buried Structures, Slopes, and Embankments. NCHRP Report 611.
#: AASHTO LRFD Bridge Design Specifications, §11.5.8, §11.6.5 y Apéndice A11.5 (citados por Caltrans, Geotechnical Manual: «Seismic Overall Slope Stability», dic. 2025, y «Geotechnical Seismic Design of ERS», ene. 2026).
#: CEN (2004). EN 1998-5, Eurocódigo 8 parte 5, §4.1.3.3, §7.3.2.2 y Anejo A (por Pecker, A. (2011), «Eurocode 8: Background and Applications», JRC, Lisboa, láminas 23-24 y 28).
#: MIDUVI (2015). NEC-SE-GC Geotecnia y Cimentaciones, Tabla 4 y nota (*), p. 31; §5.2 (Mononobe-Okabe), p. 37. NEC-SE-DS Peligro Sísmico, §3.2.2 (Tablas 3-5), §3.3.1 y §3.4.
#: MIDUVI (2023). Borrador NEC-SE-GC (27-07-2023), §8.1.5 (p. 131-132), Tabla 8.2, §8.3.9 y Tabla 8.6 (Mononobe-Okabe con k_{h} y k_{v}).
#: Fine (2024). GEO5, ayuda: «Earthquake Effect - Standard Analysis» y «Influence of Earthquake».
