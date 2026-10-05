# Muro en voladizo del ejemplo oficial de GEO5: empuje, vuelco, deslizamiento y capacidad portante
#numerico

#: **Qué se calcula.** El muro del ejemplo oficial de GEO5 Cantilever Wall (**Demo01.guz**): fuste de 5.00 m sobre una zapata de 4.10 × 0.60 m con dentellón, tres estratos detrás y una fuerza horizontal de 30 kN/m en la coronación. Se repite, número por número, lo que GEO5 imprime en los marcos «Verification» y «Bearing cap.»: las cinco fuerzas, el **vuelco**, el **deslizamiento**, la **excentricidad** y la **presión en la base**.
#: **Cómo.** Empuje activo por **Coulomb** con la rama que usa GEO5, sacada del binario CantileverWall_5.dll (función 0xD9509C): K_{a} con α, β y δ, y la cohesión con K_{ac} = cos φ·cos β·(1 + tan α·tan β)/(1 + sin(φ + δ + α − β)). Detrás del talón GEO5 no empuja contra el fuste: forma una **cuña de tierra** y empuja sobre una cara virtual inclinada («Shape of earth wedge: Calculate as skew»).
#: **Juez.** Las ventanas «In detail» de GEO5 2024 con el Demo01 abierto (capturas del 2 de octubre). Al final, la tabla **Hekatan contra GEO5** con la diferencia en %, y la comprobación con la **NEC-SE-GC 2015**.
#: **Unidades.** kN, m y kPa por metro de muro, como GEO5 (1 tonf = 9.80665 kN; los resultados principales se repiten en tonf). Dentro de las fórmulas los ángulos van en radianes; los datos se escriben en grados.

## 1 · Datos del ejemplo (Demo01.guz)

#: **Geometría.** Abscisa x desde la punta de la puntera hacia el relleno; ordenada y desde el fondo de la zapata hacia arriba (GEO5 imprime z = −y).
B_z = 4.1 'ancho de la zapata [m]
h_z = 0.6 'canto de la zapata [m]
x_p = 1 'puntera: de la punta a la cara delantera del fuste, abajo [m]
b_f = 0.6 'espesor del fuste abajo [m]
t_f = 0.2 'espesor del fuste en la coronación [m]
H_f = 5 'altura del fuste sobre la zapata [m]
x_t = x_p + b_f 'abscisa de la cara trasera del fuste (vertical) [m]
L_t = B_z - x_t 'talón: vuelo detrás del fuste [m]
y_s = h_z + H_f 'cota del terreno detrás del muro = coronación [m]
b_d = 0.5 'ancho del dentellón, bajo el extremo del talón [m]
h_d = 0.2 'alto del dentellón [m]
gamma_c = 23 'peso específico del hormigón (marco Material) [kN/m3]
#: **Los tres estratos** (marcos Profile, Soils y Assign): espesores desde la coronación 2.30 m, 1.70 m y el resto. δ es el rozamiento suelo-estructura.
y_12 = y_s - 2.3 'cota del contacto suelo 1 / suelo 2 [m]
y_23 = y_12 - 1.7 'cota del contacto suelo 2 / suelo 3 [m]
g_1 = 19 'peso específico del suelo 1 [kN/m3]
p_1 = 29 'ángulo de rozamiento del suelo 1 [grados]
c_1 = 10 'cohesión del suelo 1 [kPa]
g_2 = 17.5 'peso específico del suelo 2 [kN/m3]
p_2 = 31.5 'ángulo de rozamiento del suelo 2 [grados]
c_2 = 0 'cohesión del suelo 2 [kPa]
g_3 = 19.5 'peso específico del suelo 3 [kN/m3]
p_3 = 27 'ángulo de rozamiento del suelo 3 (también bajo la base) [grados]
c_3 = 10 'cohesión del suelo 3 [kPa]
d_s = 15 'rozamiento suelo-estructura δ de los tres suelos [grados]
#: **Delante del muro** (marco FF resistance): 0.50 m del suelo 1, resistencia «at rest» (en reposo), sin sobrecarga.
h_ff = 0.5 'espesor del suelo delante, sobre el fondo de la zapata [m]
#: **La fuerza aplicada** (marco Applied forces, «Force No. 1»): 30 kN/m hacia delante, a 0.20 m sobre la coronación, en el eje del fuste.
F_1 = 30 'fuerza horizontal en la coronación, hacia la puntera [kN/m]
x_F = 1.5 'abscisa de la fuerza [m]
y_F = 5.8 'cota de la fuerza [m]
#: **Lo que exige GEO5 en este ejemplo** (Settings, «Safety factors (ASD)»): vuelco 1.50, deslizamiento 1.50, portante 1.00 y excentricidad ≤ 0.333. La capacidad del suelo se da a mano: 180 kPa.
SF_o = 1.5 'factor pedido al vuelco (GEO5)
SF_s = 1.5 'factor pedido al deslizamiento (GEO5)
R_d = 180 'capacidad portante del suelo de apoyo, dato del ejemplo [kPa]
e_adm = 0.333 'excentricidad relativa admisible (GEO5)

