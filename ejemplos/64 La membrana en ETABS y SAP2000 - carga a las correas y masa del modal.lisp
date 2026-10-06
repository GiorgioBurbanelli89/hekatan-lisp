# La membrana en ETABS y SAP2000: qué lleva, cómo reparte y qué masa da al modal

#: Un galpón **no es un edificio**. No tiene losa, no tiene diafragma rígido, y la cubierta es una chapa que no flecta. Todo lo que se da por sabido en un edificio, aquí cambia.
#: Cuatro preguntas, con lo que los programas hacen de verdad — no de memoria: lo que sigue está sacado del `.e2k` que **escribe el propio ETABS**.

## 0 · Los datos

E_s = 200000000 'módulo del acero [kN/m²] ; ν = 0.3 'Poisson del acero [—] ; t_z = 0.0008 'espesor del zinc [m]
E_c = 21000000 'módulo del hormigón [kN/m²] ; ν_c = 0.2 'Poisson del hormigón [—] ; t_c = 0.20 'canto de la losa [m]
q = 0.5 'carga de cubierta [kN/m²] ; s = 1.5 'separación entre correas [m] ; γ = 78.5 'peso unitario del acero [kN/m³]

## 1 · Qué esfuerzos tiene una membrana (y cuáles NO tiene)

#: Una cáscara completa tiene ocho esfuerzos por unidad de longitud. Una **membrana** solo tiene los tres primeros:

#| Esfuerzo | Qué es | Membrana | Cáscara completa |
#|---|---|---|---|
#| F_{11}, F_{22} | axiles en el plano [kN/m] | **sí** | sí |
#| F_{12} | cortante en el plano [kN/m] | **sí** | sí |
#| M_{11}, M_{22} | flectores [kN·m/m] | **NO** | sí |
#| M_{12} | torsor [kN·m/m] | **NO** | sí |
#| V_{13}, V_{23} | cortantes fuera del plano [kN/m] | **NO** | sí |

#: O sea: la membrana trabaja **estirándose y cortándose en su propio plano**. Fuera de su plano no tiene rigidez ninguna.

## 2 · Y no es un criterio arbitrario: se mide

#: Las dos rigideces de una placa, por unidad de ancho. La de membrana va con `t`, la de flexión con `t³`:
#: K_{m} = E·t / (1 − ν²)      y      D = E·t³ / (12·(1 − ν²))

K_m = dec(200000000*0.0008/(1 - 0.3^2), 1) [kN/m] 'rigidez de membrana del zinc de 0.8 mm
D_z = dec(200000000*0.0008^3/(12*(1 - 0.3^2)), 6) [kN·m] 'rigidez a flexión del mismo zinc
D_h = dec(21000000*0.20^3/(12*(1 - 0.2^2)), 1) [kN·m] 'la de una losa de hormigón de 20 cm
razon = dec(14583.3/0.009377, 0) [—] 'cuántas veces más rígida es la losa

#: El zinc tiene una rigidez a flexión de {D_z} kN·m contra los {D_h} kN·m de la losa: **{razon} veces menos**. Poner su flexión a cero no quita nada que existiera.
#: Y se ve en la fórmula: al pasar de 20 cm a 0.8 mm el espesor se divide por 250, pero **la flexión va con el cubo**, así que se divide por 250³.

#fplot(21000000*x^3/(12*(1 - 0.04)), [0.001 0.2])
#: El eje horizontal es el espesor en metros y el vertical `D` en kN·m. A la izquierda del todo está el zinc: pegado a cero.

## 3 · Entonces, ¿cómo le pasa la carga a las correas?

#: Si la membrana no tiene flexión, **no puede llevar carga perpendicular a su plano por rigidez**. Así que el programa no la calcula: la **reparte**.
#: Esto lo escribe ETABS en el `.e2k`, literal:

#| Lo que escribe ETABS | Qué significa |
#|---|---|
#| `MODELINGTYPE "Membrane"` | solo esfuerzos en el plano |
#| `ONEWAYLOADDIST "Yes"` | la carga baja **en una dirección**, a las correas |

#: `ONEWAYLOADDIST` es la clave: la carga se reparte **por área tributaria** a las barras de borde, no por rigidez. Lo mismo que se hace a mano, porque cada correa recoge medio vano a cada lado:
#: w = q · s

w = dec(0.5*1.5, 3) [kN/m] 'carga lineal que recibe cada correa
w_2 = dec(0.5*3.0, 3) [kN/m] 'la misma con las correas al doble de separación

