# Cantilever slab fixed along one edge
#numerico

#: Slab with a 4 m cantilever (in x) and 2 m width, fixed at x = 0 and free at the other three edges, with uniform load (an eave, a balcony). **ν = 0** is taken on purpose: this way the slab has no anticlastic curvature and its EXACT solution is that of a cantilever beam, w(a) = q·a⁴/(8·D) and M(0) = −q·a²/2. That gives an exact reference, without tables.
#: **Units** (those of Calcpad): E in MPa and q in kN/m² → Z in **mm**; moments in **kN·m/m**.

## 1 · Data
a = 4 [m] 'slab side in x
b = 2 [m] 'slab side in y
t = 0.12 [m] 'thickness
q = 10 [kN/m²] 'distributed load
E = 35000 [MPa] 'modulus of elasticity (concrete)
ν = 0 'no Poisson effect: the plate works as a beam
D_p = E·t^3/(12·(1 - ν^2)) [MN·m] 'plate bending stiffness

## 2 · BFS mesh
#: Regular mesh of 8 × 4 square elements of 0.5 m.
n = 16 'degrees of freedom of the element
n_a = 8 'elements along a
n_b = 4 'elements along b
n_e = n_a·n_b 'number of elements
n_j = (n_a + 1)·(n_b + 1) 'number of nodes
a_1 = a/n_a [m] 'element side in x
b_1 = b/n_b [m] 'element side in y
#: Nodes numbered by columns, as in example 71: the node of column i_{a} and row i_{b} is j = (i_{a} − 1)·(n_{b} + 1) + i_{b}. Each element takes its 4 nodes counterclockwise from the lower left corner.
#hide
x_j = zeros(n_j, 1)
y_j = zeros(n_j, 1)
for i_a = 1:n_a + 1
  for i_b = 1:n_b + 1
    j = (i_a - 1)·(n_b + 1) + i_b
    x_j(j) = (i_a - 1)·a_1
    y_j(j) = (i_b - 1)·b_1
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
#show
#: **Supports.** Only the edge x = 0 is fixed: its nodes restrain the 4 degrees of freedom (w, θx, θy, ψ). The other edges are free. Each supported node stores a row of r_{s} with its 4 degrees of freedom (w, θx, θy, ψ): 1 = fixed, 0 = free.
#hide
s_j = 0
r_s = 0
n_s = 0
#show
for i_a = 1:n_a + 1
  for i_b = 1:n_b + 1
    j = (i_a - 1)·(n_b + 1) + i_b
    r = [0, 0, 0, 0]
    if i_a == 1
      r = [1, 1, 1, 1]
    end
    if sum(r) > 0
      n_s = n_s + 1
      s_j(n_s) = j
      r_s(n_s, 1:4) = r
    end
  end
end
n_s 'supported nodes
#malla(x_j, y_j, e_j, s_j, r_s)

## 3 · BFS element (Bogner–Fox–Schmit)
#: Rectangle of a₁ × b₁ with 4 degrees of freedom per node: deflection w, rotations θx = ∂w/∂x and θy = ∂w/∂y, and warping ψ = ∂²w/∂x∂y. It is the same element as in example 71 (verified against Calcpad on 849 values).
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
#: **Constitutive matrix** (moments ↔ curvatures); its factor is the bending stiffness D_p from the data:
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
#: Four degrees of freedom per node: those of node j are k₁·(j − 1) + 1 … k₁·j; those of the element, those of its four nodes in sequence.
k_1 = n/4
n_d = k_1·n_j 'degrees of freedom of the slab
#hide
d_j(j) = k_1·(j - 1) + (1:k_1)
d_e(e) = [d_j(e_j(e, 1)), d_j(e_j(e, 2)), d_j(e_j(e, 3)), d_j(e_j(e, 4))]
K = zeros(n_d, n_d)
F = zeros(n_d, 1)
#show
#: The stiffness and the load of each element are ADDED into the rows and columns of its degrees of freedom (all elements are equal: the mesh is regular).
for e = 1:n_e
  g = d_e(e)
  K(g, g) = K(g, g) + K_e
  F(g) = F(g) + F_e
