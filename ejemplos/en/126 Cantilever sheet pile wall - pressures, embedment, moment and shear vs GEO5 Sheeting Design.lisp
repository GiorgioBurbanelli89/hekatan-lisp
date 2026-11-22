# Cantilever sheet pile wall: earth pressures, embedment, moment and shear, against GEO5 Sheeting Design
#numerico

#: **What is computed.** The wall of the official GEO5 Sheeting Design example (**Demo_manual_04.gp1**, manual EM 4 "Design of a non-anchored retaining wall"): an unanchored VL 601 steel sheet pile that supports a **2.75 m** trench. What the GEO5 "Analysis" frame gives is sought: how much it must be **embedded** in the soil, the **total length**, the **maximum moment** and the **maximum shear** (stage 1).
#: **How.** With the official GEO5 help: "Analysis of Sheet Pile Wall" (moment equilibrium and then shear equilibrium), "Active Earth Pressure – The Coulomb Theory", "Passive Earth Pressure – The Caquot-Kérisel Theory" with its two tables, and "Analysis of Sheeting Structures" (EN 1997, approach DA3). The soil data were read from the .gp1 file itself (it is binary: the numbers are stored as they are).
#: **Judge.** The GEO5 2024 "Analysis" frame and its "In detail". At the end, the **Hekatan against GEO5** table with the difference in %.
#: **Units.** kN, m and kPa (as GEO5); at the end also in tonf. Inside the formulas the angles are in radians.

## 1 · Example data (Demo_manual_04.gp1)

#: **The ground**, three strata measured from the head of the wall:
gamma_1 = 17.5 'unit weight of the sand with fines (0 to 1.50 m) [kN/m3]
phi_1 = 29.5 'friction angle of the sand [degrees]
c_1 = 0 'cohesion of the sand [kPa]
gamma_2 = 18.5 'unit weight of the clayey sand (1.50 to 2.50 m) [kN/m3]
phi_2 = 27 'friction angle of the clayey sand [degrees]
c_2 = 8 'cohesion of the clayey sand [kPa]
gamma_3 = 21 'unit weight of the low-plasticity clay (below 2.50 m) [kN/m3]
phi_3 = 19 'friction angle of the clay [degrees]
c_3 = 12 'cohesion of the clay [kPa]
delta_k = 14 'soil-wall friction, the same in the three soils [degrees]
#: The saturated weight equals the natural one in the three soils (file data), so below water the submerged weight is γ − γ_{w}.
gamma_w = 10 'unit weight of water [kN/m3]
#: **The excavation and the water.** The water table is **only behind**, at 1.00 m; in front, in the trench, there is no water (Water frame, stage 1). There are no surcharges or anchors, and the thrust is the **active** one without the "minimum design pressure".
H_e = 2.75 'trench depth [m]
z_w = 1.0 'depth of the water table behind [m]
#: **The design approach.** The example uses EN 1997, **DA3**: the soil parameters are divided by 1.25 (tan φ and c) and the geotechnical actions keep factor 1.00 (help "Analysis of Sheeting Structures").
F_m = 1.25 'partial factor of the soil (DA3) on tan φ and c

#dibujo("Example section: three strata, 2.75 m trench and water behind at 1.00 m", ud = m, escala = auto, cotas = m, alto = 160)
#  linea(-3, 0, 0, 0, "media verde")
#  linea(0, -2.75, 3, -2.75, "media verde")
#  rect(-0.05, -5.54, 0.1, 5.54, "gruesa")
#  linea(-3, -1.5, 0, -1.5, "fina")
#  linea(-3, -2.5, 0, -2.5, "fina")
#  linea(0, -2.5, 3, -2.5, "fina")
#  linea(-3, -1.0, -0.1, -1.0, "trazos azul")
#  texto(-2.9, -0.88, "water table behind", 2.6, "i")
#  texto(-2.9, -0.4, "sand with fines  φ 29.5°", 2.6, "i")
#  texto(-2.9, -2.0, "clayey sand  φ 27°, c 8", 2.6, "i")
#  texto(-2.9, -3.6, "clay  φ 19°, c 12", 2.6, "i")
#  texto(0.3, -2.6, "bottom of the trench", 2.6, "i")
#  cota(0.4, 0, 0.4, -2.75, 0.25, "2.75")
#  cota(0.4, -2.75, 0.4, -5.54, 0.25, "embedment (GEO5: 2.79)")
#fin

## 2 · The design parameters (DA3)

