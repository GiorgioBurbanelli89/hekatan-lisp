# Thick plate by finite elements: the MITC4 element (Mindlin-Reissner)
#numerico

#: Replica of the Calcpad sheet **benchmark platethick MITC4**: the same slab, the same 12 × 8 mesh, the same **MITC4** element (Dvorkin-Bathe 1985), the same supports and the same moment recovery. Here it runs in Hekatan LISP with the #numerico directive.
#: **Why MITC4.** In a thick plate (Mindlin-Reissner) the deflection w and the rotations β_{x}, β_{y} are independent and shear deformation appears. If the shear is computed with the shape functions as they are, the thin slab becomes too stiff (shear locking). MITC4 measures the shear only at the **four midpoints of the sides** and interpolates it: that way it does not lock.
#: **Units.** As in Calcpad: E in MPa (= MN/m²) and q in kN/m². Then K comes out in MN/m, F in kN and the ratio F/K in kN/(MN/m) = 10⁻³ m = **mm** (rotations, in mrad). The moments −D·B·Z come out in **kN·m/m**. That is why the numbers match those of Calcpad without conversion factors.

## 1 · Data
a = 6 [m] 'slab length
b = 4 [m] 'slab width
t = 0.40 [m] 'thickness
q = 10 [kN/m²] 'distributed load
E = 35000 [MPa] 'modulus of elasticity
ν = 0.15 'Poisson's ratio
κ = 5/6 'shear correction factor (Reissner)

## 2 · Finite element mesh
#: 4-node element with 3 degrees of freedom per node: the deflection w and the rotations β_{x} and β_{y}. In total n = 12 per element.
n = 12 'degrees of freedom of the element
n_a = 12 'elements along a
n_b = 8 'elements along b
n_e = n_a·n_b 'number of elements
n_j = (n_a + 1)·(n_b + 1) 'number of nodes
a_1 = a/n_a [m] 'element side in x
b_1 = b/n_b [m] 'element side in y
a_h = a_1/2 [m] 'half side in x
b_h = b_1/2 [m] 'half side in y
n_s = 2·(n_a + n_b) 'supported nodes (the whole edge)
#hide
x_j = zeros(n_j, 1)
y_j = zeros(n_j, 1)
x_0 = 0
y_0 = 0
for j = 1:n_j
  x_j(j) = x_0
  y_j(j) = y_0
  y_0 = y_0 + b_1
  if y_0 > b
    y_0 = 0
    x_0 = x_0 + a_1
  end
end
e_j = zeros(n_e, 4)
for i_a = 1:n_a
  for i_b = 1:n_b
    e = i_b + n_b·(i_a - 1)
    j = e + i_a - 1
    e_j(e, 1) = j
    e_j(e, 2) = j + n_b + 1
    e_j(e, 3) = j + n_b + 2
    e_j(e, 4) = j + 1
  end
end
s_j = zeros(n_s, 1)
i_s = 0
for i = 1:n_a + 1
  i_s = i_s + 1
  s_j(i_s) = (n_b + 1)·i - n_b
end
for i = 1:n_a + 1
  i_s = i_s + 1
  s_j(i_s) = (n_b + 1)·i
end
for i = 2:n_b
  i_s = i_s + 1
  s_j(i_s) = i
end
for i = 2:n_b
  i_s = i_s + 1
  s_j(i_s) = n_a·(n_b + 1) + i
end
#show
#: Nodes numbered by columns (from bottom to top and from left to right); those on the edge are supported:
#malla(x_j, y_j, e_j, s_j)

## 3 · Constitutive matrices
#: **Bending** (moments ↔ curvatures), 3 × 3:
D_b = E·t^3/(12·(1 - ν^2))·[1, ν, 0; ν, 1, 0; 0, 0, (1 - ν)/2]
#: **Shear** (shear forces ↔ shear strains), 2 × 2:
G = E/(2·(1 + ν)) [MPa]
D_s11 = κ·G·t
D_s = D_s11·[1, 0; 0, 1]

## 4 · 2 × 2 Gauss quadrature
gp = [-1/sqrt(3), 1/sqrt(3)]
gw = [1, 1]

