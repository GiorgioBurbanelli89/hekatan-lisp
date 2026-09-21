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

#| Elemento de Hekatan | Formulación | Fuente |
#|---|---|---|
#| **Barra** (columna, viga, cordón) | viga de Timoshenko con áreas de cortante | Wilson **Cap. 4**, 4-2 a 4-12 (*One-Dimensional Elements*, incluye *Member End-Releases*) |
#| **Placa gruesa** (`shelltype thick`) | Reissner-Mindlin tipo MITC + modos incompatibles | Bathe & Dvorkin (1985); modos incompatibles en Wilson **Cap. 6**, 6-3 a 6-5 |
#| **Placa delgada** (`shelltype thin`) | DKQ de Kirchhoff | Batoz & Tahar (1982); y Wilson **Cap. 8**, *Plate Bending Elements* |
#| **Membrana con giro** (*drilling*) | Allman + burbuja, el giro dentro del campo de desplazamientos | **Ibrahimbegović, Taylor & Wilson (1990)**, IJNME 30:445-457; y Wilson **Cap. 9**, *Membrane Element with Normal Rotations* |
#| **Cáscara** (membrana + placa) | cáscara plana ensamblada | Wilson **Cap. 10**, *Shell Elements* |
#| **Diafragma rígido** | restricción de cuerpo rígido en planta | Wilson **Cap. 7**, **7-6** *Floor Diaphragm Constraints* y 7-11 *Rigid Constraints* |
#| **Condensación estática** | eliminar grados que no interesan | Wilson **Cap. 8**, 8-10, y **Apéndice C**, *Partial Gauss Elimination, Static Condensation* |
#| **Suelo** | muelles de Winkler, módulo de balasto | Bowles, *Foundation Analysis and Design*; el no lineal es contacto unilateral |

#: **Aquí está lo importante:** el elemento de membrana con giro que usa Hekatan es de un artículo que **firma el propio Wilson** (1990), y tiene capítulo en su libro. No es una formulación heredada de nadie: es la publicada.

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
