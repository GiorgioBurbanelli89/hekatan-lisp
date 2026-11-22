# Nailed soil slope: check as a wall and bearing capacity, against GEO5 Nailed Slope
#numerico

#: **What is calculated.** The cut of the official GEO5 Nailed Slope example (**Demo01.ghr**): 7 m high, face inclined 2 m backward, six 5 m nails at 10° (one per meter of height, every 1 m in plan) and a 0.20 m layer of shotcrete. The "Verification" frame is reproduced (the nailed block as a **gravity wall**: overturning and sliding) and the "Bearing cap." frame (pressure under the block against 160 kPa → factor 1.13).
#: **How.** Coulomb (GEO5 help) on a **fictitious back** and the geometry of the .ghr file, which is binary and also stores GEO5's integer results: they are compared against those.
#: **Judge.** GEO5 2024: overturning 2601.99/17.41 = 149.48, sliding 502.25/17.42 = 28.83, pressure 142.21 kPa against 160 kPa → 1.13.
#: **Units.** kN, m and kPa per meter of wall; summary in tonf. Angles in radians inside the formulas.

## 1 · Data (Demo01.ghr)

#: **The face.** From (x = 0, z = 0) at the top to (x = −2, z = 7) at the bottom; z is the depth below the cut head.
H_c = 7 'height of the cut [m]
d_x = 2 'setback of the face from top to bottom [m]
#: **The nails.** Six, at z = 1, 2 … 6 m, 5 m long, inclined 10° downward:
L_n = 5 'nail length [m]
a_n = 10·pi/180 'nail inclination [rad]
z_n6 = 6 'depth of the head of the bottom nail [m]
#: **The soil.** Soil No. 1 down to 2.50 m and Soil No. 2 below (file data):
gamma_1 = 19.5 'unit weight of soil 1 [kN/m3]
gamma_2 = 21 'unit weight of soil 2 [kN/m3]
phi_2 = 30 'friction angle of soil 2 [degrees]
c_2 = 15 'cohesion of soil 2 [kPa]
z_12 = 2.5 'depth of the contact between soils [m]
R_d = 160 'given bearing capacity of the foundation soil [kPa]

#dibujo("Cut: face (black), nails (red) and fictitious back (blue) through the nail ends", ud = m, escala = auto, cotas = m, alto = 170)
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
#  texto(5.0, -2.35, "soil 1 / soil 2", 2.6, "i")
#  texto(3.6, -6.0, "fictitious back", 2.6, "i")
#  cota(-2, -7.4, 3.172, -7.4, -0.15, "B = 5.17")
#fin

## 2 · The fictitious back

#: As in MSE Wall (sheet 127), GEO5 closes the nailed block with a back **parallel to the face** that passes through the nail ends. All the nails have the same length, so their ends lie on that line. It is lowered from the end of the bottom nail to the base:
t_c = d_x/H_c 'slope of the face and of the back (2/7)
x_e = -t_c·z_n6 + L_n·cos(a_n) 'x of the end of the bottom nail [m]
z_e = z_n6 + L_n·sin(a_n) 'depth of the end of the bottom nail [m]
x_B = x_e - t_c·(H_c - z_e) 'x of the back at the base [m]
B_b = x_B + d_x 'width of the base of the nailed block (from the toe) [m]

## 3 · The pressure on the fictitious back

#: Soil against soil: δ = φ. The back leans toward the backfill, α = −atan(2/7). As in sheet 127, the cohesion term of the help agrees with +atan(2/7) (sign of α reversed in the K_{ahc} formula).
f_2 = phi_2·pi/180 'φ of soil 2 [rad]
a_b = -atan(t_c) 'inclination of the back [rad]
K_a = cos(f_2 - a_b)^2/(cos(a_b)^2·cos(a_b + f_2)·(1 + sqrt(sin(2·f_2)·sin(f_2)/(cos(a_b + f_2)·cos(a_b))))^2) 'active earth pressure coefficient (Coulomb)
K_h = K_a·cos(a_b + f_2) 'horizontal component
C_h = 2·c_2·cos(f_2)·cos(f_2 + a_b)/(1 + sin(2·f_2 + a_b)) 'horizontal cohesion term [kPa]
#: The vertical stress on the back is that of the soil column: σ_{z} = γ₁·2.50 + γ₂·(z − 2.50). The cohesion of soil 2 keeps the pressure at zero down to z_{0}:
s_12 = gamma_1·z_12 'σz at the contact [kPa]
z_0 = z_12 + (C_h/K_h - s_12)/gamma_2 'depth where the soil starts to push [m]
e_7 = (s_12 + gamma_2·(H_c - z_12))·K_h - C_h 'pressure at the base [kPa]
E_a = e_7·(H_c - z_0)/2 'horizontal force [kN/m]
V_a = E_a·tan(a_b + f_2) 'vertical component [kN/m]
h_a = (H_c - z_0)/3 'height of the resultant above the base [m]
x_a = B_b + t_c·h_a 'its arm from the toe [m]
#: **Above, in soil 1.** Above the end of the top nail (z = 1.87 m) the back continues **vertical** up to the ground (as in MSE Wall). There soil 1 (φ = 27°, c = 12 kPa, δ = φ, α = 0) pushes only in a very thin wedge, just above that point; lower down, in the inclined part of soil 1, the cohesion again cancels the pressure:
phi_1 = 27 'friction angle of soil 1 [degrees]
c_1 = 12 'cohesion of soil 1 [kPa]
f_1 = phi_1·pi/180 'φ of soil 1 [rad]
K_h1 = cos(f_1)^2/(cos(f_1)·(1 + sqrt(sin(2·f_1)·sin(f_1)/cos(f_1)))^2)·cos(f_1) 'K_a·cos δ, vertical part
C_h1 = 2·c_1·cos(f_1)·cos(f_1)/(1 + sin(2·f_1)) 'horizontal cohesion, vertical part [kPa]
z_e1 = 1 + L_n·sin(a_n) 'depth of the end of the top nail [m]
z_01 = C_h1/(gamma_1·K_h1) 'where soil 1 starts to push [m]
e_1 = gamma_1·z_e1·K_h1 - C_h1 'pressure at the foot of the vertical part [kPa]
E_1 = e_1·(z_e1 - z_01)/2 'the top wedge [kN/m]
V_1 = E_1·tan(f_1) 'its vertical component [kN/m]
h_1 = H_c - z_e1 + (z_e1 - z_01)/3 'its height above the base [m]
x_1 = -t_c + L_n·cos(a_n) + d_x 'its arm from the toe [m]
#: **The total pressure** on the fictitious back:
E_t = E_a + E_1 'total horizontal force [kN/m]
V_t = V_a + V_1 'total vertical force [kN/m]
h_t = (E_a·h_a + E_1·h_1)/E_t 'height of the resultant [m]

