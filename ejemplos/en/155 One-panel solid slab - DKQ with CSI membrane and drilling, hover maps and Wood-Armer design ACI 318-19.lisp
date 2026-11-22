# One-panel solid slab on beams: CSI shell (Batoz DKQ + membrane with drilling rotation), Mxx, Myy and Mxy maps with the cursor and graphical design by Wood-Armer (ACI 318-19, NEC-15)
#numerico
#: **What is computed.** A 4.00 × 4.80 m, 15 cm solid slab, supported on the four edge beams, with the NEC-15 ultimate load. It is solved by finite elements with the **CSI thin shell** (Shell-Thin of SAP2000 and ETABS): bending with the **Batoz and Tahar DKQ** and, in the plane, the **CSI membrane with drilling rotation**. The moments Mxx, Myy and Mxy come out over the whole plan (maps: when the cursor passes, the tooltip gives the three at once and the position), and with them the **design**: Wood-Armer moments, steel per face and direction (ACI 318-19), steel map and the reinforcement drawn.
#: **How it is validated.** (1) Navier, the exact solution of the simply supported plate (to 4 digits); (2) equilibrium: the sum of the reactions is the total load; (3) a hand steel calculation at the centre; (4) the complete shell (6 degrees of freedom per node) gives the same moments as the plate alone. The DKQ element of this sheet is that of sheet 153 (= SAP2000 and ETABS to 1e-8 %) and the membrane is that of `k_membrana_csi.py` (= ETABS 22 to 2e-15).
#: **Units** (Ecuador): tonf, m, kgf/cm²; moments in tonf·m/m and steel in cm²/m. **CSI sign**: M > 0 = tension at the BOTTOM (positive span moment).

## 1 · In symbols
#: **Bending stiffness** of the plate, from E, the thickness h and ν:
D_f = Simplify{E*h^3/(12*(1-nu^2))}
#: **Thin plate equation** (Kirchhoff): D·∇⁴w = q. Navier solves it on a simply supported a × b plate with a double sine series; each term m, n (odd) is a sinusoidal deflection:
w_mn = Simplify{W*sin(m*pi*x/a)*sin(n*pi*y/b)}
#: The moments come from the curvatures, Mx = −D·(w,xx + ν·w,yy) (with w downward). Differentiating the term twice:
k_xx = Simplify{-Diff{Diff{W*sin(m*pi*x/a)*sin(n*pi*y/b) @ x} @ x}}
k_yy = Simplify{-Diff{Diff{W*sin(m*pi*x/a)*sin(n*pi*y/b) @ y} @ y}}
#: With uniform load q, its sine expansion gives q_{mn} = 16·q/(π²·m·n) and the amplitude is W_{mn} = q_{mn}/(D·π⁴·(m²/a² + n²/b²)²). Summing: w = Σ W_mn·sin·sin, Mx = Σ W_mn·D·π²·(m²/a² + ν·n²/b²)·sin·sin, My the same with ν in the other term.
#: **Bending steel** (ACI 318-19 §22.2, Whitney block in a strip of b = 100 cm): M_u = φ·A_s·f_y·(d − a/2) with a = A_s·f_{y} /(0.85·f'c·b). It is a second-degree equation in A_s; its smaller root is
#: A_s = 0.85·f'c·b·d/f_y · (1 − √(1 − 2·M_{u} /(φ·0.85·f'c·b·d²)))
#: **Wood-Armer** (the one used by SAFE and ETABS to reinforce slabs with Mxy): at each point, design moment of the bottom face Mx⁺ = Mxx + |Mxy|, My⁺ = Myy + |Mxy|; of the top face Mx⁻ = Mxx − |Mxy|, My⁻ = Myy − |Mxy|. If one of the two changes sign it is set to zero and the other becomes Myy ± Mxy²/|Mxx| (or the reverse). The twisting moment Mxy has no bar of its own: it is reinforced by adding it to the two directions.

## 2 · Data
l_x = 4.0 [m] 'short span (between beam axes), in x
l_y = 4.8 [m] 'long span, in y
h_l = 0.15 [m] 'thickness of the solid slab
f_c = 240 [kgf/cm²] 'concrete strength f'c
f_y = 4200 [kgf/cm²] 'yield strength of the reinforcing steel
f_cM = f_c·0.0980665 [MPa] 'f'c in MPa
E_c = 4700·sqrt(f_cM)·101.97162 [tonf/m²] 'concrete modulus, ACI 318-19 §19.2.2.1 (4700·√f'c in MPa), converted to tonf/m²
ν = 0.2 'Poisson's ratio of the concrete
γ_h = 2.4 [tonf/m³] 'unit weight of reinforced concrete
q_pp = γ_h·h_l [tonf/m²] 'slab self-weight
q_cm = 0.30 [tonf/m²] 'assumed superimposed dead load: finishes and masonry
q_cv = 0.204 [tonf/m²] 'residential live load, 2.0 kN/m² (NEC-SE-CG 2015)
q_D = q_pp + q_cm [tonf/m²] 'total dead load D
#: **Combinations** (NEC-SE-CG 2015 §3.4.3 = ACI 318-19 Table 5.3.1): 1.4·D and 1.2·D + 1.6·L. The larger governs:
q_u1 = 1.4·q_D [tonf/m²] 'combination 1
q_u2 = 1.2·q_D + 1.6·q_cv [tonf/m²] 'combination 2
q_u = max(q_u1, q_u2) [tonf/m²] 'ultimate design load
D_p = E_c·h_l^3/(12·(1 - ν^2)) [tonf·m] 'bending stiffness of the plate
D_b = D_p·[1, ν, 0; ν, 1, 0; 0, 0, (1 - ν)/2] [tonf·m] 'bending constitutive matrix (moments ↔ curvatures)

