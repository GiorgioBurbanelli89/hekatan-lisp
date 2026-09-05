# El Jacobiano en dos dimensiones
## Las funciones de forma del capítulo anterior no solo interpolan el desplazamiento: con las mismas se dibuja la geometría. A eso se le llama elemento isoparamétrico.
## Tomemos un elemento rectangular de seis por cuatro. Sus cuatro nudos están aquí.
## La coordenada horizontal de un punto interior es la suma de las cuatro, cada una pesada por su función de forma.
xg = Expand{(1-xi)·(1-eta)/4·0 + (1+xi)·(1-eta)/4·6 + (1+xi)·(1+eta)/4·6 + (1-xi)·(1+eta)/4·0}
## Y la vertical, igual.
yg = Expand{(1-xi)·(1-eta)/4·0 + (1+xi)·(1-eta)/4·0 + (1+xi)·(1+eta)/4·4 + (1-xi)·(1+eta)/4·4}
## El Jacobiano es la matriz de las cuatro derivadas: cuánto se mueve el elemento real cuando te mueves en el patrón.
Ja = Partial{3·xi + 3 @ xi}
Jb = Partial{3·xi + 3 @ eta}
Jc = Partial{2·eta + 2 @ xi}
Jd = Partial{2·eta + 2 @ eta}
## Ordenadas en una matriz de dos por dos.
J = [3, 0; 0, 2]
## En una dimensión el Jacobiano era un número, la mitad del largo. Aquí es una matriz de cuatro números.
## Su determinante dice cuánto se agranda el área al pasar del patrón al elemento real.
dJ = det(J)
## Y la comprobación: el patrón mide dos por dos, así que el área real tiene que salir la del rectángulo.
areal = 6·2·2
## Para las deformaciones hacen falta las derivadas respecto a las coordenadas reales, y para eso se invierte el Jacobiano.
Jinv = J^-1
## Ahora un elemento TORCIDO, con los nudos donde caigan. El Jacobiano ya no es el mismo en todo el elemento; este es el del centro.
Jt = [3, -0.25; 0.5, 2.25]
dJt = det(Jt)
## Y aquí está el aviso. Si los nudos se numeran al revés, en sentido horario, el Jacobiano sale cambiado.
Jm = [0, 2; 3, 0]
dJm = det(Jm)
## Determinante negativo: el elemento está del revés y el programa no puede integrarlo. Por eso se numeran siempre en sentido antihorario.
