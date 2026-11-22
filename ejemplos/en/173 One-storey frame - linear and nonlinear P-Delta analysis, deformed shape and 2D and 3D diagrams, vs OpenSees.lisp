# One-storey frame: linear and nonlinear (P-Δ) analysis with deformed shape and diagrams in 2D and 3D
#numerico

#: **What is computed.** A one-storey concrete frame, 5 m × 5 m in plan and 3 m high, fixed to the ground. A lateral force H and the weight P are applied at each roof node. It is solved in two ways: **linear** (the stiffness does not change: K·u = F) and **geometrically nonlinear P-Δ** (the axial force of the columns takes away lateral stiffness: it is repeated until equilibrium is reached, Newton's method with tangent stiffness).
#: **Why it matters.** In linear analysis the displacement grows in a straight line with the load. In P-Δ gravity "pushes" the already inclined column and the curve bends upward: the structure becomes more flexible. Near the critical load λ_{cr} the deflection shoots up.
#: **Where it comes from.** It is the model of the 3D frame videos, checked against **OpenSees 3.7.1** (elasticBeamColumn, Linear and PDelta): linear with relative error 1e-15 and P-Δ with 1e-8 in the Newton residual. 12 × 12 Euler-Bernoulli 3D member, 6 degrees of freedom per node (48, of which 24 are free). Units kN, m, kPa.

## 1 · Data
#dibujo("The frame: elevation (x-z plane) with supports, loads and dimensions", ud = m, escala = auto, cotas = m, alto = 120, lado = derecha)
#  polilinea(0, 0, 0, H_c, L_x, H_c, L_x, 0, "gruesa")
#  empotramiento(-0.4, 0, L_x + 0.4, 0, -1)
#  flecha(-1.4, H_c, -0.12, H_c, "gruesa rojo")
#  texto(-1.4, H_c + 0.25, "H/4 per node", 2.4, "i")
#  flecha(0, H_c + 0.9, 0, H_c + 0.12, "gruesa verde")
#  flecha(L_x, H_c + 0.9, L_x, H_c + 0.12, "gruesa verde")
#  texto(0.15, H_c + 0.7, "P per node", 2.4, "i")
#  texto(0.15, H_c/2, "columns", 2.4, "i")
#  texto(L_x/2, H_c + 0.2, "beams", 2.4, "c")
#  cota(0, -0.55, L_x, -0.55, 0, "5.00")
#  cota(-0.75, 0, -0.75, H_c, 0, "3.00")
#fin
E_m = 2.5e7 'modulus of elasticity of concrete [kPa]
nu_p = 0.2 'Poisson's ratio
lado_s = 0.40 'side of the square section of columns and beams [m]
H_total = 50.0 'total lateral force in x, distributed over the 4 roof nodes [kN]
P_lineal = 1000.0 'gravity per roof node in the linear analysis [kN]
P_nolineal = 8000.0 'gravity per roof node in the nonlinear analysis, high so that P-Δ shows [kN]
n_inc = 10 'load increments up to λ = 1
tol = 1.0e-6 'tolerance of the Newton residual [kN]
iter_max = 20 'maximum Newton iterations per step
tan_completa = 0 'zero uses the normal tangent; one adds the dKg/dN term
nudos = [0.0, 0.0, 0.0, 1; 5.0, 0.0, 0.0, 1; 5.0, 5.0, 0.0, 1; 0.0, 5.0, 0.0, 1; 0.0, 0.0, 3.0, 0; 5.0, 0.0, 3.0, 0; 5.0, 5.0, 3.0, 0; 0.0, 5.0, 3.0, 0] 'nodes: x, y, z [m] and 1 = fixed, 0 = free (1 to 4 on the ground, 5 to 8 on the roof)
barras = [1, 5, 1, 0, 0; 2, 6, 1, 0, 0; 3, 7, 1, 0, 0; 4, 8, 1, 0, 0; 5, 6, 0, 0, 1; 6, 7, 0, 0, 1; 7, 8, 0, 0, 1; 8, 5, 0, 0, 1] 'members: node i, node j and the vector that fixes the local axis (1-4 columns, 5-8 beams)
kg_tipo = 2 'geometric matrix: 2 is the chord one N/L, equal to OpenSees PDelta; 1 is the consistent cubic one
#: The data above are those of a single file for all languages. What follows is deduced from them.
G_m = E_m/(2·(1 + nu_p)) 'shear modulus [kPa]
A_s = lado_s^2 'section area [m²]
I_s = lado_s^4/12 'section inertia, equal in both axes [m⁴]
J_s = 0.1406·lado_s^4 'torsion constant [m⁴]
n_n = 8 'number of nodes
n_b = 8 'number of members
n_g = 48 'total degrees of freedom
Pm = [E_m, A_s, I_s, I_s, kg_tipo] 'parameters passed to the functions: E, A, Iy, Iz, type of geometric matrix
esc = 400 'amplification of the drawn deformed shapes (only to see them)
L_x = nudos(2, 1) 'frame span in x [m]
H_c = nudos(5, 3) 'column height [m]
X_n = nudos(1:8, 1:3) 'x, y, z coordinates of the 8 nodes [m]
e_n = barras(1:8, 1:2) 'members: start and end node of each one
sin_losa = [1, 1, 1, 1] 'this model has no slab: a zero-area face at node 1 (not visible)
apoyo_nudo = nudos(1:8, 4) 'support of each node: 1 = fixed, 0 = free
sin_valor = zeros(8, 2) 'no diagram on the members
#: **The 3D model with cursor.** Drag to rotate, wheel to zoom; when the cursor passes over a node or a member the value appears (here, whether the node is a support).
#modelo3d(X_n, sin_losa, e_n, apoyo_nudo, sin_valor)

## 2 · The idea: the stiffness of a column, with and without axial load

