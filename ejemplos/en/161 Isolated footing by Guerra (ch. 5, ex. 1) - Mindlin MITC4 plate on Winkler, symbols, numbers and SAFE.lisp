# Isolated footing by Guerra (chapter 5, exercise 1): Mindlin MITC4 plate on Winkler, symbols, numbers and SAFE
#numerico

#: **What is computed.** Exercise 1 of chapter 5 of the book *Cimentaciones sismo resistentes utilizando SAFE* (Eng. Marcelo Guerra, pp. 29 to 39): a square isolated footing of 3.45 × 3.45 m, depth 0.45 m, on a soil with subgrade modulus k_{s} = 2920 t/m³, with the 0.45 m column at the center. The book solves it with SAFE («Single Footing»); here it is solved with the same model written by hand: **symbols** (where the stiffnesses come from) and **numbers** (the 10 × 10 element mesh, 121 nodes).
#: **With what.** The **4-node Mindlin plate with MITC4-type shear**: 3 degrees of freedom per node [w, θ_{x}, θ_{y}] (right-hand rotations), bending with 2 × 2 Gauss points and shear interpolated from the side midpoints (the MITC4 trick against shear locking). The soil is **Winkler springs** at the nodes, k_{s} times the tributary area. The same four ideas are also solved by Python (numpy), Hekatan OpenSees and Hekatan Math Studio web: here they are compared node by node against numpy.
#: Units: t (force ton), m. Pressure in t/m², deflection in mm.

## 1 · Data (p. 31, Fig. 17, and p. 34, Fig. 25 of the book)

L_z = 3.45 'footing side, 1.725 on each side of the axis [m]
t_z = 0.45 'footing depth, first iteration of the book [m]
c_z = 0.45 'side of the square column [m]
k_s = 2920 'subgrade modulus of the subgrade soil [t/m3]
E_c = 14100·sqrt(280)·10 'modulus of concrete with f'c = 280 kg/cm2, 14100·√f'c = 2 359 381.3 [t/m2]
ν = 0.2 'Poisson's ratio of the concrete
γ_c = 2.4028 'unit weight of concrete [t/m3]
P_D = 91 'axial load, dead load (Dead) [t]
P_L = 30 'axial load, live load (Live) [t]
M_xD = 0 'moment in x, dead [t·m]
M_xL = 0 'moment in x, live [t·m]
M_yD = 12 'moment in y, dead [t·m]
M_yL = 5 'moment in y, live [t·m]
#: **Combinations of the book (p. 35):** VERTICAL LOAD = 1.0·D + 1.0·L (service, for the soil stress) and ULTIMATE LOAD = 1.4·D + 1.7·L (for design). The footing **self weight**, γ·h·area, goes inside DEAD (that is how SAFE does it).
f_Ds = 1.0 'dead load factor, service
f_Ls = 1.0 'live load factor, service
f_Du = 1.4 'dead load factor, ultimate
f_Lu = 1.7 'live load factor, ultimate
P_s = f_Ds·P_D + f_Ls·P_L 'service axial load [t]
M_ys = f_Ds·M_yD + f_Ls·M_yL 'service moment [t·m]
P_u = f_Du·P_D + f_Lu·P_L 'ultimate axial load [t]
M_yu = f_Du·M_yD + f_Lu·M_yL 'ultimate moment [t·m]
A_z = L_z^2 'footing area [m2]
q_pp = γ_c·t_z 'self weight per m2 [t/m2]
W_pp = q_pp·A_z 'footing self weight [t]

## 2 · Symbols: the plate stiffnesses

