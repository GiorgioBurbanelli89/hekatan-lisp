# ¿La deformada que dibuja el programa es la REAL? ¿De dónde vino la cúbica?
#: Sí, para vigas y columnas es la deformada **real** (exacta), no un dibujo bonito. Aquí ves de dónde viene: de resolver la **ecuación de la viga**. El motor lo comprueba.

## 1 · La ecuación de la viga (Euler–Bernoulli)
#: La física de una viga es:  **EI · v''''(x) = q(x)**  (q = carga repartida). Entre dos nudos, si la carga va aplicada EN los nudos, no hay q en el medio → **v'''' = 0**.

## 2 · El MOTOR resuelve: integrar (cada ∫ sube un grado)
#: Sin carga en el vano, el **cortante es constante** → v''' = 6c₃ (una constante). Integro subiendo; el motor lo hace y cada **∫ sube el grado en 1**:
vpp = Integral{6*c3 @ x} @@(v'': ∫ constante → LINEAL)
vp = Integral{6*c3*x @ x} @@(v': ∫ lineal → CUADRÁTICA)
v = Integral{3*c3*x^2 @ x} @@(v: ∫ cuadrática → CÚBICA)
#: Partí de una **constante** y en 3 integrales llegué a una **cúbica** (c₃·x³). Cada ∫ añade una constante de integración → 4 constantes en total (c₀,c₁,c₂,c₃) = los **4 datos de los nudos** (v y θ en cada extremo). **De ahí vino la cúbica: es lo que sale de integrar la ecuación de la viga.**

## 3 · Comprobación: derivar la cúbica vuelve a 0
#: Al revés: si derivo la cúbica cuatro veces (d/dx ordinaria, v es de una sola variable), debe volver a 0 (así confirmo que cumple v''''=0).
vc = c0 + c1*x + c2*x^2 + c3*x^3 @@(la deformada)
d1 = Diff{vc @ x} @@(v')
d2 = Diff{c1+2*c2*x+3*c3*x^2 @ x} @@(v'')
d3 = Diff{2*c2+6*c3*x @ x} @@(v''' constante)
d4 = Diff{6*c3 @ x} @@(v'''' = 0 ✓)
#: **v'''' = 0** → la cúbica satisface exactamente la ecuación de la viga. Por eso la deformada dibujada ES la real: la viga, entre nudos sin carga, toma justo esa forma cúbica.

## 4 · La curvatura no es constante — por eso se ve "curva"
#: La curvatura es v'' = 2c₂ + 6c₃x → **lineal**, no cero. Por eso la viga se ve doblada (no recta) y su momento (M = EI·v'') varía a lo largo. Justo lo que dibuja el programa.

## 5 · El matiz honesto: CON carga repartida en el vano
#: Si hay carga w repartida ENTRE nudos (peso propio), entonces v'''' = w/EI ≠ 0 → integrando, la deformada real gana un término **x⁴** (grado 4). La forma real de una viga biempotrada con carga uniforme es x²·(1−x)²:
#fplot(x^2*(1-x)^2, [0 1])
#: Ahí la cúbica de Hermite ya **no** es exacta en el medio; el programa lo corrige sumando esa parte de la carga (o partiendo en más elementos). Pero para cargas EN los nudos (lo común en columnas), la cúbica es exacta.

## 6 · Columnas: la misma historia
#: Una columna es una viga-columna: su flexión sigue la misma **EI·v''''=0** entre nudos → la misma **cúbica** exacta. (Solo cuando pesa el pandeo / P-Δ la ecuación cambia y la forma real usa funciones de estabilidad — trigonométricas/hiperbólicas.)
