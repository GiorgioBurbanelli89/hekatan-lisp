# Newton-Raphson con varias incógnitas, paso a paso: cómo se calcula a mano y en Hekatan Math Studio la cercha de 2 barras con K_T·Δ u = R
#numerico

## 1 · El objeto: una cercha de dos barras que se ablandan
#: **La idea en una frase:** con UNA incógnita, Newton es una **división** repetida (Δ d = R/k_T, hojas 196 y 198). Con VARIAS incógnitas es lo mismo, pero la división se vuelve un **sistema lineal** repetido: **K_T·Δ u = R**. Esta hoja lo hace con la cercha más chica que tiene dos incógnitas, vuelta por vuelta, sin saltarse nada.
#dibujo("La cercha: apoyos A y B, nudo C cargado; las incógnitas son u₁ y u₂, el movimiento de C", ud = m, escala = auto, cotas = m, alto = 85)
#  poligono(0, 0, -0.35, -0.5, 0.35, -0.5, 0, 0, "gruesa")
#  poligono(4, 0, 3.65, -0.5, 4.35, -0.5, 4, 0, "gruesa")
#  linea(0, 0, 1, 3, "gruesa")
#  linea(4, 0, 1, 3, "gruesa")
#  flecha(1, 4.4, 1, 3.05, "gruesa rojo")
#  flecha(-0.6, 3, 0.95, 3, "rojo")
#  flecha(1, 3, 2.1, 3, "media azul")
#  flecha(1.3, 3, 1.3, 4.1, "media azul")
#  texto(2.35, 3.25, "u₁", 2.6, "c")
#  texto(1.6, 3.9, "u₂", 2.6, "c")
#  texto(0.2, 4.3, "P = 300 kN", 2.4, "c")
#  texto(-1.2, 3.4, "H = 30 kN", 2.4, "c")
#  texto(0, -0.9, "A", 2.4, "c")
#  texto(4, -0.9, "B", 2.4, "c")
#  texto(0.65, 3.35, "C", 2.4, "c")
#  texto(0.1, 1.6, "AC", 2.2, "c")
#  texto(2.9, 1.6, "BC", 2.2, "c")
#  cota(0, -1.3, 4, -1.3, 0, "4 m")
#  cota(4.7, 0, 4.7, 3, 0, "3 m")
#fin
#: Las dos barras tienen la misma rigidez axial EA = 60 000 kN y **se ablandan**: no pasan de N_u = 300 kN (la ley de la hoja 198). El nudo C se mueve **u = (u₁, u₂)**: u₁ horizontal (+ a la derecha) y u₂ vertical (+ hacia arriba). Son **dos incógnitas**, y el equilibrio de C son **dos ecuaciones**: la suma de fuerzas en x y en y.
#: **Equilibrio:** las cargas F = (H, −P) tienen que ser iguales a lo que empujan las barras sobre C, las **fuerzas internas f_int(u)**. Lo que falta se llama **residuo**: **R(u) = F − f_int(u) = 0**. Si las barras fueran lineales, f_int = K·u y bastaría resolver K·u = F una vez. Como se ablandan, f_int(u) es una curva y hay que dar vueltas.

