# Soil capacity and contact pressure: the same 1.5 × 1.5 m footing

#: Sheet 48 distributed the pressure under an eccentric footing and compared it with four programs. Before distributing anything there are two questions that were not answered there: **how much the soil can take** (geotechnics) and **why it is allowed to distribute the pressure with a straight line** (footing stiffness). This sheet answers both with the SAME footing of example 6.10 of Braja M. Das, *Principles of Foundation Engineering*, 9th ed. (2019): square, 1.5 × 1.5 m, placed at 0.7 m in sand with γ = 18 kN/m³, φ' = 30°, c' = 0, and the load shifted 0.30 m in one direction and 0.15 m in the other.
#: Forces are in kilonewtons [kN] and pressures in kilopascals [kPa] while following the book, which works in SI. At the end it is converted to tonne-force per square metre [tonf/m²], which is how the programs' results come out and how a soil study is read in Ecuador: 1 tonf/m² = 9.81 kPa.

## 0 · The example footing (figure 3.25 of the book)

#: Above, the section: the column comes down, the 1.5 × 1.5 m footing rests at 0.7 m and everything is in sand. Below, the plan: the black dot is where the load falls, shifted 0.15 m one way and 0.30 m the other from the centre. It is the same figure as in the book, redrawn to scale with the real dimensions.
#dibujo("Eccentrically loaded foundation · Das, figure 3.25 (ex. 3.8, p. 170-172)", ud = m, escala = 1:28, cotas = m, alto = 240)
#  linea(-0.35, 3.0, 2.15, 3.0, "media")
#  rect(0, 2.2, 1.5, 0.25, "gruesa")
#  achurado(0, 2.2, 1.5, 0.25, "diagonal")
#  rect(0.6, 2.45, 0.3, 0.95, "gruesa")
#  achurado(0.6, 2.45, 0.3, 0.95, "diagonal")
#  flecha(0.75, 3.95, 0.75, 3.46, "rojo")
#  texto(0.9, 3.8, "Q", 3, "i")
#  texto(0.75, 2.3, "1.5 × 1.5 m", 2.4, "c")
#  texto(1.75, 2.92, "Sand", 2.5, "i")
#  texto(1.75, 2.72, "γ = 18 kN/m³", 2.4, "i")
#  texto(1.75, 2.54, "φ' = 30°", 2.4, "i")
#  texto(1.75, 2.36, "c' = 0", 2.4, "i")
#  cota(-0.12, 2.2, -0.12, 3.0, 0.22, "D_{f} = 0.7")
#  linea(0.75, 2.2, 0.75, 1.75, "eje")
#  rect(0, 0, 1.5, 1.5, "gruesa")
#  linea(0.75, -0.25, 0.75, 1.75, "eje")
#  linea(-0.25, 0.75, 1.75, 0.75, "eje")
#  circulo(0.6, 1.05, 0.045)
#  circulo(0.6, 1.05, 0.022)
#  cota(0.6, 1.28, 0.75, 1.28, 0.1, "e_{B} = 0.15")
#  cota(0.95, 0.75, 0.95, 1.05, -0.12, "e_{L} = 0.30")
#  cota(0, -0.28, 1.5, -0.28, -0.12, "B = 1.50")
#  cota(-0.28, 0, -0.28, 1.5, 0.12, "L = 1.50")
#  texto(0.75, -0.62, "plan", 2.4, "c")
#fin
#: The two eccentricities are over B/6 = 0.25 m in one case and not in the other: 0.30 > 0.25 and 0.15 < 0.25. That is why the book goes to case II of Highter and Anders, and why the edge lifts.

## 1 · The three things that hold up a footing

#: Terzaghi (1943) splits the problem into three terms, and each one is a different soil mechanism: the COHESION that glues the particles, the WEIGHT OF THE GROUND above the bearing plane (which hinders the failure wedge as it tries to rise) and the WEIGHT OF THE SOIL ITSELF under the footing (the friction that has to be overcome for the wedge to move). In Meyerhof's form, with the shape and depth factors, and with the ground surcharge at the bearing level:
q_ult = c*N_c*F_cs*F_cd + q_sob*N_q*F_qs*F_qd + 0.5*γ_s*B*N_γ*F_γs*F_γd
#: The ultimate pressure comes out in [kPa] if the cohesion is in [kPa], the unit weight in [kN/m³] and the width in [m]. The six F factors and the three N are dimensionless. The surcharge is the weight of the earth that remained on top:
q_sob = γ_s*D_f
#: In this sand c' = 0, so the first term disappears entirely: **in clean sand the footing is held up by friction, not by cohesion**. The surcharge and the soil's own weight remain.

