# Entire Manabí retaining wall as a membrane: stem and footing on springs
#numerico

#: **What model it is.** It is the simplified model of the Manabí wall in Hekatan Struct (example «muro-manabi», **membrane** model). It is still a **membrane**: the **section** of the wall (stem and footing together) is modeled with four-node elements, two displacements per node (u_{x} horizontal, u_{z} vertical) and 1 m of wall as thickness. Since the wall is long, the strip works in **plane strain**.
#: **What the footing adds.** Two things: (1) vertical **subgrade springs** at all the nodes of the base, because the footing rests on the soil and not on a fixed support; (2) **a horizontal support** at the tip of the toe, so that the wall does not slide. Nothing else.
#: **How the sheet is made.** First everything with **symbols** (sections 1 to 4): thrusts, load at the nodes, constitutive matrix, shape functions, Jacobian, element stiffness and springs. Then, the **numbers** (sections 5 to 9) and the comparison with SAP2000 and Hekatan Struct.
#: **Units.** kN, m and kPa (kN/m²), per meter of wall.

## 1 · The wall: dimensions and drawing
#: The wall dimensions, in m. **Change any one and the drawing, the mesh and the whole calculation change with it** (with AutoRun, as you type):
H_f = 2.6 'height of the stem (shaft)
t_f = 0.4 'footing depth
t_c = 0.25 'stem at the top
t_b = 0.4 'stem at the foot
p_t = 0.7 'toe
t_l = 1.9 'heel
x_b = p_t + t_b 'abscissa of the back face
B = x_b + t_l 'footing width
Z_t = t_f + H_f 'elevation of the top
#hide
x_c = x_b - t_c
q_d = 0.4·t_l
q_s = 0.45·t_l
q_r = 0.16·t_l
y_e = t_f + 0.45·H_f
x_t = B + 0.75
y_s = Z_t - 0.1·H_f
y_r = t_f + 0.12·H_f
k_1 = B/10
k_2 = B/2
k_3 = 9·B/10
#show
#dibujo("Wall section: backfill thrust (blue), seismic increment (orange), weight of the backfill over the heel (green) and springs under the footing", ud = m, cotas = m, ancho = 150, alto = 120)
#  polilinea([0, B, B, x_b, x_b, x_c, p_t, 0, 0], [0, 0, t_f, t_f, Z_t, Z_t, t_f, t_f, 0], "gruesa")
#  carga(x_b, Z_t, x_b, t_f, 0, q_d, "", "azul", n = 8)
#  carga(x_b, Z_t, x_b, t_f, q_s, 0, "", "naranja", n = 8)
#  carga(x_b, t_f, B, t_f, q_r, q_r, "", "verde", n = 10)
#  texto(x_t, y_e, "Coulomb thrust", 2.4, "i", estilo = "azul")
#  texto(x_t, y_s, "earthquake, Mononobe-Okabe", 2.4, "i", estilo = "naranja")
#  texto(x_t, y_r, "backfill γ·H_f", 2.4, "i", estilo = "verde")
#  polilinea([k_1, k_1, k_1 - 0.08, k_1 + 0.08, k_1 - 0.08, k_1 + 0.08, k_1, k_1], [0, -0.08, -0.12, -0.18, -0.24, -0.3, -0.34, -0.42], "media")
#  polilinea([k_2, k_2, k_2 - 0.08, k_2 + 0.08, k_2 - 0.08, k_2 + 0.08, k_2, k_2], [0, -0.08, -0.12, -0.18, -0.24, -0.3, -0.34, -0.42], "media")
#  polilinea([k_3, k_3, k_3 - 0.08, k_3 + 0.08, k_3 - 0.08, k_3 + 0.08, k_3, k_3], [0, -0.08, -0.12, -0.18, -0.24, -0.3, -0.34, -0.42], "media")
#  linea(-0.1, -0.42, B + 0.1, -0.42, "trazos gris")
#  empotramiento(-0.03, 0, -0.03, t_f, 1)
#  cotas([0, p_t, x_b, B], 0, -0.75)
#  cota(0, 0, B, 0, -1.1)
#  cotasy([0, t_f, Z_t], B, -0.45)
#  cota(x_c, Z_t, x_b, Z_t, 0.3)
#fin
#: The face of the backfill (the back face) is vertical and the front one is inclined. The base carries subgrade springs k_{s} at all its nodes and the support u_{x} = 0 at the tip of the toe.

