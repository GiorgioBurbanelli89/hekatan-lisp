# Losa rectangular por elementos finitos: las funciones de forma DEDUCIDAS (Hermite)
#numerico

#: La losa **Rectangular Slab FEA** de Calcpad (Ned Ganchovski), pero con las funciones de
#: forma DEDUCIDAS por el motor en vez de escritas a mano: se parten cuatro polinomios
#: sencillos (constante, lineal, cuadrático, cúbico), se arma la matriz de condiciones —
#: flecha y giro en cada extremo del elemento —, se invierte, y salen las cuatro de Hermite
#: con sus derivadas. La resta contra las fórmulas de Calcpad da cero.
#: **Orden.** La parte **A** hace TODO en símbolos, con el lado del elemento como L libre:
#: el motor deriva, invierte y simplifica sin usar ni un dato de la losa. La parte **B**
#: trae los números: la malla de @{n_a} × @{n_b} elementos (@{a} m × @{b} m), la misma
#: deducción repetida con aritmética —la resta sigue dando cero— y de ahí el análisis
#: completo: rigidez, ensamblaje, apoyos, flechas y momentos.
#: **Por qué se repite la deducción.** El programa numérico no compila los operadores
#: simbólicos: la parte A corre en el motor simbólico y queda como fórmula; la parte B
#: corre en el programa numérico. Dos caminos a la misma cuenta, y las restas de A.4 y de
#: B.3 lo comprueban contra el mismo oráculo.
#: **Oráculos.** Las fórmulas de Calcpad (Rectangular Slab FEA) y la hoja 71, que ya le
#: cuadra a 4 decimales con 849 valores.
#: Para mirar un dato sin bajar: la matriz constitutiva del material ☞{tabla D} y las flechas nodales ☞{tabla W_z} salen al pasar el ratón sobre la mano, y una nota con la malla dentro del texto ☞{la losa mide @{a} x @{b} m con @{n_a} x @{n_b} elementos}.
#: **Unidades.** Como en Calcpad: E en MPa (= MN/m²) y q en kN/m². Entonces K sale en MN/m,
#: F en kN, la flecha en mm y los momentos en kN·m/m.

## A · Deducción simbólica (una sola vez, con el lado L libre)
#: Todo en símbolos: ninguna fila de esta parte usa un dato de la losa. Las cuatro
#: condiciones forman una matriz de 4 × 4; su inversa son los coeficientes que se buscan.

### A.1 · Cuatro polinomios y la matriz de condiciones
#: **Funciones base:** las cuatro potencias de x sobre el elemento natural, de 0 a 1.
#: **Cuatro condiciones** (las que defines a una Hermite): la flecha vale 1 en el extremo
#: izquierdo y 0 en el derecho; el giro vale 0 en ambos. La fila del giro va dividida por
#: el lado L para que quede en la misma unidad que la flecha. El motor deriva cada monomio
#: y evalúa la pendiente en el punto (Slope):
p(x) = [1, x, x^2, x^3]
A_H = Simplify{[p(0); (1/L)*[Slope{1 @ x = 0}, Slope{x @ x = 0}, Slope{x^2 @ x = 0}, Slope{x^3 @ x = 0}]; p(1); (1/L)*[Slope{1 @ x = 1}, Slope{x @ x = 1}, Slope{x^2 @ x = 1}, Slope{x^3 @ x = 1}]]}
#: Fila 1: las cuatro funciones valen 1 en el extremo izquierdo. Fila 2: sus pendientes
#: allí, divididas por L. Fila 3: valen 0 en el extremo derecho. Fila 4: sus pendientes
#: aquí, divididas por L.

### A.2 · La inversa: los coeficientes de las Hermite
#: Cada incógnita es el coeficiente de un monomio en una de las cuatro funciones. El
#: sistema es matriz por incógnita igual a condiciones, así que las incógnitas salen con la
#: inversa de A_H: cada COLUMNA de C_H es el conjunto de coeficientes (desde la constante
#: hasta el cúbico) de una función. Con eso la Hermite queda deducida, no escrita:
C_H = Simplify{inv(A_H)}

