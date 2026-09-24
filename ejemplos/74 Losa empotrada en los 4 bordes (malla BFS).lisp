# Losa empotrada en sus 4 bordes con carga repartida
#numerico

#: Losa rectangular de 4 × 6 m con los 4 bordes EMPOTRADOS (unida a vigas o muros muy rígidos) y carga uniforme, con el elemento BFS del ejemplo 71. Lo nuevo frente a la losa apoyada son los apoyos: en un borde empotrado no se mueve NADA del nudo.
#: **Unidades** (las de Calcpad): E en MPa y q en kN/m² → Z en **mm**; momentos en **kN·m/m**.

## 1 · Datos
a = 4 [m] 'lado de la losa en x
b = 6 [m] 'lado de la losa en y
t = 0.12 [m] 'espesor
q = 10 [kN/m²] 'carga repartida
E = 35000 [MPa] 'módulo de elasticidad (hormigón)
ν = 0.3 'coeficiente de Poisson (el de las tablas de Timoshenko)
D_p = E·t^3/(12·(1 - ν^2)) [MN·m] 'rigidez a flexión de la placa

## 2 · Malla BFS
#: Malla regular de 16 × 24 elementos de 0.25 m. El empotramiento concentra momentos negativos junto al borde: hace falta una malla más fina que en la losa apoyada para captarlos (con 8 × 12 el momento del borde sale un 2.5 % y un 4.6 % por debajo).
n = 16 'grados de libertad del elemento
n_a = 16 'elementos a lo largo de a
n_b = 24 'elementos a lo largo de b
n_e = n_a·n_b 'número de elementos
n_j = (n_a + 1)·(n_b + 1) 'número de nudos
a_1 = a/n_a [m] 'lado del elemento en x
b_1 = b/n_b [m] 'lado del elemento en y
#: Nudos numerados por columnas, como en el ejemplo 71: el nudo de la columna i_{a} y la fila i_{b} es j = (i_{a} − 1)·(n_{b} + 1) + i_{b}. Cada elemento toma sus 4 nudos en sentido antihorario desde la esquina inferior izquierda.
#hide
x_j = zeros(n_j, 1)
y_j = zeros(n_j, 1)
for i_a = 1:n_a + 1
  for i_b = 1:n_b + 1
    j = (i_a - 1)·(n_b + 1) + i_b
    x_j(j) = (i_a - 1)·a_1
    y_j(j) = (i_b - 1)·b_1
  end
end
e_j = zeros(n_e, 4)
for i_a = 1:n_a
  for i_b = 1:n_b
    e = i_b + n_b·(i_a - 1)
    j = e + i_a - 1
    e_j(e, 1) = j
    e_j(e, 2) = j + n_b + 1
    e_j(e, 3) = j + n_b + 2
    e_j(e, 4) = j + 1
  end
end
#show
#: **Apoyos.** Borde empotrado: en todos los nudos del borde se fijan los 4 grados de libertad. w = 0 y la pendiente que cruza el borde = 0 (eso es empotrar); la pendiente a lo largo del borde y el alabeo ψ = ∂²w/∂x∂y también son 0, porque son derivadas A LO LARGO de un borde que ni baja ni gira. Cada nudo apoyado guarda una fila de r_{s} con sus 4 grados de libertad (w, θx, θy, ψ): 1 = fijo, 0 = libre.
#hide
s_j = 0
r_s = 0
n_s = 0
#show
for i_a = 1:n_a + 1
  for i_b = 1:n_b + 1
    j = (i_a - 1)·(n_b + 1) + i_b
    r = [0, 0, 0, 0]
    if i_a == 1 || i_a == n_a + 1 || i_b == 1 || i_b == n_b + 1
      r = [1, 1, 1, 1]
    end
    if sum(r) > 0
      n_s = n_s + 1
      s_j(n_s) = j
      r_s(n_s, 1:4) = r
    end
  end
end
n_s 'nudos apoyados
#malla(x_j, y_j, e_j, s_j, r_s)

