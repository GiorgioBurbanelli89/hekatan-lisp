# Cantilever wall of the official GEO5 example: thrust, overturning, sliding and bearing capacity
#numerico

#: **What is calculated.** The wall of the official GEO5 Cantilever Wall example (**Demo01.guz**): 5.00 m stem on a 4.10 × 0.60 m footing with a key, three strata behind and a horizontal force of 30 kN/m at the top. It repeats, number by number, what GEO5 prints in the "Verification" and "Bearing cap." frames: the five forces, the **overturning**, the **sliding**, the **eccentricity** and the **pressure at the base**.
#: **How.** Active thrust by **Coulomb** with the branch that GEO5 uses, taken from the binary CantileverWall_5.dll (function 0xD9509C): K_{a} with α, β and δ, and the cohesion with K_{ac} = cos φ·cos β·(1 + tan α·tan β)/(1 + sin(φ + δ + α − β)). Behind the heel GEO5 does not push against the stem: it forms an **earth wedge** and pushes on an inclined virtual face ("Shape of earth wedge: Calculate as skew").
#: **Judge.** The "In detail" windows of GEO5 2024 with Demo01 open (captures of October 2). At the end, the table **Hekatan against GEO5** with the difference in %, and the check with **NEC-SE-GC 2015**.
#: **Units.** kN, m and kPa per meter of wall, as GEO5 (1 tonf = 9.80665 kN; the main results are repeated in tonf). Inside the formulas the angles are in radians; the data are written in degrees.

## 1 · Example data (Demo01.guz)

#: **Geometry.** Abscissa x from the toe tip toward the backfill; ordinate y from the bottom of the footing upward (GEO5 prints z = −y).
B_z = 4.1 'footing width [m]
h_z = 0.6 'footing depth [m]
x_p = 1 'toe: from the tip to the front face of the stem, at the bottom [m]
b_f = 0.6 'stem thickness at the bottom [m]
t_f = 0.2 'stem thickness at the top [m]
H_f = 5 'stem height above the footing [m]
x_t = x_p + b_f 'abscissa of the back face of the stem (vertical) [m]
L_t = B_z - x_t 'heel: overhang behind the stem [m]
y_s = h_z + H_f 'ground elevation behind the wall = top [m]
b_d = 0.5 'key width, under the end of the heel [m]
h_d = 0.2 'key height [m]
gamma_c = 23 'unit weight of the concrete (Material frame) [kN/m3]
#: **The three strata** (Profile, Soils and Assign frames): thicknesses from the top 2.30 m, 1.70 m and the rest. δ is the soil-structure friction.
y_12 = y_s - 2.3 'elevation of the soil 1 / soil 2 contact [m]
y_23 = y_12 - 1.7 'elevation of the soil 2 / soil 3 contact [m]
g_1 = 19 'unit weight of soil 1 [kN/m3]
p_1 = 29 'friction angle of soil 1 [degrees]
c_1 = 10 'cohesion of soil 1 [kPa]
g_2 = 17.5 'unit weight of soil 2 [kN/m3]
p_2 = 31.5 'friction angle of soil 2 [degrees]
c_2 = 0 'cohesion of soil 2 [kPa]
g_3 = 19.5 'unit weight of soil 3 [kN/m3]
p_3 = 27 'friction angle of soil 3 (also under the base) [degrees]
c_3 = 10 'cohesion of soil 3 [kPa]
d_s = 15 'soil-structure friction δ of the three soils [degrees]
#: **In front of the wall** (FF resistance frame): 0.50 m of soil 1, "at rest" resistance, no surcharge.
h_ff = 0.5 'thickness of the soil in front, above the bottom of the footing [m]
#: **The applied force** (Applied forces frame, "Force No. 1"): 30 kN/m forward, 0.20 m above the top, on the stem axis.
F_1 = 30 'horizontal force at the top, toward the toe [kN/m]
x_F = 1.5 'abscissa of the force [m]
y_F = 5.8 'elevation of the force [m]
#: **What GEO5 requires in this example** (Settings, "Safety factors (ASD)"): overturning 1.50, sliding 1.50, bearing 1.00 and eccentricity ≤ 0.333. The soil capacity is given by hand: 180 kPa.
SF_o = 1.5 'factor required for overturning (GEO5)
SF_s = 1.5 'factor required for sliding (GEO5)
R_d = 180 'bearing capacity of the supporting soil, example datum [kPa]
e_adm = 0.333 'admissible relative eccentricity (GEO5)

## 2 · The weight of the wall, by parts

