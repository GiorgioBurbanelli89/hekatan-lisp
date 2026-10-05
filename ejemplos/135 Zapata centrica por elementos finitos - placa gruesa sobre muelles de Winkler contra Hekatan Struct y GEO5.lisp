# Zapata céntrica por elementos finitos: placa gruesa sobre muelles de Winkler, contra Hekatan Struct y GEO5
#numerico

#: **Qué se calcula.** La zapata de 1.20 × 1.20 × 0.40 m del ejemplo oficial **Demo01.gpa** de GEO5 Spread Footing (hojas 104 y 105), ahora como lo hace un programa de estructuras: la zapata es una **placa** dividida en elementos finitos y el suelo, un colchón de **muelles** (Winkler). Sale la presión de contacto nudo a nudo, la flecha y el giro.
#: **Con qué.** La formulación de **Hekatan Struct**: su cáscara gruesa (el Shell-Thick de CSI) y su muelle de área repartido a nudos, solo a compresión. La hoja escribe el elemento entero y lo resuelve; después compara **nudo a nudo** con Struct corriendo el mismo modelo (mismo .heks, misma malla) y con GEO5 (analítico: Meyerhof y asiento edométrico).
#: Unidades: kN, m, kPa (= kN/m²), como GEO5; el módulo de balasto también en tonf/m³.

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

#: La resultante cae a e_{x} del centro (hoja 104: el momento M_{y} y la horizontal H_{x} por el canto); en y los dos términos se anulan:
e_x = (-M_y + H_x·t_z)/V_d 'excentricidad en x (GEO5: −0.021) [m]
e_y = (M_x + H_y·t_z)/V_d 'excentricidad en y [m]

## 2 · El módulo de balasto k_{s}: de dónde sale

#: **Winkler** cambia el suelo por un colchón de muelles independientes: la presión en un punto es proporcional a lo que baja ese punto, p = k_{s}·w (la recta y = m·x con pendiente m = k_{s}). GEO5 no usa muelles: calcula el asiento con el módulo edométrico, capa a capa (hoja 105). Por eso k_{s} **no es un dato del suelo**: hay que elegirlo.
#: **Criterio de estas hojas:** k_{s} se calibra con GEO5. Se pide que la zapata, con la carga 3 de servicio (N = 1500 kN, la del asiento), baje en promedio lo que dice GEO5: k_{s} = presión neta / asiento.
N_3 = 1500 'axial de la carga 3, la del asiento [kN]
q_n = (N_3 + G_z + Z_r)/(l_x·l_y) - γ_1·d_f 'presión neta de la carga 3 (hoja 105) [kPa]
s_G = 0.0159 'asiento de GEO5 con la carga 3 [m]
k_s = q_n/s_G 'módulo de balasto [kN/m3]
k_t = k_s/9.80665 'el mismo en tonf/m3
#: Unos 6 700 tonf/m³ (6.7 kgf/cm³): un valor de arena densa / grava, coherente con el suelo 1 (φ = 31.5°) sobre una capa muy rígida (E_{def} = 1000 MPa) a 3 m. Con este criterio el asiento **medio** coincide con GEO5 por construcción; lo que el elemento finito añade es **cómo se reparte** la presión y el giro. La sensibilidad a k_{s} se mide al final.


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


## 4 · El elemento: la placa gruesa de Hekatan Struct

#: Hekatan Struct modela la zapata con su **cáscara gruesa** (`shelltype thick`), que es el **Shell-Thick de CSI** (ETABS, SAP2000, SAFE) sacado del binario y comprobado a 1e-12 % contra la rigidez de ETABS (código: `getBendingK_CSI` en `hekatan-fem/src/cpp/utils/shellQ4.cpp`). Aquí se escribe **el mismo elemento**, paso a paso. Placa de Mindlin-Reissner: la flecha w y los giros θ_{x}, θ_{y} son independientes (entra la deformación por cortante, que en una zapata de 40 cm sobre 1.2 m no es despreciable).
#: **Grados de libertad.** 3 por nudo, [w, θ_{x}, θ_{y}], giros a mano derecha. Además **10 internos** que se condensan: los giros se interpolan con 9 funciones (4 bilineales de nudo, 4 «de lado» que valen cero en las esquinas y 1 burbuja), cada una con dos componentes: 12 + 8 + 2 = 22.
a_e = h_e 'lado del elemento en x [m]
b_e = h_e 'lado del elemento en y [m]
D_0 = E_c·t_z^3/(12·(1 - ν^2)) 'rigidez a flexión de la placa [kN·m]
D_b = D_0·[1, ν, 0; ν, 1, 0; 0, 0, (1 - ν)/2] 'flexión: momentos ↔ curvaturas [kN·m]
D_s = 5/6·E_c·t_z/(2·(1 + ν))·eye(2) 'cortante: Q ↔ γ, con κ = 5/6 [kN/m]
D_tr = trace(D_b) 'suma de la diagonal de D_b, para la penalización [kN·m]
P_n = 1000 'factor de penalización de CSI (del binario)

