# The finite elements of Hekatan Geotechnic step by step: from symbols to numbers
#numerico
#: **Hekatan Geotechnic** computes the stability of a slope by finite elements with the **T6** element: a **6-node** triangle (3 corners and 3 midpoints) in **plane strain**. This sheet does, in the usual order, what the engine does inside: **data → mesh → shape functions → Jacobian → B matrix → constitutive matrix → Gauss quadrature → stiffness → assembly → gravity load → supports → solution → stresses → Mohr-Coulomb plasticity → strength reduction**.
#: **How to read it.** In each step the **symbolic operations** come first (with letters: the derivation, the why) and then the **numerical** ones (with the data of this sheet). At the end, every number is compared with the one given by the real Geotechnic solver for the same block.
#: **Idea in one sentence:** the stiffness is the strain energy of the element, **K = ∫ Bᵀ·D·B dA**. B converts the node displacements into strains, D converts strains into stresses, and the integral adds up over the area. The whole engine is this, repeated in each triangle.

## 1 · Data
#: A soil block of **4 m × 2 m** resting on a rigid base. **Only 2 T6 elements** are used so that every number fits on the screen; the real engine uses hundreds, with exactly the same formulas.
#: **Look at Figure 1:** it is the complete problem, with its data, its load (the self weight) and its support.
#dibujo("Figure 1. The problem: a soil block of 4 m × 2 m on a rigid base, loaded by its own weight", ud = m, ancho = 200, alto = 109)
#  achurado(-0.6, -0.45, 5.2, 0.45, "ground")
#  poligono([0, 4, 4, 0], [0, 0, 2, 2], "azul tenue")
#  polilinea([0, 4, 4, 0, 0], [0, 0, 2, 2, 0], "gruesa")
#  flecha(0.8, 1.85, 0.8, 1.15, "rojo")
#  flecha(2, 1.85, 2, 1.15, "rojo")
#  flecha(3.2, 1.85, 3.2, 1.15, "rojo")
#  texto(2.1, 0.78, "self weight  γ = 18 kN/m³", 3, "c", estilo = "rojo")
#  cota(0, -0.55, 4, -0.55, -0.2, "Lx = 4 m")
#  cota(-0.5, 0, -0.5, 2, 0.2, "Ly = 2 m")
#  texto(2, 0.35, "soil: E = 20000 kPa, ν = 0.3, c = 2 kPa, φ = 25°", 2.6, "c")
#  texto(2, -1.2, "fixed base (u = v = 0); the sides are free", 2.8, "c")
#fin
#: In symbols. The problem is defined by the geometry (Lx, Ly) and the soil (E, ν, γ, c, φ). From them come directly the shear modulus, the weight of the block and the pressure on the base:
Gc_s = Simplify{E_m/(2*(1 + ν_m))}
Wt_s = Simplify{γ_m*Lx*Ly}
qb_s = Simplify{γ_m*Lx*Ly/Lx}
#: With numbers (the data of this sheet):
B = 4 [m] 'width of the block
H = 2 [m] 'height of the block
E = 20000 [kPa] 'modulus of elasticity of the soil
ν = 0.3 'Poisson's ratio
γ = 18 [kN/m³] 'unit weight
c = 2 [kPa] 'cohesion
phi_g = 25 'friction angle in degrees
phi = phi_g·pi/180 'friction angle in radians
#: **Units.** kPa for E and stresses, m for lengths, kN for forces. Then K comes out in kN/m and the displacements in m (shown in mm).

## 2 · The mesh: two 6-node triangles
#: The block is split into two triangles along the diagonal. **Numbering of each T6:** first the 3 corners counterclockwise, then the 3 midpoints of sides 1-2, 2-3 and 3-1. Each node has 2 degrees of freedom (u, v): node j uses dof 2j−1 and 2j.
#: In symbols. Two equal triangles of base Lx and height Ly each have area ½·Lx·Ly, and together they cover **exactly the block** (Lx·Ly). With N nodes there are 2N degrees of freedom:
Am_s = Simplify{Lx*Ly/2 + Lx*Ly/2}
gdl_s = Simplify{2*N_m}
#: With numbers:
x_j = [0, 4, 4, 0, 2, 4, 2, 2, 0] 'x coordinate of each node, in m (unitless: so it can be indexed)
y_j = [0, 0, 2, 2, 0, 1, 1, 2, 1] 'y coordinate of each node, in m
e_j = [1, 2, 3, 5, 6, 7; 1, 3, 4, 7, 8, 9]
s_j = [1, 2, 5]
n_j = 9 'nodes
n_e = 2 'elements
n_d = 2·n_j 'total degrees of freedom
#: Each row of e_j is an element (corners 1-2-3 and midpoints 4-5-6). **Supports:** the three nodes of the base (y = 0) are fixed in x and y: **6 fixed degrees of freedom, 12 free.** The sides are free.
#: **Look at Figure 2:** the 9 nodes, the 2 elements and the degrees of freedom. Nodes 1, 2 and 5 (the base) are the supports.
#dibujo("Figure 2. The mesh: 2 T6 elements, 9 nodes and 18 degrees of freedom (node j uses dof 2j−1 = u and 2j = v)", ud = m, ancho = 200, alto = 103)
#  poligono([0, 4, 4], [0, 0, 2], "verde tenue")
#  poligono([0, 4, 0], [0, 2, 2], "azul tenue")
#  polilinea([0, 4, 4, 0, 0], [0, 0, 2, 2, 0], "gruesa")
#  linea(0, 0, 4, 2, "media")
#  circulo(0, 0, 0.09, "azul relleno")
#  circulo(4, 0, 0.09, "azul relleno")
#  circulo(4, 2, 0.09, "azul relleno")
#  circulo(0, 2, 0.09, "azul relleno")
#  circulo(2, 0, 0.06, "fina")
#  circulo(4, 1, 0.06, "fina")
#  circulo(2, 1, 0.06, "fina")
#  circulo(2, 2, 0.06, "fina")
#  circulo(0, 1, 0.06, "fina")
#  texto(-0.12, -0.32, "1", 3.2, "c")
#  texto(4.12, -0.32, "2", 3.2, "c")
#  texto(4.2, 2.12, "3", 3.2, "i")
#  texto(-0.2, 2.12, "4", 3.2, "d")
#  texto(2, -0.32, "5", 3.2, "c")
#  texto(4.2, 1, "6", 3.2, "i")
#  texto(2.15, 0.72, "7", 3.2, "i")
#  texto(2, 2.28, "8", 3.2, "c")
#  texto(-0.2, 1, "9", 3.2, "d")
#  texto(3, 0.45, "element 1", 2.8, "c", estilo = "azul")
#  texto(1, 1.55, "element 2", 2.8, "c", estilo = "azul")
#  flecha(4, 2, 4.9, 2, "rojo")
#  texto(4.95, 2, "u₃ (dof 5)", 2.6, "i", estilo = "rojo")
#  flecha(4, 2, 4, 2.8, "rojo")
#  texto(4, 2.9, "v₃ (dof 6)", 2.6, "c", estilo = "rojo")
#  achurado(-0.6, -0.45, 5.2, 0.45, "ground")
#  texto(2, -1, "nodes 1, 2 and 5 fixed: 6 fixed degrees of freedom and 12 free", 2.6, "c")
#fin

## 3 · Shape functions of the T6
#: In symbols. The reference triangle has area coordinates **ξ, η and ζ = 1 − ξ − η** (they equal 1 at one vertex and 0 on the opposite side). Each shape function must equal **1 at its node and 0 at the other five**. The corner ones are N = L(2L − 1); the midpoint ones, N = 4·L_a·L_b:
#: **Look at Figure 3:** the reference triangle with its 6 nodes and its coordinates. The shape functions are defined on IT, not on the real element.
#dibujo("Figure 3. The T6 reference triangle: area coordinates ξ, η and ζ = 1 − ξ − η; nodes 4, 5 and 6 are at the midpoints", ud = m, ancho = 188, alto = 145)
#  poligono([0, 1, 0], [0, 0, 1], "azul tenue")
#  polilinea([0, 1, 0, 0], [0, 0, 1, 0], "gruesa")
#  flecha(-0.2, 0, 1.3, 0, "negro")
#  texto(1.33, 0, "ξ", 3.4, "i")
#  flecha(0, -0.2, 0, 1.25, "negro")
#  texto(0, 1.3, "η", 3.4, "c")
#  circulo(0, 0, 0.028, "azul relleno")
#  circulo(1, 0, 0.028, "azul relleno")
#  circulo(0, 1, 0.028, "azul relleno")
#  circulo(0.5, 0, 0.02, "fina")
#  circulo(0, 0.5, 0.02, "fina")
#  circulo(0.5, 0.5, 0.02, "fina")
#  texto(-0.05, -0.1, "3  (ξ=0, η=0)", 2.5, "d")
#  texto(1.05, -0.1, "1  (ξ=1, η=0)", 2.5, "i")
#  texto(-0.05, 1.07, "2  (ξ=0, η=1)", 2.5, "d")
#  texto(0.5, -0.1, "6", 2.6, "c")
#  texto(-0.06, 0.5, "5", 2.6, "d")
#  texto(0.55, 0.55, "4", 2.6, "i")
#  linea(0.5, 0, 0.5, 0.5, "trazos")
#  texto(0.52, 0.2, "ξ = ½", 2.3, "i", estilo = "azul")
#  texto(0.78, 0.82, "ζ = 0", 2.4, "i", estilo = "rojo")
#  texto(0.12, 0.12, "ζ = 1", 2.3, "i", estilo = "rojo")
#fin
N_1 = Expand{xi*(2*xi - 1)}
N_2 = Expand{eta*(2*eta - 1)}
N_3 = Expand{(1 - xi - eta)*(2*(1 - xi - eta) - 1)}
N_4 = Expand{4*xi*eta}
N_5 = Expand{4*eta*(1 - xi - eta)}
N_6 = Expand{4*(1 - xi - eta)*xi}
#: **Partition of unity.** The six must add up to 1 over the whole element; otherwise the element cannot represent rigid-body motion:
particion = Simplify{xi*(2*xi - 1) + eta*(2*eta - 1) + (1 - xi - eta)*(2*(1 - xi - eta) - 1) + 4*xi*eta + 4*eta*(1 - xi - eta) + 4*(1 - xi - eta)*xi}
#: **How they look.** Along side 3→1 (η = 0), the three functions that touch that side: each equals 1 at its node and 0 at the other two (N₃ at ξ = 0, N₆ at ξ = ½, N₁ at ξ = 1). It is the property that defines them:
#fplot(N_1 = x*(2*x - 1), N_3 = (1 - x)*(1 - 2*x), N_6 = 4*x*(1 - x), [0 1])
#: **Derivatives** with respect to ξ and η (with ζ = 1 − ξ − η). They are the ones the strain needs; they come out **linear**, so the T6 strain varies linearly inside the element:
dN1_dxi = Derivate{xi*(2*xi - 1) @ xi}
dN4_dxi = Derivate{4*xi*eta @ xi}
dN5_dxi = Derivate{4*eta*(1 - xi - eta) @ xi}
dN6_dxi = Derivate{4*(1 - xi - eta)*xi @ xi}
dN3_deta = Derivate{(1 - xi - eta)*(2*(1 - xi - eta) - 1) @ eta}
#: With numbers. The six functions and their 12 derivatives as functions (row 1: ∂N/∂ξ; row 2: ∂N/∂η, one column per node):
Nq(xi, eta) = [xi*(2*xi - 1), eta*(2*eta - 1), (1 - xi - eta)*(2*(1 - xi - eta) - 1), 4*xi*eta, 4*eta*(1 - xi - eta), 4*(1 - xi - eta)*xi]
dNq(xi, eta) = [4*xi - 1, 0, -(4*(1 - xi - eta) - 1), 4*eta, -4*eta, 4*(1 - xi - eta) - 4*xi; 0, 4*eta - 1, -(4*(1 - xi - eta) - 1), 4*xi, 4*(1 - xi - eta) - 4*eta, -4*xi]
#: At the center of the triangle (ξ = η = 1/3) the corners equal −1/9 and the midpoints 4/9; at node 4 (ξ = η = 1/2) only N₄ equals 1:
N_centro = Nq(1/3, 1/3)
N_nudo4 = Nq(1/2, 1/2)
suma_centro = N_centro(1) + N_centro(2) + N_centro(3) + N_centro(4) + N_centro(5) + N_centro(6)

