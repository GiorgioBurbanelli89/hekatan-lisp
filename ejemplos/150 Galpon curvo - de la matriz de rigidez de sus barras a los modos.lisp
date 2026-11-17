# Galpón curvo: de la matriz de rigidez de sus barras a los modos
#: **Qué explica esta hoja.** El galpón curvo de Hekatan Struct (luz 20 m, 6 pórticos, columnas CFT, cerchas en los dos sentidos) tiene **443 barras** y **214 nudos**: **1284 grados de libertad** (6 por nudo). Toda su respuesta (flechas, reacciones, modos) sale de **una sola ecuación, K·u = F**. Aquí se ve **de dónde sale esa K**: se arma una barra, se gira, se suma con las demás y se llega a los periodos que se animan en el ejemplo 147.
#: **Orden:** 1) la rigidez de UNA barra en símbolos; 2) los números de una columna del galpón; 3) cómo se gira a los ejes globales; 4) cómo se suman dos barras (ensamblaje) y se comprueba contra la fórmula de siempre; 5) del K al modo: **K·φ = ω²·M·φ**.
#: **Unidades:** kN y m. Los datos de la columna son los del modelo del galpón (tubo CFT 250 × 250 × 8, acero E = 2·10⁸ kN/m², de 6 m).

## 1 · La rigidez de una barra, en símbolos

#: Una barra de pórtico tiene 2 nudos y 6 movimientos por nudo (u, v, w, θx, θy, θz): su matriz de rigidez es de **12 × 12**. No es una sola fórmula: son **cuatro físicas que no se mezclan**, cada una con su propia forma de interpolar el movimiento a lo largo de la barra (s = x/L, de 0 a 1).
#: **Axial** y **torsión**: el movimiento varía en línea recta, N = [1 − s, s]. La rigidez es la energía de deformación, k = EA·∫ B′ᵀ·B′ dx:
k_ax = Simplify{E*A/L*Area{transpose([Partial{1-s @ s}, Partial{s @ s}])*[Partial{1-s @ s}, Partial{s @ s}] @ s = 0 : 1}}
#: Es el resorte de siempre, **EA/L**: si la barra se estira 1, hace falta esa fuerza. En torsión es lo mismo con **GJ/L** en lugar de EA/L:
k_tor = Simplify{G*J/L*Area{transpose([Partial{1-s @ s}, Partial{s @ s}])*[Partial{1-s @ s}, Partial{s @ s}] @ s = 0 : 1}}
#: **Flexión**: la barra se dobla como una cúbica; sus cuatro formas (desplazamiento y giro en cada extremo) son las cúbicas de Hermite. La curvatura es la segunda derivada y la rigidez es la energía de flexión, k = EI·∫ Bᵀ·B dx:
B_fl = Simplify{[Partial{Partial{1-3*s^2+2*s^3 @ s} @ s}, Partial{Partial{L*(s-2*s^2+s^3) @ s} @ s}, Partial{Partial{3*s^2-2*s^3 @ s} @ s}, Partial{Partial{L*(s^3-s^2) @ s} @ s}]}
k_EB = Simplify{E*I/L^3*Area{transpose(B_fl)*B_fl @ s = 0 : 1}}
#: La diagonal vale 12EI/L³ (cuánta fuerza cuesta mover un extremo 1 sin girarlo) y 4EI/L (cuánto momento cuesta girarlo 1). **Timoshenko** añade la deformación por cortante con el parámetro φ = 12·EI/(G·A_s·L²), que hace la barra un poco más blanda cuando es corta y gruesa (A_s = 5/6·A):
φ_s = Simplify{12*E*I/(G*A_s*L^2)}
k_Ti = Simplify{E*I/(L^3*(1+phi))*[12, 6*L, -12, 6*L; 6*L, (4+phi)*L^2, -6*L, (2-phi)*L^2; -12, -6*L, 12, -6*L; 6*L, (2-phi)*L^2, -6*L, (4+phi)*L^2]}
#: Las 12 filas y columnas se arman poniendo cada bloque en sus grados de libertad: k_{ax} en (u₁, u₂), k_{tor} en (θx₁, θx₂), la flexión con I_{z} en (v, θz) y con I_{y} en (w, θy) (en este último plano los términos cruzados cambian de signo porque θy = −∂w/∂x). Todo lo demás es cero: **una barra no acopla** el estiramiento con la flexión.

