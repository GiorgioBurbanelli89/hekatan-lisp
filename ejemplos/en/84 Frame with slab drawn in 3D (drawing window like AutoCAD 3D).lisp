# Frame with slab drawn in 3D (the drawing window like AutoCAD 3D)

#: The **✏ Draw / Edit** window also draws in **3D**, with the commands and rules of AutoCAD. The buttons **Plan · Front · Side · Iso SW · Iso SE** change the view; **Shift + middle button** (the wheel pressed) while dragging rotates the view (**3DORBIT**, or the command **3DO**). **Plan** is the usual 2D window. Front and Side set their **UCS** (like AutoCAD with UCSORTHO = 1): what is drawn falls in that plane.
#: 3D coordinates: **x,y,z** · **@**dx,dy,dz; with two numbers the z is that of the UCS plane; a single number = distance in the direction of the cursor **in space**. The box next to the rubber band gives the **3D length** of the segment.
#: 3D commands: **3P** (3DPOL: 3D polyline, C closes) · **3F** (3DFACE: 4 points, Enter at the 4th = 3-sided face; continues with the 3rd and 4th of the next face; **I** before a point = invisible edge) · **UCS** (W world · XY · XZ · YZ · a point = new origin and, if wanted, a point on the X axis and another on the XY plane = 3-point UCS · P previous) · **PLAN** · **VIEW**. Object snap (endpoint, midpoint, center, intersection and **apparent intersection**) catches the projected 3D points.

## 1. The frame, drawn in the window

