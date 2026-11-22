# Where the stiffness of a bar comes from: EI and L, term by term
#: Here it is DERIVED from scratch, starting with a small piece of beam: equilibrium → beam equation → cubic shape → shape functions → curvatures → energy → integral. With {EI} and {L} as symbols, every number comes out of a calculation. All with the engine.

## 1 · The start: equilibrium of a small piece of beam
#: Everything starts here. I cut out a small piece of beam of width {dx} and look at its forces. On the left face act the moment {M} and the shear {V}; on the right, slightly changed: {M + dM} and {V + dV}. On top, the distributed load {q}. The piece is at rest, so forces and moments balance:
#slice
#: Two equilibrium conditions, and each gives a law. I add the vertical forces of the two faces plus the load (the whole piece, and it equals zero):
Fy = V - (V + dV) - q*dx @@(fuerzas verticales = 0)
#: {V} cancels and what remains is the change {dV} against the load {q}: the shear drops at the rate of the load. Now I add the moments about one face (also zero; the terms with dx·dx are neglected):
Mo = (M + dM) - M - V*dx @@(momentos = 0)
#: {M} cancels and what remains is the change {dM} against the shear {V}: the moment grows at the rate of the shear.

## 2 · What v is (the deflection) and the beam equation
#: First, what v is. The deflection v is how much the beam axis DROPS at each point x — the shape it takes when loaded. It is the UNKNOWN of the whole problem. NOTE: v (lowercase, the deflection) is NOT V (uppercase, the shear of step 1); they are different things.
#defl
#: Its derivatives have names of their own: the 1st, v′, is the rotation (the slope of the axis); the 2nd, v″, is the curvature (how much it bends); and the 4th, v⁗, is the one that appears in the beam equation.
#: Now I link the moment {M} with that shape, in two steps. Geometry (small deflections): the curvature is the second derivative of the deflection — v″. Material and section: by Hooke each fibre pulls according to its distance from the axis; adding those stresses times their lever arm, the moment {M} is the stiffness {EI} times the curvature ({EI} gathers the modulus E and the moment of inertia of the section).
#: Now I put the three laws together. From step 1: the slope of the moment is the shear {V}, and the slope of the shear is minus the load {q}. And here: the moment {M} is {EI} times the curvature. Chaining them, the load {q} equals {EI} times the FOURTH derivative of the deflection: that is the beam equation.
#: INSIDE the span, between node and node, there is no distributed load: the load {q} is zero. Then the fourth derivative of the deflection is zero. That is what I solve, with the engine, in step 3.

## 3 · A real beam: the cantilever, solved with L
#: To see the mechanism with real FORMULAS, I first solve a concrete beam of length {L}: a cantilever (fixed at the left, free at the right) with a load {P} at the tip. By statics, the moment at a distance {x} from the support is:
Mvol = -P*(L - x) @@(momento del voladizo)
#: The beam equation says that {EI} times the curvature is the moment. I integrate the moment once and get {EI} times the rotation. The support does not allow rotation at the start (the rotation at {x}=0 is zero), so the integration constant is zero:
EIvp = Integral{-P*(L - x) @ x} @@(EI·v′, giro × EI; la +C = 0)
#: I integrate again and get {EI} times the deflection. The support does not allow dropping at the start either (the deflection at {x}=0 is zero), so the constant is zero again:
EIv = Integral{-P*L*x + P*x^2/2 @ x} @@(EI·v, deflexión × EI; la +C = 0)
#: {EIv} divided by {EI} is the deflection. At the tip ({x}={L}) it gives the classic cantilever formula, {vpunta}:
vpunta = -P*L^3/(3*EI) @@(flecha en la punta)
#: NOTE the result: the deflection came out as a polynomial of degree 3 — a CUBIC in {x}. It is no accident: with no load inside the span, the equation is {EI}·v⁗ = 0 and its solution is ALWAYS a cubic (4 constants). Here the support fixed them; in a two-node element they are fixed by the 4 nodal data (drop and rotation at each end). That is step 4.

