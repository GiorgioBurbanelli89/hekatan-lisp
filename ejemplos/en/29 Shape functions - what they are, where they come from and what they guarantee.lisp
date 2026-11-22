# Shape functions: what they are, where they come from and what they guarantee
#: Symbolic formulation of the two-node linear element. The shape functions are the heart of the finite element method: the recipe that distributes the nodal values through the interior of the element. Here they are derived from scratch, the complete procedure is shown (including the matrix inverse), and their three defining properties are verified symbolically.

## 1 · What a shape function is
#: In finite elements only the values at the nodes are known. The shape function is the interpolation that distributes those values inward: any field —geometry or displacement— is built as the sum of the nodal values, each weighted by its shape function. For the two-node linear element, a displacement {u} is interpolated with {N_1} and {N_2}:
u = [N_1, N_2] * [u1; u2]
#: That is {u} = {N_1}·{u1} + {N_2}·{u2}: at node 1 {N_1} dominates and at node 2 {N_2} dominates. The two shape functions are lines that equal 1 at their own node and 0 at the other. Plotted over {xi} ∈ [−1, 1]:
#fplot((1-x)/2, (1+x)/2, [-1 1])
#: This plot shows the two shape functions: {N_1} (blue) dominates near node 1 and fades out at node 2; {N_2} (orange) the other way around. Where one equals 1, the other equals 0; they cross at the center, where both equal 1/2.

## 2 · Where they come from: the derivation
#: With two nodes there are two degrees of freedom, so the simplest shape function is a line with two coefficients {a} and {b} to find, written as the basis [1, {xi}] times the coefficient vector:
N_i = [1, xi] * [a; b]
#: The coefficients are fixed with the Kronecker delta property: the function equals 1 at its node and 0 at the other. Evaluating the basis at each node gives two equations. Stacking the basis at {xi} = −1 (row 1) and at {xi} = +1 (row 2) gives the system matrix:
M = [1, -1; 1, 1]
#: The system is M·[{a}; {b}] = [1; 0] for node 1. To solve for the coefficients the INVERSE of M is needed. And here is the complete procedure, not just the result. The inverse of a 2×2 matrix is built in three steps: its determinant, its adjugate, and the quotient of one by the other. The determinant:
detM = det(M)
#: The general rule of the 2×2 inverse is {G_inv} = 1/det · adjugate, where the adjugate swaps the diagonal and changes the sign of the other. With that rule, the inverse of M is:
Minv = inv(M)
#: The coefficients of node 1 come from multiplying the inverse by the right-hand side [1; 0]:
c_1 = Minv * [1; 0]
#: And the shape function of node 1 is rebuilt with the basis times its coefficients. Repeating with the right-hand side [0; 1] gives that of node 2; both at once by multiplying the basis by the complete inverse:
N = [1, xi] * Minv
#: Factoring out 1/2, the two shape functions in closed form:
N_1 = (1-xi)/2; N_2 = (1+xi)/2

## 3 · Property 1 — Kronecker delta
#: The property that defines them: each shape function equals 1 at its node and 0 at the other. It is verified by evaluating {N_1} at the two nodes. Evaluating at {xi} = −1 is multiplying the basis [1, −1] by the coefficients of {N_1}; at {xi} = +1, the basis [1, +1]:
k1 = [1, -1] * c_1
k2 = [1, 1] * c_1
#: It gives {k1} at node 1 and {k2} at node 2: exactly 1 and 0. The shape function of node 1 «recognizes» its node and vanishes at the other. This is what makes the nodal values be, precisely, the values of the solution at the nodes.

## 4 · Property 2 — Partition of unity
#: The sum of all the shape functions equals 1 at any point of the element. It is checked by adding the two —multiplying the row [1, 1] by the vector [{N_1}; {N_2}]:
unidad = [1, 1] * [N_1; N_2]
#: The result is {unidad}, constant and equal to 1 for all {xi}. This property guarantees that the element can represent a rigid-body motion: if both nodes move by the same amount, {u1} = {u2}, the whole element translates equally, without deforming. Without it, the element would invent false strains.

## 5 · Property 3 — They reproduce linear fields
#: A linear element must reproduce EXACTLY any first-degree field. It is tested by interpolating a linear field of known slope: if at node 1 ({xi} = −1) the field equals −1 and at node 2 ({xi} = +1) it equals +1, the interpolation must return the line {xi}:
lineal = [N_1, N_2] * [-1; 1]
#: It gives {lineal}: the interpolation reconstructs the linear field without error. Together with the partition of unity (degree 0), this ensures that the element captures rigid-body motions and constant strain states without error —the minimum condition for the mesh to converge to the solution when refined.
