# Bitácora — Rectangular Slab FEA (Calcpad) en Hekatan LISP

Objetivo: que Hekatan LISP corra ejemplos como los de Calcpad (bucles, matrices,
ensamblaje, solver, mapas) y replicar `Rectangular Slab FEA.cpd` con los mismos
números que Calcpad (oráculo: `calcpad-examples/Rectangular Slab FEA.html`).

## 2026-09-24

### Diagnóstico inicial
- ✅ Build de la app (`dotnet build -c Release`) en 11 s.
- ❌ Los bloques `for … end` dentro de una hoja NO se ejecutaban: la regex que los
  detecta (`MainWindow.Pipeline.cs`, ComputeResultCore) tenía un carácter
  RETROCESO (0x08) literal donde debía ir `\b`. Nunca casaba → el `for` se pintaba
  como «for = 1 : 4». Bug del motor, no de la hoja.
- ❌ Aunque plegara, el bloque corría APARTE: sus variables no volvían a la hoja
  (t_s = s + 1 daba 1). No había estado compartido.
- ❌ El traductor MATLAB→LISP no tenía índices `A(i,j)`, asignación indexada,
  rangos `a:b`, `'`, `\`, `&&`, `||`, funciones anónimas; `·` se comía el resto
  de la línea (n_a·n_b → n_a).
- ❌ La hoja trabaja en racionales exactos: D sale 3500/1173… (Calcpad: 2.983802).
- ❌ Nombres de función con prima (Φ′) pierden el subíndice y los argumentos.

### Plan (motor, general — no un truco para este ejemplo)
1. Runtime numérico en `engine.lisp` (escalares, vectores, matrices; + − · / ^ con
   difusión, producto matricial, `'`, `\`, índices y asignación indexada con
   rangos, funciones de Calcpad y de MATLAB, integral/integral2, spline).
2. Traductor ampliado (`MatlabToLisp.cs`): índices, rangos, lógicos, `@(x) …`,
   nombres sensibles a mayúsculas (`|e|` ≠ `|E|`), funciones de la hoja como
   clausuras.
3. `#numerico` en la hoja: un solo programa SBCL (hoja + bloques en orden) con
   estado compartido; cada línea muestra fórmula = valor (doble precisión, formato
   de Calcpad). Directivas de Calcpad `#hide/#show`, `#noc/#equ/#val`.
4. `#map` en modo numérico evaluado por el motor numérico (rejilla).

### Motor (hecho)
- ✅ `engine.lisp`: runtime numérico `hn-*`/`hnb-*` (≈440 líneas): + − · / ^ con difusión,
  producto matricial, `'`, `\`, `.*` `./` `.^`, rangos `a:b:c`, índices y asignación
  indexada con rangos y `:` (crece como MATLAB), `[a, b; c, d]` con bloques,
  biblioteca MATLAB + Calcpad (zeros, eye, size, sum, max, round, row, col,
  submatrix, slice, extract, take, add, linspace, det, inv, lsolve, **clsolve =
  Cholesky por perfil como Calcpad.Core**), `integral`/`integral2` (Gauss-Legendre
  adaptativa, integrando matricial), `spline` (algoritmo de Calcpad.Core
  Matrix.Spline/Vector.Spline, sacado del código fuente).
- ✅ `HojaNumerica.cs` (nuevo): traductor sensible a mayúsculas (`|e|` ≠ `|E|`),
  funciones de la hoja → clausuras, `@(x) …`, `function … end` → defun, palabras
  de bloque de Calcpad (`#for … #loop`, `#if … #else if … #end if`), un único
  programa SBCL por hoja con `handler-case` por línea (un error no tumba la hoja).
