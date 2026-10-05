# Zapata de lindero con viga de amarre por elementos finitos: momento de la viga, presión y FS, contra Hekatan Struct y GEO5
#numerico

#: **Qué se calcula.** La zapata de lindero de la hoja 136 (columna a 1 cm del borde) ahora **amarrada** a la columna interior con una viga. La hoja 106 lo explicó como una palanca rígida (FS de 0.41 a 1.53, con L_{v} = 5 m supuesto). Aquí lo hace el elemento finito: placa gruesa sobre muelles solo a compresión (hojas 135-136) + una **barra a flexión** unida al nudo de la columna.
#: **Modelo de la viga y de la zapata interior (supuestos, no vienen del Demo01):** viga de 0.40 × 0.90 m de hormigón C20/25, de la columna de lindero (x = −0.40) a la interior (x = 4.60, L_{v} = 5 m); la zapata interior es igual a la céntrica (1.20 × 1.20, misma carga 3033.7 kN) y se modela como un muelle vertical k_{s}·A con el giro libre. La viga trabaja como la de Struct: Timoshenko con área de cortante 5/6·A.

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

e_x = (-M_y + H_x·t_z + N_1·p_x)/V_d 'excentricidad sin viga (hoja 136) [m]
e_y = (M_x + H_y·t_z)/V_d 'excentricidad en y [m]

## 1b · La planta: zapata de lindero, viga de amarre y zapata interior

#: **Cómo se lee.** Planta a escala, en metros. A la izquierda, la **línea de lindero** (a trazos): la zapata de 1.20 × 1.20 m no puede salirse de ella, así que la columna de 0.40 m queda a 0.01 m del borde y la carga cae **excéntrica**. La **viga de amarre** (0.40 m de ancho, 0.90 m de canto) une esa columna con la interior, a 5.00 m (eje a eje), donde hay otra zapata de 1.20 × 1.20 m. La viga toma el momento de la excentricidad y lo lleva a la zapata interior como un par de fuerzas: por eso la zapata de lindero deja de girar y el suelo bajo ella se carga casi parejo (secciones 9 a 11).
#dibujo("Planta: zapata de lindero, viga de amarre de 0.40 × 0.90 m y zapata interior", ud = m, escala = auto, cotas = m, alto = 90)
#  linea(-0.6, -0.95, -0.6, 0.95, "eje")
#  texto(-0.55, 0.85, "lindero", 2.5, "i")
#  rect(-0.6, -0.6, 1.2, 1.2, "gruesa")
#  rect(4.0, -0.6, 1.2, 1.2, "gruesa")
#  rect(-0.4, -0.2, 5.0, 0.4, "media")
#  achurado(-0.4, -0.2, 5.0, 0.4, "concreto")
#  rect(-0.59, -0.2, 0.4, 0.4, "denso")
#  rect(4.4, -0.2, 0.4, 0.4, "denso")
#  texto(-0.4, -0.78, "columna de lindero", 2.4, "i")
#  texto(4.1, -0.78, "columna interior", 2.4, "i")
#  texto(1.6, 0.34, "viga de amarre", 2.5, "i")
#  cota(-0.6, 0.85, 0.6, 0.85, 0.08, "1.20")
#  cota(4.0, 0.85, 5.2, 0.85, 0.08, "1.20")
#  cota(-0.4, -0.95, 4.6, -0.95, -0.08, "5.00 entre ejes de columnas")
#  cota(2.6, -0.2, 2.6, 0.2, 0.08, "0.40")
#  cota(-0.6, 0.0, -0.19, 0.0, -0.45, "0.01 + 0.40")
#fin

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
n_g = 3·(n_j + 1) 'grados de libertad del modelo
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


## 8 · La viga de amarre y la zapata interior