## 2 · In symbols: thrusts and load at the nodes
### 2.1 · Thrust coefficients
#: Active **Coulomb** thrust with vertical back face, horizontal ground and friction δ between wall and soil:
K_C(φ, δ) = cos(φ)^2/(cos(δ)·(1 + sqrt(sin(φ + δ)·sin(φ)/cos(δ)))^2)
#: With earthquake, **Mononobe-Okabe**. The earthquake tilts gravity by an angle ψ, with tan ψ = k_{h}/(1 − k_{v}):
K_MO(φ, δ, ψ) = cos(φ - ψ)^2/(cos(ψ)·cos(δ + ψ)·(1 + sqrt(sin(φ + δ)·sin(φ - ψ)/cos(δ + ψ)))^2)
#: Static pressure at elevation z (measured from the base of the footing; Z_{t} is the elevation of the top) and the seismic **increment**, which is an **inverted** triangle: zero at the foot of the stem and maximum at the top (that is how GEO5 does it):
p_E(z) = K_a·γ·(Z_t - z)
p_S(z) = (K_ae - K_a)·(1 - k_v)·γ·(z - t_f)
#: Both pressures act in the direction of the thrust, inclined δ: the horizontal component pushes toward the toe (p·cos δ) and the vertical one pulls downward (p·sin δ).

### 2.2 · From pressure to forces at the nodes
#: On a stretch of the back face of length l the pressure is linear, from p_{1} to p_{2}. Each node receives the integral of the pressure times its shape function, N_{1} = 1 − s/l and N_{2} = s/l:
F_tramo = Simplify{Integral{[1 - s/l; s/l]*(p_1 + (p_2 - p_1)*s/l) @ s = 0 : l}}
#: That is, l·(2·p_{1} + p_{2})/6 at the bottom and l·(p_{1} + 2·p_{2})/6 at the top: each node takes somewhat more of the pressure on its side.
#: **Self weight and earthquake of the wall:** the weight of each element, W = γ_{c}·A·L, is distributed in four equal parts to its nodes (−W/4 in z) and the earthquake inertia, −k_{h}·W/4 in x. **Backfill over the heel:** γ·H_{f} times the tributary width of each node of the upper face of the heel.

## 3 · In symbols: the membrane element
### 3.1 · Plane strain constitutive matrix
#: It relates [σ_{x}, σ_{z}, τ_{xz}] to [ε_{x}, ε_{z}, γ_{xz}]. In plane strain ε_{y} = 0 along the wall:
D_p = Simplify{E/((1+nu)*(1-2*nu))*[1-nu, nu, 0; nu, 1-nu, 0; 0, 0, (1-2*nu)/2]}
#: Struct, SAP2000 and ETABS do not have a plane strain element in the shell: they use plane stress with the changed material, E' = E/(1 − ν²) and ν' = ν/(1 − ν). Substituted into plane stress it gives **the same** matrix:
D_t = Simplify{(E/(1-nu^2))/(1-(nu/(1-nu))^2)*[1, nu/(1-nu), 0; nu/(1-nu), 1, 0; 0, 0, (1-nu/(1-nu))/2]}
dif_D = Simplify{D_t - D_p}

### 3.2 · Shape functions and Jacobian
#: On the natural square (ξ and η from −1 to 1), each function equals 1 at its node and 0 at the other three:
N_1 = Expand{(1-xi)*(1-eta)/4}
N_2 = Expand{(1+xi)*(1-eta)/4}
N_3 = Expand{(1+xi)*(1+eta)/4}
N_4 = Expand{(1-xi)*(1+eta)/4}
#: The derivatives in ξ (row 1) and in η (row 2), one column per node:
dN_ξη = Simplify{[Partial{(1-xi)*(1-eta)/4 @ xi}, Partial{(1+xi)*(1-eta)/4 @ xi}, Partial{(1+xi)*(1+eta)/4 @ xi}, Partial{(1-xi)*(1+eta)/4 @ xi}; Partial{(1-xi)*(1-eta)/4 @ eta}, Partial{(1+xi)*(1-eta)/4 @ eta}, Partial{(1+xi)*(1+eta)/4 @ eta}, Partial{(1-xi)*(1+eta)/4 @ eta}]}
#: The geometry is interpolated with the same functions (isoparametric element). The **Jacobian** is that matrix times the coordinates of the four nodes, [x_{i}, z_{i}]:
J_q = Simplify{[-(1-eta)/4, (1-eta)/4, (1+eta)/4, -(1+eta)/4; -(1-xi)/4, -(1+xi)/4, (1+xi)/4, (1-xi)/4]*[x_1, z_1; x_2, z_2; x_3, z_3; x_4, z_4]}
#: In the footing the elements are squares of side a and J = (a/2)·I, constant. In the stem the element is a **trapezoid** (the front face is inclined): J changes from point to point and the integral is done by Gauss with numbers (section 7). The derivatives in x and z come from J⁻¹·dN_{ξη}.

