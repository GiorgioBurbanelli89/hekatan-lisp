# Introducción a los elementos finitos en geotecnia: los 8 pasos con un ejemplo pequeño (una zapata sobre 4 elementos, resuelta a mano y verificada)
#numerico

## 0 · Para qué es esta hoja
#: Si ya sabes calcular una viga o un pórtico con **K·u = F**, ya sabes el 80 % de los elementos finitos en suelos. Esta hoja muestra el 20 % que cambia, **paso a paso, desde cero**, con UN ejemplo tan chico que se puede seguir a mano: media zapata de 2 m de ancho sobre un bloque de suelo de 4 × 4 m partido en **4 elementos**. Todas las matrices se ven. Los resultados se comprobaron con un programa de otro autor (Hekatan OpenSees, el OpenSees de Berkeley) con el mismo modelo nudo a nudo: coinciden a 4 decimales.
#: Cada paso responde tres preguntas: **¿qué problema hay? · ¿qué se hace? · ¿qué número sale y qué significa?**
#dibujo("El ejemplo: una zapata corrida de B = 2 m con q = 200 kPa sobre arena limosa", ud = m, escala = auto, cotas = m, alto = 95)
#  achurado([-4, 4, 4, -4], [-4, -4, 0, 0], "terreno")
#  poligono(-4, -4, 4, -4, 4, 0, -4, 0, "gruesa")
#  rect(-1, 0, 2, 0.4, "concreto")
#  carga(-1, 0.4, 1, 0.4, 0.7, 0.7, "q = 200 kPa", "rojo", n = 7)
#  linea(0, -4.3, 0, 1.6, "trazos azul")
#  texto(0.15, 1.75, "eje de simetría", 2.4, "i")
#  cota(-1, -0.4, 1, -0.4, 0, "B = 2 m")
#  cota(4.4, -4, 4.4, 0, 0, "4 m")
#  texto(2, -2, "solo calculamos esta mitad", 2.6, "c")
#fin
#: La zapata es simétrica: lo que pasa a la izquierda del eje es el espejo de la derecha. Por eso se calcula **solo la mitad derecha** (0 ≤ x ≤ 4 m): la mitad de incógnitas, el mismo resultado.

## 1 · Qué cambia respecto de una estructura
#: **¿Qué problema hay?** En un pórtico las piezas son **barras**: tienen nudos naturales (las uniones) y la carga llega por ellas. El suelo **no tiene barras**: es un **medio continuo**, un bloque lleno donde cada punto empuja a sus vecinos en todas las direcciones. Además el suelo **no termina**: sigue hacia abajo y hacia los lados kilómetros.
#: **¿Qué se hace?** Cinco ideas nuevas, una por una:
#: **1 · Medio continuo → se corta en pedazos.** Se parte el bloque en «ladrillos» (los **elementos**) unidos por sus esquinas (los **nudos**). Es como cambiar una barra continua por eslabones: con más eslabones, más parecido a la realidad.
#: **2 · Deformación plana.** Una zapata corrida o un muro son muy LARGOS hacia adentro de la hoja. Una rebanada de 1 m de espesor se comporta igual que la de al lado: **nada se mueve hacia adentro de la hoja** (ε_z = 0). Así un problema 3D se vuelve 2D: cada nudo tiene solo dos movimientos, **u** (horizontal) y **v** (vertical). (En una viga plana cada nudo tenía u, v y el giro θ; aquí no hay giro: el suelo no se «dobla» como una viga, se aplasta y se distorsiona.)
#: **3 · Frontera artificial.** Como el suelo no termina, se **corta lejos** de la zapata (en estudios reales, 3 a 5 veces B hacia el lado y hacia abajo). En el corte se ponen apoyos (paso 4). Esta hoja corta a 4 m para que quepa a mano: es didáctico, no de diseño.
#: **4 · El peso propio manda.** En una viga el peso propio es una carga más y a veces pequeña. En el suelo el peso propio es ENORME (18 kN por cada m³) y ya está ahí ANTES de construir: el suelo ya está apretado por su propio peso (paso 5).
#: **5 · Signos y agua.** En estructuras la tracción es positiva. El suelo casi nunca trabaja en tracción, así que en geotecnia se habla de **compresión positiva**. La hoja calcula con tracción positiva (como cualquier programa de elementos finitos) y **muestra la compresión con su valor positivo** cuando la explica. Y el suelo tiene **agua** entre los granos:
#: **Esfuerzo efectivo σ′ = σ − u.** Piensa en una **esponja empapada** dentro de una bolsa: si la aprietas, parte del apretón lo toma el agua (la presión u) y el resto lo toman las fibras de la esponja (σ′). Los granos del suelo son las fibras: **solo σ′ los hace rozar y resistir**. Por eso la resistencia del suelo se calcula con σ′, no con σ.
#: **¿Qué número sale?** Un suelo saturado con γ_sat = 20 kN/m³ y el agua en la superficie (γ_w = 9.81 kN/m³), a z = 4 m de profundidad:
g_sat = 20 'peso unitario saturado [kN/m³]
g_w = 9.81 'peso unitario del agua [kN/m³]
z_4 = 4 'profundidad [m]
s_tot = g_sat·z_4 'esfuerzo total σ = γ_sat·z [kPa]
u_agua = g_w·z_4 'presión del agua u = γ_w·z [kPa]
s_ef = s_tot - u_agua 'esfuerzo efectivo σ′ = σ − u [kPa]
#: De los 80 kPa que pesa la columna, el agua toma 39 y los granos solo 41: **la mitad**. Pasa el cursor por las rectas (eje horizontal: profundidad z en m; vertical: kPa):
#fplot(total = 20*x, agua = 9.81*x, efectivo = 10.19*x, [0 4])
#: En el ejemplo de esta hoja el suelo está **seco** (agua muy abajo): u = 0 y σ′ = σ. Así se ve el método limpio; el agua es el tema de la hoja siguiente.
#: **En una línea:** el suelo es un bloque continuo (se corta en elementos), largo (deformación plana), sin fin (se corta lejos), pesado (peso propio) y con agua (σ′ = σ − u).

