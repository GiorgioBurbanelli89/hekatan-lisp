# XSLOPE paso a paso: los 7 métodos de equilibrio límite (Fellenius, Bishop, Janbu, Cuerpo de Ingenieros, Lowe-Karafiath, Spencer, Morgenstern-Price) y elementos finitos, primero con símbolos y luego con números
#numerico

## 1 · El talud, el círculo y las dovelas
#: **XSLOPE** (Norman Jones, BYU, código abierto en Python) calcula el factor de seguridad de un talud con 7 métodos de **equilibrio límite** y con **elementos finitos**. Esta hoja hace TODOS sus métodos a mano, con las fórmulas que están en su código, sobre las MISMAS dovelas que genera XSLOPE, y compara cada número. Talud de Griffiths y Lane (1999), ejemplo 2: cara 2:1 de H = 15.24 m, c = 15 kPa, φ = 20°, γ = 19.64 kN/m³, sin agua.
#: La idea de todos los métodos de equilibrio límite: se supone una superficie de falla (aquí un círculo), se corta la masa que desliza en **dovelas** verticales y se pregunta: ¿por cuánto hay que dividir la resistencia (c/F, tanφ/F) para que la masa quede justo en equilibrio? Ese F es el factor de seguridad. Los métodos solo difieren en **qué equilibrio cumplen** (momentos, fuerzas o los dos) y **qué suponen de las fuerzas entre dovelas**.
#dibujo("El talud, el círculo crítico de XSLOPE y sus 30 dovelas", ud = m, escala = auto, cotas = m, alto = 110)
#  achurado([0, 91.44, 91.44, 60.96, 30.48, 0], [0, 0, 22.86, 22.86, 7.62, 7.62], "suelo")
#  poligono(0, 0, 91.44, 0, 91.44, 22.86, 60.96, 22.86, 30.48, 7.62, 0, 7.62, "gruesa")
#  polilinea([30.486, 31.770, 33.063, 34.364, 35.670, 36.978, 38.287, 39.593, 40.895, 42.190, 43.475, 44.749, 46.009, 47.253, 48.478, 49.682, 50.863, 52.019, 53.148, 54.247, 55.315, 56.350, 57.350, 58.312, 59.236, 60.119, 60.960, 61.787, 62.566, 63.294, 63.971], [7.623, 7.368, 7.167, 7.023, 6.933, 6.900, 6.923, 7.002, 7.136, 7.326, 7.571, 7.871, 8.226, 8.633, 9.094, 9.606, 10.170, 10.783, 11.446, 12.156, 12.912, 13.714, 14.559, 15.445, 16.373, 17.338, 18.341, 19.420, 20.534, 21.681, 22.860], "gruesa rojo")
#  linea(31.770, 7.368, 31.770, 8.265, "fina rojo")
#  linea(33.063, 7.167, 33.063, 8.912, "fina rojo")
#  linea(34.364, 7.023, 34.364, 9.562, "fina rojo")
#  linea(35.670, 6.933, 35.670, 10.215, "fina rojo")
#  linea(36.978, 6.900, 36.978, 10.869, "fina rojo")
#  linea(38.287, 6.923, 38.287, 11.523, "fina rojo")
#  linea(39.593, 7.002, 39.593, 12.177, "fina rojo")
#  linea(40.895, 7.136, 40.895, 12.827, "fina rojo")
#  linea(42.190, 7.326, 42.190, 13.475, "fina rojo")
#  linea(43.475, 7.571, 43.475, 14.118, "fina rojo")
#  linea(44.749, 7.871, 44.749, 14.755, "fina rojo")
#  linea(46.009, 8.226, 46.009, 15.385, "fina rojo")
#  linea(47.253, 8.633, 47.253, 16.006, "fina rojo")
#  linea(48.478, 9.094, 48.478, 16.619, "fina rojo")
#  linea(49.682, 9.606, 49.682, 17.221, "fina rojo")
#  linea(50.863, 10.170, 50.863, 17.812, "fina rojo")
#  linea(52.019, 10.783, 52.019, 18.390, "fina rojo")
#  linea(53.148, 11.446, 53.148, 18.954, "fina rojo")
#  linea(54.247, 12.156, 54.247, 19.504, "fina rojo")
#  linea(55.315, 12.912, 55.315, 20.038, "fina rojo")
#  linea(56.350, 13.714, 56.350, 20.555, "fina rojo")
#  linea(57.350, 14.559, 57.350, 21.055, "fina rojo")
#  linea(58.312, 15.445, 58.312, 21.536, "fina rojo")
#  linea(59.236, 16.373, 59.236, 21.998, "fina rojo")
#  linea(60.119, 17.338, 60.119, 22.439, "fina rojo")
#  linea(60.960, 18.341, 60.960, 22.860, "fina rojo")
#  linea(61.787, 19.420, 61.787, 22.860, "fina rojo")
#  linea(62.566, 20.534, 62.566, 22.860, "fina rojo")
#  linea(63.294, 21.681, 63.294, 22.860, "fina rojo")
#  circulo(37.10, 37.50, 0.6, "rojo")
#  texto(37.10, 39.50, "centro (37.10, 37.50), R = 30.60 m", 2.4, "c")
#  linea(37.10, 37.50, 63.97, 22.86, "trazos")
#fin

