# Retaining wall by finite elements: the stem as a membrane
#numerico

#: The stem of a cantilever wall, of height H and thickness t, fixed to the footing. **A 1 m strip** of wall is studied with four-node **membrane** elements (two displacements per node: u_{x} and u_{y}), the same type of element with which Hekatan Struct, ETABS and SAP2000 model a wall in its plane. The backfill pushes on the left face with the Rankine triangular distribution.
#: **Units.** Lengths in m, forces in tonf, concrete modulus in kgf/cm². Since 1 kgf/cm² = 10 tonf/m², the stiffness comes out in tonf/m and the displacement in m; it is shown in **mm**.

## 1 · Data
H = 4 [m] 'stem height
t = 0.4 [m] 'stem thickness
γ = 1.8 [tonf/m³] 'unit weight of the backfill
φ = 30 [°] 'friction angle of the backfill
fc = 210 [kgf/cm²] 'concrete strength
ν = 0.2 'Poisson's ratio
#: Modulus of elasticity of the concrete, in kgf/cm² and converted to tonf/m²:
E_c = 15100·sqrt(fc) [kgf/cm²]
E = 10·E_c [tonf/m²]

## 2 · Lateral thrust of the backfill
#: Rankine active earth pressure coefficient:
K_a = tan(pi/4 - φ·pi/360)^2
#: The pressure grows with depth z, measured from the top:
p(z) = K_a·γ·z
p_0 = p(H) [tonf/m²] 'pressure at the base
#: In the plot, K_{a}·γ = 0.6 tonf/m³; the horizontal axis is the depth z in m and the vertical one the pressure in tonf/m²:
#fplot(p = 0.6*z, [0 4])
#: The stem with its fixed base and the thrust, which grows from zero at the top to p_{0} at the base:
#dibujo("The stem and the backfill thrust", ud = m, cotas = m, ancho = 60, alto = 80)
#  rect(0, 0, 0.4, 4, "gruesa")
#  empotramiento(-0.6, 0, 1.0, 0, 1)
#  carga(0, 0, 0, 4, 1.2, 0, "", "azul", n = 9)
#  texto(-1.75, 2.1, "thrust", 2.6, "c", estilo = "azul")
#  texto(-0.9, -0.4, "2.4 tonf/m²", 2.6, "c", estilo = "azul")
#  cota(0.4, 0, 0.4, 4, -0.5, "H = 4.00")
#  cota(0, 4, 0.4, 4, 0.3, "t = 0.40")
#fin
#: The resultant is the area of the triangle and acts at one third of the height:
E_a = K_a·γ·H^2/2 [tonf/m]
M_0 = E_a·H/3 [tonf·m/m] 'moment at the fixed base

## 3 · Constitutive matrix
#: The constitutive matrix relates the stresses σ_{x}, σ_{y}, τ_{xy} with the strains ε_{x}, ε_{y}, γ_{xy}. The membrane works in **plane stress**: there is no stress perpendicular to its plane.
D = E/(1 - ν^2)·[1, ν, 0; ν, 1, 0; 0, 0, (1 - ν)/2]
#: In a very long wall the strip also cannot deform along the wall (plane strain): the stiffness rises 4 %, which is dividing the displacement by 1/(1 − ν²) = 1.0417. Here we continue with plane stress, which is the membrane hypothesis of the programs.

## 4 · Mesh
n_x = 4 'elements across the thickness
n_y = 40 'elements along the height
n_e = n_x·n_y 'number of elements
n_j = (n_x + 1)·(n_y + 1) 'number of nodes
n_d = 2·n_j 'degrees of freedom
a_1 = t/n_x [m] 'element side in x
b_1 = H/n_y [m] 'element side in y
#hide
x_j = zeros(n_j, 1)
y_j = zeros(n_j, 1)
for i = 1:n_x + 1
  for k = 1:n_y + 1
    j = (i - 1)·(n_y + 1) + k
    x_j(j) = (i - 1)·a_1
    y_j(j) = (k - 1)·b_1
  end
end
e_j = zeros(n_e, 4)
for i = 1:n_x
  for k = 1:n_y
    e = (i - 1)·n_y + k
    j = (i - 1)·(n_y + 1) + k
    e_j(e, 1) = j
    e_j(e, 2) = j + n_y + 1
    e_j(e, 3) = j + n_y + 2
    e_j(e, 4) = j + 1
  end
end
s_j = zeros(n_x + 1, 1)
for i = 1:n_x + 1
  s_j(i) = (i - 1)·(n_y + 1) + 1
end
#show
#: Nodes numbered by columns, from the bottom up. The base nodes are fixed:
s_j
#malla(x_j, y_j, e_j, s_j)

