# Isolated footing: settlement and rotation with the oedometric modulus, against GEO5
#numerico

#: **What is calculated.** The «Settlement» frame of GEO5 Spread Footing for the footing of the official example **Demo01.gpa** (1.20 × 1.20 m): the **settlement** of the characteristic point, the **depth of the influence zone**, the **stiffness** of the footing and the two **rotations**.
#: **How GEO5 does it** (Settings of the example): «Analysis using oedometric modulus», influence zone limited by the **structural strength** of the soil, bottom pressure reduced from the finished grade and depth coefficient κ₁ activated. The formulas are those of the official GEO5 2024 help («Analysis Using the Oedometric Modulus», «Theory of Structural Strength», «Increment of Earth Pressure under Footing», «Influence of Foundation Depth», «Overall Settlement and Rotation of Foundation»), read from the help file, not from memory.
#: **Judge.** The GEO5 2024 report with «Partial results»: the table of 24 layers (start, end, E_{def}, σ_{or}, Δσ_{z}, settlement) and the edge settlements. At the end, **Hekatan against GEO5** with the difference in %.

## 1 · Data

#: **The soil** (the two strata of Demo01, with what the settlement needs):
gamma_1 = 17.5 'unit weight of soil 1 [kN/m3]
gamma_s2 = 22 'unit weight of soil 2 [kN/m3]
gamma_u2 = 12 'submerged unit weight of soil 2, under water [kN/m3]
E_d1 = 21 'deformation modulus of soil 1 [MPa]
nu_1 = 0.3 'Poisson's ratio of soil 1
E_d2 = 1000 'deformation modulus of soil 2 [MPa]
nu_2 = 0.2 'Poisson's ratio of soil 2
m_s = 0.3 'structural strength coefficient (both soils)
z_12 = 3 'depth of the soil 1 / soil 2 contact [m]
z_w = 4 'depth of the water table [m]
#: **The footing**: the bottom is 2.00 m below the original ground and d = 1.20 m below the finished grade.
l_x = 1.2 'side in x [m]
l_y = 1.2 'side in y [m]
t_z = 0.4 'depth (thickness) [m]
d_f = 1.2 'depth of the bottom from the finished grade [m]
z_f = 2 'depth of the bottom from the original ground [m]
E_cm = 30000 'concrete modulus C20/25 [MPa]
#: **The service loads.** GEO5 chooses the most unfavorable one for settlement: Load No. 3 (large axial with horizontal in x); Load No. 4 (moment in x) is the one that gives the rotation in y.
N_3 = 1500 'axial of load 3 [kN]
H_x3 = 100 'horizontal in x of load 3 [kN]
N_4 = 700 'axial of load 4 [kN]
M_x4 = 100 'moment about x of load 4 [kN·m]
G_z = 13.248 'footing weight (sheet 104: 1.2·1.2·0.4·23) [kN]
Z_r = 20.48 'weight of the fill over the footing (sheet 104) [kN]
#: **The surcharge** of Demo01: 15 kPa over a 2 × 2 m square at 3 m from the axis, on the original ground.
q_s = 15 'surcharge [kPa]

## 2 · The bottom pressure and the one that really settles

