# Muro en voladizo de Manabí: empuje de Coulomb y sismo de Mononobe-Okabe contra GEO5 Cantilever Wall
#numerico

#: **Qué se calcula.** El muro en voladizo T de Portoviejo (Manabí), sobre el suelo del estudio de suelos de Los Arenales (TSN-ES-2025-206): arena SP (γ 18.5 kN/m³, φ 30°) hasta 3.00 m y arena limosa SP-SM (γ 17.5, φ 29.97°) debajo. Empuje activo de **Coulomb**, sismo seudoestático de **Mononobe-Okabe** con k_{h} de la NEC-SE-GC, y los factores de seguridad al **vuelco** y al **deslizamiento**.
#: **Algoritmo.** El de GEO5 Cantilever Wall, sacado de su binario (CantileverWall_5.dll, ensamblado y depuración con Frida): la cara de empuje es la **cara virtual** (plano desde el extremo del talón a 45° + φ/2) más la **cara vertical del talón**. El empuje estático acumula σ_{v} **desde arriba**; el incremento sísmico acumula σ_{v} **desde abajo** (triángulo invertido).
#: **Juez.** GEO5 Cantilever Wall 2024 con el mismo muro (archivo muro_portoviejo_01.guz): vuelco **2.71**, deslizamiento **1.20**. La hoja es lineal (sin bucles ni funciones de varias líneas): corre igual en **Hekatan Math Studio** (WPF y web) y en **Hekatan LISP** (WPF y web).
#: **Unidades.** kN, m y kPa por metro de muro. Abscisa x desde la punta de la puntera hacia el relleno; cota y desde el fondo de la zapata. Ángulos de los datos en grados; dentro de las fórmulas, en radianes.

## 1 · Sismo de Manabí según la NEC

#: NEC-SE-GC §4.2.2: «la demanda sísmica para los análisis pseudo estáticos será del 60 % de la aceleración máxima en el terreno», k_{h} = 0.6·Z·F_{a}. Manabí es zona VI (Z = 0.50), perfil D (F_{a} = 1.12, NEC-SE-DS tabla 3). k_{v} = 0, el caso base de GEO5.
Z = 0.5 'factor de zona sísmica, zona VI
F_a = 1.12 'amplificación del suelo, perfil D
k_h = 0.6*Z*F_a 'coeficiente sísmico horizontal
k_v = 0 'coeficiente sísmico vertical (caso base)

## 2 · Datos del muro y del suelo (los mismos que en GEO5)

#dibujo("El muro con estos datos", ud = m, escala = auto, cotas = m, alto = 120, lado = derecha)
#  poligono(0, 0, B_z, 0, B_z, h_z, x_t, h_z, x_t, h_z + H_f, x_t - b_t, h_z + H_f, x_p, h_z, 0, h_z, "gruesa")
#  achurado(0, 0, B_z, h_z, "concreto")
#  linea(x_t, h_z + H_f, B_z + 1.2, h_z + H_f, "media verde")
#  linea(-0.8, h_z, 0, h_z, "media verde")
#  texto(B_z - 0.5, h_z + H_f/2, "arena SP", 2.5, "i")
#  cota(0, -0.35, x_p, -0.35, 0)
#  cota(x_t, -0.35, B_z, -0.35, 0)
#  cota(-0.45, 0, -0.45, h_z, 0)
#  cota(-0.45, h_z, -0.45, h_z + H_f, 0)
#  cota(x_t - b_t, h_z + H_f + 0.35, x_t, h_z + H_f + 0.35, 0)
#fin
#: Puntera: de la punta a la cara del fuste [m].
x_p = 0.7
#: Espesor del fuste en la coronación [m].
b_t = 0.25
#: Altura del fuste sobre la zapata [m].
H_f = 2.6
#: Fuste abajo (talud 1:17.33) [m].
b_b = b_t + H_f/17.33
#: Abscisa de la cara trasera del fuste [m].
x_t = x_p + b_b
#: Talón detrás del fuste [m].
L_t = 1.9
#: Ancho de la zapata [m].
B_z = x_t + L_t
#: Canto de la zapata [m].
h_z = 0.4
#: Peso específico del hormigón [kN/m3].
gamma_c = 23
#: γ de la arena SP [kN/m3].
gamma_1 = 18.5
#: φ de la arena SP [grados].
phi_1 = 30
#: φ de la SP-SM bajo 3.00 m: es el rozamiento de la base [grados].
phi_2 = 29.97
#: δ suelo-hormigón en la cara del talón [grados].
delta_p = 20
#: Medidas en m, sacadas de los datos: si cambias uno, el dibujo cambia. Gris: hormigón; verde: el terreno, que llega a la coronación detrás del muro y a la cara de la zapata delante.

