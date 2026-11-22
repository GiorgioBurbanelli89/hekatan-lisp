# Shear wall by finite elements: the panel as a membrane
#numerico

#: A **shear wall** (concrete panel that resists the seismic or wind shear of a
#: building) of height H, length L and thickness t, fixed at the base. The panel is studied in
#: its own plane, with four-node **membrane** elements (two displacements per node,
#: no rotation): the same element as test II of the normal rotation (ITW), but here WITHOUT the rotation —
#: today we see why it is needed.
#: **Units.** Lengths in m, forces in tonf, concrete modulus in kgf/cm². Since
#: 1 kgf/cm² = 10 tonf/m², the stiffness comes out in tonf/m and the displacement is shown in **mm**.

## 1 · Data
H = 3.0 [m] 'wall height (one story)
L = 3.0 [m] 'wall length in plan
t = 0.20 [m] 'wall thickness
fc = 280 [kgf/cm²] 'concrete strength
ν = 0.2 'Poisson's ratio
V = 50 [tonf] 'lateral shear at the top (what the diaphragm delivers)
#: Modulus of elasticity of the concrete, in kgf/cm² and converted to tonf/m²:
E_c = 15100·sqrt(fc) [kgf/cm²]
E = 10·E_c [tonf/m²]

## 2 · Constitutive matrix
#: The wall is a **thin panel in its plane** (plane stress, not plane strain like an
#: infinite strip): the faces are free of normal stress out of plane. The constitutive
#: matrix relates the stresses σ_{x}, σ_{y}, τ_{xy} to the strains ε_{x}, ε_{y}, γ_{xy}:
D = E/(1 - ν^2)·[1, ν, 0; ν, 1, 0; 0, 0, (1 - ν)/2]

## 3 · Mesh
n_x = 6 'elements along the length
n_y = 6 'elements along the height
n_e = n_x·n_y 'number of elements
n_j = (n_x + 1)·(n_y + 1) 'number of nodes
n_d = 2·n_j 'degrees of freedom
a_1 = L/n_x [m] 'element side in x
b_1 = H/n_y [m] 'element side in y
#hide
x_j = zeros(n_j, 1)
y_j = zeros(n_j, 1)
for i = 1:n_x + 1
  for k = 1:n_y + 1
    j = (i - 1)·(n_y + 1) + k
    x_j(j) = (i - 1)·a_1
    y_j(j) = (k - 1)·b_1
  end
end
e_j = zeros(n_e, 4)
for i = 1:n_x
  for k = 1:n_y
    e = (i - 1)·n_y + k
    j = (i - 1)·(n_y + 1) + k
    e_j(e, 1) = j
    e_j(e, 2) = j + n_y + 1
    e_j(e, 3) = j + n_y + 2
    e_j(e, 4) = j + 1
  end
end
s_j = zeros(n_x + 1, 1)
for i = 1:n_x + 1
  s_j(i) = (i - 1)·(n_y + 1) + 1
end
#show
#: Nodes numbered by columns, from bottom to top. The nodes of the base are fixed:
s_j
#malla(x_j, y_j, e_j, s_j)

## 4 · Element stiffness
#: Strain–displacement matrix of the four-node rectangle, in natural coordinates ξ and η between −1 and 1. Row 1: ε_{x} = ∂u/∂x. Row 2: ε_{y} = ∂v/∂y. Row 3: γ_{xy} = ∂u/∂y + ∂v/∂x.
B(ξ, η) = [-(1 - η)/(2·a_1), 0, (1 - η)/(2·a_1), 0, (1 + η)/(2·a_1), 0, -(1 + η)/(2·a_1), 0; 0, -(1 - ξ)/(2·b_1), 0, -(1 + ξ)/(2·b_1), 0, (1 + ξ)/(2·b_1), 0, (1 - ξ)/(2·b_1); -(1 - ξ)/(2·b_1), -(1 - η)/(2·a_1), -(1 + ξ)/(2·b_1), (1 - η)/(2·a_1), (1 + ξ)/(2·b_1), (1 + η)/(2·a_1), (1 - ξ)/(2·b_1), -(1 + η)/(2·a_1)]
#: The stiffness is the integral of Bᵀ·D·B over the element; the Jacobian of the rectangle equals a₁·b₁/4 and the thickness, t:
#noc
K_e = t·(a_1·b_1/4)·Area{Area{transpose(B(ξ, η))·D·B(ξ, η) @ ξ = -1 : 1} @ η = -1 : 1}
#equ
#hide
K_e = t·(a_1·b_1/4)·integral2(@(ξ, η) transpose(B(ξ, η))·D·B(ξ, η), -1, 1, -1, 1)
#show
K_e [tonf/m]

## 5 · Assembly, lateral load and solution
#hide
d_j(j) = [2·j - 1, 2·j]
d_e(e) = [d_j(e_j(e, 1)), d_j(e_j(e, 2)), d_j(e_j(e, 3)), d_j(e_j(e, 4))]
K = zeros(n_d, n_d)
F = zeros(n_d, 1)
#show
#: The stiffness of each element is **added** into the rows and columns of its degrees of freedom:
for e = 1:n_e
  g = d_e(e)
  K(g, g) = K(g, g) + K_e