#: Con {s} m de separación cada correa recibe {w} kN/m; al doblar la separación, {w_2} kN/m. Es una recta — es área tributaria, no hay más:
#fplot(0.5*x, [0.5 3])

#: **Consecuencia de modelado:** si en vez de membrana se deja la cubierta como losa (`Shell`), la chapa empieza a **flectar** y se lleva carga que en obra no lleva. Las correas salen más descargadas de lo que están.

## 4 · La masa del modal: lo que ETABS pone por defecto

#: Ésta es la pregunta que más periodos falsos produce. Lo que ETABS escribe **si no se toca nada**:

#| Opción de ETABS | Por defecto | Qué hace |
#|---|---|---|
#| `INCLUDEELEMENTS` | **Yes** | el peso propio SÍ es masa |
#| `INCLUDEADDEDMASS` | **Yes** | la masa añadida SÍ |
#| `INCLUDELOADS` | **No** | **las cargas NO son masa** |
#| `INCLUDELATERALMASS` | **Yes** | masa horizontal sí |
#| `INCLUDEVERTICALMASS` | **No** | **masa vertical no** |
#| `LUMPATSTORIES` | **Yes** | la concentra en los niveles |

#: Son dos hipótesis implícitas seguidas:
#: **Aviso 1 — `INCLUDELOADS "No"`.** Si la cubierta se pone como carga distribuida y no se mete en el *Mass Source*, para el modal **esa carga no existe**. La estructura pesa solo sus perfiles: sale más ligera y por tanto **más rápida**. Periodos cortos y falsos.
#: **Aviso 2 — `INCLUDEVERTICALMASS "No"`.** ETABS no cuenta la masa vertical. SAP2000 **sí** la cuenta por defecto. Mismo modelo, dos programas, periodos distintos — y ninguno está equivocado.

#| Programa | Masa de las cargas | Masa vertical |
#|---|---|---|
#| ETABS | no, salvo que se añada | **no** |
#| SAP2000 | no, salvo que se añada | **sí** |
#| Hekatan Struct | la del `.heks` | sí |

#: Y ahora el número que lo cierra. La chapa **sí** pesa, porque es peso propio:

p_z = dec(78.5*0.0008, 4) [kN/m²] 'peso propio de la chapa de zinc
p_tot = dec(0.0628 + 0.5, 4) [kN/m²] 'lo que hay de verdad sobre la cubierta
pct = dec(100*0.0628/0.5628, 1) [%] 'porcentaje que SÍ entra al modal por defecto

#: De los {p_tot} kN/m² que hay sobre la cubierta, al modal solo entra un **{pct} %**: los {p_z} kN/m² de la chapa. Los {q} kN/m² de carga se quedan fuera.
#: **Ahí está el problema**, y no avisa nadie.

## 5 · Y el modal de un galpón: aquí no hay diafragma

#: En un edificio la losa obliga a todos los nudos de una planta a moverse juntos: tres grados de libertad por piso y se acabó.
#: **En un galpón no hay losa.** La cubierta es membrana: en su plano tiene rigidez, pero no concentra masa como una losa. Cada nudo va por su cuenta.
#: Así que el modal de un galpón **no se hace con matriz de piso**: se hace con **masas puntuales en los nudos**, en las tres direcciones. Es lo que hace Aguiar en el capítulo de estructuras de lámina delgada:

#| Bloque de la matriz de masas | Cuándo actúa |
#|---|---|
#| M_{HT} | sismo en sentido transversal |
#| M_{HL} | sismo en sentido longitudinal |
#| M_{V} | sismo vertical |

#: Con seis columnas salen 18 grados de libertad: se numeran primero los transversales, luego los longitudinales y al final los verticales, y la matriz de masas queda en tres bloques por la diagonal.
#: **Y entonces la masa vertical importa.** En un edificio se puede ignorar sin culpa, porque la losa es rígida en su plano. En un galpón, el arco de 20 m de luz **sí** tiene modos verticales de verdad.
#: Por eso en la tabla del modal del galpón aparece, en el modo 4, un `U_z` del 38 %: **ese modo es la cubierta botando**. ETABS, con `INCLUDEVERTICALMASS "No"`, no lo enseña.

## 6 · Resumen

#| Pregunta | Respuesta corta |
#|---|---|
#| ¿Qué lleva la membrana? | solo F_{11}, F_{22}, F_{12} [kN/m] — nada de flexión |
#| ¿Cómo pasa la carga a las correas? | por área tributaria, w = q·s, no por rigidez |
#| ¿Qué masa usa el modal por defecto? | solo el peso propio, y sin masa vertical en ETABS |
#| ¿Y en un galpón? | masas puntuales por nudo, no matriz de piso |