#: **How to read the plan.** The thick rectangle is the 4.00 × 4.80 m slab between axes; the grey bands at the edges are the beams that support it (in the model, a simple support: w = 0 along the whole edge, rotations free). The red arrows give the x and y directions; the origin of coordinates is the bottom-left corner (node 1). The load q_u is spread over the whole plan. **Section A-A** (along x, at mid-span) shows the 15 cm thickness, the load block and the beams; dimensions are in metres.
#dibujo("Slab plan: 4.00 × 4.80 m on beams at the 4 edges", ud = m, escala = auto, cotas = m, alto = 150)
#  rect(-0.15, -0.15, 4.30, 0.30, "denso")
#  rect(-0.15, 4.65, 4.30, 0.30, "denso")
#  rect(-0.15, 0.15, 0.30, 4.50, "denso")
#  rect(3.85, 0.15, 0.30, 4.50, "denso")
#  rect(0, 0, 4.0, 4.8, "gruesa")
#  linea(-0.6, 2.4, 4.6, 2.4, "trazos")
#  texto(-0.75, 2.4, "A", 3, "c")
#  texto(4.75, 2.4, "A", 3, "c")
#  flecha(0.45, 0.45, 1.25, 0.45, "rojo")
#  flecha(0.45, 0.45, 0.45, 1.25, "rojo")
#  texto(1.35, 0.45, "x", 2.8, "i", estilo = "rojo")
#  texto(0.45, 1.40, "y", 2.8, "c", estilo = "rojo")
#  texto(2.0, 3.4, "solid slab h = 0.15 m", 2.6, "c")
#  texto(2.0, 3.0, "qu = {q_u:3} tonf/m²", 2.6, "c", estilo = "azul")
#  texto(2.0, 1.4, "edge beams = simple support", 2.4, "c")
#  cota(0, -0.55, 4.0, -0.55, -0.05, "4.00")
#  cota(-1.15, 0, -1.15, 4.8, 0.05, "4.80")
#fin
#dibujo("Section A-A: 15 cm slab between beams, with the ultimate load", ud = m, escala = auto, cotas = m, alto = 110)
#  seccion(0, 0, 4.0, 0.15)
#  rect(-0.15, -0.30, 0.30, 0.45, "gruesa")
#  rect(3.85, -0.30, 0.30, 0.45, "gruesa")
#  carga(0, 0.15, 4.0, 0.15, 0.35, 0.35, "qu = {q_u:3} tonf/m²", "azul", n = 11)
#  cota(0, -0.55, 4.0, -0.55, -0.05, "4.00")
#  texto(4.35, 0.075, "h = 0.15", 2.4, "i")
#fin

## 3 · The element: CSI thin shell = DKQ (bending) + membrane with drilling rotation
#: Each node of a shell has **6 degrees of freedom**: u_x, u_y, w, θx, θy, θz. A flat shell separates two problems that do not touch: **bending** (w, θx, θy: the DKQ) and the **membrane** (u_x, u_y and the drilling rotation θz). Both are written, joined into the 24 × 24 element matrix and it is checked at the end that, in a slab with no in-plane forces, the membrane does NOT change Mxx, Myy or Mxy.
#: Mesh of 0.40 m square elements: 10 in x and 12 in y.
n_x = 10 'elements in x
n_y = 12 'elements in y
h_x = l_x/n_x [m] 'element side in x
h_y = l_y/n_y [m] 'element side in y

### 3a · Bending: Batoz and Tahar DKQ (discrete Kirchhoff, sheet 153)
#: Rotations with the right-hand rule: θx = ∂w/∂y, θy = −∂w/∂x. Coordinates of the typical element (counterclockwise nodes):
X1 = 0 [m] 'x of node 1
Y1 = 0 [m] 'y of node 1
X2 = h_x [m] 'x of node 2
Y2 = 0 [m] 'y of node 2
X3 = h_x [m] 'x of node 3
Y3 = h_y [m] 'y of node 3
X4 = 0 [m] 'x of node 4
Y4 = h_y [m] 'y of node 4
#: Sides 5 = 1-2, 6 = 2-3, 7 = 3-4, 8 = 4-1; their five coefficients a…e (those of section 1 of sheet 153):
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
#: In a rectangle the Jacobian is constant: ∂/∂x = (2/h_x)·∂/∂ξ and ∂/∂y = (2/h_y)·∂/∂η. Curvatures κ = [βx,x ; βy,y ; βx,y + βy,x] = B·u and stiffness K = Σ Bᵀ·D_b·B·|J| at the 4 Gauss points ±1/√3:
g_p = 1/sqrt(3) 'coordinate of the 2 × 2 Gauss points
j_e = h_x·h_y/4 [m²] 'Jacobian |J| of the rectangle
#hide
B_G = zeros(12, 12)
r_g = [-g_p, g_p, g_p, -g_p]
s_g = [-g_p, -g_p, g_p, g_p]
K_p = zeros(12, 12)
for p = 1:4
  B_1 = transpose(B1_q(r_g(p), s_g(p)))
  B_2 = transpose(B2_q(r_g(p), s_g(p)))
  B_3 = transpose(B3_q(r_g(p), s_g(p)))
  K_p = K_p + j_e·(D_b(1, 1)·transpose(B_1)·B_1 + D_b(1, 2)·(transpose(B_1)·B_2 + transpose(B_2)·B_1) + D_b(2, 2)·transpose(B_2)·B_2 + D_b(3, 3)·transpose(B_3)·B_3)
  B_G(3·p - 2, :) = B_1
  B_G(3·p - 1, :) = B_2
  B_G(3·p, :) = B_3
end
#show
K_p11 = K_p(1, 1) [tonf/m] 'stiffness to w of node 1 (Python prototype with the same formulas: 42 573.9995)
K_p22 = K_p(2, 2) [tonf·m] 'stiffness to θx of node 1 (Python: 930.9515)

