# Tables in Hekatan LISP — text and results

#: Until now only MATRICES were drawn as a table. A true table (bold header, aligned numbers) did not exist: table 6.4.1 of the Simo–Fox–Rifai paper (ex11 §8) had to be written as a line of PROSE. This sheet shows the two new tables, and verifies Greek/engineering notation.

## 1 · TEXT table (written by hand, in a comment)

#: A header row `#| A | B |` followed by the SEPARATOR row `#|---|---:|` (markdown syntax, like GitHub) draws the table. The `:` on the RIGHT of the separator marks that column as a NUMBER (right-aligned); without `:` it stays on the left. Inside each cell **bold** works, and `x^{2}` / `N_{1}` for super/subscript.
#| Iteración | Residuo |
#|---|---:|
#| 0 | 1.4·10⁰ |
#| 1 | 2.6·10⁻¹ |
#| 2 | 4.0·10⁻² |
#| 3 | 5.0·10⁻³ |
#| 4 | 3.1·10⁻⁷ |
#| 5 | **2.7·10⁻¹¹** |
#: Table 6.4.1 of Simo–Fox–Rifai (1990): with the **exact** tangent Newton converges **quadratically** — the error is squared at each step, machine zero in 5 iterations.

## 2 · Table of calculated RESULTS

#: The second table is NOT written by hand: `#tabla("A","B [ud]:N")( colA ; colB )` takes columns ALREADY computed in the sheet (vectors) — or lists of literal text (between braces and quotes, separated by commas) for what is not a number, such as an axis or a column name. The `:N` at the end of a header sets the DECIMALS of that column. It does not go through the SBCL engine: it is a positional render, just like `#beam`/`#fplot`.

### Engineering case: loads per column of the MOD_002 raft

#: REAL project data (not invented): the CSV of removed and kept loads has 37 point loads per pattern, but the raft has only 15 columns (axis crossings 1–6 with A–C, according to "GRID DEFINITIONS" of the .f2k); the other 22 are exact copies of one of those 15, placed 15–75 cm away (MOD 002 raft report, §"Repeated loads"). Here are the 15 REAL ones: the one that falls exactly on the axis crossing (distance 0 to the grid), not its copies.
#: **D = dead load** (self-weight + permanent elements). **DNE = superimposed dead load** (dead load ADDITIONAL to the self-weight: plaster, screed, finishes, partitions — equivalent to "Super Dead" in CSI), NOT live. **L = live load.** Service = D + DNE + L. Design (factored, ACI 318-19 / SAFE "DESIGN") = 1.2D + 1.2DNE + 1.6L.
Columna = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
D = [13.02, 20.90, 27.52, 21.80, 19.13, 12.95, 20.37, 26.19, 22.84, 26.50, 7.48, 16.36, 17.13, 17.69, 17.57]
DNE = [3.34, 9.00, 13.61, 8.25, 4.14, 3.12, 16.60, 23.99, 16.84, 7.71, 1.99, 10.44, 11.01, 11.44, 6.63]
L = [1.68, 4.55, 7.19, 5.01, 3.28, 1.68, 8.33, 12.53, 10.18, 5.02, 1.08, 5.32, 6.37, 6.51, 3.70]
#tabla("Column","Axis","D [t]:2","DNE [t]:2","L [t]:2")(Columna; {"1-C","2-C","3-C","5-C","6-C","1-B","2-B","3-B","5-B","6-B","1-A","2-A","3-A","4-A","6-A"}; D; DNE; L)

#: Check (sum of the 15 columns, with the engine — not by head): the report's real values are Dead 287.5 t, DNE 148.1 t, Live 82.4 t.
Suma_D = dec(D(1)+D(2)+D(3)+D(4)+D(5)+D(6)+D(7)+D(8)+D(9)+D(10)+D(11)+D(12)+D(13)+D(14)+D(15), 1)
Suma_DNE = dec(DNE(1)+DNE(2)+DNE(3)+DNE(4)+DNE(5)+DNE(6)+DNE(7)+DNE(8)+DNE(9)+DNE(10)+DNE(11)+DNE(12)+DNE(13)+DNE(14)+DNE(15), 1)
Suma_L = dec(L(1)+L(2)+L(3)+L(4)+L(5)+L(6)+L(7)+L(8)+L(9)+L(10)+L(11)+L(12)+L(13)+L(14)+L(15), 1)

