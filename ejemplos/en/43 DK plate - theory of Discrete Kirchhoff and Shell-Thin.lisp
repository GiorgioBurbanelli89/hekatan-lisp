# DK plate (Discrete Kirchhoff) and Shell-Thin: the theory
#: 17-Sep-2026. Where the **DKT/DKQ** element used by the programs for the thin plate comes from, why it is called "discrete", and how it differs from Shell-Thick.

## 1. The thin plate problem
#: Kirchhoff says: the line perpendicular to the plate **stays straight and perpendicular**. So the rotations are NOT free: they are the slope of the deflection.
beta_x = Partial{w(x,y) @ x}
beta_y = Partial{w(x,y) @ y}
#: That forces the deflection w to have **continuous derivatives between elements** (C1 continuity). And there lies the problem: **building a C1 element is very hard**. That was the wall of the 1960s.

## 2. Batoz's way out (1980): impose Kirchhoff ONLY at points
#: Instead of forcing the hypothesis over the whole element, one starts from Mindlin — rotations **independent** of the deflection, which only requires C0 continuity — and imposes Kirchhoff **at chosen points**: the 3 nodes and the 3 midpoints of the sides.
#: Hence the name: **Discrete Kirchhoff**. The constraint is discrete, not continuous.
#: - **DKT** = Discrete Kirchhoff Triangle (3 nodes, 9 DOF: w, θx, θy per node).
#: - **DKQ** = the same idea in the 4-node quadrilateral.

## 3. The rotations are interpolated with 2nd-degree polynomials
#: Each rotation uses the 6 functions of the 6-node triangle (the 3 vertices and the 3 side midpoints), in area coordinates.
N_1 = Expand{(2*L1-1)*L1}
N_4 = Expand{4*L1*L2}
#: The Kirchhoff condition at the midpoints eliminates the degrees of freedom of those nodes: only the 9 of the vertices remain.

## 4. The curvatures come from differentiating the rotations
#: This is the fundamental difference with pure Kirchhoff: here the ROTATIONS are differentiated, not the deflection twice.
k_xx = Partial{beta_x(x,y) @ x}
k_yy = Partial{beta_y(x,y) @ y}
k_xy = Simplify{Partial{beta_x(x,y) @ y} + Partial{beta_y(x,y) @ x}}

## 5. Moments: the bending constitutive law
D_b = E*t^3/(12*(1-nu^2))
M_xx = Simplify{(E*t^3/(12*(1-nu^2)))*(k_xx + nu*k_yy)}
M_yy = Simplify{(E*t^3/(12*(1-nu^2)))*(k_yy + nu*k_xx)}
M_xy = Simplify{(E*t^3/(12*(1-nu^2)))*(1-nu)/2*k_xy}

## 6. The element stiffness
#: **K = ∫ Bᵇᵀ · D · Bᵇ · detJ dA**. In the DKT, Bᵇ is **linear** in the natural coordinates and D is constant, so **a single Gauss point at the centroid is exact**: 2×2 is not needed.
#: That is the shortcut that makes the DKT so cheap: 9 DOF and a single evaluation per element.

## 7. Why DK is the "Thin" plate of the programs
#: - **Thin (DK)**: no shear deformation. For slabs with span/thickness greater than 20 it is the correct answer and does not suffer **shear locking**.
#: - **Thick (Mindlin, MITC4)**: adds the shear. Needed in thick slabs or footings; in thin slabs it gives almost the same, slightly more flexible.
#: - DK **does not suffer shear locking** because shear is not in its formulation: it was eliminated when imposing Kirchhoff.

## 8. The Shell-Thin plate drawn (colormap + **hover**: move the cursor)
#: The deflection goes **downward** (the load is gravity): hence the minus sign. The plate sinks, it does not rise.
#surf(-sin(pi*x/10)*sin(pi*y/10), [0 10], [0 10])

## 9. M11, M22, M12, V13, V23: what ETABS reports
#: With the Navier deflection w = A·sin(πx/L)·sin(πy/L), the engine differentiates and the plate internal forces come out.
#: **Moments** (per unit width, kN·m/m): the deflection is differentiated TWICE.
M_11 = Simplify{-D*(Partial{Partial{A*sin(pi*x/L)*sin(pi*y/L) @ x} @ x} + nu*Partial{Partial{A*sin(pi*x/L)*sin(pi*y/L) @ y} @ y})}
M_22 = Simplify{-D*(Partial{Partial{A*sin(pi*x/L)*sin(pi*y/L) @ y} @ y} + nu*Partial{Partial{A*sin(pi*x/L)*sin(pi*y/L) @ x} @ x})}
M_12 = Simplify{-D*(1-nu)*Partial{Partial{A*sin(pi*x/L)*sin(pi*y/L) @ x} @ y}}

#: **Shears** (kN/m): the moments are differentiated once more.
V_13 = Simplify{-D*Partial{Partial{Partial{A*sin(pi*x/L)*sin(pi*y/L) @ x} @ x} @ x} - D*Partial{Partial{Partial{A*sin(pi*x/L)*sin(pi*y/L) @ y} @ y} @ x}}
V_23 = Simplify{-D*Partial{Partial{Partial{A*sin(pi*x/L)*sin(pi*y/L) @ y} @ y} @ y} - D*Partial{Partial{Partial{A*sin(pi*x/L)*sin(pi*y/L) @ x} @ x} @ y}}