### 3b · CSI membrane with drilling rotation (Allman + ITW, taken from the SAPFire binary)
#: Degrees of freedom [u_x, u_y, θz] per node. The in-plane displacement has the usual bilinear part, a **bubble** (1 − r²)(1 − s²) that is condensed and, on each side, a parabolic term that moves the rotation of the two nodes: Δu = (l/8)·(θ_j − θ_i)·n (Allman). In a rectangle, (l/8)·n of each side is:
c_x = [0, h_y/8, 0, -h_y/8] [m] 'x component of (l/8)·n of sides 1-2, 2-3, 3-4, 4-1
c_y = [-h_x/8, 0, h_x/8, 0] [m] 'y component
a_n = [4, 1, 2, 3] 'side that ARRIVES at each node (the one that leaves is the one with the same number)
D_m = E_c·h_l/(1 - ν^2)·[1, ν, 0; ν, 1, 0; 0, 0, (1 - ν)/2] [tonf/m] 'plane stress times the thickness
G_c = E_c/(2·(1 + ν)) [tonf/m²] 'shear modulus
#: B of the membrane at (r, s) (3 × 14: u, v, θ of the 4 nodes and the 2 bubbles). The θ columns are **projected** (their mean over the element is subtracted): without that the element departs 1.4 % from CSI.
#hide
r_N = [-1, 1, 1, -1]
s_N = [-1, -1, 1, 1]
M_t = zeros(3, 4)
for p = 1:4
  r_p = r_g(p)
  s_p = s_g(p)
  n_r = 0.5·[-2·r_p·(1 - s_p), 1 - s_p^2, -2·r_p·(1 + s_p), -(1 - s_p^2)]
  n_s = 0.5·[-(1 - r_p^2), -2·s_p·(1 + r_p), 1 - r_p^2, -2·s_p·(1 - r_p)]
  for i = 1:4
    k = a_n(i)
    M_t(1, i) = M_t(1, i) + (2/h_x·n_r(k)·c_x(k) - 2/h_x·n_r(i)·c_x(i))/4
    M_t(2, i) = M_t(2, i) + (2/h_y·n_s(k)·c_y(k) - 2/h_y·n_s(i)·c_y(i))/4
    M_t(3, i) = M_t(3, i) + (2/h_y·n_s(k)·c_x(k) - 2/h_y·n_s(i)·c_x(i) + 2/h_x·n_r(k)·c_y(k) - 2/h_x·n_r(i)·c_y(i))/4
  end
end
K_14 = zeros(14, 14)
for p = 1:4
  r_p = r_g(p)
  s_p = s_g(p)
  n_r = 0.5·[-2·r_p·(1 - s_p), 1 - s_p^2, -2·r_p·(1 + s_p), -(1 - s_p^2)]
  n_s = 0.5·[-(1 - r_p^2), -2·s_p·(1 + r_p), 1 - r_p^2, -2·s_p·(1 - r_p)]
  B_m = zeros(3, 14)
  for i = 1:4
    k = a_n(i)
    d_nx = 2/h_x·r_N(i)·(1 + s_N(i)·s_p)/4
    d_ny = 2/h_y·s_N(i)·(1 + r_N(i)·r_p)/4
    B_m(1, 3·i - 2) = d_nx
    B_m(2, 3·i - 1) = d_ny
    B_m(3, 3·i - 2) = d_ny
    B_m(3, 3·i - 1) = d_nx
    B_m(1, 3·i) = 2/h_x·n_r(k)·c_x(k) - 2/h_x·n_r(i)·c_x(i) - M_t(1, i)
    B_m(2, 3·i) = 2/h_y·n_s(k)·c_y(k) - 2/h_y·n_s(i)·c_y(i) - M_t(2, i)
    B_m(3, 3·i) = 2/h_y·n_s(k)·c_x(k) - 2/h_y·n_s(i)·c_x(i) + 2/h_x·n_r(k)·c_y(k) - 2/h_x·n_r(i)·c_y(i) - M_t(3, i)
  end
  B_m(1, 13) = 2/h_x·(-2·r_p·(1 - s_p^2))
  B_m(3, 13) = 2/h_y·(-2·s_p·(1 - r_p^2))
  B_m(2, 14) = 2/h_y·(-2·s_p·(1 - r_p^2))
  B_m(3, 14) = 2/h_x·(-2·r_p·(1 - s_p^2))
  K_14 = K_14 + j_e·transpose(B_m)·D_m·B_m
end
b_0 = zeros(14, 1)
for i = 1:4
  k = a_n(i)
  b_0(3·i - 2) = -0.5·2/h_y·s_N(i)·(1 + r_N(i)·0)/4
  b_0(3·i - 1) = 0.5·2/h_x·r_N(i)·(1 + s_N(i)·0)/4
  n_rk = [0, 0.5, 0, -0.5]
  n_sk = [-0.5, 0, 0.5, 0]
  b_0(3·i) = 0.5·((2/h_x·n_rk(k)·c_y(k) - 2/h_x·n_rk(i)·c_y(i)) - (2/h_y·n_sk(k)·c_x(k) - 2/h_y·n_sk(i)·c_x(i))) - 1/4
end
h_t = zeros(14, 1)
h_t(3) = 1
h_t(6) = -1
h_t(9) = 1
h_t(12) = -1
#show
#: **The two drilling terms** (read in the CSI binary, `CsiGo2.dll`): Wilson's, which ties θz to the rotation of the middle, b₀ᵀ·u = ½·(∂v/∂x − ∂u/∂y) − ¼·Σθᵢ, with weight 0.1·G·h·A; and a rotation hourglass, h = [+1, −1, +1, −1], with weight 5·10⁻⁵·G·h·A. Then the two bubbles are condensed (K_bb − K_bα·K_αα⁻¹·K_αb):
A_e = h_x·h_y [m²] 'element area
#hide
K_14 = K_14 + 0.1·G_c·h_l·A_e·(2·b_0)·transpose(2·b_0) + 0.00005·G_c·h_l·A_e·h_t·transpose(h_t)
K_m = K_14(1:12, 1:12) - K_14(1:12, 13:14)·inv(K_14(13:14, 13:14))·K_14(13:14, 1:12)
#show
K_m11 = K_m(1, 1) [tonf/m] 'stiffness to u_x of node 1 (k_membrana_csi.py = ETABS 22: 165 387.1483)
K_m33 = K_m(3, 3) [tonf·m] 'stiffness to θz of node 1 (k_membrana_csi.py: 1 274.4360)

### 3c · The shell: 24 × 24
#: Per node [u_x, u_y, w, θx, θy, θz] (the CSI order: U1, U2, U3, R1, R2, R3). Bending goes to positions 3, 4, 5 and the membrane to 1, 2, 6; the cross blocks are zero because the element is flat.
#hide
i_p = [3, 4, 5]
i_m = [1, 2, 6]
K_c = zeros(24, 24)
for i_a = 1:4
  for i_b = 1:4
    for r = 1:3
      for s = 1:3
        K_c(6·(i_a - 1) + i_p(r), 6·(i_b - 1) + i_p(s)) = K_p(3·(i_a - 1) + r, 3·(i_b - 1) + s)
        K_c(6·(i_a - 1) + i_m(r), 6·(i_b - 1) + i_m(s)) = K_m(3·(i_a - 1) + r, 3·(i_b - 1) + s)
      end
    end
  end
end
#show
K_c33 = K_c(3, 3) [tonf/m] 'w of node 1 in the shell (= K_p11)

