# Batoz DKT thin plate (3-node triangle, 9 DOF) · symbols, K, patch, maps and SAP2000
#numerico
#: DKT (Discrete Kirchhoff Triangle) element by Batoz, Bathe and Ho (1980): the thin-plate triangle used by CSI's Shell-Thin. Three degrees of freedom per node: w, θx = ∂w/∂y, θy = −∂w/∂x. First everything in symbols and then with numbers; it is validated with the patch test, the rigid bodies, the moment maps and the comparison with SAP2000 and ETABS. Bending only: membrane and drilling are another element.

## 0 · From the differential equation to the weak form
#: Kirchhoff thin plate. The vertical displacement w satisfies the differential equation D·∇⁴w = q, with the bending stiffness D = E·t³/(12·(1−ν²)) in kN·m and the load q per unit area in kN/m².
D_flex = Simplify{Em*t^3/(12*(1-nu^2))}
#: Boundary conditions. Essential, imposed on the displacement: fixed w = 0 and ∂w/∂n = 0; simply supported w = 0. Natural, they come out of the weak form by themselves: simply supported Mn = 0; free Mn = 0 and Vn = 0.
#: Test function. The equation is multiplied by a variation δw and integrated over the area A: ∫ δw·(D·∇⁴w − q) dA = 0.
#: It is integrated by parts twice. With the boundary conditions the boundary terms vanish and only second derivatives remain: ∫ δκᵀ·Db·κ dA = ∫ δw·q dA, with the curvatures κ = [−w,xx ; −w,yy ; −2·w,xy] and Db the bending constitutive matrix.
#: Discretization. w is approximated with node-by-node shape functions: w ≈ Σ Nᵢ·wᵢ. The curvatures come from their second derivatives: κ = B·u. The element stiffness is K = ∫ Bᵀ·Db·B dA and the system is K·u = f. The shape functions and B are built in the following sections.

## 1 · Symbols: where the coefficients come from
#: Along side k (from i to j, length l) the rotation along the side follows a cubic and the normal one is linear. At the midpoint:
#: βs = −3/(2·l)·(wj − wi) − 1/4·(βs_i + βs_j) · βn = 1/2·(βn_i + βn_j)
#: They are converted to x, y with C = x_ji/l, S = y_ji/l: βx = C·βs − S·βn, βy = S·βs + C·βn. From there the five coefficients of each side:
a_k = Simplify{-x_ij/(x_ij^2 + y_ij^2)}
b_k = Simplify{3/4*x_ij*y_ij/(x_ij^2 + y_ij^2)}
c_k = Simplify{(1/4*x_ij^2 - 1/2*y_ij^2)/(x_ij^2 + y_ij^2)}
d_k = Simplify{-y_ij/(x_ij^2 + y_ij^2)}
e_k = Simplify{(1/4*y_ij^2 - 1/2*x_ij^2)/(x_ij^2 + y_ij^2)}
#: Check of coefficient c: what βx_i contributes to βx_k is C·(−1/4·C) − S·(1/2)·(−S):
c_comprueba = Simplify{-(C*(-1/4*C) - S*(1/2*(-S)))}
#: With C² = x²/l² and S² = y²/l² it gives 1/4·C² − 1/2·S², the same as c_k.

## 2 · Symbols: the standard triangle (nodes (0,0), (a,0), (0,a))
#: Quadratic interpolation of six nodes: N1 = (1−ξ−η)(1−2ξ−2η), N2 = ξ(2ξ−1), N3 = η(2η−1) and for the sides N4 = 4ξη, N5 = 4η(1−ξ−η), N6 = 4ξ(1−ξ−η).
N1 = Simplify{(1-xi-eta)*(1-2*xi-2*eta)}
N2 = Simplify{xi*(2*xi-1)}
N3 = Simplify{eta*(2*eta-1)}
N4 = Simplify{4*xi*eta}
N5 = Simplify{4*eta*(1-xi-eta)}
N6 = Simplify{4*xi*(1-xi-eta)}
Jt = Simplify{[a, 0; 0, a]}
Dt = Simplify{det([a, 0; 0, a])}
#: Plate bending stiffness and constitutive matrix:
Dpl = Simplify{Em*t^3/(12*(1-nu^2))}
Db = Simplify{Dpl*[1, nu, 0; nu, 1, 0; 0, 0, (1-nu)/2]}
#: Constant curvature energy κxx = 1 over the area A = a²/2: U = 1/2·Dpl·A
U_const = Simplify{1/2*Dpl*a^2/2}

