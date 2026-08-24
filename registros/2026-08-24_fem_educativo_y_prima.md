# Hekatan LISP — serie FEM educativa, gráficas nativas y notación prima (24-ago-2026)

Meta: enseñar de dónde sale la K del FEM (funciones de forma → curvatura → integral → K → ensamblaje), con gráficas INTERCALADAS y notación de prima segura al convertir.

## Gráficas nativas (intercaladas, no al final)
- ✅ `#surf` — superficie 3D GIRABLE (canvas JS orbit). SkiaSharp = 2D estático de respaldo.
- ✅ `#map` — mapa de color 2D (SkiaSharp, ejes + colorbar, jet_r).
- ✅ `#beam` / `#frame` / `#framedef` — esquemas de viga/pórtico sin/ con deformada (SkiaSharp, columnas curvadas con Hermite).
- ✅ Intercaladas en su POSICIÓN vía marcador `PlotSlot` (BuildPlotsOrdered), no volcadas al final.

## Serie educativa (ejemplos 12–24)
- ✅ 1D→2D funciones de forma, reseña histórica (Lagrange→Ritz→Courant→Turner/Clough 1956→Hermite→Melosh→Irons).
- ✅ "El problema" (puntos, no curva), curvatura para lego, qué aproxima la interpolación (solución exacta).
- ✅ Antes del FEM (equilibrio + doble integración, orden opuesto al FEM).
- ✅ Prácticos: voladizo (21) y pórtico plano (22) CLÁSICO vs FEM.
- ✅ "De dónde sale la K" (23) y ensamblaje del pórtico (24): base·C⁻¹ = Hermite → derivadas → integrales → K_barra → ensamblaje → K_portico → u → deformada.

## Render (afinado a Hekatan Lab)
- ✅ Integral ∫ apilada EXACTA como Hekatan Lab (dvr[small(sup) nary(em ∫) small(sub)], em con scaleX(0.7) rotate(7deg)); ya no se corta.
- ✅ `+C` en integrales indefinidas · `d/dx` (Diff) vs `∂` (Partial) · `@@(etiqueta)` a la derecha.
- ✅ Leyenda no se sale del recuadro + etiquetas bonitas (·, superíndices, −).
- ✅ Matriz simbólica = numérica en UNA línea con etiqueta.

## REGLA fija (Jorge)
- ✅ Las fórmulas son OPERACIONES simbólicas (líneas math que el motor renderiza), NUNCA texto/comentario. `#:` = solo prosa.

## Notación prima (H1', H1'') — segura al convertir
- ✅ Render: `Tok` acepta `'` final; `VarHtml` lo pinta como `<sup>′</sup>` → H₁', H₁''.
- ✅ `SafeName` usa el TOKEN PROPIO de Hekatan Lab (su HtmlWriter dibuja los sufijos): `'`→`prime`, `''`→`pprime`, `'''`→`tprime`. Aplicado en ToLisp, ToLab y los LHS del builder MATLAB (#deq y línea normal).
- ✅ Verificado por `--ctl` (settext + syntax/synfull/synheklab + gettext), las 3 formas:
  - expr LISP: `(setf H1prime …)` `(setf H1pprime …)`
  - LISP completo: no usa el nombre (no filtra `'`)
  - Hekatan Lab (MATLAB): `H1prime = …` `H1pprime = …`  → al pegarlo en Hekatan Lab se ve H1′ / H1″
- Porqué: en LISP/MATLAB el `'` no es válido (en MATLAB es transpuesta). No inventé `p`: Hekatan Lab YA tenía su token (`prime/pprime/tprime`); uso el mismo para que sea coherente y redibuje la prima.

## Falta / opcional
- ⏳ nada bloqueante; commit + instalador + push de esta tanda.
