# ¿Qué es la curvatura? - la pendiente que cambia, el círculo osculador, κ = 1/R, vigas, Hermite, Taylor, Newton y placas
#numerico

## 0 · La idea en una frase
#: **La pendiente dice hacia dónde vas; la curvatura, qué tan rápido giras.** La pendiente y′ es la dirección de la curva en un punto. La curvatura κ (kappa) mide cuánto cambia esa dirección al avanzar sobre la curva, y es **uno sobre el radio del círculo que mejor se pega** a la curva en ese punto: κ = 1/R.
#: El camino de la hoja: ¿qué sé? (la pendiente) → ¿qué quiero? (medir cuánto se dobla) → ¿qué exijo? (un círculo con el mismo punto, la misma pendiente y la misma y″) → ¿qué sale? (κ = y″/(1 + y′²)^(3/2)) → ¿para qué? (vigas κ ≈ y″ = M/EI, la rigidez de Hermite, Taylor, Newton y las placas).
#: Primero el objeto. Los valores de cada punto (para el cursor):
h_x = [-1; -0.5; 0; 0.5; 1] 'cinco puntos de la curva [m]
h_y = h_x.^2 'y = x²
h_p = 2*h_x 'pendiente y′ = 2x
h_k = 2./(1 + 4*h_x.^2).^1.5 'κ [1/m]
h_R = 1./h_k 'R = 1/κ [m]
#dibujo("El objeto: la parábola y = x², su tangente en x = 0.5 y el círculo que mejor se pega (osculador). Pasa el cursor por la curva", ud = m, escala = auto, alto = 70)
#  flecha(-2.1, 0, 2.1, 0, "fina")
#  flecha(0, -0.4, 0, 2.9, "fina")
#  texto(2.2, -0.2, "x", 2.6, "c")
#  texto(0.15, 2.95, "y", 2.6, "c")
#  polilinea([-1.65, -1.595, -1.54, -1.485, -1.43, -1.375, -1.32, -1.265, -1.21, -1.155, -1.1, -1.045, -0.99, -0.935, -0.88, -0.825, -0.77, -0.715, -0.66, -0.605, -0.55, -0.495, -0.44, -0.385, -0.33, -0.275, -0.22, -0.165, -0.11, -0.055, 0, 0.055, 0.11, 0.165, 0.22, 0.275, 0.33, 0.385, 0.44, 0.495, 0.55, 0.605, 0.66, 0.715, 0.77, 0.825, 0.88, 0.935, 0.99, 1.045, 1.1, 1.155, 1.21, 1.265, 1.32, 1.375, 1.43, 1.485, 1.54, 1.595, 1.65], [2.7225, 2.544, 2.3716, 2.2052, 2.0449, 1.8906, 1.7424, 1.6002, 1.4641, 1.334, 1.21, 1.092, 0.9801, 0.8742, 0.7744, 0.6806, 0.5929, 0.5112, 0.4356, 0.366, 0.3025, 0.245, 0.1936, 0.1482, 0.1089, 0.0756, 0.0484, 0.0272, 0.0121, 0.003, 0, 0.003, 0.0121, 0.0272, 0.0484, 0.0756, 0.1089, 0.1482, 0.1936, 0.245, 0.3025, 0.366, 0.4356, 0.5112, 0.5929, 0.6806, 0.7744, 0.8742, 0.9801, 1.092, 1.21, 1.334, 1.4641, 1.6002, 1.7424, 1.8906, 2.0449, 2.2052, 2.3716, 2.544, 2.7225], "gruesa azul")
#  linea(-0.45, -0.7, 1.45, 1.2, "rojo")
#  circulo(-0.5, 1.25, 1.4142, "trazos verde")
#  circulo(-0.5, 1.25, 0.05, "verde relleno")
#  linea(-0.5, 1.25, 0.5, 0.25, "verde")
#  circulo(0.5, 0.25, 0.06, "rojo relleno")
#  texto(-0.5, 1.47, "centro C", 2.4, "c")
#  texto(0.4, 1.1, "R = 1.414", 2.4, "c")
#  texto(2.0, 0.95, "tangente: y′ = 1", 2.4, "c")
#  texto(1.25, -0.2, "κ = 1/R = 0.7071", 2.4, "c")
#  hover(h_x, h_y, "x = {#1:2}: y′ = {#3:3}, κ = {#4:4}, R = {#5:3}", h_x, h_y, h_p, h_k, h_R)
#fin

