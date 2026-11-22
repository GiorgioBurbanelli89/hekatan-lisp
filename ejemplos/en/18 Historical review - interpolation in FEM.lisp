# Historical review: interpolation in finite elements, era by era
#: First the PROBLEM (why interpolation is needed), and then the history: in each era, the engine DERIVES the formula that was used (how it is arrived at), plots it, and says what it corresponds to today.

## 0 · The problem: the analysis gives POINTS, not a curve
#: Solving the structure (K·u = F) gives you ONLY numbers at the nodes: how much each one moved. For example, a beam with the left end fixed and the right one going down 1:  v₁ = 0,  v₂ = 1 (plus their rotations). They are 2–4 **loose numbers**, NOT a function. Between the nodes you have NOTHING.

## 0.1 · The crudest: join the nodes with a straight line
#: Without any fine rule, the only thing you can do is join the nodes with a straight line:
#fplot(x, [0 1])

## 0.15 · What is the CURVATURE of a beam? (slowly)
#: Imagine you bend a ruler with your hands: it **arches**. The **curvature** measures **how tight that arc is** at each point of the beam.
#| Recta = sin arco → curvatura CERO.   ·   Arco muy cerrado = mucha curvatura.
#: In fact, a circle of radius R has curvature **κ = 1/R**: small radius → very tight curve → large curvature; infinite radius (a straight line) → zero curvature. The beam, when it bends, forms at each point a small arc, and κ measures that arc.
### Why is the curvature the SECOND derivative?
#: Think of it in two steps:
#| 1) La PRIMERA derivada v'(x) es la **pendiente**: cuán inclinada está la viga en ese punto.
#| 2) Si la pendiente NO cambia de un punto al otro → la viga va derecha (no se dobla). Si la pendiente CAMBIA → se está doblando.
#: The curvature is **how much the slope changes** = the derivative of the slope = the **second derivative** v''. The engine shows it. A **straight line**: its slope is constant, so its curvature gives zero:
r_p = Diff{x @ x} @@(pendiente = 1, constante)
r_k = Diff{1 @ x} @@(curvatura = 0 → NO se dobla)
#: Zero: a straight line has no curvature. The **cubic** does bend, because its slope changes:
c_p = Diff{3*x^2-2*x^3 @ x} @@(pendiente = 6x−6x², cambia)
c_k = Diff{6*x-6*x^2 @ x} @@(curvatura = 6−12x, distinta de cero)
### The physics: what produces the curvature
#: What bends the beam is the **bending moment M**. The beam law says  **M = EI·v''**: the moment is proportional to the curvature, and EI is how stiff it is (E = material, I = section shape). Where there is moment there is curvature; where there is none, the beam is straight.
#: The curvature of the cubic is 6 − 12x: it changes sign at x = ½, that is the beam bends to one side and then to the other (an **S** shape). Drawn:
#fplot(6-12*x, [0 1])

## 0.2 · That is why the real beam is NOT straight
#: Since the straight line has ZERO curvature and the real beam has curvature, the crude line is wrong throughout the middle. Compare the line with the real shape (the cubic):
#fplot(x, 3*x^2-2*x^3, [0 1])
#: That is why **joining points is not enough**: a fill rule that respects the physics (the curvature) is needed.

## 0.3 · The UNDERLYING reason: the physics lives INSIDE the element
#: It is not just drawing. The **strain** is the DERIVATIVE of the displacement (ε = du/dx) and the **stiffness** is an INTEGRAL (K = ∫ Bᵀ·D·B dx). To differentiate and integrate you need a **continuous function**, not points. Example: from the interpolated deformed shape I get the strain by differentiating:
u_int = 3*x^2-2*x^3 @@(desplazamiento interpolado)
deformacion = Diff{u_int @ x} @@(ε = du/dx)
#: It gives 6·x − 6·x². **Without interpolation there is no strain, no stiffness → no FEM.** Everything that follows is how interpolation was arrived at.

