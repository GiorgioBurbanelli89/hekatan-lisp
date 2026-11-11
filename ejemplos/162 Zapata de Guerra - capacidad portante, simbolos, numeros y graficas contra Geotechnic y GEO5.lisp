# Zapata aislada de Guerra (cap. 5, ej. 1): capacidad portante, símbolos, números y gráficas contra Hekatan Geotechnic y GEO5
#numerico

#: **Qué se calcula.** Lo mismo que analiza **Hekatan Geotechnic** (módulo de cimentaciones, validado contra GEO5 2024 a 4 cifras) en la zapata del ejercicio 1 del capítulo 5 del libro de Guerra (*Cimentaciones sismo resistentes utilizando SAFE*): el vertical en el fondo, la excentricidad, el área efectiva, la presión, la **capacidad portante por Meyerhof, Estándar (Brinch-Hansen) y Vesic**, el factor de seguridad, el deslizamiento y el asiento edométrico. Cada fórmula se escribe una vez: los **símbolos** la deducen, los **números** la evalúan y las **gráficas** la dibujan.
#: **Dato importante.** El libro NO da φ, c ni la profundidad de desplante: solo k_{s} = 2920 t/m³ y q_{adm} = 14 t/m². El suelo de esta hoja es **equivalente** (φ = 22.2°, c = 0, γ = 1.8 t/m³) y se elige para que q_{adm} ≈ 14 t/m² con FS = 3. No es un dato del libro.
#: **Jueces.** (1) El programa de Geotechnic, zapata.ts, con los mismos datos (la tabla final da cada diferencia). (2) GEO5 2024 Spread Footing corrido con este mismo modelo: FS = 3.12, 2.84 y 3.39. Unidades: t y m.

## 1 · Símbolos: de dónde salen los factores de capacidad portante

#: **Nq** depende solo de φ: N_{q} = e^{π·tanφ}·tan²(45° + φ/2), y como tan²(45° + φ/2) = (1 + senφ)/(1 − senφ) se escribe con seno y coseno. **N_{c}** sale de N_{q}. Aquí φ es la letra *fi*, en radianes:
Nq_s = Simplify{exp(pi*sin(fi)/cos(fi))*(1 + sin(fi))/(1 - sin(fi))}
Nc_s = Simplify{(exp(pi*sin(fi)/cos(fi))*(1 + sin(fi))/(1 - sin(fi)) - 1)*cos(fi)/sin(fi)}
#: **Rapidez de N_{q} con φ** (derivada): explica por qué q_{adm} sube tan de prisa con φ en la gráfica de la sección 6.
dNq_s = Diff{exp(pi*sin(fi)/cos(fi))*(1 + sin(fi))/(1 - sin(fi)) @ fi}
#: **Límite φ → 0** (suelo cohesivo, caso no drenado de GEO5): N_{c} → π + 2 = 5.1416.
Nc_0 = Limit{(exp(pi*sin(fi)/cos(fi))*(1 + sin(fi))/(1 - sin(fi)) - 1)*cos(fi)/sin(fi) @ fi = 0}
#: **N_{γ} de cada método** (las tres variantes de GEO5): Meyerhof (N_{q} − 1)·tan(1.4φ), Estándar 1.5·(N_{q} − 1)·tanφ y Vesic 2·(N_{q} + 1)·tanφ:
Ngm_s = Simplify{(exp(pi*sin(fi)/cos(fi))*(1 + sin(fi))/(1 - sin(fi)) - 1)*sin(1.4*fi)/cos(1.4*fi)}
Nge_s = Simplify{1.5*(exp(pi*sin(fi)/cos(fi))*(1 + sin(fi))/(1 - sin(fi)) - 1)*sin(fi)/cos(fi)}
Ngv_s = Simplify{2*(exp(pi*sin(fi)/cos(fi))*(1 + sin(fi))/(1 - sin(fi)) + 1)*sin(fi)/cos(fi)}
#: **La presión de la zapata rígida.** Se parte del plano σ(x) = P/(B·L) + 12·M·x/(L·B³) y se comprueba el equilibrio integrando: la fuerza debe dar P y el momento M.
F_eq = Simplify{Lz*Area{Pz/(Bz*Lz) + 12*Mz*x/(Lz*Bz^3) @ x = -Bz/2 : Bz/2}}
M_eq = Simplify{Lz*Area{(Pz/(Bz*Lz) + 12*Mz*x/(Lz*Bz^3))*x @ x = -Bz/2 : Bz/2}}
#: Los extremos del plano son σ = P/(B·L) ± 6·M/(L·B²). La presión se anula en el borde cuando e = M/P llega a B/6 (el **núcleo central**):
p_ext = Simplify{Pz/(Bz*Lz) + 6*Mz/(Lz*Bz^2)}
e_nuc = Despejar{Pz/(Bz*Lz) - 6*Pz*ez/(Lz*Bz^2) = 0 @ ez}