#: The Mindlin plate has **two** stiffnesses. In bending, D = E·t³/(12(1 − ν²)); in shear, C_{s} = κ·G·t with G = E/(2(1 + ν)) and the correction factor κ = 5/6.
D_flex = Simplify{Ec*t^3/(12*(1-nu^2))}
G_mod = Simplify{Ec/(2*(1+nu))}
C_cort = Simplify{5/6*Ec/(2*(1+nu))*t}
#: **The rigid footing (Navier).** If the footing were infinitely rigid on Winkler, the pressure would be a plane: p = P/A ± 6·M/(B·L²). It serves as a check: the real plate, which bends, departs a little from this figure.
p_max_s = Simplify{P/(B*L)+6*M/(B*L^2)}
p_min_s = Simplify{P/(B*L)-6*M/(B*L^2)}
#: **Elastic length** of the plate on Winkler, ℓ = (D/k_{s})^{1/4}: if it is of the order of the side, the footing works almost rigid; if it is much smaller, it bends locally.
l_el_s = Simplify{(D/ks)^(1/4)}

## 3 · Symbols: the MITC4 element of a 2a × 2b rectangle

#: Bilinear shape functions in the natural coordinates ξ, η (between −1 and 1), and their derivative with respect to x (∂/∂x = (1/a)·∂/∂ξ in a rectangle):
N_1 = Simplify{(1-xi)*(1-eta)/4}
dN1_dx = Simplify{-(1-eta)/(4*a)}
dN1_dy = Simplify{-(1-xi)/(4*b)}
#: **The MITC4 shear.** Instead of computing γ_{xz} at each Gauss point (which locks the thick-thin plate), it is measured at the two side midpoints A = (0, −1) and B = (0, +1) and **interpolated linearly in η**; γ_{yz} the same, from C = (−1, 0) and D = (+1, 0), linear in ξ:
g_xz_s = Simplify{(1-eta)/2*gA + (1+eta)/2*gB}
g_yz_s = Simplify{(1-xi)/2*gC + (1+xi)/2*gD}
#: **A closed-form stiffness coefficient.** Integrating by hand over the rectangle (∫(∂N₁/∂x)² dA = b/(3a), ∫(∂N₁/∂y)² dA = a/(3b), ∫N₁² dA = 4ab/9 and, with the MITC4 shear, ∫γ² dA = ab/3), the term of the rotation θ_{y1} with itself is K(θ_{y1}, θ_{y1}) = D·b/(3a) + D·(1 − ν)·a/(6b) + C_{s}·a·b/3 and that of the deflection w₁ with itself, K(w₁, w₁) = C_{s}·(b/(3a) + a/(3b)):
K_tyty_s = Simplify{D*b/(3*a) + D*(1-nu)*a/(6*b) + Cs*a*b/3}
K_ww_s = Simplify{Cs*(b/(3*a) + a/(3*b))}
#: In the square element of this mesh (a = b) they become K(θ_{y1}, θ_{y1}) = D·(1/3 + (1 − ν)/6) + C_{s}·a²/3 and K(w₁, w₁) = 2·C_{s}/3. Below they are compared with the numerical matrix.

## 4 · Finite element mesh

#: Regular mesh of 10 × 10 square elements of 0.345 m. The nodes are numbered row by row, from x = −1.725 to 1.725 and from y = −1.725 upward; it is the same numbering used by Python, OpenSees and Math Studio web, so the comparison is **node by node**.
n_x = 10 'elements per side
h_e = L_z/n_x 'side of each element [m]
n_n = n_x + 1 'nodes per side
n_j = n_n^2 'number of nodes (121)
n_e = n_x^2 'number of elements (100)
n_g = 3·n_j 'degrees of freedom
#hide
X_j = zeros(n_j, 1)
Y_j = zeros(n_j, 1)
for j = 1:n_n
  for i = 1:n_n
    q = (j - 1)·n_n + i
    X_j(q) = -L_z/2 + (i - 1)·h_e
    Y_j(q) = -L_z/2 + (j - 1)·h_e
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

## 5 · Numbers: the element stiffness (12 × 12)

