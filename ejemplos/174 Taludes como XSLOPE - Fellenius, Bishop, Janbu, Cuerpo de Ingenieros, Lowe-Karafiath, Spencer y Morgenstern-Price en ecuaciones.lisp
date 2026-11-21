# Taludes como XSLOPE: los siete métodos de equilibrio límite, cada uno en su ecuación
#numerico

#: **Qué es XSLOPE.** Un programa abierto de estabilidad de taludes (Norm Jones, BYU; Jones & Williams 2026, SoftwareX 36, 103018). Trae siete métodos de **equilibrio límite** por dovelas y un método de **elementos finitos** (reducción de resistencia). Esta hoja explica qué significa cada uno en matemática, con las ecuaciones de su documentación (docs/lem), y los calcula todos sobre **el mismo talud y el mismo círculo** para ver en qué se parecen y en qué no. No se ejecutó el código de XSLOPE: las fórmulas se leyeron de sus documentos.
#: **La idea de todos.** La masa encima de la superficie de falla se corta en dovelas verticales. En la base de cada dovela el suelo resiste con Mohr-Coulomb, pero solo con una fracción 1/F de su resistencia: c_{m} = c/F y tan φ_{m} = tan φ/F. **F es el factor de seguridad**: el número por el que hay que dividir la resistencia para que la masa quede justo en equilibrio.
#: **Por qué hay tantos métodos.** Cada dovela tiene más incógnitas (la normal y el cortante de la base, y las fuerzas en sus caras) que ecuaciones de equilibrio. Cada método **supone algo** sobre las fuerzas entre dovelas para que el problema se pueda resolver. Esa suposición, y qué equilibrios cumple, es lo que distingue a uno de otro.

## 1 · El talud de ejemplo

#: Talud homogéneo de 10 m de alto con pendiente 2:1 (horizontal:vertical), pie en (0; 0) y coronación a 10 m. Suelo c-φ seco (u = 0). Es la misma proporción c/(γ·H) = 0.05 del ejemplo 1 de Griffiths y Lane (1999), uno de los casos con los que XSLOPE se verifica.
H = 10 'altura del talud [m]
gamma = 20 'peso específico del suelo [kN/m3]
c = 10 'cohesión efectiva [kPa]
phi = 20 'ángulo de rozamiento efectivo [grados]
t_p = tan(phi·pi/180) 'tan φ
n_s = 2 'pendiente del talud: metros en horizontal por cada metro en vertical
#: El terreno: horizontal a cota 0 delante del pie, sube con pendiente 1/n_{s} hasta la coronación y sigue horizontal a cota H:
z_t(x) = min(max(x/n_s, 0), H)
#: **El círculo de prueba** (no es el crítico; sirve para comparar los métodos en la misma superficie). Pasa por el pie y sale por la coronación:
x_c = 8 'centro del círculo, x [m]
z_c = 22 'centro del círculo, z [m]
R = sqrt(x_c^2 + z_c^2) 'radio: el círculo pasa por el pie (0; 0) [m]
z_o(x) = z_c - sqrt(R^2 - (x - x_c)^2)
x_a = 0 'entrada por el pie [m]
x_b = x_c + sqrt(R^2 - (z_c - H)^2) 'salida en la coronación [m]
#hide
z_a0 = z_o(x_a)
P_x = zeros(3, 1)
P_z = zeros(3, 1)
for k = 1:1
  P_x(1) = x_a
  P_z(1) = z_a0
  P_x(2) = x_b
  P_z(2) = H
  P_x(3) = x_c
  P_z(3) = z_c
end
a_e = -90 - atan((x_c - x_a)/(z_c - z_a0))*180/pi
a_s = -90 + atan((x_b - x_c)/(z_c - H))*180/pi
x_cr = n_s*H
x_fin = max(x_b, x_cr) + 0.5*H
x_ini = -0.6*H
G_x = zeros(4, 1)
G_z = zeros(4, 1)
for k = 1:1
  G_x(1) = x_ini
  G_x(3) = x_cr
  G_x(4) = x_fin
  G_z(3) = H
  G_z(4) = H
end
A_x = zeros(41, 1)
A_z = zeros(41, 1)
for k = 1:41
  a_k = (a_e + (a_s - a_e)*(k - 1)/40)*pi/180
  A_x(k) = x_c + R*cos(a_k)
  A_z(k) = z_c + R*sin(a_k)
end
z_fondo = min(A_z) - 0.25*H
x_R = (x_c + x_b)/2 + 0.05*H
z_R = (z_c + H)/2
x_ms = x_cr/2 + 0.1*H
z_ms = H/2 - 0.12*H
x_su = x_cr + 0.25*H
z_su = 0.55*H
x_ct = x_ini + 0.25*H
#show
#dibujo("El talud, el círculo de prueba y su centro O (cambia con H, n_s, x_c, z_c)", ud = m, escala = auto, cotas = m, alto = 120)
#  poligono(x_ini, z_fondo, x_ini, 0, 0, 0, x_cr, H, x_fin, H, x_fin, z_fondo, "fina gris")
#  polilinea(G_x, G_z, "gruesa")
#  polilinea(A_x, A_z, "gruesa rojo")
#  circulo(x_c, z_c, 0.03*H, "rojo")
#  texto(x_c + 0.06*H, z_c, "O ({x_c:1}; {z_c:1})", 2.6, "i")
#  linea(x_c, z_c, x_a, z_a0, "fina trazos rojo")
#  linea(x_c, z_c, x_b, H, "fina trazos rojo")
#  texto(x_R, z_R, "R = {R:2} m", 2.6, "i")
#  texto(x_ms, z_ms, "{n_s:0}:1", 2.8, "c")
#  texto(x_su, z_su, "c = {c:0} kPa, φ = {phi:0}°, γ = {gamma:0} kN/m³", 2.5, "i")
#  cota(x_ct, 0, x_ct, H, 0, "H = {H:1} m")
#  cota(0, z_fondo + 0.1*H, x_cr, z_fondo + 0.1*H, 0, "{x_cr:1} m")
#  hover(P_x, P_z, "({#1:2}; {#2:2}) m", P_x, P_z)
#fin

