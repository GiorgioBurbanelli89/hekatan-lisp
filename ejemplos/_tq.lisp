# prueba
P1(x) = 1 - x^2·(3 - 2·x)
a_0 = P1(0)
a_1 = P1(1)
P3(x) = x^2·(3 - 2·x)
b_1 = P3(1)
F_w = A·B·q·Integral{Integral{(1 - xi^2·(3 - 2·xi))·(1 - eta^2·(3 - 2·eta)) @ xi = 0 : 1} @ eta = 0 : 1}
F_tx = A·B·q·Integral{Integral{xi·A·(1 - xi·(2 - xi))·(1 - eta^2·(3 - 2·eta)) @ xi = 0 : 1} @ eta = 0 : 1}
