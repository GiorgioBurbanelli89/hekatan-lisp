# De dónde sale cada fórmula de Hekatan Struct: las fuentes

#: Un programa de cálculo no vale por lo que enseña en pantalla, sino por **de dónde salió cada línea**. Aquí está el origen de cada pieza, con capítulo y página.
#: La referencia principal es **Edward L. Wilson, «Three-Dimensional Static and Dynamic Analysis of Structures»**, Computers and Structures Inc., Berkeley, 3.ª ed., 2002. Wilson escribió el SAP original, y ese libro es la formulación de la que desciende la familia SAP2000 / ETABS / SAFE.

## 1 · Qué es el método de los elementos finitos

#: Una estructura real tiene **infinitos** puntos, y por tanto infinitos desplazamientos. No se puede resolver así.
#: El método hace tres cosas, en este orden:

#| Paso | Qué se hace | Qué se gana |
#|---|---|---|
#| **partir** | se corta la estructura en trozos (elementos) unidos por nudos | de infinitos puntos a unos pocos |
#| **interpolar** | dentro de cada trozo, el desplazamiento se supone una función sencilla `N` | el interior queda descrito por los nudos |
#| **integrar** | se suma la energía de cada trozo | sale la rigidez `K` |

#: Y al final queda **una sola ecuación**, que es la misma de toda la estática:
#: K · u = R
#: Con `K` la rigidez, `u` los desplazamientos que no conocemos y `R` las cargas.

## 2 · El análisis ESTÁTICO: de dónde sale K·u = R

#: No es una definición: **se deduce**, y Wilson la deduce en tres capítulos seguidos.

#| Lo que hace falta | Dónde está en Wilson |
#|---|---|
#| la relación tensión-deformación, la matriz `D` | **Cap. 1** — Material Properties, 1-1 a 1-12 |
#| el equilibrio y la compatibilidad | **Cap. 2** — Equilibrium and Compatibility, 2-1 a 2-11 |
#| el trabajo virtual y la energía de deformación | **Cap. 3** — Energy and Work, 3-2 a 3-9 |

#: La cadena, en corto. La energía de deformación de un elemento es
#: U = (1/2)·∫ ε^{T}·σ dV
#: Con `ε = B·u` (deformación a partir de los desplazamientos de los nudos) y `σ = D·ε` (tensión a partir de la deformación), queda
#: U = (1/2)·u^{T}·(∫ B^{T}·D·B dV)·u
#: y el paréntesis **es** la matriz de rigidez:
#: K = ∫ B^{T}·D·B dV
#: Haciendo estacionaria la energía total (Wilson 3-9, *Stationary Energy Principle*) sale `K·u = R`. **No hay nada más.** Todo lo demás es cómo se calcula esa integral.

## 3 · Cómo se calcula esa integral: el elemento isoparamétrico

#| Pieza | Wilson |
#|---|---|
#| funciones de forma en 1D, 2D y 3D | **Cap. 5** — Isoparametric Elements, 5-2 a 5-14 |
#| integración numérica (Gauss) en 1D | 5-4, *One-Dimensional Integration Formulas* |
#| integración numérica en 2D | 5-10, *Numerical Integration in Two Dimensions* |

#: El elemento real, torcido, se lleva a un **cuadrado de lado 2** donde integrar es fácil. El precio es el **jacobiano**, que mide cuánto se estira ese cambio de coordenadas.

## 4 · Cada elemento de Hekatan Struct, con su fuente

#: La tabla, corta para que se lea entera. **Debajo está el enlace de cada formulación**, con su desarrollo simbólico, luego numérico y su gráfica.

#| Elemento | Formulación | Wilson |
#|---|---|---|
#| **Barra** | Timoshenko con `As` | **Cap. 4**, 4-2 a 4-12 |
#| **Placa gruesa** | Reissner-Mindlin MITC | **Cap. 6**, 6-3 a 6-5 |
#| **Placa delgada** | DKQ de Kirchhoff | **Cap. 8** |
#| **Membrana con giro** | Allman + burbuja | **Cap. 9** |
#| **Cáscara** | membrana + placa | **Cap. 10** |
#| **Diafragma rígido** | cuerpo rígido en planta | **Cap. 7**, 7-6 |
#| **Condensación** | eliminar grados | **Cap. 8**, 8-10 |
#| **Suelo** | muelles de Winkler | Bowles |

#: Y las fuentes de fuera de Wilson: placa gruesa **Bathe & Dvorkin (1985)**; placa delgada **Batoz & Tahar (1982)**; membrana con giro **Ibrahimbegović, Taylor & Wilson (1990)**, IJNME 30:445-457 — que firma el propio Wilson.

## 4b · Cada formulación, abierta y con números

#: Cada una empieza en **símbolos**, sigue en **números** y acaba en **gráfica**. **Se abren con un clic** — o por su número, en el desplegable *ejemplos* de arriba:

#| N.º | Hoja | Qué desarrolla |
#|---|---|---|
#| **40** | [Shell-Thin, la placa delgada como ETABS y SAP2000](https://giorgioburbanelli89.github.io/hekatan-lisp/#ej=40%20Shell%20Thin%20-%20placa%20delgada%20como%20ETABS%20y%20SAP2000.lisp) | la formulación que usan los dos |
#| **41** | [Shell-Thin: primero simbólico, luego numérico](https://giorgioburbanelli89.github.io/hekatan-lisp/#ej=41%20Shell%20Thin%20-%20simbolico%20y%20luego%20numerico.lisp) | la `K` en símbolos y luego con cifras |
#| **42** | [Shell-Thin: Jacobiano, forma y Gauss](https://giorgioburbanelli89.github.io/hekatan-lisp/#ej=42%20Shell%20Thin%20-%20Jacobiano%20funciones%20de%20forma%20y%20Gauss.lisp) | las tres piezas de la integral |
#| **43** | [La teoría del Discrete Kirchhoff (DKQ)](https://giorgioburbanelli89.github.io/hekatan-lisp/#ej=43%20Placa%20DK%20-%20teoria%20del%20Discrete%20Kirchhoff%20y%20Shell-Thin.lisp) | de dónde sale el Shell-Thin |
#| **44** | [M_{11}, M_{22} y M_{12}: el elemento MZC](https://giorgioburbanelli89.github.io/hekatan-lisp/#ej=44%20M11%20M22%20M12%20por%20elementos%20finitos%20-%20el%20elemento%20MZC.lisp) | los momentos, elemento a elemento |
#| **39** | [Losa rectangular BFS](https://giorgioburbanelli89.github.io/hekatan-lisp/#ej=39%20Losa%20rectangular%20BFS%20-%20lo%20que%20el%20motor%20SI%20puede%20deducir.lisp) | lo que el motor sí deduce solo |
#| **64** | [La membrana en ETABS y SAP2000](https://giorgioburbanelli89.github.io/hekatan-lisp/#ej=64%20La%20membrana%20en%20ETABS%20y%20SAP2000%20-%20carga%20a%20las%20correas%20y%20masa%20del%20modal.lisp) | esfuerzos, correas y masa |
#| **11** | [Cáscara no lineal de Simo, Fox y Rifai](https://giorgioburbanelli89.github.io/hekatan-lisp/#ej=11%20Cascara%20no%20lineal%20-%20Simo-Fox-Rifai.lisp) | más allá de lo lineal |

#: Y el modelo entero, con sus doce modos: [el galpón curvo en Hekatan Struct](https://giorgioburbanelli89.github.io/hekatan-struct-lineal/workspace/?m=95IbfMcEkc2xvBS&modal=12)
## 5 · El análisis DINÁMICO

#| Pieza | Wilson |
#|---|---|
#| el equilibrio dinámico | **Cap. 12**, 12-2 *Dynamic Equilibrium* |
#| vibración libre sin amortiguamiento | **Cap. 12**, 12-8 *Undamped Free Vibrations* |
#| superposición modal | **Cap. 13**, 13-1 a 13-5 |
#| **participación de masa** | **Cap. 13**, **13-11** *Participating Mass Ratios* |
#| cálculo de los vectores propios | **Cap. 14**, *Calculation of Stiffness and Mass Orthogonal Vectors* |
#| P-Delta | **Cap. 11** |

#: La ecuación del capítulo 12 es la que se enseñó en la charla:
#: M·u'' + C·u' + K·u = −M·r·u_{g}''
#: Y al quitar el amortiguamiento y la carga queda el problema de valores propios (12-8):
#: (K − ω²·M)·φ = 0

## 6 · Los números: cuántos capítulos respaldan cada parte

n_est = dec(1 + 2 + 3 + 5, 0) [—] 'capítulos de Wilson que sostienen el estático (1, 2, 3 y 5)
n_elem = dec(4 + 6 + 7 + 8 + 9 + 10, 0) [—] 'suma de los capítulos de elementos y restricciones
n_din = dec(11 + 12 + 13 + 14, 0) [—] 'los de dinámica

#: No son adornos: cada uno responde por una parte concreta del motor.

## 7 · Los otros libros

#| Libro | Para qué |
#|---|---|
#| **Bathe** — *Finite Element Procedures* | el MITC4 de la placa gruesa, y los métodos de valores propios |
#| **Bathe & Wilson (1976)** — *Numerical Methods in Finite Element Analysis* | el linaje del solver; **SAP IV** (1973) es el último eslabón de código abierto de esta familia |
#| **Zienkiewicz & Taylor** — *The Finite Element Method* | la formulación general |
#| **Cook** — *Concepts and Applications of Finite Element Analysis* | los elementos en la práctica |
#| **Chandrupatla** — *Introduction to Finite Elements in Engineering* | la introducción, paso a paso |
#| **Aguiar** — *Dinámica de Estructuras con MATLAB* y *Reforzamiento de estructuras de lámina delgada* | el diafragma flexible y las masas puntuales del galpón |
#| **Braja M. Das** — *Principles of Foundation Engineering*, 9.ª ed. | la zapata, ejemplo 6.10 |

## 8 · Y la regla que lo cierra

#: **Ninguna fórmula entra en Hekatan Struct de memoria.** Sale de una fuente publicada y se comprueba contra **otro programa** con el mismo modelo y la misma malla, nudo a nudo.
#: Por eso el galpón y la zapata de esta charla están calculados en cinco sitios a la vez: Hekatan Struct, SAP2000, ETABS, SAFE y OpenSeesPy.
#: Un resultado que solo da un programa **no es un resultado**: es una opinión.
