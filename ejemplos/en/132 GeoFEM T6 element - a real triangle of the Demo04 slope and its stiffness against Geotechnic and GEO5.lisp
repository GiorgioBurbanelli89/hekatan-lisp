# GeoFEM T6 element: a real triangle of the Demo04 slope and its stiffness matrix, against Hekatan Geotechnic and GEO5
#numerico

#: **What is done.** **A single element** is taken from the mesh that GEO5 FEM (GeoFEM) generates for its official example **Demo04.gmk** (a slope in two soils, 628 nodes, 287 six-node triangles) and everything the program does with it before solving is redone by hand: shape functions, Jacobian, B matrix, constitutive matrix D, Gauss integration and the **12 × 12 stiffness matrix**.
#: **Judge.** Two, in a chain. (1) **Hekatan Geotechnic**, whose solver is GEO5 to 12 digits per Gauss point in the 3 stages of Demo04 (142 of 142 iterations equal); the element K comes from it, running its own code without touching it. (2) **GEO5 itself**: on 4-Sep-2026, with a debugger (Frida) attached to FRGeoFEM.exe, the strain and stress that GEO5 calculates at each Gauss point were read (routine FUN_005bb940, 17 digits). With that, **ε = B·u** is checked here against the internal numbers of GEO5.
#: **Units.** kN, m and kPa (kN/m²). The stiffness is shown in MN/m (thousands of kN/m) and the strains in microstrains (µε = 10⁻⁶).

## 1 · The element

#: It is element **36** of the mesh (counting from 0; nodes 56, 54, 57, 266, 267 and 268 of the Geotechnic model, which is the GEO5 mesh node by node). It is in **soil 1** (the upper, weak one: c = 9 kPa, φ = 22.7°), under the edge of the slope crest (which is at elevation −2.5 m), at x ≈ 21-23 m and z ≈ −9.3 to −6.8 m: right in the strip that yields first and through which the wedge that slides in GEO5 passes.
#: First the three **corners**, counterclockwise, and then the three **mid-side nodes** (between 1-2, 2-3 and 3-1). Coordinates as the model stores them:
x_n = [21; 23.0776; 22.47681; 22.0388; 22.7772; 21.7384] 'abscissa of nodes 1 to 6 [m]
y_n = [-9.25; -9.222663; -6.773686; -9.236332; -7.998174; -8.011843] 'elevation of nodes 1 to 6 [m]
#: The same, together in a 6 × 2 table (column 1: x; column 2: y):
X_e = [21, -9.25; 23.0776, -9.222663; 22.47681, -6.773686; 22.0388, -9.236332; 22.7772, -7.998174; 21.7384, -8.011843] 'coordinates of the 6 nodes [m]
#: Soil 1 of Demo04 (what GEO5 stores and Geotechnic reads from the .gmk):
E = 130347 'modulus of elasticity of soil 1 [kPa]
ν = 0.3 'Poisson's ratio of soil 1

#dibujo("Element 36 of Demo04: three corners and three mid-side nodes (elevations in m)", ud = m, escala = auto, cotas = m, alto = 200)
#  linea(21, -9.25, 22.0388, -9.236332, "gruesa")
#  linea(22.0388, -9.236332, 23.0776, -9.222663, "gruesa")
#  linea(23.0776, -9.222663, 22.7772, -7.998174, "gruesa")
#  linea(22.7772, -7.998174, 22.47681, -6.773686, "gruesa")
#  linea(22.47681, -6.773686, 21.7384, -8.011843, "gruesa")
#  linea(21.7384, -8.011843, 21, -9.25, "gruesa")
#  circulo(21, -9.25, 0.05, "rojo relleno")
#  circulo(23.0776, -9.222663, 0.05, "rojo relleno")
#  circulo(22.47681, -6.773686, 0.05, "rojo relleno")
#  circulo(22.0388, -9.236332, 0.05, "azul relleno")
#  circulo(22.7772, -7.998174, 0.05, "azul relleno")
#  circulo(21.7384, -8.011843, 0.05, "azul relleno")
#  texto(20.75, -9.45, "1", 3, "c")
#  texto(23.3, -9.45, "2", 3, "c")
#  texto(22.5, -6.55, "3", 3, "c")
#  texto(22.04, -9.5, "4", 3, "c")
#  texto(23.0, -7.95, "5", 3, "c")
#  texto(21.45, -7.95, "6", 3, "c")
#  circulo(22.18, -8.42, 0.04, "verde relleno")
#  texto(22.18, -8.62, "Gauss point 1", 2.4, "c", estilo = "verde")
#  cota(21, -9.75, 23.0776, -9.75, -0.1, "2.08")
#fin
#: Red: corners. Blue: mid-side nodes. Green: the centroid, which is the first Gauss point (the one of sheet 133).

