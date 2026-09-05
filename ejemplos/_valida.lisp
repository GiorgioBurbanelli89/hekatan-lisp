# La prueba: el programa contra la solución analítica
## La losa apoyada en los cuatro bordes tiene solución exacta, la serie de Navier. Se compara punto por punto.
## En el CENTRO, el programa da esta flecha en milímetros.
w_fem = 1.13801
## Y la serie analítica, esta.
w_nav = 1.13895
## La diferencia.
dif_c = (1.13801/1.13895 - 1)·100
## Menos de una décima de por ciento.
## En un punto INTERIOR cualquiera, a un cuarto de cada lado.
i_fem = 0.60646
i_nav = 0.60724
dif_i = (0.60646/0.60724 - 1)·100
## En el BORDE y en la ESQUINA los dos dan cero, porque ahí la losa está apoyada.
w_bor = 0
w_esq = 0
## Y los momentos analíticos en el centro: el de la dirección corta es casi el doble.
M_11 = 6.8106
M_22 = 12.5373
raz = 12.5373/6.8106
