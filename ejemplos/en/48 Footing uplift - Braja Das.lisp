# Foundations with nonlinearity: footing uplift (soil without tension)

#: A question that came from a user: "there are situations in which footings enter the nonlinear range, such as when columns are too eccentric". Yes: the soil PUSHES but does not PULL. When the load falls far from the centre, part of the footing separates from the soil and the problem stops being linear. This sheet explains it with the book by Braja M. Das, *Principles of Foundation Engineering*, 9th ed. (2019), §6.10–6.12, p. 235–249 (Spanish edition: *Fundamentos de ingeniería de cimentaciones*, 7th ed., §3.9–3.11, p. 157–171), and compares it with the finite element calculation of Hekatan Struct, SAP2000, SAFE and ETABS.

## 1 · What eccentricity is (Das, eq. 6.50, p. 235)

#: A column that brings down a vertical load Q and a moment M does the same as the load Q alone shifted a distance e from the centre of the footing. That distance is the eccentricity:
e_x = M/Q
#: Seen from ABOVE (plan). The grey square at the centre is the column. The double-circle point is where the load really "falls": not at the centre of the column, but shifted a distance e toward the side the moment pushes. Everything that follows depends on where that point is.
#dibujo("Plan: the column is at the centre, but the load Q falls shifted a distance e", ud = m, escala = 1:30, cotas = m, alto = 95)
#  rect(0, 0, 2, 2, "gruesa")
#  achurado(0.8, 0.8, 0.4, 0.4, "diagonal")
#  rect(0.8, 0.8, 0.4, 0.4, "media")
#  linea(1, -0.2, 1, 2.2, "eje")
#  linea(-0.2, 1, 2.2, 1, "eje")
#  circulo(1.45, 1, 0.045)
#  circulo(1.45, 1, 0.02)
#  texto(1.5, 1.22, "Q: the load falls here", 2.6, "i")
#  texto(0.5, 1.28, "column", 2.4, "c")
#  cota(1, 1, 1.45, 1, -0.32, "e = M/Q")
#  cota(0, 0, 2, 0, -0.35, "B (side in the direction of e)")
#  cota(0, 0, 0, 2, 0.35, "L")
#fin
#: The more moment, the farther the load falls, and the more load the edge on that side takes.

## 2 · The pressure if the soil could pull (Das, eqs. 6.51 and 6.52, p. 236)

#: If the footing is rigid and the soil responds linearly, the pressure is a plane: maximum at the loaded edge and minimum at the opposite one (B is the side in the direction of e):
q_max = Q/(B*L)*(1 + 6*e/B)
q_min = Q/(B*L)*(1 - 6*e/B)
#: At what eccentricity does the minimum pressure reach zero? It is zero when the parenthesis is zero; multiplied by B it becomes (with e_{c} the critical eccentricity):
e_c = B/6
#: SIDE view (elevation) with e less than B/6. The red arrow is the load, shifted e to the right of the column axis. Below, in blue, the soil pressure: a TRAPEZOID, higher on the side of the load. The whole base is supported.
#dibujo("e < B/6 · the whole base pushes: the pressure is a trapezoid", ud = m, escala = 1:30, cotas = m, alto = 95)
#  rect(0, 0, 2, 0.5, "gruesa")
#  achurado(0.8, 0.5, 0.4, 0.9, "diagonal")
#  rect(0.8, 0.5, 0.4, 0.9, "media")
#  linea(1, -0.1, 1, 1.9, "eje")
#  flecha(1.2, 2.0, 1.2, 1.42, "rojo")
#  texto(1.27, 1.85, "Q", 3, "i")
#  poligono(0, 0, 2, 0, 2, -0.8, 0, -0.2, "azul")
#  linea(0, -0.2, 2, -0.8, "azul")
#  linea(0.4, 0, 0.4, -0.32, "azul")
#  linea(0.8, 0, 0.8, -0.44, "azul")
#  linea(1.2, 0, 1.2, -0.56, "azul")
#  linea(1.6, 0, 1.6, -0.68, "azul")
#  texto(2.06, -0.8, "q_{max}", 2.6, "i")
#  texto(-0.06, -0.2, "q_{min}", 2.6, "d")
#  texto(1, -1.05, "the soil pushes over the whole width", 2.4, "c")
#  cota(1, 1.62, 1.2, 1.62, 0.22, "e")
#  cota(0, -1.2, 2, -1.2, -0.12, "B")
#fin
#: That is the limit of the MIDDLE THIRD (kern): with e up to B/6 the whole base pushes (rectangle or trapezoid of pressure). Beyond B/6 the formula gives NEGATIVE pressure, that is the soil would have to PULL the footing. It does not: the edge lifts, the contact area drops and the problem is no longer linear (Das, p. 236).

