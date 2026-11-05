# Placa gruesa por elementos finitos: el elemento MITC4 (Mindlin-Reissner)
#numerico

#: Réplica de la hoja de Calcpad **benchmark platethick MITC4**: la misma losa, la misma malla de 12 × 8, el mismo elemento **MITC4** (Dvorkin-Bathe 1985), los mismos apoyos y la misma recuperación de momentos. Aquí corre en Hekatan LISP con la directiva #numerico.
#: **Por qué MITC4.** En una placa gruesa (Mindlin-Reissner) la flecha w y los giros β_{x}, β_{y} son independientes y aparece la deformación por cortante. Si el cortante se calcula con las funciones de forma tal cual, la losa delgada se pone rígida de más (bloqueo por cortante). MITC4 mide el cortante solo en los **cuatro puntos medios de los lados** y lo interpola: así no bloquea.
#: **Unidades.** Como en Calcpad: E en MPa (= MN/m²) y q en kN/m². Entonces K sale en MN/m, F en kN y el cociente F/K en kN/(MN/m) = 10⁻³ m = **mm** (los giros, en mrad). Los momentos −D·B·Z salen en **kN·m/m**. Por eso los números coinciden con los de Calcpad sin factores de conversión.

## 1 · Datos
a = 6 [m] 'largo de la losa
b = 4 [m] 'ancho de la losa
t = 0.40 [m] 'espesor
q = 10 [kN/m²] 'carga repartida
E = 35000 [MPa] 'módulo de elasticidad
ν = 0.15 'coeficiente de Poisson
κ = 5/6 'factor de corrección del cortante (Reissner)

## 2 · Malla de elementos finitos
#: Elemento de 4 nudos con 3 grados de libertad por nudo: la flecha w y los giros β_{x} y β_{y}. En total n = 12 por elemento.
n = 12 'grados de libertad del elemento
n_a = 12 'elementos a lo largo de a
n_b = 8 'elementos a lo largo de b
n_e = n_a·n_b 'número de elementos
n_j = (n_a + 1)·(n_b + 1) 'número de nudos
a_1 = a/n_a [m] 'lado del elemento en x
b_1 = b/n_b [m] 'lado del elemento en y
a_h = a_1/2 [m] 'medio lado en x
b_h = b_1/2 [m] 'medio lado en y
n_s = 2·(n_a + n_b) 'nudos apoyados (todo el borde)
#hide
x_j = zeros(n_j, 1)
y_j = zeros(n_j, 1)
x_0 = 0
y_0 = 0
for j = 1:n_j
  x_j(j) = x_0
  y_j(j) = y_0
  y_0 = y_0 + b_1
  if y_0 > b
    y_0 = 0
    x_0 = x_0 + a_1
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
s_j = zeros(n_s, 1)
i_s = 0
for i = 1:n_a + 1
  i_s = i_s + 1
  s_j(i_s) = (n_b + 1)·i - n_b
end
for i = 1:n_a + 1
  i_s = i_s + 1
  s_j(i_s) = (n_b + 1)·i
end
for i = 2:n_b
  i_s = i_s + 1
  s_j(i_s) = i
end
for i = 2:n_b
  i_s = i_s + 1
  s_j(i_s) = n_a·(n_b + 1) + i
end
#show
#: Nudos numerados por columnas (de abajo arriba y de izquierda a derecha); los del borde están apoyados:
#malla(x_j, y_j, e_j, s_j)

## 3 · Matrices constitutivas
#: **Flexión** (momentos ↔ curvaturas), 3 × 3:
D_b = E·t^3/(12·(1 - ν^2))·[1, ν, 0; ν, 1, 0; 0, 0, (1 - ν)/2]
#: **Cortante** (fuerzas cortantes ↔ deformaciones de cortante), 2 × 2:
G = E/(2·(1 + ν)) [MPa]
D_s11 = κ·G·t
D_s = D_s11·[1, 0; 0, 1]

## 4 · Cuadratura de Gauss 2 × 2
gp = [-1/sqrt(3), 1/sqrt(3)]
gw = [1, 1]

