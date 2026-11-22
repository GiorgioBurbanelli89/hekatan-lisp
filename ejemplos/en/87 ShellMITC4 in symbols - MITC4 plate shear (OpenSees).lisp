# OpenSees ShellMITC4 in symbols: MITC4 shear, membrane and in-plane rotation
#numerico

#: This is the **ShellMITC4** element: the **plate** part (MITC4 shear), the **membrane** and the **in-plane rotation** of OpenSees (ShellMITC4.cpp, getInitialStiff and computeBasis; sheet 72 translates it with numbers). Here the engine does the derivation with symbols, with a rectangle of sides **2a × 2b** and the four nodes in the OpenSees order. Each node carries three plate degrees of freedom: the deflection w and the rotations θx and θy.
#: **Sheet convention:** rotations with the right-hand rule, so the shear is γxz = ∂w/∂x + θy and γyz = ∂w/∂y − θx. It is VERIFIED against OpenSees 3.7.1 running (K of one element, rotations rx and ry): with these signs the shear agrees to 2.5e-9; with any other combination of signs the error is 0.2 to 2.4.
#: **Why MITC4.** If the shear is calculated with the shape functions as they are, the thin slab becomes too stiff (shear locking). MITC4 measures γ only at four tying points and interpolates it with (1 ± ξ) and (1 ± η).

## 1 · Shape functions and their derivatives
#: The four bilinear functions of the reference quadrilateral, and their derivatives already converted to x and y (the Jacobian of the rectangle is diagonal: dx = a·dξ, dy = b·dη).
N_1 = Expand{(1-xi)*(1-eta)/4}
N_2 = Expand{(1+xi)*(1-eta)/4}
N_3 = Expand{(1+xi)*(1+eta)/4}
N_4 = Expand{(1-xi)*(1+eta)/4}
Jm = Simplify{[Partial{a*xi @ xi}, Partial{a*xi @ eta}; Partial{b*eta @ xi}, Partial{b*eta @ eta}]}
Dj = Simplify{det(Jm)}
dNx = Simplify{[Partial{(1-xi)*(1-eta)/4 @ xi}/a, Partial{(1+xi)*(1-eta)/4 @ xi}/a, Partial{(1+xi)*(1+eta)/4 @ xi}/a, Partial{(1-xi)*(1+eta)/4 @ xi}/a]}
dNy = Simplify{[Partial{(1-xi)*(1-eta)/4 @ eta}/b, Partial{(1+xi)*(1-eta)/4 @ eta}/b, Partial{(1+xi)*(1+eta)/4 @ eta}/b, Partial{(1-xi)*(1+eta)/4 @ eta}/b]}

## 2 · «Direct» shear (the one that locks)
#: Order of the 12 degrees of freedom: [w1, θx1, θy1, w2, θx2, θy2, w3, θx3, θy3, w4, θx4, θy4]. Each row of γ is: derivative of N for w, zero or N for the rotation.
gx(xi, eta) = Simplify{[-(1-eta)/(4*a), 0, (1-xi)*(1-eta)/4, (1-eta)/(4*a), 0, (1+xi)*(1-eta)/4, (1+eta)/(4*a), 0, (1+xi)*(1+eta)/4, -(1+eta)/(4*a), 0, (1-xi)*(1+eta)/4]}
gy(xi, eta) = Simplify{[-(1-xi)/(4*b), -(1-xi)*(1-eta)/4, 0, -(1+xi)/(4*b), -(1+xi)*(1-eta)/4, 0, (1+xi)/(4*b), -(1+xi)*(1+eta)/4, 0, (1-xi)/(4*b), -(1-xi)*(1+eta)/4, 0]}

## 3 · MITC4 shear: four tying points
#: γxz is measured at points A(0, +1) and B(0, −1); γyz at C(+1, 0) and D(−1, 0). Between them it is interpolated linearly: γxz changes only with η and γyz only with ξ.
Bsx(xi, eta) = Simplify{(1+eta)/2*gx(0, 1) + (1-eta)/2*gx(0, -1)}
Bsy(xi, eta) = Simplify{(1+xi)/2*gy(1, 0) + (1-xi)/2*gy(-1, 0)}
Bs(xi, eta) = Simplify{[Bsx(xi, eta); Bsy(xi, eta)]}

