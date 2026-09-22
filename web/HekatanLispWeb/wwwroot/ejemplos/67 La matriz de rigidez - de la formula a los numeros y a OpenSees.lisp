# La matriz de rigidez: de la fórmula a los números, y de ahí a OpenSees

#: Todo programa de cálculo se reduce a **una matriz por elemento**. Aquí está la de una barra: primero en símbolos, luego con los números de una columna del galpón, y al final el mismo elemento escrito en OpenSees.

## 0 · La columna del galpón

#: Un tubo cuadrado de acero, el que sostiene el pórtico curvo.

b = 0.25 'lado exterior del tubo [m] ; t = 0.008 'espesor de la pared [m] ; L = 6.0 'altura libre [m]
E = 200000000 'módulo del acero [kN/m²] ; G = 76923077 'módulo de corte [kN/m²]

A = dec(0.25^2 - (0.25 - 2*0.008)^2, 6) [m²] 'área de la sección
I = dec((0.25^4 - (0.25 - 2*0.008)^4)/12, 8) [m⁴] 'inercia
EI = dec(200000000*0.00007565, 1) [kN·m²] 'rigidez a flexión
EA = dec(200000000*0.007744, 0) [kN] 'rigidez axial

## 1 · Los cuatro términos, en símbolos

#: Una barra plana tiene **6 grados de libertad**: en cada extremo, dos desplazamientos y un giro. Su matriz es 6×6, y **solo hay cuatro números distintos** dentro:

#| Término | Fórmula | Qué mide |
#|---|---|---|
#| k_{axial} | E·A / L | cuánto cuesta **estirarla** |
#| k_{corte} | 12·E·I / L³ | cuánto cuesta **desplazar** un extremo |
#| k_{acopl} | 6·E·I / L² | el **acoplamiento** entre mover y girar |
#| k_{giro} | 4·E·I / L | cuánto cuesta **girar** un extremo |

#: El de al lado, `2·E·I / L`, es el giro **cruzado**: lo que le llega al otro extremo cuando giras éste.

## 2 · Los mismos cuatro, con números

k_a = dec(200000000*0.007744/6, 1) [kN/m] 'axial: E·A/L
k_v = dec(12*15129.8/6^3, 1) [kN/m] 'corte: 12·E·I/L³
k_m = dec(6*15129.8/6^2, 1) [kN] 'acoplamiento: 6·E·I/L²
k_g = dec(4*15129.8/6, 1) [kN·m] 'giro: 4·E·I/L
k_c = dec(2*15129.8/6, 1) [kN·m] 'giro cruzado: 2·E·I/L

#: **Mira la diferencia entre el axial y el de corte.** Estirar la columna cuesta {k_a} kN/m; desplazarla de lado, solo {k_v} kN/m.
razon = dec(258133.3/840.5, 0) [—] 'cuántas veces más rígida es a axial que a flexión

#: **{razon} veces.** Por eso una estructura se mueve de lado y casi no se acorta: la flexión es el camino fácil.

## 3 · La matriz, armada

#: Con esos cinco números se escribe entera. Las filas y columnas van `[u1, v1, θ1, u2, v2, θ2]`:

K = [258133, 0, 0, -258133, 0, 0; 0, 840.5, 2521.6, 0, -840.5, 2521.6; 0, 2521.6, 10086.5, 0, -2521.6, 5043.3; -258133, 0, 0, 258133, 0, 0; 0, -840.5, -2521.6, 0, 840.5, -2521.6; 0, 2521.6, 5043.3, 0, -2521.6, 10086.5]

#: Tres cosas que se ven de un vistazo y que **no son casualidad**:
#: · Es **simétrica**. Sale del teorema de Betti: la fuerza que aparece en `i` al mover `j` es la misma que en `j` al mover `i`.
#: · La primera fila y la cuarta son **opuestas**: el axil de un extremo es el del otro cambiado de signo. Es equilibrio.
#: · El bloque axial no se mezcla con el de flexión: **son independientes** en una barra recta.

## 4 · Por qué esos números y no otros: de dónde salen

#: No se aprenden de memoria. Salen de la misma integral de siempre:
#: K = ∫ B^{T}·E·B dx
#: Para el eje axial, `B = [−1/L, 1/L]`, así que
#: K_{axial} = ∫ (1/L²)·E·A dx = **E·A/L**
#: Y para la flexión, `B` es la **segunda derivada** de las funciones de Hermite. Al integrarlas salen los `12/L³`, `6/L²` y `4/L`. El `12` y el `4` no son inventados: son lo que da esa integral.

## 5 · La rigidez de un piso: lo que sí se siente

#: Un pórtico de dos columnas con la viga rígida arriba. Cada columna aporta `12·E·I/L³`:
K_piso = dec(2*12*15129.8/6^3, 1) [kN/m] 'rigidez lateral del pórtico
#: Y con una masa de 20 t, su periodo:
T = dec(2*3.14159265*(20/1681)^0.5, 4) [s] 'periodo del pórtico, T = 2π·√(m/K)

#: Cómo cambia el periodo si se cambia la altura de la columna (la rigidez va con `L³`):
#fplot(2*3.14159265*(20/(2*12*15129.8/x^3))^0.5, [3 9])
#: El eje horizontal es la altura en metros. **Una columna el doble de alta no da el doble de periodo: da casi el triple**, porque la rigidez cae con el cubo.

## 6 · La misma columna, en OpenSees

#: Y esto es lo que se escribe para que OpenSees monte **exactamente esa matriz**:

#: `model basic -ndm 2 -ndf 3` — dos dimensiones, tres grados por nudo
#: `node 1 0.0 0.0` y `node 2 0.0 6.0` — la columna, de 0 a 6 m
#: `fix 1 1 1 1` — empotrada abajo
#: `geomTransf Linear 1` — transformación de local a global
#: `element elasticBeamColumn 1 1 2 0.007744 200000000 0.00007565 1`

#: Los tres números de esa última línea son **`A`, `E` e `I`**: los mismos {A} m², {E} kN/m² y {I} m⁴ de arriba. OpenSees no recibe la matriz: recibe los datos y la **arma él**, con las mismas cuatro fórmulas.
#: Por eso los tres programas coinciden: **no es que se copien, es que integran lo mismo**.

## 7 · Y si la barra es gruesa: Timoshenko

#: Cuando la barra es corta y robusta, el cortante deja de ser despreciable y aparece un término más:
#: φ = 12·E·I / (G·A_{s}·L²)
#: y el `12·E·I/L³` se convierte en `12·E·I / (L³·(1+φ))`.
As = dec(2*0.008*0.25, 6) [m²] 'área de cortante del tubo: las dos paredes verticales
phi = dec(12*15129.8/(76923077*0.004*6^2), 6) [—] 'parámetro de cortante
k_timo = dec(12*15129.8/(6^3*(1 + 0.00164)), 1) [kN/m] 'rigidez de corte CON Timoshenko

#: Con esta columna, `φ` vale {phi}: el cortante le quita un 0.16 % de rigidez. **En una columna esbelta no importa; en una viga de gran canto y poca luz, sí.**
#: Es el mismo término que Wilson deduce en el capítulo 4 y que trae SAP IV en `beam.for`. Hekatan Struct lo lleva, y por eso pide el `as` de cada barra.
