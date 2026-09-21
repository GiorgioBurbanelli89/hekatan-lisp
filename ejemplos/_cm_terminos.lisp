# Puentes: los símbolos que hacen falta para las líneas de influencia
#: Medidas del ejemplo: alcantarilla cajón de dos celdas de 9.50 m de luz y 6.00 m de alto. Vehículo: camión de diseño de la norma, de 35, 145 y 145 kN.

## 1 · La luz y el largo
L_c = 9.5
L = dec(2*L_c, 2)

## 2 · Dónde cae cada eje
#: Con x_{F} la abscisa del eje delantero y d_{k} la separación del eje k a ese delantero:
x_k = x_F - d_k
d_2 = 4.3
d_3 = 8.6

#salto
## 3 · Fuerza por distancia es momento
M = P*d
P = 145
d = 2.0
M = dec(P*d, 1)

## 4 · Las unidades
tonf = dec(1000*9.80665/1000, 5)
P_tonf = dec(145/9.80665, 2)
M_tonf = dec(290/9.80665, 2)

#salto
## 5 · La carga de carril y el impacto
w = 9.3
IM = 33
P_din = dec(145*(1 + IM/100), 1)
