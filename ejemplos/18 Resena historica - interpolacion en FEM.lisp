# Reseña histórica: la interpolación en los elementos finitos, época por época
#: Primero el PROBLEMA (por qué hace falta interpolar), y luego la historia: en cada época, el motor DEDUCE la fórmula que se usaba (cómo se llega a ella), la grafica, y se dice a qué corresponde hoy.

## 0 · El problema: del análisis salen PUNTOS, no una curva
#: Resolver la estructura (K·u = F) te da SOLO números en los nudos: cuánto se movió cada uno. Por ejemplo, una viga con el extremo izquierdo fijo y el derecho bajando 1:  v₁ = 0,  v₂ = 1 (más sus giros). Son 2–4 **números sueltos**, NO una función. Entre los nudos no tienes NADA.

## 0.1 · Lo más crudo: unir los nudos con una recta
#: Sin ninguna regla fina, lo único que puedes hacer es unir los nudos con una línea recta:
#fplot(x, [0 1])

## 0.2 · El problema: la viga real NO es recta
#: Una viga se **curva**. La recta cruda se equivoca en todo el medio. Compara la recta con la forma real (una cúbica):
#fplot(x, 3*x^2-2*x^3, [0 1])
#: Por eso **unir puntos no basta**: hace falta una regla de relleno que respete la física.

## 0.3 · La razón DE FONDO: la física vive DENTRO del elemento
#: No es solo dibujar. La **deformación** es la DERIVADA del desplazamiento (ε = du/dx) y la **rigidez** es una INTEGRAL (K = ∫ Bᵀ·D·B dx). Para derivar e integrar necesitas una **función continua**, no puntos. Ejemplo: de la deformada interpolada saco la deformación derivando:
u_int = 3*x^2-2*x^3 @@(desplazamiento interpolado)
deformacion = Diff{u_int @ x} @@(ε = du/dx)
#: Da 6·x − 6·x². **Sin interpolación no hay deformación, ni rigidez → no hay FEM.** Todo lo que sigue es cómo se llegó a la interpolación.

## ~1795 · Lagrange — la interpolación polinómica
#: La semilla: pasar una curva por puntos dados. Con 3 nudos (0, ½, 1) y solo el del medio con valor 1, el interpolante es el polinomio base de Lagrange de ese nudo:  ℓ = (x−0)(x−1) / ((½−0)(½−1)). El denominador es −¼, así que ℓ = −4·x·(x−1). El motor lo expande:
lagrange = Expand{-4*x*(x-1)} @@(polinomio por 3 puntos)
#fplot(4*x-4*x^2, [0 1])
#: Da **4x − 4x²**. La idea que lo cambió todo: reconstruir una función desde el valor en pocos puntos → nacen los "pesos" por nudo.

## 1909 · Ritz — funciones de prueba + energía
#: El salto: NO resolver la ecuación exacta, sino proponer funciones simples con perillas y ajustarlas minimizando la energía. Una curva real aproximada por un polinomio:
#fplot(sin(3.14159*x), 4*x-4*x^2, [0 1])
#: Casi coinciden. Se cambió "resolver" por "aproximar con parámetros".

## 1943 · Courant — lineal por trozos (nace el "elemento")
#: Dividir el dominio en trozos y usar en cada uno una recta. Coincide en los nudos pero hace quiebres (pico en ½):
#fplot(1-abs(2*x-1), [0 1])
#: Continua en valor (C⁰). Aquí nace el "elemento": un trozo con su función simple.

## 1956 · Turner y Clough (Boeing) — el PRIMER elemento: triángulo lineal
#: El ala delta (placa 2D) lo obligó. Triángulo de 3 nudos, campo lineal u = a + b·x + c·y. El motor deduce sus funciones de forma:
base_t = [1 x y] @@(base lineal)
C_t = [1 0 0; 1 1 0; 1 0 1] @@(base en los 3 nudos)
Ci_t = C_t^-1 @@(despeja los coeficientes)
N_t = base_t*Ci_t @@(N = [1−x−y, x, y])
#map(1-x-y, [0 1], [0 1])
#: Son **planos** (deformación constante, CST). → **Fue el nacimiento del método de los elementos finitos.**

## años 1950–60 · la viga: cúbicas de Hermite
#: La flexión exige pendiente continua (C¹): 2 datos por nudo (v y θ). El motor deduce las 4 cúbicas desde la base [1 x x² x³] evaluando v y v' en los 2 nudos:
base_h = [1 x x^2 x^3] @@(base cúbica)
C_h = [1 0 0 0; 0 1 0 0; 1 1 1 1; 0 1 2 3] @@(v y v' en los 2 nudos)
Ci_h = C_h^-1 @@(despeja)
N_h = base_h*Ci_h @@(las 4 cúbicas de Hermite)
#fplot(1-3*x^2+2*x^3, x-2*x^2+x^3, 3*x^2-2*x^3, -x^2+x^3, [0 1])
#: → **Esta es la forma que usa ETABS / SAP2000 para dibujar la deformada curva de vigas y columnas (frames).**

## 1963 · Melosh — el cuadrilátero bilineal y la matriz C
#: Para placas, cuadrado de 4 nudos. Polinomio bilineal u = c₁+c₂x+c₃y+c₄·x·y. El motor deduce las 4 "carpas":
base_b = [1 x y x*y] @@(base bilineal)
C_b = [1 0 0 0; 1 1 0 0; 1 1 1 1; 1 0 1 0] @@(base en las 4 esquinas)
Ci_b = C_b^-1 @@(despeja)
N_b = base_b*Ci_b @@(las 4 funciones de forma)
#surf((1-x)*(1-y), [0 1], [0 1])
#: Salen (1−x)(1−y), x(1−y), x·y, y(1−x). → Es lo que usan los programas para **placa y cáscara (shells)**.

## ~1968 · Irons — el isoparamétrico (el moderno)
#: Escribe las N **directamente** en coordenadas naturales ξ,η como PRODUCTO de dos 1D: N = ¼(1−ξ)(1−η). El motor la expande:
iso = Expand{0.25*(1-x)*(1-y)} @@(N₁ isoparamétrica)
#surf(0.25*(1-x)*(1-y), [-1 1], [-1 1])
#: Sin pasar por la C. → **Es la forma que usan casi todos los programas de hoy** (ETABS, SAP2000, SAFE, Abaqus…).

## En una línea
#: Lagrange (interpolar) → Ritz (aproximar) → Courant (por trozos) → **Turner/Clough 1956** (el triángulo: nace el FEM) → Hermite (vigas: la deformada de ETABS) → Melosh (placas, la C) → Irons (isoparamétrico: el moderno).
