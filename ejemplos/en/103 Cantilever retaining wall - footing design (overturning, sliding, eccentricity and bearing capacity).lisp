# Cantilever retaining wall: design and verification of the base
#numerico

#: **What is computed.** The Manabí wall of sheets 96, 98 and 99 (2.60 m stem on a 3.00 x 0.40 m footing) is no longer looked at deformed: here its **base is designed and verified**. The four external limit states required by NEC-SE-GC: active thrust, overturning, sliding, eccentricity and contact pressure, and bearing capacity of the supporting soil.
#: **How it is computed.** All static and per metre of wall. The active thrust by **Rankine** (no friction on the back face) and the bearing capacity by **Meyerhof with the effective width**, the same formula as sheet 54. At the end comes the **design**: a sweep of the width B to find the narrowest that complies.
#: **Units.** kN, m and kPa, per metre of wall. Inside the formulas the angles are in radians.
#: **Referees.** Factors: NEC-SE-GC (2022), tables 5 and 6. Loads: Struct (sheets 98 and 99) and the same geometry as GEO5 (sheet 96). Bearing capacity: Meyerhof against the Das example of sheet 54. **This sheet does not draw**: the wall, the mesh and the earthquake live in the other three.

## 1 · Data

#: **The geometry**, in abscissa s measured **from the toe** (s = 0) toward the backfill: the toe is the 0.70 m cantilever that projects toward the ground in front, the back face of the stem falls at s = 1.10 and the heel ends at s = 3.00.
B = 3 [m] 'footing width, s = 0 to 3
hz = 0.4 [m] 'footing thickness
pun = 0.7 [m] 'toe: cantilever in front of the stem
tal = 1.9 [m] 'heel: projection behind the stem, under the backfill
s_f = pun + hz [m] 'abscissa of the back face of the stem
hf = 2.6 [m] 'stem height, from the top face of the footing to the crest
ts = 0.25 [m] 'stem thickness at the top
ti = 0.4 [m] 'stem thickness at the bottom
h = hf + hz [m] 'total wall height
Df = 0.7 [m] 'embedment: the ground in front reaches z = -2.30 and covers the footing base

#: **Materials**, those of the soil study (sheet 96):
gam_c = 23 [kN/m3] 'wall concrete
gam_r = 18.5 [kN/m3] 'SP sand of the backfill
gam_f = 17.5 [kN/m3] 'SP-SM silty sand under the footing
phi_r = 30 'friction angle of the backfill [degrees]
phi_f = 29.97 'friction angle of the supporting soil [degrees]
c_f = 0 [kPa] 'cohesion: both soils are sandy, it contributes nothing
pr_r = phi_r·pi/180 'the same angle, in radians, which is what the formulas want
pr_f = phi_f·pi/180

#: **What the code requires** (NEC-SE-GC, tables 5 and 6):
req_des = 1.6 'sliding, without earthquake
req_vol = 3 'overturning: MR/MA ≥ 3.00 (design with earthquake ≥ 2.00)
kern = 1/6 'eccentricity: e/B ≤ 1/6 (design with earthquake ≤ 1/4)
req_cap = 3 'bearing capacity with dead load + normal live load

## 2 · The active thrust: Rankine

#: With a vertical back face and horizontal backfill, **Rankine sees no friction**: the soil pushes parallel to the free surface and the coefficient comes from the failure state in a uniform stress field. There are two paths to the same number, and both are here so that no faith is required:
ka1 = (1 - sin(pr_r))/(1 + sin(pr_r))
ka2 = tan(pi/4 - pr_r/2)^2
d_ka = round(ka1 - ka2, 4) 'the two paths, to four decimals
ka = ka1
#: With 30° it comes out **exactly 1/3**: tan²(45° − 15°) = tan²(30°) = 1/3. And the thrust, per metre of wall:
h_a = hf [m] 'the analysis plane is the back face of the stem, from the footing to the crest
pa = 0.5·ka·gam_r·h_a^2 [kN/m]
z_a = h_a/3 [m] 'height above the top face of the footing
brazo = z_a + hz [m] 'arm about the footing base: it is what overturns the wall

