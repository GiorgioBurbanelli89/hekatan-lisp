# Zapata excéntrica de lindero y esquinera: área efectiva y capacidad portante, contra GEO5
#numerico

#: **Qué se calcula.** La misma zapata de 1.20 × 1.20 m del ejemplo oficial **Demo01.gpa** de GEO5 Spread Footing (hoja 104), cambiada a «eccentric spread footing»: la columna ya no está en el centro sino pegada al borde. Dos casos: **de lindero** (columna a 1 cm de un borde, a_{x} = 0.01, b_{x} = 0.79) y **esquinera** (a 1 cm de dos bordes, a_{x} = a_{y} = 0.01). Se calcula lo mismo que GEO5: excentricidades, área efectiva, R_{d}, σ, FS y deslizamiento.
#: **Cómo.** Las fórmulas de la ayuda oficial de GEO5 2024 («Stress in the Footing Bottom» con el término N·p de la columna corrida, «Effective Area», «Standard Analysis», «Horizontal Bearing Capacity of Foundation»), las mismas de la hoja 104.
#: **Juez.** El informe de GEO5 2024 con «Partial results» de los dos casos. Después, la comprobación con la **NEC-SE-GC 2015** y una sección que explica **por qué la zapata de lindero real lleva viga de amarre** (explicación, no resultado de GEO5).

## 1 · Datos (los de la hoja 104)

l_x = 1.2 'lado de la zapata en x [m]
l_y = 1.2 'lado de la zapata en y [m]
t_z = 0.4 'canto [m]
d_f = 1.2 'profundidad del fondo desde la rasante [m]
gamma_1 = 17.5 'peso específico del suelo 1 [kN/m3]
phi_1 = 31.5 'φ del suelo 1, el que toca la zapata [grados]
c_1 = 5 'cohesión del suelo 1 [kPa]
N_1 = 3000 'axial de la columna, Load No. 1 [kN]
M_x = -2 'momento alrededor de x [kN·m]
M_y = 70 'momento alrededor de y [kN·m]
H_x = 14 'horizontal en x [kN]
H_y = 5 'horizontal en y [kN]
G_z = 13.248 'peso de la zapata (hoja 104) [kN]
Z_r = 20.48 'peso del relleno encima (hoja 104) [kN]
#: **El suelo homogeneizado bajo el fondo.** Igual que en la hoja 104, φ_{d} y γ₂ son **dato leído del informe de GEO5** (la homogeneización de Prandtl no se reproduce). GEO5 imprime los mismos valores en los tres casos: su superficie de rotura (2.28 m de hondo, 7.51 m de largo) no cambia con el ancho efectivo.
phi_d = 40.21 'φ homogeneizado, del informe de GEO5 [grados]
c_d = 5 'cohesión homogeneizada [kPa]
gamma_2 = 18.95 'γ homogeneizado bajo el fondo, del informe de GEO5 [kN/m3]
q_0 = gamma_1·d_f 'sobrecarga al nivel del fondo [kPa]
f_d = phi_d·pi/180 'φ_{d} en radianes
f_1 = phi_1·pi/180 'φ del suelo 1 en radianes
#: Lo que no depende de dónde esté la columna (hoja 104):
V_d = N_1 + G_z + Z_r 'vertical en el fondo [kN]
N_q = tan(pi/4 + f_d/2)^2·exp(pi·tan(f_d)) 'factor de sobrecarga
N_c = (N_q - 1)/tan(f_d) 'factor de cohesión
N_γ = 1.5·(N_q - 1)·tan(f_d) 'factor de peso propio (Brinch-Hansen)
H_r = sqrt(H_x^2 + H_y^2) 'horizontal resultante [kN]
i_f = (1 - H_r/V_d)^2 'factor de inclinación
S_pd = (1 - sin(f_1))·gamma_1·(d_f^2 - (d_f - t_z)^2)/2·l_y 'empuje en reposo delante de la zapata (hoja 104) [kN]

## 2 · Dónde queda la columna

#: GEO5 pide a_{x}, la distancia del borde a la cara de la columna; su informe da la distancia al **eje**: 0.01 + 0.40/2 = 0.21 m. Medido desde el centro de la zapata:
a_x = 0.01 'del borde a la cara de la columna [m]
c_x = 0.4 'lado de la columna [m]
p_x = a_x + c_x/2 - l_x/2 'eje de la columna desde el centro de la zapata, en x [m]
#: En la esquinera, lo mismo en y:
p_y = a_x + c_x/2 - l_y/2 'eje de la columna desde el centro, en y (esquinera) [m]

