# Integrales
#: **Integral** da la primitiva; **Area** da la integral definida entre dos límites (regla de Barrow: F(b) − F(a)).

## Indefinidas
Integral{x^2 @ x}
Integral{x + 1 @ x}
Integral{3*x^2 @ x}
Integral{1/x^2 @ x}
Integral{cos(x) @ x}
Integral{1/x @ x}

## Definidas
Area{x^2 @ x = 0 : 3}
Area{3*x^2 + 2*x @ x = 1 : 2}
Area{sin(x) @ x = 0 : pi}
Area{1/x @ x = 1 : 2}
#: Si la función no tiene primitiva elemental, el área se calcula numéricamente (regla de Simpson):
Area{exp(-x^2) @ x = 0 : 1}

#: Comprobación: derivar la primitiva devuelve la función de partida.
Derivate{x^3/3 @ x}
