# La cuadratura de Gauss con números: la integral de x³ entre 0 y 4

#: Dos medidas, dos multiplicaciones y una suma. Sale **exacto**, y aquí se ve por qué. Primero con letras, después con los números, y al final la comprobación contra la primitiva.
#: La deducción de dónde salen los puntos y los pesos está en la hoja 63; el cambio de variable, en la hoja 62. Aquí se usan.

## 1 · Con letras: el cambio de variable

#: Los puntos de Gauss están tabulados en el **tramo patrón**, de −1 a +1, en la coordenada natural ξ. Una integral real va de a a b, así que primero se lleva el tramo real al patrón con una **recta**, la que manda ξ = −1 a x = a y ξ = +1 a x = b:
X = p + q*xi
#: Sus dos números tienen nombre: p es el **centro** del tramo y q su **semilongitud**. De dónde salen se deduce en la hoja 62, y valen:
p_c = (a + b)/2
q_c = (b - a)/2
#: El **jacobiano** es la pendiente de esa recta, y lo deriva el motor:
J = Diff{p + q*xi @ xi}
#: Sale J = q, o sea (b − a)/2. Es el factor de estiramiento entre los dos tramos: un pedacito dξ del patrón mide J·dξ en el tramo real, y por eso la integral se multiplica por J.

## 2 · Con letras: la fórmula, los dos puntos y los dos pesos

#: La integral deja de ser una integral y pasa a ser una **suma de dos términos**: cada altura medida por su peso, y todo por el jacobiano.
I = q*(w_1*f_1 + w_2*f_2)
#: Con **dos** puntos la fórmula es exacta hasta grado 3. Dónde hay que ponerlos sale de exigir justo eso —se deduce entera en la hoja 63— y son simétricos:
xi_1 = dec(-1/3^0.5, 6)
xi_2 = dec(1/3^0.5, 6)
#: Y los dos pesos valen 1:
w_1 = 1
w_2 = 1
#: Suman 2 porque el tramo patrón mide 2: ésa es la primera condición, la de integrar la constante 1 entre −1 y +1. Y son iguales porque los puntos son simétricos.

## 3 · Los números: la integral de x³ entre 0 y 4

#: Ahora el caso concreto: a = 0, b = 4, y la función x³, que es de grado 3.
#: El punto medio del tramo y la semilongitud:
x_m = dec((0 + 4)/2, 6)
J = dec((4 - 0)/2, 6)
#: Los dos puntos del patrón, llevados al tramo real con x = 2 + 2·ξ:
x_1 = dec(2 - 2/3^0.5, 6)
x_2 = dec(2 + 2/3^0.5, 6)
#: Ahí se **mide** la función. Nada más: dos evaluaciones de x³.
f_1 = dec((2 - 2/3^0.5)^3, 6)
f_2 = dec((2 + 2/3^0.5)^3, 6)
#: Se suman con su peso, que vale 1:
S = dec((2 - 2/3^0.5)^3 + (2 + 2/3^0.5)^3, 6)
#: La suma da 32 **clavado**. Y se multiplica por el jacobiano:
I_g = dec(2*((2 - 2/3^0.5)^3 + (2 + 2/3^0.5)^3), 6)

## 4 · La comprobación con la primitiva

#: El camino de toda la vida: la primitiva de x³, que el motor integra:
F = Integral{x^3 @ x}
#: Es x⁴/4. Evaluada entre 0 y 4: 4⁴/4 − 0 = 64. El motor lo hace de una:
I_exacta = Area{x^3 @ x=0:4}
#: Y la diferencia entre las dos:
dif = dec(2*((2 - 2/3^0.5)^3 + (2 + 2/3^0.5)^3) - 4^4/4, 6)
#: **Cero.** No es una casualidad ni una aproximación afortunada: con n puntos la cuadratura es exacta hasta grado 2n − 1, y con n = 2 eso es grado 3. La función era x³, justo grado 3.

## 5 · ¿Y con un solo punto?

#: Con **un** punto la regla es exacta solo hasta grado 2·1 − 1 = 1, o sea rectas. El punto único es ξ = 0 —el centro— con peso 2:
x_c = dec((0 + 4)/2, 6)
f_c = dec(2^3, 6)
I_1 = dec(2*2*2^3, 6)
#: Sale 32 contra los 64 de verdad: **la mitad**. El error es del 50 %, y no por mala suerte: x³ es de grado 3 y un punto no llega. Por eso se usan dos.

## 6 · La curva y los dos puntos donde se mide

#: La curva x³ entre 0 y 4, con las dos medidas marcadas. Están dentro del tramo, no en los extremos: ahí está toda la gracia.
#fplot(x^3, Gauss = [0.845299 0.603993; 3.154701 31.396007], [0 4])
#: A la izquierda se mide casi nada (0.604) y a la derecha mucho (31.396). Sumadas valen 32, y por el jacobiano 2 dan las 64 unidades de área exactas.

## En una línea

#: · El tramo real se lleva al patrón con una recta; su pendiente es el jacobiano J = (b − a)/2.
#: · Dos puntos en ±1/√3, peso 1, y la suma por J.
#: · Con dos puntos sale exacto hasta grado 3 — y x³ es grado 3: diferencia **cero**.
