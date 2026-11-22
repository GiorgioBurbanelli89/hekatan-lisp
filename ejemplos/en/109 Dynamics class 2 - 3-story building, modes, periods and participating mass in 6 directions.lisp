# Structural dynamics, class 2: several degrees of freedom — 3-story building, modes, periods and participating mass
#numerico

#: **What is done.** The frame from class 1 (sheet 108), now with **three stories**. Each slab is a mass and each story a spring. M and K are assembled by hand, det(K − ω²·M) = 0 is solved, the three vibration shapes are drawn and the mass moved by each mode is computed. At the end, the same building in 3D with its **six** participating-mass directions.
#: **Sources.** Chopra, *Dynamics of Structures*, 4th ed.: eq. 10.2.4 and 10.2.6 (eigenvalue problem), 13.1.5 (participation factor Γ), §13.2.5 (effective modal mass). NEC-SE-DS 2015 §6.2.2 e, "Number of modes" (p. 58).
#: **Units.** tonf, m, s (mass in tonf·s²/m); SI in parentheses where requested.

## 1 · The model: three masses and three springs

#: Plan of 6 × 6 m, the same four 40 × 50 cm columns per floor and 3 m story height (class 1). The slabs are assumed rigid: each floor is **one mass that only translates**. This is the **shear building**.
k_p = 8818.187592 'lateral stiffness of one story in X, from class 1: 4·12·E·0.8·I_g/h³ [tonf/m]
k_1 = k_p 'story 1 (base to floor 1) [tonf/m]
k_2 = k_p 'story 2 [tonf/m]
k_3 = k_p 'story 3 [tonf/m]
g = 9.80665 'gravity [m/s²]
m_1 = 1.0·36/g 'floor 1: 1.0 tonf/m² over 36 m² [tonf·s²/m]
m_2 = 1.0·36/g 'floor 2 [tonf·s²/m]
m_3 = 0.8·36/g 'roof: 0.8 tonf/m², no partitions [tonf·s²/m]
m_t = m_1 + m_2 + m_3 'total mass [tonf·s²/m]
m_tSI = m_t·g·1000 'the same in SI [kg]

#dibujo("Shear building: each slab is a mass, each story a spring", ud = m, alto = 150)
#  linea(-1, 0, 7, 0, "gruesa")
#  achurado(-1, -0.4, 8, 0.4, "diagonal")
#  linea(0, 0, 0, 9, "gruesa azul")
#  linea(6, 0, 6, 9, "gruesa azul")
#  rect(-0.2, 2.85, 6.4, 0.3, "gruesa")
#  rect(-0.2, 5.85, 6.4, 0.3, "gruesa")
#  rect(-0.2, 8.85, 6.4, 0.3, "gruesa")
#  texto(2.4, 3.4, "m₁, u₁", 3, "i")
#  texto(2.4, 6.4, "m₂, u₂", 3, "i")
#  texto(2.4, 9.4, "m₃, u₃", 3, "i")
#  texto(6.3, 1.4, "k₁", 3, "i")
#  texto(6.3, 4.4, "k₂", 3, "i")
#  texto(6.3, 7.4, "k₃", 3, "i")
#  flecha(6.6, 3.0, 7.6, 3.0, "rojo")
#  flecha(6.6, 6.0, 7.6, 6.0, "rojo")
#  flecha(6.6, 9.0, 7.6, 9.0, "rojo")
#  cota(-0.8, 0, -0.8, 9, -0.2, "3 × 3.00")
#fin

## 2 · The equations of motion, derived

#: Each slab is isolated and Newton is applied, just like in class 1. Floor i is pulled by the story below with k_{i}·(u_{i} − u_{i−1}) and by the one above with k_{i+1}·(u_{i+1} − u_{i}):
#: floor 1: m₁·ü₁ = −k₁·u₁ + k₂·(u₂ − u₁)
#: floor 2: m₂·ü₂ = −k₂·(u₂ − u₁) + k₃·(u₃ − u₂)
#: floor 3: m₃·ü₃ = −k₃·(u₃ − u₂)
#: Moving everything to the left and ordering by u₁, u₂, u₃ gives the same equation as in class 1, now with **matrices**:
#: **M·ü + K·u = 0**
M = [m_1, 0, 0; 0, m_2, 0; 0, 0, m_3] 'mass matrix: diagonal, each slab with its own [tonf·s²/m]
K = [k_1 + k_2, -k_2, 0; -k_2, k_2 + k_3, -k_3; 0, -k_3, k_3] 'stiffness matrix: tridiagonal [tonf/m]
#: Row i of K holds the forces on floor i when each floor moves one unit. That is why it is symmetric and only couples neighbors.

