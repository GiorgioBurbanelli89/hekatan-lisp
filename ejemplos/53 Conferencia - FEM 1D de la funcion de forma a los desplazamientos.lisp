# Elementos finitos, de verdad: qué hace el programa por dentro
#: Una barra, cinco ideas: **función de forma**, **Jacobiano**, **matriz B**, **matriz de rigidez K** y **desplazamientos**. Todo se deduce aquí mismo con el motor: primero el álgebra, los números al final.
#> Hekatan Engineers · conferencia · Logan §3.2 · Zienkiewicz–Bathe (formulación isoparamétrica)

## 1 · El problema de siempre
#: Una barra de acero, empotrada arriba y cargada abajo: módulo {E}, área {A}, largo {L}, carga {P}. La pregunta de todo cálculo estructural: **¿cuánto se mueve y cuánto se esfuerza?**
#: La solución clásica de resistencia de materiales es una sola fórmula:
d_exacta = P*L/(E*A) @@(alargamiento clásico)
#: Sencillo. Pero en cuanto la barra cambia de sección, de material, o se vuelve un pórtico o una losa, esa fórmula se acaba. El elemento finito es la máquina que resuelve **todos** esos casos con el mismo procedimiento. Veamos ese procedimiento, paso por paso.

## 2 · La idea del método en una frase
#: **Divide el cuerpo en trozos y dentro de cada trozo supón una forma sencilla.**
#: En vez de buscar la función exacta u(x) en todo el dominio —difícil—, se parte el dominio en **elementos**, y dentro de cada elemento se dice: «el desplazamiento vale lo de mis nudos, repartido con unos pesos». Esos pesos son las **funciones de forma**.
#: Así el problema pasa de «hallar una función» a «hallar unos pocos números»: los desplazamientos de los nudos. Y hallar números es justo lo que sabe hacer un computador.

## 3 · El elemento: dos nudos y un mapa
#: El elemento barra tiene dos nudos. Para que el programa trate igual a todos los elementos —midan 10 cm o 500 cm— cada uno se formula sobre un **elemento de referencia** en coordenada natural {xi}, que siempre va de −1 a +1:
#bar1d
#: Arriba, el elemento de referencia, siempre el mismo. Abajo, la barra real, de 0 a {L}. La flecha es el **mapa** que estira uno sobre el otro. El factor de ese estiramiento es el Jacobiano, y va a aparecer solo dentro de un momento.

## 4 · Funciones de forma: la pregunta que responden
#: Conozco el desplazamiento en los dos extremos, {u_1} y {u_2}. ¿Cuánto vale **en el medio**?
#: La respuesta del método: se reparte. Cada nudo aporta con un **peso** que depende de dónde estoy:
u_xi = N_1*u_1 + N_2*u_2 @@(interpolación)
#: N₁ es el peso del nudo 1 y N₂ el del nudo 2. Eso es todo lo que es una función de forma: **un peso que varía con la posición**.

## 5 · Deducción, no memoria (1): la recta
#: Dos nudos = dos datos = la función más simple que los une es una recta. Escrita como base por coeficientes:
N_i = [1, xi] * [a; b]
#: La base [1, {xi}] es lo que depende de la posición; [{a}; {b}] son los dos números que busco: la altura en el centro y la pendiente.
#recta

## 6 · Deducción, no memoria (2): la condición de Kronecker
#: La condición que define la función de forma: **vale 1 en su nudo y 0 en el otro**. Evaluar en un nudo es meter su {xi} en la base.
e_1 = [1, -1] * [a; b] @@(en el nudo 1, ξ=−1)
e_2 = [1, 1] * [a; b] @@(en el nudo 2, ξ=+1)
#: Para N₁ pido {e_1} = 1 y {e_2} = 0. Apilando las dos filas sale el sistema:
M = [1, -1; 1, 1] @@(matriz del sistema)
c_1 = inv(M) * [1; 0] @@(coeficientes de N₁)
c_2 = inv(M) * [0; 1] @@(coeficientes de N₂)
#: El motor resolvió el sistema: {c_1} y {c_2}. Reconstruyendo la recta con esos coeficientes quedan las dos funciones de forma en forma cerrada:
N_1 = (1 - xi)/2 @@(función de forma del nudo 1)
N_2 = (1 + xi)/2 @@(función de forma del nudo 2)

