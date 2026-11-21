# Funciones de forma · Jacobiano · Gauss
#: **1D y 2D**, en diez minutos. Todo lo que se ve aquí lo calculó el motor.
#> Hekatan Struct

## 1 · Funciones de forma 1D
u_e = N_1*u_1 + N_2*u_2 @@(se reparte con pesos)
M = [1, -1; 1, 1] @@(1 en su nudo, 0 en el otro)
N = [1, xi] * inv(M) @@(las dos, deducidas)
#slider fplot(u = (1+x)/2*n/8, u_maximo = (1+x)/2, [-1 1]), n = 0:8

## 2 · Jacobiano 1D
x = N_2 * L @@(isoparamétrico: la misma N para la geometría)
J = L/2 @@(|J| para MEDIR:  dx = J·dξ)
J_inv = 2/L @@(J⁻¹ para DERIVAR:  dN/dx = J⁻¹·dN/dξ)
#slider fplot(x_real = (1+x)/2*n*50, [-1 1]), n = 1:8
#: La pendiente de esa recta **es** J.

## 3 · Matriz B y rigidez
dN_dxi = [-1/2, 1/2] @@(derivadas en ξ)
B = dN_dxi * J_inv @@(B = J⁻¹·dN/dξ)
BtB = Area{transpose(B)*B @ xi=-1:1} @@(∫BᵀB dξ)
K_barra = E*A*J*BtB @@(K = E·A·|J|·∫BᵀB dξ)

## 4 · Cuadratura de Gauss
#: ∫f dξ ≈ Σ wᵢ·f(ξᵢ) — exacta hasta grado **2n − 1**
#gauss

## 5 · Funciones de forma 2D = 1D × 1D
N_1 = Expand{(1-xi)*(1-eta)/4} @@(esquina (−1,−1))
N_2 = Expand{(1+xi)*(1-eta)/4} @@(esquina (+1,−1))
N_3 = Expand{(1+xi)*(1+eta)/4} @@(esquina (+1,+1))
N_4 = Expand{(1-xi)*(1+eta)/4} @@(esquina (−1,+1))
#: **Nᵢ = ¼(1 + ξξᵢ)(1 + ηηᵢ)** · las cuatro suman 1

## 6 · Cada N es una carpa · gírala
#surf((1-x)*(1-y)/4, [-1 1], [-1 1])

## 7 · Jacobiano 2D
J_2d = [a, 0; 0, b] @@(J = [∂x/∂ξ, ∂y/∂ξ; ∂x/∂η, ∂y/∂η])
detJ = det(J_2d) @@(|J| = factor de ÁREA:  dx·dy = |J|·dξ·dη)
J_inv2 = inv(J_2d) @@(J⁻¹ para derivar)
#slider fplot(detJ = 1 - n/10*x, [-1 1]), n = 0:9
#: Si |J| se acerca a cero, el elemento está distorsionado.

## 8 · Gauss 2D: la misma tabla, dos veces
g_2d = [-0.5774, -0.5774; 0.5774, -0.5774; 0.5774, 0.5774; -0.5774, 0.5774] @@(2×2 = 4 puntos (ξ, η))
w_2d = [1, 1, 1, 1] @@(pesos: 1 × 1)
#: **K = ∬ BᵀDB·|J| dξdη ≈ Σ wᵢwⱼ·BᵀDB·|J|**

## 9 · El camino
#: **N** reparte · **J** cambia de coordenadas · **Gauss** integra · **K·u = F**
#: Cambia el elemento y cambian las N. El procedimiento no cambia nunca.
#> Hekatan Struct
