# Mesa de torsión: losa DKQ sobre vigas y columnas, toda la operación
#numerico

#: El benchmark **Mesa de Torsión** de Hekatan Struct, resuelto aquí de principio a fin: losa de 6 × 6 m y 10 cm sobre 4 vigas perimetrales V30×50 y 4 columnas C40×40 de 4 m, con carga viva de 0.5 tonf/m². Es el mismo modelo del e2k de ETABS, nudo a nudo (malla 5 × 5, sin diafragma, base articulada).
#: **Elementos** (los de ETABS *Shell-Thin* y Hekatan Struct): losa = membrana **Q6** (modos incompatibles de Wilson) + flexión **DKQ** (Batoz, Kirchhoff discreto) + un giro en el plano muy blando; vigas y columnas = barra 3D de **Timoshenko**, 6 grados de libertad por nudo.
#: **Unidades:** kN y m al calcular; los resultados se pasan a tonf dividiendo por g = 9.80665.

## 1 · Datos
L_x = 6 'luz de la losa en x y en y (m)
H_c = 4 'altura de las columnas (m)
t = 0.1 'espesor de la losa (m)
E = 24.85e6 'módulo de elasticidad (kN/m²)
ν = 0.2 'coeficiente de Poisson
G_c = E/(2·(1 + ν)) 'módulo de corte (kN/m²)
q = 4.9033 'carga viva: 0.5 tonf/m² en kN/m²
g_0 = 9.80665 'kN por tonf
b_c = 0.4 'columna: ancho (m)
h_c = 0.4 'columna: peralte (m)
b_v = 0.3 'viga: ancho (m)
h_v = 0.5 'viga: peralte (m)
o_f = h_v 'brazo rígido en el tope de la columna: el momento se reporta en la cara de la viga (m)
#: **Secciones.** J con la fórmula de Saint-Venant para un rectángulo, con el CUBO del lado corto: J = β·a·b³, β = 1/3 − 0.21·(b/a)·(1 − (b/a)⁴/12).
A_c = b_c·h_c
I_yc = h_c·b_c^3/12
I_zc = b_c·h_c^3/12
J_c = stv(b_c, h_c)
A_v = b_v·h_v
I_yv = b_v·h_v^3/12 'inercia fuerte de la viga (flexión vertical)
I_zv = h_v·b_v^3/12
J_v = stv(b_v, h_v)

## 2 · Malla
#: 5 × 5 elementos de losa de 1.2 m (el automallado de ETABS a ≤ 1.25 m). Nudos: 4 en la base de las columnas y 36 en la losa, a la altura H.
n_e = 5 'elementos por lado
n_1 = n_e + 1 'nudos por lado
d = L_x/n_e 'lado del elemento (m)
n_j = 4 + n_1^2 'nudos
n_d = 6·n_j 'grados de libertad
#: El nudo de losa de la columna i y la fila j de la malla (i, j = 0 … 5):
p(i, j) = 5 + j·n_1 + i
#hide
X_n = zeros(n_j, 3)
X_n(2, 1) = L_x
X_n(3, 1) = L_x
X_n(3, 2) = L_x
X_n(4, 2) = L_x
for j = 0:n_e
  for i = 0:n_e
    X_n(p(i, j), 1) = i·d
    X_n(p(i, j), 2) = j·d
    X_n(p(i, j), 3) = H_c
  end
end
e_s = zeros(n_e^2, 4)
for j = 0:n_e - 1
  for i = 0:n_e - 1
    k = j·n_e + i + 1
    e_s(k, 1) = p(i, j)
    e_s(k, 2) = p(i + 1, j)
    e_s(k, 3) = p(i + 1, j + 1)
    e_s(k, 4) = p(i, j + 1)
  end
