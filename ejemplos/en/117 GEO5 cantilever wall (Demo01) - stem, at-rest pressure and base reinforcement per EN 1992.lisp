# GEO5 wall stem: at-rest pressure, moment at the base and reinforcement (EN 1992)
#numerico

#: **What is calculated.** The "Dimensioning" frame of GEO5 Cantilever Wall with the official example **Demo01.guz** (the same wall as sheet 116): the **stem base section**, 5.00 m from the crest. First the forces on the stem and the moment and shear at that joint; then the check of the reinforced concrete section that GEO5 prints (reinforcement ratio, neutral axis, M_{Rd}, V_{Rd} and required reinforcement).
#: **Why at rest.** In Stage settings the example says "Pressure acting on the stem: pressure at rest". The stem is fixed to the footing and hardly moves: the soil does not reach the active state. That is why the stem is designed with K₀ = 1 − sin φ, larger than the K_{a} of sheet 116.
#: **Judge.** The "In detail" window of GEO5 2024 Dimensioning (Wall stem check - back reinf.) and its table of forces.
#: **Units.** kN, m, kPa and MPa per meter of wall; reinforcement in mm². Angles in degrees in the data and in radians inside the formulas.

## 1 · Data

#: **The stem** (Geometry frame): 0.20 m at the crest, vertical back face, front face inclined 1:12.5, height 5.00 m.
t_f = 0.2 'stem thickness at the crest [m]
n_f = 12.5 'inclination of the front face: 1 horizontal per 12.5 vertical
H_j = 5 'depth of the construction joint below the crest [m]
gamma_c = 23 'unit weight of concrete [kN/m3]
#: **The strata behind the stem** (Profile and Soils frames), with their thickness from the crest:
t_1 = 2.3 'thickness of soil 1 [m]
t_2 = 1.7 'thickness of soil 2 [m]
g_1 = 19 'unit weight of soil 1 [kN/m3]
g_2 = 17.5 'unit weight of soil 2 [kN/m3]
g_3 = 19.5 'unit weight of soil 3 [kN/m3]
p_1 = 29 'friction angle of soil 1 [degrees]
p_2 = 31.5 'friction angle of soil 2 [degrees]
p_3 = 27 'friction angle of soil 3 [degrees]
#: **The crest force** (Force No. 1): 30 kN/m horizontal, at 0.20 m above the crest.
F_1 = 30 'horizontal force [kN/m]
a_F = 0.2 'height of the force above the crest [m]
#: **The materials** (Material frame): concrete C 20/25 and steel B500B. The back reinforcement: 14 bars Ø 20 mm per meter, cover 30 mm.
f_ck = 20 'characteristic strength of concrete [MPa]
f_yk = 500 'yield strength of steel [MPa]
f_ctm = 2.2 'mean tensile strength of concrete (Material frame) [MPa]
g_cc = 1.5 'partial factor of concrete γc (EN 1992)
g_ss = 1.15 'partial factor of steel γs (EN 1992)
n_b = 14 'number of bars per meter
d_b = 20 'bar diameter [mm]
r_c = 30 'cover [mm]
b_w = 1 'design width [m]

## 2 · The base section

#: The thickness grows from 0.20 m at the top to 0.20 + H_{j}/12.5 at the joint:
h_s = t_f + H_j/n_f 'section depth at the joint [m]
#: **Stem weight** over the joint: a 0.20 m rectangle plus a triangle (the front wedge):
A_r = t_f·H_j 'rectangle [m2]
A_t = (h_s - t_f)·H_j/2 'triangle [m2]
W_f = gamma_c·(A_r + A_t) 'stem weight over the joint [kN/m]
#: Its centroid, measured from the back face (the rectangle at t_{f}/2, the triangle at t_{f} + one third of its base), and the distance to the **section center**, which is the eccentricity of the weight:
x_W = (A_r·t_f/2 + A_t·(t_f + (h_s - t_f)/3))/(A_r + A_t) 'centroid of the weight from the back face [m]
e_W = h_s/2 - x_W 'eccentricity of the weight with respect to the section center, backward [m]
y_W = (A_r·H_j/2 + A_t·H_j/3)/(A_r + A_t) 'height of the centroid above the joint [m]

## 3 · At-rest pressure on the stem

