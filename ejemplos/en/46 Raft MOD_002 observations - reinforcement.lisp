# Observations sheet — Raft MOD_002 (SAFE model review)

#: Review report with DRAWINGS: raft plan with the observations numbered on the plan, and the reinforcement of a design strip converted to bars. Every datum comes from the delivered files (the corrected .f2k, the list of repeated loads, the steel per strip exported from SAFE and the review report); what can be computed, the sheet computes.

## 1 · Geometry (from the .f2k: GRID DEFINITIONS, FLOOR and NULL AREA OBJECT CONNECTIVITY)

#: Axes 1–6 in X and A–C in Y, as in the model's grid table:
x_e = [0, 3.65, 7.95, 10.65, 12.2, 14.95]
y_e = [0.925, 5.225, 9.525]
#: Slab edge (m): from x = −0.15 to 15.075 and from y = 0.175 to 9.675.
x_0 = -0.15
x_1 = 15.075
y_0 = 0.175
y_1 = 9.675
L_x = dec(x_1 - x_0, 3)
L_y = dec(y_1 - y_0, 3)
#: The 7 openings (NULL AREA): lower-left corner (hx, hy), width hb and height hh, in m.
hx = [1.25, 4.4, 1.25, 4.4, 8.7, 11.4, 8.7]
hy = [5.975, 5.975, 1.675, 1.675, 1.675, 1.675, 5.975]
hb = [1.65, 2.8, 1.65, 2.8, 1.2, 1.55, 2.7]
hh = [2.2, 2.2, 2.8, 2.8, 2.8, 2.8, 2.2]
A_h = dec(hb(1)*hh(1) + hb(2)*hh(2) + hb(3)*hh(3) + hb(4)*hh(4) + hb(5)*hh(5) + hb(6)*hh(6) + hb(7)*hh(7), 2)
#: Slab of 40 cm in general and 60 cm in the three strips between openings on axis B (LCIM 60cm):
zx = [2.9, 7.2, 11.4]
zb = [1.5, 1.5, 1.55]
#: Column pedestals (PEDESTAL, 15): corner (px, py), sides pb × ph in m.
px = [-0.15, 3.45, 7.75, 12.05, 14.775, -0.15, 3.525, 7.75, 12.0, 14.825, -0.15, 3.525, 7.75, 10.45, 14.825]
py = [9.375, 9.375, 9.375, 9.275, 9.275, 5.075, 4.925, 5.075, 5.075, 4.925, 0.775, 0.775, 0.775, 0.775, 0.775]
pb = [0.3, 0.4, 0.4, 0.3, 0.3, 0.3, 0.25, 0.4, 0.4, 0.25, 0.3, 0.25, 0.4, 0.4, 0.25]
ph = [0.3, 0.3, 0.3, 0.4, 0.4, 0.3, 0.6, 0.3, 0.3, 0.6, 0.3, 0.6, 0.3, 0.3, 0.6]

## 2 · Observations on the plan

