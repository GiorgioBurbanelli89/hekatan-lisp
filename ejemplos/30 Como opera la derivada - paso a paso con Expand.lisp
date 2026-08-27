# Cómo opera la derivada — regla por regla
#: La derivada de la función de forma respecto a ξ, mostrando el procedimiento: qué regla se aplica en cada paso, no solo el resultado.

## 1 · Se expande la función
#: El producto {(1+xi)/2 * L} no muestra su estructura. Expandido en potencias de ξ se ve de qué está hecho —un término lineal y uno constante:
f = Expand{(1+xi)/2 * L}

## 2 · Regla de la suma
#: La derivada de una suma es la suma de las derivadas de cada término. Se deriva {L*xi/2} y {L/2} por separado y se suman:
suma = Diff{L*xi/2 @ xi} + Diff{L/2 @ xi}

## 3 · Regla del factor constante y de la potencia
#: En el término lineal, la constante {L/2} sale de la derivada (regla del factor constante) y multiplica a la derivada de ξ:
factor = (L/2) * Diff{xi @ xi}
#: La derivada de ξ es 1 (regla de la potencia: ξ¹ baja el exponente, 1·ξ⁰ = 1):
d_xi = Diff{xi @ xi}
#: El término constante {L/2} no depende de ξ, de modo que su derivada es 0:
cero = Diff{L/2 @ xi}

## 4 · La derivada total y su tiempo
#: Juntando todo: el término lineal da {factor} y el constante da {cero}, así que la derivada es {factor}. La operación completa, cronometrada con tic/toc:
tic
J = Diff{L*xi/2 + L/2 @ xi}
toc