## 3 · Zapata de lindero

#: Ayuda «Stress in the Footing Bottom»: a la excentricidad de los momentos se suma la del axial corrido, N·p. La columna a −0.39 m y el momento de la carga empujan hacia el **mismo lado**:
e_xL = (-M_y + H_x·t_z + N_1·p_x)/V_d 'excentricidad en x [m]
e_yL = (M_x + H_y·t_z)/V_d 'excentricidad en y [m]
er_xL = abs(e_xL)/l_x 'relativa en x (GEO5: 0.339 > 0.333)
er_yL = abs(e_yL)/l_y 'relativa en y
#: Más de un tercio: la resultante está fuera del tercio central, **más de la mitad de la zapata se levanta** si se la mira con una presión lineal. GEO5 lo marca en rojo («Eccentricity of load is NOT SATISFACTORY») pero igual calcula con el rectángulo efectivo:
b_xL = l_x - 2·abs(e_xL) 'lado efectivo en x [m]
b_yL = l_y - 2·abs(e_yL) 'lado efectivo en y [m]
b_L = min(b_xL, b_yL) 'ancho efectivo (GEO5: 0.39) [m]
l_L = max(b_xL, b_yL) 'largo efectivo [m]
A_L = b_xL·b_yL 'área efectiva [m2]
sigma_L = V_d/A_L 'presión sobre el área efectiva [kPa]
#: Los factores, con los lados efectivos (hoja 104, sección 5):
s_cL = 1 + 0.2·b_L/l_L 'forma, cohesión
s_qL = 1 + b_L/l_L·sin(f_d) 'forma, sobrecarga
s_γL = 1 - 0.3·b_L/l_L 'forma, peso propio
d_cL = 1 + 0.1·sqrt(d_f/b_L) 'profundidad, cohesión
d_qL = 1 + 0.1·sqrt(d_f/b_L·sin(2·f_d)) 'profundidad, sobrecarga
R_dL = (c_d·N_c·s_cL·d_cL + q_0·N_q·s_qL·d_qL + b_L/2·gamma_2·N_γ·s_γL)·i_f 'capacidad portante [kPa]
FS_L = R_dL/sigma_L 'factor de seguridad vertical
R_dhL = V_d·tan(f_1) + c_1·A_L + S_pd 'capacidad horizontal [kN]
FS_hL = R_dhL/H_r 'factor de seguridad al deslizamiento

## 4 · Zapata esquinera

e_xE = (-M_y + H_x·t_z + N_1·p_x)/V_d 'excentricidad en x [m]
e_yE = (M_x + H_y·t_z + N_1·p_y)/V_d 'excentricidad en y [m]
er_xE = abs(e_xE)/l_x 'relativa en x (GEO5: 0.339)
er_yE = abs(e_yE)/l_y 'relativa en y (GEO5: 0.321)
er_tE = sqrt(er_xE^2 + er_yE^2) 'relativa total (GEO5: 0.467)
b_xE = l_x - 2·abs(e_xE) 'lado efectivo en x [m]
b_yE = l_y - 2·abs(e_yE) 'lado efectivo en y [m]
b_E = min(b_xE, b_yE) 'ancho efectivo (GEO5: 0.39) [m]
l_E = max(b_xE, b_yE) 'largo efectivo (GEO5: 0.43) [m]
A_E = b_xE·b_yE 'área efectiva: un 11 % de la zapata [m2]
sigma_E = V_d/A_E 'presión sobre el área efectiva [kPa]
s_cE = 1 + 0.2·b_E/l_E 'forma, cohesión
s_qE = 1 + b_E/l_E·sin(f_d) 'forma, sobrecarga
s_γE = 1 - 0.3·b_E/l_E 'forma, peso propio
d_cE = 1 + 0.1·sqrt(d_f/b_E) 'profundidad, cohesión
d_qE = 1 + 0.1·sqrt(d_f/b_E·sin(2·f_d)) 'profundidad, sobrecarga
R_dE = (c_d·N_c·s_cE·d_cE + q_0·N_q·s_qE·d_qE + b_E/2·gamma_2·N_γ·s_γE)·i_f 'capacidad portante [kPa]
FS_E = R_dE/sigma_E 'factor de seguridad vertical
R_dhE = V_d·tan(f_1) + c_1·A_E + S_pd 'capacidad horizontal [kN]
FS_hE = R_dhE/H_r 'factor de seguridad al deslizamiento
#: **Paradoja aparente:** R_{d} de la esquinera (3302) es **mayor** que la de lindero (2698). Es la forma: el área efectiva de la esquinera es casi cuadrada (0.39 × 0.43) y el factor s_{q} sube a 1.58; la de lindero es una tira de 0.39 × 1.20 (s_{q} = 1.21). Pero la presión se multiplica por 2.8 y el FS cae a 0.18.

