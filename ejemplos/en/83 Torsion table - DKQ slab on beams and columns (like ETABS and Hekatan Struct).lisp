# Torsion table: DKQ slab on beams and columns, the whole operation
#numerico

#: The Hekatan Struct **Torsion Table** benchmark, solved here from start to finish: 6 × 6 m, 10 cm slab on 4 perimeter beams V30×50 and 4 columns C40×40 of 4 m, with live load of 0.5 tonf/m². It is the same model as the ETABS e2k, node by node (5 × 5 mesh, no diaphragm, pinned base).
#: **Elements** (those of ETABS *Shell-Thin* and Hekatan Struct): slab = **Q6** membrane (Wilson incompatible modes) + **DKQ** bending (Batoz, discrete Kirchhoff) + a very soft in-plane rotation; beams and columns = **Timoshenko** 3D bar, 6 degrees of freedom per node.
#: **Units:** kN and m when calculating; the results are converted to tonf by dividing by g = 9.80665.
#: **Order:** in part **A** everything is derived in symbols, only once: shape functions, Jacobian, Gauss and the stiffness matrices of each formulation. In part **B** the numbers enter and only results are shown.

## A · Algebraic formulation (only once)
#: All in symbols: the engine differentiates, integrates and multiplies the matrices. The numbers only enter in part B. Each stiffness matrix is assembled ONCE here; afterwards only their results are used.

### A.1 · Shape functions of the Q4 quadrilateral
#: In the natural square −1 ≤ ξ, η ≤ 1. Each equals 1 at its node and 0 at the other three (nodes 1 to 4 counterclockwise, from the corner (−1, −1)):
N_1 = Expand{(1-xi)*(1-eta)/4}
N_2 = Expand{(1+xi)*(1-eta)/4}
N_3 = Expand{(1+xi)*(1+eta)/4}
N_4 = Expand{(1-xi)*(1+eta)/4}
#: They add up to 1 at every point (partition of unity): this way the element moves as a rigid body without deforming.
N_suma = Simplify{(1-xi)*(1-eta)/4 + (1+xi)*(1-eta)/4 + (1+xi)*(1+eta)/4 + (1-xi)*(1+eta)/4}
#: Their derivatives in natural coordinates:
dN_ξ = Simplify{[Partial{(1-xi)*(1-eta)/4 @ xi}, Partial{(1+xi)*(1-eta)/4 @ xi}, Partial{(1+xi)*(1+eta)/4 @ xi}, Partial{(1-xi)*(1+eta)/4 @ xi}]}
dN_η = Simplify{[Partial{(1-xi)*(1-eta)/4 @ eta}, Partial{(1+xi)*(1-eta)/4 @ eta}, Partial{(1+xi)*(1+eta)/4 @ eta}, Partial{(1-xi)*(1+eta)/4 @ eta}]}

### A.2 · Jacobian
#: The geometry is interpolated with the same functions (isoparametric). A square element of side 2·a centered at the origin has its nodes at x = ∓a, y = ∓a:
x_ξ = Simplify{a*(-(1-xi)*(1-eta)/4 + (1+xi)*(1-eta)/4 + (1+xi)*(1+eta)/4 - (1-xi)*(1+eta)/4)}
y_η = Simplify{a*(-(1-xi)*(1-eta)/4 - (1+xi)*(1-eta)/4 + (1+xi)*(1+eta)/4 + (1-xi)*(1+eta)/4)}
J = Simplify{[Partial{a*xi @ xi}, Partial{a*xi @ eta}; Partial{a*eta @ xi}, Partial{a*eta @ eta}]}
det_J = Simplify{det([a, 0; 0, a])}
#: Chain rule: ∂N/∂x = (1/a)·∂N/∂ξ and ∂N/∂y = (1/a)·∂N/∂η; and the area: dx·dy = det J·dξ·dη.

### A.3 · Gauss quadrature
#: The integral is replaced by a sum at the points ξ = ±1/√3 with weight 1. With 2 points it is EXACT up to degree 3:
I_2 = Area{xi^2 @ xi = -1 : 1}
G_2 = Simplify{(1/sqrt(3))^2 + (-1/sqrt(3))^2}
#: With degree 4 it no longer is (this matters in the DKQ, which has terms (2 − ξ² − η²)²):
I_4 = Area{xi^4 @ xi = -1 : 1}
G_4 = Simplify{(1/sqrt(3))^4 + (-1/sqrt(3))^4}
#: In 2D it is the double integral, with 2 × 2 = 4 points:
I_22 = Area{Area{xi^2*eta^2 @ xi = -1 : 1} @ eta = -1 : 1}
G_22 = Simplify{4*(1/sqrt(3))^2*(1/sqrt(3))^2}

### A.4 · Q6 membrane (8 × 8)
#: **Strains:** ε = [∂u/∂x; ∂v/∂y; ∂u/∂y + ∂v/∂x] = B_{m}·[u₁ v₁ u₂ v₂ u₃ v₃ u₄ v₄]. **Constitutive law** (plane stress):
D_m = Simplify{E/(1-nu^2)*[1, nu, 0; nu, 1, 0; 0, 0, (1-nu)/2]}
#: **B matrix**: row 1 = ∂N/∂x under each u; row 2 = ∂N/∂y under each v; row 3 = the two crossed. With the chain rule of A.2:
B_m(xi, eta) = Simplify{[-(1-eta)/(4*a), 0, (1-eta)/(4*a), 0, (1+eta)/(4*a), 0, -(1+eta)/(4*a), 0; 0, -(1-xi)/(4*a), 0, -(1+xi)/(4*a), 0, (1+xi)/(4*a), 0, (1-xi)/(4*a); -(1-xi)/(4*a), -(1-eta)/(4*a), -(1+xi)/(4*a), (1-eta)/(4*a), (1+xi)/(4*a), (1+eta)/(4*a), (1-xi)/(4*a), -(1+eta)/(4*a)]}
#: **Wilson incompatible modes**: u = Σ Nᵢ·uᵢ + (1 − ξ²)·α₁ + (1 − η²)·α₂, and v with α₃, α₄. Their derivatives give another matrix G (3 × 4):
G_m(xi, eta) = Simplify{[Partial{1-xi^2 @ xi}/a, 0, 0, 0; 0, 0, 0, Partial{1-eta^2 @ eta}/a; 0, Partial{1-eta^2 @ eta}/a, Partial{1-xi^2 @ xi}/a, 0]}
#: **Stiffness**: K = t·∫∫ Bᵀ·D·B·det J dξ dη. The integrands are of degree 2: 2 × 2 Gauss gives the same as the exact integral. To make them readable, each matrix is written with its common factor outside: K_{uu} = E·t/(24·(1 − ν²))·K̂_{uu}, and K_{uα}, K_{αα} with E·t/(3·(1 − ν²)).
Kn_uu = Simplify{24*(1-nu^2)/(E*t)*t*a^2*Area{Area{transpose(B_m(xi, eta))*D_m*B_m(xi, eta) @ xi = -1 : 1} @ eta = -1 : 1}}
Kn_ua = Simplify{3*(1-nu^2)/(E*t)*t*a^2*Area{Area{transpose(B_m(xi, eta))*D_m*G_m(xi, eta) @ xi = -1 : 1} @ eta = -1 : 1}}
Kn_aa = Simplify{3*(1-nu^2)/(E*t)*t*a^2*Area{Area{transpose(G_m(xi, eta))*D_m*G_m(xi, eta) @ xi = -1 : 1} @ eta = -1 : 1}}
#: **Static condensation**: the α are not node degrees; they are eliminated with K_{αα}·α = −K_{αu}·u, leaving K_{Q6} = K_{uu} − K_{uα}·K_{αα}⁻¹·K_{αu}. With the factors above (their ratio is 24/3 = 8), K_{Q6} = E·t/(24·(1 − ν²))·K̂_{Q6} with
Kn_Q6 = Simplify{Kn_uu - 8*Kn_ua*inv(Kn_aa)*transpose(Kn_ua)}