## 4 · Timoshenko's elastic curve, the cubic and the shape functions
#: The golden rule of the beam (Timoshenko) links the SHAPE with the moment: stiffness times curvature is the moment, {EI}·v″ = M. I use a cantilever with a load P at the tip, and go step by step — each diagram WITH its beam above, integrating (each integral raises the degree by one).
#: 1) The LOAD. What is {q}=0? The element only receives forces at its NODES (the ends): P is AT the tip, not distributed along the beam. Therefore, along the span, the distributed load is zero, {q}=0. It is not an arbitrary assumption: it is what defines the element. In the diagram, a flat line:
#diag(carga)
#: 2) The SHEAR is the integral of −q (law dV/dx=−q). Integrating zero gives a CONSTANT — the shear does not change (flat strip):
Vcte = Integral{0 @ x} @@(V = ∫(−q) = c1, constante)
#diag(cortante)
#: 3) The MOMENT is the integral of the shear (law dM/dx=V). Integrating a constant gives a STRAIGHT LINE (a triangle):
Mrecta = Integral{c1 @ x} @@(M = ∫V = c1·x + c0, recta)
#diag(momento)
#: 4) The DEFLECTION. The elastic curve says to integrate the moment (the line {c0}+{c1}·{x}) two more times: once → PARABOLA (it is {EI}·v′), again → CUBIC (it is {EI}·v):
EIv1 = Integral{c0 + c1*x @ x} @@(EI·v′: parábola)
EIv2 = Integral{c0*x + c1*x^2/2 @ x} @@(EI·v: cúbica)
#diag(deflexion)
#: There it is: {EIv2} is of DEGREE 3. Look at its coefficients: each one is a mix of {c0}, {c1}, {EI} and the integration constants. But those exact values do NOT matter yet. The only thing that matters is that it is a CUBIC with 4 free numbers.
#: So to those 4 numbers, whatever they are, I give generic letters {a0}, {a1}, {a2}, {a3} — it is like saying that 3·x + 4·x² is written a·x + b·x². I am not making anything up: I only swap the tangled coefficients for clean letters, which I will FIX later with the 4 nodal conditions. And I move to the coordinate {s} = {x/L} (from 0 to 1):
vcubica = a0 + a1*s + a2*s^2 + a3*s^3 @@(la cúbica con 4 letras por fijar)
#: Now, the shape functions. Each one is that cubic when ONE nodal datum equals 1 and the other three 0; multiplying each shape by its nodal datum and adding, any deformed shape is built. The 4 constants are fixed with the 4 nodal data. I also need the slope of the cubic:
vslope = Diff{a0 + a1*s + a2*s^2 + a3*s^3 @ s} @@(pendiente dv/ds)
#: NOTE the rotation: since {s} = {x/L}, the physical rotation is θ = {1/L}·dv/ds; that is why a unit rotation requires a slope {L} in {s}, and the rotation functions carry {L}.
#: N1 — unit drop at the left end. At {s}=0: the cubic equals 1 and does not rotate → {a0}=1, {a1}=0. At {s}=1: it equals 0 and does not rotate → 1+{a2}+{a3}=0 and {a1}+2·{a2}+3·{a3}=0 → {a3}=2, {a2}=−3:
N1 = 1 - 3*s^2 + 2*s^3 @@(descenso izquierdo)
#: N2 — unit rotation at the left end: it does not drop but rotates 1 at {s}=0 → {a1}={L} (and {a0}=0); with nothing at {s}=1 we get {a2}=−2·{L}, {a3}={L}. That is why it carries the {L}:
N2 = L*(s - 2*s^2 + s^3) @@(giro izquierdo, con su L)
#: N3 and N4: the same with unit drop and rotation at the RIGHT end ({s}=1):
N3 = 3*s^2 - 2*s^3 @@(descenso derecho)
N4 = L*(-s^2 + s^3) @@(giro derecho, con su L)
#: Now I SEE them. Each Nᵢ is the shape the beam takes with its nodal datum = 1. The drop ones: N1 falls from 1 (left) to 0 (right); N3 the other way round:
#fplot(N1, N3, [0 1])
#: The rotation ones (I draw the part without the {L}, which only scales them): they start from zero, arch up and return to zero, one on each side:
N2f = s - 2*s^2 + s^3
N4f = -s^2 + s^3
#fplot(N2f, N4f, [0 1])

