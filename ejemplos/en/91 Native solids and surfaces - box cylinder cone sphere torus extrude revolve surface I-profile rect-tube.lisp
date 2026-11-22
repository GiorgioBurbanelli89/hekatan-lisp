# Native solids and surfaces: caja, cilindro, cono, esfera, toro, extruir, revolucion, superficie, perfil-i, tubo-rect
#: They come with the engine: they are used in any sheet, without copying code. Each command draws a solid as a **closed mesh of 3DFACE faces** and returns how many faces it used. Details with keys, like the other drawing functions: `:color` (ACI number or name) and `:capa`.
#: **Limit:** an AutoCAD 3DSOLID is a proprietary ACIS model; here the solid can be seen, rotated and exported to DXF and DWG, but AutoCAD opens it as faces and not as an editable solid.

#autolisp("The eleven commands", ancho = 240, alto = 150, exporta = nCaja nCil nCono nEsf nToro nExt nRev nSup nViga nTubo nLosa nTotal)
(defun domo (x y) (max 0.0 (* 1.4 (- 1.0 (+ (* (- x 1.0) (- x 1.0)) (* (- y 1.0) (- y 1.0)))))))
(setq nCaja (caja '(0 0 0) 2 1.2 1 :color 5 :capa "CAJA"))
(setq nCil  (cilindro '(3.6 0.6 0) 0.6 1.6 :color 3 :capa "CILINDRO"))
(setq nCono (cono '(5.3 0.6 0) 0.6 1.5 :color "naranja" :capa "CONO"))
(setq nEsf  (esfera '(7.0 0.6 0.6) 0.6 :color 1 :capa "ESFERA"))
(setq nToro (toro '(9.0 0.9 0.35) 0.6 0.25 :color 4 :capa "TORO"))
(setq nExt  (extruir '((0 3 0) (2.4 3 0) (2.4 4 0) (1 4 0) (1 5.4 0) (0 5.4 0)) 0.35 :color 2 :capa "LOSA-L"))
(setq nRev  (revolucion '(4 4.2 0) '((0 0) (0.6 0) (0.8 0.4) (0.45 0.9) (0.35 1.3) (0.55 1.7) (0.6 1.8)) :color 6 :capa "JARRON"))
(setq nSup  (superficie 'domo '(6 3.2 0) 0 2 0 2 :nx 20 :ny 20 :capa "SUPERFICIE"))
(setq nViga (perfil-i '(0 7.4 0) 0.6 0.35 0.05 0.03 4 :color "gris" :capa "VIGA-I"))
(setq nTubo (tubo-rect '(5 7.4 0) 0.7 0.7 0.07 3 :color "azul" :capa "TUBO"))
(setq nLosa (losa '(8.6 6.6 0) 2 1.6 0.2 :color 9 :capa "LOSA"))
(setq nTotal (sslength (ssget "_X" '((0 . "3DFACE")))))
#fin
#: Faces per command: caja @{nCaja}, cilindro @{nCil}, cono @{nCono}, esfera @{nEsf}, toro @{nToro}, extruir (L slab) @{nExt}, revolution @{nRev}, surface @{nSup}, I profile @{nViga}, tube @{nTubo}, slab @{nLosa}. Read back from the drawing with ssget: **@{nTotal}** 3DFACE faces.
#: **Usage:** `(caja '(x y z) dx dy dz)` · `(cilindro centro radio altura)` · `(cono centro radio altura :r2 radio-arriba)` · `(esfera centro radio)` · `(toro centro radio-aro radio-tubo)` · `(extruir contorno altura)` · `(revolucion centro perfil)` with perfil = ((r z) …) · `(superficie 'f origen x0 x1 y0 y1)` · `(perfil-i p d bf tf tw largo)` · `(tubo-rect p b h espesor largo)` · `(losa p dx dy espesor)`. The extrusion caps any simple contour, also concave (L, U, T).
