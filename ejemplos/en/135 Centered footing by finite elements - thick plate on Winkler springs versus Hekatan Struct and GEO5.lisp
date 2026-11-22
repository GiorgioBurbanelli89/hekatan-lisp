# Centered footing by finite elements: thick plate on Winkler springs, versus Hekatan Struct and GEO5
#numerico

#: **What is computed.** The 1.20 × 1.20 × 0.40 m footing of the official GEO5 Spread Footing example **Demo01.gpa** (sheets 104 and 105), now the way a structural program does it: the footing is a **plate** divided into finite elements and the soil is a cushion of **springs** (Winkler). The result is the contact pressure node by node, the deflection and the rotation.
#: **With what.** The formulation of **Hekatan Struct**: its thick shell (the CSI Shell-Thick) and its area spring distributed to the nodes, compression only. The sheet writes out the whole element and solves it; then it compares **node by node** with Struct running the same model (same .heks, same mesh) and with GEO5 (analytical: Meyerhof and oedometric settlement).
#: Units: kN, m, kPa (= kN/m²), like GEO5; the subgrade modulus also in tonf/m³.

## 1 · Data (GEO5 Demo01, sheets 104 to 106)

l_x = 1.2 'footing side in x [m]
l_y = 1.2 'footing side in y [m]
t_z = 0.4 'footing depth (thickness) [m]
c_x = 0.4 'column side [m]
d_f = 1.2 'depth of the bottom from the ground surface [m]
E_c = 30000000 'modulus of C20/25 concrete from GEO5, 30 000 MPa [kPa]
ν = 0.2 'Poisson's ratio (the one Hekatan Struct uses in shells)
γ_1 = 17.5 'unit weight of soil 1 [kN/m3]
N_1 = 3000 'column axial load, load 1 [kN]
M_x = -2 'moment about x, load 1 [kN·m]
M_y = 70 'moment about y, load 1 [kN·m]
H_x = 14 'horizontal in x, load 1 [kN]
H_y = 5 'horizontal in y, load 1 [kN]
G_z = 13.248 'footing weight, 1.2·1.2·0.4·23 (sheet 104) [kN]
Z_r = 20.48 'weight of the backfill over the footing (sheet 104) [kN]
V_d = N_1 + G_z + Z_r 'total vertical load at the bottom [kN]

#: The resultant falls at e_{x} from the center (sheet 104: the moment M_{y} and the horizontal H_{x} through the depth); in y the two terms cancel:
e_x = (-M_y + H_x·t_z)/V_d 'eccentricity in x (GEO5: −0.021) [m]
e_y = (M_x + H_y·t_z)/V_d 'eccentricity in y [m]

## 1b · The footing drawn, with its loads and dimensions