#: K₀ = 1 − sin φ in each stratum (GEO5 help, "Pressure at Rest", non-cohesive soil), σ₀ = K₀·σ_{z}; at rest the cohesion does not subtract. Soil 3 reaches the joint:
r_g = pi/180 'degrees to radians
K_01 = 1 - sin(p_1·r_g) 'K₀ of soil 1
K_02 = 1 - sin(p_2·r_g) 'K₀ of soil 2
K_03 = 1 - sin(p_3·r_g) 'K₀ of soil 3
t_3 = H_j - t_1 - t_2 'thickness of soil 3 over the joint [m]
s_v1 = g_1·t_1 'vertical pressure at the base of soil 1 [kPa]
s_v2 = s_v1 + g_2·t_2 'vertical pressure at the base of soil 2 [kPa]
#: In each stratum the pressure is a trapezoid = rectangle (what the soil above weighs) + triangle (its own weight). Resultant of each and its arm **above the joint**:
P_1 = K_01·g_1·t_1^2/2 'soil 1: triangle [kN/m]
P_2r = K_02·s_v1·t_2 'soil 2: rectangle [kN/m]
P_2t = K_02·g_2·t_2^2/2 'soil 2: triangle [kN/m]
P_3r = K_03·s_v2·t_3 'soil 3: rectangle [kN/m]
P_3t = K_03·g_3·t_3^2/2 'soil 3: triangle [kN/m]
P_0 = P_1 + P_2r + P_2t + P_3r + P_3t 'total at-rest pressure force on the stem [kN/m]
M_0 = P_1·(t_2 + t_3 + t_1/3) + P_2r·(t_3 + t_2/2) + P_2t·(t_3 + t_2/3) + P_3r·t_3/2 + P_3t·t_3/3 'its moment at the joint [kN·m/m]
z_0 = M_0/P_0 'height of the resultant above the joint [m]

#: **The stem drawn, to scale.** Vertical section of the stem with the backfill on the right (the back face, vertical, is at x = 0) and the front face inclined 1:12.5 on the left. The dashed lines separate the three strata (2.30, 1.70 and 1.00 m down to the joint). **Blue:** the **at-rest** pressure σ₀ = K₀·σ_{z} on the back face (1 m of arrow = 25 kPa): it grows with depth and **jumps** at each contact because K₀ changes (each soil has its φ). **Red:** the crest force, 30 kN/m. **Orange:** the stem weight, which falls behind the section center. Everything is reduced to the **construction joint**, at 5.00 m from the crest (y = 0 in the drawing), which is where it is reinforced.
pq_1 = K_01*g_1*t_1/25 'σ₀ at the base of soil 1, at drawing scale
pq_2 = K_02*s_v1/25 'σ₀ at the top of soil 2 (jumps: K₀ changes)
pq_3 = K_02*(s_v1 + g_2*t_2)/25 'σ₀ at the base of soil 2
pq_4 = K_03*s_v2/25 'σ₀ at the top of soil 3
pq_5 = K_03*(s_v2 + g_3*t_3)/25 'σ₀ at the joint
P0_t = round(P_0, 1) 'total force, for the label
#dibujo("GEO5 Demo01 stem: strata, at-rest pressure (blue, 1 m = 25 kPa), crest force (red) and weight (orange)", ud = m, escala = auto, cotas = m, alto = 230)
#  poligono(0, 0, 0, H_j, -t_f, H_j, -h_s, 0, "gruesa")
#  poligono(0, 0, 0, H_j, -t_f, H_j, -h_s, 0, "gris tenue")
#  linea(0, H_j, 4.8, H_j, "media verde")
#  linea(0, H_j - t_1, 4.8, H_j - t_1, "trazos")
#  linea(0, H_j - t_1 - t_2, 4.8, H_j - t_1 - t_2, "trazos")
#  linea(-h_s - 0.4, 0, 4.8, 0, "eje")
#  carga(0, H_j, 0, H_j - t_1, 0, pq_1, "", "azul", n = 4)
#  carga(0, H_j - t_1, 0, H_j - t_1 - t_2, pq_2, pq_3, "", "azul", n = 4)
#  carga(0, H_j - t_1 - t_2, 0, 0, pq_4, pq_5, "", "azul", n = 3)
#  flecha(2.4, H_j + a_F, 0.05, H_j + a_F, "rojo")
#  texto(0.4, H_j + a_F + 0.25, "F = 30 kN/m", 2.5, "i")
#  flecha(-x_W, y_W + 1.2, -x_W, y_W, "naranja")
#  texto(-x_W - 1.5, y_W + 1.3, "W = 45.98 kN/m", 2.5, "i")
#  texto(2.35, H_j - t_1/2, "soil 1: γ 19, φ 29°", 2.5, "i")
#  texto(2.35, H_j - t_1 - t_2/2, "soil 2: γ 17.5, φ 31.5°", 2.5, "i")
#  texto(2.35, t_3/2, "soil 3: γ 19.5, φ 27°", 2.5, "i")
#  texto(0.3, 0.2, "joint: reinforced here", 2.5, "i")
#  cota(-h_s - 0.7, 0, -h_s - 0.7, H_j, 0.1, "5.00")
#  cota(-t_f, H_j + 0.7, 0, H_j + 0.7, 0.1, "0.20")
#  cota(-h_s, -0.6, 0, -0.6, -0.1, "0.60")
#  cota(5.0, H_j - t_1, 3.6, H_j, 0.1, "2.30")
#  cota(5.0, H_j - t_1 - t_2, 3.6, H_j - t_1, 0.1, "1.70")
#  cota(5.0, 0, 3.6, H_j - t_1 - t_2, 0.1, "1.00")
#fin
#: **How to read it.** The area of each blue trapezoid is the pressure force of that stratum (rectangle = what the soil above weighs × K₀, triangle = its own weight × K₀). Added together they give **P₀ = @{P0_t} kN/m**, at @{z_0} m above the joint: the arm with which it bends the stem. The 30 kN/m force acts 5.20 m above the joint (large arm) and therefore weighs almost as much as all the soil. The weight, falling behind the section center, **subtracts** a little moment. The sum of the three moments is M_{Ed}, which is compared below with the resistance of the reinforcement.

