# Hekatan LISP

[![Versión](https://img.shields.io/badge/versi%C3%B3n-1.0.0-blue)](https://github.com/GiorgioBurbanelli89/hekatan-lisp/releases)
[![Descargar](https://img.shields.io/badge/%E2%AC%87%20Descargar-Instalador%20Windows-success)](https://github.com/GiorgioBurbanelli89/hekatan-lisp/releases/latest)
[![Licencia](https://img.shields.io/badge/licencia-MIT-green)](#licencia)
[![Motor SBCL](https://img.shields.io/badge/motor-SBCL%20embebido-orange)](#créditos)

**Hekatan LISP** es un editor para **aprender y practicar cálculo simbólico** —la raíz histórica
del cálculo por computadora—. Escribís **matemática al estilo MATLAB** (la que ya conocés) y con un
botón la ves convertida a su **forma LISP**, que **se ejecuta de verdad** en un motor **SBCL**
(Steel Bank Common Lisp) **embebido** dentro de la app. Interfaz WPF + editor **AvalonEdit** con
resaltado, y **render matemático estilo Hekatan Lab**.

> La idea: en LISP **vos construís la función** (no hay `sum` mágico). Por eso la suma se escribe con
> el `for`, igual que en MATLAB, y el botón **⇒ a LISP** te muestra el `(loop …)` equivalente y lo corre.

> ⚙️ **Autocontenido:** el motor **SBCL viaja dentro del app** — no hace falta instalar LISP aparte.
> Windows 10/11 de 64 bits (requiere el runtime .NET 8).

---

## Novedades — v1.0.0

- **Matemática estilo MATLAB → LISP**: bucles `for i = 1:n`, `while`, `if/elseif/else`, funciones
  `function y = f(x)`, asignaciones, vectores `[1 2 3]` y matrices `[1 2; 3 4]` — **sin nombres de
  funciones de MATLAB**, porque la operación se arma con el loop (la filosofía de LISP).
- **Botón ⇒ a LISP**: pasa la matemática del editor a su forma LISP **y la ejecuta** (SBCL).
- **Motor real**: el LISP se corre de verdad; si el código devuelve un valor pero no lo imprime,
  Hekatan LISP lo muestra igual (en LISP el valor no se ve salvo que lo imprimas).
- **Editor AvalonEdit** con resaltado de sintaxis (LISP y matemática) y **render tipo libro**.

---

## Características principales

- **Cinco modos**: matemática → LISP · matemática → render · LISP → matemática · LISP → render ·
  **Calcular** (ejecuta en SBCL).
- **Conversión con árbol propio** (sin CAS): de la misma expresión salen LISP, MATLAB y el render
  matemático (fracciones, superíndices, `·`).
- **Programas imperativos**: `for` / `while` / `if` / `function` traducidos a `(loop …)`,
  `(cond …)`, `(defun …)` ejecutables.
- **Motor SBCL embebido**: define tus funciones y llámalas — se ejecutan al vuelo (deriv, simplif,
  o lo que escribas).
- **Render matemático estilo Hekatan Lab** en WebView2 (tema oscuro, math en serif).
- **Canal `--ctl`** para manejar la ventana desde la terminal (tests de regresión).

---

## Instalación

Descargá el instalador desde **[Releases](https://github.com/GiorgioBurbanelli89/hekatan-lisp/releases)**
y ejecutalo. El motor **SBCL va embebido** (no necesitás instalar LISP). Requiere el runtime **.NET 8**.

**Compilar desde el código:**

```bash
dotnet build -c Release
```

El build copia `sbcl.exe` + `sbcl.core` a la carpeta de salida (necesita SBCL instalado en la máquina
de compilación; en runtime ya viaja dentro del app).

---

## Cómo funciona

1. **Escribí** matemática estilo MATLAB en el panel izquierdo (ej.: un `for` que suma `1..n`).
2. Presioná **⇒ a LISP**: el editor pasa a la **forma LISP** y el panel derecho muestra el
   **resultado** (ejecutado por SBCL).
3. O usá los modos para ver el **render** matemático, o la vuelta **LISP → matemática**.

Ejemplo (menú *Archivo → Cargar ejemplo (loop)*):

```matlab
n = 100
s = 0
for i = 1:n
  s = s + i
end
s
```

⇒ a LISP:

```lisp
(let* ((n 0) (s 0))
  (setf n 100)
  (setf s 0)
  (loop for i from 1 to n do
    (setf s (+ s i)))
  s)          ; => 5050
```

---

## El lenguaje

Hekatan LISP entiende dos formas y las convierte entre sí:

### 1) Expresiones (matemática ↔ LISP ↔ render)

| Matemática | LISP | Render |
|---|---|---|
| `x^2 + 3*x` | `(+ (expt x 2) (* 3 x))` | x² + 3·x |
| `(x+1)^2` | `(expt (+ x 1) 2)` | (x+1)² |
| `3*x/2` | `(/ (* 3 x) 2)` | fracción 3·x / 2 |

### 2) Programas (matemática estilo MATLAB → LISP ejecutable)

| Matemática (MATLAB) | LISP |
|---|---|
| `s = s + i` | `(setf s (+ s i))` |
| `for i = 1:n` · `1:2:n` | `(loop for i from 1 to n [by 2] do …)` |
| `while cond` | `(loop while cond do …)` |
| `if / elseif / else` | `(cond …)` |
| `function y = f(n) … end` | `(defun f (n) (let* …) y)` |
| `[1 2 3]` · `[1 2; 3 4]` | `(vector …)` |
| `a == b` · `a ~= b` · `a <= b` | `(= a b)` · `(/= a b)` · `(<= a b)` |
| `f(x)` · `a^b` | `(f x)` · `(expt a b)` |

**Sin nombres de funciones de MATLAB**: no hay `sum(1:n)`; la suma se hace con el `for`, que es
justo lo que se pasa a LISP.

---

## Créditos

El **motor de ejecución** es **[SBCL — Steel Bank Common Lisp](https://www.sbcl.org/)** (dominio
público / licencia BSD-style), empaquetado dentro del app.

La **base de render e interfaz** (plantilla del reporte, panel WPF + WebView2, estilos de math)
sigue el estilo del proyecto **[Calcpad](https://codeberg.org/proektsoft/Calcpad)** de
**Nedelcho Ganchovski / PROEKTSOFT EOOD** (licencia MIT).

El resto —el **convertidor de árbol** matemática ↔ LISP ↔ MATLAB, el **traductor de programas**
(`for`/`while`/`function` → `loop`/`cond`/`defun`), el editor y los modos— es desarrollo propio de
**Hekatan Engineers**.

---

## Licencia

Distribuido bajo licencia **MIT**. Ver el archivo `LICENSE`. El crédito de la base de render/UI
corresponde a PROEKTSOFT EOOD® (Calcpad, MIT); el motor SBCL a sus autores.