#: The wall is split into four simple figures: the footing (rectangle), the key (rectangle), the straight 0.20 m stem (rectangle) and the front wedge of the stem (0.40 × 5.00 m triangle). Area per figure and its centroid:
A_1 = B_z·h_z 'footing [m2]
A_2 = b_d·h_d 'key [m2]
A_3 = t_f·H_f 'straight stem, of the top width [m2]
A_4 = (b_f - t_f)·H_f/2 'front wedge of the stem [m2]
A_m = A_1 + A_2 + A_3 + A_4 'total area of the section [m2]
W_m = gamma_c·A_m 'weight of the wall [kN/m]
#: The centroid of each figure (that of the triangle is at one third of its legs) and that of the whole, weighting by areas:
x_m = (A_1·B_z/2 + A_2·(B_z - b_d/2) + A_3·(x_t - t_f/2) + A_4·(x_p + 2·(b_f - t_f)/3))/A_m 'horizontal arm of the weight [m]
y_m = (A_1·h_z/2 - A_2·h_d/2 + A_3·(h_z + H_f/2) + A_4·(h_z + H_f/3))/A_m 'height of the centroid [m]

## 3 · The resistance in front of the wall (at-rest thrust)

#: GEO5 counts the soil in front "at rest": K₀ = 1 − sin φ (GEO5 help, "Pressure at Rest", non-cohesive soil) over 0.50 m of soil 1. It is a pressure triangle, resultant at one third of its height:
K_0 = 1 - sin(p_1·pi/180) 'at-rest thrust coefficient of soil 1
E_ff = K_0·g_1·h_ff^2/2 'front resistance [kN/m]
y_ff = h_ff/3 'height of its resultant above the bottom [m]
#: This force pushes toward the backfill, against overturning and against sliding.

## 4 · The earth wedge behind the stem

#: GEO5 help, "Earth - Pressure Wedge": when the wall has a heel, the thrust is not calculated on the stem face but on a **virtual face** that leaves the end of the heel and rises until it touches the stem. The soil of the wedge (stem, heel and virtual face) travels with the wall: **its weight is a stabilizing force**.
#: **The angle of the virtual face.** Here it is 45° + φ̄/2 above the horizontal, with φ̄ = the thickness-weighted mean of φ over the 5.00 m of the stem. **This is a hypothesis that matches GEO5, it was not seen in the binary** (see section 10): the help describes another procedure, layer by layer, that does not give these numbers.
p_m = (2.3·p_1 + 1.7·p_2 + (H_f - 4)·p_3)/H_f 'mean φ over the stem height [degrees]
th = (45 + p_m/2)·pi/180 'inclination of the virtual face above the horizontal [rad]
y_T = h_z + L_t·tan(th) 'elevation where the virtual face cuts the stem [m]
h_c = y_T - h_z 'height of the wedge [m]
a_v = pi/2 - th 'inclination of the virtual face from the vertical, α [rad]
#: The width of the wedge decreases linearly from L_{t} (over the heel) to zero (at y_{T}); the soil changes at y_{12} and at y_{23}, so the weight is integrated by strata:
w_c(y) = L_t·(1 - (y - h_z)/h_c)
W_c3 = g_3·integral(@(y) w_c(y), h_z, y_23) 'weight of the wedge in soil 3 [kN/m]
W_c2 = g_2·integral(@(y) w_c(y), y_23, y_12) 'weight of the wedge in soil 2 [kN/m]
W_c1 = g_1·integral(@(y) w_c(y), y_12, y_T) 'weight of the wedge in soil 1 [kN/m]
W_c = W_c1 + W_c2 + W_c3 'weight of the wedge [kN/m]
#: The centroid comes from the same integrals with the arm inside (the strip at height y has its center at x_{t} + w/2):
x_c = (g_3·integral(@(y) w_c(y)·(x_t + w_c(y)/2), h_z, y_23) + g_2·integral(@(y) w_c(y)·(x_t + w_c(y)/2), y_23, y_12) + g_1·integral(@(y) w_c(y)·(x_t + w_c(y)/2), y_12, y_T))/W_c 'horizontal arm of the wedge [m]
y_c = (g_3·integral(@(y) w_c(y)·y, h_z, y_23) + g_2·integral(@(y) w_c(y)·y, y_23, y_12) + g_1·integral(@(y) w_c(y)·y, y_12, y_T))/W_c 'height of the centroid of the wedge [m]

## 5 · Coulomb active thrust

