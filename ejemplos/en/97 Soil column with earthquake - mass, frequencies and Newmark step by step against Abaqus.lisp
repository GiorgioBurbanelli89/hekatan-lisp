# Soil column with earthquake: mass, frequencies and Newmark step by step against Abaqus
#numerico

#: **What is computed.** A 12 m sand layer resting on rock. The rock moves with an acceleration pulse and the sand follows it, but not as a rigid block: the shear wave goes up, reflects at the free surface and comes back down. That is why the layer **amplifies** the motion and has **its own period**. It is the first step of the dynamic analysis of a retaining wall: knowing how the ground moves alone, before putting the wall on top.
#: **How.** Finite elements in time: (1) the mass M and stiffness K of the column; (2) its natural frequencies; (3) the equation of motion M·ü + K·u = −M·1·a_{g}(t), solved step by step with the Newmark method.
#: **Units.** kN, m, t (tonne = kN·s²/m) and s; displacements are shown in mm.
#: **Referee.** The same problem with 48 six-node triangles (T6) in plane strain, computed in Python (columna_ref.py), in Hekatan Geotechnic and in **Abaqus 2017** (CPE6 element): the three give the same numbers to 4 decimals (29-Sep-2026). This sheet does **not** compute that 2D model: it computes the column reduced to a bar (section 2) and **compares** with it (section 8).

## 1 · Data
H = 12 [m] 'height of the layer
A_s = 1 [m²] 'column plan: 1 m wide by 1 m deep
E_s = 25000 [kPa] 'SP sand (soil study of the Manabí wall)
ν = 0.28 'Poisson's ratio
γ_s = 18.5 [kN/m³] 'unit weight
g = 9.80665 [m/s²]
#: The mass per volume is the weight per volume divided by g; in kN, m and s it comes out in t/m³:
ρ = γ_s/g [t/m³]
#: In a horizontal layer that moves sideways the soil works **in shear**. The shear modulus G governs, not E:
G = E_s/(2·(1 + ν)) [kPa]
#: Shear wave velocity: how fast a disturbance from the base rises through the layer.
V_s = sqrt(G/ρ) [m/s]
#: **The earthquake**: the base is accelerated with a half sine of 0.2 s and amplitude 1 m/s² (≈ 0.10·g); afterwards it stays still.
#: a_{g}(t) = a_{0}·sin(π·t / t_{p}) for 0 ≤ t ≤ t_{p};   a_{g}(t) = 0 afterwards
a_0 = 1 [m/s²]
t_p = 0.2 [s]
#: Base acceleration in time (points of the same formula, every 0.01 s):
#fplot(a_g = [0.00 0.0000; 0.01 0.1564; 0.02 0.3090; 0.03 0.4540; 0.04 0.5878; 0.05 0.7071; 0.06 0.8090; 0.07 0.8910; 0.08 0.9511; 0.09 0.9877; 0.10 1.0000; 0.11 0.9877; 0.12 0.9511; 0.13 0.8910; 0.14 0.8090; 0.15 0.7071; 0.16 0.5878; 0.17 0.4540; 0.18 0.3090; 0.19 0.1564; 0.20 0.0000; 0.21 0.0000; 0.22 0.0000; 0.23 0.0000; 0.24 0.0000; 0.25 0.0000; 0.26 0.0000; 0.27 0.0000; 0.28 0.0000; 0.29 0.0000; 0.30 0.0000; 0.31 0.0000; 0.32 0.0000; 0.33 0.0000; 0.34 0.0000; 0.35 0.0000; 0.36 0.0000; 0.37 0.0000; 0.38 0.0000; 0.39 0.0000; 0.40 0.0000], [0 0.4])
#: Horizontal axis: t in s; vertical axis: a_{g} in m/s².

