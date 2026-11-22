# A plastic GeoFEM Gauss point: self-weight, elastic predictor and Drucker-Prager return, against GEO5
#numerico

#: **What is done.** **A single Gauss point** of the GEO5 FEM Demo04 slope is followed during the **first two Newton iterations** of stage 1 (self-weight, without reducing the strength): the strain that reaches it, the trial stress (elastic predictor), the Drucker-Prager yield function, the return to the surface and the algorithmic tangent that goes into the stiffness matrix of the next iteration.
#: **The point.** Gauss point 1 (the centroid) of element 36 of the mesh, the triangle of sheet 132: soil 1, at (22.18, −8.42) m, under the edge of the crest. It is one of the first to yield: at iteration 1 it already leaves the yield surface, like 154 more points of the 2009 of the slope.
#: **Where the algorithm comes from.** It is not from a book: it is **extracted from the binary** of GEO5 (FRGeoFEM.exe, module druckerprager_sh.cpp, decompiled on 15-Aug-2026: ingenieria-inversa/hekatan-geo5-bridge/EXTRAIDO_GeoFEM_DP_returnmap.md). FUN_005bfa20 sets the **extension** fit of the cone, FUN_005bd2b0 the return and FUN_005bc220 the tangent. The Hekatan Geotechnic solver is the port of that.
#: **Judge.** The numbers GEO5 had in memory at this point: the strain and the stress returned by its routine FUN_005bb940, dumped with Frida to 17 digits on 4-Sep-2026 (dp_dump3_e1.txt). The tangent, which GEO5 does not dump, is compared with that of Geotechnic.
#: **Units.** kPa, strains in µε (10⁻⁶). Compression negative, as in GEO5.

## 1 · The material of the point (soil 1 of Demo04)

E = 130347 'modulus of elasticity [kPa]
ν = 0.3 'Poisson's ratio
φ = 22.7 'internal friction angle [°]
c = 9 'cohesion [kPa]
γ = 18 'unit weight [kN/m³]
#: The dilatancy is ψ = 0 (Demo04 datum): when yielding the soil does not change volume. That will make the return very simple.
G = E/(2*(1 + ν)) 'shear modulus [kPa]
K_v = E/(3*(1 - 2*ν)) 'bulk modulus [kPa]
#: The **plane strain** elastic matrix with the 4 components GeoFEM stores (σ_{x}, σ_{y}, σ_{z}, τ_{xy}); the third strain, ε_{z}, is always 0, but σ_{z} is not:
f_D = E/((1 + ν)*(1 - 2*ν)) 'matrix factor [kPa]
D_e = f_D*[1 - ν, ν, ν, 0; ν, 1 - ν, ν, 0; ν, ν, 1 - ν, 0; 0, 0, 0, (1 - 2*ν)/2] '4 × 4 plane strain elastic matrix [kPa]

## 2 · The initial state: GeoFEM starts from ZERO stress

#: In the strength reduction of Demo04, GeoFEM does **not** impose a geostatic state (σ_{v} = γ·h, σ_{h} = K₀·σ_{v}) before starting: it starts with σ = 0 and applies **the whole self-weight** at once; the initial stress comes from solving the slope. This is how the binary does it (measured on 3-Sep-2026 in the GEO5 "course of analysis") and how Geotechnic copies it.
#: As an order of magnitude, the soil column over the point (all soil 1, up to the crest at −2.50 m) would give:
h = 8.41545 - 2.495 'depth of the point below the crest [m]
σ_v0 = -γ*h 'vertical stress of a column γ·h [kPa]
K_0 = ν/(1 - ν) 'elastic at-rest thrust coefficient (zero lateral strain)
σ_h0 = K_0*σ_v0 'horizontal stress with K₀ [kPa]
#: Further below it is seen that the slope, with its hillside on the left, gives somewhat less: part of the weight goes toward the hillside and the shear τ_{xy} is no longer zero.

## 3 · The strain that reaches the point (iteration 1)

