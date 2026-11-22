# The stiffness matrix: from the formula to the numbers, and from there to OpenSees

#: Every analysis program comes down to **one matrix per element**. Here is the one for a bar: first in symbols, then with the numbers of a shed column, and at the end the same element written in OpenSees.

## 0 · The shed column

#: A square steel tube, the one that supports the curved frame.

b = 0.25 'outer side of the tube [m] ; t = 0.008 'wall thickness [m] ; L = 6.0 'free height [m]
E = 200000000 'steel modulus [kN/m²] ; G = 76923077 'shear modulus [kN/m²]

A = dec(0.25^2 - (0.25 - 2*0.008)^2, 6) [m²] 'section area
I = dec((0.25^4 - (0.25 - 2*0.008)^4)/12, 8) [m⁴] 'moment of inertia
EI = dec(200000000*0.00007565, 1) [kN·m²] 'flexural stiffness
EA = dec(200000000*0.007744, 0) [kN] 'axial stiffness

## 1 · The four terms, in symbols

#: A plane bar has **6 degrees of freedom**: at each end, two displacements and a rotation. Its matrix is 6×6, and **there are only four distinct numbers** inside:

#| Término | Fórmula | Qué mide |
#|---|---|---|
#| k_{axial} | E·A / L | cuánto cuesta **estirarla** |
#| k_{corte} | 12·E·I / L³ | cuánto cuesta **desplazar** un extremo |
#| k_{acopl} | 6·E·I / L² | el **acoplamiento** entre mover y girar |
#| k_{giro} | 4·E·I / L | cuánto cuesta **girar** un extremo |

#: The one next to it, `2·E·I / L`, is the **cross** rotation: what reaches the other end when you rotate this one.

## 2 · The same four, with numbers

k_a = dec(200000000*0.007744/6, 1) [kN/m] 'axial: E·A/L
k_v = dec(12*15129.8/6^3, 1) [kN/m] 'shear: 12·E·I/L³
k_m = dec(6*15129.8/6^2, 1) [kN] 'coupling: 6·E·I/L²
k_g = dec(4*15129.8/6, 1) [kN·m] 'rotation: 4·E·I/L
k_c = dec(2*15129.8/6, 1) [kN·m] 'cross rotation: 2·E·I/L

#: **Look at the difference between the axial and the shear one.** Stretching the column costs {k_a} kN/m; displacing it sideways, only {k_v} kN/m.
razon = dec(258133.3/840.5, 0) [—] 'how many times stiffer it is axially than in bending

#: **{razon} times.** That is why a structure moves sideways and hardly shortens: bending is the easy path.

## 3 · The matrix, assembled

#: With those five numbers it is written in full. Rows and columns go `[u1, v1, θ1, u2, v2, θ2]`:

K = [258133, 0, 0, -258133, 0, 0; 0, 840.5, 2521.6, 0, -840.5, 2521.6; 0, 2521.6, 10086.5, 0, -2521.6, 5043.3; -258133, 0, 0, 258133, 0, 0; 0, -840.5, -2521.6, 0, 840.5, -2521.6; 0, 2521.6, 5043.3, 0, -2521.6, 10086.5]

#: Three things seen at a glance that **are not a coincidence**:
#: · It is **symmetric**. It comes from Betti's theorem: the force that appears at `i` when moving `j` is the same as at `j` when moving `i`.
#: · The first and fourth rows are **opposite**: the axial force at one end is that of the other with the sign changed. It is equilibrium.
#: · The axial block does not mix with the bending one: **they are independent** in a straight bar.

## 4 · Why those numbers and not others: where they come from

#: They are not learned by heart. They come out of the same integral as always:
#: K = ∫ B^{T}·E·B dx
#: For the axial axis, `B = [−1/L, 1/L]`, so
#: K_{axial} = ∫ (1/L²)·E·A dx = **E·A/L**
#: And for bending, `B` is the **second derivative** of the Hermite functions. Integrating them gives `12/L³`, `6/L²` and `4/L`. The `12` and the `4` are not made up: they are what that integral gives.

## 5 · The stiffness of a story: what you do feel

#: A frame of two columns with the rigid beam on top. Each column contributes `12·E·I/L³`:
K_piso = dec(2*12*15129.8/6^3, 1) [kN/m] 'lateral stiffness of the frame
#: And with a mass of 20 t, its period:
T = dec(2*3.14159265*(20/1681)^0.5, 4) [s] 'period of the frame, T = 2π·√(m/K)

#: How the period changes if the column height is changed (the stiffness goes with `L³`):
#fplot(2*3.14159265*(20/(2*12*15129.8/x^3))^0.5, [3 9])
#: The horizontal axis is the height in meters. **A column twice as tall does not give twice the period: it gives almost triple**, because the stiffness drops with the cube.

## 6 · The same column, in OpenSees

#: And this is what is written so that OpenSees assembles **exactly that matrix**:

#: `model basic -ndm 2 -ndf 3` — two dimensions, three degrees per node
#: `node 1 0.0 0.0` and `node 2 0.0 6.0` — the column, from 0 to 6 m
#: `fix 1 1 1 1` — fixed at the bottom
#: `geomTransf Linear 1` — transformation from local to global
#: `element elasticBeamColumn 1 1 2 0.007744 200000000 0.00007565 1`

#: The three numbers in that last line are **`A`, `E` and `I`**: the same {A} m², {E} kN/m² and {I} m⁴ from above. OpenSees does not receive the matrix: it receives the data and **assembles it itself**, with the same four formulas.
#: That is why the three programs agree: **it is not that they copy each other, it is that they integrate the same thing**.

## 7 · And if the bar is thick: Timoshenko

#: When the bar is short and stocky, shear is no longer negligible and one more term appears:
#: φ = 12·E·I / (G·A_{s}·L²)
#: and `12·E·I/L³` becomes `12·E·I / (L³·(1+φ))`.
As = dec(2*0.008*0.25, 6) [m²] 'shear area of the tube: the two vertical walls
phi = dec(12*15129.8/(76923077*0.004*6^2), 6) [—] 'shear parameter
k_timo = dec(12*15129.8/(6^3*(1 + 0.00164)), 1) [kN/m] 'shear stiffness WITH Timoshenko

#: With this column, `φ` is {phi}: shear takes away 0.16 % of the stiffness. **In a slender column it does not matter; in a deep beam with a short span, it does.**
#: It is the same term that Wilson derives in chapter 4 and that SAP IV carries in `beam.for`. Hekatan Struct includes it, and that is why it asks for the `as` of each member.