## 4 · Overturning, sliding and bearing capacity

#: **The weight of the nailed block** is taken from the file (731.18 kN/m, at 3.526 m from the toe). **It is not reproduced**: with the face, the back and the inclined ground of the example the area comes out larger (≈ 796 kN/m): it is not known which part of the ground above and of the concrete layer GEO5 counts. Pending.
W_n = 731.181367 'weight of the nailed block, GEO5 datum [kN/m]
x_W = 3.526047 'its arm from the toe, GEO5 datum [m]
M_res = W_n·x_W + V_a·x_a + V_1·x_1 'resisting moment [kN·m/m]
M_vol = E_a·h_a + E_1·h_1 'overturning moment [kN·m/m]
FS_v = M_res/M_vol 'safety factor against overturning
N_v = W_n + V_t 'vertical force at the base [kN/m]
R_s = N_v·tan(f_2) + c_2·B_b 'sliding resistance [kN/m]
FS_d = R_s/E_t 'safety factor against sliding
e_c = B_b/2 - (M_res - M_vol)/N_v 'eccentricity (positive toward the toe) [m]
#: The resultant falls **behind the center** (e < 0): as in MSE Wall, GEO5 does not trim the width (ECCENTRICITY 0.0 %) and the pressure is N/B:
sigma_b = N_v/B_b 'pressure under the nailed block [kPa]
FS_c = R_d/sigma_b 'capacity / pressure
U_c = sigma_b/R_d·100 'utilization [%]
#: **In tonf:**
s_ton = sigma_b/9.80665 'pressure under the block [tonf/m2]

## 5 · Internal stability (plane at 33°): how GEO5 builds the factor

#: The "Internal stability" frame looks for the most unfavorable failure plane from the toe: 33°. With the weight of the wedge and the nail force that GEO5 calculates (618.22 and 169.41 kN/m, file data), the factor is built like this:
W_w = 618.2179 'weight of the wedge, GEO5 datum [kN/m]
T_n = 169.411394 'force of the nails behind the plane, GEO5 datum [kN/m]
R_soil = 529.711002 'soil resistance on the plane, GEO5 datum [kN/m]
t_p = 33·pi/180 'plane angle [rad]
D_w = W_w·sin(t_p) 'component that pushes along the plane [kN/m]
N_w = W_w·cos(t_p) 'component normal to the plane [kN/m]
R_n = T_n·cos(t_p + a_n) 'contribution of the nails along the plane [kN/m]
FS_i = (R_soil + R_n)/D_w 'internal safety factor
#: Checked: D = W·sen 33° (336.71), N = W·cos 33° (518.48) and the nail contribution T·cos(33° + 10°) (123.90) are those stored by GEO5. **Not reproduced** (pending) is how the weight of the wedge and the nail force come out (with the pull-out resistance of 18.85 kN/m per meter behind the plane they come out 188.2, and with only nails 4-6, 169.47) nor the soil resistance 529.71.

## 6 · Hekatan against GEO5

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
#: ² With the weight of GEO5's nailed block (731.18 kN/m), which is not reproduced here. ³ With GEO5's wedge weight, nail force and soil resistance: it checks only how the factor is built.
#: What remains (≤ 0.01 %) is the sixth digit of K_{h} and of the cohesion term (GEO5: 0.184998 and 14.86619; here 0.184996 and 14.86603).

## 7 · What the NEC requires

#: **NEC-SE-GC 2015**, **Table 5** (p. 38): overturning ≥ 3.00, sliding ≥ 1.60 and general stability ≥ 1.50 for permanent works (1.05 with earthquake). The internal factor of 1.94 that GEO5 gives meets the 1.50 (GEO5 asks 1.20 in this example). The NEC gives no factor of its own for nails.
#: **Bearing capacity**, **Table 6** (p. 42): FS = 3.0. If the 160 kPa is the **ultimate** capacity, the factor 1.13 does not pass; what would be needed:
q_u3 = 3·sigma_b 'required ultimate capacity with FS = 3 [kPa]
#: If the 160 kPa is already **allowable**, it passes. The example datum does not say.
#: **Earthquake:** k_{h} = 0.6·Z·F_{a} (note to Table 4, p. 31), zone V and soil D:
k_h = 0.6·0.40·1.20 'NEC-15 horizontal seismic coefficient
#: The **2023 draft (unofficial)** asks 1.5 in excavation cuts for general stability.
