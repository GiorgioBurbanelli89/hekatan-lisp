# Why does the color change only when the heavy axles come in?

#: A real question, watching the animation of the truck over the box culvert: «the truck comes in and everything stays blue; the color gradient appears only with the rear axles. Is it wrong?». It is not wrong. This sheet explains it from scratch, without assuming you know about bridges. Three ideas are enough: (1) what the color means, (2) how much each axle weighs, (3) how the box moves on the ground.

## 1 · What the color means

#: The color is NOT «how much it moves now». It is «how much it moves now, compared with the MOST it ever moves during the whole truck trip». Blue = almost nothing of that maximum. Red = the maximum. The scale is fixed on purpose: this way a color means the same in every frame and you can compare one instant with another. It is like a thermometer graduated up to the hottest day of the year: on a cool day the column barely rises, and that does not mean it is broken.
#: In this example the maximum of the whole trip is 6.80 mm. Below one eighth of that (0.85 mm) the palette stays in blues. Keep that number.

## 2 · How much each axle weighs

#: Units in this sheet: forces in kN (1 tonf = 9.81 kN; 145 kN is 14.8 tonf), lengths in m and settlements in mm. The unit is written in brackets at the end of the line and drawn next to the number; it is only for reading, the calculation uses pure numbers.
#: The HL-93 design truck has THREE axles (it is not a tandem: it is a front axle and two rear axles 4.3 m apart). The front one is light, the two at the back are heavy:
P_1 = 35 [kN] @@(eje delantero)
P_2 = 145 [kN] @@(eje trasero)
P_3 = 145 [kN] @@(eje trasero)
r = dec(P_1/P_2, 2) @@(sin unidades: es una proporción)
#: The front axle weighs {r} times a rear axle: less than a quarter.
#: Second piece: the structure is LINEAR. That means that if you put double the load at the same place, it moves double; a quarter of the load, a quarter of the movement. So the front axle, wherever you put it, will move the structure at most {r} of what a rear axle moves it at that same place. With that alone almost everything is understood: while only the front axle is on top, the color CANNOT go past light blue.

## 3 · How the box moves: it sinks and rocks

#: The culvert is not fixed in rock: it rests on the ground, which yields like a mattress of springs (this is called a Winkler soil). And the closed box is very stiff compared with that mattress. Result: what you see move most is not the slab bending, but the WHOLE BOX, which does two things at once: it SINKS evenly (due to the weight) and ROCKS toward the side where the load is (because the load is not at the center).
#: It can be calculated by hand treating the box as a rigid block of length B on springs. If there is a total load S on top, and its «moment» about the center is M_{o} (load times distance to the center), the settlement at a point x is: an even part S/(k·B) plus a tilted part that grows toward the edge.
B = 6 [m] @@(largo del cajón)
k_s = 19613.3 [kN/m^3] @@(balasto del suelo)
kB = dec(k_s*B/1000, 2) [kN/mm] @@(kN por cada mm de asiento)
#: k·B = {kB} (in kN per millimeter of settlement, for the 1 m strip). Two cases with a SINGLE axle to see the difference between being at the center and being at the edge:
w_centro = dec(P_2/kB, 3) [mm]
w_borde = dec(P_2/kB*(1 + 3), 3) [mm]
#: A 145 kN axle at the CENTER sinks the block {w_centro} mm, evenly. The same axle at the EDGE sinks that edge {w_borde} mm: FOUR times more, because besides sinking it tilts (the «1 + 3» comes from the geometry of the block: 6·e/B with the load at the end, e = B/2). That is why the maximum of the trip occurs with a heavy axle right at an edge, and not with the truck in the middle.

### The animation: the block under the passing truck

#: Blue line: the bottom slab seen from the side, sinking and tilting as the truck advances from left to right (each frame, the front axle advances half a meter). Red line: the maximum settlement of the whole trip, the one that corresponds to the color red. Look at the first frames: with only the front axle on top, the line barely separates from zero. When the first heavy axle enters from the left, the block suddenly rocks toward that side.
#anim fplot(asiento_mm = -((35*(1+sign(0.5*n+0.01))/2*(1+sign(6.01-0.5*n))/2 + 145*(1+sign(0.5*n-4.29))/2*(1+sign(10.31-0.5*n))/2 + 145*(1+sign(0.5*n-8.59))/2*(1+sign(14.61-0.5*n))/2) + (35*(1+sign(0.5*n+0.01))/2*(1+sign(6.01-0.5*n))/2*(0.5*n-3) + 145*(1+sign(0.5*n-4.29))/2*(1+sign(10.31-0.5*n))/2*(0.5*n-7.3) + 145*(1+sign(0.5*n-8.59))/2*(1+sign(14.61-0.5*n))/2*(0.5*n-11.6))*(x-3)/3)/117.68, maximo_del_viaje_mm = -4.93 + 0*x, cero = 0*x, [0 6]), n = 0:29

