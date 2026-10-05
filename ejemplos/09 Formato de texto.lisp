# Formato de texto en Hekatan LISP
#: Una línea que empieza con **#** es texto. Lo demás es matemática que se calcula. Así se explica el cálculo en la misma hoja.

## Títulos
#: **#** título · **##** subtítulo · **###** apartado.

### Esto es un apartado

## Alineación
#< Este texto va a la izquierda
#| Este texto va centrado
#> Este texto va a la derecha

## Estilos
#: Doble asterisco para **negrita** y uno para *cursiva*.

## Valores de la hoja dentro del texto
A = (x + 1)^2
b = 12 'base, cm
h = 30 'altura, cm
I = b*h^3/12 'inercia, cm⁴
#: La arroba pone el valor dentro de la frase: la sección de @b por @h tiene @I.

## Comentario de línea
#: Después del apóstrofo va la descripción de cada dato, como en b y h de arriba.