## 4 · Mesh, supports and load
n_n = n_x + 1 'nodes in x
n_j = (n_x + 1)·(n_y + 1) 'number of nodes
n_e = n_x·n_y 'number of elements
#hide
X_j = zeros(n_j, 1)
Y_j = zeros(n_j, 1)
for j = 1:n_y + 1
  for i = 1:n_n
    q = (j - 1)·n_n + i
    X_j(q) = (i - 1)·h_x
    Y_j(q) = (j - 1)·h_y
  end
end
e_j = zeros(n_e, 4)
for j = 1:n_y
  for i = 1:n_x
    e = (j - 1)·n_x + i
    q = (j - 1)·n_n + i
    e_j(e, 1) = q
    e_j(e, 2) = q + 1
    e_j(e, 3) = q + n_n + 1
    e_j(e, 4) = q + n_n
  end
end
s_b = zeros(n_j, 1)
for q = 1:n_j
  if X_j(q) < 0.001 || X_j(q) > l_x - 0.001 || Y_j(q) < 0.001 || Y_j(q) > l_y - 0.001
    s_b(q) = 1
  end
end
#show
#: Nodes numbered row by row from the bottom-left corner. **How to read it:** the small numbers are nodes, those in the boxes are elements; the edge nodes carry the support (w = 0).
#malla(X_j, Y_j, e_j)
n_ap = sum(s_b) 'supported nodes (the whole perimeter)
#: **Load.** Each element distributes q_u·A_e to its 4 nodes (a quarter each), downward (−z).
n_g = 6·n_j 'degrees of freedom of the shell
#hide
F = zeros(n_g, 1)
for e = 1:n_e
  for c = 1:4
    q = e_j(e, c)
    F(6·q - 3) = F(6·q - 3) - q_u·h_x·h_y/4
  end
end
#show
F_z = sum(F) [tonf] 'sum of the nodal loads = −q_u·l_x·l_y

## 5 · Assembly and solution
#: Degrees of freedom of node j: 6·(j − 1) + 1 … 6. The K of each element is **added** into the rows and columns of its 4 nodes:
d_j(j) = 6·(j - 1) + (1:6)
d_e(e) = [d_j(e_j(e, 1)), d_j(e_j(e, 2)), d_j(e_j(e, 3)), d_j(e_j(e, 4))]
#hide
K = zeros(n_g, n_g)
#show
for e = 1:n_e
  g = d_e(e)
  K(g, g) = K(g, g) + K_c
end
#: **Supports** as very stiff springs k_r (the same trick as Calcpad in sheet 77): w of the whole edge. The membrane only needs not to slide or rotate in its plane: u_x and u_y of node 1 and u_y of node 11.
k_r = 10^20 'stiffness of the support spring
#hide
for q = 1:n_j
  if s_b(q) == 1
    K(6·q - 3, 6·q - 3) = K(6·q - 3, 6·q - 3) + k_r
  end
end
K(1, 1) = K(1, 1) + k_r
K(2, 2) = K(2, 2) + k_r
K(6·n_n - 4, 6·n_n - 4) = K(6·n_n - 4, 6·n_n - 4) + k_r
#show
U = clsolve(K, F) 'displacements of the 858 degrees of freedom [m, rad]
#: **Equilibrium.** The reaction at each support is −k_r·w; their sum must be the total load:
#hide
R_j = zeros(n_j, 1)
for q = 1:n_j
  if s_b(q) == 1
    R_j(q) = -k_r·U(6·q - 3)
  end
end
#show
R_t = sum(R_j) [tonf] 'sum of the reactions
Q_t = q_u·l_x·l_y [tonf] 'total load
d_R = round(100·(R_t - Q_t)/Q_t, 8) [%] 'difference
u_mem = max(abs(U(1:6:n_g))) [m] 'largest membrane displacement u_x (no in-plane forces: 0)

## 6 · Moments at the nodes (as given by SAP2000 and ETABS)
#: In each element: B of the DKQ at the 4 Gauss points, M = −D_b·B·u (CSI sign: positive = tension at the bottom), and bilinear Gauss extrapolation to the corners; at each node the elements that arrive are averaged. The R_E matrix (12 × 12) does everything at once: moments of the 4 corners = R_E·u_e.
#hide
E_x = zeros(4, 4)
s_c = [-1, 1, 1, -1]
t_c = [-1, -1, 1, 1]
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
  u_e = zeros(12, 1)
  for k = 1:4
    q = e_j(e, k)
    u_e(3·k - 2) = U(6·q - 3)
    u_e(3·k - 1) = U(6·q - 2)
    u_e(3·k) = U(6·q - 1)
  end
  m_n = R_E·u_e
  for k = 1:4
    q = e_j(e, k)
    c_n(q) = c_n(q) + 1
    for c = 1:3
      M_s(q, c) = M_s(q, c) + m_n(3·(k - 1) + c)
    end
  end
end
for q = 1:n_j
  M_s(q, :) = M_s(q, :)/c_n(q)
end
#show
n_m = (n_y/2)·n_n + n_x/2 + 1 'node at the centre of the slab
w_c = 1000·U(6·n_m - 3) [mm] 'deflection at the centre (negative = downward)
M_xc = M_s(n_m, 1) [tonf·m/m] 'Mxx at the centre
M_yc = M_s(n_m, 2) [tonf·m/m] 'Myy at the centre
M_xy1 = M_s(1, 3) [tonf·m/m] 'Mxy at the corner of node 1 (the maximum twisting moment)

## 7 · The membrane does not change the bending: the plate alone gives the same
#: Only the bending is solved again (3 degrees of freedom per node, K_p) and the moments are compared node by node with those of the complete shell:
#hide
n_3 = 3·n_j
K_3 = zeros(n_3, n_3)
F_3 = zeros(n_3, 1)
for e = 1:n_e
  g_3 = [3·e_j(e, 1) - 2:3·e_j(e, 1), 3·e_j(e, 2) - 2:3·e_j(e, 2), 3·e_j(e, 3) - 2:3·e_j(e, 3), 3·e_j(e, 4) - 2:3·e_j(e, 4)]
  K_3(g_3, g_3) = K_3(g_3, g_3) + K_p
end
for q = 1:n_j
  F_3(3·q - 2) = F(6·q - 3)
  if s_b(q) == 1
    K_3(3·q - 2, 3·q - 2) = K_3(3·q - 2, 3·q - 2) + k_r
  end
