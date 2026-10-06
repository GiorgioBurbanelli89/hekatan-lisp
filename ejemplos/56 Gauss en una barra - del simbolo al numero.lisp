# Gauss en una barra: del símbolo al número
#: Qué son exactamente los rectángulos, y para qué sirve todo esto en una barra de verdad. Primero el álgebra, después los números.
#> Hekatan Struct

## 1 · Los rectángulos NO son la región
#: Aquí está la confusión, y conviene decirla clara. En el dibujo hay **dos figuras distintas**:
#: · La zona **azul** bajo la curva: esa es el área **exacta**, el número que queremos.
#: · Los **rectángulos naranjas**: cada uno tiene de **ancho su peso wᵢ** y de **alto la curva en su punto, f(ξᵢ)**. Su área sumada es lo que **calcula la fórmula**.
#: No se parecen, y no tienen por qué. Lo único que se les pide es que el **número** salga igual. Gauss coloca los puntos justo donde eso ocurre.

## 2 · Míralo: el ancho es el peso, la altura es la función
#gauss(vars)

## 2 · La barra, en símbolos
#: Ahora la barra. Su rigidez es esta integral, y dentro están la matriz B, el material y el Jacobiano:
B = [-1/L, 1/L] @@(B = J⁻¹·dN/dξ)
J = L/2 @@(Jacobiano)
BtB = transpose(B)*B @@(BᵀB)
K_exacta = E*A*J*Area{transpose(B)*B @ xi=-1:1} @@(K = E·A·|J|·∫BᵀB dξ)
#: Sale **EA/L**, la de toda la vida. Y ahora la clave: como B no depende de {xi}, ese integrando es **constante**.

## 3 · El ancho 1 es la solución para DOS puntos, no una regla
#: Con **n** puntos hay **2n incógnitas** —n posiciones y n pesos— y se imponen **2n condiciones**. Cambia n, cambia el sistema, y cambia la solución. Por eso el ancho no siempre vale 1:
#: **Un punto** · 2 incógnitas (ξ, w) · 2 condiciones (f = 1 y f = ξ):
#: → w·1 = 2 da **w = 2**, y w·ξ = 0 da **ξ = 0**. Un solo tramo, que ocupa todo el intervalo.
#: **Dos puntos** · 4 incógnitas · 4 condiciones (1, ξ, ξ², ξ³):
#: → **w₁ = w₂ = 1** y **ξ = ∓1/√3 = ∓0.5774**. Dos tramos de ancho 1. Esto es lo que despejamos antes.
#: **Tres puntos** · 6 incógnitas · 6 condiciones (hasta ξ⁵):
#: → **w = 5/9, 8/9, 5/9** y **ξ = ∓√(3/5), 0**. Tres tramos, y ya no miden 1.
#: Lo único que se repite en todos los casos es la **primera** condición, f = 1, que dice que los pesos suman el ancho del intervalo:
suma_pesos = Area{1 @ xi=-1:1} @@(Σwᵢ = ∫1 dξ = 2, siempre)

## 4 · Comprobemos los de tres puntos con el motor
#: Si 5/9, 8/9, 5/9 en ∓√(3/5) y 0 son la solución, tienen que cumplir las condiciones. El motor las evalúa:
c1 = dec(5/9 + 8/9 + 5/9, 4) @@(f = 1 → debe dar 2)
c2 = dec(2*(5/9)*(3/5), 4) @@(f = ξ² → debe dar 2/3 = 0.6667)
c3 = dec(2*(5/9)*(3/5)^2, 4) @@(f = ξ⁴ → debe dar 2/5 = 0.4000)
exacta_2 = Area{xi^2 @ xi=-1:1} @@(∫ξ² dξ)
exacta_4 = Area{xi^4 @ xi=-1:1} @@(∫ξ⁴ dξ)
#: Cuadran las tres. Cada juego de pesos y posiciones es la solución de **su** sistema: con dos puntos sale el ancho 1; con tres, 5/9 y 8/9.

## 5 · Con UN punto de Gauss ya basta
#: Un integrando constante es un polinomio de grado 0, y con **n = 1** Gauss es exacta hasta grado 2n−1 = 1. Así que un solo punto, en el centro, con peso 2:
K_g1 = E*A*J*2*BtB @@(K = w·BᵀB·E·A·|J|, con w = 2 y ξ = 0)
#: El mismo **EA/L**. Un punto, exacto. Por eso los programas no gastan cuatro puntos en una barra recta de sección constante.

## 6 · Ahora una barra que sí lo necesita
#: Cambiemos la barra: una de **sección variable**, que se engorda hacia los extremos. El área ya no es un número, es una función de {xi}:
A_var = A_0*(1 + 0.6*xi^2) @@(sección variable)
#: El integrando pasa a ser de **grado 2**, y ahí un solo punto se queda corto. Compruébalo: mueve la barra y mira cómo cambia la sección a lo largo del elemento.
#slider fplot(A_de_xi = 1 + n/10*x^2, [-1 1]), n = 0:9

## 7 · El número exacto, con el motor
I_A = Area{1 + 0.6*xi^2 @ xi=-1:1} @@(∫(1+0.6ξ²)dξ)
K_var = E*A_0*I_A/(2*L) @@(K = E·(1/L²)·|J|·∫A(ξ)dξ)
#: La integral vale **2.4**, así que la rigidez es **1.2·E·A₀/L**: un 20 % más que la barra de sección constante.

## 8 · Un punto contra dos puntos
#: **Con un punto** (ξ = 0, w = 2): la sección en el centro es A₀, y la fórmula da 2·A₀ = 2.0 en vez de 2.4.
g1 = dec(2*(1 + 0.6*0^2), 4) @@(1 punto: w·A(0))
#: **Con dos puntos** (ξ = ∓0.5774, w = 1): la sección en cada punto vale A₀·(1 + 0.6/3) = 1.2·A₀, y la suma da 2.4. Exacto.
g2 = dec(1*(1 + 0.6*0.5773503^2) + 1*(1 + 0.6*0.5773503^2), 4) @@(2 puntos: w₁A(−a) + w₂A(+a))
error_1 = dec((2.4 - 2.0)/2.4*100, 1) @@(error del punto único, %)
#: Un punto se equivoca un **16.7 %**; dos puntos aciertan al dígito. Esa es toda la razón de usar 2×2 puntos en un cuadrilátero y no uno solo.

## 9 · Y con números de obra
E_v = 2100 @@(tonf/cm²)
A_v = 20 @@(cm²)
L_v = 300 @@(cm)
K_const = dec(E_v*A_v/L_v, 1) @@(barra normal: E·A/L, tonf/cm)
K_variable = dec(1.2*E_v*A_v/L_v, 1) @@(barra de sección variable, tonf/cm)
#: 140 contra 168 tonf/cm. La cuadratura de Gauss es lo que permite que el programa calcule la segunda sin integrar a mano: evalúa en dos puntos, multiplica por su peso, y suma.
#> Hekatan Struct
