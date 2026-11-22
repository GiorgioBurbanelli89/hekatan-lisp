# Braja Das example 6.10, complete: eccentricity in two directions

#: The example just as in the book, from the first line to the result. Nothing is summarized here: each equation is given with its number and each number is recalculated.
#: **Mind the edition: the example changes number, and so do the equations.** It is the same problem, the same data and the same result, but if you search by the wrong number it does not appear:
#tabla("Book","Example","Pages","Figure","Tables")({"Das, Principles of Foundation Engineering, 9th ed. (English, 2019)","Das, Fundamentos de ingeniería de cimentaciones, 7th ed. (Spanish)"}; {"6.10","3.8"}; {"247-248","170-172"}; {"6.31","3.25"}; {"6.2 y 6.3","3.3 y 3.4"})
#: And the equations, one by one:
#tabla("What it calculates","In the 9th English ed.","In the 7th Spanish ed.")({"ultimate capacity q'_u","effective area A' (case II)","effective width B' = A'/L'","effective length L' = L_1","chart of L_1 and L_2"}; {"eq. 6.55","eq. 6.75","eq. 6.76","eq. 6.77","fig. 6.27b"}; {"eq. 3.40","eq. 3.58","eq. 3.59","eq. 3.60","fig. 3.21b"})
#: In this sheet **both numberings** are cited at each step: first the English one and, in parentheses, the Spanish one.
#: **The statement.** Square footing, vertical load with eccentricity in BOTH directions. The ultimate load is asked.
B = 1.5 'short side of the footing [m] ; L = 1.5 'long side of the footing [m] ; D_f = 0.7 'embedment depth [m]
γ = 18 'unit weight of the sand [kN/m³] ; φ = 30 'friction angle [°] ; c = 0 'cohesion [kPa]
e_L = 0.3 'eccentricity, long direction [m] ; e_B = 0.15 'eccentricity, short direction [m]

## 1 · The footing of the statement (figure 6.31 of the book)

#: Above the section, with the sand and the embedment; below the plan, with the point of application of the resultant shifted in both directions.
#dibujo("English figure 6.31 = Spanish 3.25 · eccentrically loaded foundation", ud = m, escala = 1:28, cotas = m, alto = 230)
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
#fin

## 2 · The two eccentricity ratios

#: The book starts there, because they are the ones that choose the chart case:
r_L = dec(0.3/1.5, 3) [-] 'relative eccentricity, long direction
r_B = dec(0.15/1.5, 3) [-] 'relative eccentricity, short direction
#: r_L = 0.2 and r_B = 0.1. Since r_L exceeds one sixth (0.167) and r_B does not, the resultant leaves the middle third in one direction: **one edge lifts**. It is the case of English figure 6.27a, which is Spanish 3.21a.

## 2-bis · What exactly is that shifted load

#: This is where everybody gets stuck, and rightly so: in plan the load point appears OUTSIDE the column axis, sometimes even outside the column section. **Nothing comes down there.**
#: The axial load comes down the column, centered on its section, always. What also comes down is a MOMENT. The book could have written the statement with moments instead of eccentricities, and it would be the same problem:
M_L = dec(606*0.3, 1) [kN·m] 'moment, long direction
M_B = dec(606*0.15, 1) [kN·m] 'moment, short direction
#: That is: "a 606 kN load centered, plus 181.8 and 90.9 kN·m" is **exactly** the same as "a 606 kN load shifted 0.30 and 0.15 m". The second form is chosen because it is easier to draw and to distribute.
#: So the shifted arrow **is not a load: it is the RESULTANT**, the point through which the sum of the centered load and the moment passes. Since nothing is applied there, it can fall outside the column section without that meaning anything strange: with 0.30 m eccentricity and a 0.30 m column, it falls right at its edge.
#: **And the trap is in the letter.** In the two drawings the arrow is labeled the same, with the same letter as the axial load, and that makes one think there are TWO loads: one on the column and another outside. **There are not two: there is only one, and it is the same.** Same value, same vertical direction; the only difference is where its line of action is drawn.
#tabla("How it is drawn","Vertical force [kN]:0","Moment about the center [kN·m]:1")({"axial load on the column axis, plus the moment","the SAME axial load, shifted 0.30 m"}; [606, 606]; [181.8, 181.8])
#: The two rows are the same force system: same vertical sum and same moment. That is why the same letter can be used. When you see the shifted load you are not seeing another force placed outside the column: it is **the usual axial load, drawn where it must be drawn so as not to have to draw the moment separately**.
#: What does mean something is how far that resultant goes:
e_nucleo = dec(1.5/6, 3) [m] 'limit of the middle third
e_vuelco = dec(1.5/2, 3) [m] 'half the footing side
#: With 0.30 m it exceeds the middle third (0.25 m) and **one edge detaches**; to overturn it would take 0.75 m. That is why this example is nonlinear but not unstable.

