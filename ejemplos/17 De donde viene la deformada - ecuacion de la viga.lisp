# ¿La deformada que dibuja el programa es la REAL? ¿De dónde vino la cúbica?
#: Sí, para vigas y columnas es la deformada **real** (exacta), no un dibujo bonito. Aquí ves de dónde viene: de resolver la **ecuación de la viga**. El motor lo comprueba.

## 1 · La ecuación de la viga (Euler–Bernoulli)
#: La física de una viga es:  **EI · v''''(x) = q(x)**  (q = carga repartida). Entre dos nudos, si la carga va aplicada EN los nudos, no hay q en el medio → **v'''' = 0**.

## 2 · Resolver = integrar 4 veces
#: Integrando v''''=0 cuatro veces, cada integral añade una constante:
#|  v'''' = 0  →  v''' = c₃  →  v'' = c₃x + ...  →  v' = ...  →  v = c₀ + c₁x + c₂x² + c₃x³
#: El resultado es un polinomio **CÚBICO**. Las 4 constantes se fijan con los 4 datos de los nudos (v y θ en cada extremo). **De ahí vino la cúbica: es la solución exacta de la ecuación de la viga.**

## 3 · El motor lo comprueba: la cúbica CUMPLE v''''=0
#: Si derivo la cúbica cuatro veces debe dar 0 (así confirmo que satisface la ecuación de la viga):
v = c0 + c1*x + c2*x^2 + c3*x^3 @@(la deformada)
va = Partial{v @ x} @@(v' pendiente)
vb = Partial{c1+2*c2*x+3*c3*x^2 @ x} @@(v'' curvatura)
vc = Partial{2*c2+6*c3*x @ x} @@(v''' ∝ cortante, constante)
vd = Partial{6*c3 @ x} @@(v'''' = 0 ✓)
#: **v'''' = 0** → la cúbica satisface exactamente la ecuación de la viga. Por eso la deformada dibujada ES la real: la viga, entre nudos sin carga, toma justo esa forma cúbica.

## 4 · La curvatura no es constante — por eso se ve "curva"
#: La curvatura es v'' = 2c₂ + 6c₃x → **lineal**, no cero. Por eso la viga se ve doblada (no recta) y su momento (M = EI·v'') varía a lo largo. Justo lo que dibuja el programa.

## 5 · El matiz honesto: CON carga repartida en el vano
#: Si hay carga w repartida ENTRE nudos (peso propio), entonces v'''' = w/EI ≠ 0 → integrando, la deformada real gana un término **x⁴** (grado 4). La forma real de una viga biempotrada con carga uniforme es x²·(1−x)²:
#fplot(x^2*(1-x)^2, [0 1])
#: Ahí la cúbica de Hermite ya **no** es exacta en el medio; el programa lo corrige sumando esa parte de la carga (o partiendo en más elementos). Pero para cargas EN los nudos (lo común en columnas), la cúbica es exacta.

## 6 · Columnas: la misma historia
#: Una columna es una viga-columna: su flexión sigue la misma **EI·v''''=0** entre nudos → la misma **cúbica** exacta. (Solo cuando pesa el pandeo / P-Δ la ecuación cambia y la forma real usa funciones de estabilidad — trigonométricas/hiperbólicas.)