### A.5 · DKQ plate (12 × 12)
#: **Discrete Kirchhoff** (Batoz and Tahar 1982): the rotations β are interpolated with 8 nodes and the condition β = ∇w is imposed only at the nodes and at the midpoints of the sides. The curvatures κ = [∂β_{x}/∂x; ∂β_{y}/∂y; ∂β_{x}/∂y + ∂β_{y}/∂x] become B_{f}·u with u = [w₁ β_{x1} β_{y1} …]. **Constitutive law** (D = E·t³/(12·(1 − ν²))):
D_f = Simplify{D*[1, nu, 0; nu, 1, 0; 0, 0, (1-nu)/2]}
D_t = Simplify{E*t^3/(12*(1-nu^2))}
#: **B matrix** of the rectangular DKQ of side d (that of Hekatan Struct, python_dkq.py):
B_f(xi, eta) = Simplify{[3*xi*(1-eta)/d^2, 0, (1-eta)*(3*xi-1)/(2*d), -3*xi*(1-eta)/d^2, 0, (1-eta)*(1+3*xi)/(2*d), -3*xi*(1+eta)/d^2, 0, (1+eta)*(1+3*xi)/(2*d), 3*xi*(1+eta)/d^2, 0, (1+eta)*(3*xi-1)/(2*d); 3*(1-xi)*eta/d^2, -(1-xi)*(3*eta-1)/(2*d), 0, 3*(1+xi)*eta/d^2, -(1+xi)*(3*eta-1)/(2*d), 0, -3*(1+xi)*eta/d^2, -(1+xi)*(1+3*eta)/(2*d), 0, -3*(1-xi)*eta/d^2, -(1-xi)*(1+3*eta)/(2*d), 0; 3*(2-xi^2-eta^2)/(2*d^2), -(1-eta)*(1+3*eta)/(4*d), (1-xi)*(1+3*xi)/(4*d), -3*(2-xi^2-eta^2)/(2*d^2), (1-eta)*(1+3*eta)/(4*d), (1+xi)*(1-3*xi)/(4*d), 3*(2-xi^2-eta^2)/(2*d^2), -(1+eta)*(3*eta-1)/(4*d), (1+xi)*(3*xi-1)/(4*d), -3*(2-xi^2-eta^2)/(2*d^2), -(1+eta)*(1-3*eta)/(4*d), -(1-xi)*(1+3*xi)/(4*d)]}
#: **Stiffness with 2 × 2 Gauss** (det J = (d/2)²), exactly as the program calculates it. It is not the exact integral: the term (2 − ξ² − η²)² is of degree 4 (see A.3). With the common factor outside, K_{DKQ} = D/(24·d²)·K̂_{DKQ}:
Kn_DKQ = Simplify{24*d^2/D*(d/2)^2*(transpose(B_f(-1/sqrt(3), -1/sqrt(3)))*D_f*B_f(-1/sqrt(3), -1/sqrt(3)) + transpose(B_f(1/sqrt(3), -1/sqrt(3)))*D_f*B_f(1/sqrt(3), -1/sqrt(3)) + transpose(B_f(1/sqrt(3), 1/sqrt(3)))*D_f*B_f(1/sqrt(3), 1/sqrt(3)) + transpose(B_f(-1/sqrt(3), 1/sqrt(3)))*D_f*B_f(-1/sqrt(3), 1/sqrt(3)))}
#: The DKQ uses β_{x} = θ_{y} and β_{y} = −θ_{x}: in the slab it is multiplied by P = diag(1, −1, −1, …) on both sides, K_{plate} = P·K_{DKQ}·P.

### A.6 · In-plane rotation (drilling)
#: The flat shell has no stiffness of its own for θz. Hekatan Struct puts a spring of 10⁻⁶ times the average of the membrane diagonal:
#: k_{θz} = 10⁻⁶ · (sum of the diagonal of K_{Q6}) / 8, placed on the θz of each node.
#: This way the slab element is 24 × 24: at each node, u and v from K_{Q6}, w, θx and θy from K_{plate}, and θz from the spring.

### A.7 · Timoshenko 3D bar (12 × 12)
#: Four physics that do not mix, in s = x/L from 0 to 1. **Axial** and **torsion**: linear functions.
N_ax = Simplify{[1-s, s]}
k_ax = Simplify{E*A_b/L*Area{transpose([Partial{1-s @ s}, Partial{s @ s}])*[Partial{1-s @ s}, Partial{s @ s}] @ s = 0 : 1}}
k_tor = Simplify{G*J_b/L*Area{transpose([Partial{1-s @ s}, Partial{s @ s}])*[Partial{1-s @ s}, Partial{s @ s}] @ s = 0 : 1}}
#: **Bending** (Euler-Bernoulli): the four Hermite cubics, displacement and rotation at each end.
N_fl = Simplify{[1-3*s^2+2*s^3, L*(s-2*s^2+s^3), 3*s^2-2*s^3, L*(s^3-s^2)]}
B_fl = Simplify{[Partial{Partial{1-3*s^2+2*s^3 @ s} @ s}, Partial{Partial{L*(s-2*s^2+s^3) @ s} @ s}, Partial{Partial{3*s^2-2*s^3 @ s} @ s}, Partial{Partial{L*(s^3-s^2) @ s} @ s}]}
k_EB = Simplify{E*I/L^3*Area{transpose(B_fl)*B_fl @ s = 0 : 1}}
#: **Timoshenko**: with shear deformation (shear area A_{s} = 5/6·A), the same positions with the parameter φ:
φ_s = Simplify{12*E*I/(G*A_s*L^2)}
k_Ti = Simplify{E*I/(L^3*(1+phi))*[12, 6*L, -12, 6*L; 6*L, (4+phi)*L^2, -6*L, (2-phi)*L^2; -12, -6*L, 12, -6*L; 6*L, (2-phi)*L^2, -6*L, (4+phi)*L^2]}
#: With φ = 0 it returns exactly to that of Euler-Bernoulli:
k_Ti0 = Simplify{E*I/(L^3*(1+0))*[12, 6*L, -12, 6*L; 6*L, (4+0)*L^2, -6*L, (2-0)*L^2; -12, -6*L, 12, -6*L; 6*L, (2-0)*L^2, -6*L, (4+0)*L^2]}
#: In the 12 × 12 matrix (order u, v, w, θx, θy, θz of each end): k_{ax} goes in (u₁, u₂), k_{tor} in (θx₁, θx₂), bending with I_{z} in (v, θz) and with I_{y} in (w, θy); in this last plane the cross terms change sign because θy = −∂w/∂x.

