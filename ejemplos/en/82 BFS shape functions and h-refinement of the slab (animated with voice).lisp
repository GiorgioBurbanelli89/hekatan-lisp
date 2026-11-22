# Shape functions of the BFS element and h-refinement of the slab
#numerico

#: Two animations on the plate element of examples 71 and 73 to 78 (Bogner–Fox–Schmit, 16 degrees of freedom). The first runs through its 16 shape functions, derived here by the engine; the second refines the mesh of the supported slab, from 2 × 2 to 16 × 16 elements, and compares the center deflection with the exact Navier solution. Each animation has ▶/⏸, a frame bar and narration (🔊 button, if the computer has a Spanish voice).

## 1 · The four Hermite cubics, derived
#: In the natural coordinate ξ = x/a₁ ∈ [0, 1] the deflection along a side is a cubic, v(ξ) = c₁ + c₂·ξ + c₃·ξ² + c₄·ξ³: four constants for four data, the deflection and the slope dv/dξ at ξ = 0 and at ξ = 1. Each row of C is one of those data evaluated on the basis [1, ξ, ξ², ξ³]:
C_H = Simplify{[1, 0, 0, 0; 0, 1, 0, 0; 1, 1, 1, 1; 0, 1, 2, 3]}
#: The shape function Hᵢ is 1 at its datum i and 0 at the other three: its coefficients satisfy C·c = eᵢ (the vector with a 1 in row i), that is, they are column i of C⁻¹. The engine inverts C:
A_H = Expand{C_H^-1}
#: And each Hermite is the basis times its column:
H_1 = Expand{[1, ξ, ξ^2, ξ^3]·C_H^-1·[1; 0; 0; 0]}
H_2 = Expand{[1, ξ, ξ^2, ξ^3]·C_H^-1·[0; 1; 0; 0]}
H_3 = Expand{[1, ξ, ξ^2, ξ^3]·C_H^-1·[0; 0; 1; 0]}
H_4 = Expand{[1, ξ, ξ^2, ξ^3]·C_H^-1·[0; 0; 0; 1]}
#: The same in the other direction, η = y/b₁:
G_1 = Expand{[1, η, η^2, η^3]·C_H^-1·[1; 0; 0; 0]}
G_2 = Expand{[1, η, η^2, η^3]·C_H^-1·[0; 1; 0; 0]}
G_3 = Expand{[1, η, η^2, η^3]·C_H^-1·[0; 0; 1; 0]}
G_4 = Expand{[1, η, η^2, η^3]·C_H^-1·[0; 0; 0; 1]}
#: Check: they are the same ones used by the calculation of section 3 (those of example 78, verified against Calcpad). The rotation ones carry the factor a₁ there, because the rotation is dw/dx = (1/a₁)·dw/dξ. Each subtraction gives zero:
r_1 = Simplify{H_1 - (1 - ξ^2·(3 - 2·ξ))}
r_2 = Simplify{H_2 - ξ·(1 - ξ·(2 - ξ))}
r_3 = Simplify{H_3 - ξ^2·(3 - 2·ξ)}
r_4 = Simplify{H_4 - ξ^2·(-1 + ξ)}

