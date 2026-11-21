# Errata de la Ec. (8.9) de Wilson (libro, cap. 8) · parche de cortante constante en un trapecio: la ecuación impresa contra la inversa de la (8.8)
#numerico
#: **Qué se prueba.** En el DSE de Wilson (E. L. Wilson, *Three-Dimensional Static and Dynamic Analysis of Structures*, cap. 8, p. 8-6 en la ed. 2005 y p. 8-7 en el PDF paginado) el cortante de cada nudo sale de los cortantes de los dos lados que llegan a él. La (8.8) dice [γij; γki] = M·[γxz; γyz] con M = [cos αij, sin αij; cos αki, sin αki]. La (8.9) debería ser M⁻¹, pero la impresa trae los términos de la diagonal secundaria cambiados.
#: **Inversa correcta:** M⁻¹ = 1/det·[sin αki, −sin αij; −cos αki, cos αij]. **Impresa (8.9):** 1/det·[sin αki, −cos αki; −sin αij, cos αij]. Con det = cos αij·sin αki − cos αki·sin αij.
#: **Prueba (parche de cortante constante):** w = 0.3·x + 0.7·y en los nudos, giros nulos. El cortante verdadero es γ = (0.3, 0.7) en todo el elemento. Si la fórmula del nudo es correcta, los cuatro nudos dan (0.3, 0.7) exactos. En un rectángulo las dos coinciden (por eso las tablas del libro no la delatan); en un trapecio, no.

