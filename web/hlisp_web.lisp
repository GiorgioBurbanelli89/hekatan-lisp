;;;; hlisp_web.lisp — puente WEB del motor (equivale a hlisp-server, sin stdin/stdout).
;;;; JS manda un TEXTO con formas Lisp; se evalúan una a una y se devuelve TODO lo impreso.

(defun hlisp-web-run (code)
  "Evalua las formas de CODE (string) y devuelve lo que imprimieron (string)."
  (let ((*print-case* :downcase)
        (*print-right-margin* 100000)
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
                  (t (handler-case (eval form)
                       (serious-condition (e)
                         (format t "; error: ~a~%" e)))))))))))
