# CSI triangle thick plate (Shell-Thick) · closed form, K, moments, shear and maps against SAP2000 and ETABS
#numerico
#: The Shell-Thick triangle of SAP2000 24 and ETABS 22 is neither the CS-DSG3 nor any of the published ones: it was obtained by measuring the ETABS binary (emulation of the kernel code) and checked against both programs. Three degrees of freedom per node: w, θx = ∂w/∂y, θy = −∂w/∂x. Here it is assembled whole, first with formulas and then with numbers: 9×9 K, reactions, moments at the nodes, shear V13 and V23 and the Mxx, Myy and Mxy maps with the mouse. Bending only: the membrane and the drilling are another element.

## 0 · From the differential equation to the weak form (Reissner-Mindlin)
#: Reissner-Mindlin thick plate. The displacement w and the rotations θ are independent unknowns. Equilibrium: ∇·M − Q = 0 and ∇·Q = −q, with the moment M = Db·κ in kN·m/m and the shear Q = (5/6)·G·t·(∇w − θ) in kN/m.
#: Boundary conditions. Essential: fixed w = 0 and θ = 0; supported w = 0. Natural: supported Mn = 0; free Mn = 0, Mns = 0 and Qn = 0.
#: Test function. It is multiplied by δw and by δθ and integrated over the area A; integrating by parts leaves the weak form with bending and shear: ∫ δκᵀ·Db·κ dA + ∫ δγᵀ·Ds·γ dA = ∫ δw·q dA, with the curvatures κ (derivatives of θ), the distortion γ = ∇w − θ and Ds = (5/6)·G·t in kN/m.
#: Discretization. w and θ are approximated with shape functions; in this triangle there are 15 degrees of freedom that are condensed to 9. The stiffness is K = ∫ Bbᵀ·Db·Bb dA + ∫ Bsᵀ·Ds·Bs dA. The shear is what distinguishes this plate from the thin one.

## 1 · The recipe, in words (why it is so)
#: The rotations are not linear: besides the three nodal Lᵢ, each side carries its own function 4·La·Lb (two components, θx and θy). They are six internal degrees of freedom that are eliminated by condensation. There is no bubble. With that the rotation can curve inside the element.
#: The shear of each side comes from Wilson: gk = (wb − wa)/L − (sa/2)(θx_a + θx_b) + (ca/2)(θy_a + θy_b) − (2/3)·sa·θx_k + (2/3)·ca·θy_k, with ca, sa the cosine and sine of the side. The shear inside the triangle is taken CONSTANT: (γr, γs) = C·(g1·L1, g2·L2, g3·L3) with C = [2/3 −1/3 −1/3; 1/3 1/3 −2/3], and γ = J⁻¹·(γr, γs). That is why V13 and V23 have the same value at the three nodes.
#: Bending is integrated with the three midpoints of the sides (weight A/3). In the six side columns the mean of the three curvature rows is subtracted (B-bar): this way a constant curvature field does not excite the internal modes. A penalty 1000·tr(Db)·(div θ)² is added that ties the side rotations to the rotation field.

## 2 · Data
Em = 24850000 [kN/m²] 'modulus of elasticity of the concrete
nu = 0.2 'Poisson's ratio (dimensionless)
t = 0.1 [m] 'plate thickness
Dpl = Em*t^3/(12*(1-nu^2)) [kN·m] 'flexural rigidity of the plate
Db = Dpl*[1, nu, 0; nu, 1, 0; 0, 0, (1-nu)/2] [kN·m] 'bending behavior matrix
Gm = Em/(2*(1+nu)) [kN/m²] 'shear modulus
Ds = 5/6*Gm*t [kN/m] 'shear rigidity (5/6·G·t)
pen = 1000*(Db(1, 1) + Db(2, 2) + Db(3, 3)) [kN·m] 'rotation penalty

## 3 · The triangle (the same as in the DKT sheet)
x1 = 0 [m] 'node coordinate
y1 = 0 [m] 'node coordinate
x2 = 2 [m] 'node coordinate
y2 = 0.5 [m] 'node coordinate
x3 = 0.5 [m] 'node coordinate
y3 = 1.5 [m] 'node coordinate
Jt = [x2-x1, y2-y1; x3-x1, y3-y1]
A2 = det(Jt) [m²] 'area
At = A2/2 [m²] 'area
Ji = inv(Jt)
#: Gradients of the area coordinates L1, L2, L3 (constant in the triangle):
g1x = (y2-y3)/A2
g1y = (x3-x2)/A2
g2x = (y3-y1)/A2
g2y = (x1-x3)/A2
g3x = (y1-y2)/A2
g3y = (x2-x1)/A2
#: Sides 1 (nodes 1-2), 2 (nodes 2-3) and 3 (nodes 3-1): length, cosine and sine.
L1 = sqrt((x2-x1)^2 + (y2-y1)^2) [m] 'side length
L2 = sqrt((x3-x2)^2 + (y3-y2)^2) [m] 'side length
L3 = sqrt((x1-x3)^2 + (y1-y3)^2) [m] 'side length
c1 = (x2-x1)/L1
s1 = (y2-y1)/L1
c2 = (x3-x2)/L2
s2 = (y3-y2)/L2
c3 = (x1-x3)/L3
s3 = (y1-y3)/L3

