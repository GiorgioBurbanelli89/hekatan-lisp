# Is the deformed shape the program draws the REAL one? Where did the cubic come from?
#: Yes, for beams and columns it is the **real** (exact) deformed shape, not just a pretty drawing. Here you see where it comes from: from solving the **beam equation**. The engine checks it.

## 1 · The beam equation (Euler–Bernoulli)
#: The physics of a beam is:  **EI · v''''(x) = q(x)**  (q = distributed load). Between two nodes, if the load is applied AT the nodes, there is no q in between → **v'''' = 0**.

## 2 · The ENGINE solves: integrate (each ∫ raises one degree)
#: With no load on the span, the **shear is constant** → v''' = 6c₃ (a constant). I integrate upwards; the engine does it and each **∫ raises the degree by 1**:
vpp = Integral{6*c3 @ x} @@(v'': ∫ constante → LINEAL)
vp = Integral{6*c3*x @ x} @@(v': ∫ lineal → CUADRÁTICA)
v = Integral{3*c3*x^2 @ x} @@(v: ∫ cuadrática → CÚBICA)
#: I started from a **constant** and in 3 integrations reached a **cubic** (c₃·x³). Each ∫ adds an integration constant → 4 constants in total (c₀,c₁,c₂,c₃) = the **4 nodal data** (v and θ at each end). **That is where the cubic came from: it is what comes out of integrating the beam equation.**

## 3 · Check: differentiating the cubic returns 0
#: The other way round: if I differentiate the cubic four times (ordinary d/dx, v is a single-variable function), it must return 0 (this confirms that it satisfies v''''=0).
vc = c0 + c1*x + c2*x^2 + c3*x^3 @@(la deformada)
d1 = Diff{vc @ x} @@(v')
d2 = Diff{c1+2*c2*x+3*c3*x^2 @ x} @@(v'')
d3 = Diff{2*c2+6*c3*x @ x} @@(v''' constante)
d4 = Diff{6*c3 @ x} @@(v'''' = 0 ✓)
#: **v'''' = 0** → the cubic satisfies the beam equation exactly. That is why the drawn deformed shape IS the real one: the beam, between unloaded nodes, takes exactly that cubic shape.

## 4 · The curvature is not constant — that is why it looks "curved"
#: The curvature is v'' = 2c₂ + 6c₃x → **linear**, not zero. That is why the beam looks bent (not straight) and its moment (M = EI·v'') varies along it. Exactly what the program draws.

## 5 · The honest nuance: WITH distributed load on the span
#: If there is a distributed load w BETWEEN nodes (self-weight), then v'''' = w/EI ≠ 0 → integrating, the real deformed shape gains an **x⁴** term (degree 4). The real shape of a fixed-fixed beam under uniform load is x²·(1−x)²:
#fplot(x^2*(1-x)^2, [0 1])
#: There the Hermite cubic is **no longer** exact in the middle; the program corrects it by adding that part of the load (or by splitting into more elements). But for loads AT the nodes (the usual case in columns), the cubic is exact.

## 6 · Columns: the same story
#: A column is a beam-column: its bending follows the same **EI·v''''=0** between nodes → the same exact **cubic**. (Only when buckling / P-Δ matters does the equation change, and the real shape uses stability functions — trigonometric/hyperbolic.)