## 4 · Jacobian: from the reference triangle to the real element
#: In symbols. The geometry is interpolated with **the same shape functions** (isoparametric): x = ΣNᵢ·xᵢ. If the midpoints are at the center of the sides (straight sides, as here), the sum simplifies to a **linear** formula:
x_interp = Simplify{xi*(2*xi - 1)*x1 + eta*(2*eta - 1)*x2 + (1 - xi - eta)*(2*(1 - xi - eta) - 1)*x3 + 4*xi*eta*(x1 + x2)/2 + 4*eta*(1 - xi - eta)*(x2 + x3)/2 + 4*(1 - xi - eta)*xi*(x3 + x1)/2}
#: that is, x = ξ·x₁ + η·x₂ + (1 − ξ − η)·x₃. The **Jacobian** is the derivative of (x, y) with respect to (ξ, η), one row per natural variable:
J_s = [x1 - x3, y1 - y3; x2 - x3, y2 - y3]
#: Its **determinant** is the area factor, dA = detJ·dξ·dη, and equals **twice the area of the triangle**. It must come out positive (counterclockwise nodes):
dJ_s = Simplify{det([x1 - x3, y1 - y3; x2 - x3, y2 - y3])}
#: **Look at Figure 4:** the transformation x = ΣNᵢ·xᵢ takes the reference triangle to the real element 1, and the Jacobian says how much it stretches it (detJ = 8 = twice the area).
#dibujo("Figure 4. The isoparametric transformation: the reference triangle (ξ, η) becomes the real element 1 (x, y); its Jacobian J measures how much it stretches", ud = m, ancho = 200, alto = 70)
#  poligono([0, 2, 0], [0, 0, 2], "azul tenue")
#  polilinea([0, 2, 0, 0], [0, 0, 2, 0], "gruesa")
#  poligono([5.6, 9.6, 9.6], [0, 0, 2], "verde tenue")
#  polilinea([5.6, 9.6, 9.6, 5.6], [0, 0, 2, 0], "gruesa")
#  circulo(0, 0, 0.07, "azul relleno")
#  circulo(2, 0, 0.07, "azul relleno")
#  circulo(0, 2, 0.07, "azul relleno")
#  circulo(1, 0, 0.05, "fina")
#  circulo(0, 1, 0.05, "fina")
#  circulo(1, 1, 0.05, "fina")
#  circulo(5.6, 0, 0.07, "azul relleno")
#  circulo(9.6, 0, 0.07, "azul relleno")
#  circulo(9.6, 2, 0.07, "azul relleno")
#  circulo(7.6, 0, 0.05, "fina")
#  circulo(9.6, 1, 0.05, "fina")
#  circulo(7.6, 1, 0.05, "fina")
#  texto(-0.1, -0.3, "3", 2.8, "c")
#  texto(2.1, -0.3, "1", 2.8, "c")
#  texto(-0.1, 2.15, "2", 2.8, "c")
#  texto(1, -0.3, "6", 2.6, "c")
#  texto(-0.2, 1, "5", 2.6, "d")
#  texto(1.15, 1.1, "4", 2.6, "i")
#  texto(5.5, -0.3, "1", 2.8, "c")
#  texto(9.7, -0.3, "2", 2.8, "c")
#  texto(9.75, 2.1, "3", 2.8, "i")
#  texto(7.6, -0.3, "4", 2.6, "c")
#  texto(9.75, 1, "5", 2.6, "i")
#  texto(7.7, 1.1, "6", 2.6, "i")
#  flecha(2.5, 1, 5, 1, "naranja")
#  texto(3.75, 1.35, "x = ΣNᵢ·xᵢ", 2.7, "c", estilo = "naranja")
#  texto(3.75, 0.65, "y = ΣNᵢ·yᵢ", 2.7, "c", estilo = "naranja")
#  texto(1, -0.9, "reference: area 1/2", 2.7, "c")
#  texto(8.1, -0.9, "element 1: area 4 m², detJ = 8 = 2·A", 2.7, "c")
#  texto(6.8, 2.55, "J = [x₁−x₃ y₁−y₃ ; x₂−x₃ y₂−y₃] = [−4 −2 ; 0 −2]", 2.5, "c", estilo = "azul")
#fin
#: The derivatives with respect to **x and y** come from the inverse of the Jacobian: [∂N/∂x; ∂N/∂y] = J⁻¹·[∂N/∂ξ; ∂N/∂η]. In symbols:
Ji_s = Simplify{inv([x1 - x3, y1 - y3; x2 - x3, y2 - y3])}
#: With numbers, element by element. **Xe** is the coordinate table of the element (one row per node, in the order of e_j). It is built with a loop and element 1 is used:
#hide
Xe = zeros(6, 2)
e = 1
for a = 1:6
  Xe(a, 1) = x_j(e_j(e, a))
  Xe(a, 2) = y_j(e_j(e, a))
end
#show
Xel_1 = 1*Xe 'coordinates of element 1, one row per node (in m)
Xel_1
Jq(xi, eta) = dNq(xi, eta)*Xe
dJq(xi, eta) = det(Jq(xi, eta))
J_1 = Jq(1/3, 1/3) 'Jacobian of element 1 (constant: straight sides)
dJ_1 = dJq(1/3, 1/3) 'twice the area of element 1
A_1 = dJ_1/2 [m²] 'area of triangle 1: base 4 × height 2 / 2

## 5 · The B matrix: strains from the displacements
#: In symbols. Plane strain has three components, ε_{x} = ∂u/∂x, ε_{y} = ∂v/∂y and γ_{xy} = ∂u/∂y + ∂v/∂x. With u = ΣNᵢ·uᵢ and v = ΣNᵢ·vᵢ, each one is a **linear combination of the 12 displacements** of the element [u₁, v₁, u₂, v₂, …, u₆, v₆]:
#: **Look at Figure 5:** the three strains of plane strain. It is what B computes from the displacements.
#dibujo("Figure 5. The three strains of plane strain: stretch in x, stretch in y and distort (shear). Dashed, the undeformed square", ud = m, ancho = 200, alto = 70)
#  polilinea([0, 1, 1, 0, 0], [0, 0, 1, 1, 0], "fina trazos")
#  polilinea([0, 1.4, 1.4, 0, 0], [0, 0, 1, 1, 0], "gruesa rojo")
#  flecha(1, 0.5, 1.4, 0.5, "rojo")
#  texto(0.7, -0.4, "ε_{x} = ∂u/∂x", 3, "c")
#  polilinea([3.6, 4.6, 4.6, 3.6, 3.6], [0, 0, 1, 1, 0], "fina trazos")
#  polilinea([3.6, 4.6, 4.6, 3.6, 3.6], [0, 0, 1.4, 1.4, 0], "gruesa azul")
#  flecha(4.1, 1, 4.1, 1.4, "azul")
#  texto(4.1, -0.4, "ε_{y} = ∂v/∂y", 3, "c")
#  polilinea([7.2, 8.2, 8.2, 7.2, 7.2], [0, 0, 1, 1, 0], "fina trazos")
#  polilinea([7.2, 8.2, 8.5, 7.5, 7.2], [0, 0, 1, 1, 0], "gruesa verde")
#  flecha(7.7, 1, 8, 1, "verde")
#  texto(7.9, -0.4, "γ_{xy} = ∂u/∂y + ∂v/∂x", 3, "c")
#fin
#: ε = B·u_e,   with   B = [ ∂N/∂x in the columns of u ;  ∂N/∂y in the columns of v ;  ∂N/∂y in u + ∂N/∂x in v ]
#: **Derivatives with respect to x and y.** They come from the chain rule with the inverse of the Jacobian of section 4 (N_ξ and N_η are the derivatives of the shape function with respect to ξ and η):
dNdx_s = Simplify{((y2 - y3)*Nxi + (y3 - y1)*Neta)/dJ_m}
dNdy_s = Simplify{((x3 - x2)*Nxi + (x1 - x3)*Neta)/dJ_m}
#: **The three strains** produced by a node, with its derivatives n_x = ∂N/∂x and n_y = ∂N/∂y and its displacements u_a and v_a:
ex_s = Expand{nx*ua}
ey_s = Expand{ny*va}
gxy_s = Expand{ny*ua + nx*va}
#: **Look at Figure 6:** the 12 degrees of freedom of the element, in the order in which they are stacked in the vector u_{e} and in the columns of B.
#dibujo("Figure 6. The 12 degrees of freedom of the T6 (2 per node, local numbering 1 to 6): B converts this vector into the 3 strains", ud = m, ancho = 200, alto = 96)
#  poligono([0, 4, 4], [0, 0, 2], "verde tenue")
#  polilinea([0, 4, 4, 0], [0, 0, 2, 0], "gruesa")
#  circulo(0, 0, 0.06, "negro relleno")
#  flecha(0, 0, 0.55, 0, "rojo")
#  texto(0.62, -0.08, "u_{1}", 2.4, "i", estilo = "rojo")
#  flecha(0, 0, 0, 0.55, "azul")
#  texto(-0.06, 0.7, "v_{1}", 2.4, "c", estilo = "azul")
#  circulo(4, 0, 0.06, "negro relleno")
#  flecha(4, 0, 4.55, 0, "rojo")
#  texto(4.62, -0.08, "u_{2}", 2.4, "i", estilo = "rojo")
#  flecha(4, 0, 4, 0.55, "azul")
#  texto(3.94, 0.7, "v_{2}", 2.4, "c", estilo = "azul")
#  circulo(4, 2, 0.06, "negro relleno")
#  flecha(4, 2, 4.55, 2, "rojo")
#  texto(4.62, 1.92, "u_{3}", 2.4, "i", estilo = "rojo")
#  flecha(4, 2, 4, 2.55, "azul")
#  texto(3.94, 2.7, "v_{3}", 2.4, "c", estilo = "azul")
#  circulo(2, 0, 0.06, "negro relleno")
#  flecha(2, 0, 2.55, 0, "rojo")
#  texto(2.62, -0.08, "u_{4}", 2.4, "i", estilo = "rojo")
#  flecha(2, 0, 2, 0.55, "azul")
#  texto(1.94, 0.7, "v_{4}", 2.4, "c", estilo = "azul")
#  circulo(4, 1, 0.06, "negro relleno")
#  flecha(4, 1, 4.55, 1, "rojo")
#  texto(4.62, 0.92, "u_{5}", 2.4, "i", estilo = "rojo")
#  flecha(4, 1, 4, 1.55, "azul")
#  texto(3.94, 1.7, "v_{5}", 2.4, "c", estilo = "azul")
#  circulo(2, 1, 0.06, "negro relleno")
#  flecha(2, 1, 2.55, 1, "rojo")
#  texto(2.62, 0.92, "u_{6}", 2.4, "i", estilo = "rojo")
#  flecha(2, 1, 2, 1.55, "azul")
#  texto(1.94, 1.7, "v_{6}", 2.4, "c", estilo = "azul")
#  texto(2, -0.85, "u_{e} = [u₁ v₁ u₂ v₂ … u₆ v₆]ᵀ : 12 degrees of freedom per element", 2.6, "c")
#fin
#: That is, **each node contributes to B a 3 × 2 block**, [n_x 0; 0 n_y; n_y n_x], and B is the union of the 6 blocks. With numbers, the matrices E_{u} and E_{v} only place each node in its position (u in the odd positions, v in the even ones):
#hide
Eu = zeros(6, 12)
Ev = zeros(6, 12)
for a = 1:6
  Eu(a, 2*a - 1) = 1
  Ev(a, 2*a) = 1
