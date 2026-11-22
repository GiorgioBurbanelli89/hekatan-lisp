# Structural dynamics, class 1: one degree of freedom — mass, stiffness, period, damping and resonance
#numerico

#: **What this class is for.** It is the first of three (sheets 108, 109 and 110). It takes you from zero to the modal analysis of a building (class 2, sheet 109) and from there to the topics of seismic mass, slab types and time history (class 3, sheet 110). It comes **before** the video on base shear and response spectrum modal analysis (cpp06), which takes for granted what is derived here.
#: **Sources.** A. K. Chopra, *Dynamics of Structures*, 4th ed.: eq. 1.3.2 (lateral stiffness of the frame), 2.2.4 to 2.2.13 (damped free vibration), 3.2.4 to 3.2.8 (harmonic load and resonance). NEC-SE-DS 2015 §6.2.2 c (p. 57: ξ = 0.05) and §6.1.6 b (p. 54: cracked inertia 0.8·I_{g} in columns). ACI 318-19 §19.2.2.1 (concrete modulus).
#: **Units.** Those of Ecuador: tonf, m, s; f′c in kgf/cm². Where it matters the SI is also given (kN, kg, MPa). Mass in tonf·s²/m (= 1 t of mass ·9.80665).

## 1 · The simplest model: a mass on a spring

#: A mass m supported without friction and joined to a wall by a spring of stiffness k. It is pulled aside a distance u_{0} and released. Nothing else pushes it: this is **free vibration**.
#dibujo("One-degree-of-freedom oscillator: mass m, spring k, displacement u", ud = m, alto = 90)
#  linea(0, -0.2, 0, 1.4, "gruesa")
#  achurado(-0.3, -0.2, 0.3, 1.6, "concreto")
#  linea(-0.3, -0.2, 5.0, -0.2, "gruesa")
#  polilinea(0, 0.6, 0.4, 0.6, 0.6, 0.9, 0.9, 0.3, 1.2, 0.9, 1.5, 0.3, 1.8, 0.9, 2.1, 0.3, 2.3, 0.6, 2.6, 0.6, "media azul")
#  rect(2.6, -0.2, 1.2, 1.2, "gruesa")
#  texto(3.05, 0.35, "m", 4, "i")
#  texto(1.25, 1.05, "k", 4, "i")
#  flecha(2.6, 1.3, 3.6, 1.3, "rojo")
#  texto(3.0, 1.45, "u(t)", 3, "i")
#fin
#: A **one-story frame** is the same system: the slab is the mass and the columns are the spring. That is why everything that follows applies to a building.

## 2 · The equilibrium, derived

#: **Newton.** The sum of forces on the mass is its mass times its acceleration: ΣF = m·ü.
#: **The spring.** It pushes backward, proportional to how much it is stretched: F_{r} = −k·u (Hooke's law).
#: Equating: m·ü = −k·u, that is, the **equation of free motion**:
#: **m·ü + k·u = 0**
#: It is "inertia + elastic force = 0". There is no load on the right: the mass moves because of what it was given when released.
#: **A solution is tried** u(t) = u_{0}·cos(ω·t), which starts at u_{0} and at rest. Its velocity and its acceleration:
v_t = Diff{u_0·cos(w·t) @ t} 'velocity u̇(t)
a_t = Diff{Diff{u_0·cos(w·t) @ t} @ t} 'acceleration ü(t)
#: The acceleration is −ω² times the displacement. It is substituted into m·ü + k·u:
r_t = Simplify{m·Diff{Diff{u_0·cos(w·t) @ t} @ t} + k·u_0·cos(w·t)} 'what is left after substituting
#: For the remainder to be **zero at every instant**, the parenthesis (k − m·ω²) must be zero. From there come the three magnitudes of the vibration:
#: **ω = √(k/m)** (circular frequency, rad/s) · **T = 2·π/ω** (period, s: the time of one cycle) · **f = 1/T** (frequency, cycles per second, Hz)
#: ω does not depend on u_{0}: the period belongs **to the structure**, not to how hard it is pushed.

## 3 · The period and the mass, as y = m·x + b

#: Solving: T = 2·π·√(m/k). Doubling the mass **does not double** the period: it multiplies it by √2 = 1.414. To double T the mass must be **quadrupled**.
#: Taking logarithms gives a straight line:
#: **log T = ½·log m + log(2·π/√k)** → y = m·x + b with y = log T, x = log m, slope **½**, intercept b = log(2·π/√k).
#: The slope ½ is the square root. More stiffness only lowers the line (changes b), it does not tilt it. With the mass multiplied by n (1 = that of the frame in section 4):
#fplot(T_n = 0.128198*sqrt(x), T_lineal = 0.128198*x, [1 4])
#: Horizontal axis: n, times the mass; vertical axis: T in s. The lower curve is the real one (√n); the upper line is what would happen if T were proportional to m. With n = 4 the period only doubles (0.256 s), it does not quadruple.
#: The same oscillation with the mass ×1, ×2, ×3 and ×4 (horizontal axis: t in s; vertical: u/u_{0}):
#anim fplot(u = cos(2*pi*x/(0.128198*sqrt(n))), [0 0.5]), n = 1:0.05:4

