# GEO5 gabions: the most loaded joint, the transverse pressure and the mesh
#numerico

#: **What is calculated.** The «Dimensioning» frame of GEO5 Gabion with the official example **Demo01.gga** (the wall of sheet 118). GEO5 checks each **joint between blocks** as if the part above were a wall resting on the block below, and picks the most loaded one: the one **over block 1**. There it checks overturning and sliding of the upper part, the **transverse pressure** that the stone fill exerts against the mesh of the block below and the **connection between blocks**.
#: **How.** With the formulas of the GEO5 help («Internal Stability of a Gabion» and «… Safety Factor»), read in LaTeX from the GEO5 2024 help file (images 1299 to 1315), not from memory.
#: **What is data.** As in sheet 118, the active thrust on the upper part and the wedge enter with the value GEO5 stores in Demo01.gga, and the surcharge with that of the GEO5 2024 screen. Everything else is calculated here.
#: **Units.** kN, m and kPa per meter of wall.

## 1 · Data

#: **The part above the joint**: blocks 2 to 6, all 1.00 m high, vertical face. Heights measured from the joint (y = 0 at the top face of block 1).
h_b = 1 'height of each block [m]
b_2 = 3.5 'width of block 2, the one that rests on the joint [m]
b_3 = 2.5 'width of block 3 [m]
b_4 = 2.5 'width of block 4 [m]
b_5 = 2 'width of block 5 [m]
b_6 = 1 'width of block 6 [m]
#: **The stone fill** and **the mesh** (Material frame, «Material No. 1»):
gamma_g = 17 'unit weight of the fill [kN/m3]
p_g = 35 'internal friction angle of the fill φ_d [degrees]
c_g = 0 'cohesion of the fill c_d [kPa]
S_u = 40 'tensile strength of the mesh [kN/m]
v_p = 1 'spacing of the vertical partitions of the mesh [m]
N_u = 40 'strength of the connection between blocks [kN/m]
#: **Settings of the example** (Wall analysis, permanent situation): factors 1.50 and the friction coefficient between blocks γ_{f}:
SF_o = 1.5 'factor required for overturning
SF_s = 1.5 'factor required for sliding
SF_n = 1.5 'factor required for the mesh
g_f = 1.52 'friction reduction coefficient between blocks γ_f
#: **Active thrust on the upper part** (file datum; in Dimensioning it has coefficient 1.000) and **the wedge** (the same as in sheet 118, now 1 m closer to the joint):
E_ax = 81.80882951481244 'horizontal active thrust [kN/m]
E_az = 88.41219413096738 'vertical active thrust [kN/m]
x_a = 2.9612319343632714 'arm of the vertical component [m]
y_a = 1.7095521808973695 'height of the horizontal one above the joint [m]
W_c = 41.475906954262925 'weight of the earth wedge [kN/m]
x_c = 2.1803341781082652 'its arm [m]
y_c = 3.0104434071848667 'its height above the joint [m]
#: **The surcharge** on the upper part (GEO5 2024, two decimals):
S_x = 6.99 'horizontal [kN/m]
S_z = 6.98 'vertical [kN/m]
x_s = 2.9 'arm of the vertical [m]
y_s = 1.72 'height of the horizontal above the joint [m]

## 2 · The weight of what is above

S_b = b_2 + b_3 + b_4 + b_5 + b_6 'sum of the widths of blocks 2 to 6 [m]
W_g = gamma_g·h_b·S_b 'weight over the joint [kN/m]
x_g = (b_2^2 + b_3^2 + b_4^2 + b_5^2 + b_6^2)/(2·S_b) 'weight arm from the front [m]
y_g = h_b·(0.5·b_2 + 1.5·b_3 + 2.5·b_4 + 3.5·b_5 + 4.5·b_6)/S_b 'centroid height above the joint [m]

## 3 · Overturning and sliding of the upper part

#: GEO5 help (img 1309): M_{res}/M_{ovr} > SF_{o}, with moments about the front of the joint:
M_res = W_g·x_g + W_c·x_c + E_az·x_a + S_z·x_s 'resisting moment [kN·m/m]
M_ovr = E_ax·y_a + S_x·y_s 'overturning moment [kN·m/m]
FS_o = M_res/M_ovr 'joint overturning safety factor
#: Help (img 1310): [N·tan φ + c·(d − 2e)/μ + F_{res}]/H > SF_{s}. Between blocks the friction is that of the **fill** (φ = 35°, c = 0), without geogrids (F_{res} = 0); with c = 0 the μ term contributes nothing:
N_j = W_g + W_c + E_az + S_z 'normal at the joint [kN/m]
H_j = E_ax + S_x 'shear at the joint [kN/m]
M_j = N_j·b_2/2 - (M_res - M_ovr) 'moment at the center of the joint [kN·m/m]
e_j = M_j/N_j 'eccentricity at the joint [m]
H_res = N_j·tan(p_g·pi/180) + c_g·(b_2 - 2·e_j) 'resisting force at the joint [kN/m]
FS_s = H_res/H_j 'joint sliding safety factor

