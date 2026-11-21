# Placa base de una columna tubular cuadrada (SHS) por elementos finitos: cáscaras, pernos, hormigón y soldadura, contra AISC y Abaqus
#numerico

#: **Qué se calcula.** La unión de una columna **hueca cuadrada (SHS)** (SHS 200 × 200 × 10) con su **placa base** de 400 × 400 × 25 mm sobre un **pedestal** de hormigón de 0.50 × 0.50 m, con **cuatro pernos** M24 y la **soldadura** del tubo a la placa, bajo compresión y momento. Se resuelve de dos maneras: por **elementos finitos de cáscara**, como lo plantea el método de componentes por elementos finitos (CBFEM) de IDEA StatiCa, y por el **método analítico de AISC** (Guía de Diseño 1), que trata la placa como un voladizo.
#: **Por qué importa.** El método de componentes por fórmulas reparte la carga con hipótesis (bloque uniforme de presión, voladizo hasta la cara del tubo). Por elementos finitos la placa se **flexiona**, **se despega** del hormigón donde el momento levanta y los **pernos** entran solo cuando hace falta: el reparto sale del cálculo. Comparar los dos enseña dónde AISC es conservador.
#: **Cómo.** Elemento ShellMITC4 de la hoja 72 (6 gdl por nudo, teoría de Reissner-Mindlin: placa **gruesa**, con deformación por cortante, como el elemento de cáscara de IDEA StatiCa; validado contra OpenSees). Soldadura = nudos compartidos en el borde del tubo; su fuerza por unidad de longitud se lee de la rigidez del tubo. Hormigón: muelles de Winkler verticales en cada nudo de la placa, activos solo en compresión; pernos: EA/L, activos solo en tracción. Se itera el conjunto activo hasta que no cambie.
#: **Juez.** **Abaqus** (shell S4 con las mismas mallas, muelles no lineales y el mismo reparto de cargas): se comparan los desplazamientos de los 161 nudos, la tracción de los pernos y las fuerzas de soldadura. No se usa IDEA StatiCa: se ha bloqueado su telemetría y no se apoya en su licencia.
#: **Unidades.** kN, m y kPa.

## 1 · Datos

#: **Material** (acero S355):
E = 210000000.0 'módulo de elasticidad del acero [kPa]
ν = 0.3 'coeficiente de Poisson
#: **Geometría.** Placa de 0.400 × 0.400 m y 25 mm; tubo SHS 200 × 200 × 10 (se modela su línea media: 0.190 × 0.190 m); se modelan 100 mm de altura del tubo. El momento actúa en el plano del lado de 200 mm (eje y); el lado comprimido es el de y positivo.
t_p = 0.025 'espesor de la placa [m]
t_c = 0.01 'espesor de la pared del tubo [m]
H_c = 0.1 'altura del tubo modelada [m]
n_z = 5 'filas de elementos en la altura del tubo
xs = [-0.2; -0.125; -0.095; -0.0475; 0.0; 0.0475; 0.095; 0.125; 0.2] 'líneas de la malla de la placa en x [m]
ys = [-0.2; -0.125; -0.095; -0.0475; 0.0; 0.0475; 0.095; 0.125; 0.2] 'líneas de la malla de la placa en y [m]
#: **Pernos y hormigón:**
A_b = 0.000353 'área resistente de un perno M24 [m2]
L_b = 0.3 'longitud libre del perno [m]
k_b = E·A_b/L_b 'rigidez axial de un perno, solo tracción [kN/m]
k_c = 60000000.0 'módulo de balasto del pedestal de hormigón, solo compresión [kN/m3]
#: Los cuatro pernos están en x = ± 0.125 m, y = ± 0.125 m.
#: **Cargas en la cabeza del tubo** (compresión y momento alrededor del eje x):
N_c = 300.0 'carga axial de compresión [kN]
M_x = 40.0 'momento alrededor de x [kN·m]

## 2 · El elemento de cáscara (ShellMITC4, hoja 72)

#: Sección elástica membrana + placa de espesor t, con cortante transversal κ = 5/6:
#hide
function d = LovelyEig(A)
  % R3vectors.cpp, LovelyEig (l.70-221): Jacobi 3×3 simétrica, solo la mitad superior
  tol = 1.0e-08
  a = [A(1, 2), A(2, 3), A(3, 1)]
  d = [A(1, 1), A(2, 2), A(3, 3)]
  b = [A(1, 1), A(2, 2), A(3, 3)]
  z = [0, 0, 0]
  its = 0
  sm = abs(a(1)) + abs(a(2)) + abs(a(3))
  while sm > tol
    if its < 3
      thresh = 0.011·sm
    else
      thresh = 0.0
    end
    for i = 1:3
      j = mod(i, 3) + 1
      k = mod(j, 3) + 1
      aij = a(i)
      g = 100.0·abs(aij)
      if abs(d(i)) + g ~= abs(d(i)) || abs(d(j)) + g ~= abs(d(j))
        if abs(aij) > thresh
          a(i) = 0.0
          hh = d(j) - d(i)
          if abs(hh) + g == abs(hh)
            t = aij/hh
          else
            r = hh/aij
            if r > 0.0
              t = 2.0/(r + sqrt(4.0 + r·r))
            else
              t = -2.0/(-r + sqrt(4.0 + r·r))
            end
          end
          c = 1.0/sqrt(1.0 + t·t)
          s = t·c
          tau = s/(1.0 + c)
          hh = t·aij
          z(i) = z(i) - hh
          z(j) = z(j) + hh
          d(i) = d(i) - hh
          d(j) = d(j) + hh
          hh = a(j)
          g = a(k)
          a(j) = hh + s·(g - hh·tau)
          a(k) = g - s·(hh + g·tau)
        end
      else
        a(i) = 0.0
      end
    end
    b = b + z
    d = b(1:3)
    % copia: «d = b» comparte memoria en la hoja y d(i) = … cambiaría también b
    z = [0, 0, 0]
    its = its + 1
    sm = abs(a(1)) + abs(a(2)) + abs(a(3))
  end
end

