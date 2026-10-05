# Zapata esquinera por elementos finitos: levantamiento en dos direcciones, contra Hekatan Struct y GEO5
#numerico

#: **Qué se calcula.** La zapata del Demo01 de GEO5 con la columna **en la esquina** (a 1 cm de dos bordes, hoja 106). La resultante cae a 0.41 m del centro en x y a 0.39 m en y: casi en la esquina. Con suelo que no tira, solo una **esquina** de la zapata queda apoyada.
#: **Con qué.** La placa gruesa y los muelles solo a compresión de **Hekatan Struct** (hojas 135 y 136), nudo a nudo contra Struct; la zapata rígida (pirámide de presiones, fórmula cerrada) y el **área efectiva** de GEO5 (0.39 × 0.43 m).

## 1 · Datos (Demo01 de GEO5, hojas 104 a 106)

l_x = 1.2 'lado de la zapata en x [m]
l_y = 1.2 'lado de la zapata en y [m]
t_z = 0.4 'canto de la zapata [m]
c_x = 0.4 'lado de la columna [m]
d_f = 1.2 'profundidad del fondo desde la rasante [m]
E_c = 30000000 'módulo del hormigón C20/25 de GEO5, 30 000 MPa [kPa]
ν = 0.2 'coeficiente de Poisson (el que usa Hekatan Struct en las cáscaras)
γ_1 = 17.5 'peso específico del suelo 1 [kN/m3]
N_1 = 3000 'axial de la columna, carga 1 [kN]
M_x = -2 'momento alrededor de x, carga 1 [kN·m]
M_y = 70 'momento alrededor de y, carga 1 [kN·m]
H_x = 14 'horizontal en x, carga 1 [kN]
H_y = 5 'horizontal en y, carga 1 [kN]
G_z = 13.248 'peso de la zapata, 1.2·1.2·0.4·23 (hoja 104) [kN]
Z_r = 20.48 'peso del relleno sobre la zapata (hoja 104) [kN]
V_d = N_1 + G_z + Z_r 'vertical total en el fondo [kN]


#: **Dónde queda la columna (hoja 106).** GEO5 pide a_{x}, la distancia del borde a la cara de la columna: a_{x} = 0.01 m, así que el eje está a 0.01 + 0.20 = 0.21 m del borde, a p = 0.39 m del centro. La excentricidad de GEO5 (ayuda «Stress in the Footing Bottom») suma la del axial corrido N·p:
a_x = 0.01 'del borde a la cara de la columna (GEO5) [m]
p_x = a_x + c_x/2 - l_x/2 'eje de la columna desde el centro, en x [m]

p_y = a_x + c_x/2 - l_y/2 'eje de la columna desde el centro, en y [m]
e_x = (-M_y + H_x·t_z + N_1·p_x)/V_d 'excentricidad en x (GEO5: 0.339·1.2) [m]
e_y = (M_x + H_y·t_z + N_1·p_y)/V_d 'excentricidad en y (GEO5: 0.321·1.2) [m]

## 1b · La zapata dibujada, con sus cargas y cotas