## 3 · The eigenvalue problem

#: As in class 1, u(t) = φ·cos(ω·t) is tried: **all floors vibrate with the same frequency and a fixed shape φ**. The acceleration is −ω²·φ·cos(ω·t) and, substituting (Chopra eq. 10.2.4):
#: **(K − ω²·M)·φ = 0**
#: For a nonzero shape φ to exist, the matrix must be singular (Chopra eq. 10.2.6):
#: **det(K − λ·M) = 0**, with λ = ω²
#: Expanding the determinant along the first row (the third column of row 1 is zero):
#: D(λ) = (k₁ + k₂ − λ·m₁)·[(k₂ + k₃ − λ·m₂)·(k₃ − λ·m₃) − k₃²] − k₂²·(k₃ − λ·m₃)
D(x) = (k_1 + k_2 - x·m_1)·((k_2 + k_3 - x·m_2)·(k_3 - x·m_3) - k_3^2) - k_2^2·(k_3 - x·m_3) 'the determinant as a function of λ
D_0 = D(0) 'D(0) = det(K) [tonf³/m³]
#: Check that the expansion is right: the engine's determinant with λ = 1000:
d_A = D(1000) 'hand expansion with λ = 1000
d_B = det(K - 1000·M) 'engine det() with λ = 1000
#: Plotted (divided by D(0) so it is readable): **each crossing with zero is a frequency of the building**. There are three because there are three floors.
#fplot(D_rel = ((k_1 + k_2 - x*m_1)*((k_2 + k_3 - x*m_2)*(k_3 - x*m_3) - k_3^2) - k_2^2*(k_3 - x*m_3))/D_0, cero = 0*x, [0 9000])
#: Horizontal axis: λ = ω² in (rad/s)²; vertical: D(λ)/D(0).

## 4 · The three roots

#: D(λ) is a polynomial of degree 3: D = c₃·λ³ + c₂·λ² + c₁·λ + c₀. Multiplying out the expansion term by term (with a = k₁ + k₂, b = k₂ + k₃, c = k₃):
a_k = k_1 + k_2 'a [tonf/m]
b_k = k_2 + k_3 'b [tonf/m]
c_k = k_3 'c [tonf/m]
c_3 = -m_1·m_2·m_3 'coefficient of λ³
c_2 = a_k·m_2·m_3 + m_1·(b_k·m_3 + c_k·m_2) 'coefficient of λ²
c_1 = -a_k·(b_k·m_3 + c_k·m_2) - m_1·(b_k·c_k - c_k^2) + k_2^2·m_3 'coefficient of λ
c_0 = a_k·(b_k·c_k - c_k^2) - k_2^2·c_k 'constant term (= D(0))
#: **The first root by Newton**, starting at λ = 0 (as would be done with a calculator): λ ← λ − D(λ)/D′(λ), with D′ = 3·c₃·λ² + 2·c₂·λ + c₁.
#hide
l_a = 0
#show
for i = 1:30
  l_a = l_a - (c_3·l_a^3 + c_2·l_a^2 + c_1·l_a + c_0)/(3·c_3·l_a^2 + 2·c_2·l_a + c_1)
