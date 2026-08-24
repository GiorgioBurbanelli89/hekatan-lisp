# De las funciones de forma a la matriz de rigidez K
#: El eslabón que conecta todo. La matriz K del pórtico NO es un dato mágico: se COCINA de las funciones de forma. Aquí el motor la deduce integrando las curvaturas de las Hermite.

## 1 · La idea
#: La rigidez de un elemento de viga es la integral de la curvatura de cada función de forma por la de la otra, por la rigidez del material:  K = EI · ∫ (N'')ᵀ (N'') dx. Las N'' son las CURVATURAS de las funciones de forma. Así que las funciones de forma están DENTRO de la K.

## 2 · Las curvaturas de las Hermite (segunda derivada)
#: Derivo dos veces H₁ (el motor), para ver el proceso:
H1p = Diff{1-3*x^2+2*x^3 @ x} @@(H₁' pendiente)
H1pp = Diff{-6*x+6*x^2 @ x} @@(H₁'' curvatura)
#: Las cuatro curvaturas salen igual:  H₁''=−6+12x,  H₂''=−4+6x,  H₃''=6−12x,  H₄''=−2+6x.

## 3 · La rigidez = integral de los productos de curvaturas
#: Cada término de la matriz es la integral del producto de dos curvaturas (EI=1, L=1):
k11 = Area{(-6+12*x)^2 @ x=0:1} @@(H₁''·H₁'')
k12 = Area{(-6+12*x)*(-4+6*x) @ x=0:1} @@(H₁''·H₂'')
k13 = Area{(-6+12*x)*(6-12*x) @ x=0:1} @@(H₁''·H₃'')
k22 = Area{(-4+6*x)^2 @ x=0:1} @@(H₂''·H₂'')
#: Dan 12, 6, −12, 4. Repitiendo para todas las parejas sale la matriz de rigidez de la viga:
K_viga = [12, 6, -12, 6; 6, 4, -6, 2; -12, -6, 12, -6; 6, 2, -6, 4] @@(rigidez del elemento viga)

## 4 · Conexión con el pórtico
#: Esa K_viga (y la de columna, igual forma) es la que se ensambló en el pórtico del ejemplo anterior. Los números 12, 6, 4, 2 NO son mágicos: son las curvaturas de las Hermite integradas. Por eso el FEM ES con funciones de forma — están escondidas dentro de cada K de barra. El pórtico solo suma esas K en los nudos y resuelve.
