;# The area under a parabola
;| A Hekatan LISP document: *text*, _symbolic operation_ and plot together.

;## 1. The function
;< We study the parabola  f = {f}  on the interval [0, 1].
f = x^2

;## 2. Symbolic operations
;< Its slope (derivative) evaluated at  x = 1  is:
$slope{x^2 @ x = 1}
;< The exact area under the curve between 0 and 1 (definite integral):
$area{x^2 @ x = 0 : 1}

;## 3. The plot
;< The curve  f = x²  whose area we just computed:
;fplot(x^2, [0 1])

;## 4. Conclusion
;| The area under  *f = x²*  between 0 and 1 is exactly  1/3.
