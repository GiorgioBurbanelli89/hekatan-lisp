# Safety factor by strength reduction in GeoFEM: the SRM ladder of Demo04, against GEO5 and the NEC
#numerico

#: **What is done.** GEO5 FEM (GeoFEM) gives the safety factor of a slope **without drawing failure surfaces**: it **divides the soil strength** by an ever larger factor F and repeats the finite element calculation until the slope no longer finds equilibrium. The last F that holds is the **FS**. This is the strength reduction method (SRM).
#: **What can be done in this sheet and what cannot.** Each rung of the ladder is a full Newton with the 2009 Gauss points of the slope (sheets 132 and 133): that is not redone here. What is done: (1) the **reduction** of c and φ; (2) GEO5's **ladder**, rung by rung, with the converges / does not converge verdict of each rung taken from the calculation (Geotechnic, which is GEO5 to 12 digits); (3) what happens to the **Gauss point of sheet 133** at each rung, with the stresses GEO5 had in memory (Frida, 17 digits); (4) why the FS of the slope is not that of a point; (5) the check with **NEC-SE-GC 2015**.
#: **Judge.** GEO5 2024, Demo04.gmk, stage 1 (self-weight): **FS = 1.69** (capture of the Analysis window, hekatan-school/VIDEOS/geo5_interfaz/geofem/captura_v2/etapa1/15ˍAnalysis.png). Hekatan Geotechnic: FS = 1.6935087808.

## 1 · The reduction: c/F and tan φ/F

#: The Mohr-Coulomb shear strength is τ_{f} = c + σ·tan φ. Dividing it entirely by F is dividing its **two** terms:
#: c_{F} = c/F,     tan φ_{F} = tan φ/F
#: Note: the **tangent** is divided, not the angle. In the GEO5 solver (verified with Frida to 13 digits on 4-Sep-2026) it is exactly φ_{F} = atan(tan φ/F).
f_r(F, ϕ) = atan(tan(ϕ*pi/180)/F)*180/pi 'angle reduced by F [°]
#: The two soils of Demo04:
φ_1 = 22.7 'friction angle of soil 1 (top, the slope one) [°]
c_1 = 9 'cohesion of soil 1 [kPa]
φ_2 = 38 'friction angle of soil 2 (bottom) [°]
c_2 = 120 'cohesion of soil 2 [kPa]
#: And with them the Drucker-Prager cone of GeoFEM (sheet 133) is recalculated at each rung with the reduced values:
a_F(F, ϕ) = 2*sin(atan(tan(ϕ*pi/180)/F))/(sqrt(3)*(3 + sin(atan(tan(ϕ*pi/180)/F)))) 'slope α of the cone with reduced φ
k_F(F, ϕ, C) = 6*(C/F)*cos(atan(tan(ϕ*pi/180)/F))/(sqrt(3)*(3 + sin(atan(tan(ϕ*pi/180)/F)))) 'intercept k of the cone with reduced c and φ [kPa]

## 2 · GEO5's ladder

#: How GeoFEM raises F (extracted from the solver and checked with its "course of analysis", registros/talud_geo5.md): each rung multiplies the remaining strength by a step **s = 0.90**; if the Newton does not converge, it goes back to the last good rung and the step is **relaxed to half** of what was missing (0.95, 0.975, 0.9875); at the **fourth** relaxation, or when s would exceed 0.99, it stops. F is not rounded.
#: F_{new} = 1/(R·s),   R = product of the steps that converged
#: What the calculation said at each attempt of stage 1 (1 = converges, 0 = does not converge), from the Geotechnic log (equal to GEO5's attempt by attempt, with the four failures):
c_v = [1; 1; 1; 1; 1; 0; 0; 0; 0] 'verdict of the 9 attempts
#: With that the ladder rebuilds itself:
#hide
F_t = zeros(9, 1)
s_t = zeros(9, 1)
R = 1
n_r = 0
F_S = 1
#show
for i = 1:9
  s_i = 1 - 0.1/2^n_r
  s_t(i) = s_i
  F_t(i) = 1/(R*s_i)
  if c_v(i) > 0.5
    R = R*s_i
    F_S = F_t(i)
  end
  if c_v(i) < 0.5
    n_r = n_r + 1
  end
