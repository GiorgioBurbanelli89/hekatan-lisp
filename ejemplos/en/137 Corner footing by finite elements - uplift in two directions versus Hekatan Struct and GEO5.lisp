# Corner footing by finite elements: uplift in two directions, versus Hekatan Struct and GEO5
#numerico

#: **What is computed.** The GEO5 Demo01 footing with the column **at the corner** (1 cm from two edges, sheet 106). The resultant falls 0.41 m from the center in x and 0.39 m in y: almost at the corner. With soil that does not pull, only one **corner** of the footing stays supported.
#: **With what.** The thick plate and compression-only springs of **Hekatan Struct** (sheets 135 and 136), node by node against Struct; the rigid footing (pressure pyramid, closed formula) and the GEO5 **effective area** (0.39 × 0.43 m).

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


#: **Where the column sits (sheet 106).** GEO5 asks for a_{x}, the distance from the edge to the column face: a_{x} = 0.01 m, so the axis is at 0.01 + 0.20 = 0.21 m from the edge, at p = 0.39 m from the center. The GEO5 eccentricity (help «Stress in the Footing Bottom») adds that of the offset axial load N·p:
a_x = 0.01 'from the edge to the column face (GEO5) [m]
p_x = a_x + c_x/2 - l_x/2 'column axis from the center, in x [m]

p_y = a_x + c_x/2 - l_y/2 'column axis from the center, in y [m]
e_x = (-M_y + H_x·t_z + N_1·p_x)/V_d 'eccentricity in x (GEO5: 0.339·1.2) [m]
e_y = (M_x + H_y·t_z + N_1·p_y)/V_d 'eccentricity in y (GEO5: 0.321·1.2) [m]

## 1b · The footing drawn, with its loads and dimensions

#: **How to read it.** Two scaled views, in meters. **Plan:** the thick square is the 1.20 × 1.20 m footing; the gray square, the 0.40 × 0.40 m column (the column is at the **corner** (0.01 m from both edges): its axis is 0.39 m from the center in x and in y). The red arrows are the horizontal loads of load 1 (H_{x} = 14 kN and H_{y} = 5 kN) and N = 3000 kN goes down along the column axis; M_{y} = 70 kN·m and M_{x} = −2 kN·m rotate it. The green cross marks the **resultant** at the bottom: it is at e_{x} = -0.407 m and e_{y} = -0.386 m from the center. **Section:** the 0.40 m footing buried 1.20 m below the ground surface, resting on **Winkler springs** (vertical blue lines: every mesh node carries one and it only works in compression).
#dibujo("Plan: corner footing of 1.20 × 1.20 m, column of 0.40 m, loads of load 1 and resultant", ud = m, escala = auto, cotas = m, alto = 150)
#  rect(-l_x/2, -l_y/2, l_x, l_y, "gruesa")
#  achurado(-l_x/2, -l_y/2, l_x, l_y, "concreto")
#  rect(-0.590, -0.590, c_x, c_x, "denso")
#  linea(-0.8, 0, 0.8, 0, "eje")
#  linea(0, -0.8, 0, 0.8, "eje")
#  circulo(-0.390, -0.390, 0.05, "rojo")
#  flecha(-0.390, -0.390, -0.110, -0.390, "rojo")
#  flecha(-0.390, -0.390, -0.390, -0.290, "rojo")
#  texto(-0.090, -0.490, "Hx", 2.5, "i")
#  texto(-0.340, -0.230, "Hy", 2.5, "i")
#  texto(-0.340, -0.670, "N = 3000 kN", 2.5, "i")
#  linea(-0.447, -0.386, -0.367, -0.386, "media verde")
#  linea(-0.407, -0.426, -0.407, -0.346, "media verde")
#  texto(-0.407, -0.506, "resultant", 2.5, "c", estilo = "verde")
#  cota(-l_x/2, -0.82, l_x/2, -0.82, -0.05, "1.20")
#  cota(0.82, -l_y/2, 0.82, l_y/2, 0.05, "1.20")
#  cota(-0.590, 0.82, -0.190, 0.82, 0.05, "0.40")
#fin
#dibujo("Section: 0.40 m footing at 1.20 m depth on Winkler springs (blue lines)", ud = m, escala = auto, cotas = m, alto = 130)
#  linea(-1.6, 0, 1.6, 0, "media verde")
#  rect(-l_x/2, -d_f, l_x, t_z, "gruesa")
#  achurado(-l_x/2, -d_f, l_x, t_z, "concreto")
#  rect(-0.590, -d_f + t_z, c_x, d_f - t_z + 0.6, "gruesa")
#  linea(-1.6, -d_f, -l_x/2, -d_f, "trazos")
#  linea(l_x/2, -d_f, 1.6, -d_f, "trazos")
#  linea(-0.55, -d_f, -0.55, -d_f - 0.3, "media azul")
#  linea(-0.35, -d_f, -0.35, -d_f - 0.3, "media azul")
#  linea(-0.15, -d_f, -0.15, -d_f - 0.3, "media azul")
#  linea(0.05, -d_f, 0.05, -d_f - 0.3, "media azul")
#  linea(0.25, -d_f, 0.25, -d_f - 0.3, "media azul")
#  linea(0.45, -d_f, 0.45, -d_f - 0.3, "media azul")
#  flecha(-0.390, 0.95, -0.390, -d_f + t_z + 0.62, "rojo")
#  texto(-0.340, 1.0, "N = 3000 kN", 2.5, "i")
#  flecha(-0.840, 0.4, -0.590, 0.4, "rojo")
#  texto(-0.840, 0.5, "Hx = 14 kN", 2.5, "i")
#  texto(0.9, -d_f - 0.2, "springs k_s", 2.5, "i", estilo = "azul")
#  cota(1.0, -d_f, 1.0, 0, 0.1, "1.20")
#  cota(-0.8, -d_f, -0.8, -d_f + t_z, -0.1, "0.40")
#  cota(-l_x/2, -d_f - 0.45, l_x/2, -d_f - 0.45, -0.05, "1.20")
#fin
#: **What they show.** The plan tells where the load falls with respect to the center: the more eccentric the resultant, the less compressed soil area (in the corner footing, part of the bottom is left without pressure: the soil does not pull the footing). The section tells why the finite element model rests on compression-only springs: the bottom is at 1.20 m depth and the soil only pushes.

