# Finite element analysis of a rectangular slab
#numerico

#: A line-by-line replica of the Calcpad example **Rectangular Slab FEA** (Ned Ganchovski): the same plate element (16-degree-of-freedom rectangle, Hermite functions), the same 6 × 4 mesh, the same loads and the same supports. Here it runs in Hekatan LISP with the #numerico directive: the whole sheet is a program with state, as in Calcpad, and loops are written as in MATLAB.
#: **Units.** As in Calcpad: E in MPa (= MN/m²) and q in kN/m². Then K comes out in MN/m, F in kN and the ratio F/K in kN/(MN/m) = 10⁻³ m = **mm**. The moments −D·B·Z come out in MN·m · m⁻² · mm = **kN·m/m**. That is why the numbers match those of Calcpad without conversion factors.

## 1 · Data
a = 6 [m] 'slab length
b = 4 [m] 'slab width
t = 0.1 [m] 'thickness
q = 10 [kN/m²] 'distributed load
E = 35000 [MPa] 'modulus of elasticity
ν = 0.15 'Poisson's ratio

## 2 · Finite element mesh
#: Rectangular element with n degrees of freedom: at each of its 4 nodes, the deflection w, the rotations θx, θy and the warping ψ.
n = 16 'degrees of freedom of the element
n_a = 6 'elements along a
n_b = 4 'elements along b
n_e = n_a·n_b 'number of elements
n_j = (n_a + 1)·(n_b + 1) 'number of nodes
a_1 = a/n_a [m] 'element side in x
b_1 = b/n_b [m] 'element side in y
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
#: Node coordinates, numbered by columns (from bottom to top and from left to right):
x_j [m]
y_j [m]
#: Nodes of each element (one column per element, counterclockwise from the lower left corner):
transpose(e_j)
#: Supported nodes:
s_j
#malla(x_j, y_j, e_j, s_j)

