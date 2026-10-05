"""Hojas 136 (lindero), 137 (esquinera) y 138 (lindero con viga de amarre). Mismo núcleo que la 135."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from gen_hojas import (DATOS, BALASTO_CORTO, MALLA, ELEMENTO_CORTO, MUELLES, CARGAS, ENSAMBLE, iteracion,
                       RESULTADOS, comparar_struct, TRES_D, wS, h135, EJ)

GEO5_EXC = r"""
#: **Dónde queda la columna (hoja 106).** GEO5 pide a_{x}, la distancia del borde a la cara de la columna: a_{x} = 0.01 m, así que el eje está a 0.01 + 0.20 = 0.21 m del borde, a p = 0.39 m del centro. La excentricidad de GEO5 (ayuda «Stress in the Footing Bottom») suma la del axial corrido N·p:
a_x = 0.01 'del borde a la cara de la columna (GEO5) [m]
p_x = a_x + c_x/2 - l_x/2 'eje de la columna desde el centro, en x [m]
"""

MALLA_COL = r"""
#: **La columna en la malla.** Con elementos de 10 cm, la huella de la columna se pone **a ras del borde** (de −0.6 a −0.2: eje en −0.40). El centímetro que falta hasta el eje real (−0.39) no se pierde: entra como momento N·0.01 = 30 kN·m en el nudo del eje. Así la resultante es **exactamente** la de GEO5.
"""

LARGO = r"""#hide
x_0 = l_x/2
for i = 1:n_x
  q = (n_x/2)·n_n + i
  if %W%(q) < 0 && %W%(q + 1) >= 0
    x_0 = X_j(q) + h_e·%W%(q)/(%W%(q) - %W%(q + 1))
  end
end
#show
"""

# ======================================================================================== 136
H136 = r"""# Zapata de lindero por elementos finitos: suelo solo a compresión, zona levantada, contra Hekatan Struct y GEO5
#numerico

#: **Qué se calcula.** La zapata de 1.20 × 1.20 × 0.40 m del Demo01 de GEO5 con la columna **en el lindero** (a 1 cm del borde, hoja 106). La carga cae a 0.41 m del centro, fuera del tercio central: con una presión lineal, más de la mitad de la zapata tendría que «tirar» del suelo. El suelo no tira: la zapata **se levanta** por el borde opuesto y el problema deja de ser lineal.
#: **Con qué.** La placa gruesa y los muelles de área de **Hekatan Struct** (hoja 135), ahora con muelles **solo a compresión** (ley Gap de CSI) resueltos por conjunto activo. Se compara nudo a nudo con Struct (mismo .heks), con la **zapata rígida** analítica (Das, ec. 6.53: triángulo de presiones) y con el **área efectiva de Meyerhof** que usa GEO5 (franja de 0.39 m).
%%DATOS%%
%%GEO5EXC%%
e_x = (-M_y + H_x·t_z + N_1·p_x)/V_d 'excentricidad en x (GEO5: 0.339·1.2 = 0.407) [m]
e_y = (M_x + H_y·t_z)/V_d 'excentricidad en y [m]
%%BALASTO%%
%%MALLA%%
%%MALLACOL%%
%%ELEMENTO%%
%%MUELLES%%
%%CARGAS%%
%%ENSAMBLE%%

## 8 · Solución: el conjunto activo

#: Se resuelve con todos los muelles; los nudos que **suben** (w > 0) se sueltan; se vuelve a resolver; hasta que el conjunto no cambie. Es lo que hace Hekatan Struct (`muellesSoloCompresion.ts`) y, con pasos de carga, SAP2000/SAFE con el «Gap»:
%%ITER%%
n_it 'resoluciones
h_1 = h_c(1) 'nudos en contacto, 1.ª resolución
h_2 = h_c(2) 'nudos en contacto, 2.ª resolución
h_3 = h_c(3) 'nudos en contacto, 3.ª resolución
h_4 = h_c(4) 'nudos en contacto, 4.ª (la final)
n_ct = sum(a_c) 'nudos en contacto al final (de 169)
#: Struct hizo **las mismas 4 vueltas con los mismos nudos**: 169 → 117 → 91 → 78.
%%RESULTADOS%%

## 9 · Presión de contacto, zona levantada y deformada

p_max = max(p_j) 'presión máxima, en el borde del lindero [kPa]
w_min = min(w_j) 'mayor hundimiento, borde del lindero [mm]
w_max = max(w_j) 'mayor levantamiento, borde opuesto [mm]
R_s = sum(R_j) 'suma de las reacciones del suelo = V [kN]
x_R = sum(R_j.*X_j)/R_s 'resultante del suelo = e_x [m]
A_c = sum(k_n.*a_c)/k_s 'área en contacto (área de los nudos que tocan) [m2]
%%LARGO%%
a_cn = x_0 + l_x/2 'largo en contacto sobre el eje y = 0 (donde w cambia de signo) [m]
#: **Mapa de presión** (kPa): toda la carga entra por la franja del lindero; el resto de la zapata está en el aire (presión 0):
p_xy(x, y) = spline(1 + (x + l_x/2)/h_e, 1 + (y + l_y/2)/h_e, P_m)
#map(p_xy(x, y), [-0.6 0.6], [-0.6 0.6])
#: **Presión en 3D** (1 m = 10 000 kPa):
%%TRESD_P%%
#modelo3d(X_3, e_j, e_f, p_j, v_f)
#: **Deformada** (×2): la zapata gira alrededor de la franja del lindero y el borde opuesto **se levanta** más de 13 cm. Color = flecha en mm (positiva = sube):
#modelo3d(X_d, e_j, e_f, w_j, v_f, U_3, 2)
#: **Zona en contacto** (1 = toca, 0 = levantada):
#hide
C_m = zeros(n_n, n_n)
for j = 1:n_n
  for i = 1:n_n
    C_m(i, j) = a_c((j - 1)·n_n + i)
  end
