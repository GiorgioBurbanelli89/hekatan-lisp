# Rock slope with an undulated joint: the undulation angle and NEC, against GEO5
#numerico

#: **What is calculated.** Stage 2 of the official GEO5 Rock Stability example (**Demo01.gsk**). It is the same block as in sheet 114 (joint at 46°, tension crack, two 95 kN anchors), but now the joint **is not smooth: it is undulated**, with an undulation angle ν = 15°. GEO5 goes from FS = 1.83 to FS = 2.31.
#: **Why it changes.** A real joint is not a perfect plane: it has waves of 1 to 10 m. For the block to slide it has to **climb** over the waves, and that demands more force than sliding on a smooth plane.
#: **How.** The formulas of the GEO5 2024 help ("Undulated Slip Surface", with the reference to Miller, 1988) and those of the plane block ("Plane Slip Surface").
#: **Judge.** The "Analysis → In detail" panel of stage 2 of GEO5 2024. At the end, the table **Hekatan against GEO5**.
#: **Units.** kN, m and kPa per meter of slope; the weight also in tonf (1 tonf = 9.80665 kN).

## 1 · Data (those of sheet 114, plus the undulation)

#: The slope profile (vertices stored by GEO5), the rock, the plane, the crack and the anchors are the same as in stage 1:
z_2 = 5.5 'elevation of slope vertex 2 (x = 2) [m]
x_2 = 2 'abscissa of vertex 2 [m]
gamma_r = 15 'unit weight of the rock [kN/m3]
phi_r = 36 'friction angle on the joint [degrees]
c_r = 15 'cohesion on the joint [kPa]
x_p = 1 'point of the plane, x [m]
z_p = 2 'point of the plane, z [m]
alpha_g = 46 'mean inclination of the plane [degrees]
x_g = 9 'distance of the tension crack [m]
F_a = 190 'anchors: 2 × 95 kN every 1 m [kN/m]
beta_a = 10 'inclination of the anchors below the horizontal [degrees]
#: **What is new in stage 2** (frame "Sl. surface", Slip surface type = undulated):
nu_g = 15 'undulation angle ν [degrees]
SF_s = 1.5 'safety factor requested in the example
#: The angles in radians, for the formulas:
a_r = alpha_g·pi/180 'inclination of the plane α [rad]
b_r = beta_a·pi/180 'inclination of the anchors β [rad]
f_r = phi_r·pi/180 'friction φ [rad]
n_r = nu_g·pi/180 'undulation ν [rad]

## 2 · The block: the same as in stage 1

#: Outcrop of the plane on the first slope segment and length to the crack (sheet 114, section 2):
x_0 = (z_p - x_p·tan(a_r))/(z_2/x_2 - tan(a_r)) 'abscissa of the outcrop [m]
L_s = (x_g - x_0)/cos(a_r) 'length of the sliding surface [m]
#: The block area, with the same polygon as sheet 114 (outcrop, vertices 2, 3 and 4, mouth and bottom of the crack):
X_b = [x_0; 2; 1; 6; 9; 9] 'abscissas of the polygon [m]
Z_b = [z_2/x_2·x_0; 5.5; 7.23; 13.19; 13.72; z_p + (x_g - x_p)·tan(a_r)] 'elevations of the polygon [m]
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
W_z = gamma_r·A_b 'block weight [kN/m]
W_t = W_z/9.80665 'the same weight in tonf/m
#: The normal and the driving force do not depend on the undulation (the waves change the **resistance**, not the loads):
N_n = W_z·cos(a_r) + F_a·sin(a_r + b_r) 'normal on the mean plane [kN/m]
T_act = W_z·sin(a_r) - F_a·cos(a_r + b_r) 'force that pushes the block [kN/m]

## 3 · What the undulation does

#: **The undulation angle.** If the surface goes up and down around the mean plane (inclination α), with segments of inclinations α_{i}, the GEO5 help defines it as ν = α − min(α_{i}): how far the flattest segment departs from the mean plane. It is the angle the block has to "climb". Here GEO5 asks for it directly: ν = 15°.
#dibujo("The undulated joint: the block slides along the mean plane but has to climb each wave with the angle ν", ud = m, cotas = m, escala = auto, alto = 110)
#  linea(0, 0, 12, 0, "trazos gris")
#  polilinea([0, 1.5, 3, 4.5, 6, 7.5, 9, 10.5, 12], [0, 0.4, 0, 0.4, 0, 0.4, 0, 0.4, 0], "gruesa rojo")
#  rect(3.6, 0.42, 3.0, 1.4, "media")
#  achurado(3.6, 0.42, 3.0, 1.4, "diagonal")
#  flecha(6.6, 1.1, 8.4, 1.1, "negro")
#  texto(7.0, 1.35, "sliding", 2.4, "i")
#  flecha(4.6, -0.6, 4.6, 0.25, "azul")
#  texto(4.75, -0.55, "σ_{n}", 2.6, "i", estilo = "azul")
#  linea(6, 0, 7.5, 0, "fina")
#  texto(7.6, 0.05, "mean plane (α)", 2.4, "i", estilo = "gris")
#  texto(6.35, 0.17, "ν", 3.0, "c", estilo = "rojo")
#  cota(0, -1.0, 3, -1.0, -0.05, "wavelength 3.0 m")
#  cota(12.4, 0, 12.4, 0.4, 0.05, "0.4")
#  cota(3.6, 2.05, 6.6, 2.05, 0.05, "block 3.0 m")
#fin
#: **The increase in resistance** (GEO5 help, formula of the page "Undulated Slip Surface"): the undulation adds to the resisting shear stress
#: Δτ = σ_{n}·tan ν
#: where σ_{n} is the normal stress on the plane. Integrated along the whole surface (σ_{n}·L = N), the block resistance becomes
#: T_{res} = c·L + N·tan φ + N·tan ν
#: First each part separately:
s_n = N_n/L_s 'mean normal stress on the joint [kPa]
D_tau = s_n·tan(n_r) 'increase of the resisting stress due to the undulation [kPa]
T_c = c_r·L_s 'cohesion part [kN/m]
T_f = N_n·tan(f_r) 'friction part [kN/m]
T_n = N_n·tan(n_r) 'undulation part [kN/m]
#: and the sum:
T_res = T_c + T_f + T_n 'resisting force with the undulated joint [kN/m]
tau_r = T_res/L_s 'mean resisting shear stress [kPa]
FS = T_res/T_act 'safety factor
#hide
r_fs = round(FS, 2)
r_n = round(100·T_n/T_res, 1)
FS_1 = (T_c + T_f)/T_act
r_f1 = round(FS_1, 2)
FS_p = (T_c + N_n·tan(f_r + n_r))/T_act
r_fp = round(FS_p, 2)
#show
#: **Reading.** The undulation contributes @{r_n} % of the resistance: the FS rises from @{r_f1} (smooth joint, sheet 114) to **@{r_fs}**.
#: **Careful, it is not Patton's formula.** Patton (1966) adds the angles: tan(φ + i). GEO5 adds the tangents: tan φ + tan ν. With φ = 36° and ν = 15° it is not the same: Patton would give FS = @{r_fp}. This sheet uses the GEO5 one because it is the one that reproduces its result (table below).

