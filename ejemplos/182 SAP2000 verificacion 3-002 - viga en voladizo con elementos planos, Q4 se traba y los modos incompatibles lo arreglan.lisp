# SAP2000 · Verificación 3-002 · Viga en voladizo con elementos planos
#numerico
#: Problema del manual de verificación de SAP2000 (Analysis › Planes › Example 3-002), tomado de **MacNeal y Harder (1985)**. Una viga en voladizo de 6 in de largo, 0.2 in de alto y 0.1 in de espesor se modela con **6 cuadriláteros** (malla 6 × 1, modelo A: rectángulos) y se carga en la punta de tres maneras: **tracción**, **fuerza vertical** y **momento**.
#: La gracia del problema: el cuadrilátero simple **Q4** se **traba** (*shear locking*) cuando trabaja a flexión y da una flecha 10 veces menor. SAP2000 lo arregla con los **modos incompatibles** de Wilson. Aquí se hacen los dos y se comparan con la teoría de vigas y con el manual.

## 1 · Datos (del manual)
E = 10000000 'módulo de elasticidad [lb/in²]
ν = 0.3 'coeficiente de Poisson
G = E/(2*(1 + ν)) 'módulo de corte [lb/in²]
L = 6 'largo [in]
h = 0.2 'alto, en el plano [in]
t = 0.1 'espesor [in]
#: Cargas en la punta: caso 1 tracción P = 1 lb · caso 2 fuerza vertical P = 1 lb · caso 3 momento M = 1 lb·in (par de ±5 lb separadas 0.2 in).

## 2 · Símbolos: la respuesta de la teoría de vigas (Cook y Young 1985, p. 244)
#: Área e inercia de la sección rectangular:
A_s = Simplify{b_s*h_s}
I_s = Simplify{b_s*h_s^3/12}
#: **Caso 1 · tracción:** la viga se alarga u = P·L/(E·A).
#: **Caso 2 · fuerza en la punta:** flecha por flexión más flecha por cortante (factor de forma κ = 5/6 en sección rectangular):
v_s = Simplify{P_s*L_s^3/(3*E_s*I_s) + P_s*L_s/(5/6*G_s*A_s)}
#: **Caso 3 · momento en la punta:** la sección gira θ = M·L/(E·I) y la fibra de arriba (o de abajo) se mueve u = θ·h/2:
u_Ms = Simplify{M_s*L_s/(E_s*I_s)*h_s/2}
#: Con los números del problema:
A = h*t 'área [in²]
I = t*h^3/12 'inercia [in⁴]
u_1 = 1*L/(E*A) 'caso 1: alargamiento [in]
v_flex = 1*L^3/(3*E*I) 'caso 2: flecha por flexión [in]
v_cort = 1*L/(5/6*G*A) 'caso 2: flecha por cortante [in]
v_2 = v_flex + v_cort 'caso 2: flecha total [in]
u_3 = 1*L/(E*I)*h/2 'caso 3: desplazamiento de la fibra extrema [in]

## 3 · Las mallas: 14 nudos y 6 cuadriláteros (modelos A, B y C)
#: Nudos 1 a 7 abajo (z = 0) y 8 a 14 arriba (z = 0.2 in); cada elemento con sus nudos en sentido antihorario. Los tres modelos tienen los mismos nudos en los extremos y cambian la posición x de los nudos intermedios (del manual):
#: **A · rectángulos:** abajo y arriba 0, 1, 2, 3, 4, 5, 6. **B · trapecios:** abajo 0, 1.1, 1.9, 3.1, 3.9, 5.1, 6 y arriba 0, 0.9, 2.1, 2.9, 4.1, 4.9, 6. **C · paralelogramos:** abajo 0, 0.9, 1.9, 2.9, 3.9, 4.9, 6 y arriba 0, 1.1, 2.1, 3.1, 4.1, 5.1, 6.
X_ab = [0, 1, 2, 3, 4, 5, 6; 0, 1.1, 1.9, 3.1, 3.9, 5.1, 6; 0, 0.9, 1.9, 2.9, 3.9, 4.9, 6]
X_ar = [0, 1, 2, 3, 4, 5, 6; 0, 0.9, 2.1, 2.9, 4.1, 4.9, 6; 0, 1.1, 2.1, 3.1, 4.1, 5.1, 6]
#hide
C = zeros(6, 4)
for e = 1:6
  C(e, 1) = e
  C(e, 2) = e + 1
  C(e, 3) = e + 8
  C(e, 4) = e + 7
end
#show

