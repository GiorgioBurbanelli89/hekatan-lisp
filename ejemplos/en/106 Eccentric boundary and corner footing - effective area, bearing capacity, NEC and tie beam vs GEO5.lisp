# Eccentric boundary and corner footing: effective area and bearing capacity, against GEO5
#numerico

#: **What is computed.** The same 1.20 × 1.20 m footing of the official GEO5 Spread Footing example **Demo01.gpa** (sheet 104), changed to "eccentric spread footing": the column is no longer at the centre but next to the edge. Two cases: **boundary** (column 1 cm from one edge, a_{x} = 0.01, b_{x} = 0.79) and **corner** (1 cm from two edges, a_{x} = a_{y} = 0.01). The same as GEO5 is computed: eccentricities, effective area, R_{d}, σ, FS and sliding.
#: **How.** The formulas from the official GEO5 2024 help ("Stress in the Footing Bottom" with the N·p term of the offset column, "Effective Area", "Standard Analysis", "Horizontal Bearing Capacity of Foundation"), the same as sheet 104.
#: **Judge.** The GEO5 2024 report with "Partial results" of the two cases. Then, the check with **NEC-SE-GC 2015** and a section that explains **why a real boundary footing carries a tie beam** (explanation, not a GEO5 result).

## 1 · Data (those of sheet 104)

l_x = 1.2 'footing side in x [m]
l_y = 1.2 'footing side in y [m]
t_z = 0.4 'depth [m]
d_f = 1.2 'depth of the bottom from the grade [m]
gamma_1 = 17.5 'unit weight of soil 1 [kN/m3]
phi_1 = 31.5 'φ of soil 1, the one touching the footing [degrees]
c_1 = 5 'cohesion of soil 1 [kPa]
N_1 = 3000 'column axial load, Load No. 1 [kN]
M_x = -2 'moment about x [kN·m]
M_y = 70 'moment about y [kN·m]
H_x = 14 'horizontal in x [kN]
H_y = 5 'horizontal in y [kN]
G_z = 13.248 'footing weight (sheet 104) [kN]
Z_r = 20.48 'weight of the fill on top (sheet 104) [kN]
#: **The homogenised soil under the bottom.** As in sheet 104, φ_{d} and γ₂ are **data read from the GEO5 report** (the Prandtl homogenisation is not reproduced). GEO5 prints the same values in the three cases: its failure surface (2.28 m deep, 7.51 m long) does not change with the effective width.
phi_d = 40.21 'homogenised φ, from the GEO5 report [degrees]
c_d = 5 'homogenised cohesion [kPa]
gamma_2 = 18.95 'homogenised γ under the bottom, from the GEO5 report [kN/m3]
q_0 = gamma_1·d_f 'surcharge at the bottom level [kPa]
f_d = phi_d·pi/180 'φ_{d} in radians
f_1 = phi_1·pi/180 'φ of soil 1 in radians
#: What does not depend on where the column is (sheet 104):
V_d = N_1 + G_z + Z_r 'vertical at the bottom [kN]
N_q = tan(pi/4 + f_d/2)^2·exp(pi·tan(f_d)) 'surcharge factor
N_c = (N_q - 1)/tan(f_d) 'cohesion factor
N_γ = 1.5·(N_q - 1)·tan(f_d) 'self-weight factor (Brinch-Hansen)
H_r = sqrt(H_x^2 + H_y^2) 'resulting horizontal [kN]
i_f = (1 - H_r/V_d)^2 'inclination factor
S_pd = (1 - sin(f_1))·gamma_1·(d_f^2 - (d_f - t_z)^2)/2·l_y 'earth pressure at rest in front of the footing (sheet 104) [kN]

## 2 · Where the column sits

#: GEO5 asks for a_{x}, the distance from the edge to the face of the column; its report gives the distance to the **axis**: 0.01 + 0.40/2 = 0.21 m. Measured from the footing centre:
a_x = 0.01 'from the edge to the column face [m]
c_x = 0.4 'column side [m]
p_x = a_x + c_x/2 - l_x/2 'column axis from the footing centre, in x [m]
#: In the corner footing, the same in y:
p_y = a_x + c_x/2 - l_y/2 'column axis from the centre, in y (corner) [m]

