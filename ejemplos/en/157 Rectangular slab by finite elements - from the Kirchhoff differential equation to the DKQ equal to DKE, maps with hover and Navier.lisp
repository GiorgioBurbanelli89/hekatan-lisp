# Rectangular slab by finite elements: from the Kirchhoff differential equation to the Batoz and Tahar DKQ (= Wilson DKE)
#numerico
#: **What is computed.** The slab of the Calcpad «Rectangular Slab FEA» example: 6 × 4 m, 10 cm, supported along the whole edge and with 10 kN/m². It starts from the **differential equation** of the thin plate and its **boundary conditions**, goes to the **weak form** and from there to the 4-node thin plate finite element.
#: **Who is who.** DKT = triangle of Batoz, Bathe and Ho (1980). DKQ = quadrilateral of Batoz and Tahar (1982), IJNME 18, 1655-1677. DKE = Wilson's «Discrete Kirchhoff Element», *Three-Dimensional Static and Dynamic Analysis of Structures*, ch. 8, §8.8, eq. (8.21). The DKQ and the DKE are **the same element** written in two ways: with the 12 × 12 K of both assembled, they agree to 7.5·10⁻¹⁶ (square, rectangle, irregular quadrilateral and trapezoid, ν from 0 to 0.45; `losa_rectangular/dke_wilson_vs_dkq.py`). It is the Shell-Thin of SAP2000 and ETABS.
#: **Units:** kN and m. Moments in kN·m/m. **CSI sign:** M > 0 = tension at the bottom (positive span moment).

## 1 · The problem
a = 6 [m] 'slab length, in x
b = 4 [m] 'slab width, in y (short span)
t = 0.1 [m] 'thickness
q = 10 [kN/m²] 'uniform downward load
E = 35000000 [kN/m²] 'modulus of elasticity (35 000 MPa)
ν = 0.15 'Poisson's ratio (unitless)
#: **How to read the plan.** The thick rectangle is the slab; the hatched edge is the simple support on the four sides (w = 0, rotations free). The origin is the bottom-left corner. The load q covers the whole plan.
#dibujo("Plan: 6 × 4 m slab supported on the four edges", ud = m, escala = auto, cotas = m, alto = 140)
#  rect(-0.12, -0.12, 6.24, 0.24, "denso")
#  rect(-0.12, 3.88, 6.24, 0.24, "denso")
#  rect(-0.12, 0.12, 0.24, 3.76, "denso")
#  rect(5.88, 0.12, 0.24, 3.76, "denso")
#  rect(0, 0, 6, 4, "gruesa")
#  flecha(0.4, 0.4, 1.2, 0.4, "rojo")
#  flecha(0.4, 0.4, 0.4, 1.2, "rojo")
#  texto(1.3, 0.4, "x", 2.8, "i", estilo = "rojo")
#  texto(0.4, 1.35, "y", 2.8, "c", estilo = "rojo")
#  texto(3.0, 2.3, "q = 10 kN/m²", 2.8, "c", estilo = "azul")
#  texto(3.0, 1.7, "t = 0.10 m", 2.6, "c")
#  cota(0, -0.5, 6, -0.5, -0.05, "6.00")
#  cota(-1.0, 0, -1.0, 4, 0.05, "4.00")
#fin
#dibujo("Section along the short span: 10 cm slab with the load", ud = m, escala = auto, cotas = m, alto = 100)
#  seccion(0, 0, 4.0, 0.10)
#  rect(-0.12, -0.25, 0.24, 0.35, "gruesa")
#  rect(3.88, -0.25, 0.24, 0.35, "gruesa")
#  carga(0, 0.10, 4.0, 0.10, 0.3, 0.3, "q = 10 kN/m²", "azul", n = 11)
#  cota(0, -0.45, 4.0, -0.45, -0.05, "4.00")
#fin

