# Gaviones de GEO5: la junta más cargada, la presión transversal y la malla
#numerico

#: **Qué se calcula.** El marco «Dimensioning» de GEO5 Gabion con el ejemplo oficial **Demo01.gga** (el muro de la hoja 118). GEO5 revisa cada **junta entre bloques** como si la parte de arriba fuera un muro apoyado en el bloque de abajo, y elige la más cargada: la que está **sobre el bloque 1**. Ahí comprueba vuelco y deslizamiento de la parte superior, la **presión transversal** que el relleno de piedra hace contra la malla del bloque de abajo y la **unión entre bloques**.
#: **Cómo.** Con las fórmulas de la ayuda de GEO5 («Internal Stability of a Gabion» y «… Safety Factor»), leídas en LaTeX del archivo de ayuda de GEO5 2024 (imágenes 1299 a 1315), no de memoria.
#: **Qué es dato.** Como en la hoja 118, el empuje activo sobre la parte de arriba y la cuña entran con el valor que GEO5 guarda en Demo01.gga, y la sobrecarga con el de la pantalla de GEO5 2024. Todo lo demás se calcula aquí.
#: **Unidades.** kN, m y kPa por metro de muro.

## 1 · Datos

#: **La parte de arriba de la junta**: los bloques 2 a 6, todos de 1.00 m de alto, frente vertical. Alturas medidas desde la junta (y = 0 en la cara superior del bloque 1).
h_b = 1 'alto de cada bloque [m]
b_2 = 3.5 'ancho del bloque 2, el que apoya en la junta [m]
b_3 = 2.5 'ancho del bloque 3 [m]
b_4 = 2.5 'ancho del bloque 4 [m]
b_5 = 2 'ancho del bloque 5 [m]
b_6 = 1 'ancho del bloque 6 [m]
#: **El relleno de piedra** y **la malla** (marco Material, «Material No. 1»):
gamma_g = 17 'peso específico del relleno [kN/m3]
p_g = 35 'ángulo de rozamiento interno del relleno φ_d [grados]
c_g = 0 'cohesión del relleno c_d [kPa]
S_u = 40 'resistencia a tracción de la malla [kN/m]
v_p = 1 'separación de los tabiques verticales de la malla [m]
N_u = 40 'resistencia de la unión entre bloques [kN/m]
#: **Settings del ejemplo** (Wall analysis, situación permanente): factores 1.50 y el coeficiente de rozamiento entre bloques γ_{f}:
SF_o = 1.5 'factor pedido al vuelco
SF_s = 1.5 'factor pedido al deslizamiento
SF_n = 1.5 'factor pedido a la malla
g_f = 1.52 'coeficiente de reducción del rozamiento entre bloques γ_f
#: **Empuje activo sobre la parte de arriba** (dato del archivo; en Dimensioning va con coeficiente 1.000) y **la cuña** (la misma de la hoja 118, ahora 1 m más cerca de la junta):
E_ax = 81.80882951481244 'empuje activo horizontal [kN/m]
E_az = 88.41219413096738 'empuje activo vertical [kN/m]
x_a = 2.9612319343632714 'brazo de la componente vertical [m]
y_a = 1.7095521808973695 'altura de la horizontal sobre la junta [m]
W_c = 41.475906954262925 'peso de la cuña de tierra [kN/m]
x_c = 2.1803341781082652 'su brazo [m]
y_c = 3.0104434071848667 'su altura sobre la junta [m]
#: **La sobrecarga** sobre la parte de arriba (GEO5 2024, dos decimales):
S_x = 6.99 'horizontal [kN/m]
S_z = 6.98 'vertical [kN/m]
x_s = 2.9 'brazo de la vertical [m]
y_s = 1.72 'altura de la horizontal sobre la junta [m]

## 2 · El peso de lo que está encima

S_b = b_2 + b_3 + b_4 + b_5 + b_6 'suma de anchos de los bloques 2 a 6 [m]
W_g = gamma_g·h_b·S_b 'peso sobre la junta [kN/m]
x_g = (b_2^2 + b_3^2 + b_4^2 + b_5^2 + b_6^2)/(2·S_b) 'brazo del peso desde el frente [m]
y_g = h_b·(0.5·b_2 + 1.5·b_3 + 2.5·b_4 + 3.5·b_5 + 4.5·b_6)/S_b 'altura del centroide sobre la junta [m]

## 3 · Vuelco y deslizamiento de la parte de arriba

#: Ayuda de GEO5 (img 1309): M_{res}/M_{ovr} > SF_{o}, con momentos respecto del frente de la junta:
M_res = W_g·x_g + W_c·x_c + E_az·x_a + S_z·x_s 'momento resistente [kN·m/m]
M_ovr = E_ax·y_a + S_x·y_s 'momento volcador [kN·m/m]
FS_o = M_res/M_ovr 'factor de seguridad al vuelco de la junta
#: Ayuda (img 1310): [N·tan φ + c·(d − 2e)/μ + F_{res}]/H > SF_{s}. Entre bloques el rozamiento es el del **relleno** (φ = 35°, c = 0), sin geomallas (F_{res} = 0); con c = 0 el término de μ no aporta:
N_j = W_g + W_c + E_az + S_z 'normal en la junta [kN/m]
H_j = E_ax + S_x 'cortante en la junta [kN/m]
M_j = N_j·b_2/2 - (M_res - M_ovr) 'momento en el centro de la junta [kN·m/m]
e_j = M_j/N_j 'excentricidad en la junta [m]
H_res = N_j·tan(p_g·pi/180) + c_g·(b_2 - 2·e_j) 'fuerza resistente en la junta [kN/m]
FS_s = H_res/H_j 'factor de seguridad al deslizamiento de la junta