## 2 · Las dovelas

#: Se corta la masa en n dovelas de igual ancho b. En cada una la base es la **cuerda** del círculo entre sus dos bordes:
n = 20 'número de dovelas
b = (x_b - x_a)/n 'ancho de cada dovela [m]
#: Para cada dovela i: α_{i} = inclinación de la base, Δℓ_{i} = b/cos α_{i} = largo de la base, W_{i} = γ·(área) = peso, x_{i} = abscisa del centro, y_{i} = cota del centro de la base.
#hide
W = zeros(n, 1)
al = zeros(n, 1)
dl = zeros(n, 1)
xm = zeros(n, 1)
yb = zeros(n, 1)
X_j = zeros(n + 1, 1)
for i = 1:n + 1
  X_j(i) = x_a + (i - 1)*b
end
for i = 1:n
  x1 = X_j(i)
  x2 = X_j(i + 1)
  z1 = z_o(x1)
  z2 = z_o(x2)
  al(i) = atan((z2 - z1)/b)
  dl(i) = b/cos(al(i))
  h1 = z_t(x1) - z1
  h2 = z_t(x2) - z2
  hm = z_t((x1 + x2)/2) - (z1 + z2)/2
  W(i) = gamma*b*(h1 + 4*hm + h2)/6
  xm(i) = (x1 + x2)/2
  yb(i) = (z1 + z2)/2
end
cc = c*ones(n, 1)
tp = t_p*ones(n, 1)
uu = zeros(n, 1)
#show
W_T = sum(W) 'peso total de la masa que desliza [kN/m]
a_min = min(al)·180/pi 'base más tendida (cerca del pie, negativa: sube hacia el pie) [grados]
a_max = max(al)·180/pi 'base más empinada (bajo la coronación) [grados]
#: La dovela de ejemplo de los dibujos de fuerzas (capítulos 3, 4 y 6) es la número k_{d}:
k_d = 15 'dovela de ejemplo
#hide
X_z = zeros(3*(n + 1), 1)
Z_z = zeros(3*(n + 1), 1)
Zo_j = zeros(n + 1, 1)
for j = 1:n + 1
  X_z(3*j - 2) = X_j(j)
  X_z(3*j - 1) = X_j(j)
  X_z(3*j) = X_j(j)
  Z_z(3*j - 2) = z_o(X_j(j))
  Z_z(3*j - 1) = z_t(X_j(j))
  Z_z(3*j) = z_o(X_j(j))
  Zo_j(j) = z_o(X_j(j))
end
a_g = zeros(n, 1)
for i = 1:n
  a_g(i) = al(i)*180/pi
end
x_L = X_j(k_d)
x_D = X_j(k_d + 1)
z_bL = z_o(x_L)
z_bD = z_o(x_D)
z_tL = z_t(x_L)
z_tD = z_t(x_D)
x_md = (x_L + x_D)/2
z_md = (z_bL + z_bD)/2
h_d = (z_tL - z_bL + z_tD - z_bD)/2
W_d = W(k_d)
a_d = al(k_d)
a_dg = a_d*180/pi
l_d = dl(k_d)
L_f = 0.45*h_d
x_W0 = x_md
z_W0 = z_md + 0.8*h_d
z_W1 = z_W0 - L_f
x_N0 = x_md + L_f*sin(a_d)
z_N0 = z_md - L_f*cos(a_d)
x_S0 = x_L + 0.1*b + 0.12*h_d*sin(a_d)
z_S0 = z_bL + 0.1*(z_bD - z_bL) - 0.12*h_d*cos(a_d)
x_S1 = x_L + 0.9*b + 0.12*h_d*sin(a_d)
z_S1 = z_bL + 0.9*(z_bD - z_bL) - 0.12*h_d*cos(a_d)
x_hz = x_L + 0.8*b
z_cb = max(z_tL, z_tD) + 0.12*h_d
x_tx = x_D + 0.25*b
z_tW = z_W0 - L_f/2
x_tN = x_N0 + 0.15*b
z_tN = z_N0
x_tS = x_S1 + 0.15*b
z_tS = z_S1 - 0.1*h_d
z_tA = z_md - 0.95*h_d
z_tX = z_md + 0.95*h_d
#show
#dibujo("Las dovelas; en azul, la dovela k_d de los dibujos de fuerzas", ud = m, escala = auto, alto = 75)
#  polilinea(G_x, G_z, "gruesa")
#  polilinea(X_z, Z_z, "media rojo")
#  poligono(x_L, z_bL, x_D, z_bD, x_D, z_tD, x_L, z_tL, "gruesa azul")
#  cota(x_L, z_cb, x_D, z_cb, 0, "b = {b:2} m")
#  texto(x_md, z_cb + 0.5*h_d, "k_d = {k_d:0} de {n:0}", 2.5, "c")
#  hover(xm, yb, "dovela: W = {#1:1} kN/m, α = {#2:1}°, Δℓ = {#3:2} m", W, a_g, dl)
#fin

## 3 · Fellenius (Método Ordinario de Dovelas, OMS)

