# Análisis por elementos finitos de una losa rectangular
#numerico

#: Réplica, línea por línea, del ejemplo **Rectangular Slab FEA** de Calcpad (Ned Ganchovski): el mismo elemento de placa (rectángulo de 16 grados de libertad, funciones de Hermite), la misma malla de 6 × 4, las mismas cargas y los mismos apoyos. Aquí corre en Hekatan LISP con la directiva #numerico: la hoja entera es un programa con estado, como en Calcpad, y los bucles se escriben como en MATLAB.
#: **Unidades.** Como en Calcpad: E en MPa (= MN/m²) y q en kN/m². Entonces K sale en MN/m, F en kN y el cociente F/K en kN/(MN/m) = 10⁻³ m = **mm**. Los momentos −D·B·Z salen en MN·m · m⁻² · mm = **kN·m/m**. Por eso los números coinciden con los de Calcpad sin factores de conversión.

## 1 · Datos
a = 6 [m] 'largo de la losa
b = 4 [m] 'ancho de la losa
t = 0.1 [m] 'espesor
q = 10 [kN/m²] 'carga repartida
E = 35000 [MPa] 'módulo de elasticidad
ν = 0.15 'coeficiente de Poisson

## 2 · Malla de elementos finitos
#: Elemento rectangular con n grados de libertad: en cada uno de sus 4 nudos, la flecha w, los giros θx, θy y el alabeo ψ.
n = 16 'grados de libertad del elemento
n_a = 6 'elementos a lo largo de a
n_b = 4 'elementos a lo largo de b
n_e = n_a·n_b 'número de elementos
n_j = (n_a + 1)·(n_b + 1) 'número de nudos
a_1 = a/n_a [m] 'lado del elemento en x
b_1 = b/n_b [m] 'lado del elemento en y
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
#: Coordenadas de los nudos, numerados por columnas (de abajo arriba y de izquierda a derecha):
x_j [m]
y_j [m]
#: Nudos de cada elemento (una columna por elemento, en sentido antihorario desde la esquina inferior izquierda):
transpose(e_j)
#: Nudos apoyados:
s_j
#malla(x_j, y_j, e_j, s_j)

