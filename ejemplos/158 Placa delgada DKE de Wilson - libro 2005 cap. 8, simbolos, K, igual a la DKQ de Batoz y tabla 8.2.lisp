# Placa delgada DKE de Wilson (Discrete Kirchhoff Element, libro 2005, cap. 8) · cuadrilátero de 4 nudos: símbolos, K, Batoz y tablas del libro
#numerico
#: **De quién es.** El DKE es de E. L. Wilson, *Three-Dimensional Static and Dynamic Analysis of Structures* (ed. 2005), cap. 8, §8.8, p. 8-10, ec. (8.21). No es de Batoz: el DKQ de Batoz y Tahar (1982) llega a la MISMA matriz por otro camino (medido abajo, sección 5). Las ecuaciones están leídas en las páginas del PDF de 2005 (`registros/libros/wilson_cap8_2005/p-03…p-10.png`). Tres grados de libertad por nudo: w, θx = ∂w/∂y, θy = −∂w/∂x.

## 0 · De la ecuación diferencial a la forma débil
#: Placa delgada de Kirchhoff: D·∇⁴w = q con D = E·h³/(12·(1 − ν²)). Bordes: esenciales (w, ∂w/∂n) y naturales (Mn, Vn). Multiplicando por δw e integrando por partes dos veces queda el trabajo virtual ∫ δψᵀ·D·ψ dA = ∫ δw·q dA: solo curvaturas. El elemento las aproxima con los giros, no con w.

## 1 · Símbolos (p. 8-3 a 8-7)
#: **Giros** (8.1): θ = Σ N_i·θ_i (4 bilineales) + Σ N_m·Δθ_m (4 jerárquicas de lado). Funciones (8.2):
N_1 = Simplify{(1-r)*(1-s)/4}
N_5 = Simplify{(1-r^2)*(1-s)/2}
N_6 = Simplify{(1+r)*(1-s^2)/2}
#: **Solo el giro normal al lado** (8.3): Δθx = sin α·Δθ, Δθy = −cos α·Δθ. Con eso (8.4) quedan 12 + 4 incógnitas.
#: **Curvaturas** (8.10) con ux = z·θy, uy = −z·θx (8.5): ψxx = θy,x · ψyy = −θx,y · ψxy = θy,y − θx,x.
#: **Kirchhoff en cada lado** (8.20)-(8.21): w cúbica a lo largo del lado y cortante de lado nulo. El giro de punto medio deja de ser incógnita:
dtheta = Simplify{3/(2*L)*(w_j - w_i) - 3/4*(t_i + t_j)}
#: con t_i = sin α·θx_i − cos α·θy_i, el giro normal del nudo i (8.7). **Matriz de comportamiento** (8.15):
D_11 = Simplify{E*h^3/(12*(1-nu^2))}
#: D12 = ν·D11 y D33 = (1 − ν)/2·D11. Rigidez (8.12): K = Σ bᵀ·D·b·det J en 2 × 2 puntos de Gauss (§8.9, p. 8-10: «a four-point numerical integration formula»).

## 2 · Datos (cuadrilátero cualquiera)
E = 25000000 [kN/m²] 'módulo de elasticidad
ν = 0.2 'coeficiente de Poisson (sin unidad)
h = 0.1 [m] 'espesor
X_e = [0, 0; 2, 0.2; 2.2, 1.8; 0.1, 1.6] [m] 'coordenadas x, y de los nudos 1 a 4 (antihorario)
D_p = E·h^3/(12·(1 - ν^2)) [kN·m] 'rigidez a flexión
D_b = D_p·[1, ν, 0; ν, 1, 0; 0, 0, (1 - ν)/2] [kN·m] 'matriz momento-curvatura (8.15)

## 3 · Lados y restricción de Kirchhoff (8.21)
#: Lado m = del nudo m al siguiente. Largo L, sin α y cos α; la fila m de T da Δθ_m = T(m, :)·u:
#hide
L_l = zeros(4, 1)
s_l = zeros(4, 1)
c_l = zeros(4, 1)
T = zeros(4, 12)
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
  T(m, 3·j - 2) = T(m, 3·j - 2) + 1.5/L_l(m)
  T(m, 3·m - 2) = T(m, 3·m - 2) - 1.5/L_l(m)
  T(m, 3·m - 1) = T(m, 3·m - 1) - 0.75·s_l(m)
  T(m, 3·j - 1) = T(m, 3·j - 1) - 0.75·s_l(m)
  T(m, 3·m) = T(m, 3·m) + 0.75·c_l(m)
  T(m, 3·j) = T(m, 3·j) + 0.75·c_l(m)
end
#show
L_1 = L_l(1) [m] 'largo del lado 1 (nudos 1-2)
T_11 = T(1, 1) 'coeficiente de w₁ en Δθ del lado 1, en 1/m (= −3/(2·L))

