# What is a NONLINEAR soil? Explained slowly
#numerico

#: This sheet is to UNDERSTAND, not to design. It is the sister of sheet 49 (the footing that lifts off). There the idea was: the soil can PUSH the footing, but it cannot PULL it. Here the idea is a different one, just as simple: **the soil carries shear only up to its strength**. Past that cap, it deforms without giving more force. Everything else follows from that.

## 1 · Linear versus nonlinear: a spring with a cap

#dibujo("The soil under the footing seen as springs (Winkler): each spring has a CAP", ud = m, escala = auto, cotas = m, alto = 110)
#  achurado(-1, -0.6, 2, 0.6, "concreto")
#  rect(-1, -0.6, 2, 0.6, "gruesa")
#  achurado(-0.2, 0, 0.4, 0.8, "concreto")
#  rect(-0.2, 0, 0.4, 0.8, "gruesa")
#  flecha(0, 1.5, 0, 0.85, "gruesa rojo")
#  texto(0.1, 1.35, "P", 3, "i")
#  polilinea(-0.800, -0.600, -0.800, -0.720, -0.730, -0.783, -0.870, -0.910, -0.730, -1.037, -0.870, -1.163, -0.730, -1.290, -0.870, -1.417, -0.800, -1.480, -0.800, -1.600, "media azul")
#  polilinea(-0.400, -0.600, -0.400, -0.720, -0.330, -0.783, -0.470, -0.910, -0.330, -1.037, -0.470, -1.163, -0.330, -1.290, -0.470, -1.417, -0.400, -1.480, -0.400, -1.600, "media azul")
#  polilinea(0.000, -0.600, 0.000, -0.720, 0.070, -0.783, -0.070, -0.910, 0.070, -1.037, -0.070, -1.163, 0.070, -1.290, -0.070, -1.417, 0.000, -1.480, 0.000, -1.600, "media azul")
#  polilinea(0.400, -0.600, 0.400, -0.720, 0.470, -0.783, 0.330, -0.910, 0.470, -1.037, 0.330, -1.163, 0.470, -1.290, 0.330, -1.417, 0.400, -1.480, 0.400, -1.600, "media azul")
#  polilinea(0.800, -0.600, 0.800, -0.720, 0.870, -0.783, 0.730, -0.910, 0.870, -1.037, 0.730, -1.163, 0.870, -1.290, 0.730, -1.417, 0.800, -1.480, 0.800, -1.600, "media azul")
#  achurado(-1.6, -1.9, 3.2, 0.3, "terreno")
#  linea(-1.6, -1.6, 1.6, -1.6, "gruesa")
#  texto(1.1, -1.05, "spring: q = min(k·δ, q_f)", 2.6, "i")
#  texto(0, -2.15, "firm soil", 2.4, "c")
#fin
#: LINEAR: twice the load gives twice the deformation. It is a straight line, like y = m·x + b with b = 0: q = k·δ. It never fails: put a thousand tonnes on it and it gives you a settlement a thousand times larger, but no alarm.
#: NONLINEAR: the soil is a spring with a CAP. While it is far from failure, it behaves like the straight line. When it reaches its capacity q_f, the curve goes FLAT: it can keep sinking, but it gives no more force. With k = 1 and q_f = 0.6 (first chart). It is written q = min(k·δ, q_f).
#: The animation (below) loads little by little: both curves go together up to δ = 0.6; then the soil one stays at 0.6 and the linear one keeps rising.
#fplot(lineal = x, suelo = 0.6 - (0.6 - x + abs(0.6 - x))/2, [0 1])
#anim fplot(lineal = x*(1 + sign(n/10 - x))/2, suelo = (0.6 - (0.6 - x + abs(0.6 - x))/2)*(1 + sign(n/10 - x))/2, [0 1]), n = 1:10