end
#show
c_xy(x, y) = spline(1 + (x + l_x/2)/h_e, 1 + (y + l_y/2)/h_e, C_m)
#map(c_xy(x, y), [-0.6 0.6], [-0.6 0.6])
#hide
w_f = w_j
p_1 = p_max
a_1 = a_cn
A_1 = A_c
w_1 = w_max
n_1 = n_ct
i_1 = n_it
#show

## 10 · La zapata rígida: FEM y fórmula de Das

#: **Fórmula (Das, ec. 6.53; Tomlinson):** zapata rígida, suelo sin tracción, e > B/6. La presión es un **triángulo**: su resultante (a un tercio del largo) tiene que caer bajo la carga, a B/2 − e del borde, y su volumen tiene que valer V:
a_D = 3·(l_x/2 - abs(e_x)) 'largo en contacto, rígida [m]
q_D = 2·V_d/(3·l_y·(l_x/2 - abs(e_x))) 'presión máxima, rígida [kPa]
#: **¿Se dobla la zapata?** Su longitud elástica sobre Winkler, ℓ = (D/k_{s})^{1/4}, es mayor que el lado: es prácticamente **rígida**. Se comprueba con el mismo FEM y la placa **10 veces más rígida** (la K de la placa es proporcional a E: basta multiplicarla):
l_el = (D_0/k_s)^(1/4) 'longitud elástica [m]
%%ITERR%%
#hide
w_j = zeros(n_j, 1)
for q = 1:n_j
  w_j(q) = 1000·U(3·q - 2)
end
#show
#hide
p_r = 0
for q = 1:n_j
  p_r = max(p_r, -k_s·U(3·q - 2)·a_c(q))
end
#show
p_r 'presión máxima, placa 10 veces más rígida [kPa]
%%LARGO%%
a_r = x_0 + l_x/2 'largo en contacto, placa 10 veces más rígida [m]
#: Cambia un 0.2 %: la zapata de 40 cm **ya es rígida**. Entonces, ¿por qué el FEM no da exactamente a Das? Por la **malla**: los muelles están concentrados en nudos cada 10 cm y el borde del contacto cae entre dos nudos; eso alarga un poco el contacto (0.595 frente a 0.579 m) y baja el pico. Medido con el mismo modelo (casos.py, que es Struct a 1e-6 %) afinando la malla: presión máxima **8507 → 8693 → 8729 kPa** con elementos de 10, 5 y 2.5 cm, frente a 8728 de Das. El FEM converge a la fórmula.

## 11 · Hekatan LISP contra Hekatan Struct, nudo a nudo

#: Struct corrió el mismo modelo (`tests/zapata_fem/c2.heks`) con su código sin tocar. Sus 169 flechas (mm), guardadas aquí:
%%CMP%%
#hide
S_ct = 0
for q = 1:n_j
  S_ct = S_ct + (1 - sign(w_S(q)))/2
end
r_Sct = S_ct
S_pmax = round(-k_s·min(w_S)/1000, 2)
S_wmax = round(max(w_S), 3)
#show
%%LARGOS%%
S_a = round(x_0 + l_x/2, 4) 'largo en contacto de Struct sobre y = 0 [m]

## 12 · Resumen: Hekatan LISP (FEM) · Hekatan Struct · GEO5 / analítico

#hide
g_b = 0.386
g_s = 6545.84
g_Rd = 2698.37
g_FS = 0.41
r_p1 = round(p_1, 2)
r_a1 = round(a_1, 4)
r_A1 = round(A_1, 3)
r_w1 = round(w_1, 3)
r_pr = round(p_r, 2)
r_ar = round(a_r, 4)
r_aD = round(a_D, 4)
r_qD = round(q_D, 2)
r_d = round(Δ_c2, 6)
r_gA = round(g_b·l_y, 3)
#show
#| Magnitud | Hekatan LISP (FEM) | Hekatan Struct (FEM) | rígida (Das) | GEO5 (Meyerhof) |
#|---|---:|---:|---:|---:|
#| nudos en contacto (de 169) / resoluciones | @{n_1} / @{i_1} | @{r_Sct} / 4 | | |
#| largo en contacto sobre y = 0 [m] | @{r_a1} | @{S_a} | @{r_aD} (FEM, E × 10: @{r_ar}) | ancho efectivo @{g_b} |
#| área en contacto [m²] | @{r_A1} | | | @{r_gA} |
#| presión máxima [kPa] | @{r_p1} | @{S_pmax} | @{r_qD} (FEM, E × 10: @{r_pr}) | @{g_s} (uniforme) |
#| levantamiento del borde opuesto [mm] | @{r_w1} | @{S_wmax} | | |
#| peor nudo LISP − Struct [% del máx.] | @{r_d} | — | | |
#: **Por qué FEM y Meyerhof difieren.** Las tres respuestas tienen **la misma resultante** (V = 3033.7 kN a 0.407 m del centro) y reparten distinto:
#: · **Meyerhof (GEO5):** rectángulo uniforme de ancho B − 2e = 0.386 m centrado en la resultante. No es la presión real: es la convención para la **capacidad portante** (σ = 6546 kPa contra R_{d} = 2698 kPa → FS = 0.41).
#: · **Rígida (Das):** triángulo de largo 3(B/2 − e) = 0.58 m y pico 2V/(3·L·(B/2 − e)) ≈ 8730 kPa: el doble de la media, porque un triángulo tiene su máximo al doble de su promedio.
#: · **Placa sobre Winkler (FEM):** la zapata es casi rígida (ℓ = 1.26 m > 1.20 m), así que el FEM da el triángulo de Das, discretizado en nudos de 10 cm (−2.5 % en el pico; converge al afinar). Es la presión **de servicio**, la que sirve para armar la zapata.
#: La franja de Meyerhof es más estrecha que el triángulo (0.39 frente a 0.58 m) porque está hecha para que un bloque uniforme tenga la misma resultante, no para parecerse a la presión.