## 2 · El peso del muro, por partes

#: El muro se parte en cuatro figuras simples: la zapata (rectángulo), el dentellón (rectángulo), el fuste recto de 0.20 m (rectángulo) y la cuña delantera del fuste (triángulo de 0.40 × 5.00 m). Área por figura y su centroide:
A_1 = B_z·h_z 'zapata [m2]
A_2 = b_d·h_d 'dentellón [m2]
A_3 = t_f·H_f 'fuste recto, del ancho de la coronación [m2]
A_4 = (b_f - t_f)·H_f/2 'cuña delantera del fuste [m2]
A_m = A_1 + A_2 + A_3 + A_4 'área total de la sección [m2]
W_m = gamma_c·A_m 'peso del muro [kN/m]
#: El centroide de cada figura (el del triángulo está a un tercio de sus catetos) y el del conjunto, ponderando por áreas:
x_m = (A_1·B_z/2 + A_2·(B_z - b_d/2) + A_3·(x_t - t_f/2) + A_4·(x_p + 2·(b_f - t_f)/3))/A_m 'brazo horizontal del peso [m]
y_m = (A_1·h_z/2 - A_2·h_d/2 + A_3·(h_z + H_f/2) + A_4·(h_z + H_f/3))/A_m 'altura del centroide [m]

## 3 · La resistencia delante del muro (empuje en reposo)

#: GEO5 cuenta el suelo de delante «at rest»: K₀ = 1 − sin φ (ayuda de GEO5, «Pressure at Rest», suelo no cohesivo) sobre 0.50 m del suelo 1. Es un triángulo de presiones, resultante a un tercio de su altura:
K_0 = 1 - sin(p_1·pi/180) 'coeficiente de empuje en reposo del suelo 1
E_ff = K_0·g_1·h_ff^2/2 'resistencia frontal [kN/m]
y_ff = h_ff/3 'altura de su resultante sobre el fondo [m]
#: Esta fuerza empuja hacia el relleno, contra el vuelco y contra el deslizamiento.

## 4 · La cuña de tierra detrás del fuste

#: Ayuda de GEO5, «Earth - Pressure Wedge»: cuando el muro tiene un talón, el empuje no se calcula sobre la cara del fuste sino sobre una **cara virtual** que sale del extremo del talón y sube hasta tocar el fuste. El suelo de la cuña (fuste, talón y cara virtual) viaja con el muro: **su peso es una fuerza estabilizadora**.
#: **El ángulo de la cara virtual.** Aquí va 45° + φ̄/2 sobre la horizontal, con φ̄ = la media de φ ponderada por espesor sobre los 5.00 m del fuste. **Esto es una hipótesis que cuadra con GEO5, no se vio en el binario** (ver sección 10): la ayuda describe otro procedimiento, capa por capa, que no da estos números.
p_m = (2.3·p_1 + 1.7·p_2 + (H_f - 4)·p_3)/H_f 'φ medio sobre la altura del fuste [grados]
th = (45 + p_m/2)·pi/180 'inclinación de la cara virtual sobre la horizontal [rad]
y_T = h_z + L_t·tan(th) 'cota donde la cara virtual corta al fuste [m]
h_c = y_T - h_z 'altura de la cuña [m]
a_v = pi/2 - th 'inclinación de la cara virtual respecto de la vertical, α [rad]
#: El ancho de la cuña baja linealmente de L_{t} (sobre el talón) a cero (en y_{T}); el suelo cambia en y_{12} y en y_{23}, así que el peso se integra por estratos:
w_c(y) = L_t·(1 - (y - h_z)/h_c)
W_c3 = g_3·integral(@(y) w_c(y), h_z, y_23) 'peso de la cuña en el suelo 3 [kN/m]
W_c2 = g_2·integral(@(y) w_c(y), y_23, y_12) 'peso de la cuña en el suelo 2 [kN/m]
W_c1 = g_1·integral(@(y) w_c(y), y_12, y_T) 'peso de la cuña en el suelo 1 [kN/m]
W_c = W_c1 + W_c2 + W_c3 'peso de la cuña [kN/m]
#: El centroide sale de las mismas integrales con el brazo dentro (la franja a la altura y tiene su centro en x_{t} + w/2):
x_c = (g_3·integral(@(y) w_c(y)·(x_t + w_c(y)/2), h_z, y_23) + g_2·integral(@(y) w_c(y)·(x_t + w_c(y)/2), y_23, y_12) + g_1·integral(@(y) w_c(y)·(x_t + w_c(y)/2), y_12, y_T))/W_c 'brazo horizontal de la cuña [m]
y_c = (g_3·integral(@(y) w_c(y)·y, h_z, y_23) + g_2·integral(@(y) w_c(y)·y, y_23, y_12) + g_1·integral(@(y) w_c(y)·y, y_12, y_T))/W_c 'altura del centroide de la cuña [m]

