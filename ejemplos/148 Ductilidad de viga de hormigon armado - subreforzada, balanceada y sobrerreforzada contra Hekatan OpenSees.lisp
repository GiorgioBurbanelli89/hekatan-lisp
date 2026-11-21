# Ductilidad de una viga de hormigón armado: subreforzada, balanceada y sobrerreforzada (ACI 318 contra Hekatan OpenSees)
#numerico

#: **Qué hace esta hoja.** Reproduce el «laboratorio de ductilidad» de una viga a flexión: la misma viga con **poco, justo o mucho acero**, y qué falla primero, el acero o el hormigón. Se resuelve de **tres formas independientes** que se comparan:
#: **1)** A mano, con el **bloque de Whitney** del ACI 318 (esta hoja).
#: **2)** Con una **sección por fibras** en el navegador (el simulador 3D viga-ductilidad/index.html).
#: **3)** Con **Hekatan OpenSees** (la DLL de Hekatan): 48 elementos dispBeamColumn, hormigón Concrete02 y acero Steel01, empujando la viga con **control de desplazamiento** hasta que el hormigón se aplasta.
#: **Unidades.** kgf, cm y kgf/cm², como en Ecuador; cargas en tonf (1 t = 1000 kgf).

## 1 · La viga y el ensayo

#: Viga simplemente apoyada de luz L, cargada en **dos puntos** a L/3 y 2L/3 (ensayo de flexión en 4 puntos). Entre las dos cargas el momento es **constante** y no hay cortante: ahí se ve la flexión «pura».
b = 15 'base de la viga [cm]
h = 25 'peralte total [cm]
r_e = 3.5 'recubrimiento hasta el centro del acero [cm]
L_v = 250 'luz entre apoyos [cm]
f_c = 210 'resistencia a compresión del hormigón [kgf/cm2]
f_y = 4200 'esfuerzo de fluencia del acero [kgf/cm2]
E_s = 2000000 'módulo de elasticidad del acero [kgf/cm2]
d = h - r_e 'peralte efectivo: de la fibra de arriba al centro del acero [cm]

#dibujo("Ensayo de flexión en 4 puntos: P/2 en cada tercio; entre las cargas el momento es constante", ud = cm, escala = auto, cotas = cm, alto = 70)
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

#: **Del momento a la carga.** Cada apoyo recibe P/2; en el tercio el momento vale (P/2)·(L/3) = P·L/6. Por eso, para pasar de un momento M a la carga total del gato: **P = 6·M/L**.

## 2 · Fisuración: cuándo aparece la primera grieta

#: Mientras la fibra de abajo no pasa la resistencia a tracción del hormigón (el **módulo de rotura** f_{r} = 2·√f'c en kgf/cm²), la sección trabaja **entera**, como un rectángulo elástico. El momento que la fisura sale de Navier con la inercia bruta:
f_r = 2·sqrt(f_c) 'módulo de rotura [kgf/cm2]
I_g = b·h^3/12 'inercia bruta del rectángulo [cm4]
M_cr = f_r·I_g/(h/2) 'momento de fisuración [kgf·cm]
P_cr = 6·M_cr/L_v/1000 'carga total que fisura la viga [t]
P_cr_ops = 1.168 'Hekatan OpenSees: carga cuando la fibra de abajo llega a f_r/E_c, con As = 1.40 [t]
#: **Lectura.** OpenSees fisura algo **después**: su sección por fibras **incluye el acero**, que agrega inercia y baja el centro de gravedad. Eso es la **sección transformada**: el acero vale n = E_{s}/E_{c} veces su área en hormigón. Con E_{c} = 2·f'c/ε_{0} (la pendiente inicial de Concrete02, ε_{0} = 0.002):
E_c = 2·f_c/0.002 'módulo inicial del hormigón de Concrete02 [kgf/cm2]
n_m = E_s/E_c 'relación modular [-]
A_s9 = 9.59 'acero de la viga sobrerreforzada (sección 5) [cm2]
A_tr = b·h + (n_m - 1)·A_s9 'área transformada [cm2]
y_g = -(n_m - 1)·A_s9·(h/2 - r_e)/A_tr 'baja del centro de gravedad, desde la mitad [cm]
I_tr = I_g + b·h·y_g^2 + (n_m - 1)·A_s9·(h/2 - r_e + y_g)^2 'inercia transformada [cm4]
M_cr9 = f_r·I_tr/(h/2 + y_g) 'momento de fisuración con el acero [kgf·cm]
P_cr9 = 6·M_cr9/L_v/1000 'carga de fisuración con el acero [t]
P_cr9_ops = 1.610 'Hekatan OpenSees con As = 9.59 [t]
#: Con la sección transformada la fórmula y OpenSees coinciden (1.59 contra 1.61 t). Con poco acero la diferencia es pequeña (1.09 bruta contra 1.17 t): ahí la sección bruta basta.

