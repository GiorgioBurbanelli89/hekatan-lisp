# Group of 20 piles in sand: effective stress method (β) and Seiler-Keeney efficiency, against GEO5
#numerico

#: **What is calculated.** The official GEO5 Pile Group example (**Demo01.gsp**, "Pile Group - Example 1"): a 15 × 15 m cap on **20 piles** (5 × 4) of concrete, 1.00 m in diameter and 12.00 m long, in silty sand and sand with fines, with the water at 7.00 m. It verifies the same as the GEO5 "Vertical cap." frame: the shaft and the tip of one pile, the resistance of one pile, the **group efficiency** and the group resistance against the load.
#: **How.** With the formulas of the official GEO5 2024 help ("Effective Stress Method", "Efficiency of a Pile Group", "Analysis According to the Theory of Limit States"), read from the help file.
#: **Judge.** The full GEO5 2024 report of Demo01.gsp and the capture of the same example with "Safety factors (ASD)", SF_{cp} = 3.
#: **Units.** kN, m and kPa, as GEO5; the allowable load also in tonf.

## 1 · Example data (Demo01.gsp)

#: **The cap and the piles.**
b_x = 15.0 'cap width in x [m]
b_y = 15.0 'cap width in y [m]
d_p = 1.0 'pile diameter [m]
n_x = 5 'piles in x
n_y = 4 'piles in y
s_x = 3.0 'axis spacing in x [m]
s_y = 4.0 'axis spacing in y [m]
h_z = 2.0 'depth of the cap bottom (pile head) [m]
L_p = 12.0 'pile length [m]
n_p = n_x·n_y 'number of piles
#: **The soil.** Silty sand (SM) from 0 to 5 m and sand with fines (S-F) below; water table at 7.00 m; water at 10 kN/m³. For the effective stress method each soil gives its coefficient β_{p} (Bjerrum-Burland) and the tip, N_{p} = 10.
h_1 = 5.0 'thickness of the silty sand [m]
gamma_1 = 18.0 'unit weight of the silty sand [kN/m3]
gamma_2 = 17.5 'unit weight of the sand with fines [kN/m3]
gamma_s2 = 19.5 'saturated weight of the sand with fines [kN/m3]
gamma_w = 10.0 'unit weight of water [kN/m3]
z_w = 7.0 'depth of the water table [m]
β_p = 0.45 'shaft coefficient of the two soils
N_p = 10 'tip coefficient (Fellenius)
#: **The example setting:** limit states (LSD), with total resistance reduction coefficient γ_{t} = 1.50 (γ_{s} = γ_{b} = 1.00).
gamma_t = 1.50 'total resistance reduction
V_d = 29551.99 'design vertical force with the cap weight, from the GEO5 report [kN]

## 2 · Effective stress along the pile

#: GEO5 counts the stress **from the bottom of the cap** (2.00 m): at the pile head σ' = 0 (the soil above was excavated for the cap). The help does not say this; the GEO5 number forces it: with the stress from the surface R_{b} would come out 1504 kN, not 1221.29.
z_p = h_z + L_p 'depth of the tip [m]
s_1 = gamma_1·(h_1 - h_z) 'σ' on passing to the sand with fines, at 5 m [kPa]
s_w = s_1 + gamma_2·(z_w - h_1) 'σ' at the water table, at 7 m [kPa]
s_b = s_w + (gamma_s2 - gamma_w)·(z_p - z_w) 'σ' at the tip, at 14 m [kPa]

## 3 · One pile: shaft and tip (Effective stress method)

