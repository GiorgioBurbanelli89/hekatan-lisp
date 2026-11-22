# Limits, Taylor series and summations
#: The derivative is a limit, the integral is the limit of a sum and a function is approximated by a polynomial: the three ideas with the engine.

## 1 · The derivative by definition
#: f′(x) = lim (f(x + h) − f(x))/h as h → 0. The engine substitutes h = 0, finds 0/0 and applies L'Hôpital:
Limit{((x + h)^2 - x^2)/h @ h = 0}
Limit{((x + h)^3 - x^3)/h @ h = 0}

## 2 · Limits of the form 0/0
Limit{sin(x)/x @ x = 0}
Limit{(x^2 - 1)/(x - 1) @ x = 1}
Limit{(1 - cos(x))/x^2 @ x = 0}
#: Toward infinity the highest-degree term dominates:
Limit{(3*x^2 + 1)/(x^2 + 5) @ x = inf}

## 3 · Summations
Sum{i @ i = 1 : 100}
Sum{i^2 @ i = 1 : 4}
#: With the upper limit as a letter, the engine gives the closed formula (Faulhaber):
Sum{i @ i = 1 : n}

## 4 · Taylor series around 0
#: The Taylor polynomial of degree n uses the derivatives at 0: f(0) + f′(0)·x + f″(0)·x²/2! + …
Taylor{sin(x) @ x = 0 : 7}
Taylor{exp(x) @ x = 0 : 4}
Taylor{cos(x) @ x = 0 : 6}
Taylor{ln(1 + x) @ x = 0 : 4}
Taylor{1/(1 - x) @ x = 0 : 4}
#: Near 0 the degree-7 polynomial and the sine are indistinguishable; farther away, they separate:
#fplot(sin(x), T_7 = x - x^3/6 + x^5/120 - x^7/5040, [-4 4])
