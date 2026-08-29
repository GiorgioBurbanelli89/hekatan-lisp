# ¿Por qué se deriva y por qué se integra?
## Derivar e integrar hacen cosas opuestas, y las dos hacen falta. Derivar mira UN punto. Integrar SUMA todos los puntos.
## La función de forma dice dónde está cada punto de la barra. Pero estar en un sitio no cuesta energía. Vamos a probarlo.
## Prueba uno: toda la barra baja lo mismo, sin doblarse. La primera derivada ya da cero.
r_1 = Diff{1 @ x}
## Prueba dos: la barra gira entera, como una tabla rígida. La primera derivada es constante, y la segunda da cero.
r_2p = Diff{x @ x}
r_2pp = Diff{1 @ x}
## Prueba tres: ahora sí se curva. La segunda derivada ya no es cero.
r_3p = Diff{x^2 @ x}
r_3pp = Diff{2·x @ x}
## Por eso se deriva DOS veces: la segunda derivada borra sola los movimientos que no cuestan energía y deja el único que sí cuesta, que es doblarse. Eso es la curvatura.
def_kappa = kappa = v_pp
## Y la curvatura por la rigidez a flexión es el momento flector: la fórmula que ya conocías.
def_M = M = EI·kappa
## Con la curvatura ya sé cuánto se dobla en cada punto. Y la energía guardada en una rebanada es esta.
u_reb = EI·kappa^2/2
## Pero la energía de una sola rebanada no sirve: hace falta la de toda la barra. Para eso se integra. Integrar es sumar todas las rebanadas.
## Ahora la cuenta de verdad, con la primera función de forma. Su curvatura es esta.
H1pp = Diff{-6·x + 6·x^2 @ x}
## Se pasa al tramo patrón, el que va de menos uno a más uno, con el cambio de siempre.
mapa = x = (1 + xi)/2
## Y la curvatura queda limpia.
H1pp_nat = Expand{-6 + 12·(1 + xi)/2}
## El Jacobiano de ese cambio, para un tramo de largo uno, vale un medio.
jac = J = 1/2
## Así que lo que hay que integrar es el cuadrado de esa curvatura por el Jacobiano.
integrando = (6·xi)^2·(1/2)
## La integral exacta da doce.
exacta = Area{18·xi^2 @ xi=-1:1}
## Y ahora sí, la suma de Gauss. Dos puntos, los dos pesos valen uno, y cada punto al cuadrado vale un tercio.
gauss = 18·(1/3) + 18·(1/3)
## Doce contra doce. La suma de Gauss no aproxima nada: acierta exacto.
## Con la pareja de la primera y la segunda función de forma pasa lo mismo.
prod = 6·xi·(-1 + 3·xi)·(1/2)
exacta_12 = Area{-3·xi + 9·xi^2 @ xi=-1:1}
gauss_12 = (-3/sqrt(3) + 9/3) + (3/sqrt(3) + 9/3)
## Seis y seis. Y ese doce y ese seis son los de la matriz de rigidez de la viga.
K_barra = [12, 6, -12, 6; 6, 4, -6, 2; -12, -6, 12, -6; 6, 2, -6, 4]