#: For a column of height L, bending in one plane moves 4 degrees of freedom (displacement and rotation at each end). Its elastic stiffness is EI/L³ times the matrix below. The axial load N (compression = negative) adds a **geometric stiffness** N/(30L) times another matrix: with compression it subtracts stiffness, with tension it adds.
L_c = 3 'column height [m]
EI_c = E_m·I_s 'bending stiffness EI [kN·m²]
k_flex = EI_c/L_c^3·[12, 6·L_c, -12, 6·L_c; 6·L_c, 4·L_c^2, -6·L_c, 2·L_c^2; -12, -6·L_c, 12, -6·L_c; 6·L_c, 2·L_c^2, -6·L_c, 4·L_c^2] 'elastic bending stiffness of a column (u1, θ1, u2, θ2)
N_ej = -8000 'an example compression [kN]
k_geo = N_ej/(30·L_c)·[36, 3·L_c, -36, 3·L_c; 3·L_c, 4·L_c^2, -3·L_c, -L_c^2; -36, -3·L_c, 36, -3·L_c; 3·L_c, -L_c^2, -3·L_c, 4·L_c^2] 'geometric stiffness of that compression: it is negative, it subtracts stiffness
k_tan = k_flex + k_geo 'tangent stiffness: the sum of the two
rig_perdida = 100·(1 - k_tan(1, 1)/k_flex(1, 1)) 'percentage of lateral stiffness that column loses with that compression [%]

## 3 · Analysis functions (the same as in the videos)

#: **klocal** builds the 12 × 12 stiffness of a member; **matT** the matrix that rotates the member axes to the global ones; **kgeo** the geometric stiffness; **fint** the internal forces with the current axial force; **ktang** the tangent; **gauss** solves K·u = F; **es_dp** says whether K is still positive definite (to find the buckling load).

function R = klocal(L, A, Iy, Iz, J, E, G)
  k = zeros(12, 12)
  EA = E·A
  GJ = G·J
  EIy = E·Iy
  EIz = E·Iz
  k(1, 1) = EA/L
  k(1, 7) = -EA/L
  k(7, 7) = EA/L
  k(4, 4) = GJ/L
  k(4, 10) = -GJ/L
  k(10, 10) = GJ/L
  k(2, 2) = 12·EIz/L^3
  k(2, 6) = 6·EIz/L^2
  k(2, 8) = -12·EIz/L^3
  k(2, 12) = 6·EIz/L^2
  k(6, 6) = 4·EIz/L
  k(6, 8) = -6·EIz/L^2
  k(6, 12) = 2·EIz/L
  k(8, 8) = 12·EIz/L^3
  k(8, 12) = -6·EIz/L^2
  k(12, 12) = 4·EIz/L
  k(3, 3) = 12·EIy/L^3
  k(3, 5) = -6·EIy/L^2
  k(3, 9) = -12·EIy/L^3
  k(3, 11) = -6·EIy/L^2
  k(5, 5) = 4·EIy/L
  k(5, 9) = 6·EIy/L^2
  k(5, 11) = 2·EIy/L
  k(9, 9) = 12·EIy/L^3
  k(9, 11) = 6·EIy/L^2
  k(11, 11) = 4·EIy/L
  for i = 1:12
    for j = i + 1:12
      k(j, i) = k(i, j)
    end
  end
  R = k
end

function R = matT(dx, dy, dz, a1, a2, a3)
  L = sqrt(dx^2 + dy^2 + dz^2)
  ex = [dx/L, dy/L, dz/L]
  ey = [a2·ex(3) - a3·ex(2), a3·ex(1) - a1·ex(3), a1·ex(2) - a2·ex(1)]
  ny = sqrt(ey(1)^2 + ey(2)^2 + ey(3)^2)
  ey = ey/ny
  ez = [ex(2)·ey(3) - ex(3)·ey(2), ex(3)·ey(1) - ex(1)·ey(3), ex(1)·ey(2) - ex(2)·ey(1)]
  T = zeros(12, 12)
  for b = 0:3
    for c = 1:3
      T(3·b + 1, 3·b + c) = ex(c)
      T(3·b + 2, 3·b + c) = ey(c)
      T(3·b + 3, 3·b + c) = ez(c)
    end
  end
  R = T
end

function R = kgeo(N, L, A, Iy, Iz, tipo)
  g = zeros(12, 12)
  if tipo == 2
    c = N/L
    g(2, 2) = c
    g(2, 8) = -c
    g(8, 8) = c
    g(3, 3) = c
    g(3, 9) = -c
    g(9, 9) = c
  else
    c = N/(30·L)
    g(2, 2) = 36·c
    g(2, 6) = 3·L·c
    g(2, 8) = -36·c
    g(2, 12) = 3·L·c
    g(6, 6) = 4·L^2·c
    g(6, 8) = -3·L·c
    g(6, 12) = -L^2·c
    g(8, 8) = 36·c
    g(8, 12) = -3·L·c
    g(12, 12) = 4·L^2·c
    g(3, 3) = 36·c
    g(3, 5) = -3·L·c
    g(3, 9) = -36·c
    g(3, 11) = -3·L·c
    g(5, 5) = 4·L^2·c
    g(5, 9) = 3·L·c
    g(5, 11) = -L^2·c
    g(9, 9) = 36·c
    g(9, 11) = 3·L·c
    g(11, 11) = 4·L^2·c
    ct = N·(Iy + Iz)/(A·L)
    g(4, 4) = ct
    g(4, 10) = -ct
    g(10, 10) = ct
  end
  for i = 1:12
    for j = i + 1:12
      g(j, i) = g(i, j)
    end
  end
  R = g
end

function R = fint(U, kloc, Tall, barras, Lb, Pm)
  F = zeros(48, 1)
  for e = 1:8
    gdl = [6·(barras(e, 1) - 1) + (1:6), 6·(barras(e, 2) - 1) + (1:6)]
    r12 = 12·(e - 1) + (1:12)
    T_e = Tall(r12, 1:12)
    u_l = T_e·U(gdl)
    N = Pm(1)·Pm(2)/Lb(e)·(u_l(7) - u_l(1))
    g = kgeo(N, Lb(e), Pm(2), Pm(3), Pm(4), Pm(5))
    f_l = (kloc(r12, 1:12) + g)·u_l
    F(gdl) = F(gdl) + transpose(T_e)·f_l
  end
  R = F
end

