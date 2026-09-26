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