## 5 · El empuje activo de Coulomb

#: **La presión vertical** a la cota y: cada estrato pesa su γ por el espesor que tiene encima de y.
s_z(y) = g_1·(y_s - max(y, y_12)) + g_2·max(0, y_12 - max(y, y_23)) + g_3·max(0, y_23 - y)
#: **Los coeficientes de Coulomb** (binario de GEO5, 0xD9509C, con el terreno horizontal β = 0). φ, δ y α en radianes; α es la inclinación de la cara respecto de la vertical:
K_a(f, d, a) = cos(f - a)^2/(cos(a)^2·cos(a + d)·(1 + sqrt(sin(f + d)·sin(f)/(cos(a + d)·cos(a))))^2)
K_ac(f, d, a) = cos(f)/(1 + sin(f + d + a))
#: y la presión activa, σ_{a} = σ_{z}·K_{a} − 2·c·K_{ac}, sin bajar de cero (donde da negativa el suelo se despega: grieta de tracción).
#: **Tres caras empujan**: (S1) el fuste por encima de la cuña, con δ = 15°; (S2) la cara virtual, suelo contra suelo, con **δ = φ**; (S3) la cara vertical del extremo del talón hasta el fondo del dentellón, con δ = 15°. La S2 cruza los tres estratos, así que se parte en S2a, S2b y S2c. En cada tramo la presión es lineal: la resultante es el área del trapecio y su altura, la de su centroide.
r_g = pi/180 'grados a radianes

#: **S1 · fuste, de y_{s} a y_{T}** (suelo 1):
K_1 = K_a(p_1·r_g, d_s·r_g, 0) 'K_a en S1
k_1 = K_ac(p_1·r_g, d_s·r_g, 0) 'K_ac en S1
s_1a = K_1·s_z(y_s) - 2·c_1·k_1 'σ_a arriba de S1 [kPa]
s_1b = K_1·s_z(y_T) - 2·c_1·k_1 'σ_a abajo de S1 [kPa]
#: Las dos salen **negativas**: con c = 10 kPa el suelo 1 se sostiene solo en esos 0.72 m y no empuja. S1 aporta cero.

#: **S2a · cara virtual en el suelo 1, de y_{T} a y_{12}** (δ = φ₁):
K_2a = K_a(p_1·r_g, p_1·r_g, a_v) 'K_a en S2a
k_2a = K_ac(p_1·r_g, p_1·r_g, a_v) 'K_ac en S2a
s_2a = K_2a·s_z(y_T) - 2·c_1·k_2a 'σ_a arriba [kPa]
s_2b = K_2a·s_z(y_12) - 2·c_1·k_2a 'σ_a abajo [kPa]
E_2a = (s_2a + s_2b)/2·(y_T - y_12) 'resultante del tramo [kN/m]
z_2a = y_12 + (y_T - y_12)·(2·s_2a + s_2b)/(3·(s_2a + s_2b)) 'cota de la resultante [m]

#: **S2b · cara virtual en el suelo 2, de y_{12} a y_{23}** (δ = φ₂, c₂ = 0):
K_2b = K_a(p_2·r_g, p_2·r_g, a_v) 'K_a en S2b
k_2b = K_ac(p_2·r_g, p_2·r_g, a_v) 'K_ac en S2b
s_3a = K_2b·s_z(y_12) - 2·c_2·k_2b 'σ_a arriba [kPa]
s_3b = K_2b·s_z(y_23) - 2·c_2·k_2b 'σ_a abajo [kPa]
E_2b = (s_3a + s_3b)/2·(y_12 - y_23) 'resultante del tramo [kN/m]
z_2b = y_23 + (y_12 - y_23)·(2·s_3a + s_3b)/(3·(s_3a + s_3b)) 'cota de la resultante [m]

#: **S2c · cara virtual en el suelo 3, de y_{23} al talón** (δ = φ₃):
K_2c = K_a(p_3·r_g, p_3·r_g, a_v) 'K_a en S2c
k_2c = K_ac(p_3·r_g, p_3·r_g, a_v) 'K_ac en S2c
s_4a = K_2c·s_z(y_23) - 2·c_3·k_2c 'σ_a arriba [kPa]
s_4b = K_2c·s_z(h_z) - 2·c_3·k_2c 'σ_a abajo [kPa]
E_2c = (s_4a + s_4b)/2·(y_23 - h_z) 'resultante del tramo [kN/m]
z_2c = h_z + (y_23 - h_z)·(2·s_4a + s_4b)/(3·(s_4a + s_4b)) 'cota de la resultante [m]

