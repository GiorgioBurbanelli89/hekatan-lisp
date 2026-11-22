# Rigid vs flexible diaphragm: center of mass, center of rigidity and torsion
#: The same **12 m × 8 m** floor plan with an earthquake in **Y**. Three walls resist in Y (axes x = 0, 6 and 12 m) and two in X (axes y = 0 and 8 m). The mass is uniformly distributed. We solve it twice: with a **rigid** slab and with a **flexible** slab.

#numerico
## 1 · Data
#| Muro | Dirección | Posición [m] | Rigidez [kN/mm] |
#|---|---|---:|---:|
#| 1 | Y | x₁ = 0 | k₁ = 200 |
#| 2 | Y | x₂ = 6 | k₂ = 100 |
#| 3 | Y | x₃ = 12 | k₃ = 50 |
#| 4 y 5 | X | y = 0 y y = 8 | kx = 150 cada uno |
#: Plan **Lx = 12 m**, **Ly = 8 m**; story shear in Y **V = 300 kN**.
#hide
Lx = 12 @@(largo de la planta en X, m)
Ly = 8 @@(ancho de la planta en Y, m)
V = 300 @@(cortante del piso en dirección Y, kN)
k1 = 200 @@(rigidez del muro 1 en Y, eje x = 0, kN/mm)
k2 = 100 @@(rigidez del muro 2 en Y, eje x = 6 m, kN/mm)
k3 = 50 @@(rigidez del muro 3 en Y, eje x = 12 m, kN/mm)
x1 = 0 @@(posición del muro 1, m)
x2 = 6 @@(posición del muro 2, m)
x3 = 12 @@(posición del muro 3, m)
kx = 150 @@(rigidez de cada uno de los 2 muros en X, ejes y = 0 y y = 8 m, kN/mm)
#show

## 2 · RIGID diaphragm: why there IS a CM and a CR
#: The slab does not deform in its plane. So **the whole floor** moves with just 3 numbers: u_x, u_y and the rotation θ. Each wall moves according to the line **u_i = u_y + θ·(x_i − x_CR)**, just like y = m·x + b: the slope is θ and the intercept is u_y.
#: If the whole plan follows a single line, there is also **a single point where the inertia acts (CM)** and **a single point where a force does not make the plan rotate (CR)**.
xCM = Lx/2 @@(centro de masa: masa uniforme, centro de la planta, m)
Ky = k1 + k2 + k3 @@(rigidez lateral total del piso en Y, kN/mm)
xCR = (k1*x1 + k2*x2 + k3*x3)/Ky @@(centro de rigidez: posición promedio pesada por la rigidez, m)
e = xCM - xCR @@(excentricidad inherente CM − CR, m)
ea = 0.05*Lx @@(excentricidad accidental: 5 % de la dimensión perpendicular a la fuerza, NEC-15 §6.3.6, m)
et = e + ea @@(excentricidad total, m)
Mt = V*et @@(momento torsor del piso, kN·m)
Kt = k1*(x1-xCR)^2 + k2*(x2-xCR)^2 + k3*(x3-xCR)^2 + 2*kx*(Ly/2)^2 @@(rigidez a torsión respecto del CR, kN·m²/mm)
uy = V/Ky @@(traslación del piso en Y, mm)
th = Mt/Kt @@(giro θ del piso, mm/m (milésimas de radián))
u1 = uy + th*(x1-xCR) @@(desplazamiento del muro 1: está sobre la recta, mm)
u2 = uy + th*(x2-xCR) @@(desplazamiento del muro 2, mm)
u3 = uy + th*(x3-xCR) @@(desplazamiento del muro 3, mm)
V1 = k1*u1 @@(cortante que toma el muro 1, kN)
V2 = k2*u2 @@(cortante que toma el muro 2, kN)
V3 = k3*u3 @@(cortante que toma el muro 3, kN)
Vsum = V1 + V2 + V3 @@(comprobación: suma de cortantes = V, kN)
#: The **stiffest** wall (number 1) takes more shear: with a rigid slab the force is distributed **by stiffness** and the rotation moves the flexible edge more.

