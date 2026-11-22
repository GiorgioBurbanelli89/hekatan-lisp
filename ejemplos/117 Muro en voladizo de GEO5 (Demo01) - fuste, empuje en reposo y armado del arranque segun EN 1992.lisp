# Fuste del muro de GEO5: empuje en reposo, momento en el arranque y armado (EN 1992)
#numerico

#: **Qué se calcula.** El marco «Dimensioning» de GEO5 Cantilever Wall con el ejemplo oficial **Demo01.guz** (el mismo muro de la hoja 116): la **sección del arranque del fuste**, a 5.00 m de la coronación. Primero las fuerzas sobre el fuste y el momento y el cortante en esa junta; luego la comprobación de la sección de hormigón armado que GEO5 imprime (cuantía, eje neutro, M_{Rd}, V_{Rd} y armadura requerida).
#: **Por qué en reposo.** En Stage settings el ejemplo dice «Pressure acting on the stem: pressure at rest». El fuste está empotrado en la zapata y casi no se mueve: el suelo no llega al estado activo. Por eso el fuste se diseña con K₀ = 1 − sin φ, más grande que el K_{a} de la hoja 116.
#: **Juez.** La ventana «In detail» de Dimensioning de GEO5 2024 (Wall stem check - back reinf.) y su tabla de fuerzas.
#: **Unidades.** kN, m, kPa y MPa por metro de muro; armaduras en mm². Ángulos en grados en los datos y en radianes dentro de las fórmulas.

## 1 · Datos

#: **El fuste** (marco Geometry): 0.20 m en la coronación, cara trasera vertical, cara delantera inclinada 1:12.5, alto 5.00 m.
t_f = 0.2 'espesor del fuste en la coronación [m]
n_f = 12.5 'inclinación de la cara delantera: 1 horizontal cada 12.5 vertical
H_j = 5 'profundidad de la junta de construcción bajo la coronación [m]
gamma_c = 23 'peso específico del hormigón [kN/m3]
#: **Los estratos detrás del fuste** (marcos Profile y Soils), con su espesor desde la coronación:
t_1 = 2.3 'espesor del suelo 1 [m]
t_2 = 1.7 'espesor del suelo 2 [m]
g_1 = 19 'peso específico del suelo 1 [kN/m3]
g_2 = 17.5 'peso específico del suelo 2 [kN/m3]
g_3 = 19.5 'peso específico del suelo 3 [kN/m3]
p_1 = 29 'ángulo de rozamiento del suelo 1 [grados]
p_2 = 31.5 'ángulo de rozamiento del suelo 2 [grados]
p_3 = 27 'ángulo de rozamiento del suelo 3 [grados]
#: **La fuerza de la coronación** (Force No. 1): 30 kN/m horizontal, a 0.20 m sobre la coronación.
F_1 = 30 'fuerza horizontal [kN/m]
a_F = 0.2 'altura de la fuerza sobre la coronación [m]
#: **Los materiales** (marco Material): hormigón C 20/25 y acero B500B. La armadura trasera: 14 barras Ø 20 mm por metro, recubrimiento 30 mm.
f_ck = 20 'resistencia característica del hormigón [MPa]
f_yk = 500 'límite elástico del acero [MPa]
f_ctm = 2.2 'resistencia media a tracción del hormigón (marco Material) [MPa]
g_cc = 1.5 'coeficiente parcial del hormigón γc (EN 1992)
g_ss = 1.15 'coeficiente parcial del acero γs (EN 1992)
n_b = 14 'número de barras por metro
d_b = 20 'diámetro de las barras [mm]
r_c = 30 'recubrimiento [mm]
b_w = 1 'ancho de cálculo [m]

## 2 · La sección del arranque

