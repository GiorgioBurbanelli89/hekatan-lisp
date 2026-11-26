# Newton-Raphson en una barra con 1, 2 y 3 incógnitas - funciones de forma 1D, 2D y 3D, la misma ley que se ablanda y Kₜ·Δu = R paso a paso
#numerico

## 0 · La idea
#: Una barra cargada en la punta se acorta o se alarga. Si el material fuera lineal, bastaría una división (o un sistema K·u = F). Pero la barra **se ablanda** (la ley de la hoja 198): hay que dar **vueltas de Newton**. Esta hoja hace lo mismo tres veces, subiendo de a una incógnita: **1, 2 y 3 GDL** (grados de libertad). Y cada caso se calcula con tres elementos finitos distintos: una **barra 1D**, un **área 2D** (Q4) y un **sólido 3D** (H8). La pregunta: ¿dan lo mismo? (Spoiler: con ν = 0, sí, hasta el último decimal; con ν ≠ 0, depende de qué se deje mover a los lados.)
#dibujo("La misma barra como elemento 1D, 2D y 3D (L = 3 m, sección 1 × 1 m)", ud = m, escala = auto, cotas = m, alto = 95)
#  achurado([-0.4, 0, 0, -0.4], [-0.6, -0.6, 5.6, 5.6], "suelo")
#  linea(0, 5, 3, 5, "gruesa")
#  circulo(0, 5, 0.08, "negro")
#  circulo(3, 5, 0.08, "negro")
#  flecha(3, 5, 3.9, 5, "gruesa rojo")
#  texto(4.3, 5.25, "P", 2.6, "c")
#  texto(1.5, 5.35, "1D: barra de 2 nudos", 2.4, "c")
#  poligono(0, 2.2, 3, 2.2, 3, 3.2, 0, 3.2, "gruesa")
#  circulo(0, 2.2, 0.08, "negro")
#  circulo(3, 2.2, 0.08, "negro")
#  circulo(3, 3.2, 0.08, "negro")
#  circulo(0, 3.2, 0.08, "negro")
#  flecha(3, 2.7, 3.9, 2.7, "gruesa rojo")
#  texto(1.5, 3.5, "2D: área Q4 (4 nudos)", 2.4, "c")
#  poligono(0, -0.6, 3, -0.6, 3, 0.4, 0, 0.4, "gruesa")
#  poligono(3, -0.6, 3.5, -0.2, 3.5, 0.8, 3, 0.4, "gruesa")
#  poligono(0, 0.4, 0.5, 0.8, 3.5, 0.8, 3, 0.4, "gruesa")
#  linea(0, -0.6, 0.5, -0.2, "trazos")
#  linea(0.5, -0.2, 3.5, -0.2, "trazos")
#  linea(0.5, -0.2, 0.5, 0.8, "trazos")
#  flecha(3.25, 0.1, 4.15, 0.1, "gruesa rojo")
#  texto(1.6, 1.15, "3D: sólido H8 (8 nudos)", 2.4, "c")
#  cota(0, -1.2, 3, -1.2, 0, "L = 3 m")
#fin
### Los 6 pasos de Newton (los mismos en toda la hoja)
#: **1.** u₀ = 0.  **2.** En cada punto de Gauss: ε = B·u, σ(ε) con la ley, y Eₜ = dσ/dε.  **3.** fᵢₙₜ = ∫ Bᵀ·σ dV y R = F − fᵢₙₜ.  **4.** Si |R| < tolerancia: terminar.  **5.** Kₜ = ∫ Bᵀ·Eₜ·B dV y resolver Kₜ·Δ u = R.  **6.** u ← u + Δ u y volver al paso 2.
#: En 2D y 3D la cara cargada se **ata** (todos sus nudos se mueven el mismo u) y los lados no se dejan mover hacia arriba ni hacia adentro: así el área y el sólido también tienen **una sola incógnita** por sección, como la barra.

