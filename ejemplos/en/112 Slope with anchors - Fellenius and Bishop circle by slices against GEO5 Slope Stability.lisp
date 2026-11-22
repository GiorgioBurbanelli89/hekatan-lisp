# Slope with wall, surcharges and two anchors: Fellenius and Bishop circle by slices, against GEO5
#numerico

#: **What is calculated.** Stage 3 of the official GEO5 Slope Stability example (**Demo01.gst**): a 13 m slope with a toe wall (rigid body), an excavation above, two strip surcharges and **two 200 kN anchors**. The circle that GEO5 brings in the example is checked (center (14.56; 166.63), radius 51.88 m) with the **Fellenius/Petterson** and **Bishop** methods.
#: **How.** The mass over the circle is cut into vertical slices. The moment that makes it rotate about the center, M_{a}, is compared with the one that resists shear at the base, M_{p}: FS = M_{p}/M_{a}. Formulas from the GEO5 2024 help ("Circular Slip Surface", "Bishop", "Fellenius / Petterson", "Anchors in the Stability Analysis").
#: **Judge.** GEO5 2024 with this file. GEO5 prints the FS with two decimals, but **stores inside the .gst the moments and the FS unrounded** (read from the file): those are the numbers of the final table.
#: **Units.** kN, m and kPa per meter of slope (as GEO5); moments also in tonf·m (1 tonf = 9.80665 kN).

## 1 · Example data (Demo01.gst, stage 3)

#: GEO5 axes: x horizontal, z = elevation. The slope faces −x: the mass slides to the left.
#: **The soils** (read from the file; the rigid body is the toe wall):
gamma_1 = 20 'soil 1, silt (top): unit weight [kN/m3]
phi_1 = 21 'soil 1: effective friction angle [degrees]
c_1 = 12 'soil 1: effective cohesion [kPa]
gamma_2 = 18 'soil 2, sandy silt (below): unit weight [kN/m3]
phi_2 = 26.5 'soil 2: effective friction angle [degrees]
c_2 = 16 'soil 2: effective cohesion [kPa]
gamma_R = 25 'rigid body (toe wall): unit weight [kN/m3]
#: Soil 3 (claystone, φ = 40°, c = 50 kPa) is below elevation 105: the circle does not touch it. No water (Water: No water) and no earthquake.
#: **The ground of stage 3** (with the excavation of stage 2 between x = 41 and 54). Each segment goes from (T_{A}, Z_{A}) to (T_{B}, Z_{B}); the vertical step of the wall at x = 17.25 remains as a jump between segment 5 and 6:
T_A = [-20; 0; 7.89; 11.54; 17.2; 17.25; 19; 20; 21.5; 26.5; 29.8; 32.39; 36.16; 38.69; 41; 41.5; 53; 54] 'abscissa of the start of each ground segment [m]
T_B = [0; 7.89; 11.54; 17.2; 17.25; 19; 20; 21.5; 26.5; 29.8; 32.39; 36.16; 38.69; 41; 41.5; 53; 54; 70] 'abscissa of the end of each segment [m]
Z_A = [115.32; 115.32; 115.2; 116.85; 117.99; 119; 119; 122.98; 122.98; 122.98; 124.92; 125.92; 127.92; 128.51; 128.67; 127.5; 127.5; 128.75] 'elevation of the start of each segment [m]
Z_B = [115.32; 115.2; 116.85; 117.99; 118; 119; 122.98; 122.98; 122.98; 124.92; 125.92; 127.92; 128.51; 128.67; 127.5; 127.5; 128.75; 128.75] 'elevation of the end of each segment [m]
#: **The top of soil 2.** Below this line there is soil 2; above it, the wall (from x = 17.2 to 21.5) or soil 1 (from x = 21.5). In front of the wall it coincides with the ground:
S_A = [-20; 0; 7.89; 11.54; 17.2; 21.5; 36.18; 53.99] 'abscissa of the start of each segment of the top of soil 2 [m]
S_B = [0; 7.89; 11.54; 17.2; 21.5; 36.18; 53.99; 70] 'abscissa of the end [m]
Y_A = [115.32; 115.32; 115.2; 116.85; 117.99; 120.02; 120.75; 121.7] 'elevation of the start [m]
Y_B = [115.32; 115.2; 116.85; 117.99; 117.9; 120.75; 121.7; 122.34] 'elevation of the end [m]
#: **Strip surcharges** (permanent, on the ground): 12 kPa from x = 22.40 to 25.90, and 160 kPa from x = 42.00 to 52.00, at the bottom of the excavation.
q_1 = 12 'surcharge 1 [kPa]
a_1 = 22.4 'start of surcharge 1 [m]
e_1 = 25.9 'end of surcharge 1 [m]
q_2 = 160 'surcharge 2 [kPa]
a_2 = 42 'start of surcharge 2 [m]
e_2 = 52 'end of surcharge 2 [m]
#: **Anchors** (stage 3): two, of 200 kN, spaced 1 m, inclined 30° below the horizontal, with 14 m free length:
x_h1 = 29.29 'head of anchor 1, x [m]
z_h1 = 124.62 'head of anchor 1, z [m]
x_h2 = 33.97 'head of anchor 2, x [m]
z_h2 = 126.76 'head of anchor 2, z [m]
P_a = 200 'force of each anchor per meter (200 kN every 1.00 m) [kN/m]
beta_a = 30 'inclination of the anchors below the horizontal [degrees]
#: **The circle** (Analysis, stage 3, "Circular slip surface"):
x_c = 14.56 'center of the circle, x [m]
z_c = 166.63 'center of the circle, z [m]
R = 51.88 'radius [m]
#: **What GEO5 asks for in the example:** safety factors (ASD), permanent situation, SF_{s} = 1.50.

