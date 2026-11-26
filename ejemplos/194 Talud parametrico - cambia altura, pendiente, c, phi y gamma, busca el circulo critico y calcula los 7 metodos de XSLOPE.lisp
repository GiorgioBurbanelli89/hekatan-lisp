# Talud paramétrico: cambia la altura, la pendiente, c, φ y γ; la hoja busca el círculo crítico y calcula los 7 métodos de XSLOPE
#numerico

## 1 · Los datos (cámbialos aquí)
#: Cambia cualquiera de estos números y la hoja rehace todo: la geometría, la búsqueda del círculo crítico, las dovelas y los 7 métodos de equilibrio límite (los mismos de XSLOPE, hoja 192). Con los valores de partida es el talud de Griffiths y Lane (1999), ejemplo 2.
H = 15.24 'altura del talud [m]
n_s = 2 'pendiente de la cara: n_s horizontal por 1 vertical (2 = 2:1) [-]
H_b = 7.62 'espesor de la cimentación bajo el pie [m]
c = 15 'cohesión [kPa]
f_g = 20 'ángulo de fricción φ [°]
g_s = 19.64 'peso unitario γ [kN/m³]
n_d = 30 'número de dovelas [-]
#: La geometría que sale de esos datos (el pie a 2·H del borde izquierdo y la corona plana 2·H más):
x_t = 2·H 'x del pie [m]
x_c = x_t + n_s·H 'x de la corona [m]
L_t = x_c + 2·H 'largo del modelo [m]
y_g(x) = H_b + min(max(x - x_t, 0), n_s·H)/n_s
#dibujo("El talud con los datos de arriba", ud = m, escala = auto, cotas = m, alto = 90)
#  achurado([0, L_t, L_t, x_c, x_t, 0], [0, 0, H_b + H, H_b + H, H_b, H_b], "suelo")
#  poligono(0, 0, L_t, 0, L_t, H_b + H, x_c, H_b + H, x_t, H_b, 0, H_b, "gruesa")
#  cota(L_t + 1.5, H_b, L_t + 1.5, H_b + H, 0, "H")
#fin

## 2 · Primero con símbolos
#: **El terreno** (cimentación plana, cara de pendiente 1:n_s y corona plana) y **el círculo** de centro (X_o, Y_o) y radio R: la base de cada dovela está sobre el arco de abajo:
y_c = Simplify{Y_o - sqrt(R^2 - (x - X_o)^2)}
#: Cada dovela de ancho b: alto h = y_terreno − y_círculo, peso W = γ·b·h (h con Simpson: (h_izq + 4·h_centro + h_der)/6), inclinación de la base α (de la pendiente del arco) y largo Δl = b/cos α:
W_s = Simplify{g*b*(y_t - y_b)}
l_s = Simplify{b/cos(alpha)}
#: **Bishop** (momentos, fuerzas entre dovelas horizontales), con t_p = tan φ:
F_B = Simplify{(c*b + W*t_p)/(cos(alpha) + sin(alpha)*t_p/F)}
#: F = Σ F_B / Σ W·sin α. **La búsqueda del círculo crítico:** se prueban muchos centros (y para cada uno un radio que pasa por el pie y dos más profundos), y el círculo crítico es el de F de Bishop MÍNIMO, como en XSLOPE. Con ese círculo se calculan los 7 métodos (sus fórmulas, paso a paso, en la hoja 192).

