# The deformed shape of a frame — Hermite functions (how a deformed beam is drawn)
#: A **frame** (beam-column) does not use the straight line of simple 1D. For **bending** it uses **Hermite cubic** polynomials. And those same cubics are the ones that draw the **curve** of the deformed beam you see on screen. The engine derives them.

## 1 · Why a cubic? The beam equation imposes it
#: A loaded beam **bends**. And it does not bend in a straight line: it takes a **smooth curve**. Which curve, exactly? Always the same: a **cubic** (a polynomial of degree 3). Here you see where it comes from, step by step and with drawings. Think of this beam —fixed at the left, with a load at the tip—:
#beam(fixed-free, P@1)
#: The law of a beam in bending is **EI·v⁗ = w** (w = the load on it). Between two nodes, if the load is applied AT the nodes, in the middle there is **no load → v⁗ = 0**. Solving that equation means **integrating four times**. And here is the key: **each integral raises the degree by one**. Look at it, with the shape the curve takes:
#: **First** integral: from zero comes a **constant** (the shear V, the same along the whole span). Its graph is a flat line:
V = Integral{0 @ x}
#fplot(1, [0 1])
#: **Second**: that constant is integrated into a **straight line** (the moment M, which rises linearly):
M = Integral{c1 @ x}
#fplot(x, [0 1])
#: **Third**: the line is integrated into a **parabola** (the rotation, i.e. the slope of the beam):
pend = Integral{c1*x + c2 @ x}
#fplot(x^2, [0 1])
#: **Fourth**: the parabola is integrated into a **cubic** (the deflection: the curve the beam really takes when bending):
defl = Integral{c1*x^2/2 + c2*x + c3 @ x}
#fplot(x^3, [0 1])
#: The whole path is **constant → line → parabola → cubic**. You started from zero and, in four integrals, arrived at a degree-3 polynomial with four constants. That cubic **approximates nothing**: it is the EXACT shape of a beam with no load between nodes. That is why the program draws the **real** deformed shape, not two broken straight lines.

## 2 · The bending degrees of freedom (2 nodes → 4)
#: And those four constants fit exactly with the element's degrees of freedom. At each end the beam has TWO things: the displacement **v** and the rotation **θ** (the slope). Two nodes → **4 data**: v₁, θ₁, v₂, θ₂. That is why the polynomial needs **4 terms** —the cubic, with the same structure that came out of integrating the equation:
v(x) = c_1 + c_2*x + c_3*x^2 + c_4*x^3 @@(cúbica: 4 constantes = 4 GDL)
base = [1 x x^2 x^3] @@(la base cúbica)

## 3 · C is born: I evaluate v and its slope v′ at the 2 nodes
#: All symbolic, with the length {L} as a letter (not {L}=1). The rows come from evaluating the displacement **v** and the slope **v′ = dv/dx** at x=0 and x={L}. At x=0 only the constants survive; at x={L} the powers of {L} appear:
#|  v(0)=c₁ → [1 0 0 0]   ·   v′(0)=c₂ → [0 1 0 0]
#|  v(L) → [1 L L² L³]   ·   v′(L) → [0 1 2L 3L²]
C = [1, 0, 0, 0; 0, 1, 0, 0; 1, L, L^2, L^3; 0, 1, 2*L, 3*L^2] @@(C: v y v′ en los 2 nudos)

## 4 · How a matrix is inverted — the method in 2×2
#: Before inverting the 4×4 C, let us see the full method on a generic 2×2, with ALL the algebraic operations in view. For a matrix A2 with entries a₁₁, a₁₂, a₂₁, a₂₂:
A2 = [a11, a12; a21, a22]
#: The **determinant** is the product of the diagonal minus that of the other one (a scalar):
detA = det(A2)
#: The **adjugate** swaps the diagonal and changes the sign of the other diagonal (a matrix):
adjA = adj(A2)
#: And the **inverse** is the adjugate multiplied by the scalar 1/det (matrix × scalar):
Ainv = adj(A2) * (1/det(A2))
#: There are the three operations: the determinant {detA} (products and one subtraction), the adjugate (reordering with signs), and the inverse = (1/det)·adjugate (scalar times matrix).

## 5 · That same method, applied to the 4×4 C
#: The engine applies EXACTLY that to C. The determinant, by cofactor expansion, comes out {L}⁴:
detC = det(C)
#: The adjugate —the transpose of the cofactor matrix (each cofactor is the signed determinant of a 3×3 submatrix)—:
adjC = adj(C)
#: And the inverse is the adjugate times the scalar 1/{L}⁴; there the powers of 1/{L} appear:
Cinv = adj(C) * (1/det(C)) @@(C⁻¹ = adj(C)/det(C))