end
c_e = [1, p(0, 0); 2, p(n_e, 0); 3, p(n_e, n_e); 4, p(0, n_e)]
b_e = zeros(4·n_e, 2)
for i = 0:n_e - 1
  b_e(i + 1, 1) = p(i, 0)
  b_e(i + 1, 2) = p(i + 1, 0)
  b_e(n_e + i + 1, 1) = p(n_e, i)
  b_e(n_e + i + 1, 2) = p(n_e, i + 1)
  b_e(2·n_e + i + 1, 1) = p(i, n_e)
  b_e(2·n_e + i + 1, 2) = p(i + 1, n_e)
  b_e(3·n_e + i + 1, 1) = p(0, i)
  b_e(3·n_e + i + 1, 2) = p(0, i + 1)
end
x_j = zeros(n_1^2, 1)
y_j = zeros(n_1^2, 1)
for k = 1:n_1^2
  x_j(k) = X_n(k + 4, 1)
  y_j(k) = X_n(k + 4, 2)
end
e_j = e_s - 4
s_j = [1; n_1; n_1^2; n_1^2 - n_e]
#show
#: Planta de la losa: 25 elementos; las columnas están en las 4 esquinas y las vigas corren por el borde.
#malla(x_j, y_j, e_j, s_j)
n_s = n_e^2 'elementos de losa
n_c = 4 'columnas
n_b = 4·n_e 'tramos de viga (cada viga se parte en los nudos de la losa)

## 3 · Elemento de losa (24 × 24)
#: Cada nudo tiene 6 grados de libertad: u, v, w, θx, θy, θz. La losa es plana y sus ejes locales son los globales, así que su matriz no se gira.
a_e = d/2 'medio lado: ξ = x/a, η = y/a
#: **Membrana Q6** (Wilson, Taylor 1976): u = Σ Nᵢ·uᵢ + (1 − ξ²)·α₁ + (1 − η²)·α₂, y lo mismo para v. Los 4 modos α se condensan: K_{m} = K_{uu} − K_{uα}·K_{αα}⁻¹·K_{αu}. Sin ellos, la Q4 bilineal se traba en flexión en el plano.
K_m = memb_q6(E, ν, t, a_e)
#: **Flexión DKQ** (Batoz y Tahar 1982): la hipótesis de Kirchhoff se impone en puntos discretos del borde, y la matriz B de curvaturas queda explícita en ξ y η. Integración de Gauss 2 × 2, con det J = a_{e}².
D_b = E·t^3/(12·(1 - ν^2))·[1, ν, 0; ν, 1, 0; 0, 0, (1 - ν)/2]
K_b = dkq_K(D_b, d)
#: El DKQ usa β_x = θ_y y β_y = −θ_x; la matriz P = diag(1, −1, −1, …) pasa sus grados de libertad a (w, θx, θy) de la hoja.
#hide
P_d = zeros(12, 12)
for k = 1:4
  P_d(3·k - 2, 3·k - 2) = 1
  P_d(3·k - 1, 3·k - 1) = -1
  P_d(3·k, 3·k) = -1
end
#show
K_p = P_d·K_b·P_d
#: **Giro en el plano θz** (el «drilling» de Hekatan Struct): un muelle de 10⁻⁶ veces el promedio de la diagonal de la membrana, solo para que la matriz no sea singular.
#hide
s_m = 0
for k = 1:8
  s_m = s_m + K_m(k, k)
end
#show
k_θ = s_m/8·1e-6
#: Las tres piezas en la matriz del elemento, en el orden u, v, w, θx, θy, θz de cada nudo:
#hide
K_s = zeros(24, 24)
for a = 1:4
  for b = 1:4
    for r = 1:2
      for c = 1:2
        K_s(6·(a - 1) + r, 6·(b - 1) + c) = K_m(2·(a - 1) + r, 2·(b - 1) + c)
      end
    end
    for r = 1:3
      for c = 1:3
        K_s(6·(a - 1) + 2 + r, 6·(b - 1) + 2 + c) = K_p(3·(a - 1) + r, 3·(b - 1) + c)
      end
    end
  end
  K_s(6·a, 6·a) = k_θ
end
#show
K_s(3:5, 3:5) 'bloque de flexión del nudo 1 (w, θx, θy)

