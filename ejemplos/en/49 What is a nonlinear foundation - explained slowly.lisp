# What is a NONLINEAR foundation? Explained slowly

#: This sheet is for UNDERSTANDING, not for designing. A single idea sums it up: the soil can PUSH on the footing, but it cannot PULL it. Everything else follows from that.

## 1 · Linear versus nonlinear

#: LINEAR: double the load gives double the response. It is a straight line, like y = m·x + b with b = 0: the force of a spring is its stiffness times how much it stretches or is squashed.
F_resorte = k*delta
#: NONLINEAR: the rule CHANGES depending on what happens. The soil is a spring that only works when you squash it (δ > 0). If you "stretch" it (δ < 0, the footing rises), it does nothing: zero force. It is written with half of (δ + |δ|), which equals δ if δ is positive and 0 if it is negative:
F_suelo = k*(delta + abs(delta))/2
#: The two together, with k = 1 (left plot, below in section 2). The blue one is a straight line from end to end. The soil one is straight on the right and FLAT on the left: it has a KINK at δ = 0. That kink is the nonlinearity.

## 2 · A single spring, animated

#: It is squashed and stretched little by little: the curve is drawn from left to right. On the pull side (left) the normal spring responds with negative force; the soil stays at zero because the footing simply LIFTS OFF. On the right, pushing, both respond the same.
#fila
#fplot(resorte = x, suelo = (x + abs(x))/2, [-1 1])
#anim fplot(resorte = x*(1 + sign(n/10 - x))/2, suelo = (x + abs(x))/2*(1 + sign(n/10 - x))/2, [-1 1]), n = -10:10
#finfila

## 3 · The footing: a row of springs

#: The program puts a spring under each point of the footing (the Winkler bed). The pressure at each point is how much its spring is squeezed. If the column is CENTERED, the footing goes down evenly and all springs squeeze the same: uniform pressure, Q divided by the area. With the footing of Das example 6.10 (1.5 × 1.5 m, Q = 61.795 tonf = 606 kN):
q_media = dec(61.795/(1.5*1.5), 2)
#: In tonf/m², the same over the whole base (x goes from one edge to the other):
#fplot(q = 27.46, [0 1.5])

## 4 · The key animation: the column moves off-center (eccentricity e)

#: If the load shifts a distance e toward an edge, that edge squeezes more and the other less. With a rigid footing the pressure is a STRAIGHT LINE (Das 9th ed., eqs. 6.51 and 6.52, p. 236):
q_max = Q/(B*L)*(1 + 6*e/B)
q_min = Q/(B*L)*(1 - 6*e/B)
#: q_min reaches zero exactly when e = B/6 (the parenthesis vanishes). Past that point the line would give NEGATIVE pressure: the soil would have to PULL the edge. Since it cannot, the edge LIFTS and the real pressure is a shorter, taller triangle (Das, eq. 6.53, p. 236):
q_real = 4*Q/(3*L*(B - 2*e))
a_contacto = 3*(B/2 - e)
#: The animation: e rises from 0 to B/3 in steps of B/60 (n = 0 … 20). x is measured from the loaded edge.
#: • "lineal" = what a soil that DOES pull would give: a line that, past e = B/6 (n = 10), crosses zero and keeps going down. That part below zero is IMPOSSIBLE tension.
#: • "sin_traccion" = the real soil: rectangle → trapezoid → triangle that touches 0 at n = 10; then the edge stays at ZERO (lifted) and the triangle gets shorter and rises.
#anim fplot(lineal = 27.4644*(1 + 0.1*n) - 3.66192*n*x, sin_traccion = ((1 + sign(10.5 - n))/2)*(27.4644*(1 + 0.1*n) - 3.66192*n*x) + ((1 - sign(10.5 - n))/2)*(54.9289/(1.5 - 0.05*n))*((1 - x/(2.25 - 0.075*n)) + abs(1 - x/(2.25 - 0.075*n)))/2, [0 1.5]), n = 0:20
#: Look at the end (n = 20, e = B/3 = 0.5 m): the linear line reads 82.4 at the edge and −27.5 on the other side; the real one reads 110 at the edge and the contact measures only 3·(0.75 − 0.5) = 0.75 m. The real soil squeezes MORE over less area.
q_n20 = dec(54.9289/(1.5 - 0.05*20), 1)
a_n20 = dec(3*(0.75 - 0.5), 2)