### A.8 · From local to global axes
#: Each bar is rotated with its direction cosines. In a vertical column x_{local} = global Z:
λ_c = Simplify{[0, 0, 1; 0, 1, 0; -1, 0, 0]}
#: and the 12 × 12 matrix is the 3 × 3 one repeated 4 times on the diagonal:
#noc
K_global = transpose(Rot)·k·Rot
#equ
#: The slab is flat and its axes are the global ones: its matrix is not rotated.

### A.9 · From the Gauss points to the nodes
#: The moments are calculated where B is good, at the 4 Gauss points: M = D_{f}·B_{f}(ξ_{g}, η_{g})·u_{e}. To take them to the nodes, the square of the Gauss points is seen as a Q4 whose corners are at ±1/√3: the nodes fall at ±√3 of that Q4. The first row of the extrapolation matrix, which is node 1 at (−√3, −√3):
A_1 = Simplify{[(1+sqrt(3))*(1+sqrt(3))/4, (1-sqrt(3))*(1+sqrt(3))/4, (1-sqrt(3))*(1-sqrt(3))/4, (1+sqrt(3))*(1-sqrt(3))/4]}
#: The other three rows are the same, rotated. At each node the largest |M| of the elements that meet there is stored (the envelope).

## B · Numerical results

### B.1 · Data
L_x = 6 'slab span in x and in y (m)
H_c = 4 'column height (m)
t = 0.1 'slab thickness (m)
E = 24.85e6 'modulus of elasticity (kN/m²)
ν = 0.2 'Poisson's ratio
G_c = E/(2·(1 + ν)) 'shear modulus (kN/m²)
g_0 = 9.80665 'kN per tonf
b_c = 0.4 'column: width (m)
h_c = 0.4 'column: depth (m)
b_v = 0.3 'beam: width (m)
h_v = 0.5 'beam: depth (m)
o_f = h_v 'rigid arm at the column top: the moment is reported at the beam face (m)
#: **Sections.** J with the Saint-Venant formula for a rectangle, with the CUBE of the short side: J = β·a·b³, β = 1/3 − 0.21·(b/a)·(1 − (b/a)⁴/12).
A_c = b_c·h_c
I_yc = h_c·b_c^3/12
I_zc = b_c·h_c^3/12
J_c = stv(b_c, h_c)
A_v = b_v·h_v
I_yv = b_v·h_v^3/12 'strong inertia of the beam (vertical bending)
I_zv = h_v·b_v^3/12
J_v = stv(b_v, h_v)

### B.2 · Mesh
#: 5 × 5 slab elements of 1.2 m (the ETABS automesh at ≤ 1.25 m). Nodes: 4 at the base of the columns and 36 in the slab, at height H.
n_e = 5 'elements per side
n_1 = n_e + 1 'nodes per side
d = L_x/n_e 'element side (m)
n_j = 4 + n_1^2 'nodes
n_d = 6·n_j 'degrees of freedom
#: The slab node of column i and row j of the mesh (i, j = 0 … 5):
p(i, j) = 5 + j·n_1 + i
#hide
X_n = zeros(n_j, 3)
X_n(2, 1) = L_x
X_n(3, 1) = L_x
X_n(3, 2) = L_x
X_n(4, 2) = L_x
for j = 0:n_e
  for i = 0:n_e
    X_n(p(i, j), 1) = i·d
    X_n(p(i, j), 2) = j·d
    X_n(p(i, j), 3) = H_c
  end
end
e_s = zeros(n_e^2, 4)
for j = 0:n_e - 1
  for i = 0:n_e - 1
    k = j·n_e + i + 1
    e_s(k, 1) = p(i, j)
    e_s(k, 2) = p(i + 1, j)
    e_s(k, 3) = p(i + 1, j + 1)
    e_s(k, 4) = p(i, j + 1)
  end
end
c_e = [1, p(0, 0); 2, p(n_e, 0); 3, p(n_e, n_e); 4, p(0, n_e)]
b_e = zeros(4·n_e, 2)
for i = 0:n_e - 1
  b_e(i + 1, 1) = p(i, 0)
  b_e(i + 1, 2) = p(i + 1, 0)
  b_e(n_e + i + 1, 1) = p(n_e, i)
  b_e(n_e + i + 1, 2) = p(n_e, i + 1)
  b_e(2·n_e + i + 1, 1) = p(i, n_e)
  b_e(2·n_e + i + 1, 2) = p(i + 1, n_e)
  b_e(3·n_e + i + 1, 1) = p(0, i)
  b_e(3·n_e + i + 1, 2) = p(0, i + 1)
end
x_j = zeros(n_1^2, 1)
y_j = zeros(n_1^2, 1)
for k = 1:n_1^2
  x_j(k) = X_n(k + 4, 1)
  y_j(k) = X_n(k + 4, 2)
end
e_j = e_s - 4
s_j = [1; n_1; n_1^2; n_1^2 - n_e]
#show
#: Slab plan: 25 elements; the columns are at the 4 corners and the beams run along the edge.
#malla(x_j, y_j, e_j, s_j)
n_s = n_e^2 'slab elements
n_c = 4 'columns
n_b = 4·n_e 'beam spans (each beam is split at the slab nodes)

### B.3 · Element matrices
#: They are the formulas of part A with the table data. They are not written again: one term of each is checked against its algebraic expression.
a_e = d/2 'half side of the slab element (m)
#hide
K_m = memb_q6(E, ν, t, a_e)
D_b = E·t^3/(12·(1 - ν^2))·[1, ν, 0; ν, 1, 0; 0, 0, (1 - ν)/2]
K_b = dkq_K(D_b, d)
P_d = zeros(12, 12)
for k = 1:4
  P_d(3·k - 2, 3·k - 2) = 1
  P_d(3·k - 1, 3·k - 1) = -1
  P_d(3·k, 3·k) = -1