## 3 · Elemento BFS (Bogner–Fox–Schmit)
#: Rectángulo de a₁ × b₁ con 4 grados de libertad por nudo: flecha w, giros θx = ∂w/∂x y θy = ∂w/∂y, y alabeo ψ = ∂²w/∂x∂y. Es el mismo elemento del ejemplo 71 (verificado contra Calcpad en 849 valores).
#: **Funciones base**: polinomios cúbicos de Hermite en ξ = x/a₁ ∈ [0, 1]. Φ₁ y Φ₃ dan la flecha de cada extremo; Φ₂ y Φ₄, el giro. Con cúbicas la flecha y su pendiente son continuas entre elementos (placa de Kirchhoff).
Φ_1a(ξ) = 1 - ξ^2·(3 - 2·ξ)
Φ_2a(ξ) = ξ·a_1·(1 - ξ·(2 - ξ))
Φ_3a(ξ) = ξ^2·(3 - 2·ξ)
Φ_4a(ξ) = ξ^2·a_1·(-1 + ξ)
#: Primeras derivadas respecto de x (la regla de la cadena divide por a₁):
Φprime_1a(ξ) = -6·(ξ/a_1)·(1 - ξ)
Φprime_2a(ξ) = 1 - ξ·(4 - 3·ξ)
Φprime_3a(ξ) = 6·(ξ/a_1)·(1 - ξ)
Φprime_4a(ξ) = -ξ·(2 - 3·ξ)
#: Segundas derivadas (curvaturas):
Φpprime_1a(ξ) = -(6/a_1^2)·(1 - 2·ξ)
Φpprime_2a(ξ) = -(2/a_1)·(2 - 3·ξ)
Φpprime_3a(ξ) = 6/a_1^2·(1 - 2·ξ)
Φpprime_4a(ξ) = -(2/a_1)·(1 - 3·ξ)
#: Las mismas a lo largo de b, en η = y/b₁:
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
#: **Funciones de forma**: el PRODUCTO de una función en ξ por otra en η, en el orden de los grados de libertad (w, θx, θy, ψ de los nudos 1, 2, 3, 4):
N(ξ, η) = [Φ_1a(ξ)·Φ_1b(η), Φ_2a(ξ)·Φ_1b(η), Φ_1a(ξ)·Φ_2b(η), Φ_2a(ξ)·Φ_2b(η), Φ_3a(ξ)·Φ_1b(η), Φ_4a(ξ)·Φ_1b(η), Φ_3a(ξ)·Φ_2b(η), Φ_4a(ξ)·Φ_2b(η), Φ_3a(ξ)·Φ_3b(η), Φ_4a(ξ)·Φ_3b(η), Φ_3a(ξ)·Φ_4b(η), Φ_4a(ξ)·Φ_4b(η), Φ_1a(ξ)·Φ_3b(η), Φ_2a(ξ)·Φ_3b(η), Φ_1a(ξ)·Φ_4b(η), Φ_2a(ξ)·Φ_4b(η)]
#: **Matriz constitutiva** (momentos ↔ curvaturas); su factor es la rigidez a flexión D_p de los datos:
D = D_p·[1, ν, 0; ν, 1, 0; 0, 0, (1 - ν)/2]
#: **Matriz B**: sus filas son las curvaturas ∂²w/∂x², ∂²w/∂y² y 2·∂²w/∂x∂y de cada función de forma.
B_1(ξ, η) = [Φpprime_1a(ξ)·Φ_1b(η), Φpprime_2a(ξ)·Φ_1b(η), Φpprime_1a(ξ)·Φ_2b(η), Φpprime_2a(ξ)·Φ_2b(η), Φpprime_3a(ξ)·Φ_1b(η), Φpprime_4a(ξ)·Φ_1b(η), Φpprime_3a(ξ)·Φ_2b(η), Φpprime_4a(ξ)·Φ_2b(η), Φpprime_3a(ξ)·Φ_3b(η), Φpprime_4a(ξ)·Φ_3b(η), Φpprime_3a(ξ)·Φ_4b(η), Φpprime_4a(ξ)·Φ_4b(η), Φpprime_1a(ξ)·Φ_3b(η), Φpprime_2a(ξ)·Φ_3b(η), Φpprime_1a(ξ)·Φ_4b(η), Φpprime_2a(ξ)·Φ_4b(η)]
B_2(ξ, η) = [Φ_1a(ξ)·Φpprime_1b(η), Φ_2a(ξ)·Φpprime_1b(η), Φ_1a(ξ)·Φpprime_2b(η), Φ_2a(ξ)·Φpprime_2b(η), Φ_3a(ξ)·Φpprime_1b(η), Φ_4a(ξ)·Φpprime_1b(η), Φ_3a(ξ)·Φpprime_2b(η), Φ_4a(ξ)·Φpprime_2b(η), Φ_3a(ξ)·Φpprime_3b(η), Φ_4a(ξ)·Φpprime_3b(η), Φ_3a(ξ)·Φpprime_4b(η), Φ_4a(ξ)·Φpprime_4b(η), Φ_1a(ξ)·Φpprime_3b(η), Φ_2a(ξ)·Φpprime_3b(η), Φ_1a(ξ)·Φpprime_4b(η), Φ_2a(ξ)·Φpprime_4b(η)]
B_3(ξ, η) = 2·[Φprime_1a(ξ)·Φprime_1b(η), Φprime_2a(ξ)·Φprime_1b(η), Φprime_1a(ξ)·Φprime_2b(η), Φprime_2a(ξ)·Φprime_2b(η), Φprime_3a(ξ)·Φprime_1b(η), Φprime_4a(ξ)·Φprime_1b(η), Φprime_3a(ξ)·Φprime_2b(η), Φprime_4a(ξ)·Φprime_2b(η), Φprime_3a(ξ)·Φprime_3b(η), Φprime_4a(ξ)·Φprime_3b(η), Φprime_3a(ξ)·Φprime_4b(η), Φprime_4a(ξ)·Φprime_4b(η), Φprime_1a(ξ)·Φprime_3b(η), Φprime_2a(ξ)·Φprime_3b(η), Φprime_1a(ξ)·Φprime_4b(η), Φprime_2a(ξ)·Φprime_4b(η)]
B(ξ, η) = [B_1(ξ, η); B_2(ξ, η); B_3(ξ, η)]
#: **Rigidez y carga del elemento**: integrales dobles sobre el rectángulo (dx·dy = a₁·b₁·dξ·dη), hechas con integral2 (Gauss-Legendre, exacta para estos polinomios).
#noc
K_e = a_1·b_1·Area{Area{transpose(B(ξ, η))·D·B(ξ, η) @ ξ = 0 : 1} @ η = 0 : 1}
F_e = a_1·b_1·Area{Area{N(ξ, η)·q @ ξ = 0 : 1} @ η = 0 : 1}
#equ
#hide
K_e = a_1·b_1·integral2(@(ξ, η) transpose(B(ξ, η))·D·B(ξ, η), 0, 1, 0, 1)
F_e = a_1·b_1·q·integral2(@(ξ, η) N(ξ, η), 0, 1, 0, 1)
#show