## 3 · La búsqueda del círculo crítico (Bishop)
t_f = tan(f_g·pi/180) 'tan φ [-]
#hide
F_n = 99
G_x = zeros(81, 1)
G_y = zeros(81, 1)
G_f = zeros(81, 1)
X_b = 0
Y_b = 0
R_b = 0
for r_e = 1:2
  if r_e == 1
    x_a = x_t
    x_z = x_c
    y_a = H_b + H
    y_z = H_b + 3·H
    k_n = 9
  end
  if r_e == 2
    x_a = X_b - (x_c - x_t)/8
    x_z = X_b + (x_c - x_t)/8
    y_a = Y_b - H/4
    y_z = Y_b + H/4
    k_n = 9
  end
  for i_x = 1:k_n
    for i_y = 1:k_n
      X_o = x_a + (x_z - x_a)·(i_x - 1)/(k_n - 1)
      Y_o = y_a + (y_z - y_a)·(i_y - 1)/(k_n - 1)
      R_0 = sqrt((X_o - x_t)^2 + (Y_o - H_b)^2)
      f_c = 9
      for i_r = 1:3
        R_c = R_0·(1 + 0.04·(i_r - 1))
        h_0 = Y_o - R_c - y_g(X_o)
        if h_0 < 0
          a_1 = X_o - R_c + 1e-9
          a_2 = X_o
          for k = 1:40
            a_3 = (a_1 + a_2)/2
            if Y_o - sqrt(R_c^2 - (a_3 - X_o)^2) - y_g(a_3) > 0
              a_1 = a_3
            end
            if Y_o - sqrt(R_c^2 - (a_3 - X_o)^2) - y_g(a_3) <= 0
              a_2 = a_3
            end
          end
          b_1 = X_o
          b_2 = min(X_o + R_c - 1e-9, L_t)
          for k = 1:40
            b_3 = (b_1 + b_2)/2
            if Y_o - sqrt(R_c^2 - (b_3 - X_o)^2) - y_g(b_3) < 0
              b_1 = b_3
            end
            if Y_o - sqrt(R_c^2 - (b_3 - X_o)^2) - y_g(b_3) >= 0
              b_2 = b_3
            end
          end
          d_b = (b_3 - a_3)/n_d
          F_t = 1.3
          for k = 1:15
            s_n = 0
            s_d = 0
            for i = 1:n_d
              x_m = a_3 + (i - 0.5)·d_b
              y_l = Y_o - sqrt(R_c^2 - (x_m - d_b/2 - X_o)^2)
              y_r = Y_o - sqrt(R_c^2 - (x_m + d_b/2 - X_o)^2)
              a_i = atan((y_r - y_l)/d_b)
              W_i = g_s·d_b·((y_g(x_m - d_b/2) - y_l) + 4·(y_g(x_m) - (Y_o - sqrt(R_c^2 - (x_m - X_o)^2))) + (y_g(x_m + d_b/2) - y_r))/6
              s_n = s_n + (c·d_b + W_i·t_f)/(cos(a_i) + sin(a_i)·t_f/F_t)
              s_d = s_d + W_i·sin(a_i)
            end
            F_t = s_n/s_d
          end
          if F_t > 0.1
            f_c = min(f_c, F_t)
          end
          if F_t < F_n
            if F_t > 0.1
              F_n = F_t
              X_b = X_o
              Y_b = Y_o
              R_b = R_c
            end
          end
        end
      end
      if r_e == 1
        G_x((i_x - 1)·k_n + i_y) = X_o
        G_y((i_x - 1)·k_n + i_y) = Y_o
        G_f((i_x - 1)·k_n + i_y) = min(f_c, 3)
      end
    end
  end
end
E_q = zeros(64, 4)
for i_x = 1:8
  for i_y = 1:8
    E_q((i_x - 1)·8 + i_y, 1) = (i_x - 1)·9 + i_y
    E_q((i_x - 1)·8 + i_y, 2) = i_x·9 + i_y
    E_q((i_x - 1)·8 + i_y, 3) = i_x·9 + i_y + 1
    E_q((i_x - 1)·8 + i_y, 4) = (i_x - 1)·9 + i_y + 1
  end
end
#show
#: **El mapa de seguridad** (como el de los programas de taludes): el F de Bishop mínimo de cada centro probado (pasa el cursor; se corta en 3). El valle (azul) es donde está el centro crítico:
#campo(G_x, G_y, E_q, G_f)
X_b 'centro del círculo crítico, x [m]
Y_b 'centro, y [m]
R_b 'radio [m]
F_n 'F de Bishop del círculo crítico (búsqueda) [-]

## 4 · Las dovelas del círculo crítico
#hide
a_3 = X_b - R_b + 1e-9
a_2 = X_b
a_1 = a_3
for k = 1:50
  a_3 = (a_1 + a_2)/2
  if Y_b - sqrt(R_b^2 - (a_3 - X_b)^2) - y_g(a_3) > 0
    a_1 = a_3
  end
  if Y_b - sqrt(R_b^2 - (a_3 - X_b)^2) - y_g(a_3) <= 0
    a_2 = a_3
  end
end
b_1 = X_b
b_2 = min(X_b + R_b - 1e-9, L_t)
for k = 1:50
  b_3 = (b_1 + b_2)/2
  if Y_b - sqrt(R_b^2 - (b_3 - X_b)^2) - y_g(b_3) < 0
    b_1 = b_3
  end
  if Y_b - sqrt(R_b^2 - (b_3 - X_b)^2) - y_g(b_3) >= 0
    b_2 = b_3
  end
