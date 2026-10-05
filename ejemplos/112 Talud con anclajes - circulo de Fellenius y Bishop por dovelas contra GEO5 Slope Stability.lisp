# Talud con muro, sobrecargas y dos anclajes: círculo de Fellenius y de Bishop por dovelas, contra GEO5
#numerico

#: **Qué se calcula.** La etapa 3 del ejemplo oficial de GEO5 Slope Stability (**Demo01.gst**): un talud de 13 m con un muro de pie (cuerpo rígido), una excavación arriba, dos sobrecargas en franja y **dos anclajes de 200 kN**. Se comprueba el círculo que GEO5 trae en el ejemplo (centro (14.56; 166.63), radio 51.88 m) con los métodos de **Fellenius/Petterson** y de **Bishop**.
#: **Cómo.** La masa sobre el círculo se corta en dovelas verticales. Se compara el momento que la hace girar respecto al centro, M_{a}, con el que resiste el corte en la base, M_{p}: FS = M_{p}/M_{a}. Fórmulas de la ayuda de GEO5 2024 («Circular Slip Surface», «Bishop», «Fellenius / Petterson», «Anchors in the Stability Analysis»).
#: **Juez.** GEO5 2024 con este archivo. GEO5 imprime el FS con dos decimales, pero **guarda dentro del .gst los momentos y el FS sin redondear** (se leyeron del archivo): esos son los números de la tabla final.
#: **Unidades.** kN, m y kPa por metro de talud (como GEO5); los momentos también en tonf·m (1 tonf = 9.80665 kN).

## 1 · Datos del ejemplo (Demo01.gst, etapa 3)

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

## 2 · Las funciones del perfil

#: Un tramo recto vale para x entre su inicio y su final. La función «dentro» vale 1 dentro del tramo y 0 fuera (en el borde, ½ con cada vecino):
dentro(x, a, b) = (sign(x - a) + 1).*(sign(b - x) + 1)/4
#: La cota del terreno y la del techo del suelo 2 en cualquier x: la recta de cada tramo, quedándose solo con la del tramo donde cae x:
z_t(x) = sum(dentro(x, T_A, T_B).*(Z_A + (x - T_A).*(Z_B - Z_A)./(T_B - T_A)))
z_s(x) = sum(dentro(x, S_A, S_B).*(Y_A + (x - S_A).*(Y_B - Y_A)./(S_B - S_A)))
#: El círculo por debajo del centro:
z_o(x) = z_c - sqrt(R^2 - (x - x_c)^2)
#: El peso específico de lo que hay **encima** del suelo 2: el muro hasta x = 21.5 y el suelo 1 desde ahí:
g_u(x) = gamma_R + (gamma_1 - gamma_R)·(sign(x - 21.5) + 1)/2

## 3 · Dónde corta el círculo al terreno

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

## 4 · Las dovelas: cómo las corta GEO5

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
#fin
#: Las líneas rojas finas son los cortes entre dovelas; la gruesa, las 20 cuerdas que forman la base. Las flechas verdes son los anclajes **reemplazados por su fuerza en la cabeza**, como hace GEO5.

## 5 · El peso de cada dovela

#: En una vertical de abscisa x y con la base de la dovela a la cota z_{d}, hay suelo 2 desde z_{d} hasta su techo z_{s}(x), y encima, hasta el terreno z_{t}(x), muro o suelo 1. El peso por metro de ancho de esa columna es:
#: q(x) = γ_{2}·máx(0, z_{s} − z_{d}) + γ_{u}·máx(0, z_{t} − máx(z_{s}, z_{d}))
#: y el peso de la dovela es la integral de q(x) en su ancho. Entre dos quiebres del perfil todas las líneas son rectas, así que q(x) es una recta: la **regla de Simpson** entre quiebres da la integral exacta. Los quiebres son los vértices del terreno y del techo del suelo 2 que caen dentro de la dovela, y el punto donde la cuerda corta al techo del suelo 2.
B_k = [7.89; 11.54; 17.2; 17.25; 19; 20; 21.5; 26.5; 29.8; 32.39; 36.16; 36.18; 38.69; 41; 41.5] 'quiebres del perfil dentro del círculo [m]
#: Lo mismo, multiplicando cada capa por la cota de su centro, da el momento estático y con él la cota del centro de gravedad z_{g} de cada dovela (solo se usa en la sección 9, con sismo).
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

## 6 · El momento que hace girar la masa

#: GEO5 (ayuda de Spencer: «the line of action of the weight of block passes through the center of the segment of slip surface») aplica el peso de cada dovela en la vertical del **centro de su base**, x_{M}. El brazo respecto al centro del círculo es x_{M} − x_{c}; las dovelas a la izquierda del centro restan:
#: M_{a} = Σ W_{i}·(x_{M,i} − x_{c})
M_a = sum(W.*(x_M - x_c)) 'momento que hace girar [kN·m/m]
M_at = M_a/9.80665 'el mismo en tonf·m/m

