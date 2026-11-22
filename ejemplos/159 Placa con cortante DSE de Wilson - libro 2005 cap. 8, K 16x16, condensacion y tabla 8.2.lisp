# Placa con cortante DSE de Wilson (Discrete Shear Element, libro 2005, cap. 8) · cuadrilátero de 4 nudos: símbolos, K 16 × 16, condensación y tablas del libro
#numerico
#: **De quién es.** El DSE es de E. L. Wilson, *Three-Dimensional Static and Dynamic Analysis of Structures* (ed. 2005), cap. 8, §8.2-8.6, p. 8-2 a 8-9; la referencia que cita es Ibrahimbegović (1993), CMAME 110, 195-209. No es de Batoz. Ecuaciones leídas en las páginas del PDF de 2005 (`registros/libros/wilson_cap8_2005/p-03…p-10.png`). Sirve para placa delgada y gruesa: incluye el cortante transversal. GDL por nudo: w, θx, θy (θx = ∂w/∂y, θy = −∂w/∂x cuando el cortante es nulo).
#: **Medido:** el DSE NO es el Shell-Thick de SAP2000 y ETABS (ingenieria-inversa/csi_shellthick/k_grueso_cuad.py): sus K difieren del orden de la propia K. El Thick de CSI usa giros de lado de dos componentes, una burbuja, 8 puntos de integración y una penalización que el libro no trae.

## 0 · De la ecuación diferencial a la forma débil
#: Placa de Reissner-Mindlin: equilibrio ∇·M − Q = 0 y ∇·Q + q = 0, con Q = (5/6)·G·h·γ. Bordes esenciales (w, giros) y naturales (Mn, Mns, Vn). Integrando por partes con (δw, δθ) queda ∫ δψᵀ·D_b·ψ dA + ∫ δγᵀ·D_s·γ dA = ∫ δw·q dA: curvaturas y cortantes.

## 1 · Símbolos (p. 8-3 a 8-9)
#: **Giros** (8.1)-(8.4): 4 bilineales + 4 jerárquicas de lado, solo con el giro NORMAL al lado (Δθx = sin α·Δθ, Δθy = −cos α·Δθ):
N_5 = Simplify{(1-r^2)*(1-s)/2}
#: **Cortante a lo largo del lado** (8.6)-(8.7), con w cúbica en el lado; el 2/3 es la media de N_m a lo largo del lado:
g_lado = Simplify{(w_j - w_i)/L - (t_i + t_j)/2 - 2/3*Dt}
#: **Cortantes del nudo i** (8.8)-(8.9) desde los dos lados que llegan (ij y ki), y bilineales al punto de Gauss:
#: [γxz; γyz]_i = 1/det·[sin α_ki, −cos α_ki; −sin α_ij, cos α_ij]·[γ_ij; γ_ki], det = cos α_ij·sin α_ki − cos α_ki·sin α_ij.
#: **Curvaturas** (8.10): ψxx = θy,x · ψyy = −θx,y · ψxy = θy,y − θx,x. **Patch test** (8.17): a las columnas de los Δθ se les resta su media en el área, b12 ← b12 − (1/A)·∫ b12 dA.
#: **Comportamiento** (8.15):
D_44 = Simplify{5*E*h/(12*(1+nu))}
#: **Rigidez** (8.18): K de 16 × 16 = Σ (bᵀ·D_b·b + b_sᵀ·D_s·b_s)·det J en 2 × 2 puntos; **condensación** (8.19) de los 4 Δθ (sus fuerzas son nulas): K = K₁₁ − K₁₂·K₂₂⁻¹·K₂₁.

## 2 · Datos (cuadrilátero cualquiera)
E = 25000000 [kN/m²] 'módulo de elasticidad
ν = 0.2 'coeficiente de Poisson (sin unidad)
h = 0.1 [m] 'espesor
X_e = [0, 0; 2, 0.2; 2.2, 1.8; 0.1, 1.6] [m] 'coordenadas x, y de los nudos 1 a 4 (antihorario)
D_b = E·h^3/(12·(1 - ν^2))·[1, ν, 0; ν, 1, 0; 0, 0, (1 - ν)/2] [kN·m] 'matriz momento-curvatura (8.15)
D_s = 5·E·h/(12·(1 + ν))·[1, 0; 0, 1] [kN/m] 'matriz cortante-distorsión (8.15)

