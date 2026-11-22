# Seismic coefficients k_h and k_v of the pseudostatic analysis: where they come from, which code requires each one and how much they change the FS of the GEO5 anchored slope
#numerico

#: **What is calculated.** The slope with wall and two anchors of sheet 112 (GEO5 Slope Stability, **Demo01.gst**, stage 3, the example circle) with **pseudostatic earthquake**: a horizontal force k_{h}·W and a vertical one k_{v}·W on each slice. The Bishop and Fellenius FS are calculated with the k_{h} and k_{v} of each code (NEC-15, NEC 2023 draft, AASHTO, Eurocode 8, Hynes-Griffin and Franklin, Seed) and the **k_{y}** that gives FS = 1, which is the input of the displacement method of **Bray and Travasarou (2007)** that NEC cites.
#: **Why.** NEC-SE-GC 2015 only gives k_{h}; it says nothing about k_{v}. The 2023 draft does name it, but sets it to zero. Other codes do use it. Here it is measured how much it weighs.
#: **Judge.** With k_{h} = k_{v} = 0 the sheet reproduces the GEO5 FS of sheet 112 (1.78813 Bishop, 1.73651 Fellenius). With k_{h} = 0.288, GEO5 gives Bishop 1.00 and Fellenius 0.95 (captures of the «NEC slopes» series). **The cases with k_{v} ≠ 0 have not been checked against GEO5** (pending: GEO5 has the K_{v} field).
#: **Units.** kN, m and kPa per meter of slope (as GEO5); moments also in tonf·m/m (1 tonf = 9.80665 kN).

## 1 · What k_h and k_v are

#: **The idea (Terzaghi, 1950).** During the earthquake the soil accelerates. The mass that can slide, of weight W and mass W/g, receives an inertia force equal to mass × acceleration and opposite in direction to the acceleration. The pseudostatic method replaces it with a **fixed force** proportional to the weight:
#: F_{h} = (a_{h}/g)·W = k_{h}·W  (horizontal, outward from the slope: the unfavorable direction)
#: F_{v} = (a_{v}/g)·W = k_{v}·W  (vertical, upward or downward)
#: k_{h} and k_{v} are, therefore, accelerations measured in «g». Terzaghi proposed k_{h} = 0.1 (severe earthquake), 0.2 (violent) and 0.5 (catastrophic).
#: **Why k_{h} is less than the PGA.** The acceleration peak lasts a fraction of a second and does not act on the whole mass at once. If the FS drops below 1 during that instant, the mass moves a little and stops (**Newmark sliding block, 1965**). That is why a fraction of the peak is used:
#: — **Seed (1979)**, earth dams: k_{h} = 0.15 with FS ≥ 1.15.
#: — **Marcuson (1981)**: k_{h} between 1/3 and 1/2 of the maximum acceleration (with its amplification).
#: — **Hynes-Griffin and Franklin (1984)**, with the Newmark block on 354 accelerograms: k_{h} = 0.5·PGA/g, FS ≥ 1.0 with the strength reduced to 80 %; this way the displacement stays below 1 m.
#: — **NEC-SE-GC 2015**, Table 4, note (*), p. 31: k_{h} = 0.6·a_{max}/g with a_{max} = Z·F_{a}, FS ≥ 1.05, and «the seismic deformation demand of the slope shall be evaluated by the method of Bray JD and Travasarou T (2007)». **It does not mention k_{v}.** No paper has been found that justifies the 0.6 (the 0.5 yes).
#: — **NEC-SE-GC 2023 draft** (§8.1.5, p. 131-132, unofficial): «horizontal and vertical pseudostatic acceleration coefficients (kh and kv)»; a_{max} = Z (without F_{a}); k_{h} = 0.6·a_{max}; «when liquefaction effects are not considered, the vertical pseudostatic coefficient, kv, shall be equal to zero. This value of kh presupposes a slope deformation [...] between 2.5 and 5.0 cm». FS ≥ 1.15 (Table 8.2).
#: **Where k_{v} does enter.**
#: — **Eurocode 8-5 (EN 1998-5:2004) §4.1.3.3**, slopes: F_{H} = 0.5·α·S·W, F_{V} = ±0.5·F_{H} if a_{vg}/a_{g} > 0.6 and ±0.33·F_{H} otherwise (Pecker, 2011, slide 23). α = a_{g}/g, S = soil factor; Annex A adds the topographic amplification S_{T} = 1.2 to 1.4. **Walls** (§7.3.2.2): k_{h} = α·S/r, k_{v} = ±0.5·k_{h} or ±0.33·k_{h}; r = 2 if the wall admits up to 300·α·S mm, 1.5 if it admits 200·α·S mm, 1 for anchored walls, basement walls or abutments.
#: — **AASHTO LRFD BDS §11.6.5** (walls): k_{h0} = F_{pga}·PGA (zero displacement); k_{h} = 0.5·k_{h0} if the wall admits 1 to 2 in (25 to 50 mm); k_{v} = 0 except near-fault sites or high simultaneous vertical accelerations. Slopes: §11.5.8 and Appendix A11.5 (Kavazanjian et al. 1997; Anderson et al. 2008, NCHRP 611; Bray and Travasarou 2009).
#: — **FHWA-HI-99-012 (1998)**, ch. 7: a k_{v} ≤ k_{h} changes k_{y} by **no more than 10 %**, with one sign or the other depending on its direction; the vertical acceleration is out of phase with the horizontal one: it is usually ignored.
#: — **Walls: Mononobe-Okabe** (Okabe, 1926; Mononobe and Matsuo, 1929), cited by NEC-15 §5.2 (p. 37) and the 2023 draft (§8.3.9, Table 8.6, «kh and kv are the seismic coefficients in the horizontal and vertical direction»). It is the Coulomb wedge with the two inertias: the resultant of weight and inertias is inclined ψ = atan[k_{h}/(1 − k_{v})] and the thrust is P_{AE} = ½·γ·H²·(1 − k_{v})·K_{AE}. Here k_{v} does enter the formula. The draft gives for walls k_{h} = a_{max}·F_{top}·F_{d} (F_{d} = 0.3 to 0.7, Table 8.7) and does not set k_{v}.
#: — **NEC-SE-DS 2015 §3.4** (structures): E_{v} ≥ 2/3·E_{h}. It is for building cantilevers, **not** for slopes, but there are Ecuadorian studies that have applied it to the slope (k_{v} = 2/3·k_{h}).
#: **Sign of k_{v} (GEO5 convention, help «Earthquake Effect - Standard Analysis»).** K_{v} > 0 multiplies the weight of soil, water and surcharge by (1 − K_{v}): the mass **weighs less** (upward inertia); K_{v} < 0 makes it weigh more. «In case of a sufficiently large k_{h}, relieving the slope (K_{v} > 0) is more unfavorable than overloading it». The horizontal force is K_{h}·W_{i} at the center of gravity of the slice, with the surcharge included.

