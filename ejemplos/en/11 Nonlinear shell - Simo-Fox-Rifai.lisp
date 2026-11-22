# The shell that rotates without breaking — Simo·Fox·Rifai (1990)
#: Self-contained document in Hekatan LISP. The text explains; whatever the **engine can compute is truly computed** (roll-up, the director norm, the constitutive law).
#: Source: J.C. Simo, D.D. Fox, M.S. Rifai — *On a stress resultant geometrically exact shell model, Part III*, CMAME **79** (1990) 21–70.

## 1 · The problem, in one sentence
#: A thin shell under large loads **rotates a lot** (a flat beam can be rolled into a complete circle). If you describe that rotation with **Euler angles**, at some point they **jam** (gimbal singularity): two axes line up and you lose a degree of freedom. The element blows up.
#: The paper's idea: **do not store angles**. Store the shell **normal** —the *director* **t**— and make it **roll over the sphere**. Rolling never jams.

## 2 · Where the director lives: the sphere S²
#: The director is a **unit** vector: it points, it has no length. That is why it lives on the sphere of radius 1, called **S²**.
#: The mother rule is that its norm is always one:  ‖t‖ = 1.
#: An admissible increment **Δt** is **tangent** to the sphere, that is, **perpendicular** to the director:  t · Δt = 0.
#: That perpendicularity is what leaves the director's rotation **2 degrees of freedom** (not 3): moving over a 2D surface.

## 3 · The heart: the exponential map (Box 2)
#: To update the director at each Newton iteration, instead of adding `t + Δt` (which would leave the sphere), it makes it **roll along a great-circle arc**. With θ = ‖Δt‖ the size of the angular step, formula (2.7)/(4.9) is:
#|  t_nuevo  =  cos(θ)·t  +  ( sin(θ) / θ )·Δt
#: The key question: **is the new director still unit length?** Since t ⊥ Δt and ‖t‖ = 1, squaring the norm makes the cross terms vanish and leaves **cos²θ + sin²θ**. I **compute it with the engine** in two steps, a small one and a large one:
theta_chico = 0.6
unitario_chico = cos(0.6)^2 + sin(0.6)^2
unitario_grande = cos(3.0)^2 + sin(3.0)^2
#: The engine returns **1** in both (up to round-off). It does not matter whether the step is 0.6 rad or 3 rad (≈172°): the director lands **exactly** on the sphere. There, with no singularity (Remark 4.2), is the reason for the whole paper.

## 4 · The geodesic, drawn
#: While rolling, the director's two components —the one pointing along **t** and the one pointing along **Δt**— **trade places** while keeping cos²+sin²=1. It is exactly a cosine and a sine running around the circle:
#fplot(cos(x), sin(x), [0 6.283])
#: Each point (cos θ, sin θ) is at distance 1 from the center. That **is** the sphere seen edge-on: the director never leaves the unit radius.

## 5 · The associated rotation: Rodrigues (SO(3))
#: Rolling the director is equivalent to applying a **rotation ΔΛ** to it, with axis **t × Δt**. Formula (2.9) is the classical **Rodrigues** one:
#|  ΔΛ  =  cos(θ)·1  +  ( sin(θ) / θ )·[t×Δt]  +  ( (1−cos θ) / θ² )·(t×Δt)⊗(t×Δt)
#: and the nodal rotation matrix is **accumulated** product by product:  Λ_new = ΔΛ · Λ.
#: This is an **implicit 2-DOF** system (Remark 4.3): the third rotation —the spin about the director itself— is **tied down**, it is not free. Keep this in mind for §9.

## 6 · Why it rolls up into a perfect circle (roll-up)
#: Classic test (§6.1.1): flat cantilever beam, moment at the tip. The theory says it curves with radius ρ given by  1/ρ = M/(E·I). Data from the paper:
E_viga = 12·10^6
w = 1
t_k = 0.1
L = 10
I_viga = w·t_k^3/12
EI_viga = E_viga·I_viga
#: The moment that gives the **full turn** is M = 2π·EI/L. I use 2π as a number (τ):
τ = 6.2831853
M_rot = τ·EI_viga/L
#: The radius it rolls up with and its **perimeter**:
ρ = EI_viga/M_rot
perimetro = τ·ρ
#: The engine gives **perimeter = 10 = L**: the beam of length {L} rolls up **exactly once**, in **a single load step**, with 25 elements. No angle-based formulation survives that without jamming.

