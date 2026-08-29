# ¿Cómo supo Gauss que son ±1/√3? No fue suerte: fue contar
## La regla de antes se llama del trapecio: se unen los dos extremos con una recta y se mide el área de la figura que queda.
trapecio = (f_1 + f_2)/2·(b - a)
## En el tramo natural, que mide dos, los puntos son los extremos y los dos pesos valen uno.
trap_nat = f_1·1 + f_2·1
## Con la parábola el área de verdad es dos tercios.
real_par = Integral{xi^2 @ xi = -1:1}
## Pero el trapecio la mide desde arriba y dice dos: se pasa tres veces.
trap_par = 1·1 + 1·1
## El trapecio tiene los puntos clavados, así que solo le quedan libres los dos pesos.
libres_vieja = 0 + 2
## Gauss los suelta: dos puntos y dos pesos son cuatro números libres.
libres = 2 + 2
## Y cada número libre deja exigir una condición: que acierte el área exacta de uno, de xi, de xi al cuadrado y de xi al cubo.
c1 = w_1 + w_2 = 2
c2 = w_1·xi_1 + w_2·xi_2 = 0
c3 = w_1·xi_1^2 + w_2·xi_2^2 = 2/3
c4 = w_1·xi_1^3 + w_2·xi_2^3 = 0
## Nadie SUPONE que los puntos sean simétricos. Sale solo: a la cuarta condición le restamos la segunda multiplicada por el primer punto al cuadrado.
paso_1 = w_2·xi_2·(xi_2^2 - xi_1^2) = 0
## Ni el peso ni el punto pueden valer cero, así que lo que se anula es el paréntesis.
paso_2 = xi_2 = -xi_1
## Con eso la segunda condición dice que los pesos son iguales, y la primera dice que valen uno.
paso_3 = w_1 = w_2 = 1
## Y recién ahí la tercera condición entrega el número.
paso_4 = 2·xi_1^2 = 2/3
sol = sqrt(1/3)
## La comprobación honesta: con xi a la cuarta, que ya es grado cuatro, la fórmula falla.
exacta_4 = Integral{xi^4 @ xi = -1:1}
gauss_4 = (1/3)^2 + (1/3)^2
## La ley: n puntos dan 2n números libres, y por eso salen exactas hasta el grado 2n menos uno.
ley = 2·n - 1
