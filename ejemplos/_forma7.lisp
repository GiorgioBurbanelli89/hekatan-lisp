# Las funciones de forma en dos dimensiones
## En una dimensión el elemento era una barra con dos nudos. Aquí es un cuadrilátero con cuatro, numerados en sentido antihorario.
## Con cuatro nudos hacen falta cuatro términos: la constante, las dos coordenadas naturales, y su producto.
b = [1 xi eta xi·eta]
## La matriz de coeficientes se arma evaluando esa base en cada nudo: una fila por nudo, una columna por término.
C = [1, -1, -1, 1; 1, 1, -1, -1; 1, 1, 1, 1; 1, -1, 1, -1]
## Se invierte una sola vez, y sirve para los cuatro.
Cinv = C^-1
## Y se comprueba que la inversa es la buena.
chk = C·Cinv
## Cada nudo hace su pedido: valer uno en él, y cero en los otros tres.
e_1 = [1; 0; 0; 0]
a_1 = Cinv·e_1
N_1 = b·a_1
## El nudo dos pide lo mismo, pero en su esquina.
N_2 = b·(Cinv·[0; 1; 0; 0])
## Y el tres, y el cuatro.
N_3 = b·(Cinv·[0; 0; 1; 0])
N_4 = b·(Cinv·[0; 0; 0; 1])
## Ahora la prueba, en un punto cualquiera dentro del elemento.
q_1 = (1-0.3)·(1+0.5)/4
q_2 = (1+0.3)·(1+0.5)/4
q_3 = (1+0.3)·(1-0.5)/4
q_4 = (1-0.3)·(1-0.5)/4
## En fracciones exactas son estas, y suman uno: la condición que cumple toda función de forma.
S = 21/80 + 39/80 + 13/80 + 7/80
## Con eso ya se interpola. Si los cuatro nudos se desplazan cero, tres, cinco y uno,
## el desplazamiento del punto interior es la suma de los cuatro, cada uno pesado por su función de forma.
u_p = 0·21/80 + 3·39/80 + 5·13/80 + 1·7/80
