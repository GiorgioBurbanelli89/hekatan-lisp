# COMPACTO: los simbolos, sin expandir
w_x = Phi_1·w_i + Phi_2·theta_i + Phi_3·w_j + Phi_4·theta_j
## el giro
theta_x = Phi_1'·w_i + Phi_2'·theta_i + Phi_3'·w_j + Phi_4'·theta_j
## la curvatura
kappa_x = Phi_1''·w_i + Phi_2''·theta_i + Phi_3''·w_j + Phi_4''·theta_j
## en forma de vectores
w_v = [Phi_1, Phi_2, Phi_3, Phi_4]·[w_i; theta_i; w_j; theta_j]
## y las de la placa
N_ab = Phi_a(xi)·Psi_b(eta)
