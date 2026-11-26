# Antes de empezar con elementos finitos en geotecnia: los 6 requisitos y por qué
#numerico

## 0 · Para qué es esta hoja
#: Esta hoja **no enseña** el método de elementos finitos (FEM) en suelos: eso lo hace la **hoja 201** (los 8 pasos con un ejemplo pequeño). Aquí solo está **lo que hace falta saber antes**, y **por qué**. Es para quien ya calcula vigas y pórticos pero nunca hizo FEM en suelos.
#: Son **6 requisitos**. Cada uno tiene: qué es (en una frase), por qué hace falta en el suelo (comparado con una estructura), una ecuación pequeña con números, un dibujo y dónde aprenderlo en nuestras hojas y videos.

## 1 · FEM de estructuras: K·u = F
#: **Qué es:** partir una estructura en piezas (elementos), escribir la rigidez de cada pieza, **ensamblar** la matriz K de toda la estructura, poner los apoyos (**bordes**) y resolver **K·u = F**. Si ya calculas un pórtico así, ya tienes el 80 %.
#: **Por qué en geotecnia:** el suelo se resuelve con la misma ecuación. Lo que cambia es la pieza: en vez de una barra, un pedazo de suelo (un «ladrillo» de 4 o 6 nudos), y en vez de E·I, la ley del suelo.
#dibujo("Requisito 1: una barra es un resorte de rigidez k = EA/L", ud = m, escala = auto, cotas = m, alto = 55)
#  empotramiento(0, -0.4, 0, 0.4, 1)
#  rect(0, -0.15, 3, 0.15, "gruesa")
#  flecha(4.2, 0, 3.05, 0, "gruesa rojo")
#  texto(4.4, 0.25, "P = 240 kN", 2.6, "i")
#  circulo(0, 0, 0.07, "azul relleno")
#  circulo(3, 0, 0.07, "azul relleno")
#  texto(0, 0.6, "nudo 1", 2.2, "c")
#  texto(3, 0.6, "nudo 2", 2.2, "c")
#  cota(0, -0.6, 3, -0.6, 0, "L = 3 m · EA = 60 000 kN")
#fin
#: La matriz de rigidez de la barra (con símbolos):
K_bar = Simplify{E*A/L*[1, -1; -1, 1]}
#: Con números: el nudo 1 está fijo (borde), queda una incógnita.
ea_1 = 60000 'rigidez axial EA [kN]
lb_1 = 3 'largo de la barra [m]
kb_1 = ea_1/lb_1 'rigidez k = EA/L [kN/m]
pb_1 = 240 'carga [kN]
xb_1 = pb_1/kb_1 'acortamiento u = P/k [m]
#: **u = 12 mm**, en una división. Funciones de forma, ensamblaje y bordes de una viga: **hojas 199 y 200** y la **viga de Hekatan Lab con las funciones de Hermite deducidas** (Math Studio, ejemplo «Viga_rigidez_Lab_LinkedIn»).

