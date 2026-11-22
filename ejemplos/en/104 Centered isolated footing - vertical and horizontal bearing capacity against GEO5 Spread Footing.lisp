# Centered isolated footing: vertical and horizontal bearing capacity, against GEO5
#numerico

#: **What is calculated.** The footing of the official GEO5 Spread Footing example (**Demo01.gpa**): 1.20 × 1.20 m, 0.40 m depth, column of 0.40 × 0.40 m. The same things are checked as in GEO5's "Bearing cap." frame: the **vertical bearing capacity** (R_{d} against the pressure σ), the **eccentricity** and the **horizontal capacity** (sliding, R_{dh} against H).
#: **How.** With the formulas of the official GEO5 help (page "Standard Analysis", Brinch-Hansen theory; "Effective Area"; "Horizontal Bearing Capacity of Foundation"; "Stress in the Footing Bottom"). The formulas were read from the GEO5 2024 help file itself, not from memory.
#: **Judge.** The GEO5 2024 report with "Partial results" (Outputs → Print document). At the end, the table **Hekatan against GEO5** with the difference in %.
#: **Units.** kN, m and kPa. Inside the formulas the angles are in radians.

## 1 · Example data (Demo01.gpa)

#: **The ground.** Two strata: 1 reaches 3.00 m depth and below it is 2. The water appears at 4.00 m.
gamma_1 = 17.5 'unit weight of soil 1 (silt with gravel, MG) [kN/m3]
phi_1 = 31.5 'effective friction angle of soil 1 [degrees]
c_1 = 5 'effective cohesion of soil 1 [kPa]
gamma_s2 = 22 'unit weight of soil 2 [kN/m3]
phi_2 = 45 'friction angle of soil 2 [degrees]
#: **The footing.** The bottom is 2.00 m below the original ground and 1.20 m below the finished grade; GEO5 measures the depth d from the finished grade.
l_x = 1.2 'footing side in x (GEO5: length) [m]
l_y = 1.2 'footing side in y (GEO5: width) [m]
t_z = 0.4 'footing depth [m]
d_f = 1.2 'depth of the bottom from the finished grade [m]
c_x = 0.4 'column side in x [m]
c_y = 0.4 'column side in y [m]
gamma_c = 23 'unit weight of concrete [kN/m3]
gamma_r = 20 'unit weight of the fill over the footing (GEO5 datum) [kN/m3]
#: **The governing load** (Load No. 1, the one GEO5 chooses as most unfavorable): axial, two moments and two horizontals at the top of the footing.
N_1 = 3000 'column axial [kN]
M_x = -2 'moment about x [kN·m]
M_y = 70 'moment about y [kN·m]
H_x = 14 'horizontal in x [kN]
H_y = 5 'horizontal in y [kN]
#: **What GEO5 demands in this example** (Settings → Spread Footing): safety factors (ASD) 1.50 vertical and 1.50 horizontal, and relative eccentricity ≤ 0.333.
SF_v = 1.5 'required vertical safety factor
SF_h = 1.5 'required horizontal safety factor
e_adm = 0.333 'allowable relative eccentricity

