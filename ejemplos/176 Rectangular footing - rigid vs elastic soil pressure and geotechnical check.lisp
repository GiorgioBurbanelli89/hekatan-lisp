# Rectangular footing: rigid pressure vs elastic soil, and geotechnical check
#numerico

## 1 · Data

B = 2 'width [m]
L = 3 'length [m]
D_f = 1.5 'depth [m]
P = 900 'axial load [kN]
M_x = 120 'moment about x [kN·m]
M_y = 60 'moment about y [kN·m]
gamma = 18 'soil unit weight [kN/m3]
phi = 30 'friction angle [deg]
E_s = 20000 'soil modulus [kPa]
nu_s = 0.3 'soil Poisson ratio
FS = 3 'safety factor

## 2 · Rigid footing: linear pressure

#sust
A = B·L
I_x = B·L^3/12
I_y = L·B^3/12
e_x = M_y/P
e_y = M_x/P
#equ
q(x, y) = P/A + M_y·x/I_y + M_x·y/I_x
#sust
q_max = q(B/2, L/2)
q_min = q(-B/2, -L/2)
#contourf(q(x, y), [-B/2 B/2], [-L/2 L/2])
#: Plane: the pressure changes linearly from q_min to q_max. Both eccentricities are inside the kern (e_x ≤ B/6, e_y ≤ L/6), so the whole base is in compression.

## 3 · Rigid footing on elastic soil (Boussinesq)

#equ
q_e(x, y) = P/A·4/(pi^2·sqrt(1 - (2·x/B)^2)·sqrt(1 - (2·y/L)^2))
#sust
q_e0 = q_e(0, 0)
#contourf(q_e(x, y), [-0.95·B/2 0.95·B/2], [-0.95·L/2 0.95·L/2])
#: Same load, same footing, but the soil is elastic: the rigid base pushes the stress to the edges and corners (in theory infinite). At the center it is only 4/π² ≈ 0.41 of the average P/A. In sand the edges yield and the real pressure is closer to the linear one; in clay it is closer to this one.

## 4 · Geotechnical check

#sust
phi_r = phi·pi/180
N_q = exp(pi·tan(phi_r))·tan(pi/4 + phi_r/2)^2
N_g = 2·(N_q + 1)·tan(phi_r)
B_p = B - 2·e_x
L_p = L - 2·e_y
s_q = 1 + B_p/L_p·tan(phi_r)
s_g = 1 - 0.4·B_p/L_p
q_u = gamma·D_f·N_q·s_q + 0.5·gamma·B_p·N_g·s_g
q_adm = q_u/FS
U = q_max/q_adm
s = 1000·(P/A)·B·(1 - nu_s^2)/E_s·1.06
#: Bearing capacity (Meyerhof effective area B'·L', Vesić N_γ, De Beer shape factors, sand c = 0). U < 1: the soil carries q_max. Settlement s [mm]: elastic, rigid footing, influence factor 1.06 for L/B = 1.5 (Bowles).
