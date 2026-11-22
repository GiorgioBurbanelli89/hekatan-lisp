# Contour maps like Hekatan Engineers: fine bands, isolines in the color of their level and the value under the cursor
#numerico

#: **How we draw a results field.** (1) The value is **interpolated** inside each cell; one color per element is not painted: colors pass smoothly from one element to the next, without the steps of the mesh. (2) The range is split into **fine bands** (12 levels, ETABS/CSI scale). (3) At each band edge there is a **fine isoline in the color of its level** (not black), traced by interpolation: levels and gradients can be read at a glance. (4) When the cursor passes over, the **exact value** at that point is shown.

## 1 · A simply supported slab (Navier, first term)

a = 6 'side in x [m]
b = 4 'side in y [m]
q = 10 'uniform load [kN/m2]
h = 0.20 'thickness [m]
E = 25e6 'concrete modulus [kN/m2]
nu = 0.2 'Poisson
D = E·h^3/(12·(1 - nu^2)) 'plate flexural rigidity [kN·m]
#: First term of the Navier series (m = n = 1): the load q is distributed as 16·q/π² · sin(πx/a)·sin(πy/b):
q_11 = 16·q/pi^2 'load amplitude [kN/m2]
w_0 = q_11/(D·pi^4·(1/a^2 + 1/b^2)^2) 'maximum deflection (center) [m]
w(x, y) = w_0·sin(pi·x/a)·sin(pi·y/b)
w_mm(x, y) = 1000·w(x, y)

## 2 · The deflection w [mm]

#contourf(w_mm(x, y), [0 a], [0 b])
#: **How to read it.** The maximum is at the center, (a/2; b/2). The isolines are nearly ellipses elongated in x because the slab is longer in x (6 m) than in y (4 m): it bends more in the short direction.

## 3 · The moment M_x [kN·m/m]

#: M_x = D·w_0·π²·(1/a² + ν/b²)·sin(πx/a)·sin(πy/b):
M_x(x, y) = D·w_0·pi^2·(1/a^2 + nu/b^2)·sin(pi·x/a)·sin(pi·y/b)
#contourf(M_x(x, y), [0 a], [0 b])
M_max = M_x(a/2, b/2) 'moment at the center [kN·m/m]
#: **How to read it.** The same pattern as the deflection (a single term of the series), with the maximum at the center. With more terms of the series (m, n = 1, 3, 5…) the corners and edges would appear in more detail; here one is enough to see how to draw it.
