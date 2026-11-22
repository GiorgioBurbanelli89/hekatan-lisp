# Geogrid-reinforced MSE wall: overturning, sliding and bearing capacity, against GEO5 MSE Wall
#numerico

#: **What is computed.** The wall of the official GEO5 MSE Wall example (**Demo01.gms**): 20 concrete blocks 0.20 m high and 0.50 m wide, each set back 0.05 m, with a 3.50 m Miragrid 5XT geogrid every two blocks, and a 35 kPa surcharge on top. The GEO5 **external verification** is reproduced: the block "soil + blocks + geogrids" works as a **fictitious gravity wall** ("Verification" and "Bearing cap." frames).
#: **How.** With the help of GEO5 ("Active Earth Pressure – The Coulomb Theory") and the geometry of the .gms file. The file is binary and stores, besides the data, **the complete results** (each force with its arm): the comparison is made against those, to 4 decimals.
#: **Judge.** GEO5 2024: overturning 22.01, sliding 8.26, stress under the blocks 109.47 kPa against 150 kPa (NOT SATISFACTORY, 1.37 < 1.50).
#: **Units.** kN, m and kPa per metre of wall (as GEO5); the summary also in tonf. Angles inside the formulas in radians.

## 1 · Data (Demo01.gms)

#: **The blocks.** The origin x = 0 is the toe of the bottom block; h is the height above the base of the blocks.
n_b = 20 'number of blocks
h_b = 0.20 'height of each block [m]
b_b = 0.50 'width of each block [m]
o_b = 0.05 'setback of each block relative to the one below [m]
gamma_b = 23 'unit weight of the block [kN/m3]
H_w = n_b·h_b 'wall height [m]
#: **The backfill** (Soil No. 1, the same behind and under the wall):
gamma_s = 19 'unit weight [kN/m3]
phi_s = 29 'friction angle [degrees]
c_s = 8 'cohesion [kPa]
q_s = 35 'permanent surcharge over the whole surface [kPa]
#: **The geogrids.** Eight, every 0.40 m from the base (h = 0, 0.4 … 2.8), 3.50 m long measured from the back of the block:
L_g = 3.5 'geogrid length [m]
h_top = 2.8 'height of the top geogrid [m]
#: **What the example demands:** factors of 1.50 for overturning, sliding and bearing capacity, and a given soil capacity of 150 kPa.
R_d = 150 'given bearing capacity of the foundation soil [kPa]

#dibujo("Wall section: blocks, geogrids (red), fictitious back (blue) and surcharge", ud = m, escala = auto, cotas = m, alto = 170)
#  rect(0.00, 0.00, 0.5, 0.2, "media")
#  rect(0.05, 0.20, 0.5, 0.2, "media")
#  rect(0.10, 0.40, 0.5, 0.2, "media")
#  rect(0.15, 0.60, 0.5, 0.2, "media")
#  rect(0.20, 0.80, 0.5, 0.2, "media")
#  rect(0.25, 1.00, 0.5, 0.2, "media")
#  rect(0.30, 1.20, 0.5, 0.2, "media")
#  rect(0.35, 1.40, 0.5, 0.2, "media")
#  rect(0.40, 1.60, 0.5, 0.2, "media")
#  rect(0.45, 1.80, 0.5, 0.2, "media")
#  rect(0.50, 2.00, 0.5, 0.2, "media")
#  rect(0.55, 2.20, 0.5, 0.2, "media")
#  rect(0.60, 2.40, 0.5, 0.2, "media")
#  rect(0.65, 2.60, 0.5, 0.2, "media")
#  rect(0.70, 2.80, 0.5, 0.2, "media")
#  rect(0.75, 3.00, 0.5, 0.2, "media")
#  rect(0.80, 3.20, 0.5, 0.2, "media")
#  rect(0.85, 3.40, 0.5, 0.2, "media")
#  rect(0.90, 3.60, 0.5, 0.2, "media")
#  rect(0.95, 3.80, 0.5, 0.2, "media")
#  linea(0.50, 0.00, 4.00, 0.00, "media rojo")
#  linea(0.60, 0.40, 4.10, 0.40, "media rojo")
#  linea(0.70, 0.80, 4.20, 0.80, "media rojo")
#  linea(0.80, 1.20, 4.30, 1.20, "media rojo")
#  linea(0.90, 1.60, 4.40, 1.60, "media rojo")
#  linea(1.00, 2.00, 4.50, 2.00, "media rojo")
#  linea(1.10, 2.40, 4.60, 2.40, "media rojo")
#  linea(1.20, 2.80, 4.70, 2.80, "media rojo")
#  linea(4.00, 0.00, 4.70, 2.80, "gruesa azul")
#  linea(4.70, 2.80, 4.70, 4.00, "gruesa azul")
#  linea(0.95, 4.0, 7.0, 4.0, "media verde")
#  linea(-0.8, 0.0, 7.0, 0.0, "fina")
#  flecha(2.0, 4.6, 2.0, 4.05, "rojo")
#  flecha(3.0, 4.6, 3.0, 4.05, "rojo")
#  flecha(4.0, 4.6, 4.0, 4.05, "rojo")
#  flecha(5.5, 4.6, 5.5, 4.05, "rojo")
#  texto(4.4, 4.75, "q = 35 kPa", 2.6, "i")
#  texto(4.85, 1.5, "fictitious back", 2.6, "i")
#  texto(2.0, -0.25, "base of the reinforced block B = 4.00", 2.6, "c")
#  cota(-0.5, 0, -0.5, 4.0, -0.2, "4.00")
#fin

