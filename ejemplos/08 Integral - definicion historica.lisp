# La integral: el área como límite de una suma
#: La integral nació del problema del **área** bajo una curva (Riemann, siglo XIX). Se parte el intervalo [a, b] en n franjas de ancho Δx = (b − a)/n, se suman los rectángulos f(x_i)·Δx y se hace crecer n: la suma tiende al área exacta.

## 1 · El área exacta
f(x) = x^2
Area{x^2 @ x = 0 : 1}

## 2 · La suma de Riemann
#: Con n franjas de ancho 1/n y altura f en el borde derecho de cada franja, x_i = i/n, cada rectángulo mide (i/n)²·(1/n) = i²/n³. La suma de los i² sale con la fórmula cerrada:
Sum{i^2 @ i = 1 : n}
#: Dividida por n³ da la suma de Riemann: S = (2n³ + 3n² + n)/(6n³).
#: La animación sube n de 1 a 16: los escalones se pegan a la parábola y el área que sobra se achica.
#anim fplot(f = x^2, rectangulos = ((floor(n*x) + 1)/n)^2, [0 0.999]), n = 1:16

## 3 · El límite
#: Cuando n → ∞ la suma tiende al área exacta:
Limit{(2*n^3 + 3*n^2 + n)/(6*n^3) @ n = inf}
#: Lo que sobra con n franjas es S − 1/3 = 1/(2n) + 1/(6n²): se divide a la mitad cada vez que n se duplica.