end
s_t 'step used at each attempt
F_t 'F tried at each attempt
#: The next step would be s = 1 − 0.1/2⁴ = 0.99375 > 0.99 (and there have been 4 relaxations): the ladder stops. The FS is the last F that converged:
F_S 'safety factor of stage 1
#hide
h_F = round(F_S, 10)
t_1 = round(F_t(6), 4)
t_2 = round(F_t(7), 4)
t_3 = round(F_t(8), 4)
t_4 = round(F_t(9), 4)
#show
#: That is: it holds with F = 1/0.9⁵ = **@{h_F}**, it does not hold with @{t_1}, nor @{t_2}, nor @{t_3}, nor @{t_4}. The FS lies between 1.6935 and 1.7149: GEO5's ladder gives it **from below**, with the last one that converged.
#: **How you see the slope going.** The maximum horizontal displacement of the slope at the end of each rung that converged (Geotechnic log, column dx): almost constant up to F = 1.52 and suddenly ×9 at the last one. That jump is the mechanism forming.
#dibujo("Maximum horizontal displacement [mm] against F: the slope goes as it nears the FS", ud = m, escala = auto, alto = 200)
#  linea(0, 0, 9, 0, "media")
#  linea(0, 0, 0, 6, "media")
#  texto(8.6, -0.35, "F", 3, "c")
#  texto(-0.6, 5.8, "dx [mm]", 2.6, "c")
#  texto(0, -0.35, "1.0", 2.4, "c")
#  texto(7.2, -0.35, "1.9", 2.4, "c")
#  texto(-0.4, 3.46, "17.3", 2.4, "c")
#  linea(0, 0.32, 0.889, 0.28, "gruesa azul")
#  linea(0.889, 0.28, 1.877, 0.24, "gruesa azul")
#  linea(1.877, 0.24, 2.974, 0.22, "gruesa azul")
#  linea(2.974, 0.22, 4.194, 0.40, "gruesa azul")
#  linea(4.194, 0.40, 5.548, 3.46, "gruesa azul")
#  circulo(0, 0.32, 0.08, "azul relleno")
#  circulo(0.889, 0.28, 0.08, "azul relleno")
#  circulo(1.877, 0.24, 0.08, "azul relleno")
#  circulo(2.974, 0.22, 0.08, "azul relleno")
#  circulo(4.194, 0.40, 0.08, "azul relleno")
#  circulo(5.548, 3.46, 0.1, "rojo relleno")
#  texto(4.5, 3.6, "FS = 1.6935", 2.6, "c", estilo = "rojo")
#  linea(7.054, 0, 7.054, 5.5, "trazos rojo")
#  texto(7.054, 5.7, "1.8817 does not converge", 2.4, "c", estilo = "rojo")
#  linea(6.261, 0, 6.261, 5.0, "puntos rojo")
#  linea(5.895, 0, 5.895, 4.8, "puntos rojo")
#  linea(5.719, 0, 5.719, 4.6, "puntos rojo")
#fin
#: Horizontal axis: (F − 1)·8, from F = 1 to 1.9. Blue points: F = 1, 1.111, 1.235, 1.372, 1.524 (dx = 1.6, 1.4, 1.2, 1.1, 2.0 mm); red: 1.6935 (17.3 mm). The red verticals are the four attempts that did not converge (1.8817 and, dotted, the relaxations toward 1.7149).

## 3 · The soils on reaching the FS

φ_1F = f_r(F_S, φ_1) 'reduced φ of soil 1 [°]
c_1F = c_1/F_S 'reduced c of soil 1 [kPa]
φ_2F = f_r(F_S, φ_2) 'reduced φ of soil 2 [°]
c_2F = c_2/F_S 'reduced c of soil 2 [kPa]
#: **What GEO5 prints** under the FS (table "Soil parameters in the last finished iteration" of the capture): region 1 → φ = 13.40°, c = 5.31 kPa; region 2 → φ = 22.44°, c = 70.86 kPa. The cohesions are c/FS, the same as here. The angles are **not**: 13.40 = 22.7/1.6935 and 22.44 = 38/1.6935, that is, the angle divided by F, which is not what its own solver uses (atan(tan φ/F) = 13.87° and 24.77°, checked by Gauss point). It is only what the table **prints**; the FS does not change.
φ_1g = φ_1/F_S 'what the GEO5 table prints for soil 1 [°]
φ_2g = φ_2/F_S 'what the GEO5 table prints for soil 2 [°]

