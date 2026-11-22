# Reinforced concrete corbel (ACI 318-14, section 16.5): from the precast beam to the reinforcement
#numerico

#: **Who this sheet is for.** For someone designing a corbel for the first time. Each step says **what** is computed, **why** and **where** the formula comes from. If you change a datum (beam span, loads, f'c), the whole sheet is recalculated.
#: **What a corbel is.** It is a very short cantilever projecting from a column that serves as the seat of a precast beam. It is so short that the load falls almost **against the column**: the distance from the load to the column face (a_{v}) is less than the depth (d). That is why it is **not designed as a beam**: it does not work in "long" bending, but as a **compression strut** (the concrete pushing diagonally) tied by a **tension tie** (the steel on top pulling).
#: **The example.** Reinforced Concrete III notes (Eng. Stalin Alcívar Moreira), unit 1: a corbel on a 35 × 35 cm column that supports precast beams of 15 m span, with f'c = 350 kgf/cm² and Fy = 4200 kgf/cm². The numbers of the notes are reproduced here step by step (and the plate bearing check, which the notes leave pending, is added).
#: **Units.** kgf, cm and kgf/cm², as used in Ecuador. 1 tonf = 1000 kgf.

## 1 · How a corbel fails (and why three things are checked)

#: Tests (Kriz and Raths, 1965) show three main failure modes. The ACI design covers them **with three steels**, one for each failure:
#: **a) Flexure.** The steel on top yields and the concrete below crushes, as in a beam. It is avoided with the steel A_{f}.
#: **b) Diagonal tension.** An inclined crack starts at the edge of the bearing plate and crosses the corbel. It is avoided by limiting the shear (section 3) and with the horizontal stirrups A_{h}.
#: **c) Direct shear.** The corbel "peels off" the column along an almost vertical crack at the column face: the concrete of the corbel slides over that of the column. It is avoided with the **shear-friction** steel A_{vf}, which sews the crack.
#: In addition, the precast beam rests on a plate and tends to be restrained as it expands with temperature: that introduces a **horizontal tension** N_{uc} in the corbel, which is covered with the steel A_{n}. **Vertical** stirrups (like those of a beam) hardly help here, because the crack is almost vertical and passes between them; the ones that work are the **horizontal** ones.

## 2 · Problem data

f_c = 350 'concrete strength f'c [kgf/cm2]
F_y = 4200 'yield stress of the reinforcing steel [kgf/cm2]
b_w = 35 'corbel width = width of the supporting column [cm]
L_n = 15 'clear span of the precast beam [m]
W_D = 2000 'uniform dead load on the beam [kgf/m]
W_L = 2800 'uniform live load on the beam [kgf/m]

#: **Factored loads.** The ACI does not design with the real loads but with **increased** loads (1.2 the dead and 1.6 the live), because the live load is more uncertain. It is the "safety margin" on the load side:
W_u = 1.2·W_D + 1.6·W_L 'ultimate load on the beam [kgf/m]
#: **Reaction at the support.** The beam is simple and symmetric: each end carries half of the total, W_{u}·L_{n}/2. That is the vertical load V_{u} that reaches **one** corbel:
V_u = W_u·L_n/2 'ultimate vertical load on the corbel [kgf]

#dibujo("Layout: the 15 m precast beam rests on two corbels, one on each column", ud = m, escala = auto, cotas = m, alto = 70)
#  rect(0, 1, 15, 0.6, "gruesa")
#  achurado(0, 1, 15, 0.6, "concreto")
#  rect(-0.35, -1.2, 0.35, 2.3, "media")
#  rect(15, -1.2, 0.35, 2.3, "media")
#  flecha(2, 3, 2, 1.7, "azul")
#  texto(2.2, 2.7, "W_{u} = 6880 kgf/m", 2.5, "i")
#  flecha(0.1, -0.4, 0.1, 1, "rojo")
#  flecha(14.9, -0.4, 14.9, 1, "rojo")
#  texto(0.5, -0.7, "V_{u} = W_{u}·L_{n}/2", 2.5, "i")
#  cota(0, -1.6, 15, -1.6, -0.1, "L_{n} = 15 m")
#fin

## 3 · Preliminary sizing: giving dimensions to the corbel

