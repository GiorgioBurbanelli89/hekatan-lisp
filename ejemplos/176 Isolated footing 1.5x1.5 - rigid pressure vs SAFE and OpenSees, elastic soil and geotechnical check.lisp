# Isolated footing 1.50 × 1.50 m: rigid pressure, plate on springs and soil by FEM (2D membrane, 3D solid) vs SAFE and OpenSees, geotechnical check
#numerico

## 1 · Data

B = 1.5 'side [m]
t = 0.6 'thickness [m]
D_f = 1.5 'depth [m]
P = 400 'axial load [kN]
M_x = 40 'moment about x [kN·m]
M_y = 20 'moment about y [kN·m]
k_s = 20000 'subgrade modulus [kN/m3]
gamma = 18 'soil unit weight [kN/m3]
phi = 30 'friction angle [deg]
E_s = 20000 'soil modulus [kPa]
nu_s = 0.3 'soil Poisson ratio
FS = 3 'safety factor

## 2 · Rigid footing: linear pressure

#sust
A = B^2
I = B^4/12
e_x = M_y/P
e_y = M_x/P
#equ
q(x, y) = P/A + M_y·x/I - M_x·y/I
#sust
q_max = q(B/2, -B/2)
q_min = q(-B/2, B/2)
#equ
c_col = 0.4 'column side [m]
q_xp = q(B/2, 0) 'pressure at x = +B/2, y = 0 [kPa]
q_xm = q(-B/2, 0) 'pressure at x = −B/2, y = 0 [kPa]
#dibujo("Footing and column: elevation (y = 0) and plan", ud = m, escala = auto, cotas = m, alto = 120)
#  linea(-1.3, 0, 1.3, 0, "media gris")
#  achurado(-B/2, -D_f, B, t, "concreto")
#  rect(-B/2, -D_f, B, t, "gruesa")
#  achurado(-c_col/2, t - D_f, c_col, D_f - t + 0.6, "concreto")
#  rect(-c_col/2, t - D_f, c_col, D_f - t + 0.6, "gruesa")
#  flecha(0, 1.45, 0, 0.62, "gruesa rojo")
#  texto(-0.25, 1.3, "P = {P:0} kN", 2.6, "d")
#  flechamomento(0, 0.95, 0.38, 150, 30, "rojo")
#  texto(0.45, 0.95, "M_y = {M_y:0} kN·m", 2.6, "i")
#  carga(B/2, -D_f, -B/2, -D_f, 0.5*q_xp/q_max, 0.5*q_xm/q_max, "soil pressure at y = 0: {q_xm:1} → {q_xp:1} kPa", "azul")
#  cota(-B/2, -D_f - 1.0, B/2, -D_f - 1.0, 0, "B = {B:2} m")
#  cota(-B/2 - 0.2, -D_f, -B/2 - 0.2, t - D_f, 0, "t = {t:2} m")
#  cota(B/2 + 0.2, -D_f, B/2 + 0.2, 0, 0, "D_f = {D_f:1} m")
#  rect(2.9 - B/2, -0.55 - B/2, B, B, "gruesa")
#  rect(2.9 - c_col/2, -0.55 - c_col/2, c_col, c_col, "gruesa denso gris")
#  flecha(2.9, -0.55, 3.9, -0.55, "fina")
#  texto(3.95, -0.55, "x", 2.6, "i")
#  flecha(2.9, -0.55, 2.9, 0.45, "fina")
#  texto(2.95, 0.45, "y", 2.6, "i")
#  circulo(2.9 + B/2, -0.55 - B/2, 0.05, "rojo denso")
#  texto(2.9 + B/2 + 0.08, -0.55 - B/2 - 0.12, "q_max = {q_max:1} kPa", 2.4, "i")
#  circulo(2.9 - B/2, -0.55 + B/2, 0.05, "azul denso")
#  texto(2.9 - B/2 - 0.08, -0.55 + B/2 + 0.12, "q_min = {q_min:1} kPa", 2.4, "d")
#  texto(2.9, -0.55 - B/2 - 0.3, "plan · M_x = {M_x:0} kN·m, M_y = {M_y:0} kN·m", 2.4, "c")
#  hover([2.9 + B/2, 2.9 - B/2, 2.9 + B/2, 2.9 - B/2, 2.9], [-0.55 - B/2, -0.55 + B/2, -0.55 + B/2, -0.55 - B/2, -0.55], "q = {#1:2} kPa (rigid)", [q_max, q_min, P/A + (M_y - M_x)*B/2/I, P/A - (M_y - M_x)*B/2/I, P/A])
#fin
#sust
#contourf(q(x, y), [-B/2 B/2], [-B/2 B/2])
#: Right-hand rule: M_x > 0 compresses the −y side, M_y > 0 the +x side. e_x, e_y ≤ B/6 = 0.25 m: the whole base is in compression.

## 3 · Hekatan LISP by finite elements: MITC4 plate on Winkler soil

#: The same model as SAFE and OpenSees, built here step by step: a Mindlin plate of 4 nodes with MITC4 shear (the element of OpenSees ShellMITC4), 3 dof per node [w, θ_x, θ_y], 10 × 10 mesh, soil springs k_s·A_trib at each node.