## 13 · NEC-SE-GC 2015

#: · **Tabla 6, §6.2 (p. 42):** FS ≥ 3.0 (CM + CV normal). GEO5 da FS = 0.41: **no cumple**, ni de lejos.
#: · **Tabla 5, §5.2 (p. 36-38):** e/B ≤ 1/6 (la tabla es de muros; usarla en zapatas es criterio nuestro). Aquí e/B = 0.339: fuera del núcleo central, que es justo lo que este FEM enseña: **la mitad de la zapata en el aire** y el borde levantado más de 13 cm. Un resultado así no se «diseña»: hay que cambiar el sistema. La solución es la **viga de amarre** (hoja 138).
e_B = abs(e_x)/l_x 'excentricidad relativa (NEC: ≤ 0.167)
"""

# ======================================================================================== 137
H137 = r"""# Zapata esquinera por elementos finitos: levantamiento en dos direcciones, contra Hekatan Struct y GEO5
#numerico

#: **Qué se calcula.** La zapata del Demo01 de GEO5 con la columna **en la esquina** (a 1 cm de dos bordes, hoja 106). La resultante cae a 0.41 m del centro en x y a 0.39 m en y: casi en la esquina. Con suelo que no tira, solo una **esquina** de la zapata queda apoyada.
#: **Con qué.** La placa gruesa y los muelles solo a compresión de **Hekatan Struct** (hojas 135 y 136), nudo a nudo contra Struct; la zapata rígida (pirámide de presiones, fórmula cerrada) y el **área efectiva** de GEO5 (0.39 × 0.43 m).
%%DATOS%%
%%GEO5EXC%%
p_y = a_x + c_x/2 - l_y/2 'eje de la columna desde el centro, en y [m]
e_x = (-M_y + H_x·t_z + N_1·p_x)/V_d 'excentricidad en x (GEO5: 0.339·1.2) [m]
e_y = (M_x + H_y·t_z + N_1·p_y)/V_d 'excentricidad en y (GEO5: 0.321·1.2) [m]
%%BALASTO%%
%%MALLA%%
%%MALLACOL%%
#: Lo mismo en y: huella de −0.6 a −0.2, y el centímetro como momento.
%%ELEMENTO%%
%%MUELLES%%
%%CARGAS%%
%%ENSAMBLE%%

## 8 · Solución: el conjunto activo

%%ITER%%
n_it 'resoluciones (Struct: 6)
h_1 = h_c(1) 'contacto en la 1.ª resolución
h_2 = h_c(2) 'en la 2.ª
h_3 = h_c(3) 'en la 3.ª
h_4 = h_c(4) 'en la 4.ª
h_5 = h_c(5) 'en la 5.ª
h_6 = h_c(6) 'en la 6.ª (final)
n_ct = sum(a_c) 'nudos en contacto al final (de 169)
#: Struct: 169 → 120 → 83 → 60 → 48 → 43. **Las mismas 6 vueltas.**
%%RESULTADOS%%

## 9 · Presión de contacto, zona levantada y deformada

p_max = max(p_j) 'presión máxima, en la esquina de la columna [kPa]
w_min = min(w_j) 'mayor hundimiento [mm]
w_max = max(w_j) 'mayor levantamiento, esquina opuesta [mm]
R_s = sum(R_j) 'suma de las reacciones = V [kN]
x_R = sum(R_j.*X_j)/R_s 'resultante del suelo en x = e_x [m]
y_R = sum(R_j.*Y_j)/R_s 'resultante del suelo en y = e_y [m]
A_c = sum(k_n.*a_c)/k_s 'área en contacto (área de los nudos que tocan) [m2]
#: **Mapa de presión** (kPa):
p_xy(x, y) = spline(1 + (x + l_x/2)/h_e, 1 + (y + l_y/2)/h_e, P_m)
#map(p_xy(x, y), [-0.6 0.6], [-0.6 0.6])
#: **Presión en 3D** (1 m = 20 000 kPa): un «pico» en la esquina:
%%TRESD_P%%
#modelo3d(X_3, e_j, e_f, p_j, v_f)
#: **Deformada** (×1): la zapata pivota sobre la esquina y la opuesta sube **más de 70 cm** con un suelo elástico lineal. Ese número no es real (antes rompe el suelo y vuelca la zapata), pero dice lo que hay que decir: así no se puede construir.
#modelo3d(X_d, e_j, e_f, w_j, v_f, U_3, 1)
#hide
C_m = zeros(n_n, n_n)
for j = 1:n_n
  for i = 1:n_n
    C_m(i, j) = a_c((j - 1)·n_n + i)
  end
