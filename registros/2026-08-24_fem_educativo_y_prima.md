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

## ej26 §1/§2 — combinar variables y texto (no texto plano)  [25-ago]
Jorge: "no estás combinando, veo texto plano allí" (las leyes dV/dx=−q, dM/dx=V estaban TECLEADAS como texto). Ahora van con `{}` inline: `{V - (V + dV) - q*dx} = 0`, `{dV/dx} = {-q}` (fracción de verdad), `{dM/dx} = {V}`, y en §2 `{V} = {dM/dx}`, `{-dV/dx} = {q}`, `{M} = {EI}·κ`.
- Motor (dos reglas para `{}` inline): (a) un `=` DENTRO de las llaves ROMPE — se pierde lo que va tras el `=`; usar `{lhs} = {rhs}` con el `=` literal afuera. (b) las PRIMAS dentro de `{}` se pierden (`{v''''}`→"v"); dejar `v″`/`v⁗` como texto literal, combinar solo lo demás. Los diferenciales `dV`,`dM`,`dx` sí son un solo símbolo y `{dV/dx}` sale como fracción.

## ej26 §1/§2 — las variables van FUERA del comentario, el comentario solo las llama  [25-ago]
Jorge: "las variables se escriben fuera de comentarios, solo las llama". Mi error: metí fórmulas ({V-(V+dV)-q*dx}, {dV/dx}) DENTRO de los `#:`. Regla suya (ver [[feedback_hekatan_lisp_solo_operaciones_no_texto]]): las fórmulas son LÍNEAS DE OPERACIÓN del motor; en el comentario solo se llama la variable por nombre.
- ✅ §1: `Fy = V - (V + dV) - q*dx` y `Mo = (M + dM) - M - V*dx` como operaciones (con label en palabras). Los `#:` solo llaman variables sueltas: {V}, {dV}, {q}, {M}, {dM}. Las leyes (cortante cae con la carga, momento crece con el cortante) en palabras.
- ✅ §2: prosa que llama {M},{V},{q},{EI} y describe geometría/material/encadenado en palabras; la prueba operacional de EI·v⁗=0 está en §3 (Diff chain).
- Nota motor: no auto-simplifica (`V-(V+dV)` NO se reduce a `-dV`); igual la operación se ve bien y el comentario explica la cancelación.

## ej26 §3 — de dónde SALE el polinomio: integrar v⁗=0 cuatro veces  [25-ago]
Jorge: "el polinomio no se entiende". Antes §3 daba "una cúbica cualquiera a0+a1x+…" (asumida). Ahora se DEDUCE hacia adelante: integrar EI·v⁗=0 cuatro veces.
- ✅ Motor: `Integral{}` es indefinida y AGREGA +C. Cadena: `kappa=Integral{c3}` → κ=c3·x+C (curvatura, recta); `theta=Integral{c3*x+c2}` → θ=c3·x²/2+c2·x+C (giro); `vdef=Integral{c3*x²/2+c2*x+c1}` → c3·x³/6+c2·x²/2+c1·x+C = CÚBICA. Cada ∫ mete una constante → 4 constantes = 4 datos de nudo. κ,θ en griego (nombre de variable).
- Es la única forma cuya 4ª derivada se anula → conecta con la cúbica del paso 4. Reemplazó la cadena de Diff (que era el chequeo AL REVÉS).

## ej26 §2 — explicar QUÉ ES v (la deflexión), con dibujo  [25-ago]
Jorge: "ni siquiera explicas el término v". Usaba v/v′/v″/v⁗ sin decir qué es.
- ✅ Nueva directiva `#defl` (BeamSchematic.DeflPng): viga simplemente apoyada con su deformada v(x) (curva seno hacia abajo), la flecha v marcada en un x, eje x. Aclara además v (deflexión, minúscula) ≠ V (cortante, mayúscula).
- ✅ §2 arranca explicando v = cuánto baja el eje en cada x = la incógnita; y nombra sus derivadas (v′ giro, v″ curvatura, v⁗ en la ecuación).
- Trampa del regex de directivas: un encabezado `# Deflexion` disparaba la directiva (empieza con la palabra). Dejé solo la clave `defl` (no `deflexion`/`deformada`) para no chocar con títulos.

