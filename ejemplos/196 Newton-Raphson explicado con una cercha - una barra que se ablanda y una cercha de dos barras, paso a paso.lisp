# Newton-Raphson explicado con una cercha: una barra que se ablanda y una cercha de dos barras, paso a paso
#numerico

## 1 · La idea en una frase
#: **Newton-Raphson = cambiar la curva por una recta, resolver la recta, y repetir.** En cada paso se usa la recta tangente y = m·x + b en el punto donde estamos (m = la rigidez de ese momento), se calcula dónde esa recta llega a la carga, y desde ahí se vuelve a mirar la curva verdadera. Si la barra fuera lineal (una sola recta), bastaría UN paso: eso es K·u = F. Como la barra se ablanda, hacen falta varios.
#: **¿Y los cordones de una cercha?** En una cercha ideal (nudos articulados, cargas solo en los nudos) TODAS las barras trabajan solo a fuerza axial, también los cordones. La «flexión» de la cercha entera se reparte como un par: el cordón inferior tracciona y el superior comprime, N = M/h, igual que las alas de una viga I. Por eso basta la rigidez axial EA/L de cada barra.

## 2 · Una barra que se ablanda (1 incógnita)
#dibujo("Una barra empotrada abajo, cargada arriba con P", ud = m, escala = auto, alto = 70)
#  achurado([-0.8, 0.8, 0.8, -0.8], [-0.4, -0.4, 0, 0], "suelo")
#  linea(0, 0, 0, 3, "gruesa")
#  flecha(0, 4.2, 0, 3.05, "gruesa rojo")
#  texto(0.9, 3.8, "P", 2.6, "c")
#  texto(0.9, 1.5, "L = 3 m", 2.4, "c")
#fin
#: **La barra se ablanda como el suelo** (curva hiperbólica): al principio responde con su rigidez lineal k₀ = EA/L, y cuanto más se acorta, más blanda se pone, hasta no pasar de N_u:
N = Simplify{k_0*d/(1 + k_0*d/N_u)}
#: La **rigidez tangente** es la pendiente de esa curva, su derivada (la «m» de la recta tangente):
k_T = Simplify{Diff{k_0*d/(1 + k_0*d/N_u) @ d}}
#: Con d = 0 da k₀ (la rigidez lineal) y baja a medida que la barra se deforma. **Un paso de Newton:** la recta tangente en d_k es N ≈ N(d_k) + k_T(d_k)·(d − d_k); se iguala a la carga P y se despeja el nuevo d:
d_n = Simplify{d_k + (P - N_k)/k_k}
#: (N_k y k_k son N y k_T evaluadas en d_k). El residuo R = P − N_k es «lo que falta por equilibrar»; cuando R ≈ 0, terminamos.

### Con números
E_A = 60000 'rigidez axial EA [kN]
L_b = 3 'largo [m]
k_0 = E_A/L_b 'rigidez lineal k₀ = EA/L [kN/m]
N_u = 300 'fuerza máxima que aguanta [kN]
P = 240 'carga (80 % de N_u) [kN]
d_L = P/k_0 'lo que diría un cálculo LINEAL (un solo paso) [m]
d_x = P/(k_0·(1 - P/N_u)) 'la respuesta exacta de la curva [m]
#: El lineal se queda corto: la barra real se acorta **5 veces más**. **Las iteraciones de Newton** (cada fila: d, N(d), la pendiente k_T y el residuo R = P − N):
#hide
T_N = zeros(8, 4)
D_v = zeros(9, 1)
d_k = 0
for k = 1:8
  N_k = k_0·d_k/(1 + k_0·d_k/N_u)
  k_k = k_0/(1 + k_0·d_k/N_u)^2
  T_N(k, 1) = 1000·d_k
  T_N(k, 2) = N_k
  T_N(k, 3) = k_k
  T_N(k, 4) = P - N_k
  D_v(k) = d_k
  d_k = d_k + (P - N_k)/k_k
