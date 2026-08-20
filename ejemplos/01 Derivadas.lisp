;;;; Derivadas respecto a x  (derive-x).  El resultado se renderiza a la derecha.
;;;; Cambia las expresiones y pulsa ▶ Ejecutar.
(dolist (e '((+ (expt x 2) (* 3 x))
             (* x (sin x))
             (/ 1 x)
             (sqrt x)
             (exp (* 2 x))))
  (format t "~a~%" (derive-x e)))
