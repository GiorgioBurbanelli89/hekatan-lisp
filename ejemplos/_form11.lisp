# Las tres formulaciones, deducidas
## Las tres usan las mismas funciones de forma del cuadrilátero. Lo que cambia es QUÉ campo interpolan y cuántas veces se deriva.
N_1 = (1-xi)·(1-eta)/4
## MEMBRANA. Se interpolan los dos desplazamientos del plano, y la deformación axial es la primera derivada.
dNdxi = Partial{(1-xi)·(1-eta)/4 @ xi}
dNdeta = Partial{(1-xi)·(1-eta)/4 @ eta}
## Con esas dos parciales se arma la matriz que convierte desplazamientos en deformaciones. Una sola derivada: basta con que el campo sea continuo.
## SHELL-THIN, la hipótesis de Kirchhoff. Aquí solo se interpola la flecha, y el giro NO es libre: ES la pendiente de la flecha.
w = 3·x^2
th_k = Partial{3·x^2 @ x}
## Por eso la distorsión por cortante sale cero por definición: la pendiente menos el giro es la misma cosa menos ella misma.
g_k = Expand{6·x - 6·x}
## Y la curvatura es la SEGUNDA derivada de la flecha.
k_k = Partial{Partial{3·x^2 @ x} @ x}
## SHELL-THICK, la hipótesis de Mindlin. Aquí la flecha y el giro se interpolan por separado, cada uno con sus propias funciones de forma.
th_m = 5·x
## Y entonces la pendiente y el giro ya no tienen por qué coincidir: su diferencia es la distorsión por cortante, y ya no es cero.
g_m = Expand{6·x - 5·x}
## La curvatura pasa a ser la PRIMERA derivada del giro, no la segunda de la flecha.
k_m = Partial{5·x @ x}
## Ahí está todo: Kirchhoff deriva dos veces la flecha, Mindlin deriva una sola vez el giro.
d_kir = 2
d_min = 1
