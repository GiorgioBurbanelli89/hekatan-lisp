# Talud con suelo claveteado: verificación como muro y capacidad portante, contra GEO5 Nailed Slope
#numerico

#: **Qué se calcula.** El corte del ejemplo oficial de GEO5 Nailed Slope (**Demo01.ghr**): 7 m de alto, cara inclinada 2 m hacia atrás, seis clavos de 5 m a 10° (uno por metro de altura, cada 1 m en planta) y una capa de hormigón proyectado de 0.20 m. Se reproduce el marco «Verification» (el bloque claveteado como **muro de gravedad**: vuelco y deslizamiento) y el marco «Bearing cap.» (presión bajo el bloque contra 160 kPa → factor 1.13).
#: **Cómo.** Coulomb (ayuda de GEO5) sobre una **espalda ficticia** y la geometría del archivo .ghr, que es binario y guarda también los resultados enteros de GEO5: contra esos se compara.
#: **Juez.** GEO5 2024: vuelco 2601.99/17.41 = 149.48, deslizamiento 502.25/17.42 = 28.83, presión 142.21 kPa contra 160 kPa → 1.13.
#: **Unidades.** kN, m y kPa por metro de muro; resumen en tonf. Ángulos en radianes dentro de las fórmulas.

## 1 · Datos (Demo01.ghr)

#: **La cara.** De (x = 0, z = 0) arriba a (x = −2, z = 7) abajo; z es la profundidad bajo la cabeza del corte.
H_c = 7 'altura del corte [m]
d_x = 2 'retiro de la cara de arriba a abajo [m]
#: **Los clavos.** Seis, a z = 1, 2 … 6 m, de 5 m, inclinados 10° hacia abajo:
L_n = 5 'largo del clavo [m]
a_n = 10·pi/180 'inclinación del clavo [rad]
z_n6 = 6 'profundidad de la cabeza del clavo de abajo [m]
#: **El suelo.** Soil No. 1 hasta 2.50 m y Soil No. 2 debajo (datos del archivo):
gamma_1 = 19.5 'peso específico del suelo 1 [kN/m3]
gamma_2 = 21 'peso específico del suelo 2 [kN/m3]
phi_2 = 30 'ángulo de rozamiento del suelo 2 [grados]
c_2 = 15 'cohesión del suelo 2 [kPa]
z_12 = 2.5 'profundidad del contacto entre suelos [m]
R_d = 160 'capacidad portante dada del suelo de cimentación [kPa]

#dibujo("Corte: cara (negro), clavos (rojo) y espalda ficticia (azul) por los extremos de los clavos", ud = m, escala = auto, cotas = m, alto = 170)
#  linea(0, 0, -2, -7, "gruesa")
#  linea(-4, -7, 6, -7, "fina")
#  linea(-4, -7, -2, -7, "media verde")
#  linea(0, 0, 5, 1, "media verde")
#  linea(5, 1, 7, 1, "media verde")
#  linea(-0.286, -1, 4.638, -1.868, "media rojo")
#  linea(-0.571, -2, 4.353, -2.868, "media rojo")
#  linea(-0.857, -3, 4.067, -3.868, "media rojo")
#  linea(-1.143, -4, 3.781, -4.868, "media rojo")
#  linea(-1.429, -5, 3.495, -5.868, "media rojo")
#  linea(-1.714, -6, 3.210, -6.868, "media rojo")
#  linea(3.172, -7, 4.638, -1.868, "gruesa azul")
#  linea(4.638, -1.868, 4.638, 0.928, "gruesa azul")
#  linea(-2, -2.5, 6.5, -2.5, "trazos")
#  texto(5.0, -2.35, "suelo 1 / suelo 2", 2.6, "i")
#  texto(3.6, -6.0, "espalda ficticia", 2.6, "i")
#  cota(-2, -7.4, 3.172, -7.4, -0.15, "B = 5.17")
#fin

## 2 · La espalda ficticia

#: Como en MSE Wall (hoja 127), GEO5 cierra el bloque claveteado con una espalda **paralela a la cara** que pasa por los extremos de los clavos. Todos los clavos miden lo mismo, así que sus extremos quedan en esa recta. Se baja desde el extremo del clavo de abajo hasta la base:
t_c = d_x/H_c 'talud de la cara y de la espalda (2/7)
x_e = -t_c·z_n6 + L_n·cos(a_n) 'x del extremo del clavo de abajo [m]
z_e = z_n6 + L_n·sin(a_n) 'profundidad del extremo del clavo de abajo [m]
x_B = x_e - t_c·(H_c - z_e) 'x de la espalda en la base [m]
B_b = x_B + d_x 'ancho de la base del bloque claveteado (desde el pie) [m]

