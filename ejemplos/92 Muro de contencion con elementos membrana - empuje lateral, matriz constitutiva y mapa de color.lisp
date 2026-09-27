# Muro de contención por elementos finitos: la pantalla como membrana
#numerico

#: La pantalla de un muro en voladizo, de altura H y espesor t, empotrada en la zapata. Se estudia **una franja de 1 m** de muro con elementos **membrana** de cuatro nudos (dos desplazamientos por nudo: u_{x} y u_{y}). El relleno empuja sobre la cara izquierda con el reparto triangular de Rankine.
#: **Unidades.** Longitudes en m, fuerzas en tonf, módulo del hormigón en kgf/cm². Como 1 kgf/cm² = 10 tonf/m², la rigidez sale en tonf/m y el desplazamiento en m; se enseña en **mm**.

## 1 · Datos
H = 4 [m] 'altura de la pantalla
t = 0.4 [m] 'espesor de la pantalla
γ = 1.8 [tonf/m³] 'peso específico del relleno
φ = 30 [°] 'ángulo de fricción del relleno
fc = 210 [kgf/cm²] 'resistencia del hormigón
ν = 0.2 'coeficiente de Poisson
#: Módulo de elasticidad del hormigón, en kgf/cm² y pasado a tonf/m²:
E_c = 15100·sqrt(fc) [kgf/cm²]
E = 10·E_c [tonf/m²]

## 2 · Empuje lateral del relleno
#: Coeficiente de empuje activo de Rankine:
K_a = tan(pi/4 - φ·pi/360)^2
#: La presión crece con la profundidad z, medida desde la coronación:
p(z) = K_a·γ·z
p_0 = p(H) [tonf/m²] 'presión en la base
#: En la gráfica, K_{a}·γ = 0.6 tonf/m³; el eje horizontal es la profundidad z en m y el vertical la presión en tonf/m²:
#fplot(p = 0.6*z, [0 4])
#: La resultante es el área del triángulo y actúa a un tercio de la altura:
E_a = K_a·γ·H^2/2 [tonf/m]
M_0 = E_a·H/3 [tonf·m/m] 'momento en el empotramiento

## 3 · Matriz constitutiva
#: El muro es largo: la franja no se deforma a lo largo del muro (**deformación plana**). La matriz constitutiva relaciona las tensiones σ_{x}, σ_{y}, τ_{xy} con las deformaciones ε_{x}, ε_{y}, γ_{xy}:
D = E/((1 + ν)·(1 - 2·ν))·[1 - ν, ν, 0; ν, 1 - ν, 0; 0, 0, (1 - 2·ν)/2]

## 4 · Malla
n_x = 4 'elementos en el espesor
n_y = 40 'elementos en la altura
n_e = n_x·n_y 'número de elementos
n_j = (n_x + 1)·(n_y + 1) 'número de nudos
n_d = 2·n_j 'grados de libertad
a_1 = t/n_x [m] 'lado del elemento en x
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

## 5 · Rigidez del elemento
#: Matriz deformación–desplazamiento del rectángulo de cuatro nudos, en coordenadas naturales ξ y η entre −1 y 1. Fila 1: ε_{x} = ∂u/∂x. Fila 2: ε_{y} = ∂v/∂y. Fila 3: γ_{xy} = ∂u/∂y + ∂v/∂x.
B(ξ, η) = [-(1 - η)/(2·a_1), 0, (1 - η)/(2·a_1), 0, (1 + η)/(2·a_1), 0, -(1 + η)/(2·a_1), 0; 0, -(1 - ξ)/(2·b_1), 0, -(1 + ξ)/(2·b_1), 0, (1 + ξ)/(2·b_1), 0, (1 - ξ)/(2·b_1); -(1 - ξ)/(2·b_1), -(1 - η)/(2·a_1), -(1 + ξ)/(2·b_1), (1 - η)/(2·a_1), (1 + ξ)/(2·b_1), (1 + η)/(2·a_1), (1 - ξ)/(2·b_1), -(1 + η)/(2·a_1)]
#: La rigidez es la integral de Bᵀ·D·B sobre el elemento; el jacobiano del rectángulo vale a₁·b₁/4 y el ancho de la franja, 1 m:
#noc
K_e = (a_1·b_1/4)·Area{Area{transpose(B(ξ, η))·D·B(ξ, η) @ ξ = -1 : 1} @ η = -1 : 1}
#equ
#hide
K_e = (a_1·b_1/4)·integral2(@(ξ, η) transpose(B(ξ, η))·D·B(ξ, η), -1, 1, -1, 1)
#show
K_e [tonf/m]