## 2 · Primero con símbolos
#: **Una dovela** de ancho b, base inclinada α y largo Δl = b/cos α, peso W = γ·b·h. Sobre su base actúan la normal N y el corte movilizado S = (c·Δl + N·tan φ)/F. Entre dovelas, la fuerza Z inclinada θ.
l_b = Simplify{b/cos(alpha)}
S_m = Simplify{(c*b/cos(alpha) + N*t_p)/F}
#: (t_p = tan φ). **1) Ordinario o Fellenius (OMS):** ignora las fuerzas entre dovelas; N = W·cos α. Momentos respecto al centro del círculo (N pasa por el centro, el brazo de S es R y el de W es R·sin α):
F_OMS = Simplify{(c*l + W*cos(alpha)*t_p)/(W*sin(alpha))}
#: (cada término es la suma sobre las dovelas, Σ arriba y Σ abajo). **2) Bishop simplificado:** fuerzas entre dovelas horizontales; equilibrio vertical de la dovela da N, y momentos. Aparece m_α:
m_a = Simplify{cos(alpha) + sin(alpha)*t_p/F}
N_B = Simplify{(W - c*l*sin(alpha)/F)/(cos(alpha) + sin(alpha)*t_p/F)}
F_B = Simplify{(c*b + W*t_p)/(cos(alpha) + sin(alpha)*t_p/F)}
#: F_B es el término de cada dovela: F = Σ[(c·b + W·tan φ)/m_α] / Σ W·sin α (XSLOPE escribe c·b como c·Δl·cos α, que es lo mismo en una dovela recta). F está a los dos lados: se itera. **3) Janbu simplificado:** la misma N de Bishop, pero equilibrio de FUERZAS horizontales:
F_J0 = Simplify{(c*l + N*t_p)*cos(alpha)}
#: F₀ = Σ (c·Δl + N·tan φ)·cos α / Σ N·sin α, y Janbu lo corrige porque ignora el corte entre dovelas: f₀ = 1 + b₁·(d/L − 1.4·(d/L)²), con b₁ = 0.5 para suelo con c y φ, d la flecha máxima del círculo y L su cuerda.
f_0 = Simplify{1 + b_1*(q - 1.4*q^2)}
#: **4) a 7) La marcha de fuerzas** (la de XSLOPE): con Z₀ = 0 a la izquierda, el equilibrio horizontal y vertical de cada dovela da su N y la fuerza Z del lado derecho. Con m = tan φ/F:
a_11 = Simplify{m*cos(alpha) - sin(alpha)}
a_21 = Simplify{m*sin(alpha) + cos(alpha)}
#: y, con θᵢ y θᵢ₊₁ en sus dos bordes: b₀ = −(c/F)·Δl·cos α − Zᵢ·cos θᵢ, b₁ = −(c/F)·Δl·sin α + W − Zᵢ·sin θᵢ, det = −a₁₁·sin θᵢ₊₁ + a₂₁·cos θᵢ₊₁:
Z_d = Simplify{(a_11*b_1 - a_21*b_0)/(-a_11*sin(t_2) + a_21*cos(t_2))}
#: F es el que deja **Z = 0 al final** (la última dovela no empuja a nadie). Cada método pone su θ:
#: • **Cuerpo de Ingenieros (variante 2):** θ paralelo al terreno en cada borde. • **Lowe-Karafiath:** θ = promedio de la pendiente del terreno y de la base. • **Spencer:** θ constante, y se busca el θ que cumpla también los MOMENTOS. • **Morgenstern-Price:** tan θ = λ·f(x) con f = sin(π·x̂) (medio seno), y se busca el λ que cumpla los momentos.
#: En un círculo los momentos respecto al centro son sencillos (N pasa por el centro y las Z se anulan de a pares): Σ W·sin α = Σ (c·Δl + N·tan φ)/F. **Spencer** clásico, con la resultante Q de cada dovela:
Q_S = Simplify{(c*l/F + W*cos(alpha)*t_p/F - W*sin(alpha))/(cos(alpha - t)*(1 + t_p*sin(alpha - t)/(cos(alpha - t)*F)))}
#: fuerzas: Σ Q = 0 y momentos: Σ Q·cos(α − θ) = 0.