#: **Symbolic: shape functions and Jacobian.** Element of sides 2a × 2b, natural coordinates ξ, η ∈ [−1, 1]. Shape function of node 1 and the map x(ξ), y(η):
N_1 = Simplify{(1-xi)*(1-eta)/4}
x_s = Simplify{a*(-(1-xi)*(1-eta)/4 + (1+xi)*(1-eta)/4 + (1+xi)*(1+eta)/4 - (1-xi)*(1+eta)/4)}
y_s = Simplify{b*(-(1-xi)*(1-eta)/4 - (1+xi)*(1-eta)/4 + (1+xi)*(1+eta)/4 + (1-xi)*(1+eta)/4)}
J_11 = Partial{a*xi @ xi}
J_22 = Partial{b*eta @ eta}
J_12 = Partial{a*xi @ eta}
J_det = Simplify{a*b - 0*0}
#: det J = a·b converts dξ·dη into dx·dy. Derivatives in x and y: ∂N/∂x = (1/a)·∂N/∂ξ, ∂N/∂y = (1/b)·∂N/∂η:
N_1_x = Simplify{Partial{(1-xi)*(1-eta)/4 @ xi}/a}
N_1_y = Simplify{Partial{(1-xi)*(1-eta)/4 @ eta}/b}
#: **Symbolic: plate stiffnesses and MITC4 shear.** Bending D = E·t³/(12(1 − ν²)); shear C_s = (5/6)·G·t. The shear strain γ_xz is not taken at the Gauss points (that locks a thin plate) but at the mid-sides A = (0, −1), B = (0, 1) and interpolated in η:
D_flex = Simplify{E*h^3/(12*(1-nu^2))}
C_shear = Simplify{5/6*E/(2*(1+nu))*h}
g_xz = Simplify{(1-eta)/2*g_A + (1+eta)/2*g_B}
#: Closed form of two terms of the element matrix (integrated by hand over 2a × 2b):
K_ww = Simplify{C*(b/(3*a) + a/(3*b))}
K_tt = Simplify{D*b/(3*a) + D*(1-nu)*a/(6*b) + C*a*b/3}

#: **Numeric: element matrix 12 × 12** with 2 × 2 Gauss points:
E_c = 24.87e6 'concrete modulus [kPa]
nu_c = 0.2 'concrete Poisson ratio
n_x = 10 'elements per side
h_e = B/n_x 'element size [m]
a_e = h_e/2 'half side [m]
D_0 = E_c·t^3/(12·(1 - nu_c^2)) 'bending stiffness [kN·m]
C_s = 5/6·E_c/(2·(1 + nu_c))·t 'shear stiffness [kN/m]
D_b = D_0·[1, nu_c, 0; nu_c, 1, 0; 0, 0, (1 - nu_c)/2]
N_n(r, s) = [(1 - r)·(1 - s)/4, (1 + r)·(1 - s)/4, (1 + r)·(1 + s)/4, (1 - r)·(1 + s)/4]
d_x(r, s) = [-(1 - s)/4, (1 - s)/4, (1 + s)/4, -(1 + s)/4]/a_e
d_y(r, s) = [-(1 - r)/4, -(1 + r)/4, (1 + r)/4, (1 - r)/4]/a_e
#hide
S_w = zeros(4, 12)
S_x = zeros(4, 12)
S_y = zeros(4, 12)
for k = 1:4
  S_w(k, 3·k - 2) = 1
  S_x(k, 3·k - 1) = 1
  S_y(k, 3·k) = 1
end
#show
B_b(r, s) = [transpose(d_x(r, s))·S_y; -transpose(d_y(r, s))·S_x; transpose(d_y(r, s))·S_y - transpose(d_x(r, s))·S_x]
B_xz(r, s) = transpose(d_x(r, s))·S_w + transpose(N_n(r, s))·S_y
B_yz(r, s) = transpose(d_y(r, s))·S_w - transpose(N_n(r, s))·S_x
G_xz(r, s) = (1 - s)/2·B_xz(0, -1) + (1 + s)/2·B_xz(0, 1)
G_yz(r, s) = (1 - r)/2·B_yz(-1, 0) + (1 + r)/2·B_yz(1, 0)
g_p = 1/sqrt(3) 'Gauss coordinate
r_g = [-g_p, g_p, g_p, -g_p]
s_g = [-g_p, -g_p, g_p, g_p]
j_d = a_e^2 'det J [m2]
#hide
K_e = zeros(12, 12)
for p = 1:4
  B_1 = B_b(r_g(p), s_g(p))
  g_1 = G_xz(r_g(p), s_g(p))
  g_2 = G_yz(r_g(p), s_g(p))
  K_e = K_e + j_d·(transpose(B_1)·D_b·B_1 + C_s·(transpose(g_1)·g_1 + transpose(g_2)·g_2))
end
#show
#: Check against the closed forms (must be 0):
dK_ww = round(K_e(1, 1) - C_s·2/3, 6)
dK_tt = round(K_e(3, 3) - (D_0/3 + D_0·(1 - nu_c)/6 + C_s·a_e^2/3), 6)

#: **Mesh, springs, load, assembly and solution.** Nodes row by row from (−B/2, −B/2); spring k_s·A_trib (corner h²/4, edge h²/2, inside h²); P, M_x, M_y at the center node:
n_n = n_x + 1
n_j = n_n^2
n_g = 3·n_j
#hide
e_j = zeros(n_x^2, 4)
for j = 1:n_x
  for i = 1:n_x
    nd = (j - 1)·n_n + i
    e_j((j - 1)·n_x + i, 1) = nd
    e_j((j - 1)·n_x + i, 2) = nd + 1
    e_j((j - 1)·n_x + i, 3) = nd + n_n + 1
    e_j((j - 1)·n_x + i, 4) = nd + n_n
  end
end
A_n = zeros(n_j, 1)
for e = 1:n_x^2
  for c = 1:4
    A_n(e_j(e, c)) = A_n(e_j(e, c)) + h_e^2/4
  end
end
K = zeros(n_g, n_g)
for e = 1:n_x^2
  g = [3·e_j(e, 1) - 2, 3·e_j(e, 1) - 1, 3·e_j(e, 1), 3·e_j(e, 2) - 2, 3·e_j(e, 2) - 1, 3·e_j(e, 2), 3·e_j(e, 3) - 2, 3·e_j(e, 3) - 1, 3·e_j(e, 3), 3·e_j(e, 4) - 2, 3·e_j(e, 4) - 1, 3·e_j(e, 4)]
  K(g, g) = K(g, g) + K_e
