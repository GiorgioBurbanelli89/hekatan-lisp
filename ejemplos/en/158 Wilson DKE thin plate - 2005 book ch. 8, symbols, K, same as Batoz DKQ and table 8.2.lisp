# Wilson DKE thin plate (Discrete Kirchhoff Element, 2005 book, ch. 8) · 4-node quadrilateral: symbols, K, Batoz and book tables
#numerico
#: **Whose it is.** The DKE is by E. L. Wilson, *Three-Dimensional Static and Dynamic Analysis of Structures* (2005 ed.), ch. 8, §8.8, p. 8-10, eq. (8.21). It is not Batoz's: the Batoz and Tahar DKQ (1982) reaches the SAME matrix by another path (measured below, section 5). The equations are read from the pages of the 2005 PDF (`registros/libros/wilson_cap8_2005/p-03…p-10.png`). Three degrees of freedom per node: w, θx = ∂w/∂y, θy = −∂w/∂x.

## 0 · From the differential equation to the weak form
#: Kirchhoff thin plate: D·∇⁴w = q with D = E·h³/(12·(1 − ν²)). Boundaries: essential (w, ∂w/∂n) and natural (Mn, Vn). Multiplying by δw and integrating by parts twice gives the virtual work ∫ δψᵀ·D·ψ dA = ∫ δw·q dA: curvatures only. The element approximates them with the rotations, not with w.

## 1 · Symbols (p. 8-3 to 8-7)
#: **Rotations** (8.1): θ = Σ N_i·θ_i (4 bilinear) + Σ N_m·Δθ_m (4 hierarchical edge functions). Functions (8.2):
N_1 = Simplify{(1-r)*(1-s)/4}
N_5 = Simplify{(1-r^2)*(1-s)/2}
N_6 = Simplify{(1+r)*(1-s^2)/2}
#: **Only the rotation normal to the side** (8.3): Δθx = sin α·Δθ, Δθy = −cos α·Δθ. With that (8.4) leaves 12 + 4 unknowns.
#: **Curvatures** (8.10) with ux = z·θy, uy = −z·θx (8.5): ψxx = θy,x · ψyy = −θx,y · ψxy = θy,y − θx,x.
#: **Kirchhoff on each side** (8.20)-(8.21): w cubic along the side and zero side shear. The midpoint rotation stops being an unknown:
dtheta = Simplify{3/(2*L)*(w_j - w_i) - 3/4*(t_i + t_j)}
#: with t_i = sin α·θx_i − cos α·θy_i, the normal rotation of node i (8.7). **Constitutive matrix** (8.15):
D_11 = Simplify{E*h^3/(12*(1-nu^2))}
#: D12 = ν·D11 and D33 = (1 − ν)/2·D11. Stiffness (8.12): K = Σ bᵀ·D·b·det J at 2 × 2 Gauss points (§8.9, p. 8-10: «a four-point numerical integration formula»).

## 2 · Data (any quadrilateral)
E = 25000000 [kN/m²] 'modulus of elasticity
ν = 0.2 'Poisson's ratio (unitless)
h = 0.1 [m] 'thickness
X_e = [0, 0; 2, 0.2; 2.2, 1.8; 0.1, 1.6] [m] 'x, y coordinates of nodes 1 to 4 (counterclockwise)
D_p = E·h^3/(12·(1 - ν^2)) [kN·m] 'flexural rigidity
D_b = D_p·[1, ν, 0; ν, 1, 0; 0, 0, (1 - ν)/2] [kN·m] 'moment-curvature matrix (8.15)

## 3 · Sides and the Kirchhoff constraint (8.21)
#: Side m = from node m to the next. Length L, sin α and cos α; row m of T gives Δθ_m = T(m, :)·u:
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
L_1 = L_l(1) [m] 'length of side 1 (nodes 1-2)
T_11 = T(1, 1) 'coefficient of w₁ in Δθ of side 1, in 1/m (= −3/(2·L))

