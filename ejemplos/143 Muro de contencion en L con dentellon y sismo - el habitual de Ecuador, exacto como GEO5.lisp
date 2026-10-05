# Muro en voladizo L con dentellón con sismo: Mononobe-Okabe por capas exacto como GEO5, k_h de la NEC-15 y del borrador 2023
#numerico

#: **Qué se calcula.** El muro en voladizo **L con dentellón** de Portoviejo (Manabí), el de la serie de vídeos de GEO5 Cantilever Wall 2024: zapata de canto 0.40 m, fuste de 2.60 m sobre arena SP (γ 18.5 kN/m³, φ 30°) que pasa a arena limosa SP-SM (γ 17.5, φ 29.97°) a los 3.00 m. Se aplica **sismo pseudoestático** con k_{h} de la NEC-15 y del borrador NEC-SE-GC 2023, y se comprueban vuelco y deslizamiento. El **dentellón** (0.50 × 0.30 m bajo el extremo del talón) es lo habitual en Ecuador: baja la base, la inclina y mejora el deslizamiento.
#: **Algoritmo.** Es el de GEO5, extraído de su binario (ensamblado de CantileverWall_5.dll y depuración dinámica con Frida): la cara de empuje se parte en **capas**: la **cara virtual** (plano que sale del extremo del talón a 45° + φ/2 sobre la horizontal, suelo contra suelo) y la **cara vertical del talón** hasta el fondo de la zapata o del dentellón. El empuje **estático** acumula σ_{v} desde arriba; el **incremento sísmico** de Mononobe-Okabe acumula σ_{v}′ desde abajo (triángulo invertido). Cada capa es un trapecio.
#: **Juez.** Las tablas «Verification» y de fuerzas de GEO5 Cantilever Wall 2024, calculadas el 5-oct-2026 con k_{h} = 0.336. La comparación está en la sección 4; GEO5 da dos decimales.
#: **Unidades.** kN, m y kPa por metro de muro. Abscisa x desde la punta de la puntera hacia el relleno; cota y desde el fondo de la zapata hacia arriba. Los ángulos de los datos van en grados; dentro de las fórmulas, en radianes.

## 1 · Qué pide cada norma para un muro

#: **NEC-SE-GC 2015 (oficial).** §4.2.2, nota (*) de la Tabla 4 (p. 31): «la demanda sísmica para los análisis pseudo estáticos será del 60 % de la aceleración máxima en el terreno», es decir k_{h} = 0.6·a_{max}/g, con a_{max} = Z·F_{a}. Para muros, §5 (p. 37): el efecto sísmico «puede analizarse mediante el método de Mononobe-Okabe». Los factores de seguridad mínimos están en la Tabla 5 (p. 37).
#: **Borrador NEC-SE-GC 2023 (no oficial).** §8.3.9 (p. 143-145): muros por Mononobe-Okabe, Tabla 8.6, **solo rellenos secos sin cohesión** y no válido si hay licuación. El coeficiente es otro: k_{h} = a_{max}·F_{top}·F_{d}, con a_{max} = Z, F_{top} = 1.0 si el talud es menor de 15° y **F_{d}** el factor del muro, Tabla 8.7: 0.7 (muro de sótano o que soporta el edificio, en reposo), 0.5 (sostiene la cimentación de un edificio, desplazamiento menor de 25 mm), 0.4 (protege al edificio de un deslizamiento) y 0.3 (vías, redes u otras obras, o H* de 3 m o más). Además, el borrador cambia a **factores parciales** (Tablas 8.4 y 8.5, p. 142): resistencia al deslizamiento ×0.80 (muro sobre suelo) o ×0.90 (suelo sobre suelo), empuje activo ×1.50, volteo ΣM_{r}/ΣM_{a} entre 1.50 y 1.35.
#: **k_{v}.** La NEC-SE-GC no lo pide. La NEC-SE-DS 2015, §3.4.2, fija la componente vertical del sismo en no menos de 2/3 de la horizontal, y el borrador solo dice que k_{h} y k_{v} son los coeficientes en cada dirección (Tabla 8.6) sin dar valor. En GEO5, k_{v} positivo es aceleración hacia abajo: la inercia **levanta** el muro y la cuña (sentido desfavorable).

