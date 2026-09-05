# El Jacobiano en 1D: del tramo patrón al elemento real
## Un edificio tiene miles de barras, y cada una mide distinto. Pero las funciones de forma están escritas SIEMPRE en el mismo sitio: el tramo patrón, el que va de menos uno a más uno.
N_1 = (1 - xi)/2
N_2 = (1 + xi)/2
## Así que hace falta un puente entre ese tramo patrón y la barra de verdad. Y el puente se hace con las MISMAS funciones de forma: eso se llama isoparamétrico.
mapeo = x = N_1·x_1 + N_2·x_2
## Se ponen las posiciones reales de los nudos: el primero en cero y el segundo en el largo de la barra.
mapeo_2 = x = (1 - xi)/2·0 + (1 + xi)/2·L
## Y al simplificar queda el puente completo.
mapeo_3 = Expand{(1 + xi)/2·L}
## Comprobación: en el nudo izquierdo, donde la coordenada patrón vale menos uno, sale cero.
chk_1 = (1 + (-1))·L/2 = 0
## Y en el derecho, donde vale más uno, sale el largo de la barra.
chk_2 = (1 + 1)·L/2 = L
## El Jacobiano es la derivada de ese puente: cuánto avanza la barra real cuando avanzo un poquito en el patrón.
jac = J = Diff{L·(1 + xi)/2 @ xi} = L/2
## Pero hay una forma todavía más directa de verlo, y es la que explica de dónde sale ese dos.
## El Jacobiano es la relación entre la coordenada FÍSICA, que va en metros, y la coordenada NATURAL, que no tiene unidades.
## El incremento FÍSICO es lo que mide la barra de verdad, de cero al largo.
inc_fis = Delta_x = L - 0 = L
## Y el incremento NATURAL es lo que mide el tramo patrón, de menos uno a más uno.
inc_nat = Delta_xi = 1 - (-1) = 2
## El Jacobiano es el incremento físico partido para el incremento natural. Ahí está de dónde sale el largo partido para dos.
razon = J = Delta_x/Delta_xi = L/2
## El Jacobiano aparece DOS veces, y en sentidos contrarios. Al integrar, un pedacito real es el Jacobiano por un pedacito patrón: MULTIPLICA.
integrar = Delta_x = J·Delta_xi
## Y al derivar es al revés: derivar respecto a la barra real es derivar respecto al patrón y DIVIDIR por el Jacobiano.
derivar = dN_dx = dN_dxi/J
## Por eso una función de forma, derivada respecto a la barra real, sale con el largo abajo.
deriv_N1 = Diff{(1 - xi)/2 @ xi}
deriv_real = dN1_dx = -1/L
## Y aquí está la razón de fondo, que los libros no dicen: como la cuadratura de Gauss está definida en el intervalo de menos uno a más uno, TODO el cálculo interno se hace en coordenadas naturales. Los programas como ETABS trabajan así por dentro.
## Si cada barra usara su propio tramo, habría que reescribir las funciones y recalcular los puntos de Gauss para cada una.
## Trabajando siempre en el tramo patrón, las funciones son las mismas para todas las barras y los puntos de Gauss también. Lo único que cambia de una barra a otra es un número: su Jacobiano.
## Comprobación bonita: si la barra midiera justo dos, el Jacobiano valdría uno y la barra real sería el tramo patrón.
chk_3 = J = 2/2 = 1
