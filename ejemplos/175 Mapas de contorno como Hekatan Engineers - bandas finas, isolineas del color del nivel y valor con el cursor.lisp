# Mapas de contorno como Hekatan Engineers: bandas finas, isolíneas del color de su nivel y el valor con el cursor
#numerico

#: **Cómo dibujamos un campo de resultados.** (1) El valor se **interpola** dentro de cada celda, no se pinta un color por elemento: los colores pasan suave de un elemento al otro, sin los escalones de la malla. (2) El rango se parte en **bandas finas** (12 niveles, escala de ETABS/CSI). (3) En cada borde de banda va una **isolínea fina del color de su nivel** (no negra), trazada por interpolación: se leen los niveles y los gradientes de un vistazo. (4) Al pasar el cursor se ve el **valor exacto** en ese punto.

## 1 · Una losa simplemente apoyada (Navier, primer término)

a = 6 'lado en x [m]
b = 4 'lado en y [m]
q = 10 'carga uniforme [kN/m2]
h = 0.20 'espesor [m]
E = 25e6 'módulo del concreto [kN/m2]
nu = 0.2 'Poisson
D = E·h^3/(12·(1 - nu^2)) 'rigidez a flexión de la placa [kN·m]
#: Primer término de la serie de Navier (m = n = 1): la carga q se reparte como 16·q/π² · sen(πx/a)·sen(πy/b):
q_11 = 16·q/pi^2 'amplitud de la carga [kN/m2]
w_0 = q_11/(D·pi^4·(1/a^2 + 1/b^2)^2) 'flecha máxima (centro) [m]
w(x, y) = w_0·sin(pi·x/a)·sin(pi·y/b)
w_mm(x, y) = 1000·w(x, y)

## 2 · La flecha w [mm]

#contourf(w_mm(x, y), [0 a], [0 b])
#: **Cómo leerlo.** El máximo va en el centro, (a/2; b/2). Las isolíneas son casi elipses alargadas en x porque la losa es más larga en x (6 m) que en y (4 m): se dobla más en la dirección corta.

## 3 · El momento M_x [kN·m/m]

#: M_x = D·w_0·π²·(1/a² + ν/b²)·sen(πx/a)·sen(πy/b):
M_x(x, y) = D·w_0·pi^2·(1/a^2 + nu/b^2)·sin(pi·x/a)·sin(pi·y/b)
#contourf(M_x(x, y), [0 a], [0 b])
M_max = M_x(a/2, b/2) 'momento en el centro [kN·m/m]
#: **Cómo leerlo.** El mismo patrón que la flecha (un solo término de la serie), con el máximo en el centro. Con más términos de la serie (m, n = 1, 3, 5…) aparecerían las esquinas y los bordes con más detalle; aquí basta uno para ver la forma de dibujar.
