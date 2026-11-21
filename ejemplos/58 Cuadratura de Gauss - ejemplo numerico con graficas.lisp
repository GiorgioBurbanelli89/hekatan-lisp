# Cuadratura de Gauss: un ejemplo numérico, con gráficas

#: La hoja anterior dedujo los dos puntos y los dos pesos. Aquí se USAN, con una integral concreta y con dibujos, para ver cómo es de verdad. Se calcula el área bajo la curva x³ entre cero y cuatro, midiendo la función en solo DOS puntos.

## 1 · La integral que queremos

#: El área bajo y = x³ desde x = 0 hasta x = 4. En la gráfica, el área es la zona bajo la curva.
#fplot(y = x^3, [0 4])

#: Por el camino de siempre, con la primitiva, el área vale:
exacta = Area{x^3 @ x = 0:4}

## 2 · Gauss trabaja en el tramo patrón, de −1 a +1

#: Los dos puntos y los dos pesos están tabulados para el tramo que va de menos uno a más uno. Nuestro tramo va de cero a cuatro, así que hay que traducir. La traducción es la recta que lleva ξ = −1 a x = a, y ξ = +1 a x = b:
a = 0
b = 4
p = (a + b)/2
q = (b - a)/2
#: El primer número es el punto MEDIO del tramo, y el segundo es la SEMILONGITUD. Con ellos, cualquier ξ se convierte en su x:
#: x = p + q·ξ, o sea x = {p} + {q}·ξ.
#: Y al cambiar de variable, el diferencial también se estira: dx = q·dξ. Ese q es el JACOBIANO, el factor de estiramiento entre los dos tramos.
J = q

## 3 · Los dos puntos de Gauss, y dónde caen de verdad

#: En el tramo patrón los dos puntos son ξ = ±1/√3, y los dos pesos valen uno.
#: En decimales, ξ_{1} = −0.577350 y ξ_{2} = +0.577350 (es 1/√3).
xi_1 = -0.577350
xi_2 = 0.577350
w_1 = 1
w_2 = 1
#: Llevados a nuestro tramo con x = p + q·ξ:
x_1 = 0.8452994616
x_2 = 3.1547005384
#: (salen de 2 + 2·ξ, con ξ = ∓0.577350)
#: Fíjate: NO caen en los extremos (0 y 4) ni en el centro. Caen aquí, y la gráfica los marca sobre la curva:
#fplot(y = x^3, puntos = [0.845299 0.603993; 3.154701 31.396007], [0 4])

## 4 · La función medida en esos dos puntos

f_1 = dec(x_1*x_1*x_1, 6)
f_2 = dec(x_2*x_2*x_2, 6)
#: Solo DOS evaluaciones de la función. Nada más. Ni cien rectángulos ni mil.

## 5 · La suma ponderada

#: La regla de Gauss es sumar cada medida multiplicada por su peso:
suma = dec(w_1*f_1 + w_2*f_2, 6)
#: Y como se calculó en el tramo patrón, hay que deshacer el estiramiento multiplicando por el Jacobiano:
gauss = dec(suma*J, 6)

## 6 · La comparación

#: El valor exacto era {exacta} y Gauss da {gauss}. La diferencia:
error = dec(gauss - exacta, 6)
#: Cero hasta la última cifra que hemos escrito. No es que se parezca: es exacto. Y el motivo es la ley del grado: con n puntos la cuadratura de Gauss integra exacto hasta el grado 2·n − 1. Con dos puntos, hasta el grado tres — y x³ es justo de grado tres.
n = 2
grado_exacto = 2*n - 1

## 7 · La prueba de que la ley manda: sube un grado y falla

#: Si la curva es de grado cuatro, dos puntos ya no bastan. El área exacta de x⁴ en el tramo patrón:
exacta_4 = Area{xi^4 @ xi = -1:1}
#: Y lo que dice Gauss con dos puntos, elevando cada punto a la cuarta:
gauss_4 = dec((1/3)^2 + (1/3)^2, 6)
#: Dos quintos contra dos novenos: falla justo donde la ley dice que tiene que fallar, en el grado cuatro. Con TRES puntos volvería a acertar, hasta el grado cinco.

## 8 · Por qué esto importa en el cálculo de estructuras

#: La deformada de una viga es una CÚBICA: grado tres. Por eso dos puntos de Gauss bastan para integrar exacto su matriz de rigidez, y por eso el motor integra así y no con cien rectángulos. Los números doce, seis, cuatro y dos de la matriz de la viga salen de esas dos evaluaciones.
K_viga = [12, 6, -12, 6; 6, 4, -6, 2; -12, -6, 12, -6; 6, 2, -6, 4]
