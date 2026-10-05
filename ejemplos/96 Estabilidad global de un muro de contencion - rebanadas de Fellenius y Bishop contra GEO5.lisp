# Estabilidad global del muro de Manabí: rebanadas de Fellenius y de Bishop contra GEO5
#numerico

#: **Qué se comprueba.** El muro puede no volcar ni deslizar sobre su base y, aun así, fallar **junto con el terreno**: el muro, el relleno y el suelo de apoyo giran como un solo bloque sobre una superficie circular que pasa **por debajo de la zapata**. Es la estabilidad general (NEC-SE-GC, tabla 5).
#: **Cómo se calcula.** La masa que queda encima del círculo se corta en **rebanadas verticales**. Se compara el momento que la hace girar respecto al centro del círculo, M_{a}, con el que el rozamiento de la base resiste, M_{p}. El factor de seguridad es el cociente de los dos: FS = M_{p} / M_{a}.
#: **Unidades.** kN y m, por metro de muro. Donde importa se da también en tonf (1 tonf = 9.80665 kN).
#: **Árbitro.** GEO5 2024 · Estabilidad de taludes, con el mismo muro y el mismo terreno (medido el 29-sep-2026 por su interfaz). Referencia en Python con la misma formulación: el guion estabilidad_rebanadas.py de la serie del muro de Manabí (Hekatan School).

## 1 · Datos
#: Ejes de GEO5: x = 0 en la cara del relleno del fuste, z = 0 en la coronación, z hacia arriba.
#: **Muro en voladizo** de 3.00 m: zapata de 3.00 × 0.40 m (puntera 0.70 m, talón 1.90 m), fuste de 0.25 m arriba y 0.40 m abajo. Su polígono: (−1.10; −3.00) (1.90; −3.00) (1.90; −2.60) (0; −2.60) (0; 0) (−0.25; 0) (−0.40; −2.60) (−1.10; −2.60).
γ_c = 23 [kN/m³] 'hormigón del muro
γ_r = 18.5 [kN/m³] 'arena SP: relleno (z = 0 a −3.00) y terreno de delante (z = −2.30 a −3.00)
γ_f = 17.5 [kN/m³] 'arena con limo SP-SM, bajo z = −3.00 (estudio de suelos)
φ_r = 30 [°] 'arena SP, c = 0
φ_f = 29.97 [°] 'arena con limo SP-SM, c = 0
#: El terreno de delante llega a z = −2.30: tapa 0.70 m la base de la zapata. Toca el frente inclinado del fuste en:
x_F = -0.25 - 0.15·2.3/2.6 [m]
#: **Sismo seudoestático** (NEC-SE-GC 4.2.2): una fuerza horizontal k_{h}·W en cada rebanada, con k_{h} = 0.6·Z·F_{a}; sin componente vertical (k_{v} = 0).
Z = 0.5 'zona sísmica VI (NEC-SE-DS)
F_a = 1.12 'perfil de suelo D (NEC-SE-DS, tabla 3)
k_h = 0.6·Z·F_a
#: **Factores exigidos** (NEC-SE-GC, tabla 5, estabilidad general): 1.50 sin sismo y 1.05 con sismo.
#: **Sin nivel freático en el modelo.** El estudio de suelos lo da a −3.05 m, 5 cm bajo la zapata; queda pendiente (con agua la presión de poros resta a la normal y el FS baja).