V_3 = N_3 + G_z + Z_r 'vertical at the bottom, load 3 [kN]
sigma_3 = V_3/(l_x·l_y) 'mean pressure, load 3 [kPa]
#: Help «Stress in the Footing Bottom»: before distributing the pressure in depth, the stress the soil already had at that level is subtracted. With the option «from the finished grade», it is that of the finished grade:
sigma_sp = gamma_1·d_f 'geostatic stress at the bottom, from the finished grade [kPa]
q_n = sigma_3 - sigma_sp 'net pressure that settles [kPa]
#: **Service eccentricities** (the check of the 2nd limit state; GEO5 prints them relative):
e_x3 = H_x3·t_z/V_3 'eccentricity in x, load 3 [m]
V_4 = N_4 + G_z + Z_r 'vertical at the bottom, load 4 [kN]
e_y4 = M_x4/V_4 'eccentricity in y, load 4 [m]
er_x = e_x3/l_x 'relative in x (GEO5: 0.022)
er_y = e_y4/l_y 'relative in y (GEO5: 0.114)
#: For the **rotations** the pressure at each edge is needed (trapezoid, combined bending), already net:
q_3M = V_3/(l_x·l_y) + V_3·e_x3/(l_y·l_x^2/6) - sigma_sp 'most loaded edge, load 3 [kPa]
q_3m = V_3/(l_x·l_y) - V_3·e_x3/(l_y·l_x^2/6) - sigma_sp 'least loaded edge, load 3 [kPa]
q_4M = V_4/(l_x·l_y) + V_4·e_y4/(l_x·l_y^2/6) - sigma_sp 'most loaded edge, load 4 [kPa]
q_4m = V_4/(l_x·l_y) - V_4·e_y4/(l_x·l_y^2/6) - sigma_sp 'least loaded edge, load 4 [kPa]

## 3 · The geostatic stress σ_{or}

#: It is measured from the **original ground**: soil 1 down to 3 m, soil 2 down to the water (4 m) and submerged below.
sigma_or(z) = gamma_1·min(z, z_12) + gamma_s2·max(0, min(z, z_w) - z_12) + gamma_u2·max(0, z - z_w)
s_or1 = sigma_or(2.025) 'at the center of the 1st layer (GEO5: 35.44) [kPa]
s_or19 = sigma_or(4.075) 'at the center of layer 19, already under water (GEO5: 75.40) [kPa]

## 4 · The stress increment under the footing (Steinbrenner)

#: Help «Increment of Earth Pressure under Footing»: under the **corner** of a rectangle l × b loaded with f, at depth z. With the sign of a and b the same function serves to add and subtract rectangles (a point outside the footing):
I_c(a, b, z) = sign(a)·sign(b)/(2·pi)·(atan(abs(a·b)/(z·sqrt(a^2 + b^2 + z^2))) + abs(a·b)·z/sqrt(a^2 + b^2 + z^2)·(1/(a^2 + z^2) + 1/(b^2 + z^2)))
#: A rectangle [x₀, x₁] × [y₀, y₁] seen from the point (p_{x}, p_{y}) is four corners:
R_u(x_0, x_1, y_0, y_1, p_x, p_y, z) = I_c(x_1 - p_x, y_1 - p_y, z) + I_c(p_x - x_0, y_1 - p_y, z) + I_c(x_1 - p_x, p_y - y_0, z) + I_c(p_x - x_0, p_y - y_0, z)
#: The **triangular load** (zero at one edge, f at the other), under the corner of the zero side (T₀) and of the maximum side (T_{m}); b is the side in which the load grows. They are the two formulas of the same help page:
T_0(l, b, z) = 1/(2·pi)·(l·b·z/(sqrt(l^2 + b^2 + z^2)·(z^2 + b^2)) + l·z/(b·sqrt(l^2 + b^2 + z^2))·(sqrt(l^2 + b^2 + z^2) - sqrt(l^2 + z^2))/sqrt(l^2 + z^2))
T_m(l, b, z) = 1/(2·pi)·(atan(l·b/(z·sqrt(l^2 + b^2 + z^2))) + l·z/(l^2 + z^2)·(sqrt(l^2 + b^2 + z^2) - sqrt(l^2 + z^2))/b)
#: **The depth of the footing** (help «Influence of Foundation Depth and Incompressible Subsoil»): the stress is calculated at a fictitious depth z_{r} = κ₁·z, greater than the real one, because the soil above confines:
kappa_1(z) = 1 + 0.35·atan(1.55·d_f/z)
k_1a = kappa_1(0.025) 'κ₁ in the 1st layer: almost 1 + 0.35·π/2
#: **The characteristic point.** Help «Overall Settlement and Rotation of Foundation»: if the footing is rigid (k > 1, section 7) its settlement is that of a point at 0.37 times the side from the axis:
x_c = 0.37·l_x 'abscissa of the characteristic point [m]
y_c = 0.37·l_y 'ordinate of the characteristic point [m]
dsz_1 = q_n·R_u(-l_x/2, l_x/2, -l_y/2, l_y/2, x_c, y_c, kappa_1(0.025)·0.025) 'Δσz in the 1st layer, without the surcharge [kPa]
#: The **pressure bulb** in the plane y = 0 (the net pressure of load 3, already with κ₁): the hot zone goes down little more than one width.
#map(q_n·R_u(-0.6, 0.6, -0.6, 0.6, x, 0, kappa_1(-y)·(-y)), [-2 2], [-4.2 -0.02])

