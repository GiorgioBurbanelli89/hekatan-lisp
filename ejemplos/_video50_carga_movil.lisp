# Carga móvil HL-93: la hoja del vídeo
#: Resumen de la hoja 50 publicada en Hekatan LISP web. Los números son los de la alcantarilla del ejemplo público: 2 celdas de 3.0 x 2.5 m, losas y muros de 0.30 m, franja de 1 m.

## 1 · El camión en letras
#: Tres ejes seguidos. El delantero manda y los otros van detrás:
x_k = x_F - d_k
#: El peso total es la suma de los tres:
P_tot = P_1 + P_2 + P_3

## 2 · La idea: superposición
#: El modelo es lineal, así que la respuesta a varias cargas es la SUMA de las respuestas a cada una. Se resuelve una vez por nudo con 1 kN y se suma:
R = P_1*IL_1 + P_2*IL_2 + P_3*IL_3

## 3 · Los factores
#: La carga que entra al modelo lleva el impacto y va dividida por el ancho de reparto:
P_k = P_norma*(1 + IM_x/100)/E_x
#: Y el rótulo de la pantalla es esa carga en tonf:
rotulo = P_k/9.80665

#salto
## 4 · Con números
P_1 = 35
P_2 = 145
P_3 = 145
a_1 = 4.3
P_tot = dec(P_1 + P_2 + P_3, 1)
#: Con el impacto en 0 % y el ancho en 1 m, los rótulos de la pantalla:
rot_trasero = dec(145*(1 + 0/100)/1/9.80665, 2)
rot_delantero = dec(35*(1 + 0/100)/1/9.80665, 2)
#: El momento en el centro de la celda 1 cuando el eje delantero está en 5.8 m. Los tres ejes caen en 5.8, en 1.5 y en -2.8: el tercero todavía NO ha entrado, así que no carga.
IL_a = -0.04181757
IL_b = 0.49139978
IL_c = 0
R_max = dec(35*IL_a + 145*IL_b + 145*IL_c, 4)
#: El motor, resolviendo el pórtico entero, da 69.7894 kN·m. Cifra a cifra.
R_tonf = dec(R_max/9.80665, 3)

## 5 · La rigidez del elemento
#: Todo el cálculo es una sola ecuación, rigidez por desplazamiento igual a fuerza:
f = K*u
#: El motor es Timoshenko. Para una sección rectangular, el número que mide el cortante sale solo de la esbeltez:
phi = 12*(1 + nu)/5*(t/L)^2
#: Con ν = 0.2, canto 0.30 m y elementos de 0.1 m:
phi_el = dec(12*(1 + 0.2)/5*(0.30/0.1)^2, 2)

#salto
## 6 · La envolvente y la línea de influencia
#: La envolvente es el peor de todas las posiciones, con la separación trasera de 4.3 a 9.0 m: 8184 posiciones. Camión más carril:
M3_max = 77.32
M3_min = -89.61
Uz_min = -6.520
#: La línea de influencia del momento en el centro de la celda 1 (61 casos unitarios del motor):
#fplot(IL_centro = [0 0.0002; 0.5 0.1083; 1 0.2712; 1.5 0.4914; 2 0.2717; 2.5 0.1147; 3 0.023; 3.5 -0.023; 4 -0.0489; 4.5 -0.0589; 5 -0.0574; 5.5 -0.0487; 6 -0.0371], [0 6])
#: Contra SAP2000, esta alcantarilla da 0.0000 % en Ux, Uz, Ry, P, V2 y M3 en las 147 posiciones.
