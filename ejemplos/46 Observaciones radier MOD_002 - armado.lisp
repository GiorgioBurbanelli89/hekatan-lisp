# Hoja de observaciones — Radier MOD_002 (revisión del modelo SAFE)

#: Memoria de revisión con DIBUJOS: planta del radier con las observaciones numeradas sobre el plano, y el armado de una franja de diseño convertido a varillas. Todo dato sale de los archivos entregados (el .f2k corregido, la lista de cargas repetidas, el acero por franja exportado de SAFE y el informe de revisión); lo que se puede calcular, lo calcula la hoja.

## 1 · Geometría (del .f2k: GRID DEFINITIONS, FLOOR y NULL AREA OBJECT CONNECTIVITY)

#: Ejes 1–6 en X y A–C en Y, tal cual la tabla de grillas del modelo:
x_e = [0, 3.65, 7.95, 10.65, 12.2, 14.95]
y_e = [0.925, 5.225, 9.525]
#: Borde de la losa (m): de x = −0.15 a 15.075 y de y = 0.175 a 9.675.
x_0 = -0.15
x_1 = 15.075
y_0 = 0.175
y_1 = 9.675
L_x = dec(x_1 - x_0, 3)
L_y = dec(y_1 - y_0, 3)
#: Los 7 huecos (NULL AREA): esquina inferior izquierda (hx, hy), ancho hb y alto hh, en m.
hx = [1.25, 4.4, 1.25, 4.4, 8.7, 11.4, 8.7]
hy = [5.975, 5.975, 1.675, 1.675, 1.675, 1.675, 5.975]
hb = [1.65, 2.8, 1.65, 2.8, 1.2, 1.55, 2.7]
hh = [2.2, 2.2, 2.8, 2.8, 2.8, 2.8, 2.2]
A_h = dec(hb(1)*hh(1) + hb(2)*hh(2) + hb(3)*hh(3) + hb(4)*hh(4) + hb(5)*hh(5) + hb(6)*hh(6) + hb(7)*hh(7), 2)
#: Losa de 40 cm en general y de 60 cm en las tres fajas entre huecos sobre el eje B (LCIM 60cm):
zx = [2.9, 7.2, 11.4]
zb = [1.5, 1.5, 1.55]
#: Pedestales de columna (PEDESTAL, 15): esquina (px, py), lados pb × ph en m.
px = [-0.15, 3.45, 7.75, 12.05, 14.775, -0.15, 3.525, 7.75, 12.0, 14.825, -0.15, 3.525, 7.75, 10.45, 14.825]
py = [9.375, 9.375, 9.375, 9.275, 9.275, 5.075, 4.925, 5.075, 5.075, 4.925, 0.775, 0.775, 0.775, 0.775, 0.775]
pb = [0.3, 0.4, 0.4, 0.3, 0.3, 0.3, 0.25, 0.4, 0.4, 0.25, 0.3, 0.25, 0.4, 0.4, 0.25]
ph = [0.3, 0.3, 0.3, 0.4, 0.4, 0.3, 0.6, 0.3, 0.3, 0.6, 0.3, 0.6, 0.3, 0.3, 0.6]

## 2 · Observaciones sobre la planta

