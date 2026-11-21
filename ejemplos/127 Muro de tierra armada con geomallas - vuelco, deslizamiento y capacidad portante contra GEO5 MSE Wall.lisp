# Muro de tierra armada con geomallas: vuelco, deslizamiento y capacidad portante, contra GEO5 MSE Wall
#numerico

#: **Qué se calcula.** El muro del ejemplo oficial de GEO5 MSE Wall (**Demo01.gms**): 20 bloques de hormigón de 0.20 m de alto y 0.50 m de ancho, cada uno retirado 0.05 m hacia atrás, con una geomalla Miragrid 5XT de 3.50 m cada dos bloques, y una sobrecarga de 35 kPa arriba. Se reproduce la **verificación externa** de GEO5: el bloque «suelo + bloques + geomallas» trabaja como un **muro de gravedad ficticio** (marcos «Verification» y «Bearing cap.»).
#: **Cómo.** Con la ayuda de GEO5 («Active Earth Pressure – The Coulomb Theory») y la geometría del archivo .gms. El archivo es binario y guarda, además de los datos, **los resultados enteros** (cada fuerza con su brazo): contra esos se compara, a 4 decimales.
#: **Juez.** GEO5 2024: vuelco 22.01, deslizamiento 8.26, tensión bajo los bloques 109.47 kPa contra 150 kPa (NOT SATISFACTORY, 1.37 < 1.50).
#: **Unidades.** kN, m y kPa por metro de muro (como GEO5); el resumen también en tonf. Los ángulos dentro de las fórmulas en radianes.

## 1 · Datos (Demo01.gms)

#: **Los bloques.** El origen x = 0 es el pie del bloque de abajo; h es la altura sobre la base de los bloques.
n_b = 20 'número de bloques
h_b = 0.20 'alto de cada bloque [m]
b_b = 0.50 'ancho de cada bloque [m]
o_b = 0.05 'retiro de cada bloque respecto al de abajo [m]
gamma_b = 23 'peso específico del bloque [kN/m3]
H_w = n_b·h_b 'altura del muro [m]
#: **El relleno** (Soil No. 1, el mismo detrás y bajo el muro):
gamma_s = 19 'peso específico [kN/m3]
phi_s = 29 'ángulo de rozamiento [grados]
c_s = 8 'cohesión [kPa]
q_s = 35 'sobrecarga permanente en toda la superficie [kPa]
#: **Las geomallas.** Ocho, cada 0.40 m desde la base (h = 0, 0.4 … 2.8), de 3.50 m medidos desde la espalda del bloque:
L_g = 3.5 'largo de la geomalla [m]
h_top = 2.8 'altura de la geomalla de arriba [m]
#: **Lo que exige el ejemplo:** factores de 1.50 a vuelco, deslizamiento y capacidad portante, y una capacidad del suelo dada de 150 kPa.
R_d = 150 'capacidad portante dada del suelo de cimentación [kPa]

