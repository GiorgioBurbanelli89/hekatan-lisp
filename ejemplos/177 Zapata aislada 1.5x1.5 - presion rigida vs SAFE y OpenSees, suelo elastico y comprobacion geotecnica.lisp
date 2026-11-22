# Zapata aislada 1.50 × 1.50 m: presión rígida, placa sobre resortes y suelo por FEM (membrana 2D, sólido 3D) vs SAFE y OpenSees, comprobación geotécnica
#numerico

## 1 · Datos

B = 1.5 'lado [m]
t = 0.6 'espesor [m]
D_f = 1.5 'profundidad de desplante [m]
P = 400 'carga axial [kN]
M_x = 40 'momento alrededor de x [kN·m]
M_y = 20 'momento alrededor de y [kN·m]
k_s = 20000 'módulo de balasto [kN/m3]
gamma = 18 'peso específico del suelo [kN/m3]
phi = 30 'ángulo de rozamiento [grados]
E_s = 20000 'módulo del suelo [kPa]
nu_s = 0.3 'Poisson del suelo
FS = 3 'factor de seguridad

## 2 · Zapata rígida: presión lineal

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
c_col = 0.4 'lado de la columna [m]
q_xp = q(B/2, 0) 'presión en x = +B/2, y = 0 [kPa]
q_xm = q(-B/2, 0) 'presión en x = −B/2, y = 0 [kPa]
#dibujo("Zapata y columna: alzado (y = 0) y planta", ud = m, escala = auto, cotas = m, alto = 120)
#  linea(-1.3, 0, 1.3, 0, "media gris")
#  achurado(-B/2, -D_f, B, t, "concreto")
#  rect(-B/2, -D_f, B, t, "gruesa")
#  achurado(-c_col/2, t - D_f, c_col, D_f - t + 0.6, "concreto")
#  rect(-c_col/2, t - D_f, c_col, D_f - t + 0.6, "gruesa")
#  flecha(0, 1.45, 0, 0.62, "gruesa rojo")
#  texto(-0.25, 1.3, "P = {P:0} kN", 2.6, "d")
#  flechamomento(0, 0.95, 0.38, 150, 30, "rojo")
#  texto(0.45, 0.95, "M_y = {M_y:0} kN·m", 2.6, "i")
#  carga(B/2, -D_f, -B/2, -D_f, 0.5*q_xp/q_max, 0.5*q_xm/q_max, "presión del suelo en y = 0: {q_xm:1} → {q_xp:1} kPa", "azul")
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
#  texto(2.9, -0.55 - B/2 - 0.3, "planta · M_x = {M_x:0} kN·m, M_y = {M_y:0} kN·m", 2.4, "c")
#  hover([2.9 + B/2, 2.9 - B/2, 2.9 + B/2, 2.9 - B/2, 2.9], [-0.55 - B/2, -0.55 + B/2, -0.55 + B/2, -0.55 - B/2, -0.55], "q = {#1:2} kPa (rígida)", [q_max, q_min, P/A + (M_y - M_x)*B/2/I, P/A - (M_y - M_x)*B/2/I, P/A])
#fin
#sust
#contourf(q(x, y), [-B/2 B/2], [-B/2 B/2])
#: Regla de la mano derecha: M_x > 0 comprime el lado −y, M_y > 0 el lado +x. e_x, e_y ≤ B/6 = 0.25 m: toda la base está comprimida.

## 3 · Hekatan LISP por elementos finitos: placa MITC4 sobre suelo de Winkler

#: El mismo modelo de SAFE y OpenSees, armado aquí paso a paso: placa de Mindlin de 4 nudos con cortante MITC4 (el elemento ShellMITC4 de OpenSees), 3 gdl por nudo [w, θ_x, θ_y], malla 10 × 10, resortes del suelo k_s·A_trib en cada nudo.

