# Global stability of the Manabí wall: Fellenius and Bishop slices against GEO5
#numerico

#: **What is checked.** The wall may not overturn or slide on its base and still fail **together with the ground**: the wall, the backfill and the supporting soil rotate as a single block on a circular surface that passes **below the footing**. It is the general stability (NEC-SE-GC, table 5).
#: **How it is calculated.** The mass above the circle is cut into **vertical slices**. The moment that makes it rotate about the center of the circle, M_{a}, is compared with the one that the base friction resists, M_{p}. The safety factor is the quotient of the two: FS = M_{p} / M_{a}.
#: **Units.** kN and m, per meter of wall. Where it matters it is also given in tonf (1 tonf = 9.80665 kN).
#: **Referee.** GEO5 2024 · Slope stability, with the same wall and the same ground (measured on 29-Sep-2026 through its interface). Python reference with the same formulation: the script estabilidad_rebanadas.py of the Manabí wall series (Hekatan School).

## 1 · Data
#: GEO5 axes: x = 0 at the backfill face of the stem, z = 0 at the top, z upward.
#: **Cantilever wall** of 3.00 m: 3.00 × 0.40 m footing (toe 0.70 m, heel 1.90 m), stem 0.25 m at the top and 0.40 m at the bottom. Its polygon: (−1.10; −3.00) (1.90; −3.00) (1.90; −2.60) (0; −2.60) (0; 0) (−0.25; 0) (−0.40; −2.60) (−1.10; −2.60).
γ_c = 23 [kN/m³] 'wall concrete
γ_r = 18.5 [kN/m³] 'SP sand: backfill (z = 0 to −3.00) and ground in front (z = −2.30 to −3.00)
γ_f = 17.5 [kN/m³] 'SP-SM silty sand, below z = −3.00 (soil study)
φ_r = 30 [°] 'SP sand, c = 0
φ_f = 29.97 [°] 'SP-SM silty sand, c = 0
#: The ground in front reaches z = −2.30: it covers 0.70 m of the footing base. It touches the inclined front of the stem at:
x_F = -0.25 - 0.15·2.3/2.6 [m]
#: **Pseudostatic earthquake** (NEC-SE-GC 4.2.2): a horizontal force k_{h}·W on each slice, with k_{h} = 0.6·Z·F_{a}; no vertical component (k_{v} = 0).
Z = 0.5 'seismic zone VI (NEC-SE-DS)
F_a = 1.12 'soil profile D (NEC-SE-DS, table 3)
k_h = 0.6·Z·F_a
#: **Required factors** (NEC-SE-GC, table 5, general stability): 1.50 without earthquake and 1.05 with earthquake.
#: **No water table in the model.** The soil study gives it at −3.05 m, 5 cm below the footing; it remains pending (with water the pore pressure subtracts from the normal and the FS drops).