#: scale = 1 gives K_{e} + K_{g}(N); scale = 0 gives only K_{e}; scale = λ gives K_{e} + λ·K_{g} (for buckling). compl = 1 adds the dK_{g}/dN term (complete tangent).
function R = ktang(U, escala, compl, kloc, Tall, barras, Lb, Pm)
  Kt = zeros(48, 48)
  for e = 1:8
    gdl = [6·(barras(e, 1) - 1) + (1:6), 6·(barras(e, 2) - 1) + (1:6)]
    r12 = 12·(e - 1) + (1:12)
    T_e = Tall(r12, 1:12)
    u_l = T_e·U(gdl)
    N = Pm(1)·Pm(2)/Lb(e)·(u_l(7) - u_l(1))
    g = kgeo(N, Lb(e), Pm(2), Pm(3), Pm(4), Pm(5))
    k_t = kloc(r12, 1:12) + escala·g
    if compl == 1
      w = kgeo(1, Lb(e), Pm(2), Pm(3), Pm(4), Pm(5))·u_l
      ea = Pm(1)·Pm(2)/Lb(e)
      for i = 1:12
        k_t(i, 1) = k_t(i, 1) - ea·w(i)
        k_t(i, 7) = k_t(i, 7) + ea·w(i)
      end
    end
    Kt(gdl, gdl) = Kt(gdl, gdl) + transpose(T_e)·k_t·T_e
  end
  R = Kt
end

function R = gauss(A0, b0)
  n = size(A0, 1)
  A = A0
  b = b0
  for k = 1:n
    p = k
    for i = k + 1:n
      if abs(A(i, k)) > abs(A(p, k))
        p = i
      end
    end
    if p ~= k
      for j = 1:n
        t = A(k, j)
        A(k, j) = A(p, j)
        A(p, j) = t
      end
      t = b(k)
      b(k) = b(p)
      b(p) = t
    end
    for i = k + 1:n
      m = A(i, k)/A(k, k)
      for j = k:n
        A(i, j) = A(i, j) - m·A(k, j)
      end
      b(i) = b(i) - m·b(k)
    end
  end
  x = zeros(n, 1)
  for i = n:-1:1
    s = b(i)
    for j = i + 1:n
      s = s - A(i, j)·x(j)
    end
    x(i) = s/A(i, i)
  end
  R = x
end

function R = es_dp(A)
  n = size(A, 1)
  Lc = zeros(n, n)
  ok = 1
  for i = 1:n
    for j = 1:i
      s = A(i, j)
      for k = 1:j - 1
        s = s - Lc(i, k)·Lc(j, k)
      end
      if i == j
        if s <= 0
          ok = 0
        else
          Lc(i, i) = sqrt(s)
        end
      else
        if ok == 1
          Lc(i, j) = s/Lc(j, j)
        end
      end
    end
  end
  R = ok
end

#: **deformada** gives the points of a deformed member: to the member axis it adds the displacement of the ends (amplified) and, in the members of the x-z plane, the Hermite cubic curve that passes through the end rotations. Only the horizontal movement and the rotations are amplified: the vertical shortening of the columns (about 6 mm) would cover everything else. It returns three rows x, y, z with 11 points.
function R = deformada(pi_, pj_, Ui, Uj, esc, herm)
  Ui(3) = 0
  Uj(3) = 0
  P = zeros(3, 11)
  L = sqrt((pj_(1) - pi_(1))^2 + (pj_(2) - pi_(2))^2 + (pj_(3) - pi_(3))^2)
  ex = (pj_(1) - pi_(1))/L
  ez = (pj_(3) - pi_(3))/L
  nx = -ez
  nz = ex
  a1 = Ui(1)·ex + Ui(3)·ez
  a2 = Uj(1)·ex + Uj(3)·ez
  v1 = Ui(1)·nx + Ui(3)·nz
  v2 = Uj(1)·nx + Uj(3)·nz
  m1 = -Ui(5)
  m2 = -Uj(5)
  for k = 1:11
    t = (k - 1)/10
    s = t·L
    a = a1 + (a2 - a1)·t
    if herm == 1
      v = v1·(1 - 3·t^2 + 2·t^3) + L·m1·(t - 2·t^2 + t^3) + v2·(3·t^2 - 2·t^3) + L·m2·(-t^2 + t^3)
      P(1, k) = pi_(1) + ex·s + esc·(ex·a + nx·v)
      P(3, k) = pi_(3) + ez·s + esc·(ez·a + nz·v)
      P(2, k) = pi_(2)
    else
      P(1, k) = pi_(1) + (pj_(1) - pi_(1))·t + esc·(Ui(1) + (Uj(1) - Ui(1))·t)
      P(2, k) = pi_(2) + (pj_(2) - pi_(2))·t + esc·(Ui(2) + (Uj(2) - Ui(2))·t)
      P(3, k) = pi_(3) + (pj_(3) - pi_(3))·t + esc·(Ui(3) + (Uj(3) - Ui(3))·t)
    end
  end
  R = P
end

#: **trazo** gives the path of the chosen members as a single polyline (two columns, x and y) to draw it in one stroke. A member with a negative number is traversed backwards. With az = 0 and el = 0 it is the 2D elevation (the x-z plane is seen); with other angles (in degrees) it is the 3D view: the frame is rotated az degrees about the vertical and tilted el degrees toward the observer.
function R = trazo(U, esc, nudos, barras, lista, az, el)
  nb = length(lista)
  S = zeros(11·nb, 2)
  ca = cos(az·0.017453292519943295)
  sa = sin(az·0.017453292519943295)
  ce = cos(el·0.017453292519943295)
  se = sin(el·0.017453292519943295)
  for q = 1:nb
    e = abs(lista(q))
    i_n = barras(e, 1)
    j_n = barras(e, 2)
    gi = 6·(i_n - 1) + (1:6)
    gj = 6·(j_n - 1) + (1:6)
    herm = 0
    if nudos(i_n, 2) == nudos(j_n, 2)
      herm = 1
    end
    P = deformada(nudos(i_n, 1:3), nudos(j_n, 1:3), U(gi), U(gj), esc, herm)
    for k = 1:11
      kk = k
      if lista(q) < 0
        kk = 12 - k
      end
      dd = -P(1, kk)·sa + P(2, kk)·ca
      S(11·(q - 1) + k, 1) = P(1, kk)·ca + P(2, kk)·sa
      S(11·(q - 1) + k, 2) = P(3, kk)·ce + dd·se
    end
  end
  R = S
end