#: **How to read it.** Two scaled views, in meters. **Plan:** the thick square is the 1.20 × 1.20 m footing; the gray square, the 0.40 × 0.40 m column (the column is at the **center** of the footing). The red arrows are the horizontal loads of load 1 (H_{x} = 14 kN and H_{y} = 5 kN) and N = 3000 kN goes down along the column axis; M_{y} = 70 kN·m and M_{x} = −2 kN·m rotate it. The green cross marks the **resultant** at the bottom: it is at e_{x} = -0.021 m and e_{y} = +0.000 m from the center. **Section:** the 0.40 m footing buried 1.20 m below the ground surface, resting on **Winkler springs** (vertical blue lines: every mesh node carries one and it only works in compression).
#dibujo("Plan: centered footing of 1.20 × 1.20 m, column of 0.40 m, loads of load 1 and resultant", ud = m, escala = auto, cotas = m, alto = 150)
#  rect(-l_x/2, -l_y/2, l_x, l_y, "gruesa")
#  achurado(-l_x/2, -l_y/2, l_x, l_y, "concreto")
#  rect(-0.200, -0.200, c_x, c_x, "denso")
#  linea(-0.8, 0, 0.8, 0, "eje")
#  linea(0, -0.8, 0, 0.8, "eje")
#  circulo(0.000, 0.000, 0.05, "rojo")
#  flecha(0.000, 0.000, 0.280, 0.000, "rojo")
#  flecha(0.000, 0.000, 0.000, 0.100, "rojo")
#  texto(0.300, -0.100, "Hx", 2.5, "i")
#  texto(0.050, 0.160, "Hy", 2.5, "i")
#  texto(0.050, -0.280, "N = 3000 kN", 2.5, "i")
#  linea(-0.061, 0.000, 0.019, 0.000, "media verde")
#  linea(-0.021, -0.040, -0.021, 0.040, "media verde")
#  texto(-0.021, -0.120, "resultant", 2.5, "c", estilo = "verde")
#  cota(-l_x/2, -0.82, l_x/2, -0.82, -0.05, "1.20")
#  cota(0.82, -l_y/2, 0.82, l_y/2, 0.05, "1.20")
#  cota(-0.200, 0.82, 0.200, 0.82, 0.05, "0.40")
#fin
#dibujo("Section: 0.40 m footing at 1.20 m depth on Winkler springs (blue lines)", ud = m, escala = auto, cotas = m, alto = 130)
#  linea(-1.6, 0, 1.6, 0, "media verde")
#  rect(-l_x/2, -d_f, l_x, t_z, "gruesa")
#  achurado(-l_x/2, -d_f, l_x, t_z, "concreto")
#  rect(-0.200, -d_f + t_z, c_x, d_f - t_z + 0.6, "gruesa")
#  linea(-1.6, -d_f, -l_x/2, -d_f, "trazos")
#  linea(l_x/2, -d_f, 1.6, -d_f, "trazos")
#  linea(-0.55, -d_f, -0.55, -d_f - 0.3, "media azul")
#  linea(-0.35, -d_f, -0.35, -d_f - 0.3, "media azul")
#  linea(-0.15, -d_f, -0.15, -d_f - 0.3, "media azul")
#  linea(0.05, -d_f, 0.05, -d_f - 0.3, "media azul")
#  linea(0.25, -d_f, 0.25, -d_f - 0.3, "media azul")
#  linea(0.45, -d_f, 0.45, -d_f - 0.3, "media azul")
#  flecha(0.000, 0.95, 0.000, -d_f + t_z + 0.62, "rojo")
#  texto(0.050, 1.0, "N = 3000 kN", 2.5, "i")
#  flecha(-0.450, 0.4, -0.200, 0.4, "rojo")
#  texto(-0.450, 0.5, "Hx = 14 kN", 2.5, "i")
#  texto(0.9, -d_f - 0.2, "springs k_s", 2.5, "i", estilo = "azul")
#  cota(1.0, -d_f, 1.0, 0, 0.1, "1.20")
#  cota(-0.8, -d_f, -0.8, -d_f + t_z, -0.1, "0.40")
#  cota(-l_x/2, -d_f - 0.45, l_x/2, -d_f - 0.45, -0.05, "1.20")
#fin
#: **What they show.** The plan tells where the load falls with respect to the center: the more eccentric the resultant, the less compressed soil area (in the centered footing the pressure is almost uniform because e is small). The section tells why the finite element model rests on compression-only springs: the bottom is at 1.20 m depth and the soil only pushes.

## 2 · The subgrade modulus k_{s}: where it comes from

#: **Winkler** replaces the soil with a cushion of independent springs: the pressure at a point is proportional to how much that point goes down, p = k_{s}·w (the line y = m·x with slope m = k_{s}). GEO5 does not use springs: it computes the settlement with the oedometric modulus, layer by layer (sheet 105). That is why k_{s} **is not a soil property**: it has to be chosen.
#: **Criterion of these sheets:** k_{s} is calibrated with GEO5. The footing, under service load 3 (N = 1500 kN, the settlement one), is required to go down on average what GEO5 says: k_{s} = net pressure / settlement.
N_3 = 1500 'axial load of load 3, the settlement one [kN]
q_n = (N_3 + G_z + Z_r)/(l_x·l_y) - γ_1·d_f 'net pressure of load 3 (sheet 105) [kPa]
s_G = 0.0159 'GEO5 settlement with load 3 [m]
k_s = q_n/s_G 'subgrade modulus [kN/m3]
k_t = k_s/9.80665 'the same in tonf/m3
#: About 6 700 tonf/m³ (6.7 kgf/cm³): a dense sand / gravel value, consistent with soil 1 (φ = 31.5°) over a very stiff layer (E_{def} = 1000 MPa) at 3 m. With this criterion the **average** settlement matches GEO5 by construction; what the finite element adds is **how the pressure is distributed** and the rotation. The sensitivity to k_{s} is measured at the end.


## 3 · Finite element mesh

#: Regular mesh of 10 cm square elements. The nodes are numbered as in the .heks of Hekatan Struct: row by row, from x = −0.6 to 0.6 and from y = −0.6 upward. That way the comparison is **node by node**.
h_e = 0.1 'side of each element [m]
n_x = round(l_x/h_e) 'elements per side
n_n = n_x + 1 'nodes per side
n_j = n_n^2 'number of nodes
n_e = n_x^2 'number of elements
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


## 4 · The element: the thick plate of Hekatan Struct