## 2 · The N factors are not a table: they are three formulas

#: Table 6.2 of the book gives 18.4 and 22.4 for φ' = 30°. Those numbers are not test data: they come from Reissner's (1924) solution for the failure wedge, and the other two are deduced from it. With the friction angle in radians, which here is π/6:
φ = pi/6
N_q = dec(exp(pi*tan(φ))*tan(pi/4 + φ/2)^2, 3)
N_c = dec((N_q - 1)/tan(φ), 2)
N_γ = dec(2*(N_q + 1)*tan(φ), 3)
#: The surcharge factor is {N_q} and the self-weight one {N_γ}: they are the 18.4 and 22.4 of the table, with more digits. The cohesion one, {N_c}, is not used here because c' = 0, but it is the one that governs in clay.
#: This is how each one grows with the friction angle. The horizontal axis is φ' in RADIANS (0.35 rad ≈ 20°, 0.70 rad ≈ 40°) and the vertical one is the factor, dimensionless. Between 20° and 40° the self-weight one is multiplied by twelve: that is why a test that is 5° wrong in the angle changes the capacity almost by double.
#fila
#fplot(N_q = exp(pi*tan(x))*tan(pi/4 + x/2)^2, [0.26 0.79])
#fplot(N_γ = 2*(exp(pi*tan(x))*tan(pi/4 + x/2)^2 + 1)*tan(x), [0.26 0.79])
#finfila

## 3 · Eccentricity does not lower the strength: it trims the area

#: Meyerhof (1953) does not touch the soil strength when the load is eccentric. He changes the footing: he replaces it by a smaller one, centred under the load, and applies uniform pressure to it. That is the effective area — sheet 48 computed it for this example (case II of Highter and Anders) and it gave 1.193 m², with long side 1.275 m and short side 0.936 m.
#: The reason is physical: the soil fails where it is loaded. The strip that lifts contributes no strength, and if it were counted, the capacity would come out high and unsafe.
A_e = 1.193 [m^2]
L_e = 1.275 [m]
B_e = 0.936 [m]
D_f = 0.7 [m]
γ_s = 18 [kN/m^3]
B = 1.5 [m]
q_sob = dec(γ_s*D_f, 1) [kPa]
#: The surcharge is {q_sob} kPa: it is what 0.7 m of sand weighs. The shape factors carry the ratio of the EFFECTIVE sides, because the footing that fails is the effective one; the depth one carries the real B, because the wedge starts from the true width (Das, table 6.3):
F_qs = dec(1 + (B_e/L_e)*tan(φ), 4)
F_γs = dec(1 - 0.4*(B_e/L_e), 4)
F_qd = dec(1 + 2*tan(φ)*(1 - sin(φ))^2*D_f/B, 4)
#: And with that, the ultimate pressure on the effective area in [kPa] and the ultimate load in [kN]:
q_u = dec(q_sob*N_q*F_qs*F_qd + 0.5*γ_s*B_e*N_γ*F_γs, 1) [kPa]
Q_u = dec(A_e*q_u, 1) [kN]
#: {Q_u} kN is the 606 kN of the book. The first term, the surcharge one, contributes 374.6 kPa and the self-weight one 133.3: **three quarters of what this footing withstands comes from being buried 0.7 m**, not from the soil below.

## 4 · From failure to service: the safety factor

#: The ultimate load is the one with which the soil BURSTS. The one used for sizing is that divided by a safety factor, which in shallow foundations is 3 — it is high because the soil is known from few tests and the failure is brittle and without warning:
FS = 3
Q_adm = dec(Q_u/FS, 1) [kN]
q_adm = dec(q_u/FS, 1) [kPa]
q_admt = dec(q_adm/9.81, 2) [tonf/m^2]
#: {Q_adm} kN is the service load this footing admits WITH that eccentricity, and {q_adm} kPa the allowable pressure on the effective area, that is {q_admt} tonf/m². That is the number that goes on the cover of a soil study, and it already carries inside the shape factors, the depth factors and the effective area of THIS footing: it is not a property of the ground that can be copied to another.

