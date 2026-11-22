# Rectangular hollow section (RHS) column base plate by finite elements: shells, bolts, concrete and weld, against AISC and Abaqus
#numerico

#: **What is calculated.** The connection of a **rectangular hollow (RHS)** column (RHS 250 × 150 × 8) with its 350 × 450 × 25 mm **base plate** on a 0.50 × 0.60 m concrete **pedestal**, with **four M24 bolts** and the **weld** of the tube to the plate, under compression and moment. It is solved in two ways: by **shell finite elements**, as the component-based finite element method (CBFEM) of IDEA StatiCa sets it out, and by the **AISC analytical method** (Design Guide 1), which treats the plate as a cantilever.
#: **Why it matters.** The component method by formulas distributes the load with assumptions (uniform pressure block, cantilever up to the tube face). With finite elements the plate **bends**, **lifts off** the concrete where the moment raises it, and the **bolts** come in only when needed: the distribution comes out of the calculation. Comparing the two shows where AISC is conservative.
#: **How.** ShellMITC4 element of sheet 72 (6 dof per node, Reissner-Mindlin theory: **thick** plate, with shear deformation, like the IDEA StatiCa shell element; validated against OpenSees). Weld = shared nodes at the tube edge; its force per unit length is read from the tube stiffness. Concrete: vertical Winkler springs at each plate node, active only in compression; bolts: EA/L, active only in tension. The active set is iterated until it does not change.
#: **Judge.** **Abaqus** (S4 shell with the same meshes, nonlinear springs and the same load distribution): the displacements of the 161 nodes, the bolt tension and the weld forces are compared. IDEA StatiCa is not used: its telemetry has been blocked and it does not rely on its license.
#: **Units.** kN, m and kPa.

## 1 · Data

#: **Material** (S355 steel):
E = 210000000.0 'modulus of elasticity of steel [kPa]
ν = 0.3 'Poisson's ratio
#: **Geometry.** Plate of 0.350 × 0.450 m and 25 mm; RHS 250 × 150 × 8 tube (its midline is modeled: 0.142 × 0.242 m); 100 mm of tube height are modeled. The moment acts in the plane of the 250 mm side (y axis); the compressed side is the positive y one.
t_p = 0.025 'plate thickness [m]
t_c = 0.008 'tube wall thickness [m]
H_c = 0.1 'modeled tube height [m]
n_z = 5 'rows of elements in the tube height
xs = [-0.175; -0.1; -0.071; -0.0355; 0.0; 0.0355; 0.071; 0.1; 0.175] 'plate mesh lines in x [m]
ys = [-0.225; -0.15; -0.121; -0.0605; 0.0; 0.0605; 0.121; 0.15; 0.225] 'plate mesh lines in y [m]
#: **Bolts and concrete:**
A_b = 0.000353 'resisting area of an M24 bolt [m2]
L_b = 0.3 'free length of the bolt [m]
k_b = E·A_b/L_b 'axial stiffness of a bolt, tension only [kN/m]
k_c = 60000000.0 'subgrade modulus of the concrete pedestal, compression only [kN/m3]
#: The four bolts are at x = ± 0.100 m, y = ± 0.150 m.
#: **Loads at the tube head** (compression and moment about the x axis):
N_c = 300.0 'axial compression load [kN]
M_x = 50.0 'moment about x [kN·m]

## 2 · The shell element (ShellMITC4, sheet 72)

#: Elastic membrane + plate section of thickness t, with transverse shear κ = 5/6:
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
dd_p = seccion(E, ν, t_p) 'plate section
dd_c = seccion(E, ν, t_c) 'tube wall section

## 3 · The mesh

#: **Plate:** 8 × 8 elements (81 nodes, z = 0). **Tube:** 16 perimeter segments by 5 rows (80 more nodes; those of the bottom row are those of the plate: that is where the weld is). The nodes of the tube perimeter fall on the lines of the plate mesh that pass through its midline.
n_x = 9 'lines per side of the plate
n_p = 81 'plate nodes
n_n = 161 'total nodes
n_e = 144 'elements: 64 of plate and 80 of tube
#hide
Xn = zeros(n_n, 3)
for j = 1:n_x
  for i = 1:n_x
    q = (j - 1)·n_x + i
    Xn(q, 1) = xs(i)
    Xn(q, 2) = ys(j)
  end