### A.3 · Las cuatro funciones y las derivadas de la base
#: Multiplicar la base por la inversa arma las cuatro funciones a la vez. Las derivadas
#: salen de la misma base diferenciada (el motor aplica Partial a cada monomio, dos veces
#: para las curvaturas):
Phi_a(x) = Simplify{p(x)*C_H}
dp_v = [Partial{1 @ x}, Partial{x @ x}, Partial{x^2 @ x}, Partial{x^3 @ x}]
d2p_v = [Partial{Partial{1 @ x} @ x}, Partial{Partial{x @ x} @ x}, Partial{Partial{x^2 @ x} @ x}, Partial{Partial{x^3 @ x} @ x}]

### A.4 · Confrontación con Calcpad: las tres restas dan cero
#: Fila por fila contra las fórmulas escritas a mano en la hoja 71: primero las funciones,
#: luego sus pendientes y al final las curvaturas. Si la deducción está bien, sobra todo y
#: queda un vector de ceros — y se comprueba con L todavía SIMBÓLICO:
dif_0 = Simplify{p(x)*C_H - [1 - x^2*(3 - 2*x), x*L*(1 - x*(2 - x)), x^2*(3 - 2*x), x^2*L*(-1 + x)]}
dif_1 = Simplify{dp_v*C_H*(1/L) - [-6*(x/L)*(1 - x), 1 - x*(4 - 3*x), 6*(x/L)*(1 - x), -x*(2 - 3*x)]}
dif_2 = Simplify{d2p_v*C_H*(1/L^2) - [-(6/L^2)*(1 - 2*x), -(2/L)*(2 - 3*x), 6/L^2*(1 - 2*x), -(2/L)*(1 - 3*x)]}

### A.5 · De cuatro funciones a dieciséis, y la matriz D
#: Cada nudo del rectángulo tiene cuatro grados de libertad: la flecha w, los giros θ_{x}
#: y θ_{y} y el alabeo ψ. Las dieciséis funciones de forma de la losa son el PRODUCTO de una
#: función de x por una de y: cuatro por cuatro, un producto tensorial — una por cada par
#: de índices (el de x, el de y). La matriz constitutiva solo necesita el material:
D_s = Simplify{E*t^3/(12*(1 - ν^2))*[1, ν, 0; ν, 1, 0; 0, 0, (1 - ν)/2]}
#: E, t y ν siguen libres: D entra con sus números en B.4.

## B · Con los números: la malla, la misma deducción y el análisis
#: Aquí entran los datos —la parte A no usó ninguno—, se repite la deducción con aritmética
#: y sigue el mismo análisis de la hoja 71, que coincide con Calcpad.

### B.1 · Datos
a = 6 [m] 'largo de la losa
b = 4 [m] 'ancho de la losa
t = 0.1 [m] 'espesor
q = 10 [kN/m²] 'carga repartida
E = 35000 [MPa] 'módulo de elasticidad
ν = 0.15 'coeficiente de Poisson

### B.2 · Malla de elementos finitos
#: Elemento rectangular con n grados de libertad: en cada uno de sus 4 nudos, la flecha w, los giros θx, θy y el alabeo ψ.
n = 16 'grados de libertad del elemento
n_a = 6 'elementos a lo largo de a
n_b = 4 'elementos a lo largo de b
n_e = n_a·n_b 'número de elementos
n_j = (n_a + 1)·(n_b + 1) 'número de nudos
a_1 = a/n_a [m] 'lado del elemento en x
b_1 = b/n_b [m] 'lado del elemento en y
n_s = 2·(n_a + n_b) 'nudos apoyados (todo el borde)
#hide
x_j = zeros(n_j, 1)
y_j = zeros(n_j, 1)
x_0 = 0
y_0 = 0
for j = 1:n_j
  x_j(j) = x_0
  y_j(j) = y_0
  y_0 = y_0 + b_1
  if y_0 > b
    y_0 = 0
    x_0 = x_0 + a_1
  end
end
e_j = zeros(n_e, 4)
for i_a = 1:n_a
  for i_b = 1:n_b
    e = i_b + n_b·(i_a - 1)
    j = e + i_a - 1
    e_j(e, 1) = j
    e_j(e, 2) = j + n_b + 1
    e_j(e, 3) = j + n_b + 2
    e_j(e, 4) = j + 1
  end
end
s_j = zeros(n_s, 1)
i_s = 0
for i = 1:n_a + 1
  i_s = i_s + 1
  s_j(i_s) = (n_b + 1)·i - n_b
