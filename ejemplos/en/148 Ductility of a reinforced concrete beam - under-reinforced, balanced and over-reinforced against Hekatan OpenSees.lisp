# Ductility of a reinforced concrete beam: under-reinforced, balanced and over-reinforced (ACI 318 against Hekatan OpenSees)
#numerico

#: **What this sheet does.** It reproduces the «ductility laboratory» of a beam in bending: the same beam with **little, just enough or a lot of steel**, and which fails first, the steel or the concrete. It is solved in **three independent ways** that are compared:
#: **1)** By hand, with the ACI 318 **Whitney block** (this sheet).
#: **2)** With a **fiber section** in the browser (the 3D simulator viga-ductilidad/index.html).
#: **3)** With **Hekatan OpenSees** (the Hekatan DLL): 48 dispBeamColumn elements, Concrete02 concrete and Steel01 steel, pushing the beam with **displacement control** until the concrete crushes.
#: **Units.** kgf, cm and kgf/cm², as in Ecuador; loads in tonf (1 t = 1000 kgf).

## 1 · The beam and the test

#: Simply supported beam of span L, loaded at **two points** at L/3 and 2L/3 (4-point bending test). Between the two loads the moment is **constant** and there is no shear: there «pure» bending is seen.
b = 15 'beam width [cm]
h = 25 'total depth [cm]
r_e = 3.5 'cover to the center of the steel [cm]
L_v = 250 'span between supports [cm]
f_c = 210 'compressive strength of the concrete [kgf/cm2]
f_y = 4200 'yield stress of the steel [kgf/cm2]
E_s = 2000000 'modulus of elasticity of the steel [kgf/cm2]
d = h - r_e 'effective depth: from the top fiber to the center of the steel [cm]

#dibujo("4-point bending test: P/2 at each third; between the loads the moment is constant", ud = cm, escala = auto, cotas = cm, alto = 70)
#  rect(0, 0, 250, 25, "gruesa")
#  achurado(0, 0, 250, 25, "concreto")
#  linea(0, 3.5, 250, 3.5, "trazos rojo")
#  flecha(83.3, 50, 83.3, 26, "rojo")
#  flecha(166.7, 50, 166.7, 26, "rojo")
#  texto(86, 46, "P/2", 3, "i")
#  texto(169, 46, "P/2", 3, "i")
#  flecha(0, -12, 0, -1, "azul")
#  flecha(250, -12, 250, -1, "azul")
#  cota(0, -18, 83.3, -18, -3, "L/3")
#  cota(83.3, -18, 166.7, -18, -3, "L/3")
#  cota(166.7, -18, 250, -18, -3, "L/3")
#  cota(-8, 0, -8, 25, -3, "h = 25")
#fin

#: **From moment to load.** Each support receives P/2; at the third the moment is (P/2)·(L/3) = P·L/6. Therefore, to go from a moment M to the total jack load: **P = 6·M/L**.

## 2 · Cracking: when the first crack appears

#: While the bottom fiber does not exceed the tensile strength of the concrete (the **modulus of rupture** f_{r} = 2·√f'c in kgf/cm²), the section works **whole**, like an elastic rectangle. The cracking moment comes from Navier with the gross inertia:
f_r = 2·sqrt(f_c) 'modulus of rupture [kgf/cm2]
I_g = b·h^3/12 'gross inertia of the rectangle [cm4]
M_cr = f_r·I_g/(h/2) 'cracking moment [kgf·cm]
P_cr = 6·M_cr/L_v/1000 'total load that cracks the beam [t]
P_cr_ops = 1.168 'Hekatan OpenSees: load when the bottom fiber reaches f_r/E_c, with As = 1.40 [t]
#: **Reading.** OpenSees cracks somewhat **later**: its fiber section **includes the steel**, which adds inertia and lowers the center of gravity. That is the **transformed section**: the steel counts n = E_{s}/E_{c} times its area in concrete. With E_{c} = 2·f'c/ε_{0} (the initial slope of Concrete02, ε_{0} = 0.002):
E_c = 2·f_c/0.002 'initial modulus of the Concrete02 concrete [kgf/cm2]
n_m = E_s/E_c 'modular ratio [-]
A_s9 = 9.59 'steel of the over-reinforced beam (section 5) [cm2]
A_tr = b·h + (n_m - 1)·A_s9 'transformed area [cm2]
y_g = -(n_m - 1)·A_s9·(h/2 - r_e)/A_tr 'drop of the center of gravity, from mid-depth [cm]
I_tr = I_g + b·h·y_g^2 + (n_m - 1)·A_s9·(h/2 - r_e + y_g)^2 'transformed inertia [cm4]
M_cr9 = f_r·I_tr/(h/2 + y_g) 'cracking moment with the steel [kgf·cm]
P_cr9 = 6·M_cr9/L_v/1000 'cracking load with the steel [t]
P_cr9_ops = 1.610 'Hekatan OpenSees with As = 9.59 [t]
#: With the transformed section the formula and OpenSees agree (1.59 against 1.61 t). With little steel the difference is small (1.09 gross against 1.17 t): there the gross section is enough.

