# Batoz DKQ thin plate (4-node quadrilateral, 12 DOF) · symbols, K, patch test, maps and SAP2000
#numerico
#: DKQ element (Discrete Kirchhoff Quadrilateral) of Batoz and Tahar (1982): the thin plate quadrilateral used by CSI Shell-Thin. Three degrees of freedom per node: w, θx = ∂w/∂y, θy = −∂w/∂x. First everything in symbols and then with numbers; it is validated with the patch test, the rigid bodies, the moment maps and the comparison with SAP2000 and ETABS. Bending only: the membrane and the drilling are another element.

## 0 · From the differential equation to the weak form
#: Kirchhoff thin plate. The vertical displacement w satisfies the differential equation D·∇⁴w = q, with the flexural rigidity D = E·t³/(12·(1−ν²)) in kN·m and the load q per unit area in kN/m².
D_flex = Simplify{Em*t^3/(12*(1-nu^2))}
#: Boundary conditions. Essential ones, imposed on the displacement: fixed w = 0 and ∂w/∂n = 0; simply supported w = 0. Natural ones, which come out by themselves from the weak form: simply supported Mn = 0; free Mn = 0 and Vn = 0.
#: Test function. The equation is multiplied by a variation δw and integrated over the area A: ∫ δw·(D·∇⁴w − q) dA = 0.
#: Integrating by parts twice. With the boundary conditions the boundary terms vanish and only second derivatives remain: ∫ δκᵀ·Db·κ dA = ∫ δw·q dA, with the curvatures κ = [−w,xx ; −w,yy ; −2·w,xy] and Db the bending constitutive matrix.
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
#: Check of the coefficient c: what βx_i contributes to βx_k is C·(−1/4·C) − S·(1/2)·(−S):
c_comprueba = Simplify{-(C*(-1/4*C) - S*(1/2*(-S)))}
#: With C² = x²/l² and S² = y²/l² it gives 1/4·C² − 1/2·S², the same as c_k.

## 2 · Numbers: data
Em = 24850000 [kN/m²] 'modulus of elasticity of the concrete
nu = 0.2 'Poisson's ratio (unitless)
t = 0.1 [m] 'plate thickness
Dpl = Em*t^3/(12*(1-nu^2)) [kN·m] 'flexural rigidity of the plate
Db = Dpl*[1, nu, 0; nu, 1, 0; 0, 0, (1-nu)/2] [kN·m] 'bending constitutive matrix

## 3 · DKQ: the N of eight nodes (four corners and four midpoints)
#: N5 = 1/2·(1−ξ²)(1−η), N6 = 1/2·(1+ξ)(1−η²), N7 = 1/2·(1−ξ²)(1+η), N8 = 1/2·(1−ξ)(1−η²) and the corner ones N1 = 1/4·(1−ξ)(1−η) − 1/2·(N8 + N5), etc.
Q5 = Simplify{1/2*(1-xi^2)*(1-eta)}
Q8 = Simplify{1/2*(1-xi)*(1-eta^2)}
Q1 = Simplify{1/4*(1-xi)*(1-eta) - 1/2*(Q8 + Q5)}
#: The coefficients a…e of side k are the same as in the DKT; at each node i the side leaving i (k = i+4) and the one arriving (k = i+3) enter, and for node 1 the arriving one is 8.
Hx1_dkq = Simplify{[1.5*(a5*Q5 - a8*Q8), b5*Q5 + b8*Q8, Q1 - c5*Q5 - c8*Q8]}