## 3 · Ahora con números (con unidades)
c = 15 'cohesión [kPa]
fi = 20·pi/180 'ángulo de fricción φ = 20° [rad]
t_f = tan(fi) 'tan φ [-]
X_o = 37.1000 'centro del círculo crítico de XSLOPE, x [m]
Y_o = 37.5000 'centro, y [m]
R_c = 30.6000 'radio [m]
n_d = 30 'número de dovelas [-]
#: **Las dovelas de XSLOPE** (x del centro, ancho b, inclinación α de la base, largo Δl y peso W de cada una):
#hide
x_d = [31.12825, 32.41671, 33.71372, 35.01693, 36.32396, 37.63240, 38.93987, 40.24397, 41.54232, 42.83254, 44.11228, 45.37919, 46.63096, 47.86529, 49.07993, 50.27266, 51.44129, 52.58369, 53.69776, 54.78147, 55.83284, 56.84994, 57.83091, 58.77396, 59.67737, 60.53947, 61.37361, 62.17648, 62.92988, 63.63232]
b_d = [1.28358, 1.29333, 1.30071, 1.30571, 1.30833, 1.30855, 1.30638, 1.30182, 1.29488, 1.28557, 1.27391, 1.25992, 1.24362, 1.22505, 1.20423, 1.18122, 1.15604, 1.12875, 1.09939, 1.06803, 1.03471, 0.99949, 0.96245, 0.92365, 0.88316, 0.84105, 0.82722, 0.77852, 0.72828, 0.67660]
a_g = [-11.25639, -8.80568, -6.35498, -3.90427, -1.45356, 0.99715, 3.44785, 5.89856, 8.34927, 10.79997, 13.25068, 15.70139, 18.15210, 20.60280, 23.05351, 25.50422, 27.95493, 30.40563, 32.85634, 35.30705, 37.75775, 40.20846, 42.65917, 45.10988, 47.56058, 50.01129, 52.50919, 55.05428, 57.59937, 60.14445]
l_d = [1.30885, 1.30885, 1.30885, 1.30885, 1.30885, 1.30885, 1.30885, 1.30885, 1.30885, 1.30885, 1.30885, 1.30885, 1.30885, 1.30885, 1.30885, 1.30885, 1.30885, 1.30885, 1.30885, 1.30885, 1.30885, 1.30885, 1.30885, 1.30885, 1.30885, 1.30885, 1.35926, 1.35926, 1.35926, 1.35926]
W_d = [11.48951, 33.72840, 54.89608, 74.81659, 93.32993, 110.29320, 125.58171, 139.08985, 150.73189, 160.44254, 168.17743, 173.91336, 177.64843, 179.40197, 179.21430, 177.14636, 173.27914, 167.71298, 160.56669, 151.97655, 142.09517, 131.09016, 119.14279, 106.44646, 93.20506, 79.63133, 64.85678, 44.28834, 25.26872, 8.03337]
y_1 = [7.62323, 8.26502, 8.91168, 9.56204, 10.21490, 10.86906, 11.52334, 12.17653, 12.82744, 13.47488, 14.11766, 14.75462, 15.38458, 16.00639, 16.61891, 17.22103, 17.81163, 18.38966, 18.95403, 19.50373, 20.03774, 20.55510, 21.05484, 21.53607, 21.99789, 22.43947, 22.86000, 22.86000, 22.86000, 22.86000]
y_2 = [8.26502, 8.91168, 9.56204, 10.21490, 10.86906, 11.52334, 12.17653, 12.82744, 13.47488, 14.11766, 14.75462, 15.38458, 16.00639, 16.61891, 17.22103, 17.81163, 18.38966, 18.95403, 19.50373, 20.03774, 20.55510, 21.05484, 21.53607, 21.99789, 22.43947, 22.86000, 22.86000, 22.86000, 22.86000, 22.86000]
y_3 = [7.62323, 7.36777, 7.16742, 7.02255, 6.93344, 6.90024, 6.92302, 7.00173, 7.13622, 7.32626, 7.57150, 7.87148, 8.22566, 8.63339, 9.09392, 9.60642, 10.16994, 10.78345, 11.44583, 12.15587, 12.91228, 13.71366, 14.55855, 15.44541, 16.37261, 17.33845, 18.34118, 19.41959, 20.53368, 21.68124]
y_4 = [7.36777, 7.16742, 7.02255, 6.93344, 6.90024, 6.92302, 7.00173, 7.13622, 7.32626, 7.57150, 7.87148, 8.22566, 8.63339, 9.09392, 9.60642, 10.16994, 10.78345, 11.44583, 12.15587, 12.91228, 13.71366, 14.55855, 15.44541, 16.37261, 17.33845, 18.34118, 19.41959, 20.53368, 21.68124, 22.86000]
y_c = [7.49550, 7.26759, 7.09499, 6.97800, 6.91684, 6.91163, 6.96237, 7.06898, 7.23124, 7.44888, 7.72149, 8.04857, 8.42952, 8.86366, 9.35017, 9.88818, 10.47669, 11.11464, 11.80085, 12.53408, 13.31297, 14.13610, 15.00198, 15.90901, 16.85553, 17.83982, 18.88039, 19.97664, 21.10746, 22.27062]
#show
#tabla("x [m]:2","b [m]:3","α [°]:2","Δl [m]:3","W [kN/m]:2")(x_d; b_d; a_g; l_d; W_d)
#hide
a_d = zeros(n_d, 1)
for i = 1:n_d
  a_d(i) = a_g(i)·pi/180
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
S_W 'Σ W·sin α, lo que empuja [kN/m]
S_L 'Σ c·Δl, la cohesión [kN/m]
S_C 'Σ W·cos α [kN/m]