## 2 · The circle with earthquake
#: It is the critical circle found by GEO5 with the Bishop method and optimization:
x_c = -1.21 [m] 'center, abscissa
z_c = 7.46 [m] 'center, elevation
R = 10.91 [m] 'radius
#: The circle exits through the ground in front (z = −2.30) and enters through the backfill (z = 0). They are the two intersections of the circle with those lines:
x_a = x_c - sqrt(R^2 - (z_c + 2.3)^2) [m]
x_b = x_c + sqrt(R^2 - z_c^2) [m]
#: [x_{a}, x_{b}] is divided into n slices of the same width:
n = 24 'slices
b = (x_b - x_a)/n [m] 'width of each slice
#: **The base of each slice is straight**: the chord between the two points of the circle. This is how GEO5 does it, replacing the arc with a polygonal. Measured: with the exact arc the moment comes out +0.2 % to +0.7 % above GEO5; with the chord and 24 slices, 0.02 % to 0.2 %.
#dibujo("Wall, ground, Bishop circle with earthquake and its 24 slices", ud = m, cotas = m, ancho = 175, alto = 175)
#  achurado([-1.1, 1.9, 1.9, 0, 0, -0.25, -0.4, -1.1], [-3, -3, -2.6, -2.6, 0, 0, -2.6, -2.6], "concreto")
#  poligono(-1.1, -3, 1.9, -3, 1.9, -2.6, 0, -2.6, 0, 0, -0.25, 0, -0.4, -2.6, -1.1, -2.6, "gruesa")
#  linea(-7, -2.3, -0.383, -2.3, "media")
#  linea(0, 0, 8, 0, "media")
#  linea(-7, -3, -1.1, -3, "trazos gris")
#  linea(1.9, -3, 8, -3, "trazos gris")
#  polilinea([-6.09, -6.09, -6.09, -5.55, -5.55, -5.55, -5.02, -5.02, -5.02, -4.48, -4.48, -4.48, -3.95, -3.95, -3.95, -3.41, -3.41, -3.41, -2.88, -2.88, -2.88, -2.34, -2.34, -2.34, -1.81, -1.81, -1.81, -1.27, -1.27, -1.27, -0.74, -0.74, -0.74, -0.20, -0.20, -0.20, 0.33, 0.33, 0.33, 0.87, 0.87, 0.87, 1.40, 1.40, 1.40, 1.94, 1.94, 1.94, 2.47, 2.47, 2.47, 3.01, 3.01, 3.01, 3.54, 3.54, 3.54, 4.08, 4.08, 4.08, 4.61, 4.61, 4.61, 5.15, 5.15, 5.15, 5.68, 5.68, 5.68, 6.22, 6.22, 6.22, 6.75, 6.75, 6.75], [-2.30, -2.30, -2.30, -2.55, -2.30, -2.55, -2.76, -2.30, -2.76, -2.95, -2.30, -2.95, -3.10, -2.30, -3.10, -3.23, -2.30, -3.23, -3.32, -2.30, -3.32, -3.39, -2.30, -3.39, -3.43, -2.30, -3.43, -3.45, -2.30, -3.45, -3.44, -2.30, -3.44, -3.40, 0.00, -3.40, -3.34, 0.00, -3.34, -3.25, 0.00, -3.25, -3.13, 0.00, -3.13, -2.99, 0.00, -2.99, -2.81, 0.00, -2.81, -2.60, 0.00, -2.60, -2.36, 0.00, -2.36, -2.08, 0.00, -2.08, -1.77, 0.00, -1.77, -1.41, 0.00, -1.41, -1.00, 0.00, -1.00, -0.53, 0.00, -0.53, 0.00, 0.00, 0.00], "fina azul")
#  polilinea([-6.086, -5.735, -5.379, -5.018, -4.652, -4.281, -3.907, -3.529, -3.148, -2.765, -2.380, -1.993, -1.605, -1.217, -0.829, -0.441, -0.054, 0.331, 0.714, 1.095, 1.473, 1.848, 2.218, 2.585, 2.946, 3.302, 3.653, 3.997, 4.335, 4.666, 4.989, 5.305, 5.612, 5.911, 6.200, 6.481, 6.751], [-2.300, -2.467, -2.622, -2.764, -2.893, -3.009, -3.111, -3.201, -3.277, -3.339, -3.387, -3.422, -3.443, -3.450, -3.443, -3.423, -3.389, -3.341, -3.279, -3.204, -3.115, -3.013, -2.897, -2.769, -2.627, -2.473, -2.306, -2.127, -1.936, -1.732, -1.518, -1.291, -1.054, -0.806, -0.547, -0.278, 0.000], "gruesa rojo")
#  linea(-1.21, 7.46, -6.086, -2.3, "fina trazos rojo")
#  linea(-1.21, 7.46, 6.751, 0, "fina trazos rojo")
#  circulo(-1.21, 7.46, 0.12, "rojo relleno")
#  texto(-1.0, 7.75, "center (−1.21; 7.46)", 2.6, "i", estilo = "rojo")
#  texto(3.4, 4.0, "R = 10.91 m", 2.6, "i", estilo = "rojo")
#  flecha(4.34, 1.2, 4.34, -0.96, "negro")
#  flecha(5.6, -0.96, 4.34, -0.96, "naranja")
#  texto(4.2, 0.9, "W_{i}", 2.6, "d")
#  texto(4.1, -1.5, "k_{h}·W_{i}", 2.6, "d", estilo = "naranja")
#  texto(2.2, 0.35, "SP fill", 2.4, "c")
#  texto(-5.0, -2.05, "SP ground", 2.4, "c")
#  texto(3.5, -3.75, "SP-SM", 2.4, "c", estilo = "gris")
#  texto(-6.1, -2.75, "x_{a}", 2.4, "d", estilo = "rojo")
#  texto(6.95, 0.3, "x_{b}", 2.4, "i", estilo = "rojo")
#fin
#: The arrows show the two loads of a slice: the weight W_{i}, vertical, and the earthquake force k_{h}·W_{i}, horizontal, toward the front of the wall, which is where the mass rotates. Both act at the center of gravity of the slice.

