# Viga empotrada en ambos extremos: la matriz de rigidez simbólica, los momentos de empotramiento y Newton-Raphson no lineal con rótulas que se ablandan
#numerico

## 0 · De la barra a la viga empotrada
#: En las hojas 196 y 198 una **barra que se ablanda** se resolvió con Newton: la curva se cambia por su recta tangente (la rigidez del momento), se calcula lo que falta (el **residuo**) y se avanza **Δd = residuo / rigidez tangente**, hasta que el residuo es cero. En la 199 el voladizo era **isostático**: el momento M(x) salía sin resolver nada. La viga **empotrada en los dos extremos** es **hiperestática**: el momento depende de la rigidez, y cuando la sección se ablanda el momento **se mueve** de un lugar a otro (redistribución). Eso es lo nuevo de esta hoja.
#dibujo("Viga empotrada en los dos extremos: carga repartida w y carga P al centro", ud = m, escala = auto, cotas = m, alto = 80)
#  empotramiento(0, -0.6, 0, 0.6, 1)
#  empotramiento(6, -0.6, 6, 0.6, -1)
#  rect(0, -0.3, 6, 0.3, "gruesa")
#  carga(0, 0.3, 6, 0.3, 0.6, 0.6, "w", "azul", n = 13)
#  flecha(3, 2.0, 3, 0.95, "gruesa rojo")
#  texto(3.35, 1.8, "P", 3.5, "c")
#  texto(6.45, 0.6, "w", 3.5, "c")
#  cota(0, -0.9, 6, -0.9, 0, "L = 6.00 m")
#  texto(4.9, 1.6, "sección b × h = 0.30 × 0.60 m", 2.6, "c")
#fin

## 1 · La matriz de rigidez de la viga, con símbolos
#: **Funciones de forma de Hermite** de un elemento de largo L: cómo se reparte la flecha entre la flecha y el giro de cada extremo (N₁, N₂ en el nudo izquierdo; N₃, N₄ en el derecho):
N_1 = Simplify{1 - 3*x^2/L^2 + 2*x^3/L^3}
N_2 = Simplify{x - 2*x^2/L + x^3/L^2}
N_3 = Simplify{3*x^2/L^2 - 2*x^3/L^3}
N_4 = Simplify{-x^2/L + x^3/L^2}
#: La **curvatura** es la segunda derivada de la flecha, κ = Σ Nᵢ″·uᵢ. Las Nᵢ″ forman la fila **B**:
B_1 = Simplify{Diff{Diff{1 - 3*x^2/L^2 + 2*x^3/L^3 @ x} @ x}}
B_2 = Simplify{Diff{Diff{x - 2*x^2/L + x^3/L^2 @ x} @ x}}
B_3 = Simplify{Diff{Diff{3*x^2/L^2 - 2*x^3/L^3 @ x} @ x}}
B_4 = Simplify{Diff{Diff{-x^2/L + x^3/L^2 @ x} @ x}}
#: **La rigidez** es la energía de flexión: K = ∫ EI·Bᵀ·B dx. Cada término es una integral de dos de esas rectas:
k_11 = Simplify{Area{E_I*(12*x/L^3 - 6/L^2)^2 @ x = 0 : L}}
k_12 = Simplify{Area{E_I*(12*x/L^3 - 6/L^2)*(6*x/L^2 - 4/L) @ x = 0 : L}}
k_13 = Simplify{Area{E_I*(12*x/L^3 - 6/L^2)*(6/L^2 - 12*x/L^3) @ x = 0 : L}}
k_22 = Simplify{Area{E_I*(6*x/L^2 - 4/L)^2 @ x = 0 : L}}
k_24 = Simplify{Area{E_I*(6*x/L^2 - 4/L)*(6*x/L^2 - 2/L) @ x = 0 : L}}
#: Son los números de siempre: **12EI/L³, 6EI/L², −12EI/L³, 4EI/L y 2EI/L**. El 4EI/L es lo que cuesta girar un extremo con el otro empotrado; la mitad (2EI/L) «pasa» al otro extremo: por eso el factor de transporte de Cross es 1/2.

