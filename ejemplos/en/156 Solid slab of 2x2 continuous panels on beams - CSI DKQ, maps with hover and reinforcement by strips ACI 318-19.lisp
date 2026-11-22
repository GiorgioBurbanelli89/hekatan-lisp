# Solid slab of 2 × 2 continuous panels on beams: CSI shell (DKQ + membrane with normal rotation), Mxx, Myy and Mxy maps with the cursor and reinforcement by strips (Wood-Armer, ACI 318-19, NEC-15)
#numerico
#: **What is calculated.** The slab of sheet 155 (4.00 × 4.80 m panel, 15 cm, the same load) repeated in **2 × 2 continuous panels**: 8.00 × 9.60 m with beams on all axes (A, B, C in x and 1, 2, 3 in y) and columns at the 9 crossings. What is new compared with one panel: over the interior beams the slab is **continuous** and the **negative** moment appears (tension on top), which asks for top steel on both sides of the beam. It is reinforced **by strips** as in ACI 318-19 §8.4.1.5 (column strip and middle strip) with the Wood-Armer moments averaged in each strip, as SAFE does.
#: **Element**: the CSI thin shell of sheet 155 (Batoz DKQ for bending and CSI membrane with normal rotation), 6 degrees of freedom per node. **Validation**: equilibrium (Σ reactions = load), symmetry and an **independent element**: the conforming BFS (Bogner-Fox-Schmit, the Calcpad one in sheet 77) on a 5 cm mesh, solved separately (same model, another element): for continuous panels there is no Navier series.
#: **Support model.** The beams are taken **rigid in the vertical** (w = 0 on all axes) and without torsional stiffness (free rotations): over an interior beam the continuity is given by the slab itself. The columns support the beams; the slab does not rest directly on them, so there is **no punching** (that belongs to the flat slab without beams, sheet 77). Units: tonf, m, kgf/cm²; CSI sign (M > 0 = tension at the bottom).

## 2 · Data
l_x = 4.0 [m] 'span of each panel in x (between beam axes)
l_y = 4.8 [m] 'span of each panel in y
h_l = 0.15 [m] 'thickness of the solid slab
f_c = 240 [kgf/cm²] 'concrete strength f'c
f_y = 4200 [kgf/cm²] 'yield strength of the reinforcing steel
f_cM = f_c·0.0980665 [MPa] 'f'c in MPa
E_c = 4700·sqrt(f_cM)·101.97162 [tonf/m²] 'concrete modulus, ACI 318-19 §19.2.2.1 (4700·√f'c in MPa), converted to tonf/m²
ν = 0.2 'Poisson's ratio of the concrete
γ_h = 2.4 [tonf/m³] 'unit weight of reinforced concrete
q_pp = γ_h·h_l [tonf/m²] 'self-weight of the slab
q_cm = 0.30 [tonf/m²] 'assumed superimposed dead load: finishes and masonry
q_cv = 0.204 [tonf/m²] 'residential live load, 2.0 kN/m² (NEC-SE-CG 2015)
q_D = q_pp + q_cm [tonf/m²] 'total dead load D
#: **Combinations** (NEC-SE-CG 2015 §3.4.3 = ACI 318-19 Table 5.3.1): 1.4·D and 1.2·D + 1.6·L. The larger governs:
q_u1 = 1.4·q_D [tonf/m²] 'combination 1
q_u2 = 1.2·q_D + 1.6·q_cv [tonf/m²] 'combination 2
q_u = max(q_u1, q_u2) [tonf/m²] 'ultimate design load
D_p = E_c·h_l^3/(12·(1 - ν^2)) [tonf·m] 'flexural rigidity of the plate
D_b = D_p·[1, ν, 0; ν, 1, 0; 0, 0, (1 - ν)/2] [tonf·m] 'bending behavior matrix (moments ↔ curvatures)
n_px = 2 'panels in x
n_py = 2 'panels in y
L_x = n_px·l_x [m] 'total length of the slab in x
L_y = n_py·l_y [m] 'total length in y
#: **How to read the plan.** The dash-dot lines are the beam axes (bubbles A, B, C and 1, 2, 3); the gray squares, the columns at the crossings. Each panel is that of sheet 155. The dimensions give the spans between axes.
#dibujo("Plan: 2 × 2 panels of 4.00 × 4.80 m on beams and columns", ud = m, escala = auto, cotas = m, alto = 175)
#  rect(0, 0, 8.0, 9.6, "gruesa")
#  ejesx([0, 4, 8], "A")
#  ejesy([0, 4.8, 9.6], "1")
#  rect([-0.15, 3.85, 7.85, -0.15, 3.85, 7.85, -0.15, 3.85, 7.85], [-0.15, -0.15, -0.15, 4.65, 4.65, 4.65, 9.45, 9.45, 9.45], 0.30, 0.30, "denso")
#  texto(2.0, 2.4, "panel 1", 2.5, "c")
#  texto(6.0, 2.4, "panel 2", 2.5, "c")
#  texto(2.0, 7.2, "panel 3", 2.5, "c")
#  texto(6.0, 7.2, "panel 4", 2.5, "c")
#  texto(4.0, -1.4, "h = 0.15 m · qu = {q_u:3} tonf/m² over the whole slab", 2.4, "c", estilo = "azul")
#  cotas([0, 4, 8], -0.7, -0.05)
#  cotasy([0, 4.8, 9.6], 8.7, -0.05)
#fin

## 3 · The element: CSI thin shell = DKQ (bending) + membrane with normal rotation
#: Each node of a shell has **6 degrees of freedom**: u_x, u_y, w, θx, θy, θz. A flat shell separates two problems that do not touch: **bending** (w, θx, θy: the DKQ) and the **membrane** (u_x, u_y and the normal rotation θz). Both are written, they are put together in the 24 × 24 element matrix and it is checked at the end that, in a slab without in-plane forces, the membrane does NOT change Mxx, Myy or Mxy.
#: Mesh of 0.40 m square elements: 20 in x and 24 in y (10 × 12 per panel, the mesh of sheet 155).
n_x = 20 'elements in x
n_y = 24 'elements in y
h_x = L_x/n_x [m] 'element side in x
h_y = L_y/n_y [m] 'element side in y