## 2 · Subgrade modulus (criterion of sheet 135)

#: Calibrated with the GEO5 settlement (sheet 105): service load 3 gives a net pressure q_{n} and GEO5 a settlement of 15.9 mm; k_{s} = q_{n}/s.
q_n = (1500 + G_z + Z_r)/(l_x·l_y) - γ_1·d_f 'net pressure of load 3 [kPa]
k_s = q_n/0.0159 'subgrade modulus [kN/m3]


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


#: **The column in the mesh.** With 10 cm elements, the column footprint is placed **flush with the edge** (from −0.6 to −0.2: axis at −0.40). The missing centimeter up to the real axis (−0.39) is not lost: it enters as a moment N·0.01 = 30 kN·m at the axis node. That way the resultant is **exactly** the GEO5 one.

#: The same in y: footprint from −0.6 to −0.2, and the centimeter as a moment.

## 4 · The element (the one from sheet 135)

#: The **Hekatan Struct thick plate** = CSI Shell-Thick (`getBendingK_CSI`, shellQ4.cpp): rotations with 9 functions (4 node, 4 edge, 1 bubble), symmetrized Wilson edge shear, 1000·tr(D_{b}) penalty of the rotation divergence, 8 Gauss points, B-bar and condensation of the 10 internal dof. The derivation is in sheet 135; here it is computed the same way.
a_e = h_e 'element side in x [m]
b_e = h_e 'element side in y [m]
D_0 = E_c·t_z^3/(12·(1 - ν^2)) 'flexural rigidity [kN·m]
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
#: Condensed to 12 × 12 (K_{e} = K_{bb} − K_{bi}·K_{ii}⁻¹·K_{ib}); its first term, as a check:
K_e11 = K_e(1, 1) 'term w₁-w₁ (Struct: 2 735 178.7) [kN/m]


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
x_c = -0.4 'footprint axis in x (flush with the edge) [m]
y_c = -0.4 'footprint axis in y [m]
M_Xn = -e_y·V_d + N_1·y_c 'moment about x [kN·m]
M_Yn = e_x·V_d - N_1·x_c 'moment about y [kN·m]
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


