# Funciones de forma T3 y T6 a fondo - coordenadas de area, matriz C, propiedades, Jacobiano, Gauss en triangulos y el mismo voladizo
#numerico

## 0 · La idea
#: Igual que en el cuadrilátero (hoja 204): cada función de forma **Nᵢ vale 1 en su nudo y 0 en los demás**, y todas **suman 1**. El triángulo tiene una ventaja: con triángulos se malla **cualquier** forma (un talud, una zapata con esquinas, un muro con huecos). Por eso PLAXIS, GEO5 y GeoFEM usan triángulos.
#: La hoja 201 presentó el T3 y el T6 y la 204 hizo el Q4, Q8 y Q9. Aquí se va **más a fondo** en el triángulo: las **coordenadas de área** L₁, L₂, L₃, el T6 escrito con ellas, el T10, el Jacobiano de un triángulo real, la cuadratura de Gauss **en triángulos** (que no es la del cuadrado) y el mismo voladizo de la 204.
#dibujo("La familia del triángulo: vértices (1-3, negro), mitad de los lados (4-6, azul), tercios de lado y centro del T10 (gris y rojo). Referencia: ξ, η de 0 a 1", ud = m, escala = auto, alto = 70)
#  poligono(0, 0, 2, 0, 0, 2, "gruesa")
#  poligono(3, 0, 5, 0, 3, 2, "gruesa")
#  poligono(6, 0, 8, 0, 6, 2, "gruesa")
#  circulo(0, 0, 0.1, "negro")
#  circulo(2, 0, 0.1, "negro")
#  circulo(0, 2, 0.1, "negro")
#  texto(-0.25, -0.3, "1", 2.4, "c")
#  texto(2.25, -0.3, "2", 2.4, "c")
#  texto(-0.25, 2.25, "3", 2.4, "c")
#  circulo(3, 0, 0.1, "negro")
#  circulo(5, 0, 0.1, "negro")
#  circulo(3, 2, 0.1, "negro")
#  circulo(4, 0, 0.1, "azul")
#  circulo(4, 1, 0.1, "azul")
#  circulo(3, 1, 0.1, "azul")
#  texto(2.75, -0.3, "1", 2.4, "c")
#  texto(5.25, -0.3, "2", 2.4, "c")
#  texto(2.75, 2.25, "3", 2.4, "c")
#  texto(4, -0.35, "4", 2.4, "c")
#  texto(4.3, 1.2, "5", 2.4, "c")
#  texto(2.7, 1, "6", 2.4, "c")
#  circulo(6, 0, 0.1, "negro")
#  circulo(8, 0, 0.1, "negro")
#  circulo(6, 2, 0.1, "negro")
#  circulo(6.667, 0, 0.08, "gris")
#  circulo(7.333, 0, 0.08, "gris")
#  circulo(7.333, 0.667, 0.08, "gris")
#  circulo(6.667, 1.333, 0.08, "gris")
#  circulo(6, 1.333, 0.08, "gris")
#  circulo(6, 0.667, 0.08, "gris")
#  circulo(6.667, 0.667, 0.1, "rojo")
#  texto(1, -0.8, "T3 lineal (CST)", 2.6, "c")
#  texto(4, -0.8, "T6 cuadrático (LST)", 2.6, "c")
#  texto(7, -0.8, "T10 cúbico", 2.6, "c")
#fin
#: **De dónde se parte.** **¿Qué sé?** el desplazamiento de los nudos. **¿Qué quiero?** saberlo dentro del triángulo. **¿Qué propongo?** un polinomio con tantas constantes como nudos: 3 (grado 1 completo) o 6 (grado 2 completo); en el triángulo las filas del triángulo de Pascal entran **enteras**. **¿Qué exijo?** que en cada nudo valga lo del nudo (C·a = u). **¿Qué sale?** Nᵢ = base·(columna i de C⁻¹). **¿Para qué?** B = ∂N/∂x y K = ∫Bᵀ·D·B dA. El triángulo de referencia (ξ, η de 0 a 1) es el mismo para todos; el Jacobiano lo lleva al triángulo real.
#: Nudos del triángulo de referencia: 1 (0, 0), 2 (1, 0), 3 (0, 1); mitades 4 (½, 0), 5 (½, ½), 6 (0, ½). CST = *constant strain triangle* (deformación constante), LST = *linear strain triangle* (deformación lineal).

