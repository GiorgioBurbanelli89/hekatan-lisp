# Losa rectangular por elementos finitos: de la ecuación diferencial de Kirchhoff a la DKQ de Batoz y Tahar (= DKE de Wilson)
#numerico
#: **Qué se calcula.** La losa del ejemplo «Rectangular Slab FEA» de Calcpad: 6 × 4 m, 10 cm, apoyada en todo el borde y con 10 kN/m². Se parte de la **ecuación diferencial** de la placa delgada y de sus **condiciones de contorno**, se pasa a la **forma débil** y de ahí al elemento finito de placa delgada de 4 nudos.
#: **Quién es quién.** DKT = triángulo de Batoz, Bathe y Ho (1980). DKQ = cuadrilátero de Batoz y Tahar (1982), IJNME 18, 1655-1677. DKE = «Discrete Kirchhoff Element» de Wilson, *Three-Dimensional Static and Dynamic Analysis of Structures*, cap. 8, §8.8, ec. (8.21). La DKQ y la DKE son **el mismo elemento** escrito de dos maneras: armada la K de 12 × 12 de las dos, coinciden a 7.5·10⁻¹⁶ (cuadrado, rectángulo, cuadrilátero irregular y trapecio, ν de 0 a 0.45; `losa_rectangular/dke_wilson_vs_dkq.py`). Es el Shell-Thin de SAP2000 y ETABS.
#: **Unidades:** kN y m. Momentos en kN·m/m. **Signo de CSI:** M > 0 = tracción abajo (momento positivo de vano).

## 1 · El problema
a = 6 [m] 'largo de la losa, en x
b = 4 [m] 'ancho de la losa, en y (luz corta)
t = 0.1 [m] 'espesor
q = 10 [kN/m²] 'carga uniforme hacia abajo
E = 35000000 [kN/m²] 'módulo de elasticidad (35 000 MPa)
ν = 0.15 'coeficiente de Poisson (sin unidad)
#: **Cómo se lee la planta.** El rectángulo grueso es la losa; el borde rayado es el apoyo simple de los cuatro lados (w = 0, giros libres). El origen es la esquina de abajo a la izquierda. La carga q cubre toda la planta.
#dibujo("Planta: losa de 6 × 4 m apoyada en los cuatro bordes", ud = m, escala = auto, cotas = m, alto = 140)
#  rect(-0.12, -0.12, 6.24, 0.24, "denso")
#  rect(-0.12, 3.88, 6.24, 0.24, "denso")
#  rect(-0.12, 0.12, 0.24, 3.76, "denso")
#  rect(5.88, 0.12, 0.24, 3.76, "denso")
#  rect(0, 0, 6, 4, "gruesa")
#  flecha(0.4, 0.4, 1.2, 0.4, "rojo")
#  flecha(0.4, 0.4, 0.4, 1.2, "rojo")
#  texto(1.3, 0.4, "x", 2.8, "i", estilo = "rojo")
#  texto(0.4, 1.35, "y", 2.8, "c", estilo = "rojo")
#  texto(3.0, 2.3, "q = 10 kN/m²", 2.8, "c", estilo = "azul")
#  texto(3.0, 1.7, "t = 0.10 m", 2.6, "c")
#  cota(0, -0.5, 6, -0.5, -0.05, "6.00")
#  cota(-1.0, 0, -1.0, 4, 0.05, "4.00")
#fin
#dibujo("Corte por la luz corta: losa de 10 cm con la carga", ud = m, escala = auto, cotas = m, alto = 100)
#  seccion(0, 0, 4.0, 0.10)
#  rect(-0.12, -0.25, 0.24, 0.35, "gruesa")
#  rect(3.88, -0.25, 0.24, 0.35, "gruesa")
#  carga(0, 0.10, 4.0, 0.10, 0.3, 0.3, "q = 10 kN/m²", "azul", n = 11)
#  cota(0, -0.45, 4.0, -0.45, -0.05, "4.00")
#fin