## 1 · Repaso de álgebra lineal: primero con letras, después con números
#: **Orden de trabajo:** primero cada operación con **letras** (simbólico: se ve la regla), y recién después se **reemplazan los valores**. Cada operación se escribe completa y luego **parte por parte** (elemento por elemento).
#: **1.1 · Con letras.** Dos matrices de 2 × 2 y un vector:
S_A = Simplify{[a_11, a_12; a_21, a_22]}
S_B = Simplify{[b_11, b_12; b_21, b_22]}
S_b = Simplify{[b_1; b_2]}
#: **Suma** (cada lugar con su igual):
S_S = Simplify{S_A + S_B}
s_s11 = Simplify{a_11 + b_11} 'fila 1, columna 1
s_s12 = Simplify{a_12 + b_12} 'fila 1, columna 2
s_s21 = Simplify{a_21 + b_21} 'fila 2, columna 1
s_s22 = Simplify{a_22 + b_22} 'fila 2, columna 2
#: **Producto A·B** (cada elemento = fila de A · columna de B: se multiplica pareja a pareja y se suma):
S_P = Simplify{S_A*S_B}
s_p11 = Simplify{a_11*b_11 + a_12*b_21} 'fila 1 de A por columna 1 de B
s_p12 = Simplify{a_11*b_12 + a_12*b_22} 'fila 1 de A por columna 2 de B
s_p21 = Simplify{a_21*b_11 + a_22*b_21} 'fila 2 de A por columna 1 de B
s_p22 = Simplify{a_21*b_12 + a_22*b_22} 'fila 2 de A por columna 2 de B
#: **El orden importa:** B·A es otra matriz (A·B ≠ B·A):
S_Q = Simplify{S_B*S_A}
#: **Transpuesta** (filas ↔ columnas) y la regla (A·B)ᵀ = Bᵀ·Aᵀ:
S_At = Simplify{transpose(S_A)}
S_L = Simplify{transpose(S_A*S_B)} 'lado izquierdo (A·B)ᵀ
S_R = Simplify{transpose(S_B)*transpose(S_A)} 'lado derecho Bᵀ·Aᵀ: la misma matriz
#: **Determinante** = (diagonal principal) − (diagonal secundaria):
s_det = Simplify{a_11*a_22 - a_12*a_21} 'det A = a₁₁·a₂₂ − a₁₂·a₂₁
#: **Adjunta**: se intercambian los de la diagonal principal y se cambia de signo la secundaria, sin moverlos de lugar:
S_adj = Simplify{[a_22, -a_12; -a_21, a_11]}
#: **Inversa = adjunta ÷ determinante: la división, elemento por elemento**:
s_i11 = Simplify{a_22/(a_11*a_22 - a_12*a_21)} 'adjunta(1,1) ÷ det
s_i12 = Simplify{-a_12/(a_11*a_22 - a_12*a_21)} 'adjunta(1,2) ÷ det
s_i21 = Simplify{-a_21/(a_11*a_22 - a_12*a_21)} 'adjunta(2,1) ÷ det
s_i22 = Simplify{a_11/(a_11*a_22 - a_12*a_21)} 'adjunta(2,2) ÷ det
S_I = Simplify{inv(S_A)} 'la misma, con la función del motor
#: **Prueba A·A⁻¹ = I** (con letras debe dar la identidad):
S_C = Simplify{S_A*S_I}
#: **Resolver A·x = b** → x = A⁻¹·b, parte por parte:
s_x1 = Simplify{(a_22*b_1 - a_12*b_2)/(a_11*a_22 - a_12*a_21)} 'x₁ = (a₂₂·b₁ − a₁₂·b₂) ÷ det
s_x2 = Simplify{(-a_21*b_1 + a_11*b_2)/(a_11*a_22 - a_12*a_21)} 'x₂ = (−a₂₁·b₁ + a₁₁·b₂) ÷ det
#: **1.2 · Reemplazo de valores.** Ahora se sustituye: a₁₁ = 4, a₁₂ = 7, a₂₁ = 2, a₂₂ = 6; b₁₁ = 1, b₁₂ = 2, b₂₁ = 3, b₂₂ = 1; b₁ = 1, b₂ = 2. Cada línea es la fórmula de arriba con esos números:
R_A = [4, 7; 2, 6]
R_B = [1, 2; 3, 1]
#: **Suma:**
R_S = R_A + R_B
r_s11 = 4 + 1 'a₁₁ + b₁₁
r_s12 = 7 + 2 'a₁₂ + b₁₂
r_s21 = 2 + 3 'a₂₁ + b₂₁
r_s22 = 6 + 1 'a₂₂ + b₂₂
#: **Producto A·B:**
R_P = R_A·R_B
r_p11 = 4·1 + 7·3 'a₁₁·b₁₁ + a₁₂·b₂₁
r_p12 = 4·2 + 7·1 'a₁₁·b₁₂ + a₁₂·b₂₂
r_p21 = 2·1 + 6·3 'a₂₁·b₁₁ + a₂₂·b₂₁
r_p22 = 2·2 + 6·1 'a₂₁·b₁₂ + a₂₂·b₂₂
#: **B·A** (otra matriz):
R_Q = R_B·R_A
r_q11 = 1·4 + 2·2 'b₁₁·a₁₁ + b₁₂·a₂₁
r_q12 = 1·7 + 2·6 'b₁₁·a₁₂ + b₁₂·a₂₂
r_q21 = 3·4 + 1·2 'b₂₁·a₁₁ + b₂₂·a₂₁
r_q22 = 3·7 + 1·6 'b₂₁·a₁₂ + b₂₂·a₂₂
#: **Transpuesta:**
R_At = transpose(R_A)
R_L = transpose(R_A·R_B) 'lado izquierdo (A·B)ᵀ
R_R = transpose(R_B)·transpose(R_A) 'lado derecho Bᵀ·Aᵀ: la misma matriz
#: **Determinante:**
r_d1 = 4·6 'a₁₁·a₂₂
r_d2 = 7·2 'a₁₂·a₂₁
r_det = r_d1 - r_d2 'det A = 24 − 14 = 10
r_det2 = det(R_A) 'el mismo, con la función del motor
#: **Adjunta:**
R_adj = [6, -7; -2, 4] 'a₂₂, −a₁₂, −a₂₁, a₁₁
#: **Inversa, la división elemento por elemento:**
r_i11 = 6/r_det 'a₂₂ ÷ det
r_i12 = -7/r_det '−a₁₂ ÷ det
r_i21 = -2/r_det '−a₂₁ ÷ det
r_i22 = 4/r_det 'a₁₁ ÷ det
R_I = [r_i11, r_i12; r_i21, r_i22] 'la inversa armada con esas cuatro divisiones
R_I2 = inv(R_A) 'la misma, con la función del motor
#: **Prueba A·A⁻¹ = I** (debe dar 1, 0, 0, 1):
r_c11 = 4·r_i11 + 7·r_i21 'fila 1 de A por columna 1 de A⁻¹ = 1
r_c12 = 4·r_i12 + 7·r_i22 'fila 1 de A por columna 2 de A⁻¹ = 0
r_c21 = 2·r_i11 + 6·r_i21 'fila 2 de A por columna 1 de A⁻¹ = 0
r_c22 = 2·r_i12 + 6·r_i22 'fila 2 de A por columna 2 de A⁻¹ = 1
#: **Resolver A·x = b** con b₁ = 1, b₂ = 2:
r_x1 = (6·1 - 7·2)/r_det 'x₁ = (a₂₂·b₁ − a₁₂·b₂) ÷ det = −0.8
r_x2 = (-2·1 + 4·2)/r_det 'x₂ = (−a₂₁·b₁ + a₁₁·b₂) ÷ det = 0.6
r_ch1 = 4·r_x1 + 7·r_x2 'A·x, fila 1: vuelve a dar b₁ = 1
r_ch2 = 2·r_x1 + 6·r_x2 'A·x, fila 2: vuelve a dar b₂ = 2

