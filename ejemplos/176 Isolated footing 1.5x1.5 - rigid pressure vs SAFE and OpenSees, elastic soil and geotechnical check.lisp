# Isolated footing 1.50 × 1.50 m: rigid pressure vs SAFE and OpenSees, elastic soil and geotechnical check
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
#contourf(q(x, y), [-B/2 B/2], [-B/2 B/2])
#: Right-hand rule: M_x > 0 compresses the −y side, M_y > 0 the +x side. e_x, e_y ≤ B/6 = 0.25 m: the whole base is in compression.

## 3 · Validation: SAFE 20 and OpenSees

#: Same footing in both programs: 10 × 10 mesh of thick shells (SAFE Thick, OpenSees ShellMITC4), E = 24.87 GPa, t = 0.60 m, Winkler soil k_s, column load P, M_x, M_y at the center node. Soil pressure = k_s·w at each node.
#equ
t_rig = [q(B/2, -B/2), q(-B/2, -B/2), q(B/2, B/2), q(-B/2, B/2), q(0, 0)] 'rigid formula [kPa]
t_safe = [281.947, 212.252, 142.556, 72.861, 178.821] 'SAFE 20, k_s·w [kPa]
t_ops = [281.960, 212.261, 142.562, 72.863, 178.811] 'OpenSees, k_s·w [kPa]
#tabla("Point (x; y) [m]","Rigid formula [kPa]:2","SAFE 20 [kPa]:2","OpenSees [kPa]:2")({"(0.75; −0.75)","(−0.75; −0.75)","(0.75; 0.75)","(−0.75; 0.75)","(0; 0)"}; t_rig; t_safe; t_ops)
#: SAFE and OpenSees agree to 0.005 % (max settlement difference 6.5·10⁻⁷ m out of 14 mm); sum of reactions = 400.000 kN. Both stay within 1–2.5 % of the rigid formula: the difference is the slight bending of a real 0.60 m footing.

## 4 · Rigid footing on elastic soil (Boussinesq)

#equ
q_e(x, y) = P/A·4/(pi^2·sqrt(1 - (2·x/B)^2)·sqrt(1 - (2·y/B)^2))
#sust
q_e0 = q_e(0, 0)
#contourf(q_e(x, y), [-0.95·B/2 0.95·B/2], [-0.95·B/2 0.95·B/2])
#: Winkler springs (SAFE, OpenSees) are independent: the pressure follows the settlement, so a rigid base gives a plane. On an elastic half-space the soil is continuous and the rigid base pushes the stress to the edges and corners; at the center it is only 4/π² ≈ 0.41 of P/A. Sand yields at the edges (closer to the plane); clay stays closer to this.

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