end
#: Tube perimeter: bottom side (+x), right (+y), top (−x), left (−y). Line indices 3 … 7.
pi_x = [3, 4, 5, 6, 7, 7, 7, 7, 7, 6, 5, 4, 3, 3, 3, 3] 'line index in x of each perimeter point
pi_y = [3, 3, 3, 3, 3, 4, 5, 6, 7, 7, 7, 7, 7, 6, 5, 4] 'line index in y
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
Xn_b = Xn(1:3, :) 'first nodes: z = 0, at the plate corner

## 4 · Stiffness assembly

#: Six degrees of freedom per node: u_x, u_y, u_z, θ_x, θ_y, θ_z (those of node q are 6(q − 1) + 1 … 6). Each element adds its 24 × 24 matrix into the rows and columns of its four nodes; the shared nodes of the tube edge are the **weld**.
n_g = 6·n_n 'degrees of freedom
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

## 5 · The supports: concrete in compression only and bolts in tension only

#: Each plate node carries a vertical spring of stiffness k_c times its **tributary area**. The bolts are at the four nodes of lines 2 and 8, with stiffness k_b. So that the model does not float in the plane: u_x and u_y are fixed at the plate center and u_y at the center of the edge x = + L_x.
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
#: Bolt nodes:
nb

## 6 · The loads

#: They are distributed over the 16 nodes of the tube head with the linear stress distribution σ = −N/A − M·y/I of the section (A = Σ a_k, I = Σ a_k·y_k², a_k = tributary length × t_c): the resultant is exactly N and M. The tributary length of each node is half of the two segments surrounding it.
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
A_t 'area of the tube section [m2]
I_t 'discrete inertia of the tube [m4]
S_F = sum(F) 'vertical resultant of the loads [kN] (must be −N)

## 7 · Solution: active set of springs

#: It is solved with all the concrete springs active and no bolt; afterwards the concrete ones that go up (u_z > 0) are **switched off** and the bolts that go up are **switched on**, and it is repeated until the set does not change.
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

## 8 · Results

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
R_conc = sum(Rc) 'total concrete reaction (upward) [kN]
T_b = sum(Rb) 'total bolt force (downward: negative) [kN]
equil = R_conc + T_b + S_F 'vertical equilibrium: must be 0 [kN]
sig_max = max(pres)/1000 'maximum contact pressure [MPa]
n_lev = n_p - sum(c_on) 'plate nodes lifted off the concrete
T_1 = -min(Rb) 'tension of the most loaded bolt [kN]
#: **Pedestal.** Concrete bearing strength f_cd = 25/1.5 and confinement factor k_j = √(A_pedestal/A_plate) ≤ 3, with the 0.50 × 0.60 m pedestal:
f_cd = 25/1.5 'design strength of concrete [MPa]
k_j = min(3, sqrt(0.3000/(0.3500·0.4500))) 'confinement factor
rat_c = sig_max/(k_j·f_cd) 'utilization of the contact
#: **Bolt.** Tensile strength of a class 8.8 M24: 0.9·f_ub·A_s/γ_M2 with f_ub = 800 MPa and γ_M2 = 1.25:
F_tRd = 0.9·800000·A_b/1.25 'tensile strength of a bolt [kN]
rat_b = T_1/F_tRd 'utilization of the bolt

## 9 · The tube-plate weld

#: The elements of the bottom row of the tube transmit to the plate, at each perimeter node, three forces (axial and two shear). Divided by the tributary length this gives the **force per unit length** of weld q_w. The throat needed for an external fillet weld (EN 1993-1-8, simplified method) is a = q_w / f_vw,d with f_vw,d = f_u/(√3·β_w·γ_M2), f_u = 510 MPa, β_w = 0.90 (S355), γ_M2 = 1.25:
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
S_wz = sum(Fw(:, 3)) 'sum of the vertical forces the weld carries down to the plate [kN]
q_w = max(qw) 'maximum force per unit length of weld [kN/m]
f_vwd = 510000/(sqrt(3)·0.9·1.25) 'design shear strength of the weld [kPa]
a_req = q_w/f_vwd·1000 'required throat [mm]

## 10 · The AISC analytical method (Design Guide 1): the plate as a cantilever

