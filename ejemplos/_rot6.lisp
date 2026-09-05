# Giro
## La matriz de la barra, girada a los ejes del edificio.
Rot = [0.6, 0.8, 0; -0.8, 0.6, 0; 0, 0, 1]
K_edif = transpose(Rot)·[1, 0, 0; 0, 12, 6; 0, 6, 4]·Rot
