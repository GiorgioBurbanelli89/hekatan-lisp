# Guerra isolated footing (ch. 5, ex. 1): bearing capacity, symbols, numbers and plots against Hekatan Geotechnic and GEO5
#numerico

#: **What is calculated.** The same as **Hekatan Geotechnic** analyzes (foundations module, validated against GEO5 2024 to 4 digits) on the footing of exercise 1 of chapter 5 of Guerra's book (*Earthquake-resistant foundations using SAFE*): the vertical at the bottom, the eccentricity, the effective area, the pressure, the **bearing capacity by Meyerhof, Standard (Brinch-Hansen) and Vesic**, the safety factor, the sliding and the oedometric settlement. Each formula is written once: the **symbols** derive it, the **numbers** evaluate it and the **plots** draw it.
#: **Important datum.** The book does NOT give φ, c or the foundation depth: only k_{s} = 2920 t/m³ and q_{adm} = 14 t/m². The soil of this sheet is **equivalent** (φ = 22.2°, c = 0, γ = 1.8 t/m³) and is chosen so that q_{adm} ≈ 14 t/m² with FS = 3. It is not a datum of the book.
#: **Judges.** (1) The Geotechnic program, zapata.ts, with the same data (the final table gives each difference). (2) GEO5 2024 Spread Footing run with this same model: FS = 3.12, 2.84 and 3.39. Units: t and m.

## 1 · Symbols: where the bearing capacity factors come from

#: **Nq** depends only on φ: N_{q} = e^{π·tanφ}·tan²(45° + φ/2), and since tan²(45° + φ/2) = (1 + sinφ)/(1 − sinφ) it is written with sine and cosine. **N_{c}** comes from N_{q}. Here φ is the letter *phi*, in radians:
Nq_s = Simplify{exp(pi*sin(fi)/cos(fi))*(1 + sin(fi))/(1 - sin(fi))}
Nc_s = Simplify{(exp(pi*sin(fi)/cos(fi))*(1 + sin(fi))/(1 - sin(fi)) - 1)*cos(fi)/sin(fi)}
#: **Rate of N_{q} with φ** (derivative): it explains why q_{adm} rises so fast with φ in the plot of section 6.
dNq_s = Diff{exp(pi*sin(fi)/cos(fi))*(1 + sin(fi))/(1 - sin(fi)) @ fi}
#: **Limit φ → 0** (cohesive soil, GEO5 undrained case): N_{c} → π + 2 = 5.1416.
Nc_0 = Limit{(exp(pi*sin(fi)/cos(fi))*(1 + sin(fi))/(1 - sin(fi)) - 1)*cos(fi)/sin(fi) @ fi = 0}
#: **N_{γ} of each method** (the three GEO5 variants): Meyerhof (N_{q} − 1)·tan(1.4φ), Standard 1.5·(N_{q} − 1)·tanφ and Vesic 2·(N_{q} + 1)·tanφ:
Ngm_s = Simplify{(exp(pi*sin(fi)/cos(fi))*(1 + sin(fi))/(1 - sin(fi)) - 1)*sin(1.4*fi)/cos(1.4*fi)}
Nge_s = Simplify{1.5*(exp(pi*sin(fi)/cos(fi))*(1 + sin(fi))/(1 - sin(fi)) - 1)*sin(fi)/cos(fi)}
Ngv_s = Simplify{2*(exp(pi*sin(fi)/cos(fi))*(1 + sin(fi))/(1 - sin(fi)) + 1)*sin(fi)/cos(fi)}
#: **The pressure of the rigid footing.** It starts from the plane σ(x) = P/(B·L) + 12·M·x/(L·B³) and the equilibrium is checked by integrating: the force must give P and the moment M.
F_eq = Simplify{Lz*Area{Pz/(Bz*Lz) + 12*Mz*x/(Lz*Bz^3) @ x = -Bz/2 : Bz/2}}
M_eq = Simplify{Lz*Area{(Pz/(Bz*Lz) + 12*Mz*x/(Lz*Bz^3))*x @ x = -Bz/2 : Bz/2}}
#: The ends of the plane are σ = P/(B·L) ± 6·M/(L·B²). The pressure vanishes at the edge when e = M/P reaches B/6 (the **central core**):
p_ext = Simplify{Pz/(Bz*Lz) + 6*Mz/(Lz*Bz^2)}
e_nuc = Despejar{Pz/(Bz*Lz) - 6*Pz*ez/(Lz*Bz^2) = 0 @ ez}

