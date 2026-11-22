# The ways to invert a matrix — they all give the same
#: There is no SINGLE way to find A⁻¹, there are several. Here, on the SAME matrix, we go through four paths and check that all reach the same inverse. I use a matrix with an integer inverse so it reads clearly:
A = [4, 3; 1, 1]
#: (Its determinant is 4·1 − 3·1 = 1, so the inverse will come out with integers.)

## Method 1 — Adjugate / determinant
#: The classical one for 2×2: **A⁻¹ = adj(A) / det(A)**. The determinant and the adjugate:
det1 = det(A)
adj1 = adj(A)
#: And the inverse (adjugate divided by the determinant, which here is 1):
inv1 = adj(A) * (1/det(A))
#: → [1, −3; −1, 4].

## Method 2 — Gauss-Jordan (row reduction)
#: The identity is attached, [A | I], and reduced by rows to [I | A⁻¹]. I start from [A | I]:
J0 = [4, 3, 1, 0; 1, 1, 0, 1]
#: **R1 ↔ R2** (put a 1 on top to pivot comfortably):
J1 = [1, 1, 0, 1; 4, 3, 1, 0]
#: **F2 ← F2 − 4·F1**:
J2 = [1, 1, 0, 1; 0, -1, 1, -4]
#: **R2 ← −R2**, then **R1 ← R1 − R2**:
J3 = [1, 0, 1, -3; 0, 1, -1, 4]
#: On the right A⁻¹ = [1, −3; −1, 4] remained. Same as Method 1.

## Method 3 — Cayley-Hamilton
#: Every matrix satisfies its characteristic equation; for 2×2 it gives **A⁻¹ = (tr(A)·I − A) / det(A)**. The trace and the identity:
tr = trace(A)
I2 = [1, 0; 0, 1]
#: And the inverse by this path:
inv3 = (tr*I2 - A) * (1/det(A))
#: → [1, −3; −1, 4]. Identical, once again.

## Method 4 — Column by column (solving systems)
#: Each COLUMN of A⁻¹ is the solution of a system: the 1st column solves A·c = [1;0]; the 2nd, A·c = [0;1]. (It is exactly what Gauss-Jordan does, but separately.) The two columns:
e1 = [1; 0]
e2 = [0; 1]
col1 = inv(A) * e1
col2 = inv(A) * e2
#: 1st column [1; −1], 2nd column [−3; 4] → together they give A⁻¹ = [1, −3; −1, 4].

## Check — all four coincide and A·A⁻¹ = I
chk = A * inv(A)
#: A·A⁻¹ = [1 0; 0 1] ✓. The four paths —adjugate, Gauss-Jordan, Cayley-Hamilton, by columns— give **the same** inverse [1, −3; −1, 4].

## Note — it also works with LETTERS
#: The same formulas hold symbolically. For example [x, 1; 1, x]:
S = [x, 1; 1, x]
invS = inv(S)
#: → [x, −1; −1, x] / (x²−1). Symbolic or numeric, it is the same algebra.