#dibujo("Corte del muro: bloques, geomallas (rojo), espalda ficticia (azul) y sobrecarga", ud = m, escala = auto, cotas = m, alto = 170)
#  rect(0.00, 0.00, 0.5, 0.2, "media")
#  rect(0.05, 0.20, 0.5, 0.2, "media")
#  rect(0.10, 0.40, 0.5, 0.2, "media")
#  rect(0.15, 0.60, 0.5, 0.2, "media")
#  rect(0.20, 0.80, 0.5, 0.2, "media")
#  rect(0.25, 1.00, 0.5, 0.2, "media")
#  rect(0.30, 1.20, 0.5, 0.2, "media")
#  rect(0.35, 1.40, 0.5, 0.2, "media")
#  rect(0.40, 1.60, 0.5, 0.2, "media")
#  rect(0.45, 1.80, 0.5, 0.2, "media")
#  rect(0.50, 2.00, 0.5, 0.2, "media")
#  rect(0.55, 2.20, 0.5, 0.2, "media")
#  rect(0.60, 2.40, 0.5, 0.2, "media")
#  rect(0.65, 2.60, 0.5, 0.2, "media")
#  rect(0.70, 2.80, 0.5, 0.2, "media")
#  rect(0.75, 3.00, 0.5, 0.2, "media")
#  rect(0.80, 3.20, 0.5, 0.2, "media")
#  rect(0.85, 3.40, 0.5, 0.2, "media")
#  rect(0.90, 3.60, 0.5, 0.2, "media")
#  rect(0.95, 3.80, 0.5, 0.2, "media")
#  linea(0.50, 0.00, 4.00, 0.00, "media rojo")
#  linea(0.60, 0.40, 4.10, 0.40, "media rojo")
#  linea(0.70, 0.80, 4.20, 0.80, "media rojo")
#  linea(0.80, 1.20, 4.30, 1.20, "media rojo")
#  linea(0.90, 1.60, 4.40, 1.60, "media rojo")
#  linea(1.00, 2.00, 4.50, 2.00, "media rojo")
#  linea(1.10, 2.40, 4.60, 2.40, "media rojo")
#  linea(1.20, 2.80, 4.70, 2.80, "media rojo")
#  linea(4.00, 0.00, 4.70, 2.80, "gruesa azul")
#  linea(4.70, 2.80, 4.70, 4.00, "gruesa azul")
#  linea(0.95, 4.0, 7.0, 4.0, "media verde")
#  linea(-0.8, 0.0, 7.0, 0.0, "fina")
#  flecha(2.0, 4.6, 2.0, 4.05, "rojo")
#  flecha(3.0, 4.6, 3.0, 4.05, "rojo")
#  flecha(4.0, 4.6, 4.0, 4.05, "rojo")
#  flecha(5.5, 4.6, 5.5, 4.05, "rojo")
#  texto(4.4, 4.75, "q = 35 kPa", 2.6, "i")
#  texto(4.85, 1.5, "espalda ficticia", 2.6, "i")
#  texto(2.0, -0.25, "base del bloque reforzado B = 4.00", 2.6, "c")
#  cota(-0.5, 0, -0.5, 4.0, -0.2, "4.00")
#fin

## 2 · El muro ficticio

#: GEO5 cierra el bloque reforzado con una **espalda ficticia** que une los extremos de las geomallas: desde el extremo de la de abajo (x = 0.50 + 3.50 = 4.00) sube con el mismo talud de los bloques (0.05 cada 0.20, o sea 1:4) hasta la de arriba, y de ahí sigue **vertical** hasta la superficie.
x_0 = b_b + L_g 'extremo de la geomalla de abajo = ancho B de la base [m]
t_b = o_b/h_b 'talud de la cara y de la espalda ficticia (1:4)
x_t = x_0 + t_b·h_top 'extremo de la geomalla de arriba [m]
#: **El peso del suelo reforzado** = área entre la espalda de los bloques y la espalda ficticia, por γ. El área bajo la espalda ficticia, menos el área que ocupan los bloques hasta su espalda:
A_vb = x_0·h_top + t_b·h_top^2/2 + x_t·(H_w - h_top) 'área bajo la espalda ficticia [m2]
A_bb = n_b·h_b·b_b + h_b·o_b·n_b·(n_b - 1)/2 'área hasta la espalda de los bloques [m2]
A_r = A_vb - A_bb 'área del suelo reforzado [m2]
W_r = gamma_s·A_r 'peso del suelo reforzado [kN/m]
#: Su brazo: el primer momento del área respecto a x = 0 (cada franja aporta x²/2), dividido por el área:
S_vb = x_0^2·h_top/2 + x_0·t_b·h_top^2/2 + t_b^2·h_top^3/6 + x_t^2/2·(H_w - h_top) 'momento estático bajo la espalda ficticia [m3]
#hide
S_bb = 0
for i = 0:n_b - 1
  S_bb = S_bb + h_b·(b_b + o_b·i)^2/2