## 2 · The shape functions of the six-node triangle

#: GeoFEM works with **area coordinates** L_{1}, L_{2} and L_{3} = 1 − L_{1} − L_{2}: they equal 1 at their corner and 0 on the opposite side. With six nodes the displacement inside the triangle is a **quadratic** polynomial (six terms, six nodes). The six functions (the same ones, in the same order, as t6() of the Geotechnic solver):
N_6(L_1, L_2) = [L_1*(2*L_1 - 1), L_2*(2*L_2 - 1), (1 - L_1 - L_2)*(2*(1 - L_1 - L_2) - 1), 4*L_1*L_2, 4*L_2*(1 - L_1 - L_2), 4*(1 - L_1 - L_2)*L_1] 'shape functions: 3 corner and 3 mid-side
#: Their derivatives with respect to L_{1} and L_{2} (row 1 and row 2). Since L_{3} depends on the other two, each derivative of L_{3} enters with a minus sign:
dN_6(L_1, L_2) = [4*L_1 - 1, 0, -(4*(1 - L_1 - L_2) - 1), 4*L_2, -4*L_2, 4*(1 - L_1 - L_2) - 4*L_1; 0, 4*L_2 - 1, -(4*(1 - L_1 - L_2) - 1), 4*L_1, 4*(1 - L_1 - L_2) - 4*L_2, -4*L_1] 'derivatives of the six functions with respect to L₁ (row 1) and L₂ (row 2)
#: **Check.** At any point they add up to 1 (an equal displacement at the six nodes moves the whole triangle equally). At L_{1} = 0.2, L_{2} = 0.3:
s_N = sum(N_6(0.2, 0.3)) 'sum of the six functions at an arbitrary point
#: **Seeing them.** A corner function is a «tent» that rises to 1 at its node and sinks below 0 in the middle of the sides (that is what makes it quadratic). N₁ = L₁·(2·L₁ − 1) is plotted with x = L₁ and y = L₂ (the real triangle is the half x + y ≤ 1 of the square):
#surf(x*(2*x-1), [0 1], [0 1])
#: And a mid-side one, N₄ = 4·L₁·L₂: it equals 1 at the midpoint of side 1-2 (L₁ = L₂ = ½) and zero at the three corners:
#surf(4*x*y, [0 1], [0 1])

## 3 · The GeoFEM Gauss points

#: GeoFEM integrates with **7 points** in the triangle (Hammer quadrature of degree 5). It is not an assumption: the GEO5 dump calls its stress routine **7 times per element** and per pass, and the Geotechnic solver (copied from what was extracted) uses these same points and weights. The weights are divided by 2 because the reference triangle has area ½:
G_p = [1/3, 1/3; 0.1012865073235, 0.1012865073235; 0.7974269853531, 0.1012865073235; 0.1012865073235, 0.7974269853531; 0.4701420641051, 0.4701420641051; 0.0597158717898, 0.4701420641051; 0.4701420641051, 0.0597158717898] 'coordinates (L₁, L₂) of the 7 points
w_g = [0.225; 0.1259391805448; 0.1259391805448; 0.1259391805448; 0.1323941527885; 0.1323941527885; 0.1323941527885]/2 'weights of the 7 points
#: **Check.** The weights add up to the area of the reference triangle:
s_w = sum(w_g) 'sum of weights = ½

## 4 · The Jacobian: from the reference triangle to the real one

#: The real coordinates are interpolated with the same functions (**isoparametric** element): x = Σ N_{a}·x_{a}, y = Σ N_{a}·y_{a}. The Jacobian gathers how x and y change when moving in L_{1} and L_{2}:
#: J = [∂x/∂L₁, ∂y/∂L₁; ∂x/∂L₂, ∂y/∂L₂] = dN·X_{e}
#: At the first Gauss point (the centroid):
J_1 = dN_6(1/3, 1/3)*X_e 'Jacobian at Gauss point 1
dJ_1 = det(J_1) 'determinant of the Jacobian = 2 × real area [m²]
A_e = dJ_1/2 'element area [m²]
#: The derivatives with respect to x and y come from inverting J: [∂N/∂x; ∂N/∂y] = J⁻¹·dN.
d_xy = inv(J_1)*dN_6(1/3, 1/3) 'Cartesian derivatives of the 6 functions at point 1 [1/m]

