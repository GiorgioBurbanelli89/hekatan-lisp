# A system is algebra — solve it SYMBOLICALLY (no numbers at the end)
#: A system has UNKNOWNS, so it is algebra —just as 2x+2y=0 is algebra even if the coefficients are numbers—. Here we solve it with **symbolic operations**, keeping EVERYTHING in letters: we do not substitute a single number.

## 1 · The system (numeric coefficients; right-hand side in letters p, q)
#|  2x +  y = p
#:   x + 3y = q
#: The coefficients are 2, 1, 1, 3, but p, q and the unknowns x, y are LETTERS. Solving = finding x, y as functions of p, q.

## 2 · Matrix form: A · X = b
A = [2, 1; 1, 3]
xy = [x; y]
b = [p; q]
#: The product A·X reproduces the system:
AX = A * xy
#: A·X = {AX}, equated to b = [p; q].

## 3 · The determinant (decides whether there is a unique solution)
detA = det(A)
#: |A| = 5. Since it is not zero, there is a unique solution and we can invert.

## 4 · Solution by the INVERSE: X = A⁻¹·b (symbolic)
sol = inv(A) * b
#: X = [ (3p − q)/5 ; (2q − p)/5 ]. That is **x = (3p−q)/5, y = (2q−p)/5** — the solution in LETTERS, without a single number plugged in.

## 5 · The same solution by CRAMER'S RULE (determinants)
#: Cramer: each unknown is a quotient of determinants. For **x**, replace the 1st column of A by b, and compute its determinant:
Ax = [p, 1; q, 3]
detAx = det(Ax)
xc = detAx * (1/detA)
#: |Ax| = 3p−q, so x = |Ax|/|A| = (3p−q)/5. For **y**, replace the 2nd column by b:
Ay = [2, p; 1, q]
detAy = det(Ay)
yc = detAy * (1/detA)
#: |Ay| = 2q−p, so y = (2q−p)/5. **Same as by the inverse.**

## 6 · Symbolic check: A·(solution) = b
#: I multiply A by the solution found; it must return to the right-hand side [p; q]:
verif = A * sol
#: A·X = {verif}. It returns **[p; q]** exactly — the solution is correct, and everything stayed in letters.

## 7 · The homogeneous case: 2x + 2y = 0
#: If the right-hand side is zero and one equation is a multiple of the other, the determinant vanishes and there is NO unique solution. For example 2x + 2y = 0 reduces to x + y = 0, that is **y = −x**: infinitely many solutions (a whole line). The algebra shows it: without |A| ≠ 0, a single point cannot be solved for.

## Closing
#: · A system with unknowns is **algebra**, whether the coefficients are letters or numbers.
#: · It is solved with **symbolic** operations: inverse (X=A⁻¹·b) or Cramer (quotients of determinants), giving x, y as functions of p, q.
#: · Only when you want a concrete point do you put numbers in p, q — but the METHOD is pure algebra.
