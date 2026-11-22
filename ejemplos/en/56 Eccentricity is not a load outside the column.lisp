# Eccentricity is not a load outside the column

#: In the drawings of sheets 48 and 54 a load point appears SHIFTED with respect to the column axis, and the doubt is a good one: nothing comes down there. **The load comes down the column, centered, always.** What is shifted is something else, and this sheet separates them.

## 1 · What really reaches the footing

#: TWO things come down from the column at once: a vertical force P, centered on its axis, and a moment M. Nobody invents the moment: it comes from earthquake, wind, frame continuity or from the beam on one side carrying more than the one on the other.
#dibujo("What comes down the column: centered force P and moment M", ud = m, escala = 1:22, cotas = m, alto = 130)
#  rect(0, 0, 2, 0.3, "gruesa")
#  achurado(0, 0, 2, 0.3, "diagonal")
#  rect(0.85, 0.3, 0.3, 1.1, "gruesa")
#  achurado(0.85, 0.3, 0.3, 1.1, "diagonal")
#  flecha(1, 2.1, 1, 1.48, "rojo")
#  texto(1.12, 1.95, "P", 3.2, "i")
#  flechamomento(1, 1.75, 0.42, 200, 340, "rojo")
#  texto(1.62, 1.78, "M", 3.2, "i")
#  linea(1, -0.15, 1, 2.25, "eje")
#  texto(1, -0.42, "the column axis", 2.4, "c")
#fin
#: Both come down through the SAME place: the column axis. No force is applied outside it.

## 2 · Why then is it drawn shifted

#: Because a force can be MOVED, if the price is paid. Moving P a distance e from its place changes the moment it produces at the base: a moment of value P times e appears. So, if that distance is chosen so that the moment that appears is exactly M, the two situations are the same for the base:
M_gen = P*e
#: Equating the generated moment to the real moment and solving for the distance:
e = M/P
#: That is the eccentricity: **the distance at which P would have to be placed, alone, to produce the same force and the same moment**. It is not where the load is: it is where its RESULTANT is.
#dibujo("The two situations are the same for the soil", ud = m, escala = 1:26, cotas = m, alto = 130)
#  rect(0, 0, 2, 0.3, "gruesa")
#  achurado(0, 0, 2, 0.3, "diagonal")
#  rect(0.85, 0.3, 0.3, 1.0, "gruesa")
#  flecha(1, 2.0, 1, 1.44, "rojo")
#  texto(1.1, 1.88, "P", 3, "i")
#  flechamomento(1, 1.68, 0.36, 200, 340, "rojo")
#  texto(1.52, 1.7, "M", 3, "i")
#  linea(1, -0.12, 1, 2.1, "eje")
#  texto(1, -0.45, "Centered P + M", 2.5, "c")
#  texto(2.35, 0.9, "IT IS THE SAME", 2.6, "c")
#  texto(2.35, 0.6, "for the base", 2.3, "c")
#  rect(2.7, 0, 2, 0.3, "gruesa")
#  achurado(2.7, 0, 2, 0.3, "diagonal")
#  rect(3.55, 0.3, 0.3, 1.0, "gruesa")
#  flecha(4.0, 2.05, 4.0, 1.38, "rojo")
#  texto(4.14, 1.94, "P", 3, "i")
#  linea(3.7, -0.12, 3.7, 2.1, "eje")
#  cota(3.7, 1.62, 4.0, 1.62, 0.26, "e = M/P")
#  texto(3.7, -0.45, "P shifted a distance e", 2.5, "c")
#fin
#: Both drawings give the same vertical force and the same moment at the base of the footing. And the soil sees neither columns nor moments: it sees a resultant. That is why we work with the one on the right, which is easier to draw and to distribute.
#: **The shifted arrow is the equivalent resultant, not a load hanging in the air.** If the point falls outside the footing (e greater than half the side) that is no longer a strange drawing: it means the footing overturns.

## 3 · The pressure, in 3D

#: Here you can see why it matters. The footing of example 3.8 measures 1.5 × 1.5 m and receives P = 606 kN with eccentricities of 0.15 and 0.30 m. The linear distribution of a rigid footing is a TILTED PLANE: mean pressure plus what each moment contributes. The horizontal axes are the two sides of the footing in meters and the vertical one is the pressure in [kPa]. **Drag with the mouse to rotate it.**
#surf(269.3 + 215.4*(x - 0.75) + 430.9*(y - 0.75), [0 1.5], [0 1.5])
#: **The vertical axis is the pressure on the soil, in [kPa]: the higher, the harder the footing presses.** The plane tilts toward the corner to which the load was shifted. At that corner the pressure reaches about 754 kPa; at the opposite one, the plane drops below zero: the formula asks the soil to PULL the footing.
#: The soil does not pull. What really happens is that this part lifts off and is left with zero pressure. The same surface, with the negative part clipped:
#: **Before looking at it, a warning, because it is easy to read backwards: the height of this drawing is the PRESSURE, not the footing.** It is not the deformed shape. What is HIGH and RED is where the footing CRUSHES the soil (the loaded corner, 754 kPa); what is FLAT and BLUE is where the footing LIFTS and does not touch (zero pressure). The lifted corner appears low because its pressure is zero, not because the footing goes down.
#surf((269.3 + 215.4*(x - 0.75) + 430.9*(y - 0.75) + abs(269.3 + 215.4*(x - 0.75) + 430.9*(y - 0.75)))/2, [0 1.5], [0 1.5])
#: The flat corner at the back is the lifted piece. That is the nonlinearity: no material breaks or yields, just a footing that stops touching.
#: Rotating it you can see that the plane does not change shape when clipped: what changes is the AREA that works. And since the load is still the same, when it is spread over less surface the pressure at the loaded corner rises. That is what sheet 54 measures.

## In one line

#: The load comes down the column and comes down centered; the eccentricity is the distance at which it must be imagined, alone, to also produce the moment. And when that distance takes the resultant out of the central core, the soil stops touching at one corner, which is where the nonlinearity begins.