## 2 · La ecuación diferencial de Kirchhoff
#: **Hipótesis de Kirchhoff:** la normal al plano medio sigue normal después de flectar. Por eso los giros son las pendientes de w y las curvaturas son segundas derivadas: κx = −w,xx, κy = −w,yy, κxy = −2·w,xy.
#: **Rigidez a flexión:**
D_s = Simplify{E*t^3/(12*(1-nu^2))}
#: **Momentos por unidad de ancho** (ley de Hooke integrada en el espesor): Mx = D·(κx + ν·κy), My = D·(ν·κx + κy), Mxy = D·(1 − ν)/2·κxy.
#: **Equilibrio** de un trozo dx·dy: cortantes Qx = Mx,x + Mxy,y, Qy = Mxy,x + My,y y vertical Qx,x + Qy,y + q = 0. Sustituyendo los momentos queda la ecuación de cuarto orden:
#: D·(w,xxxx + 2·w,xxyy + w,yyyy) = q,  o sea  D·∇⁴w = q.
#: Ejemplo: un término de Navier w = W·sin(m·π·x/a)·sin(n·π·y/b). Sus curvaturas, derivando dos veces:
k_xx = Simplify{-Diff{Diff{W*sin(m*pi*x/a)*sin(n*pi*y/b) @ x} @ x}}
k_yy = Simplify{-Diff{Diff{W*sin(m*pi*x/a)*sin(n*pi*y/b) @ y} @ y}}
#: Cada término cumple D·∇⁴w = q_mn con W_mn = q_mn/(D·π⁴·(m²/a² + n²/b²)²) y, para carga uniforme, q_mn = 16·q/(π²·m·n) (m, n impares).

## 3 · Condiciones de contorno
#: En cada borde se dan DOS condiciones (la ecuación es de cuarto orden). **Esenciales** (se imponen al desplazamiento) y **naturales** (salen solas de la forma débil):
#: · **Apoyado:** w = 0 (esencial) y Mn = 0 (natural). Es el caso de esta losa.
#: · **Empotrado:** w = 0 y ∂w/∂n = 0 (las dos esenciales).
#: · **Libre:** Mn = 0 y Vn = Qn + ∂Mns/∂s = 0 (las dos naturales).
#: El seno de Navier vale cero en x = 0 y x = a, y también su segunda derivada: cumple w = 0 y Mx = 0 en los bordes, por eso es la solución exacta de la placa apoyada.

## 4 · Forma débil (resumen del vídeo «De la ecuación diferencial a la forma débil»)
#: Se multiplica D·∇⁴w = q por un desplazamiento virtual δw que cumple las condiciones esenciales y se integra por partes dos veces. Los términos de borde se anulan (esenciales por δw = 0, naturales porque Mn y Vn son datos) y queda el **trabajo virtual**:
#: ∫ δκᵀ·D_b·κ dA = ∫ δw·q dA.  Solo hay segundas derivadas de w: basta con que w y sus giros sean continuos.

