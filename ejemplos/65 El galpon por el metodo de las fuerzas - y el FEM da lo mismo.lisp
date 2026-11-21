# El galpón por el método de las fuerzas — y el FEM da lo mismo

#: El mismo arco de 20 m que sale en el modal, resuelto **a mano**, con el método
#: clásico de las fuerzas. Y al final se compara con lo que da el elemento finito.
#: La gracia es ésa: **dos caminos que no se parecen en nada y el mismo número**.

## 1 · El problema

#| Dato | Valor |
#|---|---|
#| luz | L = 20 m |
#| flecha | f = 2.5 m |
#| carga repartida | q = 3 kN/m sobre la proyección horizontal |
#| apoyos | los dos articulados |

#: El eje del arco es una parábola. Medida desde la línea de arranques:
#: y(x) = 4·f·x·(L−x) / L²
L = 20
f = 2.5
q = 3

## 2 · Cuántas incógnitas sobran

#: Un arco con **dos apoyos articulados** tiene cuatro reacciones (dos por apoyo) y
#: la estática solo da tres ecuaciones. Sobra **una**: es hiperestático de grado 1.
GH = 4 - 3

#: Esa que sobra se llama la **redundante**. Se elige el **empuje horizontal** `H`,
#: que es lo que el arco le hace a sus apoyos hacia afuera.

## 3 · El sistema primario

#: Se **suelta** la redundante: se quita el apoyo horizontal de la derecha y se deja
#: un apoyo móvil. Lo que queda ya es isostático — se resuelve con estática sola.
#: Sobre ese sistema se ponen **dos estados**:

#| Estado | Qué lleva | Momento |
#|---|---|---|
#| **0** | la carga real `q`, sin el empuje | M_{0}(x) = q·x·(L−x)/2 |
#| **1** | un empuje **unitario** H = 1, sin carga | m_{1}(x) = −y(x) |

#: `M_0` es el de una viga simple de luz L: el arco suelto no arquea nada.
#: Y `m_1` es **menos** la altura del eje, porque un empuje hacia dentro levanta el arco.

## 4 · La condición que cierra el problema

#: El apoyo que se quitó **no se mueve** en la realidad. Así que el desplazamiento
#: horizontal total en ese punto tiene que ser cero:
#: delta_{10} + delta_{11}·X_{1} = 0
#: y de ahí sale la redundante:
#: X_{1} = −delta_{10} / delta_{11}

#: Los dos deltas salen de las **integrales de Mohr** — el trabajo virtual:
#: delta_{10} = ∫ M_{0}·m_{1} / (E·I) ds
#: delta_{11} = ∫ m_{1}² / (E·I) ds

## 5 · Las dos integrales, resueltas

#: Con E·I constante, y sustituyendo `y = 4f·x(L−x)/L²`, las dos llevan a la misma
#: integral de base:
#: ∫ x²·(L−x)² dx = L⁵/30   entre 0 y L

#: **La primera**, con M_{0} = q·x(L−x)/2:
#: ∫ M_{0}·y dx = (2·q·f/L²)·∫ x²(L−x)² dx = (2·q·f/L²)·(L⁵/30) = q·f·L³/15
I.a = dec(q*f*L^3/15, 2)

#: **La segunda**, con y²:
#: ∫ y² dx = (16·f²/L⁴)·(L⁵/30) = 8·f²·L/15
I.b = dec(8*f^2*L/15, 4)

#: El `E·I` está en las dos y **se va al dividir**. Por eso el empuje de un arco
#: parabólico **no depende de la rigidez**: sale de la geometría y de la carga.
H = dec((q*f*L^3/15)/(8*f^2*L/15), 3)

## 6 · Y la fórmula que queda

#: Haciendo la división en símbolos, antes de meter números:
#: X_{1} = (q·f·L³/15) / (8·f²·L/15) = **q·L² / (8·f)**

#: Ésta es la fórmula clásica del empuje de un arco parabólico biarticulado.
#: No se aprende de memoria: **sale**, y sale de dos integrales.
H.formula = dec(q*L^2/(8*f), 3)

#: Con los datos del galpón:
comprobacion = dec(q*L^2/(8*f) - H, 10)
#: Cero, como tenía que ser.

## 7 · Cuánto pesa la flecha

#: En la fórmula, `f` está **dividiendo**. Un arco más rebajado empuja más:
#fplot(3*20^2/(8*x), [0.8 5])
#: El eje horizontal es la flecha en metros. A la izquierda, un arco casi plano:
#: el empuje se dispara. Por eso una cubierta rebajada le pide mucho más a los apoyos.
H.rebajado = dec(q*L^2/(8*1.0), 1)
H.peraltado = dec(q*L^2/(8*5.0), 1)

## 8 · El momento en la clave

#: Con la redundante ya conocida, el momento en cualquier punto es
#: M(x) = M_{0}(x) − H·y(x). En la clave, x = L/2:
M.0.clave = dec(q*L^2/8, 2)
M.arco.clave = dec(q*L^2/8 - (q*L^2/(8*f))*f, 6)

#: **Cero.** Y no es coincidencia: con carga uniforme, la parábola es
#: **la forma antifunicular** de esa carga. El arco no flecta: trabaja **a compresión pura**.
#: Eso es lo que hace que una cubierta curva lleve luz con tan poco material.

## 9 · Y ahora el elemento finito

#: El FEM no sabe nada de todo esto. No elige redundantes, no integra Mohr, no
#: conoce la fórmula. Hace otra cosa:

#| Método de las fuerzas | Elemento finito |
#|---|---|
#| elige **una** incógnita: el empuje | monta **todos** los grados de libertad |
#| integra M·m/EI a lo largo del eje | integra B^{T}·D·B por Gauss en cada barra |
#| resuelve **una** ecuación | resuelve K·u = F, de tamaño n |
#| sale la fórmula en símbolos | salen números |

#: Y dan **lo mismo**. Porque los dos imponen la misma condición: equilibrio y
#: compatibilidad. El método de las fuerzas la impone **en una incógnita elegida a
#: mano**; el FEM la impone **en todos los nudos a la vez**.

#: **Por eso se comprueba un programa con esto.** Si el FEM no reproduce el
#: empuje de un arco parabólico, el problema no está en el arco.

## 10 · Lo que hay que llevarse

#| | |
#|---|---|
#| El empuje | H = q·L²/(8·f) — no depende de E·I |
#| Rebajar el arco | empuje mayor, en proporción inversa a la flecha |
#| Parábola con carga uniforme | momento **cero**: compresión pura |
#| El FEM | el mismo resultado, sin elegir nada a mano |
