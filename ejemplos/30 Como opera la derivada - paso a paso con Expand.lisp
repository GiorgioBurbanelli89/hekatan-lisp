# Cómo opera la derivada — paso a paso
#: La derivada de la función de forma respecto a ξ, mostrando CADA operación intermedia —igual que se hace a mano—, no solo el resultado final. Al final, la misma derivada calculada por el motor y cronometrada.

## 1 · Se expande la función
#: El producto {(1+xi)/2 * L} no muestra su estructura. Expandido en potencias de ξ se ve un término constante y uno lineal:
f = Expand{(1+xi)/2 * L}

## 2 · Derivada del término lineal (L/2)·ξ, paso por paso
#: Se sigue la cadena: la constante {L/2} sale de la derivada (factor constante), la derivada de ξ es 1 (regla de la potencia), y se multiplica:
dl = Diff{(L/2)*xi @ xi} = (L/2)*Diff{xi @ xi} = (L/2)*1 = L/2

## 3 · La derivada completa, paso por paso
#: Primero se expande, luego la regla de la suma reparte la derivada en cada término: el constante {L/2} da 0 y el lineal da {L/2}. Sumando:
J = Diff{(1+xi)/2*L @ xi} = Diff{L/2 + (L/2)*xi @ xi} = 0 + L/2 = L/2

## 4 · La misma derivada, calculada por el motor y cronometrada
#: Ahora el motor la calcula de una sola vez (esto SÍ lo computa, no es notación), con su tiempo:
tic
Jm = Diff{(1+xi)/2 * L @ xi}
toc