## 2 · The column and its mesh
#: **The 2D model (the referee's).** Column 1 m wide and 12 m high, split into 24 squares of 1.0 × 0.5 m, and each square into two T6 along the diagonal: 48 elements and 147 nodes. **Boundary:** the base is fixed; on both sides the vertical displacement is prevented and the horizontal one of the right side is **equal** to that of the left side at the same elevation. So the column behaves like a slice of a very wide ground layer: each elevation moves sideways, whole, without rotating.
#: **Why it can be reduced to a bar.** With those conditions the horizontal displacement u depends only on the height y, not on x. The whole slice at an elevation moves the same, and the column is a **shear bar**: the strain is γ_{xy} = du/dy and the stress τ = G·du/dy. The T6 sides have three nodes (every 0.25 m) with quadratic displacement; the bar is made with **three-node** elements of 0.5 m, the same 49 node levels of the 2D model.
#dibujo("2D T6 model (left) and the equivalent shear bar (right)", ud = m, ancho = 90, alto = 175)
#  rect(0, 0, 1, 12, "gruesa")
#  polilinea([0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0], [0, 0.5, 0.5, 1, 1, 1.5, 1.5, 2, 2, 2.5, 2.5, 3, 3, 3.5, 3.5, 4, 4, 4.5, 4.5, 5, 5, 5.5, 5.5, 6, 6, 6.5, 6.5, 7, 7, 7.5, 7.5, 8, 8, 8.5, 8.5, 9, 9, 9.5, 9.5, 10, 10, 10.5, 10.5, 11, 11, 11.5, 11.5, 12, 12], "fina")
#  circulo(0, [0, 0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75, 3, 3.25, 3.5, 3.75, 4, 4.25, 4.5, 4.75, 5, 5.25, 5.5, 5.75, 6, 6.25, 6.5, 6.75, 7, 7.25, 7.5, 7.75, 8, 8.25, 8.5, 8.75, 9, 9.25, 9.5, 9.75, 10, 10.25, 10.5, 10.75, 11, 11.25, 11.5, 11.75, 12], 0.05, "azul relleno")
#  circulo(0.5, [0, 0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75, 3, 3.25, 3.5, 3.75, 4, 4.25, 4.5, 4.75, 5, 5.25, 5.5, 5.75, 6, 6.25, 6.5, 6.75, 7, 7.25, 7.5, 7.75, 8, 8.25, 8.5, 8.75, 9, 9.25, 9.5, 9.75, 10, 10.25, 10.5, 10.75, 11, 11.25, 11.5, 11.75, 12], 0.05, "azul relleno")
#  circulo(1, [0, 0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75, 3, 3.25, 3.5, 3.75, 4, 4.25, 4.5, 4.75, 5, 5.25, 5.5, 5.75, 6, 6.25, 6.5, 6.75, 7, 7.25, 7.5, 7.75, 8, 8.25, 8.5, 8.75, 9, 9.25, 9.5, 9.75, 10, 10.25, 10.5, 10.75, 11, 11.25, 11.5, 11.75, 12], 0.05, "azul relleno")
#  empotramiento(-0.3, 0, 1.3, 0, 1)
#  texto(-0.25, 6, "v = 0", 2.4, "d")
#  texto(1.25, 6, "v = 0", 2.4, "i")
#  texto(0.5, 12.5, "u_{right} = u_{left}", 2.4, "c", estilo = "azul")
#  linea(3.5, 0, 3.5, 12, "gruesa")
#  circulo(3.5, [0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8, 8.5, 9, 9.5, 10, 10.5, 11, 11.5, 12], 0.09, "rojo relleno")
#  circulo(3.5, [0.25, 0.75, 1.25, 1.75, 2.25, 2.75, 3.25, 3.75, 4.25, 4.75, 5.25, 5.75, 6.25, 6.75, 7.25, 7.75, 8.25, 8.75, 9.25, 9.75, 10.25, 10.75, 11.25, 11.75], 0.06, "fina")
#  empotramiento(2.9, 0, 4.1, 0, 1)
#  flecha(0.5, -1.3, 1.8, -1.3, "naranja")
#  flecha(1.8, -1.3, 0.5, -1.3, "naranja")
#  texto(2.1, -1.3, "a_{g}(t)", 2.6, "i", estilo = "naranja")
#  texto(3.8, 12, "crest", 2.4, "i")
#  texto(3.8, 6, "24 elements of 3 nodes", 2.4, "i")
#  texto(3.8, 5.3, "49 nodes, h = 0.50 m", 2.4, "i")
#  cota(-0.9, 0, -0.9, 12, 0, "H = 12.00")
#fin
#: In the bar, large red circles: ends of each element; small black ones: middle nodes. In the 2D model, the 147 nodes (blue) lie on three verticals, x = 0, 0.5 and 1 m, every 0.25 m.
n_e = 24 'elements
h = H/n_e [m] 'height of each element
n_n = 2·n_e + 1 'bar nodes, from the base (1) to the crest (49)

