;;;; ================================================================
;;;; LA DERIVADA — definicion historica (Newton / Leibniz, s. XVII)
;;;; ================================================================
;;;; La derivada nacio del problema de la TANGENTE:
;;;;   toma la recta SECANTE que corta la curva en x y en x+h;
;;;;   su pendiente es  [ f(x+h) - f(x) ] / h .
;;;;   Cuando h -> 0, la secante se vuelve la TANGENTE, y esa pendiente
;;;;   es la DERIVADA:      f'(x) = lim_{h->0} [f(x+h) - f(x)] / h
;;;;
;;;; Ejemplo con  f(x) = x^2.  La tangente en x0=1 tiene pendiente f'(1)=2.
;;;; La grafica muestra la PARABOLA (F) y su TANGENTE en x=1 (T=2x-1):
;;;; se tocan en (1,1).
;fplot(F, T, [-1 3])

(format t "f(x) = x^2 ;  probamos la definicion en x0 = 1~%~%")
(format t "  F = ~a~%" '(expt x 2))                    ; la parabola
(format t "  T = ~a~%" '(- (* 2 x) 1))                 ; tangente en x=1:  1 + 2(x-1) = 2x-1
(format t "~%pendiente de la SECANTE cuando h se hace chico (x0=1):~%")
(dolist (h '(1 1/2 1/10 1/100 1/1000))
  (format t "  h = ~8a  ->  pendiente = ~a~%"
          h (simplify (list '/ (list '- (subst-var '(expt x 2) 'x (+ 1 h))
                                        (subst-var '(expt x 2) 'x 1)) h))))
(format t "~%... la pendiente TIENDE a 2.~%")
(format t "derivada POR DEFINICION:  f'(x) = ~a~%" (infix (deriv-def '(expt x 2))))
(format t "en x0=1:  f'(1) = 2   (la pendiente de la tangente)~%")
