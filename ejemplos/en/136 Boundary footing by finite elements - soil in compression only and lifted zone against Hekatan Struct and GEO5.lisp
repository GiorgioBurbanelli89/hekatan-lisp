# Boundary footing by finite elements: soil in compression only, lifted zone, against Hekatan Struct and GEO5
#numerico

#: **What is calculated.** The 1.20 × 1.20 × 0.40 m footing of GEO5's Demo01 with the column **at the boundary** (1 cm from the edge, sheet 106). The load falls 0.41 m from the center, outside the middle third: with a linear pressure, more than half of the footing would have to "pull" on the soil. The soil does not pull: the footing **lifts** at the opposite edge and the problem stops being linear.
#: **With what.** The thick plate and the area springs of **Hekatan Struct** (sheet 135), now with **compression-only** springs (CSI Gap law) solved by active set. It is compared node by node with Struct (same .heks), with the analytical **rigid footing** (Das, eq. 6.53: pressure triangle) and with the **Meyerhof effective area** used by GEO5 (0.39 m strip).

## 1 · Data (GEO5 Demo01, sheets 104 to 106)

l_x = 1.2 'footing side in x [m]
l_y = 1.2 'footing side in y [m]
t_z = 0.4 'footing depth [m]
c_x = 0.4 'column side [m]
d_f = 1.2 'depth of the bottom from the grade [m]
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


#: **Where the column is (sheet 106).** GEO5 asks for a_{x}, the distance from the edge to the column face: a_{x} = 0.01 m, so the axis is at 0.01 + 0.20 = 0.21 m from the edge, at p = 0.39 m from the center. The GEO5 eccentricity (help "Stress in the Footing Bottom") adds that of the displaced axial N·p:
a_x = 0.01 'from the edge to the column face (GEO5) [m]
p_x = a_x + c_x/2 - l_x/2 'column axis from the center, in x [m]

e_x = (-M_y + H_x·t_z + N_1·p_x)/V_d 'eccentricity in x (GEO5: 0.339·1.2 = 0.407) [m]
e_y = (M_x + H_y·t_z)/V_d 'eccentricity in y [m]

## 1b · The footing drawn, with its loads and dimensions

#: **How to read it.** Two views to scale, in meters. **Plan:** the thick square is the 1.20 × 1.20 m footing; the gray square, the 0.40 × 0.40 m column (the column is **against the left boundary** (0.01 m from the edge): its axis is 0.39 m from the center). The red arrows are the horizontal loads of load 1 (H_{x} = 14 kN and H_{y} = 5 kN) and N = 3000 kN goes down the column axis; M_{y} = 70 kN·m and M_{x} = −2 kN·m rotate it. The green cross marks the **resultant** at the bottom: it is at e_{x} = -0.407 m and e_{y} = +0.000 m from the center. **Section:** the 0.40 m footing buried 1.20 m below the grade, resting on **Winkler springs** (vertical blue lines: each mesh node carries one and it only works in compression).
#dibujo("Plan: 1.20 × 1.20 m boundary footing, 0.40 m column, loads of load 1 and resultant", ud = m, escala = auto, cotas = m, alto = 150)
#  rect(-l_x/2, -l_y/2, l_x, l_y, "gruesa")
#  achurado(-l_x/2, -l_y/2, l_x, l_y, "concreto")
#  rect(-0.590, -0.200, c_x, c_x, "denso")
#  linea(-0.8, 0, 0.8, 0, "eje")
#  linea(0, -0.8, 0, 0.8, "eje")
#  circulo(-0.390, 0.000, 0.05, "rojo")
#  flecha(-0.390, 0.000, -0.110, 0.000, "rojo")
#  flecha(-0.390, 0.000, -0.390, 0.100, "rojo")
#  texto(-0.090, -0.100, "Hx", 2.5, "i")
#  texto(-0.340, 0.160, "Hy", 2.5, "i")
#  texto(-0.340, -0.280, "N = 3000 kN", 2.5, "i")
#  linea(-0.447, 0.000, -0.367, 0.000, "media verde")
#  linea(-0.407, -0.040, -0.407, 0.040, "media verde")
#  texto(-0.407, -0.120, "resultant", 2.5, "c", estilo = "verde")
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
#: **What they show.** The plan says where the load falls with respect to the center: the more eccentric the resultant, the less compressed soil area (in the boundary footing, part of the bottom is left without pressure: the soil does not pull the footing). The section says why the finite element model rests on compression-only springs: the bottom is 1.20 m deep and the soil only pushes.