#: **Cómo se lee.** Dos vistas a escala, en metros. **Planta:** el cuadrado grueso es la zapata de 1.20 × 1.20 m; el cuadro gris, la columna de 0.40 × 0.40 m (la columna está en la **esquina** (a 0.01 m de los dos bordes): su eje queda a 0.39 m del centro en x y en y). Las flechas rojas son las cargas horizontales de la carga 1 (H_{x} = 14 kN y H_{y} = 5 kN) y N = 3000 kN baja por el eje de la columna; M_{y} = 70 kN·m y M_{x} = −2 kN·m la giran. La cruz verde marca la **resultante** del fondo: está a e_{x} = -0.407 m y e_{y} = -0.386 m del centro. **Corte:** la zapata de 0.40 m enterrada a 1.20 m bajo la rasante, apoyada en **muelles de Winkler** (rayas azules verticales: cada nudo de la malla lleva uno y solo trabaja a compresión).
#dibujo("Planta: zapata esquinera de 1.20 × 1.20 m, columna de 0.40 m, cargas de la carga 1 y resultante", ud = m, escala = auto, cotas = m, alto = 150)
#  rect(-l_x/2, -l_y/2, l_x, l_y, "gruesa")
#  achurado(-l_x/2, -l_y/2, l_x, l_y, "concreto")
#  rect(-0.590, -0.590, c_x, c_x, "denso")
#  linea(-0.8, 0, 0.8, 0, "eje")
#  linea(0, -0.8, 0, 0.8, "eje")
#  circulo(-0.390, -0.390, 0.05, "rojo")
#  flecha(-0.390, -0.390, -0.110, -0.390, "rojo")
#  flecha(-0.390, -0.390, -0.390, -0.290, "rojo")
#  texto(-0.090, -0.490, "Hx", 2.5, "i")
#  texto(-0.340, -0.230, "Hy", 2.5, "i")
#  texto(-0.340, -0.670, "N = 3000 kN", 2.5, "i")
#  linea(-0.447, -0.386, -0.367, -0.386, "media verde")
#  linea(-0.407, -0.426, -0.407, -0.346, "media verde")
#  texto(-0.407, -0.506, "resultante", 2.5, "c", estilo = "verde")
#  cota(-l_x/2, -0.82, l_x/2, -0.82, -0.05, "1.20")
#  cota(0.82, -l_y/2, 0.82, l_y/2, 0.05, "1.20")
#  cota(-0.590, 0.82, -0.190, 0.82, 0.05, "0.40")
#fin
#dibujo("Corte: zapata de 0.40 m a 1.20 m de profundidad sobre muelles de Winkler (rayas azules)", ud = m, escala = auto, cotas = m, alto = 130)
#  linea(-1.6, 0, 1.6, 0, "media verde")
#  rect(-l_x/2, -d_f, l_x, t_z, "gruesa")
#  achurado(-l_x/2, -d_f, l_x, t_z, "concreto")
#  rect(-0.590, -d_f + t_z, c_x, d_f - t_z + 0.6, "gruesa")
#  linea(-1.6, -d_f, -l_x/2, -d_f, "trazos")
#  linea(l_x/2, -d_f, 1.6, -d_f, "trazos")
#  linea(-0.55, -d_f, -0.55, -d_f - 0.3, "media azul")
#  linea(-0.35, -d_f, -0.35, -d_f - 0.3, "media azul")
#  linea(-0.15, -d_f, -0.15, -d_f - 0.3, "media azul")
#  linea(0.05, -d_f, 0.05, -d_f - 0.3, "media azul")
#  linea(0.25, -d_f, 0.25, -d_f - 0.3, "media azul")
#  linea(0.45, -d_f, 0.45, -d_f - 0.3, "media azul")
#  flecha(-0.390, 0.95, -0.390, -d_f + t_z + 0.62, "rojo")
#  texto(-0.340, 1.0, "N = 3000 kN", 2.5, "i")
#  flecha(-0.840, 0.4, -0.590, 0.4, "rojo")
#  texto(-0.840, 0.5, "Hx = 14 kN", 2.5, "i")
#  texto(0.9, -d_f - 0.2, "muelles k_s", 2.5, "i", estilo = "azul")
#  cota(1.0, -d_f, 1.0, 0, 0.1, "1.20")
#  cota(-0.8, -d_f, -0.8, -d_f + t_z, -0.1, "0.40")
#  cota(-l_x/2, -d_f - 0.45, l_x/2, -d_f - 0.45, -0.05, "1.20")
#fin
#: **Qué muestran.** La planta dice dónde cae la carga respecto del centro: cuanto más excéntrica la resultante, menos área de suelo comprimido (en la zapata esquinera, una parte del fondo queda sin presión: el suelo no tira de la zapata). El corte dice por qué el modelo de elementos finitos se apoya en muelles solo a compresión: el fondo está a 1.20 m de profundidad y el suelo solo empuja.

## 2 · Módulo de balasto (criterio de la hoja 135)

#: Calibrado con el asiento de GEO5 (hoja 105): la carga 3 de servicio da una presión neta q_{n} y GEO5 un asiento de 15.9 mm; k_{s} = q_{n}/s.
q_n = (1500 + G_z + Z_r)/(l_x·l_y) - γ_1·d_f 'presión neta de la carga 3 [kPa]
k_s = q_n/0.0159 'módulo de balasto [kN/m3]


## 3 · Malla de elementos finitos