#: **Símbolos: funciones de forma y Jacobiano.** Elemento de lados 2a × 2b, coordenadas naturales ξ, η ∈ [−1, 1]. Función de forma del nudo 1 y el mapeo x(ξ), y(η):
N_1 = Simplify{(1-xi)*(1-eta)/4}
x_s = Simplify{a*(-(1-xi)*(1-eta)/4 + (1+xi)*(1-eta)/4 + (1+xi)*(1+eta)/4 - (1-xi)*(1+eta)/4)}
y_s = Simplify{b*(-(1-xi)*(1-eta)/4 - (1+xi)*(1-eta)/4 + (1+xi)*(1+eta)/4 + (1-xi)*(1+eta)/4)}
J_11 = Partial{a*xi @ xi}
J_22 = Partial{b*eta @ eta}
J_12 = Partial{a*xi @ eta}
J_det = Simplify{a*b - 0*0}
#: det J = a·b convierte dξ·dη en dx·dy. Derivadas en x e y: ∂N/∂x = (1/a)·∂N/∂ξ, ∂N/∂y = (1/b)·∂N/∂η:
N_1_x = Simplify{Partial{(1-xi)*(1-eta)/4 @ xi}/a}
N_1_y = Simplify{Partial{(1-xi)*(1-eta)/4 @ eta}/b}
#: **Símbolos: rigideces de la placa y cortante MITC4.** Flexión D = E·t³/(12(1 − ν²)); cortante C_s = (5/6)·G·t. La deformación γ_xz no se toma en los puntos de Gauss (eso bloquea la placa delgada) sino en los puntos medios de los lados A = (0, −1), B = (0, 1), y se interpola en η:
D_flex = Simplify{E*h^3/(12*(1-nu^2))}
C_shear = Simplify{5/6*E/(2*(1+nu))*h}
g_xz = Simplify{(1-eta)/2*g_A + (1+eta)/2*g_B}
#: Forma cerrada de dos términos de la matriz del elemento (integrados a mano sobre 2a × 2b):
K_ww = Simplify{C*(b/(3*a) + a/(3*b))}
K_tt = Simplify{D*b/(3*a) + D*(1-nu)*a/(6*b) + C*a*b/3}

#: **Números: matriz del elemento 12 × 12** con 2 × 2 puntos de Gauss:
E_c = 24.87e6 'módulo del hormigón [kPa]
nu_c = 0.2 'Poisson del hormigón
n_x = 10 'elementos por lado
h_e = B/n_x 'lado del elemento [m]
a_e = h_e/2 'semilado [m]
D_0 = E_c·t^3/(12·(1 - nu_c^2)) 'rigidez a flexión [kN·m]
C_s = 5/6·E_c/(2·(1 + nu_c))·t 'rigidez a cortante [kN/m]
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
g_p = 1/sqrt(3) 'coordenada de Gauss
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
#: Comprobación contra las formas cerradas (deben dar 0):
dK_ww = round(K_e(1, 1) - C_s·2/3, 6)
dK_tt = round(K_e(3, 3) - (D_0/3 + D_0·(1 - nu_c)/6 + C_s·a_e^2/3), 6)

#: **Malla, resortes, carga, ensamblaje y solución.** Nudos fila a fila desde (−B/2, −B/2); resorte k_s·A_trib (esquina h²/4, borde h²/2, interior h²); P, M_x, M_y en el nudo central:
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
R_f 'suma de reacciones del suelo = P [kN]
p_fem(x, y) = spline(1 + (x + B/2)/h_e, 1 + (y + B/2)/h_e, P_m)
#contourf(p_fem(x, y), [-B/2 B/2], [-B/2 B/2])
#: **3D:** la misma presión del suelo como superficie (sobre resortes de Winkler el asiento w = p/k_s tiene la misma forma). Arrastra para girar, pasa el cursor para ver el valor:
#surf(p_fem(x, y), [-B/2 B/2], [-B/2 B/2])

## 4 · Validación: Hekatan LISP vs SAFE 20 vs OpenSees

#: Misma malla nudo a nudo, offsets = 0. Esquinas: nudos 121 (+,+), 111 (−,+), 11 (+,−), 1 (−,−); nudo central 61.
#equ
t_rig = [q(B/2, -B/2), q(-B/2, -B/2), q(B/2, B/2), q(-B/2, B/2), q(0, 0)] 'fórmula rígida [kPa]
t_hek = [p_f(11), p_f(1), p_f(n_j), p_f(n_j - n_x), p_f(n_c)] 'Hekatan LISP MITC4 [kPa]
t_safe = [281.947055, 212.251649, 142.556242, 72.860836, 178.821362] 'SAFE 20 [kPa]
t_ops = [281.960118, 212.260957, 142.561796, 72.862635, 178.811271] 'OpenSees ShellMITC4 [kPa]
#tabla("Punto (x; y) [m]","Fórmula rígida [kPa]:2","Hekatan LISP [kPa]:6","OpenSees [kPa]:6","SAFE 20 [kPa]:6")({"(0.75; −0.75)","(−0.75; −0.75)","(0.75; 0.75)","(−0.75; 0.75)","(0; 0)"}; t_rig; t_hek; t_ops; t_safe)
d_ops = max(abs(t_hek - t_ops)) 'máx |Hekatan − OpenSees| [kPa]
d_safe = max(abs(t_hek - t_safe)) 'máx |Hekatan − SAFE| [kPa]
#: Hekatan LISP y OpenSees resuelven el mismo elemento (MITC4) y los mismos resortes: coinciden en todas las cifras impresas. La placa gruesa de SAFE es un elemento algo distinto: 0.005 %. El 1–2.5 % frente a la fórmula rígida es la flexión de la zapata real de 0.60 m.