### 3.3 · Stiffness of the square element of side a
#: The B matrix gives the strains from the 8 node displacements, ordered [u_{1}, w_{1}, u_{2}, w_{2}, …]. Row 1: ε_{x} = ∂u/∂x. Row 2: ε_{z} = ∂w/∂z. Row 3: γ_{xz} = ∂u/∂z + ∂w/∂x. The zeros are where a displacement does not enter that strain:
B_a(xi, eta) = Simplify{[-(1-eta)/(2*a), 0, (1-eta)/(2*a), 0, (1+eta)/(2*a), 0, -(1+eta)/(2*a), 0; 0, -(1-xi)/(2*a), 0, -(1+xi)/(2*a), 0, (1+xi)/(2*a), 0, (1-xi)/(2*a); -(1-xi)/(2*a), -(1-eta)/(2*a), -(1+xi)/(2*a), (1-eta)/(2*a), (1+xi)/(2*a), (1+eta)/(2*a), (1-xi)/(2*a), -(1+eta)/(2*a)]}
#: **Incompatible modes** (Wilson and Taylor). The four-node element only deforms with straight sides and in bending it comes out too stiff. Two curved shapes are added, 1 − ξ² and 1 − η², for u and for w, with amplitudes α = [α_{1}, α_{2}, α_{3}, α_{4}] (u with 1 − ξ², w with 1 − ξ², u with 1 − η², w with 1 − η²). Their strains are the matrix G:
G_a(xi, eta) = Simplify{[-4*xi/a, 0, 0, 0; 0, 0, 0, -4*eta/a; 0, -4*xi/a, -4*eta/a, 0]}
#: The three stiffnesses, integrated on the natural square; the Jacobian of the square equals a²/4 and the thickness is t (1 m of wall):
K_uu = Simplify{t*a^2/4*Area{Area{transpose(B_a(xi, eta))*D_p*B_a(xi, eta) @ xi = -1 : 1} @ eta = -1 : 1}}
K_ua = Simplify{t*a^2/4*Area{Area{transpose(B_a(xi, eta))*D_p*G_a(xi, eta) @ xi = -1 : 1} @ eta = -1 : 1}}
K_aa = Simplify{t*a^2/4*Area{Area{transpose(G_a(xi, eta))*D_p*G_a(xi, eta) @ xi = -1 : 1} @ eta = -1 : 1}}
#: The α have no node of their own: they are eliminated inside the element (**static condensation**). From the two equations K_{uu}·u + K_{ua}·α = f and K_{ua}ᵀ·u + K_{aa}·α = 0, α = −K_{aa}⁻¹·K_{ua}ᵀ·u is solved and the 8 × 8 stiffness remains, **K_{c} = K_{uu} − K_{ua}·K_{aa}⁻¹·K_{ua}ᵀ**. It is too wide for the page; the engine computes it whole and it is shown by taking out the common factor E·t/(24·(1 + ν)·(1 − 2·ν)). The side a has gone: the stiffness of the square does not depend on its size, only numbers and ν remain:
K_c1 = Simplify{(K_uu - K_ua*inv(K_aa)*transpose(K_ua))*24*(1+nu)*(1-2*nu)/(E*t)}
#: **Distorted element (the stem).** With variable J, G is computed with the Jacobian at the center, J_{0} = J(0, 0), and multiplied by det J_{0}/det J. It is the Taylor correction: without it, a trapezoid would not pass the patch test (constant strain).