## 4 · Element shear stiffness
#: With Gs = κ·G·h (κ = 5/6) and dvol = a·b·dξ·dη, the integral is exact because the integrand is a polynomial of degree 2 in each variable. It is compared with the direct shear:
Ks_mitc = Simplify{Gs*a*b*Area{Area{transpose(Bs(xi, eta))*Bs(xi, eta) @ xi = -1 : 1} @ eta = -1 : 1}}
Ks_dir = Simplify{Gs*a*b*Area{Area{transpose([gx(xi, eta); gy(xi, eta)])*[gx(xi, eta); gy(xi, eta)] @ xi = -1 : 1} @ eta = -1 : 1}}
Ks_dif = Simplify{Ks_dir - Ks_mitc}

## 5 · Checks
#: A rigid-body motion must not give shear: the tilted plate w = x (w = ±a at the nodes, rotation θy = −1) and the raised plate w = 1. Both products K·u must give zero:
rig_x = Simplify{[-a; 0; -1; a; 0; -1; a; 0; -1; -a; 0; -1]}
rig_w = Simplify{[1; 0; 0; 1; 0; 0; 1; 0; 0; 1; 0; 0]}
r_x = Simplify{Ks_mitc*rig_x}
r_w = Simplify{Ks_mitc*rig_w}

## 6 · With numbers: the element of sheet 72
#: The section shear: Gs = (5/6)·G·h, with E = 210 000 kN/m², ν = 0.3 and h = 0.1. The sides a and b remain free: the matrix above holds for any rectangle.
Gsn = (5/6)·0.5·210000/(1 + 0.3)·0.1

## 7 · Membrane: the plane stress quadrilateral
#: The membrane is the usual isoparametric Q4, integrated 2 × 2 (ShellMITC4.cpp, assembleB). Per node, three degrees of freedom in the local plane: [u, v, θz]; the rotation does not enter the membrane (its column is zero). The constitutive matrix is the plane stress one, already multiplied by the thickness h:
Dm = Simplify{E*h/(1-nu^2)*[1, nu, 0; nu, 1, 0; 0, 0, (1-nu)/2]}
Bm(xi, eta) = Simplify{[-(1-eta)/(4*a), 0, 0, (1-eta)/(4*a), 0, 0, (1+eta)/(4*a), 0, 0, -(1+eta)/(4*a), 0, 0; 0, -(1-xi)/(4*b), 0, 0, -(1+xi)/(4*b), 0, 0, (1+xi)/(4*b), 0, 0, (1-xi)/(4*b), 0; -(1-xi)/(4*b), -(1-eta)/(4*a), 0, -(1+xi)/(4*b), (1-eta)/(4*a), 0, (1+xi)/(4*b), (1+eta)/(4*a), 0, (1-xi)/(4*b), -(1+eta)/(4*a), 0]}
Km = Simplify{a*b*Area{Area{transpose(Bm(xi, eta))*Dm*Bm(xi, eta) @ xi = -1 : 1} @ eta = -1 : 1}}

## 8 · The in-plane rotation (drilling)
#: The Q4 has no stiffness for θz. OpenSees adds a fictitious stiffness Ktt that ties the rotation θz to the mean rotation of the field (½(∂v/∂x − ∂u/∂y)). Per node, the rotation row is [−½·∂N/∂y, +½·∂N/∂x, −N] over [u, v, θz] (computeBdrill), and Ktt is the smallest eigenvalue of the membrane block, which in an isotropic material is the shear G·h:
Ktt = Simplify{E*h/(2*(1+nu))}
bd(xi, eta) = Simplify{[(1-xi)/(8*b), -(1-eta)/(8*a), -(1-xi)*(1-eta)/4, (1+xi)/(8*b), (1-eta)/(8*a), -(1+xi)*(1-eta)/4, -(1+xi)/(8*b), (1+eta)/(8*a), -(1+xi)*(1+eta)/4, -(1-xi)/(8*b), -(1+eta)/(8*a), -(1-xi)*(1+eta)/4]}
Kd = Simplify{Ktt*a*b*Area{Area{transpose(bd(xi, eta))*bd(xi, eta) @ xi = -1 : 1} @ eta = -1 : 1}}
#: The in-plane stiffness of the element is the sum of the two, with the section 4 shear and the bending in its block:
K_plano = Simplify{Km + Kd}

