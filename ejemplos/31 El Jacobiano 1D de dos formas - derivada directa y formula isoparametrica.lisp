# El Jacobiano 1D de dos formas: derivada directa y fórmula isoparamétrica
#: El Jacobiano del elemento lineal se puede obtener de dos maneras distintas que dan lo mismo. La primera, derivando directamente el mapeo. La segunda, con la fórmula isoparamétrica —un producto punto de las derivadas de las funciones de forma por las coordenadas de los nodos—, que es la que se generaliza a 2D y 3D. Todo simbólico.

## 1 · El elemento y su mapeo
#: El elemento lineal tiene el nodo 1 en {xi} = −1 y el nodo 2 en {xi} = +1, con funciones de forma:
N1 = (1-xi)/2; N2 = (1+xi)/2
#: En el mundo físico el nodo 1 está en x = 0 y el nodo 2 en x = {L}. La coordenada física se interpola con las mismas funciones de forma; con el nodo 1 en el origen, solo sobrevive el término de {N2}:
x = N2 * L

## 2 · Forma 1 — La derivada directa
#: El Jacobiano es, por definición, la derivada de la coordenada física {x} respecto de la natural {xi}. Se deriva el mapeo:
J1 = Diff{(1+xi)/2 * L @ xi}
#: Resulta {J1}: constante, porque el mapeo es lineal.

## 3 · Forma 2 — La fórmula isoparamétrica (manual)
#: El mismo Jacobiano sale sin derivar el mapeo completo: como {x} = Σ Nᵢ·xᵢ, su derivada es la suma de las derivadas de cada función de forma por la coordenada de su nodo, J = Σ (dNᵢ/dξ)·xᵢ. Primero las derivadas de las funciones de forma:
dN1 = Diff{(1-xi)/2 @ xi}; dN2 = Diff{(1+xi)/2 @ xi}
#: Salen {dN1} y {dN2}, constantes. La fórmula isoparamétrica es el producto punto del vector de esas derivadas por el vector de coordenadas nodales [x₁; x₂] = [0; {L}]:
J2 = [dN1, dN2] * [0; L]
#: El nodo 1 (en x = 0) no aporta; solo el nodo 2 (en x = {L}) contribuye con {dN2}·{L}.

## 4 · Las dos coinciden
#: Ambas dan {J1}. La derivada directa es más corta en 1D; la fórmula isoparamétrica J = Σ (dNᵢ/dξ)·xᵢ es la que se usa en la práctica, porque se generaliza sin cambios a 2D y 3D (donde el Jacobiano es una matriz y las coordenadas nodales, varias). En el fondo son lo mismo: derivar el mapeo interpolado equivale a sumar las derivadas de las funciones de forma pesadas por los nodos.