## 3 · Lados, cortantes de lado y de nudo
#hide
L_l = zeros(4, 1)
s_l = zeros(4, 1)
c_l = zeros(4, 1)
G_l = zeros(4, 16)
for m = 1:4
  j = m + 1
  if j > 4
    j = 1
  end
  d_x = X_e(j, 1) - X_e(m, 1)
  d_y = X_e(j, 2) - X_e(m, 2)
  L_l(m) = sqrt(d_x^2 + d_y^2)
  s_l(m) = d_y/L_l(m)
  c_l(m) = d_x/L_l(m)
  G_l(m, 3·j - 2) = G_l(m, 3·j - 2) + 1/L_l(m)
  G_l(m, 3·m - 2) = G_l(m, 3·m - 2) - 1/L_l(m)
  G_l(m, 3·m - 1) = G_l(m, 3·m - 1) - s_l(m)/2
  G_l(m, 3·j - 1) = G_l(m, 3·j - 1) - s_l(m)/2
  G_l(m, 3·m) = G_l(m, 3·m) + c_l(m)/2
  G_l(m, 3·j) = G_l(m, 3·j) + c_l(m)/2
  G_l(m, 12 + m) = -2/3
end
G_n = zeros(8, 16)
for i = 1:4
  k = i - 1
  if k < 1
    k = 4
  end
  d_t = c_l(i)·s_l(k) - c_l(k)·s_l(i)
  T_i = [s_l(k), -c_l(k); -s_l(i), c_l(i)]/d_t
  G_n(2·i - 1:2·i, :) = T_i·[G_l(i, :); G_l(k, :)]
end
#show
L_1 = L_l(1) [m] 'largo del lado 1 (nudos 1-2)
G_116 = G_l(1, 13) 'coeficiente de Δθ en el cortante del lado 1 (−2/3)

## 4 · Rigidez de 16 × 16 y condensación
g_p = 1/sqrt(3) 'coordenada de los puntos de Gauss
#hide
r_g = [-g_p, g_p, g_p, -g_p]
s_g = [-g_p, -g_p, g_p, g_p]
B_16 = zeros(12, 16)
S_16 = zeros(8, 16)
d_J = zeros(4, 1)
for p = 1:4
  r = r_g(p)
  s = s_g(p)
  N_b = 0.25·[(1 - r)·(1 - s), (1 + r)·(1 - s), (1 + r)·(1 + s), (1 - r)·(1 + s)]
  d_N = 0.25·[-(1 - s), 1 - s, 1 + s, -(1 + s); -(1 - r), -(1 + r), 1 + r, 1 - r]
  d_M = [-r·(1 - s), 0.5·(1 - s^2), -r·(1 + s), -0.5·(1 - s^2); -0.5·(1 - r^2), -(1 + r)·s, 0.5·(1 - r^2), -(1 - r)·s]
  J_p = d_N·X_e
  J_i = inv(J_p)
  d_Nx = J_i·d_N
  d_Mx = J_i·d_M
  g_x = zeros(2, 16)
  g_y = zeros(2, 16)
  b_s = zeros(2, 16)
  for k = 1:4
    g_x(:, 3·k - 1) = d_Nx(:, k)
    g_y(:, 3·k) = d_Nx(:, k)
    g_x(:, 12 + k) = s_l(k)·d_Mx(:, k)
    g_y(:, 12 + k) = -c_l(k)·d_Mx(:, k)
    b_s = b_s + N_b(k)·G_n(2·k - 1:2·k, :)
  end
  B_16(3·p - 2:3·p, :) = [g_y(1, :); -g_x(2, :); g_y(2, :) - g_x(1, :)]
  S_16(2·p - 1:2·p, :) = b_s
  d_J(p) = det(J_p)
end
A_e = sum(d_J)
b_m = zeros(3, 4)
for p = 1:4
  b_m = b_m + B_16(3·p - 2:3·p, 13:16)·d_J(p)/A_e
end
K_16 = zeros(16, 16)
for p = 1:4
  b_k = B_16(3·p - 2:3·p, :)
  b_k(:, 13:16) = b_k(:, 13:16) - b_m
  b_s = S_16(2·p - 1:2·p, :)
  K_16 = K_16 + (transpose(b_k)·D_b·b_k + transpose(b_s)·D_s·b_s)·d_J(p)
end
K_e = K_16(1:12, 1:12) - K_16(1:12, 13:16)·inv(K_16(13:16, 13:16))·K_16(13:16, 1:12)
#show
A_ee = A_e [m²] 'área del elemento (suma de det J en los 4 puntos)
K_e11 = K_e(1, 1) [kN/m] 'rigidez a w del nudo 1 (condensada)
K_e22 = K_e(2, 2) [kN·m] 'rigidez a θx del nudo 1
K_e33 = K_e(3, 3) [kN·m] 'rigidez a θy del nudo 1
u_r = [1; 0; 0; 1; 0; 0; 1; 0; 0; 1; 0; 0]
f_r = max(abs(K_e·u_r)) [kN] 'fuerza de una traslación rígida (cero)