## 6 · The Hermite shape functions: N = basis · C⁻¹
N = base*Cinv
#: It gives the Hermite functions written with the real length {L}: H₁ = 1−3(x/L)²+2(x/L)³, H₂ = x−2x²/L+x³/L², H₃ = 3(x/L)²−2(x/L)³, H₄ = −x²/L+x³/L². With {L}=1 the classical ones are recovered.

## 7 · The 4 Hermite cubics, one by one
#: Each column of {N} is a shape function, written with the real length {L}. H₁ and H₃ weight the **displacements** (v₁, v₂); H₂ and H₄ the **rotations** (θ₁, θ₂). Each one equals 1 at its own degree of freedom and 0 at the others:
H1 = 1 - 3*x^2/L^2 + 2*x^3/L^3 @@(peso de v₁)
H2 = x - 2*x^2/L + x^3/L^2 @@(peso de θ₁)
H3 = 3*x^2/L^2 - 2*x^3/L^3 @@(peso de v₂)
H4 = -x^2/L + x^3/L^2 @@(peso de θ₂)

## 8 · The deformed shape: the curved beam
#: The program solves the structure and obtains only the values at the **ends**: v₁, θ₁, v₂, θ₂. The **curve** between nodes is the combination of the four Hermite functions weighted by those values:
#|  v(x) = H₁·v₁ + H₂·θ₁ + H₃·v₂ + H₄·θ₂
#: That smooth curve —the Hermite cubic— is exactly what the program draws for the deformed beam. They are not two straight lines between nodes: it is the cubic.

## 9 · The beam stiffness matrix K
#: With the shape functions ready, the stiffness comes from the bending energy. The curvature (the bending strain) is the SECOND derivative of the deflection, B = d²N/dx². First the curvature of each Hermite function:
d2H1 = Diff{Diff{H1 @ x} @ x}
d2H2 = Diff{Diff{H2 @ x} @ x}
d2H3 = Diff{Diff{H3 @ x} @ x}
d2H4 = Diff{Diff{H4 @ x} @ x}
#: The strain vector B gathers the four curvatures:
B = [d2H1, d2H2, d2H3, d2H4]
#: The operation K = ∫EI·Bᵀ·B dx has three algebraic steps. **First**, the transpose of B: the column Bᵀ (the same curvatures, vertical):
Bt = transpose(B)
#: **Second**, the product Bᵀ·B: a 4×4 matrix where each term is the product of two curvatures (Hᵢ''·Hⱼ''). This is the algebraic core of the stiffness:
P = Bt * B
#: **Third**, it is scaled by EI and each term of that 4×4 is integrated from 0 to {L}. When integrating those polynomials the {x} disappears and only {L} and EI remain:
K = Area{EI * transpose(B)*B @ x = 0:L}
#: That is the CLASSICAL beam stiffness matrix: 12EI/L³, 6EI/L², 4EI/L, 2EI/L… derived symbol by symbol: transpose, multiply Bᵀ·B, integrate. It is the one every structural program assembles.

## 10 · The complete cycle: from K to the DRAWN deformed shape
#: Careful not to confuse two things. **K is not the drawing**: it is the tool to SOLVE. The program assembles K, solves **K·d = F** (forces = stiffness × displacements) and obtains the nodal values: d = (v₁, θ₁, v₂, θ₂). Only with those values do the **same Hermite functions** draw the curve:
#|  v(x) = H₁·v₁ + H₂·θ₁ + H₃·v₂ + H₄·θ₂
#: Example: one end fixed (v₁=0, θ₁=0) and the other rises one unit without rotating (v₂=1, θ₂=0). We insert those values:
v1 = 0
th1 = 0
v2 = 1
th2 = 0
#: The deformed shape is the combination of the Hermite functions with those values —only H₃ survives—:
defo = H1*v1 + H2*th1 + H3*v2 + H4*th2
#: And THAT is the curve drawn on screen (with {L}=1): the bent beam. Not two straight lines: the cubic.
#fplot(3*x^2 - 2*x^3, [0 1])
#: The whole cycle, closed: beam equation → cubic → Hermite functions → curvatures → **K** → solve K·d=F → nodes → **drawn deformed shape**. The same four functions serve to assemble the stiffness (differentiated twice) and to draw the curve (used directly).

## 11 · Since when has it been done this way?
#: · The **Hermite** cubics are mathematics from ~1870 (interpolation with value AND slope).
#: · The **beam stiffness matrix** (with these functions) was formalized in the **matrix structural analysis of the 1950s**, and the direct stiffness method around **1959**.
#: · **Drawing the deformed shape** with these functions on the computer has been standard since the **programs of the 1970s** (the SAP lineage, Berkeley), from which today's programs descend.
