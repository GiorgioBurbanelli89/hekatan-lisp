# Manabí cantilever wall: Coulomb thrust and Mononobe-Okabe earthquake against GEO5 Cantilever Wall
#numerico

#: **What is computed.** The T-shaped cantilever wall of Portoviejo (Manabí), on the soil of the Los Arenales soil study (TSN-ES-2025-206): SP sand (γ 18.5 kN/m³, φ 30°) down to 3.00 m and silty SP-SM sand (γ 17.5, φ 29.97°) below. **Coulomb** active thrust, **Mononobe-Okabe** pseudo-static earthquake with k_{h} from NEC-SE-GC, and the safety factors against **overturning** and **sliding**.
#: **Algorithm.** That of GEO5 Cantilever Wall, taken from its binary (CantileverWall_5.dll, disassembly and debugging with Frida): the thrust face is the **virtual face** (plane from the end of the heel at 45° + φ/2) plus the **vertical face of the heel**. The static thrust accumulates σ_{v} **from the top**; the seismic increment accumulates σ_{v} **from the bottom** (inverted triangle).
#: **Judge.** GEO5 Cantilever Wall 2024 with the same wall (file muro_portoviejo_01.guz): overturning **2.71**, sliding **1.20**. The sheet is linear (no loops or multi-line functions): it runs the same in **Hekatan Math Studio** (WPF and web) and in **Hekatan LISP** (WPF and web).
#: **Units.** kN, m and kPa per metre of wall. Abscissa x from the tip of the toe toward the backfill; elevation y from the bottom of the footing. Angles in the data in degrees; inside the formulas, in radians.

## 1 · Manabí earthquake according to the NEC

#: NEC-SE-GC §4.2.2: "the seismic demand for pseudo-static analyses will be 60 % of the maximum acceleration on the ground", k_{h} = 0.6·Z·F_{a}. Manabí is zone VI (Z = 0.50), profile D (F_{a} = 1.12, NEC-SE-DS table 3). k_{v} = 0, the GEO5 base case.
Z = 0.5 'seismic zone factor, zone VI
F_a = 1.12 'soil amplification, profile D
k_h = 0.6*Z*F_a 'horizontal seismic coefficient
k_v = 0 'vertical seismic coefficient (base case)

## 2 · Wall and soil data (the same as in GEO5)

#dibujo("The wall with these data", ud = m, escala = auto, cotas = m, alto = 120, lado = derecha)
#  poligono(0, 0, B_z, 0, B_z, h_z, x_t, h_z, x_t, h_z + H_f, x_t - b_t, h_z + H_f, x_p, h_z, 0, h_z, "gruesa")
#  achurado(0, 0, B_z, h_z, "concreto")
#  linea(x_t, h_z + H_f, B_z + 1.2, h_z + H_f, "media verde")
#  linea(-0.8, h_z, 0, h_z, "media verde")
#  texto(B_z - 0.5, h_z + H_f/2, "SP sand", 2.5, "i")
#  cota(0, -0.35, x_p, -0.35, 0)
#  cota(x_t, -0.35, B_z, -0.35, 0)
#  cota(-0.45, 0, -0.45, h_z, 0)
#  cota(-0.45, h_z, -0.45, h_z + H_f, 0)
#  cota(x_t - b_t, h_z + H_f + 0.35, x_t, h_z + H_f + 0.35, 0)
#fin
#: Toe: from the tip to the face of the stem [m].
x_p = 0.7
#: Stem thickness at the crest [m].
b_t = 0.25
#: Stem height above the footing [m].
H_f = 2.6
#: Stem at the bottom (batter 1:17.33) [m].
b_b = b_t + H_f/17.33
#: Abscissa of the back face of the stem [m].
x_t = x_p + b_b
#: Heel behind the stem [m].
L_t = 1.9
#: Footing width [m].
B_z = x_t + L_t
#: Footing depth [m].
h_z = 0.4
#: Unit weight of concrete [kN/m3].
gamma_c = 23
#: γ of SP sand [kN/m3].
gamma_1 = 18.5
#: φ of SP sand [degrees].
phi_1 = 30
#: φ of the SP-SM below 3.00 m: it is the base friction [degrees].
phi_2 = 29.97
#: δ soil-concrete on the face of the heel [degrees].
delta_p = 20
#: Dimensions in m, taken from the data: if you change one, the drawing changes. Grey: concrete; green: the ground, which reaches the crest behind the wall and the face of the footing in front.