Z = 0.5 'factor de zona sísmica: Manabí es zona VI (NEC-SE-DS, tabla 1)
F_a = 1.12 'coeficiente de amplificación de suelo, perfil D, zona VI (NEC-SE-DS, tabla 3), el estudio de suelos lo escribe 1.11 por un cruce con Fd
F_top = 1 'factor de topografía del borrador: talud menor de 15°
k_N = 0.6·Z·F_a 'k_h de la NEC-15 = 0.6·Z·F_a
F_d = [0.7; 0.5; 0.4; 0.3] 'factor del muro del borrador, Tabla 8.7
k_B = Z·F_top·F_d 'k_h del borrador = Z·F_top·F_d, para cada F_d
#: Con Z = 0.50 la NEC-15 da **0.336** y el borrador da **0.35, 0.25, 0.20 y 0.15** según el caso del muro: el borrador pide **menos** sismo salvo el caso de reposo (F_{d} = 0.7). El muro de la serie (sostiene un terreno junto a una vía) cae en F_{d} = 0.3 o 0.4 según la obra que proteja: hay que justificarlo.
k_v_N = 2/3·k_N 'k_v de la NEC-SE-DS §3.4.2: 2/3 de la componente horizontal

## 2 · Datos del muro y del suelo (los mismos que se cargaron en GEO5)

x_p = 0.0 'puntera: de la punta a la cara delantera del fuste [m] (0 = muro en L)'
b_t = 0.25 'espesor del fuste en la coronación [m]
H_f = 2.6 'altura del fuste sobre la zapata [m]
b_b = b_t 'espesor del fuste abajo [m] (fuste vertical)
x_t = x_p + b_b 'abscisa de la cara trasera del fuste, vertical [m]
L_t = 1.9 'talón: vuelo detrás del fuste [m]
B_z = x_t + L_t 'ancho de la zapata [m]
h_z = 0.4 'canto de la zapata [m]
dk = 0.3 'dentellón: profundidad bajo el fondo de la zapata, x1 menos el canto [m]
d_w = 0.5 'dentellón: ancho, pegado al extremo del talón [m]
gam_c = 23 'peso específico del hormigón [kN/m3]
g_1 = 18.5 'γ de la arena SP [kN/m3]
f_1 = 30 'φ de la arena SP [grados]
g_2 = 17.5 'γ de la arena limosa SP-SM bajo 3.00 m [kN/m3]
f_2 = 29.97 'φ de la SP-SM, que es el rozamiento de la base [grados]
d_p = 20 'rozamiento suelo-estructura δ en la cara del talón y del dentellón [grados]
D_sp = 3 'profundidad donde termina la arena SP [m]
Dat = [B_z; h_z; b_b; b_t; H_f; x_t; gam_c; dk; d_w; D_sp; g_1; f_1; g_2; f_2; d_p] 'los datos juntos, para repetir el cálculo con otros k_h y k_v
#: K de Coulomb con la rama de GEO5 (binario, 0xD9C4C8), ángulos en radianes: K = cos²(φ−α) / (cos²α · cos(α+δ) · (1+√R)²), R = sen(φ+δ)·sen(φ−β) / (cos(α+δ)·cos(α−β)).
#hide
function K = Kc(f, d, a, b)
  R = max(sin(f + d)*sin(f - b)/(cos(a + d)*cos(a - b)), 0)
  K = cos(f - a)^2/(cos(a)^2*cos(a + d)*(1 + sqrt(R))^2)
