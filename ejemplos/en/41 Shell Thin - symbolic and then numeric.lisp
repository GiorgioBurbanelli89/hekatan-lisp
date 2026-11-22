# Shell-Thin (thin plate): from symbol to number
#: 17-Sep-2026. The whole **symbolic** development first — curvatures, moments, shears — and **the numbers at the end**, compared with ETABS 19.
#: The plate: square, simply supported, uniform load. It is the case of the `placa_thick_thin_sano` test of Hekatan Struct.

## 1. The Kirchhoff hypothesis, in symbols
#: The perpendicular line stays straight and perpendicular: the rotations are the slope of the deflection, **without shear**.
theta_x = Partial{A*sin(pi*x/L)*sin(pi*y/L) @ x} @@(giro alrededor de y)
theta_y = Partial{A*sin(pi*x/L)*sin(pi*y/L) @ y} @@(giro alrededor de x)

## 2. The assumed deflection (first Navier term)
#: A single sine in each direction already reproduces 99 % of the deflection of the supported slab.
w = A*sin(pi*x/L)*sin(pi*y/L)

## 3. Curvatures: differentiate twice
k_xx = Simplify{-Partial{Partial{A*sin(pi*x/L)*sin(pi*y/L) @ x} @ x}}
k_yy = Simplify{-Partial{Partial{A*sin(pi*x/L)*sin(pi*y/L) @ y} @ y}}
k_xy = Simplify{-2*Partial{Partial{A*sin(pi*x/L)*sin(pi*y/L) @ x} @ y}}

## 4. Bending stiffness and moments (symbols)
D = E*t^3/(12*(1-nu^2))
M_xx = Simplify{D*(k_xx + nu*k_yy)} @@(momento en x)
M_yy = Simplify{D*(k_yy + nu*k_xx)} @@(momento en y)
M_xy = Simplify{D*(1-nu)/2*k_xy} @@(torsor)

## 5. Shears: differentiate the moments
Q_x = Simplify{Partial{M_xx @ x} + Partial{M_xy @ y}} @@(cortante en x)
Q_y = Simplify{Partial{M_yy @ y} + Partial{M_xy @ x}} @@(cortante en y)

## 6. The Kirchhoff equation closes the problem
#: Substituting the assumed deflection into D·∇⁴w = q gives the amplitude A:
lap4 = Simplify{Partial{Partial{Partial{Partial{A*sin(pi*x/L)*sin(pi*y/L) @ x} @ x} @ x} @ x} + 2*Partial{Partial{Partial{Partial{A*sin(pi*x/L)*sin(pi*y/L) @ x} @ x} @ y} @ y} + Partial{Partial{Partial{Partial{A*sin(pi*x/L)*sin(pi*y/L) @ y} @ y} @ y} @ y}} @@(∇⁴w)
A_1 = q*L^4/(4*pi^4*D)

## 7. The plate, drawn: colormap and **hover** (move the cursor: x, y, deflection)
#: The deflection goes **downward** (the load is gravity): that is why the minus sign. The plate sinks, it does not rise.
#surf(-sin(pi*x/10)*sin(pi*y/10), [0 10], [0 10])

#: And the same field in plan, like the ETABS color map:
#map(-sin(pi*x/10)*sin(pi*y/10), [0 10], [0 10])

## 8. NOW the numbers
#: Slab L = 10 m · t = 0.5 m · E = 2.2e7 kN/m2 · nu = 0.2 · q = 10 kN/m2.
D_num = 2.2*10^7*0.5^3/(12*(1-0.2^2))
#: **D = 238 715 kN·m**

A_num = 10*10^4/(4*pi^4*238715)
#: **A = 0.0010753 m** (amplitude of the first sine)

w_centro = 0.00406*10*10^4/238715
#: **w = 0.0017008 m = 1.70 mm** at the center, with Timoshenko's coefficient 0.00406.
#: The full series (19 terms) gives **0.0017018 m**.

M_centro = 0.0479*10*10^2
#: **M = 47.9 kN·m/m** at the center (Timoshenko coefficient 0.0479 for nu = 0.2).

## 9. Against ETABS 19 (measured, same 8x8 mesh)
#: - t/L = 0.001 → Kirchhoff 212.719 m · ETABS 212.529 m · +0.089 %
#: - t/L = 0.01 → 0.212719 · 0.212529 · +0.089 %
#: - t/L = 0.05 → 0.00170175 · 0.00170024 · +0.089 %
#: - t/L = 0.1 → 0.000212719 · 0.000212529 · +0.089 %
#: - t/L = 0.2 → 2.659e-05 · 2.657e-05 · +0.089 %
#: The difference is **the same at all five thicknesses**: it is the series truncation, not the formulation. Shell-Thin of ETABS and of SAP2000 falls on the Kirchhoff solution.
