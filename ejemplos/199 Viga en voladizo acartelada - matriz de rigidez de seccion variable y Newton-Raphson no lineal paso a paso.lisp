# Viga en voladizo acartelada: la matriz de rigidez de sección variable y Newton-Raphson no lineal paso a paso
#numerico

## 0 · Recordatorio: Newton en la barra (hojas 196 y 198)
#: Una barra que se ablanda es un **resorte cuya rigidez baja** al deformarse. Newton: en cada paso se usa la **rigidez del momento** (la pendiente de la curva, la tangente) como si fuera lineal, se calcula cuánto falta (**residuo** = carga − lo que la barra ya da) y se avanza **Δd = residuo / rigidez tangente**. Se repite hasta que el residuo es cero. Barra de EA = 60 000 kN, L = 3 m, N_u = 300 kN, P = 240 kN:
#hide
k_b = 20000
N_b = 300
P_b = 240
T_b = zeros(6, 4)
d_b = 0
for i = 1:6
  N_i = k_b·d_b/(1 + k_b·d_b/N_b)
  t_i = k_b/(1 + k_b·d_b/N_b)^2
  T_b(i, 1) = 1000·d_b
  T_b(i, 2) = N_i
  T_b(i, 3) = t_i
  T_b(i, 4) = P_b - N_i
  d_b = d_b + (P_b - N_i)/t_i
end
p_b = zeros(6, 1)
for i = 1:6
  p_b(i) = i
end
#show
#tabla("paso:0","d [mm]:2","la barra da [kN]:1","rigidez del momento [kN/m]:0","falta [kN]:2")(p_b; T_b(1:6, 1); T_b(1:6, 2); T_b(1:6, 3); T_b(1:6, 4))
#: **La viga es lo mismo**, solo que ahora hay dos incógnitas en la punta (la flecha v y el giro θ) y muchas en los nudos interiores: la «rigidez del momento» es una **matriz K_T** y el paso es **K_T·Δu = R**.

## 1 · La viga acartelada y su matriz de rigidez (lineal)
#dibujo("Voladizo acartelado: empotrado a la izquierda, carga P en la punta", ud = m, escala = auto, cotas = m, alto = 80)
#  achurado([-0.25, 0, 0, -0.25], [-0.45, -0.45, 0.45, 0.45], "suelo")
#  poligono(0, -0.3, 3, -0.15, 3, 0.15, 0, 0.3, "gruesa")
#  flecha(3, 1.0, 3, 0.18, "gruesa rojo")
#  texto(3.25, 0.9, "P", 2.6, "c")
#  cota(0, -0.6, 3, -0.6, 0, "L = 3.00 m")
#  cota(-0.45, -0.3, -0.45, 0.3, 0, "h₀ = 0.60")
#  cota(3.35, -0.15, 3.35, 0.15, 0, "h₁ = 0.30")
#  texto(1.5, 0.55, "b = 0.30 m constante; la altura baja en línea recta (cartela)", 2.2, "c")
#fin
#: **La idea:** la rigidez de una viga es «cuánto se resiste a curvarse». Si la sección cambia, cada tramo aporta según SU inercia I(x): la matriz se arma **sumando (integrando) a lo largo de la viga**.
### Primero con símbolos
#: **Funciones de forma de Hermite** (cómo se reparte la flecha entre los dos nudos de un elemento de largo L): flecha y giro en cada extremo:
N_1 = Simplify{1 - 3*x^2/L^2 + 2*x^3/L^3}
N_2 = Simplify{x - 2*x^2/L + x^3/L^2}
N_3 = Simplify{3*x^2/L^2 - 2*x^3/L^3}
N_4 = Simplify{-x^2/L + x^3/L^2}
#: La **curvatura** es la segunda derivada de la flecha: κ = v″ = Σ Nᵢ″·uᵢ. Las Nᵢ″ forman la matriz **B**:
B_1 = Simplify{Diff{Diff{1 - 3*x^2/L^2 + 2*x^3/L^3 @ x} @ x}}
B_2 = Simplify{Diff{Diff{x - 2*x^2/L + x^3/L^2 @ x} @ x}}
B_3 = Simplify{Diff{Diff{3*x^2/L^2 - 2*x^3/L^3 @ x} @ x}}
B_4 = Simplify{Diff{Diff{-x^2/L + x^3/L^2 @ x} @ x}}
#: **La matriz de rigidez:** K = ∫ EI(x)·Bᵀ·B dx. Con **EI constante** salen los números que todos conocemos:
k_11 = Simplify{Area{E_I*(12*x/L^3 - 6/L^2)^2 @ x = 0 : L}}
k_12 = Simplify{Area{E_I*(12*x/L^3 - 6/L^2)*(6*x/L^2 - 4/L) @ x = 0 : L}}
k_22 = Simplify{Area{E_I*(6*x/L^2 - 4/L)^2 @ x = 0 : L}}
k_24 = Simplify{Area{E_I*(6*x/L^2 - 4/L)*(6*x/L^2 - 2/L) @ x = 0 : L}}
#: (12EI/L³, 6EI/L², 4EI/L y 2EI/L). **Con la cartela** EI ya no sale de la integral: I(x) = b·h(x)³/12 con la altura en línea recta:
h_x = Simplify{h_0 + (h_1 - h_0)*x/L}
I_x = Simplify{b*(h_0 + (h_1 - h_0)*x/L)^3/12}
#: y el integrando EI(x)·Bᵢ·Bⱼ es un polinomio de grado 5: se integra con Gauss (3 puntos lo hacen exacto). Pero un SOLO elemento de Hermite (flecha cúbica) no puede seguir la forma real de una viga acartelada, así que también se calcula la **matriz exacta por flexibilidad**: el voladizo es isostático, una fuerza o un momento en la punta dan el momento M(x) sin resolver nada, y la flecha y el giro de la punta salen de integrar M/EI:
f_vv = Simplify{(L - x)^2/E_I}
f_vt = Simplify{(L - x)/E_I}
f_tt = Simplify{1/E_I}
#: (cada uno integrado de 0 a L con la EI(x) de la cartela). La matriz de flexibilidad F de la punta es [f_vv f_vθ; f_vθ f_θθ] y la de rigidez es su **inversa**: K = F⁻¹.

