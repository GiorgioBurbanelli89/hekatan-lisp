;;;; build_aot.lisp — corre en el ECL HOST (Linux). Compila el motor ANTES: Lisp → C → .o (wasm32).
(require (quote cmp))
(defvar *ti* (merge-pathnames "lispwasm/ecl-wasm/ecl-emscripten/target-info.lsp" (user-homedir-pathname)))
(defvar *src* (ext:getenv "HL_SRC"))      ; carpeta hekatan-lisp
(defvar *out* (ext:getenv "HL_OUT"))      ; carpeta de salida (Linux)
(setf *read-default-float-format* 'double-float)   ; 0.09 = double, igual que en SBCL
(defun src (f) (concatenate 'string *src* "/" f))
(defun out (f) (concatenate 'string *out* "/" f))
(let ((objs (list (compile-file (src "engine.lisp") :system-p t :target *ti* :output-file (out "engine.o"))
                  (compile-file (src "web/hlisp_web.lisp") :system-p t :target *ti* :output-file (out "hlisp_web.o")))))
  (format t "~&OBJS ~a~%" objs)
  (when (some #'null objs) (ext:quit 1))
  (c::compile-with-target-info
   (lambda () (c::build-static-library (out "hlisp") :lisp-files objs :init-name "init_hlisp"))
   *ti*))
(format t "~&AOT_OK~%")
(ext:quit 0)