## 1 · 1 GDL: las funciones de forma, primero con símbolos
### 1.1 · Barra 1D: de un polinomio a N₁ y N₂
#: Dentro del elemento (ξ = x/L va de 0 a 1) el movimiento es una recta: u = a₀ + a₁ξ. Sus dos coeficientes salen de las dos condiciones en los nudos: u(0) = u₁ y u(1) = u₂. Escritas como matriz A·[a₀; a₁] = [u₁; u₂]:
A_1 = Simplify{[1, 0; 1, 1]}
#: La inversa da los coeficientes en función de los nudos; multiplicada por la base [1, ξ] da las **funciones de forma**:
C_1 = Simplify{inv([1, 0; 1, 1])}
N_1D = Simplify{[1, xi]*inv([1, 0; 1, 1])}
#: **N₁ = 1 − ξ y N₂ = ξ**: cada una vale 1 en su nudo y 0 en el otro. La deformación es la derivada respecto de x = ξL (el motor deriva; dξ/dx = 1/L):
B_1 = Simplify{Diff{1 - xi @ xi}/L}
B_2 = Simplify{Diff{xi @ xi}/L}
#: Rigidez: k = ∫ Bᵀ·E·A·B dx con B = [−1/L, 1/L]; Bᵀ·B término a término, y con dx = L·dξ el motor integra de 0 a 1:
K_1D = Simplify{E*A*L*Integral{[(-1/L)*(-1/L), (-1/L)*(1/L); (1/L)*(-1/L), (1/L)*(1/L)] @ xi = 0 : 1}}
#: Con el nudo 1 fijo queda **k = EA/L**, una sola incógnita u₂. Las dos funciones de forma (eje horizontal: ξ):
#fplot(N_1 = 1 - x, N_2 = x, [0 1])
### 1.2 · Área 2D (Q4): funciones bilineales
#: En el cuadrado de referencia (ξ y η de −1 a +1) el movimiento es u = a₀ + a₁ξ + a₂η + a₃ξη. Las cuatro condiciones en las esquinas (−1,−1), (1,−1), (1,1), (−1,1):
A_2 = Simplify{[1, -1, -1, 1; 1, 1, -1, -1; 1, 1, 1, 1; 1, -1, 1, -1]}
N_Q4 = Simplify{[1, xi, eta, xi*eta]*inv([1, -1, -1, 1; 1, 1, -1, -1; 1, 1, 1, 1; 1, -1, 1, -1])}
#: Son **(1 ± ξ)(1 ± η)/4**. La cara cargada es la de ξ = +1 (nudos 2 y 3), atada con el mismo u; los nudos 1 y 4 están fijos. Entonces u(ξ, η) = (N₂ + N₃)·u:
S_Q4 = Simplify{(1 + xi)*(1 - eta)/4 + (1 + xi)*(1 + eta)/4}
#: ¡No depende de η! Es la misma recta de la barra. La deformación ε_x = (2/L)·∂/∂ξ es constante, y la integral sobre el área (det J = (L/2)(h/2), espesor t) colapsa a la de la barra:
K_Q4 = Simplify{E*t*Integral{Integral{(1/L)^2*(L/2)*(h/2) @ eta = -1 : 1} @ xi = -1 : 1}}
#: **E·t·h/L = EA/L** con A = t·h. La función de forma N₁ del Q4 en 3D (x = ξ, y = η; arrastra para girar):
#surf((1 - x)*(1 - y)/4, [-1 1], [-1 1])
### 1.3 · Sólido 3D (H8): funciones trilineales
#: Lo mismo con tres coordenadas: N = (1 ± ξ)(1 ± η)(1 ± ζ)/8, una por esquina. La cara ξ = +1 tiene 4 nudos; su suma:
S_H8 = Simplify{(1 + xi)*(1 - eta)*(1 - zeta)/8 + (1 + xi)*(1 + eta)*(1 - zeta)/8 + (1 + xi)*(1 + eta)*(1 + zeta)/8 + (1 + xi)*(1 - eta)*(1 + zeta)/8}
K_H8 = Simplify{E*Integral{Integral{Integral{(1/L)^2*(L/2)*(b/2)*(h/2) @ zeta = -1 : 1} @ eta = -1 : 1} @ xi = -1 : 1}}
#: **E·b·h/L = EA/L** otra vez. Los tres elementos, con la cara atada y ν = 0, son **la misma rigidez**. Un corte de N₁ del H8 en ζ = 0 (en 2D, la mitad del Q4):
#fplot(corte_N1 = (1 - x)/4, corte_N2 = (1 + x)/4, [-1 1])
### 1.4 · La ley que se ablanda y su rigidez tangente
#: (La de la hoja 198, aplicada a ε_x en cada punto de Gauss; los demás esfuerzos, elásticos con ν = 0.) En fuerza: N = k·δ/(1 + k·δ/N_u) para δ > 0. Su derivada, la rigidez tangente:
N_b = Simplify{k*delta/(1 + k*delta/N_u)}
k_b = Simplify{Diff{k*delta/(1 + k*delta/N_u) @ delta}}
#: Es k/(1 + k·δ/N_u)²: vale k al inicio y baja al estirarse. **El paso de Newton con 1 incógnita: Δ u = R/kₜ.**