## 2 · Geometría y malla: el bloque partido en 4 elementos
#: **¿Qué problema hay?** Un bloque continuo tiene infinitos puntos. No se pueden escribir infinitas ecuaciones.
#: **¿Qué se hace?** Se parte en **4 cuadrados de 2 × 2 m** (elementos **Q4**: cuadriláteros de 4 nudos) y se calcula el movimiento solo en los **9 nudos**. Dentro de cada cuadrado el movimiento se **interpola** (se rellena) a partir de sus 4 esquinas.
#dibujo("La malla: 4 elementos Q4 (e1…e4) y 9 nudos numerados de abajo hacia arriba", ud = m, escala = auto, cotas = m, alto = 105)
#  achurado([0, 4, 4, 0], [0, 0, 4, 4], "terreno")
#  poligono(0, 0, 4, 0, 4, 4, 0, 4, "gruesa")
#  linea(2, 0, 2, 4, "gruesa")
#  linea(0, 2, 4, 2, "gruesa")
#  rect(0, 4, 1, 0.25, "concreto")
#  carga(0, 4.25, 1, 4.25, 0.5, 0.5, "q", "rojo", n = 4)
#  circulo(0, 0, 0.09, "negro")
#  circulo(2, 0, 0.09, "negro")
#  circulo(4, 0, 0.09, "negro")
#  circulo(0, 2, 0.09, "negro")
#  circulo(2, 2, 0.09, "negro")
#  circulo(4, 2, 0.09, "negro")
#  circulo(0, 4, 0.09, "negro")
#  circulo(2, 4, 0.09, "negro")
#  circulo(4, 4, 0.09, "negro")
#  texto(-0.25, -0.3, "1", 2.6, "c")
#  texto(2, -0.3, "2", 2.6, "c")
#  texto(4.25, -0.3, "3", 2.6, "c")
#  texto(-0.3, 2, "4", 2.6, "c")
#  texto(2.25, 2.25, "5", 2.6, "c")
#  texto(4.3, 2, "6", 2.6, "c")
#  texto(-0.3, 4.15, "7", 2.6, "c")
#  texto(2.2, 4.3, "8", 2.6, "c")
#  texto(4.3, 4.15, "9", 2.6, "c")
#  texto(1, 1, "e1", 3, "c")
#  texto(3, 1, "e2", 3, "c")
#  texto(1, 3, "e3", 3, "c")
#  texto(3, 3, "e4", 3, "c")
#fin
#: **Funciones de forma.** Cada esquina tiene una «carpa»: vale 1 en su nudo y 0 en los otros tres. Se escriben en coordenadas propias del elemento, ξ (horizontal) y η (vertical), que van de −1 a +1 (así todos los elementos se calculan con la misma receta):
N_1 = Simplify{(1 - xi)*(1 - eta)/4}
N_2 = Simplify{(1 + xi)*(1 - eta)/4}
N_3 = Simplify{(1 + xi)*(1 + eta)/4}
N_4 = Simplify{(1 - xi)*(1 + eta)/4}
S_N = Simplify{(1 - xi)*(1 - eta)/4 + (1 + xi)*(1 - eta)/4 + (1 + xi)*(1 + eta)/4 + (1 - xi)*(1 + eta)/4}
#: Suman 1 en todo punto: si los 4 nudos bajan 1 cm, todo el elemento baja 1 cm (el movimiento de cuerpo rígido se respeta). **La carpa N₁ en 3D** (arrastra para girar; x = ξ, y = η):
#surf((1 - x)*(1 - y)/4, [-1 1], [-1 1])
#: Y vista desde arriba (el valor con colores; pasa el cursor):
#map((1 - x)*(1 - y)/4, [-1 1], [-1 1])
#: **El Jacobiano** dice cuánto mide el elemento real comparado con el de −1…+1. Para un cuadrado de lado a: x = a/2·(1 + ξ), así que dx/dξ = a/2 (y lo mismo en y). Es una escala:
J_x = Simplify{Diff{a/2*(1 + xi) @ xi}}
d_J = Simplify{(a/2)*(a/2)}
#: (det J = a²/4 = un cuarto del área: el cuadrado de −1…+1 tiene área 4.) Con él, las derivadas reales: ∂N/∂x = ∂N/∂ξ · (2/a).
dN1_dx = Simplify{Partial{(1 - xi)*(1 - eta)/4 @ xi}*2/a}
dN1_dy = Simplify{Partial{(1 - xi)*(1 - eta)/4 @ eta}*2/a}
#: **La matriz B** convierte los movimientos de los nudos en **deformaciones** (cuánto se estira o se distorsiona el suelo). En deformación plana hay cuatro: ε_x = ∂u/∂x, ε_y = ∂v/∂y, ε_z = 0 (nada hacia adentro) y la distorsión γ_xy = ∂u/∂y + ∂v/∂x. Para el nudo i, su bloque de B (columnas u_i y v_i):
#: B_i = [∂N_i/∂x, 0 ; 0, ∂N_i/∂y ; 0, 0 ; ∂N_i/∂y, ∂N_i/∂x]   (filas: ε_x, ε_y, ε_z, γ_xy)
#: **En una viga** B era la segunda derivada (la curvatura); **en el suelo** son primeras derivadas (estiramiento y distorsión). La idea es la misma: B = cómo se deforma el material cuando los nudos se mueven.
#: **En una línea:** 4 cuadrados, 9 nudos, carpas N que interpolan, el Jacobiano que escala y B que da las deformaciones.

## 2 bis · ¿Qué elemento uso? T3, T6, Q4, Q8 y Q9
#: **¿Qué problema hay?** Esta hoja usa **Q4** (4 cuadrados, para hacerlo a mano), pero el talud de Griffiths y Lane de las hojas 190 y 195 usa **T6** (triángulos de 6 nudos). ¿Cuál se usa y cuándo? La **letra** dice la forma (T = triángulo, Q = cuadrilátero) y el **número** dice cuántos nudos tiene.
#dibujo("La familia: esquinas (negro), nudos en la mitad de los lados (azul) y nudo central (rojo)", ud = m, escala = auto, alto = 60)
#  poligono(0, 0, 2, 0, 0, 2, "gruesa")
#  poligono(3, 0, 5, 0, 3, 2, "gruesa")
#  poligono(6, 0, 8, 0, 8, 2, 6, 2, "gruesa")
#  poligono(9, 0, 11, 0, 11, 2, 9, 2, "gruesa")
#  poligono(12, 0, 14, 0, 14, 2, 12, 2, "gruesa")
#  circulo(0, 0, 0.1, "negro")
#  circulo(2, 0, 0.1, "negro")
#  circulo(0, 2, 0.1, "negro")
#  circulo(3, 0, 0.1, "negro")
#  circulo(5, 0, 0.1, "negro")
#  circulo(3, 2, 0.1, "negro")
#  circulo(4, 0, 0.1, "azul")
#  circulo(4, 1, 0.1, "azul")
#  circulo(3, 1, 0.1, "azul")
#  circulo(10, 0, 0.1, "azul")
#  circulo(11, 1, 0.1, "azul")
#  circulo(10, 2, 0.1, "azul")
#  circulo(9, 1, 0.1, "azul")
#  circulo(13, 0, 0.1, "azul")
#  circulo(14, 1, 0.1, "azul")
#  circulo(13, 2, 0.1, "azul")
#  circulo(12, 1, 0.1, "azul")
#  circulo(13, 1, 0.1, "rojo")
#  circulo(6, 0, 0.1, "negro")
#  circulo(8, 0, 0.1, "negro")
#  circulo(8, 2, 0.1, "negro")
#  circulo(6, 2, 0.1, "negro")
#  circulo(9, 0, 0.1, "negro")
#  circulo(11, 0, 0.1, "negro")
#  circulo(11, 2, 0.1, "negro")
#  circulo(9, 2, 0.1, "negro")
#  circulo(12, 0, 0.1, "negro")
#  circulo(14, 0, 0.1, "negro")
#  circulo(14, 2, 0.1, "negro")
#  circulo(12, 2, 0.1, "negro")
#  texto(0.7, -0.6, "T3", 2.6, "c")
#  texto(3.7, -0.6, "T6", 2.6, "c")
#  texto(7, -0.6, "Q4", 2.6, "c")
#  texto(10, -0.6, "Q8", 2.6, "c")
#  texto(13, -0.6, "Q9", 2.6, "c")
#fin
#: Un «T9» no es de uso común: lo usual es el **Q9** (cuadrilátero de Lagrange con nudo central). Los triángulos de orden más alto son el **T10** (cúbico) y el **T15** que usa PLAXIS.
#: **¿Qué se hace? Deducir las funciones de forma con símbolos** (igual que Hermite en la viga): polinomio genérico → condiciones en los nudos → matriz C → inversa → N. **T3**: u = a₀ + a₁ξ + a₂η, nudos en (0, 0), (1, 0) y (0, 1). Cada fila de C es [1, ξ, η] evaluado en un nudo:
C_3 = Simplify{[1, 0, 0; 1, 1, 0; 1, 0, 1]}
C_3i = Simplify{inv(C_3)}
N_T3 = Simplify{[1, xi, eta]*C_3i}
#: **N = [1 − ξ − η, ξ, η]**: tres planos. Sus derivadas (lo que entra en la matriz B):
dT3_dxi = Simplify{Diff{1 - xi - eta @ xi}}
dT3_deta = Simplify{Diff{1 - xi - eta @ eta}}
#: **No dependen de ξ ni de η**: dentro del T3 la deformación es **constante**. Un triángulo entero con una sola deformación: por eso es tan rígido.
#: **T6**: polinomio completo de 2.º grado, 6 términos para 6 nudos: esquinas (0, 0), (1, 0), (0, 1) y medios (½, 0), (½, ½), (0, ½). Filas [1, ξ, η, ξ², ξη, η²]:
C_6 = Simplify{[1, 0, 0, 0, 0, 0; 1, 1, 0, 1, 0, 0; 1, 0, 1, 0, 0, 1; 1, 1/2, 0, 1/4, 0, 0; 1, 1/2, 1/2, 1/4, 1/4, 1/4; 1, 0, 1/2, 0, 0, 1/4]}
C_6i = Simplify{inv(C_6)}
N_T6 = Simplify{[1, xi, eta, xi^2, xi*eta, eta^2]*C_6i}
dT6_4 = Simplify{Diff{4*xi*(1 - xi - eta) @ xi}}
#: (N₄ = 4ξ(1 − ξ − η) es la del nudo de la mitad del lado 1-2.) Su derivada **sí depende de ξ y η**: la deformación del T6 varía linealmente dentro del elemento. **Q4, Q8 y Q9**: N = ¼(1 + ξξᵢ)(1 + ηηᵢ) (Q4, bilineal, el de esta hoja); Q8 agrega los nudos de los lados (serendípito, sin nudo central); Q9 es el producto de dos parábolas ℓᵢ(ξ)·ℓⱼ(η) (Lagrange, con nudo central). La del nudo central del Q9:
N_Q9c = Simplify{(1 - xi^2)*(1 - eta^2)}
#: **Las carpas en 3D** (arrastra para girar). T3, N₁ = 1 − x − y (un plano):
#surf(max(0, 1 - x - y), [0 1], [0 1])
#: T6, N₄ = 4x(1 − x − y) (una curva):
#surf(max(0, 4*x*(1 - x - y)), [0 1], [0 1])
#: Q9, la del nudo central (1 − x²)(1 − y²):
#surf((1 - x^2)*(1 - y^2), [-1 1], [-1 1])
#: **¿Qué número sale?** El MISMO bloque y la misma zapata con cada elemento, 2 × 2 celdas (los triángulos parten cada celda en dos) y 8 × 8, contra una malla muy fina (Q9 de 64 × 64). Asiento bajo el centro en mm, calculado en Python (intro_fem_manim/juez/elementos.py); T3 y Q4 dan lo mismo en Hekatan OpenSees a 4 decimales (esa DLL no trae T6 ni Q8). El Q4 de 2 × 2 es exactamente esta hoja: 18.4694 mm.
#hide
w_a = [14.4022, 18.4694, 19.5226, 19.9492, 20.6972]
w_b = [18.7143, 20.0077, 20.2288, 20.2026, 20.1991]
w_c = [2.6078, 4.1723, 10.7041, 11.6368, 11.8203]
w_d = [7.8028, 9.9305, 11.8860, 11.8616, 11.8664]
s_a = zeros(5, 1)
s_b = zeros(5, 1)
s_c = zeros(5, 1)
s_d = zeros(5, 1)
p_a = zeros(5, 1)
p_c = zeros(5, 1)
for i = 1:5
  s_a(i) = w_a(i)
  s_b(i) = w_b(i)
  s_c(i) = w_c(i)
  s_d(i) = w_d(i)
  p_a(i) = 100·w_a(i)/20.2062
  p_c(i) = 100·w_c(i)/11.8902
