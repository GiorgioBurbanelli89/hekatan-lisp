# Gauss quadrature, fully derived with the engine

#: Up to "there are four unknowns" it all explains itself. What follows —the integrals, the system, the symmetry and the number 1/√3— is what the **engine operates** here, step by step. Nothing written by hand.
#: The change of variable is in sheet 62; the example with numbers, in sheet 61.

## 1 · The setup: two measurements and four unknowns

#: Everything is done on the standard interval, from −1 to +1, in the natural coordinate ξ. Gauss's idea is to replace an integral by a **sum of two terms**: two measured heights, each with its weight:
I = w_1*f_1 + w_2*f_2
#: There are four free numbers: where to measure (ξ_{1} and ξ_{2}) and how much each measurement counts (w_{1} and w_{2}).
#: Four unknowns call for four conditions. That is the setup.

## 2 · The four conditions, with the integrals done by the engine

#: The condition is: the formula must give the **exact area** for the four bricks from which any curve of degree 3 is built — the constant 1, the line ξ, the parabola ξ² and the cubic ξ³.
#: The exact areas are not copied from a table: the engine integrates them between −1 and +1.
A_0 = Area{1 @ xi=-1:1}
A_1 = Area{xi @ xi=-1:1}
A_2 = Area{xi^2 @ xi=-1:1}
A_3 = Area{xi^3 @ xi=-1:1}
#: The two zeros are no coincidence: ξ and ξ³ are odd, they have as much area above the axis as below, and they cancel. The antiderivative says so by itself:
F_1 = Integral{xi @ xi}
F_3 = Integral{xi^3 @ xi}
#: Both antiderivatives are even: they take the same value at −1 and at +1, and subtracting them gives zero.

## 3 · The system: four equations, four unknowns

#: Equating the Gauss sum with each of those four areas gives the system:

#| nº | ladrillo | la suma de Gauss | tiene que dar |
#|---|---|---|---:|
#| 1 | 1 | w_{1} + w_{2} | 2 |
#| 2 | ξ | w_{1}·ξ_{1} + w_{2}·ξ_{2} | 0 |
#| 3 | ξ² | w_{1}·ξ_{1}² + w_{2}·ξ_{2}² | 2/3 |
#| 4 | ξ³ | w_{1}·ξ_{1}³ + w_{2}·ξ_{2}³ | 0 |

#: Four equations, four unknowns. And it is not linear: the unknowns ξ appear raised to powers. That is why it is not solved by inverting a matrix, but by combining equations.

## 4 · The symmetry is not assumed: it comes out by itself

#: The trick is to get the weights out of the way. From the 4th condition we subtract the 2nd multiplied by ξ_{1}², and the engine does the subtraction:
R = Simplify{w_1*xi_1^3 + w_2*xi_2^3 - xi_1^2*(w_1*xi_1 + w_2*xi_2)}
#: The term of the first point **cancels by itself**: in it remains w_{1}·ξ_{1}³ − ξ_{1}²·w_{1}·ξ_{1} = 0. Only the second survives, and factored it is w_{2}·ξ_{2}·(ξ_{2}² − ξ_{1}²).
#: Since the right-hand side of both conditions was 0, that subtraction is 0. The weight w_{2} cannot be zero —otherwise there would be no second point— and neither can ξ_{2} —the two points cannot be at the centre—. So what vanishes is the parenthesis:
#: ξ_{2}² = ξ_{1}², and since the two points are distinct, **ξ_{2} = −ξ_{1}**. The symmetry was not assumed: it came out of the algebra.

## 5 · With the symmetry, the solving step by step

#: ξ_{2} = −ξ_{1} is plugged into the 2nd condition. With the weights still unknown, the engine simplifies it:
C_2 = Simplify{w_1*xi_1 + w_2*(-xi_1)}
#: It leaves ξ_{1}·(w_{1} − w_{2}) = 0. Since ξ_{1} is not zero, **w_{1} = w_{2}**: the two weights are equal. Both are called w.
#: Now the 1st condition says they add up to 2, that is 2·w = 2. The engine solves:
w = Despejar{2*w = 2 @ w}
#: **Each weight is 1.** And only now does the 3rd condition come in. With weights 1 and symmetric points, its left side is:
C_3 = Simplify{1*xi^2 + 1*(-xi)^2}
#: That is 2·ξ², which must equal 2/3. That is the equation that delivers the number. Calling u = ξ² it becomes linear, and the engine solves it:
u = Despejar{2*u = 2/3 @ u}
#: **ξ² = 1/3.** Taking the root gives the two solutions, one for each point:
raices = Despejar{xi^2 = 1/3 @ xi}
#: They are ±1/√3, which is the same as ±√3/3. In decimals:
xi_1 = dec(-1/3^0.5, 6)
xi_2 = dec(1/3^0.5, 6)
#: And the 4th condition is not needed at all: with equal weights and symmetric points it holds by itself, as the engine checks:
C_4 = Simplify{xi^3 + (-xi)^3}
#: It gives zero —the engine writes the zero as 0·0—, which is exactly the exact area of ξ³. Four conditions, and all four add up.

## 6 · The check, done by the engine

#: With ξ = ±0.577350 and w = 1, we go back to the four conditions and compute the left side. Brick 1 (the constant):
v_0 = dec(1 + 1, 6)
#: Brick ξ:
v_1 = dec(-1/3^0.5 + 1/3^0.5, 6)
#: Brick ξ², which must give 2/3 = 0.666667:
v_2 = dec((-1/3^0.5)^2 + (1/3^0.5)^2, 6)
#: Brick ξ³:
v_3 = dec((-1/3^0.5)^3 + (1/3^0.5)^3, 6)
#: 2, 0, 0.666667 and 0: the four exact areas of section 2, right on.

## 7 · Where it stops working

#: With degree 4 it is over. The exact area is given by the engine:
A_4 = Area{xi^4 @ xi=-1:1}
#: And what the two Gauss points give:
v_4 = dec((-1/3^0.5)^4 + (1/3^0.5)^4, 6)
#: 0.222222 against 0.4: an error of 44 %. And it fails exactly where it had to fail: with n points the formula is exact up to degree 2n − 1, and with n = 2 that is degree 3. Not one more.

## 8 · To play with it

#: Where the ±0.5774 comes from: move the point and watch the error of each condition. Only the ξ² one dominates, and it vanishes at 1/√3:
#gauss(porque)
#: And the complete quadrature: how many points, which degree, and the 2n − 1 rule at work. Each point is drawn as a rectangle of width w_{i} and height f(ξ_{i}), so its area **is** its term of the sum:
#gauss

## In one line

#: · Two points and two weights = four unknowns; four bricks (1, ξ, ξ², ξ³) = four conditions.
#: · Subtracting equations cancels the weights and the symmetry appears: ξ_{2} = −ξ_{1}. It was not assumed.
#: · Then the weights fall out by themselves (w = 1) and so does the number (ξ² = 1/3, ξ = 1/√3 = 0.5774).