#: **diagrama** gives, as a single polyline (x, z), the M, V or N diagram of the chosen members of the x-z plane: in each member the path is end i, the ordinate at i, the ordinate at j and end j, measured perpendicular to the member and to scale. oi and oj are the ordinates per member.
function R = diagrama(nudos, barras, lista, oi, oj, esc)
  nb = length(lista)
  S = zeros(4·nb, 2)
  for q = 1:nb
    e = abs(lista(q))
    i_n = barras(e, 1)
    j_n = barras(e, 2)
    dx = nudos(j_n, 1) - nudos(i_n, 1)
    dz = nudos(j_n, 3) - nudos(i_n, 3)
    L = sqrt(dx^2 + dz^2)
    nx = -dz/L
    nz = dx/L
    xs = [nudos(i_n, 1), nudos(i_n, 1) + esc·oi(e)·nx, nudos(j_n, 1) + esc·oj(e)·nx, nudos(j_n, 1)]
    zs = [nudos(i_n, 3), nudos(i_n, 3) + esc·oi(e)·nz, nudos(j_n, 3) + esc·oj(e)·nz, nudos(j_n, 3)]
    for k = 1:4
      kk = k
      if lista(q) < 0
        kk = 5 - k
      end
      S(4·(q - 1) + k, 1) = xs(kk)
      S(4·(q - 1) + k, 2) = zs(kk)
    end
  end
  R = S
end

## 4 · Assembly: the stiffness of each member in the global system
#: For each member: local k (12 × 12), the matrix T that rotates from global to local, and Tᵀ·k·T is added into the rows and columns of its two nodes. That gives the elastic stiffness K_{e} of the whole structure (48 × 48).
#hide
K_e = zeros(n_g, n_g)
k_loc = zeros(96, 12)
T_all = zeros(96, 12)
L_b = zeros(n_b, 1)
#show
for e_b = 1:n_b
  i_n = barras(e_b, 1)
  j_n = barras(e_b, 2)
  dx = nudos(j_n, 1) - nudos(i_n, 1)
  dy = nudos(j_n, 2) - nudos(i_n, 2)
  dz = nudos(j_n, 3) - nudos(i_n, 3)
  L_b(e_b) = sqrt(dx^2 + dy^2 + dz^2)
  k_e = klocal(L_b(e_b), A_s, I_s, I_s, J_s, E_m, G_m)
  T_e = matT(dx, dy, dz, barras(e_b, 3), barras(e_b, 4), barras(e_b, 5))
  gdl = [6·(i_n - 1) + (1:6), 6·(j_n - 1) + (1:6)]
  K_e(gdl, gdl) = K_e(gdl, gdl) + transpose(T_e)·k_e·T_e
  k_loc(12·(e_b - 1) + (1:12), 1:12) = k_e
  T_all(12·(e_b - 1) + (1:12), 1:12) = T_e
end

#: The loads: H/4 in x and the weight in -z at each of the 4 roof nodes (free nodes), and the list of the 24 free degrees of freedom.
#hide
libre = zeros(24, 1)
F_lin = zeros(n_g, 1)
F_ext = zeros(n_g, 1)
#show
n_l = 0
for n = 1:n_n
  if nudos(n, 4) == 0
    F_lin(6·(n - 1) + 1) = H_total/4
    F_lin(6·(n - 1) + 3) = -P_lineal
    F_ext(6·(n - 1) + 1) = H_total/4
    F_ext(6·(n - 1) + 3) = -P_nolineal
    for a = 1:6
      n_l = n_l + 1
      libre(n_l) = 6·(n - 1) + a
    end
  end
end

## 5 · LINEAR analysis: K·u = F
#: The fixed degrees of freedom are removed (the 24 on the ground) and the system of 24 equations is solved with the weight P_linear. The reactions come from K·U − F and the internal forces of each member from k_local·T·U.
#hide
Kff = K_e(libre, libre)
Ff = F_lin(libre)
#show
uf = gauss(Kff, Ff)
#hide
U_l = zeros(n_g, 1)
U_l(libre) = uf
R_l = K_e·U_l - F_lin
FI_l = zeros(n_b, 12)
#show
for e_b = 1:n_b
  gdl = [6·(barras(e_b, 1) - 1) + (1:6), 6·(barras(e_b, 2) - 1) + (1:6)]
  u_l = T_all(12·(e_b - 1) + (1:12), 1:12)·U_l(gdl)
  f_l = k_loc(12·(e_b - 1) + (1:12), 1:12)·u_l
  for i = 1:12
    FI_l(e_b, i) = f_l(i)
  end
end
u_x5 = U_l(25) 'lateral roof displacement, node 5, in the linear analysis [m]
N_l1 = FI_l(1, 1) 'axial force in column 1, end i [kN]
M_l1 = FI_l(1, 5) 'moment at the foot of column 1 [kN·m]
R_z1 = R_l(3) 'vertical reaction of node 1 [kN]
#hide
SF_x = H_total
for n = 1:n_n
  SF_x = SF_x + R_l(6·(n - 1) + 1)
end
#show
SF_x 'sum of forces in x: lateral load plus reactions, must give 0 [kN]

## 6 · Critical buckling load and linear analysis with the high load
#: With the high load P_nonlinear the linear result is computed first. Then the critical load is searched: the smallest λ for which K_{e} + λ·K_{g} stops being positive definite (the structure becomes unstable). First λ is doubled until it fails and then bisection is done: it is not known how many turns are needed (that is why it is a while).
#hide
U_lin = zeros(n_g, 1)
#show
uf2 = gauss(K_e(libre, libre), F_ext(libre))
U_lin(libre) = uf2
ux_lin = U_lin(25) 'linear lateral roof displacement with the high load [m]
lam_lo = 0
lam_hi = 1
#hide
K_c = ktang(U_lin, lam_hi, 0, k_loc, T_all, barras, L_b, Pm)
d_p = es_dp(K_c(libre, libre))
#show
while d_p == 1
  lam_lo = lam_hi
  lam_hi = 2·lam_hi
  K_c = ktang(U_lin, lam_hi, 0, k_loc, T_all, barras, L_b, Pm)
  d_p = es_dp(K_c(libre, libre))
end
n_bis = 0
while lam_hi - lam_lo > 1e-13·lam_hi
  lam_m = (lam_lo + lam_hi)/2
  K_c = ktang(U_lin, lam_m, 0, k_loc, T_all, barras, L_b, Pm)
  d_p = es_dp(K_c(libre, libre))
  if d_p == 1
    lam_lo = lam_m
  else
    lam_hi = lam_m
  end
  n_bis = n_bis + 1