#: Each angle is reduced through its tangent and the cohesion directly. The soil-wall friction δ is reduced by GEO5 **in the same proportion as φ** (δ_{d} = δ·φ_{d}/φ): the help does not write it, but it is what the pressures GEO5 stores in the .gp1 itself give (the three layers, to 6 digits).
f_1 = atan(tan(phi_1·pi/180)/F_m) 'design φ of the sand [rad]
f_2 = atan(tan(phi_2·pi/180)/F_m) 'design φ of the clayey sand [rad]
f_3 = atan(tan(phi_3·pi/180)/F_m) 'design φ of the clay [rad]
d_1 = delta_k·f_1/phi_1 'design δ in the sand [rad]
d_2 = delta_k·f_2/phi_2 'design δ in the clayey sand [rad]
d_3 = delta_k·f_3/phi_3 'design δ in the clay [rad]
c_d2 = c_2/F_m 'design cohesion of the clayey sand [kPa]
c_d3 = c_3/F_m 'design cohesion of the clay [kPa]
#hide
g_f1 = round(f_1·180/pi, 2)
g_f3 = round(f_3·180/pi, 2)
g_d1 = round(d_1·180/pi, 2)
g_d3 = round(d_3·180/pi, 2)
r_cd3 = round(c_d3, 2)
#show
#: In degrees: φ_{d} of the sand = @{g_f1}°, of the clay = @{g_f3}°, and δ_{d} goes from @{g_d1}° (sand) to @{g_d3}° (clay). The clay ends up with c_{d} = @{r_cd3} kPa: the same 15.40° and 9.60 kPa that GEO5 writes in its stability report.

## 3 · Active thrust behind (Coulomb)

#: **GEO5 help** (vertical wall α = 0, horizontal ground β = 0): σ_{a} = σ_{z}·K_{a} − 2·c·K_{ac}, and the horizontal part is σ_{a}·cos δ.
#: K_{a} = cos²φ / (cos δ·(1 + √(sin(φ + δ)·sin φ / cos δ))²) and K_{ac} = cos φ / (1 + sin(φ + δ)). Already with the cos δ of the horizontal component:
Kh_1 = cos(f_1)^2/(1 + sqrt(sin(f_1 + d_1)·sin(f_1)/cos(d_1)))^2 'K_a·cos δ, sand
Kh_2 = cos(f_2)^2/(1 + sqrt(sin(f_2 + d_2)·sin(f_2)/cos(d_2)))^2 'K_a·cos δ, clayey sand
Kh_3 = cos(f_3)^2/(1 + sqrt(sin(f_3 + d_3)·sin(f_3)/cos(d_3)))^2 'K_a·cos δ, clay
Ch_2 = 2·c_d2·cos(f_2)/(1 + sin(f_2 + d_2))·cos(d_2) 'horizontal cohesion term, clayey sand [kPa]
Ch_3 = 2·c_d3·cos(f_3)/(1 + sin(f_3 + d_3))·cos(d_3) 'horizontal cohesion term, clay [kPa]
#: **The effective vertical stress behind**, σ'_{z}: with γ down to the water and with γ − γ_{w} below:
sv_10 = gamma_1·z_w 'σ′z at 1.00 m (water table) [kPa]
sv_15 = sv_10 + (gamma_1 - gamma_w)·0.5 'σ′z at 1.50 m [kPa]
sv_25 = sv_15 + (gamma_2 - gamma_w)·1.0 'σ′z at 2.50 m [kPa]
sv_H = sv_25 + (gamma_3 - gamma_w)·(H_e - 2.5) 'σ′z at the bottom of the trench [kPa]
#: **The total pressure on the wall** = soil + water. If the cohesion leaves the soil pressure negative, it is cut to zero (help: "tension cutoff"):
p_10 = sv_10·Kh_1 'at 1.00 m [kPa]
p_15a = sv_15·Kh_1 + gamma_w·0.5 'at 1.50 m, sand [kPa]
p_15b = max(sv_15·Kh_2 - Ch_2, 0) + gamma_w·0.5 'at 1.50 m, clayey sand [kPa]
p_25a = max(sv_25·Kh_2 - Ch_2, 0) + gamma_w·1.5 'at 2.50 m, clayey sand [kPa]
p_25b = max(sv_25·Kh_3 - Ch_3, 0) + gamma_w·1.5 'at 2.50 m, clay [kPa]
p_H = max(sv_H·Kh_3 - Ch_3, 0) + gamma_w·(H_e - z_w) 'at the bottom of the trench [kPa]
#: In the clayey sand the cohesion subtracts, but it does not manage to cancel the soil pressure (σ'_{z}·K_{h2} = 8.54 kPa > 7.49 kPa at 1.50 m): there is no tension crack.
#: **The total thrust down to the bottom of the trench** (area of the diagram, segment by segment; everything is linear between the points above):
E_1 = sv_10·Kh_1·z_w/2 + (p_10 + p_15a)/2·0.5 'sand, 0 to 1.50 m [kN/m]
E_2 = (p_15b + p_25a)/2·1.0 'clayey sand, 1.50 to 2.50 m [kN/m]
E_3 = (p_25b + p_H)/2·(H_e - 2.5) 'clay, 2.50 to 2.75 m [kN/m]
E_a = E_1 + E_2 + E_3 'total thrust on the free length = shear at the bottom of the trench [kN/m]
#hide
r_Ea = round(E_a, 4)
r_pH = round(p_H, 2)
#show
#: E_{a} = @{r_Ea} kN/m. **GEO5 draws −25.74 kN/m** in the shear diagram at 2.75 m: it is this number (the sign is only the direction). And the pressure at the bottom of the trench, @{r_pH} kPa, is the tip of the pressure diagram that GEO5 draws (about 21 kPa in the screenshot). Of those 21 kPa, 17.5 are water.

