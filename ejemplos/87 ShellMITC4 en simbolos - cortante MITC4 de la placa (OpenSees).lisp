# ShellMITC4 de OpenSees en símbolos: cortante MITC4, membrana y giro en el plano
#numerico

#: Es el elemento **ShellMITC4**: la parte de **placa** (cortante MITC4), la **membrana** y el **giro en el plano** de OpenSees (ShellMITC4.cpp, getInitialStiff y computeBasis; la hoja 72 lo traduce con números). Aquí el motor hace la deducción con símbolos, con un rectángulo de lados **2a × 2b** y los cuatro nudos en el orden de OpenSees. Cada nudo lleva tres grados de libertad de la placa: la flecha w y los giros θx y θy.
#: **Convención de la hoja:** giros con la regla de la mano derecha, así que el cortante es γxz = ∂w/∂x + θy y γyz = ∂w/∂y − θx. Está COMPROBADA contra OpenSees 3.7.1 corriendo (K de un elemento, giros rx y ry): con estos signos el cortante coincide a 2.5e-9; con cualquier otra combinación de signos el error es 0.2 a 2.4.
#: **Por qué MITC4.** Si el cortante se calcula con las funciones de forma tal cual, la losa delgada se pone rígida de más (bloqueo por cortante). MITC4 mide γ solo en cuatro puntos de amarre y lo interpola con (1 ± ξ) y (1 ± η).

## 1 · Funciones de forma y sus derivadas
#: Las cuatro funciones bilineales del cuadrilátero de referencia, y sus derivadas ya pasadas a x e y (el Jacobiano del rectángulo es diagonal: dx = a·dξ, dy = b·dη).
N_1 = Expand{(1-xi)*(1-eta)/4}
N_2 = Expand{(1+xi)*(1-eta)/4}
N_3 = Expand{(1+xi)*(1+eta)/4}
N_4 = Expand{(1-xi)*(1+eta)/4}
Jm = Simplify{[Partial{a*xi @ xi}, Partial{a*xi @ eta}; Partial{b*eta @ xi}, Partial{b*eta @ eta}]}
Dj = Simplify{det(Jm)}
dNx = Simplify{[Partial{(1-xi)*(1-eta)/4 @ xi}/a, Partial{(1+xi)*(1-eta)/4 @ xi}/a, Partial{(1+xi)*(1+eta)/4 @ xi}/a, Partial{(1-xi)*(1+eta)/4 @ xi}/a]}
dNy = Simplify{[Partial{(1-xi)*(1-eta)/4 @ eta}/b, Partial{(1+xi)*(1-eta)/4 @ eta}/b, Partial{(1+xi)*(1+eta)/4 @ eta}/b, Partial{(1-xi)*(1+eta)/4 @ eta}/b]}

## 2 · Cortante «directo» (el que bloquea)
#: Orden de los 12 grados de libertad: [w1, θx1, θy1, w2, θx2, θy2, w3, θx3, θy3, w4, θx4, θy4]. Cada fila de γ es: derivada de N para w, cero o N para el giro.
gx(xi, eta) = Simplify{[-(1-eta)/(4*a), 0, (1-xi)*(1-eta)/4, (1-eta)/(4*a), 0, (1+xi)*(1-eta)/4, (1+eta)/(4*a), 0, (1+xi)*(1+eta)/4, -(1+eta)/(4*a), 0, (1-xi)*(1+eta)/4]}
gy(xi, eta) = Simplify{[-(1-xi)/(4*b), -(1-xi)*(1-eta)/4, 0, -(1+xi)/(4*b), -(1+xi)*(1-eta)/4, 0, (1+xi)/(4*b), -(1+xi)*(1+eta)/4, 0, (1-xi)/(4*b), -(1-xi)*(1+eta)/4, 0]}

## 3 · Cortante MITC4: cuatro puntos de amarre
#: γxz se mide en los puntos A(0, +1) y B(0, −1); γyz en C(+1, 0) y D(−1, 0). Entre ellos se interpola linealmente: γxz solo cambia con η y γyz solo con ξ.
Bsx(xi, eta) = Simplify{(1+eta)/2*gx(0, 1) + (1-eta)/2*gx(0, -1)}
Bsy(xi, eta) = Simplify{(1+xi)/2*gy(1, 0) + (1-xi)/2*gy(-1, 0)}
Bs(xi, eta) = Simplify{[Bsx(xi, eta); Bsy(xi, eta)]}

