# Finite elements in 1D, explained slowly
#: 1D only. Two cases: the **bar** that stretches (a straight line comes out) and the **beam** that bends (a cubic comes out). The engine derives everything, with its plots.

## 1 · The problem: the analysis gives POINTS, not a curve
#: Solving the structure (K·u = F) gives you ONLY numbers at the nodes: how much each one moved. Between the nodes you have nothing. To draw the shape in between —and above all to compute the physics inside— you have to **fill in** between nodes with a rule: that is **interpolation**. Let us look at the two 1D rules.

## 1.5 · What does interpolation APPROXIMATE? (the exact deformed shape)
#: Before interpolation we must see WHAT it approximates. Every structure has ONE **real and exact** deformed shape when loaded. Mathematically it is the **solution of the differential equation** of the problem (beam: EI·v''''=load, with its supports): a continuous function v(x), the true deformed shape.
#: **Before finite elements**, that solution was obtained with **calculus** (integrating the equation) → a **closed formula** (classical strength of materials). Example: simply supported beam with uniform load → exact deformed shape of degree 4. Normalized (L=1):
v_exacta = x^4 - 2*x^3 + x @@(deformada EXACTA — resistencia de materiales)
#fplot(x^4-2*x^3+x, [0 1])
#: With that **formula** the exact deformed shape was drawn. But the formula ONLY exists for simple cases. In a real structure (odd geometry, a thousand members) the equation is NOT solved by hand → there is no formula. **It is THAT exact deformed shape —the one you can no longer write— that interpolation approximates**, by chopping it up and using simple polynomials. (And in a beam with no load between nodes, the exact solution is a cubic → that is why the Hermite does not approximate there: it is EXACT.)

## 2 · The BAR (axial force): it stretches, it does NOT bend
### 2.1 · The field is a STRAIGHT LINE
#: A bar pulled at its ends stretches **evenly**: the displacement grows linearly from one end to the other. Two nodes → two data → a line:  u(x) = a + b·x.

### 2.2 · The engine derives the shape functions
#: Basis [1 x], evaluated at the 2 nodes (x=0 and x=1), invert, and N = basis·C⁻¹:
base1 = [1 x] @@(base lineal)
C1 = [1 0; 1 1] @@(base en los 2 nudos)
Ci1 = C1^-1 @@(despeja)
N1 = base1*Ci1 @@(N = [1−x, x])
#fplot(1-x, x, [0 1])
#: N₁ = 1−x goes down from 1 to 0; N₂ = x goes up from 0 to 1. Each one is 1 at its node and 0 at the other: they are the **weights** of each end.  u(x) = N₁·u₁ + N₂·u₂.

### 2.3 · Why the line is ENOUGH (it is exact)
#: The bar satisfies EA·u'' = 0 → u'' = 0. The exact solution IS a line, so the linear one **does not approximate: it is exact**. The axial **strain** is ε = du/dx, and on a line it is CONSTANT (it stretches the same over the whole length):
epsilon = Diff{a+b*x @ x} @@(ε = du/dx = b, constante)
#: Constant over the whole bar. That is why for the bar the line is sufficient.

## 3 · The BEAM (bending): it BENDS → more is needed
### 3.1 · What CURVATURE is (slowly)
#: Bend a ruler with your hands: it **arches**. The **curvature** measures how tight that arc is at each point. Straight = no arc = ZERO curvature; very tight arc = a lot of curvature (a circle of radius R has κ = 1/R).
#: **Why it is the 2nd derivative:** the 1st derivative v' is the **slope**; if the slope does not change, the beam goes straight; if it changes, it bends. Curvature = how much the slope changes = **v''**. The line has constant slope → zero curvature:
r_p = Diff{a+b*x @ x} @@(pendiente = b, constante)
r_k = Diff{b @ x} @@(curvatura = 0 → no se dobla)
#: **The physics:** what bends the beam is the bending moment M, and the beam law says **M = EI·v''** (the moment is proportional to the curvature). Where there is moment, there is curvature.

### 3.2 · Why the line does NOT work for the beam
#: A beam with moment has curvature ≠ 0, but a line has curvature 0. So the line cannot represent it. A polynomial that DOES have curvature is needed → raise the degree.

