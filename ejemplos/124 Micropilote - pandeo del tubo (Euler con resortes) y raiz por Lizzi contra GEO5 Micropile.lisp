# Micropilote: pandeo del tubo con resortes del suelo (Euler) y raíz por Lizzi, contra GEO5
#numerico

#: **Qué se calcula.** El ejemplo oficial de GEO5 Micropile (**Demo01.gmp**): un micropilote inclinado 20°, de tubo de acero **TK 121 × 7** relleno de lechada, con 9.00 m de longitud libre y una **raíz** inyectada de 3.00 m y 0.30 m de diámetro, cargado con N = 120 kN y M = 9.5 kN·m. Se verifica lo mismo que GEO5: (1) la **estabilidad interna** del tubo (la carga crítica de pandeo dentro del suelo), (2) la **sección compuesta** acero + lechada con el efecto del pandeo, y (3) la **raíz** por la teoría de Lizzi.
#: **Cómo.** Con las fórmulas de la ayuda oficial de GEO5 2024 («Geometric Method (Euler)», «Modulus of Horizontal Reaction of Subsoil», «Influence of Buckling», «Micropile Lifetime», «Lizzi Theory»), leídas del archivo de ayuda.
#: **Juez.** El informe completo de GEO5 2024 del Demo01.gmp (ajuste «Safety factors (ASD)», SF = 1.50 en pandeo, sección y raíz).
#: **Unidades.** kN, m, MPa y mm (en la sección).

## 1 · Datos del ejemplo (Demo01.gmp)

#: **El tubo y la lechada.**
D_t = 121 'diámetro exterior del tubo [mm]
t_t = 7 'espesor de pared [mm]
f_y = 210 'resistencia del acero (dato del ejemplo) [MPa]
E_s = 210000 'módulo del acero [MPa]
E_g = 29000 'módulo de la lechada (hormigón de f_ck = 20 MPa) [MPa]
#: **Corrosión**: vida útil de 50 años en suelo natural; GEO5 toma de su tabla una pérdida de espesor r_{e} = 0.60 mm, con el coeficiente de unión F_{ut} = 1.
r_e = 0.60 'pérdida de espesor por corrosión [mm]
F_ut = 1.0 'coeficiente de unión micropilote-suelo
#: **La geometría.**
l_f = 9.00 'longitud libre del micropilote [m]
l_r = 3.00 'longitud de la raíz [m]
d_r = 0.30 'diámetro de la raíz [m]
α_i = 20 'inclinación respecto de la vertical [grados]
l_a = 1.00 'altura de la cabeza sobre el terreno [m]
#: **El suelo alrededor del tubo**: módulo de reacción E_{p} escrito en el marco de verificación.
E_p = 0.89 'módulo de reacción del suelo (dato del ejemplo) [MN/m3]
#: **La carga y lo que pide GEO5.**
N_d = 120 'fuerza normal [kN]
M_d = 9.5 'momento [kN·m]
SF_req = 1.50 'factor de seguridad pedido en pandeo, sección y raíz
#: **La raíz (Lizzi)**: fricción límite media y coeficiente del diámetro de la perforación (0.8 para 200 mm o más).
τ_m = 120 'fricción límite media en la raíz [kPa]
J_r = 0.80 'coeficiente del diámetro de la raíz

## 2 · La sección ideal (acero + lechada, pasada a acero)

#: Ayuda de GEO5 («Micropile Lifetime»): el área de acero se reduce con la corrosión por fuera, A_{a} = π/4·[(D − 2·r_{e})² − (D − 2·t)²]·F_{ut}. La lechada de dentro se pasa a acero con n = E_{g}/E_{s}.
D_e = D_t - 2·r_e 'diámetro exterior tras la corrosión [mm]
D_i = D_t - 2·t_t 'diámetro interior [mm]
n_E = E_g/E_s 'relación de módulos lechada/acero
A_a = pi/4·(D_e^2 - D_i^2)·F_ut 'área de acero [mm2]
A_g = pi/4·D_i^2 'área de lechada dentro del tubo [mm2]
A_i = A_a + n_E·A_g 'área de la sección ideal [mm2]
I_a = pi/64·(D_e^4 - D_i^4) 'inercia del acero [mm4]
I_i = I_a + n_E·pi/64·D_i^4 'inercia de la sección ideal [mm4]
i_r = sqrt(I_i/A_i) 'radio de giro [mm]
EI = E_s·I_i·1e-9 'rigidez a flexión de la sección ideal [kN·m2]

## 3 · Estabilidad interna: pandeo dentro del suelo (Euler)

#: Ayuda de GEO5 («Geometric Method (Euler)»): longitud efectiva l_{p} = libre + media raíz; reacción del suelo por metro E_{r} = E_{p}·D; número de semiondas n = (l_{p}/π)·(E_{r}/EI)^{1/4}.
l_p = l_f + l_r/2 'longitud efectiva [m]
E_r = E_p·1000·D_t/1000 'reacción del suelo por metro de micropilote [kN/m2]
n_w = l_p/pi·(E_r/EI)^(1/4) 'número de semiondas
#: **La cabeza fuera del suelo** (l_{v}) no tiene resortes: GEO5 reduce n y E_{r}. Aquí l_{v} es la parte **sobre el terreno medida a lo largo del eje inclinado**, l_{a}/cos α: así cuadra N_{cr}; con l_{a} = 1.00 m en vertical daría 611.86 kN.
l_v = l_a/cos(α_i·pi/180) 'longitud del micropilote fuera del suelo, sobre su eje [m]
n_r = l_v/l_p + (1 - l_v/l_p)·n_w 'semiondas reducidas
E_rr = E_r·(1 - l_v/l_p) 'reacción reducida [kN/m2]
#: Carga crítica, extremos articulados:
N_cr = EI·pi^2/l_p^2·n_r^2 + E_rr·l_p^2/pi^2/n_r^2 'carga crítica de pandeo [kN]
FS_cr = N_cr/N_d 'factor de seguridad al pandeo
#: Longitud de pandeo equivalente (ayuda, «Influence of Buckling»):
l_cr = sqrt(EI·pi^2/N_cr) 'longitud de pandeo [m]