end
#show
#: With numbers. Derivatives with respect to x and y (one column per node) and **the three rows of B separately** (each 1 × 12; stacked one below the other they form the 3 × 12 matrix B):
gx(xi, eta) = [1, 0]*inv(Jq(xi, eta))*dNq(xi, eta)
gy(xi, eta) = [0, 1]*inv(Jq(xi, eta))*dNq(xi, eta)
Bx_q(xi, eta) = gx(xi, eta)*Eu
By_q(xi, eta) = gy(xi, eta)*Ev
Bg_q(xi, eta) = gy(xi, eta)*Eu + gx(xi, eta)*Ev
dNdx_c = gx(1/3, 1/3)
dNdy_c = gy(1/3, 1/3)
Bx_c = Bx_q(1/3, 1/3)
By_c = By_q(1/3, 1/3)
Bg_c = Bg_q(1/3, 1/3)
#: **Rigid-body check.** If all the nodes translate 1 in x, the strain must be zero:
u_tras = [1; 0; 1; 0; 1; 0; 1; 0; 1; 0; 1; 0]
eps_x = Bx_c*u_tras
eps_y = By_c*u_tras
gam_xy = Bg_c*u_tras

## 6 · The constitutive matrix D (plane strain)
#: In symbols. Hooke's law in plane strain (ε_{z} = 0) relates the stresses [σ_{x}, σ_{y}, σ_{z}, τ_{xy}] to the strains [ε_{x}, ε_{y}, ε_{z}, γ_{xy}] through the Lamé constants **λ** and **G**:
#: **Look at Figure 7:** the stress state of a soil element in plane strain; D relates these stresses to the strains of Figure 5.
#dibujo("Figure 7. Soil element in plane strain: the in-plane stresses σx, σy and τxy, and the σz that appears because the strain εz is prevented", ud = m, ancho = 188, alto = 113)
#  poligono([0, 2, 2, 0], [0, 0, 2, 2], "azul tenue")
#  polilinea([0, 2, 2, 0, 0], [0, 0, 2, 2, 0], "gruesa")
#  flecha(-0.9, 1, 0, 1, "rojo")
#  flecha(2.9, 1, 2, 1, "rojo")
#  texto(-0.95, 1.25, "σx", 3, "d", estilo = "rojo")
#  texto(2.95, 1.25, "σx", 3, "i", estilo = "rojo")
#  flecha(1, -0.9, 1, 0, "azul")
#  flecha(1, 2.9, 1, 2, "azul")
#  texto(1.2, -0.75, "σy", 3, "i", estilo = "azul")
#  texto(1.2, 2.75, "σy", 3, "i", estilo = "azul")
#  flecha(0.4, 2.35, 1.6, 2.35, "verde")
#  flecha(1.6, -0.35, 0.4, -0.35, "verde")
#  texto(1, 2.75, "", 2, "c")
#  texto(2.35, 2.35, "τxy", 2.6, "i", estilo = "verde")
#  circulo(1, 1, 0.22, "media")
#  linea(0.85, 0.85, 1.15, 1.15, "media")
#  linea(0.85, 1.15, 1.15, 0.85, "media")
#  texto(1, 0.35, "σz out of the plane", 2.4, "c", estilo = "naranja")
#fin
lam_s = Simplify{E_m*ν_m/((1 + ν_m)*(1 - 2*ν_m))}
G_s = Simplify{E_m/(2*(1 + ν_m))}
#: The shear term of D, which comes out as E(1−2ν)/2 divided by (1+ν)(1−2ν), **is exactly G** (symbolic check: the difference is zero):
dif_G = Simplify{E_m*(1 - 2*ν_m)/2/((1 + ν_m)*(1 - 2*ν_m)) - E_m/(2*(1 + ν_m))}
#: And the normal row, E(1−ν)/((1+ν)(1−2ν)), is **λ + 2G**:
dif_L = Simplify{E_m*(1 - ν_m)/((1 + ν_m)*(1 - 2*ν_m)) - (E_m*ν_m/((1 + ν_m)*(1 - 2*ν_m)) + 2*E_m/(2*(1 + ν_m)))}
#: With numbers:
lam = E*ν/((1 + ν)*(1 - 2*ν)) [kPa]
G = E/(2*(1 + ν)) [kPa]
D = [lam + 2*G, lam, lam, 0; lam, lam + 2*G, lam, 0; lam, lam, lam + 2*G, 0; 0, 0, 0, G]
#: Since ε_{z} = 0, the stiffness uses only three components (ε_{x}, ε_{y}, γ_{xy}); σ_{z} does no work but it **is computed** (σ_{z} = ν·(σ_{x} + σ_{y}) in the elastic range) because Mohr-Coulomb needs it:
D3 = [lam + 2*G, lam, 0; lam, lam + 2*G, 0; 0, 0, G]

## 7 · 7-point Gauss quadrature
#: In symbols. The integral over the reference triangle (area 1/2) is replaced by a sum of 7 samples, ∫∫ f dξdη ≈ Σ wᵢ·f(ξᵢ, ηᵢ). The **Radon** rule is exact for polynomials up to **degree 5**, and its weights and positions have exact form with roots of 15. The weights, one at the center and two groups of three, **add up to 1/2** (the area of the triangle):
suma_pesos = Simplify{9/80 + 3*(155 - sqrt(15))/2400 + 3*(155 + sqrt(15))/2400}
#: With numbers, the weights:
w_centro = 9/80
w_a = (155 - sqrt(15))/2400
w_b = (155 + sqrt(15))/2400
#: The positions, in area coordinates, are combinations of (6 ∓ √15)/21 and (9 ± 2√15)/21:
a_1 = (6 - sqrt(15))/21
b_1 = (9 + 2*sqrt(15))/21
a_2 = (6 + sqrt(15))/21
b_2 = (9 - 2*sqrt(15))/21
#: **Look at Figure 8:** where the 7 points fall in the reference triangle and in the real element, and how much each one weighs.
#dibujo("Figure 8. The 7 Radon Gauss points (circle size is the weight): the integral over the triangle is replaced by 7 samples", ud = m, ancho = 200, alto = 75)
#  poligono([0, 3.2, 0], [0, 0, 3.2], "azul tenue")
#  polilinea([0, 3.2, 0, 0], [0, 0, 3.2, 0], "gruesa")
#  poligono([6.3, 9.5, 9.5], [0, 0, 1.6], "verde tenue")
#  polilinea([6.3, 9.5, 9.5, 6.3], [0, 0, 1.6, 0], "gruesa")
#  circulo(1.0667, 1.0667, 0.14, "rojo relleno")
#  texto(1.1867, 1.1667, "1", 2.5, "i")
#  circulo(8.4333, 0.5333, 0.14, "rojo relleno")
#  texto(8.5533, 0.6333, "1", 2.5, "i")
#  circulo(0.3241, 0.3241, 0.1004, "rojo relleno")
#  texto(0.4441, 0.4241, "2", 2.5, "i")
#  circulo(9.1759, 1.2759, 0.1004, "rojo relleno")
#  texto(9.2959, 1.3759, "2", 2.5, "i")
#  circulo(2.5518, 0.3241, 0.1004, "rojo relleno")
#  texto(2.6718, 0.4241, "3", 2.5, "i")
#  circulo(6.9482, 0.1621, 0.1004, "rojo relleno")
#  texto(7.0682, 0.2621, "3", 2.5, "i")
#  circulo(0.3241, 2.5518, 0.1004, "rojo relleno")
#  texto(0.4441, 2.6518, "4", 2.5, "i")
#  circulo(9.1759, 0.1621, 0.1004, "rojo relleno")
#  texto(9.2959, 0.2621, "4", 2.5, "i")
#  circulo(1.5045, 1.5045, 0.103, "rojo relleno")
#  texto(1.6245, 1.6045, "5", 2.5, "i")
#  circulo(7.9955, 0.0955, 0.103, "rojo relleno")
#  texto(8.1155, 0.1955, "5", 2.5, "i")
#  circulo(0.1911, 1.5045, 0.103, "rojo relleno")
#  texto(0.3111, 1.6045, "6", 2.5, "i")
#  circulo(9.3089, 0.7522, 0.103, "rojo relleno")
#  texto(9.4289, 0.8522, "6", 2.5, "i")
#  circulo(1.5045, 0.1911, 0.103, "rojo relleno")
#  texto(1.6245, 0.2911, "7", 2.5, "i")
#  circulo(7.9955, 0.7522, 0.103, "rojo relleno")
#  texto(8.1155, 0.8522, "7", 2.5, "i")
#  texto(1.6, -0.55, "reference triangle", 2.6, "c")
#  texto(7.9, -0.55, "the same points in element 1", 2.6, "c")
#  texto(1.6, 3.6, "larger circle = larger weight: w₁ = 9/80 = 0.1125;  w₂…w₄ = 0.0630;  w₅…w₇ = 0.0662;  Σw = ½", 2.5, "c")
#fin
#: With numbers. The 7 points (ξ, η) and their weights, in the engine order (the center, three of group a, three of group b):
xg = [1/3; a_1; b_1; a_1; a_2; b_2; a_2]
yg = [1/3; a_1; a_1; b_1; a_2; a_2; b_2]
wg = [w_centro; w_a; w_a; w_a; w_b; w_b; w_b]
#: **Checks.** The weights add up to 1/2, and the rule integrates exactly ∫∫ξ²η² dξdη = 2!·2!/6! = 1/180 (a degree 4 polynomial):
sum_w = wg(1) + wg(2) + wg(3) + wg(4) + wg(5) + wg(6) + wg(7)
int_x2y2 = wg(1)*xg(1)^2*yg(1)^2 + wg(2)*xg(2)^2*yg(2)^2 + wg(3)*xg(3)^2*yg(3)^2 + wg(4)*xg(4)^2*yg(4)^2 + wg(5)*xg(5)^2*yg(5)^2 + wg(6)*xg(6)^2*yg(6)^2 + wg(7)*xg(7)^2*yg(7)^2
exacta_x2y2 = 1/180
#: And it reproduces the area of element 1 (constant detJ × sum of weights = 8 × 1/2 = 4 m²):
area_1 = dJq(1/3, 1/3)*sum_w [m²]