## 2 · The Kirchhoff differential equation
#: **Kirchhoff hypothesis:** the normal to the mid-plane remains normal after bending. That is why the rotations are the slopes of w and the curvatures are second derivatives: κx = −w,xx, κy = −w,yy, κxy = −2·w,xy.
#: **Flexural rigidity:**
D_s = Simplify{E*t^3/(12*(1-nu^2))}
#: **Moments per unit width** (Hooke's law integrated over the thickness): Mx = D·(κx + ν·κy), My = D·(ν·κx + κy), Mxy = D·(1 − ν)/2·κxy.
#: **Equilibrium** of a piece dx·dy: shears Qx = Mx,x + Mxy,y, Qy = Mxy,x + My,y and vertical Qx,x + Qy,y + q = 0. Substituting the moments gives the fourth-order equation:
#: D·(w,xxxx + 2·w,xxyy + w,yyyy) = q,  that is,  D·∇⁴w = q.
#: Example: one Navier term w = W·sin(m·π·x/a)·sin(n·π·y/b). Its curvatures, differentiating twice:
k_xx = Simplify{-Diff{Diff{W*sin(m*pi*x/a)*sin(n*pi*y/b) @ x} @ x}}
k_yy = Simplify{-Diff{Diff{W*sin(m*pi*x/a)*sin(n*pi*y/b) @ y} @ y}}
#: Each term satisfies D·∇⁴w = q_mn with W_mn = q_mn/(D·π⁴·(m²/a² + n²/b²)²) and, for uniform load, q_mn = 16·q/(π²·m·n) (m, n odd).

## 3 · Boundary conditions
#: On each edge TWO conditions are given (the equation is fourth order). **Essential** ones (imposed on the displacement) and **natural** ones (which come out by themselves from the weak form):
#: · **Simply supported:** w = 0 (essential) and Mn = 0 (natural). It is the case of this slab.
#: · **Fixed:** w = 0 and ∂w/∂n = 0 (both essential).
#: · **Free:** Mn = 0 and Vn = Qn + ∂Mns/∂s = 0 (both natural).
#: The Navier sine is zero at x = 0 and x = a, and so is its second derivative: it satisfies w = 0 and Mx = 0 at the edges, which is why it is the exact solution of the simply supported plate.

## 4 · Weak form (summary of the video «From the differential equation to the weak form»)
#: D·∇⁴w = q is multiplied by a virtual displacement δw that satisfies the essential conditions and integrated by parts twice. The boundary terms vanish (essential ones because δw = 0, natural ones because Mn and Vn are data) and the **virtual work** remains:
#: ∫ δκᵀ·D_b·κ dA = ∫ δw·q dA.  Only second derivatives of w appear: it is enough for w and its rotations to be continuous.