end
for nd = 1:n_j
  K(3·nd - 2, 3·nd - 2) = K(3·nd - 2, 3·nd - 2) + k_s·A_n(nd)
end
n_c = (n_x/2)·n_n + n_x/2 + 1
F = zeros(n_g, 1)
F(3·n_c - 2) = -P
F(3·n_c - 1) = M_x
F(3·n_c) = M_y
U_f = clsolve(K, F)
p_f = zeros(n_j, 1)
R_f = 0
for nd = 1:n_j
  p_f(nd) = -k_s·U_f(3·nd - 2)
  R_f = R_f + p_f(nd)·A_n(nd)
end
P_m = zeros(n_n, n_n)
for j = 1:n_n
  for i = 1:n_n
    P_m(i, j) = p_f((j - 1)·n_n + i)
  end
end
#show
R_f 'sum of soil reactions = P [kN]
p_fem(x, y) = spline(1 + (x + B/2)/h_e, 1 + (y + B/2)/h_e, P_m)
#contourf(p_fem(x, y), [-B/2 B/2], [-B/2 B/2])
#: **3D:** the same soil pressure as a surface (on Winkler springs the settlement w = p/k_s has the same shape). Drag to rotate, hover for the value:
#surf(p_fem(x, y), [-B/2 B/2], [-B/2 B/2])

## 4 · Validation: Hekatan LISP vs SAFE 20 vs OpenSees

#: Same mesh node by node, offsets = 0. Corners are nodes 121 (+,+), 111 (−,+), 11 (+,−), 1 (−,−); center node 61.
#equ
t_rig = [q(B/2, -B/2), q(-B/2, -B/2), q(B/2, B/2), q(-B/2, B/2), q(0, 0)] 'rigid formula [kPa]
t_hek = [p_f(11), p_f(1), p_f(n_j), p_f(n_j - n_x), p_f(n_c)] 'Hekatan LISP MITC4 [kPa]
t_safe = [281.947055, 212.251649, 142.556242, 72.860836, 178.821362] 'SAFE 20 [kPa]
t_ops = [281.960118, 212.260957, 142.561796, 72.862635, 178.811271] 'OpenSees ShellMITC4 [kPa]
#tabla("Point (x; y) [m]","Rigid formula [kPa]:2","Hekatan LISP [kPa]:6","OpenSees [kPa]:6","SAFE 20 [kPa]:6")({"(0.75; −0.75)","(−0.75; −0.75)","(0.75; 0.75)","(−0.75; 0.75)","(0; 0)"}; t_rig; t_hek; t_ops; t_safe)
d_ops = max(abs(t_hek - t_ops)) 'max |Hekatan − OpenSees| [kPa]
d_safe = max(abs(t_hek - t_safe)) 'max |Hekatan − SAFE| [kPa]
#: Hekatan LISP and OpenSees solve the same element (MITC4) and the same springs: they agree to the printed digits. SAFE's thick shell is a slightly different element: 0.005 %. The 1–2.5 % to the rigid formula is the bending of the real 0.60 m footing.

## 5 · The soil by finite elements (1): 2D membrane, plane strain

#: Now the SOIL itself is meshed (not springs): a vertical cut through the footing at y = 0, soil 4.5 m wide and 3 m deep with 0.25 m quads, the 0.60 m concrete footing on top (6 × 2 quads). Plane strain: a slice 1 m thick, load P/B and M_y/B per metre. Bottom fixed, sides on rollers. Same mesh in OpenSees (quad PlaneStrain).
#: **Symbolic: plane-strain matrix D** (σ = D·ε, ε_z = 0) and the strain of a 4-node quad, ε = B·u with ε_x = ∂u/∂x, ε_y = ∂v/∂y, γ_xy = ∂u/∂y + ∂v/∂x:
d_11 = Simplify{E*(1-nu)/((1+nu)*(1-2*nu))}
d_12 = Simplify{E*nu/((1+nu)*(1-2*nu))}
d_33 = Simplify{E/(2*(1+nu))}
#: Element matrix K_e = ∫ Bᵀ·D·B·det J dξ dη, 2 × 2 Gauss points (full integration, as OpenSees quad).
h_s = 0.25 'soil element size [m]
W_s = 4.5 'soil width [m]
H_s = 3 'soil depth [m]
#hide
n_sx = W_s/h_s
n_sy = H_s/h_s
D_s2 = E_s/((1 + nu_s)·(1 - 2·nu_s))·[1 - nu_s, nu_s, 0; nu_s, 1 - nu_s, 0; 0, 0, (1 - 2·nu_s)/2]
D_c2 = E_c/((1 + nu_c)·(1 - 2·nu_c))·[1 - nu_c, nu_c, 0; nu_c, 1 - nu_c, 0; 0, 0, (1 - 2·nu_c)/2]
S_u = zeros(4, 8)
S_v = zeros(4, 8)
for k = 1:4
  S_u(k, 2·k - 1) = 1
  S_v(k, 2·k) = 1
end
#show
d_r(r, s) = [-(1 - s)/4, (1 - s)/4, (1 + s)/4, -(1 + s)/4]
d_s(r, s) = [-(1 - r)/4, -(1 + r)/4, (1 + r)/4, (1 - r)/4]
B_q(r, s, a, b) = [transpose(d_r(r, s))·S_u/a; transpose(d_s(r, s))·S_v/b; transpose(d_s(r, s))·S_u/b + transpose(d_r(r, s))·S_v/a]
#hide
K_s2 = zeros(8, 8)
K_c2 = zeros(8, 8)
for p = 1:4
  B_1 = B_q(r_g(p), s_g(p), h_s/2, h_s/2)
  K_s2 = K_s2 + h_s^2/4·transpose(B_1)·D_s2·B_1
  B_2 = B_q(r_g(p), s_g(p), h_s/2, t/4)
  K_c2 = K_c2 + h_s·t/8·transpose(B_2)·D_c2·B_2
