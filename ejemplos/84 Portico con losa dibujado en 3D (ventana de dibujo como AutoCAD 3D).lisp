# Pórtico con losa dibujado en 3D (la ventana de dibujo como AutoCAD 3D)

#: La ventana **✏ Dibujar / Editar** también dibuja en **3D**, con las órdenes y las reglas de AutoCAD. Los botones **Planta · Frente · Lateral · Iso SO · Iso SE** cambian la vista; **Mayús + botón central** (la rueda pulsada) arrastrando gira la vista (**3DORBITA**, o la orden **3DO**). **Planta** es la ventana 2D de siempre. Frente y Lateral ponen su **SCP** (como AutoCAD con UCSORTHO = 1): lo que se dibuja cae en ese plano.
#: Coordenadas 3D: **x,y,z** · **@**dx,dy,dz; con dos números la z es la del plano del SCP; un número solo = distancia en la dirección del cursor **en el espacio**. La caja junto a la goma da la **longitud 3D** del tramo.
#: Órdenes 3D: **3P** (3DPOL: polilínea 3D, C cierra) · **3F** (3DCARA: 4 puntos, Intro en el 4.º = cara de 3 lados; sigue con el 3.º y el 4.º de la cara siguiente; **I** antes de un punto = arista invisible) · **SCP** (U universal · XY · XZ · YZ · un punto = origen nuevo y, si se quiere, un punto en el eje X y otro en el plano XY = SCP de 3 puntos · A anterior) · **PLANTA** · **VISTA**. La referencia a objetos (final, medio, centro, intersección e **intersección ficticia**) engancha los puntos 3D proyectados.

## 1. El pórtico, dibujado en la ventana

#: Cuatro columnas (LINE con z), las vigas como una **3DPOL** cerrada a z = 3 m, la losa como una **3DCARA** y dos riostras en X en el plano del frente. Se dibujó así: **LA** COLUMNAS · **L** 0,0,0 0,0,3 … · **LA** VIGAS · **3P** 0,0,3 5,0,3 5,4,3 0,4,3 **C** · **LA** LOSA · **3F** 0,0,3 5,0,3 5,4,3 0,4,3 Intro · **LA** ARRIOSTRE · **L** 0,0,0 5,0,3. Pulsa **✏ Dibujar / Editar**, **Iso SO**, y cámbialo (por ejemplo **SCP** 0,0,3 y una viga con **L** 0,2 5,2): todo lo de abajo se recalcula.
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

## 2. Medir lo dibujado: longitudes y áreas en el espacio

#: El bloque siguiente es AutoLISP (se puede pegar en AutoCAD) y sigue sobre el MISMO dibujo: **ssget** busca por capa, **entget** da la lista DXF y los pares **(10 x y z)** son los puntos 3D. **distance** es la distancia en el espacio: √(Δx² + Δy² + Δz²). La 3DPOL se recorre con **entnext** por sus VERTEX hasta el SEQEND. El área de una cara plana de 4 vértices es la mitad del producto vectorial de sus diagonales: A = ½·|(p₃ − p₁) × (p₄ − p₂)|. Los rótulos se ponen con z, en el dibujo 3D.
#autolisp("El pórtico leído del dibujo: longitudes 3D y área de la losa", ancho = 110, alto = 90, exporta = L_col P_vig A_los L_arr n_col h_col)
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

## 3. El cálculo sigue con lo leído del dibujo

#: Con las medidas del dibujo, las cantidades de obra (espesor de losa, sección de columnas y vigas) y la comprobación de la riostra contra Pitágoras en 3D:
e_los = 0.20 'espesor de la losa, m
b_c = 0.30 'lado de la columna cuadrada, m
b_v = 0.25 'ancho de la viga, m
h_v = 0.40 'peralte de la viga, m
V_los = dec(A_los*e_los, 3) 'hormigón de la losa, m³
V_col = dec(n_col*b_c^2*h_col, 3) 'hormigón de las columnas, m³
V_vig = dec(P_vig*b_v*(h_v - e_los), 3) 'hormigón de las vigas bajo la losa, m³
V_tot = dec(V_los + V_col + V_vig, 3) 'total, m³
L_1 = dec(sqrt(5^2 + 3^2), 6) 'riostra de libro: diagonal de 5 × 3 m
e_r = dec(L_arr/2 - sqrt(5^2 + 3^2), 6) 'diferencia con la leída del dibujo (exporta trae 6 decimales)