end
lambda_1 = l_a 'first root λ₁ = ω₁² [(rad/s)²]
r_1 = D(lambda_1)/D_0 'relative residual: must be ≈ 0
#: **The other two without iterating.** If λ₁ is a root, D(λ) = (λ − λ₁)·(q₂·λ² + q₁·λ + q₀) (synthetic division), and the quadratic is solved with the usual formula:
q_2 = c_3 'coefficient of λ² of the quotient
q_1 = c_2 + c_3·lambda_1 'coefficient of λ of the quotient
q_0 = c_1 + q_1·lambda_1 'constant term of the quotient
d_q = sqrt(q_1^2 - 4·q_2·q_0) 'square root of the discriminant
lambda_2 = min((-q_1 + d_q)/(2·q_2), (-q_1 - d_q)/(2·q_2)) 'second root λ₂ [(rad/s)²]
lambda_3 = max((-q_1 + d_q)/(2·q_2), (-q_1 - d_q)/(2·q_2)) 'third root λ₃ [(rad/s)²]
#: **Frequencies and periods** (ω = √λ, T = 2·π/ω):
omega_1 = sqrt(lambda_1) 'mode 1 [rad/s]
omega_2 = sqrt(lambda_2) 'mode 2 [rad/s]
omega_3 = sqrt(lambda_3) 'mode 3 [rad/s]
T_1 = 2·pi/omega_1 'fundamental period [s]
T_2 = 2·pi/omega_2 'period of mode 2 [s]
T_3 = 2·pi/omega_3 'period of mode 3 [s]
#: The 1-story one gave 0.128 s; with 3 stories the fundamental is **0.272 s**: more mass hanging from springs in series. It is a short period because the slab was assumed rigid (high bound of k): real beams flex and lengthen it.

## 5 · The mode shapes

#: With each λ, (K − λ·M)·φ = 0 is solved by fixing φ₁ = 1. Row 1 gives φ₂ and row 3 gives φ₃:
#: φ₂ = (k₁ + k₂ − λ·m₁)/k₂ · φ₃ = k₃·φ₂/(k₃ − λ·m₃)
f_11 = 1 'mode 1, floor 1
f_21 = (k_1 + k_2 - lambda_1·m_1)/k_2 'mode 1, floor 2
f_31 = k_3·f_21/(k_3 - lambda_1·m_3) 'mode 1, floor 3 (roof)
f_12 = 1 'mode 2, floor 1
f_22 = (k_1 + k_2 - lambda_2·m_1)/k_2 'mode 2, floor 2
f_32 = k_3·f_22/(k_3 - lambda_2·m_3) 'mode 2, floor 3
f_13 = 1 'mode 3, floor 1
f_23 = (k_1 + k_2 - lambda_3·m_1)/k_2 'mode 3, floor 2
f_33 = k_3·f_23/(k_3 - lambda_3·m_3) 'mode 3, floor 3
#: Row 2 was not used: it must hold by itself. It is the proof that λ is a root:
e_1 = -k_2·f_11 + (k_2 + k_3 - lambda_1·m_2)·f_21 - k_3·f_31 'row 2 with mode 1: ≈ 0
#: For drawing they are scaled to roof = 1 (the shape matters, not the size):
p_11 = f_11/f_31 'mode 1 drawn, floor 1
p_21 = f_21/f_31 'mode 1 drawn, floor 2
p_12 = f_12/f_32 'mode 2 drawn, floor 1
p_22 = f_22/f_32 'mode 2 drawn, floor 2
p_13 = f_13/f_33 'mode 3 drawn, floor 1
p_23 = f_23/f_33 'mode 3 drawn, floor 2

#dibujo("The three modes (roof = 1). Mode 1: T = 0.2722 s · mode 2: T = 0.0987 s · mode 3: T = 0.0701 s", ud = m, alto = 150)
#  linea(0, 0, 0, 9, "trazos")
#  linea(6, 0, 6, 9, "trazos")
#  linea(12, 0, 12, 9, "trazos")
#  linea(-1, 0, 14, 0, "gruesa")
#  polilinea(0, 0, 1.5·p_11, 3, 1.5·p_21, 6, 1.5, 9, "gruesa azul")
#  polilinea(6, 0, 6 + 1.5·p_12, 3, 6 + 1.5·p_22, 6, 7.5, 9, "gruesa rojo")
#  polilinea(12, 0, 12 + 1.5·p_13, 3, 12 + 1.5·p_23, 6, 13.5, 9, "gruesa verde")
#  circulo(1.5·p_11, 3, 0.25, "azul relleno")
#  circulo(1.5·p_21, 6, 0.25, "azul relleno")
#  circulo(1.5, 9, 0.22, "azul relleno")
#  circulo(6 + 1.5·p_12, 3, 0.25, "rojo relleno")
#  circulo(6 + 1.5·p_22, 6, 0.25, "rojo relleno")
#  circulo(7.5, 9, 0.22, "rojo relleno")
#  circulo(12 + 1.5·p_13, 3, 0.25, "verde relleno")
#  circulo(12 + 1.5·p_23, 6, 0.25, "verde relleno")
#  circulo(13.5, 9, 0.22, "verde relleno")
#  texto(-0.6, 10.0, "mode 1", 3, "i")
#  texto(5.4, 10.0, "mode 2", 3, "i")
#  texto(11.4, 10.0, "mode 3", 3, "i")
#fin
#: **How to read them.** Mode 1 goes all to the same side and grows with height: it is the one that governs. Mode 2 crosses the axis once (one floor stays still in between) and mode 3 crosses twice. The more crossings, the shorter the period.

