% Placa de Kirchhoff BFS simbolica: funciones de forma, Jacobiano, B y rigidez
% Elemento rectangular a x b, cuadrado natural xi, eta de 0 a 1 (mismo calculo que Hekatan LISP y wxMaxima)
syms xi eta a b D_p nu
% 1 - Funciones de forma (Hermite cubicas)
H1 = 1 - 3*xi^2 + 2*xi^3
H1e = 1 - 3*eta^2 + 2*eta^3
H2e = eta - 2*eta^2 + eta^3
N1 = H1*H1e
N2 = b*H1*H2e
% 2 - Jacobiano: x = a*xi, y = b*eta
J = [diff(a*xi,xi), diff(b*eta,xi); diff(a*xi,eta), diff(b*eta,eta)]
detJ = det(J)
% 3 - Matriz B: curvaturas = B * desplazamientos
Bxx1 = diff(N1,xi,2)/a^2
Byy1 = diff(N1,eta,2)/b^2
Bxy1 = 2*diff(diff(N1,xi),eta)/(a*b)
Bxx2 = diff(N2,xi,2)/a^2
Byy2 = diff(N2,eta,2)/b^2
Bxy2 = 2*diff(diff(N2,xi),eta)/(a*b)
B1 = [Bxx1; Byy1; Bxy1]
B2 = [Bxx2; Byy2; Bxy2]
D = D_p*[1, nu, 0; nu, 1, 0; 0, 0, (1-nu)/2]
% 4 - Rigidez del elemento: k = integral de B' D B detJ
k11 = simplify(int(int(expand(B1.'*D*B1*detJ), xi, 0, 1), eta, 0, 1))
k12 = simplify(int(int(expand(B1.'*D*B2*detJ), xi, 0, 1), eta, 0, 1))
% Tiempo: el mismo calculo (J, B, D, k11, k12) repetido n veces; promedio por pasada
n = 10;
tic
for i = 1:n
  J = [diff(a*xi,xi), diff(b*eta,xi); diff(a*xi,eta), diff(b*eta,eta)];
  detJ = det(J);
  B1 = [diff(N1,xi,2)/a^2; diff(N1,eta,2)/b^2; 2*diff(diff(N1,xi),eta)/(a*b)];
  B2 = [diff(N2,xi,2)/a^2; diff(N2,eta,2)/b^2; 2*diff(diff(N2,xi),eta)/(a*b)];
  D = D_p*[1, nu, 0; nu, 1, 0; 0, 0, (1-nu)/2];
  k11 = simplify(int(int(expand(B1.'*D*B1*detJ), xi, 0, 1), eta, 0, 1));
  k12 = simplify(int(int(expand(B1.'*D*B2*detJ), xi, 0, 1), eta, 0, 1));
end
t_pasada_ms = toc/n*1000
