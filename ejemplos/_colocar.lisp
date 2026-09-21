# Cómo se coloca CADA valor en la matriz de rigidez
## PARTE ALGEBRAICA. Aquí no hay ni un número: sólo letras.
## La constitutiva, con Poisson como letra.
D = [1, nu, 0; nu, 1, 0; 0, 0, (1-nu)/2]
## Y le llamamos g al término de la esquina, para no repetirlo.
g = (1 - nu)/2
## La matriz de rigidez del elemento tiene ocho filas y ocho columnas. Y la regla para llenarla es una sola:
## el término de la fila i y la columna j sale de la COLUMNA i de B y la COLUMNA j de B, con la constitutiva en medio.
## Así que CADA término usa DOS columnas distintas, y por eso ninguno se parece a otro.
## Veamos cuatro, todos del primer nudo. El primero usa la columna del desplazamiento en x consigo misma.
k_11 = Dm·(1 + g)/3
## El segundo cruza el desplazamiento en x con el desplazamiento en y del MISMO nudo.
k_12 = Dm·(nu + g)/4
## El tercero cruza el nudo uno con el nudo dos, en la misma dirección.
k_13 = Dm·(-1/3 + g/6)
## Y el cuarto cruza el nudo uno en x con el nudo dos en y.
k_14 = Dm·(-nu + g)/4
## Cuatro términos, cuatro fórmulas DISTINTAS. No hay ninguna que se repita.
## PARTE NUMÉRICA. Y sólo ahora se reemplaza: Poisson vale quince centésimas, así que g vale esto.
g_n = (1 - 0.15)/2
## Y la constitutiva de membrana, en toneladas por metro, ya la teníamos.
Dm_n = 365115
## Los cuatro términos, con números.
v_11 = 365115·(1 + 0.425)/3
v_12 = 365115·(0.15 + 0.425)/4
v_13 = 365115·(-1/3 + 0.425/6)
v_14 = 365115·(-0.15 + 0.425)/4
## Cuatro números completamente distintos, y dos de ellos NEGATIVOS. Del mismo elemento y del mismo nudo.
