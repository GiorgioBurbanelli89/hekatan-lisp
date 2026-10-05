# Funciones de forma del elemento BFS y refinamiento h de la losa
#numerico

#: Dos animaciones sobre el elemento de placa de los ejemplos 71 y 73 a 78 (Bogner–Fox–Schmit, 16 grados de libertad). La primera recorre sus 16 funciones de forma, deducidas aquí por el motor; la segunda refina la malla de la losa apoyada, de 2 × 2 a 16 × 16 elementos, y compara la flecha del centro con la solución exacta de Navier. Cada animación tiene ▶/⏸, barra de cuadro y narración (botón 🔊, si el equipo tiene voz en español).

## 1 · Las cuatro cúbicas de Hermite, deducidas
#: En la coordenada natural ξ = x/a₁ ∈ [0, 1] la flecha a lo largo de un lado es una cúbica, v(ξ) = c₁ + c₂·ξ + c₃·ξ² + c₄·ξ³: cuatro constantes para cuatro datos, la flecha y la pendiente dv/dξ en ξ = 0 y en ξ = 1. Cada fila de C es uno de esos datos evaluado sobre la base [1, ξ, ξ², ξ³]:
C_H = Simplify{[1, 0, 0, 0; 0, 1, 0, 0; 1, 1, 1, 1; 0, 1, 2, 3]}
#: La función de forma Hᵢ vale 1 en su dato i y 0 en los otros tres: sus coeficientes cumplen C·c = eᵢ (el vector con un 1 en la fila i), o sea, son la columna i de C⁻¹. El motor invierte C:
A_H = Expand{C_H^-1}
#: Y cada Hermite es la base por su columna:
H_1 = Expand{[1, ξ, ξ^2, ξ^3]·C_H^-1·[1; 0; 0; 0]}
H_2 = Expand{[1, ξ, ξ^2, ξ^3]·C_H^-1·[0; 1; 0; 0]}
H_3 = Expand{[1, ξ, ξ^2, ξ^3]·C_H^-1·[0; 0; 1; 0]}
H_4 = Expand{[1, ξ, ξ^2, ξ^3]·C_H^-1·[0; 0; 0; 1]}
#: Las mismas en la otra dirección, η = y/b₁:
G_1 = Expand{[1, η, η^2, η^3]·C_H^-1·[1; 0; 0; 0]}
G_2 = Expand{[1, η, η^2, η^3]·C_H^-1·[0; 1; 0; 0]}
G_3 = Expand{[1, η, η^2, η^3]·C_H^-1·[0; 0; 1; 0]}
G_4 = Expand{[1, η, η^2, η^3]·C_H^-1·[0; 0; 0; 1]}
#: Comprobación: son las mismas que usa el cálculo de la sección 3 (las del ejemplo 78, verificado contra Calcpad). Las de giro llevan allí el factor a₁, porque el giro es dw/dx = (1/a₁)·dw/dξ. Cada resta da cero:
r_1 = Simplify{H_1 - (1 - ξ^2·(3 - 2·ξ))}
r_2 = Simplify{H_2 - ξ·(1 - ξ·(2 - ξ))}
r_3 = Simplify{H_3 - ξ^2·(3 - 2·ξ)}
r_4 = Simplify{H_4 - ξ^2·(-1 + ξ)}

