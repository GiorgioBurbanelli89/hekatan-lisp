# De M sobre EI al polinomio: la deducción simbólica
## Del video anterior quedó deducido esto: la curvatura es el momento flector partido para la rigidez a flexión.
elastica = kappa = M/EI
## Ahora hay que mirar cómo varía el momento flector dentro de una barra de pórtico. Y ahí está la clave: como la carga entra por los nudos, en el tramo no hay carga repartida.
sin_carga = w = 0
## Si no hay carga repartida, la fuerza cortante es constante a lo largo de la barra.
cortante = V = c_3
## Y si el cortante es constante, el momento flector varía en línea recta de un extremo al otro.
mom_lin = M = M_1 + (M_2 - M_1)·x/L
## Así que la curvatura, que es el momento partido para la rigidez, también es una recta.
kap_lin = kappa = c_2 + c_3·x
## La curvatura es la derivada del giro. Integrando una vez sale el giro, y aparece la primera constante.
giro = Integral{c_2 + c_3·x @ x}
## Y el giro es la derivada de la flecha. Integrando otra vez sale la flecha, y aparece la segunda.
flecha = Integral{c_2·x + c_3·x^2/2 @ x}
## Mira bien lo que quedó: un polinomio de grado tres. La cúbica no se supone en ninguna parte: SALE de integrar dos veces.
polinomio = v_x = a_0 + a_1·x + a_2·x^2 + a_3·x^3
## Y viene con cuatro constantes: dos de las integraciones y dos que ya traía el momento.
constantes = 2 + 2
## Si en el tramo SÍ hubiera carga repartida, habría que empezar dos peldaños más arriba e integrar cuatro veces.
con_carga = grado = 3 + 2
## Por eso el elemento de viga clásico es cúbico: porque en un pórtico la carga entra por los nudos.
## Y esas cuatro constantes son las que se atan a los cuatro datos de las puntas. De ahí salen las cuatro funciones de forma.
datos = [v_1; theta_1; v_2; theta_2]