## 4 · Ensamblaje y solución
#: Cuatro grados de libertad por nudo: los del nudo j son k₁·(j − 1) + 1 … k₁·j; los del elemento, los de sus cuatro nudos seguidos.
k_1 = n/4
n_d = k_1·n_j 'grados de libertad de la losa
#hide
d_j(j) = k_1·(j - 1) + (1:k_1)
d_e(e) = [d_j(e_j(e, 1)), d_j(e_j(e, 2)), d_j(e_j(e, 3)), d_j(e_j(e, 4))]
K = zeros(n_d, n_d)
F = zeros(n_d, 1)
#show
#: La rigidez y la carga de cada elemento se SUMAN en las filas y columnas de sus grados de libertad (todos los elementos son iguales: la malla es regular).
for e = 1:n_e
  g = d_e(e)
  K(g, g) = K(g, g) + K_e
  F(g) = F(g) + F_e
end
#: Cada grado de libertad fijo recibe un muelle k_{s} muy rígido en la diagonal (como en Calcpad): su desplazamiento queda en ≈ 0 sin quitar filas ni columnas.
k_s = 10^20
for i = 1:n_s
  j = k_1·(s_j(i) - 1)
  for k = 1:k_1
    if r_s(i, k) == 1
      K(j + k, j + k) = K(j + k, j + k) + k_s
    end
  end
end
#: K es simétrica y definida positiva: se resuelve por Cholesky (clsolve, como Calcpad).
Z = clsolve(K, F) [mm]

## 5 · Resultados
#: Flechas de los nudos (fila = y, columna = x). La flecha máxima está en el centro y es unas 3 veces menor que la de la misma losa apoyada.
#hide
W_z = zeros(n_a + 1, n_b + 1)
for i = 1:n_a + 1
  for j = 1:n_b + 1
    W_z(i, j) = Z(4·((i - 1)·(n_b + 1) + j) - 3)
  end
end
#show
transpose(W_z) [mm]
w(x, y) = spline(1 + x/a_1, 1 + y/b_1, W_z)
#map(-w(x, y), [0 4], [0 6])
#: **Momentos.** En cada elemento M = −D·B·Z_{e} en sus 4 nudos; en cada nudo se promedian los elementos que llegan a él. Junto al borde el momento cambia de signo: negativo (tracción arriba) en el empotramiento, positivo en el centro.
#hide
Z_e(e) = Z(d_e(e))
M_j = zeros(3, n_j)
c_j = zeros(n_j, 1)
for e = 1:n_e
  Z_el = Z_e(e)
  x_1 = x_j(e_j(e, 1))
  y_1 = y_j(e_j(e, 1))
  for i = 1:4
    j = e_j(e, i)
    c_j(j) = c_j(j) + 1
    M_j(:, j) = M_j(:, j) - D·B((x_j(j) - x_1)/a_1, (y_j(j) - y_1)/b_1)·Z_el
  end
end
for j = 1:n_j
  M_j(:, j) = M_j(:, j)/c_j(j)