## 5 · The settlement: layer by layer

#: Help «Analysis Using the Oedometric Modulus»: the oedometric modulus comes from the deformation modulus, and each layer settles by what the stress compresses it **above** its structural strength m·σ_{or} (help «Theory of Structural Strength»):
beta_1 = 1 - 2·nu_1^2/(1 - nu_1) 'β of soil 1
beta_2 = 1 - 2·nu_2^2/(1 - nu_2) 'β of soil 2
E_o1 = E_d1/beta_1·1000 'oedometric modulus of soil 1 [kPa]
E_o2 = E_d2/beta_2·1000 'oedometric modulus of soil 2 [kPa]
#: **The 1st layer by hand** (from 2.00 to 2.05 m), with the 15 kPa surcharge seen from the characteristic point:
h_1 = 0.05 'thickness of the 1st layer [m]
sur_1 = q_s·R_u(3 - 1, 3 + 1, -1, 1, x_c, y_c, 2.025) 'contribution of the surcharge in the 1st layer [kPa]
ds_1 = dsz_1 + sur_1 'total Δσz in the 1st layer (GEO5: 1024.93) [kPa]
s_1 = (ds_1 - m_s·s_or1)·h_1/E_o1·1000 'settlement of the 1st layer (GEO5: 1.79) [mm]
#: **The 24 GEO5 layers** (their origin levels, from the original ground) and what GEO5 prints for each one:
z_top = [2, 2.05, 2.1, 2.15, 2.2, 2.25, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9, 3, 3.15, 3.4, 3.65, 3.9, 4, 4.15, 4.4, 4.9, 5.4, 5.9, 6.4, 6.9, 7.4] 'levels of the GEO5 layers (and three more below) [m]
D_G = [1024.93, 940.85, 809.34, 691.98, 604.08, 539.05, 471.26, 402.85, 351.86, 310.82, 276.52, 247.34, 223.42, 197.28, 163.09, 131.14, 107.67, 94.58, 86.91, 76.33, 61.72, 47.31, 37.44, 31.75] 'GEO5 Δσz per layer [kPa]
S_G = [1.79, 1.64, 1.41, 1.2, 1.05, 0.93, 1.62, 1.38, 1.2, 1.05, 0.93, 0.82, 0.74, 0.02, 0.03, 0.03, 0.02, 0.01, 0.01, 0.01, 0.02, 0.01, 0, 0] 'GEO5 settlement per layer [mm]
#: The calculation of all the layers is that of the 1st repeated: in each layer, the center, σ_{or}, Δσ_{z} (footing + surcharge) and the settlement; in the layer where Δσ_{z} falls below m·σ_{or} the exact point is searched (bisection) and the influence zone ends there. It is done for seven points: the characteristic one and the center with load 3, the two edges in x with load 3 (trapezoid), the two edges in y with load 4 and the edge in y with load 3.
#: **The seven points**, each with its Δσ_{z} (footing + surcharge), in a one-line function:
D_1(z) = q_n·R_u(-0.6, 0.6, -0.6, 0.6, x_c, y_c, kappa_1(z)·z) + q_s·R_u(2, 4, -1, 1, x_c, y_c, z + z_f) 'characteristic point, load 3
D_2(z) = q_n·R_u(-0.6, 0.6, -0.6, 0.6, 0, 0, kappa_1(z)·z) + q_s·R_u(2, 4, -1, 1, 0, 0, z + z_f) 'center, load 3
D_3(z) = 2·q_3m·I_c(0.6, 1.2, kappa_1(z)·z) + 2·(q_3M - q_3m)·T_m(0.6, 1.2, kappa_1(z)·z) + q_s·R_u(2, 4, -1, 1, 0.6, 0, z + z_f) 'most loaded x edge, load 3
D_4(z) = 2·q_3m·I_c(0.6, 1.2, kappa_1(z)·z) + 2·(q_3M - q_3m)·T_0(0.6, 1.2, kappa_1(z)·z) + q_s·R_u(2, 4, -1, 1, -0.6, 0, z + z_f) 'least loaded x edge, load 3
D_5(z) = 2·q_4m·I_c(0.6, 1.2, kappa_1(z)·z) + 2·(q_4M - q_4m)·T_m(0.6, 1.2, kappa_1(z)·z) + q_s·R_u(2, 4, -1, 1, 0, 0.6, z + z_f) 'most loaded y edge, load 4
D_6(z) = 2·q_4m·I_c(0.6, 1.2, kappa_1(z)·z) + 2·(q_4M - q_4m)·T_0(0.6, 1.2, kappa_1(z)·z) + q_s·R_u(2, 4, -1, 1, 0, -0.6, z + z_f) 'least loaded y edge, load 4
D_7(z) = q_n·R_u(-0.6, 0.6, -0.6, 0.6, 0, 0.6, kappa_1(z)·z) + q_s·R_u(2, 4, -1, 1, 0, 0.6, z + z_f) 'center of the y edge, load 3
#: To run through them with an index k, the weight max(0, 1 − |k − i|) is 1 only when k = i:
dsig(k, z) = max(0, 1 - abs(k - 1))·D_1(z) + max(0, 1 - abs(k - 2))·D_2(z) + max(0, 1 - abs(k - 3))·D_3(z) + max(0, 1 - abs(k - 4))·D_4(z) + max(0, 1 - abs(k - 5))·D_5(z) + max(0, 1 - abs(k - 6))·D_6(z) + max(0, 1 - abs(k - 7))·D_7(z)
#: The oedometric modulus according to the stratum (the sign acts as a switch at z = 3 m):
E_oed(z) = E_o1 + (E_o2 - E_o1)·(1 + sign(z - z_12))/2
#hide
S_k = zeros(7, 1)
Z_k = zeros(7, 1)
D_H = zeros(24, 1)
S_H = zeros(24, 1)
S_GD = zeros(24, 1)
Z_m = zeros(24, 1)
for k = 1:7
  s = 0
  fin = 0
  j = 1
  while fin == 0
    z0 = z_top(j) - z_f
    z1 = z_top(j + 1) - z_f
    f1 = dsig(k, z1) - m_s·sigma_or(z1 + z_f)
    if f1 < 0
      a = z0
      b = z1
      for it = 1:50
        c = (a + b)/2
        if dsig(k, c) - m_s·sigma_or(c + z_f) > 0
          a = c
        else
          b = c
        end
      end
      z1 = (a + b)/2
      fin = 1
    end
    zm = (z0 + z1)/2
    g = dsig(k, zm)
    ds = max(g - m_s·sigma_or(zm + z_f), 0)·(z1 - z0)/E_oed(zm + z_f)·1000
    s = s + ds
    if k == 1
      D_H(j) = g
      S_H(j) = ds
      Z_m(j) = zm
      S_GD(j) = (D_G(j) - m_s·sigma_or(zm + z_f))·(z1 - z0)/E_oed(zm + z_f)·1000
    end
    j = j + 1
  end
  S_k(k) = s
  Z_k(k) = z1