end
d_b = (b_3 - a_3)/n_d
x_d = zeros(n_d, 1)
a_d = zeros(n_d, 1)
l_d = zeros(n_d, 1)
W_d = zeros(n_d, 1)
p_t = zeros(n_d + 1, 1)
p_b = zeros(n_d + 1, 1)
x_q = zeros(n_d + 1, 1)
for i = 1:n_d
  x_d(i) = a_3 + (i - 0.5)·d_b
  y_l = Y_b - sqrt(R_b^2 - (x_d(i) - d_b/2 - X_b)^2)
  y_r = Y_b - sqrt(R_b^2 - (x_d(i) + d_b/2 - X_b)^2)
  a_d(i) = atan((y_r - y_l)/d_b)
  l_d(i) = d_b/cos(a_d(i))
  W_d(i) = g_s·d_b·((y_g(x_d(i) - d_b/2) - y_l) + 4·(y_g(x_d(i)) - (Y_b - sqrt(R_b^2 - (x_d(i) - X_b)^2))) + (y_g(x_d(i) + d_b/2) - y_r))/6
end
for j = 1:n_d + 1
  x_q(j) = a_3 + (j - 1)·d_b
  p_t(j) = (y_g(x_q(j) + 0.001) - y_g(x_q(j) - 0.001))/0.002
  p_b(j) = (x_q(j) - X_b)/sqrt(R_b^2 - (x_q(j) - X_b)^2)
end
S_W = 0
S_L = 0
S_C = 0
for i = 1:n_d
  S_W = S_W + W_d(i)·sin(a_d(i))
  S_L = S_L + c·l_d(i)
  S_C = S_C + W_d(i)·cos(a_d(i))
end
#show
a_3 'la masa sale al pie en x [m]
b_3 'y entra a la corona en x [m]
d_b 'ancho de cada dovela [m]
S_W 'Σ W·sin α [kN/m]
#: **El terreno y el círculo crítico** (x e y divididos por el largo L_t del modelo, para que la gráfica sirva con cualquier talud; pasa el cursor):
#hide
C_r = zeros(41, 2)
T_r = zeros(41, 2)
for k = 1:41
  x_k = a_3 + (b_3 - a_3)·(k - 1)/40
  C_r(k, 1) = x_k/L_t
  C_r(k, 2) = (Y_b - sqrt(R_b^2 - (x_k - X_b)^2))/L_t
  T_r(k, 1) = (k - 1)/40
  T_r(k, 2) = y_g(L_t·(k - 1)/40)/L_t
end
#show
#fplot(terreno = T_r, circulo = C_r, [0 1])

## 5 · Los 7 métodos en el círculo crítico
F_1 = (S_L + S_C·t_f)/S_W 'Ordinario (Fellenius) [-]
#hide
F_2 = 1.3
for k = 1:40
  s_b = 0
  for i = 1:n_d
    s_b = s_b + (c·l_d(i)·cos(a_d(i)) + W_d(i)·t_f)/(cos(a_d(i)) + sin(a_d(i))·t_f/F_2)
  end
  F_2 = s_b/S_W
end
F_3 = 1.3
for k = 1:60
  s_n = 0
  s_d = 0
  for i = 1:n_d
    N_j = (W_d(i) - c·l_d(i)·sin(a_d(i))/F_3)/(cos(a_d(i)) + sin(a_d(i))·t_f/F_3)
    s_n = s_n + (c·l_d(i) + N_j·t_f)·cos(a_d(i))
    s_d = s_d + N_j·sin(a_d(i))
  end
  F_3 = (F_3 + s_n/s_d)/2
end
y_1 = Y_b - sqrt(R_b^2 - (a_3 - X_b)^2)
y_2 = Y_b - sqrt(R_b^2 - (b_3 - X_b)^2)
L_c = sqrt((b_3 - a_3)^2 + (y_2 - y_1)^2)
d_m = 0
for i = 1:n_d
  d_m = max(d_m, abs((y_2 - y_1)·x_d(i) - (b_3 - a_3)·(Y_b - sqrt(R_b^2 - (x_d(i) - X_b)^2)) + b_3·y_1 - y_2·a_3)/L_c)
end
q_J = d_m/L_c
f_J = 1 + 0.5·(q_J - 1.4·q_J^2)
t_C = zeros(n_d + 1, 1)
t_L = zeros(n_d + 1, 1)
for j = 1:n_d + 1
  t_C(j) = atan(p_t(j))
  t_L(j) = atan((p_t(j) + p_b(j))/2)