### Ahora con números (con unidades)
L_v = 3 'largo del voladizo [m]
b_v = 0.30 'ancho [m]
h_a = 0.60 'altura en el empotramiento [m]
h_b = 0.30 'altura en la punta [m]
E_c = 25000000 'módulo de elasticidad (concreto) [kPa]
#hide
n_s = 400
s_v = 0
s_m = 0
s_t = 0
for i = 0:n_s
  x_i = L_v·i/n_s
  w_i = 2
  if i == 0
    w_i = 1
  end
  if i == n_s
    w_i = 1
  end
  if i > 0
    if i < n_s
      if i - 2·floor(i/2) == 1
        w_i = 4
      end
    end
  end
  E_i = E_c·b_v·(h_a + (h_b - h_a)·x_i/L_v)^3/12
  s_v = s_v + w_i·(L_v - x_i)^2/E_i
  s_m = s_m + w_i·(L_v - x_i)/E_i
  s_t = s_t + w_i/E_i
end
F_x = (L_v/n_s/3)·[s_v, s_m; s_m, s_t]
K_x = inv(F_x)
g_x = [-sqrt(3/5), 0, sqrt(3/5)]
g_w = [5/9, 8/9, 5/9]
K_h = zeros(2, 2)
for g = 1:3
  x_g = L_v·(g_x(g) + 1)/2
  z_g = (g_x(g) + 1)/2
  E_g = E_c·b_v·(h_a + (h_b - h_a)·x_g/L_v)^3/12
  B_3 = (6 - 12·z_g)/L_v^2
  B_4 = (-2 + 6·z_g)/L_v
  K_h(1, 1) = K_h(1, 1) + E_g·B_3^2·g_w(g)·L_v/2
  K_h(1, 2) = K_h(1, 2) + E_g·B_3·B_4·g_w(g)·L_v/2
  K_h(2, 2) = K_h(2, 2) + E_g·B_4^2·g_w(g)·L_v/2
