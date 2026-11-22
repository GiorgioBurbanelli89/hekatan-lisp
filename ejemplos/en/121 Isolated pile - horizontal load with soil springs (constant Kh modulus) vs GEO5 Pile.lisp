# Isolated pile with horizontal load: beam on soil springs (constant modulus k_h), against GEO5
#numerico

#: **What is computed.** The same pile of sheet 120 (GEO5 Pile, **Demo_manual_13.gpi**: C 20/25 concrete, 1.00 m diameter, 12.00 m long) with the head load: **H = 85 kN** and **M = 120 kN·m**. What the GEO5 "Horizontal cap." frame gives is sought: the **head displacement**, and the maximum shear and moment.
#: **How.** GEO5 uses "Elastic subsoil (p-y method)": the pile is a beam and the soil, horizontal springs (Winkler model) of modulus k_{h}. The example chooses k_{h} **constant** per layer; the formula comes from the GEO5 help ("Constant Distribution of Modulus of Subsoil Reaction"). Here the beam is solved by **finite elements**: 24 beam elements of 0.50 m with the spring distributed along each one.
#: **Judge.** The GEO5 2024 report ("In detail" of the Horizontal cap. frame): head displacement −4.2 mm, maximum shear 85.00 kN, maximum moment 120.00 kN·m.
#: **Units.** kN, m, kPa and MPa (= MN/m²); displacements in mm.

## 1 · Data

#: **The pile.** GEO5 takes the modulus E_{cm} of the C 20/25 concrete that its report prints.
d_p = 1.0 'diameter [m]
L_p = 12.0 'length [m]
E_c = 30000 'modulus of elasticity of C 20/25 concrete [MPa]
I_p = pi·d_p^4/64 'moment of inertia of the circular section [m4]
EI = E_c·1000·I_p 'bending stiffness [kN·m2]
#: **The soil.** Two layers, with their deformation modulus E_{def} and their dispersion angle β (example data, for constant k_{h}). E_{def} was read from the soil records of the .gpi file (the report prints E_{oed}: 8 and 21 MPa).
h_1 = 6.0 'clay thickness [m]
E_1 = 5.0 'deformation modulus of the clay [MPa]
β_1 = 10 'dispersion angle of the clay [degrees]
E_2 = 15.5 'deformation modulus of the sand [MPa]
β_2 = 15 'dispersion angle of the sand [degrees]
#: **The head load** (Load No. 1): the head is free (no imposed displacement or rotation) and the base is not fixed.
H_0 = 85 'horizontal force at the head [kN]
M_0 = 120 'moment at the head [kN·m]

## 2 · The reaction modulus k_h (GEO5 help)

#: **Reduced width** of the pile: the soil "spreads" the pressure with the angle β on each side.
r_1 = d_p + 2·d_p·tan(β_1·pi/180) 'reduced width in the clay [m]
r_2 = d_p + 2·d_p·tan(β_2·pi/180) 'reduced width in the sand [m]
#: **Constant modulus in each layer:**
k_h1 = 3·E_1/(2·r_1) 'reaction modulus of the clay [MN/m3]
k_h2 = 3·E_2/(2·r_2) 'reaction modulus of the sand [MN/m3]
#: The spring per metre of pile is k_{h}·d (pressure times width): it is what is distributed in each element.
c_1 = k_h1·1000·d_p 'clay spring per metre of pile [kN/m2]
c_2 = k_h2·1000·d_p 'sand spring per metre of pile [kN/m2]

## 3 · The beam on springs by finite elements

#: **Stiffness of each element** of length h: the bending stiffness of the beam (Hermite) plus that of the distributed spring c (consistent matrix, with the same shape functions). The degrees of freedom of each node are the displacement w and the rotation θ.
n_e = 24 'number of elements
h = L_p/n_e 'length of each element [m]
K_v = EI/h^3·[12, 6·h, -12, 6·h; 6·h, 4·h^2, -6·h, 2·h^2; -12, -6·h, 12, -6·h; 6·h, 2·h^2, -6·h, 4·h^2] 'bending stiffness of the element
K_r = h/420·[156, 22·h, 54, -13·h; 22·h, 4·h^2, 13·h, -3·h^2; 54, 13·h, 156, -22·h; -13·h, -3·h^2, -22·h, 4·h^2] 'spring stiffness, per unit of c
#: **Assembly**: each element adds its stiffness into the 4 degrees of freedom of its two nodes; the spring is that of the layer in which the element centre falls.
n_g = 2·(n_e + 1) 'degrees of freedom of the pile
#hide
K = zeros(n_g, n_g)
#show
for e = 1:n_e
  g = 2·e - 1 + (0:3)
  if (e - 0.5)·h < h_1
    K(g, g) = K(g, g) + K_v + c_1·K_r
  else
    K(g, g) = K(g, g) + K_v + c_2·K_r
  end
end
#: **Loads**: the horizontal force and the moment enter at the head node.
#hide
F = zeros(n_g, 1)
F(1) = H_0
F(2) = M_0
#show
#: **Solution** K·u = F. No supports: the soil springs hold the whole pile.
u = clsolve(K, F)
w_0 = u(1)·1000 'head displacement [mm]
θ_0 = u(2)·1000 'head rotation [mrad]
w_L = u(n_g - 1)·1000 'tip displacement [mm]
#hide
r_w0 = round(w_0, 2)
r_wL = round(w_L, 2)
#show
#: The head moves @{r_w0} mm and the tip @{r_wL} mm **in the opposite direction**: the pile behaves almost like a rigid body that rotates, because 12 m of 1 m diameter concrete are much stiffer than the clay around it.

