# Isolated pile: vertical capacity by NAVFAC DM 7.2, shaft and tip, versus GEO5
#numerico

#: **What is computed.** The pile of the official GEO5 Pile example (**Demo_manual_13.gpi**, engineering manual 14): concrete, 1.00 m in diameter and 12.00 m long, bored («Bored piles»), crossing a sandy clay (0 to 6 m) and a sand with fines (from 6 m downward). It checks the same thing as the «Vertical cap.» frame of GEO5: the **shaft resistance** R_{s}, the **tip resistance** R_{b} and their sum R_{c}, against the design load V_{d}.
#: **How.** With the formulas of the official GEO5 2024 help («NAVFAC DM 7.2»: Pile Shaft Resistance, Pile Base Resistance, Coefficient of Lateral Earth Pressure K, Friction Angle on Pile Skin, Critical Depth), read from the help file itself (GEO5_EN.fhl), not from memory. The soil data were read from the complete GEO5 report (Outputs → Print document, with «Partial results»).
#: **Judge.** The GEO5 2024 report of Demo_manual_13 and the screenshot of the same example with the «Safety factors (ASD)» setting. At the end, the **Hekatan versus GEO5** table with the difference in %.
#: **Units.** kN, m and kPa, like GEO5; at the end also in tonf (1 tonf = 9.80665 kN). Inside the formulas the angles are in radians.

## 1 · Example data (Demo_manual_13.gpi)

#: **The pile.**
d_p = 1.0 'pile diameter [m]
L_p = 12.0 'pile length, with the head at the ground surface [m]
A_b = pi·d_p^2/4 'tip area [m2]
u_p = pi·d_p 'shaft perimeter [m]
#: **Layer 1, from 0 to 6 m: sandy clay (CS) of firm consistency.** GEO5 treats it as **cohesive**: the shaft works by adhesion with the undrained cohesion c_{u} and the coefficient α, which in this example is **typed by hand** (input) as 0.60.
h_1 = 6.0 'thickness of layer 1 [m]
gamma_1 = 18.5 'unit weight of the clay [kN/m3]
c_u1 = 50 'undrained cohesion of the clay [kPa]
α_1 = 0.60 'adhesion coefficient α (example data)
#: **Layer 2, from 6 m downward: sand with fines (S-F), medium dense.** It is **non-cohesive**: the shaft works by friction, with K and δ computed by GEO5.
h_2 = 6.0 'pile segment inside the sand [m]
gamma_2 = 17.5 'unit weight of the sand [kN/m3]
phi_2 = 29.5 'internal friction angle of the sand [degrees]
#: No water table (the «GWT + subsoil» frame is turned off): effective stresses equal total stresses.
#: **What the «Vertical cap.» frame asks for:** the critical depth factor k_{dc} and the capacity factor N_{q} typed by hand.
k_dc = 1.00 'critical depth factor (GEO5 data)
N_q = 10.00 'tip capacity factor (GEO5 data, «input»)
#: **The load** (Load No. 1, design): vertical, moment and horizontal. For vertical capacity only the vertical one counts.
V_d = 1450 'design vertical force at the head [kN]
#: **The example setting:** EN 1997, design approach 2 (reduces actions and resistances). The load is already a design load; the resistances are divided by:
gamma_s = 1.10 'partial factor of the shaft
gamma_b = 1.10 'partial factor of the tip

#hide
f_2 = phi_2·pi/180
#show

## 2 · Effective stress and critical depth

#: **Critical depth** (GEO5 help, «Critical Depth»): in non-cohesive soil the shaft friction does not grow endlessly with depth; from d_{c} on it stays constant.
d_c = k_dc·d_p 'critical depth [m]
#: With k_{dc} = 1 the critical depth is **1 m**: the stress used for the sand shaft is the one at 1 m, still inside the clay. That is how GEO5 prints it (σ_{or} = 18.50 kPa in the sand).
s_c = gamma_1·d_c 'effective vertical stress at the critical depth [kPa]
#: **At the tip GEO5 does NOT apply that cap**: it uses the real stress at 12 m (both layers in full). This was checked with its R_{b}: it only matches with the full stress.
s_b = gamma_1·h_1 + gamma_2·h_2 'effective vertical stress at the tip [kPa]

## 3 · Shaft (R_s): layer by layer

