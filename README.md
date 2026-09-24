# Hekatan LISP

[![Licencia](https://img.shields.io/badge/licencia-MIT-green)](#licencia) [![Windows](https://img.shields.io/badge/plataforma-Windows%2010%2F11-blue)]() [![.NET 8](https://img.shields.io/badge/.NET-8-purple)]()

**Calculadora simbólica** de escritorio (WPF · .NET 8) con motor **LISP (SBCL)** embebido y render matemático a CSS — al estilo de Hekatan Lab / Calcpad.

Escribes matemática y texto en el panel izquierdo; el resultado aparece renderizado, bonito, a la derecha. Bajo el capó tu notación se traduce a **LISP** y el motor la simplifica, deriva, integra y opera con matrices. El SBCL va **empaquetado** (autocontenido, no instalas nada).

> Hereda el espíritu de **Calcpad** (Nedelcho Ganchovski) — hoja viva donde definición, fórmula y resultado conviven en la misma línea — sobre un motor simbólico LISP propio.

---

## La regla madre

| Empieza con… | Es… |
|---|---|
| `#` | **texto** (markdown) |
| *(nada)* | **matemática** |
| `;` | **LISP** crudo |

Una línea con `=` o una expresión suelta se **calcula y renderiza**; una línea con `#` es prosa con formato. Nada más que aprender para empezar.

---

## Texto — markdown

| Escribes | Resultado |
|---|---|
| `# Título` · `## Subtítulo` · `### Sub-sub` | encabezados **H1 / H2 / H3** |
| `#: texto` | párrafo (izquierda) |
| `#\| texto` · `#> texto` · `#< texto` | centrado · derecha · izquierda |
| `**negrita**` · `*cursiva*` | inline (también `__` y `_`) |
| `@var` | inserta **"var = valor"** en el texto |
| `@{expr}` | inserta **solo el valor** (mezcla texto + matemática) |

---

## Matemática — operaciones simbólicas

Cada operación se escribe `Nombre{ f @ variable = a : b }` (los campos sobrantes se omiten). Se ven **en la misma línea**: `Nombre = operación = resultado`.

| Operación | Qué hace |
|---|---|
| `Simplify{f}` | junta términos semejantes y compacta |
| `Factor{f}` | factoriza (lo contrario de expandir) |
| `Expand{f}` | distribuye productos y potencias |
| `Partial{f @ x}` | derivada **parcial** `∂f/∂x` |
| `Derivate{f @ x}` | derivada **total** `df/dx` |
| `Integral{f @ x}` | integral indefinida `∫ f dx` (elemental) |
| `Area{f @ x = a : b}` | integral **definida** (área bajo la curva) |
| `Slope{f @ x = a}` | pendiente = derivada evaluada en `x = a` |
| `Sum{f @ i = a : b}` | sumatoria `Σ` (numérica; simbólica = notación) |
| `Product{f @ i = a : b}` | productoria `Π` |
| `Root{f @ x}` | raíz: despeja `f = 0` |
| `Find{f @ x = a : b}` | busca la raíz en `[a, b]` (numérico) |
| `Sup{f}` · `Inf{f}` | máximo / mínimo (numérico) |
| botón **despejar** | resuelve la ecuación `lhs = rhs` para una variable |

Las **letras griegas** se escriben por su nombre (`theta` → θ, `gamma` → γ…) y las derivadas parciales se escriben con `∂` (`{∂N/∂s}` en un comentario). Los botones de arriba (`simplify · expand · diff · ∫ · despejar`) aplican la operación a toda la hoja.

## Funciones

| Escribes | Resultado |
|---|---|
| `f(x) = x^2 + 1` | **define** la función (se dibuja, no se calcula) |
| `f(3)` | la **aplica**: `3² + 1 = 10` (β-reducción, como Macsyma) |
| `f(a)` | simbólico: `a² + 1` |
| `f(g(x))` | composición |
| `N_1(x)` | el subíndice del nombre baja: **N₁(x)** |

## Matrices — sintaxis MATLAB 2017a

`,` o espacio = columna · `;` o salto de línea = fila · `...` = continuación.

| Escribes | Resultado |
|---|---|
| `A = [1 2; 3 4]` | definir matriz / vector / número |
| `A'` | transpuesta `Aᵀ` |
| `A*B` · `A+B` · `s*A` | producto · suma · escala |
| `A^-1` | **inversa** (Gauss-Jordan, racionales exactos) |
| `1:5` · `1:2:9` | rango `[1 2 3 4 5]` · con paso |
| `v(i)` · `A(i,j)` | **índice** de vector / matriz (por contexto, no confunde con función) |

Los **vectores llevan flecha** (`v` → **v⃗**). La operación se muestra completa: `Inv = A⁻¹ = [ … ]`, y se verifica `A·A⁻¹ = I`.

---

## Hoja numérica — `#numerico` (como Calcpad)

Con una línea `#numerico` la hoja entera es **un programa con estado**: bucles, matrices grandes,
ensamblaje y solución, como en Calcpad. Las variables que un bucle modifica las leen las líneas
siguientes. Cada línea se muestra `nombre = fórmula = valor` (doble precisión, formato de Calcpad).

| Escribes | Hace |
|---|---|
| `for i = 1:n` · `while c` · `if … elseif … else` · `end` | bloques (sintaxis MATLAB) |
| `#for i = 1 : n` … `#loop` · `#if` … `#else if` … `#end if` | lo mismo, con las palabras de Calcpad |
| `A(i, j) = x` · `K(g, g) = K(g, g) + K_e` · `M(:, j)` · `a:b:c` | índices, rangos, asignación indexada |
| `A'` · `A*B` · `A` · `.*` `./` `.^` · `[a, b; c, d]` | álgebra de matrices |
| `f(x, y) = …` · `g = @(x) …` · `function y = f(a) … end` | funciones |
| `zeros` `eye` `size` `sum` `max` `round` `row` `col` `submatrix` `slice` `extract` `take` `add` | biblioteca (MATLAB y Calcpad) |
| `lsolve(A, b)` · `clsolve(A, b)` (Cholesky) · `inv` · `det` | sistemas |
| `integral(f, a, b)` · `integral2(f, a, b, c, d)` · `spline(u, v, M)` | integrales (también de matrices) e interpolación de Calcpad |
| `#hide` / `#show` · `#noc` / `#equ` / `#val` | visibilidad y modo de ecuación de Calcpad |
| `#map(f(x, y), [xa xb], [ya yb])` · `#malla(x_j, y_j, e_j, s_j)` | mapa de color y malla del modelo |

Los nombres distinguen mayúsculas (`e` ≠ `E`). Ejemplo completo: `ejemplos/71 Losa rectangular por elementos finitos (Rectangular Slab FEA de Calcpad).lisp`
(849 números de Calcpad, iguales a 4 decimales). Pruebas: `tests/numerico/`.

---

## Dibujo AutoLISP — `#autolisp` … `#fin` (2D y 3D)

**El código es la lista de datos**: una entidad es una lista DXF de LISP, `((0 . "LINE") (8 . "0") (10 0 0) (11 3 4))`,
que se arma con `list`/`cons`/`mapcar`, se transforma y se pone en el dibujo con `entmake`; `ssget`/`entget` la leen
de vuelta para seguir calculando. Semántica real de AutoCAD: el bloque AutoLISP puro corre igual en AutoCAD 2027
(juez: `tests/autolisp/juez_autocad.py`, accoreconsole, entidad a entidad, x y z a 1e-9).

```
#autolisp("Título", ancho = 160, alto = 110, vert = 1, exporta = n A, nuevo = no)
(entmake (list '(0 . "LINE") '(10 0 0) (cons 11 (polar '(0 0) (/ pi 6) 5))))
(setq n (sslength (ssget "_X" '((0 . "LINE")))))
#fin
```

| Nivel | Funciones |
|---|---|
| AutoLISP (portable) | `entmake` `entmakex` `entget` `entmod` `entdel` `entlast` `entnext` `entupd` `handent` · `ssget "_X"` (filtros, comodines, `-4`) `sslength` `ssname` `ssadd` `ssdel` `ssmemb` · `tblsearch` `getvar` `setvar` · `polar` `distance` `angle` `inters` · `strcat` `itoa` `atoi` `atof` `rtos` `angtos` `strlen` `substr` `strcase` `wcmatch` `fix` · `repeat` `foreach` `while` · `(defun f (a / locales) …)`, `'(lambda …)`, `(princ)` |
| Entidades | POINT, LINE, CIRCLE, ARC, LWPOLYLINE, POLYLINE 2D/3D (+VERTEX, SEQEND), 3DFACE, TEXT, MTEXT, SOLID, HATCH, DIMENSION; capas con `(0 . "LAYER")` |
| Capa simple (español) | `punto` `linea` `circulo` `arco` (grados) `poli` `rect` `texto` `formula` (rótulo con la matemática de la hoja) `cota` `achurado` `curva` `curva-par` `ejes` `capa` · 3D: `poli3` `cara3` `flecha3` `vista` · listas: `desplazar` `rotar` `escalar` · medir: `longitud` `area` `vertices` `dxf` · `vertical` `guardar` |

Las definiciones de la hoja de arriba (`L = 6`, `f(x) = x^2`) llegan al bloque; las de `exporta` vuelven como `n = …`.
El dibujo sale en SVG con encuadre automático, colores ACI y capas; con z se ve en 3D y se gira con el ratón
(Planta · Frente · Lateral · 3D). **Guardar**: `(guardar "x.dxf")` — el formato lo da la extensión: `.dxf` (R12),
`.svg`, `.png`, `.pdf`, `.dwg` (acadrust; en escritorio necesita Node) — o los botones bajo cada dibujo, o
Archivo → *Guardar dibujo como…*. Un programa LISP entero que dibuja (sin `#autolisp`) también se pinta.
Ejemplos: 79 (derivada, tangente y área + zapata paramétrica) y 80 (cáscara alabeada 3D). Pruebas: `tests/autolisp/`.

---

## Las cuatro vistas

**Izquierda (cómo escribes):** `matemática` · `expr LISP` (`(setf name forma)`) · `LISP ▶` (script ejecutable) · `Hekatan Lab` (código MATLAB).

**Derecha (cómo ves el resultado):** `Render CSS` (matemática dibujada) · `LISP` · `matemática` · `3 formas` (las tres juntas, para aprender).

Cuando no hay script, la derecha muestra una **guía de bienvenida** (como el `help.html` de Calcpad).

---

## Render

Idéntico a Calcpad/Hekatan Lab: fracciones, `∫ Σ ∏` con límites apilados, sub/superíndices, letras griegas, **paréntesis que crecen** con el contenido, matrices con corchetes, tema claro/oscuro.

## Estructura

```
hekatan-lisp/
├── LispConverter.cs   parser "matemática" → árbol → LISP · y árbol → HTML/CSS
├── LispEngine.cs      puente a SBCL (deriva, integra, opera; engine.core horneado)
├── engine.lisp        el motor simbólico (partial, factor, expand, matrices, …)
├── MainWindow.xaml    la ventana (AvalonEdit izquierda + WebView2 derecha)
└── sbcl/              SBCL empaquetado + engine.core (motor precargado, ~3× más rápido)
```

## Rendimiento

El motor deriva una parcial en **~8 µs**. La app relanza SBCL por cálculo (~85 ms de arranque con el core horneado); para lotes conviene un proceso persistente.

## Licencia

MIT.

---

*Parte del ecosistema **Hekatan**. El motor de cálculo de Calcpad es de Nedelcho Ganchovski; Hekatan LISP es una reimplementación simbólica sobre LISP con notación propia.*
