# De dónde sale la rigidez de una barra: EI y L, término a término
#: Aquí se DEDUCE de cero, empezando por un trocito de viga: equilibrio → ecuación de la viga → forma cúbica → funciones de forma → curvaturas → energía → integral. Con {EI} y {L} en símbolos, cada número sale de una cuenta. Todo con el motor.

## 1 · El comienzo: el equilibrio de un trocito de viga
#: Todo empieza aquí. Corto un pedacito de viga de ancho {dx} y le miro las fuerzas. En la cara izquierda actúan el momento {M} y el cortante {V}; en la derecha, un poco cambiados: {M + dM} y {V + dV}. Encima, la carga repartida {q}. El trocito está quieto, así que fuerzas y momentos se equilibran:
#slice
#: Dos condiciones de equilibrio, y de cada una sale una ley. Sumo las fuerzas verticales de las dos caras más la carga (todo el trocito, y vale cero):
Fy = V - (V + dV) - q*dx @@(fuerzas verticales = 0)
#: Se cancela {V} y sobra el cambio {dV} contra la carga {q}: el cortante cae al ritmo de la carga. Ahora sumo los momentos respecto a una cara (también cero, los términos con dx·dx se desprecian):
Mo = (M + dM) - M - V*dx @@(momentos = 0)
#: Se cancela {M} y sobra el cambio {dM} contra el cortante {V}: el momento crece al ritmo del cortante.

## 2 · Qué es v (la deflexión) y la ecuación de la viga
#: Primero, qué es v. La deflexión v es cuánto BAJA el eje de la viga en cada punto x — la forma que toma al cargarse. Es la INCÓGNITA de todo el problema. OJO: v (minúscula, la deflexión) NO es V (mayúscula, el cortante del paso 1); son cosas distintas.
#defl
#: Sus derivadas tienen nombre propio: la 1ª, v′, es el giro (la pendiente del eje); la 2ª, v″, es la curvatura (cuánto se dobla); y la 4ª, v⁗, es la que aparece en la ecuación de la viga.
#: Ahora ligo el momento {M} con esa forma, en dos pasos. Geometría (flechas pequeñas): la curvatura es la segunda derivada de la deflexión — v″. Material y sección: por Hooke cada fibra tira según su distancia al eje; al sumar esas tensiones por su brazo, el momento {M} es la rigidez {EI} por la curvatura (la {EI} reúne el módulo E y la inercia de la sección).
#: Ahora junto las tres leyes. Del paso 1: la pendiente del momento es el cortante {V}, y la pendiente del cortante es menos la carga {q}. Y acá: el momento {M} es {EI} por la curvatura. Encadenándolas, la carga {q} queda igual a {EI} por la CUARTA derivada de la deflexión: esa es la ecuación de la viga.
#: DENTRO del tramo, entre nudo y nudo, no hay carga repartida: la carga {q} vale cero. Entonces la cuarta derivada de la deflexión es cero. Eso es lo que resuelvo, con el motor, en el paso 3.

## 3 · Una viga de verdad: el voladizo, resuelto con L
#: Para ver el mecanismo con FÓRMULAS reales, resuelvo primero una viga concreta de largo {L}: un voladizo (empotrado a la izquierda, libre a la derecha) con una carga {P} en la punta. Por estática, el momento a una distancia {x} del empotramiento es:
Mvol = -P*(L - x) @@(momento del voladizo)
#: La ecuación de la viga dice que {EI} por la curvatura es el momento. Integro el momento una vez y sale {EI} por el giro. El empotramiento no deja girar en el arranque (el giro en {x}=0 es cero), así que la constante de integración es cero:
EIvp = Integral{-P*(L - x) @ x} @@(EI·v′, giro × EI; la +C = 0)
#: Integro otra vez y sale {EI} por la deflexión. El empotramiento tampoco deja bajar en el arranque (la deflexión en {x}=0 es cero), así que otra vez la constante es cero:
EIv = Integral{-P*L*x + P*x^2/2 @ x} @@(EI·v, deflexión × EI; la +C = 0)
#: {EIv} dividido por {EI} es la deflexión. En la punta ({x}={L}) da la fórmula clásica del voladizo, {vpunta}:
vpunta = -P*L^3/(3*EI) @@(flecha en la punta)
#: OJO al resultado: la deflexión salió un polinomio de grado 3 — una CÚBICA en {x}. No es casualidad: sin carga dentro del tramo, la ecuación es {EI}·v⁗ = 0 y su solución es SIEMPRE una cúbica (4 constantes). Aquí las fijó el empotramiento; en un elemento de dos nudos las fijan los 4 datos de nudo (descenso y giro en cada punta). Eso es el paso 4.

## 4 · Las funciones de forma (una por cada dato de nudo)
#: La deformada del elemento es la cúbica del paso 3. Cada función de forma es esa cúbica cuando UN dato de nudo vale 1 y los otros tres valen 0 — así, multiplicando cada forma por su dato de nudo y sumando, se arma cualquier deformada. Trabajo en la coordenada {s} = {x/L}, de 0 a 1. OJO con el giro: como {s} = {x/L}, el giro físico es θ = {1/L}·dv/ds; por eso un giro unitario pide una pendiente {L} en {s}, y las funciones de giro salen multiplicadas por {L}.
#: Parto de la cúbica en {s} y de su pendiente (la necesito para las condiciones de giro):
vpol = a0 + a1*s + a2*s^2 + a3*s^3 @@(cúbica: 4 coeficientes por fijar)
vslope = Diff{a0 + a1*s + a2*s^2 + a3*s^3 @ s} @@(la pendiente dv/ds)
#: N1 — descenso unitario en el nudo izquierdo. En {s}=0 la cúbica vale 1 y no gira: eso da {a0}=1 y {a1}=0 (la pendiente en 0 es justo {a1}). En {s}=1 la cúbica vale 0 y no gira: con {a0}=1 y {a1}=0 esas dos condiciones son 1+{a2}+{a3}=0 y {a1}+2·{a2}+3·{a3}=0. De ahí sale {a3}=2 y {a2}=−3. Sustituyendo los cuatro en la cúbica:
N1 = 1 - 3*s^2 + 2*s^3 @@(descenso izquierdo)
#: N2 — giro unitario en el izquierdo. Ahora la cúbica no baja pero gira 1 en {s}=0: como θ = {1/L}·dv/ds, un giro 1 pide pendiente {L}, o sea {a0}=0 y {a1}={L}. Con v=0 y sin giro en {s}=1 salen {a2}=−2·{L} y {a3}={L}: por eso N2 lleva el {L}:
N2 = L*(s - 2*s^2 + s^3) @@(giro izquierdo, con su L)
#: N3 y N4 son lo mismo pero con el descenso y el giro unitarios en el extremo DERECHO ({s}=1):
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
#: La rigidez de la barra es el factor {factorL} por esa matriz K_coef — toda en símbolos, con {EI} y {L}. Cada coeficiente salió de una integral: el {12} de la de {(-6+12*s)^2}; el {6*L}, la misma con un factor {L}; el {4*L^2}, con dos. Ahí queda deducida, término a término, sin meter un solo número.
