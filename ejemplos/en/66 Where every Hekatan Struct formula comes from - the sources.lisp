# Where every Hekatan Struct formula comes from: the sources

#: A calculation program is not worth what it shows on screen, but **where each line came from**. Here is the origin of each piece, with chapter and page.
#: The main reference is **Edward L. Wilson, "Three-Dimensional Static and Dynamic Analysis of Structures"**, Computers and Structures Inc., Berkeley, 3rd ed., 2002. Wilson wrote the original SAP, and that book is the formulation from which the SAP2000 / ETABS / SAFE family descends.

## 1 · What the finite element method is

#: A real structure has **infinitely many** points, and therefore infinitely many displacements. It cannot be solved that way.
#: The method does three things, in this order:

#| Paso | Qué se hace | Qué se gana |
#|---|---|---|
#| **partir** | se corta la estructura en trozos (elementos) unidos por nudos | de infinitos puntos a unos pocos |
#| **interpolar** | dentro de cada trozo, el desplazamiento se supone una función sencilla `N` | el interior queda descrito por los nudos |
#| **integrar** | se suma la energía de cada trozo | sale la rigidez `K` |

#: And in the end **a single equation** remains, the same as in all of statics:
#: K · u = R
#: With `K` the stiffness, `u` the displacements we do not know and `R` the loads.

## 2 · The STATIC analysis: where K·u = R comes from

#: It is not a definition: it is **derived**, and Wilson derives it in three consecutive chapters.

#| Lo que hace falta | Dónde está en Wilson |
#|---|---|
#| la relación tensión-deformación, la matriz `D` | **Cap. 1** — Material Properties, 1-1 a 1-12 |
#| el equilibrio y la compatibilidad | **Cap. 2** — Equilibrium and Compatibility, 2-1 a 2-11 |
#| el trabajo virtual y la energía de deformación | **Cap. 3** — Energy and Work, 3-2 a 3-9 |

#: The chain, in short. The strain energy of an element is
#: U = (1/2)·∫ ε^{T}·σ dV
#: With `ε = B·u` (strain from the nodal displacements) and `σ = D·ε` (stress from the strain), it becomes
#: U = (1/2)·u^{T}·(∫ B^{T}·D·B dV)·u
#: and the parenthesis **is** the stiffness matrix:
#: K = ∫ B^{T}·D·B dV
#: Making the total energy stationary (Wilson 3-9, *Stationary Energy Principle*) gives `K·u = R`. **There is nothing else.** Everything else is how that integral is computed.

## 3 · How that integral is computed: the isoparametric element

#| Pieza | Wilson |
#|---|---|
#| funciones de forma en 1D, 2D y 3D | **Cap. 5** — Isoparametric Elements, 5-2 a 5-14 |
#| integración numérica (Gauss) en 1D | 5-4, *One-Dimensional Integration Formulas* |
#| integración numérica en 2D | 5-10, *Numerical Integration in Two Dimensions* |

#: The real, skewed element is mapped to a **square of side 2** where integrating is easy. The price is the **Jacobian**, which measures how much that change of coordinates stretches.

## 4 · Each Hekatan Struct element, with its source

#: The table, kept short so it can be read whole. **Below is the link to each formulation**, with its symbolic development, then numeric and its plot.

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

#: And the sources outside Wilson: thick plate **Bathe & Dvorkin (1985)**; thin plate **Batoz & Tahar (1982)**; membrane with drilling rotation **Ibrahimbegović, Taylor & Wilson (1990)**, IJNME 30:445-457 — signed by Wilson himself.

## 4b · Each formulation, opened and with numbers

#: Each one starts in **symbols**, continues in **numbers** and ends in a **plot**. **They open with one click:**

