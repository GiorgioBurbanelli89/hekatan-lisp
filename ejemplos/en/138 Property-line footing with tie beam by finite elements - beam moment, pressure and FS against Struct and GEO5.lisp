# Property-line footing with tie beam by finite elements: beam moment, pressure and FS, against Hekatan Struct and GEO5
#numerico

#: **What is calculated.** The property-line footing of sheet 136 (column 1 cm from the edge) now **tied** to the interior column with a beam. Sheet 106 explained it as a rigid lever (FS from 0.41 to 1.53, with an assumed L_{v} = 5 m). Here the finite element does it: thick plate on compression-only springs (sheets 135-136) + a **bending bar** attached to the column node.
#: **Model of the beam and of the interior footing (assumptions, not from Demo01):** 0.40 × 0.90 m C20/25 concrete beam, from the property-line column (x = −0.40) to the interior one (x = 4.60, L_{v} = 5 m); the interior footing is equal to the centered one (1.20 × 1.20, same load 3033.7 kN) and is modeled as a vertical spring k_{s}·A with free rotation. The beam works like the one in Struct: Timoshenko with shear area 5/6·A.

## 1 · Data (GEO5 Demo01, sheets 104 to 106)

l_x = 1.2 'footing side in x [m]
l_y = 1.2 'footing side in y [m]
t_z = 0.4 'footing depth [m]
c_x = 0.4 'column side [m]
d_f = 1.2 'depth of the bottom from grade [m]
E_c = 30000000 'GEO5 C20/25 concrete modulus, 30 000 MPa [kPa]
ν = 0.2 'Poisson's ratio (the one Hekatan Struct uses in shells)
γ_1 = 17.5 'unit weight of soil 1 [kN/m3]
N_1 = 3000 'column axial, load 1 [kN]
M_x = -2 'moment about x, load 1 [kN·m]
M_y = 70 'moment about y, load 1 [kN·m]
H_x = 14 'horizontal in x, load 1 [kN]
H_y = 5 'horizontal in y, load 1 [kN]
G_z = 13.248 'footing weight, 1.2·1.2·0.4·23 (sheet 104) [kN]
Z_r = 20.48 'weight of the fill over the footing (sheet 104) [kN]
V_d = N_1 + G_z + Z_r 'total vertical at the bottom [kN]


#: **Where the column sits (sheet 106).** GEO5 asks for a_{x}, the distance from the edge to the column face: a_{x} = 0.01 m, so the axis is at 0.01 + 0.20 = 0.21 m from the edge, at p = 0.39 m from the center. The GEO5 eccentricity (help "Stress in the Footing Bottom") adds that of the shifted axial N·p:
a_x = 0.01 'from the edge to the column face (GEO5) [m]
p_x = a_x + c_x/2 - l_x/2 'column axis from the center, in x [m]

e_x = (-M_y + H_x·t_z + N_1·p_x)/V_d 'eccentricity without beam (sheet 136) [m]
e_y = (M_x + H_y·t_z)/V_d 'eccentricity in y [m]

## 1b · The plan: property-line footing, tie beam and interior footing