## 4 · Design moment and shear at the joint

#: The pressure and the crest force bend the stem forward (tension on the back face); the weight, which falls behind the center, straightens it a little. With the 1.000 factors of the example (ASD):
M_Ed = M_0 + F_1·(H_j + a_F) - W_f·e_W 'design moment at the joint [kN·m/m]
V_Ed = P_0 + F_1 'design shear at the joint [kN/m]
N_Ed = W_f 'axial (not used in GEO5's simple bending) [kN/m]

## 4b · Moment and shear along the stem

#: The same calculation (at-rest pressure by strata + crest force − weight eccentricity) repeated at each depth z below the crest gives the **moment** and **shear** diagrams of the stem. The fixity at the footing (z = 5.00 m) is where they are largest: that is where it is reinforced. The GEO5 points are its result at the joint at 5.00 m.
Pm = [t_f; n_f; gamma_c; t_1; t_2; g_1; g_2; g_3; K_01; K_02; K_03; F_1; a_F] 'stem data together
#hide
function R = mvz(z, Pm)
  t_f = Pm(1)
  n_f = Pm(2)
  gc = Pm(3)
  t1 = Pm(4)
  t2 = Pm(5)
  g1 = Pm(6)
  g2 = Pm(7)
  g3 = Pm(8)
  k1 = Pm(9)
  k2 = Pm(10)
  k3 = Pm(11)
  Fc = Pm(12)
  aF = Pm(13)
  d1 = min(z, t1)
  F1 = k1*g1*d1*d1/2
  dep1 = 2*d1/3
  d2 = max(min(z - t1, t2), 0)
  st2 = k2*g1*t1
  sb2 = k2*(g1*t1 + g2*d2)
  F2 = (st2 + sb2)/2*d2
  dep2 = t1 + d2*(st2 + 2*sb2)/(3*max(st2 + sb2, 0.000000001))
  d3 = max(z - t1 - t2, 0)
  st3 = k3*(g1*t1 + g2*t2)
  sb3 = k3*(g1*t1 + g2*t2 + g3*d3)
  F3 = (st3 + sb3)/2*d3
  dep3 = t1 + t2 + d3*(st3 + 2*sb3)/(3*max(st3 + sb3, 0.000000001))
  P = F1 + F2 + F3
  M = F1*(z - dep1) + F2*(z - dep2) + F3*(z - dep3)
  h = t_f + z/n_f
  Ar = t_f*z
  At = (h - t_f)*z/2
  W = gc*(Ar + At)
  xW = (Ar*t_f/2 + At*(t_f + (h - t_f)/3))/max(Ar + At, 0.000000001)
  R = [M + Fc*(z + aF) - W*(h/2 - xW); P + Fc]
