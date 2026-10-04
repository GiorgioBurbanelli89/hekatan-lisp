# Zapata aislada céntrica: capacidad portante vertical y horizontal, contra GEO5
#numerico

#: **Qué se calcula.** La zapata del ejemplo oficial de GEO5 Spread Footing (**Demo01.gpa**): 1.20 × 1.20 m, 0.40 m de canto, columna de 0.40 × 0.40 m. Se verifica lo mismo que el marco «Bearing cap.» de GEO5: la **capacidad portante vertical** (R_{d} contra la presión σ), la **excentricidad** y la **capacidad horizontal** (deslizamiento, R_{dh} contra H).
#: **Cómo.** Con las fórmulas de la ayuda oficial de GEO5 (página «Standard Analysis», teoría de Brinch-Hansen; «Effective Area»; «Horizontal Bearing Capacity of Foundation»; «Stress in the Footing Bottom»). Las fórmulas se leyeron del propio archivo de ayuda de GEO5 2024, no de memoria.
#: **Juez.** El informe de GEO5 2024 con «Partial results» (Outputs → Print document). Al final, la tabla **Hekatan contra GEO5** con la diferencia en %.
#: **Unidades.** kN, m y kPa. Dentro de las fórmulas los ángulos van en radianes.

## 1 · Datos del ejemplo (Demo01.gpa)

#: **El terreno.** Dos estratos: el 1 llega hasta 3.00 m de profundidad y debajo está el 2. El agua aparece a 4.00 m.
gamma_1 = 17.5 'peso específico del suelo 1 (limo con grava, MG) [kN/m3]
phi_1 = 31.5 'ángulo de rozamiento efectivo del suelo 1 [grados]
c_1 = 5 'cohesión efectiva del suelo 1 [kPa]
gamma_s2 = 22 'peso específico del suelo 2 [kN/m3]
phi_2 = 45 'ángulo de rozamiento del suelo 2 [grados]
#: **La zapata.** El fondo está a 2.00 m bajo el terreno original y a 1.20 m bajo la rasante terminada; GEO5 mide la profundidad d desde la rasante.
l_x = 1.2 'lado de la zapata en x (GEO5: «length») [m]
l_y = 1.2 'lado de la zapata en y (GEO5: «width») [m]
t_z = 0.4 'canto de la zapata [m]
d_f = 1.2 'profundidad del fondo desde la rasante terminada [m]
c_x = 0.4 'lado de la columna en x [m]
c_y = 0.4 'lado de la columna en y [m]
gamma_c = 23 'peso específico del hormigón [kN/m3]
gamma_r = 20 'peso específico del relleno sobre la zapata (dato de GEO5) [kN/m3]
#: **La carga que manda** (Load No. 1, la que GEO5 elige como más desfavorable): axial, dos momentos y dos horizontales en la cabeza de la zapata.
N_1 = 3000 'axial de la columna [kN]
M_x = -2 'momento alrededor de x [kN·m]
M_y = 70 'momento alrededor de y [kN·m]
H_x = 14 'horizontal en x [kN]
H_y = 5 'horizontal en y [kN]
#: **Lo que exige GEO5 en este ejemplo** (Settings → Spread Footing): factores de seguridad (ASD) 1.50 vertical y 1.50 horizontal, y excentricidad relativa ≤ 0.333.
SF_v = 1.5 'factor de seguridad vertical pedido
SF_h = 1.5 'factor de seguridad horizontal pedido
e_adm = 0.333 'excentricidad relativa admisible

#dibujo("Corte de la zapata del Demo01 (cotas en m)", ud = m, escala = auto, cotas = m, alto = 150)
#  linea(-3.2, 0, 3.2, 0, "media verde")
#  texto(-3.1, 0.12, "terreno original", 2.6, "i")
#  linea(-3.2, -0.8, 3.2, -0.8, "media")
#  texto(-3.1, -0.68, "rasante terminada", 2.6, "i")
#  rect(-0.6, -2.0, 1.2, 0.4, "gruesa")
#  achurado(-0.6, -2.0, 1.2, 0.4, "concreto")
#  rect(-0.2, -1.6, 0.4, 1.9, "gruesa")
#  flecha(0, 0.9, 0, 0.32, "rojo")
#  texto(0.1, 0.75, "N = 3000 kN", 2.4, "i")
#  linea(-3.2, -3.0, 3.2, -3.0, "trazos")
#  texto(-3.1, -2.88, "suelo 1: φ = 31.5°, c = 5 kPa, γ = 17.5", 2.6, "i")
#  texto(-3.1, -3.2, "suelo 2: φ = 45°, c = 5 kPa, γ = 22", 2.6, "i")
#  linea(-3.2, -4.0, 3.2, -4.0, "trazos azul")
#  texto(-3.1, -3.88, "nivel freático", 2.6, "i")
#  linea(-1.0, -4.28, 1.0, -4.28, "puntos rojo")
#  texto(1.1, -4.28, "fondo de la superficie de rotura (GEO5: 2.28 m)", 2.6, "i")
#  cota(0.9, -2.0, 0.9, -0.8, -0.25, "d = 1.20")
#  cota(-0.6, -2.25, 0.6, -2.25, -0.15, "1.20")
#fin