## 3 · El empuje sobre la espalda ficticia

#: Suelo contra suelo: δ = φ. La espalda se inclina hacia el relleno, α = −atan(2/7). Igual que en la hoja 127, el término de cohesión de la ayuda cuadra con +atan(2/7) (signo de α al revés en la fórmula de K_{ahc}).
f_2 = phi_2·pi/180 'φ del suelo 2 [rad]
a_b = -atan(t_c) 'inclinación de la espalda [rad]
K_a = cos(f_2 - a_b)^2/(cos(a_b)^2·cos(a_b + f_2)·(1 + sqrt(sin(2·f_2)·sin(f_2)/(cos(a_b + f_2)·cos(a_b))))^2) 'coeficiente de empuje activo (Coulomb)
K_h = K_a·cos(a_b + f_2) 'componente horizontal
C_h = 2·c_2·cos(f_2)·cos(f_2 + a_b)/(1 + sin(2·f_2 + a_b)) 'término de cohesión horizontal [kPa]
#: La tensión vertical en la espalda es la de la columna de suelo: σ_{z} = γ₁·2.50 + γ₂·(z − 2.50). La cohesión del suelo 2 mantiene la presión en cero hasta z_{0}:
s_12 = gamma_1·z_12 'σz en el contacto [kPa]
z_0 = z_12 + (C_h/K_h - s_12)/gamma_2 'profundidad donde el suelo empieza a empujar [m]
e_7 = (s_12 + gamma_2·(H_c - z_12))·K_h - C_h 'presión en la base [kPa]
E_a = e_7·(H_c - z_0)/2 'empuje horizontal [kN/m]
V_a = E_a·tan(a_b + f_2) 'componente vertical [kN/m]
h_a = (H_c - z_0)/3 'altura de la resultante sobre la base [m]
x_a = B_b + t_c·h_a 'su brazo desde el pie [m]
#: **Arriba, en el suelo 1.** Por encima del extremo del clavo de arriba (z = 1.87 m) la espalda sigue **vertical** hasta el terreno (como en MSE Wall). Ahí el suelo 1 (φ = 27°, c = 12 kPa, δ = φ, α = 0) empuja solo en una cuña muy fina, justo encima de ese punto; más abajo, en el tramo inclinado del suelo 1, la cohesión vuelve a anular la presión:
phi_1 = 27 'ángulo de rozamiento del suelo 1 [grados]
c_1 = 12 'cohesión del suelo 1 [kPa]
f_1 = phi_1·pi/180 'φ del suelo 1 [rad]
K_h1 = cos(f_1)^2/(cos(f_1)·(1 + sqrt(sin(2·f_1)·sin(f_1)/cos(f_1)))^2)·cos(f_1) 'K_a·cos δ, tramo vertical
C_h1 = 2·c_1·cos(f_1)·cos(f_1)/(1 + sin(2·f_1)) 'cohesión horizontal, tramo vertical [kPa]
z_e1 = 1 + L_n·sin(a_n) 'profundidad del extremo del clavo de arriba [m]
z_01 = C_h1/(gamma_1·K_h1) 'donde el suelo 1 empieza a empujar [m]
e_1 = gamma_1·z_e1·K_h1 - C_h1 'presión al pie del tramo vertical [kPa]
E_1 = e_1·(z_e1 - z_01)/2 'la cuña de arriba [kN/m]
V_1 = E_1·tan(f_1) 'su componente vertical [kN/m]
h_1 = H_c - z_e1 + (z_e1 - z_01)/3 'su altura sobre la base [m]
x_1 = -t_c + L_n·cos(a_n) + d_x 'su brazo desde el pie [m]
#: **El empuje total** sobre la espalda ficticia:
E_t = E_a + E_1 'empuje horizontal total [kN/m]
V_t = V_a + V_1 'empuje vertical total [kN/m]
h_t = (E_a·h_a + E_1·h_1)/E_t 'altura de la resultante [m]

## 4 · Vuelco, deslizamiento y capacidad portante