end
lam_cr = (lam_lo + lam_hi)/2 'buckling load factor λcr (with kg_tipo = 2: 5.36739; with 1: 4.76987)
#hide
FI_k = zeros(n_b, 12)
#show
for e_b = 1:n_b
  gdl = [6·(barras(e_b, 1) - 1) + (1:6), 6·(barras(e_b, 2) - 1) + (1:6)]
  u_l = T_all(12·(e_b - 1) + (1:12), 1:12)·U_lin(gdl)
  f_l = k_loc(12·(e_b - 1) + (1:12), 1:12)·u_l
  for i = 1:12
    FI_k(e_b, i) = f_l(i)
  end
end

#: **Linear deformed shape with cursor.** 3D frame with the linear deformed shape (only the horizontal movement, amplified esc times). Drag to rotate. The cursor over a node gives its horizontal displacement ux in mm; over a member, the moment M at its two ends in kN·m (positive = tension on the outer face).
#hide
U3_lineal = zeros(8, 3)
ux_mm_lineal = zeros(8, 1)
M_ext_lineal = zeros(8, 2)
#show
for n = 1:n_n
  U3_lineal(n, 1) = U_lin(6·(n - 1) + 1)
  U3_lineal(n, 2) = U_lin(6·(n - 1) + 2)
  ux_mm_lineal(n) = 1000·U_lin(6·(n - 1) + 1)
end
for e = 1:n_b
  sg = 1
  if e <= 4
    sg = -1
  end
  M_ext_lineal(e, 1) = sg·(-FI_k(e, 5))
  M_ext_lineal(e, 2) = sg·FI_k(e, 11)
end
#modelo3d(X_n, sin_losa, e_n, ux_mm_lineal, M_ext_lineal, U3_lineal, esc)

## 7 · NONLINEAR P-Δ analysis: load control and Newton
#: The load is raised in steps (for, λ = 0.1, 0.2 … 1). In each step it repeats (while): the residual R = λ·F − F_{int}(U) is computed; if it is greater than the tolerance, the tangent stiffness K_{t} = K_{e} + K_{g}(N) is built with the current axial force, K_{t}·ΔU = R is solved and U is corrected. If a step does not converge, it is halved.
#hide
curva = zeros(60, 2)
U = zeros(n_g, 1)
#show
lam = 0
dlam_try = 1/n_inc
n_it = 0
n_c = 0
for inc = 1:n_inc
  lam_obj = inc/n_inc
  while lam < lam_obj - 1e-12
    dl = dlam_try
    if lam + dl > lam_obj
      dl = lam_obj - lam
    end
    lam_new = lam + dl
    U_prev = U
    Rr = lam_new·F_ext - fint(U, k_loc, T_all, barras, L_b, Pm)
    normR = sqrt(sum(Rr(libre)·Rr(libre)))
    iter = 0
    while normR > tol && iter < iter_max
      Kt = ktang(U, 1, tan_completa, k_loc, T_all, barras, L_b, Pm)
      du = gauss(Kt(libre, libre), Rr(libre))
      U(libre) = U(libre) + du
      Rr = lam_new·F_ext - fint(U, k_loc, T_all, barras, L_b, Pm)
      normR = sqrt(sum(Rr(libre)·Rr(libre)))
      iter = iter + 1
      n_it = n_it + 1
    end
    if normR <= tol
      lam = lam_new
      dlam_try = 1/n_inc
    else
      U = U_prev
      dlam_try = dl/2
    end
  end
  n_c = n_c + 1
  curva(n_c, 1) = lam
  curva(n_c, 2) = U(25)
end
#hide
U_pd = U
#show
u_x5_pd = U(25) 'roof lateral displacement with P-Δ, λ = 1 [m]
amp = U(25)/ux_lin 'P-Δ / linear amplification factor
amp_teo = 1/(1 - 1/lam_cr) 'estimate 1/(1 - λ/λcr)
n_it 'Newton iterations up to λ = 1

## 8 · Internal forces with P-Δ
#hide
FI_p = zeros(n_b, 12)
#show
for e_b = 1:n_b
  gdl = [6·(barras(e_b, 1) - 1) + (1:6), 6·(barras(e_b, 2) - 1) + (1:6)]
  u_l = T_all(12·(e_b - 1) + (1:12), 1:12)·U_pd(gdl)
  N = Pm(1)·Pm(2)/L_b(e_b)·(u_l(7) - u_l(1))
  g = kgeo(N, L_b(e_b), Pm(2), Pm(3), Pm(4), Pm(5))
  f_l = (k_loc(12·(e_b - 1) + (1:12), 1:12) + g)·u_l
  for i = 1:12
    FI_p(e_b, i) = f_l(i)
  end
end
M_p1 = FI_p(1, 5) 'moment at the foot of column 1 with P-Δ [kN·m]
M_k1 = FI_k(1, 5) 'moment at the foot of column 1 linear with the same load [kN·m]
N_p1 = FI_p(1, 1) 'axial force of column 1 with P-Δ [kN]

#: **Deformed shape with P-Δ and cursor.** The same with the nonlinear analysis: the cursor over a node gives ux in mm; over a member, M at its ends with P-Δ (kN·m).
#hide
U3_pdelta = zeros(8, 3)
ux_mm_pdelta = zeros(8, 1)
M_ext_pdelta = zeros(8, 2)
#show
for n = 1:n_n
  U3_pdelta(n, 1) = U_pd(6·(n - 1) + 1)
  U3_pdelta(n, 2) = U_pd(6·(n - 1) + 2)
  ux_mm_pdelta(n) = 1000·U_pd(6·(n - 1) + 1)
end
for e = 1:n_b
  sg = 1
  if e <= 4
    sg = -1
  end
  M_ext_pdelta(e, 1) = sg·(-FI_p(e, 5))
  M_ext_pdelta(e, 2) = sg·FI_p(e, 11)
end
#modelo3d(X_n, sin_losa, e_n, ux_mm_pdelta, M_ext_pdelta, U3_pdelta, esc)

