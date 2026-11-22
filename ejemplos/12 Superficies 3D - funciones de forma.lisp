# Superficies 3D — VER las funciones de forma del elemento 2D
#: El motor dibuja superficies **z = f(x,y)** con `#surf(...)` (SkiaSharp). Sirve para *ver* lo que las fórmulas dicen: cada función de forma es una **carpa** que vale **1 en su nudo** y **0 en los otros tres**.

## 1 · El elemento y sus 4 funciones de forma
#: Cuadrilátero unitario, nudos en (0,0) (1,0) (1,1) (0,1). Las bilineales:
N_1 = (1-x)*(1-y) @@(nudo 1)
N_2 = x*(1-y) @@(nudo 2)
N_3 = x*y @@(nudo 3)
N_4 = y*(1-x) @@(nudo 4)

## 2 · Cada carpa, dibujada por el motor
#: Fíjate cómo el pico (azul, z=1) se para en una esquina distinta en cada una:
#surf((1-x)*(1-y), [0 1], [0 1])
#surf(x*(1-y), [0 1], [0 1])
#surf(x*y, [0 1], [0 1])
#surf(y*(1-x), [0 1], [0 1])

## 3 · La prueba visual: suman 1 (partición de la unidad)
#: Sumar las cuatro da un **plano plano en z=1**. Por eso interpolan cualquier valor entre los nudos sin inventar bultos:
#surf((1-x)*(1-y)+x*(1-y)+x*y+y*(1-x), [0 1], [0 1])

## 4 · La misma función en 2D (planta) — mapa de color
#: Lo mismo visto **desde arriba**: la gráfica FEM clásica. Colores = valor (jet_r) + barra. Estático (2D no gira), dibujado con SkiaSharp:
#map((1-x)*(1-y), [0 1], [0 1])
#map(x*y, [0 1], [0 1])

## 5 · Cómo se usan
#: **3D girable:** `#surf(expr, [xa xb], [ya yb])`  ·  **2D planta:** `#map(expr, [xa xb], [ya yb])`. Un solo rango `[a b]` se usa igual para x e y. La `expr` puede ser inline `(x*y)` o el **nombre** de algo ya deducido.
#: Otro ejemplo — una campana (paraboloide invertido), en 3D y en planta:
#surf(1-(x^2+y^2), [-1 1], [-1 1])
#map(1-(x^2+y^2), [-1 1], [-1 1])
