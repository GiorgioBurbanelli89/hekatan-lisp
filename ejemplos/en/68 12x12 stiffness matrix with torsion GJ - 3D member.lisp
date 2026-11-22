# Complete stiffness matrix of a 3D member, with the torsion G·J

#: In the plane a member has 6 degrees of freedom. In space it has **12**: at each end it translates in x, y, z and rotates about x, y, z. The rotation about its own axis (θx) is the **torsion**, and it is what the plane did not have.

## 1 · The order of the degrees of freedom

#: Rows and columns go like this (node i, then node j):
#: **0** u_{i} · **1** v_{i} · **2** w_{i} · **3** θx_{i} · **4** θy_{i} · **5** θz_{i} · **6** u_{j} · **7** v_{j} · **8** w_{j} · **9** θx_{j} · **10** θy_{j} · **11** θz_{j}
#: · u = axial · v, w = transverse displacements · θx = torsion · θy, θz = bending rotations.

## 2 · The torsion is derived just like the axial

#: The rotation θx varies **linearly** along the member, just like the elongation. Its shape functions are straight lines:
N_1 = 1 - x/L
N_2 = x/L
#: I differentiate (the engine) to get the torsion **B**, the rotation per unit length:
dN1 = Diff{1 - x/L @ x} @@(dN₁/dx)
dN2 = Diff{x/L @ x} @@(dN₂/dx)
#: So B = [−1/L, 1/L] and the stiffness is the usual integral, with **G·J** instead of E·A:
#: K_{t} = ∫_{0}^{L} B^{T}·G·J·B dx = (G·J/L)·[1, −1; −1, 1]
k_t = G*J/L
#: With L = 1, the engine integrates the (1,1) term and gives 1 → it leaves **G·J/L**:
k11_t = Area{(-1)*(-1) @ x=0:1} @@(B₁·B₁ con L=1)

## 3 · The four blocks of the matrix

#: Inside the 12×12 there are **four physics**, and none mixes with the others in a straight member:

#: · **axial** (u_{i}, u_{j}): E·A/L
#: · **torsion** (θx_{i}, θx_{j}): **G·J/L**
#: · **bending in the x-y plane** (v, θz): 12·E·I_{z}/L³ · 6·E·I_{z}/L² · 4·E·I_{z}/L · 2·E·I_{z}/L
#: · **bending in the x-z plane** (w, θy): 12·E·I_{y}/L³ · 6·E·I_{y}/L² · 4·E·I_{y}/L · 2·E·I_{y}/L

#: The bending in x-z carries the **6·E·I_{y}/L² with a minus sign**: a positive θy rotation lowers the end (right-hand rule).

## 4 · The complete matrix, in symbols

K_12 = [E*A/L, 0, 0, 0, 0, 0, -E*A/L, 0, 0, 0, 0, 0; 0, 12*E*I_z/L^3, 0, 0, 0, 6*E*I_z/L^2, 0, -12*E*I_z/L^3, 0, 0, 0, 6*E*I_z/L^2; 0, 0, 12*E*I_y/L^3, 0, -6*E*I_y/L^2, 0, 0, 0, -12*E*I_y/L^3, 0, -6*E*I_y/L^2, 0; 0, 0, 0, G*J/L, 0, 0, 0, 0, 0, -G*J/L, 0, 0; 0, 0, -6*E*I_y/L^2, 0, 4*E*I_y/L, 0, 0, 0, 6*E*I_y/L^2, 0, 2*E*I_y/L, 0; 0, 6*E*I_z/L^2, 0, 0, 0, 4*E*I_z/L, 0, -6*E*I_z/L^2, 0, 0, 0, 2*E*I_z/L; -E*A/L, 0, 0, 0, 0, 0, E*A/L, 0, 0, 0, 0, 0; 0, -12*E*I_z/L^3, 0, 0, 0, -6*E*I_z/L^2, 0, 12*E*I_z/L^3, 0, 0, 0, -6*E*I_z/L^2; 0, 0, -12*E*I_y/L^3, 0, 6*E*I_y/L^2, 0, 0, 0, 12*E*I_y/L^3, 0, 6*E*I_y/L^2, 0; 0, 0, 0, -G*J/L, 0, 0, 0, 0, 0, G*J/L, 0, 0; 0, 0, -6*E*I_y/L^2, 0, 2*E*I_y/L, 0, 0, 0, 6*E*I_y/L^2, 0, 4*E*I_y/L, 0; 0, 6*E*I_z/L^2, 0, 0, 0, 2*E*I_z/L, 0, -6*E*I_z/L^2, 0, 0, 0, 4*E*I_z/L]

#: Rows 3 and 9 (θx of i and of j) are the torsion: **they have only G·J/L**, no bending or axial.

## 5 · J is not the polar inertia

#: In a circular section J = I_{y} + I_{z}. In a **rectangular** one it is **not**: the section warps and J is much smaller. Saint-Venant (Roark), with a = longer side, b = shorter side, r = b/a:
#: J = [1/3 − 0.21·r·(1 − r⁴/12)]·a·b³

## 6 · With numbers: the V30×50 beam of the torsion table