end
K_p = P_d·K_b·P_d
s_m = 0
for k = 1:8
  s_m = s_m + K_m(k, k)
end
#show
#: **Q6 membrane** (A.4):
K_m11 = K_m(1, 1) 'from the program (kN/m)
K_m11f = E·t·(11 - 3·ν - 2·ν^2)/(24·(1 - ν^2)) 'formula K_Q6(1, 1)
#: **DKQ plate** (A.5):
D_p = E·t^3/(12·(1 - ν^2)) 'bending stiffness (kN·m)
K_b11 = K_b(1, 1) 'from the program (kN/m)
K_b11f = 10·D_p/d^2 'formula K_DKQ(1, 1), 2 × 2 Gauss
K_b11e = (51 - ν)·D_p/(5·d^2) 'with the exact integral: the DKQ does NOT use it
#: **In-plane rotation** (A.6):
k_θ = s_m/(8·10^6) 'θz spring (kN·m/rad)
#hide
K_s = zeros(24, 24)
for a = 1:4
  for b = 1:4
    for r = 1:2
      for c = 1:2
        K_s(6·(a - 1) + r, 6·(b - 1) + c) = K_m(2·(a - 1) + r, 2·(b - 1) + c)
      end
    end
    for r = 1:3
      for c = 1:3
        K_s(6·(a - 1) + 2 + r, 6·(b - 1) + 2 + c) = K_p(3·(a - 1) + r, 3·(b - 1) + c)
      end
    end
  end
  K_s(6·a, 6·a) = k_θ
end
k_col = frame_K(E, G_c, A_c, I_yc, I_zc, J_c, H_c)
k_vig = frame_K(E, G_c, A_v, I_yv, I_zv, J_v, d)
#show
#: Timoshenko **column** (A.7), L = H:
φ_c = 12·E·I_zc/(G_c·5/6·A_c·H_c^2) 'shear parameter
k_c11 = k_col(1, 1) 'axial, from the program
k_c11f = E·A_c/H_c 'formula E·A/L
k_c22 = k_col(2, 2) 'bending, from the program
k_c22f = 12·E·I_zc/(H_c^3·(1 + φ_c)) 'formula 12·E·I/(L³·(1 + φ))
#: **Beam span** (L = d), vertical bending with I_{y} and torsion:
φ_v = 12·E·I_yv/(G_c·5/6·A_v·d^2)
k_v33 = k_vig(3, 3) 'from the program
k_v33f = 12·E·I_yv/(d^3·(1 + φ_v)) 'formula
k_v44 = k_vig(4, 4) 'torsion, from the program
k_v44f = G_c·J_v/d 'formula G·J/L

### B.4 · Assembly and supports
d_n(j) = 6·(j - 1) + (1:6)
#hide
K = zeros(n_d, n_d)
#show
#: Slab: the 25 elements are equal and are not rotated; they are added into the rows and columns of their 4 nodes.
for e = 1:n_s
  g = [d_n(e_s(e, 1)), d_n(e_s(e, 2)), d_n(e_s(e, 3)), d_n(e_s(e, 4))]
  K(g, g) = K(g, g) + K_s
end
#: Columns and beams: they are rotated to global axes before being added. The bars go in a single list: 1 to 4 the columns, 5 to 24 the beam spans.
#hide
n_r = n_c + n_b
e_f = zeros(n_r, 2)
for e = 1:n_r
  if e <= n_c
    e_f(e, 1) = c_e(e, 1)
    e_f(e, 2) = c_e(e, 2)
  else
    e_f(e, 1) = b_e(e - n_c, 1)
    e_f(e, 2) = b_e(e - n_c, 2)
  end
end
#show
for e = 1:n_r
  g = [d_n(e_f(e, 1)), d_n(e_f(e, 2))]
  R_f = rot_frame(X_n(e_f(e, 1), :), X_n(e_f(e, 2), :))
  if e <= n_c
    K(g, g) = K(g, g) + R_f'·k_col·R_f
  else
    K(g, g) = K(g, g) + R_f'·k_vig·R_f
  end
end
#: **Supports.** Column base pinned (ETABS: RESTRAINT "UX UY UZ"): u, v, w are removed from nodes 1 to 4; their rotations stay free.
#hide
l_f = zeros(n_d - 12, 1)
k = 0
for i = 1:n_d
  if i > 24 || mod(i - 1, 6) >= 3
    k = k + 1
    l_f(k) = i
  end
end
#show
n_q = k 'free equations

### B.5 · ETABS load cases and the UDCon2 combination
#: The three patterns of the e2k and the design combination **UDCon2** ("Dead + Live [Strength]"): 1.2·Dead + 1.6·Live + 1.2·SCP.
γ_c = 2.40277·g_0 'unit weight of concrete (kN/m³)
q_L = 0.5·g_0 'Live: 0.5 tonf/m² (kN/m²)
q_S = 1.0·g_0 'SCP (permanent superimposed load): 1 tonf/m² (kN/m²)
#: **Live and SCP** go on the slab nodes by tributary area: d² in the interior, d²/2 at the edge, d²/4 at the corner.
#hide
F_L = zeros(n_d, 1)
F_S = zeros(n_d, 1)
F_D = zeros(n_d, 1)
for j = 0:n_e
  for i = 0:n_e
    f_a = 1
    if i == 0 || i == n_e
      f_a = f_a/2
    end
    if j == 0 || j == n_e
      f_a = f_a/2
    end
    F_L(6·(p(i, j) - 1) + 3) = -q_L·d^2·f_a
    F_S(6·(p(i, j) - 1) + 3) = -q_S·d^2·f_a
    F_D(6·(p(i, j) - 1) + 3) = -γ_c·t·d^2·f_a
  end
end
#show
#: **Dead** is the self-weight, as ETABS loads it: the slab over its whole area; each beam only over its **clear span**, between the column faces (from b_{c}/2 to L − b_{c}/2); and each column over its whole height. On the bars the load goes with its **fixed-end loads** (the Hermite functions of A.7 integrated over the loaded span, with moments at the nodes), and the bar force is f = k·Rot·u − f_{fixed}.
w_v = γ_c·A_v 'weight of the beam (kN/m)
W_c = γ_c·A_c·H_c 'weight of one column (kN)
#hide
Q_D = zeros(n_r, 12)
for e = 1:n_r
  if e <= n_c
    f_g = zeros(12, 1)
    f_g(3) = -W_c/2
    f_g(9) = -W_c/2
    R_f = rot_frame(X_n(e_f(e, 1), :), X_n(e_f(e, 2), :))
    q_e = R_f·f_g
  else
    i_v = mod(e - n_c - 1, n_e)
    a_1 = max(0, b_c/2 - i_v·d)
    b_1 = min(d, L_x - b_c/2 - i_v·d)
    q_e = fef_v(w_v, d, a_1, b_1)
    R_f = rot_frame(X_n(e_f(e, 1), :), X_n(e_f(e, 2), :))
  end
  Q_D(e, :) = transpose(q_e)
  g = [d_n(e_f(e, 1)), d_n(e_f(e, 2))]
  F_D(g) = F_D(g) + R_f'·q_e