## 9 · Plate bending and complete plate stiffness
#: The section gives moments M = D_b·κ with the curvatures κxx = ∂θy/∂x, κyy = −∂θx/∂y and 2κxy = ∂θy/∂y − ∂θx/∂x (with the right-hand rule of this sheet). D_b carries the flexural rigidity D = E·h³/12/(1 − ν²):
Db = Simplify{E*h^3/(12*(1-nu^2))*[1, nu, 0; nu, 1, 0; 0, 0, (1-nu)/2]}
Bb(xi, eta) = Simplify{[0, 0, -(1-eta)/(4*a), 0, 0, (1-eta)/(4*a), 0, 0, (1+eta)/(4*a), 0, 0, -(1+eta)/(4*a); 0, (1-xi)/(4*b), 0, 0, (1+xi)/(4*b), 0, 0, -(1+xi)/(4*b), 0, 0, -(1-xi)/(4*b), 0; 0, (1-eta)/(4*a), -(1-xi)/(4*b), 0, -(1-eta)/(4*a), -(1+xi)/(4*b), 0, -(1+eta)/(4*a), (1+xi)/(4*b), 0, (1+eta)/(4*a), (1-xi)/(4*b)]}
Kb = Simplify{a*b*Area{Area{transpose(Bb(xi, eta))*Db*Bb(xi, eta) @ xi = -1 : 1} @ eta = -1 : 1}}
#: The complete plate is the bending plus the MITC4 shear, with G_s = (5/6)·G·h = 5·E·h/(12·(1 + ν)) in place of the symbol:
K_placa = Simplify{Kb + 5*E*h/(12*(1+nu))/Gs*Ks_mitc}

## 10 · The general quadrilateral (that of sheet 72), with numbers
#: So far the rectangle, where the Jacobian is diagonal. In an arbitrary quadrilateral the Jacobian changes from point to point, the integral no longer has a closed form and there is no formula to simplify: it is summed at the four Gauss points (±1/√3), with numbers and the numeric program. The data are those of sheet 72: material, distorted quadrilateral and its local basis (computeBasis).
E = 210000
nu = 0.3
h = 0.1
Mm = E·h/(1 - nu^2) 'membrane
Gh = 0.5·E/(1 + nu)·h 'in-plane shear, also Ktt
Dd = E·h^3/12/(1 - nu^2) 'bending
Gs = Gh·5/6 'transverse shear
X_d = [0, 0, 0; 2.2, 0.3, 0; 1.8, 1.7, 0; 0.2, 1.2, 0]
v_1 = 0.5·(((X_d(3, :) + X_d(2, :)) - X_d(4, :)) - X_d(1, :))
v_2 = 0.5·(((X_d(4, :) + X_d(3, :)) - X_d(2, :)) - X_d(1, :))
g_1 = v_1/norm(v_1)
g_2 = v_2 - g_1·dot(v_2, g_1)
g_2 = g_2/norm(g_2)
#hide
x_l = zeros(2, 4)
for i = 1:4
  x_l(1, i) = dot(X_d(i, :), g_1)
  x_l(2, i) = dot(X_d(i, :), g_2)
end
S_0 = zeros(4, 12)
S_1 = zeros(4, 12)
S_2 = zeros(4, 12)
for i = 1:4
  S_0(i, 3*i - 2) = 1
  S_1(i, 3*i - 1) = 1
  S_2(i, 3*i) = 1
end
#show
#: **Selectors.** Each gradient row has 4 columns (one per node); to pass it to the 12 degrees of freedom it is multiplied by a 4 × 12 matrix S_a that leaves it in column a of each node.
Dm = Mm·[1, nu, 0; nu, 1, 0; 0, 0, (1 - nu)/2]
Db = Dd·[1, nu, 0; nu, 1, 0; 0, 0, (1 - nu)/2]

