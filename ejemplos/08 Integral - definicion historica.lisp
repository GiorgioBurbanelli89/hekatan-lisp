# La integral: el área como límite de una suma
#: La integral nació del problema del **área** bajo una curva (Riemann, siglo XIX). Se parte el intervalo [a, b] en n franjas de ancho Δx = (b − a)/n, se suman los rectángulos f(x_i)·Δx y se hace crecer n: la suma tiende al área exacta.

## 1 · El área exacta
f(x) = x^2
Area{x^2 @ x = 0 : 1}

## 2 · La suma de Riemann
#: Con n franjas de ancho 1/n y la altura de f en el borde **izquierdo** de cada franja, x_i = i/n con i = 0 … n − 1, cada rectángulo queda **debajo** de la parábola (f crece) y mide (i/n)²·(1/n) = i²/n³. La suma de los i² sale con la fórmula cerrada:
Sum{i^2 @ i = 1 : n}
#: Hasta n − 1 y dividida por n³ da la suma inferior de Riemann: S = (n − 1)·n·(2n − 1)/(6n³) = (2n³ − 3n² + n)/(6n³), siempre menor que el área.
#: La animación sube el número de franjas de 2 a 16: los rectángulos llenan el área bajo la parábola y el hueco que queda se achica.
#anim(k = 2:16)
#autolisp("Suma inferior con {k} rectángulos", ancho = 120, alto = 95, exporta = S)
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

## 3 · El límite
#: Cuando n → ∞ la suma tiende al área exacta:
Limit{(2*n^3 - 3*n^2 + n)/(6*n^3) @ n = inf}
#: Lo que falta con n franjas es 1/3 − S = 1/(2n) − 1/(6n²): se divide a la mitad cada vez que n se duplica.