## 2 · The profile functions

#: A straight segment holds for x between its start and its end. The function "inside" equals 1 inside the segment and 0 outside (at the edge, ½ with each neighbor):
dentro(x, a, b) = (sign(x - a) + 1).*(sign(b - x) + 1)/4
#: The ground elevation and that of the top of soil 2 at any x: the line of each segment, keeping only that of the segment where x falls:
z_t(x) = sum(dentro(x, T_A, T_B).*(Z_A + (x - T_A).*(Z_B - Z_A)./(T_B - T_A)))
z_s(x) = sum(dentro(x, S_A, S_B).*(Y_A + (x - S_A).*(Y_B - Y_A)./(S_B - S_A)))
#: The circle below the center:
z_o(x) = z_c - sqrt(R^2 - (x - x_c)^2)
#: The unit weight of what lies **above** soil 2: the wall up to x = 21.5 and soil 1 from there:
g_u(x) = gamma_R + (gamma_1 - gamma_R)·(sign(x - 21.5) + 1)/2

## 3 · Where the circle cuts the ground

#: The circle enters the ground at the toe (on the left) and leaves at the bottom of the excavation. They are the roots of z_{t}(x) − z_{o}(x) = 0; they are found by bisection (the interval is halved 60 times):
#hide
x_L = 5
x_U = 10
for k = 1:60
  x_m = (x_L + x_U)/2
  if (z_t(x_L) - z_o(x_L))·(z_t(x_m) - z_o(x_m)) <= 0
    x_U = x_m
  else
    x_L = x_m
  end
end
x_a = (x_L + x_U)/2
x_L = 45
x_U = 50
for k = 1:60
  x_m = (x_L + x_U)/2
  if (z_t(x_L) - z_o(x_L))·(z_t(x_m) - z_o(x_m)) <= 0
    x_U = x_m
  else
    x_L = x_m
  end
end
x_b = (x_L + x_U)/2
x_L = 36.18
x_U = 53.99
for k = 1:60
  x_m = (x_L + x_U)/2
  if (z_s(x_L) - z_o(x_L))·(z_s(x_m) - z_o(x_m)) <= 0
    x_U = x_m
  else
    x_L = x_m
  end
