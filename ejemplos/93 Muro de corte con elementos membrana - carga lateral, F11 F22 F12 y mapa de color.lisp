# Muro de corte por elementos finitos: el panel como membrana
#numerico

#: Un **muro de corte** (panel de hormigón que resiste el cortante sísmico o de viento de un
#: edificio) de altura H, longitud L y espesor t, empotrado en la base. Se estudia el panel en
#: su propio plano, con elementos **membrana** de cuatro nudos (dos desplazamientos por nudo,
#: sin giro): el mismo elemento del test II del giro normal (ITW), pero aquí SIN el giro —
#: hoy se ve por qué hace falta.
#: **Unidades.** Longitudes en m, fuerzas en tonf, módulo del hormigón en kgf/cm². Como
#: 1 kgf/cm² = 10 tonf/m², la rigidez sale en tonf/m y el desplazamiento se enseña en **mm**.

## 1 · Datos
H = 3.0 [m] 'altura del muro (un piso)
L = 3.0 [m] 'longitud del muro en planta
t = 0.20 [m] 'espesor del muro
fc = 280 [kgf/cm²] 'resistencia del hormigón
ν = 0.2 'coeficiente de Poisson
V = 50 [tonf] 'cortante lateral en la coronación (lo que entrega el diafragma)
#: Módulo de elasticidad del hormigón, en kgf/cm² y pasado a tonf/m²:
E_c = 15100·sqrt(fc) [kgf/cm²]
E = 10·E_c [tonf/m²]

## 2 · Matriz constitutiva
#: El muro es un panel **delgado en su plano** (tensión plana, no deformación plana como una
#: franja infinita): las caras están libres de tensión normal fuera del plano. La matriz
#: constitutiva relaciona las tensiones σ_{x}, σ_{y}, τ_{xy} con las deformaciones ε_{x}, ε_{y}, γ_{xy}:
D = E/(1 - ν^2)·[1, ν, 0; ν, 1, 0; 0, 0, (1 - ν)/2]

## 3 · Malla
n_x = 6 'elementos en la longitud
n_y = 6 'elementos en la altura
n_e = n_x·n_y 'número de elementos
n_j = (n_x + 1)·(n_y + 1) 'número de nudos
n_d = 2·n_j 'grados de libertad
a_1 = L/n_x [m] 'lado del elemento en x
b_1 = H/n_y [m] 'lado del elemento en y
#hide
x_j = zeros(n_j, 1)
y_j = zeros(n_j, 1)
for i = 1:n_x + 1
  for k = 1:n_y + 1
    j = (i - 1)·(n_y + 1) + k
    x_j(j) = (i - 1)·a_1
    y_j(j) = (k - 1)·b_1
  end
end
e_j = zeros(n_e, 4)
for i = 1:n_x
  for k = 1:n_y
    e = (i - 1)·n_y + k
    j = (i - 1)·(n_y + 1) + k
    e_j(e, 1) = j
    e_j(e, 2) = j + n_y + 1
    e_j(e, 3) = j + n_y + 2
    e_j(e, 4) = j + 1
  end
end
s_j = zeros(n_x + 1, 1)
for i = 1:n_x + 1
  s_j(i) = (i - 1)·(n_y + 1) + 1
end
#show
#: Nudos numerados por columnas, de abajo arriba. Los nudos de la base están empotrados:
s_j
#malla(x_j, y_j, e_j, s_j)

## 4 · Rigidez del elemento
#: Matriz deformación–desplazamiento del rectángulo de cuatro nudos, en coordenadas naturales ξ y η entre −1 y 1. Fila 1: ε_{x} = ∂u/∂x. Fila 2: ε_{y} = ∂v/∂y. Fila 3: γ_{xy} = ∂u/∂y + ∂v/∂x.
B(ξ, η) = [-(1 - η)/(2·a_1), 0, (1 - η)/(2·a_1), 0, (1 + η)/(2·a_1), 0, -(1 + η)/(2·a_1), 0; 0, -(1 - ξ)/(2·b_1), 0, -(1 + ξ)/(2·b_1), 0, (1 + ξ)/(2·b_1), 0, (1 - ξ)/(2·b_1); -(1 - ξ)/(2·b_1), -(1 - η)/(2·a_1), -(1 + ξ)/(2·b_1), (1 - η)/(2·a_1), (1 + ξ)/(2·b_1), (1 + η)/(2·a_1), (1 - ξ)/(2·b_1), -(1 + η)/(2·a_1)]
#: La rigidez es la integral de Bᵀ·D·B sobre el elemento; el jacobiano del rectángulo vale a₁·b₁/4 y el espesor, t:
#noc
K_e = t·(a_1·b_1/4)·Area{Area{transpose(B(ξ, η))·D·B(ξ, η) @ ξ = -1 : 1} @ η = -1 : 1}
#equ
#hide
K_e = t·(a_1·b_1/4)·integral2(@(ξ, η) transpose(B(ξ, η))·D·B(ξ, η), -1, 1, -1, 1)
#show
K_e [tonf/m]

## 5 · Ensamblaje, carga lateral y solución
#hide
d_j(j) = [2·j - 1, 2·j]
d_e(e) = [d_j(e_j(e, 1)), d_j(e_j(e, 2)), d_j(e_j(e, 3)), d_j(e_j(e, 4))]
K = zeros(n_d, n_d)
F = zeros(n_d, 1)
#show
#: La rigidez de cada elemento se **suma** en las filas y columnas de sus grados de libertad:
for e = 1:n_e
  g = d_e(e)
  K(g, g) = K(g, g) + K_e
