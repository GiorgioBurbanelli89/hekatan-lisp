# All the ways to invert a matrix — symbolic, step by step
#: Inverting is not pressing a button: it is a **procedure**, and there are **many paths** that arrive at the same place. Here they all are, done with **letters** —without a single number— and with each step solved by the engine. Nothing that follows is written by hand: what appears to the right of each equals sign was computed by Hekatan LISP.
#: The working matrix and the identity, which is the matrix that **does nothing**:
A = [a11, a12; a21, a22]
Id = [1, 0; 0, 1]
#: Inverting A is finding the matrix that **undoes** what A does. That is the whole definition, and it is the test that will be repeated at the end of each path.

## 0 · The ingredients: minor, cofactor, adjugate and determinant
#: Before the paths, the four pieces from which almost all of them are made. The **minor** of a position is what remains after crossing out its row and its column. The four minors of A, one per position:
m11 = menor(A, 1, 1)
m12 = menor(A, 1, 2)
m21 = menor(A, 2, 1)
m22 = menor(A, 2, 2)
#: The **cofactor** is the minor with a sign that alternates like the squares of a chessboard. The whole cofactor matrix:
Cf = cof(A)
#: The **adjugate** is the transpose of that cofactor matrix: the diagonal stays still and the other crosses over.
adjA = adj(A)
#: And this confirms it without argument: transposing the cofactors gives exactly the adjugate.
adjB = transpose(cof(A))
#: The **determinant** is not a rule one has to believe either: it comes from running along the first row multiplying each entry by its minor, with the alternating sign. That is the Laplace expansion, and the engine solves it:
dLap = a11*menor(A, 1, 1) - a12*menor(A, 1, 2)
#: Letter by letter, it is the same as what the determinant returns:
dA = det(A)

## 1 · Adjugate divided by the determinant
#: The classical path. The adjugate places each cofactor in its place and the determinant scales them. Notice that the determinant stays **below** the four entries:
inv1 = adj(A) * (1/det(A))
#: There you see why the determinant cannot be zero: it would be dividing by zero four times. And the proof that this matrix undoes A:
chk1 = A * (adj(A) * (1/det(A)))

## 2 · Gauss-Jordan, with the row moves made into a matrix
#: Gauss-Jordan is always explained "moving rows by hand". But each row move **is a matrix**, and multiplying by it performs the move. That way the reduction is really executed by the engine, without anyone typing the result of any step.
#: First move: divide row 1 by the pivot, so that a one is left at the top left.
E1 = [1/a11, 0; 0, 1]
p1 = E1 * A
#: Second: subtract from row 2 row 1 multiplied by its first term, to open a zero below the pivot.
E2 = [1, 0; -a21, 1]
p2 = E2 * E1 * A
#: Look at what has appeared at the bottom right: the determinant divided by the pivot. Nobody put it there, it comes out by itself.
#: Third: divide row 2 by that second pivot, so that it also leaves a one.
E3 = [1, 0; 0, a11/(a11*a22 - a12*a21)]
p3 = E3 * E2 * E1 * A
#: Fourth and last: clear the term that remains at the top right.
E4 = [1, -a12/a11; 0, 1]
p4 = E4 * E3 * E2 * E1 * A
#: It has reached the identity. And there is the whole idea of Gauss-Jordan: if the product of the four moves turns A into the identity, **that product is the inverse**.
inv2 = E4 * E3 * E2 * E1
#: It is the same matrix as in Form 1, with the fractions distributed differently. The proof:
chk2 = (E4 * E3 * E2 * E1) * A

## 3 · Cayley-Hamilton: the matrix solves its own equation
#: Every matrix satisfies its characteristic equation. For a 2×2 it says that its square, minus the trace times it, plus the determinant times the identity, vanishes. There is no need to believe it: the engine checks it and the **zero** matrix comes out.
CH = A*A - trace(A)*A + det(A)*Id
#: From that equality the inverse is solved without naming the word cofactor even once: the trace times the identity, minus the matrix itself, all divided by the determinant.
inv3 = (trace(A)*Id - A) * (1/det(A))
#: Identical to the previous ones, by a completely different path. The proof:
chk3 = A * ((trace(A)*Id - A) * (1/det(A)))

## 4 · Faddeev-LeVerrier: Cayley-Hamilton for any size
#: The previous path used the form of the characteristic equation of a 2×2. Faddeev-LeVerrier builds it by itself, for any size, chaining traces. The first coefficient is the trace; the second comes from the trace of the next product:
FM = A - trace(A)*Id
Fc = trace(A*(A - trace(A)*Id)) * (1/2)
#: And that coefficient is, up to sign, the determinant —which the method discovers instead of assuming—. The inverse is the last term divided by it:
inv4 = (A - trace(A)*Id) * (1/Fc)
chk4 = A * ((A - trace(A)*Id) * (1/Fc))