## 2 · Las 16 funciones de forma del BFS
#: Cada función de forma de la placa es el PRODUCTO de una Hermite en ξ por otra en η. En cada nudo hay cuatro grados de libertad: la flecha w, los giros θx = ∂w/∂x y θy = ∂w/∂y, y el alabeo ψ = ∂²w/∂x∂y. Nudos: 1 en (0, 0), 2 en (1, 0), 3 en (1, 1) y 4 en (0, 1). En el orden de los grados de libertad (el mismo del vector N del ejemplo 78):
N_1 = Expand{H_1·G_1}
N_2 = Expand{H_2·G_1}
N_3 = Expand{H_1·G_2}
N_4 = Expand{H_2·G_2}
N_5 = Expand{H_3·G_1}
N_6 = Expand{H_4·G_1}
N_7 = Expand{H_3·G_2}
N_8 = Expand{H_4·G_2}
N_9 = Expand{H_3·G_3}
N_10 = Expand{H_4·G_3}
N_11 = Expand{H_3·G_4}
N_12 = Expand{H_4·G_4}
N_13 = Expand{H_1·G_3}
N_14 = Expand{H_2·G_3}
N_15 = Expand{H_1·G_4}
N_16 = Expand{H_2·G_4}
#: Cada superficie es la deformada del elemento de lado 1 cuando UN grado de libertad vale 1 y los otros quince valen 0. La escala vertical es la de cada función (las de giro y alabeo son mucho más bajas que las de flecha: el rótulo da su mínimo y su máximo). Se gira con el ratón.
#anim surf(N_{k}, [0 1], [0 1]), k = 1:16
#voz: Función 1: flecha unitaria en el nudo 1, la esquina de origen. Vale 1 allí y 0 en los otros tres nudos; las pendientes en todos los nudos son nulas.
#voz: Función 2: giro unitario theta x en el nudo 1. La flecha es nula en los cuatro nudos; la superficie sale del nudo 1 con pendiente 1 en la dirección x.
#voz: Función 3: giro unitario theta y en el nudo 1. Es la función 2 con x e y intercambiadas: pendiente 1 en la dirección y.
#voz: Función 4: alabeo unitario psi en el nudo 1. Flecha y giros son nulos en los cuatro nudos; solo la derivada cruzada vale 1 en el nudo 1. La superficie es una loma muy baja junto a ese nudo: su máximo es 0.022.
#voz: Función 5: flecha unitaria en el nudo 2, en x igual a 1.
#voz: Función 6: giro theta x en el nudo 2. Pendiente 1 en x en ese nudo; por eso queda por debajo del plano.
#voz: Función 7: giro theta y en el nudo 2.
#voz: Función 8: alabeo en el nudo 2.
#voz: Función 9: flecha unitaria en el nudo 3, la esquina opuesta al origen.
#voz: Función 10: giro theta x en el nudo 3.
#voz: Función 11: giro theta y en el nudo 3.
#voz: Función 12: alabeo en el nudo 3.
#voz: Función 13: flecha unitaria en el nudo 4, en y igual a 1.
#voz: Función 14: giro theta x en el nudo 4.
#voz: Función 15: giro theta y en el nudo 4.
#voz: Función 16: alabeo en el nudo 4. Con las dieciséis, la flecha y sus pendientes son continuas de un elemento al siguiente: por eso el elemento sirve para la placa delgada de Kirchhoff.

## 3 · La losa y su solución exacta
#: Losa cuadrada simplemente apoyada en los 4 bordes, carga uniforme (la del ejemplo 78). Unidades de Calcpad: E en MPa y q en kN/m², de modo que la flecha sale en mm y el momento en kN·m/m.
a = 4 [m] 'lado en x
b = 4 [m] 'lado en y
t = 0.12 [m] 'espesor
q = 10 [kN/m²] 'carga repartida
E = 35000 [MPa] 'módulo de elasticidad
ν = 0.3 'coeficiente de Poisson
D_p = E·t^3/(12·(1 - ν^2)) [MN·m] 'rigidez a flexión
#: **Navier** (Timoshenko y Woinowsky-Krieger, *Theory of Plates and Shells*, § 30): la flecha es la doble serie w = 16·q/(π⁶·D)·Σ Σ sin(mπx/a)·sin(nπy/b)/(m·n·(m²/a² + n²/b²)²), con m y n impares. En el centro sin(mπ/2)·sin(nπ/2) = ±1. El motor la suma con 200 × 200 términos (la cola que queda es menor que 10⁻¹² mm):
#hide
s_N = 0
s_M = 0
for i_m = 1:200
  for i_n = 1:200
    m_N = 2·i_m - 1
    n_N = 2·i_n - 1
    s_N = s_N + (-1)^(i_m + i_n)/(m_N·n_N·(m_N^2/a^2 + n_N^2/b^2)^2)
    s_M = s_M + (-1)^(i_m + i_n)·(m_N^2/a^2 + ν·n_N^2/b^2)/(m_N·n_N·(m_N^2/a^2 + n_N^2/b^2)^2)
  end
end
#show
w_N = 16·q/(pi^6·D_p)·s_N [mm] 'flecha exacta en el centro
α_N = w_N·D_p/(q·a^4) 'coeficiente adimensional
#: El momento del centro sale de derivar dos veces la misma serie: Mx = 16·q/π⁴·Σ Σ (m²/a² + ν·n²/b²)·sin(mπx/a)·sin(nπy/b)/(m·n·(m²/a² + n²/b²)²).
M_N = 16·q/pi^4·s_M [kNm/m] 'momento exacto en el centro
β_N = M_N/(q·a^2) 'coeficiente adimensional
#: Los dos coinciden con la Tabla 8 (p. 120) del libro para b/a = 1 y ν = 0.3: α = 0.00406 y β = 0.0479.