#: Hekatan Struct models the footing with its **thick shell** (`shelltype thick`), which is the **CSI Shell-Thick** (ETABS, SAP2000, SAFE) extracted from the binary and checked to 1e-12 % against the ETABS stiffness (code: `getBendingK_CSI` in `hekatan-fem/src/cpp/utils/shellQ4.cpp`). Here **the same element** is written out, step by step. Mindlin-Reissner plate: the deflection w and the rotations θ_{x}, θ_{y} are independent (shear deformation enters, which in a 40 cm footing over 1.2 m is not negligible).
#: **Degrees of freedom.** 3 per node, [w, θ_{x}, θ_{y}], right-hand rotations. Plus **10 internal ones** that are condensed out: the rotations are interpolated with 9 functions (4 bilinear node functions, 4 «edge» functions that are zero at the corners and 1 bubble), each with two components: 12 + 8 + 2 = 22.
a_e = h_e 'element side in x [m]
b_e = h_e 'element side in y [m]
D_0 = E_c·t_z^3/(12·(1 - ν^2)) 'flexural rigidity of the plate [kN·m]
D_b = D_0·[1, ν, 0; ν, 1, 0; 0, 0, (1 - ν)/2] 'bending: moments ↔ curvatures [kN·m]
D_s = 5/6·E_c·t_z/(2·(1 + ν))·eye(2) 'shear: Q ↔ γ, with κ = 5/6 [kN/m]
D_tr = trace(D_b) 'sum of the diagonal of D_b, for the penalty [kN·m]
P_n = 1000 'CSI penalty factor (from the binary)

#: **The 9 rotation functions** in natural coordinates r, s (between −1 and 1). Their derivatives with respect to r and s, in this order: N₁…N₄ bilinear, N₅…N₈ edge functions (N₅ = (1 − r²)(1 − s)/2 …) and N₉ = (1 − r²)(1 − s²), the bubble:
d_r(r, s) = [-(1 - s)/4, (1 - s)/4, (1 + s)/4, -(1 + s)/4, -r·(1 - s), (1 - s^2)/2, -r·(1 + s), -(1 - s^2)/2, -2·r·(1 - s^2)]
d_s(r, s) = [-(1 - r)/4, -(1 + r)/4, (1 + r)/4, (1 - r)/4, -(1 - r^2)/2, -s·(1 + r), (1 - r^2)/2, -s·(1 - r), -2·s·(1 - r^2)]
#: Each function moves two columns of the 22 dof: the one for the rotation θ_{x} and the one for θ_{y}. P_{x} and P_{y} (9 × 22) say which: function 1 → columns 2 and 3 (θ_{x1}, θ_{y1}), … function 5 → internal 13 and 14, … bubble → 21 and 22.
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
#: **Curvatures** (chain rule in a rectangle: ∂/∂x = (2/a)·∂/∂r, ∂/∂y = (2/b)·∂/∂s). With right-hand rotations: κ_{x} = ∂θ_{y}/∂x, κ_{y} = −∂θ_{x}/∂y, 2κ_{xy} = ∂θ_{y}/∂y − ∂θ_{x}/∂x. The matrix B_{b} (3 × 22):
B_b(r, s) = [2/a_e·transpose(d_r(r, s))·P_y; -2/b_e·transpose(d_s(r, s))·P_x; 2/b_e·transpose(d_s(r, s))·P_y - 2/a_e·transpose(d_r(r, s))·P_x]
#: **Divergence of the rotations** ∂θ_{x}/∂x + ∂θ_{y}/∂y: CSI penalizes it with 1000·tr(D_{b}) (it is in the binary; without it K is not the ETABS one):
v_d(r, s) = 2/a_e·transpose(d_r(r, s))·P_x + 2/b_e·transpose(d_s(r, s))·P_y
#: **Shear: the 4 edge shears** (Wilson, ch. 8, eq. 8.7). On each edge, γ = slope of the deflection + mean rotation + 2/3 of the edge mode. Edge 1 (bottom, from 1 to 2), edge 2 (right), edge 3 (top, from 3 to 4) and edge 4 (left), as rows over the 22 dof:
l_1 = [-1/a_e, 0, 1/2, 1/a_e, 0, 1/2, 0, 0, 0, 0, 0, 0, 0, 2/3, 0, 0, 0, 0, 0, 0, 0, 0]
l_2 = [0, 0, 0, -1/b_e, -1/2, 0, 1/b_e, -1/2, 0, 0, 0, 0, 0, 0, -2/3, 0, 0, 0, 0, 0, 0, 0]
l_3 = [0, 0, 0, 0, 0, 0, -1/a_e, 0, -1/2, 1/a_e, 0, -1/2, 0, 0, 0, 0, 0, -2/3, 0, 0, 0, 0]
l_4 = [1/b_e, 1/2, 0, 0, 0, 0, 0, 0, 0, -1/b_e, 1/2, 0, 0, 0, 0, 0, 0, 0, 2/3, 0, 0, 0]
#: They are converted to covariant components (per half edge) and interpolated as in MITC: a constant term and a linear one, with the linear part **symmetrized** (the same m in both directions):
g_b = a_e/2·l_1 'bottom edge
g_t = -a_e/2·l_3 'top edge
g_R = b_e/2·l_2 'right edge
g_L = -b_e/2·l_4 'left edge
A_0 = (g_b + g_t)/2 'constant part of γ_xz
C_0 = (g_L + g_R)/2 'constant part of γ_yz
m_m = ((g_t - g_b)/2 + (g_R - g_L)/2)/2 'symmetrized linear part
B_s(r, s) = [2/a_e·transpose(A_0 + s·m_m); 2/b_e·transpose(C_0 + r·m_m)]
#: **8-point quadrature** (Irons, the one from ITW 1991): 4 near the corners with weight 9/49 and 4 on the axes with weight 40/49:
q_A = sqrt(7/9) 'coordinate of the corner points
q_B = sqrt(7/15) 'coordinate of the axis points
r_g = [-q_A, q_A, q_A, -q_A, 0, q_B, 0, -q_B] 'r of the 8 points
s_g = [-q_A, -q_A, q_A, q_A, -q_B, 0, q_B, 0] 's of the 8 points
w_g = [9/49, 9/49, 9/49, 9/49, 40/49, 40/49, 40/49, 40/49] 'weights
j_d = a_e·b_e/4 'Jacobian of the rectangle [m2]
#: **B-bar.** The 10 internal columns of B_{b} have their mean over the element subtracted: that way the internal modes do not change the mean curvature and the element passes the patch test.
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
#: **22 × 22 stiffness**: bending + shear + penalty, summed over the 8 points:
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
#: **Static condensation** of the 10 internal dof (they connect to no one: they are eliminated inside the element). With u_{i} = −K_{ii}⁻¹·K_{ib}·u_{b}:
#: K_{e} = K_{bb} − K_{bi}·K_{ii}⁻¹·K_{ib}
#hide
K_e = K_22(1:12, 1:12) - K_22(1:12, 13:22)·inv(K_22(13:22, 13:22))·K_22(13:22, 1:12)
#show
#: The element K in MN/m (rows and columns [w₁, θ_{x1}, θ_{y1}, w₂, θ_{x2}, θ_{y2} | w₃ … θ_{y4}]), in 6 × 6 blocks:
K_11 = round(K_e(1:6, 1:6)/1000·10)/10 'block nodes 1-2 with nodes 1-2 [MN/m]
K_12 = round(K_e(1:6, 7:12)/1000·10)/10 'block nodes 1-2 with nodes 3-4 [MN/m]
K_21 = round(K_e(7:12, 1:6)/1000·10)/10 'block nodes 3-4 with nodes 1-2 [MN/m]
K_22b = round(K_e(7:12, 7:12)/1000·10)/10 'block nodes 3-4 with nodes 3-4 [MN/m]
#: Check against the Hekatan Struct matrix (`csiThickBendingK`, the same element): K_{e}(1,1) = 2 735 178.7 kN/m and K_{e}(2,3) = 9 080 283.9 kN·m/rad.
K_S11 = 2735178.7 'Struct K(1,1) [kN/m]
dK_11 = round(100·(K_e(1, 1)/K_S11 - 1), 6) 'difference [%]
#: The large term that couples θ_{x} with θ_{y} (9 080 284) is the divergence penalty: it comes from CSI, it is not an error.


