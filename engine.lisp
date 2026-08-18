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
                            ((equal a b) (list 'expt a 2))   ; x*x -> x^2
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

;;;; --- expandir: distribuye productos y potencias  (x+1)^2 -> x^2 + 2*x + 1 ---

(defun expand-mul (a b)
  "Multiplica a*b distribuyendo si alguno es suma/resta."
  (cond
    ((and (consp a) (member (car a) '(+ -)))
     (list (car a) (expand-mul (second a) b) (expand-mul (third a) b)))
    ((and (consp b) (member (car b) '(+ -)))
     (list (car b) (expand-mul a (second b)) (expand-mul a (third b))))
    (t (list '* a b))))

(defun expand (e)
  "Expande productos sobre sumas y potencias enteras (polinomios)."
  (if (atom e) e
      (let ((op (car e)) (a (expand (second e))) (b (expand (third e))))
        (cond
          ((eq op '*) (expand-mul a b))
          ((eq op 'expt)
           (cond ((eql b 1) a)
                 ((and (integerp b) (> b 1)) (expand (list '* a (list 'expt a (1- b)))))
                 (t (list 'expt a b))))
          (t (list op a b))))))

;;;; ==========================================================================
;;;; MOTOR DE POLINOMIOS con coeficientes RACIONALES (exacto).
;;;; Un polinomio = alist (monomio . coef).  Monomio = alist ordenado
;;;; ((var . potencia) ...), constante = NIL.  Coef = racional de Lisp (1/2, -3).
;;;; Esto da simplify/expand/deriv EXACTOS para funciones de forma y la matriz D.
;;;; ==========================================================================

(defun vars-of (e)
  "Variables (simbolos) libres en la formula, sin repetir."
  (cond ((numberp e) nil)
        ((symbolp e) (list e))
        ((consp e) (remove-duplicates (mapcan #'vars-of (cdr e))))
        (t nil)))

(defun mono-mul (m1 m2)
  "Producto de monomios: suma potencias de la misma variable; ordena por nombre."
  (let ((res (copy-alist m1)))
    (dolist (pr m2)
      (let ((cell (assoc (car pr) res)))
        (if cell (incf (cdr cell) (cdr pr))
            (setf res (append res (list (cons (car pr) (cdr pr))))))))
    (sort (remove-if (lambda (pr) (zerop (cdr pr))) res)
          #'string< :key (lambda (pr) (string (car pr))))))

(defun mono-degree (m) (reduce #'+ (mapcar #'cdr m) :initial-value 0))

(defun p+ (p q)
  "Suma de polinomios (combina monomios iguales, tira los de coef 0)."
  (let ((res (copy-alist p)))
    (dolist (term q)
      (let ((cell (assoc (car term) res :test #'equal)))
        (if cell (incf (cdr cell) (cdr term))
            (setf res (append res (list (cons (car term) (cdr term))))))))
    (remove-if (lambda (term) (zerop (cdr term))) res)))

(defun p-scale (p c)
  (if (zerop c) nil (mapcar (lambda (term) (cons (car term) (* (cdr term) c))) p)))

(defun p* (p q)
  (let ((res nil))
    (dolist (a p)
      (dolist (b q)
        (setf res (p+ res (list (cons (mono-mul (car a) (car b))
                                      (* (cdr a) (cdr b))))))))
    res))

(defun p-const (c) (if (zerop c) nil (list (cons nil c))))
(defun p-var (v) (list (cons (list (cons v 1)) 1)))

(defun p-constant (p)
  "Valor si el polinomio es constante; :nc si no lo es."
  (cond ((null p) 0)
        ((and (null (cdr p)) (null (caar p))) (cdar p))
        (t :nc)))

(defun expr->poly (e)
  "Formula LISP -> polinomio racional.  Lanza 'notpoly con :fail si no es polinomio
   (p.ej. division por algo NO constante, potencia no entera, funcion desconocida)."
  (cond
    ((integerp e) (p-const e))
    ((rationalp e) (p-const e))
    ((floatp e) (p-const (rationalize e)))          ; 0.2 -> 1/5 (exacto)
    ((symbolp e) (p-var e))
    ((consp e)
     (let ((op (car e)))
       (cond
         ((eq op '+) (p+ (expr->poly (second e)) (expr->poly (third e))))
         ((eq op '-) (if (cddr e)
                         (p+ (expr->poly (second e)) (p-scale (expr->poly (third e)) -1))
                         (p-scale (expr->poly (second e)) -1)))   ; menos unario
         ((eq op '*) (p* (expr->poly (second e)) (expr->poly (third e))))
         ((eq op '/) (let* ((d (expr->poly (third e))) (dc (p-constant d)))
                       (if (or (eq dc :nc) (zerop dc))
                           (throw 'notpoly :fail)      ; denominador no constante -> no polinomio
                           (p-scale (expr->poly (second e)) (/ 1 dc)))))
         ((eq op 'expt) (let ((n (third e)))
                          (if (and (integerp n) (>= n 0))
                              (let ((r (p-const 1)))
                                (dotimes (i n) (setf r (p* r (expr->poly (second e)))))
                                r)
                              (throw 'notpoly :fail))))
         (t (throw 'notpoly :fail)))))
    (t (throw 'notpoly :fail))))

(defun try-poly (e) (catch 'notpoly (expr->poly e)))

(defun mono->expr (m)
  (if (null m) 1
      (reduce (lambda (a b) (list '* a b))
              (mapcar (lambda (pr) (if (= (cdr pr) 1) (car pr)
                                       (list 'expt (car pr) (cdr pr))))
                      m))))

(defun coeff->expr (c) (if (integerp c) c (list '/ (numerator c) (denominator c))))

(defun neg-expr (e)
  "Niega una expresion ya construida, de forma legible (sin romperse con simbolos)."
  (cond ((numberp e) (- e))
        ((and (consp e) (eq (car e) '/) (numberp (second e))) (list '/ (- (second e)) (third e)))
        (t (list '* -1 e))))

(defun term->expr (m c)
  "Monomio m con coef POSITIVO c (racional) -> expresion legible:
   1->mono, entero->n*mono, p/q -> (p*mono)/q  (asi 1/2*nu se ve como nu/2)."
  (cond ((null m) (coeff->expr c))
        ((= c 1) (mono->expr m))
        ((integerp c) (list '* c (mono->expr m)))
        (t (let ((num (numerator c)) (den (denominator c)))
             (list '/ (if (= num 1) (mono->expr m) (list '* num (mono->expr m))) den)))))

(defun poly->expr (p)
  "Polinomio -> formula LISP legible. Positivos primero (grado desc), luego los
   negativos como restas -> queda '1 - s^2', 's - 1/2', 'nu/2', etc."
  (if (null p) 0
      (let* ((bydeg (sort (copy-alist p) #'> :key (lambda (tm) (mono-degree (car tm)))))
             (pos (remove-if     (lambda (tm) (minusp (cdr tm))) bydeg))
             (neg (remove-if-not (lambda (tm) (minusp (cdr tm))) bydeg))
             (terms (append pos neg))
             (acc nil))
        (dolist (tm terms)
          (let* ((m (car tm)) (c (cdr tm)) (isneg (minusp c))
                 (e (term->expr m (abs c))))
            (setf acc
                  (cond ((null acc) (if isneg (neg-expr e) e))
                        (isneg (list '- acc e))
                        (t     (list '+ acc e))))))
        acc)))

(defun simplify (e)
  "Simplifica EXACTO via polinomios; si no es polinomio, cae al motor viejo."
  (let ((p (try-poly e)))
    (if (eq p :fail) (collect-in (simp* e)) (poly->expr p))))

(defun expand* (e) "Expande y simplifica (mismo motor de polinomios)." (simplify e))

(defun poly-deriv (p v)
  "Derivada del polinomio p respecto a v."
  (let ((res nil))
    (dolist (tm p)
      (let* ((m (car tm)) (c (cdr tm)) (cell (assoc v m)))
        (when cell
          (let* ((k (cdr cell))
                 (rest (remove v (copy-alist m) :key #'car))
                 (m2 (if (> k 1) (cons (cons v (1- k)) rest) rest))
                 (m2 (sort m2 #'string< :key (lambda (pr) (string (car pr))))))
            (setf res (p+ res (list (cons m2 (* c k)))))))))
    res))

(defun derive-x (e)
  "Deriva respecto a la variable DETECTADA (no fija a x) y simplifica."
  (let* ((vs (vars-of e)) (v (if vs (car vs) 'x)) (p (try-poly e)))
    (if (eq p :fail) (simplify (deriv e v)) (poly->expr (poly-deriv p v)))))

(defun poly-integ (p v)
  "Integral indefinida del polinomio p respecto a v:  c*v^n -> c/(n+1) * v^(n+1)."
  (let ((res nil))
    (dolist (tm p)
      (let* ((m (car tm)) (c (cdr tm)) (cell (assoc v m))
             (k (if cell (cdr cell) 0))
             (rest (if cell (remove v (copy-alist m) :key #'car) (copy-alist m)))
             (m2 (sort (cons (cons v (1+ k)) rest)
                       #'string< :key (lambda (pr) (string (car pr))))))
        (setf res (p+ res (list (cons m2 (/ c (1+ k))))))))
    res))

(defun integ-x (e)
  "Integral indefinida respecto a la variable DETECTADA (solo polinomios; sin +C)."
  (let* ((vs (vars-of e)) (v (if vs (car vs) 'x)) (p (try-poly e)))
    (if (eq p :fail) e (poly->expr (poly-integ p v)))))

(defun subst-var (e v val)
  "Sustituye la variable v por val (numero) en la formula e."
  (cond ((numberp e) e)
        ((symbolp e) (if (eq e v) val e))
        ((consp e) (cons (car e) (mapcar (lambda (x) (subst-var x v val)) (cdr e))))
        (t e)))

(defun defint-x (e a b)
  "Integral DEFINIDA de e entre a y b (regla de Barrow: F(b)-F(a)), variable detectada."
  (let* ((vs (vars-of e)) (v (if vs (car vs) 'x)) (p (try-poly e)))
    (if (eq p :fail) e
        (let* ((f (poly->expr (poly-integ p v)))
               (fb (simplify (subst-var f v b)))
               (fa (simplify (subst-var f v a))))
          (simplify (list '- fb fa))))))
