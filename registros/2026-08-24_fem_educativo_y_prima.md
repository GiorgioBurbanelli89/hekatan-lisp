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

## ej26 §2 — las funciones de forma DEDUCIDAS (no copiadas)  [25-ago]
Jorge: "de dónde viene ese polinomio, ¿te lo inventas?". Antes §2 solo declaraba las Hermite. Ahora se DEDUCEN con el motor:
- ✅ Cadena: deformada cúbica (sin carga → EI·v⁗=0) → 4 coef fijados por 4 datos de nudo → matriz A (evaluaciones de v y pendiente en s=0,1) → `Ainv = A^-1` → `Nnat = base·Ainv` (formas SIN L) → `Ldiag = diag(1,L,1,L)` → `Nrow = base·Ainv·Ldiag` = Hermite CON L. Idénticas al ej24.
- ✅ El motor invierte la 4×4 numérica y multiplica base(1×4 simbólica)·matriz. Verificado en probe.png y ej26.png.
- ✅ Porqué del L: el giro es dv/dx y s=x/L, así que en los datos el giro entra como L·θ; devolver ese L a las columnas 2 y 4 = la diagonal. Ahí nace, no es adorno.
- ❌→✅ FUGA de `{}`: en prosa `#:`, `{v}` y `{N}` se EXPANDÍAN (v y N estaban definidas) → volcaban vectorones. Regla: en prosa, `{}` SOLO para símbolos NO definidos (EI, L, s, θ…); a las variables definidas se las nombra en texto plano. Renombré la matriz a `Nrow` (así `{N}` de §1 vuelve a ser símbolo) y saqué `{v}`,`{A}`,`{A^-1}`,`{K_coef}` de la prosa.

## ej26 §2 nuevo — se DEDUCE EI·v⁗=0 (equilibrio), con θ y κ griegas  [25-ago]
Jorge: "¿de dónde viene ese polinomio, te lo inventas?" (señalando EI·v⁗) y "giro/curvatura/deflexión tienen símbolos griegos, úsalos".
- ✅ Nuevo §2 "De dónde sale EI·v⁗=0": cadena de derivadas de la deflexión con nombre físico. `θ=Diff{cúbica}` (giro=v′), `κ=Diff{giro}` (curvatura=v″), `cortante=Diff{}` (∝V), `carga=Diff{}` (∝q) → **0**. Sin carga (q=0) ⇒ EI·v⁗=0; integrando 4 veces ⇒ cúbica con 4 constantes = 4 datos de nudo. Renumerado: formas §3, curvatura §4, cambio var §5, integral §6 (y "paso 3/5"→"paso 4/6").
- ✅ θ y κ salen en GRIEGO en el lado izquierdo (nombrar la variable `theta`/`kappa` la dibuja θ/κ). El Diff en su propia línea de definición MUESTRA la derivación (d/dx[...] = resultado) — bien.
- ❌→✅ Trampa: si §1 REFERENCIA `kappa` (p.ej. `M = EI*kappa`) y §2 define `kappa = Diff{...}`, §1 hereda el Diff crudo y sale `M = EI·d/dx[...]` FEO. Además la definición global concretiza κ en toda la hoja. Arreglo: pasé ε, σ, M, u de §1 a PROSA con κ literal → `kappa` queda libre, §2 lo define sin ensuciar §1 (que sigue abstracto).
- Motor: `unicode θ/κ` NO valen como nombre de variable (LHS vacío). `Diff{expr explícita}` evalúa y propaga el valor; `Diff{variable-con-Diff}` = anidado, no reduce. `{E}` en prosa se dibuja minúscula (no hay CaseMap para E sola) → usar E literal.
- ✅ Motor: `--shot` ahora SALTEA el mutex single-instance (App.xaml.cs) → captura headless sin cerrar la ventana abierta.

## ej26 reordenado — "cómo empieza TODO": el trocito de viga  [25-ago]
Jorge: "no entiendo, no explicas cómo empieza todo". El §2 daba por sentado el equilibrio ("el cortante es la pendiente del momento"). Ahora arranca desde el principio físico.
- ✅ Nueva directiva `#slice` (BeamSchematic.SlicePng): dibuja el trocito dx con q (arriba), M+V (cara izq), M+dM y V+dV (cara der), cota dx y eje x. SkiaSharp. Helpers ArrowV/ArrowH/MomentArc. Cableada en los 5 regex (MainWindow×3, LispConverter×2) + despacho `isSlice`.
- ✅ Reorden lógico de la hoja: §1 EQUILIBRIO del trocito (de ahí dV/dx=−q y dM/dx=V, deducidas de ΣF=0 y ΣM=0) → §2 geometría+material (κ=v″, Hooke→M=EI·κ, encadenar → EI·v⁗=q, en el tramo q=0) → §3 cúbica (cadena θ,κ,V,q→0) → §4 formas → §5 curvaturas → §6 cambio var → §7 energía (por qué K=∫κκ) → §8 integral→K. La energía (antes §1) se movió al final: justifica la integral, no es el comienzo.
- ✅ Refs "paso N" reajustadas; headers con EI LITERAL (no {EI}: la sustitución {} no corre en `##`). Recordatorio: `{E}` en prosa se dibuja "e" minúscula → usar E literal siempre.

## Falta / opcional
- ⏳ nada bloqueante; commit + instalador + push de esta tanda.