#: **Las 9 funciones de los giros** en coordenadas naturales r, s (entre −1 y 1). Sus derivadas respecto de r y de s, en este orden: N₁…N₄ bilineales, N₅…N₈ de lado (N₅ = (1 − r²)(1 − s)/2 …) y N₉ = (1 − r²)(1 − s²), la burbuja:
d_r(r, s) = [-(1 - s)/4, (1 - s)/4, (1 + s)/4, -(1 + s)/4, -r·(1 - s), (1 - s^2)/2, -r·(1 + s), -(1 - s^2)/2, -2·r·(1 - s^2)]
d_s(r, s) = [-(1 - r)/4, -(1 + r)/4, (1 + r)/4, (1 - r)/4, -(1 - r^2)/2, -s·(1 + r), (1 - r^2)/2, -s·(1 - r), -2·s·(1 - r^2)]
#: Cada función mueve dos columnas de los 22 gdl: la del giro θ_{x} y la del θ_{y}. P_{x} y P_{y} (9 × 22) dicen cuál: función 1 → columnas 2 y 3 (θ_{x1}, θ_{y1}), … función 5 → internas 13 y 14, … burbuja → 21 y 22.
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
#: **Curvaturas** (regla de la cadena en un rectángulo: ∂/∂x = (2/a)·∂/∂r, ∂/∂y = (2/b)·∂/∂s). Con giros a mano derecha: κ_{x} = ∂θ_{y}/∂x, κ_{y} = −∂θ_{x}/∂y, 2κ_{xy} = ∂θ_{y}/∂y − ∂θ_{x}/∂x. La matriz B_{b} (3 × 22):
B_b(r, s) = [2/a_e·transpose(d_r(r, s))·P_y; -2/b_e·transpose(d_s(r, s))·P_x; 2/b_e·transpose(d_s(r, s))·P_y - 2/a_e·transpose(d_r(r, s))·P_x]
#: **Divergencia de los giros** ∂θ_{x}/∂x + ∂θ_{y}/∂y: CSI la penaliza con 1000·tr(D_{b}) (está en el binario; sin ella la K no es la de ETABS):
v_d(r, s) = 2/a_e·transpose(d_r(r, s))·P_x + 2/b_e·transpose(d_s(r, s))·P_y
#: **Cortante: los 4 cortantes de lado** (Wilson, cap. 8, ec. 8.7). En cada lado, γ = pendiente de la flecha + giro medio + 2/3 del modo de lado. Lado 1 (abajo, de 1 a 2), lado 2 (derecha), lado 3 (arriba, de 3 a 4) y lado 4 (izquierda), como filas sobre los 22 gdl:
l_1 = [-1/a_e, 0, 1/2, 1/a_e, 0, 1/2, 0, 0, 0, 0, 0, 0, 0, 2/3, 0, 0, 0, 0, 0, 0, 0, 0]
l_2 = [0, 0, 0, -1/b_e, -1/2, 0, 1/b_e, -1/2, 0, 0, 0, 0, 0, 0, -2/3, 0, 0, 0, 0, 0, 0, 0]
l_3 = [0, 0, 0, 0, 0, 0, -1/a_e, 0, -1/2, 1/a_e, 0, -1/2, 0, 0, 0, 0, 0, -2/3, 0, 0, 0, 0]
l_4 = [1/b_e, 1/2, 0, 0, 0, 0, 0, 0, 0, -1/b_e, 1/2, 0, 0, 0, 0, 0, 0, 0, 2/3, 0, 0, 0]
#: Se pasan a componentes covariantes (por medio lado) y se interpolan como en MITC: un término constante y uno lineal, con la parte lineal **simetrizada** (la misma m en las dos direcciones):
g_b = a_e/2·l_1 'lado de abajo
g_t = -a_e/2·l_3 'lado de arriba
g_R = b_e/2·l_2 'lado derecho
g_L = -b_e/2·l_4 'lado izquierdo
A_0 = (g_b + g_t)/2 'parte constante de γ_xz
C_0 = (g_L + g_R)/2 'parte constante de γ_yz
m_m = ((g_t - g_b)/2 + (g_R - g_L)/2)/2 'parte lineal simetrizada
B_s(r, s) = [2/a_e·transpose(A_0 + s·m_m); 2/b_e·transpose(C_0 + r·m_m)]
#: **Cuadratura de 8 puntos** (Irons, la de ITW 1991): 4 cerca de las esquinas con peso 9/49 y 4 sobre los ejes con peso 40/49:
q_A = sqrt(7/9) 'coordenada de los puntos de esquina
q_B = sqrt(7/15) 'coordenada de los puntos de eje
r_g = [-q_A, q_A, q_A, -q_A, 0, q_B, 0, -q_B] 'r de los 8 puntos
s_g = [-q_A, -q_A, q_A, q_A, -q_B, 0, q_B, 0] 's de los 8 puntos
w_g = [9/49, 9/49, 9/49, 9/49, 40/49, 40/49, 40/49, 40/49] 'pesos
j_d = a_e·b_e/4 'jacobiano del rectángulo [m2]
#: **B-barra.** A las 10 columnas internas de B_{b} se les resta su media sobre el elemento: así los modos internos no cambian la curvatura media y el elemento pasa la prueba de la parcela.
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
#show
#: **Rigidez de 22 × 22**: flexión + cortante + penalización, sumadas en los 8 puntos:
#: K_{22} = Σ w_{p}·|J|·( B̄_{b}ᵀ·D_{b}·B̄_{b} + B_{s}ᵀ·D_{s}·B_{s} + 1000·tr(D_{b})·vᵀ·v )
#hide
K_22 = zeros(22, 22)
#show
for p = 1:8
  B_1 = B_b(r_g(p), s_g(p)) - M_b·Q_i
  B_2 = B_s(r_g(p), s_g(p))
  v_1 = v_d(r_g(p), s_g(p))
  K_22 = K_22 + w_g(p)·j_d·(transpose(B_1)·D_b·B_1 + transpose(B_2)·D_s·B_2 + P_n·D_tr·transpose(v_1)·v_1)
