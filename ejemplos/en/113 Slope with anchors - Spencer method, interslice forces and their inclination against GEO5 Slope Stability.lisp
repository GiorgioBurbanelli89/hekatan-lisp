# Slope with anchors by the Spencer method: interslice forces and their inclination, against GEO5
#numerico

#: **What is computed.** The same slope and the same circle as sheet 112 (Demo01.gst of GEO5 Slope Stability, stage 3), now with the **Spencer** method: a "rigorous" method that satisfies force **and** moment equilibrium of **each** slice. Besides the FS it gives the **interslice forces** E_{i} and their inclination δ.
#: **Why it matters.** Bishop (sheet 112) neglects the shear between slices and only satisfies moment equilibrium of the whole mass. Spencer neglects nothing: it assumes that all interslice forces have **the same inclination δ** and looks for the δ and the FS that satisfy forces and moments at once. NEC-SE-GC 2015 cites the USACE manual EM 1110-2-1902, which recommends this method.
#: **How.** The five equations and the two recurrences from the GEO5 2024 help (page "Spencer"), read from the help file itself.
#: **Judge.** GEO5 2024 stores in Demo01.gst the FS, the δ and the 19 forces E_{i} of its calculation, unrounded: they are compared one by one.
#: **Units.** kN, m and kPa per meter of slope.

## 1 · Data (those of sheet 112)

#: Soils, ground, top of soil 2, surcharges, anchors and circle of stage 3 (see sheet 112, section 1):
gamma_1 = 20 'soil 1 (silt): unit weight [kN/m3]
phi_1 = 21 'soil 1: friction [degrees]
c_1 = 12 'soil 1: cohesion [kPa]
gamma_2 = 18 'soil 2 (sandy silt): unit weight [kN/m3]
phi_2 = 26.5 'soil 2: friction [degrees]
c_2 = 16 'soil 2: cohesion [kPa]
gamma_R = 25 'toe wall (rigid body): unit weight [kN/m3]
T_A = [-20; 0; 7.89; 11.54; 17.2; 17.25; 19; 20; 21.5; 26.5; 29.8; 32.39; 36.16; 38.69; 41; 41.5; 53; 54] 'ground: start of each segment [m]
T_B = [0; 7.89; 11.54; 17.2; 17.25; 19; 20; 21.5; 26.5; 29.8; 32.39; 36.16; 38.69; 41; 41.5; 53; 54; 70] 'ground: end of each segment [m]
Z_A = [115.32; 115.32; 115.2; 116.85; 117.99; 119; 119; 122.98; 122.98; 122.98; 124.92; 125.92; 127.92; 128.51; 128.67; 127.5; 127.5; 128.75] 'ground: elevation at the start [m]
Z_B = [115.32; 115.2; 116.85; 117.99; 118; 119; 122.98; 122.98; 122.98; 124.92; 125.92; 127.92; 128.51; 128.67; 127.5; 127.5; 128.75; 128.75] 'ground: elevation at the end [m]
S_A = [-20; 0; 7.89; 11.54; 17.2; 21.5; 36.18; 53.99] 'top of soil 2: start of each segment [m]
S_B = [0; 7.89; 11.54; 17.2; 21.5; 36.18; 53.99; 70] 'top of soil 2: end [m]
Y_A = [115.32; 115.32; 115.2; 116.85; 117.99; 120.02; 120.75; 121.7] 'top of soil 2: elevation at the start [m]
Y_B = [115.32; 115.2; 116.85; 117.99; 117.9; 120.75; 121.7; 122.34] 'top of soil 2: elevation at the end [m]
q_1 = 12 'surcharge 1, from x = 22.4 to 25.9 [kPa]
q_2 = 160 'surcharge 2, from x = 42 to 52 [kPa]
x_h1 = 29.29 'head of anchor 1, x [m]
z_h1 = 124.62 'head of anchor 1, z [m]
x_h2 = 33.97 'head of anchor 2, x [m]
z_h2 = 126.76 'head of anchor 2, z [m]
P_a = 200 'force of each anchor per meter [kN/m]
beta_a = 30 'inclination of the anchors below the horizontal [degrees]
x_c = 14.56 'center of the circle, x [m]
z_c = 166.63 'center of the circle, z [m]
R = 51.88 'radius [m]
n = 20 'slices of equal width, as GEO5 (sheet 112, section 4)
#: The profile functions (sheet 112, section 2):
dentro(x, a, b) = (sign(x - a) + 1).*(sign(b - x) + 1)/4
z_t(x) = sum(dentro(x, T_A, T_B).*(Z_A + (x - T_A).*(Z_B - Z_A)./(T_B - T_A)))
z_s(x) = sum(dentro(x, S_A, S_B).*(Y_A + (x - S_A).*(Y_B - Y_A)./(S_B - S_A)))
z_o(x) = z_c - sqrt(R^2 - (x - x_c)^2)
g_u(x) = gamma_R + (gamma_1 - gamma_R)·(sign(x - 21.5) + 1)/2
q_d(x, a, s) = gamma_2·max(0, z_s(x) - a - s·x) + g_u(x)·max(0, z_t(x) - max(z_s(x), a + s·x))

