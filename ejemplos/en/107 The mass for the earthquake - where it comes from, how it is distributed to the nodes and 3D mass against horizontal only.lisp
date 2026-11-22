# The mass for the earthquake: where it comes from, how it is distributed to the nodes and what changes without the vertical mass
#numerico

#: **What is explained.** Modal analysis needs two things: the stiffness K and the mass M. This sheet is only about the **mass**: where it comes from (the code and the *Mass Source*), how it is distributed to the nodes (bars, shells, membrane and Deck) and what happens to the modes when the mass is counted in the three directions (**3D mass**, what SAP2000 and Hekatan Struct do) or **horizontal only** (what ETABS does if nothing is touched).
#: **What is already done and is not repeated here:** sheet 60 (what a mode is, diaphragm and torsion), 64 (the shed membrane and the *Mass Source* that ETABS writes in the .e2k), 102 (rigid versus flexible diaphragm) and the CSI course video «ETABS, slab mass: Shell Thin, Thick and Membrane». At the end, their numbers go into the comparison table.
#: **Units.** tonf, m and s. The mass comes out in **tonf·s²/m** (weight in tonf divided by g in m/s²). Inside the formulas the units go in the text of each variable, not attached to the name.

## 1 · Where the mass comes from

#: Mass is not measured: it is **calculated from the weight**. It is Newton's second law read backwards, F = m·a with a = g:
#: m = W / g
#: **Which weight W.** NEC-15 defines it in **NEC-SE-DS §6.1.7 «Reactive seismic load W»** (p. 55 of the chapter; p. 60 of the PDF):

#| Caso (NEC-15, oficial) | Carga sísmica reactiva |
#|---|---|
#| Caso general | **W = D** (carga muerta total de la estructura) |
#| Bodegas y almacenaje | **W = D + 0.25·L_{i}** (L_{i}: carga viva del piso i) |

#: **NEC-SE-DS 2023 draft (12-09-23), unofficial.** It does change: §6.1.3, equation 6.1 (p. 23; p. 83 of the PDF), **W = W_{D} + x_{L}·W_{L}**, with x_{L} from its Table 6.1:

#| Ocupación (borrador, no oficial) | x_{L} |
#|---|---:|
#| Azoteas, marquesinas y techos | 0.00 |
#| Residencial, oficinas, hoteles, restaurantes | 0.15 |
#| Salud, educación | 0.25 |
#| Bodegas, archivos, almacenamiento | 0.25 |
#| Cines, teatros, centros comerciales, estacionamientos | 0.30 |

#: That is: with NEC-15 a dwelling **carries no live load** in the mass; with the draft, 15 %.

### 1b · The *Mass Source*: mass of the elements or mass from the loads

#: The programs give two paths, and they can be added. What matters is **not to count the self-weight twice**:

#| Camino | De dónde sale | Fórmula | Cuidado |
#|---|---|---|---|
#| **Masa de los elementos** | densidad de masa del material × volumen | ρ = γ / g | en ETABS **peso** y **masa** del material son dos casillas distintas |
#| **Masa desde las cargas** | patrones de carga × factor | D + x_{L}·L, dividido por g | si el peso propio ya entra por el material, el patrón «Dead» de peso propio **no** se vuelve a meter |

#: In Hekatan Struct the .heks stores the **mass density** (ρ in tonf·s²/m⁴, the weight already divided by g). Putting the weight there (2.4 instead of 0.245) makes the modal analysis 3.13 times slower (√9.81): that error was found in 24 examples and corrected (commit 853f8b85d of hekatan-struct).

#: **The numbers of this sheet** (those of the slab of the model in section 4):
γ_c = 2.4 @@(peso unitario del hormigón armado, tonf/m³)
g = 9.80665 @@(aceleración de la gravedad, m/s²)
ρ_c = γ_c/g @@(densidad de MASA del hormigón: lo que pide el programa en «Mass per unit volume», tonf·s²/m⁴)
t_l = 0.20 @@(espesor de la losa, m)
q_D = 0.20 @@(carga muerta sobreimpuesta: acabados y mampostería repartida, tonf/m²)
q_L = 0.20 @@(carga viva de vivienda, tonf/m²)
x_L = 0.15 @@(fracción de carga viva del borrador para vivienda, Tabla 6.1, no oficial)
w_15 = γ_c*t_l + q_D @@(peso sísmico por m² de losa con la NEC-15, caso general W = D, tonf/m²)
w_23 = γ_c*t_l + q_D + x_L*q_L @@(peso sísmico por m² con el borrador, W = W_D + x_L·W_L, tonf/m²)
μ_15 = w_15/g @@(masa por m² de losa con la NEC-15, tonf·s²/m³)
μ_23 = w_23/g @@(masa por m² de losa con el borrador, tonf·s²/m³)

#: The mass per m² is a **line in x_{L}**, of the type y = m·x + b: the intercept b is the dead load (what is always there) and the slope m is the live load divided by g. On the horizontal axis x_{L} from 0 to 0.30, on the vertical the mass per m² (tonf·s²/m³):
#fplot((0.48 + 0.20 + x*0.20)/9.80665, [0 0.3])
#: From 0 (NEC-15, dwelling) to 0.15 (draft) the mass rises 4.4 %, and the period, with its square root: 2.2 %.

## 2 · How the mass is distributed to the nodes

#: The program does not work with a distributed mass: it **concentrates it at the nodes** (*lumped* mass). Each element hands its mass to its own nodes, and the mass of a node is the sum of what the elements that meet at it give it.

### 2a · Bar: half and half

#: A beam or column of section A and length L weighs γ·A·L. Its mass, ρ·A·L, is split into **two equal halves**, one at each end:
#: m_{i} = m_{j} = ρ·A·L / 2
b_v = 0.30 @@(ancho de la viga, m)
h_v = 0.50 @@(peralte de la viga, m)
A_v = b_v*h_v @@(área de la viga, m²)
b_c = 0.40 @@(lado de la columna cuadrada, m)
A_c = b_c^2 @@(área de la columna, m²)
H = 3 @@(altura del piso, m)
m_vx = ρ_c*A_v*3/2 @@(masa que entrega una viga de 3 m a CADA uno de sus dos nudos, tonf·s²/m)
m_vy = ρ_c*A_v*2/2 @@(masa que entrega una viga de 2 m a cada nudo, tonf·s²/m)
m_co = ρ_c*A_c*H/2 @@(masa que entrega una columna a cada extremo, tonf·s²/m)
#: **The lower half of the column goes to the support.** A fixed node does not move, so that mass **does not vibrate** and does not appear in the modal participation: that is why the «total» mass of the programs is greater than the «participating» one.
#: This is how Hekatan Struct does it: lumpedMass in examples/src/shared/ritzModal.ts (lines 21-45), me = rho·A·L/2 at each end of the bar.