## 2 · Data and loads at the bottom of the footing

#: Guerra's data and the equivalent soil (declared). The formulas are those of zapata.ts (GEO5 «Stress in the Footing Bottom» and «Effective Area»).
B = 3.45 'side in x [m]
L = 3.45 'side in y [m]
h = 0.45 'footing depth (thickness) [m]
D_f = 1.5 'depth of the bottom from the finished grade [m]
c_x = 0.45 'column in x [m]
c_y = 0.45 'column in y [m]
gamma_c = 2.4028 'unit weight of the concrete [t/m3]
gamma_r = 1.8 'unit weight of the fill [t/m3]
gamma_s = 1.8 'unit weight of the equivalent soil [t/m3]
phi = 22.2 'equivalent friction angle [degrees]
N_c = 121 'axial load of the column [t]
M_y = 17 'moment My [t·m]
FS_n = 3 'required safety factor
k_s = 2920 'subgrade modulus of the book [t/m3]
G_z = B·L·h·gamma_c 'weight of the footing [t]
Z_r = gamma_r·(D_f - h)·(B·L - c_x·c_y) 'fill over the footing [t]
V_d = N_c + G_z + Z_r 'vertical at the bottom [t] (Geotechnic: 155.983)
e_x = -M_y/V_d 'eccentricity [m]
b_x = B - 2·abs(e_x) 'effective width in x [m]
b_ef = min(b_x, L) 'smaller side of the effective area [m]
l_ef = max(b_x, L) 'larger side [m]
A_ef = b_x·L 'effective area [m2]
sigma_c = V_d/A_ef 'pressure over the effective area [t/m2] (Geotechnic: 13.99)
q_0 = gamma_s·D_f 'surcharge at the bottom level [t/m2]
f_r = phi·pi/180 'φ in radians

## 3 · Bearing capacity by the three GEO5 methods

