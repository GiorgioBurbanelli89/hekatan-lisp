# La matriz constitutiva: la que traduce deformación en esfuerzo
## Antes de entrar en membrana, placa o cáscara hay que tener clara una sola cosa: la matriz que traduce lo que se estira en lo que aguanta.
## En UNA dimensión eso es la ley de Hooke, y no es una matriz: es un número. El esfuerzo es el módulo por la deformación.
s_1D = E·eps
## En DOS dimensiones ya no basta un número, porque al estirar en una dirección el material se ENCOGE en la otra. Eso es el coeficiente de Poisson.
## Lo natural es escribirlo al revés: dada la tensión, cuánto se deforma. Ésta es la matriz de FLEXIBILIDAD, con el módulo sacado fuera.
S = [1, -0.15, 0; -0.15, 1, 0; 0, 0, 2.3]
## Cada fila dice cuánto se deforma en una dirección por culpa de las dos tensiones. El menos de fuera de la diagonal ES el efecto Poisson.
## Y la constitutiva es su INVERSA: dada la deformación, cuánto esfuerzo aparece.
D = S^-1
## Se comprueba que la inversa es la buena: por la original tiene que dar la identidad.
chk = S·D
## Los números que salen tienen nombre. El de la diagonal es uno partido por uno menos Poisson al cuadrado.
f_11 = 400/391
## El de fuera de la diagonal es ése por Poisson: es el ACOPLE entre las dos direcciones.
f_12 = 60/391
## Y el de la esquina es el cortante, que NO se acopla con nada.
f_33 = 10/23
## Con el módulo del hormigón del ejemplo, en kilonewton por metro cuadrado.
E_c = 35000000
D_11 = 35000000·400/391
D_12 = 35000000·60/391
## Y ésta es la forma en que se escribe siempre: el módulo fuera, la forma dentro.
D_f = [1, 0.15, 0; 0.15, 1, 0; 0, 0, 0.425]
## De aquí salen las tres de la cáscara sin cambiar la forma: sólo cambia lo que multiplica.
## Para la MEMBRANA, el espesor.
A_m = 0.1
## Para la FLEXIÓN, el espesor al cubo partido para doce. En centímetros, para que salgan enteros.
I_f = 10^3/12
## Y para el cortante transversal, el espesor por cinco sextos.
S_c = 5/6·10