### 2b · 4-node shell (Q4): ρ·t·∫N dA

#: The mass of a shell is ρ·t times its area. Each node gets what **its shape function** N_{i} weighs (the one that equals 1 at that node and 0 at the other three):
#: m_{i} = ρ·t·∫ N_{i} dA
#: In a rectangle of sides a and b, with natural coordinates ξ, η from −1 to 1, N_{1} = (1 − ξ)·(1 − η)/4 and dA = (a·b/4)·dξ·dη. The shape function of node 1, plotted: it equals 1 at the corner (−1, −1) and 0 at the other three.
#surf((1-x)*(1-y)/4, [-1 1], [-1 1])
#: The volume under that surface is exactly **one quarter** of the square. The engine integrates it:
#hide
I_N = integral2(@(ξ, η) (1 - ξ)*(1 - η)/4, -1, 1, -1, 1)/4 @@(fracción del área que le toca al nudo 1: ∫N₁ dA dividido entre el área, que en coordenadas naturales es 4)
r_IN = round(I_N, 4) @@(la misma fracción, redondeada)
#show
#: ∫∫ N₁ dξ dη / 4 = **@{r_IN}**
#: **One quarter to each node** in a rectangle (and in any parallelogram). Then, in a regular mesh:

#| Nudo | Elementos que llegan | Masa que recibe |
#|---|---:|---|
#| Interior | 4 | 4/4 = la de un elemento entero |
#| De borde | 2 | 2/4 = medio elemento |
#| De esquina | 1 | 1/4 = un cuarto de elemento |

#: **In a trapezoid they are no longer quarters.** Measured in SAP2000 24 (commit 96e1a020d of hekatan-struct, trapezoid script in cli): a trapezoid that weighs 2.88 t distributes **0.80 / 0.80 / 0.64 / 0.64 t**, not 0.72 × 4. The long side takes more. Hekatan Struct calculates ρ·t·∫N dA in the engine (getGlobalMassMatrix.cpp) the same as SAP2000.

### 2c · Membrane and Deck: the mass has to reach something that supports it

#: A **membrane** has no out-of-plane stiffness (sheet 64). If it is meshed and its interior nodes are **not on a beam**, those nodes have vertical mass and **no vertical stiffness**. This is the problem of section 3.
#: A **Deck** (or a membrane with one-way distribution, ONEWAYLOADDIST) is not meshed node by node: its load and its mass **pass to the beams or purlins** by tributary area, w = q·s (sheet 64). The remaining nodes are those of the beams, and those do have stiffness.

### 2d · The distribution, in the model of this sheet

#: A **6 m × 4 m** plan with a 20 cm slab split into **2 × 2 shells** of 3 m × 2 m, **4 columns** of 40 × 40 cm and 3 m high at the corners, and **beams** of 30 × 50 cm along the edges and on the two central axes. This way **each slab node is on a beam**: none is left without vertical stiffness. Nine nodes on top (1 to 9, by columns of x) and four supports (10 to 13).
#: Bars: beams in x 1-4, 4-7, 2-5, 5-8, 3-6, 6-9; beams in y 1-2, 2-3, 4-5, 5-6, 7-8, 8-9; columns 10-1, 11-3, 12-7, 13-9. The coordinates of the top nodes are in the mass table, further below; the supports are below the corners, at z = 0.
#hide
X_n = [0, 0, 3; 0, 2, 3; 0, 4, 3; 3, 0, 3; 3, 2, 3; 3, 4, 3; 6, 0, 3; 6, 2, 3; 6, 4, 3; 0, 0, 0; 0, 4, 0; 6, 0, 0; 6, 4, 0] @@(coordenadas x, y, z de los 13 nudos, m)
e_n = [1, 4; 4, 7; 2, 5; 5, 8; 3, 6; 6, 9; 1, 2; 2, 3; 4, 5; 5, 6; 7, 8; 8, 9; 10, 1; 11, 3; 12, 7; 13, 9] @@(barras: nudo inicial y final; 1-6 vigas en x, 7-12 vigas en y, 13-16 columnas)
#show
s_q = [1, 4, 5, 2; 2, 5, 6, 3; 4, 7, 8, 5; 5, 8, 9, 6] @@(las 4 cáscaras de la losa, nudos en sentido antihorario)
#: The mass of **one shell** of the slab, with its superimposed dead load (the NEC-15 *Mass Source*: elements + D):
m_q = (ρ_c*t_l + q_D/g)*3*2 @@(masa de una cáscara de 3 m × 2 m: losa más acabados, tonf·s²/m)
#: And the distribution: each bar hands half to each end, each shell a quarter to each of its four nodes.
#: m_{node} = Σ (ρ·A·L/2 of each bar that meets) + Σ (m_{q}/4 of each shell that meets)
#hide
m_n = zeros(13, 1)
for e = 1:16
  a = e_n(e, 1)
  b = e_n(e, 2)
  L = norm(X_n(b, :) - X_n(a, :))
  A_e = A_v
  if e > 12
    A_e = A_c
  end
  m_n(a) = m_n(a) + ρ_c*A_e*L/2
  m_n(b) = m_n(b) + ρ_c*A_e*L/2
end
for q = 1:4
  for k = 1:4
    m_n(s_q(q, k)) = m_n(s_q(q, k)) + m_q/4
  end
end
#show
#hide
M_vib = 0
M_apo = 0
for j = 1:9
  M_vib = M_vib + m_n(j)
end
for j = 10:13
  M_apo = M_apo + m_n(j)
