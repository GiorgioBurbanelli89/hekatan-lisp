# Hekatan LISP con MKL Intel + JIT + matmul rápido (como Hekatan Lab) — 2026-09-23

## ✅ Funcionó
- **SBCL llama a MKL directo** (`sb-alien`, sin C#): `cblas_dgemm` y `LAPACKE_dgesv` de `mkl_rt.3.dll` (oneMKL 2026).
- `engine.lisp`: `mmul` → si m·k·n ≥ 32³ y todo son enteros/decimales → arreglo double → MKL.
  Sin MKL → bucle nativo tipado (`speed 3`), que es lo que usará la web (ECL).
- `minv-auto` → n > 20 numérica → `dgesv` contra la identidad (MKL o nativo).
- Chicas / fracciones / letras: camino EXACTO de siempre (las hojas no cambian: `[2,1;1,3]^-1` = 3/5 …).
- Busca MKL en: `HEKATAN_MKL` (`=0` la apaga) → `<app>/mkl/` → `C:/Program Files/Hekatan Lab/mkl/`.
- JIT: SBCL ya corre en `*evaluator-mode* = :compile` → cada `for/while` traducido se compila a código máquina
  (igual idea que el LXE de MATLAB: compila todo, no hay que encenderlo).

| n×n (decimales) | listas (antes) | MKL | nativo sin MKL |
|---|---|---|---|
| 200 | 0.24 s | 0.004 s (×62) | 0.010 s (×22) |
| 400 | 1.8 s | 0.011 s (×165) | 0.068 s (×22) |
| 800 | 29.9 s | 0.12 s (×246) | 1.14 s (×25) |
| inv 150 | — | 0.009 s, ‖A·A⁻¹−I‖ = 1e-14 | 0.06 s |

Diferencia vs listas ≤ 1.4e-8 (redondeo de float). Enteros 50×50: idéntico.
Warnings al cargar: 51 antes = 51 después.

## ❌ No funcionó / cuidado
- `(require :sb-alien)` falla en el SBCL instalado: sb-alien ya viene dentro, no se pide.
- Primer intento `HEKATAN_MKL=C:/nada` igual cargaba MKL → la encontraba en `Program Files/Hekatan Lab`. Se añadió `HEKATAN_MKL=0`.
- Web no se recompiló: disco a 0.6 GB libres (el `ext4.vhdx` de WSL = 17.8 GB).

## ⏳ Falta
- Empaquetar MKL en el instalador de LISP (~400 MB sin comprimir: rt, core, intel_thread, iomp5md, def, mc3, avx2, avx512, avx10).
- Web: recompilar `hlisp.wasm` (ECL) — toma el bucle nativo (`#-sbcl`). MKL no existe en WASM.
- Operador `A\b` (resolver sin invertir) en el traductor C#.