## 5 · Contra Python (placas_wilson.k_dse)
d_py = [6210.794611392; 3709.327116153; 2427.109959579; 6092.439194942; 4067.779915679; 2893.671675155; 5905.714454676; 3673.675408656; 2427.190495833; 6022.974188413; 4149.708362013; 2817.669446084] 'diagonal de k_dse en Python (kN/m y kN·m)
f_py = [6210.794611392; 3733.111537893; -2102.165213378; 203.488517856; 1758.140145436; -1917.944209630; -2671.596398284; 1692.853710621; -980.305634986; -3742.686730964; 3572.369188932; -844.388655616] 'primera fila de k_dse en Python
#hide
d_h = zeros(12, 1)
f_h = zeros(12, 1)
for i = 1:12
  d_h(i) = K_e(i, i)
  f_h(i) = K_e(1, i)
end
#show
e_py = max(max(abs(d_h - d_py)), max(abs(f_h - f_py)))/max(abs(d_py)) 'mayor diferencia relativa hoja − Python

## 6 · Tabla 8.2 del libro: cuarto de placa cuadrada, carga puntual (p. 8-12)
#: Placa de 10 × 10, P = 1 en el centro, E = 10.92, ν = 0.3 (D = h³); cuarto de placa 5 × 5 con 4 × 4 elementos, borde «duro» (w = 0 y giro a lo largo del borde nulo, p. 8-11: «this hard boundary condition is required for the DSE») y simetría. Dos espesores: h = 1 (placa gruesa) y h = 0.01 (delgada).
E_t = 10.92 'módulo del ejemplo del libro (sin unidad)
ν_t = 0.3 'Poisson del ejemplo
n_m = 4 'elementos por lado del cuarto de placa
h_v = [1, 0.01] 'espesores de la tabla
#hide
X_e = 1.25·[0, 0; 1, 0; 1, 1; 0, 1]
for m = 1:4
  j = m + 1
  if j > 4
    j = 1
  end
  d_x = X_e(j, 1) - X_e(m, 1)
  d_y = X_e(j, 2) - X_e(m, 2)
  L_l(m) = sqrt(d_x^2 + d_y^2)
  s_l(m) = d_y/L_l(m)
  c_l(m) = d_x/L_l(m)
end
G_l = zeros(4, 16)
for m = 1:4
  j = m + 1
  if j > 4
    j = 1
  end
  G_l(m, 3·j - 2) = G_l(m, 3·j - 2) + 1/L_l(m)
  G_l(m, 3·m - 2) = G_l(m, 3·m - 2) - 1/L_l(m)
  G_l(m, 3·m - 1) = G_l(m, 3·m - 1) - s_l(m)/2
  G_l(m, 3·j - 1) = G_l(m, 3·j - 1) - s_l(m)/2
  G_l(m, 3·m) = G_l(m, 3·m) + c_l(m)/2
  G_l(m, 3·j) = G_l(m, 3·j) + c_l(m)/2
  G_l(m, 12 + m) = -2/3
end
G_n = zeros(8, 16)
for i = 1:4
  k = i - 1
  if k < 1
    k = 4
  end
  d_t = c_l(i)·s_l(k) - c_l(k)·s_l(i)
  T_i = [s_l(k), -c_l(k); -s_l(i), c_l(i)]/d_t
  G_n(2·i - 1:2·i, :) = T_i·[G_l(i, :); G_l(k, :)]
end
for p = 1:4
  r = r_g(p)
  s = s_g(p)
  N_b = 0.25·[(1 - r)·(1 - s), (1 + r)·(1 - s), (1 + r)·(1 + s), (1 - r)·(1 + s)]
  d_N = 0.25·[-(1 - s), 1 - s, 1 + s, -(1 + s); -(1 - r), -(1 + r), 1 + r, 1 - r]
  d_M = [-r·(1 - s), 0.5·(1 - s^2), -r·(1 + s), -0.5·(1 - s^2); -0.5·(1 - r^2), -(1 + r)·s, 0.5·(1 - r^2), -(1 - r)·s]
  J_p = d_N·X_e
  J_i = inv(J_p)
  d_Nx = J_i·d_N
  d_Mx = J_i·d_M
  g_x = zeros(2, 16)
  g_y = zeros(2, 16)
  b_s = zeros(2, 16)
  for k = 1:4
    g_x(:, 3·k - 1) = d_Nx(:, k)
    g_y(:, 3·k) = d_Nx(:, k)
    g_x(:, 12 + k) = s_l(k)·d_Mx(:, k)
    g_y(:, 12 + k) = -c_l(k)·d_Mx(:, k)
    b_s = b_s + N_b(k)·G_n(2·k - 1:2·k, :)
  end
  B_16(3·p - 2:3·p, :) = [g_y(1, :); -g_x(2, :); g_y(2, :) - g_x(1, :)]
  S_16(2·p - 1:2·p, :) = b_s
  d_J(p) = det(J_p)
