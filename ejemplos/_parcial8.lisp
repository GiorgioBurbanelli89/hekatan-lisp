# Derivadas parciales
## Con una sola variable solo hay una forma de derivar, y se escribe con una d normal.
d_1 = Diff{3·x^2 @ x}
## Pero en dos dimensiones hay dos variables, y hay que decir respecto a cuál se deriva. La otra se queda QUIETA, como si fuera un número.
p_x = Partial{3·x^2·y @ x}
## Mira lo que pasó: se derivó la equis, y la ye salió intacta.
p_y = Partial{3·x^2·y @ y}
## Y al revés: se derivó la ye, y la equis quedó tal cual, elevada al cuadrado.
## Por eso el símbolo cambia: la d recta se vuelve una d curva.