## 4 · Rigidez a cortante del elemento
#: Con Gs = κ·G·h (κ = 5/6) y dvol = a·b·dξ·dη, la integral es exacta porque el integrando es polinomio de grado 2 en cada variable. Se compara con el cortante directo:
Ks_mitc = Simplify{Gs*a*b*Area{Area{transpose(Bs(xi, eta))*Bs(xi, eta) @ xi = -1 : 1} @ eta = -1 : 1}}
Ks_dir = Simplify{Gs*a*b*Area{Area{transpose([gx(xi, eta); gy(xi, eta)])*[gx(xi, eta); gy(xi, eta)] @ xi = -1 : 1} @ eta = -1 : 1}}
Ks_dif = Simplify{Ks_dir - Ks_mitc}

## 5 · Comprobaciones
#: Un movimiento de cuerpo rígido no debe dar cortante: la placa inclinada w = x (w = ±a en los nudos, giro θy = −1) y la placa subida w = 1. Los dos productos K·u tienen que dar cero:
rig_x = Simplify{[-a; 0; -1; a; 0; -1; a; 0; -1; -a; 0; -1]}
rig_w = Simplify{[1; 0; 0; 1; 0; 0; 1; 0; 0; 1; 0; 0]}
r_x = Simplify{Ks_mitc*rig_x}
r_w = Simplify{Ks_mitc*rig_w}

## 6 · Con números: el elemento de la hoja 72
#: El cortante de la sección: Gs = (5/6)·G·h, con E = 210 000 kN/m², ν = 0.3 y h = 0.1. Los lados a y b quedan libres: la matriz de arriba vale para cualquier rectángulo.
Gsn = (5/6)·0.5·210000/(1 + 0.3)·0.1

## 7 · Membrana: el cuadrilátero de esfuerzo plano
#: La membrana es el Q4 isoparamétrico de siempre, integrado en 2 × 2 (ShellMITC4.cpp, assembleB). Por nudo, tres grados de libertad en el plano local: [u, v, θz]; el giro no entra en la membrana (su columna es cero). La matriz constitutiva es la del esfuerzo plano, ya multiplicada por el espesor h:
Dm = Simplify{E*h/(1-nu^2)*[1, nu, 0; nu, 1, 0; 0, 0, (1-nu)/2]}
Bm(xi, eta) = Simplify{[-(1-eta)/(4*a), 0, 0, (1-eta)/(4*a), 0, 0, (1+eta)/(4*a), 0, 0, -(1+eta)/(4*a), 0, 0; 0, -(1-xi)/(4*b), 0, 0, -(1+xi)/(4*b), 0, 0, (1+xi)/(4*b), 0, 0, (1-xi)/(4*b), 0; -(1-xi)/(4*b), -(1-eta)/(4*a), 0, -(1+xi)/(4*b), (1-eta)/(4*a), 0, (1+xi)/(4*b), (1+eta)/(4*a), 0, (1-xi)/(4*b), -(1+eta)/(4*a), 0]}
Km = Simplify{a*b*Area{Area{transpose(Bm(xi, eta))*Dm*Bm(xi, eta) @ xi = -1 : 1} @ eta = -1 : 1}}

## 8 · El giro en el plano (drilling)
#: El Q4 no tiene rigidez para θz. OpenSees le pone una rigidez ficticia Ktt que amarra el giro θz a la rotación media del campo (½(∂v/∂x − ∂u/∂y)). Por nudo, la fila del giro es [−½·∂N/∂y, +½·∂N/∂x, −N] sobre [u, v, θz] (computeBdrill), y Ktt es el menor autovalor del bloque de membrana, que en un material isótropo es el cortante G·h:
Ktt = Simplify{E*h/(2*(1+nu))}
bd(xi, eta) = Simplify{[(1-xi)/(8*b), -(1-eta)/(8*a), -(1-xi)*(1-eta)/4, (1+xi)/(8*b), (1-eta)/(8*a), -(1+xi)*(1-eta)/4, -(1+xi)/(8*b), (1+eta)/(8*a), -(1+xi)*(1+eta)/4, -(1-xi)/(8*b), -(1+eta)/(8*a), -(1-xi)*(1+eta)/4]}
Kd = Simplify{Ktt*a*b*Area{Area{transpose(bd(xi, eta))*bd(xi, eta) @ xi = -1 : 1} @ eta = -1 : 1}}
#: La rigidez del plano del elemento es la suma de las dos, con el cortante de la sección 4 y la flexión en su bloque:
K_plano = Simplify{Km + Kd}