## 4 · Passive resistance in front (Caquot-Kérisel)

#: Below the trench, in front of the wall, the clay resists with the **passive thrust**. GEO5 help: σ_{p} = σ_{z}·K_{p}·ψ + 2·c·√(K_{p}·ψ), with K_{p} from the table for δ = −φ and ψ, the reduction because here |δ| < φ (second table). The horizontal component is σ_{p}·cos δ.
#: **Table "Coefficient of Passive Earth Pressure Kp"**, row α = 0, column β = 0: K_{p} = 2.19 for φ = 15° and 3.01 for φ = 20°. **Table "Reduction Coefficient ψ"**, with |δ|/φ between 0.6 and 0.8: for φ = 15°, ψ = 0.934 and 0.979; for φ = 20°, 0.901 and 0.968. It is interpolated linearly:
a_p = (f_3·180/pi - 15)/5 'position of φ_d between 15° and 20°
K_p = 2.19 + (3.01 - 2.19)·a_p 'passive coefficient for δ = −φ
r_δ = d_3/f_3 'ratio |δ|/φ
w_r = (r_δ - 0.6)/0.2 'position of |δ|/φ between 0.6 and 0.8
psi_15 = 0.934 + (0.979 - 0.934)·w_r 'ψ for φ = 15°
psi_20 = 0.901 + (0.968 - 0.901)·w_r 'ψ for φ = 20°
psi_r = psi_15 + (psi_20 - psi_15)·a_p 'ψ for φ_d
K_pp = K_p·psi_r 'reduced passive coefficient, K_p·ψ
#: In front there is no water: the clay weighs fully, γ_{3}·(z − 2.75). The horizontal passive pressure and its value just below the trench:
Kp_h = K_pp·cos(d_3) 'horizontal passive slope, per kPa of σz
Cp_h = 2·c_d3·sqrt(K_pp)·cos(d_3) 'horizontal passive cohesion term [kPa]
#hide
r_Kpp = round(K_pp, 4)
r_net0 = round(p_H - Cp_h, 2)
#show
#: Just below the trench the passive already equals C_{ph}, due to the cohesion, so the net pressure jumps from @{r_pH} kPa to @{r_net0} kPa: the step that GEO5 draws at 2.75 m.

## 5 · The equilibrium of the wall: embedment, moment and shear

