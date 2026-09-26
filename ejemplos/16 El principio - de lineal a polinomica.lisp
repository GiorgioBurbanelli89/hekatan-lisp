# El principio: por qué se interpola, y por qué primero lineal y luego polinómica
#: La pregunta de fondo, con el motor y gráficas.

## 1 · El principio raíz: de lo infinito a lo finito
#: Una estructura tiene **infinitos puntos**, cada uno se mueve distinto → la incógnita es una **función entera**, no un número. Eso es imposible de resolver directo. La jugada: guardo el valor en **pocos nudos** + una **regla de relleno** (la función de forma). Así ∞ incógnitas → **pocas** incógnitas → el computador la resuelve. Eso es un "elemento **finito**".

## 2 · Una curva real que queremos representar
#: Tomemos una curva suave cualquiera (una joroba): f(x) = sin(π·x) sobre [0,1]. Los nudos serán 0, ½ y 1.

## 3 · Relleno LINEAL: trozos rectos → aparece el QUIEBRE
#: Uno los nudos con **rectas**. La poligonal coincide en **valor** en los nudos, pero mira el **pico** en x=½: la pendiente salta de golpe. (El triángulo 1−|2x−1| es la aproximación lineal de 2 tramos.)
#fplot(sin(3.14159*x), 1-abs(2*x-1), [0 1])
#: Continua en **valor** (C⁰), pero **NO** en pendiente. Ese quiebre es lo que la lineal no puede evitar. Con más trocitos se acerca más (como un polígono a un círculo), pero siempre con quiebres.

## 4 · Relleno POLINÓMICO: una curva suave, sin quiebre
#: Un **polinomio** se curva por los mismos nudos, pero **suave**. Aquí una cuadrática 4·x·(1−x) que pasa por (0,0), (½,1), (1,0):
#fplot(sin(3.14159*x), 4*x-4*x^2, [0 1])
#: Sin pico. Coincide en **valor Y pendiente** (C¹). Captura la forma real con muy pocos elementos.

## 5 · Por qué se SUBIÓ el grado (lineal → polinómica)
#: No fue capricho. La **viga** se curva, y su energía depende de la **curvatura** (segunda derivada). Un quiebre de la lineal da curvatura falsa (cero o infinita) → físicamente inválido. Para que la **pendiente sea continua** hay que controlar en cada nudo el desplazamiento **y** el giro → 2 datos por nudo × 2 nudos = 4 → el polinomio sube a **cúbica** (Hermite). **La física exigió más suavidad, y más suavidad obliga a más grado.**

## 6 · La regla que lo unifica
#: cuánta continuidad exige el problema  →  el grado del polinomio
#|  barra que ESTIRA  →  basta valor continuo (C⁰)  →  1 dato/nudo  →  LINEAL
#|  viga que SE CURVA →  valor y pendiente (C¹)      →  2 datos/nudo →  CÚBICA (Hermite)
#: Se empezó por lo más simple (lineal: barato, y con malla fina alcanza) y se subió el grado **solo cuando la física lo pidió**. Ese es el principio.