end
U_3 = clsolve(K_3, F_3)
M_p = zeros(n_j, 3)
for e = 1:n_e
  u_e = zeros(12, 1)
  for k = 1:4
    q = e_j(e, k)
    u_e(3·k - 2:3·k) = U_3(3·q - 2:3·q)
  end
  m_n = R_E·u_e
  for k = 1:4
    q = e_j(e, k)
    for c = 1:3
      M_p(q, c) = M_p(q, c) + m_n(3·(k - 1) + c)/c_n(q)
    end
  end
end
#show
w_c3 = 1000·U_3(3·n_m - 2) [mm] 'deflection at the centre with the plate alone
d_w = abs(w_c3 - w_c) [mm] 'deflection difference, shell − plate alone
d_M = max(max(abs(M_p - M_s))) [tonf·m/m] 'largest difference of Mxx, Myy or Mxy over the 143 nodes, shell − plate alone
#: **Why.** In a flat element the membrane (u_x, u_y, θz) and the bending (w, θx, θy) share no term of K: the vertical load only moves the bending and the membrane stays at zero (u_mem = 0 above). The membrane with drilling rotation matters when there are **in-plane forces** (diaphragm with earthquake, walls, inclined slabs or slabs with eccentric beams) or when the slab joins members that do rotate in their plane (columns at the nodes). In a horizontal slab loaded vertically, Mxx, Myy and Mxy come only from the DKQ.

## 8 · Check with Navier (exact solution)
#: Double series of section 1 at the centre (x = l_x/2, y = l_y/2), with m, n odd up to 59:
#hide
w_N = 0
M_xN = 0
M_yN = 0
for m = 1:2:59
  for n = 1:2:59
    s_mn = sin(m·pi/2)·sin(n·pi/2)
    d_mn = m·n·(m^2/l_x^2 + n^2/l_y^2)^2
    w_N = w_N + s_mn/d_mn
    M_xN = M_xN + (m^2/l_x^2 + ν·n^2/l_y^2)·s_mn/d_mn
    M_yN = M_yN + (ν·m^2/l_x^2 + n^2/l_y^2)·s_mn/d_mn
  end
end
w_N = -1000·16·q_u/(pi^6·D_p)·w_N
M_xN = 16·q_u/pi^4·M_xN
M_yN = 16·q_u/pi^4·M_yN
#show
w_Nc = w_N [mm] 'deflection at the centre, Navier
M_xNc = M_xN [tonf·m/m] 'Mxx at the centre, Navier
M_yNc = M_yN [tonf·m/m] 'Myy at the centre, Navier
e_w = round(100·(w_c - w_N)/w_N, 3) [%] 'finite elements against Navier, deflection
e_Mx = round(100·(M_xc - M_xN)/M_xN, 3) [%] 'idem, Mxx
e_My = round(100·(M_yc - M_yN)/M_yN, 3) [%] 'idem, Myy
#: **How to read it.** With 10 × 12 elements the deflection differs ≈ 0.1 % and the moments ≈ 0.4-0.7 % from the exact solution (with 20 × 24 elements the Mxx drops to 0.16 %: the DKQ converges). Navier with ν = 0.3 and b/a = 1.2 gives the coefficients that Timoshenko tabulates (w = α·q·a⁴/D, M = β·q·a²), so this check is the same as that of the tables.

## 9 · Mxx, Myy and Mxy maps (move the cursor: the tooltip gives the three at once)
#hide
W_m = zeros(n_n, n_y + 1)
M_1 = zeros(n_n, n_y + 1)
M_2 = zeros(n_n, n_y + 1)
M_3 = zeros(n_n, n_y + 1)
for j = 1:n_y + 1
  for i = 1:n_n
    q = (j - 1)·n_n + i
    W_m(i, j) = -1000·U(6·q - 3)
    M_1(i, j) = M_s(q, 1)
    M_2(i, j) = M_s(q, 2)
    M_3(i, j) = M_s(q, 3)
  end
end
#show
#: Each map is the 4.00 × 4.80 m plan seen from above, with x to the right and y upward (in metres), painted with the jet scale on the right. The node values are joined with a spline. **When the cursor passes** the tooltip gives the position (x, y) and the value of ALL the maps of this plan at that point (▶ marks the map you are over): the deflection, Mxx, Myy, Mxy and, further down, the steel of the four faces.
w_z(x, y) = spline(1 + x/h_x, 1 + y/h_y, W_m)
M_xx(x, y) = spline(1 + x/h_x, 1 + y/h_y, M_1)
M_yy(x, y) = spline(1 + x/h_x, 1 + y/h_y, M_2)
M_xy(x, y) = spline(1 + x/h_x, 1 + y/h_y, M_3)
#: **Deflection** w (mm, downward). How to read it: it is a "dish" with the bottom at the centre (2.37 mm) and zero at the four supported edges.
#map(w_z(x, y), [0 4], [0 4.8])
#: **Mxx** (tonf·m/m): the one that reinforces the bars parallel to x. How to read it: maximum at the centre (≈ 1.07, red), zero at the edges x = 0 and x = 4 (simple support: there is no moment), and the central strip is wider in y because the short span is that of x.
#map(M_xx(x, y), [0 4], [0 4.8])
#: **Myy** (tonf·m/m): the one that reinforces the bars parallel to y. How to read it: smaller than Mxx (0.81 at the centre) because the y span is the long one; zero at the edges y = 0 and y = 4.8.
#map(M_yy(x, y), [0 4], [0 4.8])
#: **Mxy** (tonf·m/m, twisting). How to read it: zero at the centre and on the axes of symmetry, maximum at the **corners** (≈ ±0.75): the sign changes from one corner to the next. It is the one that lifts the corners of a supported slab (if the beam does not hold it) and the one that asks for steel at the TOP in the corners.
#map(M_xy(x, y), [0 4], [0 4.8])
#: **Section through the centre**, y = 2.40 m: Mxx from the finite elements (nodes) and from Navier. How to read it: the two curves almost cover each other; zero at the supports x = 0 and x = 4 and maximum at x = 2.
#hide
C_Fe = zeros(n_n, 2)
C_Nv = zeros(41, 2)
for i = 1:n_n
  C_Fe(i, 1) = (i - 1)·h_x
  C_Fe(i, 2) = M_s((n_y/2)·n_n + i, 1)