#: **The idea.** AISC treats the plate as a **cantilever** projecting from the tube face: the concrete pressure (a uniform block of strength f_p) bends it upward; if the moment is large, the plate lifts on one side and the **bolt tension** bends it downward. The thickness comes from requiring that the moment per unit width not exceed the plastic strength t²·F_y/4. For a **square or rectangular hollow** column Design Guide 1 measures the cantilevers up to 0.95 times the tube side: m = (N − 0.95·d)/2 in the plane of the moment and n = (B − 0.95·b)/2 in the other; the larger governs.
#: **Method data** (LRFD): plate N × B = 0.450 × 0.350 m, tube of 0.250 × 0.150 m (d × b), F_y = 355 MPa, f′_c = 25 MPa on a 0.50 × 0.60 m pedestal, bolts at f = 0.150 m from the axis in the plane of the moment:
N_p = 0.45 'plate dimension in the plane of the moment [m]
B_p = 0.35 'plate width [m]
d_t = 0.25 'tube side in the plane of the moment [m]
b_t = 0.15 'tube side in the other direction [m]
F_y = 355000 'yield strength of the plate [kPa]
fc_p = 25000 'concrete strength f′_c [kPa]
A_ped = 0.3 'pedestal area [m2]
f_b = 0.15 'distance from the axis to the bolts, in the plane of the moment [m]
#: **Bearing strength** (φ_c = 0.65; the confinement factor √(A₂/A₁) does not exceed 2):
f_pmax = 0.65·0.85·fc_p·min(2, sqrt(A_ped/(N_p·B_p))) 'design maximum contact pressure [kPa]
q_max = f_pmax·B_p 'maximum load per meter of the plate [kN/m]
m_c = (N_p - 0.95·d_t)/2 'cantilever in the plane of the moment, up to 0.95 of the tube side [m]
n_c = (B_p - 0.95·b_t)/2 'cantilever in the other direction [m]
u_t = f_b - 0.95·d_t/2 'from the bolt to the tube face [m]
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
A_r = aisc(N_c, M_x, N_p, B_p, f_b, f_pmax, q_max, m_c, u_t, F_y) 'e · e_crit · Y · T · f_p · M_contact · M_bolt · t_req
#: **Eccentricity.** e = M/P is compared with the critical e_crit = N/2 − P/(2·q_max): below it, the plate only compresses (bearing length Y = N − 2e, uniform block f_p = P/(Y·B)); above it, the plate lifts, the bolts on that side work with T = q_max·Y − P and Y comes out of the moment equation about the bolts.
e_a = A_r(1) 'eccentricity e = M/P [m]
e_crit = A_r(2) 'critical eccentricity [m]
Y_a = A_r(3) 'bearing length [m]
T_a = A_r(4) 'total tension of the bolts on one side [kN]
t_a = A_r(8)·1000 'plate thickness required by AISC [mm]

## 11 · The same by finite elements, sweeping the moment

#: With the finite element model the calculation is repeated for moments from 0 to 100 kN·m with the same axial load. From each solution the **same numbers** that AISC gives are read: the bolt tension, the cantilever moment per unit width at the tube face (from the concrete and bolt reactions) and the thickness that results from it.
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
y_s = ys(7) 'tube face (midline), where the cantilever starts [m]
n_m = 10
ms = zeros(n_m, 1)
for s = 1:n_m
  ms(s) = (s - 1)·100.0/9
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

#: **Plot 1. Total tension of the bolts on one side against the moment** (N = 300 kN). The blue points are the finite element calculation (elastic plate with springs); the orange ones, the AISC method (rigid-plastic block). AISC gives no tension until e = M/P exceeds e_crit; with finite elements the plate **bends** and the bolts start to work earlier, because the pressure is not a uniform block but grows toward the compressed edge.
#fplot(FEM = Tm, AISC = TmA, [0 100])
#: **Plot 2. Required plate thickness against the moment** (mm). Blue: the one that comes from the cantilever moment read from the finite element model; orange: AISC. The real plate is 25 mm.
#fplot(FEM = Tr, AISC = Ym, [0 100])

