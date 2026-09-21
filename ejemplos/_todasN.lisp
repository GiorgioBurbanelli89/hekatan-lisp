# Las CUATRO funciones de forma y TODAS sus derivadas
## Éstas son las cuatro, una por nudo. No hay más, y son las que ya dedujimos con la matriz de coeficientes.
N_1 = (1-xi)·(1-eta)/4
N_2 = (1+xi)·(1-eta)/4
N_3 = (1+xi)·(1+eta)/4
N_4 = (1-xi)·(1+eta)/4
## Y aquí la pregunta que hay que tener clarísima: ¿cuántas veces se derivan?
## En MEMBRANA, UNA sola vez. La deformación es la primera derivada del desplazamiento.
d_mem = 1
## En PLACA, DOS. La curvatura es la segunda derivada de la flecha. Por eso la placa necesita las Hermite y la membrana no.
d_pla = 2
## Así que aquí van las CUATRO derivadas respecto a la primera coordenada.
A_1 = Partial{(1-xi)·(1-eta)/4 @ xi}
A_2 = Partial{(1+xi)·(1-eta)/4 @ xi}
A_3 = Partial{(1+xi)·(1+eta)/4 @ xi}
A_4 = Partial{(1-xi)·(1+eta)/4 @ xi}
## Y las CUATRO respecto a la segunda.
C_1 = Partial{(1-xi)·(1-eta)/4 @ eta}
C_2 = Partial{(1+xi)·(1-eta)/4 @ eta}
C_3 = Partial{(1+xi)·(1+eta)/4 @ eta}
C_4 = Partial{(1-xi)·(1+eta)/4 @ eta}
## Ocho derivadas en total: cuatro funciones por dos direcciones. Ni una más.
n_der = 4·2
## Para pasarlas al elemento real hay que dividir por el Jacobiano. Con elementos de un metro, el Jacobiano vale un medio, así que se multiplican por dos.
## Y con eso la primera fila de la matriz B queda con TODO escrito, sin símbolos.
B_1 = [-(1-eta)/2, 0, (1-eta)/2, 0, (1+eta)/2, 0, -(1+eta)/2, 0]
## La segunda fila, con las derivadas de la otra dirección y los ceros al revés.
B_2 = [0, -(1-xi)/2, 0, -(1+xi)/2, 0, (1+xi)/2, 0, (1-xi)/2]
## Y la tercera, la distorsión, que lleva las dos mezcladas y ningún cero.
B_3 = [-(1-xi)/2, -(1-eta)/2, -(1+xi)/2, (1-eta)/2, (1+xi)/2, (1+eta)/2, (1-xi)/2, -(1+eta)/2]
## Comprobación de que las derivadas están bien: las cuatro de una dirección tienen que SUMAR CERO, porque si el elemento se mueve entero no se deforma.
S_x = Expand{-(1-eta)/2 + (1-eta)/2 + (1+eta)/2 - (1+eta)/2}
S_y = Expand{-(1-xi)/2 - (1+xi)/2 + (1+xi)/2 + (1-xi)/2}