#: Malla regular de elementos cuadrados de 10 cm. Los nudos se numeran como en el .heks de Hekatan Struct: fila a fila, de x = −0.6 a 0.6 y de y = −0.6 hacia arriba. Así la comparación es **nudo a nudo**.
h_e = 0.1 'lado de cada elemento [m]
n_x = round(l_x/h_e) 'elementos por lado
n_n = n_x + 1 'nudos por lado
n_j = n_n^2 'número de nudos
n_e = n_x^2 'número de elementos
#hide
X_j = zeros(n_j, 1)
Y_j = zeros(n_j, 1)
for j = 1:n_n
  for i = 1:n_n
    q = (j - 1)·n_n + i
    X_j(q) = -l_x/2 + (i - 1)·h_e
    Y_j(q) = -l_y/2 + (j - 1)·h_e
  end
end
e_j = zeros(n_e, 4)
for j = 1:n_x
  for i = 1:n_x
    e = (j - 1)·n_x + i
    q = (j - 1)·n_n + i
    e_j(e, 1) = q
    e_j(e, 2) = q + 1
    e_j(e, 3) = q + n_n + 1
    e_j(e, 4) = q + n_n
  end
end
#show
#malla(X_j, Y_j, e_j)


#: **La columna en la malla.** Con elementos de 10 cm, la huella de la columna se pone **a ras del borde** (de −0.6 a −0.2: eje en −0.40). El centímetro que falta hasta el eje real (−0.39) no se pierde: entra como momento N·0.01 = 30 kN·m en el nudo del eje. Así la resultante es **exactamente** la de GEO5.

#: Lo mismo en y: huella de −0.6 a −0.2, y el centímetro como momento.

## 4 · El elemento (el de la hoja 135)

#: La **placa gruesa de Hekatan Struct** = Shell-Thick de CSI (`getBendingK_CSI`, shellQ4.cpp): giros con 9 funciones (4 de nudo, 4 de lado, 1 burbuja), cortante de lado de Wilson simetrizado, penalización 1000·tr(D_{b}) de la divergencia de los giros, 8 puntos de Gauss, B-barra y condensación de los 10 internos. La deducción está en la hoja 135; aquí se calcula igual.
a_e = h_e 'lado del elemento en x [m]
b_e = h_e 'lado del elemento en y [m]
D_0 = E_c·t_z^3/(12·(1 - ν^2)) 'rigidez a flexión [kN·m]
D_b = D_0·[1, ν, 0; ν, 1, 0; 0, 0, (1 - ν)/2] 'matriz de flexión [kN·m]
D_s = 5/6·E_c·t_z/(2·(1 + ν))·eye(2) 'matriz de cortante [kN/m]
D_tr = trace(D_b) 'para la penalización [kN·m]
P_n = 1000 'penalización de CSI
d_r(r, s) = [-(1 - s)/4, (1 - s)/4, (1 + s)/4, -(1 + s)/4, -r·(1 - s), (1 - s^2)/2, -r·(1 + s), -(1 - s^2)/2, -2·r·(1 - s^2)]
d_s(r, s) = [-(1 - r)/4, -(1 + r)/4, (1 + r)/4, (1 - r)/4, -(1 - r^2)/2, -s·(1 + r), (1 - r^2)/2, -s·(1 - r), -2·s·(1 - r^2)]
#hide
P_x = zeros(9, 22)
P_y = zeros(9, 22)
for j = 1:4
  P_x(j, 3·j - 1) = 1
  P_y(j, 3·j) = 1
  P_x(4 + j, 11 + 2·j) = 1
  P_y(4 + j, 12 + 2·j) = 1
