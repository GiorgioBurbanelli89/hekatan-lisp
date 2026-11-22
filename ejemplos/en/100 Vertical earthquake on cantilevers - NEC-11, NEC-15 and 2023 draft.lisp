# Vertical earthquake on cantilevers — NEC-11, NEC-15 and NEC-SE-DS 2023 draft
#: The cantilever is rigid in the vertical direction: it is designed for a **reversible net vertical force** (upward and downward) that is a fraction of its weight. Each code writes it differently; here are the three with the course building (Portoviejo, soil D) and the cantilever weight measured by Hekatan Struct.

#numerico
## 1 · Data
Z = 0.5 @@(zona sísmica, Portoviejo)
Fa = 1.12 @@(suelo D, NEC-15 Tabla 3)
eta = 1.8 @@(η, Costa, NEC-15 §3.3.1)
I = 1 @@(importancia, otras estructuras)
Wp = 212.0 @@(peso del volado de un piso, kN — Hekatan Struct, capa NEC)

## 2 · NEC-11 §2.7.6.1, eq. (2-28)
#: **F_ver = ⅔·(Z·I·Fa)·Wp**. No η: the text (§2.7.6.2) says that the cantilever, being rigid, uses a **flat spectrum of value Z·Fa**.
c11 = 2/3*Z*I*Fa @@(coeficiente NEC-11)
F11 = c11*Wp @@(F_ver, kN, ± vertical)

## 3 · NEC-15 §3.4.4
#: **F_rev = ⅔·I·(η·Z·Fa)·Wp**. The NEC-15 spectrum plateau is η·Z·Fa: the NEC-15 does multiply by η.
c15 = 2/3*I*eta*Z*Fa @@(coeficiente NEC-15)
F15 = c15*Wp @@(F_rev, kN, ± vertical)

## 4 · NEC-SE-DS 2023 draft §3.4.2.4, eq. (3.9)
#: **F_rev = ⅔·Ie·(2.4·Z·Fa)·W_vol**: the draft plateau is 2.4·Z·Fa (with the draft's Fa values; here, for comparison, the same Fa).
c23 = 2/3*I*2.4*Z*Fa @@(coeficiente borrador)
F23 = c23*Wp @@(F_rev, kN, ± vertical)

## 5 · Comparison
r15 = F15/F11 @@(NEC-15 / NEC-11 = η)
r23 = F23/F11 @@(borrador / NEC-11 = 2.4)
#: The NEC-15 gives **η = 1.8 times** the NEC-11 and the draft **2.4 times**. In all three, moreover, the general vertical component is **Ev ≥ ⅔·Eh** (NEC-11 §2.7.7.3, NEC-15 §3.4.2, draft eq. 3.8). Hekatan Struct computes F_rev in the 🌎 NEC Earthquake panel with the chosen code and shows the NEC-11 value next to it.