#: At iteration 1 the matrix is the elastic one and the load is the whole weight: the displacements are those of the **elastic** slope. Sheet 132 checked that ε = B·u at this point is what GEO5 has in memory. The GEO5 value is taken (in µε, order ε_{x}, ε_{y}, ε_{z}, γ_{xy}):
Δε_1 = [33.601130614284883; -546.07359502585953; 0; -123.71389243874369]/1000000 'GEO5 strain increment, iteration 1

## 4 · The elastic predictor

#: Everything is assumed elastic: trial σ = previous σ + D_{e}·Δε. Since it starts from zero:
σ_tr = D_e*Δε_1 'trial stress: σ_x, σ_y, σ_z, τ_xy [kPa]
#: **The invariants.** I₁ = σ_{x} + σ_{y} + σ_{z} (first invariant), σ_{m} = I₁/3 (mean stress) and the deviatoric part s = σ − σ_{m}:
I_1 = σ_tr(1) + σ_tr(2) + σ_tr(3) 'first invariant [kPa]
σ_m = I_1/3 'mean stress [kPa]
s_d = σ_tr - σ_m*[1; 1; 1; 0] 'deviatoric stress [kPa]
#: J is the root of the second invariant of the deviator. With 4 components, τ_{xy} counts twice (τ_{xy} and τ_{yx}):
J_tr = sqrt(0.5*(s_d(1)^2 + s_d(2)^2 + s_d(3)^2) + s_d(4)^2) 'J = √J₂ of the trial [kPa]

## 5 · The GeoFEM Drucker-Prager surface

#: The binary (FUN_005bfa20) writes the yield function like this:
#: f = J + M_{φ}·(σ_{m} − c·cot φ),     M_{φ} = 2·√3·sin φ/(3 + sin φ)
#: with the **extension fit** (the cone passes through the extension vertices of the Mohr-Coulomb hexagon; the compression one would carry 3 − sin φ). Expanding, it is the same as the Geotechnic form f = J + α·I₁ − k:
#: α = M_{φ}/3 = 2·sin φ/(√3·(3 + sin φ)),     k = M_{φ}·c·cot φ = 6·c·cos φ/(√3·(3 + sin φ))
s_φ = sin(φ*pi/180) 'sine of φ
α = 2*s_φ/(sqrt(3)*(3 + s_φ)) 'slope of the cone
k = 6*c*cos(φ*pi/180)/(sqrt(3)*(3 + s_φ)) 'intercept of the cone, J with I₁ = 0 [kPa]
f_tr = J_tr + α*I_1 - k 'yield function at the trial [kPa]
#: **f > 0: the point leaves the cone.** The trial is not admissible and must be **returned** to the surface.
#: **Cone or vertex?** The vertex of the cone is at σ_{m} = c·cot φ (tension). With ψ = 0 the binary criterion (FUN_005bf160) reduces to: if σ_{m} < c·cot φ, return to the cone.
σ_ap = c/tan(φ*pi/180) 'mean stress of the vertex [kPa]
#: σ_{m} = −55.7 kPa (compression) is very far from the vertex (+21.5 kPa): **return to the cone**.

## 6 · The GeoFEM return (return mapping)

#: The binary solves a local Newton in [λ, c, sin φ, sin ψ]; without hardening and with ψ = 0 that Newton closes in one step and it remains:
#: σ_{m} does not change (ψ = 0: no volume change),   J_{new} = J_{tr} − G·λ,   λ = f_{tr}/G
#: That is, the deviator **shrinks** without rotating (**radial** return) until it touches the cone:
λ = f_tr/G 'plastic multiplier
J_n = J_tr - G*λ 'J after the return [kPa]
β = J_n/J_tr 'factor by which the deviator shrinks
σ_1 = σ_m*[1; 1; 1; 0] + β*s_d 'returned stress, iteration 1 [kPa]
#hide
f_1 = round(J_n + α*I_1 - k, 10)
#show
#: Check: after the return f = **@{f_1} kPa** (to 10 decimals): the point ends up exactly on the cone.
#: **The GEO5 stress** at this point, at the end of iteration 1 (its routine returns σ_{x}, σ_{y}, τ_{xy}, σ_{z}; reordered here):
σ_g1 = [-36.859652803705295; -90.187632607799515; -39.950835385134056; -5.6906155000751300] 'GEO5 σ, iteration 1 [kPa]
#hide
d_1 = max(abs(σ_1 - σ_g1))
r_1 = round(d_1, 8)
#show
#: Largest difference with GEO5: **@{r_1} kPa** (to 8 decimals).
#: **Reading.** The return lowers J from 33.21 to 30.47 kPa without touching σ_{m}: the point loses 2.74 kPa of shear, and that shear that "does not fit" in soil 1 has to be taken by the rest of the slope in iteration 2.