## 4 · Curvatures: nodal rotations + side rotations (B-bar)
#: Order of the 15 degrees of freedom: [w1 θx1 θy1, w2 θx2 θy2, w3 θx3 θy3, side1 (θx θy), side2 (θx θy), side3 (θx θy)]. Derivative of the side function 4·La·Lb with respect to x and y, minus its mean value at the three midpoints (B-bar), with (a, b, c) = (L1, L2, L3) of the point:
sx1(a, b, c) = 4*(a*g2x + b*g1x) - 4*(g2x + g1x)/3
sx2(a, b, c) = 4*(b*g3x + c*g2x) - 4*(g3x + g2x)/3
sx3(a, b, c) = 4*(c*g1x + a*g3x) - 4*(g1x + g3x)/3
sy1(a, b, c) = 4*(a*g2y + b*g1y) - 4*(g2y + g1y)/3
sy2(a, b, c) = 4*(b*g3y + c*g2y) - 4*(g3y + g2y)/3
sy3(a, b, c) = 4*(c*g1y + a*g3y) - 4*(g1y + g3y)/3
#: The three curvature rows (κxx = βx,x, κyy = βy,y, κxy = βx,y + βy,x) and the divergence of the rotation (without subtracting the mean) for the penalty:
kxx_r(a, b, c) = [0; 0; g1x; 0; 0; g2x; 0; 0; g3x; 0; sx1(a, b, c); 0; sx2(a, b, c); 0; sx3(a, b, c)]
kyy_r(a, b, c) = [0; -g1y; 0; 0; -g2y; 0; 0; -g3y; 0; -sy1(a, b, c); 0; -sy2(a, b, c); 0; -sy3(a, b, c); 0]
kxy_r(a, b, c) = [0; -g1x; g1y; 0; -g2x; g2y; 0; -g3x; g3y; -sx1(a, b, c); sy1(a, b, c); -sx2(a, b, c); sy2(a, b, c); -sx3(a, b, c); sy3(a, b, c)]
dv_r(a, b, c) = [0; g1x; g1y; 0; g2x; g2y; 0; g3x; g3y; sx1(a, b, c) + 4*(g2x + g1x)/3; sy1(a, b, c) + 4*(g2y + g1y)/3; sx2(a, b, c) + 4*(g3x + g2x)/3; sy2(a, b, c) + 4*(g3y + g2y)/3; sx3(a, b, c) + 4*(g1x + g3x)/3; sy3(a, b, c) + 4*(g1y + g3y)/3]
#: BᵀDB at a point and the penalty:
kb_c(a, b, c) = Db(1, 1)*kxx_r(a, b, c)*transpose(kxx_r(a, b, c)) + Db(1, 2)*(kxx_r(a, b, c)*transpose(kyy_r(a, b, c)) + kyy_r(a, b, c)*transpose(kxx_r(a, b, c))) + Db(2, 2)*kyy_r(a, b, c)*transpose(kyy_r(a, b, c)) + Db(3, 3)*kxy_r(a, b, c)*transpose(kxy_r(a, b, c)) + pen*dv_r(a, b, c)*transpose(dv_r(a, b, c))

## 5 · Side shear (Wilson) and constant shear
G1 = [-1/L1; -s1/2; c1/2; 1/L1; -s1/2; c1/2; 0; 0; 0; -2/3*s1; 2/3*c1; 0; 0; 0; 0]
G2 = [0; 0; 0; -1/L2; -s2/2; c2/2; 1/L2; -s2/2; c2/2; 0; 0; -2/3*s2; 2/3*c2; 0; 0]
G3 = [1/L3; -s3/2; c3/2; 0; 0; 0; -1/L3; -s3/2; c3/2; 0; 0; 0; 0; -2/3*s3; 2/3*c3]
#: γr and γs (covariant) and γx, γy (Cartesian) as rows over the 15 degrees of freedom:
gr = 2/3*L1*G1 - 1/3*L2*G2 - 1/3*L3*G3
gs = 1/3*L1*G1 + 1/3*L2*G2 - 2/3*L3*G3
Bsx = Ji(1, 1)*gr + Ji(1, 2)*gs
Bsy = Ji(2, 1)*gr + Ji(2, 2)*gs