#: **The vertical pressure** at elevation y: each stratum weighs its γ times the thickness it has above y.
s_z(y) = g_1·(y_s - max(y, y_12)) + g_2·max(0, y_12 - max(y, y_23)) + g_3·max(0, y_23 - y)
#: **The Coulomb coefficients** (GEO5 binary, 0xD9509C, with horizontal ground β = 0). φ, δ and α in radians; α is the inclination of the face from the vertical:
K_a(f, d, a) = cos(f - a)^2/(cos(a)^2·cos(a + d)·(1 + sqrt(sin(f + d)·sin(f)/(cos(a + d)·cos(a))))^2)
K_ac(f, d, a) = cos(f)/(1 + sin(f + d + a))
#: and the active pressure, σ_{a} = σ_{z}·K_{a} − 2·c·K_{ac}, without going below zero (where it comes out negative the soil detaches: tension crack).
#: **Three faces push**: (S1) the stem above the wedge, with δ = 15°; (S2) the virtual face, soil against soil, with **δ = φ**; (S3) the vertical face of the end of the heel down to the bottom of the key, with δ = 15°. S2 crosses the three strata, so it is split into S2a, S2b and S2c. In each segment the pressure is linear: the resultant is the area of the trapezoid and its height, that of its centroid.
r_g = pi/180 'degrees to radians

#: **S1 · stem, from y_{s} to y_{T}** (soil 1):
K_1 = K_a(p_1·r_g, d_s·r_g, 0) 'K_a in S1
k_1 = K_ac(p_1·r_g, d_s·r_g, 0) 'K_ac in S1
s_1a = K_1·s_z(y_s) - 2·c_1·k_1 'σ_a at the top of S1 [kPa]
s_1b = K_1·s_z(y_T) - 2·c_1·k_1 'σ_a at the bottom of S1 [kPa]
#: Both come out **negative**: with c = 10 kPa soil 1 supports itself over those 0.72 m and does not push. S1 contributes zero.

#: **S2a · virtual face in soil 1, from y_{T} to y_{12}** (δ = φ₁):
K_2a = K_a(p_1·r_g, p_1·r_g, a_v) 'K_a in S2a
k_2a = K_ac(p_1·r_g, p_1·r_g, a_v) 'K_ac in S2a
s_2a = K_2a·s_z(y_T) - 2·c_1·k_2a 'σ_a at the top [kPa]
s_2b = K_2a·s_z(y_12) - 2·c_1·k_2a 'σ_a at the bottom [kPa]
E_2a = (s_2a + s_2b)/2·(y_T - y_12) 'resultant of the segment [kN/m]
z_2a = y_12 + (y_T - y_12)·(2·s_2a + s_2b)/(3·(s_2a + s_2b)) 'elevation of the resultant [m]

#: **S2b · virtual face in soil 2, from y_{12} to y_{23}** (δ = φ₂, c₂ = 0):
K_2b = K_a(p_2·r_g, p_2·r_g, a_v) 'K_a in S2b
k_2b = K_ac(p_2·r_g, p_2·r_g, a_v) 'K_ac in S2b
s_3a = K_2b·s_z(y_12) - 2·c_2·k_2b 'σ_a at the top [kPa]
s_3b = K_2b·s_z(y_23) - 2·c_2·k_2b 'σ_a at the bottom [kPa]
E_2b = (s_3a + s_3b)/2·(y_12 - y_23) 'resultant of the segment [kN/m]
z_2b = y_23 + (y_12 - y_23)·(2·s_3a + s_3b)/(3·(s_3a + s_3b)) 'elevation of the resultant [m]

#: **S2c · virtual face in soil 3, from y_{23} to the heel** (δ = φ₃):
K_2c = K_a(p_3·r_g, p_3·r_g, a_v) 'K_a in S2c
k_2c = K_ac(p_3·r_g, p_3·r_g, a_v) 'K_ac in S2c
s_4a = K_2c·s_z(y_23) - 2·c_3·k_2c 'σ_a at the top [kPa]
s_4b = K_2c·s_z(h_z) - 2·c_3·k_2c 'σ_a at the bottom [kPa]
E_2c = (s_4a + s_4b)/2·(y_23 - h_z) 'resultant of the segment [kN/m]
z_2c = h_z + (y_23 - h_z)·(2·s_4a + s_4b)/(3·(s_4a + s_4b)) 'elevation of the resultant [m]

#: **S3 · vertical face of the end of the heel, from the heel to the bottom of the key** (soil 3, δ = 15°):
K_3 = K_a(p_3·r_g, d_s·r_g, 0) 'K_a in S3
k_3 = K_ac(p_3·r_g, d_s·r_g, 0) 'K_ac in S3
s_5a = K_3·s_z(h_z) - 2·c_3·k_3 'σ_a at the top [kPa]
s_5b = K_3·s_z(-h_d) - 2·c_3·k_3 'σ_a at the bottom [kPa]
E_3 = (s_5a + s_5b)/2·(h_z + h_d) 'resultant of the segment [kN/m]
z_3 = -h_d + (h_z + h_d)·(2·s_5a + s_5b)/(3·(s_5a + s_5b)) 'elevation of the resultant [m]

