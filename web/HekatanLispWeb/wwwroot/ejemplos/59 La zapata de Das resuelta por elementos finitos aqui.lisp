;;;; ================================================================
;;;; LA ZAPATA DE DAS 6.10, RESUELTA AQUI POR ELEMENTOS FINITOS
;;;; ================================================================
;;;; Esta hoja NO trae los numeros de fuera: los calcula. Ensambla la
;;;; placa, pone los muelles del suelo, itera el contacto y resuelve el
;;;; sistema, todo en este motor.
;;;;
;;;; Braja M. Das, Principles of Foundation Engineering, 9.a ed. (2019),
;;;; ejemplo 6.10, p. 247-248. Zapata 1.5 x 1.5 x 0.4 m, P = 606 kN con
;;;; e_x = 0.15 m y e_y = 0.30 m, sobre arena de k_s = 2000 tonf/m3.
;;;;
;;;; LO QUE HACE, POR PARTES:
;;;;   1. la matriz de flexion del elemento MZC (Kirchhoff) de 12x12,
;;;;      REPLICADA de shellThin.cpp de Hekatan Struct — las mismas H1,
;;;;      H2, H3, la misma cuadratura de Gauss de 3x3 y la misma
;;;;      conversion de coordenadas naturales a fisicas;
;;;;   2. el ensamblaje sobre una malla de 4 x 4 (25 nudos, 75 grados);
;;;;   3. el suelo: un muelle por nudo, k = k_s * area tributaria;
;;;;   4. LA NO LINEALIDAD: el suelo no tira. Se resuelve, se mira quien
;;;;      SUBE, a ese se le quita el muelle, y se repite hasta que la
;;;;      lista de nudos en contacto no cambia;
;;;;   5. la comprobacion que importa: la suma de los muelles tiene que
;;;;      dar la carga aplicada.
;;;;
;;;; Grados por nudo: [w, tx, ty] con tx = dw/dy, ty = -dw/dx.

;;; ---------- datos ----------
(defparameter *B* 1.5d0)          ; lado en x [m]
(defparameter *L* 1.5d0)          ; lado en y [m]
(defparameter *t* 0.4d0)          ; espesor [m]
(defparameter *E* 22940519.0d0)   ; 15100*sqrt(240) kgf/cm2 -> kN/m2
(defparameter *nu* 0.2d0)
(defparameter *ks* 19613.3d0)     ; 2000 tonf/m3 -> kN/m3
(defparameter *P* 606.0d0)        ; carga [kN]
(defparameter *ex* 0.15d0)        ; excentricidad en x [m]
(defparameter *ey* 0.30d0)        ; excentricidad en y [m]
(defparameter *n* 4)              ; divisiones por lado