## 2 · 1 GDL con números: siete vueltas
E_y = 60000 'módulo E [kPa]
A_s = 1 'área de la sección 1 × 1 [m²]
L_e = 3 'largo del elemento [m]
k_0 = E_y*A_s/L_e/1000 'k = EA/L [kN/mm]
N_u = 300 'fuerza máxima del elemento 1 [kN]
P_1 = 240 'carga en la punta [kN]
F_a(x) = k_0*x/(1 + k_0*abs(x)/N_u) 'fuerza de la barra con alargamiento x [kN]
T_a(x) = k_0/(1 + k_0*abs(x)/N_u)^2 'rigidez tangente [kN/mm]
s_u = N_u/A_s 'resistencia σᵤ = Nᵤ/A [kPa]
d_0 = 0 'u inicial [mm]
#: **Vuelta 1, paso a paso** (u = d_0 mm). Paso 2, en cada punto de Gauss (todos iguales: la cara está atada):
epsilon_g = d_0/1000/L_e 'ε = u/L [-]
sigma_g = E_y*epsilon_g/(1 + E_y*abs(epsilon_g)/s_u) 'σ(ε) con la ley que se ablanda [kPa]
E_tg = E_y/(1 + E_y*abs(epsilon_g)/s_u)^2 'módulo tangente Eₜ = dσ/dε [kPa]
#: Paso 3 y 5 con cada elemento. **Barra 1D** (2 puntos de Gauss, peso 1, det J = L/2):
f_bar = 2*(1/L_e)*sigma_g*A_s*(L_e/2) 'fᵢₙₜ = Σ B·σ·A·det J [kN]
k_bar = 2*(1/L_e)*E_tg*(1/L_e)*A_s*(L_e/2)/1000 'Kₜ = Σ B·Eₜ·B·A·det J [kN/mm]
#: **Área Q4** (4 puntos, det J = (L/2)(h/2), espesor 1 m):
f_quad = 4*(1/L_e)*sigma_g*1*(L_e/2)*(1/2) 'fᵢₙₜ [kN]
k_quad = 4*(1/L_e)*E_tg*(1/L_e)*1*(L_e/2)*(1/2)/1000 'Kₜ [kN/mm]
#: **Sólido H8** (8 puntos, det J = (L/2)(b/2)(h/2)):
f_hex = 8*(1/L_e)*sigma_g*(L_e/2)*(1/2)*(1/2) 'fᵢₙₜ [kN]
k_hex = 8*(1/L_e)*E_tg*(1/L_e)*(L_e/2)*(1/2)*(1/2)/1000 'Kₜ [kN/mm]
#: Los tres dan lo mismo. Pasos 3 a 6:
R_g = P_1 - f_bar 'R = F − fᵢₙₜ [kN]
D_g = R_g/k_bar 'Δu = R/Kₜ [mm]
u_g = d_0 + D_g 'u nuevo = u + Δu [mm]
d_1 = u_g 'u₁ [mm]
#: **Vuelta 2, paso a paso** (u = d_1 mm). Paso 2, en cada punto de Gauss (todos iguales: la cara está atada):
epsilon_g = d_1/1000/L_e 'ε = u/L [-]
sigma_g = E_y*epsilon_g/(1 + E_y*abs(epsilon_g)/s_u) 'σ(ε) con la ley que se ablanda [kPa]
E_tg = E_y/(1 + E_y*abs(epsilon_g)/s_u)^2 'módulo tangente Eₜ = dσ/dε [kPa]
#: Paso 3 y 5 con cada elemento. **Barra 1D** (2 puntos de Gauss, peso 1, det J = L/2):
f_bar = 2*(1/L_e)*sigma_g*A_s*(L_e/2) 'fᵢₙₜ = Σ B·σ·A·det J [kN]
k_bar = 2*(1/L_e)*E_tg*(1/L_e)*A_s*(L_e/2)/1000 'Kₜ = Σ B·Eₜ·B·A·det J [kN/mm]
#: **Área Q4** (4 puntos, det J = (L/2)(h/2), espesor 1 m):
f_quad = 4*(1/L_e)*sigma_g*1*(L_e/2)*(1/2) 'fᵢₙₜ [kN]
k_quad = 4*(1/L_e)*E_tg*(1/L_e)*1*(L_e/2)*(1/2)/1000 'Kₜ [kN/mm]
#: **Sólido H8** (8 puntos, det J = (L/2)(b/2)(h/2)):
f_hex = 8*(1/L_e)*sigma_g*(L_e/2)*(1/2)*(1/2) 'fᵢₙₜ [kN]
k_hex = 8*(1/L_e)*E_tg*(1/L_e)*(L_e/2)*(1/2)*(1/2)/1000 'Kₜ [kN/mm]
#: Los tres dan lo mismo. Pasos 3 a 6:
R_g = P_1 - f_bar 'R = F − fᵢₙₜ [kN]
D_g = R_g/k_bar 'Δu = R/Kₜ [mm]
u_g = d_1 + D_g 'u nuevo = u + Δu [mm]
#: Las 7 vueltas seguidas (paso 2 a 6 en una línea cada uno):
q_0 = P_1 - F_a(d_0) 'residuo R = P − N [kN]
d_1 = d_0 + q_0/T_a(d_0) 'u nuevo = u + R/kₜ [mm]
q_1 = P_1 - F_a(d_1) 'residuo R = P − N [kN]
d_2 = d_1 + q_1/T_a(d_1) 'u nuevo = u + R/kₜ [mm]
q_2 = P_1 - F_a(d_2) 'residuo R = P − N [kN]
d_3 = d_2 + q_2/T_a(d_2) 'u nuevo = u + R/kₜ [mm]
q_3 = P_1 - F_a(d_3) 'residuo R = P − N [kN]
d_4 = d_3 + q_3/T_a(d_3) 'u nuevo = u + R/kₜ [mm]
q_4 = P_1 - F_a(d_4) 'residuo R = P − N [kN]
d_5 = d_4 + q_4/T_a(d_4) 'u nuevo = u + R/kₜ [mm]
q_5 = P_1 - F_a(d_5) 'residuo R = P − N [kN]
d_6 = d_5 + q_5/T_a(d_5) 'u nuevo = u + R/kₜ [mm]
q_6 = P_1 - F_a(d_6) 'residuo R = P − N [kN]
d_7 = d_6 + q_6/T_a(d_6) 'u nuevo = u + R/kₜ [mm]
q_7 = P_1 - F_a(d_7) 'residuo final [kN]
#: **u = 60 mm en 7 vueltas** (lo lineal diría 12 mm: cinco veces menos). ¿Y el área y el sólido? Con el ensamblado completo (Q4 con 2 × 2 puntos de Gauss, H8 con 2 × 2 × 2) y la cara atada, el residuo es **idéntico** vuelta a vuelta (juez numpy; y Hekatan OpenSees da 60.0000 mm con el elemento truss):
i_t = [0; 1; 2; 3; 4; 5; 6; 7] 'vuelta [-]
R_1D = [240; 106.667; 41.626; 12.0956; 1.73776; 0.0475746; 3.76626e-05; 2.359e-11] '|R| con el elemento 1D (juez) [kN]
R_2D = [240; 106.667; 41.626; 12.0956; 1.73776; 0.0475746; 3.76626e-05; 2.36469e-11] '|R| con el elemento 2D (juez) [kN]
R_3D = [240; 106.667; 41.626; 12.0956; 1.73776; 0.0475746; 3.76626e-05; 2.36469e-11] '|R| con el elemento 3D (juez) [kN]
#tabla("vuelta:0","barra 1D |R| [kN]:4","Q4 2D |R| [kN]:4","H8 3D |R| [kN]:4")(i_t; R_1D; R_2D; R_3D)
#: **La tangente que avanza** (gráfica dinámica): mueve n = el punto donde se toma la recta tangente; donde corta la carga P = 240 kN está el siguiente u (eje horizontal: u en mm; vertical: kN):
#slider fplot(barra = 20*x/(1 + 20*x/300), carga = 240 + 0*x, tangente = 20*n/(1 + 20*n/300) + 20/(1 + 20*n/300)^2*(x - n), [0 80]), n = 0:2:60
Z_z = [d_0, 0; d_1, P_1; d_1, F_a(d_1); d_2, P_1; d_2, F_a(d_2); d_3, P_1; d_3, F_a(d_3); d_4, P_1; d_4, F_a(d_4); d_5, P_1; d_5, F_a(d_5); d_6, P_1; d_6, F_a(d_6)] 'zigzag de Newton (u, N)
#fplot(Newton = Z_z, [0 80])

## 3 · ¿Y si ν ≠ 0? Lo que cambia en 2D y 3D
#: La barra 1D no sabe de Poisson. El área y el sólido sí: al estirarse **se adelgazan** de costado. Si se los deja adelgazar (lados libres), la rigidez sigue siendo **E·A/L** (tensión uniaxial). Si los lados están **restringidos**, el material no puede contraerse y se pone más rígido:
k_libre = Simplify{E*A/L}
k_plano = Simplify{E/(1 - nu^2)*A/L}
k_edom = Simplify{E*(1 - nu)/((1 + nu)*(1 - 2*nu))*A/L}
#: (2D en tensión plana con el lado fijo: E/(1 − ν²). 3D con los dos lados fijos: el **módulo edométrico**, el del ensayo de consolidación.) Con ν = 0.3 (juez numpy y Hekatan OpenSees quad/stdBrick dan lo mismo):
n_p = 0.3 'Poisson [-]
k_l = k_0 'lados libres (1D, 2D, 3D) [kN/mm]
k_p = k_0/(1 - n_p^2) '2D, lado restringido [kN/mm]
k_m = k_0*(1 - n_p)/((1 + n_p)*(1 - 2*n_p)) '3D, lados restringidos [kN/mm]
#: Las tres rigideces contra ν (eje horizontal: ν; vertical: kN/mm). Con ν = 0 coinciden; con ν → 0.5 el edométrico se dispara (el material casi no cambia de volumen):
#fplot(libre = 20 + 0*x, plano = 20/(1 - x^2), edometrico = 20*(1 - x)/((1 + x)*(1 - 2*x)), [0 0.45])
#: **Para comparar Newton en 1D, 2D y 3D se usa ν = 0** (y la ley uniaxial en ε_x): así los tres modelos son el mismo problema.