## 1 · Lo que ya sé: la pendiente y′
#: Una recta, y = m·x + b, tiene **la misma pendiente en todas partes**. El motor deriva:
p_r = Diff{3*x + 1 @ x} 'recta: siempre 3
#: Una curva **cambia de pendiente** al avanzar. En y = x²:
p_p = Diff{x^2 @ x} 'parábola: −2 en x = −1, 0 en x = 0, +2 en x = 1
#: La pendiente sola dice la **dirección**, no cuánto se dobla. Lo que mide el cambio de la pendiente es la **segunda derivada**:
s_p = Diff{Diff{x^2 @ x} @ x} 'y″ de la parábola
#: Recta y parábola con sus pendientes (pasa el cursor para leer el valor):
#fplot(recta = 3*x + 1, parabola = x^2, pendiente_recta = 3 + 0*x, pendiente_parabola = 2*x, [-2 2])

## 2 · Lo que quiero: cuánto gira la dirección (el volante)
#: Piensa en el volante de un auto: en una recta va quieto (κ = 0); en una curva suave se gira poco; en una curva cerrada, mucho. La curvatura es **cuántos radianes gira la tangente por cada metro recorrido sobre la curva**: κ = dθ/ds.
#dibujo("Lo que quiero medir: qué tan rápido gira la dirección (el volante). Recta: κ = 0 · curva suave R = 3 m: κ = 1/3 · curva cerrada R = 1 m: κ = 1", ud = m, escala = auto, alto = 60)
#  polilinea([0, 3], [0, 0], "gruesa")
#  polilinea([3, 3.1309, 3.2615, 3.3916, 3.5209, 3.6493, 3.7765, 3.9021, 4.0261, 4.1481, 4.2679, 4.3852, 4.5, 4.6119, 4.7207, 4.8263, 4.9284, 5.0268, 5.1213, 5.2118, 5.2981], [0, 0.0029, 0.0114, 0.0257, 0.0456, 0.0711, 0.1022, 0.1388, 0.1809, 0.2284, 0.2811, 0.339, 0.4019, 0.4698, 0.5425, 0.6199, 0.7019, 0.7882, 0.8787, 0.9732, 1.0716], "gruesa azul")
#  polilinea([5.2981, 5.3562, 5.4067, 5.4491, 5.4831, 5.5084, 5.5246, 5.5317, 5.5297, 5.5184, 5.498, 5.4688, 5.4309, 5.3847, 5.3307, 5.2694, 5.2012, 5.1269, 5.0471, 4.9626, 4.8741], [1.0716, 1.148, 1.2296, 1.3157, 1.4054, 1.498, 1.5926, 1.6882, 1.7842, 1.8795, 1.9732, 2.0646, 2.1528, 2.2369, 2.3162, 2.39, 2.4576, 2.5183, 2.5716, 2.617, 2.6541], "gruesa rojo")
#  texto(1.5, -0.35, "recta: volante quieto, κ = 0", 2.4, "c")
#  texto(6.4, 0.3019, "suave: R = 3 m, κ = 0.333", 2.4, "c")
#  texto(6.9321, 2.3144, "cerrada: R = 1 m, κ = 1", 2.4, "c")
#  flecha(0.6, 0.35, 1.6, 0.35, "fina")
#fin
#: La dirección es el ángulo θ de la tangente: tan θ = y′, o sea θ = atan(y′). La regla de la cadena da dθ/dx = y″/(1 + y′²) (la derivada de atan u es u′/(1 + u²)). Para la parábola, el motor deriva y′ y y″ y arma ese cociente:
t_h = Simplify{Diff{Diff{x^2 @ x} @ x}/(1 + Diff{x^2 @ x}^2)} 'dθ/dx de la parábola
#: Un pedacito de curva mide, por Pitágoras, ds = √(dx² + dy²) = √(1 + y′²)·dx. Dividiendo dθ/dx entre ds/dx = √(1 + 4x²):
k_p = Simplify{Diff{Diff{x^2 @ x} @ x}/(1 + Diff{x^2 @ x}^2)/(1 + Diff{x^2 @ x}^2)^(1/2)} 'κ = dθ/ds de la parábola
#: **κ = 2/(1 + 4x²)^(3/2)**: alta en el fondo de la parábola y casi cero en los lados, donde ya es casi recta.