## 4 · Barras (12 × 12)
#: **Timoshenko 3D**: área de corte 5/6·A, φ = 12·E·I/(G·A_s·L²). Cuatro físicas que no se mezclan: axial E·A/L, torsión G·J/L y flexión en los dos planos de la barra.
#: **Ejes locales** (los de Hekatan Struct): x a lo largo de la barra; en una columna vertical, λ = [0 0 1; 0 1 0; −1 0 0]. La matriz global es Rotᵀ·k·Rot.
k_col = frame_K(E, G_c, A_c, I_yc, I_zc, J_c, H_c)
k_vig = frame_K(E, G_c, A_v, I_yv, I_zv, J_v, d)

## 5 · Ensamblaje, apoyos y solución
d_n(j) = 6·(j - 1) + (1:6)
#hide
K = zeros(n_d, n_d)
F = zeros(n_d, 1)
#show
#: Losa: los 25 elementos son iguales y no se giran; se suman en las filas y columnas de sus 4 nudos.
for e = 1:n_s
  g = [d_n(e_s(e, 1)), d_n(e_s(e, 2)), d_n(e_s(e, 3)), d_n(e_s(e, 4))]
  K(g, g) = K(g, g) + K_s
end
#: Columnas y vigas: se giran a ejes globales antes de sumarse.
for e = 1:n_c
  g = [d_n(c_e(e, 1)), d_n(c_e(e, 2))]
  R_f = rot_frame(X_n(c_e(e, 1), :), X_n(c_e(e, 2), :))
  K(g, g) = K(g, g) + R_f'·k_col·R_f
end
for e = 1:n_b
  g = [d_n(b_e(e, 1)), d_n(b_e(e, 2))]
  R_f = rot_frame(X_n(b_e(e, 1), :), X_n(b_e(e, 2), :))
  K(g, g) = K(g, g) + R_f'·k_vig·R_f
end
#: **Carga.** q por el área tributaria de cada nudo: d² en el interior, d²/2 en el borde y d²/4 en la esquina (como ETABS reparte la carga de área).
for j = 0:n_e
  for i = 0:n_e
    f_a = 1
    if i == 0 || i == n_e
      f_a = f_a/2
    end
    if j == 0 || j == n_e
      f_a = f_a/2
    end
    F(6·(p(i, j) - 1) + 3) = -q·d^2·f_a
  end
end
Q_t = q·L_x^2/g_0 'carga total (tonf)
#: **Apoyos.** Base de las columnas articulada (ETABS: RESTRAINT "UX UY UZ"): se quitan u, v, w de los nudos 1 a 4; sus giros quedan libres.
#hide
l_f = zeros(n_d - 12, 1)
k = 0
for i = 1:n_d
  if i > 24 || mod(i - 1, 6) >= 3
    k = k + 1
    l_f(k) = i
  end
end
U = zeros(n_d, 1)
#show
n_f = k 'ecuaciones libres
#: Cholesky sobre las ecuaciones libres:
U(l_f) = clsolve(K(l_f, l_f), F(l_f))

## 6 · Flecha de la losa
#hide
W_g = zeros(n_1, n_1)
for i = 0:n_e
  for j = 0:n_e
    W_g(i + 1, j + 1) = 1000·U(6·(p(i, j) - 1) + 3)
  end
end
#show
#: Flecha w de los nudos en mm (fila = y, columna = x):
transpose(W_g)
w_c = W_g(3, 3) 'flecha en el nudo central (mm)
#: Entre nudos se interpola con las funciones de forma BILINEALES del Q4 (un spline se pasaría de los valores de los nudos). Pasa el cursor sobre el mapa para leer w en cada punto:
w_z(x, y) = bil(W_g, x, y, d, n_e)
#map(w_z(x, y), [0 L_x], [0 L_x])

