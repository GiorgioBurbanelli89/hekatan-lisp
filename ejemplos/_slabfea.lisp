# Losa rectangular por elementos finitos, paso a paso
## LOS DATOS. Seis metros por cuatro, diez centímetros de espesor.
a_m = 6
b_m = 4
t_m = 0.1
## La carga, pasada a las unidades de aquí: diez kilonewton son una tonelada fuerza.
q_t = 10/9.80665
## Y el hormigón: treinta y cinco mil megapascales en kilogramo fuerza por centímetro cuadrado.
E_kg = 35000·10.19716
nu_c = 0.15
## LA MALLA. Seis elementos a lo largo y cuatro a lo ancho.
n_e = 6·4
n_j = 7·5
## Cada elemento mide un metro por un metro.
a_1 = 6/6
b_1 = 4/4
## Y los nudos del contorno van apoyados: dos veces la suma de las dos divisiones.
n_s = 2·(6+4)
## Cuatro grados por nudo, así que la matriz del elemento es de dieciséis por dieciséis, y la global de ciento cuarenta.
n_ke = 4·4
n_g = 4·35
## LAS FUNCIONES DE FORMA, en una dirección. Son las cuatro Hermite.
P_1 = 1 - x^2·(3 - 2·x)
P_2 = x·(1 - x·(2 - x))
P_3 = x^2·(3 - 2·x)
P_4 = x^2·(-1 + x)
## Sus PRIMERAS derivadas, que dan los giros.
Q_1 = Diff{1 - x^2·(3 - 2·x) @ x}
Q_2 = Diff{x·(1 - x·(2 - x)) @ x}
## Y sus SEGUNDAS derivadas, que son las curvaturas y van dentro de la matriz B.
R_1 = Diff{Diff{1 - x^2·(3 - 2·x) @ x} @ x}
R_2 = Diff{Diff{x·(1 - x·(2 - x)) @ x} @ x}
R_3 = Diff{Diff{x^2·(3 - 2·x) @ x} @ x}
R_4 = Diff{Diff{x^2·(-1 + x) @ x} @ x}
## Y las dieciséis del elemento son PRODUCTOS de una en cada dirección. La del primer nudo, para la flecha.
N_w = (1 - x^2·(3-2·x))·(1 - y^2·(3-2·y))
## La del giro en una dirección.
N_tx = (x·(1 - x·(2-x)))·(1 - y^2·(3-2·y))
## Y la de la torsión cruzada, que es el cuarto grado.
N_ps = (x·(1 - x·(2-x)))·(y·(1 - y·(2-y)))
## LA CONSTITUTIVA, primero en álgebra.
D_alg = E·t^3/(12·(1 - nu^2))
## Y ahora con los números, en tonelada fuerza por metro.
D_num = 3569000·0.001/(12·0.9775)
## Con la forma dentro, que sólo depende de Poisson.
D_f = [1, 0.15, 0; 0.15, 1, 0; 0, 0, 0.425]
## LA RIGIDEZ del elemento: la doble integral de la B transpuesta por la constitutiva por la B, por el área del elemento.
K_e = a_1·b_1·Area{Area{Bi·D·Bj @ xi=0:1} @ eta=0:1}
## Y con eso se ensambla la global, se ponen los apoyos y se resuelve.