## 4 · La presión transversal sobre la malla del bloque 1

#: **La tensión normal en el bloque de abajo** (ayuda, img 1299): la de la junta repartida en el ancho comprimido más el peso de medio bloque. GEO5 imprime el primer sumando como «Maximum pressure on the bottom block»:
s_j = N_j/(b_2 - 2·e_j) 'presión de la junta sobre el bloque 1 [kPa]
s_n = s_j + gamma_g·h_b·cos(0)/2 'tensión normal en el centro del bloque 1 (frente vertical, α = 0) [kPa]
#: **La presión horizontal del relleno contra la malla** (img 1301 a 1305): GEO5 la toma como la media entre el reposo y el activo de la piedra, un empuje activo «aumentado»:
K_r = 1 - sin(p_g·pi/180) 'coeficiente en reposo del relleno
K_ag = tan(pi/4 - p_g·pi/360)^2 'coeficiente activo del relleno (Rankine)
T_r = s_n·K_r 'presión en reposo [kPa]
T_a = s_n·K_ag - 2·c_g·sqrt(K_ag) 'presión activa [kPa]
T_m = 0.5·T_r + 0.5·T_a 'presión media sobre la cara del bloque 1 [kPa]
#: **Cuántas mallas la resisten** (img 1306-1307): por metro de muro, con tabiques cada v metros, trabajan a compresión D_{total} = h/v + 1 mallas, y en la unión de arriba D_{upp} = 1:
D_t = h_b/v_p + 1 'mallas que reparten la presión transversal
D_u = 1 'mallas en la unión superior
#: **Fuerza en la malla** (img 1312) por metro de muro (b = 1 m) y su factor de seguridad (img 1311):
S_m = T_m·1·h_b/D_t 'fuerza transversal en la malla [kN/m]
FS_n = S_u/S_m 'factor de seguridad de la malla
#: **La unión entre bloques** (img 1314-1315): el rozamiento de la junta, reducido por γ_{f}, transmite Q_{tr}; si el cortante lo supera, la diferencia la toma la malla de la unión:
Q_tr = (N_j·tan(p_g·pi/180) + c_g·b_2)/g_f 'cortante que transmite el rozamiento [kN/m]
N_d = S_m + max(0, H_j - Q_tr)/D_u 'fuerza en la unión [kN/m]
FS_u = N_u/N_d 'factor de seguridad de la unión
#hide
r_Q = round(Q_tr, 1)
r_H = round(H_j, 1)
#show
#: **Lectura.** El rozamiento entre piedras transmite @{r_Q} kN/m y la junta solo pide @{r_H}: la malla de la unión no trabaja a cortante, solo recibe la presión transversal. Por eso GEO5 imprime la misma fuerza (21.82) en «Transverse pressure» y en «Joint btw. blocks».

#dibujo("La junta sobre el bloque 1 (rojo) y la presión media T contra la cara del bloque 1 (azul, 1 m = 50 kPa)", ud = m, escala = auto, cotas = m, alto = 140)
#  rect(0, -1, 3.5, 1, "gruesa")
#  rect(0, 0, 3.5, 1, "media")
#  rect(0, 1, 2.5, 1, "media")
#  rect(0, 2, 2.5, 1, "media")
#  rect(0, 3, 2, 1, "media")
#  rect(0, 4, 1, 1, "media")
#  achurado(0, -1, 3.5, 1, "cruzado")
#  linea(-0.3, 0, 3.8, 0, "gruesa rojo")
#  texto(3.9, 0, "junta sobre el bloque 1", 2.5, "i")
#  carga(0, 0, 0, -1, 0.87, 0.87, "T = 43.6 kPa", "azul", n = 4)
#  flecha(x_g, y_g + 0.9, x_g, y_g, "rojo")
#  texto(x_g + 0.1, y_g + 0.7, "W = 195.5", 2.5, "i")
#  cota(0, -1.4, 3.5, -1.4, -0.1, "3.50")
#fin

## 5 · Hekatan contra GEO5

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
#: Los porcentajes que GEO5 pone junto a cada verificación son 1.50/FS: vuelco 36.4 %, deslizamiento 57.2 %, presión transversal y unión 81.8 %.
#: **Pendiente:** cómo calcula GEO5 el empuje y la sobrecarga sobre la parte de arriba (los mismos pendientes de la hoja 118: cuña, terreno quebrado, sobrecarga trapecial). Las demás juntas (sobre los bloques 2 a 5) no se capturaron.

## 6 · NEC-SE-GC 2015

#: La NEC no habla de juntas entre bloques ni de mallas. Lo defendible (criterio mío, como hace GEO5 con sus SF) es pedir en cada junta lo mismo que al muro entero, **Tabla 5** (p. 38): vuelco ≥ 3.00 y deslizamiento ≥ 1.60 en estático. Para la malla y la unión no hay valor: se deja el 1.50 de GEO5.
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
#: Ojo: aquí el empuje entra entero (GEO5 usa coeficiente 1.000 en Dimensioning), así que no hay la rebaja del 0.5 de la hoja 118.