## 3 · Formulación del elemento
#: **Funciones base** (polinomios de Hermite en la coordenada natural ξ = x/a₁ ∈ [0, 1]): Φ₁ y Φ₃ dan la flecha de cada extremo, Φ₂ y Φ₄ el giro.
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
#: **Funciones de forma** de la placa: el PRODUCTO de una función en ξ por otra en η. Flechas w:
N_1w(ξ, η) = Φ_1a(ξ)·Φ_1b(η)
N_2w(ξ, η) = Φ_3a(ξ)·Φ_1b(η)
N_3w(ξ, η) = Φ_3a(ξ)·Φ_3b(η)
N_4w(ξ, η) = Φ_1a(ξ)·Φ_3b(η)
#: Giros θx:
N_1θx(ξ, η) = Φ_2a(ξ)·Φ_1b(η)
N_2θx(ξ, η) = Φ_4a(ξ)·Φ_1b(η)
N_3θx(ξ, η) = Φ_4a(ξ)·Φ_3b(η)
N_4θx(ξ, η) = Φ_2a(ξ)·Φ_3b(η)
#: Giros θy:
N_1θy(ξ, η) = Φ_1a(ξ)·Φ_2b(η)
N_2θy(ξ, η) = Φ_3a(ξ)·Φ_2b(η)
N_3θy(ξ, η) = Φ_3a(ξ)·Φ_4b(η)
N_4θy(ξ, η) = Φ_1a(ξ)·Φ_4b(η)
#: Alabeo ψ:
N_1ψ(ξ, η) = Φ_2a(ξ)·Φ_2b(η)
N_2ψ(ξ, η) = Φ_4a(ξ)·Φ_2b(η)
N_3ψ(ξ, η) = Φ_4a(ξ)·Φ_4b(η)
N_4ψ(ξ, η) = Φ_2a(ξ)·Φ_4b(η)
#: Vector de funciones de forma, en el orden de los grados de libertad (w, θx, θy, ψ de los nudos 1, 2, 3, 4):
N(ξ, η) = [N_1w(ξ, η), N_1θx(ξ, η), N_1θy(ξ, η), N_1ψ(ξ, η), N_2w(ξ, η), N_2θx(ξ, η), N_2θy(ξ, η), N_2ψ(ξ, η), N_3w(ξ, η), N_3θx(ξ, η), N_3θy(ξ, η), N_3ψ(ξ, η), N_4w(ξ, η), N_4θx(ξ, η), N_4θy(ξ, η), N_4ψ(ξ, η)]
#: **Matriz constitutiva** (momentos ↔ curvaturas):
D = E·t^3/(12·(1 - ν^2))·[1, ν, 0; ν, 1, 0; 0, 0, (1 - ν)/2]
#: **Matriz deformación–desplazamiento**: las filas son las curvaturas ∂²w/∂x², ∂²w/∂y² y 2·∂²w/∂x∂y de cada función de forma.
B_1(ξ, η) = [Φpprime_1a(ξ)·Φ_1b(η), Φpprime_2a(ξ)·Φ_1b(η), Φpprime_1a(ξ)·Φ_2b(η), Φpprime_2a(ξ)·Φ_2b(η), Φpprime_3a(ξ)·Φ_1b(η), Φpprime_4a(ξ)·Φ_1b(η), Φpprime_3a(ξ)·Φ_2b(η), Φpprime_4a(ξ)·Φ_2b(η), Φpprime_3a(ξ)·Φ_3b(η), Φpprime_4a(ξ)·Φ_3b(η), Φpprime_3a(ξ)·Φ_4b(η), Φpprime_4a(ξ)·Φ_4b(η), Φpprime_1a(ξ)·Φ_3b(η), Φpprime_2a(ξ)·Φ_3b(η), Φpprime_1a(ξ)·Φ_4b(η), Φpprime_2a(ξ)·Φ_4b(η)]
B_2(ξ, η) = [Φ_1a(ξ)·Φpprime_1b(η), Φ_2a(ξ)·Φpprime_1b(η), Φ_1a(ξ)·Φpprime_2b(η), Φ_2a(ξ)·Φpprime_2b(η), Φ_3a(ξ)·Φpprime_1b(η), Φ_4a(ξ)·Φpprime_1b(η), Φ_3a(ξ)·Φpprime_2b(η), Φ_4a(ξ)·Φpprime_2b(η), Φ_3a(ξ)·Φpprime_3b(η), Φ_4a(ξ)·Φpprime_3b(η), Φ_3a(ξ)·Φpprime_4b(η), Φ_4a(ξ)·Φpprime_4b(η), Φ_1a(ξ)·Φpprime_3b(η), Φ_2a(ξ)·Φpprime_3b(η), Φ_1a(ξ)·Φpprime_4b(η), Φ_2a(ξ)·Φpprime_4b(η)]
B_3(ξ, η) = 2·[Φprime_1a(ξ)·Φprime_1b(η), Φprime_2a(ξ)·Φprime_1b(η), Φprime_1a(ξ)·Φprime_2b(η), Φprime_2a(ξ)·Φprime_2b(η), Φprime_3a(ξ)·Φprime_1b(η), Φprime_4a(ξ)·Φprime_1b(η), Φprime_3a(ξ)·Φprime_2b(η), Φprime_4a(ξ)·Φprime_2b(η), Φprime_3a(ξ)·Φprime_3b(η), Φprime_4a(ξ)·Φprime_3b(η), Φprime_3a(ξ)·Φprime_4b(η), Φprime_4a(ξ)·Φprime_4b(η), Φprime_1a(ξ)·Φprime_3b(η), Φprime_2a(ξ)·Φprime_3b(η), Φprime_1a(ξ)·Φprime_4b(η), Φprime_2a(ξ)·Φprime_4b(η)]
B(ξ, η) = [B_1(ξ, η); B_2(ξ, η); B_3(ξ, η)]

## 4 · Matriz de rigidez y cargas del elemento
#: Cada término de la rigidez es una integral doble sobre el elemento (dx·dy = a₁·b₁·dξ·dη):
#noc
K_e = a_1·b_1·Area{Area{transpose(B(ξ, η))·D·B(ξ, η) @ ξ = 0 : 1} @ η = 0 : 1}
#equ
#: Calcpad la evalúa término a término con su integral numérica; aquí la hace integral2 (Gauss-Legendre adaptativa, exacta para estos polinomios) con la matriz entera de una vez:
#hide
K_e = a_1·b_1·integral2(@(ξ, η) transpose(B(ξ, η))·D·B(ξ, η), 0, 1, 0, 1)
#show
K_e [MN/m]
#: Vector de cargas del elemento: la carga q repartida con las mismas funciones de forma.
#noc
F_e = a_1·b_1·Area{Area{N(ξ, η)·q @ ξ = 0 : 1} @ η = 0 : 1}
#equ
#hide
F_e = a_1·b_1·q·integral2(@(ξ, η) N(ξ, η), 0, 1, 0, 1)
#show
F_e [kN]