a_e = h_e/2 'half side of the element in x [m]
b_e = h_e/2 'half side of the element in y [m]
D_0 = E_c·t_z^3/(12·(1 - ν^2)) 'flexural rigidity [t·m]
D_b = D_0·[1, ν, 0; ν, 1, 0; 0, 0, (1 - ν)/2] 'bending: moments with curvatures [t·m]
C_s = 5/6·E_c/(2·(1 + ν))·t_z 'shear stiffness, κ = 5/6 [t/m]
#: The shape functions and their derivatives, as rows of 4 (one per node):
N_n(r, s) = [(1 - r)·(1 - s)/4, (1 + r)·(1 - s)/4, (1 + r)·(1 + s)/4, (1 - r)·(1 + s)/4]
d_x(r, s) = [-(1 - s)/4, (1 - s)/4, (1 + s)/4, -(1 + s)/4]/a_e
d_y(r, s) = [-(1 - r)/4, -(1 + r)/4, (1 + r)/4, (1 - r)/4]/b_e
#: Each node has its 3 dof [w, θ_{x}, θ_{y}]: three 4 × 12 matrices choose which is which.
#hide
S_w = zeros(4, 12)
S_x = zeros(4, 12)
S_y = zeros(4, 12)
for k = 1:4
  S_w(k, 3·k - 2) = 1
  S_x(k, 3·k - 1) = 1
  S_y(k, 3·k) = 1
end
#show
#: **Curvatures** (right-hand rotations): κ_{x} = ∂θ_{y}/∂x, κ_{y} = −∂θ_{x}/∂y, κ_{xy} = ∂θ_{y}/∂y − ∂θ_{x}/∂x. **Shears** γ_{xz} = ∂w/∂x + θ_{y}, γ_{yz} = ∂w/∂y − θ_{x}.
B_b(r, s) = [transpose(d_x(r, s))·S_y; -transpose(d_y(r, s))·S_x; transpose(d_y(r, s))·S_y - transpose(d_x(r, s))·S_x]
B_xz(r, s) = transpose(d_x(r, s))·S_w + transpose(N_n(r, s))·S_y
B_yz(r, s) = transpose(d_y(r, s))·S_w - transpose(N_n(r, s))·S_x
#: **MITC4:** the shear at each Gauss point comes from interpolating those at the side midpoints (linear in η for γ_{xz}, linear in ξ for γ_{yz}):
G_xz(r, s) = (1 - s)/2·B_xz(0, -1) + (1 + s)/2·B_xz(0, 1)
G_yz(r, s) = (1 - r)/2·B_yz(-1, 0) + (1 + r)/2·B_yz(1, 0)
#: **Stiffness:** K_{e} = Σ |J|·( B_{b}ᵀ·D_{b}·B_{b} + C_{s}·(G_{xz}ᵀ·G_{xz} + G_{yz}ᵀ·G_{yz}) ) at the 4 Gauss points (±1/√3), with |J| = a·b:
g_p = 1/sqrt(3) 'Gauss coordinate
r_g = [-g_p, g_p, g_p, -g_p] 'r of the 4 points
s_g = [-g_p, -g_p, g_p, g_p] 's of the 4 points
j_d = a_e·b_e 'Jacobian of the rectangle [m2]
#hide
K_e = zeros(12, 12)
#show
for p = 1:4
  B_1 = B_b(r_g(p), s_g(p))
  g_1 = G_xz(r_g(p), s_g(p))
  g_2 = G_yz(r_g(p), s_g(p))
  K_e = K_e + j_d·(transpose(B_1)·D_b·B_1 + C_s·(transpose(g_1)·g_1 + transpose(g_2)·g_2))