end
#: **Condensación estática** de los 10 internos (no se conectan con nadie: se eliminan dentro del elemento). Con u_{i} = −K_{ii}⁻¹·K_{ib}·u_{b}:
#: K_{e} = K_{bb} − K_{bi}·K_{ii}⁻¹·K_{ib}
#hide
K_e = K_22(1:12, 1:12) - K_22(1:12, 13:22)·inv(K_22(13:22, 13:22))·K_22(13:22, 1:12)
#show
#: La K del elemento en MN/m (filas y columnas [w₁, θ_{x1}, θ_{y1}, w₂, θ_{x2}, θ_{y2} | w₃ … θ_{y4}]), en bloques de 6 × 6:
K_11 = round(K_e(1:6, 1:6)/1000·10)/10 'bloque nudos 1-2 con nudos 1-2 [MN/m]
K_12 = round(K_e(1:6, 7:12)/1000·10)/10 'bloque nudos 1-2 con nudos 3-4 [MN/m]
K_21 = round(K_e(7:12, 1:6)/1000·10)/10 'bloque nudos 3-4 con nudos 1-2 [MN/m]
K_22b = round(K_e(7:12, 7:12)/1000·10)/10 'bloque nudos 3-4 con nudos 3-4 [MN/m]
#: Comprobación contra la matriz de Hekatan Struct (`csiThickBendingK`, el mismo elemento): K_{e}(1,1) = 2 735 178.7 kN/m y K_{e}(2,3) = 9 080 283.9 kN·m/rad.
K_S11 = 2735178.7 'K(1,1) de Struct [kN/m]
dK_11 = round(100·(K_e(1, 1)/K_S11 - 1), 6) 'diferencia [%]
#: El término grande que acopla θ_{x} con θ_{y} (9 080 284) es la penalización de la divergencia: es de CSI, no un error.


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
x_c = 0 'eje de la columna en x [m]
y_c = 0 'eje de la columna en y [m]
#: El momento que llega al fondo, con el signo de la mano derecha (una fuerza hacia abajo V en (e_{x}, e_{y}) equivale a V en el centro más M_{Y} = e_{x}·V y M_{X} = −e_{y}·V):
M_Xn = -e_y·V_d 'momento alrededor de x en el nudo de la columna [kN·m]
M_Yn = e_x·V_d 'momento alrededor de y en el nudo de la columna [kN·m]
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


## 8 · Solución con el suelo solo a compresión

#: El conjunto activo: a_{c}(q) = 1 si el nudo q toca el suelo. Se empieza con todos y se repite hasta que no cambie:
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

n_it 'resoluciones hasta que el contacto no cambia
n_ct = sum(a_c) 'nudos en contacto (de 169)
#: Con la resultante a 2 cm del centro (dentro del tercio central, e/B = 0.018 < 1/6) **todos los nudos bajan**: el suelo trabaja entero a compresión y basta una resolución. Es el caso lineal.

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


