# The shape functions of the slab: what they are and where their derivatives come from
#: The Calcpad sheet **Rectangular Slab FEA** opens with a three-column table: the **basis functions**, their **first derivatives** and their **second derivatives**. Here we explain what each column is, why in some the side a_{1} appears dividing and in others it does not, and what each one is for.
#: **The idea in one line.** Between two nodes the slab bends like a **cubic**. A cubic has four coefficients, and at the two nodes there are four data: the deflection and the rotation of each. Four data, four functions.
#: **How it is checked.** The engine differentiates each function and subtracts the formula from the Calcpad table. If the table is right, the subtraction gives zero.

## 1 · The element, drawn with the CAD tool
#: The element is a rectangle of sides a_{1} and b_{1} with a node at each corner. It is drawn in the **drawing window**: with the "Draw / Edit" button below the drawing it is opened, the rectangle is stretched and saved in the sheet. The numbers of point 8 are recomputed with the new side.
#dibujar(elemento, ancho = 120, alto = 70, ud = m, cuadricula = 0.25)
;; dibujado con la ventana ✏ — 1 entidad (listas DXF de AutoLISP: se reescribe al guardar)
(entmake '((0 . "LAYER") (100 . "AcDbSymbolTableRecord") (100 . "AcDbLayerTableRecord") (2 . "ELEMENTO") (70 . 0) (62 . 5) (6 . "CONTINUOUS")))
(entmake '((0 . "LWPOLYLINE") (100 . "AcDbEntity") (8 . "ELEMENTO") (100 . "AcDbPolyline") (90 . 4) (70 . 1) (10 0.0 0.0) (10 2.0 0.0) (10 2.0 1.0) (10 0.0 1.0)))
#fin
#: The block below **reads** that rectangle, measures its two sides (l_{a} and l_{b}) and puts on it the nodes, the dimensions and the two axes of the element:
#autolisp("The element read from the drawing: four nodes and two axes", ancho = 130, alto = 85, exporta = l_a l_b)
(setq S (primera "ELEMENTO" "LWPOLYLINE"))
(setq l_a (ancho S) l_b (alto S))
(setq la l_a lb l_b)
(capa "NUDOS" :color 1)
(circulo (list 0 0) (* 0.03 lb))
(circulo (list la 0) (* 0.03 lb))
(circulo (list la lb) (* 0.03 lb))
(circulo (list 0 lb) (* 0.03 lb))
(texto (list (* -0.09 lb) (* -0.12 lb)) "1" :altura (* 0.09 lb))
(texto (list (+ la (* 0.04 lb)) (* -0.12 lb)) "2" :altura (* 0.09 lb))
(texto (list (+ la (* 0.04 lb)) (+ lb (* 0.04 lb))) "3" :altura (* 0.09 lb))
(texto (list (* -0.09 lb) (+ lb (* 0.04 lb))) "4" :altura (* 0.09 lb))
(capa "EJES DEL ELEMENTO" :color 3)
(linea (list 0 0) (list (* 0.45 la) 0) :grosor 0.5)
(linea (list (* 0.45 la) 0) (list (- (* 0.45 la) (* 0.08 lb)) (* 0.04 lb)) :grosor 0.5)
(linea (list (* 0.45 la) 0) (list (- (* 0.45 la) (* 0.08 lb)) (* -0.04 lb)) :grosor 0.5)
(linea (list 0 0) (list 0 (* 0.6 lb)) :grosor 0.5)
(linea (list 0 (* 0.6 lb)) (list (* 0.04 lb) (* 0.52 lb)) :grosor 0.5)
(linea (list 0 (* 0.6 lb)) (list (* -0.04 lb) (* 0.52 lb)) :grosor 0.5)
(formula (list (* 0.46 la) (* 0.04 lb)) "ξ" :altura (* 0.1 lb) :color 3)
(formula (list (* 0.05 lb) (* 0.6 lb)) "η" :altura (* 0.1 lb) :color 3)
(capa "COTAS" :color 8)
(cota (list 0 0) (list la 0) :sep (* -0.3 lb) :texto "a₁")
(cota (list la 0) (list la lb) :sep (* -0.3 lb) :texto "b₁")
#fin
#: At each node the slab has the **deflection** w (how much it goes down) and the **rotations** (how much it tilts). Along side a, between node 1 and node 2, that is four data: w_{1}, θ_{1}, w_{2}, θ_{2}.

## 2 · The coordinate ξ: the side measured from 0 to 1
#: Instead of measuring in meters it is measured as a **fraction of the side**: ξ = x / a_{1}, the distance to node 1 divided by the side.
#: ξ is 0 at node 1, 0.5 at the center and 1 at node 2. **Why:** this way the formulas are the same for a 0.5 m element and for a 3 m one. The real size enters only once, with a_{1}.

## 3 · The four basis functions
#: They are those of the first column of the table:
Φ_1a(ξ) = 1 - ξ^2*(3 - 2*ξ)
Φ_2a(ξ) = ξ*a_1*(1 - ξ*(2 - ξ))
Φ_3a(ξ) = ξ^2*(3 - 2*ξ)
Φ_4a(ξ) = ξ^2*a_1*(-1 + ξ)
#| Función | Dato que multiplica | Qué dibuja |
#|---|---|---|
#| Φ_{1a} | la flecha del nudo 1 | el nudo 1 baja 1 |
#| Φ_{2a} | el giro del nudo 1 | el nudo 1 gira 1 |
#| Φ_{3a} | la flecha del nudo 2 | el nudo 2 baja 1 |
#| Φ_{4a} | el giro del nudo 2 | el nudo 2 gira 1 |
#: The deflection at any point is the sum of the four, each times its datum: w(ξ) = w_{1}·Φ_{1a} + θ_{1}·Φ_{2a} + w_{2}·Φ_{3a} + θ_{2}·Φ_{4a}. It is the same idea as y = m·x + b, with four terms instead of two.
#: **Check at the nodes.** On the left node 1 (ξ = 0), on the right node 2 (ξ = 1). The two deflection functions are 1 at their node and 0 at the other:
Φ_1a(0); Φ_1a(1)
Φ_3a(0); Φ_3a(1)
#: The two rotation functions have **slope** 1 at their node and 0 at the other (the slope in meters: that of ξ divided by a_{1}, as explained in point 5):
giro_21 = Simplify{Slope{Φ_2a(ξ) @ ξ = 0}*(1/a_1)} 'Φ_2a at node 1
giro_22 = Simplify{Slope{Φ_2a(ξ) @ ξ = 1}*(1/a_1)} 'Φ_2a at node 2
giro_41 = Simplify{Slope{Φ_4a(ξ) @ ξ = 0}*(1/a_1)} 'Φ_4a at node 1
giro_42 = Simplify{Slope{Φ_4a(ξ) @ ξ = 1}*(1/a_1)} 'Φ_4a at node 2
#: The four curves, with a_{1} = 1 to see them on the same scale:
#fplot(flecha_nudo_1 = 1 - x^2*(3 - 2*x), giro_nudo_1 = x*(1 - x*(2 - x)), flecha_nudo_2 = x^2*(3 - 2*x), giro_nudo_2 = x^2*(-1 + x), [0 1])

## 4 · Animation: only one datum moves at a time
#: The strip between node 1 and node 2, seen from the side. In each animation **a single datum** grows from 0 to 1 and the other three stay at zero. The blue curve **is** the shape function of that datum. The red stroke at each node is the tangent: it marks the rotation.
#: Each animation starts by itself and repeats. With ⏸ it stops, with the bar the frame is chosen and with 🔊 the value of each frame is heard.

### 4.1 · The deflection of node 1: it draws Φ_{1a}
#: Node 1 rises; node 2 does not move and the two tangents stay horizontal.
#anim(k = 0:0.25:10)
#autolisp("Deflection of node 1 rises", ancho = 130, alto = 110)
(setq d (/ k 10.0))
(capa "SIN DEFORMAR" :color 8 :tipo "trazos")
(linea (list 0 0) (list 1 0))
(capa "DEFORMADA" :color 5)
(curva '(* d (- 1 (* x x (- 3 (* 2 x))))) 0 1 :color 5 :grosor 0.5)
(capa "NUDOS Y TANGENTES" :color 1)
(circulo (list 0 d) 0.02)
(circulo (list 1 0) 0.02)
(linea (list 0 d) (list 0.22 d) :grosor 0.5)
(linea (list 1 0) (list 0.78 0) :grosor 0.5)
(ejes 0 1 -0.25 1 :paso-x 0.25 :paso-y 0.25 :nombre-x "ξ" :nombre-y "w")
#fin
#voz: Flecha del nudo 1: {k} décimas.
#finanim

### 4.2 · The rotation of node 1: it draws Φ_{2a}
#: The tangent at node 1 tilts; no node moves from its place.
#anim(k = 0:0.25:10)
#autolisp("Rotation of node 1 grows", ancho = 130, alto = 110)
(setq d (/ k 10.0))
(capa "SIN DEFORMAR" :color 8 :tipo "trazos")
(linea (list 0 0) (list 1 0))
(capa "DEFORMADA" :color 5)
(curva '(* d x (- 1 (* x (- 2 x)))) 0 1 :color 5 :grosor 0.5)
(capa "NUDOS Y TANGENTES" :color 1)
(circulo (list 0 0) 0.02)
(circulo (list 1 0) 0.02)
(linea (list 0 0) (list 0.22 (* 0.22 d)) :grosor 0.5)
(linea (list 1 0) (list 0.78 0) :grosor 0.5)
(ejes 0 1 -0.25 1 :paso-x 0.25 :paso-y 0.25 :nombre-x "ξ" :nombre-y "w")
#fin
#voz: Giro del nudo 1: {k} décimas.
#finanim

### 4.3 · The deflection of node 2: it draws Φ_{3a}
#: It is that of node 1 seen in a mirror: now node 2 rises.
#anim(k = 0:0.25:10)
#autolisp("Deflection of node 2 rises", ancho = 130, alto = 110)
(setq d (/ k 10.0))
(capa "SIN DEFORMAR" :color 8 :tipo "trazos")
(linea (list 0 0) (list 1 0))
(capa "DEFORMADA" :color 5)
(curva '(* d x x (- 3 (* 2 x))) 0 1 :color 5 :grosor 0.5)
(capa "NUDOS Y TANGENTES" :color 1)
(circulo (list 0 0) 0.02)
(circulo (list 1 d) 0.02)
(linea (list 0 0) (list 0.22 0) :grosor 0.5)
(linea (list 1 d) (list 0.78 d) :grosor 0.5)
(ejes 0 1 -0.25 1 :paso-x 0.25 :paso-y 0.25 :nombre-x "ξ" :nombre-y "w")
#fin
#voz: Flecha del nudo 2: {k} décimas.
#finanim

### 4.4 · The rotation of node 2: it draws Φ_{4a}
#: The curve stays below: to reach node 2 going up, it first has to go down.
#anim(k = 0:0.25:10)
#autolisp("Rotation of node 2 grows", ancho = 130, alto = 110)
(setq d (/ k 10.0))
(capa "SIN DEFORMAR" :color 8 :tipo "trazos")
(linea (list 0 0) (list 1 0))
(capa "DEFORMADA" :color 5)
(curva '(* d x x (- x 1)) 0 1 :color 5 :grosor 0.5)
(capa "NUDOS Y TANGENTES" :color 1)
(circulo (list 0 0) 0.02)
(circulo (list 1 0) 0.02)
(linea (list 0 0) (list 0.22 0) :grosor 0.5)
(linea (list 1 0) (list 0.78 (* -0.22 d)) :grosor 0.5)
(ejes 0 1 -0.25 1 :paso-x 0.25 :paso-y 0.25 :nombre-x "ξ" :nombre-y "w")
#fin
#voz: Giro del nudo 2: {k} décimas.
#finanim
#: **What to look at.** When a deflection rises, the two tangents stay horizontal: the rotations are zero. When a rotation grows, the two nodes do not move from their place: only the tilt at one changes. That is why each datum has its function and they do not mix.

## 5 · First derivative: the slope, which is the rotation
#: The derivative of a curve is its **slope** at each point (the m of y = m·x + b). In the slab the slope of the deflection is the **rotation**.
#: **Why 1/a_{1} appears.** The functions are written in ξ, but the rotation is the slope in meters. Since ξ = x/a_{1}, advancing 1 in ξ is advancing a_{1} meters: the slope in meters is the slope in ξ **divided by a_{1}** (chain rule).
#: **Step 1 · the chain rule.** Φ is written in ξ, and ξ depends on x. The derivative with respect to x is the derivative with respect to ξ times how much ξ changes when x changes: dΦ/dx = dΦ/dξ · dξ/dx. And dξ/dx comes from ξ = x/a_{1}:
ξ_x = Diff{x/a_1 @ x}
#: That is why every derivative in x is the derivative in ξ **multiplied by 1/a_{1}**.
#: **Step 2 · each function, expanded** in powers of ξ (the parentheses are removed):
Φ_1d = Expand{1 - ξ^2*(3 - 2*ξ)}
Φ_2d = Expand{ξ*a_1*(1 - ξ*(2 - ξ))}
Φ_3d = Expand{ξ^2*(3 - 2*ξ)}
Φ_4d = Expand{ξ^2*a_1*(-1 + ξ)}
#: **Step 3 · it is differentiated term by term** with the power rule, d(ξⁿ)/dξ = n·ξⁿ⁻¹: the constant gives 0, ξ gives 1, ξ² gives 2·ξ and ξ³ gives 3·ξ². In Φ_{1a}: 1 → 0, −3·ξ² → −6·ξ, 2·ξ³ → 6·ξ².
dΦ_1 = Diff{1 - 3*ξ^2 + 2*ξ^3 @ ξ}
dΦ_2 = Diff{a_1*ξ - 2*a_1*ξ^2 + a_1*ξ^3 @ ξ}
dΦ_3 = Diff{3*ξ^2 - 2*ξ^3 @ ξ}
dΦ_4 = Diff{a_1*ξ^3 - a_1*ξ^2 @ ξ}
#: **Step 4 · it is multiplied by 1/a_{1}** (step 1). In Φ′_{2a} and Φ′_{4a} the a_{1} they already carried cancels. The engine does the four steps at once, directly on the functions:
Φprime_1a = Simplify{Diff{Φ_1a(ξ) @ ξ}*(1/a_1)}
Φprime_2a = Simplify{Diff{Φ_2a(ξ) @ ξ}*(1/a_1)}
Φprime_3a = Simplify{Diff{Φ_3a(ξ) @ ξ}*(1/a_1)}
Φprime_4a = Simplify{Diff{Φ_4a(ξ) @ ξ}*(1/a_1)}
#: **Why a_{1} does not remain in Φ′_{2a} and Φ′_{4a}.** Those two functions already carried a_{1} as a factor (they are the rotation ones); dividing by a_{1} cancels it. So their slope at the node is exactly 1, which is what a unit rotation must be.
#: **Against the Calcpad table** (second column). On each line, what the engine differentiates minus the table formula:
r_1 = Simplify{Diff{Φ_1a(ξ) @ ξ}*(1/a_1) - (-6*(ξ/a_1)*(1 - ξ))}
r_2 = Simplify{Diff{Φ_2a(ξ) @ ξ}*(1/a_1) - (1 - ξ*(4 - 3*ξ))}
r_3 = Simplify{Diff{Φ_3a(ξ) @ ξ}*(1/a_1) - 6*(ξ/a_1)*(1 - ξ)}
r_4 = Simplify{Diff{Φ_4a(ξ) @ ξ}*(1/a_1) - (-ξ*(2 - 3*ξ))}
#: Four zeros: the second column is the derivative of the first.
#: **Animation: the tangent runs along the curve.** The red line touches Φ_{1a} at the point ξ = n/10. Its inclination is Φ′_{1a} at that point: zero at both nodes and maximum at the center.
#anim fplot(flecha_nudo_1 = 1 - x^2*(3 - 2*x), tangente = 1 - (n/10)^2*(3 - 2*n/10) - 6*(n/10)*(1 - n/10)*(x - n/10), [0 1]), n = 0:0.125:10

## 6 · Second derivative: the curvature, which gives the moment
#: The second derivative says **how much the slope changes**, that is, how much the slab curves. The bending moment is the stiffness times the curvature: where there is no curvature there is no moment. That is why the program needs the third column: with it, it builds the stiffness and then gets the moments.
#: **Why 1/a_{1}² appears.** It is differentiated twice, and each time it is divided by a_{1}.
Φpprime_1a = Simplify{Diff{Diff{Φ_1a(ξ) @ ξ} @ ξ}*(1/a_1^2)}
Φpprime_2a = Simplify{Diff{Diff{Φ_2a(ξ) @ ξ} @ ξ}*(1/a_1^2)}
Φpprime_3a = Simplify{Diff{Diff{Φ_3a(ξ) @ ξ} @ ξ}*(1/a_1^2)}
Φpprime_4a = Simplify{Diff{Diff{Φ_4a(ξ) @ ξ} @ ξ}*(1/a_1^2)}
#: **Against the Calcpad table** (third column):
s_1 = Simplify{Diff{Diff{Φ_1a(ξ) @ ξ} @ ξ}*(1/a_1^2) - (-(6/a_1^2)*(1 - 2*ξ))}
s_2 = Simplify{Diff{Diff{Φ_2a(ξ) @ ξ} @ ξ}*(1/a_1^2) - (-(2/a_1)*(2 - 3*ξ))}
s_3 = Simplify{Diff{Diff{Φ_3a(ξ) @ ξ} @ ξ}*(1/a_1^2) - (6/a_1^2)*(1 - 2*ξ)}
s_4 = Simplify{Diff{Diff{Φ_4a(ξ) @ ξ} @ ξ}*(1/a_1^2) - (-(2/a_1)*(1 - 3*ξ))}
#: **What shape they have.** The second derivative of a cubic is a **line**: inside an element the curvature, and with it the moment, varies along a straight line. That is why a coarse mesh draws the moments in straight segments. With a_{1} = 1:
#fplot(flecha_nudo_1 = -6*(1 - 2*x), giro_nudo_1 = -2*(2 - 3*x), flecha_nudo_2 = 6*(1 - 2*x), giro_nudo_2 = -2*(1 - 3*x), [0 1])

## 7 · The other side: the same with η and b_{1}
#: Along side b the functions are **the same**, with η = y / b_{1} instead of ξ and b_{1} instead of a_{1}. There is nothing new to learn:
Φ_1b(η) = 1 - η^2*(3 - 2*η)
Φ_2b(η) = η*b_1*(1 - η*(2 - η))
Φ_3b(η) = η^2*(3 - 2*η)
Φ_4b(η) = η^2*b_1*(-1 + η)
#: The check of the third column, now with b_{1}:
t_1 = Simplify{Diff{Diff{Φ_1b(η) @ η} @ η}*(1/b_1^2) - (-(6/b_1^2)*(1 - 2*η))}
t_2 = Simplify{Diff{Diff{Φ_2b(η) @ η} @ η}*(1/b_1^2) - (-(2/b_1)*(2 - 3*η))}
t_3 = Simplify{Diff{Diff{Φ_3b(η) @ η} @ η}*(1/b_1^2) - (6/b_1^2)*(1 - 2*η)}
t_4 = Simplify{Diff{Diff{Φ_4b(η) @ η} @ η}*(1/b_1^2) - (-(2/b_1)*(1 - 3*η))}
#: **From four to sixteen.** The slab shape function is the **product** of one in ξ by one in η: four by four, sixteen. The first, Φ_{1a}·Φ_{1b}, is 1 at node 1 (lower left) and 0 at the other three. In plan, with color as height:
#map((1 - x^2*(3 - 2*x))*(1 - y^2*(3 - 2*y)), [0 1], [0 1])

## 8 · With the numbers of the drawing
#: Up to here a_{1} and b_{1} were letters. Now they take the value of the sides measured on the rectangle of point 1:
a_1 = l_a [m] 'element side in x, measured in the drawing
b_1 = l_b [m] 'element side in y, measured in the drawing
#: At the **center of side a** (ξ = 0.5), the slope and curvature produced by each datum of node 1:
p_1 = dec(-6*(0.5/a_1)*(1 - 0.5), 4) [1/m] 'slope due to the deflection of node 1
p_2 = dec(1 - 0.5*(4 - 3*0.5), 4) 'slope due to the rotation of node 1
c_1 = dec(-(6/a_1^2)*(1 - 2*0.5), 4) [1/m²] 'curvature due to the deflection of node 1
c_2 = dec(-(2/a_1)*(2 - 3*0.5), 4) [1/m] 'curvature due to the rotation of node 1
#: **Reading.** With the side of @{a_1} m, if node 1 rises 1, the slope at the center is @{p_1} per meter (negative: the curve goes down toward node 2). The curvature due to that deflection is zero at the center: there the curve changes direction. If the rectangle is stretched in the drawing window, a_{1} grows and the slopes drop: the same movement spread over more meters tilts less.

## 9 · Summary
#| Columna | Qué es | Lleva |
#|---|---|---|
#| Φ | la flecha | a_{1} solo en las de giro |
#| Φ′ | la pendiente: el giro | 1/a_{1} |
#| Φ″ | la curvatura: el momento | 1/a_{1}² |
#: **What each is for.** With Φ the deflection and the load are distributed among the nodes. With Φ′ the rotation is obtained at any point. With Φ″ the stiffness is built and the moments are obtained.
#: **Source.** The formulas are those of the Calcpad sheet *Rectangular Slab FEA* (Ned Ganchovski). The complete analysis of that slab, with these same functions, is in sheets 71 and 85.