#: **And when they draw it outside the column, what changes?** Nothing in concept: only that the moment is larger. The resultant is not placed, it is CALCULATED: it is the moment divided by the load. If the moment grows, the quotient grows and the point moves away. These are the three distances that matter, measured from the center:
#dibujo("How far the resultant can go (measured from the center)", ud = m, escala = 1:18, cotas = m, alto = 150)
#  rect(0, 0, 1.5, 0.3, "gruesa")
#  achurado(0, 0, 1.5, 0.3, "diagonal")
#  rect(0.6, 0.3, 0.3, 0.75, "gruesa")
#  achurado(0.6, 0.3, 0.3, 0.75, "diagonal")
#  linea(0.75, -0.75, 0.75, 1.45, "eje")
#  linea(0.9, 1.15, 0.9, 1.4, "media")
#  linea(1.0, 1.15, 1.0, 1.4, "media")
#  linea(1.5, 1.15, 1.5, 1.4, "media")
#  cota(0.75, 1.32, 0.9, 1.32, 0.1, "0.15 · column edge")
#  cota(0.75, -0.30, 1.0, -0.30, -0.1, "0.25 · middle third, B/6")
#  cota(0.75, -0.62, 1.5, -0.62, -0.1, "0.75 · footing edge, B/2")
#  flecha(1.05, 1.62, 1.05, 1.12, "rojo")
#  texto(1.2, 1.55, "the resultant of this example: 0.30", 2.3, "i")
#fin
#: With 0.30 m the resultant has already passed the column edge (0.15) **and** the middle third (0.25), but is far from the footing edge (0.75). Translated: there is uplift, there is no overturning. Passing the column edge has no structural consequence; passing the middle third does, and passing the footing edge is ruin.

## 3 · The chart: L₁ and L₂ (eqs. 6.75 to 6.77 English = 3.58 to 3.60 Spanish)

#: With those two ratios, English figure 6.27b (Spanish 3.21b) gives the two sides of the working trapezoid. The book reads L₁/L ≈ 0.85 and L₂/L ≈ 0.21:
L_1 = dec(0.85*1.5, 4) [m] 'long side of the trapezoid
L_2 = dec(0.21*1.5, 4) [m] 'short side of the trapezoid
#: **Equation 6.75 (Spanish 3.58)**, the effective area: the trapezoid with bases L₁ and L₂ and height B.
A_ef = dec(0.5*(1.275 + 0.315)*1.5, 4) [m^2]
#: **Equation 6.77 (Spanish 3.60)**, the effective length is the long side of the trapezoid; and **equation 6.76 (Spanish 3.59)**, the effective width comes from dividing the area by that length:
L_ef = 1.275 [m] 'effective length
B_ef = dec(1.193/1.275, 4) [m] 'effective width
#: A' = 1.193 m², L' = 1.275 m and B' = 0.936 m: the three numbers of the book.
#: The trapezoid, drawn over the footing. The hatched part is the one the capacity calculation counts; the one below, not.
#dibujo("The effective area A' of case II (eq. 6.75)", ud = m, escala = 1:20, cotas = m, alto = 150)
#  poligono(0, 1.5, 1.5, 1.5, 1.5, 0.225, 0, 1.185, "azul")
#  linea(0.15, 1.5, 0.15, 1.153, "azul")
#  linea(0.35, 1.5, 0.35, 1.025, "azul")
#  linea(0.55, 1.5, 0.55, 0.897, "azul")
#  linea(0.75, 1.5, 0.75, 0.769, "azul")
#  linea(0.95, 1.5, 0.95, 0.641, "azul")
#  linea(1.15, 1.5, 1.15, 0.513, "azul")
#  linea(1.35, 1.5, 1.35, 0.385, "azul")
#  rect(0, 0, 1.5, 1.5, "gruesa")
#  linea(0.75, -0.2, 0.75, 1.7, "eje")
#  linea(-0.2, 0.75, 1.7, 0.75, "eje")
#  circulo(0.6, 1.05, 0.04)
#  circulo(0.6, 1.05, 0.018)
#  texto(0.66, 1.14, "Q", 2.8, "i")
#  cota(1.5, 0.225, 1.5, 1.5, -0.28, "L_{1} = 1.275")
#  cota(0, 1.185, 0, 1.5, 0.28, "L_{2} = 0.315")
#  cota(0, -0.26, 1.5, -0.26, -0.12, "B = 1.50")
#  texto(0.75, 0.30, "this part does NOT count", 2.3, "c")
#fin