#: R_{d} = q₀·N_{q}·s_{q}·d_{q} + (b_{ef}/2)·γ·N_{γ}·s_{γ}·d_{γ}, with c = 0 and no horizontal load (the inclination factors are 1). The shape s and depth d factors are those of zapata.ts.
N_q = exp(pi·tan(f_r))·tan(pi/4 + f_r/2)^2 'factor Nq (Geotechnic: 7.982)
N_cc = (N_q - 1)/tan(f_r) 'factor Nc (17.108)
bl = b_ef/l_ef 'b_ef / l_ef
db = D_f/b_ef 'Df / b_ef
K_p = tan(pi/4 + f_r/2)^2
#: **Meyerhof:**
Ng_M = (N_q - 1)·tan(1.4·f_r) 'Nγ Meyerhof (4.208)
sq_M = 1 + 0.1·K_p·bl 's_q = s_γ (φ > 10°)
dq_M = 1 + 0.1·db·sqrt(K_p) 'd_q = d_γ
Rd_M = q_0·N_q·sq_M·dq_M + b_ef/2·gamma_s·Ng_M·sq_M·dq_M 'ultimate capacity Meyerhof [t/m2] (43.62)
#: **Standard (Brinch-Hansen):**
Ng_B = 1.5·(N_q - 1)·tan(f_r) 'Nγ Standard (4.274)
sq_B = 1 + bl·sin(f_r)
sg_B = 1 - 0.3·bl
dq_B = 1 + 0.1·sqrt(db·sin(2·f_r))
Rd_B = q_0·N_q·sq_B·dq_B + b_ef/2·gamma_s·Ng_B·sg_B 'ultimate capacity Standard [t/m2] (39.78)
#: **Vesic** (db ≤ 1, hence t = Df/b_ef):
Ng_V = 2·(N_q + 1)·tan(f_r) 'Nγ Vesic (7.331)
sq_V = 1 + bl·tan(f_r)
sg_V = 1 - 0.4·bl
dq_V = 1 + 2·tan(f_r)·(1 - sin(f_r))^2·db
Rd_V = q_0·N_q·sq_V·dq_V + b_ef/2·gamma_s·Ng_V·sg_V 'ultimate capacity Vesic [t/m2] (47.49)
#: **q_{adm} = R_{d}/required FS and FS = R_{d}/σ**, per method:
qa_M = Rd_M/FS_n 'q_adm Meyerhof [t/m2] (14.54)
qa_B = Rd_B/FS_n 'q_adm Standard [t/m2]
qa_V = Rd_V/FS_n 'q_adm Vesic [t/m2]
FS_M = Rd_M/sigma_c 'FS Meyerhof (GEO5: 3.12)
FS_B = Rd_B/sigma_c 'FS Standard (GEO5: 2.84)
FS_V = Rd_V/sigma_c 'FS Vesic (GEO5: 3.39)
#: **Sliding** (GEO5 «Horizontal Bearing Capacity»): R_{dh} = V·tanφ + c·A_{ef} + at-rest passive thrust, with K₀ = 1 − sinφ over the depth h:
K_0 = 1 - sin(f_r)
S_pd = K_0·gamma_s·(D_f^2 - (D_f - h)^2)/2·L 'at-rest thrust over the footing depth [t]
R_dh = V_d·tan(f_r) + S_pd 'sliding capacity [t] (Geotechnic: 65.872)

## 4 · Contact pressure of the rigid footing

#: Literature (Navier and central core; GEO5 checks with the effective area). The plane is p = a + b·x with a = V/(B·L) and b = V·e_{x}/(L·B³/12). Geotechnic divides the footing into 80 × 80 cells and sums by midpoint: Σx²·dA = (B³ − B·dx²)·L/12 with dx = B/80; with that sum its numbers are reproduced, and against exact Navier the difference is 0.0004 t/m².
a_P = V_d/(B·L) 'mean pressure [t/m2]
b_P = V_d·e_x/(L·B^3/12) 'exact slope [t/m2/m]
s_maxN = a_P + abs(b_P)·B/2 'maximum pressure, exact Navier [t/m2]
s_minN = a_P - abs(b_P)·B/2 'minimum pressure, exact Navier [t/m2]
dx_m = B/80 'Geotechnic cell [m]
b_G = V_d·e_x/(L·(B^3 - B·dx_m^2)/12) 'slope with the sum of 80 cells
s_max = a_P + abs(b_G)·B/2 'maximum pressure as Geotechnic [t/m2] (15.589)
s_min = a_P - abs(b_G)·B/2 'minimum pressure as Geotechnic [t/m2] (10.621)
sW_max = s_max/k_s·1000 'Winkler settlement σ/ks, maximum [mm]
giro_W = abs(b_G)/k_s·1000 'rotation of the rigid footing [‰]

## 5 · Settlement by the oedometric modulus