## 3 · Element stiffness and mass
#: Inside the element, u(y) is interpolated with three second-degree shape functions, N₁, N₂ and N₃ (bottom end, center, top end), the same as the side of a T6. The stiffness comes from the shear energy and the mass from the kinetic energy:
#: K_{e} = ∫ G·A·N′ᵀ·N′ dy   (y from 0 to h)
#: M_{e} = ∫ ρ·A·Nᵀ·N dy   (y from 0 to h)
#: Integrated by hand, in the node order (bottom, center, top):
K_e = G·A_s/(3·h)·[7, -8, 1; -8, 16, -8; 1, -8, 7] [kN/m]
M_e = ρ·A_s·h/30·[4, 2, -1; 2, 16, 2; -1, 2, 4] [t]
#: **Consistent mass.** M_{e} comes from the same shape functions as K_{e}: it is the matrix used by Abaqus (CPE6), GEO5 and Geotechnic for second-order elements (checked with the element matrices that Abaqus writes). The **lumped mass** would put the mass only on the diagonal, at the nodes; it is cheaper, but with the same mesh it gives somewhat lower high frequencies (in the 2D model, f₃ = 7.4923 Hz instead of 7.4947).
#: **Assembly.** Element e goes to nodes 2e − 1, 2e and 2e + 1; its 3 × 3 are added into K and M of 49 × 49:
#hide
K = zeros(n_n, n_n)
M = zeros(n_n, n_n)
for e = 1:n_e
  for i = 1:3
    for j = 1:3
      p = 2·e - 2 + i
      q = 2·e - 2 + j
      K(p, q) = K(p, q) + K_e(i, j)
      M(p, q) = M(p, q) + M_e(i, j)
    end
  end
end
u_1n = ones(n_n, 1)
#show
#: **Mass check**: adding all the terms of M gives the mass of the whole column, ρ·A·H:
m_t = dot(u_1n, M·u_1n) [t]
m_ex = ρ·A_s·H [t]
#: **Removing the base.** Node 1 does not move relative to the rock: its row and column are deleted. 48 unknowns remain, K_{f} and M_{f}. The row of node 1 is not lost completely: the earthquake force on each free node is its **complete row** of M times the vector of ones, r_{g} = M·1, which includes the coupling with the base (this is how Abaqus does it; with only M_{f}·1 the curve separates by 2·10⁻⁵ mm).
#hide
n_f = n_n - 1
K_f = zeros(n_f, n_f)
M_f = zeros(n_f, n_f)
r_g = zeros(n_f, 1)
for i = 1:n_f
  for j = 1:n_f
    K_f(i, j) = K(i + 1, j + 1)
    M_f(i, j) = M(i + 1, j + 1)
  end
  for j = 1:n_n
    r_g(i) = r_g(i) + M(i + 1, j)
  end
end
#show
n_f

## 4 · Natural frequencies
#: **Exact.** A uniform layer of height H on a rigid base vibrates with f_{n} = (2n − 1)·V_{s} / (4·H): the first mode is a quarter wave over the layer height.
f_e1 = V_s/(4·H) [Hz]
f_e2 = 3·V_s/(4·H) [Hz]
f_e3 = 5·V_s/(4·H) [Hz]
T_1 = 1/f_e1 [s] 'fundamental period of the layer
#: **From the model, without computing eigenvalues.** The mode satisfies K·φ = ω²·M·φ. The **inverse iteration** repeats x ← K⁻¹·M·x: at each round mode 1 grows (ω₁²/ω₂²)⁻¹ = 9 times more than mode 2, and x becomes mode 1. With x normalized to xᵀ·M·x = 1, the **Rayleigh quotient** gives the frequency: ω² = xᵀ·K·x, f = ω / (2π). It starts with x = 1 (the whole column displaced equally). Each round prints f₁ in Hz:
#hide
K_i = inv(K_f)
x_1 = ones(n_f, 1)
#show
for k = 1:6
  y_k = K_i·(M_f·x_1)
  x_1 = y_k/sqrt(dot(y_k, M_f·y_k))
  f_k = sqrt(dot(x_1, K_f·x_1))/(2·pi)
  disp(f_k)
