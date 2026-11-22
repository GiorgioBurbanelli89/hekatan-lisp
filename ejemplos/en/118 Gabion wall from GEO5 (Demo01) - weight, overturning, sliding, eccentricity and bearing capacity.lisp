# Gabion wall of the official GEO5 example: overturning, sliding and bearing capacity
#numerico

#: **What is calculated.** The gabion wall of the official GEO5 Gabion example (**Demo01.gga**): six blocks 1.00 m high, stepped at the back (3.50, 3.50, 2.50, 2.50, 2.00 and 1.00 m wide), with a 1:5 embankment behind and a trapezoidal surcharge. What GEO5 prints in «Verification» (complete wall: **overturning** and **sliding**) and in «Bearing cap.» (**eccentricity** and **pressure at the base**) is repeated.
#: **What is a Hekatan calculation and what is data.** The wall weight, the moments, the forces at the base, the eccentricity, the pressure and the safety factors are calculated here. The **active thrust, the earth wedge and the front resistance** are NOT: they enter with the value that GEO5 stores in the Demo01.gga file itself (its results, with all the decimals; to two decimals they are those GEO5 2024 shows). How GEO5 calculates them with the broken terrain and the surcharge is **pending** (section 7).
#: **Judge.** The «In detail» windows of GEO5 2024 with Demo01 open (captures of 2 October).
#: **Units.** kN, m and kPa per meter of wall, as GEO5 (1 tonf = 9.80665 kN; the main results are repeated in tonf).

## 1 · Example data (Demo01.gga)

#: **Geometry** (Geometry frame): the blocks are numbered from the bottom up, all 1.00 m high, vertical face (no offset, inclination α = 0). Abscissa x from the front, y from the base.
h_b = 1 'height of each block [m]
b_1 = 3.5 'width of block 1 (the base one) [m]
b_2 = 3.5 'width of block 2 [m]
b_3 = 2.5 'width of block 3 [m]
b_4 = 2.5 'width of block 4 [m]
b_5 = 2 'width of block 5 [m]
b_6 = 1 'width of block 6 (the top) [m]
#: **Gabion fill** (Material frame, «Material No. 1»): loose stone.
gamma_g = 17 'unit weight of the stone fill [kN/m3]
#: **The bearing soil** is soil 2 of the profile. Its parameters do not appear in the captures: they were read from the Demo01.gga file itself (soil record, same format as the .guz of the wall, checked against the known soils of that one).
p_2 = 30 'friction angle of soil 2, under the base [degrees]
c_2 = 5 'cohesion of soil 2 [kPa]
#: **What GEO5 demands in this example** (Settings, «Safety factors (ASD)», permanent): overturning 1.50, sliding 1.50, bearing 1.00; eccentricity ≤ 0.333. The soil capacity is given by hand: 210 kPa.
R_d = 210 'bearing capacity of the supporting soil, example datum [kPa]
e_adm = 0.333 'admissible relative eccentricity (GEO5)
#: **The active thrust coefficient.** In the «Verification» table of the example the active thrust row has **Coeff. = 0.500** (editable cell): GEO5 multiplies its two components by 0.5 in the complete wall. The other rows have 1.000.
k_a = 0.5 'coefficient the example applies to the active thrust (GEO5 datum)

## 2 · The wall weight

#: Each block is a rectangle b_{i} × h: its weight is γ·b_{i}·h, its center is at x = b_{i}/2 (the face is common) and at y = (i − ½)·h:
S_b = b_1 + b_2 + b_3 + b_4 + b_5 + b_6 'sum of widths [m]
W_g = gamma_g·h_b·S_b 'wall weight [kN/m]
x_g = (b_1^2 + b_2^2 + b_3^2 + b_4^2 + b_5^2 + b_6^2)/(2·S_b) 'weight arm from the front [m]
y_g = h_b·(0.5·b_1 + 1.5·b_2 + 2.5·b_3 + 3.5·b_4 + 4.5·b_5 + 5.5·b_6)/S_b 'centroid height [m]