end
P_x(9, 21) = 1
P_y(9, 22) = 1
#show
B_b(r, s) = [2/a_e·transpose(d_r(r, s))·P_y; -2/b_e·transpose(d_s(r, s))·P_x; 2/b_e·transpose(d_s(r, s))·P_y - 2/a_e·transpose(d_r(r, s))·P_x]
v_d(r, s) = 2/a_e·transpose(d_r(r, s))·P_x + 2/b_e·transpose(d_s(r, s))·P_y
l_1 = [-1/a_e, 0, 1/2, 1/a_e, 0, 1/2, 0, 0, 0, 0, 0, 0, 0, 2/3, 0, 0, 0, 0, 0, 0, 0, 0]
l_2 = [0, 0, 0, -1/b_e, -1/2, 0, 1/b_e, -1/2, 0, 0, 0, 0, 0, 0, -2/3, 0, 0, 0, 0, 0, 0, 0]
l_3 = [0, 0, 0, 0, 0, 0, -1/a_e, 0, -1/2, 1/a_e, 0, -1/2, 0, 0, 0, 0, 0, -2/3, 0, 0, 0, 0]
l_4 = [1/b_e, 1/2, 0, 0, 0, 0, 0, 0, 0, -1/b_e, 1/2, 0, 0, 0, 0, 0, 0, 0, 2/3, 0, 0, 0]
A_0 = (a_e/2·l_1 - a_e/2·l_3)/2 'parte constante de γ_xz
C_0 = (-b_e/2·l_4 + b_e/2·l_2)/2 'parte constante de γ_yz
m_m = ((-a_e/2·l_3 - a_e/2·l_1)/2 + (b_e/2·l_2 + b_e/2·l_4)/2)/2 'parte lineal simetrizada
B_s(r, s) = [2/a_e·transpose(A_0 + s·m_m); 2/b_e·transpose(C_0 + r·m_m)]
q_A = sqrt(7/9) 'puntos de esquina
q_B = sqrt(7/15) 'puntos de eje
r_g = [-q_A, q_A, q_A, -q_A, 0, q_B, 0, -q_B] 'r de los 8 puntos
s_g = [-q_A, -q_A, q_A, q_A, -q_B, 0, q_B, 0] 's de los 8 puntos
w_g = [9/49, 9/49, 9/49, 9/49, 40/49, 40/49, 40/49, 40/49] 'pesos
j_d = a_e·b_e/4 'jacobiano [m2]
#hide
M_b = zeros(3, 22)
for p = 1:8
  M_b = M_b + w_g(p)·B_b(r_g(p), s_g(p))
end
M_b = M_b/sum(w_g)
Q_i = zeros(22, 22)
for i = 13:22
  Q_i(i, i) = 1
end
K_22 = zeros(22, 22)
for p = 1:8
  B_1 = B_b(r_g(p), s_g(p)) - M_b·Q_i
  B_2 = B_s(r_g(p), s_g(p))
  v_1 = v_d(r_g(p), s_g(p))
  K_22 = K_22 + w_g(p)·j_d·(transpose(B_1)·D_b·B_1 + transpose(B_2)·D_s·B_2 + P_n·D_tr·transpose(v_1)·v_1)
end
K_e = K_22(1:12, 1:12) - K_22(1:12, 13:22)·inv(K_22(13:22, 13:22))·K_22(13:22, 1:12)
#show
#: Condensada a 12 × 12 (K_{e} = K_{bb} − K_{bi}·K_{ii}⁻¹·K_{ib}); su primer término, para comprobar:
K_e11 = K_e(1, 1) 'término w₁-w₁ (Struct: 2 735 178.7) [kN/m]


## 5 · Muelles del suelo: del área a los nudos

#: El muelle es de **área** (k_{s} en kN/m³) y el programa lo reparte a los nudos como lo hacen SAP2000, ETABS y SAFE: k_{n} = k_{s}·∫N_{i} dA. En un rectángulo cada elemento le da a cada uno de sus 4 nudos un cuarto de su área: un nudo interior recibe 4 cuartos, uno de borde 2 y una esquina 1.
#hide
k_n = zeros(n_j, 1)
#show
for e = 1:n_e
  for c = 1:4
    q = e_j(e, c)
    k_n(q) = k_n(q) + k_s·a_e·b_e/4
  end
end
k_esq = k_n(1) 'muelle de una esquina [kN/m]
k_bor = k_n(2) 'muelle de un nudo de borde [kN/m]
k_int = k_n(n_n + 2) 'muelle de un nudo interior [kN/m]
A_k = sum(k_n)/k_s 'suma de los muelles / k_s = área de la zapata [m2]
#: **Solo compresión.** El suelo empuja pero no tira. Es la ley del «Gap» de CSI (Analysis Reference Manual, p. 286; SAFE «Nonlinear Analysis for Uplift»): f = k·w si el nudo baja (w < 0), f = 0 si sube. Hekatan Struct la resuelve por **conjunto activo** (`muellesSoloCompresion.ts`): resolver con todos los muelles, apagar los de los nudos que suben, volver a resolver, hasta que el conjunto no cambie. Para esta ley el resultado es exacto, sin tolerancias.


