# Integrals
#: **Integral** gives the antiderivative; **Area** gives the definite integral between two limits (Barrow's rule: F(b) − F(a)).

## Indefinite
Integral{x^2 @ x}
Integral{x + 1 @ x}
Integral{3*x^2 @ x}
Integral{1/x^2 @ x}
Integral{cos(x) @ x}
Integral{1/x @ x}

## Definite
Area{x^2 @ x = 0 : 3}
Area{3*x^2 + 2*x @ x = 1 : 2}
Area{sin(x) @ x = 0 : pi}
Area{1/x @ x = 1 : 2}
#: If the function has no elementary antiderivative, the area is computed numerically (Simpson's rule):
Area{exp(-x^2) @ x = 0 : 1}

#: Check: differentiating the antiderivative returns the original function.
Derivate{x^3/3 @ x}
