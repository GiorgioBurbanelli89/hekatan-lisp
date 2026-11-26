# Newton-Raphson desde cero: cómo se resuelve un problema NO LINEAL (una barra que se ablanda, una cercha y el talud)
#numerico

## 1 · El problema: lineal contra no lineal
#: **Lineal:** una barra de rigidez k cargada con P se acorta d = P/k. Una división, un paso, listo. Con EA = 60 000 kN y L = 3 m, k = 20 000 kN/m, y con P = 240 kN: **d = 12 mm**.
#: **No lineal:** la barra real se **ablanda** al cargarla (como un suelo o un acero que fluye): su fuerza N(d) no es una recta k·d sino una **curva** que se aplana hasta N_u = 300 kN. Ya no hay división posible: no se puede «despejar» d de una curva así de fácil. ¿Cuánto se acorta de verdad con 240 kN?
E_A = 60000 'rigidez axial EA [kN]
L_b = 3 'largo de la barra [m]
k_b = E_A/L_b 'rigidez inicial k₀ = EA/L [kN/m]
N_m = 300 'fuerza máxima que aguanta N_u [kN]
P_c = 240 'carga aplicada (80 % de N_u) [kN]
d_e = P_c/(k_b·(1 - P_c/N_m)) 'respuesta exacta de la curva [m]
d_l = P_c/k_b 'lo que diría un cálculo LINEAL [m]
#: El cálculo lineal se queda corto: la barra real se acorta **5 veces más** (60 mm, no 12).

## 2 · La idea (sin fórmulas)
#: **Si no sabes resolver una curva, resuelve una recta… y repite.** Desde donde estás, haz como si la barra fuera lineal con la rigidez que tiene **en ese momento** (la pendiente de la curva ahí). Esa recta sí se resuelve con una división. Con la respuesta, mira cuánto da la barra de verdad, calcula cuánto falta y repite. Cada vuelta falta menos.

## 3 · Paso a paso, con palabras
#: **Vuelta 1.** Arrancamos en d = 0. La rigidez ahí es la inicial, 20 000 kN/m. Faltan 240 kN → avanzo 240/20 000 = 12 mm. **d = 12 mm**. Pero con 12 mm la barra de verdad solo da **133 kN**: faltan **107 kN**.
#: **Vuelta 2.** En 12 mm la barra ya se ablandó: su pendiente es 6 173 kN/m. Faltan 107 kN → avanzo 107/6 173 = 17 mm. **d = 29 mm**. La barra da **198 kN**: faltan **42 kN**.
#: **Vuelta 3.** Pendiente 2 295 kN/m → avanzo 42/2 295 = 18 mm. **d = 47 mm**. Da **228 kN**: faltan **12 kN**.
#: **Vuelta 4.** Pendiente 1 155 kN/m → avanzo 12/1 155 = 10 mm. **d = 57.9 mm**. Da **238.3 kN**: falta **1.7 kN**.
#: **Vuelta 5.** Pendiente 847 kN/m → avanzo 2 mm. **d = 59.94 mm**. Da **239.95 kN**: faltan **0.05 kN**.
#: **Vuelta 6.** **d = 60.000 mm**, da **240 kN**: no falta nada. Listo.
#: Lo que «falta» se llama **residuo**. Fíjate cómo baja: 240 → 107 → 42 → 12 → 1.7 → 0.05 → 0. Al final cada vuelta **duplica las cifras correctas**. La misma tabla, calculada por la hoja:
#: (cada fila: d en la vuelta k, el residuo P − N(d), la pendiente usada (con signo menos: es la derivada del residuo), el error frente a los 60 mm y el cociente e_{k+1}/e_k², casi constante: eso es la **convergencia cuadrática**):
#hide
T_g = zeros(8, 6)
d_k = 0
for i = 1:8
  f_k = P_c - k_b·d_k/(1 + k_b·d_k/N_m)
  p_k = -k_b/(1 + k_b·d_k/N_m)^2
  e_k = abs(d_k - d_e)
  T_g(i, 6) = i - 1
  T_g(i, 1) = 1000·d_k
  T_g(i, 2) = f_k
  T_g(i, 3) = p_k
  T_g(i, 4) = 1000·e_k
  d_k = d_k - f_k/p_k
end
for i = 1:7
  if T_g(i, 4) > 1e-9
    T_g(i, 5) = T_g(i + 1, 4)/T_g(i, 4)^2
  end
