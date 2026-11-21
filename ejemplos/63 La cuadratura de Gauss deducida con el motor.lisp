# La cuadratura de Gauss, deducida entera con el motor

#: Hasta «hay cuatro incógnitas» la cosa se entiende sola. Lo que sigue —las integrales, el sistema, la simetría y el número 1/√3— es lo que aquí **opera el motor**, paso a paso. Nada escrito a mano.
#: El cambio de variable está en la hoja 62; el ejemplo con números, en la 61.

## 1 · El planteamiento: dos medidas y cuatro incógnitas

#: Todo se hace en el tramo patrón, de −1 a +1, en la coordenada natural ξ. La idea de Gauss es cambiar una integral por una **suma de dos términos**: dos alturas medidas, cada una con su peso:
I = w_1*f_1 + w_2*f_2
#: Ahí hay cuatro números libres: dónde se mide (ξ_{1} y ξ_{2}) y cuánto cuenta cada medida (w_{1} y w_{2}).
#: Cuatro incógnitas piden cuatro condiciones. Hasta aquí, el planteamiento.

## 2 · Las cuatro condiciones, con las integrales hechas por el motor

#: La condición es: que la fórmula dé el **área exacta** para los cuatro ladrillos con los que se arma cualquier curva de grado 3 — la constante 1, la recta ξ, la parábola ξ² y la cúbica ξ³.
#: Las áreas exactas no se copian de una tabla: las integra el motor entre −1 y +1.
A_0 = Area{1 @ xi=-1:1}
A_1 = Area{xi @ xi=-1:1}
A_2 = Area{xi^2 @ xi=-1:1}
A_3 = Area{xi^3 @ xi=-1:1}
#: Los dos ceros no son casualidad: ξ y ξ³ son impares, tienen tanta área encima del eje como debajo, y se cancelan. La primitiva lo dice sola:
F_1 = Integral{xi @ xi}
F_3 = Integral{xi^3 @ xi}
#: Las dos primitivas son pares: valen lo mismo en −1 que en +1, y al restarlas da cero.

## 3 · El sistema: cuatro ecuaciones, cuatro incógnitas

#: Igualando la suma de Gauss a cada una de esas cuatro áreas queda el sistema:

#| nº | ladrillo | la suma de Gauss | tiene que dar |
#|---|---|---|---:|
#| 1 | 1 | w_{1} + w_{2} | 2 |
#| 2 | ξ | w_{1}·ξ_{1} + w_{2}·ξ_{2} | 0 |
#| 3 | ξ² | w_{1}·ξ_{1}² + w_{2}·ξ_{2}² | 2/3 |
#| 4 | ξ³ | w_{1}·ξ_{1}³ + w_{2}·ξ_{2}³ | 0 |

#: Cuatro ecuaciones, cuatro incógnitas. Y no es lineal: las incógnitas ξ aparecen elevadas. Por eso no se resuelve invirtiendo una matriz, sino combinando ecuaciones.

## 4 · La simetría no se supone: sale sola

#: El truco es quitar de en medio los pesos. A la 4.ª condición se le resta la 2.ª multiplicada por ξ_{1}², y el motor hace la resta:
R = Simplify{w_1*xi_1^3 + w_2*xi_2^3 - xi_1^2*(w_1*xi_1 + w_2*xi_2)}
#: El término del primer punto **se cancela solo**: en él queda w_{1}·ξ_{1}³ − ξ_{1}²·w_{1}·ξ_{1} = 0. Sobrevive únicamente el segundo, y factorizado es w_{2}·ξ_{2}·(ξ_{2}² − ξ_{1}²).
#: Como el lado derecho de las dos condiciones era 0, esa resta vale 0. El peso w_{2} no puede ser cero —entonces no habría segundo punto— y ξ_{2} tampoco —los dos puntos no pueden estar en el centro—. Luego lo que se anula es el paréntesis:
#: ξ_{2}² = ξ_{1}², y siendo dos puntos distintos, **ξ_{2} = −ξ_{1}**. La simetría no se supuso: salió del álgebra.

