# Base plate: the cantilever method (AISC Design Guide 1)
#modo memoria

#: A base plate spreads the column load over the concrete. This sheet follows the method of **AISC Design Guide 1, 3rd ed. (2024), §4.3** (Kanvinde, Maamouri and Buckholt), with the bearing of **AISC 360-22, J8**. The idea is just one: **the part of the plate that projects beyond the tube works as a CANTILEVER**. Everything else is finding how far it projects and what pressure loads it.
#: First each formula in letters, with its why; then, the numbers. We work in N, mm and MPa, like the guide; the results that are read from memory are also converted to tonf and kgf/cm^{2}.

## 0 · The data

#| Elemento | Dato | Elemento | Dato |
#|---|---|---|---|
#| columna | HSS 300 × 300 × 8, A500 Gr C, F_{y} = 345 MPa | placa | 600 × 600 mm, A572 Gr 50, F_{y} = 345 MPa |
#| carga axial | P_{u} = 600 kN | pedestal | 800 × 800 mm, f'_{c} = 28 MPa |
#| momento en x | M_{ux} = 120 kN·m | pernos | 8 Ø 25.4 mm (1"), F1554 Gr 55 |
#| momento en y | M_{uy} = 60 kN·m | borde a perno | 80 mm (perno a 220 mm del centro) |

#: The same quantities in the units used here:
f_ck = dec(28*10.19716, 1) [kgf/cm^2] 'concrete ; F_yk = dec(345*10.19716, 0) [kgf/cm^2] 'steel
P_uk = dec(600/9.80665, 2) [tonf] 'axial ; M_uxk = dec(120/9.80665, 2) [tonf*m] 'moment x ; M_uyk = dec(60/9.80665, 2) [tonf*m] 'moment y

#dibujo("Plan: 600 × 600 plate, HSS 300 × 300 × 8 tube and 8 bolts Ø 25.4 mm", ud = mm, cotas = mm, escala = 1:8, ancho = 170, alto = 200)
#  rect(-400, -400, 800, 800, "trazos gris")
#  texto(-392, 380, "pedestal 800 × 800 = area A_{2}", 2.3, "i", estilo = "gris")
#  rect(142.5, -300, 157.5, 600, "resalte rojo")
#  rect(-300, 142.5, 600, 157.5, "resalte azul")
#  rect(-300, -300, 600, 600, "gruesa")
#  achurado(-150, -150, 300, 8, "diagonal")
#  achurado(-150, 142, 300, 8, "diagonal")
#  achurado(-150, -142, 8, 284, "diagonal")
#  achurado(142, -142, 8, 284, "diagonal")
#  rect(-150, -150, 300, 300, "gruesa")
#  rect(-142, -142, 284, 284, "media")
#  rect(-142.5, -142.5, 285, 285, "trazos rojo")
#  linea(-345, 0, 345, 0, "eje")
#  linea(0, -345, 0, 345, "eje")
#  circulo([-220, 0, 220, -220, 220, -220, 0, 220], [-220, -220, -220, 0, 0, 220, 220, 220], 23.8, "trazos")
#  circulo([-220, 0, 220, -220, 220, -220, 0, 220], [-220, -220, -220, 0, 0, 220, 220, 220], 12.7, "acero denso")
#  texto(262, -110, "cantilever m", 2.5, "c", 90, estilo = "rojo")
#  texto(-90, 262, "cantilever n", 2.5, "c", 0, estilo = "azul")
#  texto(0, -118, "fixed at 0.95·d", 2.2, "c", estilo = "rojo")
#  texto(0, -80, "HSS 300 × 300 × 8 tube", 2.2, "c")
#  circulo(200, 100, 7, "rojo denso")
#  flecha(40, 100, 190, 100, "rojo")
#  texto(0, 128, "resultant of P_{u}", 2.2, "c", estilo = "rojo")
#  texto(0, 72, "e_{x} = 200 · e_{y} = 100", 2.2, "c", estilo = "rojo")
#  texto(355, 0, "x", 2.8, "i")
#  texto(0, 358, "y", 2.8, "c")
#  cota(-300, -300, -142.5, -300, -35, "m = 157.5")
#  cota(-142.5, -300, 142.5, -300, -35, "0.95·d = 285")
#  cota(142.5, -300, 300, -300, -35, "m = 157.5")
#  cota(-300, -300, 300, -300, -65, "N = 600")
#  cota(-300, -300, -300, 300, 65, "B = 600")
#  cota(-300, 142.5, -300, 300, 35, "n = 157.5")
#  cota(0, 300, 220, 300, 28, "220")
#  cota(220, 300, 300, 300, 28, "80")
#fin
#: The red and the blue are what projects beyond the tube: those strips are the cantilevers. The dashed red line is where they are fixed, at 0.95·d and not at the tube face (explained in section 1). The red dot is where the resultant of the axial load with the two moments passes: it is not another load, it is the same P_{u} drawn where it produces the two moments.