end
#show
S_bb 'suma bloque a bloque de h·(x_espalda)²/2 [m3]
x_r = (S_vb - S_bb)/A_r 'brazo del peso del suelo reforzado [m]
#: **El peso de los bloques** y su brazo (cada bloque centrado en 0.25 + 0.05·i):
W_b = n_b·h_b·b_b·gamma_b 'peso de los bloques [kN/m]
x_b = b_b/2 + o_b·(n_b - 1)/2 'brazo del peso de los bloques [m]
#: **La sobrecarga sobre el bloque reforzado**: desde la espalda del bloque de arriba hasta la espalda ficticia:
x_1 = b_b + o_b·(n_b - 1) 'espalda del bloque de arriba [m]
Q_r = q_s·(x_t - x_1) 'sobrecarga sobre el suelo reforzado [kN/m]
x_q = (x_1 + x_t)/2 'su brazo [m]

## 3 · El empuje sobre la espalda ficticia (Coulomb)

#: Detrás de la espalda ficticia hay **suelo contra suelo**, así que el rozamiento en la espalda es el del propio suelo, δ = φ (Stage settings: «Reduction of soil/soil friction angle: do not reduce»). Fórmulas de la ayuda (β = 0): K_{a} = cos²(φ − α) / (cos²α·cos(α + δ)·(1 + √(sen(φ + δ)·sen φ/(cos(α + δ)·cos α)))²) y K_{ahc} = cos φ·cos(δ − α)/(1 + sen(φ + δ − α)).
#: El tramo de abajo se inclina hacia el relleno: α = −atan(1/4) en la convención de K_{a}. Con los resultados guardados en el .gms, el término de cohesión K_{ahc} cuadra con **+atan(1/4)**: en la fórmula de la ayuda el signo de α va al revés (se comprobó en este ejemplo y en el de Nailed Slope, hoja 128).
f_s = phi_s·pi/180 'φ [rad]
a_2 = -atan(t_b) 'inclinación del tramo de abajo [rad]
K_a1 = cos(f_s)^2/(cos(f_s)·(1 + sqrt(sin(2·f_s)·sin(f_s)/cos(f_s)))^2) 'K_a del tramo vertical (α = 0, δ = φ)
K_a2 = cos(f_s - a_2)^2/(cos(a_2)^2·cos(a_2 + f_s)·(1 + sqrt(sin(2·f_s)·sin(f_s)/(cos(a_2 + f_s)·cos(a_2))))^2) 'K_a del tramo inclinado
K_h1 = K_a1·cos(f_s) 'componente horizontal, tramo vertical
K_h2 = K_a2·cos(a_2 + f_s) 'componente horizontal, tramo inclinado
C_h1 = 2·c_s·cos(f_s)·cos(f_s)/(1 + sin(2·f_s)) 'cohesión horizontal, tramo vertical [kPa]
C_h2 = 2·c_s·cos(f_s)·cos(f_s + a_2)/(1 + sin(2·f_s + a_2)) 'cohesión horizontal, tramo inclinado [kPa]
#: **La tierra sola** (σ_{z} = γ·z) no empuja hasta que σ_{z}·K_{h2} supera la cohesión: el tramo vertical (z < 1.20 m) queda entero en tracción y el inclinado empieza a empujar en z_{0}:
z_t = H_w - h_top 'profundidad donde cambia la espalda [m]
z_0 = C_h2/(gamma_s·K_h2) 'profundidad donde la tierra empieza a empujar [m]
e_b = gamma_s·H_w·K_h2 - C_h2 'presión de la tierra en la base [kPa]
E_s = e_b·(H_w - z_0)/2 'empuje de la tierra [kN/m]
h_s = (H_w - z_0)/3 'altura de su resultante sobre la base [m]
x_s = x_0 + t_b·h_s 'su punto en la espalda ficticia [m]
V_s = E_s·tan(a_2 + f_s) 'componente vertical (inclinada α + δ) [kN/m]
#: **La sobrecarga** se suma a la tierra; la parte de la cohesión que la tierra no alcanzó a vencer se descuenta de la sobrecarga (corte en tracción del total):
e_q0 = q_s·K_h1 - C_h1 'en la superficie [kPa]
e_q1 = gamma_s·z_t·K_h1 + q_s·K_h1 - C_h1 'al pie del tramo vertical [kPa]
e_q2 = gamma_s·z_t·K_h2 + q_s·K_h2 - C_h2 'al empezar el tramo inclinado [kPa]
e_q3 = q_s·K_h2 'desde z_0 hasta la base (constante) [kPa]
E_q1 = (e_q0 + e_q1)/2·z_t 'tramo vertical [kN/m]
E_q2 = (e_q2 + e_q3)/2·(z_0 - z_t) 'tramo inclinado, de z_t a z_0 [kN/m]
E_q3 = e_q3·(H_w - z_0) 'tramo inclinado, de z_0 a la base [kN/m]
E_q = E_q1 + E_q2 + E_q3 'empuje de la sobrecarga [kN/m]
#: Su altura sobre la base (centro de cada trapecio):
y_1 = (H_w - z_t) + z_t·(e_q1 + 2·e_q0)/(3·(e_q0 + e_q1)) 'altura del centro del tramo vertical [m]
y_2 = (H_w - z_0) + (z_0 - z_t)·(e_q3 + 2·e_q2)/(3·(e_q2 + e_q3)) 'altura del centro del tramo z_t-z_0 [m]
y_3 = (H_w - z_0)/2 'altura del centro del tramo constante [m]
h_q = (E_q1·y_1 + E_q2·y_2 + E_q3·y_3)/E_q 'altura de la resultante de la sobrecarga [m]
#: **La componente vertical de la sobrecarga**: en los datos que guarda GEO5 es q·K_{a}·sen(α + δ) **constante en toda la espalda** (sin el descuento de la cohesión), y su brazo es el centro de esas fuerzas verticales:
V_q1 = q_s·K_a1·sin(f_s)·z_t 'vertical, tramo vertical [kN/m]
V_q2 = q_s·K_a2·sin(a_2 + f_s)·h_top 'vertical, tramo inclinado [kN/m]
V_q = V_q1 + V_q2 'componente vertical de la sobrecarga [kN/m]
x_vq = (V_q1·x_t + V_q2·(x_0 + t_b·h_top/2))/V_q 'su brazo [m]