end
#show
F_2 'Bishop simplificado [-]
F_4 = F_3·f_J 'Janbu corregido (f₀ = 1 + 0.5·(d/L − 1.4·(d/L)²)) [-]
#hide
F_s = zeros(2, 1)
for m_e = 1:2
  f_a = 0.5
  f_b = 4
  for k = 1:50
    f_m = (f_a + f_b)/2
    Z_a = 0
    Z_m = 0
    for i = 1:n_d
      if m_e == 1
        t_1 = t_C(i)
        t_2 = t_C(i + 1)
      end
      if m_e == 2
        t_1 = t_L(i)
        t_2 = t_L(i + 1)
      end
      u_1 = t_f/f_a·cos(a_d(i)) - sin(a_d(i))
      u_2 = t_f/f_a·sin(a_d(i)) + cos(a_d(i))
      v_0 = -c/f_a·l_d(i)·cos(a_d(i)) - Z_a·cos(t_1)
      v_1 = -c/f_a·l_d(i)·sin(a_d(i)) + W_d(i) - Z_a·sin(t_1)
      Z_a = (u_1·v_1 - u_2·v_0)/(-u_1·sin(t_2) + u_2·cos(t_2))
      w_1 = t_f/f_m·cos(a_d(i)) - sin(a_d(i))
      w_2 = t_f/f_m·sin(a_d(i)) + cos(a_d(i))
      g_0 = -c/f_m·l_d(i)·cos(a_d(i)) - Z_m·cos(t_1)
      g_1 = -c/f_m·l_d(i)·sin(a_d(i)) + W_d(i) - Z_m·sin(t_1)
      Z_m = (w_1·g_1 - w_2·g_0)/(-w_1·sin(t_2) + w_2·cos(t_2))
    end
    if Z_a·Z_m <= 0
      f_b = f_m
    end
    if Z_a·Z_m > 0
      f_a = f_m
    end
  end
  F_s(m_e) = f_m
end
F_5 = F_s(1)
F_6 = F_s(2)
h_a = 0
h_b = 0.8
for k = 1:40
  h_m = (h_a + h_b)/2
  e_a = 0
  e_m = 0
  for r_k = 1:2
    if r_k == 1
      t_k = h_a
    end
    if r_k == 2
      t_k = h_m
    end
    p_1 = 0.5
    p_2 = 4
    q_1 = 0.5
    q_2 = 4
    for j = 1:45
      p_3 = (p_1 + p_2)/2
      q_3 = (q_1 + q_2)/2
      g_a = 0
      g_c = 0
      e_1 = 0
      e_2 = 0
      for i = 1:n_d
        g_a = g_a + (c·l_d(i)/p_1 + W_d(i)·cos(a_d(i))·t_f/p_1 - W_d(i)·sin(a_d(i)))/(cos(a_d(i) - t_k)·(1 + t_f·tan(a_d(i) - t_k)/p_1))
        g_c = g_c + (c·l_d(i)/p_3 + W_d(i)·cos(a_d(i))·t_f/p_3 - W_d(i)·sin(a_d(i)))/(cos(a_d(i) - t_k)·(1 + t_f·tan(a_d(i) - t_k)/p_3))
        e_1 = e_1 + (c·l_d(i)/q_1 + W_d(i)·cos(a_d(i))·t_f/q_1 - W_d(i)·sin(a_d(i)))/(1 + t_f·tan(a_d(i) - t_k)/q_1)
        e_2 = e_2 + (c·l_d(i)/q_3 + W_d(i)·cos(a_d(i))·t_f/q_3 - W_d(i)·sin(a_d(i)))/(1 + t_f·tan(a_d(i) - t_k)/q_3)
      end
      if g_a·g_c <= 0
        p_2 = p_3
      end
      if g_a·g_c > 0
        p_1 = p_3
      end
      if e_1·e_2 <= 0
        q_2 = q_3
      end
      if e_1·e_2 > 0
        q_1 = q_3
      end
    end
    if r_k == 1
      e_a = p_3 - q_3
    end
    if r_k == 2
      e_m = p_3 - q_3
      F_7 = q_3
    end
  end
  if e_a·e_m <= 0
    h_b = h_m
  end
  if e_a·e_m > 0
    h_a = h_m
  end