## 3 · Coulomb and Mononobe-Okabe

#: **Coulomb** (GEO5 branch), with α the inclination of the face from the vertical, β that of the ground and δ the friction: K = cos²(φ−α) / [cos²α · cos(α+δ) · (1+√R)²], R = sin(φ+δ)·sin(φ−β) / [cos(α+δ)·cos(α−β)].
#: **Mononobe-Okabe**: it is Coulomb with everything rotated by the earthquake angle ψ = atan(k_{h}/(1−k_{v})): K_{ae} = K(φ, δ, α+ψ, β+ψ) · cos²(α+ψ) / (cos ψ · cos²α).
Kc(phi, delta, alpha, beta) = cos(phi - alpha)^2/(cos(alpha)^2*cos(alpha + delta)*(1 + sqrt(max(sin(phi + delta)*sin(phi - beta)/(cos(alpha + delta)*cos(alpha - beta)), 0)))^2)
rad = pi/180 'from degrees to radians
psi = atan(k_h/(1 - k_v)) 'earthquake angle ψ [rad]
#: **The angle of the virtual face as GEO5 finds it.** Theory gives α = 45° − φ/2 from the vertical (θ = 45° + φ/2 above the horizontal). GEO5 does not use that formula: it **searches for it by bisection between 0° and 90°** and keeps the **midpoint number 15**, that is, the centre of the cell of width 90°/2^{14} that contains the exact value. Measured with Frida in CantileverWall_5.dll on 20-Nov-2026 with φ = 27, 30, 33, 34.5 and 36: all five cases follow the rule. With φ = 30° it gives α = 30.000915527…° instead of 30°; with exactly 30°, F_{z} of the thrust deviates 0.0013 and the seismic increment 0.004.
a_ex = 45 - phi_1/2 'exact α of the theory [degrees]
a_G = 90/16384*(floor(16384*a_ex/90) + 0.5) 'GEO5 α: midpoint 15 of the bisection in [0°, 90°] [degrees]
alpha_1 = a_G*rad 'inclination of the virtual face from the vertical [rad]
theta = pi/2 - alpha_1 'angle of the virtual face above the horizontal [rad]
phi = phi_1*rad 'φ of SP sand [rad]
delta_1 = phi 'δ on the virtual face = φ (soil against soil) [rad]
delta_K = delta_1 - 0.0001 'δ for K: GEO5 clips it to φ − 1e-4 (binary, 0xD9D978) [rad]
delta_2 = delta_p*rad 'δ on the heel face [rad]
Ka_1 = Kc(phi, delta_K, alpha_1, 0) 'Coulomb K_a, virtual face
Ka_2 = Kc(phi, delta_2, 0, 0) 'Coulomb K_a, heel face
Kae_1 = Kc(phi, delta_K, alpha_1 + psi, psi)*cos(alpha_1 + psi)^2/(cos(psi)*cos(alpha_1)^2) 'Mononobe-Okabe K_ae, virtual face
Kae_2 = Kc(phi, delta_2, psi, psi)*cos(psi)^2/cos(psi) 'K_ae, heel face

## 4 · Weights and centres of gravity