#: GEO5 help: R_{s} = Σ β_{p,j}·σ_{0,j}·A_{s,j}, with σ_{0,j} the **mean** stress of each segment, and R_{b} = N_{p}·σ_{p}·A_{b}.
u_p = pi·d_p 'perimeter [m]
A_b = pi·d_p^2/4 'tip area [m2]
R_s1 = β_p·(s_1/2)·u_p·(h_1 - h_z) 'shaft in the silty sand, 2 to 5 m [kN]
R_s2 = β_p·((s_1 + s_w)/2)·u_p·(z_w - h_1) 'shaft in the sand, 5 to 7 m, above the water [kN]
R_s3 = β_p·((s_w + s_b)/2)·u_p·(z_p - z_w) 'shaft in the sand, 7 to 14 m, below the water [kN]
R_s = R_s1 + R_s2 + R_s3 'shaft of one pile [kN]
R_b = N_p·s_b·A_b 'tip of one pile [kN]
R_c1 = R_s + R_b 'resistance of one pile, unreduced [kN]
#hide
p_3 = round(100·R_s3/R_s, 1)
#show
#: The segment below the water gives @{p_3} % of the shaft: it is the longest (7 m) and the one with the most stress.

#: **The shaft, segment by segment:**
z_de = [h_z, h_1, z_w] 'start of the segment [m]
z_a = [h_1, z_w, z_p] 'end of the segment [m]
s_m = [s_1/2, (s_1 + s_w)/2, (s_w + s_b)/2] 'mean effective stress of the segment [kPa]
R_si = [R_s1, R_s2, R_s3] 'shaft of the segment [kN]
#tabla("Segment","From [m]:2","To [m]:2","σ'₀ mean [kPa]:2","R_si [kN]:2")({"silty sand","sand, above the water","sand, below the water"}; z_de; z_a; s_m; R_si)

## 4 · The group efficiency (Seiler-Keeney)

#: GEO5 help: η_{g} = [1 − 0.479·(s/(s² − 0.093))·((n_{x} + n_{y} − 2)/(n_{x} + n_{y} − 1))] + 0.3/(n_{x} + n_{y}), with s in meters. With different spacings in x and y, GEO5 uses **the average**: with 3.0 or 4.0 the result moves away (49029 and 50995 kN), with 3.5 it matches.
s_g = (s_x + s_y)/2 'spacing used by GEO5 [m]
η_g = (1 - 0.479·(s_g/(s_g^2 - 0.093))·((n_x + n_y - 2)/(n_x + n_y - 1))) + 0.3/(n_x + n_y) 'group efficiency
#: For comparison, the **Converse-Labarre** one (the one the 2023 draft names and GEO5 calls "La Barré"), with the same mean spacing; it is informative only (our criterion):
ψ_g = atan(d_p/s_g)·180/pi 'angle ψ [degrees]
η_LB = 1 - ψ_g·((n_x - 1)·n_y + (n_y - 1)·n_x)/(90·n_x·n_y) 'Converse-Labarre efficiency

## 5 · The group, as the example (limit states)

#: GEO5 help: R_{g} = n·(R_{c}/γ_{t})·η_{g} ≥ V_{d}.
R_c = R_c1/gamma_t 'reduced resistance of one pile [kN]
R_g = n_p·R_c·η_g 'group resistance [kN]
#hide
r_ug = round(100·V_d/R_g, 1)
#show
#: R_{g} > V_{d}: **GEO5 says SATISFACTORY** (the group works at @{r_ug} %).

#: **The group plan** (the 20 piles, axis positions):
x_p = [-6, -3, 0, 3, 6, -6, -3, 0, 3, 6, -6, -3, 0, 3, 6, -6, -3, 0, 3, 6] 'x of each pile [m]
y_p = [-6, -6, -6, -6, -6, -2, -2, -2, -2, -2, 2, 2, 2, 2, 2, 6, 6, 6, 6, 6] 'y of each pile [m]
#dibujo("Plan: 15 × 15 m cap and 20 piles of 1.00 m (spacing 3.0 m in x and 4.0 m in y)", ud = m, escala = auto, alto = 110)
#  rect(-7.5, -7.5, 15, 15, "gruesa")
#  circulo(x_p, y_p, 0.5, "media relleno")
#  linea(-9, 0, 9, 0, "eje")
#  linea(0, -9, 0, 9, "eje")
#  cota(-6, -8.3, -3, -8.3, -0.2, "3.00")
#  cota(8.3, -6, 8.3, -2, 0.2, "4.00")
#  cota(-7.5, 8.3, 7.5, 8.3, 0.2, "15.00")
#fin

