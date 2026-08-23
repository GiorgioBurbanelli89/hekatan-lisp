# Elementos finitos en 1D, explicado despacio
#: Solo 1D. Dos casos: la **barra** que estira (sale una recta) y la **viga** que se dobla (sale una cúbica). Todo lo deduce el motor, con sus gráficas.

## 1 · El problema: del análisis salen PUNTOS, no una curva
#: Resolver la estructura (K·u = F) te da SOLO números en los nudos: cuánto se movió cada uno. Entre los nudos no tienes nada. Para dibujar la forma del medio —y sobre todo para calcular la física ahí dentro— hay que **rellenar** entre nudos con una regla: eso es la **interpolación**. Veamos las dos reglas del 1D.

## 2 · La BARRA (fuerza axial): se estira, NO se dobla
### 2.1 · El campo es una RECTA
#: Una barra jalada de sus extremos se estira **parejo**: el desplazamiento crece lineal de un extremo al otro. Dos nudos → dos datos → recta:  u(x) = a + b·x.

### 2.2 · El motor deduce las funciones de forma
#: Base [1 x], evaluada en los 2 nudos (x=0 y x=1), invertir, y N = base·C⁻¹:
base1 = [1 x] @@(base lineal)
C1 = [1 0; 1 1] @@(base en los 2 nudos)
Ci1 = C1^-1 @@(despeja)
N1 = base1*Ci1 @@(N = [1−x, x])
#fplot(1-x, x, [0 1])
#: N₁ = 1−x baja de 1 a 0; N₂ = x sube de 0 a 1. Cada una vale 1 en su nudo y 0 en el otro: son los **pesos** de cada extremo.  u(x) = N₁·u₁ + N₂·u₂.

### 2.3 · Por qué la recta BASTA (es exacta)
#: La barra cumple EA·u'' = 0 → u'' = 0. La solución exacta ES una recta, así que la lineal **no aproxima: es exacta**. La **deformación** axial es ε = du/dx, y en una recta es CONSTANTE (se estira igual en todo el largo):
epsilon = Diff{a+b*x @ x} @@(ε = du/dx = b, constante)
#: Constante en toda la barra. Por eso en la barra la recta es suficiente.

## 3 · La VIGA (flexión): se DOBLA → hace falta más
### 3.1 · Qué es la CURVATURA (despacio)
#: Dobla una regla con las manos: se **arquea**. La **curvatura** mide qué tan cerrado es ese arco en cada punto. Recta = sin arco = curvatura CERO; arco muy cerrado = mucha curvatura (un círculo de radio R tiene κ = 1/R).
#: **Por qué es la 2ª derivada:** la 1ª derivada v' es la **pendiente**; si la pendiente no cambia, la viga va derecha; si cambia, se dobla. La curvatura = cuánto cambia la pendiente = **v''**. La recta tiene pendiente constante → curvatura cero:
r_p = Diff{a+b*x @ x} @@(pendiente = b, constante)
r_k = Diff{b @ x} @@(curvatura = 0 → no se dobla)
#: **La física:** lo que dobla la viga es el momento flector M, y la ley de la viga dice **M = EI·v''** (el momento es proporcional a la curvatura). Donde hay momento, hay curvatura.

### 3.2 · Por qué la recta NO sirve para la viga
#: La viga con momento tiene curvatura ≠ 0, pero una recta tiene curvatura 0. Entonces la recta no puede representarla. Se necesita un polinomio que SÍ tenga curvatura → sube el grado.

### 3.3 · El campo de la viga: una CÚBICA
#: La ecuación de la viga sin carga en el vano es EI·v'''' = 0; integrando 4 veces sale una **cúbica**. Además cada extremo aporta 2 datos: el desplazamiento v y el giro θ. Dos nudos → 4 datos → 4 términos → cúbica. El motor deduce sus funciones de forma (Hermite) desde la base [1 x x² x³] evaluando v y v' en los 2 nudos:
base_h = [1 x x^2 x^3] @@(base cúbica)
C_h = [1 0 0 0; 0 1 0 0; 1 1 1 1; 0 1 2 3] @@(v y v' en los 2 nudos)
Ci_h = C_h^-1 @@(despeja)
N_h = base_h*Ci_h @@(las 4 cúbicas de Hermite)
#fplot(1-3*x^2+2*x^3, x-2*x^2+x^3, 3*x^2-2*x^3, -x^2+x^3, [0 1])
#: Salen H₁=1−3x²+2x³, H₂=x−2x²+x³, H₃=3x²−2x³, H₄=−x²+x³. Las dos con pico (H₁,H₃) pesan los **desplazamientos**; las suaves (H₂,H₄) pesan los **giros**.

### 3.4 · La deformada de la viga
#: El programa conoce solo los extremos (v₁,θ₁,v₂,θ₂) y arma la curva mezclando las Hermite:  v(x) = H₁·v₁ + H₂·θ₁ + H₃·v₂ + H₄·θ₂. Ejemplo (izq fijo, der baja 1 y gira 0.5):
deformada = 3*x^2-2*x^3 + 0.5*(-x^2+x^3) @@(v(x))
#fplot(deformada, [0 1])
#: Esa curva suave es la deformada real (la que dibuja ETABS/SAP para vigas y columnas).

## 3.5 · La teoría de la viga es una CADENA (la curvatura es UN eslabón)
#: La curvatura no es todo: es el eslabón del medio. **Cada derivada del desplazamiento es una cantidad física.** El motor las saca todas, una tras otra, desde la deformada v = 3x²−2x³:
v_giro = Diff{3*x^2-2*x^3 @ x} @@(giro θ = v')
v_curv = Diff{6*x-6*x^2 @ x} @@(curvatura v'' → momento M = EI·v'')
v_cort = Diff{6-12*x @ x} @@(cortante V = EI·v''')
v_carga = Diff{-12 @ x} @@(carga q = EI·v'''')
#: La cadena queda:  **v** (flecha) → **v'** (giro) → **v''** (curvatura → momento) → **v'''** (cortante) → **v''''** (carga). El momento/curvatura es el centro; hacia un lado el giro y la flecha, hacia el otro el cortante y la carga. Aquí la carga da 0: es una viga SIN carga en el vano (por eso la cúbica es exacta).
#: Y **aparte de esta cadena**, la viga de **Timoshenko** añade la deformación por **cortante** — Euler-Bernoulli la desprecia (supone que las secciones giran perpendiculares al eje). Importa en vigas **cortas o peraltadas**. Ese es el "algo más" fuera de la curvatura.

## 4 · La razón DE FONDO (por qué interpolar, en 1D)
#: No es solo dibujar: la **deformación** es la derivada del desplazamiento y la **rigidez** es una integral de eso —  K = ∫ EA·(N')ᵀ(N') dx  en la barra,  K = ∫ EI·(N'')ᵀ(N'') dx  en la viga. Para derivar e integrar necesitas una FUNCIÓN continua, no puntos sueltos. La interpolación te da esa función a partir de los valores en los nudos. **Sin interpolación no hay deformación, ni rigidez → no hay FEM.**
