# Todas las formas de invertir una matriz — simbólico, paso a paso
#: Invertir no es apretar un botón: es un **procedimiento**, y hay **muchos caminos** que llegan al mismo sitio. Aquí están todos, hechos con **letras** —sin un solo número— y con cada paso resuelto por el motor. Nada de lo que sigue está escrito a mano: lo que aparece a la derecha de cada igual lo calculó Hekatan LISP.
#: La matriz de trabajo y la identidad, que es la matriz que **no hace nada**:
A = [a11, a12; a21, a22]
Id = [1, 0; 0, 1]
#: Invertir A es encontrar la matriz que **deshace** lo que A hace. Esa es toda la definición, y es la prueba que se repetirá al final de cada camino.

## 0 · Los ingredientes: menor, cofactor, adjunta y determinante
#: Antes de los caminos, las cuatro piezas con las que están hechos casi todos. El **menor** de una posición es lo que queda al tachar su fila y su columna. Los cuatro menores de A, uno por posición:
m11 = menor(A, 1, 1)
m12 = menor(A, 1, 2)
m21 = menor(A, 2, 1)
m22 = menor(A, 2, 2)
#: El **cofactor** es el menor con un signo que alterna como las casillas de un tablero de ajedrez. La matriz de cofactores entera:
Cf = cof(A)
#: La **adjunta** es la transpuesta de esa matriz de cofactores: la diagonal se queda quieta y la otra se cruza.
adjA = adj(A)
#: Y esto lo confirma sin discusión: transponer los cofactores da exactamente la adjunta.
adjB = transpose(cof(A))
#: El **determinante** tampoco es una regla que haya que creerse: sale de recorrer la primera fila multiplicando cada entrada por su menor, con el signo alterno. Eso es la expansión de Laplace, y el motor la resuelve:
dLap = a11*menor(A, 1, 1) - a12*menor(A, 1, 2)
#: Letra por letra, es lo mismo que devuelve el determinante:
dA = det(A)

## 1 · Adjunta partida por el determinante
#: El camino clásico. La adjunta coloca cada cofactor en su sitio y el determinante los escala. Fíjate en que el determinante queda **debajo** de las cuatro entradas:
inv1 = adj(A) * (1/det(A))
#: Ahí se ve por qué el determinante no puede valer cero: sería dividir entre cero cuatro veces. Y la prueba de que esta matriz deshace a A:
chk1 = A * (adj(A) * (1/det(A)))

## 2 · Gauss-Jordan, con los movimientos de fila hechos matriz
#: Gauss-Jordan se explica siempre "moviendo filas a mano". Pero cada movimiento de fila **es una matriz**, y multiplicar por ella hace el movimiento. Así la reducción la ejecuta el motor de verdad, sin que nadie teclee el resultado de ningún paso.
#: Primer movimiento: dividir la fila 1 entre el pivote, para que arriba a la izquierda quede un uno.
E1 = [1/a11, 0; 0, 1]
p1 = E1 * A
#: Segundo: restarle a la fila 2 la fila 1 multiplicada por su primer término, para abrir un cero debajo del pivote.
E2 = [1, 0; -a21, 1]
p2 = E2 * E1 * A
#: Mira lo que ha aparecido abajo a la derecha: el determinante dividido por el pivote. Nadie lo ha metido ahí, sale solo.
#: Tercero: dividir la fila 2 entre ese segundo pivote, para que también quede un uno.
E3 = [1, 0; 0, a11/(a11*a22 - a12*a21)]
p3 = E3 * E2 * E1 * A
#: Cuarto y último: limpiar el término que queda arriba a la derecha.
E4 = [1, -a12/a11; 0, 1]
p4 = E4 * E3 * E2 * E1 * A
#: Ha llegado a la identidad. Y ahí está la idea entera de Gauss-Jordan: si el producto de los cuatro movimientos convierte A en la identidad, **ese producto es la inversa**.
inv2 = E4 * E3 * E2 * E1
#: Es la misma matriz de la Forma 1, con las fracciones repartidas de otro modo. La prueba:
chk2 = (E4 * E3 * E2 * E1) * A

