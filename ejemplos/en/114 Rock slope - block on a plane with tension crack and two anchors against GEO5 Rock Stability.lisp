# Rock slope: block sliding on a plane, with tension crack and two anchors, against GEO5
#numerico

#: **What is calculated.** The official GEO5 Rock Stability example (**Demo01.gsk**, stage 1): a rock mass cut by a joint dipping outward at 46°. The block above it, separated at the back by a vertical tension crack, can **slide on the joint**. Two active anchors of 95 kN stitch it to the sound rock.
#: **How.** Equilibrium of a single rigid block (GEO5 help: "Plane Slip Surface", "Anchorage of Rock Slope", "Mohr-Coulomb", "Verification According to the Factor of Safety"). All forces are resolved in the direction **normal** to the plane and in the direction **of sliding**. The formulas were read from the GEO5 2024 help itself.
#: **Judge.** The "Analysis → In detail" box of GEO5 2024 with this file. At the end, the table **Hekatan against GEO5** with the difference in %.
#: **Units.** kN, m and kPa per meter of slope (as GEO5); the weight also in tonf (1 tonf = 9.80665 kN). Inside the formulas the angles are in radians.

## 1 · Example data (Demo01.gsk)

#: **The slope profile.** GEO5 gives it by segments (inclination and length), but it stores the vertices with two decimals; they are these (x toward the slope, z upward):
x_1 = 0 'toe of the slope [m]
z_1 = 0
x_2 = 2 'top of the first segment, at 70° [m]
z_2 = 5.5
x_3 = 1 'the overhang: the second segment returns outward, at 120° [m]
z_3 = 7.23
x_4 = 6 'top of the third segment, at 50° [m]
z_4 = 13.19
x_5 = 18 'crest, segment at 10° [m]
z_5 = 15.31
#: **The rock** (Mohr-Coulomb criterion on the joint):
gamma_r = 15 'unit weight of the rock (example datum) [kN/m3]
phi_r = 36 'friction angle on the joint [degrees]
c_r = 15 'cohesion on the joint [kPa]
#: **The slip surface** ("Sl. surface" frame): a point of the plane, its inclination and the vertical tension crack (inclination 0° from the vertical) at 9 m from the origin. The surface is **smooth**.
x_p = 1 'point of the plane, x [m]
z_p = 2 'point of the plane, z [m]
alpha_g = 46 'inclination of the plane [degrees]
x_g = 9 'distance of the tension crack [m]
#: **The anchors** ("Anchors" frame): two, active (prestressed), of 95 kN each, inclined 10° downward, spaced 1 m along the slope.
n_a = 2 'number of anchors
P_a = 95 'prestress force of each anchor [kN]
beta_a = 10 'anchor inclination below the horizontal [degrees]
s_a = 1 'spacing of the anchors along the slope [m]
#: **What GEO5 demands in the example** (Settings: safety factors, ASD): SF_{s} = 1.50.
SF_s = 1.5 'required safety factor

#: The three angles, in radians for the formulas:
a_r = alpha_g·pi/180 'plane inclination α [rad]
b_r = beta_a·pi/180 'anchor inclination β [rad]
f_r = phi_r·pi/180 'friction φ [rad]

## 2 · The block geometry

#: **Where the plane exits at the slope.** The plane passes through (x_{p}, z_{p}) with slope tan α: z = z_{p} + (x − x_{p})·tan α. The first segment of the slope is the line z = (z_{2}/x_{2})·x. Where they intersect, the plane exits into the air ("daylights"):
m_1 = z_2/x_2 'slope of the first segment of the slope
x_0 = (z_p - x_p·tan(a_r))/(m_1 - tan(a_r)) 'abscissa of the daylight point [m]
z_0 = m_1·x_0 'elevation of the daylight point [m]
#: **Where the plane meets the crack** (x = x_{g}) and where the crack reaches the ground (segment 4–5):
z_b = z_p + (x_g - x_p)·tan(a_r) 'bottom of the crack, on the plane [m]
z_t = z_4 + (x_g - x_4)·(z_5 - z_4)/(x_5 - x_4) 'mouth of the crack, at the ground [m]
h_g = z_t - z_b 'height of the crack [m]
#: **Length of the sliding surface**, from the daylight point to the crack:
L_s = (x_g - x_0)/cos(a_r) 'length of the plane [m]
#: **The block area.** It is the polygon daylight point → vertices 2, 3, 4 of the slope → crack mouth → crack bottom. With the Gauss area formula ("shoelace"): A = ½·Σ (x_{i}·z_{i+1} − x_{i+1}·z_{i}), going all the way around:
X_b = [x_0; x_2; x_3; x_4; x_g; x_g] 'abscissas of the polygon [m]
Z_b = [z_0; z_2; z_3; z_4; z_t; z_b] 'elevations of the polygon [m]
#hide
S_a = 0
for i = 1:6
  j = i + 1
  if i == 6
    j = 1
  end
  S_a = S_a + X_b(i)·Z_b(j) - X_b(j)·Z_b(i)