## 2 · Datos
a_x = 0.3 'pendiente de w en x (= γxz verdadero)
a_y = 0.7 'pendiente de w en y (= γyz verdadero)
#hide
e_imp = zeros(2, 1)
e_cor = zeros(2, 1)
X_g = zeros(8, 2)
X_g(1:4, :) = [0, 0; 2, 0; 2, 1; 0, 1]
X_g(5:8, :) = [0, 0; 2, 0; 1.5, 1; 0.25, 1]
for g = 1:2
  X_e = X_g(4·g - 3:4·g, :)
  L_l = zeros(4, 1)
  s_l = zeros(4, 1)
  c_l = zeros(4, 1)
  G_l = zeros(4, 16)
  u_p = zeros(16, 1)
  for m = 1:4
    j = m + 1
    if j > 4
      j = 1
    end
    d_x = X_e(j, 1) - X_e(m, 1)
    d_y = X_e(j, 2) - X_e(m, 2)
    L_l(m) = sqrt(d_x^2 + d_y^2)
    s_l(m) = d_y/L_l(m)
    c_l(m) = d_x/L_l(m)
    G_l(m, 3·j - 2) = G_l(m, 3·j - 2) + 1/L_l(m)
    G_l(m, 3·m - 2) = G_l(m, 3·m - 2) - 1/L_l(m)
    G_l(m, 3·m - 1) = G_l(m, 3·m - 1) - s_l(m)/2
    G_l(m, 3·j - 1) = G_l(m, 3·j - 1) - s_l(m)/2
    G_l(m, 3·m) = G_l(m, 3·m) + c_l(m)/2
    G_l(m, 3·j) = G_l(m, 3·j) + c_l(m)/2
    G_l(m, 12 + m) = -2/3
    u_p(3·m - 2) = a_x·X_e(m, 1) + a_y·X_e(m, 2)
  end
  g_s = G_l·u_p
  e_i = 0
  e_c = 0
  for i = 1:4
    k = i - 1
    if k < 1
      k = 4
    end
    d_t = c_l(i)·s_l(k) - c_l(k)·s_l(i)
    T_i = [s_l(k), -c_l(k); -s_l(i), c_l(i)]/d_t
    T_c = [s_l(k), -s_l(i); -c_l(k), c_l(i)]/d_t
    v_s = [g_s(i); g_s(k)]
    g_i = T_i·v_s
    g_c = T_c·v_s
    e_i = max(e_i, max(abs(g_i(1) - a_x), abs(g_i(2) - a_y)))
    e_c = max(e_c, max(abs(g_c(1) - a_x), abs(g_c(2) - a_y)))
  end
  e_imp(g) = e_i
  e_cor(g) = e_c
end
#show

## 3 · Resultado: error del cortante del nudo respecto de (0.3, 0.7)
#: Mayor error absoluto entre los cuatro nudos. Cero = el parche pasa.
E_rect_impresa = e_imp(1) 'rectángulo 2 × 1, ecuación (8.9) impresa
E_rect_inversa = e_cor(1) 'rectángulo 2 × 1, inversa de (8.8)
E_trap_impresa = e_imp(2) 'trapecio (0,0) (2,0) (1.5,1) (0.25,1), ecuación (8.9) impresa
E_trap_inversa = e_cor(2) 'trapecio, inversa de (8.8)