#: **Suposición:** las fuerzas entre dovelas **no existen** (se anulan). **Equilibrio que cumple:** solo el de momentos de toda la masa respecto al centro del círculo. **Incógnitas:** solo F; sale directo, sin iterar.
#: Sin fuerzas en las caras, la normal en la base sale de equilibrar la dovela perpendicular a su base: N_{i} = W_{i}·cos α_{i}. El momento que resiste (cortante de la base × R) entre el que empuja (peso × brazo, W·R·sen α):
#: F = Σ [c·Δℓ + (W·cos α − u·Δℓ·cos²α)·tan φ] / Σ W·sen α    (XSLOPE usa la forma con u·Δℓ·cos²α, la «preferida»: evita normales negativas con mucha agua)
F_OMS = sum(cc.*dl + (W.*cos(al) - uu.*dl.*cos(al).^2).*tp)/sum(W.*sin(al)) 'Fellenius
#hide
N_Fd = W_d*cos(a_d)
S_Fd = (c*l_d + N_Fd*t_p)/F_OMS
#show
#dibujo("Fellenius en la dovela k_d: sin fuerzas en las caras; N = W·cos α", ud = m, escala = auto, alto = 150, lado = derecha)
#  poligono(x_L, z_bL, x_D, z_bD, x_D, z_tD, x_L, z_tL, "gruesa")
#  linea(x_L, z_bL, x_hz, z_bL, "fina trazos")
#  flecha(x_W0, z_W0, x_W0, z_W1, "rojo")
#  flecha(x_N0, z_N0, x_md, z_md, "azul")
#  flecha(x_S0, z_S0, x_S1, z_S1, "verde")
#  texto(x_md, z_tX, "W = {W_d:1} kN/m", 2.5, "c")
#  texto(x_tx, z_tA, "α = {a_dg:1}°, Δℓ = {l_d:2} m", 2.5, "i")
#  texto(x_tN, z_tN, "N = W·cos α = {N_Fd:1} kN/m", 2.5, "i")
#  texto(x_tS, z_tS, "S = (c·Δℓ + N·tan φ)/F = {S_Fd:1} kN/m", 2.5, "i")
#fin
#: **Qué significa:** como ignora las fuerzas entre dovelas, la normal sale «mal» en las dovelas empinadas y el resultado suele ser **conservador** (más bajo). XSLOPE lo trae como referencia histórica y de enseñanza, no para diseñar.

## 4 · Bishop simplificado

#: **Suposición:** las fuerzas entre dovelas son **horizontales** (sin cortante entre caras). **Equilibrio que cumple:** momentos respecto al centro y fuerzas **verticales** de cada dovela. No cumple el horizontal. **Solo para círculos.**
#: Del equilibrio vertical de la dovela, con el cortante movilizado S = [c·Δℓ + N'·tan φ]/F, sale la normal efectiva:
#: N' = [W − u·Δℓ·cos α − (c·Δℓ/F)·sen α] / m_{α},   m_{α} = cos α + sen α·tan φ/F
#: Llevada a la ecuación de momentos:
#: F = Σ [(c·Δℓ·cos α + (W − u·Δℓ·cos α)·tan φ) / m_{α}] / Σ W·sen α
#: F aparece a los dos lados (dentro de m_{α}): se itera, empezando con F = 1, hasta que no cambie.
#hide
F_B = 1
for k = 1:100
  m_a = cos(al) + sin(al).*tp/F_B
  F_B = sum((cc.*dl.*cos(al) + (W - uu.*dl.*cos(al)).*tp)./m_a)/sum(W.*sin(al))
end
#show
F_Bishop = F_B 'Bishop simplificado
#hide
m_ad = cos(a_d) + sin(a_d)*t_p/F_B
N_Bd = (W_d - c*l_d*sin(a_d)/F_B)/m_ad
S_Bd = (c*l_d + N_Bd*t_p)/F_B
z_EL = z_bL + 0.45*(z_tL - z_bL)
z_ED = z_bD + 0.45*(z_tD - z_bD)
x_EL = x_L - L_f
x_ED = x_D + L_f
#show
#dibujo("Bishop en la dovela k_d: Eᵢ y Eᵢ₊₁ horizontales", ud = m, escala = auto, alto = 150, lado = derecha)
#  poligono(x_L, z_bL, x_D, z_bD, x_D, z_tD, x_L, z_tL, "gruesa")
#  linea(x_L, z_bL, x_hz, z_bL, "fina trazos")
#  flecha(x_W0, z_W0, x_W0, z_W1, "rojo")
#  flecha(x_N0, z_N0, x_md, z_md, "azul")
#  flecha(x_S0, z_S0, x_S1, z_S1, "verde")
#  texto(x_md, z_tX, "W = {W_d:1} kN/m", 2.5, "c")
#  texto(x_tx, z_tA, "α = {a_dg:1}°, Δℓ = {l_d:2} m", 2.5, "i")
#  flecha(x_EL, z_EL, x_L, z_EL, "naranja")
#  flecha(x_ED, z_ED, x_D, z_ED, "naranja")
#  texto(x_EL, z_EL - 0.1*h_d, "Eᵢ", 2.8, "i")
#  texto(x_ED, z_ED - 0.1*h_d, "Eᵢ₊₁", 2.8, "d")
#  texto(x_tN, z_tN, "N' = {N_Bd:1} kN/m (m_α = {m_ad:3})", 2.5, "i")
#  texto(x_tS, z_tS, "S = {S_Bd:1} kN/m con F = {F_Bishop:3}", 2.5, "i")
#fin
#: **Qué significa:** en círculos queda casi igual que los métodos completos (Spencer), por eso es el de uso diario. XSLOPE lo usa como el valor «de momentos» de referencia en superficies circulares.

## 5 · Janbu simplificado