## 3 · The weight of each slice
#: On the vertical of abscissa x each material occupies a range of elevations [a, b]. Above the slice base (elevation z) only the part of the range above it weighs:
L_z(a, b, z) = max(0, b - max(a, z))
#: The weight of the column of width dx is Σ γ·L_{z}·dx over the three materials (concrete 23, sand 18.5, silty sand 17.5), and the slice weight is the sum of its columns. **400 columns** are taken per slice; with the straight base each column has its base elevation on the chord. The center of gravity (x_{g}, z_{g}) comes from the static moments of the same columns.
#: **Base inclination**: α_{i} = atan((z_{i+1} − z_{i}) / b). **Base friction**: φ = 29.97° if the midpoint of the base is below z = −3.00 (silty sand); otherwise, 30°.
#hide
u_v(x, a, b) = (sign(x - a) + 1)·(sign(b - x) + 1)/4
z_m(x) = (x + 0.25)·2.6/0.15
Q_z(a, b, z) = L_z(a, b, z)·(max(a, z) + b)/2
q_c(x, z) = γ_c·(u_v(x, -1.1, 1.9)·L_z(-3, -2.6, z) + u_v(x, -0.4, 0)·L_z(-2.6, min(0, z_m(x)), z))
q_r(x, z) = γ_r·(u_v(x, 0, 1.9)·L_z(-2.6, 0, z) + u_v(x, 1.9, 50)·L_z(-3, 0, z) + u_v(x, -50, -1.1)·L_z(-3, -2.3, z) + u_v(x, -1.1, x_F)·L_z(max(-2.6, z_m(x)), -2.3, z))
q_f(x, z) = γ_f·L_z(-40, -3, z)
m_z(x, z) = γ_c·(u_v(x, -1.1, 1.9)·Q_z(-3, -2.6, z) + u_v(x, -0.4, 0)·Q_z(-2.6, min(0, z_m(x)), z)) + γ_r·(u_v(x, 0, 1.9)·Q_z(-2.6, 0, z) + u_v(x, 1.9, 50)·Q_z(-3, 0, z) + u_v(x, -50, -1.1)·Q_z(-3, -2.3, z) + u_v(x, -1.1, x_F)·Q_z(max(-2.6, z_m(x)), -2.3, z)) + γ_f·Q_z(-40, -3, z)
s = 400
h = b/s
W = zeros(n, 1)
W_c = zeros(n, 1)
W_r = zeros(n, 1)
W_f = zeros(n, 1)
x_g = zeros(n, 1)
z_g = zeros(n, 1)
α = zeros(n, 1)
φ = zeros(n, 1)
x_i = zeros(n + 1, 1)
z_i = zeros(n + 1, 1)
for i = 1:n + 1
  x_i(i) = x_a + (i - 1)·b
  z_i(i) = z_c - sqrt(R^2 - (x_i(i) - x_c)^2)
