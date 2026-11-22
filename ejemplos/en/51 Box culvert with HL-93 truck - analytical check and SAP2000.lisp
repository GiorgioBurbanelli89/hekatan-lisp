# Box culvert with HL-93 truck: are the results consistent?

#: A truck crosses a two-cell box culvert. Hekatan Struct solves it with influence lines and animates it position by position. This sheet does what must be done before believing a program: check BY HAND that the numbers respect the laws of statics, enclose them between two simple bounds, and compare them with SAP2000 (which brings its own truck). The example is published at giorgioburbanelli89.github.io/hekatan-struct-lineal/workspace/?t=alcantarilla-carga-movil

## 1 · The model

#: 1 m wide strip. Two cells of span L and height H center to center, slabs and walls of thickness t, concrete of modulus E. The bottom slab rests on Winkler springs with subgrade modulus k_{s} (2 kg/cm³). Units: kN and m.
L = 3.0
H = 2.5
t = 0.30
B = 2*L
E = 24516625
k_s = 19613.3
#: The HL-93 design truck (AASHTO LRFD, in SI): one front axle and two rear axles, spaced 4.3 m. The total length is 8.6 m: LONGER than the culvert (B = {B} m). That is why there are never more than two axles on it at the same time.
P_1 = 35
P_2 = 145
s_e = 4.3

## 2 · First law: the soil returns what the truck weighs

#: The springs are the only thing that holds up the box. Adding the force of all of them (k times settlement) must give the weight of the axles that are on top. Put another way: the MEAN settlement of the bottom slab does not depend on the stiffness of the box, only on the weight and the soil:
w_med = dec(P_1/(k_s*B)*1000, 4)
#: With the front axle alone (35 kN) it gives w_{med} = {w_med} mm. The FEM gives 0.29741723 mm: the same number to the eighth decimal. In the 147 truck positions, |ΣR − ΣP| does not exceed 1e-10 kN, with Hekatan's settlements and with SAP2000's.
#: Second law, of moments: the soil resultant must fall exactly under the truck resultant (Σ k·w·x = Σ P·x). Worst difference along the whole run: 7e-10 kN·m in Hekatan and 2e-9 in SAP2000.

## 3 · Is the box rigid or flexible compared with the soil?

#: A beam on elastic soil has a characteristic length 1/λ (Hetényi). If λ·B is less than 1 the piece behaves as a rigid block; if it exceeds π, as a long flexible beam that concentrates the settlement under the load.
EI = dec(E*t^3/12, 1)
lam = dec((k_s/(4*E*t^3/12))^(1/4), 4)
lamB = dec(lam*B, 3)
#: λ·B = {lamB}: the bottom slab ALONE would be flexible. But it is not alone: the walls and the top slab tie it and form a much stiffer box. The real result must lie BETWEEN the two extremes.

## 4 · Settlement bounds: rigid block < FEM < slab alone

#: Front axle (35 kN) over the central wall, symmetric case. Lower bound: the box is an infinitely rigid block and settles uniformly:
w_rig = dec(P_1/(k_s*B)*1000, 4)
#: Upper bound: the load goes down the wall to the bottom slab and it works alone, as a finite beam with free ends and a load at the center (Hetényi):
#: The four values of the formula for λ·B = 3.276 (radians): cosh, sinh, cos and sin.
C_h = 13.2537
S_h = 13.2160
C_o = -0.9910
S_i = -0.1340
w_het = dec(P_1*lam/(2*k_s)*(C_h + C_o + 2)/(S_h + S_i)*1000, 4)
#tabla("Settlement under the central wall","w [mm]:4")({"Rigid block (lower bound)","FEM — Hekatan and SAP2000","Bottom slab alone, Hetényi (upper bound)"}; [0.2974, 0.4039, 0.5311])
#: The FEM (0.4039 mm) falls inside, closer to the rigid block: that is what is expected of a closed box.
#: The same with the heavy axle at the EDGE (x = B), which is where the maximum of the whole run occurs. The rigid block settles and also ROCKS: mean settlement plus rotation due to the eccentricity e = B/2.
w_borde = dec((P_2/(k_s*B) + P_2*(B/2)*(B/2)/(k_s*B^3/12))*1000, 4)
#: Rigid block: {w_borde} mm. FEM: 5.8512 mm. The FEM gives more because the real box deforms and loads the edge more. It is the same order and on the right side: consistent. Incidentally it explains the animation: what moves most is not the slab bending, it is the WHOLE BOX sinking and rocking on the soil.

## 5 · Moment bounds under the axle

#: 145 kN axle alone, at the center of a cell. The top slab is neither simply supported nor fixed at the walls: it is in between.
M_emp = dec(P_2*L/8, 2)
M_apo = dec(P_2*L/4, 2)
#tabla("Moment under the 145 kN axle","M [kN·m]:2")({"Fixed at the walls, P·L/8 (lower bound)","FEM — Hekatan and SAP2000","Simply supported, P·L/4 (upper bound)"}; [54.38, 71.25, 108.75])

## 6 · The statics of a span, with the FEM numbers