end
for i = 1:n_a + 1
  i_s = i_s + 1
  s_j(i_s) = (n_b + 1)·i
end
for i = 2:n_b
  i_s = i_s + 1
  s_j(i_s) = i
end
for i = 2:n_b
  i_s = i_s + 1
  s_j(i_s) = n_a·(n_b + 1) + i
end
#show
#: Coordenadas de los nudos, numerados por columnas (de abajo arriba y de izquierda a derecha):
x_j [m]
y_j [m]
#: Nudos de cada elemento (una columna por elemento, en sentido antihorario desde la esquina inferior izquierda):
transpose(e_j)
#: Nudos apoyados:
s_j
#malla(x_j, y_j, e_j, s_j)

### B.3 · La misma deducción, ahora con los números de la malla
#: La matriz de condiciones de A.1 evaluada con el lado del elemento. La biblioteca
#: numérica no trae derivadas, así que polyd aplica la regla de la potencia en un bucle (el
#: diff de MATLAB) y peval evalúa el polinomio; la inversa da los coeficientes. La misma
#: función condM arma la matriz para el lado a (en ξ) y para el lado b (en η):
function d = polyd(c)
  n = length(c)
  d = zeros(1, n - 1)
  for i = 1:n - 1
    d(i) = i*c(i + 1)
  end
end
function v = peval(c, x)
  n = length(c)
  v = 0
  for i = 1:n
    v = v + c(i)*x^(i - 1)
  end
end
function M = condM(L)
  M = zeros(4, 4)
  E4 = eye(4)
  for k = 1:4
    c = E4(:, k)
    M(1, k) = peval(c, 0)
    M(2, k) = peval(polyd(c), 0)/L
    M(3, k) = peval(c, 1)
    M(4, k) = peval(polyd(c), 1)/L
  end
end
A_a = condM(a_1)
C_a = inv(A_a)
A_b = condM(b_1)
C_b = inv(A_b)
#: Con los lados de la malla las dos inversas son @{C_a} y @{C_b}. Las cuatro funciones
#: deducidas en ξ (Pa) y en η (Pb), con sus pendientes y curvaturas — otra vez peval y
#: polyd, ahora sobre las columnas de la inversa:
Pa(x, k) = peval(C_a(:, k), x)
dPa(x, k) = peval(polyd(C_a(:, k)), x)/a_1
d2Pa(x, k) = peval(polyd(polyd(C_a(:, k))), x)/a_1^2
Pb(y, k) = peval(C_b(:, k), y)
dPb(y, k) = peval(polyd(C_b(:, k)), y)/b_1
d2Pb(y, k) = peval(polyd(polyd(C_b(:, k))), y)/b_1^2
#: **Confrontación con Calcpad:** las mismas restas de A.4, en un punto cualquiera y con
#: los lados numéricos. Las de ξ y las de η dan cero; la última es redondeo de última cifra:
x_t = 0.37
y_t = 0.63
r1 = Pa(x_t, 1) - (1 - x_t^2*(3 - 2*x_t))
r2 = Pa(x_t, 2) - x_t*a_1*(1 - x_t*(2 - x_t))
r3 = Pa(x_t, 3) - x_t^2*(3 - 2*x_t)
r4 = Pa(x_t, 4) - x_t^2*a_1*(-1 + x_t)
rd1 = dPa(x_t, 1) - (-6*(x_t/a_1)*(1 - x_t))
rd2 = d2Pa(x_t, 1) - (-(6/a_1^2)*(1 - 2*x_t))
r5 = Pb(y_t, 1) - (1 - y_t^2*(3 - 2*y_t))
r6 = Pb(y_t, 2) - y_t*b_1*(1 - y_t*(2 - y_t))
rd5 = dPb(y_t, 1) - (-6*(y_t/b_1)*(1 - y_t))

