# Solids and surfaces like AutoCAD
#: The AutoCAD 3D commands —**BOX, CYLINDER, SPHERE, EXTRUDE, REVOLVE** and the surfaces z = f(x, y)— are simple functions of the drawing layer: **caja, cilindro, esfera, extruir, revolucion, superficie**. Each one builds the solid with 3DFACE faces (a closed mesh), on its layer and with its color, and returns how many faces it drew.
#: **Honest limit:** a true AutoCAD 3DSOLID stores a proprietary ACIS model; here the solid is a **mesh of faces**, which can be seen, rotated and exported to DXF and DWG, but in AutoCAD it opens as faces and not as an editable solid.

## The dome: a function of the sheet
domo(x, y) = 1.4*cos(pi*(x - 1)/2)*cos(pi*(y - 1)/2)

#autolisp("Scene: box, cylinder, sphere, L slab, vase and dome", ancho = 200, alto = 130, exporta = nCaja nCil nEsf nExt nRev nSup nTotal)
(setq nCaja (caja '(0 0 0) 2 1.2 1 :capa "CAJA" :color 5))
(setq nCil (cilindro '(3.6 0.6 0) 0.6 1.6 :capa "CILINDRO" :color 3))
(setq nEsf (esfera '(5.4 0.6 0.6) 0.6 :capa "ESFERA" :color 1))
(setq nExt (extruir '((0 3) (2.4 3) (2.4 4) (1 4) (1 5.4) (0 5.4)) 0.35 :capa "EXTRUSION" :color 2))
(setq nRev (revolucion '(4 4.2 0) '((0 0) (0.6 0) (0.8 0.4) (0.45 0.9) (0.35 1.3) (0.55 1.7) (0.6 1.8)) :capa "REVOLUCION" :color 6))
(setq nSup (superficie domo '(5.6 3.2 0) 0 2 0 2 :desde 0 :capa "SUPERFICIE"))
(setq nTotal (sslength (ssget "_X" '((0 . "3DFACE")))))
#fin
#: Faces drawn: box **@{nCaja}**, cylinder **@{nCil}**, sphere **@{nEsf}**, L slab **@{nExt}**, vase **@{nRev}**, dome **@{nSup}**. Read back from the drawing: **@{nTotal}** 3DFACE faces in total.
#: **How it is written** (the same data AutoCAD asks for): `(caja '(x y z) dx dy dz)` · `(cilindro centro radio altura)` · `(esfera centro radio)` · `(extruir contorno altura)` · `(revolucion centro perfil)` · `(superficie f centro x0 x1 y0 y1)`. Optional: `:capa "NAME"` `:color n` `:lados n` `:meridianos n` `:paralelos n` `:nx n` `:ny n` `:desde z`. There are also `cono`, `toro`, `losa`, `perfil-i` and `tubo-rect` (example 91).