end
#: Each fixed degree of freedom receives a very stiff spring k_{s} on the diagonal (as in Calcpad): its displacement stays at ≈ 0 without removing rows or columns.
k_s = 10^20
for i = 1:n_s
  j = k_1·(s_j(i) - 1)
  for k = 1:k_1
    if r_s(i, k) == 1
      K(j + k, j + k) = K(j + k, j + k) + k_s
    end
  end
end
#: K is symmetric and positive definite: it is solved by Cholesky (clsolve, as Calcpad).
Z = clsolve(K, F) [mm]

## 5 · Results
#: Node deflections (row = y, column = x). The deflection grows toward the free edge x = a and is the same along the whole column (with ν = 0 there is no transverse warping).
#hide
W_z = zeros(n_a + 1, n_b + 1)
for i = 1:n_a + 1
  for j = 1:n_b + 1
    W_z(i, j) = Z(4·((i - 1)·(n_b + 1) + j) - 3)
  end
end
#show
transpose(W_z) [mm]
w(x, y) = spline(1 + x/a_1, 1 + y/b_1, W_z)
#map(-w(x, y), [0 4], [0 2])
#: **Moments.** In each element M = −D·B·Z_{e} at its 4 nodes; at each node the elements that meet there are averaged. Mx is negative (tension on top) and maximum at the fixed edge; My ≈ 0 because with ν = 0 nothing bends the slab in y.
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
for i = 1:n_a + 1
  for k = 1:n_b + 1
    j = (i - 1)·(n_b + 1) + k
    Mx(i, k) = M_j(1, j)
    My(i, k) = M_j(2, j)
  end
end
#show
#: **Mx** (row = y, column = x):
transpose(Mx) [kNm/m]
M_x(x, y) = spline(1 + x/a_1, 1 + y/b_1, Mx)
#map(M_x(x, y), [0 4], [0 2])
#: **My**:
transpose(My) [kNm/m]
M_y(x, y) = spline(1 + x/a_1, 1 + y/b_1, My)
#map(M_y(x, y), [0 4], [0 2])

## 6 · Verification
#: **Reference 1 — exact solution** (cantilever beam of unit width; with ν = 0 the plate reproduces it exactly). The central row y = b/2 is used.
j_o(i_a, i_b) = (i_a - 1)·(n_b + 1) + i_b 'node of column i_{a} and row i_{b}
j_x = j_o(n_a + 1, n_b/2 + 1) 'free end, x = a
j_0 = j_o(1, n_b/2 + 1) 'fixed end, x = 0
w_x = Z(k_1·(j_x - 1) + 1) [mm] 'Hekatan LISP
w_T = q·a^4/(8·D_p) [mm] 'cantilever beam
dif_w = round((w_x - w_T)/w_T·100, 4) [%]
M_0 = M_j(1, j_0) [kNm/m] 'Hekatan LISP
M_T = -q·a^2/2 [kNm/m] 'cantilever beam
dif_M = round((M_0 - M_T)/M_T·100, 4) [%]
#: The deflection comes out EXACT: the Hermite element gives the exact nodal displacements of a beam with distributed load. The moment at the fixed end comes from the curvature of ONE element, which is linear, while that of the cantilever is parabolic: the difference is q·a₁²/12, the fixed-end moment of a 0.5 m span.
ΔM = q·a_1^2/12 [kNm/m] 'what is missing in M_0
#: **Reference 2 — another program, same mesh node by node.** Calcpad (*Rectangular Slab FEA* with these data and only the edge x = 0, fixed).
w_CP = 63.492063 [mm] 'Calcpad
dif_wCP = round((w_x - w_CP)/w_CP·100, 4) [%]
M_CP = -79.791667 [kNm/m] 'Calcpad
dif_MCP = round((M_0 - M_CP)/M_CP·100, 4) [%]
#| magnitud | referencia | referencia vale | Hekatan LISP | dif % |
#|---|---|--:|--:|--:|
#| w extremo [mm] | viga: q·a⁴/(8·D) | @{w_T} | @{w_x} | @{dif_w} |
#| Mx empotramiento [kNm/m] | viga: −q·a²/2 | @{M_T} | @{M_0} | @{dif_M} |
#| w extremo [mm] | Calcpad, misma malla | @{w_CP} | @{w_x} | @{dif_wCP} |
#| Mx empotramiento [kNm/m] | Calcpad, misma malla | @{M_CP} | @{M_0} | @{dif_MCP} |