#: El espesor crece de 0.20 m arriba a 0.20 + H_{j}/12.5 en la junta:
h_s = t_f + H_j/n_f 'canto de la sección en la junta [m]
#: **Peso del fuste** sobre la junta: un rectángulo de 0.20 m más un triángulo (la cuña delantera):
A_r = t_f·H_j 'rectángulo [m2]
A_t = (h_s - t_f)·H_j/2 'triángulo [m2]
W_f = gamma_c·(A_r + A_t) 'peso del fuste sobre la junta [kN/m]
#: Su centroide, medido desde la cara trasera (el rectángulo a t_{f}/2, el triángulo a t_{f} + un tercio de su base), y la distancia al **centro de la sección**, que es la excentricidad del peso:
x_W = (A_r·t_f/2 + A_t·(t_f + (h_s - t_f)/3))/(A_r + A_t) 'centroide del peso desde la cara trasera [m]
e_W = h_s/2 - x_W 'excentricidad del peso respecto del centro de la sección, hacia atrás [m]
y_W = (A_r·H_j/2 + A_t·H_j/3)/(A_r + A_t) 'altura del centroide sobre la junta [m]

## 3 · Empuje en reposo sobre el fuste

#: K₀ = 1 − sin φ en cada estrato (ayuda de GEO5, «Pressure at Rest», suelo no cohesivo), σ₀ = K₀·σ_{z}; en reposo la cohesión no resta. El suelo 3 llega hasta la junta:
r_g = pi/180 'grados a radianes
K_01 = 1 - sin(p_1·r_g) 'K₀ del suelo 1
K_02 = 1 - sin(p_2·r_g) 'K₀ del suelo 2
K_03 = 1 - sin(p_3·r_g) 'K₀ del suelo 3
t_3 = H_j - t_1 - t_2 'espesor del suelo 3 sobre la junta [m]
s_v1 = g_1·t_1 'presión vertical en la base del suelo 1 [kPa]
s_v2 = s_v1 + g_2·t_2 'presión vertical en la base del suelo 2 [kPa]
#: En cada estrato la presión es un trapecio = rectángulo (lo que pesa lo de arriba) + triángulo (su propio peso). Resultante de cada uno y su brazo **sobre la junta**:
P_1 = K_01·g_1·t_1^2/2 'suelo 1: triángulo [kN/m]
P_2r = K_02·s_v1·t_2 'suelo 2: rectángulo [kN/m]
P_2t = K_02·g_2·t_2^2/2 'suelo 2: triángulo [kN/m]
P_3r = K_03·s_v2·t_3 'suelo 3: rectángulo [kN/m]
P_3t = K_03·g_3·t_3^2/2 'suelo 3: triángulo [kN/m]
P_0 = P_1 + P_2r + P_2t + P_3r + P_3t 'empuje en reposo total sobre el fuste [kN/m]
M_0 = P_1·(t_2 + t_3 + t_1/3) + P_2r·(t_3 + t_2/2) + P_2t·(t_3 + t_2/3) + P_3r·t_3/2 + P_3t·t_3/3 'su momento en la junta [kN·m/m]
z_0 = M_0/P_0 'altura de la resultante sobre la junta [m]