## 4 · La fórmula de la inversa 2 × 2 y por qué la (8.9) impresa falla (álgebra lineal simbólica)
#: **Fórmula.** Para M = [m_a, m_b; m_c, m_d] con det M = m_a·m_d − m_b·m_c ≠ 0: **M⁻¹ = 1/det · [m_d, −m_b; −m_c, m_a]**. Regla: se **intercambian** los términos de la diagonal principal (m_a ↔ m_d) y se **cambia de signo** los de la secundaria, sin moverlos de lugar (m_b sigue en la fila 1, m_c en la fila 2). La impresa los mueve de lugar: ese es el error.
M_g = Simplify{[m_a, m_b; m_c, m_d]}
M_gi = Simplify{inv(M_g)}
#: **Misma inversa escrita con el determinante:** M⁻¹ = (1/det M) · adj(M), donde adj(M) = [m_d, −m_b; −m_c, m_a] es la matriz adjunta (cofactores traspuestos).
d_g = Simplify{m_a*m_d - m_b*m_c} 'determinante de M_g
A_g = Simplify{[m_d, -m_b; -m_c, m_a]} 'adjunta de M_g
M_gd = Simplify{A_g/d_g} 'inversa = adjunta / determinante (igual a M_gi)
#: **La misma división, elemento por elemento** (cada elemento de la adjunta entre el determinante):
M_gi11 = Simplify{m_d/d_g} 'elemento (1,1): m_d ÷ det
M_gi12 = Simplify{-m_b/d_g} 'elemento (1,2): −m_b ÷ det
M_gi21 = Simplify{-m_c/d_g} 'elemento (2,1): −m_c ÷ det
M_gi22 = Simplify{m_a/d_g} 'elemento (2,2): m_a ÷ det
#: **Comprobación simbólica:** M·M⁻¹ debe dar la identidad (det aparece en el denominador y se cancela).
I_g = Simplify{M_g*M_gi}
#: **Aplicado a la (8.8)** con m_a = cos α_ij, m_b = sin α_ij, m_c = cos α_ki, m_d = sin α_ki:
M_w = Simplify{[cos(a_ij), sin(a_ij); cos(a_ki), sin(a_ki)]}
d_w = Simplify{cos(a_ij)*sin(a_ki) - cos(a_ki)*sin(a_ij)}
T_correcta = Simplify{[sin(a_ki), -sin(a_ij); -cos(a_ki), cos(a_ij)]/d_w}
T_impresa = Simplify{[sin(a_ki), -cos(a_ki); -sin(a_ij), cos(a_ij)]/d_w}
#: **Prueba:** M_w·T_correcta = I. M_w·T_impresa ≠ I.
P_correcta = Simplify{M_w*T_correcta}
P_impresa = Simplify{M_w*T_impresa}
#: **Ejemplo con números** (lado ij horizontal, α_ij = 0; lado ki a 60°): M = [1, 0; 0.5, 0.866], det = 0.866.
M_n = [1, 0; 0.5, 0.866]
d_n = 1·0.866 - 0·0.5 'determinante
T_c = [0.866, 0; -0.5, 1]/d_n 'inversa correcta de (8.8)
T_i = [0.866, -0.5; 0, 1]/d_n 'la (8.9) impresa
P_c = M_n·T_c 'da la identidad
P_i = M_n·T_i 'NO da la identidad: [1, −0.577; 0.5, 0.711]

