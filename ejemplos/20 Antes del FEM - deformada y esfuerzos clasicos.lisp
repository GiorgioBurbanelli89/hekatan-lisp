# Antes del FEM: cómo se graficaba la deformada y los esfuerzos (método clásico)
#: Partimos de aquí. Antes de los elementos finitos, para una viga se hacía en DOS pasos —y en **orden inverso** al FEM—: primero los ESFUERZOS (por equilibrio), luego la DEFORMADA (integrando). El motor lo reproduce.

## 1 · El ejemplo: viga simplemente apoyada con carga uniforme
#: Longitud L=1, carga repartida w=1, rigidez EI=1 (normalizado). Cada apoyo toma la mitad de la carga: reacción R = w·L/2 = ½.

## 2 · Primero los ESFUERZOS, por EQUILIBRIO (sin saber la deformada)
#: Cortas la viga en una sección x y aplicas equilibrio al trozo izquierdo:
#| · Cortante (suma de fuerzas):  V(x) = R − w·x = ½ − x
#| · Momento (suma de momentos):  M(x) = R·x − w·x²/2 = (x − x²)/2
V = 1/2 - x @@(cortante, del equilibrio)
M = (x - x^2)/2 @@(momento, del equilibrio)
#fplot(1/2-x, (x-x^2)/2, [0 1])
#: Esos son los **diagramas de cortante y momento**. Se dibujaban DIRECTO del equilibrio — sin conocer todavía la deformada. (El momento máximo en el centro es wL²/8 = ⅛ = 0.125.)

## 3 · Después la DEFORMADA, por DOBLE INTEGRACIÓN
#: La ley de la viga dice EI·v'' = M (la curvatura por la rigidez = el momento). Con EI=1: v'' = M = (x−x²)/2. Integras DOS veces (el motor integra):
vp = Integral{(x-x^2)/2 @ x} @@(v' = ∫ M dx)
v = Integral{x^2/4-x^3/6 @ x} @@(v = ∫ v' dx)
#: Sale x³/12 − x⁴/24 (más las constantes de integración). Las **condiciones de borde** (v=0 en los dos apoyos) fijan esas constantes, y queda la deformada exacta:
v_final = (2*x^3 - x^4 - x)/24 @@(deformada exacta)
#fplot((2*x^3-x^4-x)/24, [0 1])
#: Es la deformada real (grado 4), aquí obtenida **integrando el momento**. Baja (flecha hacia abajo), máxima en el centro.

## 4 · El contraste con el FEM: ¡el ORDEN es inverso!
#: Recuerda la cadena:  carga → cortante V → momento M → curvatura → giro → flecha v.
#| · CLÁSICO (antes): equilibrio → ESFUERZOS (V, M) → integrar M/EI dos veces → DEFORMADA. Va de esfuerzo a deformada, **INTEGRANDO** (y necesita las condiciones de borde).
#| · FEM (hoy): rigidez → DESPLAZAMIENTOS (resolviendo K·u = F) → derivar → ESFUERZOS. Va de deformada a esfuerzo, **DERIVANDO**.
#: Recorren la misma cadena en **sentidos opuestos**. Por eso el FEM necesita la **interpolación**: para tener una función v(x) continua que poder derivar. El clásico no interpola —resuelve la ecuación exacta—, pero solo sirve en casos simples con fórmula. Ese es el punto de partida del que nació el FEM.