#: **How to read it.** Plan to scale, in meters. On the left, the **property line** (dashed): the 1.20 × 1.20 m footing cannot go beyond it, so the 0.40 m column ends up 0.01 m from the edge and the load falls **eccentric**. The **tie beam** (0.40 m wide, 0.90 m deep) joins that column with the interior one, 5.00 m away (axis to axis), where there is another 1.20 × 1.20 m footing. The beam takes the moment of the eccentricity and carries it to the interior footing as a force couple: that is why the property-line footing stops rotating and the soil under it is loaded almost evenly (sections 9 to 11).
#dibujo("Plan: property-line footing, 0.40 × 0.90 m tie beam and interior footing", ud = m, escala = auto, cotas = m, alto = 90)
#  linea(-0.6, -0.95, -0.6, 0.95, "eje")
#  texto(-0.55, 0.85, "property line", 2.5, "i")
#  rect(-0.6, -0.6, 1.2, 1.2, "gruesa")
#  rect(4.0, -0.6, 1.2, 1.2, "gruesa")
#  rect(-0.4, -0.2, 5.0, 0.4, "media")
#  achurado(-0.4, -0.2, 5.0, 0.4, "concreto")
#  rect(-0.59, -0.2, 0.4, 0.4, "denso")
#  rect(4.4, -0.2, 0.4, 0.4, "denso")
#  texto(-0.4, -0.78, "property-line column", 2.4, "i")
#  texto(4.1, -0.78, "interior column", 2.4, "i")
#  texto(1.6, 0.34, "tie beam", 2.5, "i")
#  cota(-0.6, 0.85, 0.6, 0.85, 0.08, "1.20")
#  cota(4.0, 0.85, 5.2, 0.85, 0.08, "1.20")
#  cota(-0.4, -0.95, 4.6, -0.95, -0.08, "5.00 between column axes")
#  cota(2.6, -0.2, 2.6, 0.2, 0.08, "0.40")
#  cota(-0.6, 0.0, -0.19, 0.0, -0.45, "0.01 + 0.40")
#fin

## 2 · Subgrade modulus (criterion of sheet 135)

#: Calibrated with the GEO5 settlement (sheet 105): service load 3 gives a net pressure q_{n} and GEO5 a settlement of 15.9 mm; k_{s} = q_{n}/s.
q_n = (1500 + G_z + Z_r)/(l_x·l_y) - γ_1·d_f 'net pressure of load 3 [kPa]
k_s = q_n/0.0159 'subgrade modulus [kN/m3]


## 3 · Finite element mesh

#: Regular mesh of 10 cm square elements. The nodes are numbered as in the Hekatan Struct .heks: row by row, from x = −0.6 to 0.6 and from y = −0.6 upward. This way the comparison is **node by node**.
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


#: **The column in the mesh.** With 10 cm elements, the column footprint is placed **flush with the edge** (from −0.6 to −0.2: axis at −0.40). The centimeter missing up to the real axis (−0.39) is not lost: it enters as a moment N·0.01 = 30 kN·m at the axis node. This way the resultant is **exactly** that of GEO5.


## 4 · The element (that of sheet 135)

#: The **Hekatan Struct thick plate** = CSI Shell-Thick (`getBendingK_CSI`, shellQ4.cpp): rotations with 9 functions (4 node, 4 side, 1 bubble), symmetrized Wilson side shear, penalty 1000·tr(D_{b}) of the divergence of the rotations, 8 Gauss points, B-bar and condensation of the 10 internal ones. The derivation is in sheet 135; here it is calculated the same.
a_e = h_e 'element side in x [m]
b_e = h_e 'element side in y [m]
D_0 = E_c·t_z^3/(12·(1 - ν^2)) 'bending stiffness [kN·m]
D_b = D_0·[1, ν, 0; ν, 1, 0; 0, 0, (1 - ν)/2] 'bending matrix [kN·m]
D_s = 5/6·E_c·t_z/(2·(1 + ν))·eye(2) 'shear matrix [kN/m]
D_tr = trace(D_b) 'for the penalty [kN·m]
P_n = 1000 'CSI penalty
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
A_0 = (a_e/2·l_1 - a_e/2·l_3)/2 'constant part of γ_xz
C_0 = (-b_e/2·l_4 + b_e/2·l_2)/2 'constant part of γ_yz
m_m = ((-a_e/2·l_3 - a_e/2·l_1)/2 + (b_e/2·l_2 + b_e/2·l_4)/2)/2 'symmetrized linear part
B_s(r, s) = [2/a_e·transpose(A_0 + s·m_m); 2/b_e·transpose(C_0 + r·m_m)]
q_A = sqrt(7/9) 'corner points
q_B = sqrt(7/15) 'axis points
r_g = [-q_A, q_A, q_A, -q_A, 0, q_B, 0, -q_B] 'r of the 8 points
s_g = [-q_A, -q_A, q_A, q_A, -q_B, 0, q_B, 0] 's of the 8 points
w_g = [9/49, 9/49, 9/49, 9/49, 40/49, 40/49, 40/49, 40/49] 'weights
j_d = a_e·b_e/4 'Jacobian [m2]
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
#: Condensed to 12 × 12 (K_{e} = K_{bb} − K_{bi}·K_{ii}⁻¹·K_{ib}); its first term, to check:
K_e11 = K_e(1, 1) 'term w₁-w₁ (Struct: 2 735 178.7) [kN/m]