end
Mv = zeros(26, 2)
Vv = zeros(26, 2)
for j = 1:26
  zj = (j - 1)*0.2
  Rj = mvz(zj, Pm)
  Mv(j, 1) = zj
  Mv(j, 2) = Rj(1)
  Vv(j, 1) = zj
  Vv(j, 2) = Rj(2)
end
#show
R_j = mvz(H_j, Pm) 'check: the function at the joint gives [M_Ed; V_Ed]
#fplot(Momento = Mv, Cortante = Vv, GEO5M = [5 348.11], GEO5V = [5 148.8], [0 5])
#: x axis: depth z below the crest [m]; y axis: moment M [kN·m/m] and shear V [kN/m]. The moment grows **more than linearly** with depth (the soil pressure grows with z and so does its arm): that is why the critical section is always the base.

## 5 · The reinforced concrete section (EN 1992-1-1)

#: Design strengths, the given reinforcement and the effective depth:
f_cd = f_ck/g_cc 'design strength of concrete (α_{cc} = 1) [MPa]
f_yd = f_yk/g_ss 'design strength of steel [MPa]
A_s = n_b·pi·d_b^2/4 'back reinforcement per meter [mm2]
d_u = h_s - (r_c + d_b/2)/1000 'effective depth [m]
#: **Reinforcement ratio** and the EN 1992 minimum (9.2.1.1: 0.26·f_{ctm}/f_{yk}, and not less than 0.0013):
rho = A_s/(1000·b_w·1000·d_u) 'geometric reinforcement ratio
rho_min = max(0.26·f_ctm/f_yk, 0.0013) 'minimum reinforcement ratio
#: **Neutral axis** with the rectangular block (λ = 0.8, η = 1): the concrete compression equals the steel tension. Its limit is the one that lets the steel yield: x ≤ ε_{cu3}/(ε_{cu3} + f_{yd}/E_{s})·d, with ε_{cu3} = 0.0035 and E_{s} = 200 GPa:
x_n = A_s·f_yd/(0.8·b_w·1000·f_cd)/1000 'depth of the neutral axis [m]
x_max = 0.0035/(0.0035 + f_yd/200000)·d_u 'maximum neutral axis [m]
#: **Resisting moment**: the steel force times the arm d − 0.4·x:
M_Rd = A_s·f_yd·(d_u - 0.4·x_n)/1000 'resisting moment [kN·m/m]
#: **Shear without shear reinforcement** (EN 1992, 6.2.2): V_{Rd,c} = C_{Rd,c}·k·(100·ρ·f_{ck})^{1/3}·b·d, with C_{Rd,c} = 0.18/γ_{c} and k = 1 + √(200/d[mm]) ≤ 2:
k_v = min(2, 1 + sqrt(200/(1000·d_u))) 'size factor k
V_Rd = 0.18/g_cc·k_v·(100·rho·f_ck)^(1/3)·1000·b_w·d_u 'resisting shear [kN/m]
#: **Required reinforcement**: the A_{s} that gives M_{Rd} = M_{Ed}. With x = A_{s}·f_{yd}/(0.8·b·f_{cd}) a second-degree equation in A_{s} results, a·A_{s}² − f_{yd}·d·A_{s} + M_{Ed} = 0 (units: m², kN and m), and the small root is taken:
a_q = 0.4·(1000·f_yd)^2/(0.8·b_w·1000·f_cd) 'coefficient of A_s² [kN/m3]
A_req = (1000·f_yd·d_u - sqrt((1000·f_yd·d_u)^2 - 4·a_q·M_Ed))/(2·a_q)·1000000 'required reinforcement [mm2]
#hide
r_us = round(100·M_Ed/M_Rd, 1)
r_uv = round(100·V_Ed/V_Rd, 1)
#show
#: **Reading.** Bending uses @{r_us} % of the section and shear @{r_uv} %: the section passes with room to spare. GEO5 flags "NOT OK. (1000 %)" in bending for ANOTHER section, the one at 1.57 m below the crest, where it cuts the reinforcement: there the depth is 0.33 m and the same 14 Ø 20 give x > x_{max} ("too much reinforcement"), an over-reinforced section.