## 9 · Presión de contacto y flecha

p_max = max(p_j) 'presión máxima (borde x = −0.6) [kPa]
p_min = min(p_j) 'presión mínima (borde x = +0.6) [kPa]
n_m = n_x/2·n_n + n_x/2 + 1 'nudo del centro
p_cen = p_j(n_m) 'presión bajo el centro [kPa]
w_cen = w_j(n_m) 'flecha del centro [mm]
w_min = min(w_j) 'flecha mayor (hacia abajo) [mm]
R_s = sum(R_j) 'suma de las reacciones del suelo = V [kN]
x_R = sum(R_j.*X_j)/R_s 'abscisa de la resultante del suelo = e_x [m]
#: **Equilibrio:** la suma de los muelles da V = 3033.728 kN y su resultante cae en e_{x}: el modelo no pierde carga.
#: **Mapa de presión** (kPa) en la planta de la zapata; con el cursor se lee el valor:
p_xy(x, y) = spline(1 + (x + l_x/2)/h_e, 1 + (y + l_y/2)/h_e, P_m)
#map(p_xy(x, y), [-0.6 0.6], [-0.6 0.6])
#: **La presión en 3D** (altura: 1 m = 5000 kPa): la «mesa» de presiones, más alta del lado de x negativo, que es hacia donde cae la resultante. Se gira con el ratón:
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
#: **Deformada** (×10), pintada con la flecha en mm:
#modelo3d(X_d, e_j, e_f, w_j, v_f, U_3, 10)

## 10 · La solución analítica: zapata rígida

#: Si la zapata fuera infinitamente rígida, la presión sería un **plano** (Navier: N/A ± M/S). Con la resultante dentro del tercio central:
A_z = l_x·l_y 'área [m2]
S_y = l_y·l_x^2/6 'módulo resistente de la planta [m3]
p_Rmax = V_d/A_z + V_d·abs(e_x)/S_y 'presión máxima, rígida [kPa]
p_Rmin = V_d/A_z - V_d·abs(e_x)/S_y 'presión mínima, rígida [kPa]
#: **¿Es rígida esta zapata?** La longitud elástica de la placa sobre Winkler, ℓ = (D/k_{s})^{1/4}, se compara con el lado: si ℓ es del orden del lado o mayor, la placa se comporta casi rígida.
l_el = (D_0/k_s)^(1/4) 'longitud elástica [m]
#: ℓ ≈ 1.26 m > 1.20 m: casi rígida, pero no del todo. Por eso el elemento finito da casi el plano de Navier: la placa se arquea un poco bajo la columna, el centro empuja algo más (2122 kPa frente a los 2107 de Navier) y los bordes algo menos.
dp_max = 100·(p_max/p_Rmax - 1) 'FEM frente a la rígida, presión máxima [%]

## 11 · Asiento y giro: carga 3 y carga 4 de servicio (hoja 105)

#: Para el asiento GEO5 usa la presión **neta** (descontando el suelo excavado, σ = γ₁·d_{f}). Carga 3: N = 1500 kN y H_{x} = 100 kN (momento H·t = 40 kN·m). Carga 4: N = 700 kN y M_{x} = 100 kN·m. Mismo modelo, otras cargas; la K no cambia:
q_n4 = (700 + G_z + Z_r)/(l_x·l_y) - γ_1·d_f 'presión neta de la carga 4 [kPa]
#hide
F_3 = zeros(n_g, 1)
F_4 = zeros(n_g, 1)
for e = 1:n_e
  for c = 1:4
    q = e_j(e, c)
    F_3(3·q - 2) = F_3(3·q - 2) - q_n·a_e·b_e/4
    F_4(3·q - 2) = F_4(3·q - 2) - q_n4·a_e·b_e/4
  end
end
F_3(3·n_c) = F_3(3·n_c) + 40
F_4(3·n_c - 1) = F_4(3·n_c - 1) - 100
U_3c = clsolve(K_t, F_3)
U_4c = clsolve(K_t, F_4)
w_3 = zeros(n_j, 1)
w_4 = zeros(n_j, 1)
for q = 1:n_j
  w_3(q) = 1000·U_3c(3·q - 2)
  w_4(q) = 1000·U_4c(3·q - 2)
