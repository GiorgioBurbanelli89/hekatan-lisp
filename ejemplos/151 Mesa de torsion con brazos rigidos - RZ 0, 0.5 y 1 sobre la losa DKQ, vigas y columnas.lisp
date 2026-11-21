# Mesa de torsión con brazos rígidos: lo que cambia cuando las barras se rigidizan en los nudos
#numerico

#: **Qué hace esta hoja.** Es la **mesa de torsión del ejemplo 83** (losa 6 × 6 m de 10 cm sobre 4 vigas V30×50 y 4 columnas C40×40 de 4 m, carga viva 0.5 tonf/m²) resuelta **tres veces**: con los brazos rígidos de SAP2000 y ETABS al **0 %, 50 % y 100 %** (factor **RZ** = 0, 0.5 y 1). Todo lo demás es idéntico: losa Q6 + DKQ, barras de Timoshenko y apoyos articulados.
#: **Por qué importa.** Las barras del modelo van de **eje a eje**, pero la parte de la viga que entra en la columna (y la de la columna que entra en la viga) no se dobla: está dentro de un bloque de hormigón. Ese tramo es el **brazo**. Con RZ = 0 existe pero no rigidiza nada (es lo que usa el ejemplo 83 y lo que da ETABS por defecto); con RZ = 1 todo el brazo es rígido y la barra solo se dobla en su **longitud libre**. La deducción de las reglas de CSI está en el ejemplo 111; aquí se ve **cuánto cambia la mesa**.
#: **La regla automática de ETABS** (*Automatic from Connectivity*): la **viga** lleva en cada extremo que toca una columna un brazo de **la mitad del lado de la columna** (0.40/2 = 0.20 m); la **columna** lleva en su extremo superior un brazo de **todo el canto de la viga** (0.50 m). Flexión y cortante usan la longitud libre L_{f} = L − l_{I} − l_{J}; el axil y la torsión siguen con la longitud entera: K = Tᵀ·k(L_{f})·T.
#: **Unidades:** kN y m al calcular; resultados en tonf y tonf·m dividiendo por g = 9.80665. **Qué se compara:** flecha central, momentos de la losa, fuerzas en la columna y torsión de la viga. Con RZ = 0 los números son los del 83 (que coinciden con ETABS a 6 decimales en la losa): es la comprobación de que el programa de esta hoja es el mismo.

## A · El brazo, en símbolos

#: Un extremo de la barra no se mueve como el nudo: el punto donde empieza el tramo flexible está a una distancia l del nudo, **sobre un sólido que gira con él**. En el plano de flexión, si el nudo baja v y gira θ, ese punto baja **v + l·θ** (la palanca) y gira lo mismo. En el otro extremo el brazo va hacia atrás: v − l·θ. En matriz, con los grados (v_{I}, θ_{I}, v_{J}, θ_{J}):
T_b = Simplify{[1, l_i, 0, 0; 0, 1, 0, 0; 0, 0, 1, -l_j; 0, 0, 0, 1]}
#: La energía del tramo flexible, ½·u′ᵀ·k(L_{f})·u′ con u′ = T·u, se lee desde los nudos como ½·uᵀ·(Tᵀ·k·T)·u. Con la barra de Euler-Bernoulli de largo libre L_{f}:
k_f = Simplify{E*I/L_f^3*[12, 6*L_f, -12, 6*L_f; 6*L_f, 4*L_f^2, -6*L_f, 2*L_f^2; -12, -6*L_f, 12, -6*L_f; 6*L_f, 2*L_f^2, -6*L_f, 4*L_f^2]}
K_br = Simplify{transpose([1, l_i, 0, 0; 0, 1, 0, 0; 0, 0, 1, -l_j; 0, 0, 0, 1])*(E*I/L_f^3*[12, 6*L_f, -12, 6*L_f; 6*L_f, 4*L_f^2, -6*L_f, 2*L_f^2; -12, -6*L_f, 12, -6*L_f; 6*L_f, 2*L_f^2, -6*L_f, 4*L_f^2])*[1, l_i, 0, 0; 0, 1, 0, 0; 0, 0, 1, -l_j; 0, 0, 0, 1]}
#: Lectura de la segunda fila: la rigidez a la flecha v_{I} no cambia (12EI/L_{f}³), pero la de **giro crece**: 4EI/L_{f} pasa a 4EI/L_{f} + 12·EI·l_{I}²/L_{f}³ + 12·EI·l_{I}/L_{f}². El brazo es una palanca que hace al nudo más rígido. En 3D son las mismas relaciones en cada plano de flexión: v′ = v + l·θz y w′ = w − l·θy en el extremo I, v′ = v − l·θz y w′ = w + l·θy en el J; **el axil y la torsión no se tocan**.