## 5 · Shape functions and B matrices
#: **Bilinear functions** of the 4-node quadrilateral, in natural coordinates ξ and η between −1 and 1. The same serve for w, β_{x} and β_{y}:
N_1(ξ, η) = (1 - ξ)·(1 - η)/4
N_2(ξ, η) = (1 + ξ)·(1 - η)/4
N_3(ξ, η) = (1 + ξ)·(1 + η)/4
N_4(ξ, η) = (1 - ξ)·(1 + η)/4
#: Their derivatives with respect to ξ (subscript ξ) and η (subscript η):
N_1ξ(ξ, η) = -(1 - η)/4
N_2ξ(ξ, η) = (1 - η)/4
N_3ξ(ξ, η) = (1 + η)/4
N_4ξ(ξ, η) = -(1 + η)/4
N_1η(ξ, η) = -(1 - ξ)/4
N_2η(ξ, η) = -(1 + ξ)/4
N_3η(ξ, η) = (1 + ξ)/4
N_4η(ξ, η) = (1 - ξ)/4
#: **Curvatures**: they are the derivatives of the rotations. The chain rule divides by the half side (dx = a_{h}·dξ, dy = b_{h}·dη):
#: κ_{x} = ∂β_{x}/∂x , κ_{y} = ∂β_{y}/∂y , 2·κ_{xy} = ∂β_{x}/∂y + ∂β_{y}/∂x
#: Order of the 12 degrees of freedom: [w₁, β_{x1}, β_{y1}, w₂, β_{x2}, β_{y2}, w₃, β_{x3}, β_{y3}, w₄, β_{x4}, β_{y4}].
#: **Bending matrix** B_{b} (3 × 12). Row 1: κ_{x}, only in the columns of β_{x}. Row 2: κ_{y}, only in those of β_{y}. Row 3: 2·κ_{xy}, in both:
B_b(ξ, η) = [0, N_1ξ(ξ, η)/a_h, 0, 0, N_2ξ(ξ, η)/a_h, 0, 0, N_3ξ(ξ, η)/a_h, 0, 0, N_4ξ(ξ, η)/a_h, 0; 0, 0, N_1η(ξ, η)/b_h, 0, 0, N_2η(ξ, η)/b_h, 0, 0, N_3η(ξ, η)/b_h, 0, 0, N_4η(ξ, η)/b_h; 0, N_1η(ξ, η)/b_h, N_1ξ(ξ, η)/a_h, 0, N_2η(ξ, η)/b_h, N_2ξ(ξ, η)/a_h, 0, N_3η(ξ, η)/b_h, N_3ξ(ξ, η)/a_h, 0, N_4η(ξ, η)/b_h, N_4ξ(ξ, η)/a_h]
#: **MITC4 shear: the four tying points.** γ_{xz} is measured at A (ξ = 0, η = −1) and at C (ξ = 0, η = +1); γ_{yz} at B (ξ = +1, η = 0) and at D (ξ = −1, η = 0). At each point, the shear is the slope of the deflection along the side minus the mean rotation of its two nodes:
#: γ_{A} = (w₂ − w₁)/(2·a_{h}) − ½·(β_{x1} + β_{x2})
#: γ_{C} = (w₃ − w₄)/(2·a_{h}) − ½·(β_{x4} + β_{x3})
#: γ_{B} = (w₃ − w₂)/(2·b_{h}) − ½·(β_{y2} + β_{y3})
#: γ_{D} = (w₄ − w₁)/(2·b_{h}) − ½·(β_{y1} + β_{y4})
#: Written as rows over the 12 degrees of freedom:
γ_A = [-1/(2·a_h), -0.5, 0, 1/(2·a_h), -0.5, 0, 0, 0, 0, 0, 0, 0]
γ_C = [0, 0, 0, 0, 0, 0, 1/(2·a_h), -0.5, 0, -1/(2·a_h), -0.5, 0]
γ_B = [0, 0, 0, -1/(2·b_h), 0, -0.5, 1/(2·b_h), 0, -0.5, 0, 0, 0]
γ_D = [-1/(2·b_h), 0, -0.5, 0, 0, 0, 0, 0, 0, 1/(2·b_h), 0, -0.5]
#: **Shear matrix** B_{s} (2 × 12): between the tying points it is interpolated in a straight line. γ_{xz} changes only with η and γ_{yz} only with ξ:
B_s(ξ, η) = [0.5·(1 - η)·γ_A + 0.5·(1 + η)·γ_C; 0.5·(1 - ξ)·γ_D + 0.5·(1 + ξ)·γ_B]