## 4 · DKQ with numbers (any quadrilateral)
X1 = 0 [m] 'node coordinate
Y1 = 0 [m] 'node coordinate
X2 = 2 [m] 'node coordinate
Y2 = 0.2 [m] 'node coordinate
X3 = 2.2 [m] 'node coordinate
Y3 = 1.8 [m] 'node coordinate
X4 = 0.1 [m] 'node coordinate
Y4 = 1.6 [m] 'node coordinate
XY = [X1, Y1; X2, Y2; X3, Y3; X4, Y4]
#: Sides 5 = 1-2, 6 = 2-3, 7 = 3-4, 8 = 4-1:
m5 = (X1-X2)^2 + (Y1-Y2)^2 [m²] 'square of the side length
m6 = (X2-X3)^2 + (Y2-Y3)^2 [m²] 'square of the side length
m7 = (X3-X4)^2 + (Y3-Y4)^2 [m²] 'square of the side length
m8 = (X4-X1)^2 + (Y4-Y1)^2 [m²] 'square of the side length
A5 = -(X1-X2)/m5 'side coefficient, in 1/m
A6 = -(X2-X3)/m6 'side coefficient, in 1/m
A7 = -(X3-X4)/m7 'side coefficient, in 1/m
A8 = -(X4-X1)/m8 'side coefficient, in 1/m
B5 = 0.75*(X1-X2)*(Y1-Y2)/m5
B6 = 0.75*(X2-X3)*(Y2-Y3)/m6
B7 = 0.75*(X3-X4)*(Y3-Y4)/m7
B8 = 0.75*(X4-X1)*(Y4-Y1)/m8
C5 = (0.25*(X1-X2)^2 - 0.5*(Y1-Y2)^2)/m5
C6 = (0.25*(X2-X3)^2 - 0.5*(Y2-Y3)^2)/m6
C7 = (0.25*(X3-X4)^2 - 0.5*(Y3-Y4)^2)/m7
C8 = (0.25*(X4-X1)^2 - 0.5*(Y4-Y1)^2)/m8
D5 = -(Y1-Y2)/m5 'side coefficient, in 1/m
D6 = -(Y2-Y3)/m6 'side coefficient, in 1/m
D7 = -(Y3-Y4)/m7 'side coefficient, in 1/m
D8 = -(Y4-Y1)/m8 'side coefficient, in 1/m
E5 = (0.25*(Y1-Y2)^2 - 0.5*(X1-X2)^2)/m5
E6 = (0.25*(Y2-Y3)^2 - 0.5*(X2-X3)^2)/m6
E7 = (0.25*(Y3-Y4)^2 - 0.5*(X3-X4)^2)/m7
E8 = (0.25*(Y4-Y1)^2 - 0.5*(X4-X1)^2)/m8
#: Rows Hx and Hy (12 columns) linear in the eight N or in their derivatives:
Hx_q(n1, n2, n3, n4, n5, n6, n7, n8) = [1.5*(A5*n5 - A8*n8); B5*n5 + B8*n8; n1 - C5*n5 - C8*n8; 1.5*(A6*n6 - A5*n5); B6*n6 + B5*n5; n2 - C6*n6 - C5*n5; 1.5*(A7*n7 - A6*n6); B7*n7 + B6*n6; n3 - C7*n7 - C6*n6; 1.5*(A8*n8 - A7*n7); B8*n8 + B7*n7; n4 - C8*n8 - C7*n7]
Hy_q(n1, n2, n3, n4, n5, n6, n7, n8) = [1.5*(D5*n5 - D8*n8); -n1 + E5*n5 + E8*n8; -B5*n5 - B8*n8; 1.5*(D6*n6 - D5*n5); -n2 + E6*n6 + E5*n5; -B6*n6 - B5*n5; 1.5*(D7*n7 - D6*n6); -n3 + E7*n7 + E6*n6; -B7*n7 - B6*n6; 1.5*(D8*n8 - D7*n7); -n4 + E8*n8 + E7*n7; -B8*n8 - B7*n7]
#: Derivatives of the eight N (ξ and η):
N5x(xi, eta) = -xi*(1-eta)
N5y(xi, eta) = -0.5*(1-xi^2)
N6x(xi, eta) = 0.5*(1-eta^2)
N6y(xi, eta) = -(1+xi)*eta
N7x(xi, eta) = -xi*(1+eta)
N7y(xi, eta) = 0.5*(1-xi^2)
N8x(xi, eta) = -0.5*(1-eta^2)
N8y(xi, eta) = -(1-xi)*eta
N1x(xi, eta) = -0.25*(1-eta) - 0.5*(N8x(xi, eta) + N5x(xi, eta))
N1y(xi, eta) = -0.25*(1-xi) - 0.5*(N8y(xi, eta) + N5y(xi, eta))
N2x(xi, eta) = 0.25*(1-eta) - 0.5*(N5x(xi, eta) + N6x(xi, eta))
N2y(xi, eta) = -0.25*(1+xi) - 0.5*(N5y(xi, eta) + N6y(xi, eta))
N3x(xi, eta) = 0.25*(1+eta) - 0.5*(N6x(xi, eta) + N7x(xi, eta))
N3y(xi, eta) = 0.25*(1+xi) - 0.5*(N6y(xi, eta) + N7y(xi, eta))
N4x(xi, eta) = -0.25*(1+eta) - 0.5*(N7x(xi, eta) + N8x(xi, eta))
N4y(xi, eta) = 0.25*(1-xi) - 0.5*(N7y(xi, eta) + N8y(xi, eta))
Hxs(xi, eta) = Hx_q(N1x(xi, eta), N2x(xi, eta), N3x(xi, eta), N4x(xi, eta), N5x(xi, eta), N6x(xi, eta), N7x(xi, eta), N8x(xi, eta))
Hxh(xi, eta) = Hx_q(N1y(xi, eta), N2y(xi, eta), N3y(xi, eta), N4y(xi, eta), N5y(xi, eta), N6y(xi, eta), N7y(xi, eta), N8y(xi, eta))
Hys(xi, eta) = Hy_q(N1x(xi, eta), N2x(xi, eta), N3x(xi, eta), N4x(xi, eta), N5x(xi, eta), N6x(xi, eta), N7x(xi, eta), N8x(xi, eta))
Hyh(xi, eta) = Hy_q(N1y(xi, eta), N2y(xi, eta), N3y(xi, eta), N4y(xi, eta), N5y(xi, eta), N6y(xi, eta), N7y(xi, eta), N8y(xi, eta))
#: Jacobian of the geometry (bilinear in the four corners) J = [p, q; r, s]:
jp(xi, eta) = 0.25*(-(1-eta)*X1 + (1-eta)*X2 + (1+eta)*X3 - (1+eta)*X4)
jq(xi, eta) = 0.25*(-(1-eta)*Y1 + (1-eta)*Y2 + (1+eta)*Y3 - (1+eta)*Y4)
jr(xi, eta) = 0.25*(-(1-xi)*X1 - (1+xi)*X2 + (1+xi)*X3 + (1-xi)*X4)
js(xi, eta) = 0.25*(-(1-xi)*Y1 - (1+xi)*Y2 + (1+xi)*Y3 + (1-xi)*Y4)
dj(xi, eta) = jp(xi, eta)*js(xi, eta) - jq(xi, eta)*jr(xi, eta)
#: Inverse of J: (1/det)·[s, −q; −r, p]. Derivatives with respect to x and y:
Hx_xq(xi, eta) = (js(xi, eta)*Hxs(xi, eta) - jq(xi, eta)*Hxh(xi, eta))/dj(xi, eta)
Hx_yq(xi, eta) = (-jr(xi, eta)*Hxs(xi, eta) + jp(xi, eta)*Hxh(xi, eta))/dj(xi, eta)
Hy_xq(xi, eta) = (js(xi, eta)*Hys(xi, eta) - jq(xi, eta)*Hyh(xi, eta))/dj(xi, eta)
Hy_yq(xi, eta) = (-jr(xi, eta)*Hys(xi, eta) + jp(xi, eta)*Hyh(xi, eta))/dj(xi, eta)
B1_q(xi, eta) = Hx_xq(xi, eta)
B2_q(xi, eta) = Hy_yq(xi, eta)
B3_q(xi, eta) = Hx_yq(xi, eta) + Hy_xq(xi, eta)
kb_q(xi, eta) = (Db(1, 1)*B1_q(xi, eta)*transpose(B1_q(xi, eta)) + Db(1, 2)*(B1_q(xi, eta)*transpose(B2_q(xi, eta)) + B2_q(xi, eta)*transpose(B1_q(xi, eta))) + Db(2, 2)*B2_q(xi, eta)*transpose(B2_q(xi, eta)) + Db(3, 3)*B3_q(xi, eta)*transpose(B3_q(xi, eta)))*dj(xi, eta)
#: Four Gauss points ±1/√3, weight 1:
g = 1/sqrt(3)
K_dkq = kb_q(-g, -g) + kb_q(g, -g) + kb_q(g, g) + kb_q(-g, g)
K_dkq_11 = K_dkq(1, 1) [kN/m] 'stiffness to w of node 1
K_dkq_22 = K_dkq(2, 2) [kN·m] 'stiffness to rotation of node 1
K_dkq_33 = K_dkq(3, 3) [kN·m] 'stiffness to rotation of node 1

