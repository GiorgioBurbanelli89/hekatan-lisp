# Das example 6.10 footing, in 2D: from the formula to the finite element

#: The same footing as sheets 48 and 54, now seen **in plan**. What the FORMULA gives (linear distribution, rigid footing) is compared with what the FINITE ELEMENT of the Hekatan Struct model gives (flexible plate on springs that do not pull). The color map is traversed with the cursor: passing over it shows the value at that point.
#: Braja M. Das, *Principles of Foundation Engineering*, 9th ed. (2019), example 6.10, p. 247-248 · Spanish ed.: *Fundamentos de ingeniería de cimentaciones*, 7th ed., example 3.8.

## 1 · The data

#| Dato | Valor | Dato | Valor |
#|---|---:|---|---:|
#| B (en x) | 1.50 m | P | 606 kN |
#| L (en y) | 1.50 m | e_{x} | 0.15 m |
#| espesor t | 0.40 m | e_{y} | 0.30 m |
#| columna c | 0.30 m | f'_{c} | 240 kgf/cm^{2} |
#| k_{s} | 2000 tonf/m^{3} | malla | 4 x 4 |

#: The concrete modulus by ACI 318, and the subgrade modulus converted to SI:
E_c = 15100*240^0.5kgf/cm^2|kN/m^2
k_s = 2000tonf/m^3|kN/m^3

## 2 · The formula: linear distribution

#: If the footing were INFINITELY RIGID the pressure is distributed with a plane. First in letters, the mean pressure and the full plane:
sigma_prom = P/(B*L)
#: And the plane, with the two eccentricities; x and y are measured from the center:
sigma = sigma_prom*(1 + 12*e_x*x/B^2 + 12*e_y*y/L^2)
#: With the numbers. The mean:
sigma_prom = 606kN/(1.5m*1.5m)|kPa
#: And at the most loaded corner, x = y = 0.75 m:
sigma_esq = 269.33kPa*(1 + 12*0.15*0.75/1.5^2 + 12*0.3*0.75/1.5^2)|kPa

## 3 · The formula map

#: The pressure plane over the footing plan, in kPa. x and y go from 0 to 1.5 m, measured from the corner. **Move the cursor over it**: the value appears.
#map(269.3*(1 + 12*0.15*(x-0.75)/2.25 + 12*0.3*(y-0.75)/2.25), [0 1.5], [0 1.5])

#: The gradient is visible: the lower left corner is the unloaded one and the upper right the one that takes everything. But that plane has a problem.

## 4 · The soil does not pull: the nonlinearity

#: The plane above gives NEGATIVE pressure at the unloaded corner, and that would mean the soil is pulling the footing downward. It cannot. Where the plane comes out negative, the footing **lifts off**: there the pressure is zero and that part of the load is shared by the zones that do bear.
#: The condition, written short: the pressure is taken only if it pushes. The positive part of a number is itself added to its absolute value, divided by two — if it is negative they cancel and zero remains.
sigma_real = (sigma + abs(sigma))/2
#: The same map with that condition. The FLAT blue zone, all the same tone, is the one that **is lifted**: zero pressure. Compare it with the map above, where it kept going down there.
#map((269.3333*(1 + 12*0.15*(x-0.75)/2.25 + 12*0.3*(y-0.75)/2.25) + abs(269.3333*(1 + 12*0.15*(x-0.75)/2.25 + 12*0.3*(y-0.75)/2.25)))/2, [0 1.5], [0 1.5])
#: The scale reaches the same maximum as before, 754 kPa, but now the minimum is ZERO and not a negative number: the soil does not pull.

## 5 · What the finite element gives

#: The Hekatan Struct model does not assume a rigid footing: the mesh with Mindlin plate (Shell-Thick), a Winkler spring per node that works in compression only, and the load distributed over the column footprint. With the 4 x 4 mesh (42 nodes, 30 elements) this comes out:

#| Punto | x, y [m] | Asiento [mm] | Presión [kPa] |
#|---|---|---:|---:|
#| Esquina cargada | 1.50 , 1.50 | -36.26 | 711.2 |
#| Centro | 0.75 , 0.75 | -16.73 | 328.1 |
#| Esquina descargada | 0.00 , 0.00 | **+5.11** | 0.0 |
#| Borde | 1.50 , 0.00 | **+1.26** | 0.0 |

#: The positive sign is UPLIFT: those nodes rise, they do not bear. Three of the forty-two lift off.
#: And the comparison at the most loaded corner, formula against finite element:
dif = dec((754.0 - 711.2)/754.0*100, 1)
#: The formula gives 5.7 % more. It is not an error of either: the formula distributes over a RIGID footing, and this one, with 40 cm depth and 1.5 m side, flexes. By flexing it carries load toward the center and the tip is unloaded.

## 6 · Why it flexes: the relative stiffness

#: The criterion is the stiffness of the footing against that of the ground. With the concrete modulus and the soil modulus:
k_rel = dec(22940519/19613.3*(0.4/1.5)^3, 2)
#: Above 1 the footing behaves as rigid and the plane formula holds. Here it comes out well above, so the two should look alike — and they agree within 5.7 %. What separates them is not the flexure: it is **the uplift**, which the plane formula cannot do and the finite element can.