## 2 · Los números de una columna del galpón

#: Primera columna del modelo: tubo CFT 250 × 250 × 8 de 6 m, empotrada abajo. Sus datos (de `frame 1` del modelo de Hekatan Struct): E = 2·10⁸ kN/m², A = 0.007744 m², I = 7.5669·10⁻⁵ m⁴, J = 1.1338·10⁻⁴ m⁴, ν = 0.3 y L = 6 m. El relleno de hormigón del CFT suma rigidez que esta hoja deja fuera para ver lo esencial: el acero solo.
#numerico
E_s = 200000000 'módulo de elasticidad del acero (kN/m²)
nu_s = 0.3 'coeficiente de Poisson
G_s = E_s/(2*(1+nu_s)) 'módulo de corte (kN/m²)
A_c = 0.007744 'área de la sección (m²)
I_c = 0.000075669205 'inercia a flexión (m⁴)
J_c = 0.0001133799 'constante de torsión (m⁴)
L_c = 6 'longitud de la columna (m)
#: Los términos de la diagonal, evaluados con esos datos. **Axial**: cuánta fuerza axial cuesta acortar la columna 1 m (kN/m). **Torsión**: momento por radián (kN·m). **Flexión**: fuerza para desplazar el extremo 1 m sin girarlo (kN/m) y momento para girarlo 1 rad (kN·m):
kax_c = E_s*A_c/L_c 'EA/L (kN/m)
ktor_c = G_s*J_c/L_c 'GJ/L (kN·m/rad)
kv_c = 12*E_s*I_c/L_c^3 '12EI/L³ (kN/m)
kth_c = 4*E_s*I_c/L_c '4EI/L (kN·m/rad)
#: La columna es **mucho más rígida axialmente que a flexión**: EA/L es unas 300 veces 12EI/L³. Por eso casi todo el movimiento del galpón es de flexión, y la cubierta cede por los pórticos, no por acortarse las columnas.
rel_ax = kax_c/kv_c 'cuántas veces es más rígida axialmente que a flexión

## 3 · De los ejes de la barra a los ejes del modelo

#: Las matrices de arriba están en los **ejes locales** de la barra (x a lo largo de ella). El modelo vive en ejes globales (X, Y, Z), así que cada barra se gira con sus **cosenos directores**: K_{global} = Tᵀ·k·T, donde T repite 4 veces la matriz de 3 × 3 de la rotación en la diagonal. Para una columna vertical, x local = Z global:
λ_c = Simplify{[0, 0, 1; 0, 1, 0; -1, 0, 0]}
#: En una barra inclinada de la cercha (cordón o diagonal) con extremos (x₁, y₁, z₁) y (x₂, y₂, z₂), el primer eje es el vector unitario de la barra, **e₁ = (P₂ − P₁)/L**, y los otros dos salen de ortogonalizarlo con la vertical. **Es lo único que cambia entre las 443 barras**: sus datos de sección y su orientación.

## 4 · Dos barras en serie: el ensamblaje