## 2 · Datos y cargas en el fondo de la zapata

#: Datos de Guerra y el suelo equivalente (declarado). Las fórmulas son las de zapata.ts (GEO5 «Stress in the Footing Bottom» y «Effective Area»).
B = 3.45 'lado en x [m]
L = 3.45 'lado en y [m]
h = 0.45 'canto de la zapata [m]
D_f = 1.5 'profundidad del fondo desde la rasante [m]
c_x = 0.45 'columna en x [m]
c_y = 0.45 'columna en y [m]
gamma_c = 2.4028 'peso específico del hormigón [t/m3]
gamma_r = 1.8 'peso específico del relleno [t/m3]
gamma_s = 1.8 'peso específico del suelo equivalente [t/m3]
phi = 22.2 'ángulo de fricción equivalente [grados]
N_c = 121 'axial de la columna [t]
M_y = 17 'momento My [t·m]
FS_n = 3 'factor de seguridad exigido
k_s = 2920 'módulo de balasto del libro [t/m3]
G_z = B·L·h·gamma_c 'peso de la zapata [t]
Z_r = gamma_r·(D_f - h)·(B·L - c_x·c_y) 'relleno sobre la zapata [t]
V_d = N_c + G_z + Z_r 'vertical en el fondo [t] (Geotechnic: 155.983)
e_x = -M_y/V_d 'excentricidad [m]
b_x = B - 2·abs(e_x) 'ancho efectivo en x [m]
b_ef = min(b_x, L) 'lado menor del área efectiva [m]
l_ef = max(b_x, L) 'lado mayor [m]
A_ef = b_x·L 'área efectiva [m2]
sigma_c = V_d/A_ef 'presión sobre el área efectiva [t/m2] (Geotechnic: 13.99)
q_0 = gamma_s·D_f 'sobrecarga a la cota del fondo [t/m2]
f_r = phi·pi/180 'φ en radianes

## 3 · Capacidad portante por los tres métodos de GEO5