## 2 · Newton-Raphson: K_T·Δu = R
#: **Qué es:** la forma de resolver un problema que **no es una recta**: se hace como si fuera recta (con la pendiente de ese momento), se mira cuánto falta y se repite.
#: **Por qué en geotecnia:** en una viga elástica K·u = F se resuelve **una vez**. El suelo se ablanda al cargarlo: su rigidez cambia con cada milímetro. Ya no hay una sola K: hay que dar vueltas.
#: La barra de la hoja 198 se ablanda hasta N_u = 300 kN. El residuo (lo que falta) y la rigidez tangente (la pendiente), con símbolos:
R_res = Simplify{P - k_0*d/(1 + k_0*d/N_u)}
k_tan = Simplify{Diff{k_0*d/(1 + k_0*d/N_u) @ d}}
#: **Una vuelta** de Newton con números, empezando con la k inicial (la de arriba):
nm_2 = 300 'fuerza máxima de la barra N_u [kN]
nb_2 = kb_1·xb_1/(1 + kb_1·xb_1/nm_2) 'lo que da la barra con u = 12 mm [kN]
rb_2 = pb_1 - nb_2 'residuo R = P − N: lo que falta [kN]
kt_2 = kb_1/(1 + kb_1·xb_1/nm_2)^2 'rigidez tangente en u = 12 mm [kN/m]
db_2 = rb_2/kt_2 'avance Δu = R / k_T [m]
xb_2 = xb_1 + db_2 'nuevo u [m]
#: Con 12 mm la barra solo da 133.3 kN: faltan 106.7 kN. Se avanza 17.3 mm → **u = 29.3 mm**. Repitiendo, a la 6.ª vuelta da 60 mm (cinco veces lo lineal).
#: Los puntos del dibujo (para el cursor): u en mm y N en kN de cada paso.
nw_d = [0; 12; 12; 29.28; 60] 'u de cada punto [mm]
nw_n = [0; 240; 133.33; 240; 240] 'N de cada punto [kN]
nw_x = nw_d/10 'posición en el dibujo [-]
nw_y = nw_n/40 'posición en el dibujo [-]
#dibujo("Requisito 2: la curva de la barra y la primera vuelta de Newton (pasa el cursor por los puntos)", ud = m, escala = auto, alto = 70)
#  flecha(0, 0, 8.6, 0, "fina")
#  flecha(0, 0, 0, 7, "fina")
#  texto(8.6, -0.4, "u [mm/10]", 2.2, "c")
#  texto(0.2, 7.2, "N [kN/40]", 2.2, "i")
#  polilinea(0, 0, 0.5, 1.875, 1, 3, 1.5, 3.75, 2, 4.286, 3, 5, 4, 5.4545, 6, 6, 8, 6.3158, "gruesa azul")
#  linea(0, 6, 8, 6, "trazos rojo")
#  texto(4.5, 6.45, "carga P = 240 kN", 2.2, "c")
#  linea(0, 0, 1.2, 6, "media verde")
#  linea(1.2, 6, 1.2, 3.333, "trazos verde")
#  linea(1.2, 3.333, 2.928, 6, "media verde")
#  circulo(1.2, 3.333, 0.1, "rojo relleno")
#  circulo(6, 6, 0.1, "azul relleno")
#  texto(2.2, 2.9, "R = 106.7 kN", 2.2, "i")
#  texto(6, 5.4, "solución: 60 mm", 2.2, "c")
#  hover(nw_x, nw_y, "u = {#1:2} mm, N = {#2:2} kN", nw_d, nw_n)
#fin
#: Aprenderlo: **hojas 196 y 198** y el video **https://youtu.be/1LZ13H_CPJg** (Newton-Raphson desde cero).

