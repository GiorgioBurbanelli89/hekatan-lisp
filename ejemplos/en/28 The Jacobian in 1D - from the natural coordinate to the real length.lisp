# The Jacobian in 1D: the isoparametric transformation of the linear element
#: Symbolic formulation of the two-node linear element. The goal is to define the Jacobian of the isoparametric transformation: the scalar that relates the natural coordinate to the physical coordinate of the element.

## 1 · The natural coordinate ξ and the reference element
#: In the finite element method each element of the physical domain is formulated on a reference element of fixed geometry, parametrized by the natural coordinate {xi}. For the two-node linear element, {xi} runs over the interval [−1, 1], following the standard isoparametric convention (Zienkiewicz, Bathe, Hughes).
#: The symmetric interval [−1, 1] is not arbitrary: it places the parametric origin at the center of the element and coincides with the integration domain of the Gauss–Legendre quadrature, with which the stiffness matrix is evaluated. The real geometry, of length {L}, is recovered through the isoparametric transformation, whose scale factor is the Jacobian. The reference element {xi} ∈ [−1, 1] and its image in the physical domain [0, {L}]:
#bar1d
#: This plot shows the same element seen in two ways: above, in natural coordinate {xi} (from −1 to +1, always the same, whatever the bar measures); below, on the real bar (from 0 to {L}). The arrow is the map that stretches the reference segment onto the physical bar.

## 2 · Derivation of the shape functions
#: The shape functions are not postulated from memory: they are derived. The element has two nodes, that is, two degrees of freedom, so the simplest function that interpolates them is a line: N = {a} + {b}·{xi}, with two numbers to determine, {a} and {b}.
#: Beware of a common misunderstanding: {a} and {b} are NOT points of the bar —that is the geometry, the one above—. They are the two numbers that define the line, just as in y = m·x + c: {a} is the intercept (the height of N at the center, {xi} = 0) and {b} is the slope (how much N changes per step of {xi}). For the shape function of node 1 they look like this:
#recta
#: This plot shows that the shape function is a line that drops from 1 (at its node) to 0 (at the other). The green point is {a}: the height of the line at the center ({xi} = 0). The amber triangle is {b}: the slope, how much the line drops when advancing 1 in {xi}. Neither {a} nor {b} are points of the bar; they are the height and the inclination of this line.
#: That same line is written as a product of the basis [1, {xi}] by the coefficient vector [{a}; {b}]. It is nothing new: the row·column product multiplies term by term and adds —one times {a}, plus {xi} times {b}—, which reproduces exactly the line {N_i}:
N_i = [1, xi] * [a; b]
#: That product is called the dot product. It is done in parts: the elements are paired in the same order, each pair is multiplied and they are added. In the drawing, each pair has a color —1 with {a} in blue, {xi} with {b} in coral—:
#punto
#: The same as engine operations. The first of the row (1) with the first of the column ({a}); the second of the row ({xi}) with the second of the column ({b}):
p_1 = 1*a
p_2 = xi*b
#: The first pair gives 1 times {a} = {a}; the second gives {xi} times {b}. The two pairs are added, and that sum is the complete line:
suma = 1*a + xi*b
#: That is {suma}. That is the whole dot product: pair, multiply each pair, add.
#: Why the detour? Because it SEPARATES two different things: the basis [1, {xi}] contains what depends on the position {xi}; the vector [{a}; {b}] contains the coefficients I am looking for. That separation makes the next step mechanical.
#: The coefficients are fixed with the Kronecker delta property: the shape function of a node equals unity at that node and vanishes at the other. Applying it is simple: evaluating the line at a node means plugging in the value of {xi} of that node. When doing so, only the basis changes —the coefficient vector [{a}; {b}] stays intact—.
#: Node 1 ({xi} = −1): plugging in {xi} = −1 the basis [1, {xi}] becomes [1, −1], so the shape function at that point is:
e_1 = [1, -1] * [a; b]
#: The vector [1, −1] is nothing new: it is the line with {xi} = −1, written short. Since {N_i} must equal 1 at node 1, the first equation is obtained: {e_1} = 1. Node 2 ({xi} = +1): the basis becomes [1, +1], and the function at that point is:
e_2 = [1, 1] * [a; b]
#: Since it must vanish at node 2, the second equation is {e_2} = 0. There are now two equations with two unknowns: {a} − {b} = 1 and {a} + {b} = 0. Stacking the two rows —each is the basis evaluated at a node— the system matrix is formed:
M = [1, -1; 1, 1]
#: The system is then M·[{a}; {b}] = [1; 0], where the right-hand side collects the nodal values of {N_1} (1 at node 1, 0 at node 2). It is solved by inverting the matrix:
c_1 = inv(M) * [1; 0]
#: The sought coefficients are {c_1}: {a} = 1/2 and {b} = −1/2. The shape function of node 1 is rebuilt by multiplying the basis by its coefficient vector:
N_1 = [1, xi] * c_1
#: Repeating with the right-hand side [0; 1] gives that of node 2. Both come from a single product, multiplying the basis by the complete inverse of the system:
N = [1, xi] * inv(M)
#: The result, factoring out 1/2, are the two linear shape functions in closed form:
N_1 = (1-xi)/2; N_2 = (1+xi)/2
#: Every interpolated field —geometry or displacement— is expressed as a linear combination of the shape functions weighted by the nodal values: {N_1} times the value at node 1 plus {N_2} times the value at node 2. Being first degree, the interpolation is exact for linear fields. Plotted over {xi} ∈ [−1, 1], each shape function is a line that passes through 1 at its node and 0 at the other; they cross at {xi} = 0, where both equal 1/2:
#fplot((1-x)/2, (1+x)/2, [-1 1])
#: This plot shows the two shape functions together: {N_1} (blue) drops from 1 to 0, {N_2} (orange) rises from 0 to 1. Each equals 1 at its own node and 0 at the other —the Kronecker delta property— and both cross at the center, where they equal 1/2. That they add up to 1 at every point guarantees that the interpolation reproduces any constant field.