## 3 · Cayley-Hamilton: la matriz resuelve su propia ecuación
#: Toda matriz cumple su ecuación característica. Para una 2×2 dice que su cuadrado, menos la traza por ella, más el determinante por la identidad, se anula. No hay que creerlo: el motor lo comprueba y sale la matriz **cero**.
CH = A*A - trace(A)*A + det(A)*Id
#: De esa igualdad se despeja la inversa sin nombrar ni una sola vez la palabra cofactor: la traza por la identidad, menos la propia matriz, todo partido por el determinante.
inv3 = (trace(A)*Id - A) * (1/det(A))
#: Idéntica a las anteriores, por un camino completamente distinto. La prueba:
chk3 = A * ((trace(A)*Id - A) * (1/det(A)))

## 4 · Faddeev-LeVerrier: Cayley-Hamilton para cualquier tamaño
#: El camino anterior usó la forma de la ecuación característica de una 2×2. Faddeev-LeVerrier la construye sola, para cualquier tamaño, encadenando trazas. El primer coeficiente es la traza; el segundo sale de la traza del producto siguiente:
FM = A - trace(A)*Id
Fc = trace(A*(A - trace(A)*Id)) * (1/2)
#: Y ese coeficiente es, salvo el signo, el determinante —que el método descubre en vez de suponerlo—. La inversa es el último término dividido por él:
inv4 = (A - trace(A)*Id) * (1/Fc)
chk4 = A * ((A - trace(A)*Id) * (1/Fc))

## 5 · Cramer: cada columna de la inversa es un sistema
#: La inversa se puede levantar **columna a columna**. La primera columna es la que A transforma en el primer vector de la identidad; la segunda, en el segundo. Cada una se resuelve con Cramer: se cambia una columna de A por el término independiente y se divide un determinante entre otro.
bb = [b1; b2]
Ab1 = [b1, a12; b2, a22]
Ab2 = [a11, b1; a21, b2]
#: Así queda la solución del sistema, escrita como la escribe Cramer —cociente de determinantes—:
xcr = [det(Ab1)/det(A); det(Ab2)/det(A)]
#: Y esto demuestra que Cramer y la adjunta son el mismo álgebra con otra ropa: la adjunta por el término independiente da exactamente los numeradores de arriba.
adjbb = adj(A) * bb
#: Poniendo como término independiente las columnas de la identidad salen, una a una, las columnas de la inversa:
col1 = [det([1, a12; 0, a22])/det(A); det([a11, 1; a21, 0])/det(A)]
col2 = [det([0, a12; 1, a22])/det(A); det([a11, 0; a21, 1])/det(A)]

## 6 · Factorizar en dos triangulares (LU)
#: Otro camino: partir A en dos matrices triangulares, una con ceros debajo y otra con ceros encima. Son justo las que deja Gauss antes de limpiar hacia arriba.
Lm = [1, 0; a21/a11, 1]
Um = [a11, a12; 0, a22 - a21*a12/a11]
#: Que la partición es correcta lo dice el propio producto: reconstruye A entera.
LUm = Lm * Um
#: Invertir una triangular es fácil, porque se despeja en cadena de arriba abajo. Cada una por su lado:
iU = Um^-1
iL = Lm^-1
#: Y la inversa de un producto invierte el orden de los factores: primero se deshace lo último que se hizo.
inv6 = Um^-1 * Lm^-1
chk6 = (Um^-1 * Lm^-1) * A
#: La misma factorización admite repartir el pivote al otro lado —eso es Crout en vez de Doolittle—, y el resultado no cambia:
Lcr = [a11, 0; a21, a22 - a21*a12/a11]
Ucr = [1, a12/a11; 0, 1]
LUcr = Lcr * Ucr
inv6b = Ucr^-1 * Lcr^-1

## 7 · Por bloques: el complemento de Schur
#: Este es el camino de los programas grandes, y el de la condensación estática del FEM: se parte la matriz en bloques, se invierte el primero y aparece el **complemento de Schur**, que es lo que queda del resto una vez descontado lo que el primer bloque ya explica.
sc = a22 - a21*(1/a11)*a12
#: Con él se arma la inversa por bloques. Fíjate en que el complemento hace de determinante local, y en que solo hubo que invertir el bloque de la esquina:
blk = [1/a11 + a12*a21/(a11*a11*sc), -a12/(a11*sc); -a21/(a11*sc), 1/sc]
chk7 = blk * A