## 3 · Numbers: data
Em = 24850000 [kN/m²] 'elastic modulus of the concrete
nu = 0.2 'Poisson's ratio (no unit)
t = 0.1 [m] 'plate thickness
Dpl = Em*t^3/(12*(1-nu^2)) [kN·m] 'plate bending stiffness
Db = Dpl*[1, nu, 0; nu, 1, 0; 0, 0, (1-nu)/2] [kN·m] 'bending constitutive matrix

## 4 · DKT with numbers (any triangle)
x1 = 0 [m] 'node coordinate
y1 = 0 [m] 'node coordinate
x2 = 2 [m] 'node coordinate
y2 = 0.5 [m] 'node coordinate
x3 = 0.5 [m] 'node coordinate
y3 = 1.5 [m] 'node coordinate
Jt = [x2-x1, y2-y1; x3-x1, y3-y1]
At = det(Jt)/2 [m²] 'triangle area
#: Side 4 = nodes 2-3, side 5 = 3-1, side 6 = 1-2:
l4 = (x2-x3)^2 + (y2-y3)^2 [m²] 'square of the side length
l5 = (x3-x1)^2 + (y3-y1)^2 [m²] 'square of the side length
l6 = (x1-x2)^2 + (y1-y2)^2 [m²] 'square of the side length
a4 = -(x2-x3)/l4 'side coefficient, in 1/m
a5 = -(x3-x1)/l5 'side coefficient, in 1/m
a6 = -(x1-x2)/l6 'side coefficient, in 1/m
b4 = 0.75*(x2-x3)*(y2-y3)/l4
b5 = 0.75*(x3-x1)*(y3-y1)/l5
b6 = 0.75*(x1-x2)*(y1-y2)/l6
c4 = (0.25*(x2-x3)^2 - 0.5*(y2-y3)^2)/l4
c5 = (0.25*(x3-x1)^2 - 0.5*(y3-y1)^2)/l5
c6 = (0.25*(x1-x2)^2 - 0.5*(y1-y2)^2)/l6
d4 = -(y2-y3)/l4 'side coefficient, in 1/m
d5 = -(y3-y1)/l5 'side coefficient, in 1/m
d6 = -(y1-y2)/l6 'side coefficient, in 1/m
e4 = (0.25*(y2-y3)^2 - 0.5*(x2-x3)^2)/l4
e5 = (0.25*(y3-y1)^2 - 0.5*(x3-x1)^2)/l5
e6 = (0.25*(y1-y2)^2 - 0.5*(x1-x2)^2)/l6
#: The rows Hx and Hy are linear in the six N; the N or their derivatives are substituted:
Hx_t(n1, n2, n3, n4, n5, n6) = [1.5*(a6*n6 - a5*n5); b5*n5 + b6*n6; n1 - c5*n5 - c6*n6; 1.5*(a4*n4 - a6*n6); b6*n6 + b4*n4; n2 - c6*n6 - c4*n4; 1.5*(a5*n5 - a4*n4); b4*n4 + b5*n5; n3 - c4*n4 - c5*n5]
Hy_t(n1, n2, n3, n4, n5, n6) = [1.5*(d6*n6 - d5*n5); -n1 + e5*n5 + e6*n6; -b5*n5 - b6*n6; 1.5*(d4*n4 - d6*n6); -n2 + e6*n6 + e4*n4; -b6*n6 - b4*n4; 1.5*(d5*n5 - d4*n4); -n3 + e4*n4 + e5*n5; -b4*n4 - b5*n5]
#: Inverse of the Jacobian (constant over the triangle): [∂x; ∂y] = J⁻¹·[∂ξ; ∂η]
Ji = inv(Jt)
J11 = Ji(1, 1)
J12 = Ji(1, 2)
J21 = Ji(2, 1)
J22 = Ji(2, 2)
#: Derivatives of Hx and Hy with respect to x and y (each is a column of 9). The derivatives of the N with respect to ξ: (4(ξ+η)−3, 4ξ−1, 0, 4η, −4η, 4(1−2ξ−η)); with respect to η: (4(ξ+η)−3, 0, 4η−1, 4ξ, 4(1−ξ−2η), −4ξ)
Hx_x(xi, eta) = J11*Hx_t(4*(xi+eta)-3, 4*xi-1, 0, 4*eta, -4*eta, 4*(1-2*xi-eta)) + J12*Hx_t(4*(xi+eta)-3, 0, 4*eta-1, 4*xi, 4*(1-xi-2*eta), -4*xi)
Hx_y(xi, eta) = J21*Hx_t(4*(xi+eta)-3, 4*xi-1, 0, 4*eta, -4*eta, 4*(1-2*xi-eta)) + J22*Hx_t(4*(xi+eta)-3, 0, 4*eta-1, 4*xi, 4*(1-xi-2*eta), -4*xi)
Hy_x(xi, eta) = J11*Hy_t(4*(xi+eta)-3, 4*xi-1, 0, 4*eta, -4*eta, 4*(1-2*xi-eta)) + J12*Hy_t(4*(xi+eta)-3, 0, 4*eta-1, 4*xi, 4*(1-xi-2*eta), -4*xi)
Hy_y(xi, eta) = J21*Hy_t(4*(xi+eta)-3, 4*xi-1, 0, 4*eta, -4*eta, 4*(1-2*xi-eta)) + J22*Hy_t(4*(xi+eta)-3, 0, 4*eta-1, 4*xi, 4*(1-xi-2*eta), -4*xi)
#: The three rows of B (curvatures κxx = βx,x, κyy = βy,y, κxy = βx,y + βy,x):
B1_t(xi, eta) = Hx_x(xi, eta)
B2_t(xi, eta) = Hy_y(xi, eta)
B3_t(xi, eta) = Hx_y(xi, eta) + Hy_x(xi, eta)
#: BᵀDB = sum of Db(i,j)·(row i)ᵀ·(row j):
kb_t(xi, eta) = Db(1, 1)*B1_t(xi, eta)*transpose(B1_t(xi, eta)) + Db(1, 2)*(B1_t(xi, eta)*transpose(B2_t(xi, eta)) + B2_t(xi, eta)*transpose(B1_t(xi, eta))) + Db(2, 2)*B2_t(xi, eta)*transpose(B2_t(xi, eta)) + Db(3, 3)*B3_t(xi, eta)*transpose(B3_t(xi, eta))
#: Three Gauss points (midpoints of the sides), weight A/3 each:
K_dkt = At/3*(kb_t(0.5, 0) + kb_t(0.5, 0.5) + kb_t(0, 0.5))
K_dkt_11 = K_dkt(1, 1) [kN/m] 'stiffness to w of node 1
K_dkt_22 = K_dkt(2, 2) [kN·m] 'stiffness to rotation of node 1
K_dkt_33 = K_dkt(3, 3) [kN·m] 'stiffness to rotation of node 1