## 1 · The idealization: a cantilever

#: The tube is far stiffer than the plate. That is why the plate, under the tube, practically does not rotate: it stays **fixed** to the tube. What projects has nothing holding it at the other end: the plate edge is free. Fixed on one side and free on the other is a **cantilever**.
#: That cantilever is loaded from below by the concrete pressure on the compressed side and, if present, by the bolt tension on the other side.
#: **Where it is fixed.** Not at the tube face but slightly inward, at 0.95·d. In the tube, the corner and the weld let the plate rotate somewhat right at the face, and tests (DeWolf and Ricker, 1990, cited by the guide on p. 23) adjust the critical section to that 95 %. In rectangular tubes 0.95·d is used in one direction and 0.95·b in the other, and the λn' term of I-shapes is not used.
#: Thus, the length of the cantilever is what is left over on each side:
m = (N - 0.95*d)/2 @@(DG1 ec. 4-10)
n = (B - 0.95*b)/2 @@(DG1 ec. 4-11)
#: With the numbers (the plate and the tube are square, so both cantilevers measure the same):
m = dec((600 - 0.95*300)/2, 1) [mm] ; n = dec((600 - 0.95*300)/2, 1) [mm]

#: The cantilever is studied as a **1 mm wide strip**, like a slab: the pressure f_{p} (force per area) becomes a load per unit length on that strip, and the moment comes out in N·mm per mm of width.
#dibujo("The cantilever: 1 mm wide strip, fixed at the 0.95·d line", ud = mm, cotas = mm, ancho = 150, alto = 150)
#  empotramiento(0, -45, 0, 45, 1)
#  rect(0, -19, 157.5, 38, "gruesa")
#  achurado(0, -19, 157.5, 38, "diagonal")
#  carga(0, -19, 157.5, -19, -55, -55, "f_{p}: concrete pressure, pushes upward", "rojo")
#  cota(0, 19, 157.5, 19, 22, "m = 157.5")
#  texto(163, 0, "free edge", 2.4, "i")
#  texto(-8, 55, "tube", 2.4, "d")
#  linea(0, -165, 157.5, -165, "media")
#  curva(0, 157.5, -165 - 70*((157.5 - x)/157.5)^2, "azul relleno", base = -165)
#  texto(6, -250, "M_{max} = f_{p}·m^{2}/2 at the fixed end", 2.4, "i", estilo = "azul")
#  texto(95, -180, "M(x) = f_{p}·(m − x)^{2}/2", 2.4, "c", estilo = "azul")
#  texto(162, -165, "M = 0 at the free edge", 2.2, "i", estilo = "azul")
#fin
#: Above, the plate and the pressure; below, the moment diagram, drawn on the tension side. It grows with the square of the distance to the free edge: **that is why the length m weighs so much**. Doubling m quadruples the moment.

## 2 · How much the concrete can take (AISC 360-22, J8)

#: The concrete under the plate cannot be squeezed without limit. The code gives the maximum bearing pressure. If the pedestal is larger than the plate, the surrounding concrete **confines** the concrete below and it can take more; that benefit goes with the square root of the area ratio and has a cap of two:
f_pmax = phi_c*0.85*fprime_c*sqrt(A_2/A_1) @@(J8-2, DG1 ec. 4-1)
f_plim = phi_c*1.7*fprime_c @@(tope de J8-2)
#: A_{1} is the plate area and A_{2} that of the pedestal, similar and concentric; φ_{c} = 0.65. Multiplied by the width B, the pressure becomes force per mm of length, which is what the guide uses:
q_max = f_pmax*B @@(DG1 ec. 4-37)
#: With the numbers:
r_A = dec(sqrt(800*800/(600*600)), 4) [-] 'root of A2/A1, less than 2
f_pmax = dec(0.65*0.85*28*1.3333, 2) [MPa] ; f_plim = dec(0.65*1.7*28, 2) [MPa]
q_max = dec(20.627*600, 0) [N/mm] ; f_pmaxk = dec(20.627*10.19716, 1) [kgf/cm^2]
#: 20.63 MPa governs (210 kgf/cm^{2}), because it does not reach the cap of 30.94.