## 2 · The 20 slices (the same calculation as sheet 112)

#: Circle entry and exit, crossing with the top of soil 2, chords, weights by Simpson between breaks and surcharges: the block of sheet 112, section 5, hidden here.
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
b = (x_b - x_a)/n
B_k = [7.89; 11.54; 17.2; 17.25; 19; 20; 21.5; 26.5; 29.8; 32.39; 36.16; 36.18; 38.69; 41; 41.5]
X_i = zeros(n + 1, 1)
Z_i = zeros(n + 1, 1)
for i = 1:n + 1
  X_i(i) = x_a + (i - 1)·b
  Z_i(i) = z_o(X_i(i))
end
r_e = 1e-9
W = zeros(n, 1)
al = zeros(n, 1)
c_m = zeros(n, 1)
t_m = zeros(n, 1)
x_M = zeros(n, 1)
z_M = zeros(n, 1)
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
  for j = 1:m - 1
    p = P_t(j) + r_e
    q = P_t(j + 1) - r_e
    g_1 = z_s(p) - a_i - s_i·p
    g_2 = z_s(q) - a_i - s_i·q
    if g_1·g_2 < 0
      r = p + (q - p)·g_1/(g_1 - g_2)
      w_i = w_i + (r - p)·(q_d(p, a_i, s_i) + 4·q_d((p + r)/2, a_i, s_i) + q_d(r, a_i, s_i))/6 + (q - r)·(q_d(r, a_i, s_i) + 4·q_d((r + q)/2, a_i, s_i) + q_d(q, a_i, s_i))/6
    else
      w_i = w_i + (q - p)·(q_d(p, a_i, s_i) + 4·q_d((p + q)/2, a_i, s_i) + q_d(q, a_i, s_i))/6
    end
  end
  o_1 = max(0, min(X_i(i + 1), 25.9) - max(X_i(i), 22.4))
  o_2 = max(0, min(X_i(i + 1), 52) - max(X_i(i), 42))
  W(i) = w_i + q_1·o_1 + q_2·o_2
  al(i) = atan(s_i)
  f_2 = max(0, min(1, (x_x - X_i(i))/b))
  c_m(i) = f_2·c_2 + (1 - f_2)·c_1
  t_m(i) = f_2·tan(phi_2·pi/180) + (1 - f_2)·tan(phi_1·pi/180)
  x_M(i) = (X_i(i) + X_i(i + 1))/2
  z_M(i) = (Z_i(i) + Z_i(i + 1))/2
end
#show
W_T = sum(W) 'total weight with surcharges (sheet 112: 5324.90) [kN/m]
b = b 'width of each slice [m]
#: In slice 16 the base is split between the two soils; Spencer carries a single N per slice, so the mix c̄ = f_{2}·c_{2} + (1 − f_{2})·c_{1} and tan φ̄ = f_{2}·tan φ_{2} + (1 − f_{2})·tan φ_{1} is used, which is the same as splitting N in that proportion.

## 3 · The anchors as forces on the slice

#: Each anchor is a force at its head (sheet 112, section 7). In the GEO5 Spencer equations it enters as an external force on the slice: horizontal Fx (positive toward +x, into the slope), vertical Fy (positive upward) and its moment M1 about the center M of the slice base (positive counterclockwise):
F_x = P_a·cos(beta_a·pi/180) 'horizontal component of each anchor [kN/m]
F_y = -P_a·sin(beta_a·pi/180) 'vertical component (downward, negative) [kN/m]
k_1 = floor((x_h1 - x_a)/b) + 1 'slice of anchor 1
k_2 = floor((x_h2 - x_a)/b) + 1 'slice of anchor 2
#hide
Fx = zeros(n, 1)
Fy = zeros(n, 1)
M1 = zeros(n, 1)
Fx(k_1) = F_x
Fy(k_1) = F_y
M1(k_1) = (x_h1 - x_M(k_1))·F_y - (z_h1 - z_M(k_1))·F_x
Fx(k_2) = F_x
Fy(k_2) = F_y
M1(k_2) = (x_h2 - x_M(k_2))·F_y - (z_h2 - z_M(k_2))·F_x
#show
M1_11 = M1(k_1) 'moment of anchor 1 about the center of its slice base [kN·m/m]
M1_13 = M1(k_2) 'moment of anchor 2 about the center of its slice base [kN·m/m]

