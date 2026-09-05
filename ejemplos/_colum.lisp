# Por qué una carga unidad da una COLUMNA entera
## La ecuación de la estructura
Ku_f = K·u = F

## Si se despeja el desplazamiento
u_desp = u = Inverse{K}·F

## Y la carga es UNIDAD en el primer grado y CERO en los demás
e_1 = [1; 0; 0]
e_2 = [0; 1; 0]
e_3 = [0; 0; 1]

## Una matriz cualquiera, para verlo
A_m = [a, b, c; d, e, p; q, r, s]

## Multiplicada por el primer vector unidad
c_1 = [a, b, c; d, e, p; q, r, s]·[1; 0; 0]

## Por el segundo
c_2 = [a, b, c; d, e, p; q, r, s]·[0; 1; 0]

## Y por el tercero
c_3 = [a, b, c; d, e, p; q, r, s]·[0; 0; 1]

## Es decir: cada carga unidad EXTRAE una columna de la inversa
F_col = u_j = Inverse{K}·e_j

## Con las tres columnas se tiene la flexibilidad entera, y se invierte
K_fin = Inverse{F}
