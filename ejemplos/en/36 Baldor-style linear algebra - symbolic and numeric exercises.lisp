# Baldor-style linear algebra — symbolic and numeric exercises
#: Like the Baldor exercises, but for linear algebra: some with **letters** (pure algebra), others with **numbers**. The Hekatan LISP engine solves them. Each one: it is stated and solved.

## Exercise 1 — Inverse of a SYMBOLIC matrix
#: Given A, find det(A), its adjugate, its inverse, and check A·A⁻¹ = I.
A = [x, 1; 1, x]
dA = det(A)
adjA = adj(A)
iA = inv(A)
chkA = A * inv(A)
#: |A| = x²−1; the inverse is [x, −1; −1, x] / (x²−1); and A·A⁻¹ = I (the identity, symbolic). ✓

## Exercise 2 — With TWO letters
#: Now with x and y. Find det and inverse of B.
B = [x, y; y, x]
dB = det(B)
iB = inv(B)
#: |B| = x²−y²; inverse = [x, −y; −y, x] / (x²−y²).

## Exercise 3 — Entries that are POLYNOMIALS (watch the result!)
#: The entries are expressions. Find the determinant of C.
C = [x+1, x; x, x-1]
dC = det(C)
#: |C| = (x+1)(x−1) − x·x = x²−1 − x² = **−1**. The algebra cancels: a constant comes out.

## Exercise 4 — Product of symbolic matrices
#: Multiply two matrices with letters (each entry = row·column):
P = [x, 1; 0, x] * [x, 0; 1, x]
#: It gives [x²+1, x; x, x²]. The order matters; here it came out like this.

## Exercise 5 — Determinant of a SYMBOLIC 3×3
#: A tridiagonal 3×3 matrix. Find its determinant (cofactor expansion):
D = [x, 1, 0; 1, x, 1; 0, 1, x]
dD = det(D)
#: |D| = x·(x²−1) − 1·(x) = **x³ − 2x**. All symbolic, without a single number.

## Exercise 6 — Now with NUMBERS
#: The same theory, with numeric coefficients. Find det and inverse:
N = [2, 1; 1, 3]
dN = det(N)
iN = inv(N)
#: |N| = 5; inverse = (1/5)·[3, −1; −1, 2] = [3/5, −1/5; −1/5, 2/5].

## Exercise 7 — Solving a SYMBOLIC system A·X = b
#: With the matrix of ex. 1 and a right-hand side with letters p, q. Solve X = A⁻¹·b:
rhs = [p; q]
sol = inv(A) * rhs
#: X = [ (x·p − q)/(x²−1) ; (x·q − p)/(x²−1) ]. The solution of the system, with LETTERS. Substituting values (x, p, q) the numbers would come out.

## Closing
#: · Symbolic and numeric are **the same algebra**: det, adjugate, inverse, product, systems.
#: · With letters you see the general FORMULA; with numbers, the concrete result. Baldor, but for matrices.