end
x_x = (x_L + x_U)/2
#show
x_a = x_a 'entry of the circle, at the toe [m]
z_a = z_o(x_a) 'its elevation [m]
x_b = x_b 'exit of the circle, at the bottom of the excavation [m]
z_b = z_o(x_b) 'its elevation [m]
#: GEO5 gives the two angles from the center: −7.57° and 41.04°. Here:
a_1g = asin((x_a - x_c)/R)·180/pi 'entry angle [degrees]
a_2g = asin((x_b - x_c)/R)·180/pi 'exit angle [degrees]
#: The circle **crosses the contact** between soil 2 and soil 1 at:
x_x = x_x 'crossing of the circle with the top of soil 2 [m]
#: To the left of x_{x} the base of the circle is in soil 2 (φ = 26.5°); to the right, in soil 1 (φ = 21°).

## 4 · The slices: how GEO5 cuts them

#: **Measured, not assumed.** GEO5 stores in the .gst the 19 interslice forces of its Spencer calculation (sheet 113). Its two jumps fall at slices 11 and 13, where the anchor heads are (x = 29.29 and 33.97), and that only happens with **20 slices of equal width**. In addition, GEO5 replaces the arc with the **chord** (straight base) in each slice.
n = 20 'number of slices
b = (x_b - x_a)/n 'width of each slice [m]
#hide
X_i = zeros(n + 1, 1)
Z_i = zeros(n + 1, 1)
for i = 1:n + 1
  X_i(i) = x_a + (i - 1)·b
  Z_i(i) = z_o(X_i(i))