## 5 · DKQ: patch test and rigid body
u_par_q = [X1^2/2; 0; -X1; X2^2/2; 0; -X2; X3^2/2; 0; -X3; X4^2/2; 0; -X4]
kxx_q = transpose(B1_q(0.3, -0.4))*u_par_q
kyy_q = transpose(B2_q(0.3, -0.4))*u_par_q
kxy_q = transpose(B3_q(0.3, -0.4))*u_par_q
kxx_q2 = transpose(B1_q(-0.7, 0.6))*u_par_q
#: Area of the quadrilateral by the shoelace formula:
Aq = 0.5*((X1*Y2 - X2*Y1) + (X2*Y3 - X3*Y2) + (X3*Y4 - X4*Y3) + (X4*Y1 - X1*Y4)) [m²] 'area
U_q = 0.5*transpose(u_par_q)*K_dkq*u_par_q [kN·m] 'strain energy
U_q_exacta = 0.5*Dpl*Aq [kN·m] 'strain energy
u_tras_q = [1; 0; 0; 1; 0; 0; 1; 0; 0; 1; 0; 0]
f_tras_q = K_dkq*u_tras_q
u_giro_q = [X1; 0; -1; X2; 0; -1; X3; 0; -1; X4; 0; -1]
f_giro_q = K_dkq*u_giro_q