## 4 · The Spencer equations (GEO5 help)

#: On the base of slice i act the normal N_{i} and the shear T_{i}; on its faces, E_{i} (left) and E_{i+1} (right), inclined δ; plus the weight W_{i} (through the base center M) and the anchor forces.
#: **(2) Mohr-Coulomb with the FS:** T_{i} = N_{i}·tan φ_{i} + c_{i}·b_{i}/cos α_{i}, reduced by FS.
#: **(3) Equilibrium normal to the base:** N_{i} − (W_{i} − Fy_{i})·cos α_{i} − Fx_{i}·sen α_{i} + E_{i+1}·sen(α_{i} − δ) − E_{i}·sen(α_{i} − δ) = 0
#: **(4) Equilibrium along the base:** N_{i}·tan φ_{i}/FS + c_{i}·b_{i}/(FS·cos α_{i}) − (W_{i} − Fy_{i})·sen α_{i} + Fx_{i}·cos α_{i} − E_{i+1}·cos(α_{i} − δ) + E_{i}·cos(α_{i} − δ) = 0
#: Solving N from (3) and substituting it in (4) gives the **force recurrence** (formula (6) of the help), which gives E_{i+1} from E_{i}, starting with E_{1} = 0 at the toe:
#: E_{i+1} = {[(W − Fy)·cos α + Fx·sen α + E_{i}·sen(α − δ_{i})]·tan φ/FS + c·b/(FS·cos α) − (W − Fy)·sen α + Fx·cos α + E_{i}·cos(α − δ_{i})} / [sen(α − δ_{i+1})·tan φ/FS + cos(α − δ_{i+1})]
#: **(5) Moments of the slice about M** → the **lever-arm recurrence** (formula (7)): the height z_{i+1} of E_{i+1} above the base, starting with z_{1} = 0:
#: z_{i+1} = {b/2·[E_{i+1}·(sen δ_{i+1} − cos δ_{i+1}·tan α) + E_{i}·(sen δ_{i} − cos δ_{i}·tan α)] + E_{i}·z_{i}·cos δ_{i} − M1_{i}} / (E_{i+1}·cos δ_{i+1})
#: At both ends of the surface δ = 0 (help: "only at slip surface endpoint is δ = 0").
#: **The two closing conditions.** At the end (after the last slice) there is nothing: E_{n+1} = 0 (forces) and the last slice must be in moment equilibrium with E_{n+1} = 0 (moments). For each δ, the FS that satisfies the first is found by bisection; then the δ that satisfies the second is found, also by bisection.

## 5 · The solution

#hide
d_L = 0
d_U = 25·pi/180
E = zeros(n + 1, 1)
z_a = zeros(n + 1, 1)
d_v = zeros(n + 1, 1)
for o = 1:50
  for side = 1:2
    if side == 1
      dd = d_L
    else
      dd = (d_L + d_U)/2
    end
    for i = 2:n
      d_v(i) = dd
    end
    F_L = 1
    F_U = 3
    for k = 1:50
      for t = 1:2
        if t == 1
          FF = F_L
        else
          FF = (F_L + F_U)/2
        end
        E(1) = 0
        for i = 1:n
          a = al(i)
          E(i + 1) = (((W(i) - Fy(i))·cos(a) + Fx(i)·sin(a) + E(i)·sin(a - d_v(i)))·t_m(i)/FF + c_m(i)·b/(FF·cos(a)) - (W(i) - Fy(i))·sin(a) + Fx(i)·cos(a) + E(i)·cos(a - d_v(i)))/(sin(a - d_v(i + 1))·t_m(i)/FF + cos(a - d_v(i + 1)))
        end
        if t == 1
          e_L = E(n + 1)
        else
          e_M = E(n + 1)
        end
      end
      if e_L·e_M <= 0
        F_U = (F_L + F_U)/2
      else
        F_L = (F_L + F_U)/2
      end
    end
    FF = (F_L + F_U)/2
    E(1) = 0
    for i = 1:n
      a = al(i)
      E(i + 1) = (((W(i) - Fy(i))·cos(a) + Fx(i)·sin(a) + E(i)·sin(a - d_v(i)))·t_m(i)/FF + c_m(i)·b/(FF·cos(a)) - (W(i) - Fy(i))·sin(a) + Fx(i)·cos(a) + E(i)·cos(a - d_v(i)))/(sin(a - d_v(i + 1))·t_m(i)/FF + cos(a - d_v(i + 1)))
    end
    z_a(1) = 0
    for i = 1:n - 1
      a = al(i)
      z_a(i + 1) = (b/2·(E(i + 1)·(sin(d_v(i + 1)) - cos(d_v(i + 1))·tan(a)) + E(i)·(sin(d_v(i)) - cos(d_v(i))·tan(a))) + E(i)·z_a(i)·cos(d_v(i)) - M1(i))/(E(i + 1)·cos(d_v(i + 1)))
    end
    a = al(n)
    r_m = -E(n)·cos(d_v(n))·(z_a(n) - b/2·tan(a)) - E(n)·sin(d_v(n))·b/2 + M1(n)
    if side == 1
      r_L = r_m
    else
      r_M = r_m
    end
  end
  if r_L·r_M <= 0
    d_U = (d_L + d_U)/2
  else
    d_L = (d_L + d_U)/2
  end