#: **El fuste dibujado, a escala.** Sección vertical del fuste con el relleno a la derecha (la cara trasera, vertical, está en x = 0) y la cara delantera inclinada 1:12.5 a la izquierda. Las líneas a trazos separan los tres estratos (2.30, 1.70 y 1.00 m hasta la junta). **Azul:** el empuje **en reposo** σ₀ = K₀·σ_{z} sobre la cara trasera (1 m de flecha = 25 kPa): crece con la profundidad y **salta** en cada contacto porque cambia K₀ (cada suelo tiene su φ). **Rojo:** la fuerza de la coronación, 30 kN/m. **Naranja:** el peso del fuste, que cae detrás del centro de la sección. Todo se reduce a la **junta de construcción**, a 5.00 m de la coronación (y = 0 en el dibujo), que es donde se arma.
pq_1 = K_01*g_1*t_1/25 'σ₀ en la base del suelo 1, a escala del dibujo
pq_2 = K_02*s_v1/25 'σ₀ arriba del suelo 2 (salta: cambia K₀)
pq_3 = K_02*(s_v1 + g_2*t_2)/25 'σ₀ en la base del suelo 2
pq_4 = K_03*s_v2/25 'σ₀ arriba del suelo 3
pq_5 = K_03*(s_v2 + g_3*t_3)/25 'σ₀ en la junta
P0_t = round(P_0, 1) 'empuje total, para el rótulo
#dibujo("Fuste de GEO5 Demo01: estratos, empuje en reposo (azul, 1 m = 25 kPa), fuerza de la coronación (rojo) y peso (naranja)", ud = m, escala = auto, cotas = m, alto = 230)
#  poligono(0, 0, 0, H_j, -t_f, H_j, -h_s, 0, "gruesa")
#  poligono(0, 0, 0, H_j, -t_f, H_j, -h_s, 0, "gris tenue")
#  linea(0, H_j, 4.8, H_j, "media verde")
#  linea(0, H_j - t_1, 4.8, H_j - t_1, "trazos")
#  linea(0, H_j - t_1 - t_2, 4.8, H_j - t_1 - t_2, "trazos")
#  linea(-h_s - 0.4, 0, 4.8, 0, "eje")
#  carga(0, H_j, 0, H_j - t_1, 0, pq_1, "", "azul", n = 4)
#  carga(0, H_j - t_1, 0, H_j - t_1 - t_2, pq_2, pq_3, "", "azul", n = 4)
#  carga(0, H_j - t_1 - t_2, 0, 0, pq_4, pq_5, "", "azul", n = 3)
#  flecha(2.4, H_j + a_F, 0.05, H_j + a_F, "rojo")
#  texto(0.4, H_j + a_F + 0.25, "F = 30 kN/m", 2.5, "i")
#  flecha(-x_W, y_W + 1.2, -x_W, y_W, "naranja")
#  texto(-x_W - 1.5, y_W + 1.3, "W = 45.98 kN/m", 2.5, "i")
#  texto(2.35, H_j - t_1/2, "suelo 1: γ 19, φ 29°", 2.5, "i")
#  texto(2.35, H_j - t_1 - t_2/2, "suelo 2: γ 17.5, φ 31.5°", 2.5, "i")
#  texto(2.35, t_3/2, "suelo 3: γ 19.5, φ 27°", 2.5, "i")
#  texto(0.3, 0.2, "junta: se arma aquí", 2.5, "i")
#  cota(-h_s - 0.7, 0, -h_s - 0.7, H_j, 0.1, "5.00")
#  cota(-t_f, H_j + 0.7, 0, H_j + 0.7, 0.1, "0.20")
#  cota(-h_s, -0.6, 0, -0.6, -0.1, "0.60")
#  cota(5.0, H_j - t_1, 3.6, H_j, 0.1, "2.30")
#  cota(5.0, H_j - t_1 - t_2, 3.6, H_j - t_1, 0.1, "1.70")
#  cota(5.0, 0, 3.6, H_j - t_1 - t_2, 0.1, "1.00")
#fin
#: **Cómo se lee.** El área de cada trapecio azul es el empuje de ese estrato (rectángulo = lo que pesa lo de arriba × K₀, triángulo = su propio peso × K₀). Sumados dan **P₀ = @{P0_t} kN/m**, a @{z_0} m sobre la junta: el brazo con que flexiona el fuste. La fuerza de 30 kN/m actúa 5.20 m sobre la junta (brazo grande) y por eso pesa casi tanto como todo el suelo. El peso, al caer detrás del centro de la sección, **resta** un poco de momento. La suma de los tres momentos es M_{Ed}, que se compara más abajo con la resistencia de la armadura.

## 4 · Momento y cortante de diseño en la junta

#: El empuje y la fuerza de la coronación flexionan el fuste hacia delante (tracción en la cara trasera); el peso, que cae detrás del centro, lo endereza un poco. Con los coeficientes 1.000 del ejemplo (ASD):
M_Ed = M_0 + F_1·(H_j + a_F) - W_f·e_W 'momento de diseño en la junta [kN·m/m]
V_Ed = P_0 + F_1 'cortante de diseño en la junta [kN/m]
N_Ed = W_f 'axial (no se usa en la flexión simple de GEO5) [kN/m]