## 5 · Why the computer has to ITERATE

#: The program does not know beforehand which part of the footing bears. So it tries: 1) solve with ALL springs; 2) those that ended up pulling (node that rose) are turned OFF; 3) solve again. Repeat until no spring changes. These are the 4 REAL rounds of Hekatan with Das example 6.10 (1.5 × 1.5 m, e_{B} = 0.15 m and e_{L} = 0.30 m, mesh of 961 nodes):
#tabla("Round:0","Active springs:0","In tension:0","Turned off:0","Turned on:0","q_max [tonf/m²]:2")([1, 2, 3, 4]; [961, 851, 802, 798]; [110, 49, 4, 0]; [110, 49, 4, 0]; [0, 0, 0, 0]; [76.67, 81.34, 81.91, 81.91])
#: Round 1 = the linear calculation: 110 springs pull and the maximum pressure is 76.67. Those 110 are turned off → round 2: 49 more pull. Round 3: 4. Round 4: none → finished. 798 of 961 nodes remain bearing.
#: The pressure along the footing DIAGONAL (from the most loaded corner, x = 0, to the opposite one) in each round n. In round 1 the curve drops below zero at the end (tension); in the following ones those points are turned off and the pressure rises where it does bear:
#anim fplot(q = (1 - sign(abs(n - 1)))*(76.67*(1 - abs(x - 0)/0.2121 + abs(1 - abs(x - 0)/0.2121))/2 + 66.87*(1 - abs(x - 0.2121)/0.2121 + abs(1 - abs(x - 0.2121)/0.2121))/2 + 57.09*(1 - abs(x - 0.4243)/0.2121 + abs(1 - abs(x - 0.4243)/0.2121))/2 + 47.32*(1 - abs(x - 0.6364)/0.2121 + abs(1 - abs(x - 0.6364)/0.2121))/2 + 37.47*(1 - abs(x - 0.8485)/0.2121 + abs(1 - abs(x - 0.8485)/0.2121))/2 + 27.55*(1 - abs(x - 1.0607)/0.2121 + abs(1 - abs(x - 1.0607)/0.2121))/2 + 17.65*(1 - abs(x - 1.2728)/0.2121 + abs(1 - abs(x - 1.2728)/0.2121))/2 + 7.76*(1 - abs(x - 1.4849)/0.2121 + abs(1 - abs(x - 1.4849)/0.2121))/2 + -2.11*(1 - abs(x - 1.6971)/0.2121 + abs(1 - abs(x - 1.6971)/0.2121))/2 + -11.97*(1 - abs(x - 1.9092)/0.2121 + abs(1 - abs(x - 1.9092)/0.2121))/2 + -21.83*(1 - abs(x - 2.1213)/0.2121 + abs(1 - abs(x - 2.1213)/0.2121))/2) + (1 - sign(abs(n - 2)))*(81.34*(1 - abs(x - 0)/0.2121 + abs(1 - abs(x - 0)/0.2121))/2 + 70.33*(1 - abs(x - 0.2121)/0.2121 + abs(1 - abs(x - 0.2121)/0.2121))/2 + 59.34*(1 - abs(x - 0.4243)/0.2121 + abs(1 - abs(x - 0.4243)/0.2121))/2 + 48.35*(1 - abs(x - 0.6364)/0.2121 + abs(1 - abs(x - 0.6364)/0.2121))/2 + 37.29*(1 - abs(x - 0.8485)/0.2121 + abs(1 - abs(x - 0.8485)/0.2121))/2 + 26.15*(1 - abs(x - 1.0607)/0.2121 + abs(1 - abs(x - 1.0607)/0.2121))/2 + 15.03*(1 - abs(x - 1.2728)/0.2121 + abs(1 - abs(x - 1.2728)/0.2121))/2 + 3.92*(1 - abs(x - 1.4849)/0.2121 + abs(1 - abs(x - 1.4849)/0.2121))/2) + (1 - sign(abs(n - 3)))*(81.91*(1 - abs(x - 0)/0.2121 + abs(1 - abs(x - 0)/0.2121))/2 + 70.74*(1 - abs(x - 0.2121)/0.2121 + abs(1 - abs(x - 0.2121)/0.2121))/2 + 59.58*(1 - abs(x - 0.4243)/0.2121 + abs(1 - abs(x - 0.4243)/0.2121))/2 + 48.43*(1 - abs(x - 0.6364)/0.2121 + abs(1 - abs(x - 0.6364)/0.2121))/2 + 37.21*(1 - abs(x - 0.8485)/0.2121 + abs(1 - abs(x - 0.8485)/0.2121))/2 + 25.91*(1 - abs(x - 1.0607)/0.2121 + abs(1 - abs(x - 1.0607)/0.2121))/2 + 14.63*(1 - abs(x - 1.2728)/0.2121 + abs(1 - abs(x - 1.2728)/0.2121))/2 + 3.35*(1 - abs(x - 1.4849)/0.2121 + abs(1 - abs(x - 1.4849)/0.2121))/2) + (1 - sign(abs(n - 4)))*(81.91*(1 - abs(x - 0)/0.2121 + abs(1 - abs(x - 0)/0.2121))/2 + 70.74*(1 - abs(x - 0.2121)/0.2121 + abs(1 - abs(x - 0.2121)/0.2121))/2 + 59.58*(1 - abs(x - 0.4243)/0.2121 + abs(1 - abs(x - 0.4243)/0.2121))/2 + 48.43*(1 - abs(x - 0.6364)/0.2121 + abs(1 - abs(x - 0.6364)/0.2121))/2 + 37.21*(1 - abs(x - 0.8485)/0.2121 + abs(1 - abs(x - 0.8485)/0.2121))/2 + 25.91*(1 - abs(x - 1.0607)/0.2121 + abs(1 - abs(x - 1.0607)/0.2121))/2 + 14.62*(1 - abs(x - 1.2728)/0.2121 + abs(1 - abs(x - 1.2728)/0.2121))/2 + 3.35*(1 - abs(x - 1.4849)/0.2121 + abs(1 - abs(x - 1.4849)/0.2121))/2), [0 2.1213]), n = 1:4