## B · Resultados numéricos

### B.1 · Datos
L_x = 6 'luz de la losa en x y en y (m)
H_c = 4 'altura de las columnas (m)
t = 0.1 'espesor de la losa (m)
E = 24.85e6 'módulo de elasticidad (kN/m²)
ν = 0.2 'coeficiente de Poisson
G_c = E/(2·(1 + ν)) 'módulo de corte (kN/m²)
g_0 = 9.80665 'kN por tonf
b_c = 0.4 'columna: ancho (m)
h_c = 0.4 'columna: peralte (m)
b_v = 0.3 'viga: ancho (m)
h_v = 0.5 'viga: peralte (m)
o_f = h_v 'brazo rígido en el tope de la columna: el momento se reporta en la cara de la viga (m)
off_v = b_c/2 'brazo de la viga en el extremo que toca una columna: medio lado de la columna (m)
off_c = h_v 'brazo de la columna en su extremo superior: todo el canto de la viga (m)
#: **Secciones.** J con la fórmula de Saint-Venant para un rectángulo, con el CUBO del lado corto: J = β·a·b³, β = 1/3 − 0.21·(b/a)·(1 − (b/a)⁴/12).
A_c = b_c·h_c
I_yc = h_c·b_c^3/12
I_zc = b_c·h_c^3/12
J_c = stv(b_c, h_c)
A_v = b_v·h_v
I_yv = b_v·h_v^3/12 'inercia fuerte de la viga (flexión vertical)
I_zv = h_v·b_v^3/12
J_v = stv(b_v, h_v)

### B.2 · Malla
#: 5 × 5 elementos de losa de 1.2 m (el automallado de ETABS a ≤ 1.25 m). Nudos: 4 en la base de las columnas y 36 en la losa, a la altura H.
n_e = 5 'elementos por lado
n_1 = n_e + 1 'nudos por lado
d = L_x/n_e 'lado del elemento (m)
n_j = 4 + n_1^2 'nudos
n_d = 6·n_j 'grados de libertad
#: El nudo de losa de la columna i y la fila j de la malla (i, j = 0 … 5):
p(i, j) = 5 + j·n_1 + i
#hide
X_n = zeros(n_j, 3)
X_n(2, 1) = L_x
X_n(3, 1) = L_x
X_n(3, 2) = L_x
X_n(4, 2) = L_x
for j = 0:n_e
  for i = 0:n_e
    X_n(p(i, j), 1) = i·d
    X_n(p(i, j), 2) = j·d
    X_n(p(i, j), 3) = H_c
  end
end
e_s = zeros(n_e^2, 4)
for j = 0:n_e - 1
  for i = 0:n_e - 1
    k = j·n_e + i + 1
    e_s(k, 1) = p(i, j)
    e_s(k, 2) = p(i + 1, j)
    e_s(k, 3) = p(i + 1, j + 1)
    e_s(k, 4) = p(i, j + 1)
  end
end
c_e = [1, p(0, 0); 2, p(n_e, 0); 3, p(n_e, n_e); 4, p(0, n_e)]
b_e = zeros(4·n_e, 2)
for i = 0:n_e - 1
  b_e(i + 1, 1) = p(i, 0)
  b_e(i + 1, 2) = p(i + 1, 0)
  b_e(n_e + i + 1, 1) = p(n_e, i)
  b_e(n_e + i + 1, 2) = p(n_e, i + 1)
  b_e(2·n_e + i + 1, 1) = p(i, n_e)
  b_e(2·n_e + i + 1, 2) = p(i + 1, n_e)
  b_e(3·n_e + i + 1, 1) = p(0, i)
  b_e(3·n_e + i + 1, 2) = p(0, i + 1)