## 3 · Las tres cantidades de acero que fija el ACI

#: **Bloque de Whitney.** El ACI reemplaza la compresión curva del hormigón por un rectángulo de altura 0.85·f'c y profundidad a = β_{1}·c. Para f'c ≤ 280 kgf/cm², β_{1} = 0.85.
beta_1 = 0.85 'factor del bloque de Whitney, válido hasta 280 kgf/cm2 [-]
#: **Falla balanceada:** el hormigón llega a ε_{cu} = 0.003 **en el mismo instante** en que el acero llega a ε_{y} = f_{y}/E_{s}. Por triángulos semejantes, c_{b}/d = 0.003/(0.003 + ε_{y}) = 6000/(6000 + f_{y}); con C = T sale la cuantía balanceada:
rho_b = 0.85·beta_1·f_c/f_y·6000/(6000 + f_y) 'cuantía balanceada [-]
A_sb = rho_b·b·d 'acero balanceado [cm2]
A_smax = 0.75·A_sb 'acero máximo de la norma antigua (0.75·Asb) [cm2]
#: **Acero mínimo** (ACI 318, 9.6.1.2): el mayor de 0.8·√f'c/f_{y}·b·d y 14/f_{y}·b·d. Existe para que, al fisurar, el acero **pueda** recibir la tracción que soltó el hormigón sin romperse de golpe.
A_smin = max(0.8·sqrt(f_c)/f_y, 14/f_y)·b·d 'acero mínimo [cm2]
#: **Lectura.** Con b = 15 cm y d = 21.5 cm, el acero útil va de A_{smin} = 1.07 a A_{sb} = 6.85 cm². Por debajo, la viga falla al fisurar; por encima, el hormigón se aplasta antes de que el acero fluya.

## 4 · Viga subreforzada: As = 1.40 cm²

A_s1 = 1.40 'acero de la viga del vídeo [cm2]
#: Se supone que el acero fluye (f_{s} = f_{y}). Equilibrio C = T: 0.85·f'c·b·a = A_{s}·f_{y}.
a_1 = A_s1·f_y/(0.85·f_c·b) 'profundidad del bloque de Whitney [cm]
c_1 = a_1/beta_1 'eje neutro desde arriba [cm]
e_t1 = 0.003·(d - c_1)/c_1 'deformación del acero cuando el hormigón llega a 0.003 [-]
#: ε_{t} sale unas **diez veces** ε_{y} = 0.0021: el acero fluye muchísimo antes de que el hormigón se aplaste. El supuesto se cumple.
M_n1 = A_s1·f_y·(d - a_1/2) 'momento nominal [kgf·cm]
P_n1 = 6·M_n1/L_v/1000 'carga total nominal [t]
P_y1_ops = 2.929 'Hekatan OpenSees: carga cuando fluye el acero [t]
P_u1_ops = 2.872 'Hekatan OpenSees: carga cuando el hormigón llega a 0.003 [t]
D_y1_ops = 8.380 'Hekatan OpenSees: flecha al fluir el acero [mm]
D_u1_ops = 50.580 'Hekatan OpenSees: flecha cuando el hormigón llega a 0.003 [mm]
mu_1 = D_u1_ops/D_y1_ops 'ductilidad de desplazamiento μΔ [-]
#: **Lectura.** El ACI a mano (2.88 t) queda entre las dos cargas de OpenSees (2.87 al aplastar, 2.93 al fluir): **1 a 2 %** de diferencia. Pero la flecha pasa de unos 8 mm al fluir a unos 51 mm al aplastar: μ_{Δ} ≈ 6. Esa **meseta** es la ductilidad: la viga avisa con grietas anchas y una flecha grande.