### 3a · Bending: Batoz and Tahar DKQ (discrete Kirchhoff, sheet 153)
#: Rotations with the right-hand rule: θx = ∂w/∂y, θy = −∂w/∂x. Coordinates of the typical element (counterclockwise nodes):
X1 = 0 [m] 'x of node 1
Y1 = 0 [m] 'y of node 1
X2 = h_x [m] 'x of node 2
Y2 = 0 [m] 'y of node 2
X3 = h_x [m] 'x of node 3
Y3 = h_y [m] 'y of node 3
X4 = 0 [m] 'x of node 4
Y4 = h_y [m] 'y of node 4
#: Sides 5 = 1-2, 6 = 2-3, 7 = 3-4, 8 = 4-1; their five coefficients a…e (those of section 1 of sheet 153):
#hide
m5 = (X1-X2)^2 + (Y1-Y2)^2
m6 = (X2-X3)^2 + (Y2-Y3)^2
m7 = (X3-X4)^2 + (Y3-Y4)^2
m8 = (X4-X1)^2 + (Y4-Y1)^2
A5 = -(X1-X2)/m5
A6 = -(X2-X3)/m6
A7 = -(X3-X4)/m7
A8 = -(X4-X1)/m8
B5 = 0.75*(X1-X2)*(Y1-Y2)/m5
B6 = 0.75*(X2-X3)*(Y2-Y3)/m6
B7 = 0.75*(X3-X4)*(Y3-Y4)/m7
B8 = 0.75*(X4-X1)*(Y4-Y1)/m8
C5 = (0.25*(X1-X2)^2 - 0.5*(Y1-Y2)^2)/m5
C6 = (0.25*(X2-X3)^2 - 0.5*(Y2-Y3)^2)/m6
C7 = (0.25*(X3-X4)^2 - 0.5*(Y3-Y4)^2)/m7
C8 = (0.25*(X4-X1)^2 - 0.5*(Y4-Y1)^2)/m8
D5 = -(Y1-Y2)/m5
D6 = -(Y2-Y3)/m6
D7 = -(Y3-Y4)/m7
D8 = -(Y4-Y1)/m8
E5 = (0.25*(Y1-Y2)^2 - 0.5*(X1-X2)^2)/m5
E6 = (0.25*(Y2-Y3)^2 - 0.5*(X2-X3)^2)/m6
E7 = (0.25*(Y3-Y4)^2 - 0.5*(X3-X4)^2)/m7
E8 = (0.25*(Y4-Y1)^2 - 0.5*(X4-X1)^2)/m8
Hx_q(n1, n2, n3, n4, n5, n6, n7, n8) = [1.5*(A5*n5 - A8*n8); B5*n5 + B8*n8; n1 - C5*n5 - C8*n8; 1.5*(A6*n6 - A5*n5); B6*n6 + B5*n5; n2 - C6*n6 - C5*n5; 1.5*(A7*n7 - A6*n6); B7*n7 + B6*n6; n3 - C7*n7 - C6*n6; 1.5*(A8*n8 - A7*n7); B8*n8 + B7*n7; n4 - C8*n8 - C7*n7]
Hy_q(n1, n2, n3, n4, n5, n6, n7, n8) = [1.5*(D5*n5 - D8*n8); -n1 + E5*n5 + E8*n8; -B5*n5 - B8*n8; 1.5*(D6*n6 - D5*n5); -n2 + E6*n6 + E5*n5; -B6*n6 - B5*n5; 1.5*(D7*n7 - D6*n6); -n3 + E7*n7 + E6*n6; -B7*n7 - B6*n6; 1.5*(D8*n8 - D7*n7); -n4 + E8*n8 + E7*n7; -B8*n8 - B7*n7]
N5x(xi, eta) = -xi*(1-eta)
N5y(xi, eta) = -0.5*(1-xi^2)
N6x(xi, eta) = 0.5*(1-eta^2)
N6y(xi, eta) = -(1+xi)*eta
N7x(xi, eta) = -xi*(1+eta)
N7y(xi, eta) = 0.5*(1-xi^2)
N8x(xi, eta) = -0.5*(1-eta^2)
N8y(xi, eta) = -(1-xi)*eta
N1x(xi, eta) = -0.25*(1-eta) - 0.5*(N8x(xi, eta) + N5x(xi, eta))
N1y(xi, eta) = -0.25*(1-xi) - 0.5*(N8y(xi, eta) + N5y(xi, eta))
N2x(xi, eta) = 0.25*(1-eta) - 0.5*(N5x(xi, eta) + N6x(xi, eta))
N2y(xi, eta) = -0.25*(1+xi) - 0.5*(N5y(xi, eta) + N6y(xi, eta))
N3x(xi, eta) = 0.25*(1+eta) - 0.5*(N6x(xi, eta) + N7x(xi, eta))
N3y(xi, eta) = 0.25*(1+xi) - 0.5*(N6y(xi, eta) + N7y(xi, eta))
N4x(xi, eta) = -0.25*(1+eta) - 0.5*(N7x(xi, eta) + N8x(xi, eta))
N4y(xi, eta) = 0.25*(1-xi) - 0.5*(N7y(xi, eta) + N8y(xi, eta))
Hxs(xi, eta) = Hx_q(N1x(xi, eta), N2x(xi, eta), N3x(xi, eta), N4x(xi, eta), N5x(xi, eta), N6x(xi, eta), N7x(xi, eta), N8x(xi, eta))
Hxh(xi, eta) = Hx_q(N1y(xi, eta), N2y(xi, eta), N3y(xi, eta), N4y(xi, eta), N5y(xi, eta), N6y(xi, eta), N7y(xi, eta), N8y(xi, eta))
Hys(xi, eta) = Hy_q(N1x(xi, eta), N2x(xi, eta), N3x(xi, eta), N4x(xi, eta), N5x(xi, eta), N6x(xi, eta), N7x(xi, eta), N8x(xi, eta))
Hyh(xi, eta) = Hy_q(N1y(xi, eta), N2y(xi, eta), N3y(xi, eta), N4y(xi, eta), N5y(xi, eta), N6y(xi, eta), N7y(xi, eta), N8y(xi, eta))
B1_q(xi, eta) = 2/h_x*Hxs(xi, eta)
B2_q(xi, eta) = 2/h_y*Hyh(xi, eta)
B3_q(xi, eta) = 2/h_y*Hxh(xi, eta) + 2/h_x*Hys(xi, eta)
#show
#: In a rectangle the Jacobian is constant: ∂/∂x = (2/h_x)·∂/∂ξ and ∂/∂y = (2/h_y)·∂/∂η. Curvatures κ = [βx,x ; βy,y ; βx,y + βy,x] = B·u and stiffness K = Σ Bᵀ·D_b·B·|J| at the 4 Gauss points ±1/√3:
g_p = 1/sqrt(3) 'coordinate of the 2 × 2 Gauss points
j_e = h_x·h_y/4 [m²] 'Jacobian |J| of the rectangle
#hide
B_G = zeros(12, 12)
r_g = [-g_p, g_p, g_p, -g_p]
s_g = [-g_p, -g_p, g_p, g_p]
K_p = zeros(12, 12)
for p = 1:4
  B_1 = transpose(B1_q(r_g(p), s_g(p)))
  B_2 = transpose(B2_q(r_g(p), s_g(p)))
  B_3 = transpose(B3_q(r_g(p), s_g(p)))
  K_p = K_p + j_e·(D_b(1, 1)·transpose(B_1)·B_1 + D_b(1, 2)·(transpose(B_1)·B_2 + transpose(B_2)·B_1) + D_b(2, 2)·transpose(B_2)·B_2 + D_b(3, 3)·transpose(B_3)·B_3)
  B_G(3·p - 2, :) = B_1
  B_G(3·p - 1, :) = B_2
  B_G(3·p, :) = B_3