## 5 · Soil springs: from area to nodes

#: The spring is an **area** spring (k_{s} in kN/m³) and the program distributes it to the nodes the way SAP2000, ETABS and SAFE do: k_{n} = k_{s}·∫N_{i} dA. In a rectangle each element gives each of its 4 nodes a quarter of its area: an interior node receives 4 quarters, an edge node 2 and a corner 1.
#hide
k_n = zeros(n_j, 1)
#show
for e = 1:n_e
  for c = 1:4
    q = e_j(e, c)
    k_n(q) = k_n(q) + k_s·a_e·b_e/4
  end
end
k_esq = k_n(1) 'spring of a corner [kN/m]
k_bor = k_n(2) 'spring of an edge node [kN/m]
k_int = k_n(n_n + 2) 'spring of an interior node [kN/m]
A_k = sum(k_n)/k_s 'sum of the springs / k_s = footing area [m2]
#: **Compression only.** The soil pushes but does not pull. It is the CSI «Gap» law (Analysis Reference Manual, p. 286; SAFE «Nonlinear Analysis for Uplift»): f = k·w if the node goes down (w < 0), f = 0 if it goes up. Hekatan Struct solves it by **active set** (`muellesSoloCompresion.ts`): solve with all the springs, turn off those of the nodes that go up, solve again, until the set does not change. For this law the result is exact, with no tolerances.


## 6 · Loads

