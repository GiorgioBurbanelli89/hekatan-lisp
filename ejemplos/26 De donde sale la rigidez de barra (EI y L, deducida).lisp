# De dónde sale la rigidez de una barra: EI y L, término a término
#: En los ejemplos anteriores la rigidez de una barra apareció ya hecha: el factor {EI/L^3} por una matriz de {12}, {6*L}, {4*L^2}. Aquí se DEDUCE de cero — equilibrio → funciones de forma → curvaturas → integral — con {EI} y {L} en símbolos. Cada número sale de una cuenta. Todo con el motor.

## 1 · Por qué la rigidez es ∫ curvatura·curvatura (de dónde sale la fórmula)
#: Dos hechos de la viga. Primero: una fibra a distancia {y} del eje se estira según la curvatura κ (secciones planas). Por la ley de Hooke la deformación es ε = −{y}·κ y la tensión σ = E·ε.
#: Sumando esa tensión por su brazo en toda la sección, el momento es rigidez por curvatura: M = {EI}·κ (el {EI} reúne el material E y la inercia de la sección).
#: Segundo: la energía que se guarda al doblar va con la curvatura AL CUADRADO (por eso todo gira en torno a κ): la energía por unidad de barra es u = ½·EI·κ².
#: Y la deformada es las funciones de forma {N} por los desplazamientos de los nudos {d}:
v = N*d @@(deformada de la barra)
#: Su curvatura se arma igual, pero con las CURVATURAS de las formas (las {N''}, que salen en el paso 4). Metida en la energía κ² e integrada por la barra, cada pareja de nudos deja multiplicando la integral de {N''} por {N''}, por {EI}. Comparando con la rigidez, sale término a término: cada entrada {K} es la curvatura de una forma por la de otra, integradas. Es justo lo que se calcula en el paso 6.

## 2 · De dónde sale {EI}·v⁗ = 0 (por qué la deformada es cúbica)
#: Antes de las funciones de forma, hay que justificar que la deformada del tramo es una CÚBICA. Sale de las derivadas de la deflexión v — cada una tiene su nombre físico. El giro es la pendiente de la deflexión, θ = dv/dx; la curvatura, la pendiente del giro, κ = dθ/dx = v″. Por el paso 1, el momento es M = {EI}·κ. El equilibrio del trocito manda: el cortante es la pendiente del momento, V = dM/dx; y la carga repartida, la del cortante, q = dV/dx. Encadenando, q = {EI}·v⁗.
#: Lo veo con una cúbica cualquiera {a0 + a1*x + a2*x^2 + a3*x^3} y derivo, paso a paso, hasta la 4ª:
theta = Diff{a0 + a1*x + a2*x^2 + a3*x^3 @ x} @@(giro θ = v′)
kappa = Diff{a1 + 2*a2*x + 3*a3*x^2 @ x} @@(curvatura κ = v″)
cortante = Diff{2*a2 + 6*a3*x @ x} @@(∝ cortante V = EI·v‴)
carga = Diff{6*a3 @ x} @@(∝ carga q = EI·v⁗)
#: La 4ª derivada da 0: dentro del tramo no hay carga repartida (q=0), así que {EI}·v⁗ = 0. Al revés, integrar cuatro veces devuelve la cúbica, con 4 constantes de integración — que son justo los 4 datos de nudo (descenso y giro en cada extremo). Por eso entre nudos la deformada es cúbica. De esa cúbica saco ahora las funciones de forma.

