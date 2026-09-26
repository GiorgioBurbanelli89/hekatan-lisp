# Losa rectangular por elementos finitos — el elemento BFS
#: Este es el mismo problema que resuelve `rectangular_slab_bfs.m` en Hekatan Lab: una losa rectangular simplemente apoyada con carga uniforme, mallada con el elemento BFS (Bogner-Fox-Schmit) de 16 grados de libertad. Aquí se DEDUCE la formulación paso a paso. Al final está marcado, sin adornos, qué parte NO puede hacer hoy este motor.

## 1 · Los datos
a = 6 @@(dimensión en x, m)
b = 4 @@(dimensión en y, m)
t = 0.1 @@(espesor, m)
q = 10 @@(carga repartida, kN/m²)
E = 35000000 @@(módulo elástico, kN/m²)
nu = 0.15 @@(coeficiente de Poisson)

## 2 · El mallado
#: La losa se parte en una rejilla de elementos rectangulares. Cada elemento tiene cuatro nudos, y cada nudo CUATRO grados de libertad.
n_a = 6 @@(elementos en la dirección a)
n_b = 4 @@(elementos en la dirección b)
n_e = 6·4 @@(elementos en total)
n_j = 7·5 @@(nudos en total)
a_1 = 6/6 @@(ancho de un elemento, m)
b_1 = 4/4 @@(alto de un elemento, m)
#: Y aquí está lo que distingue al BFS: cuatro grados por nudo, no tres. Se añade la derivada cruzada.
n_dof = 4 @@(w, θx, θy y la torsión cruzada ∂²w/∂x∂y)
n_ke = 4·4 @@(grados por elemento: la K de un elemento es de 16 × 16)
n_g = 4·35 @@(grados totales del modelo)

## 3 · La rigidez a flexión de la placa
#: Sale de integrar el cuadrado del brazo a través del espesor. Es la D del capítulo de la cáscara.
D_11 = 35000000·0.1^3/(12·(1 - 0.15^2))
#: Y la matriz constitutiva de flexión, con el Poisson acoplando las dos direcciones y el cortante en la esquina.
D_b = [1, 0.15, 0; 0.15, 1, 0; 0, 0, (1-0.15)/2]

## 4 · Las funciones de forma: las cuatro Hermite
#: El BFS no inventa funciones nuevas. Usa las mismas cuatro Hermite cúbicas de una dimensión, las que ya dedujimos con la matriz de coeficientes. Escritas en el tramo de 0 a 1:
P_1 = 1 - 3·x^2 + 2·x^3 @@(vale 1 donde el nudo baja)
P_2 = x - 2·x^2 + x^3 @@(vale 1 donde el nudo gira)
P_3 = 3·x^2 - 2·x^3 @@(la del otro nudo)
P_4 = -x^2 + x^3 @@(y su giro)
#: Comprobación: en el nudo de la izquierda la primera vale uno y las otras cero. Se sustituye x = 0 y x = 1.

## 5 · Las curvaturas: derivando DOS veces
#: La placa flexiona, así que lo que hace falta es la segunda derivada de cada Hermite. El motor las saca:
C_1 = Diff{Diff{1 - 3·x^2 + 2·x^3 @ x} @ x}
C_2 = Diff{Diff{x - 2·x^2 + x^3 @ x} @ x}
C_3 = Diff{Diff{3·x^2 - 2·x^3 @ x} @ x}
C_4 = Diff{Diff{-x^2 + x^3 @ x} @ x}
#: Estas cuatro curvaturas son las que van dentro de la matriz B del elemento.

## 6 · Las 16 funciones del BFS: el producto de dos Hermite
#: Y aquí está la idea del elemento. Cada una de las dieciséis funciones de forma es el PRODUCTO de una Hermite en una dirección por otra Hermite en la otra. Cuatro por cuatro, dieciséis.
N_1 = (1 - 3·x^2 + 2·x^3)·(1 - 3·y^2 + 2·y^3) @@(la del nudo 1, en su grado w)
N_6 = (x - 2·x^2 + x^3)·(1 - 3·y^2 + 2·y^3) @@(otra: giro en x por flecha en y)
#: Igual que las bilineales de cuatro nudos son el producto de dos rectas, las del BFS son el producto de dos cúbicas. Por eso hacen falta los cuatro grados por nudo: el cuarto es el que cierra el producto.

## 7 · Las tres curvaturas de la placa
#: De cada función de forma salen TRES curvaturas, y cada una da un momento. Las dos primeras son derivadas dobles rectas; la tercera es la CRUZADA.
K_11 = Partial{Partial{(1 - 3·x^2 + 2·x^3)·(1 - 3·y^2 + 2·y^3) @ x} @ x} @@(da el momento M11)
K_22 = Partial{Partial{(1 - 3·x^2 + 2·x^3)·(1 - 3·y^2 + 2·y^3) @ y} @ y} @@(da el momento M22)
K_12 = Partial{Partial{(1 - 3·x^2 + 2·x^3)·(1 - 3·y^2 + 2·y^3) @ x} @ y} @@(la cruzada: da el torsor M12)
#: Fíjate en la última: se deriva UNA vez respecto a cada dirección. Ésa es la que obliga a llevar el cuarto grado de libertad en cada nudo.

## 8 · La rigidez: la doble integral
#: La matriz del elemento es la doble integral, en las dos direcciones, del producto de las curvaturas por la constitutiva. Un término concreto, con las curvaturas ya sustituidas:
k_11 = Area{Area{(-6+12·x)^2·(1 - 3·y^2 + 2·y^3)^2 @ x=0:1} @ y=0:1}
k_12 = Area{Area{(-6+12·x)·(-4+6·x)·(1 - 3·y^2 + 2·y^3)^2 @ x=0:1} @ y=0:1}
#: Repitiendo eso para las 16 × 16 parejas sale la matriz del elemento. En el script de Hekatan Lab esa doble integral se hace con cuadratura de Gauss de 4 × 4 puntos: un bucle dentro de otro.

## 9 · La comprobación del espesor
#: Y de paso, de dónde viene el doce de la fórmula de la placa. Se suma el cuadrado del brazo a través del espesor, de una cara a la otra, con el espesor en centímetros:
I_p = Area{z^2 @ z=-5:5}
chk = 10^3/12
#: El mismo número. El doce no es un número mágico: es el resultado de esa integral.

## 10 · LO QUE ESTE MOTOR NO PUEDE HACER TODAVÍA
#: Hasta aquí llega la deducción, y llega entera: funciones de forma, curvaturas, la constitutiva y la doble integral, todo simbólico y comprobado. Lo que falta para resolver la losa COMPLETA como hace el script de Hekatan Lab es esto, y conviene tenerlo escrito:
#: 1 · No hay BUCLES. No se puede escribir "para cada elemento" ni "para cada punto de Gauss". Los 16 × 16 términos hay que escribirlos a mano, uno por uno.
#: 2 · No hay ENSAMBLAJE. No hay forma de sumar la matriz de cada elemento dentro de una matriz global de 140 grados, que es lo que pide este mallado.
#: 3 · No se puede RESOLVER un sistema grande ni aplicar los apoyos de todo un contorno.
#: 4 · No hay MAPA DE COLOR. Hekatan Lab tiene `contourf` y dibuja los campos; aquí no existe, así que los resultados no se pueden pintar.
#: Con bucles, ensamblaje, solver y contourf, este mismo worksheet resolvería la losa entera y dibujaría M11, M22 y M12 sin salir del motor.
