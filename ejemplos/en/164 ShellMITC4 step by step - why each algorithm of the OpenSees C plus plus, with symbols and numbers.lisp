# OpenSees ShellMITC4 step by step: why the C++ does what it does
#numerico
#: Sheet of the class «OpenSees · ShellMITC4». Each step goes from the **question** to the **idea**, from the idea to the **symbol** (the engine derives it) and from the symbol to the **C++ line** of `SRC/element/shell/ShellMITC4.cpp` (OpenSees master, 2555 lines). The numbers are those of the element of the **Guerra footing** (ch. 5, ex. 1): a 0.345 m square, h = 0.45 m, in t and m.
#: Verification: the numpy replica of the C++ gives the 24 × 24 K of OpenSees running with relative error 1e-16 (hekatan-school/VIDEOS/mitc4_clase/datos.py).

## 1 · What does the shell do? Membrane + plate + in-plane rotation
#: Each node carries 6 numbers: u1, u2 of **membrane** (stretching in its plane), w, θ1, θ2 of **plate** (bending and shear) and θ3 of **drilling** (rotation in its plane). C++: comment of `formResidAndTangent`, lines 1332-1343; `ndf = 6` l.1370; `nstress = 8` l.1372 (3 membrane, 3 moments, 2 shears).
E = 14100*sqrt(280)*10 'concrete modulus f'c = 280, in t/m²
nu = 0.2
h = 0.45 'footing thickness, m
#: The section (ElasticMembranePlateSection.cpp, l.244-267) gives four stiffnesses:
M_m = E/(1 - nu^2)*h 'membrane, t/m
G_h = 0.5*E/(1 + nu)*h 'in-plane shear, t/m
D_b = E*h^3/12/(1 - nu^2) 'bending, t·m
G_s = 5/6*G_h 'transverse shear with κ = 5/6 (five6, l.41 and l.265)
#: **Drilling.** The Q4 membrane has no stiffness for θ3: K would come out singular. OpenSees adds a fictitious stiffness Ktt = the smallest eigenvalue of the membrane block (l.397-401). In an isotropic material the eigenvalues are M(1+ν), M(1−ν) and G·h; the smallest is G·h:
eig_1 = M_m*(1 + nu)
eig_2 = M_m*(1 - nu)
Ktt = G_h 'the smallest of the three

## 2 · In which axes is it measured? The local basis (computeBasis, l.1788-1835)
#: If the element is inclined in space, the element x and y are not the global ones. v1 = ½(node3 + node2 − node4 − node1): the mean «left to right» direction. v2 = ½(node4 + node3 − node2 − node1), with Gram-Schmidt so that it is perpendicular to v1. v3 = v1 × v2 is the normal. With an inclined quadrilateral (the distorted one of the class rotated 35° and 20°, datos.py):
X_i = [0.5, 0.3, 1; 2.3794, 0.8562, 0.5544; 2.6613, 2.2257, 1.3881; 0.406, 1.5091, 1.8884]
w_1 = 0.5*(X_i(3, :) + X_i(2, :) - X_i(4, :) - X_i(1, :))
v_1 = w_1/norm(w_1)
w_2 = 0.5*(X_i(4, :) + X_i(3, :) - X_i(2, :) - X_i(1, :))
al = w_2(1)*v_1(1) + w_2(2)*v_1(2) + w_2(3)*v_1(3) 'alpha = v2·v1 of Gram-Schmidt (l.1812)
u_2 = w_2 - al*v_1
v_2 = u_2/norm(u_2)
v_3 = [v_1(2)*v_2(3) - v_1(3)*v_2(2), v_1(3)*v_2(1) - v_1(1)*v_2(3), v_1(1)*v_2(2) - v_1(2)*v_2(1)] 'the normal v1 × v2 (LovelyCrossProduct, l.1825)
#: The local coordinates are the projections (l.1833-1834): xl = X·v1, yl = X·v2. Node 1 is not subtracted: only the differences matter.
x_l = X_i*transpose(v_1)
y_l = X_i*transpose(v_2)

