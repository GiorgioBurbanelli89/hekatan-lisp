# Shell-Thin: la placa delgada de ETABS y SAP2000
#: 17-sep-2026. Qué es el **Shell-Thin**, de dónde sale su número y por qué ETABS, SAP2000 y Hekatan Struct caen todos sobre la misma superficie.

## 1. La idea, en una frase
#: Thin = **Kirchhoff**: la placa solo se dobla. Una recta perpendicular a la placa sigue recta y perpendicular después de doblarse, **sin resbalar por cortante**. Es la viga de Euler-Bernoulli, pero en dos direcciones.
#: Thick = **Mindlin**: esa recta sí puede resbalar. Cuenta el cortante, y por eso da un poco más flexible.
#: Cuándo usar cuál: si el lado entre el espesor pasa de 20, la diferencia es despreciable y **Thin y Thick coinciden**.

## 2. La rigidez a flexión D
#: Es la única constante de la placa delgada: junta el material (E, nu) con el espesor (t).
D = E*t^3/(12*(1-nu^2))

#: Para hormigón de E = 22 GPa, nu = 0.2 y t = 0.5 m (los datos de la prueba contra ETABS 19):
D_1 = 2.2*10^7*0.5^3/(12*(1-0.2^2))
#: Es decir **D = 238 715 kN·m** (la fracción de arriba, en decimal).

## 3. La ecuación que resuelve
#: Kirchhoff en una línea: el laplaciano doble de la flecha, por D, es la carga.
#: D*(d4w/dx4 + 2*d4w/dx2dy2 + d4w/dy4) = q
#: La solución de Navier para losa cuadrada simplemente apoyada suma senos. El primer término ya da el 99 % de la flecha:
w_1 = 16*q/(pi^6*D)*sin(pi*x/L)*sin(pi*y/L)

## 4. La flecha en el centro
#: Poniendo x = y = L/2 y sumando la serie sale el coeficiente clásico de Timoshenko:
w_max = 0.00406*q*L^4/D

#: Con L = 10 m, q = 10 kN/m2 y la D de arriba (t = 0.5 m):
w_centro = 0.00406*10*10^4/238715
#: Es decir **0.0017008 m = 1.70 mm** en el centro (con el coeficiente 0.00406 de Timoshenko).

#: **Medido en ETABS 19** con esta misma losa y malla 8x8: 0.0017002 m.
#: La serie de Navier (19 terminos) da 0.0017018 m: **diferencia +0.089 %**; con el coeficiente 0.00406, +0.035 %, y es la misma en los cinco espesores probados (t/L de 0.001 a 0.2): no es formulación, es el corte de la serie.

## 5. La superficie de la flecha (colormap + hover)
#: Gira con el ratón y **pasa el cursor por encima**: sale x, y y el valor de la flecha en ese nudo.
#: La flecha va **hacia abajo** (la carga es la gravedad): por eso el signo menos. La placa se hunde, no se levanta.
#surf(-sin(pi*x/10)*sin(pi*y/10), [0 10], [0 10])

## 6. El mismo campo en planta, como el mapa de color de ETABS
#map(-sin(pi*x/10)*sin(pi*y/10), [0 10], [0 10])

## 7. Los momentos salen de las curvaturas
#: Derivando dos veces la flecha: donde la superficie es más curva, más momento.
Mxx = -D*(diff(diff(w,x),x) + nu*diff(diff(w,y),y))
Myy = -D*(diff(diff(w,y),y) + nu*diff(diff(w,x),x))
Mxy = -D*(1-nu)*diff(diff(w,x),y)

## 8. Qué mirar cuando se compara con CSI
#: - Misma malla, nudo a nudo, y offsets en cero.
#: - Thin contra Thin: Hekatan Struct da 0.000 % contra ETABS en su prueba de losas.
#: - Si la losa es gruesa (lado/espesor menor que 10), el Thin se queda corto: ahí manda el Thick.
