# El peso: el ancho que le toca a cada punto
## Todo empieza en el rectángulo: su área es la base por la altura.
A_rect = b·h
## Bajo una curva ponemos rectángulos. La altura es el valor de la función y la base es el peso.
A_1 = f_1·w_1
## Con dos puntos, el área total es la suma de los dos rectángulos.
A = f_1·w_1 + f_2·w_2
## Si repartimos el tramo en pedazos iguales, cada peso es el largo del tramo dividido para el número de pedazos.
w_igual = L/n
## Los pesos son anchos, así que sumados tienen que dar el largo del tramo. En el tramo natural ese largo vale dos.
largo = Integral{1 @ xi = -1:1}
suma = w_1 + w_2 = 2
## Los dos puntos son simétricos, o sea que a cada uno le toca la mitad: el peso de cada uno vale uno.
w_g = 2/2
## La prueba: con una función que vale uno en todas partes, la fórmula tiene que devolver el largo del tramo.
prueba = 1·1 + 1·1
## En el elemento real el tramo no mide dos, así que el peso se estira con el Jacobiano.
J = L/2
w_real = w·L/2
