# Funciones de forma 1D — qué son y de dónde salen
#: Explicado desde cero y **deducido por el motor** (no te las doy hechas: se calculan). Las ecuaciones llevan su número a la derecha, como en el libro.
#> Fuente: D. Logan, *A First Course in the Finite Element Method*, 6ª ed., §3.2 (elemento barra).

## 1 · La pregunta que responden
#: Tienes una barra con dos extremos: el **nudo 1** (en x=0) y el **nudo 2** (en x=L). Conoces el desplazamiento en cada extremo: {u_1} y {u_2}. La pregunta: ¿cuánto vale el desplazamiento **en el medio**, u(x)?
#: La **función de forma** N_i es el **peso** con que el nudo i aporta a cada punto. Interpolar = repartir el valor de los nudos a lo largo del elemento.

## 2 · La deducción de Logan, paso a paso
#: Se supone que el desplazamiento varía **lineal** dentro de la barra:
u(x) = a_1 + a_2·x @@(Logan 3.2.1)
#: Lo evalúo en los dos nudos y despejo las constantes a_1, a_2:
u(0) = u_1 = a_1 @@(Logan 3.2.3)
u(L) = u_2 = a_2·L + a_1 @@(Logan 3.2.4)
a_2 = (u_2 - u_1)/L @@(Logan 3.2.5)
#: Sustituyo a_1, a_2 en u(x) y **reagrupo por u_1 y u_2**. El motor hace el álgebra:
u = Expand{(1 - x/L)·u_1 + (x/L)·u_2} @@(Logan 3.2.6)
#: Los pesos que multiplican a cada nudo **son** las funciones de forma:
N_1(x) = 1 - x/L @@(Logan 3.2.9)
N_2(x) = x/L @@(Logan 3.2.9)

## 3 · Las 3 propiedades que SIEMPRE cumplen (las verifica el motor)
#: **(a) Valen 1 en su nudo y 0 en el otro** (delta de Kronecker):
en_nudo1 = N_1(0) @@(N_1 en el nudo 1)
en_nudo2 = N_1(L) @@(N_1 en el nudo 2)
#: N_1 da **1** y **0**; por eso cada nudo controla su propio valor y no molesta al otro.
#: **(b) Suman 1 en todo punto** (partición de la unidad):
particion = Simplify{N_1(x) + N_2(x)} @@(partición de la unidad)
#: Consecuencia física: si los dos nudos valen lo mismo (u_1=u_2=c), el elemento se mueve **rígido** sin deformarse:
cuerpo_rigido = Expand{(1 - x/L)·5 + (x/L)·5} @@(u_1=u_2=5 → u=5)
#: Da **5** (constante, sin x). Sin esta propiedad el elemento fallaría el patch test.

## 4 · La coordenada natural ξ (la que usarás en 2D)
#: Para 2D conviene un elemento **maestro** con ξ de −1 a +1 (nudo 1 en ξ=−1, nudo 2 en ξ=+1). Las mismas funciones, ahora deducidas por **Lagrange**: N_i = producto de (ξ−ξ_j)/(ξ_i−ξ_j) sobre los otros nudos. El motor las saca:
N_1 = Expand{(xi - 1)/(-1 - 1)} @@(Lagrange, nudo ξ=−1)
N_2 = Expand{(xi + 1)/(1 + 1)} @@(Lagrange, nudo ξ=+1)
particion_nat = Simplify{(xi - 1)/(-1 - 1) + (xi + 1)/(1 + 1)} @@(también suman 1)

## 5 · La derivada dN/dξ → la deformación
#: La deformación es ε = du/dx. Como u = Σ N_i·u_i, entonces ε depende de las **derivadas** de las N:
dN_1 = Slope{(1 - xi)/2 @ xi} @@(pendiente de N_1)
dN_2 = Slope{(1 + xi)/2 @ xi} @@(pendiente de N_2)
#: Dan **−1/2** y **+1/2**: **constantes**. Por eso la barra lineal tiene deformación (y tensión) **constante** en todo el elemento. En 2D a este tipo se le llama CST.

## 6 · Dibujadas: las dos rectas
#fplot((1-xi)/2, (1+xi)/2, [-1 1])
#: N_1 baja de 1 a 0; N_2 sube de 0 a 1. Se **cruzan en ξ=0**, donde cada una vale ½. Ahí está toda la idea: cada peso manda en su nudo y se desvanece en el otro.

## 7 · Con más nudos: la cuadrática (3 nudos)
#: Si añades un nudo en el medio (ξ = −1, 0, +1), Lagrange da **parábolas**. El motor las deduce:
M_1 = Expand{(xi - 0)·(xi - 1)/((-1 - 0)·(-1 - 1))} @@(esquina ξ=−1)
M_2 = Expand{(xi + 1)·(xi - 1)/((0 + 1)·(0 - 1))} @@(centro ξ=0)
M_3 = Expand{(xi + 1)·(xi - 0)/((1 + 1)·(1 - 0))} @@(esquina ξ=+1)
particion_cuad = Expand{(xi - 0)·(xi - 1)/2 + (xi + 1)·(xi - 1)/(-1) + (xi + 1)·(xi - 0)/2} @@(suman 1)
#fplot(xi·(xi-1)/2, 1-xi^2, xi·(xi+1)/2, [-1 1])
#: La del medio (M_2 = 1−ξ²) es una campana que vale 1 en el centro; las de las esquinas valen 1 en su esquina y 0 en los otros dos nudos.

## 8 · El puente a 2D (lo que sigue)
#: En 2D el elemento maestro es un **cuadrado** con ξ, η ∈ [−1, 1]. La clave: las funciones de forma 2D son el **producto** de dos 1D, una en cada dirección:
N(ξ,η) = N_a(ξ)·N_b(η) @@(producto tensorial)
#: Ejemplo, la esquina (ξ=−1, η=−1):  N = (1−ξ)/2 · (1−η)/2 = ¼(1−ξ)(1−η). Las 4 funciones del cuadrilátero son estos productos. **Por eso entender 1D es entenderlo todo: 2D es 1D × 1D.**
#> Logan §3.2 · las mismas N valen en la barra, el resorte y (como producto) en el cuadrilátero.