#: R_{d} = q₀·N_{q}·s_{q}·d_{q} + (b_{ef}/2)·γ·N_{γ}·s_{γ}·d_{γ}, con c = 0 y sin carga horizontal (los factores de inclinación valen 1). Los factores de forma s y de profundidad d son los de zapata.ts.
N_q = exp(pi·tan(f_r))·tan(pi/4 + f_r/2)^2 'factor Nq (Geotechnic: 7.982)
N_cc = (N_q - 1)/tan(f_r) 'factor Nc (17.108)
bl = b_ef/l_ef 'b_ef / l_ef
db = D_f/b_ef 'Df / b_ef
K_p = tan(pi/4 + f_r/2)^2
#: **Meyerhof:**
Ng_M = (N_q - 1)·tan(1.4·f_r) 'Nγ Meyerhof (4.208)
sq_M = 1 + 0.1·K_p·bl 's_q = s_γ (φ > 10°)
dq_M = 1 + 0.1·db·sqrt(K_p) 'd_q = d_γ
Rd_M = q_0·N_q·sq_M·dq_M + b_ef/2·gamma_s·Ng_M·sq_M·dq_M 'capacidad última Meyerhof [t/m2] (43.62)
#: **Estándar (Brinch-Hansen):**
Ng_B = 1.5·(N_q - 1)·tan(f_r) 'Nγ Estándar (4.274)
sq_B = 1 + bl·sin(f_r)
sg_B = 1 - 0.3·bl
dq_B = 1 + 0.1·sqrt(db·sin(2·f_r))
Rd_B = q_0·N_q·sq_B·dq_B + b_ef/2·gamma_s·Ng_B·sg_B 'capacidad última Estándar [t/m2] (39.78)
#: **Vesic** (db ≤ 1, por eso t = Df/b_ef):
Ng_V = 2·(N_q + 1)·tan(f_r) 'Nγ Vesic (7.331)
sq_V = 1 + bl·tan(f_r)
sg_V = 1 - 0.4·bl
dq_V = 1 + 2·tan(f_r)·(1 - sin(f_r))^2·db
Rd_V = q_0·N_q·sq_V·dq_V + b_ef/2·gamma_s·Ng_V·sg_V 'capacidad última Vesic [t/m2] (47.49)
#: **q_{adm} = R_{d}/FS exigido y FS = R_{d}/σ**, por método:
qa_M = Rd_M/FS_n 'q_adm Meyerhof [t/m2] (14.54)
qa_B = Rd_B/FS_n 'q_adm Estándar [t/m2]
qa_V = Rd_V/FS_n 'q_adm Vesic [t/m2]
FS_M = Rd_M/sigma_c 'FS Meyerhof (GEO5: 3.12)
FS_B = Rd_B/sigma_c 'FS Estándar (GEO5: 2.84)
FS_V = Rd_V/sigma_c 'FS Vesic (GEO5: 3.39)
#: **Deslizamiento** (GEO5 «Horizontal Bearing Capacity»): R_{dh} = V·tanφ + c·A_{ef} + empuje pasivo en reposo, con K₀ = 1 − senφ sobre el canto h:
K_0 = 1 - sin(f_r)
S_pd = K_0·gamma_s·(D_f^2 - (D_f - h)^2)/2·L 'empuje en reposo sobre el canto [t]
R_dh = V_d·tan(f_r) + S_pd 'capacidad al deslizamiento [t] (Geotechnic: 65.872)

## 4 · Presión de contacto de la zapata rígida

#: Literatura (Navier y núcleo central; GEO5 verifica con el área efectiva). El plano es p = a + b·x con a = V/(B·L) y b = V·e_{x}/(L·B³/12). Geotechnic reparte la zapata en 80 × 80 celdas y suma por punto medio: Σx²·dA = (B³ − B·dx²)·L/12 con dx = B/80; con esa suma se reproducen sus números, y frente a Navier exacto la diferencia es 0.0004 t/m².
a_P = V_d/(B·L) 'presión media [t/m2]
b_P = V_d·e_x/(L·B^3/12) 'pendiente exacta [t/m2/m]
s_maxN = a_P + abs(b_P)·B/2 'presión máxima, Navier exacto [t/m2]
s_minN = a_P - abs(b_P)·B/2 'presión mínima, Navier exacto [t/m2]
dx_m = B/80 'celda de Geotechnic [m]
b_G = V_d·e_x/(L·(B^3 - B·dx_m^2)/12) 'pendiente con la suma de 80 celdas
s_max = a_P + abs(b_G)·B/2 'presión máxima como Geotechnic [t/m2] (15.589)
s_min = a_P - abs(b_G)·B/2 'presión mínima como Geotechnic [t/m2] (10.621)
sW_max = s_max/k_s·1000 'asiento de Winkler σ/ks, máximo [mm]
giro_W = abs(b_G)/k_s·1000 'giro de la zapata rígida [‰]