end
#show
#tabla("Elemento","arena ν = 1/3, 2×2 [mm]:4","8×8 [mm]:4","% del correcto (2×2):0","arcilla ν = 0.49, 2×2 [mm]:4","8×8 [mm]:4","% del correcto (2×2):0")({"T3","Q4","T6","Q8","Q9"}; s_a; s_b; p_a; s_c; s_d; p_c)
#: (malla muy fina: 20.2062 mm con ν = 1/3 y 11.8902 mm con ν = 0.49.) **Arcilla saturada (ν = 0.49, casi sin cambio de volumen)**, % del asiento correcto con 2 × 2 celdas (pasa el cursor):
#hide
h_xe = zeros(5, 1)
h_ye = zeros(5, 1)
for i = 1:5
  h_xe(i) = 10·i - 4
  h_ye(i) = p_c(i)/4
end
#show
#dibujo("Arcilla saturada: % del asiento correcto con 2 × 2 celdas (rojo: lineales que se bloquean; verde: cuadráticos)", ud = m, escala = auto, alto = 70)
#  linea(0, 0, 52, 0, "fina")
#  linea(0, 25, 52, 25, "trazos")
#  texto(50, 27, "100 %", 2.6, "c")
#  rect(3, 0, 6, 5.48, "rojo")
#  texto(6, -2, "T3", 2.6, "c")
#  rect(13, 0, 6, 8.77, "rojo")
#  texto(16, -2, "Q4", 2.6, "c")
#  rect(23, 0, 6, 22.50, "verde")
#  texto(26, -2, "T6", 2.6, "c")
#  rect(33, 0, 6, 24.47, "verde")
#  texto(36, -2, "Q8", 2.6, "c")
#  rect(43, 0, 6, 24.85, "verde")
#  texto(46, -2, "Q9", 2.6, "c")
#  hover(h_xe, h_ye, "{#2:1} % del asiento correcto", h_xe, p_c)
#fin
#: **¿Qué significa?** Con la arena los lineales se quedan cortos (T3 71 %, Q4 91 %) y los cuadráticos casi aciertan (97–102 %). Con la arcilla saturada el T3 da 22 % y el Q4 35 %: **se bloquean** (no pueden deformarse sin cambiar de volumen, y el agua no deja cambiar el volumen). Lo mismo pasa cuando el suelo fluye en plasticidad: por eso el FS del paso 8 necesita otra malla.
#: **Cuándo usar cada uno:** **T3** demasiado rígido → evitarlo para la falla del suelo. **T6** el estándar en geotecnia (GEO5 y PLAXIS usan triángulos cuadráticos; se mallan solos en taludes y excavaciones). **Q4** simple, para enseñar y mallas regulares; rígido con pocos elementos. **Q8 / Q9** cuadráticos para mallas ordenadas; Q9 algo más robusto. **Regla práctica: para la falla del suelo, elementos cuadráticos (T6, Q8) y malla fina.**
#: **En una línea:** T3 constante y rígido, T6 lineal y el estándar; cuadráticos + malla fina para la falla.

## 3 · Material: elástico, y el techo de Mohr-Coulomb
#: **¿Qué problema hay?** Hay que decir cuánto esfuerzo produce cada deformación, como en una viga se dice E.
#: **¿Qué se hace?** Primero lo más simple: **elástico** (un resorte: el doble de deformación da el doble de esfuerzo). En deformación plana se usan λ y G (dos números que salen de E y ν):
lam_E = Simplify{E*nu/((1 + nu)*(1 - 2*nu))}
G_E = Simplify{E/(2*(1 + nu))}
M_E = Simplify{E*nu/((1 + nu)*(1 - 2*nu)) + E/(1 + nu)}
#: M = λ + 2G es el **módulo confinado**: la rigidez de una columna de suelo que no puede abrirse hacia los lados (la del ensayo de edómetro). La matriz **D** (esfuerzo = D · deformación, filas σ_x, σ_y, σ_z, τ_xy):
#: D = [λ+2G, λ, λ, 0 ; λ, λ+2G, λ, 0 ; λ, λ, λ+2G, 0 ; 0, 0, 0, G]
#: Fíjate en la tercera fila: aunque ε_z = 0, **σ_z no es cero** (el suelo de las rebanadas vecinas empuja). Es lo que la deformación plana tiene de distinto.
#: **Con números** (arena limosa medianamente densa):
E_s = 20000 'módulo de elasticidad E [kPa] (20 MPa)
n_s = 1/3 'coeficiente de Poisson ν
g_s = 18 'peso unitario γ [kN/m³]
c_s = 10 'cohesión c [kPa]
f_g = 30 'ángulo de fricción φ [°]
f_r = f_g·pi/180 'φ [rad]
l_D = E_s·n_s/((1 + n_s)·(1 - 2·n_s)) 'λ [kPa]
G_m = E_s/(2·(1 + n_s)) 'G [kPa]
M_c = l_D + 2·G_m 'módulo confinado M [kPa]
D_e = [l_D + 2·G_m, l_D, l_D, 0; l_D, l_D + 2·G_m, l_D, 0; l_D, l_D, l_D + 2·G_m, 0; 0, 0, 0, G_m] 'D [kPa]
#: **¿Por qué no alcanza lo elástico?** Porque un resorte aguanta todo: con el doble de carga, el doble de asiento, sin límite. El suelo real **se ablanda** y llega a un **techo**: no puede aguantar más corte que el que le da su fricción y su cohesión. Ese techo es **Mohr-Coulomb**: τ_max = c + σ′·tan φ. Como un libro sobre la mesa: cuanto más lo aprietas contra la mesa (σ′), más fuerza hace falta para deslizarlo (la fricción, tan φ); la cohesión c es un «pegamento» que existe aunque no aprietes.
#fplot(Mohr_Coulomb = 10 + 0.57735*x, sin_cohesion = 0.57735*x, [0 200])
#: (eje horizontal: σ′ en kPa; vertical: el corte máximo τ en kPa; pasa el cursor.) **La hipótesis «elástico», animada:** mueve ▶ y mira cómo la recta elástica (el resorte) y la curva del suelo real se separan a medida que crece la deformación n (x en milésimas, esfuerzo en kPa; techo de 150 kPa):
#anim fplot(elastico = 20*x, suelo_real = 20*x/(1 + 20*x/150), techo = 150 + 0*x, hoy_elastico = 20*n + 0*x, hoy_real = 20*n/(1 + 20*n/150) + 0*x, [0 20]), n = 0:1:20
#: Las dos rectas horizontales marcan dónde está cada una con la deformación n: con deformaciones chicas (n ≤ 2) casi se tapan: **elástico vale**. Con deformaciones grandes el suelo real se aplana bajo el techo y el resorte sigue subiendo: **elástico miente**.
#: En esta hoja el techo es el **Drucker-Prager** que usa GEO5 (un Mohr-Coulomb «redondeado», sin esquinas, más fácil de calcular), con los mismos c y φ:
a_DP = 2·sin(f_r)/(sqrt(3)·(3 + sin(f_r))) 'α de Drucker-Prager
k_DP = 6·c_s·cos(f_r)/(sqrt(3)·(3 + sin(f_r))) 'k de Drucker-Prager [kPa]
#: Un punto del suelo está bien si **f = J + α·I₁ − k < 0** (J mide el corte, I₁ el apretón; con tracción positiva, el apretón I₁ es negativo y ayuda). Si f quiere pasar de 0, el punto **fluye**: se le llama **punto plástico**.
#: **En una línea:** elástico (D con λ y G) para empezar; Mohr-Coulomb / Drucker-Prager como techo que el suelo no puede pasar.