function K = mitc4_K(X, dd)
  % ShellMITC4.cpp, getInitialStiff (l.825-1102): puntos de Gauss (constructor l.270-283)
  sg = [-1, 1, 1, -1]/sqrt(3)
  tg = [-1, -1, 1, 1]/sqrt(3)
  % setDomain (l.388-401): K_tt = menor autovalor de la membrana
  lam = LovelyEig(dd(1:3, 1:3))
  Ktt = min(lam(3), min(lam(1), lam(2)))
  % computeBasis (l.1763-1845)
  v1 = 0.5·(((X(3, :) + X(2, :)) - X(4, :)) - X(1, :))
  v2 = 0.5·(((X(4, :) + X(3, :)) - X(2, :)) - X(1, :))
  g1 = v1/norm(v1)
  v2 = v2 - g1·dot(v2, g1)
  g2 = v2/norm(v2)
  g3 = [g1(2)·g2(3) - g1(3)·g2(2), g1(3)·g2(1) - g1(1)·g2(3), g1(1)·g2(2) - g1(2)·g2(1)]
  xl = zeros(2, 4)
  for i = 1:4
    xl(1, i) = dot(X(i, :), g1)
    xl(2, i) = dot(X(i, :), g2)
  end
  % getInitialStiff (l.874-935): G 4×12 de los puntos de amarre, Ax..Cy, Rot
  dx34 = xl(1, 3) - xl(1, 4)
  dy34 = xl(2, 3) - xl(2, 4)
  dx21 = xl(1, 2) - xl(1, 1)
  dy21 = xl(2, 2) - xl(2, 1)
  dx32 = xl(1, 3) - xl(1, 2)
  dy32 = xl(2, 3) - xl(2, 2)
  dx41 = xl(1, 4) - xl(1, 1)
  dy41 = xl(2, 4) - xl(2, 1)
  q = 0.25
  Gm = zeros(4, 12)
  Gm(1, 1) = -0.5
  Gm(1, 2) = -dy41·q
  Gm(1, 3) = dx41·q
  Gm(1, 10) = 0.5
  Gm(1, 11) = -dy41·q
  Gm(1, 12) = dx41·q
  Gm(2, 1) = -0.5
  Gm(2, 2) = -dy21·q
  Gm(2, 3) = dx21·q
  Gm(2, 4) = 0.5
  Gm(2, 5) = -dy21·q
  Gm(2, 6) = dx21·q
  Gm(3, 4) = -0.5
  Gm(3, 5) = -dy32·q
  Gm(3, 6) = dx32·q
  Gm(3, 7) = 0.5
  Gm(3, 8) = -dy32·q
  Gm(3, 9) = dx32·q
  Gm(4, 7) = 0.5
  Gm(4, 8) = -dy34·q
  Gm(4, 9) = dx34·q
  Gm(4, 10) = -0.5
  Gm(4, 11) = -dy34·q
  Gm(4, 12) = dx34·q
  Ax = -xl(1, 1) + xl(1, 2) + xl(1, 3) - xl(1, 4)
  Bx = xl(1, 1) - xl(1, 2) + xl(1, 3) - xl(1, 4)
  Cx = -xl(1, 1) - xl(1, 2) + xl(1, 3) + xl(1, 4)
  Ay = -xl(2, 1) + xl(2, 2) + xl(2, 3) - xl(2, 4)
  By = xl(2, 1) - xl(2, 2) + xl(2, 3) - xl(2, 4)
  Cy = -xl(2, 1) - xl(2, 2) + xl(2, 3) + xl(2, 4)
  alph = atan(Ay/Ax)
  bet = 3.141592653589793/2 - atan(Cx/Cy)
  Rot = [sin(bet), -sin(alph); -cos(bet), cos(alph)]
  % assembleB (l.1995-2117): Gmem 2×3 y Gshear 3×6
  Gmem = [g1; g2]
  Gshear = zeros(3, 6)
  Gshear(1, 1:3) = g3
  Gshear(2, 4:6) = g1
  Gshear(3, 4:6) = g2
  K = zeros(24, 24)
  for i = 1:4
    % l.942-950: r1, r2
    r1 = Cx + sg(i)·Bx
    r3 = Cy + sg(i)·By
    r1 = sqrt(r1·r1 + r3·r3)
    r2 = Ax + tg(i)·Bx
    r3 = Ay + tg(i)·By
    r2 = sqrt(r2·r2 + r3·r3)
    % shape2d (l.2187-2245): N, dN/dx, dN/dy locales y det J
    ss = sg(i)
    tt = tg(i)
    sn = [-0.5, 0.5, 0.5, -0.5]
    tn = [-0.5, -0.5, 0.5, 0.5]
    shp = zeros(3, 4)
    for n = 1:4
      shp(3, n) = (0.5 + sn(n)·ss)·(0.5 + tn(n)·tt)
      shp(1, n) = sn(n)·(0.5 + tn(n)·tt)
      shp(2, n) = tn(n)·(0.5 + sn(n)·ss)
    end
    xs = zeros(2, 2)
    for a = 1:2
      for b = 1:2
        for n = 1:4
          xs(a, b) = xs(a, b) + xl(a, n)·shp(b, n)
        end
      end
    end
    xsj = xs(1, 1)·xs(2, 2) - xs(1, 2)·xs(2, 1)
    jinv = 1.0/xsj
    sx = [xs(2, 2)·jinv, -xs(1, 2)·jinv; -xs(2, 1)·jinv, xs(1, 1)·jinv]
    for n = 1:4
      temp = shp(1, n)·sx(1, 1) + shp(2, n)·sx(2, 1)
      shp(2, n) = shp(1, n)·sx(1, 2) + shp(2, n)·sx(2, 2)
      shp(1, n) = temp
    end
    dvol = xsj
    % l.957-968: Ms·G escalada por r/(8·det J) y girada con Rot
    Ms = zeros(2, 4)
    Ms(2, 1) = 1 - sg(i)
    Ms(1, 2) = 1 - tg(i)
    Ms(2, 3) = 1 + sg(i)
    Ms(1, 4) = 1 + tg(i)
    Bsv = Ms·Gm
    Bsv(1, :) = Bsv(1, :)·r1/(8·xsj)
    Bsv(2, :) = Bsv(2, :)·r2/(8·xsj)
    Bs = Rot·Bsv
    % computeBmembrane (l.2121), computeBbend (l.2152), assembleB, computeBdrill (l.1929)
    B = zeros(8, 24)
    Bd = zeros(24, 1)
    for j = 1:4
      Bm = [shp(1, j), 0; 0, shp(2, j); shp(2, j), shp(1, j)]
      Bb = [0, -shp(1, j); shp(2, j), 0; shp(1, j), -shp(2, j)]
      c = 6·j - 5
      B(1:3, c:c + 2) = Bm·Gmem
      B(4:6, c + 3:c + 5) = Bb·Gmem
      B(7:8, c:c + 5) = Bs(:, 3·j - 2:3·j)·Gshear
      Bd(c:c + 2) = -0.5·shp(2, j)·g1 + 0.5·shp(1, j)·g2
      Bd(c + 3:c + 5) = -shp(3, j)·g3
    end
    % l.1022-1026: flexión de B_J por (−1)
    BJ = B
    for j = 1:4
      c = 6·j - 5
      BJ(4:6, c + 3:c + 5) = -BJ(4:6, c + 3:c + 5)
    end
    % l.1060-1095: K += B_J'·(dd·dvol)·B_K + (Ktt·dvol)·b_J·b_K
    K = K + BJ'·(dd·dvol)·B + (Ktt·dvol)·(Bd·Bd')
  end
end
function dd = seccion(E, nu, t)
  Mm = E/(1 - nu^2)·t
  G = 0.5·E/(1 + nu)·t
  Gs = G·(5/6)
  D = E·t^3/12/(1 - nu^2)
  dd = zeros(8, 8)
  dd(1, 1) = Mm
  dd(2, 2) = Mm
  dd(1, 2) = nu·Mm
  dd(2, 1) = nu·Mm
  dd(3, 3) = G
  dd(4, 4) = -D
  dd(5, 5) = -D
  dd(4, 5) = -nu·D
  dd(5, 4) = -nu·D
  dd(6, 6) = -0.5·D·(1 - nu)
  dd(7, 7) = Gs
  dd(8, 8) = Gs
end
#show
dd_p = seccion(E, ν, t_p) 'sección de la placa
dd_c = seccion(E, ν, t_c) 'sección de la pared del tubo

## 3 · La malla

#: **Placa:** 8 × 8 elementos (81 nudos, z = 0). **Tubo:** 16 tramos de perímetro por 5 filas (80 nudos más; los de la fila de abajo son los de la placa: ahí está la soldadura). Los nudos del perímetro del tubo caen en las líneas de la malla de la placa que pasan por su línea media.
n_x = 9 'líneas por lado de la placa
n_p = 81 'nudos de la placa
n_n = 161 'nudos totales
n_e = 144 'elementos: 64 de placa y 80 de tubo
#hide
Xn = zeros(n_n, 3)
for j = 1:n_x
  for i = 1:n_x
    q = (j - 1)·n_x + i
    Xn(q, 1) = xs(i)
    Xn(q, 2) = ys(j)
  end