## 5 · El elemento: Kirchhoff discreto (DKQ de Batoz-Tahar = DKE de Wilson)
#: Malla de la hoja de Calcpad: 6 × 4 elementos de 1 × 1 m.
n_x = 6 'elementos en x
n_y = 4 'elementos en y
h_x = a/n_x [m] 'lado del elemento en x
h_y = b/n_y [m] 'lado del elemento en y
#: **La idea.** Los giros βx, βy se interpolan con las 8 funciones cuadráticas (4 esquinas + 4 puntos medios). Los giros de punto medio no son grados de libertad: se eliminan imponiendo Kirchhoff **solo en los lados**. A lo largo del lado ij de largo L, w es una cúbica de Hermite; su pendiente en el punto medio es:
w_lado = Simplify{(1 - 3*s^2/L^2 + 2*s^3/L^3)*w_i + (s - 2*s^2/L + s^3/L^2)*p_i + (3*s^2/L^2 - 2*s^3/L^3)*w_j + (-s^2/L + s^3/L^2)*p_j}
#: Derivando y evaluando en s = L/2: β_s,medio = 3/(2·L)·(w_j − w_i) − ¼·(β_s,i + β_s,j). Restando la parte lineal ½·(β_s,i + β_s,j) sale la ec. (8.21) de Wilson:
dpsi = Simplify{3/(2*L)*(w_j - w_i) - 3/4*(p_i + p_j)}
#: El giro normal al lado se toma lineal. Con eso quedan 3 grados de libertad por nudo (w, θx = ∂w/∂y, θy = −∂w/∂x) y 12 por elemento.
#: Coordenadas del elemento tipo (todos son iguales):
X1 = 0 [m] 'x del nudo 1
Y1 = 0 [m] 'y del nudo 1
X2 = h_x [m] 'x del nudo 2
Y2 = 0 [m] 'y del nudo 2
X3 = h_x [m] 'x del nudo 3
Y3 = h_y [m] 'y del nudo 3
X4 = 0 [m] 'x del nudo 4
Y4 = h_y [m] 'y del nudo 4
#hide
m5 = (X1-X2)^2 + (Y1-Y2)^2
m6 = (X2-X3)^2 + (Y2-Y3)^2
m7 = (X3-X4)^2 + (Y3-Y4)^2
m8 = (X4-X1)^2 + (Y4-Y1)^2
A5 = -(X1-X2)/m5
A6 = -(X2-X3)/m6
A7 = -(X3-X4)/m7
A8 = -(X4-X1)/m8
B5 = 0.75*(X1-X2)*(Y1-Y2)/m5
B6 = 0.75*(X2-X3)*(Y2-Y3)/m6
B7 = 0.75*(X3-X4)*(Y3-Y4)/m7
B8 = 0.75*(X4-X1)*(Y4-Y1)/m8
C5 = (0.25*(X1-X2)^2 - 0.5*(Y1-Y2)^2)/m5
C6 = (0.25*(X2-X3)^2 - 0.5*(Y2-Y3)^2)/m6
C7 = (0.25*(X3-X4)^2 - 0.5*(Y3-Y4)^2)/m7
C8 = (0.25*(X4-X1)^2 - 0.5*(Y4-Y1)^2)/m8
D5 = -(Y1-Y2)/m5
D6 = -(Y2-Y3)/m6
D7 = -(Y3-Y4)/m7
D8 = -(Y4-Y1)/m8
E5 = (0.25*(Y1-Y2)^2 - 0.5*(X1-X2)^2)/m5
E6 = (0.25*(Y2-Y3)^2 - 0.5*(X2-X3)^2)/m6
E7 = (0.25*(Y3-Y4)^2 - 0.5*(X3-X4)^2)/m7
E8 = (0.25*(Y4-Y1)^2 - 0.5*(X4-X1)^2)/m8
Hx_q(n1, n2, n3, n4, n5, n6, n7, n8) = [1.5*(A5*n5 - A8*n8); B5*n5 + B8*n8; n1 - C5*n5 - C8*n8; 1.5*(A6*n6 - A5*n5); B6*n6 + B5*n5; n2 - C6*n6 - C5*n5; 1.5*(A7*n7 - A6*n6); B7*n7 + B6*n6; n3 - C7*n7 - C6*n6; 1.5*(A8*n8 - A7*n7); B8*n8 + B7*n7; n4 - C8*n8 - C7*n7]
Hy_q(n1, n2, n3, n4, n5, n6, n7, n8) = [1.5*(D5*n5 - D8*n8); -n1 + E5*n5 + E8*n8; -B5*n5 - B8*n8; 1.5*(D6*n6 - D5*n5); -n2 + E6*n6 + E5*n5; -B6*n6 - B5*n5; 1.5*(D7*n7 - D6*n6); -n3 + E7*n7 + E6*n6; -B7*n7 - B6*n6; 1.5*(D8*n8 - D7*n7); -n4 + E8*n8 + E7*n7; -B8*n8 - B7*n7]
N5x(xi, eta) = -xi*(1-eta)
N5y(xi, eta) = -0.5*(1-xi^2)
N6x(xi, eta) = 0.5*(1-eta^2)
N6y(xi, eta) = -(1+xi)*eta
N7x(xi, eta) = -xi*(1+eta)
N7y(xi, eta) = 0.5*(1-xi^2)
N8x(xi, eta) = -0.5*(1-eta^2)
N8y(xi, eta) = -(1-xi)*eta
N1x(xi, eta) = -0.25*(1-eta) - 0.5*(N8x(xi, eta) + N5x(xi, eta))
N1y(xi, eta) = -0.25*(1-xi) - 0.5*(N8y(xi, eta) + N5y(xi, eta))
N2x(xi, eta) = 0.25*(1-eta) - 0.5*(N5x(xi, eta) + N6x(xi, eta))
N2y(xi, eta) = -0.25*(1+xi) - 0.5*(N5y(xi, eta) + N6y(xi, eta))
N3x(xi, eta) = 0.25*(1+eta) - 0.5*(N6x(xi, eta) + N7x(xi, eta))
N3y(xi, eta) = 0.25*(1+xi) - 0.5*(N6y(xi, eta) + N7y(xi, eta))
N4x(xi, eta) = -0.25*(1+eta) - 0.5*(N7x(xi, eta) + N8x(xi, eta))
N4y(xi, eta) = 0.25*(1-xi) - 0.5*(N7y(xi, eta) + N8y(xi, eta))
Hxs(xi, eta) = Hx_q(N1x(xi, eta), N2x(xi, eta), N3x(xi, eta), N4x(xi, eta), N5x(xi, eta), N6x(xi, eta), N7x(xi, eta), N8x(xi, eta))
Hxh(xi, eta) = Hx_q(N1y(xi, eta), N2y(xi, eta), N3y(xi, eta), N4y(xi, eta), N5y(xi, eta), N6y(xi, eta), N7y(xi, eta), N8y(xi, eta))
Hys(xi, eta) = Hy_q(N1x(xi, eta), N2x(xi, eta), N3x(xi, eta), N4x(xi, eta), N5x(xi, eta), N6x(xi, eta), N7x(xi, eta), N8x(xi, eta))
Hyh(xi, eta) = Hy_q(N1y(xi, eta), N2y(xi, eta), N3y(xi, eta), N4y(xi, eta), N5y(xi, eta), N6y(xi, eta), N7y(xi, eta), N8y(xi, eta))
B1_q(xi, eta) = 2/h_x*Hxs(xi, eta)
B2_q(xi, eta) = 2/h_y*Hyh(xi, eta)
B3_q(xi, eta) = 2/h_y*Hxh(xi, eta) + 2/h_x*Hys(xi, eta)
#show
#: Los coeficientes de lado a…e de la DKQ salen solo de la geometría; en el lado 5 (nudos 1-2) del elemento tipo:
A_5 = A5 'coeficiente a del lado 5, en 1/m
C_5 = C5 'coeficiente c del lado 5 (sin unidad)
E_5 = E5 'coeficiente e del lado 5 (sin unidad)