end
for k = 1:41
  x_k = (k - 1)·l_x/40
  m_k = 0
  for m = 1:2:59
    for n = 1:2:59
      m_k = m_k + (m^2/l_x^2 + ν·n^2/l_y^2)·sin(m·pi·x_k/l_x)·sin(n·pi/2)/(m·n·(m^2/l_x^2 + n^2/l_y^2)^2)
    end
  end
  C_Nv(k, 1) = x_k
  C_Nv(k, 2) = 16·q_u/pi^4·m_k
end
#show
#fplot(Mxx_FEM = C_Fe, Mxx_Navier = C_Nv, [0 4])

## 10 · Design: Wood-Armer moments and steel (ACI 318-19)
r_ec = 2.0 [cm] 'clear cover of the slab (ACI 318-19 Table 20.5.1.3.1: 20 mm, slab not exposed)
d_v = 1.0 [cm] 'assumed bar diameter, Ø10
d_x = 100·h_l - r_ec - d_v/2 [cm] 'effective depth of the bars in x (outer layer, the short span)
d_y = d_x - d_v [cm] 'effective depth of the bars in y (inner layer)
φ_f = 0.9 'flexural reduction factor (tension-controlled section, checked below)
A_smin = 0.0018·100·100·h_l [cm²/m] 'minimum steel, ACI 318-19 §8.6.1.1 (0.0018·A_g, f_y = 420 MPa), on the tension face
s_max = min(2·100·h_l, 45) [cm] 'maximum spacing, ACI 318-19 §8.7.2.2 (2·h and 45 cm)
#: The steel per metre, the formula of section 1 with b = 100 cm and M_u in tonf·m/m (×10⁵ for kgf·cm):
A_req(M_u, d_c) = 0.85·f_c·100·d_c/f_y·(1 - sqrt(1 - 2·M_u·10^5/(φ_f·0.85·f_c·100·d_c^2)))
#hide
A_1 = zeros(n_n, n_y + 1)
A_2 = zeros(n_n, n_y + 1)
A_3 = zeros(n_n, n_y + 1)
A_4 = zeros(n_n, n_y + 1)
W_A = zeros(n_j, 4)
for q = 1:n_j
  m_x = M_s(q, 1)
  m_y = M_s(q, 2)
  m_t = abs(M_s(q, 3))
  b_x = m_x + m_t
  b_y = m_y + m_t
  if b_x < 0
    b_x = 0
    b_y = m_y + m_t^2/abs(m_x)
  end
  if b_y < 0
    b_y = 0
    b_x = m_x + m_t^2/abs(m_y)
  end
  a_x = m_x - m_t
  a_y = m_y - m_t
  if a_x > 0
    a_x = 0
    a_y = m_y - m_t^2/abs(m_x)
  end
  if a_y > 0
    a_y = 0
    a_x = m_x - m_t^2/abs(m_y)
  end
  W_A(q, 1) = max(b_x, 0)
  W_A(q, 2) = max(b_y, 0)
  W_A(q, 3) = -min(a_x, 0)
  W_A(q, 4) = -min(a_y, 0)
end
for j = 1:n_y + 1
  for i = 1:n_n
    q = (j - 1)·n_n + i
    A_1(i, j) = A_req(W_A(q, 1), d_x)
    A_2(i, j) = A_req(W_A(q, 2), d_y)
    A_3(i, j) = A_req(W_A(q, 3), d_x)
    A_4(i, j) = A_req(W_A(q, 4), d_y)
  end
end
#show
#: **Maximum design moments** (Wood-Armer), in absolute value:
M_xinf = max(W_A(:, 1)) [tonf·m/m] 'bottom face, x direction (centre)
M_yinf = max(W_A(:, 2)) [tonf·m/m] 'bottom face, y direction
M_xsup = max(W_A(:, 3)) [tonf·m/m] 'top face, x direction (corners, from Mxy)
M_ysup = max(W_A(:, 4)) [tonf·m/m] 'top face, y direction (corners)
#: **Maximum required steel** per face and direction:
A_xinf = A_req(M_xinf, d_x) [cm²/m] 'bottom, bars in x
A_yinf = A_req(M_yinf, d_y) [cm²/m] 'bottom, bars in y
A_xsup = A_req(M_xsup, d_x) [cm²/m] 'top, bars in x (corners)
A_ysup = A_req(M_ysup, d_y) [cm²/m] 'top, bars in y (corners)
#: **Required steel maps** (cm²/m, without the minimum, to see WHERE it asks). How to read it: at the bottom, the steel follows Mxx + |Mxy| and My + |Mxy| (maximum at the centre); at the top it appears only at the four corners, because of the twisting moment. Every value below A_smin = 2.70 cm²/m is covered by the minimum.
A_xi(x, y) = spline(1 + x/h_x, 1 + y/h_y, A_1)
A_yi(x, y) = spline(1 + x/h_x, 1 + y/h_y, A_2)
A_xs(x, y) = spline(1 + x/h_x, 1 + y/h_y, A_3)
A_ys(x, y) = spline(1 + x/h_x, 1 + y/h_y, A_4)
#: Bottom, x direction:
#map(A_xi(x, y), [0 4], [0 4.8])
#: Bottom, y direction:
#map(A_yi(x, y), [0 4], [0 4.8])
#: Top, x direction:
#map(A_xs(x, y), [0 4], [0 4.8])
#: Top, y direction:
#map(A_ys(x, y), [0 4], [0 4.8])

### 10a · One point by hand: the centre, bottom in x
#: At the centre Mxy = 0, so Wood-Armer gives Mx⁺ = Mxx. Step by step with Whitney's formula:
M_uc = M_xc [tonf·m/m] 'ultimate moment at the centre
M_uk = M_uc·10^5 [kgf·cm/m] 'in kgf·cm per metre of width
R_nu = M_uk/(φ_f·100·d_x^2) [kgf/cm²] 'strength required of the section
ρ_c = 0.85·f_c/f_y·(1 - sqrt(1 - 2·R_nu/(0.85·f_c))) 'required reinforcement ratio
A_sc = ρ_c·100·d_x [cm²/m] 'required steel = A_req of the map at the centre
a_w = A_sc·f_y/(0.85·f_c·100) [cm] 'depth of the compression block
c_n0 = a_w/0.85 [cm] 'neutral axis (β₁ = 0.85 for f'c ≤ 280 kgf/cm²)
ε_t = 0.003·(d_x - c_n0)/c_n0 'steel strain: ≥ 0.005 ⇒ tension-controlled, φ = 0.9 valid
M_ver = φ_f·A_sc·f_y·(d_x - a_w/2)/10^5 [tonf·m/m] 'check: φ·Mn with that steel = M_u
#: **How to read it.** 2.30 cm²/m is asked at the centre, less than the minimum of 2.70: in this slab the **minimum steel** governs over almost the whole plan. The steel strain comes out well above 0.005, so φ = 0.9 is correctly taken.

