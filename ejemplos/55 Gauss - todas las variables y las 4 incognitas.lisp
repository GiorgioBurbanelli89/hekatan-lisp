# Cuadratura de Gauss: todas las variables, y las cuatro incógnitas
#: Hoja aparte, para el que quiera ver los números por dentro: qué vale cada cosa en cada punto, dónde está su rectángulo, y el sistema de cuatro ecuaciones del que salen ξ y w.
#> Hekatan Struct · anexo de la conferencia

## 1 · Qué hay en cada punto de Gauss
#: Cada punto trae cuatro números: **ξᵢ** (dónde), **wᵢ** (su peso = el ancho de su rectángulo), **f(ξᵢ)** (la altura) y **wᵢ·f(ξᵢ)** (lo que aporta).
#gauss(vars)
#: Los anchos siempre suman **2**: el intervalo entero.

## 2 · Las cuatro incógnitas, una barra cada una
#: **4 incógnitas** (ξ₁, ξ₂, w₁, w₂) → **4 condiciones**:
c_1 = Area{1 @ xi=-1:1} @@(f = 1 → w₁ + w₂ debe dar 2)
c_2 = Area{xi @ xi=-1:1} @@(f = ξ → w₁ξ₁ + w₂ξ₂ debe dar 0)
c_3 = Area{xi^2 @ xi=-1:1} @@(f = ξ² → w₁ξ₁² + w₂ξ₂² debe dar 2/3)
c_4 = Area{xi^3 @ xi=-1:1} @@(f = ξ³ → w₁ξ₁³ + w₂ξ₂³ debe dar 0)
#: Una barra por incógnita. Ponlas las cuatro en OK a la vez:
#gauss(sistema)
#: Única solución: **ξ = ∓0.5774 · w = 1, 1**

## 3 · El despeje, por si quieres verlo a mano
#: Por simetría: w + w = 2 → **w = 1**; −a + a = 0 ✓; y la que manda: **2a² = 2/3**
a_gauss = dec(sqrt(1/3), 6) @@(a = 1/√3)
#: Mueve el punto: el error de ξ² solo se anula ahí.
#gauss(porque)

## 4 · La tabla que usa el programa
#: Los números que trae cableados cualquier programa, para [−1, 1]:
puntos_1 = [0] @@(n = 1 · ξ)
pesos_1 = [2] @@(n = 1 · w)
puntos_2 = [-0.57735, 0.57735] @@(n = 2 · ξ)
pesos_2 = [1, 1] @@(n = 2 · w)
puntos_3 = [-0.774597, 0, 0.774597] @@(n = 3 · ξ)
pesos_3 = [0.555556, 0.888889, 0.555556] @@(n = 3 · w)
#: En 2D, los mismos combinados: **2×2 = 4 puntos**, peso 1·1 = 1.
#> Hekatan Struct · anexo
