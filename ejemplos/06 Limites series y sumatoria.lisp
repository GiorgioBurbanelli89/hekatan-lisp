;;;; Limites, series de Taylor, sumatoria, y derivada POR DEFINICION.
;;;; (la derivada es un limite; la integral, el limite de una suma)

;; --- DERIVADA POR DEFINICION: f'(x) = lim_{h->0} (f(x+h)-f(x))/h ---
(format t "d/dx x^2  (por definicion) = ~a~%" (deriv-def '(expt x 2)))
(format t "d/dx x^3  (por definicion) = ~a~%" (deriv-def '(expt x 3)))

;; --- SUMATORIA finita ---
(format t "suma i, 1..100 = ~a~%" (suma 'i 'i 1 100))
(format t "suma i^2, 1..4 = ~a~%" (suma '(expt i 2) 'i 1 4))

;; --- SERIE DE TAYLOR alrededor de 0 ---
(format t "sin x ~~ ~a~%" (taylor '(sin x) 7))
(format t "e^x  ~~ ~a~%" (taylor '(exp x) 4))
(format t "cos x ~~ ~a~%" (taylor '(cos x) 6))

;; --- LIMITES (0/0 con L'Hopital) ---
(format t "lim x->0 sin(x)/x = ~a~%" (limite '(/ (sin x) x) 'x 0))
(format t "lim x->1 (x^2-1)/(x-1) = ~a~%" (limite '(/ (- (expt x 2) 1) (- x 1)) 'x 1))