## 5 · The B matrix and the D matrix

#: **B** converts the 12 node displacements (u_{x} and u_{y} of each, in the order u₁, v₁, u₂, v₂, …) into the three in-plane strains: ε_{x} = ∂u/∂x, ε_{y} = ∂v/∂y, γ_{xy} = ∂u/∂y + ∂v/∂x. At point 1:
#hide
B_1 = zeros(3, 12)
for a = 1:6
  B_1(1, 2*a - 1) = d_xy(1, a)
  B_1(2, 2*a) = d_xy(2, a)
  B_1(3, 2*a - 1) = d_xy(2, a)
  B_1(3, 2*a) = d_xy(1, a)
end
#show
B_1 'B matrix at Gauss point 1 [1/m]
#: **D** is the **plane strain** one (the slope is long: ε_{z} = 0). GeoFEM stores it as 4 × 4 (σ_{x}, σ_{y}, σ_{z}, τ_{xy}) because the out-of-plane stress σ_{z} = ν·(σ_{x} + σ_{y}) enters the plasticity (sheet 133). For the stiffness the in-plane part is enough:
f_D = E/((1 + ν)*(1 - 2*ν)) 'factor of the plane strain matrix [kPa]
D = f_D*[1 - ν, ν, 0; ν, 1 - ν, 0; 0, 0, (1 - 2*ν)/2] 'in-plane constitutive matrix [kPa]
G_s = E/(2*(1 + ν)) 'shear modulus = D(3,3) [kPa]

## 6 · The stiffness matrix: sum over the 7 points

#: K_{e} = ∫ Bᵀ·D·B dA = Σ_{q} Bᵀ·D·B·|J|·w_{q}. What sections 4 and 5 did is repeated at each point (the thickness is 1 m of slope):
#hide
K_e = zeros(12, 12)
#show
for q = 1:7
  dN_q = dN_6(G_p(q, 1), G_p(q, 2))
  J_q = dN_q*X_e
  d_q = inv(J_q)*dN_q
  B_q = zeros(3, 12)
  for a = 1:6
    B_q(1, 2*a - 1) = d_q(1, a)
    B_q(2, 2*a) = d_q(2, a)
    B_q(3, 2*a - 1) = d_q(2, a)
    B_q(3, 2*a) = d_q(1, a)
  end
  K_e = K_e + transpose(B_q)*D*B_q*det(J_q)*w_g(q)
end
#: It is shown in **four 6 × 6 blocks**, in MN/m. Top left, nodes 1-3 (corners) among themselves; bottom right, nodes 4-6 (mid-side) among themselves:
#hide
i_1 = [1, 2, 3, 4, 5, 6]
i_2 = [7, 8, 9, 10, 11, 12]
#show
K_11 = K_e(i_1, i_1)/1000 'corner-corner block [MN/m]
K_12 = K_e(i_1, i_2)/1000 'corner-mid block [MN/m]
K_22 = K_e(i_2, i_2)/1000 'mid-mid block [MN/m]
#: The mid-corner block is the transpose of K₁₂ (K is symmetric). The mid-node terms (322.9 MN/m) are almost triple those of the corners: in a T6 the mid nodes «carry» more stiffness.
#: **Physics checks.** K symmetric, and a rigid translation (all nodes 1 mm in x) produces no forces:
#hide
a_sim = max(max(abs(K_e - transpose(K_e))))
r_x = [1; 0; 1; 0; 1; 0; 1; 0; 1; 0; 1; 0]/1000
F_r = max(abs(K_e*r_x))
r_s = round(a_sim, 8)
r_F = round(F_r, 8)
#show
#: Maximum asymmetry: **@{r_s} kN/m**. Maximum force at the nodes from the rigid translation: **@{r_F} kN** (to 8 decimals; what remains is double rounding, of the order of 10⁻¹¹).

## 7 · Against Hekatan Geotechnic: the K of the same element