## 3 · The three steel amounts set by the ACI

#: **Whitney block.** The ACI replaces the curved compression of the concrete with a rectangle of height 0.85·f'c and depth a = β_{1}·c. For f'c ≤ 280 kgf/cm², β_{1} = 0.85.
beta_1 = 0.85 'Whitney block factor, valid up to 280 kgf/cm2 [-]
#: **Balanced failure:** the concrete reaches ε_{cu} = 0.003 **at the same instant** that the steel reaches ε_{y} = f_{y}/E_{s}. By similar triangles, c_{b}/d = 0.003/(0.003 + ε_{y}) = 6000/(6000 + f_{y}); with C = T the balanced ratio comes out:
rho_b = 0.85·beta_1·f_c/f_y·6000/(6000 + f_y) 'balanced ratio [-]
A_sb = rho_b·b·d 'balanced steel [cm2]
A_smax = 0.75·A_sb 'maximum steel of the old code (0.75·Asb) [cm2]
#: **Minimum steel** (ACI 318, 9.6.1.2): the larger of 0.8·√f'c/f_{y}·b·d and 14/f_{y}·b·d. It exists so that, on cracking, the steel **can** take the tension released by the concrete without breaking suddenly.
A_smin = max(0.8·sqrt(f_c)/f_y, 14/f_y)·b·d 'minimum steel [cm2]
#: **Reading.** With b = 15 cm and d = 21.5 cm, the useful steel goes from A_{smin} = 1.07 to A_{sb} = 6.85 cm². Below, the beam fails on cracking; above, the concrete crushes before the steel yields.

## 4 · Under-reinforced beam: As = 1.40 cm²

A_s1 = 1.40 'steel of the beam in the video [cm2]
#: The steel is assumed to yield (f_{s} = f_{y}). Equilibrium C = T: 0.85·f'c·b·a = A_{s}·f_{y}.
a_1 = A_s1·f_y/(0.85·f_c·b) 'depth of the Whitney block [cm]
c_1 = a_1/beta_1 'neutral axis from the top [cm]
e_t1 = 0.003·(d - c_1)/c_1 'steel strain when the concrete reaches 0.003 [-]
#: ε_{t} comes out about **ten times** ε_{y} = 0.0021: the steel yields long before the concrete crushes. The assumption holds.
M_n1 = A_s1·f_y·(d - a_1/2) 'nominal moment [kgf·cm]
P_n1 = 6·M_n1/L_v/1000 'nominal total load [t]
P_y1_ops = 2.929 'Hekatan OpenSees: load when the steel yields [t]
P_u1_ops = 2.872 'Hekatan OpenSees: load when the concrete reaches 0.003 [t]
D_y1_ops = 8.380 'Hekatan OpenSees: deflection when the steel yields [mm]
D_u1_ops = 50.580 'Hekatan OpenSees: deflection when the concrete reaches 0.003 [mm]
mu_1 = D_u1_ops/D_y1_ops 'displacement ductility μΔ [-]
#: **Reading.** The ACI by hand (2.88 t) lies between the two OpenSees loads (2.87 at crushing, 2.93 at yielding): **1 to 2 %** difference. But the deflection goes from about 8 mm at yielding to about 51 mm at crushing: μ_{Δ} ≈ 6. That **plateau** is the ductility: the beam warns with wide cracks and a large deflection.

## 5 · Over-reinforced beam: As = 1.4·Asb

A_s4 = 1.4·A_sb 'a lot of steel: 40 % above balanced [cm2]
#: Here the steel **does not yield**: f_{s} = E_{s}·0.003·(d − c)/c. The equilibrium 0.85·f'c·b·β_{1}·c = A_{s}·E_{s}·0.003·(d − c)/c, multiplied by c, is a 2nd degree equation in c: q_{a}·c² + q_{b}·c − q_{b}·d = 0.
q_a = 0.85·f_c·b·beta_1 'coefficient of c² [kgf/cm2·cm]
q_b = A_s4·E_s·0.003 'coefficient of c [kgf]
c_4 = (-q_b + sqrt(q_b^2 + 4·q_a·q_b·d))/(2·q_a) 'neutral axis from the top [cm]
f_s4 = E_s·0.003·(d - c_4)/c_4 'steel stress, less than fy: it does not yield [kgf/cm2]
a_4 = beta_1·c_4 'Whitney block [cm]
M_n4 = A_s4·f_s4·(d - a_4/2) 'nominal moment [kgf·cm]
P_n4 = 6·M_n4/L_v/1000 'nominal total load [t]
P_u4_ops = 11.365 'Hekatan OpenSees: load when the concrete reaches 0.003 [t]
D_u4_ops = 13.000 'Hekatan OpenSees: deflection when the concrete reaches 0.003 [mm]
#: **Reading.** The steel stays at about 3300 kgf/cm², far from the 4200: it does not yield. The ACI gives 4 % more than OpenSees (the Whitney block with ε_{cu} = 0.003 is not the Concrete02 parabola). The beam carries **four times more** than the under-reinforced one, but it breaks with little deflection and **without warning**. That is why the code puts a cap on the steel even though it «can take more».