#: The 22 REPEATED loads per pattern (list of removed and kept loads; the same in Dead, DNE and Live), in m:
xq = [-0.15, -0.15, -0.15, -0.15, -0.15, 0, 0, 1.25, 10.65, 10.65, 12.2, 12.2, 14.95, 14.95, 15.075, 15.075, 15.075, 15.075, 15.075, 3.65, 7.95, 7.95]
yq = [0.925, 3.075, 5.225, 7.075, 9.525, 0.175, 9.675, 7.075, 0.175, 5.975, 4.475, 9.675, 0.175, 9.675, 0.925, 3.075, 5.225, 7.075, 9.525, 9.675, 0.175, 9.675]
#: With them the column load of the received model was 1127.8 t instead of the real 518.0 t (report, §1):
f_rep = dec(1127.8/518.0, 2)
#: Maximum SERVICE soil pressure of the corrected model (SAP2000 = SAFE 20 = Hekatan to 4 digits, report §3a), in t/m² and in kg/cm²:
q_max = 13.48
q_kgcm = dec(q_max/10, 2)
#: Columns with punching v_{u}/φv_{c} > 1.0 in DESIGN (report §4): 2-B, 2-C, 3-B and 3-C, next to the openings.
xp = [3.65, 3.65, 7.95, 7.95]
yp = [5.225, 9.525, 5.225, 9.525]
#dibujo("MOD_002 raft plan — observations", ud = m, cotas = m)
#  rect(x_0, y_0, L_x, 1.5, "resalte azul")
#  rect(zx, 4.475, zb, 1.5, "resalte naranja")
#  rect(x_0, y_0, L_x, L_y, "gruesa")
#  hueco(hx, hy, hb, hh)
#  rect(px, py, pb, ph, "relleno fina")
#  ejesx(x_e, "1")
#  ejesy(y_e, "A")
#  cotas(x_e, y_0, -0.7)
#  cota(x_0, y_0, x_1, y_0, -1.5)
#  cotasy(y_e, x_1, -0.7)
#  cota(x_1, y_0, x_1, y_1, -1.5)
#  texto(7.5, 1.3, "strip CSA1 (b = 1.50 m)", 2.2, "c", estilo = "azul")
#  obs(1, xq, yq, "corregida", "22 point loads repeated per pattern (copies 15–75 cm from their column): the column load was {f_rep} times the real one. Removed in the corrected .f2k (15 per pattern remain).")
#  obs(2, x_1, y_1, "pendiente", "Maximum SERVICE pressure {q_max} t/m² = {q_kgcm} kg/cm² at corner 6-C: compare with the allowable capacity of the soil study.", dx = 6, dy = 6)
#  obs(3, xp, yp, "pendiente", "Punching v_{u}/φv_{c} > 1.0 (DESIGN, ACI 318-14) at 2-B, 2-C, 3-B and 3-C, next to the openings: raise the local depth, move away/reduce openings or add shear reinforcement.", dx = 3.5, dy = 3.5)
#  obs(4, 5.8, 5.225, "corregida", "Self weight at zero (Self Weight Multiplier = 0 in the 3 patterns): 142.3 t were missing (slab + beams). Activated in Dead.")
#  leyenda("Axis", "eje")
#  leyenda("Opening", "hueco")
#  leyenda("60 cm slab", "resalte naranja")
#  leyenda("Strip CSA1", "resalte azul")
#  leyenda("Pending obs.", "pendiente")
#  leyenda("Corrected obs.", "corregida")
#fin

#: Net slab area (without openings), for control: the plan measures {L_x} × {L_y} m and the openings add up to {A_h} m².

#salto

## 3 · Reinforcement of strip CSA1 (axis A) with the SAFE steel