## 4 · 2 GDL: dos elementos en serie
#dibujo("Dos elementos en serie: incógnitas u₁ (nudo 2) y u₂ (nudo 3)", ud = m, escala = auto, cotas = m, alto = 60)
#  achurado([-0.4, 0, 0, -0.4], [-0.6, -0.6, 0.6, 0.6], "suelo")
#  linea(0, 0, 6, 0, "gruesa")
#  circulo(0, 0, 0.09, "negro")
#  circulo(3, 0, 0.09, "negro")
#  circulo(6, 0, 0.09, "negro")
#  flecha(3, 0.5, 3.9, 0.5, "gruesa rojo")
#  flecha(6, 0, 6.9, 0, "gruesa rojo")
#  texto(3.5, 0.95, "90 kN", 2.4, "c")
#  texto(6.5, 0.45, "150 kN", 2.4, "c")
#  texto(1.5, -0.45, "e1: Nu = 300 kN", 2.2, "c")
#  texto(4.5, -0.45, "e2: Nu = 200 kN", 2.2, "c")
#  texto(3, -0.95, "u₁", 2.4, "c")
#  texto(6, -0.95, "u₂", 2.4, "c")
#fin
#: Cada elemento usa las mismas funciones de forma (1D, Q4 o H8) y se **ensambla**: el elemento 1 se alarga δ₁ = u₁ y el 2, δ₂ = u₂ − u₁. Las fuerzas internas en los nudos 2 y 3 (con S₁ y S₂ = la fuerza máxima de cada elemento):
f_2s = Simplify{[k*u_1/(1 + k*u_1/S_1) - k*(u_2 - u_1)/(1 + k*(u_2 - u_1)/S_2); k*(u_2 - u_1)/(1 + k*(u_2 - u_1)/S_2)]}
#: La matriz tangente es la derivada de cada fuerza respecto de cada incógnita (el motor deriva):
g_11 = Simplify{Diff{k*u_1/(1 + k*u_1/S_1) - k*(u_2 - u_1)/(1 + k*(u_2 - u_1)/S_2) @ u_1}}
g_12 = Simplify{Diff{k*u_1/(1 + k*u_1/S_1) - k*(u_2 - u_1)/(1 + k*(u_2 - u_1)/S_2) @ u_2}}
g_22 = Simplify{Diff{k*(u_2 - u_1)/(1 + k*(u_2 - u_1)/S_2) @ u_2}}
#: Es decir **Kₜ = [t₁ + t₂, −t₂; −t₂, t₂]**: cada elemento pone su tₑ = k/(1 + k·δₑ/Sₑ)² en su lugar (el ensamblado). Y el paso: Kₜ·Δ u = R.
F_b(x) = k_0*x/(1 + k_0*abs(x)/200) 'fuerza del elemento con Nu = 200 kN [kN]
T_b(x) = k_0/(1 + k_0*abs(x)/200)^2 'su rigidez tangente [kN/mm]
Q_2(x, y) = [F_a(x) - F_b(y - x); F_b(y - x)] 'fuerzas internas [kN]
K_2(x, y) = [T_a(x) + T_b(y - x), -T_b(y - x); -T_b(y - x), T_b(y - x)] 'matriz tangente [kN/mm]
F_2 = [90; 150] 'cargas en los nudos 2 y 3 [kN]
v_0 = [0; 0] 'u inicial [mm]
#: **Vuelta 1, paso a paso** (u = v_0 en mm). Paso 2, deformación de cada elemento (igual en todos sus puntos de Gauss):
epsilon_1 = v_0(1)/1000/L_e 'ε del elemento 1 = (u_j − u_i)/L [-]
sigma_1 = E_y*epsilon_1/(1 + E_y*abs(epsilon_1)/300) 'σ(ε), σᵤ = 300 kPa [kPa]
E_t1 = E_y/(1 + E_y*abs(epsilon_1)/300)^2 'Eₜ = dσ/dε [kPa]
epsilon_2 = (v_0(2) - v_0(1))/1000/L_e 'ε del elemento 2 = (u_j − u_i)/L [-]
sigma_2 = E_y*epsilon_2/(1 + E_y*abs(epsilon_2)/200) 'σ(ε), σᵤ = 200 kPa [kPa]
E_t2 = E_y/(1 + E_y*abs(epsilon_2)/200)^2 'Eₜ = dσ/dε [kPa]
#: Fuerza y rigidez de cada elemento con la suma de Gauss (1D: 2 puntos · Q4: 4 · H8: 8; las tres dan lo mismo):
N_bar1 = 2*(1/L_e)*sigma_1*A_s*(L_e/2) 'barra 1D [kN]
N_quad1 = 4*(1/L_e)*sigma_1*(L_e/2)*(1/2) 'Q4 [kN]
N_hex1 = 8*(1/L_e)*sigma_1*(L_e/2)*(1/2)*(1/2) 'H8 [kN]
r_bar1 = 2*(1/L_e)*E_t1*(1/L_e)*A_s*(L_e/2)/1000 'kₜ del elemento 1 (igual en Q4 y H8) [kN/mm]
N_bar2 = 2*(1/L_e)*sigma_2*A_s*(L_e/2) 'barra 1D [kN]
N_quad2 = 4*(1/L_e)*sigma_2*(L_e/2)*(1/2) 'Q4 [kN]
N_hex2 = 8*(1/L_e)*sigma_2*(L_e/2)*(1/2)*(1/2) 'H8 [kN]
r_bar2 = 2*(1/L_e)*E_t2*(1/L_e)*A_s*(L_e/2)/1000 'kₜ del elemento 2 (igual en Q4 y H8) [kN/mm]
f_v = 1*[N_bar1 - N_bar2; N_bar2] 'paso 3: fᵢₙₜ ensamblada [kN]
K_m = 1*[r_bar1 + r_bar2, -r_bar2; -r_bar2, r_bar2] 'paso 5: Kₜ ensamblada [kN/mm]
R_v = F_2 - f_v 'R = F − fᵢₙₜ [kN]
n_v = sqrt(R_v(1)^2 + R_v(2)^2) '|R| [kN]
D_v = lsolve(K_m, R_v) 'resolver Kₜ·Δu = R [mm]
u_v = v_0 + D_v 'paso 6: u nuevo = u + Δu [mm]
v_1 = u_v 'u₁ [mm]
#: **Vuelta 2, paso a paso** (u = v_1 en mm). Paso 2, deformación de cada elemento (igual en todos sus puntos de Gauss):
epsilon_1 = v_1(1)/1000/L_e 'ε del elemento 1 = (u_j − u_i)/L [-]
sigma_1 = E_y*epsilon_1/(1 + E_y*abs(epsilon_1)/300) 'σ(ε), σᵤ = 300 kPa [kPa]
E_t1 = E_y/(1 + E_y*abs(epsilon_1)/300)^2 'Eₜ = dσ/dε [kPa]
epsilon_2 = (v_1(2) - v_1(1))/1000/L_e 'ε del elemento 2 = (u_j − u_i)/L [-]
sigma_2 = E_y*epsilon_2/(1 + E_y*abs(epsilon_2)/200) 'σ(ε), σᵤ = 200 kPa [kPa]
E_t2 = E_y/(1 + E_y*abs(epsilon_2)/200)^2 'Eₜ = dσ/dε [kPa]
#: Fuerza y rigidez de cada elemento con la suma de Gauss (1D: 2 puntos · Q4: 4 · H8: 8; las tres dan lo mismo):
N_bar1 = 2*(1/L_e)*sigma_1*A_s*(L_e/2) 'barra 1D [kN]
N_quad1 = 4*(1/L_e)*sigma_1*(L_e/2)*(1/2) 'Q4 [kN]
N_hex1 = 8*(1/L_e)*sigma_1*(L_e/2)*(1/2)*(1/2) 'H8 [kN]
r_bar1 = 2*(1/L_e)*E_t1*(1/L_e)*A_s*(L_e/2)/1000 'kₜ del elemento 1 (igual en Q4 y H8) [kN/mm]
N_bar2 = 2*(1/L_e)*sigma_2*A_s*(L_e/2) 'barra 1D [kN]
N_quad2 = 4*(1/L_e)*sigma_2*(L_e/2)*(1/2) 'Q4 [kN]
N_hex2 = 8*(1/L_e)*sigma_2*(L_e/2)*(1/2)*(1/2) 'H8 [kN]
r_bar2 = 2*(1/L_e)*E_t2*(1/L_e)*A_s*(L_e/2)/1000 'kₜ del elemento 2 (igual en Q4 y H8) [kN/mm]
f_v = 1*[N_bar1 - N_bar2; N_bar2] 'paso 3: fᵢₙₜ ensamblada [kN]
K_m = 1*[r_bar1 + r_bar2, -r_bar2; -r_bar2, r_bar2] 'paso 5: Kₜ ensamblada [kN/mm]
R_v = F_2 - f_v 'R = F − fᵢₙₜ [kN]
n_v = sqrt(R_v(1)^2 + R_v(2)^2) '|R| [kN]
D_v = lsolve(K_m, R_v) 'resolver Kₜ·Δu = R [mm]
u_v = v_1 + D_v 'paso 6: u nuevo = u + Δu [mm]
#: Las 7 vueltas seguidas:
r_0 = F_2 - Q_2(v_0(1), v_0(2)) 'R = F − fᵢₙₜ [kN]
n_0 = sqrt(r_0(1)^2 + r_0(2)^2) '|R| [kN]
w_0 = lsolve(K_2(v_0(1), v_0(2)), r_0) 'Δu de Kₜ·Δu = R [mm]
v_1 = v_0 + w_0 'u nuevo [mm]
r_1 = F_2 - Q_2(v_1(1), v_1(2)) 'R = F − fᵢₙₜ [kN]
n_1 = sqrt(r_1(1)^2 + r_1(2)^2) '|R| [kN]
w_1 = lsolve(K_2(v_1(1), v_1(2)), r_1) 'Δu de Kₜ·Δu = R [mm]
v_2 = v_1 + w_1 'u nuevo [mm]
r_2 = F_2 - Q_2(v_2(1), v_2(2)) 'R = F − fᵢₙₜ [kN]
n_2 = sqrt(r_2(1)^2 + r_2(2)^2) '|R| [kN]
w_2 = lsolve(K_2(v_2(1), v_2(2)), r_2) 'Δu de Kₜ·Δu = R [mm]
v_3 = v_2 + w_2 'u nuevo [mm]
r_3 = F_2 - Q_2(v_3(1), v_3(2)) 'R = F − fᵢₙₜ [kN]
n_3 = sqrt(r_3(1)^2 + r_3(2)^2) '|R| [kN]
w_3 = lsolve(K_2(v_3(1), v_3(2)), r_3) 'Δu de Kₜ·Δu = R [mm]
v_4 = v_3 + w_3 'u nuevo [mm]
r_4 = F_2 - Q_2(v_4(1), v_4(2)) 'R = F − fᵢₙₜ [kN]
n_4 = sqrt(r_4(1)^2 + r_4(2)^2) '|R| [kN]
w_4 = lsolve(K_2(v_4(1), v_4(2)), r_4) 'Δu de Kₜ·Δu = R [mm]
v_5 = v_4 + w_4 'u nuevo [mm]
r_5 = F_2 - Q_2(v_5(1), v_5(2)) 'R = F − fᵢₙₜ [kN]
n_5 = sqrt(r_5(1)^2 + r_5(2)^2) '|R| [kN]
w_5 = lsolve(K_2(v_5(1), v_5(2)), r_5) 'Δu de Kₜ·Δu = R [mm]
v_6 = v_5 + w_5 'u nuevo [mm]
r_6 = F_2 - Q_2(v_6(1), v_6(2)) 'R = F − fᵢₙₜ [kN]
n_6 = sqrt(r_6(1)^2 + r_6(2)^2) '|R| [kN]
w_6 = lsolve(K_2(v_6(1), v_6(2)), r_6) 'Δu de Kₜ·Δu = R [mm]
v_7 = v_6 + w_6 'u nuevo [mm]
r_7 = F_2 - Q_2(v_7(1), v_7(2)) 'residuo final [kN]
#: **u₁ = 60 mm, u₂ = 90 mm en 7 vueltas** (el elemento 2 se alarga 30 mm). Con Q4 y H8 el juez da el mismo residuo vuelta a vuelta (175 → 77 → 29.6 → 8.58 → 1.33 → 0.043 → 3.7·10⁻⁵ → 2.4·10⁻¹¹ kN); Hekatan OpenSees (truss): 60.0000 y 90.0000 mm.
#: **El mapa del residuo**: para cada (u₁, u₂), cuánto falta. Primero en 3D (x = u₁, y = u₂ en mm), luego en planta:
R_2n(x, y) = sqrt((90 - F_a(x) + F_b(y - x))^2 + (150 - F_b(y - x))^2) '|R| [kN]
#surf(R_2n(x, y), [0 80], [0 120])
#map(R_2n(x, y), [0 80], [0 120])
o_1 = [v_0(1); v_1(1); v_2(1); v_3(1); v_4(1); v_5(1); v_6(1); v_7(1)] 'u₁ por vuelta [mm]
o_2 = [v_0(2); v_1(2); v_2(2); v_3(2); v_4(2); v_5(2); v_6(2); v_7(2)] 'u₂ por vuelta [mm]
o_n = [n_0; n_1; n_2; n_3; n_4; n_5; n_6; 0] '|R| por vuelta [kN]
g_x = o_1/8 'posición en el dibujo [-]
g_y = o_2/8 'posición en el dibujo [-]
#dibujo("El camino de Newton en el plano u₁–u₂ (mm)", ud = m, escala = auto, alto = 80)
#  flecha(0, 0, 11, 0, "fina")
#  flecha(0, 0, 0, 13.5, "fina")
#  texto(11, -0.5, "u₁ [mm]", 2.2, "c")
#  texto(0.3, 13.8, "u₂ [mm]", 2.2, "i")
#  texto(2.500, -0.5, "20", 2.0, "c")
#  texto(5.000, -0.5, "40", 2.0, "c")
#  texto(7.500, -0.5, "60", 2.0, "c")
#  texto(10.000, -0.5, "80", 2.0, "c")
#  texto(-0.7, 3.750, "30", 2.0, "c")
#  texto(-0.7, 7.500, "60", 2.0, "c")
#  texto(-0.7, 11.250, "90", 2.0, "c")
#  flecha(0.000, 0.000, 1.500, 2.438, "media rojo")
#  flecha(1.500, 2.438, 3.660, 5.828, "media rojo")
#  flecha(3.660, 5.828, 5.927, 9.177, "media rojo")
#  flecha(5.927, 9.177, 7.236, 10.936, "media rojo")
#  flecha(7.236, 10.936, 7.493, 11.242, "media rojo")
#  flecha(7.493, 11.242, 7.500, 11.250, "media rojo")
#  circulo(0.000, 0.000, 0.09, "rojo relleno")
#  circulo(1.500, 2.438, 0.09, "rojo relleno")
#  circulo(3.660, 5.828, 0.09, "rojo relleno")
#  circulo(5.927, 9.177, 0.09, "rojo relleno")
#  circulo(7.236, 10.936, 0.09, "rojo relleno")
#  circulo(7.500, 11.250, 0.15, "verde relleno")
#  texto(6.000, 11.950, "solución (60, 90)", 2.2, "c")
#  hover(g_x, g_y, "u₁ = {#1:4} mm, u₂ = {#2:4} mm, |R| = {#3:4} kN", o_1, o_2, o_n)
#fin