### 10b · Proposed reinforcement
A_b = pi·d_v^2/4 [cm²] 'area of one Ø10 bar
A_dx = max(A_xinf, A_smin) [cm²/m] 'design steel bottom in x
A_dy = max(A_yinf, A_smin) [cm²/m] 'design steel bottom in y
s_x = min(floor(100·A_b/A_dx/2.5)·2.5, s_max) [cm] 'spacing bottom in x (multiple of 2.5 cm)
s_y = min(floor(100·A_b/A_dy/2.5)·2.5, s_max) [cm] 'spacing bottom in y
A_px = 100·A_b/s_x [cm²/m] 'steel provided bottom in x
A_py = 100·A_b/s_y [cm²/m] 'steel provided bottom in y
#: **Corners (top and bottom).** ACI 318-19 §8.7.3.1: at the exterior corners of a slab on beams, reinforcement is placed, top and bottom, for the **largest positive moment** of the panel, over a distance of l/5 of the long span from the corner. Wood-Armer asks at the top for A_xsup in x and A_ysup in y; the larger of the two criteria is taken:
l_esq = l_y/5 [m] 'side of the corner reinforcement square
A_esq = max(max(A_xsup, A_ysup), A_xinf) [cm²/m] 'corner steel, top, in both directions
s_e = min(floor(100·A_b/max(A_esq, A_smin)/2.5)·2.5, s_max) [cm] 'spacing of the corner reinforcement
n_bx = floor(100·l_y/s_x) + 1 'bars bottom in x (spread over 4.80 m)
n_by = floor(100·l_x/s_y) + 1 'bars bottom in y (spread over 4.00 m)
n_be = floor(100·l_esq/s_e) + 1 'bars per direction in each corner
#: Bar positions for the drawing (centred on the span; those at the corners, from 8 cm from the edge):
#hide
y_bx = zeros(n_bx, 1)
x_by = zeros(n_by, 1)
p_e = zeros(n_be, 1)
for k = 1:n_bx
  y_bx(k) = (l_y - (n_bx - 1)·s_x/100)/2 + (k - 1)·s_x/100
end
for k = 1:n_by
  x_by(k) = (l_x - (n_by - 1)·s_y/100)/2 + (k - 1)·s_y/100
end
for k = 1:n_be
  p_e(k) = 0.08 + (k - 1)·s_e/100
end
#show
#: **How to read the reinforcement plan.** Two identical plans of the slab, side by side so that the labels do not cross the bars of the other direction. **Left:** the bars in x (parallel to the short span, outer bottom layer); **right:** the bars in y (inner bottom layer). ALL are drawn, at their real spacing; the red one with hooks is the typical bar and its label says "quantity Ø diameter @ spacing". The dimensions give the spans.
#dibujo("Bottom reinforcement: Ø10 in x (left) and Ø10 in y (right)", ud = m, escala = auto, cotas = m, alto = 175)
#  rect(0, 0, 4.0, 4.8, "gruesa")
#  rect(5.5, 0, 4.0, 4.8, "gruesa")
#  rect(0.05, y_bx, 3.9, 0, "fina")
#  rect(5.5 + x_by, 0.05, 0, 4.7, "fina")
#  varillas(0.05, y_bx(9), 3.95, y_bx(9), n_bx, 10, s_x, 90, 90, 1)
#  varillas(5.5 + x_by(7), 0.05, 5.5 + x_by(7), 4.75, n_by, 10, s_y, 90, 90, 1)
#  texto(2.0, 5.15, "bottom, in x (outer layer)", 2.5, "c")
#  texto(7.5, 5.15, "bottom, in y (inner layer)", 2.5, "c")
#  cota(0, -0.45, 4.0, -0.45, -0.05, "4.00")
#  cota(5.5, -0.45, 9.5, -0.45, -0.05, "4.00")
#  cota(-0.45, 0, -0.45, 4.8, 0.05, "4.80")
#fin
#: **How to read the top reinforcement.** There is steel at the top only at the four corners: a square of l/5 = 0.96 m (red dashes) with @{n_be} Ø10 bars in x and @{n_be} in y (red lines). The centre of the slab carries no top steel because there the moment is positive everywhere (tension at the bottom).
#dibujo("Top reinforcement: corner reinforcement (ACI 318-19 §8.7.3)", ud = m, escala = auto, cotas = m, alto = 175)
#  rect(0, 0, 4.0, 4.8, "gruesa")
#  rect(0, 0, l_esq, l_esq, "trazos rojo")
#  rect(4.0 - l_esq, 0, l_esq, l_esq, "trazos rojo")
#  rect(0, 4.8 - l_esq, l_esq, l_esq, "trazos rojo")
#  rect(4.0 - l_esq, 4.8 - l_esq, l_esq, l_esq, "trazos rojo")
#  rect(0.03, p_e, l_esq - 0.03, 0, "media rojo")
#  rect(p_e, 0.03, 0, l_esq - 0.03, "media rojo")
#  rect(4.0 - l_esq, p_e, l_esq - 0.03, 0, "media rojo")
#  rect(4.0 - p_e, 0.03, 0, l_esq - 0.03, "media rojo")
#  rect(0.03, 4.8 - p_e, l_esq - 0.03, 0, "media rojo")
#  rect(p_e, 4.8 - l_esq, 0, l_esq - 0.03, "media rojo")
#  rect(4.0 - l_esq, 4.8 - p_e, l_esq - 0.03, 0, "media rojo")
#  rect(4.0 - p_e, 4.8 - l_esq, 0, l_esq - 0.03, "media rojo")
#  texto(2.0, 2.65, "in each corner, top:", 2.5, "c", estilo = "rojo")
#  texto(2.0, 2.25, "{n_be:0} Ø10 @ {s_e:1} cm en x y en y", 2.5, "c", estilo = "rojo")
#  texto(2.0, 1.85, "centre: no top steel", 2.4, "c")
#  cota(0, -0.45, l_esq, -0.45, -0.05, "{l_esq:2}")
#  cota(0, -0.45, 4.0, -0.45, -0.40, "4.00")
#  cota(-0.45, 0, -0.45, 4.8, 0.05, "4.80")
#  cota(4.45, 4.8 - l_esq, 4.45, 4.8, -0.05, "{l_esq:2}")
#fin
#: **Section A-A with the reinforcement** (vertical exaggerated ×5 so the layers can be seen). How to read it: the dots are the cut bars in y (inner bottom layer); the bottom line is a bar in x (outer layer, the one with the greater effective depth d_{x}); at the top there is steel only at the corners (red dashes of l/5 on each side). The labels are placed outside the section.
#dibujo("Section A-A: steel layers (vertical ×5)", ud = m, ancho = 180, vert = 5, cotas = m)
#  seccion(0, 0, 4.0, 0.15)
#  varilla(0.03, 0.025, 3.97, 0.025, 10, 90, 90, "", 1)
#  fila(x_by(1), 0.037, x_by(n_by), 0.037, n_by, 10, s_y, 1, rotulo = "no")
#  varilla(0.03, 0.12, l_esq, 0.12, 10, -90, 0, "", 1, estilo = "rojo")
#  varilla(4.0 - l_esq, 0.12, 3.97, 0.12, 10, 0, -90, "", 1, estilo = "rojo")
#  texto(2.0, -0.035, "bottom: Ø10 @ {s_x:1} cm in x (line) and Ø10 @ {s_y:1} cm in y (dots)", 2.3, "c")
#  texto(0.0, 0.19, "top, corner: Ø10 @ {s_e:1} cm", 2.3, "i", estilo = "rojo")
#  texto(4.0, 0.19, "corner", 2.3, "d", estilo = "rojo")
#  cota(0, -0.11, 4.0, -0.11, -0.02, "4.00")
#  texto(4.12, 0.075, "h = 0.15", 2.3, "i")
#fin