## 7 · Las dos rectas, dibujadas
#fplot(N_1 = (1-x)/2, N_2 = (1+x)/2, [-1 1])
#: N₁ (azul) baja de 1 a 0; N₂ (naranja) sube de 0 a 1. Se cruzan en el centro, donde ambas valen ½: en la mitad del elemento cada nudo manda la mitad.

## 8 · Las tres propiedades que nunca fallan
#: **(a) Delta de Kronecker.** Cada N vale 1 en su nudo y 0 en el otro:
kro_1 = Expand{(1-(-1))/2} @@(N₁ en ξ=−1)
kro_2 = Expand{(1-1)/2} @@(N₁ en ξ=+1)
#: Por eso cada nudo controla su propio valor y no ensucia al vecino.
#: **(b) Partición de la unidad.** Suman 1 en todo punto:
particion = Simplify{(1-xi)/2 + (1+xi)/2} @@(suman 1)
#: **(c) Movimiento de cuerpo rígido.** Si los dos nudos se mueven lo mismo, el elemento se traslada **sin deformarse**:
rigido = Expand{(1-xi)/2*5 + (1+xi)/2*5} @@(u₁=u₂=5 → u=5)
#: Da 5, constante, sin {xi}. Sin esta propiedad el elemento no pasa el patch test, y el programa inventaría fuerzas al mover la estructura entera.

## 9 · La interpolación en movimiento
#: El nudo 1 se queda quieto y el nudo 2 se mueve. Mira cómo la recta interior sigue a los nudos: eso es la función de forma trabajando. Mueve tú la barra: el nudo 2 baja y sube cuando tú quieras.
#slider fplot(u = (1+x)/2*n/8, u_maximo = (1+x)/2, [-1 1]), n = 0:8
#: Cada posición de la barra es un {u_2} distinto; la forma es **siempre** la misma recta, escalada. La forma la ponen las N; el tamaño lo ponen los nudos.

## 10 · El mapa isoparamétrico: de ξ a x
#: «Isoparamétrico» significa: **la geometría se interpola con las mismas funciones de forma que el desplazamiento**. Con el nudo 1 en 0 y el nudo 2 en {L}:
x = N_2 * L @@(mapeo de la geometría)
#: En {xi} = −1 da 0; en {xi} = +1 da {L}; en el centro, la mitad. Es una recta:
#mapa1d

## 11 · El Jacobiano: la pendiente de ese mapa
#: El **Jacobiano** es la derivada de la coordenada real respecto de la natural: cuántos centímetros reales avanzo por cada paso de {xi}.
Jac = Diff{x @ xi} @@(Jacobiano)
#: Sale {Jac}, que de aquí en adelante llamo J. Y tiene sentido de metro de sastre: el elemento de referencia mide 2 (de −1 a +1) y el real mide {L}; la razón es {L}/2. **El Jacobiano es el factor de escala del elemento.**
#: Su inversa es la que transporta las derivadas en sentido contrario:
J = L/2 @@(Jacobiano del elemento)
J_inv = 2/L @@(Jacobiano inverso)