#: **Components.** Each resultant is inclined δ + α from the horizontal (GEO5 help: σ_{ax} = σ_{a}·cos(α + δ), σ_{az} = σ_{a}·sin(α + δ)). On the virtual face, the abscissa of each resultant lies on the face itself: x = x_{t} + (y_{T} − z)/tan θ.
u_1 = p_1·r_g + a_v 'δ + α in S2a [rad]
u_2 = p_2·r_g + a_v 'δ + α in S2b [rad]
u_3 = p_3·r_g + a_v 'δ + α in S2c [rad]
u_4 = d_s·r_g 'δ + α in S3 [rad]
E_ax = E_2a·cos(u_1) + E_2b·cos(u_2) + E_2c·cos(u_3) + E_3·cos(u_4) 'horizontal active thrust [kN/m]
E_az = E_2a·sin(u_1) + E_2b·sin(u_2) + E_2c·sin(u_3) + E_3·sin(u_4) 'vertical active thrust [kN/m]
y_a = (E_2a·cos(u_1)·z_2a + E_2b·cos(u_2)·z_2b + E_2c·cos(u_3)·z_2c + E_3·cos(u_4)·z_3)/E_ax 'height of the horizontal thrust [m]
x_a = (E_2a·sin(u_1)·(x_t + (y_T - z_2a)/tan(th)) + E_2b·sin(u_2)·(x_t + (y_T - z_2b)/tan(th)) + E_2c·sin(u_3)·(x_t + (y_T - z_2c)/tan(th)) + E_3·sin(u_4)·B_z)/E_az 'arm of the vertical thrust [m]
#hide
r_K1 = round(K_2a, 3)
r_K2 = round(K_2b, 3)
r_K3 = round(K_2c, 3)
r_th = round(th/r_g, 3)
#show
#: **Reading.** On the virtual face K_{a} comes out @{r_K1}, @{r_K2} and @{r_K3}, double that of a smooth wall (≈ 0.33): the face is leaning (θ = @{r_th}°) and the soil above loads it. In exchange, the thrust arrives strongly inclined (δ + α ≈ 60°) and its vertical component **stabilizes** the wall: it is larger than the horizontal one.

#: **The pressures, drawn.** The blue block is σ_{a} on each face (scale: 1 m of the drawing = 25 kPa), perpendicular to the face; the wedge is the hatched zone.
q_1 = s_2a/25 'σa at the top of S2a, scaled
q_2 = s_2b/25 'σa at the bottom of S2a, scaled
q_3 = s_3a/25 'σa at the top of S2b, scaled
q_4 = s_3b/25 'σa at the bottom of S2b, scaled
q_5 = s_4a/25 'σa at the top of S2c, scaled
q_6 = s_4b/25 'σa at the bottom of S2c, scaled
q_7 = s_5a/25 'σa at the top of S3, scaled
q_8 = s_5b/25 'σa at the bottom of S3, scaled
x_12 = x_t + (y_T - y_12)/tan(th) 'abscissa of the virtual face at y12 [m]
x_23 = x_t + (y_T - y_23)/tan(th) 'abscissa of the virtual face at y23 [m]
#dibujo("Demo01.guz: wall, strata, earth wedge and Coulomb active thrust (blue, 1 m = 25 kPa)", ud = m, escala = auto, cotas = m, alto = 190)
#  poligono(0, 0, 3.6, 0, 3.6, -0.2, 4.1, -0.2, 4.1, 0.6, 1.6, 0.6, 1.6, 5.6, 1.4, 5.6, 1.0, 0.6, 0, 0.6, "gruesa")
#  achurado(0, 0, 4.1, 0.6, "concreto")
#  poligono(x_t, h_z, B_z, h_z, x_t, y_T, "verde tenue")
#  linea(x_t, y_T, B_z, h_z, "trazos verde")
#  linea(1.6, 5.6, 7.6, 5.6, "media verde")
#  linea(1.6, y_12, 7.6, y_12, "trazos")
#  linea(1.6, y_23, 7.6, y_23, "trazos")
#  linea(-1.5, 0.5, 0, 0.5, "media verde")
#  texto(5.3, 5.0, "soil 1: γ 19, φ 29°, c 10", 2.5, "i")
#  texto(5.3, 2.75, "soil 2: γ 17.5, φ 31.5°, c 0", 2.5, "i")
#  texto(5.3, 1.05, "soil 3: γ 19.5, φ 27°, c 10", 2.5, "i")
#  carga(x_t, y_T, x_12, y_12, q_1, q_2, "", "azul", n = 5)
#  carga(x_12, y_12, x_23, y_23, q_3, q_4, "", "azul", n = 6)
#  carga(x_23, y_23, B_z, h_z, q_5, q_6, "", "azul", n = 5)
#  carga(B_z, h_z, B_z, -h_d, q_7, q_8, "", "azul", n = 3)
#  flecha(2.9, 5.8, 1.6, 5.8, "rojo")
#  texto(3.0, 5.85, "F = 30 kN/m", 2.5, "i")
#  texto(2.05, 1.5, "wedge", 2.5, "c")
#  cota(0, -0.6, 4.1, -0.6, -0.1, "4.10")
#  cota(-0.5, 0.6, -0.5, 5.6, 0.1, "5.00")
#fin
#: The virtual face (green dashed) cuts the stem at @{r_th}° above the horizontal. In segment S1 there is no block: the pressure is negative and GEO5 takes it as zero.