## 4 · Los dos elementos
#: **Q4** (el de la hoja 179): funciones de forma bilineales, Jacobiano y cuadratura de Gauss 2 × 2.
Db = E/(1 - ν^2)·[1, ν, 0; ν, 1, 0; 0, 0, (1 - ν)/2]
dN_q(xi, eta) = 0.25*[-(1-eta), (1-eta), (1+eta), -(1+eta); -(1-xi), -(1+xi), (1+xi), (1-xi)]
J_q(xi, eta, X) = dN_q(xi, eta)*X
dJ_q(xi, eta, X) = det(J_q(xi, eta, X))
gx_q(xi, eta, X) = transpose([1; 0])*inv(J_q(xi, eta, X))*dN_q(xi, eta)
gy_q(xi, eta, X) = transpose([0; 1])*inv(J_q(xi, eta, X))*dN_q(xi, eta)
E_u = [1, 0, 0, 0, 0, 0, 0, 0; 0, 0, 1, 0, 0, 0, 0, 0; 0, 0, 0, 0, 1, 0, 0, 0; 0, 0, 0, 0, 0, 0, 1, 0]
E_v = [0, 1, 0, 0, 0, 0, 0, 0; 0, 0, 0, 1, 0, 0, 0, 0; 0, 0, 0, 0, 0, 1, 0, 0; 0, 0, 0, 0, 0, 0, 0, 1]
Bx_q(xi, eta, X) = gx_q(xi, eta, X)*E_u
By_q(xi, eta, X) = gy_q(xi, eta, X)*E_v
Bg_q(xi, eta, X) = gy_q(xi, eta, X)*E_u + gx_q(xi, eta, X)*E_v
k_q(xi, eta, X) = t*dJ_q(xi, eta, X)*(Db(1, 1)*transpose(Bx_q(xi, eta, X))*Bx_q(xi, eta, X) + Db(1, 2)*(transpose(Bx_q(xi, eta, X))*By_q(xi, eta, X) + transpose(By_q(xi, eta, X))*Bx_q(xi, eta, X)) + Db(2, 2)*transpose(By_q(xi, eta, X))*By_q(xi, eta, X) + Db(3, 3)*transpose(Bg_q(xi, eta, X))*Bg_q(xi, eta, X))
#: **Por qué se traba:** con funciones bilineales el borde del elemento queda **recto** al flexionar; para curvarse el elemento tiene que inventar una distorsión angular γ que la viga real no tiene, y esa rigidez de cortante «falsa» frena la flecha.
#: **Modos incompatibles (Wilson):** se agregan dos deformaciones internas P_1 = 1 − ξ² y P_2 = 1 − η² (una parábola en cada dirección) que dejan al borde **curvarse**. Sus 4 grados de libertad (a_1, a_2 en x y en z) son internos del elemento y se eliminan antes de ensamblar (condensación estática): k = k_cc − k_ci·k_ii^{-1}·k_ic.
dP_i(xi, eta) = [-2*xi, 0; 0, -2*eta]
gx_i(xi, eta, X) = transpose([1; 0])*inv(J_q(0, 0, X))*dP_i(xi, eta)
gy_i(xi, eta, X) = transpose([0; 1])*inv(J_q(0, 0, X))*dP_i(xi, eta)
F_u = [1, 0, 0, 0; 0, 0, 1, 0]
F_v = [0, 1, 0, 0; 0, 0, 0, 1]
Bx_i(xi, eta, X) = gx_i(xi, eta, X)*F_u
By_i(xi, eta, X) = gy_i(xi, eta, X)*F_v
Bg_i(xi, eta, X) = gy_i(xi, eta, X)*F_u + gx_i(xi, eta, X)*F_v
k_ci(xi, eta, X) = t*dJ_q(xi, eta, X)*(Db(1, 1)*transpose(Bx_q(xi, eta, X))*Bx_i(xi, eta, X) + Db(1, 2)*(transpose(Bx_q(xi, eta, X))*By_i(xi, eta, X) + transpose(By_q(xi, eta, X))*Bx_i(xi, eta, X)) + Db(2, 2)*transpose(By_q(xi, eta, X))*By_i(xi, eta, X) + Db(3, 3)*transpose(Bg_q(xi, eta, X))*Bg_i(xi, eta, X))
k_ii(xi, eta, X) = t*dJ_q(xi, eta, X)*(Db(1, 1)*transpose(Bx_i(xi, eta, X))*Bx_i(xi, eta, X) + Db(1, 2)*(transpose(Bx_i(xi, eta, X))*By_i(xi, eta, X) + transpose(By_i(xi, eta, X))*Bx_i(xi, eta, X)) + Db(2, 2)*transpose(By_i(xi, eta, X))*By_i(xi, eta, X) + Db(3, 3)*transpose(Bg_i(xi, eta, X))*Bg_i(xi, eta, X))
g = 1/sqrt(3) 'punto de Gauss