## 4 · In symbols: the springs and the system
#: Each node of the base carries a vertical soil spring: the subgrade modulus times the area that belongs to it (half of each neighboring segment times the meter of wall): **k_{j} = k_{s}·A_{j}**. The soil pressure at that node is the settlement times the subgrade modulus, q_{j} = −k_{s}·w_{j}. The spring stiffness is added on the diagonal, at the vertical degree of the node:
#: (K + K_{s})·U = F
#: with K the sum of the element stiffnesses, K_{s} the diagonal of the springs and U the displacements. The horizontal support of the toe removes the row and the column of its u_{x}: the **free** degrees are solved, U_{L} = K_{LL}⁻¹·F_{L}.

## 5 · And now the numbers: material, soil and earthquake
#: The wall dimensions are in section 1. Wall length and element side:
L = 1 'meter of wall
m_s = 0.1 'element side, m
#: f'_{c} = 21 MPa (the minimum of NEC-SE-HM) and E = 4700·√f'_{c} in MPa (ACI 318-19, 19.2.2.1.b), converted to kN/m²:
E = 4700·sqrt(21)·1000
ν = 0.2
γ_c = 23 'concrete, kN/m³ (the GEO5 one)
γ = 18.5 'backfill, SP sand, kN/m³
φ = 30·pi/180 'backfill friction
δ = 20·pi/180 'wall-soil friction
k_h = 0.336 'NEC-SE-GC: 0.6·Z·F_a = 0.6·0.50·1.12
k_v = 0
#: Subgrade modulus from the soil study (stretch −2.55 to −3.00 m): 6.59 kg/cm³, in kN/m³:
k_s = 6.59·9.80665·1000
#: The thrust coefficients, with the formulas of section 2:
K_a = K_C(φ, δ)
ψ = atan(k_h/(1 - k_v))
K_ae = K_MO(φ, δ, ψ)
ψ_g = ψ·180/pi 'in degrees

## 6 · Mesh
#: The dimensions of section 1 must be multiples of the element side m_{s}. Number of elements in x (n_{x}), in the footing (n_{f}) and in the stem (n_{h}); in the stem each row of nodes is divided into n_{p} equal parts between the inclined face and the back face.
n_x = round(B/m_s)
n_f = round(t_f/m_s)
n_h = round(H_f/m_s)
n_z = n_f + n_h
i_0 = round(p_t/m_s) + 1 'column of the front face, at the foot
i_1 = round(x_b/m_s) + 1 'column of the back face
n_p = i_1 - i_0 'elements across the stem depth
#hide
N_ik = zeros(n_x + 1, n_z + 1)
n_j = (n_f + 1)·(n_x + 1) + n_h·(n_p + 1)
x_j = zeros(n_j, 1)
z_j = zeros(n_j, 1)
n_j = 0
for k = 1:n_f + 1
  for i = 1:n_x + 1
    n_j = n_j + 1
    N_ik(i, k) = n_j
    x_j(n_j) = (i - 1)·m_s
    z_j(n_j) = (k - 1)·m_s
  end
end
for k = n_f + 2:n_z + 1
  z = (k - 1)·m_s
  x_f = p_t + (t_b - t_c)·(z - t_f)/H_f
  for i = i_0:i_1
    n_j = n_j + 1
    N_ik(i, k) = n_j
    x_j(n_j) = x_f + (i - i_0)/n_p·(x_b - x_f)
    z_j(n_j) = z
  end
end
n_e = n_x·n_f + n_p·n_h
e_j = zeros(n_e, 4)
e = 0
for k = 1:n_f
  for i = 1:n_x
    e = e + 1
    e_j(e, :) = [N_ik(i, k), N_ik(i + 1, k), N_ik(i + 1, k + 1), N_ik(i, k + 1)]
  end
end
for k = n_f + 1:n_z
  for i = i_0:i_1 - 1
    e = e + 1
    e_j(e, :) = [N_ik(i, k), N_ik(i + 1, k), N_ik(i + 1, k + 1), N_ik(i, k + 1)]
  end
end
#show
#: Nodes, elements and degrees of freedom (the same as in Struct):
n_j
n_e
n_d = 2·n_j
#: Node 1 is the tip of the toe, the one with the horizontal support:
#malla(x_j, z_j, e_j, [1])

