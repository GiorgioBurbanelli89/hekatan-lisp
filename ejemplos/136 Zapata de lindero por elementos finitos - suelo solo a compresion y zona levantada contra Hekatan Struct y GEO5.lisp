# Zapata de lindero por elementos finitos: suelo solo a compresión, zona levantada, contra Hekatan Struct y GEO5
#numerico

#: **Qué se calcula.** La zapata de 1.20 × 1.20 × 0.40 m del Demo01 de GEO5 con la columna **en el lindero** (a 1 cm del borde, hoja 106). La carga cae a 0.41 m del centro, fuera del tercio central: con una presión lineal, más de la mitad de la zapata tendría que «tirar» del suelo. El suelo no tira: la zapata **se levanta** por el borde opuesto y el problema deja de ser lineal.
#: **Con qué.** La placa gruesa y los muelles de área de **Hekatan Struct** (hoja 135), ahora con muelles **solo a compresión** (ley Gap de CSI) resueltos por conjunto activo. Se compara nudo a nudo con Struct (mismo .heks), con la **zapata rígida** analítica (Das, ec. 6.53: triángulo de presiones) y con el **área efectiva de Meyerhof** que usa GEO5 (franja de 0.39 m).

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

e_x = (-M_y + H_x·t_z + N_1·p_x)/V_d 'excentricidad en x (GEO5: 0.339·1.2 = 0.407) [m]
e_y = (M_x + H_y·t_z)/V_d 'excentricidad en y [m]

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
x_c = -0.4 'eje de la huella en la malla (a ras del borde) [m]
y_c = 0 'eje de la columna en y [m]
#: Momento que falta en el nudo del eje (mano derecha: M_{Y} = e_{x}·V, M_{X} = −e_{y}·V), descontado lo que ya pone la columna en su huella:
M_Xn = -e_y·V_d 'momento alrededor de x [kN·m]
M_Yn = e_x·V_d - N_1·x_c 'momento alrededor de y: el de la carga + el centímetro [kN·m]
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

#: Se resuelve con todos los muelles; los nudos que **suben** (w > 0) se sueltan; se vuelve a resolver; hasta que el conjunto no cambie. Es lo que hace Hekatan Struct (`muellesSoloCompresion.ts`) y, con pasos de carga, SAP2000/SAFE con el «Gap»:
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

n_it 'resoluciones
h_1 = h_c(1) 'nudos en contacto, 1.ª resolución
h_2 = h_c(2) 'nudos en contacto, 2.ª resolución
h_3 = h_c(3) 'nudos en contacto, 3.ª resolución
h_4 = h_c(4) 'nudos en contacto, 4.ª (la final)
n_ct = sum(a_c) 'nudos en contacto al final (de 169)
#: Struct hizo **las mismas 4 vueltas con los mismos nudos**: 169 → 117 → 91 → 78.

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

p_max = max(p_j) 'presión máxima, en el borde del lindero [kPa]
w_min = min(w_j) 'mayor hundimiento, borde del lindero [mm]
w_max = max(w_j) 'mayor levantamiento, borde opuesto [mm]
R_s = sum(R_j) 'suma de las reacciones del suelo = V [kN]
x_R = sum(R_j.*X_j)/R_s 'resultante del suelo = e_x [m]
A_c = sum(k_n.*a_c)/k_s 'área en contacto (área de los nudos que tocan) [m2]
#hide
x_0 = l_x/2
for i = 1:n_x
  q = (n_x/2)·n_n + i
  if w_j(q) < 0 && w_j(q + 1) >= 0
    x_0 = X_j(q) + h_e·w_j(q)/(w_j(q) - w_j(q + 1))
  end
end
#show