## 2 · Subgrade modulus (criterion of sheet 135)

#: Calibrated with GEO5's settlement (sheet 105): the service load 3 gives a net pressure q_{n} and GEO5 a settlement of 15.9 mm; k_{s} = q_{n}/s.
q_n = (1500 + G_z + Z_r)/(l_x·l_y) - γ_1·d_f 'net pressure of load 3 [kPa]
k_s = q_n/0.0159 'subgrade modulus [kN/m3]


## 3 · Finite element mesh

#: Regular mesh of 10 cm square elements. The nodes are numbered as in the Hekatan Struct .heks: row by row, from x = −0.6 to 0.6 and from y = −0.6 upward. That way the comparison is **node by node**.
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


#: **The column in the mesh.** With 10 cm elements, the column footprint is placed **flush with the edge** (from −0.6 to −0.2: axis at −0.40). The centimeter missing up to the real axis (−0.39) is not lost: it enters as a moment N·0.01 = 30 kN·m at the axis node. That way the resultant is **exactly** GEO5's.


## 4 · The element (that of sheet 135)

#: The **Hekatan Struct thick plate** = CSI Shell-Thick (`getBendingK_CSI`, shellQ4.cpp): rotations with 9 functions (4 nodal, 4 side, 1 bubble), symmetrized Wilson side shear, penalty 1000·tr(D_{b}) of the divergence of the rotations, 8 Gauss points, B-bar and condensation of the 10 internal ones. The derivation is in sheet 135; here it is calculated the same way.
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
A_k = sum(k_n)/k_s 'sum of the springs / k_s = footing area [m2]
#: **Compression only.** The soil pushes but does not pull. It is the CSI "Gap" law (Analysis Reference Manual, p. 286; SAFE "Nonlinear Analysis for Uplift"): f = k·w if the node goes down (w < 0), f = 0 if it goes up. Hekatan Struct solves it by **active set** (`muellesSoloCompresion.ts`): solve with all the springs, switch off those of the nodes that go up, solve again, until the set does not change. For this law the result is exact, with no tolerances.


## 6 · Loads

#: Three things: (1) the weight of the footing and the fill, distributed over the whole plan; (2) the column axial, distributed over its 40 × 40 cm footprint; (3) the remaining moments, as a moment at the column axis node. Each element takes its distributed load to its 4 nodes (a quarter each: it is the consistent vector of a uniform pressure on a rectangle).
q_g = (G_z + Z_r)/(l_x·l_y) 'weight of the footing and fill [kPa]
q_c = N_1/c_x^2 'pressure of the column over its footprint [kPa]
x_c = -0.4 'axis of the footprint in the mesh (flush with the edge) [m]
y_c = 0 'column axis in y [m]
#: Moment missing at the axis node (right-hand rule: M_{Y} = e_{x}·V, M_{X} = −e_{y}·V), discounting what the column already puts on its footprint:
M_Xn = -e_y·V_d 'moment about x [kN·m]
M_Yn = e_x·V_d - N_1·x_c 'moment about y: that of the load + the centimeter [kN·m]
n_c = round((y_c + l_y/2)/h_e)·n_n + round((x_c + l_x/2)/h_e) + 1 'column axis node
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

#: It is solved with all the springs; the nodes that **go up** (w > 0) are released; it is solved again; until the set does not change. It is what Hekatan Struct does (`muellesSoloCompresion.ts`) and, with load steps, SAP2000/SAFE with the "Gap":
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

n_it 'solutions
h_1 = h_c(1) 'nodes in contact, 1st solution
h_2 = h_c(2) 'nodes in contact, 2nd solution
h_3 = h_c(3) 'nodes in contact, 3rd solution
h_4 = h_c(4) 'nodes in contact, 4th (the final)
n_ct = sum(a_c) 'nodes in contact at the end (of 169)
#: Struct did **the same 4 rounds with the same nodes**: 169 → 117 → 91 → 78.

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


