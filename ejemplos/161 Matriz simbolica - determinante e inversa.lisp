# Matriz simbólica: determinante, adjunta e inversa
#: Matriz A de 2 × 2 con letras (sin números).
A = [a, b; c, d]
#: Determinante de A: det(A) = a*d - b*c.
Da = Simplify{det(A)}
#: Adjunta de A: la traspuesta de la matriz de cofactores, adj(A) = C^T.
Adj = Simplify{adj(A)}
#: Inversa de A: A^-1 = adj(A) / det(A), y se escribe inv(A).
Ai = Simplify{inv(A)}