## 5 · DKT: patch test and rigid body
#: Constant curvature w = x²/2: w = x²/2, θx = ∂w/∂y = 0, θy = −∂w/∂x = −x at each node.
u_par_t = [x1^2/2; 0; -x1; x2^2/2; 0; -x2; x3^2/2; 0; -x3]
#: B·u must give (−1, 0, 0) at any point:
kxx_t = transpose(B1_t(0.2, 0.3))*u_par_t
kyy_t = transpose(B2_t(0.2, 0.3))*u_par_t
kxy_t = transpose(B3_t(0.2, 0.3))*u_par_t
U_t = 0.5*transpose(u_par_t)*K_dkt*u_par_t [kN·m] 'strain energy
U_t_exacta = 0.5*Dpl*At [kN·m] 'strain energy
#: Vertical translation and rigid rotation (w = x): K·u must be zero.
u_tras_t = [1; 0; 0; 1; 0; 0; 1; 0; 0]
f_tras_t = K_dkt*u_tras_t
u_giro_t = [x1; 0; -1; x2; 0; -1; x3; 0; -1]
f_giro_t = K_dkt*u_giro_t

## 6 · Comparison with SAP2000 (Plate-Thin)
#: Same triangle as section 4 and the field w = x³/6 + x·y²/2 imposed as displacements at the three nodes (w, θx = x·y, θy = −(x²+y²)/2). With the 9 DOF restrained, the SAP2000 reaction is K·u. SAP2000 24: Plate-Thin area, no automatic mesh, units kN and m.
wf(x, y) = x^3/6 + x*y^2/2
u_s_t = [wf(x1, y1); x1*y1; -(x1^2+y1^2)/2; wf(x2, y2); x2*y2; -(x2^2+y2^2)/2; wf(x3, y3); x3*y3; -(x3^2+y3^2)/2]
f_t = K_dkt*u_s_t 'DKT reactions: kN for w and kN·m for θx, θy
#: SAP2000 reactions (w, θx, θy of each node), copied from its output [SAP2000 OAPI]:
f_sap_t = [3644.278276; -82.364302; -555.595142; -2513.109557; 642.343285; -3290.592954; -1131.168719; 2393.328875; -1745.615377] 'reactions: force in kN for w and moment in kN·m for θx, θy
dif_t = f_t - f_sap_t
err_t = 100*sqrt(transpose(dif_t)*dif_t)/sqrt(transpose(f_sap_t)*f_sap_t) [%] 'relative difference
#: DKT moments at each node (B evaluated at the node, area coordinates):
Mxx_nt(xi, eta) = Db(1, 1)*transpose(B1_t(xi, eta))*u_s_t + Db(1, 2)*transpose(B2_t(xi, eta))*u_s_t
Myy_nt(xi, eta) = Db(1, 2)*transpose(B1_t(xi, eta))*u_s_t + Db(2, 2)*transpose(B2_t(xi, eta))*u_s_t
Mxy_nt(xi, eta) = Db(3, 3)*transpose(B3_t(xi, eta))*u_s_t
M_t1 = [Mxx_nt(0, 0), Myy_nt(0, 0), Mxy_nt(0, 0)] [kN·m/m] 'moments Mxx Myy Mxy of the node
M_t2 = [Mxx_nt(1, 0), Myy_nt(1, 0), Mxy_nt(1, 0)] [kN·m/m] 'moments Mxx Myy Mxy of the node
M_t3 = [Mxx_nt(0, 1), Myy_nt(0, 1), Mxy_nt(0, 1)] [kN·m/m] 'moments Mxx Myy Mxy of the node
#: SAP2000 (M11, M22, M12) at nodes 1 to 3 [SAP2000 OAPI]. SAP2000 gives the moment with the opposite sign to this sheet (M11 = −Mxx, M22 = −Myy, M12 = −Mxy), so the sum of the two must give zero:
M_sapt1 = [-611.491059, -740.226019, 836.777239] [kN·m/m] 'moments Mxx Myy Mxy of the node
M_sapt2 = [5144.695506, 4237.836331, 700.908084] [kN·m/m] 'moments Mxx Myy Mxy of the node
M_sapt3 = [455.257503, 1573.941943, 2153.497718] [kN·m/m] 'moments Mxx Myy Mxy of the node
n3(v) = sqrt(v(1)^2 + v(2)^2 + v(3)^2)
err_M_t = 100*sqrt(n3(M_t1 + M_sapt1)^2 + n3(M_t2 + M_sapt2)^2 + n3(M_t3 + M_sapt3)^2)/sqrt(n3(M_sapt1)^2 + n3(M_sapt2)^2 + n3(M_sapt3)^2) [%] 'relative difference

