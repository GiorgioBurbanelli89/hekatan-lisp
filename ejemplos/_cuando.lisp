# Cuándo se deriva en ingeniería
## La pendiente de una recta: lo mismo de siempre
p_rec = Diff{m·x + b @ x}

## La DEFORMACIÓN UNITARIA
eps_u = epsilon = du/dx

## La VELOCIDAD y la ACELERACIÓN de un nudo bajo sismo
v_sis = du/dt
a_sis = d2u/dt2

## El GRADIENTE hidráulico en el terreno
i_hid = dh/dx

## Las dos leyes de la pieza a flexión
ley_V = dV/dx = -q
ley_M = dM/dx = V

## El segundo uso: el MÁXIMO. La derivada se anula en el extremo.
con_max = dM/dx = 0

## Y como dM/dx es el cortante, el momento es máximo donde el cortante SE ANULA
cor_x = q·L/2 - q·x

## Se despeja la abscisa
abs_m = Despejar{q·L/2 - q·x = 0 @ x}

## Y el momento en esa sección
M_max = Simplify{q·L/2·(L/2) - q·(L/2)^2/2}

## Igual con la flecha: máxima donde el giro se anula
con_w = dw/dx = theta = 0