## 4 · Vuelco, deslizamiento y capacidad portante

#: **Vuelco** alrededor del pie (x = 0): resisten los pesos y las componentes verticales; vuelcan las horizontales.
M_res = W_r·x_r + W_b·x_b + Q_r·x_q + V_s·x_s + V_q·x_vq 'momento resistente [kN·m/m]
M_vol = E_s·h_s + E_q·h_q 'momento volcador [kN·m/m]
FS_v = M_res/M_vol 'factor de seguridad al vuelco
#: **Deslizamiento** en la base del bloque reforzado (ancho B = x_{0}), con el φ y la c del suelo de cimentación:
N_v = W_r + W_b + Q_r + V_s + V_q 'fuerza vertical total [kN/m]
H_t = E_s + E_q 'fuerza horizontal total [kN/m]
R_s = N_v·tan(f_s) + c_s·x_0 'resistencia al deslizamiento [kN/m]
FS_d = R_s/H_t 'factor de seguridad al deslizamiento
#: **Excentricidad** respecto al centro de la base:
e_c = x_0/2 - (M_res - M_vol)/N_v 'excentricidad (positiva hacia el pie) [m]
#hide
r_ec = round(e_c, 3)
#show
#: Sale e = @{r_ec} m: **negativa**, la resultante cae detrás del centro, hacia el relleno. GEO5 marca «ECCENTRICITY: 0.0 %» y no recorta el ancho: la presión es la carga entre el ancho entero (es lo que guarda: 437.872577/4 = 109.468144 exacto).
sigma_b = N_v/x_0 'presión bajo el bloque reforzado [kPa]
FS_c = R_d/sigma_b 'factor de capacidad portante
U_c = sigma_b/(R_d/1.5)·100 'aprovechamiento con el 1.50 del ejemplo [%]
#: **En tonf** (1 tonf = 9.80665 kN):
N_ton = N_v/9.80665 'vertical total [tonf/m]
s_ton = sigma_b/9.80665 'presión bajo el muro [tonf/m2]
#hide
r_fv = round(FS_v, 2)
r_fd = round(FS_d, 2)
r_fc = round(FS_c, 2)
r_uc = round(U_c, 1)
#show
#: **Lectura.** El muro no vuelca (FS @{r_fv}) ni desliza (FS @{r_fd}): el bloque reforzado pesa mucho y empuja poco porque el relleno tiene cohesión. Lo que falla es el **suelo de cimentación**: 150/σ = @{r_fc} < 1.50, aprovechamiento @{r_uc} % → **NOT SATISFACTORY**, igual que GEO5.