#: ETABS 22 (OAPI, Shell-Thin slab, OBJMESHTYPE NOAUTOMESH so it does not remesh; its membrane DOF stay at zero, so they do not affect bending). Same reactions and same moments [ETABS OAPI]:
f_etabs_t = [3644.278338; -82.364139; -555.595033; -2513.109192; 642.343417; -3290.592722; -1131.169146; 2393.329038; -1745.615202] 'reactions: force in kN for w and moment in kN·m for θx, θy
err_t_etabs = 100*sqrt(transpose(f_t - f_etabs_t)*(f_t - f_etabs_t))/sqrt(transpose(f_etabs_t)*f_etabs_t) [%] 'relative difference
M_etabst1 = [-611.490864, -740.226179, 836.777226] [kN·m/m] 'moments Mxx Myy Mxy of the node
M_etabst2 = [5144.69518, 4237.835935, 700.908183] [kN·m/m] 'moments Mxx Myy Mxy of the node
M_etabst3 = [455.257903, 1573.942229, 2153.497644] [kN·m/m] 'moments Mxx Myy Mxy of the node
err_M_t_etabs = 100*sqrt(n3(M_t1 + M_etabst1)^2 + n3(M_t2 + M_etabst2)^2 + n3(M_t3 + M_etabst3)^2)/sqrt(n3(M_etabst1)^2 + n3(M_etabst2)^2 + n3(M_etabst3)^2) [%] 'relative difference

## 7 · Maps over the SAP2000 and ETABS triangle (to compare with the mouse)
#: The same triangle (0,0), (2,0.5), (0.5,1.5) and the same field as sections 4 and 6. x, y are converted to ξ, η with the inverse of the Jacobian: ξ = (x−x1)·J11 + (y−y1)·J21, η = (x−x1)·J12 + (y−y1)·J22. It only holds inside the triangle. Move the mouse over the nodes: at (0,0), (2,0.5) and (0.5,1.5) it must read Mxx = −M11 of SAP2000 and ETABS (−611.49, 5144.70, 455.26 with the SAP sign).
xi_p(x, y) = (x - x1)*J11 + (y - y1)*J21
eta_p(x, y) = (x - x1)*J12 + (y - y1)*J22
Mxx_p(x, y) = Mxx_nt(xi_p(x, y), eta_p(x, y))
Myy_p(x, y) = Myy_nt(xi_p(x, y), eta_p(x, y))
Mxy_p(x, y) = Mxy_nt(xi_p(x, y), eta_p(x, y))
#: Mxx (kN·m/m):
#map(Mxx_p(x, y), [0 2], [0 1.5])
#: Myy (kN·m/m):
#map(Myy_p(x, y), [0 2], [0 1.5])
#: Mxy (kN·m/m):
#map(Mxy_p(x, y), [0 2], [0 1.5])