end
x_j = zeros(n_1^2, 1)
y_j = zeros(n_1^2, 1)
for k = 1:n_1^2
  x_j(k) = X_n(k + 4, 1)
  y_j(k) = X_n(k + 4, 2)
end
e_j = e_s - 4
s_j = [1; n_1; n_1^2; n_1^2 - n_e]
#show
#: Planta de la losa: 25 elementos; las columnas están en las 4 esquinas y las vigas corren por el borde.
#malla(x_j, y_j, e_j, s_j)
n_s = n_e^2 'elementos de losa
n_c = 4 'columnas
n_b = 4·n_e 'tramos de viga (cada viga se parte en los nudos de la losa)


### B.3 · Matrices de los elementos
#: Son las fórmulas de la parte A con los datos de la mesa. No se vuelven a escribir: se comprueba un término de cada una contra su expresión algebraica.
a_e = d/2 'medio lado del elemento de losa (m)
#hide
K_m = memb_q6(E, ν, t, a_e)
D_b = E·t^3/(12·(1 - ν^2))·[1, ν, 0; ν, 1, 0; 0, 0, (1 - ν)/2]
K_b = dkq_K(D_b, d)
P_d = zeros(12, 12)
for k = 1:4
  P_d(3·k - 2, 3·k - 2) = 1
  P_d(3·k - 1, 3·k - 1) = -1
  P_d(3·k, 3·k) = -1
end
K_p = P_d·K_b·P_d
s_m = 0
for k = 1:8
  s_m = s_m + K_m(k, k)
end
#show
#: **Membrana Q6** (A.4):
K_m11 = K_m(1, 1) 'del programa (kN/m)
K_m11f = E·t·(11 - 3·ν - 2·ν^2)/(24·(1 - ν^2)) 'fórmula K_Q6(1, 1)
#: **Placa DKQ** (A.5):
D_p = E·t^3/(12·(1 - ν^2)) 'rigidez a flexión (kN·m)
K_b11 = K_b(1, 1) 'del programa (kN/m)
K_b11f = 10·D_p/d^2 'fórmula K_DKQ(1, 1), Gauss 2 × 2
K_b11e = (51 - ν)·D_p/(5·d^2) 'con la integral exacta: el DKQ NO la usa
#: **Giro en el plano** (A.6):
k_θ = s_m/(8·10^6) 'muelle de θz (kN·m/rad)
#hide
K_s = zeros(24, 24)
for a = 1:4
  for b = 1:4
    for r = 1:2
      for c = 1:2
        K_s(6·(a - 1) + r, 6·(b - 1) + c) = K_m(2·(a - 1) + r, 2·(b - 1) + c)
      end
    end
    for r = 1:3
      for c = 1:3
        K_s(6·(a - 1) + 2 + r, 6·(b - 1) + 2 + c) = K_p(3·(a - 1) + r, 3·(b - 1) + c)
      end
    end
  end
  K_s(6·a, 6·a) = k_θ
end

### B.4 · Ensamblaje, apoyos y carga viva
d_n(j) = 6·(j - 1) + (1:6)
#hide
n_r = n_c + n_b
e_f = zeros(n_r, 2)
for e = 1:n_r
  if e <= n_c
    e_f(e, 1) = c_e(e, 1)
    e_f(e, 2) = c_e(e, 2)
  else
    e_f(e, 1) = b_e(e - n_c, 1)
    e_f(e, 2) = b_e(e - n_c, 2)
  end
end
#: **Apoyos.** Base de las columnas articulada (ETABS: RESTRAINT "UX UY UZ"): se quitan u, v, w de los nudos 1 a 4; sus giros quedan libres.
#hide
l_f = zeros(n_d - 12, 1)
k = 0
for i = 1:n_d
  if i > 24 || mod(i - 1, 6) >= 3
    k = k + 1
    l_f(k) = i
  end
end
#show
n_q = k 'ecuaciones libres
#: **Live** (0.5 tonf/m²) en los nudos de la losa por área tributaria: d² en el interior, d²/2 en el borde, d²/4 en la esquina. Es la misma carga para los tres modelos.
q_L = 0.5·g_0 'Live: 0.5 tonf/m² (kN/m²)
#hide
F_L = zeros(n_d, 1)
for j = 0:n_e
  for i = 0:n_e
    f_a = 1
    if i == 0 || i == n_e
      f_a = f_a/2
    end
    if j == 0 || j == n_e
      f_a = f_a/2
    end
    F_L(6·(p(i, j) - 1) + 3) = -q_L·d^2·f_a
  end
