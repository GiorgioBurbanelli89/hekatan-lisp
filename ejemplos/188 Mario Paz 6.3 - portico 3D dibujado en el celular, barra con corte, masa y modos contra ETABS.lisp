# Mario Paz 6.3: pórtico 3D dibujado en el celular, de la barra a los modos, contra ETABS
#numerico
#: **La idea.** Un pórtico de un piso con 4 columnas y 4 vigas de acero (Paz y Leigh, ejemplo 6.3). Cada barra es un resorte en 3D: se estira, se dobla en dos planos y se tuerce. Si se juntan los 8 resortes y la masa de acero en los nudos de arriba, salen las **frecuencias** con las que el pórtico vibra.
#: La geometría se dibujó **desde cero en el celular** (Hekatan Croquis: cursor con lupa, cotas editables y calculadora) y se pasó a esta hoja con el botón «Llevar a Math Studio».
#: Unidades del libro: **kip, in, s**.

## 1 · El objeto: la geometría que viene del Croquis
X_n = [0, 0, 0; 0, 0, 180; 0, 240, 0; 0, 240, 180; 114, 0, 0; 114, 0, 180; 114, 240, 0; 114, 240, 180] @@(coordenadas x, y, z de los 8 nudos, in)
e_n = [1, 2; 3, 4; 5, 6; 7, 8; 2, 6; 4, 8; 2, 4; 6, 8] @@(barras: 1-4 columnas W24x146, 5-8 vigas W14x84)
s_q = zeros(0, 4) @@(sin cáscaras: solo barras)
apoyo_n = [3; 0; 3; 0; 3; 0; 3; 0] @@(3 = empotrado: las 4 bases)
#hide
sin_diagrama = zeros(8, 2)
#show
#: El pórtico en 3D (arrastra para girar):
#modelo3d(X_n, s_q, e_n, apoyo_n, sin_diagrama)

## 2 · Con letras: la barra 3D con deformación por corte
#: Cada nudo tiene 6 movimientos: 3 desplazamientos (u, v, w) y 3 giros (θ₁, θ₂, θ₃). Una barra une 2 nudos: su rigidez es de **12×12** (hoja 68). Aquí se le agrega lo que ETABS sí cuenta y la hoja 68 no: la **deformación por corte** (viga de Timoshenko).
#: El corte se mide con Φ: la flexión pura frente al corte. Si el área de corte A_s fuera infinita, Φ = 0 y vuelve la viga de siempre (Euler–Bernoulli).
Phi(E, I, G, A_s, L) = 12*E*I/(G*A_s*L^2) @@(Φ: cuánto pesa el corte frente a la flexión)
#: La flexión en el plano 1-2 (desplazamiento v y giro θ₃ en cada punta, con I₃₃):
k_f(E, I, L, F) = E*I/(L^3*(1 + F))*[12, 6*L, -12, 6*L; 6*L, (4 + F)*L^2, -6*L, (2 - F)*L^2; -12, -6*L, 12, -6*L; 6*L, (2 - F)*L^2, -6*L, (4 + F)*L^2] @@(v_i, θ_i, v_j, θ_j · F = Φ)
#: Con Φ = 0 se recupera 12·E·I/L³, 6·E·I/L², 4·E·I/L y 2·E·I/L. El corte **ablanda** la barra: divide entre (1 + Φ). El plano 1-3 es igual con I₂₂ (y signos cambiados en los giros).
#: El estiramiento y la torsión son dos resortes simples:
k_a(E, A, L) = E*A/L*[1, -1; -1, 1] @@(axial)
k_t(G, J, L) = G*J/L*[1, -1; -1, 1] @@(torsión)
#: **Hipótesis: el corte importa en barras cortas y peraltadas.** Φ crece cuando L baja. Con la columna W24x146 (E = 29500, I₃₃ = 5630, G = 11346, A_s = 35,83):
#fplot(rigidez_con_corte = 1/(1 + 12*29500*5630/(11346.15*35.833333*x^2)), [40 400])
#: A 180 in (la columna del pórtico) la barra conserva el 95 % de su rigidez a flexión; a 60 in, solo el 64 %.

