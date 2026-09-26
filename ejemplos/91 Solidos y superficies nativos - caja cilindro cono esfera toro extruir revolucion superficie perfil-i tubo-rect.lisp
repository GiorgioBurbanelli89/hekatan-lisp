# Sólidos y superficies nativos: caja, cilindro, cono, esfera, toro, extruir, revolucion, superficie, perfil-i, tubo-rect
#: Ya vienen con el motor: se usan en cualquier hoja, sin copiar código. Cada comando dibuja un sólido como **malla cerrada de caras 3DFACE** y devuelve cuántas caras usó. Detalles con claves, como las demás funciones de dibujo: `:color` (número ACI o nombre) y `:capa`.
#: **Límite:** un 3DSOLID de AutoCAD es un modelo ACIS propietario; aquí el sólido se ve, se gira y se exporta a DXF y DWG, pero AutoCAD lo abre como caras y no como sólido editable.

#autolisp("Los once comandos", ancho = 240, alto = 150, exporta = nCaja nCil nCono nEsf nToro nExt nRev nSup nViga nTubo nLosa nTotal)
(defun domo (x y) (max 0.0 (* 1.4 (- 1.0 (+ (* (- x 1.0) (- x 1.0)) (* (- y 1.0) (- y 1.0)))))))
(setq nCaja (caja '(0 0 0) 2 1.2 1 :color 5 :capa "CAJA"))
(setq nCil  (cilindro '(3.6 0.6 0) 0.6 1.6 :color 3 :capa "CILINDRO"))
(setq nCono (cono '(5.3 0.6 0) 0.6 1.5 :color "naranja" :capa "CONO"))
(setq nEsf  (esfera '(7.0 0.6 0.6) 0.6 :color 1 :capa "ESFERA"))
(setq nToro (toro '(9.0 0.9 0.35) 0.6 0.25 :color 4 :capa "TORO"))
(setq nExt  (extruir '((0 3 0) (2.4 3 0) (2.4 4 0) (1 4 0) (1 5.4 0) (0 5.4 0)) 0.35 :color 2 :capa "LOSA-L"))
(setq nRev  (revolucion '(4 4.2 0) '((0 0) (0.6 0) (0.8 0.4) (0.45 0.9) (0.35 1.3) (0.55 1.7) (0.6 1.8)) :color 6 :capa "JARRON"))
(setq nSup  (superficie 'domo 0 2 0 2 :c '(6 3.2 0) :nx 20 :ny 20 :capa "SUPERFICIE"))
(setq nViga (perfil-i '(0 7.4 0) 0.6 0.35 0.05 0.03 4 :color "gris" :capa "VIGA-I"))
(setq nTubo (tubo-rect '(5 7.4 0) 0.7 0.7 0.07 3 :color "azul" :capa "TUBO"))
(setq nLosa (losa '(8.6 6.6 0) 2 1.6 0.2 :color 9 :capa "LOSA"))
(setq nTotal (sslength (ssget "_X" '((0 . "3DFACE")))))
#fin
#: Caras por comando: caja @{nCaja}, cilindro @{nCil}, cono @{nCono}, esfera @{nEsf}, toro @{nToro}, extruir (losa en L) @{nExt}, revolución @{nRev}, superficie @{nSup}, perfil I @{nViga}, tubo @{nTubo}, losa @{nLosa}. Leídas de vuelta del dibujo con ssget: **@{nTotal}** caras 3DFACE.
#: **Uso:** `(caja '(x y z) dx dy dz)` · `(cilindro centro radio altura)` · `(cono centro radio altura :r2 radio-arriba)` · `(esfera centro radio)` · `(toro centro radio-aro radio-tubo)` · `(extruir contorno altura)` · `(revolucion centro perfil)` con perfil = ((r z) …) · `(superficie 'f x0 x1 y0 y1 :c origen)` · `(perfil-i p d bf tf tw largo)` · `(tubo-rect p b h espesor largo)` · `(losa p dx dy espesor)`. La extrusión tapa cualquier contorno simple, también cóncavo (L, U, T).
