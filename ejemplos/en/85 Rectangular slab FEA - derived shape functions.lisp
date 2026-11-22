# Rectangular slab by finite elements: DERIVED shape functions (Hermite)
#numerico

#: The Calcpad **Rectangular Slab FEA** slab (Ned Ganchovski), but with the shape functions
#: DERIVED by the engine instead of written by hand: four simple polynomials are split off
#: (constant, linear, quadratic, cubic), the matrix of conditions is built —
#: deflection and rotation at each end of the element —, it is inverted, and the four Hermite functions come out
#: with their derivatives. The subtraction against the Calcpad formulas gives zero.
#: **Order.** Part **A** does EVERYTHING in symbols, with the element side as a free L:
#: the engine differentiates, inverts and simplifies without using a single slab datum. Part **B**
#: brings the numbers: the mesh of @{n_a} × @{n_b} elements (@{a} m × @{b} m), the same
#: derivation repeated with arithmetic —the subtraction still gives zero— and from there the complete
#: analysis: stiffness, assembly, supports, deflections and moments.
#: **Why the derivation is repeated.** The numeric program does not compile the symbolic
#: operators: part A runs in the symbolic engine and stays as a formula; part B
#: runs in the numeric program. Two paths to the same calculation, and the subtractions of A.4 and of
#: B.3 check it against the same oracle.
#: **Oracles.** The Calcpad formulas (Rectangular Slab FEA) and sheet 71, which already
#: matches it to 4 decimals with 849 values.
#: To look at a datum without scrolling down: the constitutive matrix of the material ☞{tabla D} and the nodal deflections ☞{tabla W_z} appear when the mouse passes over the hand, and a note with the mesh inside the text ☞{the slab measures @{a} x @{b} m with @{n_a} x @{n_b} elements}.
#: **Units.** As in Calcpad: E in MPa (= MN/m²) and q in kN/m². Then K comes out in MN/m,
#: F in kN, the deflection in mm and the moments in kN·m/m.

## A · Symbolic derivation (only once, with the side L free)
#: All in symbols: no row of this part uses a slab datum. The four
#: conditions form a 4 × 4 matrix; its inverse is the coefficients being sought.

### A.1 · Four polynomials and the matrix of conditions
#: **Basis functions:** the four powers of x on the natural element, from 0 to 1.
#: **Four conditions** (those that define a Hermite function): the deflection is 1 at the left
#: end and 0 at the right; the rotation is 0 at both. The rotation row is divided by
#: the side L so that it stays in the same unit as the deflection. The engine differentiates each monomial
#: and evaluates the slope at the point (Slope):
p(x) = [1, x, x^2, x^3]
A_H = Simplify{[p(0); (1/L)*[Slope{1 @ x = 0}, Slope{x @ x = 0}, Slope{x^2 @ x = 0}, Slope{x^3 @ x = 0}]; p(1); (1/L)*[Slope{1 @ x = 1}, Slope{x @ x = 1}, Slope{x^2 @ x = 1}, Slope{x^3 @ x = 1}]]}
#: Row 1: the four functions equal 1 at the left end. Row 2: their slopes
#: there, divided by L. Row 3: they equal 0 at the right end. Row 4: their slopes
#: here, divided by L.

### A.2 · The inverse: the coefficients of the Hermite functions
#: Each unknown is the coefficient of a monomial in one of the four functions. The
#: system is matrix times unknown equals conditions, so the unknowns come out with the
#: inverse of A_H: each COLUMN of C_H is the set of coefficients (from the constant
#: up to the cubic) of one function. With that the Hermite function is derived, not written:
C_H = Simplify{inv(A_H)}

### A.3 · The four functions and the derivatives of the basis
#: Multiplying the basis by the inverse builds the four functions at once. The derivatives
#: come from the same differentiated basis (the engine applies Partial to each monomial, twice
#: for the curvatures):
Phi_a(x) = Simplify{p(x)*C_H}
dp_v = [Partial{1 @ x}, Partial{x @ x}, Partial{x^2 @ x}, Partial{x^3 @ x}]
d2p_v = [Partial{Partial{1 @ x} @ x}, Partial{Partial{x @ x} @ x}, Partial{Partial{x^2 @ x} @ x}, Partial{Partial{x^3 @ x} @ x}]

### A.4 · Comparison with Calcpad: the three subtractions give zero
#: Row by row against the formulas written by hand in sheet 71: first the functions,
#: then their slopes and finally the curvatures. If the derivation is right, everything cancels and
#: a vector of zeros remains — and it is checked with L still SYMBOLIC:
dif_0 = Simplify{p(x)*C_H - [1 - x^2*(3 - 2*x), x*L*(1 - x*(2 - x)), x^2*(3 - 2*x), x^2*L*(-1 + x)]}
dif_1 = Simplify{dp_v*C_H*(1/L) - [-6*(x/L)*(1 - x), 1 - x*(4 - 3*x), 6*(x/L)*(1 - x), -x*(2 - 3*x)]}
dif_2 = Simplify{d2p_v*C_H*(1/L^2) - [-(6/L^2)*(1 - 2*x), -(2/L)*(2 - 3*x), 6/L^2*(1 - 2*x), -(2/L)*(1 - 3*x)]}