## 5 · Ejemplos con funciones trigonométricas
#: **a) Matriz de rotación.** R = [cos θ, −sin θ; sin θ, cos θ]. Su determinante es cos²θ + sin²θ = 1, así que la inversa por adjunta/determinante es la **traspuesta**: R⁻¹ = [cos θ, sin θ; −sin θ, cos θ] (rotar −θ).
R_t = Simplify{[cos(t), -sin(t); sin(t), cos(t)]}
d_R = Simplify{cos(t)*cos(t) + sin(t)*sin(t)} 'determinante (identidad trigonométrica: vale 1)
A_R = Simplify{[cos(t), sin(t); -sin(t), cos(t)]} 'adjunta
R_ti = Simplify{A_R/d_R} 'inversa = adjunta / determinante
#: **b) La (8.8) con ángulos concretos** (lado ij a α_ij = 0°, lado ki a α_ki = 60° = π/3; los senos y cosenos valen 0, 1, ½ y √3/2):
a_ij = 0 'ángulo del lado ij [rad]
a_ki = pi/3 'ángulo del lado ki [rad]
M_a = [cos(a_ij), sin(a_ij); cos(a_ki), sin(a_ki)]
d_a = cos(a_ij)·sin(a_ki) - cos(a_ki)·sin(a_ij) 'determinante = sin(α_ki − α_ij)
T_ca = [sin(a_ki), -sin(a_ij); -cos(a_ki), cos(a_ij)]/d_a 'inversa correcta (adjunta / determinante)
T_ia = [sin(a_ki), -cos(a_ki); -sin(a_ij), cos(a_ij)]/d_a 'la (8.9) impresa
P_ca = M_a·T_ca 'identidad
P_ia = M_a·T_ia 'no es la identidad
#: **c) El mismo caso con ángulos cualquiera** (un trapecio de α_ij = 15° y α_ki = 100°). La impresa y la correcta difieren en [0, (sin α_ij − cos α_ki)/det; −(sin α_ij − cos α_ki)/det, 0] (comprobado con sympy), así que coinciden solo cuando cos α_ki = sin α_ij, o sea α_ki = α_ij − 90° (el lado ki sale girado −90° respecto del ij, como en un rectángulo).
a_1 = 15·pi/180 'ángulo del lado ij [rad]
a_2 = 100·pi/180 'ángulo del lado ki [rad]
M_b = [cos(a_1), sin(a_1); cos(a_2), sin(a_2)]
d_b = sin(a_2 - a_1) 'determinante de M_b
T_cb = [sin(a_2), -sin(a_1); -cos(a_2), cos(a_1)]/d_b
T_ib = [sin(a_2), -cos(a_2); -sin(a_1), cos(a_1)]/d_b
P_cb = M_b·T_cb 'identidad
P_ib = M_b·T_ib 'no es la identidad
#: **d) Comprobación numérica del libro** con α_ij = 30° y α_ki = 105° (los lados del dibujo). Se multiplica (8.8) por cada versión de (8.9):
a_3 = 30·pi/180 'ángulo del lado ij [rad]
a_4 = 105·pi/180 'ángulo del lado ki [rad]
M_d = [cos(a_3), sin(a_3); cos(a_4), sin(a_4)]
d_d = sin(a_4 - a_3) 'determinante
T_cd = [sin(a_4), -sin(a_3); -cos(a_4), cos(a_3)]/d_d
T_id = [sin(a_4), -cos(a_4); -sin(a_3), cos(a_3)]/d_d
#: **Correcta:** (8.8) × (8.9 correcta) = [1.0000, ok:0.0000; ok:0.0000, 1.0000]
P_cd = M_d·T_cd 'identidad
#: **Impresa:** (8.8) × (8.9 impresa) = [0.6072, mal:0.6803; mal:−0.7588, 0.7967]
P_id = M_d·T_id 'no es la identidad
#: La versión correcta da la **identidad** (unos y ceros). La impresa deja números distintos de cero fuera de la diagonal (**0.6803** y **−0.7588**): no es la inversa.

## 6 · Ejemplos de determinante
#: **Qué es.** El determinante es un número que dice si la matriz tiene inversa (det ≠ 0) y por cuánto escala las áreas o volúmenes. En 2 × 2: det [m_a, m_b; m_c, m_d] = m_a·m_d − m_b·m_c = **área con signo del paralelogramo** formado por sus dos filas.
#: **a) Con letras primero: regla de Sarrus** (solo 3 × 3): suma de las tres diagonales hacia abajo menos las tres hacia arriba.
A_s = Simplify{[s_a, s_b, s_c; s_d, s_e, s_f; s_g, s_h, s_i]}
d_s = Simplify{s_a*s_e*s_i + s_b*s_f*s_g + s_c*s_d*s_h - s_c*s_e*s_g - s_a*s_f*s_h - s_b*s_d*s_i} 'determinante de A_s
#: **b) Con números: 3 × 3 por cofactores** (se desarrolla por la primera fila: cada elemento por el determinante 2 × 2 que queda al quitar su fila y columna, con signos + − +):
A_3 = [2, 1, 3; 0, -1, 4; 1, 2, 0]
c_11 = (-1)·0 - 4·2 'cofactor de a₁₁ (quita fila 1 y columna 1)
c_12 = 0·0 - 4·1 'determinante sin fila 1 y columna 2 (entra con signo −)
c_13 = 0·2 - (-1)·1 'determinante sin fila 1 y columna 3
d_3 = 2·c_11 - 1·c_12 + 3·c_13 'det A = 2·(−8) − 1·(−4) + 3·(1) = −9
#: **c) Determinante cero = no hay inversa.** Si las filas son proporcionales (una es múltiplo de la otra) el paralelogramo se aplasta y el área es 0:
M_0 = [1, 2; 3, 6]
d_0 = 1·6 - 2·3 'cero: la fila 2 es 3 veces la fila 1
#: **d) Lo mismo en la (8.8):** det M = sin(α_ki − α_ij). Vale cero si los dos lados que llegan al nudo son paralelos (α_ki = α_ij): ahí no se puede pasar de los cortantes de lado a los del nudo. El trapecio de α_ij = 0°, α_ki = 60° tiene det = sin 60° = 0.866 (no es cero, hay inversa); con α_ki = 0° el det vale 0.
d_60 = sin(pi/3) - 0 'determinante a 60° (= 0.866)
d_00 = cos(0)·sin(0) - cos(0)·sin(0) 'determinante con los dos lados paralelos (cero)