#: **S3 · cara vertical del extremo del talón, del talón al fondo del dentellón** (suelo 3, δ = 15°):
K_3 = K_a(p_3·r_g, d_s·r_g, 0) 'K_a en S3
k_3 = K_ac(p_3·r_g, d_s·r_g, 0) 'K_ac en S3
s_5a = K_3·s_z(h_z) - 2·c_3·k_3 'σ_a arriba [kPa]
s_5b = K_3·s_z(-h_d) - 2·c_3·k_3 'σ_a abajo [kPa]
E_3 = (s_5a + s_5b)/2·(h_z + h_d) 'resultante del tramo [kN/m]
z_3 = -h_d + (h_z + h_d)·(2·s_5a + s_5b)/(3·(s_5a + s_5b)) 'cota de la resultante [m]

#: **Componentes.** Cada resultante se inclina δ + α respecto de la horizontal (ayuda de GEO5: σ_{ax} = σ_{a}·cos(α + δ), σ_{az} = σ_{a}·sin(α + δ)). En la cara virtual, la abscisa de cada resultante está sobre la propia cara: x = x_{t} + (y_{T} − z)/tan θ.
u_1 = p_1·r_g + a_v 'δ + α en S2a [rad]
u_2 = p_2·r_g + a_v 'δ + α en S2b [rad]
u_3 = p_3·r_g + a_v 'δ + α en S2c [rad]
u_4 = d_s·r_g 'δ + α en S3 [rad]
E_ax = E_2a·cos(u_1) + E_2b·cos(u_2) + E_2c·cos(u_3) + E_3·cos(u_4) 'empuje activo horizontal [kN/m]
E_az = E_2a·sin(u_1) + E_2b·sin(u_2) + E_2c·sin(u_3) + E_3·sin(u_4) 'empuje activo vertical [kN/m]
y_a = (E_2a·cos(u_1)·z_2a + E_2b·cos(u_2)·z_2b + E_2c·cos(u_3)·z_2c + E_3·cos(u_4)·z_3)/E_ax 'altura del empuje horizontal [m]
x_a = (E_2a·sin(u_1)·(x_t + (y_T - z_2a)/tan(th)) + E_2b·sin(u_2)·(x_t + (y_T - z_2b)/tan(th)) + E_2c·sin(u_3)·(x_t + (y_T - z_2c)/tan(th)) + E_3·sin(u_4)·B_z)/E_az 'brazo del empuje vertical [m]
#hide
r_K1 = round(K_2a, 3)
r_K2 = round(K_2b, 3)
r_K3 = round(K_2c, 3)
r_th = round(th/r_g, 3)
#show
#: **Lectura.** Sobre la cara virtual K_{a} sale @{r_K1}, @{r_K2} y @{r_K3}, el doble que en un muro liso (≈ 0.33): la cara está tumbada (θ = @{r_th}°) y el suelo de encima la carga. A cambio, el empuje llega muy inclinado (δ + α ≈ 60°) y su componente vertical **estabiliza** el muro: es más grande que la horizontal.

#: **Las presiones, dibujadas.** El bloque azul es σ_{a} sobre cada cara (escala: 1 m del dibujo = 25 kPa), perpendicular a la cara; la cuña es la zona rayada.
q_1 = s_2a/25 'σa arriba de S2a, escalada
q_2 = s_2b/25 'σa abajo de S2a, escalada
q_3 = s_3a/25 'σa arriba de S2b, escalada
q_4 = s_3b/25 'σa abajo de S2b, escalada
q_5 = s_4a/25 'σa arriba de S2c, escalada
q_6 = s_4b/25 'σa abajo de S2c, escalada
q_7 = s_5a/25 'σa arriba de S3, escalada
q_8 = s_5b/25 'σa abajo de S3, escalada
x_12 = x_t + (y_T - y_12)/tan(th) 'abscisa de la cara virtual en y12 [m]
x_23 = x_t + (y_T - y_23)/tan(th) 'abscisa de la cara virtual en y23 [m]
#dibujo("Demo01.guz: muro, estratos, cuña de tierra y empuje activo de Coulomb (azul, 1 m = 25 kPa)", ud = m, escala = auto, cotas = m, alto = 190)
#  poligono(0, 0, 3.6, 0, 3.6, -0.2, 4.1, -0.2, 4.1, 0.6, 1.6, 0.6, 1.6, 5.6, 1.4, 5.6, 1.0, 0.6, 0, 0.6, "gruesa")
#  achurado(0, 0, 4.1, 0.6, "concreto")
#  poligono(x_t, h_z, B_z, h_z, x_t, y_T, "verde tenue")
#  linea(x_t, y_T, B_z, h_z, "trazos verde")
#  linea(1.6, 5.6, 7.6, 5.6, "media verde")
#  linea(1.6, y_12, 7.6, y_12, "trazos")
#  linea(1.6, y_23, 7.6, y_23, "trazos")
#  linea(-1.5, 0.5, 0, 0.5, "media verde")
#  texto(5.3, 5.0, "suelo 1: γ 19, φ 29°, c 10", 2.5, "i")
#  texto(5.3, 2.75, "suelo 2: γ 17.5, φ 31.5°, c 0", 2.5, "i")
#  texto(5.3, 1.05, "suelo 3: γ 19.5, φ 27°, c 10", 2.5, "i")
#  carga(x_t, y_T, x_12, y_12, q_1, q_2, "", "azul", n = 5)
#  carga(x_12, y_12, x_23, y_23, q_3, q_4, "", "azul", n = 6)
#  carga(x_23, y_23, B_z, h_z, q_5, q_6, "", "azul", n = 5)
#  carga(B_z, h_z, B_z, -h_d, q_7, q_8, "", "azul", n = 3)
#  flecha(2.9, 5.8, 1.6, 5.8, "rojo")
#  texto(3.0, 5.85, "F = 30 kN/m", 2.5, "i")
#  texto(2.05, 1.5, "cuña", 2.5, "c")
#  cota(0, -0.6, 4.1, -0.6, -0.1, "4.10")
#  cota(-0.5, 0.6, -0.5, 5.6, 0.1, "5.00")
#fin
#: La cara virtual (verde a trazos) corta al fuste a @{r_th}° sobre la horizontal. En el tramo S1 no hay bloque: la presión es negativa y GEO5 la toma como cero.

