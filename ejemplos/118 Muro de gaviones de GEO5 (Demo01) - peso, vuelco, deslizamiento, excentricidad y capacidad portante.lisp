# Muro de gaviones del ejemplo oficial de GEO5: vuelco, deslizamiento y capacidad portante
#numerico

#: **Qué se calcula.** El muro de gaviones del ejemplo oficial de GEO5 Gabion (**Demo01.gga**): seis bloques de 1.00 m de alto, escalonados por detrás (3.50, 3.50, 2.50, 2.50, 2.00 y 1.00 m de ancho), con un terraplén 1:5 detrás y una sobrecarga trapecial. Se repite lo que GEO5 imprime en «Verification» (muro completo: **vuelco** y **deslizamiento**) y en «Bearing cap.» (**excentricidad** y **presión en la base**).
#: **Qué es cálculo de Hekatan y qué es dato.** El peso del muro, los momentos, las fuerzas en la base, la excentricidad, la presión y los factores de seguridad se calculan aquí. El **empuje activo, la cuña de tierra y la resistencia frontal** NO: entran con el valor que GEO5 guarda en el propio archivo Demo01.gga (sus resultados, con todos los decimales; a dos decimales son los que muestra GEO5 2024). Cómo los calcula GEO5 con el terreno quebrado y la sobrecarga está **pendiente** (sección 7).
#: **Juez.** Las ventanas «In detail» de GEO5 2024 con el Demo01 abierto (capturas del 2 de octubre).
#: **Unidades.** kN, m y kPa por metro de muro, como GEO5 (1 tonf = 9.80665 kN; los resultados principales se repiten en tonf).

## 1 · Datos del ejemplo (Demo01.gga)

#: **Geometría** (marco Geometry): los bloques se numeran de abajo arriba, todos de 1.00 m de alto, frente vertical (sin desplazamiento, inclinación α = 0). Abscisa x desde el frente, y desde la base.
h_b = 1 'alto de cada bloque [m]
b_1 = 3.5 'ancho del bloque 1 (el de la base) [m]
b_2 = 3.5 'ancho del bloque 2 [m]
b_3 = 2.5 'ancho del bloque 3 [m]
b_4 = 2.5 'ancho del bloque 4 [m]
b_5 = 2 'ancho del bloque 5 [m]
b_6 = 1 'ancho del bloque 6 (la coronación) [m]
#: **Relleno de los gaviones** (marco Material, «Material No. 1»): piedra suelta.
gamma_g = 17 'peso específico del relleno de piedra [kN/m3]
#: **El suelo de apoyo** es el suelo 2 del perfil. Sus parámetros no salen en las capturas: se leyeron del propio archivo Demo01.gga (registro de suelos, mismo formato que el .guz del muro, comprobado con los suelos conocidos de aquél).
p_2 = 30 'ángulo de rozamiento del suelo 2, bajo la base [grados]
c_2 = 5 'cohesión del suelo 2 [kPa]
#: **Lo que exige GEO5 en este ejemplo** (Settings, «Safety factors (ASD)», permanente): vuelco 1.50, deslizamiento 1.50, portante 1.00; excentricidad ≤ 0.333. La capacidad del suelo se da a mano: 210 kPa.
R_d = 210 'capacidad portante del suelo de apoyo, dato del ejemplo [kPa]
e_adm = 0.333 'excentricidad relativa admisible (GEO5)
#: **El coeficiente del empuje activo.** En la tabla «Verification» del ejemplo la fila del empuje activo lleva **Coeff. = 0.500** (celda editable): GEO5 multiplica sus dos componentes por 0.5 en el muro completo. Las demás filas van con 1.000.
k_a = 0.5 'coeficiente que el ejemplo aplica al empuje activo (dato de GEO5)

## 2 · El peso del muro

#: Cada bloque es un rectángulo b_{i} × h: su peso es γ·b_{i}·h, su centro está en x = b_{i}/2 (el frente es común) y a y = (i − ½)·h:
S_b = b_1 + b_2 + b_3 + b_4 + b_5 + b_6 'suma de anchos [m]
W_g = gamma_g·h_b·S_b 'peso del muro [kN/m]
x_g = (b_1^2 + b_2^2 + b_3^2 + b_4^2 + b_5^2 + b_6^2)/(2·S_b) 'brazo del peso desde el frente [m]
y_g = h_b·(0.5·b_1 + 1.5·b_2 + 2.5·b_3 + 3.5·b_4 + 4.5·b_5 + 5.5·b_6)/S_b 'altura del centroide [m]

