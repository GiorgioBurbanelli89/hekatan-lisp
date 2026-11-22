# Flat slab on columns (Calcpad Flat Slab FEA)
#numerico

#: Replica of the Calcpad **Flat Slab FEA** example (Ned Ganchovski): a flat slab (no beams) of 4 × 3 bays resting directly on 20 columns, with the same BFS element as example 71. What is new compared with sheets 71–76: the mesh is built from the bay SPANS and the supports are POINT supports, one per column, at the crossings of the axes.
#: **Units** (those of Calcpad): E in MPa and q in kN/m² → Z in **mm**; moments in **kN·m/m**.

## 1 · Data
#: Bay spans in x and y (column axes):
a = [3.6; 4.2; 4.2; 3.6] [m]
b = [3; 3.6; 3] [m]
n_sa = length(a) + 1 'axes in x
n_sb = length(b) + 1 'axes in y
#hide
x_s = zeros(n_sa, 1)
y_s = zeros(n_sb, 1)
for k = 1:n_sa - 1
  x_s(k + 1) = x_s(k) + a(k)
end
for k = 1:n_sb - 1
  y_s(k + 1) = y_s(k) + b(k)
end
#show
x_s [m] 'coordinates of the axes in x
y_s [m] 'coordinates of the axes in y
l_a = x_s(n_sa) [m] 'slab length
l_b = y_s(n_sb) [m] 'slab width
t = 0.2 [m] 'thickness
q = 10 [kN/m²] 'distributed load
E = 35000 [MPa] 'modulus of elasticity
ν = 0.2 'Poisson's ratio
D_p = E·t^3/(12·(1 - ν^2)) [MN·m] 'bending stiffness of the plate

## 2 · BFS mesh
#: Square elements of 0.6 m: each span has to be a multiple of 0.6 so that there is a node at each column axis.
n = 16 'degrees of freedom of the element
a_1 = 0.6 [m] 'element side in x
b_1 = 0.6 [m] 'element side in y
#: Elements per bay. round is used and not ceil: in floating point 4.2/0.6 = 7.000000000000001 and ceil would give 8.
n_a = round(a/a_1)
n_b = round(b/b_1)
n_ea = sum(n_a) 'elements along x
n_eb = sum(n_b) 'elements along y
n_ja = n_ea + 1 'nodes along x
n_jb = n_eb + 1 'nodes along y
n_e = n_ea·n_eb 'number of elements
n_j = n_ja·n_jb 'number of nodes
n_s = n_sa·n_sb 'columns (supported nodes)
#: Nodes numbered by mesh columns (from bottom to top and from left to right), as in example 71; elements with their 4 nodes counterclockwise.
#hide
x_j = zeros(n_j, 1)
y_j = zeros(n_j, 1)
for i_a = 1:n_ja
  for i_b = 1:n_jb
    j = (i_a - 1)·n_jb + i_b
    x_j(j) = (i_a - 1)·a_1
    y_j(j) = (i_b - 1)·b_1
  end
end
e_j = zeros(n_e, 4)
for i_a = 1:n_ea
  for i_b = 1:n_eb
    e = i_b + n_eb·(i_a - 1)
    j = e + i_a - 1
    e_j(e, 1) = j
    e_j(e, 2) = j + n_eb + 1
    e_j(e, 3) = j + n_eb + 2
    e_j(e, 4) = j + 1
  end
end
s_j = zeros(n_s, 1)
r_s = zeros(n_s, 4)
#show
#: **Supports.** A column at each axis crossing: the mesh node is e_{a} elements to the right and e_{b} up, with e_{a} and e_{b} the elements of the previous bays. The column only prevents the slab from going DOWN (w = 0); the rotations stay free, as in Calcpad (column pinned to the slab).
for k_a = 1:n_sa
  for k_b = 1:n_sb
    e_a = sum(n_a(1:k_a - 1))
    e_b = sum(n_b(1:k_b - 1))
    i_s = (k_a - 1)·n_sb + k_b
    s_j(i_s) = e_a·n_jb + e_b + 1
    r_s(i_s, 1) = 1
  end
end
transpose(s_j) 'nodes with a column
#malla(x_j, y_j, e_j, s_j, r_s)

