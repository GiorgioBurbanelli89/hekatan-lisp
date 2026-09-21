# De las diferencias finitas al segundo momento de área
#: Primero se suman trozos FINITOS. Al afinarlos, la suma converge. Ese límite es la integral.

## DIFERENCIA FINITA: la sección en 4 franjas, cada una aporta y²·ΔA
S_4 = dec(((3/8)^2 + (1/8)^2 + (1/8)^2 + (3/8)^2)/4, 5)

## Se afina a 8 franjas
S_8 = dec(2·((7/16)^2 + (5/16)^2 + (3/16)^2 + (1/16)^2)/8, 5)

## Y a 16
S_16 = dec(2·((15/32)^2+(13/32)^2+(11/32)^2+(9/32)^2+(7/32)^2+(5/32)^2+(3/32)^2+(1/32)^2)/16, 5)

## En el LÍMITE, Δ pasa a d y la suma pasa a integral
I_lim = Integral{y^2 @ y = -1/2 : 1/2}
I_dec = dec(Integral{y^2 @ y = -1/2 : 1/2}, 5)

## Lo que se equivocaba cada suma
e_4 = dec((0.07812 - 1/12)/(1/12)·100, 2)
e_8 = dec((0.08203 - 1/12)/(1/12)·100, 2)
e_16 = dec((0.08301 - 1/12)/(1/12)·100, 2)

## Y esto es el SEGUNDO MOMENTO DE ÁREA de la sección
I_2 = Integral{b·y^2 @ y = -h/2 : h/2}