end
#: Perímetro del tubo: lado inferior (+x), derecho (+y), superior (−x), izquierdo (−y). Índices de línea 3 … 7.
pi_x = [3, 4, 5, 6, 7, 7, 7, 7, 7, 6, 5, 4, 3, 3, 3, 3] 'índice de línea en x de cada punto del perímetro
pi_y = [3, 3, 3, 3, 3, 4, 5, 6, 7, 7, 7, 7, 7, 6, 5, 4] 'índice de línea en y
Pn = zeros(16, 1)
for k = 1:16
  Pn(k) = (pi_y(k) - 1)·n_x + pi_x(k)
end
for l = 1:n_z
  for k = 1:16
    q = n_p + (l - 1)·16 + k
    Xn(q, 1) = xs(pi_x(k))
    Xn(q, 2) = ys(pi_y(k))
    Xn(q, 3) = H_c·l/n_z
  end
end
En = zeros(n_e, 4)
for j = 1:8
  for i = 1:8
    e = (j - 1)·8 + i
    q = (j - 1)·n_x + i
    En(e, :) = [q, q + 1, q + n_x + 1, q + n_x]
  end
end
function q = nodo_tubo(l, k, Pn, n_p)
  if l == 0
    q = Pn(k)
  else
    q = n_p + (l - 1)·16 + k
  end
end
e = 64
for l = 1:n_z
  for k = 1:16
    k2 = mod(k, 16) + 1
    e = e + 1
    En(e, :) = [nodo_tubo(l - 1, k, Pn, n_p), nodo_tubo(l - 1, k2, Pn, n_p), nodo_tubo(l, k2, Pn, n_p), nodo_tubo(l, k, Pn, n_p)]
  end
end
#show
Xn_b = Xn(1:3, :) 'primeros nudos: z = 0, en la esquina de la placa

## 4 · Ensamblaje de la rigidez

#: Seis grados de libertad por nudo: u_x, u_y, u_z, θ_x, θ_y, θ_z (los del nudo q son 6(q − 1) + 1 … 6). Cada elemento suma su matriz de 24 × 24 en las filas y columnas de sus cuatro nudos; los nudos compartidos del borde del tubo son la **soldadura**.
n_g = 6·n_n 'grados de libertad
#hide
K = zeros(n_g, n_g)
function g = gdl(q)
  g = 6·(q - 1) + (1:6)
end
for e = 1:n_e
  q = En(e, :)
  Xe = [Xn(q(1), :); Xn(q(2), :); Xn(q(3), :); Xn(q(4), :)]
  if e <= 64
    Ke = mitc4_K(Xe, dd_p)
  else
    Ke = mitc4_K(Xe, dd_c)
  end
  g = [gdl(q(1)), gdl(q(2)), gdl(q(3)), gdl(q(4))]
  K(g, g) = K(g, g) + Ke
end
#show

## 5 · Los apoyos: hormigón solo a compresión y pernos solo a tracción

#: Cada nudo de la placa lleva un muelle vertical de rigidez k_c por su **área tributaria**. Los pernos están en los cuatro nudos de las líneas 2 y 8, con rigidez k_b. Para que el modelo no flote en el plano: se fijan u_x y u_y en el centro de la placa y u_y en el centro del borde x = + L_x.
#hide
kc_i = zeros(n_p, 1)
for j = 1:n_x
  for i = 1:n_x
    i0 = max(i - 1, 1)
    i1 = min(i + 1, n_x)
    j0 = max(j - 1, 1)
    j1 = min(j + 1, n_x)
    kc_i((j - 1)·n_x + i) = k_c·(xs(i1) - xs(i0))/2·(ys(j1) - ys(j0))/2
  end
end
kb_i = zeros(n_p, 1)
nb = [(2 - 1)·n_x + 2, (2 - 1)·n_x + 8, (8 - 1)·n_x + 2, (8 - 1)·n_x + 8]
for m = 1:4
  kb_i(nb(m)) = k_b
end
#show
#: Nudos de los pernos:
nb

## 6 · Las cargas

#: Se reparten en los 16 nudos de la cabeza del tubo con la distribución lineal de esfuerzos σ = −N/A − M·y/I de la sección (A = Σ a_k, I = Σ a_k·y_k², a_k = longitud tributaria × t_c): la resultante es exactamente N y M. La longitud tributaria de cada nudo es la mitad de los dos tramos que lo rodean.
#hide
ell = zeros(16, 1)
yk = zeros(16, 1)
for k = 1:16
  k0 = mod(k + 14, 16) + 1
  k2 = mod(k, 16) + 1
  d0 = sqrt((xs(pi_x(k)) - xs(pi_x(k0)))^2 + (ys(pi_y(k)) - ys(pi_y(k0)))^2)
  d2 = sqrt((xs(pi_x(k)) - xs(pi_x(k2)))^2 + (ys(pi_y(k)) - ys(pi_y(k2)))^2)
  ell(k) = (d0 + d2)/2
  yk(k) = ys(pi_y(k))
end
function Fc = carga(N, M, yk, ell, n_p, n_z, n_g, t_c)
  A_t = 0
  I_t = 0
  for k = 1:16
    A_t = A_t + ell(k)·t_c
    I_t = I_t + ell(k)·t_c·yk(k)^2
  end
  Fc = zeros(n_g, 1)
  for k = 1:16
    q = n_p + (n_z - 1)·16 + k
    Fc(6·(q - 1) + 3) = (-N/A_t - M·yk(k)/I_t)·ell(k)·t_c
  end
end
F = carga(N_c, M_x, yk, ell, n_p, n_z, n_g, t_c)
A_t = 0
I_t = 0
for k = 1:16
  A_t = A_t + ell(k)·t_c
  I_t = I_t + ell(k)·t_c·yk(k)^2
end
#show
A_t 'área de la sección del tubo [m2]
I_t 'inercia discreta del tubo [m4]
S_F = sum(F) 'resultante vertical de las cargas [kN] (debe ser −N)

## 7 · Solución: conjunto activo de muelles

#: Se resuelve con todos los muelles de hormigón activos y ningún perno; después se **apagan** los de hormigón que suben (u_z > 0) y se **encienden** los pernos que suben, y se repite hasta que el conjunto no cambia.
#hide
function Uc = resuelve(K, Fc, kc_i, kb_i, n_p, n_g)
  c_on = ones(n_p, 1)
  b_on = zeros(n_p, 1)
  cambia = 1
  iters = 0
  Uc = zeros(n_g, 1)
  while cambia > 0 && iters < 30
    Kt = K
    for q = 1:n_p
      d3 = 6·(q - 1) + 3
      Kt(d3, d3) = Kt(d3, d3) + c_on(q)·kc_i(q) + b_on(q)·kb_i(q)
    end
    for d = [6·(41 - 1) + 1, 6·(41 - 1) + 2, 6·(45 - 1) + 2]
      Kt(d, :) = 0
      Kt(:, d) = 0
      Kt(d, d) = 1
    end
    Ft = Fc
    for d = [6·(41 - 1) + 1, 6·(41 - 1) + 2, 6·(45 - 1) + 2]
      Ft(d) = 0
    end
    Uc = clsolve(Kt, Ft)
    cambia = 0
    for q = 1:n_p
      uz = Uc(6·(q - 1) + 3)
      if c_on(q) == 1 && uz > 0
        c_on(q) = 0
        cambia = cambia + 1
      end
      if c_on(q) == 0 && uz < 0
        c_on(q) = 1
        cambia = cambia + 1
      end
      if kb_i(q) > 0
        if b_on(q) == 0 && uz > 0
          b_on(q) = 1
          cambia = cambia + 1
        end
        if b_on(q) == 1 && uz < 0
          b_on(q) = 0
          cambia = cambia + 1
        end
      end
    end
    iters = iters + 1
  end