a_cn = x_0 + l_x/2 'largo en contacto sobre el eje y = 0 (donde w cambia de signo) [m]
#: **Mapa de presión** (kPa): toda la carga entra por la franja del lindero; el resto de la zapata está en el aire (presión 0):
p_xy(x, y) = spline(1 + (x + l_x/2)/h_e, 1 + (y + l_y/2)/h_e, P_m)
#map(p_xy(x, y), [-0.6 0.6], [-0.6 0.6])
#: **Presión en 3D** (1 m = 10 000 kPa):
#hide
X_3 = zeros(n_j, 3)
X_d = zeros(n_j, 3)
U_3 = zeros(n_j, 3)
for q = 1:n_j
  X_3(q, 1) = X_j(q)
  X_3(q, 2) = Y_j(q)
  X_3(q, 3) = p_j(q)/10000
  X_d(q, 1) = X_j(q)
  X_d(q, 2) = Y_j(q)
  U_3(q, 3) = U(3·q - 2)
end
e_f = zeros(0, 2)
v_f = zeros(0, 2)
#show

#modelo3d(X_3, e_j, e_f, p_j, v_f)
#: **Deformada** (×2): la zapata gira alrededor de la franja del lindero y el borde opuesto **se levanta** más de 13 cm. Color = flecha en mm (positiva = sube):
#modelo3d(X_d, e_j, e_f, w_j, v_f, U_3, 2)
#: **Zona en contacto** (1 = toca, 0 = levantada):
#hide
C_m = zeros(n_n, n_n)
for j = 1:n_n
  for i = 1:n_n
    C_m(i, j) = a_c((j - 1)·n_n + i)
  end
end
#show
c_xy(x, y) = spline(1 + (x + l_x/2)/h_e, 1 + (y + l_y/2)/h_e, C_m)
#map(c_xy(x, y), [-0.6 0.6], [-0.6 0.6])
#hide
w_f = w_j
p_1 = p_max
a_1 = a_cn
A_1 = A_c
w_1 = w_max
n_1 = n_ct
i_1 = n_it
#show

## 10 · La zapata rígida: FEM y fórmula de Das

#: **Fórmula (Das, ec. 6.53; Tomlinson):** zapata rígida, suelo sin tracción, e > B/6. La presión es un **triángulo**: su resultante (a un tercio del largo) tiene que caer bajo la carga, a B/2 − e del borde, y su volumen tiene que valer V:
a_D = 3·(l_x/2 - abs(e_x)) 'largo en contacto, rígida [m]
q_D = 2·V_d/(3·l_y·(l_x/2 - abs(e_x))) 'presión máxima, rígida [kPa]
#: **¿Se dobla la zapata?** Su longitud elástica sobre Winkler, ℓ = (D/k_{s})^{1/4}, es mayor que el lado: es prácticamente **rígida**. Se comprueba con el mismo FEM y la placa **10 veces más rígida** (la K de la placa es proporcional a E: basta multiplicarla):
l_el = (D_0/k_s)^(1/4) 'longitud elástica [m]
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
w_j = zeros(n_j, 1)
for q = 1:n_j
  w_j(q) = 1000·U(3·q - 2)
end
#show
#hide
p_r = 0
for q = 1:n_j
  p_r = max(p_r, -k_s·U(3·q - 2)·a_c(q))
end
#show
p_r 'presión máxima, placa 10 veces más rígida [kPa]
#hide
x_0 = l_x/2
for i = 1:n_x
  q = (n_x/2)·n_n + i
  if w_j(q) < 0 && w_j(q + 1) >= 0
    x_0 = X_j(q) + h_e·w_j(q)/(w_j(q) - w_j(q + 1))
  end
end
#show

a_r = x_0 + l_x/2 'largo en contacto, placa 10 veces más rígida [m]
#: Cambia un 0.2 %: la zapata de 40 cm **ya es rígida**. Entonces, ¿por qué el FEM no da exactamente a Das? Por la **malla**: los muelles están concentrados en nudos cada 10 cm y el borde del contacto cae entre dos nudos; eso alarga un poco el contacto (0.595 frente a 0.579 m) y baja el pico. Medido con el mismo modelo (casos.py, que es Struct a 1e-6 %) afinando la malla: presión máxima **8507 → 8693 → 8729 kPa** con elementos de 10, 5 y 2.5 cm, frente a 8728 de Das. El FEM converge a la fórmula.