end
#show
A_b = abs(S_a)/2 'block area [m2]

#dibujo("Demo01.gsk: the block (hatched) on the 46° joint, the tension crack and the two anchors", ud = m, escala = auto, cotas = m, alto = 170)
#  polilinea([0, 2, 1, 6, 18], [0, 5.5, 7.23, 13.19, 15.31], "gruesa")
#  linea(-1, 0, 0, 0, "media")
#  achurado([x_0, 2, 1, 6, 9, 9], [z_0, 5.5, 7.23, 13.19, z_t, z_b], "diagonal")
#  poligono(x_0, z_0, 2, 5.5, 1, 7.23, 6, 13.19, 9, z_t, 9, z_b, "media rojo")
#  linea(x_0, z_0, 14, z_p + 13·tan(a_r), "trazos rojo")
#  linea(1.98, 5.53, 1.98 + 10·cos(b_r), 5.53 - 10·sin(b_r), "media azul")
#  linea(3.54, 10.26, 3.54 + 10·cos(b_r), 10.26 - 10·sin(b_r), "media azul")
#  flecha(0.2, 6.4, 1.98, 5.53, "azul")
#  texto(5.3, 3.4, "anchors 2 × 95 kN, 10°", 2.6, "i", estilo = "azul")
#  texto(9.3, 11.9, "tension crack", 2.6, "i")
#  texto(10.5, 8.6, "joint α = 46°", 2.6, "i", estilo = "rojo")
#  texto(4.6, 9.9, "W", 3.0, "c")
#  circulo(x_0, z_0, 0.12, "rojo relleno")
#  texto(x_0 + 0.25, z_0 - 0.4, "daylight point", 2.4, "i", estilo = "rojo")
#  cota(0, -0.6, 9, -0.6, -0.3, "x = 9.00")
#fin

## 3 · The forces on the block

#: **Weight.** The area times the unit weight, per meter of slope:
W_z = gamma_r·A_b 'block weight [kN/m]
W_t = W_z/9.80665 'the same weight in tonf/m
#: **Anchors.** Per meter of slope they are n·P/s. GEO5 gives their two components:
F_a = n_a·P_a/s_a 'total anchor force per meter [kN/m]
F_ax = F_a·cos(b_r) 'horizontal component (toward the rock) [kN/m]
F_az = F_a·sin(b_r) 'vertical component (downward) [kN/m]
#: **Projection on the plane.** The block goes down the joint in the direction (−cos α, −sen α); the normal that presses the plane is (sen α, −cos α).
#: — The weight, vertical, gives W·cos α of normal and W·sen α of push down the plane.
#: — The anchor makes with the plane the angle α + β (α above the horizontal, β downward). It presses the plane with F·sen(α + β) and **brakes** the block with F·cos(α + β). Since it is active (prestressed), GEO5 subtracts that part from the forces that push ("the tangent component … is subtracted from the shear (active) forces").
#: N = W·cos α + F·sen(α + β)
#: T_{act} = W·sen α − F·cos(α + β)
N_n = W_z·cos(a_r) + F_a·sin(a_r + b_r) 'normal force on the plane [kN/m]
T_act = W_z·sin(a_r) - F_a·cos(a_r + b_r) 'force that pushes the block [kN/m]
#: **Resistance** of Mohr-Coulomb along the whole plane (help: τ = c + (N/l)·tan φ):
#: T_{res} = c·L + N·tan φ
T_res = c_r·L_s + N_n·tan(f_r) 'resisting force [kN/m]
tau_r = T_res/L_s 'mean resisting shear stress [kPa]
#: **Safety factor** (help: SF = T_{res}/T_{act} > SF_{s}):
FS = T_res/T_act 'safety factor against sliding
#hide
r_fs = round(FS, 2)
r_c = round(100·c_r·L_s/T_res, 1)
W_0 = W_z·sin(a_r)
FS_0 = (c_r·L_s + W_z·cos(a_r)·tan(f_r))/W_0
r_f0 = round(FS_0, 2)
#show
#: **Reading.** FS = @{r_fs} > 1.50: **it passes**. Cohesion gives @{r_c} % of the resistance. Without the anchors the same block would have FS = @{r_f0}: the two 95 kN anchors are what take it above 1.50.

#: **How much anchor is needed.** The same calculation with the force per meter F as a variable (from 0 to 300 kN/m); the red line is the required 1.50:
#fplot(FS = (c_r·L_s + (W_z·cos(a_r) + x·sin(a_r + b_r))·tan(f_r))/(W_z·sin(a_r) - x·cos(a_r + b_r)), limite = 1.5, [0 300])
#: With F = 190 kN/m (this example) FS = 1.83; 1.50 is reached around 114 kN/m.

## 4 · Hekatan against GEO5