### 3.1 · Ordinario (Fellenius)
F_1 = (S_L + S_C·t_f)/S_W 'factor de seguridad, Ordinario [-]

### 3.2 · Bishop simplificado (se itera)
#hide
F_2 = 1
for k = 1:40
  s_b = 0
  for i = 1:n_d
    s_b = s_b + (c·l_d(i)·cos(a_d(i)) + W_d(i)·t_f)/(cos(a_d(i)) + sin(a_d(i))·t_f/F_2)
  end
  F_2 = s_b/S_W
end
N_O = zeros(n_d, 2)
N_I = zeros(n_d, 2)
for i = 1:n_d
  N_O(i, 1) = x_d(i)
  N_O(i, 2) = W_d(i)·cos(a_d(i))
  N_I(i, 1) = x_d(i)
  N_I(i, 2) = (W_d(i) - c·l_d(i)·sin(a_d(i))/F_2)/(cos(a_d(i)) + sin(a_d(i))·t_f/F_2)
end
#show
F_2 'factor de seguridad, Bishop [-]
#: **La normal N de cada dovela**: Ordinario (W·cos α) contra Bishop (con el corte entre dovelas horizontal). Pasa el cursor:
#fplot(Ordinario = N_O, Bishop = N_I, [30 64])

### 3.3 · Janbu simplificado y su corrección f₀
#hide
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
x_1 = x_d(1) - b_d(1)/2
x_2 = x_d(n_d) + b_d(n_d)/2
L_c = sqrt((x_2 - x_1)^2 + (y_4(n_d) - y_3(1))^2)
d_m = 0
for i = 1:n_d
  d_m = max(d_m, abs((y_4(n_d) - y_3(1))·x_d(i) - (x_2 - x_1)·y_c(i) + x_2·y_3(1) - y_4(n_d)·x_1)/L_c)