## 7 · Stiffness: sum at the four Gauss points
#: In each element and at each Gauss point (ξ, η = ±1/√3, weights 1): Jacobian, derivatives in x and z, the B and G matrices, and det J·t·[BᵀDB, BᵀDG, GᵀDG] is accumulated. Then it is condensed as in section 3.3 and added into K at the rows and columns of its degrees of freedom. Along the way, the sum of det J gives the element area, which is needed for the weight.
D = E/((1 + ν)·(1 - 2·ν))·[1 - ν, ν, 0; ν, 1 - ν, 0; 0, 0, (1 - 2·ν)/2]
s_g = 1/sqrt(3)
ξ_g = [-s_g, s_g, s_g, -s_g]
η_g = [-s_g, -s_g, s_g, s_g]
#hide
S_u = zeros(4, 8)
S_w = zeros(4, 8)
for i = 1:4
  S_u(i, 2·i - 1) = 1
  S_w(i, 2·i) = 1
end
d_e(e) = [2·e_j(e, 1) - 1, 2·e_j(e, 1), 2·e_j(e, 2) - 1, 2·e_j(e, 2), 2·e_j(e, 3) - 1, 2·e_j(e, 3), 2·e_j(e, 4) - 1, 2·e_j(e, 4)]
K = zeros(n_d, n_d)
A_e = zeros(n_e, 1)
K_1 = zeros(8, 8)
for e = 1:n_e
  X_e = [x_j(e_j(e, 1)), z_j(e_j(e, 1)); x_j(e_j(e, 2)), z_j(e_j(e, 2)); x_j(e_j(e, 3)), z_j(e_j(e, 3)); x_j(e_j(e, 4)), z_j(e_j(e, 4))]
  J_0 = [-1, 1, 1, -1; -1, -1, 1, 1]/4·X_e
  d_0 = det(J_0)
  k_uu = zeros(8, 8)
  k_ua = zeros(8, 4)
  k_aa = zeros(4, 4)
  for g = 1:4
    ξ = ξ_g(g)
    η = η_g(g)
    d_N = [-(1 - η)/4, (1 - η)/4, (1 + η)/4, -(1 + η)/4; -(1 - ξ)/4, -(1 + ξ)/4, (1 + ξ)/4, (1 - ξ)/4]
    J_g = d_N·X_e
    d_J = det(J_g)
    g_xz = inv(J_g)·d_N
    g_x = transpose(g_xz(1, :))
    g_z = transpose(g_xz(2, :))
    B_g = [g_x·S_u; g_z·S_w; g_z·S_u + g_x·S_w]
    P = inv(J_0)·[-2·ξ, 0; 0, -2·η]·d_0/d_J
    G_g = [P(1, 1), 0, P(1, 2), 0; 0, P(2, 1), 0, P(2, 2); P(2, 1), P(1, 1), P(2, 2), P(1, 2)]
    k_uu = k_uu + d_J·L·transpose(B_g)·D·B_g
    k_ua = k_ua + d_J·L·transpose(B_g)·D·G_g
    k_aa = k_aa + d_J·L·transpose(G_g)·D·G_g
    A_e(e) = A_e(e) + d_J
  end
  K_e = k_uu - k_ua·(k_aa\transpose(k_ua))
  if e == 1
    K_1 = K_e
  end
  g = d_e(e)
  K(g, g) = K(g, g) + K_e
end
#show
#: **Check of the symbol.** Element 1 is a square of the footing. Its term (1, 1) summed by Gauss and that of the formula of section 3.3, K_{c1}(1, 1)·E·t/(24·(1 + ν)·(1 − 2·ν)), with K_{c1}(1, 1) = (12·ν² − 25·ν + 11)/(1 − ν):
k_Gauss = K_1(1, 1)
k_simb = (12·ν^2 - 25·ν + 11)/(1 - ν)·E·L/(24·(1 + ν)·(1 - 2·ν))
#: Area of the section (the sum of the element areas), in m²:
A_sec = sum(A_e)
#: **Springs.** Tributary area of each node of the base: m_{s}/2 at the two ends, m_{s} at the others:
#hide
K_s = 0
for i = 1:n_x + 1
  j = N_ik(i, 1)
  w_i = m_s
  if i == 1
    w_i = m_s/2
  end
  if i == n_x + 1
    w_i = m_s/2
  end
  K(2·j, 2·j) = K(2·j, 2·j) + k_s·w_i·L
  K_s = K_s + k_s·w_i·L
end
#show
#: The sum of the springs must be k_{s}·B·L:
K_s
k_sBL = k_s·B·L