#: **Suposición:** sin cortante entre dovelas (igual que Bishop). **Equilibrio que cumple:** fuerzas **horizontales** de toda la masa y verticales de cada dovela. **No** cumple momentos. Sirve para círculos y no círculos.
#: La normal sale igual que en Bishop: N = [W − (c·Δℓ − u·Δℓ·tan φ)·sen α/F] / m_{α}. Del equilibrio horizontal (Σ S·cos α = Σ N·sen α):
#: F_{0} = Σ [c·Δℓ + (N − u·Δℓ)·tan φ]·cos α / Σ N·sen α
#hide
F_J = 1
for k = 1:200
  m_a = cos(al) + sin(al).*tp/F_J
  NN = (W - (cc.*dl - uu.*dl.*tp).*sin(al)/F_J)./m_a
  F_J = sum((cc.*dl + (NN - uu.*dl).*tp).*cos(al))/sum(NN.*sin(al))
end
#show
F_0 = F_J 'Janbu sin corregir
#: Como olvida los momentos, Janbu sale bajo. Lo corrige con un factor empírico f_{0} que depende de lo profunda que es la superficie: d = flecha máxima del arco respecto a la cuerda, L = largo de la cuerda:
#: f_{0} = 1 + b_{1}·[d/L − 1.4·(d/L)²],   b_{1} = 0.67 (solo c), 0.5 (c-φ), 0.31 (solo φ). XSLOPE limita d/L ≤ 1/2.8, donde el polinomio tiene su máximo.
L_c = sqrt((x_b - x_a)^2 + (z_o(x_b) - z_o(x_a))^2) 'largo de la cuerda entre la entrada y la salida [m]
d_c = R - abs((x_b - x_a)·(z_o(x_a) - z_c) - (x_a - x_c)·(z_o(x_b) - z_o(x_a)))/L_c 'flecha del arco [m]
r_dL = min(d_c/L_c, 1/2.8) 'd/L
b_1 = 0.5 'suelo c-φ
f_0 = 1 + b_1·(r_dL - 1.4·r_dL^2) 'factor de corrección de Janbu
F_Janbu = f_0·F_0 'Janbu corregido
#hide
x_m1 = (x_a + x_b)/2
z_m1 = (z_a0 + H)/2
r_m1 = sqrt((x_m1 - x_c)^2 + (z_m1 - z_c)^2)
x_d1 = x_c + R*(x_m1 - x_c)/r_m1
z_d1 = z_c + R*(z_m1 - z_c)/r_m1
x_L1 = x_m1 - 0.15*H
z_L1 = z_m1 + 0.08*H
x_t5 = x_ini
z_t5 = H + 0.15*H
#show
#dibujo("Janbu: ΣF_x = 0 de toda la masa; f₀ sale de la flecha d y la cuerda L", ud = m, escala = auto, alto = 75)
#  polilinea(G_x, G_z, "gruesa")
#  polilinea(A_x, A_z, "gruesa rojo")
#  linea(x_a, z_a0, x_b, H, "media trazos azul")
#  linea(x_m1, z_m1, x_d1, z_d1, "gruesa azul")
#  texto(x_L1, z_L1, "L = {L_c:2} m", 2.6, "c")
#  texto(x_d1 + 0.04*H, z_d1 - 0.06*H, "d = {d_c:2} m", 2.6, "i")
#  texto(x_t5, z_t5, "f₀ = 1 + b₁·[d/L − 1.4·(d/L)²] = {f_0:4}", 2.6, "i")
#fin
#: **Qué significa:** es una estimación rápida, sobre todo para superficies no circulares; XSLOPE recomienda confirmarla con Spencer.

## 6 · El barrido de fuerzas (lo que usan los cuatro métodos que faltan)

#: Los métodos que siguen sí ponen fuerzas en las caras: una resultante Z en cada borde j, inclinada θ_{j}. Si se conoce θ_{j}, cada dovela tiene dos incógnitas, N' (normal efectiva de la base) y Z_{i+1} (la fuerza que pasa a la siguiente), y dos ecuaciones (Σ F_{x} = 0 y Σ F_{y} = 0). En forma de matriz, A·x = b:
#: [tan φ_{m}·cos α − sen α,  −cos θ_{i+1};  tan φ_{m}·sen α + cos α,  −sen θ_{i+1}] · [N'; Z_{i+1}] = [−c_{m}·Δℓ·cos α + u·Δℓ·sen α − Z_{i}·cos θ_{i};  −c_{m}·Δℓ·sen α − u·Δℓ·cos α + W − Z_{i}·sen θ_{i}]
#: Se empieza en el pie con Z_{1} = 0 y se va dovela a dovela hasta el final. Detrás de la última dovela no hay suelo: la fuerza que «sobra», Z_{n+1}(F), tiene que ser **cero**. Ese es el **residuo de fuerzas**: el F correcto es el que hace Z_{n+1}(F) = 0.
#: El **residuo de momentos** de toda la masa respecto al origen (las fuerzas entre dovelas se anulan entre vecinas, solo quedan peso, normal y cortante de la base):
#: R_{m} = Σ [−W·x + (N' + u·Δℓ)·(x·cos α + y·sen α) + S·(x·sen α − y·cos α)],   S = (c·Δℓ + N'·tan φ)/F
#hide
function R = barrido(F, TH, W, al, dl, cc, tp, uu, n)
  Z = 0
  R = zeros(n + 1, 1)
  for i = 1:n
    cm = cc(i)/F
    tm = tp(i)/F
    a11 = tm*cos(al(i)) - sin(al(i))
    a12 = -cos(TH(i + 1))
    a21 = tm*sin(al(i)) + cos(al(i))
    a22 = -sin(TH(i + 1))
    b1 = -cm*dl(i)*cos(al(i)) + uu(i)*dl(i)*sin(al(i)) - Z*cos(TH(i))
    b2 = -cm*dl(i)*sin(al(i)) - uu(i)*dl(i)*cos(al(i)) + W(i) - Z*sin(TH(i))
    de = a11*a22 - a12*a21
    R(i + 1) = (b1*a22 - a12*b2)/de
    Z = (a11*b2 - a21*b1)/de
  end
  R(1) = Z
