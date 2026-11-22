# Mesh convergence of the supported slab against Navier
#numerico

#: The same square supported slab with uniform load, solved with the BFS element on 2 × 2, 4 × 4, 8 × 8 and 16 × 16 meshes. The question: how close does the mesh get to the EXACT Navier solution when refined? The whole chain (mesh, stiffness, assembly, supports, Cholesky, moments) goes inside ONE loop, one pass per mesh.
#: **Units** (Calcpad's): E in MPa and q in kN/m² → Z in **mm**; moments in **kN·m/m**.

## 1 · Data
a = 4 [m] 'side in x
b = 4 [m] 'side in y
t = 0.12 [m] 'thickness
q = 10 [kN/m²] 'distributed load
E = 35000 [MPa] 'modulus of elasticity
ν = 0.3 'Poisson's ratio (the one in the Timoshenko tables)
D_p = E·t^3/(12·(1 - ν^2)) [MN·m] 'flexural rigidity of the plate

## 2 · Exact solution (Navier)
#: Plate supported on its 4 edges with uniform load: w = α·q·a⁴/D and Mx = β·q·a² at the center. Timoshenko & Woinowsky-Krieger, *Theory of Plates and Shells*, 2nd ed., Table 8 (p. 120), b/a = 1, ν = 0.3: α = 0.00406, β = 0.0479. The table gives 3 figures; the same Navier series summed with more terms (separate program, tests/placas_bfs/navier_levy.py, 400 × 400 terms) gives α = 0.00406235 and β = 0.0478864, which are the ones used to measure the error.
α_T = 0.00406 'Table 8
β_T = 0.0479 'Table 8
α_N = 0.00406235 'Navier series
β_N = 0.0478864 'Navier series
w_N = α_N·q·a^4/D_p [mm] 'exact deflection at the center
M_N = β_N·q·a^2 [kNm/m] 'exact moment at the center