end
#: The shear V is delivered by the diaphragm as a UNIFORM load along the top: it is distributed to its nodes by the tributary width (half at the two ends).
for i = 1:n_x + 1
  j = s_j(i) + n_y
  trib = a_1
  if i == 1 || i == n_x + 1
    trib = a_1/2
  end
  F(2·j - 1) = F(2·j - 1) + V/L·trib
end
#: Check: the sum of the nodal forces must give the shear V:
ΣF = sum(F) [tonf]
#: Free degrees of freedom: all except those of the base (fixed in Ux and Uy).
#hide
L_g = zeros(n_d - 2·(n_x + 1), 1)
m = 0
for j = 1:n_j
  if y_j(j) > 0
    L_g(m + 1) = 2·j - 1
    L_g(m + 2) = 2·j
    m = m + 2
  end
end
U = zeros(n_d, 1)
#show
#: Solution of the system K·U = F in the free degrees of freedom:
U(L_g) = K(L_g, L_g)\F(L_g)

## 6 · Displacements
#hide
U_x = zeros(n_x + 1, n_y + 1)
for i = 1:n_x + 1
  for k = 1:n_y + 1
    U_x(i, k) = 1000·U(2·((i - 1)·(n_y + 1) + k) - 1)
  end
end
#show
#: Horizontal displacement at the top, at mid-length (the drift of the wall):
j_cor = s_j(round(n_x/2) + 1) + n_y
u_cor = 1000·U(2·j_cor - 1) [mm]
#: **Color map** of the horizontal displacement u_{x} in mm, over the WHOLE panel:
u_x(x, y) = spline(1 + x/a_1, 1 + y/b_1, U_x)
#map(u_x(x, y), [0 L], [0 H])
#: **Deformed shape** (magnified ×300, to see it): the short wall shears AND bends at the same time —
#: that is why the horizontals tilt (shear) and in addition the whole curves (bending).
esc = 300 'visual magnification factor
#hide
x_def = zeros(n_j, 1)
y_def = zeros(n_j, 1)
for j = 1:n_j
  x_def(j) = x_j(j) + esc·U(2·j - 1)
  y_def(j) = y_j(j) + esc·U(2·j)
end
#show
#malla(x_def, y_def, e_j, s_j)

## 7 · Forces F11, F22, F12
#: In a **membrane** element the forces are called F11, F22, F12 (force per unit width,
#: in tonf/m): F11 and F22 are axial in x and y, F12 is in-plane shear. They are **not** M11, M22, M12: those are
#: bending moments of a plate, and the wall does not bend out of its plane.
#: In each element σ = D·B·U_{e}, evaluated at its four nodes; at each node the elements meeting there are averaged. F = σ·t.
#hide
ξ_n = [-1, 1, 1, -1]
η_n = [-1, -1, 1, 1]
S_j = zeros(3, n_j)
c_j = zeros(n_j, 1)
for e = 1:n_e
  U_e = U(d_e(e))
  for i = 1:4
    j = e_j(e, i)
    c_j(j) = c_j(j) + 1
    S_j(:, j) = S_j(:, j) + D·B(ξ_n(i), η_n(i))·U_e
  end
end
for j = 1:n_j
  S_j(:, j) = S_j(:, j)/c_j(j)
end
F11_j = zeros(n_x + 1, n_y + 1)
F22_j = zeros(n_x + 1, n_y + 1)
F12_j = zeros(n_x + 1, n_y + 1)
for i = 1:n_x + 1
  for k = 1:n_y + 1
    jn = (i - 1)·(n_y + 1) + k
    F11_j(i, k) = t·S_j(1, jn)
    F22_j(i, k) = t·S_j(2, jn)
    F12_j(i, k) = t·S_j(3, jn)
  end
end
#show
#: **F11**, horizontal axial, in tonf/m:
F11(x, y) = spline(1 + x/a_1, 1 + y/b_1, F11_j)
#map(F11(x, y), [0 L], [0 H])
#: **F22**, vertical axial (bending of the wall as a cantilever: tension on one side, compression on the other), in tonf/m:
F22(x, y) = spline(1 + x/a_1, 1 + y/b_1, F22_j)
#map(F22(x, y), [0 L], [0 H])
#: **F12**, in-plane shear, in tonf/m — maximum at the fixed base:
F12(x, y) = spline(1 + x/a_1, 1 + y/b_1, F12_j)
#map(F12(x, y), [0 L], [0 H])
F12_base = F12_j(round(n_x/2) + 1, 1) [tonf/m] 'at the center of the fixed base

## 8 · Check with beam theory (bending + shear)
#: The short wall (H/L = 1) is a cantilever where the shear **cannot** be ignored — it is the
#: same reason why test II of the normal rotation (shear-dominated) needs the
#: element with drilling. With the inertia and area of the L×t section:
I = t·L^3/12 [m⁴]
A_c = t·L [m²]
G = E/(2·(1 + ν)) [tonf/m²]
δ_flex = 1000·V·H^3/(3·E·I) [mm]
δ_cort = 1000·1.2·V·H/(G·A_c) [mm]
δ_viga = δ_flex + δ_cort [mm]
frac_cortante = 100·δ_cort/(δ_flex + δ_cort) [%] 'how much of the displacement is shear ONLY
dif = 100·(u_cor - δ_viga)/δ_viga [%]