#dibujo("Planta de las dos zapatas: área efectiva rayada, columna y resultante (punto rojo)", ud = m, escala = 1:20, cotas = m, alto = 120)
#  rect(-0.6, -0.6, 1.2, 1.2, "gruesa")
#  rect(-0.6, -0.6, b_xL, b_yL, "verde relleno")
#  achurado(-0.6, -0.6, b_xL, b_yL, "diagonal")
#  rect(-0.59, -0.2, 0.4, 0.4, "media")
#  circulo(e_xL, e_yL, 0.035, "rojo")
#  linea(-0.8, 0, 0.8, 0, "eje")
#  linea(0, -0.8, 0, 0.8, "eje")
#  texto(0, 0.9, "LINDERO", 3, "c")
#  cota(-0.6, -0.78, -0.6 + b_xL, -0.78, -0.1, "0.386")
#  rect(1.6, -0.6, 1.2, 1.2, "gruesa")
#  rect(1.6, -0.6, b_xE, b_yE, "verde relleno")
#  achurado(1.6, -0.6, b_xE, b_yE, "diagonal")
#  rect(1.61, -0.59, 0.4, 0.4, "media")
#  circulo(2.2 + e_xE, e_yE, 0.035, "rojo")
#  linea(1.4, 0, 3.0, 0, "eje")
#  linea(2.2, -0.8, 2.2, 0.8, "eje")
#  texto(2.2, 0.9, "ESQUINERA", 3, "c")
#  cota(1.6, -0.78, 1.6 + b_xE, -0.78, -0.1, "0.386")
#  cota(3.0, -0.6, 3.0, -0.6 + b_yE, -0.1, "0.429")
#fin
#: La resultante (punto rojo) cae **dentro de la columna**: la columna está corrida 0.39 m y el momento de la carga la corre 2 cm más. El área efectiva es el rectángulo que tiene ese punto en su centro; el resto de la zapata no trabaja.

#: **3D: la presión de contacto de GEO5** (rectángulo efectivo, presión uniforme), lindero a la izquierda y esquinera a la derecha. Altura: 1 m = 10 000 kPa. Se gira con el ratón y el cursor lee la presión:
#hide
n_g = 25
n_p = n_g^2
X_n = zeros(2·n_p + 4, 3)
v_n = zeros(2·n_p + 4, 1)
e_s = zeros(2·(n_g - 1)^2, 4)
for c = 1:2
  for j = 1:n_g
    for k = 1:n_g
      p = (c - 1)·n_p + (j - 1)·n_g + k
      xx = -0.6 + 1.2·(k - 1)/(n_g - 1)
      yy = -0.6 + 1.2·(j - 1)/(n_g - 1)
      X_n(p, 1) = xx + 2.2·(c - 1)
      X_n(p, 2) = yy
      if c == 1
        if xx <= -0.6 + b_xL + 0.001
          v_n(p) = sigma_L
        end
      else
        if xx <= -0.6 + b_xE + 0.001
          if yy <= -0.6 + b_yE + 0.001
            v_n(p) = sigma_E
          end
        end
      end
      X_n(p, 3) = v_n(p)/10000
    end
  end
  for j = 1:n_g - 1
    for k = 1:n_g - 1
      q = (c - 1)·(n_g - 1)^2 + (j - 1)·(n_g - 1) + k
      a = (c - 1)·n_p + (j - 1)·n_g + k
      e_s(q, 1) = a
      e_s(q, 2) = a + 1
      e_s(q, 3) = a + n_g + 1
      e_s(q, 4) = a + n_g
    end
  end