end
for i = 1:n
  M_x = 0
  M_y = 0
  for k = 1:s
    x = x_i(i) + (k - 0.5)·h
    z = z_i(i) + (z_i(i + 1) - z_i(i))·(x - x_i(i))/b
    W_c(i) = W_c(i) + q_c(x, z)·h
    W_r(i) = W_r(i) + q_r(x, z)·h
    W_f(i) = W_f(i) + q_f(x, z)·h
    M_x = M_x + (q_c(x, z) + q_r(x, z) + q_f(x, z))·h·x
    M_y = M_y + m_z(x, z)·h
  end
  W(i) = W_c(i) + W_r(i) + W_f(i)
  x_g(i) = M_x/W(i)
  z_g(i) = M_y/W(i)
  α(i) = atan2(z_i(i + 1) - z_i(i), b)
  φ(i) = φ_r·pi/180
  if (z_i(i) + z_i(i + 1))/2 < -3
    φ(i) = φ_f·pi/180
  end
end
Reb_1 = zeros(8, 7)
Reb_2 = zeros(8, 7)
Reb_3 = zeros(8, 7)
for i = 1:8
  for j = 0:2
    k = i + 8·j
    F_l = [k, round(x_i(k), 4), round(x_i(k + 1), 4), round(W(k), 4), round(x_g(k), 4), round(z_g(k), 4), round(α(k)·180/pi, 4)]
    if j == 0
      Reb_1(i, :) = F_l
    end
    if j == 1
      Reb_2(i, :) = F_l
    end
    if j == 2
      Reb_3(i, :) = F_l
    end
  end
end
#show
#: **An example: slice 12**, the one that passes under the stem. Its weight by material, in kN:
W_c12 = W_c(12) [kN] 'concrete of the footing and the stem
W_r12 = W_r(12) [kN] 'SP fill
W_f12 = W_f(12) [kN] 'silty sand under the footing
W_12 = W_c12 + W_r12 + W_f12 [kN]
#: The concrete weighs almost half of the slice: the wall is the largest load on the circle, and it is on the side that makes it rotate.
#: **The 24 slices.** Columns: i · x_{1} · x_{2} [m] · W [kN] · x_{g} · z_{g} [m] · α [°]. Slices 1 to 8, 9 to 16 and 17 to 24:
Reb_1
Reb_2
Reb_3
#: The weight of each slice, drawn at the abscissa of its midpoint (values from the table above). The jump at x ≈ 0 is the wall:
#fplot(W_i = [-5.818 1.23; -5.283 3.53; -4.748 5.51; -4.214 7.15; -3.679 8.46; -3.144 9.49; -2.609 10.26; -2.074 10.79; -1.539 11.06; -1.004 11.74; -0.470 18.13; 0.065 36.49; 0.600 33.41; 1.135 32.44; 1.670 31.14; 2.205 28.68; 2.740 26.77; 3.274 24.55; 3.809 21.99; 4.344 19.05; 4.879 15.70; 5.414 11.90; 5.949 7.57; 6.484 2.63], [-6.2 6.9])
#: The base inclination: sin α of each chord (points) and sin α of the arc at each x (line, sin α = (x − x_{c}) / R). The points fall on the line because the chord is parallel to the tangent of the arc at its midpoint. To the left of the center the base rises toward the front (α < 0) and that part **brakes** the rotation; to the right it descends (α > 0) and **pushes**:
#fplot(arco = (x + 1.21)/10.91, cuerda = [-5.818 -0.4225; -5.283 -0.3735; -4.748 -0.3244; -4.214 -0.2754; -3.679 -0.2263; -3.144 -0.1773; -2.609 -0.1283; -2.074 -0.0792; -1.539 -0.0302; -1.004 0.0188; -0.470 0.0679; 0.065 0.1169; 0.600 0.1660; 1.135 0.2150; 1.670 0.2640; 2.205 0.3131; 2.740 0.3621; 3.274 0.4112; 3.809 0.4602; 4.344 0.5093; 4.879 0.5584; 5.414 0.6074; 5.949 0.6565; 6.484 0.7056], [-6.2 6.9])