end
#show
#dibujo("Stage 3 of Demo01: soils, wall, surcharges, anchors and the circle with its 20 slices", ud = m, cotas = m, ancho = 180, alto = 110)
#  poligono(21.5, 117.9, 21.5, 122.98, 20, 122.98, 19, 119, 17.25, 119, 17.25, 118, 17.2, 117.99, "media")
#  achurado([21.5, 21.5, 20, 19, 17.25, 17.25, 17.2], [117.9, 122.98, 122.98, 119, 119, 118, 117.99], "concreto")
#  polilinea([2, 7.89, 11.54, 17.2, 17.25, 17.25, 19, 20, 21.5, 26.5, 29.8, 32.39, 36.16, 38.69, 41, 41.5, 53, 54, 56], [115.29, 115.2, 116.85, 117.99, 118, 119, 119, 122.98, 122.98, 122.98, 124.92, 125.92, 127.92, 128.51, 128.67, 127.5, 127.5, 128.75, 128.75], "gruesa")
#  polilinea([2, 7.89, 11.54, 17.2, 21.5, 21.5, 36.18, 53.99, 56], [115.29, 115.2, 116.85, 117.99, 117.9, 120.02, 120.75, 121.7, 121.78], "media trazos azul")
#  polilinea([7.722, 7.722, 7.722, 9.768, 9.768, 9.768, 11.813, 11.813, 11.813, 13.858, 13.858, 13.858, 15.903, 15.903, 15.903, 17.948, 17.948, 17.948, 19.993, 19.993, 19.993, 22.038, 22.038, 22.038, 24.083, 24.083, 24.083, 26.128, 26.128, 26.128, 28.173, 28.173, 28.173, 30.218, 30.218, 30.218, 32.264, 32.264, 32.264, 34.309, 34.309, 34.309, 36.354, 36.354, 36.354, 38.399, 38.399, 38.399, 40.444, 40.444, 40.444, 42.489, 42.489, 42.489, 44.534, 44.534, 44.534, 46.579, 46.579, 46.579, 48.624], [115.203, 115.203, 115.203, 114.972, 116.049, 114.972, 114.823, 116.905, 114.823, 114.755, 117.317, 114.755, 114.767, 117.729, 114.767, 114.861, 119.0, 114.861, 115.035, 122.952, 115.035, 115.292, 122.98, 115.292, 115.632, 122.98, 115.632, 116.056, 122.98, 116.056, 116.568, 123.964, 116.568, 117.169, 125.082, 117.169, 117.864, 125.871, 117.864, 118.656, 126.938, 118.656, 119.55, 127.965, 119.55, 120.551, 128.442, 120.551, 121.668, 128.631, 121.668, 122.909, 127.5, 122.909, 124.285, 127.5, 124.285, 125.81, 127.5, 125.81, 127.5], "fina rojo")
#  polilinea([7.722, 9.768, 11.813, 13.858, 15.903, 17.948, 19.993, 22.038, 24.083, 26.128, 28.173, 30.218, 32.264, 34.309, 36.354, 38.399, 40.444, 42.489, 44.534, 46.579, 48.624], [115.203, 114.972, 114.823, 114.755, 114.767, 114.861, 115.035, 115.292, 115.632, 116.056, 116.568, 117.169, 117.864, 118.656, 119.55, 120.551, 121.668, 122.909, 124.285, 125.81, 127.5], "gruesa rojo")
#  linea(29.29, 124.62, 29.29 + 14·cos(pi/6), 124.62 - 7, "media verde")
#  linea(33.97, 126.76, 33.97 + 14·cos(pi/6), 126.76 - 7, "media verde")
#  flecha(26.0, 126.1, 29.29, 124.62, "verde")
#  flecha(30.7, 128.24, 33.97, 126.76, "verde")
#  flecha(23.3, 125.5, 23.3, 123.1, "azul")
#  flecha(25.0, 125.5, 25.0, 123.1, "azul")
#  flecha(43.0, 131.0, 43.0, 127.6, "azul")
#  flecha(45.5, 131.0, 45.5, 127.6, "azul")
#  flecha(48.0, 131.0, 48.0, 127.6, "azul")
#  flecha(50.5, 131.0, 50.5, 127.6, "azul")
#  texto(46.5, 131.6, "q = 160 kPa", 2.4, "c", estilo = "azul")
#  texto(24.2, 126.2, "12 kPa", 2.4, "c", estilo = "azul")
#  texto(38.5, 117.0, "anchors 2 × 200 kN, 30°", 2.4, "i", estilo = "verde")
#  texto(19.5, 124.0, "wall", 2.4, "c")
#  texto(45.0, 125.0, "soil 1", 2.4, "c")
#  texto(30.0, 113.0, "soil 2", 2.4, "c", estilo = "azul")
#  texto(12.0, 112.6, "circle R = 51.88 m (center 50 m higher)", 2.4, "c", estilo = "rojo")
#  cota(7.722, 112.6, 48.624, 112.6, -0.4, "circle entry to exit: 40.90 m")
#  cota(58.2, 115.29, 58.2, 128.75, 0.4, "13.46")
#  cota(14.0, 117.9, 14.0, 122.98, 0.4, "5.08")
#fin
#: The thin red lines are the cuts between slices; the thick one, the 20 chords that form the base. The green arrows are the anchors **replaced by their force at the head**, as GEO5 does.

## 5 · The weight of each slice