## 4 · Condiciones de borde: la caja de arena
#: **¿Qué problema hay?** Cortamos el suelo en x = 0, x = 4 m y z = 4 m. Pero el suelo de afuera sigue empujando: hay que reemplazarlo por algo.
#: **¿Qué se hace?** Piensa en **arena dentro de una caja de vidrio**: el fondo no deja que la arena baje ni se corra; las paredes no la dejan salir hacia los lados, pero la arena **sí resbala hacia abajo** pegada al vidrio. Eso mismo se pone:
#: • **Base fija** (u = 0 y v = 0): abajo el suelo es más firme y ya no se mueve.
#: • **Laterales con rodillo** (u = 0, v libre): la pared deja bajar pero no deja salir. En x = 0 además es el **eje de simetría**: por simetría ningún punto del eje se mueve de lado.
#: • **Superficie libre**: nada la sujeta (fuera de la zapata, nada la carga).
#dibujo("Condiciones de borde: base fija, rodillos a los lados, superficie libre", ud = m, escala = auto, cotas = m, alto = 105)
#  achurado([0, 4, 4, 0], [0, 0, 4, 4], "terreno")
#  poligono(0, 0, 4, 0, 4, 4, 0, 4, "gruesa")
#  linea(2, 0, 2, 4, "fina")
#  linea(0, 2, 4, 2, "fina")
#  empotramiento(-0.2, -0.05, 4.2, -0.05, -1)
#  circulo(-0.15, 2, 0.13, "azul")
#  circulo(-0.15, 4, 0.13, "azul")
#  circulo(4.15, 2, 0.13, "azul")
#  circulo(4.15, 4, 0.13, "azul")
#  linea(-0.3, 1.6, -0.3, 4.3, "gruesa azul")
#  linea(4.3, 1.6, 4.3, 4.3, "gruesa azul")
#  texto(-1.2, 3, "rodillo u = 0", 2.4, "c")
#  texto(5.2, 3, "rodillo u = 0", 2.4, "c")
#  texto(2, -0.55, "base fija: u = 0, v = 0", 2.4, "c")
#  texto(2.6, 4.35, "superficie libre", 2.4, "c")
#  rect(0, 4, 1, 0.25, "concreto")
#fin
#: **¿Qué número sale?** De 9 nudos × 2 = 18 movimientos posibles, la base fija quita 6 (nudos 1, 2, 3) y los rodillos quitan 4 (u de los nudos 4, 6, 7, 9). Quedan **8 incógnitas libres**: v₄, u₅, v₅, v₆, v₇, u₈, v₈, v₉. La matriz que se resuelve es de **8 × 8**: cabe en la hoja.
L_b = [8, 9, 10, 12, 14, 15, 16, 18] 'números de los 8 movimientos libres (nudo i: u = 2i − 1, v = 2i)
#: **En una viga** pones apoyos donde están los apoyos reales. **En el suelo** los apoyos son **inventados** (el corte de la frontera): por eso se ponen lejos, para que no cambien el resultado.
#: **En una línea:** base fija, rodillos a los lados, superficie libre: 8 incógnitas.

## 5 · Estado inicial: el suelo ya está apretado por su peso
#: **¿Qué problema hay?** Antes de construir la zapata, el suelo **ya** soporta su propio peso: cada punto está apretado por todo el suelo de arriba. Si se ignora, el suelo parecería no tener fricción (la fricción crece con el apretón).
#: **¿Qué se hace?** Primero se calcula el **estado inicial**. A una profundidad z, el peso de la columna de arriba da el esfuerzo vertical, y el horizontal es una fracción K₀ de él (el suelo empuja a los lados menos de lo que empuja hacia abajo):
#: **σ_v = γ·z**   y   **σ_h = K₀·σ_v**
#: Hay dos fórmulas para K₀. **Jaky** (de ensayos, suelos normalmente consolidados): K₀ = 1 − sin φ. **Elástica** (una columna que no puede abrirse de lado): K₀ = ν/(1 − ν). Con φ = 30° y ν = 1/3 **las dos dan 0.5**: se eligió ν para que coincidan.
K_0 = 1 - sin(f_r) 'K₀ de Jaky
K_n = n_s/(1 - n_s) 'K₀ elástico ν/(1 − ν)
#: Los programas (GEO5, PLAXIS) llaman a esto la **fase inicial** (o «geostática»). Se hace en la malla: el peso de cada elemento (γ · área = 18 · 4 = 72 kN por metro) se reparte entre sus 4 nudos (18 kN a cada uno) y se resuelve K·u = F_peso:
#hide
X_n = [0, 2, 4, 0, 2, 4, 0, 2, 4] 'x de los 9 nudos [m]
Y_n = [0, 0, 0, 2, 2, 2, 4, 4, 4] 'y de los 9 nudos [m]
E_q = [1, 2, 5, 4; 2, 3, 6, 5; 4, 5, 8, 7; 5, 6, 9, 8] 'nudos de cada elemento (antihorario)
g_p = 1/sqrt(3)
P_x = [-g_p, g_p, g_p, -g_p] 'ξ de los 4 puntos de Gauss
P_y = [-g_p, -g_p, g_p, g_p] 'η de los 4 puntos de Gauss
n_n = 9
K_g = zeros(18, 18)
F_p = zeros(18, 1)
B_s = zeros(64, 8)
w_s = zeros(16, 1)
G_e = zeros(4, 8)
X_g = zeros(16, 1)
Y_g = zeros(16, 1)
K_1 = zeros(8, 8)
for i_e = 1:4
  x_e = zeros(4, 1)
  y_e = zeros(4, 1)
  g_d = zeros(8, 1)
  for i_a = 1:4
    x_e(i_a) = X_n(E_q(i_e, i_a))
    y_e(i_a) = Y_n(E_q(i_e, i_a))
    g_d(2·i_a - 1) = 2·E_q(i_e, i_a) - 1
    g_d(2·i_a) = 2·E_q(i_e, i_a)
  end
  Kel = zeros(8, 8)
  for i_q = 1:4
    x_i = P_x(i_q)
    e_t = P_y(i_q)
    N_v = [(1 - x_i)·(1 - e_t)/4, (1 + x_i)·(1 - e_t)/4, (1 + x_i)·(1 + e_t)/4, (1 - x_i)·(1 + e_t)/4]
    d_1 = [-(1 - e_t)/4, (1 - e_t)/4, (1 + e_t)/4, -(1 + e_t)/4]
    d_2 = [-(1 - x_i)/4, -(1 + x_i)/4, (1 + x_i)/4, (1 - x_i)/4]
    j_11 = 0
    j_12 = 0
    j_21 = 0
    j_22 = 0
    for i_a = 1:4
      j_11 = j_11 + d_1(i_a)·x_e(i_a)
      j_12 = j_12 + d_1(i_a)·y_e(i_a)
      j_21 = j_21 + d_2(i_a)·x_e(i_a)
      j_22 = j_22 + d_2(i_a)·y_e(i_a)
    end
    d_t = j_11·j_22 - j_12·j_21
    B = zeros(4, 8)
    for i_a = 1:4
      B(1, 2·i_a - 1) = (j_22·d_1(i_a) - j_12·d_2(i_a))/d_t
      B(2, 2·i_a) = (-j_21·d_1(i_a) + j_11·d_2(i_a))/d_t
      B(4, 2·i_a - 1) = B(2, 2·i_a)
      B(4, 2·i_a) = B(1, 2·i_a - 1)
    end
    Kel = Kel + transpose(B)·D_e·B·d_t
    i_g = 4·(i_e - 1) + i_q
    B_s(4·(i_g - 1) + 1:4·i_g, 1:8) = B
    w_s(i_g) = d_t
    X_g(i_g) = 0
    Y_g(i_g) = 0
    for i_a = 1:4
      F_p(g_d(2·i_a)) = F_p(g_d(2·i_a)) - N_v(i_a)·g_s·d_t
      X_g(i_g) = X_g(i_g) + N_v(i_a)·x_e(i_a)
      Y_g(i_g) = Y_g(i_g) + N_v(i_a)·y_e(i_a)
    end
  end
  K_g(g_d, g_d) = K_g(g_d, g_d) + Kel
  G_e(i_e, 1:8) = transpose(g_d)
  if i_e == 1
    K_1 = Kel
  end