## 2 · What each code requires (for this slope: zone V, soil D)

#: Z = 0.40, F_{a} = 1.2 (NEC-SE-DS, Table 3). For comparison, in AASHTO and EC8 the surface PGA is taken equal to Z·F_{a} = 0.48 (in AASHTO it is F_{pga}·PGA; in EC8, α·S). **That equivalence is an assumption of this sheet.**
#| Fuente | k_{h} | k_{v} | FS mínimo | Desplazamiento que admite |
#|---|---|---|---|---|
#| NEC-SE-GC 2015, Tabla 4 (p. 31) | 0.6·Z·F_{a} = 0.288 | no lo menciona | 1.05 (1.00 con CV máxima) | evaluarlo con Bray y Travasarou (2007) |
#| Borrador NEC-SE-GC 2023, §8.1.5 | 0.6·Z = 0.24 | 0 (sin licuación) | 1.15 (1.10) | 2.5 a 5 cm |
#| AASHTO LRFD §11.6.5 / §11.5.8 | 0.5·F_{pga}·PGA = 0.24 | 0 (salvo campo cercano) | factor de resistencia, no leído | 25 a 50 mm |
#| Eurocódigo 8-5, §4.1.3.3 | 0.5·α·S = 0.24 (×S_{T}) | ±0.5·k_{h} o ±0.33·k_{h} | FS = 1 con factores parciales | no fijado |
#| Hynes-Griffin y Franklin (1984) | 0.5·PGA = 0.24 | no | 1.0 con resistencia al 80 % | < 1 m |
#| Seed (1979) | 0.15 | no | 1.15 | ~1 m (presas) |
#| Bray y Travasarou (2009) | k para D_{a} dado (sección 12) | no | 1.0 | el que se elija (5, 15, 30 cm) |
#| NEC-SE-DS §3.4 (estructuras) | — | 2/3·E_{h} | — | no es para taludes |

