# Elementos finitos en estructuras (edificaciones, puentes y estructuras varias) vs elementos finitos geotécnicos: la tabla de las 8 diferencias y un mini ejemplo de cada lado
#numerico

## 0 · De dónde se parte
#: **¿Qué sé?** Un pórtico se resuelve con **K·u = F**: se arma la rigidez, se divide una vez y salen los desplazamientos y las fuerzas internas.
#: **¿Qué quiero?** Saber qué cambia cuando lo que se calcula es el **suelo** (taludes, zapatas sobre suelo, excavaciones, muros), no la estructura.
#: **¿Qué exijo?** El mismo método a los dos lados y números **verificados** con un programa de otro autor (Hekatan OpenSees, el OpenSees de Berkeley), no de memoria.
#: **¿Qué sale?** Ocho diferencias (la tabla de la sección 1) y un mini ejemplo de cada lado: un voladizo y un pórtico (estructuras) y un bloque de suelo de 4 × 4 m con su peso y una zapata (geotécnicos).
#: **¿Para qué?** Para elegir el modelo correcto en cada caso y entender lo que calcula el ingeniero geotécnico.
#dibujo("Los dos lados: a la izquierda un pórtico (piezas esbeltas con nudos), a la derecha el suelo (un continuo sin bordes)", ud = m, escala = auto, cotas = m, alto = 90)
#  linea(-6, 0, -6, 3, "gruesa")
#  linea(-2, 0, -2, 3, "gruesa")
#  linea(-6, 3, -2, 3, "gruesa")
#  circulo(-6, 3, 0.12, "rojo denso")
#  circulo(-2, 3, 0.12, "rojo denso")
#  flecha(-7.4, 3, -6.1, 3, "gruesa rojo")
#  texto(-7.3, 3.35, "H = 10 kN", 2.4, "d")
#  texto(-4, 3.45, "pórtico: nudos naturales", 2.4, "c")
#  cota(-6, -0.6, -2, -0.6, 0, "L = 4 m")
#  cota(-1.4, 0, -1.4, 3, 0, "h = 3 m")
#  achurado([1, 9, 9, 1], [-1, -1, 3, 3], "terreno")
#  poligono(1, -1, 9, -1, 9, 3, 1, 3, "trazos")
#  rect(4.5, 3, 1, 0.3, "concreto")
#  carga(4.5, 3.3, 5.5, 3.3, 0.6, 0.6, "q = 200 kPa", "rojo", n = 5)
#  texto(5, -0.6, "frontera artificial (se corta lejos)", 2.4, "c")
#  hover([-6, -2, 5], [3, 3, 3.3], "{#1:0}", [1, 2, 3])
#fin
#: (en el dibujo el bloque de suelo es didáctico: en un estudio real la frontera va a 3–5 veces el ancho de la zapata.)

## 1 · La tabla de las 8 diferencias
#: **Lado izquierdo: elementos finitos en estructuras** (edificaciones, puentes y estructuras varias):
#tabla("Eje","Elementos finitos en estructuras")({"1 · El objeto","2 · Los elementos","3 · El material","4 · De dónde se parte","5 · Qué se busca","6 · Cómo se resuelve","7 · Donde se juntan","8 · Programas"}; {"piezas esbeltas (barras, placas) con nudos naturales; pocos elementos","frame 6 GDL/nudo (Hermite), shell delgado DKT/DKQ o MITC4, sólidos con contacto y pernos en conexiones y placas base","acero y concreto elásticos en servicio; fluencia (fy) en conexiones o sismo fuerte","cero esfuerzos; cargas D, L, sismo desde cero; el orden no importa (superposición)","fuerzas internas M, V, N para diseñar con la norma","K·u = F una vez; sin solución = modelo mal armado","resortes de Winkler (k = k_s·A_trib), pilotes con resortes p-y","ETABS, SAP2000, SAFE; IDEA StatiCa o similares para conexiones"})
#: **Lado derecho: elementos finitos geotécnicos** (taludes, zapatas sobre suelo, excavaciones, muros):
#tabla("Eje","Elementos finitos geotécnicos")({"1 · El objeto","2 · Los elementos","3 · El material","4 · De dónde se parte","5 · Qué se busca","6 · Cómo se resuelve","7 · Donde se juntan","8 · Programas"}; {"medio continuo sin bordes: frontera artificial lejos; malla fina","T6/Q8 en deformación plana (2 GDL, sin giros), H8/T10 en 3D, interfaces suelo-muro","no lineal desde el inicio, resistencia que crece con la presión (Mohr-Coulomb, Drucker-Prager), agua: σ′ = σ − u","ya cargado por su peso (σ_v = γz, σ_h = K₀·σ_v); excavar = descargar; etapas: el orden importa","asientos, zonas plásticas y factor de seguridad (c/F, tan φ/F)","Newton-Raphson con escalones; no converger = el suelo falló","suelo mallado bajo la zapata: la presión se va a los bordes","GEO5, PLAXIS, OpenSees, Hekatan Geotechnic"})
#: **La idea en una frase:** por dentro es el mismo K·u = F; cambian el objeto, el material, el punto de partida y la pregunta.