b_v = 0.4 'ancho de la viga [m]
h_v = 0.9 'canto de la viga [m]
L_v = 5 'de la columna de lindero a la interior [m]
A_v = b_v·h_v 'área [m2]
I_v = b_v·h_v^3/12 'inercia a flexión vertical [m4]
J_v = 0.013845 'constante de torsión del rectángulo 0.40 × 0.90 [m4]
G_c = E_c/(2·(1 + ν)) 'módulo de cortante [kPa]
φ_v = 12·E_c·I_v/(G_c·5/6·A_v·L_v^2) 'parámetro de Timoshenko (cortante de la viga)
c_v = E_c·I_v/(L_v^3·(1 + φ_v)) 'factor común [kN/m]
#: **Rigidez de la viga** en los gdl [w, θ_{x}, θ_{y}] de sus dos nudos. A lo largo de x, la pendiente de la flecha es dw/dx = −θ_{y} (mano derecha): por eso los términos que cruzan w con θ_{y} cambian de signo respecto al libro. La torsión (G·J/L) va en θ_{x}:
K_f = c_v·[12, 0, -6·L_v, -12, 0, -6·L_v; 0, 0, 0, 0, 0, 0; -6·L_v, 0, (4 + φ_v)·L_v^2, 6·L_v, 0, (2 - φ_v)·L_v^2; -12, 0, 6·L_v, 12, 0, 6·L_v; 0, 0, 0, 0, 0, 0; -6·L_v, 0, (2 - φ_v)·L_v^2, 6·L_v, 0, (4 + φ_v)·L_v^2]
t_v = G_c·J_v/L_v 'rigidez a torsión [kN·m/rad]
K_T = t_v·[0, 0, 0, 0, 0, 0; 0, 1, 0, 0, -1, 0; 0, 0, 0, 0, 0, 0; 0, 0, 0, 0, 0, 0; 0, -1, 0, 0, 1, 0; 0, 0, 0, 0, 0, 0]
K_v = K_f + K_T 'rigidez de la viga [kN/m, kN·m/rad]
n_k = n_j + 1 'nudo de la columna interior
K_i = k_s·l_x·l_y 'muelle de la zapata interior [kN/m]
P_i = V_d 'carga de la columna interior + su peso [kN]
g_v = [3·n_c - 2, 3·n_c - 1, 3·n_c, 3·n_k - 2, 3·n_k - 1, 3·n_k] 'gdl de la viga
#: Se suman a la K de la placa: la viga en los gdl de sus dos nudos, el muelle de la zapata interior en su w, y la carga interior en F:
#hide
K(g_v, g_v) = K(g_v, g_v) + K_v
K(3·n_k - 2, 3·n_k - 2) = K(3·n_k - 2, 3·n_k - 2) + K_i
F(3·n_k - 2) = F(3·n_k - 2) - P_i
#show

## 9 · Solución: el conjunto activo

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
#hide
U_v = U
#show

n_it 'resoluciones
n_ct = sum(a_c) 'nudos en contacto (de 169)
#: **Con la viga no se levanta ningún nudo**: toda la zapata vuelve a apoyar (sin viga, hoja 136: 78 de 169).

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


## 10 · Lo que toma la viga

#hide
u_v = zeros(6, 1)
for i = 1:6
  u_v(i) = U(g_v(i))
end
#show
f_v = round(K_v·u_v·10)/10 'fuerzas en los extremos de la viga, f = K·u [kN, kN·m]
P_v = f_v(1) 'fuerza hacia abajo que la viga pone sobre la zapata de lindero [kN]
M_v = f_v(3) 'momento de la viga en la columna de lindero [kN·m]
#: La viga **empuja hacia abajo** la zapata de lindero con P_{v} (y tira hacia arriba de la interior con lo mismo) y le aplica un momento que la **endereza**: es la palanca. La palanca rígida de la hoja 106 da ΔP = N·e₀/(L_{v} − e₀):
Δ_P = N_1·abs(p_x)/(L_v - abs(p_x)) 'lo que la palanca rígida le pasa a la zapata de lindero [kN]
M_0 = N_1·abs(p_x) 'momento que crea la columna corrida, N·e₀ (hoja 106) [kN·m]
r_M = abs(M_v)/M_0 'fracción de N·e₀ que toma la viga
w_c = 1000·U(3·n_c - 2) 'asiento de la columna de lindero [mm]
w_k = 1000·U(3·n_k - 2) 'asiento de la columna interior [mm]
β_v = abs(w_c - w_k)/L_v 'distorsión angular entre columnas [‰]
θ_c = 1000·U(3·n_c) 'giro de la zapata de lindero alrededor de y [‰]
#: **Diagrama de momentos de la viga**: lineal, de M_{v} en la columna de lindero a 0 en la interior (giro libre allí, y la viga no lleva carga en el vano):
m_1 = -abs(M_v)/1000 'ordenada del dibujo (1 m = 1000 kN·m)
#dibujo("Viga de amarre: diagrama de momentos (1 m = 1000 kN·m)", ud = m, escala = auto, alto = 90)
#  linea(0, 0, 5, 0, "gruesa")
#  linea(0, m_1, 5, 0, "gruesa rojo")
#  linea(0, 0, 0, m_1, "media rojo")
#  texto(0.1, m_1 - 0.15, "M en la columna de lindero", 2.6, "i")
#  texto(5, 0.15, "columna interior (M = 0)", 2.6, "d")
#fin