## 6 · Comparison with SAP2000 (Plate-Thin)
#: Same quadrilateral as section 4 and the field w = x³/6 + x·y²/2 imposed as displacements at the four nodes (w, θx = x·y, θy = −(x²+y²)/2). With the 12 DOF restrained, the SAP2000 reaction is K·u. SAP2000 24: Plate-Thin area, no automatic mesh, units kN and m.
wf(x, y) = x^3/6 + x*y^2/2
u_s_q = [wf(X1, Y1); X1*Y1; -(X1^2+Y1^2)/2; wf(X2, Y2); X2*Y2; -(X2^2+Y2^2)/2; wf(X3, Y3); X3*Y3; -(X3^2+Y3^2)/2; wf(X4, Y4); X4*Y4; -(X4^2+Y4^2)/2]
f_q = K_dkq*u_s_q 'reactions: kN for w and kN·m for θx, θy
#: SAP2000 reactions (w, θx, θy of each node), copied from its output [SAP2000 OAPI]:
f_sap_q = [5503.829765; -751.808244; -316.323307; -4502.797955; -3135.217694; -4287.655588; 398.404973; 4136.870944; -3873.509261; -1399.436783; 2172.684486; 208.439509]
dif_q = f_q - f_sap_q
err_q = 100*sqrt(transpose(dif_q)*dif_q)/sqrt(transpose(f_sap_q)*f_sap_q) [%] 'relative difference
#: Moments at the node: B of the DKQ at the Gauss points and bilinear extrapolation to the nodes (that is how SAP2000 gives them).
Mxx_n(xi, eta) = Db(1, 1)*transpose(B1_q(xi, eta))*u_s_q + Db(1, 2)*transpose(B2_q(xi, eta))*u_s_q
Myy_n(xi, eta) = Db(1, 2)*transpose(B1_q(xi, eta))*u_s_q + Db(2, 2)*transpose(B2_q(xi, eta))*u_s_q
Mxy_n(xi, eta) = Db(3, 3)*transpose(B3_q(xi, eta))*u_s_q
Mxx_x(si, ti) = 0.25*((1-sqrt(3)*si)*(1-sqrt(3)*ti)*Mxx_n(-g, -g) + (1+sqrt(3)*si)*(1-sqrt(3)*ti)*Mxx_n(g, -g) + (1+sqrt(3)*si)*(1+sqrt(3)*ti)*Mxx_n(g, g) + (1-sqrt(3)*si)*(1+sqrt(3)*ti)*Mxx_n(-g, g))
Myy_x(si, ti) = 0.25*((1-sqrt(3)*si)*(1-sqrt(3)*ti)*Myy_n(-g, -g) + (1+sqrt(3)*si)*(1-sqrt(3)*ti)*Myy_n(g, -g) + (1+sqrt(3)*si)*(1+sqrt(3)*ti)*Myy_n(g, g) + (1-sqrt(3)*si)*(1+sqrt(3)*ti)*Myy_n(-g, g))
Mxy_x(si, ti) = 0.25*((1-sqrt(3)*si)*(1-sqrt(3)*ti)*Mxy_n(-g, -g) + (1+sqrt(3)*si)*(1-sqrt(3)*ti)*Mxy_n(g, -g) + (1+sqrt(3)*si)*(1+sqrt(3)*ti)*Mxy_n(g, g) + (1-sqrt(3)*si)*(1+sqrt(3)*ti)*Mxy_n(-g, g))
M_q1 = [Mxx_x(-1, -1), Myy_x(-1, -1), Mxy_x(-1, -1)] [kN·m/m] 'moments Mxx Myy Mxy of the node
M_q2 = [Mxx_x(1, -1), Myy_x(1, -1), Mxy_x(1, -1)] [kN·m/m] 'moments Mxx Myy Mxy of the node
M_q3 = [Mxx_x(1, 1), Myy_x(1, 1), Mxy_x(1, 1)] [kN·m/m] 'moments Mxx Myy Mxy of the node
M_q4 = [Mxx_x(-1, 1), Myy_x(-1, 1), Mxy_x(-1, 1)] [kN·m/m] 'moments Mxx Myy Mxy of the node
#: SAP2000 (M11, M22, M12) at nodes 1 to 4 [SAP2000 OAPI]. SAP2000 gives the moment with the opposite sign to this sheet (M11 = −Mxx, M22 = −Myy, M12 = −Mxy), so the sum of the two must give zero:
M_sap1 = [-221.352005, -161.569777, 773.527219] [kN·m/m] 'moments Mxx Myy Mxy of the node
M_sap2 = [4990.463335, 4961.900813, 938.655492] [kN·m/m] 'moments Mxx Myy Mxy of the node
M_sap3 = [5922.245888, 5968.54638, 2329.722025] [kN·m/m] 'moments Mxx Myy Mxy of the node
M_sap4 = [417.801978, 379.808169, 2149.254494] [kN·m/m] 'moments Mxx Myy Mxy of the node
n3(v) = sqrt(v(1)^2 + v(2)^2 + v(3)^2)
err_M_q = 100*sqrt(n3(M_q1 + M_sap1)^2 + n3(M_q2 + M_sap2)^2 + n3(M_q3 + M_sap3)^2 + n3(M_q4 + M_sap4)^2)/sqrt(n3(M_sap1)^2 + n3(M_sap2)^2 + n3(M_sap3)^2 + n3(M_sap4)^2) [%] 'relative difference

