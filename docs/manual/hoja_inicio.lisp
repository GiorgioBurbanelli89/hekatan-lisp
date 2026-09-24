# Mi primera hoja
#: Escribo datos y fórmulas a la izquierda; a la derecha sale la matemática dibujada.
L = 6 'largo de la viga, m
q = 10 'carga repartida, kN/m
M = q*L^2/8 'momento máximo, kN·m
## Operaciones simbólicas
f(x) = x^3 - 2*x
Derivate{f(x) @ x}
Integral{f(x) @ x}
Area{x^2 @ x = 0 : 3}
## Matrices
A = [2 1; 1 3]
A^-1
