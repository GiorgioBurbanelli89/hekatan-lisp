# Finite elements, for real: what the program does inside
#: One bar, five ideas: **shape function**, **Jacobian**, **B matrix**, **stiffness matrix K** and **displacements**. Everything is derived right here with the engine: first the algebra, the numbers at the end.
#> Hekatan Engineers · conferencia · Logan §3.2 · Zienkiewicz–Bathe (formulación isoparamétrica)

## 1 · The usual problem
#: A steel bar, fixed at the top and loaded at the bottom: modulus {E}, area {A}, length {L}, load {P}. The question of every structural calculation: **how much does it move and how much is it stressed?**
#: The classical strength-of-materials solution is a single formula:
d_exacta = P*L/(E*A) @@(alargamiento clásico)
#: Simple. But as soon as the bar changes section, material, or becomes a frame or a slab, that formula runs out. The finite element is the machine that solves **all** those cases with the same procedure. Let us see that procedure, step by step.

## 2 · The idea of the method in one sentence
#: **Divide the body into pieces and inside each piece assume a simple shape.**
#: Instead of looking for the exact function u(x) over the whole domain —hard—, the domain is split into **elements**, and inside each element we say: "the displacement is that of my nodes, distributed with some weights". Those weights are the **shape functions**.
#: This way the problem goes from "finding a function" to "finding a few numbers": the nodal displacements. And finding numbers is exactly what a computer knows how to do.

## 3 · The element: two nodes and a map
#: The bar element has two nodes. So that the program treats all elements the same —whether they measure 10 cm or 500 cm— each one is formulated on a **reference element** in natural coordinate {xi}, which always goes from −1 to +1:
#bar1d
#: Above, the reference element, always the same. Below, the real bar, from 0 to {L}. The arrow is the **map** that stretches one onto the other. The factor of that stretching is the Jacobian, and it will appear by itself in a moment.

## 4 · Shape functions: the question they answer
#: I know the displacement at the two ends, {u_1} and {u_2}. What is it **in the middle**?
#: The method's answer: it is distributed. Each node contributes with a **weight** that depends on where I am:
u_xi = N_1*u_1 + N_2*u_2 @@(interpolación)
#: N₁ is the weight of node 1 and N₂ that of node 2. That is all a shape function is: **a weight that varies with position**.

## 5 · Derivation, not memory (1): the line
#: Two nodes = two data = the simplest function joining them is a straight line. Written as a basis times coefficients:
N_i = [1, xi] * [a; b]
#: The basis [1, {xi}] is what depends on position; [{a}; {b}] are the two numbers I look for: the height at the center and the slope.
#recta

## 6 · Derivation, not memory (2): the Kronecker condition
#: The condition that defines the shape function: **it equals 1 at its node and 0 at the other**. Evaluating at a node is putting its {xi} into the basis.
e_1 = [1, -1] * [a; b] @@(en el nudo 1, ξ=−1)
e_2 = [1, 1] * [a; b] @@(en el nudo 2, ξ=+1)
#: For N₁ I ask {e_1} = 1 and {e_2} = 0. Stacking the two rows gives the system:
M = [1, -1; 1, 1] @@(matriz del sistema)
c_1 = inv(M) * [1; 0] @@(coeficientes de N₁)
c_2 = inv(M) * [0; 1] @@(coeficientes de N₂)
#: The engine solved the system: {c_1} and {c_2}. Rebuilding the line with those coefficients leaves the two shape functions in closed form:
N_1 = (1 - xi)/2 @@(función de forma del nudo 1)
N_2 = (1 + xi)/2 @@(función de forma del nudo 2)

## 7 · The two lines, drawn
#fplot(N_1 = (1-x)/2, N_2 = (1+x)/2, [-1 1])
#: N₁ (blue) goes down from 1 to 0; N₂ (orange) goes up from 0 to 1. They cross at the center, where both equal ½: at the middle of the element each node governs half.