## 8 · Solution: the active set

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

n_it 'solves (Struct: 6)
h_1 = h_c(1) 'contact at the 1st solve
h_2 = h_c(2) 'at the 2nd
h_3 = h_c(3) 'at the 3rd
h_4 = h_c(4) 'at the 4th
h_5 = h_c(5) 'at the 5th
h_6 = h_c(6) 'at the 6th (final)
n_ct = sum(a_c) 'nodes in contact at the end (out of 169)
#: Struct: 169 → 120 → 83 → 60 → 48 → 43. **The same 6 iterations.**

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


## 9 · Contact pressure, uplifted zone and deformed shape

p_max = max(p_j) 'maximum pressure, at the column corner [kPa]
w_min = min(w_j) 'largest settlement [mm]
w_max = max(w_j) 'largest uplift, opposite corner [mm]
R_s = sum(R_j) 'sum of the reactions = V [kN]
x_R = sum(R_j.*X_j)/R_s 'soil resultant in x = e_x [m]
y_R = sum(R_j.*Y_j)/R_s 'soil resultant in y = e_y [m]
A_c = sum(k_n.*a_c)/k_s 'contact area (area of the nodes that touch) [m2]
#: **Pressure map** (kPa):
p_xy(x, y) = spline(1 + (x + l_x/2)/h_e, 1 + (y + l_y/2)/h_e, P_m)
#map(p_xy(x, y), [-0.6 0.6], [-0.6 0.6])
#: **Pressure in 3D** (1 m = 20 000 kPa): a «peak» at the corner:
#hide
X_3 = zeros(n_j, 3)
X_d = zeros(n_j, 3)
U_3 = zeros(n_j, 3)
for q = 1:n_j
  X_3(q, 1) = X_j(q)
  X_3(q, 2) = Y_j(q)
  X_3(q, 3) = p_j(q)/20000
  X_d(q, 1) = X_j(q)
  X_d(q, 2) = Y_j(q)
  U_3(q, 3) = U(3·q - 2)
end
e_f = zeros(0, 2)
v_f = zeros(0, 2)
#show

#modelo3d(X_3, e_j, e_f, p_j, v_f)
#: **Deformed shape** (×1): the footing pivots on the corner and the opposite one rises **more than 70 cm** with a linear elastic soil. That number is not real (before that the soil fails and the footing overturns), but it says what has to be said: it cannot be built like this.
#modelo3d(X_d, e_j, e_f, w_j, v_f, U_3, 1)
#hide
C_m = zeros(n_n, n_n)
for j = 1:n_n
  for i = 1:n_n
    C_m(i, j) = a_c((j - 1)·n_n + i)
  end
end
#show
#: **Contact zone** (1 = touching, 0 = uplifted): a triangle/quadrant at the corner:
c_xy(x, y) = spline(1 + (x + l_x/2)/h_e, 1 + (y + l_y/2)/h_e, C_m)
#map(c_xy(x, y), [-0.6 0.6], [-0.6 0.6])
#hide
w_f = w_j
p_1 = p_max
A_1 = A_c
w_1 = w_max
n_1 = n_ct
i_1 = n_it
#show

## 10 · The rigid footing: the pressure pyramid

