# Las cuatro cáscaras, con números
## Las tres formulaciones acaban en la misma doble integral. Lo que cambia es la matriz constitutiva que va dentro. Aquí van las cuatro, en centímetros.
## UNO. MEMBRANA: se suma a través del espesor y sale el espesor entero.
A_m = Q·20
## DOS. SHELL-THIN: se suma el cuadrado del brazo y sale el espesor al cubo partido para doce.
D_t = Q·20^3/12
## TRES. SHELL-THICK: lo mismo, y además el cortante transversal con el factor de cinco sextos.
S_k = 5/6·G·20
## CUATRO. LAYERED, la cáscara por capas. Aquí la integral se vuelve una SUMA: una por capa.
## Cada capa aporta lo suyo MÁS el traslado de Steiner: su espesor por su distancia al centro, al cuadrado.
c_1 = 5^3/12 + 5·7.5^2
c_2 = 5^3/12 + 5·2.5^2
## Cuatro capas de cinco centímetros suman esto.
D_4 = 2·(5^3/12 + 5·7.5^2) + 2·(5^3/12 + 5·2.5^2)
## Y una sola capa de veinte centímetros, esto otro.
D_u = 20^3/12
## El mismo número. Partir la losa en capas no cambia nada si el material es el mismo: es la comprobación de que el método está bien.
## Y aparece un término que en la cáscara maciza no existe: el acople entre membrana y flexión.
## Con las capas simétricas se cancela.
B_sim = 5·(-7.5) + 5·(-2.5) + 5·2.5 + 5·7.5
## Pero con el acero solo en una cara, no.
B_asi = 10·5·(-7.5) + 5·(-2.5) + 5·2.5 + 5·7.5
## Y eso significa que al ESTIRAR la losa, se dobla.
## Y con acero en las dos caras, la rigidez a flexión se multiplica por casi nueve.
D_ac = 2·10·(5^3/12 + 5·7.5^2) + 2·(5^3/12 + 5·2.5^2)
veces = 5916.6667/666.66667