## 4 · The moment that makes the mass rotate
#: About the center of the circle, the weight of a slice has horizontal arm (x_{g} − x_{c}) and the earthquake force, vertical arm (z_{c} − z_{g}). All slices are added:
#: M_{a} = Σ W_{i}·(x_{g,i} − x_{c}) + k_{h}·Σ W_{i}·(z_{c} − z_{g,i})
#: **Weight** part. The slices to the left of the center subtract, because their weight rotates in the opposite direction:
M_W = sum(W.*(x_g - x_c)) [kN·m/m]
#: **Earthquake** part. All add: the whole mass is below the center and the force goes toward the front:
M_S = k_h·sum(W.*(z_c - z_g)) [kN·m/m]
M_as = M_W + M_S [kN·m/m]
M_ast = M_as/9.80665 [tonf·m/m]
#: The earthquake contributes more than half of the moment that makes it rotate: with such a large circle the vertical arm z_{c} − z_{g} is about 10 m.

## 5 · Fellenius (Petterson)
#: **Hypothesis.** Each slice is treated alone: there are **no forces between slices** (neither normal E_{i} nor shear X_{i}). Only the moment equilibrium of the whole mass about the center is satisfied (GEO5 help, "Fellenius / Petterson"; Petterson, Géotechnique 5, 1955).
#: Without forces between slices, the normal at the base is the projection of the slice loads on the normal to its base: the weight presses with W·cos α; the earthquake, horizontal, with −k_{h}·W·sin α.
#: N_{i} = W_{i}·cos α_{i} − k_{h}·W_{i}·sen α_{i}
N = W.*cos(α) - k_h·W.*sin(α)
#: With c = 0 and no water, the base resists N·tan φ; its arm about the center is the radius R:
#: M_{p} = R·Σ N_{i}·tan φ_{i}
M_Fs = R·sum(N.*tan(φ)) [kN·m/m]
FS_Fs = M_Fs/M_as
#: With earthquake, Fellenius gives FS = @{FS_Fs} **< 1.05**: on this circle it does not comply.

## 6 · Simplified Bishop
#: **Hypothesis.** Between slices there are only **horizontal** forces (X_{i} = 0, no shear between slices). The **vertical equilibrium of each slice** and the moment equilibrium of the whole mass are satisfied (GEO5 help, "Bishop"; Bishop, Géotechnique 5(1):7-17, 1955).
#: **Where the normal comes from.** On the base act the normal N and the mobilized shear N·tan φ / FS. Vertical equilibrium of the slice: N·cos α + (N·tan φ / FS)·sin α = W. The earthquake is horizontal and does not enter this equation. Solving:
#: N_{i} = W_{i} / (cos α_{i} + tan φ_{i}·sen α_{i} / FS)
#: and the resisting moment is, as before, R·Σ N_{i}·tan φ_{i}:
#: M_{p} = R·Σ W_{i}·tan φ_{i} / (cos α_{i} + tan φ_{i}·sen α_{i} / FS)
#: **FS appears on both sides**: it has to be iterated. One starts with FS = 1, computes M_{p}, the new FS is M_{p} / M_{a}, and repeats until it does not change. Each turn of the loop prints the FS of that turn:
F_k = 1
for k = 1:8
  F_k = R·sum(W.*tan(φ)./(cos(α) + tan(φ).*sin(α)/F_k))/M_as
  disp(F_k)
end
#: By the fifth turn the first six digits no longer change. It continues until the difference between two turns is less than 10⁻¹²:
#hide
for k = 1:40
  F_k = R·sum(W.*tan(φ)./(cos(α) + tan(φ).*sin(α)/F_k))/M_as
end
#show
M_Bs = R·sum(W.*tan(φ)./(cos(α) + tan(φ).*sin(α)/F_k)) [kN·m/m]
FS_Bs = M_Bs/M_as
M_Bst = M_Bs/9.80665 [tonf·m/m]
#: With earthquake, Bishop gives FS = @{FS_Bs} **> 1.05**: it complies, with a margin of 4 %.
#: **Why Bishop gives more than Fellenius.** The two normals of the same slice are compared (φ = 30°, FS = 1.09). At the front, with α = −20°: Bishop gives 1.32·W and Fellenius 0.94·W. In the backfill, with α = 30°: Bishop gives 0.88·W and Fellenius 0.87·W − 0.17·W from the earthquake = 0.70·W. The interslice forces that Bishop keeps press on the base and give more friction; Fellenius removes them and stays on the safe side.

