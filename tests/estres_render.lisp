# Estres del render de Hekatan LISP
#: Cada linea debe verse bien: griegos, funciones, igualdades, transpuestas, reservadas.

## 1 · Griegos minuscula
g1 = alpha + beta + gamma + delta
g2 = epsilon + zeta + eta + theta
g3 = iota + kappa + lambda + mu
g4 = nu + xi + omicron + pi
g5 = rho + sigma + tau + upsilon
g6 = phi + chi + psi + omega
lambda = 3
alpha = lambda^2
## 1b · Griegos mayuscula
G1 = Gamma + Delta + Theta + Lambda
G2 = Xi + Pi + Sigma + Phi
G3 = Psi + Omega
## 1c · Griegos con subindice
s1 = sigma_x + theta_y + lambda_1
s2 = Phi_c·epsilon_xx + tau_xy
s3 = Lambda_1 + Omega_n + Delta_u
## 1d · Unicode directo
w1 = λ + σ_x + Δ
w2 = θ_1·ε_xx
w3 = Δu + 2·π

## 2 · Funciones
f(x) = x^2 + 1
N_1(xi) = (1 - xi)/2
g(x, y) = x·y + lambda
v1 = f(2)
v2 = N_1(0.5)
#fplot f(x), x = 0 : 2
#fplot(N_1(xi), [-1 1])

## 3 · Igualdades
Ul = u_l = G·u_g
K·u = F
F_1 = Expand{Kc·(u1 - u0) + Kv·(u1 - u2)}
Fx = F_2 = Expand{Kc·(u1 - u0) + Kv·(u1 - u2)}
num = 2·3 + 4

## 4 · Transpuesta e indices
t1 = transpose(T_e)
t2 = T_e^2
t3 = K_ff^(-1)
t4 = transpose(L)
t5 = transpose(T_e)·k_e·T_e

## 5 · Reservadas
r1 = T + D
r2 = T_1 + D_c
r3 = L·D·transpose(L)
r4 = T·D
T = 3
D_c = 4
r5 = T·D_c
Pi = 7
r6 = 2·Pi

## 6 · Choques mayuscula/minuscula
c1 = m + M
c2 = l·L
c3 = g_x + G_x
c4 = k·K

## 7 · Operadores
o1 = Sum{sigma_i·lambda_i @ i = 1 : n}
o2 = Integral{theta^2 @ theta}
o3 = Derivate{sin(omega·t) @ t}
o4 = ((a + b)/(c - d))/(1 + e/f)
o5 = sqrt(lambda^2 + mu^2)
o6 = [1, -2; -3, 4]