end
#: It converges very fast: the error of the Rayleigh quotient drops with the square of the vector error. It continues up to 40 rounds (hidden) and this remains:
#hide
for k = 1:40
  y_k = K_i·(M_f·x_1)
  x_1 = y_k/sqrt(dot(y_k, M_f·y_k))
end
#show
f_1 = sqrt(dot(x_1, K_f·x_1))/(2·pi) [Hz]
#: **Modes 2 and 3.** The same iteration always converges to mode 1. To get 2, at each round the **mode 1 part is removed from the vector** (orthogonality with respect to M): y ← y − (x₁ᵀ·M·y)·x₁. For 3 the parts of modes 1 and 2 are removed. Mode 3 converges more slowly (factor (ω₃/ω₄)² = 25/49 per round); 80 rounds are more than enough:
#hide
x_2 = ones(n_f, 1)
x_3 = ones(n_f, 1)
#show
for k = 1:80
  y_k = K_i·(M_f·x_2)
  y_k = y_k - dot(x_1, M_f·y_k)·x_1
  x_2 = y_k/sqrt(dot(y_k, M_f·y_k))
  y_k = K_i·(M_f·x_3)
  y_k = y_k - dot(x_1, M_f·y_k)·x_1
  y_k = y_k - dot(x_2, M_f·y_k)·x_2
  x_3 = y_k/sqrt(dot(y_k, M_f·y_k))
end
f_2 = sqrt(dot(x_2, K_f·x_2))/(2·pi) [Hz]
f_3 = sqrt(dot(x_3, K_f·x_3))/(2·pi) [Hz]
#: The three match the exact ones to 4 decimals. **With 2-node elements** (u linear per segment) much more mesh is needed for the same; computed separately in Python with the same data (not in this sheet):
#| Elementos | Nudos | f₁ [Hz] | f₂ [Hz] | f₃ [Hz] |
#|---|---:|---:|---:|---:|
#| 12 de 2 nudos | 13 | 1.500007 | 4.525757 | 7.629068 |
#| 24 de 2 nudos | 25 | 1.499204 | 4.504037 | 7.528169 |
#| 48 de 2 nudos | 49 | 1.499003 | 4.498616 | 7.503046 |
#| 96 de 2 nudos | 97 | 1.498953 | 4.497261 | 7.496773 |
#| 6 de 3 nudos | 13 | 1.498941 | 4.497961 | 7.508728 |
#| 12 de 3 nudos | 25 | 1.498937 | 4.496883 | 7.495617 |
#| **24 de 3 nudos (esta hoja)** | 49 | 1.498937 | 4.496814 | 7.494742 |
#| exacta | — | 1.498937 | 4.496810 | 7.494683 |
#: With the same 49 nodes, the 3-node element gives f₃ with 0.001 % error and the 2-node one, 0.11 %.

