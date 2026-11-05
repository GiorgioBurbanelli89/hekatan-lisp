# Grupo de 20 pilotes en arena: método de tensiones efectivas (β) y eficiencia de Seiler-Keeney, contra GEO5
#numerico

#: **Qué se calcula.** El ejemplo oficial de GEO5 Pile Group (**Demo01.gsp**, «Pile Group - Example 1»): un cabezal de 15 × 15 m sobre **20 pilotes** (5 × 4) de hormigón de 1.00 m de diámetro y 12.00 m de largo, en arena limosa y arena con finos, con el agua a 7.00 m. Se verifica lo mismo que el marco «Vertical cap.» de GEO5: el fuste y la punta de un pilote, la resistencia de un pilote, la **eficiencia del grupo** y la resistencia del grupo contra la carga.
#: **Cómo.** Con las fórmulas de la ayuda oficial de GEO5 2024 («Effective Stress Method», «Efficiency of a Pile Group», «Analysis According to the Theory of Limit States»), leídas del archivo de ayuda.
#: **Juez.** El informe completo de GEO5 2024 del Demo01.gsp y la captura del mismo ejemplo con «Safety factors (ASD)», SF_{cp} = 3.
#: **Unidades.** kN, m y kPa, como GEO5; la carga admisible también en tonf.

## 1 · Datos del ejemplo (Demo01.gsp)

#: **El cabezal y los pilotes.**
b_x = 15.0 'ancho del cabezal en x [m]
b_y = 15.0 'ancho del cabezal en y [m]
d_p = 1.0 'diámetro de los pilotes [m]
n_x = 5 'pilotes en x
n_y = 4 'pilotes en y
s_x = 3.0 'separación entre ejes en x [m]
s_y = 4.0 'separación entre ejes en y [m]
h_z = 2.0 'profundidad del fondo del cabezal (cabeza de los pilotes) [m]
L_p = 12.0 'longitud de los pilotes [m]
n_p = n_x·n_y 'número de pilotes
#: **El suelo.** Arena limosa (SM) de 0 a 5 m y arena con finos (S-F) debajo; nivel freático a 7.00 m; agua con 10 kN/m³. Para el método de tensiones efectivas cada suelo da su coeficiente β_{p} (Bjerrum-Burland) y la punta, N_{p} = 10.
h_1 = 5.0 'espesor de la arena limosa [m]
gamma_1 = 18.0 'peso específico de la arena limosa [kN/m3]
gamma_2 = 17.5 'peso específico de la arena con finos [kN/m3]
gamma_s2 = 19.5 'peso saturado de la arena con finos [kN/m3]
gamma_w = 10.0 'peso específico del agua [kN/m3]
z_w = 7.0 'profundidad del nivel freático [m]
β_p = 0.45 'coeficiente de fuste de los dos suelos
N_p = 10 'coeficiente de punta (Fellenius)
#: **El ajuste del ejemplo:** estados límite (LSD), con coeficiente de reducción de la resistencia total γ_{t} = 1.50 (γ_{s} = γ_{b} = 1.00).
gamma_t = 1.50 'reducción de la resistencia total
V_d = 29551.99 'fuerza vertical de cálculo con el peso del cabezal, del informe de GEO5 [kN]

## 2 · Tensión efectiva a lo largo del pilote

#: GEO5 cuenta la tensión **desde el fondo del cabezal** (2.00 m): en la cabeza del pilote σ' = 0 (el suelo de encima se excavó para el cabezal). Esto no lo dice la ayuda; lo obliga el número de GEO5: con la tensión desde la superficie R_{b} saldría 1504 kN, no 1221.29.
z_p = h_z + L_p 'profundidad de la punta [m]
s_1 = gamma_1·(h_1 - h_z) 'σ' al pasar a la arena con finos, a 5 m [kPa]
s_w = s_1 + gamma_2·(z_w - h_1) 'σ' en el nivel freático, a 7 m [kPa]
s_b = s_w + (gamma_s2 - gamma_w)·(z_p - z_w) 'σ' en la punta, a 14 m [kPa]

## 3 · Un pilote: fuste y punta (Effective stress method)

#: Ayuda de GEO5: R_{s} = Σ β_{p,j}·σ_{0,j}·A_{s,j}, con σ_{0,j} la tensión **media** de cada tramo, y R_{b} = N_{p}·σ_{p}·A_{b}.
u_p = pi·d_p 'perímetro [m]
A_b = pi·d_p^2/4 'área de la punta [m2]
R_s1 = β_p·(s_1/2)·u_p·(h_1 - h_z) 'fuste en la arena limosa, 2 a 5 m [kN]
R_s2 = β_p·((s_1 + s_w)/2)·u_p·(z_w - h_1) 'fuste en la arena, 5 a 7 m, sobre el agua [kN]
R_s3 = β_p·((s_w + s_b)/2)·u_p·(z_p - z_w) 'fuste en la arena, 7 a 14 m, bajo el agua [kN]
R_s = R_s1 + R_s2 + R_s3 'fuste de un pilote [kN]
R_b = N_p·s_b·A_b 'punta de un pilote [kN]
R_c1 = R_s + R_b 'resistencia de un pilote, sin reducir [kN]
#hide
p_3 = round(100·R_s3/R_s, 1)
#show
#: El tramo bajo el agua da el @{p_3} % del fuste: es el más largo (7 m) y el de más tensión.

