# Shape functions · Jacobian · Gauss
#: **1D and 2D**, in ten minutes. Everything seen here was computed by the engine.
#> Hekatan Struct

## 1 · 1D shape functions
u_e = N_1*u_1 + N_2*u_2 @@(se reparte con pesos)
M = [1, -1; 1, 1] @@(1 en su nudo, 0 en el otro)
N = [1, xi] * inv(M) @@(las dos, deducidas)
#slider fplot(u = (1+x)/2*n/8, u_maximo = (1+x)/2, [-1 1]), n = 0:8

## 2 · 1D Jacobian
x = N_2 * L @@(isoparamétrico: la misma N para la geometría)
J = L/2 @@(|J| para MEDIR:  dx = J·dξ)
J_inv = 2/L @@(J⁻¹ para DERIVAR:  dN/dx = J⁻¹·dN/dξ)
#slider fplot(x_real = (1+x)/2*n*50, [-1 1]), n = 1:8
#: The slope of that line **is** J.

## 3 · B matrix and stiffness
dN_dxi = [-1/2, 1/2] @@(derivadas en ξ)
B = dN_dxi * J_inv @@(B = J⁻¹·dN/dξ)
BtB = Area{transpose(B)*B @ xi=-1:1} @@(∫BᵀB dξ)
K_barra = E*A*J*BtB @@(K = E·A·|J|·∫BᵀB dξ)

## 4 · Gauss quadrature
#: ∫f dξ ≈ Σ wᵢ·f(ξᵢ) — exact up to degree **2n − 1**
#gauss

## 5 · 2D shape functions = 1D × 1D
N_1 = Expand{(1-xi)*(1-eta)/4} @@(esquina (−1,−1))
N_2 = Expand{(1+xi)*(1-eta)/4} @@(esquina (+1,−1))
N_3 = Expand{(1+xi)*(1+eta)/4} @@(esquina (+1,+1))
N_4 = Expand{(1-xi)*(1+eta)/4} @@(esquina (−1,+1))
#: **Nᵢ = ¼(1 + ξξᵢ)(1 + ηηᵢ)** · the four add up to 1

## 6 · Each N is a tent · rotate it
#surf((1-x)*(1-y)/4, [-1 1], [-1 1])

## 7 · 2D Jacobian
J_2d = [a, 0; 0, b] @@(J = [∂x/∂ξ, ∂y/∂ξ; ∂x/∂η, ∂y/∂η])
detJ = det(J_2d) @@(|J| = factor de ÁREA:  dx·dy = |J|·dξ·dη)
J_inv2 = inv(J_2d) @@(J⁻¹ para derivar)
#slider fplot(detJ = 1 - n/10*x, [-1 1]), n = 0:9
#: If |J| approaches zero, the element is distorted.

## 8 · 2D Gauss: the same table, twice
g_2d = [-0.5774, -0.5774; 0.5774, -0.5774; 0.5774, 0.5774; -0.5774, 0.5774] @@(2×2 = 4 puntos (ξ, η))
w_2d = [1, 1, 1, 1] @@(pesos: 1 × 1)
#: **K = ∬ BᵀDB·|J| dξdη ≈ Σ wᵢwⱼ·BᵀDB·|J|**

## 9 · The path
#: **N** distributes · **J** changes coordinates · **Gauss** integrates · **K·u = F**
#: Change the element and the N change. The procedure never changes.
#> Hekatan Struct