## 5 · The element: discrete Kirchhoff (Batoz-Tahar DKQ = Wilson DKE)
#: Mesh of the Calcpad sheet: 6 × 4 elements of 1 × 1 m.
n_x = 6 'elements in x
n_y = 4 'elements in y
h_x = a/n_x [m] 'element side in x
h_y = b/n_y [m] 'element side in y
#: **The idea.** The rotations βx, βy are interpolated with the 8 quadratic functions (4 corners + 4 midpoints). The midpoint rotations are not degrees of freedom: they are eliminated by imposing Kirchhoff **only on the sides**. Along side ij of length L, w is a Hermite cubic; its slope at the midpoint is:
w_lado = Simplify{(1 - 3*s^2/L^2 + 2*s^3/L^3)*w_i + (s - 2*s^2/L + s^3/L^2)*p_i + (3*s^2/L^2 - 2*s^3/L^3)*w_j + (-s^2/L + s^3/L^2)*p_j}
#: Differentiating and evaluating at s = L/2: β_s,mid = 3/(2·L)·(w_j − w_i) − ¼·(β_s,i + β_s,j). Subtracting the linear part ½·(β_s,i + β_s,j) gives Wilson's eq. (8.21):
dpsi = Simplify{3/(2*L)*(w_j - w_i) - 3/4*(p_i + p_j)}
#: The rotation normal to the side is taken linear. That leaves 3 degrees of freedom per node (w, θx = ∂w/∂y, θy = −∂w/∂x) and 12 per element.
#: Coordinates of the typical element (all are equal):
X1 = 0 [m] 'x of node 1
Y1 = 0 [m] 'y of node 1
X2 = h_x [m] 'x of node 2
Y2 = 0 [m] 'y of node 2
X3 = h_x [m] 'x of node 3
Y3 = h_y [m] 'y of node 3
X4 = 0 [m] 'x of node 4
Y4 = h_y [m] 'y of node 4
#hide
m5 = (X1-X2)^2 + (Y1-Y2)^2
m6 = (X2-X3)^2 + (Y2-Y3)^2
m7 = (X3-X4)^2 + (Y3-Y4)^2
m8 = (X4-X1)^2 + (Y4-Y1)^2
A5 = -(X1-X2)/m5
A6 = -(X2-X3)/m6
A7 = -(X3-X4)/m7
A8 = -(X4-X1)/m8
B5 = 0.75*(X1-X2)*(Y1-Y2)/m5
B6 = 0.75*(X2-X3)*(Y2-Y3)/m6
B7 = 0.75*(X3-X4)*(Y3-Y4)/m7
B8 = 0.75*(X4-X1)*(Y4-Y1)/m8
C5 = (0.25*(X1-X2)^2 - 0.5*(Y1-Y2)^2)/m5
C6 = (0.25*(X2-X3)^2 - 0.5*(Y2-Y3)^2)/m6
C7 = (0.25*(X3-X4)^2 - 0.5*(Y3-Y4)^2)/m7
C8 = (0.25*(X4-X1)^2 - 0.5*(Y4-Y1)^2)/m8
D5 = -(Y1-Y2)/m5
D6 = -(Y2-Y3)/m6
D7 = -(Y3-Y4)/m7
D8 = -(Y4-Y1)/m8
E5 = (0.25*(Y1-Y2)^2 - 0.5*(X1-X2)^2)/m5
E6 = (0.25*(Y2-Y3)^2 - 0.5*(X2-X3)^2)/m6
E7 = (0.25*(Y3-Y4)^2 - 0.5*(X3-X4)^2)/m7
E8 = (0.25*(Y4-Y1)^2 - 0.5*(X4-X1)^2)/m8
Hx_q(n1, n2, n3, n4, n5, n6, n7, n8) = [1.5*(A5*n5 - A8*n8); B5*n5 + B8*n8; n1 - C5*n5 - C8*n8; 1.5*(A6*n6 - A5*n5); B6*n6 + B5*n5; n2 - C6*n6 - C5*n5; 1.5*(A7*n7 - A6*n6); B7*n7 + B6*n6; n3 - C7*n7 - C6*n6; 1.5*(A8*n8 - A7*n7); B8*n8 + B7*n7; n4 - C8*n8 - C7*n7]
Hy_q(n1, n2, n3, n4, n5, n6, n7, n8) = [1.5*(D5*n5 - D8*n8); -n1 + E5*n5 + E8*n8; -B5*n5 - B8*n8; 1.5*(D6*n6 - D5*n5); -n2 + E6*n6 + E5*n5; -B6*n6 - B5*n5; 1.5*(D7*n7 - D6*n6); -n3 + E7*n7 + E6*n6; -B7*n7 - B6*n6; 1.5*(D8*n8 - D7*n7); -n4 + E8*n8 + E7*n7; -B8*n8 - B7*n7]
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
B1_q(xi, eta) = 2/h_x*Hxs(xi, eta)
B2_q(xi, eta) = 2/h_y*Hyh(xi, eta)
B3_q(xi, eta) = 2/h_y*Hxh(xi, eta) + 2/h_x*Hys(xi, eta)
#show
#: The side coefficients a…e of the DKQ come only from the geometry; on side 5 (nodes 1-2) of the typical element:
A_5 = A5 'coefficient a of side 5, in 1/m
C_5 = C5 'coefficient c of side 5 (unitless)
E_5 = E5 'coefficient e of side 5 (unitless)