## 8 · The element stiffness
#: In symbols. K is the strain energy, K = ∫ Bᵀ·D·B dA, per meter of depth (plane strain). With the quadrature, **each term is a sum over the 7 points**:
#: K_{e} = Σ_{q=1…7} w_{q} · detJ · B(ξ_{q}, η_{q})ᵀ · D₃ · B(ξ_{q}, η_{q})
#: **Look at Figure 9:** the shape of K_{e}: 12 × 12 with 2 × 2 blocks, one for each pair of nodes (the orange block is the coupling between nodes 3 and 4).
#dibujo("Figure 9. Structure of the element stiffness K_{e} (12 × 12): 6 × 6 blocks of 2 × 2, one for each pair of nodes", ud = , ancho = 200, alto = 133)
#  poligono([0, 2, 2, 0], [10, 10, 12, 12], "azul tenue")
#  poligono([2, 4, 4, 2], [8, 8, 10, 10], "azul tenue")
#  poligono([4, 6, 6, 4], [6, 6, 8, 8], "azul tenue")
#  poligono([6, 8, 8, 6], [4, 4, 6, 6], "azul tenue")
#  poligono([8, 10, 10, 8], [2, 2, 4, 4], "azul tenue")
#  poligono([10, 12, 12, 10], [0, 0, 2, 2], "azul tenue")
#  poligono([4, 6, 6, 4], [4, 4, 6, 6], "naranja tenue")
#  linea(0, 0, 12, 0, "fina")
#  linea(0, 0, 0, 12, "fina")
#  linea(0, 2, 12, 2, "fina")
#  linea(2, 0, 2, 12, "fina")
#  linea(0, 4, 12, 4, "fina")
#  linea(4, 0, 4, 12, "fina")
#  linea(0, 6, 12, 6, "fina")
#  linea(6, 0, 6, 12, "fina")
#  linea(0, 8, 12, 8, "fina")
#  linea(8, 0, 8, 12, "fina")
#  linea(0, 10, 12, 10, "fina")
#  linea(10, 0, 10, 12, "fina")
#  linea(0, 12, 12, 12, "fina")
#  linea(12, 0, 12, 12, "fina")
#  polilinea([0, 12, 12, 0, 0], [0, 0, 12, 12, 0], "gruesa")
#  texto(1, 12.6, "node 1", 2.3, "c")
#  texto(-0.3, 11, "node 1", 2.3, "d")
#  texto(3, 12.6, "node 2", 2.3, "c")
#  texto(-0.3, 9, "node 2", 2.3, "d")
#  texto(5, 12.6, "node 3", 2.3, "c")
#  texto(-0.3, 7, "node 3", 2.3, "d")
#  texto(7, 12.6, "node 4", 2.3, "c")
#  texto(-0.3, 5, "node 4", 2.3, "d")
#  texto(9, 12.6, "node 5", 2.3, "c")
#  texto(-0.3, 3, "node 5", 2.3, "d")
#  texto(11, 12.6, "node 6", 2.3, "c")
#  texto(-0.3, 1, "node 6", 2.3, "d")
#  texto(13, 8, "each 2×2 square couples", 2.4, "i")
#  texto(13, 7.2, "node a with node b:", 2.4, "i")
#  texto(13, 6.4, "[ k_{uu} k_{uv} ; k_{vu} k_{vv} ]", 2.4, "i", estilo = "azul")
#  texto(13, 5, "the orange square (nodes 3 and 4)", 2.3, "i", estilo = "naranja")
#  texto(13, 4.2, "es K_{34}", 2.3, "i", estilo = "naranja")
#  texto(13, 2.6, "K_{e} is symmetric 12×12", 2.4, "i")
#  texto(13, 1.8, "(144 numbers, 78 distinct)", 2.4, "i")
#fin
#: A single entry, that of the degree of freedom u₁ with itself. The column u₁ of B is [∂N₁/∂x; 0; ∂N₁/∂y] (u₁ only affects ε_{x} and γ_{xy}), so the contribution of one point is:
k11_q = Expand{dJ_m*(nx^2*(λ_m + 2*G_m) + ny^2*G_m)}
#: that is, **(λ+2G)·(∂N₁/∂x)² + G·(∂N₁/∂y)²**, times detJ. The first term is the axial stiffness and the second the shear one.
#: With numbers. A loop adds the 7 points. It is done for element 1 (Xe already contains its coordinates):
#: Contribution of **one** Gauss point, 12 × 12 (with the three rows of B separately; the product Bᵀ·D·B is written by adding the terms of D₃):
kq(xi, eta) = dJq(xi, eta)*(D3(1, 1)*transpose(Bx_q(xi, eta))*Bx_q(xi, eta) + D3(1, 2)*(transpose(Bx_q(xi, eta))*By_q(xi, eta) + transpose(By_q(xi, eta))*Bx_q(xi, eta)) + D3(2, 2)*transpose(By_q(xi, eta))*By_q(xi, eta) + D3(3, 3)*transpose(Bg_q(xi, eta))*Bg_q(xi, eta))
#hide
Ke = zeros(12, 12)
for q = 1:7
  Ke = Ke + wg(q)*kq(xg(q), yg(q))
end
#show
Kel_11 = Ke(1, 1) [kN/m]
#: **Checks** (if they fail, there is a sign or ordering error). K is symmetric, and a rigid-body motion (translation in x) **produces no forces**:
asim = Ke(1, 2) - Ke(2, 1)
f_tras = Ke*u_tras
n_tras = norm(f_tras) 'must be ≈ 0 (numerical noise)
#: **Energy of a constant strain.** With u = 0.001·x at the nodes, ε_{x} = 0.001 and the rest zero: the exact energy is U = ½·(λ+2G)·ε²·A = ½·(λ+2G)·10⁻⁶·4. The element must give it exactly:
u_x = [0; 0; 0.004; 0; 0.004; 0; 0.002; 0; 0.004; 0; 0.002; 0]
U_fem = 0.5*transpose(u_x)*Ke*u_x [kN·m]
U_exacta = 0.5*(lam + 2*G)*0.001*0.001*area_1 [kN·m]

