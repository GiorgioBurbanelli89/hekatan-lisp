# De dónde sale la rigidez de una barra: EI y L, término a término
#: Aquí se DEDUCE de cero, empezando por un trocito de viga: equilibrio → ecuación de la viga → forma cúbica → funciones de forma → curvaturas → energía → integral. Con {EI} y {L} en símbolos, cada número sale de una cuenta. Todo con el motor.

## 1 · El comienzo: el equilibrio de un trocito de viga
#: Todo empieza aquí. Corto un pedacito de viga de ancho {dx} y le miro las fuerzas. En la cara izquierda actúan el momento {M} y el cortante {V}; en la derecha, un poco cambiados: {M + dM} y {V + dV}. Encima, la carga repartida {q}. El trocito está quieto, así que fuerzas y momentos se equilibran:
#slice
#: Dos condiciones de equilibrio, y de cada una sale una ley:
#: (1) Fuerzas verticales, la suma es cero: {V - (V + dV) - q*dx} = 0. Se cancela {V}, queda {-dV} = {q*dx}, es decir {dV/dx} = {-q}. El cortante cae al ritmo de la carga.
#: (2) Momentos, la suma es cero (los términos {dx*dx} son despreciables): {dM - V*dx} = 0, o sea {dM/dx} = {V}. El momento crece al ritmo del cortante.

## 2 · Geometría y material: la ecuación de la viga EI·v⁗ = q
#: Falta ligar el momento con la FORMA de la viga. Geometría (flechas pequeñas): la curvatura es la segunda derivada de la deflexión, κ = v″ — cuánto se dobla. Material + sección: por Hooke, la fibra a distancia {y} del eje tiene tensión σ = E·(−{y}·κ); sumando esa tensión por su brazo en toda la sección sale el momento {M} = {EI}·κ (el {EI} reúne el módulo E y la inercia de la sección). Juntando, {M} = {EI}·v″.
#: Ahora encadeno las tres leyes: de (2), {V} = {dM/dx}; de (1), {-dV/dx} = {q}. Derivando {M} = {EI}·v″ dos veces y sustituyendo, la ecuación de la viga es {EI}·v⁗ = {q}.
#: DENTRO del tramo, entre nudo y nudo, no hay carga repartida: {q} = 0. Por lo tanto {EI}·v⁗ = 0. Esa es la ecuación que gobierna la deformada de la barra.

## 3 · {EI}·v⁗ = 0 quiere decir: la deformada es CÚBICA
#: Compruebo que una cúbica cualquiera {a0 + a1*x + a2*x^2 + a3*x^3} cumple v⁗ = 0. Derivo, paso a paso, y cada derivada tiene su nombre físico:
theta = Diff{a0 + a1*x + a2*x^2 + a3*x^3 @ x} @@(giro θ = v′)
kappa = Diff{a1 + 2*a2*x + 3*a3*x^2 @ x} @@(curvatura κ = v″)
cortante = Diff{2*a2 + 6*a3*x @ x} @@(∝ cortante V = EI·v‴)
carga = Diff{6*a3 @ x} @@(∝ carga q = EI·v⁗)
#: La 4ª derivada da 0: se cumple {EI}·v⁗ = 0. Al revés, integrar cuatro veces devuelve la cúbica, con 4 constantes de integración — que son justo los 4 datos de nudo (descenso y giro en cada extremo). Por eso entre nudos la deformada es cúbica. De esa cúbica saco ahora las funciones de forma.

## 4 · De dónde salen las funciones de forma (se DEDUCEN)
#: La deformada es esa CÚBICA (paso 3): {a0 + a1*s + a2*s^2 + a3*s^3}. Tiene 4 coeficientes {a0}…{a3}, y se fijan con los 4 datos de los nudos: descenso y giro en cada extremo. Uso {s} = {x/L}, de 0 a 1.
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

## 5 · La curvatura de cada peso (segunda derivada)
#: Derivo cada función dos veces respecto a {s}. Salen lineales (la curvatura de una cúbica):
N1s = Diff{1 - 3*s^2 + 2*s^3 @ s} @@(pendiente de N₁)
N1ss = Diff{-6*s + 6*s^2 @ s} @@(curvatura de N₁)
N2s = Diff{L*s - 2*L*s^2 + L*s^3 @ s} @@(pendiente de N₂)
N2ss = Diff{L - 4*L*s + 3*L*s^2 @ s} @@(curvatura de N₂)
N3ss = Diff{6*s - 6*s^2 @ s} @@(curvatura de N₃)
N4ss = Diff{-2*L*s + 3*L*s^2 @ s} @@(curvatura de N₄)

## 6 · El cambio de variable trae las potencias de L
#: Aquí nace el {EI/L^3}. Como {s} = {x/L}, derivar respecto a {x} mete un {1/L} por cada derivada: dos derivadas → {1/L^2}. Y al integrar en {x} aparece un factor {L} más. Juntando los tres, el factor común que sale afuera es {EI/L^3}; adentro quedan las curvaturas en {s}, con sus factores {L} de N2 y N4.

## 7 · La energía: por qué la rigidez es ∫ curvatura·curvatura
#: Ya tengo las curvaturas de las formas. Falta ver por qué la rigidez es su integral. La energía que guarda la viga al doblarse va con la curvatura AL CUADRADO: la energía por unidad de barra es u = ½·{EI}·κ². Y la deformada es las funciones de forma por los desplazamientos de nudo:
v = N*d @@(deformada de la barra)
#: Su curvatura son las CURVATURAS de las formas (las {N''} del paso 5) por esos mismos desplazamientos. Al meter κ² en la energía e integrarla por la barra, cada pareja de nudos deja multiplicando la integral de {N''} por {N''}, por {EI}. Esa es justo la entrada {K} de la rigidez: cada término es EI·∫ curvatura·curvatura. Es lo que se calcula en el paso 8.

## 8 · La integral: de dónde salen 12, 6L, 4L²
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