end
#show
s_med = -sum(w_3.*k_n)/sum(k_n) 'asiento medio, carga 3 (= 15.9 por el criterio de k_s) [mm]
s_cen = -w_3(n_m) 'asiento del centro, carga 3 [mm]
s_xp = -w_3(n_m + n_x/2) 'centro del borde x = +0.6, carga 3 [mm]
s_xm = -w_3(n_m - n_x/2) 'centro del borde x = −0.6, carga 3 [mm]
θ_x = (s_xp - s_xm)/l_x 'giro en x, carga 3 [‰]
s_yp = -w_4(n_m + (n_x/2)·n_n) 'centro del borde y = +0.6, el más cargado con la carga 4 [mm]
s_ym = -w_4(n_m - (n_x/2)·n_n) 'centro del borde y = −0.6, carga 4 [mm]
θ_y = (s_yp - s_ym)/l_y 'giro en y, carga 4 [‰]
#: **Winkler frente al semiespacio de GEO5.** El asiento medio coincide (es el criterio), pero la **forma** no: GEO5 da el centro a 23.1 mm y los bordes a 12-14 mm (la zapata en el suelo elástico se hunde como un plato), y aquí, con la placa casi rígida, centro y bordes bajan casi lo mismo. Los muelles de Winkler no se hablan entre sí: no hay «plato». Y el giro sale **el doble** que el de GEO5 (≈ 3.5 ‰ frente a 1.6 ‰): en Winkler la rigidez al giro es k_{s}·I = k_{s}·l⁴/12, que con el k_{s} calibrado para el asiento es más baja que la del semiespacio. Con un solo k_{s} no se pueden clavar a la vez el asiento y el giro de GEO5.
θ_W = 40/(k_s·l_y·l_x^3/12)·1000 'giro de una zapata rígida sobre Winkler, carga 3 [‰]

## 12 · Sensibilidad a k_{s}

#: El k_{s} es un criterio, no un dato: se repite la carga 1 con la mitad y con el doble.
#hide
K_h = K
K_2 = K
for q = 1:n_j
  K_h(3·q - 2, 3·q - 2) = K_h(3·q - 2, 3·q - 2) + 0.5·k_n(q)
  K_2(3·q - 2, 3·q - 2) = K_2(3·q - 2, 3·q - 2) + 2·k_n(q)
end
U_h = clsolve(K_h, F)
U_2 = clsolve(K_2, F)
p_h = zeros(n_j, 1)
p_2 = zeros(n_j, 1)
for q = 1:n_j
  p_h(q) = -0.5·k_s·U_h(3·q - 2)
  p_2(q) = -2·k_s·U_2(3·q - 2)
end
p_hmax = max(p_h)
p_2max = max(p_2)
w_hmax = 0
w_2max = 0
for q = 1:n_j
  w_hmax = max(w_hmax, -1000·U_h(3·q - 2))
  w_2max = max(w_2max, -1000·U_2(3·q - 2))
end
w_1max = -min(w_j)
r_p1 = round(p_max, 1)
r_ph = round(p_hmax, 1)
r_p2 = round(p_2max, 1)
r_w1 = round(w_1max, 2)
r_wh = round(w_hmax, 2)
r_w2 = round(w_2max, 2)
#show
#| k_{s} | presión máxima [kPa] | flecha máxima [mm] |
#|---|---:|---:|
#| k_{s}/2 = 32 833 kN/m³ | @{r_ph} | @{r_wh} |
#| **k_{s} = 65 666 kN/m³** | **@{r_p1}** | **@{r_w1}** |
#| 2·k_{s} = 131 332 kN/m³ | @{r_p2} | @{r_w2} |
#: **Lectura:** la flecha va casi como 1/k_{s} (es el colchón el que se comprime), pero la presión apenas cambia: con la zapata casi rígida, la presión la fija el **equilibrio** (V y M), no el suelo. Por eso en una zapata céntrica el k_{s} importa para el asiento y poco para el diseño a flexión.

## 13 · Hekatan LISP contra Hekatan Struct, nudo a nudo

