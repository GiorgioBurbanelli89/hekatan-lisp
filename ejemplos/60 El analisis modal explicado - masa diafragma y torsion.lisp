# El análisis modal, explicado: masa, diafragma y torsión

#: Dos preguntas que todo programa contesta distinto y casi nadie explica: **de dónde sale la masa** y **qué hace el diafragma**. Con ellas se entiende por qué a dos personas con el mismo modelo no les salen los mismos periodos.
#: Los números son los del galpón curvo de 20 x 30 m que está publicado, calculado en Hekatan Struct y comprobado contra SAP2000 y ETABS.

## 1 · Qué es un modo

#: Una estructura sin nada que la empuje puede vibrar sola, y solo de ciertas formas. Cada forma es un **modo**, y cada modo tarda lo suyo en ir y volver: su **periodo**.
#: Sale de igualar la fuerza elástica a la de inercia. Sin amortiguamiento:
K*fi = omega^2*M*fi
#: Con K la rigidez, M la masa, fi la forma del modo y omega la frecuencia. No hay carga a la derecha: el modo es de la estructura, no de lo que le hagas.
#: Y el periodo es lo que se mide:
T = 2*pi/omega

## 1b · Los tres modos, dibujados

#: Cada modo va a su ritmo. Aquí están los tres primeros del galpón, con su periodo de verdad: el modo 1 tarda 0.3311 s en ir y volver, el 3 solo 0.2794 s. Cuanto más rígida la forma, más rápido vibra.
#fplot(sin(2*pi*x/0.3311), sin(2*pi*x/0.3238), sin(2*pi*x/0.2794), [0 1])
#: La curva más lenta es el modo 1 (el fundamental): el que manda. Las otras dos van más apretadas.

## 1c · Cómo se separan los periodos

#: Y esto es lo que pasa cuando la estructura se pone más rígida: el periodo BAJA. La relación es de raíz cuadrada, no proporcional — hay que multiplicar por cuatro la rigidez para bajar el periodo a la mitad.
T = 2*pi*(m/K)^0.5
#: Con la masa del galpón, y barriendo la rigidez:
#fplot(2*pi*(4.2012/x)^0.5, [100 2000])
#: Se ve la caída: al principio, un poco más de rigidez baja mucho el periodo; después ya casi no.

## 2 · De dónde sale la masa

#| Programa | Masa horizontal | Masa VERTICAL |
#|---|---|---|
#| SAP2000 | sí | **sí, por defecto** |
#| ETABS | sí | **no, por defecto** |
#| Hekatan Struct | sí | sí (masa 3D, como SAP2000) |

#: **Esa fila es la primera causa de que no coincidan los periodos.** Mismo modelo, mismo material, y salen distintos porque uno cuenta la masa vertical y el otro no. No es un error de nadie: es una opción por defecto.
#: La masa sale del peso: se divide por la gravedad.
m = W/g
#: Con el peso del galpón, en toneladas-masa:
W = 41.2
g = 9.80665
m = dec(41.2/9.80665, 4)

## 3 · El diafragma: rígido o flexible

#: Un diafragma **rígido** obliga a que todo un piso se mueva junto: un solo desplazamiento para todos sus nudos. Es lo que hace CEINCI-LAB por construcción, agrupando los nudos por su cota.
#: Un diafragma **flexible** deja que cada nudo vaya por su cuenta. La losa o la chapa transmiten lo que pueden, y nada más.

#: **El galpón curvo NO tiene diafragma rígido.** Su cubierta son 100 cáscaras de zinc de 0.8 mm que trabajan **solo como membrana**: en su plano sí, a flexión no. Se declara con dos números, el de membrana y el de flexión:
#| Modificador | Valor | Qué significa |
#|---|---|---|
#| membrana | 1 | la chapa trabaja en su plano |
#| flexión | **0** | la chapa NO flecta |

#: En ETABS y SAP2000 es exactamente lo mismo: un shell **membrana**, o poner los modificadores de flexión a cero. Si se deja como losa, el galpón sale más rígido de lo que es y el periodo sale corto.

## 4 · La participación de masa: cuántos modos hacen falta

#: No todos los modos mueven la misma masa. El factor de participación dice qué parte de la masa total arrastra cada modo:
Gamma = fi^T*M*r
#: Y la norma pide llegar al 90 % de la masa sumando modos. NEC-15 §6.2.2 y ASCE 7-22 §12.9.1.1 dicen lo mismo.

#: En el galpón, con 12 modos:
#| Modo | T [s] | Tipo | Suma |
#|---|---:|---|---:|
#| 1 | 0.3311 | U_{y} (100 %) | 99.7 % |
#| 2 | 0.3238 | U_{x} (100 %) | 99.9 % |
#| 3 | 0.2794 | **R_{z} (100 %)** | — |
#| 4 | 0.1725 | U_{z} (38 %) | — |

#: Con **dos modos** ya se pasa del 90 % en las dos direcciones. Los demás afinan, pero no cambian el resultado.

## 5 · La torsión: el modo que gira

#: El tercer grado de cada planta no es un desplazamiento, es un **giro**: R_{z}. Y ahí está el criterio que importa.

#: **Si el primer modo es de giro, el edificio tiene torsión.** Gira antes de trasladarse, y eso castiga a las columnas de las esquinas.
#: En el galpón los dos primeros modos **trasladan** y el tercero gira. Eso es lo sano.

#: La masa que se opone al giro no es la masa a secas: es el **momento polar de inercia** de la losa. Para una planta rectangular de lados a y b:
J_cm = m*(a^2 + b^2)/12
#: Con la masa del galpón y sus lados:
a = 20
b = 30
J_cm = dec(4.2012*(20^2 + 30^2)/12, 2)

#: Cuanto mayor es J_cm, más le cuesta girar. Por eso una planta alargada gira más fácil que una cuadrada de la misma área.

## 5b · La forma del modo, en 3D

#: Así se deforma el galpón en su primer modo: una sola panza, sin nudos intermedios. **Gíralo con el ratón.**
#surf(sin(pi*x)*sin(pi*y), [0 1], [0 1])
#: Y el modo torsional, el que GIRA: una mitad sube mientras la otra baja. Por eso se llama torsión.
#surf(sin(pi*x)*sin(2*pi*y), [0 1], [0 1])
#: Míralos desde arriba y se entiende de un vistazo: el primero es todo del mismo signo; el torsional tiene una raya donde no se mueve nada.
#map(sin(pi*x)*sin(2*pi*y), [0 1], [0 1])

## 6 · Lo que hay que mirar, en orden

#: 1 · ¿**La masa vertical** está contada igual en los dos programas que comparas? Si no, los periodos no van a coincidir.
#: 2 · ¿El **diafragma** es rígido o flexible? Una chapa de zinc no es una losa.
#: 3 · ¿Se llega al **90 %** de masa participativa? Si no, faltan modos.
#: 4 · ¿El **primer modo gira**? Entonces hay torsión, y hay que mirarla.