#dibujo("The COMPLETE spring law: the footing tilts; one edge lifts, the other reaches the cap", ud = m, escala = auto, cotas = m, alto = 120)
#  poligono(-1, -0.350, 1, -0.850, 1, -0.350, -1, 0.150, "gruesa")
#  flecha(0.45, 1.0, 0.45, -0.162, "gruesa rojo")
#  texto(0.55, 0.9, "P (off centre)", 2.6, "i")
#  polilinea(-0.800, -0.600, -0.800, -0.720, -0.730, -0.783, -0.870, -0.910, -0.730, -1.037, -0.870, -1.163, -0.730, -1.290, -0.870, -1.417, -0.800, -1.480, -0.800, -1.600, "media gris")
#  linea(-0.95, -0.55, -0.65, -0.55, "fina gris")
#  polilinea(-0.400, -0.500, -0.400, -0.632, -0.330, -0.702, -0.470, -0.841, -0.330, -0.980, -0.470, -1.120, -0.330, -1.259, -0.470, -1.398, -0.400, -1.468, -0.400, -1.600, "media azul")
#  polilinea(0.000, -0.600, 0.000, -0.720, 0.070, -0.783, -0.070, -0.910, 0.070, -1.037, -0.070, -1.163, 0.070, -1.290, -0.070, -1.417, 0.000, -1.480, 0.000, -1.600, "media azul")
#  polilinea(0.400, -0.700, 0.400, -0.808, 0.470, -0.865, 0.330, -0.979, 0.470, -1.093, 0.330, -1.207, 0.470, -1.321, 0.330, -1.435, 0.400, -1.492, 0.400, -1.600, "media azul")
#  polilinea(0.800, -0.800, 0.800, -0.896, 0.870, -0.947, 0.730, -1.048, 0.870, -1.149, 0.730, -1.251, 0.870, -1.352, 0.730, -1.453, 0.800, -1.504, 0.800, -1.600, "gruesa rojo")
#  achurado(-1.6, -1.9, 3.2, 0.3, "terreno")
#  linea(-1.6, -1.6, 1.6, -1.6, "gruesa")
#  texto(-1.05, -0.2, "lifts: q = 0 (CONTACT, sheet 49)", 2.4, "d")
#  texto(1.05, -1.05, "cap q_f: soil FAILURE (sheet 178)", 2.4, "i")
#  texto(0, -2.15, "in between: linear, q = k·δ", 2.4, "c")
#fin
#: **The complete spring law (sheets 49 and 178 together).** They are TWO different nonlinearities in the same spring, but they happen in different places: 1) if the footing LIFTS (δ < 0), the spring switches off: q = 0. It happens at the footing–soil CONTACT: the soil is not glued to the concrete, it can push but not pull (sheet 49). 2) In between, linear: q = k·δ (k comes from the soil modulus E or from the plate load test). 3) If it reaches the CAP q_f, the SOIL below fails in shear (its Mohr circle touches the c–φ line, section 2): q rises no more (this sheet). In one line: q = min(max(k·δ, 0), q_f).
#fplot(resorte = 0.6 - (0.6 - (x + abs(x))/2 + abs(0.6 - (x + abs(x))/2))/2, lineal = x, [-0.5 1])
#: In Plaxis or GEO5 each one has its place: the lift-off with INTERFACE elements between footing and soil; the cap with Mohr-Coulomb in the SOIL elements. SAFE or ETABS only have the first one («compression only» springs).

## 2 · When does a soil point reach the cap? Mohr's circle