## 5 · Where the subgrade modulus comes from

#: The finite element model of sheet 48 needed a datum that Das does not give: the subgrade modulus, that is how much pressure must be applied to sink the soil one metre, in [kN/m³]. By definition it is pressure divided by settlement, with the pressure in [kPa] and the settlement in [m]:
ks_def = q_c/s_c
#: Bowles (1996) observed that if the allowable settlement is of the order of 25 mm, that quotient is tied to the allowable pressure, and proposed a rule of thumb that gives the modulus in [kN/m³] with the allowable pressure in [kPa]:
k_sB = dec(40*FS*q_adm, 0) [kN/m^3]
k_sBt = dec(k_sB/9.81, 0) [tonf/m^3]
#: That is {k_sBt} tonf/m³. Sheet 48 modelled with 2000 tonf/m³: **the model's subgrade modulus was not an invented number, it comes out of the same bearing capacity**, and the difference is from the book's roundings.
#: It is worth seeing the other path, that of elastic settlement, because it shows that the subgrade modulus is NOT a soil property. For a uniform load over an area of width B_c, with the soil modulus in [kPa] and its Poisson's ratio, the settlement in [m] is:
s_el = q_c*B_c*(1 - ν^2)*I_s/E_su
#: The width enters multiplying. Two footings on the SAME sand, one 1 m and the other 3 m, with the same pressure, sink differently: the large one three times as much. And since the subgrade modulus is pressure divided by settlement, the large one has a modulus three times smaller. That is why a subgrade modulus is requested for a specific footing and not reused.
E_su = 25000 [kPa]
ν = 0.3
s_e = dec(q_adm*B_e*(1 - ν^2)/E_su*1000, 2) [mm]
#: With a soil modulus of 25 MPa (medium sand) and Poisson 0.3, this footing settles {s_e} mm under the allowable pressure: below the 25 mm usually accepted, so bearing capacity governs and not settlement.

## 6 · The contact pressure is not decided by the soil

#: So far, geotechnics. Now the structural part, which is another question: how that pressure is DISTRIBUTED under the footing. And the answer depends not only on the soil, but on how stiff the footing is compared with it.
#dibujo("How a footing distributes the pressure according to its stiffness and the soil", ud = m, escala = 1:45, cotas = m, alto = 115)
#  rect(0, 0, 2, 0.18, "gruesa")
#  flecha(1, 0.62, 1, 0.2, "rojo")
#  linea(0, -0.62, 0.5, -0.3, "azul")
#  linea(0.5, -0.3, 1, -0.24, "azul")
#  linea(1, -0.24, 1.5, -0.3, "azul")
#  linea(1.5, -0.3, 2, -0.62, "azul")
#  linea(0, 0, 0, -0.62, "azul")
#  linea(2, 0, 2, -0.62, "azul")
#  texto(1, 0.9, "RIGID on CLAY", 2.4, "c")
#  texto(1, -0.95, "peaks at the edge", 2.2, "c")
#  rect(2.6, 0, 4.6, 0.18, "gruesa")
#  flecha(3.6, 0.62, 3.6, 0.2, "rojo")
#  linea(2.6, 0, 2.6, -0.12, "azul")
#  linea(2.6, -0.12, 3.6, -0.75, "azul")
#  linea(3.6, -0.75, 4.6, -0.12, "azul")
#  linea(4.6, -0.12, 4.6, 0, "azul")
#  texto(3.6, 0.9, "RIGID on SAND", 2.4, "c")
#  texto(3.6, -0.95, "maximum at the centre", 2.2, "c")
#  rect(5.2, 0, 7.2, 0.1, "media")
#  flecha(6.2, 0.62, 6.2, 0.16, "rojo")
#  linea(5.2, 0.1, 5.7, 0.04, "media")
#  linea(5.7, 0.04, 6.2, -0.16, "media")
#  linea(6.2, -0.16, 6.7, 0.04, "media")
#  linea(6.7, 0.04, 7.2, 0.1, "media")
#  linea(5.2, -0.28, 5.7, -0.34, "azul")
#  linea(5.7, -0.34, 6.2, -0.85, "azul")
#  linea(6.2, -0.85, 6.7, -0.34, "azul")
#  linea(6.7, -0.34, 7.2, -0.28, "azul")
#  linea(5.2, -0.2, 5.2, -0.28, "azul")
#  linea(7.2, -0.2, 7.2, -0.28, "azul")
#  texto(6.2, 0.9, "FLEXIBLE (any soil)", 2.4, "c")
#  texto(6.2, -1.05, "the pressure follows the deflection", 2.2, "c")
#fin
#: The rigid footing goes down without bending, and then the soil decides the shape: saturated clay resists by cohesion and can give pressure at the edge, so it is loaded there; the sand at the edge is not confined, it escapes sideways and the pressure shifts to the centre. The flexible footing does the opposite: it sinks more where there is more load, and the pressure follows the deflection.
#: Das distributes with a straight line (trapezoid or triangle) and that is valid only for the RIGID case. The finite element program does not assume it: it solves the plate and lets the pressure come out. That the two coincided within 0.36 % in sheet 48 is no coincidence, and here we measure why.