end
function r = residuo(t, F, TH, W, al, dl, cc, tp, uu, xm, yb, n)
  B = barrido(F, TH, W, al, dl, cc, tp, uu, n)
  if t == 1
    r = B(1)
  else
    r = 0
    for i = 1:n
      Np = B(i + 1)
      S = (cc(i)*dl(i) + Np*tp(i))/F
      r = r - W(i)*xm(i) + (Np + uu(i)*dl(i))*(xm(i)*cos(al(i)) + yb(i)*sin(al(i))) + S*(xm(i)*sin(al(i)) - yb(i)*cos(al(i)))
    end
  end
end
function Fr = raiz(t, TH, Fref, WT, W, al, dl, cc, tp, uu, xm, yb, n)
  lim = 20*WT*(1 + 30*(t - 1))
  r0 = residuo(t, Fref, TH, W, al, dl, cc, tp, uu, xm, yb, n)
  Fl = -1
  Fu = -1
  pu = Fref
  ru = r0
  pd = Fref
  rd = r0
  for k = 1:60
    if Fl < 0
      q = Fref + 0.05*k
      rq = residuo(t, q, TH, W, al, dl, cc, tp, uu, xm, yb, n)
      if ru*rq <= 0
        if abs(ru) + abs(rq) < lim
          Fl = pu
          Fu = q
          rl = ru
          rh = rq
        end
      end
      pu = q
      ru = rq
    end
    if Fl < 0
      q = Fref - 0.05*k
      if q > 0.2
        rq = residuo(t, q, TH, W, al, dl, cc, tp, uu, xm, yb, n)
        if rd*rq <= 0
          if abs(rd) + abs(rq) < lim
            Fl = q
            Fu = pd
            rl = rq
            rh = rd
          end
        end
        pd = q
        rd = rq
      end
    end
  end
  Fr = -1
  if Fl > 0
    for k = 1:40
      if abs(rh) > 0
        Fq = Fu - rh*(Fu - Fl)/(rh - rl)
        rq = residuo(t, Fq, TH, W, al, dl, cc, tp, uu, xm, yb, n)
        if rq*rh < 0
          Fl = Fu
          rl = rh
        else
          rl = rl/2
        end
        Fu = Fq
        rh = rq
        if abs(rq) < 1e-10*WT
          rh = 0
        end
      end
    end
    Fr = Fu
  end
end
function S = lamsol(fx, Fref, WT, W, al, dl, cc, tp, uu, xm, yb, n)
  la = -1
  lb = -1
  dmin = 1e9
  lp = 0
  TH = fx
  for jj = 1:n + 1
    TH(jj) = atan(lp*fx(jj))
  end
  Ff = raiz(1, TH, Fref, WT, W, al, dl, cc, tp, uu, xm, yb, n)
  Fm = raiz(2, TH, Fref, WT, W, al, dl, cc, tp, uu, xm, yb, n)
  gp = Ff - Fm
  mp = Fm
  for s = 1:12
    if la < 0
    lq = 0.1*s
    for jj = 1:n + 1
      TH(jj) = atan(lq*fx(jj))
    end
    Ff = raiz(1, TH, Fref, WT, W, al, dl, cc, tp, uu, xm, yb, n)
    Fm = raiz(2, TH, Fref, WT, W, al, dl, cc, tp, uu, xm, yb, n)
    gq = Ff - Fm
    if mp > 0.4
      if Fm > 0.4
        if gp*gq <= 0
          if abs(Ff - Fref) < dmin
            dmin = abs(Ff - Fref)
            la = lp
            lb = lq
            ga = gp
            gb = gq
          end
        end
      end
    end
    lp = lq
    gp = gq
    mp = Fm
    end
  end
  for k = 1:25
    if abs(gb) > 1e-12
      lq = lb - gb*(lb - la)/(gb - ga)
      for jj = 1:n + 1
        TH(jj) = atan(lq*fx(jj))
      end
      Ff = raiz(1, TH, Fref, WT, W, al, dl, cc, tp, uu, xm, yb, n)
      Fm = raiz(2, TH, Fref, WT, W, al, dl, cc, tp, uu, xm, yb, n)
      gq = Ff - Fm
      if gq*gb < 0
        la = lb
        ga = gb
      else
        ga = ga/2
      end
      lb = lq
      gb = gq
      if abs(gq) < 1e-10
        gb = 0
      end
    end
  end
  S = zeros(4, 1)
  S(1) = lb
  S(2) = Ff
  S(3) = Fm
end
#show
#dibujo("El barrido en la dovela k_d: incógnitas N' y Zᵢ₊₁ (con la θ de Spencer)", ud = m, escala = auto, alto = 150, lado = derecha)
#  poligono(x_L, z_bL, x_D, z_bD, x_D, z_tD, x_L, z_tL, "gruesa")
#  linea(x_L, z_bL, x_hz, z_bL, "fina trazos")
#  flecha(x_W0, z_W0, x_W0, z_W1, "rojo")
#  flecha(x_N0, z_N0, x_md, z_md, "azul")
#  flecha(x_S0, z_S0, x_S1, z_S1, "verde")
#  texto(x_md, z_tX, "W = {W_d:1} kN/m", 2.5, "c")
#  texto(x_tx, z_tA, "α = {a_dg:1}°, Δℓ = {l_d:2} m", 2.5, "i")
#  flecha(x_ZL, z_ZL0, x_L, z_ZL, "morado")
#  flecha(x_ZD, z_ZD0, x_D, z_ZD, "morado")
#  texto(x_ZL, z_ZL0 - 0.08*h_d, "Zᵢ (conocida)", 2.5, "i")
#  texto(x_ZD, z_ZD0 + 0.1*h_d, "Zᵢ₊₁ (incógnita)", 2.5, "d")
#  texto(x_md, z_tX + 0.12*h_d, "Z₁ = 0 → … → Zₙ₊₁(F) = 0", 2.5, "i")
#fin
#: El F de cada método se busca como XSLOPE pide: la raíz **más cercana al valor de momentos** (Bishop). Se sale de F_{Bishop} hacia arriba y hacia abajo en pasos de 0.05 hasta el primer cambio de signo del residuo (descartando los polos, donde el determinante de A se hace cero y el residuo salta) y se afina con regula falsi: unas pocas pasadas en vez de cientos.