As_t = round(A_s, 0) 'reinforcement, for the label
ME_t = round(M_Ed, 1) 'design moment, for the label
MR_t = round(M_Rd, 1) 'resisting moment, for the label
xn_t = round(x_n, 3) 'neutral axis, for the label
yb_ = linspace(1/28, 1 - 1/28, 14) 'position of the 14 bars along the meter
#: **The reinforced section, to scale.** Horizontal cut of the stem at the joint height (0.60 m thick) through a 1 m long strip. The front face (left) is in compression; the **back** one (right), in tension, carries the 14 bars Ø20 per meter, at 30 mm cover. The **neutral axis** (dashed line) lies at x = @{xn_t} m from the compressed face: it is the depth of the concrete block that balances the steel tension. The **effective depth** d is the distance from the compressed face to the center of the bars.
#dibujo("Base section: 14 Ø20 per meter on the back face, cover 30 mm, neutral axis and effective depth", ud = m, escala = auto, cotas = m, alto = 200)
#  rect(0, 0, h_s, 1, "gruesa")
#  circulo(h_s - (r_c + d_b/2)/1000, yb_, d_b/2000, "acero relleno")
#  linea(x_n, 0, x_n, 1, "trazos")
#  texto(x_n + 0.02, 0.5, "neutral axis", 2.5, "i")
#  texto(0.05, 0.9, "front face (compression)", 2.5, "i")
#  texto(h_s + 0.25, 0.5, "back face (tension)", 2.5, "i")
#  cota(0, -0.12, h_s, -0.12, -0.05, "0.60")
#  cota(0, 1.12, d_u, 1.12, 0.05, "d")
#  cota(h_s - (r_c + d_b/2)/1000, 1.12, h_s, 1.12, 0.05, "0.04")
#  cota(h_s + 0.15, 0, h_s + 0.15, 1/14, 0.05, "7.1 cm")
#fin
#: **How to read it.** Each circle is a bar Ø20 (area 314 mm²); 14 bars per meter give A_{s} = @{As_t} mm². With the design moment M_{Ed} = @{ME_t} kN·m/m, the resistance M_{Rd} = @{MR_t} kN·m/m leaves the section with room to spare; GEO5 flags "NOT OK" for another section (at 1.57 m from the crest) which this sheet does not reproduce.

## 6 · Hekatan against GEO5

#hide
g_P0 = 118.80
g_z0 = 1.65
g_W = 45.98
g_ME = 348.11
g_VE = 148.80
g_As = 4398.2
g_Ar = 1495.1
g_rho = 0.79
g_rmin = 0.13
g_x = 0.18
g_xm = 0.35
g_VR = 268.85
g_MR = 933.56
h_P0 = round(P_0, 2)
h_z0 = round(z_0, 2)
h_W = round(W_f, 2)
h_ME = round(M_Ed, 2)
h_VE = round(V_Ed, 2)
h_As = round(A_s, 1)
h_Ar = round(A_req, 1)
h_rho = round(100·rho, 2)
h_rmin = round(100·rho_min, 2)
h_x = round(x_n, 2)
h_xm = round(x_max, 2)
h_VR = round(V_Rd, 2)
h_MR = round(M_Rd, 2)
x_P0 = round(100·(h_P0/g_P0 - 1), 3)
x_z0 = round(100·(h_z0/g_z0 - 1), 3)
x_Wd = round(100·(h_W/g_W - 1), 3)
x_ME = round(100·(h_ME/g_ME - 1), 3)
x_VE = round(100·(h_VE/g_VE - 1), 3)
x_As = round(100·(h_As/g_As - 1), 3)
x_Ar = round(100·(h_Ar/g_Ar - 1), 3)
x_rho = round(100·(h_rho/g_rho - 1), 3)
x_rmin = round(100·(h_rmin/g_rmin - 1), 3)
x_x = round(100·(h_x/g_x - 1), 3)
x_xm = round(100·(h_xm/g_xm - 1), 3)
x_VR = round(100·(h_VR/g_VR - 1), 3)
x_MR = round(100·(h_MR/g_MR - 1), 3)
#show
#| Magnitud | Hekatan (junta a 5.00 m) | GEO5 2024 | Diferencia [%] |
#|---|---:|---:|---:|
#| empuje en reposo P₀ [kN/m] | @{h_P0} | @{g_P0} | @{x_P0} |
#| su altura sobre la junta [m] | @{h_z0} | @{g_z0} | @{x_z0} |
#| peso del fuste [kN/m] | @{h_W} | @{g_W} | @{x_Wd} |
#| **M_{Ed} [kN·m/m]** | @{h_ME} | @{g_ME} | @{x_ME} |
#| **V_{Ed} [kN/m]** | @{h_VE} | @{g_VE} | @{x_VE} |
#| A_{s} dada [mm²] | @{h_As} | @{g_As} | @{x_As} |
#| A_{s} requerida [mm²] | @{h_Ar} | @{g_Ar} | @{x_Ar} |
#| ρ [%] | @{h_rho} | @{g_rho} | @{x_rho} |
#| ρ_{min} [%] | @{h_rmin} | @{g_rmin} | @{x_rmin} |
#| eje neutro x [m] | @{h_x} | @{g_x} | @{x_x} |
#| x_{max} [m] | @{h_xm} | @{g_xm} | @{x_xm} |
#| **V_{Rd} [kN/m]** | @{h_VR} | @{g_VR} | @{x_VR} |
#| **M_{Rd} [kN·m/m]** | @{h_MR} | @{g_MR} | @{x_MR} |