## 4 · A one-story frame, with numbers

#: 6 × 6 m plan, four 40 × 50 cm columns (40 cm in the X direction), 3 m height, slab assumed **infinitely rigid** relative to the columns (upper bound of the stiffness: Chopra eq. 1.3.2).
f_c = 240 'concrete strength f′c [kgf/cm²]
f_cM = f_c·9.80665/100 'the same in SI [MPa]
E_cM = 4700·sqrt(f_cM) 'concrete modulus, ACI 318-19 §19.2.2.1 [MPa]
E_c = E_cM·1000/9.80665 'the same in tonf/m² (1 MPa = 101.97 tonf/m²)
b_x = 0.40 'column side in X [m]
b_y = 0.50 'column side in Y [m]
h_p = 3.0 'story height [m]
#: For the slab to move in X the column bends about its Y axis: the side that works is b_{x}. NEC-15 §6.1.6 b asks for cracked inertia: 0.8·I_{g} in columns.
I_x = 0.8·b_y·b_x^3/12 'cracked inertia for the motion in X [m⁴]
#: **Stiffness of a column fixed at top and bottom** (the slab does not rotate): the force that displaces it one unit. It comes from the Euler-Bernoulli beam with both ends without rotation:
#: **k_{c} = 12·E·I/h³**
k_c = 12·E_c·I_x/h_p^3 'lateral stiffness of one column in X [tonf/m]
k_x = 4·k_c 'lateral stiffness of the story in X: 4 columns in parallel [tonf/m]
k_xSI = k_x·9.80665 'the same in SI [kN/m]
#: **The mass.** It comes from the weight: m = W/g. With 1.0 tonf/m² of dead load over 36 m²:
q_D = 1.0 'weight per square meter of slab (dead load) [tonf/m²]
W_p = q_D·6·6 'story weight [tonf]
g = 9.80665 'gravity [m/s²]
m_p = W_p/g 'story mass [tonf·s²/m]
m_SI = W_p·1000 'the same mass in SI: 36 t of mass [kg]
#: **Period**, first the formula and then the numbers:
#: ω = √(k/m) · T = 2·π/ω · f = 1/T
omega_n = sqrt(k_x/m_p) 'circular frequency [rad/s]
T_n = 2·pi/omega_n 'natural period in X [s]
f_n = 1/T_n 'natural frequency [Hz]
#: **0.128 s**: the frame goes back and forth almost eight times per second. It is a short period because the slab was taken as rigid; with real beams the stiffness drops (Chopra eq. 1.3.5) and T rises.
#: Released from u_{0} = 1 cm (horizontal axis: t in s; vertical: u in cm):
#fplot(u = cos(omega_n*x), [0 0.5])

#dibujo("The one-story frame is an oscillator: the slab is m, the columns are k", ud = m, alto = 110)
#  linea(-0.5, 0, 6.5, 0, "gruesa")
#  achurado(-0.5, -0.3, 7.0, 0.3, "ground")
#  linea(0, 0, 0, 3, "trazos")
#  linea(6, 0, 6, 3, "trazos")
#  polilinea(0, 0, 0.15, 1.0, 0.45, 2.0, 0.6, 3.0, "gruesa azul")
#  polilinea(6, 0, 6.15, 1.0, 6.45, 2.0, 6.6, 3.0, "gruesa azul")
#  rect(0.6, 3.0, 6.0, 0.3, "gruesa")
#  achurado(0.6, 3.0, 6.0, 0.3, "concreto")
#  flecha(6.8, 3.15, 7.6, 3.15, "rojo")
#  texto(6.9, 3.4, "u(t)", 3, "i")
#  texto(3.2, 3.55, "m = W/g", 3, "i")
#  texto(2.2, 1.4, "k = 4·12·E·I/h³", 3, "i")
#  cota(-0.4, 0, -0.4, 3, -0.2, "h = 3.00")
#fin

## 5 · Damping: the vibration dies out

