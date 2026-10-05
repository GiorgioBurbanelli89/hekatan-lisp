# Dibujo 3D: la cáscara de 4 nudos alabeada y sus ejes locales

#: El elemento **ShellMITC4** de OpenSees (hoja 72) no es plano: sus cuatro nudos pueden estar alabeados. Sus ejes locales salen de un cálculo con vectores (ShellMITC4::computeBasis):
#: v₁ = ½·(x₂ + x₃ − x₁ − x₄) · v₂ = ½·(x₃ + x₄ − x₁ − x₂) · g₁ = v₁/|v₁| · g₃ = g₁ × v₂ /|g₁ × v₂| · g₂ = g₃ × g₁
#: El bloque de abajo es **AutoLISP puro**: se puede pegar tal cual en AutoCAD (APPLOAD o (load "…")) y da el mismo dibujo. Las entidades son 3D de AutoCAD: POLYLINE 3D (70 = 8, vértices 70 = 32), 3DFACE, LINE y TEXT con z. El dibujo se gira con el ratón; los botones vuelven a planta, frente o lateral.

#autolisp("ShellMITC4 alabeado: nudos, ejes locales g₁ g₂ g₃ y ejes globales", ancho = 150, alto = 115, exporta = g3x g3y g3z tetan, autocad = si)
;;; ---------- vectores (AutoLISP puro) ----------
(defun v+ (a b) (mapcar '+ a b))
(defun v- (a b) (mapcar '- a b))
(defun v* (k a) (mapcar '(lambda (x) (* k x)) a))
(defun vdot (a b) (apply '+ (mapcar '* a b)))
(defun vlen (a) (sqrt (vdot a a)))
(defun vunit (a) (v* (/ 1.0 (vlen a)) a))
(defun vcross (a b)
  (list (- (* (cadr a) (caddr b)) (* (caddr a) (cadr b)))
        (- (* (caddr a) (car b)) (* (car a) (caddr b)))
        (- (* (car a) (cadr b)) (* (cadr a) (car b)))))
;;; ---------- capas ----------
(defun capa (nom col)
  (entmake (list '(0 . "LAYER") '(100 . "AcDbSymbolTableRecord") '(100 . "AcDbLayerTableRecord")
                 (cons 2 nom) '(70 . 0) (cons 62 col) '(6 . "CONTINUOUS"))))
(capa "CASCARA" 5) (capa "BORDE" 7) (capa "NUDOS" 7) (capa "EJES-LOCALES" 1) (capa "EJES-GLOBALES" 8)
;;; ---------- flecha 3D: linea + punta de dos caras (440: opacas) ----------
(defun flecha (p q col lay / d l u a n1 n2 b)
  (setq d (v- q p) l (vlen d) u (vunit d) a (* 0.16 l)
        n1 (if (< (abs (car u)) 0.9) (vunit (vcross u '(1.0 0.0 0.0))) (vunit (vcross u '(0.0 1.0 0.0))))
        n2 (vcross u n1)
        b (v- q (v* a u)))
  (entmake (list '(0 . "LINE") (cons 8 lay) (cons 62 col) (cons 10 p) (cons 11 b)))
  (entmake (list '(0 . "3DFACE") (cons 8 lay) (cons 62 col) '(440 . 33554687) (cons 10 q)
                 (cons 11 (v+ b (v* (* 0.32 a) n1))) (cons 12 (v- b (v* (* 0.32 a) n1))) (cons 13 (v- b (v* (* 0.32 a) n1)))))
  (entmake (list '(0 . "3DFACE") (cons 8 lay) (cons 62 col) '(440 . 33554687) (cons 10 q)
                 (cons 11 (v+ b (v* (* 0.32 a) n2))) (cons 12 (v- b (v* (* 0.32 a) n2))) (cons 13 (v- b (v* (* 0.32 a) n2))))))
(defun rotulo (p txt h col lay)
  (entmake (list '(0 . "TEXT") (cons 8 lay) (cons 62 col) (cons 10 p) (cons 40 h) (cons 1 txt))))
;;; ---------- geometría: 4 nudos alabeados ----------
(setq alabeo 0.45)
(setq x1 (list 0.0 0.0 0.0)
      x2 (list 2.0 0.0 alabeo)
      x3 (list 2.2 1.6 0.1)
      x4 (list 0.1 1.5 0.0))
;;; ---------- ejes locales (ShellMITC4::computeBasis) ----------
(setq v1 (v* 0.5 (v- (v+ x2 x3) (v+ x1 x4)))
      v2 (v* 0.5 (v- (v+ x3 x4) (v+ x1 x2)))
      g1 (vunit v1)
      g3 (vunit (vcross g1 v2))
      g2 (vcross g3 g1)
      c  (v* 0.25 (v+ (v+ x1 x2) (v+ x3 x4))))
(setq g3x (car g3) g3y (cadr g3) g3z (caddr g3))
(setq tetan (* (/ 180.0 pi) (atan (sqrt (+ (* g3x g3x) (* g3y g3y))) g3z)))   ; g3 contra Z, grados
;;; ---------- dibujo ----------
(entmake (list '(0 . "3DFACE") '(8 . "CASCARA") (cons 10 x1) (cons 11 x2) (cons 12 x3) (cons 13 x4)))
(entmake '((0 . "POLYLINE") (8 . "BORDE") (66 . 1) (10 0.0 0.0 0.0) (70 . 9)))
(foreach p (list x1 x2 x3 x4)
  (entmake (list '(0 . "VERTEX") '(8 . "BORDE") (cons 10 p) '(70 . 32))))
(entmake '((0 . "SEQEND") (8 . "BORDE")))
(setq i 0)
(foreach p (list x1 x2 x3 x4)
  (setq i (1+ i))
  (entmake (list '(0 . "POINT") '(8 . "NUDOS") (cons 10 p)))
  (rotulo (v+ p '(0.05 0.05 0.08)) (itoa i) 0.1 7 "NUDOS"))
(flecha c (v+ c (v* 0.8 g1)) 1 "EJES-LOCALES")
(flecha c (v+ c (v* 0.8 g2)) 3 "EJES-LOCALES")
(flecha c (v+ c (v* 0.8 g3)) 5 "EJES-LOCALES")
(rotulo (v+ c (v* 0.9 g1)) "g1" 0.1 1 "EJES-LOCALES")
(rotulo (v+ c (v* 0.9 g2)) "g2" 0.1 3 "EJES-LOCALES")
(rotulo (v+ c (v* 0.9 g3)) "g3" 0.1 5 "EJES-LOCALES")
(setq o (list -0.6 -0.5 0.0))
(flecha o (v+ o '(0.5 0.0 0.0)) 8 "EJES-GLOBALES")
(flecha o (v+ o '(0.0 0.5 0.0)) 8 "EJES-GLOBALES")
(flecha o (v+ o '(0.0 0.0 0.5)) 8 "EJES-GLOBALES")
(rotulo (v+ o '(0.56 0.0 0.0)) "X" 0.09 8 "EJES-GLOBALES")
(rotulo (v+ o '(0.0 0.56 0.0)) "Y" 0.09 8 "EJES-GLOBALES")
(rotulo (v+ o '(0.0 0.0 0.56)) "Z" 0.09 8 "EJES-GLOBALES")
;;; ---------- vuelta: leer del dibujo ----------
(setq ss (ssget "_X" '((0 . "3DFACE") (8 . "CASCARA"))))
(setq f (entget (ssname ss 0)))
(princ (strcat "g3 = (" (rtos g3x 2 4) ", " (rtos g3y 2 4) ", " (rtos g3z 2 4) ")"))
(princ (strcat "\nNudo 2 leido de la 3DFACE: z = " (rtos (cadddr (assoc 11 f)) 2 3)))
(princ (strcat "\ng1 . g3 = " (rtos (vdot g1 g3) 2 6) "   |g2| = " (rtos (vlen g2) 2 6)))
#fin

#: g₃ es la normal del elemento: con el alabeo se inclina @tetan grados respecto del eje Z global (valores devueltos a la hoja, arriba).