## 2 · La carga en el fondo de la zapata

#: GEO5 suma al axial el peso de la zapata (G) y el del relleno que queda encima (Z, sin el hueco de la columna):
G_z = l_x·l_y·t_z·gamma_c 'peso de la zapata [kN]
Z_r = gamma_r·(d_f - t_z)·(l_x·l_y - c_x·c_y) 'peso del relleno sobre la zapata [kN]
V_d = N_1 + G_z + Z_r 'fuerza vertical en el fondo [kN]
#: **Las excentricidades** (ayuda de GEO5, «Stress in the Footing Bottom»): el momento en el fondo es el de la cabeza más la horizontal por el canto. Con la columna centrada no hay término N·p.
e_x = (-M_y + H_x·t_z)/V_d 'excentricidad en x [m]
e_y = (M_x + H_y·t_z)/V_d 'excentricidad en y [m]
#: GEO5 la compara **relativa al lado**, contra 0.333:
er_x = abs(e_x)/l_x 'excentricidad relativa en x
er_y = abs(e_y)/l_y 'excentricidad relativa en y
er_t = sqrt(er_x^2 + er_y^2) 'excentricidad relativa total
#: Con −2 + 5·0.4 = 0 la excentricidad en y es **exactamente cero**: el momento M_{x} lo anula la horizontal H_{y}.

## 3 · El área efectiva y la presión de contacto

#: La resultante está corrida e_{x} del centro; GEO5 (forma «rectangle») cuenta solo el rectángulo que la tiene en su centro: a cada lado se pierde 2·|e|.
b_x = l_x - 2·abs(e_x) 'lado efectivo en x [m]
b_y = l_y - 2·abs(e_y) 'lado efectivo en y [m]
b_ef = min(b_x, b_y) 'ancho efectivo (el menor) [m]
l_ef = max(b_x, b_y) 'largo efectivo (el mayor) [m]
A_ef = b_x·b_y 'área efectiva [m2]
sigma_c = V_d/A_ef 'presión de contacto uniforme sobre el área efectiva [kPa]

#dibujo("Planta: la parte rayada es el área efectiva (GEO5 dibuja 1.16 × 1.20)", ud = m, escala = auto, cotas = m, alto = 120)
#  rect(-0.6, -0.6, 1.2, 1.2, "gruesa")
#  rect(-0.6, -0.6, b_x, b_y, "verde relleno")
#  achurado(-0.6, -0.6, b_x, b_y, "diagonal")
#  rect(-0.2, -0.2, 0.4, 0.4, "media")
#  linea(-0.8, 0, 0.8, 0, "eje")
#  linea(0, -0.8, 0, 0.8, "eje")
#  circulo(e_x, e_y, 0.03, "rojo")
#  cota(-0.6, 0.75, -0.6 + b_x, 0.75, 0.1, "b_{ef} = 1.158")
#  cota(-0.6, -0.75, 0.6, -0.75, -0.1, "l_{x} = 1.20")
#fin
#: El punto rojo es la resultante: está a 2 cm del centro, hacia −x. La franja de 4 cm de la derecha no cuenta.

## 4 · El suelo bajo la zapata: los parámetros de GEO5

