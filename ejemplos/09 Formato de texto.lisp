;# Formato de texto en Hekatan LISP
;| Todo esto vive dentro de *comentarios* ( ; ) — al ejecutar el .lisp NO se ve.
;| Solo Hekatan LISP lo dibuja. Sirve para explicar tus cálculos.

;## Alineación
;< Este texto va a la IZQUIERDA
;| Este texto va CENTRADO
;> Este texto va a la DERECHA

;## Estilos y variables
;: Puedes combinar *negrita*, _cursiva_ y {variables} de la hoja.
A = (x + 1)^2
B = x^2 - 1
;: El cuadrado del binomio es  A = {A}  y la diferencia  B = {B}.

;## Directivas
;: ;#  Título        ;##  Subtítulo
;: ;<  izquierda     ;>  derecha      ;|  ó  ;=  centrado
;: ;:  ó  ;-  párrafo normal
;: inline:  *negrita*   _cursiva_   {Variable}