## 2 · El círculo con sismo
#: Es el círculo crítico que halló GEO5 con el método de Bishop y optimización:
x_c = -1.21 [m] 'centro, abscisa
z_c = 7.46 [m] 'centro, cota
R = 10.91 [m] 'radio
#: El círculo sale por el terreno de delante (z = −2.30) y entra por el relleno (z = 0). Son los dos cortes del círculo con esas rectas:
x_a = x_c - sqrt(R^2 - (z_c + 2.3)^2) [m]
x_b = x_c + sqrt(R^2 - z_c^2) [m]
#: Se divide [x_{a}, x_{b}] en n rebanadas del mismo ancho:
n = 24 'rebanadas
b = (x_b - x_a)/n [m] 'ancho de cada rebanada
#: **La base de cada rebanada es recta**: la cuerda entre los dos puntos del círculo. Así lo hace GEO5, que sustituye el arco por una poligonal. Medido: con el arco exacto el momento sale de +0.2 % a +0.7 % sobre GEO5; con la cuerda y 24 rebanadas, de 0.02 % a 0.2 %.
#dibujo("Muro, terreno, círculo de Bishop con sismo y sus 24 rebanadas", ud = m, cotas = m, ancho = 175, alto = 175)
#  achurado([-1.1, 1.9, 1.9, 0, 0, -0.25, -0.4, -1.1], [-3, -3, -2.6, -2.6, 0, 0, -2.6, -2.6], "concreto")
#  poligono(-1.1, -3, 1.9, -3, 1.9, -2.6, 0, -2.6, 0, 0, -0.25, 0, -0.4, -2.6, -1.1, -2.6, "gruesa")
#  linea(-7, -2.3, -0.383, -2.3, "media")
#  linea(0, 0, 8, 0, "media")
#  linea(-7, -3, -1.1, -3, "trazos gris")
#  linea(1.9, -3, 8, -3, "trazos gris")
#  polilinea([-6.09, -6.09, -6.09, -5.55, -5.55, -5.55, -5.02, -5.02, -5.02, -4.48, -4.48, -4.48, -3.95, -3.95, -3.95, -3.41, -3.41, -3.41, -2.88, -2.88, -2.88, -2.34, -2.34, -2.34, -1.81, -1.81, -1.81, -1.27, -1.27, -1.27, -0.74, -0.74, -0.74, -0.20, -0.20, -0.20, 0.33, 0.33, 0.33, 0.87, 0.87, 0.87, 1.40, 1.40, 1.40, 1.94, 1.94, 1.94, 2.47, 2.47, 2.47, 3.01, 3.01, 3.01, 3.54, 3.54, 3.54, 4.08, 4.08, 4.08, 4.61, 4.61, 4.61, 5.15, 5.15, 5.15, 5.68, 5.68, 5.68, 6.22, 6.22, 6.22, 6.75, 6.75, 6.75], [-2.30, -2.30, -2.30, -2.55, -2.30, -2.55, -2.76, -2.30, -2.76, -2.95, -2.30, -2.95, -3.10, -2.30, -3.10, -3.23, -2.30, -3.23, -3.32, -2.30, -3.32, -3.39, -2.30, -3.39, -3.43, -2.30, -3.43, -3.45, -2.30, -3.45, -3.44, -2.30, -3.44, -3.40, 0.00, -3.40, -3.34, 0.00, -3.34, -3.25, 0.00, -3.25, -3.13, 0.00, -3.13, -2.99, 0.00, -2.99, -2.81, 0.00, -2.81, -2.60, 0.00, -2.60, -2.36, 0.00, -2.36, -2.08, 0.00, -2.08, -1.77, 0.00, -1.77, -1.41, 0.00, -1.41, -1.00, 0.00, -1.00, -0.53, 0.00, -0.53, 0.00, 0.00, 0.00], "fina azul")
#  polilinea([-6.086, -5.735, -5.379, -5.018, -4.652, -4.281, -3.907, -3.529, -3.148, -2.765, -2.380, -1.993, -1.605, -1.217, -0.829, -0.441, -0.054, 0.331, 0.714, 1.095, 1.473, 1.848, 2.218, 2.585, 2.946, 3.302, 3.653, 3.997, 4.335, 4.666, 4.989, 5.305, 5.612, 5.911, 6.200, 6.481, 6.751], [-2.300, -2.467, -2.622, -2.764, -2.893, -3.009, -3.111, -3.201, -3.277, -3.339, -3.387, -3.422, -3.443, -3.450, -3.443, -3.423, -3.389, -3.341, -3.279, -3.204, -3.115, -3.013, -2.897, -2.769, -2.627, -2.473, -2.306, -2.127, -1.936, -1.732, -1.518, -1.291, -1.054, -0.806, -0.547, -0.278, 0.000], "gruesa rojo")
#  linea(-1.21, 7.46, -6.086, -2.3, "fina trazos rojo")
#  linea(-1.21, 7.46, 6.751, 0, "fina trazos rojo")
#  circulo(-1.21, 7.46, 0.12, "rojo relleno")
#  texto(-1.0, 7.75, "centro (−1.21; 7.46)", 2.6, "i", estilo = "rojo")
#  texto(3.4, 4.0, "R = 10.91 m", 2.6, "i", estilo = "rojo")
#  flecha(4.34, 1.2, 4.34, -0.96, "negro")
#  flecha(5.6, -0.96, 4.34, -0.96, "naranja")
#  texto(4.2, 0.9, "W_{i}", 2.6, "d")
#  texto(4.1, -1.5, "k_{h}·W_{i}", 2.6, "d", estilo = "naranja")
#  texto(2.2, 0.35, "relleno SP", 2.4, "c")
#  texto(-5.0, -2.05, "terreno SP", 2.4, "c")
#  texto(3.5, -3.75, "SP-SM", 2.4, "c", estilo = "gris")
#  texto(-6.1, -2.75, "x_{a}", 2.4, "d", estilo = "rojo")
#  texto(6.95, 0.3, "x_{b}", 2.4, "i", estilo = "rojo")
#fin
#: Las flechas enseñan las dos cargas de una rebanada: el peso W_{i}, vertical, y la fuerza de sismo k_{h}·W_{i}, horizontal, hacia el frente del muro, que es hacia donde gira la masa. Las dos actúan en el centro de gravedad de la rebanada.