## 3 · Coulomb y Mononobe-Okabe

#: **Coulomb** (rama de GEO5), con α la inclinación de la cara respecto de la vertical, β la del terreno y δ el rozamiento: K = cos²(φ−α) / [cos²α · cos(α+δ) · (1+√R)²], R = sen(φ+δ)·sen(φ−β) / [cos(α+δ)·cos(α−β)].
#: **Mononobe-Okabe**: es Coulomb con todo girado el ángulo del sismo ψ = atan(k_{h}/(1−k_{v})): K_{ae} = K(φ, δ, α+ψ, β+ψ) · cos²(α+ψ) / (cos ψ · cos²α).
Kc(phi, delta, alpha, beta) = cos(phi - alpha)^2/(cos(alpha)^2*cos(alpha + delta)*(1 + sqrt(max(sin(phi + delta)*sin(phi - beta)/(cos(alpha + delta)*cos(alpha - beta)), 0)))^2)
rad = pi/180 'de grados a radianes
psi = atan(k_h/(1 - k_v)) 'ángulo del sismo ψ [rad]
#: **El ángulo de la cara virtual como lo halla GEO5.** La teoría da α = 45° − φ/2 respecto de la vertical (θ = 45° + φ/2 sobre la horizontal). GEO5 no usa esa fórmula: lo **busca por bisección entre 0° y 90°** y se queda con el **punto medio número 15**, es decir, el centro de la celda de ancho 90°/2^{14} que contiene el valor exacto. Medido con Frida en CantileverWall_5.dll el 20-nov-2026 con φ = 27, 30, 33, 34.5 y 36: los cinco casos cumplen la regla. Con φ = 30° sale α = 30.000915527…° en vez de 30°; con 30° exactos, F_{z} del empuje se desvía 0.0013 y el incremento sísmico 0.004.
a_ex = 45 - phi_1/2 'α exacto de la teoría [grados]
a_G = 90/16384*(floor(16384*a_ex/90) + 0.5) 'α de GEO5: punto medio 15 de la bisección en [0°, 90°] [grados]
alpha_1 = a_G*rad 'inclinación de la cara virtual respecto de la vertical [rad]
theta = pi/2 - alpha_1 'ángulo de la cara virtual sobre la horizontal [rad]
phi = phi_1*rad 'φ de la arena SP [rad]
delta_1 = phi 'δ en la cara virtual = φ (suelo contra suelo) [rad]
delta_K = delta_1 - 0.0001 'δ para K: GEO5 lo recorta a φ − 1e-4 (binario, 0xD9D978) [rad]
delta_2 = delta_p*rad 'δ en la cara del talón [rad]
Ka_1 = Kc(phi, delta_K, alpha_1, 0) 'K_a de Coulomb, cara virtual
Ka_2 = Kc(phi, delta_2, 0, 0) 'K_a de Coulomb, cara del talón
Kae_1 = Kc(phi, delta_K, alpha_1 + psi, psi)*cos(alpha_1 + psi)^2/(cos(psi)*cos(alpha_1)^2) 'K_ae de Mononobe-Okabe, cara virtual
Kae_2 = Kc(phi, delta_2, psi, psi)*cos(psi)^2/cos(psi) 'K_ae, cara del talón

## 4 · Pesos y centros de gravedad

