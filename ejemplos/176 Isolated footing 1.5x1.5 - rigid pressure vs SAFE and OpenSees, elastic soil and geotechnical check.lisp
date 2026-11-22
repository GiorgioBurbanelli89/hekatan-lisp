# Isolated footing 1.50 × 1.50 m: rigid pressure vs SAFE and OpenSees and geotechnical check
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

## 5 · Geotechnical check

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