#: Three things: (1) the weight of the footing and the backfill, spread over the whole plan; (2) the column axial load, spread over its 40 × 40 cm footprint; (3) the remaining moments, as a moment at the column-axis node. Each element sends its distributed load to its 4 nodes (a quarter each: it is the consistent vector of a uniform pressure on a rectangle).
q_g = (G_z + Z_r)/(l_x·l_y) 'weight of footing and backfill [kPa]
q_c = N_1/c_x^2 'column pressure over its footprint [kPa]
x_c = 0 'column axis in x [m]
y_c = 0 'column axis in y [m]
#: The moment that reaches the bottom, with the right-hand sign (a downward force V at (e_{x}, e_{y}) is equivalent to V at the center plus M_{Y} = e_{x}·V and M_{X} = −e_{y}·V):
M_Xn = -e_y·V_d 'moment about x at the column node [kN·m]
M_Yn = e_x·V_d 'moment about y at the column node [kN·m]
n_c = round((y_c + l_y/2)/h_e)·n_n + round((x_c + l_x/2)/h_e) + 1 'column-axis node
n_g = 3·n_j 'degrees of freedom of the model
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
F_z 'sum of the vertical forces = −V [kN]


## 7 · Assembly

#: Three degrees of freedom per node: those of node j are 3(j − 1) + 1, 2, 3. The stiffness of each element is **added** into the rows and columns of its 4 nodes:
d_j(j) = 3·(j - 1) + (1:3)
d_e(e) = [d_j(e_j(e, 1)), d_j(e_j(e, 2)), d_j(e_j(e, 3)), d_j(e_j(e, 4))]
#hide
K = zeros(n_g, n_g)
#show
for e = 1:n_e
  g = d_e(e)
  K(g, g) = K(g, g) + K_e
end


## 8 · Solution with compression-only soil

#: The active set: a_{c}(q) = 1 if node q touches the soil. Start with all of them and repeat until it does not change:
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

n_it 'solves until the contact does not change
n_ct = sum(a_c) 'nodes in contact (out of 169)
#: With the resultant at 2 cm from the center (inside the middle third, e/B = 0.018 < 1/6) **all the nodes go down**: the soil works entirely in compression and one solve is enough. It is the linear case.

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


## 9 · Contact pressure and deflection

p_max = max(p_j) 'maximum pressure (edge x = −0.6) [kPa]
p_min = min(p_j) 'minimum pressure (edge x = +0.6) [kPa]
n_m = n_x/2·n_n + n_x/2 + 1 'center node
p_cen = p_j(n_m) 'pressure under the center [kPa]
w_cen = w_j(n_m) 'deflection at the center [mm]
w_min = min(w_j) 'largest deflection (downward) [mm]
R_s = sum(R_j) 'sum of the soil reactions = V [kN]
x_R = sum(R_j.*X_j)/R_s 'abscissa of the soil resultant = e_x [m]
#: **Equilibrium:** the sum of the springs gives V = 3033.728 kN and its resultant falls at e_{x}: the model loses no load.
#: **Pressure map** (kPa) on the footing plan; the value is read with the cursor:
p_xy(x, y) = spline(1 + (x + l_x/2)/h_e, 1 + (y + l_y/2)/h_e, P_m)
#map(p_xy(x, y), [-0.6 0.6], [-0.6 0.6])
#: **The pressure in 3D** (height: 1 m = 5000 kPa): the pressure «table», higher on the negative-x side, which is where the resultant falls. Rotate it with the mouse:
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
#: **Deformed shape** (×10), painted with the deflection in mm:
#modelo3d(X_d, e_j, e_f, w_j, v_f, U_3, 10)

## 10 · The analytical solution: rigid footing

#: If the footing were infinitely rigid, the pressure would be a **plane** (Navier: N/A ± M/S). With the resultant inside the middle third:
A_z = l_x·l_y 'area [m2]
S_y = l_y·l_x^2/6 'section modulus of the plan [m3]
p_Rmax = V_d/A_z + V_d·abs(e_x)/S_y 'maximum pressure, rigid [kPa]
p_Rmin = V_d/A_z - V_d·abs(e_x)/S_y 'minimum pressure, rigid [kPa]
#: **Is this footing rigid?** The elastic length of the plate on Winkler, ℓ = (D/k_{s})^{1/4}, is compared with the side: if ℓ is of the order of the side or larger, the plate behaves almost rigid.
l_el = (D_0/k_s)^(1/4) 'elastic length [m]
#: ℓ ≈ 1.26 m > 1.20 m: almost rigid, but not quite. That is why the finite element gives almost the Navier plane: the plate arches a little under the column, the center pushes somewhat more (2122 kPa against the 2107 of Navier) and the edges somewhat less.
dp_max = 100·(p_max/p_Rmax - 1) 'FEM versus rigid, maximum pressure [%]

## 11 · Settlement and rotation: service load 3 and load 4 (sheet 105)