#: GEO5: s = Σ (Δσz − m·σor)·dz / E_{oed} with E_{oed} = E_{def}/β, β = 1 − 2ν²/(1 − ν), Δσz from Steinbrenner (sum of the four corners) at the fictitious depth z_r = κ₁·z, κ₁ = 1 + 0.35·atan(1.55·D_f/z). The relative stiffness k = E_{c}·h³/(E_{def}·B³) decides whether the footing is rigid (k > 1, characteristic point) or flexible (center):
E_def = 89.9 'deformation modulus [MPa]
nu_s = 0.3 'Poisson's ratio of the soil
m_s = 0.3 'structural strength coefficient
E_c = 23138 'concrete modulus [MPa]
k_rel = E_c·h^3/(E_def·B^3) 'relative stiffness (0.571 < 1: FLEXIBLE footing, the center is evaluated)
E_oed = E_def/(1 - 2·nu_s^2/(1 - nu_s))·1000/9.80665 'oedometric modulus [t/m2]
q_n = V_d/(B·L) - gamma_s·D_f 'mean net pressure [t/m2]
I_c(a, b, z) = (atan(a·b/(z·sqrt(a^2 + b^2 + z^2))) + a·b·z/sqrt(a^2 + b^2 + z^2)·(1/(a^2 + z^2) + 1/(b^2 + z^2)))/(2·pi)
kappa_1(z) = 1 + 0.35·atan(1.55·D_f/z)
dsig_z(z) = 4·q_n·I_c(B/2, L/2, kappa_1(z)·z)
m_sor(z) = m_s·gamma_s·(z + D_f)
#: **End of the influence zone**, where Δσz = m·σor (bisection, as GEO5):
#hide
a_b = 0.01
b_b = 30
for it = 1:60
  c_b = (a_b + b_b)/2
  if dsig_z(c_b) - m_sor(c_b) > 0
    a_b = c_b
  else
    b_b = c_b
  end
end
z_inf = (a_b + b_b)/2
#show
z_inf = round(z_inf, 4) 'influence depth [m]
s_edo = integral(@(z) (dsig_z(z) - m_sor(z))/E_oed*1000, 0.0000001, z_inf) 'oedometric settlement [mm] (GEO5: 1.26)
#: The GEO5 angular distortion (β = Δs/side with the settlement at the four edges) is **not** reproduced in this sheet; above is only the Winkler rotation, which is from the literature.

## 6 · Plots

#: **Map of the contact pressure in plan** [t/m²], with x and y measured from the center of the footing. The pressure is maximum on the x < 0 side, toward which the resultant falls (e_{x} = −0.109 m, inside the core B/6 = 0.575 m), and minimum at x > 0. The value is read with the cursor:
p_xy(x, y) = max(0, a_P + b_P·x)
#map(p_xy(x, y), [-1.725 1.725], [-1.725 1.725])
#: **q_{adm} against φ for the three methods.** The same formulas of section 3 as functions of φ in degrees, with the same footing, load and eccentricity. The purple line is the book q_{adm} = 14 t/m²: it cuts it near the equivalent φ of 22.2°.
Nq_D(p) = exp(pi·tan(p·pi/180))·tan(pi/4 + p·pi/360)^2
Kp_D(p) = tan(pi/4 + p·pi/360)^2
qa_Mf(p) = (q_0·Nq_D(p)·(1 + 0.1·Kp_D(p)·bl)·(1 + 0.1·db·sqrt(Kp_D(p))) + b_ef/2·gamma_s·(Nq_D(p) - 1)·tan(1.4·p·pi/180)·(1 + 0.1·Kp_D(p)·bl)·(1 + 0.1·db·sqrt(Kp_D(p))))/FS_n
qa_Bf(p) = (q_0·Nq_D(p)·(1 + bl·sin(p·pi/180))·(1 + 0.1·sqrt(db·sin(2·p·pi/180))) + b_ef/2·gamma_s·1.5·(Nq_D(p) - 1)·tan(p·pi/180)·(1 - 0.3·bl))/FS_n
qa_Vf(p) = (q_0·Nq_D(p)·(1 + bl·tan(p·pi/180))·(1 + 2·tan(p·pi/180)·(1 - sin(p·pi/180))^2·db) + b_ef/2·gamma_s·2·(Nq_D(p) + 1)·tan(p·pi/180)·(1 - 0.4·bl))/FS_n
#fplot(Meyerhof = (q_0*exp(pi*tan(x*pi/180))*tan(pi/4 + x*pi/360)^2*(1 + 0.1*tan(pi/4 + x*pi/360)^2*bl)*(1 + 0.1*db*sqrt(tan(pi/4 + x*pi/360)^2)) + b_ef/2*gamma_s*(exp(pi*tan(x*pi/180))*tan(pi/4 + x*pi/360)^2 - 1)*tan(1.4*x*pi/180)*(1 + 0.1*tan(pi/4 + x*pi/360)^2*bl)*(1 + 0.1*db*sqrt(tan(pi/4 + x*pi/360)^2)))/FS_n, Estandar = (q_0*exp(pi*tan(x*pi/180))*tan(pi/4 + x*pi/360)^2*(1 + bl*sin(x*pi/180))*(1 + 0.1*sqrt(db*sin(2*x*pi/180))) + b_ef/2*gamma_s*1.5*(exp(pi*tan(x*pi/180))*tan(pi/4 + x*pi/360)^2 - 1)*tan(x*pi/180)*(1 - 0.3*bl))/FS_n, Vesic = (q_0*exp(pi*tan(x*pi/180))*tan(pi/4 + x*pi/360)^2*(1 + bl*tan(x*pi/180))*(1 + 2*tan(x*pi/180)*(1 - sin(x*pi/180))^2*db) + b_ef/2*gamma_s*2*(exp(pi*tan(x*pi/180))*tan(pi/4 + x*pi/360)^2 + 1)*tan(x*pi/180)*(1 - 0.4*bl))/FS_n, limite = 14, [12 32])
#: Check at the equivalent φ (22.2°), which must give q_{adm} = 14.54, 13.26 and 15.83 t/m² as Geotechnic:
qc_M = qa_Mf(phi) 'q_adm Meyerhof at 22.2 degrees [t/m2]
qc_B = qa_Bf(phi) 'q_adm Standard [t/m2]
qc_V = qa_Vf(phi) 'q_adm Vesic [t/m2]