#: **Plot 3. The pressure under the plate, along its center line, with M = 80 kN·m.** The blue points are the finite element contact pressure (MPa); the orange ones, AISC's uniform block over the bearing length Y. The compressed edge is at y = +0.225 m. The fundamental difference is seen: AISC distributes the load in a **flat block** and therefore needs more thickness; with finite elements the pressure **grows toward the edge** and the cantilever moment is smaller.
#hide
Ug = resuelve(K, carga(N_c, 80, yk, ell, n_p, n_z, n_g, t_c), kc_i, kb_i, n_p, n_g)
Ag = aisc(N_c, 80, N_p, B_p, f_b, f_pmax, q_max, m_c, u_t, F_y)
Pc = zeros(n_x, 2)
for j = 1:n_x
  q = (j - 1)·n_x + 5
  Pc(j, 1) = ys(j)
  Pc(j, 2) = max(0, -k_c·Ug(6·(q - 1) + 3))/1000
end
Pa = zeros(41, 2)
for s = 1:41
  yy = -0.225 + (s - 1)·0.225/20
  Pa(s, 1) = yy
  if yy >= 0.225 - Ag(3) - 1e-9
    Pa(s, 2) = Ag(5)/1000
  end
end
#show
Y_g = Ag(3) 'AISC bearing length with that moment [m]
T_g = Ag(4) 'AISC tension with that moment [kN]
#fplot(FEM = Pc, AISC = Pa, [-0.225 0.225])

## 12 · Comparison for the case of the sheet (N = 300 kN, M = 50 kN·m)

#hide
Pf = post(U, kc_i, kb_i, ys, n_p, n_x, B_p, y_s)
#show
T_fem = Pf(2) 'total bolt tension (FEM) [kN]
M_fem = max(Pf(4), Pf(5)) 'cantilever moment per unit width (FEM) [kN·m/m]
t_fem = 1000·sqrt(4·M_fem/(0.9·F_y)) 'required thickness (FEM) [mm]
M_aisc = max(A_r(6), A_r(7)) 'cantilever moment per unit width (AISC) [kN·m/m]
#: **What each method says.** AISC: uniform pressure block over the bearing length Y and, if e > e_crit, tension in the bolts. Finite elements: the plate deforms, the pressure is linear and the bolts activate as the plate lifts them. Both give the thickness with the same rule (plastic cantilever t² F_y/4 = M).
#: **Comparison with two other programs** (same model: the same 161 nodes, the same loads, concrete in compression only and bolts in tension only). **Abaqus**: S4 shell and nonlinear springs, run from the command line. **IDEA StatiCa**: its CBFEM finite element solver (k2fem64, CQUAD4 shell and contact with gap elements), run offline and without its program; **it is not IDEA's own connection model**, it is its solver with this same model. The sheet column is the calculation above; the other two are given as reference, they are not used in the calculation.
#: - **Total bolt tension** (kN): sheet 67.82 · Abaqus 67.96 · IDEA 68.43 · AISC 0 (assumes a rigid plate without lift-off: e < e_crit)
#: - **Total concrete reaction** (kN): sheet 367.82 · Abaqus 367.96 · IDEA 368.43
#: - **Maximum upward deflection of the plate** (mm): sheet 0.2652 · Abaqus 0.2697 · IDEA 0.2713
#: - **Maximum downward deflection of the plate** (mm): sheet -0.1808 · Abaqus -0.1822 · IDEA -0.1878
#: - **Elevation of the most loaded bolt** (mm): sheet 0.1372 · Abaqus 0.1375 · IDEA 0.1385
#: - **Vertical equilibrium** (sum of reactions, with N = 300 kN): sheet 300.000 · Abaqus 300.000 · IDEA 300.0006
#: - **Maximum Von Mises stress in the plate** (MPa): sheet 108.90 · Abaqus 109.69
#: - **Maximum weld force per node** (kN): sheet 85.06 · Abaqus 84.42
#: The three finite element models agree within 1 % in the forces (bolts, concrete, weld) and 3 % in the maximum deflection; the differences come from each program's shell formulation. **AISC is from another family**: without plate lift-off there is no bolt tension and the cantilever moment is that of section 16 (M_aisc), more than double that given by the shell.

## 13 · The connection drawn

