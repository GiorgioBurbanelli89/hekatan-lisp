# La cuadratura de Gauss en dos dimensiones
## En una dimensión ya lo vimos: con dos puntos bien elegidos se integra exacto hasta grado tres. Los puntos eran estos.
g_1 = -1/sqrt(3)
g_2 = 1/sqrt(3)
## Y en dos dimensiones no hay que inventar nada: se integra primero en una coordenada y después en la otra.
## Eso da cuatro puntos, uno por cada combinación, y su peso es el producto de los dos pesos de una dimensión.
w_1 = 1·1
n_pun = 2·2
## Primera comprobación: el área del cuadrado patrón. Va de menos uno a uno en las dos, así que mide dos por dos.
A_pat = 1 + 1 + 1 + 1
## Segunda comprobación, con un polinomio de verdad. Su integral exacta en una dimensión es esta.
I_1D = Area{xi^2 @ xi=-1:1}
## Y en dos dimensiones, el producto de las dos.
I_ex = 2/3·2/3
## Ahora con Gauss: en cada punto la coordenada al cuadrado vale un tercio, y hay cuatro puntos de peso uno.
I_ga = 4·(1/3)·(1/3)
## Cuatro novenos los dos. Exacto, no aproximado.
## Y lo que hace falta de verdad: el área del elemento real. Se suma el Jacobiano en los cuatro puntos.
A_real = 1·6 + 1·6 + 1·6 + 1·6
## Veinticuatro, que es seis por cuatro. El mismo resultado del capítulo anterior, pero ahora sumando en cuatro puntos.
## ¿Y por qué dos por dos y no más? Porque la rigidez de este elemento es de grado dos en cada dirección, y dos puntos la integran exacta.
grado = 2·2 - 1