## ej26 §3 — VIGA REAL (voladizo con L) en vez de constantes abstractas  [25-ago]
Jorge: "no se entiende, vas directo a las c; quiero ver una integral simbólica, la solución de una viga L con fórmulas (cortante, deflexión)". Las constantes c3,c2,c1 abstractas no se entendían.
- ✅ §3 ahora resuelve un VOLADIZO concreto (largo L, carga P en la punta): `Mvol = -P*(L-x)` → `EIvp = Integral{}` (EI·v′) → `EIv = Integral{}` (EI·v = P·x³/6 - L·P·x²/2) → `vpunta = -P·L³/(3·EI)` (la flecha clásica). El empotramiento hace ambas constantes = 0 (v(0)=0, v'(0)=0), así el motor no necesita resolver el sistema. Fórmulas REALES con L, integral simbólica visible.
- ✅ Cierre: la deflexión salió CÚBICA → generaliza: sin carga EI·v⁗=0 ⇒ siempre cúbica (4 constantes) ⇒ en el elemento las fijan los 4 datos de nudo (paso 4).
- ❌→✅ Leak: definir `M` en §3 pisaba el `{M}` de §2 y el `M` del `Mo` de §1 → renombrado `Mvol`.
- El `∫` que "se cortaba" era por 3 integrales APILADAS (sin prosa entre ellas); con prosa entre cada operación el `∫` sale completo. (Nota: el clip de integrales apiladas sigue latente en el CSS — `.m-dvr top:-3pt` + `.m-nary` 240% — no crítico.)

## ej26 — estilo LIBRO de resistencia, simbólico, sin números  [25-ago]
Jorge: "hazlo como el libro de resistencia de materiales, sin operaciones numéricas hasta que te diga".
- Motor NO puede `∫₀ᴸ` con L simbólico (da "?"). Confirmado con probe. Por eso se mantiene la sustitución s=x/L (que el libro también usa) para las integrales de rigidez.
- ✅ §4: fuera la inversión de matriz NUMÉRICA (A=[números], Ainv). Ahora estilo libro: cada función de forma = la cúbica con UN dato de nudo=1 y los otros 0; condiciones en palabras; el L del giro explicado (θ=(1/L)dv/ds). N1..N4 quedan como operaciones (resultado).
- ✅ §8: quitado "con EI=1 y L=1 da los números". K = (EI/L³)·K_coef, todo en símbolos.
- Regla nueva de Jorge → memoria: TODO simbólico (EI, L), sin meter números, hasta nuevo aviso.

## ej26 §4 — DEDUCIR los coeficientes de N1 (de dónde sale 1,−3,2)  [25-ago]
Jorge: "N1 = 1−3s²+2s³, ¿de dónde sale? falta agregarlo". Yo daba las condiciones en palabras y saltaba al resultado.
- ✅ Ahora: `vpol = a0+a1*s+a2*s^2+a3*s^3` (cúbica), `vslope = Diff{}` = 3a3·s²+2a2·s+a1 (operaciones). Condiciones: s=0 → a0=1, a1=0; s=1 → 1+a2+a3=0 y a1+2a2+3a3=0 → a3=2, a2=−3 → N1. N2 con el L (giro 1 pide pendiente L → a1=L → a2=−2L, a3=L). N3/N4 por simetría.

## ej26 §4 — RAZONAR por qué la cúbica (no elegirla)  [25-ago]
Jorge: "no entiendo la cúbica, por qué usas ese polinomio, razóname". Yo asumía "la cúbica del paso 3".
- ✅ Agregado el razonamiento al inicio de §4: sin carga en el tramo → EI·v⁗=0 → 4ª derivada cero → integrar 4 veces solo puede dar grado 3 (nada mayor sobrevive) con 4 constantes → CÚBICA. "No la elijo yo: me la impone la física." Y las 4 constantes calzan con los 4 datos de nudo.

## ej26 §4 — la cúbica NACE de la elástica de Timoshenko + GRÁFICAS  [25-ago]
Jorge: "vpol parece de memoria, no entiendo de dónde viene ni por qué lo usas; quiero como Timoshenko puro simbólico; y grafica hazlo entendible".
- ✅ §4 arranca de la elástica EI·v″=M (Timoshenko). Sin carga → cortante constante → momento RECTA (m0+m1·x). `EIv1=Integral{recta}` (parábola, EI·v′), `EIv2=Integral{}` (grado 3, EI·v). "AHÍ nace la cúbica: integrar 2 veces una recta da grado 3." Luego se reagrupan las 4 constantes en a0..a3 y se pasa a s=x/L → vcubica. Ya NO es de memoria.
- ✅ GRÁFICAS con `#fplot`: `#fplot(N1, N3, [0 1])` (descensos, se cruzan en 0.5) y `#fplot(N2f, N4f, [0 1])` (giros, la parte sin L, se arquean ±). Se VE la forma que toma la viga con cada dato de nudo. `#fplot` acepta varias curvas por nombre.

## ej26 §4 — gráfica del mecanismo INTEGRAR (recta→parábola→cúbica)  [25-ago]
Jorge confundía: "¿de la función lineal la derivo 4 veces?". No — es INTEGRAR (subir), no derivar (bajar). Desde el momento (recta) integro 2 veces.
- ✅ Nota aclaratoria + gráfica `#fplot(Mg, v1g, v2g, [0 1])` con c0=c1=1 de ejemplo: recta (momento) → parábola (∫) → cúbica (∫∫). Cada integral sube un grado. (Derivar bajaría: cúbica→…→0.)
- ✅ m0/m1 → c0/c1 (parecían masa): c0=valor en 0, c1=pendiente de la recta.

## ej26 §4 — una gráfica DESPUÉS DE CADA ecuación  [25-ago]
Jorge: "no entiendo, grafícala, ponla luego de cada ecuación". Antes tenía una sola gráfica combinada al final.
- ✅ PASO 1 recta (símbolo + recta_g=1+x) → #fplot línea. PASO 2 EIv1 (∫) + EIv1_g → #fplot parábola. PASO 3 EIv2 (∫∫) + EIv2_g → #fplot cúbica. Cada ecuación con su gráfica justo debajo; se ve subir de grado paso a paso.

## ej26 §4 — DEDUCIR por qué M es recta (simbólico + gráfico)  [25-ago]
Jorge: "¿de dónde se deduce que M es recta? debe haber razonamiento, explícalo gráficamente y con variables simbólicas".
- ✅ Antes de PASO 1: sin carga q=0 → V=Integral{0}=constante → M=Integral{V0}=V0·x+M0=RECTA. Simbólico con `Integral` (engine) y gráfico `#fplot(qcero, Vcteg,[0 1])` (q plano en 0, V horizontal). Cadena completa: q=0 → V cte → M recta → v′ parábola → v cúbica.
- Motor: `#fplot` grafica constantes (`0*x`, `2+0*x`).

## ej26 §4 — figura de LIBRO: viga + diagramas apilados y alineados  [25-ago]
Jorge: "prefiero ver la viga en la misma gráfica y debajo la carga para entender, no entiendo nada". Las #fplot sueltas no ayudaban.
- ✅ Nueva directiva `#diag` (BeamSchematic.BeamDiagramsPng): voladizo con carga P arriba, y ALINEADOS debajo (mismo eje x, guías punteadas en los nudos): q=0 (plano), V (franja constante), M (triángulo/recta), v (cúbica). La figura clásica de resistencia.
- ✅ §4 ahora abre con `#diag` y la deducción camina por el diagrama (integrar de arriba abajo: q→V→M→v). Quitadas las #fplot sueltas (qcero/Vcteg/recta_g/EIv1_g/EIv2_g).

## ej26 §4 — cada diagrama CON su viga + aclarar q=0  [25-ago]
Jorge: "preferible cada gráfica vaya con su viga" y "¿qué es q=0, se supone?".
- ✅ `#diag` ahora acepta cuál: `#diag(carga|cortante|momento|deflexion)` dibuja la viga + ESE diagrama; `#diag` (sin arg) los 4. §4 camina paso a paso, cada uno con su viga.
- ✅ Aclarado q=0: el elemento solo recibe fuerzas en los NUDOS (extremos); la P está en la punta, no repartida → a lo largo del tramo q=0. No es supuesto: define al elemento.
- Colisión regex: un encabezado que empiece con "diag" dispara la directiva (como pasó con "deflexion"). En ej26 no ocurre (headers no empiezan así).

## ej26 §4 — explicar el REAGRUPAR a a0..a3 (analogía de Jorge)  [25-ago]
Jorge captó: "está reemplazando, cómo decir 3x+4x² es ax+bx², explícalo".
- ✅ Explicado: los coeficientes de la cúbica integrada son mezcla de c0,c1,EI,constantes, pero esos valores no importan aún; lo que importa es que es cúbica con 4 números libres → les pongo letras a0..a3 (como 3x+4x² → ax+bx²), que se FIJAN después con las 4 condiciones de nudo.

## Render — el ∫ se cortaba por arriba (CSS)  [25-ago]
Jorge: "no se ve toda la integral, arregla eso en el CSS".
- ✅ Causa: el contenedor de línea math recorta el glifo alto del ∫ (m-nary 240% + m-dvr top:-3pt). Fix: `padding:.4em 0 .25em`. OJO: hay DOS contenedores — `.ws-eq` (línea normal) y `.ws-deq>.deq-body` (línea con etiqueta `@@`). Las líneas de ej26 tienen `@@`, así que la clave era `.ws-deq>.deq-body` (el primer intento solo tocó `.ws-eq`). Verificado con la línea Mrecta (con `@@`).

## Hekatan LISP — nombre del archivo VISIBLE arriba (como Hekatan Lab)  [25-ago]
Jorge: "Hekatan Lab muestra el nombre arriba al abrir/guardar; en Hekatan LISP no veo esa parte".
- ✅ TextBlock `LblFile` en la fila 0 (arriba derecha), italic/muted, actualizado en `SetCurrentFile`. Además `--in` ahora llama `SetCurrentFile(inFile)` (antes no seteaba nombre ni título). Verificado con captura de VENTANA (`--view lisp --shot` usa RenderTargetBitmap → incluye el chrome): muestra "26 De donde sale...lisp".
- Nota Hekatan Lab render: [[reference_hekatan_lab_css_eq_vs_graficas]] — sus ecuaciones no llevan overflow-y:hidden (no cortan el ∫); el ∫ del ejemplo se verifica abriendo Lab con un .m posicional (`HekatanLab.exe archivo.m`, NO `--in`).

## Falta / opcional
- ⏳ nada bloqueante; commit + instalador + push de esta tanda.