#dibujo("The point in the (−σm, J) plane: GeoFEM Drucker-Prager cone, trial and return (axes in kPa/10)", ud = m, escala = auto, alto = 220)
#  linea(-2.5, 0, 8.5, 0, "media")
#  linea(0, 0, 0, 4.6, "media")
#  texto(8.0, -0.35, "−σm", 3, "c")
#  texto(-0.6, 4.4, "J", 3, "c")
#  linea(-σ_ap/10, 0, 8.5, (k + 3*α*85)/10, "gruesa rojo")
#  texto(6.2, 3.9, "cone f = 0 (c = 9, φ = 22.7°)", 2.6, "c", estilo = "rojo")
#  circulo(-σ_m/10, J_tr/10, 0.08, "azul relleno")
#  texto(-σ_m/10 + 1.1, J_tr/10 + 0.15, "trial it 1", 2.4, "c", estilo = "azul")
#  flecha(-σ_m/10, J_tr/10, -σ_m/10, J_n/10, "azul")
#  circulo(-σ_m/10, J_n/10, 0.08, "verde relleno")
#  texto(-σ_m/10 - 1.3, J_n/10 - 0.2, "returned it 1", 2.4, "c", estilo = "verde")
#  circulo(-σ_ap/10, 0, 0.08, "negro relleno")
#  texto(-σ_ap/10, -0.35, "vertex", 2.4, "c")
#  texto(-σ_m/10, -0.35, "55.7", 2.4, "c")
#fin
#: With ψ = 0 the return is **vertical** in this plane (the zoom is at the end of section 8).

## 7 · The algorithmic tangent (the D that goes into the K of iteration 2)

#: After the return, the matrix with which GeoFEM assembles the stiffness of this point is no longer D_{e}: it is the **tangent consistent** with the return (FUN_005bc220). With the returned deviator s, its J, the direction w = s/(2·J) (with 2·τ_{xy} in the fourth) and n = w + α·[1; 1; 1; 0]:
p_1 = (σ_1(1) + σ_1(2) + σ_1(3))/3 'returned mean stress [kPa]
s_1 = σ_1 - p_1*[1; 1; 1; 0] 'returned deviator [kPa]
J_1 = sqrt(0.5*(s_1(1)^2 + s_1(2)^2 + s_1(3)^2) + s_1(4)^2) 'returned J [kPa]
w_1 = [s_1(1); s_1(2); s_1(3); 2*s_1(4)]/(2*J_1) 'flow direction (ψ = 0: deviatoric only)
n_1 = w_1 + α*[1; 1; 1; 0] 'normal to the cone
#: The "shrunken" stiffness Ξ = K·(1⊗1) + β·2G·P_{dev}, with P_{dev} the deviatoric projector and the fourth diagonal β·G (engineering shear):
P_d = [2/3, -1/3, -1/3, 0; -1/3, 2/3, -1/3, 0; -1/3, -1/3, 2/3, 0; 0, 0, 0, 1/2] 'deviatoric projector (fourth row for γ_xy)
U_1 = [1, 1, 1, 0; 1, 1, 1, 0; 1, 1, 1, 0; 0, 0, 0, 0] 'product 1⊗1
Ξ = K_v*U_1 + β*2*G*P_d 'shrunken elastic stiffness [kPa]
#: and the **non-symmetric** tangent (the normal n and the flow direction w are not equal because ψ ≠ φ):
D_ep = Ξ - (Ξ*w_1)*(transpose(n_1)*Ξ)/(transpose(n_1)*Ξ*w_1) 'algorithmic tangent [kPa]
#: The Geotechnic one for this point and this iteration:
D_ref = [125965.91495404902, 83649.72050275785, 36849.26571169705, 5301.3609180544245; 158701.88377211674, 159503.75815581746, 153415.7490486464, -9731.343717318105; 41199.70127383428, 82714.02134142473, 135602.48523965658, 4429.982799263682; 13310.15864831885, -1722.545987053678, 12438.780529528109, 44394.05680741031] 'Geotechnic tangent [kPa]
#hide
d_D = max(max(abs(D_ep - D_ref)))
r_D = round(d_D, 6)
a_D = round(max(max(abs(D_ep - transpose(D_ep)))), 1)
#show
#: Largest difference with Geotechnic: **@{r_D} kPa** (to 6 decimals, on terms of 160 000). The asymmetry of D_{ep} is **@{a_D} kPa**: the K of iteration 2 is no longer symmetric, and that is why GEO5 (and Geotechnic) factorizes it with a non-symmetric banded LU.

