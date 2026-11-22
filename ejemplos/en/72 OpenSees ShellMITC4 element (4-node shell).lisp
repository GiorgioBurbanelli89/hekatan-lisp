# OpenSees ShellMITC4 (4-node shell element), translated to Hekatan LISP
#numerico

#: Line-by-line translation of **ShellMITC4.cpp**, **R3vectors.cpp** and **ElasticMembranePlateSection.cpp** (OpenSees, master branch). (C) 1999 The Regents of the University of California, All Rights Reserved; used according to the OpenSees COPYRIGHT file. ShellMITC4: Ed Love; reimplementation L. Tesser, D. A. Talledo and V. Le Corvec. Reference: Dvorkin and Bathe, Eng. Comput. 1, 77-88 (1984).
#: Same order of operations as the C++. The oracle is **OpenSees running** (openseespy 3.7.1); it is compared by the script verificar-vs-opensees.py in the opensees-port/shellmitc4 folder of the hekatan-opensees repository.
#: **Vector convention of the sheet:** a vector [a, b, c] is a COLUMN. That is why b·b' is the outer product (in the C++, BdrillJ[p]·BdrillK[q]).

## 1 · Data
E = 2.5e7 'modulus of elasticity (kN/m²)
ν = 0.2 'Poisson's ratio
h = 0.15 'thickness (m)

## 2 · Elastic membrane + plate section
#: ElasticMembranePlateSection::getSectionTangent (l.241-284). Strains: ε₁₁, ε₂₂, γ₁₂ (membrane), κ₁₁, κ₂₂, 2κ₁₂ (bending), γ₁₃, γ₂₃ (shear). Bending enters with a MINUS sign: the element corrects it by multiplying by −1 the bending rows of the B of node J.
M = E/(1 - ν^2)·h 'membrane stiffness (kN/m)
G = 0.5·E/(1 + ν)·h 'in-plane shear stiffness (kN/m)
G_s = G·(5/6) 'transverse shear, κ = 5/6 (Ep/Em = 1)
D = E·h^3/12/(1 - ν^2) 'bending stiffness (kN·m)
#hide
d_d = zeros(8, 8)
d_d(1, 1) = M
d_d(2, 2) = M
d_d(1, 2) = ν·M
d_d(2, 1) = ν·M
d_d(3, 3) = G
d_d(4, 4) = -D
d_d(5, 5) = -D
d_d(4, 5) = -ν·D
d_d(5, 4) = -ν·D
d_d(6, 6) = -0.5·D·(1 - ν)
d_d(7, 7) = G_s
d_d(8, 8) = G_s
#show
d_d

## 3 · In-plane rotational stiffness (drilling)
#: ShellMITC4::setDomain (l.388-401): K_tt is the SMALLEST eigenvalue of the 3×3 membrane block, by the Jacobi of R3vectors.cpp (LovelyEig, l.70-221).
#hide
d_m = d_d(1:3, 1:3)
#show
#: Membrane block (the first 3 rows and columns of the section):
d_m
λ = LovelyEig(d_m)
K_tt = min(λ(3), min(λ(1), λ(2))) 'equal to the in-plane shear stiffness (kN/m)

## 4 · Step by step in a distorted quadrilateral
#: **Local basis** (computeBasis, l.1763-1845): v₁ = ½(x₃ + x₂ − x₄ − x₁), v₂ = ½(x₄ + x₃ − x₂ − x₁), Gram-Schmidt, g₃ = g₁ × g₂. The local coordinates are the ABSOLUTE ones projected on g₁ and g₂.
X_d = [0, 0, 0; 2.2, 0.3, 0; 1.8, 1.7, 0; 0.2, 1.2, 0]
v_1 = 0.5·(((X_d(3, :) + X_d(2, :)) - X_d(4, :)) - X_d(1, :))
v_2 = 0.5·(((X_d(4, :) + X_d(3, :)) - X_d(2, :)) - X_d(1, :))
g_1 = v_1/norm(v_1)
g_2 = v_2 - g_1·dot(v_2, g_1)
g_2 = g_2/norm(g_2)
g_3 = [g_1(2)·g_2(3) - g_1(3)·g_2(2), g_1(3)·g_2(1) - g_1(1)·g_2(3), g_1(1)·g_2(2) - g_1(2)·g_2(1)]
#hide
x_l = zeros(2, 4)
for i = 1:4
  x_l(1, i) = dot(X_d(i, :), g_1)
  x_l(2, i) = dot(X_d(i, :), g_2)
end
#show
x_l
#: **MITC4 shear** (getInitialStiff, l.874-935): the matrix Gm (4×12) gives γ at the 4 tying points (sides 4-1, 2-1, 3-2, 3-4); at each Gauss point it is interpolated with Ms (1 ± ξ, 1 ± η), scaled by r/(8·det J) and rotated with R.
A_x = -x_l(1, 1) + x_l(1, 2) + x_l(1, 3) - x_l(1, 4)
C_x = -x_l(1, 1) - x_l(1, 2) + x_l(1, 3) + x_l(1, 4)
A_y = -x_l(2, 1) + x_l(2, 2) + x_l(2, 3) - x_l(2, 4)
C_y = -x_l(2, 1) - x_l(2, 2) + x_l(2, 3) + x_l(2, 4)
α = atan(A_y/A_x)
β = 3.141592653589793/2 - atan(C_x/C_y)
R = [sin(β), -sin(α); -cos(β), cos(α)]

## 5 · Element stiffness (24 × 24)
#: K = Σ (4 Gauss points) [ BJ'·(dd·dvol)·BK + (Ktt·dvol)·bJ·bK' ], with B in GLOBAL DOF (assembleB already multiplies by g₁, g₂, g₃: there is no separate transformation). 2 × 2 Gauss at ±1/√3. The function that builds it is at the end of the sheet (hidden).
K_d = mitc4_K(X_d, d_d)
#: 1 × 1 square:
K_c = mitc4_K([0, 0, 0; 1, 0, 0; 1, 1, 0; 0, 1, 0], d_d)
#: 2 × 1 rectangle in an inclined plane (tests the g basis outside the XY plane):
K_r = mitc4_K([0, 0, 0; 1.6, 1.2, 0; 1.6, 1.2, 1; 0, 0, 1], d_d)
#: Warped quadrilateral (the 4 nodes outside a single plane):
K_w = mitc4_K([0.1, 0, 0.05; 2.2, 0.3, -0.12; 1.8, 1.7, 0.2; 0.2, 1.2, -0.08], d_d)

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
#show