## 8 · The three properties that never fail
#: **(a) Kronecker delta.** Each N equals 1 at its node and 0 at the other:
kro_1 = Expand{(1-(-1))/2} @@(N₁ en ξ=−1)
kro_2 = Expand{(1-1)/2} @@(N₁ en ξ=+1)
#: That is why each node controls its own value and does not contaminate its neighbor.
#: **(b) Partition of unity.** They add up to 1 at every point:
particion = Simplify{(1-xi)/2 + (1+xi)/2} @@(suman 1)
#: **(c) Rigid body motion.** If both nodes move the same, the element translates **without deforming**:
rigido = Expand{(1-xi)/2*5 + (1+xi)/2*5} @@(u₁=u₂=5 → u=5)
#: It gives 5, constant, with no {xi}. Without this property the element does not pass the patch test, and the program would invent forces when moving the whole structure.

## 9 · The interpolation in motion
#: Node 1 stays still and node 2 moves. See how the interior line follows the nodes: that is the shape function at work. Move the bar yourself: node 2 goes down and up whenever you want.
#slider fplot(u = (1+x)/2*n/8, u_maximo = (1+x)/2, [-1 1]), n = 0:8
#: Each position of the bar is a different {u_2}; the shape is **always** the same line, scaled. The N set the shape; the nodes set the size.

## 10 · The isoparametric map: from ξ to x
#: "Isoparametric" means: **the geometry is interpolated with the same shape functions as the displacement**. With node 1 at 0 and node 2 at {L}:
x = N_2 * L @@(mapeo de la geometría)
#: At {xi} = −1 it gives 0; at {xi} = +1 it gives {L}; at the center, half. It is a line:
#mapa1d

## 11 · The Jacobian: the slope of that map
#: The **Jacobian** is the derivative of the real coordinate with respect to the natural one: how many real centimeters I advance per step of {xi}.
Jac = Diff{x @ xi} @@(Jacobiano)
#: It comes out {Jac}, which from here on I call J. And it makes tailor's-tape sense: the reference element measures 2 (from −1 to +1) and the real one measures {L}; the ratio is {L}/2. **The Jacobian is the scale factor of the element.**
#: Its inverse is the one that carries the derivatives in the opposite direction:
J = L/2 @@(Jacobiano del elemento)
J_inv = 2/L @@(Jacobiano inverso)

## 12 · What the Jacobian is for (two uses, always the same)
#: **Use 1 — measuring.** A little piece of the real bar equals the natural little piece times the Jacobian:
dx = J*dxi @@(cambio de variable)
#: That is why every integral over the real element can be done over [−1, 1], which is where Gauss quadrature lives. That is the reason the program always integrates over the reference segment —or square—.
#: **Use 2 — differentiating.** The N are written in {xi}, but the strain is measured in x. The chain rule forces a division by the Jacobian:
dN_dx = dN_dxi * J_inv @@(regla de la cadena)
#: In 2D and 3D the Jacobian stops being a number and becomes a matrix, but the role is identical: **|J| to measure, J⁻¹ to differentiate**. If an element comes out very distorted, |J| approaches zero, J⁻¹ blows up, and that is where the mesh warnings of ETABS or SAP2000 are born.

## 13 · The B matrix: from displacements to strain
#: The axial strain is the derivative of the displacement, ε = du/dx. Differentiating the interpolation of step 4 and applying the chain rule:
dN_dxi = [-1/2, 1/2] @@(derivadas en la coordenada natural)
B = dN_dxi * J_inv @@(matriz deformación–desplazamiento)
#: That row is the **B matrix**. With it the strain comes from the nodal displacements with one multiplication, without differentiating anything else: ε = B · [{u_1}; {u_2}].
#: And look at what {B} says: the strain is (u₂ − u₁)/{L}, that is, **elongation divided by length**. The age-old definition, derived by itself.
#: A big detail: {B} **does not depend on {xi}**. The strain is **constant** inside the element. That is why the linear bar gives constant stress per element, and why in 2D the linear triangle is called CST, constant strain triangle.