end
#show
#: **Zona en contacto** (1 = toca, 0 = levantada): un triángulo/cuadrante en la esquina:
c_xy(x, y) = spline(1 + (x + l_x/2)/h_e, 1 + (y + l_y/2)/h_e, C_m)
#map(c_xy(x, y), [-0.6 0.6], [-0.6 0.6])
#hide
w_f = w_j
p_1 = p_max
A_1 = A_c
w_1 = w_max
n_1 = n_ct
i_1 = n_it
#show

## 10 · La zapata rígida: la pirámide de presiones

#: **Fórmula.** Si la zapata es rígida, la presión es un plano que se anula en una recta. Cuando esa recta corta los dos bordes, el contacto es un **triángulo** con el ángulo recto en la esquina cargada, de catetos a y b, y la presión es una **pirámide** (un tetraedro) de altura q. Dos condiciones: (1) el centro de gravedad de un tetraedro está a 1/4 de sus aristas: la resultante cae a a/4 y b/4 de la esquina; (2) su volumen es q·(a·b/2)/3 = V:
d_x = l_x/2 - abs(e_x) 'de la esquina a la resultante, en x [m]
d_y = l_y/2 - abs(e_y) 'de la esquina a la resultante, en y [m]
a_P = 4·d_x 'cateto del contacto en x (menor que 1.2: el triángulo cabe) [m]
b_P = 4·d_y 'cateto del contacto en y [m]
A_P = a_P·b_P/2 'área en contacto, rígida [m2]
q_P = 6·V_d/(a_P·b_P) 'presión en la esquina, rígida [kPa]
#: **¿Es rígida esta zapata?** Mismo FEM con la placa 10 veces más rígida:
%%ITERR%%
#hide
p_r = 0
for q = 1:n_j
  p_r = max(p_r, -k_s·U(3·q - 2)·a_c(q))
end
#show
p_r 'presión máxima, placa 10 veces más rígida [kPa]
n_r = sum(a_c) 'nudos en contacto, placa 10 veces más rígida
#: Casi igual: es rígida. La diferencia con la pirámide (26 303 frente a 27 486 kPa) es la **malla** (muelles concentrados en nudos de 10 cm; el pico de una pirámide es justo lo que peor se discretiza). Medido con el mismo modelo afinando la malla: **26 303 → 27 173 → 27 406 kPa** con elementos de 10, 5 y 2.5 cm: converge a la fórmula.

## 11 · Hekatan LISP contra Hekatan Struct, nudo a nudo

#: Struct corrió el mismo modelo (`tests/zapata_fem/c3.heks`). Sus 169 flechas (mm):
%%CMP%%
#hide
S_ct = 0
for q = 1:n_j
  S_ct = S_ct + (1 - sign(w_S(q)))/2
end
r_Sct = S_ct
S_pmax = round(-k_s·min(w_S)/1000, 2)
S_wmax = round(max(w_S), 3)
#show

## 12 · Resumen: Hekatan LISP (FEM) · Hekatan Struct · GEO5 / analítico

#hide
g_bx = 0.386
g_by = 0.429
g_s = 18324.06
g_Rd = 3302.21
g_FS = 0.18
r_p1 = round(p_1, 2)
r_A1 = round(A_1, 3)
r_w1 = round(w_1, 2)
r_pr = round(p_r, 2)
r_AP = round(A_P, 4)
r_aP = round(a_P, 3)
r_bP = round(b_P, 3)
r_qP = round(q_P, 1)
r_d = round(Δ_c3, 6)
r_gA = round(g_bx·g_by, 4)
r_xR = round(x_R, 4)
r_yR = round(y_R, 4)
r_ex = round(e_x, 4)
r_ey = round(e_y, 4)
#show
#| Magnitud | Hekatan LISP (FEM) | Hekatan Struct (FEM) | rígida (pirámide) | GEO5 (Meyerhof) |
#|---|---:|---:|---:|---:|
#| nudos en contacto (de 169) / resoluciones | @{n_1} / @{i_1} | @{r_Sct} / 6 | (FEM, E × 10: @{n_r}) | |
#| área en contacto [m²] | @{r_A1} | | @{r_AP} (triángulo @{r_aP} × @{r_bP} / 2) | @{r_gA} (0.386 × 0.429) |
#| presión máxima [kPa] | @{r_p1} | @{S_pmax} | @{r_qP} (FEM, E × 10: @{r_pr}) | @{g_s} (uniforme) |
#| resultante del suelo (x; y) [m] | @{r_xR}; @{r_yR} | | | e = @{r_ex}; @{r_ey} |
#| levantamiento de la esquina opuesta [mm] | @{r_w1} | @{S_wmax} | | |
#| peor nudo LISP − Struct [% del máx.] | @{r_d} | — | | |
#: **Por qué FEM y Meyerhof difieren.** Igual que en la hoja 136, las dos tienen la misma resultante (comprobado en la tabla) y reparten distinto. Meyerhof pone un rectángulo **uniforme** de 0.386 × 0.429 m centrado en la resultante (18 324 kPa): convención para la capacidad portante. La zapata real, rígida sobre un suelo elástico sin tracción, apoya un **triángulo** el doble de grande (0.33 m²) con una **pirámide** de presiones: el pico (≈ 27 500 kPa) es el triple de la media del triángulo. El FEM lo reproduce y, de paso, enseña lo que Meyerhof no dice: la esquina opuesta se levanta.