H_t = h_z + H_f 'altura total [m]
x_v = B_z - H_f/tan(theta) 'abscisa donde la cara virtual corta el terreno [m]
W_z = gamma_c*B_z*h_z 'peso de la zapata [kN/m]
A_f = (b_b + b_t)/2*H_f 'área del fuste [m2]
W_f = gamma_c*A_f 'peso del fuste [kN/m]
x_f = x_t - H_f*(b_b^2 + b_b*b_t + b_t^2)/6/A_f 'abscisa del c.d.g. del fuste [m]
y_f = h_z + H_f*(b_b + 2*b_t)/(3*(b_b + b_t)) 'cota del c.d.g. del fuste [m]
W_m = W_z + W_f 'peso del muro [kN/m]
x_m = (W_z*B_z/2 + W_f*x_f)/W_m 'abscisa del c.d.g. del muro [m]
y_m = (W_z*h_z/2 + W_f*y_f)/W_m 'cota del c.d.g. del muro [m]
w_0 = B_z - x_t 'ancho de la cuña de tierra abajo [m]
#: **La cuña de GEO5.** Su lado inclinado usa el mismo α de la bisección, pero GEO5 corre el punto de arriba **1e-5 m** hacia el relleno (una tolerancia interna): con eso su peso y su centro de gravedad salen iguales al binario bit a bit (Frida: W = 55.287195935578424, x desde el fuste 0.6563994871255965, z desde arriba 1.5829687446284182).
w_1 = L_t - H_f*tan(alpha_1) + 0.00001 'ancho de la cuña arriba, como GEO5 [m]
A_c = (w_0 + w_1)/2*H_f 'área de la cuña sobre el talón [m2]
W_c = gamma_1*A_c 'peso de la cuña [kN/m]
x_c = x_t + H_f*(w_0^2 + w_0*w_1 + w_1^2)/6/A_c 'abscisa de su c.d.g. [m]
y_c = h_z + H_f*(w_0 + 2*w_1)/(3*(w_0 + w_1)) 'cota de su c.d.g. [m]

## 5 · Empuje estático (desde arriba) e incremento sísmico (desde abajo)

#: Dos capas: la **1** es la cara virtual (alto H_{f}); la **2** es la cara del talón (alto h_{z}), que sigue en la arena SP porque el muro mide justo 3.00 m.
s_1 = gamma_1*H_f 'σv al pie de la capa 1 [kPa]
s_2 = s_1 + gamma_1*h_z 'σv al pie de la capa 2 [kPa]
F_1 = Ka_1*s_1/2*H_f 'empuje estático, capa 1: triángulo [kN/m]
F_2 = Ka_2*(s_1 + s_2)/2*h_z 'empuje estático, capa 2: trapecio [kN/m]
zc_1 = 2*H_f/3 'profundidad de F_1 [m]
zc_2 = H_f + h_z*(s_1 + 2*s_2)/(3*(s_1 + s_2)) 'profundidad de F_2 [m]
E_x = F_1*cos(alpha_1 + delta_1) + F_2*cos(delta_2) 'empuje activo horizontal [kN/m]
E_z = F_1*sin(alpha_1 + delta_1) + F_2*sin(delta_2) 'empuje activo vertical [kN/m]
E_xx = (F_1*sin(alpha_1 + delta_1)*(x_v + zc_1/tan(theta)) + F_2*sin(delta_2)*B_z)/E_z 'abscisa de aplicación [m]
E_y = (F_1*cos(alpha_1 + delta_1)*(H_t - zc_1) + F_2*cos(delta_2)*(H_t - zc_2))/E_x 'cota de aplicación [m]
#: El incremento sísmico usa σ_{v}′ medido **desde abajo**: arriba de la capa 1 vale todo el peso (s_{2}) y al pie de la capa 2 vale cero.
t_1 = (1 - k_v)*s_2 'σv′ arriba de la capa 1 [kPa]
t_2 = (1 - k_v)*gamma_1*h_z 'σv′ al pie de la capa 1 = arriba de la capa 2 [kPa]
G_1 = (Kae_1 - Ka_1)*(t_1 + t_2)/2*H_f 'incremento sísmico, capa 1 [kN/m]
G_2 = (Kae_2 - Ka_2)*t_2/2*h_z 'incremento sísmico, capa 2 [kN/m]
zs_1 = H_f*(t_1 + 2*t_2)/(3*(t_1 + t_2)) 'profundidad de G_1 [m]
zs_2 = H_f + h_z/3 'profundidad de G_2 [m]
S_x = G_1*cos(alpha_1 + delta_1) + G_2*cos(delta_2) 'incremento sísmico horizontal [kN/m]
S_z = G_1*sin(alpha_1 + delta_1) + G_2*sin(delta_2) 'incremento sísmico vertical [kN/m]
S_xx = (G_1*sin(alpha_1 + delta_1)*(x_v + zs_1/tan(theta)) + G_2*sin(delta_2)*B_z)/S_z 'abscisa de aplicación [m]
S_y = (G_1*cos(alpha_1 + delta_1)*(H_t - zs_1) + G_2*cos(delta_2)*(H_t - zs_2))/S_x 'cota de aplicación [m]