#: Strip CSA1 runs along axis A (y = 0.925 m), width 0.75 + 0.75 = 1.50 m (STRIP OBJECT CONNECTIVITY), 40 cm slab. SAFE gives the REQUIRED area at each station (Start, Middle, End) of each span between axes; it is copied in cm², spans 1–2 to 5–6:
As_si = [4.54, 1.19, 0.12, 0.60, 16.78]
As_sc = [12.25, 4.82, 1.67, 7.01, 24.34]
As_sj = [2.83, 0.26, 0.35, 16.78, 1.70]
As_ii = [0.55, 5.13, 7.51, 4.93, 0]
As_ic = [0, 0, 2.60, 0, 0]
As_ij = [6.47, 8.62, 3.73, 0, 0.67]
#: Envelope of each span (the largest of the three stations), top and bottom face:
As_sup = max(As_si, As_sc, As_sj)
As_inf = max(As_ii, As_ic, As_ij)
#: INEN bars: Ø 16 mm top and Ø 14 mm bottom. Area of one bar in cm², A_{b} = π·Ø²/4 with Ø in mm and /100 to convert to cm²:
db_s = 16
db_i = 14
Ab_s = dec(pi*db_s^2/400, 3)
Ab_i = dec(pi*db_i^2/400, 3)
#: Number of bars with the SAFE rule, n = ⌈A_{s}/A_{b}⌉ (rounded UP):
n_s = ceil(As_sup/Ab_s)
n_i = ceil(As_inf/Ab_i)
#: Spacing = width/n rounded DOWN to a multiple of 2.5 cm (Hekatan convention, so that the site spacing is never greater than the design one):
b_f = 150
s_s = floor(b_f/n_s/2.5)*2.5
s_i = floor(b_f/n_i/2.5)*2.5
#: Steel provided, which must be ≥ the required:
Asp_s = dec(n_s*Ab_s, 2)
Asp_i = dec(n_i*Ab_i, 2)
#tabla("Span","A_{s,top} [cm²]:2","n top:0","s top [cm]:1","A_{s,bot} [cm²]:2","n bot:0","s bot [cm]:1")({"1–2","2–3","3–4","4–5","5–6"}; As_sup; n_s; s_s; As_inf; n_i; s_i)
#: Note: where SAFE asks for less than one bar (span 3–4 top, 5–6 bottom) the rule gives n = 1 and s = 150 cm. There the minimum steel and maximum spacing of the code govern, which this sheet does NOT yet verify.

### Reinforcement elevation (d = h − 7.5 cm, as in the report)

#: The strip is 15.2 m long and 0.40 m high: at real scale the slab would be a line, so the elevation is drawn with the vertical exaggerated ×5 (stated in the title). The bottom bars are drawn 10 cm further in only so that their hook does not cover the top one.

h_l = 0.40
r_c = 0.075
#dibujo("Strip CSA1 — elevation (width 1.50 m, slab 40 cm)", ud = m, ancho = 180, vert = 5, cotas = m)
#  rect(x_0, 0, L_x, h_l, "gruesa")
#  ejesx(x_e, "1")
#  varillas(x_0 + r_c, h_l - r_c, x_e(2), h_l - r_c, n_s(1), db_s, s_s(1), -90, 0, -1)
#  varillas(x_e(2), h_l - r_c, x_e(3), h_l - r_c, n_s(2), db_s, s_s(2), 0, 0, -1)
#  varillas(x_e(3), h_l - r_c, x_e(4), h_l - r_c, n_s(3), db_s, s_s(3), 0, 0, -1)
#  varillas(x_e(4), h_l - r_c, x_e(5), h_l - r_c, n_s(4), db_s, s_s(4), 0, 0, 1, off = 3.55)
#  varillas(x_e(5), h_l - r_c, x_1 - r_c, h_l - r_c, n_s(5), db_s, s_s(5), 0, -90, -1)
#  varillas(x_0 + r_c + 0.1, r_c, x_e(2), r_c, n_i(1), db_i, s_i(1), 90, 0, 1)
#  varillas(x_e(2), r_c, x_e(3), r_c, n_i(2), db_i, s_i(2), 0, 0, 1)
#  varillas(x_e(3), r_c, x_e(4), r_c, n_i(3), db_i, s_i(3), 0, 0, 1)
#  varillas(x_e(4), r_c, x_e(5), r_c, n_i(4), db_i, s_i(4), 0, 0, -1, off = 3.55)
#  varillas(x_e(5), r_c, x_1 - r_c - 0.1, r_c, n_i(5), db_i, s_i(5), 0, 90, 1)
#  cotas(x_e, 0, -0.3)
#  cota(x_0, 0, x_1, 0, -0.6)
#  leyenda("Rebar (label: quantity Ø diameter @ spacing)", "varilla")
#fin

### Cross section of span 1–2