H_t = h_z + H_f 'total height [m]
x_v = B_z - H_f/tan(theta) 'abscissa where the virtual face cuts the ground [m]
W_z = gamma_c*B_z*h_z 'footing weight [kN/m]
A_f = (b_b + b_t)/2*H_f 'stem area [m2]
W_f = gamma_c*A_f 'stem weight [kN/m]
x_f = x_t - H_f*(b_b^2 + b_b*b_t + b_t^2)/6/A_f 'abscissa of the stem c.g. [m]
y_f = h_z + H_f*(b_b + 2*b_t)/(3*(b_b + b_t)) 'elevation of the stem c.g. [m]
W_m = W_z + W_f 'wall weight [kN/m]
x_m = (W_z*B_z/2 + W_f*x_f)/W_m 'abscissa of the wall c.g. [m]
y_m = (W_z*h_z/2 + W_f*y_f)/W_m 'elevation of the wall c.g. [m]
w_0 = B_z - x_t 'width of the earth wedge at the bottom [m]
#: **The GEO5 wedge.** Its inclined side uses the same α from the bisection, but GEO5 shifts the top point **1e-5 m** toward the backfill (an internal tolerance): with that its weight and its centre of gravity come out equal to the binary bit by bit (Frida: W = 55.287195935578424, x from the stem 0.6563994871255965, z from the top 1.5829687446284182).
w_1 = L_t - H_f*tan(alpha_1) + 0.00001 'width of the wedge at the top, as GEO5 [m]
A_c = (w_0 + w_1)/2*H_f 'area of the wedge over the heel [m2]
W_c = gamma_1*A_c 'wedge weight [kN/m]
x_c = x_t + H_f*(w_0^2 + w_0*w_1 + w_1^2)/6/A_c 'abscissa of its c.g. [m]
y_c = h_z + H_f*(w_0 + 2*w_1)/(3*(w_0 + w_1)) 'elevation of its c.g. [m]

## 5 · Static thrust (from the top) and seismic increment (from the bottom)

#: Two layers: **1** is the virtual face (height H_{f}); **2** is the heel face (height h_{z}), which stays in the SP sand because the wall is exactly 3.00 m.
s_1 = gamma_1*H_f 'σv at the foot of layer 1 [kPa]
s_2 = s_1 + gamma_1*h_z 'σv at the foot of layer 2 [kPa]
F_1 = Ka_1*s_1/2*H_f 'static thrust, layer 1: triangle [kN/m]
F_2 = Ka_2*(s_1 + s_2)/2*h_z 'static thrust, layer 2: trapezoid [kN/m]
zc_1 = 2*H_f/3 'depth of F_1 [m]
zc_2 = H_f + h_z*(s_1 + 2*s_2)/(3*(s_1 + s_2)) 'depth of F_2 [m]
E_x = F_1*cos(alpha_1 + delta_1) + F_2*cos(delta_2) 'horizontal active thrust [kN/m]
E_z = F_1*sin(alpha_1 + delta_1) + F_2*sin(delta_2) 'vertical active thrust [kN/m]
E_xx = (F_1*sin(alpha_1 + delta_1)*(x_v + zc_1/tan(theta)) + F_2*sin(delta_2)*B_z)/E_z 'abscissa of application [m]
E_y = (F_1*cos(alpha_1 + delta_1)*(H_t - zc_1) + F_2*cos(delta_2)*(H_t - zc_2))/E_x 'elevation of application [m]
#: The seismic increment uses σ_{v}′ measured **from the bottom**: at the top of layer 1 it equals the whole weight (s_{2}) and at the foot of layer 2 it is zero.
t_1 = (1 - k_v)*s_2 'σv′ at the top of layer 1 [kPa]
t_2 = (1 - k_v)*gamma_1*h_z 'σv′ at the foot of layer 1 = top of layer 2 [kPa]
G_1 = (Kae_1 - Ka_1)*(t_1 + t_2)/2*H_f 'seismic increment, layer 1 [kN/m]
G_2 = (Kae_2 - Ka_2)*t_2/2*h_z 'seismic increment, layer 2 [kN/m]
zs_1 = H_f*(t_1 + 2*t_2)/(3*(t_1 + t_2)) 'depth of G_1 [m]
zs_2 = H_f + h_z/3 'depth of G_2 [m]
S_x = G_1*cos(alpha_1 + delta_1) + G_2*cos(delta_2) 'horizontal seismic increment [kN/m]
S_z = G_1*sin(alpha_1 + delta_1) + G_2*sin(delta_2) 'vertical seismic increment [kN/m]
S_xx = (G_1*sin(alpha_1 + delta_1)*(x_v + zs_1/tan(theta)) + G_2*sin(delta_2)*B_z)/S_z 'abscissa of application [m]
S_y = (G_1*cos(alpha_1 + delta_1)*(H_t - zs_1) + G_2*cos(delta_2)*(H_t - zs_2))/S_x 'elevation of application [m]

