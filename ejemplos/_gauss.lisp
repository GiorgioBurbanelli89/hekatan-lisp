# Cuadratura de Gauss
regla = Integral{f @ xi} = w_1·f_1 + w_2·f_2
xi_g = 1/sqrt(3)
exacta = Integral{xi^2 @ xi = -1:1}
gauss = 1·(1/sqrt(3))^2 + 1·(-1/sqrt(3))^2
