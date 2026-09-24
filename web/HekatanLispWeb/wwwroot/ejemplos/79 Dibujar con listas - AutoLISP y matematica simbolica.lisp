# Dibujar con listas: la matemática simbólica hecha gráfica

#: En Hekatan LISP **el código es la lista de datos**. Una línea no es un objeto escondido: es una lista de asociación DXF, la misma que usa AutoLISP en AutoCAD: **((0 . "LINE") (8 . "0") (10 0 0) (11 3 4))**. Se arma con list, cons y mapcar, se guarda en una variable, se transforma con funciones, y recién **entmake** la pone en el dibujo. Al revés, **ssget** y **entget** leen lo dibujado como listas, y con esas listas se sigue calculando.
#: Un bloque **#autolisp … #fin** es código LISP. Ve las definiciones de la hoja que van antes (f, P, q…) y devuelve a la hoja los valores que se piden con **exporta**. Guardar el dibujo: **(guardar "nombre.dxf")** (también .svg, .png y .pdf) o los botones bajo cada dibujo.

## 1. Lo simple: una función, su derivada, su tangente y su área

#: La función se escribe en la hoja. El motor simbólico hace el resto: deriva, despeja f′(x) = 0, integra, y cada resultado se dibuja y se rotula con su fórmula.
f(x) = x^3 - 6*x^2 + 9*x + 1
x_0 = 2 'punto de la tangente

#autolisp("f(x), su derivada simbólica, la tangente en x₀ y el área entre 0 y 3", ancho = 165, alto = 125, vert = 0.45, exporta = m_t A_exacta A_dibujo)
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

#: La pendiente de la tangente sale de la derivada simbólica evaluada en x₀, y el área del dibujo (un polígono de 60 tramos) se lee con **area** y se compara con la integral exacta:
e_A = (A_dibujo - A_exacta)/A_exacta 'error relativo del polígono

## 2. Lo AutoLISP: entmake, ssget, sslength

#: El caso de partida, tal cual se escribe en AutoCAD. El punto sale de un cálculo; la cuenta de líneas, de leer el dibujo. Las cuatro líneas son UNA lista L_1 girada con una función de cuatro líneas (**subst** + **polar**): la entidad es un dato que se transforma antes de dibujarlo. Este bloque es AutoLISP puro: pegado en AutoCAD da el mismo dibujo.
#autolisp("Del cálculo al dibujo y del dibujo al cálculo", ancho = 120, alto = 70, exporta = n S_m, autocad = si)
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

#: El dibujo tiene @n líneas, y la suma de las pendientes leídas, S_m = −(tan 0° + tan 15° + tan 30° + tan 45°), vuelve a la hoja.

## 3. Un plano paramétrico: la zapata que sale del cálculo

#: La carga y la presión admisible se escriben en la hoja. El LISP calcula el lado B, dibuja la planta con cotas, y después LEE el dibujo: el área de la polilínea de la zapata y la medida de la cota. Si cambias P, cambian el dibujo y lo leído.
P = 850 'carga de servicio, kN
q_adm = 200 'presión admisible, kPa

#autolisp("Zapata aislada: planta (m)", ancho = 110, alto = 100, exporta = B A_leida B_cota q_real)
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

#: Lo leído del dibujo (el área de la polilínea y la medida de la cota) vuelve a la hoja: con esa área la presión real queda por debajo de la admisible.