h_c = 40
rc = 7.5
#: The bars are centered in the width: the first at (b − (n − 1)·s)/2 from the edge, with the center at 7.5 cm from each face.
#dibujo("Section of strip CSA1, span 1–2", ud = cm, cotas = cm, ancho = 170)
#  seccion(0, 0, b_f, h_c)
#  fila((b_f - (n_s(1) - 1)*s_s(1))/2, h_c - rc, (b_f + (n_s(1) - 1)*s_s(1))/2, h_c - rc, n_s(1), db_s, s_s(1), 1, off = 3)
#  fila((b_f - (n_i(1) - 1)*s_i(1))/2, rc, (b_f + (n_i(1) - 1)*s_i(1))/2, rc, n_i(1), db_i, s_i(1), -1, off = 3)
#  cota(0, 0, b_f, 0, -14)
#  cota(b_f, 0, b_f, h_c, -8)
#  leyenda("Concrete f'c = 210 kg/cm²", "seccion")
#  leyenda("Bars in section", "fila")
#fin

#salto

## Annex · Syntax of the drawing primitives

#: A drawing is a block that starts with #dibujo(…) and ends with #fin; each line inside is a primitive. Numbers can be sheet names, v(i) components or expressions; in texts, braces with a name put its value. Paper units in mm (text 2.5 mm), geometry in the unit ud.
#| Primitiva | Qué dibuja |
#|---|---|
#| dibujo("título", ud = m, escala = auto o 1:50, ancho = 170, alto = 150, cotas = cm, dec = 2) | abre el lienzo; escala automática = la mayor normalizada que cabe |
#| linea(x1, y1, x2, y2, "estilo") | línea; estilos: fina, media, gruesa, eje, trazos, puntos, rojo, azul, verde, naranja, gris |
#| polilinea(xv, yv) · poligono(xv, yv, "relleno") | varios puntos (vectores o pares x, y) |
#| rect(x, y, b, h, "estilo") · circulo(xc, yc, r) · arco(xc, yc, r, a1, a2) | rectángulo (admite vectores), círculo, arco en grados |
#| texto(x, y, "texto", tamaño, "i/c/d", ángulo) | texto; admite sub/superíndice con guion bajo y circunflejo + llaves |
#| cota(x1, y1, x2, y2, d, "texto") · cotas(xv, y, d) · cotasy(yv, x, d) | cota con flechas y valor; d > 0 a la izquierda de p1→p2 |
#| ejesx(xv, "1") · ejesy(yv, "A") · ejex / ejey | ejes con burbuja, rótulos 1, 2, 3… o A, B, C… o lista entre llaves |
#| hueco(x, y, b, h) · achurado(x, y, b, h, "diagonal/cruzado/concreto") | abertura con cruz; achurado de corte |
#| varilla(x1, y1, x2, y2, Ø, g1, g2, "rótulo", lado) | varilla con ganchos 90°/135°/180° (signo = lado del gancho) |
#| varillas(x1, y1, x2, y2, n, Ø, s, g1, g2, lado) | varilla rotulada «n Ø d mm @ s cm» |
#| fila(x1, y1, x2, y2, n, Ø, s, lado) · seccion(x, y, b, h) · estribo(x, y, b, h, rec, Ø) | varillas en corte, sección de concreto, estribo con ganchos a 135° |
#| obs(n, x, y, "pendiente/corregida/info", "texto", dx = , dy = ) · leyenda("texto", "estilo") | observación numerada (x, y pueden ser vectores) y leyenda |

#: Syntax example (does NOT belong to MOD_002): a generic 30 × 50 cm beam with Ø 10 mm stirrup and 135° hooks.
#dibujo("Syntax example — beam 30 × 50", ud = cm, cotas = cm, alto = 90)
#  seccion(0, 0, 30, 50)
#  estribo(0, 0, 30, 50, 4, 10)
#  fila(5.8, 5.8, 24.2, 5.8, 3, 16, 0, -1, off = 5)
#  fila(5.7, 44.3, 24.3, 44.3, 2, 14, 0, 1, off = 5)
#  cota(0, 0, 30, 0, -8)
#  cota(0, 0, 0, 50, 5)
#fin
