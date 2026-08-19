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
    ((eq (car e) 'sqrt)                    ; (sqrt u)' = u' / (2*sqrt u)
     (list '/ (deriv (second e) x) (list '* 2 (list 'sqrt (second e)))))
    ((eq (car e) 'sin)                     ; (sin u)' = cos u * u'
     (list '* (list 'cos (second e)) (deriv (second e) x)))
    ((eq (car e) 'cos)                     ; (cos u)' = -sin u * u'
     (list '* (list '- 0 (list 'sin (second e))) (deriv (second e) x)))
    ((eq (car e) 'exp)                     ; (e^u)' = e^u * u'
     (list '* (list 'exp (second e)) (deriv (second e) x)))
    ((eq (car e) 'log)                     ; (ln u)' = u'/u
     (list '/ (deriv (second e) x) (second e)))
    (t (error "no se derivar: ~a" e))))

(defun simplif (e)
  "Una pasada de reglas obvias: 0+x=x, 1*x=x, 0*x=0, numeros se operan.
   Los operadores aritmeticos son BINARIOS; cualquier otra forma (sqrt, sin,
   vector con N args...) se recorre respetando TODOS sus argumentos."
  (if (atom e) e
      (let ((op (car e)))
        (if (not (and (member op '(+ - * / expt)) (= (length e) 3)))
            (cons op (mapcar #'simplif (cdr e)))   ; n-ario: no pierde argumentos
        (let ((a (simplif (second e)))
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
          (t (list op a b))))))))

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

(defun partial (e v)
  "Derivada PARCIAL respecto a la variable v (elegida). Para 2D: dN/ds, dN/dt.
   A diferencia de derive-x (que AUTODETECTA una variable), aquí TÚ das la variable."
  (let ((p (try-poly e)))
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

(defun elem-integ (e v)
  "Integral ELEMENTAL respecto a v: polinomio, sin, cos, exp, 1/v, sumas/restas y c*f.
   Devuelve :fail si no sabe integrarlo (p.ej. x*sin(x), que pide por partes)."
  (let ((p (try-poly e)))
    (if (not (eq p :fail)) (poly->expr (poly-integ p v))
        (cond
          ((atom e) (if (eq e v) (list '/ (list 'expt v 2) 2) (list '* e v)))  ; ∫v dv, ∫c dv
          ((and (eq (car e) '+) (= (length e) 3))
           (let ((a (elem-integ (second e) v)) (b (elem-integ (third e) v)))
             (if (or (eq a :fail) (eq b :fail)) :fail (simplify (list '+ a b)))))
          ((and (eq (car e) '-) (= (length e) 3))
           (let ((a (elem-integ (second e) v)) (b (elem-integ (third e) v)))
             (if (or (eq a :fail) (eq b :fail)) :fail (simplify (list '- a b)))))
          ((and (eq (car e) '-) (= (length e) 2))                       ; menos unario
           (let ((a (elem-integ (second e) v))) (if (eq a :fail) :fail (simplify (list '- 0 a)))))
          ((and (eq (car e) 'sin) (eq (second e) v)) (list '- 0 (list 'cos v)))   ; ∫sin = -cos
          ((and (eq (car e) 'cos) (eq (second e) v)) (list 'sin v))               ; ∫cos =  sin
          ((and (eq (car e) 'exp) (eq (second e) v)) (list 'exp v))               ; ∫e^v = e^v
          ((and (eq (car e) '/) (eql (second e) 1) (eq (third e) v)) (list 'log v)) ; ∫1/v = ln v
          ((and (eq (car e) '*) (numberp (second e)))                 ; c*f
           (let ((r (elem-integ (third e) v))) (if (eq r :fail) :fail (simplify (list '* (second e) r)))))
          ((and (eq (car e) '*) (numberp (third e)))                  ; f*c
           (let ((r (elem-integ (second e) v))) (if (eq r :fail) :fail (simplify (list '* (third e) r)))))
          (t :fail)))))

(defun integ-x (e)
  "Integral indefinida respecto a la variable DETECTADA (elemental; sin +C).
   Si NO sabe integrarlo devuelve (no-elem e) para que la app no muestre una primitiva falsa."
  (let* ((vs (vars-of e)) (v (if vs (car vs) 'x)) (r (elem-integ e v)))
    (if (eq r :fail) (list 'no-elem e) r)))

(defun integ-var (e v)
  "Integral indefinida respecto a la variable v ELEGIDA (elemental; para 2D)."
  (let ((r (elem-integ e v))) (if (eq r :fail) (list 'no-elem e) r)))

(defun subst-var (e v val)
  "Sustituye la variable v por val (numero) en la formula e."
  (cond ((numberp e) e)
        ((symbolp e) (if (eq e v) val e))
        ((consp e) (cons (car e) (mapcar (lambda (x) (subst-var x v val)) (cdr e))))
        (t e)))

;;;; --- alias con nombres de MATLAB (para quien viene de MATLAB) ---
;;;; OJO: NO definir 'int': es un simbolo BLOQUEADO en SBCL (paquete SB-ALIEN,
;;;; tipo C para FFI) -> romperia la carga de engine.lisp. La integral es 'integ'.
(defun diff (e) "MATLAB: diff(f) -> derivada." (derive-x e))
(defun integ (e) "Integral indefinida (MATLAB usa 'int', pero 'int' esta bloqueado)." (integ-x e))
;; simplify y expand ya se llaman igual que en MATLAB.

(defun defint-x (e a b)
  "Integral DEFINIDA de e entre a y b (regla de Barrow: F(b)-F(a)), variable detectada."
  (let* ((vs (vars-of e)) (v (if vs (car vs) 'x)) (p (try-poly e)))
    (if (eq p :fail) e
        (let* ((f (poly->expr (poly-integ p v)))
               (fb (simplify (subst-var f v b)))
               (fa (simplify (subst-var f v a))))
          (simplify (list '- fb fa))))))

;;;; --- notacion INFIJA (matematica, estilo MATLAB): (+ (* 2 x) 3) -> "2*x + 3" ---
;;;; Para que el script imprima el resultado como MATEMATICA en vez de lista LISP:
;;;;   (format t "~a~%" (infix (derive-x '(+ (expt x 2) (* 3 x)))))  ->  2*x + 3
(defun join (sep lst)
  (if (null lst) "" (reduce (lambda (a b) (concatenate 'string a sep b)) lst)))
(defun op-prec (op)
  (cond ((eq op 'expt) 4) ((member op '(* /)) 2) ((member op '(+ -)) 1) (t 0)))
(defun infix-par (e outer)
  "infix, con parentesis si la precedencia del hijo < outer. Funciones = prec alta (sin parentesis)."
  (let ((s (infix e))
        (myp (if (and (consp e) (member (car e) '(+ - * / expt))) (op-prec (car e)) 5)))
    (if (< myp outer) (concatenate 'string "(" s ")") s)))
(defun infix (e)
  "Convierte una expresion LISP a texto matematico infijo (estilo MATLAB)."
  (cond
    ((integerp e) (format nil "~a" e))
    ((rationalp e) (format nil "~a/~a" (numerator e) (denominator e)))
    ((numberp e) (format nil "~a" e))
    ((symbolp e) (string-downcase (symbol-name e)))
    ((atom e) (format nil "~a" e))
    ((eq (car e) 'vector) (concatenate 'string "[" (join " " (mapcar #'infix (cdr e))) "]"))
    ((and (eq (car e) '-) (= (length e) 2)) (concatenate 'string "-" (infix-par (second e) 3)))
    ((member (car e) '(+ *))
     (join (if (eq (car e) '+) " + " "*") (mapcar (lambda (a) (infix-par a (op-prec (car e)))) (cdr e))))
    ((member (car e) '(- /))
     (let* ((p (op-prec (car e))) (sep (if (eq (car e) '-) " - " "/")) (args (cdr e)))
       (join sep (cons (infix-par (car args) p) (mapcar (lambda (a) (infix-par a (1+ p))) (cdr args))))))
    ((eq (car e) 'expt) (concatenate 'string (infix-par (second e) 5) "^" (infix-par (third e) 5)))
    (t (concatenate 'string (string-downcase (symbol-name (car e))) "(" (join ", " (mapcar #'infix (cdr e))) ")"))))

;;;; ================= LIMITES · SERIES · SUMATORIA · POR DEFINICION =================

;; reglas: evalua funciones en puntos conocidos ( (sin 0)->0, (cos 0)->1, (exp 0)->1 ... )
(defun eval-consts (e)
  (if (atom e) e
      (let* ((f (car e)) (a (and (cdr e) (eval-consts (second e)))))
        (cond
          ((and (eq f 'sin) (eql a 0)) 0)
          ((and (eq f 'cos) (eql a 0)) 1)
          ((and (eq f 'tan) (eql a 0)) 0)
          ((and (eq f 'exp) (eql a 0)) 1)
          ((and (eq f 'log) (eql a 1)) 0)
          ((and (eq f 'sqrt) (eql a 0)) 0)
          ((and (eq f 'sqrt) (eql a 1)) 1)
          (t (cons f (mapcar #'eval-consts (cdr e))))))))

;; DERIVADA POR DEFINICION:  f'(x) = lim_{h->0} (f(x+h)-f(x))/h
;; Se expande f(x+h)-f(x) como polinomio en h; dividir por h = bajar el grado;
;; hacer h->0 = quedarse con el coeficiente de h^1. Exacto para polinomios.
(defun poly-coef-h1 (p)
  (let ((res nil))
    (dolist (tm p)
      (let* ((m (car tm)) (c (cdr tm)) (cell (assoc 'h m)))
        (when (and cell (= (cdr cell) 1))
          (setf res (p+ res (list (cons (remove 'h (copy-alist m) :key #'car) c)))))))
    res))
(defun deriv-def (e &optional (var 'x))
  "Derivada POR DEFINICION (limite del cociente). Cae a derive-x si no es polinomio."
  (let* ((fh (subst-var e var (list '+ var 'h)))
         (num (try-poly (list '- fh e))))
    (if (eq num :fail) (derive-x e) (poly->expr (poly-coef-h1 num)))))

;; SUMATORIA finita:  sum_{var=a}^{b} e
(defun suma (e var a b)
  "Sumatoria de e con var de a a b. Con limites ENTEROS suma termino a termino y
   simplifica; con limites SIMBOLICOS (n, lados) es NOTACION: devuelve la forma sin
   evaluar, para que se dibuje la Σ y no se fabrique un resultado falso."
  (if (and (integerp a) (integerp b))
      (let ((acc 0)) (loop for i from a to b do (setf acc (simplify (list '+ acc (subst-var e var i))))) acc)
      (list 'suma e var a b)))

;; SERIE DE TAYLOR alrededor de 0 hasta grado n:  sum f^(k)(0)/k! x^k
(defun fct (n) (if (<= n 1) 1 (* n (fct (1- n)))))
(defun taylor (e n &optional (var 'x))
  "Serie de Taylor de e alrededor de 0, hasta grado n. Usa las derivadas del motor."
  (let ((term e) (acc 0))
    (dotimes (k (1+ n))
      (let ((c (simplify (eval-consts (subst-var term var 0)))))
        (setf acc (list '+ acc (list '/ (list '* c (list 'expt var k)) (fct k)))))
      (setf term (eval-consts (simplify (derive-x term)))))
    (simplify acc)))

;; LIMITE:  sustituye var=a; si da 0/0 aplica L'Hopital (deriva arriba y abajo).
(defun limite (e var a)
  "Limite de e cuando var->a. Sustituye; si 0/0, L'Hopital."
  (if (and (consp e) (eq (car e) '/))
      (let ((nu (simplify (eval-consts (subst-var (second e) var a))))
            (de (simplify (eval-consts (subst-var (third e) var a)))))
        (if (and (eql nu 0) (eql de 0))
            (limite (list '/ (partial (second e) var) (partial (third e) var)) var a)
            (simplify (eval-consts (subst-var e var a)))))
      (simplify (eval-consts (subst-var e var a)))))

;;;; ================= FACTORIZAR (lo contrario de expandir) =================
;;;; simplify = factorizar/compactar:  x^2+2x+1 -> (x+1)^2 ,  (x+1)^2 se queda (x+1)^2
;;;; expand = distribuir:  (x+1)^2 -> x^2+2x+1
(defun poly->coeffs (p v)
  (let ((deg 0)) (dolist (tm p) (let ((c (assoc v (car tm)))) (setf deg (max deg (if c (cdr c) 0)))))
    (let ((arr (make-list (1+ deg) :initial-element 0)))
      (dolist (tm p) (let* ((c (assoc v (car tm))) (k (if c (cdr c) 0)))
                       (setf (nth k arr) (+ (nth k arr) (cdr tm))))) arr)))
(defun divisors (n) (setf n (abs n))
  (if (= n 0) '(1) (let (d) (loop for i from 1 to n do (when (zerop (mod n i)) (push i d))) (nreverse d))))
(defun peval (coeffs x) (let ((s 0) (p 1)) (dolist (c coeffs) (setf s (+ s (* c p)) p (* p x))) s))
(defun deflate (coeffs r)   ; Ruffini: coeffs / (x - r) -> cociente (r raiz exacta)
  (let ((bs nil) (b 0)) (dolist (a (reverse coeffs)) (setf b (+ a (* r b))) (push b bs)) (cdr bs)))
(defun coeffs->expr (coeffs v)
  (let ((p nil) (k 0)) (dolist (c coeffs)
    (unless (zerop c) (setf p (p+ p (p-scale (let ((r (p-const 1))) (dotimes (i k) (setf r (p* r (p-var v)))) r) c)))) (incf k))
    (poly->expr p)))
(defun lin-factor (b a v)   ; factor (b*v - a) legible
  (let ((vx (if (= b 1) v (list '* b v))))
    (cond ((zerop a) vx) ((> a 0) (list '- vx a)) (t (list '+ vx (- a))))))
(defun group-powers (parts) ; factores identicos -> (expt f n)
  (let ((seen nil))
    (dolist (p parts) (let ((cell (assoc p seen :test #'equal)))
      (if cell (incf (cdr cell)) (push (cons p 1) seen))))
    (mapcar (lambda (c) (if (= (cdr c) 1) (car c) (list 'expt (car c) (cdr c)))) (nreverse seen))))
(defun factor-coeffs (coeffs v)
  (let* ((L (reduce #'lcm (mapcar #'denominator coeffs) :initial-value 1))
         (ic (mapcar (lambda (c) (* c L)) coeffs))
         (g (reduce #'gcd ic :initial-value 0))
         (ic (if (zerop g) ic (mapcar (lambda (c) (/ c g)) ic)))
         (cont (/ g L)) (factors nil))
    (let ((k 0)) (loop while (and (cdr ic) (zerop (car ic))) do (pop ic) (incf k))
      (when (> k 0) (push (if (= k 1) v (list 'expt v k)) factors)))
    (loop while (> (length ic) 1) do
      (let ((c0 (car ic)) (cn (car (last ic))) (found nil))
        (block search
          (dolist (p (divisors c0)) (dolist (q (divisors cn))
            (dolist (r (list (/ p q) (/ (- p) q)))
              (when (zerop (peval ic r))
                (push (lin-factor (denominator r) (numerator r) v) factors)
                (setf ic (mapcar (lambda (cc) (/ cc (denominator r))) (deflate ic r))) (setf found t)
                (return-from search))))))
        (unless found (return))))
    (let* ((resto (unless (equal ic '(1)) (coeffs->expr ic v)))
           (parts (append (unless (= cont 1) (list (coeff->expr cont)))
                          (group-powers (reverse factors)) (and resto (list resto)))))
      (cond ((null parts) 1) ((null (cdr parts)) (car parts))
            (t (reduce (lambda (x y) (list '* x y)) parts))))))
(defun factor (e)
  "Factoriza un polinomio de UNA variable (raices racionales). Si no puede, lo reduce."
  (let ((p (try-poly e)))
    (if (eq p :fail) e (let ((vs (vars-of e)))
      (if (/= (length vs) 1) (poly->expr p) (factor-coeffs (poly->coeffs p (car vs)) (car vs)))))))

;;;; ================= DESPEJAR (resolver una ecuacion para una variable) =================
(defun psqrt (e)   ; (sqrt n) con n cuadrado perfecto -> raiz entera
  (if (and (consp e) (eq (car e) 'sqrt) (integerp (second e)) (>= (second e) 0)
           (let ((r (isqrt (second e)))) (= (* r r) (second e))))
      (isqrt (second e)) e))
(defun clean (e)   ; limpia sqrt de cuadrados y reduce por polinomios si puede
  (let ((e2 (if (atom e) e (psqrt (cons (car e) (mapcar #'clean (cdr e)))))))
    (let ((p (try-poly e2))) (if (eq p :fail) e2 (poly->expr p)))))
(defun neg-clean (e)  ; niega legible: -(a-b) -> b-a
  (cond ((numberp e) (- e))
        ((and (consp e) (eq (car e) '-) (= (length e) 3)) (list '- (third e) (second e)))
        (t (list '* -1 e))))
(defun poly-deg-in (p v) (let ((d 0)) (dolist (tm p) (let ((c (assoc v (car tm)))) (setf d (max d (if c (cdr c) 0))))) d))
(defun poly-coef-of (p v k)   ; coeficiente de v^k como expresion (en las otras variables)
  (let ((res nil)) (dolist (tm p)
    (let* ((m (car tm)) (cell (assoc v m)) (kk (if cell (cdr cell) 0)))
      (when (= kk k) (setf res (p+ res (list (cons (remove v (copy-alist m) :key #'car) (cdr tm))))))))
    (poly->expr res)))
(defun neg-lead-p (e)
  (cond ((numberp e) (< e 0)) ((and (consp e) (eq (car e) '*) (eql (second e) -1)) t) (t nil)))
(defun despejar (lhs rhs var)
  "Despeja var de la ecuacion lhs = rhs. Lineal -> simbolico; cuadratica -> las 2 raices."
  (let ((p (try-poly (list '- lhs rhs))))
    (if (eq p :fail) '?
        (let ((deg (poly-deg-in p var)))
          (cond
            ((= deg 1)
             (let ((c0 (poly-coef-of p var 0)) (c1 (poly-coef-of p var 1)))
               (if (neg-lead-p c1) (clean (list '/ c0 (neg-clean c1)))
                   (clean (list '/ (neg-clean c0) c1)))))
            ((= deg 2)
             (let* ((a (poly-coef-of p var 2)) (b (poly-coef-of p var 1)) (c (poly-coef-of p var 0))
                    (disc (clean (list '- (list 'expt b 2) (list '* 4 (list '* a c))))))
               (list 'vector
                     (clean (list '/ (list '+ (neg-clean b) (list 'sqrt disc)) (list '* 2 a)))
                     (clean (list '/ (list '- (neg-clean b) (list 'sqrt disc)) (list '* 2 a))))))
            (t '?))))))

;;;; ============ operadores estilo Calcpad (REALES, de Calcpad.Core/Solver.cs) ============
;;;; $Slope{f(x) @ x = a}   = pendiente = DERIVADA de f respecto a x, evaluada en x=a
;;;; $Area{f(x) @ x = a : b} = AREA bajo la curva = INTEGRAL definida de a a b
;;;; (Calcpad lo hace NUMERICO; aqui, al ser simbolico, es EXACTO.)
(defun slope-at (f var x0)
  (simplify (eval-consts (subst-var (partial f var) var x0))))
(defun area-under (f var a b)
  (let ((p (try-poly f)))
    (if (eq p :fail) '?
        (let ((bigf (poly->expr (poly-integ p var))))
          (simplify (list '- (subst-var bigf var b) (subst-var bigf var a)))))))

;; $product{f @ i = a : b}  y  $root{f @ x}
(defun producto-op (f var a b)
  (if (and (integerp a) (integerp b))
      (let ((acc 1)) (loop for i from a to b do (setf acc (simplify (list '* acc (subst-var f var i))))) acc)
      (list 'producto-op f var a b)))   ; limites simbolicos -> NOTACION
(defun root-op (f var) (despejar f 0 var))

;;;; ---- evaluador NUMERICO del arbol (para $find/$sup/$inf/$repeat) ----
;;;; Calcpad los calcula NUMERICO (Solver.cs); replicamos su algoritmo tal cual.
(defun nval (e var x)
  "Evalua E como numero double, sustituyendo VAR por X."
  (cond
    ((numberp e) (float e 1d0))
    ((eq e var) (float x 1d0))
    ((eq e 'pi) pi)
    ((eq e 'e) (exp 1d0))
    ((symbolp e) (error "variable libre ~a" e))
    ((consp e)
     (let ((op (car e)) (as (cdr e)))
       (flet ((n (a) (nval a var x)))
         (case op
           (+ (reduce #'+ (mapcar #'n as) :initial-value 0d0))
           (* (reduce #'* (mapcar #'n as) :initial-value 1d0))
           (- (if (cdr as) (- (n (first as)) (reduce #'+ (mapcar #'n (cdr as)))) (- (n (first as)))))
           (/ (/ (n (first as)) (n (second as))))
           (expt (expt (n (first as)) (n (second as))))
           (sqrt (sqrt (n (first as)))) (sin (sin (n (first as)))) (cos (cos (n (first as))))
           (tan (tan (n (first as)))) (exp (exp (n (first as)))) (log (log (n (first as))))
           (abs (abs (n (first as))))
           (t (error "op ~a" op))))))
    (t (error "?"))))

(defun nclean (x)
  "Redondea a ~8 decimales y entera si esta cerca de un entero."
  (if (numberp x)
      (let ((r (/ (fround (* (float x 1d0) 1d8)) 1d8)))
        (if (< (abs (- r (fround r))) 1d-9) (round r) r))
      x))

;; $Find{f @ x = a:b} = x en [a,b] donde f(x)=0 (biseccion; Calcpad usa ModAB)
(defun find-op (f var a b)
  (let* ((a (float a 1d0)) (b (float b 1d0))
         (fa (nval f var a)) (fb (nval f var b)))
    (if (> (* fa fb) 0d0) '?              ; sin cambio de signo en [a,b]
        (dotimes (i 200 (nclean (/ (+ a b) 2)))
          (let* ((m (/ (+ a b) 2)) (fm (nval f var m)))
            (when (< (abs fm) 1d-13) (return (nclean m)))
            (if (< (* fa fm) 0d0) (setf b m fb fm) (setf a m fa fm)))))))

;; $Sup / $Inf = extremo de f en [a,b] por seccion aurea (Solver.cs::Extremum), devuelve el VALOR
(defun extremum-op (f var left right is-min)
  (let* ((k 0.6180339887498948d0)
         (x1 (float (min left right) 1d0)) (x2 (float (max left right) 1d0))
         (left x1) (right x2)
         (d (- x2 x1)) (x3 (- x2 (* k d))) (x4 (+ x1 (* k d)))
         (y3 (nval f var x3)) (y4 (nval f var x4)))
    (loop while (> d (* 1d-11 (+ (abs x3) (abs x4) 1d-30))) do
      (if (eq is-min (< y3 y4))
          (setf x2 x4 x4 x3 y4 y3 d (- x2 x1) x3 (- x2 (* k d)) y3 (nval f var x3))
          (setf x1 x3 x3 x4 y3 y4 d (- x2 x1) x4 (+ x1 (* k d)) y4 (nval f var x4))))
    (nclean (cond ((= x1 left)  (nval f var left))    ; extremo en el borde izq
                  ((= x2 right) (nval f var right))   ; extremo en el borde der
                  (t (nval f var (/ (+ x1 x2) 2)))))))
(defun sup-op (f var a b) (extremum-op f var a b nil))
(defun inf-op (f var a b) (extremum-op f var a b t))

;; $Repeat{f @ i = a:b} = itera i=a..b, devuelve el ULTIMO f(i) (Solver.cs::Repeat)
(defun repeat-op (f var a b)
  (let ((res '?)) (loop for i from (round a) to (round b) do (setf res (nclean (nval f var i)))) res))

;;;; ---- evaluador SIMBOLICO de expresiones con tokens (Partial, Factor, …) ----
;;;; Permite mezclar operaciones con aritmética:  (Partial{v@x} - Partial{u@y})/2
;;;; evops recorre la expresión, EVALUA cada llamada de operación a su resultado
;;;; simbólico, y SIMPLIFICA la combinación (+ - * / expt).
(defparameter *op-calls*
  '(partial derive-x factor expand* integ-var integ-x area-under slope-at
    suma producto-op root-op find-op sup-op inf-op repeat-op))
(defun evops (e)
  (cond
    ((atom e) e)
    ((eq (car e) 'quote) (second e))                     ; '(...) → el dato tal cual
    ((member (car e) *op-calls*)                         ; (partial 'f 'x) → su resultado
     (apply (symbol-function (car e))
            (mapcar (lambda (a) (if (and (consp a) (eq (car a) 'quote)) (second a) (evops a)))
                    (cdr e))))
    ((member (car e) '(+ - * / expt))                    ; aritmética → simplifica lo combinado
     (simplify (cons (car e) (mapcar #'evops (cdr e)))))
    (t e)))

;;;; ================= ÁLGEBRA DE MATRICES (simbólica/numérica) =================
;;;; Forma externa (del parser): fila = #(a b c) ; matriz = #(#(..) #(..)).
;;;; Internamente: LISTA DE FILAS (cada fila, lista de entradas). Las entradas pueden
;;;; ser números o expresiones simbólicas; se compactan con `simplify`.
(defun to-rows (x)
  (cond ((not (vectorp x)) (list (list x)))                       ; escalar -> 1x1
        ((and (plusp (length x)) (vectorp (aref x 0)))            ; ya es matriz
         (map 'list (lambda (r) (coerce r 'list)) x))
        (t (list (coerce x 'list)))))                            ; fila -> 1xN
(defun from-rows (rows)
  (if (= (length rows) 1)
      (coerce (first rows) 'vector)                               ; una fila -> #(..)
      (coerce (mapcar (lambda (r) (coerce r 'vector)) rows) 'vector)))
(defun matp (x) (vectorp x))                                      ; un valor matriz/vector

(defun mtransp (x) (from-rows (apply #'mapcar #'list (to-rows x))))
;; producto punto: suma BINARIA anidada (+ (+ (+ 0 p1) p2) p3), porque `simplify` solo
;; combina '+' de dos en dos (un (+ a b c) n-ario le haría perder términos).
(defun mdot (row col)
  (simplify (reduce (lambda (acc pr) (list '+ acc (list '* (car pr) (cdr pr))))
                    (mapcar #'cons row col) :initial-value 0)))
(defun mmul (a b)
  (let ((ra (to-rows a)) (cb (apply #'mapcar #'list (to-rows b))))
    (from-rows (mapcar (lambda (row) (mapcar (lambda (col) (mdot row col)) cb)) ra))))
(defun mscale (s x)
  (from-rows (mapcar (lambda (row) (mapcar (lambda (e) (simplify (list '* s e))) row)) (to-rows x))))
(defun madd (a b)
  (from-rows (mapcar (lambda (r1 r2) (mapcar (lambda (e f) (simplify (list '+ e f))) r1 r2))
                     (to-rows a) (to-rows b))))
(defun msub (a b)
  (from-rows (mapcar (lambda (r1 r2) (mapcar (lambda (e f) (simplify (list '- e f))) r1 r2))
                     (to-rows a) (to-rows b))))
(defun mrange (a &optional s b)                                   ; (a b) o (a s b)
  (unless b (setf b s s 1))
  (coerce (loop for x from a to b by s collect x) 'vector))

;; INVERSA por Gauss-Jordan. Convierte cada entrada a número (eval-consts) y resuelve
;; con aritmética EXACTA de SBCL (racionales). Matriz singular -> se deja igual.
(defun mnum (e) (let ((v (ignore-errors (eval-consts (simplify e))))) (if (numberp v) v 0)))
(defun minv (x)
  (let* ((rows (to-rows x)) (n (length rows))
         (a (make-array (list n (* 2 n)) :initial-element 0)))
    (loop for i from 0 below n do
      (loop for j from 0 below n do (setf (aref a i j) (mnum (nth j (nth i rows)))))
      (setf (aref a i (+ n i)) 1))
    (loop for c from 0 below n do
      (when (zerop (aref a c c))
        (loop for r from (1+ c) below n do
          (unless (zerop (aref a r c))
            (loop for k from 0 below (* 2 n) do (rotatef (aref a c k) (aref a r k)))
            (return))))
      (let ((piv (aref a c c)))
        (when (zerop piv) (return-from minv x))                   ; singular
        (loop for k from 0 below (* 2 n) do (setf (aref a c k) (/ (aref a c k) piv)))
        (loop for r from 0 below n do
          (unless (= r c)
            (let ((f (aref a r c)))
              (loop for k from 0 below (* 2 n) do
                (setf (aref a r k) (- (aref a r k) (* f (aref a c k))))))))))
    (from-rows (loop for i from 0 below n collect
                     (loop for j from 0 below n collect (aref a i (+ n j)))))))

;; construye la matriz de un literal [ … ]: si los elementos ya son matrices/filas,
;; los apila por filas (vertcat); si son escalares, es una sola fila.
(defun build-mat (elems)
  (if (some #'vectorp elems)
      (from-rows (apply #'append (mapcar #'to-rows elems)))
      (coerce elems 'vector)))

;; meval: evalúa una expresión que MEZCLA matrices y escalares.
;;   (vector …) construye ; mtransp/mrange ; + - * expt(-1)=inversa ; escalar·matriz.
(defun meval (e)
  (cond
    ((atom e) e)
    ((eq (car e) 'quote) (second e))
    ((eq (car e) 'vector) (build-mat (mapcar #'meval (cdr e))))
    ((eq (car e) 'mtransp) (mtransp (meval (second e))))
    ((eq (car e) 'mrange)  (apply #'mrange (mapcar #'meval (cdr e))))
    ((eq (car e) '+) (m2 #'madd #'+ (meval (second e)) (meval (third e))))
    ((eq (car e) '-) (if (cddr e) (m2 #'msub #'- (meval (second e)) (meval (third e)))
                         (let ((v (meval (second e))))    ; menos unario: matriz -> escalar -1; escalar -> -x
                           (if (matp v) (mscale -1 v) (simplify (list '- v))))))
    ((eq (car e) '*) (mtimes (meval (second e)) (meval (third e))))
    ((eq (car e) 'expt)
     (let ((base (meval (second e))) (p (meval (third e))))
       (if (and (matp base) (eql p -1)) (minv base) (simplify (list 'expt base p)))))
    (t (simplify (cons (car e) (mapcar #'meval (cdr e)))))))
(defun m2 (mf sf a b) (if (or (matp a) (matp b)) (funcall mf a b) (simplify (list (if (eq sf #'+) '+ '-) a b))))
(defun mtimes (a b)
  (cond ((and (matp a) (matp b)) (mmul a b))
        ((matp a) (mscale b a))
        ((matp b) (mscale a b))
        (t (simplify (list '* a b)))))

;; imprime el resultado como forma (vector …) para que el parser de C# lo lea y renderice.
(defun mprint (x)
  (if (vectorp x)
      (format nil "(vector ~{~a~^ ~})" (map 'list #'mprint x))
      (format nil "~a" x)))