## 5 · Con la simetría, el despeje paso a paso

#: Se mete ξ_{2} = −ξ_{1} en la 2.ª condición. Con los pesos todavía sin saber, el motor la simplifica:
C_2 = Simplify{w_1*xi_1 + w_2*(-xi_1)}
#: Queda ξ_{1}·(w_{1} − w_{2}) = 0. Como ξ_{1} no es cero, **w_{1} = w_{2}**: los dos pesos son iguales. Se les llama w a los dos.
#: Ahora la 1.ª condición dice que suman 2, o sea 2·w = 2. El motor despeja:
w = Despejar{2*w = 2 @ w}
#: **Cada peso vale 1.** Y recién ahora entra la 3.ª condición. Con pesos 1 y puntos simétricos, su lado izquierdo es:
C_3 = Simplify{1*xi^2 + 1*(-xi)^2}
#: O sea 2·ξ², que tiene que dar 2/3. Ésa es la ecuación que entrega el número. Llamando u = ξ² queda lineal, y el motor la despeja:
u = Despejar{2*u = 2/3 @ u}
#: **ξ² = 1/3.** Sacando la raíz salen las dos soluciones, una para cada punto:
raices = Despejar{xi^2 = 1/3 @ xi}
#: Son ±1/√3, que es lo mismo que ±√3/3. En decimales:
xi_1 = dec(-1/3^0.5, 6)
xi_2 = dec(1/3^0.5, 6)
#: Y la 4.ª condición no hace falta para nada: con pesos iguales y puntos simétricos se cumple sola, como comprueba el motor:
C_4 = Simplify{xi^3 + (-xi)^3}
#: Da cero —el motor escribe el cero como 0·0—, que es justo el área exacta de ξ³. Cuatro condiciones, y las cuatro cuadran.

## 6 · La comprobación, hecha por el motor

#: Con ξ = ±0.577350 y w = 1, se vuelve a las cuatro condiciones y se calcula el lado izquierdo. Ladrillo 1 (la constante):
v_0 = dec(1 + 1, 6)
#: Ladrillo ξ:
v_1 = dec(-1/3^0.5 + 1/3^0.5, 6)
#: Ladrillo ξ², que tiene que dar 2/3 = 0.666667:
v_2 = dec((-1/3^0.5)^2 + (1/3^0.5)^2, 6)
#: Ladrillo ξ³:
v_3 = dec((-1/3^0.5)^3 + (1/3^0.5)^3, 6)
#: 2, 0, 0.666667 y 0: las cuatro áreas exactas de la sección 2, clavadas.

## 7 · Dónde deja de funcionar

#: Con grado 4 se acabó. El área exacta la da el motor:
A_4 = Area{xi^4 @ xi=-1:1}
#: Y lo que dan los dos puntos de Gauss:
v_4 = dec((-1/3^0.5)^4 + (1/3^0.5)^4, 6)
#: 0.222222 contra 0.4: un error del 44 %. Y falla justo donde tenía que fallar: con n puntos la fórmula es exacta hasta grado 2n − 1, y con n = 2 eso es grado 3. Ni uno más.

## 8 · Para tocarlo

#: De dónde sale el ±0.5774: se mueve el punto y se mira el error de cada condición. Solo la de ξ² manda, y se anula en 1/√3:
#gauss(porque)
#: Y la cuadratura completa: cuántos puntos, qué grado, y la regla 2n − 1 en marcha. Cada punto se dibuja como un rectángulo de ancho w_{i} y alto f(ξ_{i}), así que su área **es** su término de la suma:
#gauss

## En una línea

#: · Dos puntos y dos pesos = cuatro incógnitas; cuatro ladrillos (1, ξ, ξ², ξ³) = cuatro condiciones.
#: · Restando ecuaciones se cancelan los pesos y aparece la simetría: ξ_{2} = −ξ_{1}. No se supuso.
#: · Después caen solos los pesos (w = 1) y el número (ξ² = 1/3, ξ = 1/√3 = 0.5774).