## 2 · The fictitious wall

#: GEO5 closes the reinforced block with a **fictitious back** joining the ends of the geogrids: from the end of the bottom one (x = 0.50 + 3.50 = 4.00) it rises with the same batter as the blocks (0.05 every 0.20, that is 1:4) up to the top one, and from there it continues **vertically** to the surface.
x_0 = b_b + L_g 'end of the bottom geogrid = width B of the base [m]
t_b = o_b/h_b 'batter of the face and of the fictitious back (1:4)
x_t = x_0 + t_b·h_top 'end of the top geogrid [m]
#: **The weight of the reinforced soil** = area between the back of the blocks and the fictitious back, times γ. The area under the fictitious back, minus the area occupied by the blocks up to their back:
A_vb = x_0·h_top + t_b·h_top^2/2 + x_t·(H_w - h_top) 'area under the fictitious back [m2]
A_bb = n_b·h_b·b_b + h_b·o_b·n_b·(n_b - 1)/2 'area up to the back of the blocks [m2]
A_r = A_vb - A_bb 'area of the reinforced soil [m2]
W_r = gamma_s·A_r 'weight of the reinforced soil [kN/m]
#: Its arm: the first moment of the area about x = 0 (each strip contributes x²/2), divided by the area:
S_vb = x_0^2·h_top/2 + x_0·t_b·h_top^2/2 + t_b^2·h_top^3/6 + x_t^2/2·(H_w - h_top) 'static moment under the fictitious back [m3]
#hide
S_bb = 0
for i = 0:n_b - 1
  S_bb = S_bb + h_b·(b_b + o_b·i)^2/2
end
#show
S_bb 'block-by-block sum of h·(x_back)²/2 [m3]
x_r = (S_vb - S_bb)/A_r 'arm of the reinforced soil weight [m]
#: **The weight of the blocks** and its arm (each block centred at 0.25 + 0.05·i):
W_b = n_b·h_b·b_b·gamma_b 'weight of the blocks [kN/m]
x_b = b_b/2 + o_b·(n_b - 1)/2 'arm of the blocks weight [m]
#: **The surcharge over the reinforced block**: from the back of the top block to the fictitious back:
x_1 = b_b + o_b·(n_b - 1) 'back of the top block [m]
Q_r = q_s·(x_t - x_1) 'surcharge over the reinforced soil [kN/m]
x_q = (x_1 + x_t)/2 'its arm [m]

## 3 · The thrust on the fictitious back (Coulomb)