## 5 · Viga sobrerreforzada: As = 1.4·Asb

A_s4 = 1.4·A_sb 'mucho acero: 40 % por encima del balanceado [cm2]
#: Aquí el acero **no fluye**: f_{s} = E_{s}·0.003·(d − c)/c. El equilibrio 0.85·f'c·b·β_{1}·c = A_{s}·E_{s}·0.003·(d − c)/c, multiplicado por c, es una ecuación de 2.º grado en c: q_{a}·c² + q_{b}·c − q_{b}·d = 0.
q_a = 0.85·f_c·b·beta_1 'coeficiente de c² [kgf/cm2·cm]
q_b = A_s4·E_s·0.003 'coeficiente de c [kgf]
c_4 = (-q_b + sqrt(q_b^2 + 4·q_a·q_b·d))/(2·q_a) 'eje neutro desde arriba [cm]
f_s4 = E_s·0.003·(d - c_4)/c_4 'esfuerzo del acero, menor que fy: no fluye [kgf/cm2]
a_4 = beta_1·c_4 'bloque de Whitney [cm]
M_n4 = A_s4·f_s4·(d - a_4/2) 'momento nominal [kgf·cm]
P_n4 = 6·M_n4/L_v/1000 'carga total nominal [t]
P_u4_ops = 11.365 'Hekatan OpenSees: carga cuando el hormigón llega a 0.003 [t]
D_u4_ops = 13.000 'Hekatan OpenSees: flecha cuando el hormigón llega a 0.003 [mm]
#: **Lectura.** El acero se queda en unos 3300 kgf/cm², lejos de los 4200: no fluye. El ACI da 4 % más que OpenSees (el bloque de Whitney con ε_{cu} = 0.003 no es la parábola de Concrete02). La viga carga **cuatro veces más** que la subreforzada, pero se rompe con poca flecha y **sin aviso**. Por eso la norma pone un tope al acero aunque «aguante más».

## 6 · Las curvas de Hekatan OpenSees