## 5 · Funciones de forma y matrices B
#: **Funciones bilineales** del cuadrilátero de 4 nudos, en coordenadas naturales ξ y η entre −1 y 1. Las mismas sirven para w, β_{x} y β_{y}:
N_1(ξ, η) = (1 - ξ)·(1 - η)/4
N_2(ξ, η) = (1 + ξ)·(1 - η)/4
N_3(ξ, η) = (1 + ξ)·(1 + η)/4
N_4(ξ, η) = (1 - ξ)·(1 + η)/4
#: Sus derivadas respecto de ξ (subíndice ξ) y de η (subíndice η):
N_1ξ(ξ, η) = -(1 - η)/4
N_2ξ(ξ, η) = (1 - η)/4
N_3ξ(ξ, η) = (1 + η)/4
N_4ξ(ξ, η) = -(1 + η)/4
N_1η(ξ, η) = -(1 - ξ)/4
N_2η(ξ, η) = -(1 + ξ)/4
N_3η(ξ, η) = (1 + ξ)/4
N_4η(ξ, η) = (1 - ξ)/4
#: **Curvaturas**: son las derivadas de los giros. La regla de la cadena divide por el medio lado (dx = a_{h}·dξ, dy = b_{h}·dη):
#: κ_{x} = ∂β_{x}/∂x , κ_{y} = ∂β_{y}/∂y , 2·κ_{xy} = ∂β_{x}/∂y + ∂β_{y}/∂x
#: Orden de los 12 grados de libertad: [w₁, β_{x1}, β_{y1}, w₂, β_{x2}, β_{y2}, w₃, β_{x3}, β_{y3}, w₄, β_{x4}, β_{y4}].
#: **Matriz de flexión** B_{b} (3 × 12). Fila 1: κ_{x}, solo en las columnas de β_{x}. Fila 2: κ_{y}, solo en las de β_{y}. Fila 3: 2·κ_{xy}, en las dos:
B_b(ξ, η) = [0, N_1ξ(ξ, η)/a_h, 0, 0, N_2ξ(ξ, η)/a_h, 0, 0, N_3ξ(ξ, η)/a_h, 0, 0, N_4ξ(ξ, η)/a_h, 0; 0, 0, N_1η(ξ, η)/b_h, 0, 0, N_2η(ξ, η)/b_h, 0, 0, N_3η(ξ, η)/b_h, 0, 0, N_4η(ξ, η)/b_h; 0, N_1η(ξ, η)/b_h, N_1ξ(ξ, η)/a_h, 0, N_2η(ξ, η)/b_h, N_2ξ(ξ, η)/a_h, 0, N_3η(ξ, η)/b_h, N_3ξ(ξ, η)/a_h, 0, N_4η(ξ, η)/b_h, N_4ξ(ξ, η)/a_h]
#: **Cortante MITC4: los cuatro puntos de amarre.** γ_{xz} se mide en A (ξ = 0, η = −1) y en C (ξ = 0, η = +1); γ_{yz} en B (ξ = +1, η = 0) y en D (ξ = −1, η = 0). En cada punto, el cortante es la pendiente de la flecha a lo largo del lado menos el giro medio de sus dos nudos:
#: γ_{A} = (w₂ − w₁)/(2·a_{h}) − ½·(β_{x1} + β_{x2})
#: γ_{C} = (w₃ − w₄)/(2·a_{h}) − ½·(β_{x4} + β_{x3})
#: γ_{B} = (w₃ − w₂)/(2·b_{h}) − ½·(β_{y2} + β_{y3})
#: γ_{D} = (w₄ − w₁)/(2·b_{h}) − ½·(β_{y1} + β_{y4})
#: Escritas como filas sobre los 12 grados de libertad:
γ_A = [-1/(2·a_h), -0.5, 0, 1/(2·a_h), -0.5, 0, 0, 0, 0, 0, 0, 0]
γ_C = [0, 0, 0, 0, 0, 0, 1/(2·a_h), -0.5, 0, -1/(2·a_h), -0.5, 0]
γ_B = [0, 0, 0, -1/(2·b_h), 0, -0.5, 1/(2·b_h), 0, -0.5, 0, 0, 0]
γ_D = [-1/(2·b_h), 0, -0.5, 0, 0, 0, 0, 0, 0, 1/(2·b_h), 0, -0.5]
#: **Matriz de cortante** B_{s} (2 × 12): entre los puntos de amarre se interpola en línea recta. γ_{xz} solo cambia con η y γ_{yz} solo con ξ:
B_s(ξ, η) = [0.5·(1 - η)·γ_A + 0.5·(1 + η)·γ_C; 0.5·(1 - ξ)·γ_D + 0.5·(1 + ξ)·γ_B]