end
r_cen = round(m_n(5), 4)
r_esq = round(m_n(1), 4)
r_bx = round(m_n(4), 4)
r_by = round(m_n(2), 4)
r_vib = round(M_vib, 4)
r_apo = round(M_apo, 4)
r_W = round((M_vib + M_apo)*g, 3)
rm1 = round(m_n(1), 4) @@(masa del nudo 1, tonf·s²/m)
rm2 = round(m_n(2), 4) @@(masa del nudo 2, tonf·s²/m)
rm3 = round(m_n(3), 4) @@(masa del nudo 3, tonf·s²/m)
rm4 = round(m_n(4), 4) @@(masa del nudo 4, tonf·s²/m)
rm5 = round(m_n(5), 4) @@(masa del nudo 5, tonf·s²/m)
rm6 = round(m_n(6), 4) @@(masa del nudo 6, tonf·s²/m)
rm7 = round(m_n(7), 4) @@(masa del nudo 7, tonf·s²/m)
rm8 = round(m_n(8), 4) @@(masa del nudo 8, tonf·s²/m)
rm9 = round(m_n(9), 4) @@(masa del nudo 9, tonf·s²/m)
rm10 = round(m_n(10), 4) @@(masa del nudo 10, tonf·s²/m)
rm11 = round(m_n(11), 4) @@(masa del nudo 11, tonf·s²/m)
rm12 = round(m_n(12), 4) @@(masa del nudo 12, tonf·s²/m)
rm13 = round(m_n(13), 4) @@(masa del nudo 13, tonf·s²/m)
#show
#: The mass of each node, in tonf·s²/m:
#| Nudo | x [m] | y [m] | Dónde está | Masa [tonf·s²/m] |
#|---:|---:|---:|---|---:|
#| 1 | 0 | 0 | esquina, sobre columna | @{rm1} |
#| 2 | 0 | 2 | borde corto, viga central | @{rm2} |
#| 3 | 0 | 4 | esquina, sobre columna | @{rm3} |
#| 4 | 3 | 0 | borde largo, viga central | @{rm4} |
#| 5 | 3 | 2 | **centro** | **@{rm5}** |
#| 6 | 3 | 4 | borde largo, viga central | @{rm6} |
#| 7 | 6 | 0 | esquina, sobre columna | @{rm7} |
#| 8 | 6 | 2 | borde corto, viga central | @{rm8} |
#| 9 | 6 | 4 | esquina, sobre columna | @{rm9} |
#| 10 a 13 | — | — | apoyos (mitad de abajo de cada columna) | @{rm10} cada uno |
#: **Reading.** The central node (5) gathers four quarters of slab and four half-beams: @{r_cen}. A corner (1) only a quarter of slab, two half-beams and half a column: @{r_esq}. The edge ones are in between (@{r_bx} on the long edge, @{r_by} on the short one). The nine nodes that vibrate add up to **@{r_vib} tonf·s²/m**; the supports keep @{r_apo}. Total weight: @{r_W} tonf.
#: **The mass of each node, in 3D.** The slab is painted with the mass of its nodes (red = more mass); pass the cursor to read the value:
#hide
masa_nudo = m_n
sin_diagrama = zeros(16, 2)
#show
#modelo3d(X_n, s_q, e_n, masa_nudo, sin_diagrama)
#: The distribution can be seen: the center weighs more than twice a corner. That is the slab that surrounds it.

## 3 · The mass matrix: three numbers per node

#: Each node has six degrees of freedom (u_{x}, u_{y}, u_{z}, θ_{x}, θ_{y}, θ_{z}). The lumped mass is **diagonal**: the same mass in the three translations, and nothing in the rotations (a point has no rotational inertia):
#: M_{node} = diag(m, m, m, 0, 0, 0)        3D mass (SAP2000, Hekatan Struct)
#: M_{node} = diag(m, m, 0, 0, 0, 0)        horizontal only (ETABS by default: INCLUDEVERTICALMASS "No")
#: Hekatan Struct has both: lumpedMass(…, lateralOnly) in ritzModal.ts; with lateralOnly = true it makes m[2] = 0 (line 43), the vertical mass out, like ETABS.

### 3a · Without vertical mass there are no vertical modes

#: The mode comes from K·φ = ω²·M·φ. If in the vertical direction the mass is **zero**, that row says K·φ = 0: there is no inertia to oppose, and the vertical displacement **adjusts itself, instantly**, to whatever the rest does. It is eliminated by **static condensation**, like the rotations:
#: K̂ = K_{tt} − K_{tr}·K_{rr}⁻¹·K_{rt}
#: where t are the degrees **with mass** and r those without. With 3D mass 3 per node remain (27 modes); with horizontal only, 2 per node (**18 modes**): the vertical modes **do not exist**, it is not that they come out with low participation.

### 3b · Vertical mass without vertical stiffness: absurd periods

#: It is the opposite: a **meshed membrane** whose interior nodes do not fall on a beam. They have vertical mass m but vertical stiffness k ≈ 0 (only numerical noise). The period of that node comes from a single-degree oscillator:
#: T = 2·π·√(m / k)
m_1 = 0.6 @@(masa vertical de un nudo interior de losa, como el nudo 5 de este modelo, tonf·s²/m)
k_1 = 0.0000176 @@(rigidez vertical residual de un nudo de membrana, la que da 1160 s, tonf/m)
T_abs = 2*pi*sqrt(m_1/k_1) @@(periodo de ese nudo, s: el de ETABS con la losa Membrane mallada)
#: With k → 0 the period shoots up. On the horizontal axis the vertical stiffness of the node (from 0.00001 to 0.01 tonf/m), on the vertical its period in seconds:
#fplot(2*pi*sqrt(0.6/x), [0.00001 0.01])
#: Measured in the CSI course video with the meshed Membrane slab: **ETABS 1160 s**, **SAP2000 five million seconds** (its residual stiffness is even smaller). It is not a mode of the structure: it is a loose node. Hekatan Struct **removes** those nodes and warns how much load does not reach the base. The solution in the model: Deck, or one-way distribution to the beams (section 2c).

## 4 · A small model, solved: 3D mass against horizontal only

### 4a · The stiffness