#: Bajo el fondo hay 1.00 m del suelo 1 y debajo el suelo 2, mucho más fuerte. GEO5 (ayuda «Homogenization of Layered Subsoil») los convierte en **un suelo equivalente** promediando φ y c con las longitudes de la superficie de rotura de Prandtl que cae en cada estrato, y γ con las áreas.
#: **Esto NO se reproduce aquí.** La ayuda da los promedios pero la forma exacta de la superficie solo en una figura. Probé la cuña de Prandtl (45° + φ/2) y la de Terzaghi (φ), con b = 1.158 y 1.20: ninguna da la profundidad 2.28 m ni la longitud 7.51 m que imprime GEO5. Por eso φ_{d} y γ_{2} entran como **dato leído del informe de GEO5**, no calculado:
phi_d = 40.21 'φ homogeneizado bajo el fondo, del informe de GEO5 [grados]
c_d = 5 'cohesión homogeneizada (los dos suelos tienen 5) [kPa]
gamma_2 = 18.95 'γ homogeneizado bajo el fondo, del informe de GEO5 [kN/m3]
#: Sobre el fondo solo hay suelo 1, así que el γ de arriba es el suyo, sin promedio:
q_0 = gamma_1·d_f 'sobrecarga al nivel del fondo, q₀ = γ₁·d [kPa]
f_d = phi_d·pi/180 'el mismo ángulo en radianes

## 5 · Capacidad portante vertical: Brinch-Hansen (ayuda de GEO5, «Standard Analysis»)

#: **Factores de capacidad.** GEO5 los llama N_{d}, N_{e} y N_{b}; aquí con las letras de siempre (N_{q}, N_{c}, N_{γ}). Ojo: el de peso propio de Brinch-Hansen es 1.5·(N_{q} − 1)·tan φ, no el 2·(N_{q} + 1)·tan φ de Vesic.
N_q = tan(pi/4 + f_d/2)^2·exp(pi·tan(f_d)) 'factor de sobrecarga (Prandtl)
N_c = (N_q - 1)/tan(f_d) 'factor de cohesión (Reissner)
N_γ = 1.5·(N_q - 1)·tan(f_d) 'factor de peso propio (Brinch-Hansen)
#: **Factores de forma**, con los lados EFECTIVOS:
s_c = 1 + 0.2·b_ef/l_ef 'forma, cohesión
s_q = 1 + b_ef/l_ef·sin(f_d) 'forma, sobrecarga
s_γ = 1 - 0.3·b_ef/l_ef 'forma, peso propio
#: **Factores de profundidad**, con d medido desde la rasante y el ancho efectivo:
d_c = 1 + 0.1·sqrt(d_f/b_ef) 'profundidad, cohesión
d_q = 1 + 0.1·sqrt(d_f/b_ef·sin(2·f_d)) 'profundidad, sobrecarga
d_γ = 1 'profundidad, peso propio
#: **Inclinación de la carga**: δ es el ángulo de la resultante con la vertical. GEO5 lo dibuja: «Delta = 0.28°».
H_r = sqrt(H_x^2 + H_y^2) 'horizontal resultante [kN]
t_δ = H_r/V_d 'tangente de la inclinación
δ_g = atan(t_δ)·180/pi 'inclinación en grados
i_f = (1 - t_δ)^2 'factor de inclinación, el mismo para los tres términos
#: Terreno horizontal y fondo horizontal: los factores b y g valen 1.
#: **La capacidad**, término a término:
R_c = c_d·N_c·s_c·d_c·i_f 'término de cohesión [kPa]
R_q = q_0·N_q·s_q·d_q·i_f 'término de sobrecarga [kPa]
R_γ = b_ef/2·gamma_2·N_γ·s_γ·d_γ·i_f 'término de peso propio [kPa]
R_d = R_c + R_q + R_γ 'capacidad portante del suelo de apoyo [kPa]
FS_v = R_d/sigma_c 'factor de seguridad vertical
#hide
p_c = round(100·R_c/R_d, 1)
p_q = round(100·R_q/R_d, 1)
p_g = round(100·R_γ/R_d, 1)
r_fsv = round(FS_v, 2)
r_dlt = round(δ_g, 2)
#show
#: **Lectura.** El @{p_q} % de R_{d} sale de estar enterrada 1.20 m (término q₀), el @{p_g} % del peso del suelo bajo la zapata y solo el @{p_c} % de la cohesión. FS = @{r_fsv} > 1.50: **cumple con el criterio de GEO5**. La inclinación δ = @{r_dlt}° apenas resta un 1 %.