## 3 · Con letras: de ejes locales a globales
#: La matriz se arma en los ejes de la barra (1 = a lo largo). Para ensamblar se gira a los ejes del edificio: K = Tᵀ·k·T, con T = diag(R, R, R, R) y R = [e₁; e₂; e₃].
#: Columnas (verticales): e₁ = Z, e₂ = X, e₃ = Y, como ETABS. Vigas: e₁ a lo largo, e₂ = Z (arriba) y e₃ = e₁ × e₂.

## 4 · Con letras: la masa
#: Se concentra en los nudos: **la mitad de cada barra a cada punta**, en las tres traslaciones (los giros no llevan masa).
m_nudo(rho, A, L_libre) = rho*A*L_libre/2 @@(masa que cada barra le da a cada nudo)
#: ETABS pesa las vigas con su **luz libre**: descuenta el ancho de la columna en cada punta (la viga no pesa dentro del nudo). Las columnas van completas.

## 5 · Con números (kip, in, s)
E = 29500 @@(ksi)
nu = 0.3
G = E/(2*(1 + nu)) @@(ksi)
rho = 490/1000/12^3/386.4 @@(kip·s²/in⁴: acero de 490 lb/ft³)
S_e = [43, 391, 5630, 34.8, 35.833333; 24.7, 225, 928, 5.9, 20.583333] @@(A, I₂₂, I₃₃, J, A_s · fila 1 = W24x146, fila 2 = W14x84)
t_e = [1; 1; 1; 1; 2; 2; 2; 2] @@(sección de cada barra)
d_c = [24.7, 12.9] @@(ancho de la columna en x y en y: lo que la viga no pesa)
#: Se arma cada barra (12×12), se gira con T y se suma en la matriz del pórtico (8 nudos × 6 = 48 grados de libertad):
#hide
K = zeros(48, 48)
m_v = zeros(8, 1)
for e = 1:8
  a = e_n(e, 1)
  b = e_n(e, 2)
  s = t_e(e)
  dx = X_n(b, 1) - X_n(a, 1)
  dy = X_n(b, 2) - X_n(a, 2)
  dz = X_n(b, 3) - X_n(a, 3)
  L = sqrt(dx^2 + dy^2 + dz^2)
  A_e = S_e(s, 1)
  I_2 = S_e(s, 2)
  I_3 = S_e(s, 3)
  J_e = S_e(s, 4)
  A_s = S_e(s, 5)
  F_3 = 12*E*I_3/(G*A_s*L^2)
  F_2 = 12*E*I_2/(G*A_s*L^2)
  k = zeros(12, 12)
  k(1, 1) = E*A_e/L
  k(1, 7) = -E*A_e/L
  k(7, 7) = E*A_e/L
  k(4, 4) = G*J_e/L
  k(4, 10) = -G*J_e/L
  k(10, 10) = G*J_e/L
  c3 = E*I_3/(L^3*(1 + F_3))
  k(2, 2) = 12*c3
  k(2, 6) = 6*L*c3
  k(2, 8) = -12*c3
  k(2, 12) = 6*L*c3
  k(6, 6) = (4 + F_3)*L^2*c3
  k(6, 8) = -6*L*c3
  k(6, 12) = (2 - F_3)*L^2*c3
  k(8, 8) = 12*c3
  k(8, 12) = -6*L*c3
  k(12, 12) = (4 + F_3)*L^2*c3
  c2 = E*I_2/(L^3*(1 + F_2))
  k(3, 3) = 12*c2
  k(3, 5) = -6*L*c2
  k(3, 9) = -12*c2
  k(3, 11) = -6*L*c2
  k(5, 5) = (4 + F_2)*L^2*c2
  k(5, 9) = 6*L*c2
  k(5, 11) = (2 - F_2)*L^2*c2
  k(9, 9) = 12*c2
  k(9, 11) = 6*L*c2
  k(11, 11) = (4 + F_2)*L^2*c2
  for r = 1:12
    for q = r + 1:12
      k(q, r) = k(r, q)
    end
  end
  e1x = dx/L
  e1y = dy/L
  e1z = dz/L
  if abs(dz) > 0.5*L
    R = [e1x, e1y, e1z; 1, 0, 0; 0, e1z, -e1y]
    L_l = L
  else
    n3 = sqrt(e1x^2 + e1y^2)
    R = [e1x, e1y, 0; 0, 0, 1; e1y/n3, -e1x/n3, 0]
    if abs(dx) > 0.5*L
      L_l = L - d_c(1)
    else
      L_l = L - d_c(2)
    end
  end
  T_r = zeros(12, 12)
  for p = 0:3
    for r = 1:3
      for q = 1:3
        T_r(3*p + r, 3*p + q) = R(r, q)
      end
    end
  end
  k_g = transpose(T_r)*k*T_r
  for r = 1:12
    if r <= 6
      g_r = 6*(a - 1) + r
    else
      g_r = 6*(b - 1) + r - 6
    end
    for q = 1:12
      if q <= 6
        g_q = 6*(a - 1) + q
      else
        g_q = 6*(b - 1) + q - 6
      end
      K(g_r, g_q) = K(g_r, g_q) + k_g(r, q)
    end
  end
  m_v(a) = m_v(a) + rho*A_e*L_l/2
  m_v(b) = m_v(b) + rho*A_e*L_l/2
