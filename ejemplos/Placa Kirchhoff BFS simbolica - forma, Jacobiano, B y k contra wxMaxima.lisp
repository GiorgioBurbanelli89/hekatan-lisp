# Placa de Kirchhoff BFS: funciones de forma, Jacobiano, B y rigidez (todo simbolico)
#: Elemento rectangular de lados a x b. Se trabaja en el cuadrado natural, xi y eta de 0 a 1. La misma hoja esta en wxMaxima (bfs_simbolico.wxm) para comparar.

## 1 - Funciones de forma (Hermite cubicas)
H_1(v) = 1 - 3*v^2 + 2*v^3
H_2(v) = v - 2*v^2 + v^3
#: Cada funcion del BFS es el producto de dos Hermite. N_1 es la flecha w del nudo 1; N_2 su giro dw/dy (por eso lleva el largo b).
N_1(xi, eta) = H_1(xi)*H_1(eta)
N_2(xi, eta) = b*H_1(xi)*H_2(eta)
n_1 = Expand{H_1(xi)*H_1(eta)}
n_2 = Expand{b*H_1(xi)*H_2(eta)}

tic
## 2 - Jacobiano: del cuadrado natural al rectangulo real
#: El mapa es x = a·ξ, y = b·η.
J_11 = Partial{a*xi @ xi}
J_12 = Partial{b*eta @ xi}
J_21 = Partial{a*xi @ eta}
J_22 = Partial{b*eta @ eta}
J = [J_11, J_12; J_21, J_22]
detJ = det(J)
#: Por la regla de la cadena: d/dx = (1/a) d/dxi y d/dy = (1/b) d/deta.

## 3 - Matriz B: curvaturas = B * desplazamientos
#: Cada columna de B tiene las tres curvaturas de una funcion de forma: κxx, κyy y 2·κxy.
B_xx1 = Partial{Partial{H_1(xi)*H_1(eta) @ xi} @ xi}/a^2
B_yy1 = Partial{Partial{H_1(xi)*H_1(eta) @ eta} @ eta}/b^2
B_xy1 = 2*Partial{Partial{H_1(xi)*H_1(eta) @ xi} @ eta}/(a*b)
B_xx2 = Partial{Partial{b*H_1(xi)*H_2(eta) @ xi} @ xi}/a^2
B_yy2 = Partial{Partial{b*H_1(xi)*H_2(eta) @ eta} @ eta}/b^2
B_xy2 = 2*Partial{Partial{b*H_1(xi)*H_2(eta) @ xi} @ eta}/(a*b)
B_1 = [B_xx1; B_yy1; B_xy1]
B_2 = [B_xx2; B_yy2; B_xy2]
D = D_p*[1, nu, 0; nu, 1, 0; 0, 0, (1 - nu)/2]

## 4 - Rigidez del elemento: k = ∫∫ Bᵀ·D·B·detJ
k_11 = Area{Area{transpose(B_1)*D*B_1*detJ @ xi = 0 : 1} @ eta = 0 : 1}
k_12 = Area{Area{transpose(B_1)*D*B_2*detJ @ xi = 0 : 1} @ eta = 0 : 1}
toc
#: Con a = b = 1: k11 = 2064·Dp/175 y k12 = (210·Dp·ν + 542·Dp)/175, igual que la hoja anterior.
