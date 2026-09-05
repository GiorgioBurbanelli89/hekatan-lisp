# De las funciones de forma a la matriz: la doble integral
## Cada formulación interpola lo suyo, y por eso necesita un número distinto de términos.
## La MEMBRANA tiene dos grados por nudo, y cuatro nudos: ocho.
n_mem = 4·2
## Sus funciones son las bilineales, y su deformación es la primera derivada parcial.
e_x = Partial{(1-xi)·(1-eta)/4 @ xi}
## SHELL-THIN, la de Kirchhoff, tiene tres grados por nudo: doce.
n_thin = 4·3
## Y como solo interpola la flecha, necesita doce términos en un único polinomio, y llega hasta grado tres en cada dirección.
## Su curvatura es la segunda derivada parcial de ese polinomio.
k_x = Partial{Partial{x^3·y @ x} @ x}
## SHELL-THICK, la de Mindlin, también tiene doce grados, pero repartidos en TRES campos de cuatro.
n_thick = 3·4
## Cada campo con las mismas bilineales, y solo hace falta la primera derivada.
k_m = Partial{(1-xi)·(1-eta)/4·th_1 @ xi}
## Y ahora lo que las une a las tres: la matriz de rigidez es una DOBLE integral sobre el cuadrado patrón.
## Se integra en las dos coordenadas, y dentro va el jacobiano del capítulo ocho.
I_d = Area{Area{xi^2·eta^2 @ xi=-1:1} @ eta=-1:1}
## Cuatro novenos. Y por partes sale lo mismo: primero una coordenada, después la otra.
I_1 = Area{xi^2 @ xi=-1:1}
I_2 = Area{(2/3)·eta^2 @ eta=-1:1}
## Y el programa no integra: SUMA en los cuatro puntos de Gauss, con el peso de cada uno.
S_g = 1·(1/3)·(1/3) + 1·(1/3)·(1/3) + 1·(1/3)·(1/3) + 1·(1/3)·(1/3)
## El mismo número. La doble integral y la doble suma de Gauss dan lo mismo, y por eso el programa puede sumar en vez de integrar.