#: **Formula.** If the footing is rigid, the pressure is a plane that vanishes along a line. When that line cuts both edges, the contact is a **triangle** with the right angle at the loaded corner, with legs a and b, and the pressure is a **pyramid** (a tetrahedron) of height q. Two conditions: (1) the centroid of a tetrahedron is at 1/4 of its edges: the resultant falls at a/4 and b/4 from the corner; (2) its volume is q·(a·b/2)/3 = V:
d_x = l_x/2 - abs(e_x) 'from the corner to the resultant, in x [m]
d_y = l_y/2 - abs(e_y) 'from the corner to the resultant, in y [m]
a_P = 4·d_x 'contact leg in x (less than 1.2: the triangle fits) [m]
b_P = 4·d_y 'contact leg in y [m]
A_P = a_P·b_P/2 'contact area, rigid [m2]
q_P = 6·V_d/(a_P·b_P) 'pressure at the corner, rigid [kPa]
#: **Is this footing rigid?** Same FEM with the plate 10 times stiffer:
#hide
a_c = ones(n_j, 1)
h_c = zeros(30, 1)
n_it = 0
#show
for i_t = 1:30
  K_t = 10·K
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
p_r = 0
for q = 1:n_j
  p_r = max(p_r, -k_s·U(3·q - 2)·a_c(q))
end
#show
p_r 'maximum pressure, plate 10 times stiffer [kPa]
n_r = sum(a_c) 'nodes in contact, plate 10 times stiffer
#: Almost the same: it is rigid. The difference with the pyramid (26 303 against 27 486 kPa) is the **mesh** (springs concentrated at 10 cm nodes; the peak of a pyramid is exactly what is hardest to discretize). Measured with the same model refining the mesh: **26 303 → 27 173 → 27 406 kPa** with elements of 10, 5 and 2.5 cm: it converges to the formula.

## 11 · Hekatan LISP versus Hekatan Struct, node by node

#: Struct ran the same model (`tests/zapata_fem/c3.heks`). Its 169 deflections (mm):
#hide
w_S = [-400.5588750, -349.7962833, -299.0343115, -248.2633750, -197.4752815, -146.6865055, -95.9140201, -45.1509237, 5.6088213, 56.3706251, 107.1326693, 157.8949046, 208.6573375, -354.2359322, -303.4742697, -252.7127807, -201.9432977, -151.1573823, -100.3699154, -49.5973534, 1.1666905, 51.9300595, 102.6926235, 153.4551236, 204.2175721, 254.9800740, -307.9100625, -257.1510221, -206.3920172, -155.6246534, -104.8414730, -54.0554156, -3.2825927, 47.4856816, 98.2508616, 149.0146473, 199.7776727, 250.5403484, 301.3028859, -261.5704787, -210.8142844, -160.0598425, -109.2975705, -58.5188758, -7.7365263, 43.0376031, 93.8067595, 144.5729888, 195.3374014, 246.1007841, 296.8635727, 347.6260589, -215.2089099, -164.4553815, -113.7052861, -62.9500682, -12.1825959, 38.5919899, 89.3630650, 140.1312207, 190.8971339, 241.6615147, 292.4248658, 343.1875700, 393.9498831, -168.8439236, -118.0930689, -67.3462967, -16.5963122, 34.1620928, 84.9267095, 135.6930961, 186.4588272, 237.2235152, 287.9872238, 338.7501740, 389.5125654, 440.2745765, -122.4953780, -71.7461022, -21.0005160, 29.7487188, 80.5039361, 131.2635752, 182.0257593, 232.7888027, 283.5518120, 334.3144834, 385.0767505, 435.8386557, 486.6002629, -76.1584163, -25.4093153, 25.3383695, 76.0889659, 126.8428600, 177.5999792, 228.3594001, 279.1201610, 329.8815146, 380.6430268, 431.4044887, 482.1658066, 532.9269494, -29.8273525, 20.9234724, 71.6742027, 122.4258507, 173.1795116, 223.9353380, 274.6930561, 325.4521394, 376.2120910, 426.9725232, 477.7331783, 528.4938941, 579.2545646, 16.5029056, 67.2560185, 118.0082041, 168.7607946, 219.5145013, 270.2696939, 321.0263537, 371.7842669, 422.5431267, 473.3026450, 524.0625793, 574.8227384, 625.5829696, 62.8350279, 113.5885288, 164.3415429, 215.0946464, 265.8484288, 316.6032399, 367.3592152, 418.1162977, 468.8743324, 519.6331172, 570.3924500, 621.1521376, 671.9119992, 109.1677616, 159.9214304, 210.6747125, 261.4280005, 312.1817193, 362.9362115, 413.6916633, 464.4481198, 515.2055139, 565.9637158, 616.7225635, 667.4818779, 718.2414626, 155.5010797, 206.2547594, 257.0080289, 307.7612091, 358.5146837, 409.2687933, 460.0237570, 510.7796757, 561.5365351, 612.2942558, 663.0527064, 713.8117337, 764.5711318]
d_w = 0
w_mx = 0
for q = 1:n_j
  d_w = max(d_w, abs(w_f(q) - w_S(q)))
  w_mx = max(w_mx, abs(w_S(q)))
