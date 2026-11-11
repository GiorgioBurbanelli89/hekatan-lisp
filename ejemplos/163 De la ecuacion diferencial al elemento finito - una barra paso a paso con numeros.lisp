# De la ecuación diferencial al elemento finito: una barra, primero en símbolos y luego con números
#: Una barra empotrada a la izquierda, con carga repartida q y una fuerza P en la punta. Se resuelve **tres veces**: a mano con la ecuación diferencial, comprobando la forma débil, y con elementos finitos. Las tres tienen que dar lo mismo.

## 1 · La ecuación diferencial, en símbolos (forma fuerte)
#: Se corta una rebanada de ancho dx. **Equilibrio:** a la izquierda actúa la fuerza axial N, a la derecha N + dN, y dentro la carga q·dx, así que dN + q·dx = 0, o sea **N′ = −q**.
#: **Cinemática:** la deformación es la derivada del desplazamiento, ε = u′. **Constitutiva (Hooke):** N = EA·ε = EA·u′.
#: Se sustituye y queda **una sola ecuación con una incógnita**, la forma fuerte: **EA·u″ = −q**. Hay que integrarla dos veces, y cada integral trae una constante.
#: Condiciones de borde: **esencial** u(0) = 0 (el apoyo) y **natural** EA·u′(L) = P (la fuerza en la punta).


## 2 · Resolverla a mano, en símbolos: integrar dos veces
#: Primera integral: EA·u′ = −q·x + C₁. Segunda: EA·u = −q·x²/2 + C₁·x + C₂.
#: La natural en x = L da −q·L + C₁ = P, o sea **C₁ = P + q·L**. La esencial en x = 0 da **C₂ = 0**.
u(x) = (-q*x^2/2 + (P + q*L)*x)/EA @@(desplazamiento exacto)
N(x) = -q*x + P + q*L @@(fuerza axial N = EA·u′)
u_L = Simplify{u(L)} @@(desplazamiento de la punta)
N_0 = Simplify{N(0)} @@(fuerza axial en el apoyo)
N_L = Simplify{N(L)} @@(fuerza axial en la punta)

## 3 · La forma débil, en símbolos
#: Se multiplica la ecuación por una función v(x) con v(0) = 0 y se integra por partes. Queda: **∫EA·u′·v′ dx = ∫q·v dx + P·v(L)**, trabajo interno = trabajo externo. Se comprueba con la solución exacta, con dos funciones v distintas.
#: **Con v = x** (v′ = 1):
Ti1 = Simplify{Integral{P + q*L - q*x @ x = 0 : L}}
Te1 = Simplify{Integral{q*x @ x = 0 : L} + P*L}
dif_1 = Simplify{Ti1 - Te1} @@(debe ser 0)
#: **Con v = x²** (v′ = 2x):
Ti2 = Simplify{Integral{(P + q*L - q*x)*2*x @ x = 0 : L}}
Te2 = Simplify{Integral{q*x^2 @ x = 0 : L} + P*L^2}
dif_2 = Simplify{Ti2 - Te2} @@(debe ser 0)
#: Con la solución exacta la igualdad vale **para cualquier v**: la débil no es otra física. Ahora una aproximación **pobre**, la recta u = a·x, con la a que cumple la igualdad solo para v = x:
a_G = (q*L/2 + P)/EA @@(a de Galerkin)
d_G1 = Simplify{Integral{EA*a_G @ x = 0 : L} - (Integral{q*x @ x = 0 : L} + P*L)} @@(con v = x se cumple)
#: Con v = x² ya **no** se cumple: la recta no es la solución, solo es la mejor de su familia.
d_G2 = Simplify{Integral{EA*a_G*2*x @ x = 0 : L} - (Integral{q*x^2 @ x = 0 : L} + P*L^2)}
#: Por eso Galerkin exige la igualdad solo para las v de la **misma familia** que la aproximación. Con más funciones (más elementos), la familia crece y la aproximación mejora.