## 4 · El elemento, en números
#: Las Hermite de la sección 1, ya con el largo del elemento a₁ (y b₁ en η), y sus derivadas; son las del ejemplo 78.
Φ_1a(ξ) = 1 - ξ^2·(3 - 2·ξ)
Φ_2a(ξ) = ξ·a_1·(1 - ξ·(2 - ξ))
Φ_3a(ξ) = ξ^2·(3 - 2·ξ)
Φ_4a(ξ) = ξ^2·a_1·(-1 + ξ)
Φprime_1a(ξ) = -6·(ξ/a_1)·(1 - ξ)
Φprime_2a(ξ) = 1 - ξ·(4 - 3·ξ)
Φprime_3a(ξ) = 6·(ξ/a_1)·(1 - ξ)
Φprime_4a(ξ) = -ξ·(2 - 3·ξ)
Φpprime_1a(ξ) = -(6/a_1^2)·(1 - 2·ξ)
Φpprime_2a(ξ) = -(2/a_1)·(2 - 3·ξ)
Φpprime_3a(ξ) = 6/a_1^2·(1 - 2·ξ)
Φpprime_4a(ξ) = -(2/a_1)·(1 - 3·ξ)
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
#: Funciones de forma (en el orden N_1 … N_16 de la sección 2), constitutiva y matriz de curvaturas B:
N(ξ, η) = [Φ_1a(ξ)·Φ_1b(η), Φ_2a(ξ)·Φ_1b(η), Φ_1a(ξ)·Φ_2b(η), Φ_2a(ξ)·Φ_2b(η), Φ_3a(ξ)·Φ_1b(η), Φ_4a(ξ)·Φ_1b(η), Φ_3a(ξ)·Φ_2b(η), Φ_4a(ξ)·Φ_2b(η), Φ_3a(ξ)·Φ_3b(η), Φ_4a(ξ)·Φ_3b(η), Φ_3a(ξ)·Φ_4b(η), Φ_4a(ξ)·Φ_4b(η), Φ_1a(ξ)·Φ_3b(η), Φ_2a(ξ)·Φ_3b(η), Φ_1a(ξ)·Φ_4b(η), Φ_2a(ξ)·Φ_4b(η)]
D = D_p·[1, ν, 0; ν, 1, 0; 0, 0, (1 - ν)/2]
B_1(ξ, η) = [Φpprime_1a(ξ)·Φ_1b(η), Φpprime_2a(ξ)·Φ_1b(η), Φpprime_1a(ξ)·Φ_2b(η), Φpprime_2a(ξ)·Φ_2b(η), Φpprime_3a(ξ)·Φ_1b(η), Φpprime_4a(ξ)·Φ_1b(η), Φpprime_3a(ξ)·Φ_2b(η), Φpprime_4a(ξ)·Φ_2b(η), Φpprime_3a(ξ)·Φ_3b(η), Φpprime_4a(ξ)·Φ_3b(η), Φpprime_3a(ξ)·Φ_4b(η), Φpprime_4a(ξ)·Φ_4b(η), Φpprime_1a(ξ)·Φ_3b(η), Φpprime_2a(ξ)·Φ_3b(η), Φpprime_1a(ξ)·Φ_4b(η), Φpprime_2a(ξ)·Φ_4b(η)]
B_2(ξ, η) = [Φ_1a(ξ)·Φpprime_1b(η), Φ_2a(ξ)·Φpprime_1b(η), Φ_1a(ξ)·Φpprime_2b(η), Φ_2a(ξ)·Φpprime_2b(η), Φ_3a(ξ)·Φpprime_1b(η), Φ_4a(ξ)·Φpprime_1b(η), Φ_3a(ξ)·Φpprime_2b(η), Φ_4a(ξ)·Φpprime_2b(η), Φ_3a(ξ)·Φpprime_3b(η), Φ_4a(ξ)·Φpprime_3b(η), Φ_3a(ξ)·Φpprime_4b(η), Φ_4a(ξ)·Φpprime_4b(η), Φ_1a(ξ)·Φpprime_3b(η), Φ_2a(ξ)·Φpprime_3b(η), Φ_1a(ξ)·Φpprime_4b(η), Φ_2a(ξ)·Φpprime_4b(η)]
B_3(ξ, η) = 2·[Φprime_1a(ξ)·Φprime_1b(η), Φprime_2a(ξ)·Φprime_1b(η), Φprime_1a(ξ)·Φprime_2b(η), Φprime_2a(ξ)·Φprime_2b(η), Φprime_3a(ξ)·Φprime_1b(η), Φprime_4a(ξ)·Φprime_1b(η), Φprime_3a(ξ)·Φprime_2b(η), Φprime_4a(ξ)·Φprime_2b(η), Φprime_3a(ξ)·Φprime_3b(η), Φprime_4a(ξ)·Φprime_3b(η), Φprime_3a(ξ)·Φprime_4b(η), Φprime_4a(ξ)·Φprime_4b(η), Φprime_1a(ξ)·Φprime_3b(η), Φprime_2a(ξ)·Φprime_3b(η), Φprime_1a(ξ)·Φprime_4b(η), Φprime_2a(ξ)·Φprime_4b(η)]
B(ξ, η) = [B_1(ξ, η); B_2(ξ, η); B_3(ξ, η)]
#: Rigidez y carga del elemento (integrales dobles sobre el rectángulo, dx·dy = a₁·b₁·dξ·dη):
#noc
K_e = a_1·b_1·Area{Area{transpose(B(ξ, η))·D·B(ξ, η) @ ξ = 0 : 1} @ η = 0 : 1}
F_e = a_1·b_1·Area{Area{N(ξ, η)·q @ ξ = 0 : 1} @ η = 0 : 1}
#equ
#hide
n_g = 16
k_1 = n_g/4
d_j(j) = k_1·(j - 1) + (1:k_1)
d_e(e) = [d_j(e_j(e, 1)), d_j(e_j(e, 2)), d_j(e_j(e, 3)), d_j(e_j(e, 4))]
w_s = zeros(8, 1)
M_s = zeros(8, 1)
g_s = zeros(8, 1)
#show

