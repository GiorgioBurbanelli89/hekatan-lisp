# De donde sale la constitutiva
## Hooke en 2D: la deformacion en x tiene DOS causas, la tension de x y la de y
e_x = (s_x - nu·s_y)/E
e_y = (s_y - nu·s_x)/E
## Multiplico la primera por E y la segunda por nu·E, y las SUMO
suma = Expand{(s_x - nu·s_y) + nu·(s_y - nu·s_x)}
## El termino de s_y se cancela solo
## Comprobacion del cortante: el termino de la esquina ES el modulo de cortante
cort = Expand{(1 - nu)/(2·(1 - nu^2))}
## Con nu = 0.15 en fracciones: uno menos nu es 17/20, y uno menos nu al cuadrado es 391/400
c_1 = (17/20)·400/(2·391)
## Y el modulo de cortante, uno partido para dos por uno mas nu
c_2 = 400/(2·460)