## 3 · Las otras fuerzas (datos de GEO5)

#: **Resistencia frontal** (FF resistance: «at rest», suelo 2, 0.70 m delante, terreno a −15°). Del archivo:
F_ff = 2.032927794697164 'resistencia frontal, horizontal hacia el relleno [kN/m]
y_ff = 0.2333333333333334 'su altura sobre la base (h/3 de 0.70 m) [m]
#: **Peso de la cuña de tierra**: el suelo atrapado entre los escalones de atrás y la cara virtual que GEO5 traza desde el talón del bloque 2 («Shape of earth wedge: Calculate as skew»). Del archivo:
W_c = 41.475906954262925 'peso de la cuña de tierra [kN/m]
x_c = 2.1803341781082652 'su brazo desde el frente [m]
y_c = 4.010443407184867 'su altura [m]
#: **Empuje activo** (Coulomb, según Settings), sobre la cara virtual y el trasdós del bloque 1 y 2. Del archivo:
E_ax = 112.33693811838292 'empuje activo horizontal, hacia el frente [kN/m]
E_az = 97.16598840898497 'empuje activo vertical, hacia abajo [kN/m]
x_a = 3.0097710623577343 'brazo de la componente vertical [m]
y_a = 2.1050260766684157 'altura de la componente horizontal [m]
#: **La sobrecarga trapecial** (10 → 20 kPa sobre 3.00 m, a 4.50 m de la coronación). Aquí el archivo NO sirve: guarda 9.37 / 7.82 kN/m, que es lo que calculaba GEO5 2020; GEO5 2024 da 9.26 / 7.63. Va el valor de la pantalla de 2024 (dos decimales):
S_x = 9.26 'empuje de la sobrecarga, horizontal [kN/m]
S_z = 7.63 'empuje de la sobrecarga, vertical [kN/m]
x_s = 2.95 'brazo de la componente vertical [m]
y_s = 2.18 'altura de la componente horizontal [m]

#: Para el dibujo: la sobrecarga escalada (1 m = 20 kPa) y el perfil del terreno detrás del muro.
q_a = 10/20 'sobrecarga al inicio, escalada
q_b = 20/20 'sobrecarga al final, escalada
t_x = [1; 5; 9.5] 'abscisas del terreno: coronación, fin del terraplén, borde del dibujo [m]
t_y = [6; 6.8; 6.8] 'cotas del terreno [m]
#dibujo("Demo01.gga: bloques, terraplén 1:5, sobrecarga trapecial y fuerzas (sobrecarga: 1 m = 20 kPa)", ud = m, escala = auto, cotas = m, alto = 170)
#  rect(0, 0, 3.5, 1, "gruesa")
#  rect(0, 1, 3.5, 1, "gruesa")
#  rect(0, 2, 2.5, 1, "gruesa")
#  rect(0, 3, 2.5, 1, "gruesa")
#  rect(0, 4, 2, 1, "gruesa")
#  rect(0, 5, 1, 1, "gruesa")
#  achurado(0, 0, 3.5, 2, "cruzado")
#  achurado(0, 2, 2.5, 2, "cruzado")
#  achurado(0, 4, 2, 1, "cruzado")
#  achurado(0, 5, 1, 1, "cruzado")
#  polilinea(t_x, t_y, "media verde")
#  linea(-2.6, 0, 0, 0.7, "media verde")
#  linea(3.5, 0, 9.5, 0, "media")
#  linea(2.5, 4, 9.5, 4, "trazos")
#  texto(6.5, 5.3, "suelo 1: γ 20, φ 25°, c 9", 2.5, "i")
#  texto(6.5, 2.0, "suelo 2: γ 19, φ 30°, c 5", 2.5, "i")
#  carga(5.5, 6.8, 8.5, 6.8, q_a, q_b, "10 → 20 kPa", "azul", n = 7)
#  flecha(x_g, y_g + 1.0, x_g, y_g, "rojo")
#  texto(x_g + 0.1, y_g + 0.8, "W = 255", 2.5, "i")
#  flecha(x_a + 1.2, y_a + 1.0, x_a, y_a, "azul")
#  texto(x_a + 1.25, y_a + 1.05, "E_{a}", 2.5, "i")
#  flecha(-1.0, y_ff, 0, y_ff, "verde")
#  cota(0, -0.5, 3.5, -0.5, -0.1, "3.50")
#  cota(-0.6, 0, -0.6, 6, 0.1, "6.00")
#fin

