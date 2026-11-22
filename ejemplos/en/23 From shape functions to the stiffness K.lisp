# From shape functions to the stiffness matrix K
#: The link that connects everything. The frame's K matrix is NOT a magic datum: it is COOKED from the shape functions. Here the engine derives it by integrating the curvatures of the Hermite functions.

## 1 · The idea
#: The stiffness of a beam element is the integral of the curvature of each shape function times that of the other, times the material stiffness:  K = EI · ∫ (N'')ᵀ (N'') dx. The N'' are the CURVATURES of the shape functions. So the shape functions are INSIDE K.

## 2 · The curvatures of the Hermite functions (second derivative)
#: I differentiate H₁ twice (the engine), to show the process:
H1p = Diff{1-3*x^2+2*x^3 @ x} @@(H₁' pendiente)
H1pp = Diff{-6*x+6*x^2 @ x} @@(H₁'' curvatura)
#: The four curvatures come out the same way:  H₁''=−6+12x,  H₂''=−4+6x,  H₃''=6−12x,  H₄''=−2+6x.

## 3 · The stiffness = integral of the products of curvatures
#: Each term of the matrix is the integral of the product of two curvatures (EI=1, L=1):
k11 = Area{(-6+12*x)^2 @ x=0:1} @@(H₁''·H₁'')
k12 = Area{(-6+12*x)*(-4+6*x) @ x=0:1} @@(H₁''·H₂'')
k13 = Area{(-6+12*x)*(6-12*x) @ x=0:1} @@(H₁''·H₃'')
k22 = Area{(-4+6*x)^2 @ x=0:1} @@(H₂''·H₂'')
#: They give 12, 6, −12, 4. Repeating for all pairs yields the beam stiffness matrix:
K_viga = [12, 6, -12, 6; 6, 4, -6, 2; -12, -6, 12, -6; 6, 2, -6, 4] @@(rigidez del elemento viga)

## 4 · Connection with the frame
#: That K_beam (and the column one, same form) is the one assembled in the frame of the previous example. The numbers 12, 6, 4, 2 are NOT magic: they are the integrated curvatures of the Hermite functions. That is why the FEM IS shape functions — they are hidden inside each member K. The frame only adds those K at the nodes and solves.
