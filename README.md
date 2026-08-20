# Hekatan LISP

**Calculadora simbólica** de escritorio (WPF · .NET 8) con motor **LISP (SBCL)** embebido y render matemático a CSS — al estilo de Hekatan Lab.

Escribes matemática y texto en el panel izquierdo; el resultado aparece renderizado, bonito, a la derecha. Bajo el capó, tu notación se traduce a **LISP** y el motor la simplifica, deriva, integra y opera con matrices.

> Hereda el espíritu de **Calcpad** (Nedelcho Ganchovski) — hoja viva donde definición, fórmula y resultado conviven en la misma línea — llevado a un motor simbólico LISP propio.

---

## La regla madre

| Empieza con… | Es… |
|---|---|
| `#` | **texto** (markdown) |
| *(nada)* | **matemática** |
| `;` | **LISP** crudo |

Nada más. Una línea con `=` o una expresión suelta se **calcula y renderiza**; una línea con `#` es prosa con formato.

---

## Texto — markdown

```
# Título              ## Subtítulo         ### Sub-sub
#: párrafo (izquierda)
#| centrado           #> derecha           #< izquierda
**negrita**   *cursiva*   __negrita__   _cursiva_
@var          → "var = valor"     (variable inline)
@{expr}       → solo el valor     (mezcla texto + matemática)
```

## Matemática

```
A = [1 2; 3 4]           # definir matriz / vector / número
Inv = A^-1               # operación VISIBLE:  Inv = A⁻¹ = [resultado]
A'   A*B   A+B   1:5      # transpuesta · producto · suma · rango
f(x) = x^2 + 1  →  f(3)   # función y su aplicación  (= 10)
v(i)   A(i,j)   N_1        # índice de vector · de matriz · subíndice
Simplify{…}  Factor{…}  Expand{…}  Partial{f @ x}   # operaciones simbólicas
```

Las matrices siguen la sintaxis **MATLAB 2017a**: `,` o espacio = columna, `;` o salto de línea = fila, `...` = continuación. Se distingue **función** de **índice** por el contexto (cómo definiste el nombre), igual que MATLAB. Los vectores llevan **flecha** (`v → v⃗`).

---

## Qué sabe hacer el motor

- **Simbólico**: simplificar, factorizar, expandir, derivar (total y parcial `∂`), integrar (elemental), despejar, sumatorias/productos, sup/inf/find.
- **Funciones**: `f(x) = …` y su aplicación por sustitución (β-reducción): `f(3)`, `f(a)`, composición `f(g(x))`.
- **Álgebra de matrices**: transpuesta `A'`, producto `A*B`, suma, escala, **inversa** `A^-1` (Gauss-Jordan exacto, racionales), rango `1:n`. Verificado `A·A⁻¹ = I`.
- **Render** idéntico a Calcpad/Hekatan Lab: fracciones, ∫ Σ ∏ con límites apilados, sub/superíndices, letras griegas, paréntesis que crecen, matrices con corchetes.
- **Combinar** texto + operación + gráfica en una misma hoja.

---

## Exportar

Un botón lleva la hoja a **LISP** ejecutable (`(defun …)`) o a **Hekatan Lab** (MATLAB). El motor real es SBCL empaquetado, autocontenido (no hay que instalar nada).

---

## Estructura

```
hekatan-lisp/
├── LispConverter.cs   parser de "matemática" → árbol → LISP · y árbol → HTML/CSS
├── LispEngine.cs      puente a SBCL (deriva, integra, opera; engine.core horneado)
├── engine.lisp        el motor simbólico (partial, factor, expand, matrices, …)
├── MainWindow.xaml    la ventana (AvalonEdit izquierda + WebView2 derecha)
└── sbcl/              SBCL empaquetado + engine.core (motor precargado, ~3× más rápido)
```

---

## Rendimiento

El motor deriva una parcial en **~8 µs**. La app relanza SBCL por cálculo (~85 ms de arranque con el core horneado); para lotes conviene un proceso persistente.

---

*Parte del ecosistema **Hekatan**. El motor de cálculo de Calcpad es de Nedelcho Ganchovski; Hekatan LISP es una reimplementación simbólica sobre LISP con notación propia.*