## 12 · Para qué sirve el Jacobiano (dos usos, siempre los mismos)
#: **Uso 1 — medir.** Un pedacito de la barra real vale el pedacito natural por el Jacobiano:
dx = J*dxi @@(cambio de variable)
#: Por eso toda integral sobre el elemento real se puede hacer sobre [−1, 1], que es donde vive la cuadratura de Gauss. Esa es la razón de que el programa integre siempre sobre el segmento —o el cuadrado— de referencia.
#: **Uso 2 — derivar.** Las N están escritas en {xi}, pero la deformación se mide en x. La regla de la cadena obliga a dividir por el Jacobiano:
dN_dx = dN_dxi * J_inv @@(regla de la cadena)
#: En 2D y 3D el Jacobiano deja de ser un número y pasa a ser una matriz, pero el papel es idéntico: **|J| para medir, J⁻¹ para derivar**. Si un elemento sale muy distorsionado, |J| se acerca a cero, J⁻¹ se dispara, y ahí nacen los avisos de malla de ETABS o SAP2000.

## 13 · La matriz B: de desplazamientos a deformación
#: La deformación axial es la derivada del desplazamiento, ε = du/dx. Derivando la interpolación del paso 4 y aplicando la regla de la cadena:
dN_dxi = [-1/2, 1/2] @@(derivadas en la coordenada natural)
B = dN_dxi * J_inv @@(matriz deformación–desplazamiento)
#: Esa fila es la **matriz B**. Con ella la deformación sale de los desplazamientos de los nudos con una multiplicación, sin derivar nada más: ε = B · [{u_1}; {u_2}].
#: Y mira lo que dice {B}: la deformación es (u₂ − u₁)/{L}, o sea **alargamiento dividido para el largo**. La definición de toda la vida, deducida sola.
#: Un detalle grande: {B} **no depende de {xi}**. La deformación es **constante** dentro del elemento. Por eso la barra lineal da tensión constante por elemento, y por eso en 2D al triángulo lineal se le llama CST, constant strain triangle.

## 14 · Integrar sin integrar: la cuadratura
#: Para armar K hace falta una **integral**. Pero un computador no sabe integrar símbolos: sabe **sumar y multiplicar**. Así que toda integral se cambia por una suma:
#: **∫ f(ξ) dξ ≈ w₁·f(ξ₁) + w₂·f(ξ₂) + … + wₙ·f(ξₙ)** — evalúo la función en unos pocos puntos ξᵢ, multiplico cada valor por un peso wᵢ, y sumo. Eso es una **cuadratura**.
#: Léelo como un área: cada término wᵢ·f(ξᵢ) es un **rectángulo** de ancho wᵢ y altura f(ξᵢ). La suma de esos rectángulos es el área. Mueve las barras: **n** son los puntos, **p** es el grado del polinomio que estoy integrando.
#gauss
#: Prueba esto: deja n = 2 y sube el grado. Hasta **p = 3** el error es CERO —exacto, no aproximado—; en p = 4 se despega. Sube a n = 3 y aguanta hasta p = 5. Esa es la regla: **con n puntos es exacto hasta el grado 2n − 1.**

## 15 · ¿De dónde sale el 0.5774? (aquí está la clave)
#: Trapecio y Simpson evalúan en puntos **fijos** —los extremos, el centro—. Gauss pregunta otra cosa: si puedo elegir **dónde** evaluar, ¿dónde conviene? Con 2 puntos tengo **4 números libres**: ξ₁, ξ₂, w₁, w₂. Con 4 libertades puedo exigir 4 condiciones: que la fórmula dé **exacta** la integral de 1, de ξ, de ξ² y de ξ³.
#: Por simetría los puntos salen en −a y +a con el mismo peso. El motor calcula las integrales exactas que hay que igualar:
I_0 = Area{1 @ xi=-1:1} @@(∫1 dξ)
I_1 = Area{xi @ xi=-1:1} @@(∫ξ dξ)
I_2 = Area{xi^2 @ xi=-1:1} @@(∫ξ² dξ)
#: Con pesos 1 y 1: para f = 1 la suma da 1+1 = 2 = {I_0} ✔ (por eso los pesos valen 1). Para f = ξ da −a+a = 0 = {I_1} ✔ (por simetría, gratis). La única que manda es **f = ξ²**: la suma vale a² + a² = 2a², y tiene que dar {I_2}. De ahí sale el punto:
a_gauss = dec(sqrt(1/3), 6) @@(2a² = 2/3 → a = 1/√3)
#: Ese 0.577 no es un número mágico ni sacado de una tabla: es el **despeje de una ecuación**. Y los pesos valen 1 porque tenían que sumar 2, que es lo que mide el intervalo.