end
#show
#: Total loads (tonf), the sum of the three things in each pattern:
Q_Dt = (γ_c·t·L_x^2 + 4·w_v·(L_x - b_c) + 4·W_c)/g_0 'Dead
Q_Lt = q_L·L_x^2/g_0 'Live
Q_St = q_S·L_x^2/g_0 'SCP
#: **Solution**: Cholesky on the free equations, one load vector per pattern. The combination is linear: U of UDCon2 = 1.2·U_{D} + 1.6·U_{L} + 1.2·U_{S}.
#hide
U_D = zeros(n_d, 1)
U_L = zeros(n_d, 1)
U_S = zeros(n_d, 1)
#show
U_D(l_f) = clsolve(K(l_f, l_f), F_D(l_f))
U_L(l_f) = clsolve(K(l_f, l_f), F_L(l_f))
U_S(l_f) = clsolve(K(l_f, l_f), F_S(l_f))
U_C = 1.2·U_D + 1.6·U_L + 1.2·U_S
F_C = 1.2·F_D + 1.6·F_L + 1.2·F_S

### B.6 · Slab results (UDCon2)
#: Moments with the DKQ recovery (A.9): M = D_{f}·B(ξ, η)·u_{e} at the 4 Gauss points, extrapolated to the nodes; at each node, the envelope of the elements that meet there (like the ETABS element-joint table).
s_3 = sqrt(3)
A_x = [1 + s_3/2, -0.5, 1 - s_3/2, -0.5; -0.5, 1 + s_3/2, -0.5, 1 - s_3/2; 1 - s_3/2, -0.5, 1 + s_3/2, -0.5; -0.5, 1 - s_3/2, -0.5, 1 + s_3/2]
#hide
G_D = losa_M(U_D, e_s, P_d, D_b, d, n_e, A_x, g_0)
G_L = losa_M(U_L, e_s, P_d, D_b, d, n_e, A_x, g_0)
G_S = losa_M(U_S, e_s, P_d, D_b, d, n_e, A_x, g_0)
G_C = losa_M(U_C, e_s, P_d, D_b, d, n_e, A_x, g_0)
W_g = zeros(n_1, n_1)
M_xg = zeros(n_1, n_1)
M_yg = zeros(n_1, n_1)
M_sg = zeros(n_1, n_1)
for i = 0:n_e
  for j = 0:n_e
    W_g(i + 1, j + 1) = 1000·U_C(6·(p(i, j) - 1) + 3)
    M_xg(i + 1, j + 1) = G_C(i + 1, j + 1)
    M_yg(i + 1, j + 1) = G_C(n_1 + i + 1, j + 1)
    M_sg(i + 1, j + 1) = G_C(2·n_1 + i + 1, j + 1)
  end
end
#show
#: **Deflection w** in mm (row = y, column = x). Between nodes it is interpolated with the bilinear shape functions of the Q4, exact at the nodes; move the cursor over each map to read the value:
transpose(W_g)
w_z(x, y) = bil(W_g, x, y, d, n_e)
#map(w_z(x, y), [0 L_x], [0 L_x])
#: **Mxx** in tonf·m/m: negative at the edge, where the beam half-fixes it.
transpose(M_xg)
M_xx(x, y) = bil(M_xg, x, y, d, n_e)
#map(M_xx(x, y), [0 L_x], [0 L_x])
#: **Myy**: the same rotated 90° (the table is symmetric).
M_yy(x, y) = bil(M_yg, x, y, d, n_e)
#map(M_yy(x, y), [0 L_x], [0 L_x])
#: **Mxy**, the torsion of the slab: maximum near the corners, where the slab warps over the columns.
transpose(M_sg)
M_xy(x, y) = bil(M_sg, x, y, d, n_e)
#map(M_xy(x, y), [0 L_x], [0 L_x])

### B.7 · Forces in columns and beams (UDCon2)
#: In each bar f = k·Rot·u_{e} − f_{fixed}, in local axes: P, V₂, V₃, T, M₂, M₃ at node i and then at j (tonf, tonf·m). Rows 1 to 4 the columns, 5 to 24 the beam spans.
#hide
f_D = barras_F(U_D, X_n, e_f, k_col, k_vig, n_c, Q_D, g_0)
f_L = barras_F(U_L, X_n, e_f, k_col, k_vig, n_c, 0·Q_D, g_0)
f_S = barras_F(U_S, X_n, e_f, k_col, k_vig, n_c, 0·Q_D, g_0)
f_t = barras_F(U_C, X_n, e_f, k_col, k_vig, n_c, 1.2·Q_D, g_0)
#show
f_t
#: **Where ETABS reports:** the column, at the beam face (half a meter below the node): M_{face} = M_{node} − V·o_{f}. The beam, at its stations: the column face (0.2 m), where the load starts, and 3.2 m near the center. Between nodes, M(x) = M_{i} + V_{i}·x − w·x²/2.
#hide
S_D = resumen(f_D, G_D, U_D, F_D, K, n_c, n_1, p(2, 2), o_f, w_v/g_0)
S_L = resumen(f_L, G_L, U_L, F_L, K, n_c, n_1, p(2, 2), o_f, 0)
S_S = resumen(f_S, G_S, U_S, F_S, K, n_c, n_1, p(2, 2), o_f, 0)
S_C = resumen(f_t, G_C, U_C, F_C, K, n_c, n_1, p(2, 2), o_f, 1.2·w_v/g_0)
M_f = zeros(n_r, 2)
V_f = zeros(n_r, 2)
T_f = zeros(n_r, 2)
P_f = zeros(n_r, 2)
for e = 1:n_r
  M_f(e, 1) = f_t(e, 5)
  M_f(e, 2) = -f_t(e, 11)
  V_f(e, 1) = f_t(e, 3)
  V_f(e, 2) = -f_t(e, 9)
  T_f(e, 1) = f_t(e, 4)
  T_f(e, 2) = -f_t(e, 10)
  P_f(e, 1) = f_t(e, 1)
  P_f(e, 2) = -f_t(e, 7)