end
U = resuelve(K, F, kc_i, kb_i, n_p, n_g)
c_on = zeros(n_p, 1)
b_on = zeros(n_p, 1)
for q = 1:n_p
  if U(6·(q - 1) + 3) < 0
    c_on(q) = 1
  end
  if U(6·(q - 1) + 3) > 0 && kb_i(q) > 0
    b_on(q) = 1
  end
end
#show

## 8 · Resultados

#hide
Rc = zeros(n_p, 1)
Rb = zeros(n_p, 1)
uz_p = zeros(n_p, 1)
pres = zeros(n_p, 1)
for q = 1:n_p
  uz_p(q) = U(6·(q - 1) + 3)
  Rc(q) = -c_on(q)·kc_i(q)·uz_p(q)
  Rb(q) = -b_on(q)·kb_i(q)·uz_p(q)
  pres(q) = Rc(q)/(kc_i(q)/k_c)
end
#show
R_conc = sum(Rc) 'reacción total del hormigón (hacia arriba) [kN]
T_b = sum(Rb) 'fuerza total de los pernos (hacia abajo: negativa) [kN]
equil = R_conc + T_b + S_F 'equilibrio vertical: debe ser 0 [kN]
sig_max = max(pres)/1000 'presión máxima de contacto [MPa]
n_lev = n_p - sum(c_on) 'nudos de la placa levantados del hormigón
T_1 = -min(Rb) 'tracción del perno más cargado [kN]
#: **Pedestal.** Resistencia de contacto del hormigón f_cd = 25/1.5 y factor de confinamiento k_j = √(A_pedestal/A_placa) ≤ 3, con el pedestal de 0.50 × 0.50 m:
f_cd = 25/1.5 'resistencia de cálculo del hormigón [MPa]
k_j = min(3, sqrt(0.2500/(0.4000·0.4000))) 'factor de confinamiento
rat_c = sig_max/(k_j·f_cd) 'aprovechamiento del contacto
#: **Perno.** Resistencia a tracción de un M24 de clase 8.8: 0.9·f_ub·A_s/γ_M2 con f_ub = 800 MPa y γ_M2 = 1.25:
F_tRd = 0.9·800000·A_b/1.25 'resistencia a tracción de un perno [kN]
rat_b = T_1/F_tRd 'aprovechamiento del perno

## 9 · La soldadura tubo-placa

#: Los elementos del tubo de la fila de abajo transmiten a la placa, por cada nudo del perímetro, tres fuerzas (axial y dos de corte). Dividida por la longitud tributaria da la **fuerza por unidad de longitud** de soldadura q_w. La garganta necesaria para una soldadura en ángulo exterior (EN 1993-1-8, método simplificado) es a = q_w / f_vw,d con f_vw,d = f_u/(√3·β_w·γ_M2), f_u = 510 MPa, β_w = 0.90 (S355), γ_M2 = 1.25:
#hide
Fw = zeros(16, 3)
for e = 65:80
  q = En(e, :)
  Xe = [Xn(q(1), :); Xn(q(2), :); Xn(q(3), :); Xn(q(4), :)]
  Ke = mitc4_K(Xe, dd_c)
  g = [gdl(q(1)), gdl(q(2)), gdl(q(3)), gdl(q(4))]
  ug = zeros(24, 1)
  for r = 1:24
    ug(r) = U(g(r))
  end
  fe = Ke·ug
  k1 = e - 64
  k2 = mod(k1, 16) + 1
  for c3 = 1:3
    Fw(k1, c3) = Fw(k1, c3) + fe(c3)
    Fw(k2, c3) = Fw(k2, c3) + fe(6 + c3)
  end
end
qw = zeros(16, 1)
for k = 1:16
  qw(k) = sqrt(Fw(k, 1)^2 + Fw(k, 2)^2 + Fw(k, 3)^2)/ell(k)
end
#show
S_wz = sum(Fw(:, 3)) 'suma de las fuerzas verticales que baja la soldadura a la placa [kN]
q_w = max(qw) 'fuerza máxima por unidad de longitud de soldadura [kN/m]
f_vwd = 510000/(sqrt(3)·0.9·1.25) 'resistencia de cálculo a cortante de la soldadura [kPa]
a_req = q_w/f_vwd·1000 'garganta necesaria [mm]

## 10 · El método analítico de AISC (Guía de Diseño 1): la placa como voladizo

#: **La idea.** AISC trata la placa como un **voladizo** que sale de la cara del tubo: la presión del hormigón (un bloque uniforme de resistencia f_p) la dobla hacia arriba; si el momento es grande, la placa se levanta de un lado y la **tracción de los pernos** la dobla hacia abajo. El espesor sale de pedir que el momento por unidad de ancho no pase de la resistencia plástica t²·F_y/4. Para una columna **hueca cuadrada o rectangular** la Guía de Diseño 1 mide los voladizos hasta 0.95 veces el lado del tubo: m = (N − 0.95·d)/2 en el plano del momento y n = (B − 0.95·b)/2 en el otro; manda el mayor.
#: **Datos del método** (LRFD): placa N × B = 0.400 × 0.400 m, tubo de 0.200 × 0.200 m (d × b), F_y = 355 MPa, f′_c = 25 MPa sobre un pedestal de 0.50 × 0.50 m, pernos a f = 0.125 m del eje en el plano del momento:
N_p = 0.4 'dimensión de la placa en el plano del momento [m]
B_p = 0.4 'ancho de la placa [m]
d_t = 0.2 'lado del tubo en el plano del momento [m]
b_t = 0.2 'lado del tubo en el otro sentido [m]
F_y = 355000 'límite elástico de la placa [kPa]
fc_p = 25000 'resistencia del hormigón f′_c [kPa]
A_ped = 0.25 'área del pedestal [m2]
f_b = 0.125 'distancia del eje a los pernos, en el plano del momento [m]
#: **Resistencia de contacto** (φ_c = 0.65; el factor de confinamiento √(A₂/A₁) no pasa de 2):
f_pmax = 0.65·0.85·fc_p·min(2, sqrt(A_ped/(N_p·B_p))) 'presión máxima de contacto de cálculo [kPa]
q_max = f_pmax·B_p 'carga máxima por metro de la placa [kN/m]
m_c = (N_p - 0.95·d_t)/2 'voladizo en el plano del momento, hasta 0.95 del lado del tubo [m]
n_c = (B_p - 0.95·b_t)/2 'voladizo en el otro sentido [m]
u_t = f_b - 0.95·d_t/2 'del perno a la cara del tubo [m]
#hide
function R = aisc(P, M, N_p, B_p, f_b, f_pmax, q_max, m_c, u_t, F_y)
  e = M/P
  e_cr = N_p/2 - P/(2·q_max)
  if e <= e_cr
    Y = N_p - 2·e
    T = 0
    f_p = P/(Y·B_p)
  else
    Y = (f_b + N_p/2) - sqrt((f_b + N_p/2)^2 - 2·P·(e + f_b)/q_max)
    T = q_max·Y - P
    f_p = f_pmax
  end
  if Y >= m_c
    Mc = f_p·m_c^2/2
  else
    Mc = f_p·Y·(m_c - Y/2)
  end
  Mt = T·u_t/B_p
  t_r = sqrt(4·max(Mc, Mt)/(0.9·F_y))
  R = [e; e_cr; Y; T; f_p; Mc; Mt; t_r]