## 1 · T3: tres planos y las coordenadas de área
#: La base es [1, ξ, η] (grado 1 completo). Cada fila de C es la base en un vértice:
C_3 = [1, 0, 0; 1, 1, 0; 1, 0, 1] 'filas: nudos 1, 2, 3
d_3 = det(C_3) 'distinto de 0
C_3i = inv(C_3) 'columna j = coeficientes de Nⱼ
N_T3 = Simplify{[1, xi, eta]*inv([1, 0, 0; 1, 1, 0; 1, 0, 1])}
#: **N₁ = 1 − ξ − η, N₂ = ξ, N₃ = η**. Tienen un significado geométrico precioso: un punto P parte el triángulo en tres; **Lᵢ = (área del triángulo opuesto al vértice i) / (área total)**. Si P está en el vértice 1, el triángulo opuesto es todo: L₁ = 1. Si P está en el lado 2-3, ese triángulo desaparece: L₁ = 0.
#dibujo("Coordenadas de área: L₁ = A₁/A, L₂ = A₂/A, L₃ = A₃/A (Aᵢ es el triángulo OPUESTO al vértice i)", ud = m, escala = auto, alto = 55)
#  poligono(0, 0, 4, 0, 1.2, 3, "gruesa")
#  linea(1.6, 1, 0, 0, "trazos")
#  linea(1.6, 1, 4, 0, "trazos")
#  linea(1.6, 1, 1.2, 3, "trazos")
#  circulo(1.6, 1, 0.08, "rojo")
#  texto(1.85, 1.15, "P", 2.6, "c")
#  texto(-0.25, -0.25, "1", 2.4, "c")
#  texto(4.25, -0.25, "2", 2.4, "c")
#  texto(1.2, 3.3, "3", 2.4, "c")
#  texto(2.3, 1.45, "A₁", 2.4, "c")
#  texto(0.95, 1.4, "A₂", 2.4, "c")
#  texto(1.9, 0.35, "A₃", 2.4, "c")
#fin
#: El motor comprueba con un punto P = (ξ, η): el área del triángulo P-2-3 sobre el área total (½) da 1 − ξ − η:
A_1 = Simplify{((1 - xi)*(1 - eta) - (0 - eta)*(0 - xi))/2} 'área de P-2-3 = ½·|(2 − P) × (3 − P)|
r_1 = Simplify{((1 - xi)*(1 - eta) - eta*xi)/2/(1/2)} 'A₁/A = L₁
#: N₁ del T3 en 3D: un **plano** inclinado (x = ξ, y = η; arrastra para girar):
#surf(max(0, 1 - x - y), [0 1], [0 1])
#: Sus derivadas son **constantes**: dentro del T3 la deformación no varía (por eso CST):
g_1 = Simplify{Diff{1 - xi - eta @ xi}} '∂N₁/∂ξ
g_2 = Simplify{Diff{1 - xi - eta @ eta}} '∂N₁/∂η

