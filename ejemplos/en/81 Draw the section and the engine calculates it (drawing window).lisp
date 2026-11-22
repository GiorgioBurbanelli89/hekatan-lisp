# Draw the section and the engine calculates it

#: **#dibujar(name)** puts a drawing on the sheet with the **✏ Draw / Edit** button. The button opens a **drawing window** (like AutoCAD): line, polyline, rectangle, circle, arc, point, text and dimension, with grid, object snap and command line. When you press **💾 Save to sheet**, what was drawn is **written to the sheet** between #dibujar and #fin, one entity per line: **(entmake '((0 . "LWPOLYLINE") …))**, the same DXF list of AutoLISP (it can be pasted into AutoCAD). The sheet recalculates and the lines below use what was drawn.
#: Commands (typed at any time, Enter or Space to execute): **L** line · **PL** polyline (C closes) · **REC** rectangle · **C** circle · **A** arc (3 points or C = center) · **PO** point · **T** text · **DIM** dimension (H/V/A) · **M** move · **E** erase · **U** undo · **LA** layer · **COL** color · **Z** zoom. Coordinates: **x,y** · **@**dx,dy · **@**d<angle · a single number = distance in the cursor direction. **F3** object snap · **F7** grid · **F8** ortho · **F9** force cursor. Esc cancels; an empty Enter repeats the last command.

## 1. The section, drawn by hand

#: A concrete T: closed polyline on layer SECCION and four dimensions on layer COTAS. Press **✏ Draw / Edit** to change it (for example **E** to erase the polyline and **PL** to draw another, or **M** to move it): everything that follows is recalculated with the new one.
#dibujar(seccion, ancho = 100, alto = 95, ud = m, cuadricula = 0.025)
;; dibujado con la ventana ✏ — 5 entidades (listas DXF de AutoLISP: se reescribe al guardar)
(entmake '((0 . "LAYER") (100 . "AcDbSymbolTableRecord") (100 . "AcDbLayerTableRecord") (2 . "SECCION") (70 . 0) (62 . 5) (6 . "CONTINUOUS")))
(entmake '((0 . "LAYER") (100 . "AcDbSymbolTableRecord") (100 . "AcDbLayerTableRecord") (2 . "COTAS") (70 . 0) (62 . 3) (6 . "CONTINUOUS")))
(entmake '((0 . "LWPOLYLINE") (100 . "AcDbEntity") (8 . "SECCION") (100 . "AcDbPolyline") (90 . 8) (70 . 1) (10 0.175 0.0) (10 0.425 0.0) (10 0.425 0.45) (10 0.6 0.45) (10 0.6 0.6) (10 0.0 0.6) (10 0.0 0.45) (10 0.175 0.45)))
(entmake '((0 . "DIMENSION") (100 . "AcDbEntity") (8 . "COTAS") (100 . "AcDbDimension") (10 0.6 0.7 0.0) (70 . 32) (1 . "") (100 . "AcDbAlignedDimension") (13 0.0 0.6 0.0) (14 0.6 0.6 0.0) (50 . 0.0) (100 . "AcDbRotatedDimension")))
(entmake '((0 . "DIMENSION") (100 . "AcDbEntity") (8 . "COTAS") (100 . "AcDbDimension") (10 -0.1 0.6 0.0) (70 . 32) (1 . "") (100 . "AcDbAlignedDimension") (13 0.175 0.0 0.0) (14 0.0 0.6 0.0) (50 . 1.570796327) (100 . "AcDbRotatedDimension")))
(entmake '((0 . "DIMENSION") (100 . "AcDbEntity") (8 . "COTAS") (100 . "AcDbDimension") (10 0.425 -0.1 0.0) (70 . 32) (1 . "") (100 . "AcDbAlignedDimension") (13 0.175 0.0 0.0) (14 0.425 0.0 0.0) (50 . 0.0) (100 . "AcDbRotatedDimension")))
(entmake '((0 . "DIMENSION") (100 . "AcDbEntity") (8 . "COTAS") (100 . "AcDbDimension") (10 0.7 0.6 0.0) (70 . 32) (1 . "") (100 . "AcDbAlignedDimension") (13 0.6 0.45 0.0) (14 0.6 0.6 0.0) (50 . 1.570796327) (100 . "AcDbRotatedDimension")))
#fin

## 2. Reading the drawing: area, centroid and inertia

#: The next block continues on the SAME drawing: **ssget** finds the polyline on layer SECCION, **entget** returns it as a list and its **(10 x y)** pairs are the vertices. With them, Green's theorem gives the area, the static moments and the inertias of any polygon (one line of LISP per formula). The results are labeled on the drawing and return to the sheet with **exporta**.
#autolisp("The section read from the drawing: centroid and principal axes", ancho = 110, alto = 95, exporta = A x_c y_c I_x I_y b h b_w t_f)
;; la sección la leen las funciones del motor (Green sobre los vértices): sin defun ni bucles
(setq S (primera "SECCION" "LWPOLYLINE"))
(setq A (area S) x_c (centroide-x S) y_c (centroide-y S) I_x (inercia-x S) I_y (inercia-y S))
(setq b (ancho S) h (alto S) b_w (ancho-en S 0.001) t_f (/ (- A (* b_w h)) (- b b_w)))
;; rótulos sobre el dibujo: el centroide, sus ejes y los valores
(capa "EJES" :color 1 :tipo "eje")
(linea (list (- x_c (* 0.62 b)) y_c) (list (+ x_c (* 0.62 b)) y_c))
(linea (list x_c (- y_c (* 0.55 h))) (list x_c (+ y_c (* 0.55 h))))
(capa "RESULTADOS" :color 1)
(circulo (list x_c y_c) (* 0.02 b))
(formula (list (+ x_c (* 0.04 b)) (+ y_c (* 0.03 h))) "G" :altura (* 0.045 h))
(formula (list (* 0.03 b) (* 0.36 h)) A :nombre "A" :altura (* 0.04 h))
(formula (list (* 0.03 b) (* 0.28 h)) y_c :nombre "y_c" :altura (* 0.04 h))
(formula (list (* 0.03 b) (* 0.20 h)) I_x :nombre "I_x" :altura (* 0.04 h))
(princ (strcat "Polilínea de " (itoa (length (vertices S))) " vértices leída del dibujo"))
#fin

#: The area, the centroid and the inertia read from the drawing (drawing units: m, m², m⁴):
f_x = I_x/A 'squared radius of gyration, m²

## 3. The symbolic engine continues: the T formula against the drawing

#: With the dimensions read from the vertices (b, h, b_w, t_f), the textbook T formula (Steiner: flange + web) must give the same as the Green polygon:
y_T = (b*t_f*(h - t_f/2) + b_w*(h - t_f)*(h - t_f)/2)/(b*t_f + b_w*(h - t_f)) 'centroid from the bottom, m
I_T = b*t_f^3/12 + b*t_f*(h - t_f/2 - y_T)^2 + b_w*(h - t_f)^3/12 + b_w*(h - t_f)*((h - t_f)/2 - y_T)^2 'inertia: flange + web with Steiner, m⁴
e_I = (I_T - I_x)/I_x 'difference with what was read from the drawing
W_s = I_T/(h - y_T) 'section modulus of the top fiber, m³
