# Columna de suelo con sismo: masa, frecuencias y Newmark paso a paso contra Abaqus
#numerico

#: **Qué se calcula.** Una capa de arena de 12 m apoyada sobre roca. La roca se mueve con un pulso de aceleración y la arena lo sigue, pero no como un bloque rígido: la onda de cortante sube, se refleja en la superficie libre y vuelve a bajar. Por eso la capa **amplifica** el movimiento y tiene **su propio periodo**. Es el primer paso del análisis dinámico de un muro de contención: saber cómo se mueve el terreno solo, antes de poner el muro encima.
#: **Cómo.** Elementos finitos en el tiempo: (1) la masa M y la rigidez K de la columna; (2) sus frecuencias propias; (3) la ecuación del movimiento M·ü + K·u = −M·1·a_{g}(t), resuelta paso a paso con el método de Newmark.
#: **Unidades.** kN, m, t (tonelada = kN·s²/m) y s; los desplazamientos se enseñan en mm.
#: **Árbitro.** El mismo problema con 48 triángulos de seis nudos (T6) en deformación plana, calculado en Python (columna_ref.py), en Hekatan Geotechnic y en **Abaqus 2017** (elemento CPE6): los tres dan los mismos números a 4 decimales (29-sep-2026). Esta hoja **no** calcula ese modelo 2D: calcula la columna reducida a una barra (sección 2) y **compara** con él (sección 8).

## 1 · Datos
H = 12 [m] 'altura de la capa
A_s = 1 [m²] 'planta de la columna: 1 m de ancho por 1 m de fondo
E_s = 25000 [kPa] 'arena SP (estudio de suelos del muro de Manabí)
ν = 0.28 'coeficiente de Poisson
γ_s = 18.5 [kN/m³] 'peso específico
g = 9.80665 [m/s²]
#: La masa por volumen es el peso por volumen dividido por g; en kN, m y s sale en t/m³:
ρ = γ_s/g [t/m³]
#: En una capa horizontal que se mueve de lado el suelo trabaja **a cortante**. Manda el módulo de cortante G, no E:
G = E_s/(2·(1 + ν)) [kPa]
#: Velocidad de la onda de cortante: lo rápido que sube por la capa una perturbación de la base.
V_s = sqrt(G/ρ) [m/s]
#: **El sismo**: la base se acelera con medio seno de 0.2 s y de amplitud 1 m/s² (≈ 0.10·g); después queda quieta.
#: a_{g}(t) = a_{0}·sen(π·t / t_{p}) para 0 ≤ t ≤ t_{p};   a_{g}(t) = 0 después
a_0 = 1 [m/s²]
t_p = 0.2 [s]
#: Aceleración de la base en el tiempo (puntos de la misma fórmula, cada 0.01 s):
#fplot(a_g = [0.00 0.0000; 0.01 0.1564; 0.02 0.3090; 0.03 0.4540; 0.04 0.5878; 0.05 0.7071; 0.06 0.8090; 0.07 0.8910; 0.08 0.9511; 0.09 0.9877; 0.10 1.0000; 0.11 0.9877; 0.12 0.9511; 0.13 0.8910; 0.14 0.8090; 0.15 0.7071; 0.16 0.5878; 0.17 0.4540; 0.18 0.3090; 0.19 0.1564; 0.20 0.0000; 0.21 0.0000; 0.22 0.0000; 0.23 0.0000; 0.24 0.0000; 0.25 0.0000; 0.26 0.0000; 0.27 0.0000; 0.28 0.0000; 0.29 0.0000; 0.30 0.0000; 0.31 0.0000; 0.32 0.0000; 0.33 0.0000; 0.34 0.0000; 0.35 0.0000; 0.36 0.0000; 0.37 0.0000; 0.38 0.0000; 0.39 0.0000; 0.40 0.0000], [0 0.4])
#: Eje horizontal: t en s; eje vertical: a_{g} en m/s².

