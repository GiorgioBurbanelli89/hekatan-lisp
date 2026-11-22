# The derivative: from the secant to the tangent
#: The derivative was born in the 17th century (Newton and Leibniz) from the problem of the **tangent**. You draw the **secant** line that cuts the curve at two points, x and x + h, and bring one point toward the other: when h tends to 0, the secant becomes the tangent and its slope is the derivative.

## 1 · The slope of the secant
f(x) = x^2
#: Between x = 1 and x = 1 + h the slope of the secant is (f(1 + h) − f(1))/h:
m_s = Simplify{((1 + h)^2 - 1^2)/h}
#: It comes out 2 + h: it depends on h. With h = 1 it is 3; with h = 0.1 it is 2.1.

## 2 · The limit: the tangent
m_t = Limit{((1 + h)^2 - 1)/h @ h = 0}
#: The animation shrinks h = 1/n (n = 1 … 12): the secant turns until it coincides with the tangent at the point (1, 1).
#anim fplot(f = x^2, secante = 1 + (2 + 1/n)*(x - 1), tangente = 1 + 2*(x - 1), [-1 3]), n = 1:0.1:12

## 3 · The rule that comes out of the limit
#: The same at any x gives the derivative:
Limit{((x + h)^2 - x^2)/h @ h = 0}
Derivate{x^2 @ x}
Slope{x^2 @ x = 1}