end
s_3 = sqrt(3)
A_x = [1 + s_3/2, -0.5, 1 - s_3/2, -0.5; -0.5, 1 + s_3/2, -0.5, 1 - s_3/2; 1 - s_3/2, -0.5, 1 + s_3/2, -0.5; -0.5, 1 - s_3/2, -0.5, 1 + s_3/2]
#show

### B.5 · La barra con brazo: longitud libre y K = Tᵀ·k·T
#: La función `frame_Koff` es la barra de Timoshenko 12 × 12 del ejemplo 83 con las dos reglas de CSI: **flexión y cortante con L_{f}** y **axil y torsión con L**, y luego la transformación de los brazos T (que mueve v y w con la palanca de θz y θy). Se comprueba en la viga del borde, primer tramo (d = 1.2 m, brazo de 0.20 m en el lado de la columna):
l_ej = off_v 'brazo del primer tramo de la viga, RZ = 1 (m)
#hide
k_sin = frame_K(E, G_c, A_v, I_yv, I_zv, J_v, d)
k_con = frame_Koff(E, G_c, A_v, I_yv, I_zv, J_v, d, l_ej, 0)
#show
#: Flecha-flecha de la flexión vertical (término 3,3) y axil (1,1), sin y con brazo. El **axil no cambia**; la flexión **crece** porque el tramo flexible baja de 1.20 a 1.00 m y la rigidez va con 1/L_{f}³:
k_33_sin = k_sin(3, 3) 'flecha, sin brazo (kN/m)
k_33_con = k_con(3, 3) 'flecha, con brazo (kN/m)
k_11_sin = k_sin(1, 1) 'axil, sin brazo (kN/m)
k_11_con = k_con(1, 1) 'axil, con brazo (kN/m)
r_33 = k_33_con/k_33_sin 'cuántas veces crece la rigidez a flexión del tramo

### B.6 · Los tres modelos: RZ = 0, 0.5 y 1
#: Para cada RZ se vuelve a armar K (la losa es la misma; cambian las barras: columnas con brazo arriba y los dos tramos de viga que tocan cada columna), se resuelve **K·u = F** y se sacan los resultados. La losa se recupera con el DKQ (envolvente de los elementos que llegan a cada nudo, como la tabla de ETABS).
#hide
rz_l = [0, 0.5, 1]
S_tab = zeros(3, 9)
U_all = zeros(n_d, 3)
G_all = zeros(3·n_1, 3·n_1)
for kk = 1:3
  rz = rz_l(kk)
  K = zeros(n_d, n_d)
  for e = 1:n_s
    g = [d_n(e_s(e, 1)), d_n(e_s(e, 2)), d_n(e_s(e, 3)), d_n(e_s(e, 4))]
    K(g, g) = K(g, g) + K_s
  end
  Ke_k = zeros(12·n_r, 12)
  for e = 1:n_r
    g = [d_n(e_f(e, 1)), d_n(e_f(e, 2))]
    R_f = rot_frame(X_n(e_f(e, 1), :), X_n(e_f(e, 2), :))
    if e <= n_c
      ke = frame_Koff(E, G_c, A_c, I_yc, I_zc, J_c, H_c, 0, rz·off_c)
    else
      i_v = mod(e - n_c - 1, n_e)
      l_i = 0
      l_j = 0
      if i_v == 0
        l_i = rz·off_v
      end
      if i_v == n_e - 1
        l_j = rz·off_v
      end
      ke = frame_Koff(E, G_c, A_v, I_yv, I_zv, J_v, d, l_i, l_j)
    end
    Ke_k(12·(e - 1) + (1:12), :) = ke
    K(g, g) = K(g, g) + R_f'·ke·R_f
  end
  U_k = zeros(n_d, 1)
  U_k(l_f) = clsolve(K(l_f, l_f), F_L(l_f))
  U_all(:, kk) = U_k
  G_k = losa_M(U_k, e_s, P_d, D_b, d, n_e, A_x, g_0)
  G_all(:, n_1·(kk - 1) + (1:n_1)) = G_k
  g1 = [d_n(e_f(1, 1)), d_n(e_f(1, 2))]
  f_c = Ke_k(1:12, :)·rot_frame(X_n(e_f(1, 1), :), X_n(e_f(1, 2), :))·U_k(g1)/g_0
  b1 = n_c + 1
  g2 = [d_n(e_f(b1, 1)), d_n(e_f(b1, 2))]
  f_b = Ke_k(12·(b1 - 1) + (1:12), :)·rot_frame(X_n(e_f(b1, 1), :), X_n(e_f(b1, 2), :))·U_k(g2)/g_0
  S_tab(kk, 1) = rz
  S_tab(kk, 2) = -1000·U_k(6·(p(2, 2) - 1) + 3)
  S_tab(kk, 3) = max(abs(G_k(1:n_1, :)))
  S_tab(kk, 4) = max(abs(G_k(n_1 + 1:2·n_1, :)))
  S_tab(kk, 5) = max(abs(G_k(2·n_1 + 1:3·n_1, :)))
  S_tab(kk, 6) = abs(f_c(8))
  S_tab(kk, 7) = abs(f_c(12))
  S_tab(kk, 8) = abs(f_b(4))
  S_tab(kk, 9) = abs(f_b(5))