### Los momentos de empotramiento, por trabajo virtual
#: Una carga repartida no cae en los nudos: se lleva a ellos con las **mismas** funciones de forma (trabajo virtual: f = ∫ w·Nᵀ dx). Con w constante:
f_1 = Simplify{Area{w*(1 - 3*x^2/L^2 + 2*x^3/L^3) @ x = 0 : L}}
f_2 = Simplify{Area{w*(x - 2*x^2/L + x^3/L^2) @ x = 0 : L}}
f_3 = Simplify{Area{w*(3*x^2/L^2 - 2*x^3/L^3) @ x = 0 : L}}
f_4 = Simplify{Area{w*(-x^2/L + x^3/L^2) @ x = 0 : L}}
#: **wL/2 a cada lado y ±wL²/12**: son exactamente las reacciones y los **momentos de empotramiento perfecto** de las tablas. No es casualidad: con EI constante las funciones de Hermite son la deformada exacta de la viga.

### Viga de dos elementos (un nudo al centro)
#: Se parte la viga en dos elementos de largo L/2. En los empotramientos todo está fijo; las únicas incógnitas son la flecha y el giro del nudo central. Al **ensamblar**, el nudo central recibe el 12EI/l³ de los dos elementos, y los 6EI/l² (uno + y otro −) **se anulan**:
k_c = Simplify{2*12*E_I/(L/2)^3}
k_r = Simplify{2*4*E_I/(L/2)}
#: La carga en el nudo central: wl/2 de cada elemento (l = L/2); los momentos +wl²/12 y −wl²/12 también se anulan, así que **el giro del centro es cero** (simetría):
f_c = Simplify{2*w*(L/2)/2}
#: **Flecha del centro** = carga / rigidez:
v_m = Simplify{(w*L/2)/(192*E_I/L^3)}
#: **Momento en el empotramiento**: la fila del giro del apoyo, k·u menos la carga de empotramiento (con l = L/2 y la flecha recién hallada):
m_1 = Simplify{-6*E_I/(L/2)^2*w*L^4/(384*E_I) - w*(L/2)^2/12}
#: **Momento al centro**: el isostático wL²/8 menos lo que se llevan los apoyos:
m_2 = Simplify{w*L^2/8 - w*L^2/12}
#: **−wL²/12 en los apoyos y +wL²/24 al centro**: el apoyo aguanta el **doble** que el centro. Esto importa en la Parte 3: allí se ablanda primero.
#: Con una carga **P al centro** (va directa al nudo central):
d_P = Simplify{P/(192*E_I/L^3)}
m_3 = Simplify{-6*E_I/(L/2)^2*P*L^3/(192*E_I)}
#: (PL³/192EI de flecha y −PL/8 en el apoyo; al centro +PL/4 − PL/8 = +PL/8.)

## 2 · Con números (con unidades)
L_g = 6 'luz de la viga [m]
b_g = 0.30 'ancho [m]
h_g = 0.60 'altura [m]
E_c = 25000000 'módulo de elasticidad del concreto [kPa]
I_g = b_g·h_g^3/12 'inercia b·h³/12 [m⁴]
E_g = E_c·I_g 'rigidez a flexión EI [kN·m²]
w_g = 40 'carga repartida [kN/m]
P_g = 100 'carga al centro [kN]
#: **Elementos finitos** (2 elementos de Hermite, la K de la Parte 1 con números, ensamblada; las cargas por trabajo virtual) contra las **fórmulas clásicas**, para w sola, P sola y las dos juntas:
#hide
g_x = [-sqrt(3/5), 0, sqrt(3/5)]
g_w = [5/9, 8/9, 5/9]
T_l = zeros(3, 6)
for c_s = 1:3
  w_s = w_g
  p_s = P_g
  if c_s == 1
    p_s = 0
  end
  if c_s == 2
    w_s = 0
  end
  n_e = 2
  l_e = L_g/n_e
  n_d = 2·n_e + 2
  K_g = zeros(n_d, n_d)
  F_v = zeros(n_d, 1)
  for m_e = 1:n_e
    K_l = E_g·[12/l_e^3, 6/l_e^2, -12/l_e^3, 6/l_e^2; 6/l_e^2, 4/l_e, -6/l_e^2, 2/l_e; -12/l_e^3, -6/l_e^2, 12/l_e^3, -6/l_e^2; 6/l_e^2, 2/l_e, -6/l_e^2, 4/l_e]
    f_l = w_s·[l_e/2, l_e^2/12, l_e/2, -l_e^2/12]
    for a = 1:4
      F_v(2·m_e - 2 + a) = F_v(2·m_e - 2 + a) + f_l(a)
      for c = 1:4
        K_g(2·m_e - 2 + a, 2·m_e - 2 + c) = K_g(2·m_e - 2 + a, 2·m_e - 2 + c) + K_l(a, c)
      end
    end
  end
  F_v(n_e + 1) = F_v(n_e + 1) + p_s
  f_r = zeros(n_d - 4, 1)
  for a = 1:n_d - 4
    f_r(a) = a + 2
  end
  u_v = zeros(n_d, 1)
  u_f = lsolve(K_g(f_r, f_r), F_v(f_r))
  for a = 1:n_d - 4
    u_v(a + 2) = u_f(a)
  end
  r_v = K_g·u_v - F_v
  T_l(c_s, 1) = 1000·u_v(n_e + 1)
  T_l(c_s, 2) = 1000·(w_s·L_g^4/(384·E_g) + p_s·L_g^3/(192·E_g))
  T_l(c_s, 3) = r_v(2)
  T_l(c_s, 4) = -(w_s·L_g^2/12 + p_s·L_g/8)
  T_l(c_s, 5) = w_s·L_g^2/8 + p_s·L_g/4 + r_v(2)
  T_l(c_s, 6) = w_s·L_g^2/24 + p_s·L_g/8