- ✅ `#numerico` en `MainWindow.Pipeline.cs`: `#hide/#show`, `#noc/#equ/#val` de
  Calcpad; bloque plegable (código a un clic, como el #hide de Calcpad pero visible);
  «nombre = fórmula = valor» con formato de Calcpad (6 decimales, 7 cifras si |x|<1,
  10ⁿ, y el umbral de cero de Calcpad HtmWriter: 1e-14·máx en matrices).
- ✅ `#map(f(x, y), [xa xb], [ya yb])` en modo numérico: la rejilla la calcula el
  motor (sirve cualquier función de la hoja); planta con su proporción real.
- ✅ `#malla(x_j, y_j, e_j, s_j)`: dibuja la malla DEL MODELO (numeración real,
  apoyos). ❌ antes: `#malla(6, 4, …)` numeraba por filas y el modelo de Calcpad por
  columnas → el dibujo contradecía al cálculo.
- ✅ `FnNameHtml`: primas con token (`Φprime_1a` → Φ′₁ₐ) también en nombres de función.
- ✅ Números negativos ya no ponen rayas separadoras en toda una matriz.
- ❌→✅ Tiempo: 4–6 s por hoja en la app. Medido: compilar el programa 0.57 s,
  correrlo 0.25 s; el resto era la app corriendo la hoja DOS veces en --html (al
  abrir y al exportar) y esperando el candado del servidor. Con
  `(optimize (compilation-speed 3))` la compilación baja a 0.37 s.

### Verificación contra Calcpad (oráculo = su HTML)
- ✅ 849 valores comparados (D, K_e triángulo superior, F_e, K 20×21 visibles, F, Z,
  W_z, w, Z_e(15), M_e, M_j, Mx, My, Mxy y máximos): **0 distintos a 4 decimales**;
  máx. diferencia relativa 3.9·10⁻⁷ (= el redondeo a 7 cifras del HTML de Calcpad).
- ⏳ Ruido de redondeo ~1e-14 donde Calcpad escribe 0 (Z_e(15)[8], M_e[3]): con
  clsolve (Cholesky) bajó de 2.4e-13 a 1.2e-14; el vector no llega al umbral de
  Calcpad (min(1e-14·máx, 1e-14)). A 4 decimales es 0.
- ✅ PNG revisados: malla, K_e, K, Z, W_z, mapas de w, Mx, My, Mxy (0 errores JS).

### Regresión (las 82 hojas de ejemplos, motor viejo vs nuevo, texto del HTML)
- ✅ 64 idénticas; 14 con el mismo texto (solo cambian ids aleatorios o se quitan las
  rayas de columna que ponía un número negativo); 2 cambian solo el tic/toc (tiempo).
- ❌→✅ Hoja 69 (placa base, `#modo memoria`): salía unas veces con las fórmulas
  sustituidas y otras no. No era de este cambio: `--html` corría la hoja DOS veces a la
  vez (al abrir y al exportar) y los campos `_sinSustituir`/`_op` se pisaban. Arreglado:
  un solo cálculo a la vez (`lock` en ComputeResult) y `--html` espera el cálculo ya
  lanzado. 3/3 corridas iguales. De paso la losa bajó de 4–6 s a 0.66 s.
- ⏳ Cada `--html` deja una carpeta `HekatanLispWV2_<pid>` (~15 MB) en %TEMP%. Borré las
  183 de esta sesión (el disco llegó a 0.9 GB libres). Falta que la app la borre al salir.

### Pruebas
- ✅ `tests/numerico/test_hn_runtime.lisp` (SBCL, sin la app): 36/36.
- ✅ `tests/numerico/test_hoja_numerica.py`: hoja básica 19/19 + losa contra Calcpad
  (849 valores, 0 distintos a 4 decimales, 5 gráficas, 0 errores).

### Tarea aparte: divisor arrastrable y Ctrl + rueda (como Hekatan Lab 6dc944d / 83d1b3e)
- ✅ El divisor YA era arrastrable en LISP (GridSplitter Width=6 en columna de 6 px,
  PreviousAndNext, SizeWE). Medido con --ctl «layout» + ratón real: editor 550 → 350 DIP,
  resultado 550 → 750 (300 px físicos a 150 %).
- ❌ Primer intento de arrastre «no movía nada»: bajo el divisor estaba una consola
  PowerShell a pantalla completa, capa transparente, por encima de la app (WindowFromPoint
  lo dijo). No era la app. El test ahora pone su ventana SIEMPRE ENCIMA y comprueba con
  WindowFromPoint que el punto es de la app antes de apretar; si no, no toca el ratón.
- ✅ Ctrl + rueda sobre el editor: ahora ±2 pt entre 6 y 40 (antes ±1.5 entre 8 y 48),
  igual que Lab. Real: 15 → 19 → 15 pt. Ops --ctl nuevas «zoom» y «layout».
- ⏳ Entrada sintética algo inestable: de 3 corridas, 2 TODO OK y 1 con la rueda
  perdida (el ratón tiene que moverse sobre el editor antes; el test ya lo hace).

### Cierre
- ✅ Motor portable a ECL (web): `hn-fmt` usaba `sb-ext:` sin `#+sbcl` y habría roto
  el horneado de hlisp.wasm. El C# de la web compila (0 errores, solo compilación).
- ⏳ Web: falta rehornear `hlisp.wasm` con el engine.lisp nuevo para que `#numerico`
  corra en el navegador.
- ⏳ Siguiente motor: `$Plot` numérico (#fplot evaluado por el programa, como #map):
  es lo que más ejemplos de Calcpad bloquea (≈ 90 de 298). Después: `$Root/$Find`
  (≈ 14), `#def` (≈ 44; hoy se expande a mano), dibujos SVG con valores, `?` entradas.
- Tiempo de la losa (una corrida): 0.66–0.69 s en la app (traducir + compilar el
  programa en SBCL + calcular); cálculo puro 0.23 s (integrales, ensamblaje 140×140,
  Cholesky, momentos, 4 rejillas de mapa).