## 6 · Matriz de rigidez y cargas del elemento
#: La rigidez es la suma de la de flexión y la de cortante, integradas sobre el elemento (dx·dy = a_{h}·b_{h}·dξ·dη):
#noc
K_e = a_h·b_h·Area{Area{transpose(B_b(ξ, η))·D_b·B_b(ξ, η) + transpose(B_s(ξ, η))·D_s·B_s(ξ, η) @ ξ = -1 : 1} @ η = -1 : 1}
#equ
#: La integral se hace con la cuadratura de Gauss de 2 × 2 (exacta aquí: el integrando es un polinomio de grado 2 en cada variable):
k_e(ξ, η) = transpose(B_b(ξ, η))·D_b·B_b(ξ, η) + transpose(B_s(ξ, η))·D_s·B_s(ξ, η)
#hide
K_e = zeros(n, n)
for j = 1:2
  for i = 1:2
    K_e = K_e + a_h·b_h·gw(i)·gw(j)·k_e(gp(i), gp(j))
  end
end
#show
K_e [MN/m]
#: **Vector de cargas del elemento**: la carga q repartida por igual a las flechas de los cuatro nudos (grados de libertad 1, 4, 7 y 10); los giros no reciben carga.
#hide
F_e = zeros(n, 1)
F_e(1) = q·a_1·b_1/4
F_e(4) = q·a_1·b_1/4
F_e(7) = q·a_1·b_1/4
F_e(10) = q·a_1·b_1/4
#show
F_e [kN]

## 7 · Ensamblaje y solución
#: Tres grados de libertad por nudo (k₁ = n/4). Los del nudo j son k₁·(j − 1) + 1 … k₁·j, y los del elemento, los de sus cuatro nudos seguidos:
k_1 = n/4
n_g = k_1·n_j 'grados de libertad de la losa
#hide
d_j(j) = k_1·(j - 1) + (1:k_1)
d_e(e) = [d_j(e_j(e, 1)), d_j(e_j(e, 2)), d_j(e_j(e, 3)), d_j(e_j(e, 4))]
K = zeros(n_g, n_g)
F = zeros(n_g, 1)
#show
#: Ensamblaje: la rigidez y la carga de cada elemento se SUMAN en las filas y columnas de sus grados de libertad.
for e = 1:n_e
  g = d_e(e)
  K(g, g) = K(g, g) + K_e
  F(g) = F(g) + F_e
end
#: Apoyos (borde simplemente apoyado, condición «dura»): un muelle muy rígido k_{s} en la flecha de cada nudo del borde y en el giro que la arrastraría a lo largo del borde. En los bordes x = 0 y x = a se sujeta β_{y}; en y = 0 e y = b, β_{x}; en las esquinas, los dos.
k_s = 10^20
for i = 1:n_s
  j_s = s_j(i)
  g = k_1·(j_s - 1) + 1
  K(g, g) = K(g, g) + k_s
  if x_j(j_s) == 0 || x_j(j_s) == a
    if y_j(j_s) == 0 || y_j(j_s) == b
      K(g + 1, g + 1) = K(g + 1, g + 1) + k_s
      K(g + 2, g + 2) = K(g + 2, g + 2) + k_s
    else
      K(g + 2, g + 2) = K(g + 2, g + 2) + k_s
    end
  else
    K(g + 1, g + 1) = K(g + 1, g + 1) + k_s
  end
end
#: Solución del sistema K·Z = F por Cholesky (clsolve, como en Calcpad):
Z = clsolve(K, F)

## 8 · Flecha
#: Flechas de los nudos (fila = y, columna = x), redondeadas a 0.001 mm como en Calcpad:
#hide
W_z = zeros(n_a + 1, n_b + 1)
for i = 1:n_a + 1
  for j = 1:n_b + 1
    W_z(i, j) = round(Z(k_1·((i - 1)·(n_b + 1) + j) - (k_1 - 1))·1000)/1000
  end
