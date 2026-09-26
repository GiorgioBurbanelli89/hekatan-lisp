# Manual Hekatan LISP: capturas anotadas (24-sep-2026)

## ✅ Funcionó
- Exe limpio compilado en hekatan-lisp-3d (main dec7583); bin/obj borrados al final.
- Foto SOLO de la ventana (PrintWindow) + --ctl + UIA invoke/expand; ventana con SW_SHOWNOACTIVATE / SWP_NOACTIVATE.
- anotar.py: número fuera del marco; prueba sitios alrededor y descarta los que pisan texto medido, otro número, línea de otro marco o píxeles de letra; si no cabe, guía (sin cruzar texto ni otros marcos).
- Menú Dibujo (popup = otra hwnd): PrintWindow de la hwnd del popup pegada en su sitio.
- Ventana CAD: teclas y ratón como eventos del DOM (TECLAS/MOVER); webzoom 0.85 para que la barra de estado quepa en una fila.
- PDF: 29 págs (manual) y 15 (dibujo); imágenes caben (max-height 245 mm en impresión).

## ❌ No funcionó (y por qué)
- captura de página entera con barra de desplazamiento: ancho distinto al medido → overflow hidden antes de medir y capturar.
- Forzc movía el cursor a la rejilla → se usa hkCad.cursor() real.
- Cajas de texto del DOM tapadas por la ventana CAD contaban como texto → filtro con elementFromPoint.
- Ventana quedó minimizada una vez → hkapp.asegurar() la restaura sin activar.
- Motor: Limit{(1+1/n)^n @ n = inf}, Sum{1/2^k @ k = 0 : inf} y Taylor{e^x @ x = 0 : 4} no dan resultado (no se documentan).

## ⏳ Falta
- Push / publicar (lo hace Jorge).
- El botón 🖩 del escritorio sale como una rayita en PrintWindow (glifo emoji de WPF).
