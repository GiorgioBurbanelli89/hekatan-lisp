# El Jacobiano en 1D: de la coordenada natural ξ al largo real
#: Todo simbólico. Empezamos por lo más simple: una barra (1D). Aquí el Jacobiano es UN NÚMERO, no una matriz. Es el mismo concepto que en 2D, pero desnudo.

## 1 · La coordenada natural ξ (de −1 a +1)
#: En FEM cada barra, mida lo que mida, se piensa como el estiramiento de un SEGMENTO de referencia. La coordenada natural estándar es ξ (xi) y va de −1 (un extremo) a +1 (el otro). Es la que usan casi todos los libros (Zienkiewicz, Cook, Hughes). En 2D será (ξ, η); en 3D (ξ, η, ζ).
#: ¿Por qué de −1 a 1 y no de 0 a 1? Por SIMETRÍA (el centro queda en ξ=0) y porque la cuadratura de Gauss —con la que se integra la rigidez— vive justo en [−1, 1]. (Ojo: la "posición normalizada" x/L, de 0 a 1, es OTRA cosa —dice dónde estás, no es la natural isoparamétrica.)
#: Ventaja: siempre trabajas sobre el mismo segmento [−1, 1], sin importar si la barra mide 2 m o 200 m. Del largo real se encarga el Jacobiano.

## 2 · El mapa: la posición física x en función de ξ
#: Las coordenadas físicas salen de interpolar las posiciones de los nudos con las funciones de forma. Con el nudo 1 en x=0 y el nudo 2 en x=L, y N2 = (1+ξ)/2:
x = L*(1+xi)/2
#: En ξ=−1 (nudo 1) da x=0; en ξ=+1 (nudo 2) da x=L. El mapa estira el segmento natural [−1,1] (que mide 2) hasta el largo real L.

## 3 · El Jacobiano: cuánto avanza x por un pasito dξ
#: El Jacobiano en 1D es la derivada del mapa: cuánto te mueves en el mundo físico (x) por cada pasito en el natural (ξ). Un solo número:
J = Diff{x @ xi}
#: Salió L/2. Tiene sentido: el segmento natural mide 2 y la barra mide L, así que cada unidad de ξ vale L/2 de barra. El Jacobiano es el "factor de estiramiento" del mapa.

## 4 · Para qué sirve
#: El Jacobiano traduce medidas de ida y de vuelta:
#: — De natural a físico: un pedacito dξ vale dx = J·dξ = (L/2)·dξ de barra real. Ese factor es el que aparece en toda integral sobre el elemento: ∫(…)dx = ∫(…)·J·dξ, integrando de −1 a 1.
#: — De físico a natural: la INVERSA 1/J pasa las derivadas al revés. La deformación se calcula como d/dx = (1/J)·d/dξ:
Ji = 1/J
#: O sea 2/L. Eso es exactamente lo que necesita la matriz B: derivar las funciones de forma respecto a x, cuando están escritas en ξ.

## 5 · La otra escala que quizá conoces: x/L (de 0 a 1)
#: A veces se usa una coordenada normalizada de POSICIÓN que va de 0 a 1: cuánta fracción de la barra llevas. Llamémosla t = x/L. El mapa entonces es x = t·L y el Jacobiano dx/dt = L (el largo entero, porque ese segmento mide 1, no 2):
xt = t*L
Jt = Diff{xt @ t}
#: Es el MISMO concepto —el Jacobiano es el estiramiento del segmento de referencia al largo real— solo cambia el largo del segmento: mide 2 con ξ (→ J=L/2) o mide 1 con x/L (→ J=L). En FEM manda la ξ de −1 a 1; la x/L es más bien una ayuda de intuición.
