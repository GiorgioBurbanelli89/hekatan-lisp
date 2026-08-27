# El Jacobiano en 1D: la transformación isoparamétrica del elemento lineal
#: Formulación simbólica del elemento lineal de dos nodos. El objetivo es definir el Jacobiano de la transformación isoparamétrica: el escalar que relaciona la coordenada natural con la coordenada física del elemento.

## 1 · La coordenada natural ξ y el elemento de referencia
#: En el método de los elementos finitos cada elemento del dominio físico se formula sobre un elemento de referencia de geometría fija, parametrizado por la coordenada natural {xi}. Para el elemento lineal de dos nodos, {xi} recorre el intervalo [−1, 1], según la convención isoparamétrica estándar (Zienkiewicz, Bathe, Hughes).
#: El intervalo simétrico [−1, 1] no es arbitrario: sitúa el origen paramétrico en el centro del elemento y coincide con el dominio de integración de la cuadratura de Gauss–Legendre, con la que se evalúa la matriz de rigidez. La geometría real, de longitud {L}, se recupera mediante la transformación isoparamétrica, cuyo factor de escala es el Jacobiano. El elemento de referencia {xi} ∈ [−1, 1] y su imagen en el dominio físico [0, {L}]:
#bar1d

## 2 · Deducción de las funciones de forma
#: Las funciones de forma no se postulan de memoria: se deducen. El elemento tiene dos nodos, es decir dos grados de libertad, de modo que el polinomio interpolante más simple es de primer grado en {xi}. Para el nodo 1 se propone la forma general:
N1a = a + b*xi
#: Los coeficientes {a} y {b} se determinan con la propiedad de delta de Kronecker: la función de forma de un nodo vale la unidad en ese nodo y se anula en el otro. Para {N1a}: valor 1 en {xi} = −1 (nodo 1) y valor 0 en {xi} = +1 (nodo 2). Evaluar el polinomio en los dos nodos equivale a multiplicar la base [1, {xi}] por el vector de coeficientes; ordenando por filas se obtiene la matriz del sistema:
M = [1, -1; 1, 1]
#: La primera fila es la base en {xi} = −1 y la segunda en {xi} = +1. El sistema es M·[a; b] = [1; 0], donde el lado derecho recoge los valores nodales de {N1}. Los coeficientes salen invirtiendo la matriz:
Mi = inv(M)
c1 = Mi * [1; 0]
#: El vector {c1} contiene los coeficientes {a} y {b} buscados. La función de forma se reconstruye como la base por el vector de coeficientes:
N1r = [1, xi] * c1
#: Repitiendo el proceso con el lado derecho [0; 1] se obtiene {N2}. De hecho, ambas funciones de forma salen de un solo producto, multiplicando la base por la inversa completa:
N = [1, xi] * Mi
#: El resultado, factorizando 1/2, es {N} = [ (1−{xi})/2 , (1+{xi})/2 ]. Se definen así en forma cerrada:
N1 = (1-xi)/2; N2 = (1+xi)/2
#: Todo campo interpolado —geometría o desplazamiento— se expresa como combinación lineal de las funciones de forma ponderadas por los valores nodales: {N1} por el valor en el nodo 1 más {N2} por el valor en el nodo 2. Al ser de primer grado, la interpolación es exacta para campos lineales. Trazadas sobre {xi} ∈ [−1, 1], cada función de forma es una recta que pasa por 1 en su nodo y por 0 en el otro; se cruzan en {xi} = 0, donde ambas valen 1/2:
#fplot((1-x)/2, (1+x)/2, [-1 1])

## 3 · El mapeo isoparamétrico: de ξ a la coordenada física x
#: En la formulación isoparamétrica la geometría y el campo de desplazamientos se interpolan con las mismas funciones de forma. La coordenada física {x} se obtiene interpolando las coordenadas nodales; con el nodo 1 en el origen y el nodo 2 en {L}, subsiste únicamente el término asociado a {N2}:
x = N2*L
#: Se comprueban los valores en los extremos: en {xi} = −1 se recupera el nodo 1 ({x} = 0) y en {xi} = +1 el nodo 2 ({x} = {L}). La transformación aplica el elemento de referencia, de medida 2, sobre el dominio físico de longitud {L}.

## 4 · El Jacobiano de la transformación
#: El Jacobiano de la transformación isoparamétrica es la derivada de la coordenada física respecto de la coordenada natural: mide la razón de cambio entre ambos dominios. Para el elemento lineal es un escalar:
J = Diff{x @ xi}
#: Resulta {J}, coherente con la relación de medidas: el elemento de referencia mide 2 y el físico {L}, de modo que el Jacobiano es el factor de escala de la transformación. Su valor gobierna el cambio de variable de toda integral sobre el elemento, requisito de la integración por cuadratura de Gauss.

## 5 · La inversa del Jacobiano y la matriz de deformación
#: El Jacobiano interviene en ambos sentidos. En sentido directo, un diferencial de la coordenada natural se transporta al dominio físico escalado por {J} —el factor que acompaña a la integración numérica. En sentido inverso, la matriz de deformación B exige las derivadas de las funciones de forma respecto de la coordenada física {x}; como éstas se definen en {xi}, la regla de la cadena introduce el Jacobiano inverso:
Ji = 1/J
#: Se obtiene {Ji}. Con el Jacobiano {J} y su inversa {Ji} queda definido el operador que transporta las derivadas entre el dominio de referencia y el físico, base para ensamblar la matriz de deformación B y, a partir de ella, la matriz de rigidez del elemento.