## 3 · Torsion control with a RIGID diaphragm
umax = u3 @@(desplazamiento máximo, en el borde flexible x = 12 m, mm)
uprom = (u1 + u3)/2 @@(promedio de los dos bordes, mm)
rt = umax/uprom @@(relación de torsión δmax/δprom; irregular si > 1.2, NEC-15 Tabla 13 tipo 1)
Ax = (umax/(1.2*uprom))^2 @@(amplificación de la torsión accidental, borrador ec. 6.7, entre 1 y 3)
#: It is corrected by bringing the CR closer to the CM (in this example, stiffening wall 3) until δmax/δavg ≤ 1.2.

## 4 · FLEXIBLE diaphragm: why there is NO CR (and the CM no longer matters)
#: The slab bends like a **simple beam supported on the walls**. Each wall receives the load of its **tributary area**, regardless of its stiffness.
w = V/Lx @@(carga sísmica por metro de planta, kN/m)
F1 = w*(x2-x1)/2 @@(muro 1: tributaria de 3 m, kN)
F2 = w*((x2-x1)/2 + (x3-x2)/2) @@(muro 2: tributaria de 6 m, kN)
F3 = w*(x3-x2)/2 @@(muro 3: tributaria de 3 m, kN)
d1 = F1/k1 @@(desplazamiento del muro 1 con losa flexible, mm)
d2 = F2/k2 @@(desplazamiento del muro 2, mm)
d3 = F3/k3 @@(desplazamiento del muro 3, mm)
g12 = (d2 - d1)/(x2 - x1) @@(«giro» del tramo 1–2: pendiente entre muros 1 y 2, mm/m)
g23 = (d3 - d2)/(x3 - x2) @@(«giro» del tramo 2–3: pendiente entre muros 2 y 3, mm/m)
#: **g12 ≠ g23**: the walls **do not lie on a single line**, so the floor does not have a single rotation θ. Without a single θ there is no point "where θ = 0", that is, **there is no CR**.
#: The **CM** does exist in the geometry (x = 6 m), but the slab **does not carry** the inertia to that point: each piece of mass goes to its own wall. That is why there is **no floor torsion** to distribute.

## 5 · How torsion is controlled with a flexible diaphragm
#: 1. **Each wall line separately**: it is designed with its tributary force (F1, F2, F3) and must meet the drift limit **on its own** (draft §5.3.1.1 c.2).
#: 2. **No accidental torsion**: draft §6.2.4.2 requires the 5 % only *"for diaphragms that are not flexible"*. NEC-15 §6.3.6 requires distributing *"taking that condition into account"*.
#: 3. **Check that it really is flexible**: draft eq. 5.1, **MDD/ADVE > 2** (maximum slab deflection over the average drift of the walls). If it fails and the slab is not rigid either (§5.3.1.2), it is **semi-rigid**: the slab is modeled with shells.
#: 4. **Semi-rigid**: the CR can only be approximated (distributing the load by mass). The torsional irregularity is measured with **δmax/δavg** at the edges, which **does not need a CR**: just two displacements. This is how Hekatan Struct does it without a diaphragm.
#: 5. Common practice: design each wall with the **larger** of the two forces (rigid and flexible), because the real slab lies between the two.
Vm1 = max(V1, F1) @@(muro 1: envolvente rígido/flexible, kN)
Vm2 = max(V2, F2) @@(muro 2: envolvente rígido/flexible, kN)
Vm3 = max(V3, F3) @@(muro 3: envolvente rígido/flexible, kN)

## 6 · Summary: the same floor, two slabs
#| Muro | Rígido: V [kN] | Flexible: F [kN] | Rígido: u [mm] | Flexible: d [mm] |
#|---|---:|---:|---:|---:|
#| 1 (k = 200) | 114.6 | 75 | 0.573 | 0.375 |
#| 2 (k = 100) | 107.0 | 150 | 1.070 | 1.500 |
#| 3 (k = 50) | 78.4 | 75 | 1.567 | 1.500 |
#: Rigid: the 3 displacements fall on **a line** (single rotation θ → there is a CR and torsion). Flexible: they **do not** fall on a line (no CR) and each wall takes the share of its tributary area.
