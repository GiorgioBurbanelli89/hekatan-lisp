# HL-93 moving load on a box culvert: influence lines and envelope
#: This sheet explains, step by step, WHAT Hekatan Struct does when an HL-93 truck crosses the box culvert of the public example. First in letters, then with the numbers. The formulas and numbers come from the app's engine, not from memory: each one carries its file:line.
#: The live example: https://giorgioburbanelli89.github.io/hekatan-struct-lineal/workspace/?t=alcantarilla-carga-movil
#: Engine: examples/src/shared/cargaMovil.ts and examples/src/alcantarilla-carga-movil/ (hekatan-struct repo, branch carga-movil-alcantarilla).
#: Units: the engine works in kN and m (cargaMovil.ts:31). Here they are also given in tonf, which is what is used in Ecuador. 1 tonf = 9.80665 kN.

## 1 · The HL-93 truck: what it is, in letters

#: The HL-93 is not a truck: it is loads applied at the same time, and the combination is called HL-93K (cargaMovil.ts:16). First the design truck, three axles in a row. The total weight is the sum of the three:
P_tot = P_1 + P_2 + P_3
#: The axles are not fixed: the front axle rules, and each axle goes a distance d BEHIND it (cargaMovil.ts:37-41, "distance BEHIND the front axle"). If the front axle is at abscissa x_F, axle k is at:
x_k = x_F - d_k
#: The three HL-93 distances (cargaMovil.ts:82-84): the front one at 0, the second at a₁, and the third at a₁ plus the rear spacing a₂, which is NOT fixed:
d_1 = 0
d_2 = a_1
d_3 = a_1 + a_2
#: The total length of the truck is the distance from the first axle to the last (cargaMovil.ts:90, largoVehiculo = maximum of the d):
L_cam = a_1 + a_2
#: And along with the truck goes the lane load: a distributed load w_c along the whole length, which does not move; it is placed where it does the most damage.

## 2 · Now the numbers (AASHTO LRFD, in SI)

#: Where they come from: there is no AASHTO PDF on this PC. The verified source is the CSI Analysis Reference Manual of SAP2000 24, chap. XXVI, p. 515 and Figure 92 p. 517 (cargaMovil.ts:16-20 and :72). There the HL-93 is in English units: 8 k · 32 k · 32 k, spacings 14 ft and 14-30 ft, lane 0.640 k/ft. In SI they are the code roundings used by the engine in cargaMovil.ts:67-71:
P_1 = 35
P_2 = 145
P_3 = 145
a_1 = 4.3
#: The total weight of the truck, in kN and in tonf:
P_tot = dec(P_1 + P_2 + P_3, 1)
P_tonf = dec(P_tot/9.80665, 3)
#: The lane load (cargaMovil.ts:71), in kN/m and in tonf/m:
w_c = 9.3
w_tonf = dec(w_c/9.80665, 5)
#: And the rear spacing a₂ is a RANGE, not a number (cargaMovil.ts:69-70): the truck stretches or shrinks looking for the worst case.
a_2min = 4.3
a_2max = 9.0
#: With that the truck measures between:
L_min = a_1 + a_2min
L_max = a_1 + a_2max

## 3 · The factors that touch the loads

#: (a) IMPACT IM. The load of a truck passing at speed hits harder than the same load placed slowly. The code includes it by multiplying the axles by a factor. In the engine (cargaMovil.ts:77 and :82-84):
f_IM = 1 + IM/100
P_din = P_eje*f_IM
#: The reason for the solving: if a test gives you the measured load P_med, the IM comes out of here:
Despejar{P_med = P_eje*(1 + IM/100) @ IM}
#: With the 33 % IM of the HL-93 (CSI Ref. p. 515: "if im = 33 ... multiplied by 1.33"), the rear axle becomes:
IM = 33
f_IM = 1 + IM/100
P_eje33 = dec(145*f_IM, 2)
#: Note, and this is important: the factor only touches the AXLES, not the lane (cargaMovil.ts:57 and :86 — the lane is divided by the width, but not multiplied by f_IM). In the public example the IM comes at 0 % by default (alcantarillaCargaMovil.ts:52), so that the effect of the moving load alone can be seen; it is raised with the control.

#: (b) DISTRIBUTION WIDTH E. The model is a plane frame: a 1 m STRIP of the culvert (modeloAlcantarilla.ts:1-2). A real axle spreads across the width, so the load entering the strip is:
P_franja = P_eje/E_r
#: And the other way round: if you want a load P_obj to enter the strip, the width needed comes from solving for E:
Despejar{P_eje = P_obj*E_r @ E_r}
#: WARNING: here the sheet says what it does NOT know. The AASHTO LRFD distribution width for culverts (equivalent strip plus the spread of the wheel through the fill) has NO source on this PC: there is no AASHTO PDF and the CSI manuals do not include it. That is why the example opens with E_r = 1 m, that is the WHOLE axle on the 1 m strip, which is the safe side, and it warns on screen in orange (alcantarillaCargaMovil.ts:53 and :193-196). No number is made up.
E_r = 1

#: (c) MULTIPLE PRESENCE FACTOR. The full HL-93 carries a factor m depending on how many lanes are loaded at once. The Hekatan Struct engine does NOT apply it: camionHL93 only accepts rear spacing, IM, width and lane yes/no (cargaMovil.ts:53-62). What is calculated is ONE lane on the 1 m strip. If your code asks for m, it is multiplied outside.

## 4 · The idea that makes everything possible: superposition

#: The model is LINEAR. Linear means the same as y = m·x: if you double the load, the response doubles, and if you put two loads, the response is the SUM of the two separately. That is said in those words in the engine itself (cargaMovil.ts:8-13).
#: So there is no need to solve the structure at each truck position. It is enough to solve it ONCE for each deck node with 1 kN downward. That collection of responses is the INFLUENCE LINE. After that, the truck at any position is a sum:
R = P_1*IL_1 + P_2*IL_2 + P_3*IL_3
#: R can be anything: a moment, a shear, a deflection, the reaction of a spring. The influence line is calculated once and serves for all positions. It is the same as what the SAP2000 Moving Load does (cargaMovil.ts:13).
#: The savings are enormous. Deck nodes of the public example (19 m deck, one node every 0.1 m):
n_nudos = 191
#: Positions that are tried in the envelope:
n_pos = 14424
#: Without superposition the structure would have to be solved 14 424 times. With influence lines it is solved 191 times. The savings:
ahorro = dec(n_pos/n_nudos, 1)