## 3 · Element formulation
#: **Basis functions** (Hermite polynomials in the natural coordinate ξ = x/a₁ ∈ [0, 1]): Φ₁ and Φ₃ give the deflection of each end, Φ₂ and Φ₄ the rotation.
Φ_1a(ξ) = 1 - ξ^2·(3 - 2·ξ)
Φ_2a(ξ) = ξ·a_1·(1 - ξ·(2 - ξ))
Φ_3a(ξ) = ξ^2·(3 - 2·ξ)
Φ_4a(ξ) = ξ^2·a_1·(-1 + ξ)
#: First derivatives with respect to x (the chain rule divides by a₁):
Φprime_1a(ξ) = -6·(ξ/a_1)·(1 - ξ)
Φprime_2a(ξ) = 1 - ξ·(4 - 3·ξ)
Φprime_3a(ξ) = 6·(ξ/a_1)·(1 - ξ)
Φprime_4a(ξ) = -ξ·(2 - 3·ξ)
#: Second derivatives (curvatures):
Φpprime_1a(ξ) = -(6/a_1^2)·(1 - 2·ξ)
Φpprime_2a(ξ) = -(2/a_1)·(2 - 3·ξ)
Φpprime_3a(ξ) = 6/a_1^2·(1 - 2·ξ)
Φpprime_4a(ξ) = -(2/a_1)·(1 - 3·ξ)
#: The same along b, in η = y/b₁:
Φ_1b(η) = 1 - η^2·(3 - 2·η)
Φ_2b(η) = η·b_1·(1 - η·(2 - η))
Φ_3b(η) = η^2·(3 - 2·η)
Φ_4b(η) = η^2·b_1·(-1 + η)
Φprime_1b(η) = -6·(η/b_1)·(1 - η)
Φprime_2b(η) = 1 - η·(4 - 3·η)
Φprime_3b(η) = 6·(η/b_1)·(1 - η)
Φprime_4b(η) = -η·(2 - 3·η)
Φpprime_1b(η) = -(6/b_1^2)·(1 - 2·η)
Φpprime_2b(η) = -(2/b_1)·(2 - 3·η)
Φpprime_3b(η) = 6/b_1^2·(1 - 2·η)
Φpprime_4b(η) = -(2/b_1)·(1 - 3·η)
#: **Shape functions** of the plate: the PRODUCT of a function in ξ by another in η. Deflections w:
N_1w(ξ, η) = Φ_1a(ξ)·Φ_1b(η)
N_2w(ξ, η) = Φ_3a(ξ)·Φ_1b(η)
N_3w(ξ, η) = Φ_3a(ξ)·Φ_3b(η)
N_4w(ξ, η) = Φ_1a(ξ)·Φ_3b(η)
#: Rotations θx:
N_1θx(ξ, η) = Φ_2a(ξ)·Φ_1b(η)
N_2θx(ξ, η) = Φ_4a(ξ)·Φ_1b(η)
N_3θx(ξ, η) = Φ_4a(ξ)·Φ_3b(η)
N_4θx(ξ, η) = Φ_2a(ξ)·Φ_3b(η)
#: Rotations θy:
N_1θy(ξ, η) = Φ_1a(ξ)·Φ_2b(η)
N_2θy(ξ, η) = Φ_3a(ξ)·Φ_2b(η)
N_3θy(ξ, η) = Φ_3a(ξ)·Φ_4b(η)
N_4θy(ξ, η) = Φ_1a(ξ)·Φ_4b(η)
#: Warping ψ:
N_1ψ(ξ, η) = Φ_2a(ξ)·Φ_2b(η)
N_2ψ(ξ, η) = Φ_4a(ξ)·Φ_2b(η)
N_3ψ(ξ, η) = Φ_4a(ξ)·Φ_4b(η)
N_4ψ(ξ, η) = Φ_2a(ξ)·Φ_4b(η)
#: Vector of shape functions, in the order of the degrees of freedom (w, θx, θy, ψ of nodes 1, 2, 3, 4):
N(ξ, η) = [N_1w(ξ, η), N_1θx(ξ, η), N_1θy(ξ, η), N_1ψ(ξ, η), N_2w(ξ, η), N_2θx(ξ, η), N_2θy(ξ, η), N_2ψ(ξ, η), N_3w(ξ, η), N_3θx(ξ, η), N_3θy(ξ, η), N_3ψ(ξ, η), N_4w(ξ, η), N_4θx(ξ, η), N_4θy(ξ, η), N_4ψ(ξ, η)]
#: **Constitutive matrix** (moments ↔ curvatures):
D = E·t^3/(12·(1 - ν^2))·[1, ν, 0; ν, 1, 0; 0, 0, (1 - ν)/2]
#: **Strain–displacement matrix**: the rows are the curvatures ∂²w/∂x², ∂²w/∂y² and 2·∂²w/∂x∂y of each shape function.
B_1(ξ, η) = [Φpprime_1a(ξ)·Φ_1b(η), Φpprime_2a(ξ)·Φ_1b(η), Φpprime_1a(ξ)·Φ_2b(η), Φpprime_2a(ξ)·Φ_2b(η), Φpprime_3a(ξ)·Φ_1b(η), Φpprime_4a(ξ)·Φ_1b(η), Φpprime_3a(ξ)·Φ_2b(η), Φpprime_4a(ξ)·Φ_2b(η), Φpprime_3a(ξ)·Φ_3b(η), Φpprime_4a(ξ)·Φ_3b(η), Φpprime_3a(ξ)·Φ_4b(η), Φpprime_4a(ξ)·Φ_4b(η), Φpprime_1a(ξ)·Φ_3b(η), Φpprime_2a(ξ)·Φ_3b(η), Φpprime_1a(ξ)·Φ_4b(η), Φpprime_2a(ξ)·Φ_4b(η)]
B_2(ξ, η) = [Φ_1a(ξ)·Φpprime_1b(η), Φ_2a(ξ)·Φpprime_1b(η), Φ_1a(ξ)·Φpprime_2b(η), Φ_2a(ξ)·Φpprime_2b(η), Φ_3a(ξ)·Φpprime_1b(η), Φ_4a(ξ)·Φpprime_1b(η), Φ_3a(ξ)·Φpprime_2b(η), Φ_4a(ξ)·Φpprime_2b(η), Φ_3a(ξ)·Φpprime_3b(η), Φ_4a(ξ)·Φpprime_3b(η), Φ_3a(ξ)·Φpprime_4b(η), Φ_4a(ξ)·Φpprime_4b(η), Φ_1a(ξ)·Φpprime_3b(η), Φ_2a(ξ)·Φpprime_3b(η), Φ_1a(ξ)·Φpprime_4b(η), Φ_2a(ξ)·Φpprime_4b(η)]
B_3(ξ, η) = 2·[Φprime_1a(ξ)·Φprime_1b(η), Φprime_2a(ξ)·Φprime_1b(η), Φprime_1a(ξ)·Φprime_2b(η), Φprime_2a(ξ)·Φprime_2b(η), Φprime_3a(ξ)·Φprime_1b(η), Φprime_4a(ξ)·Φprime_1b(η), Φprime_3a(ξ)·Φprime_2b(η), Φprime_4a(ξ)·Φprime_2b(η), Φprime_3a(ξ)·Φprime_3b(η), Φprime_4a(ξ)·Φprime_3b(η), Φprime_3a(ξ)·Φprime_4b(η), Φprime_4a(ξ)·Φprime_4b(η), Φprime_1a(ξ)·Φprime_3b(η), Φprime_2a(ξ)·Φprime_3b(η), Φprime_1a(ξ)·Φprime_4b(η), Φprime_2a(ξ)·Φprime_4b(η)]
B(ξ, η) = [B_1(ξ, η); B_2(ξ, η); B_3(ξ, η)]

