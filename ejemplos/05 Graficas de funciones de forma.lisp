;;;; Deduce las funciones de forma Y las GRAFICA.
;;;; La directiva va en comentario ;  (estilo MATLAB fplot). Rango [-1 1].
;fplot(N1, N2, N3, [-1 1])
(defun prod (lst) (if (= (length lst) 1) (car lst) (cons '* lst)))
(defun factores (nodes i)
  (let ((xi (nth i nodes)) (fn nil) (fd nil))
    (dotimes (j (length nodes))
      (unless (= j i)
        (push (list '- 's (nth j nodes)) fn)
        (push (list '- xi (nth j nodes)) fd)))
    (list '/ (prod (reverse fn)) (prod (reverse fd)))))
(format t "1D CUADRATICA (3 nodos):~%")
(dotimes (i 3)
  (format t "  N~a = ~a~%" (1+ i) (expand* (factores '(-1 0 1) i))))