## 6 · Mapeo isoparamétrico y jacobiano
#: Cada elemento es la imagen del cuadrado ξ, η ∈ [−1, 1] por x = Σ Nᵢ·xᵢ, y = Σ Nᵢ·yᵢ (funciones bilineales). El jacobiano J = ∂(x, y)/∂(ξ, η) pasa las derivadas: ∂/∂x = (2/h_x)·∂/∂ξ, ∂/∂y = (2/h_y)·∂/∂η, y dA = det J·dξ·dη.
J_11 = h_x/2 [m] 'derivada ∂x/∂ξ
J_22 = h_y/2 [m] 'derivada ∂y/∂η
det_J = J_11·J_22 [m²] 'det J: un cuarto del área del elemento

## 7 · Matriz de rigidez del elemento: K = ∫ Bᵀ·D_b·B dA
D_p = E·t^3/(12·(1 - ν^2)) [kN·m] 'rigidez a flexión D
D_b = D_p·[1, ν, 0; ν, 1, 0; 0, 0, (1 - ν)/2] [kN·m] 'matriz momento-curvatura
#: Gauss 2 × 2 en ξ, η = ±1/√3 (peso 1):
g_p = 1/sqrt(3) 'coordenada de los puntos de Gauss
#hide
B_G = zeros(12, 12)
r_g = [-g_p, g_p, g_p, -g_p]
s_g = [-g_p, -g_p, g_p, g_p]
K_e = zeros(12, 12)
for p = 1:4
  B_1 = transpose(B1_q(r_g(p), s_g(p)))
  B_2 = transpose(B2_q(r_g(p), s_g(p)))
  B_3 = transpose(B3_q(r_g(p), s_g(p)))
  K_e = K_e + det_J·(D_b(1, 1)·transpose(B_1)·B_1 + D_b(1, 2)·(transpose(B_1)·B_2 + transpose(B_2)·B_1) + D_b(2, 2)·transpose(B_2)·B_2 + D_b(3, 3)·transpose(B_3)·B_3)
  B_G(3·p - 2, :) = B_1
  B_G(3·p - 1, :) = B_2
  B_G(3·p, :) = B_3