## 8 · Diagonalizar: invertir números en vez de matrices
#: Si se mira la matriz en la dirección de sus **autovectores**, deja de mezclar y solo estira. En esa dirección es diagonal, y una diagonal se invierte dando la vuelta a cada número. Los autovalores salen de anular el determinante de A menos lambda por la identidad:
lam = Despejar{ det(A - lambda*Id) = 0 @ lambda }
#: Para recorrer el camino entero con letras limpias uso una matriz simétrica, cuyos autovectores son las dos diagonales del cuadrado:
Sm = [p, q; q, p]
Pm = [1, 1; 1, -1]
Dm = [p+q, 0; 0, p-q]
#: Que la descomposición es correcta lo dice el producto: reconstruye la matriz de partida.
chkP = Pm * Dm * Pm^-1
#: La diagonal se invierte número a número: cada estiramiento se deshace encogiendo lo mismo.
iDm = Dm^-1
#: Y volviendo a la base original queda la inversa, sin haber invertido ninguna matriz llena:
inv8 = Pm * Dm^-1 * Pm^-1
chk8 = Sm * (Pm * Dm^-1 * Pm^-1)

## 9 · Cuando la matriz es ortogonal, la inversa es la transpuesta
#: Hay un caso en que invertir no cuesta nada. Si las columnas son perpendiculares entre sí y de largo uno, la matriz solo gira, y deshacer un giro es girar al revés: basta con transponer. Un giro de ángulo theta:
Rot = [cos(theta), -sin(theta); sin(theta), cos(theta)]
#: Multiplicada por su transpuesta da la identidad —y ahí está Pitágoras haciendo el trabajo—:
chk9 = Rot * transpose(Rot)
#: Lo mismo con una matriz de permutación, que solo intercambia filas:
Perm = [0, 1; 1, 0]
chk9b = Perm * transpose(Perm)

## 10 · QR: separar el giro del estiramiento (Gram-Schmidt)
#: Si la matriz no es ortogonal, se puede partir en una que sí lo es y otra triangular. La ortogonal se invierte transponiendo (gratis) y la triangular, despejando en cadena. Las direcciones ortonormales de la matriz simétrica de antes:
Qm = [1/sqrt(2), 1/sqrt(2); 1/sqrt(2), -1/sqrt(2)]
chk10 = Qm * transpose(Qm)
#: La parte triangular es lo que queda al mirar la matriz desde esas direcciones:
Rm = transpose(Qm) * Sm
#: Y las dos juntas reconstruyen la matriz:
QRm = Qm * (transpose(Qm) * Sm)
#: La inversa, entonces, es la triangular invertida por la transpuesta de la ortogonal:
inv10 = (transpose(Qm)*Sm)^-1 * transpose(Qm)

## 11 · Cholesky: la raíz cuadrada de una matriz simétrica
#: Cuando la matriz es simétrica y define energía positiva —la matriz de rigidez del FEM lo es—, se parte en una triangular por su propia transpuesta. Es media LU, y cuesta la mitad.
Lch = [sqrt(p), 0; q/sqrt(p), sqrt(p - q*q/p)]
#: Que es la partición correcta lo dice el producto, que reconstruye la simétrica:
chk11 = Lch * transpose(Lch)
#: Invertida la triangular, la inversa sale sin tocar la matriz llena:
iLch = Lch^-1
inv11 = transpose(Lch)^-1 * Lch^-1

## 12 · La pseudo-inversa de Moore-Penrose
#: Esta es la inversa **generalizada**: existe aunque la matriz no sea cuadrada. Se construye con la transpuesta por la matriz, invertida, por la transpuesta.
pinv = (transpose(A)*A)^-1 * transpose(A)
#: Y cuando la matriz sí es cuadrada e invertible —como aquí—, la pseudo-inversa **es** la inversa de siempre: mira el resultado y compáralo con la Forma 1.
chk12 = ((transpose(A)*A)^-1 * transpose(A)) * A