## 8 · Loads
#: Two force vectors: F_{0} (static: self weight, backfill and Coulomb thrust) and F_{1} (the earthquake: wall inertia and Mononobe-Okabe increment). The seismic case is F_{0} + F_{1}.
#hide
F_0 = zeros(n_d, 1)
F_1 = zeros(n_d, 1)
for e = 1:n_e
  W = A_e(e)·L·γ_c
  for i = 1:4
    j = e_j(e, i)
    F_0(2·j) = F_0(2·j) - W/4
    F_1(2·j - 1) = F_1(2·j - 1) - k_h·W/4
    F_1(2·j) = F_1(2·j) + k_v·W/4
  end
end
F_pp = sum(F_0)
for i = i_1:n_x + 1
  j = N_ik(i, n_f + 1)
  w_i = m_s
  if i == i_1
    w_i = m_s/2
  end
  if i == n_x + 1
    w_i = m_s/2
  end
  F_0(2·j) = F_0(2·j) - γ·H_f·w_i·L
end
F_rel = sum(F_0) - F_pp
E_x = 0
E_z = 0
S_x = 0
S_z = 0
for k = n_f + 1:n_z
  j_a = N_ik(i_1, k)
  j_b = N_ik(i_1, k + 1)
  z_a = z_j(j_a)
  z_b = z_j(j_b)
  l = z_b - z_a
  f_a = l·(2·p_E(z_a) + p_E(z_b))/6·L
  f_b = l·(p_E(z_a) + 2·p_E(z_b))/6·L
  s_a = l·(2·p_S(z_a) + p_S(z_b))/6·L
  s_b = l·(p_S(z_a) + 2·p_S(z_b))/6·L
  F_0(2·j_a - 1) = F_0(2·j_a - 1) - f_a·cos(δ)
  F_0(2·j_b - 1) = F_0(2·j_b - 1) - f_b·cos(δ)
  F_0(2·j_a) = F_0(2·j_a) - f_a·sin(δ)
  F_0(2·j_b) = F_0(2·j_b) - f_b·sin(δ)
  F_1(2·j_a - 1) = F_1(2·j_a - 1) - s_a·cos(δ)
  F_1(2·j_b - 1) = F_1(2·j_b - 1) - s_b·cos(δ)
  F_1(2·j_a) = F_1(2·j_a) - s_a·sin(δ)
  F_1(2·j_b) = F_1(2·j_b) - s_b·sin(δ)
  E_x = E_x - (f_a + f_b)·cos(δ)
  E_z = E_z - (f_a + f_b)·sin(δ)
  S_x = S_x - (s_a + s_b)·cos(δ)
  S_z = S_z - (s_a + s_b)·sin(δ)
end
S_x = S_x + k_h·F_pp
#show
#: Sums of each load, in kN/m. Struct gives: self weight −47.035, backfill −91.390, thrust (−17.470, −6.359), earthquake (−35.038, −7.001).
F_pp
F_rel
E_x
E_z
S_x
S_z

## 9 · Solution and results
#hide
L_f = zeros(n_d - 1, 1)
for i = 2:n_d
  L_f(i - 1) = i
end
U_0 = zeros(n_d, 1)
U_1 = zeros(n_d, 1)
F_2 = F_0 + F_1
#show
#: (K + K_{s})·U = F is solved in the free degrees (all except the u_{x} of node 1), for the two cases:
U_0(L_f) = K(L_f, L_f)\F_0(L_f)
U_1(L_f) = K(L_f, L_f)\F_2(L_f)
#: **Top** (back face node, upper), in mm. Static and with earthquake:
j_c = N_ik(i_1, n_z + 1)
u_c0 = 1000·U_0(2·j_c - 1)
u_c1 = 1000·U_1(2·j_c - 1)
w_c1 = 1000·U_1(2·j_c)
#: **Soil pressure** under the footing, q = −k_{s}·w, in kPa. At the tip of the toe (x = 0) and at the tip of the heel (x = B):
q_p0 = -k_s·U_0(2·N_ik(1, 1))
q_t0 = -k_s·U_0(2·N_ik(n_x + 1, 1))
q_p1 = -k_s·U_1(2·N_ik(1, 1))
q_t1 = -k_s·U_1(2·N_ik(n_x + 1, 1))
#: Without earthquake the pressure is larger at the **heel**, which is where the backfill loads. With earthquake the wall overturns forward and the pressure goes to the **toe**.
#: **Equilibrium with earthquake.** The sum of the spring forces is the vertical reaction; it must equal the vertical loads:
#hide
R_z = 0
for i = 1:n_x + 1
  j = N_ik(i, 1)
  w_i = m_s
  if i == 1
    w_i = m_s/2
  end
  if i == n_x + 1
    w_i = m_s/2
  end
  R_z = R_z - k_s·w_i·L·U_1(2·j)