end
D_v(9) = d_k
Z_z = zeros(80, 2)
for k = 1:8
  N_a = k_0·D_v(k)/(1 + k_0·D_v(k)/N_u)
  N_b = k_0·D_v(k + 1)/(1 + k_0·D_v(k + 1)/N_u)
  for j = 1:6
    Z_z(10·(k - 1) + j, 1) = 1000·(D_v(k) + (D_v(k + 1) - D_v(k))·(j - 1)/5)
    Z_z(10·(k - 1) + j, 2) = N_a + (P - N_a)·(j - 1)/5
  end
  for j = 1:4
    Z_z(10·(k - 1) + 6 + j, 1) = 1000·D_v(k + 1)
    Z_z(10·(k - 1) + 6 + j, 2) = P - (P - N_b)·j/4
  end
end
C_b = zeros(41, 2)
L_n = zeros(16, 2)
for j = 1:41
  C_b(j, 1) = 2·(j - 1)
  C_b(j, 2) = k_0·0.002·(j - 1)/(1 + k_0·0.002·(j - 1)/N_u)
end
for j = 1:16
  L_n(j, 1) = j - 1
  L_n(j, 2) = k_0·0.001·(j - 1)
end
i_t = [1, 2, 3, 4, 5, 6, 7, 8]
#show
#tabla("iteración:0","d [mm]:3","N [kN]:3","k_T [kN/m]:1","R = P − N [kN]:4")(i_t; T_N(1:8, 1); T_N(1:8, 2); T_N(1:8, 3); T_N(1:8, 4))
d_N = d_k 'Newton después de 8 pasos [m]
#: El residuo baja 106.7 → 41.6 → … → casi 0: cada paso **duplica las cifras correctas** (convergencia cuadrática). **La gráfica de Newton:** la curva de la barra, la recta lineal y el zigzag de Newton (desde la curva sube por la tangente hasta la carga P = 240 kN, baja a la curva, vuelve a subir…, y cada vez queda más cerca de la respuesta, 60 mm). Pasa el cursor por los puntos:
#fplot(barra = C_b, lineal = L_n, Newton = Z_z, [0 80])
#: (eje horizontal: acortamiento d en mm; vertical: fuerza N en kN.)

## 3 · Una cercha de dos barras (2 incógnitas: Newton con la matriz K)
#dibujo("Cercha de dos barras: apoyos A y B, nudo C cargado", ud = m, escala = auto, cotas = m, alto = 80)
#  poligono(0, 0, -0.35, -0.5, 0.35, -0.5, 0, 0, "gruesa")
#  poligono(4, 0, 3.65, -0.5, 4.35, -0.5, 4, 0, "gruesa")
#  linea(0, 0, 1, 3, "gruesa")
#  linea(4, 0, 1, 3, "gruesa")
#  flecha(1, 4.4, 1, 3.05, "gruesa rojo")
#  flecha(-0.6, 3, 0.95, 3, "rojo")
#  texto(1.6, 4.2, "P = 300 kN", 2.4, "c")
#  texto(-1.2, 3.4, "H = 30 kN", 2.4, "c")
#  texto(0, -0.9, "A", 2.4, "c")
#  texto(4, -0.9, "B", 2.4, "c")
#  texto(1, 3.5, "C", 2.4, "c")
#fin
#: Ahora la incógnita es el movimiento del nudo C, u = (u_x, u_y). Cada barra se acorta o se alarga δ = e·u (e = su vector unitario) y tiene su fuerza N(δ) y su rigidez k_T(δ). La **matriz de rigidez tangente** de la cercha suma las de sus barras, cada una en su dirección:
K_e = Simplify{k_b*[c^2, c*s; c*s, s^2]}
#: (k_b = rigidez tangente de la barra; c y s = coseno y seno de la barra). **Newton es igual que antes, pero con matrices:** R = F_ext − F_int, K_T·Δu = R, u ← u + Δu, hasta que R ≈ 0.
### Con números
P_y = 300 'carga vertical, hacia abajo [kN]
H_x = 30 'carga horizontal [kN]
c_1 = 1/sqrt(10) 'barra AC: cos [-]
s_1 = 3/sqrt(10) 'barra AC: sin [-]
c_2 = -3/sqrt(18) 'barra BC: cos [-]
s_2 = 3/sqrt(18) 'barra BC: sin [-]
k_1 = E_A/sqrt(10) 'rigidez lineal de AC = EA/L [kN/m]
k_2 = E_A/sqrt(18) 'rigidez lineal de BC [kN/m]
#: **Primero el cálculo LINEAL** (un solo paso, K·u = F con las rigideces iniciales):
K_L = [k_1·c_1^2 + k_2·c_2^2, k_1·c_1·s_1 + k_2·c_2·s_2; k_1·c_1·s_1 + k_2·c_2·s_2, k_1·s_1^2 + k_2·s_2^2] 'matriz K lineal [kN/m]
u_L = lsolve(K_L, [H_x; -P_y]) 'u lineal [m]
#: **Ahora Newton con las barras que se ablandan** (cada fila: iteración, u_x, u_y en mm, N de cada barra y el tamaño del residuo |R|):
#hide
T_C = zeros(8, 5)
u_x = 0
u_y = 0
for k = 1:8
  e_1 = c_1·u_x + s_1·u_y
  e_2 = c_2·u_x + s_2·u_y
  N_1 = k_1·e_1/(1 + k_1·abs(e_1)/N_u)
  N_2 = k_2·e_2/(1 + k_2·abs(e_2)/N_u)
  t_1 = k_1/(1 + k_1·abs(e_1)/N_u)^2
  t_2 = k_2/(1 + k_2·abs(e_2)/N_u)^2
  R_x = H_x - (N_1·c_1 + N_2·c_2)
  R_y = -P_y - (N_1·s_1 + N_2·s_2)
  T_C(k, 1) = 1000·u_x
  T_C(k, 2) = 1000·u_y
  T_C(k, 3) = N_1
  T_C(k, 4) = N_2
  T_C(k, 5) = sqrt(R_x^2 + R_y^2)
  a_11 = t_1·c_1^2 + t_2·c_2^2
  a_12 = t_1·c_1·s_1 + t_2·c_2·s_2
  a_22 = t_1·s_1^2 + t_2·s_2^2
  d_t = a_11·a_22 - a_12^2
  u_x = u_x + (a_22·R_x - a_12·R_y)/d_t
  u_y = u_y + (-a_12·R_x + a_11·R_y)/d_t
