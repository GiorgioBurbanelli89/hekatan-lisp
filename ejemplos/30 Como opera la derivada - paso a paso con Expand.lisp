# Cómo opera la derivada — paso a paso con Expand
#: La derivada de la función de forma respecto a la coordenada natural ξ, explicada término a término. La clave es Expand: abre el polinomio en sus términos, y ahí se ve cómo se deriva cada uno.

## 1 · La función, expandida en términos
#: El producto {(1+xi)/2 * L} no muestra su estructura. Al expandirlo en potencias de ξ se ve de qué está hecho: un término constante y un término lineal:
f = Expand{(1+xi)/2 * L}

## 2 · Se deriva término a término
#: La derivada de una suma es la suma de las derivadas, así que se deriva cada término por separado.
#: El término constante L/2 no depende de ξ, de modo que su derivada es 0:
dc = Diff{L/2 @ xi}
#: El término lineal (L/2)·ξ sigue la regla de la potencia: baja el exponente (ξ¹ → ξ⁰ = 1) y multiplica, quedando solo el coeficiente:
dl = Diff{(L/2)*xi @ xi}

## 3 · La derivada total y su tiempo
#: Sumando las dos, la derivada completa es {dl} (el 0 del término constante no aporta). Esta es la operación entera, cronometrada con tic/toc:
tic
J = Diff{(1+xi)/2 * L @ xi}
toc