#dibujo("Section of the Demo01 footing (dimensions in m)", ud = m, escala = auto, cotas = m, alto = 150)
#  linea(-3.2, 0, 3.2, 0, "media verde")
#  texto(-3.1, 0.12, "original ground", 2.6, "i")
#  linea(-3.2, -0.8, 3.2, -0.8, "media")
#  texto(-3.1, -0.68, "finished grade", 2.6, "i")
#  rect(-0.6, -2.0, 1.2, 0.4, "gruesa")
#  achurado(-0.6, -2.0, 1.2, 0.4, "concreto")
#  rect(-0.2, -1.6, 0.4, 1.9, "gruesa")
#  flecha(0, 0.9, 0, 0.32, "rojo")
#  texto(0.1, 0.75, "N = 3000 kN", 2.4, "i")
#  linea(-3.2, -3.0, 3.2, -3.0, "trazos")
#  texto(-3.1, -2.88, "soil 1: φ = 31.5°, c = 5 kPa, γ = 17.5", 2.6, "i")
#  texto(-3.1, -3.2, "soil 2: φ = 45°, c = 5 kPa, γ = 22", 2.6, "i")
#  linea(-3.2, -4.0, 3.2, -4.0, "trazos azul")
#  texto(-3.1, -3.88, "water table", 2.6, "i")
#  linea(-1.0, -4.28, 1.0, -4.28, "puntos rojo")
#  texto(1.1, -4.28, "bottom of the failure surface (GEO5: 2.28 m)", 2.6, "i")
#  cota(0.9, -2.0, 0.9, -0.8, -0.25, "d = 1.20")
#  cota(-0.6, -2.25, 0.6, -2.25, -0.15, "1.20")
#fin

## 2 · The load at the footing bottom

#: GEO5 adds to the axial the weight of the footing (G) and that of the fill above it (Z, without the column void):
G_z = l_x·l_y·t_z·gamma_c 'footing weight [kN]
Z_r = gamma_r·(d_f - t_z)·(l_x·l_y - c_x·c_y) 'weight of the fill over the footing [kN]
V_d = N_1 + G_z + Z_r 'vertical force at the bottom [kN]
#: **The eccentricities** (GEO5 help, "Stress in the Footing Bottom"): the moment at the bottom is that at the top plus the horizontal times the depth. With the column centered there is no N·p term.
e_x = (-M_y + H_x·t_z)/V_d 'eccentricity in x [m]
e_y = (M_x + H_y·t_z)/V_d 'eccentricity in y [m]
#: GEO5 compares it **relative to the side**, against 0.333:
er_x = abs(e_x)/l_x 'relative eccentricity in x
er_y = abs(e_y)/l_y 'relative eccentricity in y
er_t = sqrt(er_x^2 + er_y^2) 'total relative eccentricity
#: With −2 + 5·0.4 = 0 the eccentricity in y is **exactly zero**: the moment M_{x} is cancelled by the horizontal H_{y}.

## 3 · The effective area and the contact pressure

#: The resultant is displaced e_{x} from the center; GEO5 ("rectangle" form) counts only the rectangle that has it at its center: 2·|e| is lost on each side.
b_x = l_x - 2·abs(e_x) 'effective side in x [m]
b_y = l_y - 2·abs(e_y) 'effective side in y [m]
b_ef = min(b_x, b_y) 'effective width (the smaller) [m]
l_ef = max(b_x, b_y) 'effective length (the larger) [m]
A_ef = b_x·b_y 'effective area [m2]
sigma_c = V_d/A_ef 'uniform contact pressure over the effective area [kPa]

#dibujo("Plan: the hatched part is the effective area (GEO5 draws 1.16 × 1.20)", ud = m, escala = auto, cotas = m, alto = 120)
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
#: The red dot is the resultant: it is 2 cm from the center, toward −x. The 4 cm strip on the right does not count.

## 4 · The soil under the footing: the GEO5 parameters

#: Under the bottom there is 1.00 m of soil 1 and below it soil 2, much stronger. GEO5 (help "Homogenization of Layered Subsoil") converts them into **an equivalent soil** by averaging φ and c with the lengths of the Prandtl failure surface that falls in each stratum, and γ with the areas.
#: **This is NOT reproduced here.** The help gives the averages but the exact shape of the surface only in a figure. I tried the Prandtl wedge (45° + φ/2) and the Terzaghi one (φ), with b = 1.158 and 1.20: none gives the depth 2.28 m or the length 7.51 m that GEO5 prints. That is why φ_{d} and γ_{2} enter as **data read from the GEO5 report**, not calculated:
phi_d = 40.21 'homogenized φ under the bottom, from the GEO5 report [degrees]
c_d = 5 'homogenized cohesion (both soils have 5) [kPa]
gamma_2 = 18.95 'homogenized γ under the bottom, from the GEO5 report [kN/m3]
#: Above the bottom there is only soil 1, so the γ above is its own, without averaging:
q_0 = gamma_1·d_f 'surcharge at bottom level, q₀ = γ₁·d [kPa]
f_d = phi_d·pi/180 'the same angle in radians