## 4b · Momento y cortante a lo largo del fuste

#: El mismo cálculo (empuje en reposo por estratos + fuerza de la coronación − excentricidad del peso) repetido en cada profundidad z bajo la coronación da los diagramas de **momento** y **cortante** del fuste. El empotramiento en la zapata (z = 5.00 m) es donde valen más: ahí se arma. Los puntos de GEO5 son su resultado en la junta a 5.00 m.
Pm = [t_f; n_f; gamma_c; t_1; t_2; g_1; g_2; g_3; K_01; K_02; K_03; F_1; a_F] 'datos del fuste juntos
#hide
function R = mvz(z, Pm)
  t_f = Pm(1)
  n_f = Pm(2)
  gc = Pm(3)
  t1 = Pm(4)
  t2 = Pm(5)
  g1 = Pm(6)
  g2 = Pm(7)
  g3 = Pm(8)
  k1 = Pm(9)
  k2 = Pm(10)
  k3 = Pm(11)
  Fc = Pm(12)
  aF = Pm(13)
  d1 = min(z, t1)
  F1 = k1*g1*d1*d1/2
  dep1 = 2*d1/3
  d2 = max(min(z - t1, t2), 0)
  st2 = k2*g1*t1
  sb2 = k2*(g1*t1 + g2*d2)
  F2 = (st2 + sb2)/2*d2
  dep2 = t1 + d2*(st2 + 2*sb2)/(3*max(st2 + sb2, 0.000000001))
  d3 = max(z - t1 - t2, 0)
  st3 = k3*(g1*t1 + g2*t2)
  sb3 = k3*(g1*t1 + g2*t2 + g3*d3)
  F3 = (st3 + sb3)/2*d3
  dep3 = t1 + t2 + d3*(st3 + 2*sb3)/(3*max(st3 + sb3, 0.000000001))
  P = F1 + F2 + F3
  M = F1*(z - dep1) + F2*(z - dep2) + F3*(z - dep3)
  h = t_f + z/n_f
  Ar = t_f*z
  At = (h - t_f)*z/2
  W = gc*(Ar + At)
  xW = (Ar*t_f/2 + At*(t_f + (h - t_f)/3))/max(Ar + At, 0.000000001)
  R = [M + Fc*(z + aF) - W*(h/2 - xW); P + Fc]
end
Mv = zeros(26, 2)
Vv = zeros(26, 2)
for j = 1:26
  zj = (j - 1)*0.2
  Rj = mvz(zj, Pm)
  Mv(j, 1) = zj
  Mv(j, 2) = Rj(1)
  Vv(j, 1) = zj
  Vv(j, 2) = Rj(2)
end
#show
R_j = mvz(H_j, Pm) 'comprobación: la función en la junta da [M_Ed; V_Ed]
#fplot(Momento = Mv, Cortante = Vv, GEO5M = [5 348.11], GEO5V = [5 148.8], [0 5])
#: Eje x: profundidad z bajo la coronación [m]; eje y: momento M [kN·m/m] y cortante V [kN/m]. El momento crece **más que lineal** con la profundidad (el empuje del suelo crece con z y su brazo también): por eso la sección crítica es siempre el arranque.

## 5 · La sección de hormigón armado (EN 1992-1-1)