#: **El peso del bloque claveteado** se toma del archivo (731.18 kN/m, a 3.526 m del pie). **No se reproduce**: con la cara, la espalda y el terreno inclinado del ejemplo el área sale mayor (≈ 796 kN/m): falta saber qué parte del terreno de arriba y de la capa de hormigón cuenta GEO5. Pendiente.
W_n = 731.181367 'peso del bloque claveteado, dato de GEO5 [kN/m]
x_W = 3.526047 'su brazo desde el pie, dato de GEO5 [m]
M_res = W_n·x_W + V_a·x_a + V_1·x_1 'momento resistente [kN·m/m]
M_vol = E_a·h_a + E_1·h_1 'momento volcador [kN·m/m]
FS_v = M_res/M_vol 'factor de seguridad al vuelco
N_v = W_n + V_t 'fuerza vertical en la base [kN/m]
R_s = N_v·tan(f_2) + c_2·B_b 'resistencia al deslizamiento [kN/m]
FS_d = R_s/E_t 'factor de seguridad al deslizamiento
e_c = B_b/2 - (M_res - M_vol)/N_v 'excentricidad (positiva hacia el pie) [m]
#: La resultante cae **detrás del centro** (e < 0): igual que en MSE Wall, GEO5 no recorta el ancho (ECCENTRICITY 0.0 %) y la presión es N/B:
sigma_b = N_v/B_b 'presión bajo el bloque claveteado [kPa]
FS_c = R_d/sigma_b 'capacidad / presión
U_c = sigma_b/R_d·100 'aprovechamiento [%]
#: **En tonf:**
s_ton = sigma_b/9.80665 'presión bajo el bloque [tonf/m2]

## 5 · Estabilidad interna (plano a 33°): cómo arma GEO5 el factor

#: El marco «Internal stability» busca el plano de rotura más desfavorable desde el pie: 33°. Con el peso de la cuña y la fuerza de los clavos que GEO5 calcula (618.22 y 169.41 kN/m, datos del archivo), el factor se arma así:
W_w = 618.2179 'peso de la cuña, dato de GEO5 [kN/m]
T_n = 169.411394 'fuerza de los clavos detrás del plano, dato de GEO5 [kN/m]
R_soil = 529.711002 'resistencia del suelo en el plano, dato de GEO5 [kN/m]
t_p = 33·pi/180 'ángulo del plano [rad]
D_w = W_w·sin(t_p) 'componente que empuja a lo largo del plano [kN/m]
N_w = W_w·cos(t_p) 'componente normal al plano [kN/m]
R_n = T_n·cos(t_p + a_n) 'aporte de los clavos a lo largo del plano [kN/m]
FS_i = (R_soil + R_n)/D_w 'factor de seguridad interno
#: Comprobado: D = W·sen 33° (336.71), N = W·cos 33° (518.48) y el aporte de los clavos T·cos(33° + 10°) (123.90) son los que guarda GEO5. **No se reproduce** (pendiente) cómo salen el peso de la cuña, la fuerza de los clavos (con la resistencia al arrancamiento de 18.85 kN/m por metro detrás del plano salen 188.2, y con solo los clavos 4-6, 169.47) ni la resistencia del suelo 529.71.

## 6 · Hekatan contra GEO5