#: **GEO5 help, "Analysis of Sheet Pile Wall":** the program searches, iterating, for the point of the wall where **M_{overturning} = M_{resisting}** is satisfied (the sum of moments of all the pressures is zero); then it lengthens the wall until the **shear equilibrium** is satisfied (the "embedment depth").
#: Here it is done the same way: the net pressure p(z) = active + water − passive is integrated twice from top to bottom (V = ∫p dz, M = ∫V dz, midpoint rule, step 2.5 mm) and the depth below the trench where M crosses zero is searched (interpolating between two steps):
#hide
dz = 0.0025
n_z = 2400
V_z = zeros(n_z + 1, 1)
M_z = zeros(n_z + 1, 1)
P_z = zeros(n_z + 1, 1)
for i = 1:n_z
  z = (i - 0.5)·dz
  sv = gamma_1·min(z, 1) + (gamma_1 - gamma_w)·max(min(z, 1.5) - 1, 0) + (gamma_2 - gamma_w)·max(min(z, 2.5) - 1.5, 0) + (gamma_3 - gamma_w)·max(z - 2.5, 0)
  u = gamma_w·max(z - z_w, 0)
  if z < 1.5
    pa = sv·Kh_1
  elseif z < 2.5
    pa = max(sv·Kh_2 - Ch_2, 0)
  else
    pa = max(sv·Kh_3 - Ch_3, 0)
  end
  pp = 0
  if z > H_e
    pp = gamma_3·(z - H_e)·Kp_h + Cp_h
  end
  p = pa + u - pp
  P_z(i) = p
  V_z(i + 1) = V_z(i) + p·dz
  M_z(i + 1) = M_z(i) + V_z(i)·dz + p·dz^2/2
end
k_t = 0
for j = round(H_e/dz) + 2:n_z
  if k_t == 0
    if M_z(j) <= 0
      k_t = j
    end
  end
end
s_f = M_z(k_t - 1)/(M_z(k_t - 1) - M_z(k_t))
d_0 = (k_t - 2 + s_f)·dz - H_e
d_G = 2.401829
R_V = zeros(2, 1)
R_M = zeros(2, 1)
R_z = zeros(2, 1)
R_t = zeros(2, 1)
R_D = zeros(2, 1)
for c = 1:2
  if c == 1
    dc = d_0
  else
    dc = d_G
  end
  zt = H_e + dc
  j = floor(zt/dz) + 1
  R_V(c) = -(V_z(j) + (zt/dz - j + 1)·(V_z(j + 1) - V_z(j)))
  R_t(c) = M_z(j) + (zt/dz - j + 1)·(M_z(j + 1) - M_z(j))
  for k = 0:7
    zn = H_e + k·dc/7
    j = floor(zn/dz) + 1
    mn = M_z(j) + (zn/dz - j + 1)·(M_z(j + 1) - M_z(j))
    if mn > R_M(c)
      R_M(c) = mn
      R_z(c) = zn
    end
  end
  zb = zt + 0.01
  svb = sv_25 + (gamma_3 - gamma_w)·(zb - 2.5)
  R_D(c) = R_V(c)/(svb·Kp_h + Cp_h + gamma_w·(zb - z_w))
end
M_pk = 0
for i = 1:k_t
  M_pk = max(M_pk, M_z(i))
end
#show
d_0 'depth below the trench where M = 0 [m]
#: **The maximum moment.** GEO5 does not read it at the peak of the curve but at the **nodes of its drawing**: the buried part split into 7 equal parts (2.75 + k·d_{0}/7). That is how it is done here.
#: **The final segment (shear equilibrium).** At the point of M = 0 the wall still carries a shear V_{t}; below it, the wall rotates and the soil **behind** starts to resist with its passive (plus the water). The help does not give the formula. The numbers GEO5 stores in the .gp1 satisfy Δ = V_{t}/p_{cb}, with p_{cb} the passive behind + water evaluated **1 cm below** the point of M = 0, and the lengthening also starts 1 cm lower: embedment = d_{0} + 0.01 + Δ.
V_t = R_V(1) 'shear at the point of M = 0 = maximum shear [kN/m]
M_mx = R_M(1) 'maximum moment at the GEO5 nodes [kN·m/m]
M_pk 'true peak of the moment curve [kN·m/m]
D_e = R_D(1) 'lengthening from the shear equilibrium [m]
d_emp = d_0 + 0.01 + D_e 'total embedment below the trench [m]
L_p = H_e + d_emp 'total length of the wall [m]
#: **GEO5 does not stop at exact M = 0.** Its iteration ends at d_{0} = 2.401829 m (the last node of its diagram; it stores 2.411829 = d_{0} + 1 cm), and there its own moment is −0.304655 kN·m/m, not zero (the "−0.30" seen at the foot of the drawing). With the pressure of this sheet, M = 0 falls 4 mm higher. Taking the d_{0} where GEO5 stopped, the rest comes out the same as GEO5:
M_G = R_t(2) 'moment at the GEO5 d0 (GEO5 stores −0.304655) [kN·m/m]
V_G = R_V(2) 'shear with the GEO5 d0 [kN/m]
Mx_G = R_M(2) 'maximum moment at the nodes, with the GEO5 d0 [kN·m/m]
D_G = R_D(2) 'lengthening with the GEO5 d0 [m]
L_G = H_e + d_G + 0.01 + D_G 'length with the GEO5 d0 [m]
#: **In tonf** (1 tonf = 9.80665 kN):
M_ton = M_mx/9.80665 'maximum moment [tonf·m/m]
V_ton = V_t/9.80665 'maximum shear [tonf/m]