### B.4 · Las matrices del elemento: D, las dieciséis funciones y B
#: La matriz constitutiva, con los números del material:
D = E·t^3/(12·(1 - ν^2))·[1, ν, 0; ν, 1, 0; 0, 0, (1 - ν)/2]
#: **Orden de los dieciséi grados de libertad:** w, θx, θy y ψ de los cuatro nudos (nudo 1
#: abajo a la izquierda, sentido antihorario). La columna k de la matriz usa la función
#: ia(k) de x y ib(k) de y: así se repite el producto tensorial de A.5 — la misma estructura
#: que en la hoja 71:
ia = [1, 2, 1, 2, 3, 4, 3, 4, 3, 4, 3, 4, 1, 2, 1, 2]
ib = [1, 1, 2, 2, 1, 1, 2, 2, 3, 3, 4, 4, 3, 3, 4, 4]
#: **Vector de funciones** (para la carga repartida) y **matriz B**, cuya fila 1 es la
#: curvatura en x, la fila 2 la curvatura en y y la fila 3 la torsión (el doble de la
#: derivada cruzada), en coordenadas naturales de 0 a 1. Un bloque function solo ve sus
#: parámetros: C_a, C_b, a_1 y b_1 entran como argumentos y se llama a peval y polyd, la
#: misma fórmula de Pa:
function v = Nvec(x, y, ia, ib, C_a, C_b)
  v = zeros(16, 1)
  for k = 1:16
    k2 = ia(k)
    k3 = ib(k)
    v(k) = peval(C_a(:, k2), x)*peval(C_b(:, k3), y)
  end
end
function Bm = Bmat(x, y, ia, ib, C_a, C_b, a_1, b_1)
  Bm = zeros(3, 16)
  for k = 1:16
    k2 = ia(k)
    k3 = ib(k)
    ca = C_a(:, k2)
    cb = C_b(:, k3)
    Bm(1, k) = peval(polyd(polyd(ca)), x)*peval(cb, y)/a_1^2
    Bm(2, k) = peval(ca, x)*peval(polyd(polyd(cb)), y)/b_1^2
    Bm(3, k) = 2*peval(polyd(ca), x)*peval(polyd(cb), y)/(a_1*b_1)
  end
end
#: **Rigidez y carga del elemento** por cuadratura de Gauss de 4 × 4 puntos (pesos y puntos
#: de la regla estándar, llevados al intervalo de 0 a 1): la rigidez multiplica dos matrices
#: B, cuyas entradas suben hasta grado 3, así que el integrando llega a grado 6 y hacen
#: falta cuatro puntos (son exactos hasta grado 7). La carga es de grado 3 y también queda
#: exacta:
gp = [0.5 - 0.5*0.8611363115940526, 0.5 - 0.5*0.3399810435848563, 0.5 + 0.5*0.3399810435848563, 0.5 + 0.5*0.8611363115940526]
gw = [0.5*0.3478548451374538, 0.5*0.6521451548625461, 0.5*0.6521451548625461, 0.5*0.3478548451374538]
K_e = zeros(16, 16)
for i = 1:4
  for j = 1:4
    Bg = Bmat(gp(i), gp(j), ia, ib, C_a, C_b, a_1, b_1)
    K_e = K_e + a_1·b_1·gw(i)·gw(j)·transpose(Bg)·D·Bg
  end
end
F_e = zeros(16, 1)
for i = 1:4
  for j = 1:4
    F_e = F_e + a_1·b_1·gw(i)·gw(j)·q·Nvec(gp(i), gp(j), ia, ib, C_a, C_b)
  end
end
K_e [MN/m]
F_e [kN]

### B.5 · Ensamblaje y solución
#: Cuatro grados de libertad por nudo (k₁ = n/4). Los del nudo j son k₁·(j − 1) + 1 … k₁·j, y los del elemento, los de sus cuatro nudos seguidos:
k_1 = n/4
n_d = k_1·n_j 'grados de libertad de la losa
#hide
d_j(j) = k_1·(j - 1) + (1:k_1)
d_e(e) = [d_j(e_j(e, 1)), d_j(e_j(e, 2)), d_j(e_j(e, 3)), d_j(e_j(e, 4))]
K = zeros(n_d, n_d)
F = zeros(n_d, 1)
#show
#: Ensamblaje: la rigidez y la carga de cada elemento se SUMAN en las filas y columnas de sus grados de libertad.
for e = 1:n_e
  g = d_e(e)
  K(g, g) = K(g, g) + K_e
  F(g) = F(g) + F_e