## ~1795 · Lagrange — polynomial interpolation
#: The seed: passing a curve through given points. With 3 nodes (0, ½, 1) and only the middle one with value 1, the interpolant is the Lagrange basis polynomial of that node:  ℓ = (x−0)(x−1) / ((½−0)(½−1)). The denominator is −¼, so ℓ = −4·x·(x−1). The engine expands it:
lagrange = Expand{-4*x*(x-1)} @@(polinomio por 3 puntos)
#fplot(4*x-4*x^2, [0 1])
#: It gives **4x − 4x²**. The idea that changed everything: reconstructing a function from the value at a few points → the "weights" per node are born.

## 1909 · Ritz — trial functions + energy
#: The leap: do NOT solve the exact equation, but propose simple functions with knobs and adjust them by minimising the energy. A real curve approximated by a polynomial:
#fplot(sin(3.14159*x), 4*x-4*x^2, [0 1])
#: They almost coincide. "Solving" was replaced by "approximating with parameters".

## 1943 · Courant — piecewise linear (the "element" is born)
#: Divide the domain into pieces and use a straight line in each one. It coincides at the nodes but makes kinks (peak at ½):
#fplot(1-abs(2*x-1), [0 1])
#: Continuous in value (C⁰). Here the "element" is born: a piece with its simple function.

## 1956 · Turner and Clough (Boeing) — the FIRST element: linear triangle
#: The delta wing (2D plate) forced it. 3-node triangle, linear field u = a + b·x + c·y. The engine derives its shape functions:
base_t = [1 x y] @@(base lineal)
C_t = [1 0 0; 1 1 0; 1 0 1] @@(base en los 3 nudos)
Ci_t = C_t^-1 @@(despeja los coeficientes)
N_t = base_t*Ci_t @@(N = [1−x−y, x, y])
#map(1-x-y, [0 1], [0 1])
#: They are **planes** (constant strain, CST). → **It was the birth of the finite element method.**

## 1950s–60s · the beam: Hermite cubics
#: Bending demands continuous slope (C¹): 2 data per node (v and θ). The engine derives the 4 cubics from the basis [1 x x² x³] by evaluating v and v' at the 2 nodes:
base_h = [1 x x^2 x^3] @@(base cúbica)
C_h = [1 0 0 0; 0 1 0 0; 1 1 1 1; 0 1 2 3] @@(v y v' en los 2 nudos)
Ci_h = C_h^-1 @@(despeja)
N_h = base_h*Ci_h @@(las 4 cúbicas de Hermite)
#fplot(1-3*x^2+2*x^3, x-2*x^2+x^3, 3*x^2-2*x^3, -x^2+x^3, [0 1])
#: → **This is the shape that ETABS / SAP2000 use to draw the curved deformed shape of beams and columns (frames).**

## 1963 · Melosh — the bilinear quadrilateral and the C matrix
#: For plates, a 4-node square. Bilinear polynomial u = c₁+c₂x+c₃y+c₄·x·y. The engine derives the 4 "tents":
base_b = [1 x y x*y] @@(base bilineal)
C_b = [1 0 0 0; 1 1 0 0; 1 1 1 1; 1 0 1 0] @@(base en las 4 esquinas)
Ci_b = C_b^-1 @@(despeja)
N_b = base_b*Ci_b @@(las 4 funciones de forma)
#surf((1-x)*(1-y), [0 1], [0 1])
#: They come out (1−x)(1−y), x(1−y), x·y, y(1−x). → It is what programs use for **plates and shells**.

## ~1968 · Irons — the isoparametric (the modern one)
#: Write the N **directly** in natural coordinates ξ,η as a PRODUCT of two 1D ones: N = ¼(1−ξ)(1−η). The engine expands it:
iso = Expand{0.25*(1-x)*(1-y)} @@(N₁ isoparamétrica)
#surf(0.25*(1-x)*(1-y), [-1 1], [-1 1])
#: Without going through C. → **It is the form used by almost all programs today** (ETABS, SAP2000, SAFE, Abaqus…).

## In one line
#: Lagrange (interpolate) → Ritz (approximate) → Courant (piecewise) → **Turner/Clough 1956** (the triangle: FEM is born) → Hermite (beams: the ETABS deformed shape) → Melosh (plates, the C) → Irons (isoparametric: the modern one).