#: Behind the fictitious back there is **soil against soil**, so the friction on the back is that of the soil itself, δ = φ (Stage settings: "Reduction of soil/soil friction angle: do not reduce"). Formulas from the help (β = 0): K_{a} = cos²(φ − α) / (cos²α·cos(α + δ)·(1 + √(sin(φ + δ)·sin φ/(cos(α + δ)·cos α)))²) and K_{ahc} = cos φ·cos(δ − α)/(1 + sin(φ + δ − α)).
#: The lower segment leans toward the backfill: α = −atan(1/4) in the K_{a} convention. With the results stored in the .gms, the cohesion term K_{ahc} matches **+atan(1/4)**: in the help formula the sign of α goes the other way round (it was verified in this example and in the Nailed Slope one, sheet 128).
f_s = phi_s·pi/180 'φ [rad]
a_2 = -atan(t_b) 'inclination of the lower segment [rad]
K_a1 = cos(f_s)^2/(cos(f_s)·(1 + sqrt(sin(2·f_s)·sin(f_s)/cos(f_s)))^2) 'K_a of the vertical segment (α = 0, δ = φ)
K_a2 = cos(f_s - a_2)^2/(cos(a_2)^2·cos(a_2 + f_s)·(1 + sqrt(sin(2·f_s)·sin(f_s)/(cos(a_2 + f_s)·cos(a_2))))^2) 'K_a of the inclined segment
K_h1 = K_a1·cos(f_s) 'horizontal component, vertical segment
K_h2 = K_a2·cos(a_2 + f_s) 'horizontal component, inclined segment
C_h1 = 2·c_s·cos(f_s)·cos(f_s)/(1 + sin(2·f_s)) 'horizontal cohesion, vertical segment [kPa]
C_h2 = 2·c_s·cos(f_s)·cos(f_s + a_2)/(1 + sin(2·f_s + a_2)) 'horizontal cohesion, inclined segment [kPa]
#: **The soil alone** (σ_{z} = γ·z) does not push until σ_{z}·K_{h2} exceeds the cohesion: the vertical segment (z < 1.20 m) stays entirely in tension and the inclined one starts to push at z_{0}:
z_t = H_w - h_top 'depth where the back changes [m]
z_0 = C_h2/(gamma_s·K_h2) 'depth where the soil starts to push [m]
e_b = gamma_s·H_w·K_h2 - C_h2 'soil pressure at the base [kPa]
E_s = e_b·(H_w - z_0)/2 'soil thrust [kN/m]
h_s = (H_w - z_0)/3 'height of its resultant above the base [m]
x_s = x_0 + t_b·h_s 'its point on the fictitious back [m]
V_s = E_s·tan(a_2 + f_s) 'vertical component (inclined α + δ) [kN/m]
#: **The surcharge** is added to the soil; the part of the cohesion that the soil did not manage to overcome is discounted from the surcharge (tension cut of the total):
e_q0 = q_s·K_h1 - C_h1 'at the surface [kPa]
e_q1 = gamma_s·z_t·K_h1 + q_s·K_h1 - C_h1 'at the foot of the vertical segment [kPa]
e_q2 = gamma_s·z_t·K_h2 + q_s·K_h2 - C_h2 'at the start of the inclined segment [kPa]
e_q3 = q_s·K_h2 'from z_0 to the base (constant) [kPa]
E_q1 = (e_q0 + e_q1)/2·z_t 'vertical segment [kN/m]
E_q2 = (e_q2 + e_q3)/2·(z_0 - z_t) 'inclined segment, from z_t to z_0 [kN/m]
E_q3 = e_q3·(H_w - z_0) 'inclined segment, from z_0 to the base [kN/m]
E_q = E_q1 + E_q2 + E_q3 'surcharge thrust [kN/m]
#: Its height above the base (centre of each trapezoid):
y_1 = (H_w - z_t) + z_t·(e_q1 + 2·e_q0)/(3·(e_q0 + e_q1)) 'height of the centre of the vertical segment [m]
y_2 = (H_w - z_0) + (z_0 - z_t)·(e_q3 + 2·e_q2)/(3·(e_q2 + e_q3)) 'height of the centre of the z_t-z_0 segment [m]
y_3 = (H_w - z_0)/2 'height of the centre of the constant segment [m]
h_q = (E_q1·y_1 + E_q2·y_2 + E_q3·y_3)/E_q 'height of the surcharge resultant [m]
#: **The vertical component of the surcharge**: in the data GEO5 stores it is q·K_{a}·sin(α + δ) **constant over the whole back** (without the cohesion discount), and its arm is the centre of those vertical forces:
V_q1 = q_s·K_a1·sin(f_s)·z_t 'vertical, vertical segment [kN/m]
V_q2 = q_s·K_a2·sin(a_2 + f_s)·h_top 'vertical, inclined segment [kN/m]
V_q = V_q1 + V_q2 'vertical component of the surcharge [kN/m]
x_vq = (V_q1·x_t + V_q2·(x_0 + t_b·h_top/2))/V_q 'its arm [m]

## 4 · Overturning, sliding and bearing capacity