end
w_n = zeros(n_j, 1)
Mxx_n = zeros(n_j, 1)
Myy_n = zeros(n_j, 1)
Mxy_n = zeros(n_j, 1)
for i = 0:n_e
  for j = 0:n_e
    w_n(p(i, j)) = W_g(i + 1, j + 1)
    Mxx_n(p(i, j)) = M_xg(i + 1, j + 1)
    Myy_n(p(i, j)) = M_yg(i + 1, j + 1)
    Mxy_n(p(i, j)) = M_sg(i + 1, j + 1)
  end
end
U_3 = zeros(n_j, 3)
for j = 1:n_j
  for k = 1:3
    U_3(j, k) = U_C(6·(j - 1) + k)
  end
end
#show
#: **Diagrams per bar** (value at node i and at j, with the sign of the diagram):
M_f 'moment M₂ (tonf·m)
T_f 'torsion (tonf·m): the slab twists the beam

### B.8 · The 3D model (UDCon2)
#: Drag to rotate, wheel to zoom and move the cursor to read the value of the slab or of the bar. The bar diagrams go with their values at the mesh nodes (every 1.2 m); what the self-weight adds inside a span (15.48 at 3.2 m, against 15.41 at the nodes) is in the table of B.9. Deformed ×20 with w and the moment of the bars:
#modelo3d(X_n, e_s, e_f, w_n, M_f, U_3, 20)
#: Torsion of the slab (Mxy) and of the bars (T):
#modelo3d(X_n, e_s, e_f, Mxy_n, T_f)
#: Mxx of the slab and vertical shear of the bars (V₃):
#modelo3d(X_n, e_s, e_f, Mxx_n, V_f)
#: Myy of the slab and axial of the bars (P):
#modelo3d(X_n, e_s, e_f, Myy_n, P_f)

### B.9 · Verification against ETABS
#: **Reference:** ETABS 22 with the same e2k (force tables of the user model, 3 decimals in the slab and 2 in the bars). Per case, the same quantities: slab (maxima in absolute value), column 1 and the edge beam y = 0. The residual of w (+2.6 %) is ETABS's: it stiffens the beam at the joint with the column.
#hide
r_D1 = round(S_D(1), 4)
r_D2 = round(S_D(2), 4)
r_D3 = round(S_D(3), 4)
r_D4 = round(S_D(4), 4)
r_D5 = round(S_D(5), 4)
r_D6 = round(S_D(6), 4)
r_D7 = round(S_D(7), 4)
r_D8 = round(S_D(8), 4)
r_D9 = round(S_D(9), 4)
r_D10 = round(S_D(10), 4)
r_D11 = round(S_D(11), 4)
r_D12 = round(S_D(12), 4)
r_L1 = round(S_L(1), 4)
r_L2 = round(S_L(2), 4)
r_L3 = round(S_L(3), 4)
r_L4 = round(S_L(4), 4)
r_L5 = round(S_L(5), 4)
r_L6 = round(S_L(6), 4)
r_L7 = round(S_L(7), 4)
r_L8 = round(S_L(8), 4)
r_L9 = round(S_L(9), 4)
r_L10 = round(S_L(10), 4)
r_L11 = round(S_L(11), 4)
r_L12 = round(S_L(12), 4)
r_S1 = round(S_S(1), 4)
r_S2 = round(S_S(2), 4)
r_S3 = round(S_S(3), 4)
r_S4 = round(S_S(4), 4)
r_S5 = round(S_S(5), 4)
r_S6 = round(S_S(6), 4)
r_S7 = round(S_S(7), 4)
r_S8 = round(S_S(8), 4)
r_S9 = round(S_S(9), 4)
r_S10 = round(S_S(10), 4)
r_S11 = round(S_S(11), 4)
r_S12 = round(S_S(12), 4)
r_C1 = round(S_C(1), 4)
r_C2 = round(S_C(2), 4)
r_C3 = round(S_C(3), 4)
r_C4 = round(S_C(4), 4)
r_C5 = round(S_C(5), 4)
r_C6 = round(S_C(6), 4)
r_C7 = round(S_C(7), 4)
r_C8 = round(S_C(8), 4)
r_C9 = round(S_C(9), 4)
r_C10 = round(S_C(10), 4)
r_C11 = round(S_C(11), 4)
r_C12 = round(S_C(12), 4)
#show
#: **Dead and Live:**
#| magnitud | Dead | ETABS | Live | ETABS |
#|---|--:|--:|--:|--:|
#| losa: Mxx máximo [tonf·m/m] | @{r_D2} | 0.296 | @{r_L2} | 0.654 |
#| losa: Mxy máximo [tonf·m/m] | @{r_D3} | 0.083 | @{r_L3} | 0.189 |
#| columna: P [tonf] | @{r_D4} | 5.72 | @{r_L4} | 4.50 |
#| columna: V [tonf] | @{r_D5} | 0.45 | @{r_L5} | 0.61 |
#| columna: M en la cara [tonf·m] | @{r_D6} | 1.57 | @{r_L6} | 2.13 |
#| viga: V en la cara [tonf] | @{r_D7} | 2.05 | @{r_L7} | 2.20 |
#| viga: T [tonf·m] | @{r_D8} | 0.53 | @{r_L8} | 1.15 |
#| viga: M en la cara (0.2 m) [tonf·m] | @{r_D9} |  | @{r_L9} |  |
#| viga: M en 3.2 m [tonf·m] | @{r_D10} | 2.43 | @{r_L10} | 3.14 |
#| viga: P [tonf] | @{r_D11} |  | @{r_L11} |  |
#| suma de reacciones [tonf] | @{r_D12} | 22.874 | @{r_L12} | 18.000 |
#| w en el centro [mm] | @{r_D1} |  | @{r_L1} | −6.50 |
#: **SCP and UDCon2:**
#| magnitud | SCP | ETABS | UDCon2 | ETABS |
#|---|--:|--:|--:|--:|
#| losa: Mxx máximo [tonf·m/m] | @{r_S2} | 1.308 | @{r_C2} | 2.970 |
#| losa: Mxy máximo [tonf·m/m] | @{r_S3} | 0.379 | @{r_C3} | 0.857 |
#| columna: P [tonf] | @{r_S4} | 9.00 | @{r_C4} | 24.86 |
#| columna: V [tonf] | @{r_S5} | 1.22 | @{r_C5} | 2.97 |
#| columna: M en la cara [tonf·m] | @{r_S6} | 4.26 | @{r_C6} | 10.40 |
#| viga: V en la cara [tonf] | @{r_S7} | 4.41 | @{r_C7} | 11.27 |
#| viga: T [tonf·m] | @{r_S8} | 2.29 | @{r_C8} | 5.23 |
#| viga: M en la cara (0.2 m) [tonf·m] | @{r_S9} |  | @{r_C9} | −3.99 |
#| viga: M en 3.2 m [tonf·m] | @{r_S10} | 6.28 | @{r_C10} | 15.48 |
#| viga: P [tonf] | @{r_S11} |  | @{r_C11} | 1.84 |
#| suma de reacciones [tonf] | @{r_S12} | 36.000 | @{r_C12} | 99.449 |
#| w en el centro [mm] | @{r_S1} |  | @{r_C1} |  |
#: **Against Python** (Hekatan Struct, mesa_hekatan.py with DKQ and the same loads, 6 decimals), the UDCon2 combination:
d_1 = round((S_C(2) - 2.969589)/2.969589·100, 4) 'Mxx %
d_2 = round((S_C(3) - 0.856810)/0.856810·100, 4) 'Mxy %
d_3 = round((S_C(6) - 10.403524)/10.403524·100, 4) 'M column face %
d_4 = round((S_C(8) - 5.224802)/5.224802·100, 4) 'T beam %
d_5 = round((S_C(10) - 15.483881)/15.483881·100, 4) 'M beam at 3.2 m %
d_6 = round((S_C(12) - 99.449244)/99.449244·100, 4) 'reactions %