## 5 · Ensamblaje y solución
#: Cuatro grados de libertad por nudo (k₁ = n/4). Los del nudo j son k₁·(j − 1) + 1 … k₁·j, y los del elemento, los de sus cuatro nudos seguidos:
k_1 = n/4
n_d = k_1·n_j 'grados de libertad de la losa
#hide
d_j(j) = k_1·(j - 1) + (1:k_1)
d_e(e) = [d_j(e_j(e, 1)), d_j(e_j(e, 2)), d_j(e_j(e, 3)), d_j(e_j(e, 4))]
K = zeros(n_d, n_d)
F = zeros(n_d, 1)
#show
#: Ensamblaje: la rigidez y la carga de cada elemento se SUMAN en las filas y columnas de sus grados de libertad.
for e = 1:n_e
  g = d_e(e)
  K(g, g) = K(g, g) + K_e
  F(g) = F(g) + F_e
end
#: Apoyos (borde simplemente apoyado): un muelle muy rígido k_s en la flecha de cada nudo del borde y en el giro a lo largo del borde, como en Calcpad.
k_s = 10^20
for i = 1:n_s
  j = k_1·(s_j(i) - 1) + 1
  K(j, j) = K(j, j) + k_s
  if y_j(s_j(i)) == 0 || y_j(s_j(i)) == b
    K(j + 1, j + 1) = K(j + 1, j + 1) + k_s
  end
  if x_j(s_j(i)) == 0 || x_j(s_j(i)) == a
    K(j + 2, j + 2) = K(j + 2, j + 2) + k_s
  end
end
#: Matriz de rigidez global (se muestran las esquinas):
K [MN/m]
#: Vector de cargas global:
F [kN]
#: Solución del sistema K·Z = F por Cholesky (clsolve, como en Calcpad: K es simétrica y definida positiva):
Z = clsolve(K, F) [mm]

## 6 · Resultados
#: Flechas de los nudos (fila = y, columna = x), redondeadas a 0.001 mm como en Calcpad:
#hide
W_z = zeros(n_a + 1, n_b + 1)
for i = 1:n_a + 1
  for j = 1:n_b + 1
    W_z(i, j) = round(Z(4·((i - 1)·(n_b + 1) + j) - 3)·1000)/1000
  end
end
#show
transpose(W_z) [mm]
#: Entre nudos, la flecha se interpola con el spline de Calcpad sobre la matriz de flechas:
w(x, y) = spline(1 + x/a_1, 1 + y/b_1, W_z)
#map(-w(x, y), [0 6], [0 4])
w(a/2, b/2) [mm] 'flecha máxima, en el centro

### Momentos flectores
#: En cada elemento, M = −D·B·Z_e en sus cuatro nudos; en cada nudo se promedian los elementos que llegan a él.
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
Mxy = zeros(n_a + 1, n_b + 1)
for i = 1:n_a + 1
  for k = 1:n_b + 1
    j = (i - 1)·(n_b + 1) + k
    Mx(i, k) = M_j(1, j)
    My(i, k) = M_j(2, j)
    Mxy(i, k) = M_j(3, j)
  end
end
i_c = round(n_a/2)
j_c = round(n_b/2)
#show
#: Resultados del elemento central e_c y de su primer nudo j₁:
e_c = (i_c - 1)·n_a + j_c + 1
j_1 = e_j(e_c, 1)
Z_e(e_c) [mm]
M_e(x, y) = -D·B(x/a_1, y/b_1)·Z_e(e_c)
M_e(0, 0) [kNm/m]
#: Momentos promedio en los nudos (filas: Mx, My, Mxy):
M_j [kNm/m]
#: **Mx** (fila = y, columna = x):
transpose(Mx) [kNm/m]
M_x(x, y) = spline(1 + x/a_1, 1 + y/b_1, Mx)
#map(M_x(x, y), [0 6], [0 4])
M_x(a/2, b/2) [kNm/m] 'máximo
#: **My**:
transpose(My) [kNm/m]
M_y(x, y) = spline(1 + x/a_1, 1 + y/b_1, My)
#map(M_y(x, y), [0 6], [0 4])
M_y(a/2, b/2) [kNm/m] 'máximo
#: **Mxy** (torsor):
transpose(Mxy) [kNm/m]
M_xy(x, y) = spline(1 + x/a_1, 1 + y/b_1, Mxy)
#map(M_xy(x, y), [0 6], [0 4])
M_xy(0, 0) [kNm/m] 'máximo, en la esquina
