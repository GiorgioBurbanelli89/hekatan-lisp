# La cuadratura de Gauss, deducida y hecha
## En el capítulo anterior quedó que todo el cálculo se hace en el tramo patrón, de menos uno a más uno. Y quedó una pregunta: ¿por qué justo ahí?
## Porque ahí está definida la cuadratura de Gauss. Y la cuadratura es esto: cambiar una integral por una SUMA.
regla = Integral{f @ xi} = w_1·f_1 + w_2·f_2
## Se evalúa la función en unos pocos puntos, se multiplica cada valor por su peso, y se suman. Nada más.
## Antes de Gauss se usaba la regla del trapecio: los puntos CLAVADOS en los extremos, y solo los pesos libres.
libres_trapecio = 0 + 2
## Con dos números libres solo se pueden exigir dos condiciones: acierta hasta las rectas y ahí se acaba.
## Gauss suelta los puntos: si también son incógnitas, hay CUATRO números libres.
libres_gauss = 2 + 2
## Y cada número libre permite exigir una condición. El doble de libertad, el doble de grado.
## Las cuatro condiciones: que la suma dé el área EXACTA de los cuatro ladrillos con los que se arma cualquier curva.
c_1 = w_1 + w_2 = 2
c_2 = w_1·xi_1 + w_2·xi_2 = 0
c_3 = w_1·xi_1^2 + w_2·xi_2^2 = 2/3
c_4 = w_1·xi_1^3 + w_2·xi_2^3 = 0
## Nadie SUPONE que los puntos sean simétricos: sale solo. A la cuarta condición se le resta la segunda multiplicada por el primer punto al cuadrado.
paso_1 = w_2·xi_2·(xi_2^2 - xi_1^2) = 0
## Ni el peso ni el punto pueden valer cero, así que lo que se anula es el paréntesis.
paso_2 = xi_2 = -xi_1
## Con eso la segunda condición dice que los pesos son iguales, y la primera que valen uno.
paso_3 = w_1 = w_2 = 1
## Y recién ahí la tercera condición entrega el número.
paso_4 = 2·xi_1^2 = 2/3
sol = sqrt(1/3)
## Ahora la cuenta de verdad, con la curvatura de la primera función de forma, que es la que arma la matriz de rigidez.
H1pp = Diff{-6·x + 6·x^2 @ x}
## Pasada al tramo patrón queda limpia.
H1pp_nat = Expand{-6 + 12·(1 + xi)/2}
## Y el Jacobiano del capítulo anterior, para un tramo de largo uno, vale un medio.
jac = J = 1/2
## Lo que hay que integrar es el cuadrado de esa curvatura por el Jacobiano.
integrando = (6·xi)^2·(1/2)
## La integral exacta, hecha a mano, da doce.
exacta = Area{18·xi^2 @ xi=-1:1}
## Y ahora LA SUMA de Gauss: dos puntos, los dos pesos valen uno, y cada punto al cuadrado vale un tercio.
gauss = 18·(1/3) + 18·(1/3)
## Doce contra doce. No aproxima: acierta exacto.
## Con la pareja de la primera y la segunda función pasa lo mismo.
prod = 6·xi·(-1 + 3·xi)·(1/2)
exacta_12 = Area{-3·xi + 9·xi^2 @ xi=-1:1}
gauss_12 = (-3/sqrt(3) + 9/3) + (3/sqrt(3) + 9/3)
## Seis y seis. Y ese doce y ese seis son los de la matriz de rigidez de la viga.
K_barra = [12, 6, -12, 6; 6, 4, -6, 2; -12, -6, 12, -6; 6, 2, -6, 4]
## La prueba de que es una LEY y no una casualidad: con xi a la cuarta ya falla.
exacta_4 = Area{xi^4 @ xi=-1:1}
gauss_4 = (1/3)^2 + (1/3)^2
## Dos quintos contra dos novenos. Falla justo donde tenía que fallar: en el grado cuatro.
ley = 2·n - 1
