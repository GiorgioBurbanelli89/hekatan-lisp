# Los ajustes de una barra en ETABS
## Los ocho modificadores no cambian la matriz: multiplican, uno a uno, los términos que ya dedujimos.
k_ax = fA·EA/L
k_tor = fJ·GJ/L
k_fl = fI33·12·EIz
## El brazo rígido acorta la barra, pero SOLO para la flexión y el cortante.
L_f = L - rz·(off_I + off_J)
## El axil y la torsión siguen con el largo completo: eso lo dice el propio binario de ETABS.
## Y los releases se resuelven condensando: se quita la fila y la columna del grado liberado, y su efecto se reparte en las que quedan.
K_c = K_rr - K_rf·K_ff^-1·K_fr
## Míralo con la flexión de una barra: en la diagonal hay cuatro y fuera dos.
K_ej = [4, 2; 2, 4]
## Si se libera el giro de un extremo, la rigidez del otro queda así.
Kc = 4 - 2·(1/4)·2
## De cuatro pasa a tres: aparece el tres E I partido para L del extremo articulado, que sale solo de la condensación.
## Y en una viga con carga en el centro, la flecha pasa de una a la otra.
razon = (1/48)/(1/192)