#: **Cómo se lee.** Eje x: flecha en el centro Δ [mm]. Eje y: carga total P [t]. Cada curva es la misma sección con más acero. Primero sube recto (sin fisuras), luego se dobla (fisura). Después, la **subreforzada** hace una meseta larga (el acero fluye), mientras que la **balanceada** y la **sobrerreforzada** llegan más alto pero **se cortan pronto**, cuando el hormigón llega a su deformación última.
#fplot(sub_140 = [0.01 0.016; 0.17 0.264; 0.33 0.511; 0.49 0.757; 0.65 1.001; 0.81 1.241; 0.99 1.461; 1.24 1.675; 1.69 1.884; 2.76 1.826; 3.95 1.950; 5.30 2.207; 6.36 2.457; 7.38 2.701; 8.58 2.923; 10.18 2.897; 11.78 2.887; 13.38 2.883; 14.98 2.882; 16.58 2.883; 18.18 2.883; 19.78 2.886; 21.38 2.886; 22.98 2.888; 24.58 2.891; 26.18 2.891; 27.78 2.892; 29.38 2.893; 30.98 2.895; 32.58 2.897; 34.18 2.896; 35.78 2.896; 37.38 2.895; 38.98 2.893; 40.58 2.891; 42.18 2.890; 43.78 2.888; 45.38 2.885; 46.98 2.881; 48.58 2.877; 50.18 2.873; 51.78 2.868; 53.38 2.862; 54.98 2.852; 56.58 2.841; 58.18 2.827; 58.98 2.796], max_075Asb = [0.01 0.017; 0.10 0.174; 0.19 0.330; 0.28 0.486; 0.37 0.641; 0.46 0.795; 0.55 0.949; 0.64 1.103; 0.73 1.256; 0.82 1.408; 0.94 1.596; 1.06 1.764; 1.20 1.937; 1.35 2.102; 1.52 2.271; 1.70 2.432; 1.90 2.597; 2.11 2.756; 2.34 2.919; 2.58 3.079; 2.82 3.231; 3.09 3.394; 3.36 3.550; 3.64 3.707; 3.91 3.863; 4.40 4.162; 5.00 4.547; 5.60 4.942; 6.20 5.342; 6.80 5.745; 7.40 6.146; 8.00 6.546; 8.60 6.941; 9.20 7.330; 9.80 7.711; 10.40 8.084; 11.00 8.446; 11.60 8.796; 12.20 9.132; 12.80 9.259; 13.40 9.256; 14.00 9.241; 14.60 9.215; 15.20 9.176; 15.80 9.125; 16.40 9.058; 17.00 8.970; 17.60 8.853; 18.20 8.690; 18.80 8.415; 19.40 7.964; 19.40 7.964], balanceada = [0.01 0.018; 0.10 0.182; 0.19 0.344; 0.28 0.507; 0.37 0.668; 0.46 0.829; 0.55 0.990; 0.64 1.150; 0.73 1.309; 0.82 1.468; 0.92 1.638; 1.04 1.823; 1.16 1.992; 1.28 2.148; 1.43 2.327; 1.58 2.494; 1.73 2.652; 1.90 2.820; 2.08 2.991; 2.26 3.154; 2.44 3.311; 2.62 3.463; 2.83 3.636; 3.04 3.804; 3.25 3.969; 3.46 4.130; 3.67 4.288; 3.88 4.444; 4.40 4.837; 5.00 5.306; 5.60 5.783; 6.20 6.260; 6.80 6.736; 7.40 7.206; 8.00 7.668; 8.60 8.120; 9.20 8.560; 9.80 8.985; 10.40 9.393; 11.00 9.782; 11.60 10.139; 12.20 10.434; 12.80 10.659; 13.40 10.799; 14.00 10.821; 14.60 10.664; 15.20 10.216; 15.80 9.313; 16.00 9.024], sobre_14Asb = [0.01 0.019; 0.10 0.193; 0.19 0.365; 0.28 0.537; 0.37 0.708; 0.46 0.879; 0.55 1.049; 0.64 1.218; 0.73 1.387; 0.82 1.555; 0.91 1.720; 1.00 1.877; 1.11 2.057; 1.23 2.240; 1.35 2.413; 1.47 2.578; 1.59 2.736; 1.71 2.888; 1.86 3.072; 2.01 3.249; 2.16 3.422; 2.31 3.591; 2.46 3.756; 2.61 3.918; 2.76 4.078; 2.91 4.235; 3.06 4.390; 3.21 4.543; 3.36 4.694; 3.53 4.863; 3.71 5.040; 3.89 5.215; 4.40 5.702; 5.00 6.276; 5.60 6.850; 6.20 7.418; 6.80 7.976; 7.40 8.520; 8.00 9.046; 8.60 9.552; 9.20 10.035; 9.80 10.489; 10.40 10.902; 11.00 11.227; 11.60 11.450; 12.20 11.544; 12.80 11.448; 13.40 11.094; 14.00 10.331; 14.60 9.270; 14.60 9.270], [0 60])

