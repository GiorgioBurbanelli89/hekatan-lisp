# M11, M22 and M12 by FINITE ELEMENTS: the MZC plate element
#: 17-Sep-2026, Jorge: "give me the finite element formulation, not just the analytical Navier one".
#: Here the moment **does not come from a series**: it comes from **M = D · B · u**, with B derived from the element's shape functions.

## 1. The element: rectangular, 4 nodes, 12 DOF
#: Each node carries **w, θx, θy**. With 12 degrees of freedom we need 12 terms, and the classical Kirchhoff polynomial (Adini-Clough-Melosh / Melosh-Zienkiewicz-Cheung) is this:
w_e = a1 + a2*x + a3*y + a4*x^2 + a5*x*y + a6*y^2 + a7*x^3 + a8*x^2*y + a9*x*y^2 + a10*y^3 + a11*x^3*y + a12*x*y^3
#: It is an **incomplete** 4th-degree polynomial: it has x³y and xy³ but not x⁴, x²y² or y⁴. That is why it is **non-conforming**: the normal slope jumps between elements. Even so it converges and passes the patch test on rectangular meshes.

## 2. The rotations are partial derivatives of the deflection (Kirchhoff)
theta_x = Partial{a1 + a2*x + a3*y + a4*x^2 + a5*x*y + a6*y^2 + a7*x^3 + a8*x^2*y + a9*x*y^2 + a10*y^3 + a11*x^3*y + a12*x*y^3 @ y}
theta_y = Simplify{-Partial{a1 + a2*x + a3*y + a4*x^2 + a5*x*y + a6*y^2 + a7*x^3 + a8*x^2*y + a9*x*y^2 + a10*y^3 + a11*x^3*y + a12*x*y^3 @ x}}

#: Evaluating w, θx and θy at the **4 nodes** gives 12 equations: **u_e = C · a**. Inverting, **a = C⁻¹ · u_e**.

## 3. The curvatures: second partial derivatives
#: This is the row-by-row construction of matrix **B**: each curvature is a combination of the coefficients.
k_xx = Simplify{-Partial{Partial{a1 + a2*x + a3*y + a4*x^2 + a5*x*y + a6*y^2 + a7*x^3 + a8*x^2*y + a9*x*y^2 + a10*y^3 + a11*x^3*y + a12*x*y^3 @ x} @ x}}
k_yy = Simplify{-Partial{Partial{a1 + a2*x + a3*y + a4*x^2 + a5*x*y + a6*y^2 + a7*x^3 + a8*x^2*y + a9*x*y^2 + a10*y^3 + a11*x^3*y + a12*x*y^3 @ y} @ y}}
k_xy = Simplify{-2*Partial{Partial{a1 + a2*x + a3*y + a4*x^2 + a5*x*y + a6*y^2 + a7*x^3 + a8*x^2*y + a9*x*y^2 + a10*y^3 + a11*x^3*y + a12*x*y^3 @ x} @ y}}

#: Look at what disappears: **a1, a2 and a3 appear in no curvature**. They are the rigid-body motion (translation and the two rotations): they produce no stress. That is what every well-formulated element must satisfy.

## 4. The moments: M = D · k
#: The same plate constitutive law, but now **k comes from the element**, not from a series.
M_11 = Simplify{(E*t^3/(12*(1-nu^2)))*(k_xx + nu*k_yy)}
M_22 = Simplify{(E*t^3/(12*(1-nu^2)))*(k_yy + nu*k_xx)}
M_12 = Simplify{(E*t^3/(12*(1-nu^2)))*(1-nu)/2*k_xy}

#: In matrix form: **M = D·B·u_e**, where D is 3×3 and B is 3×12. The moments are **linear** within the element (because of the cubic terms), so the cleanest values come out at the centroid: that is what ETABS and SAP report at the centre of the area.

## 5. The element stiffness, with Gauss
#: **Ke = ∫∫ Bᵀ·D·B · dx dy**, and since B is quadratic, **2×2 Gauss is exact**.
#: Points ±1/√3 with weight 1, as was verified in sheet 42.

## 6. The numbers: the same slab measured against ETABS 19
#: Slab 10 × 10 m · t = 0.5 m · E = 2.2e7 kN/m² · nu = 0.2 · q = 10 kN/m² · 8×8 mesh (1.25 m element).
#: Solved with this same element in Hekatan Lab (`placa_MZC_fem_momentos.m`):
#: - **FEM deflection: 0.001728 m** · Navier 0.001701 m → **+1.58 %** · ETABS 19 Thin 0.00170024 m → **+1.61 %**
#: - **M11 = M22 = −42.75 kN·m/m** at the centre of the element closest to the centre (x = 4.375 m), versus **47.90 kN·m/m** from Timoshenko: **−10.8 %**, because that point is 0.884 m from the real centre of the slab and the moment drops quickly.
#: - **M12 = 1.10 kN·m/m** there, almost zero, as it should be near the centre.
#: The 8×8 mesh with a non-conforming element gives a slab that is **slightly more flexible**: +1.6 %. With 16×16 it drops below 0.5 %.

## 7. The difference from Navier, in one sentence
#: - **Navier**: a series that is valid only for a simply supported rectangular slab under uniform load.
#: - **FEM (MZC, DKT, MITC4)**: valid for any shape, support and load; the price is that the answer depends on the mesh.

## 8. The plate drawn (colormap + hover: move the cursor over it)
#: The deflection goes downward: hence the minus sign.
#surf(-sin(pi*x/10)*sin(pi*y/10), [0 10], [0 10])

#: **FEM M11 [kN·m/m]** (maximum 42.7 at the centre, zero at the edges):
#map(-42.7*sin(pi*x/10)*sin(pi*y/10), [0 10], [0 10])

#: **Twisting M12 [kN·m/m]** (zero at the centre, maximum at the corners — there the slab lifts):
#map(34.9*cos(pi*x/10)*cos(pi*y/10), [0 10], [0 10])