## 2 · La columna y su malla
#: **El modelo 2D (el del árbitro).** Columna de 1 m de ancho y 12 m de alto, partida en 24 cuadrados de 1.0 × 0.5 m, y cada cuadrado en dos T6 por la diagonal: 48 elementos y 147 nudos. **Contorno:** la base, fija; en los dos lados el desplazamiento vertical está impedido y el horizontal del lado derecho es **igual** al del lado izquierdo a la misma cota. Así la columna se comporta como una tajada de una capa de terreno muy ancha: cada cota se mueve de lado, toda entera, sin girar.
#: **Por qué se puede reducir a una barra.** Con esas condiciones el desplazamiento horizontal u solo depende de la altura y, no de x. Toda la rebanada de una cota se mueve igual, y la columna es una **barra a cortante**: la deformación es γ_{xy} = du/dy y la tensión τ = G·du/dy. Los lados del T6 tienen tres nudos (cada 0.25 m) con desplazamiento cuadrático; la barra se hace con elementos de **tres nudos** de 0.5 m, los mismos 49 niveles de nudos del modelo 2D.
#dibujo("Modelo 2D de T6 (izquierda) y la barra a cortante equivalente (derecha)", ud = m, ancho = 90, alto = 175)
#  rect(0, 0, 1, 12, "gruesa")
#  polilinea([0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0], [0, 0.5, 0.5, 1, 1, 1.5, 1.5, 2, 2, 2.5, 2.5, 3, 3, 3.5, 3.5, 4, 4, 4.5, 4.5, 5, 5, 5.5, 5.5, 6, 6, 6.5, 6.5, 7, 7, 7.5, 7.5, 8, 8, 8.5, 8.5, 9, 9, 9.5, 9.5, 10, 10, 10.5, 10.5, 11, 11, 11.5, 11.5, 12, 12], "fina")
#  circulo(0, [0, 0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75, 3, 3.25, 3.5, 3.75, 4, 4.25, 4.5, 4.75, 5, 5.25, 5.5, 5.75, 6, 6.25, 6.5, 6.75, 7, 7.25, 7.5, 7.75, 8, 8.25, 8.5, 8.75, 9, 9.25, 9.5, 9.75, 10, 10.25, 10.5, 10.75, 11, 11.25, 11.5, 11.75, 12], 0.05, "azul relleno")
#  circulo(0.5, [0, 0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75, 3, 3.25, 3.5, 3.75, 4, 4.25, 4.5, 4.75, 5, 5.25, 5.5, 5.75, 6, 6.25, 6.5, 6.75, 7, 7.25, 7.5, 7.75, 8, 8.25, 8.5, 8.75, 9, 9.25, 9.5, 9.75, 10, 10.25, 10.5, 10.75, 11, 11.25, 11.5, 11.75, 12], 0.05, "azul relleno")
#  circulo(1, [0, 0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75, 3, 3.25, 3.5, 3.75, 4, 4.25, 4.5, 4.75, 5, 5.25, 5.5, 5.75, 6, 6.25, 6.5, 6.75, 7, 7.25, 7.5, 7.75, 8, 8.25, 8.5, 8.75, 9, 9.25, 9.5, 9.75, 10, 10.25, 10.5, 10.75, 11, 11.25, 11.5, 11.75, 12], 0.05, "azul relleno")
#  empotramiento(-0.3, 0, 1.3, 0, 1)
#  texto(-0.25, 6, "v = 0", 2.4, "d")
#  texto(1.25, 6, "v = 0", 2.4, "i")
#  texto(0.5, 12.5, "u_{der} = u_{izq}", 2.4, "c", estilo = "azul")
#  linea(3.5, 0, 3.5, 12, "gruesa")
#  circulo(3.5, [0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8, 8.5, 9, 9.5, 10, 10.5, 11, 11.5, 12], 0.09, "rojo relleno")
#  circulo(3.5, [0.25, 0.75, 1.25, 1.75, 2.25, 2.75, 3.25, 3.75, 4.25, 4.75, 5.25, 5.75, 6.25, 6.75, 7.25, 7.75, 8.25, 8.75, 9.25, 9.75, 10.25, 10.75, 11.25, 11.75], 0.06, "fina")
#  empotramiento(2.9, 0, 4.1, 0, 1)
#  flecha(0.5, -1.3, 1.8, -1.3, "naranja")
#  flecha(1.8, -1.3, 0.5, -1.3, "naranja")
#  texto(2.1, -1.3, "a_{g}(t)", 2.6, "i", estilo = "naranja")
#  texto(3.8, 12, "coronación", 2.4, "i")
#  texto(3.8, 6, "24 elementos de 3 nudos", 2.4, "i")
#  texto(3.8, 5.3, "49 nudos, h = 0.50 m", 2.4, "i")
#  cota(-0.9, 0, -0.9, 12, 0, "H = 12.00")
#fin
#: En la barra, círculos rojos grandes: extremos de cada elemento; negros pequeños: nudos centrales. En el modelo 2D, los 147 nudos (azul) están en tres verticales, x = 0, 0.5 y 1 m, cada 0.25 m.
n_e = 24 'elementos
h = H/n_e [m] 'alto de cada elemento
n_n = 2·n_e + 1 'nudos de la barra, de la base (1) a la coronación (49)