end
n_2 = n_sx + 1
n_ss = n_2·(n_sy + 1)
n_t2 = n_ss + 14
F_n = zeros(3, 7)
for m = 1:7
  F_n(1, m) = n_sy·n_2 + (n_sx/2 - 3) + m
  F_n(2, m) = n_ss + m
  F_n(3, m) = n_ss + 7 + m
end
K_2 = zeros(2·n_t2, 2·n_t2)
for j = 1:n_sy
  for i = 1:n_sx
    nd = (j - 1)·n_2 + i
    c_4 = [nd, nd + 1, nd + 1 + n_2, nd + n_2]
    g = [2·c_4(1) - 1, 2·c_4(1), 2·c_4(2) - 1, 2·c_4(2), 2·c_4(3) - 1, 2·c_4(3), 2·c_4(4) - 1, 2·c_4(4)]
    K_2(g, g) = K_2(g, g) + K_s2
  end
end
for k = 1:2
  for m = 1:6
    c_4 = [F_n(k, m), F_n(k, m + 1), F_n(k + 1, m + 1), F_n(k + 1, m)]
    g = [2·c_4(1) - 1, 2·c_4(1), 2·c_4(2) - 1, 2·c_4(2), 2·c_4(3) - 1, 2·c_4(3), 2·c_4(4) - 1, 2·c_4(4)]
    K_2(g, g) = K_2(g, g) + K_c2
  end
end
for i = 1:n_2
  K_2(2·i - 1, 2·i - 1) = K_2(2·i - 1, 2·i - 1) + 1e20
  K_2(2·i, 2·i) = K_2(2·i, 2·i) + 1e20
end
for j = 2:n_sy + 1
  K_2(2·((j - 1)·n_2 + 1) - 1, 2·((j - 1)·n_2 + 1) - 1) = K_2(2·((j - 1)·n_2 + 1) - 1, 2·((j - 1)·n_2 + 1) - 1) + 1e20
  K_2(2·(j·n_2) - 1, 2·(j·n_2) - 1) = K_2(2·(j·n_2) - 1, 2·(j·n_2) - 1) + 1e20
end
F_2 = zeros(2·n_t2, 1)
F_2(2·F_n(3, 3)) = -P/B/4 + M_y/B/0.5
F_2(2·F_n(3, 4)) = -P/B/2
F_2(2·F_n(3, 5)) = -P/B/4 - M_y/B/0.5
U_2 = clsolve(K_2, F_2)
f_2 = zeros(n_t2, 1)
for i = 1:n_sx
  nd = (n_sy - 1)·n_2 + i
  c_4 = [nd, nd + 1, nd + 1 + n_2, nd + n_2]
  u_e = [U_2(2·c_4(1) - 1), U_2(2·c_4(1)), U_2(2·c_4(2) - 1), U_2(2·c_4(2)), U_2(2·c_4(3) - 1), U_2(2·c_4(3)), U_2(2·c_4(4) - 1), U_2(2·c_4(4))]
  f_e = K_s2·u_e
  f_2(c_4(3)) = f_2(c_4(3)) + f_e(6)
  f_2(c_4(4)) = f_2(c_4(4)) + f_e(8)
end
q_2 = zeros(7, 1)
x_2 = zeros(7, 1)
l_t = [h_s/2, h_s, h_s, h_s, h_s, h_s, h_s/2]
for m = 1:7
  x_2(m) = -B/2 + (m - 1)·h_s
  q_2(m) = -f_2(F_n(1, m))/l_t(m)