end
#show
#tabla("Caso","flecha centro EF [mm]:4","fórmula [mm]:4","M apoyo EF [kN·m]:4","fórmula [kN·m]:4","M centro EF [kN·m]:4","fórmula [kN·m]:4")({"w = 40 kN/m (wL⁴/384EI, wL²/12, wL²/24)","P = 100 kN (PL³/192EI, PL/8, PL/8)","w + P (se suman)"}; T_l(1:3, 1); T_l(1:3, 2); T_l(1:3, 3); T_l(1:3, 4); T_l(1:3, 5); T_l(1:3, 6))
#: **Dos elementos dan el resultado exacto** (las cuatro cifras): con EI constante Hermite es la solución exacta de la viga, y las cargas por trabajo virtual son las de empotramiento perfecto. El momento del apoyo sale de la **reacción** (la fila del giro del apoyo: K·u − f).

## 3 · La misma viga NO LINEAL: las rótulas se ablandan
### La ley momento–curvatura (hipótesis)
#: **La idea:** el concreto se fisura y el acero fluye: la sección se ablanda al curvarse y **no pasa de un momento M_u** (el último). Es la misma hipérbola de la barra (hoja 196), ahora momento contra curvatura κ (q = κ):
M_k = Simplify{E_I*q/(1 + E_I*q/M_u)}
#: La **rigidez tangente** (la pendiente, la «m» de la recta de Newton) y la **secante** (M/κ):
E_t = Simplify{Diff{E_I*q/(1 + E_I*q/M_u) @ q}}
E_s = Simplify{(E_I*q/(1 + E_I*q/M_u))/q}
#: Despejando κ del momento se ve la secante en función de M: **EI_s = EI·(1 − M/M_u)**. Con M = M_u la rigidez es cero: es una **rótula**.
#: **Hipótesis** de esta parte: (1) secciones planas y viga de Euler-Bernoulli (sin cortante); (2) la misma ley en positivo y en negativo (|κ|); (3) carga creciente, sin descarga; (4) desplazamientos pequeños (sin P-Δ); (5) EI y M_u iguales en apoyos y centro.
### La carga de colapso (mecanismo de 3 rótulas)
#dibujo("Mecanismo de colapso: rótulas en los dos empotramientos y al centro", ud = m, escala = auto, alto = 70)
#  empotramiento(0, -0.5, 0, 0.5, 1)
#  empotramiento(6, -0.5, 6, 0.5, -1)
#  linea(0, 0, 6, 0, "fina")
#  linea(0, 0, 3, -0.8, "gruesa rojo")
#  linea(3, -0.8, 6, 0, "gruesa rojo")
#  circulo(0, 0, 0.12)
#  circulo(3, -0.8, 0.12)
#  circulo(6, 0, 0.12)
#  texto(0.55, -0.45, "θ", 2.6, "c")
#  texto(3, -1.25, "2θ", 2.6, "c")
#  texto(5.45, -0.45, "θ", 2.6, "c")
#  texto(3, 0.45, "δ = θ·L/2 al centro; cada rótula aguanta M_u", 2.2, "c")
#fin
#: Si las tres secciones llegan a M_u, la viga se mueve como dos barras rígidas. **Trabajo virtual**: la carga hace w·(área del triángulo) = w·L·δ/2 con δ = θL/2; las rótulas absorben M_u·(θ + 2θ + θ) = 4·M_u·θ. Igualando:
w_c = Simplify{4*M_u*theta/(L*(theta*L/2)/2)}
#: **w_u = 16·M_u/L²**. Fíjate: el cálculo elástico diría que la viga «falla» cuando el apoyo llega a M_u, con wL²/12 = M_u → w = 12·M_u/L². La redistribución da **un tercio más**: el centro todavía tenía reserva.
### Con números
M_p = 400 'momento último de la sección, igual en apoyos y centro [kN·m]
w_k = 16·M_p/L_g^2 'carga de colapso plástica 16·Mu/L² [kN/m]
w_e = 12·M_p/L_g^2 'carga con la que el apoyo ELÁSTICO llegaría a Mu [kN/m]
#: **Newton con elementos finitos** (lo que hace un programa): en cada punto de Gauss κ = B·u, M(κ) y EI_t; se arman K_T = Σ ∫ EI_t·Bᵀ·B dx y las fuerzas internas F_int = Σ ∫ Bᵀ·M dx; el residuo R = F − F_int; se resuelve **K_T·Δu = R** y se repite. La rótula del apoyo concentra la curvatura en muy poco largo, así que la malla tiene **20 elementos más cortos hacia los empotramientos** (cada uno 1.67 veces el anterior; el del centro de cada mitad es 100 veces el del apoyo), con 3 puntos de Gauss.
w_n = 120 'carga para la tabla de Newton (0.675·wu), aplicada de golpe desde cero [kN/m]
#hide
n_h = 10
q_r = 100^(1/(n_h - 1))
s_q = 0
for i = 1:n_h
  s_q = s_q + q_r^(i - 1)