## 8 · Iteration 2: from the accumulated stress

#: At iteration 2 the point no longer starts from zero: it starts from σ₁. A small increment reaches it (the slope corrects the imbalance left by iteration 1). From GEO5, in µε:
Δε_2 = [-1.6283907571145694; -28.710233069497412; 0; -30.788147477639331]/1000000 'GEO5 strain increment, iteration 2
σ_tr2 = σ_1 + D_e*Δε_2 'new trial [kPa]
I_2 = σ_tr2(1) + σ_tr2(2) + σ_tr2(3) 'first invariant [kPa]
s_2 = σ_tr2 - I_2/3*[1; 1; 1; 0] 'trial deviator [kPa]
J_tr2 = sqrt(0.5*(s_2(1)^2 + s_2(2)^2 + s_2(3)^2) + s_2(4)^2) 'trial J [kPa]
f_tr2 = J_tr2 + α*I_2 - k 'yield at the trial [kPa]
#: It leaves again (f > 0) and the same radial return follows:
β_2 = (J_tr2 - f_tr2)/J_tr2 'deviator factor
σ_2 = I_2/3*[1; 1; 1; 0] + β_2*s_2 'returned stress, iteration 2 [kPa]
σ_g2 = [-39.663123089987600; -94.683769237691322; -42.537599968778423; -7.1021148426813845] 'GEO5 σ, iteration 2 [kPa]
#hide
d_2 = max(abs(σ_2 - σ_g2))
r_2 = round(d_2, 8)
#show
#: Largest difference with GEO5: **@{r_2} kPa** (to 8 decimals). That the GEO5 Δε₂ is what it is depends on the tangent K of the whole iteration 2; since the σ₂ that comes out here with it is that of GEO5, the tangent of step 7 is also right from that side.