## 3 · Example data (Demo01.gst, stage 3)

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
#: **The stage 3 terrain** (with the stage 2 excavation between x = 41 and 54). Each segment goes from (T_{A}, Z_{A}) to (T_{B}, Z_{B}); the vertical step of the wall at x = 17.25 remains as a jump between segment 5 and 6:
T_A = [-20; 0; 7.89; 11.54; 17.2; 17.25; 19; 20; 21.5; 26.5; 29.8; 32.39; 36.16; 38.69; 41; 41.5; 53; 54] 'abscissa of the start of each terrain segment [m]
T_B = [0; 7.89; 11.54; 17.2; 17.25; 19; 20; 21.5; 26.5; 29.8; 32.39; 36.16; 38.69; 41; 41.5; 53; 54; 70] 'abscissa of the end of each segment [m]
Z_A = [115.32; 115.32; 115.2; 116.85; 117.99; 119; 119; 122.98; 122.98; 122.98; 124.92; 125.92; 127.92; 128.51; 128.67; 127.5; 127.5; 128.75] 'elevation of the start of each segment [m]
Z_B = [115.32; 115.2; 116.85; 117.99; 118; 119; 122.98; 122.98; 122.98; 124.92; 125.92; 127.92; 128.51; 128.67; 127.5; 127.5; 128.75; 128.75] 'elevation of the end of each segment [m]
#: **The top of soil 2.** Below this line there is soil 2; above it, the wall (from x = 17.2 to 21.5) or soil 1 (from x = 21.5). In front of the wall it coincides with the terrain:
S_A = [-20; 0; 7.89; 11.54; 17.2; 21.5; 36.18; 53.99] 'abscissa of the start of each segment of the top of soil 2 [m]
S_B = [0; 7.89; 11.54; 17.2; 21.5; 36.18; 53.99; 70] 'abscissa of the end [m]
Y_A = [115.32; 115.32; 115.2; 116.85; 117.99; 120.02; 120.75; 121.7] 'elevation of the start [m]
Y_B = [115.32; 115.2; 116.85; 117.99; 117.9; 120.75; 121.7; 122.34] 'elevation of the end [m]
#: **Strip surcharges** (permanent, on the terrain): 12 kPa from x = 22.40 to 25.90, and 160 kPa from x = 42.00 to 52.00, at the bottom of the excavation.
q_1 = 12 'surcharge 1 [kPa]
a_1 = 22.4 'start of surcharge 1 [m]
e_1 = 25.9 'end of surcharge 1 [m]
q_2 = 160 'surcharge 2 [kPa]
a_2 = 42 'start of surcharge 2 [m]
e_2 = 52 'end of surcharge 2 [m]
#: **Anchors** (stage 3): two, of 200 kN, 1 m apart, inclined 30° below the horizontal, with 14 m of free length:
x_h1 = 29.29 'head of anchor 1, x [m]
z_h1 = 124.62 'head of anchor 1, z [m]
x_h2 = 33.97 'head of anchor 2, x [m]
z_h2 = 126.76 'head of anchor 2, z [m]
P_a = 200 'force of each anchor per meter (200 kN every 1.00 m) [kN/m]
beta_a = 30 'inclination of the anchors below the horizontal [degrees]
#: **The circle** (Analysis, stage 3, «Circular slip surface»):
x_c = 14.56 'center of the circle, x [m]
z_c = 166.63 'center of the circle, z [m]
R = 51.88 'radius [m]
#: **What GEO5 requires in the example:** safety factors (ASD), permanent situation, SF_{s} = 1.50.

## 4 · The profile functions

#: A straight segment holds for x between its start and its end. The «inside» function equals 1 inside the segment and 0 outside (at the edge, ½ with each neighbor):
dentro(x, a, b) = (sign(x - a) + 1).*(sign(b - x) + 1)/4
#: The elevation of the terrain and of the top of soil 2 at any x: the line of each segment, keeping only that of the segment where x falls:
z_t(x) = sum(dentro(x, T_A, T_B).*(Z_A + (x - T_A).*(Z_B - Z_A)./(T_B - T_A)))
z_s(x) = sum(dentro(x, S_A, S_B).*(Y_A + (x - S_A).*(Y_B - Y_A)./(S_B - S_A)))
#: The circle below the center:
z_o(x) = z_c - sqrt(R^2 - (x - x_c)^2)
#: The unit weight of what is **above** soil 2: the wall up to x = 21.5 and soil 1 from there:
g_u(x) = gamma_R + (gamma_1 - gamma_R)·(sign(x - 21.5) + 1)/2

## 5 · Where the circle cuts the terrain

#: The circle enters the terrain at the toe (on the left) and leaves at the bottom of the excavation. They are the roots of z_{t}(x) − z_{o}(x) = 0; they are searched by bisection (the interval is halved 60 times):
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
a_1g = asin((x_a - x_c)/R)·180/pi 'angle of the entry [degrees]
a_2g = asin((x_b - x_c)/R)·180/pi 'angle of the exit [degrees]
#: The circle **crosses the contact** between soil 2 and soil 1 at:
x_x = x_x 'crossing of the circle with the top of soil 2 [m]
#: To the left of x_{x} the base of the circle is in soil 2 (φ = 26.5°); to the right, in soil 1 (φ = 21°).

## 6 · The slices: how GEO5 cuts them

#: **Measured, not assumed.** GEO5 stores in the .gst the 19 interslice forces of its Spencer calculation (sheet 113). Its two jumps fall at slices 11 and 13, where the anchor heads are (x = 29.29 and 33.97), and that only happens with **20 slices of equal width**. In addition, GEO5 replaces the arc by the **chord** (straight base) in each slice.
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
#  cota(7.722, 112.6, 48.624, 112.6, -0.4, "entry to exit of the circle: 40.90 m")
#  cota(58.2, 115.29, 58.2, 128.75, 0.4, "13.46")
#  cota(14.0, 117.9, 14.0, 122.98, 0.4, "5.08")
#fin
#: The thin red lines are the cuts between slices; the thick one, the 20 chords that form the base. The green arrows are the anchors **replaced by their force at the head**, as GEO5 does.