## 4 · The transverse pressure on the mesh of block 1

#: **The normal stress in the block below** (help, img 1299): that of the joint spread over the compressed width plus the weight of half a block. GEO5 prints the first term as «Maximum pressure on the bottom block»:
s_j = N_j/(b_2 - 2·e_j) 'joint pressure on block 1 [kPa]
s_n = s_j + gamma_g·h_b·cos(0)/2 'normal stress at the center of block 1 (vertical face, α = 0) [kPa]
#: **The horizontal pressure of the fill against the mesh** (img 1301 to 1305): GEO5 takes it as the mean between the at-rest and the active pressure of the stone, an «increased» active thrust:
K_r = 1 - sin(p_g·pi/180) 'at-rest coefficient of the fill
K_ag = tan(pi/4 - p_g·pi/360)^2 'active coefficient of the fill (Rankine)
T_r = s_n·K_r 'at-rest pressure [kPa]
T_a = s_n·K_ag - 2·c_g·sqrt(K_ag) 'active pressure [kPa]
T_m = 0.5·T_r + 0.5·T_a 'mean pressure on the face of block 1 [kPa]
#: **How many meshes resist it** (img 1306-1307): per meter of wall, with partitions every v meters, D_{total} = h/v + 1 meshes work in compression, and at the upper connection D_{upp} = 1:
D_t = h_b/v_p + 1 'meshes that distribute the transverse pressure
D_u = 1 'meshes at the upper connection
#: **Force in the mesh** (img 1312) per meter of wall (b = 1 m) and its safety factor (img 1311):
S_m = T_m·1·h_b/D_t 'transverse force in the mesh [kN/m]
FS_n = S_u/S_m 'mesh safety factor
#: **The connection between blocks** (img 1314-1315): the friction of the joint, reduced by γ_{f}, transmits Q_{tr}; if the shear exceeds it, the difference is taken by the mesh of the connection:
Q_tr = (N_j·tan(p_g·pi/180) + c_g·b_2)/g_f 'shear transmitted by the friction [kN/m]
N_d = S_m + max(0, H_j - Q_tr)/D_u 'force in the connection [kN/m]
FS_u = N_u/N_d 'connection safety factor
#hide
r_Q = round(Q_tr, 1)
r_H = round(H_j, 1)
#show
#: **Reading.** The friction between stones transmits @{r_Q} kN/m and the joint only demands @{r_H}: the mesh of the connection does not work in shear, it only receives the transverse pressure. That is why GEO5 prints the same force (21.82) in «Transverse pressure» and in «Joint btw. blocks».

#dibujo("The joint over block 1 (red) and the mean pressure T against the face of block 1 (blue, 1 m = 50 kPa)", ud = m, escala = auto, cotas = m, alto = 140)
#  rect(0, -1, 3.5, 1, "gruesa")
#  rect(0, 0, 3.5, 1, "media")
#  rect(0, 1, 2.5, 1, "media")
#  rect(0, 2, 2.5, 1, "media")
#  rect(0, 3, 2, 1, "media")
#  rect(0, 4, 1, 1, "media")
#  achurado(0, -1, 3.5, 1, "cruzado")
#  linea(-0.3, 0, 3.8, 0, "gruesa rojo")
#  texto(3.9, 0, "joint over block 1", 2.5, "i")
#  carga(0, 0, 0, -1, 0.87, 0.87, "T = 43.6 kPa", "azul", n = 4)
#  flecha(x_g, y_g + 0.9, x_g, y_g, "rojo")
#  texto(x_g + 0.1, y_g + 0.7, "W = 195.5", 2.5, "i")
#  cota(0, -1.4, 3.5, -1.4, -0.1, "3.50")
#fin

## 5 · Hekatan against GEO5