#: **Up close**, the two iterations in the (−σ_{m}, J) plane. With ψ = 0 the return is **vertical**: it lowers J at constant σ_{m}, down to the red line:
#dibujo("Zoom: −σm from 52 to 62 kPa, J from 29 to 34 kPa (axes in kPa, shifted origin)", ud = m, escala = auto, alto = 200)
#  linea(0, 0, 10, 0, "media")
#  linea(0, 0, 0, 5, "media")
#  texto(9.5, -0.3, "−σm", 3, "c")
#  texto(0.4, 5, "J", 3, "c")
#  texto(0, -0.3, "52", 2.4, "c")
#  texto(10, -0.3, "62", 2.4, "c")
#  texto(-0.5, 0, "29", 2.4, "c")
#  texto(-0.5, 5, "34", 2.4, "c")
#  linea(0, k + 3*α*52 - 29, 10, k + 3*α*62 - 29, "gruesa rojo")
#  texto(9.2, k + 3*α*60 - 29 - 1.2, "cone f = 0", 2.6, "c", estilo = "rojo")
#  circulo(-σ_m - 52, J_tr - 29, 0.1, "azul relleno")
#  flecha(-σ_m - 52, J_tr - 29, -σ_m - 52, J_n - 29, "azul")
#  circulo(-σ_m - 52, J_n - 29, 0.1, "verde relleno")
#  texto(-σ_m - 52 - 1.4, J_tr - 29, "trial it 1", 2.4, "c", estilo = "azul")
#  texto(-σ_m - 52 - 1.5, J_n - 29 - 0.3, "returned it 1", 2.4, "c", estilo = "verde")
#  circulo(-I_2/3 - 52, J_tr2 - 29, 0.1, "azul relleno")
#  flecha(-I_2/3 - 52, J_tr2 - 29, -I_2/3 - 52, J_tr2 - f_tr2 - 29, "azul")
#  circulo(-I_2/3 - 52, J_tr2 - f_tr2 - 29, 0.1, "verde relleno")
#  texto(-I_2/3 - 52 + 1.4, J_tr2 - 29 + 0.2, "trial it 2", 2.4, "c", estilo = "azul")
#  texto(-I_2/3 - 52 + 1.5, J_tr2 - f_tr2 - 29 - 0.3, "returned it 2", 2.4, "c", estilo = "verde")
#fin
#: The point moves **on** the cone toward more compression: at each iteration the trial leaves a little again (2.74 kPa in the 1st, 0.59 kPa in the 2nd) and the return lowers it once more.

## 9 · Hekatan LISP against GEO5 and Geotechnic

#hide
h_J = round(J_tr, 6)
h_f = round(f_tr, 6)
h_l = round(1000000*λ, 4)
h_sx = round(σ_1(1), 6)
h_sy = round(σ_1(2), 6)
h_sz = round(σ_1(3), 6)
h_txy = round(σ_1(4), 6)
h_sy2 = round(σ_2(2), 6)
h_txy2 = round(σ_2(4), 6)
h_D11 = round(D_ep(1, 1), 4)
h_D12 = round(D_ep(1, 2), 4)
h_D21 = round(D_ep(2, 1), 4)
#show
#| Magnitud (punto 1 del elemento 36) | Hekatan LISP | GEO5 (Frida) / Geotechnic | Diferencia |
#|---|---:|---:|---:|
#| J de la prueba, it 1 [kPa] | @{h_J} | — | — |
#| f de la prueba, it 1 [kPa] | @{h_f} | > 0 en los dos | — |
#| λ·10⁶, it 1 | @{h_l} | — | — |
#| σ_{x} devuelta, it 1 [kPa] | @{h_sx} | −36.859653 (GEO5) | |
#| σ_{y} devuelta, it 1 [kPa] | @{h_sy} | −90.187633 (GEO5) | |
#| σ_{z} devuelta, it 1 [kPa] | @{h_sz} | −39.950835 (GEO5) | |
#| τ_{xy} devuelta, it 1 [kPa] | @{h_txy} | −5.690616 (GEO5) | |
#| **σ completa, it 1** | | **GEO5** | **@{r_1} kPa** |
#| D_{ep}(1,1) / (1,2) / (2,1) [kPa] | @{h_D11} / @{h_D12} / @{h_D21} | 125965.9150 / 83649.7205 / 158701.8838 (Geotechnic) | |
#| **D_{ep} completa (16 términos)** | | **Geotechnic** | **@{r_D} kPa** |
#| σ_{y} / τ_{xy} devueltas, it 2 [kPa] | @{h_sy2} / @{h_txy2} | −94.683769 / −7.102115 (GEO5) | |
#| **σ completa, it 2** | | **GEO5** | **@{r_2} kPa** |
#: **What is verified.** The elastic predictor, the Drucker-Prager yield function with the extension fit, the radial return with λ = f/G and the accumulation of σ from one iteration to the next are those of GEO5, at this point, to double precision. The algorithmic tangent is the Geotechnic one; against GEO5 it is checked indirectly (σ of iteration 2).
#: **What does not enter here.** The vertex case (it does not apply to this point: it would make σ = c·cot φ on all three normals) and the full local Newton of the binary with hardening (Demo04 has no hardening: c and φ fixed). The reduction of c and φ for the safety factor is sheet 134.