## 7 · The weight of each slice

#: On a vertical of abscissa x and with the slice base at elevation z_{d}, there is soil 2 from z_{d} up to its top z_{s}(x), and above, up to the terrain z_{t}(x), wall or soil 1. The weight per meter of width of that column is:
#: q(x) = γ_{2}·máx(0, z_{s} − z_{d}) + γ_{u}·máx(0, z_{t} − máx(z_{s}, z_{d}))
#: and the weight of the slice is the integral of q(x) over its width. Between two breaks of the profile all the lines are straight, so q(x) is a line: **Simpson's rule** between breaks gives the exact integral. The breaks are the vertices of the terrain and of the top of soil 2 that fall within the slice, and the point where the chord cuts the top of soil 2.
B_k = [7.89; 11.54; 17.2; 17.25; 19; 20; 21.5; 26.5; 29.8; 32.39; 36.16; 36.18; 38.69; 41; 41.5] 'profile breaks inside the circle [m]
#: The same, multiplying each layer by the elevation of its center, gives the static moment and with it the elevation of the center of gravity z_{g} of each slice (used in section 10, with earthquake).
#: **Surcharges.** The strip one is added to the slice weight by the width that falls inside: q·(min(x_{2}, end) − max(x_{1}, start)).
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
#: This is how the 20 slices come out (W in kN/m, surcharge included; α in degrees; f_{2} is the part of the base that is in soil 2):
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

## 8 · The moment that turns the mass

#: GEO5 (Spencer help: «the line of action of the weight of block passes through the center of the segment of slip surface») applies the weight of each slice on the vertical of the **center of its base**, x_{M}. The arm with respect to the center of the circle is x_{M} − x_{c}; the slices to the left of the center subtract:
#: M_{a} = Σ W_{i}·(x_{M,i} − x_{c})
M_a = sum(W.*(x_M - x_c)) 'moment that turns [kN·m/m]
M_at = M_a/9.80665 'the same in tonf·m/m

## 9 · The anchors

#: GEO5 replaces each anchor by a **compression force at its head**, directed along the anchor into the slope: (P·cos β, −P·sin β). That force enters in two places:
#: — **Moment.** About the center of the circle its moment is r × F, with r the vector from the center to the head. It is opposite to the rotation of the mass: it **resists**.
#: — **Normal at the base** of the slice where the head is: it presses the base and gives more friction.
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


## 10 · The seismic forces on each slice: the algebra