## 7 · Without earthquake
#: Without earthquake (k_{h} = 0) the GEO5 critical circle with Bishop is another one, smaller and closer to the wall:
x_ce = -0.9 [m]
z_ce = 1.47 [m]
R_e = 5.27 [m]
k_he = 0
x_ae = x_ce - sqrt(R_e^2 - (z_ce + 2.3)^2) [m]
x_be = x_ce + sqrt(R_e^2 - z_ce^2) [m]
#dibujo("Bishop circle without earthquake and its 24 slices", ud = m, cotas = m, ancho = 170, alto = 110)
#  achurado([-1.1, 1.9, 1.9, 0, 0, -0.25, -0.4, -1.1], [-3, -3, -2.6, -2.6, 0, 0, -2.6, -2.6], "concreto")
#  poligono(-1.1, -3, 1.9, -3, 1.9, -2.6, 0, -2.6, 0, 0, -0.25, 0, -0.4, -2.6, -1.1, -2.6, "gruesa")
#  linea(-5.5, -2.3, -0.383, -2.3, "media")
#  linea(0, 0, 5.5, 0, "media")
#  linea(-5.5, -3, -1.1, -3, "trazos gris")
#  linea(1.9, -3, 5.5, -3, "trazos gris")
#  polilinea([-4.58, -4.58, -4.58, -4.22, -4.22, -4.22, -3.85, -3.85, -3.85, -3.49, -3.49, -3.49, -3.13, -3.13, -3.13, -2.76, -2.76, -2.76, -2.40, -2.40, -2.40, -2.03, -2.03, -2.03, -1.67, -1.67, -1.67, -1.30, -1.30, -1.30, -0.94, -0.94, -0.94, -0.58, -0.58, -0.58, -0.21, -0.21, -0.21, 0.15, 0.15, 0.15, 0.52, 0.52, 0.52, 0.88, 0.88, 0.88, 1.25, 1.25, 1.25, 1.61, 1.61, 1.61, 1.98, 1.98, 1.98, 2.34, 2.34, 2.34, 2.70, 2.70, 2.70, 3.07, 3.07, 3.07, 3.43, 3.43, 3.43, 3.80, 3.80, 3.80, 4.16, 4.16, 4.16], [-2.30, -2.30, -2.30, -2.62, -2.30, -2.62, -2.89, -2.30, -2.89, -3.12, -2.30, -3.12, -3.31, -2.30, -3.31, -3.46, -2.30, -3.46, -3.58, -2.30, -3.58, -3.68, -2.30, -3.68, -3.74, -2.30, -3.74, -3.78, -2.30, -3.78, -3.80, -2.30, -3.80, -3.79, -2.30, -3.79, -3.75, 0.00, -3.75, -3.69, 0.00, -3.69, -3.61, 0.00, -3.61, -3.49, 0.00, -3.49, -3.34, 0.00, -3.34, -3.16, 0.00, -3.16, -2.95, 0.00, -2.95, -2.69, 0.00, -2.69, -2.38, 0.00, -2.38, -2.00, 0.00, -2.00, -1.53, 0.00, -1.53, -0.92, 0.00, -0.92, 0.00, 0.00, 0.00], "fina azul")
#  polilinea([-4.582, -4.361, -4.127, -3.884, -3.630, -3.368, -3.097, -2.819, -2.535, -2.246, -1.952, -1.654, -1.355, -1.053, -0.752, -0.450, -0.151, 0.147, 0.441, 0.730, 1.014, 1.292, 1.563, 1.826, 2.079, 2.323, 2.557, 2.779, 2.989, 3.186, 3.370, 3.540, 3.695, 3.835, 3.960, 4.068, 4.161], [-2.300, -2.505, -2.696, -2.874, -3.038, -3.187, -3.320, -3.438, -3.540, -3.625, -3.694, -3.746, -3.780, -3.798, -3.798, -3.781, -3.746, -3.695, -3.627, -3.542, -3.440, -3.322, -3.189, -3.040, -2.877, -2.699, -2.508, -2.304, -2.087, -1.858, -1.619, -1.370, -1.111, -0.844, -0.569, -0.287, -0.000], "gruesa rojo")
#  linea(-0.9, 1.47, -4.582, -2.3, "fina trazos rojo")
#  linea(-0.9, 1.47, 4.161, 0, "fina trazos rojo")
#  circulo(-0.9, 1.47, 0.08, "rojo relleno")
#  texto(-0.7, 1.7, "center (−0.90; 1.47)", 2.6, "i", estilo = "rojo")
#  texto(2.0, 1.0, "R = 5.27 m", 2.6, "i", estilo = "rojo")
#  texto(1.0, 0.25, "SP fill", 2.4, "c")
#  texto(-3.6, -2.05, "SP ground", 2.4, "c")
#  texto(3.3, -3.55, "SP-SM", 2.4, "c", estilo = "gris")
#fin
#: The same slice calculation is repeated with this circle and k_{h} = 0 (the same block as before, hidden):
#hide
x_c = x_ce
z_c = z_ce
R = R_e
k_h = k_he
x_a = x_ae
x_b = x_be
b = (x_b - x_a)/n
h = b/s
W = zeros(n, 1)
x_g = zeros(n, 1)
z_g = zeros(n, 1)
α = zeros(n, 1)
φ = zeros(n, 1)
for i = 1:n + 1
  x_i(i) = x_a + (i - 1)·b
  z_i(i) = z_c - sqrt(R^2 - (x_i(i) - x_c)^2)
