# La zapata del ejemplo 6.10 de Das, en 2D: de la fórmula al elemento finito

#: Misma zapata de las hojas 48 y 54, ahora mirada **en planta**. Se compara lo que da la FÓRMULA (reparto lineal, zapata rígida) con lo que da el ELEMENTO FINITO del modelo de Hekatan Struct (placa flexible sobre muelles que no tiran). El mapa de color se recorre con el cursor: al pasar por encima sale el valor en ese punto.
#: Braja M. Das, *Principles of Foundation Engineering*, 9.ª ed. (2019), ejemplo 6.10, p. 247-248 · ed. española: *Fundamentos de ingeniería de cimentaciones*, 7.ª ed., ejemplo 3.8.

## 1 · Los datos

#| Dato | Valor | Dato | Valor |
#|---|---:|---|---:|
#| B (en x) | 1.50 m | P | 606 kN |
#| L (en y) | 1.50 m | e_{x} | 0.15 m |
#| espesor t | 0.40 m | e_{y} | 0.30 m |
#| columna c | 0.30 m | f'_{c} | 240 kgf/cm^{2} |
#| k_{s} | 2000 tonf/m^{3} | malla | 4 x 4 |

#: El módulo del hormigón por ACI 318, y el balasto pasado al SI:
E_c = 15100*240^0.5kgf/cm^2|kN/m^2
k_s = 2000tonf/m^3|kN/m^3

## 2 · La fórmula: el reparto lineal

#: Si la zapata fuese INFINITAMENTE RÍGIDA la presión se reparte con un plano. Primero en letras, la presión media y el plano completo:
sigma_prom = P/(B*L)
#: Y el plano, con las dos excentricidades; x e y se miden desde el centro:
sigma = sigma_prom*(1 + 12*e_x*x/B^2 + 12*e_y*y/L^2)
#: Con los números. La media:
sigma_prom = 606kN/(1.5m*1.5m)|kPa
#: Y en la esquina más cargada, x = y = 0.75 m:
sigma_esq = 269.33kPa*(1 + 12*0.15*0.75/1.5^2 + 12*0.3*0.75/1.5^2)|kPa

## 3 · El mapa de la fórmula

#: El plano de presiones sobre la planta de la zapata, en kPa. x e y van de 0 a 1.5 m, medidos desde la esquina. **Pasa el cursor por encima**: sale el valor.
#map(269.3*(1 + 12*0.15*(x-0.75)/2.25 + 12*0.3*(y-0.75)/2.25), [0 1.5], [0 1.5])

#: Se ve el gradiente: la esquina de abajo a la izquierda es la descargada y la de arriba a la derecha la que se lleva todo. Pero ese plano tiene un problema.

## 4 · El suelo no tira: la no linealidad

#: El plano de arriba da presión NEGATIVA en la esquina descargada, y eso significa que el suelo estaría tirando de la zapata hacia abajo. No puede. Donde el plano sale negativo, la zapata **se despega**: ahí la presión es cero y esa parte de la carga se la reparten las zonas que sí apoyan.
#: La condición, escrita corta: se toma la presión solo si empuja. La parte positiva de un número es él mismo sumado a su valor absoluto, partido por dos — si es negativo se cancelan y queda cero.
sigma_real = (sigma + abs(sigma))/2
#: El mismo mapa con esa condición. La zona azul PLANA, toda del mismo tono, es la que **está levantada**: presión cero. Compárala con el mapa de arriba, donde ahí seguía bajando.
#map((269.3333*(1 + 12*0.15*(x-0.75)/2.25 + 12*0.3*(y-0.75)/2.25) + abs(269.3333*(1 + 12*0.15*(x-0.75)/2.25 + 12*0.3*(y-0.75)/2.25)))/2, [0 1.5], [0 1.5])
#: La escala llega al mismo máximo que antes, 754 kPa, pero ahora el mínimo es CERO y no un número negativo: el suelo no tira.

## 5 · Lo que da el elemento finito

#: El modelo de Hekatan Struct no supone la zapata rígida: la malla con placa de Mindlin (Shell-Thick), un muelle de Winkler por nudo que solo trabaja a compresión, y la carga repartida en la huella de la columna. Con la malla 4 x 4 (42 nudos, 30 elementos) sale esto:

#| Punto | x, y [m] | Asiento [mm] | Presión [kPa] |
#|---|---|---:|---:|
#| Esquina cargada | 1.50 , 1.50 | -36.26 | 711.2 |
#| Centro | 0.75 , 0.75 | -16.73 | 328.1 |
#| Esquina descargada | 0.00 , 0.00 | **+5.11** | 0.0 |
#| Borde | 1.50 , 0.00 | **+1.26** | 0.0 |

#: El signo positivo es LEVANTAMIENTO: esos nudos suben, no apoyan. Tres de los cuarenta y dos se despegan.
#: Y la comparación en la esquina más cargada, fórmula contra elemento finito:
dif = dec((754.0 - 711.2)/754.0*100, 1)
#: La fórmula da un 5.7 % más. No es un error de ninguno de los dos: la fórmula reparte sobre una zapata RÍGIDA, y ésta, con 40 cm de canto y 1.5 m de lado, flexa. Al flexar se lleva carga hacia el centro y la punta se descarga.

## 6 · Por qué flexa: la rigidez relativa

#: El criterio es la rigidez de la zapata frente a la del terreno. Con el módulo del hormigón y el del suelo:
k_rel = dec(22940519/19613.3*(0.4/1.5)^3, 2)
#: Por encima de 1 la zapata se comporta como rígida y la fórmula del plano vale. Aquí sale muy por encima, así que las dos deberían parecerse — y se parecen en un 5.7 %. Lo que separa a las dos no es la flexión: es **el levantamiento**, que la fórmula del plano no sabe hacer y el elemento finito sí.
