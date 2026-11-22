# How the stiffness matrix of a closed program is measured
#: ETABS does not show its matrix. But it lets you **push and measure**, and that is enough: the whole thing can be deduced. Here is the algebra, derived by the engine.
#> Método: reconstrucción por flexibilidad. Es el mismo que sacó γ = 0.400 de la membrana de ETABS.

## 1 · The idea: push and see how much it moves
#: The structure's equation relates stiffness, displacement and load. If I push with a **unit** load on a single degree of freedom, the displacement I read **is an entire column** of the inverse of the stiffness:
u_j = Inverse{K_g}·e_j @@(1.1 carga unidad en el grado j)
#: Putting f with a 1 at degree j and 0 elsewhere, `u` **is column j** of the inverse. Repeating for each free degree fills the whole matrix. That inverse is called the **flexibility**:
F_flex = Inverse{K_g} @@(1.2 la flexibilidad ES la inversa de la rigidez)
K_medida = Inverse{F_med} @@(1.3 y se invierte de vuelta la MEDIDA)
#: That is the whole trick: **there is no need to look inside the program**. You give it known inputs and read outputs.

## 2 · Why you must restrain before pushing
#: A loose element floats: it can translate and rotate without deforming. Those motions **cost no energy**, so the stiffness sends them to zero and the matrix **cannot be inverted**. In a plate there are three:
w_rigido = a + b*x + c*y @@(2.1 los 3 modos de sólido rígido)
#: Three degrees are restrained —exactly those three— and the rest stay free. The free-free part **is** invertible, and it is the one that is measured.

## 3 · Recovering the rows that were not measured
#: When three degrees are restrained, those rows and columns are lost. They are **not invented**: they come from the fact that the stiffness times a rigid motion gives zero. Splitting the equation into free (f) and restrained (r):
cero = K_ff*R_f + K_fr*R_r @@(3.1 rigidez por sólido rígido = 0)
K_fr = -K_ff*R_f*Inverse{R_r} @@(3.2 despejando lo que falta)
#: And it is checked: if the reconstructed matrix multiplied by the rigid modes gives zero, it is right. Measured: it comes out **1e-15**.

## 4 · Separating the terms: the part that did NOT work
#: The plate constitutive law splits the stiffness into three terms with weights that depend on ν:
peso_1 = 1 @@(4.1 directos)
peso_2 = nu @@(4.2 acoplado)
peso_3 = (1 - nu)/2 @@(4.3 torsión)
#: The idea was to measure with several ν and solve for the three. **It cannot be done**, and the engine shows it: the third weight is a linear combination of the other two.
combinacion = Simplify{(1 - nu)/2 - (1/2 - nu/2)} @@(4.4 ¿son independientes?)
#: It gives **zero**: the third weight IS 1/2 minus ν/2. The columns of the system are dependent, there are infinitely many solutions and the fit returns any one of them. That is why absurd values came out.

## 5 · The route that does separate: the modifiers
#: ETABS lets you multiply **each term separately** (M11MOD, M22MOD, M12MOD). The stiffness is **linear** in them:
K_mod = m11*A11 + m22*A22 + m12*A12 @@(5.1 lineal en los modificadores)
#: Now the weights **are** independent: one is varied and the others stay still. With four measurements the three pieces are solved.
#: ⚠️ And none is set to **zero**: that would leave the plate with no stiffness in that direction and the model would be a mechanism. They are **raised** from 1 to 2, which separates just as well and breaks nothing.

## 6 · What this method found
#: Comparing the measured matrix against ours, term by term, it turned out that the thin element used the **enclosing rectangle** of the element instead of its real shape. In a square it makes no difference; in a skewed piece it does:
error_paralelogramo = 37.02 @@(6.1 % antes)
error_trapecio = 44.30 @@(6.2 % antes)
error_corregido = 0.000000001 @@(6.3 % después, con el jacobiano real)
#: The fault was **not visible** when measuring only squares and rectangles, which are exactly the two shapes where it does not appear.