## 5 · 3 GDL: tres elementos en serie
#: Tres elementos (fuerzas máximas 300, 250 y 200 kN), cargas 40, 50 y 150 kN en los nudos 2, 3 y 4. Con tres incógnitas, Kₜ es **3 × 3 y tridiagonal**: cada elemento solo toca a sus dos nudos. Con símbolos (t₁, t₂, t₃ = rigidez tangente de cada elemento):
K_3s = Simplify{[t_1 + t_2, -t_2, 0; -t_2, t_2 + t_3, -t_3; 0, -t_3, t_3]}
#: (Se arma igual que antes: el elemento e suma tₑ·[1, −1; −1, 1] en las filas y columnas de sus nudos.)
F_c(x) = k_0*x/(1 + k_0*abs(x)/250) 'fuerza del elemento con Nu = 250 kN [kN]
T_c(x) = k_0/(1 + k_0*abs(x)/250)^2 'su rigidez tangente [kN/mm]
Q_3(x, y, z) = [F_a(x) - F_c(y - x); F_c(y - x) - F_b(z - y); F_b(z - y)] 'fuerzas internas [kN]
K_3(x, y, z) = [T_a(x) + T_c(y - x), -T_c(y - x), 0; -T_c(y - x), T_c(y - x) + T_b(z - y), -T_b(z - y); 0, -T_b(z - y), T_b(z - y)] 'matriz tangente [kN/mm]
F_3 = [40; 50; 150] 'cargas [kN]
y_0 = [0; 0; 0] 'u inicial [mm]
#: **Vuelta 1, paso a paso** (u = y_0 en mm). Paso 2, deformación de cada elemento (igual en todos sus puntos de Gauss):
epsilon_1 = y_0(1)/1000/L_e 'ε del elemento 1 = (u_j − u_i)/L [-]
sigma_1 = E_y*epsilon_1/(1 + E_y*abs(epsilon_1)/300) 'σ(ε), σᵤ = 300 kPa [kPa]
E_t1 = E_y/(1 + E_y*abs(epsilon_1)/300)^2 'Eₜ = dσ/dε [kPa]
epsilon_2 = (y_0(2) - y_0(1))/1000/L_e 'ε del elemento 2 = (u_j − u_i)/L [-]
sigma_2 = E_y*epsilon_2/(1 + E_y*abs(epsilon_2)/250) 'σ(ε), σᵤ = 250 kPa [kPa]
E_t2 = E_y/(1 + E_y*abs(epsilon_2)/250)^2 'Eₜ = dσ/dε [kPa]
epsilon_3 = (y_0(3) - y_0(2))/1000/L_e 'ε del elemento 3 = (u_j − u_i)/L [-]
sigma_3 = E_y*epsilon_3/(1 + E_y*abs(epsilon_3)/200) 'σ(ε), σᵤ = 200 kPa [kPa]
E_t3 = E_y/(1 + E_y*abs(epsilon_3)/200)^2 'Eₜ = dσ/dε [kPa]
#: Fuerza y rigidez de cada elemento con la suma de Gauss (1D: 2 puntos · Q4: 4 · H8: 8; las tres dan lo mismo):
N_bar1 = 2*(1/L_e)*sigma_1*A_s*(L_e/2) 'barra 1D [kN]
N_quad1 = 4*(1/L_e)*sigma_1*(L_e/2)*(1/2) 'Q4 [kN]
N_hex1 = 8*(1/L_e)*sigma_1*(L_e/2)*(1/2)*(1/2) 'H8 [kN]
r_bar1 = 2*(1/L_e)*E_t1*(1/L_e)*A_s*(L_e/2)/1000 'kₜ del elemento 1 (igual en Q4 y H8) [kN/mm]
N_bar2 = 2*(1/L_e)*sigma_2*A_s*(L_e/2) 'barra 1D [kN]
N_quad2 = 4*(1/L_e)*sigma_2*(L_e/2)*(1/2) 'Q4 [kN]
N_hex2 = 8*(1/L_e)*sigma_2*(L_e/2)*(1/2)*(1/2) 'H8 [kN]
r_bar2 = 2*(1/L_e)*E_t2*(1/L_e)*A_s*(L_e/2)/1000 'kₜ del elemento 2 (igual en Q4 y H8) [kN/mm]
N_bar3 = 2*(1/L_e)*sigma_3*A_s*(L_e/2) 'barra 1D [kN]
N_quad3 = 4*(1/L_e)*sigma_3*(L_e/2)*(1/2) 'Q4 [kN]
N_hex3 = 8*(1/L_e)*sigma_3*(L_e/2)*(1/2)*(1/2) 'H8 [kN]
r_bar3 = 2*(1/L_e)*E_t3*(1/L_e)*A_s*(L_e/2)/1000 'kₜ del elemento 3 (igual en Q4 y H8) [kN/mm]
f_v = 1*[N_bar1 - N_bar2; N_bar2 - N_bar3; N_bar3] 'paso 3: fᵢₙₜ ensamblada [kN]
K_m = 1*[r_bar1 + r_bar2, -r_bar2, 0; -r_bar2, r_bar2 + r_bar3, -r_bar3; 0, -r_bar3, r_bar3] 'paso 5: Kₜ ensamblada [kN/mm]
R_v = F_3 - f_v 'R = F − fᵢₙₜ [kN]
n_v = sqrt(R_v(1)^2 + R_v(2)^2 + R_v(3)^2) '|R| [kN]
D_v = lsolve(K_m, R_v) 'resolver Kₜ·Δu = R [mm]
u_v = y_0 + D_v 'paso 6: u nuevo = u + Δu [mm]
y_1 = u_v 'u₁ [mm]
#: **Vuelta 2, paso a paso** (u = y_1 en mm). Paso 2, deformación de cada elemento (igual en todos sus puntos de Gauss):
epsilon_1 = y_1(1)/1000/L_e 'ε del elemento 1 = (u_j − u_i)/L [-]
sigma_1 = E_y*epsilon_1/(1 + E_y*abs(epsilon_1)/300) 'σ(ε), σᵤ = 300 kPa [kPa]
E_t1 = E_y/(1 + E_y*abs(epsilon_1)/300)^2 'Eₜ = dσ/dε [kPa]
epsilon_2 = (y_1(2) - y_1(1))/1000/L_e 'ε del elemento 2 = (u_j − u_i)/L [-]
sigma_2 = E_y*epsilon_2/(1 + E_y*abs(epsilon_2)/250) 'σ(ε), σᵤ = 250 kPa [kPa]
E_t2 = E_y/(1 + E_y*abs(epsilon_2)/250)^2 'Eₜ = dσ/dε [kPa]
epsilon_3 = (y_1(3) - y_1(2))/1000/L_e 'ε del elemento 3 = (u_j − u_i)/L [-]
sigma_3 = E_y*epsilon_3/(1 + E_y*abs(epsilon_3)/200) 'σ(ε), σᵤ = 200 kPa [kPa]
E_t3 = E_y/(1 + E_y*abs(epsilon_3)/200)^2 'Eₜ = dσ/dε [kPa]
#: Fuerza y rigidez de cada elemento con la suma de Gauss (1D: 2 puntos · Q4: 4 · H8: 8; las tres dan lo mismo):
N_bar1 = 2*(1/L_e)*sigma_1*A_s*(L_e/2) 'barra 1D [kN]
N_quad1 = 4*(1/L_e)*sigma_1*(L_e/2)*(1/2) 'Q4 [kN]
N_hex1 = 8*(1/L_e)*sigma_1*(L_e/2)*(1/2)*(1/2) 'H8 [kN]
r_bar1 = 2*(1/L_e)*E_t1*(1/L_e)*A_s*(L_e/2)/1000 'kₜ del elemento 1 (igual en Q4 y H8) [kN/mm]
N_bar2 = 2*(1/L_e)*sigma_2*A_s*(L_e/2) 'barra 1D [kN]
N_quad2 = 4*(1/L_e)*sigma_2*(L_e/2)*(1/2) 'Q4 [kN]
N_hex2 = 8*(1/L_e)*sigma_2*(L_e/2)*(1/2)*(1/2) 'H8 [kN]
r_bar2 = 2*(1/L_e)*E_t2*(1/L_e)*A_s*(L_e/2)/1000 'kₜ del elemento 2 (igual en Q4 y H8) [kN/mm]
N_bar3 = 2*(1/L_e)*sigma_3*A_s*(L_e/2) 'barra 1D [kN]
N_quad3 = 4*(1/L_e)*sigma_3*(L_e/2)*(1/2) 'Q4 [kN]
N_hex3 = 8*(1/L_e)*sigma_3*(L_e/2)*(1/2)*(1/2) 'H8 [kN]
r_bar3 = 2*(1/L_e)*E_t3*(1/L_e)*A_s*(L_e/2)/1000 'kₜ del elemento 3 (igual en Q4 y H8) [kN/mm]
f_v = 1*[N_bar1 - N_bar2; N_bar2 - N_bar3; N_bar3] 'paso 3: fᵢₙₜ ensamblada [kN]
K_m = 1*[r_bar1 + r_bar2, -r_bar2, 0; -r_bar2, r_bar2 + r_bar3, -r_bar3; 0, -r_bar3, r_bar3] 'paso 5: Kₜ ensamblada [kN/mm]
R_v = F_3 - f_v 'R = F − fᵢₙₜ [kN]
n_v = sqrt(R_v(1)^2 + R_v(2)^2 + R_v(3)^2) '|R| [kN]
D_v = lsolve(K_m, R_v) 'resolver Kₜ·Δu = R [mm]
u_v = y_1 + D_v 'paso 6: u nuevo = u + Δu [mm]
#: Las 7 vueltas seguidas:
e_0 = F_3 - Q_3(y_0(1), y_0(2), y_0(3)) 'R [kN]
m_0 = sqrt(e_0(1)^2 + e_0(2)^2 + e_0(3)^2) '|R| [kN]
z_0 = lsolve(K_3(y_0(1), y_0(2), y_0(3)), e_0) 'Δu [mm]
y_1 = y_0 + z_0 'u nuevo [mm]
e_1 = F_3 - Q_3(y_1(1), y_1(2), y_1(3)) 'R [kN]
m_1 = sqrt(e_1(1)^2 + e_1(2)^2 + e_1(3)^2) '|R| [kN]
z_1 = lsolve(K_3(y_1(1), y_1(2), y_1(3)), e_1) 'Δu [mm]
y_2 = y_1 + z_1 'u nuevo [mm]
e_2 = F_3 - Q_3(y_2(1), y_2(2), y_2(3)) 'R [kN]
m_2 = sqrt(e_2(1)^2 + e_2(2)^2 + e_2(3)^2) '|R| [kN]
z_2 = lsolve(K_3(y_2(1), y_2(2), y_2(3)), e_2) 'Δu [mm]
y_3 = y_2 + z_2 'u nuevo [mm]
e_3 = F_3 - Q_3(y_3(1), y_3(2), y_3(3)) 'R [kN]
m_3 = sqrt(e_3(1)^2 + e_3(2)^2 + e_3(3)^2) '|R| [kN]
z_3 = lsolve(K_3(y_3(1), y_3(2), y_3(3)), e_3) 'Δu [mm]
y_4 = y_3 + z_3 'u nuevo [mm]
e_4 = F_3 - Q_3(y_4(1), y_4(2), y_4(3)) 'R [kN]
m_4 = sqrt(e_4(1)^2 + e_4(2)^2 + e_4(3)^2) '|R| [kN]
z_4 = lsolve(K_3(y_4(1), y_4(2), y_4(3)), e_4) 'Δu [mm]
y_5 = y_4 + z_4 'u nuevo [mm]
e_5 = F_3 - Q_3(y_5(1), y_5(2), y_5(3)) 'R [kN]
m_5 = sqrt(e_5(1)^2 + e_5(2)^2 + e_5(3)^2) '|R| [kN]
z_5 = lsolve(K_3(y_5(1), y_5(2), y_5(3)), e_5) 'Δu [mm]
y_6 = y_5 + z_5 'u nuevo [mm]
e_6 = F_3 - Q_3(y_6(1), y_6(2), y_6(3)) 'R [kN]
m_6 = sqrt(e_6(1)^2 + e_6(2)^2 + e_6(3)^2) '|R| [kN]
z_6 = lsolve(K_3(y_6(1), y_6(2), y_6(3)), e_6) 'Δu [mm]
y_7 = y_6 + z_6 'u nuevo [mm]
e_7 = F_3 - Q_3(y_7(1), y_7(2), y_7(3)) 'residuo final [kN]
#: **u = (60, 110, 140) mm en 7 vueltas**; Q4 y H8 dan el mismo residuo (163 → 71.1 → 26.8 → 7.44 → 1.11 → 0.036 → 3.2·10⁻⁵ → 2·10⁻¹¹ kN); Hekatan OpenSees (truss): 60.0000, 110.0000 y 140.0000 mm.
#: **La convergencia de los tres casos** (eje horizontal: la vuelta; vertical: log₁₀|R|). Los tres caen igual de rápido: al final, cada vuelta **duplica las cifras correctas**:
H_1 = [0, log10(abs(q_0)); 1, log10(abs(q_1)); 2, log10(abs(q_2)); 3, log10(abs(q_3)); 4, log10(abs(q_4)); 5, log10(abs(q_5)); 6, log10(abs(q_6)); 7, log10(abs(q_7))] '1 GDL
H_2 = [0, log10(n_0); 1, log10(n_1); 2, log10(n_2); 3, log10(n_3); 4, log10(n_4); 5, log10(n_5); 6, log10(n_6)] '2 GDL
H_3 = [0, log10(m_0); 1, log10(m_1); 2, log10(m_2); 3, log10(m_3); 4, log10(m_4); 5, log10(m_5); 6, log10(m_6)] '3 GDL
#fplot(GDL1 = H_1, GDL2 = H_2, GDL3 = H_3, [0 7])
#: El residuo en 3D cuando u₃ ya está en su valor (140 mm), en función de u₁ y u₂:
R_3n(x, y) = sqrt((40 - F_a(x) + F_c(y - x))^2 + (50 - F_c(y - x) + F_b(140 - y))^2 + (150 - F_b(140 - y))^2) '|R| [kN]
#surf(R_3n(x, y), [0 90], [40 140])

## 6 · Anexo: 2 GDL con barras inclinadas (la cercha de la hoja 196)
#: La misma barra de 2 nudos, pero **girada**: su alargamiento es la proyección del movimiento del nudo sobre la barra, δ = c·u₁ + s·u₂ (c y s = coseno y seno). Entonces Kₑ = t·[c², c·s; c·s, s²] y la cercha de dos barras con P = 300 kN y H = 30 kN da u = (−11.6921, −37.2085) mm en 7 vueltas (hoja 196, y los 7 lenguajes del video).
K_r = Simplify{t*[c^2, c*s; c*s, s^2]}

## 7 · En una línea
#: **1 incógnita: Δ u = R/kₜ. 2 o 3 incógnitas: Kₜ·Δ u = R, con Kₜ ensamblada de los elementos.** La barra, el área y el sólido dan lo mismo con ν = 0 porque sus funciones de forma, con la cara atada, se reducen a la misma recta (N₂ + N₃ = (1 + ξ)/2). Con ν ≠ 0 cambia la rigidez según lo que se deje mover a los lados (E, E/(1 − ν²) o el edométrico). Lo mismo, con miles de incógnitas y el suelo en vez del acero, es el talud de las hojas 190 y 195.