end
#show
w_2 = [-1000·U_2(2·F_n(3, 4)), -1000·U_2(2·F_n(1, 1)), -1000·U_2(2·F_n(1, 7)), -1000·U_2(2·((H_s - 1.5)/h_s·n_2 + n_sx/2 + 1)), -1000·U_2(2·(n_sy·n_2 + n_sx/2 + 7))] 'settlements [mm]: footing top centre, footing edges −x and +x, soil at 1.5 m depth, soil surface at x = 1.5 m
w2_ops = [11.209830, 10.342998, 12.017109, 4.703981, 3.607047] 'OpenSees quad PlaneStrain, same nodes [mm]
q2_ops = [381.707985, 129.868413, 113.408390, 113.706140, 122.403693, 152.641280, 487.569516] 'OpenSees contact pressure [kPa]
q2_rig = [q(-0.75, 0), q(-0.5, 0), q(-0.25, 0), q(0, 0), q(0.25, 0), q(0.5, 0), q(0.75, 0)] 'rigid formula at y = 0 [kPa]
#tabla("x [m]:2","Rigid formula [kPa]:2","Hekatan LISP, 2D soil [kPa]:6","OpenSees [kPa]:6")(x_2; q2_rig; q_2; q2_ops)
#dibujo("2D model: soil 4.5 × 3 m, footing and contact pressure (red: soil FEM, blue: rigid formula)", ud = m, escala = auto, cotas = m, alto = 120)
#  rect(-W_s/2, -H_s, W_s, H_s, "fina gris tenue")
#  achurado(-B/2, 0, B, t, "concreto")
#  rect(-B/2, 0, B, t, "gruesa")
#  linea(-W_s/2 - 0.1, -H_s, W_s/2 + 0.1, -H_s, "muygruesa")
#  texto(0, -H_s - 0.25, "fixed base", 2.4, "c")
#  texto(-W_s/2 - 0.05, -H_s/2, "roller", 2.4, "d")
#  texto(W_s/2 + 0.05, -H_s/2, "roller", 2.4, "i")
#  flecha(0, 1.6, 0, 0.62, "gruesa rojo")
#  texto(0.08, 1.4, "P/B = {P/B:1} kN/m, M_y/B = {M_y/B:1} kN·m/m", 2.4, "i")
#  polilinea(x_2, -0.004*q_2, "gruesa rojo")
#  polilinea(x_2, -0.004*q2_rig, "media azul")
#  linea(-B/2, 0, -B/2, -0.004*q_2(1), "fina rojo")
#  linea(B/2, 0, B/2, -0.004*q_2(7), "fina rojo")
#  texto(B/2 + 0.08, -0.004*q_2(7), "{q_2(7):0} kPa", 2.4, "i")
#  texto(-B/2 - 0.08, -0.004*q_2(1), "{q_2(1):0} kPa", 2.4, "d")
#  hover(x_2, -0.004*q_2, "x = {#1:2} m · q = {#2:1} kPa (soil FEM)", x_2, q_2)
#  hover(x_2, -0.004*q2_rig, "x = {#1:2} m · q = {#2:1} kPa (rigid)", x_2, q2_rig)
#fin
dw_2 = max(abs(w_2 - w2_ops)) 'max |Hekatan − OpenSees| in settlement [mm]
dq_2 = max(abs(q_2 - q2_ops)) 'max |Hekatan − OpenSees| in contact pressure [kPa]
#: The contact pressure is the force each footing node passes to the soil (internal force of the top soil elements) over its tributary length; the sum gives exactly P/B. On a continuous soil a stiff footing **concentrates the pressure at its edges** (382 and 488 kPa against 114 kPa in the middle): springs (Winkler) cannot show that, the meshed soil does.
#: **The pressure bulb** (what Boussinesq describes, here by FEM): vertical stress σ_y in the soil, σ = D·B·u at the centre of each quad, averaged at the nodes. Compression positive [kPa]; hover for the value:
#hide
S_2 = zeros(n_ss, 1)
c_2 = zeros(n_ss, 1)
B_0 = B_q(0, 0, h_s/2, h_s/2)
for j = 1:n_sy
  for i = 1:n_sx
    nd = (j - 1)·n_2 + i
    c_4 = [nd, nd + 1, nd + 1 + n_2, nd + n_2]
    u_e = [U_2(2·c_4(1) - 1), U_2(2·c_4(1)), U_2(2·c_4(2) - 1), U_2(2·c_4(2)), U_2(2·c_4(3) - 1), U_2(2·c_4(3)), U_2(2·c_4(4) - 1), U_2(2·c_4(4))]
    s_e = D_s2·B_0·u_e
    for m = 1:4
      S_2(c_4(m)) = S_2(c_4(m)) - s_e(2)
      c_2(c_4(m)) = c_2(c_4(m)) + 1
    end
  end
end
G_2 = zeros(n_2, n_sy + 1)
for j = 1:n_sy + 1
  for i = 1:n_2
    G_2(i, j) = S_2((j - 1)·n_2 + i)/c_2((j - 1)·n_2 + i)
  end
end
#show
s_y2(x, y) = spline(1 + (x + W_s/2)/h_s, 1 + (y + H_s)/h_s, G_2)
#contourf(s_y2(x, y), [-W_s/2 W_s/2], [-H_s 0])

## 6 · The soil by finite elements (2): 3D solid

#: The whole footing on a 3D soil block 6 × 4.5 × 3 m with 8-node bricks of 0.75 m (6 × 6 × 4), the footing as 2 × 2 concrete bricks 0.75 × 0.75 × 0.60. Bottom fixed, sides on rollers; P, M_x, M_y on the top of the footing. Same mesh in OpenSees (stdBrick).
#: **Symbolic: shape function of a brick** (natural coordinates ξ, η, ζ) and the solid matrix D (λ, G):
N_b1 = Simplify{(1-xi)*(1-eta)*(1-zeta)/8}
l_am = Simplify{E*nu/((1+nu)*(1-2*nu))}
G_s = Simplify{E/(2*(1+nu))}
h_3 = 0.75 'brick size [m]
W_3 = 4.5 'soil block width [m]
H_3 = 3 'soil block depth [m]
#hide
D_s3 = zeros(6, 6)
D_c3 = zeros(6, 6)
for i = 1:3
  for j = 1:3
    D_s3(i, j) = E_s·nu_s/((1 + nu_s)·(1 - 2·nu_s))
    D_c3(i, j) = E_c·nu_c/((1 + nu_c)·(1 - 2·nu_c))
  end
  D_s3(i, i) = D_s3(i, i) + E_s/(1 + nu_s)
  D_c3(i, i) = D_c3(i, i) + E_c/(1 + nu_c)
  D_s3(i + 3, i + 3) = E_s/(2·(1 + nu_s))
  D_c3(i + 3, i + 3) = E_c/(2·(1 + nu_c))
end
s_x = [-1, 1, 1, -1, -1, 1, 1, -1]
s_y = [-1, -1, 1, 1, -1, -1, 1, 1]
s_z = [-1, -1, -1, -1, 1, 1, 1, 1]
T_u = zeros(8, 24)
T_v = zeros(8, 24)
T_w = zeros(8, 24)
for k = 1:8
  T_u(k, 3·k - 2) = 1
  T_v(k, 3·k - 1) = 1
  T_w(k, 3·k) = 1
