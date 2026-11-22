# Centered footing: the subgrade modulus comes from the settlement, not from a table

#: The same footing of sheets 48, 54 and 57, but with the load **centered**: no moments. It seems the boring case, and it is just the opposite: it is the only one where everything can be solved by hand, and that is why it serves as a **benchmark** to check that the six programs are set up correctly before giving them the eccentric load.
#: And it answers a question that always comes up: **if GEO5 does not ask for the subgrade modulus, how does it compute?** It does not ask for it because it does not use springs. It integrates the deformation layer by layer with the soil modulus. The subgrade modulus is not its input: it is a **consequence**, and from there it is extracted for the structural programs.

## 0 · The case

B = 1.5 'footing side [m] ; L = 1.5 'other side [m] ; D_f = 0.7 'embedment [m] ; t = 0.4 'footing depth [m]
c_x = 0.3 'column side [m]
γ = 18 'unit weight of the sand [kN/m³] ; φ = 30 'friction angle [°] ; c = 0 'cohesion [kPa]
γ_h = 23 'unit weight of the concrete [kN/m³] ; γ_r = 20 'unit weight of the backfill [kN/m³]
N_col = 202 'service load coming down the column [kN]

## 1 · The load that really reaches the soil

#: {N_col} kN come down the column, but the soil does not carry only that: it also carries the weight of the footing itself and that of the earth placed on top of it. All three are vertical load and all three are spread over the same area.
A_z = dec(1.5*1.5, 3) [m^2] 'footing area
P_zap = dec(1.5*1.5*0.4*23, 2) [kN] 'footing weight
h_rel = dec(0.7 - 0.4, 2) [m] 'thickness of earth above the footing
P_rel = dec((2.25 - 0.3*0.3)*0.3*20, 2) [kN] 'weight of that earth
N_tot = dec(202 + 20.7 + 12.96, 2) [kN] 'total vertical load on the bearing plane
#: The footing weighs {P_zap} kN and the earth on top {P_rel} kN: together they add 17 % to what comes down the column. **It is not negligible and some programs forget it.**

## 2 · The contact pressure: here it really is a division

#: With centered load the resultant passes through the center of the footing, there is no moment and the pressure comes out **uniform**. This is the only case in which the contact pressure is a quotient and no contact needs to be solved:
q_c = dec(235.66/2.25, 2) [kPa] 'contact pressure, uniform
q_ct = dec(104.74/9.80665, 2) [tonf/m^2] 'the same, in construction units
#: {q_c} kPa, that is {q_ct} tonf/m². **GEO5 gives exactly 104.74 kPa**, which confirms that it counts the self weight the same as here.
#: As soon as the load shifts, this division stops being valid: a moment appears, the pressure tilts and, if the resultant leaves the middle third, one edge lifts off and the contact has to be solved with springs that do not work in tension. That is sheet 48.

## 3 · Bearing capacity: does the soil fail?

#: A different question. The contact pressure says how hard the footing presses; the capacity says how much the soil holds before failing. Meyerhof, with zero cohesion, leaves two terms: the surcharge of the earth on top and the weight of the soil itself under the footing.
q_sob = dec(0.7*18, 2) [kPa] 'surcharge at bearing level
φ_r = dec(30*pi/180, 4) [rad] 'the angle in radians
N_q = dec(exp(pi*tan(0.5236))*tan(pi/4 + 0.5236/2)^2, 3) [-] 'surcharge factor
N_γ = dec(2*(18.401 + 1)*tan(0.5236), 3) [-] 'self weight factor
#: The shape and depth factors, with the square footing (B/L = 1):
F_qs = dec(1 + 1*tan(0.5236), 3) [-]
F_γs = dec(1 - 0.4*1, 3) [-]
F_qd = dec(1 + 2*tan(0.5236)*(1 - sin(0.5236))^2*0.7/1.5, 3) [-]
F_γd = 1 [-]
#: And the ultimate capacity, term by term:
q_u1 = dec(12.6*18.401*1.577*1.135, 1) [kPa] 'what being buried 0.7 m contributes
q_u2 = dec(0.5*18*1.5*22.402*0.6, 1) [kPa] 'what the soil below contributes
q_u = dec(415.0 + 181.5, 1) [kPa] 'ultimate capacity
#: {q_u} kPa. And the split teaches something: {q_u1} kPa come from the embedment and only {q_u2} from the soil below. **Burying the footing 70 cm contributes more than double what the ground that supports it does.**
FS = dec(596.5/104.74, 2) [-] 'safety factor against failure
#: FS = {FS}, well above the 3 that the NEC-15 asks. With this centered load the footing is more than enough; what put it at the limit in sheet 57 was the eccentricity, not the load.

