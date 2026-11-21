# La membrana de elementos finitos paso a paso: del dato a la matriz de rigidez
#numerico
#: Elemento **cuadrilátero de 4 nudos (Q4) en tensión plana**, el más simple de los elementos membrana. Se hace en el orden de siempre: **datos → matriz constitutiva → funciones de forma → Jacobiano → matriz B → cuadratura de Gauss → rigidez K → comprobación**. Es la membrana **sin giro de drilling**; el ITW añade el giro a este mismo esqueleto (ver el ejemplo del ITW).
#: **Idea en una frase:** la rigidez es la energía de deformación del elemento, **K = ∫ Bᵀ·D·B · t · dA**. B convierte los desplazamientos de los nudos en deformaciones, D convierte deformaciones en tensiones, y la integral suma sobre el área.

## 1 · Datos
E = 25000000 'módulo de elasticidad
ν = 0.2 'coeficiente de Poisson
t = 0.2 'espesor
#: Un cuadrilátero **no rectangular** (trapecio), para que el Jacobiano valga la pena. Nudos en sentido antihorario, coordenadas (x, y) en m, una fila por nudo:
Xn = [0, 0; 4, 0; 3.5, 2; 0.5, 2]
#: El elemento tiene 4 nudos y 2 desplazamientos por nudo (u, v), o sea **8 grados de libertad**, en el orden [u_1, v_1, u_2, v_2, u_3, v_3, u_4, v_4].

## 2 · Matriz constitutiva D (tensión plana)
#: Relaciona las tensiones [σ_{x}, σ_{y}, τ_{xy}] con las deformaciones [ε_{x}, ε_{y}, γ_{xy}]. **Tensión plana** porque la membrana es delgada: la tensión perpendicular al plano es cero.
Db = E/(1 - ν^2)·[1, ν, 0; ν, 1, 0; 0, 0, (1 - ν)/2]
G_c = E/(2·(1 + ν)) 'módulo de corte, para comprobar el término Db(3,3)
Dbc = Db(3, 3) 'debe ser G_c

## 3 · Funciones de forma del cuadrado natural
#: Se trabaja en el cuadrado natural, **ξ y η de −1 a 1**, donde todos los elementos son iguales. Cada función vale **1 en su nudo y 0 en los otros tres**:
N_1 = Expand{(1-xi)*(1-eta)/4}
N_2 = Expand{(1+xi)*(1-eta)/4}
N_3 = Expand{(1+xi)*(1+eta)/4}
N_4 = Expand{(1-xi)*(1+eta)/4}
#: **Partición de la unidad**: suman 1 en todo el elemento. Si no, no reproduce el movimiento de cuerpo rígido.
particion = Simplify{(1-xi)*(1-eta)/4 + (1+xi)*(1-eta)/4 + (1+xi)*(1+eta)/4 + (1-xi)*(1+eta)/4}
#: **Derivadas respecto a ξ y η**, una columna por nudo (fila 1 = ∂N/∂ξ, fila 2 = ∂N/∂η):
dN_q(xi, eta) = 0.25*[-(1-eta), (1-eta), (1+eta), -(1+eta); -(1-xi), -(1+xi), (1+xi), (1-xi)]

## 4 · Jacobiano: del cuadrado natural al elemento real
#: La geometría se interpola con **las mismas funciones de forma** (por eso se llama isoparamétrico): x = ΣN_{i}·x_{i}. El Jacobiano es la derivada de (x, y) respecto a (ξ, η):
J_q(xi, eta) = dN_q(xi, eta)*Xn
#: **detJ es el factor de área**: dx·dy = detJ·dξ·dη. Su signo debe ser positivo (nudos antihorarios); si sale cero o negativo, el elemento está mal numerado o degenerado.
dJ_q(xi, eta) = det(J_q(xi, eta))
#: Un punto concreto para ver los números: el punto de Gauss (+1/√3, +1/√3).
g = 1/sqrt(3) 'coordenada del punto de Gauss
J_g = J_q(g, g)
detJ_g = dJ_q(g, g) 'área real por unidad de área natural en ese punto
#: Las derivadas respecto a **x e y** (las que necesita la deformación) salen con la inversa del Jacobiano: [∂N/∂x; ∂N/∂y] = J⁻¹·[∂N/∂ξ; ∂N/∂η]. Una fila para ∂N/∂x y otra para ∂N/∂y, una columna por nudo:
gx_q(xi, eta) = [1, 0]*inv(J_q(xi, eta))*dN_q(xi, eta)
gy_q(xi, eta) = [0, 1]*inv(J_q(xi, eta))*dN_q(xi, eta)
dNdx_g = gx_q(g, g)
dNdy_g = gy_q(g, g)