## 5 · Soil springs: from area to nodes

#: The spring is an **area** one (k_{s} in kN/m³) and the program distributes it to the nodes as SAP2000, ETABS and SAFE do: k_{n} = k_{s}·∫N_{i} dA. In a rectangle each element gives each of its 4 nodes a quarter of its area: an interior node receives 4 quarters, an edge one 2 and a corner 1.
#hide
k_n = zeros(n_j, 1)
#show
for e = 1:n_e
  for c = 1:4
    q = e_j(e, c)
    k_n(q) = k_n(q) + k_s·a_e·b_e/4
  end
end
k_esq = k_n(1) 'corner spring [kN/m]
k_bor = k_n(2) 'edge node spring [kN/m]
k_int = k_n(n_n + 2) 'interior node spring [kN/m]
A_k = sum(k_n)/k_s 'sum of springs / k_s = footing area [m2]
#: **Compression only.** The soil pushes but does not pull. It is the CSI "Gap" law (Analysis Reference Manual, p. 286; SAFE "Nonlinear Analysis for Uplift"): f = k·w if the node goes down (w < 0), f = 0 if it goes up. Hekatan Struct solves it by **active set** (`muellesSoloCompresion.ts`): solve with all springs, switch off those of the nodes that rise, solve again, until the set does not change. For this law the result is exact, without tolerances.


## 6 · Loads

#: Three things: (1) the weight of the footing and of the fill, distributed over the whole plan; (2) the column axial, distributed over its 40 × 40 cm footprint; (3) the remaining moments, as a moment at the column axis node. Each element carries its distributed load to its 4 nodes (a quarter each: it is the consistent vector of a uniform pressure on a rectangle).
q_g = (G_z + Z_r)/(l_x·l_y) 'weight of the footing and of the fill [kPa]
q_c = N_1/c_x^2 'pressure of the column on its footprint [kPa]
x_c = -0.4 'axis of the footprint in the mesh (flush with the edge) [m]
y_c = 0 'column axis in y [m]
#: Moment missing at the axis node (right hand: M_{Y} = e_{x}·V, M_{X} = −e_{y}·V), discounting what the column already puts on its footprint:
M_Xn = -e_y·V_d 'moment about x [kN·m]
M_Yn = e_x·V_d - N_1·x_c 'moment about y: that of the load + the centimeter [kN·m]
n_c = round((y_c + l_y/2)/h_e)·n_n + round((x_c + l_x/2)/h_e) + 1 'column axis node
n_g = 3·(n_j + 1) 'degrees of freedom of the model
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


## 8 · The tie beam and the interior footing

