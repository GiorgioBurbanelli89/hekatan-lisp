# La deformada de un frame — las funciones de Hermite (cómo se dibuja una viga deformada)
#: Un **frame** (viga-columna) no usa la recta del 1D simple. Para la **flexión** usa polinomios **cúbicos de Hermite**. Y esas mismas cúbicas son las que dibujan la **curva** de la viga deformada que ves en pantalla. El motor las deduce.

## 1 · ¿Por qué una cúbica? La impone la ecuación de la viga
#: Una viga que se carga se **dobla**. Y no se dobla en línea recta: toma una **curva suave**. ¿Qué curva, exactamente? Siempre la misma: una **cúbica** (un polinomio de grado 3). Aquí ves de dónde sale, paso a paso y con dibujos. Piensa en esta viga —empotrada a la izquierda, con una carga en la punta—:
#beam(fixed-free, P@1)
#: La ley de una viga en flexión es **EI·v⁗ = w** (w = la carga que lleva encima). Entre dos nudos, si la carga está aplicada EN los nudos, en el medio **no hay carga → v⁗ = 0**. Resolver esa ecuación es **integrar cuatro veces**. Y aquí está la clave: **cada integral sube el grado en uno**. Míralo, con la forma que va tomando la curva:
#: **Primera** integral: de cero sale una **constante** (el cortante V, igual en todo el tramo). Su gráfica es una línea plana:
V = Integral{0 @ x}
#fplot(1, [0 1])
#: **Segunda**: esa constante se integra en una **recta** (el momento M, que sube en línea):
M = Integral{c1 @ x}
#fplot(x, [0 1])
#: **Tercera**: la recta se integra en una **parábola** (el giro, o sea la pendiente de la viga):
pend = Integral{c1*x + c2 @ x}
#fplot(x^2, [0 1])
#: **Cuarta**: la parábola se integra en una **cúbica** (la deflexión: la curva que de verdad toma la viga al doblarse):
defl = Integral{c1*x^2/2 + c2*x + c3 @ x}
#fplot(x^3, [0 1])
#: El camino completo es **constante → recta → parábola → cúbica**. Partiste de cero y, en cuatro integrales, llegaste a un polinomio de grado 3 con cuatro constantes. Esa cúbica **no aproxima nada**: es la forma EXACTA de una viga sin carga entre nudos. Por eso el programa dibuja la deformada **real**, no dos rectas quebradas.

## 2 · Los grados de libertad de la flexión (2 nudos → 4)
#: Y esas cuatro constantes encajan justo con los grados de libertad del elemento. En cada extremo la viga tiene DOS cosas: el desplazamiento **v** y el giro **θ** (la pendiente). Dos nudos → **4 datos**: v₁, θ₁, v₂, θ₂. Por eso el polinomio necesita **4 términos** —la cúbica, con la misma estructura que salió de integrar la ecuación:
v(x) = c_1 + c_2*x + c_3*x^2 + c_4*x^3 @@(cúbica: 4 constantes = 4 GDL)
base = [1 x x^2 x^3] @@(la base cúbica)

## 3 · Nace C: evalúo v y su pendiente v′ en los 2 nudos
#: Todo simbólico, con el largo {L} como letra (no {L}=1). Las filas salen de evaluar el desplazamiento **v** y la pendiente **v′ = dv/dx** en x=0 y x={L}. En x=0 solo sobreviven las constantes; en x={L} aparecen las potencias de {L}:
#|  v(0)=c₁ → [1 0 0 0]   ·   v′(0)=c₂ → [0 1 0 0]
#|  v(L) → [1 L L² L³]   ·   v′(L) → [0 1 2L 3L²]
C = [1, 0, 0, 0; 0, 1, 0, 0; 1, L, L^2, L^3; 0, 1, 2*L, 3*L^2] @@(C: v y v′ en los 2 nudos)

## 4 · Cómo se invierte una matriz — el método en 2×2
#: Antes de invertir la C de 4×4, veamos el método completo en una 2×2 genérica, con TODAS las operaciones algebraicas a la vista. Para una matriz A2 con entradas a₁₁, a₁₂, a₂₁, a₂₂:
A2 = [a11, a12; a21, a22]
#: El **determinante** es el producto de la diagonal menos el de la otra (un escalar):
detA = det(A2)
#: La **adjunta** intercambia la diagonal y cambia el signo de la otra diagonal (una matriz):
adjA = adj(A2)
#: Y el **inverso** es la adjunta multiplicada por el escalar 1/det (matriz × escalar):
Ainv = adj(A2) * (1/det(A2))
#: Ahí están las tres operaciones: el determinante {detA} (productos y una resta), la adjunta (reordenar con signos), y el inverso = (1/det)·adjunta (escalar por matriz).