## 4 · The color along the trip: the hand calculation against the program

#: With the same rigid block the color of each instant can be predicted: the largest settlement of the block at that instant, divided by the largest of the whole trip. The curve is that hand calculation; the points are what Hekatan paints (finite elements, with the deformable box). x is the position of the front axle, in meters since it steps onto the culvert. The horizontal line is the blue threshold (1/8).
#fplot(bloque_rigido = (35*(1+sign(x+0.01))/2*(1+sign(6.01-x))/2 + 145*(1+sign(x-4.29))/2*(1+sign(10.31-x))/2 + 145*(1+sign(x-8.59))/2*(1+sign(14.61-x))/2 + abs(35*(1+sign(x+0.01))/2*(1+sign(6.01-x))/2*(x-3) + 145*(1+sign(x-4.29))/2*(1+sign(10.31-x))/2*(x-7.3) + 145*(1+sign(x-8.59))/2*(1+sign(14.61-x))/2*(x-11.6)))/580, umbral_del_azul = 0.125 + 0*x, Hekatan = [0.0 0.242; 0.6 0.198; 1.2 0.155; 1.8 0.115; 2.4 0.081; 3.0 0.061; 3.6 0.081; 4.2 0.115; 4.8 0.788; 5.4 0.585; 6.0 0.424; 6.6 0.357; 7.2 0.256; 7.8 0.314; 8.4 0.452; 9.0 0.656; 9.6 0.541; 10.2 0.787; 10.8 0.380; 11.4 0.265; 12.0 0.295; 12.6 0.427; 13.2 0.584; 13.8 0.761; 14.4 0.940; 14.6 1.000], [0 14.6])
#: Read it from left to right, like the movie:
#: • From 0 to 4.3 m only the front axle is on top. The color starts at 0.24 (light axle but at the edge, which multiplies by four), DROPS to 0.06 when the axle passes the center (there it only sinks, it does not tilt) and rises a little again. Almost all of that stretch is below or touching the blue threshold. That is what you saw: «the truck comes in and nothing changes».
#: • At 4.3 m the first 145 kN axle enters, and it enters at the EDGE: it is the strongest combination (heavy axle and a position that tilts). The color jumps from 0.12 to almost 0.8 from one frame to the next. That is where the gradient «appears».
#: • Afterwards it rises and falls depending on where the heavy axles are, and reaches 1.00 (red) at the end, when the last heavy axle leaves through the right edge.
#tabla("Instant","Hand calc.:3","Hekatan:3")({"Front axle entering, at the edge (x = 0)","Front axle over the central wall (x = 3)","First heavy axle enters (x = 4.8)","Last heavy axle at the right edge (x = 14.6)"}; [0.241, 0.060, 0.827, 1.000]; [0.242, 0.061, 0.788, 1.000])
#: The hand calculation gets the instants with a single axle almost exactly, and overshoots a little when there are two axles (0.83 against 0.79) because the real box deforms somewhat and distributes better. That a three-line model reproduces the program is the best sign that the program is not doing anything strange.

## 5 · So, how do I «see» the truck enter?

#: Displacement is a poor witness of the front axle, as said: it is light and the scale is that of the whole trip. The BENDING MOMENT of the top slab does respond from the first frame, because it is a local effect: the slab bends right under the wheel even if the box barely sinks. In the animation it is the red and blue diagram attached to the members. Compare the two curves, each divided by its own maximum of the trip: with only the front axle on top the moment one stays between 0.15 and 0.24, while the settlement one drops to 0.06.
#fplot(umbral = 0.125 + 0*x, Asiento_relativo = [0.0 0.242; 0.6 0.198; 1.2 0.155; 1.8 0.115; 2.4 0.081; 3.0 0.061; 3.6 0.081; 4.2 0.115; 4.8 0.788; 5.4 0.585; 6.0 0.424; 6.6 0.357; 7.2 0.256], Momento_relativo = [0.0 0.160; 0.6 0.185; 1.2 0.238; 1.8 0.228; 2.4 0.163; 3.0 0.154; 3.6 0.163; 4.2 0.228; 4.8 0.715; 5.4 0.961; 6.0 0.936; 6.6 0.732; 7.2 0.637], [0 7.5])

## 6 · In one sentence

#: The gradient appears «late» for three reasons that multiply: the front axle weighs a quarter; the color scale is that of the worst instant of the trip, which is produced by a heavy axle at the edge; and what is colored is the sinking of the whole box, which at the center is four times smaller than at the edge. 0.24 × (1/4) ≈ 0.06: blue. It is not a program error, and SAP2000 gives the same millimeters at each position (sheet 51).