## 3 · Rigidez y masa del elemento
#: Dentro del elemento, u(y) se interpola con tres funciones de forma de segundo grado, N₁, N₂ y N₃ (extremo de abajo, centro, extremo de arriba), las mismas del lado de un T6. La rigidez sale de la energía del cortante y la masa, de la energía cinética:
#: K_{e} = ∫ G·A·N′ᵀ·N′ dy   (y de 0 a h)
#: M_{e} = ∫ ρ·A·Nᵀ·N dy   (y de 0 a h)
#: Integradas a mano, en el orden de nudos (abajo, centro, arriba):
K_e = G·A_s/(3·h)·[7, -8, 1; -8, 16, -8; 1, -8, 7] [kN/m]
M_e = ρ·A_s·h/30·[4, 2, -1; 2, 16, 2; -1, 2, 4] [t]
#: **Masa consistente.** M_{e} sale de las mismas funciones de forma que K_{e}: es la matriz que usan Abaqus (CPE6), GEO5 y Geotechnic para elementos de segundo orden (comprobado con las matrices de elemento que escribe Abaqus). La **masa concentrada** pondría la masa solo en la diagonal, en los nudos; es más barata, pero con la misma malla da las frecuencias altas algo más bajas (en el modelo 2D, f₃ = 7.4923 Hz en vez de 7.4947).
#: **Ensamblaje.** El elemento e va a los nudos 2e − 1, 2e y 2e + 1; sus 3 × 3 se suman en K y M de 49 × 49:
#hide
K = zeros(n_n, n_n)
M = zeros(n_n, n_n)
for e = 1:n_e
  for i = 1:3
    for j = 1:3
      p = 2·e - 2 + i
      q = 2·e - 2 + j
      K(p, q) = K(p, q) + K_e(i, j)
      M(p, q) = M(p, q) + M_e(i, j)
    end
  end
end
u_1n = ones(n_n, 1)
#show
#: **Comprobación de la masa**: sumando todos los términos de M sale la masa de la columna entera, ρ·A·H:
m_t = dot(u_1n, M·u_1n) [t]
m_ex = ρ·A_s·H [t]
#: **Quitar la base.** El nudo 1 no se mueve respecto a la roca: se borran su fila y su columna. Quedan 48 incógnitas, K_{f} y M_{f}. La fila del nudo 1 no se pierde del todo: la fuerza del sismo sobre cada nudo libre es su **fila completa** de M por el vector de unos, r_{g} = M·1, que incluye el acoplamiento con la base (así lo hace Abaqus; con solo M_{f}·1 la curva se separa 2·10⁻⁵ mm).
#hide
n_f = n_n - 1
K_f = zeros(n_f, n_f)
M_f = zeros(n_f, n_f)
r_g = zeros(n_f, 1)
for i = 1:n_f
  for j = 1:n_f
    K_f(i, j) = K(i + 1, j + 1)
    M_f(i, j) = M(i + 1, j + 1)
  end
  for j = 1:n_n
    r_g(i) = r_g(i) + M(i + 1, j)
  end
