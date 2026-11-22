# From the differential equation to the finite element: a bar, first in symbols and then with numbers
#: A bar fixed at the left, with distributed load q and a force P at the tip. It is solved **three times**: by hand with the differential equation, checking the weak form, and with finite elements. All three must give the same.

## 1 · The differential equation, in symbols (strong form)
#: A slice of width dx is cut. **Equilibrium:** on the left acts the axial force N, on the right N + dN, and inside the load q·dx, so dN + q·dx = 0, that is, **N′ = −q**.
#: **Kinematics:** the strain is the derivative of the displacement, ε = u′. **Constitutive (Hooke):** N = EA·ε = EA·u′.
#: Substituting leaves **a single equation with one unknown**, the strong form: **EA·u″ = −q**. It must be integrated twice, and each integral brings a constant.
#: Boundary conditions: **essential** u(0) = 0 (the support) and **natural** EA·u′(L) = P (the force at the tip).


## 2 · Solving it by hand, in symbols: integrate twice
#: First integral: EA·u′ = −q·x + C₁. Second: EA·u = −q·x²/2 + C₁·x + C₂.
#: The natural one at x = L gives −q·L + C₁ = P, that is, **C₁ = P + q·L**. The essential one at x = 0 gives **C₂ = 0**.
u(x) = (-q*x^2/2 + (P + q*L)*x)/EA @@(desplazamiento exacto)
N(x) = -q*x + P + q*L @@(fuerza axial N = EA·u′)
u_L = Simplify{u(L)} @@(desplazamiento de la punta)
N_0 = Simplify{N(0)} @@(fuerza axial en el apoyo)
N_L = Simplify{N(L)} @@(fuerza axial en la punta)

## 3 · The weak form, in symbols
#: The equation is multiplied by a function v(x) with v(0) = 0 and integrated by parts. It becomes: **∫EA·u′·v′ dx = ∫q·v dx + P·v(L)**, internal work = external work. It is checked with the exact solution, with two different functions v.
#: **With v = x** (v′ = 1):
Ti1 = Simplify{Integral{P + q*L - q*x @ x = 0 : L}}
Te1 = Simplify{Integral{q*x @ x = 0 : L} + P*L}
dif_1 = Simplify{Ti1 - Te1} @@(debe ser 0)
#: **With v = x²** (v′ = 2x):
Ti2 = Simplify{Integral{(P + q*L - q*x)*2*x @ x = 0 : L}}
Te2 = Simplify{Integral{q*x^2 @ x = 0 : L} + P*L^2}
dif_2 = Simplify{Ti2 - Te2} @@(debe ser 0)
#: With the exact solution the equality holds **for any v**: the weak form is not a different physics. Now a **poor** approximation, the line u = a·x, with the a that satisfies the equality only for v = x:
a_G = (q*L/2 + P)/EA @@(a de Galerkin)
d_G1 = Simplify{Integral{EA*a_G @ x = 0 : L} - (Integral{q*x @ x = 0 : L} + P*L)} @@(con v = x se cumple)
#: With v = x² it is **no longer** satisfied: the line is not the solution, it is only the best of its family.
d_G2 = Simplify{Integral{EA*a_G*2*x @ x = 0 : L} - (Integral{q*x^2 @ x = 0 : L} + P*L^2)}
#: That is why Galerkin demands the equality only for the v of the **same family** as the approximation. With more functions (more elements), the family grows and the approximation improves.

## 4 · Finite elements, in symbols: two elements
#: The bar is split into 2 segments of length h = L/2, with 3 nodes (0, 1, 2). In each segment the approximation is a **line** joining the values of its two nodes, with N₁ = 1 − x/h and N₂ = x/h.
h = L/2 @@(largo de cada elemento)
#: **Element stiffness matrix.** u′ = B·uₑ, with B = [−1/h, 1/h]. The stiffness is **kₑ = ∫EA·Bᵀ·B dx**; since B does not depend on x, the integrand is constant and the integral is h times it:
B_e = [-1/h, 1/h]
k = EA/h @@(rigidez del resorte equivalente)
k_e = [k, -k; -k, k] @@(k_e = EA·h·BᵀB = (EA/h)·[1, −1; −1, 1])
#: It is the spring matrix, with k = EA/h. The **element loads** come from ∫q·N dx: the distributed load is split in half between the two nodes.
f = q*h/2 @@(f_e = ∫q·N dx = [q·h/2; q·h/2])
f_e = [f; f]
#: **Assembly.** Node 1 belongs to both elements, so in its entry the two stiffnesses and the two loads are added. The force P goes to node 2.
K = [k, -k, 0; -k, 2*k, -k; 0, -k, k]
F = [f; 2*f; f + P]
#: **Support (essential condition).** u₀ = 0: row and column 0 are removed.
K_r = [2*k, -k; -k, k]
F_r = [2*f; f + P]
#: **Solve K·u = F**, still with letters. The determinant of K_r is k², and the inverse is (1/k²)·[k, k; k, 2k]:
u_r = Simplify{inv(K_r)*F_r}
u_1 = Simplify{(3*f + P)/k} @@(desplazamiento del nudo 1)
u_2 = Simplify{(4*f + 2*P)/k} @@(desplazamiento del nudo 2, la punta)
#: **Comparison in symbols.** At the nodes the finite element gives exactly the solution of the differential equation (a property of this constant-stiffness bar):
e_n1 = Simplify{u_1 - u(h)} @@(debe ser 0)
e_n2 = Simplify{u_2 - u(L)} @@(debe ser 0)
#: Inside the element the approximation is a line and the exact one a parabola. At mid-length of the first segment:
e_m = Simplify{u_1/2 - u(h/2)} @@(error a media barra, ≠ 0)
#: **Reaction at the support:** row 0 of K·u = F, with u₀ = 0, gives −k·u₁ = f + R:
R_0 = Simplify{-k*u_1 - f} @@(debe ser −(q·L + P))

## 5 · Substituting values
#: Only now the numbers. Same formulas, with the problem data:
L = 4 'length of the bar
EA = 10000 'axial stiffness (modulus times area)
q = 5 'distributed load along the bar
P = 10 'force at the tip (x = L)
#: **Exact solution** with the numbers (the differential equation):
Ca = P + q*L 'C₁ from the natural condition
u_Ln = u(L)
u_midn = u(L/2)
N_0n = N(0)
N_Ln = N(L)
#: **Weak form** with v = x and v = x², with numbers:
Ti1n = Integral{Ca - q*x @ x = 0 : L}
Te1n = Integral{q*x @ x = 0 : L} + P*L
dif_1n = Ti1n - Te1n 'must be 0
#: **Finite elements** with numbers:
hn = L/2
u_1n = u_1
u_2n = u_2
e_n1n = u_1 - u(h)
e_n2n = u_2 - u(L)
e_mn = u_1/2 - u(h/2)
e_m1n = u(L)/2 - u(L/2) 'with a single element the error at mid-bar is larger
R_0n = -k*u_1 - f 'reaction
R_espn = -(q*L + P) 'expected value

## 6 · Reading
#: **Strong → weak → element.** The differential equation was solved with constants fitted by the boundary conditions. The weak form gave the same answer as an equality of works for any v. The finite element uses it with v from the family of the shape functions, and everything reduces to **K·u = F**, with K assembled by adding springs.
#: **For the Q4 membrane** the skeleton is identical: kₑ = ∫EA·Bᵀ·B dx becomes **K = ∫Bᵀ·D·B·t dA**, with Gauss and the Jacobian. The rest (assemble, support, solve) is what you did here.