### 3.3 · The beam field: a CUBIC
#: The beam equation with no load in the span is EI·v'''' = 0; integrating 4 times gives a **cubic**. Also each end contributes 2 data: the displacement v and the rotation θ. Two nodes → 4 data → 4 terms → cubic. The engine derives its shape functions (Hermite) from the basis [1 x x² x³] evaluating v and v' at the 2 nodes:
base_h = [1 x x^2 x^3] @@(base cúbica)
C_h = [1 0 0 0; 0 1 0 0; 1 1 1 1; 0 1 2 3] @@(v y v' en los 2 nudos)
Ci_h = C_h^-1 @@(despeja)
N_h = base_h*Ci_h @@(las 4 cúbicas de Hermite)
#fplot(1-3*x^2+2*x^3, x-2*x^2+x^3, 3*x^2-2*x^3, -x^2+x^3, [0 1])
#: H₁=1−3x²+2x³, H₂=x−2x²+x³, H₃=3x²−2x³, H₄=−x²+x³ come out. The two with a peak (H₁,H₃) weight the **displacements**; the smooth ones (H₂,H₄) weight the **rotations**.

### 3.4 · The deformed shape of the beam
#: The program knows only the ends (v₁,θ₁,v₂,θ₂) and builds the curve by mixing the Hermite functions:  v(x) = H₁·v₁ + H₂·θ₁ + H₃·v₂ + H₄·θ₂. Example (left fixed, right goes down 1 and rotates 0.5):
deformada = 3*x^2-2*x^3 + 0.5*(-x^2+x^3) @@(v(x))
#fplot(deformada, [0 1])
#: That smooth curve is the real deformed shape (the one ETABS/SAP draw for beams and columns).

## 3.5 · Beam theory is a CHAIN (curvature is ONE link)
#: Curvature is not everything: it is the middle link. **Every derivative of the displacement is a physical quantity.** The engine gets them all, one after another, from the deformed shape v = 3x²−2x³:
v_giro = Diff{3*x^2-2*x^3 @ x} @@(giro θ = v')
v_curv = Diff{6*x-6*x^2 @ x} @@(curvatura v'' → momento M = EI·v'')
v_cort = Diff{6-12*x @ x} @@(cortante V = EI·v''')
v_carga = Diff{-12 @ x} @@(carga q = EI·v'''')
#: The chain reads:  **v** (deflection) → **v'** (rotation) → **v''** (curvature → moment) → **v'''** (shear) → **v''''** (load). Moment/curvature is the center; to one side the rotation and the deflection, to the other the shear and the load. Here the load gives 0: it is a beam with NO load in the span (that is why the cubic is exact).
#: And **apart from this chain**, the **Timoshenko** beam adds **shear** deformation — Euler-Bernoulli neglects it (it assumes sections rotate perpendicular to the axis). It matters in **short or deep** beams. That is the "something extra" outside the curvature.

## 3.6 · What is needed for EACH plot?
#: It is important not to confuse them:
#| · La DEFORMADA (la forma curva de la viga en el visor) → SOLO el desplazamiento:  v(x) = H₁·v₁ + H₂·θ₁ + H₃·v₂ + H₄·θ₂.  NO hace falta curvatura ni momento.
#| · El DIAGRAMA DE MOMENTO → M = EI·v'' (la curvatura, 2ª derivada).
#| · El DIAGRAMA DE CORTANTE → V = EI·v''' (3ª derivada).
#: That is: to **see the bent structure** it is enough to interpolate the displacement with the Hermite functions. Curvature and moment are for the **force diagrams**, which are OTHER plots. The deformed shape of §3.4 used only v(x): that is why it needed nothing from the chain.

## 3.7 · Why is each thing PAIRED with another?
#: Because **work = force × its displacement**. Each movement has ONE force that "works" with it, and that is why they go in pairs (they are dual):
#| · desplazamiento v ↔ fuerza F   (trabajo = F·v)
#| · giro (ángulo) θ ↔ momento M   (trabajo = M·θ)
#| · curvatura κ = v'' ↔ momento interno M = EI·κ   (energía de flexión = ½·∫ M·κ dx)
#: A rotation is NOT paired with a force (they would do no work together): it is paired with the **moment**. That is why at each beam node there are **2 degrees of freedom** (v and θ) with their **2 conjugate forces** (F and M), and the stiffness connects them:  the pair of forces (F, M) = K · (v, θ).
#: And the **angle has to be a node datum**: when two beams join there, they must share the SAME rotation so as not to form a kink (slope continuity, C¹). That is why the **beam carries the rotation** (2 DOF per node) and the **bar does not** (only v). That pairing is what builds the stiffness matrix.

## 3.8 · Why sometimes STRAIGHT (successive lines) and sometimes CURVED?
#: The viewer only knows the values at the NODES (v, θ). Between nodes it has TWO ways to draw the deformed shape:
#| 1) Unir los nudos con una RECTA (poligonal): rápido; cada barra = un segmento. Con muchos nudos → "successive lines".
#| 2) Usar las funciones de forma (Hermite, con los GIROS θ): dibuja la CURVA real dentro de cada barra.
#: The SAME bar (left node fixed, right goes down 1), drawn both ways:
recta = x @@(unir los nudos con recta)
curva = 3*x^2-2*x^3 @@(Hermite: la curva real)
#fplot(x, 3*x^2-2*x^3, [0 1])
#: The line only connects the ends; the curve also uses the **rotations** of the nodes → it shows the bending. That is why:
#| · Barra AXIAL (solo estira): la deformada real ES recta → recta y curva coinciden.
#| · Viga (flexión): la real es curva → si el visor solo une con rectas se ve angular; con Hermite se ve curva.
#: And if you chop a bar into MANY elements, the polyline of many little segments approaches the curve (like a polygon approaches a circle). Those are the "successive lines": many straight pieces that together approximate the curve. With a single beam element, the Hermite already gives you the exact curve without chopping.

## 4 · The FUNDAMENTAL reason (why interpolate, in 1D)
#: It is not just about drawing: the **strain** is the derivative of the displacement and the **stiffness** is an integral of that —  K = ∫ EA·(N')ᵀ(N') dx  in the bar,  K = ∫ EI·(N'')ᵀ(N'') dx  in the beam. To differentiate and integrate you need a continuous FUNCTION, not loose points. Interpolation gives you that function from the values at the nodes. **Without interpolation there is no strain, no stiffness → no FEM.**
