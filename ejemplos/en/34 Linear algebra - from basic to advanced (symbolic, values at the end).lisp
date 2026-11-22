# Linear algebra — from basic to advanced (all symbolic; numbers at the end)
#: Exercise rule: **first the algebra with letters**, reduce it to a simple formula, and **substitute the values only at the end**. This way you see the PROCESS, not just the number. The Hekatan LISP engine solves it.

## 1 · Scalar: a linear equation
#: The most basic case: one equation with one unknown, **p·x + q = r**. Solve it with pure algebra:
#|  p·x + q = r   →   p·x = r − q   →   x = (r − q) / p
#: That is the general formula. **Now** I substitute p=3, q=2, r=1 (that is, 3x + 2 = 1):
x = Simplify{(1 - 2)/3}
#: It gives {x}. The number appears ONLY at the end; the algebra (solving) was symbolic.

## 2 · Vector: basic operations
#: A generic column vector and another one:
u = [u1; u2]
v = [v1; v2]
#: **Dot product** (row·column) → a scalar, symbolic:
punto = transpose(u) * v
#: **Squared norm** (length²) = dot product with itself:
n2s = transpose(u) * u
#: The norm is its root: |u| = √(u1²+u2²). **Now I substitute** u=[3;4], v=[1;2]:
un = [3; 4]
vn = [1; 2]
puntoN = transpose(un) * vn
n2N = transpose(un) * un
normaN = sqrt(transpose(un) * un)
#: Dot = {puntoN}, length² = {n2N}, and the norm |u| = {normaN} (the 3-4-5 of Pythagoras).

## 3 · Matrix: the determinant (symbolic → number)
#: A generic 2×2 matrix:
A = [a11, a12; a21, a22]
#: Its **determinant** by algebra: |A| = a11·a22 − a12·a21:
detSim = det(A)
#: **Substitute** A = [2, 1; 1, 3]:
An = [2, 1; 1, 3]
detNum = det(An)
#: |A| = {detNum} (2·3 − 1·1 = 5).

## 4 · The inverse — METHOD 1: adjugate / determinant
#: The classical method for 2×2: **A⁻¹ = adj(A) / det(A)**. The adjugate (diagonal swapped, the other entries with sign changed):
adjSim = adj(A)
#: And the symbolic inverse:
invAdj = adj(A) * (1/det(A))
#: It gives [a22, −a12; −a21, a11] divided by the determinant. All with letters.

## 5 · The inverse — METHOD 2: Cayley-Hamilton
#: Every matrix satisfies its own characteristic equation. For 2×2: A² − tr(A)·A + det(A)·I = 0. Solving: **A⁻¹ = (tr(A)·I − A) / det(A)**. The trace and the identity:
tr = trace(A)
I2 = [1, 0; 0, 1]
#: And the inverse by this other route:
invCH = (tr*I2 - A) * (1/det(A))
#: **It is IDENTICAL to the adjugate one** — two different derivations, the same matrix. (tr·I − A turns out to be exactly the adjugate.)

## 6 · The inverse — METHOD 3: Gauss-Jordan (the general method)
#: The method programs use: the identity is attached alongside, [A | I], and reduced by rows to [I | A⁻¹]. It is a PROCEDURE (step by step), best seen with numbers. I start from [A | I] with A = [2,1;1,3]:
G0 = [2, 1, 1, 0; 1, 3, 0, 1]
#: **R2 ← R2 − ½·R1** (make 0 below the pivot):
G1 = [2, 1, 1, 0; 0, 5/2, -1/2, 1]
#: **R2 ← (2/5)·R2** (pivot = 1):
G2 = [2, 1, 1, 0; 0, 1, -1/5, 2/5]
#: **R1 ← R1 − R2** (make 0 above the pivot):
G3 = [2, 0, 6/5, -2/5; 0, 1, -1/5, 2/5]
#: **R1 ← ½·R1** (pivot = 1). On the left the identity remains; on the right, the inverse:
G4 = [1, 0, 3/5, -1/5; 0, 1, -1/5, 2/5]
#: The right half is A⁻¹ = [3/5, −1/5; −1/5, 2/5].

## 7 · Final substitution: the THREE methods give the same
#: Now I substitute A = [2, 1; 1, 3] in the two symbolic ones and compare with Gauss-Jordan:
invNum = inv(An)
#: **A⁻¹ = {invNum}** — equal to Cayley-Hamilton and equal to the right half of Gauss-Jordan. The proof that it is the inverse: A·A⁻¹ = identity:
chk = An * inv(An)
#: [1 0; 0 1] ✓. Three different paths, a single result.

## 8 · Advanced: solving a system A·x = b
#: The same serves to solve. Symbolic: **x = A⁻¹·b**:
b = [b1; b2]
xSim = inv(A) * b
#: **Substitute** A = [2,1;1,3] and b = [5; 10]:
bn = [5; 10]
xNum = inv(An) * bn
#: Solution x = {xNum}. (Check: 2·1+1·3=5 ✓, 1·1+3·3=10 ✓.)

## 9 · Summary
#: · Always: **algebra with letters first**, the number **at the end**.
#: · Inverse of 2×2: **adjugate/det** and **Cayley-Hamilton** give the same symbolically; **Gauss-Jordan** gets it by row reduction.
#: · Solving A·x = b = assemble A, assemble b, and x = A⁻¹·b. It is the core of structural analysis (K·d = F).