## 7 · Cuerpo de Ingenieros de EE. UU. (Corps of Engineers #2)

#: **Suposición:** la fuerza en cada borde es **paralela al terreno** en lo alto de ese borde: θ_{j} = pendiente del terreno en x_{j}. **Equilibrio que cumple:** solo fuerzas (horizontal y vertical de cada dovela). **No** cumple momentos.
#: Se resuelve Z_{n+1}(F) = 0 con el barrido de la sección 6.
#hide
TH = zeros(n + 1, 1)
for j = 1:n + 1
  TH(j) = atan((z_t(X_j(j) + 0.001) - z_t(X_j(j) - 0.001))/0.002)
end
F_C = raiz(1, TH, F_B, W_T, W, al, dl, cc, tp, uu, xm, yb, n)
#show
F_Corps = F_C 'Cuerpo de Ingenieros #2
#hide
T_C_x = zeros(3*(n + 1), 1)
T_C_z = zeros(3*(n + 1), 1)
T_C_g = zeros(n + 1, 1)
for j = 1:n + 1
  z0 = z_o(X_j(j))
  T_C_x(3*j - 2) = X_j(j)
  T_C_z(3*j - 2) = z0
  T_C_x(3*j - 1) = X_j(j) + 0.3*H*cos(TH(j))
  T_C_z(3*j - 1) = z0 + 0.3*H*sin(TH(j))
  T_C_x(3*j) = X_j(j)
  T_C_z(3*j) = z0
  T_C_g(j) = TH(j)*180/pi
end
#show
#dibujo("Corps #2: Z paralela al terreno en cada borde", ud = m, escala = auto, alto = 80)
#  polilinea(G_x, G_z, "gruesa")
#  polilinea(X_z, Z_z, "fina gris")
#  polilinea(T_C_x, T_C_z, "media morado")
#  texto(x_ini, H, "F = {F_Corps:4}", 2.6, "i")
#  hover(X_j, Zo_j, "θ = {#1:1}°", T_C_g)
#fin
#: **Qué significa:** XSLOPE avisa que esta convención da sistemáticamente el F **más alto** (menos conservador) de todos, de unos pocos % hasta ~15 % sobre Spencer. Se informa para comparar; para diseñar, Spencer.

## 8 · Lowe y Karafiath

#: **Suposición:** la fuerza en cada borde tiene la inclinación **promedio** entre la del terreno y la de la superficie de falla en ese borde: θ_{j} = [pendiente del terreno + pendiente del círculo]/2. **Equilibrio que cumple:** solo fuerzas.
#hide
for j = 1:n + 1
  xj = X_j(j)
  g_t = atan((z_t(xj + 0.001) - z_t(xj - 0.001))/0.002)
  g_o = atan((xj - x_c)/sqrt(R^2 - (xj - x_c)^2))
  TH(j) = (g_t + g_o)/2
end
F_L = raiz(1, TH, F_B, W_T, W, al, dl, cc, tp, uu, xm, yb, n)
#show
F_LoweK = F_L 'Lowe y Karafiath
#hide
T_L_x = zeros(3*(n + 1), 1)
T_L_z = zeros(3*(n + 1), 1)
T_L_g = zeros(n + 1, 1)
for j = 1:n + 1
  z0 = z_o(X_j(j))
  T_L_x(3*j - 2) = X_j(j)
  T_L_z(3*j - 2) = z0
  T_L_x(3*j - 1) = X_j(j) + 0.3*H*cos(TH(j))
  T_L_z(3*j - 1) = z0 + 0.3*H*sin(TH(j))
  T_L_x(3*j) = X_j(j)
  T_L_z(3*j) = z0
  T_L_g(j) = TH(j)*180/pi
end
#show
#dibujo("Lowe-Karafiath: θ = promedio de terreno y círculo", ud = m, escala = auto, alto = 80)
#  polilinea(G_x, G_z, "gruesa")
#  polilinea(X_z, Z_z, "fina gris")
#  polilinea(T_L_x, T_L_z, "media morado")
#  texto(x_ini, H, "F = {F_LoweK:4}", 2.6, "i")
#  hover(X_j, Zo_j, "θ = {#1:1}°", T_L_g)
#fin
#: **Qué significa:** según el manual EM 1110-2-1902 suele quedar a menos de ~10 % de los métodos completos. Ojo en superficies no circulares: como θ sigue a la base, una base casi vertical en el pie baja F artificialmente.

## 9 · Spencer