#: The service and factored load (ACI 318-19), column by column:
Serv = D + DNE + L
Fu = 1.2*D + 1.2*DNE + 1.6*L
#tabla("Column","D+DNE+L [t]:2","1.2D+1.2DNE+1.6L [t]:2")(Columna; Serv; Fu)

#: Total column service load (the 518.0 t of the report: columns + beams 47.1 t + self-weight 142.3 t = 707.5 t of reaction):
Suma_Serv = dec(D(1)+D(2)+D(3)+D(4)+D(5)+D(6)+D(7)+D(8)+D(9)+D(10)+D(11)+D(12)+D(13)+D(14)+D(15)+DNE(1)+DNE(2)+DNE(3)+DNE(4)+DNE(5)+DNE(6)+DNE(7)+DNE(8)+DNE(9)+DNE(10)+DNE(11)+DNE(12)+DNE(13)+DNE(14)+DNE(15)+L(1)+L(2)+L(3)+L(4)+L(5)+L(6)+L(7)+L(8)+L(9)+L(10)+L(11)+L(12)+L(13)+L(14)+L(15), 1)

## 3 · Greek and engineering notation (symbol check)

#: In a MATH line the engine translates the Latin name to the Greek letter BY ITSELF (`phi`→φ, `sigma`→σ…); in TEXT (`#:`, `#|`) the Unicode character is written directly. Alphabet used in engineering:
#: α β γ δ Δ ε θ λ μ ν ξ π ρ σ τ φ Φ ψ ω — and the symbols Ø (bar diameter), ± , ≤ ≥ , ² ³ , ⁻¹ , · (multiplication).
#: Subscripts with Greek, with underscore and braces (new in this sheet): σ_{max}, ε_{c}, φV_{c}, ρ_{min}. In a MATH line, the automatic translation:
ang = phi + theta - psi

### NOTATION table — punching shear (ILLUSTRATIVE values, not the certified calculation)

#: This table is to verify that φ, ² and the subscripts are drawn correctly in a RESULTS table — it does not replace the real project check (done with a traceable Python script, outside this sheet). Report formula (ACI 318-14): v_{c} = min(1.06√f'c ; 0.53(1+2/β)√f'c ; 0.27(α_{s}d/b₀+2)√f'c) kg/cm², φ = 0.75, V_{u} = P_{u} − soil reaction within the perimeter.
bo_p = [1.85, 1.60, 1.85, 1.60, 1.85]
d_p = [0.325, 0.325, 0.325, 0.325, 0.325]
vu_p = [8.10, 11.40, 12.30, 10.85, 6.40]
fvc_p = [9.75, 9.75, 9.75, 9.75, 9.75]
ratio_p = [0.83, 1.17, 1.26, 1.11, 0.66]
#tabla("Column","b₀ [m]:2","d [m]:3","v_u [kgf/cm²]:2","φV_{c} [kgf/cm²]:2","v_u/φV_{c}:2")({"2-B","2-C","3-B","3-C","1-A"}; bo_p; d_p; vu_p; fvc_p; ratio_p)
#: With these illustrative values, 3 of 5 columns (2-C, 3-B, 3-C) give v_{u}/φV_{c} > 1.0 — consistent with the real "4 of 15" reported by the MOD 002 raft report next to the columns next to openings (2-B, 2-C, 3-B, 3-C).

### TEXT table — reinforcement by strip (Ø, bar notation)

#: Hand-written table; also illustrative (the real reinforcement design is in SAFE's steel-by-strip CSV, not in this sheet).
#| Franja | Ø | s [cm] | As [cm²/m] | ρ |
#|---|---|---:|---:|---:|
#| F1 (eje B) | Ø 12 mm | 15 | 7.54 | 0.85% |
#| F2 (eje 3) | Ø 16 mm | 20 | 10.05 | **1.10%** |
#| F3 (eje C) | Ø 12 mm | 20 | 5.65 | 0.63% |
