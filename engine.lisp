;;;; engine.lisp — motor simbolico de Hekatan LISP. Corre en SBCL.
;;;; deriv: deriva.  simplif: limpia.  dsimp: deriva y simplifica hasta el fondo.

(defun deriv (e x)
  "Derivada de la formula E (arbol LISP) respecto a la variable X."
  (cond
    ((numberp e) 0)
    ((symbolp e) (if (eq e x) 1 0))
    ((eq (car e) '+) (list '+ (deriv (second e) x) (deriv (third e) x)))
    ((eq (car e) '-) (list '- (deriv (second e) x) (deriv (third e) x)))
    ((eq (car e) '*)                       ; regla del producto
     (list '+ (list '* (second e) (deriv (third e) x))
              (list '* (deriv (second e) x) (third e))))
    ((eq (car e) '/)                       ; regla del cociente
     (let ((u (second e)) (v (third e)))
       (list '/ (list '- (list '* (deriv u x) v) (list '* u (deriv v x)))
                (list 'expt v 2))))
    ((eq (car e) 'expt)                    ; regla de la potencia (exponente constante)
     (let ((u (second e)) (n (third e)))
       (list '* (list '* n (list 'expt u (- n 1))) (deriv u x))))
    (t (error "no se derivar: ~a" e))))

(defun simplif (e)
  "Una pasada de reglas obvias: 0+x=x, 1*x=x, 0*x=0, numeros se operan."
  (if (atom e) e
      (let ((op (car e))
            (a (simplif (second e)))
            (b (simplif (third e))))
        (cond
          ((eq op '+) (cond ((eql a 0) b) ((eql b 0) a)
                            ((and (numberp a) (numberp b)) (+ a b))
                            (t (list '+ a b))))
          ((eq op '-) (cond ((eql b 0) a)
                            ((and (numberp a) (numberp b)) (- a b))
                            (t (list '- a b))))
          ((eq op '*) (cond ((or (eql a 0) (eql b 0)) 0)
                            ((eql a 1) b) ((eql b 1) a)
                            ((and (numberp a) (numberp b)) (* a b))
                            (t (list '* a b))))
          ((eq op '/) (cond ((eql a 0) 0) ((eql b 1) a)
                            ((and (numberp a) (numberp b)) (/ a b))  ; 6/4 -> 3/2 (racional)
                            (t (list '/ a b))))
          ((eq op 'expt) (cond ((eql b 1) a) ((eql b 0) 1)
                               ((and (numberp a) (numberp b)) (expt a b))  ; 2^2 -> 4
                               (t (list 'expt a b))))
          (t (list op a b))))))

(defun simp* (e)
  "Aplica simplif hasta que ya no cambie (punto fijo)."
  (let ((s (simplif e))) (if (equal s e) s (simp* s))))

(defun dsimp (e x) (simp* (deriv e x)))

;;;; --- combinar terminos semejantes: x^2 + x^2 -> 2*x^2, 3*x + 2*x -> 5*x ---

(defun sum-terms (e)
  "Lista de sumandos de una suma anidada (+ (+ a b) c) -> (a b c)."
  (if (and (consp e) (eq (car e) '+))
      (append (sum-terms (second e)) (sum-terms (third e)))
      (list e)))

(defun coeff-base (term)
  "(coef . base): separa el factor numerico de un producto  n*base."
  (cond ((numberp term) (cons term 1))
        ((and (consp term) (eq (car term) '*) (numberp (second term)))
         (cons (second term) (third term)))
        (t (cons 1 term))))

(defun collect-sum (terms)
  "Suma combinando semejantes. Agrupa por 'base' y suma coeficientes."
  (let ((groups '()))
    (dolist (tm terms)
      (let* ((cb (coeff-base tm)) (c (car cb)) (b (cdr cb))
             (g (assoc b groups :test #'equal)))
        (if g (setf (cdr g) (+ (cdr g) c))
            (setf groups (append groups (list (cons b c)))))))
    (let ((out '()))
      (dolist (g groups)
        (let ((b (car g)) (c (cdr g)))
          (unless (eql c 0)
            (setf out (append out
              (list (cond ((equal b 1) c)          ; base 1 -> solo el numero
                          ((eql c 1) b)            ; coef 1 -> solo la base
                          (t (list '* c b)))))))))
      (cond ((null out) 0)
            ((null (cdr out)) (car out))
            (t (reduce (lambda (a b) (list '+ a b)) out))))))

(defun collect-in (e)
  "Aplica collect-sum a cada suma del arbol (recursivo)."
  (if (atom e) e
      (if (eq (car e) '+)
          (collect-sum (mapcar #'collect-in (sum-terms e)))
          (cons (car e) (mapcar #'collect-in (cdr e))))))

(defun simplify (e)
  "Simplifica de verdad: reglas obvias (simp*) + combina terminos semejantes."
  (collect-in (simp* e)))