## 4 · Elementos finitos, en símbolos: dos elementos
#: Se parte la barra en 2 tramos de largo h = L/2, con 3 nudos (0, 1, 2). En cada tramo la aproximación es una **recta** que une los valores de sus dos nudos, con N₁ = 1 − x/h y N₂ = x/h.
h = L/2 @@(largo de cada elemento)
#: **Matriz de rigidez del elemento.** u′ = B·uₑ, con B = [−1/h, 1/h]. La rigidez es **kₑ = ∫EA·Bᵀ·B dx**; como B no depende de x, el integrando es constante y la integral es h por él:
B_e = [-1/h, 1/h]
k = EA/h @@(rigidez del resorte equivalente)
k_e = [k, -k; -k, k] @@(k_e = EA·h·BᵀB = (EA/h)·[1, −1; −1, 1])
#: Es la matriz del resorte, con k = EA/h. Las **cargas del elemento** salen de ∫q·N dx: la carga repartida se divide por mitad a los dos nudos.
f = q*h/2 @@(f_e = ∫q·N dx = [q·h/2; q·h/2])
f_e = [f; f]
#: **Ensamblaje.** El nudo 1 pertenece a los dos elementos, así que en su casilla se suman las dos rigideces y las dos cargas. La fuerza P va al nudo 2.
K = [k, -k, 0; -k, 2*k, -k; 0, -k, k]
F = [f; 2*f; f + P]
#: **Apoyo (condición esencial).** u₀ = 0: se quita la fila y la columna 0.
K_r = [2*k, -k; -k, k]
F_r = [2*f; f + P]
#: **Resolver K·u = F**, todavía con letras. El determinante de K_r es k², y la inversa es (1/k²)·[k, k; k, 2k]:
u_r = Simplify{inv(K_r)*F_r}
u_1 = Simplify{(3*f + P)/k} @@(desplazamiento del nudo 1)
u_2 = Simplify{(4*f + 2*P)/k} @@(desplazamiento del nudo 2, la punta)
#: **Comparación en símbolos.** En los nudos el elemento finito da exactamente la solución de la ecuación diferencial (propiedad de esta barra de rigidez constante):
e_n1 = Simplify{u_1 - u(h)} @@(debe ser 0)
e_n2 = Simplify{u_2 - u(L)} @@(debe ser 0)
#: Dentro del elemento la aproximación es una recta y la exacta una parábola. A mitad del primer tramo:
e_m = Simplify{u_1/2 - u(h/2)} @@(error a media barra, ≠ 0)
#: **Reacción en el apoyo:** fila 0 de K·u = F, con u₀ = 0, da −k·u₁ = f + R:
R_0 = Simplify{-k*u_1 - f} @@(debe ser −(q·L + P))

## 5 · Reemplazo de valores
#: Recién ahora los números. Mismas fórmulas, con los datos del problema:
L = 4 'largo de la barra
EA = 10000 'rigidez axial (módulo por área)
q = 5 'carga repartida a lo largo de la barra
P = 10 'fuerza en la punta (x = L)
#: **Solución exacta** con los números (la ecuación diferencial):
Ca = P + q*L 'C₁ de la condición natural
u_Ln = u(L)
u_midn = u(L/2)
N_0n = N(0)
N_Ln = N(L)
#: **Forma débil** con v = x y v = x², con números:
Ti1n = Integral{Ca - q*x @ x = 0 : L}
Te1n = Integral{q*x @ x = 0 : L} + P*L
dif_1n = Ti1n - Te1n 'debe ser 0
#: **Elementos finitos** con números:
hn = L/2
u_1n = u_1
u_2n = u_2
e_n1n = u_1 - u(h)
e_n2n = u_2 - u(L)
e_mn = u_1/2 - u(h/2)
e_m1n = u(L)/2 - u(L/2) 'con un solo elemento el error a media barra es mayor
R_0n = -k*u_1 - f 'reacción
R_espn = -(q*L + P) 'valor esperado

## 6 · Lectura
#: **Fuerte → débil → elemento.** La ecuación diferencial se resolvió con constantes ajustadas por las condiciones de borde. La forma débil dio la misma respuesta como igualdad de trabajos para cualquier v. El elemento finito la usa con v de la familia de las funciones de forma, y todo se reduce a **K·u = F**, con K armada sumando resortes.
#: **Para la membrana Q4** el esqueleto es idéntico: kₑ = ∫EA·Bᵀ·B dx pasa a ser **K = ∫Bᵀ·D·B·t dA**, con Gauss y el Jacobiano. Lo demás (ensamblar, apoyar, resolver) es lo que hiciste aquí.