## 7 · Momentos de la losa (recovery DKQ)
#: En cada elemento: M = D_{b}·B(ξ, η)·u_{e} en los 4 puntos de Gauss (±1/√3), con la MISMA B del DKQ; luego se extrapola a los nudos con la matriz de √3. En cada nudo se guarda el valor de MAYOR |M| de los elementos que llegan (la envolvente, como la tabla element-joint de ETABS). Con el promedio de nudo Mxy saldría 0.170 en vez de 0.189.
s_3 = sqrt(3)
A_x = [1 + s_3/2, -0.5, 1 - s_3/2, -0.5; -0.5, 1 + s_3/2, -0.5, 1 - s_3/2; 1 - s_3/2, -0.5, 1 + s_3/2, -0.5; -0.5, 1 - s_3/2, -0.5, 1 + s_3/2]
#hide
ξ_g = [-1, 1, 1, -1]/s_3
η_g = [-1, -1, 1, 1]/s_3
M_xg = zeros(n_1, n_1)
M_yg = zeros(n_1, n_1)
M_sg = zeros(n_1, n_1)
o_i = [0, 1, 1, 0]
o_j = [0, 0, 1, 1]
for e = 1:n_s
  u_e = zeros(12, 1)
  for k = 1:4
    j_d = 6·(e_s(e, k) - 1)
    u_e(3·k - 2) = U(j_d + 3)
    u_e(3·k - 1) = U(j_d + 4)
    u_e(3·k) = U(j_d + 5)
  end
  u_d = P_d·u_e
  M_g = zeros(3, 4)
  for k = 1:4
    M_g(:, k) = D_b·dkq_B(ξ_g(k), η_g(k), d)·u_d
  end
  M_n = A_x·transpose(M_g)/g_0
  i_0 = mod(e - 1, n_e)
  j_0 = floor((e - 1)/n_e)
  for k = 1:4
    i_n = i_0 + o_i(k) + 1
    j_n = j_0 + o_j(k) + 1
    if abs(M_n(k, 1)) > abs(M_xg(i_n, j_n))
      M_xg(i_n, j_n) = M_n(k, 1)
    end
    if abs(M_n(k, 2)) > abs(M_yg(i_n, j_n))
      M_yg(i_n, j_n) = M_n(k, 2)
    end
    if abs(M_n(k, 3)) > abs(M_sg(i_n, j_n))
      M_sg(i_n, j_n) = M_n(k, 3)
    end
  end
end
#show
#: **Mxx** en tonf·m/m (fila = y, columna = x). Negativo en el borde: la viga la empotra a medias.
transpose(M_xg)
M_xx(x, y) = bil(M_xg, x, y, d, n_e)
#map(M_xx(x, y), [0 L_x], [0 L_x])
#: **Myy**: lo mismo girado 90° (la mesa es simétrica).
M_yy(x, y) = bil(M_yg, x, y, d, n_e)
#map(M_yy(x, y), [0 L_x], [0 L_x])
#: **Mxy**, la TORSIÓN de la losa: máxima cerca de las esquinas, donde la losa se alabea sobre las columnas. Es la que da nombre a la mesa.
transpose(M_sg)
M_xy(x, y) = bil(M_sg, x, y, d, n_e)
#map(M_xy(x, y), [0 L_x], [0 L_x])
M_11 = max(abs(M_xg)) 'max |Mxx| (tonf·m/m)
M_12 = max(abs(M_sg)) 'max |Mxy| (tonf·m/m)

## 8 · Fuerzas en columnas y vigas
#: En cada barra: f = k·Rot·u_{e} (ejes locales, orden P, V₂, V₃, T, M₂, M₃ en el nudo i y luego en el j), en tonf y tonf·m.
f_c = transpose(k_col·rot_frame(X_n(1, :), X_n(p(0, 0), :))·U([d_n(1), d_n(p(0, 0))]))/g_0
#: Columna de la esquina (0, 0). El momento en el nudo de arriba es 2.434, pero ETABS lo reporta en la CARA de la viga, medio metro más abajo: M_{cara} = M_{nudo} − V·o_{f}.
P_c = abs(f_c(1)) 'axial (tonf)
V_c = abs(f_c(8)) 'cortante (tonf)
M_cn = abs(f_c(12)) 'momento en el nudo (tonf·m)
M_cc = M_cn - V_c·o_f 'momento en la cara (tonf·m)
#: Los 5 tramos de la viga del borde y = 0 (una fila por tramo):
#hide
f_b = zeros(n_e, 12)
for e = 1:n_e
  g = [d_n(b_e(e, 1)), d_n(b_e(e, 2))]
  f_b(e, :) = transpose(k_vig·rot_frame(X_n(b_e(e, 1), :), X_n(b_e(e, 2), :))·U(g))/g_0