## 9 · Assembly and gravity load
#: In symbols. The degrees of freedom of node j are 2j−1 and 2j; those of an element, those of its 6 nodes in sequence. Assembly **adds** the stiffness of each element into the rows and columns of its degrees of freedom: K(g,g) ← K(g,g) + K_{e}. Where two elements share a node, their contributions add up.
#: An example with letters: two springs k₁ and k₂ in series, sharing node 2. Each element places its 2×2 matrix [k, −k; −k, k] in its own degrees of freedom and the two are **added**; the only term received by both elements is that of the shared node, K(2,2):
K22_s = Simplify{k1 + k2}
Kg_s = [k1, -k1, 0; -k1, k1 + k2, -k2; 0, -k2, k2]
#: **Look at Figure 10:** the example of the two springs, with the two contributions and the shared term.
#dibujo("Figure 10. Assembly with letters: two springs k₁ and k₂ sharing node 2. Each contributes its 2×2 matrix and at the shared node they are ADDED", ud = m, ancho = 200, alto = 65)
#  polilinea([0, 0.45, 0.75, 1.05, 1.35, 1.65, 1.95, 2.25, 2.55, 3], [0, 0.28, -0.28, 0.28, -0.28, 0.28, -0.28, 0.28, -0.28, 0], "gruesa")
#  polilinea([3, 3.45, 3.75, 4.05, 4.35, 4.65, 4.95, 5.25, 5.55, 6], [0, 0.28, -0.28, 0.28, -0.28, 0.28, -0.28, 0.28, -0.28, 0], "gruesa")
#  circulo(0, 0, 0.12, "azul relleno")
#  circulo(3, 0, 0.12, "rojo relleno")
#  circulo(6, 0, 0.12, "azul relleno")
#  texto(0, -0.5, "1", 3, "c")
#  texto(3, -0.5, "2", 3, "c")
#  texto(6, -0.5, "3", 3, "c")
#  texto(1.5, 0.6, "k₁", 3, "c", estilo = "azul")
#  texto(4.5, 0.6, "k₂", 3, "c", estilo = "azul")
#  texto(1.5, -1.05, "K_{e1} = [ k₁ −k₁ ; −k₁ k₁ ]", 2.6, "c")
#  texto(4.5, -1.05, "K_{e2} = [ k₂ −k₂ ; −k₂ k₂ ]", 2.6, "c")
#  texto(3, 1.35, "K(2,2) = k₁ + k₂", 3, "c", estilo = "rojo")
#  flecha(3, 1.15, 3, 0.3, "rojo")
#fin
#: The assembled K (above) has in K(2,2) the value **k₁ + k₂**: both elements contribute it. The same happens with the loads: at node 7 of this mesh the contributions of the two T6 are added.
#: **Look at Figure 11:** the pattern of the K of this mesh. Nodes 1, 3 and 7 belong to both elements (green cells), and there the contributions are added.
#dibujo("Figure 11. The global K (18 × 18) by node blocks: it is filled only where two nodes belong to the same element (each square is 2 × 2)", ud = , ancho = 200, alto = 125)
#  poligono([0, 1, 1, 0], [8, 8, 9, 9], "verde relleno")
#  poligono([1, 2, 2, 1], [8, 8, 9, 9], "naranja relleno")
#  poligono([2, 3, 3, 2], [8, 8, 9, 9], "verde relleno")
#  poligono([3, 4, 4, 3], [8, 8, 9, 9], "azul relleno")
#  poligono([4, 5, 5, 4], [8, 8, 9, 9], "naranja relleno")
#  poligono([5, 6, 6, 5], [8, 8, 9, 9], "naranja relleno")
#  poligono([6, 7, 7, 6], [8, 8, 9, 9], "verde relleno")
#  poligono([7, 8, 8, 7], [8, 8, 9, 9], "azul relleno")
#  poligono([8, 9, 9, 8], [8, 8, 9, 9], "azul relleno")
#  poligono([0, 1, 1, 0], [7, 7, 8, 8], "naranja relleno")
#  poligono([1, 2, 2, 1], [7, 7, 8, 8], "naranja relleno")
#  poligono([2, 3, 3, 2], [7, 7, 8, 8], "naranja relleno")
#  poligono([4, 5, 5, 4], [7, 7, 8, 8], "naranja relleno")
#  poligono([5, 6, 6, 5], [7, 7, 8, 8], "naranja relleno")
#  poligono([6, 7, 7, 6], [7, 7, 8, 8], "naranja relleno")
#  poligono([0, 1, 1, 0], [6, 6, 7, 7], "verde relleno")
#  poligono([1, 2, 2, 1], [6, 6, 7, 7], "naranja relleno")
#  poligono([2, 3, 3, 2], [6, 6, 7, 7], "verde relleno")
#  poligono([3, 4, 4, 3], [6, 6, 7, 7], "azul relleno")
#  poligono([4, 5, 5, 4], [6, 6, 7, 7], "naranja relleno")
#  poligono([5, 6, 6, 5], [6, 6, 7, 7], "naranja relleno")
#  poligono([6, 7, 7, 6], [6, 6, 7, 7], "verde relleno")
#  poligono([7, 8, 8, 7], [6, 6, 7, 7], "azul relleno")
#  poligono([8, 9, 9, 8], [6, 6, 7, 7], "azul relleno")
#  poligono([0, 1, 1, 0], [5, 5, 6, 6], "azul relleno")
#  poligono([2, 3, 3, 2], [5, 5, 6, 6], "azul relleno")
#  poligono([3, 4, 4, 3], [5, 5, 6, 6], "azul relleno")
#  poligono([6, 7, 7, 6], [5, 5, 6, 6], "azul relleno")
#  poligono([7, 8, 8, 7], [5, 5, 6, 6], "azul relleno")
#  poligono([8, 9, 9, 8], [5, 5, 6, 6], "azul relleno")
#  poligono([0, 1, 1, 0], [4, 4, 5, 5], "naranja relleno")
#  poligono([1, 2, 2, 1], [4, 4, 5, 5], "naranja relleno")
#  poligono([2, 3, 3, 2], [4, 4, 5, 5], "naranja relleno")
#  poligono([4, 5, 5, 4], [4, 4, 5, 5], "naranja relleno")
#  poligono([5, 6, 6, 5], [4, 4, 5, 5], "naranja relleno")
#  poligono([6, 7, 7, 6], [4, 4, 5, 5], "naranja relleno")
#  poligono([0, 1, 1, 0], [3, 3, 4, 4], "naranja relleno")
#  poligono([1, 2, 2, 1], [3, 3, 4, 4], "naranja relleno")
#  poligono([2, 3, 3, 2], [3, 3, 4, 4], "naranja relleno")
#  poligono([4, 5, 5, 4], [3, 3, 4, 4], "naranja relleno")
#  poligono([5, 6, 6, 5], [3, 3, 4, 4], "naranja relleno")
#  poligono([6, 7, 7, 6], [3, 3, 4, 4], "naranja relleno")
#  poligono([0, 1, 1, 0], [2, 2, 3, 3], "verde relleno")
#  poligono([1, 2, 2, 1], [2, 2, 3, 3], "naranja relleno")
#  poligono([2, 3, 3, 2], [2, 2, 3, 3], "verde relleno")
#  poligono([3, 4, 4, 3], [2, 2, 3, 3], "azul relleno")
#  poligono([4, 5, 5, 4], [2, 2, 3, 3], "naranja relleno")
#  poligono([5, 6, 6, 5], [2, 2, 3, 3], "naranja relleno")
#  poligono([6, 7, 7, 6], [2, 2, 3, 3], "verde relleno")
#  poligono([7, 8, 8, 7], [2, 2, 3, 3], "azul relleno")
#  poligono([8, 9, 9, 8], [2, 2, 3, 3], "azul relleno")
#  poligono([0, 1, 1, 0], [1, 1, 2, 2], "azul relleno")
#  poligono([2, 3, 3, 2], [1, 1, 2, 2], "azul relleno")
#  poligono([3, 4, 4, 3], [1, 1, 2, 2], "azul relleno")
#  poligono([6, 7, 7, 6], [1, 1, 2, 2], "azul relleno")
#  poligono([7, 8, 8, 7], [1, 1, 2, 2], "azul relleno")
#  poligono([8, 9, 9, 8], [1, 1, 2, 2], "azul relleno")
#  poligono([0, 1, 1, 0], [0, 0, 1, 1], "azul relleno")
#  poligono([2, 3, 3, 2], [0, 0, 1, 1], "azul relleno")
#  poligono([3, 4, 4, 3], [0, 0, 1, 1], "azul relleno")
#  poligono([6, 7, 7, 6], [0, 0, 1, 1], "azul relleno")
#  poligono([7, 8, 8, 7], [0, 0, 1, 1], "azul relleno")
#  poligono([8, 9, 9, 8], [0, 0, 1, 1], "azul relleno")
#  linea(0, 0, 9, 0, "fina")
#  linea(0, 0, 0, 9, "fina")
#  linea(0, 1, 9, 1, "fina")
#  linea(1, 0, 1, 9, "fina")
#  linea(0, 2, 9, 2, "fina")
#  linea(2, 0, 2, 9, "fina")
#  linea(0, 3, 9, 3, "fina")
#  linea(3, 0, 3, 9, "fina")
#  linea(0, 4, 9, 4, "fina")
#  linea(4, 0, 4, 9, "fina")
#  linea(0, 5, 9, 5, "fina")
#  linea(5, 0, 5, 9, "fina")
#  linea(0, 6, 9, 6, "fina")
#  linea(6, 0, 6, 9, "fina")
#  linea(0, 7, 9, 7, "fina")
#  linea(7, 0, 7, 9, "fina")
#  linea(0, 8, 9, 8, "fina")
#  linea(8, 0, 8, 9, "fina")
#  linea(0, 9, 9, 9, "fina")
#  linea(9, 0, 9, 9, "fina")
#  polilinea([0, 9, 9, 0, 0], [0, 0, 9, 9, 0], "gruesa")
#  texto(0.5, 9.5, "1", 2.6, "c")
#  texto(-0.3, 8.35, "1", 2.6, "d")
#  texto(1.5, 9.5, "2", 2.6, "c")
#  texto(-0.3, 7.35, "2", 2.6, "d")
#  texto(2.5, 9.5, "3", 2.6, "c")
#  texto(-0.3, 6.35, "3", 2.6, "d")
#  texto(3.5, 9.5, "4", 2.6, "c")
#  texto(-0.3, 5.35, "4", 2.6, "d")
#  texto(4.5, 9.5, "5", 2.6, "c")
#  texto(-0.3, 4.35, "5", 2.6, "d")
#  texto(5.5, 9.5, "6", 2.6, "c")
#  texto(-0.3, 3.35, "6", 2.6, "d")
#  texto(6.5, 9.5, "7", 2.6, "c")
#  texto(-0.3, 2.35, "7", 2.6, "d")
#  texto(7.5, 9.5, "8", 2.6, "c")
#  texto(-0.3, 1.35, "8", 2.6, "d")
#  texto(8.5, 9.5, "9", 2.6, "c")
#  texto(-0.3, 0.35, "9", 2.6, "d")
#  texto(10, 7.5, "orange: only element 1", 2.5, "i", estilo = "naranja")
#  texto(10, 6.5, "blue: only element 2", 2.5, "i", estilo = "azul")
#  texto(10, 5.5, "green: both (added)", 2.5, "i", estilo = "verde")
#  texto(10, 3.8, "empty: nodes that share", 2.4, "i")
#  texto(10, 3, "no element (K = 0)", 2.4, "i")
#fin
#: **The gravity load.** The weight distributes the force γ·∫Nᵢ dA to each node. In the reference triangle, with ∫∫ξᵃηᵇ dξdη = a!·b!/(a+b+2)!, the integral of each shape function comes out **zero at the corners and 1/6 at the midpoints**:
int_N1 = Simplify{2*(2/24) - 1/6}
int_N4 = Simplify{4*(1/24)}
#: (if N₁ = 2ξ² − ξ, then ∫N₁ = 2·(2/24) − 1/6 = 0; if N₄ = 4ξη, ∫N₄ = 4·(1/24) = 1/6). Multiplied by detJ and by γ, **each midpoint receives γ·detJ/6 downward** and the corners nothing: a curious consequence of second-degree elements. **Symbolic check:** the three midpoints, with W·detJ/6 each (W = unit weight), add up to W·detJ/2 = W·A, the weight of the element (A = area):
Pe_s = Simplify{3*W_m*dJ_m/6}
#: **Look at Figure 12:** where the weight goes. Each midpoint receives γ·detJ/6 = 24 kN and the corners zero; node 7, shared by the two elements, receives 48.
#dibujo("Figure 12. The gravity load distributed to the nodes: the T6 sends ALL the weight to the midpoints (the corners receive nothing)", ud = m, ancho = 200, alto = 120)
#  poligono([0, 4, 4], [0, 0, 2], "verde tenue")
#  poligono([0, 4, 0], [0, 2, 2], "azul tenue")
#  polilinea([0, 4, 4, 0, 0], [0, 0, 2, 2, 0], "gruesa")
#  linea(0, 0, 4, 2, "media")
#  achurado(-0.6, -0.45, 5.2, 0.45, "ground")
#  circulo(2, 0, 0.07, "negro relleno")
#  flecha(2, 0.475, 2, 0.05, "rojo")
#  texto(2.12, 0.275, "24 kN", 2.7, "i", estilo = "rojo")
#  circulo(4, 1, 0.07, "negro relleno")
#  flecha(4, 1.475, 4, 1.05, "rojo")
#  texto(4.12, 1.275, "24 kN", 2.7, "i", estilo = "rojo")
#  circulo(2, 1, 0.07, "negro relleno")
#  flecha(2, 1.95, 2, 1.05, "rojo")
#  texto(2.12, 1.55, "48 kN", 2.7, "i", estilo = "rojo")
#  circulo(2, 2, 0.07, "negro relleno")
#  flecha(2, 2.475, 2, 2.05, "rojo")
#  texto(2.12, 2.275, "24 kN", 2.7, "i", estilo = "rojo")
#  circulo(0, 1, 0.07, "negro relleno")
#  flecha(0, 1.475, 0, 1.05, "rojo")
#  texto(0.12, 1.275, "24 kN", 2.7, "i", estilo = "rojo")
#  circulo(0, 0, 0.06, "negro relleno")
#  circulo(4, 0, 0.06, "negro relleno")
#  circulo(4, 2, 0.06, "negro relleno")
#  circulo(0, 2, 0.06, "negro relleno")
#  texto(2, -1, "corners: 0 kN  ·  midpoints: γ·detJ/6 = 18·8/6 = 24 kN  ·  node 7 (shared): 48 kN", 2.4, "c")
#  texto(2, 3.1, "sum = 24·4 + 48 = 144 kN = γ·Lx·Ly", 2.8, "c", estilo = "rojo")
#fin
#: With numbers. A loop runs over the elements, builds their Xe, computes their stiffness and their load, and adds them:
#hide
K = zeros(n_d, n_d)
F = zeros(n_d, 1)
for e = 1:n_e
  for a = 1:6
    Xe(a, 1) = x_j(e_j(e, a))
    Xe(a, 2) = y_j(e_j(e, a))
  end
  g = zeros(1, 12)
  for a = 1:6
    g(2*a - 1) = 2*e_j(e, a) - 1
    g(2*a) = 2*e_j(e, a)
  end
  Ke = zeros(12, 12)
  Fe = zeros(12, 1)
  for q = 1:7
    Ke = Ke + wg(q)*kq(xg(q), yg(q))
    Nv = Nq(xg(q), yg(q))
    for a = 1:6
      Fe(2*a) = Fe(2*a) - γ*wg(q)*dJq(xg(q), yg(q))*Nv(a)
    end
  end
  K(g, g) = K(g, g) + Ke
  F(g) = F(g) + Fe