## 3 · Boundary footing

#: Help "Stress in the Footing Bottom": the eccentricity of the offset axial load, N·p, is added to that of the moments. The column at −0.39 m and the load moment push toward the **same side**:
e_xL = (-M_y + H_x·t_z + N_1·p_x)/V_d 'eccentricity in x [m]
e_yL = (M_x + H_y·t_z)/V_d 'eccentricity in y [m]
er_xL = abs(e_xL)/l_x 'relative in x (GEO5: 0.339 > 0.333)
er_yL = abs(e_yL)/l_y 'relative in y
#: More than a third: the resultant is outside the middle third, **more than half of the footing lifts** if it is looked at with a linear pressure. GEO5 marks it in red ("Eccentricity of load is NOT SATISFACTORY") but still computes with the effective rectangle:
b_xL = l_x - 2·abs(e_xL) 'effective side in x [m]
b_yL = l_y - 2·abs(e_yL) 'effective side in y [m]
b_L = min(b_xL, b_yL) 'effective width (GEO5: 0.39) [m]
l_L = max(b_xL, b_yL) 'effective length [m]
A_L = b_xL·b_yL 'effective area [m2]
sigma_L = V_d/A_L 'pressure over the effective area [kPa]
#: The factors, with the effective sides (sheet 104, section 5):
s_cL = 1 + 0.2·b_L/l_L 'shape, cohesion
s_qL = 1 + b_L/l_L·sin(f_d) 'shape, surcharge
s_γL = 1 - 0.3·b_L/l_L 'shape, self-weight
d_cL = 1 + 0.1·sqrt(d_f/b_L) 'depth, cohesion
d_qL = 1 + 0.1·sqrt(d_f/b_L·sin(2·f_d)) 'depth, surcharge
R_dL = (c_d·N_c·s_cL·d_cL + q_0·N_q·s_qL·d_qL + b_L/2·gamma_2·N_γ·s_γL)·i_f 'bearing capacity [kPa]
FS_L = R_dL/sigma_L 'vertical safety factor
R_dhL = V_d·tan(f_1) + c_1·A_L + S_pd 'horizontal capacity [kN]
FS_hL = R_dhL/H_r 'safety factor against sliding

## 4 · Corner footing

e_xE = (-M_y + H_x·t_z + N_1·p_x)/V_d 'eccentricity in x [m]
e_yE = (M_x + H_y·t_z + N_1·p_y)/V_d 'eccentricity in y [m]
er_xE = abs(e_xE)/l_x 'relative in x (GEO5: 0.339)
er_yE = abs(e_yE)/l_y 'relative in y (GEO5: 0.321)
er_tE = sqrt(er_xE^2 + er_yE^2) 'total relative (GEO5: 0.467)
b_xE = l_x - 2·abs(e_xE) 'effective side in x [m]
b_yE = l_y - 2·abs(e_yE) 'effective side in y [m]
b_E = min(b_xE, b_yE) 'effective width (GEO5: 0.39) [m]
l_E = max(b_xE, b_yE) 'effective length (GEO5: 0.43) [m]
A_E = b_xE·b_yE 'effective area: 11 % of the footing [m2]
sigma_E = V_d/A_E 'pressure over the effective area [kPa]
s_cE = 1 + 0.2·b_E/l_E 'shape, cohesion
s_qE = 1 + b_E/l_E·sin(f_d) 'shape, surcharge
s_γE = 1 - 0.3·b_E/l_E 'shape, self-weight
d_cE = 1 + 0.1·sqrt(d_f/b_E) 'depth, cohesion
d_qE = 1 + 0.1·sqrt(d_f/b_E·sin(2·f_d)) 'depth, surcharge
R_dE = (c_d·N_c·s_cE·d_cE + q_0·N_q·s_qE·d_qE + b_E/2·gamma_2·N_γ·s_γE)·i_f 'bearing capacity [kPa]
FS_E = R_dE/sigma_E 'vertical safety factor
R_dhE = V_d·tan(f_1) + c_1·A_E + S_pd 'horizontal capacity [kN]
FS_hE = R_dhE/H_r 'safety factor against sliding
#: **Apparent paradox:** R_{d} of the corner footing (3302) is **greater** than that of the boundary one (2698). It is the shape: the effective area of the corner footing is almost square (0.39 × 0.43) and the factor s_{q} rises to 1.58; the boundary one is a 0.39 × 1.20 strip (s_{q} = 1.21). But the pressure is multiplied by 2.8 and the FS falls to 0.18.