## 7 · Los anclajes

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

## 8 · Fellenius y Bishop

#: **La resistencia de la base.** En cada dovela, el cortante que puede dar la base es c·l + N·tan φ. Donde la base se reparte entre dos suelos (dovela 16), cada parte con su c y su φ, en la proporción f_{2} y 1 − f_{2}:
t_1 = tan(phi_1·pi/180) 'tan φ del suelo 1
t_2 = tan(phi_2·pi/180) 'tan φ del suelo 2
#: **El brazo del cortante.** El cortante va a lo largo de la cuerda; su distancia al centro es la apotema d = √(R² − l²/4), un poco menos que R. La normal pasa por el centro (la perpendicular por el punto medio de una cuerda pasa por el centro del círculo) y no da momento.
#: **Fellenius / Petterson** (sin fuerzas entre dovelas, Petterson 1955). La normal es la proyección de las cargas sobre la normal a la base:
#: N_{i} = W_{i}·cos α_{i} + F_{n,i}
#: M_{p} = Σ d_{i}·[c̄_{i}·l_{i} + N_{i}·tan φ̄_{i}] + M_{an}
#hide
N_F = W.*cos(al) + F_n
M_pF = sum(d_b.*((f_2·c_2 + (1 - f_2)·c_1).*l_b + N_F.*(f_2·t_2 + (1 - f_2)·t_1))) + M_an
#show
M_pF = M_pF 'momento resistente de Fellenius [kN·m/m]
FS_F = M_pF/M_a 'factor de seguridad de Fellenius
#: **Bishop simplificado** (fuerzas entre dovelas solo horizontales, Bishop 1955). Del equilibrio vertical de cada dovela sale la normal, y el cortante de la base queda (ayuda de GEO5, fórmula de Bishop):
#: T_{i} = [c·b + (W_{i} + F_{v,i})·tan φ] / [cos α_{i} + tan φ·sen α_{i}/FS]
#: M_{p} = Σ d_{i}·T_{i} + M_{an}
#: FS aparece a los dos lados: se itera desde FS = 1. Cada vuelta imprime el FS de esa vuelta:
F_k = 1
for k = 1:6
  F_k = (sum(d_b.*(f_2.*(c_2·b + (W + F_v)·t_2)./(cos(al) + t_2·sin(al)/F_k) + (1 - f_2).*(c_1·b + (W + F_v)·t_1)./(cos(al) + t_1·sin(al)/F_k))) + M_an)/M_a
  disp(F_k)
end
#hide
for k = 1:60
  F_k = (sum(d_b.*(f_2.*(c_2·b + (W + F_v)·t_2)./(cos(al) + t_2·sin(al)/F_k) + (1 - f_2).*(c_1·b + (W + F_v)·t_1)./(cos(al) + t_1·sin(al)/F_k))) + M_an)/M_a
end
M_pB = sum(d_b.*(f_2.*(c_2·b + (W + F_v)·t_2)./(cos(al) + t_2·sin(al)/F_k) + (1 - f_2).*(c_1·b + (W + F_v)·t_1)./(cos(al) + t_1·sin(al)/F_k))) + M_an
#show
M_pB = M_pB 'momento resistente de Bishop [kN·m/m]
FS_B = M_pB/M_a 'factor de seguridad de Bishop
#hide
r_FB = round(FS_B, 2)
r_FF = round(FS_F, 2)
r_an = round(100·M_an/M_pB, 1)
FS_B0 = (M_pB - M_an)/M_a
r_B0 = round(FS_B0, 2)
#show
#: **Lectura.** Bishop da FS = @{r_FB} y Fellenius @{r_FF}: los dos > 1.50. Fellenius queda por debajo porque, al quitar las fuerzas entre dovelas, aprieta menos la base. Los anclajes dan el @{r_an} % del momento resistente; quitando solo ese momento (y dejando la normal que dan en la base) el FS de Bishop bajaría a @{r_B0}.

## 9 · Hekatan contra GEO5