## 6 · Isoparametric mapping and Jacobian
#: Each element is the image of the square ξ, η ∈ [−1, 1] by x = Σ Nᵢ·xᵢ, y = Σ Nᵢ·yᵢ (bilinear functions). The Jacobian J = ∂(x, y)/∂(ξ, η) transforms the derivatives: ∂/∂x = (2/h_x)·∂/∂ξ, ∂/∂y = (2/h_y)·∂/∂η, and dA = det J·dξ·dη.
J_11 = h_x/2 [m] 'derivative ∂x/∂ξ
J_22 = h_y/2 [m] 'derivative ∂y/∂η
det_J = J_11·J_22 [m²] 'det J: a quarter of the element area

## 7 · Element stiffness matrix: K = ∫ Bᵀ·D_b·B dA
D_p = E·t^3/(12·(1 - ν^2)) [kN·m] 'flexural rigidity D
D_b = D_p·[1, ν, 0; ν, 1, 0; 0, 0, (1 - ν)/2] [kN·m] 'moment-curvature matrix
#: Gauss 2 × 2 at ξ, η = ±1/√3 (weight 1):
g_p = 1/sqrt(3) 'coordinate of the Gauss points
#hide
B_G = zeros(12, 12)
r_g = [-g_p, g_p, g_p, -g_p]
s_g = [-g_p, -g_p, g_p, g_p]
K_e = zeros(12, 12)
for p = 1:4
  B_1 = transpose(B1_q(r_g(p), s_g(p)))
  B_2 = transpose(B2_q(r_g(p), s_g(p)))
  B_3 = transpose(B3_q(r_g(p), s_g(p)))
  K_e = K_e + det_J·(D_b(1, 1)·transpose(B_1)·B_1 + D_b(1, 2)·(transpose(B_1)·B_2 + transpose(B_2)·B_1) + D_b(2, 2)·transpose(B_2)·B_2 + D_b(3, 3)·transpose(B_3)·B_3)
  B_G(3·p - 2, :) = B_1
  B_G(3·p - 1, :) = B_2
  B_G(3·p, :) = B_3
end
#show
K_e11 = K_e(1, 1) [kN/m] 'stiffness to w of node 1
K_e22 = K_e(2, 2) [kN·m] 'stiffness to θx of node 1
K_e33 = K_e(3, 3) [kN·m] 'stiffness to θy of node 1
#: **Rigid body:** a translation w = 1 at the 4 nodes produces no force:
u_r = [1; 0; 0; 1; 0; 0; 1; 0; 0; 1; 0; 0]
f_r = max(abs(K_e·u_r)) [kN] 'largest force of the rigid translation (zero)

## 8 · Assembly
n_n = n_x + 1 'nodes in x
n_j = (n_x + 1)·(n_y + 1) 'number of nodes
n_e = n_x·n_y 'number of elements
n_g = 3·n_j 'degrees of freedom of the slab
#hide
X_j = zeros(n_j, 1)
Y_j = zeros(n_j, 1)
for j = 1:n_y + 1
  for i = 1:n_n
    k = (j - 1)·n_n + i
    X_j(k) = (i - 1)·h_x
    Y_j(k) = (j - 1)·h_y
  end
end
e_j = zeros(n_e, 4)
for j = 1:n_y
  for i = 1:n_x
    e = (j - 1)·n_x + i
    k = (j - 1)·n_n + i
    e_j(e, 1) = k
    e_j(e, 2) = k + 1
    e_j(e, 3) = k + n_n + 1
    e_j(e, 4) = k + n_n
  end
end
s_b = zeros(n_j, 1)
for k = 1:n_j
  if X_j(k) < 0.001 || X_j(k) > a - 0.001 || Y_j(k) < 0.001 || Y_j(k) > b - 0.001
    s_b(k) = 1
  end
end
#show
#: Nodes row by row from the bottom-left corner. **How to read it:** the small numbers are nodes and those in the boxes, elements. An interior node is shared by 4 elements: there 4 stiffness contributions are ADDED.
#malla(X_j, Y_j, e_j)
d_j(j) = 3·(j - 1) + (1:3)
d_e(e) = [d_j(e_j(e, 1)), d_j(e_j(e, 2)), d_j(e_j(e, 3)), d_j(e_j(e, 4))]
#hide
K = zeros(n_g, n_g)
F = zeros(n_g, 1)
#show
for e = 1:n_e
  g = d_e(e)
  K(g, g) = K(g, g) + K_e