#dibujo("Section: effective stress σ' along the pile (blue, 1 m = 25 kPa); counted from the bottom of the cap", ud = m, escala = auto, alto = 120)
#  rect(-6, -5, 14, 5, "relleno amarillo tenue sinborde")
#  rect(-6, -15, 14, 10, "relleno naranja tenue sinborde")
#  linea(-6, 0, 8, 0, "media verde")
#  linea(-6, -7, 8, -7, "trazos azul")
#  texto(-5.9, -6.8, "water table −7.00", 3.2, "i")
#  texto(-5.9, -4.6, "silty sand SM", 3.2, "i")
#  texto(-5.9, -5.6, "sand with fines S-F", 3.2, "i")
#  rect(-3, -2, 6, 1, "gruesa")
#  achurado(-3, -2, 6, 1, "concreto")
#  rect(-0.5, -14, 1, 12, "gruesa")
#  achurado(-0.5, -14, 1, 12, "concreto")
#  polilinea([1, 1 + s_1/25, 1 + s_w/25, 1 + s_b/25, 1], [-2, -5, -7, -14, -14], "media azul")
#  texto(1.2 + s_b/25, -14, "σ'_{b} = 155.5 kPa", 3.2, "i")
#  texto(1.2 + s_w/25, -7, "89 kPa", 3.2, "i")
#  cota(-1.5, -14, -1.5, -2, -0.3, "12.00")
#fin

## 6 · NEC-SE-GC 2015 (official)

#: NEC-15 (§8.2, p. 49) takes as the failure load of the group the **smaller** of: (a) the sum of the piles, (b) the block that encloses them, (c) the subgroups with their efficiency. GEO5 does (a) with the efficiency η_{g}; the block (b) is **not calculated** by this program and remains pending. The allowable load uses **FS = 3.0 of Table 6** (p. 42), with dead load + normal live load (our criterion for the whole pile). In GEO5: "Safety factors (ASD)", SF_{cp} = 3.0, **without γ_{t}** (checked today, capture "nec/02_asd_vertical_cap": R_{c} = 2747.75, R_{g} = 50155.72, V_{d} = 29551.99 kN, FS = 1.70 < 3.00).
FS_req = 3.0 'Table 6, dead load + normal live load
R_gu = n_p·R_c1·η_g 'group resistance unreduced (ASD) [kN]
FS_g = R_gu/V_d 'safety factor of the group
Q_adm = R_gu/FS_req 'allowable load of the group [kN]
Q_adm_t = Q_adm/9.80665 'allowable load of the group [tonf]
#hide
r_fs = round(FS_g, 2)
r_qa = round(Q_adm_t, 0)
#show
#: FS = @{r_fs} < 3.0: **does not comply with NEC-15**. The allowable load of the group is @{r_qa} tonf. Note: V_{d} is a **design** load; with the service load of the example (17500 kN + cap = 27051.99 kN) the FS would be 1.85, which is not enough either.
#: **2023 draft (unofficial):** efficiency between 0.65 and 1.00 (AASHTO), Converse-Labarre for granular soil, and LRFD; GEO5 Pile Group has no LRFD.

## 7 · Hekatan against GEO5

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
#: **Everything matches to four digits.** What the GEO5 number forces and the help does not say: the effective stress is counted from the bottom of the cap, and the Seiler-Keeney spacing is the average of s_{x} and s_{y}.
#: **What is NOT a Hekatan calculation:** V_{d} = 29551.99 kN (= 20000 kN + 9551.99 kN; the cap weighs 15·15·1·25 = 5625 kN and the remaining 3926.99 kN, which are 1250·π, were not identified: pending) and the group settlement (group factor 3.87, 10.1 mm with the service load, Poulos curve with charts that GEO5 carries digitized).
