# Funciones de forma, Jacobiano y cuadratura de Gauss — de 1D a 2D
#: Charla rápida: las tres piezas con las que un programa de elementos finitos arma la matriz de rigidez. Primero en la barra, donde todo se ve; después en el cuadrilátero, donde es lo mismo con una letra más.
#> Hekatan Struct · conferencia · Logan §3.2 y §6 · Zienkiewicz–Bathe (isoparamétrico)

## 1 · El camino completo, en una línea
#: **N → J → B → Gauss → K → u.** Las funciones de forma **N** reparten; el Jacobiano **J** cambia de coordenadas; la matriz **B** convierte desplazamientos en deformación; la **cuadratura de Gauss** hace la integral; sale la rigidez **K**; y resolviendo K·u = F salen los desplazamientos.
#: Todo lo que sigue es eso, dos veces: en 1D y en 2D.

## 2 · Funciones de forma en 1D: qué son
#: Conozco el desplazamiento en los dos nudos, {u_1} y {u_2}. Dentro del elemento se reparte con pesos que dependen de la posición:
u_e = N_1*u_1 + N_2*u_2 @@(interpolación)
#: El elemento se formula siempre en coordenada natural {xi}, de −1 a +1, mida lo que mida en la obra:
#bar1d

## 3 · No se memorizan: se deducen
#: Se impone que cada N valga **1 en su nudo y 0 en el otro**. Apilando esas dos condiciones sale un sistema, y el motor lo resuelve:
M = [1, -1; 1, 1] @@(base evaluada en los dos nudos)
c_1 = inv(M) * [1; 0] @@(coeficientes de N₁)
c_2 = inv(M) * [0; 1] @@(coeficientes de N₂)
N_1 = (1 - xi)/2 @@(nudo 1)
N_2 = (1 + xi)/2 @@(nudo 2)
#fplot(N_1 = (1-x)/2, N_2 = (1+x)/2, [-1 1])
#: Cada una vale 1 en su nudo y 0 en el otro, y **suman 1 en todo punto**: por eso el elemento se mueve rígido sin deformarse.

## 4 · El Jacobiano en 1D: el factor de escala
#: La geometría se interpola con las **mismas** funciones de forma —eso es «isoparamétrico»—. Con el nudo 1 en 0 y el nudo 2 en {L}:
x = N_2 * L @@(mapeo de la geometría)
Jac = Diff{x @ xi} @@(Jacobiano)
J = L/2 @@(de aquí en adelante, J)
J_inv = 2/L @@(su inversa)
#mapa1d
#: Dos usos, y son siempre los mismos: **|J| para medir** —dx = J·dξ, que es lo que permite integrar entre −1 y 1— y **J⁻¹ para derivar** —dN/dx = J⁻¹·dN/dξ—.

## 5 · La matriz B y la rigidez de la barra
dN_dxi = [-1/2, 1/2] @@(derivadas en la coordenada natural)
B = dN_dxi * J_inv @@(matriz deformación–desplazamiento)
#: {B} no depende de {xi}: la deformación es **constante** en el elemento.
BtB = Area{transpose(B)*B @ xi=-1:1} @@(∫BᵀB dξ)
K_barra = E*A*J*BtB @@(K = E·A·|J|·∫BᵀB dξ)
#: El famoso EA/L no es un dato de tabla: es esa integral.

## 6 · La cuadratura de Gauss: la idea
#: El computador no integra símbolos: suma y multiplica. Toda integral se cambia por **∫f dξ ≈ Σ wᵢ·f(ξᵢ)**: se mide la función en unos pocos puntos, cada medida pesa wᵢ, y se suma. Mueve las barras: **n** son los puntos y **p** el grado del polinomio.
#gauss
#: Con **n** puntos es exacta hasta el grado **2n − 1**. Con 2 puntos, hasta grado 3.

## 7 · De dónde sale el ±0.5774
#: Con 2 puntos hay 4 números libres: dos posiciones y dos pesos. Cuatro libertades = cuatro condiciones: exacta para 1, ξ, ξ² y ξ³. Los pesos salen 1 (suman el ancho, 2) y la simetría sale gratis; la única que manda es ξ²:
I_2 = Area{xi^2 @ xi=-1:1} @@(∫ξ² dξ)
a_gauss = dec(sqrt(1/3), 4) @@(2a² = 2/3 → a = 1/√3)
#gauss(porque)
#: Arrastra: el ✗ de ξ² se vuelve ✔ **solo** en 0.5774. No es un número de tabla, es un despeje.

## 8 · La tabla que usa el programa
#: En [−1, 1], siempre la misma, desde 1814:
puntos_1 = [0] @@(n=1: ξ)
pesos_1 = [2] @@(n=1: w)
puntos_2 = [-0.5774, 0.5774] @@(n=2: ξ)
pesos_2 = [1, 1] @@(n=2: w)
puntos_3 = [-0.7746, 0, 0.7746] @@(n=3: ξ)
pesos_3 = [0.5556, 0.8889, 0.5556] @@(n=3: w)
#: Para la barra lineal BᵀB es constante —grado 0—, así que **un solo punto ya da la K exacta**.

## 9 · Ahora 2D: el elemento maestro
#: El cuadrilátero de 4 nudos se formula sobre un **cuadrado** de lado 2, con dos coordenadas naturales: {xi} y {eta}, cada una de −1 a +1. Los cuatro nudos están en las esquinas: (−1,−1), (+1,−1), (+1,+1), (−1,+1).
#: Todo lo de 1D se repite; lo único nuevo es que ahora hay dos direcciones.

