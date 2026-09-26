# Tablas en Hekatan LISP — texto y resultados

#: Hasta ahora solo las MATRICES se dibujaban como tabla. Una tabla de verdad (encabezado en negrita, números alineados) no existía: la tabla 6.4.1 del paper Simo–Fox–Rifai (ej11 §8) tuvo que escribirse como una línea de PROSA. Esta hoja muestra las dos tablas nuevas, y verifica notación griega/ingenieril.

## 1 · Tabla de TEXTO (escrita a mano, en un comentario)

#: Una fila de encabezado `#| A | B |` seguida de la fila SEPARADORA `#|---|---:|` (sintaxis markdown, como GitHub) dibuja la tabla. El `:` a la DERECHA del separador marca esa columna como NÚMERO (alineada a la derecha); sin `:` queda a la izquierda. Adentro de cada celda funcionan **negrita**, y `x^{2}` / `N_{1}` para súper/subíndice.
#| Iteración | Residuo |
#|---|---:|
#| 0 | 1.4·10⁰ |
#| 1 | 2.6·10⁻¹ |
#| 2 | 4.0·10⁻² |
#| 3 | 5.0·10⁻³ |
#| 4 | 3.1·10⁻⁷ |
#| 5 | **2.7·10⁻¹¹** |
#: Tabla 6.4.1 de Simo–Fox–Rifai (1990): con el tangente **exacto** Newton converge **cuadrático** — el error se eleva al cuadrado en cada paso, cero-máquina en 5 iteraciones.

## 2 · Tabla de RESULTADOS calculados

#: La segunda tabla NO se escribe a mano: `#tabla("A","B [ud]:N")( colA ; colB )` toma columnas YA calculadas en la hoja (vectores) — o listas de texto literal (entre llaves y comillas, separadas por coma) para lo que no es número, como un eje o un nombre de columna. El `:N` al final de un encabezado fija los DECIMALES de esa columna. No pasa por el motor SBCL: es un render posicional, igual que `#beam`/`#fplot`.

### Caso de ingeniería: cargas por columna del radier MOD_002

#: Datos REALES del proyecto (no inventados): el CSV de cargas retiradas y conservadas trae 37 cargas puntuales por patrón, pero el radier solo tiene 15 columnas (cruces de ejes 1–6 con A–C, según "GRID DEFINITIONS" del .f2k); las otras 22 son copias exactas de una de esas 15, puestas a 15–75 cm (informe del radier MOD 002, §"Cargas repetidas"). Aquí van las 15 REALES: la que cae exactamente en el cruce de ejes (distancia 0 a la grilla), no sus copias.
#: **D = carga muerta** (peso propio + elementos permanentes). **DNE = SOBRECARGA muerta** (carga muerta ADICIONAL al peso propio: enlucidos, masillado, acabados, tabiques — equivale al "Super Dead" de CSI), NO es viva. **L = carga viva.** Servicio = D + DNE + L. Diseño (mayorada, ACI 318-19 / SAFE "DISEÑO") = 1.2D + 1.2DNE + 1.6L.
Columna = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
D = [13.02, 20.90, 27.52, 21.80, 19.13, 12.95, 20.37, 26.19, 22.84, 26.50, 7.48, 16.36, 17.13, 17.69, 17.57]
DNE = [3.34, 9.00, 13.61, 8.25, 4.14, 3.12, 16.60, 23.99, 16.84, 7.71, 1.99, 10.44, 11.01, 11.44, 6.63]
L = [1.68, 4.55, 7.19, 5.01, 3.28, 1.68, 8.33, 12.53, 10.18, 5.02, 1.08, 5.32, 6.37, 6.51, 3.70]
#tabla("Columna","Eje","D [t]:2","DNE [t]:2","L [t]:2")(Columna; {"1-C","2-C","3-C","5-C","6-C","1-B","2-B","3-B","5-B","6-B","1-A","2-A","3-A","4-A","6-A"}; D; DNE; L)

#: Verificación (suma de las 15 columnas, con el motor — no de cabeza): la real del informe es Dead 287.5 t, DNE 148.1 t, Live 82.4 t.
Suma_D = dec(D(1)+D(2)+D(3)+D(4)+D(5)+D(6)+D(7)+D(8)+D(9)+D(10)+D(11)+D(12)+D(13)+D(14)+D(15), 1)
Suma_DNE = dec(DNE(1)+DNE(2)+DNE(3)+DNE(4)+DNE(5)+DNE(6)+DNE(7)+DNE(8)+DNE(9)+DNE(10)+DNE(11)+DNE(12)+DNE(13)+DNE(14)+DNE(15), 1)
Suma_L = dec(L(1)+L(2)+L(3)+L(4)+L(5)+L(6)+L(7)+L(8)+L(9)+L(10)+L(11)+L(12)+L(13)+L(14)+L(15), 1)

