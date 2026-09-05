# Subir la escalera: de la carga a la flecha
#: Derivando se baja. Integrando se sube. Y en el cálculo real se sube, porque el dato es la carga.

## Se parte de la CARGA, que es lo que se conoce
q_0 = q

## Una integral: el CORTANTE
V_1 = Integral{q @ x}

## Otra: el MOMENTO
M_2 = Integral{q·x @ x}

## Otra: el GIRO
t_3 = Integral{q·x^2/2 @ x}

## Y la cuarta: la FLECHA
w_4 = Integral{q·x^3/6 @ x}

## Cuatro integrales dejan CUATRO constantes
w_c = q·x^4/24 + C_1·x^3 + C_2·x^2 + C_3·x + C_4

## Sin carga en el vano el primer término se va, y queda el CÚBICO
w_h = C_1·x^3 + C_2·x^2 + C_3·x + C_4

## Y su cuarta derivada es cero, como debe ser
d4_h = Diff{Diff{Diff{Diff{C_1·x^3 + C_2·x^2 + C_3·x + C_4 @ x} @ x} @ x} @ x}

## Con carga uniforme, en cambio, la flecha es de grado CUATRO
d4_q = Diff{Diff{Diff{Diff{q·x^4/24 @ x} @ x} @ x} @ x}