## 3 · The other forces (GEO5 data)

#: **Front resistance** (FF resistance: «at rest», soil 2, 0.70 m in front, terrain at −15°). From the file:
F_ff = 2.032927794697164 'front resistance, horizontal toward the fill [kN/m]
y_ff = 0.2333333333333334 'its height above the base (h/3 of 0.70 m) [m]
#: **Weight of the earth wedge**: the soil trapped between the steps at the back and the virtual face that GEO5 draws from the heel of block 2 («Shape of earth wedge: Calculate as skew»). From the file:
W_c = 41.475906954262925 'weight of the earth wedge [kN/m]
x_c = 2.1803341781082652 'its arm from the front [m]
y_c = 4.010443407184867 'its height [m]
#: **Active thrust** (Coulomb, according to Settings), on the virtual face and the back of blocks 1 and 2. From the file:
E_ax = 112.33693811838292 'horizontal active thrust, toward the front [kN/m]
E_az = 97.16598840898497 'vertical active thrust, downward [kN/m]
x_a = 3.0097710623577343 'arm of the vertical component [m]
y_a = 2.1050260766684157 'height of the horizontal component [m]
#: **The trapezoidal surcharge** (10 → 20 kPa over 3.00 m, at 4.50 m from the top). Here the file is NOT useful: it stores 9.37 / 7.82 kN/m, which is what GEO5 2020 calculated; GEO5 2024 gives 9.26 / 7.63. The value from the 2024 screen is used (two decimals):
S_x = 9.26 'surcharge thrust, horizontal [kN/m]
S_z = 7.63 'surcharge thrust, vertical [kN/m]
x_s = 2.95 'arm of the vertical component [m]
y_s = 2.18 'height of the horizontal component [m]

#: For the drawing: the scaled surcharge (1 m = 20 kPa) and the terrain profile behind the wall.
q_a = 10/20 'surcharge at the start, scaled
q_b = 20/20 'surcharge at the end, scaled
t_x = [1; 5; 9.5] 'terrain abscissas: top, end of the embankment, edge of the drawing [m]
t_y = [6; 6.8; 6.8] 'terrain elevations [m]
#dibujo("Demo01.gga: blocks, 1:5 embankment, trapezoidal surcharge and forces (surcharge: 1 m = 20 kPa)", ud = m, escala = auto, cotas = m, alto = 170)
#  rect(0, 0, 3.5, 1, "gruesa")
#  rect(0, 1, 3.5, 1, "gruesa")
#  rect(0, 2, 2.5, 1, "gruesa")
#  rect(0, 3, 2.5, 1, "gruesa")
#  rect(0, 4, 2, 1, "gruesa")
#  rect(0, 5, 1, 1, "gruesa")
#  achurado(0, 0, 3.5, 2, "cruzado")
#  achurado(0, 2, 2.5, 2, "cruzado")
#  achurado(0, 4, 2, 1, "cruzado")
#  achurado(0, 5, 1, 1, "cruzado")
#  polilinea(t_x, t_y, "media verde")
#  linea(-2.6, 0, 0, 0.7, "media verde")
#  linea(3.5, 0, 9.5, 0, "media")
#  linea(2.5, 4, 9.5, 4, "trazos")
#  texto(6.5, 5.3, "soil 1: γ 20, φ 25°, c 9", 2.5, "i")
#  texto(6.5, 2.0, "soil 2: γ 19, φ 30°, c 5", 2.5, "i")
#  carga(5.5, 6.8, 8.5, 6.8, q_a, q_b, "10 → 20 kPa", "azul", n = 7)
#  flecha(x_g, y_g + 1.0, x_g, y_g, "rojo")
#  texto(x_g + 0.1, y_g + 0.8, "W = 255", 2.5, "i")
#  flecha(x_a + 1.2, y_a + 1.0, x_a, y_a, "azul")
#  texto(x_a + 1.25, y_a + 1.05, "E_{a}", 2.5, "i")
#  flecha(-1.0, y_ff, 0, y_ff, "verde")
#  cota(0, -0.5, 3.5, -0.5, -0.1, "3.50")
#  cota(-0.6, 0, -0.6, 6, 0.1, "6.00")
#fin