#: **El fuste tramo a tramo:**
z_de = [h_z, h_1, z_w] 'inicio del tramo [m]
z_a = [h_1, z_w, z_p] 'final del tramo [m]
s_m = [s_1/2, (s_1 + s_w)/2, (s_w + s_b)/2] 'tensión efectiva media del tramo [kPa]
R_si = [R_s1, R_s2, R_s3] 'fuste del tramo [kN]
#tabla("Tramo","Desde [m]:2","Hasta [m]:2","σ'₀ medio [kPa]:2","R_si [kN]:2")({"arena limosa","arena, sobre el agua","arena, bajo el agua"}; z_de; z_a; s_m; R_si)

## 4 · La eficiencia del grupo (Seiler-Keeney)

#: Ayuda de GEO5: η_{g} = [1 − 0.479·(s/(s² − 0.093))·((n_{x} + n_{y} − 2)/(n_{x} + n_{y} − 1))] + 0.3/(n_{x} + n_{y}), con s en metros. Con separaciones distintas en x y en y, GEO5 usa **el promedio**: con 3.0 o 4.0 el resultado se aleja (49029 y 50995 kN), con 3.5 cuadra.
s_g = (s_x + s_y)/2 'separación usada por GEO5 [m]
η_g = (1 - 0.479·(s_g/(s_g^2 - 0.093))·((n_x + n_y - 2)/(n_x + n_y - 1))) + 0.3/(n_x + n_y) 'eficiencia del grupo
#: Para comparar, la de **Converse-Labarre** (la que nombra el borrador 2023 y GEO5 llama «La Barré»), con la misma separación media; es solo informativa (criterio nuestro):
ψ_g = atan(d_p/s_g)·180/pi 'ángulo ψ [grados]
η_LB = 1 - ψ_g·((n_x - 1)·n_y + (n_y - 1)·n_x)/(90·n_x·n_y) 'eficiencia de Converse-Labarre

## 5 · El grupo, como el ejemplo (estados límite)

#: Ayuda de GEO5: R_{g} = n·(R_{c}/γ_{t})·η_{g} ≥ V_{d}.
R_c = R_c1/gamma_t 'resistencia reducida de un pilote [kN]
R_g = n_p·R_c·η_g 'resistencia del grupo [kN]
#hide
r_ug = round(100·V_d/R_g, 1)
#show
#: R_{g} > V_{d}: **GEO5 dice SATISFACTORY** (el grupo trabaja al @{r_ug} %).

#: **La planta del grupo** (los 20 pilotes, posiciones de los ejes):
x_p = [-6, -3, 0, 3, 6, -6, -3, 0, 3, 6, -6, -3, 0, 3, 6, -6, -3, 0, 3, 6] 'x de cada pilote [m]
y_p = [-6, -6, -6, -6, -6, -2, -2, -2, -2, -2, 2, 2, 2, 2, 2, 6, 6, 6, 6, 6] 'y de cada pilote [m]
#dibujo("Planta: cabezal de 15 × 15 m y 20 pilotes de 1.00 m (separación 3.0 m en x y 4.0 m en y)", ud = m, escala = auto, alto = 110)
#  rect(-7.5, -7.5, 15, 15, "gruesa")
#  circulo(x_p, y_p, 0.5, "media relleno")
#  linea(-9, 0, 9, 0, "eje")
#  linea(0, -9, 0, 9, "eje")
#  cota(-6, -8.3, -3, -8.3, -0.2, "3.00")
#  cota(8.3, -6, 8.3, -2, 0.2, "4.00")
#  cota(-7.5, 8.3, 7.5, 8.3, 0.2, "15.00")
#fin

#dibujo("Corte: tensión efectiva σ' a lo largo del pilote (azul, 1 m = 25 kPa); cuenta desde el fondo del cabezal", ud = m, escala = auto, alto = 120)
#  rect(-6, -5, 14, 5, "relleno amarillo tenue sinborde")
#  rect(-6, -15, 14, 10, "relleno naranja tenue sinborde")
#  linea(-6, 0, 8, 0, "media verde")
#  linea(-6, -7, 8, -7, "trazos azul")
#  texto(-5.9, -6.8, "nivel freático −7.00", 3.2, "i")
#  texto(-5.9, -4.6, "arena limosa SM", 3.2, "i")
#  texto(-5.9, -5.6, "arena con finos S-F", 3.2, "i")
#  rect(-3, -2, 6, 1, "gruesa")
#  achurado(-3, -2, 6, 1, "concreto")
#  rect(-0.5, -14, 1, 12, "gruesa")
#  achurado(-0.5, -14, 1, 12, "concreto")
#  polilinea([1, 1 + s_1/25, 1 + s_w/25, 1 + s_b/25, 1], [-2, -5, -7, -14, -14], "media azul")
#  texto(1.2 + s_b/25, -14, "σ'_{b} = 155.5 kPa", 3.2, "i")
#  texto(1.2 + s_w/25, -7, "89 kPa", 3.2, "i")
#  cota(-1.5, -14, -1.5, -2, -0.3, "12.00")
#fin

