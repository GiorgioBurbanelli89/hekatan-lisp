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
#: El terreno: horizontal a cota 0 delante del pie, sube con pendiente 1/2 hasta la coronación y sigue horizontal a cota 10:
z_t(x) = min(max(x/2, 0), H)
#: **El círculo de prueba** (no es el crítico; sirve para comparar los métodos en la misma superficie). Pasa por el pie y sale por la coronación:
x_c = 8 'centro del círculo, x [m]
z_c = 22 'centro del círculo, z [m]
R = sqrt(x_c^2 + z_c^2) 'radio: el círculo pasa por el pie (0; 0) [m]
z_o(x) = z_c - sqrt(R^2 - (x - x_c)^2)
x_a = 0 'entrada por el pie [m]
x_b = x_c + sqrt(R^2 - (z_c - H)^2) 'salida en la coronación [m]
#hide
a_e = -90 - atan((x_c - x_a)/(z_c - z_o(x_a)))*180/pi
a_s = -90 + atan((x_b - x_c)/(z_c - H))*180/pi
z_a0 = z_o(x_a)
G_x = zeros(4, 1)
G_z = zeros(4, 1)
P_x = zeros(3, 1)
P_z = zeros(3, 1)
for k = 1:1
  G_x(1) = -6
  G_x(3) = 2*H
  G_x(4) = 2*H + 14
  G_z(3) = H
  G_z(4) = H
  P_x(1) = x_a
  P_z(1) = z_a0
  P_x(2) = x_b
  P_z(2) = H
  P_x(3) = x_c
  P_z(3) = z_c
end
A_x = zeros(41, 1)
A_z = zeros(41, 1)
for k = 1:41
  a_k = (a_e + (a_s - a_e)*(k - 1)/40)*pi/180
  A_x(k) = x_c + R*cos(a_k)
  A_z(k) = z_c + R*sin(a_k)
end
#show
#dibujo("El talud, el círculo de prueba y su centro O", ud = m, escala = auto, cotas = m, alto = 105)
#  poligono(-6, -5, -6, 0, 0, 0, 2*H, H, 2*H + 14, H, 2*H + 14, -5, "fina gris")
#  polilinea(G_x, G_z, "gruesa")
#  arco(x_c, z_c, R, a_e, a_s, "gruesa rojo")
#  circulo(x_c, z_c, 0.35, "rojo")
#  texto(x_c + 0.6, z_c + 0.2, "O", 3.2, "i")
#  linea(x_c, z_c, x_a, z_a0, "fina trazos rojo")
#  linea(x_c, z_c, x_b, H, "fina trazos rojo")
#  texto((x_c + x_b)/2 + 0.6, (z_c + H)/2, "R", 3.2, "i")
#  texto(8, 3.2, "2:1", 3, "c")
#  texto(26, 6.5, "c, φ, γ", 3, "c")
#  cota(-3, 0, -3, H, 0)
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
#hide
X_z = zeros(3*(n + 1), 1)
Z_z = zeros(3*(n + 1), 1)
for j = 1:n + 1
  X_z(3*j - 2) = X_j(j)
  X_z(3*j - 1) = X_j(j)
  X_z(3*j) = X_j(j)
  Z_z(3*j - 2) = z_o(X_j(j))
  Z_z(3*j - 1) = z_t(X_j(j))
  Z_z(3*j) = z_o(X_j(j))
end
a_g = zeros(n, 1)
for i = 1:n
  a_g(i) = al(i)*180/pi
end
Zo_j = zeros(n + 1, 1)
for j = 1:n + 1
  Zo_j(j) = z_o(X_j(j))
end
x_15 = X_j(15) + b/2
z_15t = z_t(X_j(15)) + 1.2
z_15b = z_o(X_j(15)) - 1.3
#show
#dibujo("Las 20 dovelas: base = cuerda del círculo (pasa el cursor: W y α de cada una)", ud = m, escala = auto, alto = 70)
#  polilinea(G_x, G_z, "gruesa")
#  polilinea(X_z, Z_z, "media rojo")
#  texto(x_15, z_15t, "dovela i", 2.6, "c")
#  texto(x_15, z_15b, "b, Δℓ, α", 2.6, "c")
#  hover(xm, yb, "dovela: W = {#1:1} kN/m, α = {#2:1}°, Δℓ = {#3:2} m", W, a_g, dl)
#fin