end
#show
Δ_c3 = 100·d_w/w_mx 'worst node, LISP versus Struct, as % of the maximum deflection

#hide
S_ct = 0
for q = 1:n_j
  S_ct = S_ct + (1 - sign(w_S(q)))/2
end
r_Sct = S_ct
S_pmax = round(-k_s·min(w_S)/1000, 2)
S_wmax = round(max(w_S), 3)
#show

## 12 · Summary: Hekatan LISP (FEM) · Hekatan Struct · GEO5 / analytical

#hide
g_bx = 0.386
g_by = 0.429
g_s = 18324.06
g_Rd = 3302.21
g_FS = 0.18
r_p1 = round(p_1, 2)
r_A1 = round(A_1, 3)
r_w1 = round(w_1, 2)
r_pr = round(p_r, 2)
r_AP = round(A_P, 4)
r_aP = round(a_P, 3)
r_bP = round(b_P, 3)
r_qP = round(q_P, 1)
r_d = round(Δ_c3, 6)
r_gA = round(g_bx·g_by, 4)
r_xR = round(x_R, 4)
r_yR = round(y_R, 4)
r_ex = round(e_x, 4)
r_ey = round(e_y, 4)
#show
#| Magnitud | Hekatan LISP (FEM) | Hekatan Struct (FEM) | rígida (pirámide) | GEO5 (Meyerhof) |
#|---|---:|---:|---:|---:|
#| nudos en contacto (de 169) / resoluciones | @{n_1} / @{i_1} | @{r_Sct} / 6 | (FEM, E × 10: @{n_r}) | |
#| área en contacto [m²] | @{r_A1} | | @{r_AP} (triángulo @{r_aP} × @{r_bP} / 2) | @{r_gA} (0.386 × 0.429) |
#| presión máxima [kPa] | @{r_p1} | @{S_pmax} | @{r_qP} (FEM, E × 10: @{r_pr}) | @{g_s} (uniforme) |
#| resultante del suelo (x; y) [m] | @{r_xR}; @{r_yR} | | | e = @{r_ex}; @{r_ey} |
#| levantamiento de la esquina opuesta [mm] | @{r_w1} | @{S_wmax} | | |
#| peor nudo LISP − Struct [% del máx.] | @{r_d} | — | | |
#: **Why FEM and Meyerhof differ.** As in sheet 136, both have the same resultant (checked in the table) and distribute differently. Meyerhof places a **uniform** rectangle of 0.386 × 0.429 m centered on the resultant (18 324 kPa): a convention for bearing capacity. The real footing, rigid on an elastic soil without tension, bears on a **triangle** twice as large (0.33 m²) with a pressure **pyramid**: the peak (≈ 27 500 kPa) is three times the mean over the triangle. The FEM reproduces it and, along the way, shows what Meyerhof does not say: the opposite corner lifts off.

## 13 · NEC-SE-GC 2015

#: · **Table 6, §6.2 (p. 42):** FS ≥ 3.0 → GEO5 gives 0.18: **does not meet**.
#: · **Table 5, §5.2 (our own criterion for footings):** e/B ≤ 1/6 in each direction; here 0.34 and 0.32.
#: · What the FEM adds: only ≈ 1/10 of the plan touches the soil and the opposite corner lifts off tens of cm. The corner footing **needs tie beams in both directions** (sheet 138 does it for one).
e_Bx = abs(e_x)/l_x 'relative eccentricity in x
e_By = abs(e_y)/l_y 'relative eccentricity in y