## 3 · BFS element (Bogner–Fox–Schmit)
#: Rectangle of a₁ × b₁ with 4 degrees of freedom per node: deflection w, rotations θx = ∂w/∂x and θy = ∂w/∂y, and twist ψ = ∂²w/∂x∂y. It is the same element as in example 71 (verified against Calcpad in 849 values).
#: **Basis functions**: Hermite cubic polynomials in ξ = x/a₁ ∈ [0, 1]. Φ₁ and Φ₃ give the deflection of each end; Φ₂ and Φ₄, the rotation. With cubics the deflection and its slope are continuous between elements (Kirchhoff plate).
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
#: **Shape functions**: the PRODUCT of a function in ξ by another in η, in the order of the degrees of freedom (w, θx, θy, ψ of nodes 1, 2, 3, 4):
N(ξ, η) = [Φ_1a(ξ)·Φ_1b(η), Φ_2a(ξ)·Φ_1b(η), Φ_1a(ξ)·Φ_2b(η), Φ_2a(ξ)·Φ_2b(η), Φ_3a(ξ)·Φ_1b(η), Φ_4a(ξ)·Φ_1b(η), Φ_3a(ξ)·Φ_2b(η), Φ_4a(ξ)·Φ_2b(η), Φ_3a(ξ)·Φ_3b(η), Φ_4a(ξ)·Φ_3b(η), Φ_3a(ξ)·Φ_4b(η), Φ_4a(ξ)·Φ_4b(η), Φ_1a(ξ)·Φ_3b(η), Φ_2a(ξ)·Φ_3b(η), Φ_1a(ξ)·Φ_4b(η), Φ_2a(ξ)·Φ_4b(η)]
#: **Constitutive matrix** (moments ↔ curvatures); its factor is the bending stiffness D_p of the data:
D = D_p·[1, ν, 0; ν, 1, 0; 0, 0, (1 - ν)/2]
#: **B matrix**: its rows are the curvatures ∂²w/∂x², ∂²w/∂y² and 2·∂²w/∂x∂y of each shape function.
B_1(ξ, η) = [Φpprime_1a(ξ)·Φ_1b(η), Φpprime_2a(ξ)·Φ_1b(η), Φpprime_1a(ξ)·Φ_2b(η), Φpprime_2a(ξ)·Φ_2b(η), Φpprime_3a(ξ)·Φ_1b(η), Φpprime_4a(ξ)·Φ_1b(η), Φpprime_3a(ξ)·Φ_2b(η), Φpprime_4a(ξ)·Φ_2b(η), Φpprime_3a(ξ)·Φ_3b(η), Φpprime_4a(ξ)·Φ_3b(η), Φpprime_3a(ξ)·Φ_4b(η), Φpprime_4a(ξ)·Φ_4b(η), Φpprime_1a(ξ)·Φ_3b(η), Φpprime_2a(ξ)·Φ_3b(η), Φpprime_1a(ξ)·Φ_4b(η), Φpprime_2a(ξ)·Φ_4b(η)]
B_2(ξ, η) = [Φ_1a(ξ)·Φpprime_1b(η), Φ_2a(ξ)·Φpprime_1b(η), Φ_1a(ξ)·Φpprime_2b(η), Φ_2a(ξ)·Φpprime_2b(η), Φ_3a(ξ)·Φpprime_1b(η), Φ_4a(ξ)·Φpprime_1b(η), Φ_3a(ξ)·Φpprime_2b(η), Φ_4a(ξ)·Φpprime_2b(η), Φ_3a(ξ)·Φpprime_3b(η), Φ_4a(ξ)·Φpprime_3b(η), Φ_3a(ξ)·Φpprime_4b(η), Φ_4a(ξ)·Φpprime_4b(η), Φ_1a(ξ)·Φpprime_3b(η), Φ_2a(ξ)·Φpprime_3b(η), Φ_1a(ξ)·Φpprime_4b(η), Φ_2a(ξ)·Φpprime_4b(η)]
B_3(ξ, η) = 2·[Φprime_1a(ξ)·Φprime_1b(η), Φprime_2a(ξ)·Φprime_1b(η), Φprime_1a(ξ)·Φprime_2b(η), Φprime_2a(ξ)·Φprime_2b(η), Φprime_3a(ξ)·Φprime_1b(η), Φprime_4a(ξ)·Φprime_1b(η), Φprime_3a(ξ)·Φprime_2b(η), Φprime_4a(ξ)·Φprime_2b(η), Φprime_3a(ξ)·Φprime_3b(η), Φprime_4a(ξ)·Φprime_3b(η), Φprime_3a(ξ)·Φprime_4b(η), Φprime_4a(ξ)·Φprime_4b(η), Φprime_1a(ξ)·Φprime_3b(η), Φprime_2a(ξ)·Φprime_3b(η), Φprime_1a(ξ)·Φprime_4b(η), Φprime_2a(ξ)·Φprime_4b(η)]
B(ξ, η) = [B_1(ξ, η); B_2(ξ, η); B_3(ξ, η)]
#: **Element stiffness and load**: double integrals over the rectangle (dx·dy = a₁·b₁·dξ·dη), done with integral2 (Gauss-Legendre, exact for these polynomials).
#noc
K_e = a_1·b_1·Area{Area{transpose(B(ξ, η))·D·B(ξ, η) @ ξ = 0 : 1} @ η = 0 : 1}
F_e = a_1·b_1·Area{Area{N(ξ, η)·q @ ξ = 0 : 1} @ η = 0 : 1}
#equ
#hide
K_e = a_1·b_1·integral2(@(ξ, η) transpose(B(ξ, η))·D·B(ξ, η), 0, 1, 0, 1)
F_e = a_1·b_1·q·integral2(@(ξ, η) N(ξ, η), 0, 1, 0, 1)
#show