#: Resistencias de cálculo, la armadura dada y el canto útil:
f_cd = f_ck/g_cc 'resistencia de cálculo del hormigón (α_{cc} = 1) [MPa]
f_yd = f_yk/g_ss 'resistencia de cálculo del acero [MPa]
A_s = n_b·pi·d_b^2/4 'armadura trasera por metro [mm2]
d_u = h_s - (r_c + d_b/2)/1000 'canto útil [m]
#: **Cuantía** y la mínima de EN 1992 (9.2.1.1: 0.26·f_{ctm}/f_{yk}, y no menos de 0.0013):
rho = A_s/(1000·b_w·1000·d_u) 'cuantía geométrica
rho_min = max(0.26·f_ctm/f_yk, 0.0013) 'cuantía mínima
#: **Eje neutro** con el bloque rectangular (λ = 0.8, η = 1): la compresión del hormigón iguala a la tracción del acero. Su límite es el que deja al acero fluir: x ≤ ε_{cu3}/(ε_{cu3} + f_{yd}/E_{s})·d, con ε_{cu3} = 0.0035 y E_{s} = 200 GPa:
x_n = A_s·f_yd/(0.8·b_w·1000·f_cd)/1000 'profundidad del eje neutro [m]
x_max = 0.0035/(0.0035 + f_yd/200000)·d_u 'eje neutro máximo [m]
#: **Momento resistente**: la fuerza del acero por el brazo d − 0.4·x:
M_Rd = A_s·f_yd·(d_u - 0.4·x_n)/1000 'momento resistente [kN·m/m]
#: **Cortante sin armadura de corte** (EN 1992, 6.2.2): V_{Rd,c} = C_{Rd,c}·k·(100·ρ·f_{ck})^{1/3}·b·d, con C_{Rd,c} = 0.18/γ_{c} y k = 1 + √(200/d[mm]) ≤ 2:
k_v = min(2, 1 + sqrt(200/(1000·d_u))) 'factor de tamaño k
V_Rd = 0.18/g_cc·k_v·(100·rho·f_ck)^(1/3)·1000·b_w·d_u 'cortante resistente [kN/m]
#: **Armadura requerida**: la A_{s} que da M_{Rd} = M_{Ed}. Con x = A_{s}·f_{yd}/(0.8·b·f_{cd}) queda una ecuación de segundo grado en A_{s}, a·A_{s}² − f_{yd}·d·A_{s} + M_{Ed} = 0 (unidades: m², kN y m), y se toma la raíz pequeña:
a_q = 0.4·(1000·f_yd)^2/(0.8·b_w·1000·f_cd) 'coeficiente de A_s² [kN/m3]
A_req = (1000·f_yd·d_u - sqrt((1000·f_yd·d_u)^2 - 4·a_q·M_Ed))/(2·a_q)·1000000 'armadura requerida [mm2]
#hide
r_us = round(100·M_Ed/M_Rd, 1)
r_uv = round(100·V_Ed/V_Rd, 1)
#show
#: **Lectura.** La flexión usa el @{r_us} % de la sección y el cortante el @{r_uv} %: la sección cumple con holgura. GEO5 marca «NOT OK. (1000 %)» en la flexión por OTRA sección, la de 1.57 m bajo la coronación, donde corta la armadura: allí el canto es 0.33 m y las mismas 14 Ø 20 dan x > x_{max} («too much reinforcement»), una sección sobrearmada.

As_t = round(A_s, 0) 'armadura, para el rótulo
ME_t = round(M_Ed, 1) 'momento de diseño, para el rótulo
MR_t = round(M_Rd, 1) 'momento resistente, para el rótulo
xn_t = round(x_n, 3) 'eje neutro, para el rótulo
yb_ = linspace(1/28, 1 - 1/28, 14) 'posición de las 14 barras a lo largo del metro
#: **La sección armada, a escala.** Corte horizontal del fuste a la altura de la junta (0.60 m de espesor) por una franja de 1 m de largo. La cara delantera (izquierda) comprime; la **trasera** (derecha), traccionada, lleva las 14 barras Ø20 por metro, a 30 mm de recubrimiento. El **eje neutro** (línea a trazos) queda a x = @{xn_t} m de la cara comprimida: es la profundidad del bloque de hormigón que equilibra la tracción del acero. El **canto útil** d es la distancia de la cara comprimida al centro de las barras.
#dibujo("Sección del arranque: 14 Ø20 por metro en la cara trasera, recubrimiento 30 mm, eje neutro y canto útil", ud = m, escala = auto, cotas = m, alto = 200)
#  rect(0, 0, h_s, 1, "gruesa")
#  circulo(h_s - (r_c + d_b/2)/1000, yb_, d_b/2000, "acero relleno")
#  linea(x_n, 0, x_n, 1, "trazos")
#  texto(x_n + 0.02, 0.5, "eje neutro", 2.5, "i")
#  texto(0.05, 0.9, "cara delantera (compresión)", 2.5, "i")
#  texto(h_s + 0.25, 0.5, "cara trasera (tracción)", 2.5, "i")
#  cota(0, -0.12, h_s, -0.12, -0.05, "0.60")
#  cota(0, 1.12, d_u, 1.12, 0.05, "d")
#  cota(h_s - (r_c + d_b/2)/1000, 1.12, h_s, 1.12, 0.05, "0.04")
#  cota(h_s + 0.15, 0, h_s + 0.15, 1/14, 0.05, "7.1 cm")
#fin
#: **Cómo se lee.** Cada círculo es una barra Ø20 (área 314 mm²); 14 barras por metro dan A_{s} = @{As_t} mm². Con el momento de diseño M_{Ed} = @{ME_t} kN·m/m, la resistencia M_{Rd} = @{MR_t} kN·m/m deja la sección holgada; GEO5 marca «NOT OK» por otra sección (a 1.57 m de la coronación) que esta hoja no reproduce.

