# Practical example: a CANTILEVER, solved CLASSIC vs FEM
#: The same cantilever by both routes. Classic (strength of materials, integrating) and FEM (stiffness matrix). At the end they are compared: they must match EXACTLY.

## 1 · The problem
#: Cantilever fixed at the left (x=0), free at the right (x=L), with load P downward at the tip. We normalize: P=1, L=1, EI=1. This is how the beam looks UNdeformed (support + load):
#beam(fixed-free, P@1)

## 2 · CLASSIC method (double integration)
#: The moment comes from the equilibrium of the right piece (maximum at the support, zero at the tip):
M = x - 1 @@(M = −P·(L−x))
#: The beam law: stiffness × curvature = moment. With EI=1, I integrate the moment twice (with v'(0)=0 and v(0)=0):
vp = Integral{x-1 @ x} @@(v' = ∫ M dx)
v_clasico = Integral{x^2/2-x @ x} @@(v = ∫ v' dx)
#: The deflection at the tip is −1/3 = −PL³/3EI (the classic textbook result). The deformed shape:
#fplot((x^3-3*x^2)/6, [0 1])

## 3 · FEM method (1 beam element)
#: A single element. The left node is fixed (v₁=0, θ₁=0), so only 2 unknowns remain: v₂ and θ₂ (tip). The stiffness block of those 2 DOF (from the beam matrix EI/L³) is:
Kred = [12, -6; -6, 4] @@(rigidez reducida, v₂ y θ₂)
#: The load: force −P at v₂, moment 0 at θ₂. I solve K·u = F by inverting:
Kinv = Kred^-1 @@(flexibilidad)
F = [-1; 0] @@(fuerza en la punta)
u = Kinv*F @@(u = [v₂ ; θ₂])
#: It gives  v₂ = −1/3  and  θ₂ = −1/2  → the same deflection −1/3 = −PL³/3EI, and the rotation −PL²/2EI.
#: The FEM deformed shape = the Hermite functions with those values:  v(x) = H₃·v₂ + H₄·θ₂:
v_fem = Expand{(-1/3)*(3*x^2-2*x^3) + (-1/2)*(-x^2+x^3)} @@(deformada FEM)
#fplot(v_fem, [0 1])

## 4 · Comparison: they match EXACTLY
#: The classic gave (x³−3x²)/6 and the FEM gave the same. Superimposed (one covers the other):
#fplot((x^3-3*x^2)/6, v_fem, [0 1])
#: **They match exactly.** Why? Because the cantilever has NO load between nodes (the load is AT the tip, a node). There the exact solution is a cubic, and the FEM Hermite is that cubic → it does not approximate, it is EXACT. In contrast, with a distributed load in the span, the FEM (1 element) would only approximate, and it would have to be chopped into more elements.