## 6 · Overturning and sliding

#: Moments about the tip of the footing. The inertia of the wall and of the wedge (k_{h}·W) also overturns: classical Mononobe-Okabe omits it, GEO5 adds it.
M_res = (1 - k_v)*(W_m*x_m + W_c*x_c) + E_z*E_xx + S_z*S_xx 'resisting moment [kN·m/m]
M_ovr = k_h*(W_m*y_m + W_c*y_c) + E_x*E_y + S_x*S_y 'overturning moment [kN·m/m]
N_v = (1 - k_v)*(W_m + W_c) + E_z + S_z 'vertical resultant [kN/m]
H_h = k_h*(W_m + W_c) + E_x + S_x 'horizontal resultant [kN/m]
H_res = N_v*tan(phi_2*rad) 'sliding resistance [kN/m]
FS_v = M_res/M_ovr 'safety factor against OVERTURNING
FS_d = H_res/H_h 'safety factor against SLIDING

### The wall drawn with its thrusts

#dibujo("Thrusts on the wall", ud = m, escala = auto, cotas = m, alto = 220, lado = derecha)
#  poligono(0, 0, B_z, 0, B_z, h_z, x_t, h_z, x_t, H_t, x_t - b_t, H_t, x_p, h_z, 0, h_z, "gruesa")
#  achurado(0, 0, B_z, h_z, "concreto")
#  poligono(x_t, h_z, B_z, h_z, x_v, H_t, x_t, H_t, "verde tenue")
#  linea(x_v, H_t, B_z, h_z, "trazos verde")
#  linea(x_t, H_t, B_z + 3, H_t, "media verde")
#  linea(-1.2, h_z, 0, h_z, "media verde")
#  texto(B_z + 1.6, 2.2, "SP sand: γ 18.5, φ 30°", 2.5, "i")
#  texto(B_z + 1.6, -0.5, "SP-SM: γ 17.5, φ 29.97°", 2.5, "i")
#  carga(x_v, H_t, B_z, h_z, 0, q_1, "", "azul", n = 5)
#  carga(B_z, h_z, B_z, 0, q_3, q_4, "", "azul", n = 3)
#  carga(x_v, H_t, B_z, h_z, u_1, u_2, "", "rojo", n = 5)
#  carga(B_z, h_z, B_z, 0, u_3, 0, "", "rojo", n = 3)
#  cota(0, -0.70, B_z, -0.70, -0.1)
#  cota(-0.6, 0, -0.6, h_z, 0.1)
#  cota(-0.6, h_z, -0.6, H_t, 0.1)
#  cota(x_t, H_t + 0.5, x_t - b_t, H_t + 0.5, 0.1)
#  cota(x_t, H_t + 1.1, B_z, H_t + 1.1, 0.1)
#  cota(0, H_t + 0.5, x_p, H_t + 0.5, 0.1)
#fin
#: Static, foot of layer 1, to scale.
q_1 = Ka_1*s_1/25
#: Static, top of layer 2.
q_3 = Ka_2*s_1/25
#: Static, foot of layer 2.
q_4 = Ka_2*s_2/25
#: Seismic, top of layer 1.
u_1 = (Kae_1 - Ka_1)*t_1/25
#: Seismic, foot of layer 1.
u_2 = (Kae_1 - Ka_1)*t_2/25
#: Seismic, top of layer 2.
u_3 = (Kae_2 - Ka_2)*t_2/25
#: **How to read it.** Grey hatched: the concrete. Faint green: the earth wedge that travels with the wall; its inclined side (dashes) is the **virtual face**. **Blue:** static thrust (grows downward). **Red:** Mononobe-Okabe seismic increment, an **inverted triangle** (maximum at the top). Arrow scale: 1 m = 25 kPa.

## 7 · Against GEO5 Cantilever Wall 2024

