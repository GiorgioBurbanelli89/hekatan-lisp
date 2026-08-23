# Reseña histórica: la interpolación en los elementos finitos, época por época
#: Cómo, en cada época, se representó el desplazamiento DENTRO de un elemento: la fórmula que se usaba, su gráfica (dibujada por el motor) y a qué corresponde hoy. De la semilla matemática al método moderno.

## ~1795 · Lagrange — la interpolación polinómica
#: La semilla. Lagrange dio la forma de pasar UNA curva suave por puntos dados. Con 3 puntos (0,0), (½,1), (1,0) sale una parábola:
lagrange = 4*x - 4*x^2 @@(polinomio que pasa por 3 puntos)
#fplot(4*x-4*x^2, [0 1])
#: La idea que lo cambió todo: **reconstruir una función sabiendo su valor en pocos puntos**. De aquí nacen los "pesos" por punto — las futuras funciones de forma.

## 1909 · Ritz — funciones de prueba + energía
#: El salto conceptual: NO resolver la ecuación exacta, sino proponer funciones simples con perillas y ajustarlas **minimizando la energía**. Una curva real (seno) aproximada por un polinomio:
#fplot(sin(3.14159*x), 4*x-4*x^2, [0 1])
#: Casi coinciden. Se cambió "resolver" por "aproximar con parámetros" — la base de todo lo que sigue.

## 1943 · Courant — lineal por trozos (nace el "elemento")
#: Dividir el dominio en trozos y usar en cada uno la función más simple: una **recta**. La poligonal coincide en los nudos pero hace **quiebres** (pico en ½):
#fplot(1-abs(2*x-1), [0 1])
#: Continua en valor (C⁰). Aquí nace la idea de **elemento**: un trozo pequeño con su función simple.

## 1956 · Turner y Clough (Boeing) — el PRIMER elemento: triángulo lineal
#: El ala delta (una placa 2D) obligó a inventarlo. Triángulo de 3 nudos, campo lineal u = a + b·x + c·y. El motor deduce sus funciones de forma:
base = [1 x y] @@(la base lineal)
C = [1 0 0; 1 1 0; 1 0 1] @@(base en los 3 nudos)
Cinv = C^-1 @@(despeja los coeficientes)
N = base*Cinv @@(N = [1−x−y, x, y])
#: Son **planos** (no se curvan) → "deformación constante" (CST). En planta, un degradado lineal:
#map(1-x-y, [0 1], [0 1])
#: → **Fue el nacimiento del método de los elementos finitos.**

## años 1950–60 · la viga: cúbicas de Hermite
#: Para la flexión, la recta no basta (deja quiebres). La solución de la ecuación de la viga EI·v''''=0 es una **cúbica**. Sus 4 funciones de forma (Hermite):
H1 = 1-3*x^2+2*x^3 @@(peso de v₁, desplazamiento nudo 1)
H2 = x-2*x^2+x^3 @@(peso de θ₁, giro nudo 1)
H3 = 3*x^2-2*x^3 @@(peso de v₂, desplazamiento nudo 2)
H4 = -x^2+x^3 @@(peso de θ₂, giro nudo 2)
#fplot(H1, H2, H3, H4, [0 1])
#: → **Esta es la forma que usa ETABS / SAP2000 para dibujar la deformada curva de vigas y columnas (frames):** v(x) = H₁·v₁ + H₂·θ₁ + H₃·v₂ + H₄·θ₂.

## 1963 · Melosh — el cuadrilátero bilineal y la matriz C
#: Para placas, un cuadrado de 4 nudos. Polinomio bilineal u = c₁ + c₂x + c₃y + c₄·x·y. Las 4 funciones de forma son "carpas" (una por nudo):
#surf((1-x)*(1-y), [0 1], [0 1])
#: → Es lo que usan los programas para elementos de **placa y cáscara (shells)**. La matriz C fue el atajo para deducir estas N desde el polinomio.

## ~1968 · Irons — el isoparamétrico (el moderno)
#: Escribe las N **directamente** en coordenadas naturales ξ, η:  N = ¼·(1±ξ)·(1±η), sin pasar por la C. Más limpio y general (permite elementos curvos):
#surf(0.25*(1-x)*(1-y), [-1 1], [-1 1])
#: → **Es la forma que usan casi todos los programas de hoy** (ETABS, SAP2000, SAFE, Abaqus…) para sus elementos 2D y 3D.

## En una línea
#: Lagrange (interpolar) → Ritz (aproximar con parámetros) → Courant (por trozos) → **Turner/Clough 1956** (el triángulo: nace el FEM) → Hermite (vigas: la deformada de ETABS) → Melosh (placas, la C) → Irons (isoparamétrico: el moderno).