## 3 · Axial load only: the simplest case

#: Without moment, the pressure is uniform over the whole plate:
f_p = P_u/(B*N)
#: The moment at the fixed end of the cantilever, per mm of width, is that of a distributed load on a cantilever of length l:
M_vol = f_p*l^2/2
#: And what the steel strip of thickness t_{p} can take is its plastic moment, with φ_{b} = 0.90:
M_res = phi_b*F_y*t_p^2/4
#: What is demanded is equated with what is supplied and the thickness is solved. The root comes from the resisting moment going with the square of the thickness:
t_p = l*sqrt(2*f_p/(phi_b*F_y))
t_p = l*sqrt(2*P_u/(phi_b*F_y*B*N)) @@(DG1 ec. 4-7a)
#: Here l is the larger of m and n; in a tube it is m (or n). With the numbers:
f_p = dec(600000/(600*600), 3) [MPa]
t_p = dec(157.5*sqrt(2*600000/(0.9*345*600*600)), 2) [mm] 'with axial load only
#: With axial load only, 16.3 mm would be enough. The moment is what governs, as will be seen now.

## 4 · Axial load with moment (DG1 §4.3.7)

#: The guide replaces the earlier triangular pressure with a **rectangular block** of uniform pressure, of length Y, bearing against the compressed edge. The moment becomes an eccentricity: the distance at which P_{u} would have to be placed, alone, to produce the same moment.
e = M_u/P_u @@(DG1 ec. 4-39)
#: **Small moment.** As long as the required block fits without exceeding the maximum pressure, no bolts are needed. The block must have its center right under the resultant; since it starts at the edge, its center is at N/2 − Y/2 from the plate center, and that has to be e:
Y = N - 2*e @@(DG1 ec. 4-42)
f_p = P_u/(B*Y) @@(DG1 ec. 4-44)
#: The larger e is, the shorter the block and the higher the pressure. The limit arrives when the pressure reaches q_{max}: from there comes the critical eccentricity.
e_crit = N/2 - P_u/(2*q_max) @@(DG1 ec. 4-40)
#: **Large moment** (e greater than e_{crit}): the block is already at maximum pressure and is not enough; the bolts on the other side pull with T_{u}. Equilibrium of forces and of moments about the bolts (at a distance f from the center) give:
Y = (f + N/2) - sqrt((f + N/2)^2 - 2*P_u*(e + f)/q_max) @@(DG1 ec. 4-58)
T_u = q_max*Y - P_u @@(DG1 ec. 4-55)

#: **The thickness, compression side.** The cantilever of length m receives the block. If the block covers the whole cantilever (Y ≥ m) the load is uniform over m; if it is shorter (Y < m), it only pushes a piece Y, and its lever arm to the fixed end is m − Y/2:
M_vol = f_p*m^2/2 @@(Y ≥ m)
M_vol = f_p*Y*(m - Y/2) @@(Y < m)
#: Equating with the plastic moment of the strip, as in section 3:
t_p = sqrt(4*M_vol/(phi_b*F_y))
#: Substituting the first case and working out the numbers in the root gives the form in the guide; the 1.49 does not come from a table: it is the root of 2/0.9, and the 2.11 that of 4/0.9:
t_p = 1.49*m*sqrt(f_p/F_y) @@(DG1 ec. 4-51a, Y ≥ m)
t_p = 2.11*sqrt(f_p*Y*(m - Y/2)/F_y) @@(DG1 ec. 4-52a, Y < m)
k_1 = dec(sqrt(2/0.9), 4) [-] ; k_2 = dec(sqrt(4/0.9), 4) [-]
#: **The thickness, tension side.** The bolts pull the plate with T_{u}, at a distance x from the fixed line. The width that works is B:
x = f - d/2 + t/2 @@(DG1 ec. 4-61)
t_p = 2.11*sqrt(T_u*x/(B*F_y)) @@(DG1 ec. 4-62a)