## 5 · The element: where the stiffness comes from (the engine's real formulation)

#: Before moving any truck we must know what the program solves. The whole calculation is ONE equation, and it is y = m·x with matrices instead of numbers: stiffness times displacement gives force.
f = K*u
#: With an ordinary spring the why is seen. The force is the stiffness times the stretch:
F_r = k_r*u_r
#: And if what you know is the force P_dato, you solve for the displacement. More stiffness, less it moves:
Despejar{P_dato = k_r*u_r @ u_r}
#: With the whole structure it is the same, except that K is a large matrix and instead of dividing the system is solved. The engine does it with a Cholesky factorization, LDLT, because K is symmetric and positive definite (deform.cpp:224-238).

#: And where do the numbers of K come from? From the SHAPE FUNCTIONS. Between two nodes, with no load in the middle, the fourth derivative of the beam deflected shape is zero. Integrating a zero four times gives a polynomial of degree 3 (this is derived step by step in example 15 of this same website). The deflected shape of the element is, then, a cubic:
v = c_1 + c_2*x + c_3*x^2 + c_4*x^3
#: It is not an approximation: it is the EXACT shape of the beam between nodes. And it has four constants that fit exactly the four bending degrees of freedom of the element: the displacement and the rotation at each end. Written in terms of those four degrees of freedom, those cubics are the HERMITE functions.
#: The strain that matters in bending is the CURVATURE, which is the second derivative of the deflected shape:
kappa = Diff{Diff{v @ x} @ x}
#: It comes out linear in x: the curvature varies along a straight line inside the element, and so does the moment. The second derivatives of the shape functions are the rows of the matrix B, the one that goes from displacements to strains:
#|  ε = B · u        (B = derivadas de las funciones de forma)
#: And the stiffness of the element is the classic integral of the method, the strain energy put in matrix form:
#|  K_e = ∫ Bᵀ · E · B  dx        (a lo largo del elemento, de 0 a L)

#: Once that integral is done with the Hermite cubics, the matrix of a plane frame member has this form. Six degrees of freedom: at each node two displacements and a rotation. In letters first, which is how it must be read:
K_e = [EA_L, 0, 0, -EA_L, 0, 0; 0, t_f, b_f, 0, -t_f, b_f; 0, b_f, k_f, 0, -b_f, a_f; -EA_L, 0, 0, EA_L, 0, 0; 0, -t_f, -b_f, 0, t_f, -b_f; 0, b_f, a_f, 0, -b_f, k_f]
#: How to read it: it is SYMMETRIC (what node i does to j equals what j does to i). Rows 1 and 4 are pure axial and mix with nothing: stretching does not bend. Rows 2, 3, 5 and 6 are the bending, and there everything is mixed, because lowering one end forces it to rotate.
#: And the five coefficients are the usual ones. The engine has them written just so in getLocalStiffnessMatrix.cpp:214-226:
EA_L = E*A/L
t_f = 12*E*I/L^3
b_f = 6*E*I/L^2
k_f = 4*E*I/L
a_f = 2*E*I/L
#: Look at the units and you understand the physics: EA/L is how much force is needed per meter of stretch, 12EI/L³ is how much force per meter of drop, 4EI/L is how much moment per radian of rotation. And note the L: the bending stiffness goes with L cubed. Splitting an element in two does NOT make it a little stiffer, it makes it eight times stiffer.

#: But the engine is NOT pure Euler-Bernoulli: it is TIMOSHENKO, which means it also counts how much the member deforms by SHEAR. That enters with a single number, phi, which compares the shear flexibility with the bending flexibility (getLocalStiffnessMatrix.cpp:198 and :211):
phi = 12*E*I/(G*A_s*L^2)
#: and the four bending coefficients are corrected like this (getLocalStiffnessMatrix.cpp:218-221). If phi = 0 exactly those of Bernoulli remain, so Bernoulli is the particular case:
t_T = (12*E*I/L^3)/(1 + phi)
b_T = (6*E*I/L^2)/(1 + phi)
k_T = (4*E*I/L)*(1 + phi/4)/(1 + phi)
a_T = (2*E*I/L)*(1 - phi/2)/(1 + phi)
#: The default shear area is that of ETABS, 5/6 of the area (getLocalStiffnessMatrix.cpp:209-210):
A_s = 5*A/6
#: And here a nice formula comes out, still in letters. For a rectangular section of width b and depth t: the area is A = b·t, the inertia I = b·t³/12, and G = E/(2(1+ν)). Putting all that into phi, the width b goes away, E and G go away, and only the slenderness of the element remains:
phi_sim = Simplify{12*E*(b*t^3/12)/((E/(2*(1 + nu)))*(5/6)*(b*t)*L^2)}
#: Read it like this: phi = 12(1+ν)/5 times (t/L) squared. Shear governs when the depth t is large compared with the ELEMENT LENGTH L. A long thin member has phi almost zero and Timoshenko and Bernoulli give the same; a short thick one does not.

#: Now the numbers, for ONE element of the top slab of the example: depth t = 0.50 m, strip width b = 1 m, and length L = 0.1 m, because the deck is meshed at the truck step.
t_losa = 0.50
b_fr = 1
L_el = 0.1
nu = 0.2
A_el = dec(b_fr*t_losa, 4)
I_el = dec(b_fr*t_losa^3/12, 8)
phi_el = dec(12*(1 + nu)/5*(t_losa/L_el)^2, 2)
#: phi = 72, and it is not a detail: the term 12EI/L³ is divided by 73. If the engine were pure Bernoulli, that element would be 73 times stiffer. That is why the fine mesh does not blow up the stiffness, and why the validation in OpenSees had to be done with ElasticTimoshenkoBeam and not with the normal elastic beam (alcantarillaCargaMovil.ts:95).
#: With the concrete of the example, E = 250 000 kgf/cm² (1 kgf/cm² = 98.0665 kN/m²):
E_kg = 250000
E_c = dec(E_kg*98.0665, 0)
G_c = dec(E_c/(2*(1 + nu)), 0)
#: And the four bending coefficients of that element, already in kN and m:
t_num = dec((12*E_c*I_el/L_el^3)/(1 + phi_el), 0)
b_num = dec((6*E_c*I_el/L_el^2)/(1 + phi_el), 0)
k_num = dec((4*E_c*I_el/L_el)*(1 + phi_el/4)/(1 + phi_el), 0)
a_num = dec((2*E_c*I_el/L_el)*(1 - phi_el/2)/(1 + phi_el), 0)
#: Note the sign of the last one: with large phi, the term that drags one end with the other becomes NEGATIVE. That is Timoshenko, not an error.
#: The matrix the engine writes is 12x12, for space (getLocalStiffnessMatrix.cpp:229-241): the six entries we have seen are its sub-block of the plane. The other six are the out-of-plane bending and the torsion, and here they are locked (modeloAlcantarilla.ts:13-16).

