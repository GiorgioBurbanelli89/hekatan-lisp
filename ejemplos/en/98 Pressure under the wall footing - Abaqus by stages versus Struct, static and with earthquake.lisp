# Pressure under the wall footing: Abaqus by stages against Struct, static and with earthquake
#numerico

#: **What is computed.** The Manabí retaining wall (2.60 m stem, 3.00 × 0.40 m footing) resting on sand. What is wanted is the **soil pressure under the footing**: its resultant N, where it falls (eccentricity e) and the values at the toe and at the heel. It is what is compared with the bearing capacity.
#: **Two models.** (1) **Hekatan Struct**: the wall on subgrade springs, with the GEO5 loads (weight, backfill over the heel, Coulomb thrust and, with earthquake, the Mononobe-Okabe increment). It gives a **linear** pressure. (2) **Abaqus 2017**: the wall and the ground in plane strain, Mohr-Coulomb soil and frictional contact. The pressure comes from the contact, node by node, and it is **not** a straight line.
#: **How they are compared.** This sheet takes the 7 Abaqus values, integrates the resultant and its moment with the trapezoid rule, and extracts the **equivalent line**: the linear pressure that has the same N and the same moment. That line is what is compared with Struct.
#: **Units.** kN, m and kPa, per meter of wall.

## 1 · Why the wall was built in stages in Abaqus
#: If the wall and the backfill are placed **all at once**, the weight of the backfill sinks the ground behind the wall and drags the heel downward: the pressure comes out reversed (76.2 kPa at the toe and 91.8 at the heel), larger at the heel. On site that does not happen: the wall is built first, then it is backfilled in layers and each layer settles before the next.
#: In Abaqus/Explicit all the soil is there from the start, but **weightless**; the weight of each part enters in its turn with a smooth 1.6 s ramp (2 s turns): supporting ground → wall and earth in front → strip behind the heel → four 0.65 m backfill layers. At the end of each turn the kinetic energy is practically zero compared with the internal one: the calculation is almost static.
#| Final del turno | N en la base [kN/m] | Empuje en el trasdós [kN/m] | Coronación u_{x} [mm] |
#|---|---:|---:|---:|
#| muro y tierra de delante (4 s) | 47.57 | 0.00 | −3.60 |
#| capa 2 (10 s) | 87.24 | 10.01 | +1.06 |
#| capa 4, final (16 s) | 128.58 | 24.10 | +2.21 |
#: **Quoted** Abaqus numbers (muro_pesos.py, 29-Sep-2026), not computed here.

## 2 · Data
B = 3 [m] 'footing width
#: Abscissa of each soil node under the footing, measured from the tip of the toe. They are the **soil** nodes (0.50 m mesh), the slave surface of the contact: on the wall side (0.10 m mesh) Abaqus gives false peaks of 60 to 67 kPa exactly where the soil nodes fall.
x = [0; 0.5; 1; 1.5; 2; 2.5; 3] [m]
#: Abaqus contact pressure, static (weight by stages), in kPa:
p_e = [65.243; 45.628; 38.794; 39.803; 38.195; 40.663; 42.934]
#: Abaqus contact pressure with the pseudo-static earthquake on top (k_{h} = 0.336 as body force k_{h}·γ), in kPa:
p_s = [81.951; 67.584; 53.279; 49.103; 42.539; 39.069; 18.068]
#: Struct (springs): maximum and minimum pressure under the footing, in kPa, and the total vertical reaction N in kN/m (the same that SAP2000 and ETABS give with the same model; with earthquake it is 47.04 + 91.39 + 6.36 + 7.00 = 151.79, the sum of the vertical loads):
q_e1 = 58.5
q_e2 = 39.1
q_s1 = 84.7
q_s2 = 28.9
n_se = 144.78
n_ss = 151.78