#: **Coulomb, for comparison.** If friction is allowed on the face, δ = 2/3·φ, the thrust drops and already has a vertical component:
delta = 2/3·pr_r
ka_c = cos(pr_r)^2/(cos(delta)·(1 + sqrt(sin(pr_r + delta)·sin(pr_r)/cos(delta)))^2)
pa_c = 0.5·ka_c·gam_r·h_a^2 [kN/m]
#hide
r_pa = round(pa, 2)
r_pac = round(pa_c, 2)
#show
#: Coulomb gives @{r_pac} against @{r_pa} from Rankine, and GEO5/Struct give 17.47 kN/m (K = 0.280, with their critical plane and their friction). **Rankine stays above both: it is the safe side**, and it is the one used in everything that follows.

## 3 · The vertical loads

#: **The stem is a trapezoid**, not a rectangle: 0.25 m at the top and 0.40 at the bottom. Its weight is the area times the unit weight, and its arm comes from the centroid. For a thickness that varies linearly, the average of the square over the height is (ti² + ti·ts + ts²)/3 —the same rule that gives the moment of inertia of the rectangle—, and the centroid measured from the flat face (the back one) is half of that average divided by the mean thickness:
t_med = (ts + ti)/2 [m] 'mean thickness
t_cua = (ti^2 + ti·ts + ts^2)/3 'average of t² over the height [m2]
x_g = 0.5·t_cua/t_med [m] 'centroid from the back face of the stem
#: **Check by integration**: the formula is not verified with the same formula, the thickness function is integrated as it is:
x_gi = 0.5·integral(@(u) (ti + (ts - ti)·u)^2, 0, 1)/integral(@(u) (ti + (ts - ti)·u), 0, 1)
d_xg = round(x_g - x_gi, 4) 'must give zero

a_fus = t_med·hf [m2] 'stem section area, per metre of wall
W_fus = a_fus·gam_c [kN/m] 'stem weight
W_zap = B·hz·gam_c [kN/m] 'footing weight
W_rel = tal·hf·gam_r [kN/m] 'weight of the backfill resting on the heel
Vtot = W_fus + W_zap + W_rel [kN/m] 'all the vertical loads
x_f = s_f - x_g [m] 'arm of the stem resultant from the toe
x_z = B/2 [m] 'arm of the footing
x_r = s_f + tal/2 [m] 'arm of the backfill: the centre of the heel

#: **Cross-check with Struct.** The same concrete and the same backfill in the spring model of sheets 98 and 99:
peso_s = 47.035 'concrete weight in Struct, sheet 99 [kN/m]
rel_s = 91.39 'backfill over the heel in Struct, sheet 99 [kN/m]
n_s = 144.78 'vertical resultant in Struct, sheet 98 [kN/m]
pv_s = 6.359 'vertical component of the Coulomb thrust in Struct [kN/m]
d_pes = round(W_fus + W_zap - peso_s, 4) 'zero: the concrete weighs the same
d_rel = round(W_rel - rel_s, 4) 'zero: the backfill weighs the same
d_nor = round(peso_s + rel_s + pv_s - n_s, 2) 'Struct's N, to two decimals
#hide
r_vt = round(Vtot, 3)
#show
#: The three cross-checks give zero. **Vtotal = @{r_vt} kN/m**, and Struct its 144.78: the whole difference is the vertical component of the Coulomb thrust (6.359), which Rankine does not have because there is no friction.

## 4 · Overturning

#: The footing rotates about the **tip of the toe**, the point farthest from the thrust. On one side everything that weighs, on the other the thrust:
mres = W_fus·x_f + W_zap·x_z + W_rel·x_r [kN] 'resisting moment about the toe
mot = pa·brazo [kN] 'overturning moment
FSvol = mres/mot
m_vol = round(100·(FSvol/req_vol - 1), 1) 'how much margin, in %, over the 3.00
#hide
r_fsv = round(FSvol, 2)
#show
#: NEC-SE-GC (table 5) requires MR/MA ≥ 3.00 without earthquake; it comes out @{r_fsv}, @{m_vol} % above. **Why there is so much margin**: the heel is loaded with sand (91 kN at 2.05 m from the toe), and that lever weighs much more than a 20.8 kN/m thrust that also pushes low. The wall does not overturn because of its weight, it would overturn if the backfill on top were removed.