## 5 · Refinamiento h: de 2 × 2 a 16 × 16 elementos
#: h = a/n es el lado del elemento. En cada cuadro el motor arma la malla n × n, la rigidez y la carga de cada elemento (cambian con a₁ = h), ensambla, pone los apoyos (w y el giro a lo largo del borde, como en el ejemplo 71), resuelve por Cholesky y lee la flecha y el momento Mx del nudo central.
#anim(n = 2:2:16)
### Malla de {n} × {n} elementos
#hide
a_1 = a/n
b_1 = b/n
n_e = n^2
n_j = (n + 1)^2
n_d = k_1·n_j
K_e = a_1·b_1·integral2(@(ξ, η) transpose(B(ξ, η))·D·B(ξ, η), 0, 1, 0, 1)
F_e = a_1·b_1·q·integral2(@(ξ, η) N(ξ, η), 0, 1, 0, 1)
x_j = zeros(n_j, 1)
y_j = zeros(n_j, 1)
e_j = zeros(n_e, 4)
for i_a = 1:n + 1
  for i_b = 1:n + 1
    x_j((i_a - 1)·(n + 1) + i_b) = (i_a - 1)·a_1
    y_j((i_a - 1)·(n + 1) + i_b) = (i_b - 1)·b_1
  end
end
for i_a = 1:n
  for i_b = 1:n
    e = i_b + n·(i_a - 1)
    j = e + i_a - 1
    e_j(e, 1:4) = [j, j + n + 1, j + n + 2, j + 1]
  end
end
K = zeros(n_d, n_d)
F = zeros(n_d, 1)
for e = 1:n_e
  g = d_e(e)
  K(g, g) = K(g, g) + K_e
  F(g) = F(g) + F_e
end
s_j = zeros(4·n, 1)
i_s = 0
for i_a = 1:n + 1
  for i_b = 1:n + 1
    j = k_1·((i_a - 1)·(n + 1) + i_b - 1)
    if i_b == 1 || i_b == n + 1
      K(j + 1, j + 1) = K(j + 1, j + 1) + 10^20
      K(j + 2, j + 2) = K(j + 2, j + 2) + 10^20
    end
    if i_a == 1 || i_a == n + 1
      K(j + 1, j + 1) = K(j + 1, j + 1) + 10^20
      K(j + 3, j + 3) = K(j + 3, j + 3) + 10^20
    end
    if i_a == 1 || i_a == n + 1 || i_b == 1 || i_b == n + 1
      i_s = i_s + 1
      s_j(i_s) = (i_a - 1)·(n + 1) + i_b
    end
  end