## 4 · Sección compuesta con el efecto del pandeo

λ = l_cr·1000/i_r 'esbeltez
λ_p = λ·sqrt(f_y/210) 'esbeltez referida a 210 MPa
a_λ = (93/λ_p)^2
χ = 0.5·(1.26 + a_λ) - sqrt(0.25·(1.26 + a_λ)^2 - a_λ) 'coeficiente de pandeo (ayuda de GEO5, λp ≤ 250)
#: **La tensión en el acero** con N, M y χ: GEO5 imprime σ = 140.92 MPa y el eje neutro a −36.1 mm, pero la ayuda no da la fórmula. Se probaron N/(χ·A) + M·y/I con A e I del acero y de la sección ideal, con y en la cara exterior e interior y con el momento amplificado por 1/(1 − N/N_{cr}): ninguna da 140.92. Queda **pendiente** (sacarla de Micropile_5.dll); entra como dato:
σ_s = 140.92 'tensión en el acero, del informe de GEO5 [MPa]
FS_s = f_y/σ_s 'factor de seguridad de la sección

## 5 · La raíz: teoría de Lizzi

#: Ayuda de GEO5: Q = π·d·l·τ_{m}·J.
R_s = pi·d_r·l_r·τ_m·J_r 'resistencia de la raíz [kN]
FS_r = R_s/N_d 'factor de seguridad de la raíz

#dibujo("El micropilote inclinado 20°: 9 m libres (1 m sobre el terreno) y la raíz inyectada de 3 m", ud = m, cotas = m, escala = auto, alto = 120)
#  rect(-2, -12, 9, 12, "relleno naranja tenue sinborde")
#  linea(-2, 0, 7, 0, "media verde")
#  linea(-2, -4, 7, -4, "trazos")
#  texto(-1.9, -0.6, "limo con grava", 3.2, "i")
#  texto(-1.9, -4.6, "arcilla arenosa sólida", 3.2, "i")
#  linea(-0.342, 0.94, 2.736, -7.517, "gruesa")
#  poligono([2.595, 2.877, 3.903, 3.621], [-7.568, -7.465, -10.284, -10.387], "gruesa relleno gris")
#  flecha(-0.342 - 0.6·0.342, 0.94 + 0.6·0.94, -0.342, 0.94, "rojo")
#  texto(0, 1.6, "N = 120 kN, M = 9.5 kN·m", 3.2, "i")
#  texto(4.1, -9, "raíz: d = 0.30 m, l = 3.00 m", 3.2, "i")
#  texto(1.9, -3, "TK 121 × 7", 3.2, "i")
#  cota(7.3, 0, 7.3, -4, 0.2, "4.00")
#  cota(-0.342, 0.94, 2.736, -7.517, -0.5, "9.00 m libres")
#  cota(2.736, -7.517, 3.762, -10.336, 0.6, "raíz 3.00 m")
#fin

## 6 · NEC-SE-GC 2015

#: **Ninguna norma ecuatoriana regula los micropilotes**: la NEC-15 no los menciona (0 apariciones) y el borrador 2023 (no oficial) solo los cita en la bibliografía (Sabatini 2005, FHWA «Micropile Design and Construction»). Los factores SF_{f}, SF_{s} y SF_{r} quedan a criterio del ingeniero. Lo defendible (**criterio nuestro, no de la norma**): tratar la raíz como fuste de pilote y pedirle el FS = 3.0 de la Tabla 6.
FS_nec = 3.0 'criterio nuestro para la raíz (Tabla 6 de la NEC-15)
N_adm = R_s/FS_nec 'carga admisible de la raíz con FS = 3 [kN]
N_adm_t = N_adm/9.80665 'carga admisible de la raíz [tonf]
#hide
r_fr = round(FS_r, 2)
r_na = round(N_adm_t, 2)
#show
#: Con FS = 3 la raíz admite @{r_na} tonf; con la carga del ejemplo su FS es @{r_fr}: **no llegaría a 3.0**. Y la sección ya no cumple ni con el 1.50 del ejemplo.

## 7 · Hekatan contra GEO5

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
#: La sección ideal, el pandeo, la esbeltez, χ y la raíz cuadran a cuatro cifras. El n que imprime GEO5 es el **sin reducir** (1.93); para N_{cr} usa el reducido, n_{red} = 1.84. **Pendiente:** la tensión del acero en la sección compuesta (140.92 MPa) y el eje neutro (−36.1 mm): fórmula no publicada en la ayuda.
#: **Resultado del ejemplo:** pandeo SATISFACTORY (5.08 > 1.50), sección **NOT SATISFACTORY** (1.49 < 1.50) y raíz SATISFACTORY (2.26 > 1.50).