end
K_s3 = zeros(24, 24)
K_c3 = zeros(24, 24)
for p = 1:8
  r = s_x(p)/sqrt(3)
  s = s_y(p)/sqrt(3)
  z = s_z(p)/sqrt(3)
  a_x = zeros(8, 1)
  a_y = zeros(8, 1)
  a_z = zeros(8, 1)
  for k = 1:8
    a_x(k) = s_x(k)·(1 + s_y(k)·s)·(1 + s_z(k)·z)/8
    a_y(k) = s_y(k)·(1 + s_x(k)·r)·(1 + s_z(k)·z)/8
    a_z(k) = s_z(k)·(1 + s_x(k)·r)·(1 + s_y(k)·s)/8
  end
  B_s = [transpose(a_x)·T_u/(h_3/2); transpose(a_y)·T_v/(h_3/2); transpose(a_z)·T_w/(h_3/2); transpose(a_y)·T_u/(h_3/2) + transpose(a_x)·T_v/(h_3/2); transpose(a_z)·T_v/(h_3/2) + transpose(a_y)·T_w/(h_3/2); transpose(a_z)·T_u/(h_3/2) + transpose(a_x)·T_w/(h_3/2)]
  B_c = [transpose(a_x)·T_u/(h_3/2); transpose(a_y)·T_v/(h_3/2); transpose(a_z)·T_w/(t/2); transpose(a_y)·T_u/(h_3/2) + transpose(a_x)·T_v/(h_3/2); transpose(a_z)·T_v/(t/2) + transpose(a_y)·T_w/(h_3/2); transpose(a_z)·T_u/(t/2) + transpose(a_x)·T_w/(h_3/2)]
  K_s3 = K_s3 + (h_3/2)^3·transpose(B_s)·D_s3·B_s
  K_c3 = K_c3 + (h_3/2)^2·(t/2)·transpose(B_c)·D_c3·B_c
end
n_3 = W_3/h_3 + 1
n_z = H_3/h_3 + 1
p_2 = n_3^2
i_0 = (W_3/2 - B/2)/h_3
e_3 = n_3 - 1
e_z = n_z - 1
n_s3 = p_2·n_z
n_t3 = n_s3 + 9
K_3 = zeros(3·n_t3, 3·n_t3)
for k = 1:e_z
  for j = 1:e_3
    for i = 1:e_3
      nd = (k - 1)·p_2 + (j - 1)·n_3 + i
      c_8 = [nd, nd + 1, nd + n_3 + 1, nd + n_3, nd + p_2, nd + p_2 + 1, nd + p_2 + n_3 + 1, nd + p_2 + n_3]
      g = zeros(24, 1)
      for m = 1:8
        g(3·m - 2) = 3·c_8(m) - 2
        g(3·m - 1) = 3·c_8(m) - 1
        g(3·m) = 3·c_8(m)
      end
      K_3(g, g) = K_3(g, g) + K_s3
    end
  end
end
T_n = zeros(3, 3)
for j = 1:3
  for i = 1:3
    T_n(i, j) = n_s3 + (j - 1)·3 + i
  end
end
for j = 1:2
  for i = 1:2
    nd = e_z·p_2 + (j + i_0 - 1)·n_3 + i + i_0
    c_8 = [nd, nd + 1, nd + n_3 + 1, nd + n_3, T_n(i, j), T_n(i + 1, j), T_n(i + 1, j + 1), T_n(i, j + 1)]
    g = zeros(24, 1)
    for m = 1:8
      g(3·m - 2) = 3·c_8(m) - 2
      g(3·m - 1) = 3·c_8(m) - 1
      g(3·m) = 3·c_8(m)
    end
    K_3(g, g) = K_3(g, g) + K_c3
  end
end
for k = 1:n_z
  for j = 1:n_3
    for i = 1:n_3
      nd = (k - 1)·p_2 + (j - 1)·n_3 + i
      if k == 1
        K_3(3·nd - 2, 3·nd - 2) = K_3(3·nd - 2, 3·nd - 2) + 1e20
        K_3(3·nd - 1, 3·nd - 1) = K_3(3·nd - 1, 3·nd - 1) + 1e20
        K_3(3·nd, 3·nd) = K_3(3·nd, 3·nd) + 1e20
      else
        if i == 1
          K_3(3·nd - 2, 3·nd - 2) = K_3(3·nd - 2, 3·nd - 2) + 1e20
        end
        if i == n_3
          K_3(3·nd - 2, 3·nd - 2) = K_3(3·nd - 2, 3·nd - 2) + 1e20
        end
        if j == 1
          K_3(3·nd - 1, 3·nd - 1) = K_3(3·nd - 1, 3·nd - 1) + 1e20
        end
        if j == n_3
          K_3(3·nd - 1, 3·nd - 1) = K_3(3·nd - 1, 3·nd - 1) + 1e20
        end
      end
    end
  end
end
F_3 = zeros(3·n_t3, 1)
F_3(3·T_n(2, 2)) = -P
F_3(3·T_n(3, 2)) = -M_y/1.5
F_3(3·T_n(1, 2)) = M_y/1.5
F_3(3·T_n(2, 1)) = -M_x/1.5
F_3(3·T_n(2, 3)) = M_x/1.5
U_3 = clsolve(K_3, F_3)
f_3 = zeros(n_t3, 1)
for j = 1:e_3
  for i = 1:e_3
    nd = (e_z - 1)·p_2 + (j - 1)·n_3 + i
    c_8 = [nd, nd + 1, nd + n_3 + 1, nd + n_3, nd + p_2, nd + p_2 + 1, nd + p_2 + n_3 + 1, nd + p_2 + n_3]
    u_e = zeros(24, 1)
    for m = 1:8
      u_e(3·m - 2) = U_3(3·c_8(m) - 2)
      u_e(3·m - 1) = U_3(3·c_8(m) - 1)
      u_e(3·m) = U_3(3·c_8(m))
    end
    f_e = K_s3·u_e
    for m = 5:8
      f_3(c_8(m)) = f_3(c_8(m)) + f_e(3·m)
    end
  end