end
#: El cortante V lo entrega el diafragma como una carga UNIFORME a lo largo de la coronación: se reparte a sus nudos por el ancho tributario (mitad en los dos extremos).
for i = 1:n_x + 1
  j = s_j(i) + n_y
  trib = a_1
  if i == 1 || i == n_x + 1
    trib = a_1/2
  end
  F(2·j - 1) = F(2·j - 1) + V/L·trib
end
#: Comprobación: la suma de las fuerzas nodales tiene que dar el cortante V:
ΣF = sum(F) [tonf]
#: Grados de libertad libres: todos menos los de la base (empotrada en Ux y Uy).
#hide
L_g = zeros(n_d - 2·(n_x + 1), 1)
m = 0
for j = 1:n_j
  if y_j(j) > 0
    L_g(m + 1) = 2·j - 1
    L_g(m + 2) = 2·j
    m = m + 2
  end
end
U = zeros(n_d, 1)
#show
#: Solución del sistema K·U = F en los grados libres:
U(L_g) = K(L_g, L_g)\F(L_g)

## 6 · Desplazamientos
#hide
U_x = zeros(n_x + 1, n_y + 1)
for i = 1:n_x + 1
  for k = 1:n_y + 1
    U_x(i, k) = 1000·U(2·((i - 1)·(n_y + 1) + k) - 1)
  end
end
#show
#: Desplazamiento horizontal en la coronación, a la mitad de la longitud (la deriva del muro):
j_cor = s_j(round(n_x/2) + 1) + n_y
u_cor = 1000·U(2·j_cor - 1) [mm]
#: **Mapa de color** del desplazamiento horizontal u_{x} en mm, en TODO el panel:
u_x(x, y) = spline(1 + x/a_1, 1 + y/b_1, U_x)
#map(u_x(x, y), [0 L], [0 H])
#: **Deformada** (amplificada ×300, para verla): el muro corto corta Y flexiona a la vez —
#: por eso las horizontales se inclinan (cortante) y además el conjunto se curva (flexión).
esc = 300 'factor de amplificación visual
#hide
x_def = zeros(n_j, 1)
y_def = zeros(n_j, 1)
for j = 1:n_j
  x_def(j) = x_j(j) + esc·U(2·j - 1)
  y_def(j) = y_j(j) + esc·U(2·j)
end
#show
#malla(x_def, y_def, e_j, s_j)

## 7 · Esfuerzos F11, F22, F12
#: En un elemento **membrana** los esfuerzos se llaman F11, F22, F12 (fuerza por unidad de ancho,
#: en tonf/m): F11 y F22 son axiales en x e y, F12 es rasante. **No** son M11, M22, M12: esos son
#: momentos de flexión de una placa, y el muro no fleja fuera de su plano.
#: En cada elemento σ = D·B·U_{e}, evaluada en sus cuatro nudos; en cada nudo se promedian los elementos que llegan a él. F = σ·t.
#hide
ξ_n = [-1, 1, 1, -1]
η_n = [-1, -1, 1, 1]
S_j = zeros(3, n_j)
c_j = zeros(n_j, 1)
for e = 1:n_e
  U_e = U(d_e(e))
  for i = 1:4
    j = e_j(e, i)
    c_j(j) = c_j(j) + 1
    S_j(:, j) = S_j(:, j) + D·B(ξ_n(i), η_n(i))·U_e
  end
end
for j = 1:n_j
  S_j(:, j) = S_j(:, j)/c_j(j)
end
F11_j = zeros(n_x + 1, n_y + 1)
F22_j = zeros(n_x + 1, n_y + 1)
F12_j = zeros(n_x + 1, n_y + 1)
for i = 1:n_x + 1
  for k = 1:n_y + 1
    jn = (i - 1)·(n_y + 1) + k
    F11_j(i, k) = t·S_j(1, jn)
    F22_j(i, k) = t·S_j(2, jn)
    F12_j(i, k) = t·S_j(3, jn)
  end
end
#show
#: **F11**, axial horizontal, en tonf/m:
F11(x, y) = spline(1 + x/a_1, 1 + y/b_1, F11_j)
#map(F11(x, y), [0 L], [0 H])
#: **F22**, axial vertical (flexión del muro como voladizo: tracción de un lado, compresión del otro), en tonf/m:
F22(x, y) = spline(1 + x/a_1, 1 + y/b_1, F22_j)
#map(F22(x, y), [0 L], [0 H])
#: **F12**, rasante, en tonf/m — máximo en el empotramiento:
F12(x, y) = spline(1 + x/a_1, 1 + y/b_1, F12_j)
#map(F12(x, y), [0 L], [0 H])
F12_base = F12_j(round(n_x/2) + 1, 1) [tonf/m] 'en el centro del empotramiento

## 8 · Comprobación con la teoría de vigas (flexión + cortante)
#: El muro corto (H/L = 1) es un voladizo donde el cortante **no** se puede ignorar — es la
#: misma razón por la que el test II del giro normal (dominado por cortante) necesita el
#: elemento con drilling. Con la inercia y el área de la sección L×t:
I = t·L^3/12 [m⁴]
A_c = t·L [m²]
G = E/(2·(1 + ν)) [tonf/m²]
δ_flex = 1000·V·H^3/(3·E·I) [mm]
δ_cort = 1000·1.2·V·H/(G·A_c) [mm]
δ_viga = δ_flex + δ_cort [mm]
frac_cortante = 100·δ_cort/(δ_flex + δ_cort) [%] 'cuánto del desplazamiento es SOLO cortante
dif = 100·(u_cor - δ_viga)/δ_viga [%]