#hide
n_g = 53
zg = zeros(n_g, 1)
pg = zeros(n_g, 1)
vg = zeros(n_g, 1)
mg = zeros(n_g, 1)
for k = 1:n_g
  i = min((k - 1)·40 + 1, k_t)
  zg(k) = -(i - 1)·dz
  pg(k) = P_z(i)/25
  vg(k) = V_z(i)/25
  mg(k) = M_z(i)/12.5
end
#show
#: For drawing, every 10 cm (pressure: 1 unit = 25 kPa; shear: 1 = 25 kN/m; moment: 1 = 12.5 kN·m/m; depth in m):
p_g = pg 'scaled net pressure
v_g = vg 'scaled shear
m_g = mg 'scaled moment
z_g = zg 'depth
#dibujo("Net pressure (blue), shear (red) and moment (green) along the wall — stage 1", ud = m, escala = auto, alto = 200)
#  linea(0, 0.2, 0, -5.6, "eje")
#  linea(-3.4, -2.75, 3.6, -2.75, "trazos")
#  texto(2.2, -2.65, "bottom of the trench", 2.6, "i")
#  polilinea(p_g, z_g, "gruesa azul")
#  polilinea(v_g, z_g, "media rojo")
#  polilinea(m_g, z_g, "media verde")
#  linea(-3.4, -5.15, 3.6, -5.15, "puntos")
#  texto(-3.3, -5.05, "pivot (M = 0) at 2.40 m below the trench", 2.6, "i")
#  linea(-3.4, -5.54, 3.6, -5.54, "puntos rojo")
#  texto(-3.3, -5.44, "toe of the wall, 5.54 m (GEO5)", 2.6, "i")
#  texto(0.95, -1.4, "net pressure", 2.6, "i")
#  texto(3.35, -3.6, "M máx", 2.6, "i")
#  texto(-3.2, -4.6, "passive in front", 2.6, "i")
#fin
#hide
r_d0 = round(d_0, 3)
r_Vt = round(V_t, 2)
r_Mm = round(M_mx, 2)
r_zm = round(R_z(1), 2)
r_De = round(D_e, 3)
#show
#: **Reading.** At @{r_d0} m below the trench the moment vanishes: above it the thrust from behind (soil + water) governs and below it the passive of the clay. The maximum moment, @{r_Mm} kN·m/m, falls at @{r_zm} m, where the shear crosses zero. The maximum shear, @{r_Vt} kN/m, is at the point of M = 0: it is the force that the final segment of @{r_De} m has to give back.

## 6 · Hekatan against GEO5