## 7 · When a footing is rigid: there is a number, not an eyeball criterion

#: The Winkler model says that each point of the soil responds to what sinks right there, with the pressure in [kPa] and the settlement in [m]:
q_w = k_s*w
#: Putting that into the equation of the beam on a continuous spring, a characteristic length appears, and its inverse is what is compared. With the concrete modulus E in [kPa], the strip inertia I in [m⁴] and the subgrade modulus in [kN/m³], it comes out in [1/m]:
lam_def = (k_s/(4*E*I))^0.25
#: The product of that inverse and the side is dimensionless and it is the one that governs (Hetényi, 1946): below π/4 the footing behaves like a rigid block; above π it is a long beam and the load is felt only near where it enters.
#: This footing is 0.40 m deep and f'c = 240 kgf/cm², which is 23.54 MPa. The concrete modulus, by ACI 318-19, is 4700·√f'c in [MPa]:
h = 0.40 [m]
f_c = dec(240*0.0980665, 2) [MPa]
E_c = dec(4700*sqrt(f_c)*1000, 0) [kPa]
I_f = dec(h^3/12, 6) [m^4]
k_s = dec(2000*9.81, 0) [kN/m^3]
λ = dec((k_s/(4*E_c*I_f))^0.25, 4) [m^-1]
λL = dec(λ*B, 4)
lim = dec(pi/4, 4)
#: The modulus comes out {E_c} kPa, the inertia {I_f} m⁴ per metre of width and the subgrade modulus {k_s} kN/m³. The product is {λL} against the limit {lim}: **it is rigid, but only just** — it is at 86 % of the limit. That small margin is exactly the 0.36 % by which the rigid footing formula overshoots compared with the FEM: the real plate flexes a hair and distributes a hair better.
#: The second criterion, the ACI 336 relative stiffness one, uses the soil modulus instead of the subgrade modulus and considers it rigid if it exceeds 0.5:
K_r = dec(E_c/E_su*(h/B)^3/12, 3)
#: It gives {K_r}, almost three times the limit. The two criteria say the same with different data.
#: From what depth would it stop being rigid? The horizontal axis is the depth in [m] and the vertical one the dimensionless product. The footing distributes with a straight line as long as the curve is BELOW 0.785:
#fplot(λL = 1.5*(19620/(4*22802000*x^3/12))^0.25, [0.15 0.6])
#: With 0.40 m it is well within; below about 0.33 m this same footing stops distributing with a straight line, and there you have to trust the finite element and not the formula.

## 8 · The two checks are not mixed