end
FS_S = FF
d_S = (d_L + d_U)/2
#show
delta_S = d_S·180/pi 'inclination of the interslice forces δ [degrees]
FS_S = FS_S 'Spencer factor of safety
#: The interslice forces E_{2} … E_{20} [kN/m] and the height of their point of application above the base z [m] (at the end of each slice):
E_i = E(2:n) 'interslice forces [kN/m]
z_i = z_a(2:n) 'height of each E above the base [m]
#hide
r_FS = round(FS_S, 3)
r_d = round(delta_S, 2)
#show
#: **Reading.** FS = @{r_FS} with δ = @{r_d}°. The interslice forces **grow** from the toe (each slice on the left holds back those above), show **two jumps** at slices 11 and 13 (the anchors push the mass into the slope and increase the compression between slices) and fall to zero at the exit.
#: E_{i} from Hekatan (blue) and from GEO5 (red), at the abscissa of the cut; they are almost indistinguishable:
#fplot(Hekatan = [9.768 27.531; 11.813 68.686; 13.858 114.863; 15.903 160.988; 17.948 208.884; 19.993 265.505; 22.038 330.754; 24.083 377.754; 26.128 411.004; 28.173 431.663; 30.218 612.504; 32.264 607.873; 34.309 750.552; 36.354 716.686; 38.399 669.938; 40.444 600.923; 42.489 509.345; 44.534 334.382; 46.579 161.894], GEO5 = [9.768 27.519; 11.813 68.663; 13.858 114.848; 15.903 160.984; 17.948 209.151; 19.993 265.789; 22.038 331.001; 24.083 378.038; 26.128 411.322; 28.173 432.012; 30.218 612.905; 32.264 608.313; 34.309 751.045; 36.354 717.223; 38.399 670.517; 40.444 600.789; 42.489 509.225; 44.534 334.305; 46.579 161.858], [7 49])

## 5b · The slope, the circle and the interslice forces drawn

#: **How to read the drawing.** It is stage 3 of Demo01 to scale, in meters: the **ground** (light line), the **top of soil 2** (blue, dashed), the **toe wall** (hatched), the surcharges (12 kPa and 160 kPa, blue arrows), the two 200 kN **anchors** at 30° (green), the **failure circle** with its 20 slices (red, with the vertical lines of each slice). The **blue** region between the circle and its outer edge is the **interslice force diagram** E: at each cut, its horizontal width is E·cos δ to scale (1 m = 100 kN), hung at the height z of its point of application above the base. It grows from the toe upward up to cut 13 and falls on closing against the crest (E₂₁ = 0). The dimensions give the slope height, the width of the failure surface (from entry to exit) and the width b of each slice.
#hide
Xk = zeros(2*(n - 1), 1)
Yk = zeros(2*(n - 1), 1)
for i = 1:n - 1
  Xk(i) = X_i(i + 1)
  Yk(i) = Z_i(i + 1) + z_i(i)
  Xk(2*(n - 1) + 1 - i) = X_i(i + 1) + E_i(i)*cos(d_S)/100
  Yk(2*(n - 1) + 1 - i) = Z_i(i + 1) + z_i(i) - E_i(i)*sin(d_S)/100
