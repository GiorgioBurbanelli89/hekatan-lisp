# Pilote aislado: capacidad vertical por NAVFAC DM 7.2, fuste y punta, contra GEO5
#numerico

#: **Qué se calcula.** El pilote del ejemplo oficial de GEO5 Pile (**Demo_manual_13.gpi**, manual de ingeniería 14): hormigón, 1.00 m de diámetro y 12.00 m de largo, preexcavado («Bored piles»), que atraviesa una arcilla arenosa (0 a 6 m) y una arena con finos (6 m hacia abajo). Se verifica lo mismo que el marco «Vertical cap.» de GEO5: la **resistencia del fuste** R_{s}, la **de la punta** R_{b} y su suma R_{c}, contra la carga de cálculo V_{d}.
#: **Cómo.** Con las fórmulas de la ayuda oficial de GEO5 2024 («NAVFAC DM 7.2»: Pile Shaft Resistance, Pile Base Resistance, Coefficient of Lateral Earth Pressure K, Friction Angle on Pile Skin, Critical Depth), leídas del propio archivo de ayuda (GEO5_EN.fhl), no de memoria. Los datos de los suelos se leyeron del informe completo de GEO5 (Outputs → Print document, con «Partial results»).
#: **Juez.** El informe de GEO5 2024 del Demo_manual_13 y la captura del mismo ejemplo con el ajuste «Safety factors (ASD)». Al final, la tabla **Hekatan contra GEO5** con la diferencia en %.
#: **Unidades.** kN, m y kPa, como GEO5; al final también en tonf (1 tonf = 9.80665 kN). Dentro de las fórmulas los ángulos van en radianes.

## 1 · Datos del ejemplo (Demo_manual_13.gpi)

#: **El pilote.**
d_p = 1.0 'diámetro del pilote [m]
L_p = 12.0 'longitud del pilote, con la cabeza en la rasante [m]
A_b = pi·d_p^2/4 'área de la punta [m2]
u_p = pi·d_p 'perímetro del fuste [m]
#: **Capa 1, de 0 a 6 m: arcilla arenosa (CS) de consistencia firme.** GEO5 la trata como **cohesiva**: el fuste trabaja por adherencia con la cohesión no drenada c_{u} y el coeficiente α, que en este ejemplo está **escrito a mano** (input) en 0.60.
h_1 = 6.0 'espesor de la capa 1 [m]
gamma_1 = 18.5 'peso específico de la arcilla [kN/m3]
c_u1 = 50 'cohesión no drenada de la arcilla [kPa]
α_1 = 0.60 'coeficiente de adherencia α (dato del ejemplo)
#: **Capa 2, de 6 m hacia abajo: arena con finos (S-F), medianamente densa.** Es **no cohesiva**: el fuste trabaja por rozamiento, con K y δ calculados por GEO5.
h_2 = 6.0 'tramo del pilote dentro de la arena [m]
gamma_2 = 17.5 'peso específico de la arena [kN/m3]
phi_2 = 29.5 'ángulo de rozamiento interno de la arena [grados]
#: Sin nivel freático (el marco «GWT + subsoil» está apagado): las tensiones efectivas son las totales.
#: **Lo que se pide en el marco «Vertical cap.»:** el factor de profundidad crítica k_{dc} y el factor de capacidad N_{q} escrito a mano.
k_dc = 1.00 'factor de la profundidad crítica (dato de GEO5)
N_q = 10.00 'factor de capacidad de punta (dato de GEO5, «input»)
#: **La carga** (Load No. 1, de cálculo): vertical, momento y horizontal. Para la capacidad vertical solo cuenta la vertical.
V_d = 1450 'fuerza vertical de cálculo en la cabeza [kN]
#: **El ajuste del ejemplo:** EN 1997, enfoque de diseño 2 (reduce acciones y resistencias). La carga ya es de cálculo; las resistencias se dividen por:
gamma_s = 1.10 'factor parcial del fuste
gamma_b = 1.10 'factor parcial de la punta

#hide
f_2 = phi_2·pi/180
#show

## 2 · Tensión efectiva y profundidad crítica