#: ASSEMBLY. Each member has its matrix in ITS axes. To add them they must be taken to the global axes with the rotation matrix T (getGlobalStiffnessMatrix.cpp:69-80):
K_glob = T_t*K_loc*T
#: And then they are ADDED, entry by entry, in the global matrix: the row of a degree of freedom is 6 times the node number plus the degree of freedom (getGlobalStiffnessMatrix.cpp:114-133). Adding is the whole assembly: if two members reach the same node, their stiffnesses are added in the same entry. That is why a corner of the culvert is stiff: the slab and the wall are there at once.
#: The soil SPRINGS are even simpler: they are added directly to the DIAGONAL entry of that node and degree of freedom (deform.cpp:162-170). That is, exactly, the SAP2000 nodal spring:
K_dd = K_dd + k_muelle
#: And the spring value is the subgrade modulus times the area that belongs to that node:
k_muelle = k_s*b_trib*b_franja
#: In numbers: ks = 2.0 kgf/cm³ is 19 613.3 kN/m³ (1 kgf/cm³ = 9806.65 kN/m³), with 0.5 m tributary and the 1 m strip:
ks_kg = 2.0
ks_kN = dec(ks_kg*9806.65, 1)
k_muelle = dec(ks_kN*0.5*1, 0)
#: Finally the rows of the supports are removed and it is solved (deform.cpp:214-238). That is ONE load case. This whole sheet is about not having to do it 14 424 times.

## 6 · How the engine gets the influence line

#: For each deck node k, 1 kN downward is applied and it is solved (cargaMovil.ts:203-204): the load is the vector [0, 0, -1, 0, 0, 0], that is -1 in the vertical degree of freedom. From it comes the vector of displacements of the whole structure.
#: And the moments? Here is the speed trick. Calling the analyzer for each case cost 35 ms x 191 cases = 6.6 s (cargaMovil.ts:156). Since everything is linear, the forces of a member are a constant matrix times its 12 displacements:
f_barra = B*u_barra
#: B is 6x12: six results (N, V, M at the two ends) for twelve degrees of freedom of the member. And it is not rewritten by hand: it is taken from the analyzer ITSELF, by giving it unit displacements and reading the columns (cargaMovil.ts:150-186). That is the house rule: do not fabricate the formulation, extract it.
#: The sign is that of the CSI DIAGRAM, not that of the end forces: at node i the diagram is -f, at node j it is +f (cargaMovil.ts:128-131 and :181-182).
M_i = -f_i
M_j = f_j
#: The force of the Winkler springs, just as simple: stiffness times how much the node sinks, with the sign changed because the spring pushes upward (cargaMovil.ts:225):
R_muelle = -k_s*u_z

## 7 · PLOT: the two influence lines of the example

#: Culvert of the link: 2 cells, span 9.5 m center to center, height 6.0 m, top slab 0.50 m, bottom slab 0.55 m, walls 0.45 m (modeloAlcantarilla.ts:36-40). Concrete E = 250 000 kgf/cm2, nu = 0.2; subgrade ks = 2.0 kgf/cm3 under the bottom slab. 19 m deck, 0.1 m mesh: 263 nodes, 264 members, 39 springs.
#: Two control sections: C, the center of cell 1 (x = 4.70 m, the node closest to 4.75), and W, over the central wall (x = 9.50 m). Each curve says how much moment (kN·m) appears in that section when 1 kN stands at the abscissa x of the deck. They come from the engine: 191 unit cases, sampled every 0.5 m for the plot.
#fila
#fplot(IL_centro = [0 0.0253; 0.5 0.114; 1 0.2188; 1.5 0.34; 2 0.4781; 2.5 0.6333; 3 0.8061; 3.5 0.9968; 4 1.2058; 4.5 1.4335; 5 1.3802; 5.5 1.1463; 6 0.9322; 6.5 0.7383; 7 0.5648; 7.5 0.4122; 8 0.2809; 8.5 0.1712; 9 0.0835; 9.5 0.0181; 10 -0.0314; 10.5 -0.0727; 11 -0.1062; 11.5 -0.1326; 12 -0.1523; 12.5 -0.1659; 13 -0.174; 13.5 -0.1771; 14 -0.1756; 14.5 -0.1702; 15 -0.1615; 15.5 -0.1498; 16 -0.1358; 16.5 -0.1201; 17 -0.103; 17.5 -0.0853; 18 -0.0674; 18.5 -0.0499; 19 -0.0333], [0 19])
#fplot(IL_muro = [0 -0.1364; 0.5 -0.2523; 1 -0.3712; 1.5 -0.49; 2 -0.6056; 2.5 -0.7151; 3 -0.8153; 3.5 -0.9031; 4 -0.9756; 4.5 -1.0296; 5 -1.0622; 5.5 -1.0701; 6 -1.0504; 6.5 -1.0001; 7 -0.916; 7.5 -0.7951; 8 -0.6344; 8.5 -0.4307; 9 -0.181; 9.5 0.1177; 10 -0.0418; 10.5 -0.1727; 11 -0.2775; 11.5 -0.3583; 12 -0.4175; 12.5 -0.4573; 13 -0.4801; 13.5 -0.4882; 14 -0.4837; 14.5 -0.4692; 15 -0.4467; 15.5 -0.4186; 16 -0.3873; 16.5 -0.3549; 17 -0.3238; 17.5 -0.2963; 18 -0.2747; 18.5 -0.2613; 19 -0.2583], [0 19])
#finfila
#: Read them like this, which is the whole craft of the moving load:
#: - IL_centro is almost entirely POSITIVE in cell 1 with a peak right above the section. The peak equals 1.5299 kN·m per kN. That is: for the positive moment at the span center, what governs is putting the heavy axle THERE.
#: - In cell 2 (x > 9.5) the same curve becomes NEGATIVE, small, about -0.177. That is: loading the other cell RELIEVES the center of the first. That is why the envelope looks for positions, not just one.
#: - IL_muro is almost entirely negative, with its peak at x = 5.4 m and value -1.0706. The negative moment at the support is obtained by loading the CENTER of the adjacent span, not on top of the wall. At x = 9.5 (right over the wall) the curve equals +0.118, almost nothing: a load on the wall goes straight down to the footing.