## 3 · Lo que exijo: el círculo que mejor se pega (osculador)
#: Hay muchos círculos que tocan la curva en un punto, pero uno solo la **copia hasta la segunda derivada**: mismo punto, misma pendiente y misma y″. Es el **círculo osculador** («el que besa»). Se parte de lo que se sabe: el círculo de centro (a, b) y radio R, (x − a)² + (y − b)² = R². Su rama de abajo es y = b − √(R² − (x − a)²). El motor deriva una y dos veces:
#: Para no arrastrar x − a se llama u = x − a (derivar en x o en u es lo mismo):
c_1 = Diff{b - sqrt(R^2 - u^2) @ u} 'y′ del círculo
c_2 = Simplify{Diff{Diff{b - sqrt(R^2 - u^2) @ u} @ u}} 'y″ del círculo = R²/(R² − u²)^(3/2)
#: Ahora la pregunta: ¿qué combinación de y′ y y″ devuelve el radio R, sin importar el punto? Se arma 1 + y′²:
o_c = Simplify{1 + u^2/(R^2 - u^2)} '1 + y′² del círculo
#: y se prueba (1 + y′²)³/y″² = (R²/(R² − u²))³·(R² − u²)³/R⁴:
r_c = Simplify{(R^2/(R^2 - u^2))^3*(R^2 - u^2)^3/R^4} '¡R², en todo punto!
#: Entonces **(1 + y′²)^(3/2)/y″ = R**: la u se fue, el resultado no depende del punto. Comprobación con números (R = 5, u = 3):
r_n = (1 + (3/sqrt(25 - 9))^2)^1.5/(25/(25 - 9)^1.5) 'debe dar 5
#: (A mano es lo mismo: derivar el círculo dos veces da (x − a) + (y − b)·y′ = 0 y 1 + y′² + (y − b)·y″ = 0; de ahí y − b = −(1 + y′²)/y″, x − a = y′(1 + y′²)/y″, y al meterlos en el círculo queda R² = (1 + y′²)³/y″².)
#: Como el osculador tiene **la misma y′ y la misma y″ que la curva**, la fórmula vale para cualquier curva:
#: **R = (1 + y′²)^(3/2)/|y″| y κ = 1/R = y″/(1 + y′²)^(3/2)** — la misma que salió en la sección 2 con κ = dθ/ds.
#: El **signo** dice hacia dónde se dobla: **κ > 0, sonrisa ∪** (se abre hacia arriba); **κ < 0, tristeza ∩**. El centro del osculador está en x_C = x − y′(1 + y′²)/y″, y_C = y + (1 + y′²)/y″. Para y = x² en x = t:
x_C = Simplify{t - 2*t*(1 + 4*t^2)/2} 'centro, coordenada x
y_C = Simplify{t^2 + (1 + 4*t^2)/2} 'centro, coordenada y

## 4 · Lo que sale: ejemplos con números
k_0 = 2/(1 + 0^2)^1.5 'y = x² en x = 0 [1/m]
R_0 = 1/k_0 'radio [m]
k_1 = 2/(1 + 2^2)^1.5 'y = x² en x = 1: 2/5^1.5 [1/m]
R_1 = 1/k_1 'radio [m]
#: Un círculo de radio 5 (rama baja, en x = 3: y′ = 3/4, y″ = 25/64) da 0.2 en cualquier punto, y una recta, 0:
k_5 = (25/64)/(1 + (3/4)^2)^1.5 'círculo R = 5 → 1/5
k_s = -sin(pi/2)/(1 + cos(pi/2)^2)^1.5 'sin x en π/2: tristeza, R = 1
#: La parábola y su κ(x): una campana alta en el centro (κ = 2) y casi cero en los lados:
#fplot(parabola = x^2, kappa = 2/(1 + 4*x^2)^1.5, [-2 2])
#: **El círculo osculador que viaja.** Mueve n (el punto x = n): el círculo se achica en el fondo (R = 0.5) y crece hacia los lados (R = 5.59 en n = 1). Ojo: los ejes no tienen la misma escala, el círculo se ve ovalado:
#slider fplot(parabola = x^2, tangente = n^2 + 2*n*(x - n), osculador = 3*n^2 + 0.5 - sqrt(((1 + 4*n^2)^1.5/2)^2 - (x + 4*n^3)^2), [-2 2]), n = -1:0.25:1
#anim fplot(parabola = x^2, tangente = n^2 + 2*n*(x - n), osculador = 3*n^2 + 0.5 - sqrt(((1 + 4*n^2)^1.5/2)^2 - (x + 4*n^3)^2), [-2 2]), n = -1:0.05:1
#: El seno: en π/2 (la cima) κ = −1, tristeza; en π, donde cruza el cero, y″ = 0 y κ = 0: **punto de inflexión**, la curva pasa de tristeza a sonrisa:
#fplot(seno = sin(x), kappa = -sin(x)/(1 + cos(x)^2)^1.5, [0 6.2832])
#: **En 3D:** κ en función de x y de a, para la familia y = a·x². Más a, más cerrada y más alta la campana en x = 0 (κ = 2a):
#surf(2*y/(1 + 4*y^2*x^2)^1.5, [-2 2], [0.2 2])