end
#show
#: **The 24 layers of the characteristic point.** Columns: depth of the center below the bottom [m] · Hekatan Δσ_{z} · GEO5 Δσ_{z} [kPa] · Hekatan settlement · settlement with the GEO5 Δσ_{z} · GEO5 settlement [mm]:
#hide
C_t = zeros(24, 6)
for j = 1:24
  C_t(j, 1) = round(Z_m(j), 3)
  C_t(j, 2) = round(D_H(j), 2)
  C_t(j, 3) = D_G(j)
  C_t(j, 4) = round(S_H(j), 3)
  C_t(j, 5) = round(S_GD(j), 3)
  C_t(j, 6) = S_G(j)
end
#show
C_t
#: The 5th column puts into the settlement formula the Δσ_{z} that GEO5 prints: it gives its settlement layer by layer, so **the settlement formula is the same**. What separates slightly is the Δσ_{z} in the upper layers (1038.9 against 1024.9 in the 1st, 1.4 %); further down it drops to tenths of a kPa. The sum, which is what matters, agrees.

#hide
m_or = zeros(24, 1)
for j = 1:24
  m_or(j) = m_s·sigma_or(Z_m(j) + z_f)
end
#show
#: To draw the profile (1 unit = 100 kPa horizontally, the depth ×2 vertically):
p_H = D_H/100 'Hekatan Δσz, scaled
p_G = D_G'/100 'GEO5 Δσz, scaled
p_m = m_or/100 'm·σor, scaled
p_z = -2·Z_m 'depth of the center of each layer, scaled
#dibujo("Δσz with depth: Hekatan (blue), GEO5 (red circles) and m·σor (green). Scale: 1 unit = 100 kPa, z ×2", ud = m, escala = auto, alto = 150)
#  linea(0, 0, 11, 0, "media")
#  linea(0, 0, 0, -8.6, "media")
#  polilinea(p_H, p_z, "gruesa azul")
#  circulo(p_G, p_z, 0.08, "rojo")
#  polilinea(p_m, p_z, "media verde")
#  linea(0, -8.3, 1.2, -8.3, "trazos")
#  texto(1.3, -8.3, "end of the influence zone: 4.17 m (GEO5)", 2.6, "i")
#  texto(10.4, 0.3, "1044 kPa", 2.6, "c")
#  texto(5, 0.3, "500", 2.6, "c")
#  linea(5, 0, 5, 0.12, "media")
#  linea(10, 0, 10, 0.12, "media")
#  texto(-0.15, -4, "2 m", 2.6, "d")
#  texto(-0.15, -8, "4 m", 2.6, "d")
#  texto(4, -2.4, "Δσz (footing pressure, already at depth)", 2.6, "i")
#  texto(1.4, -6.6, "m·σor: below this line the soil no longer settles", 2.6, "i")
#fin