## 6 · Hekatan contra GEO5

#hide
g_P0 = 118.80
g_z0 = 1.65
g_W = 45.98
g_ME = 348.11
g_VE = 148.80
g_As = 4398.2
g_Ar = 1495.1
g_rho = 0.79
g_rmin = 0.13
g_x = 0.18
g_xm = 0.35
g_VR = 268.85
g_MR = 933.56
h_P0 = round(P_0, 2)
h_z0 = round(z_0, 2)
h_W = round(W_f, 2)
h_ME = round(M_Ed, 2)
h_VE = round(V_Ed, 2)
h_As = round(A_s, 1)
h_Ar = round(A_req, 1)
h_rho = round(100·rho, 2)
h_rmin = round(100·rho_min, 2)
h_x = round(x_n, 2)
h_xm = round(x_max, 2)
h_VR = round(V_Rd, 2)
h_MR = round(M_Rd, 2)
x_P0 = round(100·(h_P0/g_P0 - 1), 3)
x_z0 = round(100·(h_z0/g_z0 - 1), 3)
x_Wd = round(100·(h_W/g_W - 1), 3)
x_ME = round(100·(h_ME/g_ME - 1), 3)
x_VE = round(100·(h_VE/g_VE - 1), 3)
x_As = round(100·(h_As/g_As - 1), 3)
x_Ar = round(100·(h_Ar/g_Ar - 1), 3)
x_rho = round(100·(h_rho/g_rho - 1), 3)
x_rmin = round(100·(h_rmin/g_rmin - 1), 3)
x_x = round(100·(h_x/g_x - 1), 3)
x_xm = round(100·(h_xm/g_xm - 1), 3)
x_VR = round(100·(h_VR/g_VR - 1), 3)
x_MR = round(100·(h_MR/g_MR - 1), 3)
#show
#| Magnitud | Hekatan (junta a 5.00 m) | GEO5 2024 | Diferencia [%] |
#|---|---:|---:|---:|
#| empuje en reposo P₀ [kN/m] | @{h_P0} | @{g_P0} | @{x_P0} |
#| su altura sobre la junta [m] | @{h_z0} | @{g_z0} | @{x_z0} |
#| peso del fuste [kN/m] | @{h_W} | @{g_W} | @{x_Wd} |
#| **M_{Ed} [kN·m/m]** | @{h_ME} | @{g_ME} | @{x_ME} |
#| **V_{Ed} [kN/m]** | @{h_VE} | @{g_VE} | @{x_VE} |
#| A_{s} dada [mm²] | @{h_As} | @{g_As} | @{x_As} |
#| A_{s} requerida [mm²] | @{h_Ar} | @{g_Ar} | @{x_Ar} |
#| ρ [%] | @{h_rho} | @{g_rho} | @{x_rho} |
#| ρ_{min} [%] | @{h_rmin} | @{g_rmin} | @{x_rmin} |
#| eje neutro x [m] | @{h_x} | @{g_x} | @{x_x} |
#| x_{max} [m] | @{h_xm} | @{g_xm} | @{x_xm} |
#| **V_{Rd} [kN/m]** | @{h_VR} | @{g_VR} | @{x_VR} |
#| **M_{Rd} [kN·m/m]** | @{h_MR} | @{g_MR} | @{x_MR} |

