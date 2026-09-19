# Cómo se mide la matriz de rigidez de un programa cerrado
#: ETABS no enseña su matriz. Pero deja **empujar y medir**, y con eso basta: se deduce entera. Aquí está el álgebra, deducida por el motor.
#> Método: reconstrucción por flexibilidad. Es el mismo que sacó γ = 0.400 de la membrana de ETABS.

## 1 · La idea: empujar y mirar cuánto se mueve
#: La ecuación de la estructura relaciona rigidez, desplazamiento y carga. Si empujo con una carga **unidad** en un solo grado de libertad, el desplazamiento que leo **es una columna entera** de la inversa de la rigidez:
u_j = Inverse{K_g}·e_j @@(1.1 carga unidad en el grado j)
#: Poniendo f con un 1 en el grado j y 0 en el resto, `u` **es la columna j** de la inversa. Repitiendo para cada grado libre se llena la matriz completa. A esa inversa se le llama **flexibilidad**:
F_flex = Inverse{K_g} @@(1.2 la flexibilidad ES la inversa de la rigidez)
K_medida = Inverse{F_med} @@(1.3 y se invierte de vuelta la MEDIDA)
#: Eso es todo el truco: **no hace falta ver dentro del programa**. Se le dan entradas conocidas y se leen salidas.

## 2 · Por qué hay que sujetar antes de empujar
#: Un elemento suelto flota: se puede trasladar y girar sin deformarse. Esos movimientos **no cuestan energía**, así que la rigidez los manda a cero y la matriz **no se puede invertir**. En una placa hay tres:
w_rigido = a + b*x + c*y @@(2.1 los 3 modos de sólido rígido)
#: Se sujetan tres grados —justo esos tres— y el resto queda libre. La parte libre-libre **sí** es invertible, y es la que se mide.

## 3 · Recuperar las filas que no se midieron
#: Al sujetar tres grados, esas filas y columnas se pierden. **No se inventan**: salen de que la rigidez por un movimiento rígido da cero. Partiendo la ecuación en libres (f) y sujetos (r):
cero = K_ff*R_f + K_fr*R_r @@(3.1 rigidez por sólido rígido = 0)
K_fr = -K_ff*R_f*Inverse{R_r} @@(3.2 despejando lo que falta)
#: Y se comprueba: si la matriz reconstruida multiplicada por los modos rígidos da cero, está bien. Medido: sale **1e-15**.

## 4 · Separar los términos: la parte que NO funcionó
#: La constitutiva de placa reparte la rigidez en tres términos con pesos que dependen de ν:
peso_1 = 1 @@(4.1 directos)
peso_2 = nu @@(4.2 acoplado)
peso_3 = (1 - nu)/2 @@(4.3 torsión)
#: La idea era medir con varios ν y despejar los tres. **No se puede**, y el motor lo enseña: el tercer peso es combinación lineal de los otros dos.
combinacion = Simplify{(1 - nu)/2 - (1/2 - nu/2)} @@(4.4 ¿son independientes?)
#: Da **cero**: el tercer peso ES 1/2 menos ν/2. Las columnas del sistema son dependientes, hay infinitas soluciones y el ajuste devuelve una cualquiera. Por eso salían valores absurdos.

## 5 · La vía que sí separa: los modificadores
#: ETABS deja multiplicar **cada término por separado** (M11MOD, M22MOD, M12MOD). La rigidez es **lineal** en ellos:
K_mod = m11*A11 + m22*A22 + m12*A12 @@(5.1 lineal en los modificadores)
#: Ahora los pesos **sí** son independientes: se varía uno y los otros se quedan quietos. Con cuatro medidas se despejan las tres piezas.
#: ⚠️ Y no se pone ninguno a **cero**: dejaría la placa sin rigidez en esa dirección y el modelo sería un mecanismo. Se **suben** de 1 a 2, que separa igual y no rompe nada.

## 6 · Lo que encontró este método
#: Comparando la matriz medida contra la nuestra, término a término, salió que el elemento delgado usaba el **rectángulo que envuelve** al elemento en vez de su forma real. En un cuadrado da igual; en una pieza torcida, no:
error_paralelogramo = 37.02 @@(6.1 % antes)
error_trapecio = 44.30 @@(6.2 % antes)
error_corregido = 0.000000001 @@(6.3 % después, con el jacobiano real)
#: El fallo **no se veía** midiendo solo cuadrados y rectángulos, que son justo las dos formas donde no aparece.