end
#show
n_f

## 4 · Frecuencias propias
#: **Exactas.** Una capa uniforme de altura H sobre base rígida vibra con f_{n} = (2n − 1)·V_{s} / (4·H): el primer modo es un cuarto de onda en la altura de la capa.
f_e1 = V_s/(4·H) [Hz]
f_e2 = 3·V_s/(4·H) [Hz]
f_e3 = 5·V_s/(4·H) [Hz]
T_1 = 1/f_e1 [s] 'periodo fundamental de la capa
#: **Del modelo, sin calcular autovalores.** El modo cumple K·φ = ω²·M·φ. La **iteración inversa** repite x ← K⁻¹·M·x: en cada vuelta el modo 1 crece (ω₁²/ω₂²)⁻¹ = 9 veces más que el 2, y x se vuelve el modo 1. Con x normalizado a xᵀ·M·x = 1, el **cociente de Rayleigh** da la frecuencia: ω² = xᵀ·K·x, f = ω / (2π). Se arranca con x = 1 (toda la columna desplazada igual). Cada vuelta imprime f₁ en Hz:
#hide
K_i = inv(K_f)
x_1 = ones(n_f, 1)
#show
for k = 1:6
  y_k = K_i·(M_f·x_1)
  x_1 = y_k/sqrt(dot(y_k, M_f·y_k))
  f_k = sqrt(dot(x_1, K_f·x_1))/(2·pi)
  disp(f_k)
end
#: Converge muy rápido: el error del cociente de Rayleigh baja con el cuadrado del error del vector. Se sigue hasta 40 vueltas (oculto) y queda:
#hide
for k = 1:40
  y_k = K_i·(M_f·x_1)
  x_1 = y_k/sqrt(dot(y_k, M_f·y_k))
end
#show
f_1 = sqrt(dot(x_1, K_f·x_1))/(2·pi) [Hz]
#: **Modos 2 y 3.** La misma iteración converge siempre al modo 1. Para sacar el 2, en cada vuelta se le **quita al vector la parte del modo 1** (ortogonalidad respecto a M): y ← y − (x₁ᵀ·M·y)·x₁. Para el 3 se quitan las partes de los modos 1 y 2. El modo 3 converge más despacio (factor (ω₃/ω₄)² = 25/49 por vuelta); 80 vueltas bastan de sobra:
#hide
x_2 = ones(n_f, 1)
x_3 = ones(n_f, 1)
#show
for k = 1:80
  y_k = K_i·(M_f·x_2)
  y_k = y_k - dot(x_1, M_f·y_k)·x_1
  x_2 = y_k/sqrt(dot(y_k, M_f·y_k))
  y_k = K_i·(M_f·x_3)
  y_k = y_k - dot(x_1, M_f·y_k)·x_1
  y_k = y_k - dot(x_2, M_f·y_k)·x_2
  x_3 = y_k/sqrt(dot(y_k, M_f·y_k))
