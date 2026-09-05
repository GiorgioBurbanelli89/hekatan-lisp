# Una viga apoyada, de luz L, con carga q
#: Todo en álgebra. Cada integral, con su constante, y las condiciones de apoyo al final.

## Equilibrio: la carga total se reparte entre los dos apoyos
R_a = q·L/2
R_b = q·L/2

## El CORTANTE: lo que queda de la reacción al ir avanzando
V_x = q·L/2 - q·x

## En el centro se anula: media viga a cada lado
V_c = Simplify{q·L/2 - q·L/2}

## El MOMENTO: la integral del cortante
M_x = Integral{q·L/2 - q·x @ x}

## Y en el centro da el valor de siempre
M_c = Simplify{q·L/2·(L/2) - q·(L/2)^2/2}

## El GIRO: la integral del momento, partida por la rigidez
t_x = Integral{q·L·x/2 - q·x^2/2 @ x}

## La FLECHA: una integral más
w_x = Integral{q·L·x^2/4 - q·x^3/6 @ x}

## Con las dos constantes que han ido saliendo
w_c = (q·L·x^3/12 - q·x^4/24 + C_1·x + C_2)/EI

## Los apoyos: la flecha es CERO en los dos extremos
c_2 = 0
c_1 = -q·L^3/24

## Y la flecha queda
w_f = (q·L·x^3/12 - q·x^4/24 - q·L^3·x/24)/EI

## En el centro del vano
w_m = Simplify{q·L·(L/2)^3/12 - q·(L/2)^4/24 - q·L^3·(L/2)/24}

## Que es la fórmula del prontuario
w_p = -5·q·L^4/384