## 6 · Total settlement, influence zone and the other points

s_car = S_k(1) 'settlement of the characteristic point, load 3 [mm]
z_inf = Z_k(1) 'depth of the influence zone below the bottom [m]
s_cen = S_k(2) 'settlement of the center, load 3 [mm]
s_xp = S_k(3) 'most loaded x edge, load 3 [mm]
s_xm = S_k(4) 'least loaded x edge, load 3 [mm]
s_yp = S_k(5) 'most loaded y edge, load 4 [mm]
s_ym = S_k(6) 'least loaded y edge, load 4 [mm]
s_ym3 = S_k(7) 'center of the y edge, load 3 [mm]
s_GD = sum(S_GD) 'settlement with the Δσz that GEO5 prints [mm]
#: The influence zone ends where the blue curve cuts the green one: there Δσ_{z} = m·σ_{or} (help «Theory of Structural Strength»).

## 7 · Stiffness and rotation of the footing

#: Help «Overall Settlement and Rotation of Foundation»: k = E_{basic}·t³/(E_{def,av}·l³). If k > 1 the footing is **rigid** and its settlement is that of the characteristic point. E_{def,av} is the weighted mean of the modulus down to the bottom of the influence zone; the help **does not say what it is weighted by** and I could not reproduce it (with the thickness it gives 765 MPa; with Δσ_{z}·h, 369). The value GEO5 prints is taken:
E_av = 329.83 'mean deformation modulus, from the GEO5 report [MPa]
k_r = E_cm·t_z^3/(E_av·l_x^3) 'relative stiffness (k > 1: rigid)
#: **The rotation** is the settlement difference of the centers of two opposite edges, divided by the side. GEO5 gives it in tan·1000:
th_x = (s_xp - s_xm)/l_x 'rotation in x, load 3 [‰]
th_y = (s_yp - s_ym)/l_y 'rotation in y, load 4 [‰]

