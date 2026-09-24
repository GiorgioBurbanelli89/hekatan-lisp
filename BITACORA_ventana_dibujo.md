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
- Sin regresión: test_autolisp 65/65, test_hoja_numerica OK, test_placas_bfs OK.

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

### ⏳ Falta
- Recortar, copiar, desfase, simetría, empalme, estirar; cota angular/radial; OSNAP cuadrante y
  tangente; rastreo polar; pinzamientos (grips); SCP; bloques.
- Editar texto y cotas en su sitio (hoy: borrar y volver a dibujar).
- En escritorio la prueba usa eventos del DOM, no el ratón del sistema (el ratón real se probó en web).
- Publicar la web: lo decide Jorge (compilada y probada en local, sin publicar).
