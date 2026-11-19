# Placa de Kirchhoff BFS 16 x 16: rigidez simbolica (Dp, nu)
#: El mismo calculo que la hoja de wxMaxima (bfs_nativo.wxm): las funciones de Hermite, las 16 funciones del BFS como producto de dos Hermite, y la rigidez como doble integral de 0 a 1. Se mide el tiempo con tic / toc.

## 1 - Formas y curvaturas
H_1(v) = 1 - 3*v^2 + 2*v^3
H_2(v) = v - 2*v^2 + v^3
H_3(v) = 3*v^2 - 2*v^3
H_4(v) = -v^2 + v^3
N_1(x, y) = H_1(x)*H_1(y)
N_2(x, y) = H_1(x)*H_2(y)

## 2 - Rigidez: k11, k12 (dobles integrales) y la traza de las 16 diagonales
#: La traza suma las 16 diagonales. Como cada N es H_a(x)*H_b(y), la doble integral se separa en integrales de una variable: traza = Dp*(2*S2*S0 + 2*nu*S02^2 + 2*(1 - nu)*S1^2).
tic
k_11 = Area{Area{D_p*(Derivate{Derivate{N_1(x, y) @ x} @ x}^2 + Derivate{Derivate{N_1(x, y) @ y} @ y}^2 + 2*nu*Derivate{Derivate{N_1(x, y) @ x} @ x}*Derivate{Derivate{N_1(x, y) @ y} @ y}) + 2*D_p*(1 - nu)*Derivate{Derivate{N_1(x, y) @ x} @ y}^2 @ x = 0 : 1} @ y = 0 : 1}
k_12 = Area{Area{D_p*(Derivate{Derivate{N_1(x, y) @ x} @ x}*Derivate{Derivate{N_2(x, y) @ x} @ x} + Derivate{Derivate{N_1(x, y) @ y} @ y}*Derivate{Derivate{N_2(x, y) @ y} @ y} + nu*(Derivate{Derivate{N_1(x, y) @ x} @ x}*Derivate{Derivate{N_2(x, y) @ y} @ y} + Derivate{Derivate{N_1(x, y) @ y} @ y}*Derivate{Derivate{N_2(x, y) @ x} @ x})) + 2*D_p*(1 - nu)*Derivate{Derivate{N_1(x, y) @ x} @ y}*Derivate{Derivate{N_2(x, y) @ x} @ y} @ x = 0 : 1} @ y = 0 : 1}
S_0 = Area{H_1(x)^2 + H_2(x)^2 + H_3(x)^2 + H_4(x)^2 @ x = 0 : 1}
S_1 = Area{Derivate{H_1(x) @ x}^2 + Derivate{H_2(x) @ x}^2 + Derivate{H_3(x) @ x}^2 + Derivate{H_4(x) @ x}^2 @ x = 0 : 1}
S_2 = Area{Derivate{Derivate{H_1(x) @ x} @ x}^2 + Derivate{Derivate{H_2(x) @ x} @ x}^2 + Derivate{Derivate{H_3(x) @ x} @ x}^2 + Derivate{Derivate{H_4(x) @ x} @ x}^2 @ x = 0 : 1}
S_02 = Area{H_1(x)*Derivate{Derivate{H_1(x) @ x} @ x} + H_2(x)*Derivate{Derivate{H_2(x) @ x} @ x} + H_3(x)*Derivate{Derivate{H_3(x) @ x} @ x} + H_4(x)*Derivate{Derivate{H_4(x) @ x} @ x} @ x = 0 : 1}
traza = D_p*(2*S_2*S_0 + 2*nu*S_02^2 + 2*(1 - nu)*S_1^2)
toc

## 3 - Resultado
#: Esperado (wxMaxima): k11 = 2064*dp/175 ; k12 = (210*dp*nu + 542*dp)/175 ; traza = 3968/63 con dp = 1, nu = 0.15.
k_11
k_12
traza