## 2 · The 16 shape functions of the BFS
#: Each plate shape function is the PRODUCT of a Hermite in ξ by another in η. At each node there are four degrees of freedom: the deflection w, the rotations θx = ∂w/∂x and θy = ∂w/∂y, and the twist ψ = ∂²w/∂x∂y. Nodes: 1 at (0, 0), 2 at (1, 0), 3 at (1, 1) and 4 at (0, 1). In the order of the degrees of freedom (the same as the vector N of example 78):
N_1 = Expand{H_1·G_1}
N_2 = Expand{H_2·G_1}
N_3 = Expand{H_1·G_2}
N_4 = Expand{H_2·G_2}
N_5 = Expand{H_3·G_1}
N_6 = Expand{H_4·G_1}
N_7 = Expand{H_3·G_2}
N_8 = Expand{H_4·G_2}
N_9 = Expand{H_3·G_3}
N_10 = Expand{H_4·G_3}
N_11 = Expand{H_3·G_4}
N_12 = Expand{H_4·G_4}
N_13 = Expand{H_1·G_3}
N_14 = Expand{H_2·G_3}
N_15 = Expand{H_1·G_4}
N_16 = Expand{H_2·G_4}
#: Each surface is the deformed shape of the element of side 1 when ONE degree of freedom is 1 and the other fifteen are 0. The vertical scale is that of each function (the rotation and twist ones are much lower than the deflection ones: the label gives its minimum and maximum). It is rotated with the mouse.
#anim surf(N_{k}, [0 1], [0 1]), k = 1:16
#voz: Función 1: flecha unitaria en el nudo 1, la esquina de origen. Vale 1 allí y 0 en los otros tres nudos; las pendientes en todos los nudos son nulas.
#voz: Función 2: giro unitario theta x en el nudo 1. La flecha es nula en los cuatro nudos; la superficie sale del nudo 1 con pendiente 1 en la dirección x.
#voz: Función 3: giro unitario theta y en el nudo 1. Es la función 2 con x e y intercambiadas: pendiente 1 en la dirección y.
#voz: Función 4: alabeo unitario psi en el nudo 1. Flecha y giros son nulos en los cuatro nudos; solo la derivada cruzada vale 1 en el nudo 1. La superficie es una loma muy baja junto a ese nudo: su máximo es 0.022.
#voz: Función 5: flecha unitaria en el nudo 2, en x igual a 1.
#voz: Función 6: giro theta x en el nudo 2. Pendiente 1 en x en ese nudo; por eso queda por debajo del plano.
#voz: Función 7: giro theta y en el nudo 2.
#voz: Función 8: alabeo en el nudo 2.
#voz: Función 9: flecha unitaria en el nudo 3, la esquina opuesta al origen.
#voz: Función 10: giro theta x en el nudo 3.
#voz: Función 11: giro theta y en el nudo 3.
#voz: Función 12: alabeo en el nudo 3.
#voz: Función 13: flecha unitaria en el nudo 4, en y igual a 1.
#voz: Función 14: giro theta x en el nudo 4.
#voz: Función 15: giro theta y en el nudo 4.
#voz: Función 16: alabeo en el nudo 4. Con las dieciséis, la flecha y sus pendientes son continuas de un elemento al siguiente: por eso el elemento sirve para la placa delgada de Kirchhoff.

## 3 · The slab and its exact solution
#: Square slab simply supported on the 4 edges, uniform load (that of example 78). Calcpad units: E in MPa and q in kN/m², so the deflection comes out in mm and the moment in kN·m/m.
a = 4 [m] 'side in x
b = 4 [m] 'side in y
t = 0.12 [m] 'thickness
q = 10 [kN/m²] 'distributed load
E = 35000 [MPa] 'modulus of elasticity
ν = 0.3 'Poisson's ratio
D_p = E·t^3/(12·(1 - ν^2)) [MN·m] 'bending stiffness
#: **Navier** (Timoshenko and Woinowsky-Krieger, *Theory of Plates and Shells*, § 30): the deflection is the double series w = 16·q/(π⁶·D)·Σ Σ sin(mπx/a)·sin(nπy/b)/(m·n·(m²/a² + n²/b²)²), with m and n odd. At the center sin(mπ/2)·sin(nπ/2) = ±1. The engine sums it with 200 × 200 terms (the remaining tail is less than 10⁻¹² mm):
#hide
s_N = 0
s_M = 0
for i_m = 1:200
  for i_n = 1:200
    m_N = 2·i_m - 1
    n_N = 2·i_n - 1
    s_N = s_N + (-1)^(i_m + i_n)/(m_N·n_N·(m_N^2/a^2 + n_N^2/b^2)^2)
    s_M = s_M + (-1)^(i_m + i_n)·(m_N^2/a^2 + ν·n_N^2/b^2)/(m_N·n_N·(m_N^2/a^2 + n_N^2/b^2)^2)
  end
end
#show
w_N = 16·q/(pi^6·D_p)·s_N [mm] 'exact deflection at the center
α_N = w_N·D_p/(q·a^4) 'dimensionless coefficient
#: The center moment comes from differentiating the same series twice: Mx = 16·q/π⁴·Σ Σ (m²/a² + ν·n²/b²)·sin(mπx/a)·sin(nπy/b)/(m·n·(m²/a² + n²/b²)²).
M_N = 16·q/pi^4·s_M [kNm/m] 'exact moment at the center
β_N = M_N/(q·a^2) 'dimensionless coefficient
#: Both coincide with Table 8 (p. 120) of the book for b/a = 1 and ν = 0.3: α = 0.00406 and β = 0.0479.