## 13 · NEC-SE-GC 2015

#: · **Tabla 6, §6.2 (p. 42):** FS ≥ 3.0 → GEO5 da 0.18: **no cumple**.
#: · **Tabla 5, §5.2 (criterio nuestro para zapatas):** e/B ≤ 1/6 en cada dirección; aquí 0.34 y 0.32.
#: · Lo que añade el FEM: solo ≈ 1/10 de la planta toca el suelo y la esquina opuesta se levanta decenas de cm. La esquinera **necesita vigas de amarre en las dos direcciones** (la hoja 138 lo hace para una).
e_Bx = abs(e_x)/l_x 'excentricidad relativa en x
e_By = abs(e_y)/l_y 'excentricidad relativa en y
"""

# ======================================================================================== 138
H138 = r"""# Zapata de lindero con viga de amarre por elementos finitos: momento de la viga, presión y FS, contra Hekatan Struct y GEO5
#numerico

#: **Qué se calcula.** La zapata de lindero de la hoja 136 (columna a 1 cm del borde) ahora **amarrada** a la columna interior con una viga. La hoja 106 lo explicó como una palanca rígida (FS de 0.41 a 1.53, con L_{v} = 5 m supuesto). Aquí lo hace el elemento finito: placa gruesa sobre muelles solo a compresión (hojas 135-136) + una **barra a flexión** unida al nudo de la columna.
#: **Modelo de la viga y de la zapata interior (supuestos, no vienen del Demo01):** viga de 0.40 × 0.90 m de hormigón C20/25, de la columna de lindero (x = −0.40) a la interior (x = 4.60, L_{v} = 5 m); la zapata interior es igual a la céntrica (1.20 × 1.20, misma carga 3033.7 kN) y se modela como un muelle vertical k_{s}·A con el giro libre. La viga trabaja como la de Struct: Timoshenko con área de cortante 5/6·A.
%%DATOS%%
%%GEO5EXC%%
e_x = (-M_y + H_x·t_z + N_1·p_x)/V_d 'excentricidad sin viga (hoja 136) [m]
e_y = (M_x + H_y·t_z)/V_d 'excentricidad en y [m]
%%BALASTO%%
%%MALLA%%
%%MALLACOL%%
%%ELEMENTO%%
%%MUELLES%%
%%CARGAS%%
%%ENSAMBLE%%

## 8 · La viga de amarre y la zapata interior

b_v = 0.4 'ancho de la viga [m]
h_v = 0.9 'canto de la viga [m]
L_v = 5 'de la columna de lindero a la interior [m]
A_v = b_v·h_v 'área [m2]
I_v = b_v·h_v^3/12 'inercia a flexión vertical [m4]
J_v = 0.013845 'constante de torsión del rectángulo 0.40 × 0.90 [m4]
G_c = E_c/(2·(1 + ν)) 'módulo de cortante [kPa]
φ_v = 12·E_c·I_v/(G_c·5/6·A_v·L_v^2) 'parámetro de Timoshenko (cortante de la viga)
c_v = E_c·I_v/(L_v^3·(1 + φ_v)) 'factor común [kN/m]
#: **Rigidez de la viga** en los gdl [w, θ_{x}, θ_{y}] de sus dos nudos. A lo largo de x, la pendiente de la flecha es dw/dx = −θ_{y} (mano derecha): por eso los términos que cruzan w con θ_{y} cambian de signo respecto al libro. La torsión (G·J/L) va en θ_{x}:
K_f = c_v·[12, 0, -6·L_v, -12, 0, -6·L_v; 0, 0, 0, 0, 0, 0; -6·L_v, 0, (4 + φ_v)·L_v^2, 6·L_v, 0, (2 - φ_v)·L_v^2; -12, 0, 6·L_v, 12, 0, 6·L_v; 0, 0, 0, 0, 0, 0; -6·L_v, 0, (2 - φ_v)·L_v^2, 6·L_v, 0, (4 + φ_v)·L_v^2]
t_v = G_c·J_v/L_v 'rigidez a torsión [kN·m/rad]
K_T = t_v·[0, 0, 0, 0, 0, 0; 0, 1, 0, 0, -1, 0; 0, 0, 0, 0, 0, 0; 0, 0, 0, 0, 0, 0; 0, -1, 0, 0, 1, 0; 0, 0, 0, 0, 0, 0]
K_v = K_f + K_T 'rigidez de la viga [kN/m, kN·m/rad]
n_k = n_j + 1 'nudo de la columna interior
K_i = k_s·l_x·l_y 'muelle de la zapata interior [kN/m]
P_i = V_d 'carga de la columna interior + su peso [kN]
g_v = [3·n_c - 2, 3·n_c - 1, 3·n_c, 3·n_k - 2, 3·n_k - 1, 3·n_k] 'gdl de la viga
#: Se suman a la K de la placa: la viga en los gdl de sus dos nudos, el muelle de la zapata interior en su w, y la carga interior en F:
#hide
K(g_v, g_v) = K(g_v, g_v) + K_v
K(3·n_k - 2, 3·n_k - 2) = K(3·n_k - 2, 3·n_k - 2) + K_i
F(3·n_k - 2) = F(3·n_k - 2) - P_i
#show