#: **Now the numbers.** In x, the larger moment:
e_x = dec(120000000/600000, 1) [mm] ; e_y = dec(60000000/600000, 1) [mm]
e_crit = dec(600/2 - 600000/(2*12376), 1) [mm] 'critical eccentricity
#: Both eccentricities (200 and 100 mm) are below 275.8 mm: **small moment in both directions, the bolts do not work** (T_{u} = 0). In x:
Y = dec(600 - 2*200, 1) [mm] ; f_p = dec(600000/(600*200), 2) [MPa] ; f_pk = dec(5*10.19716, 1) [kgf/cm^2]
#: Y = 200 mm is greater than m = 157.5 mm: the block covers the whole cantilever, so the first case applies.
M_vol = dec(5*157.5^2/2/1000, 3) [kN*m/m] 'moment at the fixed end, per mm of width
t_px = dec(sqrt(4*62015.6/(0.9*345)), 2) [mm] 'thickness required by the x axis
t_px = dec(1.49*157.5*sqrt(5/345), 2) [mm] 'the same with the 1.49 rounded
#: (62.016 kN·m/m is 62 016 N·mm/mm, the number that goes into the root.)
#: In y, with half the moment:
Y_y = dec(600 - 2*100, 1) [mm] ; f_py = dec(600000/(600*400), 2) [MPa]
t_py = dec(157.5*sqrt(2*2.5/(0.9*345)), 2) [mm] 'thickness required by the y axis

#dibujo("Section in x: the plate as a free body (small moment, e = 200 mm)", ud = mm, cotas = mm, ancho = 165, alto = 160)
#  achurado(-150, 38, 8, 190, "diagonal")
#  rect(-150, 38, 8, 190, "gruesa")
#  achurado(142, 38, 8, 190, "diagonal")
#  rect(142, 38, 8, 190, "gruesa")
#  achurado(-300, 0, 600, 38, "cruzado")
#  rect(-300, 0, 600, 38, "gruesa")
#  linea(0, -150, 0, 330, "eje")
#  flecha(0, 335, 0, 232, "rojo")
#  texto(12, 318, "P_{u} = 600 kN", 2.5, "i", estilo = "rojo")
#  flechamomento(0, 262, 58, 335, 205, "rojo")
#  texto(66, 262, "M_{ux} = 120 kN·m", 2.5, "i", estilo = "rojo")
#  carga(100, 0, 300, 0, -70, -70, "f_{p} = 5.00 MPa over the block Y", "rojo")
#  linea(142.5, -20, 142.5, 60, "trazos rojo")
#  linea(-142.5, -20, -142.5, 60, "trazos rojo")
#  rect(-232, 38, 24, 12, "media")
#  rect(208, 38, 24, 12, "media")
#  linea(-220, 50, -220, 80, "acero")
#  linea(220, 50, 220, 80, "acero")
#  texto(-220, 92, "bolt: T_{u} = 0", 2.3, "c")
#  cota(142.5, 38, 300, 38, 55, "m = 157.5")
#  cota(100, -70, 300, -70, -30, "Y = N − 2e = 200")
#  cota(0, -150, 200, -150, -25, "e = 200: the block center falls under the resultant")
#  cota(-300, 0, -300, 38, 22, "t_{p}")
#fin
#: The center of the block (at 200 mm) falls exactly under the resultant: that is why Y = N − 2e. The dashed red lines are the fixed lines of the cantilever, at 0.95·d.

#: How the required thickness changes with the eccentricity. The horizontal axis is e in mm (labeled x) and the vertical one the thickness in mm. The curve "compresion" is the compressed cantilever; "traccion", the bolt side, which appears only after the critical eccentricity. The points are the two axes of this plate.
#fplot(compresion = sqrt(4*((1 - (1 + sign(x - 275.76))/2)*(1000/max(600 - 2*x, 40))*min(max(600 - 2*x, 40), 157.5)*(157.5 - min(max(600 - 2*x, 40), 157.5)/2) + (1 + sign(x - 275.76))/2*20.627*min(520 - sqrt(270400 - 96.962*(x + 220)), 157.5)*(157.5 - min(520 - sqrt(270400 - 96.962*(x + 220)), 157.5)/2))/310.5), traccion = sqrt(max(4*(12376*(520 - sqrt(270400 - 96.962*(x + 220))) - 600000)*73.72/186300, 0)), eje_x = [200 28.27], eje_y = [100 19.99], e_crit = [275.76 41.43], [0 600])
#: Up to e = 150 mm the block is long and the pressure low: the thickness rises slowly. Between 150 and 275.8 mm the block shortens below m, the pressure shoots up and the curve steepens. Past the critical value the pressure can no longer rise (it is q_{max}) and what grows is the bolt tension.

