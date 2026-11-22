# Text formatting in Hekatan LISP
#: A line that starts with **#** is text. Everything else is math that gets calculated. This is how the calculation is explained in the same sheet.

## Headings
#: **#** title · **##** subtitle · **###** section.

### This is a section

## Alignment
#< Este texto va a la izquierda
#| Este texto va centrado
#> Este texto va a la derecha

## Styles
#: Double asterisk for **bold** and a single one for *italic*.

## Sheet values inside the text
A = (x + 1)^2
b = 12 'base, cm
h = 30 'height, cm
I = b*h^3/12 'moment of inertia, cm⁴
#: The at-sign puts the value inside the sentence: the section of @b by @h has @I.

## Line comment
#: After the apostrophe goes the description of each datum, as in b and h above.
