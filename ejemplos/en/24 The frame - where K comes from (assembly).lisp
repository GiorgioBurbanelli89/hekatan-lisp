# The frame: where K comes from (assembly from the members)
#: In the frame example the matrix K appeared already assembled. Here we see where it comes from: it is ASSEMBLED from the K of each member, which in turn come from the shape functions. All with the engine.

## 1 · Where the SHAPE FUNCTIONS come from (the heart of it)
#: A shape function is the **WEIGHT** of a datum at the tip: it says how much that datum governs the curve the member takes in the middle. At the tips there are 4 data — how much each end DROPS (v) and how much it ROTATES (v') — so there are 4 weights. The reasoning to find them, step by step:

#: **1) The member bends as a cubic.** Why those 4 ingredients (1, x, x², x³)? For two reasons that fall together. **Counting:** at the tips I know 4 data, so I need 4 independent "knobs" to force them; the simplest are the powers, one per degree — **1** sets the level, **x** the slope, **x²** a curve, **x³** a curve that changes. Each does something the others cannot. **Physics:** a beam in bending bends exactly as a cubic (linear moment → linear curvature → two integrations → cubic deflection). The 4 ingredients are the basis; any cubic is a mix of these four:
base = [1 x x^2 x^3] @@(los 4 ingredientes de la cúbica)
#fplot(1, x, x^2, x^3, [0 1])

#: **2) The adjustments a₀…a₃ are not physical; the data at the tips ARE.** To go from one to the other, I evaluate the cubic (gives v) and its SLOPE (gives v') at the two ends, x=0 and x=1. The engine gets the slope:
wd = Diff{a0 + a1*x + a2*x^2 + a3*x^3 @ x} @@(pendiente de la cúbica general)
#: I put x=0 and x=1 into the cubic and into that slope. Each evaluation is a ROW: it says which mix of adjustments gives that datum. The 4 rows are the matrix **C**:
C = [1 0 0 0; 0 1 0 0; 1 1 1 1; 0 1 2 3] @@(fila1=v(0), fila2=v'(0), fila3=v(1), fila4=v'(1))

#: **3) I turn it around.** The data = C·adjustments, so the adjustments = C⁻¹·data. And the deformed shape = basis·adjustments = basis·C⁻¹·data. That **basis·C⁻¹** is what multiplies each datum: they are the weights. There they are born:
Cinv = C^-1 @@(C⁻¹: de los datos a los ajustes)
N = base*Cinv @@(N = base·C⁻¹ = los 4 pesos = las funciones de forma)

#: **4) What those weights are (the key).** Each weight equals **1** at its own datum and **0** at the other 3. That is why it is the "weight" of that datum. I name them (columns of N) and draw them:
H1 = 1-3*x^2+2*x^3 @@(peso de v₁)
H2 = x-2*x^2+x^3 @@(peso de θ₁)
H3 = 3*x^2-2*x^3 @@(peso de v₂)
H4 = -x^2+x^3 @@(peso de θ₂)
#fplot(1-3*x^2+2*x^3, x-2*x^2+x^3, 3*x^2-2*x^3, -x^2+x^3, [0 1])
#: Look at the blue one (H₁, weight of v₁): it starts at 1 and goes down to 0. The green one (H₃, weight of v₂): it rises from 0 to 1. Each one governs ITS datum and vanishes at the other three.