## 3 · Esfuerzos en 2D y 3D: el tensor, el círculo de Mohr, p y q
#: **Qué es:** en cada punto de un cuerpo hay empujes en todas las direcciones: σ_x, σ_y (normales) y τ_xy (corte). Girando el punto de vista se encuentran las direcciones sin corte: los **esfuerzos principales** σ₁ y σ₃. El **círculo de Mohr** los dibuja todos juntos.
#: **Por qué en geotecnia:** en una viga piensas en M y V, y de ahí σ = M·y/I. En el suelo **no hay barras**: cada punto del bloque tiene su propio estado de esfuerzos, y el suelo falla cuando ese estado (su círculo) toca el techo del requisito 5. Los programas resumen el estado con dos números: **p** (cuánto se aprieta) y **q** (cuánto se distorsiona).
#: (en geotecnia la **compresión es positiva**.) Centro y radio del círculo, y p y q, con símbolos:
s_cen = Simplify{(sigma_x + sigma_y)/2}
r_moh = Simplify{sqrt(((sigma_x - sigma_y)/2)^2 + tau^2)}
p_inv = Simplify{(sigma_1 + sigma_2 + sigma_3)/3}
q_inv = Simplify{sqrt(((sigma_1 - sigma_2)^2 + (sigma_2 - sigma_3)^2 + (sigma_3 - sigma_1)^2)/2)}
#: Con números: un punto con σ_x = 100, σ_y = 40 y τ_xy = 40 kPa, y el empuje fuera del plano σ_z = 20 kPa (como en un ensayo triaxial):
sx_3 = 100 'σ_x [kPa]
sy_3 = 40 'σ_y [kPa]
tx_3 = 40 'τ_xy [kPa]
sz_3 = 20 'σ_z, fuera del plano [kPa]
mc_3 = (sx_3 + sy_3)/2 'centro del círculo [kPa]
mr_3 = sqrt(((sx_3 - sy_3)/2)^2 + tx_3^2) 'radio del círculo [kPa]
s1_3 = mc_3 + mr_3 'σ₁, principal mayor [kPa]
s3_3 = mc_3 - mr_3 'σ₃, principal menor [kPa]
th_3 = atan(2·tx_3/(sx_3 - sy_3))/2·180/pi 'giro hasta σ₁ [°]
pp_3 = (s1_3 + sz_3 + s3_3)/3 'p, presión media [kPa]
qq_3 = sqrt(((s1_3 - sz_3)^2 + (sz_3 - s3_3)^2 + (s3_3 - s1_3)^2)/2) 'q, esfuerzo desviador [kPa]
#: Centro 70 y radio 50 → **σ₁ = 120 kPa y σ₃ = 20 kPa**, girando 26.6°. **p = 53.3 kPa y q = 100 kPa**.
#: Los puntos del círculo (para el cursor): σ₃, σ₁, la cima y los dos puntos (σ_x, τ_xy) y (σ_y, −τ_xy):
mo_s = [20; 120; 70; 100; 40] 'σ de cada punto [kPa]
mo_t = [0; 0; 50; 40; -40] 'τ de cada punto [kPa]
mo_x = mo_s/20 'posición en el dibujo [-]
mo_y = mo_t/20 'posición en el dibujo [-]
#dibujo("Requisito 3: el punto (izquierda) y su círculo de Mohr (derecha; escala 1 : 20 kPa, pasa el cursor)", ud = m, escala = auto, alto = 75)
#  rect(-4.5, -1, 2, 2, "gruesa")
#  flecha(-6.3, 0, -4.6, 0, "gruesa rojo")
#  flecha(-0.7, 0, -2.4, 0, "gruesa rojo")
#  flecha(-3.5, 2.6, -3.5, 1.1, "media rojo")
#  flecha(-3.5, -2.6, -3.5, -1.1, "media rojo")
#  flecha(-4.2, 1.2, -2.8, 1.2, "media azul")
#  flecha(-2.8, -1.2, -4.2, -1.2, "media azul")
#  texto(-6.4, 0.4, "σx = 100", 2.2, "c")
#  texto(-3.0, 2.4, "σy = 40", 2.2, "i")
#  texto(-5.0, 1.5, "τxy = 40", 2.2, "c")
#  flecha(-2.3, -0.7, -2.3, 0.7, "media azul")
#  flecha(-4.7, 0.7, -4.7, -0.7, "media azul")
#  flecha(0, 0, 7.4, 0, "fina")
#  flecha(0, -3, 0, 3.4, "fina")
#  texto(7.4, -0.4, "σ", 2.6, "c")
#  texto(0.3, 3.4, "τ", 2.6, "i")
#  circulo(3.5, 0, 2.5, "gruesa azul")
#  linea(2, -2, 5, 2, "trazos")
#  circulo(5, 2, 0.1, "rojo relleno")
#  circulo(2, -2, 0.1, "rojo relleno")
#  circulo(1, 0, 0.1, "verde relleno")
#  circulo(6, 0, 0.1, "verde relleno")
#  texto(1.15, 0.4, "σ3 = 20", 2.2, "i")
#  texto(4.5, 0.4, "σ1 = 120", 2.2, "i")
#  texto(5.2, 2.4, "(σx, τxy)", 2.2, "i")
#  hover(mo_x, mo_y, "σ = {#1:1} kPa, τ = {#2:1} kPa", mo_s, mo_t)
#fin
#: Aprenderlo: el círculo de Mohr del suelo en las **hojas 178 (sección 2) y 163**; p y q en el triaxial de la **hoja 191**.

