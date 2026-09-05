# Las potencias: qué forma da cada una
#: Antes de las funciones de forma hay que ver qué sabe hacer cada potencia.

## La curvatura de cada potencia: se deriva DOS veces
k_0 = Diff{Diff{1 @ x} @ x}
k_1 = Diff{Diff{x @ x} @ x}
k_2 = Diff{Diff{x^2 @ x} @ x}
k_3 = Diff{Diff{x^3 @ x} @ x}
k_4 = Diff{Diff{x^4 @ x} @ x}

## Y en una viga el momento es la curvatura por la rigidez
M_x = EI·kappa

## La prueba: la CUARTA derivada del cúbico
d4_3 = Diff{Diff{Diff{Diff{a_0 + a_1·x + a_2·x^2 + a_3·x^3 @ x} @ x} @ x} @ x}

## Y la de un polinomio de CUARTO grado, que ya no sirve
d4_4 = Diff{Diff{Diff{Diff{x^4 @ x} @ x} @ x} @ x}

## Cuántas condiciones puede cumplir cada base
n_1 = 2 @@(recta: flecha y giro de UN nudo)
n_2 = 3
n_3 = 4 @@(cúbico: los cuatro grados de los DOS nudos)