## 2 · Estructuras (a): un voladizo con UN elemento
#: **¿Qué sé?** La viga de Euler-Bernoulli: la curvatura es w″ = M/(EI). **¿Qué quiero?** La flecha de la punta con P en el extremo. **¿Qué exijo?** Que el elemento finito dé lo mismo que la teoría.
#dibujo("Voladizo de 3 m con P = 10 kN en la punta: 1 elemento, 2 nudos", ud = m, escala = auto, cotas = m, alto = 60)
#  achurado([-0.3, 0, 0, -0.3], [-0.6, -0.6, 0.6, 0.6], "concreto")
#  linea(0, 0, 3, 0, "gruesa")
#  circulo(0, 0, 0.06, "rojo denso")
#  circulo(3, 0, 0.06, "rojo denso")
#  flecha(3, 0.9, 3, 0.05, "gruesa rojo")
#  texto(3.1, 0.8, "P = 10 kN", 2.4, "i")
#  cota(0, -0.5, 3, -0.5, 0, "L = 3 m")
#  hover([0, 3], [0, 0], "nudo {#1:0}", [1, 2])
#fin
#: **Simbólico primero.** Trabajo virtual con una carga unitaria en la punta: el momento real es M(x) = P·(L − x) y el virtual m(x) = (L − x):
d_s = Simplify{Area{P*(L - x)^2/(E*I) @ x = 0 : L}}
#: Es la fórmula de libro δ = P·L³/(3EI). El elemento de 2 nudos de Hermite (cúbico) contiene esa curva exacta, w(x) = P·x²·(3L − x)/(6EI), por eso **1 elemento basta**: la teoría de vigas ya resolvió lo que pasa por dentro.
#: **Números** (E = 200 GPa, I = 1·10⁻⁴ m⁴: E·I = 20 000 kN·m²):
P = 10 'carga en la punta [kN]
L = 3 'largo [m]
E = 200000000 'módulo del acero [kPa]
I = 0.0001 'inercia [m⁴]
d_p = 1000·P·L^3/(3·E·I) 'flecha de la punta [mm]
M_b = P·L 'momento en el empotramiento [kN·m]: con él se diseña la sección
#: La elástica (eje horizontal: x en m; vertical: w en mm, hacia abajo; pasa el cursor):
#fplot(w = 1000*10*x^2*(9 - x)/(6*20000), [0 3])
#: **En una línea:** en estructuras la teoría (Hermite) hace exacto un solo elemento; lo que se busca es M = P·L = 30 kN·m para la norma.

## 3 · Estructuras (b): un pórtico, K·u = F una sola vez
#: Pórtico de concreto (E = 25 GPa), h = 3 m, L = 4 m, columnas 0.30 × 0.30, viga 0.30 × 0.40, H = 10 kN arriba a la izquierda. Bases empotradas: quedan **6 incógnitas** (2 nudos × u, v, θ).
#: Matriz de un elemento de pórtico en ejes locales (axial EA/L y flexión de Hermite 12EI/L³, 6EI/L², 4EI/L, 2EI/L), girada con c = cos α, s = sen α:
E_c = 25000000 'módulo del concreto [kPa]
h = 3 'altura [m]
L_v = 4 'luz [m]
A_c = 0.09 'área de columna [m²]
I_c = 0.3·0.3^3/12 'inercia de columna [m⁴]
A_v = 0.12 'área de viga [m²]
I_v = 0.3·0.4^3/12 'inercia de viga [m⁴]
H = 10 'carga lateral [kN]
#hide
X_n = [0, 0, 4, 4]
Y_n = [0, 3, 3, 0]
E_l = [1, 2, 0.09, 0.000675; 2, 3, 0.12, 0.0016; 4, 3, 0.09, 0.000675]
K_g = zeros(12, 12)
for i_e = 1:3
  n_i = E_l(i_e, 1)
  n_j = E_l(i_e, 2)
  A_e = E_l(i_e, 3)
  I_e = E_l(i_e, 4)
  d_x = X_n(n_j) - X_n(n_i)
  d_y = Y_n(n_j) - Y_n(n_i)
  L_e = sqrt(d_x^2 + d_y^2)
  c_a = d_x/L_e
  s_a = d_y/L_e
  k_a = E_c·A_e/L_e
  k_b = 12·E_c·I_e/L_e^3
  k_c = 6·E_c·I_e/L_e^2
  k_d = 4·E_c·I_e/L_e
  k_l = [k_a, 0, 0, -k_a, 0, 0; 0, k_b, k_c, 0, -k_b, k_c; 0, k_c, k_d, 0, -k_c, k_d/2; -k_a, 0, 0, k_a, 0, 0; 0, -k_b, -k_c, 0, k_b, -k_c; 0, k_c, k_d/2, 0, -k_c, k_d]
  T_r = [c_a, s_a, 0, 0, 0, 0; -s_a, c_a, 0, 0, 0, 0; 0, 0, 1, 0, 0, 0; 0, 0, 0, c_a, s_a, 0; 0, 0, 0, -s_a, c_a, 0; 0, 0, 0, 0, 0, 1]
  k_g = transpose(T_r)·k_l·T_r
  i_d = [3·n_i - 2, 3·n_i - 1, 3·n_i, 3·n_j - 2, 3·n_j - 1, 3·n_j]
  K_g(i_d, i_d) = K_g(i_d, i_d) + k_g