## 11 · Presión de contacto y deformada

p_max = max(p_j) 'presión máxima [kPa]
p_min = min(p_j) 'presión mínima [kPa]
R_s = sum(R_j) 'reacción del suelo bajo la zapata de lindero [kN]
x_R = sum(R_j.*X_j)/R_s 'resultante del suelo desde el centro [m]
R_1 = N_1·L_v/(L_v - abs(p_x)) + G_z + Z_r 'palanca rígida de la hoja 106 [kN]
#: El FEM y la palanca rígida dan casi la **misma reacción** (la viga carga la zapata de lindero con más de lo que baja por su columna) y la resultante vuelve **cerca del centro**.
p_xy(x, y) = spline(1 + (x + l_x/2)/h_e, 1 + (y + l_y/2)/h_e, P_m)
#map(p_xy(x, y), [-0.6 0.6], [-0.6 0.6])
#hide
X_3 = zeros(n_j, 3)
X_d = zeros(n_j, 3)
U_3 = zeros(n_j, 3)
for q = 1:n_j
  X_3(q, 1) = X_j(q)
  X_3(q, 2) = Y_j(q)
  X_3(q, 3) = p_j(q)/5000
  X_d(q, 1) = X_j(q)
  X_d(q, 2) = Y_j(q)
  U_3(q, 3) = U(3·q - 2)
end
e_f = zeros(0, 2)
v_f = zeros(0, 2)
#show

#modelo3d(X_3, e_j, e_f, p_j, v_f)
#: **Deformada** (×10): la zapata ya no gira; baja casi entera:
#modelo3d(X_d, e_j, e_f, w_j, v_f, U_3, 10)

## 12 · Capacidad portante con viga (método de GEO5, hoja 106)

#: Con la resultante del FEM se aplica lo mismo que GEO5: ancho efectivo B − 2e, Brinch-Hansen con φ_{d} = 40.21° y γ₂ = 18.95 (dato de GEO5, hoja 104):
φ_d = 40.21 'φ homogeneizado, del informe de GEO5 [grados]
c_d = 5 'cohesión [kPa]
γ_2 = 18.95 'γ bajo el fondo, de GEO5 [kN/m3]
f_d = φ_d·pi/180 'en radianes
q_0 = γ_1·d_f 'sobrecarga al nivel del fondo [kPa]
N_q = tan(pi/4 + f_d/2)^2·exp(pi·tan(f_d)) 'factor de sobrecarga
N_cc = (N_q - 1)/tan(f_d) 'factor de cohesión
N_γ = 1.5·(N_q - 1)·tan(f_d) 'factor de peso propio
H_r = sqrt(H_x^2 + H_y^2) 'horizontal [kN]
b_v2 = l_x - 2·abs(x_R) 'ancho efectivo con la resultante del FEM [m]
σ_v = R_s/(b_v2·l_y) 'presión de Meyerhof [kPa]
R_dv = (c_d·N_cc·(1 + 0.2·b_v2/l_y)·(1 + 0.1·sqrt(d_f/b_v2)) + q_0·N_q·(1 + b_v2/l_y·sin(f_d))·(1 + 0.1·sqrt(d_f/b_v2·sin(2·f_d))) + b_v2/2·γ_2·N_γ·(1 - 0.3·b_v2/l_y))·(1 - H_r/R_s)^2 'capacidad portante [kPa]
FS_v = R_dv/σ_v 'factor de seguridad con viga (FEM)

## 13 · Sensibilidad: una viga más débil (0.30 × 0.60 m)

#hide
h_w = 0.6
b_w = 0.3
I_w = b_w·h_w^3/12
A_w = b_w·h_w
φ_w = 12·E_c·I_w/(G_c·5/6·A_w·L_v^2)
c_w = E_c·I_w/(L_v^3·(1 + φ_w))
K_w = c_w·[12, 0, -6·L_v, -12, 0, -6·L_v; 0, 0, 0, 0, 0, 0; -6·L_v, 0, (4 + φ_w)·L_v^2, 6·L_v, 0, (2 - φ_w)·L_v^2; -12, 0, 6·L_v, 12, 0, 6·L_v; 0, 0, 0, 0, 0, 0; -6·L_v, 0, (2 - φ_w)·L_v^2, 6·L_v, 0, (4 + φ_w)·L_v^2] + G_c·0.0037/L_v·[0, 0, 0, 0, 0, 0; 0, 1, 0, 0, -1, 0; 0, 0, 0, 0, 0, 0; 0, 0, 0, 0, 0, 0; 0, -1, 0, 0, 1, 0; 0, 0, 0, 0, 0, 0]
K_9 = K
K_9(g_v, g_v) = K_9(g_v, g_v) - K_v + K_w
#hide
a_c = ones(n_j, 1)
h_c = zeros(30, 1)
n_it = 0
#show
for i_t = 1:30
  K_t = K_9
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