#: **Layer 1, clay (cohesive).** GEO5 help: R_{s} = Σ α_{j}·c_{u,j}·A_{s,j}. GEO5 splits it into two segments (0-1 m and 1-6 m, because of the critical depth), but in clay that changes nothing:
q_s1 = α_1·c_u1 'unit adhesion in the clay [kPa]
R_s1a = q_s1·u_p·d_c 'shaft in the clay, from 0 to 1 m [kN]
R_s1b = q_s1·u_p·(h_1 - d_c) 'shaft in the clay, from 1 to 6 m [kN]
#: **Layer 2, sand (non-cohesive).** GEO5 help: R_{s} = Σ K_{j}·σ_{ef,j}·tan δ_{j}·A_{s,j}. GEO5 **computes** K as the average of the active, at-rest and passive pressures:
K_a = tan(pi/4 - f_2/2)^2 'active pressure
K_0 = 1 - sin(f_2) 'at-rest pressure
K_p = tan(pi/4 + f_2/2)^2 'passive pressure
K_2 = (K_a + K_p + K_0)/3 'lateral earth pressure coefficient on the shaft
#: and the pile-soil friction angle, for reinforced concrete, as 0.75·φ (help table, «Friction Angle on Pile Skin»):
δ_2 = 0.75·phi_2 'pile-sand friction [degrees]
q_s2 = K_2·s_c·tan(δ_2·pi/180) 'unit friction in the sand [kPa]
R_s2 = q_s2·u_p·h_2 'shaft in the sand, from 6 to 12 m [kN]
R_su = R_s1a + R_s1b + R_s2 'total shaft, unfactored [kN]
#hide
p_1 = round(100·(R_s1a + R_s1b)/R_su, 1)
p_2 = round(100·R_s2/R_su, 1)
r_q2 = round(q_s2, 2)
#show
#: **Reading.** The clay gives @{p_1} % of the shaft and the sand only @{p_2} %: with the critical depth of 1 m, the sand «sees» the stress at 1 m depth and its unit friction is only @{r_q2} kPa, less than a third of the 30 kPa of the clay.

#: **The GEO5 table, segment by segment** (the same three segments it prints in «partial results»):
z_de = [0, d_c, h_1] 'start of each segment [m]
z_a = [d_c, h_1, h_1 + h_2] 'end of each segment [m]
q_si = [q_s1, q_s1, q_s2] 'unit friction of each segment [kPa]
R_si = [R_s1a, R_s1b, R_s2] 'shaft of each segment, unfactored [kN]
R_sid = R_si/gamma_s 'shaft of each segment, design [kN]
#tabla("Segment","From [m]:2","To [m]:2","Soil","Unit friction [kPa]:2","R_si unfactored [kN]:2","R_si design [kN]:2")({"1","2","3"}; z_de; z_a; {"clay (α·cu)","clay (α·cu)","sand (K·σ·tanδ)"}; q_si; R_si; R_sid)

## 3b · Plot: how much shaft each meter of pile contributes

#: **How to read it.** x axis: depth z from the head [m]. y axis: shaft resistance accumulated down to that depth R_{s}(z) [kN], unfactored. The **points** are the Hekatan calculation (every 0.5 m) and the **isolated point** is the R_{su} of the table above. The curve has **two slopes**: in the first 6 m (clay) it grows with the constant adhesion α·c_{u} = 30 kPa; from there on (sand) the slope **drops** because the unit friction of the sand is only 9.50 kPa (the critical depth of 1 m keeps it from growing with the ground pressure). The **kink** at 6 m is the clay-sand contact of the drawing.
#hide
Rz = zeros(25, 2)
for j = 1:25
  zj = (j - 1)·0.5
  Rz(j, 1) = zj
  Rz(j, 2) = q_s1·u_p·min(zj, h_1) + q_s2·u_p·max(zj - h_1, 0)
end
#show
#fplot(Fuste = Rz, R_su = [12 R_su], [0 12])
#: This curve also tells **where it pays to embed**: the 6 m of clay give almost all of the shaft; the 6 m of sand barely add what is seen in the final slope. The **tip** (section 4) adds only once, at the end, and is the largest part of the total resistance.

## 4 · Tip (R_b)

#: The soil under the tip is the sand (non-cohesive). GEO5 help: R_{b} = σ_{efb}·N_{q}·A_{b}, with N_{q} = 10 typed by hand (the help table gives 10 for bored piles with φ = 30°).
q_b = s_b·N_q 'unit resistance of the tip [kPa]
R_bu = q_b·A_b 'tip, unfactored [kN]

## 5 · Total resistance and GEO5 check (EN 1997, DA2)

R_cu = R_su + R_bu 'total resistance unfactored [kN]
R_s = R_su/gamma_s 'design shaft [kN]
R_b = R_bu/gamma_b 'design tip [kN]
R_c = R_s + R_b 'design resistance of the pile [kN]
U_c = V_d/R_c 'utilization (GEO5 passes if < 1)
#hide
r_uc = round(100·U_c, 1)
#show
#: R_{c} > V_{d}: **GEO5 says SATISFACTORY**. The pile works at @{r_uc} % of its design resistance.

