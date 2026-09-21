# El pórtico en 3D: seis grados de libertad por nudo, y cuatro físicas por barra
## En el plano cada nudo tenía tres grados de libertad. En el espacio tiene seis: se corre en tres direcciones y gira alrededor de tres ejes.
gdl_nudo = 3 + 3
## Y como cada barra toca dos nudos, su matriz de rigidez pasa de seis por seis a doce por doce.
gdl_barra = 2·6
tam_2d = 6^2
tam_3d = 12^2
## Dentro de esa matriz no hay una física nueva: hay CUATRO, y ninguna se habla con las otras.
## La primera es estirarse a lo largo, la misma del plano.
k_axial = EA/L
## La segunda es doblarse en un plano de la barra. Salen los números de las Hermite.
k_fz = 12·EI_z/L^3
## La tercera es doblarse en el OTRO plano de la barra. Lo mismo, con la otra inercia.
k_fy = 12·EI_y/L^3
## Y la cuarta es nueva y en el plano no existía: torcerse sobre su propio eje.
k_torsion = GJ/L
## La torsión se deduce igual que el axial: el giro por unidad de largo es constante, así que la función de forma vuelve a ser una RECTA.
phi_1 = 1 - x/L
phi_2 = x/L
## Esa es toda la matriz de doce por doce: cuatro bloques puestos uno al lado del otro, sin mezclarse.
K_12 = [EA/L, 0, 0, 0; 0, GJ/L, 0, 0; 0, 0, 12·EI_y/L^3, 0; 0, 0, 0, 12·EI_z/L^3]
## Y hay algo que en el plano no importaba: en el espacio, la barra puede estar girada sobre su propio eje. Ese ángulo decide cuál inercia trabaja en cada dirección.
I_fuerte = b·h^3/12
I_debil = h·b^3/12
## Una columna de treinta por sesenta es cuatro veces más rígida en un sentido que en el otro.
razon = 60^2/30^2
## Girar la barra ya no es una matriz de tres por tres con un coseno: son los tres ejes locales puestos como filas.
Rot_3 = [x_1, x_2, x_3; y_1, y_2, y_3; z_1, z_2, z_3]
## Y sin losa, cada pórtico del edificio se defiende solo: nada obliga a que dos pórticos paralelos se muevan juntos.
