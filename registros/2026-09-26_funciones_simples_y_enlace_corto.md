# 2026-09-26 — Hoja 86/81 con funciones simples; botón matemática limpio; enlace corto

## ✅ Funcionó
- Motor: `primera`, `centroide-x/y`, `inercia-x/y`, `ancho`, `alto`, `ancho-en` (Green dentro del motor). Hojas 81 y 86 sin defun/foreach/repeat; mismos números (A=0.2025, y_c=0.358333, I_x=0.0065671875).
- Botón «matemática» (vista de resultado): ya no muestra marcas SOH ni HTML suelto; añade «Cálculo con funciones» (`A = area(S)`). Verificado con `--shot`.
- Compartir (WPF): hoja idéntica a un ejemplo → `#ej=nombre&solo=1` (corto) en vez de `#h=` (83 daba 16 000 car.).

## ❌ Falló
- `(length V)` en el `princ` tras quitar V → «variable v is unbound» (AutoLISP no distingue mayúsculas). Ahora `(length (vertices S))`.

## ⏳ Falta
- (hecho) Web recompilada y publicada en gh-pages; #ej=86 verificado con puppeteer (dibujo + A=0.2025).

## Hoja 87 — ShellMITC4 en símbolos (cortante MITC4)
- ✅ `ejemplos/87 ShellMITC4 en simbolos - cortante MITC4 de la placa (OpenSees).lisp`: N, J, dNx/dNy, γ directo y MITC4 (4 puntos de amarre), Ks = Gs·a·b·∫BsᵀBs, Ks_dir−Ks_mitc ≠ 0 (fuente del bloqueo), K·rígido = 0 (w=x y w=1). Renderiza sin errores.
- ❌ Vector plano `[a, b]` es FILA (usar `;`); `x_1` se lee como subíndice numérico (usar `rig_w`); matriz literal sin `Simplify{}` no se asigna; `K − Kᵀ` simbólico sale en blanco.
- ⏳ Convención de signos = mano derecha (γxz = w,x + θy; γyz = w,y − θx); falta compararla contra la hoja 72 (OpenSees) con números y añadir membrana/drilling en símbolos.
