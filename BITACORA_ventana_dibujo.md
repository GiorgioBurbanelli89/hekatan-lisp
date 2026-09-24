# Bitácora — ventana de dibujo `#dibujar` (Hekatan LISP, escritorio y web)

Pedido (Jorge, 24-sep-2026): «cuando coloquemos dibujar, que nos dé una ventana para hacer el
dibujo; luego, cuando guardemos la gráfica, podamos seguir con operaciones simbólicas después».

Diseño (reutiliza lo hecho en `BITACORA_autolisp_dibujo.md`):
- `#dibujar(nombre, …) … #fin` es un bloque `#autolisp` de DATOS: cada línea es un `(entmake '(…))`.
  Corre en la misma llamada al motor que los `#autolisp`, así que el bloque siguiente lee lo dibujado
  con `ssget`/`entget` (un `#autolisp` justo después de un `#dibujar` no abre dibujo nuevo) y exporta.
- La ventana CAD es `LispCad.js` dentro de la página del resultado (WebView2 en escritorio, iframe en la
  web): un solo código. Guardar → mensaje a la app (`chrome.webview.postMessage` / `parent.postMessage`)
  → `LispAutoLisp.EscribirDibujo` (C# compartido) reescribe el bloque en el EDITOR → se recalcula.

## Registro

### ✅ Funcionó
- `LispCad.js` (~700 líneas): línea, polilínea (C/D), rectángulo, círculo (radio/diámetro), arco (3P y
  centro), punto, texto, cota H/V/alineada, mover, borrar (clic, ventana, captura, TODO, Último),
  deshacer/rehacer por orden completa (como U de AutoCAD), capas y color, rejilla + forzcursor, ORTO,
  OSNAP (final, medio, centro, intersección, perpendicular, punto; apertura 10 px; manda sobre orto y
  rejilla), zoom en el cursor, encuadre con la rueda, coordenadas bajo el cursor, línea de órdenes con
  x,y · @dx,dy · @d<ang · distancia directa; Intro/Espacio/clic derecho, Intro vacío repite, Esc cancela.
- Guardar escribe las listas con los `100` que pide AutoCAD (LWPOLYLINE, DIMENSION, LAYER).
  **Juez AutoCAD 2027** (`juez_autocad.py`, ahora también juzga `#dibujar`): ej. 81 5/5 y la hoja de la
  prueba web (LWPOLYLINE, LINE, CIRCLE, ARC, DIMENSION, TEXT) 6/6, Δ = 0.
- Web con Playwright (`tests/dibujar/test_ventana_web.py`, ratón y teclado reales): 24 ✓. REC por
  órdenes, LINEA con clic a 4 px del vértice → OSNAP exacto (0.3, 0.5), círculo con clic + radio
  tecleado, arco, cota, texto con espacios, `@0.2<90`, mover/U/borrar, guardar → A = 0.15 e
  I = b·h³/12 = 0.003125 leídos del dibujo; reabrir = mismas entidades (1e-9); ej. 81 abrir+guardar
  = hoja idéntica; sin errores JS. PNG de cada paso mirados.
- Escritorio `--ctl` (`test_ventana_escritorio.py`): el puente WebView2 → C# → AvalonEdit: 10 ✓;
  el editor se oculta mientras la ventana está abierta y vuelve al guardar (layout 549/6/549).
- Ejemplo 81: T dibujada → Green (A, centroide, Ix, Iy) rotulado sobre el dibujo; b, h, b_w, t_f leídos
  de los vértices; la fórmula de la T (Steiner) da e_I = 0. Escritorio y web iguales.
- `5_copiar_a_wwwroot.sh` copia solo los ejemplos que están en git (la 68 de torsión no sale).
- Sin regresión: test_autolisp 65/65, test_hoja_numerica OK, test_placas_bfs OK; HTML de b32966b vs ahora:
  79 y 80 (las que usan #autolisp) idénticas, y las 40 primeras hojas de ejemplos/ idénticas (la corrida
  entera, ~30 s por hoja, se cortó: el resto no pasa por el código tocado).

### ❌ No funcionó (y por qué)
- El JS de la ventana metido tal cual en el HTML: la hoja PARTE el HTML por líneas y el JS salía como
  «matemática» (y se tragaba el título siguiente). → va en UNA línea: base64 (UTF-8) + `eval` indirecto.
- `exporta` redondeaba a 6 decimales: I = 0.0065671875 m⁴ volvía como 0.006567 (e_I ≠ 0). → si
  |v| < 0.1, 10 cifras significativas (engine.lisp; motor web recompilado). |v| ≥ 0.1 sigue igual.
- `#\s*dibujar` casaba con un título `# Dibujar`: la directiva va pegada (`#dibujar`).
- `\b` en un `str` de Python (no crudo) = RETROCESO: se coló dos veces en regex editadas por guion.
- AutoLISP no distingue mayúsculas: `(defun f (P / a A …))` repite el símbolo → nombres distintos.
- `@dx` en un párrafo `#:` se toma como `@variable` → se escribe `**@**dx`.
- Pruebas con eventos sintéticos: si el foco está en el cuadro de órdenes, la tecla sintética no
  escribe (no hay acción por defecto) → el test enfoca el lienzo antes de cada tecla.

## 24-sep (tarde): órdenes de edición con la semántica de AutoCAD

### ✅ Funcionó
- Órdenes nuevas en `LispCad.js` (alias de AutoCAD en inglés y español):
  DESFASE (O/EQ: distancia o punto a atravesar; en bucle objeto → lado; polilínea con inglete),
  RECORTAR (TR) y ALARGAR (EX) (aristas o Intro = todas, en bucle, desHacer), COPIAR (CO/CP, varias copias),
  GIRAR (RO) y ESCALA (SC) con [Copia/Referencia], SIMETRÍA (MI, MIRRTEXT = 0, ¿borrar origen? <No>),
  EMPALME (F, [Radio/Múltiple]; dos líneas o dos tramos seguidos de una polilínea → abultamiento),
  CHAFLÁN (CHA, [Distancia]), cotas ANGULAR (DAN: dos líneas, arco o <vértice>; sector según dónde cae el arco),
  RADIO (DRA) y DIÁMETRO (DDI), EDITAR (ED y doble clic: cuadro EN SU SITIO sobre el texto; en la cota <> = medida),
  enganches CUADRANTE y TANGENTE, rastreo POLAR (F10, POLAR fija el incremento; OSNAP > polar; polar y orto se excluyen).
- Todo trabaja sobre «piezas con parámetro u» (tramo recto o arco, con el sentido del abultamiento): cortar y
  rehacer una polilínea conserva sus arcos.
- Prueba `tests/dibujar/test_ordenes_cad.py` (web local, ratón + línea de órdenes, 40 ✓, PNG mirados):
  desfase 0.1 del rectángulo 0.3×0.5 → área 0.35 fuera y 0.03 dentro; empalme r = 0.1 → centro (3.1, 0.1) y
  líneas terminando en los puntos de tangencia; rectángulo 1×1 con esquina r = 0.2 → 1 − r²(1 − π/4) = 0.991415926536
  (a 1e-12, y el motor lo lee igual: A_o = 0.991416); chaflán 0.2/0.3; copia ×2; giro 90°; escala ×2; simetría de
  línea y de arco; cota de 60° entre dos líneas; tangente: distancia del centro = r a 1e-12; polar 45° + «1» →
  (√½, 14 + √½). Guardar → 37 entmake, n_e = 37; reabrir = mismas 37 entidades (1e-9).
- Cotas de radio (70 = 36), diámetro (35) y angular de 3 puntos (37): el motor (engine.lisp, `hk-al-norm` y
  `hk-al-medida-cota`) las acepta y mide (42: la angular en radianes, como AutoCAD); la hoja las dibuja
  (LispAutoLisp.cs `CotaCurva`: SVG/PNG/PDF/DXF/DWG) con R…, Ø… y grados (DIMADEC). Motor web recompilado (3 y 4).
- **Juez AutoCAD 2027**: la hoja de la prueba 37/37 entidades, Δ = 3.9e-15; ejemplos 3/3.
- Sin regresión: test_autolisp 65/65, test_hoja_numerica OK, test_placas_bfs OK, test_ventana_web y escritorio OK.

### ❌ No funcionó (y por qué)
- Radio y diámetro guardados se perdían al recalcular (n_e bajaba): `hk-al-norm` exigía 13 y 14 a toda
  DIMENSION → se rechazaban. Arreglado por tipo de cota.
- El juez comparaba el punto 10 de la angular: AutoCAD lo corre por el arco (donde pone el texto), conservando
  radio y sector. Ahora compara vértice, lados, radio y ángulo medido.
- `5_copiar_a_wwwroot.sh` trae un `acadrust_wasm` más nuevo de otro repo: no se sube en este commit (restaurado).

### ⏳ Falta
- Estirar (STRETCH), pinzamientos (grips), SCP, bloques; empalme entre polilínea y línea, y entre arcos;
  recortar/alargar arcos de polilínea en el extremo (hoy solo el tramo recto); tangente diferida (sin punto base).
- Cota angular de 2 líneas (70 = 2) leída de fuera: se guarda tal cual (RAW), no se edita.
- Texto de cota: la ventana escribe 0.5 y la hoja 0.50 (DIMDEC = 2): unificar.
- La barra de herramientas ya ocupa dos filas: agrupar (menús) si crece más.
- En escritorio la prueba usa eventos del DOM, no el ratón del sistema (el ratón real se probó en web).
- Publicar la web: lo decide Jorge (compilada y probada en local, sin publicar).