#: Las 22 cargas REPETIDAS por patrón (lista de cargas quitadas y conservadas; las mismas en Dead, DNE y Live), en m:
xq = [-0.15, -0.15, -0.15, -0.15, -0.15, 0, 0, 1.25, 10.65, 10.65, 12.2, 12.2, 14.95, 14.95, 15.075, 15.075, 15.075, 15.075, 15.075, 3.65, 7.95, 7.95]
yq = [0.925, 3.075, 5.225, 7.075, 9.525, 0.175, 9.675, 7.075, 0.175, 5.975, 4.475, 9.675, 0.175, 9.675, 0.925, 3.075, 5.225, 7.075, 9.525, 9.675, 0.175, 9.675]
#: Con ellas la carga de columnas del modelo recibido era 1127.8 t en vez de las 518.0 t reales (informe, §1):
f_rep = dec(1127.8/518.0, 2)
#: Presión de suelo máxima de SERVICIO del modelo corregido (SAP2000 = SAFE 20 = Hekatan a 4 cifras, informe §3a), en t/m² y en kg/cm²:
q_max = 13.48
q_kgcm = dec(q_max/10, 2)
#: Columnas con punzonamiento v_{u}/φv_{c} > 1.0 en DISEÑO (informe §4): 2-B, 2-C, 3-B y 3-C, junto a los huecos.
xp = [3.65, 3.65, 7.95, 7.95]
yp = [5.225, 9.525, 5.225, 9.525]
#dibujo("Planta del radier MOD_002 — observaciones", ud = m, cotas = m)
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
#  texto(7.5, 1.3, "franja CSA1 (b = 1.50 m)", 2.2, "c", estilo = "azul")
#  obs(1, xq, yq, "corregida", "22 cargas puntuales repetidas por patrón (copias a 15–75 cm de su columna): la carga de columnas era {f_rep} veces la real. Quitadas en el .f2k corregido (quedan 15 por patrón).")
#  obs(2, x_1, y_1, "pendiente", "Presión máxima de SERVICIO {q_max} t/m² = {q_kgcm} kg/cm² en la esquina 6-C: comparar con la capacidad admisible del estudio de suelos.", dx = 6, dy = 6)
#  obs(3, xp, yp, "pendiente", "Punzonamiento v_{u}/φv_{c} > 1.0 (DISEÑO, ACI 318-14) en 2-B, 2-C, 3-B y 3-C, junto a los huecos: subir peralte local, alejar/reducir huecos o armadura de cortante.", dx = 3.5, dy = 3.5)
#  obs(4, 5.8, 5.225, "corregida", "Peso propio en cero (Self Weight Multiplier = 0 en los 3 patrones): faltaban 142.3 t (losa + vigas). Activado en Dead.")
#  leyenda("Eje", "eje")
#  leyenda("Hueco", "hueco")
#  leyenda("Losa 60 cm", "resalte naranja")
#  leyenda("Franja CSA1", "resalte azul")
#  leyenda("Obs. pendiente", "pendiente")
#  leyenda("Obs. corregida", "corregida")
#fin

#: Área neta de losa (sin huecos), para control: la planta mide {L_x} × {L_y} m y los huecos suman {A_h} m².

#salto

## 3 · Armado de la franja CSA1 (eje A) con el acero de SAFE

#: La franja CSA1 va por el eje A (y = 0.925 m), ancho 0.75 + 0.75 = 1.50 m (STRIP OBJECT CONNECTIVITY), losa de 40 cm. SAFE da el área REQUERIDA en cada estación (Start, Middle, End) de cada tramo entre ejes; se copia en cm², tramos 1–2 a 5–6:
As_si = [4.54, 1.19, 0.12, 0.60, 16.78]
As_sc = [12.25, 4.82, 1.67, 7.01, 24.34]
As_sj = [2.83, 0.26, 0.35, 16.78, 1.70]
As_ii = [0.55, 5.13, 7.51, 4.93, 0]
As_ic = [0, 0, 2.60, 0, 0]
As_ij = [6.47, 8.62, 3.73, 0, 0.67]
#: Envolvente de cada tramo (la mayor de las tres estaciones), cara superior e inferior:
As_sup = max(As_si, As_sc, As_sj)
As_inf = max(As_ii, As_ic, As_ij)
#: Varillas INEN: Ø 16 mm arriba y Ø 14 mm abajo. Área de una varilla en cm², A_{b} = π·Ø²/4 con Ø en mm y /100 para pasar a cm²:
db_s = 16
db_i = 14
Ab_s = dec(pi*db_s^2/400, 3)
Ab_i = dec(pi*db_i^2/400, 3)
#: Número de varillas con la regla de SAFE, n = ⌈A_{s}/A_{b}⌉ (se redondea hacia ARRIBA):
n_s = ceil(As_sup/Ab_s)
n_i = ceil(As_inf/Ab_i)
#: Separación = ancho/n redondeada hacia ABAJO a múltiplo de 2.5 cm (convención de Hekatan, para que la separación de obra nunca sea mayor que la de cálculo):
b_f = 150
s_s = floor(b_f/n_s/2.5)*2.5
s_i = floor(b_f/n_i/2.5)*2.5
#: Acero colocado, que debe ser ≥ el requerido:
Asp_s = dec(n_s*Ab_s, 2)
Asp_i = dec(n_i*Ab_i, 2)
#tabla("Tramo","A_{s,sup} [cm²]:2","n sup:0","s sup [cm]:1","A_{s,inf} [cm²]:2","n inf:0","s inf [cm]:1")({"1–2","2–3","3–4","4–5","5–6"}; As_sup; n_s; s_s; As_inf; n_i; s_i)
#: Ojo: donde SAFE pide menos de una varilla (tramo 3–4 arriba, 5–6 abajo) la regla da n = 1 y s = 150 cm. Ahí mandan el acero mínimo y la separación máxima de la norma, que esta hoja todavía NO verifica.

