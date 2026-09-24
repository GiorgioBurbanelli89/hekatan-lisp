# Dibuja la sección y el motor la calcula

#: **#dibujar(nombre)** pone en la hoja un dibujo con el botón **✏ Dibujar / Editar**. El botón abre una **ventana de dibujo** (como AutoCAD): línea, polilínea, rectángulo, círculo, arco, punto, texto y cota, con rejilla, referencia a objetos y línea de órdenes. Al pulsar **💾 Guardar en la hoja**, lo dibujado se **escribe en la hoja** entre #dibujar y #fin, una entidad por línea: **(entmake '((0 . "LWPOLYLINE") …))**, la misma lista DXF de AutoLISP (se puede pegar en AutoCAD). La hoja se recalcula y las líneas de abajo usan lo dibujado.
#: Órdenes (se teclean en cualquier momento, Intro o Espacio para ejecutar): **L** línea · **PL** polilínea (C cierra) · **REC** rectángulo · **C** círculo · **A** arco (3 puntos o C = centro) · **PO** punto · **T** texto · **DIM** cota (H/V/A) · **M** mover · **E** borrar · **U** deshacer · **LA** capa · **COL** color · **Z** zoom. Coordenadas: **x,y** · **@**dx,dy · **@**d<ángulo · un número solo = distancia en la dirección del cursor. **F3** referencia a objetos · **F7** rejilla · **F8** orto · **F9** forzar cursor. Esc cancela; Intro vacío repite la última orden.

## 1. La sección, dibujada a mano

#: Una T de hormigón: polilínea cerrada en la capa SECCION y cuatro cotas en la capa COTAS. Pulsa **✏ Dibujar / Editar** para cambiarla (por ejemplo **E** para borrar la polilínea y **PL** para dibujar otra, o **M** para moverla): todo lo que sigue se recalcula con lo nuevo.
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

## 2. Leer el dibujo: área, centroide e inercia

#: El bloque siguiente sigue sobre el MISMO dibujo: **ssget** busca la polilínea de la capa SECCION, **entget** la da como lista y sus pares **(10 x y)** son los vértices. Con ellos, el teorema de Green da el área, los momentos estáticos y las inercias de cualquier polígono (una línea de LISP por fórmula). Los resultados se rotulan sobre el dibujo y vuelven a la hoja con **exporta**.
#autolisp("La sección leída del dibujo: centroide y ejes principales", ancho = 110, alto = 95, exporta = A x_c y_c I_x I_y b h b_w t_f)
(setq e (entget (ssname (ssget "_X" '((0 . "LWPOLYLINE") (8 . "SECCION"))) 0)))
(setq V nil)
(foreach g e (if (= (car g) 10) (setq V (append V (list (cdr g))))))
;; Green, tramo p → q:  c = xp·yq − xq·yp ;  A = Σc/2 ;  Sx = Σ(yp+yq)·c/6 ;  Ix = Σ(yp²+yp·yq+yq²)·c/12
;; (AutoLISP no distingue mayúsculas: dentro de la función el área se llama Ar, no A)
(defun seccion (V / n i p q c Ar Sx Sy Ix Iy)
  (setq n (length V) i 0 Ar 0.0 Sx 0.0 Sy 0.0 Ix 0.0 Iy 0.0)
  (repeat n
    (setq p (nth i V) q (nth (rem (1+ i) n) V)
          c (- (* (car p) (cadr q)) (* (car q) (cadr p)))
          Ar (+ Ar (/ c 2.0))
          Sx (+ Sx (/ (* (+ (cadr p) (cadr q)) c) 6.0))
          Sy (+ Sy (/ (* (+ (car p) (car q)) c) 6.0))
          Ix (+ Ix (/ (* (+ (* (cadr p) (cadr p)) (* (cadr p) (cadr q)) (* (cadr q) (cadr q))) c) 12.0))
          Iy (+ Iy (/ (* (+ (* (car p) (car p)) (* (car p) (car q)) (* (car q) (car q))) c) 12.0))
          i (1+ i)))
  (if (< Ar 0) (mapcar '- (list Ar Sx Sy Ix Iy)) (list Ar Sx Sy Ix Iy)))   ; horario → se cambia el signo
(setq s (seccion V) A (nth 0 s) x_c (/ (nth 2 s) A) y_c (/ (nth 1 s) A))
(setq I_x (- (nth 3 s) (* A y_c y_c)) I_y (- (nth 4 s) (* A x_c x_c)))
;; las medidas de la T, leídas de los vértices: ancho, alto, alma (borde de abajo) y ala (primer escalón bajo el borde de arriba)
(setq xs (mapcar 'car V) ys (mapcar 'cadr V))
(setq b (- (apply 'max xs) (apply 'min xs)) h (- (apply 'max ys) (apply 'min ys)) y0 (apply 'min ys) y1 (apply 'max ys))
(setq bajos nil ym y0)
(foreach p V (if (< (abs (- (cadr p) y0)) 1e-9) (setq bajos (cons (car p) bajos))))
(foreach y ys (if (and (< y (- y1 1e-9)) (> y ym)) (setq ym y)))
(setq b_w (- (apply 'max bajos) (apply 'min bajos)) t_f (- y1 ym))
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
(princ (strcat "Polilínea de " (itoa (length V)) " vértices leída del dibujo"))
#fin

#: El área, el centroide y la inercia leídos del dibujo (unidades del dibujo: m, m², m⁴):
f_x = I_x/A 'radio de giro al cuadrado, m²

## 3. El motor simbólico sigue: la fórmula de la T contra el dibujo

#: Con las medidas leídas de los vértices (b, h, b_w, t_f), la fórmula de libro de la T (Steiner: ala + alma) tiene que dar lo mismo que el polígono de Green:
y_T = (b*t_f*(h - t_f/2) + b_w*(h - t_f)*(h - t_f)/2)/(b*t_f + b_w*(h - t_f)) 'centroide desde abajo, m
I_T = b*t_f^3/12 + b*t_f*(h - t_f/2 - y_T)^2 + b_w*(h - t_f)^3/12 + b_w*(h - t_f)*((h - t_f)/2 - y_T)^2 'inercia: ala + alma con Steiner, m⁴
e_I = (I_T - I_x)/I_x 'diferencia con lo leído del dibujo
W_s = I_T/(h - y_T) 'módulo resistente de la fibra de arriba, m³
