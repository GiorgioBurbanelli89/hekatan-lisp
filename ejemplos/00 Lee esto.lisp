;;;; ============================================================
;;;; BIENVENIDO A HEKATAN LISP  —  ejemplos para practicar
;;;; ============================================================
;;;; - Escribe matematica (MATLAB) o LISP a la izquierda.
;;;; - El resultado sale a la derecha (Render CSS / LISP / MATLAB / 3 formas).
;;;; - Pulsa  ▶ Ejecutar  (o deja AutoRun encendido).
;;;;
;;;; El motor (funciones LISP) hace lo simbolico:
;;;;   derive-x  : derivada respecto a x
;;;;   integ-x   : integral indefinida respecto a x
;;;;   simplify  : junta terminos, quita 0+ , 1* , etc.
;;;;   expand*   : distribuye productos y potencias
;;;;   infix     : muestra una forma LISP como matematica ( (+ x 1) -> x + 1 )
;;;;
;;;; Menu -> Motor -> Ver funciones : para VER esas funciones.
;;;; Abre los otros ejemplos de esta carpeta y juega con ellos.

(format t "Hola. Deriva x^2: ~a  =  ~a~%"
        (infix '(expt x 2)) (infix (derive-x '(expt x 2))))