#hide
function f = fef_v(w, L, a, b)
  % cargas de empotramiento (locales) de una carga w hacia abajo sobre [a, b] del tramo de largo L:
  % las Hermite de A.7 integradas con Gauss de 2 puntos (exacto: cúbica por constante)
  f = zeros(12, 1)
  gp = [-1, 1]/sqrt(3)
  for k = 1:2
    x = (a + b)/2 + (b - a)/2·gp(k)
    s = x/L
    h = (b - a)/2
    f(3) = f(3) - h·w·(1 - 3·s^2 + 2·s^3)
    f(9) = f(9) - h·w·(3·s^2 - 2·s^3)
    f(5) = f(5) + h·w·L·(s - 2·s^2 + s^3)
    f(11) = f(11) + h·w·L·(s^3 - s^2)
  end
end

function G = losa_M(U, es, Pd, Db, d, ne, Ax, g0)
  % recovery DKQ: momentos en los 4 puntos de Gauss, extrapolados a los nudos, envolvente nodal.
  % Devuelve [Mxx; Myy; Mxy] apiladas, cada una de (ne+1) × (ne+1), en tonf·m/m
  n1 = ne + 1
  G = zeros(3·n1, n1)
  s3 = sqrt(3)
  xg = [-1, 1, 1, -1]/s3
  yg = [-1, -1, 1, 1]/s3
  oi = [0, 1, 1, 0]
  oj = [0, 0, 1, 1]
  for e = 1:ne^2
    ue = zeros(12, 1)
    for k = 1:4
      jd = 6·(es(e, k) - 1)
      ue(3·k - 2) = U(jd + 3)
      ue(3·k - 1) = U(jd + 4)
      ue(3·k) = U(jd + 5)
    end
    ud = Pd·ue
    Mg = zeros(3, 4)
    for k = 1:4
      Mg(:, k) = Db·dkq_B(xg(k), yg(k), d)·ud
    end
    Mn = Ax·transpose(Mg)/g0
    i0 = mod(e - 1, ne)
    j0 = floor((e - 1)/ne)
    for k = 1:4
      ii = i0 + oi(k) + 1
      jj = j0 + oj(k) + 1
      for c = 0:2
        if abs(Mn(k, c + 1)) > abs(G(c·n1 + ii, jj))
          G(c·n1 + ii, jj) = Mn(k, c + 1)
        end
      end
    end
  end
end

function f = barras_F(U, X, ef, kc, kv, nc, Q, g0)
  % fuerzas locales de cada barra: k·Rot·u − cargas de empotramiento, en tonf y tonf·m
  n = n_rows(ef)
  f = zeros(n, 12)
  for e = 1:n
    a = ef(e, 1)
    b = ef(e, 2)
    g = [6·(a - 1) + (1:6), 6·(b - 1) + (1:6)]
    R = rot_frame(X(a, :), X(b, :))
    if e <= nc
      fe = kc·R·U(g) - Q(e, :)
    else
      fe = kv·R·U(g) - Q(e, :)
    end
    f(e, :) = transpose(fe)/g0
  end
end

function r = resumen(f, G, U, F, K, nc, n1, jc, of, w)
  % las magnitudes que reporta ETABS: w central, máximos de la losa, columna 1 y viga del borde y = 0
  r = zeros(12, 1)
  r(1) = 1000·U(6·(jc - 1) + 3)
  r(2) = max(abs(G(1:n1, :)))
  r(3) = max(abs(G(2·n1 + 1:3·n1, :)))
  r(4) = abs(f(1, 1))
  r(5) = abs(f(1, 8))
  r(6) = abs(f(1, 12)) - r(5)·of
  b = nc + 1
  r(7) = abs(f(b, 3))
  r(8) = abs(f(b, 4))
  r(9) = f(b, 5) + f(b, 3)·0.2
  r(10) = f(b + 2, 5) + f(b + 2, 3)·0.8 - w·0.8^2/2
  r(11) = abs(f(b, 1))
  s = 0
  for k = [3, 9, 15, 21]
    s = s + K(k, :)·U - F(k)
  end
  r(12) = s/9.80665
end

function z = bil(Gr, x, y, d, n)
  % interpolación bilineal de la rejilla de nudos (funciones de forma del Q4)
  i = min(max(floor(x/d), 0), n - 1)
  j = min(max(floor(y/d), 0), n - 1)
  r = x/d - i
  s = y/d - j
  z = (1 - r)·(1 - s)·Gr(i + 1, j + 1) + r·(1 - s)·Gr(i + 2, j + 1) + r·s·Gr(i + 2, j + 2) + (1 - r)·s·Gr(i + 1, j + 2)
end

function r = stv(b, h)
  % J de Saint-Venant de un rectángulo (Roark): cubo del lado CORTO
  a = max(b, h)
  s = min(b, h)
  z = s/a
  r = (1/3 - 0.21·z·(1 - z^4/12))·a·s^3
end