#: **3D: the pressure cushion at 0.50 m below the bottom** (load 3). Each point of the plan rises by the value of Δσ_{z} there (1 m of height = 1000 kPa); the color is the same value. It rotates with the mouse and the cursor reads the number:
#hide
n_g = 25
X_n = zeros(n_g^2 + 2, 3)
e_s = zeros((n_g - 1)^2, 4)
v_n = zeros(n_g^2 + 2, 1)
for j = 1:n_g
  for k = 1:n_g
    p = (j - 1)·n_g + k
    X_n(p, 1) = -1.8 + 3.6·(k - 1)/(n_g - 1)
    X_n(p, 2) = -1.8 + 3.6·(j - 1)/(n_g - 1)
    v_n(p) = q_n·R_u(-0.6, 0.6, -0.6, 0.6, X_n(p, 1), X_n(p, 2), kappa_1(0.5)·0.5)
    X_n(p, 3) = v_n(p)/1000
  end
end
for j = 1:n_g - 1
  for k = 1:n_g - 1
    q = (j - 1)·(n_g - 1) + k
    a = (j - 1)·n_g + k
    e_s(q, 1) = a
    e_s(q, 2) = a + 1
    e_s(q, 3) = a + n_g + 1
    e_s(q, 4) = a + n_g
  end
end
X_n(n_g^2 + 2, 3) = 1.5
e_f = [n_g^2 + 1, n_g^2 + 2]
v_f = [0, 0]
#show
#modelo3d(X_n, e_s, e_f, v_n, v_f)
#: The vertical bar is the column axis. Half a meter below the bottom the pressure is no longer uniform: at the very top it is 1044 kPa, here the center drops to 626 kPa (60 %) and at 1.8 m from the axis it is 3 kPa. This is why the settlement comes almost entirely from the first meter (the table of section 5).

## 8 · Hekatan against GEO5

