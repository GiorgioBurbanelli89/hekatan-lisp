# Welcome to Hekatan LISP
#: You type on the left; on the right the math comes out already calculated and drawn. There are three kinds of line:
#: **#** in front is text · nothing in front is math · **;** in front is pure LISP.

## 1 · Data and formulas
L = 6 'beam length, m
q = 10 'distributed load, kN/m
M = q*L^2/8 'maximum moment of a simply supported beam, kN·m

## 2 · Symbolic operations
f(x) = x^3 - 2*x
Derivate{f(x) @ x}
Integral{f(x) @ x}
Area{f(x) @ x = 0 : 2}

## 3 · Inside, it is LISP
#: Each formula becomes a list: x³ − 2x is (- (expt x 3) (* 2 x)). Above, under **result as**, the **LISP** button shows the whole sheet as lists and **3 forms** puts the math, the LISP and the MATLAB side by side.

#: Open the other examples (**Examples** menu) and change the data: the sheet recalculates by itself.