## 6 · The five forces (the GEO5 "Verification" table)

#: GEO5 convention: F_{x} negative toward the toe (destabilizing), F_{z} positive downward; x from the tip, z = −y.
#hide
h_W = round(W_m, 2)
h_xm = round(x_m, 2)
h_ym = round(-y_m, 2)
h_E = round(E_ff, 2)
h_yf = round(-y_ff, 2)
h_Wc = round(W_c, 2)
h_xc = round(x_c, 2)
h_yc = round(-y_c, 2)
h_Ex = round(-E_ax, 2)
h_Ez = round(E_az, 2)
h_xa = round(x_a, 2)
h_ya = round(-y_a, 2)
#show
#| N.º | Fuerza | F_{x} [kN/m] | F_{z} [kN/m] | x [m] | z [m] | GEO5: F_{x} · F_{z} · x · z |
#|---|---|---:|---:|---:|---:|---|
#| 1 | Peso del muro | 0.00 | @{h_W} | @{h_xm} | @{h_ym} | 0.00 · 104.88 · 1.80 · −1.34 |
#| 2 | Resistencia frontal | @{h_E} | 0.00 | 0.00 | @{h_yf} | 1.22 · 0.00 · 0.00 · −0.17 |
#| 3 | Peso de la cuña | 0.00 | @{h_Wc} | @{h_xc} | @{h_yc} | 0.00 · 99.17 · 2.44 · −2.00 |
#| 4 | Empuje activo | @{h_Ex} | @{h_Ez} | @{h_xa} | @{h_ya} | −84.30 · 118.67 · 3.26 · −1.65 |
#| 5 | Force No. 1 | −30.00 | 0.00 | 1.50 | −5.80 | −30.00 · 0.00 · 1.50 · −5.80 |

## 7 · Overturning about the toe

#: **Resisting moment**: the vertical forces times their arm from the tip. **Overturning moment**: the horizontal forces that push forward times their height; GEO5 **subtracts** the front resistance from the overturning one (it does not add it to the resisting one):
M_res = W_m·x_m + W_c·x_c + E_az·x_a 'resisting moment [kN·m/m]
M_ovr = E_ax·y_a + F_1·y_F - E_ff·y_ff 'overturning moment [kN·m/m]
FS_o = M_res/M_ovr 'safety factor against overturning

## 8 · Sliding on the inclined base

#: The key makes GEO5 take the base as **inclined**, from the tip (0, 0) to the bottom of the key (4.10, −0.20) ("The base key is considered as inclined footing bottom"). The forces are projected on that line:
a_b = atan(h_d/B_z) 'inclination of the base [rad]
L_b = sqrt(B_z^2 + h_d^2) 'length of the inclined base [m]
V_t = W_m + W_c + E_az 'sum of vertical forces [kN/m]
H_t = E_ax + F_1 - E_ff 'sum of horizontal forward forces [kN/m]
N_b = V_t·cos(a_b) + H_t·sin(a_b) 'normal to the base [kN/m]
T_b = H_t·cos(a_b) - V_t·sin(a_b) 'force that makes it slide, along the base [kN/m]
#: The moment about the center of the inclined base (B_{z}/2, −h_{d}/2) gives the eccentricity; the adhesion c₃ only acts on the compressed width L_{b} − 2e:
M_b = W_m·(B_z/2 - x_m) + W_c·(B_z/2 - x_c) + E_az·(B_z/2 - x_a) + E_ax·(y_a + h_d/2) + F_1·(y_F + h_d/2) - E_ff·(y_ff + h_d/2) 'moment at the center of the base [kN·m/m]
e_b = M_b/N_b 'eccentricity of the normal [m]
H_res = N_b·tan(p_3·r_g) + c_3·(L_b - 2·e_b) 'resisting force: friction + adhesion [kN/m]
FS_s = H_res/T_b 'safety factor against sliding