#: Struct corrió el **mismo modelo** (archivo `tests/zapata_fem/c0.heks`: 169 nudos, 144 cáscaras `thick`, `areaspring … nodal compresion`), con su código sin tocar (rama `zapata-levantamiento`). Sus 169 flechas (mm) están guardadas aquí; se comparan con las de esta hoja:
#hide
w_S1 = [-35.2320418, -34.7042496, -34.1775678, -33.6492329, -33.1158240, -32.5739234, -32.0209972, -31.4561417, -30.8803284, -30.2960428, -29.7065146, -29.1148424, -28.5234693, -35.2650876, -34.7381083, -34.2128477, -33.6863768, -33.1548069, -32.6141575, -32.0614112, -31.4955307, -30.9177652, -30.3311380, -29.7394620, -29.1462328, -28.5540044, -35.2988503, -34.7733612, -34.2509824, -33.7285366, -33.2013165, -32.6638979, -32.1120299, -31.5442301, -30.9623979, -30.3709883, -29.7750783, -29.1789485, -28.5852320, -35.3306613, -34.8072244, -34.2890277, -33.7732821, -33.2539702, -32.7229692, -32.1731225, -31.6018594, -31.0127537, -30.4130303, -29.8104972, -29.2102904, -28.6146144, -35.3571500, -34.8358659, -34.3223483, -33.8148658, -33.3099950, -32.7914018, -32.2443608, -31.6684015, -31.0657822, -30.4518581, -29.8413660, -29.2367062, -28.6390024, -35.3748152, -34.8551984, -34.3454604, -33.8449954, -33.3534125, -32.8469323, -32.3016147, -31.7206872, -31.1063908, -30.4798332, -29.8626676, -29.2544897, -28.6552500, -35.3810412, -34.8620511, -34.3537438, -33.8561572, -33.3683808, -32.8658582, -32.3208174, -31.7373712, -31.1203409, -30.4900878, -29.8703159, -29.2607713, -28.6609531, -35.3748152, -34.8551984, -34.3454604, -33.8449954, -33.3534125, -32.8469323, -32.3016147, -31.7206872, -31.1063908, -30.4798332, -29.8626676, -29.2544897, -28.6552500, -35.3571500, -34.8358659, -34.3223483, -33.8148658, -33.3099950, -32.7914018, -32.2443608, -31.6684015, -31.0657822, -30.4518581, -29.8413660, -29.2367062, -28.6390024, -35.3306613, -34.8072244, -34.2890277, -33.7732821, -33.2539702, -32.7229692, -32.1731225, -31.6018594, -31.0127537, -30.4130303, -29.8104972, -29.2102904, -28.6146144, -35.2988503, -34.7733612, -34.2509824, -33.7285366, -33.2013165, -32.6638979, -32.1120299, -31.5442301, -30.9623979, -30.3709883, -29.7750783, -29.1789485, -28.5852320, -35.2650876, -34.7381083, -34.2128477, -33.6863768, -33.1548069, -32.6141575, -32.0614112, -31.4955307, -30.9177652, -30.3311380, -29.7394620, -29.1462328, -28.5540044, -35.2320418, -34.7042496, -34.1775678, -33.6492329, -33.1158240, -32.5739234, -32.0209972, -31.4561417, -30.8803284, -30.2960428, -29.7065146, -29.1148424, -28.5234693]
d_w = 0
w_mx = 0
for q = 1:n_j
  d_w = max(d_w, abs(w_j(q) - w_S1(q)))
  w_mx = max(w_mx, abs(w_S1(q)))
end
#show
Δ_c1 = 100·d_w/w_mx 'peor nudo, LISP frente a Struct, en % de la flecha máxima

#hide
w_S3 = [-13.8165924, -14.1641592, -14.5114742, -14.8586366, -15.2057467, -15.5528628, -15.9000000, -16.2471372, -16.5942533, -16.9413634, -17.2885259, -17.6358408, -17.9834076, -13.8158127, -14.1633927, -14.5107498, -14.8580004, -15.2052666, -15.5526004, -15.9000000, -16.2473996, -16.5947334, -16.9419996, -17.2892502, -17.6366073, -17.9841873, -13.8150254, -14.1626047, -14.5099677, -14.8572831, -15.2046837, -15.5522771, -15.9000000, -16.2477229, -16.5953163, -16.9427169, -17.2900323, -17.6373953, -17.9849746, -13.8142712, -14.1618217, -14.5091520, -14.8564436, -15.2039700, -15.5518292, -15.9000000, -16.2481708, -16.5960300, -16.9435565, -17.2908480, -17.6381783, -17.9857289, -13.8136188, -14.1611305, -14.5083906, -14.8555877, -15.2030395, -15.5512421, -15.9000000, -16.2487579, -16.5969605, -16.9444123, -17.2916094, -17.6388695, -17.9863812, -13.8131785, -14.1606495, -14.5078283, -14.8549186, -15.2021672, -15.5502344, -15.9000000, -16.2497656, -16.5978328, -16.9450814, -17.2921717, -17.6393505, -17.9868215, -13.8130161, -14.1604721, -14.5076311, -14.8546368, -15.2018510, -15.5495382, -15.9000000, -16.2504618, -16.5981491, -16.9453632, -17.2923689, -17.6395279, -17.9869839, -13.8131785, -14.1606495, -14.5078283, -14.8549186, -15.2021672, -15.5502344, -15.9000000, -16.2497656, -16.5978328, -16.9450814, -17.2921717, -17.6393505, -17.9868215, -13.8136188, -14.1611305, -14.5083906, -14.8555877, -15.2030395, -15.5512421, -15.9000000, -16.2487579, -16.5969605, -16.9444123, -17.2916094, -17.6388695, -17.9863812, -13.8142712, -14.1618217, -14.5091520, -14.8564436, -15.2039700, -15.5518292, -15.9000000, -16.2481708, -16.5960300, -16.9435565, -17.2908480, -17.6381783, -17.9857289, -13.8150254, -14.1626047, -14.5099677, -14.8572831, -15.2046837, -15.5522771, -15.9000000, -16.2477229, -16.5953163, -16.9427169, -17.2900323, -17.6373953, -17.9849746, -13.8158127, -14.1633927, -14.5107498, -14.8580004, -15.2052666, -15.5526004, -15.9000000, -16.2473996, -16.5947334, -16.9419996, -17.2892502, -17.6366073, -17.9841873, -13.8165924, -14.1641592, -14.5114742, -14.8586366, -15.2057467, -15.5528628, -15.9000000, -16.2471372, -16.5942533, -16.9413634, -17.2885259, -17.6358408, -17.9834076]
d_w = 0
w_mx = 0
for q = 1:n_j
  d_w = max(d_w, abs(w_3(q) - w_S3(q)))
  w_mx = max(w_mx, abs(w_S3(q)))