## 3 · Fellenius (Método Ordinario de Dovelas, OMS)

#: **Suposición:** las fuerzas entre dovelas **no existen** (se anulan). **Equilibrio que cumple:** solo el de momentos de toda la masa respecto al centro del círculo. **Incógnitas:** solo F; sale directo, sin iterar.
#: Sin fuerzas en las caras, la normal en la base sale de equilibrar la dovela perpendicular a su base: N_{i} = W_{i}·cos α_{i}. El momento que resiste (cortante de la base × R) entre el que empuja (peso × brazo, W·R·sen α):
#: F = Σ [c·Δℓ + (W·cos α − u·Δℓ·cos²α)·tan φ] / Σ W·sen α    (XSLOPE usa la forma con u·Δℓ·cos²α, la «preferida»: evita normales negativas con mucha agua)
F_OMS = sum(cc.*dl + (W.*cos(al) - uu.*dl.*cos(al).^2).*tp)/sum(W.*sin(al)) 'Fellenius
#dibujo("Fellenius: sin fuerzas entre dovelas; N = W·cos α; momentos respecto a O", alto = 150, lado = derecha)
#  poligono(0, 0, 4, 1.6, 4, 6, 0, 5, "gruesa")
#  linea(0, 0, 2.6, 0, "fina trazos")
#  texto(1.7, 0.18, "α", 3, "i")
#  flecha(2, 4.6, 2, 2.5, "rojo")
#  texto(2.2, 3.7, "W", 3.2, "i")
#  flecha(2.82, -1.24, 2, 0.8, "azul")
#  texto(2.95, -1.25, "N'", 3.2, "i")
#  flecha(0.77, -0.18, 2.57, 0.54, "verde")
#  texto(-0.6, -1.1, "S = [c·Δℓ + N'·tan φ]/F", 2.6, "i")
#  circulo(-3, 9, 0.18, "rojo")
#  texto(-2.6, 9.1, "O", 3, "i")
#  linea(-3, 9, 2, 0.8, "fina trazos rojo")
#  texto(-1.5, 6.5, "R", 3, "i")
#  texto(4.6, 5.2, "sin Z en las caras", 2.6, "i")
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
#dibujo("Bishop: fuerzas entre dovelas horizontales (E); ΣF_y = 0 por dovela y ΣM_O = 0", alto = 150, lado = derecha)
#  poligono(0, 0, 4, 1.6, 4, 6, 0, 5, "gruesa")
#  linea(0, 0, 2.6, 0, "fina trazos")
#  texto(1.7, 0.18, "α", 3, "i")
#  flecha(2, 4.6, 2, 2.5, "rojo")
#  texto(2.2, 3.7, "W", 3.2, "i")
#  flecha(2.82, -1.24, 2, 0.8, "azul")
#  texto(2.95, -1.25, "N'", 3.2, "i")
#  flecha(0.77, -0.18, 2.57, 0.54, "verde")
#  texto(-0.6, -1.1, "S = [c·Δℓ + N'·tan φ]/F", 2.6, "i")
#  flecha(-2.2, 2.4, 0, 2.4, "naranja")
#  texto(-2.3, 2.75, "Eᵢ", 3, "i")
#  flecha(6.2, 3.6, 4, 3.6, "naranja")
#  texto(4.5, 3.95, "Eᵢ₊₁", 3, "i")
#  texto(-0.4, 7, "m_α = cos α + sen α·tan φ/F", 2.6, "i")
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
z_m1 = (z_o(x_a) + z_o(x_b))/2
x_L1 = (x_a + x_b)/2 + 1
z_L1 = (z_a0 + H)/2 + 1
J_x = zeros(2, 1)
J_z = zeros(2, 1)
J_L = zeros(2, 1)
J_d = zeros(2, 1)
J_f = zeros(2, 1)
r_m1 = sqrt((x_m1 - x_c)^2 + (z_m1 - z_c)^2)
x_d1 = x_c + R*(x_m1 - x_c)/r_m1
z_d1 = z_c + R*(z_m1 - z_c)/r_m1
for j = 1:2
  J_L(j) = L_c
  J_d(j) = d_c
  J_f(j) = f_0
