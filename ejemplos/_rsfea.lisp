# La losa rectangular por elementos finitos
#: Todo con letras primero. Los números, al final del todo.

## 1 · Las cuatro funciones base
#: Un tramo de longitud L, con una coordenada x que va de cero a uno.
P1(x) = 1 - x^2·(3 - 2·x)
P2(x) = x·L·(1 - x·(2 - x))
P3(x) = x^2·(3 - 2·x)
P4(x) = x^2·L·(x - 1)

## 2 · Y valen uno donde les toca, cero en lo demás
u_00 = P1(0)
u_01 = P1(1)
u_30 = P3(0)
u_31 = P3(1)

## 3 · Las primeras derivadas: los GIROS
dP_1 = Diff{1 - x^2·(3 - 2·x) @ x}
dP_2 = Diff{x·L·(1 - x·(2 - x)) @ x}
dP_3 = Diff{x^2·(3 - 2·x) @ x}
dP_4 = Diff{x^2·L·(x - 1) @ x}

## 4 · Las segundas derivadas: las CURVATURAS
ddP_1 = Diff{Diff{1 - x^2·(3 - 2·x) @ x} @ x}
ddP_2 = Diff{Diff{x·L·(1 - x·(2 - x)) @ x} @ x}
ddP_3 = Diff{Diff{x^2·(3 - 2·x) @ x} @ x}
ddP_4 = Diff{Diff{x^2·L·(x - 1) @ x} @ x}

## 5 · La regla de la cadena: el Jacobiano
#: La coordenada va de cero a uno pero el elemento mide L. Cada derivada se divide por L.
cad_1 = Diff{1 - x^2·(3 - 2·x) @ x}/L
cad_2 = Diff{Diff{1 - x^2·(3 - 2·x) @ x} @ x}/L^2

## 6 · Las funciones de la placa: PRODUCTO de dos
N_w = (1 - xi^2·(3 - 2·xi))·(1 - eta^2·(3 - 2·eta)) @@(FLECHA del nudo)
N_tx = xi·A·(1 - xi·(2 - xi))·(1 - eta^2·(3 - 2·eta)) @@(GIRO sobre x)
N_ty = (1 - xi^2·(3 - 2·xi))·eta·B·(1 - eta·(2 - eta)) @@(GIRO sobre y)
N_ps = xi·A·(1 - xi·(2 - xi))·eta·B·(1 - eta·(2 - eta)) @@(el ALABEO)

## 7 · Las tres curvaturas: dos rectas y una CRUZADA
c_11 = Partial{Partial{(1 - xi^2·(3 - 2·xi))·(1 - eta^2·(3 - 2·eta)) @ xi} @ xi}
c_22 = Partial{Partial{(1 - xi^2·(3 - 2·xi))·(1 - eta^2·(3 - 2·eta)) @ eta} @ eta}
c_12 = Partial{Partial{(1 - xi^2·(3 - 2·xi))·(1 - eta^2·(3 - 2·eta)) @ xi} @ eta}

## 8 · La matriz constitutiva
D_p = E·t^3/(12·(1 - nu^2))
D_b = [1, nu, 0; nu, 1, 0; 0, 0, (1 - nu)/2]

## 9 · La rigidez: cada término, su propia integral
K_ij = A·B·Integral{Integral{Bi·D_b·Bj @ xi} @ eta}

## 10 · Y las integrales salen en álgebra
i_pp = Integral{(1 - x^2·(3 - 2·x))^2 @ x = 0 : 1}
i_cc = Integral{Diff{Diff{1 - x^2·(3 - 2·x) @ x} @ x}^2 @ x = 0 : 1}
i_LL = Integral{x·L·(1 - x·(2 - x)) @ x = 0 : 1}

## 10b · Y en decimal, que es como se lee
dpp = dec(Integral{(1 - x^2·(3 - 2·x))^2 @ x = 0 : 1}, 4)
dcc = dec(Integral{Diff{Diff{1 - x^2·(3 - 2·x) @ x} @ x}^2 @ x = 0 : 1}, 2)

## 11 · La carga de cada grado, también en álgebra
F_w = A·B·q·Integral{Integral{(1 - xi^2·(3 - 2·xi))·(1 - eta^2·(3 - 2·eta)) @ xi = 0 : 1} @ eta = 0 : 1}
F_tx = A·B·q·Integral{Integral{xi·A·(1 - xi·(2 - xi))·(1 - eta^2·(3 - 2·eta)) @ xi = 0 : 1} @ eta = 0 : 1}

## 12 · Se ensambla, se sujeta y se resuelve
KZ = K·Z = F
Z_s = Kinv·F

## 13 · AHORA los números
a_m = 6 @@(largo, m)
b_m = 4 @@(ancho, m)
t_m = 10 @@(espesor, cm)
q_v = 1 @@(carga, tonf/m²)
nu_v = 0.15 @@(Poisson)
E_v = 356901 @@(módulo, kgf/cm²)

## 14 · La malla
ne_v = 6·4 @@(elementos)
nj_v = 7·5 @@(nudos)
ng_v = 4·35 @@(grados: cuatro por nudo)
A_v = dec(6/6, 2) @@(ancho de elemento, m)
B_v = dec(4/4, 2) @@(alto de elemento, m)

## 15 · La rigidez a flexión, con valores
Dp_v = dec(3569010·0.1^3/(12·(1 - 0.15^2)), 2) @@(rigidez a flexión, tonf·m)