## 11 · Hekatan LISP contra Hekatan Struct, nudo a nudo

#: Struct corrió el mismo modelo (`tests/zapata_fem/c2.heks`) con su código sin tocar. Sus 169 flechas (mm), guardadas aquí:
#hide
w_S = [-129.0644750, -107.3230314, -85.5896762, -63.8627917, -42.1396866, -20.4174536, 1.3068137, 23.0357470, 44.7685549, 66.5044782, 88.2428688, 109.9831909, 131.7247766, -129.1387879, -107.3942880, -85.6564616, -63.9236552, -42.1937160, -20.4644156, 1.2664901, 23.0011715, 44.7386435, 66.4781250, 88.2190482, 109.9609549, 131.7033948, -129.2273503, -107.4781907, -85.7341962, -63.9933690, -42.2540554, -20.5151932, 1.2243465, 22.9660906, 44.7089784, 66.4524310, 88.1961052, 109.9397698, 131.6832402, -129.3289404, -107.5737558, -85.8220981, -64.0707314, -42.3186005, -20.5667917, 1.1835518, 22.9332740, 44.6819100, 66.4293972, 88.1758067, 109.9212277, 131.6657749, -129.4380610, -107.6766464, -85.9170193, -64.1539984, -42.3833553, -20.6131992, 1.1486492, 22.9061137, 44.6600084, 66.4110653, 88.1598391, 109.9067765, 131.6522569, -129.5228975, -107.7571060, -85.9908718, -64.2180544, -42.4318577, -20.6461117, 1.1248352, 22.8880398, 44.6456970, 66.3992262, 88.1496227, 109.8975872, 131.6436983, -129.5522776, -107.7850473, -86.0160875, -64.2391635, -42.4485820, -20.6581018, 1.1163358, 22.8816941, 44.6407084, 66.3951340, 88.1461033, 109.8944346, 131.6407697, -129.5228975, -107.7571060, -85.9908718, -64.2180544, -42.4318577, -20.6461117, 1.1248352, 22.8880399, 44.6456970, 66.3992262, 88.1496227, 109.8975872, 131.6436983, -129.4380610, -107.6766464, -85.9170192, -64.1539984, -42.3833552, -20.6131992, 1.1486493, 22.9061137, 44.6600084, 66.4110654, 88.1598391, 109.9067765, 131.6522570, -129.3289404, -107.5737558, -85.8220981, -64.0707314, -42.3186005, -20.5667916, 1.1835518, 22.9332740, 44.6819101, 66.4293972, 88.1758067, 109.9212277, 131.6657750, -129.2273502, -107.4781907, -85.7341962, -63.9933690, -42.2540554, -20.5151931, 1.2243465, 22.9660906, 44.7089785, 66.4524311, 88.1961053, 109.9397699, 131.6832403, -129.1387879, -107.3942879, -85.6564616, -63.9236552, -42.1937160, -20.4644155, 1.2664902, 23.0011716, 44.7386435, 66.4781251, 88.2190483, 109.9609549, 131.7033949, -129.0644749, -107.3230314, -85.5896761, -63.8627917, -42.1396865, -20.4174535, 1.3068138, 23.0357471, 44.7685549, 66.5044783, 88.2428689, 109.9831910, 131.7247767]
d_w = 0
w_mx = 0
for q = 1:n_j
  d_w = max(d_w, abs(w_f(q) - w_S(q)))
  w_mx = max(w_mx, abs(w_S(q)))
end
#show
Δ_c2 = 100·d_w/w_mx 'peor nudo, LISP frente a Struct, en % de la flecha máxima

#hide
S_ct = 0
for q = 1:n_j
  S_ct = S_ct + (1 - sign(w_S(q)))/2