end
Z = clsolve(K, F)
W_z = zeros(n + 1, n + 1)
for i_a = 1:n + 1
  for i_b = 1:n + 1
    W_z(i_a, i_b) = Z(4·((i_a - 1)·(n + 1) + i_b) - 3)
  end
end
w(x, y) = spline(1 + x/a_1, 1 + y/b_1, W_z)
j_c = (n/2)·(n + 1) + n/2 + 1
e_c = (n/2 - 1)·n + n/2
M_e = -D·B(1, 1)·Z(d_e(e_c))
w_s(n/2) = Z(k_1·(j_c - 1) + 1)
M_s(n/2) = M_e(1)
g_s(n/2) = n_d
#show
#malla(x_j, y_j, e_j, s_j)
#map(-w(x, y), [0 4], [0 4])
h = a/n [m] 'lado del elemento
w_c = w_s(n/2) [mm] 'flecha en el centro
e_w = round((w_c - w_N)/w_N·100, 5) [%] 'diferencia con Navier
#voz: Malla de {n} por {n} elementos, h = @{h} metros: la flecha del centro difiere de la de Navier en @{e_w} por ciento.
#finanim
#voz: Con 2 por 2 elementos la losa entera tiene 9 nudos y la deformada es gruesa: la flecha del centro queda un 1.5 por ciento por encima de la exacta.
#voz: Con 4 por 4 el error baja unas veinte veces. Cada elemento reproduce ya una cúbica completa en cada dirección.
#voz: Con 6 por 6 la diferencia es de centésimas de por ciento.
#voz: Con 8 por 8, h es la cuarta parte que con 2 por 2, y el error es cientos de veces menor.
#voz: A partir de aquí la malla casi no cambia a la vista: la flecha ya está convergida.
#voz: Doce por doce: el error sigue bajando al mismo ritmo.
#voz: Catorce por catorce.
#voz: Dieciséis por dieciséis: mil ciento cincuenta y seis grados de libertad, y la flecha coincide con Navier en cinco cifras.

## 6 · El error y su orden de convergencia
#: Si el error se comporta como e ≈ C·hᵖ, entre dos mallas seguidas p = ln(e₁/e₂)/ln(h₁/h₂). El orden p sale de los números de la tabla, no se supone.
#hide
T = zeros(8, 9)
for k = 1:8
  n_k = 2·k
  e_wk = (w_s(k) - w_N)/w_N·100
  e_Mk = (M_s(k) - M_N)/M_N·100
  T(k, 1:5) = [n_k, a/n_k, g_s(k), w_s(k), e_wk]
  T(k, 7:8) = [M_s(k), e_Mk]
  if k > 1
    T(k, 6) = ln(T(k - 1, 5)/e_wk)/ln(T(k - 1, 2)/T(k, 2))
    T(k, 9) = ln(T(k - 1, 8)/e_Mk)/ln(T(k - 1, 2)/T(k, 2))
  end
end
#show
#: Columnas: n, h [m], grados de libertad, flecha central [mm], su error frente a Navier [%], orden p de la flecha (entre esa malla y la anterior), Mx central [kN·m/m], su error [%] y su orden p:
T
p_w = T(8, 6) 'orden de la flecha entre 14 × 14 y 16 × 16
p_M = T(8, 9) 'orden del momento entre 14 × 14 y 16 × 16
#: El orden de la flecha sale 4.01: al dividir h entre dos el error se divide entre unas dieciséis. La razón: dentro de cada elemento la flecha es un producto de cúbicas completas, y el error de interpolación con polinomios de grado 3 es del orden de h⁴. El momento sale de SEGUNDAS derivadas de esa flecha, y cada derivada pierde un orden: su error baja como h² (p = 2.04), bastante más despacio. Con una malla fina el error del momento todavía se nota cuando el de la flecha ya no.
#voz: El orden de convergencia de la flecha sale cercano a cuatro: al partir el elemento por la mitad, el error se divide entre dieciséis. El momento, que sale de segundas derivadas, converge con orden dos.
#: **Otro programa, misma malla nudo a nudo:** Calcpad (*Rectangular Slab FEA* con estos datos) da las flechas centrales de las 8 mallas (los HTML de Calcpad están en la carpeta de pruebas de las placas BFS):
#val
w_CP = [1.905605; 1.879084; 1.877967; 1.87779; 1.877742; 1.877725; 1.877718; 1.877715] [mm] 'Calcpad, una malla por fila
#equ
dif_CP = round(max(abs(w_s - w_CP)), 6) [mm] 'mayor diferencia
