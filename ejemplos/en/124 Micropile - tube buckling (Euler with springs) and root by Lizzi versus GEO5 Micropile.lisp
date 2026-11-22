# Micropile: tube buckling with soil springs (Euler) and root by Lizzi, versus GEO5
#numerico

#: **What is computed.** The official GEO5 Micropile example (**Demo01.gmp**): a micropile inclined 20°, of **TK 121 × 7** steel tube filled with grout, with 9.00 m of free length and an injected **root** of 3.00 m and 0.30 m in diameter, loaded with N = 120 kN and M = 9.5 kN·m. It checks the same as GEO5: (1) the **internal stability** of the tube (the critical buckling load inside the soil), (2) the **composite section** steel + grout with the buckling effect, and (3) the **root** by Lizzi theory.
#: **How.** With the formulas of the official GEO5 2024 help («Geometric Method (Euler)», «Modulus of Horizontal Reaction of Subsoil», «Influence of Buckling», «Micropile Lifetime», «Lizzi Theory»), read from the help file.
#: **Judge.** The complete GEO5 2024 report of Demo01.gmp («Safety factors (ASD)» setting, SF = 1.50 for buckling, section and root).
#: **Units.** kN, m, MPa and mm (in the section).

## 1 · Example data (Demo01.gmp)

#: **The tube and the grout.**
D_t = 121 'outer diameter of the tube [mm]
t_t = 7 'wall thickness [mm]
f_y = 210 'steel strength (example data) [MPa]
E_s = 210000 'steel modulus [MPa]
E_g = 29000 'grout modulus (concrete with f_ck = 20 MPa) [MPa]
#: **Corrosion**: service life of 50 years in natural soil; GEO5 takes from its table a thickness loss r_{e} = 0.60 mm, with the bond coefficient F_{ut} = 1.
r_e = 0.60 'thickness loss by corrosion [mm]
F_ut = 1.0 'micropile-soil bond coefficient
#: **The geometry.**
l_f = 9.00 'free length of the micropile [m]
l_r = 3.00 'length of the root [m]
d_r = 0.30 'diameter of the root [m]
α_i = 20 'inclination from the vertical [degrees]
l_a = 1.00 'height of the head above the ground [m]
#: **The soil around the tube**: reaction modulus E_{p} typed in the verification frame.
E_p = 0.89 'soil reaction modulus (example data) [MN/m3]
#: **The load and what GEO5 asks for.**
N_d = 120 'normal force [kN]
M_d = 9.5 'moment [kN·m]
SF_req = 1.50 'safety factor required for buckling, section and root
#: **The root (Lizzi)**: average limit friction and drilling-diameter coefficient (0.8 for 200 mm or more).
τ_m = 120 'average limit friction at the root [kPa]
J_r = 0.80 'root diameter coefficient

## 2 · The ideal section (steel + grout, converted to steel)

#: GEO5 help («Micropile Lifetime»): the steel area is reduced by corrosion on the outside, A_{a} = π/4·[(D − 2·r_{e})² − (D − 2·t)²]·F_{ut}. The grout inside is converted to steel with n = E_{g}/E_{s}.
D_e = D_t - 2·r_e 'outer diameter after corrosion [mm]
D_i = D_t - 2·t_t 'inner diameter [mm]
n_E = E_g/E_s 'grout/steel modulus ratio
A_a = pi/4·(D_e^2 - D_i^2)·F_ut 'steel area [mm2]
A_g = pi/4·D_i^2 'grout area inside the tube [mm2]
A_i = A_a + n_E·A_g 'area of the ideal section [mm2]
I_a = pi/64·(D_e^4 - D_i^4) 'moment of inertia of the steel [mm4]
I_i = I_a + n_E·pi/64·D_i^4 'moment of inertia of the ideal section [mm4]
i_r = sqrt(I_i/A_i) 'radius of gyration [mm]
EI = E_s·I_i·1e-9 'flexural stiffness of the ideal section [kN·m2]

## 3 · Internal stability: buckling inside the soil (Euler)