## 6 · Vuelco y deslizamiento

#: Momentos respecto de la punta de la zapata. La inercia del muro y de la cuña (k_{h}·W) también vuelca: la Mononobe-Okabe clásica la omite, GEO5 la suma.
M_res = (1 - k_v)*(W_m*x_m + W_c*x_c) + E_z*E_xx + S_z*S_xx 'momento resistente [kN·m/m]
M_ovr = k_h*(W_m*y_m + W_c*y_c) + E_x*E_y + S_x*S_y 'momento volcador [kN·m/m]
N_v = (1 - k_v)*(W_m + W_c) + E_z + S_z 'resultante vertical [kN/m]
H_h = k_h*(W_m + W_c) + E_x + S_x 'resultante horizontal [kN/m]
H_res = N_v*tan(phi_2*rad) 'resistencia al deslizamiento [kN/m]
FS_v = M_res/M_ovr 'factor de seguridad al VUELCO
FS_d = H_res/H_h 'factor de seguridad al DESLIZAMIENTO

### El muro dibujado con sus empujes

#dibujo("Empujes sobre el muro", ud = m, escala = auto, cotas = m, alto = 220, lado = derecha)
#  poligono(0, 0, B_z, 0, B_z, h_z, x_t, h_z, x_t, H_t, x_t - b_t, H_t, x_p, h_z, 0, h_z, "gruesa")
#  achurado(0, 0, B_z, h_z, "concreto")
#  poligono(x_t, h_z, B_z, h_z, x_v, H_t, x_t, H_t, "verde tenue")
#  linea(x_v, H_t, B_z, h_z, "trazos verde")
#  linea(x_t, H_t, B_z + 3, H_t, "media verde")
#  linea(-1.2, h_z, 0, h_z, "media verde")
#  texto(B_z + 1.6, 2.2, "arena SP: γ 18.5, φ 30°", 2.5, "i")
#  texto(B_z + 1.6, -0.5, "SP-SM: γ 17.5, φ 29.97°", 2.5, "i")
#  carga(x_v, H_t, B_z, h_z, 0, q_1, "", "azul", n = 5)
#  carga(B_z, h_z, B_z, 0, q_3, q_4, "", "azul", n = 3)
#  carga(x_v, H_t, B_z, h_z, u_1, u_2, "", "rojo", n = 5)
#  carga(B_z, h_z, B_z, 0, u_3, 0, "", "rojo", n = 3)
#  cota(0, -0.70, B_z, -0.70, -0.1)
#  cota(-0.6, 0, -0.6, h_z, 0.1)
#  cota(-0.6, h_z, -0.6, H_t, 0.1)
#  cota(x_t, H_t + 0.5, x_t - b_t, H_t + 0.5, 0.1)
#  cota(x_t, H_t + 1.1, B_z, H_t + 1.1, 0.1)
#  cota(0, H_t + 0.5, x_p, H_t + 0.5, 0.1)
#fin
#: Estático, pie de la capa 1, a escala.
q_1 = Ka_1*s_1/25
#: Estático, arriba de la capa 2.
q_3 = Ka_2*s_1/25
#: Estático, pie de la capa 2.
q_4 = Ka_2*s_2/25
#: Sísmico, arriba de la capa 1.
u_1 = (Kae_1 - Ka_1)*t_1/25
#: Sísmico, pie de la capa 1.
u_2 = (Kae_1 - Ka_1)*t_2/25
#: Sísmico, arriba de la capa 2.
u_3 = (Kae_2 - Ka_2)*t_2/25
#: **Cómo se lee.** Gris achurado: el hormigón. Verde tenue: la cuña de tierra que viaja con el muro; su lado inclinado (trazos) es la **cara virtual**. **Azul:** empuje estático (crece hacia abajo). **Rojo:** incremento sísmico de Mononobe-Okabe, un **triángulo invertido** (máximo arriba). Escala de flechas: 1 m = 25 kPa.

## 7 · Contra GEO5 Cantilever Wall 2024

