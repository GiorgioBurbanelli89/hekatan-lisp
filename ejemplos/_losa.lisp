# El aporte de la losa: diafragma y elemento de área
## Sin losa cada pórtico se defendía solo. Con losa ya no, y conviene ver por qué con números.
## Una losa tiene dos vidas. Dentro de su plano trabaja estirándose, como una membrana. Fuera de su plano trabaja doblándose, como una placa.
## Primero la de dentro del plano. Una columna de treinta por treinta, de tres metros, tiene esta rigidez para moverse de lado.
k_col = 12·2400000·0.000675/3^3
## Y una franja de losa de veinte centímetros por seis metros de ancho, estirándose, tiene esta.
k_losa = 2400000·1.2/6
## La losa es cientos de veces más rígida que la columna.
razon = 480000/720
## Por eso se acepta que la losa no se deforma dentro de su plano: se comporta como un DIAFRAGMA rígido.
## Sin diafragma, un piso con veinte nudos arrastra todos estos grados de libertad.
gdl_sin = 20·6
## Con diafragma, todo el piso se describe con tres: dos corridas y un giro en planta.
gdl_con = 2 + 1
## De ciento veinte a tres. Esa es la razón por la que los programas lo usan.
ahorro = 120/3
## Y el reparto cambia: como todos los pórticos se mueven lo mismo, la fuerza se reparte según la RIGIDEZ de cada uno, no según lo que le toca por área.
reparto = F_i = F·k_i/k_total
## Ahora la otra vida de la losa: fuera de su plano. Ahí trabaja doblándose, y para eso necesita funciones de forma de área.
## El elemento de cuatro nudos usa estas cuatro, que se llaman bilineales.
N_1 = (1 - xi)·(1 - eta)/4
N_2 = (1 + xi)·(1 - eta)/4
N_3 = (1 + xi)·(1 + eta)/4
N_4 = (1 - xi)·(1 + eta)/4
## Y cumplen la misma regla de siempre: cada una vale UNO en su nudo y CERO en los otros tres.
prueba_1 = (1 + 1)·(1 + 1)/4
prueba_2 = (1 - 1)·(1 + 1)/4
## Son el mismo molde que en la barra, pero en dos direcciones: se multiplican las dos rectas.
producto = N = N_x·N_y
## Y se integran con Gauss, dos puntos en cada dirección: cuatro en total.
puntos = 2·2
## La suma tiene un peso por cada punto, igual que en la barra.
suma_gauss = A = w_1·w_1·f_1 + w_1·w_2·f_2 + w_2·w_1·f_3 + w_2·w_2·f_4