end
#show
#tabla("iteración:0","u_x [mm]:3","u_y [mm]:3","N_AC [kN]:2","N_BC [kN]:2","|R| [kN]:4")(i_t; T_C(1:8, 1); T_C(1:8, 2); T_C(1:8, 3); T_C(1:8, 4); T_C(1:8, 5))
v_x = 1000·u_x 'u_x final [mm]
v_y = 1000·u_y 'u_y final [mm]
#: Las fuerzas son negativas: las dos barras están en **compresión** (el nudo C baja). La barra AC llega a ≈ 70 % de su límite N_u: por eso el nudo baja mucho más que en el cálculo lineal.

## 4 · El residuo en 2D y en 3D
#: Para cada posición (u_x, u_y) del nudo C, |R| mide cuánto le falta al equilibrio. Newton busca el **fondo del pozo** (|R| = 0). Con f₁ y f₂ = la fuerza de cada barra (su curva), y u en mm (ejes: u_x horizontal, u_y vertical). Pasa el cursor:
f_1(x, y) = k_1·(c_1·x + s_1·y)/1000/(1 + k_1·sqrt((c_1·x + s_1·y)^2)/1000/N_u)
f_2(x, y) = k_2·(c_2·x + s_2·y)/1000/(1 + k_2·sqrt((c_2·x + s_2·y)^2)/1000/N_u)
R_n(x, y) = sqrt((H_x - f_1(x, y)·c_1 - f_2(x, y)·c_2)^2 + (-P_y - f_1(x, y)·s_1 - f_2(x, y)·s_2)^2)
#map(R_n(x, y), [-40 10], [-120 0])
#surf(R_n(x, y), [-40 10], [-120 0])

## 5 · Lo que esto tiene que ver con el talud
#: El talud de las hojas 190 y 194 hace EXACTAMENTE esto, solo que con 666 incógnitas en vez de 2: en cada punto de Gauss el suelo se ablanda (Drucker-Prager), K_T es la suma de las rigideces tangentes de los triángulos, se resuelve K_T·Δu = R y se repite hasta que el residuo baja de 0.01. Cuando al debilitar el suelo (c/F, tan φ/F) el residuo ya no baja, la curva se ha puesto horizontal (k_T → 0, como la barra en N_u): no hay equilibrio y el talud se cae. Ese F es el factor de seguridad.
