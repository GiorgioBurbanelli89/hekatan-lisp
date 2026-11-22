# L-shaped cantilever wall with shear key and earthquake: layered Mononobe-Okabe exactly as GEO5, NEC-15 and 2023 draft k_h
#numerico

#: **What is computed.** The **L-shaped cantilever wall with shear key** of Portoviejo (Manabí), the one from the GEO5 Cantilever Wall 2024 video series: footing 0.40 m deep, 2.60 m stem on SP sand (γ 18.5 kN/m³, φ 30°) that changes to silty SP-SM sand (γ 17.5, φ 29.97°) at 3.00 m. A **pseudo-static earthquake** is applied with k_{h} from NEC-15 and from the NEC-SE-GC 2023 draft, and overturning and sliding are checked. The **shear key** (0.50 × 0.30 m under the end of the heel) is the usual one in Ecuador: it lowers the base, inclines it and improves sliding.
#: **Algorithm.** It is that of GEO5, extracted from its binary (disassembly of CantileverWall_5.dll and dynamic debugging with Frida): the thrust face is split into **layers**: the **virtual face** (plane leaving the end of the heel at 45° + φ/2 above the horizontal, soil against soil) and the **vertical face of the heel** down to the bottom of the footing or of the shear key. The **static** thrust accumulates σ_{v} from the top; the Mononobe-Okabe **seismic increment** accumulates σ_{v}′ from the bottom (inverted triangle). Each layer is a trapezoid.
#: **Judge.** The "Verification" and force tables of GEO5 Cantilever Wall 2024, computed on 5-Oct-2026 with k_{h} = 0.336. The comparison is in section 4; GEO5 gives two decimals.
#: **Units.** kN, m and kPa per metre of wall. Abscissa x from the tip of the toe toward the backfill; elevation y from the bottom of the footing upward. The angles in the data are in degrees; inside the formulas, in radians.

## 1 · What each code requires for a wall

#: **NEC-SE-GC 2015 (official).** §4.2.2, note (*) of Table 4 (p. 31): "the seismic demand for pseudo-static analyses will be 60 % of the maximum acceleration on the ground", that is k_{h} = 0.6·a_{max}/g, with a_{max} = Z·F_{a}. For walls, §5 (p. 37): the seismic effect "can be analysed by the Mononobe-Okabe method". The minimum safety factors are in Table 5 (p. 37).
#: **NEC-SE-GC 2023 draft (unofficial).** §8.3.9 (p. 143-145): walls by Mononobe-Okabe, Table 8.6, **only dry cohesionless backfills** and not valid if there is liquefaction. The coefficient is different: k_{h} = a_{max}·F_{top}·F_{d}, with a_{max} = Z, F_{top} = 1.0 if the slope is less than 15° and **F_{d}** the wall factor, Table 8.7: 0.7 (basement wall or one that supports the building, at rest), 0.5 (supports the foundation of a building, displacement less than 25 mm), 0.4 (protects the building from a landslide) and 0.3 (roads, networks or other works, or H* of 3 m or more). In addition, the draft changes to **partial factors** (Tables 8.4 and 8.5, p. 142): sliding resistance ×0.80 (wall on soil) or ×0.90 (soil on soil), active thrust ×1.50, overturning ΣM_{r}/ΣM_{a} between 1.50 and 1.35.
#: **k_{v}.** NEC-SE-GC does not ask for it. NEC-SE-DS 2015, §3.4.2, sets the vertical earthquake component at no less than 2/3 of the horizontal, and the draft only says that k_{h} and k_{v} are the coefficients in each direction (Table 8.6) without giving a value. In GEO5, positive k_{v} is downward acceleration: the inertia **lifts** the wall and the wedge (unfavourable direction).

Z = 0.5 'seismic zone factor: Manabí is zone VI (NEC-SE-DS, table 1)
F_a = 1.12 'soil amplification coefficient, profile D, zone VI (NEC-SE-DS, table 3), the soil study writes 1.11 due to a crossing with Fd
F_top = 1 'topography factor of the draft: slope less than 15°
k_N = 0.6·Z·F_a 'k_h of NEC-15 = 0.6·Z·F_a
F_d = [0.7; 0.5; 0.4; 0.3] 'wall factor of the draft, Table 8.7
k_B = Z·F_top·F_d 'k_h of the draft = Z·F_top·F_d, for each F_d
#: With Z = 0.50 NEC-15 gives **0.336** and the draft gives **0.35, 0.25, 0.20 and 0.15** depending on the wall case: the draft asks for **less** earthquake except for the at-rest case (F_{d} = 0.7). The wall of the series (supports ground next to a road) falls in F_{d} = 0.3 or 0.4 depending on the work it protects: it must be justified.
k_v_N = 2/3·k_N 'k_v of NEC-SE-DS §3.4.2: 2/3 of the horizontal component

