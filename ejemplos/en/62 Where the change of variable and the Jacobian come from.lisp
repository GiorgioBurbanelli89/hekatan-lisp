# Where x = (a+b)/2 + (b−a)/2·ξ comes from, and why J = (b−a)/2

#: That formula is copied from memory in every finite element book. Here it is not stated: it is **derived**, and the solving is done by the Hekatan LISP engine, not by hand.
#: It is the step before Gauss quadrature (sheet 63) and the one used in the numerical example (sheet 61).

## 1 · What is needed and why

#: The Gauss points and weights are tabulated **only once**, on a fixed interval that goes from −1 to +1. That interval is called the **standard interval**, and its coordinate the **natural** one: ξ.
#: But a real integral goes from a to b, and each element of a mesh has its own a and its own b. If the points had to be tabulated for every interval, the table would be useless.
#: The way out is to map each real interval to the standard one. And the simplest map that can do it is a **straight line**: to each ξ it assigns an x.

## 2 · The line, with its two numbers unknown

#: A line in ξ has two numbers to determine. Here they are called p and q:
X = p + q*xi
#: They are not two points of the interval: p is the value of x at the centre (ξ = 0) and q is the slope, how much x advances each time ξ advances 1.

## 3 · The two conditions that fix it

#: There are exactly two things the line has to satisfy, one for each end.
#: At ξ = −1 it must land on x = a. The line at that point is worth:
e_1 = p + q*(-1)
#: At ξ = +1 it must land on x = b. The line there is worth:
e_2 = p + q*(1)
#: That is: **p − q = a** and **p + q = b**. Two equations, two unknowns. There is nothing to assume.

## 4 · The solving, done by the engine

#: From the first equation p is solved:
p_sol = Despejar{p - q = a @ p}
#: It gives p = a + q. That goes into the second: (a + q) + q = b, that is a + 2·q = b. And from there q is solved:
q_sol = Despejar{a + 2*q = b @ q}
#: That is the first result: **q = (b − a)/2**, the half-length of the real interval. And with q now known, p goes back to the first equation, now with that value inside:
p_val = Despejar{p - (b - a)/2 = a @ p}
#: And that is the second: **p = (a + b)/2**, the centre of the interval. With both, the line of the change of variable becomes x = (a+b)/2 + (b−a)/2·ξ, which is the formula from the beginning.

## 5 · The same as a matrix system

#: The two conditions can be stacked: each row is the basis [1, ξ] evaluated at one end. The system is M·[p; q] = [a; b]:
M = [1, -1; 1, 1]
#: And it is solved by inverting, which is another path to the same place:
c = inv(M) * [a; b]
#: The two numbers are the same: the centre above, the half-length below. Two paths, one result.

## 6 · The Jacobian: the slope of that line

#: The Jacobian is the derivative of the real coordinate with respect to the natural one, and the engine computes it:
J = Diff{p + q*xi @ xi}
#: It gives J = q: the slope of a line is its second number. And plugging in the value of q solved above:
J_ab = Diff{(a + b)/2 + (b - a)/2*xi @ xi}
#: **J = (b − a)/2**, the half-length of the real interval.
#: What it means: it is the **stretching factor** between the two intervals. A small piece dξ of the standard interval measures J·dξ in the real one. That is why every integral changes like this: dx = J·dξ, and the integral over the real interval is that of the standard one multiplied by J.
#: The length check: the standard interval measures 2 and the real one measures b − a. Multiplying 2 by the Jacobian:
L = Simplify{2*((b - a)/2)}
#: It gives b − a, the length of the real interval. The stretching adds up.

## 7 · The example case: the interval [0, 4]

#: With a = 0 and b = 4, the centre and the half-length:
p_n = dec((0 + 4)/2, 6)
q_n = dec((4 - 0)/2, 6)
#: That is the line x = 2 + 2·ξ, and the Jacobian J = 2. It is checked at both ends. At ξ = −1:
x_izq = dec(2 + 2*(-1), 6)
#: It gives 0, which is a. And at ξ = +1:
x_der = dec(2 + 2*(1), 6)
#: It gives 4, which is b. The map does what it was asked.

## 8 · The map, drawn

#: The line that takes ξ (from −1 to +1) to x (from 0 to 4). The two marked points are the ends: (−1, 0) and (+1, 4).
#fplot(2 + 2*xi, extremos = [-1 0; 1 4], [-1 1])
#: Its inclination —2 up for every 1 to the right— **is** the Jacobian. A longer interval raises the line more; a shorter one, less.

## In one line

#: · The standard interval [−1, +1] exists to tabulate the Gauss points only once.
#: · The line x = p + q·ξ is fixed with two conditions, one per end, and the engine solves p = (a+b)/2 and q = (b−a)/2.
#: · The Jacobian is the slope of that line, J = (b−a)/2, and it is the factor by which the integral is multiplied.
