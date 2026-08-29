# Una función de forma por cada grado de libertad
## Un grado de libertad es cada cosa que un nudo puede hacer por su cuenta. En una barra que solo se estira hay dos: cuánto se corre cada punta.
gdl_axial = 2
## Y aquí está lo que hay que entender: hay una función de forma POR CADA grado de libertad. Ni una más, ni una menos.
## La función del primer grado es cómo queda la barra si muevo SOLO esa punta y dejo la otra quieta.
N_1 = 1 - x/L
## Y la del segundo grado, moviendo solo la otra punta.
N_2 = x/L
## En el tramo patrón, esas mismas dos se escriben así.
N_1p = (1 - xi)/2
N_2p = (1 + xi)/2
## El movimiento de cualquier punto de la barra es la mezcla de las dos, cada una multiplicada por SU grado de libertad.
mezcla = u_x = N_1·u_1 + N_2·u_2
## Ahora la otra pregunta: por qué se deriva para sacar la deformación unitaria.
## Toma dos puntos separados una distancia pequeña. Los dos se mueven, pero no lo mismo: el de la derecha se mueve un poquito más.
estira = du = u_2 - u_1
## El trocito, que medía dx, ahora mide eso más el estiramiento.
largo = dx + du
## Y la deformación unitaria es el estiramiento partido para lo que medía. Eso es exactamente una derivada.
defo = epsilon = du/dx
## Derivar no es un truco: es medir cuánto se estira cada trocito por unidad de largo.
## Con las funciones de forma de la barra, esa derivada sale constante.
defo_val = Diff{1 - x/L @ x}
## En la viga a flexión hay cuatro grados de libertad, dos por nudo, así que hay CUATRO funciones de forma.
gdl_viga = 2·2
## Y en el pórtico plano hay seis por barra: los dos del axial y los cuatro de la flexión.
gdl_portico = 2 + 4
## Por eso la matriz de la barra es de seis por seis: una fila y una columna por cada grado de libertad.
tam = 6·6