end
#show
#: **Tabla de resultados.** Columnas: RZ · flecha en el nudo (2.4, 2.4) en mm · máx. |Mxx|, |Myy| y |Mxy| de la losa (tonf·m/m) · cortante y momento en el extremo superior de la columna 1 (tonf, tonf·m) · torsión y momento del primer tramo de la viga del borde (tonf·m). Con RZ = 0 es el modelo del ejemplo 83.
S_tab
#hide
w_0 = round(S_tab(1, 2), 3)
w_1 = round(S_tab(3, 2), 3)
dw = round(100·(S_tab(3, 2)/S_tab(1, 2) - 1), 1)
dc = round(100·(S_tab(3, 6)/S_tab(1, 6) - 1), 1)
dt = round(100·(S_tab(3, 8)/S_tab(1, 8) - 1), 1)
dm = round(100·(S_tab(3, 3)/S_tab(1, 3) - 1), 1)
#show
#: **Lectura.** Con los brazos al 100 % la flecha central cambia **@{dw} %** (de @{w_0} a @{w_1} mm), el momento máximo Mxx de la losa **@{dm} %**, el cortante en la columna **@{dc} %** y la torsión de la viga del borde **@{dt} %**. Los nudos se vuelven más rígidos: las barras se doblan en menos longitud, atraen más fuerza y la losa se descarga o se carga según el caso. Por eso conviene saber qué brazos usa el modelo de referencia antes de comparar dos programas.

### B.7 · Mapas de la losa con RZ = 1 y su diferencia con RZ = 0
#hide
W_a = zeros(n_1, n_1)
M_a = zeros(n_1, n_1)
M_d = zeros(n_1, n_1)
for i = 0:n_e
  for j = 0:n_e
    W_a(i + 1, j + 1) = -1000·U_all(6·(p(i, j) - 1) + 3, 3)
    M_a(i + 1, j + 1) = G_all(i + 1, 2·n_1 + j + 1)
    M_d(i + 1, j + 1) = G_all(i + 1, 2·n_1 + j + 1) - G_all(i + 1, j + 1)
  end
end
#show
#: **Flecha w** (mm, hacia abajo) con RZ = 1:
transpose(W_a)
w_z(x, y) = bil(W_a, x, y, d, n_e)
#map(w_z(x, y), [0 L_x], [0 L_x])
#: **Mxx** (tonf·m/m) con RZ = 1:
transpose(M_a)
m_x(x, y) = bil(M_a, x, y, d, n_e)
#map(m_x(x, y), [0 L_x], [0 L_x])
#: **Diferencia de Mxx** entre RZ = 1 y RZ = 0: dónde se mueven los momentos al rigidizar los nudos.
transpose(M_d)
d_x(x, y) = bil(M_d, x, y, d, n_e)
#map(d_x(x, y), [0 L_x], [0 L_x])
#: **Qué sigue:** los brazos reales de ETABS para la mesa se asignan con *Assign → Frame → End Length Offsets* y el factor RZ; Hekatan Struct los lee igual (`endoffset`, `rigidzone`). La carga de los vanos con brazo y la masa dentro del brazo, que aquí no intervienen (solo Live), están en el ejemplo 111.