## 8 · The truck at one position: the lever rule

#: An axle falls at any point, almost never exactly at a node. If it falls between node i and node j, it is distributed by the lever rule (cargaMovil.ts:279-283). First, where it falls inside the span, as a fraction of one:
Despejar{x_e = s_i + t*(s_j - s_i) @ t}
#: And the distribution is the complementary one at each node: the one that is closer takes more:
w_i = P_eje*(1 - t)
w_j = P_eje*t
#: This is an APPROXIMATION, and the engine says so and measures it: it returns "repartido", the kN it had to distribute, so that the caller can see it (cargaMovil.ts:22-25 and :263). The example is meshed on purpose with a node every 0.1 m, and the truck also advances in steps of 0.1 (alcantarillaCargaMovil.ts:55): the axles ALWAYS fall on a node and "repartido" comes out 0. The moving load is exact, without lever.
#: The path of the truck is not that of the deck: it starts when the first axle enters and ends when the last one leaves (cargaMovil.ts:288-293). In letters:
x_fin = L_tab + L_cam
#: With the 19 m deck and the short 8.6 m truck:
L_tab = 19
L_cam = 8.6
x_fin = L_tab + L_cam
paso = 0.1
n_posic = x_fin/paso + 1

## 9 · PLOT: the moment as the truck advances

#: Now the sum R = P₁·IL₁ + P₂·IL₂ + P₃·IL₃ is applied at each position. The lower curve is the moment at section C (center of cell 1) according to where the FRONT axle is. Truck alone, rear spacing 4.3 m, no lane and no IM. Engine data, every 0.5 m:
#fplot(M_centro = [0 0.88; 0.5 3.99; 1 7.66; 1.5 11.9; 2 16.73; 2.5 22.17; 3 28.21; 3.5 34.89; 4 42.2; 4.5 58.71; 5 70.63; 5.5 78.59; 6 89.64; 6.5 103.86; 7 121.31; 7.5 142.06; 8 166.17; 8.5 193.72; 9 238.53; 9.5 215.36; 10 197.95; 10.5 186.15; 11 180.04; 11.5 179.71; 12 185.25; 12.5 196.75; 13 214.3; 13.5 208.98; 14 166.24; 14.5 128.11; 15 94.18; 15.5 64.39; 16 38.72; 16.5 17.11; 17 -0.48; 17.5 -14.09; 18 -23.76; 18.5 -30.18; 19 -34.83; 19.5 -37.3; 20 -39.49; 20.5 -40.39; 21 -40.17; 21.5 -38.98; 22 -36.97; 22.5 -34.31; 23 -31.14; 23.5 -23.7; 24 -22.09; 24.5 -20.12; 25 -17.88; 25.5 -15.45; 26 -12.89; 26.5 -10.29; 27 -7.74; 27.5 -5.29], [0 27.6])
#: The peak is at x_F = 9.0 m. Why exactly there? Because with the front at 9.0 the axles fall at 9.0, at 9.0 - 4.3 = 4.7 and at 9.0 - 8.6 = 0.4. The 145 kN axle stands EXACTLY over section C. Let us check it by adding by hand, with the three values of the influence line:
IL_04 = 0.09497629
IL_47 = 1.52989986
IL_90 = 0.08349465
#: The sum, first in letters:
R_max = P_1*IL_90 + P_2*IL_47 + P_3*IL_04
#: And now with the numbers:
R_max = dec(35*IL_90 + 145*IL_47 + 145*IL_04, 4)
#: The engine, solving the whole frame, gives 238.5294 kN·m at that position. They agree digit by digit: superposition is not an approximation, it is the same calculation.
R_tonf = dec(R_max/9.80665, 3)
#: And note the tail: past meter 17 the curve becomes NEGATIVE (down to -40.4 kN·m). It is the truck, already in cell 2, lifting the center of cell 1: the negative part of the influence line of the center that we saw in section 7.

## 10 · ANIMATION: the HL-93 truck crossing the deck