#: **Profundidad crítica** (ayuda de GEO5, «Critical Depth»): en suelo no cohesivo el rozamiento del fuste no crece sin fin con la profundidad; a partir de d_{c} se queda constante.
d_c = k_dc·d_p 'profundidad crítica [m]
#: Con k_{dc} = 1 la profundidad crítica es **1 m**: la tensión que usa el fuste de la arena es la que hay a 1 m, todavía dentro de la arcilla. Así lo imprime GEO5 (σ_{or} = 18.50 kPa en la arena).
s_c = gamma_1·d_c 'tensión vertical efectiva a la profundidad crítica [kPa]
#: **En la punta GEO5 NO aplica ese tope**: usa la tensión real a 12 m (las dos capas completas). Se comprobó con su R_{b}: solo cuadra con la tensión completa.
s_b = gamma_1·h_1 + gamma_2·h_2 'tensión vertical efectiva en la punta [kPa]

## 3 · Fuste (R_s): capa por capa

#: **Capa 1, arcilla (cohesiva).** Ayuda de GEO5: R_{s} = Σ α_{j}·c_{u,j}·A_{s,j}. GEO5 la parte en dos tramos (0-1 m y 1-6 m, por la profundidad crítica), pero en arcilla eso no cambia nada:
q_s1 = α_1·c_u1 'adherencia unitaria en la arcilla [kPa]
R_s1a = q_s1·u_p·d_c 'fuste en la arcilla, de 0 a 1 m [kN]
R_s1b = q_s1·u_p·(h_1 - d_c) 'fuste en la arcilla, de 1 a 6 m [kN]
#: **Capa 2, arena (no cohesiva).** Ayuda de GEO5: R_{s} = Σ K_{j}·σ_{ef,j}·tan δ_{j}·A_{s,j}. GEO5 **calcula** K como el promedio de los empujes activo, en reposo y pasivo:
K_a = tan(pi/4 - f_2/2)^2 'empuje activo
K_0 = 1 - sin(f_2) 'empuje en reposo
K_p = tan(pi/4 + f_2/2)^2 'empuje pasivo
K_2 = (K_a + K_p + K_0)/3 'coeficiente de empuje lateral sobre el fuste
#: y el ángulo de rozamiento pilote-suelo, para hormigón armado, como 0.75·φ (tabla de la ayuda, «Friction Angle on Pile Skin»):
δ_2 = 0.75·phi_2 'rozamiento pilote-arena [grados]
q_s2 = K_2·s_c·tan(δ_2·pi/180) 'rozamiento unitario en la arena [kPa]
R_s2 = q_s2·u_p·h_2 'fuste en la arena, de 6 a 12 m [kN]
R_su = R_s1a + R_s1b + R_s2 'fuste total, sin factores [kN]
#hide
p_1 = round(100·(R_s1a + R_s1b)/R_su, 1)
p_2 = round(100·R_s2/R_su, 1)
r_q2 = round(q_s2, 2)
#show
#: **Lectura.** La arcilla da el @{p_1} % del fuste y la arena solo el @{p_2} %: con la profundidad crítica de 1 m, la arena «ve» la tensión de 1 m de profundidad y su rozamiento unitario queda en @{r_q2} kPa, menos de un tercio de los 30 kPa de la arcilla.

#: **La tabla de GEO5, tramo por tramo** (los mismos tres tramos que imprime en «partial results»):
z_de = [0, d_c, h_1] 'inicio de cada tramo [m]
z_a = [d_c, h_1, h_1 + h_2] 'final de cada tramo [m]
q_si = [q_s1, q_s1, q_s2] 'rozamiento unitario de cada tramo [kPa]
R_si = [R_s1a, R_s1b, R_s2] 'fuste de cada tramo, sin factores [kN]
R_sid = R_si/gamma_s 'fuste de cada tramo, de cálculo [kN]
#tabla("Tramo","Desde [m]:2","Hasta [m]:2","Suelo","Rozamiento unitario [kPa]:2","R_si sin factor [kN]:2","R_si de cálculo [kN]:2")({"1","2","3"}; z_de; z_a; {"arcilla (α·cu)","arcilla (α·cu)","arena (K·σ·tanδ)"}; q_si; R_si; R_sid)

## 4 · Punta (R_b)

#: El suelo bajo la punta es la arena (no cohesiva). Ayuda de GEO5: R_{b} = σ_{efb}·N_{q}·A_{b}, con N_{q} = 10 escrito a mano (la tabla de la ayuda da 10 para pilotes preexcavados con φ = 30°).
q_b = s_b·N_q 'resistencia unitaria de la punta [kPa]
R_bu = q_b·A_b 'punta, sin factores [kN]

## 5 · Resistencia total y verificación de GEO5 (EN 1997, DA2)

