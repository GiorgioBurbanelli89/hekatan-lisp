# De dónde sale la rigidez de una barra: EI y L, término a término
#: En los ejemplos anteriores la rigidez de una barra apareció ya hecha: el factor {EI/L^3} por una matriz de {12}, {6*L}, {4*L^2}. Aquí se DEDUCE de cero — funciones de forma → curvaturas → integral — con {EI} y {L} en símbolos. Cada número sale de una cuenta. Todo con el motor.

## 1 · Por qué la rigidez es ∫ curvatura·curvatura (de dónde sale la fórmula)
#: Dos hechos de la viga. Primero: una fibra a distancia {y} del eje se estira según la curvatura {kappa} (secciones planas), y su tensión sigue a la ley de Hooke:
eps = -y*kappa @@(deformación de la fibra)
sigma = E*eps @@(ley de Hooke)
#: Sumando esa tensión por su brazo en toda la sección, el momento es rigidez por curvatura ({EI} reúne el material {E} y la inercia de la sección):
M = EI*kappa @@(momento y curvatura)
#: Segundo: la energía que se guarda al doblar va con la curvatura AL CUADRADO (por eso todo gira en torno a {kappa}):
u = 1/2*EI*kappa^2 @@(energía de flexión por unidad de barra)
#: Y la deformada es las funciones de forma {N} por los desplazamientos de los nudos {d}:
v = N*d @@(deformada de la barra)
#: Su curvatura se arma igual, pero con las CURVATURAS de las formas (las {N''}, que salen en el paso 3). Metida en la energía {kappa^2} e integrada por la barra, cada pareja de nudos deja multiplicando la integral de {N''} por {N''}, por {EI}. Comparando con la rigidez, sale término a término: cada entrada {K} es la curvatura de una forma por la de otra, integradas. Es justo lo que se calcula en el paso 5.

## 2 · Las funciones de forma en coordenada s = x/L
#: Uso {s} = {x/L}, que va de 0 a 1. Son las 4 de Hermite (ejemplo 24). OJO: las de GIRO ({N2}, {N4}) llevan un factor {L}, porque multiplican a un giro {theta} y el peso de un giro tiene que dar una longitud:
N1 = 1 - 3*s^2 + 2*s^3 @@(peso del descenso izquierdo)
N2 = L*(s - 2*s^2 + s^3) @@(peso del giro izquierdo, lleva L)
N3 = 3*s^2 - 2*s^3 @@(peso del descenso derecho)
N4 = L*(-s^2 + s^3) @@(peso del giro derecho, lleva L)

## 3 · La curvatura de cada peso (segunda derivada)
#: Derivo cada función dos veces respecto a {s}. Salen lineales (la curvatura de una cúbica):
N1s = Diff{1 - 3*s^2 + 2*s^3 @ s} @@(pendiente de N₁)
N1ss = Diff{-6*s + 6*s^2 @ s} @@(curvatura de N₁)
N2s = Diff{L*s - 2*L*s^2 + L*s^3 @ s} @@(pendiente de N₂)
N2ss = Diff{L - 4*L*s + 3*L*s^2 @ s} @@(curvatura de N₂)
N3ss = Diff{6*s - 6*s^2 @ s} @@(curvatura de N₃)
N4ss = Diff{-2*L*s + 3*L*s^2 @ s} @@(curvatura de N₄)

## 4 · El cambio de variable trae las potencias de L
#: Aquí nace el {EI/L^3}. Como {s} = {x/L}, derivar respecto a {x} mete un {1/L} por cada derivada: dos derivadas → {1/L^2}. Y al integrar en {x} aparece un factor {L} más. Juntando los tres, el factor común que sale afuera es {EI/L^3}; adentro quedan las curvaturas en {s}, con sus factores {L} de {N2} y {N4}.

## 5 · La integral: de dónde salen 12, 6L, 4L²
#: Cada término es la integral del producto de dos curvaturas, de 0 a 1. Los factores {L} de las funciones de giro quedan dentro y suben la potencia de {L}:
k11 = Area{(-6+12*s)^2 @ s=0:1} @@(descenso izq con descenso izq)
k12 = Area{(-6+12*s)*L*(-4+6*s) @ s=0:1} @@(descenso izq con giro izq)
k13 = Area{(-6+12*s)*(6-12*s) @ s=0:1} @@(descenso izq con descenso der)
k22 = Area{L*(-4+6*s)*L*(-4+6*s) @ s=0:1} @@(giro izq con giro izq)
k24 = Area{L*(-4+6*s)*L*(-2+6*s) @ s=0:1} @@(giro izq con giro der)
#: Ni un solo factor {L} en descenso–descenso (queda {12}), uno en descenso–giro ({6*L}), dos en giro–giro ({4*L^2}). Junto el factor común y la matriz de las 16 integrales:
factorL = EI/L^3 @@(el factor común)
K_coef = [12, 6*L, -12, 6*L; 6*L, 4*L^2, -6*L, 2*L^2; -12, -6*L, 12, -6*L; 6*L, 2*L^2, -6*L, 4*L^2] @@(la matriz de coeficientes)
#: La rigidez de la barra es el factor {factorL} por esa matriz {K_coef}. Es EXACTAMENTE la de los ejemplos 24 y 25; con {EI}=1 y {L}=1 da los números. Cada uno salió de una integral: el {12} de la de {(-6+12*s)^2}; el {6*L}, la misma con un factor {L}; el {4*L^2}, con dos. Ahí queda deducida, término a término.