## 3 · El peso de cada rebanada
#: En la vertical de abscisa x cada material ocupa un tramo de cotas [a, b]. Sobre la base de la rebanada (cota z) solo pesa la parte del tramo que queda por encima:
L_z(a, b, z) = max(0, b - max(a, z))
#: El peso de la columna de ancho dx es Σ γ·L_{z}·dx sobre los tres materiales (hormigón 23, arena 18.5, arena con limo 17.5), y el peso de la rebanada es la suma de sus columnas. Se toman **400 columnas** por rebanada; con la base recta cada columna tiene su cota de base sobre la cuerda. El centro de gravedad (x_{g}, z_{g}) sale de los momentos estáticos de las mismas columnas.
#: **Inclinación de la base**: α_{i} = atan((z_{i+1} − z_{i}) / b). **Rozamiento de la base**: φ = 29.97° si el punto medio de la base está bajo z = −3.00 (arena con limo); si no, 30°.
#hide
u_v(x, a, b) = (sign(x - a) + 1)·(sign(b - x) + 1)/4
z_m(x) = (x + 0.25)·2.6/0.15
Q_z(a, b, z) = L_z(a, b, z)·(max(a, z) + b)/2
q_c(x, z) = γ_c·(u_v(x, -1.1, 1.9)·L_z(-3, -2.6, z) + u_v(x, -0.4, 0)·L_z(-2.6, min(0, z_m(x)), z))
q_r(x, z) = γ_r·(u_v(x, 0, 1.9)·L_z(-2.6, 0, z) + u_v(x, 1.9, 50)·L_z(-3, 0, z) + u_v(x, -50, -1.1)·L_z(-3, -2.3, z) + u_v(x, -1.1, x_F)·L_z(max(-2.6, z_m(x)), -2.3, z))
q_f(x, z) = γ_f·L_z(-40, -3, z)
m_z(x, z) = γ_c·(u_v(x, -1.1, 1.9)·Q_z(-3, -2.6, z) + u_v(x, -0.4, 0)·Q_z(-2.6, min(0, z_m(x)), z)) + γ_r·(u_v(x, 0, 1.9)·Q_z(-2.6, 0, z) + u_v(x, 1.9, 50)·Q_z(-3, 0, z) + u_v(x, -50, -1.1)·Q_z(-3, -2.3, z) + u_v(x, -1.1, x_F)·Q_z(max(-2.6, z_m(x)), -2.3, z)) + γ_f·Q_z(-40, -3, z)
s = 400
h = b/s
W = zeros(n, 1)
W_c = zeros(n, 1)
W_r = zeros(n, 1)
W_f = zeros(n, 1)
x_g = zeros(n, 1)
z_g = zeros(n, 1)
α = zeros(n, 1)
φ = zeros(n, 1)
x_i = zeros(n + 1, 1)
z_i = zeros(n + 1, 1)
for i = 1:n + 1
  x_i(i) = x_a + (i - 1)·b
  z_i(i) = z_c - sqrt(R^2 - (x_i(i) - x_c)^2)