#: Concrete f'c = 210 kgf/cm², E = 15100·√f'c (in kgf/cm²), converted to tonf/m² by multiplying by 10:
E = 15100*sqrt(210)*10 @@(módulo de elasticidad del hormigón, tonf/m²)
ν = 0.2 @@(coeficiente de Poisson del hormigón)
G_m = E/(2*(1 + ν)) @@(módulo de corte, tonf/m²)
I_vs = b_v*h_v^3/12 @@(inercia fuerte de la viga: flexión vertical, m⁴)
I_vd = h_v*b_v^3/12 @@(inercia débil de la viga: flexión horizontal, m⁴)
J_v = h_v*b_v^3*(1/3 - 0.21*b_v/h_v*(1 - b_v^4/(12*h_v^4))) @@(constante de torsión de Saint-Venant de la viga, m⁴)
I_c = b_c^4/12 @@(inercia de la columna, igual en los dos ejes, m⁴)
J_c = b_c^4*(1/3 - 0.21*(1 - 1/12)) @@(constante de torsión de la columna cuadrada, m⁴)
#: Each bar is a 3D frame of 12 degrees (Euler-Bernoulli, without shear deformation). Bending in each plane is the classical 4 × 4 block, with c = E·I:
k_f(c, L) = c*[12/L^3, 6/L^2, -12/L^3, 6/L^2; 6/L^2, 4/L, -6/L^2, 2/L; -12/L^3, -6/L^2, 12/L^3, -6/L^2; 6/L^2, 2/L, -6/L^2, 4/L] @@(flexión en el plano x'-y' local: giro alrededor de z', c = E por la inercia débil o la de la columna)
k_g(c, L) = c*[12/L^3, -6/L^2, -12/L^3, -6/L^2; -6/L^2, 4/L, 6/L^2, 2/L; -12/L^3, 6/L^2, 12/L^3, 6/L^2; -6/L^2, 2/L, 6/L^2, 4/L] @@(flexión en el plano x'-z' local: giro alrededor de y', c = E por la inercia fuerte o la de la columna)
#: k_{f} is the bending in the local plane x'-y' (rotation about z'), k_{g} in the plane x'-z' (rotation about y', with the sign changed). Plus the axial E·A/L and the torsion G·J/L. Each bar is rotated to global axes with its direction cosine matrix λ and **added** into K: K = Σ Tᵀ·k·T.
λ_x = [1, 0, 0; 0, 1, 0; 0, 0, 1] @@(viga en x: x' = X, y' = Y, z' = Z)
λ_y = [0, 1, 0; -1, 0, 0; 0, 0, 1] @@(viga en y: x' = Y, y' = −X, z' = Z)
λ_z = [0, 0, 1; 1, 0, 0; 0, 1, 0] @@(columna: x' = Z, y' = X, z' = Y)
#hide
K = zeros(78, 78)
for e = 1:16
  a = e_n(e, 1)
  b = e_n(e, 2)
  L = norm(X_n(b, :) - X_n(a, :))
  if e <= 6
    lam = λ_x
  elseif e <= 12
    lam = λ_y
  else
    lam = λ_z
  end
  if e <= 12
    A_e = A_v
    I_y = I_vs
    I_z = I_vd
    J_e = J_v
  else
    A_e = A_c
    I_y = I_c
    I_z = I_c
    J_e = J_c
  end
  k_l = zeros(12, 12)
  k_l([1, 7], [1, 7]) = E*A_e/L*[1, -1; -1, 1]
  k_l([4, 10], [4, 10]) = G_m*J_e/L*[1, -1; -1, 1]
  k_l([2, 6, 8, 12], [2, 6, 8, 12]) = k_f(E*I_z, L)
  k_l([3, 5, 9, 11], [3, 5, 9, 11]) = k_g(E*I_y, L)
  T_e = zeros(12, 12)
  for s = 0:3
    T_e([3*s + 1, 3*s + 2, 3*s + 3], [3*s + 1, 3*s + 2, 3*s + 3]) = lam
  end
  k_e = transpose(T_e)*k_l*T_e
  gd = [6*a - 5, 6*a - 4, 6*a - 3, 6*a - 2, 6*a - 1, 6*a, 6*b - 5, 6*b - 4, 6*b - 3, 6*b - 2, 6*b - 1, 6*b]
  K(gd, gd) = K(gd, gd) + k_e
end
#show
#: The supports (nodes 10 to 13) are fixed: the 54 degrees of the nine top nodes remain. The stiffness **is the same** in both cases; the only thing that changes is the mass.

### 4b · 3D mass (like SAP2000 and Hekatan Struct)

#: Degrees with mass: u_{x}, u_{y}, u_{z} of the 9 nodes (27). The rotations are condensed. To solve K̂·φ = ω²·M·φ with diagonal M the change φ = M^{−1/2}·v is made, which leaves a normal symmetric problem, (M^{−1/2}·K̂·M^{−1/2})·v = ω²·v, and it is solved by **Jacobi rotations** (the off-diagonal terms are zeroed one by one; what remains on the diagonal are the ω²).
#: **Mass participation** of mode φ in direction r (φ normalized with φᵀ·M·φ = 1):
#: Γ = φᵀ·M·r        and        participation = Γ² / (rᵀ·M·r)
#: For U_{x}, U_{y}, U_{z}, r is 1 in that translation. For the rotations R_{x}, R_{y}, R_{z}, r is the displacement that a unit rotation produces **about the origin (0, 0, 0)**, as in SAP2000: for example R_{z} gives u_{x} = −y, u_{y} = x. (Hekatan Struct does it the same way: commit d7492031b, R_{x} and R_{y} = SAP2000 and ETABS to 4 decimals in the vault.) That is why R_{x} and R_{y} pick up the mass through its z arm (and the vertical one through its arm in plan).
#hide
t_a = zeros(27, 1)
r_a = zeros(27, 1)
i_t = 0
i_r = 0
for j = 1:9
  for d = 1:6
    if d <= 3
      i_t = i_t + 1
      t_a(i_t) = 6*(j - 1) + d
    else
      i_r = i_r + 1
      r_a(i_r) = 6*(j - 1) + d
    end
  end
end
m_a = zeros(27, 1)
R_a = zeros(27, 6)
for i = 1:27
  j = floor((t_a(i) - 1)/6) + 1
  d = t_a(i) - 6*(j - 1)
  m_a(i) = m_n(j)
  x = X_n(j, 1)
  y = X_n(j, 2)
  z = X_n(j, 3)
  if d == 1
    R_a(i, 1) = 1
    R_a(i, 5) = z
    R_a(i, 6) = -y
  end
  if d == 2
    R_a(i, 2) = 1
    R_a(i, 4) = -z
    R_a(i, 6) = x
  end
  if d == 3
    R_a(i, 3) = 1
    R_a(i, 4) = y
    R_a(i, 5) = -x
  end
end
S_a = K(r_a, r_a)\K(r_a, t_a)
Kc_a = K(t_a, t_a) - K(t_a, r_a)*S_a
D_a = zeros(27, 27)
for i = 1:27
  D_a(i, i) = 1/sqrt(m_a(i))
end
A = D_a*Kc_a*D_a
V = eye(27)
t_am = 1:27
for w = 1:14
  for p = 1:26
    for q = p + 1:27
      if abs(A(p, q)) > 1e-13*sqrt(abs(A(p, p)*A(q, q)))
        th = (A(q, q) - A(p, p))/(2*A(p, q))
        if th >= 0
          tg = 1/(th + sqrt(th^2 + 1))
        else
          tg = -1/(-th + sqrt(th^2 + 1))
        end
        cs = 1/sqrt(tg^2 + 1)
        sn = tg*cs
        gq = [p, q]
        Rr = [cs, sn; -sn, cs]
        A(t_am, gq) = A(t_am, gq)*Rr
        A(gq, t_am) = transpose(Rr)*A(gq, t_am)
        V(t_am, gq) = V(t_am, gq)*Rr
      end
    end
  end
end
w2_a = zeros(27, 1)
for i = 1:27
  w2_a(i) = A(i, i)
end
for i = 1:26
  k = i
  for j = i + 1:27
    if w2_a(j) < w2_a(k)
      k = j
    end
  end
  if k > i
    aux = w2_a(i)
    w2_a(i) = w2_a(k)
    w2_a(k) = aux
    V(t_am, [i, k]) = V(t_am, [k, i])
  end
end
F_a = D_a*V
T_a = zeros(27, 1)
for i = 1:27
  T_a(i) = 2*pi/sqrt(w2_a(i))
end
Mr_a = zeros(6, 1)
for d = 1:6
  for i = 1:27
    Mr_a(d) = Mr_a(d) + m_a(i)*R_a(i, d)^2
  end
end
P_a = zeros(27, 6)
for k = 1:27
  for d = 1:6
    Gm = 0
    for i = 1:27
      Gm = Gm + F_a(i, k)*m_a(i)*R_a(i, d)
    end
    if Mr_a(d) > 0
      P_a(k, d) = Gm^2/Mr_a(d)
    end
  end
end
#show
T_a @@(periodos de los 27 modos con masa 3D, s)

### 4c · Horizontal mass only (like ETABS by default)

#: The same with m_{z} = 0: now the u_{z} are also condensed, 18 degrees with mass remain and **18 modes**.
#hide
t_b = zeros(18, 1)
r_b = zeros(36, 1)
i_t = 0
i_r = 0
for j = 1:9
  for d = 1:6
    if d <= 2
      i_t = i_t + 1
      t_b(i_t) = 6*(j - 1) + d
    else
      i_r = i_r + 1
      r_b(i_r) = 6*(j - 1) + d
    end
  end
end
m_b = zeros(18, 1)
R_b = zeros(18, 6)
for i = 1:18
  j = floor((t_b(i) - 1)/6) + 1
  d = t_b(i) - 6*(j - 1)
  m_b(i) = m_n(j)
  x = X_n(j, 1)
  y = X_n(j, 2)
  z = X_n(j, 3)
  if d == 1
    R_b(i, 1) = 1
    R_b(i, 5) = z
    R_b(i, 6) = -y
  end
  if d == 2
    R_b(i, 2) = 1
    R_b(i, 4) = -z
    R_b(i, 6) = x
  end
  if d == 3
    R_b(i, 3) = 1
    R_b(i, 4) = y
    R_b(i, 5) = -x
  end
end
S_b = K(r_b, r_b)\K(r_b, t_b)
Kc_b = K(t_b, t_b) - K(t_b, r_b)*S_b
D_b = zeros(18, 18)
for i = 1:18
  D_b(i, i) = 1/sqrt(m_b(i))
end
A = D_b*Kc_b*D_b
V = eye(18)
t_bm = 1:18
for w = 1:14
  for p = 1:17
    for q = p + 1:18
      if abs(A(p, q)) > 1e-13*sqrt(abs(A(p, p)*A(q, q)))
        th = (A(q, q) - A(p, p))/(2*A(p, q))
        if th >= 0
          tg = 1/(th + sqrt(th^2 + 1))
        else
          tg = -1/(-th + sqrt(th^2 + 1))
        end
        cs = 1/sqrt(tg^2 + 1)
        sn = tg*cs
        gq = [p, q]
        Rr = [cs, sn; -sn, cs]
        A(t_bm, gq) = A(t_bm, gq)*Rr
        A(gq, t_bm) = transpose(Rr)*A(gq, t_bm)
        V(t_bm, gq) = V(t_bm, gq)*Rr
      end
    end
  end
end
w2_b = zeros(18, 1)
for i = 1:18
  w2_b(i) = A(i, i)
end
for i = 1:17
  k = i
  for j = i + 1:18
    if w2_b(j) < w2_b(k)
      k = j
    end
  end
  if k > i
    aux = w2_b(i)
    w2_b(i) = w2_b(k)
    w2_b(k) = aux
    V(t_bm, [i, k]) = V(t_bm, [k, i])
  end
end
F_b = D_b*V
T_b = zeros(18, 1)
for i = 1:18
  T_b(i) = 2*pi/sqrt(w2_b(i))
end
Mr_b = zeros(6, 1)
for d = 1:6
  for i = 1:18
    Mr_b(d) = Mr_b(d) + m_b(i)*R_b(i, d)^2
  end
end
P_b = zeros(18, 6)
for k = 1:18
  for d = 1:6
    Gm = 0
    for i = 1:18
      Gm = Gm + F_b(i, k)*m_b(i)*R_b(i, d)
    end
    if Mr_b(d) > 0
      P_b(k, d) = Gm^2/Mr_b(d)
    end
  end
end
#show
T_b @@(periodos de los 18 modos con solo masa horizontal, s)

### 4d · The participations, in the six directions

#hide
Ta1 = round(T_a(1), 4)
pa1ux = round(100*P_a(1, 1), 2)
pa1uy = round(100*P_a(1, 2), 2)
pa1uz = round(100*P_a(1, 3), 2)
pa1rx = round(100*P_a(1, 4), 2)
pa1ry = round(100*P_a(1, 5), 2)
pa1rz = round(100*P_a(1, 6), 2)
Ta2 = round(T_a(2), 4)
pa2ux = round(100*P_a(2, 1), 2)
pa2uy = round(100*P_a(2, 2), 2)
pa2uz = round(100*P_a(2, 3), 2)
pa2rx = round(100*P_a(2, 4), 2)
pa2ry = round(100*P_a(2, 5), 2)
pa2rz = round(100*P_a(2, 6), 2)
Ta3 = round(T_a(3), 4)
pa3ux = round(100*P_a(3, 1), 2)
pa3uy = round(100*P_a(3, 2), 2)
pa3uz = round(100*P_a(3, 3), 2)
pa3rx = round(100*P_a(3, 4), 2)
pa3ry = round(100*P_a(3, 5), 2)
pa3rz = round(100*P_a(3, 6), 2)
Ta4 = round(T_a(4), 4)
pa4ux = round(100*P_a(4, 1), 2)
pa4uy = round(100*P_a(4, 2), 2)
pa4uz = round(100*P_a(4, 3), 2)
pa4rx = round(100*P_a(4, 4), 2)
pa4ry = round(100*P_a(4, 5), 2)
pa4rz = round(100*P_a(4, 6), 2)
Ta5 = round(T_a(5), 4)
pa5ux = round(100*P_a(5, 1), 2)
pa5uy = round(100*P_a(5, 2), 2)
pa5uz = round(100*P_a(5, 3), 2)
pa5rx = round(100*P_a(5, 4), 2)
pa5ry = round(100*P_a(5, 5), 2)
pa5rz = round(100*P_a(5, 6), 2)
Ta6 = round(T_a(6), 4)
pa6ux = round(100*P_a(6, 1), 2)
pa6uy = round(100*P_a(6, 2), 2)
pa6uz = round(100*P_a(6, 3), 2)
pa6rx = round(100*P_a(6, 4), 2)
pa6ry = round(100*P_a(6, 5), 2)
pa6rz = round(100*P_a(6, 6), 2)
saux = round(100*(P_a(1, 1) + P_a(2, 1) + P_a(3, 1) + P_a(4, 1) + P_a(5, 1) + P_a(6, 1)), 2)
Saux = round(100*sum(P_a(t_am, 1)), 2)
sauy = round(100*(P_a(1, 2) + P_a(2, 2) + P_a(3, 2) + P_a(4, 2) + P_a(5, 2) + P_a(6, 2)), 2)
Sauy = round(100*sum(P_a(t_am, 2)), 2)
sauz = round(100*(P_a(1, 3) + P_a(2, 3) + P_a(3, 3) + P_a(4, 3) + P_a(5, 3) + P_a(6, 3)), 2)
Sauz = round(100*sum(P_a(t_am, 3)), 2)
sarx = round(100*(P_a(1, 4) + P_a(2, 4) + P_a(3, 4) + P_a(4, 4) + P_a(5, 4) + P_a(6, 4)), 2)
Sarx = round(100*sum(P_a(t_am, 4)), 2)
sary = round(100*(P_a(1, 5) + P_a(2, 5) + P_a(3, 5) + P_a(4, 5) + P_a(5, 5) + P_a(6, 5)), 2)
Sary = round(100*sum(P_a(t_am, 5)), 2)
sarz = round(100*(P_a(1, 6) + P_a(2, 6) + P_a(3, 6) + P_a(4, 6) + P_a(5, 6) + P_a(6, 6)), 2)
Sarz = round(100*sum(P_a(t_am, 6)), 2)
Tb1 = round(T_b(1), 4)
pb1ux = round(100*P_b(1, 1), 2)
pb1uy = round(100*P_b(1, 2), 2)
pb1uz = round(100*P_b(1, 3), 2)
pb1rx = round(100*P_b(1, 4), 2)
pb1ry = round(100*P_b(1, 5), 2)
pb1rz = round(100*P_b(1, 6), 2)
Tb2 = round(T_b(2), 4)
pb2ux = round(100*P_b(2, 1), 2)
pb2uy = round(100*P_b(2, 2), 2)
pb2uz = round(100*P_b(2, 3), 2)
pb2rx = round(100*P_b(2, 4), 2)
pb2ry = round(100*P_b(2, 5), 2)
pb2rz = round(100*P_b(2, 6), 2)
Tb3 = round(T_b(3), 4)
pb3ux = round(100*P_b(3, 1), 2)
pb3uy = round(100*P_b(3, 2), 2)
pb3uz = round(100*P_b(3, 3), 2)
pb3rx = round(100*P_b(3, 4), 2)
pb3ry = round(100*P_b(3, 5), 2)
pb3rz = round(100*P_b(3, 6), 2)
Tb4 = round(T_b(4), 4)
pb4ux = round(100*P_b(4, 1), 2)
pb4uy = round(100*P_b(4, 2), 2)
pb4uz = round(100*P_b(4, 3), 2)
pb4rx = round(100*P_b(4, 4), 2)
pb4ry = round(100*P_b(4, 5), 2)
pb4rz = round(100*P_b(4, 6), 2)
Tb5 = round(T_b(5), 4)
pb5ux = round(100*P_b(5, 1), 2)
pb5uy = round(100*P_b(5, 2), 2)
pb5uz = round(100*P_b(5, 3), 2)
pb5rx = round(100*P_b(5, 4), 2)
pb5ry = round(100*P_b(5, 5), 2)
pb5rz = round(100*P_b(5, 6), 2)
Tb6 = round(T_b(6), 4)
pb6ux = round(100*P_b(6, 1), 2)
pb6uy = round(100*P_b(6, 2), 2)
pb6uz = round(100*P_b(6, 3), 2)
pb6rx = round(100*P_b(6, 4), 2)
pb6ry = round(100*P_b(6, 5), 2)
pb6rz = round(100*P_b(6, 6), 2)
sbux = round(100*(P_b(1, 1) + P_b(2, 1) + P_b(3, 1) + P_b(4, 1) + P_b(5, 1) + P_b(6, 1)), 2)
Sbux = round(100*sum(P_b(t_bm, 1)), 2)
sbuy = round(100*(P_b(1, 2) + P_b(2, 2) + P_b(3, 2) + P_b(4, 2) + P_b(5, 2) + P_b(6, 2)), 2)
Sbuy = round(100*sum(P_b(t_bm, 2)), 2)
sbuz = round(100*(P_b(1, 3) + P_b(2, 3) + P_b(3, 3) + P_b(4, 3) + P_b(5, 3) + P_b(6, 3)), 2)
Sbuz = round(100*sum(P_b(t_bm, 3)), 2)
sbrx = round(100*(P_b(1, 4) + P_b(2, 4) + P_b(3, 4) + P_b(4, 4) + P_b(5, 4) + P_b(6, 4)), 2)
Sbrx = round(100*sum(P_b(t_bm, 4)), 2)
sbry = round(100*(P_b(1, 5) + P_b(2, 5) + P_b(3, 5) + P_b(4, 5) + P_b(5, 5) + P_b(6, 5)), 2)
Sbry = round(100*sum(P_b(t_bm, 5)), 2)
sbrz = round(100*(P_b(1, 6) + P_b(2, 6) + P_b(3, 6) + P_b(4, 6) + P_b(5, 6) + P_b(6, 6)), 2)
Sbrz = round(100*sum(P_b(t_bm, 6)), 2)
r_Mx = round(Mr_a(1), 4)
r_Mz = round(Mr_a(3), 4)
r_Rxa = round(Mr_a(4), 3)
r_Rxb = round(Mr_b(4), 3)
r_Rz = round(Mr_a(6), 3)
#show
#: **3D mass** (27 modes). Mass in each direction, rᵀ·M·r: U_{x} = U_{y} = U_{z} = @{r_Mx} tonf·s²/m; R_{x} = @{r_Rxa}, R_{z} = @{r_Rz} tonf·s²·m.
#| Modo | T [s] | U_{x} [%] | U_{y} [%] | U_{z} [%] | R_{x} [%] | R_{y} [%] | R_{z} [%] |
#|---:|---:|---:|---:|---:|---:|---:|---:|
#| 1 | @{Ta1} | @{pa1ux} | @{pa1uy} | @{pa1uz} | @{pa1rx} | @{pa1ry} | @{pa1rz} |
#| 2 | @{Ta2} | @{pa2ux} | @{pa2uy} | @{pa2uz} | @{pa2rx} | @{pa2ry} | @{pa2rz} |
#| 3 | @{Ta3} | @{pa3ux} | @{pa3uy} | @{pa3uz} | @{pa3rx} | @{pa3ry} | @{pa3rz} |
#| 4 | @{Ta4} | @{pa4ux} | @{pa4uy} | @{pa4uz} | @{pa4rx} | @{pa4ry} | @{pa4rz} |
#| 5 | @{Ta5} | @{pa5ux} | @{pa5uy} | @{pa5uz} | @{pa5rx} | @{pa5ry} | @{pa5rz} |
#| 6 | @{Ta6} | @{pa6ux} | @{pa6uy} | @{pa6uz} | @{pa6rx} | @{pa6ry} | @{pa6rz} |
#| **Σ modos 1-6** | | **@{saux}** | **@{sauy}** | **@{sauz}** | **@{sarx}** | **@{sary}** | **@{sarz}** |
#| **Σ todos los modos** | | **@{Saux}** | **@{Sauy}** | **@{Sauz}** | **@{Sarx}** | **@{Sary}** | **@{Sarz}** |

#: **Horizontal mass only** (18 modes). U_{z} has no mass (rᵀ·M·r = 0: the column stays at 0) and R_{x} drops to @{r_Rxb} tonf·s²·m, because the vertical mass no longer counts through its arm in plan.
#| Modo | T [s] | U_{x} [%] | U_{y} [%] | U_{z} [%] | R_{x} [%] | R_{y} [%] | R_{z} [%] |
#|---:|---:|---:|---:|---:|---:|---:|---:|
#| 1 | @{Tb1} | @{pb1ux} | @{pb1uy} | @{pb1uz} | @{pb1rx} | @{pb1ry} | @{pb1rz} |
#| 2 | @{Tb2} | @{pb2ux} | @{pb2uy} | @{pb2uz} | @{pb2rx} | @{pb2ry} | @{pb2rz} |
#| 3 | @{Tb3} | @{pb3ux} | @{pb3uy} | @{pb3uz} | @{pb3rx} | @{pb3ry} | @{pb3rz} |
#| 4 | @{Tb4} | @{pb4ux} | @{pb4uy} | @{pb4uz} | @{pb4rx} | @{pb4ry} | @{pb4rz} |
#| 5 | @{Tb5} | @{pb5ux} | @{pb5uy} | @{pb5uz} | @{pb5rx} | @{pb5ry} | @{pb5rz} |
#| 6 | @{Tb6} | @{pb6ux} | @{pb6uy} | @{pb6uz} | @{pb6rx} | @{pb6ry} | @{pb6rz} |
#| **Σ modos 1-6** | | **@{sbux}** | **@{sbuy}** | **@{sbuz}** | **@{sbrx}** | **@{sbry}** | **@{sbrz}** |
#| **Σ todos los modos** | | **@{Sbux}** | **@{Sbuy}** | **@{Sbuz}** | **@{Sbrx}** | **@{Sbry}** | **@{Sbrz}** |

#: **Reading, mode by mode:**
#: • **Modes 1 to 3 equal in both cases**: 1 translates in Y, 2 in X and 3 **rotates** (R_{z}). The vertical mass does not touch them because in this frame they hardly move anything vertically.
#: • **Mode 4 with 3D mass is vertical** (U_{z} ≈ 51 %): the slab and the central beams «bounce». **With horizontal mass only that mode does not exist**, and ETABS «mode 4» is SAP2000 mode 5. Comparing «mode 4 against mode 4» between the two programs is comparing two different modes: that is how the −29.7 % of the shed came out (commit f8c187cba of hekatan-struct), which disappeared when the ETABS vertical mass was turned on.
#: • **The sum in U_{z}** goes from 100 % to nothing, and **R_{x} and R_{y} change value** even though modes 1-3 are the same: their reference mass rᵀ·M·r changed. The columns U_{x}, U_{y} and R_{z} are the ones that can be compared between programs without looking at the *Mass Source*.
#: • NEC asks for **90 % of the mass** in each horizontal direction: here the first two modes give it (more than 94 % and 99 %).

### 4e · The mode shapes, in 3D

#: Each shape is scaled to 1 at the node that moves most, and the slab is painted with how much each node moves. It rotates by dragging.
#hide
u_f = zeros(54, 1)
u_f(t_a) = F_a(t_am, 1)
u_f(r_a) = -S_a*F_a(t_am, 1)
U_a1 = zeros(13, 3)
um = 0
for j = 1:9
  for d = 1:3
    U_a1(j, d) = u_f(6*(j - 1) + d)
    if abs(U_a1(j, d)) > um
      um = abs(U_a1(j, d))
    end
  end
end
forma_a1 = zeros(13, 1)
um = 0
for j = 1:9
  forma_a1(j) = sqrt(U_a1(j, 1)^2 + U_a1(j, 2)^2 + U_a1(j, 3)^2)
  if forma_a1(j) > um
    um = forma_a1(j)
  end
end
U_a1 = U_a1/um
forma_a1 = forma_a1/um
#show
#: **Mode 1** (translation in Y), 3D mass:
#modelo3d(X_n, s_q, e_n, forma_a1, sin_diagrama, U_a1, 0.6)
#hide
u_f = zeros(54, 1)
u_f(t_a) = F_a(t_am, 2)
u_f(r_a) = -S_a*F_a(t_am, 2)
U_a2 = zeros(13, 3)
um = 0
for j = 1:9
  for d = 1:3
    U_a2(j, d) = u_f(6*(j - 1) + d)
    if abs(U_a2(j, d)) > um
      um = abs(U_a2(j, d))
    end
  end
end
forma_a2 = zeros(13, 1)
um = 0
for j = 1:9
  forma_a2(j) = sqrt(U_a2(j, 1)^2 + U_a2(j, 2)^2 + U_a2(j, 3)^2)
  if forma_a2(j) > um
    um = forma_a2(j)
  end
end
U_a2 = U_a2/um
forma_a2 = forma_a2/um
#show
#: **Mode 2** (translation in X):
#modelo3d(X_n, s_q, e_n, forma_a2, sin_diagrama, U_a2, 0.6)
#hide
u_f = zeros(54, 1)
u_f(t_a) = F_a(t_am, 3)
u_f(r_a) = -S_a*F_a(t_am, 3)
U_a3 = zeros(13, 3)
um = 0
for j = 1:9
  for d = 1:3
    U_a3(j, d) = u_f(6*(j - 1) + d)
    if abs(U_a3(j, d)) > um
      um = abs(U_a3(j, d))
    end
  end
end
forma_a3 = zeros(13, 1)
um = 0
for j = 1:9
  forma_a3(j) = sqrt(U_a3(j, 1)^2 + U_a3(j, 2)^2 + U_a3(j, 3)^2)
  if forma_a3(j) > um
    um = forma_a3(j)
  end
end
U_a3 = U_a3/um
forma_a3 = forma_a3/um
#show
#: **Mode 3** (rotation about Z, the torsion): the corners move and the center hardly does.
#modelo3d(X_n, s_q, e_n, forma_a3, sin_diagrama, U_a3, 0.6)
#hide
u_f = zeros(54, 1)
u_f(t_a) = F_a(t_am, 4)
u_f(r_a) = -S_a*F_a(t_am, 4)
U_a4 = zeros(13, 3)
um = 0
for j = 1:9
  for d = 1:3
    U_a4(j, d) = u_f(6*(j - 1) + d)
    if abs(U_a4(j, d)) > um
      um = abs(U_a4(j, d))
    end
  end
end
forma_a4 = zeros(13, 1)
um = 0
for j = 1:9
  forma_a4(j) = sqrt(U_a4(j, 1)^2 + U_a4(j, 2)^2 + U_a4(j, 3)^2)
  if forma_a4(j) > um
    um = forma_a4(j)
  end
end
U_a4 = U_a4/um
forma_a4 = forma_a4/um
#show
#: **Mode 4, vertical: it exists only with 3D mass.** The center of the slab goes down and up over the central beams.
#modelo3d(X_n, s_q, e_n, forma_a4, sin_diagrama, U_a4, 0.6)

## 5 · Hekatan against SAP2000 against ETABS: the numbers available

#: Only **measured** numbers, with their source. What has not been run is not filled in.

#: **a) Frame with slab** (4 × 3 bays, one story, 20 cm slab), the one in the CSI course videos on slab mass, exported from Hekatan Struct to SAP2000 (s2k) and to ETABS (e2k):
#| Magnitud | Hekatan Struct | SAP2000 | ETABS |
#|---|---:|---:|---:|
#| masa total [tonf·s²/m] | 302.59 | 302.59 | — |
#| T₁, Shell-Thin, masa 3D [s] | 0.2330 | 0.233 | 0.233 |
#| T₄, modo vertical de la losa [s] | 0.0873 | — | 0.087 |
#| U_{z} del modo 4 | 8.6 % | 8.6 % | 8.6 % |
#| T₁, Shell-Thick [s] | 0.2321 | — | 0.232 |
#| T₁, Membrane mallada [s] | 0.2439 (¹) | ≈ 5 000 000 | 1160 |
#| T₁, Membrane sin masa vertical [s] | 0.2437 | — | 0.244 |
#: Source: modal table read from Hekatan Struct in the recording (CSI course, Struct mass folder) and subtitles of the SAP2000 and ETABS videos. (¹) Struct removes the membrane nodes without vertical stiffness and warns. «—»: the video does not say.

#: **b) Curved shed** (214 nodes, 443 bars, 100 sheets), difference against Hekatan:
#| Magnitud | Hekatan | SAP2000 | ETABS sin masa vertical | ETABS con masa vertical |
#|---|---:|---:|---:|---:|
#| T₁ [s] | 0.331144 | −0.00 % | — | −0.02 % |
#| T₄ [s] | 0.172513 | −0.00 % | −29.7 % | −0.01 % |
#| ΣU_{z} | 38.445 % | — | 0 | 38.446 % |
#: Source: hekatan-struct, validation/opensees/README.md (16-Sep-2026) and commit f8c187cba. The −29.7 % is not an ETABS error: its «mode 4» was another mode.

#: **c) Electoral warehouse shed** (mass = steel self-weight only):
#| Magnitud | Hekatan Struct | SAP2000 | ETABS |
#|---|---:|---:|---:|
#| T₁ [s] | 0.4314 | 0.4314 | 0.4267 |
#: Source: measurement of 2-Aug-2026 (galpon-bodega-electoral, a_etabs.py with and without --sap). Hekatan and SAP2000: the 12 modes equal to 4 digits. ETABS ~1 % different because its mass is lateral and lumped per story.

#: **d) The model of this sheet** (6 × 4 m, 2 × 2 shells on beams):
#| Magnitud | Hekatan LISP | SAP2000 | ETABS |
#|---|---:|---:|---:|
#| T₁, masa 3D [s] | @{Ta1} | pendiente | pendiente |
#| T₂ [s] | @{Ta2} | pendiente | pendiente |
#| T₃ [s] | @{Ta3} | pendiente | pendiente |
#| T₄, vertical [s] | @{Ta4} | pendiente | pendiente |
#| T₄, solo masa horizontal [s] | @{Tb4} | pendiente | pendiente |

#: **The rule that comes out of the table:** before comparing periods between programs, look at **the Mass Source** (which mass, in which directions, whether it is lumped per story). With the same mass, Hekatan, SAP2000 and ETABS give the same; with different mass, none is wrong and none agrees.
#: **Check of this sheet (it is not a judge):** the periods and participations of 4b and 4c were repeated with numpy/scipy (scipy.linalg.eigh on the same condensed K and M) and agree to 4 decimals. The real judge, SAP2000 with this same model node by node, is **pending**.

## 6 · Summary

#| Pregunta | Respuesta corta |
#|---|---|
#| ¿De dónde sale la masa? | m = W/g; NEC-15: W = D (bodegas + 0.25 L); borrador: W = W_{D} + x_{L}·W_{L} |
#| ¿Elementos o cargas? | los dos se suman; el peso propio, una sola vez |
#| ¿Barra? | ρ·A·L/2 a cada extremo; la mitad de abajo de la columna se queda en el apoyo |
#| ¿Cáscara Q4? | ρ·t·∫N_{i} dA: cuartos en un rectángulo, no en un trapecio |
#| ¿Membrana o Deck? | la masa tiene que llegar a una viga; un nudo con masa y sin rigidez da periodos absurdos |
#| ¿Masa 3D o solo horizontal? | los modos laterales casi iguales; los verticales solo existen con masa 3D y corren la numeración |