end
X_g = zeros(2·n_h + 1, 1)
for i = 1:n_h
  X_g(i + 1) = X_g(i) + (L_g/2)·q_r^(i - 1)/s_q
end
for i = 1:n_h
  X_g(n_h + 1 + i) = L_g - X_g(n_h + 1 - i)
end
n_e = 2·n_h
n_d = 2·n_e + 2
f_r = zeros(n_d - 4, 1)
for a = 1:n_d - 4
  f_r(a) = a + 2
end
u = zeros(n_d, 1)
F = zeros(n_d, 1)
for m_e = 1:n_e
  l_e = X_g(m_e + 1) - X_g(m_e)
  f_l = w_n·[l_e/2, l_e^2/12, l_e/2, -l_e^2/12]
  for a = 1:4
    F(2·m_e - 2 + a) = F(2·m_e - 2 + a) + f_l(a)
  end
end
T_n = zeros(9, 4)
for i_t = 1:9
  K_t = zeros(n_d, n_d)
  Q_f = zeros(n_d, 1)
  for m_e = 1:n_e
    l_e = X_g(m_e + 1) - X_g(m_e)
    for g = 1:3
      z_g = (g_x(g) + 1)/2
      B_v = [(-6 + 12·z_g)/l_e^2, (-4 + 6·z_g)/l_e, (6 - 12·z_g)/l_e^2, (-2 + 6·z_g)/l_e]
      q_g = 0
      for a = 1:4
        q_g = q_g + B_v(a)·u(2·m_e - 2 + a)
      end
      M_g = E_g·q_g/(1 + E_g·abs(q_g)/M_p)
      t_g = E_g/(1 + E_g·abs(q_g)/M_p)^2
      for a = 1:4
        Q_f(2·m_e - 2 + a) = Q_f(2·m_e - 2 + a) + B_v(a)·M_g·g_w(g)·l_e/2
        for c = 1:4
          K_t(2·m_e - 2 + a, 2·m_e - 2 + c) = K_t(2·m_e - 2 + a, 2·m_e - 2 + c) + t_g·B_v(a)·B_v(c)·g_w(g)·l_e/2
        end
      end
    end
  end
  R = F - Q_f
  r_n = 0
  for a = 1:n_d - 4
    r_n = r_n + R(a + 2)^2
  end
  T_n(i_t, 1) = i_t - 1
  T_n(i_t, 2) = 1000·u(n_e + 1)
  T_n(i_t, 3) = Q_f(2) - F(2)
  T_n(i_t, 4) = sqrt(r_n)
  d_u = lsolve(K_t(f_r, f_r), R(f_r))
  for a = 1:n_d - 4
    u(a + 2) = u(a + 2) + d_u(a)
  end
