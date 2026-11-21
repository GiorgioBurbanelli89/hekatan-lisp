# Convergencia de malla de la losa apoyada frente a Navier
#numerico

#: La misma losa cuadrada apoyada y con carga uniforme, resuelta con el elemento BFS en mallas de 2 × 2, 4 × 4, 8 × 8 y 16 × 16. La pregunta: ¿cuánto se acerca la malla a la solución EXACTA de Navier al refinar? Toda la cadena (malla, rigidez, ensamblaje, apoyos, Cholesky, momentos) va dentro de UN bucle, una vuelta por malla.
#: **Unidades** (las de Calcpad): E en MPa y q en kN/m² → Z en **mm**; momentos en **kN·m/m**.

## 1 · Datos
a = 4 [m] 'lado en x
b = 4 [m] 'lado en y
t = 0.12 [m] 'espesor
q = 10 [kN/m²] 'carga repartida
E = 35000 [MPa] 'módulo de elasticidad
ν = 0.3 'coeficiente de Poisson (el de las tablas de Timoshenko)
D_p = E·t^3/(12·(1 - ν^2)) [MN·m] 'rigidez a flexión de la placa

## 2 · Solución exacta (Navier)
#: Placa apoyada en sus 4 bordes con carga uniforme: w = α·q·a⁴/D y Mx = β·q·a² en el centro. Timoshenko & Woinowsky-Krieger, *Theory of Plates and Shells*, 2.ª ed., Tabla 8 (p. 120), b/a = 1, ν = 0.3: α = 0.00406, β = 0.0479. La tabla da 3 cifras; la misma serie de Navier sumada con más términos (programa aparte, tests/placas_bfs/navier_levy.py, 400 × 400 términos) da α = 0.00406235 y β = 0.0478864, que son los que se usan para medir el error.
α_T = 0.00406 'Tabla 8
β_T = 0.0479 'Tabla 8
α_N = 0.00406235 'serie de Navier
β_N = 0.0478864 'serie de Navier
w_N = α_N·q·a^4/D_p [mm] 'flecha exacta en el centro
M_N = β_N·q·a^2 [kNm/m] 'momento exacto en el centro

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
#: (Aquí solo se escriben: se calculan dentro del bucle, porque a₁ y b₁ cambian con la malla.)

## 4 · El bucle de mallas
#: En cada vuelta: malla n × n, rigidez y carga del elemento (cambian con a₁ = a/n), ensamblaje, apoyos de borde (w y el giro a lo largo del borde, como en el ejemplo 71), Cholesky, y la flecha y el momento Mx del nudo central. El momento se toma del elemento de abajo a la izquierda del centro (M = −D·B·Z_{e} en su nudo 3); por simetría los 4 elementos que llegan al centro dan lo mismo.
m_s = [2, 4, 8, 16] 'elementos por lado
n = 16 'grados de libertad del elemento
k_1 = n/4
#hide
w_s = zeros(4, 1)
M_s = zeros(4, 1)
d_s = zeros(4, 1)
d_j(j) = k_1·(j - 1) + (1:k_1)
d_e(e) = [d_j(e_j(e, 1)), d_j(e_j(e, 2)), d_j(e_j(e, 3)), d_j(e_j(e, 4))]
#show
for k_m = 1:4
  n_a = m_s(k_m)
  n_b = n_a
  a_1 = a/n_a
  b_1 = b/n_b
  n_e = n_a·n_b
  n_j = (n_a + 1)·(n_b + 1)
  n_d = k_1·n_j
  K_e = a_1·b_1·integral2(@(ξ, η) transpose(B(ξ, η))·D·B(ξ, η), 0, 1, 0, 1)
  F_e = a_1·b_1·q·integral2(@(ξ, η) N(ξ, η), 0, 1, 0, 1)
  e_j = zeros(n_e, 4)
  for i_a = 1:n_a
    for i_b = 1:n_b
      e = i_b + n_b·(i_a - 1)
      j = e + i_a - 1
      e_j(e, 1:4) = [j, j + n_b + 1, j + n_b + 2, j + 1]
    end
  end
  K = zeros(n_d, n_d)
  F = zeros(n_d, 1)
  for e = 1:n_e
    g = d_e(e)
    K(g, g) = K(g, g) + K_e
    F(g) = F(g) + F_e
  end
  for i_a = 1:n_a + 1
    for i_b = 1:n_b + 1
      j = k_1·((i_a - 1)·(n_b + 1) + i_b - 1)
      if i_b == 1 || i_b == n_b + 1
        K(j + 1, j + 1) = K(j + 1, j + 1) + 10^20
        K(j + 2, j + 2) = K(j + 2, j + 2) + 10^20
      end
      if i_a == 1 || i_a == n_a + 1
        K(j + 1, j + 1) = K(j + 1, j + 1) + 10^20
        K(j + 3, j + 3) = K(j + 3, j + 3) + 10^20
      end
    end
  end
  Z = clsolve(K, F)
  j_c = (n_a/2)·(n_b + 1) + n_b/2 + 1
  e_c = (n_a/2 - 1)·n_b + n_b/2
  M_e = -D·B(1, 1)·Z(d_e(e_c))
  w_s(k_m) = Z(k_1·(j_c - 1) + 1)
  M_s(k_m) = M_e(1)
  d_s(k_m) = n_d