#: Before computing steels the shape must be **proposed**. This is done with four practical rules:
#: **i)** Between the bearing plate and the column face **3 cm** minimum is left, so the beam can be erected.
#: **ii)** The **shear span** a_{v} (the distance from the load to the column face) is taken as **twice the gap** between the beam and the column **plus half the plate**: the load does not act right at the edge of the plate but toward its center.
#: **iii)** The ratio a_{v}/d should be between **0.15 and 0.40**: less is a corbel almost like a "wall", more already resembles a beam.
#: **iv)** The height at the free edge (h_{2}) must be at least **half** of the depth at the face.
sep = 3 'gap between the bearing plate and the column face (assumed) [cm]
l_p = 10 'length of the bearing plate in the direction of the corbel (assumed; checked in section 9) [cm]
a_v = 2·sep + l_p/2 'shear span: distance from the load to the column face [cm]
r_a = 0.30 'ratio a_v/d proposed to start with (between 0.15 and 0.40) [-]
d_calc = a_v/r_a 'depth that gives that ratio [cm]
#: The computed depth comes out 36.7 cm: **it is rounded up to 40 cm**, which is a constructive dimension and stays on the safe side.
d = 40 'effective depth of the corbel, measured at the column face [cm]
rec = 5 'cover from the top face to the center of the main steel [cm]
h_1 = d + rec 'total height of the corbel at the column face [cm]
h_2 = 0.5·h_1 'height at the free edge (half of h_1, as the ACI requires) [cm]
l = sep + l_p + rec 'projection of the corbel: 3 cm gap + plate + 5 cm edge [cm]
r_real = a_v/d 'ratio a_v/d that actually results (must be between 0.15 and 0.40) [-]

#dibujo("Corbel dimensions (cm): the beam rests on a 10 cm plate, 3 cm from the column", ud = cm, escala = auto, cotas = cm, alto = 175)
#  rect(-35, -30, 35, 110, "media")
#  achurado(-35, -30, 35, 110, "concreto")
#  polilinea([0, 18, 18, 0], [45, 45, 22.5, 0], "gruesa")
#  rect(3, 45, 10, 2, "gruesa rojo")
#  rect(3, 47, 45, 32, "media")
#  flecha(8, 90, 8, 49, "rojo")
#  texto(10, 88, "V_{u} = 51 600 kgf", 3, "i")
#  linea(0, 45, 0, 20, "trazos")
#  cota(0, 52, 3, 52, 4, "3")
#  cota(3, 52, 13, 52, 4, "10")
#  cota(13, 52, 18, 52, 4, "5")
#  cota(0, 60, 18, 60, 4, "l = 18")
#  cota(-37, 0, -37, 45, -6, "h_{1} = 45")
#  cota(24, 22.5, 24, 45, 7, "h_{2} = 22.5")
#  cota(-35, -35, 0, -35, -4, "b_{w} = 35")
#  cota(0, 36, 11, 36, -4, "a_{v} = 11")
#fin

#: **Reading the result.** a_{v}/d comes out between 0.15 and 0.40: the corbel is short and is designed as a corbel, not as a beam. The base of the corbel is taken with the **same width as the column** (b_{w} = 35 cm).

## 4 · Does the concrete hold? Maximum shear check

#: Before designing the steel it is checked that **the concrete alone** can carry the shear, without "crushing diagonally". If not, no amount of steel will fix it: the corbel must be enlarged.
#: The ACI requires V_{u}/φ **not to exceed the smallest** of three values, with φ = 0.75 for shear. The reason for dividing by φ: the strength is **reduced** by φ and the load is **increased** by the factors, so here the load already divided by φ is compared with the nominal capacity.
phi_v = 0.75 'reduction factor for shear and shear-friction [-]
V_nec = V_u/phi_v 'nominal shear the concrete must be able to carry [kgf]
V_lim1 = 0.2·f_c·b_w·d 'limit 1: 0.2·f'c·b_w·d [kgf]
V_lim2 = (34 + 0.08·f_c)·b_w·d 'limit 2: (34 + 0.08·f'c)·b_w·d [kgf]
V_lim3 = 110·b_w·d 'limit 3: 110·b_w·d [kgf]
V_lim = min(V_lim1, min(V_lim2, V_lim3)) 'the smallest of the three: the one that governs [kgf]
r_dc = V_nec/V_lim 'demand/capacity ratio of the concrete (if < 1 it complies) [-]
#: **Reading.** **Limit 2** governs. The demand/capacity ratio is about **0.79**: it complies (less than 1) and there is not too much to spare (greater than 0.5), so the dimensions are **reasonable**: they do not need to be enlarged nor can they be reduced much.

## 5 · What forces act at the column face