end
X_n(2·n_p + 1, 1) = p_x
X_n(2·n_p + 2, 1) = p_x
X_n(2·n_p + 2, 3) = 2.2
X_n(2·n_p + 3, 1) = 2.2 + p_x
X_n(2·n_p + 3, 2) = p_y
X_n(2·n_p + 4, 1) = 2.2 + p_x
X_n(2·n_p + 4, 2) = p_y
X_n(2·n_p + 4, 3) = 2.2
e_f = [2·n_p + 1, 2·n_p + 2; 2·n_p + 3, 2·n_p + 4]
v_f = [0, 0; 0, 0]
#show
#modelo3d(X_n, e_s, e_f, v_n, v_f)
#: Las barras verticales son los ejes de las columnas. La de lindero carga 6546 kPa sobre una tira de 39 cm; la esquinera, 18 324 kPa sobre un cuadradito de 0.39 × 0.43 m. Ningún suelo aguanta eso: el FS lo dice (0.41 y 0.18).

## 5 · Hekatan contra GEO5

#hide
g_exL = 0.339
g_bL = 0.386
g_sL = 6545.84
g_sqL = 1.208
g_dqL = 1.175
g_RdL = 2698.373
g_FSL = 0.41
g_RhL = 1865.40
g_FhL = 125.48
g_exE = 0.339
g_eyE = 0.321
g_etE = 0.467
g_bE = 0.386
g_sE = 18324.06
g_sqE = 1.582
g_scE = 1.180
g_RdE = 3302.208
g_FSE = 0.18
g_RhE = 1863.91
g_FhE = 125.38
h_exL = round(er_xL, 3)
h_bL = round(b_L, 3)
h_sL = round(sigma_L, 2)
h_sqL = round(s_qL, 3)
h_dqL = round(d_qL, 3)
h_RdL = round(R_dL, 3)
h_FSL = round(FS_L, 2)
h_RhL = round(R_dhL, 2)
h_FhL = round(FS_hL, 2)
h_exE = round(er_xE, 3)
h_eyE = round(er_yE, 3)
h_etE = round(er_tE, 3)
h_bE = round(b_E, 3)
h_sE = round(sigma_E, 2)
h_sqE = round(s_qE, 3)
h_scE = round(s_cE, 3)
h_RdE = round(R_dE, 3)
h_FSE = round(FS_E, 2)
h_RhE = round(R_dhE, 2)
h_FhE = round(FS_hE, 2)
x_exL = round(100·(h_exL/g_exL - 1), 3)
x_bL = round(100·(h_bL/g_bL - 1), 3)
x_sL = round(100·(h_sL/g_sL - 1), 4)
x_sqL = round(100·(h_sqL/g_sqL - 1), 3)
x_dqL = round(100·(h_dqL/g_dqL - 1), 3)
x_RdL = round(100·(h_RdL/g_RdL - 1), 4)
x_FSL = round(100·(h_FSL/g_FSL - 1), 2)
x_RhL = round(100·(h_RhL/g_RhL - 1), 4)
x_FhL = round(100·(h_FhL/g_FhL - 1), 3)
x_exE = round(100·(h_exE/g_exE - 1), 3)
x_eyE = round(100·(h_eyE/g_eyE - 1), 3)
x_etE = round(100·(h_etE/g_etE - 1), 3)
x_bE = round(100·(h_bE/g_bE - 1), 3)
x_sE = round(100·(h_sE/g_sE - 1), 4)
x_sqE = round(100·(h_sqE/g_sqE - 1), 3)
x_scE = round(100·(h_scE/g_scE - 1), 3)
x_RdE = round(100·(h_RdE/g_RdE - 1), 4)
x_FSE = round(100·(h_FSE/g_FSE - 1), 2)
x_RhE = round(100·(h_RhE/g_RhE - 1), 4)
x_FhE = round(100·(h_FhE/g_FhE - 1), 3)
#show
#| Magnitud | Hekatan | GEO5 2024 | Diferencia [%] |
#|---|---:|---:|---:|
#| **LINDERO** · excentricidad relativa e_{x} | @{h_exL} | @{g_exL} | @{x_exL} |
#| ancho efectivo [m] | @{h_bL} | @{g_bL} | @{x_bL} |
#| presión σ [kPa] | @{h_sL} | @{g_sL} | @{x_sL} |
#| s_{q} | @{h_sqL} | @{g_sqL} | @{x_sqL} |
#| d_{q} | @{h_dqL} | @{g_dqL} | @{x_dqL} |
#| **R_{d} [kPa]** | @{h_RdL} | @{g_RdL} | @{x_RdL} |
#| FS vertical | @{h_FSL} | @{g_FSL} | @{x_FSL} |
#| R_{dh} [kN] | @{h_RhL} | @{g_RhL} | @{x_RhL} |
#| FS horizontal | @{h_FhL} | @{g_FhL} | @{x_FhL} |
#| **ESQUINERA** · excentricidad relativa e_{x} | @{h_exE} | @{g_exE} | @{x_exE} |
#| excentricidad relativa e_{y} | @{h_eyE} | @{g_eyE} | @{x_eyE} |
#| excentricidad relativa total e_{t} | @{h_etE} | @{g_etE} | @{x_etE} |
#| ancho efectivo [m] | @{h_bE} | @{g_bE} | @{x_bE} |
#| presión σ [kPa] | @{h_sE} | @{g_sE} | @{x_sE} |
#| s_{q} | @{h_sqE} | @{g_sqE} | @{x_sqE} |
#| s_{c} | @{h_scE} | @{g_scE} | @{x_scE} |
#| **R_{d} [kPa]** | @{h_RdE} | @{g_RdE} | @{x_RdE} |
#| FS vertical | @{h_FSE} | @{g_FSE} | @{x_FSE} |
#| R_{dh} [kN] | @{h_RhE} | @{g_RhE} | @{x_RhE} |
#| FS horizontal | @{h_FhE} | @{g_FhE} | @{x_FhE} |
#: Con el valor de Hekatan redondeado a los decimales que imprime GEO5. Lo que asoma en R_{d} (0.01 kPa) es otra vez φ_{d} = 40.210 con tres decimales.

