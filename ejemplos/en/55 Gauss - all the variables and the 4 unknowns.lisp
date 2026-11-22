# Gauss quadrature: all the variables, and the four unknowns
#: A separate sheet, for those who want to see the numbers inside: what each thing is worth at each point, where its rectangle is, and the system of four equations from which ξ and w come.
#> Hekatan Struct · anexo de la conferencia

## 1 · What there is at each Gauss point
#: Each point brings four numbers: **ξᵢ** (where), **wᵢ** (its weight = the width of its rectangle), **f(ξᵢ)** (the height) and **wᵢ·f(ξᵢ)** (what it contributes).
#gauss(vars)
#: The widths always add up to **2**: the whole interval.

## 2 · The four unknowns, one bar each
#: **4 unknowns** (ξ₁, ξ₂, w₁, w₂) → **4 conditions**:
c_1 = Area{1 @ xi=-1:1} @@(f = 1 → w₁ + w₂ debe dar 2)
c_2 = Area{xi @ xi=-1:1} @@(f = ξ → w₁ξ₁ + w₂ξ₂ debe dar 0)
c_3 = Area{xi^2 @ xi=-1:1} @@(f = ξ² → w₁ξ₁² + w₂ξ₂² debe dar 2/3)
c_4 = Area{xi^3 @ xi=-1:1} @@(f = ξ³ → w₁ξ₁³ + w₂ξ₂³ debe dar 0)
#: One bar per unknown. Set all four to OK at once:
#gauss(sistema)
#: Only solution: **ξ = ∓0.5774 · w = 1, 1**

## 3 · The solving, in case you want to see it by hand
#: By symmetry: w + w = 2 → **w = 1**; −a + a = 0 ✓; and the one that governs: **2a² = 2/3**
a_gauss = dec(sqrt(1/3), 6) @@(a = 1/√3)
#: Move the point: the error of ξ² vanishes only there.
#gauss(porque)

## 4 · The table the program uses
#: The numbers any program has hard-wired, for [−1, 1]:
puntos_1 = [0] @@(n = 1 · ξ)
pesos_1 = [2] @@(n = 1 · w)
puntos_2 = [-0.57735, 0.57735] @@(n = 2 · ξ)
pesos_2 = [1, 1] @@(n = 2 · w)
puntos_3 = [-0.774597, 0, 0.774597] @@(n = 3 · ξ)
pesos_3 = [0.555556, 0.888889, 0.555556] @@(n = 3 · w)
#: In 2D, the same combined: **2×2 = 4 points**, weight 1·1 = 1.
#> Hekatan Struct · anexo