## 6 · Las cinco fuerzas (la tabla «Verification» de GEO5)

#: Convenio de GEO5: F_{x} negativa hacia la puntera (desestabiliza), F_{z} positiva hacia abajo; x desde la punta, z = −y.
#hide
h_W = round(W_m, 2)
h_xm = round(x_m, 2)
h_ym = round(-y_m, 2)
h_E = round(E_ff, 2)
h_yf = round(-y_ff, 2)
h_Wc = round(W_c, 2)
h_xc = round(x_c, 2)
h_yc = round(-y_c, 2)
h_Ex = round(-E_ax, 2)
h_Ez = round(E_az, 2)
h_xa = round(x_a, 2)
h_ya = round(-y_a, 2)
#show
#| N.º | Fuerza | F_{x} [kN/m] | F_{z} [kN/m] | x [m] | z [m] | GEO5: F_{x} · F_{z} · x · z |
#|---|---|---:|---:|---:|---:|---|
#| 1 | Peso del muro | 0.00 | @{h_W} | @{h_xm} | @{h_ym} | 0.00 · 104.88 · 1.80 · −1.34 |
#| 2 | Resistencia frontal | @{h_E} | 0.00 | 0.00 | @{h_yf} | 1.22 · 0.00 · 0.00 · −0.17 |
#| 3 | Peso de la cuña | 0.00 | @{h_Wc} | @{h_xc} | @{h_yc} | 0.00 · 99.17 · 2.44 · −2.00 |
#| 4 | Empuje activo | @{h_Ex} | @{h_Ez} | @{h_xa} | @{h_ya} | −84.30 · 118.67 · 3.26 · −1.65 |
#| 5 | Force No. 1 | −30.00 | 0.00 | 1.50 | −5.80 | −30.00 · 0.00 · 1.50 · −5.80 |

## 7 · Vuelco alrededor de la punta

#: **Momento resistente**: las fuerzas verticales por su brazo desde la punta. **Momento volcador**: las horizontales que empujan hacia delante por su altura; GEO5 **resta** la resistencia frontal del volcador (no la suma al resistente):
M_res = W_m·x_m + W_c·x_c + E_az·x_a 'momento resistente [kN·m/m]
M_ovr = E_ax·y_a + F_1·y_F - E_ff·y_ff 'momento volcador [kN·m/m]
FS_o = M_res/M_ovr 'factor de seguridad al vuelco

## 8 · Deslizamiento sobre la base inclinada

#: El dentellón hace que GEO5 tome la base como **inclinada**, de la punta (0, 0) al fondo del dentellón (4.10, −0.20) («The base key is considered as inclined footing bottom»). Las fuerzas se proyectan sobre esa recta:
a_b = atan(h_d/B_z) 'inclinación de la base [rad]
L_b = sqrt(B_z^2 + h_d^2) 'largo de la base inclinada [m]
V_t = W_m + W_c + E_az 'suma de verticales [kN/m]
H_t = E_ax + F_1 - E_ff 'suma de horizontales hacia delante [kN/m]
N_b = V_t·cos(a_b) + H_t·sin(a_b) 'normal a la base [kN/m]
T_b = H_t·cos(a_b) - V_t·sin(a_b) 'fuerza que hace deslizar, a lo largo de la base [kN/m]
#: El momento respecto del centro de la base inclinada (B_{z}/2, −h_{d}/2) da la excentricidad; la adherencia c₃ solo actúa en el ancho comprimido L_{b} − 2e:
M_b = W_m·(B_z/2 - x_m) + W_c·(B_z/2 - x_c) + E_az·(B_z/2 - x_a) + E_ax·(y_a + h_d/2) + F_1·(y_F + h_d/2) - E_ff·(y_ff + h_d/2) 'momento en el centro de la base [kN·m/m]
e_b = M_b/N_b 'excentricidad de la normal [m]
H_res = N_b·tan(p_3·r_g) + c_3·(L_b - 2·e_b) 'fuerza resistente: rozamiento + adherencia [kN/m]
FS_s = H_res/T_b 'factor de seguridad al deslizamiento

