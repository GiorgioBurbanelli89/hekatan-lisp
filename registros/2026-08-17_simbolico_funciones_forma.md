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
- ⏳ reescribir engine.lisp con polinomios racionales.