## 5 · Newmark: the equation of each step
#: **Equation of motion** with u measured relative to the base (relative displacement). Without damping:
#: M·ü + K·u = −r_{g}·a_{g}(t)
#: **Constant average acceleration** (Newmark with β = 1/4, γ = 1/2): within each step Δt the acceleration is taken as the average of that at the start and at the end. It is **unconditionally stable** (it does not blow up with any Δt) and removes no energy: the amplitude does not damp by itself.
β = 0.25
γ = 0.5
Δt = 0.005 [s] 'about 130 times smaller than the period T₁ and 40 steps per pulse
n_p = 400 'steps: 2 s
#: **Coefficients** (those of GEO5, read from its FRGeoFEM program, and those of Bathe's book, eq. 9.27–9.31):
b_1 = 1/(β·Δt^2) 'in 1/s²
b_2 = 1/(β·Δt) 'in 1/s
b_3 = 1/(2·β) - 1
b_4 = γ/(β·Δt) 'in 1/s
b_5 = γ/β - 1
b_6 = Δt/2·(γ/β - 2) [s]
#: b₄, b₅ and b₆ only multiply the damping C, which here is zero.
#: **One step**, from t_{n} to t_{n+1} = t_{n} + Δt. u_{n+1} is solved from the equation of motion written at the end of the step:
#: K_{ef}·u_{n+1} = −r_{g}·a_{g}(t_{n+1}) + M·(b₁·u_{n} + b₂·v_{n} + b₃·a_{n}),   with K_{ef} = K + b₁·M
#: a_{n+1} = b₁·(u_{n+1} − u_{n}) − b₂·v_{n} − b₃·a_{n}
#: v_{n+1} = v_{n} + Δt·((1 − γ)·a_{n} + γ·a_{n+1})
#: K_{ef} does not change from one step to the next (fixed Δt and elastic material): it is **inverted only once** outside the loop, and each step is just a matrix-by-vector multiplication.
#hide
K_ef = K_f + b_1·M_f
K_ei = inv(K_ef)
#show
#: **The loop.** It starts at rest (u = v = a = 0; a_{g}(0) = 0). It stores the crest displacement (last node) at each step, in mm, and keeps the largest in absolute value, its instant and the profile of the whole column at that instant. (The sheet loops come out folded: a click on the "for" line shows its code, which is that of the three equations above).
#hide
u_n = zeros(n_f, 1)
v_n = zeros(n_f, 1)
a_n = zeros(n_f, 1)
u_c = zeros(n_p + 1, 1)
u_p = zeros(n_f, 1)
u_m = 0
s_m = 0
#show
for s = 1:n_p
  t = s·Δt
  a_g = 0
  if t < t_p - 0.000001
    a_g = a_0·sin(pi·t/t_p)
  end
  R_n = -r_g·a_g + M_f·(b_1·u_n + b_2·v_n + b_3·a_n)
  u_s = K_ei·R_n
  a_s = b_1·(u_s - u_n) - b_2·v_n - b_3·a_n
  v_n = v_n + Δt·((1 - γ)·a_n + γ·a_s)
  u_n = u_s
  a_n = a_s
  u_c(s + 1) = 1000·u_n(n_f)
  if abs(u_c(s + 1)) > abs(u_m)
    u_m = u_c(s + 1)
    s_m = s
    u_p = u_n
  end
end