## 3 · Beyond B/6: the triangle (Das, eq. 6.53, p. 236, Tomlinson 1978)

#: With the edge lifted the pressure is a TRIANGLE. Two conditions fix it. First, the soil resultant must fall under the load: the resultant of a triangle is at one third of its length, measured from the loaded edge, and the load is at B/2 − e from that edge, so the contact length is three times that distance:
a_c = 3*(B/2 - e)
#: Second, vertical equilibrium: the volume of the pressure triangle (half q_{t} times the length times the width L) must equal Q. The maximum pressure is solved:
#: In formula: Q = ½ · q_{t} · a_{c} · L. Solving for q_{t} and putting a_{c} = 3·(B/2 − e); equation 6.53 of the book comes out:
q_t = 4*Q/(3*L*(B - 2*e))
#: SIDE view with e GREATER than B/6. The load falls so far from the centre that the opposite edge LIFTS: in that stretch (orange dashes) the footing no longer touches the soil and the pressure is zero. Only the contact length a_{c} pushes, and the pressure is a TRIANGLE whose resultant (at one third of its base) lies right under the load.
#dibujo("e > B/6 · the edge lifts: the pressure is a triangle over the contact length", ud = m, escala = 1:30, cotas = m, alto = 105)
#  rect(0, 0, 2, 0.5, "gruesa")
#  achurado(0.8, 0.5, 0.4, 0.9, "diagonal")
#  rect(0.8, 0.5, 0.4, 0.9, "media")
#  linea(1, -0.1, 1, 1.9, "eje")
#  flecha(1.6, 2.0, 1.6, 1.42, "rojo")
#  texto(1.67, 1.85, "Q", 3, "i")
#  flecha(1.6, 1.4, 0.8, 0, "puntos")
#  linea(1.1, 0, 1.1, -0.25, "azul")
#  linea(1.4, 0, 1.4, -0.5, "azul")
#  linea(1.7, 0, 1.7, -0.75, "azul")
#  linea(0, -0.04, 0.8, -0.04, "naranja")
#  texto(0.4, -0.22, "lifted off: pressure 0", 2.3, "c")
#  texto(2.06, -1.0, "q_{t}", 2.6, "i")
#  cota(1, 1.62, 1.6, 1.62, 0.22, "e")
#  cota(0.8, -1.2, 2, -1.2, -0.12, "a_{c} = 3·(B/2 − e)")
#  cota(1.6, -0.62, 2, -0.62, -0.05, "a_{c}/3")
#  cota(0, -1.62, 2, -1.62, -0.12, "B")
#fin
#: As e grows, the contact shrinks and q_{t} shoots up; with e = B/2 the contact is zero: the footing overturns.

## 4 · Das example 6.10 (p. 247–248), exactly as in the book