;;; ---------- la matriz de la placa (replicada de shellThin.cpp) ----------
(defun bending-k-mzc (a b e nu tt)
  "K de flexion 12x12 del MZC rectangular. a, b son SEMI-lados."
  (let* ((d0 (/ (* e tt tt tt) (* 12d0 (- 1d0 (* nu nu)))))
         (d11 d0) (d12 (* d0 nu)) (d33 (/ (* d0 (- 1d0 nu)) 2d0))
         (xin  (vector -1d0  1d0 1d0 -1d0))
         (etan (vector -1d0 -1d0 1d0  1d0))
         (gp (vector (- (sqrt 0.6d0)) 0d0 (sqrt 0.6d0)))
         (gw (vector (/ 5d0 9d0) (/ 8d0 9d0) (/ 5d0 9d0)))
         (k (make-array '(12 12) :element-type 'double-float :initial-element 0d0))
         (bb (make-array '(3 12) :element-type 'double-float)))
    (dotimes (ix 3)
      (dotimes (iy 3)
        (let* ((xi (aref gp ix)) (eta (aref gp iy))
               (wi (* (aref gw ix) (aref gw iy)))
               (detj (* a b)))
          (dotimes (r 3) (dotimes (c 12) (setf (aref bb r c) 0d0)))
          (dotimes (i 4)
            (let* ((xi-i (aref xin i)) (eta-i (aref etan i))
                   (xii (* xi-i xi)) (etai (* eta-i eta))
                   (term1 (* (+ 1d0 xii) (+ 1d0 etai)))
                   (t2 (- (+ 2d0 xii etai) (* xi xi) (* eta eta)))
                   (dt1dxi  (* xi-i (+ 1d0 etai)))
                   (dt2dxi  (- xi-i (* 2d0 xi)))
                   (dt1deta (* eta-i (+ 1d0 xii)))
                   (dt2deta (- eta-i (* 2d0 eta)))
                   ;; H1 (para w)
                   (h1xx (* 0.125d0 (+ (* term1 -2d0) (* 2d0 dt1dxi dt2dxi))))
                   (h1yy (* 0.125d0 (+ (* term1 -2d0) (* 2d0 dt1deta dt2deta))))
                   (h1xy (* 0.125d0 (+ (* xi-i eta-i t2) (* dt1dxi dt2deta) (* dt1deta dt2dxi))))
                   ;; H2 (para tx)
                   (h2xx 0d0)
                   (h2yy (* (/ b 8d0) eta-i (+ 1d0 xii) 2d0 (+ (* 3d0 etai) 1d0) eta-i eta-i))
                   (h2xy (* (/ b 8d0) xi-i eta-i eta-i (+ 1d0 etai) (- (* 3d0 etai) 1d0)))
                   ;; H3 (para ty)
                   (h3xx (* (- (/ a 8d0)) xi-i (+ 1d0 etai) 2d0 (+ (* 3d0 xii) 1d0) xi-i xi-i))
                   (h3yy 0d0)
                   (h3xy (* (- (/ a 8d0)) eta-i xi-i xi-i (+ 1d0 xii) (- (* 3d0 xii) 1d0)))
                   (cw (* 3 i)) (ctx (+ (* 3 i) 1)) (cty (+ (* 3 i) 2)))
              (setf (aref bb 0 cw)  (/ (- h1xx) (* a a))
                    (aref bb 1 cw)  (/ (- h1yy) (* b b))
                    (aref bb 2 cw)  (/ (* -2d0 h1xy) (* a b))
                    (aref bb 0 ctx) (/ (- h2xx) (* a a))
                    (aref bb 1 ctx) (/ (- h2yy) (* b b))
                    (aref bb 2 ctx) (/ (* -2d0 h2xy) (* a b))
                    (aref bb 0 cty) (/ (- h3xx) (* a a))
                    (aref bb 1 cty) (/ (- h3yy) (* b b))
                    (aref bb 2 cty) (/ (* -2d0 h3xy) (* a b)))))
          ;; K += w * B^T D B * detJ
          (dotimes (p 12)
            (dotimes (q 12)
              (let* ((b1p (aref bb 0 p)) (b2p (aref bb 1 p)) (b3p (aref bb 2 p))
                     (b1q (aref bb 0 q)) (b2q (aref bb 1 q)) (b3q (aref bb 2 q))
                     (db1 (+ (* d11 b1q) (* d12 b2q)))
                     (db2 (+ (* d12 b1q) (* d11 b2q)))
                     (db3 (* d33 b3q)))
                (incf (aref k p q)
                      (* wi detj (+ (* b1p db1) (* b2p db2) (* b3p db3))))))))))
    k))

;;; ---------- malla ----------
(defun malla ()
  "Devuelve (xs ys) con las lineas de la rejilla."
  (let ((xs (make-array (1+ *n*))) (ys (make-array (1+ *n*))))
    (dotimes (i (1+ *n*))
      (setf (aref xs i) (/ (* *B* i) *n*)
            (aref ys i) (/ (* *L* i) *n*)))
    (values xs ys)))

(defun nudo (i j) (+ (* j (1+ *n*)) i))        ; 0-based

