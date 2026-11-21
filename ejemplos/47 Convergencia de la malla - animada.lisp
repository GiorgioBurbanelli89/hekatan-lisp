# Convergencia de la malla: qué pasa al refinar
#: Una barra de largo 1, empotrada a la izquierda y libre a la derecha, con una carga axial repartida uniforme. Todo normalizado (carga = rigidez axial = largo = 1) para que se vea solo la forma. Se compara la solución EXACTA con la de ELEMENTOS FINITOS lineales, para 1, 2, 3 … 8 elementos.

## 1 · La solución exacta
#: El desplazamiento exacto de la barra es una parábola:
u = x - x^2/2
#: La tensión (el esfuerzo axial) es la pendiente del desplazamiento, su derivada:
sigma = Diff{u @ x}
#: Es una recta: vale 1 en el empotramiento y 0 en el extremo libre.

## 2 · Lo que hace el elemento finito lineal
#: Con {n} elementos, cada uno mide {h} (el largo 1 partido en {n}).
#: En la barra, el elemento lineal da los desplazamientos de los NUDOS exactos, y entre nudo y nudo traza una RECTA. La tensión dentro de un elemento que va de {a} hasta {a} + {h} es la pendiente de esa recta:
sigma_EF = Expand{((a + h) - (a + h)^2/2 - (a - a^2/2))/h}
#: Es una CONSTANTE en cada elemento: la tensión del elemento finito es una escalera, no una recta.

## 3 · La animación: el desplazamiento
#: Parábola exacta (azul) contra el elemento finito (naranja). Con 1 elemento es una sola recta; al refinar, los tramos rectos abrazan la parábola. Con ⏸ se detiene, y la barra elige el cuadro.
#anim fplot(u = x - x^2/2, u_EF = floor(n*x)/n - (floor(n*x)/n)^2/2 + (1 - floor(n*x)/n - 1/(2*n))*(x - floor(n*x)/n), [0 0.999]), n = 1:8
h = 1/n
#: En los nudos coinciden siempre. Entre nudos, el error más grande está en el centro de cada elemento y vale:
e_u = h^2/8
#: Si {n} se duplica, {h} baja a la mitad y el error baja a la CUARTA parte: eso es CONVERGER.

## 4 · La animación: la tensión (por qué CSI promedia)
#: Recta exacta (azul) contra la escalera del elemento finito (naranja):
#anim fplot(sigma = 1 - x, sigma_EF = 1 - floor(n*x)/n - 1/(2*n), [0 0.999]), n = 1:8
#: Mira un nudo interior: el elemento de la izquierda da una tensión y el de la derecha OTRA. El salto entre los dos es la diferencia de dos escalones seguidos:
salto = (1 - (a - h) - h/2) - (1 - a - h/2)
#: El salto vale {h}. Es la tercera ecuación, el EQUILIBRIO punto a punto, que el elemento finito no cumple: solo lo cumple en los nudos. Por eso SAP2000, ETABS y SAFE ofrecen ver las tensiones «Unaveraged» (con salto) o «Averaged» (el promedio de los dos elementos en el nudo). Promedio en un nudo interior:
sigma_nudo = Expand{((1 - (a - h) - h/2) + (1 - a - h/2))/2}
#: Sale 1 − {a}: justo la tensión EXACTA en ese nudo. Promediar no es un truco: aquí devuelve el valor exacto.

## 5 · Convergencia y divergencia
#: El error del desplazamiento en función del número de elementos. La curva es la fórmula; los puntos son el error MEDIDO en las animaciones de arriba (la mayor distancia entre la parábola y los tramos rectos) con 1, 2, 4 y 8 elementos:
#fplot(e_u = 1/(8*n^2), medido = [1 0.125; 2 0.03125; 4 0.0078125; 8 0.001953125], [1 8])
#: Los puntos caen justo sobre la curva: cada vez que se duplica {n}, el error se divide entre 4.
#: CONVERGE: al refinar, la curva baja hacia cero y los dos programas (o el programa y la solución exacta) se acercan. DIVERGE: al refinar, la diferencia no baja o crece; eso indica que los dos modelos NO son el mismo (otro elemento, otra teoría —Shell-Thin contra Shell-Thick— u otro error).
#: Y cuando dos programas dan una diferencia cercana a 0 %, con la misma malla y el mismo elemento, significa que hacen el MISMO cálculo.
