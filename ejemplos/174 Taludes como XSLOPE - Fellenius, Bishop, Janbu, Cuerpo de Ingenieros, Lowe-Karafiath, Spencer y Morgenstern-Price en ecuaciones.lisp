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

## 3 · Fellenius (Método Ordinario de Dovelas, OMS)

#: **Suposición:** las fuerzas entre dovelas **no existen** (se anulan). **Equilibrio que cumple:** solo el de momentos de toda la masa respecto al centro del círculo. **Incógnitas:** solo F; sale directo, sin iterar.
#: Sin fuerzas en las caras, la normal en la base sale de equilibrar la dovela perpendicular a su base: N_{i} = W_{i}·cos α_{i}. El momento que resiste (cortante de la base × R) entre el que empuja (peso × brazo, W·R·sen α):
#: F = Σ [c·Δℓ + (W·cos α − u·Δℓ·cos²α)·tan φ] / Σ W·sen α    (XSLOPE usa la forma con u·Δℓ·cos²α, la «preferida»: evita normales negativas con mucha agua)
F_OMS = sum(cc.*dl + (W.*cos(al) - uu.*dl.*cos(al).^2).*tp)/sum(W.*sin(al)) 'Fellenius
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
  Fa = 0.3
  ra = residuo(t, Fa, TH, W, al, dl, cc, tp, uu, xm, yb, n)
  best = -1
  dmin = 1e9
  for k = 1:185
    Fb = 0.3 + 0.02*k
    rb = residuo(t, Fb, TH, W, al, dl, cc, tp, uu, xm, yb, n)
    if ra*rb <= 0
      if abs(ra) + abs(rb) < 20*WT*(1 + 30*(t - 1))
        if abs((Fa + Fb)/2 - Fref) < dmin
          dmin = abs((Fa + Fb)/2 - Fref)
          best = Fa
        end
      end
    end
    Fa = Fb
    ra = rb
  end
  Fl = best
  Fu = best + 0.02
  rl = residuo(t, Fl, TH, W, al, dl, cc, tp, uu, xm, yb, n)
  for k = 1:45
    Fq = (Fl + Fu)/2
    rq = residuo(t, Fq, TH, W, al, dl, cc, tp, uu, xm, yb, n)
    if rl*rq <= 0
      Fu = Fq
    else
      Fl = Fq
      rl = rq
    end
  end
  Fr = (Fl + Fu)/2
end
#show
#: El F de cada método se busca como XSLOPE: se recorre F de 0.3 a 4, se marcan los cambios de signo del residuo (descartando los polos, donde el determinante de A se hace cero y el residuo salta), se toma la raíz más cercana al valor de momentos (Bishop) y se afina por bisección.

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
#: **Qué significa:** según el manual EM 1110-2-1902 suele quedar a menos de ~10 % de los métodos completos. Ojo en superficies no circulares: como θ sigue a la base, una base casi vertical en el pie baja F artificialmente.

## 9 · Spencer

#: **Suposición:** todas las fuerzas entre dovelas son **paralelas**: la misma inclinación θ en todos los bordes, tan θ = λ. **Equilibrio que cumple:** **todo** (fuerzas horizontales, verticales y momentos). **Incógnitas:** F y λ.
#: Para cada λ hay dos factores de seguridad: F_{f}(λ), el que cierra las fuerzas (Z_{n+1} = 0), y F_{m}(λ), el que cierra los momentos (R_{m} = 0). La solución es el λ donde **los dos coinciden**: F_{f}(λ) = F_{m}(λ). XSLOPE lo resuelve con Newton en 2D; aquí se recorre λ de −0.3 a 1.2, se toma el cruce de las dos curvas y se afina por bisección (mismo resultado).
#hide
l_a = -1
l_b = -1
dmin = 1e9
l_p = -0.3
TH = atan(l_p)*ones(n + 1, 1)
F_f = raiz(1, TH, F_B, W_T, W, al, dl, cc, tp, uu, xm, yb, n)
F_m = raiz(2, TH, F_B, W_T, W, al, dl, cc, tp, uu, xm, yb, n)
g_p = F_f - F_m
m_p = F_m
for s = 1:30
  l_q = -0.3 + 0.05*s
  TH = atan(l_q)*ones(n + 1, 1)
  F_f = raiz(1, TH, F_B, W_T, W, al, dl, cc, tp, uu, xm, yb, n)
  F_m = raiz(2, TH, F_B, W_T, W, al, dl, cc, tp, uu, xm, yb, n)
  g_q = F_f - F_m
  if m_p > 0.4
    if F_m > 0.4
      if g_p*g_q <= 0
        if abs(F_f - F_B) < dmin
          dmin = abs(F_f - F_B)
          l_a = l_p
          l_b = l_q
        end
      end
    end
  end
  l_p = l_q
  g_p = g_q
  m_p = F_m