#: Two films at once, both with the same counter n (the frame). The truck advances 1.2 m per frame: the position of the front axle is xF = 1.2·n.
#: LEFT, the truck drawn. The silhouette (box, cab and chassis) is made with steps: each piece is a rectangle built with sign(), which equals 1 inside the stretch and 0 outside. Under the ground line, three marks: they are the AXLES, at 0, 4.3 and 8.6 m behind the front one. And in the background, the influence line of the center of cell 1, the same as in section 7.
#: RIGHT, the response. The curve is the moment at that section for each truck position (the one in section 9) and the moving bar marks AT WHAT position the truck on the left is. When the heavy wheel climbs onto the peak of the influence line, the bar on the right reaches the peak.
#fila
#anim fplot(camion = 0.55*(sign(x - 1.2*n + 9.0) + 1)*(sign(1.2*n + 0.9 - x) + 1)/4 + 1.05*(sign(x - 1.2*n + 8.9) + 1)*(sign(1.2*n - 1.3 - x) + 1)/4 + 0.55*(sign(x - 1.2*n + 1.1) + 1)*(sign(1.2*n + 0.75 - x) + 1)/4, ejes = -0.35*((sign(x - 1.2*n + 0.2) + 1)*(sign(1.2*n + 0.2 - x) + 1)/4 + (sign(x - 1.2*n + 4.5) + 1)*(sign(1.2*n - 4.1 - x) + 1)/4 + (sign(x - 1.2*n + 8.8) + 1)*(sign(1.2*n - 8.4 - x) + 1)/4), IL_centro = [0 0.0253; 0.5 0.114; 1 0.2188; 1.5 0.34; 2 0.4781; 2.5 0.6333; 3 0.8061; 3.5 0.9968; 4 1.2058; 4.5 1.4335; 5 1.3802; 5.5 1.1463; 6 0.9322; 6.5 0.7383; 7 0.5648; 7.5 0.4122; 8 0.2809; 8.5 0.1712; 9 0.0835; 9.5 0.0181; 10 -0.0314; 10.5 -0.0727; 11 -0.1062; 11.5 -0.1326; 12 -0.1523; 12.5 -0.1659; 13 -0.174; 13.5 -0.1771; 14 -0.1756; 14.5 -0.1702; 15 -0.1615; 15.5 -0.1498; 16 -0.1358; 16.5 -0.1201; 17 -0.103; 17.5 -0.0853; 18 -0.0674; 18.5 -0.0499; 19 -0.0333], [0 19]), n = 0:23
#anim fplot(M_centro = [0 0.88; 0.5 3.99; 1 7.66; 1.5 11.9; 2 16.73; 2.5 22.17; 3 28.21; 3.5 34.89; 4 42.2; 4.5 58.71; 5 70.63; 5.5 78.59; 6 89.64; 6.5 103.86; 7 121.31; 7.5 142.06; 8 166.17; 8.5 193.72; 9 238.53; 9.5 215.36; 10 197.95; 10.5 186.15; 11 180.04; 11.5 179.71; 12 185.25; 12.5 196.75; 13 214.3; 13.5 208.98; 14 166.24; 14.5 128.11; 15 94.18; 15.5 64.39; 16 38.72; 16.5 17.11; 17 -0.48; 17.5 -14.09; 18 -23.76; 18.5 -30.18; 19 -34.83; 19.5 -37.3; 20 -39.49; 20.5 -40.39; 21 -40.17; 21.5 -38.98; 22 -36.97; 22.5 -34.31; 23 -31.14; 23.5 -23.7; 24 -22.09; 24.5 -20.12; 25 -17.88; 25.5 -15.45; 26 -12.89; 26.5 -10.29; 27 -7.74; 27.5 -5.29], xF_ahora = 240*(sign(x - 1.2*n + 0.2) + 1)*(sign(1.2*n + 0.2 - x) + 1)/4, [0 27.6]), n = 0:23
#finfila
#: What to look at, and it is the WHOLE craft of the moving load: the moment of each frame is the sum of the height of the influence line under each axle, multiplied by the load of that axle. No more, no less. When an axle steps where the curve is high, it adds a lot; when it steps where the curve is negative (the second cell), it SUBTRACTS. That is why the worst case is not "the truck at the center": all of them must be tried.
#: The silhouette in letters, so that you see there is no magic. A rectangle between a and b, of height h, is:
rect = h*(sign(x - a) + 1)*(sign(b - x) + 1)/4
#: The first parenthesis equals 2 if x is to the right of a and 0 if not; the second equals 2 if x is to the left of b. Multiplied and divided by 4 they give 1 only INSIDE the stretch. Adding three rectangles gives the truck, and moving a and b with n, the truck moves.

## 11 · The envelope: the worst of ALL cases

#: The envelope is, at each point of the structure, the maximum and the minimum of all the positions tried (cargaMovil.ts:375-383). And it is not one sweep: it is THREE nested sweeps.
#: (1) EACH REAR SPACING. a₂ goes from 4.3 to 9.0 every 0.1 m (cargaMovil.ts:406-409). That is 48 different trucks:
n_sep = (a_2max - a_2min)/0.1 + 1
#: (2) EACH TRUCK TRAVELS ITS OWN LENGTH. This was an error that had to be fixed (log of 19-Sep-2026): a 13.3 m truck takes longer to leave than an 8.6 m one; if the positions of the short one are used, the long one is left half out (cargaMovil.ts:368-374). Positions of a truck with spacing a₂:
n_por_sep = (L_tab + a_1 + a_2)/paso + 1
#: Adding the 48 spacings gives the 14 424 positions we said above. It is checked: the sum of (19 + 4.3 + a₂)/0.1 + 1 for the 48 spacings equals
n_tot = 48*234 + 10*48*(a_2min + a_2max)/2
#: (3) THE LANE, LOADED "IN PIECES". The lane does not move: it is placed where it does harm and removed where it helps. The engine goes node by node and adds the contribution to the maximum if it is positive and to the minimum if it is negative (cargaMovil.ts:396-399). In letters, the equivalent point load of each node is the distributed load times its tributary width:
q_k = w_c*b_k
#: And the tributary width is half a span on each side (cargaMovil.ts:120-123):
b_k = (s_k - s_ant + s_sig - s_k)/2
#: On the deck, with nodes every 0.1 m, that equals 0.1 m in the interior. The nodal lane load:
q_nodo = dec(w_c*0.1, 3)
#: And the distribution by sign: rₖ = qₖ·ILₖ; if rₖ is positive it adds to the MAXIMUM, if negative it adds to the MINIMUM. That is how SAP2000 defines the HL-93K: truck and lane at the same time (cargaMovil.ts:351-356).

## 12 · PLOTS: the envelope of M and V

