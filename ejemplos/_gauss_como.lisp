# ¿Cómo supo Gauss que son ±1/√3? No fue suerte: fue contar
## Dos puntos y dos pesos son cuatro números libres. Con cuatro libres se pueden pedir cuatro condiciones.
libres = 2 + 2
## La regla vieja fija los puntos de antemano, así que solo le quedan libres los dos pesos: dos condiciones.
libres_vieja = 0 + 2
## Las cuatro condiciones son: que la fórmula dé el área exacta para uno, para xi, para xi al cuadrado y para xi al cubo.
c1 = w_1 + w_2 = 2
c2 = w_1·xi_1 + w_2·xi_2 = 0
c3 = w_1·xi_1^2 + w_2·xi_2^2 = 2/3
c4 = w_1·xi_1^3 + w_2·xi_2^3 = 0
## Nadie SUPONE que los puntos sean simétricos. Sale solo. A la cuarta condición le restamos la segunda multiplicada por el primer punto al cuadrado.
paso_1 = w_2·xi_2·(xi_2^2 - xi_1^2) = 0
## Ni el peso ni el punto pueden valer cero, así que lo que se anula es el paréntesis.
paso_2 = xi_2 = -xi_1
## Con eso la segunda condición dice que los dos pesos son iguales, y la primera dice que valen uno.
paso_3 = w_1 = w_2 = 1
## Y recién ahí la tercera condición entrega el número.
paso_4 = 2·xi_1^2 = 2/3
sol = sqrt(1/3)
## La comprobación honesta: con xi a la cuarta, que ya es grado cuatro, la fórmula falla.
exacta_4 = Integral{xi^4 @ xi = -1:1}
gauss_4 = (1/3)^2 + (1/3)^2
## La ley: n puntos dan 2n números libres, y por eso salen exactas hasta el grado 2n menos uno.
ley = 2·n - 1