#: One confusing point remains and is worth closing. The FEM of sheet 48 gave a maximum pressure of 81.915 tonf/m², but with the FAILURE load, 606 kN. In service the load is three times smaller, and once the lifted edge stabilises the problem is linear in the load again, so the peak drops in the same proportion:
q_max = dec(81.915/FS, 2) [tonf/m^2]
q_med = dec(Q_adm/A_e/9.81, 2) [tonf/m^2]
rel = dec(q_max/q_med, 2)
#: The peak is {q_max} tonf/m² and the average over the effective area {q_med} tonf/m², which is the allowable pressure of point 4. **The peak is {rel} times the average, and that is not a failure: the two checks measure different things.** The geotechnical one asks whether the soil mass bursts, and for that it counts the total load spread over the area that works, that is averages. The structural one asks how much moment and punching reaches the concrete, and there the peak governs and where it is.
#: Put briefly: with the allowable pressure the SIZE of the footing is decided; with the pressure distribution its REINFORCEMENT and its DEPTH are decided. Comparing the peak against the allowable gives absurdly large footings; reinforcing with the average leaves the corner without steel.
#tabla("Check","What it compares","Value [tonf/m²]:2","Limit [tonf/m²]:2")({"Geotechnical (Meyerhof)","Structural (contact)"}; [17.26, 27.31]; [17.26, 0])
#: The structural row has no limit because it is not compared against the soil: that 27.31 tonf/m² enters as a load in the plate calculation, and from there the moments and punching come out.

## 9 · Example 3.8 from end to end, and its plot

#: All together, in the order in which it is solved: first the effective geometry —the only thing that changes with eccentricity—, then the soil strength, which hardly changes, and at the end the load, which is the product of the two.
#: The case II trapezoid is chosen so that its centre of gravity falls under the load. With that condition there is a closed formula (derived in sheet 48) and there is no need to read the chart by eye. With the relative short eccentricity 0.15/1.5 = 0.1:
m_c = dec((0.75 - 0.3)/(0.5 + 6*0.1^2), 4) [m]
L_1c = dec(1.6*0.8036, 4) [m]
A_ef = dec(1.5*0.8036, 4) [m^2]
B_ef = dec(1.2054/1.2857, 4) [m]
#: The effective area comes out 1.2054 m² against the 1.193 m² that the book reads from the chart: **a 1 % difference, and it is the chart's, not the method's**. The effective short side, 0.9375 m, **does not depend on the long eccentricity**: as the load shifts the trapezoid shortens, but does not narrow.
#: With that geometry, the ultimate pressure and the load. The shape factors now carry the effective ratio 0.9375/1.2857 = 0.729:
F_qsc = dec(1 + 0.729*tan(pi/6), 4)
F_γsc = dec(1 - 0.4*0.729, 4)
q_uc = dec(12.6*18.401*1.4209*1.1347 + 0.5*18*0.9375*22.402*0.7084, 1) [kPa]
Q_uc = dec(1.2054*508.0, 1) [kN]
#: 612.3 kN against the book's 606 kN: the difference comes entirely from the chart read by eye.

### What the plot teaches

#: The horizontal axis is the long eccentricity in metres, from zero to half a metre; the vertical one, the ultimate load in [kN]. The footing is always the same and so is the soil: the only thing that moves is where the load falls.
#fplot(Q_u = 2.678571*(452.1*(0.75 - x) + 25.03), [0 0.5])
#: It is a STRAIGHT LINE going down. Centred, the footing withstands 975 kN; with the load shifted 0.30 m —the book's case— it withstands 612; at 0.45 m, 430. **Half the capacity is lost in 45 centimetres of eccentricity.**
#: And the why is in the two factors. The soil strength hardly moves: 508 kPa with the load shifted against 485 kPa centred, that is it **rises** 5 % (the trapezoid becomes more elongated and the shape factor rewards it). What collapses is the area that works: from 2.009 m² to 1.205 m², 40 % less. **Eccentricity does not weaken the soil: it takes surface away from it.**
#: That is why an eccentric footing is not fixed by improving the ground, but by enlarging it on the side toward which the load shifts, or by removing the eccentricity with a tie beam.

## In one line

#: Geotechnics says how much load the soil withstands, and from it come the size of the footing and the model's subgrade modulus; the footing stiffness says whether the pressure can be distributed with a straight line; and only when that dimensionless product stays below π/4 MUST the book's formula and the finite element give the same, which is what was measured in sheet 48.