## 7 · Hekatan against Geotechnic (zapata.ts) and GEO5

#hide
t_V = 155.98269715
t_sig = 13.988860399559158
t_Nq = 7.981585611024295
t_Nc = 17.107853302469824
t_NgM = 4.208238535641821
t_NgB = 4.273698468967871
t_NgV = 7.330634388483725
t_RdM = 43.619992723241744
t_RdB = 39.77873960376557
t_RdV = 47.48998812862784
t_Rdh = 65.87210510182234
t_smax = 15.589374906821973
t_smin = 10.620698128255945
t_s = 1.2555695554582322
t_qM = 14.539997574413915
t_qB = 13.259579867921857
t_qV = 15.829996042875948
h_V = round(V_d, 4)
h_sig = round(sigma_c, 4)
h_Nq = round(N_q, 4)
h_Nc = round(N_cc, 4)
h_NgM = round(Ng_M, 4)
h_NgB = round(Ng_B, 4)
h_NgV = round(Ng_V, 4)
h_RdM = round(Rd_M, 4)
h_RdB = round(Rd_B, 4)
h_RdV = round(Rd_V, 4)
h_Rdh = round(R_dh, 4)
h_smax = round(s_max, 4)
h_smin = round(s_min, 4)
h_s = round(s_edo, 4)
h_qM = round(qc_M, 4)
h_qB = round(qc_B, 4)
h_qV = round(qc_V, 4)
r_V = round(t_V, 4)
r_sig = round(t_sig, 4)
r_Nq = round(t_Nq, 4)
r_Nc = round(t_Nc, 4)
r_NgM = round(t_NgM, 4)
r_NgB = round(t_NgB, 4)
r_NgV = round(t_NgV, 4)
r_RdM = round(t_RdM, 4)
r_RdB = round(t_RdB, 4)
r_RdV = round(t_RdV, 4)
r_Rdh = round(t_Rdh, 4)
r_smax = round(t_smax, 4)
r_smin = round(t_smin, 4)
r_s = round(t_s, 4)
r_qM = round(t_qM, 4)
r_qB = round(t_qB, 4)
r_qV = round(t_qV, 4)
d_V = round(h_V - r_V, 4)
d_sig = round(h_sig - r_sig, 4)
d_Nq = round(h_Nq - r_Nq, 4)
d_Nc = round(h_Nc - r_Nc, 4)
d_NgM = round(h_NgM - r_NgM, 4)
d_NgB = round(h_NgB - r_NgB, 4)
d_NgV = round(h_NgV - r_NgV, 4)
d_RdM = round(h_RdM - r_RdM, 4)
d_RdB = round(h_RdB - r_RdB, 4)
d_RdV = round(h_RdV - r_RdV, 4)
d_Rdh = round(h_Rdh - r_Rdh, 4)
d_smax = round(h_smax - r_smax, 4)
d_smin = round(h_smin - r_smin, 4)
d_s = round(h_s - r_s, 4)
d_qM = round(h_qM - r_qM, 4)
d_qB = round(h_qB - r_qB, 4)
d_qV = round(h_qV - r_qV, 4)
g_FSM = 3.12
g_FSB = 2.84
g_FSV = 3.39
h_FSM = round(FS_M, 2)
h_FSB = round(FS_B, 2)
h_FSV = round(FS_V, 2)
#show
#: Each difference is the Hekatan value minus that of zapata.ts, rounded to 4 decimals; it must be 0.
#| Magnitud | Hekatan | Geotechnic | Diferencia |
#|---|---:|---:|---:|
#| V en el fondo [t] | @{h_V} | @{r_V} | @{d_V} |
#| σ sobre el área efectiva [t/m²] | @{h_sig} | @{r_sig} | @{d_sig} |
#| N_{q} | @{h_Nq} | @{r_Nq} | @{d_Nq} |
#| N_{c} | @{h_Nc} | @{r_Nc} | @{d_Nc} |
#| N_{γ} Meyerhof | @{h_NgM} | @{r_NgM} | @{d_NgM} |
#| N_{γ} Estándar | @{h_NgB} | @{r_NgB} | @{d_NgB} |
#| N_{γ} Vesic | @{h_NgV} | @{r_NgV} | @{d_NgV} |
#| **R_{d} Meyerhof [t/m²]** | @{h_RdM} | @{r_RdM} | @{d_RdM} |
#| **R_{d} Estándar [t/m²]** | @{h_RdB} | @{r_RdB} | @{d_RdB} |
#| **R_{d} Vesic [t/m²]** | @{h_RdV} | @{r_RdV} | @{d_RdV} |
#| R_{dh} deslizamiento [t] | @{h_Rdh} | @{r_Rdh} | @{d_Rdh} |
#| σ_{max} de contacto [t/m²] | @{h_smax} | @{r_smax} | @{d_smax} |
#| σ_{min} de contacto [t/m²] | @{h_smin} | @{r_smin} | @{d_smin} |
#| asiento edométrico [mm] | @{h_s} | @{r_s} | @{d_s} |
#| q_{adm} Meyerhof a 22.2° | @{h_qM} | @{r_qM} | @{d_qM} |
#| q_{adm} Estándar a 22.2° | @{h_qB} | @{r_qB} | @{d_qB} |
#| q_{adm} Vesic a 22.2° | @{h_qV} | @{r_qV} | @{d_qV} |
#: And the safety factor against **GEO5 2024** (run on this model; GEO5 prints 2 decimals):
#| Método | Hekatan | GEO5 2024 |
#|---|---:|---:|
#| FS Meyerhof | @{h_FSM} | @{g_FSM} |
#| FS Estándar | @{h_FSB} | @{g_FSB} |
#| FS Vesic | @{h_FSV} | @{g_FSV} |
#: **Reading.** With e_{x} = −0.109 m (inside the core) the whole base works in compression: σ_{max}/σ_{min} = 15.59/10.62 t/m²; GEO5 checks with the mean pressure over the effective area, σ = 13.99 t/m². Meyerhof and Vesic meet FS ≥ 3; Standard stays at 2.84. The settlement (1.26 mm) is small: the bearing capacity governs.
#: **What this sheet does NOT reproduce:** the GEO5 angular distortion and the Prandtl homogenization for layered soil or with water (not extracted from the binary).
