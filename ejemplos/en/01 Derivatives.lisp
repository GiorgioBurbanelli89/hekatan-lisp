# Derivatives
#: **Derivate** differentiates the function with respect to the variable that follows the at sign. The operation and its result appear on the same line.

## Powers and sums
Derivate{x^2 + 3*x @ x}
Derivate{5*x^4 - 2*x^3 + 7 @ x}

## Product and quotient
Derivate{x*sin(x) @ x}
Derivate{1/x @ x}

## Root and exponential
Derivate{sqrt(x) @ x}
Derivate{exp(2*x) @ x}

## Slope at a point
#: **Slope** is the derivative evaluated at a point: the slope of the tangent line.
Slope{x^3 - 2*x @ x = 2}