end
for k = 1:1
  J_x(1) = x_m1
  J_z(1) = z_m1
  J_x(2) = x_d1
  J_z(2) = z_d1
end
#show
#dibujo("Janbu: ΣF_x = 0 de toda la masa; corrección f₀ con la flecha d y la cuerda L", ud = m, escala = auto, alto = 72)
#  polilinea(G_x, G_z, "gruesa")
#  polilinea(A_x, A_z, "gruesa rojo")
#  linea(x_a, z_a0, x_b, H, "media trazos azul")
#  linea(x_m1, z_m1, x_d1, z_d1, "gruesa azul")
#  texto(x_L1, z_L1, "L", 3.2, "i")
#  texto(x_d1 + 0.5, z_d1 + 0.8, "d", 3.2, "i")
#  texto(-4, H + 1, "f₀ = 1 + b₁·[d/L − 1.4·(d/L)²]", 2.6, "i")
#  hover(J_x, J_z, "L = {#1:2} m, d = {#2:2} m, f₀ = {#3:4}", J_L, J_d, J_f)
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
#dibujo("El barrido: en cada dovela 2 incógnitas (N' y Zᵢ₊₁) y 2 ecuaciones (ΣF_x, ΣF_y)", alto = 150, lado = derecha)
#  poligono(0, 0, 4, 1.6, 4, 6, 0, 5, "gruesa")
#  linea(0, 0, 2.6, 0, "fina trazos")
#  texto(1.7, 0.18, "α", 3, "i")
#  flecha(2, 4.6, 2, 2.5, "rojo")
#  texto(2.2, 3.7, "W", 3.2, "i")
#  flecha(2.82, -1.24, 2, 0.8, "azul")
#  texto(2.95, -1.25, "N'", 3.2, "i")
#  flecha(0.77, -0.18, 2.57, 0.54, "verde")
#  texto(-0.6, -1.1, "S = [c·Δℓ + N'·tan φ]/F", 2.6, "i")
#  flecha(-2.125, 2.03, 0, 2.6, "morado")
#  texto(-2.6, 1.5, "Zᵢ (conocida)", 2.6, "i")
#  flecha(6.125, 4.17, 4, 3.6, "morado")
#  texto(4.4, 4.7, "Zᵢ₊₁ (incógnita)", 2.6, "i")
#  linea(4, 3.6, 6.2, 3.6, "fina trazos")
#  texto(5.3, 3.2, "θ", 3, "i")
#  texto(-2.6, 7.4, "Z₁ = 0 → … → Zₙ₊₁(F) = 0", 2.8, "i")
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
for j = 1:n + 1
  z0 = z_o(X_j(j))
  T_C_x(3*j - 2) = X_j(j)
  T_C_z(3*j - 2) = z0
  T_C_x(3*j - 1) = X_j(j) + 3*cos(TH(j))
  T_C_z(3*j - 1) = z0 + 3*sin(TH(j))
  T_C_x(3*j) = X_j(j)
  T_C_z(3*j) = z0
end
T_C_g = zeros(n + 1, 1)
for j = 1:n + 1
  T_C_g(j) = TH(j)*180/pi
