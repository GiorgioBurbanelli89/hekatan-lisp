# De dónde parte todo
## De UNA sola relación: la deformación en cualquier punto sale de los desplazamientos de los nudos.
## Los desplazamientos de los nudos son un vector de ocho.
d = [u_1; v_1; u_2; v_2; u_3; v_3; u_4; v_4]
## Las deformaciones en un punto son un vector de tres.
eps = [e_x; e_y; g_xy]
## Y la matriz B es la que lleva de uno al otro. ÉSTA es la relación de la que parte todo.
## eps = B por d
B = [-(1-eta)/2, 0, (1-eta)/2, 0, (1+eta)/2, 0, -(1+eta)/2, 0; 0, -(1-xi)/2, 0, -(1+xi)/2, 0, (1+xi)/2, 0, (1-xi)/2; -(1-xi)/2, -(1-eta)/2, -(1+xi)/2, (1-eta)/2, (1+xi)/2, (1+eta)/2, (1-xi)/2, -(1+eta)/2]
## Con la deformación ya se tiene la tensión, multiplicando por la constitutiva: sigma = D por eps.
D = [1, 0.15, 0; 0.15, 1, 0; 0, 0, 0.425]
## Y la ENERGÍA que se acumula en el elemento es media de la deformación por la tensión, integrada en todo el volumen.
## Sustituyendo las dos relaciones anteriores, esa energía queda en función SÓLO de los desplazamientos de los nudos.
## Y lo que queda en medio, entre el vector de nudos y su transpuesta, ES la matriz de rigidez.
## Por eso la rigidez es esa doble integral: no se elige, sale de la energía.
## Comprobación de tamaños: ocho por tres, tres por tres, tres por ocho.
t_res = 8·8