## 4 · Mecánica de suelos básica: σ′ = σ − u, el peso propio, K₀ y el drenaje
#: **Qué es:** tres ideas. (1) **Esfuerzo efectivo σ′ = σ − u**: el suelo es una esponja con agua; si la aprietas, una parte la toma el agua (u) y el resto los granos (σ′). Solo σ′ hace rozar los granos. (2) **El suelo ya está cargado** antes de construir, por su peso: σ_v = γ·z abajo y σ_h = K₀·σ_v de lado. (3) **Drenado o no drenado**: si cargas lento el agua alcanza a salir (drenado); si cargas rápido una arcilla, el agua queda atrapada y toma la carga (no drenado).
#: **Por qué en geotecnia:** en una viga el peso propio es una carga más y el material no tiene agua. En el suelo la resistencia se calcula con σ′ (no con σ), y el análisis **arranca** desde el estado inicial σ_v, σ_h: si se olvida, el suelo «empieza» sin apretar y falla de mentira.
s_efe = Simplify{sigma - u}
s_hor = Simplify{(1 - sin(phi))*gamma*z}
#: (K₀ = 1 − sin φ es la fórmula de Jaky para suelos normalmente consolidados.) **Con números**, suelo seco, γ = 18 kN/m³, φ = 30°, a z = 10 m:
gs_4 = 18 'peso unitario γ [kN/m³]
zz_4 = 10 'profundidad z [m]
fi_4 = 30 'ángulo de fricción φ [°]
sv_4 = gs_4·zz_4 'σ_v = γ·z [kPa]
ko_4 = 1 - sin(fi_4·pi/180) 'K₀ = 1 − sin φ [-]
sh_4 = ko_4·sv_4 'σ_h = K₀·σ_v [kPa]
#: **σ_v = 180 kPa y σ_h = 90 kPa**: a 10 m el suelo ya aguanta 180 kPa encima, sin ninguna obra. **Con agua** (saturado, γ_sat = 20 kN/m³, agua en la superficie):
gt_4 = 20 'peso unitario saturado γ_sat [kN/m³]
gw_4 = 9.81 'peso unitario del agua γ_w [kN/m³]
st_4 = gt_4·zz_4 'σ total [kPa]
uw_4 = gw_4·zz_4 'presión del agua u = γ_w·z [kPa]
se_4 = st_4 - uw_4 'σ′ = σ − u [kPa]
#: De 200 kPa el agua toma 98.1 y los granos solo **101.9 kPa**: la mitad. Las tres rectas: σ_v y σ_h del suelo seco y σ′ del saturado. Pasa el cursor (eje horizontal: z en m; vertical: kPa):
#fplot(vertical_seco = 18*x, horizontal_seco = 9*x, efectivo_saturado = 10.19*x, [0 10])
#dibujo("Requisito 4: el suelo ya está apretado por su peso antes de construir", ud = m, escala = auto, cotas = m, alto = 80)
#  achurado([0, 9, 9, 0], [-10, -10, 0, 0], "terreno")
#  poligono(0, -10, 9, -10, 9, 0, 0, 0, "gruesa")
#  linea(-0.5, 0, 9.5, 0, "trazos azul")
#  texto(6.5, 0.45, "nivel del agua (caso 2)", 2.2, "i")
#  rect(2.6, -8.4, 0.8, 0.8, "gruesa")
#  flecha(3, -6.2, 3, -7.5, "gruesa rojo")
#  flecha(3, -9.8, 3, -8.5, "gruesa rojo")
#  flecha(1.6, -8, 2.5, -8, "media azul")
#  flecha(4.4, -8, 3.5, -8, "media azul")
#  texto(3.2, -6.4, "σv = γz = 180 kPa", 2.3, "i")
#  texto(4.6, -7.6, "σh = K0·σv = 90 kPa", 2.3, "i")
#  cota(-0.6, -8, -0.6, 0, 0, "z = 10 m")
#fin
#: Aprenderlo: σ′ = σ − u y el estado inicial σ_v, σ_h en la **hoja 201 (pasos 1 y 5)**; el peso propio en un punto de Gauss en la **hoja 133**; el empuje en reposo en la **hoja 117**.