### 10.1 · OpenSees shear data
#: **Note:** in a distorted quadrilateral the OpenSees shear is NOT the textbook MITC4 (covariant strains with J⁻¹): that version gives a 6.8 % difference. OpenSees measures the shear along each side (G_m matrix of 4 × 12: the tying points are the midpoints of sides 4-1, 2-1, 3-2 and 3-4), interpolates it with (1 ± ξ) and (1 ± η), scales it with the length r of the vector of the other direction divided by 8·det J and rotates it with R, of angles α (vector A) and β (vector C).
dx_41 = x_l(1, 4) - x_l(1, 1)
dy_41 = x_l(2, 4) - x_l(2, 1)
dx_21 = x_l(1, 2) - x_l(1, 1)
dy_21 = x_l(2, 2) - x_l(2, 1)
dx_32 = x_l(1, 3) - x_l(1, 2)
dy_32 = x_l(2, 3) - x_l(2, 2)
dx_34 = x_l(1, 3) - x_l(1, 4)
dy_34 = x_l(2, 3) - x_l(2, 4)
#hide
G_m = zeros(4, 12)
G_m(1, 1) = -0.5
G_m(1, 2) = -dy_41/4
G_m(1, 3) = dx_41/4
G_m(1, 10) = 0.5
G_m(1, 11) = -dy_41/4
G_m(1, 12) = dx_41/4
G_m(2, 1) = -0.5
G_m(2, 2) = -dy_21/4
G_m(2, 3) = dx_21/4
G_m(2, 4) = 0.5
G_m(2, 5) = -dy_21/4
G_m(2, 6) = dx_21/4
G_m(3, 4) = -0.5
G_m(3, 5) = -dy_32/4
G_m(3, 6) = dx_32/4
G_m(3, 7) = 0.5
G_m(3, 8) = -dy_32/4
G_m(3, 9) = dx_32/4
G_m(4, 7) = 0.5
G_m(4, 8) = -dy_34/4
G_m(4, 9) = dx_34/4
G_m(4, 10) = -0.5
G_m(4, 11) = -dy_34/4
G_m(4, 12) = dx_34/4
#show
A_x = -x_l(1, 1) + x_l(1, 2) + x_l(1, 3) - x_l(1, 4)
B_x = x_l(1, 1) - x_l(1, 2) + x_l(1, 3) - x_l(1, 4)
C_x = -x_l(1, 1) - x_l(1, 2) + x_l(1, 3) + x_l(1, 4)
A_y = -x_l(2, 1) + x_l(2, 2) + x_l(2, 3) - x_l(2, 4)
B_y = x_l(2, 1) - x_l(2, 2) + x_l(2, 3) - x_l(2, 4)
C_y = -x_l(2, 1) - x_l(2, 2) + x_l(2, 3) + x_l(2, 4)
alfa = atan(A_y/A_x)
beta = 3.141592653589793/2 - atan(C_x/C_y)
R = [sin(beta), -sin(alfa); -cos(beta), cos(alfa)]

### 10.2 · Sum at the four Gauss points
#: At each point: shape functions and Jacobian; gradient in real axes with the inverse Jacobian; the membrane, rotation, bending and shear B matrices; and dvol·BᵀDB is accumulated.
s_g = 1/sqrt(3)
xi_g = [-s_g, s_g, s_g, -s_g]
eta_g = [-s_g, -s_g, s_g, s_g]
K_plano_g = zeros(12, 12)
K_flex_g = zeros(12, 12)
K_cort_g = zeros(12, 12)
#hide
for k = 1:4
  xi = xi_g(k)
  eta = eta_g(k)
  dN = [-(1 - eta)/4, (1 - eta)/4, (1 + eta)/4, -(1 + eta)/4; -(1 - xi)/4, -(1 + xi)/4, (1 + xi)/4, (1 - xi)/4]
  N_v = transpose([(1 - xi)*(1 - eta)/4, (1 + xi)*(1 - eta)/4, (1 + xi)*(1 + eta)/4, (1 - xi)*(1 + eta)/4])
  Jm = dN*transpose(x_l)
  dJ = det(Jm)
  gxy = inv(Jm)*dN
  gx = transpose(gxy(1, :))
  gy = transpose(gxy(2, :))
  Bm = [gx*S_0; gy*S_1; gy*S_0 + gx*S_1]
  bd = -0.5*gy*S_0 + 0.5*gx*S_1 - N_v*S_2
  Bb = [gx*S_2; -gy*S_1; gy*S_2 - gx*S_1]
  K_plano_g = K_plano_g + dJ*(transpose(Bm)*Dm*Bm + Gh*transpose(bd)*bd)
  K_flex_g = K_flex_g + dJ*transpose(Bb)*Db*Bb
  r_1 = sqrt((C_x + xi*B_x)^2 + (C_y + xi*B_y)^2)
  r_2 = sqrt((A_x + eta*B_x)^2 + (A_y + eta*B_y)^2)
  Ms = [0, 1 - eta, 0, 1 + eta; 1 - xi, 0, 1 + xi, 0]
  Bs = R*[r_1/(8*dJ), 0; 0, r_2/(8*dJ)]*Ms*G_m
  K_cort_g = K_cort_g + dJ*Gs*transpose(Bs)*Bs
end
#show
K_placa_g = K_flex_g + K_cort_g

### 10.3 · Three numbers of each matrix, to compare with OpenSees
#: Entries of the matrices above (local axes; in the plane the order per node is [u, v, θz]; in the plate, [w, θx, θy]):
k_p11 = K_plano_g(1, 1)
k_p12 = K_plano_g(1, 2)
k_p33 = K_plano_g(3, 3)
k_b11 = K_placa_g(1, 1)
k_b22 = K_placa_g(2, 2)
k_b25 = K_placa_g(2, 5)
