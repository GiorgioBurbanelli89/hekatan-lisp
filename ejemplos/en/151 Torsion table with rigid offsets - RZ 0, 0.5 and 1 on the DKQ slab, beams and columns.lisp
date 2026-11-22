# Torsion table with rigid offsets: what changes when the members are stiffened at the joints
#numerico

#: **What this sheet does.** It is the **torsion table of example 83** (6 × 6 m slab of 10 cm on 4 V30×50 beams and 4 C40×40 columns of 4 m, live load 0.5 tonf/m²) solved **three times**: with the rigid offsets of SAP2000 and ETABS at **0 %, 50 % and 100 %** (factor **RZ** = 0, 0.5 and 1). Everything else is identical: Q6 + DKQ slab, Timoshenko members and pinned supports.
#: **Why it matters.** The members of the model run **axis to axis**, but the part of the beam that enters the column (and that of the column that enters the beam) does not bend: it is inside a block of concrete. That stretch is the **offset**. With RZ = 0 it exists but stiffens nothing (it is what example 83 uses and what ETABS gives by default); with RZ = 1 the whole offset is rigid and the member only bends along its **free length**. The derivation of the CSI rules is in example 111; here you see **how much the table changes**.
#: **The automatic ETABS rule** (*Automatic from Connectivity*): the **beam** carries at each end that touches a column an offset of **half the column side** (0.40/2 = 0.20 m); the **column** carries at its top end an offset of **the whole beam depth** (0.50 m). Bending and shear use the free length L_{f} = L − l_{I} − l_{J}; axial and torsion continue with the full length: K = Tᵀ·k(L_{f})·T.
#: **Units:** kN and m when calculating; results in tonf and tonf·m dividing by g = 9.80665. **What is compared:** central deflection, slab moments, column forces and beam torsion. With RZ = 0 the numbers are those of 83 (which match ETABS to 6 decimals in the slab): it is the check that the program of this sheet is the same.

## A · The offset, in symbols

#: One end of the member does not move like the joint: the point where the flexible stretch begins is at a distance l from the joint, **on a solid that rotates with it**. In the bending plane, if the joint goes down v and rotates θ, that point goes down **v + l·θ** (the lever) and rotates the same. At the other end the offset goes backward: v − l·θ. In matrix form, with the degrees (v_{I}, θ_{I}, v_{J}, θ_{J}):
T_b = Simplify{[1, l_i, 0, 0; 0, 1, 0, 0; 0, 0, 1, -l_j; 0, 0, 0, 1]}
#: The energy of the flexible stretch, ½·u′ᵀ·k(L_{f})·u′ with u′ = T·u, is read from the joints as ½·uᵀ·(Tᵀ·k·T)·u. With the Euler-Bernoulli member of free length L_{f}:
k_f = Simplify{E*I/L_f^3*[12, 6*L_f, -12, 6*L_f; 6*L_f, 4*L_f^2, -6*L_f, 2*L_f^2; -12, -6*L_f, 12, -6*L_f; 6*L_f, 2*L_f^2, -6*L_f, 4*L_f^2]}
K_br = Simplify{transpose([1, l_i, 0, 0; 0, 1, 0, 0; 0, 0, 1, -l_j; 0, 0, 0, 1])*(E*I/L_f^3*[12, 6*L_f, -12, 6*L_f; 6*L_f, 4*L_f^2, -6*L_f, 2*L_f^2; -12, -6*L_f, 12, -6*L_f; 6*L_f, 2*L_f^2, -6*L_f, 4*L_f^2])*[1, l_i, 0, 0; 0, 1, 0, 0; 0, 0, 1, -l_j; 0, 0, 0, 1]}
#: Reading of the second row: the stiffness to the deflection v_{I} does not change (12EI/L_{f}³), but that of **rotation grows**: 4EI/L_{f} becomes 4EI/L_{f} + 12·EI·l_{I}²/L_{f}³ + 12·EI·l_{I}/L_{f}². The offset is a lever that makes the joint stiffer. In 3D these are the same relations in each bending plane: v′ = v + l·θz and w′ = w − l·θy at end I, v′ = v − l·θz and w′ = w + l·θy at J; **axial and torsion are not touched**.

