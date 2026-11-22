# The integral: area as the limit of a sum
#: The integral was born from the problem of the **area** under a curve (Riemann, 19th century). The interval [a, b] is split into n strips of width Δx = (b − a)/n, the rectangles f(x_i)·Δx are added, and n is made to grow: the sum tends to the exact area.

## 1 · The exact area
f(x) = x^2
Area{x^2 @ x = 0 : 1}

## 2 · The Riemann sum
#: With n strips of width 1/n and the height of f at the **left** edge of each strip, x_i = i/n with i = 0 … n − 1, each rectangle lies **below** the parabola (f increases) and measures (i/n)²·(1/n) = i²/n³. The sum of the i² comes from the closed formula:
Sum{i^2 @ i = 1 : n}
#: Up to n − 1 and divided by n³ it gives the lower Riemann sum: S = (n − 1)·n·(2n − 1)/(6n³) = (2n³ − 3n² + n)/(6n³), always smaller than the area.
#: The animation raises the number of strips from 2 to 16: the rectangles fill the area under the parabola and the gap left over shrinks.
#anim(k = 2:16)
#autolisp("Lower sum with {k} rectangles", ancho = 120, alto = 95, exporta = S)
(capa "RECTANGULOS" :color 30)
(setq h (/ 1.0 k) S 0.0 i 0)
(repeat k
  (setq x (* i h) y (* x x))
  (if (> y 0) (achurado (list (list x 0) (list (+ x h) 0) (list (+ x h) y) (list x y)) :color 30 :transparencia 0.45))
  (if (> y 0) (rect (list x 0) h y :color 30))
  (setq S (+ S (* h y)) i (1+ i)))
(capa "PARABOLA" :color 5)
(curva '(expt x 2) 0 1 :color 5 :grosor 0.5)
(formula '(0.05 0.85) S :nombre "S" :altura 0.06)
(formula '(0.05 0.75) (/ 1.0 3) :nombre "A_exacta" :altura 0.06)
(ejes 0 1 0 1 :paso-x 0.25 :paso-y 0.25)
#fin
#voz: Con {k} rectángulos la suma inferior vale @{S}; el área exacta es un tercio.
#finanim

## 3 · The limit
#: When n → ∞ the sum tends to the exact area:
Limit{(2*n^3 - 3*n^2 + n)/(6*n^3) @ n = inf}
#: What is missing with n strips is 1/3 − S = 1/(2n) − 1/(6n²): it is halved each time n doubles.
