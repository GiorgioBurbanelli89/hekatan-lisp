# 1D shape functions — what they are and where they come from
#: Explained from scratch and **derived by the engine** (I don't hand them to you: they are computed). The equations carry their number on the right, as in the book.
#> Fuente: D. Logan, *A First Course in the Finite Element Method*, 6ª ed., §3.2 (elemento barra).

## 1 · The question they answer
#: You have a bar with two ends: **node 1** (at x=0) and **node 2** (at x=L). You know the displacement at each end: {u_1} and {u_2}. The question: what is the displacement **in the middle**, u(x)?
#: The **shape function** N_i is the **weight** with which node i contributes to each point. Interpolating = distributing the nodal values along the element.

## 2 · Logan's derivation, step by step
#: The displacement is assumed to vary **linearly** inside the bar:
u(x) = a_1 + a_2·x @@(Logan 3.2.1)
#: I evaluate it at the two nodes and solve for the constants a_1, a_2:
u(0) = u_1 = a_1 @@(Logan 3.2.3)
u(L) = u_2 = a_2·L + a_1 @@(Logan 3.2.4)
a_2 = (u_2 - u_1)/L @@(Logan 3.2.5)
#: I substitute a_1, a_2 into u(x) and **regroup by u_1 and u_2**. The engine does the algebra:
u = Expand{(1 - x/L)·u_1 + (x/L)·u_2} @@(Logan 3.2.6)
#: The weights multiplying each node **are** the shape functions:
N_1(x) = 1 - x/L @@(Logan 3.2.9)
N_2(x) = x/L @@(Logan 3.2.9)

## 3 · The 3 properties they ALWAYS satisfy (the engine checks them)
#: **(a) They equal 1 at their own node and 0 at the other** (Kronecker delta):
en_nudo1 = N_1(0) @@(N_1 en el nudo 1)
en_nudo2 = N_1(L) @@(N_1 en el nudo 2)
#: N_1 gives **1** and **0**; that is why each node controls its own value and does not disturb the other.
#: **(b) They sum to 1 at every point** (partition of unity):
particion = Simplify{N_1(x) + N_2(x)} @@(partición de la unidad)
#: Physical consequence: if both nodes have the same value (u_1=u_2=c), the element moves **rigidly** without deforming:
cuerpo_rigido = Expand{(1 - x/L)·5 + (x/L)·5} @@(u_1=u_2=5 → u=5)
#: It gives **5** (constant, no x). Without this property the element would fail the patch test.

## 4 · The natural coordinate ξ (the one you will use in 2D)
#: For 2D it is convenient to use a **master** element with ξ from −1 to +1 (node 1 at ξ=−1, node 2 at ξ=+1). The same functions, now derived by **Lagrange**: N_i = product of (ξ−ξ_j)/(ξ_i−ξ_j) over the other nodes. The engine extracts them:
N_1 = Expand{(xi - 1)/(-1 - 1)} @@(Lagrange, nudo ξ=−1)
N_2 = Expand{(xi + 1)/(1 + 1)} @@(Lagrange, nudo ξ=+1)
particion_nat = Simplify{(xi - 1)/(-1 - 1) + (xi + 1)/(1 + 1)} @@(también suman 1)

## 5 · The derivative dN/dξ → the strain
#: The strain is ε = du/dx. Since u = Σ N_i·u_i, ε depends on the **derivatives** of the N:
dN_1 = Slope{(1 - xi)/2 @ xi} @@(pendiente de N_1)
dN_2 = Slope{(1 + xi)/2 @ xi} @@(pendiente de N_2)
#: They give **−1/2** and **+1/2**: **constants**. That is why the linear bar has **constant** strain (and stress) throughout the element. In 2D this type is called CST.

## 6 · Plotted: the two straight lines
#fplot((1-xi)/2, (1+xi)/2, [-1 1])
#: N_1 drops from 1 to 0; N_2 rises from 0 to 1. They **cross at ξ=0**, where each one equals ½. That is the whole idea: each weight rules at its own node and vanishes at the other.

## 7 · With more nodes: the quadratic (3 nodes)
#: If you add a node in the middle (ξ = −1, 0, +1), Lagrange gives **parabolas**. The engine derives them:
M_1 = Expand{(xi - 0)·(xi - 1)/((-1 - 0)·(-1 - 1))} @@(esquina ξ=−1)
M_2 = Expand{(xi + 1)·(xi - 1)/((0 + 1)·(0 - 1))} @@(centro ξ=0)
M_3 = Expand{(xi + 1)·(xi - 0)/((1 + 1)·(1 - 0))} @@(esquina ξ=+1)
particion_cuad = Expand{(xi - 0)·(xi - 1)/2 + (xi + 1)·(xi - 1)/(-1) + (xi + 1)·(xi - 0)/2} @@(suman 1)
#fplot(xi·(xi-1)/2, 1-xi^2, xi·(xi+1)/2, [-1 1])
#: The middle one (M_2 = 1−ξ²) is a bell that equals 1 at the center; the corner ones equal 1 at their corner and 0 at the other two nodes.

## 8 · The bridge to 2D (what comes next)
#: In 2D the master element is a **square** with ξ, η ∈ [−1, 1]. The key: the 2D shape functions are the **product** of two 1D ones, one in each direction:
N(ξ,η) = N_a(ξ)·N_b(η) @@(producto tensorial)
#: Example, the corner (ξ=−1, η=−1):  N = (1−ξ)/2 · (1−η)/2 = ¼(1−ξ)(1−η). The 4 functions of the quadrilateral are these products. **That is why understanding 1D is understanding everything: 2D is 1D × 1D.**
#> Logan §3.2 · las mismas N valen en la barra, el resorte y (como producto) en el cuadrilátero.