end
#show
K_p11 = K_p(1, 1) [tonf/m] 'stiffness to w of node 1 (Python prototype with the same formulas: 42 573.9995)
K_p22 = K_p(2, 2) [tonf·m] 'stiffness to θx of node 1 (Python: 930.9515)

### 3b · CSI membrane with normal rotation (Allman + ITW, taken from the SAPFire binary)
#: Degrees of freedom [u_x, u_y, θz] per node. The in-plane displacement has the usual bilinear part, a **bubble** (1 − r²)(1 − s²) that is condensed and, on each side, a parabolic term that moves the rotation of the two nodes: Δu = (l/8)·(θ_j − θ_i)·n (Allman). In a rectangle, (l/8)·n of each side is:
c_x = [0, h_y/8, 0, -h_y/8] [m] 'x component of (l/8)·n of sides 1-2, 2-3, 3-4, 4-1
c_y = [-h_x/8, 0, h_x/8, 0] [m] 'y component
a_n = [4, 1, 2, 3] 'side that ARRIVES at each node (the one that leaves is the one with its same number)
D_m = E_c·h_l/(1 - ν^2)·[1, ν, 0; ν, 1, 0; 0, 0, (1 - ν)/2] [tonf/m] 'plane stress times the thickness
G_c = E_c/(2·(1 + ν)) [tonf/m²] 'shear modulus
#: B of the membrane at (r, s) (3 × 14: u, v, θ of the 4 nodes and the 2 bubbles). The θ columns are **projected** (their mean over the element is subtracted): without that the element departs 1.4 % from CSI.
#hide
r_N = [-1, 1, 1, -1]
s_N = [-1, -1, 1, 1]
M_t = zeros(3, 4)
for p = 1:4
  r_p = r_g(p)
  s_p = s_g(p)
  n_r = 0.5·[-2·r_p·(1 - s_p), 1 - s_p^2, -2·r_p·(1 + s_p), -(1 - s_p^2)]
  n_s = 0.5·[-(1 - r_p^2), -2·s_p·(1 + r_p), 1 - r_p^2, -2·s_p·(1 - r_p)]
  for i = 1:4
    k = a_n(i)
    M_t(1, i) = M_t(1, i) + (2/h_x·n_r(k)·c_x(k) - 2/h_x·n_r(i)·c_x(i))/4
    M_t(2, i) = M_t(2, i) + (2/h_y·n_s(k)·c_y(k) - 2/h_y·n_s(i)·c_y(i))/4
    M_t(3, i) = M_t(3, i) + (2/h_y·n_s(k)·c_x(k) - 2/h_y·n_s(i)·c_x(i) + 2/h_x·n_r(k)·c_y(k) - 2/h_x·n_r(i)·c_y(i))/4
  end
end
K_14 = zeros(14, 14)
for p = 1:4
  r_p = r_g(p)
  s_p = s_g(p)
  n_r = 0.5·[-2·r_p·(1 - s_p), 1 - s_p^2, -2·r_p·(1 + s_p), -(1 - s_p^2)]
  n_s = 0.5·[-(1 - r_p^2), -2·s_p·(1 + r_p), 1 - r_p^2, -2·s_p·(1 - r_p)]
  B_m = zeros(3, 14)
  for i = 1:4
    k = a_n(i)
    d_nx = 2/h_x·r_N(i)·(1 + s_N(i)·s_p)/4
    d_ny = 2/h_y·s_N(i)·(1 + r_N(i)·r_p)/4
    B_m(1, 3·i - 2) = d_nx
    B_m(2, 3·i - 1) = d_ny
    B_m(3, 3·i - 2) = d_ny
    B_m(3, 3·i - 1) = d_nx
    B_m(1, 3·i) = 2/h_x·n_r(k)·c_x(k) - 2/h_x·n_r(i)·c_x(i) - M_t(1, i)
    B_m(2, 3·i) = 2/h_y·n_s(k)·c_y(k) - 2/h_y·n_s(i)·c_y(i) - M_t(2, i)
    B_m(3, 3·i) = 2/h_y·n_s(k)·c_x(k) - 2/h_y·n_s(i)·c_x(i) + 2/h_x·n_r(k)·c_y(k) - 2/h_x·n_r(i)·c_y(i) - M_t(3, i)
  end
  B_m(1, 13) = 2/h_x·(-2·r_p·(1 - s_p^2))
  B_m(3, 13) = 2/h_y·(-2·s_p·(1 - r_p^2))
  B_m(2, 14) = 2/h_y·(-2·s_p·(1 - r_p^2))
  B_m(3, 14) = 2/h_x·(-2·r_p·(1 - s_p^2))
  K_14 = K_14 + j_e·transpose(B_m)·D_m·B_m
end
b_0 = zeros(14, 1)
for i = 1:4
  k = a_n(i)
  b_0(3·i - 2) = -0.5·2/h_y·s_N(i)·(1 + r_N(i)·0)/4
  b_0(3·i - 1) = 0.5·2/h_x·r_N(i)·(1 + s_N(i)·0)/4
  n_rk = [0, 0.5, 0, -0.5]
  n_sk = [-0.5, 0, 0.5, 0]
  b_0(3·i) = 0.5·((2/h_x·n_rk(k)·c_y(k) - 2/h_x·n_rk(i)·c_y(i)) - (2/h_y·n_sk(k)·c_x(k) - 2/h_y·n_sk(i)·c_x(i))) - 1/4
