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

## Hoja 87 — signos comparados con OpenSees y membrana
- ✅ Cortante MITC4: K de 1 elemento en OpenSees 3.7.1 (rect. 1×0.5, h=1e-4 para que la flexión no pese; dofs uz, rx, ry) vs mi Ks: γxz = w,x + θy y γyz = w,y − θx → error 2.5e-9; las otras 3 combinaciones de signo: 0.2–2.4. La convención de la hoja era la correcta.
- ✅ Membrana Q4 + drilling: Bm (3×12) y bd = [−½N,y, ½N,x, −N], Ktt = G·h, Gauss 2×2 → error 2e-16 vs OpenSees (dofs ux, uy, rz). En la hoja: `K_plano = Km + Kd`; entradas K(1,1) y K(1,2) simbólicas evaluadas con números = OpenSees (10576.923077, 3245.192308).
- Scripts: hekatan-opensees/opensees_port/shellmitc4/verificar_cortante_mitc4_rect.py y verificar_membrana_drilling_rect.py (repo privado, sin commit).
- ⏳ Falta: flexión (DKQ/placa de sección) en símbolos y cuadrilátero general (J no diagonal, base local g1,g2,g3).

## Hoja 87 — flexión y placa completa
- ✅ Sección 9: `Db`, `Bb` (κxx = θy,x; κyy = −θx,y; 2κxy = θy,y − θx,x), `Kb`, `K_placa = Kb + Ks_mitc` (Gs → 5Eh/12(1+ν)). Renderiza sin errores (10 págs.).
- ✅ Validación de lo TECLEADO en la hoja: `verificar_hoja87_vs_opensees.py` parsea gx, gy, Bb, Bm, bd de la hoja, arma K con numpy y compara con OpenSees: placa 1.6e-16, plano 2.1e-16 (rectángulo 1×0.5, h=0.1).
- ⏳ Falta: cuadrilátero general (J no diagonal, base local g1,g2,g3; sin forma cerrada → Gauss con símbolos/números) y el conjunto 24×24.

## Hoja 87 — cuadrilátero general (sección 10)
- ✅ Membrana + drilling + flexión con J general (gradiente = inv(J)·dN, dvol = det J, 4 puntos de Gauss): 4e-16 vs OpenSees (cuadrilátero de la hoja 72, ejes locales computeBasis).
- ✅ HALLAZGO: el cortante de OpenSees en un cuadrilátero distorsionado NO es el MITC4 de libro (covariante con J⁻¹): esa versión da 6.8 % de diferencia. OpenSees usa G_m (deformación a lo largo de cada lado), Ms (1±ξ, 1±η), escala r/(8 detJ) y giro R(α, β) → 1.6e-16.
- ✅ La hoja (numérica, sin Simplify) da k_p11 = 9444.938184, k_p12 = 2857.407799, k_p33 = 2283.974359, k_b11 = 4594.724, k_b22 = 1196.357295, k_b25 = 734.564877 = OpenSees a 10 cifras. 0 ⚠, 0 errores JS (render_html.py).
- ❌ `Simplify{}` NO ve variables numéricas de la hoja (x_l, etc. quedan sin resolver): la parte con números va SIN Simplify. `A(1, :)` y un literal `[a, b, c]` son COLUMNAS → `transpose(...)` para filas. `K_plano` simbólico y numérico no pueden compartir nombre (sale «función desconocida»).
- ⚠ La hoja tarda ~10–16 s: `--pdf`/`--shot` salen «calculando…»; usar `--html` + render_html.py.
- Script: hekatan-opensees/opensees_port/shellmitc4/verificar_cuadrilatero_general_hoja87.py (repo privado, sin commit).
- ⏳ Falta: ensamblar los 24×24 en ejes globales (rotación con g1, g2, g3) y el cuadrilátero alabeado (hoja 72 ya lo tiene en números).