## 4 · The element, in numbers
#: The Hermite functions of section 1, now with the element length a₁ (and b₁ in η), and their derivatives; they are those of example 78.
Φ_1a(ξ) = 1 - ξ^2·(3 - 2·ξ)
Φ_2a(ξ) = ξ·a_1·(1 - ξ·(2 - ξ))
Φ_3a(ξ) = ξ^2·(3 - 2·ξ)
Φ_4a(ξ) = ξ^2·a_1·(-1 + ξ)
Φprime_1a(ξ) = -6·(ξ/a_1)·(1 - ξ)
Φprime_2a(ξ) = 1 - ξ·(4 - 3·ξ)
Φprime_3a(ξ) = 6·(ξ/a_1)·(1 - ξ)
Φprime_4a(ξ) = -ξ·(2 - 3·ξ)
Φpprime_1a(ξ) = -(6/a_1^2)·(1 - 2·ξ)
Φpprime_2a(ξ) = -(2/a_1)·(2 - 3·ξ)
Φpprime_3a(ξ) = 6/a_1^2·(1 - 2·ξ)
Φpprime_4a(ξ) = -(2/a_1)·(1 - 3·ξ)
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
#: Shape functions (in the order N_1 … N_16 of section 2), constitutive matrix and curvature matrix B:
N(ξ, η) = [Φ_1a(ξ)·Φ_1b(η), Φ_2a(ξ)·Φ_1b(η), Φ_1a(ξ)·Φ_2b(η), Φ_2a(ξ)·Φ_2b(η), Φ_3a(ξ)·Φ_1b(η), Φ_4a(ξ)·Φ_1b(η), Φ_3a(ξ)·Φ_2b(η), Φ_4a(ξ)·Φ_2b(η), Φ_3a(ξ)·Φ_3b(η), Φ_4a(ξ)·Φ_3b(η), Φ_3a(ξ)·Φ_4b(η), Φ_4a(ξ)·Φ_4b(η), Φ_1a(ξ)·Φ_3b(η), Φ_2a(ξ)·Φ_3b(η), Φ_1a(ξ)·Φ_4b(η), Φ_2a(ξ)·Φ_4b(η)]
D = D_p·[1, ν, 0; ν, 1, 0; 0, 0, (1 - ν)/2]
B_1(ξ, η) = [Φpprime_1a(ξ)·Φ_1b(η), Φpprime_2a(ξ)·Φ_1b(η), Φpprime_1a(ξ)·Φ_2b(η), Φpprime_2a(ξ)·Φ_2b(η), Φpprime_3a(ξ)·Φ_1b(η), Φpprime_4a(ξ)·Φ_1b(η), Φpprime_3a(ξ)·Φ_2b(η), Φpprime_4a(ξ)·Φ_2b(η), Φpprime_3a(ξ)·Φ_3b(η), Φpprime_4a(ξ)·Φ_3b(η), Φpprime_3a(ξ)·Φ_4b(η), Φpprime_4a(ξ)·Φ_4b(η), Φpprime_1a(ξ)·Φ_3b(η), Φpprime_2a(ξ)·Φ_3b(η), Φpprime_1a(ξ)·Φ_4b(η), Φpprime_2a(ξ)·Φ_4b(η)]
B_2(ξ, η) = [Φ_1a(ξ)·Φpprime_1b(η), Φ_2a(ξ)·Φpprime_1b(η), Φ_1a(ξ)·Φpprime_2b(η), Φ_2a(ξ)·Φpprime_2b(η), Φ_3a(ξ)·Φpprime_1b(η), Φ_4a(ξ)·Φpprime_1b(η), Φ_3a(ξ)·Φpprime_2b(η), Φ_4a(ξ)·Φpprime_2b(η), Φ_3a(ξ)·Φpprime_3b(η), Φ_4a(ξ)·Φpprime_3b(η), Φ_3a(ξ)·Φpprime_4b(η), Φ_4a(ξ)·Φpprime_4b(η), Φ_1a(ξ)·Φpprime_3b(η), Φ_2a(ξ)·Φpprime_3b(η), Φ_1a(ξ)·Φpprime_4b(η), Φ_2a(ξ)·Φpprime_4b(η)]
B_3(ξ, η) = 2·[Φprime_1a(ξ)·Φprime_1b(η), Φprime_2a(ξ)·Φprime_1b(η), Φprime_1a(ξ)·Φprime_2b(η), Φprime_2a(ξ)·Φprime_2b(η), Φprime_3a(ξ)·Φprime_1b(η), Φprime_4a(ξ)·Φprime_1b(η), Φprime_3a(ξ)·Φprime_2b(η), Φprime_4a(ξ)·Φprime_2b(η), Φprime_3a(ξ)·Φprime_3b(η), Φprime_4a(ξ)·Φprime_3b(η), Φprime_3a(ξ)·Φprime_4b(η), Φprime_4a(ξ)·Φprime_4b(η), Φprime_1a(ξ)·Φprime_3b(η), Φprime_2a(ξ)·Φprime_3b(η), Φprime_1a(ξ)·Φprime_4b(η), Φprime_2a(ξ)·Φprime_4b(η)]
B(ξ, η) = [B_1(ξ, η); B_2(ξ, η); B_3(ξ, η)]
#: Stiffness and load of the element (double integrals over the rectangle, dx·dy = a₁·b₁·dξ·dη):
#noc
K_e = a_1·b_1·Area{Area{transpose(B(ξ, η))·D·B(ξ, η) @ ξ = 0 : 1} @ η = 0 : 1}
F_e = a_1·b_1·Area{Area{N(ξ, η)·q @ ξ = 0 : 1} @ η = 0 : 1}
#equ
#hide
n_g = 16
k_1 = n_g/4
d_j(j) = k_1·(j - 1) + (1:k_1)
d_e(e) = [d_j(e_j(e, 1)), d_j(e_j(e, 2)), d_j(e_j(e, 3)), d_j(e_j(e, 4))]
w_s = zeros(8, 1)
M_s = zeros(8, 1)
g_s = zeros(8, 1)
#show