#: **Dimensioned section** through the plane of the moment: the plate on the pedestal, the hollow tube and the bolts. m is the cantilever of the plate up to 0.95 of the tube side; u, the distance from the bolt to that face.
#dibujo("Tubular column base plate: section through the plane of the moment", ud = m, escala = auto, cotas = m, ancho = 190, alto = 150)
#  rect(-0.3, -0.4, 0.6, 0.4, "gruesa")
#  rect(-0.225, 0, 0.45, t_p, "gruesa")
#  achurado(-0.225, 0, 0.45, t_p, "acero")
#  poligono(-0.125, t_p, -0.11699999999999999, t_p, -0.11699999999999999, 0.30, -0.125, 0.30, "gruesa")
#  poligono(0.11699999999999999, t_p, 0.125, t_p, 0.125, 0.30, 0.11699999999999999, 0.30, "gruesa")
#  linea(-0.15, -0.28, -0.15, 0.055, "gruesa verde")
#  linea(0.15, -0.28, 0.15, 0.055, "gruesa verde")
#  texto(0.0, 0.34, "RHS 250 × 150 × 8 hollow tube", 3, "c")
#  texto(0.0, -0.46, "0.50 × 0.60 m concrete pedestal", 3, "c")
#  texto(0.18, -0.1, "M24 bolt", 2.6, "i", estilo = "verde")
#  flecha(0.0, 0.52, 0.0, 0.32, "rojo")
#  texto(0.02, 0.50, "N = 300 kN · M = 50 kN·m", 2.6, "i", estilo = "rojo")
#  cota(-0.225, -0.52, 0.225, -0.52, -0.04, "0.450")
#  cota(0.11875, 0.06, 0.225, 0.06, 0.03, "m = 0.106")
#  cota(0.11875, -0.22, 0.15, -0.22, -0.03, "u = 0.031")
#  cota(0.0, -0.14, 0.15, -0.14, -0.03, "f = 0.150")
#  cota(0.265, 0, 0.265, t_p, 0.03, "25 mm")
#fin

#: **Dimensioned plan**: the plate, the tube, the four bolts and the plate mesh (the row of nodes at the tube edge is the weld).
#dibujo("Base plate plan: tube, bolts and finite element mesh", ud = m, escala = auto, cotas = m, ancho = 150, alto = 170)
#  rect(-0.175, -0.225, 0.35, 0.45, "gruesa")
#  rect(-0.075, -0.125, 0.15, 0.25, "media rojo")
#  rect(-0.067, -0.11699999999999999, 0.134, 0.23399999999999999, "media rojo")
#  circulo(-0.1, -0.15, 0.012, "gruesa verde")
#  circulo(-0.1, 0.15, 0.012, "gruesa verde")
#  circulo(0.1, -0.15, 0.012, "gruesa verde")
#  circulo(0.1, 0.15, 0.012, "gruesa verde")
#  linea(-0.175, -0.225, -0.175, 0.225, "fina gris")
#  linea(-0.1, -0.225, -0.1, 0.225, "fina gris")
#  linea(-0.071, -0.225, -0.071, 0.225, "fina gris")
#  linea(-0.0355, -0.225, -0.0355, 0.225, "fina gris")
#  linea(0.0, -0.225, 0.0, 0.225, "fina gris")
#  linea(0.0355, -0.225, 0.0355, 0.225, "fina gris")
#  linea(0.071, -0.225, 0.071, 0.225, "fina gris")
#  linea(0.1, -0.225, 0.1, 0.225, "fina gris")
#  linea(0.175, -0.225, 0.175, 0.225, "fina gris")
#  linea(-0.175, -0.225, 0.175, -0.225, "fina gris")
#  linea(-0.175, -0.15, 0.175, -0.15, "fina gris")
#  linea(-0.175, -0.121, 0.175, -0.121, "fina gris")
#  linea(-0.175, -0.0605, 0.175, -0.0605, "fina gris")
#  linea(-0.175, 0.0, 0.175, 0.0, "fina gris")
#  linea(-0.175, 0.0605, 0.175, 0.0605, "fina gris")
#  linea(-0.175, 0.121, 0.175, 0.121, "fina gris")
#  linea(-0.175, 0.15, 0.175, 0.15, "fina gris")
#  linea(-0.175, 0.225, 0.175, 0.225, "fina gris")
#  texto(0.0, 0.0, "tube", 2.6, "c", estilo = "rojo")
#  texto(0.10500000000000001, 0.175, "M24 bolts", 2.6, "c", estilo = "verde")
#  texto(0.0, 0.27, "compressed edge (+y)", 2.6, "c")
#  cota(-0.175, -0.275, 0.175, -0.275, -0.04, "0.350")
#  cota(0.22499999999999998, -0.225, 0.22499999999999998, 0.225, 0.04, "0.450")
#  cota(-0.075, -0.14, 0.075, -0.14, -0.03, "0.150")
#fin

