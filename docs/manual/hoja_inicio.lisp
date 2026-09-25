# Mi primera hoja
## Datos
#: Viga simplemente apoyada con carga **uniforme** en toda la luz.
L = 6 'largo de la viga, m
q = 10 'carga repartida, kN/m
M = q*L^2/8 'momento máximo, kN·m
#: El momento máximo es @M.
## Funciones
f(x) = x^3 - 2*x
f(2)
Derivate{f(x) @ x}
Integral{f(x) @ x}
Area{x^2 @ x = 0 : 3}
## Límites, sumas y series
Limit{sin(x)/x @ x = 0}
Limit{(x^2 - 1)/(x - 1) @ x = 1}
Sum{i @ i = 1 : 100}
Sum{i @ i = 1 : n}
Taylor{sin(x) @ x = 0 : 7}
## Matrices
A = [2 1; 1 3]
A^-1
## Gráfica
#fplot(sin(x), T_7 = x - x^3/6 + x^5/120 - x^7/5040, [-4 4])
