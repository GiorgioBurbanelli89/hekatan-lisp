# La INVERSA de una matriz, en álgebra
#: No es un botón. Es una cadena de pasos, y cada uno se puede escribir con letras.

## El escalar
#: Con un solo número la ecuación se despeja dividiendo.
esc_1 = Despejar{a·x = b @ x}

## La matriz, con letras
A_m = [a, b; b, c]

## El determinante
detA = det(A_m)

## Los menores: tachar la fila y la columna
men11 = menor(A_m, 1, 1)
men12 = menor(A_m, 1, 2)
men21 = menor(A_m, 2, 1)
men22 = menor(A_m, 2, 2)

## Los cofactores: cada menor con su signo
cofA = cof(A_m)

## La adjunta: la de cofactores, transpuesta
adjA = adj(A_m)

## Y la inversa: la adjunta partida por el determinante
invA = A_m^-1

## La comprobación
chkA = A_m·A_m^-1

## Ahora con forma de RIGIDEZ: dos grados y un muelle de apoyo
K_s = [k, -k; -k, k + p]
detK = det(K_s)
invK = K_s^-1

## Y sin el apoyo, el muelle vale cero
K_0 = [k, -k; -k, k]
det0 = det(K_0)

## El desplazamiento, despejado en álgebra
u_s = K_s^-1·[F; 0]