end
K_h(2, 1) = K_h(1, 2)
T_k = zeros(5, 4)
for c_n = 1:5
  n_e = 2^(c_n - 1)
  l_e = L_v/n_e
  n_d = 2·n_e + 2
  K_g = zeros(n_d, n_d)
  for m_e = 1:n_e
    x_m = l_e·(m_e - 0.5)
    E_m = E_c·b_v·(h_a + (h_b - h_a)·x_m/L_v)^3/12
    K_l = E_m·[12/l_e^3, 6/l_e^2, -12/l_e^3, 6/l_e^2; 6/l_e^2, 4/l_e, -6/l_e^2, 2/l_e; -12/l_e^3, -6/l_e^2, 12/l_e^3, -6/l_e^2; 6/l_e^2, 2/l_e, -6/l_e^2, 4/l_e]
    for a = 1:4
      for c = 1:4
        K_g(2·m_e - 2 + a, 2·m_e - 2 + c) = K_g(2·m_e - 2 + a, 2·m_e - 2 + c) + K_l(a, c)
      end
    end
  end
  f_r = zeros(n_d - 2, 1)
  for a = 1:n_d - 2
    f_r(a) = a + 2
  end
  e_v = zeros(n_d - 2, 1)
  e_v(n_d - 3) = 1
  u_t = zeros(n_d - 2, 1)
  u_t(n_d - 2) = 1
  x_v = lsolve(K_g(f_r, f_r), e_v)
  x_t = lsolve(K_g(f_r, f_r), u_t)
  F_n = [x_v(n_d - 3), x_t(n_d - 3); x_v(n_d - 2), x_t(n_d - 2)]
  K_n = inv(F_n)
  T_k(c_n, 1) = n_e
  T_k(c_n, 2) = K_n(1, 1)
  T_k(c_n, 3) = K_n(1, 2)
  T_k(c_n, 4) = K_n(2, 2)
end
#show
K_x 'matriz de rigidez EXACTA de la punta (v, θ) [kN/m, kN, kN·m]
K_h 'UN elemento de Hermite con I(x) integrado con Gauss [kN/m, kN, kN·m]
#: **n elementos de I constante** (la I del centro de cada elemento): k_vv, k_vθ y k_θθ de la punta:
#tabla("elementos:0","k_vv [kN/m]:1","k_vθ [kN]:1","k_θθ [kN·m]:1")(T_k(1:5, 1); T_k(1:5, 2); T_k(1:5, 3); T_k(1:5, 4))
e_h = 100·(K_h(1, 1) - K_x(1, 1))/K_x(1, 1) 'error de UN elemento de Hermite en k_vv [%]
e_n = 100·(T_k(5, 2) - K_x(1, 1))/K_x(1, 1) 'error con 16 elementos de I constante [%]
#: **Qué enseña la tabla:** un solo elemento de Hermite (aunque integre bien la I(x)) es **29 % más rígido** que la viga real: su flecha cúbica no puede curvarse como una viga que se afina. Partiendo en más elementos la respuesta converge a la exacta (con 16, 0.2 %). Por eso los programas parten las cartelas en tramos.
#: **Cómo cambia la rigidez con la cartela** (k_vv de la punta contra la razón h₁/h₀, con la misma h₀): exacta y un elemento de Hermite. Pasa el cursor:
#hide
C_x = zeros(9, 2)
C_h = zeros(9, 2)
for j = 1:9
  r_j = 0.2 + 0.1·(j - 1)
  s_v = 0
  s_m = 0
  s_t = 0
  for i = 0:n_s
    x_i = L_v·i/n_s
    w_i = 2
    if i == 0
      w_i = 1
    end
    if i == n_s
      w_i = 1
    end
    if i > 0
      if i < n_s
        if i - 2·floor(i/2) == 1
          w_i = 4
        end
      end
    end
    E_i = E_c·b_v·(h_a + (r_j·h_a - h_a)·x_i/L_v)^3/12
    s_v = s_v + w_i·(L_v - x_i)^2/E_i
    s_m = s_m + w_i·(L_v - x_i)/E_i
    s_t = s_t + w_i/E_i
  end
  K_j = inv((L_v/n_s/3)·[s_v, s_m; s_m, s_t])
  C_x(j, 1) = r_j
  C_x(j, 2) = K_j(1, 1)
  a_1 = 0
  for g = 1:3
    x_g = L_v·(g_x(g) + 1)/2
    z_g = (g_x(g) + 1)/2
    E_g = E_c·b_v·(h_a + (r_j·h_a - h_a)·x_g/L_v)^3/12
    a_1 = a_1 + E_g·((6 - 12·z_g)/L_v^2)^2·g_w(g)·L_v/2
  end
  C_h(j, 1) = r_j
  C_h(j, 2) = a_1