## 4 · Element stiffness matrix and loads
#: Each term of the stiffness is a double integral over the element (dx·dy = a₁·b₁·dξ·dη):
#noc
K_e = a_1·b_1·Area{Area{transpose(B(ξ, η))·D·B(ξ, η) @ ξ = 0 : 1} @ η = 0 : 1}
#equ
#: Calcpad evaluates it term by term with its numerical integral; here integral2 does it (adaptive Gauss-Legendre, exact for these polynomials) with the whole matrix at once:
#hide
K_e = a_1·b_1·integral2(@(ξ, η) transpose(B(ξ, η))·D·B(ξ, η), 0, 1, 0, 1)
#show
K_e [MN/m]
#: Element load vector: the distributed load q with the same shape functions.
#noc
F_e = a_1·b_1·Area{Area{N(ξ, η)·q @ ξ = 0 : 1} @ η = 0 : 1}
#equ
#hide
F_e = a_1·b_1·q·integral2(@(ξ, η) N(ξ, η), 0, 1, 0, 1)
#show
F_e [kN]

## 5 · Assembly and solution
#: Four degrees of freedom per node (k₁ = n/4). Those of node j are k₁·(j − 1) + 1 … k₁·j, and those of the element are those of its four nodes in sequence:
k_1 = n/4
n_d = k_1·n_j 'degrees of freedom of the slab
#hide
d_j(j) = k_1·(j - 1) + (1:k_1)
d_e(e) = [d_j(e_j(e, 1)), d_j(e_j(e, 2)), d_j(e_j(e, 3)), d_j(e_j(e, 4))]
K = zeros(n_d, n_d)
F = zeros(n_d, 1)
#show
#: Assembly: the stiffness and the load of each element are ADDED into the rows and columns of its degrees of freedom.
for e = 1:n_e
  g = d_e(e)
  K(g, g) = K(g, g) + K_e
  F(g) = F(g) + F_e
end
#: Supports (simply supported edge): a very stiff spring k_s on the deflection of each edge node and on the rotation along the edge, as in Calcpad.
k_s = 10^20
for i = 1:n_s
  j = k_1·(s_j(i) - 1) + 1
  K(j, j) = K(j, j) + k_s
  if y_j(s_j(i)) == 0 || y_j(s_j(i)) == b
    K(j + 1, j + 1) = K(j + 1, j + 1) + k_s
  end
  if x_j(s_j(i)) == 0 || x_j(s_j(i)) == a
    K(j + 2, j + 2) = K(j + 2, j + 2) + k_s
  end
end
#: Global stiffness matrix (the corners are shown):
K [MN/m]
#: Global load vector:
F [kN]
#: Solution of the system K·Z = F by Cholesky (clsolve, as in Calcpad: K is symmetric and positive definite):
Z = clsolve(K, F) [mm]

## 6 · Results
#: Node deflections (row = y, column = x), rounded to 0.001 mm as in Calcpad:
#hide
W_z = zeros(n_a + 1, n_b + 1)
for i = 1:n_a + 1
  for j = 1:n_b + 1
    W_z(i, j) = round(Z(4·((i - 1)·(n_b + 1) + j) - 3)·1000)/1000
  end
end
#show
transpose(W_z) [mm]
#: Between nodes, the deflection is interpolated with the Calcpad spline over the deflection matrix:
w(x, y) = spline(1 + x/a_1, 1 + y/b_1, W_z)
#map(-w(x, y), [0 6], [0 4])
w(a/2, b/2) [mm] 'maximum deflection, at the center

### Bending moments
#: In each element, M = −D·B·Z_e at its four nodes; at each node the elements that meet there are averaged.
#hide
Z_e(e) = Z(d_e(e))
M_j = zeros(3, n_j)
c_j = zeros(n_j, 1)
for e = 1:n_e
  Z_el = Z_e(e)
  x_1 = x_j(e_j(e, 1))
  y_1 = y_j(e_j(e, 1))
  for i = 1:4
    j = e_j(e, i)
    c_j(j) = c_j(j) + 1
    M_j(:, j) = M_j(:, j) - D·B((x_j(j) - x_1)/a_1, (y_j(j) - y_1)/b_1)·Z_el
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
i_c = round(n_a/2)
j_c = round(n_b/2)
#show
#: Results of the central element e_c and of its first node j₁:
e_c = (i_c - 1)·n_a + j_c + 1
j_1 = e_j(e_c, 1)
Z_e(e_c) [mm]
M_e(x, y) = -D·B(x/a_1, y/b_1)·Z_e(e_c)
M_e(0, 0) [kNm/m]
#: Average moments at the nodes (rows: Mx, My, Mxy):
M_j [kNm/m]
#: **Mx** (row = y, column = x):
transpose(Mx) [kNm/m]
M_x(x, y) = spline(1 + x/a_1, 1 + y/b_1, Mx)
#map(M_x(x, y), [0 6], [0 4])
M_x(a/2, b/2) [kNm/m] 'maximum
#: **My**:
transpose(My) [kNm/m]
M_y(x, y) = spline(1 + x/a_1, 1 + y/b_1, My)
#map(M_y(x, y), [0 6], [0 4])
M_y(a/2, b/2) [kNm/m] 'maximum
#: **Mxy** (torsion):
transpose(Mxy) [kNm/m]
M_xy(x, y) = spline(1 + x/a_1, 1 + y/b_1, Mxy)
#map(M_xy(x, y), [0 6], [0 4])
M_xy(0, 0) [kNm/m] 'maximum, at the corner