#hide
g_L = 12.15
g_al = 46.00
g_W = 603.03
g_Fx = 187.11
g_Fz = 32.99
g_N = 576.42
g_tau = 49.48
g_Tr = 600.98
g_Ta = 327.54
g_FS = 1.83
h_L = round(L_s, 2)
h_W = round(W_z, 2)
h_Fx = round(F_ax, 2)
h_Fz = round(F_az, 2)
h_N = round(N_n, 2)
h_tau = round(tau_r, 2)
h_Tr = round(T_res, 2)
h_Ta = round(T_act, 2)
h_FS = round(FS, 2)
h_FS4 = round(FS, 4)
x_L = round(100·(h_L/g_L - 1), 3)
x_W = round(100·(h_W/g_W - 1), 4)
x_Fx = round(100·(h_Fx/g_Fx - 1), 4)
x_Fz = round(100·(h_Fz/g_Fz - 1), 4)
x_N = round(100·(h_N/g_N - 1), 4)
x_tau = round(100·(h_tau/g_tau - 1), 4)
x_Tr = round(100·(h_Tr/g_Tr - 1), 4)
x_Ta = round(100·(h_Ta/g_Ta - 1), 4)
x_FS = round(100·(h_FS/g_FS - 1), 2)
#show
#| Magnitud | Hekatan | GEO5 2024 | Diferencia [%] |
#|---|---:|---:|---:|
#| largo del plano l [m] | @{h_L} | @{g_L} | @{x_L} |
#| peso del bloque W_{z} [kN/m] | @{h_W} | @{g_W} | @{x_W} |
#| anclajes F_{ax} [kN/m] | @{h_Fx} | @{g_Fx} | @{x_Fx} |
#| anclajes F_{az} [kN/m] | @{h_Fz} | @{g_Fz} | @{x_Fz} |
#| normal N [kN/m] | @{h_N} | @{g_N} | @{x_N} |
#| tensión resistente τ [kPa] | @{h_tau} | @{g_tau} | @{x_tau} |
#| **T_{res} [kN/m]** | @{h_Tr} | @{g_Tr} | @{x_Tr} |
#| **T_{act} [kN/m]** | @{h_Ta} | @{g_Ta} | @{x_Ta} |
#| **FS** | @{h_FS} | @{g_FS} | @{x_FS} |
#: Differences with the Hekatan value rounded to the decimals that GEO5 prints. Everything is equal. Unrounded, FS = @{h_FS4}.
#: **The only thing that had to be found out:** the profile. With the GEO5 table (70°, 120°, 50°, 10° and the lengths) the area comes out 40.18 m² and the weight 602.7 kN/m; with the two-decimal vertices that GEO5 draws and stores, 40.20 m² and **603.03**, its own. GEO5 works with the vertices.

## 5 · Check with NEC-SE-GC 2015

#: NEC-SE-GC 2015, Table 4 (p. 31), requires for slopes a shear FS of **1.50** in the static condition (design) and **1.05** pseudostatic; its note says it also applies to rock. GEO5 compares with the SF_{s} = 1.50 of its setting, which coincides with the NEC static one.
#: **Static:** FS = @{r_fs} ≥ 1.50 → **passes**.
#: **Pseudostatic (Hekatan calculation, not GEO5).** NEC-15 gives k_{h} = 0.6·Z·F_{a}. For example, zone V (Z = 0.40) and rock soil type B (F_{a} = 1.0): k_{h} = 0.24. GEO5 applies S = k_{h}·W horizontal, outward, at the center of gravity of the block (help "Influence of Seismic Effects"); projected on the plane it removes k_{h}·W·sen α from the normal and adds k_{h}·W·cos α to the push:
Z_s = 0.4 'seismic zone factor (zone V)
F_as = 1.0 'soil amplification, profile B (rock)
k_h = 0.6·Z_s·F_as 'horizontal seismic coefficient (NEC-15)
N_s = N_n - k_h·W_z·sin(a_r) 'normal with earthquake [kN/m]
T_as = T_act + k_h·W_z·cos(a_r) 'push with earthquake [kN/m]
FS_s = (c_r·L_s + N_s·tan(f_r))/T_as 'pseudostatic safety factor
#hide
r_fss = round(FS_s, 2)
k_23 = 0.6·Z_s
FS_23 = (c_r·L_s + (N_n - k_23·W_z·sin(a_r))·tan(f_r))/(T_act + k_23·W_z·cos(a_r))
r_f23 = round(FS_23, 2)
#show
#: With earthquake FS = @{r_fss} ≥ 1.05: **it passes** NEC-15. The NEC-SE-GC 2023 draft (**unofficial**, only as values) removes the F_{a} (k_{h} = 0.6·Z = 0.24, the same number here because F_{a} = 1) and raises the minimum to 1.15: FS = @{r_f23} ≥ 1.15, it also passes.
#: This last calculation was not checked against GEO5 (the example has no earthquake); the projection of the seismic force is the same as that of the weight, with the angle rotated 90°.