## 4 · Overturning about the front

#: As in the cantilever wall: the verticals times their arm stabilize, the forward horizontals times their height overturn, and the front resistance **subtracts** from the overturning moment. The active thrust enters with its 0.5 coefficient:
M_res = W_g·x_g + W_c·x_c + k_a·E_az·x_a + S_z·x_s 'resisting moment [kN·m/m]
M_ovr = k_a·E_ax·y_a + S_x·y_s - F_ff·y_ff 'overturning moment [kN·m/m]
FS_o = M_res/M_ovr 'safety factor against overturning

## 5 · Sliding at the base

#: The base is horizontal: the normal is the sum of the verticals and the sliding force that of the horizontals. GEO5 help (img 1310): H_{res} = N·tan φ + c·(d − 2e), with d the base width and the cohesion only on the compressed part:
N_b = W_g + W_c + k_a·E_az + S_z 'normal at the base [kN/m]
H_a = k_a·E_ax + S_x - F_ff 'horizontal force that makes it slide [kN/m]
#: The moment about the **center of the base** is the normal times half the width minus what is left over of stability; from this, the eccentricity:
M_b = N_b·b_1/2 - (M_res - M_ovr) 'moment at the center of the base [kN·m/m]
e_b = M_b/N_b 'eccentricity of the normal [m]
H_res = N_b·tan(p_2·pi/180) + c_2·(b_1 - 2·e_b) 'resisting force [kN/m]
FS_s = H_res/H_a 'safety factor against sliding

## 6 · Eccentricity and bearing capacity

#: Uniform pressure over the compressed width b − 2e (GEO5, «Stress in the footing bottom: rectangle»):
e_r = e_b/b_1 'relative eccentricity
s_b = N_b/(b_1 - 2·e_b) 'pressure at the base [kPa]
FS_b = R_d/s_b 'bearing capacity safety factor
#hide
t_Mr = round(M_res/9.80665, 2)
t_Mo = round(M_ovr/9.80665, 2)
t_N = round(N_b/9.80665, 2)
t_sb = round(s_b/9.80665, 2)
#show
#: **In tonf:** M_{res} = @{t_Mr} and M_{ovr} = @{t_Mo} tonf·m/m, normal @{t_N} tonf/m, pressure @{t_sb} tonf/m².

## 6b · The free body: forces, arms and pressure at the base