## 6 · 15×15 stiffness and condensation to 9×9
#: Three side midpoints, weight A/3 each. The shear is constant, so its contribution is A·Bsᵀ·Ds·Bs:
K15 = At/3*(kb_c(0.5, 0.5, 0) + kb_c(0, 0.5, 0.5) + kb_c(0.5, 0, 0.5)) + At*Ds*(Bsx*transpose(Bsx) + Bsy*transpose(Bsy))
#: The 9 node degrees of freedom (Ee) are separated from the 6 internal ones (Ei) and the internal ones are condensed: Kt = Knn − KnI·KII⁻¹·KIn. The six pivots are nonzero in this triangle (the kernel skips null pivots in other geometries).
Ee = submatrix(identity(15), 1, 9, 1, 15)
Ei = submatrix(identity(15), 10, 15, 1, 15)
Knn = Ee*K15*transpose(Ee)
KnI = Ee*K15*transpose(Ei)
KII = Ei*K15*transpose(Ei)
Kt = Knn - KnI*inv(KII)*transpose(KnI)
Kt_11 = Kt(1, 1) [kN/m] 'stiffness to w of node 1
Kt_22 = Kt(2, 2) [kN·m] 'stiffness to rotation of node 1
Kt_33 = Kt(3, 3) [kN·m] 'stiffness to rotation of node 1
#: Rigid bodies: vertical translation and rigid rotation (w = x) must not give force.
u_tras = [1; 0; 0; 1; 0; 0; 1; 0; 0]
f_tras = Kt*u_tras
u_giro = [x1; 0; -1; x2; 0; -1; x3; 0; -1]
f_giro = Kt*u_giro

## 7 · Comparison with SAP2000 and ETABS (reactions)
#: The field w = x³/6 + x·y²/2 imposed as displacements at the three nodes (w, θx = x·y, θy = −(x²+y²)/2), t = 0.1. With the 9 degrees of freedom restrained, the reaction is K·u. SAP2000 24: Shell-Thick area; ETABS 22: Shell-Thick slab with OBJMESHTYPE NOAUTOMESH (otherwise ETABS remeshes the triangle into four). Units kN and m.
wf(x, y) = x^3/6 + x*y^2/2
u_s = [wf(x1, y1); x1*y1; -(x1^2+y1^2)/2; wf(x2, y2); x2*y2; -(x2^2+y2^2)/2; wf(x3, y3); x3*y3; -(x3^2+y3^2)/2]
f_k = Kt*u_s 'reactions: kN for w and kN·m for θx, θy
f_sap = [1439.386675; -528.210803; 852.730577; -1675.224363; -57.306496; -2838.572066; 235.837688; 1069.372950; -1246.688392]
f_etabs = [1439.386723; -528.210743; 852.730602; -1675.224148; -57.306426; -2838.571893; 235.837425; 1069.373105; -1246.688292]
err_f_sap = 100*sqrt(transpose(f_k - f_sap)*(f_k - f_sap))/sqrt(transpose(f_sap)*f_sap) [%] 'relative difference
err_f_etabs = 100*sqrt(transpose(f_k - f_etabs)*(f_k - f_etabs))/sqrt(transpose(f_etabs)*f_etabs) [%] 'relative difference

