# La membrana en ETABS y SAP2000: qué lleva, cómo reparte y qué masa da al modal

#: Un galpón **no es un edificio**. No tiene losa, no tiene diafragma rígido, y la cubierta es una chapa que no flecta. Todo lo que se da por sabido en un edificio aquí cambia.
#: Cuatro preguntas, con lo que los programas hacen de verdad — no de memoria: lo que sigue está sacado del `.e2k` que **escribe el propio ETABS**.

## 1 · Qué esfuerzos tiene una membrana (y cuáles NO tiene)

#: Una cáscara completa tiene ocho esfuerzos por unidad de longitud. Una **membrana** solo tiene los tres primeros:

#| Esfuerzo | Qué es | Membrana | Cáscara completa |
#|---|---|---|---|
#| F_{11}, F_{22} | axiles en el plano | **sí** | sí |
#| F_{12} | cortante en el plano | **sí** | sí |
#| M_{11}, M_{22} | flectores | **NO** | sí |
#| M_{12} | torsor | **NO** | sí |
#| V_{13}, V_{23} | cortantes fuera del plano | **NO** | sí |

#: O sea: la membrana trabaja **estirándose y cortándose en su propio plano**. Fuera de su plano no tiene rigidez ninguna.
#: La rigidez de membrana, por unidad de ancho:
E = 200000000
nu = 0.3
t = 0.0008
K.m = dec(E*t/(1 - nu^2), 1)
#: Y la rigidez a **flexión** de esa misma chapa sería:
D.chapa = dec(E*t^3/(12*(1 - nu^2)), 6)
#: Compárala con la de una losa de hormigón de 20 cm:
E.c = 21000000
t.c = 0.20
D.losa = dec(E.c*t.c^3/(12*(1 - 0.2^2)), 1)
#: La relación entre las dos:
razon = dec(D.losa/D.chapa, 0)
#: **Por eso se modela como membrana.** No es un criterio arbitrario: la chapa es un millón y medio de veces menos rígida a flexión que una losa. Poner su flexión a cero no quita nada que existiera.
#: Y se ve en la fórmula: la flexión va con **t al cubo**. Al bajar el espesor de 20 cm a 0.8 mm, el espesor se divide por 250, pero la rigidez a flexión se divide por 250 al cubo.

## 1b · Cuánto cae la rigidez a flexión al adelgazar

#: La curva de `D` contra el espesor. Se desploma:
#fplot(21000000*x^3/(12*(1 - 0.09)), [0.001 0.2])
#: A la izquierda del todo está el zinc. Prácticamente pegado a cero.

## 2 · Entonces, ¿cómo le pasa la carga a las correas?

#: Si la membrana no tiene flexión **no puede llevar carga perpendicular a su plano por rigidez**. Así que el programa no la calcula: la **reparte**.
#: Esto lo escribe ETABS en el `.e2k`, literal:

#| Lo que escribe ETABS | Qué significa |
#|---|---|
#| `MODELINGTYPE "Membrane"` | solo esfuerzos en el plano |
#| `ONEWAYLOADDIST "Yes"` | la carga baja **en una dirección**, a las correas |

#: `ONEWAYLOADDIST` es la clave: la carga de la cubierta se reparte **por área tributaria** a las barras del borde, no por rigidez. Es exactamente lo que se hace a mano.
#: Con el galpón: carga de cubierta y separación entre correas.
q = 0.5
s = 1.5
w = dec(q*s, 3)
#: Esa `w` es la carga lineal que recibe cada correa. Y la misma cuenta a mano:
#: cada correa recoge medio vano a cada lado, o sea el vano entero: `w = q · s`.
#: **Consecuencia de modelado:** si en vez de membrana dejas la cubierta como losa (`Shell`), la chapa empieza a **flectar** y se lleva carga que en la obra no lleva. Las correas salen más descargadas de lo que están de verdad.

## 2b · Cómo cambia la carga en la correa con la separación

#fplot(0.5*x, [0.5 3])
#: Es una recta: doble separación, doble carga en la correa. Nada de misterio — es área tributaria.