## 5 · Sliding

#: The footing slides on the supporting soil. It resists with the normal times tan of the friction angle and the horizontal of the thrust pushes. The concrete-soil friction is taken conservatively, 2/3 of φ of the supporting sand:
delta_b = 2/3·pr_f 'friction between the footing and the SP-SM
FSdesl = Vtot·tan(delta_b)/pa
m_des = round(100·(FSdesl/req_des - 1), 1) 'how much margin, in %, over the 1.60
#hide
r_fsd = round(FSdesl, 2)
#show
#: NEC-SE-GC table 5: ≥ 1.60 without earthquake. It comes out @{r_fsd}, @{m_des} % above. It is the **tightest** verification of the four: it is the one that governs the design in section 9.
#: **What is left out here, and how much it would be worth.** (1) The **passive thrust** of the soil in front: only 0.70 m of sand covers the toe, but even so it would add:
kp = tan(pi/4 + pr_f/2)^2 'passive coefficient
pp = 0.5·kp·gam_f·Df^2 [kN/m] 'passive thrust on those 0.70 m
FSdesl_p = (Vtot + pp)·tan(delta_b)/pa 'FS if the passive were counted
#hide
r_pp = round(pp, 2)
r_fdp = round(FSdesl_p, 2)
#show
#: with it the FS would rise from @{r_fsd} to @{r_fdp}; it is omitted because on site that soil is removed, dug and backfilled, and because **the safe side is not to count it**. (2) The **base cohesion**: c = 0 in both soils, there is nothing to add. (3) The **soil in front**: also omitted as conservative; with it the normal rises and so does the friction.

## 6 · Eccentricity and pressure under the footing

#: The thrust overturns and the vertical loads hold, so the resultant **does not fall at the centre** of the footing. The distance from the centre is the eccentricity, measured here **toward the heel**:
exx = (mres - mot)/Vtot - B/2 [m] 'positive = toward the heel
exxb = exx/B 'relative eccentricity, dimensionless
m_e = round(100·(1 - abs(exxb)/kern), 1) 'how much margin, in %, inside the middle third
#hide
r_ex = round(exx, 4)
r_exb = round(exxb, 4)
r_kern = round(kern, 4)
#show
#: NEC requires e/B ≤ 1/6 = @{r_kern}. It comes out @{r_exb} (e = @{r_ex} m), that is @{m_e} % inside the limit. **With that the resultant falls within the middle third and the whole footing stays in compression**: if it were exceeded, an edge would lift and the pressure would come out negative, and the soil cannot take tension.
#: At that distance, the pressure is a straight line (combined bending of the footing, 1 m deep section):
q_tal = Vtot/B·(1 + 6·exx/B) [kPa] 'at the heel
q_pun = Vtot/B·(1 - 6·exx/B) [kPa] 'at the toe
q_max = max(q_tal, q_pun)
q_min = min(q_tal, q_pun)
d_iden = round((q_tal + q_pun)/2·B - Vtot, 4) 'identity: (q1+q2)/2·B = Vtot, must give zero
#hide
r_qt = round(q_tal, 2)
r_qp = round(q_pun, 2)
#show
#: **The highest pressure is at the heel** (@{r_qt} against @{r_qp}), and that is logical: the backfill is there, pulling the resultant to its side, while the thrust is smaller and also pushes low. Struct gives the same pair of numbers, 58.5 and 39.1 kPa with N = 144.78 kN/m.
#: **Is it the method or the loads?** This same equilibrium is repeated with the Struct loads (concrete 47.035, backfill 91.390, horizontal thrust 17.470 and vertical 6.359, all quoted from sheets 98 and 99):
mres_s = W_fus·x_f + W_zap·x_z + W_rel·x_r + pv_s·s_f 'the Coulomb vertical drops on the back face
mot_s = 17.47·brazo 'the Coulomb horizontal, at the same arm
exx_s = (mres_s - mot_s)/n_s - B/2
q_s1 = n_s/B·(1 + 6·exx_s/B) [kPa] 'maximum, with the Struct loads
q_s2 = n_s/B·(1 - 6·exx_s/B) [kPa] 'minimum, with the Struct loads
q_1s = 58.5 'maximum quoted from Struct, sheet 98 [kPa]
q_2s = 39.1 'minimum quoted from Struct, sheet 98 [kPa]
d_q1 = round(q_s1 - q_1s, 2)
d_q2 = round(q_s2 - q_2s, 2)
#hide
r_qs1 = round(q_s1, 2)
r_qs2 = round(q_s2, 2)
r_dq1 = round(abs(d_q1), 2)
r_dq2 = round(abs(d_q2), 2)
#show
#: Same loads, same equilibrium: statics gives @{r_qs1} and @{r_qs2} against 58.5 and 39.1, that is @{r_dq1} and @{r_dq2} kPa of difference (less than 1.5 %). **Statics closes**; what changes in the end is not the method but the loads: Rankine pushes more and does not bring the Coulomb vertical component.