## 2 · Wall and soil data (the same ones loaded in GEO5)

x_p = 0.0 'toe: from the tip to the front face of the stem [m] (0 = L-shaped wall)'
b_t = 0.25 'stem thickness at the crest [m]
H_f = 2.6 'stem height above the footing [m]
b_b = b_t 'stem thickness at the bottom [m] (vertical stem)
x_t = x_p + b_b 'abscissa of the back face of the stem, vertical [m]
L_t = 1.9 'heel: projection behind the stem [m]
B_z = x_t + L_t 'footing width [m]
h_z = 0.4 'footing depth [m]
dk = 0.3 'shear key: depth below the bottom of the footing, x1 minus the depth [m]
d_w = 0.5 'shear key: width, flush with the end of the heel [m]
gam_c = 23 'unit weight of concrete [kN/m3]
g_1 = 18.5 'γ of SP sand [kN/m3]
f_1 = 30 'φ of SP sand [degrees]
g_2 = 17.5 'γ of silty SP-SM sand below 3.00 m [kN/m3]
f_2 = 29.97 'φ of the SP-SM, which is the base friction [degrees]
d_p = 20 'soil-structure friction δ on the face of the heel and of the shear key [degrees]
D_sp = 3 'depth where the SP sand ends [m]
Dat = [B_z; h_z; b_b; b_t; H_f; x_t; gam_c; dk; d_w; D_sp; g_1; f_1; g_2; f_2; d_p] 'the data together, to repeat the calculation with other k_h and k_v
#: Coulomb K with the GEO5 branch (binary, 0xD9C4C8), angles in radians: K = cos²(φ−α) / (cos²α · cos(α+δ) · (1+√R)²), R = sin(φ+δ)·sin(φ−β) / (cos(α+δ)·cos(α−β)).
#hide
function K = Kc(f, d, a, b)
  R = max(sin(f + d)*sin(f - b)/(cos(a + d)*cos(a - b)), 0)
  K = cos(f - a)^2/(cos(a)^2*cos(a + d)*(1 + sqrt(R))^2)
