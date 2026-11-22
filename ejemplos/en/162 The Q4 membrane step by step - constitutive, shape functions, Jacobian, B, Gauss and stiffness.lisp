# The finite element membrane step by step: from the data to the stiffness matrix
#numerico
#: **4-node quadrilateral (Q4) element in plane stress**, the simplest of the membrane elements. It is done in the usual order: **data → constitutive matrix → shape functions → Jacobian → B matrix → Gauss quadrature → stiffness K → check**. It is the membrane **without drilling rotation**; the ITW adds the rotation to this same skeleton (see the ITW example).
#: **Idea in one sentence:** the stiffness is the strain energy of the element, **K = ∫ Bᵀ·D·B · t · dA**. B converts the node displacements into strains, D converts strains into stresses, and the integral adds up over the area.

## 1 · Data
E = 25000000 'modulus of elasticity
ν = 0.2 'Poisson's ratio
t = 0.2 'thickness
#: A **non-rectangular** quadrilateral (trapezoid), so that the Jacobian is worthwhile. Nodes counterclockwise, coordinates (x, y) in m, one row per node:
Xn = [0, 0; 4, 0; 3.5, 2; 0.5, 2]
#: The element has 4 nodes and 2 displacements per node (u, v), that is, **8 degrees of freedom**, in the order [u_1, v_1, u_2, v_2, u_3, v_3, u_4, v_4].

## 2 · Constitutive matrix D (plane stress)
#: It relates the stresses [σ_{x}, σ_{y}, τ_{xy}] to the strains [ε_{x}, ε_{y}, γ_{xy}]. **Plane stress** because the membrane is thin: the stress perpendicular to the plane is zero.
Db = E/(1 - ν^2)·[1, ν, 0; ν, 1, 0; 0, 0, (1 - ν)/2]
G_c = E/(2·(1 + ν)) 'shear modulus, to check the term Db(3,3)
Dbc = Db(3, 3) 'must be G_c

## 3 · Shape functions of the natural square
#: We work in the natural square, **ξ and η from −1 to 1**, where all elements are equal. Each function equals **1 at its node and 0 at the other three**:
N_1 = Expand{(1-xi)*(1-eta)/4}
N_2 = Expand{(1+xi)*(1-eta)/4}
N_3 = Expand{(1+xi)*(1+eta)/4}
N_4 = Expand{(1-xi)*(1+eta)/4}
#: **Partition of unity**: they add up to 1 over the whole element. Otherwise it does not reproduce rigid-body motion.
particion = Simplify{(1-xi)*(1-eta)/4 + (1+xi)*(1-eta)/4 + (1+xi)*(1+eta)/4 + (1-xi)*(1+eta)/4}
#: **Derivatives with respect to ξ and η**, one column per node (row 1 = ∂N/∂ξ, row 2 = ∂N/∂η):
dN_q(xi, eta) = 0.25*[-(1-eta), (1-eta), (1+eta), -(1+eta); -(1-xi), -(1+xi), (1+xi), (1-xi)]

## 4 · Jacobian: from the natural square to the real element
#: The geometry is interpolated with **the same shape functions** (that is why it is called isoparametric): x = ΣN_{i}·x_{i}. The Jacobian is the derivative of (x, y) with respect to (ξ, η):
J_q(xi, eta) = dN_q(xi, eta)*Xn
#: **detJ is the area factor**: dx·dy = detJ·dξ·dη. Its sign must be positive (counterclockwise nodes); if it comes out zero or negative, the element is badly numbered or degenerate.
dJ_q(xi, eta) = det(J_q(xi, eta))
#: A concrete point to see the numbers: the Gauss point (+1/√3, +1/√3).
g = 1/sqrt(3) 'coordinate of the Gauss point
J_g = J_q(g, g)
detJ_g = dJ_q(g, g) 'real area per unit natural area at that point
#: The derivatives with respect to **x and y** (the ones the strain needs) come from the inverse of the Jacobian: [∂N/∂x; ∂N/∂y] = J⁻¹·[∂N/∂ξ; ∂N/∂η]. One row for ∂N/∂x and another for ∂N/∂y, one column per node:
gx_q(xi, eta) = [1, 0]*inv(J_q(xi, eta))*dN_q(xi, eta)
gy_q(xi, eta) = [0, 1]*inv(J_q(xi, eta))*dN_q(xi, eta)
dNdx_g = gx_q(g, g)
dNdy_g = gy_q(g, g)