#: **How much the undulation weighs.** The FS with ν as a variable, from 0° to 25° (x in degrees). The red line is 1.50:
#fplot(FS = (c_r·L_s + N_n·tan(f_r) + N_n·tan(x·pi/180))/T_act, limite = 1.5, [0 25])
#: With ν = 0 it is sheet 114 (1.83); with ν = 15°, 2.31. It grows almost in a straight line because tan ν ≈ ν for small angles.

## 4 · Hekatan against GEO5

#hide
g_W = 603.03
g_N = 576.42
g_tau = 62.20
g_Tr = 755.44
g_Ta = 327.54
g_FS = 2.31
h_W = round(W_z, 2)
h_N = round(N_n, 2)
h_tau = round(tau_r, 2)
h_Tr = round(T_res, 2)
h_Ta = round(T_act, 2)
h_FS = round(FS, 2)
h_FS4 = round(FS, 4)
x_W = round(100·(h_W/g_W - 1), 4)
x_N = round(100·(h_N/g_N - 1), 4)
x_tau = round(100·(h_tau/g_tau - 1), 4)
x_Tr = round(100·(h_Tr/g_Tr - 1), 4)
x_Ta = round(100·(h_Ta/g_Ta - 1), 4)
x_FS = round(100·(h_FS/g_FS - 1), 2)
#show
#| Magnitud | Hekatan | GEO5 2024 | Diferencia [%] |
#|---|---:|---:|---:|
#| peso del bloque W_{z} [kN/m] | @{h_W} | @{g_W} | @{x_W} |
#| normal N [kN/m] | @{h_N} | @{g_N} | @{x_N} |
#| tensión resistente τ [kPa] | @{h_tau} | @{g_tau} | @{x_tau} |
#| **T_{res} [kN/m]** | @{h_Tr} | @{g_Tr} | @{x_Tr} |
#| **T_{act} [kN/m]** | @{h_Ta} | @{g_Ta} | @{x_Ta} |
#| **FS** | @{h_FS} | @{g_FS} | @{x_FS} |
#: Differences with the Hekatan value rounded to the decimals GEO5 prints. Unrounded, FS = @{h_FS4}. The only quantity that changes with respect to stage 1 is T_{res} (600.98 → 755.44), and it changes exactly by N·tan 15°.

## 5 · Check with NEC-SE-GC 2015

#: Table 4 (p. 31) of NEC-SE-GC 2015: shear FS ≥ **1.50** static and ≥ **1.05** pseudostatic, with k_{h} = 0.6·Z·F_{a}; its note extends it to rock.
#: **Static:** FS = @{r_fs} ≥ 1.50 → **complies**, with margin.
#: **Pseudostatic (Hekatan calculation, not checked against GEO5).** Zone V (Z = 0.40), rock of profile B (F_{a} = 1.0). The force k_{h}·W, horizontal outward, removes normal and adds driving force; the undulation acts on the normal that remains:
Z_s = 0.4 'seismic zone factor (zone V)
F_as = 1.0 'soil amplification, profile B (rock)
k_h = 0.6·Z_s·F_as 'horizontal seismic coefficient (NEC-15)
N_s = N_n - k_h·W_z·sin(a_r) 'normal with earthquake [kN/m]
T_as = T_act + k_h·W_z·cos(a_r) 'driving force with earthquake [kN/m]
FS_s = (c_r·L_s + N_s·(tan(f_r) + tan(n_r)))/T_as 'pseudostatic safety factor
#hide
r_fss = round(FS_s, 2)
#show
#: With earthquake FS = @{r_fss} ≥ 1.05 → **complies** with NEC-15; also with the 1.15 of the NEC-SE-GC 2023 draft (**unofficial**; with F_{a} = 1 its k_{h} = 0.6·Z is the same).
#: **Engineering warning.** The undulation angle is measured in the rock mass (the discontinuity survey that NEC-SE-GC 2015 asks for, 3.4.3, p. 21-22). Here it contributes one fifth of the resistance: if on site the joint turns out smoother, the FS goes back to 1.83.