## 3 · A single formula for all: the parent element [−1, 1]²
#: Each real element has another shape; everything is written in a fixed square of ξ, η between −1 and 1. The C++ (shape2d, l.2196-2206) writes the functions with s_k, t_k = ±½: N_k = (½ + s_k·ξ)(½ + t_k·η). They are the usual bilinears:
N_1 = Expand{(1/2 - xi/2)*(1/2 - eta/2)}
N_2 = Expand{(1/2 + xi/2)*(1/2 - eta/2)}
N_3 = Expand{(1/2 + xi/2)*(1/2 + eta/2)}
N_4 = Expand{(1/2 - xi/2)*(1/2 + eta/2)}
#: Derivatives with respect to ξ and η (l.2204-2205: shp[0] = s_k·(½ + t_k·η), shp[1] = t_k·(½ + s_k·ξ)):
dN1_dxi = Partial{(1/2 - xi/2)*(1/2 - eta/2) @ xi}
dN1_deta = Partial{(1/2 - xi/2)*(1/2 - eta/2) @ eta}
#: **Jacobian** (l.2211-2222): xs = Σ x_k·∂N_k/∂ξ. For a rectangle of sides L_x × L_y with node 1 at the origin, x = L_x·(N_2 + N_3) and y = L_y·(N_3 + N_4):
x_r = Simplify{Lx*((1/2 + xi/2)*(1/2 - eta/2) + (1/2 + xi/2)*(1/2 + eta/2))}
y_r = Simplify{Ly*((1/2 + xi/2)*(1/2 + eta/2) + (1/2 - xi/2)*(1/2 + eta/2))}
J11 = Partial{Lx*(1+xi)/2 @ xi}
J12 = Partial{Lx*(1+xi)/2 @ eta}
J21 = Partial{Ly*(1+eta)/2 @ xi}
J22 = Partial{Ly*(1+eta)/2 @ eta}
detJ_r = Simplify{J11*J22 - J12*J21}
#: det J = L_x·L_y/4: the real area (L_x·L_y) divided by the parent area (4). It is the factor that converts dξ·dη into dx·dy. In an arbitrary quadrilateral J changes from point to point; in the distorted one of the class, at the first Gauss point:
X_d = [0, 0; 2, 0.2; 2.3, 1.8; -0.1, 1.5]
s_g = 1/sqrt(3)
dN_g(xi, eta) = 0.25*[-(1 - eta), (1 - eta), (1 + eta), -(1 + eta); -(1 - xi), -(1 + xi), (1 + xi), (1 - xi)]
J_g1 = dN_g(-s_g, -s_g)*X_d
detJ_g1 = det(J_g1) 'xsj of point 1
#: The real derivatives come out with the inverse (l.2225-2238): [∂N/∂x; ∂N/∂y] = J⁻¹·[∂N/∂ξ; ∂N/∂η]:
dNxy_g1 = inv(J_g1)*dN_g(-s_g, -s_g)

## 4 · Why 2 × 2 Gauss? The integral becomes a loop of 4 rounds
#: K = ∫∫ Bᵀ·D·B dx·dy. With 4 points (±1/√3, ±1/√3) and weight 1 (l.234-247) the sum is EXACT for polynomials up to degree 3 in each direction. Test with the engine: exact integral against the 4-point sum.
I_22 = Area{Area{xi^2*eta^2 @ xi = -1 : 1} @ eta = -1 : 1} 'exact
G_22 = 4*(1/3)*(1/3) 'Gauss: four points with ξ² = η² = 1/3
I_32 = Area{Area{(1 + xi)^3*eta^2 @ xi = -1 : 1} @ eta = -1 : 1}
G_32 = ((1 - s_g)^3 + (1 + s_g)^3)*2*(1/3)
I_4 = Area{Area{xi^4 @ xi = -1 : 1} @ eta = -1 : 1} 'degree 4: Gauss 2 × 2 no longer hits
G_4 = 4*(1/9)
#: In the C++ each round multiplies by dvol = w·det J (l.1532): the weight times the area the point represents. Sum of the 4 dvol of the distorted one = its area:
A_g = det(dN_g(-s_g, -s_g)*X_d) + det(dN_g(s_g, -s_g)*X_d) + det(dN_g(s_g, s_g)*X_d) + det(dN_g(-s_g, s_g)*X_d)

## 5 · The rows of B, node by node
#: B converts the 6 displacements of ONE node into the 8 strains. One node is assembled at a time (loop j, l.1553) because the B of a node only depends on ITS shape function; the four are stored (saveB, l.1569-1572) and K is assembled by 6 × 6 blocks: K_jk = B_jᵀ·D·B_k.
#: **Membrane** (computeBmembrane, l.2140-2143): ε11 = N,1·u1; ε22 = N,2·u2; γ12 = N,2·u1 + N,1·u2.
#: **Bending** (computeBbend, l.2171-2174): κ11 = −N,1·θ2; κ22 = N,2·θ1; 2κ12 = N,1·θ1 − N,2·θ2.
#: **Drilling** (computeBdrill, l.1973-1977): [−½·N,2, +½·N,1, −N] over [u1, u2, θ3].
#: For node 1 of a rectangle of sides 2a × 2b (center at the origin), ∂N_1/∂x and ∂N_1/∂y:
N1_x = Simplify{Partial{(1-xi)*(1-eta)/4 @ xi}/a}
N1_y = Simplify{Partial{(1-xi)*(1-eta)/4 @ eta}/b}
#: and its rows (columns [θ1, θ2] in bending):
Bbend_1 = Simplify{[0, -(-(1-eta)/(4*a)); -(1-xi)/(4*b), 0; -(1-eta)/(4*a), -(-(1-xi)/(4*b))]}
#: The sign: the section gives M = −D·κ (dd(3,3) = −D in the section), and the element changes the sign of the bending block of BJ (l.1641-1646): (−Bb)ᵀ(−D)Bb = +BbᵀDBb.