R_cu = R_su + R_bu 'resistencia total sin factores [kN]
R_s = R_su/gamma_s 'fuste de cálculo [kN]
R_b = R_bu/gamma_b 'punta de cálculo [kN]
R_c = R_s + R_b 'resistencia de cálculo del pilote [kN]
U_c = V_d/R_c 'aprovechamiento (GEO5 cumple si es < 1)
#hide
r_uc = round(100·U_c, 1)
#show
#: R_{c} > V_{d}: **GEO5 dice SATISFACTORY**. El pilote trabaja al @{r_uc} % de su resistencia de cálculo.

#dibujo("El pilote, los suelos y el rozamiento unitario a lo largo del fuste (diagrama azul: 1 m = 10 kPa)", ud = m, escala = auto, alto = 120)
#  rect(-9, -6, 14.5, 6, "relleno azul tenue sinborde")
#  rect(-9, -13, 14.5, 7, "relleno naranja tenue sinborde")
#  linea(-9, -6, 5.5, -6, "trazos")
#  texto(-8.9, -0.7, "arcilla CS: c_{u} = 50 kPa, α = 0.60", 3.2, "i")
#  texto(-8.9, -6.7, "arena S-F: φ = 29.5°", 3.2, "i")
#  linea(-9, 0, 5.5, 0, "media verde")
#  rect(-0.5, -12, 1, 12, "gruesa")
#  achurado(-0.5, -12, 1, 12, "concreto")
#  flecha(0, 2.2, 0, 0.1, "rojo")
#  texto(0.3, 1.4, "V_{d} = 1450 kN", 3.2, "i")
#  poligono([1.5, 1.5 + q_s1/10, 1.5 + q_s1/10, 1.5 + q_s2/10, 1.5 + q_s2/10, 1.5], [0, 0, -6, -6, -12, -12], "media azul relleno")
#  texto(1.6 + q_s1/10, -3, "α·c_{u} = 30 kPa", 3.2, "i")
#  texto(1.6 + q_s2/10, -9, "K·σ_{c}·tan δ = 9.50 kPa", 3.2, "i")
#  linea(-9, -1, 0.5, -1, "trazos rojo")
#  texto(-8.9, -1.6, "profundidad crítica d_{c} = 1 m", 3.2, "i")
#  flecha(0, -14.2, 0, -12.1, "rojo")
#  texto(0.3, -13.6, "punta: σ_{b}·N_{q} = 216 × 10 = 2160 kPa", 3.2, "i")
#  cota(-1.5, -12, -1.5, 0, -0.3, "L = 12.00")
#fin

## 6 · NEC-SE-GC 2015 (oficial)

#: La NEC-15 (§8.2, p. 50) escribe lo mismo que GEO5: carga última = fuste + punta, Q_{ult} = Q_{s} + Q_{t}, y la admisible es la última entre el factor de seguridad: Q_{adm} = Q_{ult}/FS. La **Tabla 6** (p. 42) pide **FS = 3.0** con carga muerta + viva normal (2.5 con viva máxima, 1.5 con sismo). La Tabla 6 se escribe para la punta; usarla para el pilote entero es criterio nuestro, como hace GEO5 con su único SF_{cp}.
#: Con el ajuste «Safety factors (ASD)» GEO5 trabaja **sin factores parciales**: la resistencia es R_{cu} y el FS es R_{cu}/V. Comprobado hoy en GEO5 (captura «nec/02_asd_vertical_cap»): R_{c} = 2440.96 kN contra 1450 kN.
FS_req = 3.0 'factor de seguridad de la Tabla 6, carga muerta + viva normal
FS_nec = R_cu/V_d 'factor de seguridad del pilote
Q_adm = R_cu/FS_req 'carga admisible por la NEC-15 [kN]
t_f = 9.80665 'kN por tonf
Q_adm_t = Q_adm/t_f 'carga admisible [tonf]
V_t = V_d/t_f 'carga del ejemplo [tonf]
#hide
r_fs = round(FS_nec, 2)
r_qa = round(Q_adm_t, 1)
r_vt = round(V_t, 1)
#show
#: FS = @{r_fs} < 3.0: **no cumple la NEC-15**. La carga admisible es @{r_qa} tonf y el ejemplo pone @{r_vt} tonf. Ojo: la carga de GEO5 es «de cálculo» (ya mayorada); la NEC pide comparar con la carga **de servicio**, que sería menor. Aun así, para 1450 kN de servicio el pilote necesitaría R_{cu} ≥ 4350 kN.
#: La NEC-15 deja bajar el FS con **pruebas de carga** (Tabla 8, p. 46, ASTM D1143). **Borrador 2023 (no oficial):** FS de 2.0 a 3.0 según el control y los ensayos, y LRFD con φ = 0.45 al fuste y 0.40 a la punta en arcilla para pilotes barrenados (Tabla 6.6); GEO5 Pile no tiene LRFD.