## 4 · The subgrade modulus: pressure divided by settlement

#: The finite element model needs a datum that neither the book nor the bearing capacity gives: how much pressure must be applied to sink the soil one meter. By definition, pressure divided by settlement:
k_s_def = q_c/s_c
#: GEO5 does not ask for that number: it produces it. It integrates the deformation layer by layer with the oedometric modulus and returns the settlement. For this footing it gives 1.8 mm, and then the subgrade modulus is solved for:
s_c = 1.8 'settlement computed by GEO5 [mm]
k_s = dec(104.74/0.0018, 0) [kN/m^3] 'subgrade modulus deduced from the settlement
k_st = dec(58189/9.80665, 0) [tonf/m^3] 'the same, in construction units
#: **{k_st} tonf/m³.** That is the spring to put in Hekatan Struct, SAP2000, SAFE and ETABS so that the four talk about the same soil as GEO5.

## 5 · Why the rule of thumb does not work

#: Bowles proposed estimating the subgrade modulus from the allowable pressure, assuming that the allowable settlement is around 25 mm:
q_adm = dec(596.5/3, 1) [kPa] 'allowable pressure with FS = 3
k_sB = dec(40*3*198.8, 0) [kN/m^3] 'subgrade modulus by the Bowles rule
k_sBt = dec(23856/9.80665, 0) [tonf/m^3]
#tabla("Where it comes from","Subgrade modulus [tonf/m³]:0","Relative to GEO5:2")({"from the settlement computed by GEO5","from the Bowles rule"}; [5934, 2433]; [1.00, 0.41])
#: The rule of thumb gives **less than half**. It is not that one is wrong: Bowles assumes a settlement of 25 mm and this footing settles 1.8, that is, fourteen times less. The less the soil sinks, the stiffer the spring.
#: And the practical consequence: **the subgrade modulus is not a property of the ground that can be copied from one footing to another**. It depends on the width. With uniform load over an area of width B, the elastic settlement is:
s_el = q_c*B*(1 - ν^2)*I_s/E_su
#: The width enters multiplying, so a 3 m footing on the same sand sinks three times as much as a 1 m one with the same pressure, and its subgrade modulus is three times smaller. That is why it is requested for a specific footing.

## 6 · What each program does

#tabla("Program","Capacity?","Contact pressure?","Settlement?","Reinforcement?")({"GEO5 Spread Footing","Hekatan Struct, SAP2000, SAFE, ETABS, OpenSees","Hekatan LISP (this sheet)"}; {"yes, Meyerhof","no","yes, by hand"}; {"uniform, assumed","yes, node by node with springs","uniform, by hand"}; {"yes, by layers","yes, from the spring","no"}; {"yes, ACI 318-19","no","no"})
#: None does everything. GEO5 answers **whether it holds**; the structural ones answer **how it holds**, which is what reinforces the concrete. And this sheet shows where each number comes from so that none is a black box.

## In one line

#: With centered load the pressure is a division, the capacity comes from a formula and the subgrade modulus is solved from the settlement: {q_ct} tonf/m² of contact, FS = {FS} against failure, and {k_st} tonf/m³ of spring for the models. **If the six programs do not agree in this case, there is no point in giving them the eccentric one.**