#hide
g_Ma = 97599.49439901125
g_MpF = 169482.57230579364
g_MpB = 174520.6917076903
g_FF = 1.7365107611408959
g_FB = 1.7881311043908268
x_Ma = round(100·(M_a/g_Ma - 1), 4)
x_MpF = round(100·(M_pF/g_MpF - 1), 4)
x_MpB = round(100·(M_pB/g_MpB - 1), 4)
x_FF = round(100·(FS_F/g_FF - 1), 4)
x_FB = round(100·(FS_B/g_FB - 1), 4)
h_Ma = round(M_a, 2)
h_MpF = round(M_pF, 2)
h_MpB = round(M_pB, 2)
h_FF = round(FS_F, 5)
h_FB = round(FS_B, 5)
h_a1 = round(a_1g, 3)
h_a2 = round(a_2g, 3)
#show
#: Los valores de GEO5 se leyeron **del propio Demo01.gst** (GEO5 guarda el resultado de cada análisis en float64; en pantalla redondea a 1.79 y 1.74):
#| Magnitud | Hekatan | GEO5 2024 | Diferencia [%] |
#|---|---:|---:|---:|
#| ángulo de entrada [°] | @{h_a1} | -7.573 | — |
#| ángulo de salida [°] | @{h_a2} | 41.041 | — |
#| M_{a} [kN·m/m] | @{h_Ma} | 97599.49 | @{x_Ma} |
#| M_{p} Fellenius [kN·m/m] | @{h_MpF} | 169482.57 | @{x_MpF} |
#| M_{p} Bishop [kN·m/m] | @{h_MpB} | 174520.69 | @{x_MpB} |
#| **FS Fellenius / Petterson** | @{h_FF} | 1.73651 | @{x_FF} |
#| **FS Bishop** | @{h_FB} | 1.78813 | @{x_FB} |
#: **Lectura honrada.** El FS coincide en las cuatro primeras cifras con los dos métodos (diferencia ≤ 0.02 %). Los momentos quedan entre 0.007 % y 0.02 % por encima. Lo que queda **no** se ha cerrado: con el FS y el ángulo δ de GEO5, la primera fuerza entre dovelas de Spencer (hoja 113) sale 0.08 % alta, lo que indica que el peso de las dovelas de GEO5 no es exactamente el área del polígono que se usa aquí. Cerrarlo pide sacar del binario (SlopeStability_5.dll) cómo calcula GEO5 el área de cada dovela; no se ha metido ningún factor para forzarlo.
#: **Lo que se probó y NO es lo de GEO5** (con la referencia en Python): cortar las dovelas en los vértices del perfil (M_{a} −0.48 %); peso en el centro de gravedad en lugar del centro de la base (M_{a} +0.07 %); base sin partir en el cruce de suelos (FS −0.36 %); arco exacto en vez de cuerda (M_{a} +0.18 %).
#: **Los demás métodos de GEO5 en este círculo** (leídos del .gst): Spencer 1.89988 (hoja 113), Janbu 1.89871, Morgenstern-Price 1.89871, Shachunyanc 1.84380, ITFM 1.98778, ITFM solución explícita 1.91459. Todos > 1.50.

## 10 · Comprobación con la NEC-SE-GC 2015

#: La etapa 3 es una situación permanente: la NEC-SE-GC 2015, Tabla 4 (p. 31), pide FS por corte ≥ **1.50** (talud estático, agua subterránea normal). Bishop @{r_FB} y Fellenius @{r_FF}: **cumple** con los dos.
#: **Pseudoestático (cálculo de Hekatan, no comprobado contra GEO5: el ejemplo no trae sismo).** k_{h} = 0.6·Z·F_{a} (nota de la Tabla 4); zona V, suelo D: Z = 0.40, F_{a} = 1.2. La fuerza k_{h}·W va horizontal hacia el frente, en el centro de gravedad de cada dovela (con la sobrecarga a la cota del terreno), y su brazo respecto al centro es z_{c} − z_{g}. Es como lo hace GEO5 en la hoja 96 (medido allí): en Bishop la normal no cambia; en Fellenius pierde k_{h}·W·sen α.
Z_s = 0.4 'factor de zona sísmica (zona V)
F_as = 1.2 'amplificación del suelo, perfil D, zona V
k_h = 0.6·Z_s·F_as 'coeficiente sísmico horizontal (NEC-15)
M_as = M_a + k_h·sum(W.*(z_c - z_g)) 'momento que hace girar, con sismo [kN·m/m]
#hide
F_s = 1
for k = 1:60
  F_s = (sum(d_b.*(f_2.*(c_2·b + (W + F_v)·t_2)./(cos(al) + t_2·sin(al)/F_s) + (1 - f_2).*(c_1·b + (W + F_v)·t_1)./(cos(al) + t_1·sin(al)/F_s))) + M_an)/M_as
end
N_s = W.*cos(al) - k_h·W.*sin(al) + F_n
#show
FS_Bs = F_s 'Bishop con sismo
FS_Fs = (sum(d_b.*((f_2·c_2 + (1 - f_2)·c_1).*l_b + N_s.*(f_2·t_2 + (1 - f_2)·t_1))) + M_an)/M_as 'Fellenius con sismo
#hide
r_Bs = round(FS_Bs, 3)
r_Fs = round(FS_Fs, 3)
#show
#: Con k_{h} = 0.288, Bishop da @{r_Bs} y Fellenius @{r_Fs}: **no cumple** el **1.05** que pide la NEC-15 en este círculo; con sismo haría falta más anclaje (el borrador NEC-SE-GC 2023, **no oficial**, pide 1.15 con k_{h} = 0.6·Z = 0.24, sin F_{a}). Ojo: es solo este círculo; con sismo el círculo crítico es otro y hay que buscarlo (GEO5: Analysis type = optimization).