end
#show
f_b
P_v = abs(f_b(1, 1)) 'axial (tonf)
V_v = abs(f_b(1, 3)) 'cortante vertical en el apoyo (tonf)
T_v = abs(f_b(1, 4)) 'torsión: la losa hace girar a la viga (tonf·m)
M_v = abs(f_b(3, 5)) 'momento al centro de la luz (tonf·m)
#: **Equilibrio**: la suma de las 4 reacciones verticales de la base tiene que ser la carga total.
R_z = (K(3, :)·U + K(9, :)·U + K(15, :)·U + K(21, :)·U)/g_0 'suma de reacciones (tonf)

## 9 · Verificación
#: **Referencias.** ETABS 22 (mismo e2k) y el motor de Hekatan Struct en Python (hekatan-fem-py, mesa_hekatan.py con DKQ), mismo modelo nudo a nudo. El +2.6 % de w es de ETABS: rigidiza la viga en la zona de junta con la columna (0.40 m); aquí la viga va de nudo a nudo (6.0 m).
w_py = -6.670544 'Hekatan Struct (Python)
M_11py = 0.653683
M_12py = 0.189311
M_ccpy = 2.129719
P_cpy = 4.499977
V_cpy = 0.608491
V_vpy = 2.203397
T_vpy = 1.146536
M_vpy = 3.141190
P_vpy = 0.376362
d_w = round((w_c - w_py)/w_py·100, 4) '%
d_11 = round((M_11 - M_11py)/M_11py·100, 4) '%
d_12 = round((M_12 - M_12py)/M_12py·100, 4) '%
d_cc = round((M_cc - M_ccpy)/M_ccpy·100, 4) '%
d_pc = round((P_c - P_cpy)/P_cpy·100, 4) '%
d_vc = round((V_c - V_cpy)/V_cpy·100, 4) '%
d_vv = round((V_v - V_vpy)/V_vpy·100, 4) '%
d_tv = round((T_v - T_vpy)/T_vpy·100, 4) '%
d_mv = round((M_v - M_vpy)/M_vpy·100, 4) '%
d_pv = round((P_v - P_vpy)/P_vpy·100, 4) '%
d_r = round((R_z - Q_t)/Q_t·100, 4) '%
#| magnitud | ETABS | Hekatan Struct (Python) | Hekatan LISP | dif. con Python % |
#|---|--:|--:|--:|--:|
#| losa: w en el centro [mm] | −6.50 | @{w_py} | @{w_c} | @{d_w} |
#| losa: Mxx máximo en valor absoluto [tonf·m/m] | 0.654 | @{M_11py} | @{M_11} | @{d_11} |
#| losa: Mxy máximo en valor absoluto [tonf·m/m] | 0.189 | @{M_12py} | @{M_12} | @{d_12} |
#| columna: M en la cara [tonf·m] | 2.130 | @{M_ccpy} | @{M_cc} | @{d_cc} |
#| columna: P [tonf] | 4.50 | @{P_cpy} | @{P_c} | @{d_pc} |
#| columna: V [tonf] | 0.608 | @{V_cpy} | @{V_c} | @{d_vc} |
#| viga: V [tonf] | 2.203 | @{V_vpy} | @{V_v} | @{d_vv} |
#| viga: T [tonf·m] | 1.147 | @{T_vpy} | @{T_v} | @{d_tv} |
#| viga: M al centro [tonf·m] | 3.141 | @{M_vpy} | @{M_v} | @{d_mv} |
#| viga: P [tonf] | 0.376 | @{P_vpy} | @{P_v} | @{d_pv} |
#| suma de reacciones [tonf] | q·L²/g = @{Q_t} | @{Q_t} | @{R_z} | @{d_r} |