## 7 · Hekatan contra GEO5

#hide
g_s1 = 85.68
g_s2 = 428.40
g_s3 = 162.74
g_K = 1.26
g_d = 22.13
g_Rs = 676.82
g_Rb = 1542.24
g_Rc = 2219.06
g_Rsu = 744.50
g_Rbu = 1696.46
g_Rcu = 2440.96
g_FS = 1.68
h_s1 = round(R_s1a/gamma_s, 2)
h_s2 = round(R_s1b/gamma_s, 2)
h_s3 = round(R_s2/gamma_s, 2)
h_K = round(K_2, 2)
h_d = round(δ_2, 2)
h_Rs = round(R_s, 2)
h_Rb = round(R_b, 2)
h_Rc = round(R_c, 2)
h_Rsu = round(R_su, 2)
h_Rbu = round(R_bu, 2)
h_Rcu = round(R_cu, 2)
h_FS = round(FS_nec, 2)
x_s1 = round(100·(h_s1/g_s1 - 1), 4)
x_s2 = round(100·(h_s2/g_s2 - 1), 4)
x_s3 = round(100·(h_s3/g_s3 - 1), 4)
x_K = round(100·(h_K/g_K - 1), 3)
x_d = round(100·(h_d/g_d - 1), 3)
x_Rs = round(100·(h_Rs/g_Rs - 1), 4)
x_Rb = round(100·(h_Rb/g_Rb - 1), 4)
x_Rc = round(100·(h_Rc/g_Rc - 1), 4)
x_Rsu = round(100·(h_Rsu/g_Rsu - 1), 4)
x_Rbu = round(100·(h_Rbu/g_Rbu - 1), 4)
x_Rcu = round(100·(h_Rcu/g_Rcu - 1), 4)
x_FS = round(100·(h_FS/g_FS - 1), 3)
#show
#| Magnitud | Hekatan | GEO5 2024 | Diferencia [%] |
#|---|---:|---:|---:|
#| R_{si} arcilla 0-1 m, de cálculo [kN] | @{h_s1} | @{g_s1} | @{x_s1} |
#| R_{si} arcilla 1-6 m, de cálculo [kN] | @{h_s2} | @{g_s2} | @{x_s2} |
#| R_{si} arena 6-12 m, de cálculo [kN] | @{h_s3} | @{g_s3} | @{x_s3} |
#| K de la arena | @{h_K} | @{g_K} | @{x_K} |
#| δ de la arena [°] | @{h_d} | @{g_d} | @{x_d} |
#| **R_{s}** (EN 1997, DA2) [kN] | @{h_Rs} | @{g_Rs} | @{x_Rs} |
#| **R_{b}** (EN 1997, DA2) [kN] | @{h_Rb} | @{g_Rb} | @{x_Rb} |
#| **R_{c}** (EN 1997, DA2) [kN] | @{h_Rc} | @{g_Rc} | @{x_Rc} |
#| R_{s} con ASD [kN] | @{h_Rsu} | @{g_Rsu} | @{x_Rsu} |
#| R_{b} con ASD [kN] | @{h_Rbu} | @{g_Rbu} | @{x_Rbu} |
#| **R_{c} con ASD** [kN] | @{h_Rcu} | @{g_Rcu} | @{x_Rcu} |
#| FS con ASD | @{h_FS} | @{g_FS} | @{x_FS} |
#: Las diferencias se calculan con el valor de Hekatan redondeado a los decimales que imprime GEO5. **Todo cuadra a cuatro cifras.**
#: **Dos cosas que la ayuda no dice y que el número de GEO5 obliga:** (1) la profundidad crítica d_{c} = k_{dc}·d solo topa el **fuste** de la arena; la **punta** usa la tensión completa (la ayuda dice que usa la misma d_{c}: con ella R_{b} saldría 145 kN, no 1696). (2) En la arena, K y δ no son datos del suelo: GEO5 los calcula, K = (K_{a} + K_{0} + K_{p})/3 y δ = 0.75·φ (el informe los deja en blanco en la tabla de suelos y los imprime en la de resultados parciales).
#: **Lo que queda fuera de esta hoja:** el asiento (curva de Poulos, con gráficos de la ayuda que GEO5 lleva digitalizados dentro del programa) y la capacidad horizontal (hoja 121).