## 4 · Rigidez K = Σ bᵀ·D·b·det J (Gauss 2 × 2)
g_p = 1/sqrt(3) 'coordenada de los puntos de Gauss
#hide
r_g = [-g_p, g_p, g_p, -g_p]
s_g = [-g_p, -g_p, g_p, g_p]
K_e = zeros(12, 12)
for p = 1:4
  r = r_g(p)
  s = s_g(p)
  d_N = 0.25·[-(1 - s), 1 - s, 1 + s, -(1 + s); -(1 - r), -(1 + r), 1 + r, 1 - r]
  d_M = [-r·(1 - s), 0.5·(1 - s^2), -r·(1 + s), -0.5·(1 - s^2); -0.5·(1 - r^2), -(1 + r)·s, 0.5·(1 - r^2), -(1 - r)·s]
  J_p = d_N·X_e
  J_i = inv(J_p)
  d_Nx = J_i·d_N
  d_Mx = J_i·d_M
  g_x = zeros(2, 16)
  g_y = zeros(2, 16)
  for k = 1:4
    g_x(:, 3·k - 1) = d_Nx(:, k)
    g_y(:, 3·k) = d_Nx(:, k)
    g_x(:, 12 + k) = s_l(k)·d_Mx(:, k)
    g_y(:, 12 + k) = -c_l(k)·d_Mx(:, k)
  end
  b_16 = [g_y(1, :); -g_x(2, :); g_y(2, :) - g_x(1, :)]
  b_12 = b_16(:, 1:12) + b_16(:, 13:16)·T
  K_e = K_e + transpose(b_12)·D_b·b_12·det(J_p)
end
#show
K_e11 = K_e(1, 1) [kN/m] 'rigidez a w del nudo 1
K_e22 = K_e(2, 2) [kN·m] 'rigidez a θx del nudo 1
K_e33 = K_e(3, 3) [kN·m] 'rigidez a θy del nudo 1
u_r = [1; 0; 0; 1; 0; 0; 1; 0; 0; 1; 0; 0]
f_r = max(abs(K_e·u_r)) [kN] 'fuerza de una traslación rígida (cero)

## 5 · Contra Python (placas_wilson.k_dke) y contra el DKQ de Batoz
#: Diagonal y primera fila de k_dke de hekatan-struct-py con los mismos datos. Y k_dke = k_dkq de Batoz-Tahar a 4·10⁻¹⁶ (test_placas_wilson.py, 16 casos: cuadrado, rectángulo, irregular, trapecio × ν = 0 … 0.45): **el mismo elemento**.
d_py = [7316.316784471; 3661.405538313; 2281.039535151; 7168.746741566; 3780.940266517; 2501.975814690; 6982.039202437; 3679.477152456; 2278.977831937; 7127.738672020; 3911.752240946; 2422.958917080] 'diagonal de k_dke en Python (kN/m y kN·m)
f_py = [7316.316784471; 3856.202257218; -2179.058584267; -812.560357329; 1878.516215411; -1805.204897334; -1672.510434950; 1642.638193336; -877.230701348; -4831.245992192; 3525.667775918; -926.274087820] 'primera fila de k_dke en Python
#hide
d_h = zeros(12, 1)
f_h = zeros(12, 1)
for i = 1:12
  d_h(i) = K_e(i, i)
  f_h(i) = K_e(1, i)
end
#show
e_py = max(max(abs(d_h - d_py)), max(abs(f_h - f_py)))/max(abs(d_py)) 'mayor diferencia relativa hoja − Python

## 6 · Tablas 8.2 del libro: cuarto de placa cuadrada, carga puntual (p. 8-12)
#: Placa de 10 × 10 apoyada, P = 1 en el centro, E = 10.92, ν = 0.3 (así D = h³ y w·h³ = w·D). Se modela un cuarto (5 × 5) con 4 × 4 elementos: w = 0 en los bordes apoyados con el giro a lo largo del borde nulo (borde «duro»), θy = 0 en x = 5 y θx = 0 en y = 5 (simetría). Con h = 1 el DKE no depende de h.
E_t = 10.92 'módulo del ejemplo del libro (sin unidad)
ν_t = 0.3 'Poisson del ejemplo
n_m = 4 'elementos por lado del cuarto de placa
a_t = 5 'lado del cuarto de placa
D_t = E_t/(12·(1 - ν_t^2))·[1, ν_t, 0; ν_t, 1, 0; 0, 0, (1 - ν_t)/2] 'matriz momento-curvatura con h = 1
#hide
X_e = a_t/n_m·[0, 0; 1, 0; 1, 1; 0, 1]
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
T = zeros(4, 12)
for m = 1:4
  j = m + 1
  if j > 4
    j = 1
  end
  T(m, 3·j - 2) = T(m, 3·j - 2) + 1.5/L_l(m)
  T(m, 3·m - 2) = T(m, 3·m - 2) - 1.5/L_l(m)
  T(m, 3·m - 1) = T(m, 3·m - 1) - 0.75·s_l(m)
  T(m, 3·j - 1) = T(m, 3·j - 1) - 0.75·s_l(m)
  T(m, 3·m) = T(m, 3·m) + 0.75·c_l(m)
  T(m, 3·j) = T(m, 3·j) + 0.75·c_l(m)