## 2 · T6: el grado 2 completo
#: Seis nudos piden seis términos: [1, ξ, η, ξ², ξη, η²], la fila 2 del triángulo de Pascal entera. C es 6 × 6 (nudos 1…6):
C_6 = [1, 0, 0, 0, 0, 0; 1, 1, 0, 1, 0, 0; 1, 0, 1, 0, 0, 1; 1, 0.5, 0, 0.25, 0, 0; 1, 0.5, 0.5, 0.25, 0.25, 0.25; 1, 0, 0.5, 0, 0, 0.25]
d_6 = det(C_6) '1/64: distinto de 0
C_6i = inv(C_6) 'columna j = coeficientes de Nⱼ
N_T6 = Simplify{[1, xi, eta, xi^2, xi*eta, eta^2]*inv([1, 0, 0, 0, 0, 0; 1, 1, 0, 1, 0, 0; 1, 0, 1, 0, 0, 1; 1, 1/2, 0, 1/4, 0, 0; 1, 1/2, 1/2, 1/4, 1/4, 1/4; 1, 0, 1/2, 0, 0, 1/4])}
#: Con las coordenadas de área quedan cortas y simétricas: **vértice Nᵢ = Lᵢ(2Lᵢ − 1)**, **lado N₄ = 4L₁L₂** (y N₅ = 4L₂L₃, N₆ = 4L₃L₁). El motor expande las dos formas para compararlas (vértice 1 y lado 4):
n_61 = Simplify{[1, xi, eta, xi^2, xi*eta, eta^2]*[1; -3; -3; 2; 4; 2]} 'base · columna 1 de C⁻¹
f_61 = Simplify{(1 - xi - eta)*(2*(1 - xi - eta) - 1)} 'L₁(2L₁ − 1) expandido: igual
n_64 = Simplify{[1, xi, eta, xi^2, xi*eta, eta^2]*[0; 4; 0; -4; -4; 0]} 'base · columna 4 de C⁻¹
f_64 = Simplify{4*(1 - xi - eta)*xi} '4L₁L₂ expandido: igual
#: El vértice del T6 en 3D: vale 1 en su vértice, 0 en los otros 5 nudos y **se hace negativo** (hasta −1/8, sobre la recta L₁ = ¼; en el centroide vale −1/9):
#surf((1 - x - y)*(2*(1 - x - y) - 1)*min(1, max(0, (1 - x - y)*1000)), [0 1], [0 1])
c_6 = (1 - 1/3 - 1/3)*(2*(1 - 1/3 - 1/3) - 1) 'N₁ en el centroide
m_6 = 0.25*(2*0.25 - 1) 'mínimo, con L₁ = ¼
#: El nudo de lado N₄ = 4ξ(1 − ξ − η), una carpa sobre el lado 1-2:
#surf(max(0, 4*x*(1 - x - y)), [0 1], [0 1])
#: Corte por el lado 1-2 (η = 0): las tres funciones del lado son **las parábolas de Lagrange** con nudos en 0, ½ y 1 (las mismas del Q9, escaladas):
#fplot(N_1 = (1 - x)*(1 - 2*x), N_4 = 4*x*(1 - x), N_2 = x*(2*x - 1), nudos = [0 1; 0.5 1; 1 1; 0 0; 0.5 0; 1 0], [0 1])
#: ∂N₄/∂ξ ya **no es constante**: la deformación del T6 varía linealmente (LST):
g_4 = Simplify{Diff{4*xi*(1 - xi - eta) @ xi}} '∂N₄/∂ξ

## 3 · T10 (cúbico), en una línea
#: Con 10 nudos (vértices, dos por lado en los tercios y el **centroide**) la base es el grado 3 completo, 10 términos. Deducidas con C⁻¹ en Python (sympy, juez de esta hoja): **vértice Lᵢ(3Lᵢ − 1)(3Lᵢ − 2)/2**, **centro 27L₁L₂L₃**. La «burbuja» del centro, que vale 1 en el centroide y 0 en todo el borde:
b_10 = 27*(1/3)*(1/3)*(1/3) 'en el centroide
#surf(max(0, 27*x*y*(1 - x - y)), [0 1], [0 1])
#: PLAXIS usa además el T15 (grado 4). Cuanto más alto el grado, más exacto con pocos elementos, pero más caro cada uno.