#: On a vertical of abscissa x and with the slice base at elevation z_{d}, there is soil 2 from z_{d} up to its top z_{s}(x), and above it, up to the ground z_{t}(x), wall or soil 1. The weight per meter of width of that column is:
#: q(x) = γ_{2}·max(0, z_{s} − z_{d}) + γ_{u}·max(0, z_{t} − max(z_{s}, z_{d}))
#: and the slice weight is the integral of q(x) over its width. Between two breaks of the profile all the lines are straight, so q(x) is a line: the **Simpson rule** between breaks gives the exact integral. The breaks are the vertices of the ground and of the top of soil 2 that fall inside the slice, and the point where the chord cuts the top of soil 2.
B_k = [7.89; 11.54; 17.2; 17.25; 19; 20; 21.5; 26.5; 29.8; 32.39; 36.16; 36.18; 38.69; 41; 41.5] 'breaks of the profile inside the circle [m]
#: The same, multiplying each layer by the elevation of its center, gives the static moment and with it the elevation of the center of gravity z_{g} of each slice (only used in section 9, with earthquake).
#: **Surcharges.** The strip one is added to the slice weight over the width that falls inside: q·(min(x_{2}, end) − max(x_{1}, start)).
#hide
q_d(x, a, s) = gamma_2·max(0, z_s(x) - a - s·x) + g_u(x)·max(0, z_t(x) - max(z_s(x), a + s·x))
m_d(x, a, s) = gamma_2·max(0, z_s(x) - a - s·x)·(z_s(x) + a + s·x)/2 + g_u(x)·max(0, z_t(x) - max(z_s(x), a + s·x))·(z_t(x) + max(z_s(x), a + s·x))/2
r_e = 1e-9
W_s = zeros(n, 1)
W_q = zeros(n, 1)
W = zeros(n, 1)
M_z = zeros(n, 1)
z_g = zeros(n, 1)
x_M = zeros(n, 1)
al = zeros(n, 1)
l_b = zeros(n, 1)
d_b = zeros(n, 1)
f_2 = zeros(n, 1)
P_t = zeros(30, 1)
for i = 1:n
  s_i = (Z_i(i + 1) - Z_i(i))/b
  a_i = Z_i(i) - s_i·X_i(i)
  m = 1
  P_t(1) = X_i(i)
  for k = 1:15
    if B_k(k) > X_i(i)
      if B_k(k) < X_i(i + 1)
        m = m + 1
        P_t(m) = B_k(k)
      end
    end
  end
  m = m + 1
  P_t(m) = X_i(i + 1)
  w_i = 0
  y_i = 0
  for j = 1:m - 1
    p = P_t(j) + r_e
    q = P_t(j + 1) - r_e
    g_1 = z_s(p) - a_i - s_i·p
    g_2 = z_s(q) - a_i - s_i·q
    if g_1·g_2 < 0
      r = p + (q - p)·g_1/(g_1 - g_2)
      w_i = w_i + (r - p)·(q_d(p, a_i, s_i) + 4·q_d((p + r)/2, a_i, s_i) + q_d(r, a_i, s_i))/6 + (q - r)·(q_d(r, a_i, s_i) + 4·q_d((r + q)/2, a_i, s_i) + q_d(q, a_i, s_i))/6
      y_i = y_i + (r - p)·(m_d(p, a_i, s_i) + 4·m_d((p + r)/2, a_i, s_i) + m_d(r, a_i, s_i))/6 + (q - r)·(m_d(r, a_i, s_i) + 4·m_d((r + q)/2, a_i, s_i) + m_d(q, a_i, s_i))/6
    else
      w_i = w_i + (q - p)·(q_d(p, a_i, s_i) + 4·q_d((p + q)/2, a_i, s_i) + q_d(q, a_i, s_i))/6
      y_i = y_i + (q - p)·(m_d(p, a_i, s_i) + 4·m_d((p + q)/2, a_i, s_i) + m_d(q, a_i, s_i))/6
    end
  end
  o_1 = max(0, min(X_i(i + 1), e_1) - max(X_i(i), a_1))
  o_2 = max(0, min(X_i(i + 1), e_2) - max(X_i(i), a_2))
  W_s(i) = w_i
  W_q(i) = q_1·o_1 + q_2·o_2
  W(i) = W_s(i) + W_q(i)
  x_m = (X_i(i) + X_i(i + 1))/2
  M_z(i) = y_i + q_1·o_1·z_t(max(X_i(i), a_1) + o_1/2) + q_2·o_2·z_t(max(X_i(i), a_2) + o_2/2)
  z_g(i) = M_z(i)/W(i)
  x_M(i) = x_m
  al(i) = atan(s_i)
  l_b(i) = b/cos(al(i))
  d_b(i) = sqrt(R^2 - l_b(i)^2/4)
  f_2(i) = max(0, min(1, (x_x - X_i(i))/b))
