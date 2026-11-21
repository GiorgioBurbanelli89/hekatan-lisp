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
#contourf(q(x, y), [-B/2 B/2], [-B/2 B/2])
#: Regla de la mano derecha: M_x > 0 comprime el lado −y, M_y > 0 el lado +x. e_x, e_y ≤ B/6 = 0.25 m: toda la base está comprimida.

## 3 · Validación: SAFE 20 y OpenSees

#: La misma zapata en los dos programas: malla 10 × 10 de placas gruesas (Thick de SAFE, ShellMITC4 de OpenSees), E = 24.87 GPa, t = 0.60 m, suelo de Winkler k_s, carga de la columna P, M_x, M_y en el nudo central. Presión del suelo = k_s·w en cada nudo.
#equ
t_rig = [q(B/2, -B/2), q(-B/2, -B/2), q(B/2, B/2), q(-B/2, B/2), q(0, 0)] 'fórmula rígida [kPa]
t_safe = [281.947, 212.252, 142.556, 72.861, 178.821] 'SAFE 20, k_s·w [kPa]
t_ops = [281.960, 212.261, 142.562, 72.863, 178.811] 'OpenSees, k_s·w [kPa]
#tabla("Punto (x; y) [m]","Fórmula rígida [kPa]:2","SAFE 20 [kPa]:2","OpenSees [kPa]:2")({"(0.75; −0.75)","(−0.75; −0.75)","(0.75; 0.75)","(−0.75; 0.75)","(0; 0)"}; t_rig; t_safe; t_ops)
#: SAFE y OpenSees coinciden al 0.005 % (diferencia máxima de asiento 6.5·10⁻⁷ m sobre 14 mm); la suma de reacciones es 400.000 kN. Los dos quedan a 1–2.5 % de la fórmula rígida: la diferencia es que una zapata real de 0.60 m se dobla un poco.

## 4 · Zapata rígida sobre suelo elástico (Boussinesq)

#equ
q_e(x, y) = P/A·4/(pi^2·sqrt(1 - (2·x/B)^2)·sqrt(1 - (2·y/B)^2))
#sust
q_e0 = q_e(0, 0)
#contourf(q_e(x, y), [-0.95·B/2 0.95·B/2], [-0.95·B/2 0.95·B/2])
#: Los resortes de Winkler (SAFE, OpenSees) son independientes: la presión sigue al asiento, y una base rígida da un plano. En un semiespacio elástico el suelo es continuo y la base rígida lleva el esfuerzo a los bordes y esquinas; en el centro queda solo 4/π² ≈ 0.41 de P/A. La arena plastifica en los bordes (más cerca del plano); la arcilla se queda más cerca de esto.

## 5 · Comprobación geotécnica

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