## 9 · Solución: el conjunto activo

%%ITER%%
n_it 'resoluciones
n_ct = sum(a_c) 'nudos en contacto (de 169)
#: **Con la viga no se levanta ningún nudo**: toda la zapata vuelve a apoyar (sin viga, hoja 136: 78 de 169).
%%RESULTADOS%%

## 10 · Lo que toma la viga

#hide
u_v = zeros(6, 1)
for i = 1:6
  u_v(i) = U(g_v(i))
end
#show
f_v = round(K_v·u_v·10)/10 'fuerzas en los extremos de la viga, f = K·u [kN, kN·m]
P_v = f_v(1) 'fuerza hacia abajo que la viga pone sobre la zapata de lindero [kN]
M_v = f_v(3) 'momento de la viga en la columna de lindero [kN·m]
#: La viga **empuja hacia abajo** la zapata de lindero con P_{v} (y tira hacia arriba de la interior con lo mismo) y le aplica un momento que la **endereza**: es la palanca. La palanca rígida de la hoja 106 da ΔP = N·e₀/(L_{v} − e₀):
Δ_P = N_1·abs(p_x)/(L_v - abs(p_x)) 'lo que la palanca rígida le pasa a la zapata de lindero [kN]
M_0 = N_1·abs(p_x) 'momento que crea la columna corrida, N·e₀ (hoja 106) [kN·m]
r_M = abs(M_v)/M_0 'fracción de N·e₀ que toma la viga
w_c = 1000·U(3·n_c - 2) 'asiento de la columna de lindero [mm]
w_k = 1000·U(3·n_k - 2) 'asiento de la columna interior [mm]
β_v = abs(w_c - w_k)/L_v 'distorsión angular entre columnas [‰]
θ_c = 1000·U(3·n_c) 'giro de la zapata de lindero alrededor de y [‰]
#: **Diagrama de momentos de la viga**: lineal, de M_{v} en la columna de lindero a 0 en la interior (giro libre allí, y la viga no lleva carga en el vano):
m_1 = -abs(M_v)/1000 'ordenada del dibujo (1 m = 1000 kN·m)
#dibujo("Viga de amarre: diagrama de momentos (1 m = 1000 kN·m)", ud = m, escala = auto, alto = 90)
#  linea(0, 0, 5, 0, "gruesa")
#  linea(0, m_1, 5, 0, "gruesa rojo")
#  linea(0, 0, 0, m_1, "media rojo")
#  texto(0.1, m_1 - 0.15, "M en la columna de lindero", 2.6, "i")
#  texto(5, 0.15, "columna interior (M = 0)", 2.6, "d")
#fin

## 11 · Presión de contacto y deformada

p_max = max(p_j) 'presión máxima [kPa]
p_min = min(p_j) 'presión mínima [kPa]
R_s = sum(R_j) 'reacción del suelo bajo la zapata de lindero [kN]
x_R = sum(R_j.*X_j)/R_s 'resultante del suelo desde el centro [m]
R_1 = N_1·L_v/(L_v - abs(p_x)) + G_z + Z_r 'palanca rígida de la hoja 106 [kN]
#: El FEM y la palanca rígida dan casi la **misma reacción** (la viga carga la zapata de lindero con más de lo que baja por su columna) y la resultante vuelve **cerca del centro**.
p_xy(x, y) = spline(1 + (x + l_x/2)/h_e, 1 + (y + l_y/2)/h_e, P_m)
#map(p_xy(x, y), [-0.6 0.6], [-0.6 0.6])
%%TRESD_P%%
#modelo3d(X_3, e_j, e_f, p_j, v_f)
#: **Deformada** (×10): la zapata ya no gira; baja casi entera:
#modelo3d(X_d, e_j, e_f, w_j, v_f, U_3, 10)

## 12 · Capacidad portante con viga (método de GEO5, hoja 106)

#: Con la resultante del FEM se aplica lo mismo que GEO5: ancho efectivo B − 2e, Brinch-Hansen con φ_{d} = 40.21° y γ₂ = 18.95 (dato de GEO5, hoja 104):
φ_d = 40.21 'φ homogeneizado, del informe de GEO5 [grados]
c_d = 5 'cohesión [kPa]
γ_2 = 18.95 'γ bajo el fondo, de GEO5 [kN/m3]
f_d = φ_d·pi/180 'en radianes
q_0 = γ_1·d_f 'sobrecarga al nivel del fondo [kPa]
N_q = tan(pi/4 + f_d/2)^2·exp(pi·tan(f_d)) 'factor de sobrecarga
N_cc = (N_q - 1)/tan(f_d) 'factor de cohesión
N_γ = 1.5·(N_q - 1)·tan(f_d) 'factor de peso propio
H_r = sqrt(H_x^2 + H_y^2) 'horizontal [kN]
b_v2 = l_x - 2·abs(x_R) 'ancho efectivo con la resultante del FEM [m]
σ_v = R_s/(b_v2·l_y) 'presión de Meyerhof [kPa]
R_dv = (c_d·N_cc·(1 + 0.2·b_v2/l_y)·(1 + 0.1·sqrt(d_f/b_v2)) + q_0·N_q·(1 + b_v2/l_y·sin(f_d))·(1 + 0.1·sqrt(d_f/b_v2·sin(2·f_d))) + b_v2/2·γ_2·N_γ·(1 - 0.3·b_v2/l_y))·(1 - H_r/R_s)^2 'capacidad portante [kPa]
FS_v = R_dv/σ_v 'factor de seguridad con viga (FEM)