## B · Numerical results

### B.1 · Data
L_x = 6 'slab span in x and in y (m)
H_c = 4 'column height (m)
t = 0.1 'slab thickness (m)
E = 24.85e6 'modulus of elasticity (kN/m²)
ν = 0.2 'Poisson's ratio
G_c = E/(2·(1 + ν)) 'shear modulus (kN/m²)
g_0 = 9.80665 'kN per tonf
b_c = 0.4 'column: width (m)
h_c = 0.4 'column: depth (m)
b_v = 0.3 'beam: width (m)
h_v = 0.5 'beam: depth (m)
o_f = h_v 'rigid offset at the column top: the moment is reported at the beam face (m)
off_v = b_c/2 'beam offset at the end that touches a column: half the column side (m)
off_c = h_v 'column offset at its top end: the whole beam depth (m)
#: **Sections.** J with the Saint-Venant formula for a rectangle, with the CUBE of the short side: J = β·a·b³, β = 1/3 − 0.21·(b/a)·(1 − (b/a)⁴/12).
A_c = b_c·h_c
I_yc = h_c·b_c^3/12
I_zc = b_c·h_c^3/12
J_c = stv(b_c, h_c)
A_v = b_v·h_v
I_yv = b_v·h_v^3/12 'strong inertia of the beam (vertical bending)
I_zv = h_v·b_v^3/12
J_v = stv(b_v, h_v)

### B.2 · Mesh
#: 5 × 5 slab elements of 1.2 m (ETABS automesh at ≤ 1.25 m). Nodes: 4 at the base of the columns and 36 in the slab, at height H.
n_e = 5 'elements per side
n_1 = n_e + 1 'nodes per side
d = L_x/n_e 'element side (m)
n_j = 4 + n_1^2 'nodes
n_d = 6·n_j 'degrees of freedom
#: The slab node of column i and row j of the mesh (i, j = 0 … 5):
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
#: Slab plan: 25 elements; the columns are at the 4 corners and the beams run along the edge.
#malla(x_j, y_j, e_j, s_j)
n_s = n_e^2 'slab elements
n_c = 4 'columns
n_b = 4·n_e 'beam segments (each beam is split at the slab nodes)


### B.3 · Element matrices
#: They are the formulas of part A with the table data. They are not written again: one term of each is checked against its algebraic expression.
a_e = d/2 'half side of the slab element (m)
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
#: **Q6 membrane** (A.4):
K_m11 = K_m(1, 1) 'from the program (kN/m)
K_m11f = E·t·(11 - 3·ν - 2·ν^2)/(24·(1 - ν^2)) 'formula K_Q6(1, 1)
#: **DKQ plate** (A.5):
D_p = E·t^3/(12·(1 - ν^2)) 'bending stiffness (kN·m)
K_b11 = K_b(1, 1) 'from the program (kN/m)
K_b11f = 10·D_p/d^2 'formula K_DKQ(1, 1), Gauss 2 × 2
K_b11e = (51 - ν)·D_p/(5·d^2) 'with the exact integral: DKQ does NOT use it
#: **In-plane rotation** (A.6):
k_θ = s_m/(8·10^6) 'spring of θz (kN·m/rad)
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

### B.4 · Assembly, supports and live load
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
#: **Supports.** Column base pinned (ETABS: RESTRAINT "UX UY UZ"): u, v, w of nodes 1 to 4 are removed; their rotations stay free.
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
n_q = k 'free equations
#: **Live** (0.5 tonf/m²) at the slab nodes by tributary area: d² in the interior, d²/2 at the edge, d²/4 at the corner. It is the same load for the three models.
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

