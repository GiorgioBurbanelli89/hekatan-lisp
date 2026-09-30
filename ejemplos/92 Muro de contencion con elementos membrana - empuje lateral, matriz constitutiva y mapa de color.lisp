# Muro de contención por elementos finitos: la pantalla como membrana
#numerico

#: La pantalla de un muro en voladizo, de altura H y espesor t, empotrada en la zapata. Se estudia **una franja de 1 m** de muro con elementos **membrana** de cuatro nudos (dos desplazamientos por nudo: u_{x} y u_{y}), el mismo tipo de elemento con el que Hekatan Struct, ETABS y SAP2000 modelan un muro en su plano. El relleno empuja sobre la cara izquierda con el reparto triangular de Rankine.
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
#: La pantalla con su empotramiento y el empuje, que crece de cero en la coronación a p_{0} en la base:
#dibujo("La pantalla y el empuje del relleno", ud = m, cotas = m, ancho = 60, alto = 80)
#  rect(0, 0, 0.4, 4, "gruesa")
#  empotramiento(-0.6, 0, 1.0, 0, 1)
#  carga(0, 0, 0, 4, 1.2, 0, "", "azul", n = 9)
#  texto(-1.75, 2.1, "empuje", 2.6, "c", estilo = "azul")
#  texto(-0.9, -0.4, "2.4 tonf/m²", 2.6, "c", estilo = "azul")
#  cota(0.4, 0, 0.4, 4, -0.5, "H = 4.00")
#  cota(0, 4, 0.4, 4, 0.3, "t = 0.40")
#fin
#: La resultante es el área del triángulo y actúa a un tercio de la altura:
E_a = K_a·γ·H^2/2 [tonf/m]
M_0 = E_a·H/3 [tonf·m/m] 'momento en el empotramiento

## 3 · Matriz constitutiva
#: La matriz constitutiva relaciona las tensiones σ_{x}, σ_{y}, τ_{xy} con las deformaciones ε_{x}, ε_{y}, γ_{xy}. La membrana trabaja en **tensión plana**: no hay tensión perpendicular a su plano.
D = E/(1 - ν^2)·[1, ν, 0; ν, 1, 0; 0, 0, (1 - ν)/2]
#: En un muro muy largo la franja tampoco se puede deformar a lo largo del muro (deformación plana): la rigidez sube un 4 %, que es dividir el desplazamiento por 1/(1 − ν²) = 1.0417. Aquí se sigue con la tensión plana, que es la hipótesis de la membrana de los programas.

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
K_uu = (a_1·b_1/4)·Area{Area{transpose(B(ξ, η))·D·B(ξ, η) @ ξ = -1 : 1} @ η = -1 : 1}
#equ
#hide
K_uu = (a_1·b_1/4)·integral2(@(ξ, η) transpose(B(ξ, η))·D·B(ξ, η), -1, 1, -1, 1)
#show
#: **Modos incompatibles.** El elemento de cuatro nudos solo sabe deformarse con lados rectos, y en flexión eso lo hace demasiado rígido. Se le añaden dos formas curvas, 1 − ξ² y 1 − η², para u y para v (Wilson y Taylor); es el elemento que usan SAP2000 y ETABS. Sus deformaciones son la matriz G:
G(ξ, η) = [-4·ξ/a_1, 0, 0, 0; 0, 0, 0, -4·η/b_1; 0, -4·ξ/a_1, -4·η/b_1, 0]
#hide
K_ua = (a_1·b_1/4)·integral2(@(ξ, η) transpose(B(ξ, η))·D·G(ξ, η), -1, 1, -1, 1)
K_aa = (a_1·b_1/4)·integral2(@(ξ, η) transpose(G(ξ, η))·D·G(ξ, η), -1, 1, -1, 1)
#show
#: Esas formas no tienen nudo propio: se eliminan dentro del elemento (condensación estática) y queda la rigidez de 8 × 8:
K_e = K_uu - K_ua·(K_aa\transpose(K_ua))

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
#: **Deformada con mapa de color.** El muro dibujado con sus desplazamientos ampliados 200 veces y pintado con el desplazamiento horizontal u_{x} en mm. Al pasar el cursor sale el valor en ese punto:
#hide
X_n = zeros(n_j, 3)
U_3 = zeros(n_j, 3)
u_x = zeros(n_j, 1)
for j = 1:n_j
  X_n(j, 1) = x_j(j)
  X_n(j, 2) = y_j(j)
  U_3(j, 1) = U(2·j - 1)
  U_3(j, 2) = U(2·j)
  u_x(j) = 1000·U(2·j - 1)
