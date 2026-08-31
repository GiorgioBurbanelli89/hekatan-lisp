# De dónde salen las cuatro funciones de forma
#: No se inventan. Salen de resolver la viga.

## La ecuación de la viga a flexión, sin carga en el vano
ec_v = EI·w'''' = 0

## Integrando cuatro veces queda un polinomio CÚBICO
w_x = a_0 + a_1·x + a_2·x^2 + a_3·x^3

## Su pendiente, derivando
dw_x = Diff{a_0 + a_1·x + a_2·x^2 + a_3·x^3 @ x}

## CUATRO constantes, CUATRO condiciones: los grados de los dos nudos
c_1 = a_0 = w_i
c_2 = a_1 = theta_i
c_3 = a_0 + a_1 + a_2 + a_3 = w_j
c_4 = a_1 + 2·a_2 + 3·a_3 = theta_j

## Eso es un sistema. Su matriz:
C_m = [1, 0, 0, 0; 0, 1, 0, 0; 1, 1, 1, 1; 0, 1, 2, 3]

## El determinante no es cero, así que tiene inversa
detC = det(C_m)

## Y la inversa es la MATRIZ DE COEFICIENTES
Ci = C_m^-1

## Se comprueba
chk = C_m·C_m^-1

## Las constantes salen de los grados
a_v = Ci·[w_i; theta_i; w_j; theta_j]

## Y las funciones de forma son la base por la inversa
Phi_v = [1, x, x^2, x^3]·[1, 0, 0, 0; 0, 1, 0, 0; 1, 1, 1, 1; 0, 1, 2, 3]^-1
