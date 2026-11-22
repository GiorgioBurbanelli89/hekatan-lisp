# Solving a system of equations — with NUMBERS and the unknowns x, y
#: No abstract coefficients (no a₁₁, a₁₂): real numbers as coefficients and the unknowns **x, y**. It is the most practical use of linear algebra: solving a system. Only at the end are the found values substituted.

## 1 · The system (two equations, two unknowns)
#|  2x +  y = 5
#|   x + 3y = 10

## 2 · In matrix form: A · X = b
#: The coefficients (numbers) go in the matrix **A**; the unknowns in the vector **X**; the results in **b**:
A = [2, 1; 1, 3]
xy = [x; y]
b = [5; 10]
#: The product A·X reproduces the equations —row by unknowns—:
AX = A * xy
#: A·X = {AX}. Set equal to b = [5; 10] they are exactly **2x+y = 5** and **x+3y = 10**. So a table of numbers and a vector of unknowns hold the WHOLE system.

## 3 · Does it have a solution? The determinant
#: From A·X = b we solve **X = A⁻¹·b** (like dividing, but with matrices). First, the determinant tells whether A has an inverse:
detA = det(A)
#: |A| = 5 ≠ 0 → it **does** have an inverse, the system has a unique solution.

## 4 · The inverse of A — FORM 1: adjugate / determinant
#: **A⁻¹ = adj(A) / det(A)**. The adjugate (main diagonal swapped, the other with sign changed):
adjA = adj(A)
#: And the inverse:
invA = adj(A) * (1/det(A))
#: → (1/5)·[3, −1; −1, 2].

## 5 · The inverse of A — FORM 2: Cayley-Hamilton
#: Another way: A⁻¹ = (tr(A)·I − A) / det(A). The trace and the identity:
tr = trace(A)
I2 = [1, 0; 0, 1]
invCH = (tr*I2 - A) * (1/det(A))
#: **Identical** to the adjugate one — two paths, the same inverse.

## 6 · The inverse of A — FORM 3: Gauss-Jordan
#: The general method: the identity is attached, [A | I], and reduced by rows to [I | A⁻¹]. I start from [A | I]:
G0 = [2, 1, 1, 0; 1, 3, 0, 1]
#: **R2 ← R2 − ½·R1**:
G1 = [2, 1, 1, 0; 0, 5/2, -1/2, 1]
#: **R2 ← (2/5)·R2**, then **R1 ← R1 − R2**, then **R1 ← ½·R1**:
G2 = [1, 0, 3/5, -1/5; 0, 1, -1/5, 2/5]
#: On the right A⁻¹ = [3/5, −1/5; −1/5, 2/5] remained. The three forms give the same.

## 7 · The solution: X = A⁻¹·b
sol = inv(A) * b
#: **X = [1; 3]**, that is **x = 1, y = 3**. The solution of the same equations was A⁻¹·b.

## 8 · Check: substitute x = 1, y = 3 in the system
#: Only NOW do I put the found values into the original equations:
eq1 = 2*1 + 1*3
eq2 = 1*1 + 3*3
#: 2x+y = {eq1} = 5 ✓  ·  x+3y = {eq2} = 10 ✓. Both hold: the solution is correct.

## 9 · Summary
#: · A system **2x+y=5, x+3y=10** is stored as **A·X = b** (numbers in A, unknowns x,y in X).
#: · It is solved with the **inverse**: X = A⁻¹·b. The 2×2 inverse comes from **adjugate/det**, **Cayley-Hamilton** (the same) or **Gauss-Jordan** (by rows).
#: · Result x=1, y=3; it is checked by substituting in the equations. It is the same A·X=b of FEM (K·d=F).
