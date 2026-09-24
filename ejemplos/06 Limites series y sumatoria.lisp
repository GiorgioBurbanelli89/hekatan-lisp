# Límites, series de Taylor y sumatorias
#: La derivada es un límite, la integral es el límite de una suma y una función se aproxima con un polinomio: las tres ideas con el motor.

## 1 · La derivada por definición
#: f′(x) = lím (f(x + h) − f(x))/h cuando h → 0. El motor sustituye h = 0, encuentra 0/0 y aplica L'Hôpital:
Limit{((x + h)^2 - x^2)/h @ h = 0}
Limit{((x + h)^3 - x^3)/h @ h = 0}

## 2 · Límites de la forma 0/0
Limit{sin(x)/x @ x = 0}
Limit{(x^2 - 1)/(x - 1) @ x = 1}

## 3 · Sumatorias
Sum{i @ i = 1 : 100}
Sum{i^2 @ i = 1 : 4}
#: Con el límite superior como letra, el motor da la fórmula cerrada (Faulhaber):
Sum{i @ i = 1 : n}

## 4 · Series de Taylor alrededor de 0
#: El polinomio de Taylor de grado n usa las derivadas en 0: f(0) + f′(0)·x + f″(0)·x²/2! + …
Taylor{sin(x) @ x = 0 : 7}
Taylor{exp(x) @ x = 0 : 4}
Taylor{cos(x) @ x = 0 : 6}
#: Cerca de 0 el polinomio de grado 7 y el seno no se distinguen; lejos, se separan:
#fplot(sin(x), T_7 = x - x^3/6 + x^5/120 - x^7/5040, [-4 4])