end
for i = 1:n
  M_x = 0
  M_y = 0
  for k = 1:s
    x = x_i(i) + (k - 0.5)·h
    z = z_i(i) + (z_i(i + 1) - z_i(i))·(x - x_i(i))/b
    W_c(i) = W_c(i) + q_c(x, z)·h
    W_r(i) = W_r(i) + q_r(x, z)·h
    W_f(i) = W_f(i) + q_f(x, z)·h
    M_x = M_x + (q_c(x, z) + q_r(x, z) + q_f(x, z))·h·x
    M_y = M_y + m_z(x, z)·h
  end
  W(i) = W_c(i) + W_r(i) + W_f(i)
  x_g(i) = M_x/W(i)
  z_g(i) = M_y/W(i)
  α(i) = atan2(z_i(i + 1) - z_i(i), b)
  φ(i) = φ_r·pi/180
  if (z_i(i) + z_i(i + 1))/2 < -3
    φ(i) = φ_f·pi/180
  end
end
Reb_1 = zeros(8, 7)
Reb_2 = zeros(8, 7)
Reb_3 = zeros(8, 7)
for i = 1:8
  for j = 0:2
    k = i + 8·j
    F_l = [k, round(x_i(k), 4), round(x_i(k + 1), 4), round(W(k), 4), round(x_g(k), 4), round(z_g(k), 4), round(α(k)·180/pi, 4)]
    if j == 0
      Reb_1(i, :) = F_l
    end
    if j == 1
      Reb_2(i, :) = F_l
    end
    if j == 2
      Reb_3(i, :) = F_l
    end
  end
end
#show
#: **Un ejemplo: la rebanada 12**, la que pasa bajo el fuste. Su peso por material, en kN:
W_c12 = W_c(12) [kN] 'hormigón de la zapata y del fuste
W_r12 = W_r(12) [kN] 'relleno SP
W_f12 = W_f(12) [kN] 'arena con limo bajo la zapata
W_12 = W_c12 + W_r12 + W_f12 [kN]
#: El hormigón pesa casi la mitad de la rebanada: el muro es la carga más grande del círculo, y está en el lado que hace girar.
#: **Las 24 rebanadas.** Columnas: i · x_{1} · x_{2} [m] · W [kN] · x_{g} · z_{g} [m] · α [°]. Rebanadas 1 a 8, 9 a 16 y 17 a 24:
Reb_1
Reb_2
Reb_3
#: El peso de cada rebanada, dibujado en la abscisa de su punto medio (valores de la tabla de arriba). El salto en x ≈ 0 es el muro:
#fplot(W_i = [-5.818 1.23; -5.283 3.53; -4.748 5.51; -4.214 7.15; -3.679 8.46; -3.144 9.49; -2.609 10.26; -2.074 10.79; -1.539 11.06; -1.004 11.74; -0.470 18.13; 0.065 36.49; 0.600 33.41; 1.135 32.44; 1.670 31.14; 2.205 28.68; 2.740 26.77; 3.274 24.55; 3.809 21.99; 4.344 19.05; 4.879 15.70; 5.414 11.90; 5.949 7.57; 6.484 2.63], [-6.2 6.9])
#: La inclinación de la base: sen α de cada cuerda (puntos) y sen α del arco en cada x (recta, sen α = (x − x_{c}) / R). Los puntos caen sobre la recta porque la cuerda es paralela a la tangente del arco en su punto medio. A la izquierda del centro la base sube hacia el frente (α < 0) y esa parte **frena** el giro; a la derecha baja (α > 0) y **empuja**:
#fplot(arco = (x + 1.21)/10.91, cuerda = [-5.818 -0.4225; -5.283 -0.3735; -4.748 -0.3244; -4.214 -0.2754; -3.679 -0.2263; -3.144 -0.1773; -2.609 -0.1283; -2.074 -0.0792; -1.539 -0.0302; -1.004 0.0188; -0.470 0.0679; 0.065 0.1169; 0.600 0.1660; 1.135 0.2150; 1.670 0.2640; 2.205 0.3131; 2.740 0.3621; 3.274 0.4112; 3.809 0.4602; 4.344 0.5093; 4.879 0.5584; 5.414 0.6074; 5.949 0.6565; 6.484 0.7056], [-6.2 6.9])