end
#show
#hide
function R = muro(Dat, k_h, k_v)
  B_z = Dat(1)
  h_z = Dat(2)
  b_b = Dat(3)
  b_t = Dat(4)
  H_f = Dat(5)
  x_t = Dat(6)
  gam_c = Dat(7)
  dk = Dat(8)
  d_w = Dat(9)
  D_sp = Dat(10)
  g_1 = Dat(11)
  f_1 = Dat(12)
  g_2 = Dat(13)
  f_2 = Dat(14)
  d_p = Dat(15)
  r_ = pi/180
  th = pi/4 + f_1*r_/2
  x_v = B_z - H_f/tan(th)
  H_t = h_z + H_f
  A_z = B_z*h_z + d_w*dk
  W_z = gam_c*A_z
  x_z = (B_z*h_z*B_z/2 + d_w*dk*(B_z - d_w/2))/A_z
  y_z = (B_z*h_z*h_z/2 - d_w*dk*dk/2)/A_z
  A_f = (b_b + b_t)/2*H_f
  W_f = gam_c*A_f
  x_f = x_t - H_f*(b_b^2 + b_b*b_t + b_t^2)/6/A_f
  y_f = h_z + H_f*(b_b + 2*b_t)/(3*(b_b + b_t))
  W_m = W_z + W_f
  x_m = (W_z*x_z + W_f*x_f)/W_m
  y_m = (W_z*y_z + W_f*y_f)/W_m
  w_0 = B_z - x_t
  w_1 = x_v - x_t
  A_c = (w_0 + w_1)/2*H_f
  W_c = g_1*A_c
  x_c = x_t + H_f*(w_0^2 + w_0*w_1 + w_1^2)/6/A_c
  y_c = h_z + H_f*(w_0 + 2*w_1)/(3*(w_0 + w_1))
  psi = atan(k_h/(1 - k_v))
  esp_1 = H_f
  esp_2 = max(min(D_sp, H_t) - H_f, 0)
  esp_3 = H_t + dk - H_f - esp_2
  a_1 = pi/2 - th
  a_2 = 0
  a_3 = 0
  ph_1 = f_1*r_
  ph_2 = f_1*r_
  ph_3 = f_2*r_
  dd_1 = ph_1
  dd_2 = d_p*r_
  dd_3 = d_p*r_
  dK_1 = dd_1 - 0.0001
  dK_2 = dd_2
  dK_3 = dd_3
  gl_1 = g_1
  gl_2 = g_1
  gl_3 = g_2
  Ka_1 = Kc(ph_1, dK_1, a_1, 0)
  Ka_2 = Kc(ph_2, dK_2, a_2, 0)
  Ka_3 = Kc(ph_3, dK_3, a_3, 0)
  Kae_1 = Kc(ph_1, dK_1, a_1 + psi, psi)*cos(a_1 + psi)^2/(cos(psi)*cos(a_1)^2)
  Kae_2 = Kc(ph_2, dK_2, a_2 + psi, psi)*cos(a_2 + psi)^2/(cos(psi)*cos(a_2)^2)
  Kae_3 = Kc(ph_3, dK_3, a_3 + psi, psi)*cos(a_3 + psi)^2/(cos(psi)*cos(a_3)^2)
  w_a1 = esp_1*gl_1
  w_a2 = esp_2*gl_2
  w_a3 = esp_3*gl_3
  sa_1 = 0
  sb_1 = w_a1
  sa_2 = sb_1
  sb_2 = sa_2 + w_a2
  sa_3 = sb_2
  sb_3 = sa_3 + w_a3
  zz_1 = 0
  zz_2 = esp_1
  zz_3 = esp_1 + esp_2
  pa_1 = Ka_1*sa_1
  pb_1 = Ka_1*sb_1
  pa_2 = Ka_2*sa_2
  pb_2 = Ka_2*sb_2
  pa_3 = Ka_3*sa_3
  pb_3 = Ka_3*sb_3
  F_1 = (pa_1 + pb_1)/2*esp_1
  F_2 = (pa_2 + pb_2)/2*esp_2
  F_3 = (pa_3 + pb_3)/2*esp_3
  zc_1 = zz_1 + esp_1*(pa_1 + 2*pb_1)/(3*max(pa_1 + pb_1, 0.000000001))
  zc_2 = zz_2 + esp_2*(pa_2 + 2*pb_2)/(3*max(pa_2 + pb_2, 0.000000001))
  zc_3 = zz_3 + esp_3*(pa_3 + 2*pb_3)/(3*max(pa_3 + pb_3, 0.000000001))
  E_x = F_1*cos(a_1 + dd_1) + F_2*cos(a_2 + dd_2) + F_3*cos(a_3 + dd_3)
  E_z = F_1*sin(a_1 + dd_1) + F_2*sin(a_2 + dd_2) + F_3*sin(a_3 + dd_3)
  E_xx = (F_1*sin(a_1 + dd_1)*(x_v + zc_1/tan(th)) + F_2*sin(a_2 + dd_2)*B_z + F_3*sin(a_3 + dd_3)*B_z)/E_z
  E_y = (F_1*cos(a_1 + dd_1)*(H_t - zc_1) + F_2*cos(a_2 + dd_2)*(H_t - zc_2) + F_3*cos(a_3 + dd_3)*(H_t - zc_3))/E_x
  ws_1 = (1 - k_v)*w_a1
  ws_2 = (1 - k_v)*w_a2
  ws_3 = (1 - k_v)*w_a3
  ta_1 = ws_1 + ws_2 + ws_3
  tb_1 = ta_1 - ws_1
  ta_2 = tb_1
  tb_2 = ta_2 - ws_2
  ta_3 = tb_2
  tb_3 = ta_3 - ws_3
  qa_1 = (Kae_1 - Ka_1)*ta_1
  qb_1 = (Kae_1 - Ka_1)*tb_1
  qa_2 = (Kae_2 - Ka_2)*ta_2
  qb_2 = (Kae_2 - Ka_2)*tb_2
  qa_3 = (Kae_3 - Ka_3)*ta_3
  qb_3 = (Kae_3 - Ka_3)*tb_3
  G_1 = (qa_1 + qb_1)/2*esp_1
  G_2 = (qa_2 + qb_2)/2*esp_2
  G_3 = (qa_3 + qb_3)/2*esp_3
  zs_1 = zz_1 + esp_1*(qa_1 + 2*qb_1)/(3*max(qa_1 + qb_1, 0.000000001))
  zs_2 = zz_2 + esp_2*(qa_2 + 2*qb_2)/(3*max(qa_2 + qb_2, 0.000000001))
  zs_3 = zz_3 + esp_3*(qa_3 + 2*qb_3)/(3*max(qa_3 + qb_3, 0.000000001))
  S_x = G_1*cos(a_1 + dd_1) + G_2*cos(a_2 + dd_2) + G_3*cos(a_3 + dd_3)
  S_z = G_1*sin(a_1 + dd_1) + G_2*sin(a_2 + dd_2) + G_3*sin(a_3 + dd_3)
  S_xx = (G_1*sin(a_1 + dd_1)*(x_v + zs_1/tan(th)) + G_2*sin(a_2 + dd_2)*B_z + G_3*sin(a_3 + dd_3)*B_z)/max(S_z, 0.000000001)
  S_y = (G_1*cos(a_1 + dd_1)*(H_t - zs_1) + G_2*cos(a_2 + dd_2)*(H_t - zs_2) + G_3*cos(a_3 + dd_3)*(H_t - zs_3))/max(S_x, 0.000000001)
  M_res = (1 - k_v)*(W_m*x_m + W_c*x_c) + E_z*E_xx + S_z*S_xx
  M_ovr = k_h*(W_m*y_m + W_c*y_c) + E_x*E_y + S_x*S_y
  N_v = (1 - k_v)*(W_m + W_c) + E_z + S_z
  H_h = k_h*(W_m + W_c) + E_x + S_x
  eps_b = atan(dk/B_z)
  H_res = (N_v*cos(eps_b) + H_h*sin(eps_b))*tan(f_2*r_)
  T_ac = H_h*cos(eps_b) - N_v*sin(eps_b)
  FS_v = M_res/M_ovr
  FS_d = H_res/T_ac
  R = [FS_v; FS_d; M_res; M_ovr]
