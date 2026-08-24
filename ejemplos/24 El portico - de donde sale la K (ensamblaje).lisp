# El pórtico: de dónde sale la K (ensamblaje desde las barras)
#: En el ejemplo del pórtico la matriz K apareció ya armada. Aquí se ve de dónde sale: se ENSAMBLA de las K de cada barra, que a su vez vienen de las funciones de forma. Todo con el motor.

## 1 · La K de cada barra viene de las funciones de forma
#: Deducida integrando las curvaturas de las Hermite (ejemplo anterior). Sus filas y columnas son los grados de libertad de la barra: desplazamiento y giro en cada extremo [v₁, θ₁, v₂, θ₂]:
K_barra = [12, 6, -12, 6; 6, 4, -6, 2; -12, -6, 12, -6; 6, 2, -6, 4] @@(rigidez de barra)

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
