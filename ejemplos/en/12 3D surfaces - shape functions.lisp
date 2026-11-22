# 3D surfaces — SEEING the shape functions of the 2D element
#: The engine draws surfaces **z = f(x,y)** with `#surf(...)` (SkiaSharp). It lets you *see* what the formulas say: each shape function is a **tent** that equals **1 at its node** and **0 at the other three**.

## 1 · The element and its 4 shape functions
#: Unit quadrilateral, nodes at (0,0) (1,0) (1,1) (0,1). The bilinear functions:
N_1 = (1-x)*(1-y) @@(nudo 1)
N_2 = x*(1-y) @@(nudo 2)
N_3 = x*y @@(nudo 3)
N_4 = y*(1-x) @@(nudo 4)

## 2 · Each tent, drawn by the engine
#: Notice how the peak (blue, z=1) stands on a different corner in each one:
#surf((1-x)*(1-y), [0 1], [0 1])
#surf(x*(1-y), [0 1], [0 1])
#surf(x*y, [0 1], [0 1])
#surf(y*(1-x), [0 1], [0 1])

## 3 · The visual test: they add up to 1 (partition of unity)
#: Adding the four gives a **flat plane at z=1**. That is why they interpolate any value between the nodes without inventing bumps:
#surf((1-x)*(1-y)+x*(1-y)+x*y+y*(1-x), [0 1], [0 1])

## 4 · The same function in 2D (plan view) — color map
#: The same seen **from above**: the classic FEM plot. Colors = value (jet_r) + bar. Static (2D does not rotate), drawn with SkiaSharp:
#map((1-x)*(1-y), [0 1], [0 1])
#map(x*y, [0 1], [0 1])

## 5 · How they are used
#: **Rotatable 3D:** `#surf(expr, [xa xb], [ya yb])`  ·  **2D plan:** `#map(expr, [xa xb], [ya yb])`. A single range `[a b]` is used for both x and y. The `expr` can be inline `(x*y)` or the **name** of something already derived.
#: Another example — a bell (inverted paraboloid), in 3D and in plan:
#surf(1-(x^2+y^2), [-1 1], [-1 1])
#map(1-(x^2+y^2), [-1 1], [-1 1])