## 6 · Comprobación con la NEC-SE-GC 2015

#: **Lo que dice la norma** (solo valores de la NEC-SE-GC 2015, la oficial):
#: · **Tabla 6, §6.2 (p. 42)**: factor de seguridad mínimo para capacidad portante de cimientos superficiales, **3.0** con carga muerta + viva normal, 2.5 con viva máxima, 1.5 con sismo pseudoestático.
#: · **Tabla 5, §5.2 (p. 36-38)**: excentricidad **e/B ≤ 1/6** en estático (≤ 1/4 con sismo). La tabla es de **muros**; usarla en una zapata aislada es **criterio nuestro**: es el límite del tercio central, donde toda la base sigue comprimida.
#: · GEO5 en este ejemplo usa FS = 1.50 y e ≤ 0.333 (Settings del Demo01), que **no son los de la NEC**.
#: **Criterio nuestro también:** la Load No. 1 del Demo01 es de tipo «Design»; aquí se toma tal cual, como si fuera la combinación de servicio CM + CV normal que pide la Tabla 6.
FS_nec = 3 'Tabla 6, CM + CV normal
e_nec = 1/6 'Tabla 5 (criterio nuestro para la zapata)
#hide
r_FSc = 1.65
r_ec = 0.195
r_FSL = round(FS_L, 2)
r_eL = round(er_xL, 3)
r_FSE = round(FS_E, 2)
r_eE = round(max(er_xE, er_yE), 3)
#show
#| Zapata | FS (GEO5 = Hekatan) | NEC: FS ≥ 3.0 | e/B máxima | NEC: e/B ≤ 0.167 | GEO5: e ≤ 0.333 |
#|---|---:|:---:|---:|:---:|:---:|
#| céntrica (hoja 104) | @{r_FSc} | no cumple | @{r_ec} (Load 2) | no cumple | cumple |
#| de lindero | @{r_FSL} | no cumple | @{r_eL} | no cumple | no cumple |
#| esquinera | @{r_FSE} | no cumple | @{r_eE} | no cumple | no cumple |
#: **Las tres fallan la NEC.** Hasta la céntrica, que GEO5 da por buena con su 1.50, queda en 1.65 frente al 3.0 de la Tabla 6, y la Load No. 2 (M = −200 kN·m) la saca del tercio central. Con la NEC esta zapata de 1.20 m es pequeña para 3000 kN.

## 7 · Por qué la zapata de lindero real lleva viga de amarre (explicación, no es resultado de GEO5)