end
#show
Δ_c3 = 100·d_w/w_mx 'peor nudo, LISP frente a Struct, en % de la flecha máxima

#hide
w_S4 = [-2.2311540, -2.2292047, -2.2272365, -2.2253509, -2.2237200, -2.2226193, -2.2222134, -2.2226193, -2.2237200, -2.2253509, -2.2272365, -2.2292047, -2.2311540, -3.1000712, -3.0981548, -3.0961849, -3.0942274, -3.0924994, -3.0912968, -3.0908533, -3.0912968, -3.0924994, -3.0942274, -3.0961849, -3.0981548, -3.1000712, -3.9683585, -3.9665475, -3.9645923, -3.9625531, -3.9606496, -3.9592438, -3.9587508, -3.9592438, -3.9606496, -3.9625531, -3.9645923, -3.9665475, -3.9683585, -4.8362646, -4.8346740, -4.8328809, -4.8307819, -4.8286422, -4.8269695, -4.8262651, -4.8269695, -4.8286422, -4.8307819, -4.8328809, -4.8346740, -4.8362646, -5.7040398, -5.7028395, -5.7013822, -5.6995981, -5.6972718, -5.6950910, -5.6943005, -5.6950910, -5.6972718, -5.6995981, -5.7013822, -5.7028395, -5.7040398, -6.5718301, -6.5711740, -6.5703658, -6.5692462, -6.5677784, -6.5652592, -6.5635186, -6.5652592, -6.5677784, -6.5692462, -6.5703658, -6.5711740, -6.5718301, -7.4396731, -7.4396731, -7.4396731, -7.4396731, -7.4396731, -7.4396731, -7.4396731, -7.4396731, -7.4396731, -7.4396731, -7.4396731, -7.4396731, -7.4396731, -8.3075160, -8.3081721, -8.3089803, -8.3101000, -8.3115677, -8.3140870, -8.3158276, -8.3140870, -8.3115677, -8.3101000, -8.3089803, -8.3081721, -8.3075160, -9.1753063, -9.1765067, -9.1779639, -9.1797480, -9.1820743, -9.1842551, -9.1850457, -9.1842551, -9.1820743, -9.1797480, -9.1779639, -9.1765067, -9.1753063, -10.0430815, -10.0446721, -10.0464652, -10.0485642, -10.0507039, -10.0523767, -10.0530811, -10.0523767, -10.0507039, -10.0485642, -10.0464652, -10.0446721, -10.0430815, -10.9109877, -10.9127986, -10.9147539, -10.9167930, -10.9186966, -10.9201023, -10.9205954, -10.9201023, -10.9186966, -10.9167930, -10.9147539, -10.9127986, -10.9109877, -11.7792750, -11.7811913, -11.7831612, -11.7851187, -11.7868468, -11.7880494, -11.7884928, -11.7880494, -11.7868468, -11.7851187, -11.7831612, -11.7811913, -11.7792750, -12.6481921, -12.6501414, -12.6521097, -12.6539952, -12.6556262, -12.6567268, -12.6571328, -12.6567268, -12.6556262, -12.6539952, -12.6521097, -12.6501414, -12.6481921]
d_w = 0
w_mx = 0
for q = 1:n_j
  d_w = max(d_w, abs(w_4(q) - w_S4(q)))
  w_mx = max(w_mx, abs(w_S4(q)))