#: The matrix that the Geotechnic solver assembles for this element (its arrays Bc, dJw and D4, which are the ones it uses at each iteration), copied with all its digits:
#hide
K_ref = [104856.09822367188, 18063.733111389705, 33292.337372351925, -6444.907773201235, 1659.6656072880437, 12466.152446998982, -133169.26460751682, 25779.64028537574, -0.03401514035431319, -0.16242005026151674, -6638.802580654712, -49864.45565051294; 18063.733111389705, 35656.57011077325, -2267.1193116646987, 4843.709315434811, 8288.363985461812, 7041.720340830101, 9068.486439224693, -19374.72480546388, -0.16242004963021373, -0.0249790599195876, -33153.30180436189, -28167.249982514368; 33292.337372351925, -2267.1193116646987, 116107.86941863039, -44897.107941091635, 5410.306752558619, -12698.58568488964, -133169.38090281485, 9068.464383086486, -21641.134023038612, 50794.50285487617, 0.001382312511850614, -0.1543003166680137; -6444.907773201236, 4843.70931543481, -44897.107941091635, 67598.98206397063, -8520.797223352478, 17689.38366142077, 25779.61822923753, -19374.943996707916, 34083.34900872513, -70757.29774679425, -0.15430031729738403, 0.1667026759369037; 1659.6656072880444, 8288.363985461812, 5410.306752558619, -8520.797223352478, 21209.890751779996, -697.3058526481565, -0.018365706986060104, 0.011856011006784684, -21641.405027741956, 34083.19241130584, -6638.439718177725, -33153.46517677802; 12466.152446998982, 7041.720340830101, -12698.58568488964, 17689.38366142077, -697.3058526481566, 74193.32773377914, 0.011856011006784684, -0.02669325185161142, 50794.34625745375, -70758.12141938061, -49864.61902292592, -28166.28362339756; -133169.26460751682, 9068.486439224693, -133169.38090281485, 25779.61822923753, -0.018365706985605357, 0.011856011005875189, 322898.1905179742, -36707.51213468322, -13277.361631182808, -83018.05248050028, -43282.16501075277, 84877.44809071027; 25779.64028537574, -19374.72480546388, 9068.464383086486, -19374.94399670792, 0.011856011007694178, -0.0266932518552494, -36707.51213468322, 236598.3768752575, -83018.05248050379, -56334.0766974797, 84877.44809071376, -141514.60468235414; -0.03401514035431319, -0.16242004963021373, -21641.134023038612, 34083.34900872513, -21641.405027741956, 50794.34625745375, -13277.361631182815, -83018.05248050379, 322898.6819178008, -36708.87845572436, -266338.7472206971, 34849.3980900989; -0.16242005026333572, -0.0249790599195876, 50794.50285487617, -70757.29774679424, 34083.19241130584, -70758.12141938061, -83018.05248050028, -56334.0766974797, -36708.87845572436, 236599.8061229753, 34849.39809009289, -38750.28528026076; -6638.802580654708, -33153.30180436189, 0.001382312515488593, -0.154300317301022, -6638.439718177725, -49864.61902292592, -43282.165010752775, 84877.44809071376, -266338.74722069706, 34849.39809009289, 322898.15314796974, -36708.77105320154; -49864.45565051294, -28167.24998251437, -0.15430031666983268, 0.16670267593872268, -33153.46517677802, -28166.283623397547, 84877.44809071027, -141514.60468235414, 34849.39809009891, -38750.28528026077, -36708.77105320153, 236598.25686585088]
dJw_1 = 0.5742472926683748
d_K = max(max(abs(K_e - K_ref)))
d_Kr = 100*d_K/max(max(abs(K_ref)))
d_J = 100*(dJ_1*w_g(1) - dJw_1)/dJw_1
r_K = round(d_K, 8)
r_Kr = round(d_Kr, 10)
#show
#: Largest difference between the two K, term by term: **@{r_K} kN/m** (to 8 decimals), that is **@{r_Kr} %** of the largest term (322 898 kN/m).
#: The terms that in K_{ref} are 0.03 or 0.16 kN/m (almost zero against 322 898) exist because the mid nodes of the model do not fall **exactly** at the middle of each side (the elevation of node 4 has 6 decimals). That is why |J| is not exactly equal at the 7 points: it is 5.10442 m² (twice the area) at all of them, but changes in the sixth digit from one point to another (|J|·w = 0.3214230 at point 2 and 0.3214233 at 3). This sheet reproduces them the same.

## 8 · Against GEO5: the strain at the 7 points