## 6 · Cargas

#: Tres cosas: (1) el peso de la zapata y del relleno, repartido en toda la planta; (2) el axial de la columna, repartido sobre su huella de 40 × 40 cm; (3) los momentos que quedan, como momento en el nudo del eje de la columna. Cada elemento lleva su carga repartida a sus 4 nudos (un cuarto cada uno: es el vector consistente de una presión uniforme en un rectángulo).
q_g = (G_z + Z_r)/(l_x·l_y) 'peso de la zapata y del relleno [kPa]
q_c = N_1/c_x^2 'presión de la columna sobre su huella [kPa]
x_c = -0.4 'eje de la huella en x (a ras del borde) [m]
y_c = -0.4 'eje de la huella en y [m]
M_Xn = -e_y·V_d + N_1·y_c 'momento alrededor de x [kN·m]
M_Yn = e_x·V_d - N_1·x_c 'momento alrededor de y [kN·m]
n_c = round((y_c + l_y/2)/h_e)·n_n + round((x_c + l_x/2)/h_e) + 1 'nudo del eje de la columna
n_g = 3·n_j 'grados de libertad del modelo
#hide
F = zeros(n_g, 1)
#show
for e = 1:n_e
  x_m = (X_j(e_j(e, 1)) + X_j(e_j(e, 2)))/2
  y_m = (Y_j(e_j(e, 1)) + Y_j(e_j(e, 4)))/2
  q_e = q_g
  if abs(x_m - x_c) < c_x/2 && abs(y_m - y_c) < c_x/2
    q_e = q_e + q_c
  end
  for c = 1:4
    q = e_j(e, c)
    F(3·q - 2) = F(3·q - 2) - q_e·a_e·b_e/4
  end
end
#hide
F(3·n_c - 1) = F(3·n_c - 1) + M_Xn
F(3·n_c) = F(3·n_c) + M_Yn
F_z = 0
for q = 1:n_j
  F_z = F_z + F(3·q - 2)
end
#show
F_z 'suma de las fuerzas verticales = −V [kN]


## 7 · Ensamblaje

#: Tres grados de libertad por nudo: los del nudo j son 3(j − 1) + 1, 2, 3. La rigidez de cada elemento se **suma** en las filas y columnas de sus 4 nudos:
d_j(j) = 3·(j - 1) + (1:3)
d_e(e) = [d_j(e_j(e, 1)), d_j(e_j(e, 2)), d_j(e_j(e, 3)), d_j(e_j(e, 4))]
#hide
K = zeros(n_g, n_g)
#show
for e = 1:n_e
  g = d_e(e)
  K(g, g) = K(g, g) + K_e
end


## 8 · Solución: el conjunto activo

#hide
a_c = ones(n_j, 1)
h_c = zeros(30, 1)
n_it = 0
#show
for i_t = 1:30
  K_t = K
  for q = 1:n_j
    if a_c(q) == 1
      K_t(3·q - 2, 3·q - 2) = K_t(3·q - 2, 3·q - 2) + 1·k_n(q)
    end
  end
  U = clsolve(K_t, F)
  h_c(i_t) = sum(a_c)
  n_it = i_t
  c_b = 0
  for q = 1:n_j
    n_v = 0
    if U(3·q - 2) < 0
      n_v = 1
    end
    if n_v ~= a_c(q)
      c_b = 1
    end
    a_c(q) = n_v
  end
  if c_b == 0
    break
  end
end

n_it 'resoluciones (Struct: 6)
h_1 = h_c(1) 'contacto en la 1.ª resolución
h_2 = h_c(2) 'en la 2.ª
h_3 = h_c(3) 'en la 3.ª
h_4 = h_c(4) 'en la 4.ª
h_5 = h_c(5) 'en la 5.ª
h_6 = h_c(6) 'en la 6.ª (final)
n_ct = sum(a_c) 'nudos en contacto al final (de 169)
#: Struct: 169 → 120 → 83 → 60 → 48 → 43. **Las mismas 6 vueltas.**