;;; ---------- resolver el sistema (eliminacion de Gauss) ----------
(defun resolver (a f ndof)
  (let ((m (make-array (list ndof (1+ ndof)) :element-type 'double-float)))
    (dotimes (i ndof)
      (dotimes (j ndof) (setf (aref m i j) (aref a i j)))
      (setf (aref m i ndof) (aref f i)))
    (dotimes (c ndof)
      ;; pivote parcial
      (let ((mejor c))
        (loop for r from (1+ c) below ndof
              when (> (abs (aref m r c)) (abs (aref m mejor c))) do (setf mejor r))
        (when (/= mejor c)
          (dotimes (j (1+ ndof))
            (rotatef (aref m c j) (aref m mejor j)))))
      (let ((piv (aref m c c)))
        (when (< (abs piv) 1d-14) (setf piv 1d-14))
        (loop for r from (1+ c) below ndof
              for fac = (/ (aref m r c) piv)
              unless (zerop fac)
              do (loop for j from c to ndof
                       do (decf (aref m r j) (* fac (aref m c j)))))))
    (let ((x (make-array ndof :element-type 'double-float :initial-element 0d0)))
      (loop for i from (1- ndof) downto 0
            do (let ((s (aref m i ndof)))
                 (loop for j from (1+ i) below ndof do (decf s (* (aref m i j) (aref x j))))
                 (setf (aref x i) (/ s (aref m i i)))))
      x)))

;;; ---------- el problema completo ----------
(defun zapata ()
  (multiple-value-bind (xs ys) (malla)
    (let* ((nn (* (1+ *n*) (1+ *n*)))
           (ndof (* 3 nn))
           (dx (/ *B* *n*)) (dy (/ *L* *n*))
           (ke (bending-k-mzc (/ dx 2d0) (/ dy 2d0) *E* *nu* *t*))
           (k0 (make-array (list ndof ndof) :element-type 'double-float :initial-element 0d0))
           (f  (make-array ndof :element-type 'double-float :initial-element 0d0))
           (area (make-array nn :element-type 'double-float :initial-element 0d0)))
      ;; ensamblaje de la placa
      (dotimes (j *n*)
        (dotimes (i *n*)
          (let ((ns (vector (nudo i j) (nudo (1+ i) j) (nudo (1+ i) (1+ j)) (nudo i (1+ j)))))
            (dotimes (p 12)
              (dotimes (q 12)
                (let ((gp (+ (* 3 (aref ns (floor p 3))) (mod p 3)))
                      (gq (+ (* 3 (aref ns (floor q 3))) (mod q 3))))
                  (incf (aref k0 gp gq) (aref ke p q)))))
            ;; area tributaria para el muelle: un cuarto de celda a cada nudo
            (dotimes (v 4) (incf (aref area (aref ns v)) (/ (* dx dy) 4d0))))))
      ;; carga: P en el punto (xc, yc), repartida al elemento que lo contiene
      (let* ((xc (+ (/ *B* 2d0) *ex*)) (yc (+ (/ *L* 2d0) *ey*))
             (ic (min (1- *n*) (floor xc dx))) (jc (min (1- *n*) (floor yc dy)))
             (xl (/ (- xc (* ic dx)) dx)) (yl (/ (- yc (* jc dy)) dy))
             (ns (vector (nudo ic jc) (nudo (1+ ic) jc) (nudo (1+ ic) (1+ jc)) (nudo ic (1+ jc))))
             (nf (vector (* (- 1d0 xl) (- 1d0 yl)) (* xl (- 1d0 yl)) (* xl yl) (* (- 1d0 xl) yl))))
        (dotimes (v 4)
          (decf (aref f (* 3 (aref ns v))) (* *P* (aref nf v)))))   ; hacia abajo
      ;; iteracion de la no linealidad: el muelle que traccione se quita
      (let ((activo (make-array nn :initial-element t))
            (u nil))
        (dotimes (iter 12)
          (let ((k (make-array (list ndof ndof) :element-type 'double-float)))
            (dotimes (p ndof) (dotimes (q ndof) (setf (aref k p q) (aref k0 p q))))
            (dotimes (nd nn)
              (when (aref activo nd)
                (incf (aref k (* 3 nd) (* 3 nd)) (* *ks* (aref area nd))))
              )
            (setf u (resolver k f ndof))
            ;; quien sube (w > 0) no apoya
            (let ((cambio nil))
              (dotimes (nd nn)
                (let ((sube (> (aref u (* 3 nd)) 1d-12)))
                  (when (and (aref activo nd) sube) (setf (aref activo nd) nil cambio t))
                  (when (and (not (aref activo nd)) (not sube)) (setf (aref activo nd) t cambio t))))
              (unless cambio
                (format t "~&convergio en ~a iteraciones~%" (1+ iter))
                (return)))))
        ;; resultados
        (format t "~&~%nudo    x      y      w [mm]     p [kPa]~%")
        (let ((wmin 0d0) (pmax 0d0) (q 0d0))
          (dotimes (j (1+ *n*))
            (dotimes (i (1+ *n*))
              (let* ((nd (nudo i j)) (w (aref u (* 3 nd)))
                     (p (if (and (aref activo nd) (< w 0d0)) (* (- w) *ks*) 0d0)))
                (setf wmin (min wmin w) pmax (max pmax p))
                (incf q (* p (aref area nd)))
                (format t "~4a ~6,3f ~6,3f ~10,4f ~10,3f~%"
                        (1+ nd) (aref xs i) (aref ys j) (* w 1000d0) p))))
          (format t "~%w_min = ~,4f mm   p_max = ~,3f kPa~%" (* wmin 1000d0) pmax)
          (format t "suma de los muelles = ~,2f kN   (P = ~,2f kN)~%" q *P*)
          (format t "nudos levantados = ~a de ~a~%"
                  (count nil activo) nn))))))

(zapata)