## 5 · Para qué: por qué en vigas basta con y″
#dibujo("La viga simplemente apoyada con carga q: la flecha δ = L/250 (dibujada 60 veces mayor) y su pendiente máxima θ en el apoyo", ud = m, escala = auto, cotas = m, alto = 50)
#  linea(0, 0, 6, 0, "fina")
#  polilinea([0, 0.15, 0.3, 0.45, 0.6, 0.75, 0.9, 1.05, 1.2, 1.35, 1.5, 1.65, 1.8, 1.95, 2.1, 2.25, 2.4, 2.55, 2.7, 2.85, 3, 3.15, 3.3, 3.45, 3.6, 3.75, 3.9, 4.05, 4.2, 4.35, 4.5, 4.65, 4.8, 4.95, 5.1, 5.25, 5.4, 5.55, 5.7, 5.85, 6], [0, -0.1151, -0.2293, -0.3419, -0.452, -0.5591, -0.6624, -0.7613, -0.8552, -0.9436, -1.026, -1.1019, -1.1709, -1.2326, -1.2868, -1.3331, -1.3713, -1.4013, -1.4227, -1.4357, -1.44, -1.4357, -1.4227, -1.4013, -1.3713, -1.3331, -1.2868, -1.2326, -1.1709, -1.1019, -1.026, -0.9436, -0.8552, -0.7613, -0.6624, -0.5591, -0.452, -0.3419, -0.2293, -0.1151, 0], "gruesa azul")
#  flecha(0, 0.75, 0, 0.1, "rojo")
#  flecha(1, 0.75, 1, 0.1, "rojo")
#  flecha(2, 0.75, 2, 0.1, "rojo")
#  flecha(3, 0.75, 3, 0.1, "rojo")
#  flecha(4, 0.75, 4, 0.1, "rojo")
#  flecha(5, 0.75, 5, 0.1, "rojo")
#  flecha(6, 0.75, 6, 0.1, "rojo")
#  linea(0, 0.75, 6, 0.75, "rojo")
#  texto(3, 1.0, "q", 2.8, "c")
#  poligono(0, 0, -0.2, -0.35, 0.2, -0.35, "fina")
#  poligono(6, 0, 5.8, -0.35, 6.2, -0.35, "fina")
#  cota(0, -1.85, 6, -1.85, 0, "L")
#  cota(3.3, 0, 3.3, -1.44, 0, "δ = L/250")
#  linea(0, 0, 1.6, -1.2288, "trazos rojo")
#  texto(1.95, -0.95, "θ = 0.0128 (×60)", 2.4, "c")
#fin
#: La viga simplemente apoyada con carga q tiene flecha y = q·x·(L³ − 2Lx² + x³)/(24·EI). Su flecha al centro y su pendiente en el apoyo (el motor):
d_v = Simplify{q*(L/2)*(L^3 - 2*L*(L/2)^2 + (L/2)^3)/(24*EI)} 'flecha δ al centro
t_v = Simplify{Diff{q*x*(L^3 - 2*L*x^2 + x^3)/(24*EI) @ x}} 'pendiente y′(x)
r_v = Simplify{(q*L^3/(24*EI))/(5*q*L^4/(384*EI))} 'θ(0)/δ = 16/(5L)
#: Con la flecha de servicio **δ = L/250**: θ_max = 16/(5L)·L/250, y el error de cambiar κ por y″ es 1 − 1/(1 + θ²)^1.5:
p_m = 16/(5*250) 'pendiente máxima [rad]
e_m = 100*(1 - 1/(1 + p_m^2)^1.5) 'error de κ ≈ y″ [%]
#: **0.025 %**: el denominador (1 + y′²)^(3/2) es prácticamente 1 y **κ ≈ y″**. Con la ley de la viga (Euler-Bernoulli) **κ = M/EI**: más momento, más se dobla; más rigidez EI, menos. Si la pendiente fuera 0.5 (un cable, un arco con grandes desplazamientos), el error sería:
e_c = 100*(1 - 1/(1 + 0.5^2)^1.5) 'error con pendiente 0.5 [%]
#: El error en función de la pendiente:
#fplot(error_pct = 100*(1 - 1/(1 + x^2)^1.5), [0 0.6])
#: **La hipótesis κ ≈ y″ en movimiento:** la viga y = n·x·(1 − x) con flecha creciente (n). Con n chico la curvatura exacta (azul) y la aproximada y″ = −2n coinciden; al crecer n se separan en los apoyos:
#anim fplot(kappa_exacta = -2*n/(1 + (n*(1 - 2*x))^2)^1.5, kappa_aprox = -2*n + 0*x, [0 1]), n = 0.02:0.04:1