## 13 · Sensibilidad: una viga más débil (0.30 × 0.60 m)

#hide
h_w = 0.6
b_w = 0.3
I_w = b_w·h_w^3/12
A_w = b_w·h_w
φ_w = 12·E_c·I_w/(G_c·5/6·A_w·L_v^2)
c_w = E_c·I_w/(L_v^3·(1 + φ_w))
K_w = c_w·[12, 0, -6·L_v, -12, 0, -6·L_v; 0, 0, 0, 0, 0, 0; -6·L_v, 0, (4 + φ_w)·L_v^2, 6·L_v, 0, (2 - φ_w)·L_v^2; -12, 0, 6·L_v, 12, 0, 6·L_v; 0, 0, 0, 0, 0, 0; -6·L_v, 0, (2 - φ_w)·L_v^2, 6·L_v, 0, (4 + φ_w)·L_v^2] + G_c·0.0037/L_v·[0, 0, 0, 0, 0, 0; 0, 1, 0, 0, -1, 0; 0, 0, 0, 0, 0, 0; 0, 0, 0, 0, 0, 0; 0, -1, 0, 0, 1, 0; 0, 0, 0, 0, 0, 0]
K_9 = K
K_9(g_v, g_v) = K_9(g_v, g_v) - K_v + K_w
%%ITERW%%
u_w = zeros(6, 1)
for i = 1:6
  u_w(i) = U(g_v(i))
end
f_w = round(K_w·u_w·10)/10
R_w = 0
x_w = 0
for q = 1:n_j
  R_w = R_w + (-k_s·U(3·q - 2)·a_c(q))·k_n(q)/k_s
  x_w = x_w + (-k_s·U(3·q - 2)·a_c(q))·k_n(q)/k_s·X_j(q)
end
x_w = x_w/R_w
n_w = sum(a_c)
b_w2 = l_x - 2·abs(x_w)
R_dw = (c_d·N_cc·(1 + 0.2·b_w2/l_y)·(1 + 0.1·sqrt(d_f/b_w2)) + q_0·N_q·(1 + b_w2/l_y·sin(f_d))·(1 + 0.1·sqrt(d_f/b_w2·sin(2·f_d))) + b_w2/2·γ_2·N_γ·(1 - 0.3·b_w2/l_y))·(1 - H_r/R_w)^2
FS_w = R_dw/(R_w/(b_w2·l_y))
r_Mw = round(abs(f_w(3)), 1)
r_nw = n_w
r_xw = round(x_w, 4)
r_FSw = round(FS_w, 2)
#show
#| Viga | momento en la columna [kN·m] | nudos en contacto | resultante x_{R} [m] | FS (GEO5 con la x_{R} del FEM) |
#|---|---:|---:|---:|---:|
#| sin viga (hoja 136) | — | 78 | −0.4069 | 0.41 |
#| 0.30 × 0.60 m | @{r_Mw} | @{r_nw} | @{r_xw} | @{r_FSw} |
#| **0.40 × 0.90 m** | **@{r_Mv}** | **@{n_ct}** | **@{r_xR}** | **@{r_FSv}** |
#: Una viga más flexible deja girar algo la zapata: la resultante se aleja del centro y el FS baja. La viga **tiene que ser rígida** frente a la zapata (aquí 3EI/L ≫ k_{s}·I de la zapata).

## 14 · Hekatan LISP contra Hekatan Struct, nudo a nudo

#: Struct corrió el mismo modelo (`tests/zapata_fem/c4.heks`: 169 nudos de la placa + el de la columna interior, la barra `frame` 0.40 × 0.90 y el `spring` de la zapata interior). Sus 170 flechas (mm):
#hide
w_k1 = zeros(n_k, 1)
for q = 1:n_k
  w_k1(q) = 1000·U_v(3·q - 2)
end
#show
%%CMP%%

## 15 · Resumen: Hekatan LISP (FEM) · Hekatan Struct · GEO5 / analítico

#hide
S_pmax = round(-k_s·min(w_S(1:169))/1000, 2)
S_wc = round(w_S(n_c), 3)
S_wk = round(w_S(n_k), 3)
r_pmax = round(p_max, 2)
r_pmin = round(p_min, 2)
r_Rs = round(R_s, 1)
r_R1 = round(R_1, 1)
r_xR = round(x_R, 4)
r_Mv = round(abs(M_v), 1)
r_M0 = round(M_0, 0)
r_FSv = round(FS_v, 2)
r_wc = round(w_c, 3)
r_wk = round(w_k, 3)
r_bv = round(β_v, 3)
r_d = round(Δ_c4, 6)
#show
#| Magnitud | Hekatan LISP (FEM) | Hekatan Struct (FEM) | analítico (hoja 106) / GEO5 |
#|---|---:|---:|---:|
#| nudos en contacto (de 169) | @{n_ct} | 169 | sin viga: 78 |
#| reacción del suelo bajo la zapata de lindero [kN] | @{r_Rs} | | palanca rígida @{r_R1} |
#| resultante desde el centro [m] | @{r_xR} | | sin viga −0.4069 |
#| presión máxima / mínima [kPa] | @{r_pmax} / @{r_pmin} | @{S_pmax} | sin viga (GEO5) 6545.84 |
#| momento de la viga en la columna [kN·m] | @{r_Mv} | | N·e₀ = @{r_M0} |
#| asiento columna de lindero / interior [mm] | @{r_wc} / @{r_wk} | @{S_wc} / @{S_wk} | |
#| FS a capacidad portante | @{r_FSv} | | palanca rígida 1.53 · sin viga 0.41 |
#| peor nudo LISP − Struct [% del máx.] | @{r_d} | — | |
#: **Por qué el FEM y la palanca de la hoja 106 casi coinciden:** la viga de 0.90 m es mucho más rígida que el giro de la zapata sobre el suelo, así que se comporta como la palanca rígida del libro. El FEM añade lo que la palanca no da: la presión real (un trapecio casi uniforme, ya sin zona levantada), el momento con el que se arma la viga y lo que pasa si la viga es más débil (sección 13).