## 4 · The Gauss point of sheet 133, rung by rung

#: Each rung starts **from zero stress** with the full weight (that is how GEO5 does it in Demo04, sheet 133) and ends with a stress at the point. These are GEO5's at the end of each rung that converged (σ_{x}, σ_{y}, σ_{z}, τ_{xy}, dumped with Frida, iterations 2, 4, 7, 11, 16 and 24 of stage 1):
S_g = [-39.6631230899876, -94.683769237691322, -42.537599968778423, -7.1021148426813845; -43.34524993719846, -95.478589898028474, -46.271756527094936, -7.7413436058394085; -47.304253750038058, -96.966967171156369, -50.785266397693036, -8.3990170215993309; -51.455693826540994, -98.229275555454734, -55.663087416394895, -9.2862464425630122; -56.076802908453388, -99.654483006604707, -61.534992940704946, -10.401709373184794; -60.540410922227004, -103.96829645085039, -72.373612343407927, -12.632082286473894] 'GEO5 σ at point 1 of element 36 at the end of each rung [kPa]
#: With each σ, the yield function with the **parameters reduced for that rung**. The F of the six rungs that converged are 1 (the start) and the first five attempts of the ladder:
#hide
f_p = zeros(6, 1)
J_p = zeros(6, 1)
I_p = zeros(6, 1)
for i = 1:6
  I_i = S_g(i, 1) + S_g(i, 2) + S_g(i, 3)
  m_i = I_i/3
  J_i = sqrt(0.5*((S_g(i, 1) - m_i)^2 + (S_g(i, 2) - m_i)^2 + (S_g(i, 3) - m_i)^2) + S_g(i, 4)^2)
  I_p(i) = I_i
  J_p(i) = J_i
end
F_6 = [1; F_t(1); F_t(2); F_t(3); F_t(4); F_t(5)]
for i = 1:6
  f_p(i) = round(J_p(i) + a_F(F_6(i), φ_1)*I_p(i) - k_F(F_6(i), φ_1, c_1), 6)
end
#show
F_6 'F of each rung that converged
J_p 'J of the point at the end of each rung [kPa]
f_p 'yield function with c and φ reduced for that rung [kPa]
#: **Reading.** f is never positive (GEO5's stress is always **admissible** with the reduced strength). At F = 1, 1.111 and 1.235 it is 0: the point is **on** the cone, yielded. At 1.372 and 1.524 it is slightly inside (−0.12 and −0.46 kPa): in the last step the slope took some load off it (elastic unloading). At the FS it touches the cone again (−0.002 kPa). With each rung the cone shrinks (k drops from 8.49 to 5.52 kPa) and the J of the point drops with it from 31.8 to 25.8 kPa: the shear the point can no longer carry goes to its neighbors, until there is nowhere left.

## 5 · Why the FS of the slope is not the FS of a point

#: With the **fixed** stress of F = 1, each point has its own "local factor": the F with which its cone shrinks until it touches it, f(F) = 0. For the point of sheet 133 it is 1 (it is already on the cone at F = 1). In soil 2 no point yields at F = 1; the one with the lowest local factor (the **most loaded**, searched among the 1477 points of soil 2 with Geotechnic's stresses) is point 5 of element 93, bottom right, at (33.0, −20.8) m:
S_93 = [-86.367808744574219, -345.97194709713648, -86.467951168342140, -1.5635952699674367] 'GEO5 σ at that point with F = 1 [kPa]
I_93 = S_93(1) + S_93(2) + S_93(3) 'first invariant [kPa]
m_93 = I_93/3 'mean stress [kPa]
J_93 = sqrt(0.5*((S_93(1) - m_93)^2 + (S_93(2) - m_93)^2 + (S_93(3) - m_93)^2) + S_93(4)^2) 'J [kPa]
#: The F that makes f = 0 is sought by halving the interval [1, 50] 60 times (bisection):
#hide
F_a = 1
F_b = 50
for i = 1:60
  F_m = (F_a + F_b)/2
  f_m = J_93 + a_F(F_m, φ_2)*I_93 - k_F(F_m, φ_2, c_2)
  if f_m < 0
    F_a = F_m
  end
  if f_m >= 0
    F_b = F_m
  end