u_w = zeros(6, 1)
for i = 1:6
  u_w(i) = U(g_v(i))
end
f_w = round(K_w·u_w·10)/10
R_w = 0
x_w = 0
for q = 1:n_j
  R_w = R_w + (-k_s·U(3·q - 2)·a_c(q))·k_n(q)/k_s
  x_w = x_w + (-k_s·U(3·q - 2)·a_c(q))·k_n(q)/k_s·X_j(q)
end
x_w = x_w/R_w
n_w = sum(a_c)
b_w2 = l_x - 2·abs(x_w)
R_dw = (c_d·N_cc·(1 + 0.2·b_w2/l_y)·(1 + 0.1·sqrt(d_f/b_w2)) + q_0·N_q·(1 + b_w2/l_y·sin(f_d))·(1 + 0.1·sqrt(d_f/b_w2·sin(2·f_d))) + b_w2/2·γ_2·N_γ·(1 - 0.3·b_w2/l_y))·(1 - H_r/R_w)^2
FS_w = R_dw/(R_w/(b_w2·l_y))
r_Mw = round(abs(f_w(3)), 1)
r_nw = n_w
r_xw = round(x_w, 4)
r_FSw = round(FS_w, 2)
#show
#| Viga | momento en la columna [kN·m] | nudos en contacto | resultante x_{R} [m] | FS (GEO5 con la x_{R} del FEM) |
#|---|---:|---:|---:|---:|
#| sin viga (hoja 136) | — | 78 | −0.4069 | 0.41 |
#| 0.30 × 0.60 m | @{r_Mw} | @{r_nw} | @{r_xw} | @{r_FSw} |
#| **0.40 × 0.90 m** | **@{r_Mv}** | **@{n_ct}** | **@{r_xR}** | **@{r_FSv}** |
#: Una viga más flexible deja girar algo la zapata: la resultante se aleja del centro y el FS baja. La viga **tiene que ser rígida** frente a la zapata (aquí 3EI/L ≫ k_{s}·I de la zapata).

## 14 · Hekatan LISP contra Hekatan Struct, nudo a nudo

#: Struct corrió el mismo modelo (`tests/zapata_fem/c4.heks`: 169 nudos de la placa + el de la columna interior, la barra `frame` 0.40 × 0.90 y el `spring` de la zapata interior). Sus 170 flechas (mm):
#hide
w_k1 = zeros(n_k, 1)
for q = 1:n_k
  w_k1(q) = 1000·U_v(3·q - 2)
end
#show
#hide
w_S = [-38.8723330, -38.2354182, -37.5824262, -36.9066979, -36.2043548, -35.4753646, -34.7220887, -33.9497439, -33.1637221, -32.3698856, -31.5726915, -30.7758677, -29.9817561, -38.8935004, -38.2614139, -37.6133021, -36.9413673, -36.2406929, -35.5110102, -34.7554152, -33.9798948, -33.1909044, -32.3944441, -31.5954167, -30.7973230, -30.0024971, -38.9228204, -38.2995815, -37.6592569, -36.9918004, -36.2916119, -35.5578342, -34.7964041, -34.0146298, -33.2203905, -32.4200075, -31.6181547, -30.8182823, -30.0223873, -38.9559954, -38.3470892, -37.7192584, -37.0590513, -36.3563673, -35.6143663, -34.8417694, -34.0507906, -33.2497036, -32.4443095, -31.6391967, -30.8371753, -30.0399698, -38.9905826, -38.4008876, -37.7923815, -37.1433088, -36.4342501, -35.6719936, -34.8846726, -34.0834522, -33.2749167, -32.4647454, -31.6563245, -30.8523407, -30.0539422, -39.0135729, -38.4296208, -37.8550713, -37.2306344, -36.5007368, -35.7162115, -34.9163796, -34.1061802, -33.2923268, -32.4783014, -31.6676568, -30.8621616, -30.0628643, -39.0179849, -38.4287962, -37.8959709, -37.2706847, -36.5242215, -35.7339302, -34.9276127, -34.1146767, -33.2983504, -32.4831903, -31.6715468, -30.8655936, -30.0660105, -39.0135729, -38.4296208, -37.8550713, -37.2306344, -36.5007368, -35.7162115, -34.9163796, -34.1061802, -33.2923268, -32.4783014, -31.6676568, -30.8621616, -30.0628643, -38.9905826, -38.4008876, -37.7923815, -37.1433088, -36.4342501, -35.6719936, -34.8846726, -34.0834522, -33.2749167, -32.4647454, -31.6563245, -30.8523407, -30.0539422, -38.9559954, -38.3470892, -37.7192584, -37.0590513, -36.3563673, -35.6143663, -34.8417694, -34.0507906, -33.2497036, -32.4443095, -31.6391967, -30.8371753, -30.0399698, -38.9228204, -38.2995815, -37.6592569, -36.9918003, -36.2916119, -35.5578342, -34.7964041, -34.0146298, -33.2203905, -32.4200075, -31.6181547, -30.8182823, -30.0223873, -38.8935004, -38.2614139, -37.6133021, -36.9413673, -36.2406929, -35.5110102, -34.7554152, -33.9798948, -33.1909044, -32.3944441, -31.5954167, -30.7973230, -30.0024971, -38.8723330, -38.2354182, -37.5824262, -36.9066979, -36.2043548, -35.4753646, -34.7220887, -33.9497439, -33.1637221, -32.3698856, -31.5726915, -30.7758677, -29.9817561, -29.4450936]
d_w = 0
w_mx = 0
for q = 1:n_k
  d_w = max(d_w, abs(w_k1(q) - w_S(q)))
  w_mx = max(w_mx, abs(w_S(q)))