## 3 · Resultant and moment by the trapezoid rule
#: Between two consecutive nodes the pressure is taken as linear. Segment i contributes the force F_{i} = (p_{i} + p_{i+1})/2·Δx, applied at the center of the segment, x_{m} = (x_{i} + x_{i+1})/2. The force and its moment about the **center of the footing** (x = B/2) are added:
#: N = Σ F_{i}   ·   M_{c} = Σ F_{i}·(x_{m} − B/2)
#: If M_{c} is negative, the resultant falls on the toe side. The eccentricity, measured toward the toe:
#: e = −M_{c}/N
#hide
N_e = 0
M_e = 0
N_s = 0
M_s = 0
#show
for i = 1:6
  d_x = x(i + 1) - x(i)
  x_m = (x(i) + x(i + 1))/2 - B/2
  N_e = N_e + (p_e(i) + p_e(i + 1))/2·d_x
  M_e = M_e + (p_e(i) + p_e(i + 1))/2·d_x·x_m
  N_s = N_s + (p_s(i) + p_s(i + 1))/2·d_x
  M_s = M_s + (p_s(i) + p_s(i + 1))/2·d_x·x_m
end
#: **Static:**
N_e
e_e = -M_e/N_e [m]
#: **With earthquake:**
N_s
e_s = -M_s/N_s [m]
#: Check with the contact forces that Abaqus adds up at the base: 128.58 kN/m (static) and 150.83 kN/m (earthquake). The trapezoid gives the same, so the 7 nodes are enough for the resultant.

## 4 · Equivalent line
#: A linear pressure with resultant N and eccentricity e (combined bending of the footing, as a section 1 m deep):
#: p_{toe} = N/B·(1 + 6·e/B)   ·   p_{heel} = N/B·(1 − 6·e/B)
#: As long as e ≤ B/6 = 0.50 m, the whole footing is in compression.
p_e1 = N_e/B·(1 + 6·e_e/B) [kPa]
p_e2 = N_e/B·(1 - 6·e_e/B) [kPa]
p_s1 = N_s/B·(1 + 6·e_s/B) [kPa]
p_s2 = N_s/B·(1 - 6·e_s/B) [kPa]
#: **Is the Struct pressure linear?** If it were, its maximum and minimum would give its N: N = (q_{max} + q_{min})/2·B.
n_qe = (q_e1 + q_e2)/2·B
n_qs = (q_s1 + q_s2)/2·B
#: In the static case it gives 146.4 against the real N of 144.78: almost linear. **With earthquake it gives 170.4 against 151.78**: with earthquake the Struct pressure is **not a line either**; the 84.7 is a peak at the toe, like the Abaqus one. That is why, with earthquake, maximum is compared with maximum and minimum with minimum, not lines.
#: Abaqus maximum and minimum, node by node:
m_e1 = max(p_e)
m_e2 = min(p_e)
m_s1 = max(p_s)
m_s2 = min(p_s)

## 5 · Drawing
#dibujo("Pressure under the footing. Static, left; with earthquake, right. Scale: 100 kPa = 1 m. Black: Abaqus node by node; red: its equivalent line; blue dashed: Struct (static only, where it is almost linear)", ud = m, ancho = 190, alto = 110)
#  polilinea([0, 3, 3, 1.1, 1.1, 0.85, 0.7, 0, 0], [0, 0, 0.4, 0.4, 3, 3, 0.4, 0.4, 0], "gruesa")
#  linea(1.1, 3, 2.6, 3, "trazos gris")
#  texto(1.85, 3.25, "relleno", 2.4, "c")
#  polilinea([0, 0, 0.5, 1, 1.5, 2, 2.5, 3, 3], [0, -0.652, -0.456, -0.388, -0.398, -0.382, -0.407, -0.429, 0], "gruesa")
#  polilinea([0, 0, 3, 3], [0, -0.493, -0.365, 0], "rojo")
#  polilinea([0, 0, 3, 3], [0, -0.585, -0.391, 0], "trazos azul")
#  texto(-0.1, -0.65, "65.2", 2.2, "d")
#  texto(-0.1, -0.45, "49.3", 2.2, "d", estilo = "rojo")
#  texto(3.1, -0.43, "42.9", 2.2, "i")
#  texto(3.1, -0.25, "36.5", 2.2, "i", estilo = "rojo")
#  texto(1.5, -1.05, "STATIC", 2.6, "c")
#  polilinea([5, 8, 8, 6.1, 6.1, 5.85, 5.7, 5, 5], [0, 0, 0.4, 0.4, 3, 3, 0.4, 0.4, 0], "gruesa")
#  linea(6.1, 3, 7.6, 3, "trazos gris")
#  flecha(7.8, 1.8, 7.0, 1.8, "naranja")
#  texto(7.9, 1.8, "k_{h} = 0.336", 2.4, "i", estilo = "naranja")
#  polilinea([5, 5, 5.5, 6, 6.5, 7, 7.5, 8, 8], [0, -0.820, -0.676, -0.533, -0.491, -0.425, -0.391, -0.181, 0], "gruesa")
#  polilinea([5, 5, 8, 8], [0, -0.749, -0.257, 0], "rojo")
#  texto(4.9, -0.87, "82.0", 2.2, "d")
#  texto(4.9, -0.67, "74.9", 2.2, "d", estilo = "rojo")
#  texto(8.1, -0.18, "18.1", 2.2, "i")
#  texto(8.1, -0.33, "25.7", 2.2, "i", estilo = "rojo")
#  texto(6.5, -1.05, "WITH EARTHQUAKE", 2.6, "c")
#fin
#: The ordinates of the drawing are the pressures of section 2 divided by 100; the red labels, those of the line of section 4.
#: **What is seen.** Abaqus does not give a line. In the static case there is a **peak under the tip of the toe** and the rest is almost uniform (39 to 43 kPa): the footing is much stiffer than the sand and the load goes to the edge. With earthquake the wall pushes forward and the pressure shifts toward the toe; at the heel it drops to 18 kPa.