#: The GEO5 values come from its "Verification" table and the force table, with two decimals. In each table, the columns are **Hekatan**, **GEO5** and **difference**. It is enough that the difference stays under 0.01: it is GEO5's rounding.
#: **Forces [kN/m]**, by rows: wall weight; static thrust F_{x} and F_{z}; seismic increment F_{x} and F_{z}.
T_F = [W_m, 47.04, W_m - 47.04; E_x, 26.63, E_x - 26.63; E_z, 38.21, E_z - 38.21; S_x, 38.39, S_x - 38.39; S_z, 65.87, S_z - 65.87] 'Hekatan, GEO5, difference
#: **Points of application [m]**, by rows: static thrust x and y; seismic increment x and y.
T_P = [E_xx, 2.53, E_xx - 2.53; E_y, 1.03, E_y - 1.03; S_xx, 2.06, S_xx - 2.06; S_y, 2.01, S_y - 2.01] 'Hekatan, GEO5, difference
#: **Seismic inertia and wedge [kN/m]**, by rows: wall inertia k_{h}·W_{m} ("Earthq.- constr."), wedge weight, wedge inertia ("Earthquake - soil wedge").
T_I = [k_h*W_m, 15.80, k_h*W_m - 15.80; W_c, 55.29, W_c - 55.29; k_h*W_c, 18.58, k_h*W_c - 18.58] 'Hekatan, GEO5, difference
#: **Moments [kN·m/m] and horizontal forces [kN/m]**, from the GEO5 "In detail" window: M_{res}, M_{ovr}, H_{res}, H_{act}.
T_M = [M_res, 388.96, M_res - 388.96; M_ovr, 143.34, M_ovr - 143.34; H_res, 119.02, H_res - 119.02; H_h, 99.40, H_h - 99.40] 'Hekatan, GEO5, difference
#: **Bit by bit against the binary.** GEO5 internal values read with Frida (double precision, 17 digits) on 20-Nov-2026 on this same wall: wedge weight and its centre of gravity, K_{a} and K_{ae} of the virtual face and the heel, and the forces F_{x}, F_{z} of the static thrust and the seismic increment. The difference stays at 1e-14: it is machine rounding, not method.
T_B = [W_c, 55.287195935578424, W_c - 55.287195935578424; x_c - x_t, 0.6563994871255965, x_c - x_t - 0.6563994871255965; H_t - y_c, 1.5829687446284182, H_t - y_c - 1.5829687446284182; Ka_1, 0.6666466332305437, Ka_1 - 0.6666466332305437; Kae_1, 1.594497947900209, Kae_1 - 1.594497947900209; Ka_2, 0.29731385720545084, Ka_2 - 0.29731385720545084; Kae_2, 0.6246519605930702, Kae_2 - 0.6246519605930702; E_x, 26.630959107165644, E_x - 26.630959107165644; E_z, 38.20792194799549, E_z - 38.20792194799549; S_x, 38.389394942694004, S_x - 38.389394942694004; S_z, 65.87199689777745, S_z - 65.87199689777745] 'Hekatan, GEO5 (Frida), difference
#: **Safety factors**, by rows: overturning and sliding.
T_S = [FS_v, 2.71, FS_v - 2.71; FS_d, 1.20, FS_d - 1.20] 'Hekatan, GEO5, difference

## 8 · Hekatan Geotechnic

#: **Hekatan Geotechnic** has the same wall in its walls module (src/wall/geo5Cantilever.ts, function muroGeo5) with the same GEO5 bisection. In its interface (wall panel, block "Like GEO5 Cantilever Wall", with k_{h} = 0.336, s1 = 17.33, k = 0.25 and base φ 29.97) and in its test tests/muro_manabi_bits.ts it gives these values for this wall; the third column is the difference from this sheet, which must be zero except for the last bit.
T_G = [M_res, 388.96319832456504, M_res - 388.96319832456504; M_ovr, 143.33686202937173, M_ovr - 143.33686202937173; H_res, 119.02291472713189, H_res - 119.02291472713189; H_h, 99.400990926337528, H_h - 99.400990926337528; FS_v, 2.7136299261585695, FS_v - 2.7136299261585695; FS_d, 1.1974016920549158, FS_d - 1.1974016920549158] 'this sheet, Hekatan Geotechnic, difference

#: **NEC-SE-GC, table 5 (earthquake):** overturning ≥ 2.00 and sliding ≥ 1.05. With k_{h} = 0.336 the wall **meets** both (2.71 and 1.20).