## 4 · Vuelco alrededor del frente

#: Igual que en el muro en voladizo: las verticales por su brazo estabilizan, las horizontales hacia delante por su altura vuelcan, y la resistencia frontal **resta** del volcador. El empuje activo entra con su coeficiente 0.5:
M_res = W_g·x_g + W_c·x_c + k_a·E_az·x_a + S_z·x_s 'momento resistente [kN·m/m]
M_ovr = k_a·E_ax·y_a + S_x·y_s - F_ff·y_ff 'momento volcador [kN·m/m]
FS_o = M_res/M_ovr 'factor de seguridad al vuelco

## 5 · Deslizamiento en la base

#: La base es horizontal: la normal es la suma de verticales y la fuerza que desliza la de horizontales. Ayuda de GEO5 (img 1310): H_{res} = N·tan φ + c·(d − 2e), con d el ancho de la base y la cohesión solo en la parte comprimida:
N_b = W_g + W_c + k_a·E_az + S_z 'normal en la base [kN/m]
H_a = k_a·E_ax + S_x - F_ff 'fuerza horizontal que hace deslizar [kN/m]
#: El momento respecto del **centro de la base** es la normal por medio ancho menos lo que sobra de estabilidad; de ahí la excentricidad:
M_b = N_b·b_1/2 - (M_res - M_ovr) 'momento en el centro de la base [kN·m/m]
e_b = M_b/N_b 'excentricidad de la normal [m]
H_res = N_b·tan(p_2·pi/180) + c_2·(b_1 - 2·e_b) 'fuerza resistente [kN/m]
FS_s = H_res/H_a 'factor de seguridad al deslizamiento

## 6 · Excentricidad y capacidad portante

#: Presión uniforme sobre el ancho comprimido b − 2e (GEO5, «Stress in the footing bottom: rectangle»):
e_r = e_b/b_1 'excentricidad relativa
s_b = N_b/(b_1 - 2·e_b) 'presión en la base [kPa]
FS_b = R_d/s_b 'factor de seguridad de la capacidad portante
#hide
t_Mr = round(M_res/9.80665, 2)
t_Mo = round(M_ovr/9.80665, 2)
t_N = round(N_b/9.80665, 2)
t_sb = round(s_b/9.80665, 2)
#show
#: **En tonf:** M_{res} = @{t_Mr} y M_{ovr} = @{t_Mo} tonf·m/m, normal @{t_N} tonf/m, presión @{t_sb} tonf/m².

## 6b · El cuerpo libre: fuerzas, brazos y presión en la base

