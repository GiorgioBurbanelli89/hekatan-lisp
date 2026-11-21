# Losa plana sobre columnas (Flat Slab FEA de Calcpad)
#numerico

#: Réplica del ejemplo **Flat Slab FEA** de Calcpad (Ned Ganchovski): una losa plana (sin vigas) de 4 × 3 vanos apoyada directamente en 20 columnas, con el mismo elemento BFS del ejemplo 71. Lo nuevo frente a las hojas 71–76: la malla se arma a partir de las LUCES de los vanos y los apoyos son PUNTUALES, uno por columna, en los cruces de los ejes.
#: **Unidades** (las de Calcpad): E en MPa y q en kN/m² → Z en **mm**; momentos en **kN·m/m**.

## 1 · Datos
#: Luces de los vanos en x y en y (ejes de columnas):
a = [3.6; 4.2; 4.2; 3.6] [m]
b = [3; 3.6; 3] [m]
n_sa = length(a) + 1 'ejes en x
n_sb = length(b) + 1 'ejes en y
#hide
x_s = zeros(n_sa, 1)
y_s = zeros(n_sb, 1)
for k = 1:n_sa - 1
  x_s(k + 1) = x_s(k) + a(k)
end
for k = 1:n_sb - 1
  y_s(k + 1) = y_s(k) + b(k)
end
#show
x_s [m] 'coordenadas de los ejes en x
y_s [m] 'coordenadas de los ejes en y
l_a = x_s(n_sa) [m] 'largo de la losa
l_b = y_s(n_sb) [m] 'ancho de la losa
t = 0.2 [m] 'espesor
q = 10 [kN/m²] 'carga repartida
E = 35000 [MPa] 'módulo de elasticidad
ν = 0.2 'coeficiente de Poisson
D_p = E·t^3/(12·(1 - ν^2)) [MN·m] 'rigidez a flexión de la placa

## 2 · Malla BFS
#: Elementos cuadrados de 0.6 m: cada luz tiene que ser múltiplo de 0.6 para que haya un nudo en cada eje de columnas.
n = 16 'grados de libertad del elemento
a_1 = 0.6 [m] 'lado del elemento en x
b_1 = 0.6 [m] 'lado del elemento en y
#: Elementos por vano. Se usa round y no ceil: en coma flotante 4.2/0.6 = 7.000000000000001 y ceil daría 8.
n_a = round(a/a_1)
n_b = round(b/b_1)
n_ea = sum(n_a) 'elementos a lo largo de x
n_eb = sum(n_b) 'elementos a lo largo de y
n_ja = n_ea + 1 'nudos a lo largo de x
n_jb = n_eb + 1 'nudos a lo largo de y
n_e = n_ea·n_eb 'número de elementos
n_j = n_ja·n_jb 'número de nudos
n_s = n_sa·n_sb 'columnas (nudos apoyados)
#: Nudos numerados por columnas de la malla (de abajo arriba y de izquierda a derecha), como en el ejemplo 71; elementos con sus 4 nudos en sentido antihorario.
#hide
x_j = zeros(n_j, 1)
y_j = zeros(n_j, 1)
for i_a = 1:n_ja
  for i_b = 1:n_jb
    j = (i_a - 1)·n_jb + i_b
    x_j(j) = (i_a - 1)·a_1
    y_j(j) = (i_b - 1)·b_1
  end
end
e_j = zeros(n_e, 4)
for i_a = 1:n_ea
  for i_b = 1:n_eb
    e = i_b + n_eb·(i_a - 1)
    j = e + i_a - 1
    e_j(e, 1) = j
    e_j(e, 2) = j + n_eb + 1
    e_j(e, 3) = j + n_eb + 2
    e_j(e, 4) = j + 1
  end
end
s_j = zeros(n_s, 1)
r_s = zeros(n_s, 4)
#show
#: **Apoyos.** Una columna en cada cruce de ejes: el nudo de la malla está e_{a} elementos a la derecha y e_{b} arriba, con e_{a} y e_{b} los elementos de los vanos anteriores. La columna solo impide que la losa BAJE (w = 0); los giros quedan libres, como en Calcpad (columna articulada a la losa).
for k_a = 1:n_sa
  for k_b = 1:n_sb
    e_a = sum(n_a(1:k_a - 1))
    e_b = sum(n_b(1:k_b - 1))
    i_s = (k_a - 1)·n_sb + k_b
    s_j(i_s) = e_a·n_jb + e_b + 1
    r_s(i_s, 1) = 1
  end
end
transpose(s_j) 'nudos con columna
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
k_1 = n/4
n_d = k_1·n_j 'grados de libertad de la losa
#hide
d_j(j) = k_1·(j - 1) + (1:k_1)
d_e(e) = [d_j(e_j(e, 1)), d_j(e_j(e, 2)), d_j(e_j(e, 3)), d_j(e_j(e, 4))]
K = zeros(n_d, n_d)
F = zeros(n_d, 1)
#show
#: La rigidez y la carga de cada elemento se SUMAN en las filas y columnas de sus grados de libertad:
for e = 1:n_e
  g = d_e(e)
  K(g, g) = K(g, g) + K_e
  F(g) = F(g) + F_e
end
#: Cada columna: un muelle k_{s} muy rígido en el grado de libertad w de su nudo.
k_s = 10^20
for i = 1:n_s
  j = k_1·(s_j(i) - 1)
  for k = 1:k_1
    if r_s(i, k) == 1
      K(j + k, j + k) = K(j + k, j + k) + k_s
    end
  end
end
#: Cholesky (clsolve) sobre las 1836 ecuaciones:
Z = clsolve(K, F) [mm]