end
L_b = [4, 5, 6, 7, 8, 9]
F_g = zeros(12, 1)
F_g(4) = H
#show
K_L = K_g(L_b, L_b) 'rigidez de los 6 movimientos libres [kN/m, kN/rad, kN·m/rad]
F_L = F_g(L_b) 'cargas en los nudos libres [kN, kN·m]
u_L = lsolve(K_L, F_L) 'UNA división: u₂, v₂, θ₂, u₃, v₃, θ₃ [m, rad]
u_t = 1000·u_L(1) 'desplazamiento del techo [mm]
M_1 = 6·E_c·I_c/h^2·u_L(1) + 2·E_c·I_c/h·u_L(3) 'momento en la base izquierda [kN·m]
u_r = 1000·H·h^3/(24·E_c·I_c) 'si la viga fuera infinitamente rígida [mm]
#: **En una línea:** 6 incógnitas, una sola división: el techo se mueve 0.845 mm (0.667 mm con viga rígida) y cada base toma unos 8 kN·m. Hekatan OpenSees (elasticBeamColumn) da lo mismo en 14 cifras.

## 4 · Geotécnicos (a): el suelo ya está cargado por su peso
#: **¿Qué sé?** Un bloque de suelo de H = 4 m pesa γ = 18 kN/m³ y tiene un módulo confinado M = λ + 2G = 30 000 kPa (E = 20 MPa, ν = 1/3). **¿Qué quiero?** Cuánto se hunde la superficie por su propio peso. **¿Qué exijo?** Que sea el mismo número de la hoja 201 (4 elementos Q4).
#dibujo("Columna de suelo de 4 m: σ_v = γz crece con la profundidad (pasa el cursor)", ud = m, escala = auto, cotas = m, alto = 70)
#  achurado([0, 1, 1, 0], [-4, -4, 0, 0], "terreno")
#  poligono(0, -4, 1, -4, 1, 0, 0, 0, "gruesa")
#  poligono(1.3, 0, 1.3, -4, 3.3, -4, "media rojo")
#  texto(2.6, -1.2, "σ_v = γ·z", 2.4, "i")
#  cota(-0.3, -4, -0.3, 0, 0, "H = 4 m")
#  hover([1.8, 2.3, 2.8, 3.3], [-1, -2, -3, -4], "z = {#1:0} m: σ_v = {#2:0} kPa", [1, 2, 3, 4], [18, 36, 54, 72])
#fin
#: **Simbólico:** cada capa dz se acorta (γz/M)·dz; se suma de 0 a H:
s_g = Simplify{Area{γ*z/M_m @ z = 0 : H_m}}
g_s = 18 'peso unitario [kN/m³]
M_c = 30000 'módulo confinado λ + 2G [kPa]
H_s = 4 'altura del bloque [m]
s_p = 1000·g_s·H_s^2/(2·M_c) 'asiento por peso propio [mm]: el mismo de la hoja 201
#: Y luego **los desplazamientos vuelven a cero**: esos 4.8 mm pasaron hace miles de años. Se guardan los esfuerzos (σ_h = K₀·σ_v con K₀ = 1 − sen φ = 0.5). En una estructura el peso es una carga más; en el suelo es el **punto de partida**.
#: **La resistencia crece con la presión** (Mohr-Coulomb, c = 10 kPa, φ = 30°): τ_f = c + σ′·tan φ. Eje horizontal: σ′ en kPa; vertical: τ en kPa (pasa el cursor):
#fplot(Mohr_Coulomb = 10 + 0.57735*x, acero_fy_no_depende = 0*x + 145, [0 200])
#: (la recta horizontal es solo para comparar: la resistencia de una sección de acero no depende de cuánto la aprietan.)

