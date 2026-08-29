# La escalera de la viga: de la carga distribuida hasta la flecha
## La flecha es cuánto baja la viga en cada punto.
flecha = v_x
## El giro de la sección es la derivada de la flecha.
giro = theta = v_p
## Y la curvatura es la derivada del giro. Ojo con esto: la curvatura es kappa, no theta. Theta es el giro.
curvatura = kappa = v_pp
## El momento flector es la rigidez a flexión por la curvatura. Esta es la fórmula que ya conoces.
momento = M = EI·kappa
## La fuerza cortante es la derivada del momento flector.
cortante = V = M_p
## Y la carga distribuida es menos la derivada del cortante.
carga = w = -V_p
## En una barra de pórtico no hay carga distribuida en el tramo: todo entra por los nudos.
sin_carga = w = 0
## Si no hay carga distribuida, la fuerza cortante es constante a lo largo de la barra.
p_V = V = c_3
## Si el cortante es constante, el momento flector varía en línea recta.
p_M = M = c_2 + c_3·x
## Y la curvatura es el momento partido para la rigidez, así que la curvatura también es una recta.
p_kap = kappa = M/EI
## Integrando la curvatura sale el giro: una parábola.
p_th = Integral{c_2 + c_3·x @ x}
## E integrando el giro sale la flecha: una cúbica.
p_v = Integral{c_2·x + c_3·x^2/2 @ x}
## Cuatro integraciones dejaron cuatro constantes, así que hacen falta cuatro datos para fijarlas.
base = [1 x x^2 x^3]
## Y los cuatro datos son los de los nudos: la flecha y el giro de cada extremo.
datos = [v_1; theta_1; v_2; theta_2]
## Cada dato es una fila: se evalúa la flecha y el giro en cada nudo. Eso arma la matriz C.
C = [1 0 0 0; 0 1 0 0; 1 1 1 1; 0 1 2 3]
## Los datos son C por las constantes, así que las constantes son C inversa por los datos.
Cinv = C^-1
## Y la flecha es la base por C inversa por los datos.
N = base*Cinv
## Eso que multiplica a cada dato son las cuatro funciones de forma. Una por dato.
H_1 = 1-3*x^2+2*x^3
H_2 = x-2*x^2+x^3
H_3 = 3*x^2-2*x^3
H_4 = -x^2+x^3
## ¿Y por qué hay que DERIVAR? Porque la rigidez no depende de cuánto se mueve la barra, sino de cuánto se dobla.
## Prueba uno: toda la barra baja lo mismo. No se dobló nada, y la primera derivada ya da cero.
rig_1 = v = 1
rig_1p = Diff{1 @ x}
## Prueba dos: la barra gira entera, como una tabla rígida. Tampoco se dobló: la primera derivada es constante y la segunda da cero.
rig_2p = Diff{x @ x}
rig_2pp = Diff{1 @ x}
## Prueba tres: ahora sí se curva. La segunda derivada ya no es cero.
rig_3p = Diff{x^2 @ x}
rig_3pp = Diff{2·x @ x}
## Por eso se deriva dos veces: la segunda derivada borra sola los movimientos que no cuestan energía, y deja solo lo que sí cuesta, que es doblarse.
## Derivando dos veces cada una salen sus curvaturas.
H1pp = Diff{-6*x+6*x^2 @ x}
H2pp = Diff{1-4*x+3*x^2 @ x}
H3pp = Diff{6*x-6*x^2 @ x}
H4pp = Diff{-2*x+3*x^2 @ x}
## Las cuatro son rectas, que es justo lo que pide un momento flector lineal.
kap_mix = kappa = H1pp·v_1 + H2pp·theta_1 + H3pp·v_2 + H4pp·theta_2
## Y el momento flector es la rigidez por esa curvatura: la misma fórmula del principio, repartida entre los cuatro datos.
mom_mix = M = EI·kappa
## Por eso la energía de deformación por flexión de los libros y la del elemento finito son la misma.
energia = M^2/(2·EI)
## Y de integrar los productos de esas cuatro curvaturas salen los dieciséis números de la matriz de rigidez.
k_11 = Area{(-6+12*x)^2 @ x=0:1}
k_12 = Area{(-6+12*x)*(-4+6*x) @ x=0:1}
K_barra = [12, 6, -12, 6; 6, 4, -6, 2; -12, -6, 12, -6; 6, 2, -6, 4]