## 9 · Contact pressure, lifted zone and deformed shape

p_max = max(p_j) 'maximum pressure, at the boundary edge [kPa]
w_min = min(w_j) 'largest settlement, boundary edge [mm]
w_max = max(w_j) 'largest uplift, opposite edge [mm]
R_s = sum(R_j) 'sum of the soil reactions = V [kN]
x_R = sum(R_j.*X_j)/R_s 'soil resultant = e_x [m]
A_c = sum(k_n.*a_c)/k_s 'contact area (area of the nodes that touch) [m2]
#hide
x_0 = l_x/2
for i = 1:n_x
  q = (n_x/2)·n_n + i
  if w_j(q) < 0 && w_j(q + 1) >= 0
    x_0 = X_j(q) + h_e·w_j(q)/(w_j(q) - w_j(q + 1))
  end
end
#show

a_cn = x_0 + l_x/2 'contact length along the axis y = 0 (where w changes sign) [m]
#: **Pressure map** (kPa): the whole load enters through the boundary strip; the rest of the footing is in the air (pressure 0):
p_xy(x, y) = spline(1 + (x + l_x/2)/h_e, 1 + (y + l_y/2)/h_e, P_m)
#map(p_xy(x, y), [-0.6 0.6], [-0.6 0.6])
#: **Pressure in 3D** (1 m = 10 000 kPa):
#hide
X_3 = zeros(n_j, 3)
X_d = zeros(n_j, 3)
U_3 = zeros(n_j, 3)
for q = 1:n_j
  X_3(q, 1) = X_j(q)
  X_3(q, 2) = Y_j(q)
  X_3(q, 3) = p_j(q)/10000
  X_d(q, 1) = X_j(q)
  X_d(q, 2) = Y_j(q)
  U_3(q, 3) = U(3·q - 2)
end
e_f = zeros(0, 2)
v_f = zeros(0, 2)
#show

#modelo3d(X_3, e_j, e_f, p_j, v_f)
#: **Deformed shape** (×2): the footing rotates about the boundary strip and the opposite edge **lifts** more than 13 cm. Color = deflection in mm (positive = up):
#modelo3d(X_d, e_j, e_f, w_j, v_f, U_3, 2)
#: **Contact zone** (1 = touches, 0 = lifted):
#hide
C_m = zeros(n_n, n_n)
for j = 1:n_n
  for i = 1:n_n
    C_m(i, j) = a_c((j - 1)·n_n + i)
  end
end
#show
c_xy(x, y) = spline(1 + (x + l_x/2)/h_e, 1 + (y + l_y/2)/h_e, C_m)
#map(c_xy(x, y), [-0.6 0.6], [-0.6 0.6])
#hide
w_f = w_j
p_1 = p_max
a_1 = a_cn
A_1 = A_c
w_1 = w_max
n_1 = n_ct
i_1 = n_it
#show

## 10 · The rigid footing: FEM and Das's formula

#: **Formula (Das, eq. 6.53; Tomlinson):** rigid footing, soil without tension, e > B/6. The pressure is a **triangle**: its resultant (at one third of the length) must fall under the load, at B/2 − e from the edge, and its volume must equal V:
a_D = 3·(l_x/2 - abs(e_x)) 'contact length, rigid [m]
q_D = 2·V_d/(3·l_y·(l_x/2 - abs(e_x))) 'maximum pressure, rigid [kPa]
#: **Does the footing bend?** Its elastic length on Winkler, ℓ = (D/k_{s})^{1/4}, is greater than the side: it is practically **rigid**. It is checked with the same FEM and the plate **10 times stiffer** (the K of the plate is proportional to E: it is enough to multiply it):
l_el = (D_0/k_s)^(1/4) 'elastic length [m]
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
w_j = zeros(n_j, 1)
for q = 1:n_j
  w_j(q) = 1000·U(3·q - 2)
end
#show
#hide
p_r = 0
for q = 1:n_j
  p_r = max(p_r, -k_s·U(3·q - 2)·a_c(q))