end
#show
transpose(W_z) [mm]
#: Entre nudos, la flecha se interpola con el spline de Calcpad sobre la matriz de flechas:
w(x, y) = spline(1 + x/a_1, 1 + y/b_1, W_z)
#map(-w(x, y), [0 6], [0 4])
w(a/2, b/2) [mm] 'flecha máxima, en el centro
#: La misma flecha, sin redondear (la del nudo central):
j_c = (n_a/2)·(n_b + 1) + n_b/2 + 1 'nudo central
w_c = Z(k_1·(j_c - 1) + 1) [mm]

## 9 · Momentos flectores
#: **Recuperación.** En cada elemento el momento M = −D_{b}·B_{b}·Z_{e} se calcula en los 4 puntos de Gauss (donde es más exacto) y se **extrapola** a las esquinas con las mismas funciones bilineales; el factor √3 lleva los puntos de Gauss (±1/√3) a las esquinas (±1). En cada nudo se promedian los elementos que llegan a él (Cook-Malkus-Plesha; así lo hace SAP2000).
#hide
ξ_c = [-1, 1, 1, -1]
η_c = [-1, -1, 1, 1]
r_3 = sqrt(3)
Z_e(e) = Z(d_e(e))
M_j = zeros(3, n_j)
c_j = zeros(n_j, 1)
for e = 1:n_e
  Z_el = Z_e(e)
  M_g1 = -D_b·B_b(gp(1), gp(1))·Z_el
  M_g2 = -D_b·B_b(gp(2), gp(1))·Z_el
  M_g3 = -D_b·B_b(gp(1), gp(2))·Z_el
  M_g4 = -D_b·B_b(gp(2), gp(2))·Z_el
  for c = 1:4
    N_g1 = (1 - r_3·ξ_c(c))·(1 - r_3·η_c(c))/4
    N_g2 = (1 + r_3·ξ_c(c))·(1 - r_3·η_c(c))/4
    N_g3 = (1 - r_3·ξ_c(c))·(1 + r_3·η_c(c))/4
    N_g4 = (1 + r_3·ξ_c(c))·(1 + r_3·η_c(c))/4
    j = e_j(e, c)
    M_j(:, j) = M_j(:, j) + N_g1·M_g1 + N_g2·M_g2 + N_g3·M_g3 + N_g4·M_g4
    c_j(j) = c_j(j) + 1
  end
end
for j = 1:n_j
  M_j(:, j) = M_j(:, j)/c_j(j)
end
Mx = zeros(n_a + 1, n_b + 1)
My = zeros(n_a + 1, n_b + 1)
Mxy = zeros(n_a + 1, n_b + 1)
for i = 1:n_a + 1
  for k = 1:n_b + 1
    j = (i - 1)·(n_b + 1) + k
    Mx(i, k) = M_j(1, j)
    My(i, k) = M_j(2, j)
    Mxy(i, k) = M_j(3, j)
  end
end
#show
#: **Mx** (fila = y, columna = x):
transpose(Mx) [kNm/m]
M_x(x, y) = spline(1 + x/a_1, 1 + y/b_1, Mx)
#map(M_x(x, y), [0 6], [0 4])
M_x(a/2, b/2) [kNm/m] 'en el centro
#: **My**:
transpose(My) [kNm/m]
M_y(x, y) = spline(1 + x/a_1, 1 + y/b_1, My)
#map(M_y(x, y), [0 6], [0 4])
M_y(a/2, b/2) [kNm/m] 'máximo, en el centro
#: **Mxy** (torsor):
transpose(Mxy) [kNm/m]
M_xy(x, y) = spline(1 + x/a_1, 1 + y/b_1, Mxy)
#map(M_xy(x, y), [0 6], [0 4])
M_xy(0, 0) [kNm/m] 'máximo, en la esquina

## 10 · Comparación con SAP2000 v24 (Plate-Thick, t = 0.40 m)
#: Valores de SAP2000 con la misma losa: flecha en el centro y torsor en la esquina.
w_SAP = 0.1066 [mm]
Mxy_SAP = -7.7089 [kNm/m]
Δ_w = 100·(w_c - w_SAP)/w_SAP [%]
Δ_Mxy = 100·(M_xy(0, 0) - Mxy_SAP)/Mxy_SAP [%]
#: **Por qué no son idénticos.** SAP2000 usa en su placa gruesa una variante con la flecha cúbica; MITC4 usa la flecha bilineal (Bathe-Dvorkin, el de los libros). Los dos son Mindlin-Reissner válidos y se acercan al refinar la malla.