end
#show
#: Global load vector (kN). Nodes 5, 6, 8 and 9 (midpoints of a single element) receive −24 kN and node 7 (midpoint of the diagonal, shared by the two) receives **−48 kN**. The sum is the total weight of the block, W = γ·B·H = 18·4·2 = 144 kN:
#hide
F_r = zeros(n_d, 1)
for i = 1:n_d
  F_r(i) = round(F(i)*1000000)/1000000
end
#show
F_r [kN]
peso_total = -(F(6) + F(10) + F(12) + F(14) + F(16) + F(18)) [kN]
W = γ*B*H [kN]

## 10 · Supports and solution
#: In symbols. With the fixed degrees of freedom (u = 0) the equilibrium equations K·u = F reduce to those of the **free** ones: K_{ff}·u_{f} = F_{f}. K_{ff} is symmetric and positive definite (if the support prevents rigid-body motion), so it is solved by Cholesky.
#: With letters, a system of 2 unknowns, [m₁₁ m₁₂; m₁₂ m₂₂]·[u₁; u₂] = [f₁; f₂]. The solution (Cramer's rule) and the check that it satisfies the first equation:
u1_s = Simplify{(m22*f1 - m12*f2)/(m11*m22 - m12^2)}
u2_s = Simplify{(m11*f2 - m12*f1)/(m11*m22 - m12^2)}
chk_s = Simplify{m11*(m22*f1 - m12*f2)/(m11*m22 - m12^2) + m12*(m11*f2 - m12*f1)/(m11*m22 - m12^2) - f1}
#: (the symbolic result of the check is zero). The engine does the same with 12 unknowns, or with thousands in a real mesh, factoring the banded matrix instead of using Cramer.
#: With numbers. The fixed degrees are those of nodes 1, 2 and 5 (the base): 1, 2, 3, 4, 9 and 10.
i_fix = [1; 2; 3; 4; 9; 10]
#hide
fijo = zeros(n_d, 1)
for i = 1:6
  k_f = i_fix(i)
  fijo(k_f) = 1
end
lib = zeros(12, 1)
k_l = 0
for i = 1:n_d
  if fijo(i) == 0
    k_l = k_l + 1
    lib(k_l) = i
  end
end
#show
lib
Kff = K(lib, lib)
Ff = F(lib)
uf = lsolve(Kff, Ff)
#: The displacements are returned to the 18 degrees of freedom and shown per node (**u** and **v** in mm):
#hide
u = zeros(n_d, 1)
for i = 1:12
  u(lib(i)) = uf(i)
end
U_n = zeros(n_j, 2)
for j = 1:n_j
  U_n(j, 1) = u(2*j - 1)*1000
  U_n(j, 2) = u(2*j)*1000
end
#show
U_n [mm]
#: **Look at Figure 13:** the result in a drawing. The block settles (v < 0) and its upper corners spread apart due to the Poisson effect; the base does not move.
#dibujo("Figure 13. The solution K·u = F: deformed mesh (magnified 400 times) against the original", ud = m, ancho = 200, alto = 109)
#  polilinea([0, 2, 4, 4, 4, 2, 0, 0, 0], [0, 0, 0, 1, 2, 2, 2, 1, 0], "media trazos azul")
#  linea(0, 0, 4, 2, "fina trazos")
#  polilinea([0, 2, 4, 4.1557, 4.1412, 1.989, -0.1642, -0.171, 0], [0, 0, 0, 0.5811, 1.3921, 1.4163, 1.388, 0.5487, 0], "gruesa rojo")
#  polilinea([0, 1.9969, 4.1412], [0, 0.5872, 1.3921], "media rojo")
#  achurado(-0.6, -0.45, 5.2, 0.45, "ground")
#  circulo(0, 0, 0.05, "rojo relleno")
#  circulo(4, 0, 0.05, "rojo relleno")
#  circulo(4.1412, 1.3921, 0.05, "rojo relleno")
#  circulo(-0.1642, 1.388, 0.05, "rojo relleno")
#  circulo(2, 0, 0.05, "rojo relleno")
#  circulo(4.1557, 0.5811, 0.05, "rojo relleno")
#  circulo(1.9969, 0.5872, 0.05, "rojo relleno")
#  circulo(1.989, 1.4163, 0.05, "rojo relleno")
#  circulo(-0.171, 0.5487, 0.05, "rojo relleno")
#  texto(4.2912, 1.4421, "3: u = 0.353, v = −1.520 mm", 2.4, "i", estilo = "rojo")
#  texto(-0.3142, 1.438, "4: u = −0.411, v = −1.530 mm", 2.4, "d", estilo = "rojo")
#  texto(2, -1, "displacements ×400 (1 mm real is drawn as 0.4 m); dashed, the undeformed mesh", 2.5, "c")
#  texto(2, 3.3, "the base does not move; the block settles and the corners open (Poisson effect)", 2.5, "c")
#fin
#: **Comparison with the Hekatan Geotechnic solver** (same block, same model): node 3, upper right corner, u = 0.353110519 mm and v = −1.519685519 mm. The difference must be numerical noise:
ref_u3 = [0.353110519; -1.519685519] [mm]
dif_u3 = [U_n(3, 1) - ref_u3(1); U_n(3, 2) - ref_u3(2)] [mm]
#: **Reactions.** R = K·u − F at the fixed degrees of freedom; the sum of the vertical reactions must equal the weight:
Rn = K*u - F
suma_Ry = Rn(2) + Rn(4) + Rn(10) [kN]

## 11 · Stresses at the Gauss points
#: In symbols. At each Gauss point, ε = B·u_{e} and σ = D·ε. The stresses are **not continuous** between elements (the T6 only guarantees continuity of displacements); that is why the engine evaluates and stores them **at the Gauss points**, where the approximation is most accurate.
#: σ_{q} = D · [ε_{x}; ε_{y}; 0; γ_{xy}]_{q}  with  ε_{q} = B(ξ_{q}, η_{q}) · u_{e}
#: Multiplying D by the strains, component by component:
sx_s = Expand{(lm + 2*Gm)*ex + lm*ey}
sy_s = Expand{lm*ex + (lm + 2*Gm)*ey}
sz_s = Expand{lm*(ex + ey)}
tau_s = Expand{Gm*gxy}
#: **σ_{z}** does not come from any displacement (ε_{z} = 0) but it does have a value. With the Lamé constants in terms of E and ν, **σ_{z} = ν·(σ_{x} + σ_{y})** holds (the difference is zero):
sz_dif = Simplify{E_m*ν_m/((1 + ν_m)*(1 - 2*ν_m))*(ex + ey) - ν_m*((E_m*ν_m/((1 + ν_m)*(1 - 2*ν_m)) + 2*E_m/(2*(1 + ν_m)))*ex + E_m*ν_m/((1 + ν_m)*(1 - 2*ν_m))*ey + E_m*ν_m/((1 + ν_m)*(1 - 2*ν_m))*ex + (E_m*ν_m/((1 + ν_m)*(1 - 2*ν_m)) + 2*E_m/(2*(1 + ν_m)))*ey)}
#: With numbers:
#: With numbers. A loop runs over the 14 points (7 per element) and stores [σ_{x}, σ_{y}, σ_{z}, τ_{xy}] in kPa (compression negative):
#hide
S = zeros(14, 4)
for e = 1:n_e
  for a = 1:6
    Xe(a, 1) = x_j(e_j(e, a))
    Xe(a, 2) = y_j(e_j(e, a))
  end
  g = zeros(1, 12)
  for a = 1:6
    g(2*a - 1) = 2*e_j(e, a) - 1
    g(2*a) = 2*e_j(e, a)
  end
  ue = u(g)
  for q = 1:7
    de_x = Bx_q(xg(q), yg(q))*ue
    de_y = By_q(xg(q), yg(q))*ue
    dg_xy = Bg_q(xg(q), yg(q))*ue
    ex1 = de_x(1, 1)
    ey1 = de_y(1, 1)
    gg1 = dg_xy(1, 1)
    r_s = 7*(e - 1) + q
    S(r_s, 1) = D(1, 1)*ex1 + D(1, 2)*ey1
    S(r_s, 2) = D(2, 1)*ex1 + D(2, 2)*ey1
    S(r_s, 3) = D(3, 1)*ex1 + D(3, 2)*ey1
    S(r_s, 4) = D(4, 4)*gg1
  end
end
#show
S [kPa]
#: **Look at Figure 14:** the vertical stresses σy of table S, placed at the position of each Gauss point. They grow with depth (σy ≈ −γ·z).
#dibujo("Figure 14. The vertical stresses σy at the 14 Gauss points, where the engine stores and evaluates the plasticity", ud = m, ancho = 200, alto = 102)
#  poligono([0, 4, 4], [0, 0, 2], "verde tenue")
#  poligono([0, 4, 0], [0, 2, 2], "azul tenue")
#  polilinea([0, 4, 4, 0, 0], [0, 0, 2, 2, 0], "gruesa")
#  linea(0, 0, 4, 2, "media")
#  achurado(-0.6, -0.45, 5.2, 0.45, "ground")
#  circulo(2.6667, 0.6667, 0.05, "azul relleno")
#  texto(2.7467, 0.5067, "-23.8", 1.9, "i")
#  circulo(1.3333, 1.3333, 0.05, "azul relleno")
#  texto(1.4133, 1.1733, "-12.2", 1.9, "i")
#  circulo(3.5949, 1.5949, 0.05, "rojo relleno")
#  texto(3.6749, 1.4349, "-7.5", 1.9, "i")
#  circulo(0.4051, 1.7974, 0.05, "rojo relleno")
#  texto(0.4851, 1.6374, "-2.9", 1.9, "i")
#  circulo(0.8103, 0.2026, 0.05, "azul relleno")
#  texto(0.8903, 0.0426, "-31.7", 1.9, "i")
#  circulo(0.4051, 0.4051, 0.05, "azul relleno")
#  texto(0.4851, 0.2451, "-29.8", 1.9, "i")
#  circulo(3.5949, 0.2026, 0.05, "azul relleno")
#  texto(3.6749, 0.0426, "-32.3", 1.9, "i")
#  circulo(3.1897, 1.7974, 0.05, "rojo relleno")
#  texto(3.2697, 1.6374, "-3.9", 1.9, "i")
#  circulo(2.1194, 0.1194, 0.05, "azul relleno")
#  texto(2.1994, -0.0406, "-33.4", 1.9, "i")
#  circulo(1.8806, 1.0597, 0.05, "azul relleno")
#  texto(1.9606, 0.8997, "-17.7", 1.9, "i")
#  circulo(3.7611, 0.9403, 0.05, "azul relleno")
#  texto(3.8411, 0.7803, "-19.2", 1.9, "i")
#  circulo(1.8806, 1.8806, 0.05, "rojo relleno")
#  texto(1.9606, 1.7206, "-1.8", 1.9, "i")
#  circulo(2.1194, 0.9403, 0.05, "azul relleno")
#  texto(2.1994, 0.7803, "-18.8", 1.9, "i")
#  circulo(0.2389, 1.0597, 0.05, "azul relleno")
#  texto(0.3189, 0.8997, "-17.1", 1.9, "i")
#  texto(2, -1, "σy in kPa (compression negative): it grows with depth, like the weight γ·z; red = little compression, blue = a lot", 2.4, "c")
#  texto(2, 2.45, "14 Gauss points (7 per element): the stresses are NOT continuous between elements", 2.6, "c")
#fin
#: **Comparison with the real solver**, point 3 of element 2 (row 10): σ = (−7.915809, −29.819866, −11.320703, −3.091447) kPa.
ref_S10 = [-7.915809, -29.819866, -11.320703, -3.091447] [kPa]
dif_S10 = [S(10, 1) - ref_S10(1), S(10, 2) - ref_S10(2), S(10, 3) - ref_S10(3), S(10, 4) - ref_S10(4)] [kPa]