#: **Suposición:** todas las fuerzas entre dovelas son **paralelas**: la misma inclinación θ en todos los bordes, tan θ = λ. **Equilibrio que cumple:** **todo** (fuerzas horizontales, verticales y momentos). **Incógnitas:** F y λ.
#: Para cada λ hay dos factores de seguridad: F_{f}(λ), el que cierra las fuerzas (Z_{n+1} = 0), y F_{m}(λ), el que cierra los momentos (R_{m} = 0). La solución es el λ donde **los dos coinciden**: F_{f}(λ) = F_{m}(λ). XSLOPE lo resuelve con Newton en 2D; aquí se recorre λ desde 0 en pasos de 0.1 hasta el primer cruce de las dos curvas y se afina con regula falsi (mismo resultado).
#hide
S_p = lamsol(ones(n + 1, 1), F_B, W_T, W, al, dl, cc, tp, uu, xm, yb, n)
l_q = S_p(1)
F_f = S_p(2)
F_m = S_p(3)
#show
lambda_S = l_q 'λ de Spencer = tan θ
theta_S = atan(l_q)·180/pi 'inclinación de las fuerzas entre dovelas [grados]
#hide
t_hS = atan(lambda_S)
z_ZL = z_bL + 0.45*(z_tL - z_bL)
z_ZD = z_bD + 0.45*(z_tD - z_bD)
x_ZL = x_L - L_f*cos(t_hS)
z_ZL0 = z_ZL - L_f*sin(t_hS)
x_ZD = x_D + L_f*cos(t_hS)
z_ZD0 = z_ZD + L_f*sin(t_hS)
#show
F_Spencer = (F_f + F_m)/2 'Spencer
#hide
for j = 1:n + 1
  TH(j) = atan(l_q)
end
#show
#hide
T_S_x = zeros(3*(n + 1), 1)
T_S_z = zeros(3*(n + 1), 1)
T_S_g = zeros(n + 1, 1)
for j = 1:n + 1
  z0 = z_o(X_j(j))
  T_S_x(3*j - 2) = X_j(j)
  T_S_z(3*j - 2) = z0
  T_S_x(3*j - 1) = X_j(j) + 0.3*H*cos(TH(j))
  T_S_z(3*j - 1) = z0 + 0.3*H*sin(TH(j))
  T_S_x(3*j) = X_j(j)
  T_S_z(3*j) = z0
  T_S_g(j) = TH(j)*180/pi
end
#show
#dibujo("Spencer: todas las Z paralelas, θ constante", ud = m, escala = auto, alto = 80)
#  polilinea(G_x, G_z, "gruesa")
#  polilinea(X_z, Z_z, "fina gris")
#  polilinea(T_S_x, T_S_z, "media morado")
#  texto(x_ini, H, "θ = {theta_S:1}° en todos los bordes, F = {F_Spencer:4}", 2.6, "i")
#  hover(X_j, Zo_j, "θ = {#1:1}°", T_S_g)
#fin
dF_S = F_f - F_m 'comprobación: F de fuerzas − F de momentos (debe ser ≈ 0)
#: **Qué significa:** es el método «riguroso» que XSLOPE recomienda para diseñar: no supone la dirección de las fuerzas entre dovelas, la **calcula**.

## 10 · Morgenstern-Price

#: **Suposición:** la inclinación de las fuerzas entre dovelas **varía** a lo largo de la superficie según una función f(x) que se elige: tan θ_{j} = λ·f(x_{j}). XSLOPE usa por defecto la **media onda de seno**, que vale 0 en los dos extremos (no se transmite cortante más allá del pie ni de la coronación):
#: f(x) = sen[π·(x − x_{L})/(x_{R} − x_{L})]
#: **Equilibrio que cumple:** todo, como Spencer. **Incógnitas:** F y λ, con las mismas dos condiciones F_{f}(λ) = F_{m}(λ). Con f(x) = 1 es **exactamente Spencer** (XSLOPE se verifica así, a 10⁻¹⁰).
#hide
f_x = zeros(n + 1, 1)
for j = 1:n + 1
  f_x(j) = sin(pi*(X_j(j) - x_a)/(x_b - x_a))
end
S_p = lamsol(f_x, F_B, W_T, W, al, dl, cc, tp, uu, xm, yb, n)
l_q = S_p(1)
F_f = S_p(2)
F_m = S_p(3)
#show
lambda_MP = l_q 'λ de Morgenstern-Price (con media onda de seno)
F_MP = (F_f + F_m)/2 'Morgenstern-Price
#hide
TH = zeros(n + 1, 1)
F_xz = zeros(n + 1, 1)
for j = 1:n + 1
  TH(j) = atan(l_q*f_x(j))
  F_xz(j) = z_fondo + 0.3*H*f_x(j)
end
#show
#hide
T_M_x = zeros(3*(n + 1), 1)
T_M_z = zeros(3*(n + 1), 1)
T_M_g = zeros(n + 1, 1)
for j = 1:n + 1
  z0 = z_o(X_j(j))
  T_M_x(3*j - 2) = X_j(j)
  T_M_z(3*j - 2) = z0
  T_M_x(3*j - 1) = X_j(j) + 0.3*H*cos(TH(j))
  T_M_z(3*j - 1) = z0 + 0.3*H*sin(TH(j))
  T_M_x(3*j) = X_j(j)
  T_M_z(3*j) = z0
  T_M_g(j) = TH(j)*180/pi
end
#show
#dibujo("Morgenstern-Price: tan θ = λ·f(x) (abajo, la curva f(x))", ud = m, escala = auto, alto = 80)
#  polilinea(G_x, G_z, "gruesa")
#  polilinea(X_z, Z_z, "fina gris")
#  polilinea(T_M_x, T_M_z, "media morado")
#  polilinea(X_j, F_xz, "media azul")
#  linea(x_a, z_fondo, x_b, z_fondo, "fina")
#  texto(x_b, z_fondo + 0.1*H, "f(x)", 2.6, "i")
#  texto(x_ini, H, "λ = {lambda_MP:3}, F = {F_MP:4}", 2.6, "i")
#  hover(X_j, Zo_j, "θ = {#1:1}°", T_M_g)
#fin
dF_MP = F_f - F_m 'comprobación: F de fuerzas − F de momentos (debe ser ≈ 0)
#: **Qué significa:** es el más general. El F casi no depende de la f(x) elegida; λ sí.

## 11 · Los siete juntos