#dibujo("A slice with earthquake: weight W, vertical inertia k_v·W (k_v > 0 upward, GEO5 convention) and horizontal inertia k_h·W toward the front of the slope, at its center of gravity", ud = m, escala = auto, alto = 90)
#  poligono(0, 0, 4, 1.6, 4, 7, 0, 6, "gruesa")
#  flecha(2, 3.4, 2, 0.9, "negro")
#  texto(2.2, 2.0, "W", 3.0, "i")
#  flecha(2, 3.4, 2, 5.4, "azul")
#  texto(2.2, 4.8, "k_v·W", 2.6, "i", estilo = "azul")
#  flecha(2, 3.4, -1.0, 3.4, "rojo")
#  texto(-2.6, 3.7, "k_h·W", 2.6, "i", estilo = "rojo")
#  linea(2, 0.8, 1.35, 2.43, "fina trazos")
#  texto(1.0, 1.5, "N", 2.6, "c")
#  flecha(1.0, 0.4, 3.2, 1.28, "verde")
#  texto(2.3, 0.4, "T (resists)", 2.4, "c", estilo = "verde")
#  texto(4.3, 0.6, "base at α", 2.4, "i")
#fin
#: Each slice i now has three loads on the vertical of the center of its base or at its center of gravity: the weight W_{i}, the vertical inertia k_{v}·W_{i} (upward if k_{v} > 0) and the horizontal inertia k_{h}·W_{i}, applied at the center of gravity (elevation z_{g,i}) and directed toward the front of the slope (−x).
#: **1) The effective weight.** The vertical ones add: W_{i} − k_{v}·W_{i} = (1 − k_{v})·W_{i}.
#: **2) The moment that turns** about the center (x_{c}, z_{c}). The effective weight has arm x_{M,i} − x_{c}; the horizontal force, arm z_{c} − z_{g,i} (the center is above):
#: M_{A}(k_{h}, k_{v}) = Σ (1 − k_{v})·W_{i}·(x_{M,i} − x_{c}) + Σ k_{h}·W_{i}·(z_{c} − z_{g,i})
#: Taking the constants out of the sum, a line in k_{h} and in k_{v} remains (like y = m·x + b):
#: M_{A} = (1 − k_{v})·M_{a} + k_{h}·M_{h},  with M_{a} = Σ W_{i}·(x_{M,i} − x_{c}) (section 8) and M_{h} = Σ W_{i}·(z_{c} − z_{g,i})
M_h = sum(W.*(z_c - z_g)) 'moment of the k_h·W forces per unit of k_h [kN·m/m]
M_ht = M_h/9.80665 'the same in tonf·m/m
#: **3) Bishop resistance.** The vertical equilibrium of the slice (the interslice forces are horizontal) gives the normal; k_{h}·W is horizontal and **does not enter**; k_{v} does, through the effective weight:
#: T_{i} = [c·b + ((1 − k_{v})·W_{i} + F_{v,i})·tan φ] / [cos α_{i} + tan φ·sin α_{i}/FS]
#: FS = [Σ d_{i}·T_{i} + M_{an}] / M_{A}(k_{h}, k_{v})
#: **4) Fellenius.** The normal is the projection of all the loads on the normal to the base: the effective weight gives (1 − k_{v})·W·cos α, and the horizontal one **takes away** k_{h}·W·sin α:
#: N_{i} = (1 − k_{v})·W_{i}·cos α_{i} − k_{h}·W_{i}·sin α_{i} + F_{n,i}
#: **5) For Hynes-Griffin and Franklin** the soil strength goes to 80 %: c and tan φ are multiplied by r_{s} = 0.8 (the anchors are not).
#: **What to expect from k_{v} before calculating.** With k_{v} > 0 both the driving moment (the term (1 − k_{v})·M_{a}) and the base friction drop. The term k_{h}·M_{h} **does not drop**. If the horizontal earthquake governs (k_{h}·M_{h} large compared with M_{a}), the resistance loses more than the driving moment and the FS drops: k_{v} > 0 is the unfavorable direction, as the GEO5 help says.
t_1 = tan(phi_1·pi/180) 'tan φ of soil 1
t_2 = tan(phi_2·pi/180) 'tan φ of soil 2
#: The three formulas, as functions of k_{h}, k_{v} and r_{s} (r_{s} = 1: full strength):
M_A(k_h, k_v) = (1 - k_v)·M_a + k_h·M_h
B_s(F, k_h, k_v, r_s) = (sum(d_b.*(f_2.*(r_s·c_2·b + (W·(1 - k_v) + F_v)·r_s·t_2)./(cos(al) + r_s·t_2·sin(al)/F) + (1 - f_2).*(r_s·c_1·b + (W·(1 - k_v) + F_v)·r_s·t_1)./(cos(al) + r_s·t_1·sin(al)/F))) + M_an)/M_A(k_h, k_v)
F_F(k_h, k_v, r_s) = (sum(d_b.*(r_s·(f_2·c_2 + (1 - f_2)·c_1).*l_b + (W·(1 - k_v).*cos(al) - k_h·W.*sin(al) + F_n)·r_s.*(f_2·t_2 + (1 - f_2)·t_1))) + M_an)/M_A(k_h, k_v)

## 11 · The FS with the k_h and k_v of each code

Z_s = 0.4 'seismic zone factor Z (zone V), NEC-SE-DS
F_as = 1.2 'F_a, profile D, zone V (NEC-SE-DS, Table 3)
k_N = 0.6·Z_s·F_as 'k_h of NEC-15 = 0.6·Z·F_a
k_B = 0.6·Z_s 'k_h of the NEC 2023 draft = 0.6·Z
k_A = 0.5·Z_s·F_as 'k_h = 0.5·surface PGA (AASHTO 0.5·k_h0, Hynes-Griffin, EC8 0.5·α·S)
#: The cases (k_{h}, k_{v}, r_{s}). In each one, Bishop is iterated from FS = 1 (60 rounds):
K_H = [0; k_N; k_N; k_N; k_N; k_N; k_B; k_A; k_A; k_A; k_A; 0.15] 'k_h of each case
K_V = [0; 0; 0.5·k_N; -0.5·k_N; 2/3·k_N; -2/3·k_N; 0; 0; 0; 0.5·k_A; -0.5·k_A; 0] 'k_v of each case (+ = upward)
R_S = [1; 1; 1; 1; 1; 1; 1; 1; 0.8; 1; 1; 1] 'soil strength factor (0.8 in Hynes-Griffin)
#hide
n_c = 12
S_B = zeros(n_c, 1)
S_F = zeros(n_c, 1)
for j = 1:n_c
  F = 1
  for k = 1:60
    F = B_s(F, K_H(j), K_V(j), R_S(j))
  end
  S_B(j) = F
  S_F(j) = F_F(K_H(j), K_V(j), R_S(j))