#| N.º | Hoja | Qué desarrolla |
#|---|---|---|
#| **40** | [Shell-Thin, la placa delgada como ETABS y SAP2000](https://giorgioburbanelli89.github.io/hekatan-lisp/#ej=40%20Shell%20Thin%20-%20placa%20delgada%20como%20ETABS%20y%20SAP2000.lisp) | la formulación que usan los dos |
#| **41** | [Shell-Thin: primero simbólico, luego numérico](https://giorgioburbanelli89.github.io/hekatan-lisp/#ej=41%20Shell%20Thin%20-%20simbolico%20y%20luego%20numerico.lisp) | la rigidez en símbolos y luego con cifras |
#| **42** | [Shell-Thin: Jacobiano, forma y Gauss](https://giorgioburbanelli89.github.io/hekatan-lisp/#ej=42%20Shell%20Thin%20-%20Jacobiano%20funciones%20de%20forma%20y%20Gauss.lisp) | las tres piezas de la integral |
#| **43** | [La teoría del Discrete Kirchhoff (DKQ)](https://giorgioburbanelli89.github.io/hekatan-lisp/#ej=43%20Placa%20DK%20-%20teoria%20del%20Discrete%20Kirchhoff%20y%20Shell-Thin.lisp) | de dónde sale el Shell-Thin |
#| **44** | [M_{11}, M_{22} y M_{12}: el elemento MZC](https://giorgioburbanelli89.github.io/hekatan-lisp/#ej=44%20M11%20M22%20M12%20por%20elementos%20finitos%20-%20el%20elemento%20MZC.lisp) | los momentos, elemento a elemento |
#| **39** | [Losa rectangular BFS](https://giorgioburbanelli89.github.io/hekatan-lisp/#ej=39%20Losa%20rectangular%20BFS%20-%20lo%20que%20el%20motor%20SI%20puede%20deducir.lisp) | lo que el motor sí deduce solo |
#| **64** | [La membrana en ETABS y SAP2000](https://giorgioburbanelli89.github.io/hekatan-lisp/#ej=64%20La%20membrana%20en%20ETABS%20y%20SAP2000%20-%20carga%20a%20las%20correas%20y%20masa%20del%20modal.lisp) | esfuerzos, correas y masa |
#| **11** | [Cáscara no lineal de Simo, Fox y Rifai](https://giorgioburbanelli89.github.io/hekatan-lisp/#ej=11%20Cascara%20no%20lineal%20-%20Simo-Fox-Rifai.lisp) | más allá de lo lineal |

#: And the whole model, with its twelve modes: [the curved shed in Hekatan Struct](https://giorgioburbanelli89.github.io/hekatan-struct-lineal/workspace/?m=95IbfMcEkc2xvBS&modal=12)
## 5 · The DYNAMIC analysis

#| Pieza | Wilson |
#|---|---|
#| el equilibrio dinámico | **Cap. 12**, 12-2 *Dynamic Equilibrium* |
#| vibración libre sin amortiguamiento | **Cap. 12**, 12-8 *Undamped Free Vibrations* |
#| superposición modal | **Cap. 13**, 13-1 a 13-5 |
#| **participación de masa** | **Cap. 13**, **13-11** *Participating Mass Ratios* |
#| cálculo de los vectores propios | **Cap. 14**, *Calculation of Stiffness and Mass Orthogonal Vectors* |
#| P-Delta | **Cap. 11** |

#: The equation of chapter 12 is the one taught in the talk:
#: M·u'' + C·u' + K·u = −M·r·u_{g}''
#: And removing the damping and the load leaves the eigenvalue problem (12-8):
#: (K − ω²·M)·φ = 0

## 6 · The numbers: how many chapters back each part

n_est = dec(1 + 2 + 3 + 5, 0) [—] 'Wilson chapters that support the static analysis (1, 2, 3 and 5)
n_elem = dec(4 + 6 + 7 + 8 + 9 + 10, 0) [—] 'sum of the chapters on elements and constraints
n_din = dec(11 + 12 + 13 + 14, 0) [—] 'those of dynamics

#: They are not decoration: each one answers for a specific part of the engine.

## 7 · The other books

#| Libro | Para qué |
#|---|---|
#| **Bathe** — *Finite Element Procedures* | el MITC4 de la placa gruesa, y los métodos de valores propios |
#| **Bathe & Wilson (1976)** — *Numerical Methods in Finite Element Analysis* | el linaje del solver; **SAP IV** (1973) es el último eslabón de código abierto de esta familia |
#| **Zienkiewicz & Taylor** — *The Finite Element Method* | la formulación general |
#| **Cook** — *Concepts and Applications of Finite Element Analysis* | los elementos en la práctica |
#| **Chandrupatla** — *Introduction to Finite Elements in Engineering* | la introducción, paso a paso |
#| **Aguiar** — *Dinámica de Estructuras con MATLAB* y *Reforzamiento de estructuras de lámina delgada* | el diafragma flexible y las masas puntuales del galpón |
#| **Braja M. Das** — *Principles of Foundation Engineering*, 9.ª ed. | la zapata, ejemplo 6.10 |

## 8 · And the rule that closes it

#: **No formula enters Hekatan Struct from memory.** It comes from a published source and is checked against **another program** with the same model and the same mesh, node by node.
#: That is why the shed and the footing of this talk are calculated in five places at once: Hekatan Struct, SAP2000, ETABS, SAFE and OpenSeesPy.
#: A result that only one program gives **is not a result**: it is an opinion.