## 9 · The complete curve up to near buckling
#: The load continues to be raised from λ = 1 to near λ_{cr} with the same Newton, to see how far the real curve departs from the linear straight line. Each point is saved (λ, roof displacement).
lam_fin = 0.9·lam_cr 'final load of the curve [λ]
n_ext = 12 'load steps of the extended part
for inc = 1:n_ext
  lam_obj = 1 + inc·(lam_fin - 1)/n_ext
  while lam < lam_obj - 1e-12
    dl = dlam_try
    if lam + dl > lam_obj
      dl = lam_obj - lam
    end
    lam_new = lam + dl
    U_prev = U
    Rr = lam_new·F_ext - fint(U, k_loc, T_all, barras, L_b, Pm)
    normR = sqrt(sum(Rr(libre)·Rr(libre)))
    iter = 0
    while normR > tol && iter < iter_max
      Kt = ktang(U, 1, tan_completa, k_loc, T_all, barras, L_b, Pm)
      du = gauss(Kt(libre, libre), Rr(libre))
      U(libre) = U(libre) + du
      Rr = lam_new·F_ext - fint(U, k_loc, T_all, barras, L_b, Pm)
      normR = sqrt(sum(Rr(libre)·Rr(libre)))
      iter = iter + 1
    end
    if normR <= tol
      lam = lam_new
      dlam_try = 1.0
    else
      U = U_prev
      dlam_try = dl/2
    end
  end
  n_c = n_c + 1
  curva(n_c, 1) = lam
  curva(n_c, 2) = U(25)
end
u_x5_fin = U(25) 'lateral roof displacement at the last step [m]
amp_fin = u_x5_fin/(lam·ux_lin) 'amplification with respect to the linear straight line at that step
#hide
cv_x = zeros(n_c + 1, 1)
cv_y = zeros(n_c + 1, 1)
for k = 1:n_c
  cv_x(k + 1) = curva(k, 2)·1000
  cv_y(k + 1) = curva(k, 1)
end
x_max = 1000·u_x5_fin
sy = 0.8·x_max/lam_fin
lin_x = [0, 1000·ux_lin·lam_fin]
lin_y = [0, sy·lam_fin]
cv_ys = sy·cv_y
#show

## 10 · 2D plots
#: **Frame elevation** (x-z plane, y = 0). Grey: undeformed. Blue: linear deformed shape. Red: P-Δ deformed shape at the same load. All amplified esc times so it can be seen; the curve of each column passes through the rotations of its ends. Each drawing is made in a single stroke: the path through the members (a negative member is traversed backwards).
lista2 = [1, 5, -2]
lista3 = [1, 5, -2, 2, 6, -3, 3, 7, -4, 4, 8]
#hide
Z0 = zeros(n_g, 1)
q0 = trazo(Z0, 0, nudos, barras, lista2, 0, 0)
ql = trazo(U_lin, esc, nudos, barras, lista2, 0, 0)
qp = trazo(U_pd, esc, nudos, barras, lista2, 0, 0)
#show
e0x = q0(1:33, 1) 'undeformed elevation: x of each point of the path [m]
e0z = q0(1:33, 2) 'undeformed elevation: z of each point of the path [m]
elx = ql(1:33, 1) 'amplified linear elevation: x [m]
elz = ql(1:33, 2) 'amplified linear elevation: z [m]
epx = qp(1:33, 1) 'amplified P-Δ elevation: x [m]
epz = qp(1:33, 2) 'amplified P-Δ elevation: z [m]
#: **Values at 33 points of the path** (for the cursor of the drawings and the plots): abscissa in m along the frame (from 0 to 3 the left column from bottom to top, from 3 to 8 the beam, from 8 to 11 the right column from top to bottom), M, V, N and ux of each point, linear and with P-Δ. Hb is the member, Hx the distance from its end i in m. Sign: positive = tension on the outer face.
#hide
cum = [0, L_b(1), L_b(1) + L_b(5)]
pth = [1, 5, 2]
dir_p = [1, 1, -1]
M_lin = zeros(33, 2)
M_pdelta = zeros(33, 2)
V_lin = zeros(33, 2)
V_pdelta = zeros(33, 2)
N_lin = zeros(33, 2)
N_pdelta = zeros(33, 2)
D_lin = zeros(33, 2)
D_pdelta = zeros(33, 2)
Hb = zeros(33, 1)
Hx = zeros(33, 1)
Hml = zeros(33, 1)
Hmp = zeros(33, 1)
Hvl = zeros(33, 1)
Hvp = zeros(33, 1)
Hnl = zeros(33, 1)
Hnp = zeros(33, 1)
Hdl = zeros(33, 1)
Hdp = zeros(33, 1)
#show
for q = 1:3
  e = pth(q)
  sg = 1
  if e <= 4
    sg = -1
  end
  i_n = barras(e, 1)
  j_n = barras(e, 2)
  gi = 6·(i_n - 1) + (1:6)
  gj = 6·(j_n - 1) + (1:6)
  Pk = deformada(nudos(i_n, 1:3), nudos(j_n, 1:3), U_lin(gi), U_lin(gj), 1, 1)
  Pp = deformada(nudos(i_n, 1:3), nudos(j_n, 1:3), U_pd(gi), U_pd(gj), 1, 1)
  for k = 1:11
    t = (k - 1)/10
    s = t
    if dir_p(q) < 0
      s = 1 - t
    end
    kb = round(10·s) + 1
    r = 11·(q - 1) + k
    xx = cum(q) + t·L_b(e)
    x0 = nudos(i_n, 1) + (nudos(j_n, 1) - nudos(i_n, 1))·s
    M_lin(r, 1) = xx
    M_pdelta(r, 1) = xx
    V_lin(r, 1) = xx
    V_pdelta(r, 1) = xx
    N_lin(r, 1) = xx
    N_pdelta(r, 1) = xx
    D_lin(r, 1) = xx
    D_pdelta(r, 1) = xx
    M_lin(r, 2) = sg·((1 - s)·(-FI_k(e, 5)) + s·FI_k(e, 11))
    M_pdelta(r, 2) = sg·((1 - s)·(-FI_p(e, 5)) + s·FI_p(e, 11))
    V_lin(r, 2) = sg·((1 - s)·FI_k(e, 3) + s·(-FI_k(e, 9)))
    V_pdelta(r, 2) = sg·((1 - s)·FI_p(e, 3) + s·(-FI_p(e, 9)))
    N_lin(r, 2) = sg·((1 - s)·(-FI_k(e, 1)) + s·FI_k(e, 7))
    N_pdelta(r, 2) = sg·((1 - s)·(-FI_p(e, 1)) + s·FI_p(e, 7))
    D_lin(r, 2) = 1000·(Pk(1, kb) - x0)
    D_pdelta(r, 2) = 1000·(Pp(1, kb) - x0)
    Hb(r) = e
    Hx(r) = s·L_b(e)
    Hml(r) = M_lin(r, 2)
    Hmp(r) = M_pdelta(r, 2)
    Hvl(r) = V_lin(r, 2)
    Hvp(r) = V_pdelta(r, 2)
    Hnl(r) = N_lin(r, 2)
    Hnp(r) = N_pdelta(r, 2)
    Hdl(r) = D_lin(r, 2)
    Hdp(r) = D_pdelta(r, 2)
  end