#hide
w_j = zeros(n_j, 1)
p_j = zeros(n_j, 1)
R_j = zeros(n_j, 1)
P_m = zeros(n_n, n_n)
W_m = zeros(n_n, n_n)
for q = 1:n_j
  w_j(q) = 1000·U(3·q - 2)
  p_j(q) = -k_s·U(3·q - 2)·a_c(q)
  R_j(q) = p_j(q)·k_n(q)/k_s
end
for j = 1:n_n
  for i = 1:n_n
    P_m(i, j) = p_j((j - 1)·n_n + i)
    W_m(i, j) = w_j((j - 1)·n_n + i)
  end
end
#show


## 9 · Presión de contacto, zona levantada y deformada

p_max = max(p_j) 'presión máxima, en la esquina de la columna [kPa]
w_min = min(w_j) 'mayor hundimiento [mm]
w_max = max(w_j) 'mayor levantamiento, esquina opuesta [mm]
R_s = sum(R_j) 'suma de las reacciones = V [kN]
x_R = sum(R_j.*X_j)/R_s 'resultante del suelo en x = e_x [m]
y_R = sum(R_j.*Y_j)/R_s 'resultante del suelo en y = e_y [m]
A_c = sum(k_n.*a_c)/k_s 'área en contacto (área de los nudos que tocan) [m2]
#: **Mapa de presión** (kPa):
p_xy(x, y) = spline(1 + (x + l_x/2)/h_e, 1 + (y + l_y/2)/h_e, P_m)
#map(p_xy(x, y), [-0.6 0.6], [-0.6 0.6])
#: **Presión en 3D** (1 m = 20 000 kPa): un «pico» en la esquina:
#hide
X_3 = zeros(n_j, 3)
X_d = zeros(n_j, 3)
U_3 = zeros(n_j, 3)
for q = 1:n_j
  X_3(q, 1) = X_j(q)
  X_3(q, 2) = Y_j(q)
  X_3(q, 3) = p_j(q)/20000
  X_d(q, 1) = X_j(q)
  X_d(q, 2) = Y_j(q)
  U_3(q, 3) = U(3·q - 2)
end
e_f = zeros(0, 2)
v_f = zeros(0, 2)
#show

#modelo3d(X_3, e_j, e_f, p_j, v_f)
#: **Deformada** (×1): la zapata pivota sobre la esquina y la opuesta sube **más de 70 cm** con un suelo elástico lineal. Ese número no es real (antes rompe el suelo y vuelca la zapata), pero dice lo que hay que decir: así no se puede construir.
#modelo3d(X_d, e_j, e_f, w_j, v_f, U_3, 1)
#hide
C_m = zeros(n_n, n_n)
for j = 1:n_n
  for i = 1:n_n
    C_m(i, j) = a_c((j - 1)·n_n + i)
  end
end
#show
#: **Zona en contacto** (1 = toca, 0 = levantada): un triángulo/cuadrante en la esquina:
c_xy(x, y) = spline(1 + (x + l_x/2)/h_e, 1 + (y + l_y/2)/h_e, C_m)
#map(c_xy(x, y), [-0.6 0.6], [-0.6 0.6])
#hide
w_f = w_j
p_1 = p_max
A_1 = A_c
w_1 = w_max
n_1 = n_ct
i_1 = n_it
#show

## 10 · La zapata rígida: la pirámide de presiones

#: **Fórmula.** Si la zapata es rígida, la presión es un plano que se anula en una recta. Cuando esa recta corta los dos bordes, el contacto es un **triángulo** con el ángulo recto en la esquina cargada, de catetos a y b, y la presión es una **pirámide** (un tetraedro) de altura q. Dos condiciones: (1) el centro de gravedad de un tetraedro está a 1/4 de sus aristas: la resultante cae a a/4 y b/4 de la esquina; (2) su volumen es q·(a·b/2)/3 = V:
d_x = l_x/2 - abs(e_x) 'de la esquina a la resultante, en x [m]
d_y = l_y/2 - abs(e_y) 'de la esquina a la resultante, en y [m]
a_P = 4·d_x 'cateto del contacto en x (menor que 1.2: el triángulo cabe) [m]
b_P = 4·d_y 'cateto del contacto en y [m]
A_P = a_P·b_P/2 'área en contacto, rígida [m2]
q_P = 6·V_d/(a_P·b_P) 'presión en la esquina, rígida [kPa]
#: **¿Es rígida esta zapata?** Mismo FEM con la placa 10 veces más rígida:
#hide
a_c = ones(n_j, 1)
h_c = zeros(30, 1)
n_it = 0
#show
for i_t = 1:30
  K_t = 10·K
  for q = 1:n_j
    if a_c(q) == 1
      K_t(3·q - 2, 3·q - 2) = K_t(3·q - 2, 3·q - 2) + 1·k_n(q)
    end
  end
  U = clsolve(K_t, F)
  h_c(i_t) = sum(a_c)
  n_it = i_t
  c_b = 0
  for q = 1:n_j
    n_v = 0
    if U(3·q - 2) < 0
      n_v = 1
    end
    if n_v ~= a_c(q)
      c_b = 1
    end
    a_c(q) = n_v
  end
  if c_b == 0
    break
  end