## 14 · Integrating without integrating: quadrature
#: To assemble K an **integral** is needed. But a computer does not know how to integrate symbols: it knows how to **add and multiply**. So every integral is replaced by a sum:
#: **∫ f(ξ) dξ ≈ w₁·f(ξ₁) + w₂·f(ξ₂) + … + wₙ·f(ξₙ)** — I evaluate the function at a few points ξᵢ, multiply each value by a weight wᵢ, and add. That is a **quadrature**.
#: Read it as an area: each term wᵢ·f(ξᵢ) is a **rectangle** of width wᵢ and height f(ξᵢ). The sum of those rectangles is the area. Move the bars: **n** is the number of points, **p** is the degree of the polynomial I am integrating.
#gauss
#: Try this: leave n = 2 and raise the degree. Up to **p = 3** the error is ZERO —exact, not approximate—; at p = 4 it breaks away. Raise to n = 3 and it holds up to p = 5. That is the rule: **with n points it is exact up to degree 2n − 1.**

## 15 · Where does 0.5774 come from? (here is the key)
#: Trapezoid and Simpson evaluate at **fixed** points —the ends, the center—. Gauss asks something else: if I can choose **where** to evaluate, where is it best? With 2 points I have **4 free numbers**: ξ₁, ξ₂, w₁, w₂. With 4 freedoms I can demand 4 conditions: that the formula give the **exact** integral of 1, of ξ, of ξ² and of ξ³.
#: By symmetry the points come out at −a and +a with the same weight. The engine computes the exact integrals that must be matched:
I_0 = Area{1 @ xi=-1:1} @@(∫1 dξ)
I_1 = Area{xi @ xi=-1:1} @@(∫ξ dξ)
I_2 = Area{xi^2 @ xi=-1:1} @@(∫ξ² dξ)
#: With weights 1 and 1: for f = 1 the sum gives 1+1 = 2 = {I_0} ✔ (that is why the weights are 1). For f = ξ it gives −a+a = 0 = {I_1} ✔ (by symmetry, free). The only one that rules is **f = ξ²**: the sum is a² + a² = 2a², and it must give {I_2}. From there the point comes out:
a_gauss = dec(sqrt(1/3), 6) @@(2a² = 2/3 → a = 1/√3)
#: That 0.577 is not a magic number nor taken from a table: it is **the solution of an equation**. And the weights are 1 because they had to add to 2, which is what the interval measures.

## 16 · See it yourself: move the point
#: The two points are at −a and +a with weight 1. Drag and look at the four conditions: those of 1, ξ and ξ³ come out right **always** —because of the weights and the symmetry—; the one of **ξ²** only works out in one place.
#gauss(porque)
#: There, and only there, the error becomes zero: a = 1/√3 = 0.5774. With two evaluations you are integrating exactly up to degree 3.

## 17 · Gauss versus the trapezoid, with the same work
#: Two evaluations of the function, two methods. Let us integrate f(ξ) = ((1+ξ)/2)³ between −1 and 1. The exact answer, by the engine:
exacta = Area{((1+xi)/2)^3 @ xi=-1:1} @@(valor exacto)
#: **Trapezoid** (evaluates at the ends, ξ = −1 and ξ = +1, with weight 1 each):
trapecio = dec(((1-1)/2)^3 + ((1+1)/2)^3, 4) @@(f(−1) + f(+1))
#: **Gauss** (evaluates at ξ = ∓0.5774, weight 1 each):
gauss_2 = dec(((1-0.5773503)/2)^3 + ((1+0.5773503)/2)^3, 4) @@(f(−a) + f(+a))
#: Trapezoid gives 1.0 with a 100 % error; Gauss gives **exactly** 0.5. **The same number of operations, and one gets the digit right.** That is the whole reason ETABS, SAP2000, SAFE and Abaqus integrate with Gauss and not with trapezoids.
#: The points and weights for the segment [−1, 1] are always the same —they have been in a table since 1814—, and that is why **every element is formulated in natural coordinate**: so that table always holds, whatever the real element measures. The Jacobian takes care of the rest.