end
v_1 = round(S_B(1), 5)
w_1 = round(S_F(1), 5)
v_2 = round(S_B(2), 3)
w_2 = round(S_F(2), 3)
v_3 = round(S_B(3), 3)
w_3 = round(S_F(3), 3)
v_4 = round(S_B(4), 3)
w_4 = round(S_F(4), 3)
v_5 = round(S_B(5), 3)
w_5 = round(S_F(5), 3)
v_6 = round(S_B(6), 3)
w_6 = round(S_F(6), 3)
v_7 = round(S_B(7), 3)
w_7 = round(S_F(7), 3)
v_8 = round(S_B(8), 3)
w_8 = round(S_F(8), 3)
v_9 = round(S_B(9), 3)
w_9 = round(S_F(9), 3)
v_10 = round(S_B(10), 3)
w_10 = round(S_F(10), 3)
v_11 = round(S_B(11), 3)
w_11 = round(S_F(11), 3)
v_12 = round(S_B(12), 3)
w_12 = round(S_F(12), 3)
p_3 = round(100·(S_B(3)/S_B(2) - 1), 1)
p_4 = round(100·(S_B(4)/S_B(2) - 1), 1)
p_5 = round(100·(S_B(5)/S_B(2) - 1), 1)
p_6 = round(100·(S_B(6)/S_B(2) - 1), 1)
p_10 = round(100·(S_B(10)/S_B(8) - 1), 1)
p_11 = round(100·(S_B(11)/S_B(8) - 1), 1)
h_kN = round(k_N, 3)
h_kB = round(k_B, 3)
h_kA = round(k_A, 3)
h_v3 = round(0.5·k_N, 3)
h_v5 = round(2/3·k_N, 3)
h_v10 = round(0.5·k_A, 3)
#show
FS_B0 = S_B(1) 'Bishop without earthquake (GEO5: 1.78813; sheet 112 gives the same)
FS_F0 = S_F(1) 'Fellenius without earthquake (GEO5: 1.73651)
FS_BN = S_B(2) 'Bishop with k_h = 0.288 and k_v = 0 (GEO5: 1.00)
FS_FN = S_F(2) 'Fellenius with k_h = 0.288 and k_v = 0 (GEO5: 0.95)
#| Caso | k_{h} | k_{v} | Bishop | Fellenius | Cambio de Bishop por k_{v} | FS pedido |
#|---|---:|---:|---:|---:|---:|---|
#| Sin sismo (control contra GEO5) | 0 | 0 | @{v_1} | @{w_1} | — | 1.50 (NEC estático) |
#| **NEC-15** (0.6·Z·F_{a}) | @{h_kN} | 0 | **@{v_2}** | @{w_2} | — | 1.05 |
#| NEC-15 + k_{v} = +0.5·k_{h} (arriba) | @{h_kN} | +@{h_v3} | @{v_3} | @{w_3} | @{p_3} % | 1.05 |
#| NEC-15 + k_{v} = −0.5·k_{h} (abajo) | @{h_kN} | −@{h_v3} | @{v_4} | @{w_4} | @{p_4} % | 1.05 |
#| NEC-15 + k_{v} = +2/3·k_{h} (arriba) | @{h_kN} | +@{h_v5} | @{v_5} | @{w_5} | @{p_5} % | 1.05 |
#| NEC-15 + k_{v} = −2/3·k_{h} (abajo) | @{h_kN} | −@{h_v5} | @{v_6} | @{w_6} | @{p_6} % | 1.05 |
#| **Borrador NEC 2023** (0.6·Z) | @{h_kB} | 0 | **@{v_7}** | @{w_7} | — | 1.15 |
#| **AASHTO** 0.5·k_{h0} | @{h_kA} | 0 | **@{v_8}** | @{w_8} | — | no leído |
#| **Hynes-Griffin y Franklin** (0.5·PGA, resistencia × 0.8) | @{h_kA} | 0 | **@{v_9}** | @{w_9} | — | 1.00 |
#| **EC8** 0.5·α·S, k_{v} = +0.5·k_{h} | @{h_kA} | +@{h_v10} | @{v_10} | @{w_10} | @{p_10} % | 1 con factores parciales |
#| **EC8** 0.5·α·S, k_{v} = −0.5·k_{h} | @{h_kA} | −@{h_v10} | @{v_11} | @{w_11} | @{p_11} % | 1 con factores parciales |
#| **Seed (1979)** | 0.15 | 0 | **@{v_12}** | @{w_12} | — | 1.15 |
#: The «change» column compares with the same k_{h} and k_{v} = 0. With EC8 and the topographic amplification S_{T} = 1.2 (Annex A, slope over 15°), k_{h} = 0.5·0.48·1.2 = 0.288: the same number as NEC-15, and then k_{v} = ±0.144 are rows 3 and 4.

## 12 · The k_y (FS = 1) and the displacement of Bray and Travasarou

#: **The yield coefficient k_{y}** is the k_{h} that leaves the FS exactly at 1: above k_{y} the mass slides (Newmark, 1965). It is searched by bisection with Bishop, k_{v} = 0:
#hide
k_L = 0
k_U = 0.6
for i = 1:50
  k_m = (k_L + k_U)/2
  F = 1
  for k = 1:60
    F = B_s(F, k_m, 0, 1)
  end
  if F > 1
    k_L = k_m
  else
    k_U = k_m
  end
