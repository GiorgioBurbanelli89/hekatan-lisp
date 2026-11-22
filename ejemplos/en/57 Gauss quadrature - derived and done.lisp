# Gauss quadrature, derived and done
## In the previous chapter it was established that all the calculation is done on the standard span, from minus one to plus one. And a question remained: why exactly there?
## Because there is where Gauss quadrature is defined. And quadrature is this: replacing an integral by a SUM.
regla = Integral{f @ xi} = w_1·f_1 + w_2·f_2
## The function is evaluated at a few points, each value is multiplied by its weight, and they are added. Nothing more.
## Before Gauss the trapezoidal rule was used: the points FIXED at the ends, and only the weights free.
libres_trapecio = 0 + 2
## With two free numbers only two conditions can be demanded: it is right up to straight lines and there it ends.
## Gauss releases the points: if they are also unknowns, there are FOUR free numbers.
libres_gauss = 2 + 2
## And each free number allows demanding one condition. Double the freedom, double the degree.
## The four conditions: that the sum gives the EXACT area of the four bricks from which any curve is built.
c_1 = w_1 + w_2 = 2
c_2 = w_1·xi_1 + w_2·xi_2 = 0
c_3 = w_1·xi_1^2 + w_2·xi_2^2 = 2/3
c_4 = w_1·xi_1^3 + w_2·xi_2^3 = 0
## Nobody ASSUMES that the points are symmetric: it comes out by itself. From the fourth condition the second multiplied by the first point squared is subtracted.
paso_1 = w_2·xi_2·(xi_2^2 - xi_1^2) = 0
## Neither the weight nor the point can be zero, so what vanishes is the parenthesis.
paso_2 = xi_2 = -xi_1
## With that the second condition says the weights are equal, and the first that they are worth one.
paso_3 = w_1 = w_2 = 1
## And only then does the third condition deliver the number.
paso_4 = 2·xi_1^2 = 2/3
sol = sqrt(1/3)
## Now the real calculation, with the curvature of the first shape function, which is the one that builds the stiffness matrix.
H1pp = Diff{-6·x + 6·x^2 @ x}
## Moved to the standard span it comes out clean.
H1pp_nat = Expand{-6 + 12·(1 + xi)/2}
## And the Jacobian of the previous chapter, for a span of length one, is one half.
jac = J = 1/2
## What has to be integrated is the square of that curvature times the Jacobian.
integrando = (6·xi)^2·(1/2)
## The exact integral, done by hand, gives twelve.
exacta = Area{18·xi^2 @ xi=-1:1}
## And now THE SUM of Gauss: two points, both weights are one, and each point squared is one third.
gauss = 18·(1/3) + 18·(1/3)
## Twelve against twelve. It does not approximate: it is exactly right.
## With the pair of the first and the second function the same happens.
prod = 6·xi·(-1 + 3·xi)·(1/2)
exacta_12 = Area{-3·xi + 9·xi^2 @ xi=-1:1}
gauss_12 = (-3/sqrt(3) + 9/3) + (3/sqrt(3) + 9/3)
## Six and six. And that twelve and that six are those of the beam stiffness matrix.
K_barra = [12, 6, -12, 6; 6, 4, -6, 2; -12, -6, 12, -6; 6, 2, -6, 4]
## The proof that it is a LAW and not a coincidence: with xi to the fourth it already fails.
exacta_4 = Area{xi^4 @ xi=-1:1}
gauss_4 = (1/3)^2 + (1/3)^2
## Two fifths against two ninths. It fails exactly where it had to fail: at degree four.
ley = 2·n - 1