## 14 · The pressure and the deformed shape of the plate

#: **Contact pressure map** (kPa) in the plan of the plate, with the case of the sheet: the concrete works only on the compressed side (positive y); the zone at zero is the one that lifts off. The value is read with the cursor.
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
    xq = -0.175 + (if_ - 1)·0.175/10
    yq = -0.225 + (jf - 1)·0.225/10
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
p_xy(x, y) = spline(1 + (x + 0.175)/(0.175/10), 1 + (y + 0.225)/(0.225/10), P_f)
#map(p_xy(x, y), [-0.175 0.175], [-0.225 0.225])
#: **Plate stress.** With the rotations of each element the curvatures at its center are calculated (κ₁₁ = −∂θ_y/∂x, κ₂₂ = ∂θ_x/∂y, κ₁₂ = ∂θ_x/∂x − ∂θ_y/∂y), the moments per unit width m = D·[κ₁₁ + νκ₂₂, νκ₁₁ + κ₂₂, (1 − ν)/2·κ₁₂] with D = E·t³/(12·(1 − ν²)), and the extreme fibre stresses σ = 6·m/t². The equivalent Von Mises stress (in MPa) averaged at the plate nodes is shown:
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
    xq = -0.175 + (if_ - 1)·0.175/10
    yq = -0.225 + (jf - 1)·0.225/10
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
sig_max_p = max(sv_n) 'maximum Von Mises stress in the plate (node average) [MPa]
sig_el_max = max(sig_el) 'maximum Von Mises stress at an element center [MPa]
rat_f = sig_el_max/355 'utilization of the plate against the 355 MPa yield strength
s_xy(x, y) = spline(1 + (x + 0.175)/(0.175/10), 1 + (y + 0.225)/(0.225/10), S_f)
#map(s_xy(x, y), [-0.175 0.175], [-0.225 0.225])
#: **Vertical displacement of the plate** (mm; positive upward): the lifted zone is that on the side of the bolts in tension.
w_xy(x, y) = spline(1 + (x + 0.175)/(0.175/10), 1 + (y + 0.225)/(0.225/10), W_f)
#map(w_xy(x, y), [-0.175 0.175], [-0.225 0.225])
#: **The deformed shape of the plate** (magnified) with the concrete on the compressed side and the plate lifted on the other; it rotates with the mouse and, by moving the cursor, the displacement (mm) of each node is read:
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
#: **The same deformed shape with the Von Mises stress** (MPa) of each node when moving the cursor:
#modelo3d(X_d, e_j, e_f, sv_n, v_f, U_3, 500)

## 15 · Summary

#: With N = 300 kN and M = 50 kN·m (eccentricity 0.167 m, greater than N/6 = 0.075 m of the plate): the plate **lifts off** on the tension side, the bolts on that side work, and the concrete on the compressed side carries the concentrated load. With finite elements fewer millimeters of plate are needed than with AISC, because AISC assumes a flat pressure block; AISC is more conservative.

## 16 · From symbol to number: the plate strip as a finite element beam

#: **What it is.** The AISC method treats the cantilever of the plate as a **beam fixed at the tube face** with the concrete pressure as the load. Here that beam is solved **by finite elements**: first **everything in symbols** (the engine derives the shape functions, the curvature, the stiffness and the solution, with no plate data) and then **with the numbers** of this sheet, with plots. It is the reduction to one dimension of the shell of sections 2 to 8; the shell itself was already calculated with numbers.