#hide
g_W = 195.50
g_xg = 1.29
g_Mr = 625.37
g_Mo = 151.90
g_FSo = 4.12
g_Hr = 232.73
g_Ha = 88.80
g_FSs = 2.62
g_sj = 116.66
g_T = 43.64
g_Q = 153.11
g_S = 21.82
g_FSn = 1.83
g_Nd = 21.82
h_W = round(W_g, 2)
h_xg = round(x_g, 2)
h_Mr = round(M_res, 2)
h_Mo = round(M_ovr, 2)
h_FSo = round(FS_o, 2)
h_Hr = round(H_res, 2)
h_Ha = round(H_j, 2)
h_FSs = round(FS_s, 2)
h_sj = round(s_j, 2)
h_T = round(T_m, 2)
h_Q = round(Q_tr, 2)
h_S = round(S_m, 2)
h_FSn = round(FS_n, 2)
h_Nd = round(N_d, 2)
d_W = round(100·(h_W/g_W - 1), 3)
d_xg = round(100·(h_xg/g_xg - 1), 3)
d_Mr = round(100·(h_Mr/g_Mr - 1), 3)
d_Mo = round(100·(h_Mo/g_Mo - 1), 3)
d_FSo = round(100·(h_FSo/g_FSo - 1), 3)
d_Hr = round(100·(h_Hr/g_Hr - 1), 3)
d_Ha = round(100·(h_Ha/g_Ha - 1), 3)
d_FSs = round(100·(h_FSs/g_FSs - 1), 3)
d_sj = round(100·(h_sj/g_sj - 1), 3)
d_T = round(100·(h_T/g_T - 1), 3)
d_Q = round(100·(h_Q/g_Q - 1), 3)
d_S = round(100·(h_S/g_S - 1), 3)
d_FSn = round(100·(h_FSn/g_FSn - 1), 3)
d_Nd = round(100·(h_Nd/g_Nd - 1), 3)
#show
#| Magnitud (junta sobre el bloque 1) | Hekatan | GEO5 2024 | Diferencia [%] |
#|---|---:|---:|---:|
#| peso encima [kN/m] | @{h_W} | @{g_W} | @{d_W} |
#| su brazo x [m] | @{h_xg} | @{g_xg} | @{d_xg} |
#| **M_{res} [kN·m/m]** | @{h_Mr} | @{g_Mr} | @{d_Mr} |
#| **M_{ovr} [kN·m/m]** | @{h_Mo} | @{g_Mo} | @{d_Mo} |
#| FS vuelco | @{h_FSo} | @{g_FSo} | @{d_FSo} |
#| **H_{res} [kN/m]** | @{h_Hr} | @{g_Hr} | @{d_Hr} |
#| **H_{act} [kN/m]** | @{h_Ha} | @{g_Ha} | @{d_Ha} |
#| FS deslizamiento | @{h_FSs} | @{g_FSs} | @{d_FSs} |
#| presión máxima sobre el bloque 1 [kPa] | @{h_sj} | @{g_sj} | @{d_sj} |
#| presión media en la cara T [kPa] | @{h_T} | @{g_T} | @{d_T} |
#| cortante que transmite el rozamiento [kN/m] | @{h_Q} | @{g_Q} | @{d_Q} |
#| **fuerza transversal en la malla [kN/m]** | @{h_S} | @{g_S} | @{d_S} |
#| FS malla | @{h_FSn} | @{g_FSn} | @{d_FSn} |
#| **fuerza en la unión [kN/m]** | @{h_Nd} | @{g_Nd} | @{d_Nd} |
#: The percentages that GEO5 puts next to each check are 1.50/SF: overturning 36.4 %, sliding 57.2 %, transverse pressure and connection 81.8 %.
#: **Pending:** how GEO5 calculates the thrust and the surcharge on the upper part (the same pending items as in sheet 118: wedge, broken terrain, trapezoidal surcharge). The other joints (over blocks 2 to 5) were not captured.

## 6 · NEC-SE-GC 2015

#: NEC says nothing about joints between blocks or meshes. What is defensible (my own criterion, as GEO5 does with its SF) is to require at each joint the same as for the whole wall, **Table 5** (p. 38): overturning ≥ 3.00 and sliding ≥ 1.60 in static. For the mesh and the connection there is no value: the GEO5 1.50 is kept.
#hide
n_o = round(FS_o, 2)
n_s = round(FS_s, 2)
n_n = round(FS_n, 2)
#show
#| Verificación de la junta | Hekatan = GEO5 | NEC-15 (aplicada a la junta) | ¿Cumple? |
#|---|---:|---:|---|
#| Vuelco | @{n_o} | 3.00 | sí |
#| Deslizamiento | @{n_s} | 1.60 | sí |
#| Malla y unión | @{n_n} | (sin valor; GEO5 1.50) | sí con 1.50 |
#: Note: here the thrust enters whole (GEO5 uses coefficient 1.000 in Dimensioning), so there is no 0.5 reduction as in sheet 118.
