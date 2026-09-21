# El pórtico plano: la matriz de rigidez de una barra
## Con lo de los capítulos anteriores ya alcanza: las funciones de forma, el Jacobiano y la cuadratura de Gauss. Ahora se arma la matriz de una barra entera.
## En un pórtico plano cada nudo puede hacer tres cosas: correrse en horizontal, correrse en vertical, y girar.
gdl_nudo = 3
## Cada barra toca dos nudos, así que tiene seis grados de libertad y su matriz es de seis por seis.
gdl_barra = 2·3
tam = 6·6
## Dentro de la barra hay dos físicas que no se mezclan: estirarse a lo largo, y doblarse.
## Para ESTIRARSE hay dos grados: cuánto se corre cada punta. Con dos datos la función de forma es una recta, y son las del tramo patrón.
N_1 = (1 - xi)/2
N_2 = (1 + xi)/2
## Su derivada respecto al patrón es esta.
dN_pat = Partial{(1 - xi)/2 @ xi}
## Y para pasarla a la barra real se divide por el Jacobiano, que es el largo partido para dos. Queda menos uno partido para el largo.
dN_real = dN_dx = -1/L
## La rigidez axial es la integral de esa derivada al cuadrado por la rigidez del material. Y se integra en el tramo patrón, multiplicando por el Jacobiano, tal como quedó en el capítulo dos.
k_axial = EA·Area{(1/L)^2·(L/2) @ xi=-1:1}
## Sale la rigidez de un resorte: área por módulo, partido para el largo.
## Para DOBLARSE hay cuatro grados: cuánto baja y cuánto gira cada punta. Ahí van las cuatro funciones de forma del capítulo uno.
## Sus curvaturas son las segundas derivadas, y de integrar los productos salen los números de la flexión.
k_11 = Area{(-6+12·x)^2 @ x=0:1}
k_12 = Area{(-6+12·x)·(-4+6·x) @ x=0:1}
k_22 = Area{(-4+6·x)^2 @ x=0:1}
## Con eso ya se arma la matriz de la barra en sus propios ejes. El orden de los grados es: se corre, baja y gira, en cada punta.
K_local = [1, 0, 0, -1, 0, 0; 0, 12, 6, 0, -12, 6; 0, 6, 4, 0, -6, 2; -1, 0, 0, 1, 0, 0; 0, -12, -6, 0, 12, -6; 0, 6, 2, 0, -6, 4]
## Fíjate en los ceros: el estirarse y el doblarse no se hablan. Son dos bloques separados dentro de la misma matriz.
## Pero esa matriz está en los ejes de la BARRA, y el pórtico se resuelve en los ejes del edificio. Hay que girarla.
Rot_giro = [c, s, 0; -s, c, 0; 0, 0, 1]
## En una columna la barra está de pie: el coseno vale cero y el seno vale uno.
Rot_col = [0, 1, 0; -1, 0, 0; 0, 0, 1]
## Y la matriz girada es la transpuesta del giro, por la matriz, por el giro.
K_giro = transpose(Rot_col)·[1, 0, 0; 0, 12, 6; 0, 6, 4]·Rot_col
## Mira lo que pasó: la rigidez de estirarse, que en la barra estaba en el primer sitio, en el edificio pasó al segundo. Por eso una columna aguanta el peso en vertical.
## Y ya en ejes del edificio se ENSAMBLA: en cada nudo se suman las barras que llegan.
k_BB = 4 + 4
k_DD = 12 + 12
K_portico = [8, 2, -6; 2, 8, -6; -6, -6, 24]
## Funciones de forma, integrar con Gauss, girar y sumar. No hay ningún dato mágico en toda la cadena.