### Elevación del armado (d = h − 7.5 cm, como el informe)

#: La franja mide 15.2 m de largo y 0.40 m de alto: a escala real la losa sería una raya, así que la elevación va con la vertical exagerada ×5 (se dice en el título). Las varillas inferiores se dibujan 10 cm más adentro solo para que su gancho no tape al de la superior.

h_l = 0.40
r_c = 0.075
#dibujo("Franja CSA1 — elevación (ancho 1.50 m, losa 40 cm)", ud = m, ancho = 180, vert = 5, cotas = m)
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
#  leyenda("Varilla (rótulo: cantidad Ø diámetro @ separación)", "varilla")
#fin

### Sección transversal del tramo 1–2

h_c = 40
rc = 7.5
#: Las varillas van centradas en el ancho: la primera a (b − (n − 1)·s)/2 del borde, con el centro a 7.5 cm de cada cara.
#dibujo("Sección de la franja CSA1, tramo 1–2", ud = cm, cotas = cm, ancho = 170)
#  seccion(0, 0, b_f, h_c)
#  fila((b_f - (n_s(1) - 1)*s_s(1))/2, h_c - rc, (b_f + (n_s(1) - 1)*s_s(1))/2, h_c - rc, n_s(1), db_s, s_s(1), 1, off = 3)
#  fila((b_f - (n_i(1) - 1)*s_i(1))/2, rc, (b_f + (n_i(1) - 1)*s_i(1))/2, rc, n_i(1), db_i, s_i(1), -1, off = 3)
#  cota(0, 0, b_f, 0, -14)
#  cota(b_f, 0, b_f, h_c, -8)
#  leyenda("Concreto f'c = 210 kg/cm²", "seccion")
#  leyenda("Varillas en corte", "fila")
#fin

#salto

## Anexo · Sintaxis de las primitivas de dibujo

#: Un dibujo es un bloque que empieza con #dibujo(…) y termina con #fin; cada línea de adentro es una primitiva. Los números pueden ser nombres de la hoja, componentes v(i) o expresiones; en los textos, llaves con un nombre ponen su valor. Unidades del papel en mm (texto 2.5 mm), geometría en la unidad ud.
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

#: Ejemplo de sintaxis (NO pertenece al MOD_002): una viga genérica de 30 × 50 cm con estribo Ø 10 mm y ganchos a 135°.
#dibujo("Ejemplo de sintaxis — viga 30 × 50", ud = cm, cotas = cm, alto = 90)
#  seccion(0, 0, 30, 50)
#  estribo(0, 0, 30, 50, 4, 10)
#  fila(5.8, 5.8, 24.2, 5.8, 3, 16, 0, -1, off = 5)
#  fila(5.7, 44.3, 24.3, 44.3, 2, 14, 0, 1, off = 5)
#  cota(0, 0, 30, 0, -8)
#  cota(0, 0, 0, 50, 5)
#fin
