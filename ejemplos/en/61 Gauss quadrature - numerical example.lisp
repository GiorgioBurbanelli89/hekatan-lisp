# Gauss quadrature with numbers: the integral of x³ from 0 to 4

#: Two measurements, two multiplications and one sum. It comes out **exact**, and here you see why. First with letters, then with numbers, and finally the check against the antiderivative.
#: The derivation of where the points and weights come from is in sheet 63; the change of variable, in sheet 62. Here they are used.

## 1 · With letters: the change of variable

#: The Gauss points are tabulated on the **standard interval**, from −1 to +1, in the natural coordinate ξ. A real integral goes from a to b, so first the real interval is mapped to the standard one with a **straight line**, the one that sends ξ = −1 to x = a and ξ = +1 to x = b:
X = p + q*xi
#: Its two numbers have names: p is the **centre** of the interval and q its **half-length**. Where they come from is derived in sheet 62, and they are:
p_c = (a + b)/2
q_c = (b - a)/2
#: The **Jacobian** is the slope of that line, and the engine derives it:
J = Diff{p + q*xi @ xi}
#: It gives J = q, that is (b − a)/2. It is the stretching factor between the two intervals: a small piece dξ of the standard interval measures J·dξ in the real one, and that is why the integral is multiplied by J.

## 2 · With letters: the formula, the two points and the two weights

#: The integral stops being an integral and becomes a **sum of two terms**: each height measured, times its weight, and everything times the Jacobian.
I = q*(w_1*f_1 + w_2*f_2)
#: With **two** points the formula is exact up to degree 3. Where to put them comes from demanding just that —it is fully derived in sheet 63— and they are symmetric:
xi_1 = dec(-1/3^0.5, 6)
xi_2 = dec(1/3^0.5, 6)
#: And the two weights are 1:
w_1 = 1
w_2 = 1
#: They add up to 2 because the standard interval measures 2: that is the first condition, that of integrating the constant 1 between −1 and +1. And they are equal because the points are symmetric.

## 3 · The numbers: the integral of x³ from 0 to 4

#: Now the concrete case: a = 0, b = 4, and the function x³, which is of degree 3.
#: The midpoint of the interval and the half-length:
x_m = dec((0 + 4)/2, 6)
J = dec((4 - 0)/2, 6)
#: The two standard points, mapped to the real interval with x = 2 + 2·ξ:
x_1 = dec(2 - 2/3^0.5, 6)
x_2 = dec(2 + 2/3^0.5, 6)
#: There the function is **measured**. Nothing more: two evaluations of x³.
f_1 = dec((2 - 2/3^0.5)^3, 6)
f_2 = dec((2 + 2/3^0.5)^3, 6)
#: They are added with their weight, which is 1:
S = dec((2 - 2/3^0.5)^3 + (2 + 2/3^0.5)^3, 6)
#: The sum gives exactly 32. And it is multiplied by the Jacobian:
I_g = dec(2*((2 - 2/3^0.5)^3 + (2 + 2/3^0.5)^3), 6)

## 4 · The check with the antiderivative

#: The traditional way: the antiderivative of x³, which the engine integrates:
F = Integral{x^3 @ x}
#: It is x⁴/4. Evaluated between 0 and 4: 4⁴/4 − 0 = 64. The engine does it at once:
I_exacta = Area{x^3 @ x=0:4}
#: And the difference between the two:
dif = dec(2*((2 - 2/3^0.5)^3 + (2 + 2/3^0.5)^3) - 4^4/4, 6)
#: **Zero.** It is neither a coincidence nor a lucky approximation: with n points the quadrature is exact up to degree 2n − 1, and with n = 2 that is degree 3. The function was x³, exactly degree 3.

## 5 · And with a single point?

#: With **one** point the rule is exact only up to degree 2·1 − 1 = 1, that is straight lines. The single point is ξ = 0 —the centre— with weight 2:
x_c = dec((0 + 4)/2, 6)
f_c = dec(2^3, 6)
I_1 = dec(2*2*2^3, 6)
#: It gives 32 against the true 64: **half**. The error is 50 %, and not through bad luck: x³ is of degree 3 and one point is not enough. That is why two are used.

## 6 · The curve and the two points where it is measured

#: The curve x³ between 0 and 4, with the two measurements marked. They are inside the interval, not at the ends: that is the whole point.
#fplot(x^3, Gauss = [0.845299 0.603993; 3.154701 31.396007], [0 4])
#: On the left almost nothing is measured (0.604) and on the right a lot (31.396). Added they give 32, and times the Jacobian 2 they give the exact 64 units of area.

## In one line

#: · The real interval is mapped to the standard one with a straight line; its slope is the Jacobian J = (b − a)/2.
#: · Two points at ±1/√3, weight 1, and the sum times J.
#: · With two points it is exact up to degree 3 — and x³ is degree 3: difference **zero**.