end
#show
#dibujo("Cuerpo de Ingenieros #2: Z en cada borde paralela al terreno (θ = pendiente del terreno)", ud = m, escala = auto, alto = 78)
#  polilinea(G_x, G_z, "gruesa")
#  polilinea(X_z, Z_z, "fina gris")
#  polilinea(T_C_x, T_C_z, "media morado")
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
for j = 1:n + 1
  z0 = z_o(X_j(j))
  T_L_x(3*j - 2) = X_j(j)
  T_L_z(3*j - 2) = z0
  T_L_x(3*j - 1) = X_j(j) + 3*cos(TH(j))
  T_L_z(3*j - 1) = z0 + 3*sin(TH(j))
  T_L_x(3*j) = X_j(j)
  T_L_z(3*j) = z0
end
T_L_g = zeros(n + 1, 1)
for j = 1:n + 1
  T_L_g(j) = TH(j)*180/pi
end
#show
#dibujo("Lowe-Karafiath: θ = promedio de la pendiente del terreno y la del círculo", ud = m, escala = auto, alto = 78)
#  polilinea(G_x, G_z, "gruesa")
#  polilinea(X_z, Z_z, "fina gris")
#  polilinea(T_L_x, T_L_z, "media morado")
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
F_Spencer = (F_f + F_m)/2 'Spencer
#hide
for j = 1:n + 1
  TH(j) = atan(l_q)
end
#show
#hide
T_S_x = zeros(3*(n + 1), 1)
T_S_z = zeros(3*(n + 1), 1)
for j = 1:n + 1
  z0 = z_o(X_j(j))
  T_S_x(3*j - 2) = X_j(j)
  T_S_z(3*j - 2) = z0
  T_S_x(3*j - 1) = X_j(j) + 3*cos(TH(j))
  T_S_z(3*j - 1) = z0 + 3*sin(TH(j))
  T_S_x(3*j) = X_j(j)
  T_S_z(3*j) = z0
end
T_S_g = zeros(n + 1, 1)
for j = 1:n + 1
  T_S_g(j) = TH(j)*180/pi
end
#show
#dibujo("Spencer: todas las Z paralelas, θ constante (sale de F_f = F_m)", ud = m, escala = auto, alto = 78)
#  polilinea(G_x, G_z, "gruesa")
#  polilinea(X_z, Z_z, "fina gris")
#  polilinea(T_S_x, T_S_z, "media morado")
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
for j = 1:n + 1
  TH(j) = atan(l_q*f_x(j))
end
F_xz = zeros(n + 1, 1)
for j = 1:n + 1
  F_xz(j) = -4 + 3*f_x(j)
end
#show
#hide
T_M_x = zeros(3*(n + 1), 1)
T_M_z = zeros(3*(n + 1), 1)
for j = 1:n + 1
  z0 = z_o(X_j(j))
  T_M_x(3*j - 2) = X_j(j)
  T_M_z(3*j - 2) = z0
  T_M_x(3*j - 1) = X_j(j) + 3*cos(TH(j))
  T_M_z(3*j - 1) = z0 + 3*sin(TH(j))
  T_M_x(3*j) = X_j(j)
  T_M_z(3*j) = z0
end
T_M_g = zeros(n + 1, 1)
for j = 1:n + 1
  T_M_g(j) = TH(j)*180/pi
end
#show
#dibujo("Morgenstern-Price: tan θ = λ·f(x), con f(x) = media onda de seno (abajo)", ud = m, escala = auto, alto = 95)
#  polilinea(G_x, G_z, "gruesa")
#  polilinea(X_z, Z_z, "fina gris")
#  polilinea(T_M_x, T_M_z, "media morado")
#  polilinea(X_j, F_xz, "media azul")
#  linea(x_a, -4, x_b, -4, "fina")
#  texto(x_b + 0.5, -3, "f(x)", 2.8, "i")
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
for k = 1:1
  F_v(1) = F_OMS
  F_v(2) = F_Bishop
  F_v(3) = F_Janbu
  F_v(4) = F_Corps
  F_v(5) = F_LoweK
  F_v(6) = F_Spencer
  F_v(7) = F_MP
end
B_x = zeros(7, 1)
B_h = zeros(7, 1)
B_c = zeros(7, 1)
for j = 1:7
  B_x(j) = 1.5*(j - 1)
  B_h(j) = 20*(F_v(j) - 1.4)
  B_c(j) = B_x(j) + 0.5