## 6 · Element stiffness matrix and loads
#: The stiffness is the sum of the bending and shear ones, integrated over the element (dx·dy = a_{h}·b_{h}·dξ·dη):
#noc
K_e = a_h·b_h·Area{Area{transpose(B_b(ξ, η))·D_b·B_b(ξ, η) + transpose(B_s(ξ, η))·D_s·B_s(ξ, η) @ ξ = -1 : 1} @ η = -1 : 1}
#equ
#: The integral is done with 2 × 2 Gauss quadrature (exact here: the integrand is a polynomial of degree 2 in each variable):
k_e(ξ, η) = transpose(B_b(ξ, η))·D_b·B_b(ξ, η) + transpose(B_s(ξ, η))·D_s·B_s(ξ, η)
#hide
K_e = zeros(n, n)
for j = 1:2
  for i = 1:2
    K_e = K_e + a_h·b_h·gw(i)·gw(j)·k_e(gp(i), gp(j))
  end
end
#show
K_e [MN/m]
#: **Element load vector**: the load q distributed equally to the deflections of the four nodes (degrees of freedom 1, 4, 7 and 10); the rotations receive no load.
#hide
F_e = zeros(n, 1)
F_e(1) = q·a_1·b_1/4
F_e(4) = q·a_1·b_1/4
F_e(7) = q·a_1·b_1/4
F_e(10) = q·a_1·b_1/4
#show
F_e [kN]

## 7 · Assembly and solution
#: Three degrees of freedom per node (k₁ = n/4). Those of node j are k₁·(j − 1) + 1 … k₁·j, and those of the element, those of its four nodes in sequence:
k_1 = n/4
n_g = k_1·n_j 'degrees of freedom of the slab
#hide
d_j(j) = k_1·(j - 1) + (1:k_1)
d_e(e) = [d_j(e_j(e, 1)), d_j(e_j(e, 2)), d_j(e_j(e, 3)), d_j(e_j(e, 4))]
K = zeros(n_g, n_g)
F = zeros(n_g, 1)
#show
#: Assembly: the stiffness and the load of each element are ADDED into the rows and columns of their degrees of freedom.
for e = 1:n_e
  g = d_e(e)
  K(g, g) = K(g, g) + K_e
  F(g) = F(g) + F_e
end
#: Supports (simply supported edge, «hard» condition): a very stiff spring k_{s} on the deflection of each edge node and on the rotation that would drag it along the edge. On the edges x = 0 and x = a β_{y} is restrained; on y = 0 and y = b, β_{x}; at the corners, both.
k_s = 10^20
for i = 1:n_s
  j_s = s_j(i)
  g = k_1·(j_s - 1) + 1
  K(g, g) = K(g, g) + k_s
  if x_j(j_s) == 0 || x_j(j_s) == a
    if y_j(j_s) == 0 || y_j(j_s) == b
      K(g + 1, g + 1) = K(g + 1, g + 1) + k_s
      K(g + 2, g + 2) = K(g + 2, g + 2) + k_s
    else
      K(g + 2, g + 2) = K(g + 2, g + 2) + k_s
    end
  else
    K(g + 1, g + 1) = K(g + 1, g + 1) + k_s
  end
end
#: Solution of the system K·Z = F by Cholesky (clsolve, as in Calcpad):
Z = clsolve(K, F)

## 8 · Deflection
#: Node deflections (row = y, column = x), rounded to 0.001 mm as in Calcpad:
#hide
W_z = zeros(n_a + 1, n_b + 1)
for i = 1:n_a + 1
  for j = 1:n_b + 1
    W_z(i, j) = round(Z(k_1·((i - 1)·(n_b + 1) + j) - (k_1 - 1))·1000)/1000
  end