## 5 · h-refinement: from 2 × 2 to 16 × 16 elements
#: h = a/n is the element side. In each frame the engine builds the n × n mesh, the stiffness and the load of each element (they change with a₁ = h), assembles, applies the supports (w and the rotation along the edge, as in example 71), solves by Cholesky and reads the deflection and the moment Mx of the central node.
#anim(n = 2:2:16)
### Mesh of {n} × {n} elements
#hide
a_1 = a/n
b_1 = b/n
n_e = n^2
n_j = (n + 1)^2
n_d = k_1·n_j
K_e = a_1·b_1·integral2(@(ξ, η) transpose(B(ξ, η))·D·B(ξ, η), 0, 1, 0, 1)
F_e = a_1·b_1·q·integral2(@(ξ, η) N(ξ, η), 0, 1, 0, 1)
x_j = zeros(n_j, 1)
y_j = zeros(n_j, 1)
e_j = zeros(n_e, 4)
for i_a = 1:n + 1
  for i_b = 1:n + 1
    x_j((i_a - 1)·(n + 1) + i_b) = (i_a - 1)·a_1
    y_j((i_a - 1)·(n + 1) + i_b) = (i_b - 1)·b_1
  end
end
for i_a = 1:n
  for i_b = 1:n
    e = i_b + n·(i_a - 1)
    j = e + i_a - 1
    e_j(e, 1:4) = [j, j + n + 1, j + n + 2, j + 1]
  end
end
K = zeros(n_d, n_d)
F = zeros(n_d, 1)
for e = 1:n_e
  g = d_e(e)
  K(g, g) = K(g, g) + K_e
  F(g) = F(g) + F_e
end
s_j = zeros(4·n, 1)
i_s = 0
for i_a = 1:n + 1
  for i_b = 1:n + 1
    j = k_1·((i_a - 1)·(n + 1) + i_b - 1)
    if i_b == 1 || i_b == n + 1
      K(j + 1, j + 1) = K(j + 1, j + 1) + 10^20
      K(j + 2, j + 2) = K(j + 2, j + 2) + 10^20
    end
    if i_a == 1 || i_a == n + 1
      K(j + 1, j + 1) = K(j + 1, j + 1) + 10^20
      K(j + 3, j + 3) = K(j + 3, j + 3) + 10^20
    end
    if i_a == 1 || i_a == n + 1 || i_b == 1 || i_b == n + 1
      i_s = i_s + 1
      s_j(i_s) = (i_a - 1)·(n + 1) + i_b
    end
  end