end
q_3 = zeros(9, 1)
l_3 = [h_3/2, h_3, h_3/2]
for j = 1:3
  for i = 1:3
    nd = e_z·p_2 + (j + i_0 - 1)·n_3 + i + i_0
    q_3((j - 1)·3 + i) = -f_3(nd)/(l_3(i)·l_3(j))
  end
end
#show
w_3 = [-1000·U_3(3·T_n(2, 2)), -1000·U_3(3·(e_z·p_2 + i_0·n_3 + i_0 + 3)), -1000·U_3(3·(e_z·p_2 + (i_0 + 2)·n_3 + i_0 + 1)), -1000·U_3(3·((H_3 - 1.5)/h_3·p_2 + (n_3 - 1)/2·n_3 + (n_3 + 1)/2)), -1000·U_3(3·(e_z·p_2 + (n_3 - 1)/2·n_3 + (n_3 + 1)/2 + 2))] 'settlements [mm]: footing top centre, corners (0.75; −0.75) and (−0.75; 0.75), soil at 1.5 m depth, surface at x = 1.5 m
w3_ops = [5.769229, 6.985553, 4.435608, 2.191077, 1.704312] 'OpenSees stdBrick, same nodes [mm]
q3_ops = [365.618869, 188.051611, 428.177492, 139.667323, 65.180715, 171.923515, 240.501624, 123.539227, 303.060246] 'OpenSees contact pressure [kPa]
#tabla("Node (x; y) [m]","Hekatan LISP, 3D soil [kPa]:6","OpenSees [kPa]:6")({"(−0.75; −0.75)","(0; −0.75)","(0.75; −0.75)","(−0.75; 0)","(0; 0)","(0.75; 0)","(−0.75; 0.75)","(0; 0.75)","(0.75; 0.75)"}; q_3; q3_ops)
#hide
Q_3 = zeros(3, 3)
for j = 1:3
  for i = 1:3
    Q_3(i, j) = q_3((j - 1)·3 + i)
  end
end
#show
p_3(x, y) = spline(1 + (x + B/2)/h_3, 1 + (y + B/2)/h_3, Q_3)
#contourf(p_3(x, y), [-B/2 B/2], [-B/2 B/2])
#surf(p_3(x, y), [-B/2 B/2], [-B/2 B/2])
dw_3 = max(abs(w_3 - w3_ops)) 'max |Hekatan − OpenSees| in settlement [mm]
dq_3 = max(abs(q_3 - q3_ops)) 'max |Hekatan − OpenSees| in contact pressure [kPa]
#: Same picture in 3D: the corners carry the most (428 kPa at the +x, −y corner where M_x and M_y push) and the centre the least (65 kPa). The 0.75 m bricks are coarse (2 × 2 under the footing): this is a validation of the method against OpenSees, not a design mesh.
#: **Pressure bulb in 3D**, vertical cut y = 0: σ_z at the brick centres averaged at the nodes [kPa] (compression positive):
#hide
S_3 = zeros(n_s3, 1)
c_3 = zeros(n_s3, 1)
a_x = zeros(8, 1)
a_y = zeros(8, 1)
a_z = zeros(8, 1)
for k = 1:8
  a_x(k) = s_x(k)/8
  a_y(k) = s_y(k)/8
  a_z(k) = s_z(k)/8
end
B_0 = [transpose(a_x)·T_u/(h_3/2); transpose(a_y)·T_v/(h_3/2); transpose(a_z)·T_w/(h_3/2); transpose(a_y)·T_u/(h_3/2) + transpose(a_x)·T_v/(h_3/2); transpose(a_z)·T_v/(h_3/2) + transpose(a_y)·T_w/(h_3/2); transpose(a_z)·T_u/(h_3/2) + transpose(a_x)·T_w/(h_3/2)]
for k = 1:e_z
  for j = 1:e_3
    for i = 1:e_3
      nd = (k - 1)·p_2 + (j - 1)·n_3 + i
      c_8 = [nd, nd + 1, nd + n_3 + 1, nd + n_3, nd + p_2, nd + p_2 + 1, nd + p_2 + n_3 + 1, nd + p_2 + n_3]
      u_e = zeros(24, 1)
      for m = 1:8
        u_e(3·m - 2) = U_3(3·c_8(m) - 2)
        u_e(3·m - 1) = U_3(3·c_8(m) - 1)
        u_e(3·m) = U_3(3·c_8(m))
      end
      s_e = D_s3·B_0·u_e
      for m = 1:8
        S_3(c_8(m)) = S_3(c_8(m)) - s_e(3)
        c_3(c_8(m)) = c_3(c_8(m)) + 1
      end
    end
  end
end
G_3 = zeros(n_3, n_z)
for k = 1:n_z
  for i = 1:n_3
    G_3(i, k) = S_3((k - 1)·p_2 + (n_3 - 1)/2·n_3 + i)/c_3((k - 1)·p_2 + (n_3 - 1)/2·n_3 + i)
  end
end
#show
s_z3(x, y) = spline(1 + (x + W_3/2)/h_3, 1 + (y + H_3)/h_3, G_3)
#contourf(s_z3(x, y), [-W_3/2 W_3/2], [-H_3 0])
#: **3D: the soil as a solid**, cut at y = 0 to see inside: colour = vertical stress σ_z [kPa] (the pressure bulb on the cut face), deformed shape ×30, the column as a bar. Drag to rotate, wheel to zoom, hover to read:
#hide
n_f3 = e_3·e_3 + 2·(e_3/2)·e_z + 2·e_3·e_z + 8
X_3 = zeros(n_t3 + 1, 3)
v_3 = zeros(n_t3 + 1, 1)
U_m = zeros(n_t3 + 1, 3)
for k = 1:n_z
  for j = 1:n_3
    for i = 1:n_3
      nd = (k - 1)·p_2 + (j - 1)·n_3 + i
      X_3(nd, 1) = -W_3/2 + (i - 1)·h_3
      X_3(nd, 2) = -W_3/2 + (j - 1)·h_3
      X_3(nd, 3) = -H_3 + (k - 1)·h_3
      v_3(nd) = S_3(nd)/c_3(nd)
    end
  end