end
#show
#: **Newton paso a paso** con w = 120 kN/m: cada fila es una vuelta. La flecha avanza, el momento del apoyo se acomoda y **lo que falta** (el residuo) baja hasta cero, igual que en la barra:
#tabla("paso:0","flecha del centro [mm]:4","M apoyo [kN·m]:4","falta |R| [kN]:8")(T_n(1:9, 1); T_n(1:9, 2); T_n(1:9, 3); T_n(1:9, 4))
d_n = T_n(9, 2) 'flecha del centro con Newton (20 elementos) [mm]
M_n = T_n(9, 3) 'momento del apoyo con Newton [kN·m]
#: El **paso 1** usa la rigidez sin fisurar: su flecha (3 mm) es la del cálculo **lineal**, que pondría −360 kN·m (wL²/12) en el apoyo. Pero con esa curvatura la sección real solo da 360/(1 + 360/400) = 189 kN·m: falta equilibrio (el residuo) y Newton sigue. Al final el apoyo **suelta** momento (de −360 a −332) y el centro lo **recoge** (de 180 a 208). La flecha real es **2.4 veces** la lineal. (La columna del momento del apoyo son las fuerzas internas de cada vuelta: solo vale como momento cuando el residuo ya es cero.)

### La solución exacta (para comparar)
#: Por simetría basta una condición: el giro de los empotramientos es cero, o sea **∫₀ᴸ κ(x) dx = 0**, con M(x) = M_a + w·x·(L − x)/2 (M_a = momento del apoyo, la incógnita). Se busca M_a por bisección con la curvatura exacta κ = M/(EI·(1 − |M|/M_u)) y la flecha del centro sale de integrar κ·(L/2 − x). La integral tiene una singularidad logarítmica cuando el apoyo llega a M_u, por eso se integra con tramos cada vez más cortos hacia el apoyo (40 en progresión geométrica + 30 iguales, 3 puntos de Gauss en cada uno).
#hide
e_d = zeros(71, 1)
for k = 1:40
  e_d(k + 1) = (L_g/2)·0.1·10^(-14 + 14·(k - 1)/39)
end
for k = 1:30
  e_d(41 + k) = (L_g/2)·(0.1 + 0.9·k/30)
end
l_s = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.95, 0.97, 0.99]
C_x = zeros(13, 2)
X_a = zeros(13, 3)
for j = 2:13
  w_j = l_s(j)·w_k
  s_a = -15
  s_b = log10(min(M_p, 2·M_p - w_j·L_g^2/8)) - 0.000000000001
  for i_b = 1:50
    s_m = (s_a + s_b)/2
    M_0 = -M_p + 10^s_m
    g_i = 0
    for k = 1:70
      for g = 1:3
        x_k = e_d(k) + (e_d(k + 1) - e_d(k))·(g_x(g) + 1)/2
        M_x = M_0 + w_j·x_k·(L_g - x_k)/2
        g_i = g_i + g_w(g)·(e_d(k + 1) - e_d(k))/2·M_x/(E_g·(1 - abs(M_x)/M_p))
      end
    end
    if g_i < 0
      s_a = s_m
    else
      s_b = s_m
    end
  end
  M_0 = -M_p + 10^((s_a + s_b)/2)
  v_i = 0
  for k = 1:70
    for g = 1:3
      x_k = e_d(k) + (e_d(k + 1) - e_d(k))·(g_x(g) + 1)/2
      M_x = M_0 + w_j·x_k·(L_g - x_k)/2
      v_i = v_i - g_w(g)·(e_d(k + 1) - e_d(k))/2·M_x/(E_g·(1 - abs(M_x)/M_p))·(L_g/2 - x_k)
    end
  end
  C_x(j, 1) = 1000·v_i
  C_x(j, 2) = w_j
  X_a(j, 1) = w_j
  X_a(j, 2) = M_0
  X_a(j, 3) = M_0 + w_j·L_g^2/8
end
#show
d_x = C_x(7, 1) 'flecha EXACTA del centro con w = 0.6·wu = 106.67 kN/m [mm]

### Curva carga–flecha: lineal, exacta y Newton con dos mallas
#: Se aplica la carga en 10 escalones (0.1·w_u … 0.9·w_u y 0.95·w_u) y en cada uno Newton parte de la solución del anterior (10 vueltas). Dos mallas: **16 elementos iguales** y los **20 graduados** de arriba.
#hide
C_l = zeros(11, 2)
C_w = zeros(11, 2)
for j = 1:11
  C_l(j, 1) = 1000·w_k·(j - 1)/10·L_g^4/(384·E_g)
  C_l(j, 2) = w_k·(j - 1)/10
  C_w(j, 1) = 15.5·(j - 1)
  C_w(j, 2) = w_k