### 16.1 · In symbols: the fixed-free element
#: The element measures L. x is measured from the fixed end and normalized (from 0 to 1). Since at the fixed end the deflection and the rotation are zero, the deflection is the sum of two powers, x² and x³. Its two coefficients come from the two conditions at the free end: deflection w and rotation θ (the rotation row is divided by L):
A_c = Simplify{[1, 1; 2/L, 3/L]}
#: The inverse is the coefficients of the two shape functions (each column is a function):
C_c = Simplify{inv(A_c)}
#: The shape functions (deflection per unit of w and of θ at the free end):
Phi_c = Simplify{[x^2, x^3]*C_c}
#: The curvature is the second derivative of the deflection (the engine differentiates each power twice; the 1/L² goes from normalized x to real x):
d2p_c = [Partial{Partial{x^2 @ x} @ x}, Partial{Partial{x^3 @ x} @ x}]
B_c = Simplify{d2p_c*C_c*(1/L^2)}
#: **The stiffness** is the bending energy: K = EI·∫ Bᵀ·B dx over the length L. The engine integrates with L and EI as letters:
K_c = Simplify{EI*L*Integral{transpose(B_c)*B_c @ x = 0 : 1}}
#: **The load.** A uniform pressure q (load per meter of width) is distributed to the nodes with the same shape functions, F = q·L·∫ Φᵀ dx:
F_c = Simplify{q*L*Integral{transpose(Phi_c) @ x = 0 : 1}}
#: **The solution.** K·u = F is solved, also in symbols. The deflection and rotation of the free edge of the plate come out, exact formulas of a cantilever with uniform load:
u_c = Simplify{inv(K_c)*F_c}
#: **The moment at the fixed end** (the tube face) comes from equilibrium, M = q·L²/2. It is the AISC formula, M_c = f_p·m²/2: the finite element reproduces it exactly.
M_c_s = Simplify{q*L^2/2}

### 16.2 · With the numbers of the sheet
#: The contact pressure is that of the AISC method of section 10 (uniform block f_p) and the cantilever is m. The beam is assembled with n equal elements: the element stiffness is the one derived above, EI/L³·[12, 6L, −12, 6L; …], with L the length of each element.
EI_p = E·t_p^3/(12·(1 - ν^2)) 'bending stiffness of the plate per meter of width [kN·m]
q_s = A_r(5) 'contact pressure per meter of width [kN/m]
L_v = m_c 'cantilever from the tube face [m]
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
M_exacto = q_s·L_v^2/2 'moment at the tube face, AISC formula [kN·m/m]
w_exacto = 1000·q_s·L_v^4/(8·EI_p) 'deflection of the free edge, symbolic formula [mm]
w_fe = W_4(5, 2) 'deflection of the free edge by finite elements, 4 elements [mm]
M_fe_1 = Mr_n(1) 'moment at the tube face with 1 element [kN·m/m]
M_fe_4 = Mr_n(3) 'with 4 elements [kN·m/m]
M_fe_8 = Mr_n(4) 'with 8 elements [kN·m/m]
#: **Plot 4. The deflection of the plate cantilever** (mm; x from the tube face). Orange points: the 5 nodes of the finite element beam (4 elements); blue: the exact formula. Move the cursor over the plot to read x and the deflection.
#fplot(Exacta = w_ex, FEM = W_4, [0 0.10625000000000001])
#: **Plot 5. The bending moment** (kN·m per meter of width) at each node. Orange points: finite elements (element end moment); blue: q·(L − x)²/2. At x = 0 is the AISC moment.
#fplot(Exacta = m_ex, FEM = M_4, [0 0.10625000000000001])
#: **What the comparison says.** The finite element beam gives at the tube face **{M_exacto} kN·m/m**, the same AISC moment (section 10), with 1, 2, 4 or 8 elements: the Hermite cubic is exact for uniform load. In contrast the shell of sections 2 to 8 gives M_fem of section 12, considerably smaller: the real pressure under the plate **is not uniform** (it is lower next to the tube, which stiffens the plate) and the plate also bears on the tube walls; that is why AISC is conservative. The difference is one of model, not of calculation.

#: The 966 displacements and rotations (u_x, u_y, u_z, θ_x, θ_y, θ_z of each node, in m and rad) to compare them with Abaqus:
U_f = U 'displacements and rotations of the 161 nodes
sig_el_f = sig_el 'Von Mises stress at the center of each plate element [MPa]
Fw_f = Fw 'weld forces at the 16 perimeter nodes: Fx, Fy, Fz [kN]