b_v = 0.4 'beam width [m]
h_v = 0.9 'beam depth [m]
L_v = 5 'from the property-line column to the interior one [m]
A_v = b_v·h_v 'area [m2]
I_v = b_v·h_v^3/12 'vertical bending inertia [m4]
J_v = 0.013845 'torsion constant of the 0.40 × 0.90 rectangle [m4]
G_c = E_c/(2·(1 + ν)) 'shear modulus [kPa]
φ_v = 12·E_c·I_v/(G_c·5/6·A_v·L_v^2) 'Timoshenko parameter (beam shear)
c_v = E_c·I_v/(L_v^3·(1 + φ_v)) 'common factor [kN/m]
#: **Beam stiffness** in the dof [w, θ_{x}, θ_{y}] of its two nodes. Along x, the slope of the deflection is dw/dx = −θ_{y} (right hand): that is why the terms that cross w with θ_{y} change sign with respect to the book. The torsion (G·J/L) goes in θ_{x}:
K_f = c_v·[12, 0, -6·L_v, -12, 0, -6·L_v; 0, 0, 0, 0, 0, 0; -6·L_v, 0, (4 + φ_v)·L_v^2, 6·L_v, 0, (2 - φ_v)·L_v^2; -12, 0, 6·L_v, 12, 0, 6·L_v; 0, 0, 0, 0, 0, 0; -6·L_v, 0, (2 - φ_v)·L_v^2, 6·L_v, 0, (4 + φ_v)·L_v^2]
t_v = G_c·J_v/L_v 'torsional stiffness [kN·m/rad]
K_T = t_v·[0, 0, 0, 0, 0, 0; 0, 1, 0, 0, -1, 0; 0, 0, 0, 0, 0, 0; 0, 0, 0, 0, 0, 0; 0, -1, 0, 0, 1, 0; 0, 0, 0, 0, 0, 0]
K_v = K_f + K_T 'beam stiffness [kN/m, kN·m/rad]
n_k = n_j + 1 'interior column node
K_i = k_s·l_x·l_y 'interior footing spring [kN/m]
P_i = V_d 'interior column load + its weight [kN]
g_v = [3·n_c - 2, 3·n_c - 1, 3·n_c, 3·n_k - 2, 3·n_k - 1, 3·n_k] 'beam dof
#: They are added to the plate K: the beam in the dof of its two nodes, the interior footing spring in its w, and the interior load in F:
#hide
K(g_v, g_v) = K(g_v, g_v) + K_v
K(3·n_k - 2, 3·n_k - 2) = K(3·n_k - 2, 3·n_k - 2) + K_i
F(3·n_k - 2) = F(3·n_k - 2) - P_i
#show

## 9 · Solution: the active set

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

n_it 'solves
n_ct = sum(a_c) 'nodes in contact (of 169)
#: **With the beam no node lifts**: the whole footing bears again (without beam, sheet 136: 78 of 169).

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


## 10 · What the beam takes

#hide
u_v = zeros(6, 1)
for i = 1:6
  u_v(i) = U(g_v(i))
end
#show
f_v = round(K_v·u_v·10)/10 'forces at the beam ends, f = K·u [kN, kN·m]
P_v = f_v(1) 'downward force that the beam puts on the property-line footing [kN]
M_v = f_v(3) 'beam moment at the property-line column [kN·m]
#: The beam **pushes down** the property-line footing with P_{v} (and pulls up the interior one with the same) and applies a moment that **straightens** it: it is the lever. The rigid lever of sheet 106 gives ΔP = N·e₀/(L_{v} − e₀):
Δ_P = N_1·abs(p_x)/(L_v - abs(p_x)) 'what the rigid lever transfers to the property-line footing [kN]
M_0 = N_1·abs(p_x) 'moment created by the shifted column, N·e₀ (sheet 106) [kN·m]
r_M = abs(M_v)/M_0 'fraction of N·e₀ taken by the beam
w_c = 1000·U(3·n_c - 2) 'settlement of the property-line column [mm]
w_k = 1000·U(3·n_k - 2) 'settlement of the interior column [mm]
β_v = abs(w_c - w_k)/L_v 'angular distortion between columns [‰]
θ_c = 1000·U(3·n_c) 'rotation of the property-line footing about y [‰]
#: **Beam moment diagram**: linear, from M_{v} at the property-line column to 0 at the interior one (free rotation there, and the beam carries no load in the span):
m_1 = -abs(M_v)/1000 'drawing ordinate (1 m = 1000 kN·m)
#dibujo("Tie beam: moment diagram (1 m = 1000 kN·m)", ud = m, escala = auto, alto = 90)
#  linea(0, 0, 5, 0, "gruesa")
#  linea(0, m_1, 5, 0, "gruesa rojo")
#  linea(0, 0, 0, m_1, "media rojo")
#  texto(0.1, m_1 - 0.15, "M at the property-line column", 2.6, "i")
#  texto(5, 0.15, "interior column (M = 0)", 2.6, "d")
#fin

## 11 · Contact pressure and deformed shape