#dibujo("A soil point A, under the footing edge: squeezed by σ_1 (from above) and σ_3 (from the sides)", ud = m, escala = auto, cotas = m, alto = 120)
#  achurado(-3, -3, 6, 3, "terreno")
#  linea(-3, 0, 3, 0, "gruesa")
#  achurado(-1, 0, 2, 0.5, "concreto")
#  rect(-1, 0, 2, 0.5, "gruesa")
#  achurado(-0.2, 0.5, 0.4, 0.7, "concreto")
#  rect(-0.2, 0.5, 0.4, 0.7, "gruesa")
#  flecha(0, 1.8, 0, 1.25, "gruesa rojo")
#  texto(0.1, 1.65, "P", 3, "i")
#  rect(0.75, -1.45, 0.5, 0.5, "gruesa denso gris")
#  flecha(1, -0.35, 1, -0.9, "gruesa rojo")
#  flecha(1, -2.05, 1, -1.5, "gruesa rojo")
#  texto(1.08, -0.45, "σ_1", 3, "i")
#  flecha(2.0, -1.2, 1.3, -1.2, "media azul")
#  flecha(0, -1.2, 0.7, -1.2, "media azul")
#  texto(2.05, -1.2, "σ_3", 3, "i")
#  texto(1, -2.35, "point A", 2.6, "c")
#  texto(-2.9, -2.75, "soil (c, φ)", 2.4, "i")
#  texto(-2.9, 0.15, "surface", 2.4, "i")
#fin
#: A soil point under the footing is squeezed by two principal stresses: σ_1 (the larger, almost vertical) and σ_3 (the smaller, from the sides). With them a circle is drawn: centre (σ_1 + σ_3)/2, radius (σ_1 − σ_3)/2. The radius is the maximum shear the point carries.
#: The soil resists a shear τ = c + σ·tan φ (Mohr-Coulomb line, c = cohesion, φ = friction angle). While the circle stays BELOW the line, the point is elastic and the linear model works. When the circle TOUCHES the line, the point yields.

c = 10 'cohesion [kPa]
phi_g = 25 'friction angle [degrees]
phi = phi_g·π/180
s_3 = 50 'side stress, fixed [kPa]

#: Three states of the same point, with σ_3 = 50 kPa and σ_1 = 100, 150 and 200 kPa (as the footing load grows, σ_1 grows). In the chart: falla = the Mohr-Coulomb line; c1, c2, c3 = the circles.
#fplot(falla = c + x·tan(phi), c1 = sqrt(abs(25^2 - (x - 75)^2))*(1 + sign(25 - abs(x - 75)))/2, c2 = sqrt(abs(50^2 - (x - 100)^2))*(1 + sign(50 - abs(x - 100)))/2, c3 = sqrt(abs(75^2 - (x - 125)^2))*(1 + sign(75 - abs(x - 125)))/2, [0 220])

#: How far each circle is from touching the line: the «yield function» F. With F < 0 the point is elastic; F = 0 touches; F > 0 would be IMPOSSIBLE (the circle crosses the line): the linear model gives stresses the soil cannot have.
F(s1, s3) = (s1 - s3)/2 - (s1 + s3)/2·sin(phi) - c·cos(phi)
F_1 = F(100, s_3)
F_2 = F(150, s_3)
F_3 = F(200, s_3)

## 3 · The strip footing: where the soil yields

#: A strip footing of width B with pressure p on the soil. The ELASTIC stresses under it have a closed form (strip load, Boussinesq/Michell, plane strain): if α is the angle under which the point «sees» the footing, σ_1,3 = (p/π)·(α ± sin α). The self-weight γ·d is added (with K0 = 1, a simplification). d = depth.

B = 2 'footing width [m]
g_s = 18 'unit weight [kN/m3]
#dibujo("Strip footing of width B on the soil: the point (x, y) «sees» the footing under the angle α", ud = m, escala = auto, cotas = m, alto = 120)
#  achurado(-4, -4, 8, 4, "terreno")
#  linea(-4, 0, 4, 0, "gruesa")
#  carga(-B/2, 0, B/2, 0, 0.6, 0.6, "p", "rojo")
#  circulo(1.8, -1.6, 0.06, "denso negro")
#  texto(1.9, -1.75, "(x, y)", 2.6, "i")
#  linea(1.8, -1.6, -B/2, 0, "fina azul")
#  linea(1.8, -1.6, B/2, 0, "fina azul")
#  texto(1.45, -1.05, "α", 3.2, "c")
#  cota(-B/2, 0.95, B/2, 0.95, 0, "B = {B:1} m")
#  flecha(-4, 0, -3.3, 0, "fina")
#  texto(-3.25, 0.08, "x", 2.6, "i")
#  flecha(-4, 0, -4, -0.7, "fina")
#  texto(-3.92, -0.75, "y", 2.6, "i")
#  texto(0, -4.35, "the map below is this same cut: x from −4 to 4 m, y from 0 to −4 m", 2.4, "c")
#fin
al(x, y) = atan((x + B/2)/(0.001 - y)) - atan((x - B/2)/(0.001 - y))
U(x, y, p) = ((p/π)·sin(al(x, y)))/((p/π·al(x, y) - g_s·y)·sin(phi) + c·cos(phi))