end
#show
F_93 = (F_a + F_b)/2 'local factor of the most loaded point of soil 2
#: **Reading.** There are points with local factor 1 (the 125 of soil 1 already yielded at F = 1) and the worst of soil 2 has 1.52: **both below** the FS of 1.69. A yielded point (or strip) does not bring down the slope: the surrounding soil takes what that point releases. The slope falls when the plastic zone **joins** the toe with the crest (a mechanism) and the Newton no longer finds equilibrium: that is what the ladder measures. That is why the GeoFEM FS needs the whole calculation and does not come from looking at one point.

## 6 · NEC-SE-GC 2015

#: Table 4 of NEC-SE-GC (2015), p. 31: minimum shear safety factors for slopes, FS = τ_{f}/τ_{A} with τ_{f} = c′ + σ′·tan φ′ (the same reduction of c and tan φ as in section 1):
#| Condición | Diseño | Construcción |
#|---|---:|---:|
#| Talud estático, agua normal | 1.50 | 1.25 |
#| Talud pseudoestático, agua normal + k_{h} | 1.05 | 1.00 |
FS_n = 1.5 'NEC minimum FS, static design slope
#: The three stages of Demo04 (GEO5 and Geotechnic, registros/hekatan_geotechnic.md):
#| Etapa | FS GEO5 | FS Geotechnic | NEC estático (≥ 1.50) |
#|---|---:|---:|---|
#| 1 · peso propio | 1.69 | 1.6935 | cumple |
#| 2 · + sobrecarga | 1.48 | 1.4810 | **no cumple** (le falta 1.3 %) |
#| 3 · + anclaje | 1.69 | 1.6935 | cumple |
#: Stage 2 shows what the anchor of stage 3 is for: with the surcharge the slope drops below 1.50 and the anchor brings it back to 1.69. The pseudostatic case (1.05 with k_{h}) **cannot** be checked: Demo04 has no earthquake.

## 7 · Hekatan LISP against GEO5 and Geotechnic

#hide
r_FS = round(F_S, 4)
r_f1 = round(φ_1F, 2)
r_c1 = round(c_1F, 2)
r_f2 = round(φ_2F, 2)
r_c2 = round(c_2F, 2)
r_g1 = round(φ_1g, 2)
r_g2 = round(φ_2g, 2)
r_93 = round(F_93, 4)
d_FS = round(100*(F_S - 1.6935087808430282)/1.6935087808430282, 10)
d_G = round(100*(round(F_S, 2) - 1.69)/1.69, 4)
#show
#| Magnitud | Hekatan LISP | GEO5 2024 | Geotechnic | Diferencia |
#|---|---:|---:|---:|---:|
#| **FS, etapa 1** | @{r_FS} | 1.69 | 1.6935087808 | @{d_G} % con GEO5 (a 2 decimales), @{d_FS} % con Geotechnic |
#| intentos fallidos | 1.8817 / 1.7826 / 1.7369 / 1.7149 | los mismos 4 (log de GEO5) | los mismos | — |
#| c reducida, suelo 1 / 2 [kPa] | @{r_c1} / @{r_c2} | 5.31 / 70.86 | — | 0 |
#| φ reducido que usa el solver, suelo 1 / 2 [°] | @{r_f1} / @{r_f2} | (no lo imprime) | 13.87 / 24.77 | 0 |
#| φ que imprime la tabla de GEO5 [°] | @{r_g1} / @{r_g2} | 13.40 / 22.44 | — | 0 (es φ/FS) |
#| f del punto de la hoja 133 en los 6 peldaños [kPa] | ≤ 0 | σ de GEO5 | — | admisible en todos |
#| factor local, punto más cargado del suelo 2 | @{r_93} | — | — | < FS |
#: **What is checked.** The reduction c/F and atan(tan φ/F), GEO5's ladder (step 0.90, relaxations to half, cap of 4) and the FS = 1/0.9⁵ = 1.6935 that GEO5 prints as 1.69; and that GEO5's stress at a real point is admissible with the reduced strength of each rung.
#: **What is NOT reproduced here.** Whether each rung converges or not (the Newton with 2009 Gauss points): the verdict is taken from the Geotechnic calculation, which is GEO5 to 12 digits per Gauss point in the 124 iterations of the three stages. Sheets 132 and 133 check in parts what is inside each iteration.