#: La carga de servicio y la mayorada (ACI 318-19), columna a columna:
Serv = D + DNE + L
Fu = 1.2*D + 1.2*DNE + 1.6*L
#tabla("Columna","D+DNE+L [t]:2","1.2D+1.2DNE+1.6L [t]:2")(Columna; Serv; Fu)

#: Servicio total de columnas (los 518.0 t del informe: columnas + vigas 47.1 t + peso propio 142.3 t = 707.5 t de reacción):
Suma_Serv = dec(D(1)+D(2)+D(3)+D(4)+D(5)+D(6)+D(7)+D(8)+D(9)+D(10)+D(11)+D(12)+D(13)+D(14)+D(15)+DNE(1)+DNE(2)+DNE(3)+DNE(4)+DNE(5)+DNE(6)+DNE(7)+DNE(8)+DNE(9)+DNE(10)+DNE(11)+DNE(12)+DNE(13)+DNE(14)+DNE(15)+L(1)+L(2)+L(3)+L(4)+L(5)+L(6)+L(7)+L(8)+L(9)+L(10)+L(11)+L(12)+L(13)+L(14)+L(15), 1)

## 3 · Notación griega e ingenieril (verificación de símbolos)

#: En una línea de MATEMÁTICA el motor traduce el nombre latino a la letra griega SOLO (`phi`→φ, `sigma`→σ…); en TEXTO (`#:`, `#|`) se escribe el carácter Unicode directo. Alfabeto usado en ingeniería:
#: α β γ δ Δ ε θ λ μ ν ξ π ρ σ τ φ Φ ψ ω — y los símbolos Ø (diámetro de varilla), ± , ≤ ≥ , ² ³ , ⁻¹ , · (multiplicación).
#: Subíndices con griega, con guion bajo y llaves (nuevo en esta hoja): σ_{max}, ε_{c}, φV_{c}, ρ_{min}. En una línea de MATEMÁTICA, la traducción automática:
ang = phi + theta - psi

### Tabla de NOTACIÓN — punzonamiento (valores ILUSTRATIVOS, no el cálculo certificado)

#: Esta tabla es para verificar que φ, ² y los subíndices se dibujan bien en una tabla de RESULTADOS — no reemplaza el chequeo real del proyecto (hecho con un script Python trazable, fuera de esta hoja). Fórmula del informe (ACI 318-14): v_{c} = mín(1.06√f'c ; 0.53(1+2/β)√f'c ; 0.27(α_{s}d/b₀+2)√f'c) kg/cm², φ = 0.75, V_{u} = P_{u} − reacción del suelo dentro del perímetro.
bo_p = [1.85, 1.60, 1.85, 1.60, 1.85]
d_p = [0.325, 0.325, 0.325, 0.325, 0.325]
vu_p = [8.10, 11.40, 12.30, 10.85, 6.40]
fvc_p = [9.75, 9.75, 9.75, 9.75, 9.75]
ratio_p = [0.83, 1.17, 1.26, 1.11, 0.66]
#tabla("Columna","b₀ [m]:2","d [m]:3","v_u [kgf/cm²]:2","φV_{c} [kgf/cm²]:2","v_u/φV_{c}:2")({"2-B","2-C","3-B","3-C","1-A"}; bo_p; d_p; vu_p; fvc_p; ratio_p)
#: Con estos valores ilustrativos, 3 de 5 columnas (2-C, 3-B, 3-C) dan v_{u}/φV_{c} > 1.0 — consistente con el "4 de 15" real que reporta el informe del radier MOD 002 junto a las columnas junto a huecos (2-B, 2-C, 3-B, 3-C).

### Tabla de TEXTO — armado por franja (Ø, notación de varilla)

#: Tabla escrita a mano; también ilustrativa (el diseño real de armado está en el CSV de acero por franja de SAFE, no en esta hoja).
#| Franja | Ø | s [cm] | As [cm²/m] | ρ |
#|---|---|---:|---:|---:|
#| F1 (eje B) | Ø 12 mm | 15 | 7.54 | 0.85% |
#| F2 (eje 3) | Ø 16 mm | 20 | 10.05 | **1.10%** |
#| F3 (eje C) | Ø 12 mm | 20 | 5.65 | 0.63% |