#hide
g_B = 5.172108
g_Ea = 17.423852
g_Va = 4.362743
g_ha = 0.999011
g_xa = 5.457768
g_Mr = 2601.990717
g_Mv = 17.406626
g_N = 735.54411
g_Rs = 502.248204
g_FSv = 149.48
g_FSd = 28.83
g_sig = 142.213614
g_FSc = 1.13
g_D = 336.7056
g_Rn = 123.89965
g_FSi = 1.941193
hk_1 = round(B_b, 4)
hk_2 = round(E_t, 4)
hk_3 = round(V_t, 4)
hk_4 = round(h_t, 4)
hk_5 = round(x_a, 4)
hk_6 = round(M_res, 4)
hk_7 = round(M_vol, 4)
hk_8 = round(N_v, 4)
hk_9 = round(R_s, 4)
hk_10 = round(FS_v, 2)
hk_11 = round(FS_d, 2)
hk_12 = round(sigma_b, 4)
hk_13 = round(FS_c, 2)
hk_14 = round(D_w, 4)
hk_15 = round(R_n, 4)
hk_16 = round(FS_i, 4)
dk_1 = round(100·(hk_1/g_B - 1), 4)
dk_2 = round(100·(hk_2/g_Ea - 1), 4)
dk_3 = round(100·(hk_3/g_Va - 1), 4)
dk_4 = round(100·(hk_4/g_ha - 1), 4)
dk_5 = round(100·(hk_5/g_xa - 1), 4)
dk_6 = round(100·(hk_6/g_Mr - 1), 4)
dk_7 = round(100·(hk_7/g_Mv - 1), 4)
dk_8 = round(100·(hk_8/g_N - 1), 4)
dk_9 = round(100·(hk_9/g_Rs - 1), 4)
dk_10 = round(100·(hk_10/g_FSv - 1), 4)
dk_11 = round(100·(hk_11/g_FSd - 1), 4)
dk_12 = round(100·(hk_12/g_sig - 1), 4)
dk_13 = round(100·(hk_13/g_FSc - 1), 4)
dk_14 = round(100·(hk_14/g_D - 1), 4)
dk_15 = round(100·(hk_15/g_Rn - 1), 4)
dk_16 = round(100·(hk_16/g_FSi - 1), 4)
#show
#| Magnitud | Hekatan | GEO5 2024 (.ghr) | Diferencia [%] |
#|---|---:|---:|---:|
#| ancho de la base B [m] | @{hk_1} | @{g_B} | @{dk_1} |
#| empuje horizontal total [kN/m] | @{hk_2} | @{g_Ea} | @{dk_2} |
#| empuje vertical total [kN/m] | @{hk_3} | @{g_Va} | @{dk_3} |
#| altura del empuje total [m] | @{hk_4} | @{g_ha} | @{dk_4} |
#| brazo del empuje vertical del suelo 2 [m] | @{hk_5} | @{g_xa} | @{dk_5} |
#| momento resistente [kN·m/m] ² | @{hk_6} | @{g_Mr} | @{dk_6} |
#| momento volcador [kN·m/m] | @{hk_7} | @{g_Mv} | @{dk_7} |
#| vertical en la base [kN/m] ² | @{hk_8} | @{g_N} | @{dk_8} |
#| resistencia al deslizamiento [kN/m] ² | @{hk_9} | @{g_Rs} | @{dk_9} |
#| **FS vuelco** ² | @{hk_10} | @{g_FSv} | @{dk_10} |
#| **FS deslizamiento** ² | @{hk_11} | @{g_FSd} | @{dk_11} |
#| **presión bajo el bloque** [kPa] ² | @{hk_12} | @{g_sig} | @{dk_12} |
#| **capacidad / presión** ² | @{hk_13} | @{g_FSc} | @{dk_13} |
#| fuerza que empuja en el plano de 33° [kN/m] ³ | @{hk_14} | @{g_D} | @{dk_14} |
#| aporte de los clavos [kN/m] ³ | @{hk_15} | @{g_Rn} | @{dk_15} |
#| **FS interno** ³ | @{hk_16} | @{g_FSi} | @{dk_16} |
#: ² Con el peso del bloque claveteado de GEO5 (731.18 kN/m), que aquí no se reproduce. ³ Con el peso de la cuña, la fuerza de los clavos y la resistencia del suelo de GEO5: comprueba solo cómo se arma el factor.
#: Lo que queda (≤ 0.01 %) es la sexta cifra de K_{h} y del término de cohesión (GEO5: 0.184998 y 14.86619; aquí 0.184996 y 14.86603).

## 7 · Lo que pide la NEC

#: **NEC-SE-GC 2015**, **Tabla 5** (p. 38): vuelco ≥ 3.00, deslizamiento ≥ 1.60 y estabilidad general ≥ 1.50 en obra permanente (1.05 con sismo). El factor interno de 1.94 que da GEO5 cumple el 1.50 (GEO5 pide 1.20 en este ejemplo). La NEC no da un factor propio para clavos.
#: **Capacidad portante**, **Tabla 6** (p. 42): FS = 3.0. Si los 160 kPa son la capacidad **última**, el factor 1.13 no cumple; haría falta:
q_u3 = 3·sigma_b 'capacidad última necesaria con FS = 3 [kPa]
#: Si los 160 kPa ya son **admisibles**, cumple. El dato del ejemplo no lo dice.
#: **Sismo:** k_{h} = 0.6·Z·F_{a} (nota de la Tabla 4, p. 31), zona V y suelo D:
k_h = 0.6·0.40·1.20 'coeficiente sísmico horizontal NEC-15
#: El **borrador 2023 (no oficial)** pide 1.5 en cortes de excavación para la estabilidad general.