## 10 · Funciones de forma 2D = 1D × 1D
#: No hay nada que inventar: la función de forma de una esquina es el **producto** de la 1D en {xi} por la 1D en {eta}.
N_1 = Expand{(1-xi)*(1-eta)/4} @@(esquina (−1,−1))
N_2 = Expand{(1+xi)*(1-eta)/4} @@(esquina (+1,−1))
N_3 = Expand{(1+xi)*(1+eta)/4} @@(esquina (+1,+1))
N_4 = Expand{(1-xi)*(1+eta)/4} @@(esquina (−1,+1))
particion = Simplify{(1-xi)*(1-eta)/4 + (1+xi)*(1-eta)/4 + (1+xi)*(1+eta)/4 + (1-xi)*(1+eta)/4} @@(suman 1)
#: La forma general se escribe de una vez: N_i = ¼(1 + ξ·ξᵢ)(1 + η·ηᵢ), con (ξᵢ, ηᵢ) la esquina del nudo i.

## 11 · Cada función de forma es una carpa
#: Vale 1 en su esquina y baja a 0 en las otras tres. Arrastra con el ratón para girarla:
#surf((1-x)*(1-y)/4, [-1 1], [-1 1])
#: Esa carpa es N₁. Las otras tres son la misma carpa girada a cada esquina, y las cuatro **suman el plano a la altura 1**.

## 12 · El Jacobiano en 2D ya no es un número: es una matriz
#: La geometría se interpola igual: x = Σ Nᵢ·xᵢ, y = Σ Nᵢ·yᵢ. Para un rectángulo de lados 2a y 2b centrado en el origen queda x = a·ξ, y = b·η, y el Jacobiano recoge las cuatro derivadas cruzadas:
J_2d = [a, 0; 0, b] @@(J = [∂x/∂ξ, ∂y/∂ξ; ∂x/∂η, ∂y/∂η])
detJ = det(J_2d) @@(|J| = a·b: el factor de ÁREA)
J_inv2 = inv(J_2d) @@(J⁻¹: el que transporta las derivadas)
#: Mismo papel que en 1D: **|J| para medir** —dx·dy = |J|·dξ·dη— y **J⁻¹ para derivar**. Si el elemento sale muy distorsionado, |J| se acerca a cero, J⁻¹ se dispara, y ahí están los avisos de malla de ETABS o SAP2000.

## 13 · La matriz B en 2D
#: Con las derivadas ya pasadas a x e y, la B del Q4 es una matriz **3×8**: tres deformaciones (εx, εy, γxy) contra ocho grados de libertad (dos por nudo).
B_fila = [-1/(4*a), 0, 1/(4*a), 0, 1/(4*a), 0, -1/(4*a), 0] @@(∂N/∂x en η = 0, fila de εx)
#: Y la matriz del material, para tensión plana:
D = E/(1-nu^2)*[1, nu, 0; nu, 1, 0; 0, 0, (1-nu)/2] @@(tensión plana)

## 14 · Gauss en 2D: dos veces la misma tabla
#: La integral es doble, así que la cuadratura se aplica **dos veces, una por dirección**: ∬ f dξ dη ≈ ΣΣ wᵢ·wⱼ·f(ξᵢ, ηⱼ).
#: Con 2 puntos por dirección salen **2 × 2 = 4 puntos de Gauss**, en las cuatro combinaciones de ∓0.5774, y el peso de cada uno es el producto de los pesos: 1 × 1 = 1.
g_2d = [-0.5774, -0.5774; 0.5774, -0.5774; 0.5774, 0.5774; -0.5774, 0.5774] @@(los 4 puntos (ξ, η))
w_2d = [1, 1, 1, 1] @@(sus pesos)
#: Esos son los cuatro puntos que ETABS o Abaqus enseñan dentro de cada elemento, y donde calculan las tensiones antes de extrapolarlas a los nudos.

## 15 · La rigidez del Q4, con Gauss
#: La fórmula es la misma de la barra, con la D en medio y el |J| del área:
#: **K = ∬ Bᵀ·D·B·|J| dξ dη ≈ Σ wᵢ wⱼ · Bᵀ D B |J|**, evaluada en los 4 puntos.
#: El integrando del Q4 llega a grado 2 en cada dirección, y la regla 2n−1 dice que con n=2 se acierta hasta grado 3: por eso **2×2 es exacta** para el elemento bien formado. Usar menos puntos —integración reducida— abarata pero deja modos de energía nula, el *hourglassing*.

## 16 · Lo que hay que llevarse
#: **1.** Las funciones de forma reparten los valores de los nudos. En 2D son el **producto** de las de 1D.
#: **2.** El Jacobiano cambia de coordenadas: **|J| para integrar, J⁻¹ para derivar**. En 1D es un número; en 2D, una matriz 2×2.
#: **3.** La cuadratura de Gauss convierte la integral en una suma de pocas medidas, colocadas donde más rinden: **n puntos, exacta hasta 2n−1**.
#: **4.** Con eso se arma K, se ensambla, se resuelve **K·u = F**, y se vuelve por el mismo camino a deformaciones, tensiones y fuerzas.
#: Cambia el elemento —barra, cuadrilátero, cáscara, sólido— y cambian las N y el tamaño de B y D. **El procedimiento no cambia nunca.**
#> Hekatan Struct · todo lo de esta hoja lo calculó el motor al abrirla.