## 11 · Shear (the beams receive the slab)
#: The slab supported on beams has no punching (there are no columns): one-way shear at the edge is checked. The edge reaction per metre is that of the node divided by its tributary width; the largest is at the middle of each side:
v_ux = R_j((n_y/2)·n_n + 1)/h_y [tonf/m] 'reaction per metre at the middle of edge x = 0 (supports the short span)
v_uy = R_j(n_x/2 + 1)/h_x [tonf/m] 'reaction per metre at the middle of edge y = 0
R_esq = R_j(1) [tonf] 'corner reaction (negative: the beam holds the corner, which wants to lift)
#: Concrete shear strength without stirrups, ACI 318-19 Table 22.5.5.1 (c), in MPa and mm: V_c = 0.66·λ_s·ρ_w^(1/3)·√f'c·b·d, with λ_s = √(2/(1 + 0.004·d)) ≤ 1:
d_mm = 10·d_x [mm] 'effective depth in mm
λ_s = min(sqrt(2/(1 + 0.004·d_mm)), 1) 'size effect
ρ_w = A_px/(100·d_x) 'ratio of the steel provided in x
V_cN = 0.66·λ_s·ρ_w^(1/3)·sqrt(f_cM)·1000·d_mm/1000 [kN/m] 'nominal strength per metre
V_cmax = 0.42·sqrt(f_cM)·1000·d_mm/1000 [kN/m] 'ACI 318-19 §22.5.5.1.1 cap
V_cd = 0.75·min(V_cN, V_cmax)/9.80665 [tonf/m] 'design strength (φ = 0.75)
r_V = max(v_ux, v_uy)/V_cd 'demand/capacity (≤ 1 passes; conservative: the reaction at the axis, not at d from the face)
#: **How to read it.** The slab works in shear with margin (r_V well below 1): in solid slabs on beams shear almost never governs. The NEGATIVE reaction at the corners is the force with which the beam has to hold the corner (the supported slab wants to lift them, because of the twisting moment Mxy): it is anchored with the top corner reinforcement and the beam-slab continuity.

## 12 · Minimum thickness (ACI 318-19 Table 8.3.1.2, slab with stiff beams, α_fm > 2)
l_n = l_y - 0.30 [m] 'long clear span (30 cm beams)
β_l = (l_y - 0.30)/(l_x - 0.30) 'ratio of clear spans
h_min = max(1000·l_n·(0.8 + f_y·0.0980665/1400)/(36 + 9·β_l), 90) [mm] 'minimum thickness so that deflections need not be computed
#: 15 cm > h_min: it passes without computing the long-term deflection.

## 13 · Summary
#hide
r_wc = round(w_c, 4)
r_wN = round(w_N, 4)
r_Mx = round(M_xc, 4)
r_MxN = round(M_xN, 4)
r_My = round(M_yc, 4)
r_MyN = round(M_yN, 4)
r_Mxy = round(M_xy1, 4)
r_R = round(R_t, 4)
r_Q = round(Q_t, 4)
r_Ai = round(A_xinf, 2)
r_Ayi = round(A_yinf, 2)
r_As = round(A_xsup, 2)
r_Ays = round(A_ysup, 2)
r_dw = round(d_w, 10)
#show
#| Magnitud | Elementos finitos (cáscara CSI) | Referencia | Diferencia |
#|---|---:|---:|---:|
#| flecha del centro [mm] | @{r_wc} | Navier @{r_wN} | @{e_w} % |
#| Mxx del centro [tonf·m/m] | @{r_Mx} | Navier @{r_MxN} | @{e_Mx} % |
#| Myy del centro [tonf·m/m] | @{r_My} | Navier @{r_MyN} | @{e_My} % |
#| Mxy de la esquina [tonf·m/m] | @{r_Mxy} | — | — |
#| suma de reacciones [tonf] | @{r_R} | q_u·l_x·l_y = @{r_Q} | @{d_R} % |
#| flecha cáscara − placa sola [mm] | @{r_dw} | 0 | — |
#| acero abajo x / y requerido [cm²/m] | @{r_Ai} / @{r_Ayi} | mínimo 2.70 | manda el mínimo |
#| acero arriba x / y requerido (esquinas) [cm²/m] | @{r_As} / @{r_Ays} | ACI §8.7.3: = el de abajo | esquinas |
#: **Reinforcement:** bottom Ø10 @ @{s_x} cm in x and Ø10 @ @{s_y} cm in y over the whole slab; at the top, in each corner, a square of @{l_esq} m with Ø10 @ @{s_e} cm in both directions. **Next:** several continuous panels (beams and columns), where the negative moments over the interior supports and the column and middle strips appear.
