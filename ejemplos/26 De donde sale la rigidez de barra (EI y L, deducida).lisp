# De dónde sale la rigidez de una barra: EI y L, término a término
#: En los ejemplos anteriores apareció K_barra = (EI/L³)·[12, 6L, …]. Aquí se DEDUCE de cero: funciones de forma → curvaturas → integral, con EI y L en símbolos. Cada 12, 6L, 4L² sale de una cuenta. Todo con el motor.

## 1 · El principio: la rigidez es la integral de las curvaturas
#: Al doblar la barra se guarda energía de flexión, y esa energía va con el cuadrado de la CURVATURA (v''). De ahí, cada término de la rigidez es la curvatura de una función de forma por la de otra, integradas por la barra y por EI:  K_ij = EI·∫ N_i''·N_j'' dx. O sea: las funciones de forma, curvadas dos veces e integradas. Vamos a hacerlo.

## 2 · Las funciones de forma en coordenada s = x/L
#: Uso s = x/L, que va de 0 a 1. Son las 4 de Hermite (ejemplo 24). OJO: las de GIRO (N₂, N₄) llevan un factor L, porque multiplican a un giro θ y el peso de un giro tiene que dar una longitud:
N1 = 1 - 3*s^2 + 2*s^3 @@(peso de v₁)
N2 = L*(s - 2*s^2 + s^3) @@(peso de θ₁ — lleva L)
N3 = 3*s^2 - 2*s^3 @@(peso de v₂)
N4 = L*(-s^2 + s^3) @@(peso de θ₂ — lleva L)

## 3 · La curvatura de cada peso (segunda derivada)
#: Derivo cada función dos veces respecto a s. Salen lineales (curvatura de una cúbica):
N1s = Diff{1 - 3*s^2 + 2*s^3 @ s} @@(N₁' pendiente)
N1ss = Diff{-6*s + 6*s^2 @ s} @@(N₁'' = −6+12s)
N2s = Diff{L*s - 2*L*s^2 + L*s^3 @ s} @@(N₂' con L)
N2ss = Diff{L - 4*L*s + 3*L*s^2 @ s} @@(N₂'' = L(−4+6s))
N3ss = Diff{6*s - 6*s^2 @ s} @@(N₃'' = 6−12s)
N4ss = Diff{-2*L*s + 3*L*s^2 @ s} @@(N₄'' = L(−2+6s))

## 4 · El cambio de variable trae las potencias de L
#: Aquí nace el (EI/L³). Como s = x/L, derivar respecto a x mete un 1/L por cada derivada: dos derivadas → 1/L². Y al integrar en x el dx = L·ds aporta un L. Juntando: K_ij = EI·∫₀^L N_i''·N_j'' dx = (EI/L³)·∫₀¹ N_i(s)''·N_j(s)'' ds. El EI/L³ sale afuera; adentro quedan las curvaturas en s (con sus factores L de N₂, N₄).

## 5 · La integral: de dónde salen 12, 6L, 4L²
#: Cada término es la integral del producto de dos curvaturas, de 0 a 1. Los factores L de las funciones de giro quedan dentro y suben la potencia de L:
k11 = Area{(-6+12*s)^2 @ s=0:1} @@(v₁–v₁ → 12)
k12 = Area{(-6+12*s)*L*(-4+6*s) @ s=0:1} @@(v₁–θ₁ → 6L)
k13 = Area{(-6+12*s)*(6-12*s) @ s=0:1} @@(v₁–v₂ → −12)
k22 = Area{L*(-4+6*s)*L*(-4+6*s) @ s=0:1} @@(θ₁–θ₁ → 4L²)
k24 = Area{L*(-4+6*s)*L*(-2+6*s) @ s=0:1} @@(θ₁–θ₂ → 2L²)
#: Ni un solo factor L en v–v (queda 12), uno en v–θ (6L), dos en θ–θ (4L²). Junto el factor común (el del cambio de variable) y la matriz de las 16 integrales:
factorL = EI/L^3 @@(el factor común: EI/L³)
K_coef = [12, 6*L, -12, 6*L; 6*L, 4*L^2, -6*L, 2*L^2; -12, -6*L, 12, -6*L; 6*L, 2*L^2, -6*L, 4*L^2] @@(las 16 integrales ∫Ni''·Nj'' ds)
#: La rigidez de la barra es el factor por esa matriz: K_barra = factorL · K_coef = (EI/L³)·[12, 6L, …]. Es EXACTAMENTE la de los ejemplos 24 y 25; con EI=1 y L=1 da los [12, 6, −12, 6; …]. Cada número salió de una integral: el 12 de ∫(−6+12s)²; el 6L, la misma con un factor L; el 4L², con dos. Ahí queda deducida, término a término.