end
h_t = zeros(14, 1)
h_t(3) = 1
h_t(6) = -1
h_t(9) = 1
h_t(12) = -1
#show
#: **The two normal rotation terms** (read in the CSI binary, `CsiGo2.dll`): that of Wilson, which ties θz to the mid rotation, b₀ᵀ·u = ½·(∂v/∂x − ∂u/∂y) − ¼·Σθᵢ, with weight 0.1·G·h·A; and a rotation hourglass, h = [+1, −1, +1, −1], with weight 5·10⁻⁵·G·h·A. Then the two bubbles are condensed (K_bb − K_bα·K_αα⁻¹·K_αb):
A_e = h_x·h_y [m²] 'element area
#hide
K_14 = K_14 + 0.1·G_c·h_l·A_e·(2·b_0)·transpose(2·b_0) + 0.00005·G_c·h_l·A_e·h_t·transpose(h_t)
K_m = K_14(1:12, 1:12) - K_14(1:12, 13:14)·inv(K_14(13:14, 13:14))·K_14(13:14, 1:12)
#show
K_m11 = K_m(1, 1) [tonf/m] 'stiffness to u_x of node 1 (k_membrana_csi.py = ETABS 22: 165 387.1483)
K_m33 = K_m(3, 3) [tonf·m] 'stiffness to θz of node 1 (k_membrana_csi.py: 1 274.4360)

### 3c · The shell: 24 × 24
#: Per node [u_x, u_y, w, θx, θy, θz] (the CSI order: U1, U2, U3, R1, R2, R3). Bending goes to positions 3, 4, 5 and the membrane to 1, 2, 6; the cross blocks are zero because the element is flat.
#hide
i_p = [3, 4, 5]
i_m = [1, 2, 6]
K_c = zeros(24, 24)
for i_a = 1:4
  for i_b = 1:4
    for r = 1:3
      for s = 1:3
        K_c(6·(i_a - 1) + i_p(r), 6·(i_b - 1) + i_p(s)) = K_p(3·(i_a - 1) + r, 3·(i_b - 1) + s)
        K_c(6·(i_a - 1) + i_m(r), 6·(i_b - 1) + i_m(s)) = K_m(3·(i_a - 1) + r, 3·(i_b - 1) + s)
      end
    end
  end
end
#show
K_c33 = K_c(3, 3) [tonf/m] 'w of node 1 in the shell (= K_p11)

## 4 · Mesh, supports and load
n_n = n_x + 1 'nodes in x
n_j = (n_x + 1)·(n_y + 1) 'number of nodes
n_e = n_x·n_y 'number of elements
#hide
X_j = zeros(n_j, 1)
Y_j = zeros(n_j, 1)
for j = 1:n_y + 1
  for i = 1:n_n
    q = (j - 1)·n_n + i
    X_j(q) = (i - 1)·h_x
    Y_j(q) = (j - 1)·h_y
  end
end
e_j = zeros(n_e, 4)
for j = 1:n_y
  for i = 1:n_x
    e = (j - 1)·n_x + i
    q = (j - 1)·n_n + i
    e_j(e, 1) = q
    e_j(e, 2) = q + 1
    e_j(e, 3) = q + n_n + 1
    e_j(e, 4) = q + n_n
  end
end
s_b = zeros(n_j, 1)
for q = 1:n_j
  for k = 0:n_px
    if abs(X_j(q) - k·l_x) < 0.001
      s_b(q) = 1
    end
  end
  for k = 0:n_py
    if abs(Y_j(q) - k·l_y) < 0.001
      s_b(q) = 1
    end
  end
end
#show
#: Nodes row by row from corner A-1. **How to read it:** 0.40 m grid; the nodes on axes A, B, C and 1, 2, 3 carry the beam support (w = 0).
#malla(X_j, Y_j, e_j)
n_ap = sum(s_b) 'nodes supported on the beams
#: **The shell in its two blocks.** In sheet 155 the 24 × 24 matrix per element was assembled and it was seen that bending and membrane share no term. Here, with 525 nodes, the 3150 × 3150 matrix does not fit in the numeric engine (1 GB of memory). Since the two blocks are independent, it is enough to solve the **bending** one (w, θx, θy, 1575 equations, with K_p); the **membrane** one (u_x, u_y, θz with K_m) has no load in this horizontal slab, so its solution is exactly u = 0 (in sheet 155, with the full 24 × 24 matrix per element, it came out 0). With earthquake or in-plane forces, the membrane block would be solved the same way, with K_m.
n_g = 3·n_j 'degrees of freedom of each block
#hide
F = zeros(n_g, 1)
for e = 1:n_e
  for c = 1:4
    q = e_j(e, c)
    F(3·q - 2) = F(3·q - 2) - q_u·h_x·h_y/4
  end
end
#show
F_z = sum(F) [tonf] 'sum of the nodal loads = −q_u·L_x·L_y

## 5 · Assembly and solution
d_j(j) = 3·(j - 1) + (1:3)
d_e(e) = [d_j(e_j(e, 1)), d_j(e_j(e, 2)), d_j(e_j(e, 3)), d_j(e_j(e, 4))]
#hide
K = zeros(n_g, n_g)
#show
for e = 1:n_e
  g = d_e(e)
  K(g, g) = K(g, g) + K_p
end
#: Supports as very stiff springs k_r in w at all the beam nodes.
k_r = 10^20 'stiffness of the support spring
#hide
for q = 1:n_j
  if s_b(q) == 1
    K(3·q - 2, 3·q - 2) = K(3·q - 2, 3·q - 2) + k_r
  end
end
#show
U = clsolve(K, F) 'bending: w, θx, θy of the 525 nodes [m, rad]
#hide
K = 0
R_j = zeros(n_j, 1)
for q = 1:n_j
  if s_b(q) == 1
    R_j(q) = -k_r·U(3·q - 2)
  end
end
#show
R_t = sum(R_j) [tonf] 'sum of the beam reactions
Q_t = q_u·L_x·L_y [tonf] 'total load
d_R = round(100·(R_t - Q_t)/Q_t, 8) [%] 'difference

## 6 · Moments at the nodes (as given by SAP2000 and ETABS)
#: In each element: B of the DKQ at the 4 Gauss points, M = −D_b·B·u (CSI sign: positive = tension at the bottom), and bilinear extrapolation from Gauss to the corners; at each node the elements that meet there are averaged. The matrix R_E (12 × 12) does it all at once: moments of the 4 corners = R_E·u_e.
#hide
E_x = zeros(4, 4)
s_c = [-1, 1, 1, -1]
t_c = [-1, -1, 1, 1]
for k = 1:4
  for p = 1:4
    E_x(k, p) = 0.25·(1 + sqrt(3)·s_c(k)·r_N(p))·(1 + sqrt(3)·t_c(k)·s_N(p))
  end
end
X_E = zeros(12, 12)
D_B = zeros(12, 12)
for k = 1:4
  D_B(3·k - 2:3·k, 3·k - 2:3·k) = D_b
  for p = 1:4
    for c = 1:3
      X_E(3·(k - 1) + c, 3·(p - 1) + c) = E_x(k, p)
    end
  end