## 18 · Gauss inside the stiffness matrix
#: Now everything comes together. The element K is K = ∫ Bᵀ·D·B·|J| dξ, so the program does exactly this: for each **Gauss point** ξᵢ, it evaluates B(ξᵢ), multiplies Bᵀ·D·B, multiplies by |J| and by the weight wᵢ, and **accumulates** it:
K_gauss = w_1*Bt_D_B_1*J + w_2*Bt_D_B_2*J @@(K = Σ wᵢ·Bᵀ D B·|J|)
#: How many points are needed is decided with the 2n − 1 rule. In the linear bar BᵀB is **constant** (degree 0), so **with 1 point it is already exact**. In the Q4 quadrilateral the integrand reaches degree 2 and **2×2 = 4 points** are used; in the Q8, 3×3 = 9.
#: That is why programs talk about "full" or "reduced" integration: using fewer points than the rule asks makes the calculation cheaper, but can leave deformation modes with zero energy —*hourglassing*, that mesh that looks like an hourglass—.
#: And that is why, when you ask for stresses, ETABS or Abaqus calculate them **at the Gauss points** and then extrapolate them to the nodes: that is where the element really did the calculations.

## 19 · The stiffness matrix: where the integral comes from
#: The strain energy of the bar is ½∫σ·ε·{A}·dx. Putting in ε = B·u and σ = {E}·ε, everything that is not the displacements stays inside an integral: **that integral is K**.
#: K = ∫ Bᵀ·{E}·{A}·B dx over the real bar. I change to the natural coordinate with the Jacobian —use 1 of step 12—: K = ∫ Bᵀ·{E}·{A}·B·|J| dξ, with {xi} from −1 to +1. The engine does the integral:
BtB = Area{transpose(B)*B @ xi=-1:1} @@(∫BᵀB dξ)
K_elem = E*A*J*BtB @@(K = E·A·|J|·∫BᵀB dξ)
#: And there it is, **derived**, not copied: the stiffness of the bar element is (E·A/{L})·[1, −1; −1, 1]. The famous EA/L is not a table datum: it is the integral of the B matrix against itself.
#: Note the symmetry and that the rows add to zero. That last one is the rigid body of step 8 again: if you move both nodes the same, no force appears. A K that does **not** meet that is badly assembled.

## 20 · Now, the numbers
#: Steel bar, construction units: {E} in tonf/cm², {A} in cm², {L} in cm, {P} in tonf.
E_v = 2100 @@(módulo de elasticidad)
A_v = 20 @@(área de la sección)
L_v = 300 @@(largo)
P_v = 10 @@(carga axial)
#: Stiffness of the element and Jacobian of this bar:
J_v = dec(L_v/2, 1) @@(Jacobiano, cm por unidad de ξ)
k_ax = dec(E_v*A_v/L_v, 1) @@(E·A/L, tonf/cm)
K_num = k_ax*[1, -1; -1, 1] @@(K del elemento, tonf/cm)
#: Reading that matrix is easy: to move node 2 one centimeter, with node 1 still, 140 tonnes are needed. The diagonal says "how much it costs to move me"; the cross terms, "how much I drag my neighbor".

## 21 · Assembly: the structure is the sum of its elements
#: I split the bar into **two** elements of 150 cm. Each one is twice as stiff:
k_ax2 = dec(E_v*A_v/150, 1) @@(E·A/150, tonf/cm)
K_1 = k_ax2*[1, -1; -1, 1] @@(elemento 1: nudos 1–2)
K_2 = k_ax2*[1, -1; -1, 1] @@(elemento 2: nudos 2–3)
#: Node 2 is shared by the two elements, so there the stiffnesses **add**. Assembled, the complete 3-node structure:
K_g = [280, -280, 0; -280, 560, -280; 0, -280, 280] @@(K global, 3 nudos)
#: That is literally the whole assembly: taking each number of each element K to the row and column of the node it belongs to, and adding where they coincide. A 20-story frame is this same operation, repeated thousands of times.