end
#show
#dibujo("Los siete F (barras desde F = 1.40; pasa el cursor para ver cada valor)", alto = 105)
#  rect(B_x, 0, 1, B_h, "media azul")
#  linea(-0.5, 0, 10.5, 0, "media")
#  texto(-0.6, 0, "1.40", 2.6, "d")
#  texto(0.5, -0.5, "OMS", 2.4, "c")
#  texto(1.5 + 0.5, -1.1, "Bishop", 2.4, "c")
#  texto(3.5, -0.5, "Janbu", 2.4, "c")
#  texto(5, -1.1, "Corps", 2.4, "c")
#  texto(6.5, -0.5, "L-K", 2.4, "c")
#  texto(8, -1.1, "Spencer", 2.4, "c")
#  texto(9.5, -0.5, "M-P", 2.4, "c")
#  hover(B_c, B_h, "F = {#1:4}", F_v)
#fin
#: **Cómo leerlo.** Los dos métodos completos (Spencer y Morgenstern-Price) y Bishop quedan casi iguales en un círculo: cumplen los momentos, que es lo que más pesa. Fellenius sale más bajo porque ignora las fuerzas entre dovelas. Los de solo fuerzas dependen de la θ que suponen: Corps #2 sale más alto, como avisa XSLOPE.
#: Este es un círculo de prueba; para el **factor de seguridad del talud** hay que buscar el círculo crítico (el de F mínimo), que XSLOPE hace con su búsqueda automática.

## 12 · El otro algoritmo de XSLOPE: elementos finitos con reducción de resistencia (SSR)

#: No usa dovelas. Se modela el talud con elementos finitos (XSLOPE usa por defecto triángulos de 6 nodos) y se **reduce** la resistencia del suelo por un factor F hasta que el talud no puede quedar en equilibrio:
#: c_{r} = c/F,   tan φ_{r} = tan φ/F
#dibujo("Reducción de resistencia (SSR): sin dovelas; la falla aparece como una banda de corte", ud = m, escala = auto, alto = 75)
#  poligono(-6, -5, -6, 0, 0, 0, 2*H, H, 2*H + 14, H, 2*H + 14, -5, "fina gris")
#  polilinea(G_x, G_z, "gruesa")
#  polilinea(A_x, A_z, "muygruesa naranja")
#  flecha(16, 6.5, 12, 4.2, "rojo")
#  flecha(24, 9.2, 21, 7.4, "rojo")
#  texto(36, 6, "cᵣ = c/F", 2.8, "i")
#  texto(36, 3.6, "tan φᵣ = tan φ/F", 2.8, "i")
#  texto(2, -3, "F sube hasta que el equilibrio no converge", 2.6, "i")
#fin
#: **Plasticidad:** Mohr-Coulomb, con el método **viscoplástico explícito** de Smith y Griffiths: la rigidez elástica K se factoriza **una sola vez**; en cada paso, el exceso sobre la superficie de fluencia se convierte en deformación viscoplástica, ε^{vp} += Δt·∂Q/∂σ·⟨f⟩, con Δt = 4·(1 + ν)/(3·E), y vuelve como carga. Flujo **no asociado** con dilatancia ψ = 0.
#: **Cuándo falla:** XSLOPE usa un criterio híbrido: (1) que no converja (desplazamientos y fuerzas por nodo con tolerancia 10⁻³) y (2) que el desplazamiento crezca respecto al elástico, u/u_{elástico} ≥ 1.5. El F de falla se busca por **bisección** entre 1 y 2 (ampliando el intervalo si hace falta) con tolerancia 0.01.
#: **Qué significa:** no hay que suponer nada sobre la forma de la superficie ni sobre las fuerzas entre dovelas: la falla **aparece** sola, como la zona donde se concentra la deformación cortante. Hekatan Geotechnic hace lo mismo con Newton-Raphson en vez del método viscoplástico (hoja 164).
