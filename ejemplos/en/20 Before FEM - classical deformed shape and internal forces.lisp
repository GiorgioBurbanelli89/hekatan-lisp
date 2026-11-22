# Before FEM: how the deformed shape and the internal forces were plotted (classical method)
#: We start here. Before finite elements, for a beam it was done in TWO steps —and in the **reverse order** of FEM—: first the INTERNAL FORCES (by equilibrium), then the DEFORMED SHAPE (by integrating). The engine reproduces it.

## 1 · The example: simply supported beam with uniform load
#: Length L=1, distributed load w=1, stiffness EI=1 (normalized). Each support takes half of the load: reaction R = w·L/2 = ½.

## 2 · First the INTERNAL FORCES, by EQUILIBRIUM (without knowing the deformed shape)
#: You cut the beam at a section x and apply equilibrium to the left piece:
#| · Cortante (suma de fuerzas):  V(x) = R − w·x = ½ − x
#| · Momento (suma de momentos):  M(x) = R·x − w·x²/2 = (x − x²)/2
V = 1/2 - x @@(cortante, del equilibrio)
M = (x - x^2)/2 @@(momento, del equilibrio)
#fplot(1/2-x, (x-x^2)/2, [0 1])
#: Those are the **shear and moment diagrams**. They were drawn DIRECTLY from equilibrium — without yet knowing the deformed shape. (The maximum moment at the center is wL²/8 = ⅛ = 0.125.)

## 3 · Then the DEFORMED SHAPE, by DOUBLE INTEGRATION
#: The beam law says EI·v'' = M (the curvature times the stiffness = the moment). With EI=1: v'' = M = (x−x²)/2. You integrate TWICE (the engine integrates):
vp = Integral{(x-x^2)/2 @ x} @@(v' = ∫ M dx)
v = Integral{x^2/4-x^3/6 @ x} @@(v = ∫ v' dx)
#: It gives x³/12 − x⁴/24 (plus the integration constants). The **boundary conditions** (v=0 at both supports) fix those constants, and the exact deformed shape remains:
v_final = (2*x^3 - x^4 - x)/24 @@(deformada exacta)
#fplot((2*x^3-x^4-x)/24, [0 1])
#: It is the real deformed shape (degree 4), here obtained by **integrating the moment**. It goes down (downward deflection), maximum at the center.

## 4 · The contrast with FEM: the ORDER is reversed!
#: Remember the chain:  load → shear V → moment M → curvature → rotation → deflection v.
#| · CLÁSICO (antes): equilibrio → ESFUERZOS (V, M) → integrar M/EI dos veces → DEFORMADA. Va de esfuerzo a deformada, **INTEGRANDO** (y necesita las condiciones de borde).
#| · FEM (hoy): rigidez → DESPLAZAMIENTOS (resolviendo K·u = F) → derivar → ESFUERZOS. Va de deformada a esfuerzo, **DERIVANDO**.
#: They run through the same chain in **opposite directions**. That is why FEM needs **interpolation**: to have a continuous function v(x) that can be differentiated. The classical method does not interpolate —it solves the exact equation—, but it only works for simple cases with a formula. That is the starting point from which FEM was born.