#hide
function z = bil(Gr, x, y, d, n)
  % interpolación bilineal de la rejilla de nudos (funciones de forma del Q4)
  i = min(max(floor(x/d), 0), n - 1)
  j = min(max(floor(y/d), 0), n - 1)
  r = x/d - i
  s = y/d - j
  z = (1 - r)·(1 - s)·Gr(i + 1, j + 1) + r·(1 - s)·Gr(i + 2, j + 1) + r·s·Gr(i + 2, j + 2) + (1 - r)·s·Gr(i + 1, j + 2)
end

function r = stv(b, h)
  % J de Saint-Venant de un rectángulo (Roark): cubo del lado CORTO
  a = max(b, h)
  s = min(b, h)
  z = s/a
  r = (1/3 - 0.21·z·(1 - z^4/12))·a·s^3
end

function K = memb_q6(E, nu, t, a)
  % membrana Q6 de modos incompatibles, rectángulo de medio lado a (shell_thin.py, _membrane_k_q6)
  c = E/(1 - nu^2)
  Em = c·[1, nu, 0; nu, 1, 0; 0, 0, (1 - nu)/2]
  gp = [-1, 1]/sqrt(3)
  Kuu = zeros(8, 8)
  Kua = zeros(8, 4)
  Kaa = zeros(4, 4)
  for ix = 1:2
    for iy = 1:2
      xi = gp(ix)
      eta = gp(iy)
      dNx = [-(1 - eta), 1 - eta, 1 + eta, -(1 + eta)]/(4·a)
      dNy = [-(1 - xi), -(1 + xi), 1 + xi, 1 - xi]/(4·a)
      B = zeros(3, 8)
      for i = 1:4
        B(1, 2·i - 1) = dNx(i)
        B(2, 2·i) = dNy(i)
        B(3, 2·i - 1) = dNy(i)
        B(3, 2·i) = dNx(i)
      end
      Gi = zeros(3, 4)
      Gi(1, 1) = -2·xi/a
      Gi(3, 2) = -2·eta/a
      Gi(3, 3) = -2·xi/a
      Gi(2, 4) = -2·eta/a
      wd = t·a^2
      Kuu = Kuu + wd·transpose(B)·Em·B
      Kua = Kua + wd·transpose(B)·Em·Gi
      Kaa = Kaa + wd·transpose(Gi)·Em·Gi
    end
  end
  K = Kuu - Kua·inv(Kaa)·transpose(Kua)
end

function B = dkq_B(xi, eta, d)
  % B 3×12 del DKQ rectangular (python_dkq.py, _dkq_Bmatrix), lado d, orden (w, θx, θy)
  rw1 = 3·xi·(1 - eta)/d^2
  rt1 = (1 - eta)·(3·xi - 1)/(2·d)
  rw2 = -3·xi·(1 - eta)/d^2
  rt2 = (1 - eta)·(1 + 3·xi)/(2·d)
  rw3 = -3·xi·(1 + eta)/d^2
  rt3 = (1 + eta)·(1 + 3·xi)/(2·d)
  rw4 = 3·xi·(1 + eta)/d^2
  rt4 = (1 + eta)·(3·xi - 1)/(2·d)
  sw1 = 3·(1 - xi)·eta/d^2
  st1 = (1 - xi)·(3·eta - 1)/(2·d)
  sw2 = 3·(1 + xi)·eta/d^2
  st2 = (1 + xi)·(3·eta - 1)/(2·d)
  sw3 = -3·(1 + xi)·eta/d^2
  st3 = (1 + xi)·(1 + 3·eta)/(2·d)
  sw4 = -3·(1 - xi)·eta/d^2
  st4 = (1 - xi)·(1 + 3·eta)/(2·d)
  tq = 3·(2 - xi^2 - eta^2)/(2·d^2)
  bx1 = (1 - xi)·(1 + 3·xi)/(4·d)
  by1 = (1 - eta)·(1 + 3·eta)/(4·d)
  bx2 = (1 + xi)·(1 - 3·xi)/(4·d)
  by2 = -(1 - eta)·(1 + 3·eta)/(4·d)
  bx3 = (1 + xi)·(3·xi - 1)/(4·d)
  by3 = (1 + eta)·(3·eta - 1)/(4·d)
  bx4 = -(1 - xi)·(1 + 3·xi)/(4·d)
  by4 = (1 + eta)·(1 - 3·eta)/(4·d)
  B = [rw1, 0, rt1, rw2, 0, rt2, rw3, 0, rt3, rw4, 0, rt4; sw1, -st1, 0, sw2, -st2, 0, sw3, -st3, 0, sw4, -st4, 0; tq, -by1, bx1, -tq, -by2, bx2, tq, -by3, bx3, -tq, -by4, bx4]