## 9 · Excentricidad y capacidad portante

#: GEO5 («Bearing cap.», presión «rectangle»): la normal reparte uniforme sobre el ancho comprimido, y la excentricidad se compara relativa al ancho:
e_r = e_b/L_b 'excentricidad relativa (GEO5 la compara con 0.333)
s_b = N_b/(L_b - 2·e_b) 'presión en el fondo, repartida en el ancho efectivo [kPa]
FS_b = R_d/s_b 'factor de seguridad de la capacidad portante
#hide
t_Ea = round(E_ax/9.80665, 2)
t_Mr = round(M_res/9.80665, 2)
t_Mo = round(M_ovr/9.80665, 2)
t_sb = round(s_b/9.80665, 2)
t_Hr = round(H_res/9.80665, 2)
#show
#: **En tonf** (por metro de muro): empuje horizontal @{t_Ea} tonf/m, M_{res} = @{t_Mr} y M_{ovr} = @{t_Mo} tonf·m/m, H_{res} = @{t_Hr} tonf/m, presión en la base @{t_sb} tonf/m².

## 9b · El cuerpo libre: las cinco fuerzas, sus brazos y la presión en la base

#: **Cómo se lee el dibujo.** Es el muro del Demo01 a escala, en metros, con el origen en la **punta** de la zapata (la esquina de abajo a la izquierda): las fuerzas de la tabla de la sección 6 puestas donde actúan. **Naranja:** el peso del muro W (con el del dentellón) y el peso de la cuña de tierra W_{c}, verticales hacia abajo, en sus centros de gravedad. **Rojo:** el empuje activo de Coulomb, que se descompone en una parte **horizontal** E_{ax} (hacia la punta: tiende a **volcar** y a **deslizar** el muro) y una **vertical** E_{az} (hacia abajo: ayuda a estabilizar porque el relleno roza el muro), y la fuerza de 30 kN/m de la coronación. **Azul debajo de la base:** la presión del suelo sobre la zapata, que GEO5 reparte **uniforme** en el ancho comprimido (la base menos el doble de la excentricidad). Escala de flechas: 1 m = 100 kN; de la presión: 1 m = 100 kPa.
x_R = B_z/2 - e_b 'dónde cae la resultante desde la punta (excentricidad hacia la punta) [m]
w_s = L_b - 2·e_b 'ancho comprimido de la base [m]
r_FSo = round(FS_o, 2) 'FS al vuelco, para el rótulo
r_eb = round(e_b, 2) 'excentricidad, para el rótulo
r_ws = round(w_s, 2) 'ancho comprimido, para el rótulo
r_sb = round(s_b, 1) 'presión en la base, para el rótulo
#dibujo("Cuerpo libre del muro del Demo01: fuerzas de la tabla de GEO5, brazos y presión en la base", ud = m, escala = auto, cotas = m, ancho = 180, alto = 190)
#  poligono(0, 0, 3.6, 0, 3.6, -0.2, 4.1, -0.2, 4.1, 0.6, 1.6, 0.6, 1.6, 5.6, 1.4, 5.6, 1.0, 0.6, 0, 0.6, "gruesa")
#  achurado(0, 0, 4.1, 0.6, "concreto")
#  poligono(x_t, h_z, B_z, h_z, x_t, y_T, "verde tenue")
#  linea(x_t, y_T, B_z, h_z, "trazos verde")
#  flecha(x_m, y_m + W_m/100, x_m, y_m, "naranja")
#  texto(x_m - 0.1, y_m + W_m/100 + 0.2, "W = 104.9 kN/m", 2.4, "d", estilo = "naranja")
#  flecha(x_c, y_c + W_c/100, x_c, y_c, "naranja")
#  texto(x_c + 0.15, y_c + W_c/100 - 0.1, "Wc = 99.2 kN/m", 2.4, "i", estilo = "naranja")
#  flecha(x_a, y_a + E_az/100, x_a, y_a, "rojo")
#  texto(x_a + 0.15, y_a + E_az/100 - 0.2, "Eaz = 118.7", 2.4, "i", estilo = "rojo")
#  flecha(x_a + E_ax/100, y_a, x_a, y_a, "rojo")
#  texto(x_a + E_ax/100 + 0.1, y_a + 0.2, "Eax = 84.3 kN/m", 2.4, "i", estilo = "rojo")
#  flecha(1.6 + F_1/100 + 0.4, y_F, 1.6, y_F, "rojo")
#  texto(2.35, y_F + 0.3, "F = 30 kN/m", 2.4, "i", estilo = "rojo")
#  carga(w_s, 0, 0, 0, s_b/100, s_b/100, "", "azul", n = 7)
#  circulo(x_R, 0, 0.07, "verde relleno")
#  texto(x_R, -1.0, "resultante", 2.4, "c", estilo = "verde")
#  cota(0, -1.35, 1.80, -1.35, -0.05, "1.80")
#  cota(0, -1.75, 2.44, -1.75, -0.05, "2.44")
#  cota(0, -2.15, 3.26, -2.15, -0.05, "3.26")
#  cota(0, -2.55, B_z, -2.55, -0.05, "4.10")
#  cota(-0.5, 0, -0.5, y_a, 0.1, "1.65")
#  cota(-1.3, 0, -1.3, y_F, 0.1, "5.80")
#fin
#: **Cómo se calculan el vuelco y el deslizamiento con este dibujo.** El **vuelco** es girar alrededor de la punta (origen): cada fuerza vertical multiplicada por su brazo horizontal (las cotas de abajo: 1.80, 2.44 y 3.26 m) da el momento **resistente**; cada fuerza horizontal por su altura (1.65 m el empuje, 5.80 m la fuerza de la coronación) da el momento **volcador**. Su cociente es FS = @{r_FSo}. El **deslizamiento** compara el rozamiento de la base (N·tan φ más la adherencia) con la fuerza que empuja a lo largo de ella. La **excentricidad** e = @{r_eb} m es lo que se corre la resultante del centro de la base hacia la punta; la presión se concentra en el ancho w = @{r_ws} m y vale @{r_sb} kPa, que se compara con la capacidad portante de 180 kPa.