end

#dibujo("Elevation: undeformed (grey), linear (blue) and P-Δ (red), amplified ×400", ud = m, escala = auto, alto = 110, lado = derecha)
#  polilinea(e0x, e0z, "media gris")
#  polilinea(elx, elz, "gruesa azul")
#  polilinea(epx, epz, "gruesa rojo")
#  hover(e0x, e0z, "member {#1:0}, x = {#2:2} m: ux = {#3:2} mm (linear) / {#4:2} mm (P-Δ)", Hb, Hx, Hdl, Hdp)
#  hover(elx, elz, "member {#1:0}, x = {#2:2} m: ux = {#3:2} mm (linear) / {#4:2} mm (P-Δ)", Hb, Hx, Hdl, Hdp)
#  hover(epx, epz, "member {#1:0}, x = {#2:2} m: ux = {#3:2} mm (linear) / {#4:2} mm (P-Δ)", Hb, Hx, Hdl, Hdp)
#  flecha(-1.3, 3, -0.15, 3, "gruesa verde")
#  texto(-1.3, 3.25, "H/4 per node", 2.4, "i")
#  texto(2.5, 3.6, "linear: blue · P-Δ: red", 2.6, "c")
#fin

#: **Elevation diagrams.** They are drawn on each member, perpendicular to it: the moment M (kN·m), the shear V (kN) and the axial force N (kN, tension positive). Blue: linear with the same load. Red: P-Δ. Each diagram has its own scale so that it measures 1 m at its maximum value.
#hide
Mi_k = zeros(8, 1)
Mj_k = zeros(8, 1)
Mi_p = zeros(8, 1)
Mj_p = zeros(8, 1)
Vi_k = zeros(8, 1)
Vj_k = zeros(8, 1)
Vi_p = zeros(8, 1)
Vj_p = zeros(8, 1)
Ni_k = zeros(8, 1)
Nj_k = zeros(8, 1)
Ni_p = zeros(8, 1)
Nj_p = zeros(8, 1)
mx_M = 0
mx_V = 0
mx_N = 0
for e = 1:8
  sg = 1
  if e <= 4
    sg = -1
  end
  Mi_k(e) = sg·(-FI_k(e, 5))
  Mj_k(e) = sg·(FI_k(e, 11))
  Mi_p(e) = sg·(-FI_p(e, 5))
  Mj_p(e) = sg·(FI_p(e, 11))
  Vi_k(e) = sg·(FI_k(e, 3))
  Vj_k(e) = sg·(-FI_k(e, 9))
  Vi_p(e) = sg·(FI_p(e, 3))
  Vj_p(e) = sg·(-FI_p(e, 9))
  Ni_k(e) = sg·(-FI_k(e, 1))
  Nj_k(e) = sg·(FI_k(e, 7))
  Ni_p(e) = sg·(-FI_p(e, 1))
  Nj_p(e) = sg·(FI_p(e, 7))
  mx_M = max([mx_M, abs(Mi_p(e)), abs(Mj_p(e)), abs(Mi_k(e)), abs(Mj_k(e))])
  mx_V = max([mx_V, abs(Vi_p(e)), abs(Vi_k(e))])
  mx_N = max([mx_N, abs(Ni_p(e)), abs(Ni_k(e))])
end
dMk = diagrama(nudos, barras, lista2, Mi_k, Mj_k, 1/mx_M)
dMp = diagrama(nudos, barras, lista2, Mi_p, Mj_p, 1/mx_M)
dVk = diagrama(nudos, barras, lista2, Vi_k, Vj_k, 1/mx_V)
dVp = diagrama(nudos, barras, lista2, Vi_p, Vj_p, 1/mx_V)
dNk = diagrama(nudos, barras, lista2, Ni_k, Nj_k, 1/mx_N)
dNp = diagrama(nudos, barras, lista2, Ni_p, Nj_p, 1/mx_N)
#show
mx_M 'maximum moment of the diagrams [kN·m]
mx_V 'maximum shear of the diagrams [kN]
mx_N 'maximum axial force of the diagrams [kN]
mkx = dMk(1:12, 1) 'linear M diagram: x [m]
mkz = dMk(1:12, 2) 'linear M diagram: z [m]
mpx = dMp(1:12, 1) 'M diagram with P-Δ: x [m]
mpz = dMp(1:12, 2) 'M diagram with P-Δ: z [m]
vkx = dVk(1:12, 1) 'linear V diagram: x [m]
vkz = dVk(1:12, 2) 'linear V diagram: z [m]
vpx = dVp(1:12, 1) 'V diagram with P-Δ: x [m]
vpz = dVp(1:12, 2) 'V diagram with P-Δ: z [m]
nkx = dNk(1:12, 1) 'linear N diagram: x [m]
nkz = dNk(1:12, 2) 'linear N diagram: z [m]
npx = dNp(1:12, 1) 'N diagram with P-Δ: x [m]
npz = dNp(1:12, 2) 'N diagram with P-Δ: z [m]
#dibujo("Moment M (kN·m): linear (blue) and P-Δ (red)", ud = m, escala = auto, alto = 100, lado = derecha)
#  polilinea(e0x, e0z, "fina gris")
#  polilinea(mkx, mkz, "media azul")
#  polilinea(mpx, mpz, "media rojo")
#  hover(e0x, e0z, "member {#1:0}, x = {#2:2} m: M = {#3:2} kN·m (linear) / {#4:2} kN·m (P-Δ)", Hb, Hx, Hml, Hmp)
#fin
#dibujo("Shear V (kN): linear (blue) and P-Δ (red)", ud = m, escala = auto, alto = 100, lado = derecha)
#  polilinea(e0x, e0z, "fina gris")
#  polilinea(vkx, vkz, "media azul")
#  polilinea(vpx, vpz, "media rojo")
#  hover(e0x, e0z, "member {#1:0}, x = {#2:2} m: V = {#3:2} kN (linear) / {#4:2} kN (P-Δ)", Hb, Hx, Hvl, Hvp)
#fin
#dibujo("Axial N (kN, tension +): linear (blue) and P-Δ (red)", ud = m, escala = auto, alto = 100, lado = derecha)
#  polilinea(e0x, e0z, "fina gris")
#  polilinea(nkx, nkz, "media azul")
#  polilinea(npx, npz, "media rojo")
#  hover(e0x, e0z, "member {#1:0}, x = {#2:2} m: N = {#3:2} kN (linear) / {#4:2} kN (P-Δ)", Hb, Hx, Hnl, Hnp)
#fin

