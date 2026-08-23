# La deformada de un frame — las funciones de Hermite (cómo se dibuja una viga deformada)
#: Un **frame** (viga-columna) no usa la recta del 1D simple. Para la **flexión** usa polinomios **cúbicos de Hermite**. Y esas mismas cúbicas son las que dibujan la **curva** de la viga deformada que ves en pantalla. El motor las deduce.

## 1 · Los grados de libertad de la flexión (2 nudos → 4)
#: En cada extremo la viga tiene DOS cosas: el desplazamiento **v** y el giro **θ** (la pendiente). Dos nudos → **4 datos**: v₁, θ₁, v₂, θ₂. Por eso el polinomio necesita **4 términos** → cúbica:
v(x) = c_1 + c_2*x + c_3*x^2 + c_4*x^3 @@(cúbica: 4 perillas)
base = [1 x x^2 x^3] @@(la base cúbica)
#: (Es cúbica y no lineal porque la ecuación de la viga EI·v'''' = 0 tiene solución cúbica — así la "aproximación" es **exacta** para la viga sin carga entre nudos.)

## 2 · Nace C: evalúo v y su pendiente v' en los 2 nudos
#: Con L=1. Las filas salen de evaluar el desplazamiento **v** y la pendiente **v' = dv/dx** en x=0 y x=1:
#|  v(0)=c₁ → [1 0 0 0]   ·   v'(0)=c₂ → [0 1 0 0]
#|  v(1)      → [1 1 1 1]   ·   v'(1)      → [0 1 2 3]
C = [1 0 0 0; 0 1 0 0; 1 1 1 1; 0 1 2 3] @@(C: v y v' en los 2 nudos)

## 3 · La inversa
Cinv = C^-1 @@(despeja las 4 perillas)

## 4 · Las funciones de forma de Hermite: N = base · C⁻¹
N = base*Cinv @@(las 4 cúbicas de Hermite)
#: Da  H₁=1−3x²+2x³ (para v₁),  H₂=x−2x²+x³ (para θ₁),  H₃=3x²−2x³ (para v₂),  H₄=−x²+x³ (para θ₂).

## 5 · VERLAS — las 4 cúbicas de Hermite
#: H₁ y H₃ mandan sobre los **desplazamientos**; H₂ y H₄ sobre los **giros**. Cada una vale 1 en su GDL y 0 en los otros:
H1 = 1-3*x^2+2*x^3 @@(peso de v₁)
H2 = x-2*x^2+x^3 @@(peso de θ₁)
H3 = 3*x^2-2*x^3 @@(peso de v₂)
H4 = -x^2+x^3 @@(peso de θ₂)
#fplot(H1, H2, H3, H4, [0 1])

## 6 · LA DEFORMADA: así se dibuja la viga curva
#: El programa resuelve la estructura y obtiene solo los valores en los **extremos** (v₁,θ₁,v₂,θ₂). Para dibujar la **curva** entre nudos, mezcla las Hermite:
#|  v(x) = H₁·v₁ + H₂·θ₁ + H₃·v₂ + H₄·θ₂
#: Ejemplo: extremo izquierdo fijo (v₁=0, θ₁=0), derecho baja 1 y gira 0.5 (v₂=1, θ₂=0.5). La deformada es:
deformada = 3*x^2-2*x^3 + 0.5*(-x^2+x^3) @@(v(x) con esos valores)
#fplot(deformada, [0 1])
#: Esa **curva suave** es exactamente lo que dibuja el programa para la viga deformada (amplificada por un factor, porque las deformaciones reales son diminutas). No son dos rectas entre nudos: es la cúbica de Hermite.

## 7 · ¿Desde cuándo se hace así?
#: · Las cúbicas de **Hermite** son matemática de ~1870 (interpolación con valor Y pendiente).
#: · La **matriz de rigidez de la viga** (con estas funciones) se formaliza en el **análisis matricial de estructuras de los años 1950**, y el método de rigidez directa hacia **1959**.
#: · **Dibujar la deformada** con estas funciones en el computador es estándar desde los **programas de los años 1970** (el linaje SAP, Berkeley), del que descienden los programas de hoy.