## 7 · Bearing capacity

#: The soil has to withstand the highest of those pressures without failing. Meyerhof, with the effective width —the eccentric resultant compresses only B − 2·|e| of the footing—:
qs = gam_f·Df [kPa] 'surcharge from the ground in front: 0.70 m of sand
nq = exp(pi·tan(pr_f))·tan(pi/4 + pr_f/2)^2
ng = 2·(nq + 1)·tan(pr_f)
#: **Do the tables come out?** With φ = 30° exactly, these same formulas must give the Das values used in sheet 54:
nq30 = exp(pi·tan(pi/6))·tan(pi/4 + (pi/6)/2)^2
ng30 = 2·(nq30 + 1)·tan(pi/6)
d_nq = round(100·(nq30/18.4 - 1), 3) 'Das gives 18.4, difference in %
d_ng = round(100·(ng30/22.4 - 1), 3) 'Das gives 22.4, difference in %
#hide
r_nq = round(nq, 3)
r_ng = round(ng, 3)
#show
#: Das (tables 6.2 and 6.3) gives 18.4 and 22.4; here, with φ of the supporting sand, @{r_nq} and @{r_ng} come out. For exactly 30° the difference from the table is @{d_nq} % and @{d_ng} %: the table is rounded, the formula is not.
#: The foundation sinks the base a little and that confines it; the Meyerhof depth factor enters, and for shape the Saric factor (it is so narrow that it works in plane strain, with no shape factors):
f_qd = 1 + 2·tan(pr_f)·(1 - sin(pr_f))^2·Df/B
be = B - 2·abs(exx) [m] 'effective width
q_ult = qs·nq·f_qd + 0.5·gam_f·be·ng [kPa]
q_adm = q_ult/req_cap [kPa] 'FS = 3.0, NEC table 6
q_adm_t = q_adm/9.80665 [tonf/m2] 'for those who think in tonnes
FScap = q_ult/q_max
m_cap = round(100·(FScap/req_cap - 1), 1) 'how much margin, in %, over the 3.00
#hide
r_qu = round(q_ult, 1)
r_qa = round(q_adm, 1)
r_qat = round(q_adm_t, 1)
r_qm = round(q_max, 2)
r_fsc = round(FScap, 2)
#show
#: NEC table 6: FS = 3.0 with dead load and normal live load, so the allowable pressure is @{r_qa} kPa (@{r_qat} tonf/m²) against a maximum pressure on the footing of @{r_qm} kPa: @{m_cap} % margin, and the real factor is @{r_fsc}. The check here is not critical; what governs this footing is sliding.

## 8 · The four verifications

#| Qué se verifica | Calculado | Exigido (NEC-SE-GC) | Cuánto sobra [%] |
#|---|---:|---:|---:|
#| Volcamiento, MR/MA | @{r_fsv} | ≥ 3.00 | @{m_vol} |
#| Deslizamiento, FS | @{r_fsd} | ≥ 1.60 | @{m_des} |
#| Excentricidad, e/B | @{r_exb} | ≤ 0.1667 | @{m_e} |
#| Capacidad portante, q_{ult}/q_{max} | @{r_fsc} | ≥ 3.00 | @{m_cap} |

#: All four pass. **The one with the least margin is sliding**: @{m_des} % over the minimum, against @{m_vol} % for overturning. That matters for section 9, because it is sliding that governs the width.

## 9 · The design: how much width is needed?