#: **How to read the drawing.** The gabion wall (the six 1 m high blocks, with their stone fill) to scale, in meters, with the origin at the **front of the base** (the toe of the wall): it is the point about which it overturns. **Orange:** the self-weight of the wall W and that of the earth wedge W_{c}, vertical, at their centers of gravity. **Red:** the active thrust E_{a} (with the 0.500 coefficient set by the example) decomposed into horizontal (pushes toward the front) and vertical (downward), and the surcharge thrust S. **Green:** the soil resistance in front of the wall, small. **Blue under the base:** the bearing pressure, uniformly distributed over the compressed width b − 2e. Arrow scale: 1 m = 100 kN; pressure: 1 m = 100 kPa. The dimensions at the bottom are the **arms** of the vertical forces with respect to the front; those on the left, the **height** of the horizontal ones: they are the numbers that multiply in the overturning (section 4).
w_s = b_1 - 2·e_b 'compressed width of the base [m]
r_FSo = round(FS_o, 2) 'overturning SF, for the label
r_FSs = round(FS_s, 2) 'sliding SF, for the label
r_eb = round(e_b, 3) 'eccentricity, for the label
r_ws = round(w_s, 2) 'compressed width, for the label
r_sb = round(s_b, 1) 'pressure at the base, for the label
#dibujo("Free body of the gabion wall: forces, arms with respect to the front and pressure at the base", ud = m, escala = auto, cotas = m, ancho = 190, alto = 190)
#  rect(0, 0, 3.5, 1, "gruesa")
#  rect(0, 1, 3.5, 1, "gruesa")
#  rect(0, 2, 2.5, 1, "gruesa")
#  rect(0, 3, 2.5, 1, "gruesa")
#  rect(0, 4, 2, 1, "gruesa")
#  rect(0, 5, 1, 1, "gruesa")
#  achurado(0, 0, 3.5, 2, "cruzado")
#  achurado(0, 2, 2.5, 2, "cruzado")
#  achurado(0, 4, 2, 1, "cruzado")
#  achurado(0, 5, 1, 1, "cruzado")
#  polilinea(t_x, t_y, "media verde")
#  linea(3.5, 0, 9.5, 0, "media")
#  flecha(x_g, y_g + W_g/100, x_g, y_g, "naranja")
#  texto(x_g - 0.1, y_g + W_g/100 + 0.2, "W = 255 kN/m", 2.4, "d", estilo = "naranja")
#  flecha(x_c, y_c + W_c/100, x_c, y_c, "naranja")
#  texto(x_c + 0.1, y_c + W_c/100 + 0.1, "Wc = 41.5", 2.4, "i", estilo = "naranja")
#  flecha(x_a, y_a + k_a·E_az/100, x_a, y_a, "rojo")
#  flecha(x_a + k_a·E_ax/100, y_a, x_a, y_a, "rojo")
#  texto(x_a + k_a·E_ax/100 + 0.1, y_a - 0.1, "0.5·Ea = 56.2 / 48.6", 2.4, "i", estilo = "rojo")
#  flecha(x_s + 0.2, y_s + S_z/100, x_s, y_s, "rojo")
#  flecha(x_s + S_x/100, y_s, x_s, y_s, "rojo")
#  flecha(-F_ff/100 - 0.3, y_ff, 0, y_ff, "verde")
#  carga(w_s, 0, 0, 0, s_b/100, s_b/100, "", "azul", n = 7)
#  texto(w_s/2, -1.3, "pressure {r_sb} kPa over {r_ws} m", 2.4, "c", estilo = "azul")
#  cota(0, -1.7, 1.40, -1.7, -0.05, "1.40")
#  cota(0, -2.1, 2.18, -2.1, -0.05, "2.18")
#  cota(0, -2.5, 3.01, -2.5, -0.05, "3.01")
#  cota(0, -2.9, 3.5, -2.9, -0.05, "3.50")
#  cota(-0.6, 0, -0.6, 2.43, 0.1, "2.43")
#  cota(-1.3, 0, -1.3, 2.11, 0.1, "2.11")
#  cota(-2.0, 0, -2.0, 6, 0.1, "6.00")
#fin
#: **What each number says.** With the arms of the dimensions, M_{res} = @{t_Mr} tonf·m/m (verticals × arm) against M_{ovr} = @{t_Mo} tonf·m/m (horizontals × height − front resistance): overturning SF = @{r_FSo}. Sliding (SF = @{r_FSs}) compares the friction N·tan φ + c·(b − 2e) with the sum of horizontals. The normal is shifted e = @{r_eb} m from the center toward the front and the pressure is concentrated over @{r_ws} m of the 3.50 m of the base.

## 7 · Hekatan against GEO5