## 6 · The Hekatan OpenSees curves

#: **How to read it.** x axis: deflection at the center Δ [mm]. y axis: total load P [t]. Each curve is the same section with more steel. First it rises straight (no cracks), then it bends (cracks). After that, the **under-reinforced** one makes a long plateau (the steel yields), while the **balanced** and the **over-reinforced** ones reach higher but **are cut off early**, when the concrete reaches its ultimate strain.
#fplot(sub_140 = [0.01 0.016; 0.17 0.264; 0.33 0.511; 0.49 0.757; 0.65 1.001; 0.81 1.241; 0.99 1.461; 1.24 1.675; 1.69 1.884; 2.76 1.826; 3.95 1.950; 5.30 2.207; 6.36 2.457; 7.38 2.701; 8.58 2.923; 10.18 2.897; 11.78 2.887; 13.38 2.883; 14.98 2.882; 16.58 2.883; 18.18 2.883; 19.78 2.886; 21.38 2.886; 22.98 2.888; 24.58 2.891; 26.18 2.891; 27.78 2.892; 29.38 2.893; 30.98 2.895; 32.58 2.897; 34.18 2.896; 35.78 2.896; 37.38 2.895; 38.98 2.893; 40.58 2.891; 42.18 2.890; 43.78 2.888; 45.38 2.885; 46.98 2.881; 48.58 2.877; 50.18 2.873; 51.78 2.868; 53.38 2.862; 54.98 2.852; 56.58 2.841; 58.18 2.827; 58.98 2.796], max_075Asb = [0.01 0.017; 0.10 0.174; 0.19 0.330; 0.28 0.486; 0.37 0.641; 0.46 0.795; 0.55 0.949; 0.64 1.103; 0.73 1.256; 0.82 1.408; 0.94 1.596; 1.06 1.764; 1.20 1.937; 1.35 2.102; 1.52 2.271; 1.70 2.432; 1.90 2.597; 2.11 2.756; 2.34 2.919; 2.58 3.079; 2.82 3.231; 3.09 3.394; 3.36 3.550; 3.64 3.707; 3.91 3.863; 4.40 4.162; 5.00 4.547; 5.60 4.942; 6.20 5.342; 6.80 5.745; 7.40 6.146; 8.00 6.546; 8.60 6.941; 9.20 7.330; 9.80 7.711; 10.40 8.084; 11.00 8.446; 11.60 8.796; 12.20 9.132; 12.80 9.259; 13.40 9.256; 14.00 9.241; 14.60 9.215; 15.20 9.176; 15.80 9.125; 16.40 9.058; 17.00 8.970; 17.60 8.853; 18.20 8.690; 18.80 8.415; 19.40 7.964; 19.40 7.964], balanceada = [0.01 0.018; 0.10 0.182; 0.19 0.344; 0.28 0.507; 0.37 0.668; 0.46 0.829; 0.55 0.990; 0.64 1.150; 0.73 1.309; 0.82 1.468; 0.92 1.638; 1.04 1.823; 1.16 1.992; 1.28 2.148; 1.43 2.327; 1.58 2.494; 1.73 2.652; 1.90 2.820; 2.08 2.991; 2.26 3.154; 2.44 3.311; 2.62 3.463; 2.83 3.636; 3.04 3.804; 3.25 3.969; 3.46 4.130; 3.67 4.288; 3.88 4.444; 4.40 4.837; 5.00 5.306; 5.60 5.783; 6.20 6.260; 6.80 6.736; 7.40 7.206; 8.00 7.668; 8.60 8.120; 9.20 8.560; 9.80 8.985; 10.40 9.393; 11.00 9.782; 11.60 10.139; 12.20 10.434; 12.80 10.659; 13.40 10.799; 14.00 10.821; 14.60 10.664; 15.20 10.216; 15.80 9.313; 16.00 9.024], sobre_14Asb = [0.01 0.019; 0.10 0.193; 0.19 0.365; 0.28 0.537; 0.37 0.708; 0.46 0.879; 0.55 1.049; 0.64 1.218; 0.73 1.387; 0.82 1.555; 0.91 1.720; 1.00 1.877; 1.11 2.057; 1.23 2.240; 1.35 2.413; 1.47 2.578; 1.59 2.736; 1.71 2.888; 1.86 3.072; 2.01 3.249; 2.16 3.422; 2.31 3.591; 2.46 3.756; 2.61 3.918; 2.76 4.078; 2.91 4.235; 3.06 4.390; 3.21 4.543; 3.36 4.694; 3.53 4.863; 3.71 5.040; 3.89 5.215; 4.40 5.702; 5.00 6.276; 5.60 6.850; 6.20 7.418; 6.80 7.976; 7.40 8.520; 8.00 9.046; 8.60 9.552; 9.20 10.035; 9.80 10.489; 10.40 10.902; 11.00 11.227; 11.60 11.450; 12.20 11.544; 12.80 11.448; 13.40 11.094; 14.00 10.331; 14.60 9.270; 14.60 9.270], [0 60])