#: GEO5 help («Geometric Method (Euler)»): effective length l_{p} = free + half root; soil reaction per meter E_{r} = E_{p}·D; number of half-waves n = (l_{p}/π)·(E_{r}/EI)^{1/4}.
l_p = l_f + l_r/2 'effective length [m]
E_r = E_p·1000·D_t/1000 'soil reaction per meter of micropile [kN/m2]
n_w = l_p/pi·(E_r/EI)^(1/4) 'number of half-waves
#: **The head outside the soil** (l_{v}) has no springs: GEO5 reduces n and E_{r}. Here l_{v} is the part **above ground measured along the inclined axis**, l_{a}/cos α: that is how N_{cr} matches; with l_{a} = 1.00 m vertical it would give 611.86 kN.
l_v = l_a/cos(α_i·pi/180) 'length of micropile outside the soil, along its axis [m]
n_r = l_v/l_p + (1 - l_v/l_p)·n_w 'reduced half-waves
E_rr = E_r·(1 - l_v/l_p) 'reduced reaction [kN/m2]
#: Critical load, pinned ends:
N_cr = EI·pi^2/l_p^2·n_r^2 + E_rr·l_p^2/pi^2/n_r^2 'critical buckling load [kN]
FS_cr = N_cr/N_d 'buckling safety factor
#: Equivalent buckling length (help, «Influence of Buckling»):
l_cr = sqrt(EI·pi^2/N_cr) 'buckling length [m]

## 4 · Composite section with the buckling effect

λ = l_cr·1000/i_r 'slenderness
λ_p = λ·sqrt(f_y/210) 'slenderness referred to 210 MPa
a_λ = (93/λ_p)^2
χ = 0.5·(1.26 + a_λ) - sqrt(0.25·(1.26 + a_λ)^2 - a_λ) 'buckling coefficient (GEO5 help, λp ≤ 250)
#: **The stress in the steel** with N, M and χ: GEO5 prints σ = 140.92 MPa and the neutral axis at −36.1 mm, but the help does not give the formula. We tried N/(χ·A) + M·y/I with A and I of the steel and of the ideal section, with y at the outer and inner face and with the moment amplified by 1/(1 − N/N_{cr}): none gives 140.92. It remains **pending** (extract it from Micropile_5.dll); it enters as data:
σ_s = 140.92 'stress in the steel, from the GEO5 report [MPa]
FS_s = f_y/σ_s 'section safety factor

## 5 · The root: Lizzi theory

#: GEO5 help: Q = π·d·l·τ_{m}·J.
R_s = pi·d_r·l_r·τ_m·J_r 'root resistance [kN]
FS_r = R_s/N_d 'root safety factor

#dibujo("The micropile inclined 20°: 9 m free (1 m above ground) and the injected root of 3 m", ud = m, cotas = m, escala = auto, alto = 120)
#  rect(-2, -12, 9, 12, "relleno naranja tenue sinborde")
#  linea(-2, 0, 7, 0, "media verde")
#  linea(-2, -4, 7, -4, "trazos")
#  texto(-1.9, -0.6, "silt with gravel", 3.2, "i")
#  texto(-1.9, -4.6, "solid sandy clay", 3.2, "i")
#  linea(-0.342, 0.94, 2.736, -7.517, "gruesa")
#  poligono([2.595, 2.877, 3.903, 3.621], [-7.568, -7.465, -10.284, -10.387], "gruesa relleno gris")
#  flecha(-0.342 - 0.6·0.342, 0.94 + 0.6·0.94, -0.342, 0.94, "rojo")
#  texto(0, 1.6, "N = 120 kN, M = 9.5 kN·m", 3.2, "i")
#  texto(4.1, -9, "root: d = 0.30 m, l = 3.00 m", 3.2, "i")
#  texto(1.9, -3, "TK 121 × 7", 3.2, "i")
#  cota(7.3, 0, 7.3, -4, 0.2, "4.00")
#  cota(-0.342, 0.94, 2.736, -7.517, -0.5, "9.00 m free")
#  cota(2.736, -7.517, 3.762, -10.336, 0.6, "root 3.00 m")
#fin

## 6 · NEC-SE-GC 2015