#: CSI nomenclature: **M11 and M22** bending moments in the two directions · **M12** twisting moment · **V13 and V23** out-of-plane shears. In Thin there is no shear deformation, but the equilibrium shears do exist.

### The color maps (10 m slab, t = 0.5 m, q = 10 kN/m², A = 0.0010753 m)
#: **M11 [kN·m/m]** — maximum at the center, zero at the supported edges:
#map(30.4*sin(pi*x/10)*sin(pi*y/10), [0 10], [0 10])

#: **M12 twisting [kN·m/m]** — zero at the center, maximum at the CORNERS (where the slab lifts up):
#map(-20.3*cos(pi*x/10)*cos(pi*y/10), [0 10], [0 10])

#: **V13 [kN/m]** — shear toward the supports, maximum at the edge x = 0 and x = L:
#map(15.9*cos(pi*x/10)*sin(pi*y/10), [0 10], [0 10])

#: **V23 [kN/m]** — the same, rotated 90°:
#map(15.9*sin(pi*x/10)*cos(pi*y/10), [0 10], [0 10])

#: Contrast values at the center: **M11 = M22 = 30.4 kN·m/m** (Timoshenko gives 0.0479·q·L² = 47.9 with the full series; with a single sine term it comes to 30.4, which is 63 %: the first term is enough for the deflection, not for the moment).

### Principal moments and direction (what ETABS calls Mmax, Mmin)
#: Just like Mohr's circle, but with moments: the axes rotate until the twisting moment vanishes.
M_max = (M11+M22)/2 + sqrt(((M11-M22)/2)^2 + M12^2)
M_min = (M11+M22)/2 - sqrt(((M11-M22)/2)^2 + M12^2)
tan_2theta = Simplify{2*M12/(M11-M22)}

### Wood-Armer reinforcement (what is used to design the slab)
#: The twisting moment is not reinforced directly: it is distributed by adding its absolute value to the two bending moments.
M_armar_x = M11 + abs(M12)
M_armar_y = M22 + abs(M12)

### Stresses on the plate face, from the moment
#: The extreme fibre is at t/2, and the section modulus per unit width is t²/6.
sigma_x = 6*M11/t^2
sigma_y = 6*M22/t^2
tau_xy = 6*M12/t^2
sigma_vm = Simplify{sqrt((6*M11/t^2)^2 - (6*M11/t^2)*(6*M22/t^2) + (6*M22/t^2)^2 + 3*(6*M12/t^2)^2)} @@(von Mises en la cara)

## 9. The numbers, against ETABS 19
#: 10 × 10 m slab, t = 0.5 m, E = 2.2e7 kN/m², nu = 0.2, q = 10 kN/m², 8×8 mesh.
D_num = 2.2*10^7*0.5^3/(12*(1-0.2^2))
#: **D = 238 715 kN·m**
w_centro = 0.00406*10*10^4/238715
#: **w = 0.0017008 m = 1.70 mm** at the center.
#: - Kirchhoff, Navier series (19 terms): **0.00170175 m**
#: - ETABS 19 Shell-Thin: **0.00170024 m** → **+0.089 %**
#: The same difference in the five thicknesses tested (t/L from 0.001 to 0.2): it is the series truncation, not the formulation.

## 10. What is NOT verified here
#: The Hekatan Lab example that builds the mesh with the framework's DKT (`placa_DKT_colormap.m`) gives a deflection **a thousand times smaller** than the theory. The error is in the assembly or in the DKT B matrix, and it is found by comparing **the stiffness matrix of ONE element** against ETABS or SAP2000, node by node, before looking at the full mesh.

## 11. The data the plots were made with
#: Everything drawn above comes from these numbers, so it can be repeated:
#: - Square slab **L = 10 m**, simply supported on the four edges.
#: - Thickness **t = 0.5 m** (L/t = 20: thin, Thin applies).
#: - **E = 2.2e7 kN/m²** · **nu = 0.2** · load **q = 10 kN/m²**.
#: - Stiffness **D = E·t³/12(1−ν²) = 238 715 kN·m**.
#: - Amplitude of the first Navier term: **A = q·L⁴/(4·π⁴·D) = 0.0010753 m**.
#:
#: From there come the coefficients of each map:
#: - Deflection drawn: **w = −A·sin(πx/L)·sin(πy/L)**, with the minus because the load is gravity.
#: - **M11 = M22 = D·A·(π/L)²·(1+ν) = 30.4 kN·m/m** at the center.
#: - **M12 = −D·A·(π/L)²·(1−ν) = −20.3 kN·m/m**, maximum at the corners.
#: - **V13 = V23 = 2·D·A·(π/L)³ = 15.9 kN/m**, maximum at the edges.
#: - Comparison mesh with ETABS: **8×8** elements of 1.25 m, **detJ = 0.3906 m²** per element.
#:
#: Check: (π/10)² = 0.098696 · D·A = 256.7 kN·m/m · 256.7 × 0.098696 × 1.2 = **30.4** ✔