end
#show
#tabla("vuelta k:0","d [mm]:4","residuo [kN]:4","−pendiente [kN/m]:1","error [mm]:6","e_k+1/e_k² [1/mm]:5")(T_g(1:8, 6); T_g(1:8, 1); T_g(1:8, 2); T_g(1:8, 3); T_g(1:8, 4); T_g(1:8, 5))
d_N = d_k 'Newton después de 8 vueltas [m]

## 4 · El zigzag (paso a paso, animado)
#: **La curva y Newton en zigzag** (d en mm, fuerza en kN): sube por la tangente hasta la carga P = 240 kN, baja a la curva, vuelve a subir… Pasa el cursor:
#hide
D_v = zeros(9, 1)
d_k = 0
for i = 1:8
  D_v(i) = d_k
  d_k = d_k - (P_c - k_b·d_k/(1 + k_b·d_k/N_m))/(-k_b/(1 + k_b·d_k/N_m)^2)
end
D_v(9) = d_k
Z_z = zeros(80, 2)
for i = 1:8
  N_a = k_b·D_v(i)/(1 + k_b·D_v(i)/N_m)
  N_b = k_b·D_v(i + 1)/(1 + k_b·D_v(i + 1)/N_m)
  for j = 1:6
    Z_z(10·(i - 1) + j, 1) = 1000·(D_v(i) + (D_v(i + 1) - D_v(i))·(j - 1)/5)
    Z_z(10·(i - 1) + j, 2) = N_a + (P_c - N_a)·(j - 1)/5
  end
  for j = 1:4
    Z_z(10·(i - 1) + 6 + j, 1) = 1000·D_v(i + 1)
    Z_z(10·(i - 1) + 6 + j, 2) = P_c - (P_c - N_b)·j/4
  end
end
C_b = zeros(41, 2)
for j = 1:41
  C_b(j, 1) = 2·(j - 1)
  C_b(j, 2) = k_b·0.002·(j - 1)/(1 + k_b·0.002·(j - 1)/N_m)
end
#show
#fplot(barra = C_b, Newton = Z_z, [0 80])
#: **La tangente que avanza** (gráfica dinámica): mueve la barra para elegir el punto d_k (en mm) y mira la recta tangente: donde corta la carga P = 240 kN está el siguiente d. Con d en mm la barra es N(x) = 20x/(1 + 20x/300):
#slider fplot(barra = 20*x/(1 + 20*x/300), carga = 240 + 0*x, tangente = 20*n/(1 + 20*n/300) + 20/(1 + 20*n/300)^2*(x - n), [0 80]), n = 0:5:60
#: Lo mismo animado, el punto recorriendo la curva:
#anim fplot(barra = 20*x/(1 + 20*x/300), carga = 240 + 0*x, tangente = 20*n/(1 + 20*n/300) + 20/(1 + 20*n/300)^2*(x - n), [0 80]), n = 0:1:60

