# Curved shed: from the stiffness matrix of its members to the modes
#: **What this sheet explains.** The curved shed of Hekatan Struct (span 20 m, 6 frames, CFT columns, trusses in both directions) has **443 members** and **214 nodes**: **1284 degrees of freedom** (6 per node). All its response (deflections, reactions, modes) comes from **a single equation, K·u = F**. Here you see **where that K comes from**: one member is built, rotated, added to the others and we arrive at the periods that are animated in example 147.
#: **Order:** 1) the stiffness of ONE member in symbols; 2) the numbers of a shed column; 3) how it is rotated to the global axes; 4) how two members are added (assembly) and checked against the usual formula; 5) from K to the mode: **K·φ = ω²·M·φ**.
#: **Units:** kN and m. The column data are those of the shed model (CFT tube 250 × 250 × 8, steel E = 2·10⁸ kN/m², 6 m long).

## 1 · The stiffness of a member, in symbols

#: A frame member has 2 nodes and 6 motions per node (u, v, w, θx, θy, θz): its stiffness matrix is **12 × 12**. It is not a single formula: it is **four physics that do not mix**, each with its own way of interpolating the motion along the member (s = x/L, from 0 to 1).
#: **Axial** and **torsion**: the motion varies linearly, N = [1 − s, s]. The stiffness is the strain energy, k = EA·∫ B′ᵀ·B′ dx:
k_ax = Simplify{E*A/L*Area{transpose([Partial{1-s @ s}, Partial{s @ s}])*[Partial{1-s @ s}, Partial{s @ s}] @ s = 0 : 1}}
#: It is the usual spring, **EA/L**: if the member is stretched by 1, that force is needed. In torsion it is the same with **GJ/L** instead of EA/L:
k_tor = Simplify{G*J/L*Area{transpose([Partial{1-s @ s}, Partial{s @ s}])*[Partial{1-s @ s}, Partial{s @ s}] @ s = 0 : 1}}
#: **Bending**: the member bends as a cubic; its four shapes (displacement and rotation at each end) are the Hermite cubics. The curvature is the second derivative and the stiffness is the bending energy, k = EI·∫ Bᵀ·B dx:
B_fl = Simplify{[Partial{Partial{1-3*s^2+2*s^3 @ s} @ s}, Partial{Partial{L*(s-2*s^2+s^3) @ s} @ s}, Partial{Partial{3*s^2-2*s^3 @ s} @ s}, Partial{Partial{L*(s^3-s^2) @ s} @ s}]}
k_EB = Simplify{E*I/L^3*Area{transpose(B_fl)*B_fl @ s = 0 : 1}}
#: The diagonal is 12EI/L³ (how much force it takes to move one end by 1 without rotating it) and 4EI/L (how much moment it takes to rotate it by 1). **Timoshenko** adds the shear deformation with the parameter φ = 12·EI/(G·A_s·L²), which makes the member slightly softer when it is short and thick (A_s = 5/6·A):
φ_s = Simplify{12*E*I/(G*A_s*L^2)}
k_Ti = Simplify{E*I/(L^3*(1+phi))*[12, 6*L, -12, 6*L; 6*L, (4+phi)*L^2, -6*L, (2-phi)*L^2; -12, -6*L, 12, -6*L; 6*L, (2-phi)*L^2, -6*L, (4+phi)*L^2]}
#: The 12 rows and columns are built by placing each block in its degrees of freedom: k_{ax} at (u₁, u₂), k_{tor} at (θx₁, θx₂), bending with I_{z} at (v, θz) and with I_{y} at (w, θy) (in this last plane the cross terms change sign because θy = −∂w/∂x). Everything else is zero: **a member does not couple** stretching with bending.

## 2 · The numbers of a shed column

#: First column of the model: CFT tube 250 × 250 × 8 of 6 m, fixed at the bottom. Its data (from `frame 1` of the Hekatan Struct model): E = 2·10⁸ kN/m², A = 0.007744 m², I = 7.5669·10⁻⁵ m⁴, J = 1.1338·10⁻⁴ m⁴, ν = 0.3 and L = 6 m. The concrete infill of the CFT adds stiffness that this sheet leaves out to see the essentials: the steel alone.
#numerico
E_s = 200000000 'modulus of elasticity of steel (kN/m²)
nu_s = 0.3 'Poisson's ratio
G_s = E_s/(2*(1+nu_s)) 'shear modulus (kN/m²)
A_c = 0.007744 'section area (m²)
I_c = 0.000075669205 'bending inertia (m⁴)
J_c = 0.0001133799 'torsion constant (m⁴)
L_c = 6 'column length (m)
#: The diagonal terms, evaluated with those data. **Axial**: how much axial force it takes to shorten the column by 1 m (kN/m). **Torsion**: moment per radian (kN·m). **Bending**: force to displace the end by 1 m without rotating it (kN/m) and moment to rotate it by 1 rad (kN·m):
kax_c = E_s*A_c/L_c 'EA/L (kN/m)
ktor_c = G_s*J_c/L_c 'GJ/L (kN·m/rad)
kv_c = 12*E_s*I_c/L_c^3 '12EI/L³ (kN/m)
kth_c = 4*E_s*I_c/L_c '4EI/L (kN·m/rad)
#: The column is **much stiffer axially than in bending**: EA/L is about 300 times 12EI/L³. That is why almost all the movement of the shed is bending, and the roof yields through the frames, not by the columns shortening.
rel_ax = kax_c/kv_c 'how many times stiffer axially than in bending