end
K_t = zeros(12, 12)
B_c = zeros(12, 12)
for p = 1:4
  r = r_g(p)
  s = s_g(p)
  d_N = 0.25·[-(1 - s), 1 - s, 1 + s, -(1 + s); -(1 - r), -(1 + r), 1 + r, 1 - r]
  d_M = [-r·(1 - s), 0.5·(1 - s^2), -r·(1 + s), -0.5·(1 - s^2); -0.5·(1 - r^2), -(1 + r)·s, 0.5·(1 - r^2), -(1 - r)·s]
  J_p = d_N·X_e
  J_i = inv(J_p)
  d_Nx = J_i·d_N
  d_Mx = J_i·d_M
  g_x = zeros(2, 16)
  g_y = zeros(2, 16)
  for k = 1:4
    g_x(:, 3·k - 1) = d_Nx(:, k)
    g_y(:, 3·k) = d_Nx(:, k)
    g_x(:, 12 + k) = s_l(k)·d_Mx(:, k)
    g_y(:, 12 + k) = -c_l(k)·d_Mx(:, k)
  end
  b_16 = [g_y(1, :); -g_x(2, :); g_y(2, :) - g_x(1, :)]
  b_12 = b_16(:, 1:12) + b_16(:, 13:16)·T
  K_t = K_t + transpose(b_12)·D_t·b_12·det(J_p)
  B_c(3·p - 2:3·p, :) = b_12
end
n_n = n_m + 1
n_j = n_n^2
K = zeros(3·n_j, 3·n_j)
F = zeros(3·n_j, 1)
for j = 1:n_m
  for i = 1:n_m
    k = (j - 1)·n_n + i
    g = [3·k - 2:3·k, 3·k + 1:3·k + 3, 3·(k + n_n) + 1:3·(k + n_n) + 3, 3·(k + n_n) - 2:3·(k + n_n)]
    K(g, g) = K(g, g) + K_t
  end
end
k_r = 10^20
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
k_c = n_j - n_n - 1
g_c = [3·k_c - 2:3·k_c, 3·k_c + 1:3·k_c + 3, 3·n_j - 2:3·n_j, 3·n_j - 5:3·n_j - 3]
u_c = U(g_c)
D_B = zeros(12, 12)
for p = 1:4
  D_B(3·p - 2:3·p, 3·p - 2:3·p) = D_t
end
M_a = D_B·B_c·u_c
M_g = [M_a(1); M_a(4); M_a(7); M_a(10)]
M_c = 0.25·((1 + 3·r_g(1))·(1 + 3·s_g(1))·M_g(1) + (1 + 3·r_g(2))·(1 + 3·s_g(2))·M_g(2) + (1 + 3·r_g(3))·(1 + 3·s_g(3))·M_g(3) + (1 + 3·r_g(4))·(1 + 3·s_g(4))·M_g(4))
#show
w_c = U(3·n_j - 2) 'flecha del centro por h³ (sin unidad: D = h³)
w_lib = 1.195 'tabla 8.2 del libro, DKE 4 × 4
e_w = round(100·(w_c - w_lib)/w_lib, 3) [%] 'hoja frente al libro
w_py = 1.1937204785866729 'cuadrante_placa_cuadrada("dke", 1, 4) en Python
M_cc = M_c 'Mxx en el centro (Gauss 2 × 2 extrapolado al nudo)
M_lib = 0.3545 'tabla 8.2, DKE
M_py = 0.37532795851200246 'el mismo Mxx en Python (momentos("dke", …, "nudos"))
e_Mpy = abs(M_cc - M_py)/M_py 'diferencia relativa hoja − Python en el momento
#: **Cómo se lee.** La flecha coincide con el libro al 0.1 % y con Python a 10⁻¹⁰; con 16 × 16 (tabla 8.3) la flecha da 1.1630 = 1.163 del libro. El momento máximo del libro (0.3545) no se reproduce con ninguna recuperación probada (nudo extrapolado 0.3753, Gauss 0.2848, centro 0.1939): el libro no dice dónde lo evalúa. La flecha exacta de Kirchhoff es 1.160.