## 8 · Moments at the nodes and shear V13, V23
#: The six internal rotations are recovered from the nodal ones: u_int = −KII⁻¹·KIn·u. With them, the curvature at each node (same B-bar of the stiffness) gives the moment Db·κ. SAP2000 and ETABS give the moment with the opposite sign to this sheet (M11 = −Mxx, M22 = −Myy, M12 = −Mxy), so the sum of the two must give zero.
u_int = -inv(KII)*transpose(KnI)*u_s
u15 = transpose(Ee)*u_s + transpose(Ei)*u_int
Mxx_v(a, b, c) = Db(1, 1)*transpose(kxx_r(a, b, c))*u15 + Db(1, 2)*transpose(kyy_r(a, b, c))*u15
Myy_v(a, b, c) = Db(1, 2)*transpose(kxx_r(a, b, c))*u15 + Db(2, 2)*transpose(kyy_r(a, b, c))*u15
Mxy_v(a, b, c) = Db(3, 3)*transpose(kxy_r(a, b, c))*u15
M_k1 = [Mxx_v(1, 0, 0), Myy_v(1, 0, 0), Mxy_v(1, 0, 0)] [kN·m/m] 'moments Mxx Myy Mxy of the node
M_k2 = [Mxx_v(0, 1, 0), Myy_v(0, 1, 0), Mxy_v(0, 1, 0)] [kN·m/m] 'moments Mxx Myy Mxy of the node
M_k3 = [Mxx_v(0, 0, 1), Myy_v(0, 0, 1), Mxy_v(0, 0, 1)] [kN·m/m] 'moments Mxx Myy Mxy of the node
#: SAP2000 (M11, M22, M12) at nodes 1 to 3 [SAP2000 OAPI]:
M_sap1 = [-73.268026, -923.355267, 494.199195] [kN·m/m] 'moments Mxx Myy Mxy of the node
M_sap2 = [5627.313614, 3070.332005, 166.099293] [kN·m/m] 'moments Mxx Myy Mxy of the node
M_sap3 = [946.723825, 1412.268053, 1751.751702] [kN·m/m] 'moments Mxx Myy Mxy of the node
n3(v) = sqrt(v(1)^2 + v(2)^2 + v(3)^2)
err_M_sap = 100*sqrt(n3(M_k1 + M_sap1)^2 + n3(M_k2 + M_sap2)^2 + n3(M_k3 + M_sap3)^2)/sqrt(n3(M_sap1)^2 + n3(M_sap2)^2 + n3(M_sap3)^2) [%] 'relative difference
#: ETABS 22 (OAPI), same nodes:
M_etabs1 = [-73.267887, -923.355369, 494.199137] [kN·m/m] 'moments Mxx Myy Mxy of the node
M_etabs2 = [5627.313203, 3070.331803, 166.099431] [kN·m/m] 'moments Mxx Myy Mxy of the node
M_etabs3 = [946.724097, 1412.268357, 1751.751621] [kN·m/m] 'moments Mxx Myy Mxy of the node
err_M_etabs = 100*sqrt(n3(M_k1 + M_etabs1)^2 + n3(M_k2 + M_etabs2)^2 + n3(M_k3 + M_etabs3)^2)/sqrt(n3(M_etabs1)^2 + n3(M_etabs2)^2 + n3(M_etabs3)^2) [%] 'relative difference
#: Constant shear V = Ds·γ (the same value at the three nodes):
V13_k = Ds*transpose(Bsx)*u15 [kN/m] 'transverse shear
V23_k = Ds*transpose(Bsy)*u15 [kN/m] 'transverse shear
#: SAP2000: V13 = −2350.930823, V23 = −351.895018. ETABS: V13 = −2350.930606, V23 = −351.895227.
err_V_sap = 100*sqrt((V13_k + 2350.930823)^2 + (V23_k + 351.895018)^2)/sqrt(2350.930823^2 + 351.895018^2) [%] 'relative difference
err_V_etabs = 100*sqrt((V13_k + 2350.930606)^2 + (V23_k + 351.895227)^2)/sqrt(2350.930606^2 + 351.895227^2) [%] 'relative difference

## 9 · Maps on the SAP2000 and ETABS triangle (to compare with the mouse)
#: The same triangle (0,0), (2,0.5), (0.5,1.5) and the same field. We go from x, y to area coordinates with the inverse Jacobian: L2 = (x−x1)·J11 + (y−y1)·J21, L3 = (x−x1)·J12 + (y−y1)·J22, L1 = 1 − L2 − L3. It only holds inside the triangle. Pass the mouse over the nodes: at (0,0), (2,0.5) and (0.5,1.5) it must read Mxx = −M11 of SAP2000 and ETABS (73.27, −5627.31 and −946.72: the opposite of the SAP sign). Inside the element the field is that of the curvature of the rotations with B-bar; the nodes are what CSI reports.
xi_p(x, y) = (x - x1)*Ji(1, 1) + (y - y1)*Ji(2, 1)
eta_p(x, y) = (x - x1)*Ji(1, 2) + (y - y1)*Ji(2, 2)
Mxx_p(x, y) = Mxx_v(1 - xi_p(x, y) - eta_p(x, y), xi_p(x, y), eta_p(x, y))
Myy_p(x, y) = Myy_v(1 - xi_p(x, y) - eta_p(x, y), xi_p(x, y), eta_p(x, y))
Mxy_p(x, y) = Mxy_v(1 - xi_p(x, y) - eta_p(x, y), xi_p(x, y), eta_p(x, y))
#: Mxx (kN·m/m):
#map(Mxx_p(x, y), [0 2], [0 1.5])
#: Myy (kN·m/m):
#map(Myy_p(x, y), [0 2], [0 1.5])
#: Mxy (kN·m/m):
#map(Mxy_p(x, y), [0 2], [0 1.5])

## Labels