end
for i = 1:n
  M_x = 0
  M_y = 0
  for k = 1:s
    x = x_i(i) + (k - 0.5)·h
    z = z_i(i) + (z_i(i + 1) - z_i(i))·(x - x_i(i))/b
    W(i) = W(i) + (q_c(x, z) + q_r(x, z) + q_f(x, z))·h
    M_x = M_x + (q_c(x, z) + q_r(x, z) + q_f(x, z))·h·x
    M_y = M_y + m_z(x, z)·h
  end
  x_g(i) = M_x/W(i)
  z_g(i) = M_y/W(i)
  α(i) = atan2(z_i(i + 1) - z_i(i), b)
  φ(i) = φ_r·pi/180
  if (z_i(i) + z_i(i + 1))/2 < -3
    φ(i) = φ_f·pi/180
  end
end
#show
#: Moment that makes it rotate (weight only):
M_ae = sum(W.*(x_g - x_c)) + k_h·sum(W.*(z_c - z_g)) [kN·m/m]
#: Fellenius:
M_Fe = R·sum((W.*cos(α) - k_h·W.*sin(α)).*tan(φ)) [kN·m/m]
FS_Fe = M_Fe/M_ae
#: Bishop, with the same iteration:
#hide
F_k = 1
for k = 1:60
  F_k = R·sum(W.*tan(φ)./(cos(α) + tan(φ).*sin(α)/F_k))/M_ae
end
#show
M_Be = R·sum(W.*tan(φ)./(cos(α) + tan(φ).*sin(α)/F_k)) [kN·m/m]
FS_Be = M_Be/M_ae
#: Without earthquake both comply with margin (FS > 1.50). Here the difference between the methods is larger (@{FS_Be} against @{FS_Fe}) because the circle is small and its bases are very inclined: α reaches −42° at the front and 68° in the backfill, and it is with large α that the interslice forces weigh most.