end
Mx = zeros(n_a + 1, n_b + 1)
My = zeros(n_a + 1, n_b + 1)
for i = 1:n_a + 1
  for k = 1:n_b + 1
    j = (i - 1)·(n_b + 1) + k
    Mx(i, k) = M_j(1, j)
    My(i, k) = M_j(2, j)
  end
end
#show
#: **Mx** (fila = y, columna = x):
transpose(Mx) [kNm/m]
M_x(x, y) = spline(1 + x/a_1, 1 + y/b_1, Mx)
#map(M_x(x, y), [0 4], [0 6])
#: **My**:
transpose(My) [kNm/m]
M_y(x, y) = spline(1 + x/a_1, 1 + y/b_1, My)
#map(M_y(x, y), [0 4], [0 6])

## 6 · Verificación
#: **Referencia 1 — solución publicada.** Timoshenko & Woinowsky-Krieger, *Theory of Plates and Shells*, 2.ª ed., Tabla 35 (p. 202), placa empotrada con b/a = 6/4 = 1.5 y ν = 0.3: w = 0.00220·q·a⁴/D en el centro; en el centro Mx = 0.0368·q·a² y My = 0.0203·q·a²; en el medio del borde largo (x = 0) Mx = −0.0757·q·a² y en el medio del borde corto (y = 0) My = −0.0570·q·a². a es el lado CORTO (4 m, en x).
j_o(i_a, i_b) = (i_a - 1)·(n_b + 1) + i_b 'nudo de la columna i_{a} y la fila i_{b}
j_c = j_o(n_a/2 + 1, n_b/2 + 1) 'nudo central
j_l = j_o(1, n_b/2 + 1) 'medio del borde largo x = 0
j_k = j_o(n_a/2 + 1, 1) 'medio del borde corto y = 0
w_c = Z(k_1·(j_c - 1) + 1) [mm] 'Hekatan LISP
w_T = 0.00220·q·a^4/D_p [mm] 'Tabla 35
dif_w = round((w_c - w_T)/w_T·100, 4) [%]
M_xc = M_j(1, j_c) [kNm/m]
M_xcT = 0.0368·q·a^2 [kNm/m]
dif_xc = round((M_xc - M_xcT)/M_xcT·100, 4) [%]
M_yc = M_j(2, j_c) [kNm/m]
M_ycT = 0.0203·q·a^2 [kNm/m]
dif_yc = round((M_yc - M_ycT)/M_ycT·100, 4) [%]
M_xl = M_j(1, j_l) [kNm/m]
M_xlT = -0.0757·q·a^2 [kNm/m]
dif_xl = round((M_xl - M_xlT)/M_xlT·100, 4) [%]
M_yk = M_j(2, j_k) [kNm/m]
M_ykT = -0.0570·q·a^2 [kNm/m]
dif_yk = round((M_yk - M_ykT)/M_ykT·100, 4) [%]
#: **Referencia 2 — otro programa, misma malla nudo a nudo.** Calcpad (*Rectangular Slab FEA* con estos datos, esta malla de 16 × 24 y los 4 GDL fijos en el borde).
w_CP = 1.015279 [mm] 'Calcpad
dif_wCP = round((w_c - w_CP)/w_CP·100, 4) [%]
M_xlCP = -12.026911 [kNm/m] 'Calcpad
dif_xlCP = round((M_xl - M_xlCP)/M_xlCP·100, 4) [%]
#| magnitud | referencia | referencia vale | Hekatan LISP | dif % |
#|---|---|--:|--:|--:|
#| w centro [mm] | Timoshenko, Tabla 35 (p. 202) | @{w_T} | @{w_c} | @{dif_w} |
#| Mx centro [kNm/m] | Timoshenko, Tabla 35 | @{M_xcT} | @{M_xc} | @{dif_xc} |
#| My centro [kNm/m] | Timoshenko, Tabla 35 | @{M_ycT} | @{M_yc} | @{dif_yc} |
#| Mx borde largo [kNm/m] | Timoshenko, Tabla 35 | @{M_xlT} | @{M_xl} | @{dif_xl} |
#| My borde corto [kNm/m] | Timoshenko, Tabla 35 | @{M_ykT} | @{M_yk} | @{dif_yk} |
#| w centro [mm] | Calcpad, misma malla | @{w_CP} | @{w_c} | @{dif_wCP} |
#| Mx borde largo [kNm/m] | Calcpad, misma malla | @{M_xlCP} | @{M_xl} | @{dif_xlCP} |
#: Con Calcpad coincide a 4 decimales. Con Timoshenko: la flecha, dentro del redondeo de la tabla (0.00220 tiene 3 cifras: ±0.2 %); los momentos del borde quedan un 1 % por DEBAJO porque en cada nudo se PROMEDIAN los elementos y el momento del borde es un pico: al refinar se acercan.