end
M_f = zeros(11, 2)
M_m = zeros(11, 2)
t_m = zeros(n_d + 1, 1)
for k_l = 1:11
  l_m = (k_l - 1)·0.1
  for j = 1:n_d + 1
    t_m(j) = atan(l_m·sin(pi·(j - 1)/n_d))
  end
  f_a = 0.5
  f_b = 4
  for k = 1:45
    f_m = (f_a + f_b)/2
    Z_a = 0
    Z_m = 0
    for i = 1:n_d
      u_1 = t_f/f_a·cos(a_d(i)) - sin(a_d(i))
      u_2 = t_f/f_a·sin(a_d(i)) + cos(a_d(i))
      v_0 = -c/f_a·l_d(i)·cos(a_d(i)) - Z_a·cos(t_m(i))
      v_1 = -c/f_a·l_d(i)·sin(a_d(i)) + W_d(i) - Z_a·sin(t_m(i))
      Z_a = (u_1·v_1 - u_2·v_0)/(-u_1·sin(t_m(i + 1)) + u_2·cos(t_m(i + 1)))
      w_1 = t_f/f_m·cos(a_d(i)) - sin(a_d(i))
      w_2 = t_f/f_m·sin(a_d(i)) + cos(a_d(i))
      g_0 = -c/f_m·l_d(i)·cos(a_d(i)) - Z_m·cos(t_m(i))
      g_1 = -c/f_m·l_d(i)·sin(a_d(i)) + W_d(i) - Z_m·sin(t_m(i))
      Z_m = (w_1·g_1 - w_2·g_0)/(-w_1·sin(t_m(i + 1)) + w_2·cos(t_m(i + 1)))
    end
    if Z_a·Z_m <= 0
      f_b = f_m
    end
    if Z_a·Z_m > 0
      f_a = f_m
    end
  end
  F_k = 1.3
  for k = 1:40
    Z_q = 0
    s_r = 0
    for i = 1:n_d
      u_1 = t_f/F_k·cos(a_d(i)) - sin(a_d(i))
      u_2 = t_f/F_k·sin(a_d(i)) + cos(a_d(i))
      v_0 = -c/F_k·l_d(i)·cos(a_d(i)) - Z_q·cos(t_m(i))
      v_1 = -c/F_k·l_d(i)·sin(a_d(i)) + W_d(i) - Z_q·sin(t_m(i))
      d_t = -u_1·sin(t_m(i + 1)) + u_2·cos(t_m(i + 1))
      N_q = (-v_0·sin(t_m(i + 1)) + cos(t_m(i + 1))·v_1)/d_t
      Z_q = (u_1·v_1 - u_2·v_0)/d_t
      s_r = s_r + c·l_d(i) + N_q·t_f
    end
    F_k = s_r/S_W
  end
  M_f(k_l, 1) = l_m
  M_f(k_l, 2) = f_m
  M_m(k_l, 1) = l_m
  M_m(k_l, 2) = F_k
end
k_x = 1
for k_l = 1:10
  if (M_f(k_l, 2) - M_m(k_l, 2))·(M_f(k_l + 1, 2) - M_m(k_l + 1, 2)) <= 0
    k_x = k_l
  end
end
e_1 = M_f(k_x, 2) - M_m(k_x, 2)
e_2 = M_f(k_x + 1, 2) - M_m(k_x + 1, 2)
l_P = M_f(k_x, 1) + 0.1·e_1/(e_1 - e_2)
F_8 = M_m(k_x, 2) + (M_m(k_x + 1, 2) - M_m(k_x, 2))·e_1/(e_1 - e_2)
#show
F_5 'Cuerpo de Ingenieros (θ paralelo al terreno) [-]
F_6 'Lowe-Karafiath [-]
t_S = h_m·180/pi 'θ de Spencer [°]
F_7 'Spencer [-]
l_P 'λ de Morgenstern-Price [-]
F_8 'Morgenstern-Price [-]
#: **Morgenstern-Price:** F de fuerzas y F de momentos contra λ (se cruzan en la solución). Pasa el cursor:
#fplot(fuerzas = M_f, momentos = M_m, [0 1])
t_h = [F_1, F_2, F_4, F_5, F_6, F_7, F_8] 'los 7 factores de seguridad
#tabla("Método","F:4")({"Ordinario (Fellenius)","Bishop simplificado","Janbu corregido","Cuerpo de Ingenieros","Lowe-Karafiath","Spencer","Morgenstern-Price"}; t_h)

## 6 · Cómo cambia F con c y φ (2D y 3D)
#: En el MISMO círculo crítico, el Ordinario es una fórmula cerrada: F = (c·ΣΔl + tan φ·Σ W·cos α)/Σ W·sin α. Pasa el cursor (x = c en kPa, y = φ en °); para otra pendiente o altura, cambia los datos de arriba:
D_l = S_L/c 'Σ Δl [m]
S_F(x, y) = (x·D_l + tan(y·pi/180)·S_C)/S_W
#map(S_F(x, y), [0 40], [5 40])
#surf(S_F(x, y), [0 40], [5 40])