#: Un nudo compartido recibe la rigidez de **todas las barras que llegan a él**: se **suman** en el mismo grado de libertad. Para verlo sin 1284 filas, se toma la columna dividida en dos barras iguales de largo L (en el plano de flexión, 2 movimientos por nudo: desplazamiento y giro). La matriz global es de 6 × 6; la de la barra de abajo ocupa los nudos 1-2 y la de arriba los nudos 2-3, y se **superponen en el nudo 2**:
k_b = Simplify{E*I/L^3*[12, 6*L, -12, 6*L; 6*L, 4*L^2, -6*L, 2*L^2; -12, -6*L, 12, -6*L; 6*L, 2*L^2, -6*L, 4*L^2]}
K_6 = Simplify{E*I/L^3*[12, 6*L, -12, 6*L, 0, 0; 6*L, 4*L^2, -6*L, 2*L^2, 0, 0; -12, -6*L, 24, 0, -12, 6*L; 6*L, 2*L^2, 0, 8*L^2, -6*L, 2*L^2; 0, 0, -12, -6*L, 12, -6*L; 0, 0, 6*L, 2*L^2, -6*L, 4*L^2]}
#: Mira el centro: 12 + 12 = **24** y 4L² + 4L² = **8L²**. Son las dos barras sumadas en el nudo 2. El nudo 1 es el empotramiento (u = θ = 0): se **eliminan sus dos filas y columnas** y queda un sistema de 4 × 4 en (u₂, θ₂, u₃, θ₃):
K_4 = Simplify{E*I/L^3*[24, 0, -12, 6*L; 0, 8*L^2, -6*L, 2*L^2; -12, -6*L, 12, -6*L; 6*L, 2*L^2, -6*L, 4*L^2]}
#: Se aplica una fuerza lateral P en el extremo libre (nudo 3) y se resuelve **K·u = F**. La flecha del extremo tiene que dar la fórmula de la resistencia de materiales para un voladizo de largo 2L, P·(2L)³/(3EI) = 8·P·L³/(3·E·I):
u_4 = Simplify{inv(K_4)*[0; 0; P; 0]}
#: El tercer valor es u₃, la flecha de la punta. **Coincide exactamente con 8PL³/(3EI)**: la matriz de rigidez reproduce la teoría de vigas, y con dos elementos cúbicos es exacta (la solución es una cúbica). En el galpón el procedimiento es idéntico, solo que el vector tiene 1284 filas.
u_ref = Simplify{8*P*L^3/(3*E*I)}

## 5 · Del K al modo de vibración

#: Sin fuerzas externas, la ecuación del movimiento es **M·ü + K·u = 0**. Se prueba u = φ·cos(ω·t) y queda el **problema de valores propios**: **K·φ = ω²·M·φ**. Solo hay solución distinta de cero cuando det(K − ω²·M) = 0: ese polinomio (de grado 1284 en el galpón) tiene una raíz por modo. De ω sale el periodo, T = 2π/ω.
#: Con la columna de arriba, empotrada y con una masa m en la punta, hay un solo grado de libertad y la rigidez lateral es la de un voladizo, 3EI/L³. El periodo es **T = 2π·√(m/k)**:
k_lat = 3*E_s*I_c/L_c^3 'rigidez lateral de la columna en voladizo (kN/m)
m_p = 20 'masa en la punta, ejemplo (t = kN·s²/m)
T_c = 2*pi*sqrt(m_p/k_lat) 'periodo de esa columna con su masa (s)
#: El galpón completo tiene miles de grados de libertad y masas repartidas, pero **el principio es el mismo**: cada modo es una masa equivalente sobre un resorte equivalente. Hekatan Struct y Hekatan OpenSees arman el K de las 443 barras y el M de las masas, resuelven el problema de valores propios y dan T₁ = 0.3309 s, T₂ = 0.3237 s y T₃ = 0.2786 s: **los periodos que se animan en el ejemplo 147**.
#: **Dónde seguir:** la matriz de la cubierta de zinc (cáscara de membrana + flexión, 24 × 24 por chapa) se deduce en el ejemplo 83; la rigidez y la masa de una barra hasta el modal y la masa participativa, en el 149; los brazos rígidos de SAP2000 y ETABS en las uniones, en el 111.