end
R_E = -X_E·D_B·B_G
M_s = zeros(n_j, 3)
c_n = zeros(n_j, 1)
for e = 1:n_e
  u_e = zeros(12, 1)
  for k = 1:4
    q = e_j(e, k)
    u_e(3·k - 2) = U(3·q - 2)
    u_e(3·k - 1) = U(3·q - 1)
    u_e(3·k) = U(3·q)
  end
  m_n = R_E·u_e
  for k = 1:4
    q = e_j(e, k)
    c_n(q) = c_n(q) + 1
    for c = 1:3
      M_s(q, c) = M_s(q, c) + m_n(3·(k - 1) + c)
    end
  end
end
for q = 1:n_j
  M_s(q, :) = M_s(q, :)/c_n(q)
end
#show
n_c1 = (n_y/4)·n_n + n_x/4 + 1 'node at the center of panel 1 (x = 2.0, y = 2.4)
n_b1 = (n_y/4)·n_n + n_x/2 + 1 'node over the beam of axis B, at mid-span (x = 4.0, y = 2.4)
n_b2 = (n_y/2)·n_n + n_x/4 + 1 'node over the beam of axis 2, at mid-span (x = 2.0, y = 4.8)
n_c4 = (3·n_y/4)·n_n + 3·n_x/4 + 1 'center of panel 4 (symmetric of 1)
w_c = 1000·U(3·n_c1 - 2) [mm] 'deflection at the center of panel 1
M_xc = M_s(n_c1, 1) [tonf·m/m] 'positive Mxx, center of panel 1
M_yc = M_s(n_c1, 2) [tonf·m/m] 'positive Myy, center of panel 1
M_xB = M_s(n_b1, 1) [tonf·m/m] 'NEGATIVE Mxx over the beam of axis B
M_y2 = M_s(n_b2, 2) [tonf·m/m] 'NEGATIVE Myy over the beam of axis 2
d_sim = abs(M_s(n_c4, 1) - M_xc) [tonf·m/m] 'symmetry: Mxx of panel 4 − panel 1

## 7 · Check with an independent element (conforming BFS)
#: The same model (2 × 2 panels, w = 0 on the axes, same load) solved separately in Python with the **BFS** (Bogner-Fox-Schmit: Hermite cubics, w and its slope continuous, the Calcpad element) on meshes of 0.20, 0.10 and 0.05 m; with 0.05 m the deflection no longer changes in the 7th digit. Values of the 0.05 m mesh:
w_BFS = -1.2176472 [mm] 'deflection at the center of panel 1, BFS 0.05 m
M_xBFS = 0.6720589 [tonf·m/m] 'Mxx center panel 1, BFS
M_yBFS = 0.4984077 [tonf·m/m] 'Myy center panel 1, BFS
M_xBBFS = -1.5148771 [tonf·m/m] 'Mxx over beam B, BFS
M_y2BFS = -1.3205699 [tonf·m/m] 'Myy over beam 2, BFS
e_w = round(100·(w_c - w_BFS)/w_BFS, 3) [%] 'deflection difference
e_Mx = round(100·(M_xc - M_xBFS)/M_xBFS, 3) [%] 'span Mxx
e_My = round(100·(M_yc - M_yBFS)/M_yBFS, 3) [%] 'span Myy
e_MxB = round(100·(M_xB - M_xBBFS)/M_xBBFS, 3) [%] 'Mxx over beam B
e_My2 = round(100·(M_y2 - M_y2BFS)/M_y2BFS, 3) [%] 'Myy over beam 2
#: **How to read it.** With 0.40 m (10 × 12 per panel, as in sheet 155) the deflection and the negatives are within ≈ 1 % of the BFS and the positive span moment within ≈ 2 % (above: safe side); refining the DKQ to 0.10 m (in Python) it drops to 0.07 %, 0.1 % and 0.13 %: both elements converge to the same value.

## 8 · Maps of Mxx, Myy and Mxy (pass the cursor: the balloon gives all at once)
#hide
W_m = zeros(n_n, n_y + 1)
M_1 = zeros(n_n, n_y + 1)
M_2 = zeros(n_n, n_y + 1)
M_3 = zeros(n_n, n_y + 1)
for j = 1:n_y + 1
  for i = 1:n_n
    q = (j - 1)·n_n + i
    W_m(i, j) = -1000·U(3·q - 2)
    M_1(i, j) = M_s(q, 1)
    M_2(i, j) = M_s(q, 2)
    M_3(i, j) = M_s(q, 3)
  end
end
#show
#: Plan of 8.00 × 9.60 m seen from above (x to the right, y upward, in meters), jet scale on the right. **When the cursor passes over**, the balloon gives (x, y) and the value of ALL the maps of this plan at that point: deflection, Mxx, Myy, Mxy and the steel of the four faces (▶ = the map below).
w_z(x, y) = spline(1 + x/h_x, 1 + y/h_y, W_m)
M_xx(x, y) = spline(1 + x/h_x, 1 + y/h_y, M_1)
M_yy(x, y) = spline(1 + x/h_x, 1 + y/h_y, M_2)
M_xy(x, y) = spline(1 + x/h_x, 1 + y/h_y, M_3)
#: **Deflection** w (mm, downward). How to read it: four «dishes», one per panel, and zero over all the beams.
#map(w_z(x, y), [0 8], [0 9.6])
#: **Mxx** (tonf·m/m). How to read it: red = positive in each panel (up to ≈ 0.75, shifted toward the exterior edge, as in the end span of a continuous beam; at the center of the panel 0.69); dark blue = the **negative** over the beam of axis B (x = 4, ≈ −1.5): there the slab passes continuous and is in tension on top. Over axes A and C (edges) it returns to zero.
#map(M_xx(x, y), [0 8], [0 9.6])
#: **Myy** (tonf·m/m). How to read it: the same in the other direction; the negative is over the beam of axis 2 (y = 4.8, ≈ −1.3).
#map(M_yy(x, y), [0 8], [0 9.6])
#: **Mxy** (tonf·m/m, twisting moment). How to read it: large at the four **exterior corners** of the slab (where two edges are simple support); next to the crossings of interior beams it is smaller, because the continuity prevents the rotation.
#map(M_xy(x, y), [0 8], [0 9.6])
#: **Cut at y = 2.40 m** (center of panels 1 and 2): Mxx along x. How to read it: two positive «bellies» in the spans and a negative peak over beam B (x = 4); zero at edges A and C. It is the diagram of a two-span continuous beam, but of a slab strip.
#hide
C_Fe = zeros(n_n, 2)
for i = 1:n_n
  C_Fe(i, 1) = (i - 1)·h_x
  C_Fe(i, 2) = M_s((n_y/4)·n_n + i, 1)
end
#show
#fplot(Mxx_y24 = C_Fe, [0 8])