#hide
g_W = 255.00
g_xg = 1.40
g_yg = 2.43
g_Mr = 616.19
g_Mo = 137.95
g_FSo = 4.47
g_Hr = 217.19
g_Ha = 63.40
g_FSs = 3.43
g_M = 138.97
g_N = 352.69
g_er = 0.113
g_sb = 130.05
g_FSb = 1.61
h_W = round(W_g, 2)
h_xg = round(x_g, 2)
h_yg = round(y_g, 2)
h_Mr = round(M_res, 2)
h_Mo = round(M_ovr, 2)
h_FSo = round(FS_o, 2)
h_Hr = round(H_res, 2)
h_Ha = round(H_a, 2)
h_FSs = round(FS_s, 2)
h_M = round(M_b, 2)
h_N = round(N_b, 2)
h_er = round(e_r, 3)
h_sb = round(s_b, 2)
h_FSb = round(FS_b, 2)
d_W = round(100·(h_W/g_W - 1), 3)
d_xg = round(100·(h_xg/g_xg - 1), 3)
d_yg = round(100·(h_yg/g_yg - 1), 3)
d_Mr = round(100·(h_Mr/g_Mr - 1), 3)
d_Mo = round(100·(h_Mo/g_Mo - 1), 3)
d_FSo = round(100·(h_FSo/g_FSo - 1), 3)
d_Hr = round(100·(h_Hr/g_Hr - 1), 3)
d_Ha = round(100·(h_Ha/g_Ha - 1), 3)
d_FSs = round(100·(h_FSs/g_FSs - 1), 3)
d_M = round(100·(h_M/g_M - 1), 3)
d_N = round(100·(h_N/g_N - 1), 3)
d_er = round(100·(h_er/g_er - 1), 3)
d_sb = round(100·(h_sb/g_sb - 1), 3)
d_FSb = round(100·(h_FSb/g_FSb - 1), 3)
#show
#| Magnitud | Hekatan | GEO5 2024 | Diferencia [%] |
#|---|---:|---:|---:|
#| peso del muro [kN/m] | @{h_W} | @{g_W} | @{d_W} |
#| su brazo x [m] | @{h_xg} | @{g_xg} | @{d_xg} |
#| su altura [m] | @{h_yg} | @{g_yg} | @{d_yg} |
#| **M_{res} [kN·m/m]** | @{h_Mr} | @{g_Mr} | @{d_Mr} |
#| **M_{ovr} [kN·m/m]** | @{h_Mo} | @{g_Mo} | @{d_Mo} |
#| FS vuelco | @{h_FSo} | @{g_FSo} | @{d_FSo} |
#| **H_{res} [kN/m]** | @{h_Hr} | @{g_Hr} | @{d_Hr} |
#| **H_{act} [kN/m]** | @{h_Ha} | @{g_Ha} | @{d_Ha} |
#| FS deslizamiento | @{h_FSs} | @{g_FSs} | @{d_FSs} |
#| momento en el centro de la base [kN·m/m] | @{h_M} | @{g_M} | @{d_M} |
#| normal en la base [kN/m] | @{h_N} | @{g_N} | @{d_N} |
#| excentricidad relativa | @{h_er} | @{g_er} | @{d_er} |
#| **presión en la base [kPa]** | @{h_sb} | @{g_sb} | @{d_sb} |
#| FS capacidad portante | @{h_FSb} | @{g_FSb} | @{d_FSb} |
#: Differences with the Hekatan value rounded to the decimals of GEO5. The little that shows comes from the surcharge, which is only available with two decimals.
#: **Pending (nothing was adjusted):**
#: · **The earth wedge.** A straight face from the corner of block 2 (3.50, 2.00) at 64.0° above the horizontal gives 41.49 kN/m with centroid (2.18, 4.01), the same as GEO5; but 64.0° comes from fitting, not from a formula. The file stores the point (2.50001, 4.00), the corner of block 4: a broken face through there gives the weight but not the centroid (2.165 against 2.180). It must be taken from Gabion_5.dll.
#: · **The active thrust.** Coulomb on that face with the 1:5 slope (β = 11.31°) gives 114.08 / 99.02 kN/m against 112.34 / 97.17: 1.5 % high. The GEO5 distribution for broken terrain is missing (4 m embankment and then horizontal: sum of triangles, help «Distribution of Earth Pressures in case of Broken Terrain») and the trapezoidal surcharge split into 10 strips.
#: · **The front resistance** 2.03 kN/m: K₀ = 1 − sin 30° gives 2.33, ν/(1 − ν) gives 2.00 and the sloping terrain formula of the help (img 427) 2.60. None closes.
#: · **The surcharge**: GEO5 2020 and 2024 give different values (9.37 against 9.26 kN/m): the algorithm changed between versions.