## 4 · El momento que hace girar la masa
#: Respecto al centro del círculo, el peso de una rebanada tiene brazo horizontal (x_{g} − x_{c}) y la fuerza de sismo, brazo vertical (z_{c} − z_{g}). Se suman todas las rebanadas:
#: M_{a} = Σ W_{i}·(x_{g,i} − x_{c}) + k_{h}·Σ W_{i}·(z_{c} − z_{g,i})
#: Parte del **peso**. Las rebanadas a la izquierda del centro restan, porque su peso gira en sentido contrario:
M_W = sum(W.*(x_g - x_c)) [kN·m/m]
#: Parte del **sismo**. Todas suman: toda la masa está debajo del centro y la fuerza va hacia el frente:
M_S = k_h·sum(W.*(z_c - z_g)) [kN·m/m]
M_as = M_W + M_S [kN·m/m]
M_ast = M_as/9.80665 [tonf·m/m]
#: El sismo aporta más de la mitad del momento que hace girar: con un círculo tan grande el brazo vertical z_{c} − z_{g} es de unos 10 m.

## 5 · Fellenius (Petterson)
#: **Hipótesis.** Cada rebanada se trata sola: **no hay fuerzas entre rebanadas** (ni normales E_{i} ni cortantes X_{i}). Solo se cumple el equilibrio de momentos de toda la masa respecto al centro (ayuda de GEO5, «Fellenius / Petterson»; Petterson, Géotechnique 5, 1955).
#: Sin fuerzas entre rebanadas, la normal en la base es la proyección de las cargas de la rebanada sobre la normal a su base: el peso aprieta con W·cos α; el sismo, horizontal, con −k_{h}·W·sen α.
#: N_{i} = W_{i}·cos α_{i} − k_{h}·W_{i}·sen α_{i}
N = W.*cos(α) - k_h·W.*sin(α)
#: Con c = 0 y sin agua, la base resiste N·tan φ; su brazo respecto al centro es el radio R:
#: M_{p} = R·Σ N_{i}·tan φ_{i}
M_Fs = R·sum(N.*tan(φ)) [kN·m/m]
FS_Fs = M_Fs/M_as
#: Con sismo, Fellenius da FS = @{FS_Fs} **< 1.05**: en este círculo no cumple.

## 6 · Bishop simplificado
#: **Hipótesis.** Entre rebanadas solo hay fuerzas **horizontales** (X_{i} = 0, sin cortante entre rebanadas). Se cumple el equilibrio **vertical de cada rebanada** y el de momentos de toda la masa (ayuda de GEO5, «Bishop»; Bishop, Géotechnique 5(1):7-17, 1955).
#: **De dónde sale la normal.** En la base actúan la normal N y el cortante movilizado N·tan φ / FS. Equilibrio vertical de la rebanada: N·cos α + (N·tan φ / FS)·sen α = W. El sismo es horizontal y no entra en esta ecuación. Despejando:
#: N_{i} = W_{i} / (cos α_{i} + tan φ_{i}·sen α_{i} / FS)
#: y el momento resistente es, como antes, R·Σ N_{i}·tan φ_{i}:
#: M_{p} = R·Σ W_{i}·tan φ_{i} / (cos α_{i} + tan φ_{i}·sen α_{i} / FS)
#: **FS aparece a los dos lados**: hay que iterar. Se empieza con FS = 1, se calcula M_{p}, el nuevo FS es M_{p} / M_{a}, y se repite hasta que no cambie. Cada vuelta del bucle imprime el FS de esa vuelta:
F_k = 1
for k = 1:8
  F_k = R·sum(W.*tan(φ)./(cos(α) + tan(φ).*sin(α)/F_k))/M_as
  disp(F_k)
end
#: A la quinta vuelta ya no cambian las seis primeras cifras. Se sigue hasta que la diferencia entre dos vueltas es menor que 10⁻¹²:
#hide
for k = 1:40
  F_k = R·sum(W.*tan(φ)./(cos(α) + tan(φ).*sin(α)/F_k))/M_as
end
#show
M_Bs = R·sum(W.*tan(φ)./(cos(α) + tan(φ).*sin(α)/F_k)) [kN·m/m]
FS_Bs = M_Bs/M_as
M_Bst = M_Bs/9.80665 [tonf·m/m]
#: Con sismo, Bishop da FS = @{FS_Bs} **> 1.05**: cumple, con un margen de 4 %.
#: **Por qué Bishop da más que Fellenius.** Se comparan las dos normales de una misma rebanada (φ = 30°, FS = 1.09). En el frente, con α = −20°: Bishop da 1.32·W y Fellenius 0.94·W. En el relleno, con α = 30°: Bishop da 0.88·W y Fellenius 0.87·W − 0.17·W del sismo = 0.70·W. Las fuerzas entre rebanadas que Bishop conserva aprietan la base y dan más rozamiento; Fellenius las quita y queda del lado de la seguridad.