## 2 · Primero con símbolos: de dónde sale cada fórmula
### 2.1 · Cuánto se alarga una barra
#: Una barra va de su apoyo a C; sus proyecciones son x y y, su largo L = √(x² + y²). Si C se mueve (u₁, u₂), el **largo deformado** es:
L_d = Simplify{sqrt((x + u_1)^2 + (y + u_2)^2)}
#: ¿Cuánto cambia L′ si C se mueve un poco a la derecha (u₁) o hacia arriba (u₂)? Su derivada:
e_x = Simplify{Diff{sqrt((x + u_1)^2 + (y + u_2)^2) @ u_1}}
e_y = Simplify{Diff{sqrt((x + u_1)^2 + (y + u_2)^2) @ u_2}}
#: En u = 0 valen **x/L = c** y **y/L = s**: el coseno y el seno de la barra. El primer término de Taylor da el alargamiento **δ = L′ − L ≈ c·u₁ + s·u₂** (hipótesis de **desplazamientos pequeños**; en la sección 5 se grafica cuánto se equivoca: menos de 1 %).
### 2.2 · La fuerza de una barra que se ablanda
#: La ley de la barra es N = k·δ/(1 + k·|δ|/N_u), con k = EA/L (hoja 198: empieza como la recta k·δ y no pasa de N_u). Aquí las dos barras se **acortan** (δ < 0), así que |δ| = −δ:
N_s = Simplify{k*delta/(1 - k*delta/N_u)}
#: Su **rigidez tangente** (la pendiente de la curva, lo que usa Newton) es la derivada:
k_b = Simplify{Diff{k*delta/(1 - k*delta/N_u) @ delta}}
#: Es lo mismo que **t = k/(1 − k·δ/N_u)²**: con δ = 0 vale k (lineal) y baja cuando la barra se acorta.
### 2.3 · Las fuerzas internas en C
#: Cada barra empuja a C con su fuerza N en su dirección (c, s). Con δ = c·u₁ + s·u₂ dentro de N:
f_b = Simplify{k*(c*u_1 + s*u_2)/(1 - k*(c*u_1 + s*u_2)/N_u)*[c; s]}
#: y **f_int(u) = f_AC + f_BC** (la suma de las dos barras).
### 2.4 · La matriz tangente K_T = ∂f_int/∂u (el motor deriva)
#: Con una incógnita, Newton usaba la pendiente k_T. Con dos, la «pendiente» es una **matriz 2×2**: cuánto cambia cada fuerza interna si se mueve cada incógnita. Derivando la fuerza de una barra:
g_11 = Simplify{Diff{k*(c*u_1 + s*u_2)/(1 - k*(c*u_1 + s*u_2)/N_u)*c @ u_1}}
g_12 = Simplify{Diff{k*(c*u_1 + s*u_2)/(1 - k*(c*u_1 + s*u_2)/N_u)*c @ u_2}}
g_22 = Simplify{Diff{k*(c*u_1 + s*u_2)/(1 - k*(c*u_1 + s*u_2)/N_u)*s @ u_2}}
#: Las tres tienen el mismo factor: k·N_u²/(…)² = **t**, la rigidez tangente de la barra (2.2). Queda la matriz de una barra inclinada, y la de la cercha es la suma de las dos barras:
K_e = Simplify{t*[c^2, c*s; c*s, s^2]}
#: **K_T = K_AC + K_BC**, cada una con su t, c y s (regla de la cadena: ∂N/∂u = t·∂δ/∂u = t·[c, s]).
### 2.5 · El paso de Newton: resolver K_T·Δ u = R
#: Con una incógnita: Δ d = R/k_T. Con dos: **Δ u = K_T⁻¹·R**. La inversa de una matriz 2×2 simétrica [a b; b e]:
K_i = Simplify{inv([a, b; b, e])}
#: (se cambian a y e de lugar, se cambia el signo de b y se divide por el determinante a·e − b²). Multiplicada por el residuo R = (R₁, R₂):
D_u = Simplify{inv([a, b; b, e])*[R_1; R_2]}
### 2.6 · El algoritmo
#: **1.** u₀ = (0, 0).
#: **2.** R = F − f_int(u)  (lo que falta para el equilibrio).
#: **3.** ¿|R| < tolerancia? → **terminar**.
#: **4.** K_T = ∂f_int/∂u en ese u (la rigidez de ESE momento).
#: **5.** resolver K_T·Δ u = R.
#: **6.** u ← u + Δ u, y volver al paso 2.
#: Es la recta tangente de la hoja 198 (y = m·x + b), pero en 2D: un **plano tangente** por cada ecuación.

## 3 · Ahora con números
E_A = 60000 'rigidez axial EA [kN]
N_u = 300 'fuerza máxima de cada barra [kN]
P_y = 300 'carga vertical, hacia abajo [kN]
H_x = 30 'carga horizontal [kN]
L_1 = sqrt(1^2 + 3^2) 'largo de AC [m]
L_2 = sqrt(3^2 + 3^2) 'largo de BC [m]
c_1 = 1/L_1 'AC: coseno [-]
s_1 = 3/L_1 'AC: seno [-]
c_2 = -3/L_2 'BC: coseno [-]
s_2 = 3/L_2 'BC: seno [-]
k_1 = E_A/L_1/1000 'k = EA/L de AC [kN/mm]
k_2 = E_A/L_2/1000 'k = EA/L de BC [kN/mm]
#: (u en **mm**, fuerzas en kN, rigideces en kN/mm.) Las fórmulas de la sección 2, como funciones de u = (x, y):
d_a(x, y) = c_1*x + s_1*y 'alargamiento de AC [mm]
d_b(x, y) = c_2*x + s_2*y 'alargamiento de BC [mm]
N_a(x, y) = k_1*d_a(x, y)/(1 + k_1*abs(d_a(x, y))/N_u) 'fuerza en AC [kN]
N_b(x, y) = k_2*d_b(x, y)/(1 + k_2*abs(d_b(x, y))/N_u) 'fuerza en BC [kN]
t_a(x, y) = k_1/(1 + k_1*abs(d_a(x, y))/N_u)^2 'rigidez tangente de AC [kN/mm]
t_b(x, y) = k_2/(1 + k_2*abs(d_b(x, y))/N_u)^2 'rigidez tangente de BC [kN/mm]
f_i(x, y) = [N_a(x, y)*c_1 + N_b(x, y)*c_2; N_a(x, y)*s_1 + N_b(x, y)*s_2] 'fuerzas internas f_int [kN]
K_T(x, y) = [t_a(x, y)*c_1^2 + t_b(x, y)*c_2^2, t_a(x, y)*c_1*s_1 + t_b(x, y)*c_2*s_2; t_a(x, y)*c_1*s_1 + t_b(x, y)*c_2*s_2, t_a(x, y)*s_1^2 + t_b(x, y)*s_2^2] 'matriz tangente [kN/mm]
F_v = [H_x; -P_y] 'cargas en C [kN]
#: **Primero lo LINEAL** (un solo paso con la K inicial, la de u = 0):
K_0 = K_T(0, 0) 'K lineal [kN/mm]
u_L = lsolve(K_0, F_v) 'u lineal [mm]
#: El cálculo lineal dice que C baja 12.3 mm. Ahora Newton, que sigue a las barras mientras se ablandan.

