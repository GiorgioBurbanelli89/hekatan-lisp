# De dónde sale cada una de las cuatro funciones de forma
## Las cuatro son la MISMA cúbica con cuatro perillas. Lo único que cambia son las cuatro condiciones que se le exigen.
cubica = H = a_0 + a_1·x + a_2·x^2 + a_3·x^3
## Y su pendiente, que es lo que vale el giro en cada punto.
pend = Diff{a_0 + a_1·x + a_2·x^2 + a_3·x^3 @ x}
## La regla es una sola: cada función vale UNO en su propio dato y CERO en los otros tres.
## Empecemos por la primera, que es el peso de la flecha del primer nudo.
## Al principio la flecha vale uno, y meter cero en la cúbica deja solo la primera perilla.
h1_a = a_0 = 1
## Al principio el giro vale cero, y meter cero en la pendiente deja solo la segunda perilla.
h1_b = a_1 = 0
## Al final la flecha vale cero: se mete uno en la cúbica y quedan las otras dos perillas.
h1_c = 1 + a_2 + a_3 = 0
## Y al final el giro también vale cero: se mete uno en la pendiente.
h1_d = 2·a_2 + 3·a_3 = 0
## Ese par de ecuaciones se resuelve solo, y da las dos perillas que faltaban.
h1_e = a_2 = -3
h1_f = a_3 = 2
## Y esa es la primera función de forma, ya completa.
H_1 = 1 - 3·x^2 + 2·x^3
## Su pendiente es esto: justo lo que viste en el video anterior.
H_1p = Diff{1 - 3·x^2 + 2·x^3 @ x}
## Y derivando otra vez, su curvatura.
H_1pp = Diff{-6·x + 6·x^2 @ x}
## La segunda es el peso del GIRO del primer nudo. Cambian dos condiciones: la flecha del principio ahora vale cero y el giro vale uno.
h2_a = a_0 = 0
h2_b = a_1 = 1
h2_c = 1 + a_2 + a_3 = 0
h2_d = 1 + 2·a_2 + 3·a_3 = 0
H_2 = x - 2·x^2 + x^3
H_2p = Diff{x - 2·x^2 + x^3 @ x}
H_2pp = Diff{1 - 4·x + 3·x^2 @ x}
## La tercera es el peso de la flecha del SEGUNDO nudo: todo cero al principio, y al final la flecha vale uno y el giro cero.
h3_c = a_2 + a_3 = 1
h3_d = 2·a_2 + 3·a_3 = 0
H_3 = 3·x^2 - 2·x^3
H_3p = Diff{3·x^2 - 2·x^3 @ x}
H_3pp = Diff{6·x - 6·x^2 @ x}
## Y la cuarta es el peso del giro del segundo nudo: todo cero menos el giro del final, que vale uno.
h4_c = a_2 + a_3 = 0
h4_d = 2·a_2 + 3·a_3 = 1
H_4 = -x^2 + x^3
H_4p = Diff{-x^2 + x^3 @ x}
H_4pp = Diff{-2·x + 3·x^2 @ x}
## Ahí están las cuatro. Mismo molde, cuatro juegos de condiciones, cuatro funciones.
## Y la deformada de la barra es la mezcla de las cuatro, cada una con su dato.
mezcla = v_x = H_1·v_1 + H_2·theta_1 + H_3·v_2 + H_4·theta_2
