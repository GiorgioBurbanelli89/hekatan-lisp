# El Jacobiano en 1D: de la coordenada natural al largo real
#: Todo simbólico. Empezamos por lo más simple: una barra (1D). Aquí el Jacobiano es UN NÚMERO, no una matriz. Es el mismo concepto que en 2D, pero desnudo.

## 1 · La coordenada natural (tu s = x/L)
#: En FEM cada barra, mida lo que mida, se piensa como el estiramiento de un SEGMENTO de referencia. La coordenada natural s recorre ese segmento de 0 a 1: es, literalmente, "qué fracción de la barra llevas". Justo tu idea: s = x/L (en un extremo s=0, en el otro s=1).
#: Ventaja: siempre trabajas sobre el mismo segmento [0, 1], sin importar si la barra mide 2 m o 200 m. Del largo real se encarga el Jacobiano.

## 2 · El mapa: la posición física x en función de s
#: Si la barra va de x=0 a x=L, la posición física es la coordenada natural escalada por el largo:
x = s*L
#: En s=0 estás en 0; en s=1 estás en L. El mapa estira el segmento natural (de largo 1) hasta el largo real L.

## 3 · El Jacobiano: cuánto avanza x por un pasito ds
#: El Jacobiano en 1D es la derivada del mapa: cuánto te mueves en el mundo físico (x) por cada pasito en el natural (s). Un solo número:
J = Diff{x @ s}
#: Salió L. Tiene todo el sentido: recorrer TODO el segmento natural (Δs = 1) te lleva TODO el largo real (Δx = L). En 1D, el Jacobiano ES el largo de la barra.

## 4 · Para qué sirve
#: El Jacobiano traduce medidas de ida y de vuelta:
#: — De natural a físico: un pedacito ds vale dx = J·ds = L·ds de barra real. Ese factor es el que aparece en toda integral sobre el elemento: ∫(…)dx = ∫(…)·J·ds.
#: — De físico a natural: la INVERSA 1/J pasa las derivadas al revés. La deformación se calcula como d/dx = (1/J)·d/ds:
Ji = 1/J
#: O sea 1/L. Eso es exactamente lo que necesita la matriz B: derivar las funciones de forma respecto a x, cuando están escritas en s.

## 5 · La otra convención: el segmento de −1 a 1
#: En FEM se usa muchísimo un segmento natural que va de −1 a +1 (por simetría y porque la cuadratura de Gauss vive ahí). La coordenada es ξ = 2s − 1. El mapa y su Jacobiano:
x2 = L*(1+xi)/2
J2 = Diff{x2 @ xi}
#: Ahí el Jacobiano es L/2: el segmento natural mide 2, la barra mide L → factor L/2. Es el MISMO concepto que el s = x/L, solo que sobre un segmento de largo 2 en vez de 1. En 2D (el cuadrado [−1,1]²) usaremos esta misma convención.