## 9 · Design: Wood-Armer and steel (ACI 318-19)
r_ec = 2.0 [cm] 'clear cover (ACI 318-19 Table 20.5.1.3.1)
d_v = 1.0 [cm] 'bar diameter, Ø10
d_x = 100·h_l - r_ec - d_v/2 [cm] 'effective depth of the bars in x (outer layer)
d_y = d_x - d_v [cm] 'effective depth of the bars in y (inner layer)
φ_f = 0.9 'bending, tension-controlled section
A_smin = 0.0018·100·100·h_l [cm²/m] 'minimum, ACI 318-19 §8.6.1.1
s_max = min(2·100·h_l, 45) [cm] 'maximum spacing, ACI 318-19 §8.7.2.2
A_b = pi·d_v^2/4 [cm²] 'area of one Ø10 bar
A_req(M_u, d_c) = 0.85·f_c·100·d_c/f_y·(1 - sqrt(1 - 2·M_u·10^5/(φ_f·0.85·f_c·100·d_c^2)))
s_var(A_s) = min(floor(100·A_b/max(A_s, A_smin)/2.5)·2.5, s_max)
#hide
A_1 = zeros(n_n, n_y + 1)
A_2 = zeros(n_n, n_y + 1)
A_3 = zeros(n_n, n_y + 1)
A_4 = zeros(n_n, n_y + 1)
W_A = zeros(n_j, 4)
for q = 1:n_j
  m_x = M_s(q, 1)
  m_y = M_s(q, 2)
  m_t = abs(M_s(q, 3))
  b_x = m_x + m_t
  b_y = m_y + m_t
  if b_x < 0
    b_x = 0
    b_y = m_y + m_t^2/abs(m_x)
  end
  if b_y < 0
    b_y = 0
    b_x = m_x + m_t^2/abs(m_y)
  end
  a_x = m_x - m_t
  a_y = m_y - m_t
  if a_x > 0
    a_x = 0
    a_y = m_y - m_t^2/abs(m_x)
  end
  if a_y > 0
    a_y = 0
    a_x = m_x - m_t^2/abs(m_y)
  end
  W_A(q, 1) = max(b_x, 0)
  W_A(q, 2) = max(b_y, 0)
  W_A(q, 3) = -min(a_x, 0)
  W_A(q, 4) = -min(a_y, 0)
end
for j = 1:n_y + 1
  for i = 1:n_n
    q = (j - 1)·n_n + i
    A_1(i, j) = A_req(W_A(q, 1), d_x)
    A_2(i, j) = A_req(W_A(q, 2), d_y)
    A_3(i, j) = A_req(W_A(q, 3), d_x)
    A_4(i, j) = A_req(W_A(q, 4), d_y)
  end
end
#show
#: **Required steel maps** (cm²/m, from moment only; what stays under A_smin = 2.70 is covered by the minimum). How to read it: bottom, maximum at the center of each panel; top, a band over beam B (bars in x) and another over beam 2 (bars in y), plus the four exterior corners.
A_xi(x, y) = spline(1 + x/h_x, 1 + y/h_y, A_1)
A_yi(x, y) = spline(1 + x/h_x, 1 + y/h_y, A_2)
A_xs(x, y) = spline(1 + x/h_x, 1 + y/h_y, A_3)
A_ys(x, y) = spline(1 + x/h_x, 1 + y/h_y, A_4)
#: Bottom, bars in x:
#map(A_xi(x, y), [0 8], [0 9.6])
#: Bottom, bars in y:
#map(A_yi(x, y), [0 8], [0 9.6])
#: Top, bars in x:
#map(A_xs(x, y), [0 8], [0 9.6])
#: Top, bars in y:
#map(A_ys(x, y), [0 8], [0 9.6])

## 10 · Reinforcement by strips (ACI 318-19 §8.4.1.5)
#: **Strips.** Column strip: on each side of an axis, 0.25·min(l_x, l_y) = 1.00 m; middle strip: the rest of the panel (4.80 − 2·1.00 = 2.80 m for the bars in x; 4.00 − 2·1.00 = 2.00 m for the bars in y). In each strip the design moment is the **average** of Wood-Armer at the strip nodes (like the SAFE strips): for the positive, on each line of nodes the largest along the span is taken (in the end span the maximum is not at the center but shifted toward the exterior support, ≈ 1.6 m from it); for the negative, the section over the interior beam (x = 4, y = 4.8).
b_c = 0.25·min(l_x, l_y) [m] 'half width of the column strip
#hide
m_xp_c = 0
m_xp_m = 0
m_xn_c = 0
m_xn_m = 0
k_c = 0
k_m = 0
for j = 1:n_y/2 + 1
  y_q = (j - 1)·h_y
  q_n = (j - 1)·n_n + n_x/2 + 1
  m_pk = 0
  for i = 1:n_x/2 + 1
    m_pk = max(m_pk, W_A((j - 1)·n_n + i, 1))
  end
  if y_q < b_c + 0.001 || y_q > l_y - b_c - 0.001
    m_xp_c = m_xp_c + m_pk
    m_xn_c = m_xn_c + W_A(q_n, 3)
    k_c = k_c + 1
  end
  if y_q > b_c + 0.001 && y_q < l_y - b_c - 0.001
    m_xp_m = m_xp_m + m_pk
    m_xn_m = m_xn_m + W_A(q_n, 3)
    k_m = k_m + 1
  end
end
m_xp_c = m_xp_c/k_c
m_xp_m = m_xp_m/k_m
m_xn_c = m_xn_c/k_c
m_xn_m = m_xn_m/k_m
m_yp_c = 0
m_yp_m = 0
m_yn_c = 0
m_yn_m = 0
k_c = 0
k_m = 0
for i = 1:n_x/2 + 1
  x_q = (i - 1)·h_x
  q_n = (n_y/2)·n_n + i
  m_pk = 0
  for j = 1:n_y/2 + 1
    m_pk = max(m_pk, W_A((j - 1)·n_n + i, 2))
  end
  if x_q < b_c + 0.001 || x_q > l_x - b_c - 0.001
    m_yp_c = m_yp_c + m_pk
    m_yn_c = m_yn_c + W_A(q_n, 4)
    k_c = k_c + 1
  end
  if x_q > b_c + 0.001 && x_q < l_x - b_c - 0.001
    m_yp_m = m_yp_m + m_pk
    m_yn_m = m_yn_m + W_A(q_n, 4)
    k_m = k_m + 1
  end