## 6 · How much mass each mode moves: Γ and effective mass

#: An earthquake pushes **all floors at once in the same direction**: r = [1; 1; 1]. How much of that push mode n takes is given by its **participation factor** (Chopra eq. 13.1.5):
#: **Γ_{n} = φ_{n}ᵀ·M·r / φ_{n}ᵀ·M·φ_{n} = L_{n}/M_{n}**
#: and the mass that behaves as a 1-degree oscillator (class 1) with the period of that mode is the **effective modal mass** (Chopra §13.2.5):
#: **M_{ef,n} = Γ_{n}²·M_{n} = L_{n}²/M_{n}**
L_1 = m_1·f_11 + m_2·f_21 + m_3·f_31 'φ₁ᵀ·M·r [tonf·s²/m]
M_1 = m_1·f_11^2 + m_2·f_21^2 + m_3·f_31^2 'φ₁ᵀ·M·φ₁, generalized mass [tonf·s²/m]
L_2 = m_1·f_12 + m_2·f_22 + m_3·f_32 'φ₂ᵀ·M·r [tonf·s²/m]
M_2 = m_1·f_12^2 + m_2·f_22^2 + m_3·f_32^2 'φ₂ᵀ·M·φ₂ [tonf·s²/m]
L_3 = m_1·f_13 + m_2·f_23 + m_3·f_33 'φ₃ᵀ·M·r [tonf·s²/m]
M_3 = m_1·f_13^2 + m_2·f_23^2 + m_3·f_33^2 'φ₃ᵀ·M·φ₃ [tonf·s²/m]
G_1 = L_1/M_1 'Γ₁, participation factor of mode 1
G_2 = L_2/M_2 'Γ₂
G_3 = L_3/M_3 'Γ₃
Me_1 = G_1^2·M_1 'effective mass of mode 1 [tonf·s²/m]
Me_2 = G_2^2·M_2 'effective mass of mode 2 [tonf·s²/m]
Me_3 = G_3^2·M_3 'effective mass of mode 3 [tonf·s²/m]
P_1 = 100·Me_1/m_t 'percentage of the total mass moved by mode 1 [%]
P_2 = 100·Me_2/m_t 'mode 2 [%]
P_3 = 100·Me_3/m_t 'mode 3 [%]
S_1 = P_1 'cumulative sum up to mode 1 [%]
S_2 = P_1 + P_2 'cumulative sum up to mode 2 [%]
S_3 = P_1 + P_2 + P_3 'sum with the three modes: must give 100 [%]
#: Γ depends on how φ is scaled (here φ₁ = 1); **M_{ef} does not**: it is a physical mass. That is why the NEC rule is measured as a mass percentage, not in Γ.
#: **The NEC-15 rule** (NEC-SE-DS 2015, §6.2.2 e, "Procedure 1: spectral analysis → Number of modes", p. 58), verbatim: *"all modes that involve the participation of an accumulated modal mass of at least 90% of the total mass of the structure, in each of the main horizontal directions considered"* must be taken into account.
#: Here mode 1 alone already moves **91.85 %**: it complies with one mode. In tall buildings, or with torsion, many more are needed (cpp06: 12 modes and in Y some were still missing).

## 7 · In 3D there are six directions