end
TH = atan(l_a)*ones(n + 1, 1)
g_a = raiz(1, TH, F_B, W_T, W, al, dl, cc, tp, uu, xm, yb, n) - raiz(2, TH, F_B, W_T, W, al, dl, cc, tp, uu, xm, yb, n)
for k = 1:30
  l_q = (l_a + l_b)/2
  for j = 1:n + 1
    TH(j) = atan(l_q)
  end
  F_f = raiz(1, TH, F_B, W_T, W, al, dl, cc, tp, uu, xm, yb, n)
  F_m = raiz(2, TH, F_B, W_T, W, al, dl, cc, tp, uu, xm, yb, n)
  g_q = F_f - F_m
  if g_a*g_q <= 0
    l_b = l_q
  else
    l_a = l_q
    g_a = g_q
  end
end
#show
lambda_S = l_q 'λ de Spencer = tan θ
theta_S = atan(l_q)·180/pi 'inclinación de las fuerzas entre dovelas [grados]
F_Spencer = (F_f + F_m)/2 'Spencer
dF_S = F_f - F_m 'comprobación: F de fuerzas − F de momentos (debe ser ≈ 0)
#: **Qué significa:** es el método «riguroso» que XSLOPE recomienda para diseñar: no supone la dirección de las fuerzas entre dovelas, la **calcula**.

## 10 · Morgenstern-Price

#: **Suposición:** la inclinación de las fuerzas entre dovelas **varía** a lo largo de la superficie según una función f(x) que se elige: tan θ_{j} = λ·f(x_{j}). XSLOPE usa por defecto la **media onda de seno**, que vale 0 en los dos extremos (no se transmite cortante más allá del pie ni de la coronación):
#: f(x) = sen[π·(x − x_{L})/(x_{R} − x_{L})]
#: **Equilibrio que cumple:** todo, como Spencer. **Incógnitas:** F y λ, con las mismas dos condiciones F_{f}(λ) = F_{m}(λ). Con f(x) = 1 es **exactamente Spencer** (XSLOPE se verifica así, a 10⁻¹⁰).
#hide
l_a = -0.3
l_b = 1.2
for j = 1:n + 1
  TH(j) = atan(l_a*sin(pi*(X_j(j) - x_a)/(x_b - x_a)))
end
g_a = raiz(1, TH, F_B, W_T, W, al, dl, cc, tp, uu, xm, yb, n) - raiz(2, TH, F_B, W_T, W, al, dl, cc, tp, uu, xm, yb, n)
for k = 1:30
  l_q = (l_a + l_b)/2
  for j = 1:n + 1
    TH(j) = atan(l_q*sin(pi*(X_j(j) - x_a)/(x_b - x_a)))
  end
  F_f = raiz(1, TH, F_B, W_T, W, al, dl, cc, tp, uu, xm, yb, n)
  F_m = raiz(2, TH, F_B, W_T, W, al, dl, cc, tp, uu, xm, yb, n)
  g_q = F_f - F_m
  if g_a*g_q <= 0
    l_b = l_q
  else
    l_a = l_q
    g_a = g_q
  end
end
#show
lambda_MP = l_q 'λ de Morgenstern-Price (con media onda de seno)
F_MP = (F_f + F_m)/2 'Morgenstern-Price
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
#: **Cómo leerlo.** Los dos métodos completos (Spencer y Morgenstern-Price) y Bishop quedan casi iguales en un círculo: cumplen los momentos, que es lo que más pesa. Fellenius sale más bajo porque ignora las fuerzas entre dovelas. Los de solo fuerzas dependen de la θ que suponen: Corps #2 sale más alto, como avisa XSLOPE.
#: Este es un círculo de prueba; para el **factor de seguridad del talud** hay que buscar el círculo crítico (el de F mínimo), que XSLOPE hace con su búsqueda automática.

## 12 · El otro algoritmo de XSLOPE: elementos finitos con reducción de resistencia (SSR)

#: No usa dovelas. Se modela el talud con elementos finitos (XSLOPE usa por defecto triángulos de 6 nodos) y se **reduce** la resistencia del suelo por un factor F hasta que el talud no puede quedar en equilibrio:
#: c_{r} = c/F,   tan φ_{r} = tan φ/F
#: **Plasticidad:** Mohr-Coulomb, con el método **viscoplástico explícito** de Smith y Griffiths: la rigidez elástica K se factoriza **una sola vez**; en cada paso, el exceso sobre la superficie de fluencia se convierte en deformación viscoplástica, ε^{vp} += Δt·∂Q/∂σ·⟨f⟩, con Δt = 4·(1 + ν)/(3·E), y vuelve como carga. Flujo **no asociado** con dilatancia ψ = 0.
#: **Cuándo falla:** XSLOPE usa un criterio híbrido: (1) que no converja (desplazamientos y fuerzas por nodo con tolerancia 10⁻³) y (2) que el desplazamiento crezca respecto al elástico, u/u_{elástico} ≥ 1.5. El F de falla se busca por **bisección** entre 1 y 2 (ampliando el intervalo si hace falta) con tolerancia 0.01.
#: **Qué significa:** no hay que suponer nada sobre la forma de la superficie ni sobre las fuerzas entre dovelas: la falla **aparece** sola, como la zona donde se concentra la deformación cortante. Hekatan Geotechnic hace lo mismo con Newton-Raphson en vez del método viscoplástico (hoja 164).