end
m_yp_c = m_yp_c/k_c
m_yp_m = m_yp_m/k_m
m_yn_c = m_yn_c/k_c
m_yn_m = m_yn_m/k_m
#show
M_xpc = m_xp_c [tonf·m/m] 'bars in x, bottom, column strip (average of the span maximum)
M_xpm = m_xp_m [tonf·m/m] 'bars in x, bottom, middle strip
M_xnc = m_xn_c [tonf·m/m] 'bars in x, top over beam B, column strip
M_xnm = m_xn_m [tonf·m/m] 'bars in x, top over beam B, middle strip
M_ypc = m_yp_c [tonf·m/m] 'bars in y, bottom, column strip
M_ypm = m_yp_m [tonf·m/m] 'bars in y, bottom, middle strip
M_ync = m_yn_c [tonf·m/m] 'bars in y, top over beam 2, column strip
M_ynm = m_yn_m [tonf·m/m] 'bars in y, top over beam 2, middle strip
#: Required steel per strip (cm²/m):
A_xpc = A_req(m_xp_c, d_x) [cm²/m] 'bottom x, column
A_xpm = A_req(m_xp_m, d_x) [cm²/m] 'bottom x, middle
A_xnc = A_req(m_xn_c, d_x) [cm²/m] 'top x over B, column
A_xnm = A_req(m_xn_m, d_x) [cm²/m] 'top x over B, middle
A_ypc = A_req(m_yp_c, d_y) [cm²/m] 'bottom y, column
A_ypm = A_req(m_yp_m, d_y) [cm²/m] 'bottom y, middle
A_ync = A_req(m_yn_c, d_y) [cm²/m] 'top y over 2, column
A_ynm = A_req(m_yn_m, d_y) [cm²/m] 'top y over 2, middle
#: **Spacings** (Ø10, multiple of 2.5 cm, not below the minimum nor above s_max):
s_xpc = s_var(A_xpc) [cm] 'bottom x, column
s_xpm = s_var(A_xpm) [cm] 'bottom x, middle
s_xnc = s_var(A_xnc) [cm] 'top x over B, column
s_xnm = s_var(A_xnm) [cm] 'top x over B, middle
s_ypc = s_var(A_ypc) [cm] 'bottom y, column
s_ypm = s_var(A_ypm) [cm] 'bottom y, middle
s_ync = s_var(A_ync) [cm] 'top y over 2, column
s_ynm = s_var(A_ynm) [cm] 'top y over 2, middle
#: **Length of the top steel.** It is measured on the cut through the center of the panel: the negative moment (Mxx < 0) extends to the inflection point, at x_0 from the beam axis; ACI 318-19 §7.7.3.3 asks to continue d or 12·d_b beyond the point where it is no longer needed. The last node with negative moment counting from the beam is taken, one element is added (safe side: the zero is inside that element) and then d or 12·d_b:
#hide
x_0 = 0
f_l = 1
for k = 0:n_x/2
  q = (n_y/4)·n_n + n_x/2 + 1 - k
  if M_s(q, 1) >= 0
    f_l = 0
  end
  if f_l == 1
    x_0 = k·h_x
  end
end
y_0 = 0
f_l = 1
for k = 0:n_y/2
  q = (n_y/2 - k)·n_n + n_x/4 + 1
  if M_s(q, 2) >= 0
    f_l = 0
  end
  if f_l == 1
    y_0 = k·h_y
  end
end
#show
x_0m = x_0 [m] 'inflection point of Mxx, measured from axis B
y_0m = y_0 [m] 'inflection point of Myy, measured from axis 2
L_bx = ceil(20·(x_0 + h_x + max(d_x/100, 12·d_v/100)))/20 [m] 'length of the top bar in x on EACH side of axis B
L_by = ceil(20·(y_0 + h_y + max(d_y/100, 12·d_v/100)))/20 [m] 'same in y on each side of axis 2
#: **Exterior corners** (ACI 318-19 §8.7.3.1): top and bottom, for the largest positive moment of the panel, over l/5 = 0.96 m from the corner (as in sheet 155):
l_esq = l_y/5 [m] 'side of the corner square
s_e = s_var(max(A_xpm, A_ypm)) [cm] 'spacing at the corners
#hide
r_vx = 100·L_y/s_xpm
r_vy = 100·L_x/s_ypm
n_vx = floor(r_vx) + 1
n_vy = floor(r_vy) + 1
y_v = zeros(n_vx, 1)
x_v = zeros(n_vy, 1)
for k = 1:n_vx
  y_v(k) = (L_y - (n_vx - 1)·s_xpm/100)/2 + (k - 1)·s_xpm/100
end
for k = 1:n_vy
  x_v(k) = (L_x - (n_vy - 1)·s_ypm/100)/2 + (k - 1)·s_ypm/100
end
r_be = 100·l_esq/s_e
n_be = floor(r_be) + 1
p_e = zeros(n_be, 1)
for k = 1:n_be
  p_e(k) = 0.08 + (k - 1)·s_e/100
end
#show
n_vxm = n_vx 'bars in x along 9.60 m (each layer)
n_vym = n_vy 'bars in y along 8.00 m

