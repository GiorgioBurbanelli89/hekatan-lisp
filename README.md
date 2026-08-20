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