#: For the settlement GEO5 uses the **net** pressure (discounting the excavated soil, σ = γ₁·d_{f}). Load 3: N = 1500 kN and H_{x} = 100 kN (moment H·t = 40 kN·m). Load 4: N = 700 kN and M_{x} = 100 kN·m. Same model, other loads; K does not change:
q_n4 = (700 + G_z + Z_r)/(l_x·l_y) - γ_1·d_f 'net pressure of load 4 [kPa]
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
s_med = -sum(w_3.*k_n)/sum(k_n) 'average settlement, load 3 (= 15.9 by the k_s criterion) [mm]
s_cen = -w_3(n_m) 'settlement at the center, load 3 [mm]
s_xp = -w_3(n_m + n_x/2) 'center of edge x = +0.6, load 3 [mm]
s_xm = -w_3(n_m - n_x/2) 'center of edge x = −0.6, load 3 [mm]
θ_x = (s_xp - s_xm)/l_x 'rotation about x, load 3 [‰]
s_yp = -w_4(n_m + (n_x/2)·n_n) 'center of edge y = +0.6, the most loaded with load 4 [mm]
s_ym = -w_4(n_m - (n_x/2)·n_n) 'center of edge y = −0.6, load 4 [mm]
θ_y = (s_yp - s_ym)/l_y 'rotation about y, load 4 [‰]
#: **Winkler versus the GEO5 half-space.** The average settlement matches (it is the criterion), but the **shape** does not: GEO5 gives the center at 23.1 mm and the edges at 12-14 mm (the footing on elastic soil sinks like a dish), and here, with the nearly rigid plate, center and edges go down almost the same. Winkler springs do not talk to each other: there is no «dish». And the rotation comes out **twice** the GEO5 one (≈ 3.5 ‰ against 1.6 ‰): in Winkler the rotational stiffness is k_{s}·I = k_{s}·l⁴/12, which with the k_{s} calibrated for the settlement is lower than that of the half-space. With a single k_{s} one cannot nail both the settlement and the rotation of GEO5 at the same time.
θ_W = 40/(k_s·l_y·l_x^3/12)·1000 'rotation of a rigid footing on Winkler, load 3 [‰]

## 12 · Sensitivity to k_{s}

#: The k_{s} is a criterion, not a datum: load 1 is repeated with half and with double.
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
#: **Reading:** the deflection goes almost as 1/k_{s} (it is the cushion that compresses), but the pressure hardly changes: with the nearly rigid footing, the pressure is set by **equilibrium** (V and M), not by the soil. That is why in a centered footing k_{s} matters for the settlement and little for the flexural design.

## 13 · Hekatan LISP versus Hekatan Struct, node by node

#: Struct ran the **same model** (file `tests/zapata_fem/c0.heks`: 169 nodes, 144 `thick` shells, `areaspring … nodal compresion`), with its code untouched (branch `zapata-levantamiento`). Its 169 deflections (mm) are stored here; they are compared with those of this sheet:
#hide
w_S1 = [-35.2320418, -34.7042496, -34.1775678, -33.6492329, -33.1158240, -32.5739234, -32.0209972, -31.4561417, -30.8803284, -30.2960428, -29.7065146, -29.1148424, -28.5234693, -35.2650876, -34.7381083, -34.2128477, -33.6863768, -33.1548069, -32.6141575, -32.0614112, -31.4955307, -30.9177652, -30.3311380, -29.7394620, -29.1462328, -28.5540044, -35.2988503, -34.7733612, -34.2509824, -33.7285366, -33.2013165, -32.6638979, -32.1120299, -31.5442301, -30.9623979, -30.3709883, -29.7750783, -29.1789485, -28.5852320, -35.3306613, -34.8072244, -34.2890277, -33.7732821, -33.2539702, -32.7229692, -32.1731225, -31.6018594, -31.0127537, -30.4130303, -29.8104972, -29.2102904, -28.6146144, -35.3571500, -34.8358659, -34.3223483, -33.8148658, -33.3099950, -32.7914018, -32.2443608, -31.6684015, -31.0657822, -30.4518581, -29.8413660, -29.2367062, -28.6390024, -35.3748152, -34.8551984, -34.3454604, -33.8449954, -33.3534125, -32.8469323, -32.3016147, -31.7206872, -31.1063908, -30.4798332, -29.8626676, -29.2544897, -28.6552500, -35.3810412, -34.8620511, -34.3537438, -33.8561572, -33.3683808, -32.8658582, -32.3208174, -31.7373712, -31.1203409, -30.4900878, -29.8703159, -29.2607713, -28.6609531, -35.3748152, -34.8551984, -34.3454604, -33.8449954, -33.3534125, -32.8469323, -32.3016147, -31.7206872, -31.1063908, -30.4798332, -29.8626676, -29.2544897, -28.6552500, -35.3571500, -34.8358659, -34.3223483, -33.8148658, -33.3099950, -32.7914018, -32.2443608, -31.6684015, -31.0657822, -30.4518581, -29.8413660, -29.2367062, -28.6390024, -35.3306613, -34.8072244, -34.2890277, -33.7732821, -33.2539702, -32.7229692, -32.1731225, -31.6018594, -31.0127537, -30.4130303, -29.8104972, -29.2102904, -28.6146144, -35.2988503, -34.7733612, -34.2509824, -33.7285366, -33.2013165, -32.6638979, -32.1120299, -31.5442301, -30.9623979, -30.3709883, -29.7750783, -29.1789485, -28.5852320, -35.2650876, -34.7381083, -34.2128477, -33.6863768, -33.1548069, -32.6141575, -32.0614112, -31.4955307, -30.9177652, -30.3311380, -29.7394620, -29.1462328, -28.5540044, -35.2320418, -34.7042496, -34.1775678, -33.6492329, -33.1158240, -32.5739234, -32.0209972, -31.4561417, -30.8803284, -30.2960428, -29.7065146, -29.1148424, -28.5234693]
d_w = 0
w_mx = 0
for q = 1:n_j
  d_w = max(d_w, abs(w_j(q) - w_S1(q)))
  w_mx = max(w_mx, abs(w_S1(q)))