#: The critical section is the **column face**: there the corbel tends to peel off. Three things act there at once:
#: **V_{u}**, the shear: the vertical load of the beam.
#: **N_{uc}**, a horizontal tension. Even if the design does not foresee it, the beam always transmits something by friction (braking, shrinkage, temperature). The ACI requires **at least 20 % of V_{u}**, and that minimum is taken.
#: **M_{u}**, the moment: V_{u} times its arm a_{v}, **plus** N_{uc} times its arm (h − d), because the horizontal tension acts in the upper part and is offset from the main steel.
N_uc = 0.2·V_u 'minimum horizontal tension required by the ACI [kgf]
M_u = V_u·a_v + N_uc·(h_1 - d) 'moment at the column face [kgf·cm]

#dibujo("Forces at the column face: V_{u} goes down at a_{v} from the face, N_{uc} pulls outward", ud = cm, escala = auto, cotas = cm, alto = 130)
#  rect(-35, -30, 35, 110, "media")
#  achurado(-35, -30, 35, 110, "concreto")
#  polilinea([0, 18, 18, 0], [45, 45, 22.5, 0], "gruesa")
#  flecha(11, 80, 11, 47, "rojo")
#  texto(13, 75, "V_{u}", 3, "i")
#  flecha(0, 44, 22, 44, "azul")
#  texto(23, 41, "N_{uc}", 3, "i")
#  cota(0, 53, 11, 53, 4, "a_{v}")
#  cota(-8, 0, -8, 45, -3, "h_{1}")
#fin

## 6 · The three steels

#: Each force is covered with a steel. The idea in all three is the same: **force the steel must carry = area × Fy × φ**, and from that the area is solved.
#: **A_{n}** — the steel that resists the **tension** N_{uc}. It is simple: the force divided by what each cm² of steel holds. With φ = 0.90 (tension).
phi_n = 0.90 'reduction factor for tension and flexure [-]
A_n = N_uc/(phi_n·F_y) 'steel for the horizontal tension [cm2]
#: **A_{vf}** — the **shear-friction** steel, which sews the crack between corbel and column. It works by friction: when trying to slide, the rough crack opens slightly, the steel stretches and **squeezes** the faces. The force it resists is μ·A_{vf}·Fy, where **μ** is the friction coefficient of the surface:
#: μ = 1.40 if the corbel is cast **at the same time** as the column (monolithic); 1.00 if it goes against **roughened** hardened concrete (6 mm); 0.60 if it goes against **smooth** hardened concrete; 0.70 if it goes against structural steel.
#: Corbels are made **monolithic** with the column (cast together), therefore:
mu = 1.4 'friction coefficient: monolithic concrete [-]
A_vf = V_u/(phi_v·mu·F_y) 'shear-friction steel [cm2]
#: **A_{f}** — the **flexure** steel, which resists the moment. It is treated as a beam with an internal arm z; the ACI allows taking **z = 0.8·d**: the distance between the tension steel and the compression resultant of the concrete.
z = 0.8·d 'internal arm of the flexure [cm]
A_f = M_u/(phi_n·F_y·z) 'steel for the moment [cm2]

## 7 · Main steel A_{sc} (the top tie)

#: The three steels are not placed separately: they are **combined** into a single main steel on top, A_{sc}, which is the tie of the strut. The ACI gives three criteria and the **largest** governs:
#: **a)** A_{f} + A_{n}: flexure plus tension (both pull).
#: **b)** (2/3)·A_{vf} + A_{n}: two thirds of the shear steel (the other third goes in the horizontal stirrups) plus the tension.
#: **c)** 0.04·(f'c/Fy)·b_{w}·d: a minimum so the corbel does not fail suddenly with very little steel.
A_sc1 = A_f + A_n 'criterion a) flexure + tension [cm2]
A_sc2 = (2/3)·A_vf + A_n 'criterion b) shear + tension [cm2]
A_sc3 = 0.04·(f_c/F_y)·b_w·d 'criterion c) minimum [cm2]
A_sc = max(A_sc1, max(A_sc2, A_sc3)) 'required main steel: the largest of the three [cm2]
#: **Reading.** Criterion b) governs: in such a short corbel **shear governs**, not flexure. It is characteristic of a small a_{v}/d.
#: **Choosing the bars.** 10.53 cm² are needed. With Ø22 mm bars (3.80 cm² each):
d_b = 2.2 'diameter of the main bars [cm]
A_b = pi·d_b^2/4 'area of one Ø22 bar [cm2]
n_b = 3 'number of main bars (3 is tried) [bars]
A_prov = n_b·A_b 'steel provided [cm2]
c_prov = A_prov/A_sc 'provided over required (must be ≥ 1) [-]
#: With **3 Ø22 mm**, 11.40 cm² ≥ 10.53 cm² are provided: it complies. The bars are **welded to a transverse bar** of the same diameter (or to an angle) at the free edge: that way the tie is anchored like a "tie with an anchor", not only by bond.