## 8 · Maps of Mxx, Myy and Mxy (move the mouse and read the value)
#: The same field w = x³/6 + x·y²/2 over a right triangle with legs 4 and 3: nodes (0,0), (4,0), (0,3), with ξ = x/4 and η = y/3. Only the part under the diagonal (x/4 + y/3 ≤ 1) holds; the rest of the box is extrapolation and does not count.
x1 = 0 [m] 'node coordinate
y1 = 0 [m] 'node coordinate
x2 = 4 [m] 'node coordinate
y2 = 0 [m] 'node coordinate
x3 = 0 [m] 'node coordinate
y3 = 3 [m] 'node coordinate
Jt = [x2-x1, y2-y1; x3-x1, y3-y1]
At = det(Jt)/2 [m²] 'triangle area
#: Side 4 = nodes 2-3, side 5 = 3-1, side 6 = 1-2:
l4 = (x2-x3)^2 + (y2-y3)^2 [m²] 'square of the side length
l5 = (x3-x1)^2 + (y3-y1)^2 [m²] 'square of the side length
l6 = (x1-x2)^2 + (y1-y2)^2 [m²] 'square of the side length
a4 = -(x2-x3)/l4 'side coefficient, in 1/m
a5 = -(x3-x1)/l5 'side coefficient, in 1/m
a6 = -(x1-x2)/l6 'side coefficient, in 1/m
b4 = 0.75*(x2-x3)*(y2-y3)/l4
b5 = 0.75*(x3-x1)*(y3-y1)/l5
b6 = 0.75*(x1-x2)*(y1-y2)/l6
c4 = (0.25*(x2-x3)^2 - 0.5*(y2-y3)^2)/l4
c5 = (0.25*(x3-x1)^2 - 0.5*(y3-y1)^2)/l5
c6 = (0.25*(x1-x2)^2 - 0.5*(y1-y2)^2)/l6
d4 = -(y2-y3)/l4 'side coefficient, in 1/m
d5 = -(y3-y1)/l5 'side coefficient, in 1/m
d6 = -(y1-y2)/l6 'side coefficient, in 1/m
e4 = (0.25*(y2-y3)^2 - 0.5*(x2-x3)^2)/l4
e5 = (0.25*(y3-y1)^2 - 0.5*(x3-x1)^2)/l5
e6 = (0.25*(y1-y2)^2 - 0.5*(x1-x2)^2)/l6
Ji = inv(Jt)
J11 = Ji(1, 1)
J12 = Ji(1, 2)
J21 = Ji(2, 1)
J22 = Ji(2, 2)
uw_t = [0; 0; 0; 64/6; 0; -8; 0; 0; -9/2]
k1_t(x, y) = transpose(B1_t(x/4, y/3))*uw_t
k2_t(x, y) = transpose(B2_t(x/4, y/3))*uw_t
k3_t(x, y) = transpose(B3_t(x/4, y/3))*uw_t
Mxx_t(x, y) = Db(1, 1)*k1_t(x, y) + Db(1, 2)*k2_t(x, y)
Myy_t(x, y) = Db(1, 2)*k1_t(x, y) + Db(2, 2)*k2_t(x, y)
Mxy_t(x, y) = Db(3, 3)*k3_t(x, y)
#: At the centroid (4/3, 1) and the exact value of the continuous plate:
Mxx_tc = Mxx_t(4/3, 1) [kN·m/m] 'moment at the centroid
Mxx_tex = -Dpl*(1+nu)*4/3 [kN·m/m] 'moment at the centroid
Mxy_tc = Mxy_t(4/3, 1) [kN·m/m] 'moment at the centroid
Mxy_tex = -Dpl*(1-nu)*1 [kN·m/m] 'moment at the centroid
#: DKT Mxx (kN·m/m):
#map(Mxx_t(x, y), [0 4], [0 3])
#: DKT Myy (kN·m/m):
#map(Myy_t(x, y), [0 4], [0 3])
#: DKT Mxy (kN·m/m):
#map(Mxy_t(x, y), [0 4], [0 3])

## The labels
