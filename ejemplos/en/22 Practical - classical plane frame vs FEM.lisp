# Plane frame: CLASSICAL vs FEM
#: A one-bay frame with lateral load, solved by BOTH routes: the classical by hand (portal method, approximate) and FEM (stiffness matrix, exact). At the end they are compared.

## 1 · The problem
#: Two columns and a beam, all of length 1 and stiffness EI=1. Fixed bases. Lateral load H=1 pushing the upper left corner. Undeformed:
#frame(fixed-fixed, H)

## 2 · CLASSICAL METHOD — portal method (by hand, approximate)
#: The classical method distributes the story shear among the columns and assumes an inflection point at mid-height of each one. The shear per column is half of the load:
Vcol = 1/2 @@(H repartido entre 2 columnas)
#: With the inflection at mid-height, the moment at the base is the shear times half the height:
M_portal = Vcol*(1/2) @@(momento en la base, aproximado)
#: It gives 1/4. It is APPROXIMATE: it assumes the inflection exactly at mid-height, which is not exact for fixed bases.

## 3 · FEM METHOD — stiffness (exact)
#: The degrees of freedom: rotation of the left corner θ_B, rotation of the right one θ_C, and sway Δ. Each member contributes its stiffness; assembled:
K = [8, 2, -6; 2, 8, -6; -6, -6, 24] @@(rigidez del pórtico)
F = [0; 0; 1] @@(carga lateral H en Δ)
Kinv = K^-1 @@(flexibilidad)
u = Kinv*F @@(u = [θ_B ; θ_C ; Δ])
#: It gives θ_B = θ_C = 1/28 and Δ = 5/84. The deformed shape (amplified, dotted = undeformed):
#framedef(5/84, 1/28, 1/28)
#: From the solution I take the column end moments (chord rotation ψ = Δ/h):
psi = 5/84 @@(giro de cuerda)
M_base = 2*(1/28 - 3*psi) @@(momento EXACTO en la base)
M_tope = 2*(2/28 - 3*psi) @@(momento EXACTO en el tope)
#: It gives M_base = −2/7 ≈ −0.286 and M_top = −3/14 ≈ −0.214.

## 4 · Comparison
#: At the base: the classical (portal) gave 0.25 and the exact FEM gave 0.286 — the hand method APPROXIMATES (it assumes the inflection at mid-height, which does not fall there). FEM gives the exact value and also the two different ends (0.286 and 0.214), because the column bends in double curvature. The more complex the frame, the worse the hand approximation and the more necessary FEM is.
#: And the EXACT classical method (slope-deflection) sets up by hand the same equilibrium equations that, in matrix form, are the K above: FEM is that slope-deflection automated.