end
#show
#: **La rigidez de UN elemento** (8 × 8: u₁, v₁, u₂, v₂, u₃, v₃, u₄, v₄ de sus esquinas, en kN/m). Se integra con 4 **puntos de Gauss**: 4 puntos elegidos dentro del elemento (en ξ, η = ±1/√3) donde basta evaluar B y sumar para obtener la integral EXACTA de este elemento. Es como medir la temperatura de una sala en 4 lugares bien elegidos en vez de en todos. Con símbolos, los dos primeros términos (M = λ + 2G):
k_11 = Simplify{Area{Area{(M_k*((eta - 1)/(2*a))^2 + G_k*((xi - 1)/(2*a))^2)*a^2/4 @ xi = -1 : 1} @ eta = -1 : 1}}
k_12 = Simplify{Area{Area{(l_k + G_k)*((eta - 1)/(2*a))*((xi - 1)/(2*a))*a^2/4 @ xi = -1 : 1} @ eta = -1 : 1}}
#: ¡El lado a se cancela! Un cuadrado de 2 m y uno de 20 cm tienen la **misma** rigidez (en deformación plana, por metro de espesor). Con números: (M + G)/3 = (30 000 + 7 500)/3 = **12 500 kN/m** y (λ + G)/4 = 22 500/4 = **5 625 kN/m**. La matriz entera (los 4 elementos son iguales):
K_1
#: **Se ensambla** como en un pórtico: cada término del elemento se suma en la fila y columna de su nudo global. El nudo 5 (centro) recibe de los 4 elementos. Se quitan las filas y columnas fijas (paso 4) y queda la **K de 8 × 8** (orden v₄, u₅, v₅, v₆, v₇, u₈, v₈, v₉; kN/m):
K_L = K_g(L_b, L_b)
F_L = F_p(L_b) 'peso propio en los nudos libres [kN] (negativo: hacia abajo)
#: (nudo 5: 4 × 18 = 72 kN; nudos 4, 6: 2 × 18 = 36; nudos 7, 9: 18.) **Se resuelve K·u = F** con el peso solo:
#hide
u_g = zeros(18, 1)
u_g(L_b) = lsolve(K_L, F_L)
S_0 = zeros(64, 1)
for i_e = 1:4
  for i_q = 1:4
    i_g = 4·(i_e - 1) + i_q
    S_0(4·(i_g - 1) + 1:4·i_g) = D_e·B_s(4·(i_g - 1) + 1:4·i_g, 1:8)·u_g(G_e(i_e, 1:8))
  end
end
#show
v_7g = 1000·u_g(14) 'asiento por peso propio en la superficie [mm]
v_4g = 1000·u_g(8) 'a 2 m de profundidad [mm]
#: **Comprobación a mano:** una columna que no puede abrirse de lado se acorta γ·H²/(2M) = 18 · 4²/(2 · 30 000) = 4.8 mm. ¡La malla da exactamente lo mismo!
v_mano = 1000·g_s·4^2/(2·M_c) 'γH²/2M [mm]
#: Los esfuerzos en los puntos de Gauss (compresión positiva, kPa): en los elementos de abajo (centro a z = 3 m) y de arriba (z = 1 m):
s_v1 = -S_0(2) 'σ_v elemento 1 [kPa] (γ·3 = 54)
s_h1 = -S_0(1) 'σ_h elemento 1 [kPa] (K₀·54 = 27)
s_v3 = -S_0(34) 's_v elemento 3 [kPa] (γ·1 = 18)
s_h3 = -S_0(33) 's_h elemento 3 [kPa] (K₀·18 = 9)
#: Es justo **σ_v = γ·z** en el centro de cada elemento y **σ_h = 0.5·σ_v**. La recta exacta y lo que ve la malla (escalones: un valor por elemento), pasa el cursor:
#hide
h_z = [0; 1; 3; 4]
h_v = [0; s_v3; s_v1; 72]
#show
#dibujo("Estado inicial: σ_v (rojo) y σ_h (azul) contra la profundidad z; escalones = lo que guarda la malla", ud = m, escala = auto, alto = 90)
#  linea(0, 0, 80, 0, "fina")
#  linea(0, 0, 0, -45, "fina")
#  polilinea([0, 72], [0, -40], "trazos rojo")
#  polilinea([0, 36], [0, -40], "trazos azul")
#  polilinea([18, 18, 54, 54], [0, -20, -20, -40], "gruesa rojo")
#  polilinea([9, 9, 27, 27], [0, -20, -20, -40], "gruesa azul")
#  circulo(18, -10, 1.2, "rojo")
#  circulo(54, -30, 1.2, "rojo")
#  circulo(9, -10, 1.2, "azul")
#  circulo(27, -30, 1.2, "azul")
#  texto(76, -40, "σ_v = γz", 2.6, "c")
#  texto(40, -42, "σ_h = K₀σ_v", 2.6, "c")
#  texto(40, 3, "esfuerzo [kPa] (compresión +)", 2.4, "c")
#  texto(-6, -20, "z = 2 m", 2.4, "c")
#  texto(-6, -40, "z = 4 m", 2.4, "c")
#  hover([18, 54], [-10, -30], "z = {#1:0} m: σ_v = {#2:1} kPa", [1, 3], [18, 54])
#fin
#: **Y después se ponen los desplazamientos a CERO.** ¿Por qué? Esos 4.8 mm pasaron hace miles de años, cuando el suelo se depositó. La zapata no los produce: lo que interesa es **cuánto MÁS** se mueve el suelo por la zapata. Se guardan los esfuerzos iniciales (el apretón) y se borran los movimientos. **En una viga** el peso propio es una carga más que se suma; **en el suelo** el peso propio es el punto de partida.
#: **En una línea:** σ_v = γz, σ_h = K₀σ_v (aquí 0.5), se guardan los esfuerzos y los desplazamientos vuelven a cero.

## 6 · Cargar la zapata y resolver
#: **¿Qué problema hay?** La zapata aprieta 200 kPa sobre 1 m (la media zapata). Esa presión está repartida: hay que llevarla a los nudos.
#: **¿Qué se hace?** Igual que los momentos de empotramiento de una viga: la carga repartida se reparte con las **mismas** funciones de forma (trabajo virtual). En el borde de arriba del elemento 3 (de x = 0 a 2 m) la carga va de x = 0 a 1:
f_7 = Simplify{Area{q*(2 - x)/2 @ x = 0 : 1}}
f_8 = Simplify{Area{q*x/2 @ x = 0 : 1}}
q_z = 200 'presión de la zapata [kPa]
#hide
F_z = q_z·[0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; -0.75; 0; -0.25; 0; 0]
#show
F_zL = F_z(L_b) 'carga de la zapata en los nudos libres [kN]: 150 en el nudo 7, 50 en el 8
#: **Parte LINEAL (elástica):** un solo K·u = F, como en un pórtico:
#hide
x_l = lsolve(K_L, F_zL)
u_l = zeros(18, 1)
for i_a = 1:8
  u_l(L_b(i_a)) = x_l(i_a)