## 7 · Sin sismo
#: Sin sismo (k_{h} = 0) el círculo crítico de GEO5 con Bishop es otro, más pequeño y más pegado al muro:
x_ce = -0.9 [m]
z_ce = 1.47 [m]
R_e = 5.27 [m]
k_he = 0
x_ae = x_ce - sqrt(R_e^2 - (z_ce + 2.3)^2) [m]
x_be = x_ce + sqrt(R_e^2 - z_ce^2) [m]
#dibujo("Círculo de Bishop sin sismo y sus 24 rebanadas", ud = m, cotas = m, ancho = 170, alto = 110)
#  achurado([-1.1, 1.9, 1.9, 0, 0, -0.25, -0.4, -1.1], [-3, -3, -2.6, -2.6, 0, 0, -2.6, -2.6], "concreto")
#  poligono(-1.1, -3, 1.9, -3, 1.9, -2.6, 0, -2.6, 0, 0, -0.25, 0, -0.4, -2.6, -1.1, -2.6, "gruesa")
#  linea(-5.5, -2.3, -0.383, -2.3, "media")
#  linea(0, 0, 5.5, 0, "media")
#  linea(-5.5, -3, -1.1, -3, "trazos gris")
#  linea(1.9, -3, 5.5, -3, "trazos gris")
#  polilinea([-4.58, -4.58, -4.58, -4.22, -4.22, -4.22, -3.85, -3.85, -3.85, -3.49, -3.49, -3.49, -3.13, -3.13, -3.13, -2.76, -2.76, -2.76, -2.40, -2.40, -2.40, -2.03, -2.03, -2.03, -1.67, -1.67, -1.67, -1.30, -1.30, -1.30, -0.94, -0.94, -0.94, -0.58, -0.58, -0.58, -0.21, -0.21, -0.21, 0.15, 0.15, 0.15, 0.52, 0.52, 0.52, 0.88, 0.88, 0.88, 1.25, 1.25, 1.25, 1.61, 1.61, 1.61, 1.98, 1.98, 1.98, 2.34, 2.34, 2.34, 2.70, 2.70, 2.70, 3.07, 3.07, 3.07, 3.43, 3.43, 3.43, 3.80, 3.80, 3.80, 4.16, 4.16, 4.16], [-2.30, -2.30, -2.30, -2.62, -2.30, -2.62, -2.89, -2.30, -2.89, -3.12, -2.30, -3.12, -3.31, -2.30, -3.31, -3.46, -2.30, -3.46, -3.58, -2.30, -3.58, -3.68, -2.30, -3.68, -3.74, -2.30, -3.74, -3.78, -2.30, -3.78, -3.80, -2.30, -3.80, -3.79, -2.30, -3.79, -3.75, 0.00, -3.75, -3.69, 0.00, -3.69, -3.61, 0.00, -3.61, -3.49, 0.00, -3.49, -3.34, 0.00, -3.34, -3.16, 0.00, -3.16, -2.95, 0.00, -2.95, -2.69, 0.00, -2.69, -2.38, 0.00, -2.38, -2.00, 0.00, -2.00, -1.53, 0.00, -1.53, -0.92, 0.00, -0.92, 0.00, 0.00, 0.00], "fina azul")
#  polilinea([-4.582, -4.361, -4.127, -3.884, -3.630, -3.368, -3.097, -2.819, -2.535, -2.246, -1.952, -1.654, -1.355, -1.053, -0.752, -0.450, -0.151, 0.147, 0.441, 0.730, 1.014, 1.292, 1.563, 1.826, 2.079, 2.323, 2.557, 2.779, 2.989, 3.186, 3.370, 3.540, 3.695, 3.835, 3.960, 4.068, 4.161], [-2.300, -2.505, -2.696, -2.874, -3.038, -3.187, -3.320, -3.438, -3.540, -3.625, -3.694, -3.746, -3.780, -3.798, -3.798, -3.781, -3.746, -3.695, -3.627, -3.542, -3.440, -3.322, -3.189, -3.040, -2.877, -2.699, -2.508, -2.304, -2.087, -1.858, -1.619, -1.370, -1.111, -0.844, -0.569, -0.287, -0.000], "gruesa rojo")
#  linea(-0.9, 1.47, -4.582, -2.3, "fina trazos rojo")
#  linea(-0.9, 1.47, 4.161, 0, "fina trazos rojo")
#  circulo(-0.9, 1.47, 0.08, "rojo relleno")
#  texto(-0.7, 1.7, "centro (−0.90; 1.47)", 2.6, "i", estilo = "rojo")
#  texto(2.0, 1.0, "R = 5.27 m", 2.6, "i", estilo = "rojo")
#  texto(1.0, 0.25, "relleno SP", 2.4, "c")
#  texto(-3.6, -2.05, "terreno SP", 2.4, "c")
#  texto(3.3, -3.55, "SP-SM", 2.4, "c", estilo = "gris")
#fin
#: Se repite el mismo cálculo de las rebanadas con este círculo y k_{h} = 0 (el mismo bloque de antes, oculto):
#hide
x_c = x_ce
z_c = z_ce
R = R_e
k_h = k_he
x_a = x_ae
x_b = x_be
b = (x_b - x_a)/n
h = b/s
W = zeros(n, 1)
x_g = zeros(n, 1)
z_g = zeros(n, 1)
α = zeros(n, 1)
φ = zeros(n, 1)
for i = 1:n + 1
  x_i(i) = x_a + (i - 1)·b
  z_i(i) = z_c - sqrt(R^2 - (x_i(i) - x_c)^2)