## 6 · Result: the crest in time
#: **Maximum crest displacement** relative to the base and its instant:
u_max = u_m [mm]
t_max = s_m·Δt [s]
#: Crest displacement u_{c}(t) in mm (horizontal axis: t in s). The curve is drawn with the numbers of the Python reference of the same bar model, one every 0.02 s, because the engine plots do not yet read vectors computed in the sheet. The table below checks that they coincide with those computed by this sheet:
#fplot(u_c = [0.00 0.000; 0.02, -0.021; 0.04, -0.165; 0.06, -0.542; 0.08, -1.240; 0.10, -2.314; 0.12, -3.785; 0.14, -5.633; 0.16, -7.800; 0.18, -10.178; 0.20, -12.526; 0.22, -14.499; 0.24, -15.886; 0.26, -16.549; 0.28, -16.425; 0.30, -15.524; 0.32, -13.936; 0.34, -11.816; 0.36, -9.370; 0.38, -6.816; 0.40, -4.273; 0.42, -1.726; 0.44 0.818; 0.46 3.363; 0.48 5.908; 0.50 8.443; 0.52 10.924; 0.54 13.194; 0.56 15.005; 0.58 16.175; 0.60 16.596; 0.62 16.224; 0.64 15.095; 0.66 13.321; 0.68 11.074; 0.70 8.566; 0.72 5.995; 0.74 3.453; 0.76 0.910; 0.78, -1.637; 0.80, -4.181; 0.82, -6.722; 0.84, -9.241; 0.86, -11.665; 0.88, -13.818; 0.90, -15.449; 0.92, -16.389; 0.94, -16.566; 0.96, -15.947; 0.98, -14.603; 1.00, -12.659; 1.02, -10.305; 1.04, -7.750; 1.06, -5.173; 1.08, -2.633; 1.10, -0.094; 1.12 2.457; 1.14 4.997; 1.16 7.533; 1.18 10.024; 1.20 12.377; 1.22 14.390; 1.24 15.826; 1.26 16.528; 1.28 16.455; 1.30 15.601; 1.32 14.050; 1.34 11.956; 1.36 9.512; 1.38 6.928; 1.40 4.349; 1.42 1.815; 1.44, -0.723; 1.46, -3.275; 1.48, -5.812; 1.50, -8.334; 1.52, -10.788; 1.54, -13.049; 1.56, -14.909; 1.58, -16.131; 1.60, -16.590; 1.62, -16.268; 1.64, -15.186; 1.66, -13.443; 1.68, -11.217; 1.70, -8.702; 1.72, -6.099; 1.74, -3.526; 1.76, -0.998; 1.78 1.540; 1.80 4.092; 1.82 6.625; 1.84 9.123; 1.86 11.529; 1.88 13.680; 1.90 15.366; 1.92 16.363; 1.94 16.573; 1.96 16.006; 1.98 14.707; 2.00 12.787], [0 2.4])
#hide
u_02 = u_c(41)
u_04 = u_c(81)
u_06 = u_c(121)
u_10 = u_c(201)
u_15 = u_c(301)
u_20 = u_c(401)
#show
#| t [s] | u_{c} de esta hoja [mm] | u_{c} dibujado [mm] |
#|---:|---:|---:|
#| 0.20 | @{u_02} | −12.526 |
#| 0.40 | @{u_04} | −4.273 |
#| 0.60 | @{u_06} | 16.596 |
#| 1.00 | @{u_10} | −12.659 |
#| 1.50 | @{u_15} | −8.334 |
#| 2.00 | @{u_20} | 12.787 |
#: **Reading.** While the pulse lasts (0 to 0.2 s) the base pushes and the column lags behind: the crest goes to the opposite side (negative values). Once the pulse is over, the layer keeps vibrating by itself in its **mode 1**: the peaks repeat every T₁ = 0.667 s (0.27, 0.60, 0.94, 1.27, 1.60, 1.94 s), alternating in sign every half period. Without damping the amplitude does not drop: the six peaks are between 16.59 and 16.60 mm, and the largest falls at t = @{t_max} s by a difference of 0.0002 mm with the one at 0.935 s.
#: **Why the layer amplifies.** If the ground were rigid, it would move with the base and the relative displacement would be zero. The wave takes H / V_{s} = 0.17 s to rise; the pulse lasts 0.2 s, of the order of that time, so the layer cannot follow it and is left vibrating.

## 7 · Height profile at the instant of the maximum
#hide
u_y2 = 1000·u_p(8)
u_y4 = 1000·u_p(16)
u_y6 = 1000·u_p(24)
u_y8 = 1000·u_p(32)
u_y10 = 1000·u_p(40)
u_y12 = 1000·u_p(48)
#show
#: Displacement of each elevation at t = @{t_max} s, computed by this sheet (in mm):
#| y [m] | 0 | 2 | 4 | 6 | 8 | 10 | 12 |
#|---|---:|---:|---:|---:|---:|---:|---:|
#| u [mm] | 0 | @{u_y2} | @{u_y4} | @{u_y6} | @{u_y8} | @{u_y10} | @{u_y12} |
#dibujo("Displacement profile at t = 0.600 s (horizontal scale: 1 mm = 0.25 m)", ud = m, ancho = 100, alto = 150)
#  linea(0, 0, 0, 12, "trazos gris")
#  empotramiento(-0.8, 0, 0.8, 0, 1)
#  polilinea([0.0000, 0.1105, 0.2210, 0.3315, 0.4423, 0.5528, 0.6635, 0.7740, 0.8845, 0.9948, 1.1050, 1.2155, 1.3260, 1.4365, 1.5473, 1.6580, 1.7688, 1.8795, 1.9905, 2.1010, 2.2113, 2.3213, 2.4303, 2.5385, 2.6455, 2.7510, 2.8550, 2.9568, 3.0563, 3.1530, 3.2468, 3.3375, 3.4243, 3.5073, 3.5860, 3.6603, 3.7300, 3.7948, 3.8545, 3.9093, 3.9588, 4.0028, 4.0413, 4.0740, 4.1008, 4.1220, 4.1370, 4.1460, 4.1490], [0, 0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75, 3, 3.25, 3.5, 3.75, 4, 4.25, 4.5, 4.75, 5, 5.25, 5.5, 5.75, 6, 6.25, 6.5, 6.75, 7, 7.25, 7.5, 7.75, 8, 8.25, 8.5, 8.75, 9, 9.25, 9.5, 9.75, 10, 10.25, 10.5, 10.75, 11, 11.25, 11.5, 11.75, 12], "gruesa rojo")
#  flecha(0, 12, 4.149, 12, "rojo")
#  flecha(0, 6, 2.6455, 6, "rojo")
#  texto(4.3, 12, "16.60 mm", 2.4, "i", estilo = "rojo")
#  texto(2.8, 6, "10.58 mm", 2.4, "i", estilo = "rojo")
#  texto(-0.15, 11.5, "y", 2.6, "d")
#fin
#: The red curve is drawn with the displacements of the Python reference (those of the table, to 3 decimals). It is almost a straight line at the bottom and curves at the top: the wave traveling through the layer, pictured at that instant. At the top the curve arrives vertical because at the free surface the shear stress is zero (τ = G·du/dy = 0).