#dibujo("The pile, the soils and the unit friction along the shaft (blue diagram: 1 m = 10 kPa)", ud = m, escala = auto, alto = 120)
#  rect(-9, -6, 14.5, 6, "relleno azul tenue sinborde")
#  rect(-9, -13, 14.5, 7, "relleno naranja tenue sinborde")
#  linea(-9, -6, 5.5, -6, "trazos")
#  texto(-8.9, -0.7, "sandy clay CS: c_{u} = 50 kPa, α = 0.60", 3.2, "i")
#  texto(-8.9, -6.7, "sand S-F: φ = 29.5°", 3.2, "i")
#  linea(-9, 0, 5.5, 0, "media verde")
#  rect(-0.5, -12, 1, 12, "gruesa")
#  achurado(-0.5, -12, 1, 12, "concreto")
#  flecha(0, 2.2, 0, 0.1, "rojo")
#  texto(0.3, 1.4, "V_{d} = 1450 kN", 3.2, "i")
#  poligono([1.5, 1.5 + q_s1/10, 1.5 + q_s1/10, 1.5 + q_s2/10, 1.5 + q_s2/10, 1.5], [0, 0, -6, -6, -12, -12], "media azul relleno")
#  texto(1.6 + q_s1/10, -3, "α·c_{u} = 30 kPa", 3.2, "i")
#  texto(1.6 + q_s2/10, -9, "K·σ_{c}·tan δ = 9.50 kPa", 3.2, "i")
#  linea(-9, -1, 0.5, -1, "trazos rojo")
#  texto(-8.9, -1.6, "critical depth d_{c} = 1 m", 3.2, "i")
#  flecha(0, -14.2, 0, -12.1, "rojo")
#  texto(0.3, -13.6, "tip: σ_{b}·N_{q} = 216 × 10 = 2160 kPa", 3.2, "i")
#  cota(-1.5, -12, -1.5, 0, -0.3, "L = 12.00")
#fin

## 6 · NEC-SE-GC 2015 (official)

#: The NEC-15 (§8.2, p. 50) writes the same as GEO5: ultimate load = shaft + tip, Q_{ult} = Q_{s} + Q_{t}, and the allowable load is the ultimate one divided by the safety factor: Q_{adm} = Q_{ult}/FS. **Table 6** (p. 42) asks for **FS = 3.0** with dead + normal live load (2.5 with maximum live load, 1.5 with earthquake). Table 6 is written for the tip; using it for the whole pile is our own criterion, as GEO5 does with its single SF_{cp}.
#: With the «Safety factors (ASD)» setting GEO5 works **without partial factors**: the resistance is R_{cu} and the FS is R_{cu}/V. Checked today in GEO5 (screenshot «nec/02_asd_vertical_cap»): R_{c} = 2440.96 kN against 1450 kN.
FS_req = 3.0 'Table 6 safety factor, dead + normal live load
FS_nec = R_cu/V_d 'safety factor of the pile
Q_adm = R_cu/FS_req 'allowable load by the NEC-15 [kN]
t_f = 9.80665 'kN per tonf
Q_adm_t = Q_adm/t_f 'allowable load [tonf]
V_t = V_d/t_f 'example load [tonf]
#hide
r_fs = round(FS_nec, 2)
r_qa = round(Q_adm_t, 1)
r_vt = round(V_t, 1)
#show
#: FS = @{r_fs} < 3.0: **does not meet the NEC-15**. The allowable load is @{r_qa} tonf and the example uses @{r_vt} tonf. Note: the GEO5 load is a «design» load (already factored); the NEC asks to compare with the **service** load, which would be smaller. Even so, for 1450 kN of service load the pile would need R_{cu} ≥ 4350 kN.
#: The NEC-15 allows lowering the FS with **load tests** (Table 8, p. 46, ASTM D1143). **2023 draft (unofficial):** FS from 2.0 to 3.0 depending on control and testing, and LRFD with φ = 0.45 for the shaft and 0.40 for the tip in clay for bored piles (Table 6.6); GEO5 Pile has no LRFD.

## 7 · Hekatan versus GEO5

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
#: The differences are computed with the Hekatan value rounded to the decimals GEO5 prints. **Everything matches to four figures.**
#: **Two things the help does not say and that the GEO5 number forces:** (1) the critical depth d_{c} = k_{dc}·d only caps the **shaft** of the sand; the **tip** uses the full stress (the help says it uses the same d_{c}: with it R_{b} would come out as 145 kN, not 1696). (2) In the sand, K and δ are not soil data: GEO5 computes them, K = (K_{a} + K_{0} + K_{p})/3 and δ = 0.75·φ (the report leaves them blank in the soil table and prints them in the partial results table).
#: **What stays outside this sheet:** settlement (Poulos curve, with help charts that GEO5 carries digitized inside the program) and horizontal capacity (sheet 121).