end
#show
K_e11 = K_e(1, 1) [kN/m] 'rigidez a w del nudo 1
K_e22 = K_e(2, 2) [kN·m] 'rigidez a θx del nudo 1
K_e33 = K_e(3, 3) [kN·m] 'rigidez a θy del nudo 1
#: **Cuerpo rígido:** una traslación w = 1 en los 4 nudos no produce fuerza:
u_r = [1; 0; 0; 1; 0; 0; 1; 0; 0; 1; 0; 0]
f_r = max(abs(K_e·u_r)) [kN] 'mayor fuerza de la traslación rígida (cero)

## 8 · Ensamblaje
n_n = n_x + 1 'nudos en x
n_j = (n_x + 1)·(n_y + 1) 'número de nudos
n_e = n_x·n_y 'número de elementos
n_g = 3·n_j 'grados de libertad de la losa
#hide
X_j = zeros(n_j, 1)
Y_j = zeros(n_j, 1)
for j = 1:n_y + 1
  for i = 1:n_n
    k = (j - 1)·n_n + i
    X_j(k) = (i - 1)·h_x
    Y_j(k) = (j - 1)·h_y
  end
end
e_j = zeros(n_e, 4)
for j = 1:n_y
  for i = 1:n_x
    e = (j - 1)·n_x + i
    k = (j - 1)·n_n + i
    e_j(e, 1) = k
    e_j(e, 2) = k + 1
    e_j(e, 3) = k + n_n + 1
    e_j(e, 4) = k + n_n
  end
end
s_b = zeros(n_j, 1)
for k = 1:n_j
  if X_j(k) < 0.001 || X_j(k) > a - 0.001 || Y_j(k) < 0.001 || Y_j(k) > b - 0.001
    s_b(k) = 1
  end
end
#show
#: Nudos fila a fila desde la esquina de abajo a la izquierda. **Cómo se lee:** los números chicos son nudos y los de los cuadros, elementos. Un nudo interior lo comparten 4 elementos: allí se SUMAN 4 aportes de rigidez.
#malla(X_j, Y_j, e_j)
d_j(j) = 3·(j - 1) + (1:3)
d_e(e) = [d_j(e_j(e, 1)), d_j(e_j(e, 2)), d_j(e_j(e, 3)), d_j(e_j(e, 4))]
#hide
K = zeros(n_g, n_g)
F = zeros(n_g, 1)
#show
for e = 1:n_e
  g = d_e(e)
  K(g, g) = K(g, g) + K_e
end
#: **Carga:** cada elemento reparte q·h_x·h_y en sus 4 nudos, hacia abajo (−w):
#hide
for e = 1:n_e
  for c = 1:4
    k = e_j(e, c)
    F(3·k - 2) = F(3·k - 2) - q·h_x·h_y/4
  end