#: **Cómo se lee el dibujo.** El muro de gaviones (los seis bloques de 1 m de alto, con su relleno de piedra) a escala, en metros, con el origen en el **frente de la base** (el pie del muro): es el punto alrededor del cual vuelca. **Naranja:** el peso propio del muro W y el de la cuña de tierra W_{c}, verticales, en sus centros de gravedad. **Rojo:** el empuje activo E_{a} (con el coeficiente 0.500 que fija el ejemplo) descompuesto en horizontal (empuja hacia el frente) y vertical (hacia abajo), y el empuje de la sobrecarga S. **Verde:** la resistencia del suelo delante del muro, pequeña. **Azul bajo la base:** la presión de apoyo, repartida uniforme en el ancho comprimido b − 2e. Escala de flechas: 1 m = 100 kN; de la presión: 1 m = 100 kPa. Las cotas de abajo son los **brazos** de las fuerzas verticales respecto del frente; las de la izquierda, la **altura** de las horizontales: son los números que multiplican en el vuelco (sección 4).
w_s = b_1 - 2·e_b 'ancho comprimido de la base [m]
r_FSo = round(FS_o, 2) 'FS al vuelco, para el rótulo
r_FSs = round(FS_s, 2) 'FS al deslizamiento, para el rótulo
r_eb = round(e_b, 3) 'excentricidad, para el rótulo
r_ws = round(w_s, 2) 'ancho comprimido, para el rótulo
r_sb = round(s_b, 1) 'presión en la base, para el rótulo
#dibujo("Cuerpo libre del muro de gaviones: fuerzas, brazos respecto del frente y presión en la base", ud = m, escala = auto, cotas = m, ancho = 190, alto = 190)
#  rect(0, 0, 3.5, 1, "gruesa")
#  rect(0, 1, 3.5, 1, "gruesa")
#  rect(0, 2, 2.5, 1, "gruesa")
#  rect(0, 3, 2.5, 1, "gruesa")
#  rect(0, 4, 2, 1, "gruesa")
#  rect(0, 5, 1, 1, "gruesa")
#  achurado(0, 0, 3.5, 2, "cruzado")
#  achurado(0, 2, 2.5, 2, "cruzado")
#  achurado(0, 4, 2, 1, "cruzado")
#  achurado(0, 5, 1, 1, "cruzado")
#  polilinea(t_x, t_y, "media verde")
#  linea(3.5, 0, 9.5, 0, "media")
#  flecha(x_g, y_g + W_g/100, x_g, y_g, "naranja")
#  texto(x_g - 0.1, y_g + W_g/100 + 0.2, "W = 255 kN/m", 2.4, "d", estilo = "naranja")
#  flecha(x_c, y_c + W_c/100, x_c, y_c, "naranja")
#  texto(x_c + 0.1, y_c + W_c/100 + 0.1, "Wc = 41.5", 2.4, "i", estilo = "naranja")
#  flecha(x_a, y_a + k_a·E_az/100, x_a, y_a, "rojo")
#  flecha(x_a + k_a·E_ax/100, y_a, x_a, y_a, "rojo")
#  texto(x_a + k_a·E_ax/100 + 0.1, y_a - 0.1, "0.5·Ea = 56.2 / 48.6", 2.4, "i", estilo = "rojo")
#  flecha(x_s + 0.2, y_s + S_z/100, x_s, y_s, "rojo")
#  flecha(x_s + S_x/100, y_s, x_s, y_s, "rojo")
#  flecha(-F_ff/100 - 0.3, y_ff, 0, y_ff, "verde")
#  carga(w_s, 0, 0, 0, s_b/100, s_b/100, "", "azul", n = 7)
#  texto(w_s/2, -1.3, "presión {r_sb} kPa en {r_ws} m", 2.4, "c", estilo = "azul")
#  cota(0, -1.7, 1.40, -1.7, -0.05, "1.40")
#  cota(0, -2.1, 2.18, -2.1, -0.05, "2.18")
#  cota(0, -2.5, 3.01, -2.5, -0.05, "3.01")
#  cota(0, -2.9, 3.5, -2.9, -0.05, "3.50")
#  cota(-0.6, 0, -0.6, 2.43, 0.1, "2.43")
#  cota(-1.3, 0, -1.3, 2.11, 0.1, "2.11")
#  cota(-2.0, 0, -2.0, 6, 0.1, "6.00")
#fin
#: **Qué dice cada número.** Con los brazos de las cotas, M_{res} = @{t_Mr} tonf·m/m (verticales × brazo) contra M_{ovr} = @{t_Mo} tonf·m/m (horizontales × altura − resistencia frontal): FS al vuelco = @{r_FSo}. El deslizamiento (FS = @{r_FSs}) compara el rozamiento N·tan φ + c·(b − 2e) con la suma de horizontales. La normal se corre e = @{r_eb} m del centro hacia el frente y la presión se concentra en @{r_ws} m de los 3.50 m de la base.

## 7 · Hekatan contra GEO5