## 5 · The curvature of each weight (second derivative)
#: I differentiate each function twice with respect to {s}. They come out linear (the curvature of a cubic):
N1s = Diff{1 - 3*s^2 + 2*s^3 @ s} @@(pendiente de N₁)
N1ss = Diff{-6*s + 6*s^2 @ s} @@(curvatura de N₁)
N2s = Diff{L*s - 2*L*s^2 + L*s^3 @ s} @@(pendiente de N₂)
N2ss = Diff{L - 4*L*s + 3*L*s^2 @ s} @@(curvatura de N₂)
N3ss = Diff{6*s - 6*s^2 @ s} @@(curvatura de N₃)
N4ss = Diff{-2*L*s + 3*L*s^2 @ s} @@(curvatura de N₄)

## 6 · The change of variable brings the powers of L
#: Here {EI/L^3} is born. Since {s} = {x/L}, differentiating with respect to {x} brings in a {1/L} for each derivative: two derivatives → {1/L^2}. And when integrating in {x} one more factor {L} appears. Putting the three together, the common factor that comes out is {EI/L^3}; inside remain the curvatures in {s}, with their {L} factors from N2 and N4.

## 7 · The energy: why the stiffness is ∫ curvature·curvature
#: I already have the curvatures of the shapes. It remains to see why the stiffness is their integral. The energy stored by the beam when it bends goes with the SQUARE of the curvature: the energy per unit of bar is u = ½·{EI}·κ². And the deformed shape is the shape functions times the nodal displacements:
v = N*d @@(deformada de la barra)
#: Its curvature is the CURVATURES of the shapes (the {N''} of step 5) times those same displacements. When κ² is put into the energy and integrated over the bar, each pair of nodes is left multiplying the integral of {N''} by {N''}, times {EI}. That is exactly the entry {K} of the stiffness: each term is EI·∫ curvature·curvature. It is what is computed in step 8.

## 8 · The integral: where 12, 6L, 4L² come from
#: Each term is the integral of the product of two curvatures, from 0 to 1. The {L} factors of the rotation functions stay inside and raise the power of {L}:
k11 = Area{(-6+12*s)^2 @ s=0:1} @@(descenso izq con descenso izq)
k12 = Area{(-6+12*s)*L*(-4+6*s) @ s=0:1} @@(descenso izq con giro izq)
k13 = Area{(-6+12*s)*(6-12*s) @ s=0:1} @@(descenso izq con descenso der)
k22 = Area{L*(-4+6*s)*L*(-4+6*s) @ s=0:1} @@(giro izq con giro izq)
k24 = Area{L*(-4+6*s)*L*(-2+6*s) @ s=0:1} @@(giro izq con giro der)
#: Not a single {L} factor in drop–drop (it stays {12}), one in drop–rotation ({6*L}), two in rotation–rotation ({4*L^2}). I put together the common factor and the matrix of the 16 integrals:
factorL = EI/L^3 @@(el factor común)
K_coef = [12, 6*L, -12, 6*L; 6*L, 4*L^2, -6*L, 2*L^2; -12, -6*L, 12, -6*L; 6*L, 2*L^2, -6*L, 4*L^2] @@(la matriz de coeficientes)
#: The stiffness of the bar is the factor {factorL} times that matrix K_coef — all in symbols, with {EI} and {L}. Each coefficient came from an integral: the {12} from that of {(-6+12*s)^2}; the {6*L}, the same with one {L} factor; the {4*L^2}, with two. There it is derived, term by term, without putting in a single number.