## 5 · Resultados
#: Flechas de los nudos (fila = y, columna = x):
#hide
W_z = zeros(n_ja, n_jb)
for i = 1:n_ja
  for j = 1:n_jb
    W_z(i, j) = Z(4·((i - 1)·n_jb + j) - 3)
  end
end
#show
transpose(W_z) [mm]
w(x, y) = spline(1 + x/a_1, 1 + y/b_1, W_z)
#map(-w(x, y), [0 15.6], [0 9.6])
#: **Momentos.** En cada elemento M = −D·B·Z_{e} en sus 4 nudos; en cada nudo se promedian los elementos que llegan a él. Sobre las columnas aparecen picos de momento NEGATIVO (tracción arriba): es lo que arma la losa plana.
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
Mx = zeros(n_ja, n_jb)
My = zeros(n_ja, n_jb)
for i = 1:n_ja
  for k = 1:n_jb
    j = (i - 1)·n_jb + k
    Mx(i, k) = M_j(1, j)
    My(i, k) = M_j(2, j)
  end
end
#show
#: **Mx** (fila = y, columna = x):
transpose(Mx) [kNm/m]
M_x(x, y) = spline(1 + x/a_1, 1 + y/b_1, Mx)
#map(M_x(x, y), [0 15.6], [0 9.6])
#: **My**:
transpose(My) [kNm/m]
M_y(x, y) = spline(1 + x/a_1, 1 + y/b_1, My)
#map(M_y(x, y), [0 15.6], [0 9.6])

## 6 · Verificación
#: **Referencia — otro programa, mismo modelo nudo a nudo:** el ejemplo *Flat Slab FEA* corrido en Calcpad con dos ajustes para que compare a 4 decimales: Cholesky (clsolve) en vez de su solver iterativo slsolve (tolerancia 10⁻²) e integrales de K_{e} y F_{e} con Precision = 10⁻¹² en vez de 10⁻⁴ (y W_z sin redondear a 0.001 mm). Con el ejemplo TAL CUAL las diferencias son de 0.005–0.008 %: son las de esas dos tolerancias, no del modelo (ver la última fila de la tabla). Tres nudos: la columna interior del eje 3 (x = 7.8, y = 3), un nudo del vano de esquina (x = 1.8, y = 1.2) y uno del vano central (x = 6.0, y = 4.8). Los centros exactos de esos vanos no son nudos: 3 m y 4.2 m son un número IMPAR de elementos.
j_o(i_a, i_b) = (i_a - 1)·n_jb + i_b 'nudo de la columna i_{a} y la fila i_{b} de la malla
j_c = j_o(n_a(1) + n_a(2) + 1, n_b(1) + 1) 'columna interior
j_m = j_o(4, 3) 'vano de esquina
j_p = j_o(11, 9) 'vano central
M_xc = M_j(1, j_c) [kNm/m] 'Mx sobre la columna
M_xcCP = -36.536664 [kNm/m] 'Calcpad
dif_xc = round((M_xc - M_xcCP)/M_xcCP·100, 4) [%]
w_m = Z(k_1·(j_m - 1) + 1) [mm] 'flecha en el vano de esquina
w_mCP = 0.6204587 [mm] 'Calcpad
dif_wm = round((w_m - w_mCP)/w_mCP·100, 4) [%]
M_xm = M_j(1, j_m) [kNm/m]
M_xmCP = 8.134667 [kNm/m] 'Calcpad
dif_xm = round((M_xm - M_xmCP)/M_xmCP·100, 4) [%]
w_p = Z(k_1·(j_p - 1) + 1) [mm] 'flecha en el vano central
w_pCP = 0.5376822 [mm] 'Calcpad
dif_wp = round((w_p - w_pCP)/w_pCP·100, 4) [%]
w_max = max(W_z) [mm] 'flecha máxima de la losa
w_maxCP = 0.6349423 [mm] 'Calcpad
dif_wmax = round((w_max - w_maxCP)/w_maxCP·100, 4) [%]
w_maxO = 0.6348933 [mm] 'Calcpad, ejemplo tal cual (slsolve, Precision 10⁻⁴)
dif_wmaxO = round((w_max - w_maxO)/w_maxO·100, 4) [%]
#: **Equilibrio** (independiente de cualquier programa): la reacción de cada columna es k_{s}·w de su nudo (el muelle se acorta w ≈ 10⁻¹⁷ mm), y todas juntas tienen que sumar la carga total q·l_{a}·l_{b}.
R_t = k_s·sum(Z(k_1·(s_j - 1) + 1)) [kN] 'suma de reacciones
Q = q·l_a·l_b [kN] 'carga total
dif_R = round((R_t - Q)/Q·100, 4) [%]
#| magnitud | referencia | referencia vale | Hekatan LISP | dif % |
#|---|---|--:|--:|--:|
#| Mx columna interior [kNm/m] | Calcpad, mismo modelo (clsolve) | @{M_xcCP} | @{M_xc} | @{dif_xc} |
#| w vano de esquina [mm] | Calcpad, mismo modelo (clsolve) | @{w_mCP} | @{w_m} | @{dif_wm} |
#| Mx vano de esquina [kNm/m] | Calcpad, mismo modelo (clsolve) | @{M_xmCP} | @{M_xm} | @{dif_xm} |
#| w vano central [mm] | Calcpad, mismo modelo (clsolve) | @{w_pCP} | @{w_p} | @{dif_wp} |
#| w máxima [mm] | Calcpad, mismo modelo (clsolve) | @{w_maxCP} | @{w_max} | @{dif_wmax} |
#| w máxima [mm] | Calcpad, ejemplo tal cual | @{w_maxO} | @{w_max} | @{dif_wmaxO} |
#| suma de reacciones [kN] | equilibrio, q·l_{a}·l_{b} | @{Q} | @{R_t} | @{dif_R} |
