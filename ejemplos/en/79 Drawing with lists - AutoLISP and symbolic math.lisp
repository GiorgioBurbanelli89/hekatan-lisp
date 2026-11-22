# Drawing with lists: symbolic math made graphic

#: In Hekatan LISP **the code is the data list**. A line is not a hidden object: it is a DXF association list, the same one AutoLISP uses in AutoCAD: **((0 . "LINE") (8 . "0") (10 0 0) (11 3 4))**. It is built with list, cons and mapcar, stored in a variable, transformed with functions, and only then does **entmake** put it in the drawing. Conversely, **ssget** and **entget** read what is drawn as lists, and those lists are used for further calculation.
#: A block **#autolisp … #fin** is LISP code. It sees the sheet definitions that come before (f, P, q…) and returns to the sheet the values requested with **exporta**. To save the drawing: **(guardar "name.dxf")** (also .svg, .png and .pdf) or the buttons under each drawing.

## 1. The simple one: a function, its derivative, its tangent and its area

#: The function is written in the sheet. The symbolic engine does the rest: it differentiates, solves f′(x) = 0, integrates, and each result is drawn and labeled with its formula.
f(x) = x^3 - 6*x^2 + 9*x + 1
x_0 = 2 'point of the tangent

#autolisp("f(x), its symbolic derivative, the tangent at x₀ and the area between 0 and 3", ancho = 165, alto = 125, vert = 0.45, exporta = m_t A_exacta A_dibujo)
(setq df (derive-x f))                  ; derivada SIMBÓLICA:  3x² − 12x + 9
(setq crit (despejar df 0 'x))          ; f'(x) = 0  →  (vector 3 1)
(setq A_exacta (defint-x f 0 3))        ; integral definida EXACTA: 39/4
(setq m_t (nval df 'x x_0))             ; pendiente = derivada evaluada en x₀
(setq y_0 (nval f 'x x_0))
(setq tg (simplify `(+ (* ,(round m_t) x) ,(round (- y_0 (* m_t x_0))))))    ; t(x) = m·x + b
(vertical 0.45)
(ejes -0.4 4.4 -3.5 10.2 :paso-x 1 :paso-y 2 :nombre-y "y")
;; el área bajo la curva: un polígono hecho con los puntos de la fórmula (una lista)
(setq borde (loop for i from 0 to 60 collect (let ((x (* 3 (/ i 60.0)))) (list x (nval f 'x x)))))
(achurado (append '((0 0)) borde '((3 0))) :color "azul" :transparencia 0.82 :capa "AREA")
(setq A_dibujo (area (entlast)))        ; y el área, LEÍDA del dibujo
;; las curvas: y = f(x) desde la fórmula
(curva f -0.3 4.2 :n 120 :color "azul" :grosor 0.45 :capa "f")
(curva df 0.25 3.75 :n 120 :color "rojo" :grosor 0.35 :tipo "trazos" :capa "f'")
(curva tg (- x_0 1.1) (+ x_0 1.1) :n 2 :color "verde" :grosor 0.35 :capa "tangente")
;; máximo y mínimo: donde f'(x) = 0
(setq d2f (derive-x df))                ; f''(x): máximo si es negativa
(foreach xc (cdr crit)
  (punto (list xc (nval f 'x xc)) :color "azul")
  (if (< (nval d2f 'x xc) 0)                                 ; máximo: rótulo encima; mínimo: a la derecha
      (formula (list (- xc 0.25) (+ (nval f 'x xc) 0.8)) (format nil "(~a, ~a)" xc (round (nval f 'x xc))) :altura 0.2 :alinea "c")
      (formula (list (+ xc 0.18) (- (nval f 'x xc) 0.9)) (format nil "(~a, ~a)" xc (round (nval f 'x xc))) :altura 0.2)))
(punto (list x_0 y_0) :color "verde")
;; los rótulos: la fórmula que dio el motor, escrita como en la hoja
(formula '(0.35 9.6) (infix f) :nombre "f(x)" :altura 0.21 :color "azul")
(formula '(0.35 8.5) (infix df) :nombre "f'(x)" :altura 0.21 :color "rojo")
(formula '(2.9 9.6) tg :nombre "t(x)" :altura 0.21 :color "verde")
(formula '(1.5 1.1) A_exacta :nombre "A" :altura 0.21 :alinea "c" :color "azul")
#fin

#: The slope of the tangent comes from the symbolic derivative evaluated at x₀, and the area of the drawing (a polygon of 60 segments) is read with **area** and compared with the exact integral:
e_A = (A_dibujo - A_exacta)/A_exacta 'relative error of the polygon

## 2. The AutoLISP one: entmake, ssget, sslength

#: The starting case, exactly as written in AutoCAD. The point comes from a calculation; the line count, from reading the drawing. The four lines are ONE list L_1 rotated with a four-line function (**subst** + **polar**): the entity is a datum that is transformed before it is drawn. This block is pure AutoLISP: pasted in AutoCAD it gives the same drawing.
#autolisp("From calculation to drawing and from drawing to calculation", ancho = 120, alto = 70, exporta = n S_m, autocad = si)
;; simbólico: cálculo
(setq H 10.0  S 1.5)
(setq pie (list (* H S) (- H)))         ; (15.0 -10.0)
;; dibujo con ese resultado simbólico
(entmakex (list '(0 . "POINT") (cons 10 pie)))
(setq L_1 (list '(0 . "LINE") '(8 . "RAYOS") '(62 . 5) '(10 0.0 0.0) (cons 11 (list H 0.0))))
;; girar = operar sobre la LISTA: subst cambia el par 11 por el punto girado con polar
(defun gira (ent a / p q)
  (setq p (cdr (assoc 10 ent)) q (cdr (assoc 11 ent)))
  (subst (cons 11 (polar p (+ (angle p q) a) (distance p q))) (assoc 11 ent) ent))
(foreach a '(0 -15 -30 -45) (entmake (gira L_1 (* pi (/ a 180.0)))))
(entmake (list '(0 . "LINE") '(8 . "COTA") (cons 10 (list 0.0 (- H))) (cons 11 pie)))
;; simbólico: leer el valor del dibujo
(setq n (sslength (ssget "_X" '((0 . "LINE")))))
(princ (strcat "Hay " (itoa n) " lineas"))
;; y operar con lo leído: la suma de las pendientes de los rayos
(setq ss (ssget "_X" '((0 . "LINE") (8 . "RAYOS"))) S_m 0.0 i 0)
(repeat (sslength ss)
  (setq e (entget (ssname ss i))
        S_m (+ S_m (/ (- (caddr (assoc 11 e)) (caddr (assoc 10 e))) (- (cadr (assoc 11 e)) (cadr (assoc 10 e)))))
        i (1+ i)))
(princ (strcat "\nSuma de pendientes: " (rtos S_m 2 4)))
(princ (strcat "\nAngulo del ultimo rayo: " (angtos (angle (cdr (assoc 10 e)) (cdr (assoc 11 e))))))
#fin

#: The drawing has @n lines, and the sum of the slopes read, S_m = −(tan 0° + tan 15° + tan 30° + tan 45°), returns to the sheet.

## 3. A parametric plan: the footing that comes out of the calculation

#: The load and the allowable pressure are written in the sheet. The LISP computes the side B, draws the plan with dimensions, and then READS the drawing: the area of the footing polyline and the dimension value. If you change P, the drawing and what is read change.
P = 850 'service load, kN
q_adm = 200 'allowable pressure, kPa

#autolisp("Isolated footing: plan (m)", ancho = 110, alto = 100, exporta = B A_leida B_cota q_real)
(setq B (/ (fceiling (* 20 (sqrt (/ P q_adm)))) 20))   ; B ≥ √(P/q), múltiplo de 5 cm
(setq c 0.40  o (list (- (/ B 2)) (- (/ B 2))))
(capa "ZAPATA" :color 7 :grosor 0.5)
(rect o B B)
(capa "COLUMNA" :color 8)
(achurado (list (list (- (/ c 2)) (- (/ c 2))) (list (/ c 2) (- (/ c 2))) (list (/ c 2) (/ c 2)) (list (- (/ c 2)) (/ c 2)))
          :patron "ANSI31")
(rect (list (- (/ c 2)) (- (/ c 2))) c c :grosor 0.35)
(capa "EJES" :color 8 :tipo "eje")
(linea (list (- (* 0.62 B)) 0) (list (* 0.62 B) 0))
(linea (list 0 (- (* 0.62 B))) (list 0 (* 0.62 B)))
;; cuatro pernos: una lista de puntos hecha con polar y mapcar
(capa "PERNOS" :color 1)
(mapcar (lambda (a) (circulo (polar '(0 0) (rad a) 0.13) 0.016)) '(45 135 225 315))
(capa "COTAS" :color 3)
(cota (list (- (/ B 2)) (- (/ B 2))) (list (/ B 2) (- (/ B 2))) :dir "h" :sep (- (* 0.18 B)))
(cota (list (/ B 2) (- (/ B 2))) (list (/ B 2) (/ B 2)) :dir "v" :sep (- (* 0.18 B)))
(capa "TEXTO" :color 7)
(texto (list (- (/ B 2)) (+ (/ B 2) 0.1)) (strcat "Z-1   P = " (rtos P 2 0) " kN") :altura 0.09)
;; la vuelta: leer del dibujo y verificar
(setq zap (ssget "_X" '((0 . "LWPOLYLINE") (8 . "ZAPATA"))))
(setq A_leida (area (ssname zap 0)))
;; la cota horizontal: su línea (10) queda abajo a la izquierda → filtro relacional -4 por componentes
(setq B_cota (dxf 42 (ssname (ssget "_X" '((0 . "DIMENSION") (-4 . "<,<,*") (10 0.0 0.0 0.0))) 0)))
(setq q_real (/ P A_leida))
(princ (strcat "Leído del dibujo: A = " (rtos A_leida 2 3) " m²,  cota = " (rtos B_cota 2 2) " m"))
(princ (strcat "\nq = P/A = " (rtos q_real 2 1) " kPa " (if (<= q_real q_adm) "≤" ">") " q_adm = " (rtos q_adm 2 0) " kPa"))
(guardar "zapata Z-1.dxf")
(guardar "zapata Z-1.pdf")
(guardar "zapata Z-1.svg")
(guardar "zapata Z-1.dwg")
#fin

#: What is read from the drawing (the polyline area and the dimension value) returns to the sheet: with that area the real pressure stays below the allowable one.