end
#show
b_t = round(b, 2) 'slice width, for the label
#dibujo("Stage 3 of Demo01: slope, circle, 20 slices and diagram of the interslice force E (blue, 1 m = 100 kN)", ud = m, cotas = m, ancho = 190, alto = 120)
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
#  poligono(Xk, Yk, "azul tenue")
#  polilinea(Xk, Yk, "fina azul")
#  cota(x_a, 112.6, x_b, 112.6, -0.4, "entry to exit: 40.90 m")
#  cota(x_a, 113.6, x_a + b, 113.6, -0.3, "b")
#  cota(58.2, 115.29, 58.2, 128.75, 0.4, "13.46")
#  cota(14.0, 117.9, 14.0, 122.98, 0.4, "5.08")
#  texto(12.0, 110.9, "circle R = 51.88 m (the center is 50 m higher)", 2.4, "c", estilo = "rojo")
#fin
#: The drawing shows what the equations say: where the diagram widens, the upper slices push harder on the lower ones; the direction of E is toward the toe, inclined δ = @{r_d}° from the horizontal. The two largest forces (cuts 13 to 15, of the order of 600 to 750 kN/m) are those that move the block loaded by the 160 kPa and the anchors.
#: **The point of application.** The heights z stay inside the slice (between 0.3 and 3.4 m above the base, slice heights of 1 to 9 m): the "line of thrust" is reasonable, another sign that the solution is good.

## 6 · Hekatan against GEO5

#hide
G_E = [27.51938568613442; 68.6631; 114.848; 160.984; 209.151; 265.789; 331.001; 378.038; 411.322; 432.012; 612.905; 608.313; 751.045; 717.223; 670.517; 600.789; 509.225; 334.305; 161.858]
g_FS = 1.8998778176916171
g_d = 10.54406970739365
x_FS = round(100·(FS_S/g_FS - 1), 4)
x_d = round(100·(delta_S/g_d - 1), 4)
h_FS = round(FS_S, 5)
h_d = round(delta_S, 4)
D_1 = zeros(10, 4)
D_2 = zeros(9, 4)
e_mx = 0
for i = 1:19
  e_i = round(100·(E_i(i)/G_E(i) - 1), 3)
  e_mx = max(e_mx, abs(e_i))
  if i <= 10
    D_1(i, :) = [i + 1, round(E_i(i), 3), round(G_E(i), 3), e_i]
  else
    D_2(i - 10, :) = [i + 1, round(E_i(i), 3), round(G_E(i), 3), e_i]
  end
end
#show
#| Magnitud | Hekatan | GEO5 2024 | Diferencia [%] |
#|---|---:|---:|---:|
#| **FS de Spencer** | @{h_FS} | 1.89988 | @{x_FS} |
#| **δ [°]** | @{h_d} | 10.5441 | @{x_d} |
#: The 19 interslice forces. Columns: cut · E Hekatan [kN/m] · E GEO5 [kN/m] · difference [%]. Cuts 2 to 11 and 12 to 20:
D_1
D_2
#: The largest difference is at cut 6 (−0.128 %), at the foot of the wall.
#: **Honest reading.** The FS and the δ agree to three digits (0.04 % and 0.03 %). The 19 forces E are within 0.13 %; the largest differences are at cuts 6 to 15, those that touch the wall and the anchors. With the FS and the δ **of GEO5** put into the recurrence, the first E comes out 27.542 against 27.519 (0.08 %): the difference is not in the method but in the **weight** of the slices (the first slice has only soil 2, with no breaks). It is the same small difference as in sheet 112. Closing it requires reading in the binary (SlopeStability_5.dll) how GEO5 computes the area of a slice. No fudge factor has been introduced.

## 7 · The other rigorous methods and the NEC

#: Read from Demo01.gst (same circle, stage 3): Janbu 1.89871 and Morgenstern-Price 1.89871 (both within 0.06 % of Spencer, as expected from methods that satisfy all equilibria), Bishop 1.78813 and Fellenius 1.73651 (sheet 112).
#: **Spencer gives 6 % more than Bishop here (1.90 against 1.79).** The only difference in assumptions is the shear between slices: Bishop makes it zero and Spencer takes it as E·sen δ, with δ ≈ 10.5°. That shear, added over the faces, is what separates the two results.
#: **NEC-SE-GC 2015**, Table 4 (p. 31), static slope with normal water: FS ≥ 1.50. Spencer @{r_FS} → **complies**. (The 2023 draft, unofficial, keeps 1.50 for static.) For the pseudostatic check see sheet 112, section 10: in this circle it does not reach 1.05 with k_{h} = 0.288.
