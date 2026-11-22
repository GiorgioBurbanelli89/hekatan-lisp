# The first element (1956): the linear triangle — derived by the engine
#: This is where it all began. **1956, Boeing**: Turner and Clough cut the wing into **triangles** and inside each one assumed a **linear** displacement. That was the first use of polynomials in finite elements. The engine derives it and plots it.

## 1 · The polynomial: LINEAR (3 nodes → 3 terms)
#: A triangle has 3 corners → 3 knobs. The simplest polynomial is a plane:
u(x,y) = a + b*x + c*y @@(plano lineal)
base = [1 x y] @@(los términos, sin el x·y del cuadrado)

## 2 · The triangle and its 3 nodes
#|  nudo 1 (0,0)   ·   nudo 2 (1,0)   ·   nudo 3 (0,1)

## 3 · C is born: the basis evaluated at the 3 nodes
#|  (0,0):[1 0 0]     (1,0):[1 1 0]     (0,1):[1 0 1]
C = [1 0 0; 1 1 0; 1 0 1] @@(C = base en los 3 nudos)

## 4 · Solving for the knobs: the inverse
Cinv = C^-1 @@(C⁻¹ despeja a, b, c)

## 5 · The shape functions: N = basis · C⁻¹
N = base*Cinv @@(las 3 funciones de forma)
#: It gives  **[1−x−y ,  x ,  y]**. These are the "area coordinates". Each one equals 1 at its node and 0 at the other two.

## 6 · Check: they sum to 1
suma = N*[1;1;1] @@(N₁+N₂+N₃ = 1)

## 7 · SEE THEM — they are PLANES, not tents
#: Here is the difference with the square: the linear triangle gives **inclined planes** (constant slope). That is why it is called **CST** = "constant strain triangle". The bilinear square gave warped tents; this one does NOT twist:
#surf(1-x-y, [0 1], [0 1])
#: In plan view (color map) each N is a perfect **linear gradient** — N₁ falls diagonally, N₂ from left to right, N₃ from bottom to top:
#map(1-x-y, [0 1], [0 1])
#map(x, [0 1], [0 1])
#map(y, [0 1], [0 1])
#: (The real triangle is the corner where x+y ≤ 1; the rest of the square is only there to show the plane.)

## 8 · THE REASON — the 1956 moment
#: The value at any point is  u = N₁·u₁ + N₂·u₂ + N₃·u₃. Each N weights one node. Cut the wing into triangles, a linear field in each, **assemble through the shared nodes**, solve on the computer. That was the birth of the finite element method.