end
#: **Load:** each element distributes q·h_x·h_y to its 4 nodes, downward (−w):
#hide
for e = 1:n_e
  for c = 1:4
    k = e_j(e, c)
    F(3·k - 2) = F(3·k - 2) - q·h_x·h_y/4
  end
end
#show
F_z = sum(F) [kN] 'sum of the nodal loads = −q·a·b

## 9 · Boundary conditions in the system and solution
#: Simple support = **essential** condition w = 0 at the edge nodes (very stiff spring, like Calcpad). Mn = 0 is **natural**: it is not written, the rotations stay free.
k_r = 10^20 'stiffness of the support spring
#hide
for k = 1:n_j
  if s_b(k) == 1
    K(3·k - 2, 3·k - 2) = K(3·k - 2, 3·k - 2) + k_r
  end
end
#show
n_ap = sum(s_b) 'supported nodes
U = clsolve(K, F) 'displacements: w in m, rotations in rad
#hide
R_j = zeros(n_j, 1)
for k = 1:n_j
  if s_b(k) == 1
    R_j(k) = -k_r·U(3·k - 2)
  end
end
#show
R_t = sum(R_j) [kN] 'sum of the reactions (= total load)

## 10 · Results
#: Moments at the nodes as SAP2000 gives them: B at the 4 Gauss points, M = −D_b·B·u (CSI sign), bilinear extrapolation to the corners and average of the elements meeting at the node.
#hide
E_x = zeros(4, 4)
s_c = [-1, 1, 1, -1]
t_c = [-1, -1, 1, 1]
r_N = [-1, 1, 1, -1]
s_N = [-1, -1, 1, 1]
for k = 1:4
  for p = 1:4
    E_x(k, p) = 0.25·(1 + sqrt(3)·s_c(k)·r_N(p))·(1 + sqrt(3)·t_c(k)·s_N(p))
  end
end
X_E = zeros(12, 12)
D_B = zeros(12, 12)
for k = 1:4
  D_B(3·k - 2:3·k, 3·k - 2:3·k) = D_b
  for p = 1:4
    for c = 1:3
      X_E(3·(k - 1) + c, 3·(p - 1) + c) = E_x(k, p)
    end
  end
end
R_E = -X_E·D_B·B_G
M_s = zeros(n_j, 3)
c_n = zeros(n_j, 1)
for e = 1:n_e
  u_e = U(d_e(e))
  m_n = R_E·u_e
  for k = 1:4
    i = e_j(e, k)
    c_n(i) = c_n(i) + 1
    for c = 1:3
      M_s(i, c) = M_s(i, c) + m_n(3·(k - 1) + c)
    end
  end
end
for i = 1:n_j
  M_s(i, :) = M_s(i, :)/c_n(i)
end
W_m = zeros(n_n, n_y + 1)
M_1 = zeros(n_n, n_y + 1)
M_2 = zeros(n_n, n_y + 1)
M_3 = zeros(n_n, n_y + 1)
for j = 1:n_y + 1
  for i = 1:n_n
    k = (j - 1)·n_n + i
    W_m(i, j) = -1000·U(3·k - 2)
    M_1(i, j) = M_s(k, 1)
    M_2(i, j) = M_s(k, 2)
    M_3(i, j) = M_s(k, 3)
  end
