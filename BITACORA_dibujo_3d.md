# Bitácora — ventana de dibujo en 3D (como AutoCAD 3D), rama `dibujo-3d`

Pedido (Jorge, 24-sep-2026): «que también dibuje como AutoCAD 3D».
Base: `LispCad.js`; los 38 checks 2D de `test_ordenes_cad.py --local` pasaban ANTES de tocar nada.

## ✅ Funcionó
- Planta = el camino 2D de siempre (sin cámara: `S.c3 = null`): 38/38 checks 2D local y web, iguales.
- Vistas Planta/Frente/Lateral/Iso SO/Iso SE (botones + `VISTA` + `PLANTA`), proyección paralela; Frente y Lateral
  ponen su SCP (UCSORTHO = 1). Órbita: Mayús + botón central y `3DO`.
- Coordenadas `x,y,z`, `@dx,dy,dz` en el SCP; 2 números → z del plano del SCP; distancia directa en 3D (10 → punto a
  1e-9 sobre la recta base→cursor); caja dinámica con la longitud 3D y `x,y,z` junto al cursor.
- SCP: U, XY, XZ, YZ, origen, 3 puntos, anterior. Cursor = rayo ∩ plano del SCP (comprobado z = 0 y z = 3).
- Entidades: LINE con z, 3DPOL (POLYLINE 70 = 8|1, VERTEX 70 = 32), 3DCARA (3 lados, encadenadas, `I` invisible).
- OSNAP 3D: final, medio, intersección real (11,6,1) e intersección ficticia (APPINT) con imán y marcador ACI 31.
- Mira estrella de Struct en 3D; icono del SCP abajo a la izquierda; barra «Iso SO · Plano XY · SCP Universal».
- Guardar: entmake con z; 3DPOL en una línea (POLYLINE + VERTEX + SEQEND). Web: el `#autolisp` lee ΣL 3D y ΣA de
  caras igual que Python; reabrir = mismas 17 entidades (1e-9). Escritorio (`--ctl`): 3DPOL nueva → editor → recalcula.
- DXF R12: faltaban POLYLINE 3D y 3DFACE en `EscribirDxf` → añadidos (ezdxf: POLYLINE 9 con VERTEX 32 y 3DFACE, z = 3).
  DWG (acadrust) leído de vuelta: LINE, POLYLINE d3 y la 3DFACE (el lector la da como 4 aristas d3), TEXT con z.
- Ejemplo 83 (pórtico con losa): motor SBCL y escritorio dan L_col 12, P_vig 18, A_los 20, riostra 5.830952.
- Tests: `test_dibujo_3d.py` 43 ✓ web (40 local), `test_ventana_escritorio_3d.py` 10 ✓.

## ❌ No funcionó (y por qué)
- `(= "VERTEX" s)` en el motor: el `=` de AutoLISP con cadenas no está (es el `=` de CL). Arreglarlo pide recompilar
  hlisp.wasm (ECL): el ejemplo usa `equal`, que vale en los dos.
- Juez AutoCAD (accoreconsole 2027): hoy se queda colgado tras SECURELOAD incluso con el .scr viejo del juez (6 min
  sin DXF). No se pudo confirmar con AutoCAD el orden de la 3DCARA encadenada (se usó: la nueva empieza en el 3.º y
  4.º de la anterior, como dice la ayuda de AutoCAD) ni los entmake 3D.

## ⏳ Falta
- Juez AutoCAD de los entmake 3D y de 3DFACE encadenada cuando accoreconsole vuelva a arrancar.
- Órdenes planas (REC, C, A, cotas, texto, recortar…) en un SCP girado: siguen en el XY universal (AutoCAD usaría el
  SCO/extrusión 210).
- `=` con cadenas en el motor (engine.lisp + recompilar el wasm).