## 5 · Ensamblaje, apoyos, cargas y solución para cada modelo
#: Para cada modelo: se arma la rigidez global 28 × 28 con Q4 (K_a) y con modos incompatibles (K_b); apoyos como en SAP2000 (nudo 1 fijo en x y z, nudo 8 fijo solo en x, con un resorte muy rígido) y las tres cargas: caso 1 F_x = 0.5 lb en 7 y 14 · caso 2 F_z = 0.5 lb en 7 y 14 y −0.5 lb en 8 (la reacción, sin Poisson) · caso 3 F_x = −5 lb en 7 y +5 lb en 14.
#: Resultado de cada caso (promedio de los nudos 7 y 14, como el manual): R_q(modelo, caso) con Q4 y R_m(modelo, caso) con modos incompatibles; V_q y V_m guardan la flecha del caso 2 en los 14 nudos (para las gráficas).
#hide
R_q = zeros(3, 3)
R_m = zeros(3, 3)
V_q = zeros(3, 14)
V_m = zeros(3, 14)
XY = zeros(14, 2)
Xn = zeros(4, 2)
F_1 = zeros(28, 1)
F_2 = zeros(28, 1)
F_3 = zeros(28, 1)
for i = 1:1
  F_1(13) = 0.5
  F_1(27) = 0.5
  F_2(14) = 0.5
  F_2(28) = 0.5
  F_2(16) = -0.5
  F_3(13) = -5
  F_3(27) = 5
end
for m = 1:3
  for n = 1:7
    XY(n, 1) = X_ab(m, n)
    XY(n + 7, 1) = X_ar(m, n)
    XY(n + 7, 2) = h
  end
  K_a = zeros(28, 28)
  K_b = zeros(28, 28)
  for e = 1:6
    for a = 1:4
      Xn(a, 1) = XY(C(e, a), 1)
      Xn(a, 2) = XY(C(e, a), 2)
    end
    K_cc = k_q(-g, -g, Xn) + k_q(g, -g, Xn) + k_q(g, g, Xn) + k_q(-g, g, Xn)
    K_ci = k_ci(-g, -g, Xn) + k_ci(g, -g, Xn) + k_ci(g, g, Xn) + k_ci(-g, g, Xn)
    K_ii = k_ii(-g, -g, Xn) + k_ii(g, -g, Xn) + k_ii(g, g, Xn) + k_ii(-g, g, Xn)
    K_m = K_cc - K_ci*inv(K_ii)*transpose(K_ci)
    for a = 1:4
      for b = 1:4
        for i = 1:2
          for j = 1:2
            K_a(2*C(e, a) - 2 + i, 2*C(e, b) - 2 + j) = K_a(2*C(e, a) - 2 + i, 2*C(e, b) - 2 + j) + K_cc(2*a - 2 + i, 2*b - 2 + j)
            K_b(2*C(e, a) - 2 + i, 2*C(e, b) - 2 + j) = K_b(2*C(e, a) - 2 + i, 2*C(e, b) - 2 + j) + K_m(2*a - 2 + i, 2*b - 2 + j)
          end
        end
      end
    end
  end
  K_a(1, 1) = K_a(1, 1) + 1e15
  K_a(2, 2) = K_a(2, 2) + 1e15
  K_a(15, 15) = K_a(15, 15) + 1e15
  K_b(1, 1) = K_b(1, 1) + 1e15
  K_b(2, 2) = K_b(2, 2) + 1e15
  K_b(15, 15) = K_b(15, 15) + 1e15
  U_a1 = clsolve(K_a, F_1)
  U_a2 = clsolve(K_a, F_2)
  U_a3 = clsolve(K_a, F_3)
  U_b1 = clsolve(K_b, F_1)
  U_b2 = clsolve(K_b, F_2)
  U_b3 = clsolve(K_b, F_3)
  R_q(m, 1) = (U_a1(13) + U_a1(27))/2
  R_q(m, 2) = (U_a2(14) + U_a2(28))/2
  R_q(m, 3) = (abs(U_a3(13)) + abs(U_a3(27)))/2
  R_m(m, 1) = (U_b1(13) + U_b1(27))/2
  R_m(m, 2) = (U_b2(14) + U_b2(28))/2
  R_m(m, 3) = (abs(U_b3(13)) + abs(U_b3(27)))/2
  for n = 1:14
    V_q(m, n) = U_a2(2*n)
    V_m(m, n) = U_b2(2*n)
  end