#: A real frame does not vibrate forever: cracks, joints and partitions dissipate energy. It is represented with a viscous damper c·u̇ and the equation becomes **m·ü + c·u̇ + k·u = 0**.
#: It is measured with the **fraction of critical damping** ξ = c/(2·m·ω). NEC-15 (§6.2.2 c, p. 57) builds its spectrum with **ξ = 0.05** (5 %).
xi = 0.05 'NEC-15 fraction of critical damping
omega_D = omega_n·sqrt(1 - xi^2) 'damped frequency, Chopra eq. 2.2.5 [rad/s]
#: With 5 % ω_{D} is almost equal to ω: damping **does not change the period**, it dies out the amplitude. The response (Chopra eq. 2.2.4, released from u_{0} without velocity):
#: u(t) = u_{0}·e^{−ξ·ω·t}·[cos(ω_{D}·t) + ξ/√(1 − ξ²)·sen(ω_{D}·t)]
#fplot(u = exp(-xi*omega_n*x)*(cos(omega_D*x) + xi*omega_n/omega_D*sin(omega_D*x)), envolvente = exp(-xi*omega_n*x), [0 1])
#: Horizontal axis: t in s; vertical: u/u_{0}. The upper curve is the **envelope** e^{−ξ·ω·t}: the peaks fall on it.
#: **Another straight line y = m·x + b.** The logarithm of the envelope is ln(u) = ln(u_{0}) − ξ·ω·t: a line with slope **−ξ·ω**. That is why, by measuring two successive peaks on site, ξ is obtained (logarithmic decrement, Chopra eq. 2.2.11: δ ≈ 2·π·ξ).
p_env = -xi·omega_n 'slope of ln(amplitude) against t [1/s]
N_50 = 0.11/xi 'cycles for the amplitude to fall to half, Chopra eq. 2.2.13
#: With ξ = 0 to 20 % (n·5 %), the same frame:
#anim fplot(u = exp(-(n/20)*omega_n*x)*cos(omega_n*x), [0 0.5]), n = 0:0.05:4

## 6 · Resonance: when the load goes at the rhythm of the structure

#: Now a harmonic load p(t) = p_{0}·sen(Ω·t) (a machine, or an earthquake with a dominant period). The equation is **m·ü + c·u̇ + k·u = p_{0}·sen(Ω·t)**.
#: After the start-up, the structure vibrates at the rhythm of the load with an amplitude u_{0} = (p_{0}/k)·R_{d}, where p_{0}/k is how much it would move with the load at rest and R_{d} is the **dynamic amplification factor** (Chopra eq. 3.2.4 and 3.2.10):
#: **R_{d} = 1/√[(1 − r²)² + (2·ξ·r)²]**, with r = Ω/ω (the frequency ratio)
#fplot(xi_2 = 1/sqrt((1 - x^2)^2 + (2*0.02*x)^2), xi_5 = 1/sqrt((1 - x^2)^2 + (2*0.05*x)^2), xi_10 = 1/sqrt((1 - x^2)^2 + (2*0.10*x)^2), xi_20 = 1/sqrt((1 - x^2)^2 + (2*0.20*x)^2), [0 3])
#: Horizontal axis: r = Ω/ω; vertical: R_{d}. Three zones:
#: · **r ≪ 1** (slow load): R_{d} ≈ 1, the structure follows it as if it were static.
#: · **r ≈ 1** (resonance): the load always pushes in the same sense and only damping brakes it. The peak equals 1/(2·ξ) (Chopra eq. 3.2.7).
#: · **r ≫ 1** (fast load): R_{d} → 0, the mass cannot keep up with it.
R_res = 1/(2·xi) 'amplification at resonance with ξ = 5 %
T_res = T_n 'period of the load that brings the frame into resonance [s]
#: **With 5 % the frame moves 10 times the static value.** That is why the building period compared with that of the ground matters: an earthquake with energy near 0.128 s punishes this frame.
#: And it does not arrive all at once: starting from rest, the amplitude grows cycle by cycle up to that cap (Chopra eq. 3.2.8). Vertical axis: u/(p_{0}/k); horizontal: t in s.
#fplot(u = R_res*(exp(-xi*omega_n*x) - 1)*cos(omega_n*x), envolvente = R_res*(1 - exp(-xi*omega_n*x)), [0 1.5])

## 7 · What to take away

#hide
r_k = round(k_x, 2)
r_m = round(m_p, 4)
r_w = round(omega_n, 3)
r_T = round(T_n, 4)
r_R = round(R_res, 1)
#show
#| Magnitud | Fórmula | Pórtico de 1 piso |
#|---|---|---:|
#| rigidez lateral | k = Σ 12·E·I/h³ | @{r_k} tonf/m |
#| masa | m = W/g | @{r_m} tonf·s²/m |
#| frecuencia circular | ω = √(k/m) | @{r_w} rad/s |
#| periodo | T = 2·π/ω | @{r_T} s |
#| amplificación en resonancia | 1/(2·ξ) | @{r_R} |

#: 1 · **m·ü + k·u = 0** is not memorized: it is Newton plus Hooke.
#: 2 · **T grows with √m and drops with √k**: it is the line of slope ½ on a logarithmic scale.
#: 3 · **ξ = 5 %** does not change the period; it limits resonance to 10 times the static value.
#: **Class 2 (sheet 109):** the same reasoning with three stories: three masses, one stiffness matrix, three periods and three mode shapes.