#dibujo("Plan of the two footings: hatched effective area, column and resultant (red dot)", ud = m, escala = 1:20, cotas = m, alto = 120)
#  rect(-0.6, -0.6, 1.2, 1.2, "gruesa")
#  rect(-0.6, -0.6, b_xL, b_yL, "verde relleno")
#  achurado(-0.6, -0.6, b_xL, b_yL, "diagonal")
#  rect(-0.59, -0.2, 0.4, 0.4, "media")
#  circulo(e_xL, e_yL, 0.035, "rojo")
#  linea(-0.8, 0, 0.8, 0, "eje")
#  linea(0, -0.8, 0, 0.8, "eje")
#  texto(0, 0.9, "BOUNDARY", 3, "c")
#  cota(-0.6, -0.78, -0.6 + b_xL, -0.78, -0.1, "0.386")
#  rect(1.6, -0.6, 1.2, 1.2, "gruesa")
#  rect(1.6, -0.6, b_xE, b_yE, "verde relleno")
#  achurado(1.6, -0.6, b_xE, b_yE, "diagonal")
#  rect(1.61, -0.59, 0.4, 0.4, "media")
#  circulo(2.2 + e_xE, e_yE, 0.035, "rojo")
#  linea(1.4, 0, 3.0, 0, "eje")
#  linea(2.2, -0.8, 2.2, 0.8, "eje")
#  texto(2.2, 0.9, "CORNER", 3, "c")
#  cota(1.6, -0.78, 1.6 + b_xE, -0.78, -0.1, "0.386")
#  cota(3.0, -0.6, 3.0, -0.6 + b_yE, -0.1, "0.429")
#fin
#: The resultant (red dot) falls **inside the column**: the column is offset 0.39 m and the load moment shifts it 2 cm more. The effective area is the rectangle that has that point at its centre; the rest of the footing does not work.

#: **3D: the GEO5 contact pressure** (effective rectangle, uniform pressure), boundary on the left and corner on the right. Height: 1 m = 10 000 kPa. Rotate with the mouse and the cursor reads the pressure:
#hide
n_g = 25
n_p = n_g^2
X_n = zeros(2·n_p + 4, 3)
v_n = zeros(2·n_p + 4, 1)
e_s = zeros(2·(n_g - 1)^2, 4)
for c = 1:2
  for j = 1:n_g
    for k = 1:n_g
      p = (c - 1)·n_p + (j - 1)·n_g + k
      xx = -0.6 + 1.2·(k - 1)/(n_g - 1)
      yy = -0.6 + 1.2·(j - 1)/(n_g - 1)
      X_n(p, 1) = xx + 2.2·(c - 1)
      X_n(p, 2) = yy
      if c == 1
        if xx <= -0.6 + b_xL + 0.001
          v_n(p) = sigma_L
        end
      else
        if xx <= -0.6 + b_xE + 0.001
          if yy <= -0.6 + b_yE + 0.001
            v_n(p) = sigma_E
          end
        end
      end
      X_n(p, 3) = v_n(p)/10000
    end
  end
  for j = 1:n_g - 1
    for k = 1:n_g - 1
      q = (c - 1)·(n_g - 1)^2 + (j - 1)·(n_g - 1) + k
      a = (c - 1)·n_p + (j - 1)·n_g + k
      e_s(q, 1) = a
      e_s(q, 2) = a + 1
      e_s(q, 3) = a + n_g + 1
      e_s(q, 4) = a + n_g
    end
  end