## 16 · Míralo tú: mueve el punto
#: Los dos puntos están en −a y +a con peso 1. Arrastra y mira las cuatro condiciones: las de 1, ξ y ξ³ salen **siempre** bien —por los pesos y por la simetría—; la de **ξ²** solo cuadra en un sitio.
#gauss(porque)
#: Ahí, y solo ahí, el error se hace cero: a = 1/√3 = 0.5774. Con dos evaluaciones estás integrando exacto hasta grado 3.

## 17 · Gauss contra el trapecio, con el mismo trabajo
#: Dos evaluaciones de la función, dos métodos. Integremos f(ξ) = ((1+ξ)/2)³ entre −1 y 1. La respuesta exacta, por el motor:
exacta = Area{((1+xi)/2)^3 @ xi=-1:1} @@(valor exacto)
#: **Trapecio** (evalúa en los extremos, ξ = −1 y ξ = +1, con peso 1 cada uno):
trapecio = dec(((1-1)/2)^3 + ((1+1)/2)^3, 4) @@(f(−1) + f(+1))
#: **Gauss** (evalúa en ξ = ∓0.5774, peso 1 cada uno):
gauss_2 = dec(((1-0.5773503)/2)^3 + ((1+0.5773503)/2)^3, 4) @@(f(−a) + f(+a))
#: Trapecio da 1.0 con un error del 100 %; Gauss da **exactamente** 0.5. **El mismo número de cuentas, y uno acierta al dígito.** Esa es toda la razón de que ETABS, SAP2000, SAFE y Abaqus integren con Gauss y no con trapecios.
#: Los puntos y pesos para el segmento [−1, 1] son siempre los mismos —están en una tabla desde 1814—, y por eso **todo elemento se formula en coordenada natural**: para que esa tabla valga siempre, mida lo que mida el elemento real. El Jacobiano se encarga del resto.

## 18 · Gauss dentro de la matriz de rigidez
#: Ahora se junta todo. La K del elemento es K = ∫ Bᵀ·D·B·|J| dξ, así que el programa hace exactamente esto: por cada **punto de Gauss** ξᵢ, evalúa B(ξᵢ), multiplica Bᵀ·D·B, lo multiplica por |J| y por el peso wᵢ, y lo va **acumulando**:
K_gauss = w_1*Bt_D_B_1*J + w_2*Bt_D_B_2*J @@(K = Σ wᵢ·Bᵀ D B·|J|)
#: Cuántos puntos hacen falta se decide con la regla 2n − 1. En la barra lineal BᵀB es **constante** (grado 0), así que **con 1 punto ya es exacta**. En el cuadrilátero Q4 el integrando llega a grado 2 y se usan **2×2 = 4 puntos**; en el Q8, 3×3 = 9.
#: Por eso los programas hablan de «integración completa» o «reducida»: usar menos puntos de los que pide la regla abarata el cálculo, pero puede dejar modos de deformación con energía cero —el *hourglassing*, esa malla que se ve como un reloj de arena—.
#: Y por eso, cuando pides tensiones, ETABS o Abaqus las calculan **en los puntos de Gauss** y después las extrapolan a los nudos: ahí es donde el elemento de verdad hizo las cuentas.