## 5 · Vertical bearing capacity: Brinch-Hansen (GEO5 help, "Standard Analysis")

#: **Capacity factors.** GEO5 calls them N_{d}, N_{e} and N_{b}; here with the usual letters (N_{q}, N_{c}, N_{γ}). Note: the Brinch-Hansen self-weight factor is 1.5·(N_{q} − 1)·tan φ, not the 2·(N_{q} + 1)·tan φ of Vesic.
N_q = tan(pi/4 + f_d/2)^2·exp(pi·tan(f_d)) 'surcharge factor (Prandtl)
N_c = (N_q - 1)/tan(f_d) 'cohesion factor (Reissner)
N_γ = 1.5·(N_q - 1)·tan(f_d) 'self-weight factor (Brinch-Hansen)
#: **Shape factors**, with the EFFECTIVE sides:
s_c = 1 + 0.2·b_ef/l_ef 'shape, cohesion
s_q = 1 + b_ef/l_ef·sin(f_d) 'shape, surcharge
s_γ = 1 - 0.3·b_ef/l_ef 'shape, self-weight
#: **Depth factors**, with d measured from the finished grade and the effective width:
d_c = 1 + 0.1·sqrt(d_f/b_ef) 'depth, cohesion
d_q = 1 + 0.1·sqrt(d_f/b_ef·sin(2·f_d)) 'depth, surcharge
d_γ = 1 'depth, self-weight
#: **Load inclination**: δ is the angle of the resultant with the vertical. GEO5 draws it: "Delta = 0.28°".
H_r = sqrt(H_x^2 + H_y^2) 'resultant horizontal [kN]
t_δ = H_r/V_d 'tangent of the inclination
δ_g = atan(t_δ)·180/pi 'inclination in degrees
i_f = (1 - t_δ)^2 'inclination factor, the same for the three terms
#: Horizontal ground and horizontal bottom: the factors b and g equal 1.
#: **The capacity**, term by term:
R_c = c_d·N_c·s_c·d_c·i_f 'cohesion term [kPa]
R_q = q_0·N_q·s_q·d_q·i_f 'surcharge term [kPa]
R_γ = b_ef/2·gamma_2·N_γ·s_γ·d_γ·i_f 'self-weight term [kPa]
R_d = R_c + R_q + R_γ 'bearing capacity of the supporting soil [kPa]
FS_v = R_d/sigma_c 'vertical safety factor
#hide
p_c = round(100·R_c/R_d, 1)
p_q = round(100·R_q/R_d, 1)
p_g = round(100·R_γ/R_d, 1)
r_fsv = round(FS_v, 2)
r_dlt = round(δ_g, 2)
#show
#: **Reading.** The @{p_q} % of R_{d} comes from being buried 1.20 m (term q₀), the @{p_g} % from the weight of the soil under the footing and only the @{p_c} % from the cohesion. FS = @{r_fsv} > 1.50: **it passes by the GEO5 criterion**. The inclination δ = @{r_dlt}° barely subtracts 1 %.