#: This is not a bound: it is an exact law. In a span with moments M_{i} and M_{j} at the ends and a load P at the center, the moment under the load is the average of the end moments plus the simply supported P·L/4. With the end moments given by the FEM (position 131, axle at x = 4.5 m):
M_i = -45.2634
M_j = -29.7307
M_c = dec((M_i + M_j)/2 + P_2*L/4, 4)
#: It gives {M_c} kN·m and the FEM gives 71.2530: identical. Checked at ALL nodes of the top slab and in the 147 positions: maximum difference 5e-11 kN·m. And the shear jump under each axle equals the axle weight with a 6e-11 kN difference.
#: Two more laws that also hold: Maxwell–Betti (the settlement at i due to a load at j equals that at j due to a load at i: difference 1e-19 m) and symmetry (an axle at x gives the mirror of an axle at B − x: 6e-18 m/kN).

## 7 · "The truck enters and the color does not change"

#: In the animation the color is the displacement divided by the LARGEST displacement of the whole run (6.797 mm, with the 145 kN axle at the edge). The scale is fixed so that a color means the same in all frames. Consequence: while only the front axle (35 kN) is on top the fraction goes from 0.24 to 0.06 and everything looks blue. When the first 145 kN axle enters it jumps to 0.79. It is not a calculation error: it is the scale. x is the position of the front axle:
#fplot(limite_azul = 0.125 + 0*x, Fraccion_del_color = [0.0 0.242; 0.6 0.198; 1.2 0.155; 1.8 0.115; 2.4 0.081; 3.0 0.061; 3.6 0.081; 4.2 0.115; 4.8 0.788; 5.4 0.585; 6.0 0.424; 6.6 0.357; 7.2 0.256; 7.8 0.314; 8.4 0.452; 9.0 0.656; 9.6 0.541; 10.2 0.787; 10.8 0.380; 11.4 0.265; 12.0 0.295; 12.6 0.427; 13.2 0.584; 13.8 0.761; 14.4 0.940; 14.6 1.000], [0 15])
#: The bending moment, on the other hand, does respond from the first frame (11 → 17 kN·m with the front axle). To SEE the truck enter, the stress map is better than the displacement one.

## 8 · Against SAP2000, which brings its own truck

#: SAP2000 has two native moving-load analyses: "Multi-Step Static" (the vehicle advances along a lane at a speed, step by step) and "Moving Load" (influence lines → envelope). The lane was defined over the 60 members of the top slab and the 35/145/145 kN vehicle. Maximum settlement at each position: the points are SAP2000's NATIVE truck and Hekatan's; the reference line is the rigid block with a 145 kN axle centered.
#fplot(bloque_rigido_145 = 1.2322 + 0*x, Hekatan = [0.0 1.4124; 0.6 1.1887; 1.2 0.9414; 1.8 0.7046; 2.4 0.5161; 3.0 0.4136; 3.6 0.5161; 4.2 0.7046; 4.8 4.8482; 5.4 3.7072; 6.0 2.8041; 6.6 2.2554; 7.2 1.7322; 7.8 2.0286; 8.4 2.7796; 9.0 4.3427; 9.6 3.6617; 10.2 5.0639; 10.8 2.3799; 11.4 1.7784; 12.0 1.9306; 12.6 2.6430; 13.2 3.5483; 13.8 4.5906; 14.4 5.5571; 14.6 5.8512], SAP2000_nativo = [0.3 1.3044; 0.9 1.0670; 1.5 0.8139; 2.1 0.6057; 2.7 0.4456; 3.3 0.4456; 3.9 0.6057; 4.5 5.3807; 5.1 4.2884; 5.7 3.2256; 6.3 2.6430; 6.9 1.9306; 7.5 1.7784; 8.1 2.3799; 8.7 5.0639; 9.3 3.6617; 9.9 4.3427; 10.5 2.7796; 11.1 2.0286; 11.7 1.7322; 12.3 2.2554; 12.9 3.0620; 13.5 4.0749], [0 15])
#: Position by position (147 static cases, all nodes and members: Ux, Uz, Ry, P, V2, M3) the worst error is 6e-10 %. With the native truck step by step, 5e-10 % in 134 steps. And the envelopes of the native "Moving Load":
#tabla("Comparison","Hekatan:4","SAP2000:4","Diferencia [%]:4")({"Truck envelope, M3 max [kN·m]","Truck envelope, M3 min [kN·m]","Truck envelope, settlement [mm]","HL-93 + lane envelope, M3 max [kN·m]","HL-93 + lane envelope, M3 min [kN·m]","HL-93 + lane envelope, settlement [mm]"}; [71.5127, -77.7595, -5.8512, 77.3201, -89.6117, -6.5198]; [71.5128, -77.7599, -5.8512, 77.3194, -89.6053, -6.5198]; [0.0001, 0.0005, 0.0000, 0.0009, 0.0071, 0.0000])
#: Two details measured, not assumed. One: SAP2000's native truck starts with the front axle 1 m BEFORE the lane (x = t − 1.0 m), so its first ten steps are the zero state, with the truck outside. Two: at the exact instant an axle steps on the start of the lane (x = 0) SAP2000 does not yet load it and Hekatan does; that is 3 steps out of 137, and that is why 134 are compared. The envelopes differ in the fourth digit because SAP2000 discretizes the lane with points at ±1 mm from each node.

## 9 · Verdict

#: The seven exact laws hold to 1e-9 or better, with Hekatan's numbers and with SAP2000's. The hand bounds enclose the FEM on both sides. And SAP2000, with its own truck, gives the same. The results are consistent. Still pending, and flagged on screen, is the AASHTO distribution width: today the whole axle goes on the 1 m strip, which is the safe side.
