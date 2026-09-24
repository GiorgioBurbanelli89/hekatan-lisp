# Bitácora — dibujo AutoLISP en Hekatan LISP (rama `autolisp-dibujo`)

Pedido (Jorge, 24-sep-2026): dibujar al estilo AutoLISP (entmake/ssget/entget con listas DXF)
y mezclarlo con el cálculo simbólico. Capa simple en español encima. Guardar DXF.

Principio: **el código es la lista de datos**. Una entidad ES una lista de asociación DXF
normal de LISP: se arma con list/cons/mapcar, se transforma con funciones, y `entmake`
la pone en el dibujo. Leer lo dibujado (`ssget`/`entget`/`assoc`) devuelve listas con las
que se sigue calculando.

## Base
- Worktree creado de `main` (a803916) pero `main` NO tiene la hoja 70 (#dibujo con cargas)
  ni `HojaNumerica.cs`: están en `placa-base-voladizo` (8c4b0b1). Rama re-basada allí.

## Fuentes de la semántica (no de memoria)
- entmake (AutoLISP Reference 2024, Autodesk): devuelve la lista si crea la entidad, `nil`
  si falta un dato obligatorio; lo opcional (capa…) toma el valor por defecto; **ignora el
  código 100** por compatibilidad.
  https://help.autodesk.com/cloudhelp/2024/ENU/AutoCAD-AutoLISP-Reference/files/GUID-D47983BA-1E5D-417D-85B8-6F3DE5F506BA.htm
- Ángulos: en las listas de AutoLISP (entget/entmake) los códigos 50/51 van en **radianes**
  (p. ej. `(50 . 5.96143)`); en el fichero .DXF van en grados. Aquí igual: lista = radianes,
  el escritor DXF los pasa a grados.
- Códigos DXF (DXF Reference de AutoCAD): 0 tipo, 5 handle, 8 capa, 6 tipo de línea,
  62 color ACI (256 = PORCAPA), 370 grosor (centésimas de mm), 10/11 puntos, 40 radio o
  altura, 1 texto, 50/51 ángulos, 72/73 alineación de TEXT, 71 anclaje de MTEXT,
  90 nº vértices y 70 cerrada de LWPOLYLINE, 42 abultamiento, 13/14 orígenes de las
  líneas de referencia de DIMENSION, 42 medida, 70 tipo (0 girada, 1 alineada, +32).

## Registro
