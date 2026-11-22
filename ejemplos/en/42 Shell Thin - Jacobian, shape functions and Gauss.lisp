# Shell-Thin: shape functions, Jacobian and Gauss quadrature
#: 17-Sep-2026. First the **symbol** — where the shape functions come from, what the Jacobian is and why Gauss gives the exact value — and at the end the **number** and the **plot** of the thin plate.

## 1. The shape functions of the Q4 quadrilateral
#: On the natural square, from −1 to 1 in both directions. Each one equals **1 at its node and 0 at the other three**.
N_1 = Expand{(1-xi)*(1-eta)/4}
N_2 = Expand{(1+xi)*(1-eta)/4}
N_3 = Expand{(1+xi)*(1+eta)/4}
N_4 = Expand{(1-xi)*(1+eta)/4}

#: **Partition of unity**: the four add up to 1 at any point. If this fails, the element does not reproduce a rigid-body motion.
particion = Simplify{(1-xi)*(1-eta)/4 + (1+xi)*(1-eta)/4 + (1+xi)*(1+eta)/4 + (1-xi)*(1+eta)/4}

## 2. Derivatives in natural coordinates
dN1_dxi = Simplify{Partial{(1-xi)*(1-eta)/4 @ xi}}
dN1_deta = Simplify{Partial{(1-xi)*(1-eta)/4 @ eta}}
dN3_dxi = Simplify{Partial{(1+xi)*(1+eta)/4 @ xi}}
dN3_deta = Simplify{Partial{(1+xi)*(1+eta)/4 @ eta}}

## 3. The Jacobian: from the natural square to the real element
#: The geometry is interpolated with the SAME shape functions (isoparametric). For a rectangle of sides a and b centered at the origin:
x_geo = Simplify{(a/2)*xi}
y_geo = Simplify{(b/2)*eta}
J_11 = Simplify{Partial{(a/2)*xi @ xi}}
J_22 = Simplify{Partial{(b/2)*eta @ eta}}
detJ = Simplify{(a/2)*(b/2)}

#: The determinant is the **area factor**: dx·dy = detJ · dξ·dη. That is why every integral over the element is computed on the square and multiplied by detJ.

## 4. Gauss quadrature
#: Integrating exactly by hand is expensive; Gauss replaces the integral by a sum: **∫f ≈ Σ w_i · f(ξ_i)**.
#: With 2 points, ξ = ±1/√3 and weights 1, it is EXACT up to degree 3.
xi_g = 1/sqrt(3)
#: Test with ξ² (the exact integral is 2/3):
exacta = Integral{xi^2 @ xi}
gauss_2 = 1*(1/sqrt(3))^2 + 1*(-1/sqrt(3))^2
#: Gauss gives **2/3**, the same as the exact integral. That is why the Q4 stiffness is computed with 2×2 points.

## 5. The same, but for the plate stiffness
#: The bending stiffness comes from **K = ∫ Bᵀ·D·B · detJ dξ dη**, evaluated at the 4 Gauss points of the square.
D_b = E*t^3/(12*(1-nu^2))

## 6. The Shell-Thin plate drawn (colormap + **hover**: move the cursor)
#: The deflection goes **downward** (the load is gravity): hence the minus sign. The plate sinks, it does not rise.
#surf(-sin(pi*x/10)*sin(pi*y/10), [0 10], [0 10])

#: And in plan, like the ETABS color map:
#map(-sin(pi*x/10)*sin(pi*y/10), [0 10], [0 10])

## 7. NOW the numbers
#: 10 × 10 m slab · t = 0.5 m · E = 2.2e7 kN/m² · nu = 0.2 · q = 10 kN/m² · 8×8 mesh (1.25 m element).
detJ_num = (1.25/2)*(1.25/2)
#: **detJ = 0.3906 m²** per element (the element area is 4·detJ = 1.5625 m²).

D_num = 2.2*10^7*0.5^3/(12*(1-0.2^2))
#: **D = 238 715 kN·m**

w_centro = 0.00406*10*10^4/238715
#: **w = 0.0017008 m = 1.70 mm** at the center.

## 8. Against ETABS 19 (measured with this same mesh)
#: - Kirchhoff (Navier series, 19 terms): **0.00170175 m**
#: - ETABS 19 Shell-Thin: **0.00170024 m**
#: - Difference: **+0.089 %**, the same in the five thicknesses tested (t/L from 0.001 to 0.2).
#: It is the series truncation, not the formulation: the Shell-Thin of ETABS and SAP2000 falls on the Kirchhoff solution.