#: A node of a 3D model has **six** degrees of freedom: three translations (U_{x}, U_{y}, U_{z}) and three rotations (R_{x}, R_{y}, R_{z}). With a **rigid diaphragm** each slab is reduced to three: U_{x}, U_{y} and the plan rotation R_{z}. The rotation is opposed by the **polar mass moment** J = m·(a² + b²)/12 (plan a × b).
#: This building is symmetric (center of mass = center of rigidity), so the three families **do not couple** and each repeats the 3-story problem above with its own stiffness. Column of 40 in X and 50 in Y: higher stiffness in Y.
k_y = k_p·(0.5/0.4)^2 'story in Y: I grows with (50/40)² relative to X [tonf/m]
k_c = k_p/4 'one column in X [tonf/m]
k_cy = k_y/4 'one column in Y [tonf/m]
K_t = 4·(k_c·3^2 + k_cy·3^2) 'torsional stiffness of the story: Σ k·d², columns at 3 m from the center [tonf·m]
J_m = (6^2 + 6^2)/12 'J/m of a 6 × 6 m slab [m²]
#: Since the Y and rotation stiffnesses are proportional to those in X (same distribution per floor) and J = 6·m in all slabs, the shapes are **the same** and the λ are scaled:
T_y1 = T_1·sqrt(k_p/k_y) 'mode 1 of the Y family [s]
T_r1 = T_1·sqrt(k_p·J_m/K_t) 'mode 1 of the R_z rotation family [s]
#: Ordering the nine periods from longest to shortest: **mode 1 = U_{x} (0.2722 s), mode 2 = U_{y} (0.2177 s), mode 3 = R_{z} (0.1388 s)**; then come the second modes of each family (0.0987, 0.0790, 0.0701, 0.0561, 0.0504, 0.0358 s). Translation, translation and rotation: the healthy order (sheet 60).
#: **The six summations.** For the rotations, the earthquake "rotates" the base about the origin (plan center, at the base): a floor at height z moves z per radian. That is why a mode in X also contributes mass to R_{y} (with arm z) and one in Y to R_{x}:
z_1 = 3 'height of floor 1 [m]
z_2 = 6 'height of floor 2 [m]
z_3 = 9 'roof height [m]
L_r1 = m_1·f_11·z_1 + m_2·f_21·z_2 + m_3·f_31·z_3 'φ₁ᵀ·M·r with r = z (base rotation) [tonf·s²]
I_rb = m_1·z_1^2 + m_2·z_2^2 + m_3·z_3^2 'total inertia against base rotation, Σ m·z² [tonf·s²·m]
P_r1 = 100·L_r1^2/(M_1·I_rb) 'R_y contributed by mode 1 (= R_x of mode 2) [%]

#| Modo | T [s] | U_{x} | U_{y} | U_{z} | R_{x} | R_{y} | R_{z} |
#|---:|---:|---:|---:|---:|---:|---:|---:|
#| 1 | 0.2722 | 91.85 | 0 | 0 | 0 | 98.52 | 0 |
#| 2 | 0.2177 | 0 | 91.85 | 0 | 98.52 | 0 | 0 |
#| 3 | 0.1388 | 0 | 0 | 0 | 0 | 0 | 91.85 |
#| **Σ modos 1-3** | | **91.85** | **91.85** | **0** | **98.52** | **98.52** | **91.85** |
#| **Σ los 9 modos** | | **100** | **100** | **0** | **100** | **100** | **100** |

#: **U_{z} = 0**: this model has no vertical mass (like ETABS by default; SAP2000 does count it). Whether the vertical mass is included or not changes periods and summations: that is the subject of sheet 107 (seismic mass).
#: **R_{z} with three modes stays at 91.85 %** although U_{x} and U_{y} too: with 3 modes the NEC is met in both horizontal directions. But if mode 3 were not a rotation mode, R_{z} would be 0 and torsion would not be represented: that is why all six columns are checked, not just X and Y.

#: The 3D building with the real modes (drag to rotate). First mode 1, U_{x}:
#hide
X_n = zeros(16, 3)
for l = 0:3
  X_n(4·l + 1, 3) = 3·l
  X_n(4·l + 2, 1) = 6
  X_n(4·l + 2, 3) = 3·l
  X_n(4·l + 3, 1) = 6
  X_n(4·l + 3, 2) = 6
  X_n(4·l + 3, 3) = 3·l
  X_n(4·l + 4, 2) = 6
  X_n(4·l + 4, 3) = 3·l