end
#: En un nudo de borde que es esquina se suman dos muelles en w: da igual, w ya queda fija.

## 5 · Resultados y verificación
#: Tabla de convergencia. Columnas: elementos por lado, grados de libertad, flecha central [mm], su error frente a Navier [%], Mx central [kN·m/m] y su error [%]:
#hide
C = zeros(4, 6)
for k = 1:4
  C(k, 1:6) = [m_s(k), d_s(k), w_s(k), round((w_s(k) - w_N)/w_N·100, 4), M_s(k), round((M_s(k) - M_N)/M_N·100, 4)]
end
#show
C
#: La flecha converge muy rápido (con 4 × 4 ya está a 0.07 % de la exacta) y el momento más despacio (sale de SEGUNDAS derivadas): +19 % con 2 × 2, +0.14 % con 16 × 16. Cada vez que se duplica la malla el error del momento baja unas 4 veces (orden h²).
#: **Otro programa, misma malla nudo a nudo:** Calcpad (*Rectangular Slab FEA* con estos datos, en las 4 mallas).
w_CP = [1.905605, 1.879084, 1.87779, 1.877715] [mm] 'Calcpad
M_CP = [9.152385, 7.874727, 7.705873, 7.672276] [kNm/m] 'Calcpad
dif_wCP = round(max(abs(w_s - w_CP)), 6) [mm] 'mayor diferencia en w
dif_MCP = round(max(abs(M_s - M_CP)), 6) [kNm/m] 'mayor diferencia en Mx
w_16 = w_s(4) [mm]
dif_w16 = round((w_16 - w_N)/w_N·100, 4) [%]
M_16 = M_s(4) [kNm/m]
dif_M16 = round((M_16 - M_N)/M_N·100, 4) [%]
w_T = α_T·q·a^4/D_p [mm] 'con el coeficiente de la tabla (3 cifras)
dif_wT = round((w_16 - w_T)/w_T·100, 4) [%]
M_T = β_T·q·a^2 [kNm/m]
dif_MT = round((M_16 - M_T)/M_T·100, 4) [%]
#| magnitud (malla 16 × 16) | referencia | referencia vale | Hekatan LISP | dif % |
#|---|---|--:|--:|--:|
#| w centro [mm] | Navier (serie) | @{w_N} | @{w_16} | @{dif_w16} |
#| Mx centro [kNm/m] | Navier (serie) | @{M_N} | @{M_16} | @{dif_M16} |
#| w centro [mm] | Timoshenko, Tabla 8 (p. 120) | @{w_T} | @{w_16} | @{dif_wT} |
#| Mx centro [kNm/m] | Timoshenko, Tabla 8 (p. 120) | @{M_T} | @{M_16} | @{dif_MT} |
#: Con Calcpad la mayor diferencia en las 4 mallas es la de arriba (dif_{wCP} y dif_{MCP}): 0 a 6 decimales. Frente a la Tabla 8 la diferencia es la del redondeo de α = 0.00406 (±0.12 %).
