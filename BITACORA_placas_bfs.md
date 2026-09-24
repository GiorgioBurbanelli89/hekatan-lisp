# Bitácora — Ejemplos de placas con malla BFS (Hekatan LISP)

Objetivo: ejemplos 73… de losas con el elemento BFS (16 GDL, Hermite) del ejemplo 71,
cada uno verificado contra OTRO programa (Calcpad, misma malla nudo a nudo) y contra la
solución publicada (Timoshenko & Woinowsky-Krieger, Navier/Lévy).

## 2026-09-24

### Plan
- Oráculo 1: **Calcpad CLI** (`Calcpad-Suite/Calcpad.Cli/bin/Release/net10.0/Cli.exe`) corriendo
  variantes de `Rectangular Slab FEA.cpd` (misma malla, mismos apoyos) → HTML → 4 decimales.
- Oráculo 2: series de Navier / Lévy en Python (programa aparte) + coeficientes publicados
  de Timoshenko (ν = 0.3).
- Caso 5 (losa sobre columnas): HTML de Calcpad `Flat Slab FEA.html` (cpw-deploy/rendered).

### Hecho
- ✅ Calcpad CLI corre `Rectangular Slab FEA.cpd` en 4.8 s (sirve de oráculo para las variantes).
- ✅ Existe el HTML de Calcpad de `Flat Slab FEA` (oráculo del caso 5).
- ✅ Timoshenko está en `referencias/Pdf` (escaneado, sin texto): tablas leídas de la imagen.
  Offset PDF = página del libro + 11. Tabla 8 p.120, Tabla 23 p.143, Tabla 35 p.202, Tabla 47 p.219.
- ✅ `tests/placas_bfs/navier_levy.py`: series de Navier/Lévy reproducen las tablas
  (Tabla 8: 0.004062/0.047886; Tabla 23: 0.011601; Tabla 47 b/a=2 igual a 3-4 cifras).
- ❌ Tabla 47 con b/a = 1 y 0.5: la serie de Lévy da en el BORDE LIBRE w = 0.01501 y Mx = 0.1311
  (libro 0.01509 y 0.1318, −0.5 %); el centro coincide. Con b/a = 2 todo coincide → el caso 75 usa b/a = 2.
- ✅ `tests/placas_bfs/oraculo_calcpad.py`: variantes de Rectangular Slab FEA.cpd (misma malla, apoyos
  por GDL, carga puntual, W_z sin redondear, bloque ORACULO) corridas con el Cli de Calcpad.
- ❌ `@{var}` / `@var` en texto y tablas `#|…|` NO funcionaba en `#numerico` (buscaba en el pipeline
  simbólico, vacío): salía «@{w_c}» literal. Motor: `NumInline` (MainWindow.Pipeline.cs) toma el valor
  del programa numérico (última línea visible antes del texto). ✅
- ✅ Motor: `#malla(x, y, e, s, r)` acepta un 5.º dato opcional con los GDL fijos de cada apoyo
  (fila [w θx θy ψ]); el dibujo distingue apoyo puntual (○), borde apoyado (○ con raya a lo largo del
  borde, como Calcpad) y empotrado (■), con leyenda. Sin 5.º dato dibuja como antes.
- ❌ En prosa `i_a` se volvía cursiva (markdown `_`): se escribe `i_{a}`.
- ✅ Hojas 73–76 corren sin errores (0.7–1.4 s). Con Calcpad 0 % a 4 decimales en w y M comparados.
- ✅ 74: con 8×12 los momentos del empotramiento salían −2.5 % / −4.6 % frente a Tabla 35; con 16×24
  −0.7 % / −1.3 % → la hoja usa 16×24 (1700 GDL).
- ✅ 76 (voladizo, ν = 0): flecha EXACTA (Hermite = nodalmente exacto en viga); M del empotramiento
  −0.26 % = q·a₁²/12 (curvatura lineal por elemento), explicado en la hoja.
- ✅ 77 (Flat Slab): 0 % a 4 decimales contra Calcpad con clsolve + Precision 10⁻¹²; con el ejemplo
  TAL CUAL (slsolve Tol 10⁻², $Integral Precision 10⁻⁴) difiere 0.005–0.008 % → son las tolerancias de
  Calcpad (la suma de reacciones de Calcpad da 1497.576 en vez de 1497.6; la nuestra 1497.6 exacto).
- ❌ `ceil(3.6/0.6)`: en coma flotante 4.2/0.6 = 7.000000000000001 → ceil = 8. La hoja usa round.
- ✅ 78: convergencia 2/4/8/16 dentro de UN bucle; = Calcpad a 6 decimales en las 4 mallas;
  16×16: w +0.0003 %, Mx +0.14 % frente a Navier (serie, α = 0.00406235, β = 0.0478864).
- ✅ `tests/placas_bfs/test_placas_bfs.py`: 73–78 contra Calcpad, 2936 valores, 0 distintos a 4 decimales.
- ✅ Regresión `tests/numerico/test_hoja_numerica.py`: TODO OK (849 valores de la 71).

### Aviso de Jorge: la 74 en la app de escritorio se quedó en blanco y la app desapareció
- ❌→? Reproducido con --ctl: 74 tras 73 tardó 121 s… pero la traza del motor (nueva: `HK_LISP_TRACE`)
  mostró el cálculo en 1.07 s. Los 120 s eran MI prueba: pedía un `capture` del WebView mientras
  navegaba y esperaba su tiempo límite (120 s). No es el motor. Sin captura: 1.5–2 s por hoja.
- ✅ Motor/app: aviso «calculando…» sobre el panel si el cálculo pasa de 0.35 s (antes: nada).
- ✅ App: los errores sin atrapar ya no cierran la ventana en silencio: se anotan en
  `%LOCALAPPDATA%\HekatanLisp\errores.log` y se muestra un aviso. (Causa de la desaparición: sin
  confirmar; si vuelve a pasar, queda en ese log.)
- ✅ `HK_LISP_TRACE=archivo`: traza de cada llamada al SBCL (tiempo, servidor o proceso).

### Encargo: #surf / #map / #fplot no resolvían los nombres de la hoja
- ❌ `#surf(-w_0*sin(pi*x/a)*sin(pi*y/b), …)` salía PLANO: Eval ponía 0 en w_0, a, b y además tomaba
  «w_0» y «a» como ejes. Y los valores de la hoja traían pegada la descripción («a = 6␅largo» → átomo
  «6largo»), así que ni con búsqueda por nombre valían.
- ✅ Motor: `ResolverNombres` sustituye cada nombre con valor numérico (definiciones encadenadas, hasta
  12 niveles) antes de dibujar; ejes = x, y (o los que queden libres); rangos con nombres `[0 a]`,
  `[0 a/3]` en #surf, #map y #fplot; si queda un nombre sin valor → aviso en rojo, no un dibujo plano.
  Se corta la descripción (DescSep) al leer los valores. demo_dibujo: cúpula de 6.844 mm (PNG visto).