end
C_u = zeros(11, 2)
C_m = zeros(11, 2)
G_a = zeros(11, 3)
U_a = zeros(11, 3)
for c_s = 1:2
  n_e = 16
  if c_s == 2
    n_e = 2·n_h
  end
  n_d = 2·n_e + 2
  X_c = zeros(n_e + 1, 1)
  for i = 1:n_e + 1
    X_c(i) = L_g·(i - 1)/n_e
    if c_s == 2
      X_c(i) = X_g(i)
    end
  end
  f_r = zeros(n_d - 4, 1)
  for a = 1:n_d - 4
    f_r(a) = a + 2
  end
  u = zeros(n_d, 1)
  for j = 2:11
    w_j = l_s(j)·w_k
    F = zeros(n_d, 1)
    for m_e = 1:n_e
      l_e = X_c(m_e + 1) - X_c(m_e)
      f_l = w_j·[l_e/2, l_e^2/12, l_e/2, -l_e^2/12]
      for a = 1:4
        F(2·m_e - 2 + a) = F(2·m_e - 2 + a) + f_l(a)
      end
    end
    for i_t = 1:10
      K_t = zeros(n_d, n_d)
      Q_f = zeros(n_d, 1)
      for m_e = 1:n_e
        l_e = X_c(m_e + 1) - X_c(m_e)
        for g = 1:3
          z_g = (g_x(g) + 1)/2
          B_v = [(-6 + 12·z_g)/l_e^2, (-4 + 6·z_g)/l_e, (6 - 12·z_g)/l_e^2, (-2 + 6·z_g)/l_e]
          q_g = 0
          for a = 1:4
            q_g = q_g + B_v(a)·u(2·m_e - 2 + a)
          end
          M_g = E_g·q_g/(1 + E_g·abs(q_g)/M_p)
          t_g = E_g/(1 + E_g·abs(q_g)/M_p)^2
          for a = 1:4
            Q_f(2·m_e - 2 + a) = Q_f(2·m_e - 2 + a) + B_v(a)·M_g·g_w(g)·l_e/2
            for c = 1:4
              K_t(2·m_e - 2 + a, 2·m_e - 2 + c) = K_t(2·m_e - 2 + a, 2·m_e - 2 + c) + t_g·B_v(a)·B_v(c)·g_w(g)·l_e/2
            end
          end
        end
      end
      R = F - Q_f
      d_u = lsolve(K_t(f_r, f_r), R(f_r))
      for a = 1:n_d - 4
        u(a + 2) = u(a + 2) + d_u(a)
      end
    end
    if c_s == 1
      C_u(j, 1) = 1000·u(n_e + 1)
      C_u(j, 2) = w_j
      U_a(j, 1) = w_j
      U_a(j, 2) = Q_f(2) - F(2)
      U_a(j, 3) = Q_f(2) - F(2) + w_j·L_g^2/8
    else
      C_m(j, 1) = 1000·u(n_e + 1)
      C_m(j, 2) = w_j
      G_a(j, 1) = w_j
      G_a(j, 2) = Q_f(2) - F(2)
      G_a(j, 3) = Q_f(2) - F(2) + w_j·L_g^2/8
    end
  end
end
o_p = zeros(11, 1)
o_x = zeros(11, 1)
o_u = zeros(11, 1)
o_m = zeros(11, 1)
o_a = zeros(11, 1)
o_g = zeros(11, 1)
for j = 1:11
  o_p(j) = l_s(j)
  o_x(j) = C_x(j, 1)
  o_u(j) = C_u(j, 1)
  o_m(j) = C_m(j, 1)
  o_a(j) = X_a(j, 2)
  o_g(j) = G_a(j, 2)
