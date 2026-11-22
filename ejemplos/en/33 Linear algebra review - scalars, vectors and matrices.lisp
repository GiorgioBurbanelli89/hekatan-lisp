# Linear algebra review — all symbolic (scalars, vectors, matrices)
#: A COMPLETE review of the linear algebra operations, ALL solved **symbolically** (with letters, no numbers). It is exactly what the FEM uses inside. The Hekatan LISP engine does each operation and shows the result with letters.

## 1 · Scalars: the algebra of a single number
#: A scalar is a single number (here, a letter). With scalars you do the algebra you already know.
#: **Common factor and canceling**:
frac = Simplify{(p*q + p*r)/p}
#: **Expanding a binomial** (multiply and group):
ex = Expand{(p+q)^2}
#: **Adding fractions** (common denominator):
sf = Simplify{1/p + 1/q}
#: Everything with ONE unknown. LINEAR algebra appears when there are SEVERAL at once: that is where vectors and matrices come in.

## 2 · Vectors: an ordered list of numbers
#: A vector groups several numbers in a column (an "arrow" with direction and length):
u = [u_1; u_2]
v = [v_1; v_2]
#: **Sum** (component by component):
suma = u + v
#: **Subtraction**:
resta = u - v
#: **Scalar times vector** (stretches or shrinks the arrow):
esc = k * u
#: **Linear combination** (a mix of two vectors with weights al and be):
comb = al*u + be*v
#: **Transpose** (column → row), written uᵀ:
uf = transpose(u)
#: **Dot product** uᵀ·v: pair by pair and add. It gives ONE scalar. It measures how much two vectors **point the same way** (if it is 0, they are perpendicular):
dot = transpose(u) * v
#: **Squared norm** (the length²): dot product with itself = u1²+u2² (Pythagoras):
n2 = transpose(u) * u
#: **Outer product** u·vᵀ (column × row): the opposite of the dot, it gives a MATRIX:
ext = u * transpose(v)

## 3 · Cross product (vectors in 3D)
#: Only in 3D. Two vectors of three components:
w = [w_1; w_2; w_3]
z = [z_1; z_2; z_3]
#: The **cross product** w×z gives a vector **perpendicular** to both (useful for surface normals, moments, areas):
cr = cross(w, z)

## 4 · Matrices: a table that TRANSFORMS vectors
#: A matrix transforms a vector into another (rotates it, stretches it). Two 2×2 ones:
A = [a_11, a_12; a_21, a_22]
Bm = [b_11, b_12; b_21, b_22]
#: **Sum** and **subtraction** (component by component):
sumaM = A + Bm
restaM = A - Bm
#: **Scalar times matrix** (multiplies each entry):
A_k = k * A
#: **Matrix times vector** A·u: THIS is how a vector is transformed (each component is a dot product row·vector):
A_u = A * u
#: **Matrix product** A·B (chains two transformations):
A_B = A * Bm
#: **CAREFUL, order matters**: in general A·B ≠ B·A:
B_A = Bm * A
#: **Power** A² = A·A (apply the same transformation twice):
A_2 = A * A
#: **Transpose** Aᵀ (reflects across the diagonal, rows ↔ columns):
A_t = transpose(A)
#: **Trace** tr(A): the sum of the diagonal (a scalar; it appears in eigenvalues and invariants):
tr = trace(A)

## 5 · Determinant: does the matrix flatten space?
#: The determinant is ONE number: how much the transformation enlarges or shrinks areas:
det_A = det(A)
#: It is a_{11}·a_{22} − a_{12}·a_{21}. If **det = 0**, the matrix flattens the plane into a line → **it has no inverse**. If det ≠ 0, it does.

## 6 · The inverse: undoing the transformation
#: **Adjugate** (swap the diagonal, change the sign of the other):
A_adj = adj(A)
#: **Inverse** = adjugate ÷ determinant:
A_inv = inv(A)
#: Proof that it "undoes": A times its inverse gives the **identity** (the matrix that does nothing):
chk = A * inv(A)
#: It gives [1 0; 0 1] ✓. And the other way around too, A⁻¹·A = I.

## 7 · Properties worth keeping in view
#: **The transpose of a product reverses the order**: (A·B)ᵀ = Bᵀ·Aᵀ. Look —both give the SAME matrix—:
lhs = transpose(A * Bm)
rhs = transpose(Bm) * transpose(A)
#: **The identity changes nothing**: A·I = A (like multiplying by 1). With the identity matrix:
Id = [1, 0; 0, 1]
A_I = A * Id

## 8 · Solving a system: A·x = b
#: This is what EVERYTHING above is for: finding the vector **x** that A transforms into a given **b**. It is the heart of the FEM: **K·d = F** (stiffness × displacements = forces). It is solved with the INVERSE (like dividing, but with matrices):
#|  A·x = b   →   x = A⁻¹·b
bb = [b_1; b_2]
x = inv(A) * bb
#: There is the solution: the displacements as a function of the stiffness A and the loads b —symbolic and exact—. That is, in essence, what a structural program does: it assembles A, assembles b and solves **x = A⁻¹·b**.

## 9 · Summary
#: · **Scalar**: add, multiply, expand, simplify, solve for.
#: · **Vector**: sum, subtraction, scalar, linear combination; dot (uᵀv → scalar), outer (uvᵀ → matrix), cross (3D → perpendicular).
#: · **Matrix**: sum, subtraction, scalar, product (order matters!), power, transpose, trace.
#: · **Determinant**: if it is 0, there is no inverse. · **Inverse**: undoes (A·A⁻¹ = I).
#: · **System A·x = b** → x = A⁻¹·b. The engine of every structural calculation.