### A.5 · From four functions to sixteen, and the matrix D
#: Each node of the rectangle has four degrees of freedom: the deflection w, the rotations θ_{x}
#: and θ_{y} and the twist ψ. The sixteen shape functions of the slab are the PRODUCT of a
#: function of x by one of y: four by four, a tensor product — one for each pair
#: of indices (the x one, the y one). The constitutive matrix only needs the material:
D_s = Simplify{E*t^3/(12*(1 - ν^2))*[1, ν, 0; ν, 1, 0; 0, 0, (1 - ν)/2]}
#: E, t and ν remain free: D enters with its numbers in B.4.

## B · With the numbers: the mesh, the same derivation and the analysis
#: Here the data come in —part A used none—, the derivation is repeated with arithmetic
#: and the same analysis of sheet 71 follows, which agrees with Calcpad.

### B.1 · Data
a = 6 [m] 'slab length
b = 4 [m] 'slab width
t = 0.1 [m] 'thickness
q = 10 [kN/m²] 'distributed load
E = 35000 [MPa] 'modulus of elasticity
ν = 0.15 'Poisson's ratio

### B.2 · Finite element mesh
#: Rectangular element with n degrees of freedom: at each of its 4 nodes, the deflection w, the rotations θx, θy and the twist ψ.
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

### B.3 · The same derivation, now with the mesh numbers
#: The matrix of conditions of A.1 evaluated with the element side. The
#: numeric library has no derivatives, so polyd applies the power rule in a loop (the
#: MATLAB diff) and peval evaluates the polynomial; the inverse gives the coefficients. The same
#: function condM builds the matrix for side a (in ξ) and for side b (in η):
function d = polyd(c)
  n = length(c)
  d = zeros(1, n - 1)
  for i = 1:n - 1
    d(i) = i*c(i + 1)
  end
end
function v = peval(c, x)
  n = length(c)
  v = 0
  for i = 1:n
    v = v + c(i)*x^(i - 1)
  end
end
function M = condM(L)
  M = zeros(4, 4)
  E4 = eye(4)
  for k = 1:4
    c = E4(:, k)
    M(1, k) = peval(c, 0)
    M(2, k) = peval(polyd(c), 0)/L
    M(3, k) = peval(c, 1)
    M(4, k) = peval(polyd(c), 1)/L
  end
end
A_a = condM(a_1)
C_a = inv(A_a)
A_b = condM(b_1)
C_b = inv(A_b)
#: With the mesh sides the two inverses are @{C_a} and @{C_b}. The four functions
#: derived in ξ (Pa) and in η (Pb), with their slopes and curvatures — again peval and
#: polyd, now on the columns of the inverse:
Pa(x, k) = peval(C_a(:, k), x)
dPa(x, k) = peval(polyd(C_a(:, k)), x)/a_1
d2Pa(x, k) = peval(polyd(polyd(C_a(:, k))), x)/a_1^2
Pb(y, k) = peval(C_b(:, k), y)
dPb(y, k) = peval(polyd(C_b(:, k)), y)/b_1
d2Pb(y, k) = peval(polyd(polyd(C_b(:, k))), y)/b_1^2
#: **Comparison with Calcpad:** the same subtractions of A.4, at an arbitrary point and with
#: the numeric sides. Those in ξ and in η give zero; the last one is last-digit rounding:
x_t = 0.37
y_t = 0.63
r1 = Pa(x_t, 1) - (1 - x_t^2*(3 - 2*x_t))
r2 = Pa(x_t, 2) - x_t*a_1*(1 - x_t*(2 - x_t))
r3 = Pa(x_t, 3) - x_t^2*(3 - 2*x_t)
r4 = Pa(x_t, 4) - x_t^2*a_1*(-1 + x_t)
rd1 = dPa(x_t, 1) - (-6*(x_t/a_1)*(1 - x_t))
rd2 = d2Pa(x_t, 1) - (-(6/a_1^2)*(1 - 2*x_t))
r5 = Pb(y_t, 1) - (1 - y_t^2*(3 - 2*y_t))
r6 = Pb(y_t, 2) - y_t*b_1*(1 - y_t*(2 - y_t))
rd5 = dPb(y_t, 1) - (-6*(y_t/b_1)*(1 - y_t))