end
#show
F_z = sum(F) [kN] 'suma de las cargas nodales = −q·a·b

## 9 · Condiciones de contorno en el sistema y solución
#: Apoyo simple = condición **esencial** w = 0 en los nudos del borde (muelle muy rígido, como Calcpad). Mn = 0 es **natural**: no se escribe, los giros quedan libres.
k_r = 10^20 'rigidez del muelle de apoyo
#hide
for k = 1:n_j
  if s_b(k) == 1
    K(3·k - 2, 3·k - 2) = K(3·k - 2, 3·k - 2) + k_r
  end
end
#show
n_ap = sum(s_b) 'nudos apoyados
U = clsolve(K, F) 'desplazamientos: w en m, giros en rad
#hide
R_j = zeros(n_j, 1)
for k = 1:n_j
  if s_b(k) == 1
    R_j(k) = -k_r·U(3·k - 2)
  end
end
#show
R_t = sum(R_j) [kN] 'suma de las reacciones (= carga total)

## 10 · Resultados
#: Momentos en los nudos como los da SAP2000: B en los 4 puntos de Gauss, M = −D_b·B·u (signo de CSI), extrapolación bilineal a las esquinas y promedio de los elementos que llegan al nudo.
#hide
E_x = zeros(4, 4)
s_c = [-1, 1, 1, -1]
t_c = [-1, -1, 1, 1]
r_N = [-1, 1, 1, -1]
s_N = [-1, -1, 1, 1]
for k = 1:4
  for p = 1:4
    E_x(k, p) = 0.25·(1 + sqrt(3)·s_c(k)·r_N(p))·(1 + sqrt(3)·t_c(k)·s_N(p))
  end
end
X_E = zeros(12, 12)
D_B = zeros(12, 12)
for k = 1:4
  D_B(3·k - 2:3·k, 3·k - 2:3·k) = D_b
  for p = 1:4
    for c = 1:3
      X_E(3·(k - 1) + c, 3·(p - 1) + c) = E_x(k, p)
    end
  end
end
R_E = -X_E·D_B·B_G
M_s = zeros(n_j, 3)
c_n = zeros(n_j, 1)
for e = 1:n_e
  u_e = U(d_e(e))
  m_n = R_E·u_e
  for k = 1:4
    i = e_j(e, k)
    c_n(i) = c_n(i) + 1
    for c = 1:3
      M_s(i, c) = M_s(i, c) + m_n(3·(k - 1) + c)
    end
  end
end
for i = 1:n_j
  M_s(i, :) = M_s(i, :)/c_n(i)
end
W_m = zeros(n_n, n_y + 1)
M_1 = zeros(n_n, n_y + 1)
M_2 = zeros(n_n, n_y + 1)
M_3 = zeros(n_n, n_y + 1)
for j = 1:n_y + 1
  for i = 1:n_n
    k = (j - 1)·n_n + i
    W_m(i, j) = -1000·U(3·k - 2)
    M_1(i, j) = M_s(k, 1)
    M_2(i, j) = M_s(k, 2)
    M_3(i, j) = M_s(k, 3)
  end
end
#show
n_m = (n_y/2)·n_n + n_x/2 + 1 'nudo del centro de la losa
w_c = -1000·U(3·n_m - 2) [mm] 'flecha del centro (hacia abajo)
M_xc = M_s(n_m, 1) [kN·m/m] 'M11 en el centro
M_yc = M_s(n_m, 2) [kN·m/m] 'M22 en el centro (luz corta: manda)
M_xy1 = M_s(1, 3) [kN·m/m] 'M12 en la esquina del nudo 1 (torsor máximo)
#: **Cómo se leen los mapas.** Planta de 6 × 4 m vista desde arriba, x a la derecha e y hacia arriba; escala jet a la derecha. Pasa el cursor: el globo da la posición (x, y) y el valor.
w_z(x, y) = spline(1 + x/h_x, 1 + y/h_y, W_m)
M_xx(x, y) = spline(1 + x/h_x, 1 + y/h_y, M_1)
M_yy(x, y) = spline(1 + x/h_x, 1 + y/h_y, M_2)
M_xy(x, y) = spline(1 + x/h_x, 1 + y/h_y, M_3)
#: Flecha w (mm, hacia abajo):
#map(w_z(x, y), [0 6], [0 4])
#: M11 (kN·m/m):
#map(M_xx(x, y), [0 6], [0 4])
#: M22 (kN·m/m):
#map(M_yy(x, y), [0 6], [0 4])
#: M12 (kN·m/m):
#map(M_xy(x, y), [0 6], [0 4])

