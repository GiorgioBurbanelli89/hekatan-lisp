# Ejemplo práctico: un VOLADIZO, resuelto CLÁSICO vs FEM
#: El mismo voladizo por los dos caminos. Clásico (resistencia de materiales, integrando) y FEM (matriz de rigidez). Al final se comparan: deben cerrar EXACTO.

## 1 · El problema
#: Voladizo empotrado en la izquierda (x=0), libre en la derecha (x=L), con carga P hacia abajo en la punta. Normalizamos: P=1, L=1, EI=1.

## 2 · Método CLÁSICO (doble integración)
#: Momento por equilibrio del trozo derecho:  M(x) = −P·(L−x) = x − 1  (máximo en el empotramiento, cero en la punta). La ley de la viga EI·v''=M; con EI=1, integro dos veces:
M = x - 1 @@(momento, del equilibrio)
vp = Integral{x-1 @ x} @@(v' = ∫ M dx ; con v'(0)=0)
v_clasico = Integral{x^2/2-x @ x} @@(v = ∫ v' dx ; con v(0)=0)
#: Da  v(x) = x³/6 − x²/2 = (x³−3x²)/6. La flecha en la punta:  v(1) = −1/3 = **−PL³/3EI** (el resultado clásico de libro).
#fplot((x^3-3*x^2)/6, [0 1])

## 3 · Método FEM (1 elemento de viga)
#: Un solo elemento. El nudo izquierdo está empotrado (v₁=0, θ₁=0), así que solo quedan 2 incógnitas: v₂ y θ₂ (punta). El bloque de rigidez de esos 2 GDL (de la matriz de viga EI/L³) es:
Kred = [12, -6; -6, 4] @@(rigidez reducida, v₂ y θ₂)
#: La carga: fuerza −P en v₂, momento 0 en θ₂. Resuelvo K·u = F invirtiendo:
Kinv = Kred^-1 @@(flexibilidad)
F = [-1; 0] @@(fuerza en la punta)
u = Kinv*F @@(u = [v₂ ; θ₂])
#: Da  v₂ = −1/3  y  θ₂ = −1/2  → la misma flecha −1/3 = −PL³/3EI, y el giro −PL²/2EI.
#: La deformada FEM = las Hermite con esos valores:  v(x) = H₃·v₂ + H₄·θ₂:
v_fem = Expand{(-1/3)*(3*x^2-2*x^3) + (-1/2)*(-x^2+x^3)} @@(deformada FEM)
#fplot(v_fem, [0 1])

## 4 · Comparación: coinciden EXACTO
#: El clásico dio (x³−3x²)/6 y el FEM dio lo mismo. Superpuestas (una tapa a la otra):
#fplot((x^3-3*x^2)/6, v_fem, [0 1])
#: **Cierran exacto.** ¿Por qué? Porque el voladizo NO tiene carga entre nudos (la carga está EN la punta, un nudo). Ahí la solución exacta es una cúbica, y la Hermite del FEM es esa cúbica → no aproxima, es EXACTA. En cambio, con carga repartida en el vano, el FEM (1 elemento) solo aproximaría, y habría que trocear en más elementos.
