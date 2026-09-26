# 2026-09-26 — Hoja 86/81 con funciones simples; botón matemática limpio; enlace corto

## ✅ Funcionó
- Motor: `primera`, `centroide-x/y`, `inercia-x/y`, `ancho`, `alto`, `ancho-en` (Green dentro del motor). Hojas 81 y 86 sin defun/foreach/repeat; mismos números (A=0.2025, y_c=0.358333, I_x=0.0065671875).
- Botón «matemática» (vista de resultado): ya no muestra marcas SOH ni HTML suelto; añade «Cálculo con funciones» (`A = area(S)`). Verificado con `--shot`.
- Compartir (WPF): hoja idéntica a un ejemplo → `#ej=nombre&solo=1` (corto) en vez de `#h=` (83 daba 16 000 car.).

## ❌ Falló
- `(length V)` en el `princ` tras quitar V → «variable v is unbound» (AutoLISP no distingue mayúsculas). Ahora `(length (vertices S))`.

## ⏳ Falta
- (hecho) Web recompilada y publicada en gh-pages; #ej=86 verificado con puppeteer (dibujo + A=0.2025).