## 5 · Plasticidad: el techo que depende de la presión
#: **Qué es:** un material es elástico (resorte) hasta un **techo**; ahí **fluye**: se deforma sin aguantar más. El techo se llama **superficie de fluencia** (o de falla).
#: **Por qué en geotecnia:** en el acero el techo es **un número**: f_y = 420 MPa, aprietes como aprietes. En el suelo el techo **sube con la presión**: un libro sobre la mesa cuesta más de deslizar cuanto más lo aprietas (fricción, tan φ), y la cohesión c es un pegamento que existe aunque no aprietes. Es **Mohr-Coulomb** (μ = tan φ es el coeficiente de fricción):
t_fal = Simplify{c + sigma*mu}
#: Un círculo de Mohr (centro σ_m, radio r) toca esa recta cuando su radio llega a:
r_max = Simplify{c*cos(phi) + sigma_m*sin(phi)}
#: Si el radio pasa de ahí, **f = r − r_máx > 0**: el punto es **plástico**. **Drucker-Prager** es el mismo techo «redondeado» (un cono sin esquinas): f = √J₂ + α·I₁ − k, con α y k sacados de c y φ (lo usa GEO5).
#dibujo("Requisito 5: el techo del acero es plano; el del suelo sube con la presión", ud = m, escala = auto, alto = 60)
#  flecha(0, 0, 7.4, 0, "fina")
#  flecha(0, 0, 0, 5, "fina")
#  texto(7.4, -0.4, "presión σ′", 2.2, "c")
#  texto(0.2, 5.1, "corte que aguanta τ", 2.2, "i")
#  linea(0, 3, 7, 3, "gruesa azul")
#  texto(1.2, 3.35, "acero: fy, siempre igual", 2.2, "i")
#  linea(0, 0.5, 7, 4.54, "gruesa rojo")
#  texto(3.6, 4.55, "suelo: τ = c + σ′·tan φ", 2.2, "d")
#  texto(0.3, 0.75, "c", 2.4, "i")
#fin
#: **Con números**, c = 10 kPa y φ = 30°, con σ′ = 100 kPa:
cs_5 = 10 'cohesión c [kPa]
fr_5 = 30·pi/180 'φ [rad]
sn_5 = 100 'presión efectiva σ′ [kPa]
tf_5 = cs_5 + sn_5·tan(fr_5) 'corte máximo τ = c + σ′·tan φ [kPa]
#: **¿El punto del requisito 3 aguanta?** Su círculo tiene centro 70 y radio 50:
rx_5 = cs_5·cos(fr_5) + mc_3·sin(fr_5) 'radio máximo que permite el techo [kPa]
fy_5 = mr_3 - rx_5 'f = r − r_máx (> 0: plástico) [kPa]
#: **f = 6.34 kPa > 0**: el círculo **atraviesa** la recta. Ese estado no puede existir: es un **punto plástico**. En un programa de elementos finitos esto se revisa en cada **punto de Gauss**: primero se calcula como si fuera elástico (predictor); si f > 0, se lo **devuelve al techo** (f = 0). Con ψ = 0 (sin dilatancia) el retorno de Mohr-Coulomb conserva el centro σ_m (Δσ₁ = −Δσ₃) y baja el radio a 43.66 kPa:
s1_5 = mc_3 + rx_5 'σ₁ devuelto [kPa]
s3_5 = mc_3 - rx_5 'σ₃ devuelto [kPa]
#: Pasa el cursor: el círculo del punto (elástico, atraviesa la recta), el devuelto al techo (la toca) y la recta de Mohr-Coulomb (eje horizontal σ′ en kPa; vertical τ en kPa):
#fplot(circulo_elastico = sqrt(max(0, 2500 - (x - 70)^2)), devuelto = sqrt(max(0, 1906.218 - (x - 70)^2)), Mohr_Coulomb = 10 + 0.57735*x, [0 140])
#: **El techo en 3D:** el corte que aguanta el suelo, τ = c + σ′·tan φ, para cualquier presión σ′ (x, kPa) y cualquier φ (y, grados), con c = 10 kPa. Con φ = 0 es plano como el acero; con φ grande sube rápido. Arrastra para girar:
t_s(x, y) = 10 + x*tan(y*pi/180)
#surf(t_s(x, y), [0 200], [0 45])
#map(t_s(x, y), [0 200], [0 45])
#: Aprenderlo (es el requisito **más difícil y la clave**): el punto de Gauss con predictor y retorno de Drucker-Prager en la **hoja 133**; edómetro y triaxial con Drucker-Prager en la **hoja 191**; Mohr-Coulomb con ángulo de Lode en la **hoja 193**; qué es un suelo no lineal en la **hoja 178**.