end
f_2 = sqrt(dot(x_2, K_f·x_2))/(2·pi) [Hz]
f_3 = sqrt(dot(x_3, K_f·x_3))/(2·pi) [Hz]
#: Las tres coinciden con las exactas a 4 decimales. **Con elementos de 2 nudos** (u lineal por tramo) hace falta mucha más malla para lo mismo; calculado aparte en Python con los mismos datos (no en esta hoja):
#| Elementos | Nudos | f₁ [Hz] | f₂ [Hz] | f₃ [Hz] |
#|---|---:|---:|---:|---:|
#| 12 de 2 nudos | 13 | 1.500007 | 4.525757 | 7.629068 |
#| 24 de 2 nudos | 25 | 1.499204 | 4.504037 | 7.528169 |
#| 48 de 2 nudos | 49 | 1.499003 | 4.498616 | 7.503046 |
#| 96 de 2 nudos | 97 | 1.498953 | 4.497261 | 7.496773 |
#| 6 de 3 nudos | 13 | 1.498941 | 4.497961 | 7.508728 |
#| 12 de 3 nudos | 25 | 1.498937 | 4.496883 | 7.495617 |
#| **24 de 3 nudos (esta hoja)** | 49 | 1.498937 | 4.496814 | 7.494742 |
#| exacta | — | 1.498937 | 4.496810 | 7.494683 |
#: Con los mismos 49 nudos, el elemento de 3 nudos da f₃ con error de 0.001 % y el de 2 nudos, de 0.11 %.

## 5 · Newmark: la ecuación de cada paso
#: **Ecuación del movimiento** con u medido respecto a la base (desplazamiento relativo). Sin amortiguamiento:
#: M·ü + K·u = −r_{g}·a_{g}(t)
#: **Aceleración media constante** (Newmark con β = 1/4, γ = 1/2): dentro de cada paso Δt la aceleración se toma como la media de la del principio y la del final. Es **incondicionalmente estable** (no explota con ningún Δt) y no quita energía: la amplitud no se amortigua sola.
β = 0.25
γ = 0.5
Δt = 0.005 [s] 'unas 130 veces menor que el periodo T₁ y 40 pasos por pulso
n_p = 400 'pasos: 2 s
#: **Coeficientes** (los de GEO5, leídos de su programa FRGeoFEM, y los del libro de Bathe, ec. 9.27–9.31):
b_1 = 1/(β·Δt^2) 'en 1/s²
b_2 = 1/(β·Δt) 'en 1/s
b_3 = 1/(2·β) - 1
b_4 = γ/(β·Δt) 'en 1/s
b_5 = γ/β - 1
b_6 = Δt/2·(γ/β - 2) [s]
#: b₄, b₅ y b₆ solo multiplican al amortiguamiento C, que aquí es cero.
#: **Un paso**, de t_{n} a t_{n+1} = t_{n} + Δt. Se despeja u_{n+1} de la ecuación del movimiento escrita al final del paso:
#: K_{ef}·u_{n+1} = −r_{g}·a_{g}(t_{n+1}) + M·(b₁·u_{n} + b₂·v_{n} + b₃·a_{n}),   con K_{ef} = K + b₁·M
#: a_{n+1} = b₁·(u_{n+1} − u_{n}) − b₂·v_{n} − b₃·a_{n}
#: v_{n+1} = v_{n} + Δt·((1 − γ)·a_{n} + γ·a_{n+1})
#: K_{ef} no cambia de un paso a otro (Δt fijo y material elástico): se **invierte una sola vez** fuera del bucle, y cada paso es solo una multiplicación matriz por vector.
#hide
K_ef = K_f + b_1·M_f
K_ei = inv(K_ef)
#show
#: **El bucle.** Arranca en reposo (u = v = a = 0; a_{g}(0) = 0). Guarda el desplazamiento de la coronación (último nudo) en cada paso, en mm, y se queda con el mayor en valor absoluto, su instante y el perfil de toda la columna en ese instante. (Los bucles de la hoja salen plegados: un clic en la línea «for» enseña su código, que es el de las tres ecuaciones de arriba).
#hide
u_n = zeros(n_f, 1)
v_n = zeros(n_f, 1)
a_n = zeros(n_f, 1)
u_c = zeros(n_p + 1, 1)
u_p = zeros(n_f, 1)
u_m = 0
s_m = 0
#show
for s = 1:n_p
  t = s·Δt
  a_g = 0
  if t < t_p - 0.000001
    a_g = a_0·sin(pi·t/t_p)
  end
  R_n = -r_g·a_g + M_f·(b_1·u_n + b_2·v_n + b_3·a_n)
  u_s = K_ei·R_n
  a_s = b_1·(u_s - u_n) - b_2·v_n - b_3·a_n
  v_n = v_n + Δt·((1 - γ)·a_n + γ·a_s)
  u_n = u_s
  a_n = a_s
  u_c(s + 1) = 1000·u_n(n_f)
  if abs(u_c(s + 1)) > abs(u_m)
    u_m = u_c(s + 1)
    s_m = s
    u_p = u_n
  end