## 8 · Comparison with GEO5
#hide
d_1 = round(100·(M_as/2136.32 - 1), 3)
d_2 = round(100·(M_Bs/2333.60 - 1), 3)
d_3 = round(100·(FS_Bs/(2333.60/2136.32) - 1), 3)
d_4 = round(100·(M_Fs/2127.39 - 1), 3)
d_5 = round(100·(FS_Fs/(2127.39/2136.32) - 1), 3)
d_6 = round(100·(M_ae/434.85 - 1), 3)
d_7 = round(100·(M_Be/1011.77 - 1), 3)
d_8 = round(100·(FS_Be/(1011.77/434.85) - 1), 3)
d_9 = round(100·(M_Fe/841.35 - 1), 3)
d_10 = round(100·(FS_Fe/(841.35/434.85) - 1), 3)
#show
#: GEO5 2024 on the same circles, per meter of wall. The GEO5 FS is written as M_{p} / M_{a} with its moments (on screen it rounds it to two decimals: 1.09, 1.00, 2.33 and 1.93). The "Python" column is the reference with the same formulation.
#| Caso | Magnitud | Esta hoja | Python | GEO5 | Diferencia con GEO5 [%] |
#|---|---|---:|---:|---:|---:|
#| con sismo | M_{a} [kN·m/m] | @{M_as} | 2136.6737 | 2136.32 | @{d_1} |
#| con sismo | M_{p} Bishop [kN·m/m] | @{M_Bs} | 2336.0494 | 2333.60 | @{d_2} |
#| con sismo | FS Bishop | @{FS_Bs} | 1.0933 | 1.0923 | @{d_3} |
#| con sismo | M_{p} Fellenius [kN·m/m] | @{M_Fs} | 2129.6949 | 2127.39 | @{d_4} |
#| con sismo | FS Fellenius | @{FS_Fs} | 0.9967 | 0.9958 | @{d_5} |
#| sin sismo | M_{a} [kN·m/m] | @{M_ae} | 435.7314 | 434.85 | @{d_6} |
#| sin sismo | M_{p} Bishop [kN·m/m] | @{M_Be} | 1012.7970 | 1011.77 | @{d_7} |
#| sin sismo | FS Bishop | @{FS_Be} | 2.3244 | 2.3267 | @{d_8} |
#| sin sismo | M_{p} Fellenius [kN·m/m] | @{M_Fe} | 842.5051 | 841.35 | @{d_9} |
#| sin sismo | FS Fellenius | @{FS_Fe} | 1.9335 | 1.9348 | @{d_10} |
#: **Honest reading.** The sheet and Python agree: it is the same formulation. With GEO5 a difference of 0.02 % to 0.2 % remains in the moments and 0.1 % in the FS. It comes from **how GEO5 divides the mass into slices**: its help does not say how many it uses or where it places the cuts, and that is not known exactly. It changes no conclusion.

## 9 · The five GEO5 methods
#: GEO5 also calculates the problem with three other, more complete methods, which are **not calculated** here: they are cited with their result. Each method optimizes **its own** circle (that is why the Fellenius in the table is 0.95 and not the 0.9967 of the Bishop circle). Hypotheses taken from the official GEO5 help:
#| Método | Equilibrio que cumple | Fuerzas entre rebanadas | Con sismo | Sin sismo |
#|---|---|---|---:|---:|
#| Fellenius / Petterson | momentos de toda la masa | ninguna (E_{i} = X_{i} = 0) | 0.95 | 1.89 |
#| Bishop simplificado | momentos + verticales de cada rebanada | solo horizontales (X_{i} = 0) | 1.09 | 2.33 |
#| Janbu | fuerzas y momentos de cada rebanada | E_{i} a una altura supuesta | 1.11 | 2.33 |
#| Spencer | fuerzas y momentos de cada rebanada | E_{i} con la misma inclinación δ | 1.12 | 2.33 |
#| Morgenstern-Price | fuerzas y momentos de cada rebanada | E_{i} con inclinación λ·f(x) | 1.11 | 2.33 |
#: In Janbu the assumed height is near a third of the face, and the moment of the last slice is not satisfied. In Morgenstern-Price, f(x) is a half sine wave.
#: The three complete methods give 1.11–1.12 with earthquake: Bishop (1.09) is very close to them and on the safe side. Fellenius departs: it is the only one that does not comply.

## 10 · Conclusion
#: **With earthquake** the general stability **complies with Bishop** (1.09 > 1.05) and with Janbu, Spencer and Morgenstern-Price (1.11–1.12), and **does not comply with Fellenius** (0.95 < 1.05). The margin is small: 4 % over the minimum with Bishop.
#: **Without earthquake** it complies with all methods (1.89 to 2.33 > 1.50).
#: **Pending.** Two things from the soil study are not in this model and both lower the FS: the **water table** at −3.05 m (pore pressure at the base of the slices) and the **liquefiable stratum** from −3.05 to −6.00 m, which in an earthquake can lose its strength. With a 4 % margin they must be added before accepting the wall.
