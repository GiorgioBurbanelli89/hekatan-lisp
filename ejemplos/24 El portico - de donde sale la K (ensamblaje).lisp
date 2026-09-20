# El pórtico: de dónde sale la K (ensamblaje desde las barras)
#: En el ejemplo del pórtico la matriz K apareció ya armada. Aquí se ve de dónde sale: se ENSAMBLA de las K de cada barra, que a su vez vienen de las funciones de forma. Todo con el motor.

## 1 · De dónde salen las FUNCIONES DE FORMA (el meollo)
#: Una función de forma es el **PESO** de un dato de la punta: dice cuánto manda ese dato sobre la curva que toma la barra en el medio. En las puntas hay 4 datos — cuánto BAJA (v) y cuánto GIRA (v') cada extremo — así que hay 4 pesos. El razonamiento para hallarlos, paso a paso:

#: **1) La barra se dobla como una cúbica.** ¿Por qué esos 4 ingredientes (1, x, x², x³)? Por dos razones que caen juntas. **Contar:** en las puntas conozco 4 datos, así que necesito 4 "perillas" independientes para forzarlos; las más simples son las potencias, una por grado — **1** pone el nivel, **x** la inclinación, **x²** una curva, **x³** una curva que cambia. Cada una hace algo que las otras no pueden. **Física:** una viga a flexión se dobla exactamente como cúbica (momento lineal → curvatura lineal → dos integraciones → flecha cúbica). Los 4 ingredientes son la base; cualquier cúbica es una mezcla de estos cuatro:
base = [1 x x^2 x^3] @@(los 4 ingredientes de la cúbica)
#fplot(1, x, x^2, x^3, [0 1])

#: **2) Los ajustes a₀…a₃ no son físicos; los datos de las puntas SÍ.** Para pasar de unos a otros, evalúo la cúbica (da v) y su PENDIENTE (da v') en los dos extremos, x=0 y x=1. La pendiente la saca el motor:
wd = Diff{a0 + a1*x + a2*x^2 + a3*x^3 @ x} @@(pendiente de la cúbica general)
#: Meto x=0 y x=1 en la cúbica y en esa pendiente. Cada evaluación es una FILA: dice qué mezcla de ajustes da ese dato. Las 4 filas son la matriz **C**:
C = [1 0 0 0; 0 1 0 0; 1 1 1 1; 0 1 2 3] @@(fila1=v(0), fila2=v'(0), fila3=v(1), fila4=v'(1))

#: **3) Le doy la vuelta.** Los datos = C·ajustes, así que los ajustes = C⁻¹·datos. Y la deformada = base·ajustes = base·C⁻¹·datos. Ese **base·C⁻¹** es lo que multiplica a cada dato: son los pesos. Ahí nacen:
Cinv = C^-1 @@(C⁻¹: de los datos a los ajustes)
N = base*Cinv @@(N = base·C⁻¹ = los 4 pesos = las funciones de forma)

#: **4) Qué son esos pesos (la clave).** Cada peso vale **1** en su propio dato y **0** en los otros 3. Por eso es el "peso" de ese dato. Los nombro (columnas de N) y los dibujo:
H1 = 1-3*x^2+2*x^3 @@(peso de v₁)
H2 = x-2*x^2+x^3 @@(peso de θ₁)
H3 = 3*x^2-2*x^3 @@(peso de v₂)
H4 = -x^2+x^3 @@(peso de θ₂)
#fplot(1-3*x^2+2*x^3, x-2*x^2+x^3, 3*x^2-2*x^3, -x^2+x^3, [0 1])
#: Mira la azul (H₁, peso de v₁): sale de 1 y baja a 0. La verde (H₃, peso de v₂): sube de 0 a 1. Cada una manda sobre SU dato y se anula en los otros tres.