#: En lindero la zapata no puede centrarse bajo la columna: el terreno del vecino no se toca. Si se deja sola, pasa lo de la sección 3: la columna está a e₀ = 0.39 m del centro, y ese brazo convierte el axial en un **momento** que la zapata no puede equilibrar con el suelo:
e_0 = abs(p_x) 'brazo de la columna respecto al centro de la zapata [m]
M_0 = N_1·e_0 'momento que crea la columna corrida [kN·m]
#: La **viga de amarre** (o viga de equilibrio) une esta zapata con la de la columna interior. Funciona como una palanca: la viga toma M₀ y la zapata de lindero recibe una carga **centrada**. Supuesto de esta sección (no viene del Demo01): la columna interior está a **L_{v} = 5.00 m**. Momentos respecto al eje de la columna interior:
L_v = 5 'distancia entre ejes de columnas (supuesto) [m]
R_1 = N_1·L_v/(L_v - e_0) 'reacción del suelo bajo la zapata de lindero, ya centrada [kN]
D_P = R_1 - N_1 'lo que la viga le quita a la columna interior [kN]
#: La zapata de lindero recibe **más** que su columna (R₁ > N₁), pero centrada; la interior recibe **menos**. Con la carga centrada la zapata vuelve a ser la céntrica de la hoja 104, sin el brazo de 0.39 m (se dejan los momentos y la horizontal de la carga, que toma la zapata):
V_v = R_1 + G_z + Z_r 'vertical en el fondo con viga [kN]
e_v = (-M_y + H_x·t_z)/V_v 'excentricidad que queda: solo la de la carga [m]
b_v = l_x - 2·abs(e_v) 'ancho efectivo con viga [m]
sigma_v = V_v/(b_v·l_y) 'presión con viga [kPa]
R_dv = (c_d·N_c·(1 + 0.2·b_v/l_y)·(1 + 0.1·sqrt(d_f/b_v)) + q_0·N_q·(1 + b_v/l_y·sin(f_d))·(1 + 0.1·sqrt(d_f/b_v·sin(2·f_d))) + b_v/2·gamma_2·N_γ·(1 - 0.3·b_v/l_y))·(1 - H_r/V_v)^2 'capacidad con viga [kPa]
FS_v = R_dv/sigma_v 'factor de seguridad con viga
#hide
r_FSv = round(FS_v, 2)
r_R1 = round(R_1, 1)
r_M0 = round(M_0, 0)
#show
#: **Lectura.** Con la viga el FS pasa de @{r_FSL} a @{r_FSv}: la zapata vuelve a trabajar entera y cumple el 1.50 de GEO5. La viga se diseña para un momento del orden de N·e₀ = @{r_M0} kN·m (máximo junto a la columna de lindero) y la zapata para R₁ = @{r_R1} kN. **Con la NEC sigue sin bastar** (FS < 3.0): hay que agrandar la zapata además de amarrarla. La esquinera es el mismo problema en dos direcciones: viga de amarre en x y en y.

#dibujo("Viga de amarre: la palanca que centra la zapata de lindero (esquema, L_v supuesto = 5 m)", ud = m, escala = auto, alto = 110)
#  rect(-0.6, -0.4, 1.2, 0.4, "gruesa")
#  achurado(-0.6, -0.4, 1.2, 0.4, "concreto")
#  rect(4.0, -0.4, 1.4, 0.4, "gruesa")
#  achurado(4.0, -0.4, 1.4, 0.4, "concreto")
#  rect(-0.59, 0, 0.4, 1.4, "media")
#  rect(4.5, 0, 0.4, 1.4, "media")
#  rect(-0.59, 0, 5.49, 0.5, "media azul relleno")
#  texto(2.2, 0.25, "viga de amarre (toma M = N·e₀)", 2.8, "c")
#  flecha(-0.39, 2.2, -0.39, 1.45, "rojo")
#  texto(-0.3, 2.0, "N₁ = 3000 kN", 2.6, "i")
#  flecha(0, -1.3, 0, -0.45, "verde")
#  texto(0.1, -1.1, "R₁ centrada", 2.6, "i")
#  linea(-0.6, -1.6, -0.6, 2.4, "trazos rojo")
#  texto(-0.7, 2.25, "lindero (terreno del vecino)", 2.6, "d")
#  cota(-0.39, 1.7, 4.7, 1.7, 0.15, "L_{v} = 5.00")
#  cota(-0.39, -0.6, 0, -0.6, -0.12, "e₀ = 0.39")
#fin

#: **En una línea:** GEO5 calcula bien lo que se le da (área efectiva y Brinch-Hansen), pero una zapata con la columna en el borde **no se arregla con el suelo**, se arregla con la estructura: viga de amarre que lleve el momento N·e₀ a otra zapata.
