# Modal analysis, explained: mass, diaphragm and torsion

#: Two questions that every program answers differently and almost nobody explains: **where the mass comes from** and **what the diaphragm does**. With them you understand why two people with the same model do not get the same periods.
#: The numbers are those of the published 20 x 30 m curved shed, calculated in Hekatan Struct and checked against SAP2000 and ETABS.

## 1 · What a mode is

#: A structure with nothing pushing it can vibrate by itself, and only in certain shapes. Each shape is a **mode**, and each mode takes its own time to go and return: its **period**.
#: It comes from equating the elastic force to the inertial one. Without damping:
K*fi = omega^2*M*fi
#: With K the stiffness, M the mass, fi the mode shape and omega the frequency. There is no load on the right: the mode belongs to the structure, not to what you do to it.
#: And the period is what gets measured:
T = 2*pi/omega

## 1b · The three modes, drawn

#: Each mode goes at its own pace. Here are the first three of the shed, with their true period: mode 1 takes 0.3311 s to go and return, mode 3 only 0.2794 s. The stiffer the shape, the faster it vibrates.
#fplot(sin(2*pi*x/0.3311), sin(2*pi*x/0.3238), sin(2*pi*x/0.2794), [0 1])
#: The slowest curve is mode 1 (the fundamental): the one that rules. The other two are tighter.

## 1c · How the periods separate

#: And this is what happens when the structure gets stiffer: the period GOES DOWN. The relation is a square root, not proportional — you must multiply the stiffness by four to halve the period.
T = 2*pi*(m/K)^0.5
#: With the mass of the shed, sweeping the stiffness:
#fplot(2*pi*(4.2012/x)^0.5, [100 2000])
#: The drop is visible: at first, a little more stiffness lowers the period a lot; later it hardly does.

## 2 · Where the mass comes from

#| Programa | Masa horizontal | Masa VERTICAL |
#|---|---|---|
#| SAP2000 | sí | **sí, por defecto** |
#| ETABS | sí | **no, por defecto** |
#| Hekatan Struct | sí | sí (masa 3D, como SAP2000) |

#: **That row is the first cause of periods not matching.** Same model, same material, and they come out different because one counts the vertical mass and the other does not. It is nobody's mistake: it is a default option.
#: The mass comes from the weight: it is divided by gravity.
m = W/g
#: With the weight of the shed, in mass tonnes:
W = 41.2
g = 9.80665
m = dec(41.2/9.80665, 4)

## 3 · The diaphragm: rigid or flexible

#: A **rigid** diaphragm forces a whole floor to move together: a single displacement for all its nodes. It is what CEINCI-LAB does by construction, grouping the nodes by their elevation.
#: A **flexible** diaphragm lets each node go its own way. The slab or the sheet transmits what it can, and nothing more.

#: **The curved shed does NOT have a rigid diaphragm.** Its roof is 100 zinc shells of 0.8 mm that work **only as membrane**: in their plane yes, in bending no. It is declared with two numbers, the membrane one and the bending one:
#| Modificador | Valor | Qué significa |
#|---|---|---|
#| membrana | 1 | la chapa trabaja en su plano |
#| flexión | **0** | la chapa NO flecta |

#: In ETABS and SAP2000 it is exactly the same: a **membrane** shell, or setting the bending modifiers to zero. If it is left as a slab, the shed comes out stiffer than it is and the period comes out short.

## 4 · Mass participation: how many modes are needed

#: Not all modes move the same mass. The participation factor says what part of the total mass each mode drags:
Gamma = fi^T*M*r
#: And the code asks to reach 90 % of the mass by adding modes. NEC-15 §6.2.2 and ASCE 7-22 §12.9.1.1 say the same.

#: In the shed, with 12 modes:
#| Modo | T [s] | Tipo | Suma |
#|---|---:|---|---:|
#| 1 | 0.3311 | U_{y} (100 %) | 99.7 % |
#| 2 | 0.3238 | U_{x} (100 %) | 99.9 % |
#| 3 | 0.2794 | **R_{z} (100 %)** | — |
#| 4 | 0.1725 | U_{z} (38 %) | — |

#: With **two modes** it already exceeds 90 % in both directions. The rest refine, but do not change the result.

## 5 · Torsion: the mode that rotates

#: The third degree of each floor is not a displacement, it is a **rotation**: R_{z}. And there lies the criterion that matters.

#: **If the first mode is a rotation, the building has torsion.** It rotates before translating, and that punishes the corner columns.
#: In the shed the first two modes **translate** and the third rotates. That is the healthy case.

#: The mass that opposes rotation is not the plain mass: it is the **polar moment of inertia** of the slab. For a rectangular plan of sides a and b:
J_cm = m*(a^2 + b^2)/12
#: With the mass of the shed and its sides:
a = 20
b = 30
J_cm = dec(4.2012*(20^2 + 30^2)/12, 2)

#: The larger J_cm is, the harder it is to rotate. That is why an elongated plan rotates more easily than a square one of the same area.

## 5b · The mode shape, drawn as it is

#: **Warning, because it is a very common mistake:** mode 1 of the shed **is not a vertical belly**. It is **translational**: the whole structure goes sideways. The vertical belly is something else (a plate mode), and does not apply here.
#: The shape of the translational mode is measured in **height**: at the bottom, at the supports, the motion is zero; at the top it is maximum. It grows with height, but not in a straight line:
#fplot(sin(pi*x/2), [0 1])
#: The horizontal axis is the height (0 at the base, 1 at the roof) and the vertical, how much it moves. The whole structure goes **to the same side at once**: there is no intermediate point at rest.
#: The **torsional** one does have a point at rest, but in **plan**, not in height: the center of rotation. On one side the structure goes right and on the other left:
#fplot(x - 0.5, [0 1])
#: The zero in the middle is the axis of rotation. That is what distinguishes a mode that **translates** from one that **rotates**: the one that translates has no zero, the one that rotates does.

## 6 · What to look at, in order

#: 1 · Is **the vertical mass** counted the same in the two programs you compare? If not, the periods will not match.
#: 2 · Is the **diaphragm** rigid or flexible? A zinc sheet is not a slab.
#: 3 · Is **90 %** of the participating mass reached? If not, modes are missing.
#: 4 · Does the **first mode rotate**? Then there is torsion, and it must be looked at.