end
k_yv = (k_L + k_U)/2
k_L = 0
k_U = 0.6
for i = 1:50
  k_m = (k_L + k_U)/2
  F = 1
  for k = 1:60
    F = B_s(F, k_m, 0.5·k_m, 1)
  end
  if F > 1
    k_L = k_m
  else
    k_U = k_m
  end
end
k_yu = (k_L + k_U)/2
H_m = 0
for i = 1:n
  H_m = max(H_m, z_t(x_M(i)) - z_o(x_M(i)))
end
#show
k_y = k_yv 'yield coefficient, Bishop, k_v = 0
k_yu = k_yu 'yield coefficient with k_v = +0.5·k_h at the same time (upward)
#: **Bray and Travasarou (2007)**, JGGE 133(4), median displacement equation (ε = 0) for T_{s} ≥ 0.05 s; D in cm, S_{a} in g:
#: ln D = −1.10 − 2.83·ln k_{y} − 0.333·(ln k_{y})² + 0.566·ln k_{y}·ln S_{a} + 3.04·ln S_{a} − 0.244·(ln S_{a})² + 1.5·T_{s} + 0.278·(M − 7)
#: T_{s} = 4·H/V_{s} is the period of the sliding mass; S_{a} is the spectral acceleration (5 %) at the «degraded» period 1.5·T_{s}; M is the magnitude of the design earthquake.
#: **Data that this sheet ASSUMES** (they do not come from Demo01; the engineer must set them for the site): V_{s} = 250 m/s, M = 7.5, and S_{a} from the NEC-SE-DS elastic spectrum in the Sierra (η = 2.48).
H_s = H_m 'maximum height of the sliding mass (vertical between the terrain and the circle) [m]
V_s = 250 'shear wave velocity of the soil, ASSUMED [m/s]
M_w = 7.5 'moment magnitude of the design earthquake, ASSUMED
T_s = 4·H_s/V_s 'period of the sliding mass [s]
F_ds = 1.19 'F_d, profile D, zone V (NEC-SE-DS, Table 4)
F_ss = 1.28 'F_s, profile D, zone V (NEC-SE-DS, Table 5)
T_0 = 0.1·F_ss·F_ds/F_as 'start of the NEC spectrum plateau [s]
T_C = 0.55·F_ss·F_ds/F_as 'end of the NEC spectrum plateau [s]
T_d = 1.5·T_s 'degraded period 1.5·T_s [s]
#: 1.5·T_{s} falls between T_{0} and T_{C}, on the spectrum plateau: S_{a} = η·Z·F_{a}.
eta_s = 2.48 'η, Sierra provinces (NEC-SE-DS §3.3.1)
S_a = eta_s·Z_s·F_as 'spectral acceleration at 1.5·T_s [g]
l_k = ln(k_y) 'ln k_y
l_a = ln(S_a) 'ln S_a
D_bt = exp(-1.10 - 2.83·l_k - 0.333·l_k^2 + 0.566·l_k·l_a + 3.04·l_a - 0.244·l_a^2 + 1.5·T_s + 0.278·(M_w - 7)) 'median displacement of Bray and Travasarou [cm]
D_mm = 10·D_bt 'the same in mm
#: **The other way around: the k_{h} for an admitted displacement D_{a}** (Bray and Travasarou, 2009, JGGE 135(9)). It is the same equation solving for x = ln k: a parabola 0.333·x² + a·x + (ln D_{a} − C) = 0 remains, with a = 2.83 − 0.566·ln S_{a} and C the remaining terms that do not depend on k. D_{a} = 5 cm is taken (the cap of the NEC 2023 draft):
D_a = 5 'admitted displacement [cm]
a_q = 2.83 - 0.566·l_a 'coefficient a of the parabola
C_q = -1.10 + 3.04·l_a - 0.244·l_a^2 + 1.5·T_s + 0.278·(M_w - 7) 'terms without k
k_5 = exp((-a_q + sqrt(a_q^2 - 4·0.333·(ln(D_a) - C_q)))/(2·0.333)) 'k_h that gives D_a = 5 cm with FS = 1.0
#hide
F = 1
for k = 1:60
  F = B_s(F, k_5, 0, 1)
end
r_k5 = round(F, 3)
r_ky = round(k_y, 3)
r_kyu = round(k_yu, 3)
r_D = round(D_bt, 1)
r_k5k = round(k_5, 3)
#show
#: With this k_{h} = @{r_k5k}, the Bishop FS of the circle is @{r_k5}. Bray and Travasarou ask for FS ≥ 1.0 with their k: it **does not comply** (k_{y} = @{r_ky} is smaller).
#: **Reading.** The circle resists up to k_{y} = @{r_ky}, almost exactly the 0.288 of NEC-15 (that is why the FS comes out 1.00 and not 1.05). With the assumed data, Bray and Travasarou give **@{r_D} cm** of median displacement, more than the 2.5 to 5 cm that the draft takes as accepted. An upward k_{v} equal to half of k_{h} lowers k_{y} to @{r_kyu}.

