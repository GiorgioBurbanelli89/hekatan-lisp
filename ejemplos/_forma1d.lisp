# Las funciones de forma: de dónde salen la flecha y el giro
#: Cada función es la deformada del tramo cuando UN grado vale uno y los otros tres valen cero.

## La flecha en un punto cualquiera del interior
w_x = P1(x)·w_i + P2(x)·q_i + P3(x)·w_j + P4(x)·q_j

## Las cuatro funciones, en la coordenada x que va de 0 a 1
P1(x) = 1 - x^2·(3 - 2·x)
P2(x) = L·x·(1 - x·(2 - x))
P3(x) = x^2·(3 - 2·x)
P4(x) = L·x^2·(x - 1)

## Las de FLECHA valen uno en su nudo y cero en el otro
a_10 = P1(0)
a_11 = P1(1)
a_30 = P3(0)
a_31 = P3(1)

## Las de GIRO valen CERO en los dos nudos: no bajan el nudo, lo giran
F2(x) = x·(1 - x·(2 - x))
F4(x) = x^2·(x - 1)
b_20 = F2(0)
b_21 = F2(1)
b_40 = F4(0)
b_41 = F4(1)

## Lo que las distingue es su PENDIENTE. El motor deriva:
dF_2 = Diff{x·(1 - x·(2 - x)) @ x}
dF_4 = Diff{x^2·(x - 1) @ x}
dF_1 = Diff{1 - x^2·(3 - 2·x) @ x}

## Y ahora se evalúa esa derivada en los dos nudos
G2(x) = 3·x^2 - 4·x + 1
G4(x) = 3·x^2 - 2·x
G1(x) = 6·x^2 - 6·x
g_20 = G2(0)
g_21 = G2(1)
g_40 = G4(0)
g_41 = G4(1)
g_10 = G1(0)
g_11 = G1(1)

## El giro en cualquier punto es la derivada de la flecha
q_x = Diff{P1(x)·w_i + P2(x)·q_i + P3(x)·w_j + P4(x)·q_j @ x}/L
