# Por qué se deriva: el equilibrio de un TROCITO
#: La viga tiene infinitos puntos y el cortante cambia en cada uno. No se puede plantear el equilibrio de todo a la vez. Se corta un trozo de longitud dx y se le aplica el equilibrio de siempre.

## Lo que ENTRA por la cara izquierda y lo que SALE por la derecha
e_iz = V @@(cortante que entra)
e_de = V + dV @@(el que sale, un poco distinto)
m_iz = M @@(momento que entra)
m_de = M + dM @@(el que sale)
c_ar = q·dx @@(la carga que cae encima del trocito)

## EQUILIBRIO VERTICAL: todo lo que sube menos todo lo que baja
eq_v = V - (V + dV) - q·dx = 0

## Se despeja y sale la PRIMERA ley
ley_1 = Simplify{V - (V + dV) - q·dx}
dV_dx = dV/dx = -q

## EQUILIBRIO DE MOMENTOS, tomando la cara derecha
eq_m = M + dM - M - V·dx + q·dx·dx/2 = 0

## Aquí está el truco: el término con dx AL CUADRADO
t_2 = q·dx^2/2 @@(infinitésimo de SEGUNDO orden)

## Con dx = 1 cm, dx vale 0.01 y dx al cuadrado vale
val_1 = 1/100
val_2 = (1/100)^2/2

## Es doscientas veces menor: se desprecia
raz = (1/100)/((1/100)^2/2)

## Y queda la SEGUNDA ley
ley_2 = Simplify{dM - V·dx}
dM_dx = dM/dx = V