#: **Cómo cae el FS si la carga se corre.** La misma fórmula con e_{x} como variable (de 0 a 0.40 m), dejando todo lo demás igual: el ancho efectivo baja, la presión sube y la capacidad baja. La recta roja es el 1.50 que pide GEO5:
#fplot(FS = (c_d·N_c·(1 + 0.2·(l_x - 2·x)/l_y)·(1 + 0.1·sqrt(d_f/(l_x - 2·x))) + q_0·N_q·(1 + (l_x - 2·x)/l_y·sin(f_d))·(1 + 0.1·sqrt(d_f/(l_x - 2·x)·sin(2·f_d))) + (l_x - 2·x)/2·gamma_2·N_γ·(1 - 0.3·(l_x - 2·x)/l_y))·i_f/(V_d/((l_x - 2·x)·l_y)), limite = 1.5, [0 0.4])
#: A e_{x} = 0.02 m (este ejemplo) el FS es 1.65; pasa por 1.50 hacia los 0.06 m. Con 0.40 m (la zapata de lindero de la hoja 106) queda en 0.43.

## 6 · Capacidad horizontal (deslizamiento)

#: Ayuda de GEO5, «Horizontal Bearing Capacity of Foundation»: R_{dh} = V·tan ψ + a·A_{ef} + S_{pd}. El rozamiento y la adherencia son los del suelo **en contacto** con la zapata (el suelo 1), no los del suelo homogeneizado:
f_1 = phi_1·pi/180 'φ del suelo 1 en radianes
R_roz = V_d·tan(f_1) 'rozamiento en la base [kN]
R_coh = c_1·A_ef 'adherencia en el área efectiva [kN]
#: **Empuje en reposo** sobre el canto de la zapata (GEO5: «Earth resistance: at rest»), K₀ = 1 − sen φ, en la cara de 1.20 m, del techo (d − t) al fondo (d) de la zapata:
K_0 = 1 - sin(f_1) 'coeficiente de empuje en reposo
S_pd = K_0·gamma_1·(d_f^2 - (d_f - t_z)^2)/2·l_y 'resistencia del terreno delante de la zapata [kN]
R_dh = R_roz + R_coh + S_pd 'capacidad horizontal [kN]
FS_h = R_dh/H_r 'factor de seguridad al deslizamiento
#hide
r_fsh = round(FS_h, 2)
r_spd = round(S_pd, 2)
#show
#: FS = @{r_fsh}: la horizontal (15 kN) no le hace nada a una zapata que aprieta 3034 kN contra el suelo. El empuje en reposo aporta @{r_spd} kN, lo mismo que GEO5 (4.01).

## 7 · La segunda carga (Load No. 2) y la excentricidad máxima

#: GEO5 revisa todas las cargas de diseño. La Load No. 2 (N = 820 kN, M_{y} = −200 kN·m) es la que da la **mayor excentricidad** de la lista: 0.195 relativa.
N_2 = 820 'axial de la carga 2 [kN]
M_y2 = -200 'momento de la carga 2 [kN·m]
V_2 = N_2 + G_z + Z_r 'vertical en el fondo, carga 2 [kN]
e_x2 = -M_y2/V_2 'excentricidad, carga 2 [m]
er_x2 = abs(e_x2)/l_x 'relativa: la máxima de la lista
b_x2 = l_x - 2·abs(e_x2) 'lado efectivo, carga 2 [m]
sigma_2 = V_2/(b_x2·l_y) 'presión, carga 2 [kPa]
s_c2 = 1 + 0.2·b_x2/l_y
s_q2 = 1 + b_x2/l_y·sin(f_d)
s_γ2 = 1 - 0.3·b_x2/l_y
d_c2 = 1 + 0.1·sqrt(d_f/b_x2)
d_q2 = 1 + 0.1·sqrt(d_f/b_x2·sin(2·f_d))
R_d2 = c_d·N_c·s_c2·d_c2 + q_0·N_q·s_q2·d_q2 + b_x2/2·gamma_2·N_γ·s_γ2 'capacidad, carga 2 (sin horizontal: i = 1) [kPa]

## 8 · Hekatan contra GEO5