#: Moment in the top slab along the 19 m. The two curves are the maximum and the minimum of the 14 424 positions, truck plus lane. Sampled every 0.5 m:
#fplot(M_max = [0 55.14; 0.5 67.1; 1 111.39; 1.5 151.43; 2 193.93; 2.5 236.9; 3 267.64; 3.5 285.98; 4 292.5; 4.5 292.37; 5 293.46; 5.5 282.03; 6 257.71; 6.5 220.84; 7 172.65; 7.5 134.64; 8 97.02; 8.5 61.26; 9 20.43; 9.5 -4.47; 10 36.28; 10.5 75.61; 11 109.46; 11.5 144.84; 12 180.4; 12.5 226.02; 13 260.34; 13.5 282.29; 14 291.68; 14.5 296.18; 15 296.87; 15.5 289.05; 16 269.52; 16.5 237.88; 17 194.45; 17.5 151.28; 18 112.65; 18.5 73.79; 19 54.73], M_min = [0 -180.64; 0.5 -103.88; 1 -48.73; 1.5 -20.03; 2 -9.28; 2.5 -10.79; 3 -18.68; 3.5 -27.81; 4 -37.31; 4.5 -47; 5 -56.74; 5.5 -66.53; 6 -76.37; 6.5 -86.38; 7 -97.24; 7.5 -110.72; 8 -144.24; 8.5 -196.45; 9 -257.84; 9.5 -346.99; 10 -257.92; 10.5 -191.92; 11 -136.18; 11.5 -103.84; 12 -90.18; 12.5 -79.34; 13 -69.5; 13.5 -59.98; 14 -50.59; 14.5 -41.36; 15 -32.3; 15.5 -23.55; 16 -15.29; 16.5 -8.14; 17 -9.04; 17.5 -20.7; 18 -49.4; 18.5 -106.78; 19 -183.13], [0 19])
#: Shear in the same slab, maximum and minimum:
#fplot(V_max = [0 20.37; 0.5 20.57; 1 23.17; 1.5 33.74; 2 44.38; 2.5 55.08; 3 65.85; 3.5 76.67; 4 87.53; 4.5 98.42; 5 109.53; 5.5 128.39; 6 147.59; 6.5 167; 7 186.45; 7.5 205.79; 8 224.84; 8.5 243.44; 9 261.41; 9.5 278.58; 10 0.34; 10.5 11.45; 11 17.41; 11.5 24.21; 12 31.8; 12.5 40.12; 13 49.09; 13.5 58.65; 14 68.84; 14.5 85.21; 15 103.2; 15.5 120.13; 16 137.89; 16.5 156.31; 17 175.22; 17.5 194.45; 18 213.82; 18.5 233.17; 19 252.31], V_min = [0 -254.71; 0.5 -238.52; 1 -218.25; 1.5 -198.1; 2 -178.2; 2.5 -158.72; 3 -139.81; 3.5 -121.64; 4 -104.36; 4.5 -88.12; 5 -73.07; 5.5 -60.85; 6 -50.47; 6.5 -40.8; 7 -31.91; 7.5 -23.84; 8 -16.64; 8.5 -10.37; 9 -1.08; 9.5 0.85; 10 -265.01; 10.5 -244.89; 11 -226.54; 11.5 -207.8; 12 -188.83; 12.5 -169.83; 13 -150.97; 13.5 -132.43; 14 -114.37; 14.5 -100.84; 15 -88.14; 15.5 -77.19; 16 -66.25; 16.5 -55.35; 17 -44.5; 17.5 -33.74; 18 -23.07; 18.5 -20.73; 19 -20.46], [0 19])
#: What the first plot says, in practice:
#: - Two positive humps, one per cell, of about 293-297 kN·m at the center of each span.
#: - A negative peak nailed at x = 9.5 m, the central wall: -346.99 kN·m. It is the largest of the sheet, and it governs the top reinforcement over the wall.
#: - At the ends (x = 0 and x = 19) there is also strong negative, -180 and -183 kN·m: the slab is joined to the exterior walls, not simply supported.
#: - The curve of maxima and that of minima never cross: the envelope is not one curve, it is TWO, and the section is reinforced for both.
#: The shear one: the maximum appears next to the walls (278.58 kN to the left of the central wall, -265.01 right to its right) and passes through zero near the center of each span. The jump at x = 9.5 is the load that goes down through the wall.

## 13 · How much the lane adds

#: The engine stores the two envelopes separately: that of the truck ALONE, before adding the lane (cargaMovil.ts:388-389), and the total. That way it is seen what each contributes. Maximum and minimum moment of the truck alone:
#fplot(M_max_camion = [0 45.61; 0.5 56.32; 1 96.41; 1.5 129.68; 2 164.01; 2.5 198; 3 221.27; 3.5 234.2; 4 237.47; 4.5 236.36; 5 238.78; 5.5 230.99; 6 212.62; 6.5 183.87; 7 145.29; 7.5 116.61; 8 86.59; 8.5 56.17; 9 18.59; 9.5 -4.77; 10 34.44; 10.5 70.52; 11 99.02; 11.5 126.82; 12 153.04; 12.5 189.05; 13 215.25; 13.5 231.25; 14 236.99; 14.5 240.16; 15 241.84; 15.5 237.27; 16 223.15; 16.5 198.98; 17 164.53; 17.5 129.54; 18 97.66; 18.5 63; 19 45.2], M_min_camion = [0 -143.48; 0.5 -82.99; 1 -38.84; 1.5 -16.25; 2 -7.88; 2.5 -8.64; 3 -14.96; 3.5 -22.25; 4 -29.76; 4.5 -37.38; 5 -45.05; 5.5 -52.76; 6 -60.49; 6.5 -68.26; 7 -76.02; 7.5 -83.81; 8 -107.57; 8.5 -145.45; 9 -188.09; 9.5 -254.45; 10 -188.17; 10.5 -140.92; 11 -99.5; 11.5 -76.93; 12 -68.96; 12.5 -61.21; 13 -53.63; 13.5 -46.21; 14 -38.89; 14.5 -31.73; 15 -24.75; 15.5 -17.99; 16 -11.57; 16.5 -5.98; 17 -7.65; 17.5 -16.92; 18 -39.52; 18.5 -85.9; 19 -145.98], [0 19])
#: The peaks, side by side:
#tabla("Result","Truck alone:2","Truck + lane:2","Increase [%]:1")({"M máx [kN·m]","M mín [kN·m]","Deflection Uz min [mm]"}; [241.84, -254.45, -9.694]; [297.61, -346.99, -12.323]; [23.1, 36.4, 27.1])
#: The lane is not decoration: it raises the negative moment of the central wall by 36 %. And it raises the negative more than the positive, because the influence line of the wall is negative over almost the WHOLE deck (section 7): the lane can load the entire 19 m and all of it adds against.
#: In Ecuador units, the governing peaks:
M_pos_tonf = dec(297.61/9.80665, 3)
M_neg_tonf = dec(-346.99/9.80665, 3)
V_max_tonf = dec(279.95/9.80665, 3)

## 14 · Is it right? What has a judge and what does not

