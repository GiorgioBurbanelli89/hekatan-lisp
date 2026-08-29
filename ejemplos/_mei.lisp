# De la escalera de derivadas a las cuatro funciones de forma
## Toda la viga se cuenta con una sola función y sus derivadas. La función es cuánto baja en cada punto.
esc_0 = v_x
## Su primera derivada es cuánto gira.
esc_1 = v_p = th
## La segunda, por la rigidez, es el momento. Esa es la curvatura de siempre.
esc_2 = EI·v_pp = M
## La tercera es el cortante.
esc_3 = EI·v_ppp = V
## Y la cuarta es la carga repartida.
esc_4 = EI·v_pppp = q
## En una barra de pórtico no hay carga repartida en el tramo: todo entra por los nudos. Así que la cuarta derivada vale CERO.
sin_carga = EI·v_pppp = 0
## Y ahí está todo. Si la cuarta es cero, la tercera es constante.
paso_3 = v_ppp = c_3
## La segunda es una recta: por eso la curvatura de una barra es una recta.
paso_2 = v_pp = c_2 + c_3·x
## La primera es una parábola.
paso_1 = Integral{c_2 + c_3·x @ x}
## Y la deformada es una CÚBICA. Cuatro integraciones, cuatro constantes.
paso_0 = Integral{c_2·x + c_3·x^2/2 @ x}
## Y esa segunda derivada es la misma que ya conocías de resistencia de materiales.
elastica = v_pp = M/EI
## La cúbica tiene cuatro constantes, así que hacen falta cuatro datos para fijarla.
base = [1 x x^2 x^3]
## Y los cuatro datos que hay son los de las puntas: cuánto baja y cuánto gira cada extremo.
datos = [v_1; th_1; v_2; th_2]
## Cada dato es una fila: se evalúa la cúbica y su pendiente en cada punta. Eso arma la matriz C.
C = [1 0 0 0; 0 1 0 0; 1 1 1 1; 0 1 2 3]
## Los datos son C por las constantes, así que las constantes son C inversa por los datos.
Cinv = C^-1
## Y la deformada es la base por C inversa por los datos.
N = base*Cinv
## Eso que multiplica a cada dato son las CUATRO funciones de forma. Una por dato, ni una más.
H_1 = 1-3*x^2+2*x^3
H_2 = x-2*x^2+x^3
H_3 = 3*x^2-2*x^3
H_4 = -x^2+x^3
## Ahora se cierra el círculo. Derivo dos veces cada una y salen sus curvaturas.
H1pp = Diff{-6*x+6*x^2 @ x}
H2pp = Diff{1-4*x+3*x^2 @ x}
H3pp = Diff{6*x-6*x^2 @ x}
H4pp = Diff{-2*x+3*x^2 @ x}
## Las cuatro son RECTAS, que es justo lo que pedía la escalera.
curvatura = v_pp = H1pp·v_1 + H2pp·th_1 + H3pp·v_2 + H4pp·th_2
## Y el momento es la rigidez por esa curvatura: la misma M sobre EI, repartida entre los cuatro datos.
momento = M = EI·v_pp
## Por eso la energía clásica de flexión y la del elemento finito son la misma.
energia = M^2/(2·EI)
## Y de integrar los productos de esas cuatro curvaturas salen los dieciséis números de la matriz.
k_11 = Area{(-6+12*x)^2 @ x=0:1}
k_12 = Area{(-6+12*x)*(-4+6*x) @ x=0:1}
K_barra = [12, 6, -12, 6; 6, 4, -6, 2; -12, -6, 12, -6; 6, 2, -6, 4]