#hide
g_V = 3033.73
g_ex = 0.195
g_bef = 1.158
g_sig = 2184.03
g_Nq = 66.102
g_Nc = 77.010
g_Ng = 82.552
g_sq = 1.623
g_dq = 1.101
g_i = 0.990
g_Rd = 3594.345
g_FS = 1.65
g_Spd = 4.01
g_Rdh = 1870.03
g_FSh = 125.79
g_sig2 = 972.62
g_Rd2 = 3135.26
h_V = round(V_d, 2)
h_ex = round(er_x2, 3)
h_bef = round(b_ef, 3)
h_sig = round(sigma_c, 2)
h_Nq = round(N_q, 3)
h_Nc = round(N_c, 3)
h_Ng = round(N_γ, 3)
h_sq = round(s_q, 3)
h_dq = round(d_q, 3)
h_i = round(i_f, 3)
h_Rd = round(R_d, 3)
h_FS = round(FS_v, 2)
h_Spd = round(S_pd, 2)
h_Rdh = round(R_dh, 2)
h_FSh = round(FS_h, 2)
h_sig2 = round(sigma_2, 2)
h_Rd2 = round(R_d2, 2)
x_V = round(100·(h_V/g_V - 1), 4)
x_ex = round(100·(h_ex/g_ex - 1), 3)
x_bef = round(100·(h_bef/g_bef - 1), 3)
x_sig = round(100·(h_sig/g_sig - 1), 4)
x_Nq = round(100·(h_Nq/g_Nq - 1), 4)
x_Nc = round(100·(h_Nc/g_Nc - 1), 4)
x_Ng = round(100·(h_Ng/g_Ng - 1), 4)
x_sq = round(100·(h_sq/g_sq - 1), 3)
x_dq = round(100·(h_dq/g_dq - 1), 3)
x_i = round(100·(h_i/g_i - 1), 3)
x_Rd = round(100·(h_Rd/g_Rd - 1), 4)
x_FS = round(100·(h_FS/g_FS - 1), 2)
x_Spd = round(100·(h_Spd/g_Spd - 1), 2)
x_Rdh = round(100·(h_Rdh/g_Rdh - 1), 4)
x_FSh = round(100·(h_FSh/g_FSh - 1), 3)
x_sig2 = round(100·(h_sig2/g_sig2 - 1), 4)
x_Rd2 = round(100·(h_Rd2/g_Rd2 - 1), 4)
#show
#| Magnitud | Hekatan | GEO5 2024 | Diferencia [%] |
#|---|---:|---:|---:|
#| V en el fondo [kN] | @{h_V} | @{g_V} | @{x_V} |
#| excentricidad relativa máxima (Load 2) | @{h_ex} | @{g_ex} | @{x_ex} |
#| ancho efectivo b_{ef} [m] | @{h_bef} | @{g_bef} | @{x_bef} |
#| presión σ [kPa] | @{h_sig} | @{g_sig} | @{x_sig} |
#| N_{q} | @{h_Nq} | @{g_Nq} | @{x_Nq} |
#| N_{c} | @{h_Nc} | @{g_Nc} | @{x_Nc} |
#| N_{γ} | @{h_Ng} | @{g_Ng} | @{x_Ng} |
#| s_{q} | @{h_sq} | @{g_sq} | @{x_sq} |
#| d_{q} | @{h_dq} | @{g_dq} | @{x_dq} |
#| i | @{h_i} | @{g_i} | @{x_i} |
#| **R_{d} [kPa]** | @{h_Rd} | @{g_Rd} | @{x_Rd} |
#| FS vertical | @{h_FS} | @{g_FS} | @{x_FS} |
#| S_{pd} [kN] | @{h_Spd} | @{g_Spd} | @{x_Spd} |
#| **R_{dh} [kN]** | @{h_Rdh} | @{g_Rdh} | @{x_Rdh} |
#| FS horizontal | @{h_FSh} | @{g_FSh} | @{x_FSh} |
#| σ, Load 2 [kPa] | @{h_sig2} | @{g_sig2} | @{x_sig2} |
#| R_{d}, Load 2 [kPa] | @{h_Rd2} | @{g_Rd2} | @{x_Rd2} |
#: Las diferencias se calculan con el valor de Hekatan redondeado a los mismos decimales que imprime GEO5. Todo cuadra a cuatro cifras; lo Ãºnico que asoma es R_{d} (0.016 kPa sobre 3594): GEO5 imprime Ï_{d} = 40.210 con tres decimales y aquÃ­ entra asÃ­.
#: **Lo que NO es cálculo de Hekatan:** φ_{d} = 40.21° y γ_{2} = 18.95 kN/m³ (homogeneización de Prandtl de GEO5, ver sección 4). Cerrarlo pide sacar la geometría de la superficie de rotura del binario SpreadFooting_5.dll.