#: **Capacity against ductility.** x axis: steel area A_{s} [cm²]. y axis: steel strain ε_{s} at the instant the concrete reaches 0.003 [-]. The **points** are Hekatan OpenSees (a complete analysis for each A_{s}); the **curve** is the ACI formula ε_{t} = 0.003·(d − c)/c with c = A_{s}·f_{y}/(0.85·f'c·b·β_{1}), valid while the steel yields. Where the curve crosses ε_{y} = 0.0021 is the **balanced** point; to the left of the crossing with 0.005 the section is «tension-controlled» (φ = 0.90).
#fplot(OpenSees = [0.90 0.03394; 1.35 0.02158; 1.80 0.01553; 2.25 0.01191; 2.70 0.00942; 3.15 0.00757; 3.60 0.00630; 4.05 0.00526; 4.50 0.00443; 4.95 0.00377; 5.40 0.00326; 5.85 0.00279; 6.30 0.00239; 6.75 0.00212; 7.20 0.00203; 7.65 0.00194; 8.10 0.00187; 8.55 0.00179; 9.00 0.00173; 9.45 0.00167; 9.90 0.00162; 10.35 0.00157; 10.80 0.00152], ACI = 0.003·(d - x·f_y/(0.85·f_c·b·beta_1))/(x·f_y/(0.85·f_c·b·beta_1)), e_y = 0.0021 + 0·x, e_005 = 0.005 + 0·x, [1 10])

#: **Resisting moment.** x axis: A_{s} [cm²]. y axis: moment when the concrete reaches 0.003 [t·m]. Points: OpenSees. Curve: ACI assuming the steel yields, M_{n} = A_{s}·f_{y}·(d − a/2). At first they go together; past the balanced point, the ACI curve **overshoots** the real one because the steel no longer yields and the moment almost stops growing.
#fplot(OpenSees = [0.90 0.785; 1.35 1.156; 1.80 1.513; 2.25 1.856; 2.70 2.185; 3.15 2.501; 3.60 2.800; 4.05 3.089; 4.50 3.365; 4.95 3.622; 5.40 3.845; 5.85 4.060; 6.30 4.279; 6.75 4.403; 7.20 4.476; 7.65 4.549; 8.10 4.534; 8.55 4.618; 9.00 4.597; 9.45 4.692; 9.90 4.671; 10.35 4.770; 10.80 4.753], ACI_fluye = x·f_y·(d - x·f_y/(0.85·f_c·b)/2)/100000, [1 10])

## 7 · Summary: ACI against Hekatan OpenSees

t_As = [A_s1, A_s4] 'steel of the two beams [cm2]
t_Pn = [P_n1, P_n4] 'nominal load by the ACI [t]
t_Po = [P_u1_ops, P_u4_ops] 'Hekatan OpenSees load when the concrete reaches 0.003 [t]
t_Do = [D_u1_ops, D_u4_ops] 'Hekatan OpenSees deflection at that instant [mm]
#tabla("Case","As [cm2]:2","ACI: Pn [t]:3","OpenSees: P with εc = 0.003 [t]:3","OpenSees: Δ [mm]:1")({"Under-reinforced","Over-reinforced"}; t_As; t_Pn; t_Po; t_Do)

#: **Conclusion.** A finite element program is not needed to understand ductility: the Whitney block (1 to 2 % in the under-reinforced beam, 4 % in the over-reinforced one) already says **what fails first**. What OpenSees adds is the **complete curve** with the deflection, and from it the ductility μ_{Δ}: about 6 with little steel; with a lot of steel there is no yielding, and therefore no ductility. The 3D simulator (viga-ductilidad/index.html) uses the same material laws as OpenSees and paints its points on top; in the table of that page the loads agree within 2 %.