## 12 · Mohr-Coulomb plasticity at a Gauss point
#: In symbols. The soil cannot withstand any stress: the **Mohr-Coulomb** criterion sets the limit in terms of the principal stresses σ₁ ≥ σ₂ ≥ σ₃ (tension positive). With the center p = (σ₁+σ₃)/2 and the radius R = (σ₁−σ₃)/2 of the largest Mohr circle, the yield function is:
f_s = Simplify{(σ_1 - σ_3)/2 + (σ_1 + σ_3)/2*sin(φ_m) - c_m*cos(φ_m)}
#: **Look at Figure 15:** the function f is a distance in the Mohr plane: the stress circle against the failure line τ = c − σ·tanφ.
#dibujo("Figure 15. The Mohr-Coulomb criterion in the Mohr plane: the envelope τ = c − σ·tanφ and the largest circle (center p, radius R) of a stress state", ud = kPa, ancho = 200, alto = 117)
#  flecha(-44, 0, 9, 0, "negro")
#  texto(9.4, 0, "σ", 3.4, "i")
#  flecha(0, -16.5, 0, 17, "negro")
#  texto(0, 17.8, "τ", 3.4, "c")
#  polilinea([4.289, -30], [0, 15.9892], "gruesa rojo")
#  polilinea([4.289, -30], [0, -15.9892], "gruesa rojo")
#  circulo(-18.8678, 0, 11.3804, "media azul")
#  circulo(-18.8678, 0, 0.35, "azul relleno")
#  texto(-18.8678, -1.9, "p", 3, "c", estilo = "azul")
#  linea(-18.8678, 0, -11.5527, 8.7179, "media azul")
#  texto(-15.2678, 5.4, "R", 3, "i", estilo = "azul")
#  texto(-30.6482, -1.9, "σ₃", 3, "d")
#  texto(-7.0875, -1.9, "σ₁", 3, "i")
#  texto(0.8, 3.3, "c", 3, "i", estilo = "rojo")
#  circulo(0, 2, 0.3, "rojo relleno")
#  texto(1.3, 14.2, "failure line:", 2.8, "i", estilo = "rojo")
#  texto(1.3, 12.6, "τ = c − σ·tanφ", 2.8, "i", estilo = "rojo")
#  texto(-12, -10.5, "f = R + p·senφ − c·cosφ", 3.2, "i", estilo = "azul")
#  texto(-12, -12.4, "f < 0: the circle is below the line (the soil resists)", 2.6, "i")
#  texto(-12, -14, "f = 0: the circle touches the line (the strength is reached)", 2.6, "i")
#  texto(-12, -15.6, "f > 0: the circle crosses it (the state cannot exist)", 2.6, "i", estilo = "rojo")
#fin
#: **f ≤ 0:** the point is elastic. **f > 0:** the point cannot exist (the limit was exceeded) and must be **returned** to the surface. The engine does it with a **plastic correction**: σ' = σ_{trial} − Δλ·D·g, where g is the direction of the plastic flow (ψ = dilatancy angle) and Δλ the multiplier. For f(σ') = 0, since f is linear in σ with gradient n, **Δλ = f / (nᵀ·D·g)** is needed:
#: n = [½(1+senφ), 0, ½(senφ−1)],   g = [½(1+senψ), 0, ½(senψ−1)]   (in the order σ₁, σ₂, σ₃)
an_s = (1 + sin(φ_m))/2
bn_s = (sin(φ_m) - 1)/2
ag_s = (1 + sin(ψ_m))/2
bg_s = (sin(ψ_m) - 1)/2
den_s = Simplify{an_s*ag_s*(λ_m + 2*G_m) + bn_s*bg_s*(λ_m + 2*G_m) + (an_s*bg_s + bn_s*ag_s)*λ_m}
#: **Symbolic check:** after the correction, f(σ') = f − Δλ·(nᵀDg) = f − (f/den)·den = 0.
f_despues = Simplify{f_0 - (f_0/den_m)*den_m}
#: With numbers. The point with the largest excess is taken (element 2, point 3, row 10 of the table). Its in-plane principal stresses come from the Mohr circle, and the third is σ_{z}:
sx = S(10, 1)
sy = S(10, 2)
sz = S(10, 3)
txy = S(10, 4)
cen = (sx + sy)/2
Rr = sqrt(((sx - sy)/2)^2 + txy^2)
s_a = cen + Rr
s_b = cen - Rr
#: The order is σ₁ = s_a, σ₂ = σ_{z}, σ₃ = s_b (verifiable in the values). With φ = 25° and c = 2 kPa:
psi = 0 'zero dilatancy
sp = sin(phi)
cc = c*cos(phi)
s1 = s_a
s2 = sz
s3 = s_b
f_prueba = (s1 - s3)/2 + (s1 + s3)/2*sp - cc [kPa]
#: f > 0: **the point is outside the surface** (by pure elasticity). Return to the σ₁-σ₃ face, with D in principal axes and the flow direction g:
Dp = [lam + 2*G, lam, lam; lam, lam + 2*G, lam; lam, lam, lam + 2*G]
n1 = [(1 + sp)/2; 0; (sp - 1)/2]
g1 = [(1 + sin(psi))/2; 0; (sin(psi) - 1)/2]
den = transpose(n1)*Dp*g1
dlam = f_prueba/den(1, 1) 'plastic multiplier
sret = [s1; s2; s3] - dlam*Dp*g1
f_ret = (sret(1) - sret(3))/2 + (sret(1) + sret(3))/2*sp - cc [kPa]
#: f(σ') ≈ 0: the point returned to the surface. **Validity:** the other two functions (faces σ₂-σ₃ and σ₁-σ₂) must be ≤ 0, otherwise the return would go to an edge or to the vertex:
f_23 = (sret(2) - sret(3))/2 + (sret(2) + sret(3))/2*sp - cc [kPa]
f_12 = (sret(1) - sret(2))/2 + (sret(1) + sret(2))/2*sp - cc [kPa]
#: **Look at Figures 16 and 17:** the same return that was just computed, drawn in the Mohr plane and in the principal stress plane.
#dibujo("Figure 16. The plastic return of point 10 with numbers: the trial circle (dashed) crosses the envelope; the return shrinks it until it is tangent", ud = kPa, ancho = 200, alto = 117)
#  flecha(-44, 0, 9, 0, "negro")
#  texto(9.4, 0, "σ", 3.4, "i")
#  flecha(0, -16.5, 0, 17, "negro")
#  texto(0, 17.8, "τ", 3.4, "c")
#  polilinea([4.289, -30], [0, 15.9892], "gruesa rojo")
#  polilinea([4.289, -30], [0, -15.9892], "gruesa rojo")
#  circulo(-18.8678, 0, 11.3804, "media trazos rojo")
#  circulo(-18.8678, 0, 9.7865, "gruesa verde")
#  circulo(-9.4041, 0, 1.9166, "fina trazos rojo")
#  circulo(-20.7845, 0, 9.4638, "fina trazos rojo")
#  circulo(-7.4875, 0, 0.3, "rojo relleno")
#  circulo(-11.3207, 0, 0.3, "rojo relleno")
#  circulo(-30.2482, 0, 0.3, "rojo relleno")
#  circulo(-9.0813, 0, 0.3, "verde relleno")
#  circulo(-28.6543, 0, 0.3, "verde relleno")
#  texto(-30.7482, -2.3, "σ₃ = −30.25", 2.5, "d", estilo = "rojo")
#  texto(-6.9875, -2.3, "σ₁ = −7.49", 2.5, "i", estilo = "rojo")
#  texto(-11.3207, -4.6, "σ₂ = σz = −11.32", 2.5, "c", estilo = "rojo")
#  texto(-20.8678, 13.6, "trial (dashed): f = +1.593 kPa", 2.7, "c", estilo = "rojo")
#  texto(-18.8678, -13.2, "returned (green): f = 0, tangent to the line", 2.8, "c", estilo = "verde")
#  texto(-43, -7.5, "σ₁' = −9.08;  σ₃' = −28.65;  σ₂' = −11.32 (does not change: ψ = 0)", 2.6, "i", estilo = "verde")
#  texto(-43, -9.4, "Δλ = f / (nᵀ·D·g) = 2.07·10⁻⁴", 2.6, "i")
#  texto(1.3, 14.2, "failure line:", 2.8, "i", estilo = "rojo")
#  texto(1.3, 12.6, "τ = c − σ·tanφ", 2.8, "i", estilo = "rojo")
#fin
#dibujo("Figure 17. The return in the principal stress plane (σ₁, σ₃): it moves in the direction −D·g until the yield surface", ud = kPa, ancho = 200, alto = 150)
#  flecha(-12, -35, -4.5, -35, "negro")
#  texto(-4.2, -35, "σ₁", 3, "i")
#  flecha(-12, -35, -12, -21.5, "negro")
#  texto(-12, -20.6, "σ₃", 3, "c")
#  polilinea([-11.4, -6.6], [-34.3673, -22.5406], "gruesa rojo")
#  texto(-6.2, -22.3406, "f = 0 (face σ₁–σ₃)", 2.6, "i", estilo = "rojo")
#  circulo(-7.4875, -30.2482, 0.12, "rojo relleno")
#  texto(-7.1875, -30.6482, "trial (−7.49; −30.25)", 2.5, "i", estilo = "rojo")
#  circulo(-9.0813, -28.6543, 0.12, "verde relleno")
#  texto(-9.3813, -28.3543, "returned (−9.08; −28.65)", 2.5, "d", estilo = "verde")
#  flecha(-7.4875, -30.2482, -9.0013, -28.7343, "negro")
#  texto(-11.7, -23, "Δσ = −Δλ·D·g, with g = [½, 0, −½]", 2.5, "i")
#  texto(-11.7, -24.2, "D·g = G·[1, 0, −1]: lowers σ₁ and raises σ₃ by the same amount", 2.5, "i")
#fin
#: The principal stresses are rotated back to the x, y axes with the same angle (2θ = atan2(2·τ_{xy}, σ_{x} − σ_{y})):
t2 = atan2(2*txy, sx - sy)
cen2 = (sret(1) + sret(3))/2
R2 = (sret(1) - sret(3))/2
s_dev = [cen2 + R2*cos(t2); cen2 - R2*cos(t2); sret(2); R2*sin(t2)] [kPa]
#: **Comparison with the real solver** (Mohr-Coulomb return of Hekatan Geotechnic with the same trial stresses): σ' = (−9.44935831, −28.28631697, −11.32070259, −2.65856958) kPa.
ref_sdev = [-9.44935831; -28.28631697; -11.32070259; -2.65856958] [kPa]
dif_sdev = [s_dev(1) - ref_sdev(1); s_dev(2) - ref_sdev(2); s_dev(3) - ref_sdev(3); s_dev(4) - ref_sdev(4)] [kPa]