## 4 · Propiedades
#: **ΣN = 1**: igual que en el cuadrilátero, la primera columna de C es de unos, así que C⁻¹·[1; …; 1] = [1; 0; …] y la suma vale 1:
s_3 = Simplify{[1, xi, eta]*(inv([1, 0, 0; 1, 1, 0; 1, 0, 1])*[1; 1; 1])} 'ΣN del T3
c_s6 = inv(C_6)*[1; 1; 1; 1; 1; 1] 'C⁻¹·unos
s_6 = Simplify{[1, xi, eta, xi^2, xi*eta, eta^2]*[1; 0; 0; 0; 0; 0]} 'ΣN del T6
#: **Completitud**: con los valores ξᵢ en los nudos devuelven ξ. ¿Y ξ²? Truco: en los vértices ξᵢ vale 0 o 1, así que ξᵢ² = ξᵢ y el **T3 devuelve ξ, no ξ²** (no puede curvarse). El T6 tiene los nudos de lado (ξ = ½ → ξ² = ¼) y devuelve ξ²:
p_3 = Simplify{[1, xi, eta]*(inv([1, 0, 0; 1, 1, 0; 1, 0, 1])*[0; 1; 0])} 'ΣNᵢξᵢ² del T3 = ξ
c_p6 = inv(C_6)*[0; 1; 0; 0.25; 0.25; 0] 'C⁻¹·ξᵢ²
p_6 = Simplify{[1, xi, eta, xi^2, xi*eta, eta^2]*[0; 0; 0; 1; 0; 0]} 'ΣNᵢξᵢ² del T6 = ξ²
#: Interpolando ξ² a lo largo del lado η = 0: el T3 da la cuerda (recta), el T6 la parábola exacta:
#fplot(exacta = x^2, T3 = x, T6 = x^2 + 0*x, nudos_T6 = [0 0; 0.5 0.25; 1 1], [0 1])

## 5 · Jacobiano de un triángulo real (m)
#dibujo("T3 real: nudos 1 (0, 0), 2 (3, 0.5), 3 (1, 2) m", ud = m, escala = auto, cotas = m, alto = 50)
#  poligono(0, 0, 3, 0.5, 1, 2, "gruesa")
#  circulo(0, 0, 0.05, "negro")
#  circulo(3, 0.5, 0.05, "negro")
#  circulo(1, 2, 0.05, "negro")
#  texto(-0.15, -0.2, "1", 2.4, "c")
#  texto(3.2, 0.4, "2", 2.4, "c")
#  texto(1, 2.25, "3", 2.4, "c")
#  cota(0, -0.5, 3, -0.5, 0, "3 m")
#  cota(3.4, 0, 3.4, 2, 0, "2 m")
#fin
x_t = Simplify{[1, xi, eta]*(inv([1, 0, 0; 1, 1, 0; 1, 0, 1])*[0; 3; 1])} 'x(ξ, η) [m]
y_t = Simplify{[1, xi, eta]*(inv([1, 0, 0; 1, 1, 0; 1, 0, 1])*[0; 0.5; 2])} 'y(ξ, η) [m]
#: J = [∂x/∂ξ, ∂y/∂ξ; ∂x/∂η, ∂y/∂η] es **constante** en el T3 (todo es lineal):
J_t = [3, 0.5; 1, 2] 'J [m]
d_Jt = det(J_t) 'det J = 2·área [m²]
A_t = d_Jt/2 'área del triángulo [m²]
#: Derivadas en x e y: [∂N/∂x; ∂N/∂y] = J⁻¹·[∂N/∂ξ; ∂N/∂η], con ∂N/∂ξ = [−1, 1, 0] y ∂N/∂η = [−1, 0, 1]:
G_t = inv(J_t)*[-1, 1, 0; -1, 0, 1] '∂N/∂x y ∂N/∂y [1/m]: constantes
#: Las filas suman cero (movimiento rígido): −3/11 + 4/11 − 1/11 = 0 y −4/11 − 2/11 + 6/11 = 0. Con eso B (3 × 6) es constante: **ε es la misma en todo el triángulo**.
#: **Distorsión en el T6.** Con un lado curvo (nudo 5 corrido hacia afuera 0.3 m) det J deja de ser constante: 5.5, 7.62 y 6.35 m² en los vértices (Python). Si el nudo 4 se corre hacia el vértice 1, det J en el vértice 1 vale 5.5 (en la mitad), **0 a ¼ del lado** y **−1.1 m² a 0.2**: el elemento se da vuelta. Con el nudo 4 a 0.2 del lado, det J = 66ξ/5 + 33η/5 − 11/10 m² (Python): negativo cerca del vértice 1. Mapa en ξ–η (afuera del triángulo se pinta 0):
#map((66*x/5 + 33*y/5 - 11/10)*min(1, max(0, (1 - x - y)*1000)), [0 1], [0 1])