end
#show
d_lin = 1000·u_l(L_b) 'desplazamientos libres [mm] (v₄, u₅, v₅, v₆, v₇, u₈, v₈, v₉)
s_lin = -1000·u_l(14) 'ASIENTO bajo el centro de la zapata, elástico [mm]
#: **Comparación de sentido común:** si los 200 kPa cubrieran TODA la superficie, la columna se acortaría q·H/M = 200 · 4/30 000 = 26.7 mm. Con zapata (la carga se abre hacia los lados) da menos: 18.5 mm. Razonable.
s_1D = 1000·q_z·4/M_c 'q·H/M [mm]
#: **Parte NO LINEAL (con el techo de Drucker-Prager):** ahora la rigidez de cada punto depende de cuánto está cargado. Ya no basta UNA división: se usa **Newton-Raphson** (la hoja 198 lo explica con una barra): se calcula con la rigidez del momento (**K_T**, rigidez tangente), se mira cuánta fuerza falta (el **residuo R = F_ext − F_int**, lo que la carga pide menos lo que el suelo devuelve) y se repite hasta que no falte nada.
#: K_T · Δu = R        F_int = Σ Bᵀ · σ · det J · w   (suma sobre los 16 puntos de Gauss)
#: En cada punto de Gauss: se suma al esfuerzo inicial la parte elástica de la deformación (**predictor**); si f > 0 el punto se pasó del techo y se **devuelve** a él (retorno de Drucker-Prager, ψ = 0: baja el corte J hasta J − f sin cambiar el apretón I₁) y su rigidez baja (tangente consistente, como en la hoja 190).
#hide
O_n = [1; 1; 1; 0]
P_d = [2/3, -1/3, -1/3, 0; -1/3, 2/3, -1/3, 0; -1/3, -1/3, 2/3, 0; 0, 0, 0, 1]
K_b = E_s/(3·(1 - 2·n_s))
F_c = [1, 1, 1.25, 1.5, 2]
N_c = [1, 10, 10, 10, 10]
R_h = zeros(12, 2)
c_R = 0
C_q = zeros(11, 2)
T_F = zeros(5, 4)
u_p = zeros(18, 1)
u_q = zeros(18, 1)
P_1 = zeros(16, 1)
S_p = zeros(64, 1)
for i_c = 1:5
  F_k = F_c(i_c)
  p_r = atan(tan(f_r)/F_k)
  c_r = c_s/F_k
  a_l = 2·sin(p_r)/(sqrt(3)·(3 + sin(p_r)))
  k_d = 6·c_r·cos(p_r)/(sqrt(3)·(3 + sin(p_r)))
  n_p = N_c(i_c)
  S_g = S_0
  D_g = zeros(64, 4)
  for i = 1:16
    D_g(4·(i - 1) + 1:4·i, 1:4) = D_e
  end
  P_l = zeros(16, 1)
  u = zeros(18, 1)
  i_t = 0
  for i_n = 1:n_p
    F_e = F_p + F_z·i_n/n_p
    u_ini = u
    Q_t = S_g
    c_v = 0
    while c_v == 0
      F_n = zeros(18, 1)
      for i_e = 1:4
        for i_q = 1:4
          i_g = 4·(i_e - 1) + i_q
          F_n(G_e(i_e, 1:8)) = F_n(G_e(i_e, 1:8)) + transpose(B_s(4·(i_g - 1) + 1:4·i_g, 1:8))·Q_t(4·(i_g - 1) + 1:4·i_g)·w_s(i_g)
        end
      end
      R = F_e(L_b) - F_n(L_b)
      n_r = sqrt(sum(R.*R))
      if i_c == 1
        c_R = c_R + 1
        R_h(c_R, 1) = c_R - 1
        R_h(c_R, 2) = n_r
      end
      if n_r < 1e-9·sqrt(sum(F_e(L_b).*F_e(L_b)))
        c_v = 1
      else
        i_t = i_t + 1
        K_t = zeros(18, 18)
        for i_e = 1:4
          Kel = zeros(8, 8)
          for i_q = 1:4
            i_g = 4·(i_e - 1) + i_q
            B = B_s(4·(i_g - 1) + 1:4·i_g, 1:8)
            Kel = Kel + transpose(B)·D_g(4·(i_g - 1) + 1:4·i_g, 1:4)·B·w_s(i_g)
          end
          K_t(G_e(i_e, 1:8), G_e(i_e, 1:8)) = K_t(G_e(i_e, 1:8), G_e(i_e, 1:8)) + Kel
        end
        d_u = zeros(18, 1)
        d_u(L_b) = lsolve(K_t(L_b, L_b), R)
        u = u + d_u
        for i_e = 1:4
          for i_q = 1:4
            i_g = 4·(i_e - 1) + i_q
            B = B_s(4·(i_g - 1) + 1:4·i_g, 1:8)
            s_t = S_g(4·(i_g - 1) + 1:4·i_g) + D_e·B·(u(G_e(i_e, 1:8)) - u_ini(G_e(i_e, 1:8)))
            I_1 = s_t(1) + s_t(2) + s_t(3)
            s_m = I_1/3
            s_d = s_t - s_m·O_n
            J_2 = sqrt(max(0.5·(s_d(1)^2 + s_d(2)^2 + s_d(3)^2) + s_d(4)^2, 0))
            f_y = J_2 + a_l·I_1 - k_d
            D_p = D_e
            P_l(i_g) = 0
            if f_y > 1e-12
              P_l(i_g) = 1
              a_p = k_d/(3·a_l)
              o_k = 0
              if s_m < a_p
                if J_2 > 1e-12
                  if J_2 - f_y >= 1e-12
                    o_k = 1
                  end
                end
              end
              if o_k == 1
                b_t = (J_2 - f_y)/J_2
                s_t = s_m·O_n + b_t·s_d
                p_m = (s_t(1) + s_t(2) + s_t(3))/3
                d_v = s_t - p_m·O_n
                s_j = sqrt(max(0.5·(d_v(1)^2 + d_v(2)^2 + d_v(3)^2) + d_v(4)^2, 0))
                w_v = [d_v(1); d_v(2); d_v(3); 2·d_v(4)]/(2·s_j)
                g_v = w_v + a_l·O_n
                Z_i = K_b·O_n·transpose(O_n) + b_t·2·G_m·P_d
                Z_i(4, 4) = b_t·G_m
                Z_m = Z_i·w_v
                d_n = sum(g_v.*Z_m)
                D_p = Z_i - Z_m·(transpose(g_v)·Z_i)/d_n
              else
                s_t = [a_p; a_p; a_p; 0]
              end
            end
            Q_t(4·(i_g - 1) + 1:4·i_g) = s_t
            D_g(4·(i_g - 1) + 1:4·i_g, 1:4) = D_p
          end
        end
        if i_t > 60
          c_v = 2
        end
      end
    end
    S_g = Q_t
    if i_c == 2
      C_q(i_n + 1, 1) = q_z·i_n/n_p
      C_q(i_n + 1, 2) = -1000·u(14)
    end
  end
  T_F(i_c, 1) = F_k
  T_F(i_c, 2) = -1000·u(14)
  T_F(i_c, 3) = sum(P_l)
  T_F(i_c, 4) = i_t
  if i_c == 1
    u_p = u
    for i = 1:16
      P_1(i) = P_l(i)
    end
    S_p = S_g
  end
  if i_c == 2
    u_q = u
  end
end
#show
#: **Newton, vuelta por vuelta** (la zapata entera de una vez; residuo = la fuerza que todavía falta, en kN):
Newton = R_h(1:c_R, 1:2) 'columnas: vuelta, |R| [kN]
#: 158 → 12.6 → 0.70 → 0.0024 → 0.00000003 kN: en cada vuelta **se duplican las cifras correctas** (convergencia cuadrática, como en la hoja 198). Cuatro vueltas y listo.
d_nl = 1000·u_p(L_b) 'desplazamientos libres, no lineal [mm]
s_nl = -1000·u_p(14) 'ASIENTO bajo el centro, no lineal [mm]
r_nl = s_nl/s_lin 'cuánto más asienta que el elástico
n_pl = sum(P_1) 'puntos de Gauss plásticos (de 16)
#: **¿Qué significa?** El suelo real (con techo) asienta **10 % más** que el resorte elástico, porque 6 de los 16 puntos llegaron al techo y se ablandaron. **En una viga** de acero con cargas de servicio basta lo lineal; **en el suelo** el techo aparece enseguida, al lado de la zapata.
#: **La curva carga – asiento**, en 10 escalones (como hacen los programas: la plasticidad depende del camino, por eso se carga de a poco). Azul: elástico (una recta). Rojo: con el techo (se curva):
#hide
c_x = zeros(11, 1)
c_y = zeros(11, 1)
k_x = zeros(11, 1)
m_y = zeros(11, 1)
for i = 1:11
  c_x(i) = C_q(i, 1)
  c_y(i) = C_q(i, 2)
  k_x(i) = C_q(i, 1)/10
  m_y(i) = 0 - C_q(i, 2)