end
#show
#fplot(exacta = C_x, Hermite_1_elemento = C_h, [0.2 1])
#: (eje horizontal: h₁/h₀. Con h₁/h₀ = 1 la viga es prismática y las dos coinciden en 12EI/L³, porque con EI constante la flecha cúbica de Hermite ES la exacta; cuanto más afilada la cartela, más se separan.)

## 2 · La misma viga NO LINEAL: Newton-Raphson
#: **La idea:** el concreto se fisura y la sección se ablanda: cuanto más se curva, menos momento extra aguanta, hasta un tope M_u. Es la misma curva de la barra, pero ahora momento contra curvatura:
M_q = Simplify{E_I*q/(1 + E_I*q/M_u)}
#: La **rigidez a flexión del momento** (la tangente, la «m» de la recta) es su derivada:
E_t = Simplify{Diff{E_I*q/(1 + E_I*q/M_u) @ q}}
#: (q = curvatura κ). **La solución exacta** existe porque el voladizo es isostático: con P en la punta, M(x) = P·(L − x) sin resolver nada; se despeja la curvatura de cada sección y se integra:
q_M = Simplify{M/(E_I*(1 - M/M_u))}
#: δ_punta = ∫ κ(x)·(L − x) dx (vale mientras M < M_u en todas las secciones). **Newton con elementos finitos** (lo que haría un programa): en cada punto de Gauss κ = B·u, M(κ) y EI_t; se arman K_T = Σ ∫ EI_t·Bᵀ·B dx y las fuerzas internas F_int = Σ ∫ Bᵀ·M dx; el residuo R = F − F_int; se resuelve **K_T·Δu = R** y se repite. Es la barra, con matrices.
### Con números
s_u = 20000 'esfuerzo de la sección plástica (aprox. M_u = σ·b·h²/4, rectángulo plástico) [kPa]
P = 150 'carga en la punta [kN]
#hide
P_u = 1000000
for i = 0:300
  x_i = L_v·i/300
  if x_i < L_v
    P_u = min(P_u, s_u·b_v·(h_a + (h_b - h_a)·x_i/L_v)^2/4/(L_v - x_i))
  end
end
d_e = 0
for i = 0:n_s
  x_i = L_v·i/n_s
  w_i = 2
  if i == 0
    w_i = 1
  end
  if i == n_s
    w_i = 1
  end
  if i > 0
    if i < n_s
      if i - 2·floor(i/2) == 1
        w_i = 4
      end
    end
  end
  h_i = h_a + (h_b - h_a)·x_i/L_v
  E_i = E_c·b_v·h_i^3/12
  M_i = P·(L_v - x_i)
  d_e = d_e + w_i·M_i/(E_i·(1 - M_i/(s_u·b_v·h_i^2/4)))·(L_v - x_i)
end
d_e = d_e·L_v/n_s/3
d_l = P·F_x(1, 1)
n_e = 10
l_e = L_v/n_e
n_d = 2·n_e + 2
u = zeros(n_d, 1)
F = zeros(n_d, 1)
F(n_d - 1) = P
f_r = zeros(n_d - 2, 1)
for a = 1:n_d - 2
  f_r(a) = a + 2