end
#show
Δ_c1 = 100·d_w/w_mx 'worst node, LISP versus Struct, as % of the maximum deflection

#hide
w_S3 = [-13.8165924, -14.1641592, -14.5114742, -14.8586366, -15.2057467, -15.5528628, -15.9000000, -16.2471372, -16.5942533, -16.9413634, -17.2885259, -17.6358408, -17.9834076, -13.8158127, -14.1633927, -14.5107498, -14.8580004, -15.2052666, -15.5526004, -15.9000000, -16.2473996, -16.5947334, -16.9419996, -17.2892502, -17.6366073, -17.9841873, -13.8150254, -14.1626047, -14.5099677, -14.8572831, -15.2046837, -15.5522771, -15.9000000, -16.2477229, -16.5953163, -16.9427169, -17.2900323, -17.6373953, -17.9849746, -13.8142712, -14.1618217, -14.5091520, -14.8564436, -15.2039700, -15.5518292, -15.9000000, -16.2481708, -16.5960300, -16.9435565, -17.2908480, -17.6381783, -17.9857289, -13.8136188, -14.1611305, -14.5083906, -14.8555877, -15.2030395, -15.5512421, -15.9000000, -16.2487579, -16.5969605, -16.9444123, -17.2916094, -17.6388695, -17.9863812, -13.8131785, -14.1606495, -14.5078283, -14.8549186, -15.2021672, -15.5502344, -15.9000000, -16.2497656, -16.5978328, -16.9450814, -17.2921717, -17.6393505, -17.9868215, -13.8130161, -14.1604721, -14.5076311, -14.8546368, -15.2018510, -15.5495382, -15.9000000, -16.2504618, -16.5981491, -16.9453632, -17.2923689, -17.6395279, -17.9869839, -13.8131785, -14.1606495, -14.5078283, -14.8549186, -15.2021672, -15.5502344, -15.9000000, -16.2497656, -16.5978328, -16.9450814, -17.2921717, -17.6393505, -17.9868215, -13.8136188, -14.1611305, -14.5083906, -14.8555877, -15.2030395, -15.5512421, -15.9000000, -16.2487579, -16.5969605, -16.9444123, -17.2916094, -17.6388695, -17.9863812, -13.8142712, -14.1618217, -14.5091520, -14.8564436, -15.2039700, -15.5518292, -15.9000000, -16.2481708, -16.5960300, -16.9435565, -17.2908480, -17.6381783, -17.9857289, -13.8150254, -14.1626047, -14.5099677, -14.8572831, -15.2046837, -15.5522771, -15.9000000, -16.2477229, -16.5953163, -16.9427169, -17.2900323, -17.6373953, -17.9849746, -13.8158127, -14.1633927, -14.5107498, -14.8580004, -15.2052666, -15.5526004, -15.9000000, -16.2473996, -16.5947334, -16.9419996, -17.2892502, -17.6366073, -17.9841873, -13.8165924, -14.1641592, -14.5114742, -14.8586366, -15.2057467, -15.5528628, -15.9000000, -16.2471372, -16.5942533, -16.9413634, -17.2885259, -17.6358408, -17.9834076]
d_w = 0
w_mx = 0
for q = 1:n_j
  d_w = max(d_w, abs(w_3(q) - w_S3(q)))
  w_mx = max(w_mx, abs(w_S3(q)))
end
#show
Δ_c3 = 100·d_w/w_mx 'worst node, LISP versus Struct, as % of the maximum deflection