## 10 · Hekatan contra GEO5

#hide
g_W = 104.88
g_xm = 1.80
g_ff = 1.22
g_Wc = 99.17
g_xc = 2.44
g_yc = 2.00
g_Ex = 84.30
g_Ez = 118.67
g_xa = 3.26
g_ya = 1.65
g_Mr = 817.56
g_Mo = 313.07
g_FSo = 2.61
g_Hr = 197.82
g_Ha = 97.21
g_FSs = 2.03
g_M = 168.39
g_N = 327.85
g_er = 0.125
g_sb = 106.53
g_FSb = 1.69
h_Ex2 = round(E_ax, 2)
h_yc2 = round(y_c, 2)
h_ya2 = round(y_a, 2)
h_Mr = round(M_res, 2)
h_Mo = round(M_ovr, 2)
h_FSo = round(FS_o, 2)
h_Hr = round(H_res, 2)
h_Ha = round(T_b, 2)
h_FSs = round(FS_s, 2)
h_M = round(M_b, 2)
h_N = round(N_b, 2)
h_er = round(e_r, 3)
h_sb = round(s_b, 2)
h_FSb = round(FS_b, 2)
x_W = round(100·(h_W/g_W - 1), 3)
x_xm = round(100·(h_xm/g_xm - 1), 3)
x_ff = round(100·(h_E/g_ff - 1), 3)
x_Wc = round(100·(h_Wc/g_Wc - 1), 3)
x_xc = round(100·(h_xc/g_xc - 1), 3)
x_yc = round(100·(h_yc2/g_yc - 1), 3)
x_Ex = round(100·(h_Ex2/g_Ex - 1), 3)
x_Ez = round(100·(h_Ez/g_Ez - 1), 3)
x_xa = round(100·(h_xa/g_xa - 1), 3)
x_ya = round(100·(h_ya2/g_ya - 1), 3)
x_Mr = round(100·(h_Mr/g_Mr - 1), 3)
x_Mo = round(100·(h_Mo/g_Mo - 1), 3)
x_FSo = round(100·(h_FSo/g_FSo - 1), 3)
x_Hr = round(100·(h_Hr/g_Hr - 1), 3)
x_Ha = round(100·(h_Ha/g_Ha - 1), 3)
x_FSs = round(100·(h_FSs/g_FSs - 1), 3)
x_M = round(100·(h_M/g_M - 1), 3)
x_N = round(100·(h_N/g_N - 1), 3)
x_er = round(100·(h_er/g_er - 1), 3)
x_sb = round(100·(h_sb/g_sb - 1), 3)
x_FSb = round(100·(h_FSb/g_FSb - 1), 3)
#show
#| Magnitud | Hekatan | GEO5 2024 | Diferencia [%] |
#|---|---:|---:|---:|
#| peso del muro [kN/m] | @{h_W} | @{g_W} | @{x_W} |
#| su brazo x [m] | @{h_xm} | @{g_xm} | @{x_xm} |
#| resistencia frontal [kN/m] | @{h_E} | @{g_ff} | @{x_ff} |
#| peso de la cuña [kN/m] | @{h_Wc} | @{g_Wc} | @{x_Wc} |
#| cuña: x [m] | @{h_xc} | @{g_xc} | @{x_xc} |
#| cuña: altura [m] | @{h_yc2} | @{g_yc} | @{x_yc} |
#| empuje horizontal [kN/m] | @{h_Ex2} | @{g_Ex} | @{x_Ex} |
#| empuje vertical [kN/m] | @{h_Ez} | @{g_Ez} | @{x_Ez} |
#| empuje: x [m] | @{h_xa} | @{g_xa} | @{x_xa} |
#| empuje: altura [m] | @{h_ya2} | @{g_ya} | @{x_ya} |
#| **M_{res} [kN·m/m]** | @{h_Mr} | @{g_Mr} | @{x_Mr} |
#| **M_{ovr} [kN·m/m]** | @{h_Mo} | @{g_Mo} | @{x_Mo} |
#| FS vuelco | @{h_FSo} | @{g_FSo} | @{x_FSo} |
#| **H_{res} [kN/m]** | @{h_Hr} | @{g_Hr} | @{x_Hr} |
#| **H_{act} [kN/m]** | @{h_Ha} | @{g_Ha} | @{x_Ha} |
#| FS deslizamiento | @{h_FSs} | @{g_FSs} | @{x_FSs} |
#| momento en el centro de la base [kN·m/m] | @{h_M} | @{g_M} | @{x_M} |
#| normal a la base [kN/m] | @{h_N} | @{g_N} | @{x_N} |
#| excentricidad relativa | @{h_er} | @{g_er} | @{x_er} |
#| **presión en la base [kPa]** | @{h_sb} | @{g_sb} | @{x_sb} |
#| FS capacidad portante | @{h_FSb} | @{g_FSb} | @{x_FSb} |
#: Diferencias con el valor de Hekatan redondeado a los decimales que imprime GEO5.
#: **Lo que no cuadra a cuatro cifras:** la cuña (99.19 frente a 99.17, un 0.02 %) y el empuje vertical (118.65 frente a 118.67). Las dos salen del ángulo de la cara virtual: con 45° + φ̄/2 = 59.725° no cierran; con 59.720° cierran las dos a la vez (y la altura de la cuña, 2.005 m, cae justo en el borde del redondeo: sale 2.01 aquí y 2.00 en GEO5). De dónde sale exactamente ese ángulo **no está resuelto**: la ayuda («Earth - Pressure Wedge») da una fórmula capa por capa (υ_{a} = φ + ε) que probada con β = 0 y δ = 15° o δ = φ da 54° a 58°, no 59.7°. Queda pendiente sacarlo de CantileverWall_5.dll (la rutina de la cuña); **no se ajustó ningún factor**.
#: **Lo que no se compara:** GEO5 imprime en «Bearing cap.» una «Shear Force» de 96.96 kN/m que no es la H_{act} = 97.21 de la verificación; con las fuerzas de esta hoja sale 97.22 en las dos. No se sabe qué proyección usa esa columna: pendiente. No entra en ninguna verificación.