## 6 · Ensamblaje, cargas y solución
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
#: El empuje se reparte a los nudos de la cara izquierda. En cada tramo de altura b₁ la presión es lineal, de p_{a} abajo a p_{b} arriba:
for k = 1:n_y
  p_a = p(H - y_j(k))
  p_b = p(H - y_j(k + 1))
  F(2·k - 1) = F(2·k - 1) + b_1·(2·p_a + p_b)/6
  F(2·k + 1) = F(2·k + 1) + b_1·(p_a + 2·p_b)/6
end
#: Comprobación: la suma de las fuerzas nodales tiene que dar la resultante E_{a}:
ΣF = sum(F) [tonf/m]
#: Grados de libertad libres: todos menos los de la base.
#hide
L = zeros(n_d - 2·(n_x + 1), 1)
m = 0
for j = 1:n_j
  if y_j(j) > 0
    L(m + 1) = 2·j - 1
    L(m + 2) = 2·j
    m = m + 2
  end
end
U = zeros(n_d, 1)
#show
#: Solución del sistema K·U = F en los grados libres:
U(L) = K(L, L)\F(L)

## 7 · Resultados
#hide
U_x = zeros(n_x + 1, n_y + 1)
for i = 1:n_x + 1
  for k = 1:n_y + 1
    U_x(i, k) = 1000·U(2·((i - 1)·(n_y + 1) + k) - 1)
  end
end
#show
#: Desplazamiento horizontal en la coronación, en la cara del relleno:
u_cor = 1000·U(2·(n_y + 1) - 1) [mm]
#: **Mapa de color** del desplazamiento horizontal u_{x} en mm. Al pasar el cursor sale el valor en ese punto:
u_x(x, y) = spline(1 + x/a_1, 1 + y/b_1, U_x)
#map(u_x(x, y), [0 0.4], [0 4])

### Tensiones
#: En cada elemento σ = D·B·U_{e}, evaluada en sus cuatro nudos; en cada nudo se promedian los elementos que llegan a él. Se pasa a kgf/cm² dividiendo por 10.
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
    S_j(:, j) = S_j(:, j) + D·B(ξ_n(i), η_n(i))·U_e/10
  end
end
for j = 1:n_j
  S_j(:, j) = S_j(:, j)/c_j(j)
end
S_y = zeros(n_x + 1, n_y + 1)
for i = 1:n_x + 1
  for k = 1:n_y + 1
    S_y(i, k) = S_j(2, (i - 1)·(n_y + 1) + k)
  end
end
#show
#: **Tensión vertical σ_{y}** en kgf/cm²: tracción en la cara del relleno, compresión en la cara libre.
σ_y(x, y) = spline(1 + x/a_1, 1 + y/b_1, S_y)
#map(σ_y(x, y), [0 0.4], [0 4])
σ_trac = S_y(1, 1) [kgf/cm²] 'en el empotramiento, cara del relleno
σ_comp = S_y(n_x + 1, 1) [kgf/cm²] 'en el empotramiento, cara libre

## 8 · Comprobación con la teoría de vigas
#: La pantalla es un voladizo con carga triangular. Con el módulo de deformación plana E/(1 − ν²) y la inercia de la franja:
I = t^3/12 [m⁴/m]
δ_viga = 1000·p_0·H^4/(30·E/(1 - ν^2)·I) [mm]
σ_viga = M_0·(t/2)/I/10 [kgf/cm²]
dif = 100·(u_cor - δ_viga)/δ_viga [%]
#: La diferencia es la esperada: la viga no cuenta la deformación por cortante y el elemento de cuatro nudos es algo rígido a flexión. Las tensiones de la base se comparan con los 24 kgf/cm² de la viga.

## 9 · Comprobación con SAP2000
#: El mismo modelo en SAP2000 24: elemento **Plane** de deformación plana, sin modos incompatibles, con los mismos 205 nudos y las mismas fuerzas nodales. Desplazamientos en mm:
u_med = 1000·U(2·(n_y/2 + 1) - 1) [mm] 'a media altura, cara del relleno
v_lib = 1000·U(2·n_j) [mm] 'vertical en la coronación, cara libre
#hide
dif_1 = round(100·(u_cor - 1.655280)/1.655280, 4)
dif_2 = round(100·(u_med - 0.6424612)/0.6424612, 4)
dif_3 = round(100·(v_lib + 0.1021237)/0.1021237, 4)
#show
#| Desplazamiento [mm] | Esta hoja | SAP2000 | Diferencia [%] |
#|---|---:|---:|---:|
#| Horizontal en la coronación | @{u_cor} | 1.655280 | @{dif_1} |
#| Horizontal a media altura | @{u_med} | 0.6424612 | @{dif_2} |
#| Vertical en la coronación, cara libre | @{v_lib} | -0.1021237 | @{dif_3} |
#: En los 205 nudos, la mayor diferencia es de 6·10⁻⁹ % del desplazamiento máximo. La reacción horizontal en la base es 4.8 tonf/m, igual a la resultante del empuje.
