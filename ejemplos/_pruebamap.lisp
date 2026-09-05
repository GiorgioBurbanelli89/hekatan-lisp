# Mallado y mapas de contorno
## La malla de la losa: 6 por 4 elementos sobre 6 x 4 metros.
#malla(6, 4, [0 6], [0 4])
## Y los campos, con bandas de contorno y el colormap de CSI.
M_11 = sin(pi·x/6)·sin(pi·y/4)
#contourf(M_11, [0 6], [0 4])
V_13 = cos(pi·x/6)·sin(pi·y/4)
#contourf(V_13, [0 6], [0 4])