## 9 · Flexión de la placa y rigidez completa de la placa
#: La sección da momentos M = D_b·κ con las curvaturas κxx = ∂θy/∂x, κyy = −∂θx/∂y y 2κxy = ∂θy/∂y − ∂θx/∂x (con la regla de la mano derecha de esta hoja). D_b lleva la rigidez a flexión D = E·h³/12/(1 − ν²):
Db = Simplify{E*h^3/(12*(1-nu^2))*[1, nu, 0; nu, 1, 0; 0, 0, (1-nu)/2]}
Bb(xi, eta) = Simplify{[0, 0, -(1-eta)/(4*a), 0, 0, (1-eta)/(4*a), 0, 0, (1+eta)/(4*a), 0, 0, -(1+eta)/(4*a); 0, (1-xi)/(4*b), 0, 0, (1+xi)/(4*b), 0, 0, -(1+xi)/(4*b), 0, 0, -(1-xi)/(4*b), 0; 0, (1-eta)/(4*a), -(1-xi)/(4*b), 0, -(1-eta)/(4*a), -(1+xi)/(4*b), 0, -(1+eta)/(4*a), (1+xi)/(4*b), 0, (1+eta)/(4*a), (1-xi)/(4*b)]}
Kb = Simplify{a*b*Area{Area{transpose(Bb(xi, eta))*Db*Bb(xi, eta) @ xi = -1 : 1} @ eta = -1 : 1}}
#: La placa completa es la flexión más el cortante MITC4, con G_s = (5/6)·G·h = 5·E·h/(12·(1 + ν)) en lugar del símbolo:
K_placa = Simplify{Kb + 5*E*h/(12*(1+nu))/Gs*Ks_mitc}

## 10 · El cuadrilátero general (el de la hoja 72), con números
#: Hasta aquí el rectángulo, donde el Jacobiano es diagonal. En un cuadrilátero cualquiera el Jacobiano cambia de punto a punto, la integral ya no tiene forma cerrada y no hay fórmula que simplificar: se suma en los cuatro puntos de Gauss (±1/√3), con números y el programa numérico. Los datos son los de la hoja 72: material, cuadrilátero distorsionado y su base local (computeBasis).
E = 210000
nu = 0.3
h = 0.1
Mm = E·h/(1 - nu^2) 'membrana
Gh = 0.5·E/(1 + nu)·h 'cortante en el plano, también Ktt
Dd = E·h^3/12/(1 - nu^2) 'flexión
Gs = Gh·5/6 'cortante transversal
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
#: **Selectores.** Cada fila de gradiente tiene 4 columnas (una por nudo); para pasarla a los 12 grados de libertad se multiplica por una matriz S_a de 4 × 12 que la deja en la columna a de cada nudo.
Dm = Mm·[1, nu, 0; nu, 1, 0; 0, 0, (1 - nu)/2]
Db = Dd·[1, nu, 0; nu, 1, 0; 0, 0, (1 - nu)/2]

### 10.1 · Datos del cortante de OpenSees
#: **Ojo:** en un cuadrilátero distorsionado el cortante de OpenSees NO es el MITC4 de libro (deformaciones covariantes con J⁻¹): esa versión da un 6.8 % de diferencia. OpenSees mide el cortante a lo largo de cada lado (matriz G_m de 4 × 12: los puntos de amarre son los medios de los lados 4-1, 2-1, 3-2 y 3-4), lo interpola con (1 ± ξ) y (1 ± η), lo escala con el largo r del vector de la otra dirección dividido entre 8·det J y lo gira con R, de ángulos α (vector A) y β (vector C).
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

### 10.2 · Suma en los cuatro puntos de Gauss
#: En cada punto: funciones de forma y Jacobiano; gradiente en ejes reales con la inversa del Jacobiano; las matrices B de membrana, giro, flexión y cortante; y se acumula dvol·BᵀDB.
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

### 10.3 · Tres números de cada matriz, para comparar con OpenSees
#: Entradas de las matrices de arriba (ejes locales; en el plano el orden por nudo es [u, v, θz]; en la placa, [w, θx, θy]):
k_p11 = K_plano_g(1, 1)
k_p12 = K_plano_g(1, 2)
k_p33 = K_plano_g(3, 3)
k_b11 = K_placa_g(1, 1)
k_b22 = K_placa_g(2, 2)
k_b25 = K_placa_g(2, 5)