## 9 · Eccentricity and bearing capacity

#: GEO5 ("Bearing cap.", "rectangle" pressure): the normal is distributed uniformly over the compressed width, and the eccentricity is compared relative to the width:
e_r = e_b/L_b 'relative eccentricity (GEO5 compares it with 0.333)
s_b = N_b/(L_b - 2·e_b) 'pressure at the bottom, distributed over the effective width [kPa]
FS_b = R_d/s_b 'safety factor of the bearing capacity
#hide
t_Ea = round(E_ax/9.80665, 2)
t_Mr = round(M_res/9.80665, 2)
t_Mo = round(M_ovr/9.80665, 2)
t_sb = round(s_b/9.80665, 2)
t_Hr = round(H_res/9.80665, 2)
#show
#: **In tonf** (per meter of wall): horizontal thrust @{t_Ea} tonf/m, M_{res} = @{t_Mr} and M_{ovr} = @{t_Mo} tonf·m/m, H_{res} = @{t_Hr} tonf/m, base pressure @{t_sb} tonf/m².

## 9b · The free body: the five forces, their arms and the pressure at the base

#: **How to read the drawing.** It is the Demo01 wall to scale, in meters, with the origin at the **tip** of the footing (the lower left corner): the forces of the table in section 6 placed where they act. **Orange:** the weight of the wall W (with that of the key) and the weight of the earth wedge W_{c}, vertical downward, at their centers of gravity. **Red:** the Coulomb active thrust, which is split into a **horizontal** part E_{ax} (toward the tip: it tends to **overturn** and **slide** the wall) and a **vertical** one E_{az} (downward: it helps stabilize because the backfill rubs against the wall), and the 30 kN/m force at the top. **Blue below the base:** the soil pressure on the footing, which GEO5 distributes **uniformly** over the compressed width (the base minus twice the eccentricity). Arrow scale: 1 m = 100 kN; of the pressure: 1 m = 100 kPa.
x_R = B_z/2 - e_b 'where the resultant falls from the tip (eccentricity toward the tip) [m]
w_s = L_b - 2·e_b 'compressed width of the base [m]
r_FSo = round(FS_o, 2) 'FS against overturning, for the label
r_eb = round(e_b, 2) 'eccentricity, for the label
r_ws = round(w_s, 2) 'compressed width, for the label
r_sb = round(s_b, 1) 'base pressure, for the label
#dibujo("Free body of the Demo01 wall: forces of the GEO5 table, arms and pressure at the base", ud = m, escala = auto, cotas = m, ancho = 180, alto = 190)
#  poligono(0, 0, 3.6, 0, 3.6, -0.2, 4.1, -0.2, 4.1, 0.6, 1.6, 0.6, 1.6, 5.6, 1.4, 5.6, 1.0, 0.6, 0, 0.6, "gruesa")
#  achurado(0, 0, 4.1, 0.6, "concreto")
#  poligono(x_t, h_z, B_z, h_z, x_t, y_T, "verde tenue")
#  linea(x_t, y_T, B_z, h_z, "trazos verde")
#  flecha(x_m, y_m + W_m/100, x_m, y_m, "naranja")
#  texto(x_m - 0.1, y_m + W_m/100 + 0.2, "W = 104.9 kN/m", 2.4, "d", estilo = "naranja")
#  flecha(x_c, y_c + W_c/100, x_c, y_c, "naranja")
#  texto(x_c + 0.15, y_c + W_c/100 - 0.1, "Wc = 99.2 kN/m", 2.4, "i", estilo = "naranja")
#  flecha(x_a, y_a + E_az/100, x_a, y_a, "rojo")
#  texto(x_a + 0.15, y_a + E_az/100 - 0.2, "Eaz = 118.7", 2.4, "i", estilo = "rojo")
#  flecha(x_a + E_ax/100, y_a, x_a, y_a, "rojo")
#  texto(x_a + E_ax/100 + 0.1, y_a + 0.2, "Eax = 84.3 kN/m", 2.4, "i", estilo = "rojo")
#  flecha(1.6 + F_1/100 + 0.4, y_F, 1.6, y_F, "rojo")
#  texto(2.35, y_F + 0.3, "F = 30 kN/m", 2.4, "i", estilo = "rojo")
#  carga(w_s, 0, 0, 0, s_b/100, s_b/100, "", "azul", n = 7)
#  circulo(x_R, 0, 0.07, "verde relleno")
#  texto(x_R, -1.0, "resultant", 2.4, "c", estilo = "verde")
#  cota(0, -1.35, 1.80, -1.35, -0.05, "1.80")
#  cota(0, -1.75, 2.44, -1.75, -0.05, "2.44")
#  cota(0, -2.15, 3.26, -2.15, -0.05, "3.26")
#  cota(0, -2.55, B_z, -2.55, -0.05, "4.10")
#  cota(-0.5, 0, -0.5, y_a, 0.1, "1.65")
#  cota(-1.3, 0, -1.3, y_F, 0.1, "5.80")
#fin
#: **How overturning and sliding are calculated with this drawing.** **Overturning** is rotation about the tip (origin): each vertical force multiplied by its horizontal arm (the dimensions below: 1.80, 2.44 and 3.26 m) gives the **resisting** moment; each horizontal force by its height (1.65 m the thrust, 5.80 m the force at the top) gives the **overturning** moment. Their quotient is FS = @{r_FSo}. **Sliding** compares the friction of the base (N·tan φ plus adhesion) with the force that pushes along it. The **eccentricity** e = @{r_eb} m is how far the resultant shifts from the center of the base toward the tip; the pressure concentrates over the width w = @{r_ws} m and equals @{r_sb} kPa, which is compared with the bearing capacity of 180 kPa.