## 5 · El suelo por elementos finitos (1): membrana 2D, deformación plana

#: Ahora se malla el SUELO mismo (no resortes): un corte vertical por la zapata en y = 0, suelo de 4.5 m de ancho y 3 m de profundidad con cuadriláteros de 0.25 m, y la zapata de concreto de 0.60 m encima (6 × 2 cuadriláteros). Deformación plana: una rebanada de 1 m, carga P/B y M_y/B por metro. Base fija, lados con rodillos. La misma malla en OpenSees (quad PlaneStrain).
#: **Símbolos: matriz D de deformación plana** (σ = D·ε, ε_z = 0) y la deformación de un cuadrilátero de 4 nudos, ε = B·u con ε_x = ∂u/∂x, ε_y = ∂v/∂y, γ_xy = ∂u/∂y + ∂v/∂x:
d_11 = Simplify{E*(1-nu)/((1+nu)*(1-2*nu))}
d_12 = Simplify{E*nu/((1+nu)*(1-2*nu))}
d_33 = Simplify{E/(2*(1+nu))}
#: Matriz del elemento K_e = ∫ Bᵀ·D·B·det J dξ dη, 2 × 2 puntos de Gauss (integración completa, como el quad de OpenSees).
h_s = 0.25 'lado del elemento de suelo [m]
W_s = 4.5 'ancho del suelo [m]
H_s = 3 'profundidad del suelo [m]
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
w_2 = [-1000·U_2(2·F_n(3, 4)), -1000·U_2(2·F_n(1, 1)), -1000·U_2(2·F_n(1, 7)), -1000·U_2(2·((H_s - 1.5)/h_s·n_2 + n_sx/2 + 1)), -1000·U_2(2·(n_sy·n_2 + n_sx/2 + 7))] 'asientos [mm]: centro arriba de la zapata, bordes −x y +x de la zapata, suelo a 1.5 m de profundidad, superficie en x = 1.5 m
w2_ops = [11.209830, 10.342998, 12.017109, 4.703981, 3.607047] 'OpenSees quad PlaneStrain, mismos nudos [mm]
q2_ops = [381.707985, 129.868413, 113.408390, 113.706140, 122.403693, 152.641280, 487.569516] 'presión de contacto de OpenSees [kPa]
q2_rig = [q(-0.75, 0), q(-0.5, 0), q(-0.25, 0), q(0, 0), q(0.25, 0), q(0.5, 0), q(0.75, 0)] 'fórmula rígida en y = 0 [kPa]
#tabla("x [m]:2","Fórmula rígida [kPa]:2","Hekatan LISP, suelo 2D [kPa]:6","OpenSees [kPa]:6")(x_2; q2_rig; q_2; q2_ops)
#dibujo("Modelo 2D: suelo 4.5 × 3 m, zapata y presión de contacto (rojo: suelo FEM, azul: fórmula rígida)", ud = m, escala = auto, cotas = m, alto = 120)
#  rect(-W_s/2, -H_s, W_s, H_s, "fina gris tenue")
#  achurado(-B/2, 0, B, t, "concreto")
#  rect(-B/2, 0, B, t, "gruesa")
#  linea(-W_s/2 - 0.1, -H_s, W_s/2 + 0.1, -H_s, "muygruesa")
#  texto(0, -H_s - 0.25, "base fija", 2.4, "c")
#  texto(-W_s/2 - 0.05, -H_s/2, "rodillo", 2.4, "d")
#  texto(W_s/2 + 0.05, -H_s/2, "rodillo", 2.4, "i")
#  flecha(0, 1.6, 0, 0.62, "gruesa rojo")
#  texto(0.08, 1.4, "P/B = {P/B:1} kN/m, M_y/B = {M_y/B:1} kN·m/m", 2.4, "i")
#  polilinea(x_2, -0.004*q_2, "gruesa rojo")
#  polilinea(x_2, -0.004*q2_rig, "media azul")
#  linea(-B/2, 0, -B/2, -0.004*q_2(1), "fina rojo")
#  linea(B/2, 0, B/2, -0.004*q_2(7), "fina rojo")
#  texto(B/2 + 0.08, -0.004*q_2(7), "{q_2(7):0} kPa", 2.4, "i")
#  texto(-B/2 - 0.08, -0.004*q_2(1), "{q_2(1):0} kPa", 2.4, "d")
#  hover(x_2, -0.004*q_2, "x = {#1:2} m · q = {#2:1} kPa (suelo FEM)", x_2, q_2)
#  hover(x_2, -0.004*q2_rig, "x = {#1:2} m · q = {#2:1} kPa (rígida)", x_2, q2_rig)
#fin
dw_2 = max(abs(w_2 - w2_ops)) 'máx |Hekatan − OpenSees| en asiento [mm]
dq_2 = max(abs(q_2 - q2_ops)) 'máx |Hekatan − OpenSees| en presión de contacto [kPa]
#: La presión de contacto es la fuerza que cada nudo de la zapata pasa al suelo (fuerza interna de los elementos de suelo de arriba) entre su largo tributario; la suma da exactamente P/B. En un suelo continuo una zapata rígida **concentra la presión en sus bordes** (382 y 488 kPa frente a 114 kPa en el medio): los resortes (Winkler) no pueden mostrar eso, el suelo mallado sí.
#: **El bulbo de presiones** (lo que describe Boussinesq, aquí por FEM): esfuerzo vertical σ_y en el suelo, σ = D·B·u en el centro de cada cuadrilátero, promediado en los nudos. Compresión positiva [kPa]; con el cursor se ve el valor:
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

