# Sección en T dibujada a mano
#: El contorno se dibuja en la ventana de dibujo; el bloque de abajo lo lee y calcula.
#dibujar(seccion, ancho = 100, alto = 80, ud = m, cuadricula = 0.025)
;; dibujado con la ventana ✏ — 3 entidades (listas DXF de AutoLISP: se reescribe al guardar)
(entmake '((0 . "LAYER") (100 . "AcDbSymbolTableRecord") (100 . "AcDbLayerTableRecord") (2 . "SECCION") (70 . 0) (62 . 4) (6 . "CONTINUOUS")))
(entmake '((0 . "LAYER") (100 . "AcDbSymbolTableRecord") (100 . "AcDbLayerTableRecord") (2 . "COTAS") (70 . 0) (62 . 3) (6 . "CONTINUOUS")))
(entmake '((0 . "LWPOLYLINE") (100 . "AcDbEntity") (8 . "SECCION") (100 . "AcDbPolyline") (90 . 8) (70 . 1) (10 0.175 0.0) (10 0.425 0.0) (10 0.425 0.45) (10 0.6 0.45) (10 0.6 0.6) (10 0.0 0.6) (10 0.0 0.45) (10 0.175 0.45)))
(entmake '((0 . "DIMENSION") (100 . "AcDbEntity") (8 . "COTAS") (100 . "AcDbDimension") (10 0.6 0.725 0.0) (70 . 32) (1 . "") (100 . "AcDbAlignedDimension") (13 0.0 0.6 0.0) (14 0.6 0.6 0.0) (50 . 0.0) (100 . "AcDbRotatedDimension")))
(entmake '((0 . "DIMENSION") (100 . "AcDbEntity") (8 . "COTAS") (100 . "AcDbDimension") (10 0.425 -0.1 0.0) (70 . 32) (1 . "") (100 . "AcDbAlignedDimension") (13 0.175 0.0 0.0) (14 0.425 0.0 0.0) (50 . 0.0) (100 . "AcDbRotatedDimension")))
#fin
#autolisp("La sección leída del dibujo: centroide y ejes principales", ancho = 110, alto = 95, exporta = A x_c y_c I_x I_y b h b_w t_f)
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

#: Lo leído del dibujo, en la hoja:
r_x = sqrt(I_x/A) 'radio de giro, m