end
#show
#hide
function R = muro(Dat, k_h, k_v)
  B_z = Dat(1)
  h_z = Dat(2)
  b_b = Dat(3)
  b_t = Dat(4)
  H_f = Dat(5)
  x_t = Dat(6)
  gam_c = Dat(7)
  dk = Dat(8)
  d_w = Dat(9)
  D_sp = Dat(10)
  g_1 = Dat(11)
  f_1 = Dat(12)
  g_2 = Dat(13)
  f_2 = Dat(14)
  d_p = Dat(15)
  r_ = pi/180
  th = pi/4 + f_1*r_/2
  x_v = B_z - H_f/tan(th)
  H_t = h_z + H_f
  A_z = B_z*h_z + d_w*dk
  W_z = gam_c*A_z
  x_z = (B_z*h_z*B_z/2 + d_w*dk*(B_z - d_w/2))/A_z
  y_z = (B_z*h_z*h_z/2 - d_w*dk*dk/2)/A_z
  A_f = (b_b + b_t)/2*H_f
  W_f = gam_c*A_f
  x_f = x_t - H_f*(b_b^2 + b_b*b_t + b_t^2)/6/A_f
  y_f = h_z + H_f*(b_b + 2*b_t)/(3*(b_b + b_t))
  W_m = W_z + W_f
  x_m = (W_z*x_z + W_f*x_f)/W_m
  y_m = (W_z*y_z + W_f*y_f)/W_m
  w_0 = B_z - x_t
  w_1 = x_v - x_t
  A_c = (w_0 + w_1)/2*H_f
  W_c = g_1*A_c
  x_c = x_t + H_f*(w_0^2 + w_0*w_1 + w_1^2)/6/A_c
  y_c = h_z + H_f*(w_0 + 2*w_1)/(3*(w_0 + w_1))
  psi = atan(k_h/(1 - k_v))
  esp_1 = H_f
  esp_2 = max(min(D_sp, H_t) - H_f, 0)
  esp_3 = H_t + dk - H_f - esp_2
  a_1 = pi/2 - th
  a_2 = 0
  a_3 = 0
  ph_1 = f_1*r_
  ph_2 = f_1*r_
  ph_3 = f_2*r_
  dd_1 = ph_1
  dd_2 = d_p*r_
  dd_3 = d_p*r_
  dK_1 = dd_1 - 0.0001
  dK_2 = dd_2
  dK_3 = dd_3
  gl_1 = g_1
  gl_2 = g_1
  gl_3 = g_2
  Ka_1 = Kc(ph_1, dK_1, a_1, 0)
  Ka_2 = Kc(ph_2, dK_2, a_2, 0)
  Ka_3 = Kc(ph_3, dK_3, a_3, 0)
  Kae_1 = Kc(ph_1, dK_1, a_1 + psi, psi)*cos(a_1 + psi)^2/(cos(psi)*cos(a_1)^2)
  Kae_2 = Kc(ph_2, dK_2, a_2 + psi, psi)*cos(a_2 + psi)^2/(cos(psi)*cos(a_2)^2)
  Kae_3 = Kc(ph_3, dK_3, a_3 + psi, psi)*cos(a_3 + psi)^2/(cos(psi)*cos(a_3)^2)
  w_a1 = esp_1*gl_1
  w_a2 = esp_2*gl_2
  w_a3 = esp_3*gl_3
  sa_1 = 0
  sb_1 = w_a1
  sa_2 = sb_1
  sb_2 = sa_2 + w_a2
  sa_3 = sb_2
  sb_3 = sa_3 + w_a3
  zz_1 = 0
  zz_2 = esp_1
  zz_3 = esp_1 + esp_2
  pa_1 = Ka_1*sa_1
  pb_1 = Ka_1*sb_1
  pa_2 = Ka_2*sa_2
  pb_2 = Ka_2*sb_2
  pa_3 = Ka_3*sa_3
  pb_3 = Ka_3*sb_3
  F_1 = (pa_1 + pb_1)/2*esp_1
  F_2 = (pa_2 + pb_2)/2*esp_2
  F_3 = (pa_3 + pb_3)/2*esp_3
  zc_1 = zz_1 + esp_1*(pa_1 + 2*pb_1)/(3*max(pa_1 + pb_1, 0.000000001))
  zc_2 = zz_2 + esp_2*(pa_2 + 2*pb_2)/(3*max(pa_2 + pb_2, 0.000000001))
  zc_3 = zz_3 + esp_3*(pa_3 + 2*pb_3)/(3*max(pa_3 + pb_3, 0.000000001))
  E_x = F_1*cos(a_1 + dd_1) + F_2*cos(a_2 + dd_2) + F_3*cos(a_3 + dd_3)
  E_z = F_1*sin(a_1 + dd_1) + F_2*sin(a_2 + dd_2) + F_3*sin(a_3 + dd_3)
  E_xx = (F_1*sin(a_1 + dd_1)*(x_v + zc_1/tan(th)) + F_2*sin(a_2 + dd_2)*B_z + F_3*sin(a_3 + dd_3)*B_z)/E_z
  E_y = (F_1*cos(a_1 + dd_1)*(H_t - zc_1) + F_2*cos(a_2 + dd_2)*(H_t - zc_2) + F_3*cos(a_3 + dd_3)*(H_t - zc_3))/E_x
  ws_1 = (1 - k_v)*w_a1
  ws_2 = (1 - k_v)*w_a2
  ws_3 = (1 - k_v)*w_a3
  ta_1 = ws_1 + ws_2 + ws_3
  tb_1 = ta_1 - ws_1
  ta_2 = tb_1
  tb_2 = ta_2 - ws_2
  ta_3 = tb_2
  tb_3 = ta_3 - ws_3
  qa_1 = (Kae_1 - Ka_1)*ta_1
  qb_1 = (Kae_1 - Ka_1)*tb_1
  qa_2 = (Kae_2 - Ka_2)*ta_2
  qb_2 = (Kae_2 - Ka_2)*tb_2
  qa_3 = (Kae_3 - Ka_3)*ta_3
  qb_3 = (Kae_3 - Ka_3)*tb_3
  G_1 = (qa_1 + qb_1)/2*esp_1
  G_2 = (qa_2 + qb_2)/2*esp_2
  G_3 = (qa_3 + qb_3)/2*esp_3
  zs_1 = zz_1 + esp_1*(qa_1 + 2*qb_1)/(3*max(qa_1 + qb_1, 0.000000001))
  zs_2 = zz_2 + esp_2*(qa_2 + 2*qb_2)/(3*max(qa_2 + qb_2, 0.000000001))
  zs_3 = zz_3 + esp_3*(qa_3 + 2*qb_3)/(3*max(qa_3 + qb_3, 0.000000001))
  S_x = G_1*cos(a_1 + dd_1) + G_2*cos(a_2 + dd_2) + G_3*cos(a_3 + dd_3)
  S_z = G_1*sin(a_1 + dd_1) + G_2*sin(a_2 + dd_2) + G_3*sin(a_3 + dd_3)
  S_xx = (G_1*sin(a_1 + dd_1)*(x_v + zs_1/tan(th)) + G_2*sin(a_2 + dd_2)*B_z + G_3*sin(a_3 + dd_3)*B_z)/max(S_z, 0.000000001)
  S_y = (G_1*cos(a_1 + dd_1)*(H_t - zs_1) + G_2*cos(a_2 + dd_2)*(H_t - zs_2) + G_3*cos(a_3 + dd_3)*(H_t - zs_3))/max(S_x, 0.000000001)
  M_res = (1 - k_v)*(W_m*x_m + W_c*x_c) + E_z*E_xx + S_z*S_xx
  M_ovr = k_h*(W_m*y_m + W_c*y_c) + E_x*E_y + S_x*S_y
  N_v = (1 - k_v)*(W_m + W_c) + E_z + S_z
  H_h = k_h*(W_m + W_c) + E_x + S_x
  eps_b = atan(dk/B_z)
  H_res = (N_v*cos(eps_b) + H_h*sin(eps_b))*tan(f_2*r_)
  T_ac = H_h*cos(eps_b) - N_v*sin(eps_b)
  FS_v = M_res/M_ovr
  FS_d = H_res/T_ac
  R = [FS_v; FS_d; M_res; M_ovr]