### B.4 · The element matrices: D, the sixteen functions and B
#: The constitutive matrix, with the material numbers:
D = E·t^3/(12·(1 - ν^2))·[1, ν, 0; ν, 1, 0; 0, 0, (1 - ν)/2]
#: **Order of the sixteen degrees of freedom:** w, θx, θy and ψ of the four nodes (node 1
#: bottom left, counterclockwise). Column k of the matrix uses function
#: ia(k) of x and ib(k) of y: this repeats the tensor product of A.5 — the same structure
#: as in sheet 71:
ia = [1, 2, 1, 2, 3, 4, 3, 4, 3, 4, 3, 4, 1, 2, 1, 2]
ib = [1, 1, 2, 2, 1, 1, 2, 2, 3, 3, 4, 4, 3, 3, 4, 4]
#: **Vector of functions** (for the distributed load) and **matrix B**, whose row 1 is the
#: curvature in x, row 2 the curvature in y and row 3 the twist (double the
#: cross derivative), in natural coordinates from 0 to 1. A function block only sees its
#: parameters: C_a, C_b, a_1 and b_1 enter as arguments and peval and polyd are called, the
#: same formula as Pa:
function v = Nvec(x, y, ia, ib, C_a, C_b)
  v = zeros(16, 1)
  for k = 1:16
    k2 = ia(k)
    k3 = ib(k)
    v(k) = peval(C_a(:, k2), x)*peval(C_b(:, k3), y)
  end
end
function Bm = Bmat(x, y, ia, ib, C_a, C_b, a_1, b_1)
  Bm = zeros(3, 16)
  for k = 1:16
    k2 = ia(k)
    k3 = ib(k)
    ca = C_a(:, k2)
    cb = C_b(:, k3)
    Bm(1, k) = peval(polyd(polyd(ca)), x)*peval(cb, y)/a_1^2
    Bm(2, k) = peval(ca, x)*peval(polyd(polyd(cb)), y)/b_1^2
    Bm(3, k) = 2*peval(polyd(ca), x)*peval(polyd(cb), y)/(a_1*b_1)
  end
end
#: **Element stiffness and load** by 4 × 4 point Gauss quadrature (weights and points
#: of the standard rule, carried to the interval from 0 to 1): the stiffness multiplies two
#: B matrices, whose entries go up to degree 3, so the integrand reaches degree 6 and four
#: points are needed (they are exact up to degree 7). The load is of degree 3 and is also
#: exact:
gp = [0.5 - 0.5*0.8611363115940526, 0.5 - 0.5*0.3399810435848563, 0.5 + 0.5*0.3399810435848563, 0.5 + 0.5*0.8611363115940526]
gw = [0.5*0.3478548451374538, 0.5*0.6521451548625461, 0.5*0.6521451548625461, 0.5*0.3478548451374538]
K_e = zeros(16, 16)
for i = 1:4
  for j = 1:4
    Bg = Bmat(gp(i), gp(j), ia, ib, C_a, C_b, a_1, b_1)
    K_e = K_e + a_1·b_1·gw(i)·gw(j)·transpose(Bg)·D·Bg
  end
end
F_e = zeros(16, 1)
for i = 1:4
  for j = 1:4
    F_e = F_e + a_1·b_1·gw(i)·gw(j)·q·Nvec(gp(i), gp(j), ia, ib, C_a, C_b)
  end
end
K_e [MN/m]
F_e [kN]

### B.5 · Assembly and solution
#: Four degrees of freedom per node (k₁ = n/4). Those of node j are k₁·(j − 1) + 1 … k₁·j, and those of the element, those of its four nodes in sequence:
k_1 = n/4
n_d = k_1·n_j 'degrees of freedom of the slab
#hide
d_j(j) = k_1·(j - 1) + (1:k_1)
d_e(e) = [d_j(e_j(e, 1)), d_j(e_j(e, 2)), d_j(e_j(e, 3)), d_j(e_j(e, 4))]
K = zeros(n_d, n_d)
F = zeros(n_d, 1)
#show
#: Assembly: the stiffness and load of each element are ADDED into the rows and columns of its degrees of freedom.
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

### B.6 · Results
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
w_c = w(a/2, b/2) [mm] 'maximum deflection, at the center

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
    M_j(:, j) = M_j(:, j) - D·Bmat((x_j(j) - x_1)/a_1, (y_j(j) - y_1)/b_1, ia, ib, C_a, C_b, a_1, b_1)·Z_el
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
M_e(x, y) = -D·Bmat(x/a_1, y/b_1, ia, ib, C_a, C_b, a_1, b_1)·Z_e(e_c)
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
#: **Mxy** (twisting moment):
transpose(Mxy) [kNm/m]
M_xy(x, y) = spline(1 + x/a_1, 1 + y/b_1, Mxy)
#map(M_xy(x, y), [0 6], [0 4])
M_xy(0, 0) [kNm/m] 'maximum, at the corner