end
e_s = zeros(3, 4)
e_f = zeros(12, 2)
for l = 1:3
  for c = 1:4
    e_s(l, c) = 4·l + c
    e_f(4·(l - 1) + c, 1) = 4·(l - 1) + c
    e_f(4·(l - 1) + c, 2) = 4·l + c
  end
end
v_f = zeros(12, 2)
s_1 = [0; p_11; p_21; 1]
s_r = [0; p_11; p_21; 1]
U_x = zeros(16, 3)
U_y = zeros(16, 3)
U_r = zeros(16, 3)
v_x = zeros(16, 1)
v_y = zeros(16, 1)
v_r = zeros(16, 1)
for l = 0:3
  for c = 1:4
    n = 4·l + c
    U_x(n, 1) = s_1(l + 1)
    U_y(n, 2) = s_1(l + 1)
    U_r(n, 1) = -0.25·s_r(l + 1)·(X_n(n, 2) - 3)
    U_r(n, 2) = 0.25·s_r(l + 1)·(X_n(n, 1) - 3)
    v_x(n) = s_1(l + 1)
    v_y(n) = s_1(l + 1)
    v_r(n) = 0.25·s_r(l + 1)·sqrt((X_n(n, 1) - 3)^2 + (X_n(n, 2) - 3)^2)
  end
end
#show
#modelo3d(X_n, e_s, e_f, v_x, v_f, U_x, 1.5)
#: Mode 2, U_{y} (the columns are stiffer in Y, so it is faster):
#modelo3d(X_n, e_s, e_f, v_y, v_f, U_y, 1.5)
#: Mode 3, R_{z}: the slabs rotate about the plan center, the corners are the ones that move the most:
#modelo3d(X_n, e_s, e_f, v_r, v_f, U_r, 1.5)

## 8 · Independent check (numpy / scipy)

#: The same building assembled as a **9-degree-of-freedom** model (U_{x}, U_{y}, R_{z} per floor, each column with its position) and solved with scipy.linalg.eigh, without any of the simplifications of this sheet:
#hide
n_T1 = 0.272179
n_T2 = 0.098737
n_T3 = 0.070122
n_Ty = 0.217743
n_Tr = 0.138828
n_P1 = 91.85
h_T1 = round(T_1, 6)
h_T2 = round(T_2, 6)
h_T3 = round(T_3, 6)
h_Ty = round(T_y1, 6)
h_Tr = round(T_r1, 6)
h_P1 = round(P_1, 2)
h_P2 = round(P_2, 2)
h_P3 = round(P_3, 2)
h_Pr = round(P_r1, 2)
x_T1 = round(100·(T_1 - n_T1)/n_T1, 3)
x_T2 = round(100·(T_2 - n_T2)/n_T2, 3)
x_T3 = round(100·(T_3 - n_T3)/n_T3, 3)
x_Ty = round(100·(T_y1 - n_Ty)/n_Ty, 3)
x_Tr = round(100·(T_r1 - n_Tr)/n_Tr, 3)
#show
#| Magnitud | Esta hoja | scipy (9 gdl) | Diferencia [%] |
#|---|---:|---:|---:|
#| T₁, modo 1 en X [s] | @{h_T1} | 0.272179 | @{x_T1} |
#| T₂, segundo modo en X [s] | @{h_T2} | 0.098737 | @{x_T2} |
#| T₃, tercer modo en X [s] | @{h_T3} | 0.070122 | @{x_T3} |
#| primer modo en Y [s] | @{h_Ty} | 0.217743 | @{x_Ty} |
#| primer modo de giro R_{z} [s] | @{h_Tr} | 0.138828 | @{x_Tr} |
#| masa efectiva modo 1 / 2 / 3 [%] | @{h_P1} / @{h_P2} / @{h_P3} | 91.85 / 7.19 / 0.96 | 0 |
#| R_{y} del modo 1 [%] | @{h_Pr} | 98.52 | 0 |
#: The same periods and percentages by two different routes: the determinant by hand with Newton, and the full 9 × 9 decomposition from scipy. Script: `hekatan-lisp/tests/numerico/clase_dinamica_9gdl.py`.
#: **Next: class 3 (sheet 110).** Where m comes from in a real building (Mass Source, slab mass distributed to nodes, with or without vertical mass) and what each slab type changes in m and in k, that is, in T.