#: **Overturning** about the toe (x = 0): the weights and the vertical components resist; the horizontal ones overturn.
M_res = W_r·x_r + W_b·x_b + Q_r·x_q + V_s·x_s + V_q·x_vq 'resisting moment [kN·m/m]
M_vol = E_s·h_s + E_q·h_q 'overturning moment [kN·m/m]
FS_v = M_res/M_vol 'safety factor against overturning
#: **Sliding** at the base of the reinforced block (width B = x_{0}), with the φ and c of the foundation soil:
N_v = W_r + W_b + Q_r + V_s + V_q 'total vertical force [kN/m]
H_t = E_s + E_q 'total horizontal force [kN/m]
R_s = N_v·tan(f_s) + c_s·x_0 'sliding resistance [kN/m]
FS_d = R_s/H_t 'safety factor against sliding
#: **Eccentricity** with respect to the centre of the base:
e_c = x_0/2 - (M_res - M_vol)/N_v 'eccentricity (positive toward the toe) [m]
#hide
r_ec = round(e_c, 3)
#show
#: It gives e = @{r_ec} m: **negative**, the resultant falls behind the centre, toward the backfill. GEO5 shows "ECCENTRICITY: 0.0 %" and does not reduce the width: the pressure is the load divided by the full width (that is what it stores: 437.872577/4 = 109.468144 exact).
sigma_b = N_v/x_0 'pressure under the reinforced block [kPa]
FS_c = R_d/sigma_b 'bearing capacity factor
U_c = sigma_b/(R_d/1.5)·100 'utilisation with the example's 1.50 [%]
#: **In tonf** (1 tonf = 9.80665 kN):
N_ton = N_v/9.80665 'total vertical [tonf/m]
s_ton = sigma_b/9.80665 'pressure under the wall [tonf/m2]
#hide
r_fv = round(FS_v, 2)
r_fd = round(FS_d, 2)
r_fc = round(FS_c, 2)
r_uc = round(U_c, 1)
#show
#: **Reading.** The wall neither overturns (FS @{r_fv}) nor slides (FS @{r_fd}): the reinforced block weighs a lot and pushes little because the backfill has cohesion. What fails is the **foundation soil**: 150/σ = @{r_fc} < 1.50, utilisation @{r_uc} % → **NOT SATISFACTORY**, same as GEO5.

## 5 · Hekatan against GEO5