#: Square footing 1.5 × 1.5 m placed at 0.7 m in sand (γ = 18 kN/m³, φ' = 30°, c' = 0), with eccentricity in TWO directions: e_{L} = 0.3 m and e_{B} = 0.15 m.
B_d = 1.5
L_d = 1.5
e_L = 0.3
e_B = 0.15
r_L = dec(e_L/L_d, 3)
r_B = dec(e_B/B_d, 3)
#: e_{L}/L = {r_L} is GREATER than 1/6: the resultant leaves the kern and an edge lifts. e_{B}/B = {r_B} is less than 1/6. With 1/6 < e_{L}/L < 0.5 and e_{B}/B < 1/6 the load falls in CASE II of Highter and Anders (1985) (Das, p. 244).
#: The example footing, seen from above and with its real dimensions. The column is at the centre; the load falls shifted 0.15 m in one direction and 0.30 m in the other (double-circle point). The blue hatched zone is the book's EFFECTIVE AREA A': the trapezoid whose centre of gravity falls right under the load. The lower part, unhatched, is the one the capacity calculation does not count.
#dibujo("Example 6.10 · 1.5 × 1.5 m footing: column, load point and effective area (case II)", ud = m, escala = 1:20, cotas = m, alto = 120)
#  poligono(0, 1.5, 1.5, 1.5, 1.5, 0.225, 0, 1.185, "azul")
#  linea(0.1, 1.5, 0.1, 1.121, "azul")
#  linea(0.2, 1.5, 0.2, 1.057, "azul")
#  linea(0.3, 1.5, 0.3, 0.993, "azul")
#  linea(0.4, 1.5, 0.4, 0.929, "azul")
#  linea(0.5, 1.5, 0.5, 0.865, "azul")
#  linea(0.6, 1.5, 0.6, 0.801, "azul")
#  linea(0.7, 1.5, 0.7, 0.737, "azul")
#  linea(0.8, 1.5, 0.8, 0.673, "azul")
#  linea(0.9, 1.5, 0.9, 0.609, "azul")
#  linea(1.0, 1.5, 1.0, 0.545, "azul")
#  linea(1.1, 1.5, 1.1, 0.481, "azul")
#  linea(1.2, 1.5, 1.2, 0.417, "azul")
#  linea(1.3, 1.5, 1.3, 0.353, "azul")
#  linea(1.4, 1.5, 1.4, 0.289, "azul")
#  rect(0, 0, 1.5, 1.5, "gruesa")
#  rect(0.575, 0.575, 0.35, 0.35, "media")
#  achurado(0.575, 0.575, 0.35, 0.35, "crossed")
#  linea(0.75, -0.15, 0.75, 1.65, "eje")
#  linea(-0.15, 0.75, 1.65, 0.75, "eje")
#  circulo(0.9, 1.05, 0.035)
#  circulo(0.9, 1.05, 0.015)
#  texto(0.95, 1.12, "Q", 3, "i")
#  texto(0.75, 0.45, "column", 2.3, "c")
#  texto(0.38, 1.6, "effective area A' (hatched)", 2.5, "c")
#  cota(0.75, 0.75, 0.9, 0.75, -0.62, "e_{B} = 0.15")
#  cota(0.9, 0.75, 0.9, 1.05, -0.22, "e_{L} = 0.30")
#  cota(1.5, 0.225, 1.5, 1.5, -0.3, "L_{1} = 0.85·L")
#  cota(0, 1.185, 0, 1.5, 0.3, "L_{2} = 0.21·L")
#  cota(0, 0, 1.5, 0, -0.3, "B = 1.50")
#fin
#: In case II the effective area is a trapezoid (eq. 6.75). The book reads L₁ and L₂ from the chart of figure 6.27b: L₁/L ≈ 0.85 and L₂/L ≈ 0.21, that is L₁ = 0.85·1.5 = 1.275 m and L₂ = 0.21·1.5 = 0.315 m.
L_1 = 1.275
L_2 = 0.315
Aprime = dec(0.5*(L_1 + L_2)*B_d, 3)
Lprime = L_1
Bprime = dec(Aprime/Lprime, 3)
#: With the effective area, the ultimate capacity (eq. 6.55 with c' = 0). The factors are given by the example itself: q₀ = 0.7·18 (the book's q, surcharge γ·D_{f}), N_{q} = 18.4 and N_{γ} = 22.4 (table 6.2), and those of shape and depth from table 6.3:
q_0 = 12.6
N_q = 18.4
N_γ = 22.4
F_qs = dec(1 + (Bprime/Lprime)*tan(30*pi/180), 3)
F_γs = dec(1 - 0.4*(Bprime/Lprime), 3)
F_qd = dec(1 + 2*tan(30*pi/180)*(1 - sin(30*pi/180))^2*0.7/B_d, 3)
Q_u = dec(Aprime*(q_0*N_q*F_qs*F_qd + 0.5*18*Bprime*N_γ*F_γs), 0)
#: Without rounding anything it comes out 605 kN. The book rounds A' to 1.193 m² and B' to 0.936 m before continuing; with ITS roundings:
Q_ulib = dec(1.193*(q_0*N_q*1.424*1.135 + 0.5*18*0.936*N_γ*0.706), 0)
#: Q_{u} ≈ 606 kN, the book's number. The difference of 1 kN is only rounding.

### The chart without reading it by eye

#: The case II trapezoid is chosen so that its centroid falls RIGHT under the load (that is what figure 6.27a draws). With that condition the chart has a closed formula (derivation of this sheet, not the book's): with m the half-sum of L₁ and L₂,
m_c = (L_d/2 - e_L)/(1/2 + 6*r_B^2)
L_1c = dec(m_c + 6*m_c*r_B, 4)
L_2c = dec(m_c - 6*m_c*r_B, 4)
A_c = dec(0.5*(L_1c + L_2c)*B_d, 4)
#: It gives L₁/L = 0.857 and L₂/L = 0.214 (the book reads 0.85 and 0.21) and an effective area 1 % larger than the chart's.

## 5 · What Das assumes and what the FEM does