end
A_e = sum(d_J)
b_m = zeros(3, 4)
for p = 1:4
  b_m = b_m + B_16(3·p - 2:3·p, 13:16)·d_J(p)/A_e
end
n_n = n_m + 1
n_j = n_n^2
w_t = zeros(2, 1)
for i_h = 1:2
  h_t = h_v(i_h)
  D_bt = E_t·h_t^3/(12·(1 - ν_t^2))·[1, ν_t, 0; ν_t, 1, 0; 0, 0, (1 - ν_t)/2]
  D_st = 5·E_t·h_t/(12·(1 + ν_t))·[1, 0; 0, 1]
  K_16 = zeros(16, 16)
  for p = 1:4
    b_k = B_16(3·p - 2:3·p, :)
    b_k(:, 13:16) = b_k(:, 13:16) - b_m
    b_s = S_16(2·p - 1:2·p, :)
    K_16 = K_16 + (transpose(b_k)·D_bt·b_k + transpose(b_s)·D_st·b_s)·d_J(p)
  end
  K_t = K_16(1:12, 1:12) - K_16(1:12, 13:16)·inv(K_16(13:16, 13:16))·K_16(13:16, 1:12)
  K = zeros(3·n_j, 3·n_j)
  F = zeros(3·n_j, 1)
  for j = 1:n_m
    for i = 1:n_m
      k = (j - 1)·n_n + i
      g = [3·k - 2:3·k, 3·k + 1:3·k + 3, 3·(k + n_n) + 1:3·(k + n_n) + 3, 3·(k + n_n) - 2:3·(k + n_n)]
      K(g, g) = K(g, g) + K_t
    end
  end
  k_r = 10^20·max(abs(K_t(1, 1)), 1)
  for j = 1:n_n
    for i = 1:n_n
      k = (j - 1)·n_n + i
      if i == 1
        K(3·k - 2, 3·k - 2) = K(3·k - 2, 3·k - 2) + k_r
        K(3·k - 1, 3·k - 1) = K(3·k - 1, 3·k - 1) + k_r
      end
      if j == 1
        K(3·k - 2, 3·k - 2) = K(3·k - 2, 3·k - 2) + k_r
        K(3·k, 3·k) = K(3·k, 3·k) + k_r
      end
      if i == n_n
        K(3·k, 3·k) = K(3·k, 3·k) + k_r
      end
      if j == n_n
        K(3·k - 1, 3·k - 1) = K(3·k - 1, 3·k - 1) + k_r
      end
    end
  end
  F(3·n_j - 2) = 0.25
  U = clsolve(K, F)
  w_t(i_h) = U(3·n_j - 2)·h_t^3
end
#show
w_h1 = w_t(1) 'flecha del centro por h³ con h = 1 (sin unidad)
w_lib1 = 1.383 'tabla 8.2 del libro, DSE, h = 1
w_py1 = 1.3817524554356204 'Python, cuadrante_placa_cuadrada("dse", 1, 4)
w_h2 = w_t(2) 'flecha del centro por h³ con h = 0.01
w_lib2 = 1.218 'tabla 8.2 del libro, DSE, h = 0.01
w_py2 = 1.2162457556027133 'Python, cuadrante_placa_cuadrada("dse", 0.01, 4)
e_lib = round(100·max(abs(w_h1 - w_lib1)/w_lib1, abs(w_h2 - w_lib2)/w_lib2), 3) [%] 'mayor diferencia hoja − libro
e_py = max(abs(w_h1 - w_py1)/w_py1, abs(w_h2 - w_py2)/w_py2) 'mayor diferencia hoja − Python
#: **Cómo se lee.** El DSE reproduce la tabla 8.2 al 0.15 % y la 8.3 (16 × 16: 1.3929 y 1.1648 frente a 1.393 y 1.164) en Python. Con h = 1 el cortante ablanda la placa un 14 %; con h = 0.01 el DSE tiende al DKE (1.1937) sin bloquearse. La flecha exacta de Kirchhoff es 1.160.