## 19 · La matriz de rigidez: de dónde sale la integral
#: La energía de deformación de la barra es ½∫σ·ε·{A}·dx. Metiendo ε = B·u y σ = {E}·ε, todo lo que no son los desplazamientos queda dentro de una integral: **esa integral es K**.
#: K = ∫ Bᵀ·{E}·{A}·B dx sobre la barra real. Cambio a la coordenada natural con el Jacobiano —uso 1 del paso 12—: K = ∫ Bᵀ·{E}·{A}·B·|J| dξ, con {xi} de −1 a +1. El motor hace la integral:
BtB = Area{transpose(B)*B @ xi=-1:1} @@(∫BᵀB dξ)
K_elem = E*A*J*BtB @@(K = E·A·|J|·∫BᵀB dξ)
#: Y ahí está, **deducida**, no copiada: la rigidez del elemento barra es (E·A/{L})·[1, −1; −1, 1]. El famoso EA/L no es un dato de tabla: es la integral de la matriz B contra sí misma.
#: Fíjate en la simetría y en que las filas suman cero. Eso último es el cuerpo rígido del paso 8 otra vez: si mueves los dos nudos lo mismo, no aparece ninguna fuerza. Una K que **no** cumpla eso está mal ensamblada.

## 20 · Ahora sí, los números
#: Barra de acero, unidades de obra: {E} en tonf/cm², {A} en cm², {L} en cm, {P} en tonf.
E_v = 2100 @@(módulo de elasticidad)
A_v = 20 @@(área de la sección)
L_v = 300 @@(largo)
P_v = 10 @@(carga axial)
#: Rigidez del elemento y Jacobiano de esta barra:
J_v = dec(L_v/2, 1) @@(Jacobiano, cm por unidad de ξ)
k_ax = dec(E_v*A_v/L_v, 1) @@(E·A/L, tonf/cm)
K_num = k_ax*[1, -1; -1, 1] @@(K del elemento, tonf/cm)
#: Leer esa matriz es fácil: para mover el nudo 2 un centímetro, con el nudo 1 quieto, hacen falta 140 toneladas. La diagonal dice «cuánto cuesta moverme»; los términos cruzados, «cuánto arrastro al vecino».

## 21 · Ensamblaje: la estructura es la suma de sus elementos
#: Parto la barra en **dos** elementos de 150 cm. Cada uno es el doble de rígido:
k_ax2 = dec(E_v*A_v/150, 1) @@(E·A/150, tonf/cm)
K_1 = k_ax2*[1, -1; -1, 1] @@(elemento 1: nudos 1–2)
K_2 = k_ax2*[1, -1; -1, 1] @@(elemento 2: nudos 2–3)
#: El nudo 2 lo comparten los dos elementos, así que ahí las rigideces se **suman**. Ensamblada, la estructura completa de 3 nudos:
K_g = [280, -280, 0; -280, 560, -280; 0, -280, 280] @@(K global, 3 nudos)
#: Eso es literalmente todo el ensamblaje: llevar cada número de cada K de elemento a la fila y a la columna del nudo que le toca, y sumar donde coincidan. Un pórtico de 20 pisos es esta misma operación, repetida miles de veces.

## 22 · Condiciones de borde y solución
#: El nudo 1 está empotrado, {u_1} = 0. Se tacha su fila y su columna —el programa dice «restringir el grado de libertad»— y queda un sistema de 2×2 con los nudos libres:
K_ff = [560, -280; -280, 280] @@(K de los grados libres)
F_f = [0; 10] @@(cargas: 0 en el nudo 2, P en el 3)
u_f = dec(inv(K_ff) * F_f, 4) @@(desplazamientos: u = K⁻¹·F)
#: Los desplazamientos son {u_f} cm: 0.0357 cm en la mitad y **0.0714 cm en la punta**. Y la fórmula clásica del paso 1 daba:
d_num = dec(P_v*L_v/(E_v*A_v), 4) @@(P·L/(E·A))
#: El mismo número. El método reprodujo la solución exacta.
#: Ese K⁻¹·F es la línea que se lleva el grueso del tiempo de cálculo en ETABS, SAP2000 o Abaqus. Todo lo anterior —las N, el Jacobiano, la B— existe solo para poder escribir esa K.