## 8 · NEC-SE-GC 2015

#: Gabions are gravity walls: the same **Table 5** (p. 38) applies to them as to any wall: static, sliding ≥ 1.60 and overturning ≥ 3.00 **or** e/B ≤ 1/6; pseudostatic 1.05 and 2.00 (e/B ≤ 1/4). Bearing capacity, **Table 6** (p. 42): SF ≥ 3.0. For the mesh (SF_{n} of GEO5) NEC gives no value.
#: **Careful with the 0.5 of the thrust.** The GEO5 example lowers the active thrust to half in the verification table; NEC does not provide any reduction of the thrust: it is taken whole. So it is checked twice: with the 0.5 of the example and with 1.0.
N_1 = W_g + W_c + E_az + S_z 'normal with the full thrust [kN/m]
M_r1 = W_g·x_g + W_c·x_c + E_az·x_a + S_z·x_s 'resisting moment with the full thrust [kN·m/m]
M_o1 = E_ax·y_a + S_x·y_s - F_ff·y_ff 'overturning moment with the full thrust [kN·m/m]
FS_o1 = M_r1/M_o1 'overturning with the full thrust
e_1 = (N_1·b_1/2 - (M_r1 - M_o1))/N_1 'eccentricity with the full thrust [m]
FS_s1 = (N_1·tan(p_2·pi/180) + c_2·(b_1 - 2·e_1))/(E_ax + S_x - F_ff) 'sliding with the full thrust
s_1 = N_1/(b_1 - 2·e_1) 'pressure at the base with the full thrust [kPa]
FS_b1 = R_d/s_1 'bearing capacity with the full thrust
#hide
n_o = round(FS_o, 2)
n_s = round(FS_s, 2)
n_e = round(e_r, 3)
n_b = round(FS_b, 2)
n_o1 = round(FS_o1, 2)
n_s1 = round(FS_s1, 2)
n_e1 = round(e_1/b_1, 3)
n_b1 = round(FS_b1, 2)
#show
#| Verificación | GEO5 (empuje × 0.5) | Empuje entero | NEC-15 estático | ¿Cumple con el empuje entero? |
#|---|---:|---:|---:|---|
#| Volcamiento M_{R}/M_{A} | @{n_o} | @{n_o1} | 3.00 | **no** (por poco) |
#| Excentricidad e/B | @{n_e} | @{n_e1} | 0.167 | sí |
#| Deslizamiento | @{n_s} | @{n_s1} | 1.60 | sí |
#| Capacidad portante (R_{d} = 210 kPa) | @{n_b} | @{n_b1} | 3.0 | **no** |
#: **Reading.** With the full thrust the overturning by moments drops from 4.47 to @{n_o1}: it stays just below 3.00. Table 5 accepts overturning by eccentricity, and e/B = @{n_e1} does fall within 1/6 (my reading of «whichever turns out more critical»; the conservative one demands both). Sliding is comfortably met. The bearing capacity does not reach the NEC 3.0 even with the 0.5: with 210 kPa as ultimate capacity the admissible is 70 kPa and the base presses more than 130 kPa.
#: **NEC 2023 draft (unofficial):** load and resistance factors (active thrust ×1.50, earth weight ×1.35; overturning ΣM_{r}/ΣM_{a} from 1.50 to 1.35) and sliding **without the front resistance** (here 2.03 kN/m, almost nothing).