#: **How the FS falls if the load shifts.** The same formula with e_{x} as a variable (from 0 to 0.40 m), leaving everything else equal: the effective width drops, the pressure rises and the capacity drops. The red line is the 1.50 that GEO5 requires:
#fplot(FS = (c_d·N_c·(1 + 0.2·(l_x - 2·x)/l_y)·(1 + 0.1·sqrt(d_f/(l_x - 2·x))) + q_0·N_q·(1 + (l_x - 2·x)/l_y·sin(f_d))·(1 + 0.1·sqrt(d_f/(l_x - 2·x)·sin(2·f_d))) + (l_x - 2·x)/2·gamma_2·N_γ·(1 - 0.3·(l_x - 2·x)/l_y))·i_f/(V_d/((l_x - 2·x)·l_y)), limite = 1.5, [0 0.4])
#: At e_{x} = 0.02 m (this example) the FS is 1.65; it crosses 1.50 around 0.06 m. With 0.40 m (the boundary footing of sheet 106) it ends at 0.43.

## 6 · Horizontal capacity (sliding)

#: GEO5 help, "Horizontal Bearing Capacity of Foundation": R_{dh} = V·tan ψ + a·A_{ef} + S_{pd}. The friction and adhesion are those of the soil **in contact** with the footing (soil 1), not those of the homogenized soil:
f_1 = phi_1·pi/180 'φ of soil 1 in radians
R_roz = V_d·tan(f_1) 'friction at the base [kN]
R_coh = c_1·A_ef 'adhesion over the effective area [kN]
#: **At-rest pressure** on the depth of the footing (GEO5: "Earth resistance: at rest"), K₀ = 1 − sen φ, on the 1.20 m face, from the top (d − t) to the bottom (d) of the footing:
K_0 = 1 - sin(f_1) 'at-rest earth pressure coefficient
S_pd = K_0·gamma_1·(d_f^2 - (d_f - t_z)^2)/2·l_y 'ground resistance in front of the footing [kN]
R_dh = R_roz + R_coh + S_pd 'horizontal capacity [kN]
FS_h = R_dh/H_r 'safety factor against sliding
#hide
r_fsh = round(FS_h, 2)
r_spd = round(S_pd, 2)
#show
#: FS = @{r_fsh}: the horizontal (15 kN) does nothing to a footing that presses 3034 kN against the soil. The at-rest pressure contributes @{r_spd} kN, the same as GEO5 (4.01).

## 7 · The second load (Load No. 2) and the maximum eccentricity

#: GEO5 checks all the design loads. Load No. 2 (N = 820 kN, M_{y} = −200 kN·m) is the one that gives the **largest eccentricity** of the list: 0.195 relative.
N_2 = 820 'axial of load 2 [kN]
M_y2 = -200 'moment of load 2 [kN·m]
V_2 = N_2 + G_z + Z_r 'vertical at the bottom, load 2 [kN]
e_x2 = -M_y2/V_2 'eccentricity, load 2 [m]
er_x2 = abs(e_x2)/l_x 'relative: the maximum of the list
b_x2 = l_x - 2·abs(e_x2) 'effective side, load 2 [m]
sigma_2 = V_2/(b_x2·l_y) 'pressure, load 2 [kPa]
s_c2 = 1 + 0.2·b_x2/l_y
s_q2 = 1 + b_x2/l_y·sin(f_d)
s_γ2 = 1 - 0.3·b_x2/l_y
d_c2 = 1 + 0.1·sqrt(d_f/b_x2)
d_q2 = 1 + 0.1·sqrt(d_f/b_x2·sin(2·f_d))
R_d2 = c_d·N_c·s_c2·d_c2 + q_0·N_q·s_q2·d_q2 + b_x2/2·gamma_2·N_γ·s_γ2 'capacity, load 2 (no horizontal: i = 1) [kPa]

## 8 · Hekatan against GEO5

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
#: The differences are calculated with the Hekatan value rounded to the same decimals that GEO5 prints. Everything agrees to four digits; the only thing that shows is R_{d} (0.016 kPa out of 3594): GEO5 prints φ_{d} = 40.210 with three decimals and here it enters that way.
#: **What is NOT a Hekatan calculation:** φ_{d} = 40.21° and γ_{2} = 18.95 kN/m³ (GEO5's Prandtl homogenization, see section 4). Closing it requires extracting the failure surface geometry from the SpreadFooting_5.dll binary.