end
#show
p_r 'maximum pressure, plate 10 times stiffer [kPa]
#hide
x_0 = l_x/2
for i = 1:n_x
  q = (n_x/2)·n_n + i
  if w_j(q) < 0 && w_j(q + 1) >= 0
    x_0 = X_j(q) + h_e·w_j(q)/(w_j(q) - w_j(q + 1))
  end
end
#show

a_r = x_0 + l_x/2 'contact length, plate 10 times stiffer [m]
#: It changes 0.2 %: the 40 cm footing **is already rigid**. Then why does the FEM not give Das exactly? Because of the **mesh**: the springs are concentrated at nodes every 10 cm and the edge of the contact falls between two nodes; that lengthens the contact a little (0.595 versus 0.579 m) and lowers the peak. Measured with the same model (casos.py, which is Struct to 1e-6 %) refining the mesh: maximum pressure **8507 → 8693 → 8729 kPa** with 10, 5 and 2.5 cm elements, versus 8728 from Das. The FEM converges to the formula.

## 11 · Hekatan LISP against Hekatan Struct, node by node

#: Struct ran the same model (`tests/zapata_fem/c2.heks`) with its code untouched. Its 169 deflections (mm), saved here:
#hide
w_S = [-129.0644750, -107.3230314, -85.5896762, -63.8627917, -42.1396866, -20.4174536, 1.3068137, 23.0357470, 44.7685549, 66.5044782, 88.2428688, 109.9831909, 131.7247766, -129.1387879, -107.3942880, -85.6564616, -63.9236552, -42.1937160, -20.4644156, 1.2664901, 23.0011715, 44.7386435, 66.4781250, 88.2190482, 109.9609549, 131.7033948, -129.2273503, -107.4781907, -85.7341962, -63.9933690, -42.2540554, -20.5151932, 1.2243465, 22.9660906, 44.7089784, 66.4524310, 88.1961052, 109.9397698, 131.6832402, -129.3289404, -107.5737558, -85.8220981, -64.0707314, -42.3186005, -20.5667917, 1.1835518, 22.9332740, 44.6819100, 66.4293972, 88.1758067, 109.9212277, 131.6657749, -129.4380610, -107.6766464, -85.9170193, -64.1539984, -42.3833553, -20.6131992, 1.1486492, 22.9061137, 44.6600084, 66.4110653, 88.1598391, 109.9067765, 131.6522569, -129.5228975, -107.7571060, -85.9908718, -64.2180544, -42.4318577, -20.6461117, 1.1248352, 22.8880398, 44.6456970, 66.3992262, 88.1496227, 109.8975872, 131.6436983, -129.5522776, -107.7850473, -86.0160875, -64.2391635, -42.4485820, -20.6581018, 1.1163358, 22.8816941, 44.6407084, 66.3951340, 88.1461033, 109.8944346, 131.6407697, -129.5228975, -107.7571060, -85.9908718, -64.2180544, -42.4318577, -20.6461117, 1.1248352, 22.8880399, 44.6456970, 66.3992262, 88.1496227, 109.8975872, 131.6436983, -129.4380610, -107.6766464, -85.9170192, -64.1539984, -42.3833552, -20.6131992, 1.1486493, 22.9061137, 44.6600084, 66.4110654, 88.1598391, 109.9067765, 131.6522570, -129.3289404, -107.5737558, -85.8220981, -64.0707314, -42.3186005, -20.5667916, 1.1835518, 22.9332740, 44.6819101, 66.4293972, 88.1758067, 109.9212277, 131.6657750, -129.2273502, -107.4781907, -85.7341962, -63.9933690, -42.2540554, -20.5151931, 1.2243465, 22.9660906, 44.7089785, 66.4524311, 88.1961053, 109.9397699, 131.6832403, -129.1387879, -107.3942879, -85.6564616, -63.9236552, -42.1937160, -20.4644155, 1.2664902, 23.0011716, 44.7386435, 66.4781251, 88.2190483, 109.9609549, 131.7033949, -129.0644749, -107.3230314, -85.5896761, -63.8627917, -42.1396865, -20.4174535, 1.3068138, 23.0357471, 44.7685549, 66.5044783, 88.2428689, 109.9831910, 131.7247767]
d_w = 0
w_mx = 0
for q = 1:n_j
  d_w = max(d_w, abs(w_f(q) - w_S(q)))
  w_mx = max(w_mx, abs(w_S(q)))