#hide
g_W = 255.00
g_xg = 1.40
g_yg = 2.43
g_Mr = 616.19
g_Mo = 137.95
g_FSo = 4.47
g_Hr = 217.19
g_Ha = 63.40
g_FSs = 3.43
g_M = 138.97
g_N = 352.69
g_er = 0.113
g_sb = 130.05
g_FSb = 1.61
h_W = round(W_g, 2)
h_xg = round(x_g, 2)
h_yg = round(y_g, 2)
h_Mr = round(M_res, 2)
h_Mo = round(M_ovr, 2)
h_FSo = round(FS_o, 2)
h_Hr = round(H_res, 2)
h_Ha = round(H_a, 2)
h_FSs = round(FS_s, 2)
h_M = round(M_b, 2)
h_N = round(N_b, 2)
h_er = round(e_r, 3)
h_sb = round(s_b, 2)
h_FSb = round(FS_b, 2)
d_W = round(100·(h_W/g_W - 1), 3)
d_xg = round(100·(h_xg/g_xg - 1), 3)
d_yg = round(100·(h_yg/g_yg - 1), 3)
d_Mr = round(100·(h_Mr/g_Mr - 1), 3)
d_Mo = round(100·(h_Mo/g_Mo - 1), 3)
d_FSo = round(100·(h_FSo/g_FSo - 1), 3)
d_Hr = round(100·(h_Hr/g_Hr - 1), 3)
d_Ha = round(100·(h_Ha/g_Ha - 1), 3)
d_FSs = round(100·(h_FSs/g_FSs - 1), 3)
d_M = round(100·(h_M/g_M - 1), 3)
d_N = round(100·(h_N/g_N - 1), 3)
d_er = round(100·(h_er/g_er - 1), 3)
d_sb = round(100·(h_sb/g_sb - 1), 3)
d_FSb = round(100·(h_FSb/g_FSb - 1), 3)
#show
#| Magnitud | Hekatan | GEO5 2024 | Diferencia [%] |
#|---|---:|---:|---:|
#| peso del muro [kN/m] | @{h_W} | @{g_W} | @{d_W} |
#| su brazo x [m] | @{h_xg} | @{g_xg} | @{d_xg} |
#| su altura [m] | @{h_yg} | @{g_yg} | @{d_yg} |
#| **M_{res} [kN·m/m]** | @{h_Mr} | @{g_Mr} | @{d_Mr} |
#| **M_{ovr} [kN·m/m]** | @{h_Mo} | @{g_Mo} | @{d_Mo} |
#| FS vuelco | @{h_FSo} | @{g_FSo} | @{d_FSo} |
#| **H_{res} [kN/m]** | @{h_Hr} | @{g_Hr} | @{d_Hr} |
#| **H_{act} [kN/m]** | @{h_Ha} | @{g_Ha} | @{d_Ha} |
#| FS deslizamiento | @{h_FSs} | @{g_FSs} | @{d_FSs} |
#| momento en el centro de la base [kN·m/m] | @{h_M} | @{g_M} | @{d_M} |
#| normal en la base [kN/m] | @{h_N} | @{g_N} | @{d_N} |
#| excentricidad relativa | @{h_er} | @{g_er} | @{d_er} |
#| **presión en la base [kPa]** | @{h_sb} | @{g_sb} | @{d_sb} |
#| FS capacidad portante | @{h_FSb} | @{g_FSb} | @{d_FSb} |
#: Diferencias con el valor de Hekatan redondeado a los decimales de GEO5. Lo poco que asoma viene de la sobrecarga, que solo se tiene con dos decimales.
#: **Pendiente (no se ajustó nada):**
#: · **La cuña de tierra.** Una cara recta desde la esquina del bloque 2 (3.50, 2.00) a 64.0° sobre la horizontal da 41.49 kN/m con centroide (2.18, 4.01), lo mismo que GEO5; pero 64.0° sale de ajustar, no de una fórmula. El archivo guarda el punto (2.50001, 4.00), la esquina del bloque 4: una cara quebrada por ahí da el peso pero no el centroide (2.165 frente a 2.180). Hay que sacarlo de Gabion_5.dll.
#: · **El empuje activo.** Coulomb sobre esa cara con el talud de 1:5 (β = 11.31°) da 114.08 / 99.02 kN/m frente a 112.34 / 97.17: un 1.5 % arriba. Falta el reparto de GEO5 para terreno quebrado (terraplén de 4 m y luego horizontal: suma de triángulos, ayuda «Distribution of Earth Pressures in case of Broken Terrain») y la sobrecarga trapecial partida en 10 franjas.
#: · **La resistencia frontal** 2.03 kN/m: K₀ = 1 − sin 30° da 2.33, ν/(1 − ν) da 2.00 y la fórmula de terreno inclinado de la ayuda (img 427) 2.60. Ninguna cierra.
#: · **La sobrecarga**: GEO5 2020 y 2024 dan distinto (9.37 frente a 9.26 kN/m): cambió el algoritmo entre versiones.