## 4 · Las vueltas de Newton, una por una
#: Cada vuelta repite los pasos 2 a 6 del algoritmo. Se escriben una debajo de otra (desplegadas): así se ve cada número.
v_0 = [0; 0] 'u₀: punto de partida [mm]
#: **Vuelta 1** (desde u₀ = 0): las barras aún no trabajan, f_int = 0, así que R = F completo; K_T es la K lineal, y el primer paso da justo la respuesta lineal.
r_0 = F_v - f_i(v_0(1), v_0(2)) 'R = F − f_int(u) [kN]
n_0 = sqrt(r_0(1)^2 + r_0(2)^2) '|R| [kN]
T_0 = K_T(v_0(1), v_0(2)) 'K_T en ese u [kN/mm]
w_0 = lsolve(T_0, r_0) 'Δu: se resuelve K_T·Δu = R [mm]
v_1 = v_0 + w_0 'u nuevo = u + Δu [mm]
#: **Vuelta 2:** con u₁ las barras ya se ablandaron: K_T es más chica (mira K_T₁₁ y K_T₂₂), y el nuevo paso baja más.
r_1 = F_v - f_i(v_1(1), v_1(2)) 'R = F − f_int(u) [kN]
n_1 = sqrt(r_1(1)^2 + r_1(2)^2) '|R| [kN]
T_1 = K_T(v_1(1), v_1(2)) 'K_T en ese u [kN/mm]
w_1 = lsolve(T_1, r_1) 'Δu: se resuelve K_T·Δu = R [mm]
v_2 = v_1 + w_1 'u nuevo = u + Δu [mm]
#: **Vuelta 3:**
r_2 = F_v - f_i(v_2(1), v_2(2)) 'R = F − f_int(u) [kN]
n_2 = sqrt(r_2(1)^2 + r_2(2)^2) '|R| [kN]
T_2 = K_T(v_2(1), v_2(2)) 'K_T en ese u [kN/mm]
w_2 = lsolve(T_2, r_2) 'Δu: se resuelve K_T·Δu = R [mm]
v_3 = v_2 + w_2 'u nuevo = u + Δu [mm]
#: **Vuelta 4:**
r_3 = F_v - f_i(v_3(1), v_3(2)) 'R = F − f_int(u) [kN]
n_3 = sqrt(r_3(1)^2 + r_3(2)^2) '|R| [kN]
T_3 = K_T(v_3(1), v_3(2)) 'K_T en ese u [kN/mm]
w_3 = lsolve(T_3, r_3) 'Δu: se resuelve K_T·Δu = R [mm]
v_4 = v_3 + w_3 'u nuevo = u + Δu [mm]
#: **Vuelta 5:** el residuo ya es menos de 1 kN.
r_4 = F_v - f_i(v_4(1), v_4(2)) 'R = F − f_int(u) [kN]
n_4 = sqrt(r_4(1)^2 + r_4(2)^2) '|R| [kN]
T_4 = K_T(v_4(1), v_4(2)) 'K_T en ese u [kN/mm]
w_4 = lsolve(T_4, r_4) 'Δu: se resuelve K_T·Δu = R [mm]
v_5 = v_4 + w_4 'u nuevo = u + Δu [mm]
#: **Vuelta 6:** R ≈ 0.0016 kN.
r_5 = F_v - f_i(v_5(1), v_5(2)) 'R = F − f_int(u) [kN]
n_5 = sqrt(r_5(1)^2 + r_5(2)^2) '|R| [kN]
T_5 = K_T(v_5(1), v_5(2)) 'K_T en ese u [kN/mm]
w_5 = lsolve(T_5, r_5) 'Δu: se resuelve K_T·Δu = R [mm]
v_6 = v_5 + w_5 'u nuevo = u + Δu [mm]
#: **Vuelta 7:** R ≈ 3·10⁻⁸ kN: después de esta vuelta, |R| < 10⁻⁹ kN.
r_6 = F_v - f_i(v_6(1), v_6(2)) 'R = F − f_int(u) [kN]
n_6 = sqrt(r_6(1)^2 + r_6(2)^2) '|R| [kN]
T_6 = K_T(v_6(1), v_6(2)) 'K_T en ese u [kN/mm]
w_6 = lsolve(T_6, r_6) 'Δu: se resuelve K_T·Δu = R [mm]
v_7 = v_6 + w_6 'u nuevo = u + Δu [mm]
r_7 = F_v - f_i(v_7(1), v_7(2)) 'residuo final [kN]
n_7 = sqrt(r_7(1)^2 + r_7(2)^2) '|R| final [kN]
N_1 = N_a(v_7(1), v_7(2)) 'fuerza final en AC [kN]
N_2 = N_b(v_7(1), v_7(2)) 'fuerza final en BC [kN]
#: **Resultado:** C se mueve **u₁ = −11.6921 mm y u₂ = −37.2085 mm** (3 veces lo lineal). Las dos barras están en compresión; AC llega al 71 % de N_u. Las vueltas en una tabla (u en mm, |R| en kN):
i_t = [0; 1; 2; 3; 4; 5; 6; 7] 'vuelta [-]
p_x = [v_0(1); v_1(1); v_2(1); v_3(1); v_4(1); v_5(1); v_6(1); v_7(1)] 'u₁ de cada vuelta [mm]
p_y = [v_0(2); v_1(2); v_2(2); v_3(2); v_4(2); v_5(2); v_6(2); v_7(2)] 'u₂ de cada vuelta [mm]
p_r = [n_0; n_1; n_2; n_3; n_4; n_5; n_6; n_7] '|R| de cada vuelta [kN]
#tabla("vuelta:0","u₁ [mm]:4","u₂ [mm]:4","|R| [kN]:4")(i_t; p_x; p_y; p_r)
#: **Convergencia cuadrática:** el residuo baja 301 → 115 → 34 → 6.2 → 0.38 → 0.0016 → 3·10⁻⁸: al final, cada vuelta **duplica las cifras correctas** (el exponente se duplica: 10⁻³ → 10⁻⁸ → 10⁻¹⁴).
l_r = [log10(n_0); log10(n_1); log10(n_2); log10(n_3); log10(n_4); log10(n_5); log10(n_6); log10(n_7)] 'log₁₀|R| [-]
C_v = [0, log10(n_0); 1, log10(n_1); 2, log10(n_2); 3, log10(n_3); 4, log10(n_4); 5, log10(n_5); 6, log10(n_6); 7, log10(n_7)] 'puntos (vuelta, log₁₀|R|)
#fplot(Newton = C_v, [0 7])
#: (eje horizontal: la vuelta; vertical: log₁₀|R|. La curva cae cada vez más empinada.)