#hide
function G = losa_M(U, es, Pd, Db, d, ne, Ax, g0)
  % recovery DKQ: momentos en los 4 puntos de Gauss, extrapolados a los nudos, envolvente nodal.
  % Devuelve [Mxx; Myy; Mxy] apiladas, cada una de (ne+1) × (ne+1), en tonf·m/m
  n1 = ne + 1
  G = zeros(3·n1, n1)
  s3 = sqrt(3)
  xg = [-1, 1, 1, -1]/s3
  yg = [-1, -1, 1, 1]/s3
  oi = [0, 1, 1, 0]
  oj = [0, 0, 1, 1]
  for e = 1:ne^2
    ue = zeros(12, 1)
    for k = 1:4
      jd = 6·(es(e, k) - 1)
      ue(3·k - 2) = U(jd + 3)
      ue(3·k - 1) = U(jd + 4)
      ue(3·k) = U(jd + 5)
    end
    ud = Pd·ue
    Mg = zeros(3, 4)
    for k = 1:4
      Mg(:, k) = Db·dkq_B(xg(k), yg(k), d)·ud
    end
    Mn = Ax·transpose(Mg)/g0
    i0 = mod(e - 1, ne)
    j0 = floor((e - 1)/ne)
    for k = 1:4
      ii = i0 + oi(k) + 1
      jj = j0 + oj(k) + 1
      for c = 0:2
        if abs(Mn(k, c + 1)) > abs(G(c·n1 + ii, jj))
          G(c·n1 + ii, jj) = Mn(k, c + 1)
        end
      end
    end
  end
end

function f = barras_F(U, X, ef, kc, kv, nc, Q, g0)
  % fuerzas locales de cada barra: k·Rot·u − cargas de empotramiento, en tonf y tonf·m
  n = n_rows(ef)
  f = zeros(n, 12)
  for e = 1:n
    a = ef(e, 1)
    b = ef(e, 2)
    g = [6·(a - 1) + (1:6), 6·(b - 1) + (1:6)]
    R = rot_frame(X(a, :), X(b, :))
    if e <= nc
      fe = kc·R·U(g) - Q(e, :)
    else
      fe = kv·R·U(g) - Q(e, :)
    end
    f(e, :) = transpose(fe)/g0
  end
end

function r = resumen(f, G, U, F, K, nc, n1, jc, of, w)
  % las magnitudes que reporta ETABS: w central, máximos de la losa, columna 1 y viga del borde y = 0
  r = zeros(12, 1)
  r(1) = 1000·U(6·(jc - 1) + 3)
  r(2) = max(abs(G(1:n1, :)))
  r(3) = max(abs(G(2·n1 + 1:3·n1, :)))
  r(4) = abs(f(1, 1))
  r(5) = abs(f(1, 8))
  r(6) = abs(f(1, 12)) - r(5)·of
  b = nc + 1
  r(7) = abs(f(b, 3))
  r(8) = abs(f(b, 4))
  r(9) = f(b, 5) + f(b, 3)·0.2
  r(10) = f(b + 2, 5) + f(b + 2, 3)·0.8 - w·0.8^2/2
  r(11) = abs(f(b, 1))
  s = 0
  for k = [3, 9, 15, 21]
    s = s + K(k, :)·U - F(k)
  end
  r(12) = s/9.80665
end
function z = bil(Gr, x, y, d, n)
  % interpolación bilineal de la rejilla de nudos (funciones de forma del Q4)
  i = min(max(floor(x/d), 0), n - 1)
  j = min(max(floor(y/d), 0), n - 1)
  r = x/d - i
  s = y/d - j
  z = (1 - r)·(1 - s)·Gr(i + 1, j + 1) + r·(1 - s)·Gr(i + 2, j + 1) + r·s·Gr(i + 2, j + 2) + (1 - r)·s·Gr(i + 1, j + 2)
end

function r = stv(b, h)
  % J de Saint-Venant de un rectángulo (Roark): cubo del lado CORTO
  a = max(b, h)
  s = min(b, h)
  z = s/a
  r = (1/3 - 0.21·z·(1 - z^4/12))·a·s^3