#: Los valores de GEO5 salen de su tabla «Verification» y de la de fuerzas, con dos decimales. En cada tabla, las columnas son **Hekatan**, **GEO5** y **diferencia**. Basta con que la diferencia quede bajo 0.01: es el redondeo de GEO5.
#: **Fuerzas [kN/m]**, por filas: peso del muro; empuje estático F_{x} y F_{z}; incremento sísmico F_{x} y F_{z}.
T_F = [W_m, 47.04, W_m - 47.04; E_x, 26.63, E_x - 26.63; E_z, 38.21, E_z - 38.21; S_x, 38.39, S_x - 38.39; S_z, 65.87, S_z - 65.87] 'Hekatan, GEO5, diferencia
#: **Puntos de aplicación [m]**, por filas: empuje estático x e y; incremento sísmico x e y.
T_P = [E_xx, 2.53, E_xx - 2.53; E_y, 1.03, E_y - 1.03; S_xx, 2.06, S_xx - 2.06; S_y, 2.01, S_y - 2.01] 'Hekatan, GEO5, diferencia
#: **Inercia sísmica y cuña [kN/m]**, por filas: inercia del muro k_{h}·W_{m} («Earthq.- constr.»), peso de la cuña, inercia de la cuña («Earthquake - soil wedge»).
T_I = [k_h*W_m, 15.80, k_h*W_m - 15.80; W_c, 55.29, W_c - 55.29; k_h*W_c, 18.58, k_h*W_c - 18.58] 'Hekatan, GEO5, diferencia
#: **Momentos [kN·m/m] y fuerzas horizontales [kN/m]**, de la ventana «In detail» de GEO5: M_{res}, M_{ovr}, H_{res}, H_{act}.
T_M = [M_res, 388.96, M_res - 388.96; M_ovr, 143.34, M_ovr - 143.34; H_res, 119.02, H_res - 119.02; H_h, 99.40, H_h - 99.40] 'Hekatan, GEO5, diferencia
#: **Bit a bit contra el binario.** Valores internos de GEO5 leídos con Frida (doble precisión, 17 cifras) el 20-nov-2026 en este mismo muro: peso de la cuña y su centro de gravedad, K_{a} y K_{ae} de la cara virtual y del talón, y las fuerzas F_{x}, F_{z} del empuje estático y del incremento sísmico. La diferencia queda en 1e-14: es el redondeo de la máquina, no del método.
T_B = [W_c, 55.287195935578424, W_c - 55.287195935578424; x_c - x_t, 0.6563994871255965, x_c - x_t - 0.6563994871255965; H_t - y_c, 1.5829687446284182, H_t - y_c - 1.5829687446284182; Ka_1, 0.6666466332305437, Ka_1 - 0.6666466332305437; Kae_1, 1.594497947900209, Kae_1 - 1.594497947900209; Ka_2, 0.29731385720545084, Ka_2 - 0.29731385720545084; Kae_2, 0.6246519605930702, Kae_2 - 0.6246519605930702; E_x, 26.630959107165644, E_x - 26.630959107165644; E_z, 38.20792194799549, E_z - 38.20792194799549; S_x, 38.389394942694004, S_x - 38.389394942694004; S_z, 65.87199689777745, S_z - 65.87199689777745] 'Hekatan, GEO5 (Frida), diferencia
#: **Factores de seguridad**, por filas: vuelco y deslizamiento.
T_S = [FS_v, 2.71, FS_v - 2.71; FS_d, 1.20, FS_d - 1.20] 'Hekatan, GEO5, diferencia

## 8 · Hekatan Geotechnic

#: **Hekatan Geotechnic** tiene el mismo muro en su módulo de muros (src/wall/geo5Cantilever.ts, función muroGeo5) con la misma bisección de GEO5. En su interfaz (panel del muro, bloque «Como GEO5 Cantilever Wall», con k_{h} = 0.336, s1 = 17.33, k = 0.25 y φ de la base 29.97) y en su prueba tests/muro_manabi_bits.ts da estos valores para este muro; la tercera columna es la diferencia con esta hoja, que debe ser cero salvo el último bit.
T_G = [M_res, 388.96319832456504, M_res - 388.96319832456504; M_ovr, 143.33686202937173, M_ovr - 143.33686202937173; H_res, 119.02291472713189, H_res - 119.02291472713189; H_h, 99.400990926337528, H_h - 99.400990926337528; FS_v, 2.7136299261585695, FS_v - 2.7136299261585695; FS_d, 1.1974016920549158, FS_d - 1.1974016920549158] 'esta hoja, Hekatan Geotechnic, diferencia

#: **NEC-SE-GC, tabla 5 (sismo):** vuelco ≥ 2.00 y deslizamiento ≥ 1.05. Con k_{h} = 0.336 el muro **cumple** los dos (2.71 y 1.20).