## 5 · Asiento por el módulo edométrico

#: GEO5: s = Σ (Δσz − m·σor)·dz / E_{oed} con E_{oed} = E_{def}/β, β = 1 − 2ν²/(1 − ν), Δσz de Steinbrenner (suma de las cuatro esquinas) a la profundidad ficticia z_r = κ₁·z, κ₁ = 1 + 0.35·atan(1.55·D_f/z). La rigidez relativa k = E_{c}·h³/(E_{def}·B³) decide si la zapata es rígida (k > 1, punto característico) o flexible (centro):
E_def = 89.9 'módulo de deformación [MPa]
nu_s = 0.3 'Poisson del suelo
m_s = 0.3 'coeficiente de resistencia estructural
E_c = 23138 'módulo del hormigón [MPa]
k_rel = E_c·h^3/(E_def·B^3) 'rigidez relativa (0.571 < 1: zapata FLEXIBLE, se evalúa el centro)
E_oed = E_def/(1 - 2·nu_s^2/(1 - nu_s))·1000/9.80665 'módulo edométrico [t/m2]
q_n = V_d/(B·L) - gamma_s·D_f 'presión neta media [t/m2]
I_c(a, b, z) = (atan(a·b/(z·sqrt(a^2 + b^2 + z^2))) + a·b·z/sqrt(a^2 + b^2 + z^2)·(1/(a^2 + z^2) + 1/(b^2 + z^2)))/(2·pi)
kappa_1(z) = 1 + 0.35·atan(1.55·D_f/z)
dsig_z(z) = 4·q_n·I_c(B/2, L/2, kappa_1(z)·z)
m_sor(z) = m_s·gamma_s·(z + D_f)
#: **Fin de la zona de influencia**, donde Δσz = m·σor (bisección, como GEO5):
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
z_inf = round(z_inf, 4) 'profundidad de influencia [m]
s_edo = integral(@(z) (dsig_z(z) - m_sor(z))/E_oed*1000, 0.0000001, z_inf) 'asiento edométrico [mm] (GEO5: 1.26)
#: La distorsión angular de GEO5 (β = Δs/lado con el asiento en los cuatro bordes) **no** se reproduce en esta hoja; arriba va solo el giro de Winkler, que es de la literatura.

## 6 · Gráficas

