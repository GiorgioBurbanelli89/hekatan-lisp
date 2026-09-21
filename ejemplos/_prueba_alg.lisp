# Prueba: inversa e integral EN ÁLGEBRA
## inversa 2x2 con letras
M_a = [a, b; b, a]
Mi_a = [a, b; b, a]^-1
chk_a = [a, b; b, a]·[a, b; b, a]^-1
## inversa con k y l
M_k = [k, 1/l; 1/l, k]
Mi_k = [k, 1/l; 1/l, k]^-1
## inversa 3x3 diagonal con letras
M_d = [a, 0, 0; 0, b, 0; 0, 0, c]
Mi_d = [a, 0, 0; 0, b, 0; 0, 0, c]^-1
## integral simple de una Hermite
I_1 = Integral{1 - 3·x^2 + 2·x^3 @ x = 0 : 1}
## integral con parametro L
I_L = Integral{x·L·(1 - x·(2 - x)) @ x = 0 : 1}
## producto de dos segundas derivadas, integrado
I_2 = Integral{(-6 + 12·x)·(-6 + 12·x) @ x = 0 : 1}
## doble integral simbolica
I_d = Integral{Integral{(1 - 3·x^2 + 2·x^3)·(1 - 3·y^2 + 2·y^3) @ x = 0 : 1} @ y = 0 : 1}