## 10 · Hekatan against GEO5

#hide
g_W = 104.88
g_xm = 1.80
g_ff = 1.22
g_Wc = 99.17
g_xc = 2.44
g_yc = 2.00
g_Ex = 84.30
g_Ez = 118.67
g_xa = 3.26
g_ya = 1.65
g_Mr = 817.56
g_Mo = 313.07
g_FSo = 2.61
g_Hr = 197.82
g_Ha = 97.21
g_FSs = 2.03
g_M = 168.39
g_N = 327.85
g_er = 0.125
g_sb = 106.53
g_FSb = 1.69
h_Ex2 = round(E_ax, 2)
h_yc2 = round(y_c, 2)
h_ya2 = round(y_a, 2)
h_Mr = round(M_res, 2)
h_Mo = round(M_ovr, 2)
h_FSo = round(FS_o, 2)
h_Hr = round(H_res, 2)
h_Ha = round(T_b, 2)
h_FSs = round(FS_s, 2)
h_M = round(M_b, 2)
h_N = round(N_b, 2)
h_er = round(e_r, 3)
h_sb = round(s_b, 2)
h_FSb = round(FS_b, 2)
x_W = round(100·(h_W/g_W - 1), 3)
x_xm = round(100·(h_xm/g_xm - 1), 3)
x_ff = round(100·(h_E/g_ff - 1), 3)
x_Wc = round(100·(h_Wc/g_Wc - 1), 3)
x_xc = round(100·(h_xc/g_xc - 1), 3)
x_yc = round(100·(h_yc2/g_yc - 1), 3)
x_Ex = round(100·(h_Ex2/g_Ex - 1), 3)
x_Ez = round(100·(h_Ez/g_Ez - 1), 3)
x_xa = round(100·(h_xa/g_xa - 1), 3)
x_ya = round(100·(h_ya2/g_ya - 1), 3)
x_Mr = round(100·(h_Mr/g_Mr - 1), 3)
x_Mo = round(100·(h_Mo/g_Mo - 1), 3)
x_FSo = round(100·(h_FSo/g_FSo - 1), 3)
x_Hr = round(100·(h_Hr/g_Hr - 1), 3)
x_Ha = round(100·(h_Ha/g_Ha - 1), 3)
x_FSs = round(100·(h_FSs/g_FSs - 1), 3)
x_M = round(100·(h_M/g_M - 1), 3)
x_N = round(100·(h_N/g_N - 1), 3)
x_er = round(100·(h_er/g_er - 1), 3)
x_sb = round(100·(h_sb/g_sb - 1), 3)
x_FSb = round(100·(h_FSb/g_FSb - 1), 3)
#show
#| Magnitud | Hekatan | GEO5 2024 | Diferencia [%] |
#|---|---:|---:|---:|
#| peso del muro [kN/m] | @{h_W} | @{g_W} | @{x_W} |
#| su brazo x [m] | @{h_xm} | @{g_xm} | @{x_xm} |
#| resistencia frontal [kN/m] | @{h_E} | @{g_ff} | @{x_ff} |
#| peso de la cuña [kN/m] | @{h_Wc} | @{g_Wc} | @{x_Wc} |
#| cuña: x [m] | @{h_xc} | @{g_xc} | @{x_xc} |
#| cuña: altura [m] | @{h_yc2} | @{g_yc} | @{x_yc} |
#| empuje horizontal [kN/m] | @{h_Ex2} | @{g_Ex} | @{x_Ex} |
#| empuje vertical [kN/m] | @{h_Ez} | @{g_Ez} | @{x_Ez} |
#| empuje: x [m] | @{h_xa} | @{g_xa} | @{x_xa} |
#| empuje: altura [m] | @{h_ya2} | @{g_ya} | @{x_ya} |
#| **M_{res} [kN·m/m]** | @{h_Mr} | @{g_Mr} | @{x_Mr} |
#| **M_{ovr} [kN·m/m]** | @{h_Mo} | @{g_Mo} | @{x_Mo} |
#| FS vuelco | @{h_FSo} | @{g_FSo} | @{x_FSo} |
#| **H_{res} [kN/m]** | @{h_Hr} | @{g_Hr} | @{x_Hr} |
#| **H_{act} [kN/m]** | @{h_Ha} | @{g_Ha} | @{x_Ha} |
#| FS deslizamiento | @{h_FSs} | @{g_FSs} | @{x_FSs} |
#| momento en el centro de la base [kN·m/m] | @{h_M} | @{g_M} | @{x_M} |
#| normal a la base [kN/m] | @{h_N} | @{g_N} | @{x_N} |
#| excentricidad relativa | @{h_er} | @{g_er} | @{x_er} |
#| **presión en la base [kPa]** | @{h_sb} | @{g_sb} | @{x_sb} |
#| FS capacidad portante | @{h_FSb} | @{g_FSb} | @{x_FSb} |
#: Differences with the Hekatan value rounded to the decimals GEO5 prints.
#: **What does not match to four digits:** the wedge (99.19 versus 99.17, 0.02 %) and the vertical thrust (118.65 versus 118.67). Both come from the angle of the virtual face: with 45° + φ̄/2 = 59.725° they do not close; with 59.720° both close at once (and the height of the wedge, 2.005 m, falls right on the rounding edge: it comes out 2.01 here and 2.00 in GEO5). Where exactly that angle comes from is **not resolved**: the help ("Earth - Pressure Wedge") gives a layer-by-layer formula (υ_{a} = φ + ε) that, tried with β = 0 and δ = 15° or δ = φ, gives 54° to 58°, not 59.7°. Extracting it from CantileverWall_5.dll (the wedge routine) is pending; **no factor was adjusted**.
#: **What is not compared:** GEO5 prints in "Bearing cap." a "Shear Force" of 96.96 kN/m that is not the H_{act} = 97.21 of the verification; with the forces of this sheet both come out 97.22. It is not known what projection that column uses: pending. It does not enter any verification.