## 6 · El suelo por elementos finitos (2): sólido 3D

#: La zapata completa sobre un bloque de suelo 3D de 6 × 4.5 × 3 m con hexaedros de 8 nudos de 0.75 m (6 × 6 × 4); la zapata como 2 × 2 hexaedros de concreto de 0.75 × 0.75 × 0.60. Base fija, lados con rodillos; P, M_x, M_y arriba de la zapata. La misma malla en OpenSees (stdBrick).
#: **Símbolos: función de forma de un hexaedro** (coordenadas naturales ξ, η, ζ) y la matriz D del sólido (λ, G):
N_b1 = Simplify{(1-xi)*(1-eta)*(1-zeta)/8}
l_am = Simplify{E*nu/((1+nu)*(1-2*nu))}
G_s = Simplify{E/(2*(1+nu))}
h_3 = 0.75 'lado del hexaedro [m]
W_3 = 4.5 'ancho del bloque de suelo [m]
H_3 = 3 'profundidad del bloque de suelo [m]
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
w_3 = [-1000·U_3(3·T_n(2, 2)), -1000·U_3(3·(e_z·p_2 + i_0·n_3 + i_0 + 3)), -1000·U_3(3·(e_z·p_2 + (i_0 + 2)·n_3 + i_0 + 1)), -1000·U_3(3·((H_3 - 1.5)/h_3·p_2 + (n_3 - 1)/2·n_3 + (n_3 + 1)/2)), -1000·U_3(3·(e_z·p_2 + (n_3 - 1)/2·n_3 + (n_3 + 1)/2 + 2))] 'asientos [mm]: centro arriba de la zapata, esquinas (0.75; −0.75) y (−0.75; 0.75), suelo a 1.5 m de profundidad, superficie en x = 1.5 m
w3_ops = [5.769229, 6.985553, 4.435608, 2.191077, 1.704312] 'OpenSees stdBrick, mismos nudos [mm]
q3_ops = [365.618869, 188.051611, 428.177492, 139.667323, 65.180715, 171.923515, 240.501624, 123.539227, 303.060246] 'presión de contacto de OpenSees [kPa]
#tabla("Nudo (x; y) [m]","Hekatan LISP, suelo 3D [kPa]:6","OpenSees [kPa]:6")({"(−0.75; −0.75)","(0; −0.75)","(0.75; −0.75)","(−0.75; 0)","(0; 0)","(0.75; 0)","(−0.75; 0.75)","(0; 0.75)","(0.75; 0.75)"}; q_3; q3_ops)
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
dw_3 = max(abs(w_3 - w3_ops)) 'máx |Hekatan − OpenSees| en asiento [mm]
dq_3 = max(abs(q_3 - q3_ops)) 'máx |Hekatan − OpenSees| en presión de contacto [kPa]
#: Lo mismo en 3D: las esquinas cargan más (428 kPa en la esquina +x, −y, donde empujan M_x y M_y) y el centro menos (65 kPa). Los hexaedros de 0.75 m son gruesos (2 × 2 bajo la zapata): es una validación del método contra OpenSees, no una malla de diseño.
#: **Bulbo de presiones en 3D**, corte vertical y = 0: σ_z en el centro de los hexaedros promediado en los nudos [kPa] (compresión positiva):
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
#: **3D: el suelo como sólido**, cortado en y = 0 para ver por dentro: color = esfuerzo vertical σ_z [kPa] (el bulbo en la cara del corte), deformada ×30, la columna como barra. Arrastra para girar, rueda para acercar, cursor para leer:
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

## 7 · Comprobación geotécnica

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
#: Área efectiva de Meyerhof B'·L' (B' el lado menor), N_γ de Vesić, factores de forma de De Beer, arena c = 0. U < 1: el suelo resiste q_max. Asiento s [mm]: elástico, zapata cuadrada rígida, factor de influencia 0.82 (Bowles).