## 5 · Matriz B (deformación = B · desplazamientos)
#: ε_{x} = ∂u/∂x, ε_{y} = ∂v/∂y, γ_{xy} = ∂u/∂y + ∂v/∂x. Con u = ΣN_{i}·u_{i} y v = ΣN_{i}·v_{i}, cada deformación es una **combinación lineal de los 8 desplazamientos**. Las matrices E_{u} y E_{v} solo colocan cada nudo en su lugar (u en las posiciones 1, 3, 5, 7; v en las 2, 4, 6, 8):
E_u = [1, 0, 0, 0, 0, 0, 0, 0; 0, 0, 1, 0, 0, 0, 0, 0; 0, 0, 0, 0, 1, 0, 0, 0; 0, 0, 0, 0, 0, 0, 1, 0]
E_v = [0, 1, 0, 0, 0, 0, 0, 0; 0, 0, 0, 1, 0, 0, 0, 0; 0, 0, 0, 0, 0, 1, 0, 0; 0, 0, 0, 0, 0, 0, 0, 1]
#: Cada fila de B es una deformación: **B_{x}** da ε_{x}, **B_{y}** da ε_{y}, **B_{g}** da γ_{xy}. Puestas una debajo de otra forman la matriz B de 3 × 8 (aquí se dejan por separado), y con ellas el producto Bᵀ·D·B se escribe sumando los términos de D:
Bx_q(xi, eta) = gx_q(xi, eta)*E_u
By_q(xi, eta) = gy_q(xi, eta)*E_v
Bg_q(xi, eta) = gy_q(xi, eta)*E_u + gx_q(xi, eta)*E_v
Bxp = Bx_q(g, g) 'fila de ε_x
Byp = By_q(g, g) 'fila de ε_y
Bgp = Bg_q(g, g) 'fila de γ_xy

## 6 · Cuadratura de Gauss y rigidez K
#: La integral **K = ∫∫ Bᵀ·D·B · t · detJ dξ dη** se cambia por una suma en **4 puntos (2 × 2)**, ξ = ±1/√3, η = ±1/√3, con peso 1 cada uno. Es exacta para polinomios hasta grado 3 en cada dirección.
#: Aporte de **un** punto de Gauss, 8 × 8 (lo que vale esa muestra de la integral):
k_q(xi, eta) = t*dJ_q(xi, eta)*(Db(1, 1)*transpose(Bx_q(xi, eta))*Bx_q(xi, eta) + Db(1, 2)*(transpose(Bx_q(xi, eta))*By_q(xi, eta) + transpose(By_q(xi, eta))*Bx_q(xi, eta)) + Db(2, 2)*transpose(By_q(xi, eta))*By_q(xi, eta) + Db(3, 3)*transpose(Bg_q(xi, eta))*Bg_q(xi, eta))
k_g = k_q(g, g)
#: **Rigidez del elemento = suma de los 4 puntos:**
K = k_q(-g, -g) + k_q(g, -g) + k_q(g, g) + k_q(-g, g)
Kuu = K(1, 1) 'rigidez del grado u_{1}
Kuv = K(1, 2) 'acoplamiento u_{1} con v_{1}

## 7 · Comprobaciones (si fallan, hay un error de signo o de orden)
#: **a) El área.** La suma de detJ en los 4 puntos debe ser el área del trapecio, (4 + 3)/2 · 2 = 7 m²:
A_gauss = dJ_q(-g, -g) + dJ_q(g, -g) + dJ_q(g, g) + dJ_q(-g, g)
#: **b) Movimiento de cuerpo rígido.** Si todos los nudos se trasladan 1 en x, no hay deformación y **las fuerzas deben ser cero**:
u_tras = [1; 0; 1; 0; 1; 0; 1; 0]
f_tras = K*u_tras
n_tras = norm(f_tras) 'tiene que ser ≈ 0 (ruido numérico)
#: **c) Patch test de deformación constante.** u = 0.001·x en todos los nudos (ε_{x} = 0.001, el resto cero). El elemento debe reproducir la energía exacta U = ½·σ_{x}·ε_{x}·t·A con σ_{x} = D(1,1)·ε_{x}:
u_x = [0; 0; 0.004; 0; 0.0035; 0; 0.0005; 0]
U_fem = 0.5*transpose(u_x)*K*u_x 'energía con la K calculada
U_exacta = 0.5*Db(1, 1)*0.001*0.001*t*7 'energía de la deformación constante
#: **d) Corte constante.** u = 0.001·y (γ_{xy} = 0.001): energía exacta ½·G·γ²·t·A.
u_c = [0; 0; 0; 0; 0.002; 0; 0.002; 0]
U_c = 0.5*transpose(u_c)*K*u_c
U_ec = 0.5*G_c*0.001*0.001*t*7

## 8 · Lectura
#: Los cuatro números coinciden: el elemento representa **traslación rígida, deformación constante y corte constante**, que es lo que exige el patch test. K es simétrica de 8 × 8 con 3 modos de energía nula (dos traslaciones y una rotación de sólido rígido).
#: **Lo que no tiene este elemento:** no hay giro alrededor de la normal (drilling), así que no se puede pegar a una placa dentro de una cáscara sin añadir uno. El elemento **ITW** de Ibrahimbegović, Taylor y Wilson conserva este esqueleto (D, Jacobiano, B, Gauss) y le suma una interpolación con giro y una burbuja interna.
