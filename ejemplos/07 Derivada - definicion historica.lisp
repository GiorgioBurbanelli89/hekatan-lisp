# La derivada: de la secante a la tangente
#: La derivada nació en el siglo XVII (Newton y Leibniz) con el problema de la **tangente**. Se traza la recta **secante** que corta la curva en dos puntos, x y x + h, y se acerca un punto al otro: cuando h tiende a 0, la secante se vuelve tangente y su pendiente es la derivada.

## 1 · La pendiente de la secante
f(x) = x^2
#: Entre x = 1 y x = 1 + h la pendiente de la secante es (f(1 + h) − f(1))/h:
m_s = Simplify{((1 + h)^2 - 1^2)/h}
#: Sale 2 + h: depende de h. Con h = 1 vale 3; con h = 0.1 vale 2.1.

## 2 · El límite: la tangente
m_t = Limit{((1 + h)^2 - 1)/h @ h = 0}
#: La animación achica h = 1/n (n = 1 … 12): la secante gira hasta coincidir con la tangente en el punto (1, 1).
#anim fplot(f = x^2, secante = 1 + (2 + 1/n)*(x - 1), tangente = 1 + 2*(x - 1), [-1 3]), n = 1:12

## 3 · La regla que sale del límite
#: Lo mismo en cualquier x da la derivada:
Limit{((x + h)^2 - x^2)/h @ h = 0}
Derivate{x^2 @ x}
Slope{x^2 @ x = 1}