end
#show
n_m = (n_y/2)·n_n + n_x/2 + 1 'slab center node
w_c = -1000·U(3·n_m - 2) [mm] 'deflection at the center (downward)
M_xc = M_s(n_m, 1) [kN·m/m] 'M11 at the center
M_yc = M_s(n_m, 2) [kN·m/m] 'M22 at the center (short span: governs)
M_xy1 = M_s(1, 3) [kN·m/m] 'M12 at the corner of node 1 (maximum torsion)
#: **How to read the maps.** 6 × 4 m plan seen from above, x to the right and y upward; jet scale on the right. Move the cursor: the balloon gives the position (x, y) and the value.
w_z(x, y) = spline(1 + x/h_x, 1 + y/h_y, W_m)
M_xx(x, y) = spline(1 + x/h_x, 1 + y/h_y, M_1)
M_yy(x, y) = spline(1 + x/h_x, 1 + y/h_y, M_2)
M_xy(x, y) = spline(1 + x/h_x, 1 + y/h_y, M_3)
#: Deflection w (mm, downward):
#map(w_z(x, y), [0 6], [0 4])
#: M11 (kN·m/m):
#map(M_xx(x, y), [0 6], [0 4])
#: M22 (kN·m/m):
#map(M_yy(x, y), [0 6], [0 4])
#: M12 (kN·m/m):
#map(M_xy(x, y), [0 6], [0 4])

## 11 · Verification
##11a · Navier (exact solution of the simply supported plate)
#hide
w_N = 0
M_xN = 0
M_yN = 0
for m = 1:2:59
  for n = 1:2:59
    s_mn = sin(m·pi/2)·sin(n·pi/2)
    d_mn = m·n·(m^2/a^2 + n^2/b^2)^2
    w_N = w_N + s_mn/d_mn
    M_xN = M_xN + (m^2/a^2 + ν·n^2/b^2)·s_mn/d_mn
    M_yN = M_yN + (ν·m^2/a^2 + n^2/b^2)·s_mn/d_mn
  end
end
w_N = 1000·16·q/(pi^6·D_p)·w_N
M_xN = 16·q/pi^4·M_xN
M_yN = 16·q/pi^4·M_yN
#show
w_Nc = w_N [mm] 'center deflection, Navier
M_xNc = M_xN [kN·m/m] 'Mx at the center, Navier
M_yNc = M_yN [kN·m/m] 'My at the center, Navier
e_w = round(100·(w_c - w_N)/w_N, 3) [%] '6 × 4 mesh versus Navier, deflection
e_Mx = round(100·(M_xc - M_xN)/M_xN, 3) [%] 'same, M11
e_My = round(100·(M_yc - M_yN)/M_yN, 3) [%] 'same, M22
#: **How to read it.** With 6 × 4 elements the deflection comes out 1.5 % short and M22 3.7 % high; with 48 × 32 (losa_calculo.py) the deflection is 6.626 mm and M22 12.320: the mesh converges to Navier.
##11b · Hekatan Struct Py and the table of the Calcpad sheet
w_py = 6.528691 [mm] 'center deflection with Plate from hekatan-struct-py (losa_resultados.json)
M11_py = 6.225905 [kN·m/m] 'M11 at the center, Plate from hekatan-struct-py
M22_py = 12.762707 [kN·m/m] 'M22 at the center, Plate from hekatan-struct-py
d_py = round(100·max(abs(w_c - w_py)/w_py, max(abs(M_xc - M11_py)/M11_py, abs(M_yc - M22_py)/M22_py)), 6) [%] 'largest difference sheet versus hekatan-struct-py
M11_sap = 6.22 [kN·m/m] 'Mx at the center from the «SAP2000 PDF» table of the Calcpad sheet
M22_sap = 12.76 [kN·m/m] 'My at the center, same table
M12_sap = 7.25 [kN·m/m] 'Mxy at the corner (absolute value), same table
d_sap = round(100·max(abs(M_xc - M11_sap)/M11_sap, max(abs(M_yc - M22_sap)/M22_sap, abs(abs(M_xy1) - M12_sap)/M12_sap)), 3) [%] 'largest difference versus that table
##11c · Square plate: Timoshenko coefficients (ν = 0.3, 32 × 32 mesh, losa_calculo.py)
#: Simply supported: w = 0.004062·q·a⁴/D (table 0.00406) and M = 0.04792·q·a² (table 0.0479). Fixed: w = 0.001269·q·a⁴/D (table 0.00126) and M = 0.02299·q·a² (table 0.0231).
