;;;; ================================================================
;;;; LA INTEGRAL — definicion historica (Riemann, s. XIX)
;;;; ================================================================
;;;; La integral nacio del problema del AREA bajo una curva:
;;;;   parte [a,b] en n pedazos de ancho dx = (b-a)/n;
;;;;   suma el area de los rectangulos:  SUM f(x_i) * dx  (suma de Riemann);
;;;;   cuando n -> infinito, la suma tiende al AREA exacta = la INTEGRAL:
;;;;       integral_a^b f(x) dx = lim_{n->inf} SUM f(x_i) * dx
;;;;
;;;; Ejemplo:  area bajo  f(x) = x^2  entre 0 y 1.
;;;; Valor exacto = integral x^2 dx |_0^1 = x^3/3 |_0^1 = 1/3.
;;;; La grafica muestra la curva F cuya area (entre 0 y 1) vamos aproximando:
;fplot(F, [0 1])

(format t "f(x) = x^2 ;  area entre 0 y 1~%~%")
(format t "  F = ~a~%" '(expt x 2))
(format t "  primitiva (integral indefinida) = ~a~%" (infix (integ-x '(expt x 2))))   ; x^3/3
(format t "~%suma de RIEMANN (rectangulos) cuando n crece:~%")
(dolist (n '(4 10 100 1000))
  (let ((s 0))
    (dotimes (i n)
      (setf s (+ s (* (expt (* (1+ i) (/ 1 n)) 2) (/ 1 n)))))   ; f(x_i)*dx, x_i = (i+1)/n
    (format t "  n = ~5a  ->  suma = ~14a ~~ ~a~%" n s (float s))))
(format t "~%... la suma TIENDE a 1/3 = 0.3333...~%")
(format t "area exacta = integral_0^1 x^2 dx = 1/3~%")