end
#show
Δ_c4 = 100·d_w/w_mx 'peor nudo, LISP frente a Struct, en % de la flecha máxima

#: Menos de una cienmilésima de % del máximo: es el **mismo elemento y el mismo modelo**; lo que queda es el redondeo de la aritmética (la penalización 1000·tr(D_{b}) hace la K mal condicionada) y de los datos guardados (7 decimales en mm).

## 14 · Resumen: Hekatan LISP (FEM) · Hekatan Struct · GEO5 (analítico)

#hide
g_s = 2184.03
g_Rd = 3594.35
g_FS = 1.65
g_as = 15.9
g_tx = 1.638
g_ty = 4.095
g_cen = 23.1
r_pmax = round(p_max, 2)
r_pmin = round(p_min, 2)
r_Rmax = round(p_Rmax, 2)
r_Rmin = round(p_Rmin, 2)
r_med = round(s_med, 2)
r_cen = round(s_cen, 2)
r_tx = round(θ_x, 3)
r_ty = round(θ_y, 3)
r_tW = round(θ_W, 3)
r_d1 = round(Δ_c1, 6)
r_d3 = round(Δ_c3, 6)
r_d4 = round(Δ_c4, 6)
S_pmax = round(-k_s·min(w_S1)/1000, 2)
S_pmin = round(-k_s·max(w_S1)/1000, 2)
S_med = round(-sum(w_S3.*k_n)/sum(k_n), 2)
S_cen = round(-w_S3(n_m), 2)
S_tx = round((w_S3(n_m - n_x/2) - w_S3(n_m + n_x/2))/l_x, 3)
S_ty = round((w_S4(n_m - (n_x/2)·n_n) - w_S4(n_m + (n_x/2)·n_n))/l_y, 3)
#show
#| Magnitud | Hekatan LISP (FEM) | Hekatan Struct (FEM) | GEO5 / analítico |
#|---|---:|---:|---:|
#| presión máxima, carga 1 [kPa] | @{r_pmax} | @{S_pmax} | rígida (Navier) @{r_Rmax} |
#| presión mínima, carga 1 [kPa] | @{r_pmin} | @{S_pmin} | rígida @{r_Rmin} |
#| presión de GEO5 (Meyerhof, uniforme en 1.158 × 1.2 m) [kPa] | | | @{g_s} |
#| asiento medio, carga 3 [mm] | @{r_med} | @{S_med} | @{g_as} (punto característico) |
#| asiento del centro, carga 3 [mm] | @{r_cen} | @{S_cen} | @{g_cen} |
#| giro en x, carga 3 [‰] | @{r_tx} | @{S_tx} | @{g_tx} (Winkler rígida: @{r_tW}) |
#| giro en y, carga 4 [‰] | @{r_ty} | @{S_ty} | @{g_ty} |
#| peor nudo LISP − Struct, cargas 1 / 3 / 4 [% del máx.] | @{r_d1} / @{r_d3} / @{r_d4} | — | |
#: **Por qué FEM y GEO5 no dan la misma presión.** GEO5 (como la EN 1997 y la NEC) no busca la presión real: usa la de **Meyerhof**, uniforme sobre un rectángulo efectivo B − 2e centrado en la resultante, que es un artificio para la **capacidad portante** (2184 kPa sobre 1.158 m). La placa sobre muelles da la presión de **servicio** (la que sirve para armar la zapata): un plano casi de Navier, entre 1883 y 2323 kPa. Las dos tienen la misma resultante (V en e_{x}); no se comparan punto a punto.

## 15 · NEC-SE-GC 2015

#: **Tabla 6, §6.2 (p. 42)**: FS ≥ 3.0 a capacidad portante (CM + CV normal). Con R_{d} = 3594.35 kPa de GEO5 (hoja 104) la presión admisible es R_{d}/3:
q_adm = 3594.35/3 'presión admisible NEC [kPa]
#: La presión máxima de contacto del FEM (≈ 2323 kPa) la duplica, y el FS de GEO5 (1.65) es menor que 3.0: **no cumple la NEC** (igual que en la hoja 104). **§6.3.4 (p. 43-44)**: asiento total admisible de una zapata aislada 20 cm; aquí ≈ 1.6 cm con la carga de servicio: cumple. **Tabla 7**: distorsión angular L/300 en pórticos de hormigón ≈ 3.3 ‰; el giro FEM de la carga 3 (≈ 3.5 ‰) lo roza, el de GEO5 (1.6 ‰) no. Con Winkler el giro sale del lado de la seguridad.