#: GEO5 prints 2 decimals, but **stores the complete results** inside the .gp1 (object TPaz1Posouzeni and the diagram points). The comparison is made against those, to 4 decimals:
#hide
g_Ea = 25.742982
g_p1 = 6.482615
g_p25 = 19.460799
g_pH = 21.580005
g_n0 = -6.170034
g_d0 = 2.401829
g_V = 73.08522
g_M = 40.855667
g_De = 0.374533
g_de = 2.786361
g_L = 5.536361
h_Ea = round(E_a, 4)
h_p1 = round(p_10, 4)
h_p25 = round(p_25a, 4)
h_pH = round(p_H, 4)
h_n0 = round(p_H - Cp_h, 4)
h_d0 = round(d_0, 4)
h_V = round(V_G, 4)
h_M = round(Mx_G, 4)
h_De = round(D_G, 4)
h_de = round(d_G + 0.01 + D_G, 4)
h_L = round(L_G, 4)
x_Ea = round(100·(h_Ea/g_Ea - 1), 4)
x_p1 = round(100·(h_p1/g_p1 - 1), 4)
x_p25 = round(100·(h_p25/g_p25 - 1), 4)
x_pH = round(100·(h_pH/g_pH - 1), 4)
x_n0 = round(100·(h_n0/g_n0 - 1), 4)
x_d0 = round(100·(h_d0/g_d0 - 1), 4)
x_V = round(100·(h_V/g_V - 1), 4)
x_M = round(100·(h_M/g_M - 1), 4)
x_De = round(100·(h_De/g_De - 1), 4)
x_de = round(100·(h_de/g_de - 1), 4)
x_L = round(100·(h_L/g_L - 1), 4)
o_V = round(V_t, 2)
o_M = round(M_mx, 2)
o_L = round(L_p, 3)
#show
#| Magnitud | Hekatan | GEO5 2024 (.gp1) | Diferencia [%] |
#|---|---:|---:|---:|
#| presión a 1.00 m (arena) [kPa] | @{h_p1} | @{g_p1} | @{x_p1} |
#| presión a 2.50 m (arena arcillosa) [kPa] | @{h_p25} | @{g_p25} | @{x_p25} |
#| presión al fondo de la zanja [kPa] | @{h_pH} | @{g_pH} | @{x_pH} |
#| presión neta bajo la zanja [kPa] | @{h_n0} | @{g_n0} | @{x_n0} |
#| cortante en el fondo de la zanja [kN/m] | @{h_Ea} | @{g_Ea} | @{x_Ea} |
#| punto de giro (M = 0) bajo la zanja [m] | @{h_d0} | @{g_d0} | @{x_d0} |
#| **cortante máximo** [kN/m] (GEO5: 73.09) ¹ | @{h_V} | @{g_V} | @{x_V} |
#| **momento máximo** [kN·m/m] (GEO5: 40.86) ¹ | @{h_M} | @{g_M} | @{x_M} |
#| alargue por cortantes [m] ¹ | @{h_De} | @{g_De} | @{x_De} |
#| **empotramiento** [m] (GEO5: 2.79) ¹ | @{h_de} | @{g_de} | @{x_de} |
#| **largo de la pantalla** [m] (GEO5: 5.54) ¹ | @{h_L} | @{g_L} | @{x_L} |
#: ¹ With the d_{0} where the GEO5 iteration stops (2.401829 m). With the exact M = 0 of this sheet (@{h_d0} m) @{o_V} kN/m, @{o_M} kN·m/m and @{o_L} m come out: **the only thing that is not reproduced is the stopping criterion of the GEO5 iteration** (it stops with M = −0.30 instead of 0, 4 mm lower). That is in the binary, not in the help.
#: **Three things the help does not say and that were taken from the results stored by GEO5** (they are not adjustments: each one was checked in all layers or points): (1) δ is reduced in proportion to φ; (2) the maximum moment is read at the 7 nodes of the buried segment; (3) the lengthening starts 1 cm below the pivot point and uses the passive behind that point. The Caquot-Kérisel table is interpolated linearly in φ and in |δ|/φ.
#: **Not reproduced (pending):** stage 2 (water 1 m above the ground behind, unreduced parameters) and its envelope of 178.81 kN·m/m and 215.82 kN/m; the verification of the VL 601 section with EN 1993-1-1 (bending NOT OK at 100.4 %); and the minimum depth of 4.46 m of the Stability frame, which comes from a slope stability analysis (another program).

## 7 · What the NEC requires

#: **NEC-SE-GC 2015** (official), §5.2 (p. 36): sheet piles and braced excavations are retaining structures. It asks to check structural failure and excessive deformation, and the earthquake with Mononobe-Okabe (p. 37).
#: **Table 5** (p. 38), general stability: 1.50 for permanent works (static), 1.30 for temporary works, 1.20 during construction; 1.05 and 1.00 pseudo-static. It **gives no** factor for the embedment or for the mobilised passive: the one used is the engineer's criterion.
#: §4.2.1 (p. 29): NEC-15 works with a **global safety factor** and unfactored loads. The GEO5 example uses EN 1997-DA3 (partial factors); for the NEC it is changed in Settings to "Safety factors (ASD)". Here DA3 is kept to be able to compare with the example.
#: §5.1 (p. 35): consider the surcharges of the public road and bottom failure. The **2023 draft (unofficial)** sets 15 kPa as the minimum surcharge; this example carries no surcharge.
#: **Earthquake:** k_{h} = 0.6·Z·F_{a} (note to Table 4, p. 31). Zone V (Z = 0.40) with soil D (F_{a} = 1.20):
k_h = 0.6·0.40·1.20 'NEC-15 horizontal seismic coefficient, zone V, soil D
#: The example has no earthquake (Earthquake switched off); for the NEC this k_{h} is written by hand in GEO5.