end
e_f = zeros(0, 2)
v_f = zeros(0, 2)
#show
#modelo3d(X_n, e_j, e_f, u_x, v_f, U_3, 200)
#: El mismo desplazamiento como **mapa de color** sobre la pantalla sin deformar, con el espesor ampliado para ver lo que pasa dentro:
u_xy(x, y) = spline(1 + x/a_1, 1 + y/b_1, U_x)
#map(u_xy(x, y), [0 0.4], [0 4])

### Tensiones
#: En cada elemento σ = D·(B·U_{e} + G·α_{e}), con α_{e} la amplitud de los modos incompatibles, evaluada en sus cuatro nudos; en cada nudo se promedian los elementos que llegan a él. Se pasa a kgf/cm² dividiendo por 10.
#hide
ξ_n = [-1, 1, 1, -1]
η_n = [-1, -1, 1, 1]
S_j = zeros(3, n_j)
c_j = zeros(n_j, 1)
for e = 1:n_e
  U_e = U(d_e(e))
  α_e = -(K_aa\(transpose(K_ua)·U_e))
  for i = 1:4
    j = e_j(e, i)
    c_j(j) = c_j(j) + 1
    S_j(:, j) = S_j(:, j) + D·(B(ξ_n(i), η_n(i))·U_e + G(ξ_n(i), η_n(i))·α_e)/10
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
#: La pantalla es un voladizo con carga triangular. A la flecha de flexión se le suma la de cortante (viga de Timoshenko, con área de cortante 5/6 de la sección y G = E/(2·(1 + ν))):
I = t^3/12 [m⁴/m]
δ_flex = 1000·p_0·H^4/(30·E·I) [mm]
δ_cort = 1000·p_0·H^2/(6·(5/6)·(E/(2·(1 + ν)))·t) [mm]
δ_viga = δ_flex + δ_cort [mm]
σ_viga = M_0·(t/2)/I/10 [kgf/cm²]
dif = 100·(u_cor - δ_viga)/δ_viga [%]

## 9 · Comprobación con SAP2000 y con Hekatan Struct
#: **SAP2000 24**: elemento Plane de tensión plana con modos incompatibles, los mismos 205 nudos y las mismas fuerzas nodales. Es el mismo elemento de esta hoja. **Hekatan Struct**: el mismo muro con su cáscara, cuya membrana lleva además el giro en el plano (elemento de Ibrahimbegović, Taylor y Wilson, 1990); es otro elemento y por eso no coincide en todas las cifras.
u_med = 1000·U(2·(n_y/2 + 1) - 1) [mm] 'a media altura, cara del relleno
v_lib = 1000·U(2·n_j) [mm] 'vertical en la coronación, cara libre
#hide
dif_1 = round(100·(u_cor - 1.774773)/1.774773, 4)
dif_2 = round(100·(u_med - 0.6884897)/0.6884897, 4)
dif_3 = round(100·(v_lib + 0.1095972)/0.1095972, 4)
dis_1 = round(100·(1.773183 - u_cor)/u_cor, 2)
dis_2 = round(100·(0.6877718 - u_med)/u_med, 2)
dis_3 = round(100·(-0.1095110 - v_lib)/v_lib, 2)
#show
#| Desplazamiento [mm] | Esta hoja | SAP2000 | dif. [%] | Hekatan Struct | dif. [%] |
#|---|---:|---:|---:|---:|---:|
#| Horizontal en la coronación | @{u_cor} | 1.774773 | @{dif_1} | 1.773183 | @{dis_1} |
#| Horizontal a media altura | @{u_med} | 0.6884897 | @{dif_2} | 0.6877718 | @{dis_2} |
#| Vertical en la coronación, cara libre | @{v_lib} | -0.1095972 | @{dif_3} | -0.1095110 | @{dis_3} |
#: Con SAP2000 la mayor diferencia en los 205 nudos es de 8·10⁻⁹ % del desplazamiento máximo; con Hekatan Struct, de 0.09 %. La reacción horizontal en la base es 4.8 tonf/m en los tres, igual a la resultante del empuje.