## 11 · NEC-SE-GC 2015

#: **What the official code asks** (NEC-SE-GC 2015, §5.2, **Table 5**, p. 38, static condition): sliding ≥ 1.60, overturning M_{R}/M_{A} ≥ 3.00 **or** eccentricity e/B ≤ 1/6, whichever is more critical; with earthquake (pseudostatic) 1.05 and 2.00 (e/B ≤ 1/4). Bearing capacity: **Table 6**, p. 42, FS ≥ 3.0 with dead load + normal live load (1.5 with earthquake).
#: GEO5 in this example uses 1.50 / 1.50 / 1.00 (Settings of Demo01): **they are not those of the NEC**.
#hide
n_o = round(FS_o, 2)
n_s = round(FS_s, 2)
n_e = round(e_r, 3)
n_b = round(FS_b, 2)
#show
#| Verificación | Hekatan = GEO5 | GEO5 pide | NEC-15 estático | ¿Cumple la NEC? |
#|---|---:|---:|---:|---|
#| Volcamiento M_{R}/M_{A} | @{n_o} | 1.50 | 3.00 | **no** |
#| Excentricidad e/B | @{n_e} | 0.333 | 0.167 | sí |
#| Deslizamiento | @{n_s} | 1.50 | 1.60 | sí |
#| Capacidad portante (R_{d} = 180 kPa) | @{n_b} | 1.00 | 3.0 | **no** |
#: **Reading.** By moments the wall does not reach 3.00, but the NEC accepts overturning by eccentricity ("whichever is more critical" is read as: the chosen criterion must be met with its limit) and e/B = 0.125 is within the middle third (1/6 = 0.167). **Note on judgment:** that reading of Table 5 is mine; the conservative one is to require both. The bearing capacity does fail: with 180 kPa as ultimate capacity, the NEC allowable pressure would be 180/3 = 60 kPa, and the base presses 106.5 kPa. The footing would have to be widened or an R_{d} from a soil study used.
#: **NEC 2023 draft (unofficial):** switches to load and resistance factors (overturning ΣM_{r}/ΣM_{a} from 1.50 to 1.35 depending on importance, active thrust ×1.50) and **calculates sliding without the front resistance**. Here that hardly changes anything: the front resistance is 1.22 kN/m out of 97 kN/m.