end
#show
R_z
F_z = -(F_pp + F_rel + E_z + S_z)

### Deformed shape and color map
#: The wall with earthquake, with the displacements magnified 300 times and painted with the horizontal displacement u_{x} in mm. Moving the cursor gives the value at each point. The rotation of the whole wall on the springs is seen: the footing sinks more at the toe than at the heel, and the stem bends forward.
#hide
X_n = zeros(n_j, 3)
U_3 = zeros(n_j, 3)
u_x = zeros(n_j, 1)
for j = 1:n_j
  X_n(j, 1) = x_j(j)
  X_n(j, 2) = z_j(j)
  U_3(j, 1) = U_1(2·j - 1)
  U_3(j, 2) = U_1(2·j)
  u_x(j) = 1000·U_1(2·j - 1)
end
e_f = zeros(0, 2)
v_f = zeros(0, 2)
#show
#modelo3d(X_n, e_j, e_f, u_x, v_f, U_3, 300)

## 10 · Comparison with SAP2000 and with Hekatan Struct
#: The SAP2000 and Struct numbers are those of the wall with the dimensions and data of this sheet as they come; if they are changed, the table compares with another wall.
#: **SAP2000 24** (through OAPI): **plane strain Plane element with incompatible modes**, the same 285 nodes, the same springs, the same support and the same nodal forces. It is the element of this sheet. **Hekatan Struct**: the same wall with its shell used as a membrane, with the in-plane rotation (Ibrahimbegović, Taylor and Wilson, 1990) and plane stress with E' and ν'. It is another element: that is why Struct does not match in all the figures.
#hide
a_1 = round(100·(u_c0 - 0.0372081247)/0.0372081247, 6)
a_2 = round(100·(u_c1 + 2.3739108692)/2.3739108692, 6)
a_3 = round(100·(q_p1 - 84.72973371)/84.72973371, 6)
a_4 = round(100·(q_t1 - 28.92792)/28.92792, 6)
a_5 = round(100·(q_t0 - 58.45284813)/58.45284813, 6)
b_1 = round(100·(0.0383037 - u_c0)/u_c0, 1)
b_2 = round(100·(-2.3687667 - u_c1)/abs(u_c1), 2)
b_3 = round(100·(84.7133 - q_p1)/q_p1, 2)
b_4 = round(100·(28.9162 - q_t1)/q_t1, 2)
b_5 = round(100·(58.4518 - q_t0)/q_t0, 2)
r_1 = round(u_c0, 10)
r_2 = round(u_c1, 10)
r_3 = round(q_p1, 8)
r_4 = round(q_t1, 8)
r_5 = round(q_t0, 8)
#show
#| | Esta hoja | SAP2000 | dif. [%] | Hekatan Struct | dif. [%] |
#|---|---:|---:|---:|---:|---:|
#| u_{x} coronación, estático [mm] | @{r_1} | 0.0372081247 | @{a_1} | 0.0383037 | @{b_1} |
#| u_{x} coronación, sismo [mm] | @{r_2} | −2.3739108692 | @{a_2} | −2.3687667 | @{b_2} |
#| presión en la puntera, sismo [kPa] | @{r_3} | 84.72973371 | @{a_3} | 84.7133 | @{b_3} |
#| presión en el talón, sismo [kPa] | @{r_4} | 28.92792 | @{a_4} | 28.9162 | @{b_4} |
#| presión en el talón, estático [kPa] | @{r_5} | 58.45284813 | @{a_5} | 58.4518 | @{b_5} |
#: With SAP2000 the largest difference over the 285 nodes is 1.4·10⁻⁹ % of the maximum displacement (with earthquake) and 2·10⁻¹⁰ % (static). With Struct, 0.22 %. In the static case the top hardly moves (0.04 mm): the weight of the backfill over the heel offsets the thrust, and there a difference of 0.001 mm is already 3 %.
#: The Struct **H8 solid** (the same section extruded, 3135 nodes) gives −2.3739 mm with earthquake: the same as this sheet. It makes sense: the hexahedron with incompatible modes in plane strain is the same quadrilateral with incompatible modes.