## 13 · Strength reduction: the safety factor
#: In symbols. The **safety factor** of a slope is the number F by which the soil strength must be divided for the slope to **just** stop being stable: c_{F} = c/SRF  and  tanφ_{F} = tanφ/SRF. For a single Gauss point, with fixed stresses (σ₁, σ₃), the F that brings it to yield comes out in **closed form**. With t = tanφ, the trigonometric ratios of the reduced angle are senφ_{F} = t/√(SRF²+t²) and cosφ_{F} = SRF/√(SRF²+t²), and the yield function simplifies to:
fF_s = Simplify{R_m + (p_m*t_m - c_m)/sqrt(SRF^2 + t_m^2)}
#: **Look at Figure 18:** as SRF increases the failure line drops and flattens; the SRF at which it touches the circle is the safety factor of the point.
#dibujo("Figure 18. Strength reduction at a point: dividing c and tanφ by SRF the envelope drops until it touches the circle; that SRF is the safety factor of the point", ud = kPa, ancho = 200, alto = 127)
#  flecha(-14, 0, 14, 0, "negro")
#  texto(14.4, 0, "σ", 3.4, "i")
#  flecha(0, -10, 0, 20, "negro")
#  texto(0, 20.8, "τ", 3.4, "c")
#  circulo(-1.8858, 0, 5.7741, "gruesa azul")
#  texto(-1.8858, -1.9, "circle of the point", 2.6, "c", estilo = "azul")
#  texto(-1.8858, -3.5, "(fixed stresses)", 2.4, "c", estilo = "azul")
#  polilinea([13.8564, -13], [0, 15.5056], "media verde")
#  texto(-13.3, 15.9056, "SRF = 1 (real strength)", 2.6, "d", estilo = "verde")
#  polilinea([13.8564, -13], [0, 12.4044], "media naranja")
#  texto(-13.3, 12.8044, "SRF = 1.25", 2.6, "d", estilo = "naranja")
#  polilinea([13.8564, -13], [0, 10.5886], "gruesa rojo")
#  texto(-13.3, 10.9886, "SRF = 1.464: touches the circle", 2.6, "d", estilo = "rojo")
#  texto(-13, -7, "c_F = c/SRF  and  tanφ_F = tanφ/SRF:", 2.6, "i")
#  texto(-13, -8.7, "as SRF increases the line drops and flattens", 2.6, "i")
#fin
#: Setting it to zero, the factor is solved:  √(SRF² + t²) = (c − p·t)/R   →   **SRF = √( ((c − p·t)/R)² − t² )**.
F_s = Simplify{sqrt(((c_m - p_m*t_m)/R_m)^2 - t_m^2)}
#: With numbers. To see a factor greater than 1, a stronger soil is used, c = 8 kPa and φ = 30°. At each of the 14 points (with the elastic stresses of table S) R, p and F are computed:
c_s = 8 [kPa]
t_s = tan(30*pi/180)
#hide
Fpt = zeros(14, 1)
Rcv = zeros(14, 1)
pcv = zeros(14, 1)
for i = 1:14
  cen_i = (S(i, 1) + S(i, 2))/2
  R_i = sqrt(((S(i, 1) - S(i, 2))/2)^2 + S(i, 4)^2)
  sa_i = cen_i + R_i
  sb_i = cen_i - R_i
  smax = max(max(sa_i, sb_i), S(i, 3))
  smin = min(min(sa_i, sb_i), S(i, 3))
  Rc = (smax - smin)/2
  pc = (smax + smin)/2
  Rcv(i) = Rc
  pcv(i) = pc
  Fpt(i) = sqrt(((c_s - pc*t_s)/Rc)^2 - t_s^2)
end
#show
Fpt
F_min = min(min(min(Fpt(1), Fpt(2)), min(Fpt(3), Fpt(4))), min(min(Fpt(5), Fpt(6)), min(Fpt(7), Fpt(8))))
F_min2 = min(min(min(Fpt(9), Fpt(10)), min(Fpt(11), Fpt(12))), min(Fpt(13), Fpt(14)))
F_punto = min(F_min, F_min2) 'the first point to yield, with the elastic stresses
#: **The function f(SRF)** of point 2 with the data of this sheet: it crosses zero exactly at SRF = 1.464, the safety factor of that point:
#fplot(f_SRF = 5.77407 + (-1.88579*0.57735 - 8.0)/sqrt(x^2 + 0.33333), cero = 0*x, [0.6 3])
#: **Check of the closed formula** at point 2: with the strength reduced by its factor, the yield function must be zero:
F_2 = Fpt(2)
f_chk = Rcv(2) + pcv(2)*sin(atan(t_s/F_2)) - (c_s/F_2)*cos(atan(t_s/F_2)) [kPa]
#: That is only a **local indicator**: it says when the first point starts to yield, with the elastic stresses. But the real safety factor is the F at which **the whole system loses equilibrium**: when a point yields, its stresses are passed on to its neighbors and the block holds more. That is why the engine does not stop at this number: it **reduces the strength in steps (F = 1, 1.1, 1.2, …) and at each step solves the complete nonlinear problem**; the last F that converges is the safety factor.
#: For this 2-element block, with c = 8 kPa and φ = 30°, **the Hekatan Geotechnic solver gives FS = 1.9299** (the full SRM, 7 steps), greater than the local indicator, as expected from the redistribution:
FS_solver = 1.929925
reserva = FS_solver/F_punto 'how much more the system holds than the first point

## 14 · What the engine adds to this
#: Everything above is **the same code** that runs in each element of the engine; what changes with a mesh of hundreds of elements is only the size of the matrix (banded with reverse Cuthill-McKee) and that the plasticity enters in a Newton-Raphson loop. This is what is added and it is **checked against GEO5 2024**:
#: **Look at Figure 19:** the complete strength reduction loop, with Newton-Raphson inside each step.
#dibujo("Figure 19. The strength reduction loop in Geotechnic: Newton-Raphson inside each step, and the highest SRF step that converges is the safety factor", ud = , ancho = 200, alto = 117)
#  poligono([0, 6, 6, 0], [8, 8, 9.2, 9.2], "azul tenue")
#  polilinea([0, 6, 6, 0, 0], [8, 8, 9.2, 9.2, 8], "media")
#  texto(3, 8.48, "SRF = 1; σ = self weight", 2.4, "c")
#  poligono([0, 6, 6, 0], [6, 6, 7.2, 7.2], "azul tenue")
#  polilinea([0, 6, 6, 0, 0], [6, 6, 7.2, 7.2, 6], "media")
#  texto(3, 6.48, "c_F = c/SRF; tanφ_F = tanφ/SRF", 2.4, "c")
#  poligono([0, 6, 6, 0], [4, 4, 5.2, 5.2], "azul tenue")
#  polilinea([0, 6, 6, 0, 0], [4, 4, 5.2, 5.2, 4], "media")
#  texto(3, 4.48, "Newton iteration: K with the tangent", 2.4, "c")
#  poligono([0, 6, 6, 0], [2, 2, 3.2, 3.2], "azul tenue")
#  polilinea([0, 6, 6, 0, 0], [2, 2, 3.2, 3.2, 2], "media")
#  texto(3, 2.48, "du = −K⁻¹·R; line search η", 2.4, "c")
#  poligono([0, 6, 6, 0], [0, 0, 1.2, 1.2], "azul tenue")
#  polilinea([0, 6, 6, 0, 0], [0, 0, 1.2, 1.2, 0], "media")
#  texto(3, 0.48, "σ ← Mohr-Coulomb return; new R", 2.4, "c")
#  flecha(3, 8, 3, 7.25, "negro")
#  flecha(3, 6, 3, 5.25, "negro")
#  flecha(3, 4, 3, 3.25, "negro")
#  flecha(3, 2, 3, 1.25, "negro")
#  poligono([8.5, 14, 14, 8.5], [0, 0, 1.2, 1.2], "naranja tenue")
#  polilinea([8.5, 14, 14, 8.5, 8.5], [0, 0, 1.2, 1.2, 0], "media")
#  texto(11.25, 0.48, "|R| < tolerance ?", 2.4, "c")
#  flecha(6, 0.6, 8.5, 0.6, "negro")
#  texto(7.25, 0.9, "", 2, "c")
#  poligono([8.5, 14, 14, 8.5], [3, 3, 4.4, 4.4], "verde tenue")
#  polilinea([8.5, 14, 14, 8.5, 8.5], [3, 3, 4.4, 4.4, 3], "media")
#  texto(11.25, 3.58, "yes: converges → store and raise SRF", 2.4, "c")
#  flecha(11.25, 1.2, 11.25, 3, "negro")
#  texto(11.9, 1.9, "sí", 2.4, "i")
#  polilinea([8.5, 7, 7], [0.6, 0.6, 3.6], "media negro")
#  flecha(7, 3.6, 6, 4.6, "negro")
#  texto(7.4, 1.8, "no", 2.4, "i")
#  poligono([8.5, 14, 14, 8.5], [6, 6, 7.4, 7.4], "rojo tenue")
#  polilinea([8.5, 14, 14, 8.5, 8.5], [6, 6, 7.4, 7.4, 6], "media")
#  texto(11.25, 6.58, "does not converge → FS = last SRF that converged", 2.4, "c")
#  polilinea([14, 14.6, 14.6], [3.7, 3.7, 6.7], "media negro")
#  flecha(14.6, 6.7, 14, 6.7, "negro")
#  texto(14.75, 5.2, "if it diverges", 2.4, "i")
#  polilinea([8.5, 8, 8], [3.7, 3.7, 6.6], "media negro")
#  flecha(8, 6.6, 6, 6.6, "negro")
#fin
#: **1. Newton-Raphson with algorithmic tangent.** When a point yields, its stiffness is no longer D, but the **tangent** D − (D·g)(nᵀD)/(nᵀDg), which is not symmetric. Each iteration rebuilds K with those tangents and corrects the displacements until the residual (F − internal forces) is zero. In the GEO5 dynamics, the tangent of the first iteration of each step is elastic.
#: **2. Multisurface return.** The Mohr-Coulomb criterion is a hexagonal pyramid: besides the face (this sheet), there are **edges** and a **vertex** (apex). The yield tolerance is **absolute**, 10⁻³ kPa.
#: **3. Line search.** If a Newton step increases the residual, it is shortened by a factor η. GEO5 computes it with frozen inertia and a single secant: η ← η·e₀/(e₀−e₁).
#: **4. Dynamics.** With consistent mass M = ∫ρ·NᵀN dA, the HHT-α method and Rayleigh damping, the same T6 responds to an earthquake at the base. Compared with GEO5 2024 running: relative error of **3.9 × 10⁻⁷** in the displacements of an 8-T6 mesh with plasticity, 16 steps.
#: **Summary of what was checked in this sheet against the real solver:** displacements of node 3 (difference ≈ 10⁻¹⁰ mm), stresses of point 10 (≈ 10⁻⁷ kPa), Mohr-Coulomb return (≈ 10⁻⁹ kPa), reactions = weight, and the SRF safety factor.
