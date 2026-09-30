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
                  ;; Recolección ENTRE formas, en un punto seguro (30-sep-2026): si la recolección
                  ;; salta a MITAD de un cálculo simbólico largo, en WASM se liberaba algo vivo y el
                  ;; motor caía con «function signature mismatch» (hoja 99: la K condensada, 14.ª
                  ;; forma, solo fallaba tras las 13 anteriores; con (si:gc t) entre formas, nunca).
                  ;; Cuesta ~11 ms por forma.
                  (t (si:gc t)
                     (handler-case (eval form)
                       (serious-condition (e)
                         (format t "; error: ~a~%" e)))))))))))