end

function K = memb_q6(E, nu, t, a)
  % membrana Q6 de modos incompatibles, rectángulo de medio lado a (shell_thin.py, _membrane_k_q6)
  c = E/(1 - nu^2)
  Em = c·[1, nu, 0; nu, 1, 0; 0, 0, (1 - nu)/2]
  gp = [-1, 1]/sqrt(3)
  Kuu = zeros(8, 8)
  Kua = zeros(8, 4)
  Kaa = zeros(4, 4)
  for ix = 1:2
    for iy = 1:2
      xi = gp(ix)
      eta = gp(iy)
      dNx = [-(1 - eta), 1 - eta, 1 + eta, -(1 + eta)]/(4·a)
      dNy = [-(1 - xi), -(1 + xi), 1 + xi, 1 - xi]/(4·a)
      B = zeros(3, 8)
      for i = 1:4
        B(1, 2·i - 1) = dNx(i)
        B(2, 2·i) = dNy(i)
        B(3, 2·i - 1) = dNy(i)
        B(3, 2·i) = dNx(i)
      end
      Gi = zeros(3, 4)
      Gi(1, 1) = -2·xi/a
      Gi(3, 2) = -2·eta/a
      Gi(3, 3) = -2·xi/a
      Gi(2, 4) = -2·eta/a
      wd = t·a^2
      Kuu = Kuu + wd·transpose(B)·Em·B
      Kua = Kua + wd·transpose(B)·Em·Gi
      Kaa = Kaa + wd·transpose(Gi)·Em·Gi
    end
  end
  K = Kuu - Kua·inv(Kaa)·transpose(Kua)
end

function B = dkq_B(xi, eta, d)
  % B 3×12 del DKQ rectangular (python_dkq.py, _dkq_Bmatrix), lado d, orden (w, θx, θy)
  rw1 = 3·xi·(1 - eta)/d^2
  rt1 = (1 - eta)·(3·xi - 1)/(2·d)
  rw2 = -3·xi·(1 - eta)/d^2
  rt2 = (1 - eta)·(1 + 3·xi)/(2·d)
  rw3 = -3·xi·(1 + eta)/d^2
  rt3 = (1 + eta)·(1 + 3·xi)/(2·d)
  rw4 = 3·xi·(1 + eta)/d^2
  rt4 = (1 + eta)·(3·xi - 1)/(2·d)
  sw1 = 3·(1 - xi)·eta/d^2
  st1 = (1 - xi)·(3·eta - 1)/(2·d)
  sw2 = 3·(1 + xi)·eta/d^2
  st2 = (1 + xi)·(3·eta - 1)/(2·d)
  sw3 = -3·(1 + xi)·eta/d^2
  st3 = (1 + xi)·(1 + 3·eta)/(2·d)
  sw4 = -3·(1 - xi)·eta/d^2
  st4 = (1 - xi)·(1 + 3·eta)/(2·d)
  tq = 3·(2 - xi^2 - eta^2)/(2·d^2)
  bx1 = (1 - xi)·(1 + 3·xi)/(4·d)
  by1 = (1 - eta)·(1 + 3·eta)/(4·d)
  bx2 = (1 + xi)·(1 - 3·xi)/(4·d)
  by2 = -(1 - eta)·(1 + 3·eta)/(4·d)
  bx3 = (1 + xi)·(3·xi - 1)/(4·d)
  by3 = (1 + eta)·(3·eta - 1)/(4·d)
  bx4 = -(1 - xi)·(1 + 3·xi)/(4·d)
  by4 = (1 + eta)·(1 - 3·eta)/(4·d)
  B = [rw1, 0, rt1, rw2, 0, rt2, rw3, 0, rt3, rw4, 0, rt4; sw1, -st1, 0, sw2, -st2, 0, sw3, -st3, 0, sw4, -st4, 0; tq, -by1, bx1, -tq, -by2, bx2, tq, -by3, bx3, -tq, -by4, bx4]
end

function K = dkq_K(Db, d)
  % rigidez 12×12 del DKQ: Gauss 2×2, det J = (d/2)^2
  gx = [-1, 1, 1, -1]/sqrt(3)
  gy = [-1, -1, 1, 1]/sqrt(3)
  K = zeros(12, 12)
  for k = 1:4
    B = dkq_B(gx(k), gy(k), d)
    K = K + transpose(B)·Db·B·(d/2)^2
  end