end
#show
F_3 'Janbu sin corregir [-]
L_c 'cuerda del círculo [m]
d_m 'flecha máxima [m]
q_J = d_m/L_c 'd/L [-]
f_J = 1 + 0.5·(q_J - 1.4·q_J^2) 'corrección f₀ [-]
F_4 = F_3·f_J 'factor de seguridad, Janbu corregido [-]

### 3.4 · La marcha de fuerzas: Cuerpo de Ingenieros y Lowe-Karafiath
#: Pendientes del terreno y de la base en cada borde (promedio de las dos dovelas vecinas):
#hide
p_t = zeros(n_d + 1, 1)
p_b = zeros(n_d + 1, 1)
for j = 1:n_d + 1
  if j == 1
    p_t(j) = (y_2(1) - y_1(1))/b_d(1)
    p_b(j) = (y_4(1) - y_3(1))/b_d(1)
  end
  if j == n_d + 1
    p_t(j) = (y_2(n_d) - y_1(n_d))/b_d(n_d)
    p_b(j) = (y_4(n_d) - y_3(n_d))/b_d(n_d)
  end
  if j > 1
    if j < n_d + 1
      p_t(j) = ((y_2(j - 1) - y_1(j - 1))/b_d(j - 1) + (y_2(j) - y_1(j))/b_d(j))/2
      p_b(j) = ((y_4(j - 1) - y_3(j - 1))/b_d(j - 1) + (y_4(j) - y_3(j))/b_d(j))/2
    end
  end
end
t_C = zeros(n_d + 1, 1)
t_L = zeros(n_d + 1, 1)
for j = 1:n_d + 1
  t_C(j) = atan(p_t(j))
  t_L(j) = atan((p_t(j) + p_b(j))/2)
end
#show
#: **Cuerpo de Ingenieros:** se busca F (bisección) hasta que la última Z sea cero:
#hide
f_a = 1
f_b = 2.5
for k = 1:50
  f_m = (f_a + f_b)/2
  Z_a = 0
  Z_m = 0
  for i = 1:n_d
    u_1 = t_f/f_a·cos(a_d(i)) - sin(a_d(i))
    u_2 = t_f/f_a·sin(a_d(i)) + cos(a_d(i))
    v_0 = -c/f_a·l_d(i)·cos(a_d(i)) - Z_a·cos(t_C(i))
    v_1 = -c/f_a·l_d(i)·sin(a_d(i)) + W_d(i) - Z_a·sin(t_C(i))
    Z_a = (u_1·v_1 - u_2·v_0)/(-u_1·sin(t_C(i + 1)) + u_2·cos(t_C(i + 1)))
    w_1 = t_f/f_m·cos(a_d(i)) - sin(a_d(i))
    w_2 = t_f/f_m·sin(a_d(i)) + cos(a_d(i))
    g_0 = -c/f_m·l_d(i)·cos(a_d(i)) - Z_m·cos(t_C(i))
    g_1 = -c/f_m·l_d(i)·sin(a_d(i)) + W_d(i) - Z_m·sin(t_C(i))
    Z_m = (w_1·g_1 - w_2·g_0)/(-w_1·sin(t_C(i + 1)) + w_2·cos(t_C(i + 1)))
  end
  if Z_a·Z_m <= 0
    f_b = f_m
  end
  if Z_a·Z_m > 0
    f_a = f_m
  end
end
F_5 = f_m
Z_C = zeros(n_d + 1, 2)
Z_q = 0
Z_C(1, 1) = x_1
for i = 1:n_d
  u_1 = t_f/F_5·cos(a_d(i)) - sin(a_d(i))
  u_2 = t_f/F_5·sin(a_d(i)) + cos(a_d(i))
  v_0 = -c/F_5·l_d(i)·cos(a_d(i)) - Z_q·cos(t_C(i))
  v_1 = -c/F_5·l_d(i)·sin(a_d(i)) + W_d(i) - Z_q·sin(t_C(i))
  Z_q = (u_1·v_1 - u_2·v_0)/(-u_1·sin(t_C(i + 1)) + u_2·cos(t_C(i + 1)))
  Z_C(i + 1, 1) = x_d(i) + b_d(i)/2
  Z_C(i + 1, 2) = Z_q
