;;;; hlisp_web.lisp — puente WEB del motor (equivale a hlisp-server, sin stdin/stdout).
;;;; JS manda un TEXTO con formas Lisp; se evalúan una a una y se devuelve TODO lo impreso.

(defvar *hl-gc-mark* 0)
(defparameter *hl-gc-umbral* (* 32 1024 1024))   ; bytes asignados entre dos recolecciones completas

(defun hl-gc-seguro ()
  "Recoleccion completa ENTRE formas, pero solo si se asigno >= umbral desde la ultima
   (un GC completo por forma costaba ~65 % del tiempo en hojas con muchas formas cortas)."
  (let ((ahora (si:gc-stats nil)))
    (when (>= (- ahora *hl-gc-mark*) *hl-gc-umbral*)
      (si:gc t)
      (setf *hl-gc-mark* (si:gc-stats nil)))))

(defun hlisp-web-run (code)
  "Evalua las formas de CODE (string) y devuelve lo que imprimieron (string)."
  (let ((*print-case* :downcase)
        (*print-right-margin* 100000)
        (*print-pretty* nil)
        (*read-default-float-format* 'double-float))
    (with-output-to-string (*standard-output*)
      (with-input-from-string (in code)
        (loop
          (let ((form (handler-case (read in nil :hlisp-eof)
                        (error () :hlisp-skip))))
            (cond ((eq form :hlisp-eof) (return))
                  ((eq form :hlisp-skip) (read-line in nil :hlisp-eof))   ; resincroniza
                  ((equal form '(hlisp-done)))                            ; marcador: se ignora
                  ;; serious-condition (no solo error): en WASM también atrapa la falta de
                  ;; memoria (storage-condition) de UNA forma, y las demás siguen.
                  ;; Recolección ENTRE formas, en un punto seguro (30-sep-2026): si la recolección
                  ;; salta a MITAD de un cálculo simbólico largo, en WASM se liberaba algo vivo y el
                  ;; motor caía con «function signature mismatch» (hoja 99: la K condensada, 14.ª
                  ;; forma, solo fallaba tras las 13 anteriores; con (si:gc t) entre formas, nunca).
                  ;; Cuesta ~11 ms por forma.
                  (t (hl-gc-seguro)
                     (handler-case (eval form)
                       (serious-condition (e)
                         (format t "; error: ~a~%" e)))))))))))