#: **Mapa de la presión de contacto en planta** [t/m²], con x e y medidos desde el centro de la zapata. La presión es máxima del lado x < 0, hacia donde cae la resultante (e_{x} = −0.109 m, dentro del núcleo B/6 = 0.575 m), y mínima en x > 0. Con el cursor se lee el valor:
p_xy(x, y) = max(0, a_P + b_P·x)
#map(p_xy(x, y), [-1.725 1.725], [-1.725 1.725])
#: **q_{adm} contra φ para los tres métodos.** Las mismas fórmulas de la sección 3 como funciones de φ en grados, con la misma zapata, carga y excentricidad. La recta morada es el q_{adm} = 14 t/m² del libro: la corta cerca del φ equivalente de 22.2°.
Nq_D(p) = exp(pi·tan(p·pi/180))·tan(pi/4 + p·pi/360)^2
Kp_D(p) = tan(pi/4 + p·pi/360)^2
qa_Mf(p) = (q_0·Nq_D(p)·(1 + 0.1·Kp_D(p)·bl)·(1 + 0.1·db·sqrt(Kp_D(p))) + b_ef/2·gamma_s·(Nq_D(p) - 1)·tan(1.4·p·pi/180)·(1 + 0.1·Kp_D(p)·bl)·(1 + 0.1·db·sqrt(Kp_D(p))))/FS_n
qa_Bf(p) = (q_0·Nq_D(p)·(1 + bl·sin(p·pi/180))·(1 + 0.1·sqrt(db·sin(2·p·pi/180))) + b_ef/2·gamma_s·1.5·(Nq_D(p) - 1)·tan(p·pi/180)·(1 - 0.3·bl))/FS_n
qa_Vf(p) = (q_0·Nq_D(p)·(1 + bl·tan(p·pi/180))·(1 + 2·tan(p·pi/180)·(1 - sin(p·pi/180))^2·db) + b_ef/2·gamma_s·2·(Nq_D(p) + 1)·tan(p·pi/180)·(1 - 0.4·bl))/FS_n
#fplot(Meyerhof = (q_0*exp(pi*tan(x*pi/180))*tan(pi/4 + x*pi/360)^2*(1 + 0.1*tan(pi/4 + x*pi/360)^2*bl)*(1 + 0.1*db*sqrt(tan(pi/4 + x*pi/360)^2)) + b_ef/2*gamma_s*(exp(pi*tan(x*pi/180))*tan(pi/4 + x*pi/360)^2 - 1)*tan(1.4*x*pi/180)*(1 + 0.1*tan(pi/4 + x*pi/360)^2*bl)*(1 + 0.1*db*sqrt(tan(pi/4 + x*pi/360)^2)))/FS_n, Estandar = (q_0*exp(pi*tan(x*pi/180))*tan(pi/4 + x*pi/360)^2*(1 + bl*sin(x*pi/180))*(1 + 0.1*sqrt(db*sin(2*x*pi/180))) + b_ef/2*gamma_s*1.5*(exp(pi*tan(x*pi/180))*tan(pi/4 + x*pi/360)^2 - 1)*tan(x*pi/180)*(1 - 0.3*bl))/FS_n, Vesic = (q_0*exp(pi*tan(x*pi/180))*tan(pi/4 + x*pi/360)^2*(1 + bl*tan(x*pi/180))*(1 + 2*tan(x*pi/180)*(1 - sin(x*pi/180))^2*db) + b_ef/2*gamma_s*2*(exp(pi*tan(x*pi/180))*tan(pi/4 + x*pi/360)^2 + 1)*tan(x*pi/180)*(1 - 0.4*bl))/FS_n, limite = 14, [12 32])
#: Control en el φ equivalente (22.2°), que debe dar q_{adm} = 14.54, 13.26 y 15.83 t/m² como Geotechnic:
qc_M = qa_Mf(phi) 'q_adm Meyerhof a 22.2 grados [t/m2]
qc_B = qa_Bf(phi) 'q_adm Estándar [t/m2]
qc_V = qa_Vf(phi) 'q_adm Vesic [t/m2]

## 7 · Hekatan contra Geotechnic (zapata.ts) y GEO5

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
#: Cada diferencia es el valor de Hekatan menos el de zapata.ts, redondeados a 4 decimales; debe ser 0.
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
#: Y el factor de seguridad contra **GEO5 2024** (corrido sobre este modelo; GEO5 imprime 2 decimales):
#| Método | Hekatan | GEO5 2024 |
#|---|---:|---:|
#| FS Meyerhof | @{h_FSM} | @{g_FSM} |
#| FS Estándar | @{h_FSB} | @{g_FSB} |
#| FS Vesic | @{h_FSV} | @{g_FSV} |
#: **Lectura.** Con e_{x} = −0.109 m (dentro del núcleo) toda la base trabaja a compresión: σ_{max}/σ_{min} = 15.59/10.62 t/m²; GEO5 verifica con la presión media sobre el área efectiva, σ = 13.99 t/m². Meyerhof y Vesic cumplen FS ≥ 3; el Estándar queda en 2.84. El asiento (1.26 mm) es pequeño: manda la capacidad portante.
#: **Lo que NO reproduce esta hoja:** la distorsión angular de GEO5 y la homogeneización de Prandtl para suelo estratificado o con agua (no extraída del binario).
