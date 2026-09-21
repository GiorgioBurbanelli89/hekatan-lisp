# Medir la matriz de rigidez de un programa cerrado
## Se empuja con carga unidad en un grado y se lee el desplazamiento
u_j = Inverse{K_g}·e_j

## Ese desplazamiento ES una columna de la inversa. Repitiendo, sale la FLEXIBILIDAD
F_flex = Inverse{K_g}

## Y se invierte de vuelta para tener la rigidez medida
K_medida = Inverse{F_med}

## Antes hay que SUJETAR: un elemento suelto tiene tres movimientos que no deforman
w_rigido = a + b·x + c·y

## La rigidez por un movimiento rígido da CERO: de ahí salen las filas que no se midieron
K_fr = -K_ff·R_f·Inverse{R_r}

## La constitutiva reparte la rigidez en tres términos, con estos pesos
peso_1 = 1
peso_2 = nu
peso_3 = (1 - nu)/2

## ¿Se pueden separar midiendo con varios ν? El motor lo responde
combinacion = Simplify{(1 - nu)/2 - (1/2 - nu/2)}

## Con los modificadores SÍ: la rigidez es lineal en ellos
K_mod = m_11·A_11 + m_22·A_22 + m_12·A_12

## Y lo que encontró el método, comparando término a término
e_paralelogramo = 37.02
e_trapecio = 44.30
e_corregido = dec(0.000000001, 9)
