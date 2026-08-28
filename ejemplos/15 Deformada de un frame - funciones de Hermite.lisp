# La deformada de un frame — las funciones de Hermite (cómo se dibuja una viga deformada)
#: Un **frame** (viga-columna) no usa la recta del 1D simple. Para la **flexión** usa polinomios **cúbicos de Hermite**. Y esas mismas cúbicas son las que dibujan la **curva** de la viga deformada que ves en pantalla. El motor las deduce.

## 1 · ¿Por qué una cúbica? La impone la ecuación de la viga
#: No se elige la cúbica por capricho: la da la física. Una viga en flexión obedece la ecuación de Euler-Bernoulli, EI·v⁗ = w (la carga). ENTRE dos nudos no hay carga (w = 0), así que v⁗ = 0. Esa ecuación se resuelve integrando cuatro veces, y cada integral añade una constante. Primera integral —el cortante:
V = Integral{0 @ x}
#: Segunda —el momento (salvo EI):
M = Integral{c1 @ x}
#: Tercera —el giro (la pendiente v′):
pend = Integral{c1*x + c2 @ x}
#: Cuarta —la deflexión:
defl = Integral{c1*x^2/2 + c2*x + c3 @ x}
#: La deflexión {defl} es un polinomio de GRADO 3 —una cúbica con cuatro constantes—. Ese es el punto: la cúbica no aproxima nada, es la forma EXACTA de una viga descargada entre nudos. Por eso el FEM de viga reproduce la deformada real, no la parte en rectas.

## 2 · Los grados de libertad de la flexión (2 nudos → 4)
#: Y esas cuatro constantes encajan justo con los grados de libertad del elemento. En cada extremo la viga tiene DOS cosas: el desplazamiento **v** y el giro **θ** (la pendiente). Dos nudos → **4 datos**: v₁, θ₁, v₂, θ₂. Por eso el polinomio necesita **4 términos** —la cúbica, con la misma estructura que salió de integrar la ecuación:
v(x) = c_1 + c_2*x + c_3*x^2 + c_4*x^3 @@(cúbica: 4 constantes = 4 GDL)
base = [1 x x^2 x^3] @@(la base cúbica)

## 3 · Nace C: evalúo v y su pendiente v′ en los 2 nudos
#: Todo simbólico, con el largo {L} como letra (no {L}=1). Las filas salen de evaluar el desplazamiento **v** y la pendiente **v′ = dv/dx** en x=0 y x={L}. En x=0 solo sobreviven las constantes; en x={L} aparecen las potencias de {L}:
#|  v(0)=c₁ → [1 0 0 0]   ·   v′(0)=c₂ → [0 1 0 0]
#|  v(L) → [1 L L² L³]   ·   v′(L) → [0 1 2L 3L²]
C = [1, 0, 0, 0; 0, 1, 0, 0; 1, L, L^2, L^3; 0, 1, 2*L, 3*L^2] @@(C: v y v′ en los 2 nudos)

## 4 · La inversa — la operación paso a paso
#: Para despejar las cuatro constantes hace falta C⁻¹. El motor la calcula por la fórmula clásica: **C⁻¹ = adj(C) / det(C)**. Primero el determinante (por expansión de cofactores):
detC = det(C)
#: Sale {L}⁴. Luego la matriz **adjunta** —la transpuesta de la matriz de cofactores; cada cofactor es el determinante (con signo) de una submatriz 3×3—:
adjC = adj(C)
#: Y la inversa es la adjunta dividida por el determinante. Al dividir por {L}⁴ aparecen las potencias de 1/{L}:
Cinv = adj(C) * (1/det(C)) @@(C⁻¹ = adj(C)/det(C))

## 5 · Las funciones de forma de Hermite: N = base · C⁻¹
N = base*Cinv @@(las 4 cúbicas de Hermite, con L)
#: Da las Hermite escritas con el largo real {L}: H₁ = 1−3(x/L)²+2(x/L)³, H₂ = x−2x²/L+x³/L², H₃ = 3(x/L)²−2(x/L)³, H₄ = −x²/L+x³/L². Con {L}=1 se recuperan las clásicas.

## 6 · Las 4 cúbicas de Hermite, una por una
#: Cada columna de {N} es una función de forma, escrita con el largo real {L}. H₁ y H₃ pesan los **desplazamientos** (v₁, v₂); H₂ y H₄ los **giros** (θ₁, θ₂). Cada una vale 1 en su grado de libertad y 0 en los otros:
H1 = 1 - 3*x^2/L^2 + 2*x^3/L^3 @@(peso de v₁)
H2 = x - 2*x^2/L + x^3/L^2 @@(peso de θ₁)
H3 = 3*x^2/L^2 - 2*x^3/L^3 @@(peso de v₂)
H4 = -x^2/L + x^3/L^2 @@(peso de θ₂)

## 7 · La deformada: la viga curva
#: El programa resuelve la estructura y obtiene solo los valores en los **extremos**: v₁, θ₁, v₂, θ₂. La **curva** entre nudos es la combinación de las cuatro Hermite pesadas por esos valores:
#|  v(x) = H₁·v₁ + H₂·θ₁ + H₃·v₂ + H₄·θ₂
#: Esa curva suave —la cúbica de Hermite— es exactamente lo que dibuja el programa para la viga deformada. No son dos rectas entre nudos: es la cúbica.

## 8 · ¿Desde cuándo se hace así?
#: · Las cúbicas de **Hermite** son matemática de ~1870 (interpolación con valor Y pendiente).
#: · La **matriz de rigidez de la viga** (con estas funciones) se formaliza en el **análisis matricial de estructuras de los años 1950**, y el método de rigidez directa hacia **1959**.
#: · **Dibujar la deformada** con estas funciones en el computador es estándar desde los **programas de los años 1970** (el linaje SAP, Berkeley), del que descienden los programas de hoy.
