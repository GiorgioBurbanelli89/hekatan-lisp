# Lisp → WASM con ECL + Emscripten (2026-09-18)

Meta: motor Lisp compilado ANTES a WASM (A) + lo que escribe el usuario (forma matemática → Lisp) corre como bytecode en el navegador (B).
Entorno: WSL Ubuntu (~/lispwasm), emsdk latest, ECL git.

## ✅ Funcionó
- WSL Ubuntu tiene gcc/make/autoconf; ECL git b875e3a trae `wasm32-unknown-emscripten.cross_config` (INSTALL: probado con emsdk 4.0.12, -O0, `--spill-pointers` para el GC, STACK_SIZE 1 MB).
- engine.lisp: solo 2 llamadas SBCL (`sb-ext:float-nan-p/infinity-p`) → `#+sbcl/#-sbcl` con `ext:` de ECL. Escritorio igual.
- web/hlisp_web.lisp: `hlisp-web-run` (texto→texto) = hlisp-server sin stdin/stdout.
- web/hlisp_main.c: cl_boot + init_hlisp + `hlisp_run` exportado a JS.
- ECL 26.5.5 host + wasm32 compilados en WSL (emsdk 4.0.12). `ecl.wasm` 5.6 MB corre en node.
- AOT (A): host ECL `compile-file :system-p t :target target-info.lsp` → engine.o (wasm) + `c::build-static-library :init-name "init_hlisp"` → libhlisp.a; emcc + hlisp_main.c → **hlisp.wasm 6 MB**. Arranque 0.43 s, 1 derivada 0.7 ms, UTF-8 ok.
- Oráculo SBCL: 8/8 ejemplos Lisp puro IGUALES byte a byte (web/cmp_sbcl.lisp vs cmp_wasm.cjs).
- `hk-rationalize` = algoritmo de SBCL 2.6.7 (target-float.lisp) portado; 220 011 floats → 0 distintos vs `rationalize` de SBCL.
- Página web/dist/index.html con paleta Struct (#0e1116, #22d3ee, #1e3a4a); worker; PNG escritorio+móvil OK, consola limpia.

### Parte 2 — la web con el CSS/UI de Hekatan LISP (mismo C# del escritorio)
- Refactor: `MainWindow.Pipeline.cs` (ComputeResult + ayudantes + ConvertEditor/ConvertEqLine/BuildFullLisp/BuildRealMatlab) sacado de MainWindow.xaml.cs, sin WPF. Escritorio: 0 errores y `--html` IGUAL byte a byte en 4 hojas vs build previo.
- `LispEngine.cs`: `#if HEKATAN_WEB` → Run() llama a hlisp.wasm (JSImport). Escritorio igual.
- `web/HekatanLispWeb` (.NET 10 wasmbrowser): enlaza los .cs del escritorio (no copia). UI calcada de MainWindow.xaml (menú, modos, escribo/operar, calculadora, tema claro/oscuro, colores Lisp.xshd).
- Web vs escritorio (`--html`): 01 y 04 IGUALES (solo CRLF).
- Oráculo SBCL de TODOS los scripts que genera la web (48 hojas → 56 scripts): 51/51 iguales (los 5 restantes son tic/toc, miden velocidad). 5 vueltas seguidas en un proceso: 51/51 cada vuelta.
- Gráficas: SkiaSharp 3.119.4 (trae libSkiaSharp.a para Emscripten 3.1.56 = .NET 10; la 2.88.8 del escritorio llega a 3.1.34 → no enlazaba). Fuente web `hekatan-plot.ttf` = Open Sans 400 + → ₓ de DejaVu (fontTools); `HkFont.Ui` (escritorio null = Segoe UI igual que antes). Escritorio: 6 hojas con gráficas `--html` IGUALES byte a byte tras el cambio.
- **48 hojas web vs escritorio: 45 iguales** (HTML igual salvo espacios + PNG <1 % píxeles). Las 3 restantes: 2 = cronómetro ⏱ (web ~150 µs/op vs SBCL ~1 µs), 1 = trazo de fuente en una gráfica (1.96 %, visualmente igual).
- UI: capturas claro/oscuro/diff en vivo/LISP ▶/3 formas/móvil, consola limpia.

## ❌ No funcionó (y por qué)
- make host: PATH de Windows heredado en WSL ("Program Files/GNU Octave") rompe GMP doc → exportar PATH Linux limpio.
- `c:build-static-library` → error de lector: hay que `(require 'cmp)` antes.
- ECL `rationalize` = fracción EXACTA (0.09 → 8444…/1125…); SBCL da la MÁS SIMPLE (9/100) → evops daba fracción en vez de 75000. Arreglado con hk-rationalize.
- `python -m http.server` en Windows manda .js como text/plain → worker no carga. → web/serve.py con MIME forzado.
- render_html.py usa file:// → Worker no corre ahí; se verificó por http con Playwright.

- `ext:octets-to-string` de ECL-wasm FALLA con >4096 bytes ("Memory limit reached") → mi puente C fallaba con hojas largas (parecía GC/SJLJ; bisección: umbral exacto 4096). → UTF-8 decodificado/codificado a mano en hlisp_main.c.
- bdwgc en wasm nunca recolectaba: prefería crecer el heap y Emscripten ABORTA al no poder crecer. → `ECL_OPT_HEAP_SIZE` 160 MB (< INITIAL_MEMORY 256 MB).
- Con el GC ya corriendo: resultados CORRUPTOS ((a11 a22) en vez de 0). Causa: en Emscripten bdwgc NO escanea datos estáticos (gcconfig.h DATASTART=DATAEND) y las constantes compiladas VV[] de ECL viven ahí. → `GC_add_roots(__global_base, __data_end)` tras cl_boot.
- `intersection`: orden libre por estándar; engine toma el 1º como variable principal → signo distinto. → `hk-intersection` = algoritmo SBCL 2.6.7 (list.lisp), 50 000 casos 0 distintos.
- `sort` NO era (ECL y SBCL: merge sort estable en listas; verificado en fuentes).
- Heredocs bash con `\` se rompen: escribir .cjs/.py con Write.

- Selawik (reemplazo libre de Segoe UI) NO trae griego → ξ desaparecía en la hoja 28. → Open Sans (+ → ₓ de DejaVu).
- Mi cmp_web.py duplicaba los saltos de línea (write_text en Windows convierte LF a CRLF encima del CRLF que ya trae el C#): artefacto del test, no de la web.
- Olvidé copiar el hlisp.wasm con el arreglo de raíces a wwwroot: la web corrió un rato con el anterior (sha1 9cbc… vs 85ac…). Verificar sha1 antes de dar por bueno.

### Parte 3 — salida de programas con prosa + fórmula (escritorio Y web, mismo C#)
- ❌ Hoja 00: `(format t "Hola. Deriva x^2: ~a = ~a" (infix …) (infix …))` se veía «Hola. = 2*x». Igual en el ESCRITORIO.
  Causa: RenderPage parte por " = " y lee cada tramo con ParseLisp/ParseMath, que NO fallan: TRUNCAN en silencio
  ("Hola. Deriva x^2: x^2" → «Hola.»; "2*x" queda crudo; "1 -> pendiente" → 1).
- ✅ LispConverter: `EsFormaLispLimpia` / `EsMatInfija` / `TramoMixtoHtml` (+ `.ws-prosa`, `RestaurarNombres`
  para DEFINICION→definicionhkq3). Solo entra si algún tramo NO es forma LISP limpia.
  48 hojas escritorio antes/después: cambian SOLO 00, 06, 07, 08 (las que tenían texto truncado); el resto idéntico.
  Web publicada: «Hola. Deriva x^2: x² = 2·x».

### Parte 4 — publicar sin romper (GitHub Pages)
- ❌ «Solo resultado» no cambiaba nada en el navegador de Jorge: usaba el **app.css viejo de la caché** (GitHub Pages ~10 min). main.js sí se renovó (lleva huella); el CSS no.
- ❌ El marcador de huella de .NET NO se aplica a `<link>` (lo deja en app.css) → al publicar: `app.css?v=<sha1 contenido>`.
- ❌ Publicación INCREMENTAL dejó `main#[.{fingerprint}].js` sin reemplazar → el sitio pedía «main»/«hlisp» (404) y no cargaba. → publicación LIMPIA + chequeo que aborta si queda `{fingerprint}`.
- ✅ Todo en `web/build/6_publicar_gh_pages.sh` (clon temporal de gh-pages, autocrlf=false, .nojekyll, sin .br/.gz, ?v= del CSS). Verificado en el sitio público.

## ⏳ Falta
- Velocidad: motor web ~150 µs/op vs SBCL ~1 µs (ECL -O0 por --spill-pointers + eval en bytecode). Probar -O1/-O2 y medir.
- «LISP ▶» en la web muestra rutas del escritorio (/sbcl/sbcl.exe): es el mismo C#; el script es para correrlo en SBCL de escritorio.
- Publicar en GitHub Pages (no hecho: pedir OK).