## 5 · Hekatan contra GEO5

#hide
g_Wr = 264.48
g_xr = 2.71086
g_Wb = 46
g_xb = 0.725
g_Q = 113.75
g_Es = 7.461617
g_hs = 0.651795
g_Vs = 1.994276
g_Eq = 25.781831
g_hq = 1.857369
g_Vq = 11.648301
g_xq = 4.53833
g_Mr = 1161.265326
g_Mv = 52.749823
g_N = 437.872577
g_FSv = 22.01
g_FSd = 8.26
g_sig = 109.468144
g_FSc = 1.37
hk_1 = round(W_r, 4)
hk_2 = round(x_r, 4)
hk_3 = round(W_b, 4)
hk_4 = round(x_b, 4)
hk_5 = round(Q_r, 4)
hk_6 = round(E_s, 4)
hk_7 = round(h_s, 4)
hk_8 = round(V_s, 4)
hk_9 = round(E_q, 4)
hk_10 = round(h_q, 4)
hk_11 = round(V_q, 4)
hk_12 = round(x_vq, 4)
hk_13 = round(M_res, 4)
hk_14 = round(M_vol, 4)
hk_15 = round(N_v, 4)
hk_16 = round(FS_v, 2)
hk_17 = round(FS_d, 2)
hk_18 = round(sigma_b, 4)
hk_19 = round(FS_c, 2)
dk_1 = round(100·(hk_1/g_Wr - 1), 4)
dk_2 = round(100·(hk_2/g_xr - 1), 4)
dk_3 = round(100·(hk_3/g_Wb - 1), 4)
dk_4 = round(100·(hk_4/g_xb - 1), 4)
dk_5 = round(100·(hk_5/g_Q - 1), 4)
dk_6 = round(100·(hk_6/g_Es - 1), 4)
dk_7 = round(100·(hk_7/g_hs - 1), 4)
dk_8 = round(100·(hk_8/g_Vs - 1), 4)
dk_9 = round(100·(hk_9/g_Eq - 1), 4)
dk_10 = round(100·(hk_10/g_hq - 1), 4)
dk_11 = round(100·(hk_11/g_Vq - 1), 4)
dk_12 = round(100·(hk_12/g_xq - 1), 4)
dk_13 = round(100·(hk_13/g_Mr - 1), 4)
dk_14 = round(100·(hk_14/g_Mv - 1), 4)
dk_15 = round(100·(hk_15/g_N - 1), 4)
dk_16 = round(100·(hk_16/g_FSv - 1), 4)
dk_17 = round(100·(hk_17/g_FSd - 1), 4)
dk_18 = round(100·(hk_18/g_sig - 1), 4)
dk_19 = round(100·(hk_19/g_FSc - 1), 4)
#show
#| Magnitud | Hekatan | GEO5 2024 (.gms) | Diferencia [%] |
#|---|---:|---:|---:|
#| peso del suelo reforzado [kN/m] | @{hk_1} | @{g_Wr} | @{dk_1} |
#| su brazo [m] | @{hk_2} | @{g_xr} | @{dk_2} |
#| peso de los bloques [kN/m] | @{hk_3} | @{g_Wb} | @{dk_3} |
#| su brazo [m] | @{hk_4} | @{g_xb} | @{dk_4} |
#| sobrecarga sobre el bloque [kN/m] | @{hk_5} | @{g_Q} | @{dk_5} |
#| empuje de la tierra, horizontal [kN/m] | @{hk_6} | @{g_Es} | @{dk_6} |
#| su altura sobre la base [m] | @{hk_7} | @{g_hs} | @{dk_7} |
#| empuje de la tierra, vertical [kN/m] | @{hk_8} | @{g_Vs} | @{dk_8} |
#| empuje de la sobrecarga, horizontal [kN/m] | @{hk_9} | @{g_Eq} | @{dk_9} |
#| su altura sobre la base [m] | @{hk_10} | @{g_hq} | @{dk_10} |
#| empuje de la sobrecarga, vertical [kN/m] | @{hk_11} | @{g_Vq} | @{dk_11} |
#| su brazo [m] | @{hk_12} | @{g_xq} | @{dk_12} |
#| momento resistente [kN·m/m] | @{hk_13} | @{g_Mr} | @{dk_13} |
#| momento volcador [kN·m/m] | @{hk_14} | @{g_Mv} | @{dk_14} |
#| vertical total [kN/m] | @{hk_15} | @{g_N} | @{dk_15} |
#| **FS vuelco** | @{hk_16} | @{g_FSv} | @{dk_16} |
#| **FS deslizamiento** | @{hk_17} | @{g_FSd} | @{dk_17} |
#| **presión bajo el muro** [kPa] | @{hk_18} | @{g_sig} | @{dk_18} |
#| **capacidad / presión** | @{hk_19} | @{g_FSc} | @{dk_19} |
#: **Lo que la ayuda no dice y salió de los resultados guardados en el .gms** (comprobado número a número, sin factores): la espalda ficticia quebrada por los extremos de las geomallas; δ = φ en ella; el signo de α en K_{ahc}; la componente vertical de la sobrecarga sin descuento de cohesión; y que con la resultante detrás del centro GEO5 no recorta el ancho.
#: **No reproducido (pendiente):** la verificación de las juntas entre bloques (vuelco 3.38 y deslizamiento 2.80), la estabilidad interna de cada geomalla (rotura 19.00/5.70 = 3.33, arrancamiento 41.46/2.95 = 14.04, que usan el coeficiente k_{r}/k_{a} de AASHTO) y la estabilidad global por Bishop (FS 1.59, radio 7.24 m), que es otro programa (Slope Stability).

