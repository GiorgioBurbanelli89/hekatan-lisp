# El Jacobiano en 1D: de la coordenada natural ξ al largo real
#: Todo simbólico. Empezamos por lo más simple: una barra (1D). Aquí el Jacobiano es UN NÚMERO, no una matriz. Es el mismo concepto que en 2D, pero desnudo.

## 1 · La coordenada natural ξ
#: En FEM cada barra, mida lo que mida, se piensa como el estiramiento de un SEGMENTO de referencia. La coordenada natural estándar es {xi} y va de −1 (un extremo) a +1 (el otro). Es la que usan casi todos los libros (Zienkiewicz, Cook, Hughes). En 2D serán {xi} y {eta}; en 3D se suma {zeta}.
#: ¿Por qué de −1 a +1 y no de 0 a 1? Por SIMETRÍA (el centro queda en {xi} = 0) y porque la cuadratura de Gauss —con la que se integra la rigidez— vive justo en ese tramo. Ventaja: siempre trabajas sobre el mismo segmento, sin importar si {L} vale 2 m o 200 m. Del largo real se encarga el Jacobiano. Míralo: el segmento natural {xi} ∈ [−1,1] arriba, y su mapa a la barra real [0, {L}] abajo:
#bar1d

## 2 · Las funciones de forma
#: Cada extremo tiene su función de forma. {N1} vale 1 en el nudo 1 ({xi} = −1) y 0 en el nudo 2; {N2} al revés:
N1 = (1-xi)/2; N2 = (1+xi)/2
#: Entre las dos interpolan en línea recta: cualquier cosa (posición, desplazamiento) se arma como {N1} por su valor en el nudo 1 más {N2} por su valor en el nudo 2. Dibujadas sobre {xi} ∈ [−1,1] —se cruzan en el centro, donde cada una vale 1/2:
#fplot((1-x)/2, (1+x)/2, [-1 1])

## 3 · El mapa: la posición física x en función de ξ
#: La posición física {x} sale de interpolar las posiciones de los nudos. Con el nudo 1 en el origen y el nudo 2 a distancia {L}, solo sobrevive el término de {N2}:
x = N2*L
#: En {xi} = −1 da 0 (nudo 1); en {xi} = +1 da {L} (nudo 2). El mapa estira el segmento natural —que mide 2— hasta el largo real {L}.

## 4 · El Jacobiano: cuánto avanza x por un pasito dξ
#: El Jacobiano en 1D es la derivada del mapa {x}: cuánto te mueves en el mundo físico por cada pasito en el natural. Un solo número:
J = Diff{x @ xi}
#: Salió {J}. Tiene sentido: el segmento natural mide 2 y la barra mide {L}, así que cada unidad de {xi} vale ese {J} de barra. El Jacobiano es el factor de estiramiento del mapa.

## 5 · Para qué sirve
#: El Jacobiano traduce medidas de ida y de vuelta. De natural a físico: un pedacito d{xi} vale {J}·d{xi} de barra real; ese factor es el que aparece en toda integral sobre el elemento. De físico a natural, la INVERSA pasa las derivadas al revés —lo que necesita la matriz de deformación B para derivar respecto a x lo que está escrito en {xi}:
Ji = 1/J
#: O sea {Ji}. Con esos dos —el Jacobiano {J} y su inversa {Ji}— ya se puede montar la deformación y, de ahí, la rigidez del elemento. El siguiente paso.
