# Gauss on a bar: from the symbol to the number
#: What exactly the rectangles are, and what all this is for on a real bar. First the algebra, then the numbers.
#> Hekatan Struct

## 1 · The rectangles are NOT the region
#: Here is the confusion, and it is worth saying clearly. In the drawing there are **two different figures**:
#: · The **blue** zone under the curve: that is the **exact** area, the number we want.
#: · The **orange rectangles**: each one has as **width its weight wᵢ** and as **height the curve at its point, f(ξᵢ)**. Their summed area is what the **formula computes**.
#: They do not look alike, and they need not. The only thing asked of them is that the **number** comes out equal. Gauss places the points exactly where that happens.

## 2 · Look at it: the width is the weight, the height is the function
#gauss(vars)

## 2 · The bar, in symbols
#: Now the bar. Its stiffness is this integral, and inside are the B matrix, the material and the Jacobian:
B = [-1/L, 1/L] @@(B = J⁻¹·dN/dξ)
J = L/2 @@(Jacobiano)
BtB = transpose(B)*B @@(BᵀB)
K_exacta = E*A*J*Area{transpose(B)*B @ xi=-1:1} @@(K = E·A·|J|·∫BᵀB dξ)
#: It gives **EA/L**, the classic one. And now the key: since B does not depend on {xi}, that integrand is **constant**.

## 3 · The width 1 is the solution for TWO points, not a rule
#: With **n** points there are **2n unknowns** —n positions and n weights— and **2n conditions** are imposed. Change n, the system changes, and the solution changes. That is why the width is not always 1:
#: **One point** · 2 unknowns (ξ, w) · 2 conditions (f = 1 and f = ξ):
#: → w·1 = 2 gives **w = 2**, and w·ξ = 0 gives **ξ = 0**. A single segment, which occupies the whole interval.
#: **Two points** · 4 unknowns · 4 conditions (1, ξ, ξ², ξ³):
#: → **w₁ = w₂ = 1** and **ξ = ∓1/√3 = ∓0.5774**. Two segments of width 1. This is what we solved for before.
#: **Three points** · 6 unknowns · 6 conditions (up to ξ⁵):
#: → **w = 5/9, 8/9, 5/9** and **ξ = ∓√(3/5), 0**. Three segments, and they no longer measure 1.
#: The only thing that repeats in all cases is the **first** condition, f = 1, which says that the weights add up to the width of the interval:
suma_pesos = Area{1 @ xi=-1:1} @@(Σwᵢ = ∫1 dξ = 2, siempre)

## 4 · Let us check the three-point ones with the engine
#: If 5/9, 8/9, 5/9 at ∓√(3/5) and 0 are the solution, they must satisfy the conditions. The engine evaluates them:
c1 = dec(5/9 + 8/9 + 5/9, 4) @@(f = 1 → debe dar 2)
c2 = dec(2*(5/9)*(3/5), 4) @@(f = ξ² → debe dar 2/3 = 0.6667)
c3 = dec(2*(5/9)*(3/5)^2, 4) @@(f = ξ⁴ → debe dar 2/5 = 0.4000)
exacta_2 = Area{xi^2 @ xi=-1:1} @@(∫ξ² dξ)
exacta_4 = Area{xi^4 @ xi=-1:1} @@(∫ξ⁴ dξ)
#: All three match. Each set of weights and positions is the solution of **its own** system: with two points the width 1 comes out; with three, 5/9 and 8/9.

## 5 · ONE Gauss point is already enough
#: A constant integrand is a polynomial of degree 0, and with **n = 1** Gauss is exact up to degree 2n−1 = 1. So a single point, at the center, with weight 2:
K_g1 = E*A*J*2*BtB @@(K = w·BᵀB·E·A·|J|, con w = 2 y ξ = 0)
#: The same **EA/L**. One point, exact. That is why programs do not spend four points on a straight bar of constant section.

## 6 · Now a bar that does need it
#: Let us change the bar: one of **variable section**, which thickens toward the ends. The area is no longer a number, it is a function of {xi}:
A_var = A_0*(1 + 0.6*xi^2) @@(sección variable)
#: The integrand becomes of **degree 2**, and there a single point falls short. Check it: move the bar and watch how the section changes along the element.
#slider fplot(A_de_xi = 1 + n/10*x^2, [-1 1]), n = 0:9

## 7 · The exact number, with the engine
I_A = Area{1 + 0.6*xi^2 @ xi=-1:1} @@(∫(1+0.6ξ²)dξ)
K_var = E*A_0*I_A/(2*L) @@(K = E·(1/L²)·|J|·∫A(ξ)dξ)
#: The integral equals **2.4**, so the stiffness is **1.2·E·A₀/L**: 20 % more than the constant-section bar.

## 8 · One point against two points
#: **With one point** (ξ = 0, w = 2): the section at the center is A₀, and the formula gives 2·A₀ = 2.0 instead of 2.4.
g1 = dec(2*(1 + 0.6*0^2), 4) @@(1 punto: w·A(0))
#: **With two points** (ξ = ∓0.5774, w = 1): the section at each point equals A₀·(1 + 0.6/3) = 1.2·A₀, and the sum gives 2.4. Exact.
g2 = dec(1*(1 + 0.6*0.5773503^2) + 1*(1 + 0.6*0.5773503^2), 4) @@(2 puntos: w₁A(−a) + w₂A(+a))
error_1 = dec((2.4 - 2.0)/2.4*100, 1) @@(error del punto único, %)
#: One point is wrong by **16.7 %**; two points hit the digit. That is the whole reason for using 2×2 points in a quadrilateral and not just one.

## 9 · And with construction numbers
E_v = 2100 @@(tonf/cm²)
A_v = 20 @@(cm²)
L_v = 300 @@(cm)
K_const = dec(E_v*A_v/L_v, 1) @@(barra normal: E·A/L, tonf/cm)
K_variable = dec(1.2*E_v*A_v/L_v, 1) @@(barra de sección variable, tonf/cm)
#: 140 against 168 tonf/cm. Gauss quadrature is what lets the program compute the second without integrating by hand: it evaluates at two points, multiplies by their weight, and adds.
#> Hekatan Struct