end
#show
#: Flecha de la punta en el caso 2 (fuerza vertical), modelos A, B y C:
v_Q4 = transpose([R_q(1, 2); R_q(2, 2); R_q(3, 2)]) 'Q4 [in]
v_MI = transpose([R_m(1, 2); R_m(2, 2); R_m(3, 2)]) 'modos incompatibles [in]

## 6 · Gráficas
#: **Gráfica 3D.** La viga del modelo A deformada con los modos incompatibles (caso 2, flecha × 10); color = desplazamiento vertical:
#hide
X_m = zeros(15, 3)
U_m = zeros(15, 3)
v_n = zeros(15, 1)
for n = 1:7
  X_m(n, 1) = X_ab(1, n)
  X_m(n + 7, 1) = X_ar(1, n)
  X_m(n + 7, 2) = h
end
for n = 1:14
  U_m(n, 2) = V_m(1, n)
  v_n(n) = V_m(1, n)
end
X_m(15, 3) = 0.01
e_b = [1, 1]
v_b = [0, 0]
#show
#modelo3d(X_m, C, e_b, v_n, v_b, U_m, 10)
#: **Gráfica 2D (corte por el eje de la viga) con la discretización.** La curva es la teoría de vigas, v(x) = P·x²·(3L − x)/(6EI) + P·x/(κGA). Los puntos son los **7 nudos** del modelo A (promedio de abajo y arriba en cada x): con **Q4** quedan muy por debajo (se traba); con **modos incompatibles** caen sobre la curva.
#hide
P_q4 = zeros(7, 2)
P_mi = zeros(7, 2)
for n = 1:7
  P_q4(n, 1) = n - 1
  P_q4(n, 2) = (V_q(1, n) + V_q(1, n + 7))/2
  P_mi(n, 1) = n - 1
  P_mi(n, 2) = (V_m(1, n) + V_m(1, n + 7))/2
end
#show
#fplot(teoria = x^2*(18 - x)/4000 + x/(5/6*3846153.85*0.02), Q4 = P_q4, modos_inc = P_mi, [0 6])

## 7 · Comparación con el manual de SAP2000
#hide
for i = 1:1
  S_q = zeros(9, 1)
  S_m = zeros(9, 1)
  T_i = zeros(9, 1)
  H_q = zeros(9, 1)
  H_m = zeros(9, 1)
  S_q(1) = 3.000E-05
  S_q(2) = 3.000E-05
  S_q(3) = 3.000E-05
  S_q(4) = 0.0101
  S_q(5) = 0.0030
  S_q(6) = 0.0038
  S_q(7) = 0.840E-04
  S_q(8) = 0.206E-04
  S_q(9) = 0.282E-04
  S_m(1) = 3.000E-05
  S_m(2) = 3.000E-05
  S_m(3) = 3.000E-05
  S_m(4) = 0.1073
  S_m(5) = 0.0238
  S_m(6) = 0.0861
  S_m(7) = 9.000E-04
  S_m(8) = 1.466E-04
  S_m(9) = 7.614E-04
  for k = 1:3
    T_i(k) = u_1
    T_i(k + 3) = v_2
    T_i(k + 6) = u_3
    H_q(k) = R_q(k, 1)
    H_q(k + 3) = R_q(k, 2)
    H_q(k + 6) = R_q(k, 3)
    H_m(k) = R_m(k, 1)
    H_m(k + 3) = R_m(k, 2)
    H_m(k + 6) = R_m(k, 3)
  end
end
#show
#tabla("Caso · modelo","Teoría:6","SAP2000 sin modos inc.:6","Hekatan Q4:6","SAP2000 con modos inc.:6","Hekatan modos inc.:6")({"1 tracción · A","1 tracción · B","1 tracción · C","2 fuerza · A","2 fuerza · B","2 fuerza · C","3 momento · A","3 momento · B","3 momento · C"}; T_i; S_q; H_q; S_m; H_m)
#: **Conclusión.** En **tracción** todos dan exacto (3·10⁻⁵ in), por deformados que estén los elementos. En **flexión** el **Q4** se traba siempre y Hekatan da lo mismo que SAP2000 en los tres modelos (0.0101, 0.0030 y 0.0038 in). Con **modos incompatibles** el modelo de **rectángulos** queda exacto (0.1073 in); en los elementos **deformados** la flecha cae mucho —trapecios ≈ 0.023 in (−79 %), paralelogramos ≈ 0.085 in (−21 %)— y Hekatan queda a 1–3 % de SAP2000, que usa la versión de Taylor de los modos incompatibles para elementos deformados. Es lo que advierten MacNeal y Harder: la forma de la malla importa tanto como el elemento.