#: **5) La deformada real es la mezcla.** Se suman los 4 pesos, cada uno por su dato. Ejemplo: baja 1 a la izquierda y 0.5 a la derecha (giros 0):
w = 1*H1 + 0.5*H3 @@(deformada = v₁·H₁ + v₂·H₃, con v₁=1, v₂=0.5)
#fplot(1-1.5*x^2+x^3, [0 1])
#: Ese es todo el meollo: se asume cúbica → se atan sus ajustes a los datos de las puntas (matriz C) → se invierte (C⁻¹) → base·C⁻¹ = los pesos. El FEM es exactamente esto.
#: Esas son las funciones de forma del pórtico: cada barra usa estas mismas 4 curvas. Para llegar a la rigidez, de cada una saco la PENDIENTE (primera derivada) y de ahí la CURVATURA (segunda derivada). El motor deriva paso a paso:
H1' = Diff{1-3*x^2+2*x^3 @ x} @@(pendiente de H₁)
H1'' = Diff{-6*x+6*x^2 @ x} @@(curvatura de H₁)
H2' = Diff{x-2*x^2+x^3 @ x} @@(pendiente de H₂)
H2'' = Diff{1-4*x+3*x^2 @ x} @@(curvatura de H₂)
H3' = Diff{3*x^2-2*x^3 @ x} @@(pendiente de H₃)
H3'' = Diff{6*x-6*x^2 @ x} @@(curvatura de H₃)
H4' = Diff{-x^2+x^3 @ x} @@(pendiente de H₄)
H4'' = Diff{-2*x+3*x^2 @ x} @@(curvatura de H₄)
#: Ya con las curvaturas, la rigidez es cada una por la otra, integrada:  K_ij = EI·∫ H_i'' · H_j'' dx. El motor integra los productos (con L=1) y da los coeficientes:
k11 = Area{(-6+12*x)^2 @ x=0:1} @@(H₁''·H₁'')
k12 = Area{(-6+12*x)*(-4+6*x) @ x=0:1} @@(H₁''·H₂'')
k22 = Area{(-4+6*x)^2 @ x=0:1} @@(H₂''·H₂'')
#: Dan 12, 6, 4 (así salen todos). El factor EI es la rigidez del material; las potencias de L las fija la UNIDAD de cada término: desplazamiento–desplazamiento va con EI/L³, desplazamiento–giro con EI/L², giro–giro con EI/L. Con eso se arma la matriz de barra (filas/columnas = GDL [v₁, θ₁, v₂, θ₂]) — simbólica = numérica (EI=1, L=1):
K_barra = (EI/L^3)*[12, 6*L, -12, 6*L; 6*L, 4*L^2, -6*L, 2*L^2; -12, -6*L, 12, -6*L; 6*L, 2*L^2, -6*L, 4*L^2] = [12, 6, -12, 6; 6, 4, -6, 2; -12, -6, 12, -6; 6, 2, -6, 4] @@(rigidez de barra: fórmula y valor)

## 2 · Qué parte usa cada barra del pórtico
#: COLUMNA (base empotrada): en el tope, el desplazamiento transversal es el ladeo Δ y el giro es θ. De la K de barra toma el bloque del extremo 2 (v₂, θ₂):
K_col = [12, -6; -6, 4] @@(columna: Δ y θ del tope)
#: VIGA (los extremos no bajan, solo giran): usa sus dos giros θ_B, θ_C. De la K de barra toma el bloque de los giros (θ₁, θ₂):
K_vig = [4, 2; 2, 4] @@(viga: θ_B y θ_C)

## 3 · Ensamblar: sumar las barras que comparten cada grado de libertad
#: Cada término de la K global es la SUMA de las barras que tocan ese GDL. El motor suma:
kBB = 4 + 4 @@(θ_B: columna izq + viga)
kCC = 4 + 4 @@(θ_C: columna der + viga)
kBC = 2 @@(θ_B con θ_C: solo la viga)
kDD = 12 + 12 @@(Δ: las dos columnas)
kBD = -6 @@(θ_B con Δ: la columna izq)
#: Con esas sumas se arma la K del pórtico (los kBB=8, kDD=24 son las sumas de arriba):
K_portico = [8, 2, -6; 2, 8, -6; -6, -6, 24] @@(rigidez del pórtico)
#: No es un dato mágico: es el ensamblaje de las K de barra. Y cada K de barra son las funciones de forma integradas. Ahí están las funciones de forma del pórtico: escondidas en cada barra.

## 4 · Resolver
F = [0; 0; 1] @@(carga lateral H en Δ)
Kinv = K_portico^-1 @@(flexibilidad)
u = Kinv*F @@(u = [θ_B ; θ_C ; Δ])
#framedef(5/84, 1/28, 1/28)
#: Da θ_B = θ_C = 1/28 y Δ = 5/84 — el mismo resultado, pero ahora se ve TODO el camino: funciones de forma → K de barra → ensamblaje → K del pórtico → solución → deformada.