## 6 · Gauss en triángulos
#: Un triángulo no es un cuadrado: sus puntos de Gauss son otros. En el triángulo de referencia (área ½): **1 punto** en el centroide (⅓, ⅓) con peso ½, exacto hasta grado 1; **3 puntos** en (⅙, ⅙), (⅔, ⅙), (⅙, ⅔) con peso ⅙ cada uno, exacto hasta grado 2. En un triángulo real dA = det J·dξ·dη = 2A·dξ·dη. Una integral de grado 2:
i_2 = Simplify{2*A*Integral{xi^2*(1 - xi) @ xi = 0 : 1}} 'exacta (∫₀^{1−ξ} dη = 1 − ξ)
i_21 = Simplify{2*A*(1/2)*(1/3)^2} '1 punto: no alcanza
i_23 = Simplify{2*A*(1/6)*((1/6)^2 + (2/3)^2 + (1/6)^2)} '3 puntos: exacta
#: La rigidez del T6 (lados rectos) lleva (∂N/∂ξ)², de grado 2: necesita **3 puntos**. Con 1 solo, el término de N₄ **desaparece**: ∂N₄/∂ξ = 4(1 − 2ξ − η) vale cero justo en el centroide:
k_4 = Simplify{2*A*Integral{16/3*((1 - 2*xi)^3 + xi^3) @ xi = 0 : 1}} 'exacta (∫₀^{1−ξ}16(1 − 2ξ − η)² dη = 16[(1 − 2ξ)³ + ξ³]/3)
k_41 = Simplify{2*A*(1/2)*16*(1 - 2/3 - 1/3)^2} '1 punto: el integrando vale 0 en el centroide
k_43 = Simplify{2*A*(1/6)*(16*(1 - 2/6 - 1/6)^2 + 16*(1 - 4/3 - 1/6)^2 + 16*(1 - 2/6 - 2/3)^2)} '3 puntos: exacta
#: Modos de energía nula (autovalores nulos de K, 3 son de cuerpo rígido), contados en Python:
v_a = [3, 9, 3] 'autovalores nulos
v_b = [0, 6, 0] 'modos espurios
#tabla("Elemento e integración","autovalores nulos:0","espurios:0")({"T3, 1 punto (exacto)","T6, 1 punto","T6, 3 puntos"}; v_a; v_b)
#: El T3 con 1 punto es **exacto** (su integrando es constante). El T6 con 1 punto tiene **6 modos espurios**: nunca se reduce así.