## 5 · Element stiffness
#: Strain–displacement matrix of the four-node rectangle, in natural coordinates ξ and η between −1 and 1. Row 1: ε_{x} = ∂u/∂x. Row 2: ε_{y} = ∂v/∂y. Row 3: γ_{xy} = ∂u/∂y + ∂v/∂x.
B(ξ, η) = [-(1 - η)/(2·a_1), 0, (1 - η)/(2·a_1), 0, (1 + η)/(2·a_1), 0, -(1 + η)/(2·a_1), 0; 0, -(1 - ξ)/(2·b_1), 0, -(1 + ξ)/(2·b_1), 0, (1 + ξ)/(2·b_1), 0, (1 - ξ)/(2·b_1); -(1 - ξ)/(2·b_1), -(1 - η)/(2·a_1), -(1 + ξ)/(2·b_1), (1 - η)/(2·a_1), (1 + ξ)/(2·b_1), (1 + η)/(2·a_1), (1 - ξ)/(2·b_1), -(1 + η)/(2·a_1)]
#: The stiffness is the integral of Bᵀ·D·B over the element; the Jacobian of the rectangle is a₁·b₁/4 and the strip width, 1 m:
#noc
K_uu = (a_1·b_1/4)·Area{Area{transpose(B(ξ, η))·D·B(ξ, η) @ ξ = -1 : 1} @ η = -1 : 1}
#equ
#hide
K_uu = (a_1·b_1/4)·integral2(@(ξ, η) transpose(B(ξ, η))·D·B(ξ, η), -1, 1, -1, 1)
#show
#: **Incompatible modes.** The four-node element can only deform with straight sides, and in bending that makes it too stiff. Two curved shapes, 1 − ξ² and 1 − η², are added for u and for v (Wilson and Taylor); it is the element used by SAP2000 and ETABS. Its strains are the G matrix:
G(ξ, η) = [-4·ξ/a_1, 0, 0, 0; 0, 0, 0, -4·η/b_1; 0, -4·ξ/a_1, -4·η/b_1, 0]
#hide
K_ua = (a_1·b_1/4)·integral2(@(ξ, η) transpose(B(ξ, η))·D·G(ξ, η), -1, 1, -1, 1)
K_aa = (a_1·b_1/4)·integral2(@(ξ, η) transpose(G(ξ, η))·D·G(ξ, η), -1, 1, -1, 1)
#show
#: Those shapes have no node of their own: they are eliminated inside the element (static condensation) and the 8 × 8 stiffness remains:
K_e = K_uu - K_ua·(K_aa\transpose(K_ua))

## 6 · Assembly, loads and solution
#hide
d_j(j) = [2·j - 1, 2·j]
d_e(e) = [d_j(e_j(e, 1)), d_j(e_j(e, 2)), d_j(e_j(e, 3)), d_j(e_j(e, 4))]
K = zeros(n_d, n_d)
F = zeros(n_d, 1)
#show
#: The stiffness of each element is **added** into the rows and columns of its degrees of freedom:
for e = 1:n_e
  g = d_e(e)
  K(g, g) = K(g, g) + K_e
end
#: The thrust is distributed to the nodes of the left face. In each segment of height b₁ the pressure is linear, from p_{a} at the bottom to p_{b} at the top:
for k = 1:n_y
  p_a = p(H - y_j(k))
  p_b = p(H - y_j(k + 1))
  F(2·k - 1) = F(2·k - 1) + b_1·(2·p_a + p_b)/6
  F(2·k + 1) = F(2·k + 1) + b_1·(p_a + 2·p_b)/6
end
#: Check: the sum of the nodal forces must give the resultant E_{a}:
ΣF = sum(F) [tonf/m]
#: Free degrees of freedom: all except those of the base.
#hide
L = zeros(n_d - 2·(n_x + 1), 1)
m = 0
for j = 1:n_j
  if y_j(j) > 0
    L(m + 1) = 2·j - 1
    L(m + 2) = 2·j
    m = m + 2
  end
end
U = zeros(n_d, 1)
#show
#: Solution of the system K·U = F at the free degrees of freedom:
U(L) = K(L, L)\F(L)

## 7 · Results
#hide
U_x = zeros(n_x + 1, n_y + 1)
for i = 1:n_x + 1
  for k = 1:n_y + 1
    U_x(i, k) = 1000·U(2·((i - 1)·(n_y + 1) + k) - 1)
  end
end
#show
#: Horizontal displacement at the top, on the backfill face:
u_cor = 1000·U(2·(n_y + 1) - 1) [mm]
#: **Deformed shape with color map.** The wall drawn with its displacements magnified 200 times and painted with the horizontal displacement u_{x} in mm. When the cursor passes over, the value at that point appears:
#hide
X_n = zeros(n_j, 3)
U_3 = zeros(n_j, 3)
u_x = zeros(n_j, 1)
for j = 1:n_j
  X_n(j, 1) = x_j(j)
  X_n(j, 2) = y_j(j)
  U_3(j, 1) = U(2·j - 1)
  U_3(j, 2) = U(2·j)
  u_x(j) = 1000·U(2·j - 1)