## 13 · Reading

#: **1) k_{v} weighs little and its unfavorable direction is «upward».** With k_{h} = 0.288, a k_{v} = ±0.5·k_{h} changes the Bishop FS by @{p_3} % (upward) and @{p_4} % (downward); with ±2/3·k_{h}, by @{p_5} % and @{p_6} %. It is what the FHWA says (≤ 10 % if k_{v} ≤ k_{h}). The unfavorable direction is k_{v} > 0 (the mass weighs less), because here the moment of k_{h}·W is large compared with that of the weight: the resistance loses more than the driver.
#: **2) What changes the FS most is the k_{h} that is chosen,** not k_{v}: from 0.15 (Seed) to 0.288 (NEC-15) the Bishop FS goes from @{v_12} to @{v_2}. Almost all the codes with «half PGA» (AASHTO, Hynes-Griffin, EC8 without topography) lead to 0.24 at this site, the same as the NEC 2023 draft by another route (0.6·Z instead of 0.5·Z·F_{a}).
#: **3) With NEC-15 this circle does not meet 1.05** (Bishop @{v_2}); with the draft it would not meet 1.15 either (Bishop @{v_7}). Hynes-Griffin and Franklin, with strength at 80 %, gives @{v_9} < 1.0.
#: **4) The pseudostatic FS does not say how much the slope moves;** that is why NEC-15 also asks for Bray and Travasarou. The bridge between the two is k_{y}.
#: **Pending.** (a) Check in GEO5 a case with K_{v} ≠ 0 (that the horizontal force is K_{h}·W and not K_{h}·(1 − K_{v})·W). (b) Search for the critical circle with earthquake (it is another one). (c) Read the original text of AASHTO §11.5.8 / §11.6.5 (seismic resistance factor) and of EN 1998-5 §4.1.3.3 (here they are cited through secondary sources). (d) V_{s} and M of the site.

## 14 · References

#: Terzaghi, K. (1950). Mechanism of landslides. In: Application of Geology to Engineering Practice (Berkey Volume), GSA, 83-123.
#: Newmark, N. M. (1965). Effects of earthquakes on dams and embankments. Géotechnique 15(2), 139-160.
#: Seed, H. B. (1979). Considerations in the earthquake-resistant design of earth and rockfill dams. Géotechnique 29(3), 215-263.
#: Marcuson, W. F. (1981). Moderator's report for session on earth dams and stability of slopes under dynamic loads. Int. Conf. Recent Advances in Geotech. Earthq. Eng., St. Louis, vol. 3, p. 1175.
#: Hynes-Griffin, M. E. and Franklin, A. G. (1984). Rationalizing the seismic coefficient method. USACE WES, Misc. Paper GL-84-13.
#: FHWA (1998). Geotechnical Earthquake Engineering, Reference Manual, FHWA-HI-99-012, ch. 7 (§7.2.1) and ch. 9.
#: Bray, J. D. and Travasarou, T. (2007). Simplified procedure for estimating earthquake-induced deviatoric slope displacements. JGGE 133(4), 381-392.
#: Bray, J. D. and Travasarou, T. (2009). Pseudostatic coefficient for use in simplified seismic slope stability evaluation. JGGE 135(9), 1336-1340.
#: Bray, J. D. and Travasarou, T. (2011). Pseudostatic slope stability procedure. 5th ICEGE, Santiago, Chile.
#: Anderson, D. G. et al. (2008). Seismic Analysis and Design of Retaining Walls, Buried Structures, Slopes, and Embankments. NCHRP Report 611.
#: AASHTO LRFD Bridge Design Specifications, §11.5.8, §11.6.5 and Appendix A11.5 (cited by Caltrans, Geotechnical Manual: «Seismic Overall Slope Stability», Dec. 2025, and «Geotechnical Seismic Design of ERS», Jan. 2026).
#: CEN (2004). EN 1998-5, Eurocode 8 part 5, §4.1.3.3, §7.3.2.2 and Annex A (via Pecker, A. (2011), «Eurocode 8: Background and Applications», JRC, Lisbon, slides 23-24 and 28).
#: MIDUVI (2015). NEC-SE-GC Geotechnics and Foundations, Table 4 and note (*), p. 31; §5.2 (Mononobe-Okabe), p. 37. NEC-SE-DS Seismic Hazard, §3.2.2 (Tables 3-5), §3.3.1 and §3.4.
#: MIDUVI (2023). NEC-SE-GC draft (27-07-2023), §8.1.5 (p. 131-132), Table 8.2, §8.3.9 and Table 8.6 (Mononobe-Okabe with k_{h} and k_{v}).
#: Fine (2024). GEO5, help: «Earthquake Effect - Standard Analysis» and «Influence of Earthquake».