## 8 · Comparison
#hide
d_m = round(100·(m_t/22.6376999 - 1), 6)
d_1 = round(100·(f_1/1.4989365979 - 1), 6)
d_2 = round(100·(f_2/4.4968143672 - 1), 6)
d_3 = round(100·(f_3/7.4947422039 - 1), 6)
d_u = round(100·(u_max/16.5962895 - 1), 6)
e_1 = round(100·(f_1/f_e1 - 1), 6)
e_2 = round(100·(f_2/f_e2 - 1), 6)
e_3 = round(100·(f_3/f_e3 - 1), 6)
#show
#: "2D FE" column: 48 T6, 147 nodes; **Python = Hekatan Geotechnic = Abaqus 2017 (CPE6)** to 4 decimals (between Geotechnic and Abaqus, at most 2·10⁻⁷). Those numbers are **quoted**, not computed in this sheet.
#| Magnitud | Esta hoja (barra, 49 nudos) | EF 2D (Python = Geotechnic = Abaqus) | Diferencia con EF 2D [%] | Exacta | Diferencia con la exacta [%] |
#|---|---:|---:|---:|---:|---:|
#| Masa total [t] | @{m_t} | 22.6377 | @{d_m} | ρ·A·H = 22.6377 | — |
#| f₁ [Hz] | @{f_1} | 1.498937 | @{d_1} | 1.498937 | @{e_1} |
#| f₂ [Hz] | @{f_2} | 4.496814 | @{d_2} | 4.496810 | @{e_2} |
#| f₃ [Hz] | @{f_3} | 7.494742 | @{d_3} | 7.494683 | @{e_3} |
#| u máx. coronación [mm] | @{u_max} | 16.596289 | @{d_u} | — | — |
#| instante del máximo [s] | @{t_max} | 0.600 | — | — | — |
#: **Honest reading.** The bar of 24 three-node elements gives **the same numbers as the 2D model** (mass, three frequencies and maximum, to 4 decimals; on the full curve the maximum difference with Python 2D is 3·10⁻⁵ mm). It is not a coincidence: with the sides tied and the vertical prevented, the T6 only works in shear and its side is the 3-node bar. Against the exact solution, the frequencies differ by less than 0.001 %; it is mesh error, which shows slightly more in mode 3.

## 9 · Conclusion and what is missing
#: A 12 m layer of SP sand (V_{s} = 72 m/s) has a natural period of 0.667 s. A 0.2 s, 0.1·g pulse on the rock leaves it vibrating with **16.6 mm** of relative displacement at the crest. With K, M and a five-line Newmark loop, this sheet reproduces the same result as Abaqus and Hekatan Geotechnic.
#: **What is missing** (the next steps of the dynamic analysis):
#: • **Damping** (Rayleigh, C = α·M + β·K, with ξ ≈ 5 %): without it the vibration never dies out, and a real soil does dissipate energy.
#: • **Absorbing boundary at the base**: here the rock is rigid and the downgoing wave bounces back entirely. A real rock lets part of the energy pass downward.
#: • **Nonlinear soil**: G drops and damping rises with shear strain; with strong earthquakes the response changes a lot.
#: • **The wall on top**: the next model is the Manabí wall on this layer, in 2D, with its own mass and the soil-structure interaction.