end
#show
transpose(W_z) [mm]
#: Between nodes, the deflection is interpolated with the Calcpad spline over the deflection matrix:
w(x, y) = spline(1 + x/a_1, 1 + y/b_1, W_z)
#map(-w(x, y), [0 6], [0 4])
w(a/2, b/2) [mm] 'maximum deflection, at the center
#: The same deflection, unrounded (that of the central node):
j_c = (n_a/2)·(n_b + 1) + n_b/2 + 1 'central node
w_c = Z(k_1·(j_c - 1) + 1) [mm]

## 9 · Bending moments
#: **Recovery.** In each element the moment M = −D_{b}·B_{b}·Z_{e} is computed at the 4 Gauss points (where it is most accurate) and **extrapolated** to the corners with the same bilinear functions; the factor √3 takes the Gauss points (±1/√3) to the corners (±1). At each node the elements meeting there are averaged (Cook-Malkus-Plesha; that is how SAP2000 does it).
#hide
ξ_c = [-1, 1, 1, -1]
η_c = [-1, -1, 1, 1]
r_3 = sqrt(3)
Z_e(e) = Z(d_e(e))
M_j = zeros(3, n_j)
c_j = zeros(n_j, 1)
for e = 1:n_e
  Z_el = Z_e(e)
  M_g1 = -D_b·B_b(gp(1), gp(1))·Z_el
  M_g2 = -D_b·B_b(gp(2), gp(1))·Z_el
  M_g3 = -D_b·B_b(gp(1), gp(2))·Z_el
  M_g4 = -D_b·B_b(gp(2), gp(2))·Z_el
  for c = 1:4
    N_g1 = (1 - r_3·ξ_c(c))·(1 - r_3·η_c(c))/4
    N_g2 = (1 + r_3·ξ_c(c))·(1 - r_3·η_c(c))/4
    N_g3 = (1 - r_3·ξ_c(c))·(1 + r_3·η_c(c))/4
    N_g4 = (1 + r_3·ξ_c(c))·(1 + r_3·η_c(c))/4
    j = e_j(e, c)
    M_j(:, j) = M_j(:, j) + N_g1·M_g1 + N_g2·M_g2 + N_g3·M_g3 + N_g4·M_g4
    c_j(j) = c_j(j) + 1
  end
end
for j = 1:n_j
  M_j(:, j) = M_j(:, j)/c_j(j)
end
Mx = zeros(n_a + 1, n_b + 1)
My = zeros(n_a + 1, n_b + 1)
Mxy = zeros(n_a + 1, n_b + 1)
for i = 1:n_a + 1
  for k = 1:n_b + 1
    j = (i - 1)·(n_b + 1) + k
    Mx(i, k) = M_j(1, j)
    My(i, k) = M_j(2, j)
    Mxy(i, k) = M_j(3, j)
  end
end
#show
#: **Mx** (row = y, column = x):
transpose(Mx) [kNm/m]
M_x(x, y) = spline(1 + x/a_1, 1 + y/b_1, Mx)
#map(M_x(x, y), [0 6], [0 4])
M_x(a/2, b/2) [kNm/m] 'at the center
#: **My**:
transpose(My) [kNm/m]
M_y(x, y) = spline(1 + x/a_1, 1 + y/b_1, My)
#map(M_y(x, y), [0 6], [0 4])
M_y(a/2, b/2) [kNm/m] 'maximum, at the center
#: **Mxy** (torsion):
transpose(Mxy) [kNm/m]
M_xy(x, y) = spline(1 + x/a_1, 1 + y/b_1, Mxy)
#map(M_xy(x, y), [0 6], [0 4])
M_xy(0, 0) [kNm/m] 'maximum, at the corner

## 10 · Comparison with SAP2000 v24 (Plate-Thick, t = 0.40 m)
#: SAP2000 values with the same slab: deflection at the center and torsion at the corner.
w_SAP = 0.1066 [mm]
Mxy_SAP = -7.7089 [kNm/m]
Δ_w = 100·(w_c - w_SAP)/w_SAP [%]
Δ_Mxy = 100·(M_xy(0, 0) - Mxy_SAP)/Mxy_SAP [%]
#: **Why they are not identical.** SAP2000 uses in its thick plate a variant with cubic deflection; MITC4 uses the bilinear deflection (Bathe-Dvorkin, the textbook one). Both are valid Mindlin-Reissner and they approach each other as the mesh is refined.