## 3 · From the member axes to the model axes

#: The matrices above are in the member's **local axes** (x along it). The model lives in global axes (X, Y, Z), so each member is rotated with its **direction cosines**: K_{global} = Tᵀ·k·T, where T repeats the 3 × 3 rotation matrix 4 times on the diagonal. For a vertical column, local x = global Z:
λ_c = Simplify{[0, 0, 1; 0, 1, 0; -1, 0, 0]}
#: In an inclined truss member (chord or diagonal) with ends (x₁, y₁, z₁) and (x₂, y₂, z₂), the first axis is the unit vector of the member, **e₁ = (P₂ − P₁)/L**, and the other two come from orthogonalising it with the vertical. **It is the only thing that changes among the 443 members**: their section data and their orientation.

## 4 · Two members in series: the assembly

#: A shared node receives the stiffness of **all the members that arrive at it**: they are **added** in the same degree of freedom. To see it without 1284 rows, the column is taken split into two equal members of length L (in the bending plane, 2 motions per node: displacement and rotation). The global matrix is 6 × 6; that of the lower member occupies nodes 1-2 and that of the upper one nodes 2-3, and they **overlap at node 2**:
k_b = Simplify{E*I/L^3*[12, 6*L, -12, 6*L; 6*L, 4*L^2, -6*L, 2*L^2; -12, -6*L, 12, -6*L; 6*L, 2*L^2, -6*L, 4*L^2]}
K_6 = Simplify{E*I/L^3*[12, 6*L, -12, 6*L, 0, 0; 6*L, 4*L^2, -6*L, 2*L^2, 0, 0; -12, -6*L, 24, 0, -12, 6*L; 6*L, 2*L^2, 0, 8*L^2, -6*L, 2*L^2; 0, 0, -12, -6*L, 12, -6*L; 0, 0, 6*L, 2*L^2, -6*L, 4*L^2]}
#: Look at the centre: 12 + 12 = **24** and 4L² + 4L² = **8L²**. They are the two members added at node 2. Node 1 is the fixed support (u = θ = 0): **its two rows and columns are eliminated** and a 4 × 4 system in (u₂, θ₂, u₃, θ₃) remains:
K_4 = Simplify{E*I/L^3*[24, 0, -12, 6*L; 0, 8*L^2, -6*L, 2*L^2; -12, -6*L, 12, -6*L; 6*L, 2*L^2, -6*L, 4*L^2]}
#: A lateral force P is applied at the free end (node 3) and **K·u = F** is solved. The end deflection must give the strength-of-materials formula for a cantilever of length 2L, P·(2L)³/(3EI) = 8·P·L³/(3·E·I):
u_4 = Simplify{inv(K_4)*[0; 0; P; 0]}
#: The third value is u₃, the tip deflection. **It coincides exactly with 8PL³/(3EI)**: the stiffness matrix reproduces beam theory, and with two cubic elements it is exact (the solution is a cubic). In the shed the procedure is identical, only the vector has 1284 rows.
u_ref = Simplify{8*P*L^3/(3*E*I)}

## 5 · From K to the vibration mode

#: With no external forces, the equation of motion is **M·ü + K·u = 0**. Trying u = φ·cos(ω·t) leaves the **eigenvalue problem**: **K·φ = ω²·M·φ**. There is a nonzero solution only when det(K − ω²·M) = 0: that polynomial (of degree 1284 in the shed) has one root per mode. From ω the period comes out, T = 2π/ω.
#: With the column above, fixed and with a mass m at the tip, there is a single degree of freedom and the lateral stiffness is that of a cantilever, 3EI/L³. The period is **T = 2π·√(m/k)**:
k_lat = 3*E_s*I_c/L_c^3 'lateral stiffness of the cantilever column (kN/m)
m_p = 20 'mass at the tip, example (t = kN·s²/m)
T_c = 2*pi*sqrt(m_p/k_lat) 'period of that column with its mass (s)
#: The complete shed has thousands of degrees of freedom and distributed masses, but **the principle is the same**: each mode is an equivalent mass on an equivalent spring. Hekatan Struct and Hekatan OpenSees build the K of the 443 members and the M of the masses, solve the eigenvalue problem and give T₁ = 0.3309 s, T₂ = 0.3237 s and T₃ = 0.2786 s: **the periods that are animated in example 147**.
#: **Where to go next:** the matrix of the zinc roof (membrane + bending shell, 24 × 24 per sheet) is derived in example 83; the stiffness and mass of a member up to the modal analysis and the participating mass, in 149; the rigid offsets of SAP2000 and ETABS at the joints, in 111.