## 11 · NEC-SE-GC 2015

#: **Lo que pide la norma oficial** (NEC-SE-GC 2015, §5.2, **Tabla 5**, p. 38, condición estática): deslizamiento ≥ 1.60, volcamiento M_{R}/M_{A} ≥ 3.00 **o** excentricidad e/B ≤ 1/6, el que resulte más crítico; con sismo (pseudoestático) 1.05 y 2.00 (e/B ≤ 1/4). Capacidad portante: **Tabla 6**, p. 42, FS ≥ 3.0 con carga muerta + viva normal (1.5 con sismo).
#: GEO5 en este ejemplo usa 1.50 / 1.50 / 1.00 (Settings del Demo01): **no son los de la NEC**.
#hide
n_o = round(FS_o, 2)
n_s = round(FS_s, 2)
n_e = round(e_r, 3)
n_b = round(FS_b, 2)
#show
#| Verificación | Hekatan = GEO5 | GEO5 pide | NEC-15 estático | ¿Cumple la NEC? |
#|---|---:|---:|---:|---|
#| Volcamiento M_{R}/M_{A} | @{n_o} | 1.50 | 3.00 | **no** |
#| Excentricidad e/B | @{n_e} | 0.333 | 0.167 | sí |
#| Deslizamiento | @{n_s} | 1.50 | 1.60 | sí |
#| Capacidad portante (R_{d} = 180 kPa) | @{n_b} | 1.00 | 3.0 | **no** |
#: **Lectura.** Por momentos el muro no llega al 3.00, pero la NEC acepta el vuelco por excentricidad («el que resulte más crítico» se lee como: hay que cumplir el criterio que se elija con su límite) y e/B = 0.125 está dentro del tercio central (1/6 = 0.167). **Nota de criterio:** esa lectura de la Tabla 5 es mía; la conservadora es exigir las dos. La capacidad portante sí falla: con 180 kPa como capacidad última, la presión admisible de la NEC sería 180/3 = 60 kPa, y la base aprieta 106.5 kPa. Habría que ensanchar la zapata o usar un R_{d} de un estudio de suelos.
#: **Borrador NEC 2023 (no oficial):** pasa a factores de carga y resistencia (volteo ΣM_{r}/ΣM_{a} de 1.50 a 1.35 según la importancia, empuje activo ×1.50) y **calcula el deslizamiento sin la resistencia frontal**. Aquí eso apenas cambia: la resistencia frontal es 1.22 kN/m de 97 kN/m.
