# Why shape functions exist — 1D first, 2D afterwards
#: The QUESTION: I know the value only at the **nodes**. How do I get the value at **any point** in between? I need a fill rule. The engine derives it by itself. Everything is **computed by Hekatan LISP**.

## PART 1 · A 2-NODE BAR (1D)

### 1.1 · The assumption: a straight line (2 nodes → 2 knobs)
#: Between 2 points, the simplest thing is a straight line. Basis = the terms [1, x]:
base1 = [1 x] @@(los términos, como el y=a+b·x)

### 1.2 · Here C IS BORN: I evaluate the basis at each node (x=0 and x=1)
#: I plug the coordinate of each node into [1, x]. Each row is that evaluation:
#|  nudo 1 (x=0): [1  0]      nudo 2 (x=1): [1  1]
C1 = [1 0; 1 1] @@(C = base evaluada en los 2 nudos)

### 1.3 · I solve for the knobs: the inverse
Ci1 = C1^-1 @@(C⁻¹: despeja los coeficientes)

### 1.4 · The shape functions come out BY THEMSELVES: N = basis · C⁻¹
N1D = base1*Ci1 @@(N = base · C⁻¹)
#: It gives **[1−x , x]**. Those are N₁ and N₂.

### 1.5 · SEEING THEM (1D plot)
#: N₁ drops from 1→0, N₂ rises from 0→1. Each one equals **1 at its node and 0 at the other**:
Na = 1-x @@(N₁)
Nb = x @@(N₂)
#fplot(Na, Nb, [0 1])

### 1.6 · THE REASON (this is what you were missing)
#: The value at any point is  **u(x) = N₁·u₁ + N₂·u₂**. Each N is the **WEIGHT** of a node. At node 1, N₁=1 and N₂=0 → u₁ comes out exact. In between, they blend smoothly. That is why it works: it reproduces the nodes and fills in the rest.

## PART 2 · A 4-NODE TILE (2D)

### 2.1 · The assumption: bilinear (4 nodes → 4 knobs)
#: Same idea, but 4 corners → 4 terms. The new one is x·y (it keeps the edges straight):
base2 = [1 x y x*y] @@(la base bilineal)

### 2.2 · C is born: the basis evaluated at the 4 corners
#|  (0,0):[1 0 0 0]  (1,0):[1 1 0 0]  (1,1):[1 1 1 1]  (0,1):[1 0 1 0]
C2 = [1 0 0 0; 1 1 0 0; 1 1 1 1; 1 0 1 0] @@(C, 4 filas = 4 nudos)

### 2.3 · The inverse
Ci2 = C2^-1 @@(despeja las 4 perillas)

### 2.4 · The 4 shape functions: N = basis · C⁻¹
N2D = base2*Ci2 @@(las 4 carpas)
#: It gives  N₁=(1−x)(1−y), N₂=x(1−y), N₃=x·y, N₄=y(1−x).

### 2.5 · SEEING THEM in 3D (rotatable) and in 2D (plan)
#: Each tent equals 1 at its node and 0 at the other three — just like in 1D, but at the 4 corners:
#surf((1-x)*(1-y), [0 1], [0 1])
#surf(x*y, [0 1], [0 1])
#map((1-x)*(1-y), [0 1], [0 1])

### 2.6 · THE REASON is the SAME as in 1D
#: u(x,y) = N₁·u₁ + N₂·u₂ + N₃·u₃ + N₄·u₄. Each N weights one node. Their sum = 1 at every point (so no values are invented). C was only the machine to manufacture those weights from the polynomial.