function K = memb_q6(E, nu, t, a)
  % membrana Q6 de modos incompatibles, rectángulo de medio lado a (shell_thin.py, _membrane_k_q6)
  c = E/(1 - nu^2)
  Em = c·[1, nu, 0; nu, 1, 0; 0, 0, (1 - nu)/2]
  gp = [-1, 1]/sqrt(3)
  Kuu = zeros(8, 8)
  Kua = zeros(8, 4)
  Kaa = zeros(4, 4)
  for ix = 1:2
    for iy = 1:2
      xi = gp(ix)
      eta = gp(iy)
      dNx = [-(1 - eta), 1 - eta, 1 + eta, -(1 + eta)]/(4·a)
      dNy = [-(1 - xi), -(1 + xi), 1 + xi, 1 - xi]/(4·a)
      B = zeros(3, 8)
      for i = 1:4
        B(1, 2·i - 1) = dNx(i)
        B(2, 2·i) = dNy(i)
        B(3, 2·i - 1) = dNy(i)
        B(3, 2·i) = dNx(i)
      end
      Gi = zeros(3, 4)
      Gi(1, 1) = -2·xi/a
      Gi(3, 2) = -2·eta/a
      Gi(3, 3) = -2·xi/a
      Gi(2, 4) = -2·eta/a
      wd = t·a^2
      Kuu = Kuu + wd·transpose(B)·Em·B
      Kua = Kua + wd·transpose(B)·Em·Gi
      Kaa = Kaa + wd·transpose(Gi)·Em·Gi
    end
  end
  K = Kuu - Kua·inv(Kaa)·transpose(Kua)
end

function B = dkq_B(xi, eta, d)
  % B 3×12 del DKQ rectangular (python_dkq.py, _dkq_Bmatrix), lado d, orden (w, θx, θy)
  rw1 = 3·xi·(1 - eta)/d^2
  rt1 = (1 - eta)·(3·xi - 1)/(2·d)
  rw2 = -3·xi·(1 - eta)/d^2
  rt2 = (1 - eta)·(1 + 3·xi)/(2·d)
  rw3 = -3·xi·(1 + eta)/d^2
  rt3 = (1 + eta)·(1 + 3·xi)/(2·d)
  rw4 = 3·xi·(1 + eta)/d^2
  rt4 = (1 + eta)·(3·xi - 1)/(2·d)
  sw1 = 3·(1 - xi)·eta/d^2
  st1 = (1 - xi)·(3·eta - 1)/(2·d)
  sw2 = 3·(1 + xi)·eta/d^2
  st2 = (1 + xi)·(3·eta - 1)/(2·d)
  sw3 = -3·(1 + xi)·eta/d^2
  st3 = (1 + xi)·(1 + 3·eta)/(2·d)
  sw4 = -3·(1 - xi)·eta/d^2
  st4 = (1 - xi)·(1 + 3·eta)/(2·d)
  tq = 3·(2 - xi^2 - eta^2)/(2·d^2)
  bx1 = (1 - xi)·(1 + 3·xi)/(4·d)
  by1 = (1 - eta)·(1 + 3·eta)/(4·d)
  bx2 = (1 + xi)·(1 - 3·xi)/(4·d)
  by2 = -(1 - eta)·(1 + 3·eta)/(4·d)
  bx3 = (1 + xi)·(3·xi - 1)/(4·d)
  by3 = (1 + eta)·(3·eta - 1)/(4·d)
  bx4 = -(1 - xi)·(1 + 3·xi)/(4·d)
  by4 = (1 + eta)·(1 - 3·eta)/(4·d)
  B = [rw1, 0, rt1, rw2, 0, rt2, rw3, 0, rt3, rw4, 0, rt4; sw1, -st1, 0, sw2, -st2, 0, sw3, -st3, 0, sw4, -st4, 0; tq, -by1, bx1, -tq, -by2, bx2, tq, -by3, bx3, -tq, -by4, bx4]
end

function K = dkq_K(Db, d)
  % rigidez 12×12 del DKQ: Gauss 2×2, det J = (d/2)^2
  gx = [-1, 1, 1, -1]/sqrt(3)
  gy = [-1, -1, 1, 1]/sqrt(3)
  K = zeros(12, 12)
  for k = 1:4
    B = dkq_B(gx(k), gy(k), d)
    K = K + transpose(B)·Db·B·(d/2)^2
  end
end

function K = frame_K(E, G, A, Iy, Iz, J, L)
  % Timoshenko 3D 12×12 (local_stiffness.py, _frame_k), área de corte 5/6·A
  As = 5/6·A
  pz = 12·E·Iz/(G·As·L^2)
  py = 12·E·Iy/(G·As·L^2)
  ea = E·A/L
  gj = G·J/L
  tz = 12·E·Iz/L^3/(1 + pz)
  bz = 6·E·Iz/L^2/(1 + pz)
  kz = 4·E·Iz/L·(1 + pz/4)/(1 + pz)
  az = 2·E·Iz/L·(1 - pz/2)/(1 + pz)
  ty = 12·E·Iy/L^3/(1 + py)
  by = 6·E·Iy/L^2/(1 + py)
  ky = 4·E·Iy/L·(1 + py/4)/(1 + py)
  ay = 2·E·Iy/L·(1 - py/2)/(1 + py)
  K = zeros(12, 12)
  K(1, 1) = ea
  K(1, 7) = -ea
  K(7, 1) = -ea
  K(7, 7) = ea
  K(4, 4) = gj
  K(4, 10) = -gj
  K(10, 4) = -gj
  K(10, 10) = gj
  K(2, 2) = tz
  K(2, 6) = bz
  K(2, 8) = -tz
  K(2, 12) = bz
  K(6, 2) = bz
  K(6, 6) = kz
  K(6, 8) = -bz
  K(6, 12) = az
  K(8, 2) = -tz
  K(8, 6) = -bz
  K(8, 8) = tz
  K(8, 12) = -bz
  K(12, 2) = bz
  K(12, 6) = az
  K(12, 8) = -bz
  K(12, 12) = kz
  K(3, 3) = ty
  K(3, 5) = -by
  K(3, 9) = -ty
  K(3, 11) = -by
  K(5, 3) = -by
  K(5, 5) = ky
  K(5, 9) = by
  K(5, 11) = ay
  K(9, 3) = -ty
  K(9, 5) = by
  K(9, 9) = ty
  K(9, 11) = by
  K(11, 3) = -by
  K(11, 5) = ay
  K(11, 9) = by
  K(11, 11) = ky
end

function R = rot_frame(p0, p1)
  % transformation.py, frame: λ con x a lo largo de la barra; 4 bloques de 3×3
  dv = p1 - p0
  L = norm(dv)
  l = dv(1)/L
  m = dv(2)/L
  n = dv(3)/L
  if abs(n - 1) < 1e-9
    lam = [0, 0, 1; 0, 1, 0; -1, 0, 0]
  elseif abs(n + 1) < 1e-9
    lam = [0, 0, -1; 0, 1, 0; 1, 0, 0]
  else
    D = sqrt(l^2 + m^2)
    lam = [l, m, n; -m/D, l/D, 0; -l·n/D, -m·n/D, D]
  end
  R = zeros(12, 12)
  for k = 0:3
    for r = 1:3
      for c = 1:3
        R(3·k + r, 3·k + c) = lam(r, c)
      end
    end
  end
end
#show