p_max = max(p_j) 'maximum pressure [kPa]
p_min = min(p_j) 'minimum pressure [kPa]
R_s = sum(R_j) 'soil reaction under the property-line footing [kN]
x_R = sum(R_j.*X_j)/R_s 'resultant of the soil from the center [m]
R_1 = N_1·L_v/(L_v - abs(p_x)) + G_z + Z_r 'rigid lever of sheet 106 [kN]
#: The FEM and the rigid lever give almost the **same reaction** (the beam loads the property-line footing with more than comes down through its column) and the resultant returns **near the center**.
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
#: **Deformed shape** (×10): the footing no longer rotates; it goes down almost whole:
#modelo3d(X_d, e_j, e_f, w_j, v_f, U_3, 10)

## 12 · Bearing capacity with beam (GEO5 method, sheet 106)

#: With the FEM resultant the same as GEO5 is applied: effective width B − 2e, Brinch-Hansen with φ_{d} = 40.21° and γ₂ = 18.95 (GEO5 datum, sheet 104):
φ_d = 40.21 'homogenized φ, from the GEO5 report [degrees]
c_d = 5 'cohesion [kPa]
γ_2 = 18.95 'γ below the bottom, from GEO5 [kN/m3]
f_d = φ_d·pi/180 'in radians
q_0 = γ_1·d_f 'surcharge at bottom level [kPa]
N_q = tan(pi/4 + f_d/2)^2·exp(pi·tan(f_d)) 'surcharge factor
N_cc = (N_q - 1)/tan(f_d) 'cohesion factor
N_γ = 1.5·(N_q - 1)·tan(f_d) 'self-weight factor
H_r = sqrt(H_x^2 + H_y^2) 'horizontal [kN]
b_v2 = l_x - 2·abs(x_R) 'effective width with the FEM resultant [m]
σ_v = R_s/(b_v2·l_y) 'Meyerhof pressure [kPa]
R_dv = (c_d·N_cc·(1 + 0.2·b_v2/l_y)·(1 + 0.1·sqrt(d_f/b_v2)) + q_0·N_q·(1 + b_v2/l_y·sin(f_d))·(1 + 0.1·sqrt(d_f/b_v2·sin(2·f_d))) + b_v2/2·γ_2·N_γ·(1 - 0.3·b_v2/l_y))·(1 - H_r/R_s)^2 'bearing capacity [kPa]
FS_v = R_dv/σ_v 'safety factor with beam (FEM)

## 13 · Sensitivity: a weaker beam (0.30 × 0.60 m)

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
#: A more flexible beam lets the footing rotate somewhat: the resultant moves away from the center and the FS drops. The beam **has to be stiff** compared with the footing (here 3EI/L ≫ k_{s}·I of the footing).

## 14 · Hekatan LISP against Hekatan Struct, node by node

#: Struct ran the same model (`tests/zapata_fem/c4.heks`: 169 plate nodes + that of the interior column, the 0.40 × 0.90 `frame` bar and the `spring` of the interior footing). Its 170 deflections (mm):
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
Δ_c4 = 100·d_w/w_mx 'worst node, LISP against Struct, in % of the maximum deflection


## 15 · Summary: Hekatan LISP (FEM) · Hekatan Struct · GEO5 / analytical

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
#: **Why the FEM and the lever of sheet 106 almost coincide:** the 0.90 m beam is much stiffer than the rotation of the footing on the soil, so it behaves like the rigid lever of the book. The FEM adds what the lever does not give: the real pressure (an almost uniform trapezoid, now without a lifted zone), the moment the beam is designed for and what happens if the beam is weaker (section 13).

## 16 · NEC-SE-GC 2015

#: · **Table 6, §6.2 (p. 42):** FS ≥ 3.0. With the beam the FS rises to ≈ 1.5: it improves a lot, but it **still does not comply** (the same as the centered one, sheet 135): the 1.20 m footing is small for 3000 kN. It has to be enlarged as well as tied.
#: · **Table 7 (p. 44):** angular distortion between columns ≤ L/300 (concrete frames):
β_lim = 1/300 'NEC limit
#: β = |w_{property line} − w_{interior}|/L_{v}: @{r_bv} ‰ against 3.33 ‰. It complies.