end
X_n(2·n_p + 1, 1) = p_x
X_n(2·n_p + 2, 1) = p_x
X_n(2·n_p + 2, 3) = 2.2
X_n(2·n_p + 3, 1) = 2.2 + p_x
X_n(2·n_p + 3, 2) = p_y
X_n(2·n_p + 4, 1) = 2.2 + p_x
X_n(2·n_p + 4, 2) = p_y
X_n(2·n_p + 4, 3) = 2.2
e_f = [2·n_p + 1, 2·n_p + 2; 2·n_p + 3, 2·n_p + 4]
v_f = [0, 0; 0, 0]
#show
#modelo3d(X_n, e_s, e_f, v_n, v_f)
#: The vertical bars are the column axes. The boundary one loads 6546 kPa on a 39 cm strip; the corner one, 18 324 kPa on a small 0.39 × 0.43 m square. No soil withstands that: the FS says so (0.41 and 0.18).

## 5 · Hekatan against GEO5

#hide
g_exL = 0.339
g_bL = 0.386
g_sL = 6545.84
g_sqL = 1.208
g_dqL = 1.175
g_RdL = 2698.373
g_FSL = 0.41
g_RhL = 1865.40
g_FhL = 125.48
g_exE = 0.339
g_eyE = 0.321
g_etE = 0.467
g_bE = 0.386
g_sE = 18324.06
g_sqE = 1.582
g_scE = 1.180
g_RdE = 3302.208
g_FSE = 0.18
g_RhE = 1863.91
g_FhE = 125.38
h_exL = round(er_xL, 3)
h_bL = round(b_L, 3)
h_sL = round(sigma_L, 2)
h_sqL = round(s_qL, 3)
h_dqL = round(d_qL, 3)
h_RdL = round(R_dL, 3)
h_FSL = round(FS_L, 2)
h_RhL = round(R_dhL, 2)
h_FhL = round(FS_hL, 2)
h_exE = round(er_xE, 3)
h_eyE = round(er_yE, 3)
h_etE = round(er_tE, 3)
h_bE = round(b_E, 3)
h_sE = round(sigma_E, 2)
h_sqE = round(s_qE, 3)
h_scE = round(s_cE, 3)
h_RdE = round(R_dE, 3)
h_FSE = round(FS_E, 2)
h_RhE = round(R_dhE, 2)
h_FhE = round(FS_hE, 2)
x_exL = round(100·(h_exL/g_exL - 1), 3)
x_bL = round(100·(h_bL/g_bL - 1), 3)
x_sL = round(100·(h_sL/g_sL - 1), 4)
x_sqL = round(100·(h_sqL/g_sqL - 1), 3)
x_dqL = round(100·(h_dqL/g_dqL - 1), 3)
x_RdL = round(100·(h_RdL/g_RdL - 1), 4)
x_FSL = round(100·(h_FSL/g_FSL - 1), 2)
x_RhL = round(100·(h_RhL/g_RhL - 1), 4)
x_FhL = round(100·(h_FhL/g_FhL - 1), 3)
x_exE = round(100·(h_exE/g_exE - 1), 3)
x_eyE = round(100·(h_eyE/g_eyE - 1), 3)
x_etE = round(100·(h_etE/g_etE - 1), 3)
x_bE = round(100·(h_bE/g_bE - 1), 3)
x_sE = round(100·(h_sE/g_sE - 1), 4)
x_sqE = round(100·(h_sqE/g_sqE - 1), 3)
x_scE = round(100·(h_scE/g_scE - 1), 3)
x_RdE = round(100·(h_RdE/g_RdE - 1), 4)
x_FSE = round(100·(h_FSE/g_FSE - 1), 2)
x_RhE = round(100·(h_RhE/g_RhE - 1), 4)
x_FhE = round(100·(h_FhE/g_FhE - 1), 3)
#show
#| Magnitud | Hekatan | GEO5 2024 | Diferencia [%] |
#|---|---:|---:|---:|
#| **LINDERO** · excentricidad relativa e_{x} | @{h_exL} | @{g_exL} | @{x_exL} |
#| ancho efectivo [m] | @{h_bL} | @{g_bL} | @{x_bL} |
#| presión σ [kPa] | @{h_sL} | @{g_sL} | @{x_sL} |
#| s_{q} | @{h_sqL} | @{g_sqL} | @{x_sqL} |
#| d_{q} | @{h_dqL} | @{g_dqL} | @{x_dqL} |
#| **R_{d} [kPa]** | @{h_RdL} | @{g_RdL} | @{x_RdL} |
#| FS vertical | @{h_FSL} | @{g_FSL} | @{x_FSL} |
#| R_{dh} [kN] | @{h_RhL} | @{g_RhL} | @{x_RhL} |
#| FS horizontal | @{h_FhL} | @{g_FhL} | @{x_FhL} |
#| **ESQUINERA** · excentricidad relativa e_{x} | @{h_exE} | @{g_exE} | @{x_exE} |
#| excentricidad relativa e_{y} | @{h_eyE} | @{g_eyE} | @{x_eyE} |
#| excentricidad relativa total e_{t} | @{h_etE} | @{g_etE} | @{x_etE} |
#| ancho efectivo [m] | @{h_bE} | @{g_bE} | @{x_bE} |
#| presión σ [kPa] | @{h_sE} | @{g_sE} | @{x_sE} |
#| s_{q} | @{h_sqE} | @{g_sqE} | @{x_sqE} |
#| s_{c} | @{h_scE} | @{g_scE} | @{x_scE} |
#| **R_{d} [kPa]** | @{h_RdE} | @{g_RdE} | @{x_RdE} |
#| FS vertical | @{h_FSE} | @{g_FSE} | @{x_FSE} |
#| R_{dh} [kN] | @{h_RhE} | @{g_RhE} | @{x_RhE} |
#| FS horizontal | @{h_FhE} | @{g_FhE} | @{x_FhE} |
#: With the Hekatan value rounded to the decimals GEO5 prints. What shows up in R_{d} (0.01 kPa) is once again φ_{d} = 40.210 with three decimals.