#: Four columns (LINE with z), the beams as a closed **3DPOL** at z = 3 m, the slab as a **3DFACE** and two X braces in the front plane. It was drawn like this: **LA** COLUMNS · **L** 0,0,0 0,0,3 … · **LA** BEAMS · **3P** 0,0,3 5,0,3 5,4,3 0,4,3 **C** · **LA** SLAB · **3F** 0,0,3 5,0,3 5,4,3 0,4,3 Enter · **LA** BRACING · **L** 0,0,0 5,0,3. Press **✏ Draw / Edit**, **Iso SW**, and change it (for example **UCS** 0,0,3 and a beam with **L** 0,2 5,2): everything below is recomputed.
#dibujar(portico, ancho = 110, alto = 90, ud = m, cuadricula = 0.5)
;; dibujado con la ventana ✏ — 8 entidades (listas DXF de AutoLISP: se reescribe al guardar)
(entmake '((0 . "LAYER") (100 . "AcDbSymbolTableRecord") (100 . "AcDbLayerTableRecord") (2 . "COLUMNAS") (70 . 0) (62 . 1) (6 . "CONTINUOUS")))
(entmake '((0 . "LAYER") (100 . "AcDbSymbolTableRecord") (100 . "AcDbLayerTableRecord") (2 . "VIGAS") (70 . 0) (62 . 3) (6 . "CONTINUOUS")))
(entmake '((0 . "LAYER") (100 . "AcDbSymbolTableRecord") (100 . "AcDbLayerTableRecord") (2 . "LOSA") (70 . 0) (62 . 5) (6 . "CONTINUOUS")))
(entmake '((0 . "LAYER") (100 . "AcDbSymbolTableRecord") (100 . "AcDbLayerTableRecord") (2 . "ARRIOSTRE") (70 . 0) (62 . 30) (6 . "CONTINUOUS")))
(entmake '((0 . "LINE") (8 . "COLUMNAS") (10 0.0 0.0 0.0) (11 0.0 0.0 3.0)))
(entmake '((0 . "LINE") (8 . "COLUMNAS") (10 5.0 0.0 0.0) (11 5.0 0.0 3.0)))
(entmake '((0 . "LINE") (8 . "COLUMNAS") (10 5.0 4.0 0.0) (11 5.0 4.0 3.0)))
(entmake '((0 . "LINE") (8 . "COLUMNAS") (10 0.0 4.0 0.0) (11 0.0 4.0 3.0)))
(entmake '((0 . "POLYLINE") (8 . "VIGAS") (66 . 1) (10 0.0 0.0 0.0) (70 . 9))) (entmake '((0 . "VERTEX") (8 . "VIGAS") (10 0.0 0.0 3.0) (70 . 32))) (entmake '((0 . "VERTEX") (8 . "VIGAS") (10 5.0 0.0 3.0) (70 . 32))) (entmake '((0 . "VERTEX") (8 . "VIGAS") (10 5.0 4.0 3.0) (70 . 32))) (entmake '((0 . "VERTEX") (8 . "VIGAS") (10 0.0 4.0 3.0) (70 . 32))) (entmake '((0 . "SEQEND") (8 . "VIGAS")))
(entmake '((0 . "3DFACE") (8 . "LOSA") (10 0.0 0.0 3.0) (11 5.0 0.0 3.0) (12 5.0 4.0 3.0) (13 0.0 4.0 3.0)))
(entmake '((0 . "LINE") (8 . "ARRIOSTRE") (10 0.0 0.0 0.0) (11 5.0 0.0 3.0)))
(entmake '((0 . "LINE") (8 . "ARRIOSTRE") (10 5.0 0.0 0.0) (11 0.0 0.0 3.0)))
#fin

## 2. Measuring what is drawn: lengths and areas in space

#: The following block is AutoLISP (it can be pasted in AutoCAD) and continues on the SAME drawing: **ssget** searches by layer, **entget** gives the DXF list and the **(10 x y z)** pairs are the 3D points. **distance** is the distance in space: √(Δx² + Δy² + Δz²). The 3DPOL is traversed with **entnext** through its VERTEXes up to the SEQEND. The area of a planar 4-vertex face is half the cross product of its diagonals: A = ½·|(p₃ − p₁) × (p₄ − p₂)|. The labels are placed with z, in the 3D drawing.
#autolisp("The frame read from the drawing: 3D lengths and slab area", ancho = 110, alto = 90, exporta = L_col P_vig A_los L_arr n_col h_col)
(defun v- (a b) (mapcar '- a b))
(defun vx (a b)
  (list (- (* (cadr a) (caddr b)) (* (caddr a) (cadr b)))
        (- (* (caddr a) (car b)) (* (car a) (caddr b)))
        (- (* (car a) (cadr b)) (* (cadr a) (car b)))))
(defun vl (a) (sqrt (apply '+ (mapcar '* a a))))
;; suma de longitudes 3D de las LINE de una capa
(defun largo-capa (lay / ss i e L)
  (setq ss (ssget "_X" (list '(0 . "LINE") (cons 8 lay))) i 0 L 0.0)
  (if ss (repeat (sslength ss)
           (setq e (entget (ssname ss i)) L (+ L (distance (cdr (assoc 10 e)) (cdr (assoc 11 e)))) i (1+ i))))
  L)
(setq L_col (largo-capa "COLUMNAS") L_arr (largo-capa "ARRIOSTRE"))
(setq n_col (sslength (ssget "_X" '((0 . "LINE") (8 . "COLUMNAS")))) h_col (/ L_col n_col))
;; la 3DPOL de las vigas: los VERTEX tras la cabecera; cerrada (70 bit 1) → también el último tramo
(setq pl (ssname (ssget "_X" '((0 . "POLYLINE") (8 . "VIGAS"))) 0)
      cerr (= 1 (logand 1 (cdr (assoc 70 (entget pl)))))
      V nil e (entnext pl))
(while (equal "VERTEX" (cdr (assoc 0 (entget e))))   ; (equal: el = de AutoLISP con cadenas aún no está en el motor)
  (setq V (append V (list (cdr (assoc 10 (entget e))))) e (entnext e)))
(setq P_vig 0.0 i 0)
(repeat (if cerr (length V) (1- (length V)))
  (setq P_vig (+ P_vig (distance (nth i V) (nth (rem (1+ i) (length V)) V))) i (1+ i)))
;; la losa: ½·|d₁ × d₂| de la 3DCARA
(setq f (entget (ssname (ssget "_X" '((0 . "3DFACE") (8 . "LOSA"))) 0))
      p1 (cdr (assoc 10 f)) p2 (cdr (assoc 11 f)) p3 (cdr (assoc 12 f)) p4 (cdr (assoc 13 f))
      A_los (/ (vl (vx (v- p3 p1) (v- p4 p2))) 2.0))
;; rótulos en el espacio (TEXT con z)
(entmake (list '(0 . "LAYER") '(100 . "AcDbSymbolTableRecord") '(100 . "AcDbLayerTableRecord") '(2 . "RESULTADOS") '(70 . 0) '(62 . 2) '(6 . "CONTINUOUS")))
(entmake (list '(0 . "TEXT") '(8 . "RESULTADOS") (cons 10 (list 1.2 1.8 3.05)) '(40 . 0.3) (cons 1 (strcat "A losa = " (rtos A_los 2 2) " m2"))))
(entmake (list '(0 . "TEXT") '(8 . "RESULTADOS") (cons 10 (list 2.6 -0.1 1.5)) '(40 . 0.25) (cons 1 (strcat "riostra = " (rtos (/ L_arr 2) 2 3) " m"))))
(princ (strcat "Columnas: " (itoa n_col) " de " (rtos h_col 2 2) " m · vigas: " (rtos P_vig 2 2) " m · losa: " (rtos A_los 2 2) " m2 · riostras: " (rtos L_arr 2 3) " m"))
#fin

## 3. The calculation continues with what was read from the drawing

#: With the measurements of the drawing, the quantities of work (slab thickness, column and beam section) and the check of the brace against Pythagoras in 3D:
e_los = 0.20 'slab thickness, m
b_c = 0.30 'side of the square column, m
b_v = 0.25 'beam width, m
h_v = 0.40 'beam depth, m
V_los = dec(A_los*e_los, 3) 'slab concrete, m³
V_col = dec(n_col*b_c^2*h_col, 3) 'column concrete, m³
V_vig = dec(P_vig*b_v*(h_v - e_los), 3) 'concrete of the beams under the slab, m³
V_tot = dec(V_los + V_col + V_vig, 3) 'total, m³
L_1 = dec(sqrt(5^2 + 3^2), 6) 'book brace: 5 × 3 m diagonal
e_r = dec(L_arr/2 - sqrt(5^2 + 3^2), 6) 'difference with the one read from the drawing (exporta brings 6 decimals)