## 7 · The element: 4-node QUAD, mixed formulation
### (a) The three fields and their common template
#: The bilinear QUAD splits the energy into three pieces —**membrane**, **shear**, **bending**— and each one follows the **same recipe** (Appendix C):  strain ε → stress σ = ℂ·ε → material stiffness Km = BᵀℂB → geometric stiffness Kg → residual R.
### (b) The bending constitutive law, with numbers
#: The bending stiffness (eq. 2.37) for E=12·10⁶, ν=0.3, t=0.1. The engine computes it (name D_b so it does not clash with the engine's D):
D_b = E_viga·t_k^3/(12·(1-0.3^2))
C_b = D_b·[1 0.3 0; 0.3 1 0; 0 0 0.35]
#: The factor 1/(1−ν²) is the stiffening from **plane stress** —the same D₀ we already used in plates.
### (c) The anti-locking trick: assumed shear (MITC4)
#: A naive QUAD **locks** in shear (it comes out infinitely stiff as it gets thinner). Simo avoids this by evaluating the shear **not at the Gauss points** but at the **midpoints of the sides** A,B,C,D (eq. A.6–A.7). It is the **Bathe–Dvorkin / MITC4** method —the same pattern you isolated in the ETABS Q4.
### (d) The element stiffness: a DOUBLE integral
#: With the constitutive matrix ℂ (the C_b above) and the matrix **B** —which links strain to nodal displacements— the element stiffness is a **double integral** over the natural square ξ,η ∈ [−1,1]:
#|  K_e  =  ∫₋₁¹ ∫₋₁¹  Bᵀ · ℂ · B · det J  dξ dη
#: That integral is **not solved by hand**: it is approximated by **Gauss quadrature** —evaluating the integrand at a few points and summing with weights. For the bilinear QUAD **2×2** is enough (four points), at ξ,η = ±1/√3, all with weight 1. It is the same Gauss as in §7c.
pg = 1/sqrt(3)
#: I test it with a scalar term of the BᵀℂB type —a degree-2 polynomial, f = ξ²+η², whose exact double integral over [−1,1]² is 8/3—. I sum Gauss at the 4 points (±1/√3, ±1/√3):
K_gauss = (pg^2 + pg^2) + (pg^2 + pg^2) + (pg^2 + pg^2) + (pg^2 + pg^2)
#: The engine gives **8/3 = 2.6667**, exactly the exact value: 2×2 Gauss integrates without error up to degree 3, and BᵀℂB of a bilinear QUAD falls right in that range. This is how **each of the 12×12 entries** of K_e —the matrix of the next step— is assembled, Gauss point by Gauss point.
### (e) The element matrices are large → automatic collapse
#: The constitutive matrix C_b is 3×3 (small). But the **element stiffness** K_e is **12×12** (4 nodes × 3 DOF). When a matrix goes beyond 9 columns or 11 rows —or a vector beyond 9— Hekatan LISP puts the **indices on the edges** and **collapses the center** with … ⋮ ⋱ (like NumPy/MATLAB). Demonstration with the 12×12 identity (which K_e·K_e⁻¹ converges to) and a vector of 15:
Id = [1 0 0 0 0 0 0 0 0 0 0 0; 0 1 0 0 0 0 0 0 0 0 0 0; 0 0 1 0 0 0 0 0 0 0 0 0; 0 0 0 1 0 0 0 0 0 0 0 0; 0 0 0 0 1 0 0 0 0 0 0 0; 0 0 0 0 0 1 0 0 0 0 0 0; 0 0 0 0 0 0 1 0 0 0 0 0; 0 0 0 0 0 0 0 1 0 0 0 0; 0 0 0 0 0 0 0 0 1 0 0 0; 0 0 0 0 0 0 0 0 0 1 0 0; 0 0 0 0 0 0 0 0 0 0 1 0; 0 0 0 0 0 0 0 0 0 0 0 1]
gdl = 1:15

## 8 · The exact tangent and why it matters
#: Newton needs the derivative of the residual: the **tangent operator**. Simo gives it in **exact closed form** (§5), split into material + geometric. The reward is **quadratic convergence**: the error is squared at each step. Table 6.4.1 of the paper, as is:
#: iteration 0 → residual 1.4·10⁰ · iteration 3 → 5.0·10⁻³ · iteration 5 → **2.7·10⁻¹¹**.
#: Five steps and it is already at machine zero. With an approximate tangent that does **not** happen —and worse: **buckling** comes out wrong (Remark 5.2). Buckling is detected when the pivot of the K_T factorization **changes sign** (becomes singular).

## 9 · How it fits your work (ETABS / drilling)
#: **(1)** It is the **Taylor–Simo** line we already identified behind the CSI shell. The **MITC4** of §7c is the same assumed-strain as the ETABS Q4.
#: **(2)** This element has **5 DOF** per node (3 of φ + 2 of the director). The **drilling** you isolated (k₀=0.4·G) is exactly the **6th** that is missing here —Remark 4.3 says so: *"the 3-DOF rotational system is treated in another paper"*. This is the previous step.
#: **(3)** The **exponential map on S²/SO(3)** of §3 is the tool you will need to take your shell to **nonlinear** (large rotations), which linear ETABS does not do.

## 10 · Minimal glossary
#: **director** (t): the unit normal of the shell. **S²**: the sphere of radius 1, where the director lives. **SO(3)**: the group of 3D rotations. **exponential map**: rolling along the geodesic without leaving the sphere. **geometrically exact**: valid for rotations of any size, with no approximation. **MITC4**: shear evaluated at the side midpoints (anti-locking). **consistent tangent**: the exact derivative of the residual → quadratic Newton. **bifurcation**: where K_T becomes singular (buckling).
#> Simo · Fox · Rifai (1990), Parte III · Stanford · continúa la Parte I (formulación) y II (lineal).
