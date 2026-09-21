# La escalera: cada derivada baja un grado y significa otra cosa
w_1 = a_0 + a_1·x + a_2·x^2 + a_3·x^3 @@(la FLECHA, grado 3)
g_1 = Diff{a_0 + a_1·x + a_2·x^2 + a_3·x^3 @ x} @@(el GIRO, grado 2)
k_1 = Diff{Diff{a_0 + a_1·x + a_2·x^2 + a_3·x^3 @ x} @ x} @@(la CURVATURA, grado 1)
v_1 = Diff{Diff{Diff{a_0 + a_1·x + a_2·x^2 + a_3·x^3 @ x} @ x} @ x} @@(el CORTANTE, constante)
q_1 = Diff{Diff{Diff{Diff{a_0 + a_1·x + a_2·x^2 + a_3·x^3 @ x} @ x} @ x} @ x} @@(la CARGA en el vano, nula)