end

#hide
p_r = 0
for q = 1:n_j
  p_r = max(p_r, -k_s·U(3·q - 2)·a_c(q))
end
#show
p_r 'presión máxima, placa 10 veces más rígida [kPa]
n_r = sum(a_c) 'nudos en contacto, placa 10 veces más rígida
#: Casi igual: es rígida. La diferencia con la pirámide (26 303 frente a 27 486 kPa) es la **malla** (muelles concentrados en nudos de 10 cm; el pico de una pirámide es justo lo que peor se discretiza). Medido con el mismo modelo afinando la malla: **26 303 → 27 173 → 27 406 kPa** con elementos de 10, 5 y 2.5 cm: converge a la fórmula.

## 11 · Hekatan LISP contra Hekatan Struct, nudo a nudo

#: Struct corrió el mismo modelo (`tests/zapata_fem/c3.heks`). Sus 169 flechas (mm):
#hide
w_S = [-400.5588750, -349.7962833, -299.0343115, -248.2633750, -197.4752815, -146.6865055, -95.9140201, -45.1509237, 5.6088213, 56.3706251, 107.1326693, 157.8949046, 208.6573375, -354.2359322, -303.4742697, -252.7127807, -201.9432977, -151.1573823, -100.3699154, -49.5973534, 1.1666905, 51.9300595, 102.6926235, 153.4551236, 204.2175721, 254.9800740, -307.9100625, -257.1510221, -206.3920172, -155.6246534, -104.8414730, -54.0554156, -3.2825927, 47.4856816, 98.2508616, 149.0146473, 199.7776727, 250.5403484, 301.3028859, -261.5704787, -210.8142844, -160.0598425, -109.2975705, -58.5188758, -7.7365263, 43.0376031, 93.8067595, 144.5729888, 195.3374014, 246.1007841, 296.8635727, 347.6260589, -215.2089099, -164.4553815, -113.7052861, -62.9500682, -12.1825959, 38.5919899, 89.3630650, 140.1312207, 190.8971339, 241.6615147, 292.4248658, 343.1875700, 393.9498831, -168.8439236, -118.0930689, -67.3462967, -16.5963122, 34.1620928, 84.9267095, 135.6930961, 186.4588272, 237.2235152, 287.9872238, 338.7501740, 389.5125654, 440.2745765, -122.4953780, -71.7461022, -21.0005160, 29.7487188, 80.5039361, 131.2635752, 182.0257593, 232.7888027, 283.5518120, 334.3144834, 385.0767505, 435.8386557, 486.6002629, -76.1584163, -25.4093153, 25.3383695, 76.0889659, 126.8428600, 177.5999792, 228.3594001, 279.1201610, 329.8815146, 380.6430268, 431.4044887, 482.1658066, 532.9269494, -29.8273525, 20.9234724, 71.6742027, 122.4258507, 173.1795116, 223.9353380, 274.6930561, 325.4521394, 376.2120910, 426.9725232, 477.7331783, 528.4938941, 579.2545646, 16.5029056, 67.2560185, 118.0082041, 168.7607946, 219.5145013, 270.2696939, 321.0263537, 371.7842669, 422.5431267, 473.3026450, 524.0625793, 574.8227384, 625.5829696, 62.8350279, 113.5885288, 164.3415429, 215.0946464, 265.8484288, 316.6032399, 367.3592152, 418.1162977, 468.8743324, 519.6331172, 570.3924500, 621.1521376, 671.9119992, 109.1677616, 159.9214304, 210.6747125, 261.4280005, 312.1817193, 362.9362115, 413.6916633, 464.4481198, 515.2055139, 565.9637158, 616.7225635, 667.4818779, 718.2414626, 155.5010797, 206.2547594, 257.0080289, 307.7612091, 358.5146837, 409.2687933, 460.0237570, 510.7796757, 561.5365351, 612.2942558, 663.0527064, 713.8117337, 764.5711318]
d_w = 0
w_mx = 0
for q = 1:n_j
  d_w = max(d_w, abs(w_f(q) - w_S(q)))
  w_mx = max(w_mx, abs(w_S(q)))