end
#show

## 3 · The calculation with NEC-15 k_h and k_v = 0 (the GEO5 base case)

#: Each line carries its description: weights and centres of gravity, the three layers of the thrust face, K_{a} and K_{ae} per layer, the static and seismic trapezoids, and at the end the moments and the safety factors.
k_h = k_N 'k_h of NEC-15, 0.6·Z·F_a
k_v = 0 'k_v of the GEO5 base case
r_ = pi/180 'from degrees to radians
th = pi/4 + f_1*r_/2 'angle of the virtual face above the horizontal [rad]
x_v = B_z - H_f/tan(th) 'abscissa where the virtual face cuts the ground [m]
H_t = h_z + H_f 'elevation of the ground above the bottom of the footing [m]
A_z = B_z*h_z + d_w*dk 'area of the footing with its shear key [m2]
W_z = gam_c*A_z 'footing weight [kN/m]
x_z = (B_z*h_z*B_z/2 + d_w*dk*(B_z - d_w/2))/A_z 'abscissa of its centre of gravity [m]
y_z = (B_z*h_z*h_z/2 - d_w*dk*dk/2)/A_z 'elevation of its centre of gravity [m]
A_f = (b_b + b_t)/2*H_f 'stem area [m2]
W_f = gam_c*A_f 'stem weight [kN/m]
x_f = x_t - H_f*(b_b^2 + b_b*b_t + b_t^2)/6/A_f 'abscissa of its centre of gravity [m]
y_f = h_z + H_f*(b_b + 2*b_t)/(3*(b_b + b_t)) 'elevation of its centre of gravity [m]
W_m = W_z + W_f 'wall weight [kN/m]
x_m = (W_z*x_z + W_f*x_f)/W_m 'abscissa of the wall centre of gravity [m]
y_m = (W_z*y_z + W_f*y_f)/W_m 'elevation of the wall centre of gravity [m]
w_0 = B_z - x_t 'width of the earth wedge at the bottom [m]
w_1 = x_v - x_t 'width of the wedge at the top [m]
A_c = (w_0 + w_1)/2*H_f 'wedge area [m2]
W_c = g_1*A_c 'wedge weight [kN/m]
x_c = x_t + H_f*(w_0^2 + w_0*w_1 + w_1^2)/6/A_c 'abscissa of its centre of gravity [m]
y_c = h_z + H_f*(w_0 + 2*w_1)/(3*(w_0 + w_1)) 'elevation of its centre of gravity [m]
psi = atan(k_h/(1 - k_v)) 'earthquake angle ψ = atan(kh/(1 - kv)) [rad]
esp_1 = H_f 'layer 1: the virtual face, from the crest to the height of the stem [m]
esp_2 = max(min(D_sp, H_t) - H_f, 0) 'layer 2: the heel face, in the SP sand [m]
esp_3 = H_t + dk - H_f - esp_2 'layer 3: the shear key, in the silty SP-SM sand [m]
a_1 = pi/2 - th 'inclination of the virtual face from the vertical [rad]
a_2 = 0 'the heel face is vertical
a_3 = 0 'the shear key face is vertical
ph_1 = f_1*r_ 'φ of layer 1 [rad]
ph_2 = f_1*r_ 'φ of layer 2 [rad]
ph_3 = f_2*r_ 'φ of layer 3 [rad]
dd_1 = ph_1 'δ of the virtual face = φ (soil against soil) [rad]
dd_2 = d_p*r_ 'δ of the heel face [rad]
dd_3 = d_p*r_ 'δ of the shear key face [rad]
dK_1 = dd_1 - 0.0001 'δ only to compute K: GEO5 clips it to φ - 1e-4 (0xD9D978) [rad]
dK_2 = dd_2 'δ for K, layer 2 [rad]
dK_3 = dd_3 'δ for K, layer 3 [rad]
gl_1 = g_1 'γ of layer 1 [kN/m3]
gl_2 = g_1 'γ of layer 2 [kN/m3]
gl_3 = g_2 'γ of layer 3 [kN/m3]
Ka_1 = Kc(ph_1, dK_1, a_1, 0) 'Coulomb K_a, layer 1
Ka_2 = Kc(ph_2, dK_2, a_2, 0) 'Coulomb K_a, layer 2
Ka_3 = Kc(ph_3, dK_3, a_3, 0) 'Coulomb K_a, layer 3
Kae_1 = Kc(ph_1, dK_1, a_1 + psi, psi)*cos(a_1 + psi)^2/(cos(psi)*cos(a_1)^2) 'Mononobe-Okabe K_ae, layer 1
Kae_2 = Kc(ph_2, dK_2, a_2 + psi, psi)*cos(a_2 + psi)^2/(cos(psi)*cos(a_2)^2) 'K_ae, layer 2
Kae_3 = Kc(ph_3, dK_3, a_3 + psi, psi)*cos(a_3 + psi)^2/(cos(psi)*cos(a_3)^2) 'K_ae, layer 3
w_a1 = esp_1*gl_1 'weight per m2 of layer 1 [kPa]
w_a2 = esp_2*gl_2 'weight of layer 2 [kPa]
w_a3 = esp_3*gl_3 'weight of layer 3 [kPa]
sa_1 = 0 'σv of layer 1 top: the STATIC thrust accumulates FROM THE TOP [kPa]
sb_1 = w_a1 'σv of layer 1 bottom [kPa]
sa_2 = sb_1 'σv of layer 2 top [kPa]
sb_2 = sa_2 + w_a2 'σv of layer 2 bottom [kPa]
sa_3 = sb_2 'σv of layer 3 top [kPa]
sb_3 = sa_3 + w_a3 'σv of layer 3 bottom [kPa]
zz_1 = 0 'depth of the top of layer 1 [m]
zz_2 = esp_1 'depth of the top of layer 2 [m]
zz_3 = esp_1 + esp_2 'depth of the top of layer 3 [m]
pa_1 = Ka_1*sa_1 'static Δσ, layer 1 top [kPa]
pb_1 = Ka_1*sb_1 'static Δσ, layer 1 bottom [kPa]
pa_2 = Ka_2*sa_2 'static Δσ, layer 2 top [kPa]
pb_2 = Ka_2*sb_2 'static Δσ, layer 2 bottom [kPa]
pa_3 = Ka_3*sa_3 'static Δσ, layer 3 top [kPa]
pb_3 = Ka_3*sb_3 'static Δσ, layer 3 bottom [kPa]
F_1 = (pa_1 + pb_1)/2*esp_1 'trapezoid force, layer 1 [kN/m]
F_2 = (pa_2 + pb_2)/2*esp_2 'trapezoid force, layer 2 [kN/m]
F_3 = (pa_3 + pb_3)/2*esp_3 'trapezoid force, layer 3 [kN/m]
zc_1 = zz_1 + esp_1*(pa_1 + 2*pb_1)/(3*max(pa_1 + pb_1, 0.000000001)) 'depth of the resultant, layer 1 [m]
zc_2 = zz_2 + esp_2*(pa_2 + 2*pb_2)/(3*max(pa_2 + pb_2, 0.000000001)) 'depth of the resultant, layer 2 [m]
zc_3 = zz_3 + esp_3*(pa_3 + 2*pb_3)/(3*max(pa_3 + pb_3, 0.000000001)) 'depth of the resultant, layer 3 [m]
E_x = F_1*cos(a_1 + dd_1) + F_2*cos(a_2 + dd_2) + F_3*cos(a_3 + dd_3) 'horizontal active thrust, Fx [kN/m]
E_z = F_1*sin(a_1 + dd_1) + F_2*sin(a_2 + dd_2) + F_3*sin(a_3 + dd_3) 'vertical active thrust, Fz [kN/m]
E_xx = (F_1*sin(a_1 + dd_1)*(x_v + zc_1/tan(th)) + F_2*sin(a_2 + dd_2)*B_z + F_3*sin(a_3 + dd_3)*B_z)/E_z 'abscissa of application (weighted by Fz) [m]
E_y = (F_1*cos(a_1 + dd_1)*(H_t - zc_1) + F_2*cos(a_2 + dd_2)*(H_t - zc_2) + F_3*cos(a_3 + dd_3)*(H_t - zc_3))/E_x 'elevation of application (weighted by Fx) [m]
ws_1 = (1 - k_v)*w_a1 'weight of layer 1 with the earthquake vertical [kPa]
ws_2 = (1 - k_v)*w_a2 'weight of layer 2 [kPa]
ws_3 = (1 - k_v)*w_a3 'weight of layer 3 [kPa]
ta_1 = ws_1 + ws_2 + ws_3 'σv′ of layer 1 top: the SEISMIC increment accumulates FROM THE BOTTOM (inverted triangle) [kPa]
tb_1 = ta_1 - ws_1 'σv′ of layer 1 bottom [kPa]
ta_2 = tb_1 'σv′ of layer 2 top [kPa]
tb_2 = ta_2 - ws_2 'σv′ of layer 2 bottom [kPa]
ta_3 = tb_2 'σv′ of layer 3 top [kPa]
tb_3 = ta_3 - ws_3 'σv′ of layer 3 bottom [kPa]
qa_1 = (Kae_1 - Ka_1)*ta_1 'seismic Δσ, layer 1 top [kPa]
qb_1 = (Kae_1 - Ka_1)*tb_1 'seismic Δσ, layer 1 bottom [kPa]
qa_2 = (Kae_2 - Ka_2)*ta_2 'seismic Δσ, layer 2 top [kPa]
qb_2 = (Kae_2 - Ka_2)*tb_2 'seismic Δσ, layer 2 bottom [kPa]
qa_3 = (Kae_3 - Ka_3)*ta_3 'seismic Δσ, layer 3 top [kPa]
qb_3 = (Kae_3 - Ka_3)*tb_3 'seismic Δσ, layer 3 bottom [kPa]
G_1 = (qa_1 + qb_1)/2*esp_1 'seismic force of the trapezoid, layer 1 [kN/m]
G_2 = (qa_2 + qb_2)/2*esp_2 'seismic force, layer 2 [kN/m]
G_3 = (qa_3 + qb_3)/2*esp_3 'seismic force, layer 3 [kN/m]
zs_1 = zz_1 + esp_1*(qa_1 + 2*qb_1)/(3*max(qa_1 + qb_1, 0.000000001)) 'depth of the seismic resultant, layer 1 [m]
zs_2 = zz_2 + esp_2*(qa_2 + 2*qb_2)/(3*max(qa_2 + qb_2, 0.000000001)) 'depth, layer 2 [m]
zs_3 = zz_3 + esp_3*(qa_3 + 2*qb_3)/(3*max(qa_3 + qb_3, 0.000000001)) 'depth, layer 3 [m]
S_x = G_1*cos(a_1 + dd_1) + G_2*cos(a_2 + dd_2) + G_3*cos(a_3 + dd_3) 'seismic increment of the thrust, Fx [kN/m]
S_z = G_1*sin(a_1 + dd_1) + G_2*sin(a_2 + dd_2) + G_3*sin(a_3 + dd_3) 'seismic increment, Fz [kN/m]
S_xx = (G_1*sin(a_1 + dd_1)*(x_v + zs_1/tan(th)) + G_2*sin(a_2 + dd_2)*B_z + G_3*sin(a_3 + dd_3)*B_z)/max(S_z, 0.000000001) 'abscissa of application [m]
S_y = (G_1*cos(a_1 + dd_1)*(H_t - zs_1) + G_2*cos(a_2 + dd_2)*(H_t - zs_2) + G_3*cos(a_3 + dd_3)*(H_t - zs_3))/max(S_x, 0.000000001) 'elevation of application [m]
M_res = (1 - k_v)*(W_m*x_m + W_c*x_c) + E_z*E_xx + S_z*S_xx 'resisting moment about the tip of the footing [kN·m/m]
M_ovr = k_h*(W_m*y_m + W_c*y_c) + E_x*E_y + S_x*S_y 'overturning moment [kN·m/m]
N_v = (1 - k_v)*(W_m + W_c) + E_z + S_z 'vertical resultant [kN/m]
H_h = k_h*(W_m + W_c) + E_x + S_x 'horizontal resultant [kN/m]
eps_b = atan(dk/B_z) 'inclination of the base, from the bottom of the toe to the bottom of the shear key [rad]
H_res = (N_v*cos(eps_b) + H_h*sin(eps_b))*tan(f_2*r_) 'sliding resistance force on the inclined base [kN/m]
T_ac = H_h*cos(eps_b) - N_v*sin(eps_b) 'acting force along the base [kN/m]
FS_v = M_res/M_ovr 'safety factor against OVERTURNING
FS_d = H_res/T_ac 'safety factor against SLIDING

