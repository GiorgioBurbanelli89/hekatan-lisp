# Continuidad C0 y C1: de dónde sale, dibujada
#: **La idea (y = m·x + b):** una recta se puede quebrar en un punto y sigue siendo continua. Eso es C0: la curva no se rompe, pero la **pendiente da un salto**. C1 pide algo más: que la **pendiente tampoco salte**.
#: En un elemento finito, w(x) es la flecha y su pendiente es el giro w′(x). Dos elementos comparten un nudo: C0 = misma flecha en el nudo; C1 = misma flecha **y el mismo giro**.

## 1 · En una viga (2D): dos elementos que se juntan en x = 0.4
#: La curva exacta es w = sen(πx), en gris. Con un nudo en x = 0.4 y otro en cada extremo:
#: rojo = elemento **C0** (solo se da la flecha del nudo, entre nudos es recta); verde = elemento **C1** (se dan flecha **y giro** del nudo, Hermite cúbico).
#: Las líneas cortas amarillas son las tangentes en el nudo: C0 tiene DOS (una por elemento), C1 tiene UNA.
xn = 0.4 'posición del nudo compartido
wn = sin(pi*xn) 'flecha en el nudo (la comparten los dos)
gn = pi*cos(pi*xn) 'giro exacto en el nudo

#autolisp("C0 quiebra, C1 no", ancho = 150, alto = 90, exporta = sL0 sR0 salto0 sL1 sR1 salto1)
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
#: Los seis valores de arriba se midieron del dibujo. **C0**: la pendiente salta de sL₀ a sR₀ (salto₀, distinto de cero). **C1**: va de sL₁ a sR₁ y salto₁ ≈ 0 (la diferencia mínima viene de medir a ±0.00015 del nudo).

## 2 · De dónde sale la exigencia: la energía
#: La energía de una placa delgada (Kirchhoff) contiene la **segunda** derivada: U = ½ ∫ D·(w″)² dx. Si la pendiente w′ **salta** en el nudo, su derivada w″ es un pico infinito ahí (una delta de Dirac), y la integral **no existe**. Por eso una placa delgada pide **C1**.
#: Una placa gruesa (Mindlin) tiene la flecha w y el giro θ como incógnitas **independientes** y en la energía solo aparecen sus **primeras** derivadas (θ′ y w′−θ). Con eso basta **C0**.
#: **Resumen:** Kirchhoff puro → C1 (difícil de lograr en un elemento). Mindlin → C0 (fácil). DKQ y MITC4 usan giros como incógnitas (C0) y **fuerzan** Kirchhoff en puntos o lados: por eso se conforman con C0.

## 3 · En una placa (3D): cuatro elementos, la superficie w = sen(πx)·sen(πy)
#: Malla de 2×2 elementos con nudos en x = 0, 0.4, 1 y y = 0, 0.5, 1. A la izquierda, elementos **C0** (bilineales: solo la flecha del nudo). A la derecha, elementos **C1** (bicúbicos de Hermite, tipo BFS: flecha, giros y torsión en cada nudo).
#: Líneas amarillas: las aristas compartidas. Líneas rojas y azules: la **normal** de la superficie en un punto de la arista, calculada desde cada lado. En C0 se **abren**; en C1 **coinciden**.

#autolisp("Placa 3D: C0 (izquierda) y C1 (derecha)", ancho = 190, alto = 130, exporta = ang0 ang1)
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
#: Ángulo entre las dos normales de la arista: **C0 = ang₀°** (la superficie tiene un pliegue) y **C1 = ang₁° ≈ 0** (superficie suave, las normales coinciden).