end
T_n = zeros(9, 3)
for i_t = 1:9
  K_t = zeros(n_d, n_d)
  Q_f = zeros(n_d, 1)
  for m_e = 1:n_e
    for g = 1:3
      z_g = (g_x(g) + 1)/2
      x_g = l_e·(m_e - 1 + z_g)
      h_g = h_a + (h_b - h_a)·x_g/L_v
      E_g = E_c·b_v·h_g^3/12
      M_v = s_u·b_v·h_g^2/4
      B_v = [(-6 + 12·z_g)/l_e^2, (-4 + 6·z_g)/l_e, (6 - 12·z_g)/l_e^2, (-2 + 6·z_g)/l_e]
      q_g = 0
      for a = 1:4
        q_g = q_g + B_v(a)·u(2·m_e - 2 + a)
      end
      M_g = E_g·q_g/(1 + E_g·abs(q_g)/M_v)
      t_g = E_g/(1 + E_g·abs(q_g)/M_v)^2
      for a = 1:4
        Q_f(2·m_e - 2 + a) = Q_f(2·m_e - 2 + a) + B_v(a)·M_g·g_w(g)·l_e/2
        for c = 1:4
          K_t(2·m_e - 2 + a, 2·m_e - 2 + c) = K_t(2·m_e - 2 + a, 2·m_e - 2 + c) + t_g·B_v(a)·B_v(c)·g_w(g)·l_e/2
        end
      end
    end
  end
  R = F - Q_f
  r_n = 0
  for a = 3:n_d
    r_n = r_n + R(a)^2
  end
  T_n(i_t, 1) = i_t - 1
  T_n(i_t, 2) = 1000·u(n_d - 1)
  T_n(i_t, 3) = sqrt(r_n)
  d_u = lsolve(K_t(f_r, f_r), R(f_r))
  for a = 1:n_d - 2
    u(a + 2) = u(a + 2) + d_u(a)
  end
end
#show
P_u 'carga de colapso de la viga (M = M_u en alguna sección) [kN]
d_l = 1000·d_l 'flecha de la punta, cálculo LINEAL (un paso) [mm]
d_e = 1000·d_e 'flecha EXACTA no lineal (integral de la curvatura) [mm]
#: **Newton paso a paso** (10 elementos, 3 puntos de Gauss): cada fila es un paso; la flecha avanza y **lo que falta** (el residuo) baja hasta cero, igual que en la barra:
#tabla("paso:0","flecha de la punta [mm]:4","falta |R| [kN]:6")(T_n(1:9, 1); T_n(1:9, 2); T_n(1:9, 3))
d_n = T_n(9, 2) 'Newton (10 elementos) [mm]
e_r = 100·(d_n - d_e)/d_e 'diferencia con la exacta [%]
#: El primer paso de Newton (con la rigidez sin fisurar) da **exactamente el cálculo lineal** (16.36 mm); después la viga se ablanda y la flecha real es **4.7 veces mayor**. Newton llega a la exacta en 7 pasos; lo que queda (milésimas de mm) es por partir la viga en 10 elementos.
#: **Curva carga–flecha** (lineal, exacta no lineal y el punto de Newton). Cerca de P_u = 180 kN la curva se acuesta (rigidez → 0) y la flecha se dispara: eso es el colapso. Pasa el cursor:
#hide
C_l = zeros(9, 2)
C_e = zeros(9, 2)
for j = 1:9
  P_j = 20·j
  if j == 9
    P_j = 175
  end
  s_v = 0
  for i = 0:n_s
    x_i = L_v·i/n_s
    w_i = 2
    if i == 0
      w_i = 1
    end
    if i == n_s
      w_i = 1
    end
    if i > 0
      if i < n_s
        if i - 2·floor(i/2) == 1
          w_i = 4
        end
      end
    end
    h_i = h_a + (h_b - h_a)·x_i/L_v
    M_i = P_j·(L_v - x_i)
    s_v = s_v + w_i·M_i/(E_c·b_v·h_i^3/12·(1 - M_i/(s_u·b_v·h_i^2/4)))·(L_v - x_i)
  end
  C_e(j, 1) = 1000·s_v·L_v/n_s/3
  C_e(j, 2) = P_j
  C_l(j, 1) = 1000·P_j·F_x(1, 1)
  C_l(j, 2) = P_j
end
N_p = zeros(9, 2)
for j = 1:9
  N_p(j, 1) = T_n(j, 2)
  N_p(j, 2) = P
end
#show
#fplot(lineal = C_l, exacta_no_lineal = C_e, pasos_de_Newton = N_p, [0 400])
#: (eje horizontal: flecha de la punta en mm; vertical: carga P en kN.)

## 3 · Cómo se ablanda la sección (3D)
#: La rigidez del momento relativa EI_t/EI en cada punto de la viga (x, m) y para cada curvatura (y, en 1/1000 m): donde la viga es más baja (la punta) se ablanda antes. Arrastra para girar:
e_s(x, y) = 1/(1 + E_c·b_v·(h_a + (h_b - h_a)·x/L_v)^3/12·y/1000/(s_u·b_v·(h_a + (h_b - h_a)·x/L_v)^2/4))^2
#map(e_s(x, y), [0 3], [0 10])
#surf(e_s(x, y), [0 3], [0 10])