end
#show
A_r = aisc(N_c, M_x, N_p, B_p, f_b, f_pmax, q_max, m_c, u_t, F_y) 'e · e_crít · Y · T · f_p · M_contacto · M_perno · t_req
#: **Excentricidad.** e = M/P se compara con la crítica e_crít = N/2 − P/(2·q_max): por debajo, la placa solo comprime (longitud de apoyo Y = N − 2e, bloque uniforme f_p = P/(Y·B)); por encima, la placa se levanta, los pernos de ese lado trabajan con T = q_max·Y − P y Y sale de la ecuación de momentos respecto de los pernos.
e_a = A_r(1) 'excentricidad e = M/P [m]
e_crit = A_r(2) 'excentricidad crítica [m]
Y_a = A_r(3) 'longitud de apoyo [m]
T_a = A_r(4) 'tracción total de los pernos de un lado [kN]
t_a = A_r(8)·1000 'espesor de placa necesario por AISC [mm]

## 11 · Lo mismo por elementos finitos, barriendo el momento

#: Con el modelo por elementos finitos se repite el cálculo para momentos de 0 a 90 kN·m con la misma carga axial. De cada solución se leen los **mismos números** que da AISC: la tracción de los pernos, el momento de voladizo por unidad de ancho en la cara del tubo (a partir de las reacciones del hormigón y de los pernos) y el espesor que resulta de él.
#hide
function R = post(Uc, kc_i, kb_i, ys, n_p, n_x, B_p, y_s)
  Rc_t = 0
  Tb = 0
  nl = 0
  Mp = 0
  Mn = 0
  for j = 1:n_x
    for i = 1:n_x
      q = (j - 1)·n_x + i
      uz = Uc(6·(q - 1) + 3)
      rc = 0
      rb = 0
      if uz < 0
        rc = -kc_i(q)·uz
      else
        nl = nl + 1
        if kb_i(q) > 0
          rb = kb_i(q)·uz
        end
      end
      Rc_t = Rc_t + rc
      Tb = Tb + rb
      if ys(j) > y_s + 1e-9
        Mp = Mp + (rc - rb)·(ys(j) - y_s)
      end
      if ys(j) < -y_s - 1e-9
        Mn = Mn + (rc - rb)·(-ys(j) - y_s)
      end
    end
  end
  R = [Rc_t; Tb; nl; abs(Mp)/B_p; abs(Mn)/B_p]
end
y_s = ys(7) 'cara del tubo (línea media), donde empieza el voladizo [m]
n_m = 10
ms = zeros(n_m, 1)
for s = 1:n_m
  ms(s) = (s - 1)·90.0/9
end
Tm = zeros(n_m, 2)
Tr = zeros(n_m, 2)
Ym = zeros(n_m, 2)
TmA = zeros(n_m, 2)
for s = 1:n_m
  Fs = carga(N_c, ms(s), yk, ell, n_p, n_z, n_g, t_c)
  Us = resuelve(K, Fs, kc_i, kb_i, n_p, n_g)
  Ps = post(Us, kc_i, kb_i, ys, n_p, n_x, B_p, y_s)
  As = aisc(N_c, ms(s), N_p, B_p, f_b, f_pmax, q_max, m_c, u_t, F_y)
  Tm(s, 1) = ms(s)
  Tm(s, 2) = Ps(2)
  Tr(s, 1) = ms(s)
  Tr(s, 2) = 1000·sqrt(4·max(Ps(4), Ps(5))/(0.9·F_y))
  Ym(s, 1) = ms(s)
  Ym(s, 2) = 1000·As(8)
  TmA(s, 1) = ms(s)
  TmA(s, 2) = As(4)
end
#show

#: **Gráfica 1. Tracción total de los pernos de un lado frente al momento** (N = 300 kN). Los puntos azules son el cálculo por elementos finitos (placa elástica con muelles); los naranjas, el método de AISC (bloque rígido-plástico). AISC no da tracción hasta que e = M/P pasa de e_crít; por elementos finitos la placa se **flexiona** y los pernos empiezan a trabajar antes, porque la presión no es un bloque uniforme sino que crece hacia el borde comprimido.
#fplot(FEM = Tm, AISC = TmA, [0 90])
#: **Gráfica 2. Espesor de placa necesario frente al momento** (mm). Azul: el que sale del momento de voladizo leído en el modelo de elementos finitos; naranja: AISC. La placa real es de 25 mm.
#fplot(FEM = Tr, AISC = Ym, [0 90])

#: **Gráfica 3. La presión bajo la placa, a lo largo de su línea central, con M = 72 kN·m.** Los puntos azules son la presión de contacto por elementos finitos (MPa); los naranjas, el bloque uniforme de AISC sobre la longitud de apoyo Y. El borde comprimido está en y = +0.200 m. Se ve la diferencia de fondo: AISC reparte la carga en un **bloque plano** y por eso necesita más espesor; por elementos finitos la presión **crece hacia el borde** y el momento de voladizo es menor.
#hide
Ug = resuelve(K, carga(N_c, 72, yk, ell, n_p, n_z, n_g, t_c), kc_i, kb_i, n_p, n_g)
Ag = aisc(N_c, 72, N_p, B_p, f_b, f_pmax, q_max, m_c, u_t, F_y)
Pc = zeros(n_x, 2)
for j = 1:n_x
  q = (j - 1)·n_x + 5
  Pc(j, 1) = ys(j)
  Pc(j, 2) = max(0, -k_c·Ug(6·(q - 1) + 3))/1000
end
Pa = zeros(41, 2)
for s = 1:41
  yy = -0.2 + (s - 1)·0.2/20
  Pa(s, 1) = yy
  if yy >= 0.2 - Ag(3) - 1e-9
    Pa(s, 2) = Ag(5)/1000
  end
end
#show
Y_g = Ag(3) 'longitud de apoyo de AISC con ese momento [m]
T_g = Ag(4) 'tracción de AISC con ese momento [kN]
#fplot(FEM = Pc, AISC = Pa, [-0.2 0.2])

## 12 · Comparación para el caso de la hoja (N = 300 kN, M = 40 kN·m)

#hide
Pf = post(U, kc_i, kb_i, ys, n_p, n_x, B_p, y_s)
#show
T_fem = Pf(2) 'tracción total de los pernos (FEM) [kN]
M_fem = max(Pf(4), Pf(5)) 'momento de voladizo por unidad de ancho (FEM) [kN·m/m]
t_fem = 1000·sqrt(4·M_fem/(0.9·F_y)) 'espesor necesario (FEM) [mm]
M_aisc = max(A_r(6), A_r(7)) 'momento de voladizo por unidad de ancho (AISC) [kN·m/m]
#: **Qué dice cada método.** AISC: bloque uniforme de presión sobre la longitud de apoyo Y y, si e > e_crít, tracción en los pernos. Elementos finitos: la placa se deforma, la presión es lineal y los pernos se activan a medida que la placa los levanta. Los dos dan el espesor con la misma regla (voladizo plástico t² F_y/4 = M).
#: **Comparación con otros dos programas** (mismo modelo: mismos 161 nudos, mismas cargas, hormigón solo a compresión y pernos solo a tracción). **Abaqus**: cáscara S4 y muelles no lineales, corrido por línea de órdenes. **IDEA StatiCa**: su solver de elementos finitos CBFEM (k2fem64, cáscara CQUAD4 y contacto con elementos gap), corrido sin conexión y sin su programa; **no es el modelo propio de IDEA de la conexión**, es su solver con este mismo modelo. La columna de la hoja es el cálculo de arriba; las otras dos se dan como referencia, no se usan en el cálculo.
#: - **Tracción total de los pernos** (kN): hoja 56.96 · Abaqus 57.07 · IDEA 57.45 · AISC 0 (supone la placa rígida y sin despegue: e < e_crít)
#: - **Reacción total del hormigón** (kN): hoja 356.96 · Abaqus 357.07 · IDEA 357.45
#: - **Flecha máxima hacia arriba de la placa** (mm): hoja 0.2869 · Abaqus 0.2939 · IDEA 0.2957
#: - **Flecha máxima hacia abajo de la placa** (mm): hoja -0.1598 · Abaqus -0.1607 · IDEA -0.1648
#: - **Elevación del perno más cargado** (mm): hoja 0.1153 · Abaqus 0.1155 · IDEA 0.1162
#: - **Equilibrio vertical** (suma de reacciones, con N = 300 kN): hoja 300.000 · Abaqus 300.000 · IDEA 300.0006
#: - **Tensión de Von Mises máxima en la placa** (MPa): hoja 105.20 · Abaqus 103.34
#: - **Fuerza de soldadura máxima por nudo** (kN): hoja 81.96 · Abaqus 81.47
#: Los tres modelos de elementos finitos coinciden dentro de 1 % en las fuerzas (pernos, hormigón, soldadura) y de 3 % en la flecha máxima; las diferencias salen de la formulación de la cáscara de cada programa. **AISC es de otra familia**: sin despegue de la placa no hay tracción en los pernos y el momento de voladizo es el de la sección 16 (M_aisc), más del doble del que da la cáscara.