end
#show

## 3 · El cálculo con k_h de la NEC-15 y k_v = 0 (el caso base de GEO5)

#: Cada línea lleva su descripción: pesos y centros de gravedad, las tres capas de la cara de empuje, K_{a} y K_{ae} por capa, los trapecios estático y sísmico, y al final los momentos y los factores de seguridad.
k_h = k_N 'k_h de la NEC-15, 0.6·Z·F_a
k_v = 0 'k_v del caso base de GEO5
r_ = pi/180 'de grados a radianes
th = pi/4 + f_1*r_/2 'ángulo de la cara virtual sobre la horizontal [rad]
x_v = B_z - H_f/tan(th) 'abscisa donde la cara virtual corta el terreno [m]
H_t = h_z + H_f 'cota del terreno sobre el fondo de la zapata [m]
A_z = B_z*h_z + d_w*dk 'área de la zapata con su dentellón [m2]
W_z = gam_c*A_z 'peso de la zapata [kN/m]
x_z = (B_z*h_z*B_z/2 + d_w*dk*(B_z - d_w/2))/A_z 'abscisa de su centro de gravedad [m]
y_z = (B_z*h_z*h_z/2 - d_w*dk*dk/2)/A_z 'cota de su centro de gravedad [m]
A_f = (b_b + b_t)/2*H_f 'área del fuste [m2]
W_f = gam_c*A_f 'peso del fuste [kN/m]
x_f = x_t - H_f*(b_b^2 + b_b*b_t + b_t^2)/6/A_f 'abscisa de su centro de gravedad [m]
y_f = h_z + H_f*(b_b + 2*b_t)/(3*(b_b + b_t)) 'cota de su centro de gravedad [m]
W_m = W_z + W_f 'peso del muro [kN/m]
x_m = (W_z*x_z + W_f*x_f)/W_m 'abscisa del centro de gravedad del muro [m]
y_m = (W_z*y_z + W_f*y_f)/W_m 'cota del centro de gravedad del muro [m]
w_0 = B_z - x_t 'ancho de la cuña de tierra abajo [m]
w_1 = x_v - x_t 'ancho de la cuña arriba [m]
A_c = (w_0 + w_1)/2*H_f 'área de la cuña [m2]
W_c = g_1*A_c 'peso de la cuña [kN/m]
x_c = x_t + H_f*(w_0^2 + w_0*w_1 + w_1^2)/6/A_c 'abscisa de su centro de gravedad [m]
y_c = h_z + H_f*(w_0 + 2*w_1)/(3*(w_0 + w_1)) 'cota de su centro de gravedad [m]
psi = atan(k_h/(1 - k_v)) 'ángulo del sismo ψ = atan(kh/(1 - kv)) [rad]
esp_1 = H_f 'capa 1: la cara virtual, de la coronación hasta la altura del fuste [m]
esp_2 = max(min(D_sp, H_t) - H_f, 0) 'capa 2: la cara del talón, en la arena SP [m]
esp_3 = H_t + dk - H_f - esp_2 'capa 3: el dentellón, en la arena limosa SP-SM [m]
a_1 = pi/2 - th 'inclinación de la cara virtual respecto de la vertical [rad]
a_2 = 0 'la cara del talón es vertical
a_3 = 0 'la cara del dentellón es vertical
ph_1 = f_1*r_ 'φ de la capa 1 [rad]
ph_2 = f_1*r_ 'φ de la capa 2 [rad]
ph_3 = f_2*r_ 'φ de la capa 3 [rad]
dd_1 = ph_1 'δ de la cara virtual = φ (suelo contra suelo) [rad]
dd_2 = d_p*r_ 'δ de la cara del talón [rad]
dd_3 = d_p*r_ 'δ de la cara del dentellón [rad]
dK_1 = dd_1 - 0.0001 'δ solo para calcular K: GEO5 lo recorta a φ - 1e-4 (0xD9D978) [rad]
dK_2 = dd_2 'δ para K, capa 2 [rad]
dK_3 = dd_3 'δ para K, capa 3 [rad]
gl_1 = g_1 'γ de la capa 1 [kN/m3]
gl_2 = g_1 'γ de la capa 2 [kN/m3]
gl_3 = g_2 'γ de la capa 3 [kN/m3]
Ka_1 = Kc(ph_1, dK_1, a_1, 0) 'K_a de Coulomb, capa 1
Ka_2 = Kc(ph_2, dK_2, a_2, 0) 'K_a de Coulomb, capa 2
Ka_3 = Kc(ph_3, dK_3, a_3, 0) 'K_a de Coulomb, capa 3
Kae_1 = Kc(ph_1, dK_1, a_1 + psi, psi)*cos(a_1 + psi)^2/(cos(psi)*cos(a_1)^2) 'K_ae de Mononobe-Okabe, capa 1
Kae_2 = Kc(ph_2, dK_2, a_2 + psi, psi)*cos(a_2 + psi)^2/(cos(psi)*cos(a_2)^2) 'K_ae, capa 2
Kae_3 = Kc(ph_3, dK_3, a_3 + psi, psi)*cos(a_3 + psi)^2/(cos(psi)*cos(a_3)^2) 'K_ae, capa 3
w_a1 = esp_1*gl_1 'peso por m2 de la capa 1 [kPa]
w_a2 = esp_2*gl_2 'peso de la capa 2 [kPa]
w_a3 = esp_3*gl_3 'peso de la capa 3 [kPa]
sa_1 = 0 'σv de la capa 1 arriba: el empuje ESTÁTICO se acumula DESDE ARRIBA [kPa]
sb_1 = w_a1 'σv de la capa 1 abajo [kPa]
sa_2 = sb_1 'σv de la capa 2 arriba [kPa]
sb_2 = sa_2 + w_a2 'σv de la capa 2 abajo [kPa]
sa_3 = sb_2 'σv de la capa 3 arriba [kPa]
sb_3 = sa_3 + w_a3 'σv de la capa 3 abajo [kPa]
zz_1 = 0 'profundidad del tope de la capa 1 [m]
zz_2 = esp_1 'profundidad del tope de la capa 2 [m]
zz_3 = esp_1 + esp_2 'profundidad del tope de la capa 3 [m]
pa_1 = Ka_1*sa_1 'Δσ estático, capa 1 arriba [kPa]
pb_1 = Ka_1*sb_1 'Δσ estático, capa 1 abajo [kPa]
pa_2 = Ka_2*sa_2 'Δσ estático, capa 2 arriba [kPa]
pb_2 = Ka_2*sb_2 'Δσ estático, capa 2 abajo [kPa]
pa_3 = Ka_3*sa_3 'Δσ estático, capa 3 arriba [kPa]
pb_3 = Ka_3*sb_3 'Δσ estático, capa 3 abajo [kPa]
F_1 = (pa_1 + pb_1)/2*esp_1 'fuerza del trapecio, capa 1 [kN/m]
F_2 = (pa_2 + pb_2)/2*esp_2 'fuerza del trapecio, capa 2 [kN/m]
F_3 = (pa_3 + pb_3)/2*esp_3 'fuerza del trapecio, capa 3 [kN/m]
zc_1 = zz_1 + esp_1*(pa_1 + 2*pb_1)/(3*max(pa_1 + pb_1, 0.000000001)) 'profundidad de la resultante, capa 1 [m]
zc_2 = zz_2 + esp_2*(pa_2 + 2*pb_2)/(3*max(pa_2 + pb_2, 0.000000001)) 'profundidad de la resultante, capa 2 [m]
zc_3 = zz_3 + esp_3*(pa_3 + 2*pb_3)/(3*max(pa_3 + pb_3, 0.000000001)) 'profundidad de la resultante, capa 3 [m]
E_x = F_1*cos(a_1 + dd_1) + F_2*cos(a_2 + dd_2) + F_3*cos(a_3 + dd_3) 'empuje activo horizontal, Fx [kN/m]
E_z = F_1*sin(a_1 + dd_1) + F_2*sin(a_2 + dd_2) + F_3*sin(a_3 + dd_3) 'empuje activo vertical, Fz [kN/m]
E_xx = (F_1*sin(a_1 + dd_1)*(x_v + zc_1/tan(th)) + F_2*sin(a_2 + dd_2)*B_z + F_3*sin(a_3 + dd_3)*B_z)/E_z 'abscisa de aplicación (pesada por Fz) [m]
E_y = (F_1*cos(a_1 + dd_1)*(H_t - zc_1) + F_2*cos(a_2 + dd_2)*(H_t - zc_2) + F_3*cos(a_3 + dd_3)*(H_t - zc_3))/E_x 'cota de aplicación (pesada por Fx) [m]
ws_1 = (1 - k_v)*w_a1 'peso de la capa 1 con la vertical del sismo [kPa]
ws_2 = (1 - k_v)*w_a2 'peso de la capa 2 [kPa]
ws_3 = (1 - k_v)*w_a3 'peso de la capa 3 [kPa]
ta_1 = ws_1 + ws_2 + ws_3 'σv′ de la capa 1 arriba: el incremento SÍSMICO se acumula DESDE ABAJO (triángulo invertido) [kPa]
tb_1 = ta_1 - ws_1 'σv′ de la capa 1 abajo [kPa]
ta_2 = tb_1 'σv′ de la capa 2 arriba [kPa]
tb_2 = ta_2 - ws_2 'σv′ de la capa 2 abajo [kPa]
ta_3 = tb_2 'σv′ de la capa 3 arriba [kPa]
tb_3 = ta_3 - ws_3 'σv′ de la capa 3 abajo [kPa]
qa_1 = (Kae_1 - Ka_1)*ta_1 'Δσ sísmico, capa 1 arriba [kPa]
qb_1 = (Kae_1 - Ka_1)*tb_1 'Δσ sísmico, capa 1 abajo [kPa]
qa_2 = (Kae_2 - Ka_2)*ta_2 'Δσ sísmico, capa 2 arriba [kPa]
qb_2 = (Kae_2 - Ka_2)*tb_2 'Δσ sísmico, capa 2 abajo [kPa]
qa_3 = (Kae_3 - Ka_3)*ta_3 'Δσ sísmico, capa 3 arriba [kPa]
qb_3 = (Kae_3 - Ka_3)*tb_3 'Δσ sísmico, capa 3 abajo [kPa]
G_1 = (qa_1 + qb_1)/2*esp_1 'fuerza sísmica del trapecio, capa 1 [kN/m]
G_2 = (qa_2 + qb_2)/2*esp_2 'fuerza sísmica, capa 2 [kN/m]
G_3 = (qa_3 + qb_3)/2*esp_3 'fuerza sísmica, capa 3 [kN/m]
zs_1 = zz_1 + esp_1*(qa_1 + 2*qb_1)/(3*max(qa_1 + qb_1, 0.000000001)) 'profundidad de la resultante sísmica, capa 1 [m]
zs_2 = zz_2 + esp_2*(qa_2 + 2*qb_2)/(3*max(qa_2 + qb_2, 0.000000001)) 'profundidad, capa 2 [m]
zs_3 = zz_3 + esp_3*(qa_3 + 2*qb_3)/(3*max(qa_3 + qb_3, 0.000000001)) 'profundidad, capa 3 [m]
S_x = G_1*cos(a_1 + dd_1) + G_2*cos(a_2 + dd_2) + G_3*cos(a_3 + dd_3) 'incremento sísmico del empuje, Fx [kN/m]
S_z = G_1*sin(a_1 + dd_1) + G_2*sin(a_2 + dd_2) + G_3*sin(a_3 + dd_3) 'incremento sísmico, Fz [kN/m]
S_xx = (G_1*sin(a_1 + dd_1)*(x_v + zs_1/tan(th)) + G_2*sin(a_2 + dd_2)*B_z + G_3*sin(a_3 + dd_3)*B_z)/max(S_z, 0.000000001) 'abscisa de aplicación [m]
S_y = (G_1*cos(a_1 + dd_1)*(H_t - zs_1) + G_2*cos(a_2 + dd_2)*(H_t - zs_2) + G_3*cos(a_3 + dd_3)*(H_t - zs_3))/max(S_x, 0.000000001) 'cota de aplicación [m]
M_res = (1 - k_v)*(W_m*x_m + W_c*x_c) + E_z*E_xx + S_z*S_xx 'momento resistente respecto de la punta de la zapata [kN·m/m]
M_ovr = k_h*(W_m*y_m + W_c*y_c) + E_x*E_y + S_x*S_y 'momento volcador [kN·m/m]
N_v = (1 - k_v)*(W_m + W_c) + E_z + S_z 'resultante vertical [kN/m]
H_h = k_h*(W_m + W_c) + E_x + S_x 'resultante horizontal [kN/m]
eps_b = atan(dk/B_z) 'inclinación de la base, del fondo de la puntera al fondo del dentellón [rad]
H_res = (N_v*cos(eps_b) + H_h*sin(eps_b))*tan(f_2*r_) 'fuerza resistente al deslizamiento sobre la base inclinada [kN/m]
T_ac = H_h*cos(eps_b) - N_v*sin(eps_b) 'fuerza actuante a lo largo de la base [kN/m]
FS_v = M_res/M_ovr 'factor de seguridad al VUELCO
FS_d = H_res/T_ac 'factor de seguridad al DESLIZAMIENTO