end
#: Check against the closed formulas of point 3 (they must give 0):
K_ww_f = C_s·(b_e/(3·a_e) + a_e/(3·b_e)) 'K(w1,w1) in closed form [t/m]
K_tt_f = D_0·b_e/(3·a_e) + D_0·(1 - ν)·a_e/(6·b_e) + C_s·a_e·b_e/3 'K(ty1,ty1) in closed form [t·m]
dK_ww = round(K_e(1, 1) - K_ww_f, 6) 'difference in K(w1,w1)
dK_tt = round(K_e(3, 3) - K_tt_f, 6) 'difference in K(ty1,ty1)
K_e11 = K_e(1, 1) 'K(w1,w1) [t/m]
K_e33 = K_e(3, 3) 'K(ty1,ty1) [t·m]

## 6 · Soil springs and loads

#: **Winkler springs.** The spring is an area spring (k_{s} in t/m³) and it is distributed to the nodes by the **tributary area**: each element gives each of its nodes h²/4, so a corner receives h²/4, an edge h²/2 and an interior node h² (they add up to the footing area):
#hide
A_n = zeros(n_j, 1)
for e = 1:n_e
  for c = 1:4
    q = e_j(e, c)
    A_n(q) = A_n(q) + h_e^2/4
  end
end
k_n = k_s·A_n
#show
A_t = sum(A_n) 'sum of tributary areas = footing area [m2]
k_esq = k_n(1) 'spring of a corner [t/m]
k_int = k_n(n_n + 2) 'spring of an interior node [t/m]
#: **Loads.** The axial load P goes downward (negative w) and the moment M_{y} as a moment at the central node (right-hand: positive M_{y} lowers the +x side). The **self weight** γ·h is distributed by tributary area to all the nodes (it carries the dead load factor).
n_c = (n_x/2)·n_n + n_x/2 + 1 'column-axis node (the 61)
#hide
F_s = zeros(n_g, 1)
F_u = zeros(n_g, 1)
for q = 1:n_j
  F_s(3·q - 2) = -f_Ds·q_pp·A_n(q)
  F_u(3·q - 2) = -f_Du·q_pp·A_n(q)
end
F_s(3·n_c - 2) = F_s(3·n_c - 2) - P_s
F_s(3·n_c - 1) = M_xD + M_xL
F_s(3·n_c) = M_ys
F_u(3·n_c - 2) = F_u(3·n_c - 2) - P_u
F_u(3·n_c - 1) = f_Du·M_xD + f_Lu·M_xL
F_u(3·n_c) = M_yu
F_sz = 0
F_uz = 0
for q = 1:n_j
  F_sz = F_sz + F_s(3·q - 2)
  F_uz = F_uz + F_u(3·q - 2)
end
#show
F_sz 'sum of the vertical service forces = −(P + self weight) [t]
F_uz 'sum of the vertical ultimate forces [t]

## 7 · Assembly and solution

#: The dof of node j are 3(j − 1) + 1, 2, 3. The stiffness of each element is **added** into the rows and columns of its 4 nodes, and the soil spring is added at the deflection dof:
d_j(j) = 3·(j - 1) + (1:3)
d_e(e) = [d_j(e_j(e, 1)), d_j(e_j(e, 2)), d_j(e_j(e, 3)), d_j(e_j(e, 4))]
#hide
K = zeros(n_g, n_g)
#show
for e = 1:n_e
  g = d_e(e)
  K(g, g) = K(g, g) + K_e
end
#hide
K_t = K
for q = 1:n_j
  K_t(3·q - 2, 3·q - 2) = K_t(3·q - 2, 3·q - 2) + k_n(q)
end
U_s = clsolve(K_t, F_s)
U_u = clsolve(K_t, F_u)
#show
#: Solve the system K_{t}·U = F for the two combinations. **Results:** deflection w (mm) and soil pressure p = −k_{s}·w (t/m²) at each node:
#hide
w_s = zeros(n_j, 1)
p_s = zeros(n_j, 1)
w_u = zeros(n_j, 1)
p_u = zeros(n_j, 1)
R_s = 0
R_u = 0
for q = 1:n_j
  w_s(q) = 1000·U_s(3·q - 2)
  p_s(q) = -k_s·U_s(3·q - 2)
  w_u(q) = 1000·U_u(3·q - 2)
  p_u(q) = -k_s·U_u(3·q - 2)
  R_s = R_s + p_s(q)·A_n(q)
  R_u = R_u + p_u(q)·A_n(q)