## 3 · BFS element (Bogner–Fox–Schmit)
#: Rectangle of a₁ × b₁ with 4 degrees of freedom per node: deflection w, rotations θx = ∂w/∂x and θy = ∂w/∂y, and twist ψ = ∂²w/∂x∂y. It is the same element as example 71 (verified against Calcpad on 849 values).
#: **Basis functions**: Hermite cubic polynomials in ξ = x/a₁ ∈ [0, 1]. Φ₁ and Φ₃ give the deflection at each end; Φ₂ and Φ₄, the rotation. With cubics the deflection and its slope are continuous between elements (Kirchhoff plate).
Φ_1a(ξ) = 1 - ξ^2·(3 - 2·ξ)
Φ_2a(ξ) = ξ·a_1·(1 - ξ·(2 - ξ))
Φ_3a(ξ) = ξ^2·(3 - 2·ξ)
Φ_4a(ξ) = ξ^2·a_1·(-1 + ξ)
#: First derivatives with respect to x (the chain rule divides by a₁):
Φprime_1a(ξ) = -6·(ξ/a_1)·(1 - ξ)
Φprime_2a(ξ) = 1 - ξ·(4 - 3·ξ)
Φprime_3a(ξ) = 6·(ξ/a_1)·(1 - ξ)
Φprime_4a(ξ) = -ξ·(2 - 3·ξ)
#: Second derivatives (curvatures):
Φpprime_1a(ξ) = -(6/a_1^2)·(1 - 2·ξ)
Φpprime_2a(ξ) = -(2/a_1)·(2 - 3·ξ)
Φpprime_3a(ξ) = 6/a_1^2·(1 - 2·ξ)
Φpprime_4a(ξ) = -(2/a_1)·(1 - 3·ξ)
#: The same along b, in η = y/b₁:
Φ_1b(η) = 1 - η^2·(3 - 2·η)
Φ_2b(η) = η·b_1·(1 - η·(2 - η))
Φ_3b(η) = η^2·(3 - 2·η)
Φ_4b(η) = η^2·b_1·(-1 + η)
Φprime_1b(η) = -6·(η/b_1)·(1 - η)
Φprime_2b(η) = 1 - η·(4 - 3·η)
Φprime_3b(η) = 6·(η/b_1)·(1 - η)
Φprime_4b(η) = -η·(2 - 3·η)
Φpprime_1b(η) = -(6/b_1^2)·(1 - 2·η)
Φpprime_2b(η) = -(2/b_1)·(2 - 3·η)
Φpprime_3b(η) = 6/b_1^2·(1 - 2·η)
Φpprime_4b(η) = -(2/b_1)·(1 - 3·η)
#: **Shape functions**: the PRODUCT of a function in ξ by another in η, in the order of the degrees of freedom (w, θx, θy, ψ of nodes 1, 2, 3, 4):
N(ξ, η) = [Φ_1a(ξ)·Φ_1b(η), Φ_2a(ξ)·Φ_1b(η), Φ_1a(ξ)·Φ_2b(η), Φ_2a(ξ)·Φ_2b(η), Φ_3a(ξ)·Φ_1b(η), Φ_4a(ξ)·Φ_1b(η), Φ_3a(ξ)·Φ_2b(η), Φ_4a(ξ)·Φ_2b(η), Φ_3a(ξ)·Φ_3b(η), Φ_4a(ξ)·Φ_3b(η), Φ_3a(ξ)·Φ_4b(η), Φ_4a(ξ)·Φ_4b(η), Φ_1a(ξ)·Φ_3b(η), Φ_2a(ξ)·Φ_3b(η), Φ_1a(ξ)·Φ_4b(η), Φ_2a(ξ)·Φ_4b(η)]
#: **Constitutive matrix** (moments ↔ curvatures); its factor is the flexural rigidity D_p of the data:
D = D_p·[1, ν, 0; ν, 1, 0; 0, 0, (1 - ν)/2]
#: **B matrix**: its rows are the curvatures ∂²w/∂x², ∂²w/∂y² and 2·∂²w/∂x∂y of each shape function.
B_1(ξ, η) = [Φpprime_1a(ξ)·Φ_1b(η), Φpprime_2a(ξ)·Φ_1b(η), Φpprime_1a(ξ)·Φ_2b(η), Φpprime_2a(ξ)·Φ_2b(η), Φpprime_3a(ξ)·Φ_1b(η), Φpprime_4a(ξ)·Φ_1b(η), Φpprime_3a(ξ)·Φ_2b(η), Φpprime_4a(ξ)·Φ_2b(η), Φpprime_3a(ξ)·Φ_3b(η), Φpprime_4a(ξ)·Φ_3b(η), Φpprime_3a(ξ)·Φ_4b(η), Φpprime_4a(ξ)·Φ_4b(η), Φpprime_1a(ξ)·Φ_3b(η), Φpprime_2a(ξ)·Φ_3b(η), Φpprime_1a(ξ)·Φ_4b(η), Φpprime_2a(ξ)·Φ_4b(η)]
B_2(ξ, η) = [Φ_1a(ξ)·Φpprime_1b(η), Φ_2a(ξ)·Φpprime_1b(η), Φ_1a(ξ)·Φpprime_2b(η), Φ_2a(ξ)·Φpprime_2b(η), Φ_3a(ξ)·Φpprime_1b(η), Φ_4a(ξ)·Φpprime_1b(η), Φ_3a(ξ)·Φpprime_2b(η), Φ_4a(ξ)·Φpprime_2b(η), Φ_3a(ξ)·Φpprime_3b(η), Φ_4a(ξ)·Φpprime_3b(η), Φ_3a(ξ)·Φpprime_4b(η), Φ_4a(ξ)·Φpprime_4b(η), Φ_1a(ξ)·Φpprime_3b(η), Φ_2a(ξ)·Φpprime_3b(η), Φ_1a(ξ)·Φpprime_4b(η), Φ_2a(ξ)·Φpprime_4b(η)]
B_3(ξ, η) = 2·[Φprime_1a(ξ)·Φprime_1b(η), Φprime_2a(ξ)·Φprime_1b(η), Φprime_1a(ξ)·Φprime_2b(η), Φprime_2a(ξ)·Φprime_2b(η), Φprime_3a(ξ)·Φprime_1b(η), Φprime_4a(ξ)·Φprime_1b(η), Φprime_3a(ξ)·Φprime_2b(η), Φprime_4a(ξ)·Φprime_2b(η), Φprime_3a(ξ)·Φprime_3b(η), Φprime_4a(ξ)·Φprime_3b(η), Φprime_3a(ξ)·Φprime_4b(η), Φprime_4a(ξ)·Φprime_4b(η), Φprime_1a(ξ)·Φprime_3b(η), Φprime_2a(ξ)·Φprime_3b(η), Φprime_1a(ξ)·Φprime_4b(η), Φprime_2a(ξ)·Φprime_4b(η)]
B(ξ, η) = [B_1(ξ, η); B_2(ξ, η); B_3(ξ, η)]
#: **Element stiffness and load**: double integrals over the rectangle (dx·dy = a₁·b₁·dξ·dη), done with integral2 (Gauss-Legendre, exact for these polynomials).
#noc
K_e = a_1·b_1·Area{Area{transpose(B(ξ, η))·D·B(ξ, η) @ ξ = 0 : 1} @ η = 0 : 1}
F_e = a_1·b_1·Area{Area{N(ξ, η)·q @ ξ = 0 : 1} @ η = 0 : 1}
#equ
#: (Here they are only written: they are computed inside the loop, because a₁ and b₁ change with the mesh.)

