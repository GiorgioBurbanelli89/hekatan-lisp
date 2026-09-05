# La constitutiva, invirtiendo la flexibilidad
## fracciones
F = [5/2, 0; 0, 4]
Fi = F^-1
## la flexibilidad de tension plana con nu = 0.15 (el modulo va fuera)
S = [1, -0.15, 0; -0.15, 1, 0; 0, 0, 2.3]
D = S^-1
chk = S·D