## 13 · Sherman-Morrison: invertir el cambio, no la matriz
#: Si ya tienes una inversa y la matriz cambia un poco —una columna por otra, un apoyo que se añade—, no hace falta empezar de nuevo. Sherman-Morrison corrige la inversa que ya tenías. El cambio, escrito como columna por fila:
uu = [u1; u2]
vv = [v1; v2]
Bsm = Id + uu*transpose(vv)
#: Todo el coste está en un escalar, este de aquí, que es lo único que hay que dividir:
den = 1 + transpose(vv)*uu
#: Y la inversa corregida:
inv13 = Id - uu*transpose(vv) * (1/(1 + transpose(vv)*uu))
chk13 = Bsm * (Id - uu*transpose(vv) * (1/(1 + transpose(vv)*uu)))

## 14 · La serie de Neumann: la primera que aproxima
#: Las trece anteriores son exactas. Esta no, y por eso es la que usan los métodos iterativos cuando la matriz es enorme. Si la matriz es la identidad **perturbada** por algo pequeño, su inversa se escribe como una suma de potencias de esa perturbación.
Nm = [0, n12; n21, 0]
Bn = Id - Nm
#: Los tres primeros términos de la serie:
sN = Id + Nm + Nm*Nm
#: Y aquí se ve exactamente qué se está dejando fuera: al multiplicar por la matriz original no sale la identidad limpia, sino la identidad menos el **cubo** de la perturbación. Ese es el error de cortar la serie:
chk14 = Bn * (Id + Nm + Nm*Nm)
#: Por eso la serie solo sirve si la perturbación es pequeña: si no, sus potencias crecen en vez de apagarse. El mismo fenómeno con un solo número: la curva azul es el valor exacto, y las otras dos son la serie cortada en uno y en dos términos.
#fplot(1/(1-x), 1+x, 1+x+x^2, [-0.9 0.9])
#: Cerca del cero las tres se pegan y la serie sirve. Hacia el uno la exacta se dispara y las cortadas se quedan atrás: ahí la aproximación deja de valer.

## 15 · Newton-Schulz: la iteración que dobla los aciertos
#: La serie anterior gana un término por vuelta. Newton-Schulz gana el **doble** cada vez: toma la inversa aproximada que llevas y la corrige multiplicándola por dos veces la identidad menos la matriz por ella. Arrancando desde el primer término de la serie:
X1 = 2*Id - Bn
X2 = X1 * (2*Id - Bn*X1)
#: Compara este resto con el de la serie: allí sobraba el cubo de la perturbación, aquí sobra la **cuarta** potencia. En una vuelta ha adelantado dos.
chk15 = Bn * X2

## 16 · Los casos en que no hay que hacer nada
#: Tres matrices se invierten mirándolas. Una diagonal, dando la vuelta a cada número:
Dg = [d1, 0; 0, d2]
iDg = Dg^-1
#: Una triangular, despejando en cadena y sin que aparezcan más ceros de los que ya había:
Sup = [s1, s2; 0, s3]
iSup = Sup^-1
#: Y una de un solo número, que es la división de toda la vida:
uno = [e1]
iuno = uno^-1

## 17 · Cuándo la inversa no existe
#: Si una fila es la otra multiplicada por algo, la matriz aplasta el plano contra una línea. Dos puntos distintos van a parar al mismo sitio, y desde el destino ya no se puede saber de cuál se venía. El determinante lo delata:
Asing = [a11, a12; k*a11, k*a12]
dSing = det(Asing)
#: Cero. Y como ese cero está debajo en todas las formas exactas, las quince fallan a la vez. No es el defecto de un método: es que la inversa **no existe**.

## 18 · Todos los caminos, la misma matriz
#: Adjunta, filas, ecuación característica, trazas encadenadas, determinantes de Cramer, factorización triangular, bloques, autovectores, transpuesta, QR, Cholesky, pseudo-inversa, corrección de rango uno, serie e iteración. Quince procedimientos, una sola respuesta. La resta de dos cualesquiera de ellos lo dice sin discutir:
dif12 = adj(A)*(1/det(A)) - E4*E3*E2*E1
dif13 = adj(A)*(1/det(A)) - (trace(A)*Id - A)*(1/det(A))
dif14 = adj(A)*(1/det(A)) - (A - trace(A)*Id)*(1/Fc)
dif16 = adj(A)*(1/det(A)) - Um^-1 * Lm^-1
dif17 = adj(A)*(1/det(A)) - blk
dif112 = adj(A)*(1/det(A)) - (transpose(A)*A)^-1 * transpose(A)
#: Todas cero. Y la definición, que era lo único que había que cumplir desde el principio:
final = A * A^-1