#: ETABS 22 (OAPI, Shell-Thin slab, OBJMESHTYPE NOAUTOMESH so it does not remesh; its membrane DOF remain zero, so they do not affect the bending). Same reactions and same moments [ETABS OAPI]:
f_etabs_q = [5503.829972; -751.807911; -316.323343; -4502.796709; -3135.216921; -4287.655684; 398.403504; 4136.871793; -3873.509643; -1399.436767; 2172.684901; 208.439283]
err_q_etabs = 100*sqrt(transpose(f_q - f_etabs_q)*(f_q - f_etabs_q))/sqrt(transpose(f_etabs_q)*f_etabs_q) [%] 'relative difference
M_etabs1 = [-221.351797, -161.569725, 773.527096] [kN·m/m] 'moments Mxx Myy Mxy of the node
M_etabs2 = [4990.462902, 4961.899605, 938.655356] [kN·m/m] 'moments Mxx Myy Mxy of the node
M_etabs3 = [5922.24661, 5968.547651, 2329.721915] [kN·m/m] 'moments Mxx Myy Mxy of the node
M_etabs4 = [417.801466, 379.808048, 2149.254371] [kN·m/m] 'moments Mxx Myy Mxy of the node
err_M_q_etabs = 100*sqrt(n3(M_q1 + M_etabs1)^2 + n3(M_q2 + M_etabs2)^2 + n3(M_q3 + M_etabs3)^2 + n3(M_q4 + M_etabs4)^2)/sqrt(n3(M_etabs1)^2 + n3(M_etabs2)^2 + n3(M_etabs3)^2 + n3(M_etabs4)^2) [%] 'relative difference