## 6 · Shear locking and the MITC4 correction
#: Thin plate in **pure bending**: the rotation θy goes from −θ0 to +θ0 along x and the deflection w is 0 at the four nodes. The theory says γxz = ∂w/∂x + θy = 0 (a thin plate does not deform by shear). But with the bilinears the element can only do:
th_y(xi, eta) = Simplify{-t0*(1-xi)*(1-eta)/4 + t0*(1+xi)*(1-eta)/4 + t0*(1+xi)*(1+eta)/4 - t0*(1-xi)*(1+eta)/4}
#: Since w = 0 at the nodes, ∂w/∂x = 0 and the direct shear is only the interpolated rotation:
g_dir(xi, eta) = th_y(xi, eta) 'γ = θ0·ξ: different from zero
#: At the Gauss points it is ±θ0/√3: the element «believes» there is shear and charges it with G_s·h, which is enormous compared with the bending. False shear energy against true bending energy (κ = θ0/a):
U_s = Simplify{1/2*Gs*a*b*Area{Area{(t0*xi)^2 @ xi = -1 : 1} @ eta = -1 : 1}}
U_b = Simplify{1/2*Db*(t0/a)^2*4*a*b}
r_sb = Simplify{U_s/U_b}
#: With G_s = (5/6)·G·h and D = E·h³/(12(1−ν²)), the ratio grows as (a/h)²: the thinner, the more it locks.
rsb_h = Simplify{(5/6*Ee/(2*(1+nn))*hh)*a^2/(3*Ee*hh^3/(12*(1-nn^2)))}
#: **The MITC4 idea.** At the center of each side (tying points A(0, −1), B(0, +1) for γxz; C(−1, 0), D(+1, 0) for γyz) the false shear is ZERO. It is measured only there and interpolated linearly: γxz(ξ, η) = ½(1 − η)·γ_A + ½(1 + η)·γ_B.
g_A = g_dir(0, -1) 'tying point A, center of the bottom side
g_B = g_dir(0, 1) 'tying point B, center of the top side
g_mitc = Simplify{(1-eta)/2*g_A + (1+eta)/2*g_B} 'zero over the whole element: no locking
#: In the C++ the tying points are the rows of G(4,12) (l.1462-1488): one per side (4-1, 1-2, 2-3, 3-4) with ±½ for the w (difference of deflections) and ±Δy/4, Δx/4 for the rotations (mean rotation of the side times the side length). The linear interpolation is Ms (l.1535-1538) with (1 − s), (1 − t), (1 + s), (1 + t); r/(8·det J) (l.1542-1543) goes from shear «per side» to shear per unit length, and Rot (l.1503-1510) rotates it to the x, y axes.

## 7 · The formStiffness loop: the box that starts at zero
#: K = Σ_{gp=1..4} Σ_{j=1..4} Σ_{k=1..4} B_jᵀ·D·B_k·dvol_gp (l.1518 Gauss loop, l.1633 node j, l.1676 node k, l.1693-1698 stiff(jj+p, kk+q) += ...). With the footing element, the term for the deflection of node 1 (shear only: bending does not touch w) in each round:
a_z = 0.345/2 'half side
d_z = a_z*a_z 'det J of the square: (0.345/2)², the same at the 4 points
#: Row of γxz and γyz for column w1 (MITC4 in a rectangle: −1/(4a)·(1 ∓ η) and −1/(4b)·(1 ∓ ξ) measured on the sides):
kw(xi, eta) = d_z*G_s*((-(1 - eta)/(4*a_z))^2 + (-(1 - xi)/(4*a_z))^2)
K_0 = 0 'the box starts at zero (stiff.Zero(), l.1442)
K_1 = K_0 + kw(-s_g, -s_g)
K_2 = K_1 + kw(s_g, -s_g)
K_3 = K_2 + kw(s_g, s_g)
K_4 = K_3 + kw(-s_g, s_g)
#: OpenSees running (printA) gives K[w1, w1] = 245768.882794 t/m: K_4 must give that. In the w column the MITC4 row of a rectangle equals the direct one (∂w/∂x is already linear in η); the MITC difference is in the rotation columns, which is where the false shear of step 6 was born.
K_ops = 245768.882794 't/m, OpenSees printA
err_K = (K_4 - K_ops)/K_ops

## 8 · The whole footing
#: 100 elements like this, 121 nodes with Winkler springs ks = 2920 t/m³, service load P = 121 t and My = 17 t·m at the center. The same loop (replica) and OpenSees running give the same maximum pressure:
sigR = 13.249780 't/m², numpy replica of the C++ (calc_extra.py)
sigO = 13.249780 't/m², openseespy 3.7.1 (zapata_opensees.py)
sigL = 13.163 't/m², SAFE in Guerra's book
difL = (sigO - sigL)/sigL*100 '% difference with the book