## 5 · Cramer: each column of the inverse is a system
#: The inverse can be built **column by column**. The first column is the one that A transforms into the first vector of the identity; the second, into the second. Each one is solved with Cramer: one column of A is replaced by the right-hand side and one determinant is divided by another.
bb = [b1; b2]
Ab1 = [b1, a12; b2, a22]
Ab2 = [a11, b1; a21, b2]
#: This is how the solution of the system is written, as Cramer writes it —quotient of determinants—:
xcr = [det(Ab1)/det(A); det(Ab2)/det(A)]
#: And this shows that Cramer and the adjugate are the same algebra in different clothes: the adjugate times the right-hand side gives exactly the numerators above.
adjbb = adj(A) * bb
#: Putting the columns of the identity as the right-hand side gives, one by one, the columns of the inverse:
col1 = [det([1, a12; 0, a22])/det(A); det([a11, 1; a21, 0])/det(A)]
col2 = [det([0, a12; 1, a22])/det(A); det([a11, 0; a21, 1])/det(A)]

## 6 · Factorising into two triangular matrices (LU)
#: Another path: split A into two triangular matrices, one with zeros below and another with zeros above. They are exactly the ones Gauss leaves before clearing upward.
Lm = [1, 0; a21/a11, 1]
Um = [a11, a12; 0, a22 - a21*a12/a11]
#: That the split is correct is stated by the product itself: it rebuilds the whole of A.
LUm = Lm * Um
#: Inverting a triangular matrix is easy, because it is solved in a chain from top to bottom. Each one on its own:
iU = Um^-1
iL = Lm^-1
#: And the inverse of a product reverses the order of the factors: first you undo the last thing that was done.
inv6 = Um^-1 * Lm^-1
chk6 = (Um^-1 * Lm^-1) * A
#: The same factorisation allows distributing the pivot to the other side —that is Crout instead of Doolittle—, and the result does not change:
Lcr = [a11, 0; a21, a22 - a21*a12/a11]
Ucr = [1, a12/a11; 0, 1]
LUcr = Lcr * Ucr
inv6b = Ucr^-1 * Lcr^-1

## 7 · By blocks: the Schur complement
#: This is the path of large programs, and that of static condensation in the FEM: the matrix is split into blocks, the first is inverted and the **Schur complement** appears, which is what remains of the rest once what the first block already explains is discounted.
sc = a22 - a21*(1/a11)*a12
#: With it the inverse is assembled by blocks. Notice that the complement acts as a local determinant, and that only the corner block had to be inverted:
blk = [1/a11 + a12*a21/(a11*a11*sc), -a12/(a11*sc); -a21/(a11*sc), 1/sc]
chk7 = blk * A

## 8 · Diagonalising: inverting numbers instead of matrices
#: If the matrix is looked at in the direction of its **eigenvectors**, it stops mixing and only stretches. In that direction it is diagonal, and a diagonal is inverted by flipping each number. The eigenvalues come from setting to zero the determinant of A minus lambda times the identity:
lam = Despejar{ det(A - lambda*Id) = 0 @ lambda }
#: To travel the whole path with clean letters I use a symmetric matrix, whose eigenvectors are the two diagonals of the square:
Sm = [p, q; q, p]
Pm = [1, 1; 1, -1]
Dm = [p+q, 0; 0, p-q]
#: That the decomposition is correct is stated by the product: it rebuilds the starting matrix.
chkP = Pm * Dm * Pm^-1
#: The diagonal is inverted number by number: each stretch is undone by shrinking the same amount.
iDm = Dm^-1
#: And going back to the original basis the inverse remains, without having inverted any full matrix:
inv8 = Pm * Dm^-1 * Pm^-1
chk8 = Sm * (Pm * Dm^-1 * Pm^-1)

## 9 · When the matrix is orthogonal, the inverse is the transpose
#: There is a case where inverting costs nothing. If the columns are perpendicular to each other and of length one, the matrix only rotates, and undoing a rotation is rotating the other way: it is enough to transpose. A rotation by angle theta:
Rot = [cos(theta), -sin(theta); sin(theta), cos(theta)]
#: Multiplied by its transpose it gives the identity —and there is Pythagoras doing the work—:
chk9 = Rot * transpose(Rot)
#: The same with a permutation matrix, which only swaps rows:
Perm = [0, 1; 1, 0]
chk9b = Perm * transpose(Perm)

## 10 · QR: separating the rotation from the stretch (Gram-Schmidt)
#: If the matrix is not orthogonal, it can be split into one that is and a triangular one. The orthogonal one is inverted by transposing (free) and the triangular one by solving in a chain. The orthonormal directions of the symmetric matrix from before:
Qm = [1/sqrt(2), 1/sqrt(2); 1/sqrt(2), -1/sqrt(2)]
chk10 = Qm * transpose(Qm)
#: The triangular part is what remains when looking at the matrix from those directions:
Rm = transpose(Qm) * Sm
#: And the two together rebuild the matrix:
QRm = Qm * (transpose(Qm) * Sm)
#: The inverse, then, is the inverted triangular matrix times the transpose of the orthogonal one:
inv10 = (transpose(Qm)*Sm)^-1 * transpose(Qm)