end

## 6 · Resultado: la coronación en el tiempo
#: **Desplazamiento máximo de la coronación** respecto a la base y su instante:
u_max = u_m [mm]
t_max = s_m·Δt [s]
#: Desplazamiento de la coronación u_{c}(t) en mm (eje horizontal: t en s). La curva se dibuja con los números de la referencia en Python del mismo modelo de barra, uno cada 0.02 s, porque las gráficas del motor todavía no leen vectores calculados en la hoja. La tabla de abajo comprueba que coinciden con los que calcula esta hoja:
#fplot(u_c = [0.00 0.000; 0.02, -0.021; 0.04, -0.165; 0.06, -0.542; 0.08, -1.240; 0.10, -2.314; 0.12, -3.785; 0.14, -5.633; 0.16, -7.800; 0.18, -10.178; 0.20, -12.526; 0.22, -14.499; 0.24, -15.886; 0.26, -16.549; 0.28, -16.425; 0.30, -15.524; 0.32, -13.936; 0.34, -11.816; 0.36, -9.370; 0.38, -6.816; 0.40, -4.273; 0.42, -1.726; 0.44 0.818; 0.46 3.363; 0.48 5.908; 0.50 8.443; 0.52 10.924; 0.54 13.194; 0.56 15.005; 0.58 16.175; 0.60 16.596; 0.62 16.224; 0.64 15.095; 0.66 13.321; 0.68 11.074; 0.70 8.566; 0.72 5.995; 0.74 3.453; 0.76 0.910; 0.78, -1.637; 0.80, -4.181; 0.82, -6.722; 0.84, -9.241; 0.86, -11.665; 0.88, -13.818; 0.90, -15.449; 0.92, -16.389; 0.94, -16.566; 0.96, -15.947; 0.98, -14.603; 1.00, -12.659; 1.02, -10.305; 1.04, -7.750; 1.06, -5.173; 1.08, -2.633; 1.10, -0.094; 1.12 2.457; 1.14 4.997; 1.16 7.533; 1.18 10.024; 1.20 12.377; 1.22 14.390; 1.24 15.826; 1.26 16.528; 1.28 16.455; 1.30 15.601; 1.32 14.050; 1.34 11.956; 1.36 9.512; 1.38 6.928; 1.40 4.349; 1.42 1.815; 1.44, -0.723; 1.46, -3.275; 1.48, -5.812; 1.50, -8.334; 1.52, -10.788; 1.54, -13.049; 1.56, -14.909; 1.58, -16.131; 1.60, -16.590; 1.62, -16.268; 1.64, -15.186; 1.66, -13.443; 1.68, -11.217; 1.70, -8.702; 1.72, -6.099; 1.74, -3.526; 1.76, -0.998; 1.78 1.540; 1.80 4.092; 1.82 6.625; 1.84 9.123; 1.86 11.529; 1.88 13.680; 1.90 15.366; 1.92 16.363; 1.94 16.573; 1.96 16.006; 1.98 14.707; 2.00 12.787], [0 2.4])
#hide
u_02 = u_c(41)
u_04 = u_c(81)
u_06 = u_c(121)
u_10 = u_c(201)
u_15 = u_c(301)
u_20 = u_c(401)
#show
#| t [s] | u_{c} de esta hoja [mm] | u_{c} dibujado [mm] |
#|---:|---:|---:|
#| 0.20 | @{u_02} | −12.526 |
#| 0.40 | @{u_04} | −4.273 |
#| 0.60 | @{u_06} | 16.596 |
#| 1.00 | @{u_10} | −12.659 |
#| 1.50 | @{u_15} | −8.334 |
#| 2.00 | @{u_20} | 12.787 |
#: **Lectura.** Mientras dura el pulso (0 a 0.2 s) la base empuja y la columna se queda atrás: la coronación va hacia el lado contrario (valores negativos). Acabado el pulso, la capa sigue vibrando sola en su **modo 1**: los picos se repiten cada T₁ = 0.667 s (0.27, 0.60, 0.94, 1.27, 1.60, 1.94 s), alternando de signo cada medio periodo. Sin amortiguamiento la amplitud no baja: los seis picos están entre 16.59 y 16.60 mm, y el mayor cae en t = @{t_max} s por una diferencia de 0.0002 mm con el de 0.935 s.
#: **Por qué la capa amplifica.** Si el terreno fuera rígido, se movería con la base y el desplazamiento relativo sería cero. La onda tarda H / V_{s} = 0.17 s en subir; el pulso dura 0.2 s, del orden de ese tiempo, así que la capa no puede seguirlo y queda vibrando.