end
P_ms = zeros(n_n, n_n)
P_mu = zeros(n_n, n_n)
for j = 1:n_n
  for i = 1:n_n
    P_ms(i, j) = p_s((j - 1)·n_n + i)
    P_mu(i, j) = p_u((j - 1)·n_n + i)
  end
end
#show

## 8 · Service (VERTICAL LOAD): soil stress

sig_max_s = max(p_s) 'maximum soil pressure, service [t/m2]
sig_min_s = min(p_s) 'minimum soil pressure, service [t/m2]
w_cen_s = -w_s(n_c) 'deflection under the column, service [mm]
w_max_s = -min(w_s) 'maximum deflection, service [mm]
R_serv = R_s 'sum of the soil reactions [t]
#: **Equilibrium:** the reactions add up to P + self weight = 121 + 12.87 t: the model loses no load.
dEq_s = round(R_serv + F_sz, 6) 'R + ΣF vertical (must be 0) [t]
#: **Pressure map** (t/m²) on the plan; the value is read with the cursor. Higher on the +x side, toward where the moment M_{y} pushes the resultant:
p_xy(x, y) = spline(1 + (x + L_z/2)/h_e, 1 + (y + L_z/2)/h_e, P_ms)
#map(p_xy(x, y), [-1.725 1.725], [-1.725 1.725])
#: **The book (SAFE, Fig. 29, p. 36):** maximum stress for VERTICAL LOAD = 13.163 t/m² with h = 0.45 m. Here:
sig_SAFE = 13.163 'maximum stress of the book [t/m2]
d_SAFE = round(100·(sig_max_s/sig_SAFE - 1), 2) 'difference with SAFE [%]
#: A difference of less than 1 % with SAFE, with another mesh, another element type and the same self weight: Guerra's footing is **reproduced**. (Without the self weight it would give 12.17, 8 % less: SAFE does carry it in DEAD.)

## 9 · Ultimate (ULTIMATE LOAD 1.4D + 1.7L): for design

sig_max_u = max(p_u) 'maximum soil pressure, ultimate [t/m2]
sig_min_u = min(p_u) 'minimum soil pressure, ultimate [t/m2]
w_max_u = -min(w_u) 'maximum deflection, ultimate [mm]
R_ult = R_u 'sum of the reactions, ultimate [t]
#: **Pressure map of the ULTIMATE LOAD** (t/m²), with the same distribution as the service one but with 1.4D + 1.7L:
p_xyu(x, y) = spline(1 + (x + L_z/2)/h_e, 1 + (y + L_z/2)/h_e, P_mu)
#map(p_xyu(x, y), [-1.725 1.725], [-1.725 1.725])

## 10 · Check: the rigid footing and the elastic length

p_Rmax = (P_s + W_pp)/A_z + 6·M_ys/L_z^3 'maximum pressure, rigid footing, service [t/m2]
p_Rmin = (P_s + W_pp)/A_z - 6·M_ys/L_z^3 'minimum pressure, rigid footing, service [t/m2]
l_el = (D_0/k_s)^(1/4) 'elastic length of the plate on Winkler [m]
#: With ℓ ≈ 1.59 m against a side of 3.45 m (L/ℓ ≈ 2.2) the footing is **not rigid**: it arches under the column and unloads the edges. That is why σ_{max} of the FEM (13.25) is below the rigid figure (13.73): the flexible plate distributes less pressure at the loaded edge.

## 11 · Against numpy (the same mesh and the same element)