end

function K = dkq_K(Db, d)
  % rigidez 12×12 del DKQ: Gauss 2×2, det J = (d/2)^2
  gx = [-1, 1, 1, -1]/sqrt(3)
  gy = [-1, -1, 1, 1]/sqrt(3)
  K = zeros(12, 12)
  for k = 1:4
    B = dkq_B(gx(k), gy(k), d)
    K = K + transpose(B)·Db·B·(d/2)^2
  end
end

function K = frame_K(E, G, A, Iy, Iz, J, L)
  % Timoshenko 3D 12×12 (local_stiffness.py, _frame_k), área de corte 5/6·A
  As = 5/6·A
  pz = 12·E·Iz/(G·As·L^2)
  py = 12·E·Iy/(G·As·L^2)
  ea = E·A/L
  gj = G·J/L
  tz = 12·E·Iz/L^3/(1 + pz)
  bz = 6·E·Iz/L^2/(1 + pz)
  kz = 4·E·Iz/L·(1 + pz/4)/(1 + pz)
  az = 2·E·Iz/L·(1 - pz/2)/(1 + pz)
  ty = 12·E·Iy/L^3/(1 + py)
  by = 6·E·Iy/L^2/(1 + py)
  ky = 4·E·Iy/L·(1 + py/4)/(1 + py)
  ay = 2·E·Iy/L·(1 - py/2)/(1 + py)
  K = zeros(12, 12)
  K(1, 1) = ea
  K(1, 7) = -ea
  K(7, 1) = -ea
  K(7, 7) = ea
  K(4, 4) = gj
  K(4, 10) = -gj
  K(10, 4) = -gj
  K(10, 10) = gj
  K(2, 2) = tz
  K(2, 6) = bz
  K(2, 8) = -tz
  K(2, 12) = bz
  K(6, 2) = bz
  K(6, 6) = kz
  K(6, 8) = -bz
  K(6, 12) = az
  K(8, 2) = -tz
  K(8, 6) = -bz
  K(8, 8) = tz
  K(8, 12) = -bz
  K(12, 2) = bz
  K(12, 6) = az
  K(12, 8) = -bz
  K(12, 12) = kz
  K(3, 3) = ty
  K(3, 5) = -by
  K(3, 9) = -ty
  K(3, 11) = -by
  K(5, 3) = -by
  K(5, 5) = ky
  K(5, 9) = by
  K(5, 11) = ay
  K(9, 3) = -ty
  K(9, 5) = by
  K(9, 9) = ty
  K(9, 11) = by
  K(11, 3) = -by
  K(11, 5) = ay
  K(11, 9) = by
  K(11, 11) = ky
end

function R = rot_frame(p0, p1)
  % transformation.py, frame: λ con x a lo largo de la barra; 4 bloques de 3×3
  dv = p1 - p0
  L = norm(dv)
  l = dv(1)/L
  m = dv(2)/L
  n = dv(3)/L
  if abs(n - 1) < 1e-9
    lam = [0, 0, 1; 0, 1, 0; -1, 0, 0]
  elseif abs(n + 1) < 1e-9
    lam = [0, 0, -1; 0, 1, 0; 1, 0, 0]
  else
    D = sqrt(l^2 + m^2)
    lam = [l, m, n; -m/D, l/D, 0; -l·n/D, -m·n/D, D]
  end
  R = zeros(12, 12)
  for k = 0:3
    for r = 1:3
      for c = 1:3
        R(3·k + r, 3·k + c) = lam(r, c)
      end
    end
  end
end
#show