end
#show
#dibujo("La viga con su carga y la flecha del centro δ (exagerada)", ud = m, escala = auto, alto = 60)
#  empotramiento(0, -0.5, 0, 0.5, 1)
#  empotramiento(6, -0.5, 6, 0.5, -1)
#  carga(0, 0.05, 6, 0.05, 0.5, 0.5, "w", "azul", n = 13)
#  curva(0, 6, -0.6·(1 - cos(2·pi·x/6))/2, "gruesa rojo")
#  linea(0, 0, 6, 0, "fina")
#  cota(3.3, 0, 3.3, -0.6, 0, "δ")
#fin
#: **Pasa el cursor:** al principio todas las curvas siguen la recta lineal; luego la viga se ablanda y la curva se **acuesta** hacia w_u = 177.78 kN/m (la línea horizontal): cerca del colapso la flecha se dispara. La malla de 16 elementos iguales se queda **rígida** cerca del colapso (no alcanza a seguir la rótula del apoyo); la graduada se pega a la exacta.
#fplot(lineal = C_l, exacta = C_x, Newton_16_iguales = C_u, Newton_20_graduados = C_m, colapso_w_u = C_w, [0 260])
#: (eje horizontal: flecha del centro en mm; vertical: carga w en kN/m.)
#tabla("w / w_u:2","exacta [mm]:4","Newton 16 iguales [mm]:4","Newton 20 graduados [mm]:4","M apoyo exacto [kN·m]:4","M apoyo Newton 20 [kN·m]:4")(o_p; o_x; o_u; o_m; o_a; o_g)
#: Con 0.97·w_u la flecha exacta es 71 mm y con 0.99·w_u, 152 mm: la curva no cruza nunca w_u, **tiende** a ella (la hipérbola solo llega a M_u con curvatura infinita).

### La redistribución del momento
#dibujo("Diagrama de momentos lineal: −wL²/12 en los apoyos y +wL²/24 al centro", ud = m, escala = auto, alto = 60)
#  empotramiento(0, -0.5, 0, 0.5, 1)
#  empotramiento(6, -0.5, 6, 0.5, -1)
#  linea(0, 0, 6, 0, "gruesa")
#  curva(0, 6, -0.25·(x·(6 - x)/2 - 3), "relleno azul", base = 0)
#  texto(0.9, 0.9, "−wL²/12", 2.4, "c")
#  texto(5.1, 0.9, "−wL²/12", 2.4, "c")
#  texto(3, -0.7, "+wL²/24", 2.4, "c")
#fin
#: El cálculo **lineal** dice que el apoyo lleva siempre el doble que el centro (rectas wL²/12 y wL²/24). En la viga **real** el apoyo se ablanda primero: su momento crece cada vez menos y se **pega a M_u**, y lo que falta (el total siempre es wL²/8, eso es equilibrio) lo toma el **centro**, que sube hasta M_u. Con w_u las dos llegan a M_u: es el mecanismo de 3 rótulas. Pasa el cursor:
#hide
R_1 = zeros(11, 2)
R_2 = zeros(11, 2)
R_u = zeros(11, 2)
for j = 1:11
  R_1(j, 1) = w_k·(j - 1)/10
  R_1(j, 2) = R_1(j, 1)·L_g^2/12
  R_2(j, 1) = R_1(j, 1)
  R_2(j, 2) = R_1(j, 1)·L_g^2/24
  R_u(j, 1) = R_1(j, 1)
  R_u(j, 2) = M_p
end
R_a = zeros(13, 2)
R_c = zeros(13, 2)
for j = 1:13
  R_a(j, 1) = X_a(j, 1)
  R_a(j, 2) = -X_a(j, 2)
  R_c(j, 1) = X_a(j, 1)
  R_c(j, 2) = X_a(j, 3)
end
N_a = zeros(11, 2)
N_c = zeros(11, 2)
for j = 1:11
  N_a(j, 1) = G_a(j, 1)
  N_a(j, 2) = -G_a(j, 2)
  N_c(j, 1) = G_a(j, 1)
  N_c(j, 2) = G_a(j, 3)
end
#show
#fplot(apoyo_lineal_wL2_12 = R_1, centro_lineal_wL2_24 = R_2, apoyo_exacto = R_a, centro_exacto = R_c, apoyo_Newton = N_a, centro_Newton = N_c, M_u = R_u, [0 300])
#: (eje horizontal: carga w en kN/m; vertical: momento en kN·m, el del apoyo en valor absoluto.)
#: **El diagrama de momentos** con w = 0.9·w_u = 160 kN/m: el lineal pasaría M_u en el apoyo (480 > 400); el real se queda en 398 y el centro sube de 240 a 322:
#hide
D_l = zeros(31, 2)
D_r = zeros(31, 2)
D_s = zeros(13, 2)
D_i = zeros(13, 2)
for i = 1:13
  D_s(i, 1) = L_g·(i - 1)/12
  D_s(i, 2) = M_p
  D_i(i, 1) = D_s(i, 1)
  D_i(i, 2) = -M_p