## 3 · De dónde salen las funciones de forma (se DEDUCEN)
#: La deformada es esa CÚBICA (paso 2): {a0 + a1*s + a2*s^2 + a3*s^3}. Tiene 4 coeficientes {a0}…{a3}, y se fijan con los 4 datos de los nudos: descenso y giro en cada extremo. Uso {s} = {x/L}, de 0 a 1.
#: Evalúo esa cúbica y su pendiente en los dos extremos ({s}=0 y {s}=1). Eso relaciona los coeficientes con los datos de nudo mediante la matriz A (fila 1 = valor en 0, fila 2 = pendiente en 0, fila 3 = valor en 1, fila 4 = pendiente en 1):
A = [1 0 0 0; 0 1 0 0; 1 1 1 1; 0 1 2 3] @@(evaluaciones de v y su pendiente)
#: La invierto para tener los coeficientes en función de los datos de nudo (coef = A⁻¹·datos):
Ainv = A^-1 @@(coeficientes desde los nudos)
#: La deformada es la base cúbica por los coeficientes; agrupando, cada COLUMNA de base·A⁻¹ es una función de forma:
base = [1 s s^2 s^3] @@(base cúbica)
Nnat = base*Ainv @@(las formas, aún sin L)
#: Falta el {L}. El giro físico es θ = dv/dx, y como {s} = {x/L}, cada derivada en {x} trae un {1/L}: θ = {1/L}·dv/ds. Por eso en los datos el giro entra como {L}·θ; para que las formas multipliquen al giro θ hay que devolver ese {L} en las columnas de giro (2 y 4) con la diagonal diag(1, L, 1, L):
Ldiag = [1 0 0 0; 0 L 0 0; 0 0 1 0; 0 0 0 L] @@(el L del giro)
Nrow = base*Ainv*Ldiag @@(las 4 de Hermite, deducidas)
#: Leídas de Nrow (idénticas al ejemplo 24): las de giro llevan su {L}, las de descenso no.
N1 = 1 - 3*s^2 + 2*s^3 @@(descenso izquierdo)
N2 = L*(s - 2*s^2 + s^3) @@(giro izquierdo, con su L)
N3 = 3*s^2 - 2*s^3 @@(descenso derecho)
N4 = L*(-s^2 + s^3) @@(giro derecho, con su L)

## 4 · La curvatura de cada peso (segunda derivada)
#: Derivo cada función dos veces respecto a {s}. Salen lineales (la curvatura de una cúbica):
N1s = Diff{1 - 3*s^2 + 2*s^3 @ s} @@(pendiente de N₁)
N1ss = Diff{-6*s + 6*s^2 @ s} @@(curvatura de N₁)
N2s = Diff{L*s - 2*L*s^2 + L*s^3 @ s} @@(pendiente de N₂)
N2ss = Diff{L - 4*L*s + 3*L*s^2 @ s} @@(curvatura de N₂)
N3ss = Diff{6*s - 6*s^2 @ s} @@(curvatura de N₃)
N4ss = Diff{-2*L*s + 3*L*s^2 @ s} @@(curvatura de N₄)

## 5 · El cambio de variable trae las potencias de L
#: Aquí nace el {EI/L^3}. Como {s} = {x/L}, derivar respecto a {x} mete un {1/L} por cada derivada: dos derivadas → {1/L^2}. Y al integrar en {x} aparece un factor {L} más. Juntando los tres, el factor común que sale afuera es {EI/L^3}; adentro quedan las curvaturas en {s}, con sus factores {L} de N2 y N4.

## 6 · La integral: de dónde salen 12, 6L, 4L²
#: Cada término es la integral del producto de dos curvaturas, de 0 a 1. Los factores {L} de las funciones de giro quedan dentro y suben la potencia de {L}:
k11 = Area{(-6+12*s)^2 @ s=0:1} @@(descenso izq con descenso izq)
k12 = Area{(-6+12*s)*L*(-4+6*s) @ s=0:1} @@(descenso izq con giro izq)
k13 = Area{(-6+12*s)*(6-12*s) @ s=0:1} @@(descenso izq con descenso der)
k22 = Area{L*(-4+6*s)*L*(-4+6*s) @ s=0:1} @@(giro izq con giro izq)
k24 = Area{L*(-4+6*s)*L*(-2+6*s) @ s=0:1} @@(giro izq con giro der)
#: Ni un solo factor {L} en descenso–descenso (queda {12}), uno en descenso–giro ({6*L}), dos en giro–giro ({4*L^2}). Junto el factor común y la matriz de las 16 integrales:
factorL = EI/L^3 @@(el factor común)
K_coef = [12, 6*L, -12, 6*L; 6*L, 4*L^2, -6*L, 2*L^2; -12, -6*L, 12, -6*L; 6*L, 2*L^2, -6*L, 4*L^2] @@(la matriz de coeficientes)
#: La rigidez de la barra es el factor {factorL} por esa matriz K_coef. Es EXACTAMENTE la de los ejemplos 24 y 25; con {EI}=1 y {L}=1 da los números. Cada uno salió de una integral: el {12} de la de {(-6+12*s)^2}; el {6*L}, la misma con un factor {L}; el {4*L^2}, con dos. Ahí queda deducida, término a término.