#hide
g_Wr = 264.48
g_xr = 2.71086
g_Wb = 46
g_xb = 0.725
g_Q = 113.75
g_Es = 7.461617
g_hs = 0.651795
g_Vs = 1.994276
g_Eq = 25.781831
g_hq = 1.857369
g_Vq = 11.648301
g_xq = 4.53833
g_Mr = 1161.265326
g_Mv = 52.749823
g_N = 437.872577
g_FSv = 22.01
g_FSd = 8.26
g_sig = 109.468144
g_FSc = 1.37
hk_1 = round(W_r, 4)
hk_2 = round(x_r, 4)
hk_3 = round(W_b, 4)
hk_4 = round(x_b, 4)
hk_5 = round(Q_r, 4)
hk_6 = round(E_s, 4)
hk_7 = round(h_s, 4)
hk_8 = round(V_s, 4)
hk_9 = round(E_q, 4)
hk_10 = round(h_q, 4)
hk_11 = round(V_q, 4)
hk_12 = round(x_vq, 4)
hk_13 = round(M_res, 4)
hk_14 = round(M_vol, 4)
hk_15 = round(N_v, 4)
hk_16 = round(FS_v, 2)
hk_17 = round(FS_d, 2)
hk_18 = round(sigma_b, 4)
hk_19 = round(FS_c, 2)
dk_1 = round(100·(hk_1/g_Wr - 1), 4)
dk_2 = round(100·(hk_2/g_xr - 1), 4)
dk_3 = round(100·(hk_3/g_Wb - 1), 4)
dk_4 = round(100·(hk_4/g_xb - 1), 4)
dk_5 = round(100·(hk_5/g_Q - 1), 4)
dk_6 = round(100·(hk_6/g_Es - 1), 4)
dk_7 = round(100·(hk_7/g_hs - 1), 4)
dk_8 = round(100·(hk_8/g_Vs - 1), 4)
dk_9 = round(100·(hk_9/g_Eq - 1), 4)
dk_10 = round(100·(hk_10/g_hq - 1), 4)
dk_11 = round(100·(hk_11/g_Vq - 1), 4)
dk_12 = round(100·(hk_12/g_xq - 1), 4)
dk_13 = round(100·(hk_13/g_Mr - 1), 4)
dk_14 = round(100·(hk_14/g_Mv - 1), 4)
dk_15 = round(100·(hk_15/g_N - 1), 4)
dk_16 = round(100·(hk_16/g_FSv - 1), 4)
dk_17 = round(100·(hk_17/g_FSd - 1), 4)
dk_18 = round(100·(hk_18/g_sig - 1), 4)
dk_19 = round(100·(hk_19/g_FSc - 1), 4)
#show
#| Magnitud | Hekatan | GEO5 2024 (.gms) | Diferencia [%] |
#|---|---:|---:|---:|
#| peso del suelo reforzado [kN/m] | @{hk_1} | @{g_Wr} | @{dk_1} |
#| su brazo [m] | @{hk_2} | @{g_xr} | @{dk_2} |
#| peso de los bloques [kN/m] | @{hk_3} | @{g_Wb} | @{dk_3} |
#| su brazo [m] | @{hk_4} | @{g_xb} | @{dk_4} |
#| sobrecarga sobre el bloque [kN/m] | @{hk_5} | @{g_Q} | @{dk_5} |
#| empuje de la tierra, horizontal [kN/m] | @{hk_6} | @{g_Es} | @{dk_6} |
#| su altura sobre la base [m] | @{hk_7} | @{g_hs} | @{dk_7} |
#| empuje de la tierra, vertical [kN/m] | @{hk_8} | @{g_Vs} | @{dk_8} |
#| empuje de la sobrecarga, horizontal [kN/m] | @{hk_9} | @{g_Eq} | @{dk_9} |
#| su altura sobre la base [m] | @{hk_10} | @{g_hq} | @{dk_10} |
#| empuje de la sobrecarga, vertical [kN/m] | @{hk_11} | @{g_Vq} | @{dk_11} |
#| su brazo [m] | @{hk_12} | @{g_xq} | @{dk_12} |
#| momento resistente [kN·m/m] | @{hk_13} | @{g_Mr} | @{dk_13} |
#| momento volcador [kN·m/m] | @{hk_14} | @{g_Mv} | @{dk_14} |
#| vertical total [kN/m] | @{hk_15} | @{g_N} | @{dk_15} |
#| **FS vuelco** | @{hk_16} | @{g_FSv} | @{dk_16} |
#| **FS deslizamiento** | @{hk_17} | @{g_FSd} | @{dk_17} |
#| **presión bajo el muro** [kPa] | @{hk_18} | @{g_sig} | @{dk_18} |
#| **capacidad / presión** | @{hk_19} | @{g_FSc} | @{dk_19} |
#: **What the help does not say and came out of the results stored in the .gms** (checked number by number, no factors): the fictitious back broken at the ends of the geogrids; δ = φ on it; the sign of α in K_{ahc}; the vertical component of the surcharge without cohesion discount; and that with the resultant behind the centre GEO5 does not reduce the width.
#: **Not reproduced (pending):** the verification of the joints between blocks (overturning 3.38 and sliding 2.80), the internal stability of each geogrid (rupture 19.00/5.70 = 3.33, pullout 41.46/2.95 = 14.04, which use the AASHTO k_{r}/k_{a} coefficient) and the global stability by Bishop (FS 1.59, radius 7.24 m), which is another program (Slope Stability).

## 6 · What the NEC requires

#: **NEC-SE-GC 2015** (official), §5.2 and **Table 5** (p. 38), static: sliding ≥ 1.60, overturning M_{R}/M_{A} ≥ 3.00 (or e/B ≤ 1/6), general stability ≥ 1.50 for permanent works. With earthquake: 1.05, 2.00, e/B ≤ 1/4 and 1.05.
#: Here: overturning @{r_fv} ≥ 3.00 ✔, sliding @{r_fd} ≥ 1.60 ✔, e/B = 0 (resultant toward the backfill) ✔, general stability 1.59 (from GEO5) ≥ 1.50 ✔.
#: **Bearing capacity**, **Table 6** (p. 42): FS = 3.0 with static load. If the 150 kPa of the example is the **ultimate** capacity, what is needed is:
q_u3 = 3·sigma_b 'ultimate capacity needed with FS = 3 [kPa]
#: With 150 kPa it meets neither the example's 1.50 nor the NEC's 3.0: the foundation soil must be improved or the base widened (longer geogrids).
#: **Earthquake:** k_{h} = 0.6·Z·F_{a} (note to Table 4, p. 31). Zone V with soil D:
k_h = 0.6·0.40·1.20 'NEC-15 horizontal seismic coefficient, zone V, soil D
#: The **2023 draft (unofficial)** uses for walls k_{h} = Z·F_{top}·F_{d} (for example 0.40·1.0·0.5 = 0.20) and, for geosynthetics, a resistance factor of 0.80. The GEO5 example has no earthquake.