end
#: Apoyos (borde simplemente apoyado): un muelle muy rígido k_s en la flecha de cada nudo del borde y en el giro a lo largo del borde, como en Calcpad.
k_s = 10^20
for i = 1:n_s
  j = k_1·(s_j(i) - 1) + 1
  K(j, j) = K(j, j) + k_s
  if y_j(s_j(i)) == 0 || y_j(s_j(i)) == b
    K(j + 1, j + 1) = K(j + 1, j + 1) + k_s
  end
  if x_j(s_j(i)) == 0 || x_j(s_j(i)) == a
    K(j + 2, j + 2) = K(j + 2, j + 2) + k_s
  end
end
#: Matriz de rigidez global (se muestran las esquinas):
K [MN/m]
#: Vector de cargas global:
F [kN]
#: Solución del sistema K·Z = F por Cholesky (clsolve, como en Calcpad: K es simétrica y definida positiva):
Z = clsolve(K, F) [mm]

### B.6 · Resultados
#: Flechas de los nudos (fila = y, columna = x), redondeadas a 0.001 mm como en Calcpad:
#hide
W_z = zeros(n_a + 1, n_b + 1)
for i = 1:n_a + 1
  for j = 1:n_b + 1
    W_z(i, j) = round(Z(4·((i - 1)·(n_b + 1) + j) - 3)·1000)/1000
  end
end
#show
transpose(W_z) [mm]
#: Entre nudos, la flecha se interpola con el spline de Calcpad sobre la matriz de flechas:
w(x, y) = spline(1 + x/a_1, 1 + y/b_1, W_z)
#map(-w(x, y), [0 6], [0 4])
w_c = w(a/2, b/2) [mm] 'flecha máxima, en el centro

### Momentos flectores
#: En cada elemento, M = −D·B·Z_e en sus cuatro nudos; en cada nudo se promedian los elementos que llegan a él.
#hide
Z_e(e) = Z(d_e(e))
M_j = zeros(3, n_j)
c_j = zeros(n_j, 1)
for e = 1:n_e
  Z_el = Z_e(e)
  x_1 = x_j(e_j(e, 1))
  y_1 = y_j(e_j(e, 1))
  for i = 1:4
    j = e_j(e, i)
    c_j(j) = c_j(j) + 1
    M_j(:, j) = M_j(:, j) - D·Bmat((x_j(j) - x_1)/a_1, (y_j(j) - y_1)/b_1, ia, ib, C_a, C_b, a_1, b_1)·Z_el
  end
end
for j = 1:n_j
  M_j(:, j) = M_j(:, j)/c_j(j)
end
Mx = zeros(n_a + 1, n_b + 1)
My = zeros(n_a + 1, n_b + 1)
Mxy = zeros(n_a + 1, n_b + 1)
for i = 1:n_a + 1
  for k = 1:n_b + 1
    j = (i - 1)·(n_b + 1) + k
    Mx(i, k) = M_j(1, j)
    My(i, k) = M_j(2, j)
    Mxy(i, k) = M_j(3, j)
  end
end
i_c = round(n_a/2)
j_c = round(n_b/2)
#show
#: Resultados del elemento central e_c y de su primer nudo j₁:
e_c = (i_c - 1)·n_a + j_c + 1
j_1 = e_j(e_c, 1)
Z_e(e_c) [mm]
M_e(x, y) = -D·Bmat(x/a_1, y/b_1, ia, ib, C_a, C_b, a_1, b_1)·Z_e(e_c)
M_e(0, 0) [kNm/m]
#: Momentos promedio en los nudos (filas: Mx, My, Mxy):
M_j [kNm/m]
#: **Mx** (fila = y, columna = x):
transpose(Mx) [kNm/m]
M_x(x, y) = spline(1 + x/a_1, 1 + y/b_1, Mx)
#map(M_x(x, y), [0 6], [0 4])
M_x(a/2, b/2) [kNm/m] 'máximo
#: **My**:
transpose(My) [kNm/m]
M_y(x, y) = spline(1 + x/a_1, 1 + y/b_1, My)
#map(M_y(x, y), [0 6], [0 4])
M_y(a/2, b/2) [kNm/m] 'máximo
#: **Mxy** (torsor):
transpose(Mxy) [kNm/m]
M_xy(x, y) = spline(1 + x/a_1, 1 + y/b_1, Mxy)
#map(M_xy(x, y), [0 6], [0 4])
M_xy(0, 0) [kNm/m] 'máximo, en la esquina
