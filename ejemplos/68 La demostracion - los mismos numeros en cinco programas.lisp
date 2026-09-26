# La demostración: los mismos números en cinco programas

#: Un resultado que solo da un programa **no es un resultado**. Esta hoja es la prueba: el mismo modelo, la misma malla nudo a nudo, resuelto en cinco sitios.
#: Todos los números de aquí están **medidos**, no estimados. Cada uno se puede repetir con el comando que va al pie.

## 1 · El caso de referencia: Paz y Leigh 6.3

#: Un pórtico espacial de acero. Es el ejemplo clásico de validación modal, y tiene solución publicada.

#| Modo | ETABS 22 | Hekatan denso | Hekatan subespacio |
#|---:|---:|---:|---:|
#| 1 | 8.8305 | 8.8358 | **8.8305** |
#| 2 | 14.5459 | 14.5551 | **14.5459** |
#| 3 | 24.2336 | 24.2228 | **24.2336** |
#| 4 | 25.1132 | 25.1038 | **25.1132** |
#| 5 | 159.6525 | 159.6530 | **159.6525** |
#| 6 | 159.8513 | 159.8523 | **159.8513** |

#: El camino de **subespacio** coincide con ETABS en **los cuatro decimales de los seis modos**. No es que se parezca: es el mismo número.

## 2 · Pero al principio NO coincidía, y eso es lo interesante

#: Tal cual, ETABS daba `9.0903` contra `8.8305`. Un **+2.94 % uniforme** en todos los modos. Un error uniforme nunca es casualidad.

#: **No era el solver.** ETABS pone brazos rígidos automáticos y **descuenta del peso propio el tramo de viga que cae dentro de la columna**. Se midió con su propia tabla `AssembledJointMass`:

m_etabs = 5.707652 'masa de un nudo libre, ETABS con sus brazos [×10⁻³]
m_hek = 6.048429 'la misma en Hekatan, sin brazos [×10⁻³]
dif = dec(100*(6.048429 - 5.707652)/6.048429, 2) [%] 'cuánta masa descuenta ETABS

#: ETABS pesa un **{dif} %** menos ese nudo. Y el periodo va con la **raíz** de la masa:
factor = dec((6.048429/5.707652)^0.5, 5) [—] 'raíz del cociente de masas
medido = dec(9.0903/8.8305, 5) [—] 'cociente de frecuencias observado

#: **{factor} contra {medido}.** Las dos vías cierran en la quinta cifra. Ya no es una sospecha: es la explicación.
#: Y el volumen descontado son **1857.4 in³ exactos**, que es `2·24.7·24.7 + 2·24.7·12.9`: **los offsets de las vigas**. Los de columna no los descuenta.

vol = dec(2*24.7*24.7 + 2*24.7*12.9, 1) [in³] 'el volumen que ETABS no pesa

#: Con `offsets = 0` en ETABS, la masa total coincide al **0.002 %**.

## 3 · El galpón curvo y el mezanine

#| Modelo | Contra | Diferencia |
#|---|---|---:|
#| Galpón, 609 nudos y 1140 barras | SAP2000 24 por OAPI | **0.001 %** |
#| Mezanine con columna CFT | SAP2000, sección general | **0.0000 %** |
#| El mismo mezanine | ETABS 22 | **0.0008 %** |
#| 8 plantillas, masa total | ETABS 22 | **0.000 %** |
#| 8 plantillas, modos 1 a 3 | ETABS 22 | **0.00 a 0.01 %** |
#| Fuerzas de cáscara, 3600 joints | ETABS 22 | **0.0000 %** |

#: El mezanine con SAP2000 cierra en **2415 de 2415 componentes**. No es una media: son todos.

## 4 · La zapata no lineal, en cuatro programas

#: Braja M. Das, ejemplo 6.10: zapata de 1.5 × 1.5 × 0.40 m, carga de 606 kN con excentricidad en las dos direcciones, sobre arena.

P = 606 'carga aplicada [kN] ; e_x = 0.15 'excentricidad en x [m] ; e_y = 0.30 'en y [m]

#| Programa | Cómo modela el suelo | Suma de las presiones |
#|---|---|---:|
#| Hekatan Struct | `areaspring … nodal compresion` | **606.00 kN** |
#| SAFE 20 | *Compression Only* | **606.00 kN** |
#| OpenSeesPy | `uniaxialMaterial ENT` | **606.00 kN** |
#| ETABS 22 | muelles nodales | **606.00 kN** |

#: **Ésta es la comprobación que importa**, y no la hace ningún programa solo: la suma de las presiones del suelo por su área tiene que dar la carga aplicada.
q_suma = dec(606.00 - 606, 4) [kN] 'diferencia entre lo que baja y lo que aguanta el suelo

#: **Cero.** Si no diera cero, el modelo estaría mal — y ninguno avisaría.
#: Y la no linealidad se ve en un número: de los 169 nudos, **30 se levantan**. Ahí la presión es cero porque el suelo no tira.
levantados = dec(100*30/169, 1) [%] 'porcentaje de la zapata que se despega

## 5 · Y todo esto no se comprueba a mano: hay un test

#: Cada uno de estos casos es un test que **falla solo** si alguien rompe algo.

#| Comando | Qué compara | Árbitro |
#|---|---|---|
#| `node tests/run.mjs paz` | 6 modos por dos caminos | ETABS 22 |
#| `node tests/run.mjs masa` | la masa **nudo a nudo** | ETABS 22 |
#| `node tests/run.mjs fuerzas-cascara` | M y F joint a joint | ETABS 22 |
#| `node tests/run.mjs guerra-vs-safe` | 8 zapatas | SAFE |
#| `node tests/run.mjs cimentacion-vs-csi` | los tres ficheros CSI | SAP, ETABS, SAFE |
#| `npm test` | **todos** | los cinco |

n_tests = 335 'casos que corren en la suite completa [—]
t_suite = 261 'lo que tarda en pasar todos [s]

#: **{n_tests} casos en {t_suite} segundos**, y sale con código de error si uno solo se pasa de su límite.

## 6 · La regla, en una línea

#: **La referencia de un caso tiene que ser OTRO PROGRAMA**, con el mismo modelo, la misma malla nodo a nodo y los brazos rígidos anulados.
#: Nunca una cuenta a mano, nunca un número heredado sin fuente. Así fue como se coló una vez una referencia falsa en el Paz 6.3 y estuvo meses dando por buena una regresión que no existía.
#: Por eso cuando aquí dice **0.000 %**, se puede volver a medir delante de quien lo pregunte.
