# La derivada dN/dx de dos formas: el despeje largo y el atajo del Jacobiano
#: Para armar la deformación (la matriz B) hace falta la derivada de la función de forma respecto a la coordenada FÍSICA {x}, no a la natural {xi}. Hay dos maneras de obtenerla que dan lo mismo. La primera, manual, es larga: obliga a despejar {xi}. La segunda usa el Jacobiano —que se inventó justo para evitar ese despeje—. Todo simbólico.

## 1 · El punto de partida
#: La función de forma {N1} = (1−{xi})/2 está escrita en la coordenada natural {xi}, pero la deformación necesita su derivada en la física {x}. Se conocen dos piezas: la derivada natural de la función de forma, y el Jacobiano del mapeo {x} = (1+{xi})/2·{L}:
dN1_dxi = Diff{(1-xi)/2 @ xi}
J = Diff{(1+xi)/2 * L @ xi}
#: Salen {dN1_dxi} y el Jacobiano {J}.

## 2 · Forma manual — el despeje largo
#: Se despeja {xi} del mapeo: de {x} = (1+{xi})/2·{L} sale {xi} = 2{x}/{L} − 1. Se mete ese {xi} en la función de forma para tenerla escrita en {x}:
N1x = Simplify{(1 - (2*x/L - 1))/2}
#: Queda {N1x}. Ahora sí se deriva respecto a la coordenada física {x}:
dN1_dx_manual = Diff{(1 - (2*x/L - 1))/2 @ x}
#: Resulta {dN1_dx_manual}. El resultado es correcto, pero hubo que despejar {xi} y reescribir la función —un paso que en 1D es fácil, pero en 2D y 3D es prácticamente imposible a mano.

## 3 · Forma con Jacobiano — el atajo
#: En vez de despejar, se usa la regla de la cadena: dN/d{x} = dN/d{xi} · d{xi}/d{x}. Y como el Jacobiano es d{x}/d{xi} = {J}, su recíproco es d{xi}/d{x} = 1/{J}. Primero la inversa del Jacobiano:
Jinv = Simplify{1/J}
#: Sale {Jinv}. Entonces la derivada física es la natural {dN1_dxi} multiplicada por esa inversa —sin despejar nada—:
dN1_dx_jac = Simplify{dN1_dxi * Jinv}
#: Resulta {dN1_dx_jac}.

## 4 · Coinciden — y por eso existe el Jacobiano
#: Las dos dan {dN1_dx_jac}. La forma manual obliga a despejar {xi} y reescribir la función; la del Jacobiano solo deriva en {xi} y multiplica por 1/{J}. Por eso el método de los elementos finitos trabaja SIEMPRE en coordenadas naturales y usa el Jacobiano para pasar a las físicas: evita el despeje, que en varias dimensiones sería inviable.