#hide
w_S4 = [-2.2311540, -2.2292047, -2.2272365, -2.2253509, -2.2237200, -2.2226193, -2.2222134, -2.2226193, -2.2237200, -2.2253509, -2.2272365, -2.2292047, -2.2311540, -3.1000712, -3.0981548, -3.0961849, -3.0942274, -3.0924994, -3.0912968, -3.0908533, -3.0912968, -3.0924994, -3.0942274, -3.0961849, -3.0981548, -3.1000712, -3.9683585, -3.9665475, -3.9645923, -3.9625531, -3.9606496, -3.9592438, -3.9587508, -3.9592438, -3.9606496, -3.9625531, -3.9645923, -3.9665475, -3.9683585, -4.8362646, -4.8346740, -4.8328809, -4.8307819, -4.8286422, -4.8269695, -4.8262651, -4.8269695, -4.8286422, -4.8307819, -4.8328809, -4.8346740, -4.8362646, -5.7040398, -5.7028395, -5.7013822, -5.6995981, -5.6972718, -5.6950910, -5.6943005, -5.6950910, -5.6972718, -5.6995981, -5.7013822, -5.7028395, -5.7040398, -6.5718301, -6.5711740, -6.5703658, -6.5692462, -6.5677784, -6.5652592, -6.5635186, -6.5652592, -6.5677784, -6.5692462, -6.5703658, -6.5711740, -6.5718301, -7.4396731, -7.4396731, -7.4396731, -7.4396731, -7.4396731, -7.4396731, -7.4396731, -7.4396731, -7.4396731, -7.4396731, -7.4396731, -7.4396731, -7.4396731, -8.3075160, -8.3081721, -8.3089803, -8.3101000, -8.3115677, -8.3140870, -8.3158276, -8.3140870, -8.3115677, -8.3101000, -8.3089803, -8.3081721, -8.3075160, -9.1753063, -9.1765067, -9.1779639, -9.1797480, -9.1820743, -9.1842551, -9.1850457, -9.1842551, -9.1820743, -9.1797480, -9.1779639, -9.1765067, -9.1753063, -10.0430815, -10.0446721, -10.0464652, -10.0485642, -10.0507039, -10.0523767, -10.0530811, -10.0523767, -10.0507039, -10.0485642, -10.0464652, -10.0446721, -10.0430815, -10.9109877, -10.9127986, -10.9147539, -10.9167930, -10.9186966, -10.9201023, -10.9205954, -10.9201023, -10.9186966, -10.9167930, -10.9147539, -10.9127986, -10.9109877, -11.7792750, -11.7811913, -11.7831612, -11.7851187, -11.7868468, -11.7880494, -11.7884928, -11.7880494, -11.7868468, -11.7851187, -11.7831612, -11.7811913, -11.7792750, -12.6481921, -12.6501414, -12.6521097, -12.6539952, -12.6556262, -12.6567268, -12.6571328, -12.6567268, -12.6556262, -12.6539952, -12.6521097, -12.6501414, -12.6481921]
d_w = 0
w_mx = 0
for q = 1:n_j
  d_w = max(d_w, abs(w_4(q) - w_S4(q)))
  w_mx = max(w_mx, abs(w_S4(q)))
end
#show
Δ_c4 = 100·d_w/w_mx 'worst node, LISP versus Struct, as % of the maximum deflection

#: Less than a hundred-thousandth of a % of the maximum: it is the **same element and the same model**; what remains is arithmetic rounding (the 1000·tr(D_{b}) penalty makes K ill-conditioned) and the stored data (7 decimals in mm).

## 14 · Summary: Hekatan LISP (FEM) · Hekatan Struct · GEO5 (analytical)

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
#: **Why FEM and GEO5 do not give the same pressure.** GEO5 (like EN 1997 and the NEC) does not look for the real pressure: it uses the **Meyerhof** one, uniform over an effective rectangle B − 2e centered on the resultant, which is a device for **bearing capacity** (2184 kPa over 1.158 m). The plate on springs gives the **service** pressure (the one used to reinforce the footing): an almost Navier plane, between 1883 and 2323 kPa. Both have the same resultant (V at e_{x}); they are not compared point by point.

## 15 · NEC-SE-GC 2015

#: **Table 6, §6.2 (p. 42)**: FS ≥ 3.0 for bearing capacity (DL + normal LL). With R_{d} = 3594.35 kPa from GEO5 (sheet 104) the allowable pressure is R_{d}/3:
q_adm = 3594.35/3 'NEC allowable pressure [kPa]
#: The maximum FEM contact pressure (≈ 2323 kPa) doubles it, and the GEO5 FS (1.65) is less than 3.0: it **does not meet the NEC** (same as in sheet 104). **§6.3.4 (p. 43-44)**: allowable total settlement of an isolated footing 20 cm; here ≈ 1.6 cm with the service load: it passes. **Table 7**: angular distortion L/300 in concrete frames ≈ 3.3 ‰; the FEM rotation of load 3 (≈ 3.5 ‰) grazes it, the GEO5 one (1.6 ‰) does not. With Winkler the rotation errs on the safe side.
