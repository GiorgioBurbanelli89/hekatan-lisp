# usar la funcion por su NOMBRE
Phi_1(x) = 1 - x^2·(3 - 2·x)
Phi_2(x) = L·x·(1 - x·(2 - x))
## derivar por el nombre
d1 = Diff{Phi_1(x) @ x}
## la segunda
d2 = Diff{Diff{Phi_1(x) @ x} @ x}
## el producto de dos, por el nombre
N_w = Phi_1(xi)·Phi_1(eta)
## la parcial del producto
c11 = Partial{Partial{Phi_1(xi)·Phi_1(eta) @ xi} @ xi}
## y la interpolacion
w_x = Phi_1(x)·w_i + Phi_2(x)·q_i
