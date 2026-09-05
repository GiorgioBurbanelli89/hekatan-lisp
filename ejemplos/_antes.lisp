# Cómo se calculaba antes de los elementos finitos
#: Con fórmulas de catálogo y series. Servían, pero solo para los casos del catálogo.

## La viga de prontuario: apoyada, con carga uniforme
d_max = 5·q·L^4/(384·EI)

## Y su momento en el centro
M_c = q·L^2/8

## Sale de integrar cuatro veces, igual que antes
w_q = Diff{Diff{Diff{Diff{q·x^4/24 @ x} @ x} @ x} @ x}

## La placa apoyada en los cuatro bordes: la serie de Navier
w_nav = 16·q/(pi^6·D)·Suma{Suma{sin(m·pi·x/a)·sin(n·pi·y/b)/(m·n·(m^2/a^2 + n^2/b^2)^2) @ n = 1 : 9} @ m = 1 : 9}

## El primer término, que ya da casi todo
t_1 = 16/(pi^6)

## Cuánto vale la serie con UN término, en el centro
c_1 = 1/(1/36 + 1/16)^2

## Y con nueve términos por lado
n_t = 5·5 @@(solo los impares cuentan)