## 6 · Why it matters

#: If it is computed as linear (soil that pulls), the maximum pressure comes out 76.67 instead of 81.91 tonf/m²: 6.4 % LESS, on the unsafe side. And the "lifted" zone appears pulling on the soil, which does not happen.
dif = dec((76.670/81.914 - 1)*100, 1)
#: Five programs with the same mesh give the same. In the plot, x is the program number (1 SAP2000, 2 Hekatan, 3 SAFE, 4 ETABS, 5 OpenSeesPy); the "rigida" line is the rigid Das footing (82.21) and "lineal" the soil that pulls (76.67):
#: On the right, as a function of e (another footing, 2 × 2 m, P = 60 tonf): the curve is Das's formula; the points, the finite element calculation. They also follow the curve after e/L = 1/6, where lift-off begins.
#fila
#fplot(rigida = 82.211, lineal = 76.670, SAP2000 = [1 81.914], Hekatan = [2 81.915], SAFE = [3 81.915], ETABS = [4 81.915], OpenSeesPy = [5 81.915], [0.5 5.5])
#fplot(Das = 15*(1 + 6*x)*(1 + sign(1/6 - x))/2 + (20/(1 - 2*x))*(1 - sign(1/6 - x))/2, SAP2000 = [0 15.180; 1/12 22.464; 1/6 30.000; 1/4 40.052; 1/3 60.038], Hekatan = [0 15.180; 1/12 22.464; 1/6 30.000; 1/4 40.055; 1/3 60.072], [0 0.4])
#finfila

## In one line

#: NONLINEAR = the soil cannot pull. That is why it has to be recomputed, turning off what pulls, until the contact zone stops changing.