## 7 · Lectura
#: En el rectángulo las dos dan cero. En el trapecio la impresa falla y la inversa de (8.8) da cero (redondeo). Medido en Python con placas_wilson (hekatan-struct-py): impresa se desvía hasta 0.11 en el cortante de los puntos de Gauss; correcta 1e-12. El C++ de Struct usa la correcta en el pf 4 y la impresa solo en el pf 7. **Nota:** la hoja 159 usa la (8.9) impresa tal como está en el libro (sus datos son un cuadrilátero cualquiera).

## 8 · Fuente, lo correcto y lo mal tipeado (qué cambia en el cálculo)
#: **De dónde sale.** E. L. Wilson, *Three-Dimensional Static and Dynamic Analysis of Structures*, **cap. 8** (elemento de placa con cortante, DSE), **ecuaciones (8.8) y (8.9)**, p. 8-6 de la edición 2005 (p. 8-7 en el PDF paginado). La (8.8) pasa los cortantes del elemento (γxz, γyz) a los de los lados (γij, γki); la (8.9) debe hacer el camino inverso, o sea ser la **inversa** de la matriz de la (8.8).
#: **Lo correcto** (inversa de la 8.8, adjunta ÷ determinante), con α_ij = 0° y α_ki = 60°: los términos de la diagonal secundaria **cambian de signo pero se quedan en su lugar**. M⁻¹ = 1/det·[sin α_ki, ok:−sin α_ij; ok:−cos α_ki, cos α_ij]
W_correcta = [sin(a_ki), -sin(a_ij); -cos(a_ki), cos(a_ij)]/d_a 'T = 1/det · [sin α_ki, −sin α_ij; −cos α_ki, cos α_ij]
#: **Lo mal tipeado** (la (8.9) tal como está impresa): los dos términos de la diagonal secundaria quedaron **cambiados de lugar** (cos α_ki arriba y sin α_ij abajo). (8.9) = 1/det·[sin α_ki, mal:−cos α_ki; mal:−sin α_ij, cos α_ij]
W_impresa = [sin(a_ki), -cos(a_ki); -sin(a_ij), cos(a_ij)]/d_a 'T = 1/det · [sin α_ki, −cos α_ki; −sin α_ij, cos α_ij]
#: **Prueba de cada una:** M·T debe dar la identidad.
W_ok = M_a·W_correcta 'identidad [1, 0; 0, 1]: bien
W_mal = M_a·W_impresa 'NO es la identidad: mal
#: **Qué cambia al calcular.** Con la correcta, el parche de cortante constante (γ = 0.3, 0.7) sale **exacto** en los cuatro nudos, en el rectángulo y en el trapecio (error ≈ 1e-16, ver sección 3). Con la impresa, el rectángulo sigue saliendo exacto, pero el **trapecio falla: el cortante del nudo se desvía hasta 0.246** (sección 3, E_trap_impresa) respecto de 0.3 y 0.7, y en los puntos de Gauss hasta 0.11 (sección 7). Es decir: **si se sigue la ecuación mal tipeada, en un elemento de lados no perpendiculares el cortante nudal sale equivocado**, y como la rigidez a cortante se arma con esos valores, la rigidez, los desplazamientos y los cortantes de la placa se alejan de la solución correcta. En rectángulos no se nota (por eso las tablas del libro no lo delatan). Esta hoja no mide cuánto cambia la rigidez total ni la flecha de una placa completa: eso depende de la malla.