### The wall drawn with its thrusts

#: **The drawing, read calmly.** It is the section of the wall to scale, in metres, with the dimensions of the geometry. **Grey with hatching:** the concrete (footing, stem and shear key). **Faint green:** the earth wedge that pushes; its inclined face is the **virtual face**, the plane that leaves the end of the heel at 45° + φ/2 above the horizontal. **Blue:** the **static** thrust of each layer (1 m of arrow = 25 kPa), which grows with depth (it accumulates from the top). **Red:** the Mononobe-Okabe **seismic increment**, which is an **inverted triangle**: it is maximum at the top and vanishes at the bottom, because it accumulates with the weight of the soil that lies BELOW each point. The dashed horizontal line marks where the SP sand changes to SP-SM.
q_1 = pa_1/25 'static thrust, layer 1 top, at drawing scale
q_2 = pb_1/25 'static thrust, layer 1 bottom
q_3 = pa_2/25 'static thrust, layer 2 top
q_4 = pb_2/25 'static thrust, layer 2 bottom
u_1 = qa_1/25 'seismic increment, layer 1 top
u_2 = qb_1/25 'seismic increment, layer 1 bottom
u_3 = qa_2/25 'seismic increment, layer 2 top
u_4 = qb_2/25 'seismic increment, layer 2 bottom
q_5 = pa_3/25 'static thrust, layer 3 (shear key) top
q_6 = pb_3/25 'static thrust, layer 3 (shear key) bottom
u_5 = qa_3/25 'seismic increment, layer 3 top
u_6 = qb_3/25 'seismic increment, layer 3 bottom
#dibujo("L wall with shear key: concrete, earth wedge, virtual face and static thrust (blue) and seismic increment (red), 1 m = 25 kPa", ud = m, escala = auto, cotas = m, alto = 220)
#  poligono(0, 0, B_z - d_w, 0, B_z - d_w, -dk, B_z, -dk, B_z, h_z, x_t, h_z, x_t, H_t, x_t - b_t, H_t, x_p, h_z, 0, h_z, "gruesa")
#  achurado(0, 0, B_z, h_z, "concreto")
#  achurado(B_z - d_w, -dk, B_z, 0, "concreto")
#  poligono(x_t, h_z, B_z, h_z, x_v, H_t, x_t, H_t, "verde tenue")
#  linea(x_v, H_t, B_z, h_z, "trazos verde")
#  linea(x_t, H_t, B_z + 3, H_t, "media verde")
#  linea(-1.2, h_z, 0, h_z, "media verde")
#  linea(-1.2, 0, B_z + 3, 0, "trazos")
#  texto(B_z + 1.6, 2.2, "SP sand: γ 18.5, φ 30°", 2.5, "i")
#  texto(B_z + 1.6, -0.5, "SP-SM silty sand: γ 17.5, φ 29.97°", 2.5, "i")
#  texto((x_t + B_z)/2, 1.4, "cuña", 2.5, "c")
#  carga(x_v, H_t, B_z, h_z, q_1, q_2, "", "azul", n = 5)
#  carga(B_z, h_z, B_z, 0, q_3, q_4, "", "azul", n = 3)
#  carga(x_v, H_t, B_z, h_z, u_1, u_2, "", "rojo", n = 5)
#  carga(B_z, h_z, B_z, 0, u_3, u_4, "", "rojo", n = 3)
#  carga(B_z, 0, B_z, -dk, q_5, q_6, "", "azul", n = 2)
#  carga(B_z, 0, B_z, -dk, u_5, u_6, "", "rojo", n = 2)
#  cota(0, -1.00, B_z, -1.00, -0.1, "2.15")
#  cota(-0.6, 0, -0.6, h_z, 0.1, "0.40")
#  cota(-0.6, h_z, -0.6, H_t, 0.1, "2.60")
#  cota(x_t, H_t + 0.5, x_t - b_t, H_t + 0.5, 0.1, "0.25")
#  cota(x_t, H_t + 1.1, B_z, H_t + 1.1, 0.1, "1.90")
#  cota(B_z - d_w - 0.35, 0, B_z - d_w - 0.35, -dk, 0.1, "0.30")
#  cota(B_z - d_w, -dk - 0.3, B_z, -dk - 0.3, -0.1, "0.50")
#fin
#: **How to read it.** The dimensions give the footing width (2.15 m), the depth (0.40 m), the stem height (2.60 m), its thickness at the crest (0.25 m) and the heel (1.90 m), with no toe (**L** wall), and the shear key (0.50 m wide × 0.30 m deep). The resultant of each diagram (blue and red) is what is added in the table of section 4: the **static** one acts at a third of the height of each layer; the **seismic** one higher, because its diagram is an inverted triangle. In **overturning** those forces rotate the wall about the tip of the footing (the origin of the drawing); in **sliding**, the base is **inclined**: it goes down to the bottom of the shear key, and that is why it resists more.