## 6 · Check with NEC-SE-GC 2015

#: **What the code says** (only values from NEC-SE-GC 2015, the official one):
#: · **Table 6, §6.2 (p. 42)**: minimum safety factor for bearing capacity of shallow foundations, **3.0** with dead + normal live load, 2.5 with maximum live, 1.5 with pseudo-static earthquake.
#: · **Table 5, §5.2 (p. 36-38)**: eccentricity **e/B ≤ 1/6** in static (≤ 1/4 with earthquake). The table is for **walls**; using it for an isolated footing is **our criterion**: it is the middle-third limit, where the whole base remains in compression.
#: · GEO5 in this example uses FS = 1.50 and e ≤ 0.333 (Settings of Demo01), which **are not those of the NEC**.
#: **Also our criterion:** Load No. 1 of Demo01 is of type "Design"; here it is taken as is, as if it were the service combination DL + normal LL that Table 6 requires.
FS_nec = 3 'Table 6, DL + normal LL
e_nec = 1/6 'Table 5 (our criterion for the footing)
#hide
r_FSc = 1.65
r_ec = 0.195
r_FSL = round(FS_L, 2)
r_eL = round(er_xL, 3)
r_FSE = round(FS_E, 2)
r_eE = round(max(er_xE, er_yE), 3)
#show
#| Zapata | FS (GEO5 = Hekatan) | NEC: FS ≥ 3.0 | e/B máxima | NEC: e/B ≤ 0.167 | GEO5: e ≤ 0.333 |
#|---|---:|:---:|---:|:---:|:---:|
#| céntrica (hoja 104) | @{r_FSc} | no cumple | @{r_ec} (Load 2) | no cumple | cumple |
#| de lindero | @{r_FSL} | no cumple | @{r_eL} | no cumple | no cumple |
#| esquinera | @{r_FSE} | no cumple | @{r_eE} | no cumple | no cumple |
#: **All three fail the NEC.** Even the centred one, which GEO5 passes with its 1.50, stays at 1.65 against the 3.0 of Table 6, and Load No. 2 (M = −200 kN·m) takes it out of the middle third. With the NEC this 1.20 m footing is small for 3000 kN.

## 7 · Why a real boundary footing carries a tie beam (explanation, not a GEO5 result)