## 4 · Los 5 tipos de no linealidad (y Newton es siempre el mismo)
#: En todos el procedimiento es idéntico: **calcular lo que falta (residuo) → la rigidez del momento (tangente) → K_T·Δu = R → repetir**. Lo único que cambia es **de dónde sale la curva**:
#tabla("Tipo","De dónde sale la curva","Ejemplo")({"1 · Material", "2 · Geométrica", "3 · De carga", "4 · Contacto", "5 · Fractura / daño"}; {"el material se ablanda o fluye (la sección pierde rigidez)", "el equilibrio se escribe en la posición DEFORMADA (la carga axial empuja la punta desplazada)", "la carga cambia con la deformación", "la rigidez SALTA cuando dos cuerpos se tocan o se separan", "con ablandamiento la rigidez se vuelve NEGATIVA (la curva baja)"}; {"concreto fisurado, acero que fluye, suelo (hojas 190, 196 y la Parte 2)", "efecto P-Δ, pandeo, cables", "presión que sigue a la superficie, viento sobre la deformada", "zapata que se levanta, juntas, apoyos que despegan", "concreto que se agrieta; aquí Newton solo no basta: longitud de arco o IMPL-EX"})

## 5 · No linealidad GEOMÉTRICA (P-Δ) y COMBINADA en el mismo voladizo
#: **La idea simple:** ahora además de la carga lateral H hay una carga axial de compresión N en la punta. Cuando la punta se corre δ, la fuerza N queda **descentrada** y empuja: el momento en cada sección ya no es solo H·(L − x) sino **M = H·(L − x) + N·(δ − v(x))**. Más flecha → más momento → más flecha. Eso es el efecto **P-Δ**.
#dibujo("Voladizo con carga lateral H y axial N (la deformada exagerada)", ud = m, escala = auto, alto = 80)
#  achurado([-0.25, 0, 0, -0.25], [-0.45, -0.45, 0.45, 0.45], "suelo")
#  poligono(0, -0.3, 3, -0.15, 3, 0.15, 0, 0.3, "fina")
#  linea(0, 0, 0.75, -0.053, "gruesa rojo")
#  linea(0.75, -0.053, 1.5, -0.194, "gruesa rojo")
#  linea(1.5, -0.194, 2.25, -0.392, "gruesa rojo")
#  linea(2.25, -0.392, 3, -0.62, "gruesa rojo")
#  flecha(3, 0.9, 3, -0.55, "gruesa azul")
#  flecha(4.2, -0.62, 3.05, -0.62, "gruesa azul")
#  texto(3.25, 0.85, "H", 2.6, "c")
#  texto(4.3, -0.4, "N (compresión)", 2.4, "c")
#  texto(1.5, -0.95, "deformada: N empuja la punta corrida δ", 2.2, "c")
#fin
### Primero con símbolos
#: En elementos finitos esto se escribe con la **matriz geométrica** K_G (sale de la energía de la carga axial sobre el giro de la viga, ∫ N·v′² dx): con las mismas funciones de Hermite, K_G = N·∫ N′ᵀ·N′ dx:
g_11 = Simplify{Area{(6*x^2/L^3 - 6*x/L^2)^2 @ x = 0 : L}}
g_12 = Simplify{Area{(6*x^2/L^3 - 6*x/L^2)*(1 - 4*x/L + 3*x^2/L^2) @ x = 0 : L}}
g_22 = Simplify{Area{(1 - 4*x/L + 3*x^2/L^2)^2 @ x = 0 : L}}
g_24 = Simplify{Area{(1 - 4*x/L + 3*x^2/L^2)*(3*x^2/L^2 - 2*x/L) @ x = 0 : L}}
#: (6/(5L), 1/10, 2L/15 y −L/30, multiplicados por N). **Equilibrio en la posición deformada:** con compresión la carga axial QUITA rigidez:
#: **(K_E − K_G(N))·u = F**    y, con el material que se ablanda,    **K_T = K_E,t(EI_t) − K_G(N)**
#: **La carga crítica de pandeo** es la N que deja la viga sin rigidez: det(K_E − N·K_G) = 0. Para una columna prismática en voladizo, N_cr = π²·EI/(4L²).
### Ahora con números
#hide
K_e = zeros(n_d, n_d)
K_r = zeros(n_d, n_d)
for m_e = 1:n_e
  K_s = (1/(30·l_e))·[36, 3·l_e, -36, 3·l_e; 3·l_e, 4·l_e^2, -3·l_e, -l_e^2; -36, -3·l_e, 36, -3·l_e; 3·l_e, -l_e^2, -3·l_e, 4·l_e^2]
  for g = 1:3
    z_g = (g_x(g) + 1)/2
    x_g = l_e·(m_e - 1 + z_g)
    E_g = E_c·b_v·(h_a + (h_b - h_a)·x_g/L_v)^3/12
    B_v = [(-6 + 12·z_g)/l_e^2, (-4 + 6·z_g)/l_e, (6 - 12·z_g)/l_e^2, (-2 + 6·z_g)/l_e]
    for a = 1:4
      for c = 1:4
        K_e(2·m_e - 2 + a, 2·m_e - 2 + c) = K_e(2·m_e - 2 + a, 2·m_e - 2 + c) + E_g·B_v(a)·B_v(c)·g_w(g)·l_e/2
      end
    end
  end
  for a = 1:4
    for c = 1:4
      K_r(2·m_e - 2 + a, 2·m_e - 2 + c) = K_r(2·m_e - 2 + a, 2·m_e - 2 + c) + K_s(a, c)
    end
  end
