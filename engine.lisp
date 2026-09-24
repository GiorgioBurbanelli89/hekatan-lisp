;;;; engine.lisp — motor simbolico de Hekatan LISP. Corre en SBCL.
;;;; deriv: deriva.  simplif: limpia.  dsimp: deriva y simplifica hasta el fondo.

;; Un literal 0.09 se lee como DOUBLE (15-16 cifras). Por defecto SBCL lo lee SINGLE (7 cifras):
;; 2500000*0.09/3 daba 75000.01 en vez de 75000.
(setf *read-default-float-format* 'double-float)

;; INTERSECTION portable: el ORDEN del resultado lo deja libre el estándar, y aquí importa
;; (se toma el PRIMERO como variable principal → decide el signo de la forma normal).
;; Fuera de SBCL se usa el MISMO algoritmo de SBCL 2.6.7 (src/code/list.lisp, test EQL):
;; listas cortas → recorre la MÁS CORTA (empate: la 1ª) y hace push → orden inverso;
;; si la corta tiene >20 o (≥3 y la larga ≥100) → tabla hash y recorre la LARGA.
(defun hk-intersection (l1 l2)
  #+sbcl (intersection l1 l2)
  #-sbcl
  (when (and l1 l2)
    (let* ((n1 (length l1)) (n2 (length l2))
           (short (if (<= n1 n2) l1 l2)) (long (if (<= n1 n2) l2 l1))
           (sl (min n1 n2)) (ll (max n1 n2)) (res nil))
      (if (or (> sl 20) (and (>= sl 3) (>= ll 100)))
          (let ((h (make-hash-table :test 'eql)))
            (dolist (e short) (setf (gethash e h) t))
            (dolist (e long) (when (gethash e h) (push e res))))
          (dolist (e short) (when (member e long) (push e res))))
      res)))

;; RATIONALIZE portable: SBCL da la fraccion MAS SIMPLE (0.09 -> 9/100); ECL da la EXACTA
;; del float (0.09 -> 84442493013196796875/...), y el estandar permite las dos. Fuera de SBCL
;; se usa el MISMO algoritmo de SBCL 2.6.7 (src/code/target-float.lisp, fraccion continua
;; dentro del intervalo de redondeo [2m-1, 2m+1]/2^(1-e)), copiado sin cambios de logica.
(defun hk-rationalize (x)
  #+sbcl (rationalize x)
  #-sbcl
  (if (not (floatp x))
      (rational x)
      (multiple-value-bind (frac expo sign) (integer-decode-float x)
        (let* ((shift (- (float-digits x) (integer-length frac)))
               (frac (ash frac shift))
               (expo (- expo shift)))
          (if (or (zerop frac) (>= expo 0))
              (if (minusp sign) (- (ash frac expo)) (ash frac expo))
              (let ((a (/ (- (* 2 frac) 1) (ash 1 (- 1 expo))))
                    (b (/ (+ (* 2 frac) 1) (ash 1 (- 1 expo))))
                    (p0 0) (q0 1) (p1 1) (q1 0))
                (do ((c (ceiling a) (ceiling a)))
                    ((< c b)
                     (let ((top (+ (* c p1) p0)) (bot (+ (* c q1) q0)))
                       (/ (if (minusp sign) (- top) top) bot)))
                  (let* ((k (- c 1))
                         (p2 (+ (* k p1) p0))
                         (q2 (+ (* k q1) q0)))
                    (psetf a (/ (- b k))
                           b (/ (- a k)))
                    (setf p0 p1 q0 q1 p1 p2 q1 q2)))))))))

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
    ((floatp e) (p-const (hk-rationalize e)))          ; 0.2 -> 1/5 (exacto)
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

;;;; --- FUNCIONES RACIONALES (num/den polinomios) con cancelacion: para 1/L, L/L^2, dN/dx, EA/L ---
(defun to-ratpoly (e)
  "Expresion -> (num-poly . den-poly). Lanza 'notrat si no es racional (sin, sqrt, ...)."
  (cond
    ((numberp e) (cons (p-const e) (p-const 1)))
    ((symbolp e) (cons (p-var e) (p-const 1)))
    ((consp e)
     (let ((op (car e)))
       (cond
         ((eq op '+) (let ((a (to-ratpoly (second e))) (b (to-ratpoly (third e))))
                       (cons (p+ (p* (car a) (cdr b)) (p* (car b) (cdr a))) (p* (cdr a) (cdr b)))))
         ((eq op '-) (if (cddr e)
                         (let ((a (to-ratpoly (second e))) (b (to-ratpoly (third e))))
                           (cons (p+ (p* (car a) (cdr b)) (p-scale (p* (car b) (cdr a)) -1)) (p* (cdr a) (cdr b))))
                         (let ((a (to-ratpoly (second e)))) (cons (p-scale (car a) -1) (cdr a)))))
         ((eq op '*) (let ((a (to-ratpoly (second e))) (b (to-ratpoly (third e))))
                       (cons (p* (car a) (car b)) (p* (cdr a) (cdr b)))))
         ((eq op '/) (let ((a (to-ratpoly (second e))) (b (to-ratpoly (third e))))
                       (cons (p* (car a) (cdr b)) (p* (cdr a) (car b)))))
         ((eq op 'expt) (let ((n (third e)))
                          (if (and (integerp n) (>= n 0))
                              (let ((a (to-ratpoly (second e))) (rn (cons (p-const 1) (p-const 1))))
                                (dotimes (i n) (setf rn (cons (p* (car rn) (car a)) (p* (cdr rn) (cdr a))))) rn)
                              (throw 'notrat :fail))))
         (t (throw 'notrat :fail)))))
    (t (throw 'notrat :fail))))
(defun try-ratpoly (e) (catch 'notrat (to-ratpoly e)))

(defun gcd-rat (a b)
  "MCD de dos racionales: gcd(numeradores)/lcm(denominadores)."
  (if (or (zerop a) (zerop b)) (+ (abs a) (abs b))
      (/ (gcd (numerator a) (numerator b)) (lcm (denominator a) (denominator b)))))

(defun ratcontent (p)
  "Contenido racional de un polinomio: gcd(|numeradores|)/lcm(denominadores) de sus coefs."
  (if (null p) 1
      (let ((gn 0) (ld 1))
        (dolist (tm p) (setf gn (gcd gn (abs (numerator (cdr tm)))) ld (lcm ld (denominator (cdr tm)))))
        (if (zerop gn) 1 (/ gn ld)))))

(defun mono-min (terms)
  "Monomio con la potencia MINIMA de cada variable entre TODOS los terminos (factor comun)."
  (if (null terms) nil
      (let ((m (copy-alist (caar terms))))
        (dolist (tm (cdr terms))
          (let ((tmm (car tm)) (new nil))
            (dolist (pr m)
              (let ((cell (assoc (car pr) tmm)))
                (when cell (push (cons (car pr) (min (cdr pr) (cdr cell))) new))))
            (setf m new)))
        (remove-if (lambda (pr) (zerop (cdr pr))) m))))

(defun poly-div-mono (p m)
  "Divide cada termino de p por el monomio m (que divide a todos)."
  (if (null m) p
      (mapcar (lambda (tm)
                (let ((res (copy-alist (car tm))))
                  (dolist (pr m)
                    (let ((cell (assoc (car pr) res)))
                      (when cell (decf (cdr cell) (cdr pr)))))
                  (cons (remove-if (lambda (x) (zerop (cdr x))) res) (cdr tm))))
              p)))

;;;; ---- MCD de POLINOMIOS multivariables: para cancelar la fraccion de verdad ----
;;;; `cancel-ratpoly` solo quitaba el monomio y el factor NUMERICO comunes. Por eso la
;;;; inversa por LU, la pseudo-inversa o la QR salian con el determinante elevado al
;;;; cuadrado arriba y abajo: correcto, pero ilegible. Con el MCD (Euclides con
;;;; pseudo-division sobre la variable principal) la fraccion queda en minima expresion.
;;;; Se cancela SOLO si el MCD divide EXACTO a los dos, asi que nunca puede falsear.

;; PRESUPUESTO. El MCD es exacto pero puede dispararse (los coeficientes de la
;; pseudo-division crecen solos). Un motor que NO cancela es feo; uno que se CUELGA
;; es inservible. Asi que cada intento lleva un presupuesto de pasos: si se agota,
;; se abandona y la fraccion se queda como estaba. Nunca puede colgar.
(defvar *gcd-saldo* 0)
(defun gcd-gasta (&optional (n 1))
  "Saldo 0 = nadie abrio presupuesto (llamada suelta): no se frena nada."
  (when (> *gcd-saldo* 0)
    (decf *gcd-saldo* n)
    (when (<= *gcd-saldo* 0) (throw 'gcd-caro :caro))))

(defun poly-zerop (p) (null p))

(defun poly-vars (p)
  (let ((vs nil))
    (dolist (tm p) (dolist (pr (car tm)) (pushnew (car pr) vs)))
    vs))

(defun poly-deg (p v)
  (let ((d 0))
    (dolist (tm p) (let ((c (assoc v (car tm)))) (when c (setf d (max d (cdr c))))))
    d))

(defun poly-coef-v (p v k)
  "Coeficiente de v^k: un polinomio en las DEMAS variables."
  (let ((res nil))
    (dolist (tm p)
      (when (= (or (cdr (assoc v (car tm))) 0) k)
        (setf res (p+ res (list (cons (remove v (copy-alist (car tm)) :key #'car)
                                      (cdr tm)))))))
    res))

(defun poly-mul-v^k (p v k) (p* p (list (cons (if (zerop k) nil (list (cons v k))) 1))))

(defun mono-div (m1 m2)
  "m1/m2 si m2 divide a m1; :no si no lo divide."
  (let ((res (copy-alist m1)))
    (dolist (pr m2)
      (let ((cell (assoc (car pr) res)))
        (if (and cell (>= (cdr cell) (cdr pr)))
            (decf (cdr cell) (cdr pr))
            (return-from mono-div :no))))
    (remove-if (lambda (pr) (zerop (cdr pr))) res)))

(defun mono-mayor-p (m1 m2)
  "Orden GRLEX: primero el grado total y, a igual grado, lexicografico sobre las
   variables por nombre. Tiene que ser un orden MULTIPLICATIVO —comparar el TEXTO del
   monomio no lo es— o el lider del divisor no divide al del dividendo y una division
   que SI es exacta se declara imposible: eso dejaba las fracciones sin cancelar."
  (let ((d1 (mono-degree m1)) (d2 (mono-degree m2)))
    (cond ((> d1 d2) t) ((< d1 d2) nil)
          (t (let ((vs (sort (remove-duplicates (append (mapcar #'car m1) (mapcar #'car m2)))
                             #'string< :key #'string)))
               (dolist (v vs nil)
                 (let ((e1 (or (cdr (assoc v m1)) 0))
                       (e2 (or (cdr (assoc v m2)) 0)))
                   (cond ((> e1 e2) (return t))
                         ((< e1 e2) (return nil))))))))))

(defun poly-lead (p)
  (let ((mejor (car p)))
    (dolist (tm (cdr p)) (when (mono-mayor-p (car tm) (car mejor)) (setf mejor tm)))
    mejor))

(defun poly-exact-div (p q)
  "p/q cuando la division es EXACTA; NIL si sobra resto (o si q es cero)."
  (if (or (poly-zerop p) (poly-zerop q)) nil
      (let ((r p) (out nil) (lq (poly-lead q)) (n 0))
        (loop while (and r (< n 300)) do
          (incf n) (gcd-gasta)
          (let* ((lr (poly-lead r))
                 (md (mono-div (car lr) (car lq))))
            (when (eq md :no) (return-from poly-exact-div nil))
            (let ((tq (list (cons md (/ (cdr lr) (cdr lq))))))
              (setf out (p+ out tq))
              (setf r (p+ r (p-scale (p* tq q) -1))))))
        (if (poly-zerop r) out nil))))

(defun poly-primitiva (p)
  "Quita el factor NUMERICO comun de los coeficientes."
  (if (poly-zerop p) p
      (let ((c (ratcontent p)))
        (if (or (zerop c) (= c 1)) p (p-scale p (/ 1 c))))))

(defun poly-prem (a b v)
  "Pseudo-resto de a entre b respecto a v (Euclides sin fracciones)."
  (let* ((db (poly-deg b v)) (lb (poly-coef-v b v db)) (r a))
    (loop for guarda from 0 below 200
          while (and (not (poly-zerop r)) (>= (poly-deg r v) db)) do
      (gcd-gasta (max 1 (floor (length r) 4)))
      (when (and (> *gcd-saldo* 0) (> (length r) 200)) (throw 'gcd-caro :caro))
      (let* ((dr (poly-deg r v)) (lr (poly-coef-v r v dr)))
        (setf r (poly-primitiva
                 (p+ (p* lb r)
                     (p-scale (p* (poly-mul-v^k lr v (- dr db)) b) -1))))))
    r))

;; El MCD tiene que ser PRIMITIVO: si no se quita el contenido (el factor comun de
;; los coeficientes vistos en v) el algoritmo devuelve el MCD multiplicado por basura
;; —salia q^2·(p^2-q^2) en vez de (p^2-q^2)— y entonces ya no divide exacto y no se
;; cancela nada. El contenido se calcula con el mismo MCD, pero con UNA VARIABLE MENOS,
;; asi que la recursion siempre termina.
(defun poly-content-v (p v)
  "MCD de los coeficientes de p visto como polinomio en v."
  (if (> (length p) 60) (p-const 1)
      (let ((g nil))
        (loop for k from 0 to (poly-deg p v) do
          (let ((c (poly-coef-v p v k)))
            (unless (poly-zerop c) (setf g (if g (poly-gcd g c) c)))))
        (or g (p-const 1)))))

(defun poly-pp-v (p v)
  "Parte primitiva de p respecto a v: p dividido por su contenido."
  (if (poly-zerop p) p
      (let ((c (poly-content-v p v)))
        (if (numberp (p-constant c))
            (poly-primitiva p)
            (poly-primitiva (or (poly-exact-div p c) p))))))

(defun poly-gcd (a b)
  "MCD de dos polinomios, salvo constante (Euclides con pseudo-division, PRS primitivo)."
  (gcd-gasta)
  (cond ((poly-zerop a) (poly-primitiva b))
        ((poly-zerop b) (poly-primitiva a))
        ((poly-exact-div b a) (poly-primitiva a))
        ((poly-exact-div a b) (poly-primitiva b))
        (t (let ((v (car (hk-intersection (poly-vars a) (poly-vars b)))))
             (if (null v) (p-const 1)
                 (let* ((ca (poly-content-v a v))
                        (cb (poly-content-v b v))
                        (cg (if (or (numberp (p-constant ca)) (numberp (p-constant cb)))
                                (p-const 1) (poly-gcd ca cb)))
                        (x (poly-pp-v a v))
                        (y (poly-pp-v b v)))
                   (when (< (poly-deg x v) (poly-deg y v)) (rotatef x y))
                   (loop for guarda from 0 below 40
                         while (not (poly-zerop y)) do
                           (let ((r (poly-prem x y v)))
                             (setf x y y (poly-pp-v r v))))
                   (p* cg x)))))))

(defun cancel-gcd (num den)
  "Divide numerador y denominador por su MCD, comprobando que sale EXACTO."
  (if (or (poly-zerop num) (poly-zerop den)
          (numberp (p-constant den))                 ; denominador constante: nada que hacer
          (> (length num) 80) (> (length den) 80))   ; demasiado grande: no merece la pena
      (cons num den)
      (let* ((*gcd-saldo* 6000)
             (g (catch 'gcd-caro (ignore-errors (poly-gcd num den)))))
        (if (or (null g) (eq g :caro) (poly-zerop g) (numberp (p-constant g)))
            (cons num den)
            (let* ((r (catch 'gcd-caro
                        (let ((n2 (poly-exact-div num g)) (d2 (poly-exact-div den g)))
                          (if (and n2 d2) (cons n2 d2) :caro)))))
              (if (eq r :caro) (cons num den) r))))))

(defun cancel-ratpoly (r)
  "Cancela el monomio y el factor numerico comunes entre numerador y denominador.
   Ademas, si num y den son el MISMO polinomio -> 1 (la diagonal de A*inv(A)=I);
   si son opuestos -> -1. (p+ deja el polinomio VACIO cuando todo se cancela.)"
  (let ((num (car r)) (den (cdr r)))
    (cond
      ((null num) (cons nil (p-const 1)))
      ((null (p+ num (p-scale den -1))) (cons (p-const 1) (p-const 1)))   ; num = den  -> 1
      ((null (p+ num den))              (cons (p-const -1) (p-const 1)))  ; num = -den -> -1
      (t
       (let ((mm (mono-min (append num den))))
         (when mm (setf num (poly-div-mono num mm) den (poly-div-mono den mm)))
         (let ((g (gcd-rat (ratcontent num) (ratcontent den))))
           (when (and (/= g 0) (/= g 1)) (setf num (p-scale num (/ 1 g)) den (p-scale den (/ 1 g)))))
         ;; y el factor POLINOMICO comun (el determinante que salia al cuadrado)
         (let ((g (cancel-gcd num den)))
           (setf num (car g) den (cdr g)))
         ;; si el denominador es una constante negativa, pasa el signo al numerador
         (let ((dc (p-constant den)))
           (when (and (numberp dc) (minusp dc)) (setf num (p-scale num -1) den (p-scale den -1))))
         (cons num den))))))

(defun ratpoly->expr (r)
  "(num . den) -> expresion legible; si el den es constante lo reparte, si no deja num/den."
  (let* ((num (car r)) (den (cdr r)) (dc (p-constant den)))
    (cond ((and (numberp dc) (= dc 1)) (poly->expr num))
          ((numberp dc) (poly->expr (p-scale num (/ 1 dc))))
          (t (list '/ (poly->expr num) (poly->expr den))))))

;;;; ===== ATOMOS OPACOS: sin, cos, sqrt… DENTRO del motor de polinomios =====
;;;; El motor de polinomios solo entiende + - * / y potencia entera. Cualquier otra
;;;; llamada (sin, cos, sqrt, log) le hacia tirar la toalla, y `simplify` devolvia la
;;;; expresion casi cruda: cos(t)*sin(t) - sin(t)*cos(t) se quedaba escrito tal cual, y
;;;; sqrt(p)*sqrt(p) no era p. Eso bloqueaba TRES formas de invertir una matriz
;;;; —ortogonal (A^-1 = A^T), Cholesky y QR—, que viven todas de raices y senos.
;;;; Aqui esas llamadas se sustituyen por una LETRA nueva, el polinomio las combina
;;;; como a cualquier otra, y al final dos reglas las devuelven a su significado:
;;;;   · (sqrt a)^k          -> a^(k/2) · (sqrt a)^(k mod 2)     [sqrt(p)*sqrt(p) = p]
;;;;   · sin(u)^2*M + cos(u)^2*M -> M                            [Pitagoras]

(defvar *opq* nil "alist (letra-nueva . forma original) del simplify opaco en curso.")

(defun opq-arith-p (op) (member op '(+ - * / expt)))

(defun opq-sub (e)
  "Sustituye cada llamada NO aritmetica por una letra nueva; recuerda la equivalencia."
  (cond ((atom e) e)
        ((opq-arith-p (car e)) (cons (car e) (mapcar #'opq-sub (cdr e))))
        (t (let ((hit (rassoc e *opq* :test #'equal)))
             (if hit (car hit)
                 (let ((g (make-symbol (format nil "OPQ~3,'0d" (length *opq*)))))
                   (push (cons g e) *opq*)
                   g))))))

(defun opq-back (e)
  "Devuelve cada letra opaca a su forma original."
  (cond ((symbolp e) (let ((hit (assoc e *opq*))) (if hit (cdr hit) e)))
        ((consp e) (cons (car e) (mapcar #'opq-back (cdr e))))
        (t e)))

(defun opq-form (v) (and (symbolp v) (cdr (assoc v *opq*))))
(defun opq-letra-de (forma) (car (rassoc forma *opq* :test #'equal)))
;; el radicando puede ser una FRACCION (Cholesky: sqrt(p - q^2/p)), asi que el
;; plegado trabaja con racionales (num . den), no con polinomios sueltos.
(defun opq-ratpoly (e) (try-ratpoly (opq-sub e)))
(defun rp* (a b) (cons (p* (car a) (car b)) (p* (cdr a) (cdr b))))
(defun rp+ (a b) (cons (p+ (p* (car a) (cdr b)) (p* (car b) (cdr a))) (p* (cdr a) (cdr b))))

(defun mono-sort (m)
  (sort (remove-if (lambda (pr) (zerop (cdr pr))) (copy-alist m))
        #'string< :key (lambda (pr) (string (car pr)))))

(defun poly-sqrt-fold (p)
  "(sqrt a)^k dentro de un monomio -> a^(k/2) multiplicando fuera, (sqrt a)^(k mod 2)
   dentro. Devuelve un RACIONAL (num . den) porque el radicando puede ser fraccion."
  (let ((out (cons nil (p-const 1))))
    (dolist (tm p)
      (let ((m nil) (extra (cons (p-const 1) (p-const 1))))
        (dolist (pr (car tm))
          (let ((f (opq-form (car pr))))
            (if (and (consp f) (eq (car f) 'sqrt) (>= (cdr pr) 2))
                (let* ((k (cdr pr)) (mitad (floor k 2)) (resto (mod k 2))
                       (ar (opq-ratpoly (second f))))
                  (if (eq ar :fail)
                      (push pr m)                    ; radicando raro: se deja como esta
                      (progn
                        (when (> resto 0) (push (cons (car pr) resto) m))
                        (dotimes (i mitad) (setf extra (rp* extra ar))))))
                (push pr m))))
        (setf out (rp+ out (rp* (cons (list (cons (mono-sort m) (cdr tm))) (p-const 1))
                                extra)))))
    out))

(defun mono-baja (m v k)
  "El monomio m con la potencia de v rebajada en k."
  (mono-sort (mapcar (lambda (pr) (if (eq (car pr) v) (cons v (- (cdr pr) k)) pr)) m)))

(defun poly-pyth (p)
  "sin(u)^2*M + cos(u)^2*M -> M (mismo coeficiente). Repite hasta que no cambie nada."
  (let ((sigue t))
    (loop while sigue do
      (setf sigue nil)
      (block barrido
        (dolist (tm p)
          (let ((m (car tm)) (c (cdr tm)))
            (dolist (pr m)
              (let ((f (opq-form (car pr))))
                (when (and (consp f) (member (car f) '(sin cos)) (>= (cdr pr) 2))
                  (let ((otro (opq-letra-de (list (if (eq (car f) 'sin) 'cos 'sin) (second f)))))
                    (when otro
                      (let* ((resto (mono-baja m (car pr) 2))
                             (m2 (mono-mul resto (list (cons otro 2))))
                             (par (assoc m2 p :test #'equal)))
                        (when (and par (= (cdr par) c))
                          (setf p (p+ p (list (cons m (- c)) (cons m2 (- c)) (cons resto c))))
                          (setf sigue t)
                          (return-from barrido))))))))))))
    p))

(defun opq-reglas (r)
  "Las dos reglas sobre un racional: (n1/n2)/(d1/d2) = (n1*d2)/(n2*d1)."
  (let ((n (poly-sqrt-fold (car r)))
        (d (poly-sqrt-fold (cdr r))))
    (cons (poly-pyth (p* (car n) (cdr d)))
          (poly-pyth (p* (cdr n) (car d))))))

(defun simplify-opaco (e)
  "Ultimo intento: trata sin/cos/sqrt como letras, simplifica, y aplica sus dos reglas."
  (let ((*opq* nil))
    (let* ((es (opq-sub e))
           (p (try-poly es)))
      (if (not (eq p :fail))
          (opq-back (ratpoly->expr (cancel-ratpoly (opq-reglas (cons p (p-const 1))))))
          (let ((r (try-ratpoly es)))
            (if (eq r :fail)
                (collect-in (simp* e))
                (opq-back (ratpoly->expr (cancel-ratpoly (opq-reglas r))))))))))

(defun simplify (e)
  "Simplifica EXACTO: polinomio; si no, funcion RACIONAL (num/den con cancelacion);
   si no, el mismo motor tratando sin/cos/sqrt como letras; si no, motor viejo."
  (let ((p (try-poly e)))
    (if (not (eq p :fail)) (poly->expr p)
        (let ((r (try-ratpoly e)))
          (if (eq r :fail) (simplify-opaco e) (ratpoly->expr (cancel-ratpoly r)))))))

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

(defun derive-x (e &optional v)
  "Derivada ORDINARIA d/dx. Si se da v, deriva respecto a v; si no, autodetecta la variable.
   Resuelve ops anidadas primero (Diff{Diff{}} = 2a derivada, que el quote dejaba sin evaluar)."
  (let* ((e (eval-ops-tree e)) (var (or v (let ((vs (vars-of e))) (if vs (car vs) 'x)))) (p (try-poly e)))
    (if (eq p :fail) (simplify (deriv e var)) (poly->expr (poly-deriv p var)))))

(defun partial (e v)
  "Derivada PARCIAL respecto a la variable v (elegida). Para 2D: dN/ds, dN/dt.
   A diferencia de derive-x (que AUTODETECTA una variable), aquí TÚ das la variable."
  (let* ((e (eval-ops-tree e)) (p (try-poly e)))
    (if (eq p :fail) (simplify (deriv e v)) (poly->expr (poly-deriv p v)))))

;;;; --- derivada que MUESTRA SU TRABAJO: la regla de la potencia con su aritmetica ---
(defun mono-drop (m v) "El monomio m sin la variable v." (remove v m :key #'car))

(defun drule-term (m c v)
  "Un termino c*(monomio m) derivado por la REGLA DE LA POTENCIA, SIN reducir:
   c*v^n  ->  (c*n) * resto * v^(n-1).  Muestra el producto c*n y el exponente n-1.
   Si v no aparece (n=0), la derivada del termino es 0."
  (let ((n (or (cdr (assoc v m)) 0)))
    (if (= n 0) 0
        (let* ((rest (mono-drop m v))
               (restx (if rest (mono->expr rest) nil))
               (powx  (if (> (- n 1) 0) (list 'expt v (- n 1)) nil))
               (coef  (list '* (coeff->expr c) n))          ; deja  c*n  a la vista
               (tail  (cond ((and restx powx) (list '* restx powx))
                            (restx restx) (powx powx) (t nil))))
          (if tail (list '* coef tail) coef)))))

(defun deriv-steps (e v)
  "Derivada MOSTRANDO EL TRABAJO. Devuelve (steps s0 s1 s2 s3), una cadena de igualdades:
   s0 = d/dv[e] (la derivada a resolver), s1 = regla de la suma (d/dv de cada termino),
   s2 = regla de la potencia con su aritmetica (c*n*v^(n-1)), s3 = resultado reducido.
   Solo polinomios; si no lo es, cae al resultado normal."
  (let ((p (try-poly e)))
    (if (eq p :fail)
        (list 'steps (list 'derive-x e v) (simplify (deriv e v)))
        (let* ((bydeg (sort (copy-alist p) #'> :key (lambda (tm) (mono-degree (car tm)))))
               (s0 (list 'derive-x e v))
               (term-forms (mapcar (lambda (tm)
                              (let ((te (if (minusp (cdr tm))
                                            (neg-expr (term->expr (car tm) (- (cdr tm))))
                                            (term->expr (car tm) (cdr tm)))))
                                (list 'derive-x te v)))
                            bydeg))
               (s1 (if term-forms (reduce (lambda (a b) (list '+ a b)) term-forms) 0))
               (rule-terms (mapcar (lambda (tm) (drule-term (car tm) (cdr tm) v)) bydeg))
               (s2 (if rule-terms (reduce (lambda (a b) (list '+ a b)) rule-terms) 0))
               (s3 (poly->expr (poly-deriv p v))))
          (list 'steps s0 s1 s2 s3)))))

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
          ((and (eq (car e) '/) (numberp (second e)) (eq (third e) v))              ; ∫c/v = c·ln v
           (simplify (list '* (second e) (list 'log v))))
          ;; regla de la potencia con exponente cualquiera (n ≠ -1): ∫v^n dv = v^(n+1)/(n+1)
          ((and (eq (car e) 'expt) (eq (second e) v) (numberp (third e)) (/= (third e) -1))
           (let ((m (+ (third e) 1))) (simplify (list '/ (list 'expt v m) m))))
          ;; c/v^n = c·v^(-n):  ∫ = c·v^(1-n)/(1-n)   (n ≠ 1; n = 1 es el logaritmo de arriba)
          ((and (eq (car e) '/) (numberp (second e)) (consp (third e)) (eq (car (third e)) 'expt)
                (eq (second (third e)) v) (numberp (third (third e))) (/= (third (third e)) 1))
           (let ((m (- 1 (third (third e)))))
             (if (< m 0)    ; exponente negativo: se escribe como fracción, −c/(|m|·v^|m|)
                 (let ((k (- m)))
                   (simplify (list '/ (- (second e)) (if (= k 1) v (list '* k (list 'expt v k))))))
                 (simplify (list '/ (list '* (second e) (list 'expt v m)) m)))))
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
;; ---- DECIMALES ----
;; El motor guarda TODO exacto (fracciones) para no perder cifras. Pero un
;; resultado de ingenieria se lee en decimal: 304.26, no 118967/391.
;;
;; No sirve guardar un racional con denominador 10^n: Common Lisp REDUCE los
;; racionales solo (30426/100 -> 15213/50), asi que la potencia de 10 se pierde.
;; Por eso `dec` devuelve un nodo (decv "304.26") con el texto ya formateado,
;; que `infix` escribe tal cual.
(defun fmt-dec-str (x n)
  "Valor exacto -> texto decimal con n cifras, redondeando."
  (let* ((m (expt 10 n)) (k (round (* (rational x) m)))
         (neg (< k 0)) (a (abs k)) (ent (floor a m)) (fr (- a (* ent m))))
    (if (= n 0)
        (format nil "~:[~;-~]~a" neg ent)
        (format nil "~:[~;-~]~a.~v,'0d" neg ent n fr))))

(defun poda-ceros (s)
  "\"0.3300\" -> \"0.33\" ; \"5.0000\" -> \"5\". Solo cuando el usuario no fijo las cifras."
  (if (find #\. s)
      (let ((r (string-right-trim "0" s)))
        (if (char= (char r (1- (length r))) #\.) (subseq r 0 (1- (length r))) r))
      s))

(defun to-dec (v n podar)
  "dec(x) y dec(x, n). Funciona tambien sobre MATRICES, termino a termino."
  (cond
    ((matp v) (from-rows (mapcar (lambda (f) (mapcar (lambda (c) (to-dec c n podar)) f))
                                 (to-rows v))))
    (t (let ((x (cond ((numberp v) v)
                      (t (let ((w (ignore-errors (eval-consts (simplify v)))))
                           ;; hk-num: ultimo intento con π, √ y decimales ya formateados por otro dec
                           (if (numberp w) w (or (ignore-errors (num-eval (or w v))) (hk-num v))))))))
         (if (null x) v
             (let ((txt (fmt-dec-str x n)))
               ;; simbolo con el texto por nombre: asi funciona igual dentro de una
               ;; MATRIZ (que se imprime elemento a elemento) que suelto.
               (intern (if podar (poda-ceros txt) txt))))))))

(defun infix (e)
  "Convierte una expresion LISP a texto matematico infijo (estilo MATLAB)."
  (cond
    ((integerp e) (format nil "~a" e))
    ;; (decv "0.33") = un decimal ya formateado por `dec`; se escribe tal cual.
    ((and (consp e) (eq (car e) 'decv)) (second e))
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
;; FORMULAS CERRADAS de Faulhaber (sum_{i=1}^{n} i^k) para k = 0..3:
(defun faulhaber (k n)
  (case k
    (0 n)
    (1 (list '/ (list '* n (list '+ n 1)) 2))
    (2 (list '/ (list '* (list '* n (list '+ n 1)) (list '+ (list '* 2 n) 1)) 6))
    (3 (list 'expt (list '/ (list '* n (list '+ n 1)) 2) 2))
    (t nil)))
(defun suma-poly-1n (e var n)
  "Sum_{var=1}^{n} e, con e POLINOMIO en var (grado<=3): Faulhaber + linealidad. nil si no aplica."
  (let ((p (try-poly (expand* e))))
    (if (eq p :fail) nil
        (let ((d (poly-deg-in p var)))
          (if (or (null d) (> d 3)) nil
              (let ((acc 0))
                (dotimes (k (1+ d))
                  (let ((ck (poly-coef-of p var k)) (fk (faulhaber k n)))
                    (unless (or (equal ck 0) (null fk))
                      (setf acc (list '+ acc (list '* ck fk))))))
                (simplify (expand* acc))))))))
(defun suma (e var a b)
  "Sumatoria de e con var de a a b. Limites ENTEROS: suma termino a termino. Limite
   inferior 1 y superior SIMBOLICO con sumando polinomial: FORMULA CERRADA (Faulhaber).
   Resto de limites simbolicos: NOTACION (dibuja la Σ, no fabrica un resultado falso)."
  (cond
    ((and (integerp a) (integerp b))
     (let ((acc 0)) (loop for i from a to b do (setf acc (simplify (list '+ acc (subst-var e var i))))) acc))
    ((and (eql a 1) (not (integerp b)))
     (or (suma-poly-1n e var b) (list 'suma e var a b)))
    (t (list 'suma e var a b))))

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

;; Taylor{ f @ x = 0 : n } de la hoja: mismo orden que los demas operadores (f v a b).
;; Solo alrededor de 0 (a = 0); con otro a devuelve la notacion, no un resultado falso.
(defun taylor-op (e var a n)
  (if (and (numberp a) (zerop a) (integerp n)) (taylor e n var) (list 'taylor-op e var a n)))

;; LIMITE:  sustitucion directa; 0/0 -> L'Hopital; var->infinito -> comparar grados.
(defun infinityp (a) (and (symbolp a) (member a '(inf infinity infty +inf oo))))
(defun deg-in (e var)
  "Grado de e como polinomio en var, o nil si no es polinomio en var."
  (let ((p (try-poly (expand* e))))
    (if (eq p :fail) nil (poly-deg-in p var))))
(defun lead-coef-in (e var)
  "Coeficiente lider de e (polinomio) en var, o 1 si no aplica."
  (let ((p (try-poly (expand* e))) (d (deg-in e var)))
    (if (or (eq p :fail) (null d)) 1 (poly-coef-of p var d))))
(defun limite-inf (e var)
  "Limite cuando var->infinito. Racional P/Q: por grados; polinomio: inf; constante: ella."
  (if (and (consp e) (eq (car e) '/))
      (let ((dn (deg-in (second e) var)) (dd (deg-in (third e) var)))
        (if (and dn dd)
            (cond ((< dn dd) 0)                                    ; abajo domina -> 0
                  ((> dn dd) 'inf)                                 ; arriba domina -> inf
                  (t (simplify (list '/ (lead-coef-in (second e) var)   ; grados iguales -> razon de lideres
                                       (lead-coef-in (third e) var)))))
            (list 'limite e var 'inf)))
      (let ((d (deg-in e var)))
        (cond ((null d) (list 'limite e var 'inf))
              ((zerop d) (simplify (eval-consts e)))
              (t 'inf)))))
(defun limite (e var a)
  "Limite de e cuando var->a. Sustituye; si 0/0 aplica L'Hopital; var->inf por grados."
  (cond
    ((infinityp a) (limite-inf e var))
    ((and (consp e) (eq (car e) '/))
     (let ((nu (simplify (eval-consts (subst-var (second e) var a))))
           (de (simplify (eval-consts (subst-var (third e) var a)))))
       (if (and (eql nu 0) (eql de 0))
           (limite (list '/ (partial (second e) var) (partial (third e) var)) var a)
           (simplify (eval-consts (subst-var e var a))))))
    (t (simplify (eval-consts (subst-var e var a))))))

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
  "Factoriza un polinomio de UNA variable (raices racionales). Si no es polinomio, cae a
   simplify (que maneja funciones racionales: 1/L, dN/dx, EA/L). Si no, lo reduce.
   Primero resuelve operaciones anidadas (Diff{} dentro de Simplify{})."
  (let* ((e (eval-ops-tree e)) (p (try-poly e)))
    (if (eq p :fail) (simplify e)
        (let ((vs (vars-of e)))
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
  "Despeja var de la ecuacion lhs = rhs. Lineal -> simbolico; cuadratica -> las 2 raices.
   Resuelve primero ops de MATRIZ en los lados (det, …) para que
   Despejar{det(K-lam*M)=0 @ lam} de los autovalores (det -> polinomio caracteristico)."
  (let* ((lhs (meval lhs)) (rhs (meval rhs))
         (p (try-poly (list '- lhs rhs))))
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
  ;; resuelve operaciones anidadas (Diff{} dentro de Area{}) que el quote dejo sin evaluar
  (let ((f (eval-ops-tree f)))
  (cond
    ;; f NO depende de var (constante respecto a la integración, aunque tenga OTRAS
    ;; letras: 1/L², E·A…) → ∫ₐᵇ f dvar = f·(b−a). Así el FEM con geometría/material
    ;; simbólico integra (∫₋₁¹ (1/L²) dξ = 2/L²), donde try-poly fallaba por tratar L
    ;; como variable del polinomio.
    ((not (member var (vars-of f)))
     (simplify (list '* f (- b a))))
    (t (let ((p (try-poly f)))
         (if (not (eq p :fail))
             (let ((bigf (poly->expr (poly-integ p var))))
               (simplify (list '- (subst-var bigf var b) (subst-var bigf var a))))
             ;; NO es polinomio: prueba funcion RACIONAL num/den con den SIN la variable de integracion
             ;; (∫ (poly en x)/L^n dx = (1/L^n) ∫ poly dx). Es lo que aparece en la rigidez de viga.
             (let ((r (try-ratpoly f)))
               (if (and (not (eq r :fail))
                        (not (member var (vars-of (poly->expr (cdr r))))))
                   (let* ((bigf (poly->expr (poly-integ (car r) var)))
                          (defint (simplify (list '- (subst-var bigf var b) (subst-var bigf var a)))))
                     (simplify (list '/ defint (poly->expr (cdr r)))))
                   '?))))))))

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
  '(partial derive-x deriv-steps factor expand* integ-var integ-x area-under slope-at
    suma producto-op root-op find-op sup-op inf-op repeat-op limite taylor-op despejar dec
    qshow qval))

;; dec como FUNCION, para que `evops` la aplique en el camino ESCALAR (el de
;; matrices entra por `meval`). Sin n: 6 cifras y se podan los ceros de cola.
(defun dec (x &optional n) (to-dec x (or n 6) (null n)))

;;;; ---- ceil / floor / round / max / min NUMERICOS (hojas de diseño: n = ⌈As/Ab⌉) ----
;;;; Antes quedaban sin evaluar (ceil(24.3/2.01) se dibujaba tal cual). Evaluan si el
;;;; argumento REDUCE a numero (aunque lleve π o √); si queda una letra libre, la forma
;;;; se devuelve igual (simbolica). Sobre VECTORES trabajan termino a termino, y max/min
;;;; de varios vectores (o vector y escalar) dan el maximo/minimo elemento a elemento.
;;;; round = redondeo "de escuela" (0.5 sube), no el de banquero de Common Lisp.
(defparameter *num-fns* '(ceil floor round max min))
(defun ceil (x) (values (ceiling x)))                  ; camino "auto" (eval directo)
(defun hk-numsym (e)
  "Simbolos con nombre de numero (los que deja `dec`: |24.34|) -> racional exacto."
  (cond ((and (symbolp e) e (not (eq e t))
              ;; solo nombres que EMPIEZAN como numero (24.34, -0.15): rapido en matrices grandes
              (let ((nm (symbol-name e)))
                (and (> (length nm) 0)
                     (or (digit-char-p (char nm 0))
                         (and (> (length nm) 1) (member (char nm 0) '(#\- #\.)) (digit-char-p (char nm 1)))))))
         (let ((v (ignore-errors (let ((*read-default-float-format* 'double-float))
                                   (read-from-string (symbol-name e))))))
           (if (numberp v) (rational v) e)))
        ((consp e) (cons (car e) (mapcar #'hk-numsym (cdr e))))
        (t e)))
(defun hk-num (x)
  "Valor numerico (racional si se puede) de X, o NIL si tiene letras libres."
  (flet ((rat (v) (cond ((rationalp v) v) ((floatp v) (rational v)) (t nil))))
    (let* ((x (hk-numsym x))
           (w (ignore-errors (eval-consts (simplify x)))))
      (or (rat x) (rat w)
          (rat (ignore-errors (num-eval w))) (rat (ignore-errors (num-eval x)))
          (rat (ignore-errors (nval (or w x) '%sin-var% 0)))
          (rat (ignore-errors (nval x '%sin-var% 0)))))))
(defun hk-arg (a)
  "Argumento de ceil/floor/…: su NUMERO si reduce (resolviendo antes los ceil/floor
   anidados; decimales y π incluidos), si no el resultado simbolico de evops."
  (labels ((inner (e) (cond ((atom e) e)
                            ((member (car e) *num-fns*) (num-fn (car e) (mapcar #'hk-arg (cdr e))))
                            (t (cons (car e) (mapcar #'inner (cdr e)))))))
    (let ((e (inner a)))
      (or (and (not (matp e)) (hk-num e)) (ignore-errors (evops e)) e))))
(defun hk-dn (x)
  "Decimales ya formateados por `dec` (simbolos |2.011|) -> racional, tambien dentro de un
   vector: asi Ab = dec(π·1.6²/4, 3) se puede usar despues en n = ceil(As/Ab)."
  (cond ((matp x) (from-rows (mapcar (lambda (f) (mapcar #'hk-numsym f)) (to-rows x))))
        (t (hk-numsym x))))
(defun hk-round1 (f x)
  (let ((v (hk-num x)))
    (if (null v) (list f x)
        (ecase f
          (ceil (ceiling v))
          (floor (floor v))
          (round (floor (+ v 1/2)))))))
(defun hk-elems (v) (if (matp v) (to-rows v) nil))
(defun num-fn (f args)
  "Aplica ceil/floor/round/max/min a ARGS ya evaluados (escalares o matrices)."
  (let ((mats (remove-if-not #'matp args)))
    (cond
      ;; vector/matriz: termino a termino (los escalares se repiten en cada posicion)
      (mats
       (let ((rows (to-rows (first mats))))
         (from-rows
          (loop for i from 0 below (length rows)
                collect (loop for j from 0 below (length (nth i rows))
                              collect (num-fn f (mapcar (lambda (a)
                                                          (if (matp a) (nth j (nth i (to-rows a))) a))
                                                        args)))))))
      ((member f '(ceil floor round)) (hk-round1 f (first args)))
      ;; max/min devuelven el ARGUMENTO ganador tal cual (12.25 sigue siendo 12.25, no la
      ;; fraccion binaria exacta del double)
      (t (let ((vs (mapcar #'hk-num args)))
           (if (every #'identity vs)
               (let ((best 0))
                 (loop for k from 1 below (length vs)
                       when (if (eq f 'max) (> (nth k vs) (nth best vs)) (< (nth k vs) (nth best vs)))
                         do (setf best k))
                 (nth best args))
               (cons f args)))))))

(defun evops (e)
  (cond
    ((atom e) e)
    ((eq (car e) 'quote) (second e))                     ; '(...) → el dato tal cual
    ((member (car e) *num-fns*) (num-fn (car e) (mapcar #'hk-arg (cdr e))))
    ((member (car e) *op-calls*)                         ; (partial 'f 'x) → su resultado
     (apply (symbol-function (car e))
            (mapcar (lambda (a) (if (and (consp a) (eq (car a) 'quote)) (second a) (evops a)))
                    (cdr e))))
    ((member (car e) '(+ - * / expt))                    ; aritmética → simplifica lo combinado
     (simplify (cons (car e) (mapcar #'evops (cdr e)))))
    (t e)))

(defun eval-ops-tree (e)
  "Evalua las llamadas de operacion (derive-x, partial, factor, area-under, …) que aparezcan
   DENTRO de e, dejando el resto igual. Sirve para que Simplify{ … Diff{} … } resuelva las
   operaciones anidadas antes de simplificar (el quote impedia evaluarlas)."
  (cond ((atom e) e)
        ((eq (car e) 'quote) (eval-ops-tree (second e)))
        ((member (car e) *op-calls*) (evops e))
        (t (cons (car e) (mapcar #'eval-ops-tree (cdr e))))))

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
;; EVALUADOR NUMERICO rapido: recorre el arbol de una expresion SIMBOLICA con
;; aritmetica nativa (sin construir formas ni simplify), dadas las variables en
;; `env` (alist var->numero). Patron FEM: construir B/detJ simbolicos UNA vez y
;; luego neval en cada punto de Gauss / elemento -> velocidad de codigo compilado.
(defun neval (e env)
  (cond ((numberp e) e)
        ((symbolp e) (let ((p (assoc e env))) (if p (cdr p) (error "neval: ~a sin valor" e))))
        ((consp e)
         (let ((a (mapcar (lambda (x) (neval x env)) (cdr e))))
           (case (car e)
             (+ (apply #'+ a)) (- (apply #'- a)) (* (apply #'* a)) (/ (apply #'/ a))
             (expt (expt (first a) (second a))) (sqrt (sqrt (first a)))
             (sin (sin (first a))) (cos (cos (first a))) (tan (tan (first a)))
             (exp (exp (first a))) (log (log (first a))) (abs (abs (first a)))
             (t (error "neval: op ~a" (car e))))))
        (t (error "neval: ~a" e))))
;; nevala matriz simbolica -> matriz de numeros (array 2D double-float)
(defun nmat (m env)
  (let* ((rows (to-rows m)) (r (length rows)) (c (length (car rows)))
         (a (make-array (list r c) :element-type 'double-float)))
    (loop for i below r do (loop for j below c do
      (setf (aref a i j) (float (neval (nth j (nth i rows)) env) 1d0))))
    a))

;; COMPILAR a codigo nativo: una expresion SIMBOLICA se vuelve una funcion de
;; `vars` compilada por SBCL (una sola vez). Llamarla luego es velocidad de codigo
;; maquina — el ultimo salto sobre neval (que interpreta el arbol). Las ops del
;; arbol (+ - * / expt sqrt sin cos ...) ya son funciones de Common Lisp.
(defun ncompile (expr vars)
  (compile nil `(lambda ,vars (declare (ignorable ,@vars)) (float (progn ,expr) 1d0))))
;; compila cada entrada de una matriz -> array 2D de funciones; ncmat-eval las corre.
(defun ncmat-compile (m vars)
  (let* ((rows (to-rows m)) (r (length rows)) (c (length (car rows)))
         (a (make-array (list r c))))
    (loop for i below r do (loop for j below c do
      (setf (aref a i j) (ncompile (nth j (nth i rows)) vars))))
    a))
(defun ncmat-eval (fns args)
  (let* ((r (array-dimension fns 0)) (c (array-dimension fns 1))
         (a (make-array (list r c) :element-type 'double-float)))
    (loop for i below r do (loop for j below c do
      (setf (aref a i j) (apply (the function (aref fns i j)) args))))
    a))

;; NGAUSS: integral de GAUSS 2x2 NUMERICA de una matriz M(v1,v2) sobre [-1,1]^2.
;; Es el patron FEM: construir M simbolico UNA vez (meval) y evaluar rapido (neval)
;; en los 4 puntos de Gauss, sumando (pesos = 1). Devuelve matriz de numeros.
;;   K = NGauss{ transpose(B)*D*B*detJ @ xi , eta }
(defun ngauss (mexpr v1 v2)
  (let* ((m (if (vectorp mexpr) mexpr (meval mexpr)))
         (g 0.5773502691896258d0)
         (pts (list (list (- g) (- g)) (list g (- g)) (list g g) (list (- g) g)))
         (rows (to-rows m)) (nr (length rows)) (nc (length (car rows)))
         (acc (make-array (list nr nc) :element-type 'double-float :initial-element 0d0)))
    (dolist (p pts)
      (let ((env (list (cons v1 (first p)) (cons v2 (second p)))))
        (loop for i below nr do (loop for j below nc do
          (incf (aref acc i j) (float (neval (nth j (nth i rows)) env) 1d0))))))
    (from-rows (loop for i below nr collect (loop for j below nc collect (nclean (aref acc i j)))))))
;; FAST-PATH NUMERICO: las ops de matriz construyen formas (* a b) y llaman simplify,
;; aun con numeros. Si TODAS las entradas son numeros, se hace aritmetica nativa de
;; SBCL (sin simplify): ~1000x mas rapido en numerico, misma respuesta simbolica.
(declaim (inline nums2))
(defun nums2 (a b) (and (numberp a) (numberp b)))
;; producto punto: suma BINARIA anidada (+ (+ (+ 0 p1) p2) p3), porque `simplify` solo
;; combina '+' de dos en dos (un (+ a b c) n-ario le haría perder términos).
(defun mdot (row col)
  (if (and (every #'numberp row) (every #'numberp col))
      (let ((s 0)) (mapc (lambda (a b) (setf s (+ s (* a b)))) row col) s)   ; numerico nativo
      (simplify (reduce (lambda (acc pr) (list '+ acc (list '* (car pr) (cdr pr))))
                        (mapcar #'cons row col) :initial-value 0))))
;; ---- NUMERICO GRANDE: MKL Intel (escritorio) o bucle nativo tipado (web) ----
;; Igual que Hekatan Lab: una matriz de NUMEROS grande no se multiplica entrada por
;; entrada con listas; se copia a un arreglo double-float plano y se llama a
;; cblas_dgemm / LAPACKE_dgesv de MKL. Sin MKL (web = ECL->WASM, o la DLL no esta)
;; se usa un bucle con tipos declarados, que el compilador vuelve codigo maquina.
;; Matrices chicas o con fracciones/letras siguen por el camino EXACTO de siempre.
(defparameter *hk-fast-min* 32768)          ; m*k*n desde donde conviene (32^3)
(defparameter *hk-mkl* :sin-probar)         ; :sin-probar | t | nil
(defun hk-mkl-candidatos ()
  #+sbcl
  (let ((rt (and sb-ext:*runtime-pathname* (directory-namestring sb-ext:*runtime-pathname*)))
        (env (sb-ext:posix-getenv "HEKATAN_MKL")))
    (remove nil
            (list (and env (if (search ".dll" env) env (concatenate 'string env "/mkl_rt.3.dll")))
                  (and rt (concatenate 'string rt "../mkl/mkl_rt.3.dll"))   ; <app>/sbcl -> <app>/mkl
                  (and rt (concatenate 'string rt "mkl/mkl_rt.3.dll"))
                  "C:/Program Files/Hekatan Lab/mkl/mkl_rt.3.dll")))
  #-sbcl nil)
(defun hk-mkl-p ()
  "Carga MKL la primera vez que hace falta. NIL si no hay (se usa el bucle nativo)."
  (when (eq *hk-mkl* :sin-probar)
    (setf *hk-mkl* nil)
    #+sbcl
    (dolist (p (if (equal (sb-ext:posix-getenv "HEKATAN_MKL") "0") nil (hk-mkl-candidatos)))   ; 0 = apagada
      (when (probe-file p)
        (when (ignore-errors (sb-alien:load-shared-object p :dont-save t)
                             (sb-sys:find-foreign-symbol-address "cblas_dgemm"))
          (setf *hk-mkl* t) (return)))))
  *hk-mkl*)
(defun hk-mkl-fn (name)
  #+sbcl (sb-sys:int-sap (sb-sys:find-foreign-symbol-address name))
  #-sbcl (declare (ignore name)))

(defun hk-num-rows-p (rows)
  "¿Solo enteros y decimales? (fracciones exactas y letras -> camino exacto)."
  (every (lambda (r) (every (lambda (x) (or (integerp x) (floatp x))) r)) rows))
(defun hk-rows->d (rows m n)
  (let ((a (make-array (* m n) :element-type 'double-float)) (i 0))
    (dolist (r rows a)
      (dolist (x r) (setf (aref a i) (float x 1d0)) (incf i)))
    (unless (= i (* m n)) (error "matriz no rectangular"))
    a))
(defun hk-d->rows (c m n enteros)
  "Vuelve a filas; si todo entraba ENTERO, el resultado sale entero (19, no 19.0)."
  (loop for i below m collect
    (loop for j below n collect
      (let ((v (aref c (+ (* i n) j)))) (if enteros (round v) v)))))

(defun hk-dgemm-nativo (a b m k n)
  (declare (type (simple-array double-float (*)) a b) (type fixnum m k n)
           (optimize (speed 3) (safety 0)))
  (let ((c (make-array (* m n) :element-type 'double-float :initial-element 0d0)))
    (dotimes (i m c)                                   ; orden i-p-j: recorre b por filas
      (dotimes (p k)
        (let ((aip (aref a (+ (* i k) p))) (bo (* p n)) (co (* i n)))
          (declare (type double-float aip) (type fixnum bo co))
          (dotimes (j n)
            (incf (aref c (+ co j)) (* aip (aref b (+ bo j))))))))))
(defun hk-dgemm (a b m k n)
  "C(m x n) = A(m x k) · B(k x n), fila mayor. MKL si esta; si no, bucle nativo."
  (if (hk-mkl-p)
      #+sbcl
      (let ((c (make-array (* m n) :element-type 'double-float :initial-element 0d0)))
        (sb-sys:with-pinned-objects (a b c)
          (sb-alien:alien-funcall
           (sb-alien:sap-alien (hk-mkl-fn "cblas_dgemm")
             (function sb-alien:void sb-alien:int sb-alien:int sb-alien:int sb-alien:int sb-alien:int sb-alien:int
                       double-float sb-sys:system-area-pointer sb-alien:int sb-sys:system-area-pointer sb-alien:int
                       double-float sb-sys:system-area-pointer sb-alien:int))
           101 111 111 m n k 1d0 (sb-sys:vector-sap a) k (sb-sys:vector-sap b) n 0d0 (sb-sys:vector-sap c) n))
        c)
      #-sbcl nil
      (hk-dgemm-nativo a b m k n)))

(defun hk-dgesv-nativo (a b n nrhs)
  "Resuelve A·X = B por Gauss con pivoteo parcial (double). NIL si es singular."
  (declare (type (simple-array double-float (*)) a b) (type fixnum n nrhs)
           (optimize (speed 3) (safety 0)))
  (dotimes (c n b)
    (let ((piv c) (mx (abs (aref a (+ (* c n) c)))))
      (declare (type fixnum piv) (type double-float mx))
      (loop for r fixnum from (1+ c) below n
            do (let ((v (abs (aref a (+ (* r n) c))))) (when (> v mx) (setf mx v piv r))))
      (when (< mx 1d-300) (return-from hk-dgesv-nativo nil))
      (unless (= piv c)
        (dotimes (j n) (rotatef (aref a (+ (* c n) j)) (aref a (+ (* piv n) j))))
        (dotimes (j nrhs) (rotatef (aref b (+ (* c nrhs) j)) (aref b (+ (* piv nrhs) j)))))
      (let ((d (aref a (+ (* c n) c))))
        (loop for r fixnum from 0 below n unless (= r c)
              do (let ((f (/ (aref a (+ (* r n) c)) d)))
                   (declare (type double-float f))
                   (unless (zerop f)
                     (loop for j fixnum from c below n
                           do (decf (aref a (+ (* r n) j)) (* f (aref a (+ (* c n) j)))))
                     (dotimes (j nrhs)
                       (decf (aref b (+ (* r nrhs) j)) (* f (aref b (+ (* c nrhs) j)))))))))))
  (dotimes (r n b)
    (let ((d (aref a (+ (* r n) r))))
      (dotimes (j nrhs) (setf (aref b (+ (* r nrhs) j)) (/ (aref b (+ (* r nrhs) j)) d))))))
(defun hk-dgesv (a b n nrhs)
  "X de A·X = B (B se sobrescribe). MKL LAPACKE_dgesv si esta. NIL si A es singular."
  (if (hk-mkl-p)
      #+sbcl
      (let ((ipiv (make-array n :element-type '(signed-byte 32) :initial-element 0)))
        (sb-sys:with-pinned-objects (a b ipiv)
          (let ((info (sb-alien:alien-funcall
                       (sb-alien:sap-alien (hk-mkl-fn "LAPACKE_dgesv")
                         (function sb-alien:int sb-alien:int sb-alien:int sb-alien:int
                                   sb-sys:system-area-pointer sb-alien:int sb-sys:system-area-pointer
                                   sb-sys:system-area-pointer sb-alien:int))
                       101 n nrhs (sb-sys:vector-sap a) n (sb-sys:vector-sap ipiv) (sb-sys:vector-sap b) nrhs)))
            (if (zerop info) b nil))))
      #-sbcl nil
      (hk-dgesv-nativo a b n nrhs)))

(defun hk-minv-rapida (rows n)
  "Inversa numerica en double (MKL o nativa). NIL si singular."
  (let ((id (make-array (* n n) :element-type 'double-float :initial-element 0d0)))
    (dotimes (i n) (setf (aref id (+ (* i n) i)) 1d0))
    (let ((x (hk-dgesv (hk-rows->d rows n n) id n n)))
      (and x (hk-d->rows x n n nil)))))

(defun mmul (a b)
  (let* ((rowsa (to-rows a)) (rowsb (to-rows b))
         (m (length rowsa)) (k (length (car rowsa))) (n (length (car rowsb))))
    (if (and (= k (length rowsb)) (>= (* m k n) *hk-fast-min*)
             (hk-num-rows-p rowsa) (hk-num-rows-p rowsb))
        (let ((ent (and (every (lambda (r) (every #'integerp r)) rowsa)
                        (every (lambda (r) (every #'integerp r)) rowsb))))
          (from-rows (hk-d->rows (hk-dgemm (hk-rows->d rowsa m k) (hk-rows->d rowsb k n) m k n) m n ent)))
        (let ((cb (apply #'mapcar #'list rowsb)))
          (from-rows (mapcar (lambda (row) (mapcar (lambda (col) (mdot row col)) cb)) rowsa))))))
(defun mscale (s x)
  (from-rows (mapcar (lambda (row) (mapcar (lambda (e) (if (nums2 s e) (* s e) (simplify (list '* s e)))) row)) (to-rows x))))
(defun madd (a b)
  (from-rows (mapcar (lambda (r1 r2) (mapcar (lambda (e f) (if (nums2 e f) (+ e f) (simplify (list '+ e f)))) r1 r2))
                     (to-rows a) (to-rows b))))
(defun msub (a b)
  (from-rows (mapcar (lambda (r1 r2) (mapcar (lambda (e f) (if (nums2 e f) (- e f) (simplify (list '- e f)))) r1 r2))
                     (to-rows a) (to-rows b))))
(defun mrange (a &optional s b)                                   ; (a b) o (a s b)
  (unless b (setf b s s 1))
  (coerce (loop for x from a to b by s collect x) 'vector))

;; INVERSA por Gauss-Jordan. Convierte cada entrada a número (eval-consts) y resuelve
;; con aritmética EXACTA de SBCL (racionales). Matriz singular -> se deja igual.

;; Reduce una expresion a un numero EXACTO si solo tiene numeros y las cuatro
;; operaciones. Devuelve NIL si no puede. Hace falta porque `eval-consts` NO
;; evalua aritmetica: una entrada como 5/2 llegaba a `mnum` como la lista
;; (/ 5 2), `numberp` daba NIL y se convertia en 0 -> el pivote salia cero y
;; `minv` devolvia la matriz SIN INVERTIR, en silencio. Solo funcionaba con
;; matrices de enteros.
(defun num-eval (e)
  (cond
    ((numberp e) e)
    ((atom e) nil)
    (t (let ((op (car e)) (as (mapcar #'num-eval (cdr e))))
         (when (and as (every #'identity as))
           (case op
             (+ (reduce #'+ as))
             (- (if (cdr as) (reduce #'- as) (- (car as))))
             (* (reduce #'* as))
             (neg (- (car as)))
             (/ (if (and (cdr as) (notany #'zerop (cdr as))) (reduce #'/ as) nil))
             ((expt ^) (if (and (= (length as) 2) (integerp (second as)))
                           (ignore-errors (expt (first as) (second as))) nil))
             (t nil)))))))

;; Los decimales se pasan a racional para que la eliminacion de Gauss de `minv`
;; siga siendo EXACTA (0.15 -> 3/20) y la inversa salga en fracciones limpias.
(defun mnum (e)
  (let* ((v (ignore-errors (eval-consts (simplify e))))
         (n (or (and (numberp v) v) (num-eval v) (num-eval e))))
    (cond ((null n) 0)
          ((floatp n) (rational n))
          (t n))))
;; ¿toda la matriz reduce a NUMERO de verdad? `mnum` devuelve 0 cuando no puede,
;; asi que preguntarselo a el no sirve: una entrada simbolica se colaba como 0 y
;; la eliminacion de Gauss daba un pivote nulo -> `minv` devolvia la matriz SIN
;; INVERTIR, en silencio. Con letras ([a,b;b,a]^-1) salia la propia matriz y la
;; comprobacion A·A^-1 daba [a^2+b^2, 2ab; ...] en vez de la identidad.
(defun mat-numeric-p (x)
  (every (lambda (fila)
           (every (lambda (c)
                    (let ((v (ignore-errors (eval-consts (simplify c)))))
                      (or (numberp v) (numberp (num-eval v)) (numberp (num-eval c)))))
                  fila))
         (to-rows x)))


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

;; determinante SIMBÓLICO por expansión de Laplace en la 1a fila (cofactores).
;; Funciona con entradas simbólicas (a diferencia de minv, que numericiza). Sumas
;; BINARIAS anidadas para que `simplify` combine término a término.
(defun mminor (rows i j)   ; submatriz quitando fila i, columna j (rows = lista de listas)
  (loop for r from 0 below (length rows) unless (= r i)
        collect (loop for c from 0 below (length (nth r rows)) unless (= c j)
                      collect (nth c (nth r rows)))))
(defun mdet (x)
  (let* ((rows (to-rows x)) (n (length rows)))
    (cond
      ((= n 1) (caar rows))
      ((= n 2) (let ((a (nth 0 (nth 0 rows))) (b (nth 1 (nth 0 rows)))
                     (c (nth 0 (nth 1 rows))) (d (nth 1 (nth 1 rows))))
                 (if (and (numberp a) (numberp b) (numberp c) (numberp d))
                     (- (* a d) (* b c))
                     (simplify (list '- (list '* a d) (list '* b c))))))
      (t (let ((acc 0))
           (loop for j from 0 below n do
             (let ((term (list '* (nth j (car rows)) (mdet (from-rows (mminor rows 0 j))))))
               (setf acc (list (if (evenp j) '+ '-) acc term))))
           (simplify acc))))))

;; INVERSA SIMBÓLICA por adjunta/determinante: inv(A) = (1/det A)·adj(A), con
;; adj = transpuesta de la matriz de cofactores C_ij = (-1)^(i+j)·minor(i,j).
;; A diferencia de minv (numérica), funciona con entradas simbólicas (Jᵀ, J⁻¹ del FEM).
(defun madjugate (x)
  "Matriz ADJUNTA = transpuesta de la matriz de cofactores. Sirve para C^-1 = adj(C)/det(C)."
  (let* ((rows (to-rows x)) (n (length rows)))
    (if (= n 1) (from-rows (list (list 1)))
        (let ((cof (loop for i from 0 below n collect
                     (loop for j from 0 below n collect
                       (let ((m (mdet (from-rows (mminor rows i j)))))
                         (if (evenp (+ i j)) m (simplify (list '- m))))))))
          (mtransp (from-rows cof))))))

(defun msinv (x)
  (let* ((rows (to-rows x)) (n (length rows)) (d (mdet x)))
    (if (= n 1)
        (from-rows (list (list (simplify (list '/ 1 (caar rows))))))
        (let ((cof (loop for i from 0 below n collect
                     (loop for j from 0 below n collect
                       (let ((m (mdet (from-rows (mminor rows i j)))))
                         (if (evenp (+ i j)) m (simplify (list '- m))))))))
          (mscale (simplify (list '/ 1 d)) (mtransp (from-rows cof)))))))

;; La inversa se ENRUTA segun lo que haya DENTRO: si todo son numeros, Gauss
;; exacto (fracciones limpias); si hay letras, adjunta/determinante. Asi
;; [a,b;b,a]^-1 sale en algebra y A·A^-1 da la identidad de verdad.
;; GRANDE (n > 20) y solo enteros/decimales -> double por MKL: con racionales
;; exactos una 100x100 de decimales no termina nunca. Las chicas no cambian (fracciones).
(defun minv-auto (x)
  (let* ((rows (to-rows x)) (n (length rows)))
    (cond ((and (> n 20) (every (lambda (r) (= (length r) n)) rows) (hk-num-rows-p rows))
           (let ((inv (hk-minv-rapida rows n))) (if inv (from-rows inv) x)))
          ((mat-numeric-p x) (minv x))
          (t (msinv x)))))

;; ---- los PASOS de la inversa, sueltos, para poder ENSENARLA ----
;; La inversa no es un boton: es det -> menores -> cofactores -> adjunta -> dividir.
;; Cada paso se expone al usuario para escribirlo en la hoja y verlo en algebra.

;; menor(A; i; j) = la submatriz que queda al TACHAR la fila i y la columna j (1-based).
(defun mminor-mat (x i j)
  (from-rows (mminor (to-rows x) (1- i) (1- j))))

;; cof(A) = matriz de COFACTORES: C_ij = (-1)^(i+j) · det(menor_ij).
;; La adjunta es su transpuesta; por eso adj y cof se parecen pero NO son iguales.
(defun mcofactors (x)
  (let* ((rows (to-rows x)) (n (length rows)))
    (from-rows
      (loop for i from 0 below n collect
        (loop for j from 0 below n collect
          (let ((m (mdet (from-rows (mminor rows i j)))))
            (if (evenp (+ i j)) m (simplify (list '- m)))))))))

;; TRAZA = suma de la diagonal principal (escalar). tr(A) = a11 + a22 + ...
(defun mtrace (x)
  (let* ((rows (to-rows x)) (n (length rows)) (acc 0))
    (loop for i from 0 below n do (setf acc (list '+ acc (nth i (nth i rows)))))
    (simplify acc)))

;; componentes PLANAS de un vector, sea fila o columna.
(defun vec-comps (x)
  (let ((rows (to-rows x)))
    (if (and rows (> (length rows) 1)) (mapcar #'car rows) (car rows))))

;; PRODUCTO CRUZ de dos vectores 3D -> vector columna perpendicular a ambos.
(defun mcross (a b)
  (let* ((ac (vec-comps a)) (bc (vec-comps b))
         (a1 (nth 0 ac)) (a2 (nth 1 ac)) (a3 (nth 2 ac))
         (b1 (nth 0 bc)) (b2 (nth 1 bc)) (b3 (nth 2 bc)))
    (from-rows (list (list (simplify (list '- (list '* a2 b3) (list '* a3 b2))))
                     (list (simplify (list '- (list '* a3 b1) (list '* a1 b3))))
                     (list (simplify (list '- (list '* a1 b2) (list '* a2 b1))))))))

;; construye la matriz de un literal [ … ]: si los elementos ya son matrices/filas,
;; los apila por filas (vertcat); si son escalares, es una sola fila.
(defun build-mat (elems)
  (if (some #'vectorp elems)
      (from-rows (apply #'append (mapcar #'to-rows elems)))
      (coerce elems 'vector)))

;; integral DEFINIDA de una matriz respecto a var, de a a b: integra cada entrada
;; (polinomio en var) con area-under. Sirve para H = ∫∫ QᵀDQ (aplicada dos veces).
(defun mintegrate (mat var a b)
  (from-rows (mapcar (lambda (row) (mapcar (lambda (e) (area-under e var a b)) row)) (to-rows mat))))

;; meval: evalúa una expresión que MEZCLA matrices y escalares.
;;   (vector …) construye ; mtransp/mrange ; + - * expt(-1)=inversa ; escalar·matriz ; ∫ matriz.
(defun meval (e)
  (cond
    ((atom e) e)
    ((eq (car e) 'quote) (second e))
    ((eq (car e) 'vector) (build-mat (mapcar #'meval (cdr e))))
    ((eq (car e) 'mtransp) (mtransp (meval (second e))))
    ;; transpose(M): alias de mtransp para que el usuario escriba transpose(B) y
    ;; se transponga de verdad (antes quedaba sin evaluar -> "?"). Funciona simbólico.
    ((eq (car e) 'transpose) (mtransp (meval (second e))))
    ;; det(M): determinante simbólico (para detJ del Jacobiano, etc.).
    ((eq (car e) 'det) (mdet (meval (second e))))
    ((eq (car e) 'inv) (msinv (meval (second e))))
    ((eq (car e) 'adj) (madjugate (meval (second e))))
    ;; cof(M) y menor(M; i; j): los PASOS de la inversa, para ensenarla en algebra.
    ((eq (car e) 'cof) (mcofactors (meval (second e))))
    ;; dec(x) / dec(x, n): resultado en DECIMAL en vez de fraccion exacta.
    ((eq (car e) 'dec)
     (let ((n (if (third e) (let ((k (mnum (meval (third e))))) (if (integerp k) k 4)) 6)))
       (to-dec (meval (second e)) n (null (third e)))))
    ((member (car e) '(menor minor)) (mminor-mat (meval (second e))
                                               (mnum (meval (third e)))
                                               (mnum (meval (fourth e)))))
    ;; trace(M): traza (suma de la diagonal). cross(u,v): producto cruz 3D.
    ((eq (car e) 'trace) (mtrace (meval (second e))))
    ;; ceil/floor/round/max/min: numericos, termino a termino sobre vectores (ver num-fn)
    ((member (car e) *num-fns*) (num-fn (car e) (mapcar #'meval (cdr e))))
    ;; matriz / escalar (As/Ab con As vector): antes caia al ramal generico y no se dividia
    ((and (eq (car e) '/) (= (length e) 3))
     ;; un 1x1 cuenta como ESCALAR (vᵀ·u en Sherman-Morrison): se escalariza antes de decidir
     (let ((a (scalarize (hk-dn (meval (second e))))) (b (scalarize (hk-dn (meval (third e))))))
       (cond ((and (matp a) (not (matp b))) (mscale (simplify (list '/ 1 b)) a))
             ;; escalar / vector y vector / vector (mismo largo): termino a termino (b/n con n vector)
             ((and (matp b) (or (not (matp a)) (equal (array-dimensions a) (array-dimensions b)))
                   (not (vectorp (aref b 0))))
              (map 'vector (lambda (x y) (simplify (list '/ x y)))
                   (if (matp a) a (make-array (length b) :initial-element a)) b))
             (t (clean (simplify (list '/ (scalarize a) (scalarize b))))))))
    ;; Expand{…} / Simplify{…} / Factor{…} sobre MATRICES: antes caian al ramal
    ;; generico y devolvian la forma SIN evaluar (el producto quedaba escrito). El
    ;; algebra de matrices ya simplifica cada entrada al operar, asi que basta con
    ;; evaluar dentro; si lo de dentro resulta escalar, se simplifica como escalar.
    ((member (car e) '(expand* factor simplify simplif clean))
     (let ((v (scalarize (meval (second e)))))
       (if (matp v) v (simplify v))))
    ((eq (car e) 'cross) (mcross (meval (second e)) (meval (third e))))
    ;; despejar dentro de una expr con matrices (autovalores: Despejar{det(K-λM)=0 @ λ}).
    ;; La forma llega enrutada a meval por las matrices; se resuelve la ecuacion (despejar
    ;; ya evalua det en sus lados). Desenvuelve los args citados.
    ((eq (car e) 'despejar)
     (flet ((unq (x) (if (and (consp x) (eq (car x) 'quote)) (second x) x)))
       (despejar (unq (second e)) (unq (third e)) (unq (fourth e)))))
    ((eq (car e) 'ngauss)
     (flet ((unq (x) (if (and (consp x) (eq (car x) 'quote)) (second x) x)))
       (ngauss (meval (unq (second e))) (unq (third e)) (unq (fourth e)))))
    ;; parciales/derivadas DENTRO de una matriz: si no se evalúan aquí, un
    ;; J = [∂x/∂ξ …] guarda la forma ∂ sin reducir y det(J) opera sobre símbolos
    ;; opacos. Evaluándolas, la matriz de un Jacobiano queda con sus valores.
    ((eq (car e) 'partial)  (partial  (meval (second e)) (meval (third e))))
    ((eq (car e) 'derive-x) (if (cddr e) (derive-x (meval (second e)) (meval (third e)))
                                (derive-x (meval (second e)))))
    ((eq (car e) 'mrange)  (apply #'mrange (mapcar #'meval (cdr e))))
    ((eq (car e) 'area-under)          ; ∫ de una MATRIZ (entrada por entrada) o escalar
     (let* ((fa (second e)) (va (third e))
            (fform (if (and (consp fa) (eq (car fa) 'quote)) (second fa) fa))   ; desenvuelve '(...)
            (var   (if (and (consp va) (eq (car va) 'quote)) (second va) va))
            (m (meval fform)))
       (if (vectorp m)
           (mintegrate m var (meval (fourth e)) (meval (fifth e)))
           (area-under fform var (meval (fourth e)) (meval (fifth e))))))
    ((eq (car e) '+) (m2 #'madd #'+ (meval (second e)) (meval (third e))))
    ((eq (car e) '-) (if (cddr e) (m2 #'msub #'- (meval (second e)) (meval (third e)))
                         (let ((v (meval (second e))))    ; menos unario: matriz -> escalar -1; escalar -> -x
                           (if (matp v) (mscale -1 v) (simplify (list '- v))))))
    ((eq (car e) '*) (mtimes (hk-dn (meval (second e))) (hk-dn (meval (third e)))))
    ((eq (car e) 'expt)
     (let ((base (meval (second e))) (p (meval (third e))))
       (if (and (matp base) (eql p -1)) (minv-auto base) (simplify (list 'expt base p)))))
    ;; funcion escalar (sqrt, sin, …) sobre una expr matricial que da 1x1 (p.ej. sqrt(uᵀu)):
    ;; colapsa el 1x1 a su escalar y REDUCE con clean (psqrt: sqrt de cuadrado perfecto -> entero).
    ;; sqrt([25]) -> sqrt(25) -> 5.
    (t (clean (simplify (cons (car e) (mapcar (lambda (x) (scalarize (meval x))) (cdr e))))))))
(defun scalarize (v)
  "Vector 1x1 -> su escalar (recursivo: #(25) -> 25, #(#(25)) -> 25). Otro tamaño se deja igual."
  (if (and (vectorp v) (= (length v) 1))
      (scalarize (aref v 0))
      v))
(defun m2 (mf sf a b) (if (or (matp a) (matp b)) (funcall mf a b) (simplify (list (if (eq sf #'+) '+ '-) a b))))
(defun mtimes (a b)
  (cond ((and (matp a) (matp b)) (mmul a b))
        ((matp a) (mscale b a))
        ((matp b) (mscale a b))
        (t (simplify (list '* a b)))))

;; imprime el resultado como forma (vector …) para que el parser de C# lo lea y renderice.
;; imprime un float sin el sufijo d0/e0 de SBCL y sin ceros de cola (1.3333, 12.0->12)
;; Redondea a 10 CIFRAS SIGNIFICATIVAS (quita el ruido del float: 75000.00000000001 -> 75000,
;; 395.43750000000003 -> 395.4375) y quita ceros de cola.
(defun fmt-float (x)
  (let ((d (float x 1d0)))
    (if (or (zerop d) #+sbcl (sb-ext:float-infinity-p d) #-sbcl (ext:float-infinity-p d)
                      #+sbcl (sb-ext:float-nan-p d) #-sbcl (ext:float-nan-p d))
        (if (zerop d) "0" (format nil "~a" d))
        (let* ((e (floor (log (abs d) 10d0)))
               (m (expt 10 (- 9 e)))                          ; 10 cifras: 10^(9-e)
               (r (float (/ (round (* (rational d) m)) m) 1d0))
               (s (let ((*read-default-float-format* 'double-float)) (princ-to-string r)))
               (ep (position #\e s)))
          (let ((mant (if ep (subseq s 0 ep) s)) (ex (if ep (subseq s ep) "")))
            (when (find #\. mant)
              (setf mant (string-right-trim "0" mant))
              (when (char= (char mant (1- (length mant))) #\.)
                (setf mant (subseq mant 0 (1- (length mant))))))
            (concatenate 'string mant ex))))))
(defun mprint (x)
  (cond ((vectorp x) (format nil "(vector ~{~a~^ ~})" (map 'list #'mprint x)))
        ((floatp x) (fmt-float x))
        (t (format nil "~a" x))))
;; CL: (sqrt 2), (sin 1), (expt 2 1/2) de un RACIONAL devuelven SINGLE (7 cifras) aunque
;; *read-default-float-format* sea double. dbl-args pasa esos argumentos a double antes de evaluar.
(defun dbl (x) (if (rationalp x) (float x 1d0) x))
(defun dexpt (a b)
  (if (and (rationalp a) (rationalp b) (not (integerp b))) (expt (float a 1d0) b) (expt a b)))
(defun dbl-args (f)
  (cond ((atom f) f)
        ((eq (car f) 'quote) f)
        ((member (car f) '(sqrt sin cos tan asin acos atan sinh cosh tanh asinh acosh atanh exp log))
         (cons (car f) (mapcar (lambda (a) (list 'dbl (dbl-args a))) (cdr f))))
        ((and (eq (car f) 'expt) (= (length f) 3))
         (list 'dexpt (dbl-args (second f)) (dbl-args (third f))))
        (t (cons (car f) (mapcar #'dbl-args (cdr f))))))
;; resultado para mostrar: floats -> texto redondeado (fmt-float), tambien DENTRO de formas
;; simbolicas ((* 0.30000000000000004 x) -> (* 0.3 x)). ~a escribe el texto sin comillas.
(defun show (x)
  (cond ((floatp x) (fmt-float x))
        ((and (complexp x) (floatp (realpart x)))
         (format nil "#c(~a ~a)" (fmt-float (realpart x)) (fmt-float (imagpart x))))
        ((vectorp x) (if (stringp x) x (mprint x)))
        ((consp x) (cons (show (car x)) (show (cdr x))))
        (t x)))

;; ---- SERVIDOR PERSISTENTE: un proceso SBCL vivo que evalua formas de stdin y responde ----
;; Elimina el arranque (~80 ms) por evaluacion. El WPF manda las formas (que hacen format t) y
;; al final (hlisp-done); el server evalua cada una e imprime, y cierra la respuesta con \x1e.
(defun hlisp-server ()
  (setf *print-case* :downcase)
  (setf *print-right-margin* 100000)
  (setf *read-default-float-format* 'double-float)   ; 0.09 = double (ver arriba)
  (loop
    (let ((form (handler-case (read *standard-input* nil :hlisp-eof)
                  (error () :hlisp-skip))))
      (cond
        ((eq form :hlisp-eof) (return))
        ((eq form :hlisp-skip) (read-line *standard-input* nil :hlisp-eof))   ; resincroniza
        ((equal form '(hlisp-done))
         (write-char (code-char 30)) (finish-output))                        ; \x1e = fin de respuesta (SIN newline)
        (t (handler-case (eval form) (error (e) (format t "; error: ~a~%" e)))
           (finish-output))))))

;;;; ===== UNIDADES (pegado aquí a propósito: engine.lisp es lo ÚNICO que
;;;; ===== se hornea en el core de SBCL y se compila dentro de hlisp.wasm) =====
;;;; unidades.lisp — cantidades con unidades para Hekatan LISP
;;;;
;;;; El modelo está SACADO de dos programas, no inventado:
;;;;
;;;;   · Mathcad Prime 10 (sus DLL .NET, McdStaticUnitSystem): dimensiones base
;;;;     con exponentes, y las unidades derivadas definidas por su FÓRMULA
;;;;     física (newton = m·kg/s², pascal = N/m², joule = N·m…), no por una
;;;;     tabla de factores a mano. Los prefijos son funciones: kilo(pascal).
;;;;     Mathcad guarda los exponentes en punto fijo ×60000 para que ½ y ⅓
;;;;     salgan exactos; aquí se usan RACIONALES de Common Lisp, que son
;;;;     exactos por construcción y no necesitan esa escala.
;;;;
;;;;   · Calcpad (Calcpad.Core/BaseTypes/Unit.cs): el orden de las dimensiones
;;;;     —incluido el ÁNGULO como una más— y la sintaxis `3m|cm`, donde lo que
;;;;     va tras la barra es la unidad en la que se quiere VER el resultado.
;;;;
;;;; Una cantidad es (:q valor . dims) con dims = vector de 8 racionales:
;;;;   0 masa · 1 longitud · 2 tiempo · 3 corriente · 4 temperatura
;;;;   5 sustancia · 6 luminosidad · 7 ángulo
;;;; El valor se guarda SIEMPRE en unidades base del SI (kg, m, s, A, K, mol,
;;;; cd, rad): así sumar y comparar no necesita convertir nada.

(defconstant +dim-n+ 8)
(defparameter *dim-nombres* #("masa" "longitud" "tiempo" "corriente"
                              "temperatura" "sustancia" "luminosidad" "ángulo"))

(defun dims (&rest pares)
  "dims :longitud 1 :tiempo -2  →  #(0 1 -2 0 0 0 0 0)"
  (let ((v (make-array +dim-n+ :initial-element 0)))
    (loop for (k e) on pares by #'cddr
          do (setf (aref v (position (string-downcase (symbol-name k))
                                     *dim-nombres* :test #'string=))
                   e))
    v))

(defun q (valor &optional (d (make-array +dim-n+ :initial-element 0)))
  (list* :q valor d))
(defun q-p (x) (and (consp x) (eq (car x) :q)))
(defun q-val (x) (if (q-p x) (cadr x) x))
(defun q-dim (x) (if (q-p x) (cddr x) (make-array +dim-n+ :initial-element 0)))
(defun adimensional-p (x) (every #'zerop (q-dim x)))

(defun dim= (a b) (every #'= (q-dim a) (q-dim b)))
(defun dim+ (a b) (map 'vector #'+ (q-dim a) (q-dim b)))
(defun dim- (a b) (map 'vector #'- (q-dim a) (q-dim b)))
(defun dim* (a k) (map 'vector (lambda (e) (* e k)) (q-dim a)))

(defparameter *sup-digitos* "⁰¹²³⁴⁵⁶⁷⁸⁹")
(defun sup (n)
  "2 → ², -3 → ⁻³ (el exponente se LEE, no se escribe con acento circunflejo)"
  (if (= n 1) ""
      (let ((s (format nil "~a" (abs n))))
        (concatenate 'string
                     (if (minusp n) "⁻" "")
                     (map 'string (lambda (c)
                                    (if (digit-char-p c)
                                        (char *sup-digitos* (digit-char-p c))
                                        c))
                          s)))))

(defun dim-texto (x)
  (let ((s '()))
    (loop for i from 0 below +dim-n+
          for e = (aref (q-dim x) i)
          unless (zerop e)
            do (push (format nil "~a~a" (aref *dim-nombres* i) (sup e)) s))
    (if s (format nil "~{~a~^·~}" (nreverse s)) "adimensional")))

;;; ── Aritmética: la que comprueba dimensiones ──────────────────────────

(define-condition unidades-incompatibles (error)
  ((op :initarg :op) (a :initarg :a) (b :initarg :b))
  (:report (lambda (c s)
             (format s "no se puede ~a ~a con ~a"
                     (slot-value c 'op)
                     (dim-texto (slot-value c 'a))
                     (dim-texto (slot-value c 'b))))))

(defun q+ (a b)
  (unless (dim= a b) (error 'unidades-incompatibles :op "sumar" :a a :b b))
  (q (+ (q-val a) (q-val b)) (q-dim a)))
(defun q- (a b)
  (unless (dim= a b) (error 'unidades-incompatibles :op "restar" :a a :b b))
  (q (- (q-val a) (q-val b)) (q-dim a)))
(defun q* (a b) (q (* (q-val a) (q-val b)) (dim+ a b)))
(defun q/ (a b) (q (/ (q-val a) (q-val b)) (dim- a b)))
(defun q^ (a n)
  (let ((k (q-val n)))
    (unless (adimensional-p n)
      (error 'unidades-incompatibles :op "elevar a" :a a :b n))
    (q (expt (q-val a) k) (dim* a (rational k)))))

;;; ── El catálogo: las bases valen 1, las derivadas son su fórmula ──────

(defparameter *unidades* (make-hash-table :test #'equal))
(defun def-u (nombre cantidad) (setf (gethash nombre *unidades*) cantidad) cantidad)
(defun u-simple (nombre)
  (or (gethash nombre *unidades*)
      ;; «cm2» = cm^2: dígito final pegado, como se escribe en obra
      (let* ((n (length nombre))
             (c (and (> n 1) (char nombre (1- n)))))
        (if (and c (digit-char-p c) (gethash (subseq nombre 0 (1- n)) *unidades*))
            (q^ (gethash (subseq nombre 0 (1- n)) *unidades*)
                (q (digit-char-p c)))
            (error "unidad desconocida: ~a" nombre)))))

(defun partir (cadena sep)
  (loop with ini = 0 for i = (position sep cadena :start ini)
        collect (subseq cadena ini i)
        while i do (setf ini (1+ i))))

(defun u-factor (trozo)
  "kN, m^3, cm2 … un factor suelto con su potencia."
  (let ((c (position #\^ trozo)))
    (if c
        (q^ (u-simple (subseq trozo 0 c))
            (q (parse-integer (subseq trozo (1+ c)))))
        (u-simple trozo))))

(defun u (nombre)
  "Una unidad, simple o compuesta: kN/m^2, tonf/m3, kgf/cm2, N*m."
  (or (gethash nombre *unidades*)
      (let* ((partes (partir nombre #\/))
             (num (reduce #'q* (mapcar #'u-factor (partir (first partes) #\*)))))
        (dolist (d (rest partes) num)
          (setf num (q/ num (reduce #'q* (mapcar #'u-factor (partir d #\*)))))))))

(def-u "kg"  (q 1 (dims :masa 1)))
(def-u "m"   (q 1 (dims :longitud 1)))
(def-u "s"   (q 1 (dims :tiempo 1)))
(def-u "A"   (q 1 (dims :corriente 1)))
(def-u "K"   (q 1 (dims :temperatura 1)))
(def-u "mol" (q 1 (dims :sustancia 1)))
(def-u "cd"  (q 1 (dims :luminosidad 1)))
(def-u "rad" (q 1 (dims :ángulo 1)))

;; prefijos como FUNCIONES, igual que Mathcad
(defun kilo (x) (q* (q 1000) x))
(defun mega (x) (q* (q 1000000) x))
(defun giga (x) (q* (q 1000000000) x))
(defun mili (x) (q* (q 1/1000) x))
(defun centi (x) (q* (q 1/100) x))
(defun deci (x) (q* (q 1/10) x))
(defun micro (x) (q* (q 1/1000000) x))

;; longitud
(def-u "mm" (mili (u "m")))
(def-u "cm" (centi (u "m")))
(def-u "km" (kilo (u "m")))
(def-u "in" (q* (q 254/10000) (u "m")))
(def-u "ft" (q* (q 12) (u "in")))
;; masa
(def-u "g"  (mili (u "kg")))
(def-u "t"  (kilo (u "kg")))
;; tiempo
(def-u "min" (q* (q 60) (u "s")))
(def-u "h"   (q* (q 3600) (u "s")))
;; derivadas mecánicas — la FÓRMULA, como en Mathcad
(def-u "N"   (q/ (q* (u "m") (u "kg")) (q^ (u "s") (q 2))))
(def-u "kN"  (kilo (u "N")))
(def-u "MN"  (mega (u "N")))
(def-u "Pa"  (q/ (u "N") (q^ (u "m") (q 2))))
(def-u "kPa" (kilo (u "Pa")))
(def-u "MPa" (mega (u "Pa")))
(def-u "GPa" (giga (u "Pa")))
(def-u "J"   (q* (u "N") (u "m")))
(def-u "kJ"  (kilo (u "J")))
(def-u "W"   (q/ (u "J") (u "s")))
(def-u "kW"  (kilo (u "W")))
;; las de obra en Ecuador (ver la regla de unidades de Jorge)
(def-u "kgf"  (q* (q 980665/100000) (u "N")))
(def-u "tonf" (kilo (u "kgf")))
(def-u "kgf/cm2" (q/ (u "kgf") (q^ (u "cm") (q 2))))
(def-u "tonf/m2" (q/ (u "tonf") (q^ (u "m") (q 2))))
(def-u "tonf/m3" (q/ (u "tonf") (q^ (u "m") (q 3))))
(def-u "kN/m2" (q/ (u "kN") (q^ (u "m") (q 2))))
(def-u "kN/m3" (q/ (u "kN") (q^ (u "m") (q 3))))

;;; ── La barra de Calcpad: 3m|cm ────────────────────────────────────────

(defun en (cantidad nombre-unidad)
  "El valor de CANTIDAD medido en NOMBRE-UNIDAD. Es el `|` de Calcpad.
   Falla si las dimensiones no son las mismas: 3m|s no significa nada."
  (let ((destino (u nombre-unidad)))
    (unless (dim= cantidad destino)
      (error 'unidades-incompatibles :op "expresar en" :a cantidad :b destino))
    (/ (q-val cantidad) (q-val destino))))

(defun mostrar (cantidad nombre-unidad &optional (dec 4))
  (format nil "~,vf ~a" dec (float (en cantidad nombre-unidad) 1d0) nombre-unidad))

(defun num (x nombre-unidad)
  "3m se escribe (num 3 \"m\")."
  (q* (q (rational x)) (u nombre-unidad)))

;;; ── Evaluar un árbol de expresión CON unidades ────────────────────────
;;; No pasa por `simplify` ni por `evops`: esos trabajan con números pelados
;;; y no saben de dimensiones. Aquí se interpreta el árbol con q+ q- q* q/ q^,
;;; que son los que comprueban. Un símbolo es una unidad del catálogo.

(defun qeval (e)
  (cond
    ((numberp e) (q (rational e)))
    ((stringp e) (u e))
    ((symbolp e) (u (string-downcase (symbol-name e))))
    ((consp e)
     (let ((op (car e)) (args (mapcar #'qeval (cdr e))))
       (case op
         (+ (reduce #'q+ args))
         (- (if (cdr args) (reduce #'q- args) (q* (q -1) (car args))))
         (* (reduce #'q* args))
         (/ (reduce #'q/ args))
         ((expt ^) (q^ (first args) (second args)))
         (t (error "operación sin unidades: ~a" op)))))
    (t (error "no se puede evaluar: ~a" e))))

(defun qval (e unidad &optional (dec 4))
  "Como qshow pero devuelve SOLO el número: la unidad la dibuja la hoja al lado,
   con el mismo mecanismo del [kN] visible. Si no cuadran las dimensiones,
   devuelve el aviso como texto (y entonces no hay número que dibujar)."
  (handler-case (let ((x (float (en (qeval e) unidad) 1d0)))
                  (to-dec x dec nil))
    (error (c) (format nil "⚠ ~a" c))))

(defun qshow (e unidad &optional (dec 4))
  "El `3m|cm` de la hoja: evalúa E con unidades y lo devuelve medido en UNIDAD."
  (handler-case (mostrar (qeval e) unidad dec)
    (error (c) (format nil "⚠ ~a" c))))

;;;; ===================== HOJA NUMERICA (bloques estilo Calcpad / MATLAB) =====================
;;;; La hoja simbolica trabaja con racionales exactos y sustitucion de etiquetas; para un
;;;; calculo como el de Calcpad (bucles, matrices de 140x140, ensamblaje, K\F) hace falta
;;;; ESTADO: variables que un bucle modifica y que las lineas siguientes leen. Esto es ese
;;;; motor: MainWindow arma UN programa (la hoja + sus bloques, en orden) con estos operadores
;;;; y lo corre de una vez en SBCL.
;;;;   escalar = numero · vector = simple-vector 1-D · matriz = simple-vector de filas
;;;; (la misma forma que (vector (vector ..)) de meval: mprint la imprime tal cual).
;;;; Un vector 1-D multiplica como COLUMNA (A·v) y se concatena como FILA ([v; w] = 2 filas),
;;;; igual que los vectores de numpy o los de Calcpad.

(defvar *hn-line* 0)                         ; linea de la hoja que se esta calculando
(defun hn-true (v) (cond ((null v) nil) ((numberp v) (/= v 0)) (t t)))   ; if/while: 0 y nil = falso

(defun hn-err (fmt &rest args) (error "~a" (apply #'format nil fmt args)))
(defun hn-matp (x) (and (simple-vector-p x) (plusp (length x)) (simple-vector-p (svref x 0))))
(defun hn-vecp (x) (and (simple-vector-p x) (not (hn-matp x))))
(defun hn-num (x)
  "Racional no entero -> double (1/3 -> 0.333…). Los enteros siguen enteros (indices)."
  (if (and (rationalp x) (not (integerp x))) (float x 1d0) x))
(defun hn-d (x) (if (rationalp x) (float x 1d0) x))
(defun hn-int (x)
  (cond ((integerp x) x)
        ((and (floatp x) (< (abs (- x (fround x))) 1d-9)) (round x))
        ((and (rationalp x) (= x (round x))) (round x))
        (t (hn-err "se esperaba un entero (indice o tamano) y llego ~a" x))))
(defun hn-rows (x) (cond ((hn-matp x) (length x)) ((hn-vecp x) (length x)) (t 1)))
(defun hn-cols (x) (if (hn-matp x) (length (svref x 0)) 1))
(defun hn-newvec (n &optional (v 0)) (make-array (hn-int n) :initial-element v))
(defun hn-newmat (r c &optional (v 0))
  (let ((m (make-array (hn-int r))))
    (dotimes (i (length m) m) (setf (svref m i) (make-array (hn-int c) :initial-element v)))))
(defun hn-copy (x)
  (cond ((hn-matp x) (map 'simple-vector #'copy-seq x)) ((hn-vecp x) (copy-seq x)) (t x)))
(defun hn-colmat (v) (map 'simple-vector #'vector v))              ; vector n -> matriz n x 1

;;; ---- aritmetica con difusion ----
(defun hn-map1 (f x)
  (cond ((hn-matp x) (map 'simple-vector (lambda (r) (map 'simple-vector f r)) x))
        ((hn-vecp x) (map 'simple-vector f x))
        (t (funcall f x))))
(defun hn-map2 (f a b)
  (cond ((and (numberp a) (numberp b)) (funcall f a b))
        ((numberp a) (hn-map1 (lambda (y) (funcall f a y)) b))
        ((numberp b) (hn-map1 (lambda (x) (funcall f x b)) a))
        ((and (hn-vecp a) (hn-vecp b))
         (unless (= (length a) (length b))
           (hn-err "vectores de distinto largo: ~a y ~a" (length a) (length b)))
         (map 'simple-vector f a b))
        (t (let ((ma (if (hn-vecp a) (hn-colmat a) a)) (mb (if (hn-vecp b) (hn-colmat b) b)))
             (unless (and (= (length ma) (length mb)) (= (hn-cols ma) (hn-cols mb)))
               (hn-err "dimensiones distintas: ~ax~a y ~ax~a"
                       (length ma) (hn-cols ma) (length mb) (hn-cols mb)))
             (map 'simple-vector (lambda (ra rb) (map 'simple-vector f ra rb)) ma mb)))))
(defun hn+ (a b) (if (and (numberp a) (numberp b)) (+ a b) (hn-map2 #'+ a b)))
(defun hn- (a &optional (b nil bp))
  (if bp
      (if (and (numberp a) (numberp b)) (- a b) (hn-map2 #'- a b))
      (if (numberp a) (- a) (hn-map1 #'- a))))
(defun hn/1 (a b) (hn-num (/ a b)))
(defun hn/ (a b)
  (cond ((and (numberp a) (numberp b)) (hn/1 a b))
        ((numberp b) (hn-map1 (lambda (x) (hn/1 x b)) a))
        ((numberp a) (hn-map1 (lambda (y) (hn/1 a y)) b))
        (t (hn-err "division entre matrices: use A\\b (resolver) o inv(A)"))))
(defun hn-pow1 (a b)
  (hn-num (if (and (rationalp a) (rationalp b) (not (integerp b))) (expt (float a 1d0) b) (expt a b))))
(defun hn-mm (a b)
  "Matriz (filas) x matriz (filas)."
  (let ((m (length a)) (k (hn-cols a)) (n (hn-cols b)))
    (unless (= k (length b))
      (hn-err "producto de matrices: ~ax~a por ~ax~a no encaja" m k (length b) n))
    (let ((c (hn-newmat m n 0)))
      (dotimes (i m c)
        (let ((ai (svref a i)) (ci (svref c i)))
          (dotimes (p k)
            (let ((aip (svref ai p)))
              (unless (and (numberp aip) (zerop aip))
                (let ((bp (svref b p)))
                  (dotimes (j n) (setf (svref ci j) (+ (svref ci j) (* aip (svref bp j))))))))))))))
(defun hn* (a b)
  (cond ((and (numberp a) (numberp b)) (* a b))
        ((numberp a) (hn-map1 (lambda (y) (* a y)) b))
        ((numberp b) (hn-map1 (lambda (x) (* x b)) a))
        ((and (hn-matp a) (hn-matp b))
         (let ((c (hn-mm a b))) (if (and (= (length c) 1) (= (hn-cols c) 1)) (svref (svref c 0) 0) c)))
        ((hn-matp a)                                    ; A · v  -> vector
         (let ((c (hn-mm a (hn-colmat b))))
           (if (= (length c) 1) (svref (svref c 0) 0) (map 'simple-vector (lambda (r) (svref r 0)) c))))
        ((hn-matp b) (hn-mm (hn-colmat a) b))           ; v (n x 1) · B (1 x m)
        (t (unless (= (length a) (length b))            ; v · w = producto escalar (Calcpad)
             (hn-err "producto escalar de vectores de largo ~a y ~a" (length a) (length b)))
           (let ((s 0)) (dotimes (i (length a) s) (setf s (+ s (* (svref a i) (svref b i)))))))))
(defun hn^ (a b)
  (cond ((and (numberp a) (numberp b)) (hn-pow1 a b))
        ((and (hn-matp a) (numberp b) (= b -1)) (hnb-inv a))
        ((and (hn-matp a) (integerp b) (>= b 0))
         (let ((r (hnb-eye (length a)))) (dotimes (i b r) (setf r (hn* r a)))))
        (t (hn-map2 #'hn-pow1 a b))))
(defun hn.* (a b) (hn-map2 #'* a b))
(defun hn./ (a b) (hn-map2 #'hn/1 a b))
(defun hn.^ (a b) (hn-map2 #'hn-pow1 a b))
(defun hn-tr (x)
  (cond ((hn-matp x)
         (let ((m (length x)) (n (hn-cols x)))
           (if (= m 1) (copy-seq (svref x 0))           ; fila 1 x n -> vector
               (let ((c (hn-newmat n m)))
                 (dotimes (i m c) (dotimes (j n) (setf (svref (svref c j) i) (svref (svref x i) j))))))))
        ((hn-vecp x) (vector (copy-seq x)))             ; vector -> fila 1 x n
        (t x)))

;;; ---- rangos, indices y asignacion indexada (A(i,j) = …, K(r,c) = K(r,c) + k) ----
(defun hn-range (a b &optional (s 1))
  (let ((a (hn-num a)) (b (hn-num b)) (s (hn-num s)))
    (when (zerop s) (hn-err "rango con paso 0"))
    (coerce (loop for x = a then (+ x s) while (if (plusp s) (<= x (+ b 1d-10)) (>= x (- b 1d-10)))
                  collect x)
            'simple-vector)))
(defun hn-ix (i n)
  "Indice MATLAB (1-based; numero, rango/vector, o :all) -> lista de indices 0-based."
  (cond ((eq i :all) (loop for k below n collect k))
        ((numberp i) (list (1- (hn-int i))))
        ((vectorp i) (map 'list (lambda (k) (1- (hn-int k))) i))
        ((listp i) (mapcar (lambda (k) (1- (hn-int k))) i))
        (t (hn-err "indice no valido: ~a" i))))
(defun hn-chk (k n what)
  (unless (and (>= k 0) (< k n)) (hn-err "indice ~a fuera de ~a (1..~a)" (1+ k) what n)) k)
(defun hn-ref (a &rest idx)
  (cond ((functionp a) (apply a idx))
        ((hn-matp a)
         (let ((m (length a)) (n (hn-cols a)))
           (case (length idx)
             (2 (let ((i (first idx)) (j (second idx)))
                  (if (and (numberp i) (numberp j))
                      (svref (svref a (hn-chk (1- (hn-int i)) m "las filas"))
                             (hn-chk (1- (hn-int j)) n "las columnas"))
                      (let* ((ri (hn-ix i m)) (cj (hn-ix j n))
                             (r (map 'simple-vector
                                     (lambda (p) (let ((row (svref a (hn-chk p m "las filas"))))
                                                   (map 'simple-vector
                                                        (lambda (q) (svref row (hn-chk q n "las columnas"))) cj)))
                                     ri)))
                        (cond ((numberp j) (map 'simple-vector (lambda (row) (svref row 0)) r)) ; una columna -> vector
                              ((numberp i) (svref r 0))                                          ; una fila -> vector
                              (t r))))))
             (1 (let ((ks (hn-ix (first idx) (* m n))))      ; indice lineal por columnas (MATLAB)
                  (flet ((at (k) (hn-chk k (* m n) "la matriz")
                           (svref (svref a (mod k m)) (floor k m))))
                    (if (numberp (first idx)) (at (first ks)) (map 'simple-vector #'at ks)))))
             (t (hn-err "una matriz se indexa con (i, j)")))))
        ((hn-vecp a)
         (let* ((n (length a))
                (i (cond ((= (length idx) 1) (first idx))
                         ((and (= (length idx) 2) (eql (hn-num (second idx)) 1)) (first idx))
                         ((and (= (length idx) 2) (eql (hn-num (first idx)) 1)) (second idx))
                         (t (hn-err "un vector se indexa con (i)")))))
           (if (numberp i)
               (svref a (hn-chk (1- (hn-int i)) n "el vector"))
               (map 'simple-vector (lambda (k) (svref a (hn-chk k n "el vector"))) (hn-ix i n)))))
        ((numberp a) (if (every (lambda (k) (eql (hn-num k) 1)) idx) a
                         (hn-err "~a es un escalar: no tiene componentes" a)))
        (t (hn-err "no es un vector, ni una matriz, ni una funcion"))))
(defun hn-maxix (i) (cond ((numberp i) (hn-int i)) ((vectorp i) (reduce #'max (map 'list #'hn-int i) :initial-value 0))
                          ((listp i) (reduce #'max (mapcar #'hn-int i) :initial-value 0)) (t 0)))
(defun hn-set (a v &rest idx)
  "A(idx) = v. Modifica A en sitio y lo devuelve; si A no existe o se queda corto, crece
   (como MATLAB). v escalar se reparte por todo el rango; v arreglo va elemento a elemento."
  (case (length idx)
    (1 (let* ((i (first idx))
              (a (cond ((hn-matp a) (hn-err "una matriz se asigna con (i, j)"))
                       ((hn-vecp a) (if (> (hn-maxix i) (length a))
                                        (let ((b (hn-newvec (hn-maxix i) 0))) (replace b a) b) a))
                       (t (hn-newvec (max 1 (hn-maxix i)) 0))))
              (ks (hn-ix i (length a))))
         (if (and (numberp i) (not (simple-vector-p v)))
             (setf (svref a (first ks)) v)
             (let ((vs (if (simple-vector-p v) (coerce (if (hn-matp v) (hn-tr v) v) 'list) nil)))
               (when (and vs (/= (length vs) (length ks)))
                 (hn-err "se asignan ~a valores a ~a posiciones" (length vs) (length ks)))
               (dolist (k ks) (setf (svref a k) (if vs (pop vs) v)))))
         a))
    (2 (let* ((i (first idx)) (j (second idx))
              (m0 (if (hn-matp a) (length a) 0)) (n0 (if (hn-matp a) (hn-cols a) 0))
              (m (max m0 (hn-maxix i))) (n (max n0 (hn-maxix j)))
              (a (if (and (hn-matp a) (= m m0) (= n n0)) a
                     (let ((b (hn-newmat m n 0)))
                       (when (hn-matp a) (dotimes (p m0) (replace (svref b p) (svref a p))))
                       b)))
              (ri (hn-ix i m)) (cj (hn-ix j n)))
         (cond ((not (simple-vector-p v))
                (dolist (p ri) (dolist (q cj) (setf (svref (svref a p) q) v))))
               ((hn-matp v)
                (unless (and (= (length v) (length ri)) (= (hn-cols v) (length cj)))
                  (hn-err "bloque de ~ax~a en un hueco de ~ax~a" (length v) (hn-cols v) (length ri) (length cj)))
                (loop for p in ri for vr across v
                      do (loop for q in cj for x across vr do (setf (svref (svref a p) q) x))))
               (t (unless (= (length v) (* (length ri) (length cj)))
                    (hn-err "se asignan ~a valores a ~a posiciones" (length v) (* (length ri) (length cj))))
                  (let ((k 0)) (dolist (p ri) (dolist (q cj) (setf (svref (svref a p) q) (svref v k)) (incf k))))))
         a))
    (t (hn-err "asignacion con ~a indices" (length idx)))))

;;; ---- [ … ] : concatenacion (escalares, vectores = filas, matrices) ----
(defun hn-block (x)
  "Un elemento de [ ] como lista de filas (listas)."
  (cond ((numberp x) (list (list x)))
        ((hn-matp x) (map 'list (lambda (r) (coerce r 'list)) x))
        ((hn-vecp x) (list (coerce x 'list)))
        (t (list (list x)))))
(defun hn-cat (rows)
  (let ((allnum (every (lambda (r) (every #'numberp r)) rows)))
    (cond ((and allnum (= (length rows) 1)) (coerce (first rows) 'simple-vector))
          ((and allnum (every (lambda (r) (= (length r) 1)) rows)) (map 'simple-vector #'first rows))
          (t (let ((out '()))
               (dolist (r rows)
                 (let* ((blocks (mapcar #'hn-block r))
                        (h (length (first blocks))))
                   (unless (every (lambda (b) (= (length b) h)) blocks)
                     (hn-err "[ , ]: los bloques de una fila tienen distinta altura"))
                   (dotimes (k h)
                     (push (apply #'append (mapcar (lambda (b) (nth k b)) blocks)) out))))
               (setf out (nreverse out))
               (unless (every (lambda (r) (= (length r) (length (first out)))) out)
                 (hn-err "[ ; ]: las filas tienen distinto largo"))
               (if (= (length out) 1)
                   (coerce (first out) 'simple-vector)
                   (map 'simple-vector (lambda (r) (coerce r 'simple-vector)) out)))))))

;;; ---- funciones de biblioteca (nombres de MATLAB y de Calcpad) ----
(defun hn-size2 (r c) (if (or (eql (hn-num r) 1) (eql (hn-num c) 1)) (hn-newvec (max (hn-int r) (hn-int c)) 0)
                          (hn-newmat r c 0)))
(defun hnb-zeros (r &optional c) (if c (hn-size2 r c) (hn-newmat r r 0)))
(defun hnb-ones (r &optional c) (hn-map1 (lambda (x) (1+ x)) (hnb-zeros r c)))
(defun hnb-eye (n) (let ((m (hn-newmat n n 0))) (dotimes (i (hn-int n) m) (setf (svref (svref m i) i) 1))))
(defun hnb-vector (n) (hn-newvec n 0))
(defun hnb-matrix (r c) (hn-newmat r c 0))
(defun hnb-identity (n) (hnb-eye n))
(defun hnb-symmetric (n) (hn-newmat n n 0))
(defun hnb-utriang (n) (hn-newmat n n 0))
(defun hnb-ltriang (n) (hn-newmat n n 0))
(defun hnb-size (a &optional k)
  (let ((r (hn-rows a)) (c (hn-cols a)))
    (if k (if (eql (hn-num k) 1) r c) (vector r c))))
(defun hnb-n_rows (a) (hn-rows a))
(defun hnb-n_cols (a) (hn-cols a))
(defun hnb-length (a) (if (numberp a) 1 (max (hn-rows a) (hn-cols a))))
(defun hnb-len (a) (hnb-length a))
(defun hnb-numel (a) (if (numberp a) 1 (* (hn-rows a) (hn-cols a))))
(defun hnb-transpose (a) (hn-tr a))
(defun hnb-transp (a) (hn-tr a))
(defun hn-flat (a) (cond ((hn-matp a) (loop for r across a append (coerce r 'list)))
                         ((hn-vecp a) (coerce a 'list)) (t (list a))))
(defun hnb-sum (a)
  (cond ((hn-matp a) (let ((s (hn-newvec (hn-cols a) 0)))       ; por columnas (MATLAB)
                       (loop for r across a do (dotimes (j (length r)) (incf (svref s j) (svref r j)))) s))
        (t (reduce #'+ (hn-flat a) :initial-value 0))))
(defun hnb-max (a &optional (b nil bp)) (if bp (hn-map2 #'max a b) (reduce #'max (hn-flat a))))
(defun hnb-min (a &optional (b nil bp)) (if bp (hn-map2 #'min a b) (reduce #'min (hn-flat a))))
(defmacro hn-defmath (name fn)
  `(defun ,name (x) (hn-map1 (lambda (v) (let ((r (funcall ,fn (hn-d v)))) (if (and (complexp r) (zerop (imagpart r))) (realpart r) r))) x)))
(hn-defmath hnb-sqrt #'sqrt) (hn-defmath hnb-exp #'exp) (hn-defmath hnb-ln #'log) (hn-defmath hnb-log #'log)
(hn-defmath hnb-sin #'sin) (hn-defmath hnb-cos #'cos) (hn-defmath hnb-tan #'tan)
(hn-defmath hnb-asin #'asin) (hn-defmath hnb-acos #'acos) (hn-defmath hnb-atan #'atan)
(hn-defmath hnb-sinh #'sinh) (hn-defmath hnb-cosh #'cosh) (hn-defmath hnb-tanh #'tanh)
(defun hnb-log10 (x) (hn-map1 (lambda (v) (log (hn-d v) 10d0)) x))
(defun hnb-atan2 (y x) (hn-map2 (lambda (a b) (atan (hn-d a) (hn-d b))) y x))
(defun hnb-abs (x) (hn-map1 #'abs x))
(defun hn-round1 (v) (let ((r (if (minusp v) (- (floor (+ (- v) 1/2))) (floor (+ v 1/2))))) r))
(defun hnb-round (x &optional n)                 ; redondeo "de escuela": 0.5 se aleja del cero
  (if n (let ((f (expt 10 (hn-int n)))) (hn-map1 (lambda (v) (hn/1 (hn-round1 (* (rational v) f)) f)) x))
        (hn-map1 (lambda (v) (hn-round1 (rational v))) x)))
(defun hnb-floor (x) (hn-map1 (lambda (v) (values (floor v))) x))
(defun hnb-ceil (x) (hn-map1 (lambda (v) (values (ceiling v))) x))
(defun hnb-ceiling (x) (hnb-ceil x))
(defun hnb-fix (x) (hn-map1 (lambda (v) (values (truncate v))) x))
(defun hnb-trunc (x) (hnb-fix x))
(defun hnb-sign (x) (hn-map1 #'signum x))
(defun hnb-mod (a b) (hn-map2 (lambda (x y) (hn-num (mod x y))) a b))
(defun hnb-rem (a b) (hn-map2 (lambda (x y) (hn-num (rem x y))) a b))
(defun hnb-dot (a b) (hn* (coerce (hn-flat a) 'simple-vector) (coerce (hn-flat b) 'simple-vector)))
(defun hnb-norm (a) (sqrt (hn-d (reduce #'+ (mapcar (lambda (x) (* x x)) (hn-flat a)) :initial-value 0))))
(defun hnb-trace (a) (let ((s 0)) (dotimes (i (min (hn-rows a) (hn-cols a)) s) (incf s (svref (svref a i) i)))))
(defun hnb-linspace (a b n)
  (let ((n (hn-int n)))
    (coerce (loop for k below n collect (hn-num (+ a (* (- b a) (if (= n 1) 0 (/ k (1- n))))))) 'simple-vector)))
(defun hnb-row (m i) (copy-seq (svref m (hn-chk (1- (hn-int i)) (length m) "las filas"))))
(defun hnb-col (m j) (hn-ref m :all j))
(defun hnb-submatrix (m i1 i2 j1 j2) (hn-ref m (hn-range i1 i2) (hn-range j1 j2)))
(defun hnb-slice (v i1 i2) (hn-ref v (hn-range i1 i2)))
(defun hnb-extract (v idx) (hn-ref v idx))
(defun hnb-take (n &rest xs) (nth (1- (hn-int n)) xs))
(defun hnb-add (a b i &optional j)
  "Calcpad add(A; B; i; j): suma A dentro de B a partir de (i, j). B cambia y se devuelve."
  (if j
      (let ((i0 (1- (hn-int i))) (j0 (1- (hn-int j))) (am (if (hn-vecp a) (hn-colmat a) a)))
        (dotimes (p (length am) b)
          (let ((ar (svref am p)) (br (svref b (hn-chk (+ i0 p) (length b) "las filas"))))
            (dotimes (q (length ar))
              (let ((k (hn-chk (+ j0 q) (length br) "las columnas")))
                (setf (svref br k) (+ (svref br k) (svref ar q))))))))
      (let ((i0 (1- (hn-int i))))
        (dotimes (p (length a) b) (incf (svref b (hn-chk (+ i0 p) (length b) "el vector")) (svref a p))))))
(defun hnb-fill (a v) (hn-map1 (lambda (x) (declare (ignore x)) v) a))
(defun hnb-disp (x) (hn-print x) x)

;;; ---- sistemas lineales, inversa, determinante (double; MKL si esta, si no Gauss nativo) ----
(defun hn->d (m)
  (let* ((r (length m)) (c (hn-cols m)) (a (make-array (* r c) :element-type 'double-float)) (k 0))
    (loop for row across m do (loop for x across row do (setf (aref a k) (float x 1d0)) (incf k)))
    a))
(defun hnb-solve (a b)
  "x de A·x = b (b vector o matriz). Gauss con pivoteo parcial en doble precision."
  (unless (and (hn-matp a) (= (length a) (hn-cols a))) (hn-err "A\\b: A tiene que ser cuadrada"))
  (let* ((n (length a)) (vecb (not (hn-matp b)))
         (bm (if vecb (hn-colmat b) b)) (nrhs (hn-cols bm)))
    (unless (= (length bm) n) (hn-err "A\\b: A es ~ax~a y b tiene ~a filas" n n (length bm)))
    (let ((x (hk-dgesv (hn->d a) (hn->d bm) n nrhs)))
      (unless x (hn-err "A\\b: la matriz es singular (¿faltan apoyos?)"))
      (if vecb
          (let ((v (hn-newvec n 0))) (dotimes (i n v) (setf (svref v i) (aref x i))))
          (let ((m (hn-newmat n nrhs 0)))
            (dotimes (i n m) (dotimes (j nrhs) (setf (svref (svref m i) j) (aref x (+ (* i nrhs) j))))))))))
(defun hn\\ (a b) (hnb-solve a b))
(defun hnb-lsolve (a b) (hnb-solve a b))
;; clsolve de Calcpad = Cholesky (A = L·Lᵀ, A simetrica y definida positiva), por filas y
;; saltando los ceros del principio de cada fila (el "perfil" de la matriz de rigidez), como
;; HpSymmetricMatrix.GetCholesky + FwdAndBackSubst de Calcpad.Core.
(defun hn-cholesky-solve (n a b)
  (declare (type (simple-array double-float (*)) a b) (type fixnum n) (optimize (speed 3) (safety 0)))
  (let ((l (make-array (* n n) :element-type 'double-float :initial-element 0d0))
        (st (make-array n :element-type 'fixnum :initial-element 0)))
    (dotimes (i n)                                   ; primera columna no nula de cada fila
      (let ((k 0)) (declare (type fixnum k))
        (loop while (and (< k i) (zerop (aref a (+ (* i n) k)))) do (incf k))
        (setf (aref st i) k)))
    (dotimes (i n)
      (loop for j fixnum from (aref st i) to i
            do (let ((s (aref a (+ (* i n) j))) (k0 (max (aref st i) (aref st j))))
                 (declare (type double-float s) (type fixnum k0))
                 (loop for k fixnum from k0 below j
                       do (decf s (* (aref l (+ (* i n) k)) (aref l (+ (* j n) k)))))
                 (if (= i j)
                     (progn (when (<= s 0d0) (return-from hn-cholesky-solve nil))
                            (setf (aref l (+ (* i n) i)) (sqrt s)))
                     (setf (aref l (+ (* i n) j)) (/ s (aref l (+ (* j n) j))))))))
    (let ((x (make-array n :element-type 'double-float :initial-element 0d0)))
      (dotimes (i n)                                 ; L·y = b
        (let ((s (aref b i))) (declare (type double-float s))
          (loop for j fixnum from (aref st i) below i do (decf s (* (aref l (+ (* i n) j)) (aref x j))))
          (setf (aref x i) (/ s (aref l (+ (* i n) i))))))
      (loop for i fixnum from (1- n) downto 0        ; Lᵀ·x = y
            do (let ((s (aref x i))) (declare (type double-float s))
                 (loop for j fixnum from (1+ i) below n
                       do (when (<= (aref st j) i) (decf s (* (aref l (+ (* j n) i)) (aref x j)))))
                 (setf (aref x i) (/ s (aref l (+ (* i n) i))))))
      x)))
(defun hnb-clsolve (a b)
  "x de A·x = b por Cholesky (clsolve de Calcpad). A simetrica y definida positiva."
  (unless (and (hn-matp a) (= (length a) (hn-cols a))) (hn-err "clsolve: A tiene que ser cuadrada"))
  (when (hn-matp b) (hn-err "clsolve: b tiene que ser un vector"))
  (let* ((n (length a)) (x (hn-cholesky-solve n (hn->d a) (hn->d (hn-colmat b)))))
    (unless x (hn-err "clsolve: la matriz no es definida positiva (¿faltan apoyos?)"))
    (let ((v (hn-newvec n 0))) (dotimes (i n v) (setf (svref v i) (aref x i))))))
(defun hnb-slsolve (a b) (hnb-solve a b))
(defun hnb-mldivide (a b) (hnb-solve a b))
(defun hnb-inv (a) (hnb-solve a (hnb-eye (length a))))
(defun hnb-inverse (a) (hnb-inv a))
(defun hnb-det (a)
  (let* ((n (length a)) (d (hn->d a)) (det 1d0))
    (dotimes (c n det)
      (let ((p c))
        (loop for r from (1+ c) below n when (> (abs (aref d (+ (* r n) c))) (abs (aref d (+ (* p n) c)))) do (setf p r))
        (when (zerop (aref d (+ (* p n) c))) (return 0d0))
        (unless (= p c) (setf det (- det)) (dotimes (j n) (rotatef (aref d (+ (* c n) j)) (aref d (+ (* p n) j)))))
        (setf det (* det (aref d (+ (* c n) c))))
        (loop for r from (1+ c) below n
              do (let ((f (/ (aref d (+ (* r n) c)) (aref d (+ (* c n) c)))))
                   (loop for j from c below n do (decf (aref d (+ (* r n) j)) (* f (aref d (+ (* c n) j)))))))))))

;;; ---- integrales numericas: Gauss-Legendre adaptativa (la integral puede ser una MATRIZ) ----
(defvar *hn-gl* (make-hash-table))
(defun hn-gl (n)
  "Nodos y pesos de Gauss-Legendre en [-1, 1] (Newton sobre P_n; Numerical Recipes gauleg)."
  (or (gethash n *hn-gl*)
      (setf (gethash n *hn-gl*)
            (let ((xs (make-array n)) (ws (make-array n)) (m (floor (1+ n) 2)))
              (dotimes (i m (cons xs ws))
                (let ((z (cos (* pi (/ (- (1+ i) 0.25d0) (+ n 0.5d0))))) (pp 0d0))
                  (loop repeat 100
                        do (let ((p1 1d0) (p2 0d0))
                             (loop for j from 1 to n
                                   do (let ((p3 p2)) (setf p2 p1 p1 (/ (- (* (- (* 2 j) 1) z p2) (* (1- j) p3)) j))))
                             (setf pp (/ (* n (- (* z p1) p2)) (- (* z z) 1)))
                             (let ((z1 z)) (setf z (- z1 (/ p1 pp))) (when (< (abs (- z z1)) 1d-15) (return)))))
                  (setf (svref xs i) (- z) (svref xs (- n 1 i)) z
                        (svref ws i) (/ 2 (* (- 1 (* z z)) pp pp)) (svref ws (- n 1 i)) (svref ws i))))))))
(defun hn-glint (f a b &optional (n 8))
  (let* ((g (hn-gl n)) (h (/ (- b a) 2)) (c (/ (+ a b) 2)) (s 0))
    (dotimes (i n (hn* h s))
      (setf s (hn+ s (hn* (svref (cdr g) i) (funcall f (+ c (* h (svref (car g) i))))))))))
(defun hn-absmax (x) (reduce #'max (mapcar #'abs (hn-flat x)) :initial-value 0))
(defun hn-adapt (f a b whole tol depth)
  (let* ((m (/ (+ a b) 2)) (l (hn-glint f a m)) (r (hn-glint f m b)) (both (hn+ l r)))
    (if (or (<= depth 0) (<= (hn-absmax (hn- both whole)) (max tol (* 1d-12 (hn-absmax both)))))
        both
        (hn+ (hn-adapt f a m l (/ tol 2) (1- depth)) (hn-adapt f m b r (/ tol 2) (1- depth))))))
(defun hnb-integral (f a b)
  "∫ f(x) dx de a a b. Gauss-Legendre de 8 puntos, partiendo el tramo hasta que dos
   estimaciones coinciden (exacta para polinomios de grado ≤ 15)."
  (let ((a (hn-d a)) (b (hn-d b))) (hn-adapt f a b (hn-glint f a b) 1d-12 30)))
(defun hnb-integral2 (f xa xb ya yb)
  "∬ f(x, y) dy dx sobre [xa, xb] x [ya, yb] (integral de la integral)."
  (hnb-integral (lambda (x) (hnb-integral (lambda (y) (funcall f x y)) ya yb)) xa xb))

;;; ---- spline de Calcpad (Matrix.Spline / Vector.Spline, sacado de Calcpad.Core) ----
(defun hn-spl (y0 y1 ym yp t0 first last)
  "Tramo cubico de Calcpad entre y0 e y1 con pendientes limitadas (ym = anterior, yp = siguiente)."
  (let* ((dy (- y1 y0)) (a dy) (b dy) (sg (signum dy)))
    (when ym (setf a (* (- y1 ym) (if (= (signum (- y0 ym)) sg) 0.5d0 0.25d0))))
    (when yp (setf b (* (- yp y0) (if (= (signum (- yp y1)) sg) 0.5d0 0.25d0))))
    (when first (setf a (+ a (/ (- a b) 2))))
    (when last (setf b (+ b (/ (- b a) 2))))
    (+ y0 (* (+ (* (- y1 y0) (- 3 (* 2 t0)) t0) (* (- (* (+ a b) t0) a) (- t0 1))) t0))))
(defun hn-spline-vec (get n d)
  "GET(k) da el valor k (0-based) de una serie de N; D = posicion 1-based fraccionaria."
  (when (or (< d (- 1 1d-12)) (> d (* n (+ 1 1d-12)))) (hn-err "spline: la posicion ~a cae fuera de 1..~a" d n))
  (let ((i (1- (floor d))))
    (if (or (= (+ i 1) d) (>= d n)) (funcall get (min i (1- n)))
        (hn-spl (funcall get i) (funcall get (1+ i))
                (and (> i 0) (funcall get (1- i))) (and (< i (- n 2)) (funcall get (+ i 2)))
                (- d i 1) (= i 0) (= i (- n 2))))))
(defun hnb-spline (u v &optional m)
  "spline(u; v; M): M interpolada en la fila u y la columna v (1-based, fraccionarias), con el
   spline de Calcpad. spline(u; v) con v vector = interpolacion 1-D."
  (if (null m)
      (let ((vec v) (d (hn-d u))) (hn-spline-vec (lambda (k) (svref vec k)) (length vec) d))
      (let* ((nr (length m)) (nc (hn-cols m)) (du (hn-d u)) (dv (hn-d v)))
        (hn-spline-vec (lambda (r) (hn-spline-vec (lambda (c) (svref (svref m r) c)) nc dv)) nr du))))

;;; ---- salida hacia la hoja: \x1d linea \x1f nombre \x1f valor ----
(defun hn-fmt (x)
  (cond ((integerp x) (format nil "~d" x))
        ((rationalp x) (fmt-float (float x 1d0)))
        ((floatp x) (if (or #+sbcl (sb-ext:float-nan-p x) #-sbcl (ext:float-nan-p x)
                            #+sbcl (sb-ext:float-infinity-p x) #-sbcl (ext:float-infinity-p x)) "0" (fmt-float x)))
        ((complexp x) (format nil "~a" x))
        (t nil)))
(defun hn-lit (x)
  (cond ((numberp x) (hn-fmt x))
        ((hn-matp x) (with-output-to-string (s)
                       (write-string "(vector" s)
                       (loop for r across x do (write-string " (vector" s)
                                               (loop for y across r do (write-char #\Space s) (write-string (or (hn-fmt y) "0") s))
                                               (write-char #\) s))
                       (write-char #\) s)))
        ((hn-vecp x) (with-output-to-string (s)
                       (write-string "(vector" s)
                       (loop for y across x do (write-char #\Space s) (write-string (or (hn-fmt y) "0") s))
                       (write-char #\) s)))
        (t nil)))
(defun hn-emit (line tag text)
  (format t "~c~a~c~a~c~a~%" (code-char 29) line (code-char 31) tag (code-char 31) text))
(defun hn-out (line name x) (let ((s (hn-lit x))) (when s (hn-emit line name s))) x)
(defun hn-print (x) (hn-emit *hn-line* ">" (or (hn-lit x) (format nil "~a" x))))
(defun hn-fail (line c)
  (hn-emit line "!" (substitute #\Space #\Newline (format nil "~a" c))))
(defun hn-grid (line f xa xb ya yb nn)
  "Rejilla (nn+1) x (nn+1) de f(x, y) para un #map de la hoja numerica: z[i][j], i por x."
  (let ((xa (hn-d xa)) (xb (hn-d xb)) (ya (hn-d ya)) (yb (hn-d yb)))
    (hn-emit line "#grid"
             (with-output-to-string (s)
               (format s "~a ~a ~a ~a ~d" (fmt-float xa) (fmt-float xb) (fmt-float ya) (fmt-float yb) nn)
               (dotimes (i (1+ nn))
                 (dotimes (j (1+ nn))
                   (let ((z (handler-case (funcall f (+ xa (* (- xb xa) (/ i nn))) (+ ya (* (- yb ya) (/ j nn))))
                              (error () 0))))
                     (format s " ~a" (if (numberp z) (or (hn-fmt (hn-d (if (complexp z) (realpart z) z))) "0") "0")))))))))

;;;; ===================== AUTOLISP: DIBUJO CON LISTAS DXF (24-sep-2026) =====================
;;;; Pegado aquí por la misma razón que UNIDADES: engine.lisp es lo ÚNICO que se hornea en el
;;;; core de SBCL y se compila dentro de hlisp.wasm (web).
;;;;
;;;; La idea (Jorge): EL CÓDIGO ES LA LISTA DE DATOS. Una entidad es una lista de asociación
;;;; DXF normal de LISP, ((0 . "LINE") (8 . "0") (10 0.0 0.0) (11 3.0 4.0)): se arma con
;;;; list / cons / mapcar, se guarda en variables, se transforma con funciones, y recién
;;;; `entmake` la pone en el dibujo. `ssget` / `entget` / `assoc` la leen de vuelta y con eso
;;;; se sigue calculando (longitudes, áreas, pendientes).
;;;;
;;;; Semántica de AutoCAD (referencia AutoLISP y DXF de Autodesk, ver BITACORA_autolisp_dibujo.md):
;;;;   · entmake devuelve la lista si crea la entidad y nil si falta un dato obligatorio;
;;;;     lo opcional (capa, color) toma el valor por defecto; el código 100 se ignora.
;;;;   · en las LISTAS los ángulos (50, 51) van en RADIANES (en el fichero .dxf, en grados).
;;;;   · entget devuelve (-1 . <Entity name>) (0 . tipo) (5 . handle) (8 . capa) … con los
;;;;     puntos en 3D (x y z), salvo los vértices de LWPOLYLINE, que son 2D como en AutoCAD.
;;;;   · ssget "_X" con filtro de pares (comodines de wcmatch, -4 lógicos y relacionales);
;;;;     sin nada que casar devuelve nil (y sslength de nil es un error, como en AutoCAD).
;;;; El dibujo lo pinta la app (LispAutoLisp.cs) con lo que imprime hk-al-volcar al final.

(defvar *hk-al-base* #x1F0)
(defvar *hk-al-db* (make-array 16 :adjustable t :fill-pointer 0))
(defvar *hk-al-capas* nil)
(defvar *hk-al-nss* 0)
(defvar *hk-al-sysvars* nil)
(defvar *hk-al-guardar* nil)
(defparameter *hk-al-tipos*
  '("POINT" "LINE" "CIRCLE" "ARC" "LWPOLYLINE" "TEXT" "MTEXT" "SOLID" "HATCH" "DIMENSION"
    "3DFACE" "POLYLINE" "VERTEX" "SEQEND"))
(defvar *hk-al-pend* nil)   ; POLYLINE abierta: (cabecera vértice…) hasta el SEQEND
(defparameter +hk-al-pi+ (float pi 1d0))

(defstruct (hk-ename (:constructor hk-mk-ename (id))) id)
(defmethod print-object ((e hk-ename) s) (format s "<Entity name: ~(~x~)>" (hk-ename-id e)))
(defstruct (hk-ent (:constructor hk-mk-ent (ename datos))) ename datos (borrada nil) (sub nil))
(defstruct (hk-ssel (:constructor hk-mk-ssel (id items))) id items)
(defmethod print-object ((x hk-ssel) s) (format s "<Selection set: ~a>" (hk-ssel-id x)))

(defun hk-al-sysvars-defecto ()
  (list (cons "CLAYER" "0") (cons "LUPREC" 4) (cons "LUNITS" 2) (cons "AUNITS" 0) (cons "AUPREC" 0)
        (cons "TEXTSIZE" 2.5d0) (cons "DIMSCALE" 0d0) (cons "DIMTXT" 2.5d0) (cons "DIMASZ" 2.5d0)
        (cons "DIMDEC" 2) (cons "DIMEXO" 0.625d0) (cons "DIMEXE" 1.25d0) (cons "DIMGAP" 0.625d0)
        (cons "HKVERT" 1d0) (cons "HKVISTA" -1) (cons "HKAZ" -60d0) (cons "HKEL" 25d0)))

(defun hk-al-capa-lista (nombre color tipo grosor)
  (list (cons 0 "LAYER") (cons 2 nombre) (cons 70 0) (cons 62 color) (cons 6 tipo) (cons 370 grosor)))

(defun hk-al-nuevo ()
  "Dibujo nuevo (como abrir un DWG vacío): sin entidades, capa 0, variables de sistema de fábrica."
  (setf *hk-al-db* (make-array 16 :adjustable t :fill-pointer 0)
        *hk-al-capas* (list (hk-al-capa-lista "0" 7 "CONTINUOUS" -3))
        *hk-al-nss* 0 *hk-al-pend* nil
        *hk-al-sysvars* (hk-al-sysvars-defecto)
        *hk-al-guardar* nil)
  t)
(hk-al-nuevo)

;; ---------- variables de sistema ----------
(defun getvar (nombre)
  (cdr (assoc (string-upcase (string nombre)) *hk-al-sysvars* :test #'string=)))
(defun setvar (nombre valor)
  (let* ((k (string-upcase (string nombre))) (a (assoc k *hk-al-sysvars* :test #'string=)))
    (when (string= k "CLAYER") (hk-al-asegura-capa valor))
    (if a (setf (cdr a) valor) (push (cons k valor) *hk-al-sysvars*))
    valor))

;; ---------- números y puntos ----------
(defun hk-al-d (x) (float x 1d0))
(defun hk-al-ptp (v)
  (let ((n (and (consp v) (ignore-errors (list-length v)))))
    (and n (<= 2 n 3) (every #'realp v))))
(defun hk-al-pt (v dim)
  (let ((x (hk-al-d (first v))) (y (hk-al-d (second v))) (z (if (third v) (hk-al-d (third v)) 0d0)))
    (if (= dim 2) (list x y) (list x y z))))

;; ---------- capas (tabla LAYER) ----------
(defun hk-al-busca-capa (nombre)
  (find-if (lambda (c) (string-equal (cdr (assoc 2 c)) nombre)) *hk-al-capas*))
(defun hk-al-asegura-capa (nombre)
  (unless (hk-al-busca-capa nombre)
    (setf *hk-al-capas* (append *hk-al-capas* (list (hk-al-capa-lista nombre 7 "CONTINUOUS" -3)))))
  nombre)
(defun hk-al-capa-desde-lista (lst)
  (let ((nom (cdr (assoc 2 lst))))
    (when (stringp nom)
      (let ((nueva (hk-al-capa-lista nom
                                     (let ((c (cdr (assoc 62 lst)))) (if (integerp c) c 7))
                                     (let ((c (cdr (assoc 6 lst)))) (if (stringp c) (string-upcase c) "CONTINUOUS"))
                                     (let ((c (cdr (assoc 370 lst)))) (if (integerp c) c -3)))))
        (setf *hk-al-capas*
              (if (hk-al-busca-capa nom)
                  (mapcar (lambda (c) (if (string-equal (cdr (assoc 2 c)) nom) nueva c)) *hk-al-capas*)
                  (append *hk-al-capas* (list nueva))))
        nueva))))
(defun tblsearch (tabla nombre &optional sig)
  (declare (ignore sig))
  (when (string-equal tabla "LAYER") (copy-tree (hk-al-busca-capa nombre))))

;; ---------- medida de una cota (código 42) ----------
(defun hk-al-medida-cota (geo)
  (case (logand (or (cdr (assoc 70 geo)) 0) 7)
    ((3 4) (let ((a (cdr (assoc 10 geo))) (b (cdr (assoc 15 geo))))   ; radio y diámetro: de 10 a 15
             (return-from hk-al-medida-cota
               (sqrt (+ (expt (- (first b) (first a)) 2) (expt (- (second b) (second a)) 2))))))
    (5 (let* ((v (cdr (assoc 15 geo))) (d (cdr (assoc 10 geo)))      ; angular: el sector de 13 y 14 donde cae 10
              (an (lambda (p) (mod (atan (- (second p) (second v)) (- (first p) (first v))) (* 2 +hk-al-pi+))))
              (a1 (funcall an (cdr (assoc 13 geo)))) (a2 (funcall an (cdr (assoc 14 geo)))) (ad (funcall an d))
              (dos-pi (* 2 +hk-al-pi+)))
         (return-from hk-al-medida-cota
           (if (<= (mod (- ad a1) dos-pi) (mod (- a2 a1) dos-pi)) (mod (- a2 a1) dos-pi) (mod (- a1 a2) dos-pi))))))
  (let* ((p1 (cdr (assoc 13 geo))) (p2 (cdr (assoc 14 geo)))
         (dx (- (first p2) (first p1))) (dy (- (second p2) (second p1)))
         (tipo (logand (or (cdr (assoc 70 geo)) 0) 7)))
    (if (= tipo 1)
        (sqrt (+ (* dx dx) (* dy dy)))
        (let ((a (or (cdr (assoc 50 geo)) 0d0)))
          (abs (+ (* dx (cos a)) (* dy (sin a))))))))

;; ---------- normalizar una lista DXF (lo que hace entmake por dentro) ----------
(defun hk-al-norm (lst hnd &optional capa-previa)
  "Lista DXF del usuario → datos de la entidad (sin -1), o NIL si no es válida."
  (block norm
    (unless (and (listp lst) (every #'consp lst)) (return-from norm nil))
    (let ((tp (cdr (assoc 0 lst))))
      (unless (stringp tp) (return-from norm nil))
      (setf tp (string-upcase tp))
      (unless (member tp *hk-al-tipos* :test #'string=) (return-from norm nil))
      (let* ((lw (string= tp "LWPOLYLINE"))
             (capa (let ((c (cdr (assoc 8 lst)))) (if (stringp c) c (or capa-previa (getvar "CLAYER")))))
             (props nil) (geo nil))
        (dolist (p lst)
          (let ((c (car p)) (v (cdr p)))
            (cond ((not (integerp c)) (return-from norm nil))
                  ((member c '(-1 0 5 8 100 102 330 360 410 67)) nil)          ; se regeneran / subclase
                  ((member c '(62 6 370 48 440 420))
                   (push (cons c (if (and (= c 6) (stringp v)) (string-upcase v) v)) props))
                  ((or (<= 10 c 18) (= c 210))
                   (unless (hk-al-ptp v) (return-from norm nil))
                   (unless (= c 210) (push (cons c (hk-al-pt v (if lw 2 3))) geo)))
                  ((or (<= 40 c 59) (<= 140 c 149))
                   (unless (realp v) (return-from norm nil))
                   (push (cons c (hk-al-d v)) geo))
                  ((or (<= 60 c 99) (<= 170 c 179) (<= 270 c 289))
                   (unless (integerp v) (return-from norm nil))
                   (push p geo))
                  ((<= 1 c 9) (unless (stringp v) (return-from norm nil)) (push p geo))
                  (t (push p geo)))))
        (setf props (nreverse props) geo (nreverse geo))
        (flet ((tiene (k) (assoc k geo))
               (falta (&rest ks) (some (lambda (k) (null (assoc k geo))) ks)))
          (cond
            ((string= tp "POINT") (when (falta 10) (return-from norm nil)))
            ((string= tp "LINE") (when (falta 10 11) (return-from norm nil)))
            ((string= tp "CIRCLE") (when (falta 10 40) (return-from norm nil)))
            ((string= tp "ARC") (when (falta 10 40 50 51) (return-from norm nil)))
            ((string= tp "SOLID")
             (when (falta 10 11 12) (return-from norm nil))
             (unless (tiene 13) (setf geo (append geo (list (cons 13 (cdr (tiene 12))))))))
            ((string= tp "TEXT")
             (when (falta 10 1) (return-from norm nil))
             (unless (tiene 40) (setf geo (cons (cons 40 (hk-al-d (getvar "TEXTSIZE"))) geo))))
            ((string= tp "MTEXT")
             (when (falta 10 1) (return-from norm nil))
             (unless (tiene 40) (setf geo (cons (cons 40 (hk-al-d (getvar "TEXTSIZE"))) geo)))
             (unless (tiene 71) (setf geo (append geo (list (cons 71 1))))))
            ((string= tp "LWPOLYLINE")
             (let ((n (count 10 geo :key #'car)))
               (when (< n 1) (return-from norm nil))
               (setf geo (remove 90 geo :key #'car))
               (unless (tiene 70) (push (cons 70 0) geo))
               (push (cons 90 n) geo)))
            ((string= tp "HATCH")
             (when (< (count 10 geo :key #'car) 3) (return-from norm nil))
             (unless (tiene 2) (setf geo (append (list (cons 2 "SOLID") (cons 70 1)) geo))))
            ((string= tp "3DFACE")
             (when (falta 10 11 12) (return-from norm nil))
             (unless (tiene 13) (setf geo (append geo (list (cons 13 (cdr (tiene 12))))))))
            ((string= tp "POLYLINE")
             (unless (tiene 10) (setf geo (cons (cons 10 (list 0d0 0d0 0d0)) geo)))
             (unless (tiene 70) (setf geo (append geo (list (cons 70 0))))))
            ((string= tp "VERTEX") (when (falta 10) (return-from norm nil)))
            ((and (string= tp "DIMENSION") (member (logand (or (cdr (tiene 70)) 0) 7) '(3 4 5)))
             ;; radio (4) y diámetro (3): 10 y 15; angular de 3 puntos (5): 10 (arco), 13, 14 y 15 (vértice).
             ;; 42 = la medida, como la guarda AutoCAD (en la angular, en radianes).
             (let ((k (logand (cdr (tiene 70)) 7)))
               (when (or (falta 10 15) (and (= k 5) (falta 13 14))) (return-from norm nil))
               (unless (tiene 1) (setf geo (append geo (list (cons 1 "")))))
               (setf geo (remove 42 geo :key #'car))
               (setf geo (append geo (list (cons 42 (hk-al-medida-cota geo)))))))
            ((string= tp "DIMENSION")
             (when (falta 13 14) (return-from norm nil))
             (unless (tiene 10) (setf geo (cons (cons 10 (cdr (tiene 14))) geo)))
             (unless (tiene 70) (setf geo (append geo (list (cons 70 (if (tiene 50) 32 33))))))
             (unless (tiene 1) (setf geo (append geo (list (cons 1 "")))))
             (setf geo (remove 42 geo :key #'car))
             (setf geo (append geo (list (cons 42 (hk-al-medida-cota geo))))))))
        (hk-al-asegura-capa capa)
        (append (list (cons 0 tp) (cons 5 (format nil "~X" hnd)) (cons 8 capa)) props geo)))))

;; ---------- base de dibujo ----------
(defun hk-al-ent (e)
  (when (hk-ename-p e)
    (let ((i (- (hk-ename-id e) *hk-al-base*)))
      (when (and (>= i 0) (< i (fill-pointer *hk-al-db*))) (aref *hk-al-db* i)))))
(defun hk-al-viva (e) (let ((x (hk-al-ent e))) (and x (not (hk-ent-borrada x)) x)))

(defun hk-al-meter (d sub)
  (let* ((id (+ *hk-al-base* (fill-pointer *hk-al-db*))) (e (hk-mk-ename id)))
    (setf (cdr (assoc 5 d)) (format nil "~X" id))
    (let ((x (hk-mk-ent e d))) (setf (hk-ent-sub x) sub) (vector-push-extend x *hk-al-db*))
    e))
(defun hk-al-crear (lst)
  "Como entmake de AutoCAD. POLYLINE es COMPLEJA: la cabecera y cada VERTEX quedan pendientes
y entran al dibujo recién con el SEQEND (cabecera, vértices y SEQEND como subentidades)."
  (let ((tp (and (listp lst) (every #'consp lst) (cdr (assoc 0 lst)))))
    (cond
      ((and (stringp tp) (string-equal tp "LAYER")) (and (hk-al-capa-desde-lista lst) :capa))
      ((and (stringp tp) (string-equal tp "POLYLINE"))
       (let ((d (hk-al-norm lst 0))) (when d (setf *hk-al-pend* (list d)) :pend)))
      ((and (stringp tp) (string-equal tp "VERTEX"))
       (when *hk-al-pend*
         (let ((d (hk-al-norm lst 0 (cdr (assoc 8 (car *hk-al-pend*))))))
           (when d (setf *hk-al-pend* (append *hk-al-pend* (list d))) :pend))))
      ((and (stringp tp) (string-equal tp "SEQEND"))
       (when *hk-al-pend*
         (let* ((todo *hk-al-pend*) (cab (hk-al-meter (car todo) nil)))
           (dolist (v (cdr todo)) (hk-al-meter v t))
           (hk-al-meter (hk-al-norm (list (cons 0 "SEQEND") (cons 8 (cdr (assoc 8 (car todo))))) 0) t)
           (setf *hk-al-pend* nil)
           cab)))
      (t (let ((d (hk-al-norm lst 0))) (when d (hk-al-meter d nil)))))))

(defun entmake (&optional lst)
  "Crea la entidad descrita por la lista DXF. Devuelve la lista, o NIL si no es válida."
  (and (hk-al-crear lst) lst))
(defun entmakex (&optional lst)
  "Como entmake, pero devuelve el nombre de la entidad (ename)."
  (let ((r (hk-al-crear lst))) (if (member r '(:capa :pend)) t r)))
(defun entget (e &optional apps)
  (declare (ignore apps))
  (let ((x (hk-al-viva e))) (when x (cons (cons -1 e) (copy-tree (hk-ent-datos x))))))
(defun entmod (lst)
  "Cambia la entidad (-1 . e) por los datos de LST (mismo tipo). Devuelve LST o NIL."
  (let* ((e (and (listp lst) (cdr (assoc -1 lst)))) (x (hk-al-viva e)))
    (when x
      (let* ((viejo (hk-ent-datos x)) (tp (cdr (assoc 0 viejo)))
             (nt (cdr (assoc 0 lst))))
        (when (and nt (not (string-equal nt tp))) (return-from entmod nil))
        (let ((d (hk-al-norm (cons (cons 0 tp) (remove 0 lst :key #'car))
                             (hk-ename-id e) (cdr (assoc 8 viejo)))))
          (when d (setf (hk-ent-datos x) d) lst))))))
(defun entupd (e) (and (hk-al-viva e) e))
(defun hk-al-subs (e)
  "Las subentidades (VERTEX…, SEQEND) que siguen a la cabecera E."
  (let ((i (1+ (- (hk-ename-id e) *hk-al-base*))) (r nil))
    (loop while (and (< i (fill-pointer *hk-al-db*)) (hk-ent-sub (aref *hk-al-db* i)))
          do (push (aref *hk-al-db* i) r) (incf i))
    (nreverse r)))
(defun entdel (e)
  "Borra la entidad; si ya estaba borrada la recupera (como AutoCAD). Devuelve el ename."
  (let ((x (hk-al-ent e)))
    (when (and x (not (hk-ent-sub x)))
      (setf (hk-ent-borrada x) (not (hk-ent-borrada x)))
      (dolist (s (hk-al-subs e)) (setf (hk-ent-borrada s) (hk-ent-borrada x)))
      e)))
(defun entlast ()
  (loop for i from (1- (fill-pointer *hk-al-db*)) downto 0
        for x = (aref *hk-al-db* i)
        unless (or (hk-ent-borrada x) (hk-ent-sub x)) do (return (hk-ent-ename x))))
(defun entnext (&optional e)
  (let ((desde (if e (1+ (- (hk-ename-id e) *hk-al-base*)) 0)))
    (loop for i from desde below (fill-pointer *hk-al-db*)
          for x = (aref *hk-al-db* i)
          unless (hk-ent-borrada x) do (return (hk-ent-ename x)))))
(defun handent (h)
  (let ((n (ignore-errors (parse-integer h :radix 16))))
    (and n (let ((x (hk-al-viva (hk-mk-ename n)))) (and x (hk-ent-ename x))))))

;; ---------- wcmatch (comodines de AutoCAD) ----------
(defun hk-al-wc-clase (ch cls ci)
  (let ((n (length cls)) (i 0))
    (loop while (< i n) do
      (let ((a (char cls i)))
        (if (and (< (+ i 2) n) (char= (char cls (1+ i)) #\-))
            (let ((b (char cls (+ i 2))))
              (when (if ci (char-not-greaterp a ch b) (char<= a ch b)) (return-from hk-al-wc-clase t))
              (incf i 3))
            (progn (when (if ci (char-equal a ch) (char= a ch)) (return-from hk-al-wc-clase t))
                   (incf i)))))
    nil))
(defun hk-al-wc1 (s pat ci)
  (let ((ns (length s)) (np (length pat)))
    (labels ((ch= (a b) (if ci (char-equal a b) (char= a b)))
             (m (i j)
               (if (= j np)
                   (= i ns)
                   (let ((p (char pat j)) (hay (< i ns)))
                     (case p
                       (#\* (or (m i (1+ j)) (and hay (m (1+ i) j))))
                       (#\? (and hay (m (1+ i) (1+ j))))
                       (#\# (and hay (digit-char-p (char s i)) (m (1+ i) (1+ j))))
                       (#\@ (and hay (alpha-char-p (char s i)) (m (1+ i) (1+ j))))
                       (#\. (and hay (not (alphanumericp (char s i))) (m (1+ i) (1+ j))))
                       (#\` (and hay (< (1+ j) np) (ch= (char s i) (char pat (1+ j))) (m (1+ i) (+ j 2))))
                       (#\[ (let ((k (position #\] pat :start (1+ j))))
                              (if (null k)
                                  (and hay (ch= (char s i) p) (m (1+ i) (1+ j)))
                                  (let* ((cls (subseq pat (1+ j) k))
                                         (neg (and (> (length cls) 0) (char= (char cls 0) #\~)))
                                         (en (and hay (hk-al-wc-clase (char s i) (if neg (subseq cls 1) cls) ci))))
                                    (and hay (if neg (not en) en) (m (1+ i) (1+ k)))))))
                       (t (and hay (ch= (char s i) p) (m (1+ i) (1+ j)))))))))
      (m 0 0))))
(defun hk-al-wc (s pat ci)
  (let ((alts nil) (cur (make-string-output-stream)) (i 0) (n (length pat)))
    (loop while (< i n) do
      (let ((c (char pat i)))
        (cond ((and (char= c #\`) (< (1+ i) n)) (write-char c cur) (write-char (char pat (1+ i)) cur) (incf i 2))
              ((char= c #\,) (push (get-output-stream-string cur) alts) (incf i))
              (t (write-char c cur) (incf i)))))
    (push (get-output-stream-string cur) alts)
    (some (lambda (a)
            (if (and (> (length a) 0) (char= (char a 0) #\~))
                (not (hk-al-wc1 s (subseq a 1) ci))
                (hk-al-wc1 s a ci)))
          (nreverse alts))))
(defun wcmatch (s pat) (if (hk-al-wc s pat nil) t nil))

;; ---------- ssget y conjuntos de selección ----------
(defun hk-al-fparse (items)
  (let ((tests nil))
    (loop
      (when (null items) (return (values (nreverse tests) nil)))
      (let ((it (pop items)))
        (if (and (consp it) (eql (car it) -4) (stringp (cdr it)))
            (let ((op (string-upcase (cdr it))))
              (cond ((member op '("<AND" "<OR" "<NOT" "<XOR") :test #'string=)
                     (multiple-value-bind (sub rest) (hk-al-fparse items)
                       (setf items rest)
                       (push (cons (cond ((string= op "<AND") :and) ((string= op "<OR") :or)
                                         ((string= op "<NOT") :not) (t :xor))
                                   sub)
                             tests)))
                    ((member op '("AND>" "OR>" "NOT>" "XOR>") :test #'string=)
                     (return (values (nreverse tests) items)))
                    (t (push (list :rel op (pop items)) tests))))
            (push (list :rel "=" it) tests))))))
(defun hk-al-cmp (op a b)
  (cond ((string= op "*") t)
        ((and (stringp a) (stringp b))
         (let ((m (hk-al-wc a b t))) (if (member op '("!=" "/=" "<>") :test #'string=) (not m) m)))
        ((and (realp a) (realp b))
         (let ((ig (<= (abs (- a b)) (* 1d-10 (max 1 (abs a) (abs b))))))
           (cond ((string= op "=") ig)
                 ((member op '("!=" "/=" "<>") :test #'string=) (not ig))
                 ((string= op "<") (< a b)) ((string= op ">") (> a b))
                 ((string= op "<=") (or ig (< a b))) ((string= op ">=") (or ig (> a b)))
                 (t nil))))
        (t nil)))
(defun hk-al-fpar (d op par)
  (let* ((code (car par)) (quiere (cdr par))
         (a (assoc code d))
         (ev (cond (a (cdr a)) ((eql code 62) 256) ((eql code 6) "BYLAYER") (t :nada))))
    (cond ((string= op "*") t)
          ((eq ev :nada) nil)
          ((and (consp quiere) (consp ev))
           (let ((ops (let ((r nil) (s op))
                        (loop (let ((k (position #\, s)))
                                (push (string-trim " " (subseq s 0 k)) r)
                                (if k (setf s (subseq s (1+ k))) (return (nreverse r))))))))
             (loop for x in ev for y in quiere for i from 0
                   always (hk-al-cmp (or (nth i ops) (car (last ops))) x y))))
          (t (hk-al-cmp op ev quiere)))))
(defun hk-al-ftest (d tst)
  (case (car tst)
    (:and (every (lambda (x) (hk-al-ftest d x)) (cdr tst)))
    (:or (some (lambda (x) (hk-al-ftest d x)) (cdr tst)))
    (:not (notany (lambda (x) (hk-al-ftest d x)) (cdr tst)))
    (:xor (= 1 (count-if (lambda (x) (hk-al-ftest d x)) (cdr tst))))
    (:rel (hk-al-fpar d (second tst) (third tst)))))
(defun hk-al-filtro-ok (d filtro)
  (or (null filtro) (every (lambda (x) (hk-al-ftest d x)) (hk-al-fparse filtro))))

(defun ssget (&optional modo p2 p3 p4)
  "Solo el modo \"_X\" (o \"X\", \"_A\"): toda la base de dibujo que pase el filtro P2.
Los modos que piden elegir en pantalla devuelven NIL (en una hoja no hay pantalla)."
  (declare (ignore p3 p4))
  (when (and (stringp modo) (member (string-upcase (string-left-trim "_" modo)) '("X" "A") :test #'string=))
    (let ((items nil) (f (if (listp p2) p2 nil)))
      (loop for x across *hk-al-db*
            unless (or (hk-ent-borrada x) (hk-ent-sub x))
              do (when (hk-al-filtro-ok (hk-ent-datos x) f) (push (hk-ent-ename x) items)))
      (when items (hk-mk-ssel (incf *hk-al-nss*) (nreverse items))))))
(defun sslength (ss)
  (unless (hk-ssel-p ss) (error "bad argument type: lselsetp ~a" ss))
  (length (hk-ssel-items ss)))
(defun ssname (ss i)
  (unless (hk-ssel-p ss) (error "bad argument type: lselsetp ~a" ss))
  (and (integerp i) (>= i 0) (nth i (hk-ssel-items ss))))
(defun ssadd (&optional e ss)
  (cond ((null e) (hk-mk-ssel (incf *hk-al-nss*) nil))
        ((null ss) (and (hk-al-viva e) (hk-mk-ssel (incf *hk-al-nss*) (list e))))
        (t (unless (member e (hk-ssel-items ss))
             (setf (hk-ssel-items ss) (append (hk-ssel-items ss) (list e))))
           ss)))
(defun ssdel (e ss)
  (when (member e (hk-ssel-items ss)) (setf (hk-ssel-items ss) (remove e (hk-ssel-items ss))) ss))
(defun ssmemb (e ss) (and (member e (hk-ssel-items ss)) e))

;; ---------- utilidades de AutoLISP ----------
(defun strcat (&rest s) (apply #'concatenate 'string s))
(defun strlen (&rest s) (reduce #'+ (mapcar #'length s)))
(defun substr (s inicio &optional n)
  (let* ((a (min (length s) (max 0 (1- inicio)))) (b (if n (min (length s) (+ a n)) (length s))))
    (subseq s a b)))
(defun strcase (s &optional minusc) (if minusc (string-downcase s) (string-upcase s)))
(defun itoa (n)
  (unless (integerp n) (error "bad argument type: fixnump: ~a" n))
  (format nil "~d" n))
(defun atoi (s) (or (ignore-errors (parse-integer s :junk-allowed t)) 0))
(defun atof (s)
  (let* ((s (string-trim " " s))
         (k (or (position-if-not (lambda (c) (find c "0123456789+-.eE")) s) (length s)))
         (v (ignore-errors (let ((*read-default-float-format* 'double-float))
                             (read-from-string (subseq s 0 k))))))
    (if (realp v) (hk-al-d v) 0d0)))
(defun fix (x) (values (truncate x)))
(defun hk-al-fdec (x prec)
  (let ((s (format nil "~,vF" prec (hk-al-d x))))
    (when (and (> (length s) 0) (char= (char s (1- (length s))) #\.)) (setf s (subseq s 0 (1- (length s)))))
    (when (and (> (length s) 0) (char= (char s 0) #\.)) (setf s (concatenate 'string "0" s)))
    (when (and (> (length s) 1) (string= (subseq s 0 2) "-.")) (setf s (concatenate 'string "-0" (subseq s 1))))
    s))
(defun rtos (x &optional modo prec)
  "Número → texto, como AutoCAD: modo 2 decimal (defecto LUNITS), 1 científico; PREC = LUPREC."
  (let ((modo (or modo (getvar "LUNITS") 2)) (prec (or prec (getvar "LUPREC") 4)) (x (hk-al-d x)))
    (if (= modo 1)
        (let* ((ex (if (zerop x) 0 (floor (log (abs x) 10))))
               (m (/ x (expt 10d0 ex))))
          (when (>= (abs (read-from-string (hk-al-fdec m prec))) 10) (incf ex) (setf m (/ m 10)))
          (format nil "~aE~a~2,'0d" (hk-al-fdec m prec) (if (minusp ex) "-" "+") (abs ex)))
        (hk-al-fdec x prec))))
(defun angtos (a &optional modo prec)
  (let ((modo (or modo (getvar "AUNITS") 0)) (prec (or prec (getvar "AUPREC") 0)))
    (if (= modo 3)
        (concatenate 'string (hk-al-fdec a prec) "r")
        (hk-al-fdec (* (hk-al-d a) (/ 180d0 +hk-al-pi+)) prec))))
(defun polar (p a d)
  (let ((x (+ (hk-al-d (first p)) (* (hk-al-d d) (cos (hk-al-d a)))))
        (y (+ (hk-al-d (second p)) (* (hk-al-d d) (sin (hk-al-d a))))))
    (if (third p) (list x y (hk-al-d (third p))) (list x y))))
(defun distance (p1 p2)
  (let ((dx (- (first p2) (first p1))) (dy (- (second p2) (second p1)))
        (dz (if (and (third p1) (third p2)) (- (third p2) (third p1)) 0)))
    (sqrt (hk-al-d (+ (* dx dx) (* dy dy) (* dz dz))))))
(defun angle (p1 p2)
  (let ((a (atan (hk-al-d (- (second p2) (second p1))) (hk-al-d (- (first p2) (first p1))))))
    (if (< a 0) (+ a (* 2 +hk-al-pi+)) a)))
(defun inters (p1 p2 p3 p4 &optional (enseg t))
  (let* ((x1 (hk-al-d (first p1))) (y1 (hk-al-d (second p1))) (x2 (hk-al-d (first p2))) (y2 (hk-al-d (second p2)))
         (x3 (hk-al-d (first p3))) (y3 (hk-al-d (second p3))) (x4 (hk-al-d (first p4))) (y4 (hk-al-d (second p4)))
         (den (- (* (- x2 x1) (- y4 y3)) (* (- y2 y1) (- x4 x3)))))
    (unless (< (abs den) 1d-14)
      (let ((ta (/ (- (* (- x3 x1) (- y4 y3)) (* (- y3 y1) (- x4 x3))) den))
            (tb (/ (- (* (- x3 x1) (- y2 y1)) (* (- y3 y1) (- x2 x1))) den)))
        (when (or (not enseg) (and (<= -1d-12 ta (+ 1 1d-12)) (<= -1d-12 tb (+ 1 1d-12))))
          (list (+ x1 (* ta (- x2 x1))) (+ y1 (* ta (- y2 y1))) 0d0))))))
(defmacro repeat (n &body cuerpo)
  (let ((r (gensym)) (i (gensym)))
    `(let ((,r nil)) (dotimes (,i ,n ,r) (setq ,r (progn ,@cuerpo))))))
(defmacro foreach (var lista &body cuerpo)
  (let ((r (gensym)))
    `(let ((,r nil)) (dolist (,var ,lista ,r) (setq ,r (progn ,@cuerpo))))))
(defmacro while (prueba &body cuerpo)
  (let ((r (gensym)))
    `(let ((,r nil)) (loop while ,prueba do (setq ,r (progn ,@cuerpo))) ,r)))
(defun prompt (s) (princ s) nil)
(defun alert (s) (fresh-line) (princ s) (terpri) nil)

;; ---------- ejecutar un bloque de código AutoLISP (forma a forma) ----------
(defun hk-al-cadenas (codigo)
  "Escapes de AutoLISP dentro de las cadenas: \\n salto, \\t tabulador (CL los leería como n, t)."
  (with-output-to-string (o)
    (let ((n (length codigo)) (i 0) (en-cad nil) (en-com nil))
      (loop while (< i n) do
        (let ((c (char codigo i)))
          (cond (en-com (write-char c o) (when (char= c #\Newline) (setf en-com nil)) (incf i))
                ((and en-cad (char= c #\\) (< (1+ i) n))
                 (let ((d (char codigo (1+ i))))
                   (case d
                     (#\n (write-char #\Newline o))
                     (#\t (write-char #\Tab o))
                     (#\r (write-char #\Return o))
                     (t (write-char c o) (write-char d o))))
                 (incf i 2))
                ((char= c #\") (setf en-cad (not en-cad)) (write-char c o) (incf i))
                ((and (not en-cad) (char= c #\;)) (setf en-com t) (write-char c o) (incf i))
                (t (write-char c o) (incf i))))))))
(defun hk-al-forma (f)
  "(princ) sin argumentos → (values); (defun f (a / b c) …) → variables locales con let."
  (cond ((atom f) f)
        ((equal f '(princ)) '(values))
        ;; AutoLISP: (mapcar '(lambda (x) …) l) — la lambda citada es una función (y ve las variables
        ;; de alrededor, que AutoLISP tiene de alcance dinámico): en CL, (function (lambda …)).
        ((and (eq (car f) 'quote) (consp (cadr f)) (eq (car (cadr f)) 'lambda))
         (list 'function (hk-al-forma (cadr f))))
        ((and (eq (car f) 'defun) (consp (cdr f)) (listp (third f)) (member '/ (third f)))
         (let* ((ll (third f)) (k (position '/ ll)))
           (list* 'defun (second f) (subseq ll 0 k)
                  (list (list* 'let (subseq ll (1+ k)) (mapcar #'hk-al-forma (cdddr f)))))))
        (t (let ((r nil) (x f))
             (loop while (consp x) do (push (hk-al-forma (car x)) r) (setf x (cdr x)))
             (let ((l (nreverse r))) (if x (append l x) l))))))
(defun hk-al-ejecuta (codigo)
  "Evalúa CODIGO forma a forma; un error se escribe y el resto sigue (como la hoja)."
  (let ((*read-default-float-format* 'double-float)
        (*package* (find-package "COMMON-LISP-USER")))
    (with-input-from-string (in (hk-al-cadenas codigo))
      (loop
        (let ((form (handler-case (read in nil :hk-eof)
                      (error (c) (fresh-line) (format t "; error de lectura: ~a~%" c) :hk-eof))))
          (when (eq form :hk-eof) (return))
          (handler-case
              (handler-bind ((warning #'muffle-warning))
                (let ((*error-output* (make-broadcast-stream)))
                  (eval (hk-al-forma form))))
            (error (c) (fresh-line) (format t "; error: ~a~%" c)))))))
  (fresh-line)
  (values))

;; ---------- volcado para la app (la app lo convierte en SVG y en .dxf) ----------
(defun hk-al-num (x &optional (nd 9))
  (let* ((s (format nil "~,vF" nd (hk-al-d x)))
         (s (string-right-trim "0" s)))
    (when (and (> (length s) 0) (char= (char s (1- (length s))) #\.)) (setf s (subseq s 0 (1- (length s)))))
    (when (and (> (length s) 0) (char= (char s 0) #\.)) (setf s (concatenate 'string "0" s)))
    (when (and (> (length s) 1) (string= (subseq s 0 2) "-.")) (setf s (concatenate 'string "-0" (subseq s 1))))
    (if (or (string= s "-0") (string= s "")) "0" s)))
(defun hk-al-esc (s)
  (with-output-to-string (o)
    (loop for c across (princ-to-string s) do
      (cond ((char= c #\Newline) (write-string "\\P" o))
            ((member (char-code c) '(13 28 29 30 31)) (write-char #\Space o))
            (t (write-char c o))))))
(defun hk-al-val (v)
  (cond ((integerp v) (format nil "~d" v))
        ((realp v) (hk-al-num v))
        ((and (consp v) (every #'realp v)) (format nil "~{~a~^,~}" (mapcar #'hk-al-num v)))
        (t (hk-al-esc v))))
(defun hk-al-volcar (&optional titulo)
  (let ((fs (code-char 28)) (us (code-char 31)))
    (fresh-line)
    (format t "~cB~c~a~%" fs us (hk-al-esc (or titulo "")))
    (dolist (v '("DIMSCALE" "DIMTXT" "DIMASZ" "DIMDEC" "DIMEXO" "DIMEXE" "DIMGAP" "HKVERT" "LUPREC" "HKVISTA" "HKAZ" "HKEL"))
      (format t "~cV~c~a~c~a~%" fs us v us (hk-al-val (getvar v))))
    (dolist (c *hk-al-capas*)
      (format t "~cL~c~a~c~d~c~a~c~d~%" fs us (hk-al-esc (cdr (assoc 2 c))) us (cdr (assoc 62 c))
              us (cdr (assoc 6 c)) us (cdr (assoc 370 c))))
    (loop for x across *hk-al-db*
          unless (or (hk-ent-borrada x) (hk-ent-sub x))
            do (write-char fs) (write-char #\E)
               (dolist (p (hk-ent-datos x))
                 (format t "~c~d=~a" us (car p) (hk-al-val (cdr p))))
               (when (string= (cdr (assoc 0 (hk-ent-datos x))) "POLYLINE")
                 (dolist (v (hk-al-subs (hk-ent-ename x)))
                   (let ((d (hk-ent-datos v)))
                     (when (string= (cdr (assoc 0 d)) "VERTEX")
                       (format t "~c1011=~a~c1042=~a" us (hk-al-val (cdr (assoc 10 d))) us (hk-al-val (or (cdr (assoc 42 d)) 0)))))))
               (terpri))
    (dolist (g (reverse *hk-al-guardar*)) (format t "~cS~c~a~%" fs us (hk-al-esc g)))
    (format t "~cZ~%" fs))
  (values))
(defun hk-al-exporta (nombre valor)
  "Devuelve a la hoja un número calculado aquí (línea «nombre = valor» tras el dibujo).
Una forma simbólica constante del motor ((/ 39 4)) se evalúa. Se redondea a 6 decimales; si |v| < 0.1,
a 10 cifras significativas (una inercia en m⁴ de 0.0065671875 no puede quedar en 0.006567)."
  (let ((v (cond ((realp valor) valor)
                 ((consp valor) (ignore-errors (nval valor 'x 0)))
                 (t nil))))
    (format t "~&~cX~c~a~c~a~%" (code-char 28) (code-char 31) nombre (code-char 31)
            (if (realp v)
                (let* ((d (hk-al-d v)) (a (abs d))
                       (nd (if (or (>= a 0.1d0) (< a 1d-300)) 6 (min 17 (- 9 (floor (log a 10))))))
                       (k (expt 10d0 nd)))
                  (hk-al-num (/ (fround (* d k)) k) nd))
                "")))
  (values))
(defun hk-al-ctx (s v)
  "Una definición de la hoja que llega al LISP. Los nombres de Common Lisp (tan, error, t…) no se tocan."
  (unless (or (eq (symbol-package s) (find-package "COMMON-LISP")) (constantp s))
    (setf (symbol-value s) v))
  (values))

;;;; ===================== CAPA SIMPLE (en español, para matemáticas) =====================
;;;; Encima de las listas DXF: cada función ARMA la lista DXF de siempre, la pasa a entmakex y
;;;; devuelve (entget …): la misma lista que leería ssget/entget, para seguir calculando.
;;;; Puntos = listas (x y). Ángulos de la capa simple en GRADOS (como #dibujo: arco(…, a1, a2));
;;;; los de las listas DXF, en radianes (como AutoCAD). Detalles como claves opcionales:
;;;;   :color  número ACI o nombre ("rojo" "amarillo" "verde" "cian" "azul" "magenta" "gris" "naranja")
;;;;   :capa   nombre de capa (se crea sola)    :tipo "trazos" | "oculta" | "eje" | "puntos"
;;;;   :grosor mm (0.5) o "fina" | "media" | "gruesa" | "muygruesa"   (los mismos de #dibujo)

(defparameter *hk-al-colores*
  '(("rojo" . 1) ("amarillo" . 2) ("verde" . 3) ("cian" . 4) ("azul" . 5) ("magenta" . 6)
    ("blanco" . 7) ("negro" . 7) ("gris" . 8) ("gris-claro" . 9) ("naranja" . 30)
    ("porcapa" . 256) ("capa" . 256)))
(defun hk-al-aci (c)
  (cond ((integerp c) c)
        ((or (stringp c) (symbolp c))
         (or (cdr (assoc (string-downcase (string c)) *hk-al-colores* :test #'string=)) 7))
        (t 256)))
(defun hk-al-ltipo (tp)
  (let ((s (string-downcase (string tp))))
    (cond ((string= s "trazos") "DASHED") ((string= s "oculta") "HIDDEN")
          ((string= s "eje") "CENTER") ((string= s "puntos") "DOT") ((string= s "continua") "CONTINUOUS")
          (t (string-upcase s)))))
(defun hk-al-grosor (g)
  (cond ((realp g) (round (* 100 g)))
        (t (let ((s (string-downcase (string g))))
             (cond ((string= s "fina") 18) ((string= s "media") 30) ((string= s "gruesa") 50)
                   ((string= s "muygruesa") 70) (t -1))))))
(defun hk-al-props (color capa tipo grosor)
  (append (list (cons 8 (if capa (string capa) (getvar "CLAYER"))))
          (and color (list (cons 62 (hk-al-aci color))))
          (and tipo (list (cons 6 (hk-al-ltipo tipo))))
          (and grosor (list (cons 370 (hk-al-grosor grosor))))))
(defun hk-al-hacer (tipo props geo)
  (let ((e (entmakex (append (list (cons 0 tipo)) props geo)))) (and e (entget e))))

(defun rad (g) "grados → radianes" (* (hk-al-d g) (/ +hk-al-pi+ 180d0)))
(defun grad (r) "radianes → grados" (* (hk-al-d r) (/ 180d0 +hk-al-pi+)))
(defun dxf (codigo lista) "El valor del código en una lista DXF: (cdr (assoc codigo lista))."
  (cdr (assoc codigo (if (hk-ename-p lista) (entget lista) lista))))

(defun capa (nombre &key color tipo grosor)
  "Crea (o cambia) la capa y la deja como actual (CLAYER). Devuelve el nombre."
  (entmake (list (cons 0 "LAYER") (cons 2 nombre) (cons 70 0)
                 (cons 62 (if color (hk-al-aci color) 7))
                 (cons 6 (if tipo (hk-al-ltipo tipo) "CONTINUOUS"))
                 (cons 370 (if grosor (hk-al-grosor grosor) -3))))
  (setvar "CLAYER" nombre)
  nombre)
(defun punto (p &key color capa)
  (hk-al-hacer "POINT" (hk-al-props color capa nil nil) (list (cons 10 p))))
(defun linea (p1 p2 &key color capa tipo grosor)
  (hk-al-hacer "LINE" (hk-al-props color capa tipo grosor) (list (cons 10 p1) (cons 11 p2))))
(defun circulo (c r &key color capa tipo grosor)
  (hk-al-hacer "CIRCLE" (hk-al-props color capa tipo grosor) (list (cons 10 c) (cons 40 r))))
(defun arco (c r a1 a2 &key color capa tipo grosor)
  "Arco de centro C y radio R, de A1 a A2 GRADOS en sentido antihorario."
  (hk-al-hacer "ARC" (hk-al-props color capa tipo grosor)
               (list (cons 10 c) (cons 40 r) (cons 50 (rad a1)) (cons 51 (rad a2)))))
(defun poli (pts &key cerrada color capa tipo grosor ancho)
  "Polilínea (LWPOLYLINE) por la lista de puntos PTS."
  (hk-al-hacer "LWPOLYLINE" (hk-al-props color capa tipo grosor)
               (append (list (cons 70 (if cerrada 1 0)))
                       (and ancho (list (cons 43 ancho)))
                       (mapcar (lambda (p) (cons 10 p)) pts))))
(defun polilinea (pts &rest claves) (apply #'poli pts claves))
(defun rect (p b h &key color capa tipo grosor)
  "Rectángulo de esquina inferior izquierda P, ancho B y alto H (polilínea cerrada)."
  (let ((x (first p)) (y (second p)))
    (poli (list (list x y) (list (+ x b) y) (list (+ x b) (+ y h)) (list x (+ y h)))
          :cerrada t :color color :capa capa :tipo tipo :grosor grosor)))
(defun texto (p s &key altura (alinea "i") angulo color capa estilo)
  "Texto en P. ALINEA: \"i\" izquierda, \"c\" centro, \"d\" derecha, \"m\" medio (centro en los dos ejes).
ESTILO: estilo de texto (código 7); \"HKMATH\" = se dibuja como la matemática de la hoja."
  (let* ((a (string-downcase (string alinea)))
         (h72 (cond ((string= a "c") 1) ((string= a "d") 2) ((string= a "m") 4) (t 0))))
    (hk-al-hacer "TEXT" (hk-al-props color capa nil nil)
                 (append (list (cons 10 p) (cons 40 (or altura (getvar "TEXTSIZE")))
                               (cons 1 (if (stringp s) s (princ-to-string s))))
                         (and estilo (list (cons 7 estilo)))
                         (and angulo (list (cons 50 (rad angulo))))
                         (and (/= h72 0) (list (cons 72 h72) (cons 11 p)))))))
(defun hk-al-mat (e)
  (cond ((stringp e) e)
        ((and (floatp e) (= e (fround e)) (< (abs e) 1d15)) (format nil "~d" (round e)))
        ((floatp e) (hk-al-num (/ (fround (* e 1d4)) 1d4)))
        (t (infix e))))
(defun formula (p expr &key nombre altura (alinea "i") angulo color capa)
  "Rótulo con la MATEMÁTICA de la hoja (cursivas, exponentes, fracciones en línea): EXPR es una
expresión simbólica del motor ((derive-x f), 27/4…) o un texto \"f'(x) = 2*x - 3\"; NOMBRE va delante con « = »."
  (texto p (if nombre (concatenate 'string nombre " = " (hk-al-mat expr)) (hk-al-mat expr))
         :altura altura :alinea alinea :angulo angulo :color color :capa capa :estilo "HKMATH"))
(defun cota (p1 p2 &key sep texto dir color capa)
  "Cota de P1 a P2 (DIMENSION). SEP: distancia de la línea de cota, positiva a la IZQUIERDA de
P1→P2 (la misma regla que cota(…) de #dibujo). DIR: nil alineada, \"h\" horizontal, \"v\" vertical."
  (let* ((l (distance p1 p2)) (sep (or sep (* 0.15 l)))
         (d (and dir (string-downcase (string dir))))
         (x1 (first p1)) (y1 (second p1)) (x2 (first p2)) (y2 (second p2)))
    (cond ((equal d "h")
           (hk-al-hacer "DIMENSION" (hk-al-props color capa nil nil)
                        (list (cons 10 (list x1 (+ (max y1 y2) sep))) (cons 70 32) (cons 1 (or texto ""))
                              (cons 13 p1) (cons 14 p2) (cons 50 0d0))))
          ((equal d "v")
           (hk-al-hacer "DIMENSION" (hk-al-props color capa nil nil)
                        (list (cons 10 (list (- (min x1 x2) sep) y1)) (cons 70 32) (cons 1 (or texto ""))
                              (cons 13 p1) (cons 14 p2) (cons 50 (/ +hk-al-pi+ 2)))))
          (t
           (let ((nx (/ (- y1 y2) (max l 1d-300))) (ny (/ (- x2 x1) (max l 1d-300))))
             (hk-al-hacer "DIMENSION" (hk-al-props color capa nil nil)
                          (list (cons 10 (list (+ x2 (* sep nx)) (+ y2 (* sep ny)))) (cons 70 33)
                                (cons 1 (or texto "")) (cons 13 p1) (cons 14 p2))))))))
(defun achurado (pts &key (patron "SOLID") escala (angulo 0) color capa transparencia)
  "Relleno (HATCH) del polígono PTS. PATRON: \"SOLID\" (lleno), \"ANSI31\" (rayado 45°), \"ANSI37\" (cruzado).
ESCALA del patrón (sin ella: ~35 rayas a lo ancho del polígono). TRANSPARENCIA de 0 (opaco) a 0.9."
  (let* ((solido (string-equal patron "SOLID"))
         (escala (or escala
                     (let ((xs (mapcar #'first pts)) (ys (mapcar #'second pts)))
                       (/ (max 1d-9 (distance (list (reduce #'min xs) (reduce #'min ys))
                                              (list (reduce #'max xs) (reduce #'max ys))))
                          (* 35 3.175d0))))))
    (hk-al-hacer "HATCH" (append (hk-al-props color capa nil nil)
                                 (and transparencia
                                      (list (cons 440 (+ #x02000000 (round (* 255 (- 1 transparencia))))))))
                 (append (list (cons 10 '(0 0 0)) (cons 2 (string-upcase patron)) (cons 70 (if solido 1 0))
                               (cons 71 0) (cons 91 1) (cons 92 2) (cons 72 0) (cons 73 1)
                               (cons 93 (length pts)))
                         (mapcar (lambda (p) (cons 10 p)) pts)
                         (list (cons 97 0) (cons 75 0) (cons 76 1) (cons 52 (rad angulo))
                               (cons 41 escala) (cons 98 0))))))

;; ---- curvas desde una fórmula ----
(defun hk-al-tiene (e s) (or (eq e s) (and (consp e) (some (lambda (x) (hk-al-tiene x s)) (cdr e)))))
(defun hk-al-var-de (e)
  (if (hk-al-tiene e 'x) 'x
      (labels ((libre (e) (cond ((and (symbolp e) e (not (eq e t)) (not (member e '(pi e)))
                                      (not (keywordp e)) (not (boundp e)))
                                 e)
                                ((consp e) (some #'libre (cdr e)))
                                (t nil))))
        (or (libre e) 'x))))
(defun hk-al-sust (e v)
  (cond ((and (symbolp e) e (not (eq e v)) (not (eq e t)) (not (keywordp e))
              (boundp e) (realp (symbol-value e)))
         (symbol-value e))
        ((consp e) (cons (car e) (mapcar (lambda (x) (hk-al-sust x v)) (cdr e))))
        (t e)))
(defun hk-al-nval (e v x)
  (handler-case (nval (hk-al-sust e v) v x)
    (error () (progv (list v) (list x) (hk-al-d (eval e))))))
(defun hk-al-funcion (f var)
  "F → función de un número: una función, un símbolo con función o con una EXPRESIÓN guardada,
una lambda, o una expresión simbólica de la hoja ((* x x), (derive-x …))."
  (cond ((functionp f) f)
        ((and (symbolp f) f (boundp f) (functionp (symbol-value f))) (symbol-value f))
        ((and (symbolp f) f (boundp f) (consp (symbol-value f))) (hk-al-funcion (symbol-value f) var))
        ((and (symbolp f) f (fboundp f) (not (macro-function f)) (not (special-operator-p f)))
         (symbol-function f))
        ((and (consp f) (eq (car f) 'lambda)) (coerce f 'function))
        (t (let ((v (or var (hk-al-var-de f)))) (lambda (x) (hk-al-nval f v x))))))
(defun hk-al-y (fn x)
  (let ((y (ignore-errors (funcall fn x))))
    (and (realp y) (let ((d (hk-al-d y))) (and (= d d) (< (abs d) 1d300) d)))))
(defun curva (f a b &key (n 100) var color capa tipo grosor)
  "Gráfica de y = f(x) en [A, B] con N tramos (una LWPOLYLINE). F: expresión, función o lambda."
  (let ((fn (hk-al-funcion f var)) (pts nil) (a (hk-al-d a)) (b (hk-al-d b)))
    (dotimes (i (1+ n))
      (let* ((x (+ a (* (- b a) (/ i n)))) (y (hk-al-y fn x)))
        (when y (push (list x y) pts))))
    (and pts (poli (nreverse pts) :color color :capa capa :tipo tipo :grosor grosor))))
(defun curva-par (fx fy t0 t1 &key (n 100) var color capa tipo grosor cerrada)
  "Curva paramétrica (fx(u), fy(u)), u de T0 a T1."
  (let ((gx (hk-al-funcion fx var)) (gy (hk-al-funcion fy var)) (pts nil) (t0 (hk-al-d t0)) (t1 (hk-al-d t1)))
    (dotimes (i (1+ n))
      (let* ((u (+ t0 (* (- t1 t0) (/ i n)))) (x (hk-al-y gx u)) (y (hk-al-y gy u)))
        (when (and x y) (push (list x y) pts))))
    (and pts (poli (nreverse pts) :cerrada cerrada :color color :capa capa :tipo tipo :grosor grosor))))
(defun hk-al-paso (rango)
  (let* ((r (/ (abs rango) 6)) (p (expt 10d0 (floor (log (max r 1d-12) 10)))) (m (/ r p)))
    (* p (cond ((< m 1.5) 1) ((< m 3.5) 2) ((< m 7.5) 5) (t 10)))))
(defun hk-al-rot-num (v)
  (let ((r (/ (fround (* v 1d6)) 1d6)))
    (if (< (abs (- r (fround r))) 1d-9) (format nil "~d" (round r)) (hk-al-num r))))
(defun ejes (xmin xmax ymin ymax &key paso-x paso-y (capa "EJES") (color 8) altura
                                      (rotulos t) (nombre-x "x") (nombre-y "y") rejilla)
  "Ejes x-y con marcas y rótulos, en la capa EJES. La y se puede exagerar con (vertical k)."
  (let* ((cl (getvar "CLAYER"))
         (xmin (hk-al-d xmin)) (xmax (hk-al-d xmax)) (ymin (hk-al-d ymin)) (ymax (hk-al-d ymax))
         (kv (hk-al-d (or (getvar "HKVERT") 1)))
         (h (or altura (* 0.026 (max (- xmax xmin) (* (- ymax ymin) kv)))))
         (y0 (if (<= ymin 0 ymax) 0d0 ymin)) (x0 (if (<= xmin 0 xmax) 0d0 xmin))
         (px (or paso-x (hk-al-paso (- xmax xmin)))) (py (or paso-y (hk-al-paso (- ymax ymin))))
         (tk (* 0.5 h)) (n 0))
    (capa capa :color color)
    (flet ((cuenta (r) (when r (incf n)) r))
      (when rejilla
        (loop for x from (* px (ceiling (- xmin 1d-9) px)) to (+ xmax 1d-9) by px
              do (cuenta (linea (list x ymin) (list x ymax) :color 9 :tipo "puntos")))
        (loop for y from (* py (ceiling (- ymin 1d-9) py)) to (+ ymax 1d-9) by py
              do (cuenta (linea (list xmin y) (list xmax y) :color 9 :tipo "puntos"))))
      (cuenta (linea (list xmin y0) (list xmax y0)))
      (cuenta (linea (list x0 ymin) (list x0 ymax)))
      ;; flechas en las puntas (SOLID), con la y corregida por la exageración
      (cuenta (hk-al-hacer "SOLID" (hk-al-props nil capa nil nil)
                           (list (cons 10 (list xmax y0)) (cons 11 (list (- xmax (* 1.6 tk)) (+ y0 (/ (* 0.5 tk) kv))))
                                 (cons 12 (list (- xmax (* 1.6 tk)) (- y0 (/ (* 0.5 tk) kv)))))))
      (cuenta (hk-al-hacer "SOLID" (hk-al-props nil capa nil nil)
                           (list (cons 10 (list x0 ymax)) (cons 11 (list (- x0 (* 0.5 tk)) (- ymax (/ (* 1.6 tk) kv))))
                                 (cons 12 (list (+ x0 (* 0.5 tk)) (- ymax (/ (* 1.6 tk) kv)))))))
      (loop for x from (* px (ceiling (- xmin 1d-9) px)) to (- xmax (* 0.5 px)) by px
            unless (< (abs (- x x0)) 1d-9)
              do (cuenta (linea (list x (- y0 (/ tk kv))) (list x (+ y0 (/ tk kv)))))
                 (when rotulos (cuenta (texto (list x (- y0 (/ (* 2.6 h) kv))) (hk-al-rot-num x) :altura h :alinea "c"))))
      (loop for y from (* py (ceiling (- ymin 1d-9) py)) to (- ymax (* 0.5 py)) by py
            unless (< (abs (- y y0)) 1d-9)
              do (cuenta (linea (list (- x0 tk) y) (list (+ x0 tk) y)))
                 (when rotulos (cuenta (texto (list (- x0 (* 1.2 h)) (- y (/ (* 0.4 h) kv))) (hk-al-rot-num y) :altura h :alinea "d"))))
      (when nombre-x (cuenta (texto (list xmax (+ y0 (/ (* 1.3 h) kv))) nombre-x :altura (* 1.15 h) :alinea "d")))
      (when nombre-y (cuenta (texto (list (+ x0 (* 1.2 h)) (- ymax (/ (* 1.2 h) kv))) nombre-y :altura (* 1.15 h)))))
    (setvar "CLAYER" cl)
    n))
(defun vertical (k) "Exagera la escala vertical del dibujo (como vert = k de #dibujo)." (setvar "HKVERT" (hk-al-d k)))
(defun guardar (nombre)
  "Guarda TODO el dibujo; el formato sale de la extensión: .dxf .svg .png .pdf (.dwg: pendiente).
Lo escribe la app (escritorio: junto a la hoja; web: botón de descarga)."
  (push nombre *hk-al-guardar*) nombre)
(defun guardar-dxf (nombre)
  (guardar (if (search "." nombre) nombre (concatenate 'string nombre ".dxf"))))

;; ---- 3D: polilínea 3D (POLYLINE 70 = 8), caras (3DFACE), flechas; la vista (planta / 3D girable) ----
(defun poli3 (pts &key cerrada color capa tipo grosor)
  "Polilínea 3D por PTS ((x y z) …): POLYLINE (70 = 8) + VERTEX (70 = 32) + SEQEND, como en AutoCAD."
  (let* ((pr (hk-al-props color capa tipo grosor)) (cp (assoc 8 pr)))
    (entmake (append (list (cons 0 "POLYLINE")) pr
                     (list (cons 66 1) (cons 10 (list 0 0 0)) (cons 70 (if cerrada 9 8)))))
    (dolist (p pts) (entmake (list (cons 0 "VERTEX") cp (cons 10 p) (cons 70 32))))
    (entmake (list (cons 0 "SEQEND") cp))
    (entget (entlast))))
(defun cara3 (pts &key color capa)
  "Cara 3D (3DFACE) de 3 o 4 vértices."
  (hk-al-hacer "3DFACE" (hk-al-props color capa nil nil)
               (list (cons 10 (first pts)) (cons 11 (second pts)) (cons 12 (third pts))
                     (cons 13 (or (fourth pts) (third pts))))))
(defun hk-al-perp (u)
  "Un vector unitario perpendicular a U."
  (let* ((a (if (< (abs (first u)) 0.9) '(1d0 0d0 0d0) '(0d0 1d0 0d0)))
         (c (list (- (* (second u) (third a)) (* (third u) (second a)))
                  (- (* (third u) (first a)) (* (first u) (third a)))
                  (- (* (first u) (second a)) (* (second u) (first a)))))
         (n (sqrt (reduce #'+ (mapcar #'* c c)))))
    (mapcar (lambda (x) (/ x n)) c)))
(defun flecha3 (p q &key color capa grosor punta)
  "Flecha 3D de P a Q: LINE + punta de dos 3DFACE cruzadas (se ve desde cualquier lado)."
  (let* ((p (hk-al-pt p 3)) (q (hk-al-pt q 3))
         (d (mapcar #'- q p)) (l (sqrt (reduce #'+ (mapcar #'* d d)))) (u (mapcar (lambda (x) (/ x l)) d))
         (a (or punta (* 0.14 l))) (w (* 0.3 a))
         (n1 (hk-al-perp u))
         (n2 (list (- (* (second u) (third n1)) (* (third u) (second n1)))
                   (- (* (third u) (first n1)) (* (first u) (third n1)))
                   (- (* (first u) (second n1)) (* (second u) (first n1)))))
         (b (mapcar (lambda (qi ui) (- qi (* a ui))) q u)))
    (flet ((mas (v k s) (mapcar (lambda (bi vi) (+ bi (* s k vi))) b v)))
      (linea p b :color color :capa capa :grosor grosor)
      (cara3 (list q (mas n1 w 1) (mas n1 w -1)) :color color :capa capa)
      (cara3 (list q (mas n2 w 1) (mas n2 w -1)) :color color :capa capa))))
(defun vista (modo &key az el)
  "Cómo se ve el dibujo: \"planta\" o \"3d\" (girable con el ratón). AZ, EL en grados (de fábrica -60, 25)."
  (let ((m (string-downcase (string modo))))
    (setvar "HKVISTA" (if (string= m "planta") 0 1))
    (when az (setvar "HKAZ" (hk-al-d az)))
    (when el (setvar "HKEL" (hk-al-d el)))
    m))

;; ---- transformar LISTAS (no tocan el dibujo: se devuelve otra lista para entmake / entmod) ----
(defun hk-al-mapa-puntos (ent fn)
  (mapcar (lambda (p) (if (and (integerp (car p)) (<= 10 (car p) 18) (hk-al-ptp (cdr p)))
                          (cons (car p) (funcall fn (cdr p)))
                          p))
          (if (hk-ename-p ent) (entget ent) ent)))
(defun desplazar (ent dx dy)
  "Copia de la lista DXF ENT movida (dx, dy). Con (-1 . e) dentro, entmod la aplica al dibujo."
  (hk-al-mapa-puntos ent (lambda (p) (list* (+ (first p) dx) (+ (second p) dy) (cddr p)))))
(defun rotar (ent grados &optional (base '(0 0)))
  (let* ((a (rad grados)) (c (cos a)) (s (sin a)) (bx (first base)) (by (second base)))
    (mapcar (lambda (p) (if (member (car p) '(50 51)) (cons (car p) (+ (cdr p) a)) p))
            (hk-al-mapa-puntos ent (lambda (p) (let ((x (- (first p) bx)) (y (- (second p) by)))
                                                 (list* (+ bx (- (* c x) (* s y))) (+ by (+ (* s x) (* c y))) (cddr p))))))))
(defun escalar (ent k &optional (base '(0 0)))
  (let ((bx (first base)) (by (second base)))
    (mapcar (lambda (p) (if (member (car p) '(40 41 43)) (cons (car p) (* (cdr p) k)) p))
            (hk-al-mapa-puntos ent (lambda (p) (list* (+ bx (* k (- (first p) bx))) (+ by (* k (- (second p) by))) (cddr p)))))))

;; ---- medir lo dibujado (la vuelta: del dibujo al cálculo) ----
(defun vertices (ent)
  "Los puntos de una polilínea (o de un HATCH) leída del dibujo."
  (let ((d (if (hk-ename-p ent) (entget ent) ent)))
    (cond ((string-equal (cdr (assoc 0 d)) "POLYLINE")
           (loop for v in (hk-al-subs (cdr (assoc -1 d)))
                 when (string= (cdr (assoc 0 (hk-ent-datos v))) "VERTEX") collect (cdr (assoc 10 (hk-ent-datos v)))))
          (t
    (if (string-equal (cdr (assoc 0 d)) "HATCH")
        (let ((tras (member 93 d :key #'car)))
          (loop for p in (cdr tras) while (/= (car p) 97) when (= (car p) 10) collect (cdr p)))
        (loop for p in d when (eql (car p) 10) collect (cdr p)))))))
(defun hk-al-bulges (d)
  (let ((r nil) (vio nil))
    (dolist (p d) (cond ((eql (car p) 10) (when vio (push 0d0 r)) (setf vio t))
                        ((and (eql (car p) 42) vio) (push (cdr p) r) (setf vio nil))))
    (when vio (push 0d0 r))
    (nreverse r)))
(defun longitud (ent)
  (let* ((d (if (hk-ename-p ent) (entget ent) ent)) (tp (cdr (assoc 0 d))))
    (cond ((string-equal tp "LINE") (distance (cdr (assoc 10 d)) (cdr (assoc 11 d))))
          ((string-equal tp "CIRCLE") (* 2 +hk-al-pi+ (cdr (assoc 40 d))))
          ((string-equal tp "ARC")
           (let ((da (- (cdr (assoc 51 d)) (cdr (assoc 50 d)))))
             (when (< da 0) (incf da (* 2 +hk-al-pi+)))
             (* (cdr (assoc 40 d)) da)))
          ((string-equal tp "POLYLINE")
           (let* ((v (vertices d)) (n (length v)) (cerr (logtest 1 (or (cdr (assoc 70 d)) 0))) (s 0d0))
             (dotimes (i (if cerr n (1- n)) s) (incf s (distance (nth i v) (nth (mod (1+ i) n) v))))))
          ((string-equal tp "LWPOLYLINE")
           (let* ((v (vertices d)) (bs (hk-al-bulges d)) (n (length v))
                  (cerr (logtest 1 (or (cdr (assoc 70 d)) 0))) (s 0d0))
             (dotimes (i (if cerr n (1- n)) s)
               (let* ((p (nth i v)) (q (nth (mod (1+ i) n) v)) (c (distance p q)) (b (nth i bs)))
                 (incf s (if (and b (/= b 0))
                             (let ((th (* 4 (atan (abs b))))) (/ (* c th) (* 2 (sin (/ th 2)))))
                             c))))))
          (t nil))))
(defun hk-al-shoelace (v)
  (let ((s 0d0) (n (length v)))
    (dotimes (i n (/ s 2))
      (let ((p (nth i v)) (q (nth (mod (1+ i) n) v)))
        (incf s (- (* (first p) (second q)) (* (first q) (second p))))))))
(defun area (ent)
  "Área de un círculo, de una polilínea (cerrada por su último punto), de un HATCH o de un SOLID."
  (let* ((d (if (hk-ename-p ent) (entget ent) ent)) (tp (cdr (assoc 0 d))))
    (cond ((string-equal tp "CIRCLE") (* +hk-al-pi+ (expt (cdr (assoc 40 d)) 2)))
          ((string-equal tp "LWPOLYLINE")
           (let* ((v (vertices d)) (bs (hk-al-bulges d)) (n (length v)) (s (hk-al-shoelace v)))
             (dotimes (i n (abs s))
               (let ((b (nth i bs)))
                 (when (and b (/= b 0))
                   (let* ((c (distance (nth i v) (nth (mod (1+ i) n) v))) (th (* 4 (atan b)))
                          (r (/ c (* 2 (sin (/ (abs th) 2))))))
                     (incf s (* (signum b) 0.5 r r (- (abs th) (sin (abs th)))))))))))
          ((string-equal tp "HATCH") (abs (hk-al-shoelace (vertices d))))
          ((string-equal tp "SOLID")
           (abs (hk-al-shoelace (list (cdr (assoc 10 d)) (cdr (assoc 11 d)) (cdr (assoc 13 d)) (cdr (assoc 12 d))))))
          (t nil))))