end
s_10 = c_y(11)
#show
s_10 'asiento con 10 escalones [mm] (de una vez: 20.32)
#dibujo("Curva carga – asiento bajo el centro de la zapata (pasa el cursor por los puntos rojos)", ud = m, escala = auto, alto = 90)
#  linea(0, 0, 23, 0, "fina")
#  linea(0, 0, 0, -23, "fina")
#  polilinea([0, 20], [0, -18.469], "gruesa azul")
#  polilinea(k_x, m_y, "gruesa rojo")
#  texto(23, -17.5, "elástico", 0.9, "c")
#  texto(23, -21, "con techo", 0.9, "c")
#  texto(10, 1.2, "q de la zapata [kPa] (cada raya = 50 kPa)", 0.9, "c")
#  linea(5, 0, 5, 0.4, "fina")
#  linea(10, 0, 10, 0.4, "fina")
#  linea(15, 0, 15, 0.4, "fina")
#  linea(20, 0, 20, 0.4, "fina")
#  texto(-3, -10, "asiento [mm]", 0.9, "c")
#  linea(0, -10, -0.4, -10, "fina")
#  linea(0, -20, -0.4, -20, "fina")
#  texto(-1.3, -20, "20", 0.8, "c")
#  texto(-1.3, -10, "10", 0.8, "c")
#  hover(k_x, m_y, "q = {#1:0} kPa: asiento = {#2:2} mm", c_x, c_y)
#fin
#: **En una línea:** carga a los nudos con las funciones de forma; lineal = un K·u = F (18.47 mm); no lineal = Newton con K_T y el residuo (20.32 mm, 6 puntos plásticos).

## 7 · Resultados: asiento, esfuerzos y puntos plásticos
#: **¿Qué problema hay?** Ya tenemos 8 números (los movimientos libres). Hay que convertirlos en lo que el ingeniero mira: cuánto baja la zapata, cómo se reparte el asiento, dónde el suelo está al límite.
#: **¿Qué se hace?** Desde los nudos: el asiento en cada punto se interpola con las mismas carpas N; los esfuerzos se leen en los puntos de Gauss (ahí se calcularon).
#hide
v_n = zeros(9, 1)
u_n = zeros(9, 1)
for i = 1:9
  v_n(i) = -1000·u_p(2·i)
  u_n(i) = 1000·u_p(2·i - 1)
end
#show
v_n 'asiento de cada nudo [mm] (positivo = baja)
#: Fíjate en los nudos 8 y 9 (la superficie al lado de la zapata): v₉ = −0.09 mm, **sube**. El suelo apretado bajo la zapata empuja hacia el costado y levanta la superficie vecina: es el principio del mecanismo de falla de una zapata.
#: **El asiento sobre la malla** (pasa el cursor; mm):
#campo(X_n, Y_n, E_q, v_n)
#: **La malla deformada** (× 20) y los **puntos de Gauss plásticos** (rojos: llegaron al techo; verdes: siguen elásticos):
#hide
x_d = zeros(9, 1)
y_d = zeros(9, 1)
for i = 1:9
  x_d(i) = X_n(i) + 20·u_p(2·i - 1)
  y_d(i) = Y_n(i) + 20·u_p(2·i)
end
x_r = zeros(16, 1)
y_r = zeros(16, 1)
x_v = zeros(16, 1)
y_v = zeros(16, 1)
for i = 1:16
  if P_1(i) == 1
    x_r(i) = X_g(i)
    y_r(i) = Y_g(i)
    x_v(i) = -10
    y_v(i) = -10
  else
    x_v(i) = X_g(i)
    y_v(i) = Y_g(i)
    x_r(i) = -10
    y_r(i) = -10
  end
end
x_7 = x_d(7)
y_7 = y_d(7)
x_8 = x_d(8)
y_8 = y_d(8)
x_9 = x_d(9)
y_9 = y_d(9)
x_4 = x_d(4)
y_4 = y_d(4)
x_5 = x_d(5)
y_5 = y_d(5)
x_6 = x_d(6)
y_6 = y_d(6)
#show
#dibujo("Malla deformada × 20 (gris: original) y puntos de Gauss: rojo = plástico, verde = elástico", ud = m, escala = auto, cotas = m, alto = 110)
#  poligono(0, 0, 4, 0, 4, 4, 0, 4, "fina")
#  linea(2, 0, 2, 4, "fina")
#  linea(0, 2, 4, 2, "fina")
#  polilinea([0, 2, 4], [0, 0, 0], "gruesa azul")
#  polilinea([x_4, x_5, x_6], [y_4, y_5, y_6], "gruesa azul")
#  polilinea([x_7, x_8, x_9], [y_7, y_8, y_9], "gruesa azul")
#  polilinea([0, x_4, x_7], [0, y_4, y_7], "gruesa azul")
#  polilinea([2, x_5, x_8], [0, y_5, y_8], "gruesa azul")
#  polilinea([4, x_6, x_9], [0, y_6, y_9], "gruesa azul")
#  rect(0, 4, 1, 0.25, "concreto")
#  circulo(0.42, 0.42, 0.09, "verde")
#  circulo(1.58, 0.42, 0.09, "verde")
#  circulo(1.58, 1.58, 0.09, "rojo")
#  circulo(0.42, 1.58, 0.09, "rojo")
#  circulo(2.42, 0.42, 0.09, "verde")
#  circulo(3.58, 0.42, 0.09, "verde")
#  circulo(3.58, 1.58, 0.09, "verde")
#  circulo(2.42, 1.58, 0.09, "verde")
#  circulo(0.42, 2.42, 0.09, "rojo")
#  circulo(1.58, 2.42, 0.09, "rojo")
#  circulo(1.58, 3.58, 0.09, "rojo")
#  circulo(0.42, 3.58, 0.09, "rojo")
#  circulo(2.42, 2.42, 0.09, "verde")
#  circulo(3.58, 2.42, 0.09, "verde")
#  circulo(3.58, 3.58, 0.09, "verde")
#  circulo(2.42, 3.58, 0.09, "verde")
#  hover(X_g, Y_g, "punto de Gauss en ({#1:2}, {#2:2}) m: plástico = {#3:0}", X_g, Y_g, P_1)
#fin
#hide
n_16 = zeros(16, 1)
for i = 1:16
  n_16(i) = i
end
#show
#tabla("punto:0","x [m]:2","y [m]:2","¿plástico? 1 = sí:0")(n_16; X_g; Y_g; P_1)
#: Los plásticos son los 4 del elemento 3 (justo bajo la zapata y a su lado) y los 2 de arriba del elemento 1: **la zona que trabaja más**, debajo del borde de la zapata, donde el corte es mayor.
#: **Esfuerzos en el elemento 3** (bajo la zapata), puntos de Gauss 1…4, compresión positiva [kPa] (columnas σ_x, σ_y, σ_z, τ_xy):
#hide
T_s = zeros(4, 4)
for i_q = 1:4
  i_g = 8 + i_q
  T_s(i_q, 1) = -S_p(4·(i_g - 1) + 1)
  T_s(i_q, 2) = -S_p(4·(i_g - 1) + 2)
  T_s(i_q, 3) = -S_p(4·(i_g - 1) + 3)
  T_s(i_q, 4) = S_p(4·(i_g - 1) + 4)