end
y_v = ones(n_d - 2, 1)
for i_t = 1:40
  z_v = lsolve(K_e(f_r, f_r), K_r(f_r, f_r)·y_v)
  y_v = z_v/sqrt(sum(z_v.*z_v))
end
N_c = sum(y_v.*(K_e(f_r, f_r)·y_v))/sum(y_v.*(K_r(f_r, f_r)·y_v))
#show
N_c 'carga crítica de pandeo del voladizo acartelado (10 elementos) [kN]
N_a = pi^2·E_c·b_v·h_b^3/12/(4·L_v^2) 'π²EI/4L² con la I de la PUNTA (la mínima) [kN]
N_m = pi^2·E_c·b_v·((h_a + h_b)/2)^3/12/(4·L_v^2) 'π²EI/4L² con la I del CENTRO [kN]
N_z = pi^2·E_c·b_v·h_a^3/12/(4·L_v^2) 'π²EI/4L² con la I del EMPOTRAMIENTO (la máxima) [kN]
#: La cartela queda entre la I del centro y la del empotramiento: lo que más importa en el pandeo de un voladizo es la base. Usar la I mínima subestima N_cr 4 veces.
P_a = 0.3·N_c 'carga axial de compresión: 30 % de N_cr [kN]
H_l = 40 'carga lateral en la punta [kN]
s_a = P_a/(b_v·(h_a + h_b)/2) 'esfuerzo axial medio N/A (¡esta sección real se aplastaría! el caso es solo para ver el efecto) [kPa]
#: **Los 4 casos**, con la carga aplicada en 8 pasos y Newton en cada paso (con material y geometría juntos, aplicar todo de golpe hace que Newton salte a una rama falsa):
#hide
D_c = zeros(9, 5)
for j = 1:9
  D_c(j, 1) = 5·(j - 1)