## 6 · NEC-SE-GC 2015 (oficial)

#: La NEC-15 (§8.2, p. 49) toma como carga de falla del grupo la **menor** de: (a) la suma de los pilotes, (b) el bloque que los envuelve, (c) los subgrupos con su eficiencia. GEO5 hace la (a) con la eficiencia η_{g}; el bloque (b) **no lo calcula** este programa y queda pendiente. La admisible usa el **FS = 3.0 de la Tabla 6** (p. 42), con carga muerta + viva normal (criterio nuestro para el pilote entero). En GEO5: «Safety factors (ASD)», SF_{cp} = 3.0, **sin γ_{t}** (comprobado hoy, captura «nec/02_asd_vertical_cap»: R_{c} = 2747.75, R_{g} = 50155.72, V_{d} = 29551.99 kN, FS = 1.70 < 3.00).
FS_req = 3.0 'Tabla 6, carga muerta + viva normal
R_gu = n_p·R_c1·η_g 'resistencia del grupo sin reducir (ASD) [kN]
FS_g = R_gu/V_d 'factor de seguridad del grupo
Q_adm = R_gu/FS_req 'carga admisible del grupo [kN]
Q_adm_t = Q_adm/9.80665 'carga admisible del grupo [tonf]
#hide
r_fs = round(FS_g, 2)
r_qa = round(Q_adm_t, 0)
#show
#: FS = @{r_fs} < 3.0: **no cumple la NEC-15**. La carga admisible del grupo es @{r_qa} tonf. Ojo: V_{d} es carga **de cálculo**; con la de servicio del ejemplo (17500 kN + cabezal = 27051.99 kN) el FS sería 1.85, tampoco basta.
#: **Borrador 2023 (no oficial):** eficiencia entre 0.65 y 1.00 (AASHTO), Converse-Labarre para suelo granular, y LRFD; GEO5 Pile Group no tiene LRFD.

## 7 · Hekatan contra GEO5

#hide
g_Rs = 1526.46
g_Rb = 1221.29
g_Rc = 1831.84
g_Rg = 33437.14
g_Rcu = 2747.75
g_Rgu = 50155.72
g_FS = 1.70
h_Rs = round(R_s, 2)
h_Rb = round(R_b, 2)
h_Rc = round(R_c, 2)
h_Rg = round(R_g, 2)
h_Rcu = round(R_c1, 2)
h_Rgu = round(R_gu, 2)
h_FS = round(FS_g, 2)
x_Rs = round(100·(h_Rs/g_Rs - 1), 4)
x_Rb = round(100·(h_Rb/g_Rb - 1), 4)
x_Rc = round(100·(h_Rc/g_Rc - 1), 4)
x_Rg = round(100·(h_Rg/g_Rg - 1), 4)
x_Rcu = round(100·(h_Rcu/g_Rcu - 1), 4)
x_Rgu = round(100·(h_Rgu/g_Rgu - 1), 4)
x_FS = round(100·(h_FS/g_FS - 1), 3)
#show
#| Magnitud | Hekatan | GEO5 2024 | Diferencia [%] |
#|---|---:|---:|---:|
#| **R_{s}** fuste de un pilote [kN] | @{h_Rs} | @{g_Rs} | @{x_Rs} |
#| **R_{b}** punta de un pilote [kN] | @{h_Rb} | @{g_Rb} | @{x_Rb} |
#| R_{c} = (R_{s} + R_{b})/γ_{t} [kN] | @{h_Rc} | @{g_Rc} | @{x_Rc} |
#| **R_{g}** del grupo, LSD [kN] | @{h_Rg} | @{g_Rg} | @{x_Rg} |
#| R_{c} con ASD [kN] | @{h_Rcu} | @{g_Rcu} | @{x_Rcu} |
#| **R_{g}** con ASD [kN] | @{h_Rgu} | @{g_Rgu} | @{x_Rgu} |
#| FS con ASD | @{h_FS} | @{g_FS} | @{x_FS} |
#: **Todo cuadra a cuatro cifras.** Lo que el número de GEO5 obliga y la ayuda no dice: la tensión efectiva se cuenta desde el fondo del cabezal, y la separación de Seiler-Keeney es el promedio de s_{x} y s_{y}.
#: **Lo que NO es cálculo de Hekatan:** V_{d} = 29551.99 kN (= 20000 kN + 9551.99 kN; el cabezal pesa 15·15·1·25 = 5625 kN y los 3926.99 kN restantes, que son 1250·π, no se identificaron: pendiente) y el asiento del grupo (factor de grupo 3.87, 10.1 mm con la carga de servicio, curva de Poulos con gráficos que GEO5 lleva digitalizados).