end
#show
Δ_c3 = 100·d_w/w_mx 'peor nudo, LISP frente a Struct, en % de la flecha máxima

#hide
S_ct = 0
for q = 1:n_j
  S_ct = S_ct + (1 - sign(w_S(q)))/2
end
r_Sct = S_ct
S_pmax = round(-k_s·min(w_S)/1000, 2)
S_wmax = round(max(w_S), 3)
#show

## 12 · Resumen: Hekatan LISP (FEM) · Hekatan Struct · GEO5 / analítico

#hide
g_bx = 0.386
g_by = 0.429
g_s = 18324.06
g_Rd = 3302.21
g_FS = 0.18
r_p1 = round(p_1, 2)
r_A1 = round(A_1, 3)
r_w1 = round(w_1, 2)
r_pr = round(p_r, 2)
r_AP = round(A_P, 4)
r_aP = round(a_P, 3)
r_bP = round(b_P, 3)
r_qP = round(q_P, 1)
r_d = round(Δ_c3, 6)
r_gA = round(g_bx·g_by, 4)
r_xR = round(x_R, 4)
r_yR = round(y_R, 4)
r_ex = round(e_x, 4)
r_ey = round(e_y, 4)
#show
#| Magnitud | Hekatan LISP (FEM) | Hekatan Struct (FEM) | rígida (pirámide) | GEO5 (Meyerhof) |
#|---|---:|---:|---:|---:|
#| nudos en contacto (de 169) / resoluciones | @{n_1} / @{i_1} | @{r_Sct} / 6 | (FEM, E × 10: @{n_r}) | |
#| área en contacto [m²] | @{r_A1} | | @{r_AP} (triángulo @{r_aP} × @{r_bP} / 2) | @{r_gA} (0.386 × 0.429) |
#| presión máxima [kPa] | @{r_p1} | @{S_pmax} | @{r_qP} (FEM, E × 10: @{r_pr}) | @{g_s} (uniforme) |
#| resultante del suelo (x; y) [m] | @{r_xR}; @{r_yR} | | | e = @{r_ex}; @{r_ey} |
#| levantamiento de la esquina opuesta [mm] | @{r_w1} | @{S_wmax} | | |
#| peor nudo LISP − Struct [% del máx.] | @{r_d} | — | | |
#: **Por qué FEM y Meyerhof difieren.** Igual que en la hoja 136, las dos tienen la misma resultante (comprobado en la tabla) y reparten distinto. Meyerhof pone un rectángulo **uniforme** de 0.386 × 0.429 m centrado en la resultante (18 324 kPa): convención para la capacidad portante. La zapata real, rígida sobre un suelo elástico sin tracción, apoya un **triángulo** el doble de grande (0.33 m²) con una **pirámide** de presiones: el pico (≈ 27 500 kPa) es el triple de la media del triángulo. El FEM lo reproduce y, de paso, enseña lo que Meyerhof no dice: la esquina opuesta se levanta.

## 13 · NEC-SE-GC 2015

#: · **Tabla 6, §6.2 (p. 42):** FS ≥ 3.0 → GEO5 da 0.18: **no cumple**.
#: · **Tabla 5, §5.2 (criterio nuestro para zapatas):** e/B ≤ 1/6 en cada dirección; aquí 0.34 y 0.32.
#: · Lo que añade el FEM: solo ≈ 1/10 de la planta toca el suelo y la esquina opuesta se levanta decenas de cm. La esquinera **necesita vigas de amarre en las dos direcciones** (la hoja 138 lo hace para una).
e_Bx = abs(e_x)/l_x 'excentricidad relativa en x
e_By = abs(e_y)/l_y 'excentricidad relativa en y