#: **Lo que no cuadra a cuatro cifras: la profundidad de la junta.** Con la junta a 5.00 m, P₀, el peso, M_{Ed}, V_{Ed} y M_{Rd} se pasan de GEO5 entre un 0.02 % y un 0.06 %. Los cinco a la vez —y también A_{s} requerida y V_{Rd}— cierran exactos si la sección está **1.25 mm más arriba**, a 4.99875 m (canto 0.5999 m en vez de 0.6000). Se comprueba abajo con esa profundidad. GEO5 imprime «5.00 m from the wall crest» y la regla que mueve la sección no está en la ayuda: **pendiente de sacar de CantileverWall_5.dll**. La comprobación de abajo **no es el cálculo de la hoja**, es la prueba de la hipótesis.
H_h = 4.99875 'profundidad de la junta que cuadra con GEO5 (hipótesis, sin ver en el binario) [m]
h_sh = t_f + H_h/n_f 'canto con esa profundidad [m]
t_3h = H_h - t_1 - t_2 'suelo 3 sobre esa junta [m]
P_0h = P_1 + P_2r + P_2t + K_03·s_v2·t_3h + K_03·g_3·t_3h^2/2 'P₀ con la junta a 4.99875 m [kN/m]
A_th = (h_sh - t_f)·H_h/2 'cuña delantera con esa altura [m2]
W_fh = gamma_c·(t_f·H_h + A_th) 'peso con esa altura [kN/m]
x_Wh = (t_f·H_h·t_f/2 + A_th·(t_f + (h_sh - t_f)/3))/(t_f·H_h + A_th) 'centroide desde la cara trasera [m]
M_0h = P_1·(t_2 + t_3h + t_1/3) + P_2r·(t_3h + t_2/2) + P_2t·(t_3h + t_2/3) + K_03·s_v2·t_3h·t_3h/2 + K_03·g_3·t_3h^2/2·t_3h/3 'momento del empuje [kN·m/m]
M_Edh = M_0h + F_1·(H_h + a_F) - W_fh·(h_sh/2 - x_Wh) 'M_Ed con la junta a 4.99875 m [kN·m/m]
d_uh = h_sh - (r_c + d_b/2)/1000 'canto útil [m]
M_Rdh = A_s·f_yd·(d_uh - 0.4·x_n)/1000 'M_Rd con ese canto [kN·m/m]
#hide
k1 = round(P_0h, 2)
k2 = round(W_fh, 2)
k3 = round(M_Edh, 2)
k4 = round(P_0h + F_1, 2)
k5 = round(M_Rdh, 2)
#show
#: Con la junta a 4.99875 m: P₀ = @{k1} (GEO5 118.80), peso @{k2} (45.98), M_{Ed} = @{k3} (348.11), V_{Ed} = @{k4} (148.80), M_{Rd} = @{k5} (933.56).
#: **No se reproduce aquí** (pendiente): el chequeo de la puntera («Wall jump check», 6 Ø 16, A_{s} requerida 730.6 mm²) y del talón («Wall heel check»): necesitan el reparto de presiones bajo la base que GEO5 usa para dimensionar, que no está en las capturas.

## 7 · NEC

#: La NEC-SE-GC 2015 no trata el armado del fuste: remite a la NEC-SE-HM (hormigón armado, que sigue al ACI 318-19). GEO5 en este ejemplo verifica con EN 1992 y cargas sin mayorar (coeficientes 1.000), así que **este armado no es un diseño NEC**: con la NEC-SE-HM el empuje de tierras se mayora (1.6·H en la combinación 1.2·D + 1.6·L + 1.6·H) y la resistencia se reduce (φ = 0.90 en flexión, 0.75 en cortante, bloque 0.85·f'_{c}). Ese diseño queda para una hoja ACI aparte; aquí solo se reproduce GEO5.