F_OMS = F_OMS 'Fellenius (solo momentos, sin fuerzas entre dovelas)
F_Bishop = F_Bishop 'Bishop (momentos + vertical, fuerzas horizontales)
F_Janbu = F_Janbu 'Janbu corregido (solo fuerzas, sin cortante entre dovelas)
F_Corps = F_Corps 'Cuerpo de Ingenieros #2 (solo fuerzas, θ = terreno)
F_LoweK = F_LoweK 'Lowe-Karafiath (solo fuerzas, θ = promedio terreno y base)
F_Spencer = F_Spencer 'Spencer (todo, θ constante)
F_MP = F_MP 'Morgenstern-Price (todo, θ = λ·f(x))
#hide
F_v = zeros(7, 1)
B_x = zeros(7, 1)
B_h = zeros(7, 1)
B_c = zeros(7, 1)
B_t = zeros(7, 1)
B_y = zeros(7, 1)
for k = 1:1
  F_v(1) = F_OMS
  F_v(2) = F_Bishop
  F_v(3) = F_Janbu
  F_v(4) = F_Corps
  F_v(5) = F_LoweK
  F_v(6) = F_Spencer
  F_v(7) = F_MP
end
F_0b = floor(10*min(F_v) - 1)/10
for j = 1:7
  B_x(j) = 1.5*(j - 1)
  B_h(j) = 20*(F_v(j) - F_0b)
  B_c(j) = B_x(j) + 0.5
  B_t(j) = B_h(j) + 0.25
  B_y(j) = -0.5 - 0.6*(j - 2*floor(j/2))
end
#show
#dibujo("Los siete F", alto = 110)
#  rect(B_x, 0, 1, B_h, "media azul")
#  linea(-0.5, 0, 10.5, 0, "media")
#  texto(-0.6, 0, "{F_0b:2}", 2.5, "d")
#  texto(B_c, B_t, {"{F_OMS:3}", "{F_Bishop:3}", "{F_Janbu:3}", "{F_Corps:3}", "{F_LoweK:3}", "{F_Spencer:3}", "{F_MP:3}"}, 2.4, "c")
#  texto(B_c, B_y, {"OMS", "Bishop", "Janbu", "Corps", "L-K", "Spencer", "M-P"}, 2.4, "c")
#  hover(B_c, B_h, "F = {#1:4}", F_v)
#fin
#: **Cómo leerlo.** Los dos métodos completos (Spencer y Morgenstern-Price) y Bishop quedan casi iguales en un círculo: cumplen los momentos, que es lo que más pesa. Fellenius sale más bajo porque ignora las fuerzas entre dovelas. Los de solo fuerzas dependen de la θ que suponen: Corps #2 sale más alto, como avisa XSLOPE.
#: Este es un círculo de prueba; para el **factor de seguridad del talud** hay que buscar el círculo crítico (el de F mínimo), que XSLOPE hace con su búsqueda automática.

## 12 · El otro algoritmo de XSLOPE: elementos finitos con reducción de resistencia (SSR)

#: No usa dovelas. Se modela el talud con elementos finitos (XSLOPE usa por defecto triángulos de 6 nodos) y se **reduce** la resistencia del suelo por un factor F hasta que el talud no puede quedar en equilibrio:
#: c_{r} = c/F,   tan φ_{r} = tan φ/F
#hide
c_r1 = c/F_Spencer
p_r1 = atan(t_p/F_Spencer)*180/pi
k_1 = 14
k_2 = 30
x_f1 = A_x(k_1) + 0.15*H
z_f1 = A_z(k_1) + 0.25*H
x_f2 = A_x(k_2) + 0.15*H
z_f2 = A_z(k_2) + 0.25*H
x_f1b = A_x(k_1) - 0.05*H
z_f1b = A_z(k_1) + 0.13*H
x_f2b = A_x(k_2) - 0.05*H
z_f2b = A_z(k_2) + 0.13*H
#show
#dibujo("SSR: sin dovelas; en la falla c y tan φ ya están divididos por F", ud = m, escala = auto, alto = 75)
#  poligono(x_ini, z_fondo, x_ini, 0, 0, 0, x_cr, H, x_fin, H, x_fin, z_fondo, "fina gris")
#  polilinea(G_x, G_z, "gruesa")
#  polilinea(A_x, A_z, "muygruesa naranja")
#  flecha(x_f1, z_f1, x_f1b, z_f1b, "rojo")
#  flecha(x_f2, z_f2, x_f2b, z_f2b, "rojo")
#  texto(x_su, z_su + 0.15*H, "con F = {F_Spencer:3}", 2.6, "i")
#  texto(x_su, z_su, "c_r = c/F = {c_r1:2} kPa", 2.6, "i")
#  texto(x_su, z_su - 0.15*H, "φ_r = atan(tan φ/F) = {p_r1:1}°", 2.6, "i")
#fin
#: **Plasticidad:** Mohr-Coulomb, con el método **viscoplástico explícito** de Smith y Griffiths: la rigidez elástica K se factoriza **una sola vez**; en cada paso, el exceso sobre la superficie de fluencia se convierte en deformación viscoplástica, ε^{vp} += Δt·∂Q/∂σ·⟨f⟩, con Δt = 4·(1 + ν)/(3·E), y vuelve como carga. Flujo **no asociado** con dilatancia ψ = 0.
#: **Cuándo falla:** XSLOPE usa un criterio híbrido: (1) que no converja (desplazamientos y fuerzas por nodo con tolerancia 10⁻³) y (2) que el desplazamiento crezca respecto al elástico, u/u_{elástico} ≥ 1.5. El F de falla se busca por **bisección** entre 1 y 2 (ampliando el intervalo si hace falta) con tolerancia 0.01.
#: **Qué significa:** no hay que suponer nada sobre la forma de la superficie ni sobre las fuerzas entre dovelas: la falla **aparece** sola, como la zona donde se concentra la deformación cortante. Hekatan Geotechnic hace lo mismo con Newton-Raphson en vez del método viscoplástico (hoja 164).