#: **What does not agree to four digits: the joint depth.** With the joint at 5.00 m, P₀, the weight, M_{Ed}, V_{Ed} and M_{Rd} differ from GEO5 by between 0.02 % and 0.06 %. All five at once —and also the required A_{s} and V_{Rd}— close exactly if the section is **1.25 mm higher up**, at 4.99875 m (depth 0.5999 m instead of 0.6000). It is checked below with that depth. GEO5 prints "5.00 m from the wall crest" and the rule that moves the section is not in the help: **pending to extract from CantileverWall_5.dll**. The check below **is not the calculation of the sheet**, it is the test of the hypothesis.
H_h = 4.99875 'joint depth that agrees with GEO5 (hypothesis, not seen in the binary) [m]
h_sh = t_f + H_h/n_f 'section depth with that depth [m]
t_3h = H_h - t_1 - t_2 'soil 3 over that joint [m]
P_0h = P_1 + P_2r + P_2t + K_03·s_v2·t_3h + K_03·g_3·t_3h^2/2 'P₀ with the joint at 4.99875 m [kN/m]
A_th = (h_sh - t_f)·H_h/2 'front wedge with that height [m2]
W_fh = gamma_c·(t_f·H_h + A_th) 'weight with that height [kN/m]
x_Wh = (t_f·H_h·t_f/2 + A_th·(t_f + (h_sh - t_f)/3))/(t_f·H_h + A_th) 'centroid from the back face [m]
M_0h = P_1·(t_2 + t_3h + t_1/3) + P_2r·(t_3h + t_2/2) + P_2t·(t_3h + t_2/3) + K_03·s_v2·t_3h·t_3h/2 + K_03·g_3·t_3h^2/2·t_3h/3 'pressure moment [kN·m/m]
M_Edh = M_0h + F_1·(H_h + a_F) - W_fh·(h_sh/2 - x_Wh) 'M_Ed with the joint at 4.99875 m [kN·m/m]
d_uh = h_sh - (r_c + d_b/2)/1000 'effective depth [m]
M_Rdh = A_s·f_yd·(d_uh - 0.4·x_n)/1000 'M_Rd with that depth [kN·m/m]
#hide
k1 = round(P_0h, 2)
k2 = round(W_fh, 2)
k3 = round(M_Edh, 2)
k4 = round(P_0h + F_1, 2)
k5 = round(M_Rdh, 2)
#show
#: With the joint at 4.99875 m: P₀ = @{k1} (GEO5 118.80), weight @{k2} (45.98), M_{Ed} = @{k3} (348.11), V_{Ed} = @{k4} (148.80), M_{Rd} = @{k5} (933.56).
#: **Not reproduced here** (pending): the toe check ("Wall jump check", 6 Ø 16, required A_{s} 730.6 mm²) and the heel check ("Wall heel check"): they need the pressure distribution under the base that GEO5 uses for dimensioning, which is not in the captures.

## 7 · NEC

#: NEC-SE-GC 2015 does not cover the stem reinforcement: it refers to NEC-SE-HM (reinforced concrete, which follows ACI 318-19). GEO5 in this example checks with EN 1992 and unfactored loads (1.000 factors), so **this reinforcement is not a NEC design**: with NEC-SE-HM the earth pressure is factored (1.6·H in the combination 1.2·D + 1.6·L + 1.6·H) and the resistance is reduced (φ = 0.90 in bending, 0.75 in shear, block 0.85·f'_{c}). That design is left for a separate ACI sheet; here only GEO5 is reproduced.