## 5 · B matrix (strain = B · displacements)
#: ε_{x} = ∂u/∂x, ε_{y} = ∂v/∂y, γ_{xy} = ∂u/∂y + ∂v/∂x. With u = ΣN_{i}·u_{i} and v = ΣN_{i}·v_{i}, each strain is a **linear combination of the 8 displacements**. The matrices E_{u} and E_{v} only place each node in its position (u in positions 1, 3, 5, 7; v in 2, 4, 6, 8):
E_u = [1, 0, 0, 0, 0, 0, 0, 0; 0, 0, 1, 0, 0, 0, 0, 0; 0, 0, 0, 0, 1, 0, 0, 0; 0, 0, 0, 0, 0, 0, 1, 0]
E_v = [0, 1, 0, 0, 0, 0, 0, 0; 0, 0, 0, 1, 0, 0, 0, 0; 0, 0, 0, 0, 0, 1, 0, 0; 0, 0, 0, 0, 0, 0, 0, 1]
#: Each row of B is a strain: **B_{x}** gives ε_{x}, **B_{y}** gives ε_{y}, **B_{g}** gives γ_{xy}. Stacked one below the other they form the 3 × 8 matrix B (here they are kept separate), and with them the product Bᵀ·D·B is written by adding the terms of D:
Bx_q(xi, eta) = gx_q(xi, eta)*E_u
By_q(xi, eta) = gy_q(xi, eta)*E_v
Bg_q(xi, eta) = gy_q(xi, eta)*E_u + gx_q(xi, eta)*E_v
Bxp = Bx_q(g, g) 'row of ε_x
Byp = By_q(g, g) 'row of ε_y
Bgp = Bg_q(g, g) 'row of γ_xy

## 6 · Gauss quadrature and stiffness K
#: The integral **K = ∫∫ Bᵀ·D·B · t · detJ dξ dη** is replaced by a sum at **4 points (2 × 2)**, ξ = ±1/√3, η = ±1/√3, with weight 1 each. It is exact for polynomials up to degree 3 in each direction.
#: Contribution of **one** Gauss point, 8 × 8 (what that sample of the integral is worth):
k_q(xi, eta) = t*dJ_q(xi, eta)*(Db(1, 1)*transpose(Bx_q(xi, eta))*Bx_q(xi, eta) + Db(1, 2)*(transpose(Bx_q(xi, eta))*By_q(xi, eta) + transpose(By_q(xi, eta))*Bx_q(xi, eta)) + Db(2, 2)*transpose(By_q(xi, eta))*By_q(xi, eta) + Db(3, 3)*transpose(Bg_q(xi, eta))*Bg_q(xi, eta))
k_g = k_q(g, g)
#: **Element stiffness = sum of the 4 points:**
K = k_q(-g, -g) + k_q(g, -g) + k_q(g, g) + k_q(-g, g)
Kuu = K(1, 1) 'stiffness of the dof u_{1}
Kuv = K(1, 2) 'coupling u_{1} with v_{1}

## 7 · Checks (if they fail, there is a sign or ordering error)
#: **a) The area.** The sum of detJ at the 4 points must be the trapezoid area, (4 + 3)/2 · 2 = 7 m²:
A_gauss = dJ_q(-g, -g) + dJ_q(g, -g) + dJ_q(g, g) + dJ_q(-g, g)
#: **b) Rigid-body motion.** If all nodes translate 1 in x, there is no strain and **the forces must be zero**:
u_tras = [1; 0; 1; 0; 1; 0; 1; 0]
f_tras = K*u_tras
n_tras = norm(f_tras) 'must be ≈ 0 (numerical noise)
#: **c) Constant strain patch test.** u = 0.001·x at all nodes (ε_{x} = 0.001, the rest zero). The element must reproduce the exact energy U = ½·σ_{x}·ε_{x}·t·A with σ_{x} = D(1,1)·ε_{x}:
u_x = [0; 0; 0.004; 0; 0.0035; 0; 0.0005; 0]
U_fem = 0.5*transpose(u_x)*K*u_x 'energy with the computed K
U_exacta = 0.5*Db(1, 1)*0.001*0.001*t*7 'energy of the constant strain
#: **d) Constant shear.** u = 0.001·y (γ_{xy} = 0.001): exact energy ½·G·γ²·t·A.
u_c = [0; 0; 0; 0; 0.002; 0; 0.002; 0]
U_c = 0.5*transpose(u_c)*K*u_c
U_ec = 0.5*G_c*0.001*0.001*t*7

## 8 · Reading
#: The four numbers match: the element represents **rigid translation, constant strain and constant shear**, which is what the patch test demands. K is a symmetric 8 × 8 with 3 zero-energy modes (two translations and one rigid-body rotation).
#: **What this element lacks:** there is no rotation about the normal (drilling), so it cannot be joined to a plate inside a shell without adding one. The **ITW** element of Ibrahimbegović, Taylor and Wilson keeps this skeleton (D, Jacobian, B, Gauss) and adds an interpolation with rotation and an internal bubble.