#: **No Ecuadorian code regulates micropiles**: the NEC-15 does not mention them (0 occurrences) and the 2023 draft (unofficial) only cites them in the bibliography (Sabatini 2005, FHWA «Micropile Design and Construction»). The factors SF_{f}, SF_{s} and SF_{r} are left to the engineer's judgment. What is defensible (**our own criterion, not the code's**): treat the root as a pile shaft and require the FS = 3.0 of Table 6.
FS_nec = 3.0 'our own criterion for the root (NEC-15 Table 6)
N_adm = R_s/FS_nec 'allowable load of the root with FS = 3 [kN]
N_adm_t = N_adm/9.80665 'allowable load of the root [tonf]
#hide
r_fr = round(FS_r, 2)
r_na = round(N_adm_t, 2)
#show
#: With FS = 3 the root allows @{r_na} tonf; with the example load its FS is @{r_fr}: it **would not reach 3.0**. And the section no longer passes even with the 1.50 of the example.

## 7 · Hekatan versus GEO5

#hide
g_Ai = 3520
g_Ii = 4570000
g_n = 1.93
g_lcr = 3.94
g_Ncr = 609.87
g_FScr = 5.08
g_la = 109.402
g_chi = 0.481
g_FSs = 1.49
g_Rs = 271.43
g_FSr = 2.26
h_Ai = round(A_i, -1)
h_Ii = round(I_i, -4)
h_n = round(n_w, 2)
h_lcr = round(l_cr, 2)
h_Ncr = round(N_cr, 2)
h_FScr = round(FS_cr, 2)
h_la = round(λ, 3)
h_chi = round(χ, 3)
h_FSs = round(FS_s, 2)
h_Rs = round(R_s, 2)
h_FSr = round(FS_r, 2)
x_Ai = round(100·(h_Ai/g_Ai - 1), 3)
x_Ii = round(100·(h_Ii/g_Ii - 1), 3)
x_n = round(100·(h_n/g_n - 1), 3)
x_lcr = round(100·(h_lcr/g_lcr - 1), 3)
x_Ncr = round(100·(h_Ncr/g_Ncr - 1), 4)
x_FScr = round(100·(h_FScr/g_FScr - 1), 3)
x_la = round(100·(h_la/g_la - 1), 4)
x_chi = round(100·(h_chi/g_chi - 1), 3)
x_FSs = round(100·(h_FSs/g_FSs - 1), 3)
x_Rs = round(100·(h_Rs/g_Rs - 1), 4)
x_FSr = round(100·(h_FSr/g_FSr - 1), 3)
#show
#| Magnitud | Hekatan | GEO5 2024 | Diferencia [%] |
#|---|---:|---:|---:|
#| A_{i} sección ideal [mm²] | @{h_Ai} | @{g_Ai} | @{x_Ai} |
#| J_{i} sección ideal [mm⁴] | @{h_Ii} | @{g_Ii} | @{x_Ii} |
#| semiondas n (sin reducir) | @{h_n} | @{g_n} | @{x_n} |
#| longitud de pandeo l_{cr} [m] | @{h_lcr} | @{g_lcr} | @{x_lcr} |
#| **N_{cr}** [kN] | @{h_Ncr} | @{g_Ncr} | @{x_Ncr} |
#| FS al pandeo | @{h_FScr} | @{g_FScr} | @{x_FScr} |
#| esbeltez λ | @{h_la} | @{g_la} | @{x_la} |
#| coeficiente de pandeo χ (GEO5: κ) | @{h_chi} | @{g_chi} | @{x_chi} |
#| FS de la sección (con σ de GEO5) | @{h_FSs} | @{g_FSs} | @{x_FSs} |
#| **R_{s}** de la raíz (Lizzi) [kN] | @{h_Rs} | @{g_Rs} | @{x_Rs} |
#| FS de la raíz | @{h_FSr} | @{g_FSr} | @{x_FSr} |
#: The ideal section, buckling, slenderness, χ and the root match to four figures. The n that GEO5 prints is the **unreduced** one (1.93); for N_{cr} it uses the reduced one, n_{red} = 1.84. **Pending:** the steel stress in the composite section (140.92 MPa) and the neutral axis (−36.1 mm): formula not published in the help.
#: **Example result:** buckling SATISFACTORY (5.08 > 1.50), section **NOT SATISFACTORY** (1.49 < 1.50) and root SATISFACTORY (2.26 > 1.50).