end
#show
Δ_c4 = 100·d_w/w_mx 'peor nudo, LISP frente a Struct, en % de la flecha máxima


## 15 · Resumen: Hekatan LISP (FEM) · Hekatan Struct · GEO5 / analítico

#hide
S_pmax = round(-k_s·min(w_S(1:169))/1000, 2)
S_wc = round(w_S(n_c), 3)
S_wk = round(w_S(n_k), 3)
r_pmax = round(p_max, 2)
r_pmin = round(p_min, 2)
r_Rs = round(R_s, 1)
r_R1 = round(R_1, 1)
r_xR = round(x_R, 4)
r_Mv = round(abs(M_v), 1)
r_M0 = round(M_0, 0)
r_FSv = round(FS_v, 2)
r_wc = round(w_c, 3)
r_wk = round(w_k, 3)
r_bv = round(β_v, 3)
r_d = round(Δ_c4, 6)
#show
#| Magnitud | Hekatan LISP (FEM) | Hekatan Struct (FEM) | analítico (hoja 106) / GEO5 |
#|---|---:|---:|---:|
#| nudos en contacto (de 169) | @{n_ct} | 169 | sin viga: 78 |
#| reacción del suelo bajo la zapata de lindero [kN] | @{r_Rs} | | palanca rígida @{r_R1} |
#| resultante desde el centro [m] | @{r_xR} | | sin viga −0.4069 |
#| presión máxima / mínima [kPa] | @{r_pmax} / @{r_pmin} | @{S_pmax} | sin viga (GEO5) 6545.84 |
#| momento de la viga en la columna [kN·m] | @{r_Mv} | | N·e₀ = @{r_M0} |
#| asiento columna de lindero / interior [mm] | @{r_wc} / @{r_wk} | @{S_wc} / @{S_wk} | |
#| FS a capacidad portante | @{r_FSv} | | palanca rígida 1.53 · sin viga 0.41 |
#| peor nudo LISP − Struct [% del máx.] | @{r_d} | — | |
#: **Por qué el FEM y la palanca de la hoja 106 casi coinciden:** la viga de 0.90 m es mucho más rígida que el giro de la zapata sobre el suelo, así que se comporta como la palanca rígida del libro. El FEM añade lo que la palanca no da: la presión real (un trapecio casi uniforme, ya sin zona levantada), el momento con el que se arma la viga y lo que pasa si la viga es más débil (sección 13).

## 16 · NEC-SE-GC 2015

#: · **Tabla 6, §6.2 (p. 42):** FS ≥ 3.0. Con viga el FS sube a ≈ 1.5: mejora mucho, pero **sigue sin cumplir** (lo mismo que la céntrica, hoja 135): la zapata de 1.20 m es pequeña para 3000 kN. Hay que agrandarla además de amarrarla.
#: · **Tabla 7 (p. 44):** distorsión angular entre columnas ≤ L/300 (pórticos de hormigón):
β_lim = 1/300 'límite NEC
#: β = |w_{lindero} − w_{interior}|/L_{v}: @{r_bv} ‰ frente a 3.33 ‰. Cumple.