#hide
g_s = 15.9
g_z = 4.17
g_cen = 23.1
g_xm3 = 13.1
g_xp = 14.1
g_xm = 12.1
g_k = 3.37
g_tx = 1.638
g_ty = 4.095
g_d1 = 1024.93
g_s1 = 1.79
g_er = 0.022
g_ey = 0.114
h_s = round(s_car, 1)
h_sGD = round(s_GD, 1)
h_z = round(z_inf, 2)
h_cen = round(s_cen, 1)
h_xm3 = round(s_ym3, 1)
h_xp = round(s_xp, 1)
h_xm = round(s_xm, 1)
h_k = round(k_r, 2)
h_tx = round(th_x, 3)
h_ty = round(th_y, 3)
h_d1 = round(ds_1, 2)
h_s1 = round(s_1, 2)
h_er = round(er_x, 3)
h_ey = round(er_y, 3)
x_s = round(100·(h_s/g_s - 1), 2)
x_sGD = round(100·(h_sGD/g_s - 1), 2)
x_z = round(100·(h_z/g_z - 1), 2)
x_cen = round(100·(h_cen/g_cen - 1), 2)
x_xm3 = round(100·(h_xm3/g_xm3 - 1), 2)
x_xp = round(100·(h_xp/g_xp - 1), 2)
x_xm = round(100·(h_xm/g_xm - 1), 2)
x_k = round(100·(h_k/g_k - 1), 2)
x_tx = round(100·(h_tx/g_tx - 1), 2)
x_ty = round(100·(h_ty/g_ty - 1), 2)
x_d1 = round(100·(h_d1/g_d1 - 1), 2)
x_s1 = round(100·(h_s1/g_s1 - 1), 2)
x_er = round(100·(h_er/g_er - 1), 2)
x_ey = round(100·(h_ey/g_ey - 1), 2)
#show
#| Magnitud | Hekatan | GEO5 2024 | Diferencia [%] |
#|---|---:|---:|---:|
#| excentricidad relativa en x (servicio) | @{h_er} | @{g_er} | @{x_er} |
#| excentricidad relativa en y (servicio) | @{h_ey} | @{g_ey} | @{x_ey} |
#| Δσ_{z} en la 1.ª capa [kPa] | @{h_d1} | @{g_d1} | @{x_d1} |
#| asiento de la 1.ª capa [mm] | @{h_s1} | @{g_s1} | @{x_s1} |
#| **asiento del punto característico [mm]** | @{h_s} | @{g_s} | @{x_s} |
#| el mismo, con la Δσ_{z} de GEO5 [mm] | @{h_sGD} | @{g_s} | @{x_sGD} |
#| zona de influencia [m] | @{h_z} | @{g_z} | @{x_z} |
#| asiento del centro [mm] | @{h_cen} | @{g_cen} | @{x_cen} |
#| centro del borde en y, carga 3 [mm] | @{h_xm3} | @{g_xm3} | @{x_xm3} |
#| borde más cargado, carga 3 [mm] | @{h_xp} | @{g_xp} | @{x_xp} |
#| borde menos cargado, carga 3 [mm] | @{h_xm} | @{g_xm} | @{x_xm} |
#| rigidez k (con el E_{def,av} de GEO5) | @{h_k} | @{g_k} | @{x_k} |
#| giro en x [tan·1000] | @{h_tx} | @{g_tx} | @{x_tx} |
#| giro en y [tan·1000] | @{h_ty} | @{g_ty} | @{x_ty} |
#: **What agrees:** the total settlement (15.9 mm), the edge settlements to the tenth that GEO5 prints, the stiffness and the eccentricities. The center one is off by 0.05 mm (23.05 against 23.1). The per-layer settlement formula is exactly that of GEO5 (the 5th column of the table in section 5 gives its settlement with its Δσ_{z}).
#: **What does not agree to four digits, and why:** (1) **Δσ_{z} in the upper layers**, up to 1.4 % (1038.9 against 1024.9): with the Steinbrenner pressure, κ₁ and the surcharge this is what comes out; I do not know what else GEO5 does near the bottom and I do not invent a factor. (2) **The rotations**, 0.8 % and 0.5 %: they come from subtracting two edge settlements and that subtraction amplifies the difference in Δσ_{z}. (3) **The influence zone**, 4.15 against 4.17 m (0.5 %): the cut with m·σ_{or} is almost tangent and a tenth of a kPa moves it by centimeters. (4) **E_{def,av} = 329.83 MPa** is not reproduced (the help does not give the weighting); k = 3.37 comes out with the GEO5 value.
#: **NEC-SE-GC 2015**, §6.3.4 (p. 43-44): admissible total settlement of an isolated footing **20 cm** at 25 years with DL + 50 % LL_{max}. 15.9 mm is very far away; what governs in this footing is the bearing capacity (sheet 104), not the settlement.