## 4 · Against GEO5: weight, thrust, seismic increment, overturning and sliding

#: The GEO5 safety factors come from the GEO5 utilisation percentages (2.0/1.239 and 1.05/0.638). Rows: wall weight; static thrust Fx, Fz, x, y; seismic increment Fx, Fz, x, y; FS against overturning; FS against sliding. The difference must stay under 0.01 (in Fz of the seismic increment, under 0.03).
H_v = [W_m; E_x; E_z; E_xx; E_y; S_x; S_z; S_xx; S_y; FS_v; FS_d] 'Hekatan values
G_v = [38.18; 31.51; 39.98; 1.7; 0.85; 45.61; 77.16; 1.24; 1.93; 1.6142; 1.6458] 'GEO5 values
Dif = H_v - G_v 'difference Hekatan - GEO5
Rf = muro(Dat, k_h, k_v) 'the same verification with the function: it must give the same FS

## 5 · NEC-15 and draft k_h: how much do overturning and sliding change

#: The calculation is repeated for k_{h} = 0 (no earthquake), three values of the draft (F_{d} = 0.3, 0.4, 0.5), the NEC-15 one and the draft one with F_{d} = 0.7, always with k_{v} = 0. With **less** earthquake the wall **improves**: the draft is more permissive than NEC-15 except in the at-rest case (F_{d} = 0.7). Columns: k_{h}, FS against overturning, FS against sliding.
kh_l = [0; 0.15; 0.2; 0.25; 0.336; 0.35] 'k_h tested
#hide
Rl = zeros(6, 3)
for j = 1:6
  Rj = muro(Dat, kh_l(j), 0)
  Rl(j, 1) = kh_l(j)
  Rl(j, 2) = Rj(1)
  Rl(j, 3) = Rj(2)
end
#show
Res_l = Rl 'k_h, FS overturning, FS sliding

## 6 · Plot: safety factors against k_h

#: The Hekatan points come from the layered calculation repeated for 9 values of k_{h}; the GEO5 point is its result with k_{h} = 0.336.
#hide
Pv = zeros(9, 2)
Pd = zeros(9, 2)
for j = 1:9
  Rg = muro(Dat, 0.05*j, 0)
  Pv(j, 1) = 0.05*j
  Pv(j, 2) = Rg(1)
  Pd(j, 1) = 0.05*j
  Pd(j, 2) = Rg(2)
end
#show
#fplot(Vuelco = Pv, Deslizamiento = Pd, GEO5v = [0.336 1.6142], GEO5d = [0.336 1.6458], [0 0.46])

## 7 · Conclusion

#: The **L wall with shear key** comes out the same as GEO5 in weight, static thrust, seismic increment and safety factors: the algorithm is that of the binary, not an adjustment. What it does **not** yet cover (it must be measured in GEO5 before adding it): surcharge, water table, resistance in front of the toe, cohesion, ledges, stem inclined at the back, shear key separated from the end, bearing capacity and reinforcement.