## 4 · Stiffness K = Σ bᵀ·D·b·det J (Gauss 2 × 2)
g_p = 1/sqrt(3) 'coordinate of the Gauss points
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
K_e11 = K_e(1, 1) [kN/m] 'stiffness to w of node 1
K_e22 = K_e(2, 2) [kN·m] 'stiffness to θx of node 1
K_e33 = K_e(3, 3) [kN·m] 'stiffness to θy of node 1
u_r = [1; 0; 0; 1; 0; 0; 1; 0; 0; 1; 0; 0]
f_r = max(abs(K_e·u_r)) [kN] 'force of a rigid translation (zero)

## 5 · Against Python (placas_wilson.k_dke) and against the Batoz DKQ
#: Diagonal and first row of k_dke from hekatan-struct-py with the same data. And k_dke = k_dkq of Batoz-Tahar to 4·10⁻¹⁶ (test_placas_wilson.py, 16 cases: square, rectangle, irregular, trapezoid × ν = 0 … 0.45): **the same element**.
d_py = [7316.316784471; 3661.405538313; 2281.039535151; 7168.746741566; 3780.940266517; 2501.975814690; 6982.039202437; 3679.477152456; 2278.977831937; 7127.738672020; 3911.752240946; 2422.958917080] 'diagonal of k_dke in Python (kN/m and kN·m)
f_py = [7316.316784471; 3856.202257218; -2179.058584267; -812.560357329; 1878.516215411; -1805.204897334; -1672.510434950; 1642.638193336; -877.230701348; -4831.245992192; 3525.667775918; -926.274087820] 'first row of k_dke in Python
#hide
d_h = zeros(12, 1)
f_h = zeros(12, 1)
for i = 1:12
  d_h(i) = K_e(i, i)
  f_h(i) = K_e(1, i)
end
#show
e_py = max(max(abs(d_h - d_py)), max(abs(f_h - f_py)))/max(abs(d_py)) 'largest relative difference sheet − Python

## 6 · Book tables 8.2: quarter of a square plate, point load (p. 8-12)
#: 10 × 10 simply supported plate, P = 1 at the center, E = 10.92, ν = 0.3 (so D = h³ and w·h³ = w·D). A quarter (5 × 5) is modeled with 4 × 4 elements: w = 0 on the supported edges with the rotation along the edge zero («hard» edge), θy = 0 at x = 5 and θx = 0 at y = 5 (symmetry). With h = 1 the DKE does not depend on h.
E_t = 10.92 'modulus of the book example (unitless)
ν_t = 0.3 'Poisson's ratio of the example
n_m = 4 'elements per side of the quarter plate
a_t = 5 'side of the quarter plate
D_t = E_t/(12·(1 - ν_t^2))·[1, ν_t, 0; ν_t, 1, 0; 0, 0, (1 - ν_t)/2] 'moment-curvature matrix with h = 1
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
w_c = U(3·n_j - 2) 'center deflection times h³ (unitless: D = h³)
w_lib = 1.195 'book table 8.2, DKE 4 × 4
e_w = round(100·(w_c - w_lib)/w_lib, 3) [%] 'sheet versus book
w_py = 1.1937204785866729 'cuadrante_placa_cuadrada("dke", 1, 4) in Python
M_cc = M_c 'Mxx at the center (Gauss 2 × 2 extrapolated to the node)
M_lib = 0.3545 'table 8.2, DKE
M_py = 0.37532795851200246 'the same Mxx in Python (momentos("dke", …, "nudos"))
e_Mpy = abs(M_cc - M_py)/M_py 'relative difference sheet − Python in the moment
#: **How to read it.** The deflection matches the book to 0.1 % and Python to 10⁻¹⁰; with 16 × 16 (table 8.3) the deflection gives 1.1630 = 1.163 of the book. The maximum moment of the book (0.3545) is not reproduced by any recovery tried (extrapolated node 0.3753, Gauss 0.2848, center 0.1939): the book does not say where it evaluates it. The exact Kirchhoff deflection is 1.160.