## 5 · Geotécnicos (b): zapata sobre el bloque, lineal vs Drucker-Prager con Newton
#: Los resultados son los de la **hoja 201** (bloque de 4 × 4 m, 4 elementos Q4, media zapata de B = 2 m con q = 200 kPa), comprobados nudo a nudo contra Hekatan OpenSees a 4 decimales.
#: Lineal: **un** K·u = F → 18.4694 mm. Con Drucker-Prager: **Newton-Raphson**, K_T·Δu = R hasta que el residuo R = F − f_int sea cero:
n_v = [0, 1, 2, 3, 4] 'vuelta de Newton
R_v = [158.113883, 12.632616, 0.701562, 0.002404, 0.00000003] 'residuo |R| [kN] (hoja 201)
#tabla("vuelta:0","|R| [kN]:8")(n_v; R_v)
#: Curva carga – asiento bajo el centro (10 escalones; azul = elástico, rojo = con el techo; pasa el cursor):
q_k = [0, 20, 40, 60, 80, 100, 120, 140, 160, 180, 200] 'presión [kPa]
a_n = [0, 1.846938, 3.693876, 5.540813, 7.387751, 9.234689, 11.205143, 13.205988, 15.448714, 17.817372, 20.275490] 'asiento no lineal [mm] (hoja 201)
k_x = q_k/10 'x del dibujo
m_y = 0 - a_n 'y del dibujo
#dibujo("Carga – asiento: elástico (azul) contra Drucker-Prager (rojo)", ud = m, escala = auto, alto = 80)
#  linea(0, 0, 22, 0, "fina")
#  linea(0, 0, 0, -22, "fina")
#  polilinea([0, 20], [0, -18.469], "gruesa azul")
#  polilinea(k_x, m_y, "gruesa rojo")
#  texto(22.5, -17.5, "elástico", 0.9, "i")
#  texto(22.5, -20.8, "con techo", 0.9, "i")
#  texto(10, 1.3, "q [kPa] (cada raya = 50 kPa)", 0.9, "c")
#  linea(5, 0, 5, 0.4, "fina")
#  linea(10, 0, 10, 0.4, "fina")
#  linea(15, 0, 15, 0.4, "fina")
#  linea(20, 0, 20, 0.4, "fina")
#  texto(-3.2, -10, "asiento [mm]", 0.9, "c")
#  linea(0, -10, -0.4, -10, "fina")
#  linea(0, -20, -0.4, -20, "fina")
#  hover(k_x, m_y, "q = {#1:0} kPa: asiento = {#2:2} mm", q_k, a_n)
#fin
#: **En una línea:** de una vez (1 paso de carga) el asiento no lineal es 20.3229 mm, 10 % más que el elástico, con 6 de 16 puntos de Gauss en el techo. En el suelo, **que Newton no converja es la respuesta**: el suelo falló; por eso el factor de seguridad se busca debilitando c y tan φ hasta que no converge (talud de Griffiths y Lane con malla fina: 1.407 Mohr-Coulomb, 1.524 Drucker-Prager de GEO5, 1.615 OpenSees).

