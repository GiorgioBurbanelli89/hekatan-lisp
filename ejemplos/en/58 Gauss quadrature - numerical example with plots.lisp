# Gauss quadrature: a numerical example, with plots

#: The previous sheet derived the two points and the two weights. Here they are USED, with a concrete integral and with drawings, to see what it is really like. The area under the curve x³ between zero and four is calculated, measuring the function at only TWO points.

## 1 · The integral we want

#: The area under y = x³ from x = 0 to x = 4. In the plot, the area is the region under the curve.
#fplot(y = x^3, [0 4])

#: By the usual route, with the antiderivative, the area is:
exacta = Area{x^3 @ x = 0:4}

## 2 · Gauss works on the standard interval, from −1 to +1

#: The two points and the two weights are tabulated for the interval that goes from minus one to plus one. Our interval goes from zero to four, so we have to translate. The translation is the line that takes ξ = −1 to x = a, and ξ = +1 to x = b:
a = 0
b = 4
p = (a + b)/2
q = (b - a)/2
#: The first number is the MIDPOINT of the interval, and the second is the HALF-LENGTH. With them, any ξ is converted to its x:
#: x = p + q·ξ, that is x = {p} + {q}·ξ.
#: And on changing variable, the differential is also stretched: dx = q·dξ. That q is the JACOBIAN, the stretching factor between the two intervals.
J = q

## 3 · The two Gauss points, and where they really fall

#: On the standard interval the two points are ξ = ±1/√3, and the two weights equal one.
#: In decimals, ξ_{1} = −0.577350 and ξ_{2} = +0.577350 (it is 1/√3).
xi_1 = -0.577350
xi_2 = 0.577350
w_1 = 1
w_2 = 1
#: Carried to our interval with x = p + q·ξ:
x_1 = 0.8452994616
x_2 = 3.1547005384
#: (they come from 2 + 2·ξ, with ξ = ∓0.577350)
#: Note: they do NOT fall at the ends (0 and 4) nor at the center. They fall here, and the plot marks them on the curve:
#fplot(y = x^3, puntos = [0.845299 0.603993; 3.154701 31.396007], [0 4])

## 4 · The function measured at those two points

f_1 = dec(x_1*x_1*x_1, 6)
f_2 = dec(x_2*x_2*x_2, 6)
#: Only TWO evaluations of the function. Nothing more. Not a hundred rectangles nor a thousand.

## 5 · The weighted sum

#: Gauss's rule is to add each measurement multiplied by its weight:
suma = dec(w_1*f_1 + w_2*f_2, 6)
#: And since it was calculated on the standard interval, the stretching must be undone by multiplying by the Jacobian:
gauss = dec(suma*J, 6)

## 6 · The comparison

#: The exact value was {exacta} and Gauss gives {gauss}. The difference:
error = dec(gauss - exacta, 6)
#: Zero down to the last digit we wrote. It is not that it looks alike: it is exact. And the reason is the degree law: with n points Gauss quadrature integrates exactly up to degree 2·n − 1. With two points, up to degree three — and x³ is exactly degree three.
n = 2
grado_exacto = 2*n - 1

## 7 · The proof that the law rules: raise one degree and it fails

#: If the curve is of degree four, two points are no longer enough. The exact area of x⁴ on the standard interval:
exacta_4 = Area{xi^4 @ xi = -1:1}
#: And what Gauss says with two points, raising each point to the fourth power:
gauss_4 = dec((1/3)^2 + (1/3)^2, 6)
#: Two fifths against two ninths: it fails exactly where the law says it has to fail, at degree four. With THREE points it would be right again, up to degree five.

## 8 · Why this matters in structural calculation

#: The deflected shape of a beam is a CUBIC: degree three. That is why two Gauss points are enough to integrate its stiffness matrix exactly, and why the engine integrates this way and not with a hundred rectangles. The numbers twelve, six, four and two of the beam matrix come out of those two evaluations.
K_viga = [12, 6, -12, 6; 6, 4, -6, 2; -12, -6, 12, -6; 6, 2, -6, 4]
