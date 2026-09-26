# Por qué existen las funciones de forma — 1D primero, 2D después
#: La PREGUNTA: conozco el valor solo en los **nudos**. ¿Cómo obtengo el valor en **cualquier punto** de en medio? Necesito una regla de relleno. El motor la deduce sola. Todo lo **calcula Hekatan LISP**.

## PARTE 1 · UNA BARRA DE 2 NUDOS (1D)

### 1.1 · La suposición: una recta (2 nudos → 2 perillas)
#: Entre 2 puntos, lo más simple es una recta. Base = los términos [1, x]:
base1 = [1 x] @@(los términos, como el y=a+b·x)

### 1.2 · Aquí NACE C: evalúo la base en cada nudo (x=0 y x=1)
#: Meto la coordenada de cada nudo en [1, x]. Cada fila es esa evaluación:
#|  nudo 1 (x=0): [1  0]      nudo 2 (x=1): [1  1]
C1 = [1 0; 1 1] @@(C = base evaluada en los 2 nudos)

### 1.3 · Despejo las perillas: la inversa
Ci1 = C1^-1 @@(C⁻¹: despeja los coeficientes)

### 1.4 · Las funciones de forma salen SOLAS: N = base · C⁻¹
N1D = base1*Ci1 @@(N = base · C⁻¹)
#: Da **[1−x , x]**. Esas son N₁ y N₂.

### 1.5 · VERLAS (gráfica 1D)
#: N₁ baja de 1→0, N₂ sube de 0→1. Cada una vale **1 en su nudo y 0 en el otro**:
Na = 1-x @@(N₁)
Nb = x @@(N₂)
#fplot(Na, Nb, [0 1])

### 1.6 · LA RAZÓN (esto es lo que no entendías)
#: El valor en cualquier punto es  **u(x) = N₁·u₁ + N₂·u₂**. Cada N es el **PESO** de un nudo. En el nudo 1, N₁=1 y N₂=0 → sale u₁ exacto. En medio, se mezclan suave. Por eso funciona: reproduce los nudos y rellena el resto.

## PARTE 2 · UNA BALDOSA DE 4 NUDOS (2D)

### 2.1 · La suposición: bilineal (4 nudos → 4 perillas)
#: Misma idea, pero 4 esquinas → 4 términos. El nuevo es x·y (mantiene los bordes rectos):
base2 = [1 x y x*y] @@(la base bilineal)

### 2.2 · Nace C: la base evaluada en las 4 esquinas
#|  (0,0):[1 0 0 0]  (1,0):[1 1 0 0]  (1,1):[1 1 1 1]  (0,1):[1 0 1 0]
C2 = [1 0 0 0; 1 1 0 0; 1 1 1 1; 1 0 1 0] @@(C, 4 filas = 4 nudos)

### 2.3 · La inversa
Ci2 = C2^-1 @@(despeja las 4 perillas)

### 2.4 · Las 4 funciones de forma: N = base · C⁻¹
N2D = base2*Ci2 @@(las 4 carpas)
#: Da  N₁=(1−x)(1−y), N₂=x(1−y), N₃=x·y, N₄=y(1−x).

### 2.5 · VERLAS en 3D (girable) y en 2D (planta)
#: Cada carpa vale 1 en su nudo y 0 en los otros tres — igual que en 1D, pero en las 4 esquinas:
#surf((1-x)*(1-y), [0 1], [0 1])
#surf(x*y, [0 1], [0 1])
#map((1-x)*(1-y), [0 1], [0 1])

### 2.6 · LA RAZÓN es la MISMA que en 1D
#: u(x,y) = N₁·u₁ + N₂·u₂ + N₃·u₃ + N₄·u₄. Cada N pesa un nudo. Su suma = 1 en todo punto (para no inventar valores). C fue solo la máquina para fabricar esos pesos desde el polinomio.