## 6 · Donde se juntan: zapata sobre resortes vs suelo continuo
#: Zapata de 1.5 × 1.5 m, P = 400 kN, M_x = 40 y M_y = 20 kN·m (**hoja 177**). Con resortes de Winkler (k = k_s·A_trib, cada resorte independiente) la presión es casi la recta de la fórmula rígida; con el suelo mallado (membrana 2D, corte en y = 0, OpenSees quad PlaneStrain) la presión se va a los bordes.
#dibujo("Zapata sobre resortes: cada resorte lleva su parte, sin sentir al vecino", ud = m, escala = auto, cotas = m, alto = 60)
#  achurado([-0.75, 0.75, 0.75, -0.75], [0, 0, 0.6, 0.6], "concreto")
#  rect(-0.75, 0, 1.5, 0.6, "gruesa")
#  polilinea([-0.75, -0.7, -0.8, -0.7, -0.8, -0.75], [0, -0.1, -0.2, -0.3, -0.4, -0.5], "media azul")
#  polilinea([0, 0.05, -0.05, 0.05, -0.05, 0], [0, -0.1, -0.2, -0.3, -0.4, -0.5], "media azul")
#  polilinea([0.75, 0.8, 0.7, 0.8, 0.7, 0.75], [0, -0.1, -0.2, -0.3, -0.4, -0.5], "media azul")
#  linea(-1, -0.5, 1, -0.5, "gruesa")
#  flecha(0, 1.5, 0, 0.65, "gruesa rojo")
#  texto(0.1, 1.4, "P, M", 2.4, "i")
#  cota(-0.75, -0.8, 0.75, -0.8, 0, "B = 1.5 m")
#  hover([-0.75, 0, 0.75], [-0.25, -0.25, -0.25], "resorte en x = {#1:2} m", [-0.75, 0, 0.75])
#fin
x_z = [-0.75, -0.5, -0.25, 0, 0.25, 0.5, 0.75] 'posición en y = 0 [m]
q_r = 400/2.25 + 20·x_z/(1.5^4/12) 'Winkler ≈ fórmula rígida P/A + M_y·x/I [kPa]
q_c = [381.707985, 129.868413, 113.40839, 113.70614, 122.403693, 152.64128, 487.569516] 'suelo continuo 2D, OpenSees [kPa] (hoja 177)
#tabla("x [m]:2","resortes (rígida) [kPa]:1","suelo continuo [kPa]:1")(x_z; q_r; q_c)
k_z = 10·x_z 'x del dibujo
r_y = 0 - q_r/40 'y del dibujo, resortes
c_y = 0 - q_c/40 'y del dibujo, continuo
#dibujo("Presión bajo la zapata en y = 0: resortes (azul) vs suelo continuo (rojo); pasa el cursor", ud = m, escala = auto, alto = 70)
#  linea(-8, 0, 8, 0, "gruesa")
#  polilinea(k_z, r_y, "gruesa azul")
#  polilinea(k_z, c_y, "gruesa rojo")
#  texto(0, 1.2, "zapata: x de −0.75 a 0.75 m", 2.4, "c")
#  texto(8.3, -5.3, "resortes", 2.4, "i")
#  texto(8.3, -12.2, "continuo", 2.4, "i")
#  texto(-8.3, -9.5, "382 kPa", 2.4, "d")
#  texto(-8.3, -3.5, "142 kPa", 2.4, "d")
#  texto(0, -1.8, "≈114 kPa", 2.4, "c")
#  texto(0, -14, "presión hacia abajo: cada unidad = 40 kPa", 2.4, "c")
#  hover(k_z, r_y, "x = {#1:2} m · resortes: {#2:1} kPa", x_z, q_r)
#  hover(k_z, c_y, "x = {#1:2} m · continuo: {#2:1} kPa", x_z, q_c)
#fin
#: **3D:** la presión de la zapata sobre resortes es un plano, q(x, y) = P/A + M_y·x/I − M_x·y/I (arrastra para girar, pasa el cursor; x, y en m, q en kPa):
#surf(400/2.25 + 20*x/0.421875 - 40*y/0.421875, [-0.75 0.75], [-0.75 0.75])
#: **Por qué la diferencia:** un resorte no siente a su vecino; el suelo real sí (lo que se hunde bajo un punto arrastra al de al lado). Los resortes son la **aproximación estructural** del suelo: sirven para diseñar la zapata, la losa de cimentación o un pilote (resortes p-y), pero **k_s no es una propiedad del suelo**: sale del asiento que calcula el geotécnico (k_s = q/s).

## 7 · Verificación y qué falta
#tabla("Resultado","Hekatan / Python","OpenSees","Fuente")({"voladizo: flecha [mm]","voladizo: M base [kN·m]","pórtico: u techo [mm]","pórtico: M base izquierda [kN·m]","suelo: peso propio [mm]","suelo lineal: asiento [mm]","suelo Drucker-Prager: asiento [mm]","Winkler: q centro [kPa]"}; {"4.500000","30.000000","0.844548","8.182083","4.8000","18.4694","20.3229","178.811271"}; {"4.500000","30.000000","0.844548","8.182083","4.8000","18.4694","20.3229","178.811271"}; {"esta hoja","esta hoja","esta hoja","esta hoja","hoja 201","hoja 201","hoja 201","hoja 177"})
#: **Qué queda:** el método es el mismo, K·u = F. Cambian el objeto, el material, el punto de partida y la pregunta.
#: **Qué falta:** interfaces suelo-estructura, el agua que se mueve (consolidación) y el sismo en el suelo. Las hojas 201 (los 8 pasos), 177 (zapata) y 135-138 (zapatas sobre Winkler) siguen el tema.