E_c = dec(24850000, 0) [kN/m²] 'concrete modulus ; ν = dec(0.2, 2) [—] 'Poisson's ratio ; L_v = dec(6, 1) [m] 'beam span
G_c = dec(24850000/2.4, 0) [kN/m²] 'shear modulus: E divided by 2·(1+ν)
A_v = dec(0.30*0.50, 4) [m²] 'area ; I_y = dec(0.30*0.50^3/12, 6) [m⁴] 'strong inertia ; I_z = dec(0.50*0.30^3/12, 6) [m⁴] 'weak inertia
r_v = dec(0.30/0.50, 2) [—] 'b/a
J_v = dec((1/3 - 0.21*0.6*(1 - 0.6^4/12))*0.50*0.30^3, 7) [m⁴] 'Saint-Venant torsion
J_polar = dec(0.003125 + 0.001125, 6) [m⁴] 'what Iy + Iz would give (WRONG for a rectangle)
#: The Saint-Venant J is {J_v} m⁴; the polar one would give {J_polar} m⁴. Using the polar **overestimates the torsion by 51 %**.

## 7 · The terms, with numbers

k_a = dec(24850000*0.15/6, 0) [kN/m] 'axial: E·A/L
k_t = dec(10354167*0.0028174/6, 0) [kN·m] 'torsion: G·J/L
k_vz = dec(12*24850000*0.001125/6^3, 0) [kN/m] '12·E·Iz/L³ ; k_mz = dec(6*24850000*0.001125/6^2, 0) [kN] '6·E·Iz/L² ; k_gz = dec(4*24850000*0.001125/6, 0) [kN·m] '4·E·Iz/L ; k_cz = dec(2*24850000*0.001125/6, 0) [kN·m] '2·E·Iz/L
k_vy = dec(12*24850000*0.003125/6^3, 0) [kN/m] '12·E·Iy/L³ ; k_my = dec(6*24850000*0.003125/6^2, 0) [kN] '6·E·Iy/L² ; k_gy = dec(4*24850000*0.003125/6, 0) [kN·m] '4·E·Iy/L ; k_cy = dec(2*24850000*0.003125/6, 0) [kN·m] '2·E·Iy/L

## 8 · The 12×12 matrix, with numbers

K_v = [621250, 0, 0, 0, 0, 0, -621250, 0, 0, 0, 0, 0; 0, 1553, 0, 0, 0, 4659, 0, -1553, 0, 0, 0, 4659; 0, 0, 4314, 0, -12943, 0, 0, 0, -4314, 0, -12943, 0; 0, 0, 0, 4862, 0, 0, 0, 0, 0, -4862, 0, 0; 0, 0, -12943, 0, 51771, 0, 0, 0, 12943, 0, 25885, 0; 0, 4659, 0, 0, 0, 18637, 0, -4659, 0, 0, 0, 9319; -621250, 0, 0, 0, 0, 0, 621250, 0, 0, 0, 0, 0; 0, -1553, 0, 0, 0, -4659, 0, 1553, 0, 0, 0, -4659; 0, 0, -4314, 0, 12943, 0, 0, 0, 4314, 0, 12943, 0; 0, 0, 0, -4862, 0, 0, 0, 0, 0, 4862, 0, 0; 0, 0, -12943, 0, 25885, 0, 0, 0, 12943, 0, 51771, 0; 0, 4659, 0, 0, 0, 9319, 0, -4659, 0, 0, 0, 18637]

#: The viewer truncates a 12-column matrix with `⋯`. To see **all** the terms, the same matrix in its four 6×6 blocks (rows and columns 0-5 = node i, 6-11 = node j):
K_ii = [621250, 0, 0, 0, 0, 0; 0, 1553, 0, 0, 0, 4659; 0, 0, 4314, 0, -12943, 0; 0, 0, 0, 4862, 0, 0; 0, 0, -12943, 0, 51771, 0; 0, 4659, 0, 0, 0, 18637] @@(nudo i con nudo i)
K_ij = [-621250, 0, 0, 0, 0, 0; 0, -1553, 0, 0, 0, 4659; 0, 0, -4314, 0, -12943, 0; 0, 0, 0, -4862, 0, 0; 0, 0, 12943, 0, 25885, 0; 0, -4659, 0, 0, 0, 9319] @@(nudo i con nudo j)
K_jj = [621250, 0, 0, 0, 0, 0; 0, 1553, 0, 0, 0, -4659; 0, 0, 4314, 0, 12943, 0; 0, 0, 0, 4862, 0, 0; 0, 0, 12943, 0, 51771, 0; 0, -4659, 0, 0, 0, 18637] @@(nudo j con nudo j)
#: And the missing block is the transpose: K_{ji} = K_{ij}^{T}. The **4862** on the diagonal (row 3) and the **−4862** of the cross block are the torsion.

#: Three checks that can be seen at a glance:
#: · It is **symmetric** (Betti).
#: · In each row, the **displacement** columns (u, v, w of i and of j) add up to zero: if the member translates as a whole, no force appears.
#: · It has **6 zero eigenvalues** = the 6 rigid-body motions (3 translations + 3 rotations). A member without supports has no stiffness against them.

## 9 · Why torsion is "the weak one"

razon_y = dec(51771/4862, 1) [—] 'rotating in strong bending vs twisting
razon_z = dec(18637/4862, 1) [—] 'rotating in weak bending vs twisting
#: Twisting the beam costs {razon_y} times less than rotating it in its strong plane. That is why, when the slab rotates at the edge, the beam **twists** (in the torsion table: T = 1.17 tonf·m in the beams next to the columns) instead of taking the rotation with bending.

## 10 · The same element in OpenSees

#: `model basic -ndm 3 -ndf 6`
#: `geomTransf Linear 1 0 0 1`
#: `element elasticBeamColumn 1 1 2 0.15 24850000 10354167 0.0028174 0.003125 0.001125 1`
#: The order is **A, E, G, J, I_{y}, I_{z}**. Extracted with `printA`, the OpenSees matrix is **identical term by term** to that of section 8 (621250, 1553, 4314, **4862**, 51771, 18637…).