end
Z = clsolve(K, F)
W_z = zeros(n + 1, n + 1)
for i_a = 1:n + 1
  for i_b = 1:n + 1
    W_z(i_a, i_b) = Z(4·((i_a - 1)·(n + 1) + i_b) - 3)
  end
end
w(x, y) = spline(1 + x/a_1, 1 + y/b_1, W_z)
j_c = (n/2)·(n + 1) + n/2 + 1
e_c = (n/2 - 1)·n + n/2
M_e = -D·B(1, 1)·Z(d_e(e_c))
w_s(n/2) = Z(k_1·(j_c - 1) + 1)
M_s(n/2) = M_e(1)
g_s(n/2) = n_d
#show
#malla(x_j, y_j, e_j, s_j)
#map(-w(x, y), [0 4], [0 4])
h = a/n [m] 'element side
w_c = w_s(n/2) [mm] 'deflection at the center
e_w = round((w_c - w_N)/w_N·100, 5) [%] 'difference with Navier
#voz: Malla de {n} por {n} elementos, h = @{h} metros: la flecha del centro difiere de la de Navier en @{e_w} por ciento.
#finanim
#voz: Con 2 por 2 elementos la losa entera tiene 9 nudos y la deformada es gruesa: la flecha del centro queda un 1.5 por ciento por encima de la exacta.
#voz: Con 4 por 4 el error baja unas veinte veces. Cada elemento reproduce ya una cúbica completa en cada dirección.
#voz: Con 6 por 6 la diferencia es de centésimas de por ciento.
#voz: Con 8 por 8, h es la cuarta parte que con 2 por 2, y el error es cientos de veces menor.
#voz: A partir de aquí la malla casi no cambia a la vista: la flecha ya está convergida.
#voz: Doce por doce: el error sigue bajando al mismo ritmo.
#voz: Catorce por catorce.
#voz: Dieciséis por dieciséis: mil ciento cincuenta y seis grados de libertad, y la flecha coincide con Navier en cinco cifras.

## 6 · The error and its order of convergence
#: If the error behaves as e ≈ C·hᵖ, between two consecutive meshes p = ln(e₁/e₂)/ln(h₁/h₂). The order p comes from the numbers of the table, it is not assumed.
#hide
T = zeros(8, 9)
for k = 1:8
  n_k = 2·k
  e_wk = (w_s(k) - w_N)/w_N·100
  e_Mk = (M_s(k) - M_N)/M_N·100
  T(k, 1:5) = [n_k, a/n_k, g_s(k), w_s(k), e_wk]
  T(k, 7:8) = [M_s(k), e_Mk]
  if k > 1
    T(k, 6) = ln(T(k - 1, 5)/e_wk)/ln(T(k - 1, 2)/T(k, 2))
    T(k, 9) = ln(T(k - 1, 8)/e_Mk)/ln(T(k - 1, 2)/T(k, 2))
  end
end
#show
#: Columns: n, h [m], degrees of freedom, central deflection [mm], its error against Navier [%], order p of the deflection (between that mesh and the previous one), central Mx [kN·m/m], its error [%] and its order p:
T
p_w = T(8, 6) 'order of the deflection between 14 × 14 and 16 × 16
p_M = T(8, 9) 'order of the moment between 14 × 14 and 16 × 16
#: The deflection order comes out 4.01: when h is halved the error is divided by about sixteen. The reason: inside each element the deflection is a product of complete cubics, and the interpolation error with degree 3 polynomials is of order h⁴. The moment comes from SECOND derivatives of that deflection, and each derivative loses one order: its error drops as h² (p = 2.04), quite a lot slower. With a fine mesh the moment error is still noticeable when the deflection one no longer is.
#voz: El orden de convergencia de la flecha sale cercano a cuatro: al partir el elemento por la mitad, el error se divide entre dieciséis. El momento, que sale de segundas derivadas, converge con orden dos.
#: **Another program, same mesh node by node:** Calcpad (*Rectangular Slab FEA* with this data) gives the central deflections of the 8 meshes (the Calcpad HTMLs are in the BFS plate test folder):
#val
w_CP = [1.905605; 1.879084; 1.877967; 1.87779; 1.877742; 1.877725; 1.877718; 1.877715] [mm] 'Calcpad, one mesh per row
#equ
dif_CP = round(max(abs(w_s - w_CP)), 6) [mm] 'largest difference