## 4 · Contra GEO5: peso, empuje, incremento sísmico, vuelco y deslizamiento

#: Los factores de seguridad de GEO5 salen de los porcentajes de uso de GEO5 (2.0/1.239 y 1.05/0.638). Filas: peso del muro; empuje estático Fx, Fz, x, y; incremento sísmico Fx, Fz, x, y; FS al vuelco; FS al deslizamiento. La diferencia debe quedar bajo 0.01 (en Fz del incremento sísmico, bajo 0.03).
H_v = [W_m; E_x; E_z; E_xx; E_y; S_x; S_z; S_xx; S_y; FS_v; FS_d] 'valores de Hekatan
G_v = [38.18; 31.51; 39.98; 1.7; 0.85; 45.61; 77.16; 1.24; 1.93; 1.6142; 1.6458] 'valores de GEO5
Dif = H_v - G_v 'diferencia Hekatan - GEO5
Rf = muro(Dat, k_h, k_v) 'la misma verificación con la función: debe dar los mismos FS

## 5 · k_h de la NEC-15 y del borrador: cuánto cambian el vuelco y el deslizamiento

#: Se repite el cálculo para k_{h} = 0 (sin sismo), tres valores del borrador (F_{d} = 0.3, 0.4, 0.5), el de la NEC-15 y el del borrador con F_{d} = 0.7, siempre con k_{v} = 0. Con **menos** sismo el muro **mejora**: el borrador es más permisivo que la NEC-15 salvo en el caso de reposo (F_{d} = 0.7). Columnas: k_{h}, FS al vuelco, FS al deslizamiento.
kh_l = [0; 0.15; 0.2; 0.25; 0.336; 0.35] 'k_h probados
#hide
Rl = zeros(6, 3)
for j = 1:6
  Rj = muro(Dat, kh_l(j), 0)
  Rl(j, 1) = kh_l(j)
  Rl(j, 2) = Rj(1)
  Rl(j, 3) = Rj(2)