## 16 · NEC-SE-GC 2015

#: · **Tabla 6, §6.2 (p. 42):** FS ≥ 3.0. Con viga el FS sube a ≈ 1.5: mejora mucho, pero **sigue sin cumplir** (lo mismo que la céntrica, hoja 135): la zapata de 1.20 m es pequeña para 3000 kN. Hay que agrandarla además de amarrarla.
#: · **Tabla 7 (p. 44):** distorsión angular entre columnas ≤ L/300 (pórticos de hormigón):
β_lim = 1/300 'límite NEC
#: β = |w_{lindero} − w_{interior}|/L_{v}: @{r_bv} ‰ frente a 3.33 ‰. Cumple.
"""

def comun(s, cargas_mom, nnudos="n_j"):
    rep = {"%%DATOS%%": DATOS, "%%GEO5EXC%%": GEO5_EXC, "%%BALASTO%%": BALASTO_CORTO, "%%MALLA%%": MALLA,
           "%%MALLACOL%%": MALLA_COL, "%%ELEMENTO%%": ELEMENTO_CORTO, "%%MUELLES%%": MUELLES,
           "%%CARGAS%%": CARGAS.replace("%%MOMENTOS%%", cargas_mom).replace("%%NNUDOS%%", nnudos),
           "%%ENSAMBLE%%": ENSAMBLE, "%%RESULTADOS%%": RESULTADOS}
    for k, v in rep.items(): s = s.replace(k, v)
    return s

MOM_L = r"""x_c = -0.4 'eje de la huella en la malla (a ras del borde) [m]
y_c = 0 'eje de la columna en y [m]
#: Momento que falta en el nudo del eje (mano derecha: M_{Y} = e_{x}·V, M_{X} = −e_{y}·V), descontado lo que ya pone la columna en su huella:
M_Xn = -e_y·V_d 'momento alrededor de x [kN·m]
M_Yn = e_x·V_d - N_1·x_c 'momento alrededor de y: el de la carga + el centímetro [kN·m]"""

MOM_E = r"""x_c = -0.4 'eje de la huella en x (a ras del borde) [m]
y_c = -0.4 'eje de la huella en y [m]
M_Xn = -e_y·V_d + N_1·y_c 'momento alrededor de x [kN·m]
M_Yn = e_x·V_d - N_1·x_c 'momento alrededor de y [kN·m]"""

def h136():
    s = comun(H136, MOM_L)
    s = s.replace("%%ITER%%", iteracion()).replace("%%ITERR%%", iteracion("10·K"))
    s = s.replace("%%TRESD_P%%", TRES_D.replace("%ESC%", "10000"))
    s = s.replace("%%LARGOS%%", LARGO.replace("%W%", "w_S")).replace("%%LARGO%%", LARGO.replace("%W%", "w_j"))
    s = s.replace("%%CMP%%", comparar_struct("c2", wS(2), w="w_f"))
    return s

def h137():
    s = comun(H137, MOM_E)
    s = s.replace("%%ITER%%", iteracion()).replace("%%ITERR%%", iteracion("10·K"))
    s = s.replace("%%TRESD_P%%", TRES_D.replace("%ESC%", "20000"))
    s = s.replace("%%CMP%%", comparar_struct("c3", wS(3), w="w_f"))
    return s

def h138():
    s = comun(H138, MOM_L, nnudos="(n_j + 1)")
    s = s.replace("%%ITER%%", iteracion() + "#hide\nU_v = U\n#show\n").replace("%%ITERW%%", iteracion("K_9") + "#hide\n")
    s = s.replace("%%TRESD_P%%", TRES_D.replace("%ESC%", "5000"))
    s = s.replace("%%CMP%%", comparar_struct("c4", wS(4), nj="n_k", w="w_k1"))
    return s

HOJAS = {
    "136 Zapata de lindero por elementos finitos - suelo solo a compresion y zona levantada contra Hekatan Struct y GEO5.lisp": h136,
    "137 Zapata esquinera por elementos finitos - levantamiento en dos direcciones contra Hekatan Struct y GEO5.lisp": h137,
    "138 Zapata de lindero con viga de amarre por elementos finitos - momento de la viga, presion y FS contra Struct y GEO5.lisp": h138,
}

if __name__ == "__main__":
    destino = sys.argv[1] if len(sys.argv) > 1 else EJ
    solo = sys.argv[2:] if len(sys.argv) > 2 else None
    for nom, f in HOJAS.items():
        if solo and nom[:3] not in solo: continue
        open(os.path.join(destino, nom), "w", encoding="utf-8").write(f())
        print("escrita", nom)