end
#show
#: Por ejemplo, la columna 1 (L = 180 in): Φ₃ = 12·E·I₃₃/(G·A_s·L²) y el término 12·E·I/(L³·(1 + Φ)):
Phi_col = Phi(E, 5630, G, 35.833333, 180) @@(Φ de la columna en su eje fuerte)
k_c1 = k_f(E, 5630, 180, Phi_col) @@(la flexión de la columna 1, con números)
k_col = 12*E*5630/(180^3*(1 + Phi_col)) @@(kip/in: rigidez lateral de una columna biempotrada)
m_top = m_v(2) @@(kip·s²/in: masa de cada nudo de arriba)
m_col = m_nudo(rho, 43, 180) @@(lo que pone media columna)
m_vx = m_nudo(rho, 24.7, 114 - 24.7) @@(media viga en x, con luz libre)
m_vy = m_nudo(rho, 24.7, 240 - 12.9) @@(media viga en y, con luz libre)

## 6 · Las bases fijas fuera; los giros se condensan
#: Las bases no se mueven: quedan los 4 nudos de arriba (24 grados de libertad). Los giros no tienen masa, así que se **condensan** (condensación estática): K_c = K_tt − K_tr·K_rr⁻¹·K_rt, solo con las 12 traslaciones.
#hide
n_t = [2, 4, 6, 8]
K_tt = zeros(12, 12)
K_tr = zeros(12, 12)
K_rr = zeros(12, 12)
m_t = zeros(12, 1)
for i = 1:4
  for di = 1:3
    for j = 1:4
      for dj = 1:3
        K_tt(3*(i - 1) + di, 3*(j - 1) + dj) = K(6*(n_t(i) - 1) + di, 6*(n_t(j) - 1) + dj)
        K_tr(3*(i - 1) + di, 3*(j - 1) + dj) = K(6*(n_t(i) - 1) + di, 6*(n_t(j) - 1) + 3 + dj)
        K_rr(3*(i - 1) + di, 3*(j - 1) + dj) = K(6*(n_t(i) - 1) + 3 + di, 6*(n_t(j) - 1) + 3 + dj)
      end
    end
    m_t(3*(i - 1) + di) = m_v(n_t(i))
  end
end
K_c = K_tt - K_tr*inv(K_rr)*transpose(K_tr)
#show

## 7 · Los modos: K_c·φ = ω²·M·φ
#: Con D = M^(−1/2) el problema queda simétrico: A = D·K_c·D, y sus valores propios son ω². Se sacan con **Jacobi**: rotaciones que anulan uno por uno los términos de fuera de la diagonal hasta dejar A diagonal.
#hide
D_m = zeros(12, 12)
for i = 1:12
  D_m(i, i) = 1/sqrt(m_t(i))
end
A_j = D_m*K_c*D_m
V_j = zeros(12, 12)
for i = 1:12
  V_j(i, i) = 1