## 6 · Dónde ya la vimos
#: **Hermite (viga de elementos finitos).** La flecha dentro del elemento es w = N·d; la curvatura es su segunda derivada: **B = N″**. La primera función de Hermite y su curvatura (el motor):
B_1 = Diff{Diff{1 - 3*x^2/L^2 + 2*x^3/L^3 @ x} @ x} 'N₁″: la curvatura que da el desplazamiento 1
B_2 = Diff{Diff{x - 2*x^2/L + x^3/L^2 @ x} @ x} 'N₂″
#: La rigidez es la **energía de doblarse**: U = ½∫EI·κ² dx, de donde K = ∫ EI·B·Bᵀ dx. Tres términos, integrados por el motor:
K_11 = Integral{EI*(12*x/L^3 - 6/L^2)^2 @ x = 0 : L} '12EI/L³
K_12 = Integral{EI*(12*x/L^3 - 6/L^2)*(6*x/L^2 - 4/L) @ x = 0 : L} '6EI/L²
K_22 = Integral{EI*(6*x/L^2 - 4/L)^2 @ x = 0 : L} '4EI/L
#: N₁ y su curvatura N₁″ con L = 1 (la curvatura de un polinomio cúbico es una recta):
#fplot(N_1 = 1 - 3*x^2 + 2*x^3, curvatura = 12*x - 6, [0 1])
#: **Taylor.** El término c₂ = f″(a)/2 sale de exigir que el polinomio tenga la **misma curvatura** que la curva. Para cos x en 0:
t_2 = Diff{Diff{cos(x) @ x} @ x}/2 'c₂ = f″/2, que en x = 0 vale −1/2
#: **Newton.** La recta tangente tira el término ½·R″·Δd², que es el de curvatura: si la curva se dobla poco cerca de la solución, ese término es chico y Newton converge rápido (hoja 203, sección 1.5).
#: **Placas (Kirchhoff).** La superficie w(x, y) se dobla en x (κₓ), en y (κ_y) y se **tuerce** (κₓᵧ, la torsión: como una hoja tomada por dos esquinas). Con el signo de Kirchhoff, κ = −∂²w. Para w = 0.3x² + 0.15y² + 0.2xy:
kappa_x = Simplify{-Diff{Diff{3*x^2/10 + 3*y^2/20 + x*y/5 @ x} @ x}} 'κ en x
kappa_y = Simplify{-Diff{Diff{3*x^2/10 + 3*y^2/20 + x*y/5 @ y} @ y}} 'κ en y
kappa_xy = Simplify{-2*Diff{Diff{3*x^2/10 + 3*y^2/20 + x*y/5 @ x} @ y}} 'κ en xy: la torsión
#surf(0.3*x^2 + 0.15*y^2 + 0.2*x*y, [-1 1], [-1 1])
#: La misma placa en planta (bandas de w); las bandas inclinadas son el efecto de la torsión xy:
#map(0.3*x^2 + 0.15*y^2 + 0.2*x*y, [-1 1], [-1 1])

## 7 · En una frase
#: **La pendiente dice hacia dónde vas; la curvatura, qué tan rápido giras.** κ = dθ/ds = 1/R = y″/(1 + y′²)^(3/2); en vigas κ ≈ y″ = M/EI (error 0.025 % con δ = L/250); en Hermite B = N″ y K = ∫EI·B·Bᵀ dx; en Taylor c₂ = f″/2; en Newton es lo que se tira; en placas son tres: κₓ, κ_y y κₓᵧ.
