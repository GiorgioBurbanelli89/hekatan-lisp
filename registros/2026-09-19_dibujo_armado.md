# Dibujo técnico 2D + armado + observaciones en Hekatan LISP — 2026-09-19

Objetivo: hojas de OBSERVACIONES / memoria de revisión con dibujos de armado (1er caso: radier MOD_002).

## ✅ Funcionó
- **Directiva de bloque `#dibujo(…) … #fin`** (`LispDibujo.cs`, nuevo; enlazado en la web). SVG en **mm de papel**
  (viewBox en mm), geometría a escala 1:E. Escala automática = la mayor normalizada que cabe en `ancho`/`alto`;
  fija con `escala = 1:50`. `vert = 5` exagera la vertical (elevaciones largas); se rotula en el título.
  Colores del tema (`--dib-rojo/azul/verde/nar/acero`, claro y oscuro).
- Argumentos = números, nombres de la hoja, `v(i)`, expresiones, vectores (resolver `NumLookup` en
  `MainWindow.Pipeline.cs` sobre los resultados del motor). Textos con `{nombre}` / `{nombre:2}`.
- Primitivas: linea, polilinea, poligono, rect (admite vectores), circulo, arco, texto, cota, cotas, cotasy,
  ejex/ejesx, ejey/ejesy (burbuja 1,2… / A,B…), hueco, achurado (diagonal/cruzado/concreto), varilla
  (ganchos 90/135/180, signo = lado), varillas (rótulo «n Ø d mm @ s cm»), fila (varillas en corte),
  seccion, estribo (135°), leyenda, obs (círculo numerado; pendiente=rojo, corregida=verde, info=azul;
  x,y vectores; dx,dy = línea guía) + **tabla de observaciones** automática debajo del dibujo.
- Errores visibles en rojo bajo el dibujo (primitiva desconocida, variable no definida) — no revienta.
- **Motor**: `ceil`, `floor`, `round`, `max`, `min` numéricos (antes quedaban sin evaluar), término a término
  en vectores; `escalar/vector` y `vector/escalar` en `meval`; `dec` con π; los decimales de `dec`
  (|2.011|) se pueden reutilizar en cuentas. Render ⌈x⌉ ⌊x⌋ (HTML y LaTeX).
- Un número escrito por el usuario (`q = 13.48`, `x0 = -0.15`) se muestra tal cual, no como 337/25.
- Ejemplo `ejemplos/46 Observaciones radier MOD_002 - armado.lisp`: datos reales del .f2k (ejes, 7 huecos,
  zonas 60 cm, 15 pedestales), 22 cargas repetidas del CSV, q máx 13.48 t/m² en (15.075; 9.675) y
  punzonamiento/peso propio del informe; CSA1 (b = 1.50 m) con As de SAFE → n = ⌈As/Ab⌉ = [7 3 1 9 13] Ø16
  arriba y [5 6 5 4 1] Ø14 abajo, s = ⌊b/n/2.5⌋·2.5. Todo calculado en la hoja.
- Verificado con imagen: escritorio `--html` + render_html (0 errores), **PDF** 7 págs, **web local**
  (`dotnet publish` + wasm ECL recompilado) = texto idéntico al escritorio, 0 errores de consola; tema oscuro OK.
- Regresión: 46 ejemplos viejo (HEAD) vs nuevo. Solo cambian: decimales literales (ahora 0.1 en vez de 1/10,
  ej11/30/39), tiempos tic/toc (ruido) y ej45 (tablas, del otro agente).

## ❌ No funcionó (y por qué) — arreglado
- `hk-num` con paréntesis desbalanceados → SBCL no cargaba engine.lisp (la app mostraba todo sin evaluar).
- Decimales en `evops` → `simplify` revienta con floats (ratcontent 608.425): los args de ceil/max se
  evalúan numéricos ANTES (hk-arg).
- `max` devolvía la fracción binaria del double (12.25 → 49/4, 4.54 → 5110…/2^50): ahora devuelve el
  argumento ganador tal cual.
- Nuevo `/` de meval rompió ej40 (Sherman-Morrison: vᵀu es 1×1) → se escalariza el 1×1 antes. Detectado
  por la regresión de 46 hojas.
- `--pdf` headless: salía la hoja VACÍA (esperaba 1.1 s fijos) y con ruta relativa fallaba WebView2
  (`ArgumentException`). Ahora espera `_showTask` y usa ruta absoluta (`MainWindow.xaml.cs`).
- Tabla de sintaxis ancha con barra de scroll en el PDF → en `@media print` las celdas se parten.
- Elevación de 15 m × 0.40 m a escala real = una raya → `vert = 5`.

## ⏳ Falta
- Acero mínimo y separación máxima (ACI) en la hoja: donde SAFE pide < 1 varilla la regla da n = 1, s = 150 cm.
- SAFE (diseño de Jorge) tiene recubrimiento 1.5 cm en preferencias; ACI 20.6.1.3.1 pide 7.5 cm contra el suelo:
  verificar de quién es el ajuste antes de ponerlo como observación.
- `vert` deforma círculos/arcos (solo usar en elevaciones).
- Publicar la web (`web/build/6_publicar_gh_pages.sh`): NO hecho (pedido: sin deploy).
