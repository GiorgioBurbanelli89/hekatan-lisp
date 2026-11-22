# Zapata aislada 1.50 × 1.50 m: presión rígida vs SAFE y OpenSees, suelo elástico y comprobación geotécnica
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

## 5 · Zapata rígida sobre suelo elástico (Boussinesq)

#equ
q_e(x, y) = P/A·4/(pi^2·sqrt(1 - (2·x/B)^2)·sqrt(1 - (2·y/B)^2))
#sust
q_e0 = q_e(0, 0)
#contourf(q_e(x, y), [-0.95·B/2 0.95·B/2], [-0.95·B/2 0.95·B/2])
#surf(q_e(x, y), [-0.95·B/2 0.95·B/2], [-0.95·B/2 0.95·B/2])
#: Los resortes de Winkler (SAFE, OpenSees) son independientes: la presión sigue al asiento, y una base rígida da un plano. En un semiespacio elástico el suelo es continuo y la base rígida lleva el esfuerzo a los bordes y esquinas; en el centro queda solo 4/π² ≈ 0.41 de P/A. La arena plastifica en los bordes (más cerca del plano); la arcilla se queda más cerca de esto.

## 6 · Comprobación geotécnica

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