## 4 · Assembly and solution
k_1 = n/4
n_d = k_1·n_j 'degrees of freedom of the slab
#hide
d_j(j) = k_1·(j - 1) + (1:k_1)
d_e(e) = [d_j(e_j(e, 1)), d_j(e_j(e, 2)), d_j(e_j(e, 3)), d_j(e_j(e, 4))]
K = zeros(n_d, n_d)
F = zeros(n_d, 1)
#show
#: The stiffness and load of each element are ADDED into the rows and columns of its degrees of freedom:
for e = 1:n_e
  g = d_e(e)
  K(g, g) = K(g, g) + K_e
  F(g) = F(g) + F_e
end
#: Each column: a very stiff spring k_{s} in the w degree of freedom of its node.
k_s = 10^20
for i = 1:n_s
  j = k_1·(s_j(i) - 1)
  for k = 1:k_1
    if r_s(i, k) == 1
      K(j + k, j + k) = K(j + k, j + k) + k_s
    end
  end
end
#: Cholesky (clsolve) over the 1836 equations:
Z = clsolve(K, F) [mm]

## 5 · Results
#: Node deflections (row = y, column = x):
#hide
W_z = zeros(n_ja, n_jb)
for i = 1:n_ja
  for j = 1:n_jb
    W_z(i, j) = Z(4·((i - 1)·n_jb + j) - 3)
  end
end
#show
transpose(W_z) [mm]
w(x, y) = spline(1 + x/a_1, 1 + y/b_1, W_z)
#map(-w(x, y), [0 15.6], [0 9.6])
#: **Moments.** In each element M = −D·B·Z_{e} at its 4 nodes; at each node the elements that arrive at it are averaged. Over the columns peaks of NEGATIVE moment appear (tension at the top): it is what reinforces the flat slab.
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
Mx = zeros(n_ja, n_jb)
My = zeros(n_ja, n_jb)
for i = 1:n_ja
  for k = 1:n_jb
    j = (i - 1)·n_jb + k
    Mx(i, k) = M_j(1, j)
    My(i, k) = M_j(2, j)
  end
end
#show
#: **Mx** (row = y, column = x):
transpose(Mx) [kNm/m]
M_x(x, y) = spline(1 + x/a_1, 1 + y/b_1, Mx)
#map(M_x(x, y), [0 15.6], [0 9.6])
#: **My**:
transpose(My) [kNm/m]
M_y(x, y) = spline(1 + x/a_1, 1 + y/b_1, My)
#map(M_y(x, y), [0 15.6], [0 9.6])

