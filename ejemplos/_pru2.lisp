# Invertir la flexibilidad
## simbolica, sacando el modulo fuera
S_s = [1, -nu, 0; -nu, 1, 0; 0, 0, 2·(1+nu)]
D_s = S_s^-1
## numerica con nu = 0.15
S_n = [1, -0.15, 0; -0.15, 1, 0; 0, 0, 2.3]
D_n = S_n^-1
chk = S_n·D_n