## 13 · La unión dibujada

#: **Sección acotada** por el plano del momento: la placa sobre el pedestal, el tubo hueco y los pernos. m es el voladizo de la placa hasta 0.95 del lado del tubo; u, la distancia del perno a esa cara.
#dibujo("Placa base de columna tubular: sección por el plano del momento", ud = m, escala = auto, cotas = m, ancho = 190, alto = 150)
#  rect(-0.25, -0.4, 0.5, 0.4, "gruesa")
#  rect(-0.2, 0, 0.4, t_p, "gruesa")
#  achurado(-0.2, 0, 0.4, t_p, "acero")
#  poligono(-0.1, t_p, -0.09000000000000001, t_p, -0.09000000000000001, 0.30, -0.1, 0.30, "gruesa")
#  poligono(0.09000000000000001, t_p, 0.1, t_p, 0.1, 0.30, 0.09000000000000001, 0.30, "gruesa")
#  linea(-0.125, -0.28, -0.125, 0.055, "gruesa verde")
#  linea(0.125, -0.28, 0.125, 0.055, "gruesa verde")
#  texto(0.0, 0.34, "tubo hueco SHS 200 × 200 × 10", 3, "c")
#  texto(0.0, -0.46, "pedestal de hormigón 0.50 × 0.50 m", 3, "c")
#  texto(0.155, -0.1, "perno M24", 2.6, "i", estilo = "verde")
#  flecha(0.0, 0.52, 0.0, 0.32, "rojo")
#  texto(0.02, 0.50, "N = 300 kN · M = 40 kN·m", 2.6, "i", estilo = "rojo")
#  cota(-0.2, -0.52, 0.2, -0.52, -0.04, "0.400")
#  cota(0.095, 0.06, 0.2, 0.06, 0.03, "m = 0.105")
#  cota(0.095, -0.22, 0.125, -0.22, -0.03, "u = 0.030")
#  cota(0.0, -0.14, 0.125, -0.14, -0.03, "f = 0.125")
#  cota(0.24000000000000002, 0, 0.24000000000000002, t_p, 0.03, "25 mm")
#fin

#: **Planta acotada**: la placa, el tubo, los cuatro pernos y la malla de la placa (la fila de nudos del borde del tubo es la soldadura).
#dibujo("Planta de la placa base: tubo, pernos y malla de elementos finitos", ud = m, escala = auto, cotas = m, ancho = 150, alto = 170)
#  rect(-0.2, -0.2, 0.4, 0.4, "gruesa")
#  rect(-0.1, -0.1, 0.2, 0.2, "media rojo")
#  rect(-0.09000000000000001, -0.09000000000000001, 0.18000000000000002, 0.18000000000000002, "media rojo")
#  circulo(-0.125, -0.125, 0.012, "gruesa verde")
#  circulo(-0.125, 0.125, 0.012, "gruesa verde")
#  circulo(0.125, -0.125, 0.012, "gruesa verde")
#  circulo(0.125, 0.125, 0.012, "gruesa verde")
#  linea(-0.2, -0.2, -0.2, 0.2, "fina gris")
#  linea(-0.125, -0.2, -0.125, 0.2, "fina gris")
#  linea(-0.095, -0.2, -0.095, 0.2, "fina gris")
#  linea(-0.0475, -0.2, -0.0475, 0.2, "fina gris")
#  linea(0.0, -0.2, 0.0, 0.2, "fina gris")
#  linea(0.0475, -0.2, 0.0475, 0.2, "fina gris")
#  linea(0.095, -0.2, 0.095, 0.2, "fina gris")
#  linea(0.125, -0.2, 0.125, 0.2, "fina gris")
#  linea(0.2, -0.2, 0.2, 0.2, "fina gris")
#  linea(-0.2, -0.2, 0.2, -0.2, "fina gris")
#  linea(-0.2, -0.125, 0.2, -0.125, "fina gris")
#  linea(-0.2, -0.095, 0.2, -0.095, "fina gris")
#  linea(-0.2, -0.0475, 0.2, -0.0475, "fina gris")
#  linea(-0.2, 0.0, 0.2, 0.0, "fina gris")
#  linea(-0.2, 0.0475, 0.2, 0.0475, "fina gris")
#  linea(-0.2, 0.095, 0.2, 0.095, "fina gris")
#  linea(-0.2, 0.125, 0.2, 0.125, "fina gris")
#  linea(-0.2, 0.2, 0.2, 0.2, "fina gris")
#  texto(0.0, 0.0, "tubo", 2.6, "c", estilo = "rojo")
#  texto(0.13, 0.15, "pernos M24", 2.6, "c", estilo = "verde")
#  texto(0.0, 0.245, "borde comprimido (+y)", 2.6, "c")
#  cota(-0.2, -0.25, 0.2, -0.25, -0.04, "0.400")
#  cota(0.25, -0.2, 0.25, 0.2, 0.04, "0.400")
#  cota(-0.1, -0.115, 0.1, -0.115, -0.03, "0.200")
#fin

## 14 · La presión y la deformada de la placa

#: **Mapa de presión de contacto** (kPa) en la planta de la placa, con el caso de la hoja: el hormigón trabaja solo en el lado comprimido (y positivo); la zona en cero es la que se despega. Con el cursor se lee el valor.
#hide
P_m = zeros(n_x, n_x)
for j = 1:n_x
  for i = 1:n_x
    P_m(i, j) = pres((j - 1)·n_x + i)
  end
end
n_f = 21
P_f = zeros(n_f, n_f)
for jf = 1:n_f
  for if_ = 1:n_f
    xq = -0.2 + (if_ - 1)·0.2/10
    yq = -0.2 + (jf - 1)·0.2/10
    i0 = 1
    for i = 1:n_x - 1
      if xs(i) <= xq + 1e-9
        i0 = i
      end
    end
    j0 = 1
    for j = 1:n_x - 1
      if ys(j) <= yq + 1e-9
        j0 = j
      end
    end
    tx = (xq - xs(i0))/(xs(i0 + 1) - xs(i0))
    ty = (yq - ys(j0))/(ys(j0 + 1) - ys(j0))
    P_f(if_, jf) = (1 - tx)·(1 - ty)·P_m(i0, j0) + tx·(1 - ty)·P_m(i0 + 1, j0) + (1 - tx)·ty·P_m(i0, j0 + 1) + tx·ty·P_m(i0 + 1, j0 + 1)
  end