## 5 · Ese mismo método, aplicado a la C de 4×4
#: El motor aplica EXACTAMENTE eso a la C. El determinante, por expansión de cofactores, sale {L}⁴:
detC = det(C)
#: La adjunta —la transpuesta de la matriz de cofactores (cada cofactor es el determinante, con signo, de una submatriz 3×3)—:
adjC = adj(C)
#: Y el inverso es la adjunta por el escalar 1/{L}⁴; ahí aparecen las potencias de 1/{L}:
Cinv = adj(C) * (1/det(C)) @@(C⁻¹ = adj(C)/det(C))

## 6 · Las funciones de forma de Hermite: N = base · C⁻¹
N = base*Cinv
#: Da las Hermite escritas con el largo real {L}: H₁ = 1−3(x/L)²+2(x/L)³, H₂ = x−2x²/L+x³/L², H₃ = 3(x/L)²−2(x/L)³, H₄ = −x²/L+x³/L². Con {L}=1 se recuperan las clásicas.

## 7 · Las 4 cúbicas de Hermite, una por una
#: Cada columna de {N} es una función de forma, escrita con el largo real {L}. H₁ y H₃ pesan los **desplazamientos** (v₁, v₂); H₂ y H₄ los **giros** (θ₁, θ₂). Cada una vale 1 en su grado de libertad y 0 en los otros:
H1 = 1 - 3*x^2/L^2 + 2*x^3/L^3 @@(peso de v₁)
H2 = x - 2*x^2/L + x^3/L^2 @@(peso de θ₁)
H3 = 3*x^2/L^2 - 2*x^3/L^3 @@(peso de v₂)
H4 = -x^2/L + x^3/L^2 @@(peso de θ₂)

## 8 · La deformada: la viga curva
#: El programa resuelve la estructura y obtiene solo los valores en los **extremos**: v₁, θ₁, v₂, θ₂. La **curva** entre nudos es la combinación de las cuatro Hermite pesadas por esos valores:
#|  v(x) = H₁·v₁ + H₂·θ₁ + H₃·v₂ + H₄·θ₂
#: Esa curva suave —la cúbica de Hermite— es exactamente lo que dibuja el programa para la viga deformada. No son dos rectas entre nudos: es la cúbica.

## 9 · La matriz de rigidez de la viga K
#: Con las funciones de forma listas, la rigidez sale de la energía de flexión. La curvatura (la deformación por flexión) es la SEGUNDA derivada de la deflexión, B = d²N/dx². Primero la curvatura de cada Hermite:
d2H1 = Diff{Diff{H1 @ x} @ x}
d2H2 = Diff{Diff{H2 @ x} @ x}
d2H3 = Diff{Diff{H3 @ x} @ x}
d2H4 = Diff{Diff{H4 @ x} @ x}
#: El vector de deformación B reúne las cuatro curvaturas:
B = [d2H1, d2H2, d2H3, d2H4]
#: La operación K = ∫EI·Bᵀ·B dx tiene tres pasos algebraicos. **Primero**, la transpuesta de B: la columna Bᵀ (las mismas curvaturas, en vertical):
Bt = transpose(B)
#: **Segundo**, el producto Bᵀ·B: una matriz 4×4 donde cada término es el producto de dos curvaturas (Hᵢ''·Hⱼ''). Este es el núcleo algebraico de la rigidez:
P = Bt * B
#: **Tercero**, se escala por EI y se integra cada término de esa 4×4 de 0 a {L}. Al integrar esos polinomios desaparece la {x} y quedan solo {L} y EI:
K = Area{EI * transpose(B)*B @ x = 0:L}
#: Esa es la matriz de rigidez de viga CLÁSICA: 12EI/L³, 6EI/L², 4EI/L, 2EI/L… deducida símbolo a símbolo: transponer, multiplicar Bᵀ·B, integrar. Es la que ensamblan todos los programas de estructuras.

## 10 · ¿Desde cuándo se hace así?
#: · Las cúbicas de **Hermite** son matemática de ~1870 (interpolación con valor Y pendiente).
#: · La **matriz de rigidez de la viga** (con estas funciones) se formaliza en el **análisis matricial de estructuras de los años 1950**, y el método de rigidez directa hacia **1959**.
#: · **Dibujar la deformada** con estas funciones en el computador es estándar desde los **programas de los años 1970** (el linaje SAP, Berkeley), del que descienden los programas de hoy.