end
#show
#: This is how the 20 slices turn out (W in kN/m, including the surcharge; α in degrees; f_{2} is the part of the base that is in soil 2):
#hide
Tab_1 = zeros(10, 7)
Tab_2 = zeros(10, 7)
for i = 1:10
  Tab_1(i, :) = [i, round(X_i(i), 3), round(X_i(i + 1), 3), round(W_s(i), 3), round(W_q(i), 3), round(al(i)·180/pi, 3), round(f_2(i), 3)]
  k = i + 10
  Tab_2(i, :) = [k, round(X_i(k), 3), round(X_i(k + 1), 3), round(W_s(k), 3), round(W_q(k), 3), round(al(k)·180/pi, 3), round(f_2(k), 3)]
end
#show
#: Columns: slice · x_{1} · x_{2} [m] · weight of soil and wall [kN/m] · surcharge [kN/m] · α [°] · f_{2}. Slices 1 to 10 and 11 to 20:
Tab_1
Tab_2
W_T = sum(W) 'total weight of the sliding mass, with surcharges [kN/m]
#: Slice 16 (from 38.40 to 40.44) is the one that crosses the contact: its base is one third in soil 2 and two thirds in soil 1.

## 6 · The moment that makes the mass rotate

#: GEO5 (Spencer help: "the line of action of the weight of block passes through the center of the segment of slip surface") applies the weight of each slice on the vertical of the **center of its base**, x_{M}. The arm with respect to the center of the circle is x_{M} − x_{c}; slices to the left of the center subtract:
#: M_{a} = Σ W_{i}·(x_{M,i} − x_{c})
M_a = sum(W.*(x_M - x_c)) 'moment that makes it rotate [kN·m/m]
M_at = M_a/9.80665 'the same in tonf·m/m

## 7 · The anchors

#: GEO5 replaces each anchor with a **compression force at its head**, directed along the anchor into the slope: (P·cos β, −P·sin β). That force enters in two places:
#: — **Moment.** About the center of the circle its moment is r × F, with r the vector from the center to the head. It is opposite to the rotation of the mass: it **resists**.
#: — **Normal at the base** of the slice where the head is: it presses on the base and gives more friction.
c_b = cos(beta_a·pi/180) 'cosine of the anchor inclination
s_b = sin(beta_a·pi/180) 'sine of the anchor inclination
M_an = P_a·((x_c - x_h1)·s_b + (z_c - z_h1)·c_b) + P_a·((x_c - x_h2)·s_b + (z_c - z_h2)·c_b) 'resisting moment of the two anchors [kN·m/m]
k_1 = floor((x_h1 - x_a)/b) + 1 'slice where the head of anchor 1 is
k_2 = floor((x_h2 - x_a)/b) + 1 'slice where the head of anchor 2 is
#hide
F_n = zeros(n, 1)
F_v = zeros(n, 1)
F_n(k_1) = P_a·sin(al(k_1) + beta_a·pi/180)
F_n(k_2) = F_n(k_2) + P_a·sin(al(k_2) + beta_a·pi/180)
F_v(k_1) = P_a·s_b
F_v(k_2) = F_v(k_2) + P_a·s_b
#show
#: At the base of its slice, the anchor force makes the angle α + β with the base and contributes to the normal P·sin(α + β) (Fellenius) or, in the vertical equilibrium of Bishop, its vertical component P·sin β.

## 8 · Fellenius and Bishop

