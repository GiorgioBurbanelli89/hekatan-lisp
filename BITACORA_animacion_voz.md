# Bitácora — animación + voz (rama animacion-voz, 24-sep-2026)

## Sintaxis final
- `#anim fplot(…), n = 1:8` · `#anim surf(expr, [xa xb], [ya yb]), k = a:b[:paso]` · `#anim map(…), k = …`
- `#anim surf(N_{k}, …), k = 1:16` → `{k}` arma nombres; `#anim surf(M, …)` sin parámetro → un cuadro por componente.
- Bloque: `#anim(n = 2:2:16)` … `#finanim` (o forma corta: `#anim(j = 1:5)` + `#dibujo`/`#autolisp` … `#fin`).
- `#voz: texto` — pegada a una animación: una por cuadro (una sola = todas); dentro de un bloque: la de cada cuadro; suelta: párrafo con 🔊. `{k}` y `@{var}` valen.

## ✅ Funcionó
- `LispAnim.cs` (nuevo, compartido escritorio/web): reproductor ▶/⏸ + barra + rótulo + subtítulo + 🔊, JS en UNA línea.
- Voz: `speechSynthesis`, voz es-ES (WebView2 y Chromium de Playwright la tienen: Windows SAPI). Probado: 🔊 → `speaking = true`, avanza al terminar la frase, segundo clic calla.
- Superficie animada = UN lienzo con `data-frames` (el giro del ratón se conserva); escala z común con parámetro, propia por componente o con `{k}`.
- Bloques: se repiten en TEXTO antes del pipeline (cada copia la calcula el motor), marcadores `#hkanfr/#hkanfin` → `PostProcesar` los agrupa. Sirve para `#dibujo`, `#autolisp`, `#malla`, `#map`, fórmulas y bucles de `#numerico`.
- Impresión/PDF: CSS `@media print` + `beforeprint` → cuadro 1. `--shot` sale en el cuadro 1 (la autoreproducción empieza a 1.6 s).
- Ejemplo 82: Hermite deducidas por el motor (C⁻¹ por columnas), 16 funciones = productos, animadas con 16 voces; refinamiento h 2…16 animado (malla + mapa + error por cuadro); Navier sumado por el motor (200×200 términos).
- Oráculos: Calcpad para 6, 10, 12, 14 generados (`oraculo_calcpad.py`); `test_placas_bfs.py` ahora incluye el 82: 18 valores iguales a 4 decimales (w y Mx de 8 mallas + α, β de navier_levy.py). 73–78 siguen OK. `tests/numerico` OK (849 valores de Calcpad).
- Tests: `tests/animacion/test_anim_escritorio.py` (--ctl) TODO OK · `tests/animacion/test_anim_web.py` (Playwright) TODO OK.

## ❌ No funcionó (y por qué) → arreglado
- `Expand{[1 ξ ξ² ξ³]·C⁻¹}` no se calculaba: el convertidor CITA el argumento `(expand* '(…))` y `meval` devolvía la cita. Arreglado en engine.lisp (desenvuelve la cita). El wasm de la web se recompiló (WSL, `~/lispwasm/hl_anim`).
- `<script>` con saltos de línea en una línea de texto (#voz suelta): el pipeline parte la hoja por líneas y pintó el JS como fórmulas → JS en una línea.
- Reproductor inicializado antes de que existieran las `#voz` de debajo → `hkTarde` (DOMContentLoaded).
- `#finanim` de un bloque cazaba el de otro bloque más abajo → se busca solo hasta el siguiente `#anim(`.
- El mismo `#map(…)` en 8 cuadros daba 8 veces la última rejilla (diccionario por texto) → clave texto + nº de aparición (también `#malla`).
- `--shot` capturaba «calculando…» en hojas largas → espera el cálculo (y el recálculo del debounce).
- En hoja numérica las operaciones simbólicas se mostraban con cada nombre sustituido (C⁻¹ entera en cada línea) → se muestran con los nombres (N₁ = H₁·G₁).
- Parámetro que choca con argumentos con nombre (`n` en `carga(…, n = 13)`, `m` en `ud = m`): se sustituye igual → documentado: usar otra letra.

## Números del refinamiento h (losa 4×4 m apoyada, q = 10 kN/m², t = 0.12, E = 35000, ν = 0.3)
Navier (motor, 200×200): w = 1.877709674 mm (α = 0.004062352661), Mx = 7.661820532 kN·m/m (β = 0.04788638).

| n | h [m] | GDL | w centro [mm] | error w [%] | p (w) | Mx [kN·m/m] | error Mx [%] | p (Mx) |
|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| 2 | 2 | 36 | 1.905605 | 1.485585 | – | 9.152385 | 19.4544 | – |
| 4 | 1 | 100 | 1.879084 | 0.073183 | 4.343 | 7.874727 | 2.7788 | 2.808 |
| 6 | 0.667 | 196 | 1.877967 | 0.013708 | 4.131 | 7.744300 | 1.0765 | 2.339 |
| 8 | 0.5 | 324 | 1.877790 | 0.004253 | 4.068 | 7.705873 | 0.5750 | 2.180 |
| 10 | 0.4 | 484 | 1.877742 | 0.001726 | 4.041 | 7.689327 | 0.3590 | 2.111 |
| 12 | 0.333 | 676 | 1.877725 | 0.000828 | 4.028 | 7.680664 | 0.2459 | 2.075 |
| 14 | 0.286 | 900 | 1.877718 | 0.000446 | 4.020 | 7.675551 | 0.1792 | 2.054 |
| 16 | 0.25 | 1156 | 1.877715 | 0.000261 | 4.015 | 7.672276 | 0.1365 | 2.040 |

Calcpad, misma malla: diferencia máxima 0 a 6 decimales (w) y 0 a 4 decimales (w y Mx). Web (ECL): p = 4.014988 vs 4.014984 escritorio (SBCL), diferencia de redondeo.

## ⏳ Falta
- No publicado a gh-pages (a propósito). El `hlisp.wasm` de wwwroot va recompilado con el arreglo del motor: al publicar, usar el de esta rama.
- Instalador no regenerado.
- Voz: sin voces en español (Linux sin speech-dispatcher, algunos Android) el 🔊 se oculta; no probado en Firefox/Safari.