end
for barrido = 1:12
  for p = 1:11
    for q = p + 1:12
      if abs(A_j(p, q)) > 1e-12*(abs(A_j(p, p)) + abs(A_j(q, q)))
        th = 0.5*atan2(2*A_j(p, q), A_j(q, q) - A_j(p, p))
        c = cos(th)
        s = sin(th)
        for r = 1:12
          x_p = A_j(r, p)
          x_q = A_j(r, q)
          A_j(r, p) = c*x_p - s*x_q
          A_j(r, q) = s*x_p + c*x_q
        end
        for r = 1:12
          x_p = A_j(p, r)
          x_q = A_j(q, r)
          A_j(p, r) = c*x_p - s*x_q
          A_j(q, r) = s*x_p + c*x_q
        end
        for r = 1:12
          x_p = V_j(r, p)
          x_q = V_j(r, q)
          V_j(r, p) = c*x_p - s*x_q
          V_j(r, q) = s*x_p + c*x_q
        end
      end
    end
  end
end
o_r = zeros(12, 1)
for i = 1:12
  o_r(i) = i
end
for i = 1:11
  for j = i + 1:12
    if A_j(o_r(j), o_r(j)) < A_j(o_r(i), o_r(i))
      t_o = o_r(i)
      o_r(i) = o_r(j)
      o_r(j) = t_o
    end
  end
end
#show
f_1 = sqrt(A_j(o_r(1), o_r(1)))/(2*pi) @@(Hz · modo 1)
f_2 = sqrt(A_j(o_r(2), o_r(2)))/(2*pi) @@(Hz · modo 2)
f_3 = sqrt(A_j(o_r(3), o_r(3)))/(2*pi) @@(Hz · modo 3)
f_4 = sqrt(A_j(o_r(4), o_r(4)))/(2*pi) @@(Hz · modo 4)
f_5 = sqrt(A_j(o_r(5), o_r(5)))/(2*pi) @@(Hz · modo 5)
T_1 = 1/f_1 @@(s · periodo fundamental)

## 8 · Contra ETABS 22 (mismo modelo, kip-in)
#hide
d_1 = 100*(f_1/9.0903 - 1)
d_2 = 100*(f_2/14.9739 - 1)
d_3 = 100*(f_3/24.9465 - 1)
d_4 = 100*(f_4/25.8520 - 1)
d_5 = 100*(f_5/164.3495 - 1)
#show
#| Modo | Esta hoja [Hz] | ETABS 22 [Hz] | Diferencia [%] |
#|---:|---:|---:|---:|
#| 1 | @{f_1} | 9.0903 | @{d_1} |
#| 2 | @{f_2} | 14.9739 | @{d_2} |
#| 3 | @{f_3} | 24.9465 | @{d_3} |
#| 4 | @{f_4} | 25.8520 | @{d_4} |
#| 5 | @{f_5} | 164.3495 | @{d_5} |
#: **Lectura.** Los modos 1, 2 y 5 coinciden con ETABS a 4 decimales; el 3 y el 4, a 0,02 %. Lo que hacía falta para llegar ahí: el **corte** de la barra (A_s = 5/6·A) y la **luz libre** de las vigas en la masa. Sin corte (hoja 68) el modo 1 sale 2,2 % abajo; con la masa de las vigas completas, 2,9 % abajo.

## 9 · El modo 1, dibujado
#hide
U_1 = zeros(8, 3)
u_m = zeros(8, 1)
p_1 = D_m*V_j
for i = 1:4
  for di = 1:3
    U_1(n_t(i), di) = p_1(3*(i - 1) + di, o_r(1))
  end
end
u_x = max(max(abs(U_1)))
for i = 1:8
  for di = 1:3
    U_1(i, di) = U_1(i, di)/u_x
  end
  u_m(i) = sqrt(U_1(i, 1)^2 + U_1(i, 2)^2 + U_1(i, 3)^2)
end
desplazamiento = zeros(8, 2)
for e = 1:8
  desplazamiento(e, 1) = u_m(e_n(e, 1))
  desplazamiento(e, 2) = u_m(e_n(e, 2))
end
#show
#: El primer modo es el pórtico balanceándose en una dirección (pasa el cursor para leer cuánto se mueve cada nudo):
#modelo3d(X_n, s_q, e_n, u_m, sin_diagrama, U_1, 40)
