# Plate with Wilson's DSE shear (Discrete Shear Element, 2005 book, ch. 8) · 4-node quadrilateral: symbols, 16 × 16 K, condensation and book tables
#numerico
#: **Whose it is.** The DSE is by E. L. Wilson, *Three-Dimensional Static and Dynamic Analysis of Structures* (2005 ed.), ch. 8, §8.2-8.6, p. 8-2 to 8-9; the reference it cites is Ibrahimbegović (1993), CMAME 110, 195-209. It is not by Batoz. Equations read from the pages of the 2005 PDF (`registros/libros/wilson_cap8_2005/p-03…p-10.png`). It serves for thin and thick plates: it includes transverse shear. DOF per node: w, θx, θy (θx = ∂w/∂y, θy = −∂w/∂x when the shear is zero).
#: **Measured:** the DSE is NOT the Shell-Thick of SAP2000 and ETABS (ingenieria-inversa/csi_shellthick/k_grueso_cuad.py): their K differ by the order of K itself. The CSI Thick uses side rotations with two components, a bubble, 8 integration points and a penalty that the book does not include.

## 0 · From the differential equation to the weak form
#: Reissner-Mindlin plate: equilibrium ∇·M − Q = 0 and ∇·Q + q = 0, with Q = (5/6)·G·h·γ. Essential boundaries (w, rotations) and natural ones (Mn, Mns, Vn). Integrating by parts with (δw, δθ) leaves ∫ δψᵀ·D_b·ψ dA + ∫ δγᵀ·D_s·γ dA = ∫ δw·q dA: curvatures and shears.

## 1 · Symbols (p. 8-3 to 8-9)
#: **Rotations** (8.1)-(8.4): 4 bilinear + 4 hierarchical side ones, only with the rotation NORMAL to the side (Δθx = sin α·Δθ, Δθy = −cos α·Δθ):
N_5 = Simplify{(1-r^2)*(1-s)/2}
#: **Shear along the side** (8.6)-(8.7), with w cubic on the side; the 2/3 is the mean of N_m along the side:
g_lado = Simplify{(w_j - w_i)/L - (t_i + t_j)/2 - 2/3*Dt}
#: **Shears at node i** (8.8)-(8.9) from the two sides that meet there (ij and ki), and bilinear to the Gauss point:
#: [γxz; γyz]_i = 1/det·[sin α_ki, −cos α_ki; −sin α_ij, cos α_ij]·[γ_ij; γ_ki], det = cos α_ij·sin α_ki − cos α_ki·sin α_ij.
#: **Curvatures** (8.10): ψxx = θy,x · ψyy = −θx,y · ψxy = θy,y − θx,x. **Patch test** (8.17): from the columns of the Δθ their mean over the area is subtracted, b12 ← b12 − (1/A)·∫ b12 dA.
#: **Constitutive behavior** (8.15):
D_44 = Simplify{5*E*h/(12*(1+nu))}
#: **Stiffness** (8.18): 16 × 16 K = Σ (bᵀ·D_b·b + b_sᵀ·D_s·b_s)·det J at 2 × 2 points; **condensation** (8.19) of the 4 Δθ (their forces are zero): K = K₁₁ − K₁₂·K₂₂⁻¹·K₂₁.

## 2 · Data (any quadrilateral)
E = 25000000 [kN/m²] 'modulus of elasticity
ν = 0.2 'Poisson's ratio (unitless)
h = 0.1 [m] 'thickness
X_e = [0, 0; 2, 0.2; 2.2, 1.8; 0.1, 1.6] [m] 'x, y coordinates of nodes 1 to 4 (counterclockwise)
D_b = E·h^3/(12·(1 - ν^2))·[1, ν, 0; ν, 1, 0; 0, 0, (1 - ν)/2] [kN·m] 'moment-curvature matrix (8.15)
D_s = 5·E·h/(12·(1 + ν))·[1, 0; 0, 1] [kN/m] 'shear-distortion matrix (8.15)