end
for j = 1:3
  for i = 1:3
    X_3(T_n(i, j), 1) = -B/2 + (i - 1)·h_3
    X_3(T_n(i, j), 2) = -B/2 + (j - 1)·h_3
    X_3(T_n(i, j), 3) = t
    v_3(T_n(i, j)) = v_3(e_z·p_2 + (j + i_0 - 1)·n_3 + i + i_0)
  end
end
X_3(n_t3 + 1, 3) = t + 1
for nd = 1:n_t3
  U_m(nd, 1) = U_3(3·nd - 2)
  U_m(nd, 2) = U_3(3·nd - 1)
  U_m(nd, 3) = U_3(3·nd)
end
e_q = zeros(n_f3, 4)
f_n = 0
for k = 1:e_z
  for j = e_3/2 + 1:e_3
    for i = 1:e_3
      nd = (k - 1)·p_2 + (j - 1)·n_3 + i
      if k == 1
        f_n = f_n + 1
        e_q(f_n, 1) = nd
        e_q(f_n, 2) = nd + 1
        e_q(f_n, 3) = nd + n_3 + 1
        e_q(f_n, 4) = nd + n_3
      end
      if k == e_z
        f_n = f_n + 1
        e_q(f_n, 1) = nd + p_2
        e_q(f_n, 2) = nd + p_2 + 1
        e_q(f_n, 3) = nd + p_2 + n_3 + 1
        e_q(f_n, 4) = nd + p_2 + n_3
      end
      if i == 1
        f_n = f_n + 1
        e_q(f_n, 1) = nd
        e_q(f_n, 2) = nd + n_3
        e_q(f_n, 3) = nd + n_3 + p_2
        e_q(f_n, 4) = nd + p_2
      end
      if i == e_3
        f_n = f_n + 1
        e_q(f_n, 1) = nd + 1
        e_q(f_n, 2) = nd + n_3 + 1
        e_q(f_n, 3) = nd + n_3 + 1 + p_2
        e_q(f_n, 4) = nd + 1 + p_2
      end
      if j == e_3/2 + 1
        f_n = f_n + 1
        e_q(f_n, 1) = nd
        e_q(f_n, 2) = nd + 1
        e_q(f_n, 3) = nd + 1 + p_2
        e_q(f_n, 4) = nd + p_2
      end
      if j == e_3
        f_n = f_n + 1
        e_q(f_n, 1) = nd + n_3
        e_q(f_n, 2) = nd + n_3 + 1
        e_q(f_n, 3) = nd + n_3 + 1 + p_2
        e_q(f_n, 4) = nd + n_3 + p_2
      end
    end
  end
end
for i = 1:2
  nd = e_z·p_2 + (i_0 + 1)·n_3 + i + i_0
  f_n = f_n + 1
  e_q(f_n, 1) = T_n(i, 2)
  e_q(f_n, 2) = T_n(i + 1, 2)
  e_q(f_n, 3) = T_n(i + 1, 3)
  e_q(f_n, 4) = T_n(i, 3)
  f_n = f_n + 1
  e_q(f_n, 1) = nd
  e_q(f_n, 2) = nd + 1
  e_q(f_n, 3) = T_n(i + 1, 2)
  e_q(f_n, 4) = T_n(i, 2)
  f_n = f_n + 1
  e_q(f_n, 1) = nd + n_3
  e_q(f_n, 2) = nd + n_3 + 1
  e_q(f_n, 3) = T_n(i + 1, 3)
  e_q(f_n, 4) = T_n(i, 3)
end
nd = e_z·p_2 + (i_0 + 1)·n_3 + i_0 + 1
f_n = f_n + 1
e_q(f_n, 1) = nd
e_q(f_n, 2) = nd + n_3
e_q(f_n, 3) = T_n(1, 3)
e_q(f_n, 4) = T_n(1, 2)
f_n = f_n + 1
e_q(f_n, 1) = nd + 2
e_q(f_n, 2) = nd + n_3 + 2
e_q(f_n, 3) = T_n(3, 3)
e_q(f_n, 4) = T_n(3, 2)
e_c = [T_n(2, 2), n_t3 + 1]
v_c = [0, 0]
#show
#modelo3d(X_3, e_q, e_c, v_3, v_c, U_m, 30)

## 7 · Geotechnical check

#sust
phi_r = phi·pi/180
N_q = exp(pi·tan(phi_r))·tan(pi/4 + phi_r/2)^2
N_g = 2·(N_q + 1)·tan(phi_r)
B_p = B - 2·e_y
L_p = B - 2·e_x
s_q = 1 + B_p/L_p·tan(phi_r)
s_g = 1 - 0.4·B_p/L_p
q_u = gamma·D_f·N_q·s_q + 0.5·gamma·B_p·N_g·s_g
q_adm = q_u/FS
U = q_max/q_adm
s = 1000·(P/A)·B·(1 - nu_s^2)/E_s·0.82
#: Meyerhof effective area B'·L' (B' the smaller side), Vesić N_γ, De Beer shape factors, sand c = 0. U < 1: the soil carries q_max. Settlement s [mm]: elastic, rigid square footing, influence factor 0.82 (Bowles).