end
#show
Res_l = Rl 'k_h, FS vuelco, FS deslizamiento

## 6 · Gráfica: factores de seguridad frente a k_h

#: Los puntos de Hekatan salen del cálculo por capas repetido para 9 valores de k_{h}; el punto de GEO5 es su resultado con k_{h} = 0.336.
#hide
Pv = zeros(9, 2)
Pd = zeros(9, 2)
for j = 1:9
  Rg = muro(Dat, 0.05*j, 0)
  Pv(j, 1) = 0.05*j
  Pv(j, 2) = Rg(1)
  Pd(j, 1) = 0.05*j
  Pd(j, 2) = Rg(2)
end
#show
#fplot(Vuelco = Pv, Deslizamiento = Pd, GEO5v = [0.336 1.6142], GEO5d = [0.336 1.6458], [0 0.46])

## 7 · Conclusión

#: El muro **L con dentellón** sale igual que GEO5 en peso, empuje estático, incremento sísmico y factores de seguridad: el algoritmo es el del binario, no un ajuste. Lo que **no** cubre todavía (hay que medirlo en GEO5 antes de añadirlo): sobrecarga, nivel freático, resistencia delante de la puntera, cohesión, repisas, fuste inclinado por detrás, dentellón separado del extremo, capacidad portante y armado.