## 7 · Maps on the SAP2000 and ETABS quadrilateral (to compare with the mouse)
#: The same quadrilateral (0,0), (2,0.2), (2.2,1.8), (0.1,1.6) and the same field, drawn on the reference square ξ, η (x = ξ, y = η). It is the field SAP2000 gives: values at the 4 Gauss points extrapolated bilinearly. Move the mouse over the corners: (−1,−1), (1,−1), (1,1), (−1,1) are nodes 1 to 4 and must read Mxx = −M11 of SAP2000 and ETABS (221.35, −4990.46, −5922.25, −417.80 with the SAP sign).
Mxx_p(x, y) = Mxx_x(x, y)
Myy_p(x, y) = Myy_x(x, y)
Mxy_p(x, y) = Mxy_x(x, y)
#: Mxx (kN·m/m):
#map(Mxx_p(x, y), [-1 1], [-1 1])
#: Myy (kN·m/m):
#map(Myy_p(x, y), [-1 1], [-1 1])
#: Mxy (kN·m/m):
#map(Mxy_p(x, y), [-1 1], [-1 1])

## 8 · Maps of Mxx, Myy and Mxy (move the mouse and read the value)
#: A rectangular DKQ element of 4 × 3 with the field w = x³/6 + x·y²/2, whose nodal rotations are θx = x·y and θy = −(x² + y²)/2. The moments come from M = Db·κ with the B of the DKQ at each point (x, y) of the element: ξ = x/2 − 1, η = 2·y/3 − 1.
X1 = 0 [m] 'node coordinate
Y1 = 0 [m] 'node coordinate
X2 = 4 [m] 'node coordinate
Y2 = 0 [m] 'node coordinate
X3 = 4 [m] 'node coordinate
Y3 = 3 [m] 'node coordinate
X4 = 0 [m] 'node coordinate
Y4 = 3 [m] 'node coordinate
m5 = (X1-X2)^2 + (Y1-Y2)^2 [m²] 'square of the side length
m6 = (X2-X3)^2 + (Y2-Y3)^2 [m²] 'square of the side length
m7 = (X3-X4)^2 + (Y3-Y4)^2 [m²] 'square of the side length
m8 = (X4-X1)^2 + (Y4-Y1)^2 [m²] 'square of the side length
A5 = -(X1-X2)/m5 'side coefficient, in 1/m
A6 = -(X2-X3)/m6 'side coefficient, in 1/m
A7 = -(X3-X4)/m7 'side coefficient, in 1/m
A8 = -(X4-X1)/m8 'side coefficient, in 1/m
B5 = 0.75*(X1-X2)*(Y1-Y2)/m5
B6 = 0.75*(X2-X3)*(Y2-Y3)/m6
B7 = 0.75*(X3-X4)*(Y3-Y4)/m7
B8 = 0.75*(X4-X1)*(Y4-Y1)/m8
C5 = (0.25*(X1-X2)^2 - 0.5*(Y1-Y2)^2)/m5
C6 = (0.25*(X2-X3)^2 - 0.5*(Y2-Y3)^2)/m6
C7 = (0.25*(X3-X4)^2 - 0.5*(Y3-Y4)^2)/m7
C8 = (0.25*(X4-X1)^2 - 0.5*(Y4-Y1)^2)/m8
D5 = -(Y1-Y2)/m5 'side coefficient, in 1/m
D6 = -(Y2-Y3)/m6 'side coefficient, in 1/m
D7 = -(Y3-Y4)/m7 'side coefficient, in 1/m
D8 = -(Y4-Y1)/m8 'side coefficient, in 1/m
E5 = (0.25*(Y1-Y2)^2 - 0.5*(X1-X2)^2)/m5
E6 = (0.25*(Y2-Y3)^2 - 0.5*(X2-X3)^2)/m6
E7 = (0.25*(Y3-Y4)^2 - 0.5*(X3-X4)^2)/m7
E8 = (0.25*(Y4-Y1)^2 - 0.5*(X4-X1)^2)/m8
uw = [0; 0; 0; 64/6; 0; -8; 64/6+0.5*4*9; 12; -(16+9)/2; 0.5*0*9; 0; -9/2]
#: κxx, κyy, κxy at the point (x, y):
k1_q(x, y) = transpose(B1_q(x/2-1, 2*y/3-1))*uw
k2_q(x, y) = transpose(B2_q(x/2-1, 2*y/3-1))*uw
k3_q(x, y) = transpose(B3_q(x/2-1, 2*y/3-1))*uw
#: Moments per unit width (kN·m/m):
Mxx_q(x, y) = Db(1, 1)*k1_q(x, y) + Db(1, 2)*k2_q(x, y)
Myy_q(x, y) = Db(1, 2)*k1_q(x, y) + Db(2, 2)*k2_q(x, y)
Mxy_q(x, y) = Db(3, 3)*k3_q(x, y)
#: At the center (2, 1.5) and the exact value of the continuous plate (κxx = κyy = −x, κxy = −2·y):
Mxx_c = Mxx_q(2, 1.5)
Mxx_ex = -Dpl*(1+nu)*2
Mxy_c = Mxy_q(2, 1.5)
Mxy_ex = -Dpl*(1-nu)*1.5
#: With a single element the center matches the exact value (above); toward the edges the DKQ departs from it, especially in Mxy (its range goes from −1294 to −3883, the continuum would go from 0 to −5177). With more elements the map converges.
#: Mxx (kN·m/m):
#map(Mxx_q(x, y), [0 4], [0 3])
#: Myy (kN·m/m):
#map(Myy_q(x, y), [0 4], [0 3])
#: Mxy (kN·m/m):
#map(Mxy_q(x, y), [0 4], [0 3])

## The labels