#: Figures from `zapata_numpy.py` (Python, same model). The differences must be of the order of 1e-6 (printing precision):
sig_max_np = 13.24978 'numpy, maximum stress, service [t/m2]
sig_min_np = 7.287184 'numpy, minimum stress, service [t/m2]
w_max_np = 4.537596 'numpy, maximum deflection, service [mm]
w_cen_np = 4.515564 'numpy, deflection under the column, service [mm]
R_np = 133.869697 'numpy, sum of reactions, service [t]
sig_max_npu = 19.463055 'numpy, maximum stress, ultimate [t/m2]
w_max_npu = 6.66543 'numpy, maximum deflection, ultimate [mm]
d_sig = round(sig_max_s - sig_max_np, 6) 'difference σ_max service
d_sigmin = round(sig_min_s - sig_min_np, 6) 'difference σ_min service
d_wmax = round(w_max_s - w_max_np, 6) 'difference w_max service
d_wcen = round(w_cen_s - w_cen_np, 6) 'difference w center service
d_R = round(R_serv - R_np, 6) 'difference sum of reactions
d_sigu = round(sig_max_u - sig_max_npu, 6) 'difference σ_max ultimate
d_wu = round(w_max_u - w_max_npu, 6) 'difference w_max ultimate

## 12 · Geotechnical analysis (the soil under the footing)

#: **What is checked.** With the data of the statement (Fig. 4: q_{adm} = 14 t/m²) and the subgrade modulus of the book, the four things the soil requires are checked: **allowable capacity**, **eccentricity** (the base must not lift), **settlement** and **rotation/angular distortion**. There is no φ, c or embedment depth in the book: that is why the Terzaghi/Meyerhof ultimate capacity is not computed (no data is invented). The **service** combination (1.0 D + 1.0 L) is used, not the ultimate one.
q_adm = 14 'allowable soil pressure, data from the statement [t/m2]

#: **1 · Allowable capacity.** The maximum FEM stress must not exceed q_{adm}. The **utilization** is σ_{max}/q_{adm} (must be ≤ 1) and the **apparent safety factor** its inverse:
uso_q = sig_max_s/q_adm 'soil utilization (≤ 1 passes)
FS_q = q_adm/sig_max_s 'apparent safety factor
hol_q = q_adm - sig_max_s 'margin [t/m2]
uso_qR = p_Rmax/q_adm 'utilization with the rigid footing (hand reference)

#: **2 · Eccentricity.** The soil resultant falls at e = M_{y}/(P + self weight) from the axis. As long as e < L/6 (middle third) the whole base works in compression and there is no lift-off; it is confirmed with the minimum FEM pressure (must be > 0):
e_res = M_ys/(P_s + W_pp) 'eccentricity of the resultant [m]
e_nuc = L_z/6 'limit of the middle third [m]
rel_e = e_res/e_nuc 'ratio e/(L/6) (< 1 passes)
sig_min_s 'minimum pressure, service (> 0 = no lift-off) [t/m2]

#: **3 · Settlement (Winkler: w = p/k_{s}).** The maximum deflection is the maximum settlement; the difference between opposite edges of the center line is the differential settlement:
j_m = (n_n + 1)/2 'center row (y = 0)
s_max = w_max_s 'maximum settlement [mm]
s_cen = w_cen_s 'settlement under the column [mm]
s_izq = -w_s((j_m - 1)·n_n + 1) 'settlement of the −x edge, center axis [mm]
s_der = -w_s((j_m - 1)·n_n + n_n) 'settlement of the +x edge, center axis [mm]
ds_dif = s_der - s_izq 'differential settlement between edges [mm]

#: **4 · Rotation and angular distortion.** β = Δs/L. For framed structures the usual damage limit is β ≤ 1/500 (Skempton and MacDonald, 1/300 for structural damage). It is shown as a ratio to the 1/500 limit (< 1 passes):
beta = ds_dif/(1000·L_z) 'angular distortion between edges (rad)
rel_beta = beta/(1/500) 'ratio to the 1/500 limit (< 1 passes)
