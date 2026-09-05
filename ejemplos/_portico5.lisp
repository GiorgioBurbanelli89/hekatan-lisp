# La barra en el espacio: la matriz de doce por doce
## En el plano cada nudo hacía tres cosas. En el espacio hace SEIS: se corre en tres direcciones y gira alrededor de tres ejes.
gdl_nudo = 6
## Y la barra, que toca dos nudos, tiene doce grados de libertad y una matriz de doce por doce.
gdl_barra = 2·6
tam = 12·12
## Dentro de la barra ya no hay dos físicas, hay CUATRO, y siguen sin mezclarse.
## La primera, ESTIRARSE, ya la dedujimos: el desplazamiento va en línea recta de una punta a la otra.
N_1 = (1 - xi)/2
dN_dx = -1/L
k_ax = EA·Area{(1/L)^2·(L/2) @ xi=-1:1}
## La segunda es RETORCERSE, y es el mismo problema pero de giros: el ángulo también va en línea recta, así que la función de forma es la misma recta.
k_tor = GJ·Area{(1/L)^2·(L/2) @ xi=-1:1}
## La torsión es el axial de los giros: donde había área por módulo, ahora hay rigidez a torsión.
## La tercera y la cuarta son DOBLARSE, una en cada plano. Cada una usa las cuatro Hermite y su propia inercia.
kap_1 = Partial{Partial{1 - 3·x^2 + 2·x^3 @ x} @ x}
k_vv = EIz·Area{(-6+12·x)^2 @ x=0:1}
k_ww = EIy·Area{(-6+12·x)^2 @ x=0:1}
## Y ahora la cuenta cierra: dos grados del axial, dos de la torsión, cuatro de cada flexión.
cuenta = 2 + 2 + 4 + 4
## Doce. Ni uno de más ni uno de menos: cada grado de libertad de la barra pertenece a una sola física.