## 3 · Sides, side shears and node shears
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
L_1 = L_l(1) [m] 'length of side 1 (nodes 1-2)
G_116 = G_l(1, 13) 'coefficient of Δθ in the shear of side 1 (−2/3)

## 4 · 16 × 16 stiffness and condensation
g_p = 1/sqrt(3) 'coordinate of the Gauss points
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
A_ee = A_e [m²] 'element area (sum of det J at the 4 points)
K_e11 = K_e(1, 1) [kN/m] 'stiffness to w of node 1 (condensed)
K_e22 = K_e(2, 2) [kN·m] 'stiffness to θx of node 1
K_e33 = K_e(3, 3) [kN·m] 'stiffness to θy of node 1
u_r = [1; 0; 0; 1; 0; 0; 1; 0; 0; 1; 0; 0]
f_r = max(abs(K_e·u_r)) [kN] 'force of a rigid translation (zero)

## 5 · Against Python (placas_wilson.k_dse)
d_py = [6210.794611392; 3709.327116153; 2427.109959579; 6092.439194942; 4067.779915679; 2893.671675155; 5905.714454676; 3673.675408656; 2427.190495833; 6022.974188413; 4149.708362013; 2817.669446084] 'diagonal of k_dse in Python (kN/m and kN·m)
f_py = [6210.794611392; 3733.111537893; -2102.165213378; 203.488517856; 1758.140145436; -1917.944209630; -2671.596398284; 1692.853710621; -980.305634986; -3742.686730964; 3572.369188932; -844.388655616] 'first row of k_dse in Python
#hide
d_h = zeros(12, 1)
f_h = zeros(12, 1)
for i = 1:12
  d_h(i) = K_e(i, i)
  f_h(i) = K_e(1, i)
end
#show
e_py = max(max(abs(d_h - d_py)), max(abs(f_h - f_py)))/max(abs(d_py)) 'largest relative difference sheet − Python

## 6 · Book Table 8.2: quarter of a square plate, point load (p. 8-12)
#: 10 × 10 plate, P = 1 at the center, E = 10.92, ν = 0.3 (D = h³); quarter plate 5 × 5 with 4 × 4 elements, "hard" edge (w = 0 and rotation along the edge zero, p. 8-11: "this hard boundary condition is required for the DSE") and symmetry. Two thicknesses: h = 1 (thick plate) and h = 0.01 (thin).
E_t = 10.92 'modulus of the book example (unitless)
ν_t = 0.3 'Poisson's ratio of the example
n_m = 4 'elements per side of the quarter plate
h_v = [1, 0.01] 'thicknesses of the table
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
w_h1 = w_t(1) 'center deflection times h³ with h = 1 (unitless)
w_lib1 = 1.383 'book table 8.2, DSE, h = 1
w_py1 = 1.3817524554356204 'Python, cuadrante_placa_cuadrada("dse", 1, 4)
w_h2 = w_t(2) 'center deflection times h³ with h = 0.01
w_lib2 = 1.218 'book table 8.2, DSE, h = 0.01
w_py2 = 1.2162457556027133 'Python, cuadrante_placa_cuadrada("dse", 0.01, 4)
e_lib = round(100·max(abs(w_h1 - w_lib1)/w_lib1, abs(w_h2 - w_lib2)/w_lib2), 3) [%] 'largest difference sheet − book
e_py = max(abs(w_h1 - w_py1)/w_py1, abs(w_h2 - w_py2)/w_py2) 'largest difference sheet − Python
#: **How to read it.** The DSE reproduces table 8.2 to 0.15 % and table 8.3 (16 × 16: 1.3929 and 1.1648 against 1.393 and 1.164) in Python. With h = 1 the shear softens the plate by 14 %; with h = 0.01 the DSE tends to the DKE (1.1937) without locking. The exact Kirchhoff deflection is 1.160.