## 3 · La masa del modal: lo que ETABS pone por defecto

#: Esta es la pregunta que más periodos falsos produce. Lo que ETABS escribe **si tú no tocas nada**:

#| Opción de ETABS | Por defecto | Qué hace |
#|---|---|---|
#| `INCLUDEELEMENTS` | **Yes** | el peso propio SÍ es masa |
#| `INCLUDEADDEDMASS` | **Yes** | la masa añadida SÍ |
#| `INCLUDELOADS` | **No** | **las cargas NO son masa** |
#| `INCLUDELATERALMASS` | **Yes** | masa horizontal sí |
#| `INCLUDEVERTICALMASS` | **No** | **masa vertical no** |
#| `LUMPATSTORIES` | **Yes** | la concentra en los niveles |

#: Léelo despacio, porque son dos hipótesis implícitas seguidas:
#: **Aviso 1 — `INCLUDELOADS "No"`.** Si pones la cubierta como carga distribuida y no la metes en el *Mass Source*, para el modal **esa carga no existe**. La estructura pesa solo lo que pesan sus perfiles. Sale más ligera, y por tanto **más rápida**: periodos cortos y falsos.
#: **Aviso 2 — `INCLUDEVERTICALMASS "No"`.** ETABS no cuenta la masa vertical. SAP2000 **sí** la cuenta por defecto. Mismo modelo, dos programas, periodos distintos — y ninguno está equivocado.

#| Programa | Masa de las cargas | Masa vertical |
#|---|---|---|
#| ETABS | no, salvo que la añadas | **no** |
#| SAP2000 | no, salvo que la añadas | **sí** |
#| Hekatan Struct | la del `.heks` | sí |

#: Y la masa de la propia chapa, que sí cuenta porque es peso propio:
gamma = 78.5
p.zinc = dec(gamma*t, 4)
#: Contra los 0.5 kN/m² de la carga de cubierta, la chapa pesa casi nada. **Casi toda la masa de la cubierta está en la carga, que por defecto NO entra.** Ahí está el problema.

## 4 · Y el modal de un galpón: aquí no hay diafragma

#: En un edificio, la losa obliga a todos los nudos de una planta a moverse juntos: tres grados de libertad por piso y se acabó.
#: **En un galpón no hay losa.** La cubierta de chapa es membrana: en su plano tiene rigidez, pero no obliga a nada porque no hay masa de losa concentrada. Cada nudo va por su cuenta.
#: Así que el modal de un galpón **no se hace con matriz de piso**: se hace con **masas puntuales en los nudos**, en las tres direcciones. Es lo que hace Aguiar en el capítulo de estructuras de lámina delgada:

#| Bloque | Cuándo actúa |
#|---|---|
#| M_{HT} | sismo en sentido transversal |
#| M_{HL} | sismo en sentido longitudinal |
#| M_{V} | sismo vertical |

#: Con seis columnas salen 18 grados de libertad: se numeran primero todos los transversales, luego los longitudinales y al final los verticales, y la matriz de masas queda en tres bloques por la diagonal.
#: **Y entonces la masa vertical importa.** En un edificio la ignoras sin culpa porque la losa es rígida en su plano y el sismo vertical casi no la mueve. En un galpón, el arco de 20 m de luz **sí** tiene modos verticales de verdad.
#: Por eso en la tabla del modal del galpón aparece, en el modo 4, un `U_z` del 38 %: **ese modo es la cubierta botando**. ETABS, con `INCLUDEVERTICALMASS "No"`, no te lo enseña.

## 5 · Resumen en cuatro líneas

#| Pregunta | Respuesta corta |
#|---|---|
#| ¿Qué lleva la membrana? | solo F_{11}, F_{22}, F_{12} — nada de flexión |
#| ¿Cómo pasa la carga a las correas? | por área tributaria, `w = q · s`, no por rigidez |
#| ¿Qué masa usa el modal por defecto? | solo el peso propio, y sin masa vertical en ETABS |
#| ¿Y en un galpón? | masas puntuales por nudo, no matriz de piso |