#: House rule: the oracle is ANOTHER program, same model, same mesh node by node, offsets = 0. This is what has been checked (validation/carga-movil/COMPARACION_ejemplo.md):
#tabla("Check","Hekatan:4","SAP2000 24 (judge):4","OpenSeesPy:4","dif [%]:4")({"Envelope M3 max [kN·m]","Envelope M3 min [kN·m]","Uz mín [mm]","Worst component P/V2/M3"}; [77.3201, -89.6117, -6.5198, 0]; [77.3201, -89.6117, -6.5198, 0]; [77.3201, -89.6117, -6.5198, 0]; [0, 0, 0, 0])
#: CHECKED YES: the EXAMPLE culvert, 2 cells of 3.0 x 2.5 m with 0.30 m thickness. SAP2000 24 and OpenSeesPy solved the 61 unit cases and a SEPARATE code rebuilt the envelope of the 8 184 positions: 0.0000 % in Ux, Uz, Ry, P, V2 and M3. Zero to four decimals means the three programs do the SAME calculation.
#: And there is a second check, harder still: SAP2000 has a NATIVE truck (Moving Load case and Multi-Step Static case with vehicle), that is, it does the moving load with ITS own code, not with static cases that we pass it. A lane was set up over the 60 members of the slab and two general vehicles (35/145/145 with 4.3 m, and the HL-93 with lane 9.3 kN/m and rear 4.3-9.0). Result (registros/2026-09-19_alcantarilla_verificacion.md):
#tabla("Envelope (3.0 x 2.5 m example)","Hekatan:4","SAP2000 native Moving Load:4","diff [%]:3")({"Truck: M3 max [kN·m]","Truck: M3 min [kN·m]","Truck: Uz min [mm]","HL-93 + lane: M3 max [kN·m]","HL-93 + lane: M3 min [kN·m]","HL-93 + lane: Uz min [mm]"}; [71.5127, -77.7595, -5.8512, 77.3201, -89.6117, -6.5198]; [71.5128, -77.7599, -5.8512, 77.3194, -89.6053, -6.5198]; [0.000, 0.001, 0.000, 0.001, 0.007, 0.000])
#: And SAP's truck step by step (Multi-Step Static, 147 steps): 134 steps match Hekatan to 5e-10 % in Ux, Uz, Ry, P, V2 and M3, all nodes and all members. The steps that do not match are of convention, not of calculation: SAP does not load an axle that falls exactly at x = 0 (the start of the lane) and Hekatan does.
#: Sheet 51 of this same website, "Box culvert with HL-93 truck - analytical check and SAP2000", carries that verification with all its laws: equilibrium, Maxwell-Betti, symmetry and hand bounds that enclose the finite element. This sheet EXPLAINS; that one VERIFIES.
#: And a third: the same culvert made with PLATES instead of members. The app lets you choose the element (Members / Shell-thick plates / shell-thin) and the moving load runs the same, because the influence line does not ask what the model is made of. Results from the verification log of 19-Sep-2026 (EXAMPLE case 3.0 x 2.5 m, 87 Q4 plates, 172 nodes):
#|  fuente: registros/2026-09-19_alcantarilla_verificacion.md
#tabla("Comparison with PLATES (3.0 x 2.5 m example)","Displacements [%]:4","Moment [%]:2")({"Hekatan plates vs SAP2000 shell-thick (26 pos., 172 nodes)","Hekatan plates vs Hekatan members (shell-thick)","Hekatan plates vs Hekatan members (shell-thin)"}; [0.0000, 0.14, 1.00]; [0.33, 1.09, 0.90])
#: The first two numbers say different things and should not be confused:
#: - Against SAP2000, plate against plate: 0.0000 % in displacements and 0.33 % in M11. That is THE SAME CALCULATION; the 0.33 % is a single node moment next to the central wall (0.26 of 78 kN·m), the rest of the nodes coincide.
#: - Plates against members: 0.14 % in Uz and 1.09 % in M3. That is NOT an error: they are two different mathematical models, a Mindlin Q4 plate with ν = 0.2 against a beam. That they differ by 1 % is the sign that both are right and that the theory weighs little here.
#: - In the HL-93 + lane envelope: plates -6.5117 mm and 77.72 / -90.34 kN·m, members -6.5198 mm and 77.32 / -89.61 kN·m. A +0.5 % and a -0.8 %.
#: MISSING: the LARGE case of this sheet, the 9.5 x 6 m one of the link. The numbers of sections 7 to 13 are from the Hekatan engine and are checked by equilibrium (sum of reactions = sum of loads to 1e-9 kN at all positions), but SAP2000 has not yet arbitrated them. No SAP2000 figures are given for this case because they do not exist: fabricating them would be lying.
#: ALSO MISSING: the AASHTO distribution width E (section 3b). While there is no code on the PC, E = 1 m and warned in orange.

## 15 · The limits, stated and not hidden

#: The engine itself writes them in its header (cargaMovil.ts:22-30). Repeated here:
#: - LINEAR models only. The whole sheet rests on superposition. Springs that only work in compression (the footing that lifts off in example 48) are NONLINEAR: there superposition does not hold and one must solve position by position.
#: - The axle between two nodes is distributed by the lever rule. It is exact only if it falls on a node. That is why it is meshed at 0.1 m.
#: - The lane is not drawn in the animation: the truck is seen, but in the envelope the lane is added.
#: - The model is a 1 m strip in the XZ plane, with the out-of-plane degrees of freedom locked and a Ux at the lower left node so that the box does not slide (modeloAlcantarilla.ts:13-16). The loads are vertical, so that reaction comes out 0: it is a holding support, not a load one.
#: - No multiple presence factor (section 3c) and no spread of the wheel through the fill.

## 16 · The app screen, label by label

#: This section reads the screen of the public example as one reads a drawing: what each thing is and where its number comes from. All with the file:line of the code that draws it.