end
#show
p_xy(x, y) = spline(1 + (x + 0.2)/(0.2/10), 1 + (y + 0.2)/(0.2/10), P_f)
#map(p_xy(x, y), [-0.2 0.2], [-0.2 0.2])
#: **Tensión de la placa.** Con los giros de cada elemento se calculan las curvaturas en su centro (κ₁₁ = −∂θ_y/∂x, κ₂₂ = ∂θ_x/∂y, κ₁₂ = ∂θ_x/∂x − ∂θ_y/∂y), los momentos por unidad de ancho m = D·[κ₁₁ + νκ₂₂, νκ₁₁ + κ₂₂, (1 − ν)/2·κ₁₂] con D = E·t³/(12·(1 − ν²)), y las tensiones de la fibra extrema σ = 6·m/t². Se muestra la tensión equivalente de Von Mises (en MPa) promediada en los nudos de la placa:
#hide
sv_n = zeros(n_p, 1)
cn_n = zeros(n_p, 1)
D_p = E·t_p^3/12/(1 - ν^2)
sig_el = zeros(64, 1)
for e = 1:64
  q = En(e, :)
  dxi = [-0.25, 0.25, 0.25, -0.25]
  det_ = [-0.25, -0.25, 0.25, 0.25]
  j11 = 0
  j12 = 0
  j21 = 0
  j22 = 0
  for r = 1:4
    j11 = j11 + dxi(r)·Xn(q(r), 1)
    j12 = j12 + dxi(r)·Xn(q(r), 2)
    j21 = j21 + det_(r)·Xn(q(r), 1)
    j22 = j22 + det_(r)·Xn(q(r), 2)
  end
  dj = j11·j22 - j12·j21
  k11 = 0
  k22 = 0
  k12 = 0
  for r = 1:4
    dnx = (j22·dxi(r) - j12·det_(r))/dj
    dny = (-j21·dxi(r) + j11·det_(r))/dj
    tx = U(6·(q(r) - 1) + 4)
    ty = U(6·(q(r) - 1) + 5)
    k11 = k11 - dnx·ty
    k22 = k22 + dny·tx
    k12 = k12 + dnx·tx - dny·ty
  end
  m11 = D_p·(k11 + ν·k22)
  m22 = D_p·(ν·k11 + k22)
  m12 = D_p·(1 - ν)/2·k12
  sx = 6·m11/t_p^2
  sy = 6·m22/t_p^2
  txy = 6·m12/t_p^2
  svm = sqrt(sx^2 - sx·sy + sy^2 + 3·txy^2)/1000
  sig_el(e) = svm
  for r = 1:4
    sv_n(q(r)) = sv_n(q(r)) + svm
    cn_n(q(r)) = cn_n(q(r)) + 1
  end
end
S_m = zeros(n_x, n_x)
W_m = zeros(n_x, n_x)
for j = 1:n_x
  for i = 1:n_x
    q = (j - 1)·n_x + i
    sv_n(q) = sv_n(q)/cn_n(q)
    S_m(i, j) = sv_n(q)
    W_m(i, j) = 1000·U(6·(q - 1) + 3)
  end
end
S_f = zeros(n_f, n_f)
W_f = zeros(n_f, n_f)
for jf = 1:n_f
  for if_ = 1:n_f
    xq = -0.2 + (if_ - 1)·0.2/10
    yq = -0.2 + (jf - 1)·0.2/10
    i0 = 1
    for i = 1:n_x - 1
      if xs(i) <= xq + 1e-9
        i0 = i
      end
    end
    j0 = 1
    for j = 1:n_x - 1
      if ys(j) <= yq + 1e-9
        j0 = j
      end
    end
    tx = (xq - xs(i0))/(xs(i0 + 1) - xs(i0))
    ty = (yq - ys(j0))/(ys(j0 + 1) - ys(j0))
    S_f(if_, jf) = (1 - tx)·(1 - ty)·S_m(i0, j0) + tx·(1 - ty)·S_m(i0 + 1, j0) + (1 - tx)·ty·S_m(i0, j0 + 1) + tx·ty·S_m(i0 + 1, j0 + 1)
    W_f(if_, jf) = (1 - tx)·(1 - ty)·W_m(i0, j0) + tx·(1 - ty)·W_m(i0 + 1, j0) + (1 - tx)·ty·W_m(i0, j0 + 1) + tx·ty·W_m(i0 + 1, j0 + 1)
  end
end
#show
sig_max_p = max(sv_n) 'tensión de Von Mises máxima en la placa (promedio de nudos) [MPa]
sig_el_max = max(sig_el) 'tensión de Von Mises máxima en el centro de un elemento [MPa]
rat_f = sig_el_max/355 'aprovechamiento de la placa frente al límite elástico de 355 MPa
s_xy(x, y) = spline(1 + (x + 0.2)/(0.2/10), 1 + (y + 0.2)/(0.2/10), S_f)
#map(s_xy(x, y), [-0.2 0.2], [-0.2 0.2])
#: **Desplazamiento vertical de la placa** (mm; positivo hacia arriba): la zona levantada es la del lado de los pernos traccionados.
w_xy(x, y) = spline(1 + (x + 0.2)/(0.2/10), 1 + (y + 0.2)/(0.2/10), W_f)
#map(w_xy(x, y), [-0.2 0.2], [-0.2 0.2])
#: **La deformada de la placa** (ampliada) con el hormigón en el lado comprimido y la placa levantada en el otro; con el ratón se gira y, al pasar el cursor, se lee el desplazamiento (mm) de cada nudo:
#hide
X_d = zeros(n_p, 3)
U_3 = zeros(n_p, 3)
w_j = zeros(n_p, 1)
for q = 1:n_p
  X_d(q, 1) = Xn(q, 1)
  X_d(q, 2) = Xn(q, 2)
  U_3(q, 3) = U(6·(q - 1) + 3)
  w_j(q) = 1000·U(6·(q - 1) + 3)
end
e_j = En(1:64, :)
e_f = zeros(0, 2)
v_f = zeros(0, 2)
#show
#modelo3d(X_d, e_j, e_f, w_j, v_f, U_3, 500)
#: **La misma deformada con la tensión de Von Mises** (MPa) de cada nudo al pasar el cursor:
#modelo3d(X_d, e_j, e_f, sv_n, v_f, U_3, 500)

## 15 · Resumen

#: Con N = 300 kN y M = 40 kN·m (excentricidad 0.133 m, mayor que N/6 = 0.067 m de la placa): la placa **se despega** por el lado traccionado, los pernos de ese lado trabajan, y el hormigón del lado comprimido soporta la carga concentrada. Por elementos finitos hacen falta menos milímetros de placa que por AISC, porque AISC supone un bloque plano de presión; AISC es más conservador.

## 16 · Del símbolo al número: la franja de placa como viga de elementos finitos

#: **Qué es.** El método de AISC trata el voladizo de la placa como una **viga empotrada en la cara del tubo** con la presión del hormigón como carga. Aquí esa viga se resuelve **por elementos finitos**: primero **todo en símbolos** (el motor deduce las funciones de forma, la curvatura, la rigidez y la solución, sin ningún dato de la placa) y después **con los números** de esta hoja, con gráficas. Es la reducción a una dimensión de la cáscara de las secciones 2 a 8; la cáscara en sí ya se calculó con números.

