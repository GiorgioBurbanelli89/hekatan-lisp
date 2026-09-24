# Bitácora — dibujo AutoLISP en Hekatan LISP (rama `autolisp-dibujo`)

Pedido (Jorge, 24-sep-2026): dibujar al estilo AutoLISP (entmake/ssget/entget con listas DXF)
y mezclarlo con el cálculo simbólico. Capa simple en español encima. Guardar DXF.

Principio: **el código es la lista de datos**. Una entidad ES una lista de asociación DXF
normal de LISP: se arma con list/cons/mapcar, se transforma con funciones, y `entmake`
la pone en el dibujo. Leer lo dibujado (`ssget`/`entget`/`assoc`) devuelve listas con las
que se sigue calculando.

## Base
- Worktree creado de `main` (a803916) pero `main` NO tiene la hoja 70 (#dibujo con cargas)
  ni `HojaNumerica.cs`: están en `placa-base-voladizo` (8c4b0b1). Rama re-basada allí.

## Fuentes de la semántica (no de memoria)
- entmake (AutoLISP Reference 2024, Autodesk): devuelve la lista si crea la entidad, `nil`
  si falta un dato obligatorio; lo opcional (capa…) toma el valor por defecto; **ignora el
  código 100** por compatibilidad.
  https://help.autodesk.com/cloudhelp/2024/ENU/AutoCAD-AutoLISP-Reference/files/GUID-D47983BA-1E5D-417D-85B8-6F3DE5F506BA.htm
- Ángulos: en las listas de AutoLISP (entget/entmake) los códigos 50/51 van en **radianes**
  (p. ej. `(50 . 5.96143)`); en el fichero .DXF van en grados. Aquí igual: lista = radianes,
  el escritor DXF los pasa a grados.
- Códigos DXF (DXF Reference de AutoCAD): 0 tipo, 5 handle, 8 capa, 6 tipo de línea,
  62 color ACI (256 = PORCAPA), 370 grosor (centésimas de mm), 10/11 puntos, 40 radio o
  altura, 1 texto, 50/51 ángulos, 72/73 alineación de TEXT, 71 anclaje de MTEXT,
  90 nº vértices y 70 cerrada de LWPOLYLINE, 42 abultamiento, 13/14 orígenes de las
  líneas de referencia de DIMENSION, 42 medida, 70 tipo (0 girada, 1 alineada, +32).

## Registro

### ✅ Funcionó
- Capa AutoLISP en `engine.lisp` (sección AUTOLISP; engine.lisp es lo único que se hornea en SBCL y
  se compila en hlisp.wasm). Entidades = listas DXF; base de dibujo con enames `<Entity name: 1f0>`.
- `hk-al-ejecuta`: el bloque se evalúa forma a forma (un error se escribe y el resto sigue, igual en SBCL y ECL).
  Traduce 4 cosas de AutoLISP a CL: `"\n"` en cadenas, `(princ)` sin args, `(defun f (a / loc) …)`,
  `'(lambda …)` → `#'(lambda …)` (cierra sobre las variables, como el alcance dinámico de AutoLISP).
- POLYLINE COMPLEJA real (cabecera + VERTEX + SEQEND como subentidades: entnext entra, ssget no las ve).
- Hoja: `#autolisp(…) … #fin` se pliega ANTES de todo (un `(setq` volvía programa la hoja entera);
  todos los bloques en UNA llamada al motor (variables compartidas). Contexto hoja→LISP con `hk-al-ctx`
  (no toca símbolos de CL: `tan`, `error`… daban «Lock on package»). `exporta` → líneas `n = valor`.
- Render SVG (LispAutoLisp.cs): encuadre por extensión, ACI afinado al tema claro/oscuro, capas,
  tipos de línea, grosores, HATCH (lleno o rayado recortado par-impar), cotas con flechas en papel,
  TEXT con estilo HKMATH = matemática en cursiva/exponentes como la hoja (`formula`).
- 3D: proyección az/el + pintor; la página re-proyecta al arrastrar (JS con el mismo algoritmo que C#).
  PNG de planta, frente, lateral, 3D y girada revisados en escritorio y web.
- Guardar: DXF R12 (ezdxf audit 0 errores), SVG, PDF vectorial propio (Helvetica/Times, sin librería),
  PNG (canvas de la página), DWG (acadrust-wasm: escritorio con Node + pkg-node; web con pkg-web).
  `tests/autolisp/verificar_formatos.py`: DWG abierto por AutoCAD 2027 con AUDIT «0 errors»; PDF y SVG mirados.
- JUEZ AutoCAD (`tests/autolisp/juez_autocad.py`): el bloque AutoLISP puro → .lsp → accoreconsole
  (SECURELOAD 0, DXFOUT 16 decimales, rutas sin espacios en C:/Temp/hkal) → ezdxf, contra el volcado de
  Hekatan, en orden: ej. 73 bloque 2: 6/6 entidades, Δmáx 1.6e-10 · ej. 74: 34/34 (13 3DFACE, POLYLINE 3D,
  10 TEXT, 6 LINE, 4 POINT), Δmáx 4.9e-10. **2/2 bloques iguales a AutoCAD.**
- Pruebas `tests/autolisp/test_autolisp.lisp`: 65/65 en SBCL y 65/65 en el motor web (ECL→wasm, Node).
- Regresión: las 180 hojas de ejemplos/ con el exe de antes (8c4b0b1) y el nuevo → mismo HTML
  (179 idénticas; `_gauss3` solo cambia un contador de id g1→g2). tests/numerico: 36/36 y 19/19.
- Web: ECL AOT con 0 avisos (las 4 trampas de la memoria no aparecieron); ejemplos 73 y 74 en
  localhost:8766 se ven igual que en escritorio; los 5 botones descargan (DWG web: AUDIT 0 en AutoCAD).

### ❌ No funcionó (y por qué)
- `(* x x x)` y `(+ a b c)` en el motor simbólico pierden términos (el parser es BINARIO): las fórmulas
  del ejemplo van en la hoja (MathToLisp las da binarias) o con `expt`.
- JsonSerializer en la web: «JsonSerializerIsReflectionDisabled» (WASM recortado) → JSON a mano.
- Módulo .js en wwwroot/dwg: `dotnet publish` le pone huella al nombre → 404; se copia como `.mjs`.
- accoreconsole lanzado desde Git Bash se cuelga (MSYS reescribe `/s`): se lanza desde Python.
- Worktree base en el scratchpad: «Filename too long» → C:/Temp/hkal/base.

### ⏳ Falta
- DWG con 3DFACE / POLYLINE 3D / relleno lleno: el escritor de acadrust aún no los tiene (se avisa; el DXF sí).
- `(guardar "x.png")` en `--html` sin ventana: el PNG lo hace la página (en la ventana sí).
- AutoLISP no cubierto: `command`, `vla-*`, `getpoint`/`ssget` interactivo (devuelve nil), XDATA (-3),
  bloques (INSERT/BLOCK), `defun c:…` (el lector de CL toma `c:` como paquete).
- Cotas en 3D: se dibujan alineadas en el espacio (en AutoCAD viven en el plano del SCP).
- Publicar la web y fusionar a main: lo decide Jorge.
