;;;; simplify junta y limpia (0+x, 1*x…).  expand* distribuye.
(format t "~a~%" (simplify '(+ (* 0 x) (* 1 y))))
(format t "~a~%" (expand* '(* (+ x 1) (+ x 2))))
(format t "~a~%" (expand* '(expt (+ x 1) 2)))
(format t "~a~%" (simplify '(+ x x x)))
