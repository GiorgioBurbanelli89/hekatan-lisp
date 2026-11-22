# Funciones de forma cuadráticas: deducirlas y graficarlas
#: Un elemento de 3 nudos, en x = −1, 0 y 1. La función de forma de cada nudo vale **1 en su nudo y 0 en los otros dos**. Se construye con el producto de Lagrange: se multiplica por (x − x_j) para cada nudo j distinto y se divide por el mismo producto evaluado en el propio nudo.

## 1 · Las tres funciones
N_1 = Expand{(x - 0)*(x - 1)/((-1 - 0)*(-1 - 1))}
N_2 = Expand{(x + 1)*(x - 1)/((0 + 1)*(0 - 1))}
N_3 = Expand{(x + 1)*(x - 0)/((1 + 1)*(1 - 0))}

## 2 · Lo que garantizan
#: Suman 1 en cualquier punto (partición de la unidad): un desplazamiento de sólido rígido se reproduce sin deformación.
Simplify{N_1 + N_2 + N_3}

## 3 · La gráfica
#: Cada curva sube a 1 en su nudo y cruza el cero en los otros dos:
#fplot(N_1 = x^2/2 - x/2, N_2 = 1 - x^2, N_3 = x^2/2 + x/2, [-1 1])
