# 20-sep-2026 — Unidades en Hekatan LISP: `3m|cm` (escritorio y web)

Pedido de Jorge: «usa `3m|cm` como Calcpad… ¿aparte de la forma Mathcad?».

## De dónde salió el modelo (no se inventó)

- **Mathcad Prime 10**, decompilando sus DLL con `ilspycmd` (son .NET):
  `mcdstaticunitsystem.dll` (catálogo) y `mcdstaticunitsystem{si,us,cgs,mks}.dll`
  (qué unidad se MUESTRA por dimensión). Su runtime es `McdRun`/`MplPrelude` con
  `Cons`: **Mathcad por dentro es LISP compilado a .NET**.
  - 8 dimensiones base, con **Money** incluida.
  - Exponentes en punto fijo ×60000 (`Value {Length 60000 Mass 60000 Time-120000}`
    = newton). 60000 es divisible por 2,3,4,5,6,8,10,12… para que ½ y ⅓ sean exactos.
  - Las derivadas son su FÓRMULA: `newton = m·kg/s²`, `pascal = N/m²`, `joule = N·m`.
  - Los prefijos son funciones: `kilo(pascal)`, `centi(meter)`.
- **Calcpad** (`Calcpad.Core/BaseTypes/Unit.cs` y `MathParser.Input.cs:GetTargetUnits`):
  `_powers` = float[9] con el ÁNGULO como dimensión, y la barra `|` al final de la
  expresión = unidad en la que se quiere VER el resultado.

## Lo que se hizo

- **`engine.lisp`, sección UNIDADES** (pegada ahí a propósito: es lo ÚNICO que se
  hornea en el core de SBCL **y** se compila dentro de `hlisp.wasm`, así que la web
  hereda lo mismo sin duplicar nada). Una cantidad es `(:q valor . dims)` con 8
  **racionales** de Lisp — exactos, sin necesitar el ×60000 de Mathcad. `q+ q- q* q/ q^`
  comprueban dimensiones; `u` arma unidades compuestas (`kN/m^2`, `kgf/cm2`, `cm2`);
  `qeval` interpreta el árbol; `qval` devuelve el número y `qshow` el texto.
  Registradas en `*op-calls*` para que `evops` las ejecute.
- **`LispUnidades.cs`**: parser propio de la línea con barra. No se usa `ParseMath`
  porque en esa línea las letras son UNIDADES, y mezclar las dos reglas rompería
  cualquier hoja que llame `m` a una masa.
- **`MainWindow.Pipeline.cs`**: detecta la barra al leer la línea, emite la forma
  `(qval …)` y pasa la unidad de destino como unidad VISIBLE.
- Web: `LispUnidades.cs` añadido a `HekatanLispWeb.csproj` (comparte los .cs por Link),
  motor recompilado (`3_motor_aot.sh` + `4_enlazar_hlisp_wasm.sh`) y copiado a wwwroot.

## ✅ Medido

| hoja | escritorio | wasm (web) |
|---|---|---|
| `3m\|cm` | 300.0000 cm | 300.0000 |
| `2.5in\|mm` | 63.5000 mm | 63.50 |
| `606kN/1.193m^2\|tonf/m2` | 51.7978 tonf/m2 | 51.7978 |
| `2000tonf/m^3\|kN/m^3` | 19613.3000 kN/m³ | 19613.3000 |
| `3m+2s\|m` | ⚠ no se puede sumar longitud^1 con tiempo^1 | igual |

## ❌ Lo que costó (no repetir)

- `606kN/1.193m^2` se leía `(606·kN/1.193)·m²` → dimensión longitud³ en vez de presión.
  **La multiplicación PEGADA liga más fuerte que la barra de dividir**; hay un nivel
  `Implicito()` entre `Termino()` y `Potencia()` justo por eso.
- La unidad se perdía al dibujar: el resultado `«300.0000 cm»` vuelve a pasar por el
  render matemático y se queda en el número. Por eso el motor devuelve SOLO el número
  (`qval`) y la unidad va por el camino del `[kN]` visible.
- Definir dos veces la misma variable en una hoja (primero la fórmula simbólica y luego
  con valores) hace que el motor ARRASTRE la expresión entera: salían monstruos de
  media página. **Una variable, una definición.**

## ⏳ Falta

- Que una VARIABLE de la hoja lleve unidad y se propague (`B = 1.5m` y luego usar `B`).
  Hoy la barra trabaja con literales y unidades dentro de su propia línea.
- Publicar la web (`dotnet publish` + `6_publicar_gh_pages.sh`) cuando Jorge lo pida.
