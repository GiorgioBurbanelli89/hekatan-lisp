syms xi eta a b Dp nu
H1 = 1 - 3*xi^2 + 2*xi^3;
H1e = 1 - 3*eta^2 + 2*eta^3;
H2e = eta - 2*eta^2 + eta^3;
p1 = H1*H1e;
p2 = b*H1*H2e;
J = [diff(a*xi,xi), diff(b*eta,xi); diff(a*xi,eta), diff(b*eta,eta)];
detJ = det(J);
B1 = [diff(p1,xi,2)/a^2; diff(p1,eta,2)/b^2; 2*diff(diff(p1,xi),eta)/(a*b)];
B2 = [diff(p2,xi,2)/a^2; diff(p2,eta,2)/b^2; 2*diff(diff(p2,xi),eta)/(a*b)];
D = Dp*[1, nu, 0; nu, 1, 0; 0, 0, (1-nu)/2];
k11 = simplify(int(int(expand(B1.'*D*B1*detJ), xi, 0, 1), eta, 0, 1));
k12 = simplify(int(int(expand(B1.'*D*B2*detJ), xi, 0, 1), eta, 0, 1));
n = 10;
tic
for i = 1:n
J = [diff(a*xi,xi), diff(b*eta,xi); diff(a*xi,eta), diff(b*eta,eta)];
detJ = det(J);
B1 = [diff(p1,xi,2)/a^2; diff(p1,eta,2)/b^2; 2*diff(diff(p1,xi),eta)/(a*b)];
B2 = [diff(p2,xi,2)/a^2; diff(p2,eta,2)/b^2; 2*diff(diff(p2,xi),eta)/(a*b)];
D = Dp*[1, nu, 0; nu, 1, 0; 0, 0, (1-nu)/2];
k11 = simplify(int(int(expand(B1.'*D*B1*detJ), xi, 0, 1), eta, 0, 1));
k12 = simplify(int(int(expand(B1.'*D*B2*detJ), xi, 0, 1), eta, 0, 1));
end
t_pasada_ms = toc/n*1000
k11
k12