## 5 · Recién ahora, la fórmula
#: Cada vuelta hizo lo mismo: **avance = lo que falta / la rigidez de ese momento**.
#: **Δd = R / k_T**, con R = P − N(d) (el residuo) y k_T = la pendiente de la curva en ese d (la **rigidez tangente**).
#: Con símbolos: el residuo como función de d, y su derivada (que el motor calcula sola):
f_d = Simplify{P - k_0*d/(1 + k_0*d/N_u)}
f_p = Simplify{Diff{P - k_0*d/(1 + k_0*d/N_u) @ d}}
#: (el signo menos: al aumentar d el residuo baja; k_T = −f′). **Con muchas incógnitas** (una cercha, un pórtico, un talud) es lo mismo con matrices: **K_T·Δu = R**. Lineal = UN paso con la K inicial; no lineal = muchos pasos lineales, cada uno con la K del momento. Para una barra inclinada:
K_e = Simplify{k_t*[c^2, c*s; c*s, s^2]}
## 6 · Para qué sirve: una cercha que se ablanda
#: Dos barras que se ablandan (como en la hoja 196), el nudo C cargado con P = 300 kN hacia abajo y H = 30 kN. Dos incógnitas (u_x, u_y): en cada vuelta se arma K_T con la rigidez de cada barra EN ESE MOMENTO, se resuelve K_T·Δu = R y se repite:
P_y = 300 'carga vertical (abajo) [kN]
H_x = 30 'carga horizontal [kN]
c_1 = 1/sqrt(10) 'barra AC: cos [-]
s_1 = 3/sqrt(10) 'barra AC: sin [-]
c_2 = -3/sqrt(18) 'barra BC: cos [-]
s_2 = 3/sqrt(18) 'barra BC: sin [-]
k_1 = E_A/sqrt(10) 'rigidez inicial de AC [kN/m]
k_2 = E_A/sqrt(18) 'rigidez inicial de BC [kN/m]
#hide
T_c = zeros(7, 4)
u_x = 0
u_y = 0
for i = 1:7
  a_1 = c_1·u_x + s_1·u_y
  a_2 = c_2·u_x + s_2·u_y
  N_1 = k_1·a_1/(1 + k_1·abs(a_1)/N_m)
  N_2 = k_2·a_2/(1 + k_2·abs(a_2)/N_m)
  t_1 = k_1/(1 + k_1·abs(a_1)/N_m)^2
  t_2 = k_2/(1 + k_2·abs(a_2)/N_m)^2
  R_x = H_x - (N_1·c_1 + N_2·c_2)
  R_y = -P_y - (N_1·s_1 + N_2·s_2)
  T_c(i, 4) = i - 1
  T_c(i, 1) = 1000·u_x
  T_c(i, 2) = 1000·u_y
  T_c(i, 3) = sqrt(R_x^2 + R_y^2)
  b_11 = t_1·c_1^2 + t_2·c_2^2
  b_12 = t_1·c_1·s_1 + t_2·c_2·s_2
  b_22 = t_1·s_1^2 + t_2·s_2^2
  d_t = b_11·b_22 - b_12^2
  u_x = u_x + (b_22·R_x - b_12·R_y)/d_t
  u_y = u_y + (-b_12·R_x + b_11·R_y)/d_t
end
#show
#tabla("k:0","u_x [mm]:4","u_y [mm]:4","|R| [kN]:4")(T_c(1:7, 4); T_c(1:7, 1); T_c(1:7, 2); T_c(1:7, 3))
v_x = 1000·u_x 'u_x final [mm]
v_y = 1000·u_y 'u_y final [mm]
#: El residuo 301 → 115 → 34 → 6.2 → 0.38 → 0.0016 → 0: la misma convergencia cuadrática que con una sola barra. **Esto es lo que hace un programa de elementos finitos** (el talud de las hojas 190 y 194, con 666 incógnitas): aplicar la función G una y otra vez hasta que el residuo baja del límite.
#: **El talud** (hojas 190 y 194) es lo mismo con 666 incógnitas. Y ahí aparece algo nuevo: si se debilita el suelo, llega un momento en que la rigidez tangente se va a cero (la curva se pone horizontal, como la barra cuando llega a N_u): el residuo **ya no baja**, por más vueltas que se den. Eso significa que no hay equilibrio: **el talud se cayó**. El último debilitamiento con el que Newton todavía converge es el **factor de seguridad**.

## 7 · Lo mismo, escrito como función
#: Todo el método cabe en una función: **g(d) = d − f(d)/f′(d)** (entra un d, sale uno mejor) y se aplica una y otra vez: d₁ = g(d₀), d₂ = g(d₁), … Con símbolos:
g_N = Simplify{d - (P - k_0*d/(1 + k_0*d/N_u))/(-N_u^2*k_0/(d*k_0 + N_u)^2)}
#: Cuando f(d) = 0, g(d) = d: el punto ya no se mueve (un **punto fijo**).
#: g(x) = x + (240 − N(x))/N′(x) contra la recta y = x. Donde se cruzan, g(x) = x: ahí está la respuesta (60 mm). Cerca de 60 la curva g es casi horizontal: por eso converge tan rápido:
#fplot(g = x + (240 - 20*x/(1 + 20*x/300))*(1 + 20*x/300)^2/20, identidad = x, [0 80])
#: **La función g en 3D**, para cualquier carga y (kN) y cualquier punto x (mm): la superficie dice a dónde salta Newton desde cada x. Arrastra para girar:
g_3(x, y) = x + (y - 20*x/(1 + 20*x/300))*(1 + 20*x/300)^2/20
#map(g_3(x, y), [0 80], [50 280])
#surf(g_3(x, y), [0 80], [50 280])

