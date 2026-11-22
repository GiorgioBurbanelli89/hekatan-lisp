# Rectangular slab by finite elements — the BFS element
#: This is the same problem that `rectangular_slab_bfs.m` solves in Hekatan Lab: a simply supported rectangular slab with uniform load, meshed with the BFS (Bogner-Fox-Schmit) element of 16 degrees of freedom. Here the formulation is DEDUCED step by step. At the end it is marked, plainly, what this engine CANNOT do today.

## 1 · The data
a = 6 @@(dimensión en x, m)
b = 4 @@(dimensión en y, m)
t = 0.1 @@(espesor, m)
q = 10 @@(carga repartida, kN/m²)
E = 35000000 @@(módulo elástico, kN/m²)
nu = 0.15 @@(coeficiente de Poisson)

## 2 · The meshing
#: The slab is split into a grid of rectangular elements. Each element has four nodes, and each node FOUR degrees of freedom.
n_a = 6 @@(elementos en la dirección a)
n_b = 4 @@(elementos en la dirección b)
n_e = 6·4 @@(elementos en total)
n_j = 7·5 @@(nudos en total)
a_1 = 6/6 @@(ancho de un elemento, m)
b_1 = 4/4 @@(alto de un elemento, m)
#: And here is what distinguishes the BFS: four degrees per node, not three. The cross derivative is added.
n_dof = 4 @@(w, θx, θy y la torsión cruzada ∂²w/∂x∂y)
n_ke = 4·4 @@(grados por elemento: la K de un elemento es de 16 × 16)
n_g = 4·35 @@(grados totales del modelo)

## 3 · The plate bending stiffness
#: It comes from integrating the square of the arm through the thickness. It is the D of the shell chapter.
D_11 = 35000000·0.1^3/(12·(1 - 0.15^2))
#: And the bending constitutive matrix, with the Poisson ratio coupling the two directions and the shear in the corner.
D_b = [1, 0.15, 0; 0.15, 1, 0; 0, 0, (1-0.15)/2]

## 4 · The shape functions: the four Hermite
#: The BFS does not invent new functions. It uses the same four one-dimensional cubic Hermite functions, the ones we already derived with the coefficient matrix. Written on the span from 0 to 1:
P_1 = 1 - 3·x^2 + 2·x^3 @@(vale 1 donde el nudo baja)
P_2 = x - 2·x^2 + x^3 @@(vale 1 donde el nudo gira)
P_3 = 3·x^2 - 2·x^3 @@(la del otro nudo)
P_4 = -x^2 + x^3 @@(y su giro)
#: Check: at the left node the first one is one and the others zero. Substitute x = 0 and x = 1.

## 5 · The curvatures: differentiating TWICE
#: The plate bends, so what is needed is the second derivative of each Hermite function. The engine gets them:
C_1 = Diff{Diff{1 - 3·x^2 + 2·x^3 @ x} @ x}
C_2 = Diff{Diff{x - 2·x^2 + x^3 @ x} @ x}
C_3 = Diff{Diff{3·x^2 - 2·x^3 @ x} @ x}
C_4 = Diff{Diff{-x^2 + x^3 @ x} @ x}
#: These four curvatures are the ones that go inside the B matrix of the element.

## 6 · The 16 functions of the BFS: the product of two Hermite
#: And here is the idea of the element. Each of the sixteen shape functions is the PRODUCT of a Hermite in one direction by another Hermite in the other. Four by four, sixteen.
N_1 = (1 - 3·x^2 + 2·x^3)·(1 - 3·y^2 + 2·y^3) @@(la del nudo 1, en su grado w)
N_6 = (x - 2·x^2 + x^3)·(1 - 3·y^2 + 2·y^3) @@(otra: giro en x por flecha en y)
#: Just as the bilinear functions of four nodes are the product of two lines, those of the BFS are the product of two cubics. That is why the four degrees per node are needed: the fourth one closes the product.

## 7 · The three curvatures of the plate
#: From each shape function THREE curvatures come out, and each gives a moment. The first two are straight double derivatives; the third is the CROSS one.
K_11 = Partial{Partial{(1 - 3·x^2 + 2·x^3)·(1 - 3·y^2 + 2·y^3) @ x} @ x} @@(da el momento M11)
K_22 = Partial{Partial{(1 - 3·x^2 + 2·x^3)·(1 - 3·y^2 + 2·y^3) @ y} @ y} @@(da el momento M22)
K_12 = Partial{Partial{(1 - 3·x^2 + 2·x^3)·(1 - 3·y^2 + 2·y^3) @ x} @ y} @@(la cruzada: da el torsor M12)
#: Note the last one: it is differentiated ONCE with respect to each direction. That is the one that forces carrying the fourth degree of freedom at each node.

## 8 · The stiffness: the double integral
#: The element matrix is the double integral, in both directions, of the product of the curvatures by the constitutive matrix. One specific term, with the curvatures already substituted:
k_11 = Area{Area{(-6+12·x)^2·(1 - 3·y^2 + 2·y^3)^2 @ x=0:1} @ y=0:1}
k_12 = Area{Area{(-6+12·x)·(-4+6·x)·(1 - 3·y^2 + 2·y^3)^2 @ x=0:1} @ y=0:1}
#: Repeating that for the 16 × 16 pairs gives the element matrix. In the Hekatan Lab script that double integral is done with 4 × 4 Gauss quadrature: a loop inside another.

## 9 · The thickness check
#: And incidentally, where the twelve in the plate formula comes from. The square of the arm is summed through the thickness, from one face to the other, with the thickness in centimeters:
I_p = Area{z^2 @ z=-5:5}
chk = 10^3/12
#: The same number. The twelve is not a magic number: it is the result of that integral.

## 10 · WHAT THIS ENGINE CANNOT DO YET
#: The deduction goes this far, and it goes all the way: shape functions, curvatures, the constitutive matrix and the double integral, all symbolic and checked. What is missing to solve the COMPLETE slab as the Hekatan Lab script does is this, and it is worth having it written down:
#: 1 · There are no LOOPS. "For each element" or "for each Gauss point" cannot be written. The 16 × 16 terms have to be written by hand, one by one.
#: 2 · There is no ASSEMBLY. There is no way to add each element's matrix into a global matrix of 140 degrees, which is what this meshing requires.
#: 3 · A large system cannot be SOLVED nor can the supports of a whole boundary be applied.
#: 4 · There is no COLOR MAP. Hekatan Lab has `contourf` and draws the fields; here it does not exist, so the results cannot be painted.
#: With loops, assembly, solver and contourf, this same worksheet would solve the whole slab and draw M11, M22 and M12 without leaving the engine.