#: **How to read the bottom reinforcement.** One plan for each direction (if they go together, the labels cross the bars of the other). The thin lines are ALL the bars at their real spacing; the red one with hooks is the typical bar with its label «quantity Ø diameter @ spacing». The dashed lines separate the strips: **FC** = column strip (1.00 m on each side of an axis), **FCe** = middle strip. Here all the strips give the same reinforcement because the minimum governs in all of them (table below).
#dibujo("Bottom reinforcement, bars in x (Ø10 in all strips)", ud = m, escala = auto, cotas = m, alto = 180)
#  rect(0, 0, 8.0, 9.6, "gruesa")
#  rect(0.05, y_v, 7.9, 0, "fina")
#  linea(0, 1.0, 8.0, 1.0, "trazos azul")
#  linea(0, 3.8, 8.0, 3.8, "trazos azul")
#  linea(0, 5.8, 8.0, 5.8, "trazos azul")
#  linea(0, 8.6, 8.0, 8.6, "trazos azul")
#  varillas(0.05, y_v(9), 3.95, y_v(9), n_vx, 10, s_xpm, 90, 0, 1)
#  texto(8.2, 0.5, "FC", 2.4, "i", estilo = "azul")
#  texto(8.2, 2.4, "FCe", 2.4, "i", estilo = "azul")
#  texto(8.2, 4.8, "FC", 2.4, "i", estilo = "azul")
#  texto(8.2, 7.2, "FCe", 2.4, "i", estilo = "azul")
#  texto(8.2, 9.1, "FC", 2.4, "i", estilo = "azul")
#  cotas([0, 4, 8], -0.5, -0.05)
#  cotasy([0, 1.0, 3.8, 5.8, 8.6, 9.6], -0.5, 0.05)
#fin
#dibujo("Bottom reinforcement, bars in y (Ø10 in all strips)", ud = m, escala = auto, cotas = m, alto = 180)
#  rect(0, 0, 8.0, 9.6, "gruesa")
#  rect(x_v, 0.05, 0, 9.5, "fina")
#  linea(1.0, 0, 1.0, 9.6, "trazos azul")
#  linea(3.0, 0, 3.0, 9.6, "trazos azul")
#  linea(5.0, 0, 5.0, 9.6, "trazos azul")
#  linea(7.0, 0, 7.0, 9.6, "trazos azul")
#  varillas(x_v(8), 0.05, x_v(8), 4.75, n_vy, 10, s_ypm, 90, 0, 1)
#  texto(0.5, 9.85, "FC", 2.4, "c", estilo = "azul")
#  texto(2.0, 9.85, "FCe", 2.4, "c", estilo = "azul")
#  texto(4.0, 9.85, "FC", 2.4, "c", estilo = "azul")
#  texto(6.0, 9.85, "FCe", 2.4, "c", estilo = "azul")
#  texto(7.5, 9.85, "FC", 2.4, "c", estilo = "azul")
#  cotas([0, 1, 3, 5, 7, 8], -0.5, -0.05)
#  cotasy([0, 4.8, 9.6], -0.5, 0.05)
#fin
#: **How to read the top reinforcement.** Red = TOP steel. Over the beam of axis B, bars in x of 2 × L_{bx} (centered on the axis); over the beam of axis 2, bars in y of 2 × L_{by}; at the four exterior corners, the 0.96 m square of ACI §8.7.3. The dimensions at the bottom and on the right give the length of each band; the labels go outside the slab so as not to cover bars.
#dibujo("Top reinforcement: negatives over the interior beams and corners", ud = m, escala = auto, cotas = m, alto = 180)
#  rect(0, 0, 8.0, 9.6, "gruesa")
#  linea(4.0, 0, 4.0, 9.6, "eje")
#  linea(0, 4.8, 8.0, 4.8, "eje")
#  rect(4.0 - L_bx, y_v, 2·L_bx, 0, "media rojo")
#  rect(x_v, 4.8 - L_by, 0, 2·L_by, "media rojo")
#  rect(0.03, p_e, l_esq - 0.03, 0, "media rojo")
#  rect(p_e, 0.03, 0, l_esq - 0.03, "media rojo")
#  rect(8.0 - l_esq, p_e, l_esq - 0.03, 0, "media rojo")
#  rect(8.0 - p_e, 0.03, 0, l_esq - 0.03, "media rojo")
#  rect(0.03, 9.6 - p_e, l_esq - 0.03, 0, "media rojo")
#  rect(p_e, 9.6 - l_esq, 0, l_esq - 0.03, "media rojo")
#  rect(8.0 - l_esq, 9.6 - p_e, l_esq - 0.03, 0, "media rojo")
#  rect(8.0 - p_e, 9.6 - l_esq, 0, l_esq - 0.03, "media rojo")
#  cota(4.0 - L_bx, -0.45, 4.0 + L_bx, -0.45, -0.05, "2 × {L_bx:2}")
#  cota(8.45, 4.8 - L_by, 8.45, 4.8 + L_by, -0.05, "2 × {L_by:2}")
#  cota(0, -1.15, 8.0, -1.15, -0.05, "8.00")
#  texto(4.0, -1.75, "over axis B: Ø10 @ {s_xnm:1} cm in x · over axis 2: Ø10 @ {s_ynm:1} cm in y", 2.4, "c", estilo = "rojo")
#  texto(4.0, -2.20, "corners: {n_be:0} Ø10 @ {s_e:1} cm in x and in y (0.96 × 0.96 m)", 2.4, "c", estilo = "rojo")
#fin

## 11 · Summary
#hide
r_wc = round(w_c, 4)
r_wB = round(w_BFS, 4)
r_Mx = round(M_xc, 4)
r_MxB = round(M_xBFS, 4)
r_My = round(M_yc, 4)
r_MyB = round(M_yBFS, 4)
r_Mn = round(M_xB, 4)
r_MnB = round(M_xBBFS, 4)
r_Mn2 = round(M_y2, 4)
r_Mn2B = round(M_y2BFS, 4)
r_R = round(R_t, 4)
t_1 = round(A_xpc, 2)
t_2 = round(A_xnc, 2)
t_3 = round(A_ypc, 2)
t_4 = round(A_ync, 2)
t_5 = round(A_xpm, 2)
t_6 = round(A_xnm, 2)
t_7 = round(A_ypm, 2)
t_8 = round(A_ynm, 2)
r_Q = round(Q_t, 4)
#show
#| Magnitud | Hekatan LISP (cáscara CSI, 0.40 m) | Referencia | Diferencia |
#|---|---:|---:|---:|
#| flecha centro paño 1 [mm] | @{r_wc} | BFS 0.05 m: @{r_wB} | @{e_w} % |
#| Mxx centro paño 1 [tonf·m/m] | @{r_Mx} | BFS: @{r_MxB} | @{e_Mx} % |
#| Myy centro paño 1 [tonf·m/m] | @{r_My} | BFS: @{r_MyB} | @{e_My} % |
#| Mxx sobre viga B [tonf·m/m] | @{r_Mn} | BFS: @{r_MnB} | @{e_MxB} % |
#| Myy sobre viga 2 [tonf·m/m] | @{r_Mn2} | BFS: @{r_Mn2B} | @{e_My2} % |
#| suma de reacciones [tonf] | @{r_R} | q_u·L_x·L_y = @{r_Q} | @{d_R} % |
#: **Strips** (average Wood-Armer moment → required steel → Ø10 spacing):
#| Franja | abajo x [cm²/m] | arriba x sobre B [cm²/m] | abajo y [cm²/m] | arriba y sobre 2 [cm²/m] |
#|---|---:|---:|---:|---:|
#| de columna (FC) | @{t_1} → @{s_xpc} cm | @{t_2} → @{s_xnc} cm | @{t_3} → @{s_ypc} cm | @{t_4} → @{s_ync} cm |
#| central (FCe) | @{t_5} → @{s_xpm} cm | @{t_6} → @{s_xnm} cm | @{t_7} → @{s_ypm} cm | @{t_8} → @{s_ynm} cm |
#: **Reading.** The column strip asks for little: with rigid beams, what goes «to the column» is collected by the beam. The middle strip is the one that works; even so, in this 15 cm slab with spans of 4-4.8 m the **minimum steel** (2.70 cm²/m) covers everything except the negatives of the middle strip (2.84 over beam B and 2.77 over beam 2), which are just met with Ø10 @ 27.5 cm = 2.86 cm²/m. If the spans grow or the load rises, the table changes by itself: everything comes out of the maps.
