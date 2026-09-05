# Doble integral
## anidada directa
I_1 = Area{Area{xi^2·eta^2 @ xi=-1:1} @ eta=-1:1}
## por partes
I_a = Area{xi^2 @ xi=-1:1}
I_b = Area{(2/3)·eta^2 @ eta=-1:1}
## base de Kirchhoff, doce terminos
b_k = [1 x y x^2 x·y y^2 x^3 x^2·y x·y^2 y^3 x^3·y x·y^3]