## 6 · Factor de seguridad por reducción de resistencia
#: **Qué es:** se **debilita** el suelo de a poco, dividiendo c y tan φ por un factor F, y se resuelve cada vez con Newton. Mientras converge, el talud se sostiene. El primer F con el que Newton **ya no converge** es el factor de seguridad.
#: **Por qué en geotecnia:** en una viga FS = resistencia / solicitación, una división. En un talud no hay «una» solicitación ni «una» resistencia: la resistencia depende de la presión (requisito 5) y la falla busca sola su camino. Por eso se debilita el material hasta que se cae.
c_red = Simplify{c/F}
t_red = Simplify{mu/F}
#: (μ = tan φ.) Con números, F = 1.5 (c = 10 kPa, φ = 30°):
fs_6 = 1.5 'factor de reducción F [-]
cr_6 = cs_5/fs_6 'c/F [kPa]
tr_6 = tan(fr_5)/fs_6 'tan φ / F [-]
pr_6 = atan(tr_6)·180/pi 'φ reducido [°]
#: El techo baja: c de 10 a 6.67 kPa y φ de 30° a 21.05°. Las rectas con F = 1, 1.25 y 1.5 (eje horizontal σ′ en kPa; vertical τ en kPa), pasa el cursor:
#fplot(original = 10 + 0.57735*x, reducido_F125 = 8 + 0.46188*x, reducido_F150 = 6.6667 + 0.3849*x, [0 200])
#: **Comprobación en un punto:** el círculo del requisito 3 toca justo el techo con F = 0.8266 (menos que 1: ese punto ya había fallado, como dijo f > 0):
fq_6 = 0.82663 'F con el que el círculo toca el techo [-]
pq_6 = atan(tan(fr_5)/fq_6) 'φ reducido [rad]
rq_6 = cs_5/fq_6·cos(pq_6) + mc_3·sin(pq_6) 'radio máximo con ese F (= 50) [kPa]
#: En un talud se hace lo mismo con **todos** los puntos de Gauss a la vez, y Newton dice si todavía hay equilibrio.
#dibujo("Requisito 6: se divide c y tan φ por F hasta que el talud se cae", ud = m, escala = auto, cotas = m, alto = 75)
#  achurado([0, 4, 10, 14, 14, 0], [0, 0, 4, 4, -3, -3], "terreno")
#  polilinea(0, 0, 4, 0, 10, 4, 14, 4, "gruesa")
#  polilinea(4.005, 0, 5.704, 0.275, 7.099, 0.783, 8.384, 1.525, 9.521, 2.479, 10.729, 4.0, "gruesa rojo")
#  flecha(8.6, 3.6, 7.6, 2.9, "media rojo")
#  texto(3.6, 5.6, "c/F, tan φ/F: F = 1.0 → 1.1 → 1.2 …", 2.4, "i")
#  texto(3.6, 4.7, "el primer F sin convergencia = FS", 2.4, "i")
#  texto(4, -0.6, "pie", 2.2, "c")
#  texto(10.7, 4.5, "cabeza", 2.2, "c")
#fin
#: En el talud de las hojas 190 y 195 (Griffiths y Lane, ejemplo 2, la misma malla): **Mohr-Coulomb 1.407 · Drucker-Prager de GEO5 1.524 · Mohr-Coulomb redondeado de Hekatan OpenSees 1.615**. La regla del techo cambia el FS.
#: Aprenderlo: **hojas 190 y 195**, la escalera de GEO5 en la **hoja 134**, y el video **https://youtu.be/eK8ux22PKkY**.

## 7 · Los 6 requisitos y dónde aprenderlos
#tabla("Requisito","Por qué hace falta en el suelo","Dónde aprenderlo")({"1 · FEM de estructuras: K·u = F","2 · Newton-Raphson: K_T·Δu = R","3 · Esfuerzos: Mohr, p y q","4 · σ′ = σ − u, σv = γz, K0","5 · Plasticidad (la clave)","6 · FS: c/F y tan φ/F"}; {"es la misma ecuación","el suelo se ablanda","cada punto tiene su estado","agua y peso propio","el techo sube con la presión","no hay una división simple"}; {"199, 200, viga Hermite","196, 198 + video Newton","178, 163, 191","201, 133, 117","133, 191, 193, 178","190, 195, 134 + video FS"})
#: **Ruta sugerida:** el 1 y el 2 ya los tienes (vigas y Newton). Sigue **3 → 4 → 5 → 6**. El **5 (plasticidad)** es el más difícil y la clave: es lo que hace que el suelo no sea una viga.
#: **Después:** la **hoja 201** y su video de introducción (los 8 pasos con un ejemplo pequeño). Y para saber **por qué** el método nació así: la historia en **https://youtu.be/yTmN8n9YMa0**.