## 7 · El mismo voladizo de la hoja 204, con triángulos
#dibujo("Voladizo: L = 4 m, h = 0.5 m, t = 0.2 m, E = 25 GPa, ν = 0.2; P = 10 kN. Malla 4 × 1 celdas, cada una partida en 2 triángulos", ud = m, escala = auto, cotas = m, alto = 45)
#  achurado([-0.3, 0, 0, -0.3], [-0.45, -0.45, 0.45, 0.45], "concreto")
#  poligono(0, -0.25, 4, -0.25, 4, 0.25, 0, 0.25, "gruesa")
#  linea(1, -0.25, 1, 0.25, "fina")
#  linea(2, -0.25, 2, 0.25, "fina")
#  linea(3, -0.25, 3, 0.25, "fina")
#  linea(0, -0.25, 1, 0.25, "fina")
#  linea(1, -0.25, 2, 0.25, "fina")
#  linea(2, -0.25, 3, 0.25, "fina")
#  linea(3, -0.25, 4, 0.25, "fina")
#  flecha(4, 0.85, 4, 0.27, "gruesa rojo")
#  texto(4.25, 0.9, "P", 2.6, "c")
#  cota(0, -0.6, 4, -0.6, 0, "L = 4 m")
#fin
#: Referencia (hoja 204): **4.13736 mm**. Flecha en la punta, en mm. El T3 da lo mismo en Python y en Hekatan OpenSees (tri31) hasta 1e−12 mm; **la DLL no trae un triángulo de 6 nudos** (SixNodeTri no existe), así que el T6 se verifica solo por convergencia (malla 64 × 8: 4.13715 mm).
w_a = [0.07579, 0.20604, 0.53809, 1.50411, 2.86510] 'T3 [mm]
w_b = [1.8, 5.0, 13.0, 36.4, 69.2] '% T3
w_c = [3.14696, 3.89026, 4.07298, 4.12517, 4.13429] 'T6 [mm]
w_d = [76.1, 94.0, 98.4, 99.7, 99.9] '% T6
w_e = [3.6, 13.0, 36.9, 69.9, 90.2] '% Q4 (hoja 204)
#tabla("Celdas","T3 [mm]:4","% T3:1","T6 [mm]:4","% T6:1","% Q4 (204):1")({"1 × 1","2 × 1","4 × 1","8 × 2","16 × 4"}; w_a; w_b; w_c; w_d; w_e)
#: El **T3 es todavía peor que el Q4** (13 % contra 37 % con 4 × 1): su deformación es constante en cada triángulo, y la flexión necesita que varíe a lo alto. El T6 llega al 98 % con las mismas celdas. Porcentaje contra el número de celdas a lo largo (pasa el cursor):
#hide
c_T3 = [1, 1.8; 2, 5.0; 4, 13.0; 8, 36.4; 16, 69.2]
c_T6 = [1, 76.1; 2, 94.0; 4, 98.4; 8, 99.7; 16, 99.9]
c_Q4 = [1, 3.6; 2, 13.0; 4, 36.9; 8, 69.9; 16, 90.2]
#show
#fplot(T3 = c_T3, T6 = c_T6, Q4 = c_Q4, correcto = 100 + 0*x, [0 16])
#: **Bloqueo volumétrico** (deformación plana, malla 8 × 2 celdas, % de la flecha correcta de la hoja 204):
w_f = [37.1, 26.4, 10.8, 3.9, 3.0] '% T3
w_g = [98.9, 95.0, 90.3, 86.8, 86.1] '% T6
#tabla("ν","T3 %:1","T6 %:1")({"0.3","0.45","0.49","0.499","0.4999"}; w_f; w_g)
#: El T3 se bloquea casi del todo (3 %). El T6 aguanta mejor (86 %), aunque con ν → 0.5 los programas de suelos agregan una presión aparte (formulación mixta) o usan el T15.

## 8 · ¿Cuándo uso cada uno?
#tabla("Elemento","lo bueno","lo malo","úsalo en")({"T3 (CST)","T6 (LST)","T10 / T15"}; {"el más simple; malla cualquier forma","deformación lineal; lados curvos; estándar en suelos","muy exacto con pocos elementos"}; {"deformación constante: muy rígido en flexión y con ν → 0.5","3 puntos de Gauss obligatorios","caro; nudos internos"}; {"solo con malla muy fina o como relleno","taludes, excavaciones, zapatas (GeoFEM, GEO5, PLAXIS 6 nudos)","PLAXIS 15 nudos, análisis de falla finos"})
#: **Resumen:** mismo camino que el cuadrilátero (base → C → C⁻¹ → N), pero con coordenadas de área y otra cuadratura. Para flexión o suelos casi incompresibles, **nunca T3**: usa T6 o más. Siguiente hoja: el sólido H8 (206).
#> Fuentes: O. C. Zienkiewicz, R. L. Taylor, *The Finite Element Method*, vol. 1, cap. 6 (coordenadas de área, triángulos) y cap. 9 (cuadratura en triángulos); C. A. Felippa, *Introduction to Finite Element Methods*, cap. 15 y 24; R. D. Cook et al., cap. 7. Números: hekatan-school/VIDEOS/01_elementos_finitos_funciones_de_forma/ff_t3t6_manim/juez (Python y Hekatan OpenSees tri31).