end
for i = 1:n
  M_x = 0
  M_y = 0
  for k = 1:s
    x = x_i(i) + (k - 0.5)·h
    z = z_i(i) + (z_i(i + 1) - z_i(i))·(x - x_i(i))/b
    W(i) = W(i) + (q_c(x, z) + q_r(x, z) + q_f(x, z))·h
    M_x = M_x + (q_c(x, z) + q_r(x, z) + q_f(x, z))·h·x
    M_y = M_y + m_z(x, z)·h
  end
  x_g(i) = M_x/W(i)
  z_g(i) = M_y/W(i)
  α(i) = atan2(z_i(i + 1) - z_i(i), b)
  φ(i) = φ_r·pi/180
  if (z_i(i) + z_i(i + 1))/2 < -3
    φ(i) = φ_f·pi/180
  end
end
#show
#: Momento que hace girar (solo el peso):
M_ae = sum(W.*(x_g - x_c)) + k_h·sum(W.*(z_c - z_g)) [kN·m/m]
#: Fellenius:
M_Fe = R·sum((W.*cos(α) - k_h·W.*sin(α)).*tan(φ)) [kN·m/m]
FS_Fe = M_Fe/M_ae
#: Bishop, con la misma iteración:
#hide
F_k = 1
for k = 1:60
  F_k = R·sum(W.*tan(φ)./(cos(α) + tan(φ).*sin(α)/F_k))/M_ae
end
#show
M_Be = R·sum(W.*tan(φ)./(cos(α) + tan(φ).*sin(α)/F_k)) [kN·m/m]
FS_Be = M_Be/M_ae
#: Sin sismo los dos cumplen con holgura (FS > 1.50). Aquí la diferencia entre los métodos es mayor (@{FS_Be} contra @{FS_Fe}) porque el círculo es pequeño y sus bases están muy inclinadas: α llega a −42° en el frente y a 68° en el relleno, y es con α grande donde las fuerzas entre rebanadas pesan más.

