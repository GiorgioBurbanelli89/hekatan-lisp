# La INVERSA en álgebra — los pasos, no el botón
## 1 · La matriz, con letras
A_m = [a, b; b, c]
## 2 · El determinante
detA = det(A_m)
## 3 · Los MENORES: tachar fila y columna
men11 = menor(A_m, 1, 1)
men12 = menor(A_m, 1, 2)
## 4 · Los COFACTORES: el menor con su signo
cofA = cof(A_m)
## 5 · La ADJUNTA: la de cofactores, transpuesta
adjA = adj(A_m)
## 6 · Y la INVERSA: la adjunta partida por el determinante
invA = A_m^-1
## 7 · La comprobación
chkA = A_m·A_m^-1
## 8 · Con la forma de una rigidez de dos grados
K_s = [k, -k; -k, k + p]
detK = det(K_s)
invK = K_s^-1
