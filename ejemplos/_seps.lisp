# Los tres separadores
## IGUAL: los dos lados valen lo mismo, exacto
i_1 = Simplify{(x + 1)^2 - x^2 - 1}
i_2 = Integral{x^2 @ x = 0 : 1}

## APROXIMADO: el valor va redondeado, ya no es exacto
a_1 = dec(1/3, 3)
a_2 = dec(Integral{x^2 @ x = 0 : 1}, 4)

## FLECHA: no es una igualdad, es un DESPEJE. A la izquierda una ecuación, a la derecha lo que sale de ella
f_1 = Despejar{a·x = b @ x}
f_2 = Despejar{q·L/2 - q·x = 0 @ x}
f_3 = Despejar{x^2 - 5·x + 6 = 0 @ x}