## 8 · Comparación con GEO5
#hide
d_1 = round(100·(M_as/2136.32 - 1), 3)
d_2 = round(100·(M_Bs/2333.60 - 1), 3)
d_3 = round(100·(FS_Bs/(2333.60/2136.32) - 1), 3)
d_4 = round(100·(M_Fs/2127.39 - 1), 3)
d_5 = round(100·(FS_Fs/(2127.39/2136.32) - 1), 3)
d_6 = round(100·(M_ae/434.85 - 1), 3)
d_7 = round(100·(M_Be/1011.77 - 1), 3)
d_8 = round(100·(FS_Be/(1011.77/434.85) - 1), 3)
d_9 = round(100·(M_Fe/841.35 - 1), 3)
d_10 = round(100·(FS_Fe/(841.35/434.85) - 1), 3)
#show
#: GEO5 2024 en los mismos círculos, por metro de muro. El FS de GEO5 se escribe como M_{p} / M_{a} con sus momentos (en pantalla lo redondea a dos decimales: 1.09, 1.00, 2.33 y 1.93). La columna «Python» es la referencia con la misma formulación.
#| Caso | Magnitud | Esta hoja | Python | GEO5 | Diferencia con GEO5 [%] |
#|---|---|---:|---:|---:|---:|
#| con sismo | M_{a} [kN·m/m] | @{M_as} | 2136.6737 | 2136.32 | @{d_1} |
#| con sismo | M_{p} Bishop [kN·m/m] | @{M_Bs} | 2336.0494 | 2333.60 | @{d_2} |
#| con sismo | FS Bishop | @{FS_Bs} | 1.0933 | 1.0923 | @{d_3} |
#| con sismo | M_{p} Fellenius [kN·m/m] | @{M_Fs} | 2129.6949 | 2127.39 | @{d_4} |
#| con sismo | FS Fellenius | @{FS_Fs} | 0.9967 | 0.9958 | @{d_5} |
#| sin sismo | M_{a} [kN·m/m] | @{M_ae} | 435.7314 | 434.85 | @{d_6} |
#| sin sismo | M_{p} Bishop [kN·m/m] | @{M_Be} | 1012.7970 | 1011.77 | @{d_7} |
#| sin sismo | FS Bishop | @{FS_Be} | 2.3244 | 2.3267 | @{d_8} |
#| sin sismo | M_{p} Fellenius [kN·m/m] | @{M_Fe} | 842.5051 | 841.35 | @{d_9} |
#| sin sismo | FS Fellenius | @{FS_Fe} | 1.9335 | 1.9348 | @{d_10} |
#: **Lectura honrada.** La hoja y Python coinciden: es la misma formulación. Con GEO5 queda una diferencia de 0.02 % a 0.2 % en los momentos y de 0.1 % en el FS. Viene de **cómo divide GEO5 la masa en rebanadas**: su ayuda no dice cuántas usa ni dónde pone los cortes, y eso no se conoce exactamente. No cambia ninguna conclusión.

## 9 · Los cinco métodos de GEO5
#: GEO5 también calcula el problema con otros tres métodos, más completos, que aquí **no se calculan**: se citan con su resultado. Cada método optimiza **su propio** círculo (por eso el Fellenius de la tabla es 0.95 y no el 0.9967 del círculo de Bishop). Hipótesis tomadas de la ayuda oficial de GEO5:
#| Método | Equilibrio que cumple | Fuerzas entre rebanadas | Con sismo | Sin sismo |
#|---|---|---|---:|---:|
#| Fellenius / Petterson | momentos de toda la masa | ninguna (E_{i} = X_{i} = 0) | 0.95 | 1.89 |
#| Bishop simplificado | momentos + verticales de cada rebanada | solo horizontales (X_{i} = 0) | 1.09 | 2.33 |
#| Janbu | fuerzas y momentos de cada rebanada | E_{i} a una altura supuesta | 1.11 | 2.33 |
#| Spencer | fuerzas y momentos de cada rebanada | E_{i} con la misma inclinación δ | 1.12 | 2.33 |
#| Morgenstern-Price | fuerzas y momentos de cada rebanada | E_{i} con inclinación λ·f(x) | 1.11 | 2.33 |
#: En Janbu la altura supuesta está cerca de un tercio de la cara, y no se cumple el momento de la última rebanada. En Morgenstern-Price, f(x) es media onda de seno.
#: Los tres métodos completos dan 1.11–1.12 con sismo: Bishop (1.09) queda muy cerca de ellos y del lado de la seguridad. Fellenius se aparta: es el único que no cumple.

## 10 · Conclusión
#: **Con sismo** la estabilidad general **cumple con Bishop** (1.09 > 1.05) y con Janbu, Spencer y Morgenstern-Price (1.11–1.12), y **no cumple con Fellenius** (0.95 < 1.05). El margen es pequeño: 4 % sobre el mínimo con Bishop.
#: **Sin sismo** cumple con todos los métodos (1.89 a 2.33 > 1.50).
#: **Pendiente.** Dos cosas del estudio de suelos no están en este modelo y las dos bajan el FS: el **nivel freático** a −3.05 m (presión de poros en la base de las rebanadas) y el **estrato licuable** de −3.05 a −6.00 m, que en sismo puede perder su resistencia. Con un margen del 4 % hay que añadirlos antes de dar el muro por bueno.