end
r_Sct = S_ct
S_pmax = round(-k_s·min(w_S)/1000, 2)
S_wmax = round(max(w_S), 3)
#show
#hide
x_0 = l_x/2
for i = 1:n_x
  q = (n_x/2)·n_n + i
  if w_S(q) < 0 && w_S(q + 1) >= 0
    x_0 = X_j(q) + h_e·w_S(q)/(w_S(q) - w_S(q + 1))
  end
end
#show

S_a = round(x_0 + l_x/2, 4) 'largo en contacto de Struct sobre y = 0 [m]

## 12 · Resumen: Hekatan LISP (FEM) · Hekatan Struct · GEO5 / analítico

#hide
g_b = 0.386
g_s = 6545.84
g_Rd = 2698.37
g_FS = 0.41
r_p1 = round(p_1, 2)
r_a1 = round(a_1, 4)
r_A1 = round(A_1, 3)
r_w1 = round(w_1, 3)
r_pr = round(p_r, 2)
r_ar = round(a_r, 4)
r_aD = round(a_D, 4)
r_qD = round(q_D, 2)
r_d = round(Δ_c2, 6)
r_gA = round(g_b·l_y, 3)
#show
#| Magnitud | Hekatan LISP (FEM) | Hekatan Struct (FEM) | rígida (Das) | GEO5 (Meyerhof) |
#|---|---:|---:|---:|---:|
#| nudos en contacto (de 169) / resoluciones | @{n_1} / @{i_1} | @{r_Sct} / 4 | | |
#| largo en contacto sobre y = 0 [m] | @{r_a1} | @{S_a} | @{r_aD} (FEM, E × 10: @{r_ar}) | ancho efectivo @{g_b} |
#| área en contacto [m²] | @{r_A1} | | | @{r_gA} |
#| presión máxima [kPa] | @{r_p1} | @{S_pmax} | @{r_qD} (FEM, E × 10: @{r_pr}) | @{g_s} (uniforme) |
#| levantamiento del borde opuesto [mm] | @{r_w1} | @{S_wmax} | | |
#| peor nudo LISP − Struct [% del máx.] | @{r_d} | — | | |
#: **Por qué FEM y Meyerhof difieren.** Las tres respuestas tienen **la misma resultante** (V = 3033.7 kN a 0.407 m del centro) y reparten distinto:
#: · **Meyerhof (GEO5):** rectángulo uniforme de ancho B − 2e = 0.386 m centrado en la resultante. No es la presión real: es la convención para la **capacidad portante** (σ = 6546 kPa contra R_{d} = 2698 kPa → FS = 0.41).
#: · **Rígida (Das):** triángulo de largo 3(B/2 − e) = 0.58 m y pico 2V/(3·L·(B/2 − e)) ≈ 8730 kPa: el doble de la media, porque un triángulo tiene su máximo al doble de su promedio.
#: · **Placa sobre Winkler (FEM):** la zapata es casi rígida (ℓ = 1.26 m > 1.20 m), así que el FEM da el triángulo de Das, discretizado en nudos de 10 cm (−2.5 % en el pico; converge al afinar). Es la presión **de servicio**, la que sirve para armar la zapata.
#: La franja de Meyerhof es más estrecha que el triángulo (0.39 frente a 0.58 m) porque está hecha para que un bloque uniforme tenga la misma resultante, no para parecerse a la presión.

## 13 · NEC-SE-GC 2015

#: · **Tabla 6, §6.2 (p. 42):** FS ≥ 3.0 (CM + CV normal). GEO5 da FS = 0.41: **no cumple**, ni de lejos.
#: · **Tabla 5, §5.2 (p. 36-38):** e/B ≤ 1/6 (la tabla es de muros; usarla en zapatas es criterio nuestro). Aquí e/B = 0.339: fuera del núcleo central, que es justo lo que este FEM enseña: **la mitad de la zapata en el aire** y el borde levantado más de 13 cm. Un resultado así no se «diseña»: hay que cambiar el sistema. La solución es la **viga de amarre** (hoja 138).
e_B = abs(e_x)/l_x 'excentricidad relativa (NEC: ≤ 0.167)