#: In the **first iteration** of Demo04 (stage 1, reduction factor 1) GeoFEM solves the elastic slope with all the self-weight. The displacement of the six nodes of this element in that iteration (from Geotechnic, which is that of GEO5 to 12 digits) is, in mm:
u_e = [-0.21944116174743908; -18.27511452760742; -0.12941416268067674; -18.919172101148858; 0.318999771740479; -20.018626130526677; -0.17859139025973192; -18.629156436727395; 0.06793001647263578; -19.54959315855677; 0.03428278222644265; -19.218099610541124] 'u₁, v₁, …, u₆, v₆ in iteration 1 [mm]
#: With the B of each point, ε = B·u. It is converted to µε (u in mm → ×1000):
#hide
e_h = zeros(7, 3)
for q = 1:7
  dN_q = dN_6(G_p(q, 1), G_p(q, 2))
  J_q = dN_q*X_e
  d_q = inv(J_q)*dN_q
  B_q = zeros(3, 12)
  for a = 1:6
    B_q(1, 2*a - 1) = d_q(1, a)
    B_q(2, 2*a) = d_q(2, a)
    B_q(3, 2*a - 1) = d_q(2, a)
    B_q(3, 2*a) = d_q(1, a)
  end
  e_q = 1000*B_q*u_e
  e_h(q, 1) = e_q(1)
  e_h(q, 2) = e_q(2)
  e_h(q, 3) = e_q(3)
end
#show
e_h 'ε_{x}, ε_{y}, γ_{xy} at the 7 points (rows), calculated here [µε]
#: What GEO5 had in memory at those same points (dump with Frida, dp_dump3_e1.txt, iteration 1). GEO5 runs through the points in another order: our point 1 is its 7th, 2 its 3rd, 3 its 1st, 4 its 2nd, and 5 to 7 are its 4th to 6th. Already ordered as here:
e_g5 = [33.601130614284883, -546.07359502585953, -123.71389243874369; 23.020793809996603, -441.86765670145654, -101.29839623730305; 33.213008503175779, -585.16397648758489, -170.56371543683856; 44.569575867166764, -611.18893520932614, -99.279467273746900; 39.839005327797579, -607.51055415502429, -136.92943281076730; 33.829949973011304, -523.02705926975807, -96.092495014139800; 27.134431793034591, -507.68309633596534, -138.11971529871514] 'GEO5 ε at the 7 points [µε]
#hide
d_e = max(max(abs(e_h - e_g5)))
d_er = 100*d_e/max(max(abs(e_g5)))
r_d = round(d_e, 8)
#show
#: Largest difference with GEO5 over the 21 values: **@{r_d} µε** (to 8 decimals; the real value is of the order of 10⁻¹⁰ µε, double rounding).
#: **Reading.** ε_{y} ≈ −500 µε: the soil shortens vertically under its own weight; ε_{x} is small and positive (it widens a little toward the hillside) and γ_{xy} ≈ −100 to −170 µε is the **shear** that already starts to mark the slide toward the left.

## 9 · Hekatan LISP against Geotechnic and GEO5

#hide
r_J = round(d_J, 10)
r_e = round(d_er, 10)
k_77 = round(K_e(7, 7), 4)
k_11 = round(K_e(1, 1), 4)
#show
#| Qué se compara | Hekatan LISP | Referencia | Diferencia |
#|---|---:|---:|---:|
#| K_{e}(1,1), esquina 1 en x [kN/m] | @{k_11} | 104856.0982 (Geotechnic) | — |
#| K_{e}(7,7), nudo medio 4 en x [kN/m] | @{k_77} | 322898.1905 (Geotechnic) | — |
#| **K_{e} completa, 144 términos** | — | Geotechnic | **@{r_Kr} %** del término mayor |
#| det J · w en el punto 1 [m²] | — | 0.5742472927 (Geotechnic) | @{r_J} % |
#| **ε en los 7 puntos, iteración 1** | e_{h} | GEO5 (Frida, 17 cifras) | **@{r_e} %** de la mayor |
#| simetría de K [kN/m] | @{r_s} | 0 | — |
#| fuerza por traslación rígida [kN] | @{r_F} | 0 | — |
#: **What is verified.** The shape functions, the 7 Gauss points, the Jacobian, B, plane strain D and the sum Bᵀ·D·B·|J|·w of this sheet are those of GeoFEM: the element K is that of Geotechnic term by term, and ε = B·u gives the same as GEO5 had in memory at the 7 points. The differences are double rounding (10⁻¹⁰ % or less).
#: **What is NOT verified here.** GEO5 does not let you see the K of an element (that routine was not dumped); K is compared against Geotechnic, and Geotechnic against GEO5 per Gauss point and node by node (registros/talud_geo5.md, 4-Sep-2026). Sheet 133 continues with the stress at that point 1 and its return to the yield surface.