end
#show
F_5 'factor de seguridad, Cuerpo de Ingenieros (2) [-]
#: **Lowe-Karafiath:** la misma marcha con su θ:
#hide
f_a = 1
f_b = 2.5
for k = 1:50
  f_m = (f_a + f_b)/2
  Z_a = 0
  Z_m = 0
  for i = 1:n_d
    u_1 = t_f/f_a·cos(a_d(i)) - sin(a_d(i))
    u_2 = t_f/f_a·sin(a_d(i)) + cos(a_d(i))
    v_0 = -c/f_a·l_d(i)·cos(a_d(i)) - Z_a·cos(t_L(i))
    v_1 = -c/f_a·l_d(i)·sin(a_d(i)) + W_d(i) - Z_a·sin(t_L(i))
    Z_a = (u_1·v_1 - u_2·v_0)/(-u_1·sin(t_L(i + 1)) + u_2·cos(t_L(i + 1)))
    w_1 = t_f/f_m·cos(a_d(i)) - sin(a_d(i))
    w_2 = t_f/f_m·sin(a_d(i)) + cos(a_d(i))
    g_0 = -c/f_m·l_d(i)·cos(a_d(i)) - Z_m·cos(t_L(i))
    g_1 = -c/f_m·l_d(i)·sin(a_d(i)) + W_d(i) - Z_m·sin(t_L(i))
    Z_m = (w_1·g_1 - w_2·g_0)/(-w_1·sin(t_L(i + 1)) + w_2·cos(t_L(i + 1)))
  end
  if Z_a·Z_m <= 0
    f_b = f_m
  end
  if Z_a·Z_m > 0
    f_a = f_m
  end
end
F_6 = f_m
#show
F_6 'factor de seguridad, Lowe-Karafiath [-]
#: **La fuerza entre dovelas Z** a lo largo del talud (Cuerpo de Ingenieros): crece desde cero en el pie, llega a su máximo en el medio y vuelve a cero en la corona. Pasa el cursor:
#fplot(Z = Z_C, [30 64])

### 3.5 · Spencer: fuerzas Y momentos con θ constante
#: Para cada θ se buscan dos F: el de fuerzas (Σ Q = 0) y el de momentos (Σ Q·cos(α − θ) = 0). Spencer es el θ donde los dos coinciden:
#hide
h_a = 0
h_b = 0.7
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
    p_1 = 0.8
    p_2 = 2.5
    for j = 1:45
      p_3 = (p_1 + p_2)/2
      g_a = 0
      g_m = 0
      for i = 1:n_d
        g_a = g_a + (c·l_d(i)/p_1 + W_d(i)·cos(a_d(i))·t_f/p_1 - W_d(i)·sin(a_d(i)))/(cos(a_d(i) - t_k)·(1 + t_f·tan(a_d(i) - t_k)/p_1))
        g_m = g_m + (c·l_d(i)/p_3 + W_d(i)·cos(a_d(i))·t_f/p_3 - W_d(i)·sin(a_d(i)))/(cos(a_d(i) - t_k)·(1 + t_f·tan(a_d(i) - t_k)/p_3))
      end
      if g_a·g_m <= 0
        p_2 = p_3
      end
      if g_a·g_m > 0
        p_1 = p_3
      end
    end
    q_1 = 0.8
    q_2 = 2.5
    for j = 1:45
      q_3 = (q_1 + q_2)/2
      g_a = 0
      g_m = 0
      for i = 1:n_d
        g_a = g_a + (c·l_d(i)/q_1 + W_d(i)·cos(a_d(i))·t_f/q_1 - W_d(i)·sin(a_d(i)))/(1 + t_f·tan(a_d(i) - t_k)/q_1)
        g_m = g_m + (c·l_d(i)/q_3 + W_d(i)·cos(a_d(i))·t_f/q_3 - W_d(i)·sin(a_d(i)))/(1 + t_f·tan(a_d(i) - t_k)/q_3)
      end
      if g_a·g_m <= 0
        q_2 = q_3
      end
      if g_a·g_m > 0
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
#show
t_S = h_m·180/pi 'θ de Spencer [°]
F_7 'factor de seguridad, Spencer [-]