### B.5 · The member with offset: free length and K = Tᵀ·k·T
#: The function `frame_Koff` is the 12 × 12 Timoshenko member of example 83 with the two CSI rules: **bending and shear with L_{f}** and **axial and torsion with L**, and then the offset transformation T (which moves v and w with the lever of θz and θy). It is checked on the edge beam, first segment (d = 1.2 m, offset of 0.20 m on the column side):
l_ej = off_v 'offset of the first beam segment, RZ = 1 (m)
#hide
k_sin = frame_K(E, G_c, A_v, I_yv, I_zv, J_v, d)
k_con = frame_Koff(E, G_c, A_v, I_yv, I_zv, J_v, d, l_ej, 0)
#show
#: Deflection-deflection of the vertical bending (term 3,3) and axial (1,1), without and with offset. The **axial does not change**; the bending **grows** because the flexible stretch drops from 1.20 to 1.00 m and the stiffness goes with 1/L_{f}³:
k_33_sin = k_sin(3, 3) 'deflection, without offset (kN/m)
k_33_con = k_con(3, 3) 'deflection, with offset (kN/m)
k_11_sin = k_sin(1, 1) 'axial, without offset (kN/m)
k_11_con = k_con(1, 1) 'axial, with offset (kN/m)
r_33 = k_33_con/k_33_sin 'how many times the bending stiffness of the segment grows

### B.6 · The three models: RZ = 0, 0.5 and 1
#: For each RZ, K is assembled again (the slab is the same; the members change: columns with offset at the top and the two beam segments that touch each column), **K·u = F** is solved and the results are extracted. The slab is recovered with the DKQ (envelope of the elements reaching each node, like the ETABS table).
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
#: **Results table.** Columns: RZ · deflection at node (2.4, 2.4) in mm · max. |Mxx|, |Myy| and |Mxy| of the slab (tonf·m/m) · shear and moment at the top end of column 1 (tonf, tonf·m) · torsion and moment of the first segment of the edge beam (tonf·m). With RZ = 0 it is the model of example 83.
S_tab
#hide
w_0 = round(S_tab(1, 2), 3)
w_1 = round(S_tab(3, 2), 3)
dw = round(100·(S_tab(3, 2)/S_tab(1, 2) - 1), 1)
dc = round(100·(S_tab(3, 6)/S_tab(1, 6) - 1), 1)
dt = round(100·(S_tab(3, 8)/S_tab(1, 8) - 1), 1)
dm = round(100·(S_tab(3, 3)/S_tab(1, 3) - 1), 1)
#show
#: **Reading.** With the offsets at 100 % the central deflection changes **@{dw} %** (from @{w_0} to @{w_1} mm), the maximum slab moment Mxx **@{dm} %**, the column shear **@{dc} %** and the edge beam torsion **@{dt} %**. The joints become stiffer: the members bend over a shorter length, attract more force and the slab is unloaded or loaded depending on the case. That is why it is worth knowing which offsets the reference model uses before comparing two programs.

### B.7 · Slab maps with RZ = 1 and their difference with RZ = 0
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
#: **Deflection w** (mm, downward) with RZ = 1:
transpose(W_a)
w_z(x, y) = bil(W_a, x, y, d, n_e)
#map(w_z(x, y), [0 L_x], [0 L_x])
#: **Mxx** (tonf·m/m) with RZ = 1:
transpose(M_a)
m_x(x, y) = bil(M_a, x, y, d, n_e)
#map(m_x(x, y), [0 L_x], [0 L_x])
#: **Difference of Mxx** between RZ = 1 and RZ = 0: where the moments move when the joints are stiffened.
transpose(M_d)
d_x(x, y) = bil(M_d, x, y, d, n_e)
#map(d_x(x, y), [0 L_x], [0 L_x])
#: **What follows:** the real ETABS offsets for the table are assigned with *Assign → Frame → End Length Offsets* and the RZ factor; Hekatan Struct reads them the same way (`endoffset`, `rigidzone`). The loading of the spans with offset and the mass inside the offset, which do not intervene here (Live only), are in example 111.

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