## 6 · Comparison
#hide
d_e1 = round(100·(m_e1/q_e1 - 1), 1)
d_e2 = round(100·(m_e2/q_e2 - 1), 1)
d_s1 = round(100·(m_s1/q_s1 - 1), 1)
d_s2 = round(100·(m_s2/q_s2 - 1), 1)
d_ne = round(100·(N_e/n_se - 1), 1)
d_ns = round(100·(N_s/n_ss - 1), 1)
r_ne = round(N_e, 2)
r_ns = round(N_s, 2)
r_e1 = round(p_e1, 1)
r_e2 = round(p_e2, 1)
r_s1 = round(p_s1, 1)
r_s2 = round(p_s2, 1)
r_ee = round(e_e, 3)
r_es = round(e_s, 3)
#show
#| | Abaqus por etapas | Struct (muelles) | Diferencia [%] | Recta equivalente de Abaqus |
#|---|---:|---:|---:|---:|
#| **Estático**: N [kN/m] | @{r_ne} | 144.78 | @{d_ne} | — |
#| presión máxima (puntera) [kPa] | @{m_e1} | 58.5 | @{d_e1} | @{r_e1} |
#| presión mínima [kPa] | @{m_e2} | 39.1 | @{d_e2} | @{r_e2} |
#| **Con sismo**: N [kN/m] | @{r_ns} | 151.78 | @{d_ns} | — |
#| presión máxima (puntera) [kPa] | @{m_s1} | 84.7 | @{d_s1} | @{r_s1} |
#| presión mínima [kPa] | @{m_s2} | 28.9 | @{d_s2} | @{r_s2} |
#: **Reading.**
#: • **With earthquake the N coincides** (less than 1 %) **and so does the maximum at the toe** (82.0 against 84.7, 3 % less). The minimum does not: 18.1 in Abaqus against 28.9. In Abaqus the soil under the tip of the toe yields plastically and the load is distributed differently; the Struct springs are elastic.
#: • **In the static case Abaqus gives less N** (11 % less) and a larger peak at the toe (65.2 against 58.5). In Struct all the weight of the backfill over the heel goes down to the footing. In Abaqus part of that weight hangs by friction from the neighboring ground, through the vertical plane through the tip of the heel, and the springs do not have that plane.
#: • With the earthquake the Abaqus eccentricity grows from @{r_ee} to @{r_es} m and approaches the edge of the middle third (0.50 m), but does not reach it: the whole footing stays in compression.

## 7 · What has to be said about this model
#: • The Abaqus earthquake is **pseudo-static applied to the whole ground** (k_{h}·γ over the 30 m of the box). The soil yields at the right edge of the box, far from the wall (equivalent plastic strain up to 0.93), and under the tip of the toe (0.86): there the soil gives way.
#: • The −53 mm displacement of the wall with earthquake is almost all from the **ground**: the foot and the top move almost the same and the wall only tilts 2.2 mm.
#: • A layer that does not yet weigh is already there and has stiffness. Against the wall it hardly counts, because the contact opens when the wall moves away from the backfill.
#: **Next:** the same wall by stages with the **Portoviejo earthquake record** (APO1, 16-Apr-2016) at the base, instead of k_{h}.
