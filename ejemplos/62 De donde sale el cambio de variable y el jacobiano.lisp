# De dónde sale x = (a+b)/2 + (b−a)/2·ξ, y por qué J = (b−a)/2

#: Esa fórmula se copia de memoria en todos los libros de elementos finitos. Aquí no se enuncia: se **deduce**, y el despeje lo hace el motor de Hekatan LISP, no la mano.
#: Es el paso previo a la cuadratura de Gauss (hoja 63) y el que se usa en el ejemplo numérico (hoja 61).

## 1 · Qué hace falta y por qué

#: Los puntos y los pesos de Gauss están tabulados **una sola vez**, en un tramo fijo que va de −1 a +1. A ese tramo se le llama **tramo patrón**, y a su coordenada, **natural**: ξ.
#: Pero una integral de verdad va de a a b, y cada elemento de una malla tiene su propio a y su propio b. Si hubiera que tabular los puntos para cada tramo, la tabla no serviría de nada.
#: La salida es llevar cada tramo real al patrón. Y el mapa más simple que puede hacerlo es una **recta**: a cada ξ le hace corresponder un x.

## 2 · La recta, con sus dos números sin saber

#: Una recta en ξ tiene dos números por determinar. Se llaman aquí p y q:
X = p + q*xi
#: No son dos puntos del tramo: p es el valor de x en el centro (ξ = 0) y q es la pendiente, cuánto avanza x cada vez que ξ avanza 1.

## 3 · Las dos condiciones que la fijan

#: Hay exactamente dos cosas que la recta tiene que cumplir, una por cada extremo.
#: En ξ = −1 tiene que caer en x = a. La recta en ese punto vale:
e_1 = p + q*(-1)
#: En ξ = +1 tiene que caer en x = b. La recta ahí vale:
e_2 = p + q*(1)
#: O sea: **p − q = a** y **p + q = b**. Dos ecuaciones, dos incógnitas. No hay nada que suponer.

## 4 · El despeje, hecho por el motor

#: De la primera ecuación se despeja p:
p_sol = Despejar{p - q = a @ p}
#: Sale p = a + q. Eso se mete en la segunda: (a + q) + q = b, es decir a + 2·q = b. Y de ahí se despeja q:
q_sol = Despejar{a + 2*q = b @ q}
#: Ése es el primer resultado: **q = (b − a)/2**, la semilongitud del tramo real. Y con q ya conocido, p vuelve a la primera ecuación, ahora con ese valor dentro:
p_val = Despejar{p - (b - a)/2 = a @ p}
#: Y ése es el segundo: **p = (a + b)/2**, el centro del tramo. Con los dos, la recta del cambio de variable queda x = (a+b)/2 + (b−a)/2·ξ, que es la fórmula del principio.

## 5 · Lo mismo como sistema de matrices

#: Las dos condiciones se pueden apilar: cada fila es la base [1, ξ] evaluada en un extremo. El sistema es M·[p; q] = [a; b]:
M = [1, -1; 1, 1]
#: Y se resuelve invirtiendo, que es otro camino al mismo sitio:
c = inv(M) * [a; b]
#: Los dos números son los mismos: arriba el centro, abajo la semilongitud. Dos caminos, un resultado.

## 6 · El jacobiano: la pendiente de esa recta

#: El jacobiano es la derivada de la coordenada real respecto de la natural, y el motor la calcula:
J = Diff{p + q*xi @ xi}
#: Sale J = q: la pendiente de una recta es su segundo número. Y metiendo el valor de q que se despejó arriba:
J_ab = Diff{(a + b)/2 + (b - a)/2*xi @ xi}
#: **J = (b − a)/2**, la semilongitud del tramo real.
#: Qué significa: es el **factor de estiramiento** entre los dos tramos. Un pedacito dξ del patrón mide J·dξ en el tramo real. Por eso toda integral cambia así: dx = J·dξ, y la integral en el tramo real es la del patrón multiplicada por J.
#: La comprobación de medida: el patrón mide 2 y el tramo real mide b − a. Multiplicando 2 por el jacobiano:
L = Simplify{2*((b - a)/2)}
#: Da b − a, la longitud del tramo real. El estiramiento cuadra.

## 7 · El caso del ejemplo: el tramo [0, 4]

#: Con a = 0 y b = 4, el centro y la semilongitud:
p_n = dec((0 + 4)/2, 6)
q_n = dec((4 - 0)/2, 6)
#: O sea la recta x = 2 + 2·ξ, y el jacobiano J = 2. Se comprueba en los dos extremos. En ξ = −1:
x_izq = dec(2 + 2*(-1), 6)
#: Da 0, que es a. Y en ξ = +1:
x_der = dec(2 + 2*(1), 6)
#: Da 4, que es b. El mapa hace lo que se le pidió.

## 8 · El mapa, dibujado

#: La recta que lleva ξ (de −1 a +1) a x (de 0 a 4). Los dos puntos marcados son los extremos: (−1, 0) y (+1, 4).
#fplot(2 + 2*xi, extremos = [-1 0; 1 4], [-1 1])
#: Su inclinación —2 hacia arriba por cada 1 hacia la derecha— **es** el jacobiano. Un tramo más largo levanta más la recta; uno más corto, menos.

## En una línea

#: · El tramo patrón [−1, +1] existe para tabular los puntos de Gauss una sola vez.
#: · La recta x = p + q·ξ se fija con dos condiciones, una por extremo, y el motor despeja p = (a+b)/2 y q = (b−a)/2.
#: · El jacobiano es la pendiente de esa recta, J = (b−a)/2, y es el factor por el que se multiplica la integral.
