# The principle: why we interpolate, and why linear first and then polynomial
#: The underlying question, with the engine and plots.

## 1 · The root principle: from the infinite to the finite
#: A structure has **infinitely many points**, each moving differently → the unknown is an **entire function**, not a number. That is impossible to solve directly. The trick: store the value at **a few nodes** + a **fill rule** (the shape function). So ∞ unknowns → **few** unknowns → the computer solves it. That is a "**finite** element".

## 2 · A real curve we want to represent
#: Take any smooth curve (a hump): f(x) = sin(π·x) over [0,1]. The nodes will be 0, ½ and 1.

## 3 · LINEAR fill: straight pieces → the KINK appears
#: Join the nodes with **straight lines**. The polyline matches in **value** at the nodes, but look at the **peak** at x=½: the slope jumps abruptly. (The triangle 1−|2x−1| is the 2-segment linear approximation.)
#fplot(sin(3.14159*x), 1-abs(2*x-1), [0 1])
#: Continuous in **value** (C⁰), but **NOT** in slope. That kink is what the linear fill cannot avoid. With more pieces it gets closer (like a polygon to a circle), but always with kinks.

## 4 · POLYNOMIAL fill: a smooth curve, no kink
#: A **polynomial** bends through the same nodes, but **smoothly**. Here a quadratic 4·x·(1−x) that passes through (0,0), (½,1), (1,0):
#fplot(sin(3.14159*x), 4*x-4*x^2, [0 1])
#: No peak. It matches in **value AND slope** (C¹). It captures the real shape with very few elements.

## 5 · Why the degree was RAISED (linear → polynomial)
#: It was not a whim. The **beam** bends, and its energy depends on the **curvature** (second derivative). A kink in the linear fill gives false curvature (zero or infinite) → physically invalid. For the **slope to be continuous** we must control both the displacement **and** the rotation at each node → 2 data per node × 2 nodes = 4 → the polynomial rises to **cubic** (Hermite). **The physics demanded more smoothness, and more smoothness demands a higher degree.**

## 6 · The rule that unifies it
#: how much continuity the problem demands  →  the degree of the polynomial
#|  barra que ESTIRA  →  basta valor continuo (C⁰)  →  1 dato/nudo  →  LINEAL
#|  viga que SE CURVA →  valor y pendiente (C¹)      →  2 datos/nudo →  CÚBICA (Hermite)
#: We started with the simplest (linear: cheap, and a fine mesh is enough) and raised the degree **only when the physics asked for it**. That is the principle.