#: **The resistance of the base.** In each slice, the shear the base can give is c·l + N·tan φ. Where the base is shared between two soils (slice 16), each part with its c and φ, in the proportion f_{2} and 1 − f_{2}:
t_1 = tan(phi_1·pi/180) 'tan φ of soil 1
t_2 = tan(phi_2·pi/180) 'tan φ of soil 2
#: **The shear arm.** The shear goes along the chord; its distance to the center is the apothem d = √(R² − l²/4), slightly less than R. The normal passes through the center (the perpendicular through the midpoint of a chord passes through the center of the circle) and gives no moment.
#: **Fellenius / Petterson** (no interslice forces, Petterson 1955). The normal is the projection of the loads on the normal to the base:
#: N_{i} = W_{i}·cos α_{i} + F_{n,i}
#: M_{p} = Σ d_{i}·[c̄_{i}·l_{i} + N_{i}·tan φ̄_{i}] + M_{an}
#hide
N_F = W.*cos(al) + F_n
M_pF = sum(d_b.*((f_2·c_2 + (1 - f_2)·c_1).*l_b + N_F.*(f_2·t_2 + (1 - f_2)·t_1))) + M_an
#show
M_pF = M_pF 'Fellenius resisting moment [kN·m/m]
FS_F = M_pF/M_a 'Fellenius safety factor
#: **Simplified Bishop** (interslice forces only horizontal, Bishop 1955). The normal comes from the vertical equilibrium of each slice, and the base shear becomes (GEO5 help, Bishop formula):
#: T_{i} = [c·b + (W_{i} + F_{v,i})·tan φ] / [cos α_{i} + tan φ·sin α_{i}/FS]
#: M_{p} = Σ d_{i}·T_{i} + M_{an}
#: FS appears on both sides: it is iterated starting from FS = 1. Each round prints the FS of that round:
F_k = 1
for k = 1:6
  F_k = (sum(d_b.*(f_2.*(c_2·b + (W + F_v)·t_2)./(cos(al) + t_2·sin(al)/F_k) + (1 - f_2).*(c_1·b + (W + F_v)·t_1)./(cos(al) + t_1·sin(al)/F_k))) + M_an)/M_a
  disp(F_k)
end
#hide
for k = 1:60
  F_k = (sum(d_b.*(f_2.*(c_2·b + (W + F_v)·t_2)./(cos(al) + t_2·sin(al)/F_k) + (1 - f_2).*(c_1·b + (W + F_v)·t_1)./(cos(al) + t_1·sin(al)/F_k))) + M_an)/M_a
end
M_pB = sum(d_b.*(f_2.*(c_2·b + (W + F_v)·t_2)./(cos(al) + t_2·sin(al)/F_k) + (1 - f_2).*(c_1·b + (W + F_v)·t_1)./(cos(al) + t_1·sin(al)/F_k))) + M_an
#show
M_pB = M_pB 'Bishop resisting moment [kN·m/m]
FS_B = M_pB/M_a 'Bishop safety factor
#hide
r_FB = round(FS_B, 2)
r_FF = round(FS_F, 2)
r_an = round(100·M_an/M_pB, 1)
FS_B0 = (M_pB - M_an)/M_a
r_B0 = round(FS_B0, 2)
#show
#: **Reading.** Bishop gives FS = @{r_FB} and Fellenius @{r_FF}: both > 1.50. Fellenius falls below because, by removing the interslice forces, it presses less on the base. The anchors give @{r_an} % of the resisting moment; removing only that moment (and leaving the normal they give at the base) the Bishop FS would drop to @{r_B0}.

## 9 · Hekatan against GEO5