end
#show
Δ_c2 = 100·d_w/w_mx 'worst node, LISP against Struct, in % of the maximum deflection

#hide
S_ct = 0
for q = 1:n_j
  S_ct = S_ct + (1 - sign(w_S(q)))/2
end
r_Sct = S_ct
S_pmax = round(-k_s·min(w_S)/1000, 2)
S_wmax = round(max(w_S), 3)
#show
#hide
x_0 = l_x/2
for i = 1:n_x
  q = (n_x/2)·n_n + i
  if w_S(q) < 0 && w_S(q + 1) >= 0
    x_0 = X_j(q) + h_e·w_S(q)/(w_S(q) - w_S(q + 1))
  end
end
#show

S_a = round(x_0 + l_x/2, 4) 'contact length of Struct on y = 0 [m]

## 12 · Summary: Hekatan LISP (FEM) · Hekatan Struct · GEO5 / analytical

#hide
g_b = 0.386
g_s = 6545.84
g_Rd = 2698.37
g_FS = 0.41
r_p1 = round(p_1, 2)
r_a1 = round(a_1, 4)
r_A1 = round(A_1, 3)
r_w1 = round(w_1, 3)
r_pr = round(p_r, 2)
r_ar = round(a_r, 4)
r_aD = round(a_D, 4)
r_qD = round(q_D, 2)
r_d = round(Δ_c2, 6)
r_gA = round(g_b·l_y, 3)
#show
#| Magnitud | Hekatan LISP (FEM) | Hekatan Struct (FEM) | rígida (Das) | GEO5 (Meyerhof) |
#|---|---:|---:|---:|---:|
#| nudos en contacto (de 169) / resoluciones | @{n_1} / @{i_1} | @{r_Sct} / 4 | | |
#| largo en contacto sobre y = 0 [m] | @{r_a1} | @{S_a} | @{r_aD} (FEM, E × 10: @{r_ar}) | ancho efectivo @{g_b} |
#| área en contacto [m²] | @{r_A1} | | | @{r_gA} |
#| presión máxima [kPa] | @{r_p1} | @{S_pmax} | @{r_qD} (FEM, E × 10: @{r_pr}) | @{g_s} (uniforme) |
#| levantamiento del borde opuesto [mm] | @{r_w1} | @{S_wmax} | | |
#| peor nudo LISP − Struct [% del máx.] | @{r_d} | — | | |
#: **Why FEM and Meyerhof differ.** The three answers have **the same resultant** (V = 3033.7 kN at 0.407 m from the center) and distribute differently:
#: · **Meyerhof (GEO5):** uniform rectangle of width B − 2e = 0.386 m centered on the resultant. It is not the real pressure: it is the convention for the **bearing capacity** (σ = 6546 kPa against R_{d} = 2698 kPa → FS = 0.41).
#: · **Rigid (Das):** triangle of length 3(B/2 − e) = 0.58 m and peak 2V/(3·L·(B/2 − e)) ≈ 8730 kPa: twice the mean, because a triangle has its maximum at twice its average.
#: · **Plate on Winkler (FEM):** the footing is almost rigid (ℓ = 1.26 m > 1.20 m), so the FEM gives Das's triangle, discretized at 10 cm nodes (−2.5 % at the peak; it converges on refining). It is the **service** pressure, the one used to reinforce the footing.
#: The Meyerhof strip is narrower than the triangle (0.39 versus 0.58 m) because it is made so that a uniform block has the same resultant, not to resemble the pressure.

## 13 · NEC-SE-GC 2015

#: · **Table 6, §6.2 (p. 42):** FS ≥ 3.0 (DL + normal LL). GEO5 gives FS = 0.41: **it does not pass**, not even close.
#: · **Table 5, §5.2 (p. 36-38):** e/B ≤ 1/6 (the table is for walls; using it for footings is our criterion). Here e/B = 0.339: outside the middle third, which is exactly what this FEM shows: **half of the footing in the air** and the edge lifted more than 13 cm. A result like that is not "designed": the system must be changed. The solution is the **tie beam** (sheet 138).
e_B = abs(e_x)/l_x 'relative eccentricity (NEC: ≤ 0.167)
