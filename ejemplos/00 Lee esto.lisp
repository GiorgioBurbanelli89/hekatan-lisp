# Bienvenido a Hekatan LISP
#: A la izquierda se escribe; a la derecha sale la matemática ya calculada y dibujada. Hay tres tipos de línea:
#: **#** delante es texto · sin nada es matemática · **;** delante es LISP puro.

## 1 · Datos y fórmulas
L = 6 'largo de la viga, m
q = 10 'carga repartida, kN/m
M = q*L^2/8 'momento máximo de una viga simplemente apoyada, kN·m

## 2 · Operaciones simbólicas
f(x) = x^3 - 2*x
Derivate{f(x) @ x}
Integral{f(x) @ x}
Area{f(x) @ x = 0 : 2}

## 3 · Por dentro es LISP
#: Cada fórmula se convierte en una lista: x³ − 2x es (- (expt x 3) (* 2 x)). Arriba, en **resultado como**, el botón **LISP** muestra la hoja entera en listas y **3 formas** pone juntas la matemática, el LISP y el MATLAB.

#: Abre los otros ejemplos (menú **Ejemplos**) y cambia los datos: la hoja se recalcula sola.
