# Sólidos y superficies como AutoCAD
#: Los comandos 3D de AutoCAD —**BOX, CYLINDER, SPHERE, EXTRUDE, REVOLVE** y las superficies z = f(x, y)— son funciones simples de la capa de dibujo: **caja, cilindro, esfera, extruir, revolucion, superficie**. Cada una arma el sólido con caras 3DFACE (una malla cerrada), en su capa y con su color, y devuelve cuántas caras dibujó.
#: **Límite honesto:** un 3DSOLID verdadero de AutoCAD guarda un modelo ACIS propietario; aquí el sólido es una **malla de caras**, que se ve, se gira y se exporta a DXF y DWG, pero en AutoCAD se abre como caras y no como sólido editable.

## La cúpula: una función de la hoja
domo(x, y) = 1.4*cos(pi*(x - 1)/2)*cos(pi*(y - 1)/2)

#autolisp("Escena: caja, cilindro, esfera, losa en L, jarrón y cúpula", ancho = 200, alto = 130, exporta = nCaja nCil nEsf nExt nRev nSup nTotal)
(setq nCaja (caja '(0 0 0) 2 1.2 1 :capa "CAJA" :color 5))
(setq nCil (cilindro '(3.6 0.6 0) 0.6 1.6 :capa "CILINDRO" :color 3))
(setq nEsf (esfera '(5.4 0.6 0.6) 0.6 :capa "ESFERA" :color 1))
(setq nExt (extruir '((0 3) (2.4 3) (2.4 4) (1 4) (1 5.4) (0 5.4)) 0.35 :capa "EXTRUSION" :color 2))
(setq nRev (revolucion '(4 4.2 0) '((0 0) (0.6 0) (0.8 0.4) (0.45 0.9) (0.35 1.3) (0.55 1.7) (0.6 1.8)) :capa "REVOLUCION" :color 6))
(setq nSup (superficie domo '(5.6 3.2 0) 0 2 0 2 :desde 0 :capa "SUPERFICIE"))
(setq nTotal (sslength (ssget "_X" '((0 . "3DFACE")))))
#fin
#: Caras dibujadas: caja **@{nCaja}**, cilindro **@{nCil}**, esfera **@{nEsf}**, losa en L **@{nExt}**, jarrón **@{nRev}**, cúpula **@{nSup}**. Leídas de vuelta del dibujo: **@{nTotal}** caras 3DFACE en total.
#: **Cómo se escribe** (los mismos datos que pide AutoCAD): `(caja '(x y z) dx dy dz)` · `(cilindro centro radio altura)` · `(esfera centro radio)` · `(extruir contorno altura)` · `(revolucion centro perfil)` · `(superficie f centro x0 x1 y0 y1)`. Opcionales: `:capa "NOMBRE"` `:color n` `:lados n` `:meridianos n` `:paralelos n` `:nx n` `:ny n` `:desde z`. También hay `cono`, `toro`, `losa`, `perfil-i` y `tubo-rect` (ejemplo 91).
