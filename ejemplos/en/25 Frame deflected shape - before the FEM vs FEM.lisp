# Deflected shape of a frame: how it was drawn BEFORE the FEM vs with the FEM
#: The same curve by both routes. **Before** (classical) the elastic curve of each member was integrated. **Now** (FEM) the shape functions already carry that integration. Same result, same plot. All with the engine.

## 0 · The problem — and where the displacements come from
#: Single-bay frame, columns and beam of equal length, fixed bases, lateral load H at corner B. The problem data (first the variables, then they are substituted):
EI = 1 @@(rigidez de flexión del material)
L = 1 @@(longitud de cada barra)
#frame(fixed-fixed, H)
#: There are 3 unknowns: the rotation of each corner (θ_B, θ_C) and the sway of the floor (Δ). They come from the stiffness equation K·u = F, that is u = K⁻¹·F. And where does K come from? It is ASSEMBLED from the members. Each member has its flexural stiffness — in SYMBOLS (EI, L), and on the right with the values above (derived from the shape functions in example 24):
K_barra = (EI/L^3)*[12, 6*L, -12, 6*L; 6*L, 4*L^2, -6*L, 2*L^2; -12, -6*L, 12, -6*L; 6*L, 2*L^2, -6*L, 4*L^2] @@(rigidez de barra: símbolo = valor)
#: At each degree of freedom the members that touch it are ADDED (those 4, 12, 2, 6 are entries of K_member). The rotation θ_B is shared by the beam and the left column; the sway Δ is pushed by both columns; θ_B–θ_C is the beam only; rotation–sway is the column:
kBB = 4 + 4 @@(θ_B: viga + columna izq)
kCC = 4 + 4 @@(θ_C: viga + columna der)
kDD = 12 + 12 @@(Δ: las dos columnas)
K = [kBB, 2, -6; 2, kCC, -6; -6, -6, kDD] @@(K del pórtico, ensamblada de las barras)
F = [0; 0; 1] @@(la carga H va en el ladeo Δ)
u = K^-1 * F @@(u = K⁻¹·F = [θ_B ; θ_C ; Δ])
#: From that vector I take each displacement (a selector row × u picks out the component):
theta_B = [1 0 0]*u @@(giro esquina izquierda)
theta_C = [0 1 0]*u @@(giro esquina derecha)
Delta = [0 0 1]*u @@(ladeo del tope)
#: With that data we have to DRAW the curve each member takes between its nodes.

## 1 · BEFORE the FEM — integrating the elastic curve (classical)
#: Where does it start? From the physics of the member. A span WITHOUT load satisfies EI·v'''' = 0 (nothing bends it further). Integrating that equation four times —each ∫ raises one degree: 0 → constant → line → parabola → cubic— the deflection v(x) ends up as a CUBIC with 4 constants. Its ingredients:
base = [1 x x^2 x^3] @@(v = a·base = una cúbica)
#: The 4 constants are fixed with the 4 data at the ENDS of the member. The left column: fixed at the bottom (v=0, θ=0) and at the top with the sway Δ and the rotation θ_B. From the global u I select those 4:
u_col = [0 0 0; 0 0 0; 0 0 1; 1 0 0]*u @@(v,θ abajo=0 · arriba Δ=u₃, θ_B=u₁)
#: Putting those 4 data into the cubic and its slope builds the system C·a = u_col. Solving for the constants:
C = [1 0 0 0; 0 1 0 0; 1 1 1 1; 0 1 2 3] @@(las 4 condiciones de los extremos)
a = C^-1 * u_col @@(a = C⁻¹·u_col)
v_clasico = base*a @@(la deformada de la columna)
#: That cubic is the curve the column takes. Plotted:
#fplot(x^2/7 - x^3/12, [0 1])
#: Is it really an unloaded member? Check it: differentiate the deflection to the curvature (2nd derivative) and it must come out LINEAR. The engine differentiates:
vp = Diff{x^2/7 - x^3/12 @ x} @@(pendiente = v')
curv = Diff{2*x/7 - x^2/4 @ x} @@(curvatura = v'' → sale LINEAL)
#: And the other way around — the double integration of the elastic curve that used to be done BY HAND: I integrate that curvature twice, with the fixed base (slope and deflection are 0 at the bottom → constants 0), and I RECOVER the same deflection:
pend = Integral{2/7 - x/2 @ x} @@(∫ curvatura = pendiente)
flecha = Integral{2*x/7 - x^2/4 @ x} @@(∫ pendiente = la misma flecha)
#: The laborious part of the classical method: this had to be redone member by member, each with its own u.

## 2 · WITH the FEM — shape functions (no integration per member)
#: The Hermite functions ARE ALREADY the solution of EI·v''''=0 with unit boundary data: the integration was done ONCE, for good. The deflected shape of the member is N·u = each datum times its weight. In the column the two nonzero data are Δ (weight H₃) and θ (weight H₄):
H3 = 3*x^2-2*x^3 @@(peso del desplazamiento del tope)
H4 = -x^2+x^3 @@(peso del giro del tope)
v_fem = H3*Delta + H4*theta_B @@(deformada FEM = H₃·Δ + H₄·θ)
#: It gives the SAME cubic as the classical method. Plotted (identical):
#fplot(x^2/7 - x^3/12, [0 1])

## 3 · The deflected shape of the whole frame
#: Each member is drawn with its cubic; together they give the deflected shape of the frame (dotted = undeformed):
#framedef(5/84, 1/28, 1/28)
#: The classical method integrated the elastic curve of EACH member by hand; the FEM reuses the same 4 shape functions and only does N·u. Same drawing. The FEM is that double integration done once and stored in the Hermite functions.
