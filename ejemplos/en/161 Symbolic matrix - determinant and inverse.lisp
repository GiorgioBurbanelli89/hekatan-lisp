# Symbolic matrix: determinant, adjugate and inverse
#: 2 × 2 matrix A with letters (no numbers).
A = [a, b; c, d]
#: Determinant of A: det(A) = a*d - b*c.
Da = Simplify{det(A)}
#: Adjugate of A: the transpose of the cofactor matrix, adj(A) = C^T.
Adj = Simplify{adj(A)}
#: Inverse of A: A^-1 = adj(A) / det(A), written inv(A).
Ai = Simplify{inv(A)}
