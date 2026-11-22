# C0 and C1 continuity: where it comes from, drawn
#: **The idea (y = m·x + b):** a line can be broken at a point and is still continuous. That is C0: the curve does not break, but the **slope jumps**. C1 asks for something more: that the **slope does not jump either**.
#: In a finite element, w(x) is the deflection and its slope is the rotation w′(x). Two elements share a node: C0 = same deflection at the node; C1 = same deflection **and the same rotation**.

## 1 · In a beam (2D): two elements that join at x = 0.4
#: The exact curve is w = sin(πx), in gray. With a node at x = 0.4 and another at each end:
#: red = **C0** element (only the node deflection is given, between nodes it is straight); green = **C1** element (node deflection **and rotation** are given, cubic Hermite).
#: The short yellow lines are the tangents at the node: C0 has TWO (one per element), C1 has ONE.
xn = 0.4 'position of the shared node
wn = sin(pi*xn) 'deflection at the node (shared by both)
gn = pi*cos(pi*xn) 'exact rotation at the node

#autolisp("C0 breaks, C1 does not", ancho = 150, alto = 90, exporta = sL0 sR0 salto0 sL1 sR1 salto1)
(defun wex (x) (sin (* pi x)))
(defun linea (x1 y1 x2 y2 col lay)
  (entmake (list '(0 . "LINE") (cons 8 lay) (cons 62 col) (list 10 x1 y1 0.0) (list 11 x2 y2 0.0))))
(defun texto (x y txt h col lay)
  (entmake (list '(0 . "TEXT") (cons 8 lay) (cons 62 col) (list 10 x y 0.0) (cons 40 h) (cons 1 txt))))
(setq xn 0.4 wn (wex xn) gn (* pi (cos (* pi xn))))
;; curva exacta (gris): 40 tramos
(setq i 0 xa 0.0 ya 0.0)
(while (< i 40)
  (setq xb (/ (+ i 1) 40.0) yb (wex xb))
  (linea xa ya xb yb 8 "EXACTA")
  (setq xa xb ya yb i (+ i 1)))
;; C0: recta del nudo 0 al nudo xn, y de xn al nudo 1
(linea 0.0 0.0 xn wn 1 "C0")
(linea xn wn 1.0 0.0 1 "C0")
;; C1: Hermite cúbico en cada elemento con flecha y giro exactos en los nudos
(defun herm (u L)
  (list (+ (- 1 (* 3 u u)) (* 2 u u u))
        (* L (+ (- u (* 2 u u)) (* u u u)))
        (- (* 3 u u) (* 2 u u u))
        (* L (+ (- (* u u)) (* u u u)))))
(defun c1 (x / LL uu hh)
  (if (<= x xn)
    (progn (setq LL xn uu (/ x xn) hh (herm uu LL))
      (+ (* 0.0 (nth 0 hh)) (* pi (nth 1 hh)) (* wn (nth 2 hh)) (* gn (nth 3 hh))))
    (progn (setq LL (- 1.0 xn) uu (/ (- x xn) LL) hh (herm uu LL))
      (+ (* wn (nth 0 hh)) (* gn (nth 1 hh)) (* 0.0 (nth 2 hh)) (* (- pi) (nth 3 hh))))))
(setq i 0 xa 0.0 ya 0.0)
(while (< i 40)
  (setq xb (/ (+ i 1) 40.0) yb (c1 xb))
  (linea xa ya xb yb 3 "C1")
  (setq xa xb ya yb i (+ i 1)))
;; pendientes en el nudo, leídas de lo dibujado
(setq sL0 (/ wn xn) sR0 (/ (- 0.0 wn) (- 1.0 xn)) salto0 (- sR0 sL0))
(setq dh 0.0001)
(setq sL1 (/ (- (c1 xn) (c1 (- xn dh))) dh) sR1 (/ (- (c1 (+ xn dh)) (c1 xn)) dh) salto1 (- sR1 sL1))
;; tangentes en el nudo (amarillo): C0 dos, C1 una
(linea (- xn 0.16) (- wn (* sL0 0.16)) xn wn 2 "TANGENTES")
(linea xn wn (+ xn 0.16) (+ wn (* sR0 0.16)) 2 "TANGENTES")
(linea (- xn 0.16) (- wn (* gn 0.16)) (+ xn 0.16) (+ wn (* gn 0.16)) 2 "TANGENTE-C1")
(texto 0.02 1.25 "C0 (rojo): dos pendientes distintas en el nudo" 0.05 1 "TEXTOS")
(texto 0.02 1.15 "C1 (verde): una sola pendiente" 0.05 3 "TEXTOS")
#fin
#: The six values above were measured from the drawing. **C0**: the slope jumps from sL₀ to sR₀ (jump₀, nonzero). **C1**: it goes from sL₁ to sR₁ and jump₁ ≈ 0 (the tiny difference comes from measuring at ±0.00015 from the node).

## 2 · Where the requirement comes from: the energy
#: The energy of a thin plate (Kirchhoff) contains the **second** derivative: U = ½ ∫ D·(w″)² dx. If the slope w′ **jumps** at the node, its derivative w″ is an infinite spike there (a Dirac delta), and the integral **does not exist**. That is why a thin plate asks for **C1**.
#: A thick plate (Mindlin) has the deflection w and the rotation θ as **independent** unknowns and in the energy only their **first** derivatives appear (θ′ and w′−θ). **C0** is enough for that.
#: **Summary:** pure Kirchhoff → C1 (hard to achieve in an element). Mindlin → C0 (easy). DKQ and MITC4 use rotations as unknowns (C0) and **enforce** Kirchhoff at points or sides: that is why they settle for C0.

## 3 · In a plate (3D): four elements, the surface w = sin(πx)·sin(πy)
#: Mesh of 2×2 elements with nodes at x = 0, 0.4, 1 and y = 0, 0.5, 1. On the left, **C0** elements (bilinear: only the node deflection). On the right, **C1** elements (bicubic Hermite, BFS type: deflection, rotations and twist at each node).
#: Yellow lines: the shared edges. Red and blue lines: the surface **normal** at a point of the edge, computed from each side. In C0 they **open up**; in C1 they **coincide**.

#autolisp("3D plate: C0 (left) and C1 (right)", ancho = 190, alto = 130, exporta = ang0 ang1)
(setq xs (list 0.0 0.4 1.0) ys (list 0.0 0.5 1.0))
(defun fw (x y) (* (sin (* pi x)) (sin (* pi y))))
(defun fwx (x y) (* pi (cos (* pi x)) (sin (* pi y))))
(defun fwy (x y) (* pi (sin (* pi x)) (cos (* pi y))))
(defun fwxy (x y) (* pi pi (cos (* pi x)) (cos (* pi y))))
(defun herm (u L)
  (list (+ (- 1 (* 3 u u)) (* 2 u u u))
        (* L (+ (- u (* 2 u u)) (* u u u)))
        (- (* 3 u u) (* 2 u u u))
        (* L (+ (- (* u u)) (* u u u)))))
(defun ev (tipo ie je x y)
  (setq x0 (nth ie xs) x1 (nth (+ ie 1) xs) y0 (nth je ys) y1 (nth (+ je 1) ys))
  (setq lx (- x1 x0) ly (- y1 y0) u (/ (- x x0) lx) v (/ (- y y0) ly))
  (if (= tipo 0)
    (+ (* (fw x0 y0) (- 1 u) (- 1 v)) (* (fw x1 y0) u (- 1 v))
       (* (fw x0 y1) (- 1 u) v) (* (fw x1 y1) u v))
    (progn
      (setq hx (herm u lx) hy (herm v ly))
      (+ (* (fw x0 y0) (nth 0 hx) (nth 0 hy)) (* (fwx x0 y0) (nth 1 hx) (nth 0 hy))
         (* (fwy x0 y0) (nth 0 hx) (nth 1 hy)) (* (fwxy x0 y0) (nth 1 hx) (nth 1 hy))
         (* (fw x1 y0) (nth 2 hx) (nth 0 hy)) (* (fwx x1 y0) (nth 3 hx) (nth 0 hy))
         (* (fwy x1 y0) (nth 2 hx) (nth 1 hy)) (* (fwxy x1 y0) (nth 3 hx) (nth 1 hy))
         (* (fw x0 y1) (nth 0 hx) (nth 2 hy)) (* (fwx x0 y1) (nth 1 hx) (nth 2 hy))
         (* (fwy x0 y1) (nth 0 hx) (nth 3 hy)) (* (fwxy x0 y1) (nth 1 hx) (nth 3 hy))
         (* (fw x1 y1) (nth 2 hx) (nth 2 hy)) (* (fwx x1 y1) (nth 3 hx) (nth 2 hy))
         (* (fwy x1 y1) (nth 2 hx) (nth 3 hy)) (* (fwxy x1 y1) (nth 3 hx) (nth 3 hy))))))
(defun aci (z) (cond ((< z 0.2) 5) ((< z 0.4) 4) ((< z 0.6) 3) ((< z 0.8) 2) (t 1)))
(defun pto (tipo ie je x y dx) (list (+ x dx) y (ev tipo ie je x y)))
(defun superficie (tipo dx lay)
  (foreach ie '(0 1)
    (foreach je '(0 1)
      (setq x0 (nth ie xs) x1 (nth (+ ie 1) xs) y0 (nth je ys) y1 (nth (+ je 1) ys))
      (setq col (if (= (rem (+ ie je) 2) 0) 4 5))
      (foreach i '(0 1 2 3 4 5)
        (foreach j '(0 1 2 3 4 5)
          (setq xa (+ x0 (* (- x1 x0) (/ i 6.0))) xb (+ x0 (* (- x1 x0) (/ (+ i 1) 6.0)))
                ya (+ y0 (* (- y1 y0) (/ j 6.0))) yb (+ y0 (* (- y1 y0) (/ (+ j 1) 6.0))))
          (setq p1 (pto tipo ie je xa ya dx) p2 (pto tipo ie je xb ya dx) p3 (pto tipo ie je xb yb dx) p4 (pto tipo ie je xa yb dx))
          (setq col (aci (/ (+ (caddr p1) (caddr p2) (caddr p3) (caddr p4)) 4.0)))
          (entmake (list '(0 . "3DFACE") (cons 8 lay) (cons 62 col)
                         (cons 10 p1) (cons 11 p2) (cons 12 p3) (cons 13 p4)))))))
  ;; aristas compartidas en amarillo: x = 0.4 (todo y) y y = 0.5 (todo x)
  (foreach k '(0 1 2 3 4 5 6 7 8 9)
    (setq ya (/ k 10.0) yb (/ (+ k 1) 10.0))
    (setq je (if (< ya 0.5) 0 1))
    (entmake (list '(0 . "LINE") (cons 8 "ARISTAS") (cons 62 2) (cons 10 (pto tipo 0 je 0.4 ya dx)) (cons 11 (pto tipo 0 je 0.4 yb dx))))
    (setq xa (/ k 10.0) xb (/ (+ k 1) 10.0))
    (setq ie (if (< xa 0.4) 0 1))
    (entmake (list '(0 . "LINE") (cons 8 "ARISTAS") (cons 62 2) (cons 10 (pto tipo ie 0 xa 0.5 dx)) (cons 11 (pto tipo ie 0 xb 0.5 dx))))))
;; normal a cada lado de la arista x = 0.4, en y = 0.25 (elemento izquierdo ie=0, derecho ie=1)
(defun normal (tipo ie x y sgn)
  (setq h 0.0005)
  (setq wx (/ (- (ev tipo ie 0 (+ x (* sgn h)) y) (ev tipo ie 0 x y)) (* sgn h)))
  (setq wy (/ (- (ev tipo ie 0 x (+ y h)) (ev tipo ie 0 x y)) h))
  (setq nn (sqrt (+ (* wx wx) (* wy wy) 1.0)))
  (list (/ (- wx) nn) (/ (- wy) nn) (/ 1.0 nn)))
(defun flecha (tipo dx)
  (setq p (pto tipo 0 0 0.4 0.25 dx))
  (setq nl (normal tipo 0 0.4 0.25 -1) nr (normal tipo 1 0.4 0.25 1))
  (entmake (list '(0 . "LINE") (cons 8 "NORMALES") (cons 62 1) (cons 10 p)
                 (cons 11 (list (+ (car p) (* 0.45 (car nl))) (+ (cadr p) (* 0.45 (cadr nl))) (+ (caddr p) (* 0.45 (caddr nl)))))))
  (entmake (list '(0 . "LINE") (cons 8 "NORMALES") (cons 62 5) (cons 10 p)
                 (cons 11 (list (+ (car p) (* 0.45 (car nr))) (+ (cadr p) (* 0.45 (cadr nr))) (+ (caddr p) (* 0.45 (caddr nr)))))))
  ;; ángulo entre las dos normales, en grados
  (* (/ 180.0 pi) (acos (min 1.0 (+ (* (car nl) (car nr)) (* (cadr nl) (cadr nr)) (* (caddr nl) (caddr nr)))))))
(superficie 0 0.0 "C0")
(setq ang0 (flecha 0 0.0))
(superficie 1 1.5 "C1")
(setq ang1 (flecha 1 1.5))
(entmake (list '(0 . "TEXT") '(8 . "TEXTOS") '(62 . 7) (list 10 0.0 -0.35 0.0) (cons 40 0.08) (cons 1 "C0: la arista se quiebra")))
(entmake (list '(0 . "TEXT") '(8 . "TEXTOS") '(62 . 7) (list 10 1.5 -0.35 0.0) (cons 40 0.08) (cons 1 "C1: la arista es suave")))
#fin
#: Angle between the two normals of the edge: **C0 = ang₀°** (the surface has a fold) and **C1 = ang₁° ≈ 0** (smooth surface, the normals coincide).