#: **Load-displacement curve.** Horizontal axis: lateral roof displacement in mm. Vertical axis: the load factor λ (the loads are λ·H and λ·P). Blue: the linear analysis straight line. Red: the P-Δ curve, which separates to the right and becomes almost horizontal as it approaches λcr.
x_max = 1000·u_x5_fin 'final roof displacement on the curve [mm]
sy = 0.8·x_max/lam_fin 'vertical scale so the plot is not squashed [mm per unit of λ]
lin_x = [0, 1000·ux_lin·lam_fin] 'linear straight line: displacement of its two points [mm]
lin_y = [0, sy·lam_fin] 'linear straight line: height of its two points (λ·sy)
#hide
cv_xx = zeros(n_c + 1, 1)
cv_yy = zeros(n_c + 1, 1)
for k = 1:n_c
  cv_xx(k + 1) = curva(k, 2)·1000
  cv_yy(k + 1) = sy·curva(k, 1)
end
#show
cv_x = cv_xx(1:n_c + 1) 'P-Δ curve: roof displacement at each step [mm]
cv_y = cv_yy(1:n_c + 1) 'P-Δ curve: λ of each step times sy
#: Cursor over each point: it gives (roof displacement in mm; λ). Blue: linear. Red: P-Δ.
#hide
C_lineal = zeros(n_c, 2)
C_pdelta = zeros(n_c, 2)
#show
for k = 1:n_c
  C_lineal(k, 1) = 1000·ux_lin·curva(k, 1)
  C_lineal(k, 2) = curva(k, 1)
  C_pdelta(k, 1) = 1000·curva(k, 2)
  C_pdelta(k, 2) = curva(k, 1)
end
#fplot(lineal = C_lineal, P_Delta = C_pdelta, [0 45])

#: **The diagrams with cursor.** Abscissa = path along the frame in m: from 0 to 3 the left column (from bottom to top), from 3 to 8 the beam, from 8 to 11 the right column (from top to bottom). Cursor over a point: it gives (abscissa; value). Sign: positive = tension on the outer face. Blue: linear. Red: P-Δ.
#: Moment M (kN·m):
#fplot(M_lineal = M_lin, M_PDelta = M_pdelta, [0 11])
#: Shear V (kN):
#fplot(V_lineal = V_lin, V_PDelta = V_pdelta, [0 11])
#: Axial N (kN, tension positive):
#fplot(N_lineal = N_lin, N_PDelta = N_pdelta, [0 11])
#: Horizontal displacement ux along the path (mm; the elevation with cursor):
#fplot(ux_lineal = D_lin, ux_PDelta = D_pdelta, [0 11])

## 11 · 3D plot: the frame in perspective
#: The 8 members in a three-dimensional view (rotated 35° about the vertical and tilted 25°). Grey: undeformed. Blue: linear. Red: P-Δ. The columns and the beams of the x-z plane follow the Hermite curve; the beams in y are drawn straight between the displaced nodes.
az_v = 35 'rotation of the view about the vertical [degrees]
el_v = 25 'tilt of the view [degrees]
#hide
r0 = trazo(Z0, 0, nudos, barras, lista3, az_v, el_v)
rl = trazo(U_lin, esc, nudos, barras, lista3, az_v, el_v)
rp = trazo(U_pd, esc, nudos, barras, lista3, az_v, el_v)
#show
t0x = r0(1:121, 1) 'undeformed 3D view: abscissa of each point [m]
t0z = r0(1:121, 2) 'undeformed 3D view: ordinate of each point [m]
tlx = rl(1:121, 1) 'linear 3D view: abscissa [m]
tlz = rl(1:121, 2) 'linear 3D view: ordinate [m]
tpx = rp(1:121, 1) 'P-Δ 3D view: abscissa [m]
tpz = rp(1:121, 2) 'P-Δ 3D view: ordinate [m]
#dibujo("3D frame: undeformed (grey), linear (blue) and P-Δ (red), amplified ×400", ud = m, escala = auto, alto = 130)
#  polilinea(t0x, t0z, "media gris")
#  polilinea(tlx, tlz, "gruesa azul")
#  polilinea(tpx, tpz, "gruesa rojo")
#fin

## 12 · Check against OpenSees 3.7.1
#: The same numbers computed with OpenSees (elasticBeamColumn: Linear for the linear and PDelta for the nonlinear) with the same model, node by node. The relative difference must be of the order of 1e-12 or less.
ux_os = 8.733272492881403e-04 'OpenSees linear: ux displacement of node 5 [m]
dif_ux = abs(u_x5 - ux_os)/ux_os 'relative difference of the linear one
M_os = 22.85054517674827 'OpenSees linear: My moment at the foot of column 1 [kN·m]
dif_M = abs(M_l1 - M_os)/M_os 'relative difference of the moment
uxp_os = 1.073290497343695e-03 'OpenSees PDelta: ux displacement of node 5 with high P [m]
dif_uxp = abs(u_x5_pd - uxp_os)/uxp_os 'relative difference of the P-Δ
N_os = 7992.798509774815 'OpenSees PDelta: axial force of column 1 [kN]
dif_N = abs(abs(N_p1) - N_os)/N_os 'relative difference of the axial force
lcr_os = 5.36743 'OpenSees PDelta: critical load λcr, by fitting 1/(1 - λ/λcr)
dif_lcr = abs(lam_cr - lcr_os)/lcr_os 'relative difference of the critical load (OpenSees only gives 6 digits)