## 23 · Y con los desplazamientos, todo lo demás
#: Con los desplazamientos en la mano se vuelve hacia atrás por el mismo camino. En el elemento 2, que va del nudo 2 al 3:
u_e2 = [0.0357; 0.0714] @@(desplazamientos del elemento, cm)
B_num = dec([-1/150, 1/150], 6) @@(B del elemento, 1/cm)
eps = dec(B_num*u_e2, 6) @@(deformación ε = B·u)
sigma_e = dec(E_v*eps, 4) @@(tensión σ = E·ε, tonf/cm²)
N_axial = dec(sigma_e*A_v, 2) @@(fuerza axial N = σ·A, tonf)
#: Da {N_axial} tonf: las 10 tonf aplicadas. El equilibrio se cumple, el resultado se verifica solo. **Desplazamientos → deformaciones → tensiones → fuerzas**: ese es el orden en que sale todo informe de cualquier programa de elementos finitos.

## 24 · ¿Y si la solución no es una recta?
#: Con carga en la punta el elemento lineal acierta exacto, porque la solución **es** una recta. Con carga repartida —el peso propio— la solución exacta es una parábola, y una recta no puede serlo. Ahí es donde hay que mallar. Barra normalizada, exacta contra elementos finitos. Mueve la barra y refina la malla tú mismo, de 1 a 8 elementos:
#slider fplot(u = x - x^2/2, u_EF = floor(n*x)/n - (floor(n*x)/n)^2/2 + (1 - floor(n*x)/n - 1/(2*n))*(x - floor(n*x)/n), [0 0.999]), n = 1:8
#: En los nudos coincide **siempre**; entre nudos hay error. El error máximo dentro de cada tramo vale:
e_u = h^2/8 @@(error entre nudos)
#: Si duplicas el número de elementos, {h} baja a la mitad y el error baja a la **cuarta** parte. Eso es converger, y es la razón técnica —no la costumbre— de refinar una malla.

## 25 · La tensión: por qué los programas la promedian
#: El desplazamiento sale continuo, pero la tensión no: cada elemento da su constante, así que en un nudo interior hay **dos** valores distintos.
#slider fplot(sigma = 1 - x, sigma_EF = 1 - floor(n*x)/n - 1/(2*n), [0 0.999]), n = 1:8
#: Ese salto es el equilibrio que el método solo cumple en los nudos. Por eso SAP2000, ETABS y SAFE dejan elegir «Unaveraged» —con salto— o «Averaged» —promediado—. Y el promedio de los dos vecinos devuelve justo el valor exacto del nudo: promediar no es maquillaje, es recuperar información.

## 26 · El camino completo, en una diapositiva
#: **1. Funciones de forma** — reparten los valores de los nudos hacia adentro del elemento. Se deducen imponiendo que valgan 1 en su nudo y 0 en los demás.
#: **2. Jacobiano** — el factor de escala entre el elemento de referencia y el real. |J| para medir (integrar), J⁻¹ para derivar.
#: **3. Matriz B** — las derivadas de las funciones de forma pasadas por J⁻¹. Convierte desplazamientos de nudos en deformación.
#: **4. Matriz de rigidez K** — la integral ∫BᵀDB|J|dξ. Para la barra da EA/L; para una losa da una matriz llena, pero es la misma fórmula.
#: **5. Desplazamientos** — ensamblar, restringir, resolver K·u = F, y volver por el camino a deformaciones, tensiones y fuerzas.
#: Cambia el elemento —barra, viga, cáscara, sólido— y cambian las N, y cambia el tamaño de B y de D. **El procedimiento no cambia nunca.** Entendida la barra, está entendido el programa.
#> Hekatan Engineers · hoja ejecutable: todo lo anterior lo calculó el motor al abrir esta hoja.
