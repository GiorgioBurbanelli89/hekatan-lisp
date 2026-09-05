# Cómo se ARMA la matriz de rigidez de una membrana
## El elemento tiene ocho grados de libertad, y hay que ponerlos EN ORDEN. Dos por nudo, y los nudos en sentido antihorario.
d_e = [u_1; v_1; u_2; v_2; u_3; v_3; u_4; v_4]
## Y las deformaciones son TRES: el estiramiento en cada dirección y la distorsión.
eps = [e_x; e_y; g_xy]
## Así que hace falta una matriz que convierta ocho números en tres: es de TRES filas por OCHO columnas. Se llama B.
n_fil = 3
n_col = 8
## Cada FILA de B es una deformación, y cada COLUMNA es un grado de libertad. Ése es todo el secreto.
## La primera fila: el estiramiento en x sólo depende de los desplazamientos en x, así que las columnas de v van a CERO.
B_1 = [n1x, 0, n2x, 0, n3x, 0, n4x, 0]
## La segunda: el estiramiento en y sólo depende de los de y, y ahora los ceros están al revés.
B_2 = [0, n1y, 0, n2y, 0, n3y, 0, n4y]
## Y la tercera, la distorsión, depende de LAS DOS: no tiene ni un cero.
B_3 = [n1y, n1x, n2y, n2x, n3y, n3x, n4y, n4x]
## Con esas tres filas, la rigidez es la B transpuesta por la constitutiva por la B, integrada.
## Y ojo con los tamaños, que es lo que hace que salga cuadrada: ocho por tres, por tres por tres, por tres por ocho.
t_1 = 8·3
t_2 = 3·3
t_3 = 3·8
## El resultado es de ocho por ocho: la matriz del elemento.
t_K = 8·8
## Veamos UN término, el primero. Es la primera columna de B, transpuesta, por la constitutiva, por la primera columna.
## Sólo sobreviven dos productos: el de la fila axial y el de la fila de distorsión.
## Para un elemento de un metro por un metro, las dos derivadas de la primera función valen esto.
n_1x = -(1-eta)/2
n_1y = -(1-xi)/2
## Y sus dos integrales, por simetría, valen lo mismo: un tercio.
I_a = Area{Area{((1-eta)/2)^2·(1/4) @ xi=-1:1} @ eta=-1:1}
I_b = Area{Area{((1-xi)/2)^2·(1/4) @ xi=-1:1} @ eta=-1:1}
## Así que el término, en símbolos, es un tercio de la suma de dos constitutivas: la axial y la de cortante.
k_sim = (Da + Dc)/3
## Y ahora los números. La axial ya la teníamos, en toneladas por metro.
D_ax = 365115
## Y la de cortante es la axial por el término de la esquina.
D_co = 365115·0.425
## Sumadas y partidas para tres.
k_11 = (365115 + 155174)/3
## Ése es UN término de los sesenta y cuatro. Los demás salen igual, cambiando qué columna de B se usa.