end
#show
S_e3 = T_s 'σ_x, σ_y, σ_z, τ_xy en los 4 puntos de Gauss del elemento 3 [kPa]
#: **El asiento como superficie 3D.** Dentro de la malla 2 × 2 el asiento es la suma de 9 carpas (una por nudo, de 2 m de ancho): v(x, y) = Σ vᵢ · N_i(x, y). Se escribe por filas de nudos (y = 0, 2 y 4 m):
#hide
v_1 = v_n(1)
v_2 = v_n(2)
v_3 = v_n(3)
v_4 = v_n(4)
v_5 = v_n(5)
v_6 = v_n(6)
v_7 = v_n(7)
v_8 = v_n(8)
v_9 = v_n(9)
#show
t_x(x, m) = max(0, 1 - abs(x - m)/2)
f_a(x, y) = (v_4·t_x(x, 0) + v_5·t_x(x, 2) + v_6·t_x(x, 4))·t_x(y, 2)
f_b(x, y) = (v_7·t_x(x, 0) + v_8·t_x(x, 2) + v_9·t_x(x, 4))·t_x(y, 4)
v_s(x, y) = f_a(x, y) + f_b(x, y)
#: (la fila de abajo, y = 0, no suma: está fija.) **3D** (arrastra para girar; x horizontal, y altura, asiento en mm):
#surf(v_s(x, y), [0 4], [0 4])
#: **2D, vista desde arriba** (el mismo campo; pasa el cursor):
#map(v_s(x, y), [0 4], [0 4])
#: **En una línea:** asiento máximo 20.32 mm bajo el centro, la superficie vecina sube un poco, y 6 de 16 puntos están en el techo bajo el borde de la zapata.

## 8 · Factor de seguridad: debilitar el suelo hasta que caiga
#: **¿Qué problema hay?** En una viga el factor de seguridad es directo: resistencia / solicitación. En el suelo **la resistencia depende del propio esfuerzo** (la fricción crece con el apretón): no hay una división directa.
#: **¿Qué se hace?** **Reducción de resistencia** (SRM): se deja la carga como está y se **debilita el suelo** con un factor F: c/F y tan φ/F. Se prueba F = 1, 1.25, 1.5, 2… Mientras Newton encuentre el equilibrio, el suelo aguanta. **El F con el que ya no hay equilibrio es el factor de seguridad.** Como probar cuánto se puede aflojar un nudo antes de que la carga se suelte.
c_red = Simplify{c/F}
#: y la fricción: tan φ_F = tan φ / F. Con F = 1.5, por ejemplo:
c_15 = c_s/1.5 'cohesión debilitada c/F [kPa]
p_15 = atan(tan(f_r)/1.5)·180/pi 'fricción debilitada φ_F [°] (era 30°)
#: **¿Qué número sale en esta malla?** (cada F con 10 escalones de carga; asiento bajo el centro, puntos plásticos de 16 y vueltas de Newton en total):
T_SR = T_F(2:5, 1:4) 'columnas: F, asiento [mm], plásticos, vueltas
#hide
r_x = zeros(4, 1)
r_y = zeros(4, 1)
for i = 1:4
  r_x(i) = T_F(i + 1, 1)
  r_y(i) = T_F(i + 1, 2)
end
#show
#dibujo("Asiento contra el factor F que debilita el suelo (pasa el cursor)", ud = m, escala = auto, alto = 85)
#  linea(100, 0, 210, 0, "fina")
#  linea(100, 0, 100, -36, "fina")
#  texto(100, -38.5, "F = 1", 2.2, "c")
#  texto(150, -29.5, "1.5", 2.2, "c")
#  texto(200, -35.5, "2", 2.2, "c")
#  polilinea([100, 125, 150, 200], [-20.2755, -23.2906, -26.3815, -32.2758], "gruesa rojo")
#  circulo(100, -20.2755, 0.9, "rojo")
#  circulo(125, -23.2906, 0.9, "rojo")
#  circulo(150, -26.3815, 0.9, "rojo")
#  circulo(200, -32.2758, 0.9, "rojo")
#  texto(155, 3, "F × 100", 2.4, "c")
#  texto(88, -18, "asiento [mm]", 2.4, "c")
#  hover([100, 125, 150, 200], [-20.2755, -23.2906, -26.3815, -32.2758], "F = {#1:2}: asiento = {#2:2} mm", r_x, r_y)
#fin
#: El asiento crece y los puntos plásticos se extienden (6 → 11 de 16)… pero **Newton sigue convergiendo**. Con solo 4 elementos la malla es demasiado **rígida**: no tiene «bisagras» para dibujar la cuña que desliza (se dice que **se bloquea**). Esta malla NO sirve para el factor de seguridad, y es la lección más importante del paso 8: **el FS necesita una malla fina**.
#: Con una malla de verdad (el talud de Griffiths y Lane con 144 triángulos T6, **hojas 190 y 195**) sí aparece el F en que Newton ya no converge: **FS = 1.407** con Mohr-Coulomb, **1.524** con el Drucker-Prager de GEO5 y **1.615** con el Mohr-Coulomb redondeado de OpenSees. La regla del techo cambia el FS.
#: **En una línea:** se debilita el suelo (c/F, tan φ/F) hasta que no hay equilibrio; ese F es el FS, y necesita una malla fina.

## 9 · ¿Está bien? El juez externo
#: El mismo modelo (9 nudos, 4 Q4 con 2 × 2 puntos de Gauss, mismos apoyos, mismas cargas) se corrió en **Hekatan OpenSees** (el OpenSees de Berkeley compilado; elemento quad PlaneStrain, ElasticIsotropic y DruckerPrager con ρ = √2·α, σ_Y = √3·k, sin dilatancia) y en un programa de **Python/numpy** escrito aparte:
#hide
w_h = [-v_7g, s_lin, d_lin(2), s_nl, d_nl(2), d_nl(8), s_10, T_F(3, 2), T_F(4, 2), T_F(5, 2)]
w_p = [4.8, 18.4694, 2.1301, 20.3229, 2.1904, 0.0941, 20.2755, 23.2906, 26.3815, 32.2758]
c_hoja = zeros(10, 1)
c_py = zeros(10, 1)
c_os = zeros(10, 1)
for i = 1:10
  c_hoja(i) = w_h(i)
  c_py(i) = w_p(i)
  c_os(i) = w_p(i)
end
#show
#tabla("Resultado","Esta hoja:4","Python numpy:4","OpenSees:4")({"asiento por peso propio [mm]","asiento lineal [mm]","u₅ lineal [mm]","asiento no lineal, 1 paso [mm]","u₅ no lineal [mm]","v₉ no lineal [mm] (+ = sube)","asiento 10 escalones, F = 1 [mm]","F = 1.25 [mm]","F = 1.5 [mm]","F = 2 [mm]"}; c_hoja; c_py; c_os)
#: Diferencia máxima nudo a nudo: lineal 2·10⁻¹⁵ mm; no lineal 3·10⁻⁹ mm y 2·10⁻⁸ kPa en los 16 puntos de Gauss. Los 6 puntos plásticos son los mismos.

## 10 · Resumen: los 8 pasos en una pantalla
#tabla("Paso","¿Qué problema hay?","¿Qué se hace?")({"1 · Qué cambia","2 · Malla y elemento","3 · Material","4 · Bordes","5 · Estado inicial","6 · Cargar y resolver","7 · Resultados","8 · Factor de seguridad"}; {"el suelo es continuo, largo, sin fin, pesado y con agua","infinitos puntos","¿cuánto esfuerzo da cada deformación?","el suelo cortado sigue empujando","el suelo ya está apretado por su peso","la carga está repartida; el suelo se ablanda","8 números no dicen nada solos","la resistencia depende del esfuerzo"}; {"elementos, deformación plana, frontera lejos, σ′ = σ − u","4 Q4, carpas N, Jacobiano, B","D elástica (λ, G) + techo Mohr-Coulomb / Drucker-Prager","base fija, rodillos, superficie libre","σ_v = γz, σ_h = K₀σ_v, luego u = 0","K·u = F lineal; Newton con K_T y residuo","interpolar con N; esfuerzos en Gauss","c/F, tan φ/F hasta que no converge"})
#: **Y qué número sale en el ejemplo:**
#tabla("Paso","¿Qué sale en el ejemplo?")({"1 · Qué cambia","2 · Malla y elemento","3 · Material","4 · Bordes","5 · Estado inicial","6 · Cargar y resolver","7 · Resultados","8 · Factor de seguridad"}; {"8 incógnitas en vez de infinitas","K de 8 × 8; el lado a se cancela","M = 30 000 kPa, α = 0.165, k = 8.57 kPa","8 de 18 movimientos libres","4.8 mm (= γH²/2M), 18 y 54 kPa","18.47 mm lineal → 20.32 mm no lineal","6 de 16 puntos plásticos; la superficie vecina sube","4 elementos no fallan → malla fina: FS 1.407…1.615"})
#: **Qué quedó:** los 8 pasos con números verificados. **Qué falta:** el agua (presión de poros y consolidación) y una malla fina para el factor de seguridad. **Qué hereda la siguiente hoja:** esta misma receta con agua (σ′ = σ − u) y más elementos.
