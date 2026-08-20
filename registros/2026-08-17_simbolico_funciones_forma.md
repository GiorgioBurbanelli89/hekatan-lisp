# Bitácora — Hekatan LISP simbólico → funciones de forma (2026-08-17)

Meta: funciones de forma **simbólicas** (1D 2/3/4/n GDL, luego 2D), probando por `--ctl`.

## Diagnóstico del motor simbólico (engine.lisp) — antes
- ✅ `a=2` → `a+3` = **5** (variable numérica + uso).
- ❌ `f = x^2+3*x` → **⚠ «x» sin valor**: la asignación evalúa numérico, NO guarda expresión simbólica.
- ❌ simplify `(1-s)/2+(1+s)/2` → queda igual (no combina fracciones). Debe dar **1**.
- ❌ deriv `d/ds (1-s)/2` → **0** (deriva a `x`, no a `s`). Debe dar **-1/2**.
- ⚠ expand `(1-s)(1+s)` → LISP ok pero render `1+s-s+s^2` (pierde paréntesis del `-`). Debe dar **1-s²**.

Causa: `engine.lisp` es reescritor de árbol a mano; `derive-x` fija `'x`; `simplify`/`collect` no manejan fracciones ni el `-`.

## Plan
- Motor de **polinomios con coef. racionales** (exacto) para simplify/expand/deriv.
- deriv respecto a la **variable detectada** (no fija a x).
- Fallback al motor viejo si no es polinomio (p.ej. denominador no constante).

## Progreso
- ✅ engine.lisp reescrito con polinomios de coef. RACIONALES (exacto).
- ✅ simplify/expand exactos: (1-s)/2+(1+s)/2→1 ; (1-s)(1+s)→1-s².
- ✅ derive-x deriva a la VARIABLE DETECTADA (ya no fija a x): d/ds (1-s)/2→-1/2.
- ✅ integ-x / defint-x: ∫ polinomios. ∫N1²[-1,1]=2/3, ∫N1N2=1/3 (masa 1D exacta).
- ✅ botón "∫ integrar" enganchado (EvalOp/SetOp/--ctl/--op). Verificado por --ctl.
- ✅ perf: matemática 0.003 ms/op; cuello = arranque SBCL ~60 ms/cálculo.
- ✅ v1.3.0 publicado (GitHub + instalador).
- ✅ Guía "De MATLAB a LISP" (artefacto, 3 columnas Render·MATLAB·LISP, 9 lecciones
     + funciones de forma 1D). Verificada por PNG.
- ⏳ opcional: SBCL vivo (servidor) para bajar de 60 ms a µs.
- ⏳ opcional: viga Euler-Bernoulli (cúbicos de Hermite) — mismo motor, derivar 2x = curvatura.
- ⏳ pendiente stage 2: guardar EXPRESIÓN simbólica en variable (N1 = (1-s)/2) y reusar.