## 3 · The isoparametric mapping: from ξ to the physical coordinate x
#: In the isoparametric formulation the geometry and the displacement field are interpolated with the same shape functions. The physical coordinate {x} is obtained by interpolating the nodal coordinates; with node 1 at the origin and node 2 at {L}, only the term associated with {N_2} survives:
x = N_2 * L
#: The values at the ends are checked: at {xi} = −1 node 1 is recovered ({x} = 0) and at {xi} = +1 node 2 ({x} = {L}). The transformation maps the reference element, of size 2, onto the physical domain of length {L}. The relation between the physical coordinate {x} and the natural one {xi} is a line; in a plot:
#mapa1d
#: This plot shows that the physical coordinate {x} grows in a straight line with the natural one {xi}: at {xi} = −1 it equals 0, at {xi} = +1 it equals {L}, and at the center {L}/2. That line IS the isoparametric map; its constant inclination is precisely the Jacobian that follows.

## 4 · The Jacobian of the transformation
#: The Jacobian of the isoparametric transformation is the derivative of the physical coordinate with respect to the natural coordinate: it measures the rate of change between both domains. For the linear element it is a scalar:
J = Diff{x @ xi}
#: The result is {J}, consistent with the ratio of sizes: the reference element measures 2 and the physical one {L}, so the Jacobian is the scale factor of the transformation. Its value governs the change of variable of every integral over the element, a requirement of Gauss quadrature integration.

## 5 · The inverse of the Jacobian and the strain matrix
#: The Jacobian intervenes in both directions. In the direct direction, a differential of the natural coordinate is carried to the physical domain scaled by {J} —the factor that accompanies numerical integration. In the inverse direction, the strain matrix B requires the derivatives of the shape functions with respect to the physical coordinate {x}; since these are defined in {xi}, the chain rule introduces the inverse Jacobian:
J_inv = 1/J
#: {J_inv} is obtained. With the Jacobian {J} and its inverse {J_inv} the operator that carries the derivatives between the reference and the physical domain is defined, the basis for assembling the strain matrix B and, from it, the element stiffness matrix.