#: The numbers above are for B = 3.00 m. Now the design question: **how much can the footing be narrowed?** When B changes, the normal, the backfill arm and the eccentricity change, and with them the three factors. **The heel** is trimmed (the toe and the stem stay where they are), from 1.60 to 3.00 m:
#hide
Res = zeros(8, 6)
for i = 1:8
  Bi = 1.6 + 0.2·(i - 1)
  Vi = W_fus + gam_c·hz·Bi + gam_r·hf·(Bi - s_f)
  MRi = W_fus·x_f + gam_c·hz·Bi^2/2 + gam_r·hf·(Bi^2 - s_f^2)/2
  ei = (MRi - mot)/Vi - Bi/2
  q_ti = Vi/Bi·(1 + 6·ei/Bi)
  q_pi = Vi/Bi·(1 - 6·ei/Bi)
  q_mi = max(q_ti, q_pi)
  bei = Bi - 2·abs(ei)
  f_qi = 1 + 2·tan(pr_f)·(1 - sin(pr_f))^2·Df/Bi
  qu_i = qs·nq·f_qi + 0.5·gam_f·bei·ng
  Res(i, 1) = Bi
  Res(i, 2) = round(Vi·tan(delta_b)/pa, 3)
  Res(i, 3) = round(MRi/mot, 3)
  Res(i, 4) = round(ei/Bi, 4)
  Res(i, 5) = round(q_mi, 1)
  Res(i, 6) = round(qu_i/q_mi, 3)
end
#show
#: Columns: **B [m]** · **FS sliding** (≥ 1.60) · **FS overturning** (≥ 3.00) · **e/B** (≤ 0.1667) · **maximum pressure [kPa]** · **FS capacity** (≥ 3.00):
Res
#: **Check of the last row** against sections 4 to 7 (rounding included, must give zero):
d_b1 = round(Res(8, 2) - FSdesl, 3)
d_b2 = round(Res(8, 3) - FSvol, 3)
d_b3 = round(Res(8, 4) - exxb, 4)
#: **Reading.** Sliding is the one that governs: at 2.00 m it gives 1.42 and falls short, at **2.20 m it gives 1.62 and passes**; overturning passes from 1.80 m and the eccentricity never gets near the middle third over the whole range. **Minimum B = 2.20 m**, governed by sliding, and the 3.00 m footing has 51 % of margin on top.
#: The same curves drawn against B, with the code minimum as a dashed line:
#: Each curve is its numerator times a constant of the sheet: sliding is V·tan(δ_{b})/p_{a} and overturning M_{R}/M_{A}, with p_{a} and M_{A} not changing with B:
kdes = tan(delta_b)/pa 'sliding factor: FS = V·kdes [1/(kN/m)]
kvol = 1/mot 'overturning factor: FS = M_R·kvol [1/kN]
#fila
#fplot(FSd = (W_fus + gam_c·hz·t + gam_r·hf·(t - s_f))·kdes, limite = 1.6, [1.6 3])
#fplot(FSv = (W_fus·x_f + gam_c·hz·t^2/2 + gam_r·hf·t^2/2 - gam_r·hf·s_f^2/2)·kvol, limite = 3, [1.6 3])
#finfila
#: On the left sliding, which **crosses** 1.60 near 2.20 m; on the right overturning, which passes 3.00 near 1.80 m (the table above: from 1.80 m).

## 10 · What is left out of this sheet

#: ⏳ **Earthquake.** Not included. The dynamic thrust would be Mononobe-Okabe, and it is not verified: with δ = 2/3·φ and horizontal backfill it gives 38.9 kN/m against the 35.0 of Struct with k_{h} = 0.336 (sheet 99). Until the oracle closes, it is computed static here, and the limits of table 5 drop with earthquake (overturning ≥ 2.00 and sliding 1.05 in design).
#: ⏳ **Water table.** The soil study gives it at −3.05 m, 5 cm below the footing. With water, the pore pressure subtracts from the normal, lowers the friction and all the FS drops: it is the pending item that can change these numbers the most.
#: ⏳ **Passive thrust and soil in front.** Left out as conservative; section 5 already showed how much the passive would add.
#: ⏳ **Concrete reinforcement, settlements and global stability** (the overturning over the circular surface that sheet 96 does compute): they are other sheets, other verifications. This one stays at the base.
