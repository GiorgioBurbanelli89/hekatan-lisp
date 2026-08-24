# El pórtico: de dónde sale la K (ensamblaje desde las barras)
#: En el ejemplo del pórtico la matriz K apareció ya armada. Aquí se ve de dónde sale: se ENSAMBLA de las K de cada barra, que a su vez vienen de las funciones de forma. Todo con el motor.

## 1 · Las FUNCIONES DE FORMA de cada barra (aquí están, dibujadas)
#: Cada barra del pórtico (columna o viga) interpola su deformación con las 4 funciones de forma de Hermite — son los "pesos" de sus dos extremos (desplazamiento v y giro θ). Estas son:
H1 = 1-3*x^2+2*x^3 @@(peso de v₁)
H2 = x-2*x^2+x^3 @@(peso de θ₁)
H3 = 3*x^2-2*x^3 @@(peso de v₂)
H4 = -x^2+x^3 @@(peso de θ₂)
#fplot(H1, H2, H3, H4, [0 1])
#: Esas son las funciones de forma del pórtico: cada barra usa estas mismas 4 curvas. Para llegar a la rigidez, de cada una saco la PENDIENTE (primera derivada) y de ahí la CURVATURA (segunda derivada). El motor deriva paso a paso:
H1p = Diff{1-3*x^2+2*x^3 @ x} @@(H₁' pendiente)
H1pp = Diff{-6*x+6*x^2 @ x} @@(H₁'' curvatura)
H2p = Diff{x-2*x^2+x^3 @ x} @@(H₂' pendiente)
H2pp = Diff{1-4*x+3*x^2 @ x} @@(H₂'' curvatura)
H3p = Diff{3*x^2-2*x^3 @ x} @@(H₃' pendiente)
H3pp = Diff{6*x-6*x^2 @ x} @@(H₃'' curvatura)
H4p = Diff{-x^2+x^3 @ x} @@(H₄' pendiente)
H4pp = Diff{-2*x+3*x^2 @ x} @@(H₄'' curvatura)
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