## 8 · Horizontal stirrups A_{h} (the confinement)

#: The **horizontal** stirrups close the strut and stop the diagonal crack. They are distributed over the **upper 2/3** of the depth. The ACI requires their total area to be at least **half of the steel that is not pure tension**:
A_h = 0.5·(A_sc - A_n) 'minimum total area of horizontal stirrups [cm2]
#: Closed Ø10 mm stirrups are used, each with two legs inside the corbel:
d_e = 1.0 'stirrup diameter [cm]
A_e = pi·d_e^2/4 'area of one leg [cm2]
n_e = 3 'number of closed stirrups (3 is tried) [stirrups]
A_h_prov = 2·n_e·A_e 'area provided: 2 legs per stirrup [cm2]
c_h = A_h_prov/A_h 'provided over required (must be ≥ 1) [-]
s_e = 8 'stirrup spacing, within the upper 2/3 [cm]
dos_tercios = (2/3)·d 'zone where the stirrups are distributed [cm]
n_c = 2·s_e 'extent occupied by 3 stirrups at 8 cm (two spaces of 8 cm) [cm]
#: **Reading.** 3 Ø10 stirrups (6 legs) give 4.71 cm² ≥ 3.90 cm²: it complies. They are 8 cm apart: the three fit within the 27 cm of the upper 2/3 (n_{c} is less than dos_tercios).

#dibujo("Corbel reinforcement: 3 Ø22 on top welded to a transverse bar and 3 Ø10 stirrups @ 8 cm", ud = cm, escala = auto, cotas = cm, alto = 160)
#  rect(-35, -30, 35, 110, "media")
#  achurado(-35, -30, 35, 110, "concreto")
#  polilinea([0, 18, 18, 0], [45, 45, 22.5, 0], "gruesa")
#  linea(-20, 40, 15, 40, "gruesa verde")
#  linea(15, 40, 15, 33, "gruesa verde")
#  circulo(15.2, 40, 1.1, "gruesa verde")
#  polilinea([0, 15, 15, 0, 0], [32, 32, 30, 30, 32], "media rojo")
#  polilinea([0, 15, 15, 0, 0], [24, 24, 22, 22, 24], "media rojo")
#  polilinea([0, 9, 9, 0, 0], [16, 16, 14, 14, 16], "media rojo")
#  texto(22, 42, "A_{sc} = 3 Ø22 (welded at the end)", 2.5, "i")
#  texto(22, 30, "3 Ø10 stirrups @ 8 cm", 2.5, "i")
#  cota(25, 14, 25, 32, 4, "2 spaces of 8")
#  cota(-8, 40, -8, 45, -3, "5")
#fin

## 9 · Bearing plate: so the concrete does not crush (additional check)

#: The notes leave **pending** the check of the 10 cm plate. The beam transmits V_{u} through a small surface (the plate), and there the concrete can **crush**. The ACI allows a bearing stress of 0.85·f'c, with φ = 0.65 for bearing. The plate measures b_{w} wide and l_{p} long:
phi_a = 0.65 'reduction factor for bearing [-]
A_pl = b_w·l_p 'contact area of the plate [cm2]
P_apl = phi_a·0.85·f_c·A_pl 'load the concrete holds under the plate [kgf]
r_apl = V_u/P_apl 'demand over bearing capacity (if < 1 it complies) [-]
#: **Reading.** With a 10 cm plate the ratio is about 0.76: it **complies**. If it gave more than 1, it would be enough to lengthen the plate (l_{p}) and recompute a_{v}: the whole sheet updates.

## 10 · Summary of what is built

#: **Dimensions:** column 35 × 35 cm; corbel b_{w} = 35 cm, h_{1} = 45 cm at the face, h_{2} = 22.5 cm at the edge, projection l = 18 cm.
#: **Reinforcement:** main steel 3 Ø22 mm (11.40 cm²) welded to a transverse bar; 3 closed Ø10 mm stirrups at 8 cm; 1 Ø12 mm assembly bar to tie the stirrups.
#: **Comment from the notes.** The result is a **very small** corbel: it is advisable to enlarge its projection to ease erection and give the beam more seat, without changing the reinforcement.