## 22 · Boundary conditions and solution
#: Node 1 is fixed, {u_1} = 0. Its row and column are struck out —the program says "restrain the degree of freedom"— and a 2×2 system with the free nodes remains:
K_ff = [560, -280; -280, 280] @@(K de los grados libres)
F_f = [0; 10] @@(cargas: 0 en el nudo 2, P en el 3)
u_f = dec(inv(K_ff) * F_f, 4) @@(desplazamientos: u = K⁻¹·F)
#: The displacements are {u_f} cm: 0.0357 cm at the middle and **0.0714 cm at the tip**. And the classical formula of step 1 gave:
d_num = dec(P_v*L_v/(E_v*A_v), 4) @@(P·L/(E·A))
#: The same number. The method reproduced the exact solution.
#: That K⁻¹·F is the line that takes the bulk of the calculation time in ETABS, SAP2000 or Abaqus. Everything before —the N, the Jacobian, the B— exists only to be able to write that K.

## 23 · And with the displacements, everything else
#: With the displacements in hand we go back along the same path. In element 2, which goes from node 2 to 3:
u_e2 = [0.0357; 0.0714] @@(desplazamientos del elemento, cm)
B_num = dec([-1/150, 1/150], 6) @@(B del elemento, 1/cm)
eps = dec(B_num*u_e2, 6) @@(deformación ε = B·u)
sigma_e = dec(E_v*eps, 4) @@(tensión σ = E·ε, tonf/cm²)
N_axial = dec(sigma_e*A_v, 2) @@(fuerza axial N = σ·A, tonf)
#: It gives {N_axial} tonf: the 10 tonf applied. Equilibrium is satisfied, the result verifies itself. **Displacements → strains → stresses → forces**: that is the order in which every report of any finite element program comes out.

## 24 · And if the solution is not a line?
#: With a tip load the linear element is exactly right, because the solution **is** a line. With distributed load —self-weight— the exact solution is a parabola, and a line cannot be one. That is where meshing is needed. Normalized bar, exact against finite elements. Move the bar and refine the mesh yourself, from 1 to 8 elements:
#slider fplot(u = x - x^2/2, u_EF = floor(n*x)/n - (floor(n*x)/n)^2/2 + (1 - floor(n*x)/n - 1/(2*n))*(x - floor(n*x)/n), [0 0.999]), n = 1:8
#: At the nodes it matches **always**; between nodes there is error. The maximum error inside each span is:
e_u = h^2/8 @@(error entre nudos)
#: If you double the number of elements, {h} drops to half and the error drops to a **quarter**. That is converging, and it is the technical reason —not habit— for refining a mesh.

## 25 · The stress: why programs average it
#: The displacement comes out continuous, but the stress does not: each element gives its constant, so at an interior node there are **two** different values.
#slider fplot(sigma = 1 - x, sigma_EF = 1 - floor(n*x)/n - 1/(2*n), [0 0.999]), n = 1:8
#: That jump is the equilibrium that the method only satisfies at the nodes. That is why SAP2000, ETABS and SAFE let you choose "Unaveraged" —with the jump— or "Averaged". And the average of the two neighbors returns exactly the exact value at the node: averaging is not makeup, it is recovering information.

## 26 · The complete path, on one slide
#: **1. Shape functions** — spread the nodal values toward the inside of the element. They are derived by imposing that they equal 1 at their node and 0 at the others.
#: **2. Jacobian** — the scale factor between the reference element and the real one. |J| to measure (integrate), J⁻¹ to differentiate.
#: **3. B matrix** — the derivatives of the shape functions passed through J⁻¹. It converts nodal displacements into strain.
#: **4. Stiffness matrix K** — the integral ∫BᵀDB|J|dξ. For the bar it gives EA/L; for a slab it gives a full matrix, but it is the same formula.
#: **5. Displacements** — assemble, restrain, solve K·u = F, and go back along the path to strains, stresses and forces.
#: Change the element —bar, beam, shell, solid— and the N change, and the size of B and D changes. **The procedure never changes.** Once the bar is understood, the program is understood.
#> Hekatan Engineers · hoja ejecutable: todo lo anterior lo calculó el motor al abrir esta hoja.