## 7 · Perfil en altura en el instante del máximo
#hide
u_y2 = 1000·u_p(8)
u_y4 = 1000·u_p(16)
u_y6 = 1000·u_p(24)
u_y8 = 1000·u_p(32)
u_y10 = 1000·u_p(40)
u_y12 = 1000·u_p(48)
#show
#: Desplazamiento de cada cota en t = @{t_max} s, calculado por esta hoja (en mm):
#| y [m] | 0 | 2 | 4 | 6 | 8 | 10 | 12 |
#|---|---:|---:|---:|---:|---:|---:|---:|
#| u [mm] | 0 | @{u_y2} | @{u_y4} | @{u_y6} | @{u_y8} | @{u_y10} | @{u_y12} |
#dibujo("Perfil de desplazamiento en t = 0.600 s (escala horizontal: 1 mm = 0.25 m)", ud = m, ancho = 100, alto = 150)
#  linea(0, 0, 0, 12, "trazos gris")
#  empotramiento(-0.8, 0, 0.8, 0, 1)
#  polilinea([0.0000, 0.1105, 0.2210, 0.3315, 0.4423, 0.5528, 0.6635, 0.7740, 0.8845, 0.9948, 1.1050, 1.2155, 1.3260, 1.4365, 1.5473, 1.6580, 1.7688, 1.8795, 1.9905, 2.1010, 2.2113, 2.3213, 2.4303, 2.5385, 2.6455, 2.7510, 2.8550, 2.9568, 3.0563, 3.1530, 3.2468, 3.3375, 3.4243, 3.5073, 3.5860, 3.6603, 3.7300, 3.7948, 3.8545, 3.9093, 3.9588, 4.0028, 4.0413, 4.0740, 4.1008, 4.1220, 4.1370, 4.1460, 4.1490], [0, 0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75, 3, 3.25, 3.5, 3.75, 4, 4.25, 4.5, 4.75, 5, 5.25, 5.5, 5.75, 6, 6.25, 6.5, 6.75, 7, 7.25, 7.5, 7.75, 8, 8.25, 8.5, 8.75, 9, 9.25, 9.5, 9.75, 10, 10.25, 10.5, 10.75, 11, 11.25, 11.5, 11.75, 12], "gruesa rojo")
#  flecha(0, 12, 4.149, 12, "rojo")
#  flecha(0, 6, 2.6455, 6, "rojo")
#  texto(4.3, 12, "16.60 mm", 2.4, "i", estilo = "rojo")
#  texto(2.8, 6, "10.58 mm", 2.4, "i", estilo = "rojo")
#  texto(-0.15, 11.5, "y", 2.6, "d")
#fin
#: La curva roja se dibuja con los desplazamientos de la referencia en Python (los de la tabla, a 3 decimales). Es casi una recta abajo y se curva arriba: la onda que viaja por la capa, retratada en ese instante. Arriba la curva llega vertical porque en la superficie libre la tensión de cortante es cero (τ = G·du/dy = 0).

