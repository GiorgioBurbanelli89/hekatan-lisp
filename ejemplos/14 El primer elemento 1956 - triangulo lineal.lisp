# El primer elemento (1956): el triángulo lineal — deducido por el motor
#: Aquí empezó todo. **1956, Boeing**: Turner y Clough trocearon el ala en **triángulos** y dentro de cada uno supusieron un desplazamiento **lineal**. Ese fue el primer uso de polinomios en elementos finitos. El motor lo deduce y lo grafica.

## 1 · El polinomio: LINEAL (3 nudos → 3 términos)
#: Un triángulo tiene 3 esquinas → 3 perillas. El polinomio más simple es un plano:
u(x,y) = a + b*x + c*y @@(plano lineal)
base = [1 x y] @@(los términos, sin el x·y del cuadrado)

## 2 · El triángulo y sus 3 nudos
#|  nudo 1 (0,0)   ·   nudo 2 (1,0)   ·   nudo 3 (0,1)

## 3 · Nace C: la base evaluada en los 3 nudos
#|  (0,0):[1 0 0]     (1,0):[1 1 0]     (0,1):[1 0 1]
C = [1 0 0; 1 1 0; 1 0 1] @@(C = base en los 3 nudos)

## 4 · Despejar las perillas: la inversa
Cinv = C^-1 @@(C⁻¹ despeja a, b, c)

## 5 · Las funciones de forma: N = base · C⁻¹
N = base*Cinv @@(las 3 funciones de forma)
#: Da  **[1−x−y ,  x ,  y]**. Son las "coordenadas de área". Cada una vale 1 en su nudo y 0 en los otros dos.

## 6 · Prueba: suman 1
suma = N*[1;1;1] @@(N₁+N₂+N₃ = 1)

## 7 · VERLAS — son PLANOS, no carpas
#: Aquí la diferencia con el cuadrado: el triángulo lineal da **planos inclinados** (pendiente constante). Por eso se llama **CST** = "triángulo de deformación constante". El cuadrado bilineal daba carpas alabeadas; este NO se tuerce:
#surf(1-x-y, [0 1], [0 1])
#: En planta (mapa de color) se ve que cada N es un **degradado lineal** perfecto — N₁ baja en diagonal, N₂ de izquierda a derecha, N₃ de abajo a arriba:
#map(1-x-y, [0 1], [0 1])
#map(x, [0 1], [0 1])
#map(y, [0 1], [0 1])
#: (El triángulo real es la esquina donde x+y ≤ 1; el resto del cuadrado es solo para ver el plano.)

## 8 · LA RAZÓN — el momento 1956
#: El valor en cualquier punto es  u = N₁·u₁ + N₂·u₂ + N₃·u₃. Cada N pesa un nudo. Trocea el ala en triángulos, campo lineal en cada uno, **ensambla por los nudos compartidos**, resuelve en el computador. Ese fue el nacimiento del método de los elementos finitos.
