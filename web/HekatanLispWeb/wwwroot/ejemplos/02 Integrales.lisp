;;;; Integrales indefinidas respecto a x  (integ-x).
(dolist (e '((expt x 2)
             (+ x 1)
             (* 3 (expt x 2))
             (/ 1 (expt x 2))))
  (format t "~a~%" (integ-x e)))