## 6 · Verification
#: **Reference — another program, same model node by node:** the *Flat Slab FEA* example run in Calcpad with two adjustments so that it compares to 4 decimals: Cholesky (clsolve) instead of its iterative solver slsolve (tolerance 10⁻²) and integrals of K_{e} and F_{e} with Precision = 10⁻¹² instead of 10⁻⁴ (and W_z not rounded to 0.001 mm). With the example AS IS the differences are 0.005–0.008 %: they are those of those two tolerances, not of the model (see the last row of the table). Three nodes: the interior column of axis 3 (x = 7.8, y = 3), a node of the corner bay (x = 1.8, y = 1.2) and one of the central bay (x = 6.0, y = 4.8). The exact centres of those bays are not nodes: 3 m and 4.2 m are an ODD number of elements.
j_o(i_a, i_b) = (i_a - 1)·n_jb + i_b 'node of mesh column i_{a} and row i_{b}
j_c = j_o(n_a(1) + n_a(2) + 1, n_b(1) + 1) 'interior column
j_m = j_o(4, 3) 'corner bay
j_p = j_o(11, 9) 'central bay
M_xc = M_j(1, j_c) [kNm/m] 'Mx over the column
M_xcCP = -36.536664 [kNm/m] 'Calcpad
dif_xc = round((M_xc - M_xcCP)/M_xcCP·100, 4) [%]
w_m = Z(k_1·(j_m - 1) + 1) [mm] 'deflection in the corner bay
w_mCP = 0.6204587 [mm] 'Calcpad
dif_wm = round((w_m - w_mCP)/w_mCP·100, 4) [%]
M_xm = M_j(1, j_m) [kNm/m]
M_xmCP = 8.134667 [kNm/m] 'Calcpad
dif_xm = round((M_xm - M_xmCP)/M_xmCP·100, 4) [%]
w_p = Z(k_1·(j_p - 1) + 1) [mm] 'deflection in the central bay
w_pCP = 0.5376822 [mm] 'Calcpad
dif_wp = round((w_p - w_pCP)/w_pCP·100, 4) [%]
w_max = max(W_z) [mm] 'maximum slab deflection
w_maxCP = 0.6349423 [mm] 'Calcpad
dif_wmax = round((w_max - w_maxCP)/w_maxCP·100, 4) [%]
w_maxO = 0.6348933 [mm] 'Calcpad, example as is (slsolve, Precision 10⁻⁴)
dif_wmaxO = round((w_max - w_maxO)/w_maxO·100, 4) [%]
#: **Equilibrium** (independent of any program): the reaction of each column is k_{s}·w of its node (the spring shortens by w ≈ 10⁻¹⁷ mm), and all together must add up to the total load q·l_{a}·l_{b}.
R_t = k_s·sum(Z(k_1·(s_j - 1) + 1)) [kN] 'sum of reactions
Q = q·l_a·l_b [kN] 'total load
dif_R = round((R_t - Q)/Q·100, 4) [%]
#| magnitud | referencia | referencia vale | Hekatan LISP | dif % |
#|---|---|--:|--:|--:|
#| Mx columna interior [kNm/m] | Calcpad, mismo modelo (clsolve) | @{M_xcCP} | @{M_xc} | @{dif_xc} |
#| w vano de esquina [mm] | Calcpad, mismo modelo (clsolve) | @{w_mCP} | @{w_m} | @{dif_wm} |
#| Mx vano de esquina [kNm/m] | Calcpad, mismo modelo (clsolve) | @{M_xmCP} | @{M_xm} | @{dif_xm} |
#| w vano central [mm] | Calcpad, mismo modelo (clsolve) | @{w_pCP} | @{w_p} | @{dif_wp} |
#| w máxima [mm] | Calcpad, mismo modelo (clsolve) | @{w_maxCP} | @{w_max} | @{dif_wmax} |
#| w máxima [mm] | Calcpad, ejemplo tal cual | @{w_maxO} | @{w_max} | @{dif_wmaxO} |
#| suma de reacciones [kN] | equilibrio, q·l_{a}·l_{b} | @{Q} | @{R_t} | @{dif_R} |