#: U is the UTILISATION of each point: shear it carries / shear it resists (circle radius over the distance to the line). U < 1: elastic. **U > 1: the linear model asks more than the soil gives: that zone has yielded.** Look at the level-1 isoline in the three maps.

#: The footing capacity (Prandtl-Reissner-Vesic, zero embedment):
N_q = exp(π·tan(phi))·tan(π/4 + phi/2)^2
N_c = (N_q - 1)/tan(phi)
N_g = 2·(N_q + 1)·tan(phi)
q_f = c·N_c + 0.5·g_s·B·N_g

#: Three loads: a quarter, a half and three quarters of q_f. y is the level (0 at the surface, −4 is 4 m deep). Ut caps U at 1 (Ut = min(U, 1)): so the three maps have the SAME scale 0 → 1 and **magenta is the yielded zone** (U ≥ 1).
p_1 = q_f/4
p_2 = q_f/2
p_3 = 3·q_f/4
Ut(u) = 1 - (1 - u + abs(1 - u))/2
U_1(x, y) = Ut(U(x, y, p_1))
U_2(x, y) = Ut(U(x, y, p_2))
U_3(x, y) = Ut(U(x, y, p_3))
#contourf(U_1(x, y), [-4 4], [-4 0])
#contourf(U_2(x, y), [-4 4], [-4 0])
#contourf(U_3(x, y), [-4 4], [-4 0])

#: What you see: already at p = q_f/4 two small spots yield at the EDGES of the footing (there the elastic shear shoots up). At half, the two spots have merged into a magenta bulb under the footing; at three quarters, the plastic bulb grows down and sideways. The linear model does not notice: its stresses are just multiplied by the load, and all the magenta is IMPOSSIBLE stress. Note: this map comes from ELASTIC stresses, so it exaggerates the plastic zone; its real size comes from the nonlinear calculation (section 4), which passes the excess on to the neighbouring points.

## 4 · Why the computer has to ITERATE

#: It is the same reason as in sheet 49. There the program did not know which part of the footing was in contact; here it does not know which soil points have yielded. So, in each load step:
#: 1) elastic trial: it computes the stress as if the soil were linear;
#: 2) it checks F at each Gauss point: if F > 0, that point went past the line;
#: 3) return: it brings it back to the line (F = 0) with a plastic multiplier Δλ;
#: 4) Newton: since bringing it back changed the equilibrium, it solves K·ΔU = residual again, until the residual is zero.
#: One point loaded little by little (q–ε curve of a test with constant σ_3, demo of the Mohr-Coulomb return from the soil video): the initial straight line is the linear model; the real curve bends and stays at q_f = 7.7427 t/m² (the theoretical one, to 4 decimals).
#fplot(lineal = -0.275 + 24.28·x, suelo = [0 0.381; 0.05 0.938; 0.1 2.153; 0.15 3.367; 0.2 4.581; 0.25 5.795; 0.3 7.009; 0.35 7.743; 0.5 7.743; 1 7.743; 1.5 7.743; 2 7.743], [0 2])

## In one line

#: NONLINEAR = the soil has a shear CAP. The linear model works while all Mohr circles stay under the line (U < 1, service load, settlements). If U > 1 anywhere (bearing capacity, slopes, earth pressure), you have to yield and iterate.