## 4 · Shear and moment along the pile

#: In each element, the forces at its ends are (K_{v} + c·K_{r})·u_{e}; the shear and the moment at the start of the element come out with the sign changed from the first node.
#hide
z_n = zeros(n_e + 1, 1)
w_n = zeros(n_e + 1, 1)
V_n = zeros(n_e, 1)
M_n = zeros(n_e, 1)
z_m = zeros(n_e, 1)
for j = 1:n_e + 1
  z_n(j) = (j - 1)·h
  w_n(j) = u(2·j - 1)·1000
end
for e = 1:n_e
  g = 2·e - 1 + (0:3)
  if (e - 0.5)·h < h_1
    f_e = (K_v + c_1·K_r)·u(g)
  else
    f_e = (K_v + c_2·K_r)·u(g)
  end
  V_n(e) = f_e(1)
  M_n(e) = -f_e(2)
  z_m(e) = (e - 1)·h
end
#show
V_max = max(abs(V_n)) 'maximum shear [kN]
M_max = max(abs(M_n)) 'maximum moment [kN·m]
#: The maxima are at the head: the soil never returns more than what goes in. It is the same as what GEO5 prints (85.00 kN and 120.00 kN·m).
#: For the drawing, the displacement and the moment are scaled:
p_w = 0.6·w_n 'node displacement, scaled
p_z = -z_n 'depth of the nodes (downward)
p_M = -M_n/40 'moment at the start of each element, scaled
p_zm = -z_m 'depth of the start of each element
#dibujo("Deformed pile (blue, displacement ×600: 1 m = 1.67 mm) and bending moment (red, 1 m = 40 kN·m)", ud = m, cotas = m, escala = auto, alto = 120)
#  rect(-7, -6, 13, 6, "relleno azul tenue sinborde")
#  rect(-7, -13, 13, 7, "relleno naranja tenue sinborde")
#  texto(-6.9, -0.8, "clay: k_{h} = 5.54 MN/m³", 3.2, "i")
#  texto(-6.9, -6.8, "sand: k_{h} = 15.14 MN/m³", 3.2, "i")
#  linea(-7, 0, 6, 0, "media verde")
#  linea(0, 0, 0, -12, "eje")
#  polilinea(p_w, p_z, "gruesa azul")
#  polilinea(p_M, p_zm, "media rojo")
#  flecha(-2.2, 0.6, 0, 0.6, "rojo")
#  texto(-6.9, 0.9, "H = 85 kN, M = 120 kN·m", 3.2, "i")
#  texto(2.7, -0.6, "w = 4.21 mm", 3.2, "i")
#  texto(3.3, -1.6, "M = 120 kN·m (red)", 3.2, "i")
#  cota(1.3, 0, 1.3, -12, 0.2, "12.00")
#  cota(-7.4, 0, -7.4, -6, 0.2, "6.00")
#  cota(-7.4, -6, -7.4, -13, 0.2, "7.00")
#  cota(-0.5, -13.6, 0.5, -13.6, -0.1, "d = 1.00")
#fin

## 5 · NEC-SE-GC 2015 (official)

#: NEC-15 (§6.4, p. 45) treats the lateral load and the earthquake on the pile as a **beam on p-y springs** (Reese and Van Impe, 2001), which is what this GEO5 frame does. The code asks for **non-linear** springs; GEO5 with constant k_{h} is linear (the option "according to Matlock and Reese" is by the same authors, for sands only). In soils E and F it also asks for **kinematic interaction**.
#: NEC-15 **gives no limit** for the head displacement: the @{r_w0} mm are judged by the structural engineer with the drift and the forces of the superstructure. The 2023 draft (unofficial) does not set a number at the pile head either.

## 6 · Hekatan against GEO5

#hide
g_w = 4.2
g_V = 85.00
g_M = 120.00
h_w = round(abs(w_0), 1)
h_V = round(V_max, 2)
h_M = round(M_max, 2)
x_w = round(100·(h_w/g_w - 1), 3)
x_V = round(100·(h_V/g_V - 1), 4)
x_M = round(100·(h_M/g_M - 1), 4)
#show
#| Magnitud | Hekatan | GEO5 2024 | Diferencia [%] |
#|---|---:|---:|---:|
#| desplazamiento de la cabeza [mm] | @{h_w} | @{g_w} | @{x_w} |
#| cortante máximo [kN] | @{h_V} | @{g_V} | @{x_V} |
#| momento máximo [kN·m] | @{h_M} | @{g_M} | @{x_M} |
#: GEO5 prints the displacement with **a single decimal** (−4.2 mm; the sign is its axis convention): the comparison holds to 2 digits. With 12, 24, 48 and 96 elements Hekatan always gives 4.2121 mm (the Hermite beam with consistent spring already converges with 12).
#: **What is NOT Hekatan calculation:** E_{def} = 5.0 and 15.5 MPa (read from the .gpi file; they do not come out of E_{oed} = 8 and 21 MPa with β = 1 − 2ν²/(1 − ν), which would give 4.98 and 15.60) and the verification of the concrete section (N_{Rd} = 9144.06 kN, M_{Rd} = 756.75 kN·m, V_{Rd} = 419.94 kN, EN 1992-1-1): pending.