end
for c_s = 1:4
  m_f = 0
  g_f = 0
  if c_s == 2
    m_f = 1
  end
  if c_s == 3
    g_f = 1
  end
  if c_s == 4
    m_f = 1
    g_f = 1
  end
  u = zeros(n_d, 1)
  for j = 2:9
    l_f = (j - 1)/8
    F = zeros(n_d, 1)
    F(n_d - 1) = l_f·H_l
    P_s = l_f·P_a
    for i_t = 1:14
      K_t = zeros(n_d, n_d)
      Q_f = zeros(n_d, 1)
      for m_e = 1:n_e
        for g = 1:3
          z_g = (g_x(g) + 1)/2
          x_g = l_e·(m_e - 1 + z_g)
          h_g = h_a + (h_b - h_a)·x_g/L_v
          E_g = E_c·b_v·h_g^3/12
          M_v = s_u·b_v·h_g^2/4
          B_v = [(-6 + 12·z_g)/l_e^2, (-4 + 6·z_g)/l_e, (6 - 12·z_g)/l_e^2, (-2 + 6·z_g)/l_e]
          q_g = 0
          for a = 1:4
            q_g = q_g + B_v(a)·u(2·m_e - 2 + a)
          end
          M_g = E_g·q_g
          t_g = E_g
          if m_f == 1
            M_g = E_g·q_g/(1 + E_g·abs(q_g)/M_v)
            t_g = E_g/(1 + E_g·abs(q_g)/M_v)^2
          end
          for a = 1:4
            Q_f(2·m_e - 2 + a) = Q_f(2·m_e - 2 + a) + B_v(a)·M_g·g_w(g)·l_e/2
            for c = 1:4
              K_t(2·m_e - 2 + a, 2·m_e - 2 + c) = K_t(2·m_e - 2 + a, 2·m_e - 2 + c) + t_g·B_v(a)·B_v(c)·g_w(g)·l_e/2
            end
          end
        end
      end
      K_t = K_t - g_f·P_s·K_r
      R = F - (Q_f - g_f·P_s·(K_r·u))
      d_u = lsolve(K_t(f_r, f_r), R(f_r))
      for a = 1:n_d - 2
        u(a + 2) = u(a + 2) + d_u(a)
      end
    end
    D_c(j, c_s + 1) = 1000·u(n_d - 1)
  end
end
S_1 = zeros(9, 2)
S_2 = zeros(9, 2)
S_3 = zeros(9, 2)
S_4 = zeros(9, 2)
for j = 1:9
  S_1(j, 1) = D_c(j, 2)
  S_1(j, 2) = D_c(j, 1)
  S_2(j, 1) = D_c(j, 3)
  S_2(j, 2) = D_c(j, 1)
  S_3(j, 1) = D_c(j, 4)
  S_3(j, 2) = D_c(j, 1)
  S_4(j, 1) = D_c(j, 5)
  S_4(j, 2) = D_c(j, 1)
end
t_d = zeros(4, 1)
t_p = zeros(4, 1)
for j = 1:4
  t_d(j) = D_c(9, j + 1)
  t_p(j) = 100·(D_c(9, j + 1) - D_c(9, 2))/D_c(9, 2)
end
#show
t_d 'δ punta de los 4 casos [mm]
#tabla("Caso","δ punta [mm]:4","más que el lineal [%]:1")({"1 · lineal (K_E·u = F)","2 · solo material (EI se ablanda)","3 · solo geométrico P-Δ (K_E − K_G)","4 · material + geométrico juntos"}; t_d; t_p)
#: **La lección:** por separado, el material agrega 26 % y la geometría 42 %; **juntos no suman 68 %, sino ≈ 216 %**. El axial empuja la punta corrida, eso aumenta el momento, la sección se ablanda, la viga se dobla más y el axial empuja más. Con H = 50 kN ya no hay equilibrio: **la viga colapsa** aunque cada efecto por separado parezca pequeño. Por eso los códigos piden el análisis de segundo orden con la rigidez fisurada.
#: **Curvas carga lateral – flecha** (los 4 casos). Pasa el cursor:
#fplot(lineal = S_1, material = S_2, geometrico = S_3, combinado = S_4, [0 15])
#: (eje horizontal: flecha de la punta en mm; vertical: H en kN.)
#: **La amplificación P-Δ elástica** δ/δ_lineal contra N/N_cr, comparada con la fórmula clásica 1/(1 − N/N_cr):
#hide
A_m = zeros(7, 2)
A_f = zeros(7, 2)
F = zeros(n_d, 1)
F(n_d - 1) = H_l
w_0 = lsolve(K_e(f_r, f_r), F(f_r))
for j = 1:7
  f_j = 0.1·j
  w_j = lsolve(K_e(f_r, f_r) - f_j·N_c·K_r(f_r, f_r), F(f_r))
  A_m(j, 1) = f_j
  A_m(j, 2) = w_j(n_d - 3)/w_0(n_d - 3)
  A_f(j, 1) = f_j
  A_f(j, 2) = 1/(1 - f_j)
end
#show
#fplot(voladizo_acartelado = A_m, formula_1_entre_1_menos_N_Ncr = A_f, [0.1 0.7])
#: La fórmula 1/(1 − N/N_cr) acierta muy bien (la deformada por H se parece al modo de pandeo); con N = 0.5·N_cr la flecha se duplica.