end
e_f = zeros(0, 2)
v_f = zeros(0, 2)
#show
#modelo3d(X_n, e_j, e_f, u_x, v_f, U_3, 200)
#: The same displacement as a **color map** on the undeformed stem, with the thickness magnified to see what happens inside:
u_xy(x, y) = spline(1 + x/a_1, 1 + y/b_1, U_x)
#map(u_xy(x, y), [0 0.4], [0 4])

### Stresses
#: In each element σ = D·(B·U_{e} + G·α_{e}), with α_{e} the amplitude of the incompatible modes, evaluated at its four nodes; at each node the elements that meet there are averaged. It is converted to kgf/cm² by dividing by 10.
#hide
ξ_n = [-1, 1, 1, -1]
η_n = [-1, -1, 1, 1]
S_j = zeros(3, n_j)
c_j = zeros(n_j, 1)
for e = 1:n_e
  U_e = U(d_e(e))
  α_e = -(K_aa\(transpose(K_ua)·U_e))
  for i = 1:4
    j = e_j(e, i)
    c_j(j) = c_j(j) + 1
    S_j(:, j) = S_j(:, j) + D·(B(ξ_n(i), η_n(i))·U_e + G(ξ_n(i), η_n(i))·α_e)/10
  end
end
for j = 1:n_j
  S_j(:, j) = S_j(:, j)/c_j(j)
end
S_y = zeros(n_x + 1, n_y + 1)
for i = 1:n_x + 1
  for k = 1:n_y + 1
    S_y(i, k) = S_j(2, (i - 1)·(n_y + 1) + k)
  end
end
#show
#: **Vertical stress σ_{y}** in kgf/cm²: tension on the backfill face, compression on the free face.
σ_y(x, y) = spline(1 + x/a_1, 1 + y/b_1, S_y)
#map(σ_y(x, y), [0 0.4], [0 4])
σ_trac = S_y(1, 1) [kgf/cm²] 'at the fixed base, backfill face
σ_comp = S_y(n_x + 1, 1) [kgf/cm²] 'at the fixed base, free face

## 8 · Check with beam theory
#: The stem is a cantilever with triangular load. The shear deflection is added to the bending deflection (Timoshenko beam, with shear area 5/6 of the section and G = E/(2·(1 + ν))):
I = t^3/12 [m⁴/m]
δ_flex = 1000·p_0·H^4/(30·E·I) [mm]
δ_cort = 1000·p_0·H^2/(6·(5/6)·(E/(2·(1 + ν)))·t) [mm]
δ_viga = δ_flex + δ_cort [mm]
σ_viga = M_0·(t/2)/I/10 [kgf/cm²]
dif = 100·(u_cor - δ_viga)/δ_viga [%]

## 9 · Check with SAP2000 and with Hekatan Struct
#: **SAP2000 24**: plane stress Plane element with incompatible modes, the same 205 nodes and the same nodal forces. It is the same element as in this sheet. **Hekatan Struct**: the same wall with its shell, whose membrane also carries the in-plane rotation (element of Ibrahimbegović, Taylor and Wilson, 1990); it is a different element and therefore does not agree in all digits.
u_med = 1000·U(2·(n_y/2 + 1) - 1) [mm] 'at mid-height, backfill face
v_lib = 1000·U(2·n_j) [mm] 'vertical at the top, free face
#hide
dif_1 = round(100·(u_cor - 1.774773)/1.774773, 4)
dif_2 = round(100·(u_med - 0.6884897)/0.6884897, 4)
dif_3 = round(100·(v_lib + 0.1095972)/0.1095972, 4)
dis_1 = round(100·(1.773183 - u_cor)/u_cor, 2)
dis_2 = round(100·(0.6877718 - u_med)/u_med, 2)
dis_3 = round(100·(-0.1095110 - v_lib)/v_lib, 2)
#show
#| Desplazamiento [mm] | Esta hoja | SAP2000 | dif. [%] | Hekatan Struct | dif. [%] |
#|---|---:|---:|---:|---:|---:|
#| Horizontal en la coronación | @{u_cor} | 1.774773 | @{dif_1} | 1.773183 | @{dis_1} |
#| Horizontal a media altura | @{u_med} | 0.6884897 | @{dif_2} | 0.6877718 | @{dis_2} |
#| Vertical en la coronación, cara libre | @{v_lib} | -0.1095972 | @{dif_3} | -0.1095110 | @{dis_3} |
#: With SAP2000 the largest difference over the 205 nodes is 8·10⁻⁹ % of the maximum displacement; with Hekatan Struct, 0.09 %. The horizontal reaction at the base is 4.8 tonf/m in all three, equal to the resultant of the thrust.