## 8 · Comparación
#hide
d_m = round(100·(m_t/22.6376999 - 1), 6)
d_1 = round(100·(f_1/1.4989365979 - 1), 6)
d_2 = round(100·(f_2/4.4968143672 - 1), 6)
d_3 = round(100·(f_3/7.4947422039 - 1), 6)
d_u = round(100·(u_max/16.5962895 - 1), 6)
e_1 = round(100·(f_1/f_e1 - 1), 6)
e_2 = round(100·(f_2/f_e2 - 1), 6)
e_3 = round(100·(f_3/f_e3 - 1), 6)
#show
#: Columna «EF 2D»: 48 T6, 147 nudos; **Python = Hekatan Geotechnic = Abaqus 2017 (CPE6)** a 4 decimales (entre Geotechnic y Abaqus, a lo sumo 2·10⁻⁷). Esos números **se citan**, no se calculan en esta hoja.
#| Magnitud | Esta hoja (barra, 49 nudos) | EF 2D (Python = Geotechnic = Abaqus) | Diferencia con EF 2D [%] | Exacta | Diferencia con la exacta [%] |
#|---|---:|---:|---:|---:|---:|
#| Masa total [t] | @{m_t} | 22.6377 | @{d_m} | ρ·A·H = 22.6377 | — |
#| f₁ [Hz] | @{f_1} | 1.498937 | @{d_1} | 1.498937 | @{e_1} |
#| f₂ [Hz] | @{f_2} | 4.496814 | @{d_2} | 4.496810 | @{e_2} |
#| f₃ [Hz] | @{f_3} | 7.494742 | @{d_3} | 7.494683 | @{e_3} |
#| u máx. coronación [mm] | @{u_max} | 16.596289 | @{d_u} | — | — |
#| instante del máximo [s] | @{t_max} | 0.600 | — | — | — |
#: **Lectura honrada.** La barra de 24 elementos de 3 nudos da **los mismos números que el modelo 2D** (masa, tres frecuencias y máximo, a 4 decimales; en la curva completa la diferencia máxima con Python 2D es de 3·10⁻⁵ mm). No es casualidad: con los lados atados y el vertical impedido, el T6 solo trabaja a cortante y su lado es la barra de 3 nudos. Frente a la solución exacta, las frecuencias difieren menos de 0.001 %; es error de la malla, que se ve algo más en el modo 3.

## 9 · Conclusión y lo que falta
#: Una capa de 12 m de arena SP (V_{s} = 72 m/s) tiene un periodo propio de 0.667 s. Un pulso de 0.2 s y 0.1·g en la roca la deja vibrando con **16.6 mm** de desplazamiento relativo en la coronación. Con K, M y un bucle de Newmark de cinco líneas, esta hoja reproduce el mismo resultado que Abaqus y Hekatan Geotechnic.
#: **Lo que falta** (los siguientes pasos del análisis dinámico):
#: • **Amortiguamiento** (Rayleigh, C = α·M + β·K, con ξ ≈ 5 %): sin él la vibración no se apaga nunca, y un suelo real sí disipa energía.
#: • **Borde absorbente en la base**: aquí la roca es rígida y la onda que baja rebota entera. Una roca real deja pasar parte de la energía hacia abajo.
#: • **Suelo no lineal**: G baja y el amortiguamiento sube con la deformación de cortante; con sismos fuertes la respuesta cambia mucho.
#: • **El muro encima**: el siguiente modelo es el muro de Manabí sobre esta capa, en 2D, con su propia masa y la interacción suelo-estructura.