#: Das's effective area A' is a BEARING CAPACITY one: a UNIFORM ultimate pressure over the part of the footing whose centroid falls under the load. It is not the area that really touches the soil in service. For the contact pressure, Das (eq. 6.53) and section 3 assume a RIGID footing with LINEAR distribution.
#: The FEM does not assume that: the footing is a (flexible) plate on springs that work only in compression (the CSI "Gap": force = k·d if the spring is compressed, zero if stretched). It is solved, the springs that ended up in tension are switched off and it is solved again until the contact does not change. Same example 6.10, with Q = 606 kN; what Das does not give was chosen: thickness 0.40 m, column 0.30 m, f'c 240 kgf/cm², ks = 2000 tonf/m³. 30 × 30 mesh, the same node by node in the four programs.
#tabla("Program","q_max [tonf/m²]:3","Contact [m²]:3","Nodes in contact:0","vs SAP2000 [%]:4")({"SAP2000 24 (judge)","Hekatan Struct","SAFE 20","ETABS 22","RIGID footing (formula)","Linear (the soil pulls)"}; [81.914, 81.915, 81.915, 81.915, 82.211, 76.670]; [1.888, 1.888, 1.888, 1.888, 1.884, 2.250]; [798, 798, 798, 798, 0, 961]; [0, 0.0002, 0.0002, 0.0010, 0.36, -6.4])
#: The four programs give the same to 4 digits and lift the SAME edge (798 of 961 nodes touch). Mind the nodes column in the last two rows: they are FORMULAS, not finite element models, so there 0 means "does not apply", not "touches no node". The rigid footing gives 0.36 % more maximum pressure: the real plate flexes a little and distributes better. If the soil is allowed to pull (linear analysis) the maximum pressure comes out 6 % LOWER and there is tension under the lifted edge: the linear one is on the unsafe side.

## 6 · The animation: the pressure as e grows (one direction)

#: The example footing with Q = 61.8 tonf (606 kN) and the load moving in a single direction, from e = 0 to e = B/3 in steps of B/60. Up to e = B/6 the pressure is a trapezoid that tilts; at e = B/6 it is exactly a triangle; beyond that point the edge lifts off (zero pressure) and the triangle shortens and rises. x is measured from the loaded edge. Hover over it to pause.
#anim fplot(q = ((1+sign(10-n))/2)*(27.4644*(1+0.1*n) - 27.4644*0.133333*n*x) + ((1-sign(10-n))/2)*(54.9289/(1.5-0.05*n))*((1 - x/(2.25-0.075*n)) + abs(1 - x/(2.25-0.075*n)))/2, [0 1.5]), n = 0:20
#: The maximum pressure (at the edge, x = 0) and the contact length as a function of e, for the same footing:
#fila
#fplot(q_max = 27.4644*(1 + 4*x)*(1+sign(0.25-x))/2 + (54.9289/(1.5-2*x))*(1-sign(0.25-x))/2, [0 0.5])
#fplot(contacto = 1.5*(1+sign(0.25-x))/2 + 3*(0.75-x)*(1-sign(0.25-x))/2, [0 0.5])
#finfila

### The FEM on the same sweep

#: Sweep with another footing (2 × 2 × 0.5 m, P = 60 tonf, 60 × 60 mesh) in Hekatan and SAP2000, against the rigid footing formula:
#tabla("e/L","Formula q_max [tonf/m²]:3","Hekatan [tonf/m²]:3","SAP2000 [tonf/m²]:3","Formula contact [m]:3","Hekatan contact [m]:3")({"0","1/12","1/6","1/4","1/3"}; [15.000, 22.500, 30.000, 40.000, 60.000]; [15.180, 22.464, 30.000, 40.055, 60.072]; [15.180, 22.464, 30.000, 40.052, 60.038]; [2.000, 2.000, 2.000, 1.500, 1.000]; [2.000, 2.000, 2.000, 1.502, 1.002])
#: The same in a plot: the curve is the rigid footing formula (Das, eqs. 6.51 and 6.53) as a function of e/L; the points are the FEM (SAP2000 and Hekatan) with the flexible footing:
#fplot(q_max = 15*(1 + 6*x)*(1+sign(1/6-x))/2 + (20/(1-2*x))*(1-sign(1/6-x))/2, SAP2000 = [0 15.180; 1/12 22.464; 1/6 30.000; 1/4 40.052; 1/3 60.038], Hekatan = [0 15.180; 1/12 22.464; 1/6 30.000; 1/4 40.055; 1/3 60.072], [0 0.4])
#: Up to e/L = 1/6 the problem is linear and everything coincides; beyond, the FEM follows the triangle formula with the lifted edge. Hekatan and SAP2000 stay within 0.06 % (what remains is the SAP2000 convergence tolerance, 1e-4).