### 16.1 · En símbolos: el elemento empotrado-libre
#: El elemento mide L. Se mide x desde el empotramiento y se normaliza (de 0 a 1). Como en el empotramiento la flecha y el giro valen cero, la flecha es la suma de dos potencias, x² y x³. Sus dos coeficientes salen de las dos condiciones del extremo libre: flecha w y giro θ (la fila del giro va dividida por L):
A_c = Simplify{[1, 1; 2/L, 3/L]}
#: La inversa son los coeficientes de las dos funciones de forma (cada columna es una función):
C_c = Simplify{inv(A_c)}
#: Las funciones de forma (flecha por cada unidad de w y de θ en el extremo libre):
Phi_c = Simplify{[x^2, x^3]*C_c}
#: La curvatura es la segunda derivada de la flecha (el motor deriva cada potencia dos veces; el 1/L² pasa de x normalizada a x real):
d2p_c = [Partial{Partial{x^2 @ x} @ x}, Partial{Partial{x^3 @ x} @ x}]
B_c = Simplify{d2p_c*C_c*(1/L^2)}
#: **La rigidez** es la energía de flexión: K = EI·∫ Bᵀ·B dx sobre la longitud L. El motor integra con L y EI como letras:
K_c = Simplify{EI*L*Integral{transpose(B_c)*B_c @ x = 0 : 1}}
#: **La carga.** Una presión uniforme q (carga por metro de ancho) se reparte a los nudos con las mismas funciones de forma, F = q·L·∫ Φᵀ dx:
F_c = Simplify{q*L*Integral{transpose(Phi_c) @ x = 0 : 1}}
#: **La solución.** Se resuelve K·u = F, también en símbolos. Salen la flecha y el giro del borde libre de la placa, fórmulas exactas de un voladizo con carga uniforme:
u_c = Simplify{inv(K_c)*F_c}
#: **El momento en el empotramiento** (la cara del tubo) sale del equilibrio, M = q·L²/2. Es la fórmula de AISC, M_c = f_p·m²/2: el elemento finito la reproduce exactamente.
M_c_s = Simplify{q*L^2/2}

### 16.2 · Con los números de la hoja
#: La presión de contacto es la del método de AISC de la sección 10 (bloque uniforme f_p) y el voladizo es m. Se arma la viga con n elementos iguales: la rigidez del elemento es la deducida arriba, EI/L³·[12, 6L, −12, 6L; …], con L la longitud de cada elemento.
EI_p = E·t_p^3/(12·(1 - ν^2)) 'rigidez a flexión de la placa por metro de ancho [kN·m]
q_s = A_r(5) 'presión de contacto por metro de ancho [kN/m]
L_v = m_c 'voladizo desde la cara del tubo [m]
#hide
function R = franja(n, Lv, EI, q)
  Le = Lv/n
  nd = 2·(n + 1)
  Ke = EI/Le^3·[12, 6·Le, -12, 6·Le; 6·Le, 4·Le^2, -6·Le, 2·Le^2; -12, -6·Le, 12, -6·Le; 6·Le, 2·Le^2, -6·Le, 4·Le^2]
  Fe = q·Le·[0.5; Le/12; 0.5; -Le/12]
  K0 = zeros(nd, nd)
  F0 = zeros(nd, 1)
  for e = 1:n
    for i = 1:4
      F0(2·(e - 1) + i) = F0(2·(e - 1) + i) + Fe(i)
      for j = 1:4
        K0(2·(e - 1) + i, 2·(e - 1) + j) = K0(2·(e - 1) + i, 2·(e - 1) + j) + Ke(i, j)
      end
    end
  end
  Kb = K0
  Fb = F0
  for i = 1:2
    for j = 1:nd
      Kb(i, j) = 0
      Kb(j, i) = 0
    end
    Kb(i, i) = 1
    Fb(i) = 0
  end
  Ug = clsolve(Kb, Fb)
  R = zeros(n + 1, 3)
  Re = K0·Ug - F0
  for k = 1:n + 1
    R(k, 1) = (k - 1)·Le
    R(k, 2) = Ug(2·k - 1)
  end
  R(1, 3) = abs(Re(2))
  for e = 1:n
    ue = zeros(4, 1)
    for i = 1:4
      ue(i) = Ug(2·(e - 1) + i)
    end
    me = Ke·ue - Fe
    R(e + 1, 3) = abs(me(4))
  end
end
w_ex = zeros(21, 2)
m_ex = zeros(21, 2)
for s = 1:21
  xx = (s - 1)·L_v/20
  w_ex(s, 1) = xx
  w_ex(s, 2) = 1000·q_s·xx^2·(6·L_v^2 - 4·L_v·xx + xx^2)/(24·EI_p)
  m_ex(s, 1) = xx
  m_ex(s, 2) = q_s·(L_v - xx)^2/2
end
F_4 = franja(4, L_v, EI_p, q_s)
W_4 = zeros(5, 2)
M_4 = zeros(5, 2)
for k = 1:5
  W_4(k, 1) = F_4(k, 1)
  W_4(k, 2) = 1000·F_4(k, 2)
  M_4(k, 1) = F_4(k, 1)
  M_4(k, 2) = F_4(k, 3)
end
Mr_n = zeros(4, 1)
nn_v = [1, 2, 4, 8]
for k = 1:4
  Rk = franja(nn_v(k), L_v, EI_p, q_s)
  Mr_n(k) = Rk(1, 3)
end
#show
M_exacto = q_s·L_v^2/2 'momento en la cara del tubo, fórmula de AISC [kN·m/m]
w_exacto = 1000·q_s·L_v^4/(8·EI_p) 'flecha del borde libre, fórmula simbólica [mm]
w_fe = W_4(5, 2) 'flecha del borde libre por elementos finitos, 4 elementos [mm]
M_fe_1 = Mr_n(1) 'momento en la cara del tubo con 1 elemento [kN·m/m]
M_fe_4 = Mr_n(3) 'con 4 elementos [kN·m/m]
M_fe_8 = Mr_n(4) 'con 8 elementos [kN·m/m]
#: **Gráfica 4. La flecha del voladizo de la placa** (mm; x desde la cara del tubo). Puntos naranjas: los 5 nudos de la viga de elementos finitos (4 elementos); azules: la fórmula exacta. Pasa el cursor sobre la gráfica para leer x y la flecha.
#fplot(Exacta = w_ex, FEM = W_4, [0 0.10500000000000001])
#: **Gráfica 5. El momento flector** (kN·m por metro de ancho) en cada nudo. Puntos naranjas: elementos finitos (momento de extremo de elemento); azules: q·(L − x)²/2. En x = 0 está el momento de AISC.
#fplot(Exacta = m_ex, FEM = M_4, [0 0.10500000000000001])
#: **Qué dice la comparación.** La viga de elementos finitos da en la cara del tubo **{M_exacto} kN·m/m**, el mismo momento de AISC (sección 10), con 1, 2, 4 u 8 elementos: la cúbica de Hermite es exacta para carga uniforme. En cambio la cáscara de las secciones 2 a 8 da M_fem de la sección 12, bastante menor: la presión real bajo la placa **no es uniforme** (es más baja junto al tubo, que rigidiza la placa) y la placa apoya también sobre las paredes del tubo; por eso AISC es conservador. La diferencia es de modelo, no de cálculo.

#: Los 966 desplazamientos y giros (u_x, u_y, u_z, θ_x, θ_y, θ_z de cada nudo, en m y rad) para compararlos con Abaqus:
U_f = U 'desplazamientos y giros de los 161 nudos
sig_el_f = sig_el 'tensión de Von Mises en el centro de cada elemento de la placa [MPa]
Fw_f = Fw 'fuerzas de soldadura en los 16 nudos del perímetro: Fx, Fy, Fz [kN]
