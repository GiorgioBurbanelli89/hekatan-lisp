# Prueba de la ventana de dibujo
#dibujar(r, ud = m, cuadricula = 0.05)
#autolisp("Lo dibujado, leído", exporta = n_e A_r I_r)
(setq n_e (if (ssget "_X") (sslength (ssget "_X")) 0))
(setq ss (ssget "_X" '((0 . "LWPOLYLINE"))))
(defun green (V / n i p q c Ar Sx Ix)
  (setq n (length V) i 0 Ar 0.0 Sx 0.0 Ix 0.0)
  (repeat n
    (setq p (nth i V) q (nth (rem (1+ i) n) V) c (- (* (car p) (cadr q)) (* (car q) (cadr p)))
          Ar (+ Ar (/ c 2.0)) Sx (+ Sx (/ (* (+ (cadr p) (cadr q)) c) 6.0))
          Ix (+ Ix (/ (* (+ (* (cadr p) (cadr p)) (* (cadr p) (cadr q)) (* (cadr q) (cadr q))) c) 12.0)) i (1+ i)))
  (if (< Ar 0) (list (- Ar) (- Sx) (- Ix)) (list Ar Sx Ix)))
(if ss (progn
  (setq e (ssname ss 0) A_r (area e) g (green (vertices e)))
  (setq I_r (- (nth 2 g) (/ (* (nth 1 g) (nth 1 g)) (nth 0 g))))))
#fin
I_teo = 0.3*0.5^3/12 'b·h³/12