#: **5) The real deformed shape is the mix.** The 4 weights are added, each times its datum. Example: it drops 1 on the left and 0.5 on the right (rotations 0):
w = 1*H1 + 0.5*H3 @@(deformada = v₁·H₁ + v₂·H₃, con v₁=1, v₂=0.5)
#fplot(1-1.5*x^2+x^3, [0 1])
#: That is the whole heart of it: a cubic is assumed → its adjustments are tied to the data at the tips (matrix C) → it is inverted (C⁻¹) → basis·C⁻¹ = the weights. FEM is exactly this.
#: Those are the shape functions of the frame: each member uses these same 4 curves. To get to the stiffness, from each one I take the SLOPE (first derivative) and from that the CURVATURE (second derivative). The engine differentiates step by step:
H1' = Diff{1-3*x^2+2*x^3 @ x} @@(pendiente de H₁)
H1'' = Diff{-6*x+6*x^2 @ x} @@(curvatura de H₁)
H2' = Diff{x-2*x^2+x^3 @ x} @@(pendiente de H₂)
H2'' = Diff{1-4*x+3*x^2 @ x} @@(curvatura de H₂)
H3' = Diff{3*x^2-2*x^3 @ x} @@(pendiente de H₃)
H3'' = Diff{6*x-6*x^2 @ x} @@(curvatura de H₃)
H4' = Diff{-x^2+x^3 @ x} @@(pendiente de H₄)
H4'' = Diff{-2*x+3*x^2 @ x} @@(curvatura de H₄)
#: With the curvatures in hand, the stiffness is each one times the other, integrated:  K_ij = EI·∫ H_i'' · H_j'' dx. The engine integrates the products (with L=1) and gives the coefficients:
k11 = Area{(-6+12*x)^2 @ x=0:1} @@(H₁''·H₁'')
k12 = Area{(-6+12*x)*(-4+6*x) @ x=0:1} @@(H₁''·H₂'')
k22 = Area{(-4+6*x)^2 @ x=0:1} @@(H₂''·H₂'')
#: They give 12, 6, 4 (that is how they all come out). The factor EI is the material stiffness; the powers of L are set by the UNIT of each term: displacement–displacement goes with EI/L³, displacement–rotation with EI/L², rotation–rotation with EI/L. With that the member matrix is assembled (rows/columns = DOF [v₁, θ₁, v₂, θ₂]) — symbolic = numeric (EI=1, L=1):
K_barra = (EI/L^3)*[12, 6*L, -12, 6*L; 6*L, 4*L^2, -6*L, 2*L^2; -12, -6*L, 12, -6*L; 6*L, 2*L^2, -6*L, 4*L^2] = [12, 6, -12, 6; 6, 4, -6, 2; -12, -6, 12, -6; 6, 2, -6, 4] @@(rigidez de barra: fórmula y valor)

## 2 · Which part each member of the frame uses
#: COLUMN (fixed base): at the top, the transverse displacement is the sway Δ and the rotation is θ. From the member K it takes the block of end 2 (v₂, θ₂):
K_col = [12, -6; -6, 4] @@(columna: Δ y θ del tope)
#: BEAM (the ends do not drop, they only rotate): it uses its two rotations θ_B, θ_C. From the member K it takes the block of the rotations (θ₁, θ₂):
K_vig = [4, 2; 2, 4] @@(viga: θ_B y θ_C)

## 3 · Assemble: add the members that share each degree of freedom
#: Each term of the global K is the SUM of the members that touch that DOF. The engine adds:
kBB = 4 + 4 @@(θ_B: columna izq + viga)
kCC = 4 + 4 @@(θ_C: columna der + viga)
kBC = 2 @@(θ_B con θ_C: solo la viga)
kDD = 12 + 12 @@(Δ: las dos columnas)
kBD = -6 @@(θ_B con Δ: la columna izq)
#: With those sums the frame K is assembled (kBB=8, kDD=24 are the sums above):
K_portico = [8, 2, -6; 2, 8, -6; -6, -6, 24] @@(rigidez del pórtico)
#: It is not a magic datum: it is the assembly of the member K's. And each member K is the integrated shape functions. There are the frame's shape functions: hidden in each member.

## 4 · Solve
F = [0; 0; 1] @@(carga lateral H en Δ)
Kinv = K_portico^-1 @@(flexibilidad)
u = Kinv*F @@(u = [θ_B ; θ_C ; Δ])
#framedef(5/84, 1/28, 1/28)
#: It gives θ_B = θ_C = 1/28 and Δ = 5/84 — the same result, but now the WHOLE path is visible: shape functions → member K → assembly → frame K → solution → deformed shape.