## 4 · The surcharge and the capacity factors (English table 6.2 = Spanish table 3.3)

#: The surcharge at bearing level is the weight of the soil left above:
q_sob = dec(0.7*18, 1) [kPa] 'weight of the soil above
#: For φ' = 30° table 6.2 gives N_q = 18.4 and N_γ = 22.4. The table is not needed: they come from Reissner's solution, with the angle in radians.
φ_r = dec(30*pi/180, 4) [rad] '30° in radians
N_q = dec(exp(pi*tan(0.5236))*tan(pi/4 + 0.5236/2)^2, 3) [-]
N_γ = dec(2*(18.401 + 1)*tan(0.5236), 3) [-]
#: 18.401 and 22.402 against the 18.4 and 22.4 of the table.

## 5 · The shape and depth factors (English table 6.3 = Spanish table 3.4)

#: The SHAPE ones carry the ratio of EFFECTIVE sides, because the footing that fails is the effective one. The DEPTH one carries the real B, because the wedge starts from the true width. And the depth one of the self-weight term equals one:
F_qs = dec(1 + (0.936/1.275)*tan(0.5236), 3) [-] 'eq. 6.56
F_γs = dec(1 - 0.4*(0.936/1.275), 3) [-] 'eq. 6.57
F_qd = dec(1 + 2*tan(0.5236)*(1 - sin(0.5236))^2*0.7/1.5, 3) [-] 'eq. 6.60
F_γd = 1 [-] 'eq. 6.61
#: 1.424, 0.706 and 1.135: the three of the book.

## 6 · The ultimate capacity (English eq. 6.55 = Spanish eq. 3.40, with c' = 0)

#: With zero cohesion, the first term disappears and the surcharge and the self-weight of the soil remain. The ultimate pressure on the effective area:
q_u = dec(12.6*18.4*1.424*1.135 + 0.5*18*0.936*22.4*0.706, 1) [kPa]
#: And the ultimate load is that pressure times the working area:
Q_u = dec(1.193*508.0, 0) [kN]
#: **606 kN**, the result of the book. The first term contributes 374.5 kPa and the second 133.4: **three quarters come from being buried 0.7 m**, not from the soil below.

## 7 · What the book does not say, and this sheet does

#: All the above is BEARING CAPACITY: whether the soil bursts or not. None of it says how the pressure is distributed under the footing in service, which is what the concrete is designed for.
#: For that the contact must be solved: the footing on springs that work only in compression. With the same model, Hekatan Struct, SAP2000, SAFE, ETABS and OpenSees give **81.915 tonf/m²** at the loaded corner, with 798 of 961 nodes touching the ground. If the soil is allowed to pull, the linear calculation gives **76.670**: 6.4 % less, on the unsafe side.
#: The derivation of that part is in sheet 48; where the subgrade modulus comes from and why the pressure can be distributed with a line, in sheet 54; and why the load is drawn shifted, in 56.