## 4 · The mesh loop
#: On each pass: n × n mesh, element stiffness and load (they change with a₁ = a/n), assembly, edge supports (w and the rotation along the edge, as in example 71), Cholesky, and the deflection and the moment Mx of the central node. The moment is taken from the lower-left element of the center (M = −D·B·Z_{e} at its node 3); by symmetry the 4 elements meeting at the center give the same.
m_s = [2, 4, 8, 16] 'elements per side
n = 16 'degrees of freedom of the element
k_1 = n/4
#hide
w_s = zeros(4, 1)
M_s = zeros(4, 1)
d_s = zeros(4, 1)
d_j(j) = k_1·(j - 1) + (1:k_1)
d_e(e) = [d_j(e_j(e, 1)), d_j(e_j(e, 2)), d_j(e_j(e, 3)), d_j(e_j(e, 4))]
#show
for k_m = 1:4
  n_a = m_s(k_m)
  n_b = n_a
  a_1 = a/n_a
  b_1 = b/n_b
  n_e = n_a·n_b
  n_j = (n_a + 1)·(n_b + 1)
  n_d = k_1·n_j
  K_e = a_1·b_1·integral2(@(ξ, η) transpose(B(ξ, η))·D·B(ξ, η), 0, 1, 0, 1)
  F_e = a_1·b_1·q·integral2(@(ξ, η) N(ξ, η), 0, 1, 0, 1)
  e_j = zeros(n_e, 4)
  for i_a = 1:n_a
    for i_b = 1:n_b
      e = i_b + n_b·(i_a - 1)
      j = e + i_a - 1
      e_j(e, 1:4) = [j, j + n_b + 1, j + n_b + 2, j + 1]
    end
  end
  K = zeros(n_d, n_d)
  F = zeros(n_d, 1)
  for e = 1:n_e
    g = d_e(e)
    K(g, g) = K(g, g) + K_e
    F(g) = F(g) + F_e
  end
  for i_a = 1:n_a + 1
    for i_b = 1:n_b + 1
      j = k_1·((i_a - 1)·(n_b + 1) + i_b - 1)
      if i_b == 1 || i_b == n_b + 1
        K(j + 1, j + 1) = K(j + 1, j + 1) + 10^20
        K(j + 2, j + 2) = K(j + 2, j + 2) + 10^20
      end
      if i_a == 1 || i_a == n_a + 1
        K(j + 1, j + 1) = K(j + 1, j + 1) + 10^20
        K(j + 3, j + 3) = K(j + 3, j + 3) + 10^20
      end
    end
  end
  Z = clsolve(K, F)
  j_c = (n_a/2)·(n_b + 1) + n_b/2 + 1
  e_c = (n_a/2 - 1)·n_b + n_b/2
  M_e = -D·B(1, 1)·Z(d_e(e_c))
  w_s(k_m) = Z(k_1·(j_c - 1) + 1)
  M_s(k_m) = M_e(1)
  d_s(k_m) = n_d
end
#: At an edge node that is a corner two springs in w are added: it does not matter, w is already fixed.

## 5 · Results and verification
#: Convergence table. Columns: elements per side, degrees of freedom, central deflection [mm], its error against Navier [%], central Mx [kN·m/m] and its error [%]:
#hide
C = zeros(4, 6)
for k = 1:4
  C(k, 1:6) = [m_s(k), d_s(k), w_s(k), round((w_s(k) - w_N)/w_N·100, 4), M_s(k), round((M_s(k) - M_N)/M_N·100, 4)]
end
#show
C
#: The deflection converges very fast (with 4 × 4 it is already at 0.07 % of the exact one) and the moment more slowly (it comes from SECOND derivatives): +19 % with 2 × 2, +0.14 % with 16 × 16. Each time the mesh is doubled the moment error drops about 4 times (order h²).
#: **Another program, same mesh node by node:** Calcpad (*Rectangular Slab FEA* with this data, on the 4 meshes).
w_CP = [1.905605, 1.879084, 1.87779, 1.877715] [mm] 'Calcpad
M_CP = [9.152385, 7.874727, 7.705873, 7.672276] [kNm/m] 'Calcpad
dif_wCP = round(max(abs(w_s - w_CP)), 6) [mm] 'largest difference in w
dif_MCP = round(max(abs(M_s - M_CP)), 6) [kNm/m] 'largest difference in Mx
w_16 = w_s(4) [mm]
dif_w16 = round((w_16 - w_N)/w_N·100, 4) [%]
M_16 = M_s(4) [kNm/m]
dif_M16 = round((M_16 - M_N)/M_N·100, 4) [%]
w_T = α_T·q·a^4/D_p [mm] 'with the table coefficient (3 figures)
dif_wT = round((w_16 - w_T)/w_T·100, 4) [%]
M_T = β_T·q·a^2 [kNm/m]
dif_MT = round((M_16 - M_T)/M_T·100, 4) [%]
#| magnitud (malla 16 × 16) | referencia | referencia vale | Hekatan LISP | dif % |
#|---|---|--:|--:|--:|
#| w centro [mm] | Navier (serie) | @{w_N} | @{w_16} | @{dif_w16} |
#| Mx centro [kNm/m] | Navier (serie) | @{M_N} | @{M_16} | @{dif_M16} |
#| w centro [mm] | Timoshenko, Tabla 8 (p. 120) | @{w_T} | @{w_16} | @{dif_wT} |
#| Mx centro [kNm/m] | Timoshenko, Tabla 8 (p. 120) | @{M_T} | @{M_16} | @{dif_MT} |
#: With Calcpad the largest difference on the 4 meshes is the one above (dif_{wCP} and dif_{MCP}): 0 to 6 decimals. Against Table 8 the difference is that of the rounding of α = 0.00406 (±0.12 %).
