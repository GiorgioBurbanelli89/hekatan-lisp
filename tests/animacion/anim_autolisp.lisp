# Bloque AutoLISP animado
#anim(k = 3:8)
#autolisp("Polígono de {k} lados", ancho = 80, alto = 80)
(setq pts (mapcar '(lambda (i) (polar '(0 0) (/ (* 2 pi i) k) 1.0)) '(0 1 2 3 4 5 6 7)))
(entmake (list '(0 . "CIRCLE") '(10 0 0) '(40 . 1.0)))
(setq i 0)
(repeat k (entmake (list '(0 . "LINE") (cons 10 (polar '(0 0) (/ (* 2 pi i) k) 1.0)) (cons 11 (polar '(0 0) (/ (* 2 pi (+ i 1)) k) 1.0)))) (setq i (+ i 1)))
#fin
#voz: Polígono regular de {k} lados inscrito en la circunferencia.