#: If the moment were large, the free body changes like this (qualitative drawing, not the numbers of this plate):
#dibujo("Large moment (e > e_crit): block at maximum pressure and bolts in tension", ud = mm, cotas = mm, ancho = 165, alto = 120)
#  achurado(-300, 0, 600, 38, "cruzado")
#  rect(-300, 0, 600, 38, "gruesa")
#  rect(-150, 38, 300, 60, "media")
#  linea(0, -110, 0, 150, "eje")
#  carga(210, 0, 300, 0, -80, -80, "q_{max}", "rojo", n = 5)
#  flecha(-220, 20, -220, -95, "azul")
#  texto(-212, -85, "T_{u} (bolts)", 2.4, "i", estilo = "azul")
#  linea(-142.5, -15, -142.5, 60, "trazos rojo")
#  linea(142.5, -15, 142.5, 60, "trazos rojo")
#  cota(-220, 38, -142.5, 38, 30, "x")
#  cota(210, -80, 300, -80, -45, "Y")
#  cota(-220, 150, 0, 150, 18, "f")
#  flecha(0, 150, 0, 100, "rojo")
#  texto(8, 140, "P_{u}", 2.5, "i", estilo = "rojo")
#  flechamomento(0, 120, 45, 335, 205, "rojo")
#fin
#: On the bolt side the cantilever hangs from the tension T_{u}, with arm x to its fixed end: it is the same cantilever, loaded the other way.

## 5 · The two moments at once (DG1 §4.3.11)

#: The guide does not add the two cases: it uses an elliptical interaction. M_{cx} and M_{cy} are the moments the connection can take in each axis, with the same axial load, checking all modes (compressed plate, plate in tension, bolts, concrete):
razon = (M_ux/M_cx)^2 + (M_uy/M_cy)^2 @@(DG1 ec. 4-69)
#: **How much the chosen plate can take.** t_{p} = 38 mm is chosen. Its resisting moment per mm of width:
M_res = dec(0.9*345*38^2/4/1000, 3) [kN*m/m]
#: In N·mm per mm of width that is 112 090.5, the number that goes in below.
#: With small moment (no bolts) and the block shorter than m, the cantilever moment is f_{p}·Y·(m − Y/2), and since f_{p}·Y = P_{u}/B, it becomes (P_{u}/B)(m − Y/2). Equating it with M_{res} gives the shortest block that resists; its eccentricity and the moment follow from the equations above:
Y_c = 2*(m - M_res*B/P_u)
e_c = (N - Y_c)/2
M_c = P_u*e_c
#: With the numbers:
Y_c = dec(2*(157.5 - 112090.5*600/600000), 2) [mm] 'shorter than the cantilever m: the second case applies
e_c = dec((600 - 90.819)/2, 2) [mm] 'smaller than the critical: the bolts still do not work
M_c = dec(600000*254.59/1000000, 2) [kN*m] 'compressed plate: the governing mode
#: The plate and the tube are square, so M_{cx} = M_{cy} = 152.75 kN·m. The bolts do not work before that (T_{u} = 0 while e ≤ e_{crit}), so the compressed plate governs.
razon = dec((120/152.75)^2 + (60/152.75)^2, 3) [-] 'must be less than or equal to 1
#: **0.77 ≤ 1: the 38 mm plate passes.** The x axis alone required 28.3 mm; the interaction requires more because the two moments add at the corner.
#: Note on the 0.78 of the reference (calc_prediseno.py): there M_{c} is searched by raising the moment 1 kN·m at a time, and it stops at 152; here it is solved exactly, 152.75. With 152 the ratio gives 0.779; it is the same calculation.

## In one line

#: The plate that projects beyond the tube is a cantilever fixed at 0.95·d: with m = 157.5 mm and the 5 MPa pressure block, the x axis requires 28.3 mm; the interaction of the two moments gives 0.77 with 38 mm, so **the 600 × 600 × 38 mm plate passes** and the bolts do not work in tension with these loads (they will work in shear and with the earthquake, which are not included here).