#: **(a) The red labels on the axles: 14.79 · 14.79 · 3.57 tonf.**
#: Each red arrow is an axle of the truck and its label is the load that axle puts INTO THE MODEL, converted to tonf. In letters:
rotulo = P_k/9.80665
#: And note: P_k is NOT the code number as is. It is the code one, with the impact and divided by the distribution width (cargaMovil.ts:82-84). That is, the label carries inside the two factors of section 3 (the impact and the width you have set in the controls):
P_k = P_norma*(1 + IM_x/100)/E_x
#: The label is written with two decimals in animadorCargaMovil.ts:466. Now the numbers, with the default values of the example (IM = 0 % in alcantarillaCargaMovil.ts:52, and E = 1 m in :53):
IM_def = 0
Er_def = 1
rot_trasero = dec(145*(1 + IM_def/100)/Er_def/9.80665, 2)
rot_delantero = dec(35*(1 + IM_def/100)/Er_def/9.80665, 2)
#: 14.79 and 3.57. They come out exact. So the correct reading of that screen is: **they are the HL-93 axles WITHOUT impact and WITHOUT distribution**, which is what the opened example brings. It is not that the program does not know how to apply them: they come switched off on purpose, so that the effect of the moving load alone can be seen.
#: If you raise the IM to 33 %, that same label changes before your eyes:
rot_IM33 = dec(145*(1 + 33/100)/1/9.80665, 2)
#: And if you set a distribution width of 3 m, it is divided by 3:
rot_E3 = dec(145*(1 + 0/100)/3/9.80665, 2)
#: That is the check that the label is not decoration: it is the real load that enters the system of equations.

#: **(b) The white box: "1 m design strip".**
#: The model is NOT the whole culvert: it is a 1 m wide SLICE, a plane frame (modeloAlcantarilla.ts:1-2). The white box is exactly that slice: it is drawn at y = -0.5 and y = +0.5 (animadorCargaMovil.ts:307), exactly one meter. The gray roadway around it is 9 m and is DRAWING ONLY, so that the wheels are not seen hanging in the air before entering (animadorCargaMovil.ts:225 and :390-392).
#: The reason for the slice is the usual one in a culvert: it is long and all its slices work the same, so it is enough to calculate one and repeat it. Everything that comes out of the sheet is "per meter of culvert".
#: And then, how much load falls on that slice? There the distribution width E comes in:
P_franja = P_eje*(1 + IM_x/100)/E_x
#: Read it as y = m·x with m = 1/E: the wider you distribute, the less load per meter. With E = 1 m the WHOLE AXLE goes into a single meter, which is the most unfavorable thing that can happen: nothing is distributed to the sides. That is why it is the safe side.
#: What would change if there were an AASHTO source for the equivalent strip? E would be greater than 1, and since the model is LINEAR, ALL the results would drop in the same proportion 1/E. That can be stated, because it is the superposition of section 4:
M_conE = M_con1/E_x
#: With the negative moment of the central wall of this sheet, -346.99 kN·m with E = 1 m, a distribution over 2 m would give:
M_E2 = dec(-346.99/2, 2)
#: and over 3 m:
M_E3 = dec(-346.99/3, 2)
#: What can NOT be said is HOW MUCH E is worth, because there is no code on this PC (section 3b). That is why the orange warning on the screen and why the control is there, so that whoever has the code in front of them can set it.

#: **(c) Why the truck goes in that direction, and what happens on entering and leaving.**
#: The path is the nodes of the top slab SORTED by the X coordinate (cargaMovil.ts:110-116), so the truck advances in +X. The front axle rules, and the other two go behind (cargaMovil.ts:277):
x_k = x_F - d_k
#: The travel is not that of the deck: it starts when the FIRST axle steps on and ends when the LAST one leaves (cargaMovil.ts:288-293):
x_fin = L_tab + L_x
#: With the numbers of the example (19 m deck, short truck 8.6 m):
x_fin = dec(19 + 8.6, 1)
#: And what happens meanwhile: an axle whose abscissa falls OUTSIDE the path loads nothing. The engine does not throw it away, it notes it apart, in "fuera", so that equilibrium can be checked (cargaMovil.ts:263 and :272). In letters, the load that is really on the structure at each position is:
P_dentro = P_camion - P_fuera
#: That is why the start of the animation is so smooth: during the first 4.3 m only the front axle is inside, the 3.57 tonf one, which is a ninth of the truck. And that is why the end also drops slowly: the axles leave one by one.

#: **(d) The axle that falls between two nodes.**
#: It is the general case and is solved with the lever rule (section 8): the one that is closer takes more. The distribution preserves the two things that matter, the total force and its moment about the two nodes:
w_i = P_eje*(1 - t)
w_j = P_eje*t
suma = w_i + w_j
#: And it is enough because the model is LINEAR: the response to two loads is the sum of the responses (section 4). On this screen, moreover, it is not even needed: the deck is meshed every 0.1 m and the truck advances every 0.1 m, so the axles ALWAYS fall on a node and the engine counter "repartido" comes out 0. The moving load is exact.

#: **(e) The colors of the deformed shape.**
#: The color of each point is its TOTAL displacement divided by the worst displacement of the WHOLE travel (animadorCargaMovil.ts:290 and :480-491). In letters:
mag = sqrt(u_x^2 + u_z^2)
color = mag/u_ref
#: The key is that u_ref is FIXED: it is not the maximum of this frame, it is that of the 277 frames. That is why, when the small axle enters, the slab is painted blue even though it is moving: it moves 6-24 % of what it will move later. When the first 14.79 tonf axle enters it jumps to 79 % and turns orange. If the scale were that of each frame, everything would always look red and nothing would be learned.
#: And the deformed shape is AMPLIFIED, because otherwise it would not be seen. The rule is: the worst displacement of the travel is drawn as 1.5 % of the model diagonal (animadorCargaMovil.ts:226 and :491):
esc_def = 0.015*diag/u_max
#: The numbers of this culvert. The diagonal of the box the model occupies (19 m long by 6 m high):
diag = dec((19^2 + 6^2)^0.5, 4)
#: The worst displacement of the whole travel, measured in the engine:
u_max = 0.0098386
#: And the size with which it is drawn, and the factor:
dibujado = dec(0.015*diag, 3)
esc_def = dec(0.015*diag/u_max, 1)
#: That is, the deformed shape is multiplied by about 30 times, and 9.84 mm of real deflection is drawn as 30 cm. The factor is not hidden: the app writes it on screen ("deformada xN"). It is the same idea as SAP2000's "Auto" for modes, but more prudent: with the 3.7 % that the modal one uses, this culvert came out rubbery (x75) and the walls looked bent as if they were plasticine.