### 3.6 · Morgenstern-Price: tan θ = λ·sin(π·x̂)
#: Para cada λ: F de fuerzas (la marcha) y F de momentos (Σ W·sin α = Σ (c·Δl + N·tan φ)/F con la N de la marcha). Se calculan las dos curvas F(λ) y Morgenstern-Price es donde se cruzan:
#hide
x_n = zeros(n_d + 1, 1)
x_n(1) = 0
for i = 1:n_d
  x_n(i + 1) = (x_d(i) + b_d(i)/2 - x_1)/(x_2 - x_1)
end
M_f = zeros(11, 2)
M_m = zeros(11, 2)
t_m = zeros(n_d + 1, 1)
for k_l = 1:11
  l_m = (k_l - 1)·0.1
  for j = 1:n_d + 1
    t_m(j) = atan(l_m·sin(pi·x_n(j)))
  end
  f_a = 1
  f_b = 2.5
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
      N_q = (v_0·(-sin(t_m(i + 1))) + cos(t_m(i + 1))·v_1)/d_t
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
#: **Las dos curvas de Morgenstern-Price** (F de fuerzas y F de momentos contra λ): donde se cruzan las dos se cumplen a la vez. Pasa el cursor:
#fplot(fuerzas = M_f, momentos = M_m, [0 1])
l_P 'λ de Morgenstern-Price (cruce de las curvas, cada 0.1 e interpolado) [-]
F_8 'factor de seguridad, Morgenstern-Price [-]

## 4 · Cómo cambia el factor de seguridad con c y φ (2D y 3D)
#: Con el Ordinario el F de este círculo es una fórmula cerrada en c y φ: F = (c·ΣΔl + tan φ·Σ W·cos α)/Σ W·sin α. En el plano (c, φ) la línea F = 1 separa lo que falla de lo que aguanta. Pasa el cursor:
D_l = 39.46716 'Σ Δl [m]
F_o(x, y) = (x·D_l + tan(y·pi/180)·S_C)/S_W
#map(F_o(x, y), [0 30], [5 35])
#: La misma superficie en 3D (arrastra para girar):
#surf(F_o(x, y), [0 30], [5 35])

## 5 · Elementos finitos en XSLOPE (reducción de resistencia)
#: XSLOPE también resuelve el talud SIN suponer la superficie: malla de triángulos T6, Mohr-Coulomb con ψ = 0, y la misma idea de dividir c y tan φ por F; F sube por bisección hasta que la masa ya no se queda quieta. Es lo que la **hoja 190** hace paso a paso (funciones de forma, Jacobiano, matriz K, retorno al cono y Newton) y la **hoja 191** comprueba punto por punto. Con la MISMA malla de la hoja 190 (144 T6) XSLOPE da:
F_9 = 1.436 'XSLOPE, elementos finitos (bisección hasta 0.004) [-]
F_G = 1.407 'Hekatan Geotechnic, misma malla y Mohr-Coulomb [-]
#: y nudo a nudo los desplazamientos con F = 1 difieren 0.19 %.

## 6 · La hoja contra XSLOPE
t_x = [1.29462, 1.37710, 1.35269, 1.41366, 1.38986, 1.37377, 1.37363] 'XSLOPE 1.1.0 (mismo círculo, mismas dovelas)
t_h = [F_1, F_2, F_4, F_5, F_6, F_7, F_8] 'esta hoja
#tabla("Método","XSLOPE:5","Hoja:5")({"Ordinario (Fellenius)","Bishop simplificado","Janbu corregido","Cuerpo de Ingenieros (2)","Lowe-Karafiath","Spencer","Morgenstern-Price"}; t_x; t_h)
#: **Qué equilibrio cumple cada uno:** Ordinario y Bishop: momentos. Janbu, Cuerpo de Ingenieros y Lowe: fuerzas. Spencer y Morgenstern-Price: los dos (son los «rigurosos»). Por eso Spencer y Morgenstern-Price casi coinciden (1.374), Bishop queda a 0.2 % de ellos, el Ordinario sale bajo (ignora las fuerzas entre dovelas) y el Cuerpo de Ingenieros sale alto (lo dice el propio XSLOPE: no es conservador). Elementos finitos (1.436) no supone la superficie ni las fuerzas entre dovelas; Griffiths y Lane dan 1.40.