#: **Capacidad contra ductilidad.** Eje x: área de acero A_{s} [cm²]. Eje y: deformación del acero ε_{s} en el instante en que el hormigón llega a 0.003 [-]. Los **puntos** son Hekatan OpenSees (un análisis completo por cada A_{s}); la **curva** es la fórmula del ACI ε_{t} = 0.003·(d − c)/c con c = A_{s}·f_{y}/(0.85·f'c·b·β_{1}), válida mientras el acero fluye. Donde la curva cruza ε_{y} = 0.0021 está el **balanceado**; a la izquierda del cruce con 0.005 la sección es «controlada por tracción» (φ = 0.90).
#fplot(OpenSees = [0.90 0.03394; 1.35 0.02158; 1.80 0.01553; 2.25 0.01191; 2.70 0.00942; 3.15 0.00757; 3.60 0.00630; 4.05 0.00526; 4.50 0.00443; 4.95 0.00377; 5.40 0.00326; 5.85 0.00279; 6.30 0.00239; 6.75 0.00212; 7.20 0.00203; 7.65 0.00194; 8.10 0.00187; 8.55 0.00179; 9.00 0.00173; 9.45 0.00167; 9.90 0.00162; 10.35 0.00157; 10.80 0.00152], ACI = 0.003·(d - x·f_y/(0.85·f_c·b·beta_1))/(x·f_y/(0.85·f_c·b·beta_1)), e_y = 0.0021 + 0·x, e_005 = 0.005 + 0·x, [1 10])

#: **Momento resistente.** Eje x: A_{s} [cm²]. Eje y: momento cuando el hormigón llega a 0.003 [t·m]. Puntos: OpenSees. Curva: ACI suponiendo que el acero fluye, M_{n} = A_{s}·f_{y}·(d − a/2). Al principio van juntos; pasado el balanceado, la curva del ACI **se pasa** de lo real porque el acero ya no fluye y el momento casi deja de crecer.
#fplot(OpenSees = [0.90 0.785; 1.35 1.156; 1.80 1.513; 2.25 1.856; 2.70 2.185; 3.15 2.501; 3.60 2.800; 4.05 3.089; 4.50 3.365; 4.95 3.622; 5.40 3.845; 5.85 4.060; 6.30 4.279; 6.75 4.403; 7.20 4.476; 7.65 4.549; 8.10 4.534; 8.55 4.618; 9.00 4.597; 9.45 4.692; 9.90 4.671; 10.35 4.770; 10.80 4.753], ACI_fluye = x·f_y·(d - x·f_y/(0.85·f_c·b)/2)/100000, [1 10])

## 7 · Resumen: ACI contra Hekatan OpenSees

t_As = [A_s1, A_s4] 'acero de las dos vigas [cm2]
t_Pn = [P_n1, P_n4] 'carga nominal por el ACI [t]
t_Po = [P_u1_ops, P_u4_ops] 'carga de Hekatan OpenSees cuando el hormigón llega a 0.003 [t]
t_Do = [D_u1_ops, D_u4_ops] 'flecha de Hekatan OpenSees en ese instante [mm]
#tabla("Caso","As [cm2]:2","ACI: Pn [t]:3","OpenSees: P con εc = 0.003 [t]:3","OpenSees: Δ [mm]:1")({"Subreforzada","Sobrerreforzada"}; t_As; t_Pn; t_Po; t_Do)

#: **Conclusión.** No hace falta un programa de elementos finitos para entender la ductilidad: el bloque de Whitney (1 a 2 % en la subreforzada, 4 % en la sobrerreforzada) ya dice **qué falla primero**. Lo que agrega OpenSees es la **curva completa** con la flecha, y de ahí la ductilidad μ_{Δ}: cerca de 6 con poco acero; con mucho acero no hay fluencia, y por tanto no hay ductilidad. El simulador 3D (viga-ductilidad/index.html) usa las mismas leyes de material que OpenSees y le pinta encima sus puntos; en la tabla de esa página las cargas coinciden dentro del 2 %.