## 11 · Verificación
### 11a · Navier (solución exacta de la placa apoyada)
#hide
w_N = 0
M_xN = 0
M_yN = 0
for m = 1:2:59
  for n = 1:2:59
    s_mn = sin(m·pi/2)·sin(n·pi/2)
    d_mn = m·n·(m^2/a^2 + n^2/b^2)^2
    w_N = w_N + s_mn/d_mn
    M_xN = M_xN + (m^2/a^2 + ν·n^2/b^2)·s_mn/d_mn
    M_yN = M_yN + (ν·m^2/a^2 + n^2/b^2)·s_mn/d_mn
  end
end
w_N = 1000·16·q/(pi^6·D_p)·w_N
M_xN = 16·q/pi^4·M_xN
M_yN = 16·q/pi^4·M_yN
#show
w_Nc = w_N [mm] 'flecha del centro, Navier
M_xNc = M_xN [kN·m/m] 'Mx del centro, Navier
M_yNc = M_yN [kN·m/m] 'My del centro, Navier
e_w = round(100·(w_c - w_N)/w_N, 3) [%] 'malla 6 × 4 frente a Navier, flecha
e_Mx = round(100·(M_xc - M_xN)/M_xN, 3) [%] 'idem, M11
e_My = round(100·(M_yc - M_yN)/M_yN, 3) [%] 'idem, M22
#: **Cómo se lee.** Con 6 × 4 elementos la flecha queda 1.5 % corta y M22 3.7 % alto; con 48 × 32 (losa_calculo.py) la flecha es 6.626 mm y M22 12.320: la malla converge a Navier.
### 11b · Hekatan Struct Py y la tabla de la hoja de Calcpad
w_py = 6.528691 [mm] 'flecha del centro con Placa de hekatan-struct-py (losa_resultados.json)
M11_py = 6.225905 [kN·m/m] 'M11 del centro, Placa de hekatan-struct-py
M22_py = 12.762707 [kN·m/m] 'M22 del centro, Placa de hekatan-struct-py
d_py = round(100·max(abs(w_c - w_py)/w_py, max(abs(M_xc - M11_py)/M11_py, abs(M_yc - M22_py)/M22_py)), 6) [%] 'mayor diferencia hoja frente a hekatan-struct-py
M11_sap = 6.22 [kN·m/m] 'Mx del centro de la tabla «SAP2000 PDF» de la hoja de Calcpad
M22_sap = 12.76 [kN·m/m] 'My del centro, misma tabla
M12_sap = 7.25 [kN·m/m] 'Mxy de la esquina (valor absoluto), misma tabla
d_sap = round(100·max(abs(M_xc - M11_sap)/M11_sap, max(abs(M_yc - M22_sap)/M22_sap, abs(abs(M_xy1) - M12_sap)/M12_sap)), 3) [%] 'mayor diferencia frente a esa tabla
### 11c · Placa cuadrada: coeficientes de Timoshenko (ν = 0.3, malla 32 × 32, losa_calculo.py)
#: Apoyada: w = 0.004062·q·a⁴/D (tabla 0.00406) y M = 0.04792·q·a² (tabla 0.0479). Empotrada: w = 0.001269·q·a⁴/D (tabla 0.00126) y M = 0.02299·q·a² (tabla 0.0231).