end
for i = 1:31
  x_i = L_g·(i - 1)/30
  D_l(i, 1) = x_i
  D_l(i, 2) = -160·L_g^2/12 + 160·x_i·(L_g - x_i)/2
  D_r(i, 1) = x_i
  D_r(i, 2) = X_a(10, 2) + 160·x_i·(L_g - x_i)/2
end
#show
#fplot(lineal = D_l, real_no_lineal = D_r, mas_M_u = D_s, menos_M_u = D_i, [0 8.5])
#: (eje horizontal: x a lo largo de la viga en m; vertical: M en kN·m, positivo = tracción abajo.)
M_9 = X_a(10, 2) 'momento del apoyo exacto con 0.9·wu [kN·m]
M_c = X_a(10, 3) 'momento del centro exacto con 0.9·wu [kN·m]

## 4 · El momento y la rigidez en 3D a lo largo de la viga y de la carga
#: Para dibujar M(x, w) se necesita el momento del apoyo para **cualquier** w. Se ajusta un polinomio de grado 4 en t = w/w_u a los 10 valores exactos (de 0 a 0.9·w_u) por mínimos cuadrados:
#hide
V_f = zeros(10, 5)
y_f = zeros(10, 1)
for j = 1:10
  for c = 1:5
    V_f(j, c) = l_s(j)^(c - 1)
  end
  y_f(j) = -X_a(j, 2)
end
c_f = lsolve(transpose(V_f)·V_f, transpose(V_f)·y_f)
c_0 = c_f(1)
c_1 = c_f(2)
c_2 = c_f(3)
c_3 = c_f(4)
c_4 = c_f(5)
e_f = 0
for j = 1:10
  e_f = max(e_f, abs(V_f(j, 1)·c_0 + V_f(j, 2)·c_1 + V_f(j, 3)·c_2 + V_f(j, 4)·c_3 + V_f(j, 5)·c_4 - y_f(j)))
end
#show
e_f 'error máximo del ajuste en los puntos [kN·m]
#: Con eso, el momento en cada punto x de la viga (m) y para cada carga y = w (kN/m) es M = −M_a(w) + w·x·(L − x)/2, y la **rigidez secante relativa** EI_s/EI = 1 − |M|/M_u (1 = sana, 0 = rótula):
m_a(y) = c_0 + c_1·y/w_k + c_2·(y/w_k)^2 + c_3·(y/w_k)^3 + c_4·(y/w_k)^4
m_s(x, y) = x·(L_g - x)·y/2 - m_a(y)
r_s(x, y) = 1 - sqrt(m_s(x, y)^2)/M_p
#dibujo("La viga a lo largo de x (de 0 a 6 m): los mapas van debajo, con la carga w en vertical", ud = m, escala = auto, alto = 50)
#  empotramiento(0, -0.4, 0, 0.4, 1)
#  empotramiento(6, -0.4, 6, 0.4, -1)
#  rect(0, -0.2, 6, 0.2, "gruesa")
#  carga(0, 0.2, 6, 0.2, 0.4, 0.4, "w", "azul", n = 13)
#fin
#: **Momento M(x, w)** [kN·m]: negativo (azul) en los empotramientos, positivo al centro. Pasa el cursor:
#map(m_s(x, y), [0 6], [0 160])
#surf(m_s(x, y), [0 6], [0 160])
#: **Rigidez secante EI_s/EI**: las dos zonas azules (rigidez que se va a cero) de los empotramientos aparecen primero; la del centro llega después. Arrastra para girar:
#map(r_s(x, y), [0 6], [0 160])
#surf(r_s(x, y), [0 6], [0 160])

## 5 · Lo que enseña la viga empotrada
#: (1) **Lineal:** dos elementos de Hermite y las cargas por trabajo virtual dan la solución exacta (wL⁴/384EI, −wL²/12, +wL²/24). (2) **No lineal:** Newton es el mismo de la barra, con matrices: residuo → K_T → K_T·Δu = R → repetir; con la rigidez del concreto fisurado la flecha es varias veces la lineal. (3) **Hiperestática = redistribución:** el apoyo se ablanda primero y el centro toma el momento que suelta; el colapso llega con **16M_u/L²**, un tercio más que el 12M_u/L² del cálculo elástico. (4) **La malla importa** cerca del colapso: la rótula concentra la curvatura y pide elementos cortos donde se forma.
