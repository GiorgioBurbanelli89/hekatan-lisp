# Shell-Thin: the thin plate of ETABS and SAP2000
#: 17-Sep-2026. What the **Shell-Thin** is, where its number comes from, and why ETABS, SAP2000 and Hekatan Struct all land on the same surface.

## 1. The idea, in one sentence
#: Thin = **Kirchhoff**: the plate only bends. A line perpendicular to the plate stays straight and perpendicular after bending, **without slipping by shear**. It is the Euler-Bernoulli beam, but in two directions.
#: Thick = **Mindlin**: that line can slip. It accounts for shear, and therefore gives a slightly more flexible result.
#: When to use which: if the span-to-thickness ratio exceeds 20, the difference is negligible and **Thin and Thick coincide**.

## 2. The bending stiffness D
#: It is the only constant of the thin plate: it joins the material (E, nu) with the thickness (t).
D = E*t^3/(12*(1-nu^2))

#: For concrete with E = 22 GPa, nu = 0.2 and t = 0.5 m (the data of the test against ETABS 19):
D_1 = 2.2*10^7*0.5^3/(12*(1-0.2^2))
#: That is **D = 238 715 kN·m** (the fraction above, in decimal).

## 3. The equation it solves
#: Kirchhoff in one line: the double Laplacian of the deflection, times D, is the load.
#: D*(d4w/dx4 + 2*d4w/dx2dy2 + d4w/dy4) = q
#: The Navier solution for a simply supported square slab sums sines. The first term already gives 99 % of the deflection:
w_1 = 16*q/(pi^6*D)*sin(pi*x/L)*sin(pi*y/L)

## 4. The deflection at the center
#: Setting x = y = L/2 and summing the series gives the classic Timoshenko coefficient:
w_max = 0.00406*q*L^4/D

#: With L = 10 m, q = 10 kN/m2 and the D above (t = 0.5 m):
w_centro = 0.00406*10*10^4/238715
#: That is **0.0017008 m = 1.70 mm** at the center (with Timoshenko's coefficient 0.00406).

#: **Measured in ETABS 19** with this same slab and an 8x8 mesh: 0.0017002 m.
#: The Navier series (19 terms) gives 0.0017018 m: **difference +0.089 %**; with the 0.00406 coefficient, +0.035 %, and it is the same for the five thicknesses tested (t/L from 0.001 to 0.2): it is not formulation, it is the series truncation.

## 5. The deflection surface (colormap + hover)
#: Rotate with the mouse and **hover the cursor over it**: it shows x, y and the deflection value at that node.
#: The deflection goes **downward** (the load is gravity): hence the minus sign. The plate sinks, it does not rise.
#surf(-sin(pi*x/10)*sin(pi*y/10), [0 10], [0 10])

## 6. The same field in plan view, like the ETABS color map
#map(-sin(pi*x/10)*sin(pi*y/10), [0 10], [0 10])

## 7. The moments come from the curvatures
#: Differentiating the deflection twice: where the surface is more curved, there is more moment.
Mxx = -D*(diff(diff(w,x),x) + nu*diff(diff(w,y),y))
Myy = -D*(diff(diff(w,y),y) + nu*diff(diff(w,x),x))
Mxy = -D*(1-nu)*diff(diff(w,x),y)

## 8. What to look at when comparing with CSI
#: - Same mesh, node by node, and offsets at zero.
#: - Thin against Thin: Hekatan Struct gives 0.000 % against ETABS in its slab test.
#: - If the slab is thick (span/thickness less than 10), Thin falls short: there Thick governs.
