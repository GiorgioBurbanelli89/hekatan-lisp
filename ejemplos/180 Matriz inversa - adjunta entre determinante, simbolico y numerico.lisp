# Matriz inversa: adjunta entre determinante
#: La **inversa** de una matriz cuadrada A es la matriz que **deshace** lo que A hace: multiplicada por A, por la izquierda o por la derecha, da la identidad I.
#: Se calcula con la **traspuesta de la matriz de cofactores** (la **adjunta**) partida por el **determinante**: A^{-1} = (cof(A))^{T} / det(A) = adj(A) / det(A).
#: Orden de la hoja: primero **con letras** (de dónde sale la fórmula) y después **con números**.

## 1 · Con letras: matriz de 2 × 2
A = [a, b; c, d]
#: **Paso 1 · Determinante.** Diagonal principal menos diagonal secundaria:
D_A = Simplify{det(A)}
#: **Paso 2 · Cofactores.** Cada entrada se cambia por el menor que queda al tachar su fila y su columna, con el signo del tablero de ajedrez (+ − / − +):
C_A = Simplify{cof(A)}
#: **Paso 3 · Adjunta.** La traspuesta de los cofactores: la diagonal se queda y la otra se cruza.
adj_A = Simplify{transpose(cof(A))}
#: **Paso 4 · Inversa.** La adjunta partida por el determinante:
A_inv = Simplify{adj(A)/det(A)}
#: Por eso el determinante **no puede ser cero**: sería dividir entre cero. El motor da lo mismo con su función inv:
A_inv2 = Simplify{inv(A)}

## 2 · Comprobación: A·A^{-1} = A^{-1}·A = I
I_1 = Simplify{A*inv(A)}
I_2 = Simplify{inv(A)*A}
#: Las dos dan la **identidad**: la inversa deshace a A por los dos lados.

## 3 · Con letras: matriz de 3 × 3
B = [a, b, c; d, e, f; g, h, k]
#: El determinante por la regla de Sarrus (o desarrollando por la primera fila):
D_B = Simplify{det(B)}
#: La adjunta (cofactores traspuestos), entrada por entrada:
adj_B = Simplify{adj(B)}
#: Y la inversa es esa adjunta partida por det(B): cada entrada lleva el determinante **debajo**.

## 4 · Con números: matriz de 2 × 2
A_n = [4, 7; 2, 6]
d_n = det(A_n) 'determinante: 4·6 − 7·2 = 10
adj_n = adj(A_n) 'adjunta: [6, −7; −2, 4]
A_ninv = adj(A_n)/det(A_n) 'inversa = adjunta / determinante
#: La misma inversa con la función inv del motor:
A_ninv2 = inv(A_n)
#: Comprobación con números:
I_n = A_n*inv(A_n)
#: **Gráfica 2D: por qué det(A) no puede ser cero.** Si se cambia la entrada d de A_n = [4, 7; 2, d], el determinante es 4·d − 14 y la primera entrada de la inversa es d/(4·d − 14). En d = 3.5 el determinante vale **cero** y la inversa se **dispara** (división entre cero):
#fplot(det_A = 4*x - 14, inv_11 = x/(4*x - 14), [0 7])
#: **Gráfica 3D.** Con a y d libres, det = a·d − 14. Donde la superficie toca el plano 0 (la curva a·d = 14) la matriz **no tiene inversa**:
#surf(det_A = x*y - 14, cero = 0, [0 8], [0 8])

## 5 · Con números: matriz de 3 × 3
B_n = [2, 0, 1; 1, 3, 2; 1, 1, 2]
d_Bn = det(B_n) 'determinante: 2·(3·2 − 2·1) − 0 + 1·(1·1 − 3·1) = 6 (no es cero: hay inversa)
B_ninv = adj(B_n)/det(B_n) 'inversa = adjunta / determinante
I_Bn = B_n*inv(B_n)
#: **Conclusión.** A^{-1} = adj(A)/det(A) vale igual con letras y con números, y siempre se comprueba con A·A^{-1} = I.