## 8 · NEC-SE-GC 2015

#: Los gaviones son muros de gravedad: se les aplica la misma **Tabla 5** (p. 38) que a cualquier muro: estático, deslizamiento ≥ 1.60 y volcamiento ≥ 3.00 **o** e/B ≤ 1/6; pseudoestático 1.05 y 2.00 (e/B ≤ 1/4). Capacidad portante, **Tabla 6** (p. 42): FS ≥ 3.0. Para la malla (SF_{n} de GEO5) la NEC no da valor.
#: **Ojo con el 0.5 del empuje.** El ejemplo de GEO5 rebaja el empuje activo a la mitad en la tabla de verificación; la NEC no prevé ninguna rebaja del empuje: se toma entero. Así que se verifica dos veces: con el 0.5 del ejemplo y con 1.0.
N_1 = W_g + W_c + E_az + S_z 'normal con el empuje entero [kN/m]
M_r1 = W_g·x_g + W_c·x_c + E_az·x_a + S_z·x_s 'momento resistente con el empuje entero [kN·m/m]
M_o1 = E_ax·y_a + S_x·y_s - F_ff·y_ff 'momento volcador con el empuje entero [kN·m/m]
FS_o1 = M_r1/M_o1 'vuelco con el empuje entero
e_1 = (N_1·b_1/2 - (M_r1 - M_o1))/N_1 'excentricidad con el empuje entero [m]
FS_s1 = (N_1·tan(p_2·pi/180) + c_2·(b_1 - 2·e_1))/(E_ax + S_x - F_ff) 'deslizamiento con el empuje entero
s_1 = N_1/(b_1 - 2·e_1) 'presión en la base con el empuje entero [kPa]
FS_b1 = R_d/s_1 'capacidad portante con el empuje entero
#hide
n_o = round(FS_o, 2)
n_s = round(FS_s, 2)
n_e = round(e_r, 3)
n_b = round(FS_b, 2)
n_o1 = round(FS_o1, 2)
n_s1 = round(FS_s1, 2)
n_e1 = round(e_1/b_1, 3)
n_b1 = round(FS_b1, 2)
#show
#| Verificación | GEO5 (empuje × 0.5) | Empuje entero | NEC-15 estático | ¿Cumple con el empuje entero? |
#|---|---:|---:|---:|---|
#| Volcamiento M_{R}/M_{A} | @{n_o} | @{n_o1} | 3.00 | **no** (por poco) |
#| Excentricidad e/B | @{n_e} | @{n_e1} | 0.167 | sí |
#| Deslizamiento | @{n_s} | @{n_s1} | 1.60 | sí |
#| Capacidad portante (R_{d} = 210 kPa) | @{n_b} | @{n_b1} | 3.0 | **no** |
#: **Lectura.** Con el empuje entero el vuelco por momentos baja de 4.47 a @{n_o1}: se queda justo debajo del 3.00. La Tabla 5 acepta el vuelco por excentricidad, y e/B = @{n_e1} sí queda dentro de 1/6 (lectura mía de «el que resulte más crítico»; la conservadora exige las dos). El deslizamiento cumple holgado. La capacidad portante no llega al 3.0 de la NEC ni con el 0.5: con 210 kPa como capacidad última la admisible es 70 kPa y la base aprieta más de 130 kPa.
#: **Borrador NEC 2023 (no oficial):** factores de carga y resistencia (empuje activo ×1.50, peso de tierras ×1.35; volteo ΣM_{r}/ΣM_{a} de 1.50 a 1.35) y deslizamiento **sin la resistencia frontal** (aquí 2.03 kN/m, casi nada).
