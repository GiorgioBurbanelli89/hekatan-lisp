# Pórtico plano: CLÁSICO vs FEM
#: Un pórtico de un vano, bases empotradas, con una carga lateral en la esquina superior. Lo resolvemos por rigidez (FEM = método matricial). El motor hace todo el álgebra.

## 1 · El problema
#: Dos columnas y una viga, todas de longitud 1 y rigidez EI=1 (normalizado). Bases empotradas. Carga lateral H=1 empujando la esquina superior izquierda. Así se ve sin deformar:
#frame(fixed-fixed, H)

## 2 · Los grados de libertad
#: Con las bases empotradas quedan 3 incógnitas: el giro de la esquina izquierda θ_B, el giro de la derecha θ_C, y el desplazamiento lateral Δ del nivel de la viga.

## 3 · La matriz de rigidez (ensamblada de las barras)
#: Cada barra aporta su rigidez a los nudos que comparte. La del giro es la rigidez a flexión; la del lado, la rigidez lateral; y hay un acople entre girar y desplazarse. Con EI=1 y L=1, las contribuciones de barra valen:
k_flexion = 4*EI/L @@(rigidez al giro)
k_transmite = 2*EI/L @@(transmite al otro extremo)
k_lateral = 12*EI/L^3 @@(rigidez lateral de columna)
k_acople = 6*EI/L^2 @@(acople giro–lado)
#: Ensamblando todas para los tres grados de libertad sale la matriz de rigidez del pórtico:
K = [8, 2, -6; 2, 8, -6; -6, -6, 24] @@(rigidez del pórtico)

## 4 · La carga y la solución (el motor resuelve K·u = F)
F = [0; 0; 1] @@(solo la carga lateral H en Δ)
Kinv = K^-1 @@(flexibilidad)
u = Kinv*F @@(u = [θ_B ; θ_C ; Δ])
#: Da θ_B = θ_C = 1/28 y Δ = 5/84. Los dos giros iguales (el pórtico es simétrico) y el desplazamiento lateral es el mayor: el pórtico se ladea. Con esos valores, la deformada (amplificada, punteado = sin deformar):
#framedef(5/84, 1/28, 1/28)

## 5 · Clásico vs FEM
#: El método CLÁSICO (pendiente-deflexión) plantea a mano las mismas 3 ecuaciones de equilibrio: momento en el nudo B, momento en el nudo C, y cortante del piso para el ladeo. Escritas en forma de matriz, esas 3 ecuaciones **son exactamente la K de arriba**. Por eso el FEM no es otro método: es la pendiente-deflexión puesta en matrices, que la computadora ensambla y resuelve sola. Mismo resultado, pero automático y para cualquier tamaño.