#: At the boundary the footing cannot be centred under the column: the neighbour's land is not touched. If it is left alone, what happens is as in section 3: the column is at e₀ = 0.39 m from the centre, and that arm turns the axial load into a **moment** that the footing cannot balance with the soil:
e_0 = abs(p_x) 'column arm with respect to the footing centre [m]
M_0 = N_1·e_0 'moment created by the offset column [kN·m]
#: The **tie beam** (or strap beam) joins this footing with that of the interior column. It works as a lever: the beam takes M₀ and the boundary footing receives a **centred** load. Assumption of this section (not from Demo01): the interior column is at **L_{v} = 5.00 m**. Moments about the axis of the interior column:
L_v = 5 'distance between column axes (assumption) [m]
R_1 = N_1·L_v/(L_v - e_0) 'soil reaction under the boundary footing, now centred [kN]
D_P = R_1 - N_1 'what the beam takes from the interior column [kN]
#: The boundary footing receives **more** than its column (R₁ > N₁), but centred; the interior one receives **less**. With the load centred the footing becomes again the centred one of sheet 104, without the 0.39 m arm (the moments and the horizontal of the load, which the footing takes, are kept):
V_v = R_1 + G_z + Z_r 'vertical at the bottom with beam [kN]
e_v = (-M_y + H_x·t_z)/V_v 'eccentricity that remains: only that of the load [m]
b_v = l_x - 2·abs(e_v) 'effective width with beam [m]
sigma_v = V_v/(b_v·l_y) 'pressure with beam [kPa]
R_dv = (c_d·N_c·(1 + 0.2·b_v/l_y)·(1 + 0.1·sqrt(d_f/b_v)) + q_0·N_q·(1 + b_v/l_y·sin(f_d))·(1 + 0.1·sqrt(d_f/b_v·sin(2·f_d))) + b_v/2·gamma_2·N_γ·(1 - 0.3·b_v/l_y))·(1 - H_r/V_v)^2 'capacity with beam [kPa]
FS_v = R_dv/sigma_v 'safety factor with beam
#hide
r_FSv = round(FS_v, 2)
r_R1 = round(R_1, 1)
r_M0 = round(M_0, 0)
#show
#: **Reading.** With the beam the FS goes from @{r_FSL} to @{r_FSv}: the footing works whole again and meets the 1.50 of GEO5. The beam is designed for a moment of the order of N·e₀ = @{r_M0} kN·m (maximum next to the boundary column) and the footing for R₁ = @{r_R1} kN. **With the NEC it is still not enough** (FS < 3.0): the footing must be enlarged as well as tied. The corner footing is the same problem in two directions: tie beam in x and in y.

#dibujo("Tie beam: the lever that centres the boundary footing (sketch, assumed L_v = 5 m)", ud = m, escala = auto, alto = 110)
#  rect(-0.6, -0.4, 1.2, 0.4, "gruesa")
#  achurado(-0.6, -0.4, 1.2, 0.4, "concreto")
#  rect(4.0, -0.4, 1.4, 0.4, "gruesa")
#  achurado(4.0, -0.4, 1.4, 0.4, "concreto")
#  rect(-0.59, 0, 0.4, 1.4, "media")
#  rect(4.5, 0, 0.4, 1.4, "media")
#  rect(-0.59, 0, 5.49, 0.5, "media azul relleno")
#  texto(2.2, 0.25, "tie beam (takes M = N·e₀)", 2.8, "c")
#  flecha(-0.39, 2.2, -0.39, 1.45, "rojo")
#  texto(-0.3, 2.0, "N₁ = 3000 kN", 2.6, "i")
#  flecha(0, -1.3, 0, -0.45, "verde")
#  texto(0.1, -1.1, "R₁ centred", 2.6, "i")
#  linea(-0.6, -1.6, -0.6, 2.4, "trazos rojo")
#  texto(-0.7, 2.25, "boundary (neighbour's land)", 2.6, "d")
#  cota(-0.39, 1.7, 4.7, 1.7, 0.15, "L_{v} = 5.00")
#  cota(-0.39, -0.6, 0, -0.6, -0.12, "e₀ = 0.39")
#fin

#: **In one line:** GEO5 computes well what it is given (effective area and Brinch-Hansen), but a footing with the column at the edge **is not fixed with the soil**, it is fixed with the structure: a tie beam that carries the moment N·e₀ to another footing.