## 11 · Cholesky: the square root of a symmetric matrix
#: When the matrix is symmetric and defines positive energy —the FEM stiffness matrix is one—, it is split into a triangular one times its own transpose. It is half an LU, and costs half.
Lch = [sqrt(p), 0; q/sqrt(p), sqrt(p - q*q/p)]
#: That it is the correct split is stated by the product, which rebuilds the symmetric matrix:
chk11 = Lch * transpose(Lch)
#: With the triangular matrix inverted, the inverse comes out without touching the full matrix:
iLch = Lch^-1
inv11 = transpose(Lch)^-1 * Lch^-1

## 12 · The Moore-Penrose pseudo-inverse
#: This is the **generalised** inverse: it exists even if the matrix is not square. It is built with the transpose times the matrix, inverted, times the transpose.
pinv = (transpose(A)*A)^-1 * transpose(A)
#: And when the matrix is square and invertible —as here—, the pseudo-inverse **is** the usual inverse: look at the result and compare it with Form 1.
chk12 = ((transpose(A)*A)^-1 * transpose(A)) * A

## 13 · Sherman-Morrison: inverting the change, not the matrix
#: If you already have an inverse and the matrix changes a little —one column for another, a support that is added—, there is no need to start over. Sherman-Morrison corrects the inverse you already had. The change, written as a column times a row:
uu = [u1; u2]
vv = [v1; v2]
Bsm = Id + uu*transpose(vv)
#: All the cost is in one scalar, this one here, which is the only thing that has to be divided:
den = 1 + transpose(vv)*uu
#: And the corrected inverse:
inv13 = Id - uu*transpose(vv) * (1/(1 + transpose(vv)*uu))
chk13 = Bsm * (Id - uu*transpose(vv) * (1/(1 + transpose(vv)*uu)))

## 14 · The Neumann series: the first one that approximates
#: The previous thirteen are exact. This one is not, and that is why it is the one used by iterative methods when the matrix is huge. If the matrix is the identity **perturbed** by something small, its inverse is written as a sum of powers of that perturbation.
Nm = [0, n12; n21, 0]
Bn = Id - Nm
#: The first three terms of the series:
sN = Id + Nm + Nm*Nm
#: And here you see exactly what is being left out: multiplying by the original matrix does not give the clean identity, but the identity minus the **cube** of the perturbation. That is the error of cutting the series:
chk14 = Bn * (Id + Nm + Nm*Nm)
#: That is why the series only works if the perturbation is small: otherwise, its powers grow instead of dying out. The same phenomenon with a single number: the blue curve is the exact value, and the other two are the series cut at one and at two terms.
#fplot(1/(1-x), 1+x, 1+x+x^2, [-0.9 0.9])
#: Near zero the three stick together and the series works. Towards one the exact one shoots up and the cut ones lag behind: there the approximation stops being valid.

## 15 · Newton-Schulz: the iteration that doubles the correct digits
#: The previous series gains one term per turn. Newton-Schulz gains **double** each time: it takes the approximate inverse you have and corrects it by multiplying it by two times the identity minus the matrix times it. Starting from the first term of the series:
X1 = 2*Id - Bn
X2 = X1 * (2*Id - Bn*X1)
#: Compare this remainder with that of the series: there the cube of the perturbation was left over, here the **fourth** power is. In one turn it has gained two.
chk15 = Bn * X2

## 16 · The cases where nothing has to be done
#: Three matrices are inverted by looking at them. A diagonal one, by flipping each number:
Dg = [d1, 0; 0, d2]
iDg = Dg^-1
#: A triangular one, by solving in a chain and without more zeros appearing than there already were:
Sup = [s1, s2; 0, s3]
iSup = Sup^-1
#: And one of a single number, which is the division of all time:
uno = [e1]
iuno = uno^-1

## 17 · When the inverse does not exist
#: If one row is the other multiplied by something, the matrix squashes the plane onto a line. Two distinct points end up at the same place, and from the destination it is no longer possible to know which one one came from. The determinant gives it away:
Asing = [a11, a12; k*a11, k*a12]
dSing = det(Asing)
#: Zero. And since that zero is in the denominator of all the exact forms, all fifteen fail at once. It is not the defect of one method: it is that the inverse **does not exist**.

## 18 · All the paths, the same matrix
#: Adjugate, rows, characteristic equation, chained traces, Cramer determinants, triangular factorisation, blocks, eigenvectors, transpose, QR, Cholesky, pseudo-inverse, rank-one correction, series and iteration. Fifteen procedures, a single answer. The subtraction of any two of them says so without argument:
dif12 = adj(A)*(1/det(A)) - E4*E3*E2*E1
dif13 = adj(A)*(1/det(A)) - (trace(A)*Id - A)*(1/det(A))
dif14 = adj(A)*(1/det(A)) - (A - trace(A)*Id)*(1/Fc)
dif16 = adj(A)*(1/det(A)) - Um^-1 * Lm^-1
dif17 = adj(A)*(1/det(A)) - blk
dif112 = adj(A)*(1/det(A)) - (transpose(A)*A)^-1 * transpose(A)
#: All zero. And the definition, which was the only thing that had to be satisfied from the start:
final = A * A^-1