## 5 · Gráficas: el mapa del residuo y el camino de Newton
#: Para cada posición (u₁, u₂) de C, |R| mide cuánto le falta al equilibrio. La solución es el **fondo del pozo** (|R| = 0). Primero en 3D (arrastra para girar; x = u₁, y = u₂ en mm):
R_n(x, y) = sqrt((H_x - N_a(x, y)*c_1 - N_b(x, y)*c_2)^2 + (-P_y - N_a(x, y)*s_1 - N_b(x, y)*s_2)^2) '|R(u)| [kN]
#surf(R_n(x, y), [-30 10], [-60 5])
#: Y en planta (curvas de nivel; pasa el cursor):
#map(R_n(x, y), [-30 10], [-60 5])
#: **El camino de Newton** sobre esa planta: cada flecha es un paso Δ u = K_T⁻¹·R; de 0 baja a la respuesta lineal, luego se tuerce hacia el fondo del pozo y llega en 4–5 pasos (pasa el cursor por los puntos):
q_x = (p_x + 30)/3.5 'posición en el dibujo [-]
q_y = (p_y + 60)/5 'posición en el dibujo [-]
#dibujo("El camino de Newton en el plano u₁–u₂ (mm): de u₀ = 0 al fondo del pozo", ud = m, escala = auto, alto = 130)
#  flecha(0, 12.000, 12, 12.000, "fina")
#  flecha(8.571, 0, 8.571, 13.4, "fina")
#  texto(12, 12.450, "u₁ [mm]", 2.2, "c")
#  texto(8.771, 13.6, "u₂ [mm]", 2.2, "i")
#  texto(0.000, 11.550, "-30", 2.0, "c")
#  texto(2.857, 11.550, "-20", 2.0, "c")
#  texto(5.714, 11.550, "-10", 2.0, "c")
#  texto(11.429, 11.550, "10", 2.0, "c")
#  texto(9.171, 0.000, "-60", 2.0, "c")
#  texto(9.171, 4.000, "-40", 2.0, "c")
#  texto(9.171, 8.000, "-20", 2.0, "c")
#  linea(8.571, 12.000, 8.985, 9.532, "trazos azul")
#  flecha(8.571, 12.000, 8.985, 9.532, "media rojo")
#  flecha(8.985, 9.532, 7.873, 6.903, "media rojo")
#  flecha(7.873, 6.903, 6.020, 5.133, "media rojo")
#  flecha(6.020, 5.133, 5.284, 4.596, "media rojo")
#  flecha(5.284, 4.596, 5.231, 4.558, "media rojo")
#  flecha(5.231, 4.558, 5.231, 4.558, "media rojo")
#  circulo(8.571, 12.000, 0.09, "rojo relleno")
#  texto(9.121, 12.100, "u₀", 2.2, "c")
#  circulo(8.985, 9.532, 0.09, "rojo relleno")
#  texto(9.535, 9.632, "u₁", 2.2, "c")
#  circulo(7.873, 6.903, 0.09, "rojo relleno")
#  texto(8.423, 7.003, "u₂", 2.2, "c")
#  circulo(6.020, 5.133, 0.09, "rojo relleno")
#  texto(6.570, 5.233, "u₃", 2.2, "c")
#  circulo(5.284, 4.596, 0.09, "rojo relleno")
#  texto(5.834, 4.696, "u₄", 2.2, "c")
#  circulo(5.231, 4.558, 0.14, "verde relleno")
#  texto(4.931, 3.958, "solución (−11.69, −37.21)", 2.2, "c")
#  texto(9.685, 9.232, "lineal", 2.2, "c")
#  hover(q_x, q_y, "vuelta: u₁ = {#1:4} mm, u₂ = {#2:4} mm, |R| = {#3:4} kN", p_x, p_y, p_r)
#fin
### 5.1 · La hipótesis de desplazamientos pequeños
#: En 2.1 se cambió el alargamiento exacto L′ − L por c·u₁ + s·u₂. ¿Cuánto se equivoca? Para la barra BC, moviendo C una fracción λ del movimiento final (λ = 1 es la solución). La línea «aquí» se mueve con λ:
#anim fplot(exacto = (sqrt((-3 + x*-11.6921/1000)^2 + (3 + x*-37.2085/1000)^2) - sqrt(18))*1000, lineal = x*(c_2*(-11.6921) + s_2*(-37.2085)), aqui = (sqrt((-3 + n*-11.6921/1000)^2 + (3 + n*-37.2085/1000)^2) - sqrt(18))*1000 + 0*x, [0 3]), n = 0:0.1:3
#: (eje horizontal: λ; vertical: δ_BC en mm.) En la solución (λ = 1) el exacto da −17.90 mm y el lineal −18.04 mm (0.8 %); en AC, −38.9964 contra −38.9965. Por eso basta δ ≈ c·u₁ + s·u₂ en esta cercha.

## 6 · En una línea
#: **1 incógnita = una división repetida (Δ d = R/k_T). Muchas incógnitas = un sistema lineal repetido (K_T·Δ u = R).** El talud por elementos finitos de las hojas 190 y 195 hace exactamente esto con cientos de incógnitas (la K_T sale de los triángulos y de Drucker-Prager en cada punto de Gauss), y la viga de la hoja 200 lo hace con rótulas que se ablandan. Cuando K_T ya no tiene inversa (la curva se puso horizontal) el residuo no baja: no hay equilibrio.
#: Comprobado en 7 lenguajes (Python, C++, Fortran, MATLAB, Hekatan Lab, Calcpad y Hekatan LISP): **u = (−11.6921, −37.2085) mm en 7 vueltas**, igual que la hoja 196.