#hide
g_Ma = 97599.49439901125
g_MpF = 169482.57230579364
g_MpB = 174520.6917076903
g_FF = 1.7365107611408959
g_FB = 1.7881311043908268
x_Ma = round(100·(M_a/g_Ma - 1), 4)
x_MpF = round(100·(M_pF/g_MpF - 1), 4)
x_MpB = round(100·(M_pB/g_MpB - 1), 4)
x_FF = round(100·(FS_F/g_FF - 1), 4)
x_FB = round(100·(FS_B/g_FB - 1), 4)
h_Ma = round(M_a, 2)
h_MpF = round(M_pF, 2)
h_MpB = round(M_pB, 2)
h_FF = round(FS_F, 5)
h_FB = round(FS_B, 5)
h_a1 = round(a_1g, 3)
h_a2 = round(a_2g, 3)
#show
#: The GEO5 values were read **from Demo01.gst itself** (GEO5 stores the result of each analysis in float64; on screen it rounds to 1.79 and 1.74):
#| Magnitud | Hekatan | GEO5 2024 | Diferencia [%] |
#|---|---:|---:|---:|
#| ángulo de entrada [°] | @{h_a1} | -7.573 | — |
#| ángulo de salida [°] | @{h_a2} | 41.041 | — |
#| M_{a} [kN·m/m] | @{h_Ma} | 97599.49 | @{x_Ma} |
#| M_{p} Fellenius [kN·m/m] | @{h_MpF} | 169482.57 | @{x_MpF} |
#| M_{p} Bishop [kN·m/m] | @{h_MpB} | 174520.69 | @{x_MpB} |
#| **FS Fellenius / Petterson** | @{h_FF} | 1.73651 | @{x_FF} |
#| **FS Bishop** | @{h_FB} | 1.78813 | @{x_FB} |
#: **Honest reading.** The FS matches in the first four digits with both methods (difference ≤ 0.02 %). The moments come out between 0.007 % and 0.02 % above. What remains has **not** been closed: with the GEO5 FS and angle δ, the first Spencer interslice force (sheet 113) comes out 0.08 % high, which indicates that the weight of the GEO5 slices is not exactly the polygon area used here. Closing it requires extracting from the binary (SlopeStability_5.dll) how GEO5 computes the area of each slice; no factor has been inserted to force it.
#: **What was tried and is NOT what GEO5 does** (with the Python reference): cutting the slices at the profile vertices (M_{a} −0.48 %); weight at the center of gravity instead of the center of the base (M_{a} +0.07 %); base not split at the soil crossing (FS −0.36 %); exact arc instead of chord (M_{a} +0.18 %).
#: **The other GEO5 methods on this circle** (read from the .gst): Spencer 1.89988 (sheet 113), Janbu 1.89871, Morgenstern-Price 1.89871, Shachunyanc 1.84380, ITFM 1.98778, ITFM explicit solution 1.91459. All > 1.50.

## 10 · Check with NEC-SE-GC 2015

#: Stage 3 is a permanent situation: NEC-SE-GC 2015, Table 4 (p. 31), asks for shear FS ≥ **1.50** (static slope, normal groundwater). Bishop @{r_FB} and Fellenius @{r_FF}: **it complies** with both.
#: **Pseudostatic (Hekatan calculation, not checked against GEO5: the example has no earthquake).** k_{h} = 0.6·Z·F_{a} (note of Table 4); zone V, soil D: Z = 0.40, F_{a} = 1.2. The force k_{h}·W acts horizontally toward the front, at the center of gravity of each slice (with the surcharge at ground elevation), and its arm with respect to the center is z_{c} − z_{g}. It is how GEO5 does it in sheet 96 (measured there): in Bishop the normal does not change; in Fellenius it loses k_{h}·W·sin α.
Z_s = 0.4 'seismic zone factor (zone V)
F_as = 1.2 'soil amplification, profile D, zone V
k_h = 0.6·Z_s·F_as 'horizontal seismic coefficient (NEC-15)
M_as = M_a + k_h·sum(W.*(z_c - z_g)) 'moment that makes it rotate, with earthquake [kN·m/m]
#hide
F_s = 1
for k = 1:60
  F_s = (sum(d_b.*(f_2.*(c_2·b + (W + F_v)·t_2)./(cos(al) + t_2·sin(al)/F_s) + (1 - f_2).*(c_1·b + (W + F_v)·t_1)./(cos(al) + t_1·sin(al)/F_s))) + M_an)/M_as
end
N_s = W.*cos(al) - k_h·W.*sin(al) + F_n
#show
FS_Bs = F_s 'Bishop with earthquake
FS_Fs = (sum(d_b.*((f_2·c_2 + (1 - f_2)·c_1).*l_b + N_s.*(f_2·t_2 + (1 - f_2)·t_1))) + M_an)/M_as 'Fellenius with earthquake
#hide
r_Bs = round(FS_Bs, 3)
r_Fs = round(FS_Fs, 3)
#show
#: With k_{h} = 0.288, Bishop gives @{r_Bs} and Fellenius @{r_Fs}: it **does not comply** with the **1.05** that NEC-15 asks for on this circle; with an earthquake more anchorage would be needed (the NEC-SE-GC 2023 draft, **unofficial**, asks 1.15 with k_{h} = 0.6·Z = 0.24, without F_{a}). Note: this is only this circle; with an earthquake the critical circle is another one and has to be searched for (GEO5: Analysis type = optimization).