end

function K = frame_K(E, G, A, Iy, Iz, J, L)
  % Timoshenko 3D 12×12 (local_stiffness.py, _frame_k), área de corte 5/6·A
  As = 5/6·A
  pz = 12·E·Iz/(G·As·L^2)
  py = 12·E·Iy/(G·As·L^2)
  ea = E·A/L
  gj = G·J/L
  tz = 12·E·Iz/L^3/(1 + pz)
  bz = 6·E·Iz/L^2/(1 + pz)
  kz = 4·E·Iz/L·(1 + pz/4)/(1 + pz)
  az = 2·E·Iz/L·(1 - pz/2)/(1 + pz)
  ty = 12·E·Iy/L^3/(1 + py)
  by = 6·E·Iy/L^2/(1 + py)
  ky = 4·E·Iy/L·(1 + py/4)/(1 + py)
  ay = 2·E·Iy/L·(1 - py/2)/(1 + py)
  K = zeros(12, 12)
  K(1, 1) = ea
  K(1, 7) = -ea
  K(7, 1) = -ea
  K(7, 7) = ea
  K(4, 4) = gj
  K(4, 10) = -gj
  K(10, 4) = -gj
  K(10, 10) = gj
  K(2, 2) = tz
  K(2, 6) = bz
  K(2, 8) = -tz
  K(2, 12) = bz
  K(6, 2) = bz
  K(6, 6) = kz
  K(6, 8) = -bz
  K(6, 12) = az
  K(8, 2) = -tz
  K(8, 6) = -bz
  K(8, 8) = tz
  K(8, 12) = -bz
  K(12, 2) = bz
  K(12, 6) = az
  K(12, 8) = -bz
  K(12, 12) = kz
  K(3, 3) = ty
  K(3, 5) = -by
  K(3, 9) = -ty
  K(3, 11) = -by
  K(5, 3) = -by
  K(5, 5) = ky
  K(5, 9) = by
  K(5, 11) = ay
  K(9, 3) = -ty
  K(9, 5) = by
  K(9, 9) = ty
  K(9, 11) = by
  K(11, 3) = -by
  K(11, 5) = ay
  K(11, 9) = by
  K(11, 11) = ky
end

function R = rot_frame(p0, p1)
  % transformation.py, frame: λ con x a lo largo de la barra; 4 bloques de 3×3
  dv = p1 - p0
  L = norm(dv)
  l = dv(1)/L
  m = dv(2)/L
  n = dv(3)/L
  if abs(n - 1) < 1e-9
    lam = [0, 0, 1; 0, 1, 0; -1, 0, 0]
  elseif abs(n + 1) < 1e-9
    lam = [0, 0, -1; 0, 1, 0; 1, 0, 0]
  else
    D = sqrt(l^2 + m^2)
    lam = [l, m, n; -m/D, l/D, 0; -l·n/D, -m·n/D, D]
  end
  R = zeros(12, 12)
  for k = 0:3
    for r = 1:3
      for c = 1:3
        R(3·k + r, 3·k + c) = lam(r, c)
      end
    end
  end
end

function K = frame_Koff(E, G, A, Iy, Iz, J, L, li, lj)
  % brazos rígidos como CSI: flexión y cortante con la longitud libre Lf = L - li - lj; axil y torsión con L entera; K = T'·k·T
  Lf = L - li - lj
  kf = frame_K(E, G, A, Iy, Iz, J, Lf)
  ke = frame_K(E, G, A, Iy, Iz, J, L)
  kf(1, 1) = ke(1, 1)
  kf(1, 7) = ke(1, 7)
  kf(7, 1) = ke(7, 1)
  kf(7, 7) = ke(7, 7)
  kf(4, 4) = ke(4, 4)
  kf(4, 10) = ke(4, 10)
  kf(10, 4) = ke(10, 4)
  kf(10, 10) = ke(10, 10)
  T = eye(12)
  T(2, 6) = li
  T(3, 5) = -li
  T(8, 12) = -lj
  T(9, 11) = lj
  K = T'·kf·T
end
#show