## 6 · Lo que pide la NEC

#: **NEC-SE-GC 2015** (oficial), §5.2 y **Tabla 5** (p. 38), estático: deslizamiento ≥ 1.60, vuelco M_{R}/M_{A} ≥ 3.00 (o e/B ≤ 1/6), estabilidad general ≥ 1.50 en obra permanente. Con sismo: 1.05, 2.00, e/B ≤ 1/4 y 1.05.
#: Aquí: vuelco @{r_fv} ≥ 3.00 ✔, deslizamiento @{r_fd} ≥ 1.60 ✔, e/B = 0 (resultante hacia el relleno) ✔, estabilidad general 1.59 (de GEO5) ≥ 1.50 ✔.
#: **Capacidad portante**, **Tabla 6** (p. 42): FS = 3.0 con carga estática. Si los 150 kPa del ejemplo son la capacidad **última**, hace falta:
q_u3 = 3·sigma_b 'capacidad última necesaria con FS = 3 [kPa]
#: Con 150 kPa no cumple ni el 1.50 del ejemplo ni el 3.0 de la NEC: hay que mejorar el suelo de cimentación o ensanchar la base (geomallas más largas).
#: **Sismo:** k_{h} = 0.6·Z·F_{a} (nota de la Tabla 4, p. 31). Zona V con suelo D:
k_h = 0.6·0.40·1.20 'coeficiente sísmico horizontal NEC-15, zona V, suelo D
#: El **borrador 2023 (no oficial)** usa para muros k_{h} = Z·F_{top}·F_{d} (por ejemplo 0.40·1.0·0.5 = 0.20) y, para geosintéticos, un factor de resistencia de 0.80. El ejemplo de GEO5 no tiene sismo.
