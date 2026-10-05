# Las funciones de forma de la losa: qué son y de dónde salen sus derivadas
#: La hoja **Rectangular Slab FEA** de Calcpad abre con una tabla de tres columnas: las **funciones base**, sus **primeras derivadas** y sus **segundas derivadas**. Aquí se explica qué es cada columna, por qué en unas aparece el lado a_{1} dividiendo y en otras no, y para qué sirve cada una.
#: **La idea en una línea.** Entre dos nudos la losa se dobla como una **cúbica**. Una cúbica tiene cuatro coeficientes, y en los dos nudos hay cuatro datos: la flecha y el giro de cada uno. Cuatro datos, cuatro funciones.
#: **Cómo se comprueba.** El motor deriva cada función y se le resta la fórmula de la tabla de Calcpad. Si la tabla está bien, la resta da cero.

## 1 · El elemento, dibujado con la herramienta CAD
#: El elemento es un rectángulo de lados a_{1} y b_{1} con un nudo en cada esquina. Está dibujado en la **ventana de dibujo**: con el botón «Dibujar / Editar» que hay debajo del dibujo se abre, se estira el rectángulo y se guarda en la hoja. Los números del punto 8 se recalculan con el lado nuevo.
#dibujar(elemento, ancho = 120, alto = 70, ud = m, cuadricula = 0.25)
;; dibujado con la ventana ✏ — 1 entidad (listas DXF de AutoLISP: se reescribe al guardar)
(entmake '((0 . "LAYER") (100 . "AcDbSymbolTableRecord") (100 . "AcDbLayerTableRecord") (2 . "ELEMENTO") (70 . 0) (62 . 5) (6 . "CONTINUOUS")))
(entmake '((0 . "LWPOLYLINE") (100 . "AcDbEntity") (8 . "ELEMENTO") (100 . "AcDbPolyline") (90 . 4) (70 . 1) (10 0.0 0.0) (10 2.0 0.0) (10 2.0 1.0) (10 0.0 1.0)))
#fin
#: El bloque de abajo **lee** ese rectángulo, mide sus dos lados (l_{a} y l_{b}) y le pone los nudos, las cotas y los dos ejes del elemento:
#autolisp("El elemento leído del dibujo: cuatro nudos y dos ejes", ancho = 130, alto = 85, exporta = l_a l_b)
(setq S (primera "ELEMENTO" "LWPOLYLINE"))
(setq l_a (ancho S) l_b (alto S))
(setq la l_a lb l_b)
(capa "NUDOS" :color 1)
(circulo (list 0 0) (* 0.03 lb))
(circulo (list la 0) (* 0.03 lb))
(circulo (list la lb) (* 0.03 lb))
(circulo (list 0 lb) (* 0.03 lb))
(texto (list (* -0.09 lb) (* -0.12 lb)) "1" :altura (* 0.09 lb))
(texto (list (+ la (* 0.04 lb)) (* -0.12 lb)) "2" :altura (* 0.09 lb))
(texto (list (+ la (* 0.04 lb)) (+ lb (* 0.04 lb))) "3" :altura (* 0.09 lb))
(texto (list (* -0.09 lb) (+ lb (* 0.04 lb))) "4" :altura (* 0.09 lb))
(capa "EJES DEL ELEMENTO" :color 3)
(linea (list 0 0) (list (* 0.45 la) 0) :grosor 0.5)
(linea (list (* 0.45 la) 0) (list (- (* 0.45 la) (* 0.08 lb)) (* 0.04 lb)) :grosor 0.5)
(linea (list (* 0.45 la) 0) (list (- (* 0.45 la) (* 0.08 lb)) (* -0.04 lb)) :grosor 0.5)
(linea (list 0 0) (list 0 (* 0.6 lb)) :grosor 0.5)
(linea (list 0 (* 0.6 lb)) (list (* 0.04 lb) (* 0.52 lb)) :grosor 0.5)
(linea (list 0 (* 0.6 lb)) (list (* -0.04 lb) (* 0.52 lb)) :grosor 0.5)
(formula (list (* 0.46 la) (* 0.04 lb)) "ξ" :altura (* 0.1 lb) :color 3)
(formula (list (* 0.05 lb) (* 0.6 lb)) "η" :altura (* 0.1 lb) :color 3)
(capa "COTAS" :color 8)
(cota (list 0 0) (list la 0) :sep (* -0.3 lb) :texto "a₁")
(cota (list la 0) (list la lb) :sep (* -0.3 lb) :texto "b₁")
#fin
#: En cada nudo la losa tiene la **flecha** w (cuánto baja) y los **giros** (cuánto se inclina). A lo largo del lado a, entre el nudo 1 y el nudo 2, eso son cuatro datos: w_{1}, θ_{1}, w_{2}, θ_{2}.

## 2 · La coordenada ξ: el lado medido de 0 a 1
#: En vez de medir en metros se mide en **fracción del lado**: ξ = x / a_{1}, la distancia al nudo 1 dividida por el lado.
#: ξ vale 0 en el nudo 1, 0.5 en el centro y 1 en el nudo 2. **Por qué:** así las fórmulas son las mismas para un elemento de 0.5 m y para uno de 3 m. El tamaño real entra una sola vez, con a_{1}.

## 3 · Las cuatro funciones base
#: Son las de la primera columna de la tabla:
Φ_1a(ξ) = 1 - ξ^2*(3 - 2*ξ)
Φ_2a(ξ) = ξ*a_1*(1 - ξ*(2 - ξ))
Φ_3a(ξ) = ξ^2*(3 - 2*ξ)
Φ_4a(ξ) = ξ^2*a_1*(-1 + ξ)
#| Función | Dato que multiplica | Qué dibuja |
#|---|---|---|
#| Φ_{1a} | la flecha del nudo 1 | el nudo 1 baja 1 |
#| Φ_{2a} | el giro del nudo 1 | el nudo 1 gira 1 |
#| Φ_{3a} | la flecha del nudo 2 | el nudo 2 baja 1 |
#| Φ_{4a} | el giro del nudo 2 | el nudo 2 gira 1 |
#: La flecha en cualquier punto es la suma de las cuatro, cada una por su dato: w(ξ) = w_{1}·Φ_{1a} + θ_{1}·Φ_{2a} + w_{2}·Φ_{3a} + θ_{2}·Φ_{4a}. Es la misma idea que y = m·x + b, con cuatro sumandos en vez de dos.
#: **Comprobación en los nudos.** A la izquierda el nudo 1 (ξ = 0), a la derecha el nudo 2 (ξ = 1). Las dos funciones de flecha valen 1 en su nudo y 0 en el otro:
Φ_1a(0); Φ_1a(1)
Φ_3a(0); Φ_3a(1)
#: Las dos funciones de giro tienen **pendiente** 1 en su nudo y 0 en el otro (la pendiente en metros: la de ξ dividida por a_{1}, como se explica en el punto 5):
giro_21 = Simplify{Slope{Φ_2a(ξ) @ ξ = 0}*(1/a_1)} 'Φ_2a en el nudo 1
giro_22 = Simplify{Slope{Φ_2a(ξ) @ ξ = 1}*(1/a_1)} 'Φ_2a en el nudo 2
giro_41 = Simplify{Slope{Φ_4a(ξ) @ ξ = 0}*(1/a_1)} 'Φ_4a en el nudo 1
giro_42 = Simplify{Slope{Φ_4a(ξ) @ ξ = 1}*(1/a_1)} 'Φ_4a en el nudo 2
#: Las cuatro curvas, con a_{1} = 1 para verlas en la misma escala:
#fplot(flecha_nudo_1 = 1 - x^2*(3 - 2*x), giro_nudo_1 = x*(1 - x*(2 - x)), flecha_nudo_2 = x^2*(3 - 2*x), giro_nudo_2 = x^2*(-1 + x), [0 1])

## 4 · Animación: se mueve un solo dato cada vez
#: La franja entre el nudo 1 y el nudo 2, vista de lado. En cada animación crece **un solo dato** de 0 a 1 y los otros tres se quedan en cero. La curva azul **es** la función de forma de ese dato. La raya roja de cada nudo es la tangente: marca el giro.
#: Cada animación arranca sola y se repite. Con ⏸ se para, con la barra se elige el cuadro y con 🔊 se oye el valor de cada cuadro.

### 4.1 · La flecha del nudo 1: dibuja Φ_{1a}
#: El nudo 1 sube; el nudo 2 no se mueve y las dos tangentes siguen horizontales.
#anim(k = 0:10)
#autolisp("Sube la flecha del nudo 1", ancho = 130, alto = 110)
(setq d (/ k 10.0))
(capa "SIN DEFORMAR" :color 8 :tipo "trazos")
(linea (list 0 0) (list 1 0))
(capa "DEFORMADA" :color 5)
(curva '(* d (- 1 (* x x (- 3 (* 2 x))))) 0 1 :color 5 :grosor 0.5)
(capa "NUDOS Y TANGENTES" :color 1)
(circulo (list 0 d) 0.02)
(circulo (list 1 0) 0.02)
(linea (list 0 d) (list 0.22 d) :grosor 0.5)
(linea (list 1 0) (list 0.78 0) :grosor 0.5)
(ejes 0 1 -0.25 1 :paso-x 0.25 :paso-y 0.25 :nombre-x "ξ" :nombre-y "w")
#fin
#voz: Flecha del nudo 1: {k} décimas.
#finanim

### 4.2 · El giro del nudo 1: dibuja Φ_{2a}
#: La tangente del nudo 1 se inclina; ningún nudo se mueve de su sitio.
#anim(k = 0:10)
#autolisp("Crece el giro del nudo 1", ancho = 130, alto = 110)
(setq d (/ k 10.0))
(capa "SIN DEFORMAR" :color 8 :tipo "trazos")
(linea (list 0 0) (list 1 0))
(capa "DEFORMADA" :color 5)
(curva '(* d x (- 1 (* x (- 2 x)))) 0 1 :color 5 :grosor 0.5)
(capa "NUDOS Y TANGENTES" :color 1)
(circulo (list 0 0) 0.02)
(circulo (list 1 0) 0.02)
(linea (list 0 0) (list 0.22 (* 0.22 d)) :grosor 0.5)
(linea (list 1 0) (list 0.78 0) :grosor 0.5)
(ejes 0 1 -0.25 1 :paso-x 0.25 :paso-y 0.25 :nombre-x "ξ" :nombre-y "w")
#fin
#voz: Giro del nudo 1: {k} décimas.
#finanim

### 4.3 · La flecha del nudo 2: dibuja Φ_{3a}
#: Es la del nudo 1 vista en un espejo: ahora sube el nudo 2.
#anim(k = 0:10)
#autolisp("Sube la flecha del nudo 2", ancho = 130, alto = 110)
(setq d (/ k 10.0))
(capa "SIN DEFORMAR" :color 8 :tipo "trazos")
(linea (list 0 0) (list 1 0))
(capa "DEFORMADA" :color 5)
(curva '(* d x x (- 3 (* 2 x))) 0 1 :color 5 :grosor 0.5)
(capa "NUDOS Y TANGENTES" :color 1)
(circulo (list 0 0) 0.02)
(circulo (list 1 d) 0.02)
(linea (list 0 0) (list 0.22 0) :grosor 0.5)
(linea (list 1 d) (list 0.78 d) :grosor 0.5)
(ejes 0 1 -0.25 1 :paso-x 0.25 :paso-y 0.25 :nombre-x "ξ" :nombre-y "w")
#fin
#voz: Flecha del nudo 2: {k} décimas.
#finanim

### 4.4 · El giro del nudo 2: dibuja Φ_{4a}
#: La curva queda por debajo: para llegar al nudo 2 subiendo, primero tiene que bajar.
#anim(k = 0:10)
#autolisp("Crece el giro del nudo 2", ancho = 130, alto = 110)
(setq d (/ k 10.0))
(capa "SIN DEFORMAR" :color 8 :tipo "trazos")
(linea (list 0 0) (list 1 0))
(capa "DEFORMADA" :color 5)
(curva '(* d x x (- x 1)) 0 1 :color 5 :grosor 0.5)
(capa "NUDOS Y TANGENTES" :color 1)
(circulo (list 0 0) 0.02)
(circulo (list 1 0) 0.02)
(linea (list 0 0) (list 0.22 0) :grosor 0.5)
(linea (list 1 0) (list 0.78 (* -0.22 d)) :grosor 0.5)
(ejes 0 1 -0.25 1 :paso-x 0.25 :paso-y 0.25 :nombre-x "ξ" :nombre-y "w")
#fin
#voz: Giro del nudo 2: {k} décimas.
#finanim
#: **Lo que hay que mirar.** Cuando sube una flecha, las dos tangentes siguen horizontales: los giros valen cero. Cuando crece un giro, los dos nudos no se mueven de su sitio: solo cambia la inclinación en uno. Por eso cada dato tiene su función y no se mezclan.

## 5 · Primera derivada: la pendiente, que es el giro
#: La derivada de una curva es su **pendiente** en cada punto (la m de y = m·x + b). En la losa la pendiente de la flecha es el **giro**.
#: **Por qué aparece 1/a_{1}.** Las funciones están escritas en ξ, pero el giro es la pendiente en metros. Como ξ = x/a_{1}, avanzar 1 en ξ es avanzar a_{1} metros: la pendiente en metros es la pendiente en ξ **dividida por a_{1}** (regla de la cadena).
#: **Paso 1 · la regla de la cadena.** Φ está escrita en ξ, y ξ depende de x. La derivada respecto a x es la derivada respecto a ξ por lo que cambia ξ cuando cambia x: dΦ/dx = dΦ/dξ · dξ/dx. Y dξ/dx sale de ξ = x/a_{1}:
ξ_x = Diff{x/a_1 @ x}
#: Por eso toda derivada en x es la derivada en ξ **multiplicada por 1/a_{1}**.
#: **Paso 2 · cada función, desarrollada** en potencias de ξ (se quitan los paréntesis):
Φ_1d = Expand{1 - ξ^2*(3 - 2*ξ)}
Φ_2d = Expand{ξ*a_1*(1 - ξ*(2 - ξ))}
Φ_3d = Expand{ξ^2*(3 - 2*ξ)}
Φ_4d = Expand{ξ^2*a_1*(-1 + ξ)}
#: **Paso 3 · se deriva término a término** con la regla de la potencia, d(ξⁿ)/dξ = n·ξⁿ⁻¹: la constante da 0, ξ da 1, ξ² da 2·ξ y ξ³ da 3·ξ². En Φ_{1a}: 1 → 0, −3·ξ² → −6·ξ, 2·ξ³ → 6·ξ².
dΦ_1 = Diff{1 - 3*ξ^2 + 2*ξ^3 @ ξ}
dΦ_2 = Diff{a_1*ξ - 2*a_1*ξ^2 + a_1*ξ^3 @ ξ}
dΦ_3 = Diff{3*ξ^2 - 2*ξ^3 @ ξ}
dΦ_4 = Diff{a_1*ξ^3 - a_1*ξ^2 @ ξ}
#: **Paso 4 · se multiplica por 1/a_{1}** (paso 1). En Φ′_{2a} y Φ′_{4a} el a_{1} que ya llevaban se cancela. El motor hace los cuatro pasos de una vez, directamente sobre las funciones:
Φprime_1a = Simplify{Diff{Φ_1a(ξ) @ ξ}*(1/a_1)}
Φprime_2a = Simplify{Diff{Φ_2a(ξ) @ ξ}*(1/a_1)}
Φprime_3a = Simplify{Diff{Φ_3a(ξ) @ ξ}*(1/a_1)}
Φprime_4a = Simplify{Diff{Φ_4a(ξ) @ ξ}*(1/a_1)}
#: **Por qué en Φ′_{2a} y Φ′_{4a} no queda a_{1}.** Esas dos funciones ya llevaban a_{1} multiplicando (son las del giro); al dividir por a_{1} se cancela. Así su pendiente en el nudo vale exactamente 1, que es lo que tiene que valer un giro unitario.
#: **Contra la tabla de Calcpad** (segunda columna). En cada línea, lo que deriva el motor menos la fórmula de la tabla:
r_1 = Simplify{Diff{Φ_1a(ξ) @ ξ}*(1/a_1) - (-6*(ξ/a_1)*(1 - ξ))}
r_2 = Simplify{Diff{Φ_2a(ξ) @ ξ}*(1/a_1) - (1 - ξ*(4 - 3*ξ))}
r_3 = Simplify{Diff{Φ_3a(ξ) @ ξ}*(1/a_1) - 6*(ξ/a_1)*(1 - ξ)}
r_4 = Simplify{Diff{Φ_4a(ξ) @ ξ}*(1/a_1) - (-ξ*(2 - 3*ξ))}
#: Cuatro ceros: la segunda columna es la derivada de la primera.
#: **Animación: la tangente recorre la curva.** La recta roja toca a Φ_{1a} en el punto ξ = n/10. Su inclinación es Φ′_{1a} en ese punto: nula en los dos nudos y máxima en el centro.
#anim fplot(flecha_nudo_1 = 1 - x^2*(3 - 2*x), tangente = 1 - (n/10)^2*(3 - 2*n/10) - 6*(n/10)*(1 - n/10)*(x - n/10), [0 1]), n = 0:10

## 6 · Segunda derivada: la curvatura, que da el momento
#: La segunda derivada dice **cuánto cambia la pendiente**, o sea cuánto se curva la losa. El momento flector es la rigidez por la curvatura: donde no hay curvatura no hay momento. Por eso el programa necesita la tercera columna: con ella arma la rigidez y después saca los momentos.
#: **Por qué aparece 1/a_{1}².** Se deriva dos veces, y cada vez se divide por a_{1}.
Φpprime_1a = Simplify{Diff{Diff{Φ_1a(ξ) @ ξ} @ ξ}*(1/a_1^2)}
Φpprime_2a = Simplify{Diff{Diff{Φ_2a(ξ) @ ξ} @ ξ}*(1/a_1^2)}
Φpprime_3a = Simplify{Diff{Diff{Φ_3a(ξ) @ ξ} @ ξ}*(1/a_1^2)}
Φpprime_4a = Simplify{Diff{Diff{Φ_4a(ξ) @ ξ} @ ξ}*(1/a_1^2)}
#: **Contra la tabla de Calcpad** (tercera columna):
s_1 = Simplify{Diff{Diff{Φ_1a(ξ) @ ξ} @ ξ}*(1/a_1^2) - (-(6/a_1^2)*(1 - 2*ξ))}
s_2 = Simplify{Diff{Diff{Φ_2a(ξ) @ ξ} @ ξ}*(1/a_1^2) - (-(2/a_1)*(2 - 3*ξ))}
s_3 = Simplify{Diff{Diff{Φ_3a(ξ) @ ξ} @ ξ}*(1/a_1^2) - (6/a_1^2)*(1 - 2*ξ)}
s_4 = Simplify{Diff{Diff{Φ_4a(ξ) @ ξ} @ ξ}*(1/a_1^2) - (-(2/a_1)*(1 - 3*ξ))}
#: **Qué forma tienen.** La segunda derivada de una cúbica es una **recta**: dentro de un elemento la curvatura, y con ella el momento, varía en línea recta. Por eso una malla gruesa dibuja los momentos a tramos rectos. Con a_{1} = 1:
#fplot(flecha_nudo_1 = -6*(1 - 2*x), giro_nudo_1 = -2*(2 - 3*x), flecha_nudo_2 = 6*(1 - 2*x), giro_nudo_2 = -2*(1 - 3*x), [0 1])

## 7 · El otro lado: lo mismo con η y b_{1}
#: A lo largo del lado b las funciones son **las mismas**, con η = y / b_{1} en vez de ξ y b_{1} en vez de a_{1}. No hay nada nuevo que aprender:
Φ_1b(η) = 1 - η^2*(3 - 2*η)
Φ_2b(η) = η*b_1*(1 - η*(2 - η))
Φ_3b(η) = η^2*(3 - 2*η)
Φ_4b(η) = η^2*b_1*(-1 + η)
#: La comprobación de la tercera columna, ahora con b_{1}:
t_1 = Simplify{Diff{Diff{Φ_1b(η) @ η} @ η}*(1/b_1^2) - (-(6/b_1^2)*(1 - 2*η))}
t_2 = Simplify{Diff{Diff{Φ_2b(η) @ η} @ η}*(1/b_1^2) - (-(2/b_1)*(2 - 3*η))}
t_3 = Simplify{Diff{Diff{Φ_3b(η) @ η} @ η}*(1/b_1^2) - (6/b_1^2)*(1 - 2*η)}
t_4 = Simplify{Diff{Diff{Φ_4b(η) @ η} @ η}*(1/b_1^2) - (-(2/b_1)*(1 - 3*η))}
#: **De cuatro a dieciséis.** La función de forma de la losa es el **producto** de una de ξ por una de η: cuatro por cuatro, dieciséis. La primera, Φ_{1a}·Φ_{1b}, vale 1 en el nudo 1 (abajo a la izquierda) y 0 en los otros tres. En planta, con el color como altura:
#map((1 - x^2*(3 - 2*x))*(1 - y^2*(3 - 2*y)), [0 1], [0 1])

## 8 · Con los números del dibujo
#: Hasta aquí a_{1} y b_{1} eran letras. Ahora toman el valor de los lados medidos en el rectángulo del punto 1:
a_1 = l_a [m] 'lado del elemento en x, medido en el dibujo
b_1 = l_b [m] 'lado del elemento en y, medido en el dibujo
#: En el **centro del lado a** (ξ = 0.5), la pendiente y la curvatura que produce cada dato del nudo 1:
p_1 = dec(-6*(0.5/a_1)*(1 - 0.5), 4) [1/m] 'pendiente por la flecha del nudo 1
p_2 = dec(1 - 0.5*(4 - 3*0.5), 4) 'pendiente por el giro del nudo 1
c_1 = dec(-(6/a_1^2)*(1 - 2*0.5), 4) [1/m²] 'curvatura por la flecha del nudo 1
c_2 = dec(-(2/a_1)*(2 - 3*0.5), 4) [1/m] 'curvatura por el giro del nudo 1
#: **Lectura.** Con el lado de @{a_1} m, si el nudo 1 sube 1, la pendiente en el centro vale @{p_1} por metro (negativa: la curva va bajando hacia el nudo 2). La curvatura por esa flecha es cero en el centro: ahí la curva cambia de sentido. Si el rectángulo se estira en la ventana de dibujo, a_{1} crece y las pendientes bajan: el mismo movimiento repartido en más metros inclina menos.

## 9 · Resumen
#| Columna | Qué es | Lleva |
#|---|---|---|
#| Φ | la flecha | a_{1} solo en las de giro |
#| Φ′ | la pendiente: el giro | 1/a_{1} |
#| Φ″ | la curvatura: el momento | 1/a_{1}² |
#: **Para qué sirve cada una.** Con Φ se reparten la flecha y la carga entre los nudos. Con Φ′ se saca el giro en cualquier punto. Con Φ″ se arma la rigidez y se sacan los momentos.
#: **Fuente.** Las fórmulas son las de la hoja *Rectangular Slab FEA* de Calcpad (Ned Ganchovski). El análisis completo de esa losa, con estas mismas funciones, está en las hojas 71 y 85.
