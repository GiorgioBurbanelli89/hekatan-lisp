# Placa base: el método del voladizo (AISC Design Guide 1)
#modo memoria

#: Una placa base reparte la carga de la columna sobre el hormigón. Esta hoja sigue el método de la **AISC Design Guide 1, 3.ª ed. (2024), §4.3** (Kanvinde, Maamouri y Buckholt), con el aplastamiento de la **AISC 360-22, J8**. La idea es una sola: **la parte de la placa que sobresale del tubo trabaja como un VOLADIZO**. Todo lo demás es encontrar cuánto sobresale y qué presión lo carga.
#: Primero cada fórmula en letras, con su porqué; después, los números. Se trabaja en N, mm y MPa, como la guía; los resultados que se leen de memoria se pasan también a tonf y kgf/cm^{2}.

## 0 · Los datos

#| Elemento | Dato | Elemento | Dato |
#|---|---|---|---|
#| columna | HSS 300 × 300 × 8, A500 Gr C, F_{y} = 345 MPa | placa | 600 × 600 mm, A572 Gr 50, F_{y} = 345 MPa |
#| carga axial | P_{u} = 600 kN | pedestal | 800 × 800 mm, f'_{c} = 28 MPa |
#| momento en x | M_{ux} = 120 kN·m | pernos | 8 Ø 25.4 mm (1"), F1554 Gr 55 |
#| momento en y | M_{uy} = 60 kN·m | borde a perno | 80 mm (perno a 220 mm del centro) |

#: Las mismas magnitudes en las unidades de aquí:
f_ck = dec(28*10.19716, 1) [kgf/cm^2] 'hormigón ; F_yk = dec(345*10.19716, 0) [kgf/cm^2] 'acero
P_uk = dec(600/9.80665, 2) [tonf] 'axial ; M_uxk = dec(120/9.80665, 2) [tonf*m] 'momento x ; M_uyk = dec(60/9.80665, 2) [tonf*m] 'momento y

#dibujo("Planta: placa 600 × 600, tubo HSS 300 × 300 × 8 y 8 pernos Ø 25.4 mm", ud = mm, cotas = mm, escala = 1:8, ancho = 170, alto = 200)
#  rect(-400, -400, 800, 800, "trazos gris")
#  texto(-392, 380, "pedestal 800 × 800 = área A_{2}", 2.3, "i", estilo = "gris")
#  rect(142.5, -300, 157.5, 600, "resalte rojo")
#  rect(-300, 142.5, 600, 157.5, "resalte azul")
#  rect(-300, -300, 600, 600, "gruesa")
#  achurado(-150, -150, 300, 8, "diagonal")
#  achurado(-150, 142, 300, 8, "diagonal")
#  achurado(-150, -142, 8, 284, "diagonal")
#  achurado(142, -142, 8, 284, "diagonal")
#  rect(-150, -150, 300, 300, "gruesa")
#  rect(-142, -142, 284, 284, "media")
#  rect(-142.5, -142.5, 285, 285, "trazos rojo")
#  linea(-345, 0, 345, 0, "eje")
#  linea(0, -345, 0, 345, "eje")
#  circulo([-220, 0, 220, -220, 220, -220, 0, 220], [-220, -220, -220, 0, 0, 220, 220, 220], 23.8, "trazos")
#  circulo([-220, 0, 220, -220, 220, -220, 0, 220], [-220, -220, -220, 0, 0, 220, 220, 220], 12.7, "acero denso")
#  texto(262, -110, "voladizo m", 2.5, "c", 90, estilo = "rojo")
#  texto(-90, 262, "voladizo n", 2.5, "c", 0, estilo = "azul")
#  texto(0, -118, "empotramiento a 0.95·d", 2.2, "c", estilo = "rojo")
#  texto(0, -80, "tubo HSS 300 × 300 × 8", 2.2, "c")
#  circulo(200, 100, 7, "rojo denso")
#  flecha(40, 100, 190, 100, "rojo")
#  texto(0, 128, "resultante de P_{u}", 2.2, "c", estilo = "rojo")
#  texto(0, 72, "e_{x} = 200 · e_{y} = 100", 2.2, "c", estilo = "rojo")
#  texto(355, 0, "x", 2.8, "i")
#  texto(0, 358, "y", 2.8, "c")
#  cota(-300, -300, -142.5, -300, -35, "m = 157.5")
#  cota(-142.5, -300, 142.5, -300, -35, "0.95·d = 285")
#  cota(142.5, -300, 300, -300, -35, "m = 157.5")
#  cota(-300, -300, 300, -300, -65, "N = 600")
#  cota(-300, -300, -300, 300, 65, "B = 600")
#  cota(-300, 142.5, -300, 300, 35, "n = 157.5")
#  cota(0, 300, 220, 300, 28, "220")
#  cota(220, 300, 300, 300, 28, "80")
#fin
#: Lo rojo y lo azul es lo que sobresale del tubo: esas franjas son los voladizos. La línea roja a trazos es donde se empotran, a 0.95·d y no en la cara del tubo (se explica en el apartado 1). El punto rojo es por donde pasa la resultante de la carga axial con los dos momentos: no es otra carga, es la misma P_{u} dibujada donde produce los dos momentos.

## 1 · La idealización: un voladizo

#: El tubo es muchísimo más rígido que la placa. Por eso la placa, debajo del tubo, prácticamente no gira: queda como **empotrada** en el tubo. Lo que sobresale no tiene nada que la sujete por el otro extremo: el borde de la placa está libre. Empotrado de un lado y libre del otro es un **voladizo**.
#: Ese voladizo lo carga desde abajo la presión del hormigón en el lado comprimido y, si la hay, la tracción de los pernos en el otro lado.
#: **Dónde se empotra.** No en la cara del tubo sino un poco hacia adentro, a 0.95·d. En el tubo, la esquina y la soldadura dejan que la placa gire algo justo en la cara, y los ensayos (DeWolf y Ricker, 1990, que cita la guía en la p. 23) ajustan la sección crítica a ese 95 %. En tubos rectangulares se usa 0.95·d en un sentido y 0.95·b en el otro, y no se usa el término λn' de los perfiles I.
#: Así, el largo del voladizo es lo que sobra a cada lado:
m = (N - 0.95*d)/2 @@(DG1 ec. 4-10)
n = (B - 0.95*b)/2 @@(DG1 ec. 4-11)
#: Con los números (la placa y el tubo son cuadrados, así que los dos voladizos miden lo mismo):
m = dec((600 - 0.95*300)/2, 1) [mm] ; n = dec((600 - 0.95*300)/2, 1) [mm]

#: El voladizo se estudia como una **franja de 1 mm de ancho**, igual que una losa: la presión f_{p} (fuerza por área) se vuelve una carga por unidad de largo sobre esa franja, y el momento sale en N·mm por cada mm de ancho.
#dibujo("El voladizo: franja de 1 mm de ancho, empotrada en la línea 0.95·d", ud = mm, cotas = mm, ancho = 150, alto = 150)
#  empotramiento(0, -45, 0, 45, 1)
#  rect(0, -19, 157.5, 38, "gruesa")
#  achurado(0, -19, 157.5, 38, "diagonal")
#  carga(0, -19, 157.5, -19, -55, -55, "f_{p}: presión del hormigón, empuja hacia arriba", "rojo")
#  cota(0, 19, 157.5, 19, 22, "m = 157.5")
#  texto(163, 0, "borde libre", 2.4, "i")
#  texto(-8, 55, "tubo", 2.4, "d")
#  linea(0, -165, 157.5, -165, "media")
#  curva(0, 157.5, -165 - 70*((157.5 - x)/157.5)^2, "azul relleno", base = -165)
#  texto(6, -250, "M_{máx} = f_{p}·m^{2}/2 en el empotramiento", 2.4, "i", estilo = "azul")
#  texto(95, -180, "M(x) = f_{p}·(m − x)^{2}/2", 2.4, "c", estilo = "azul")
#  texto(162, -165, "M = 0 en el borde libre", 2.2, "i", estilo = "azul")
#fin
#: Arriba, la placa y la presión; abajo, el diagrama de momento, dibujado del lado traccionado. Crece con el cuadrado de la distancia al borde libre: **por eso el largo m pesa tanto**. Duplicar m cuadruplica el momento.

## 2 · Cuánto aguanta el hormigón (AISC 360-22, J8)

#: El hormigón debajo de la placa no puede apretarse sin límite. La norma da la presión máxima de aplastamiento. Si el pedestal es más grande que la placa, el hormigón de alrededor **confina** al que está debajo y aguanta más; ese beneficio va con la raíz de la relación de áreas y tiene un tope de dos veces:
f_pmax = phi_c*0.85*fprime_c*sqrt(A_2/A_1) @@(J8-2, DG1 ec. 4-1)
f_plim = phi_c*1.7*fprime_c @@(tope de J8-2)
#: A_{1} es el área de la placa y A_{2} la del pedestal, semejante y concéntrica; φ_{c} = 0.65. Multiplicada por el ancho B, la presión se vuelve fuerza por mm de largo, que es lo que usa la guía:
q_max = f_pmax*B @@(DG1 ec. 4-37)
#: Con los números:
r_A = dec(sqrt(800*800/(600*600)), 4) [-] 'raíz de A2/A1, menor que 2
f_pmax = dec(0.65*0.85*28*1.3333, 2) [MPa] ; f_plim = dec(0.65*1.7*28, 2) [MPa]
q_max = dec(20.627*600, 0) [N/mm] ; f_pmaxk = dec(20.627*10.19716, 1) [kgf/cm^2]
#: Manda 20.63 MPa (210 kgf/cm^{2}), porque no llega al tope de 30.94.

## 3 · Solo carga axial: el caso más sencillo

#: Sin momento, la presión es uniforme en toda la placa:
f_p = P_u/(B*N)
#: El momento en el empotramiento del voladizo, por mm de ancho, es el de una carga repartida en un voladizo de largo l:
M_vol = f_p*l^2/2
#: Y lo que aguanta la franja de acero de espesor t_{p} es su momento plástico, con φ_{b} = 0.90:
M_res = phi_b*F_y*t_p^2/4
#: Se iguala lo que pide con lo que aguanta y se despeja el espesor. La raíz sale de que el momento resistente va con el cuadrado del espesor:
t_p = l*sqrt(2*f_p/(phi_b*F_y))
t_p = l*sqrt(2*P_u/(phi_b*F_y*B*N)) @@(DG1 ec. 4-7a)
#: Aquí l es el mayor de m y n; en un tubo es m (o n). Con los números:
f_p = dec(600000/(600*600), 3) [MPa]
t_p = dec(157.5*sqrt(2*600000/(0.9*345*600*600)), 2) [mm] 'solo con la carga axial
#: Solo con la axial bastarían 16.3 mm. El momento es el que manda, como se ve ahora.

## 4 · Carga axial con momento (DG1 §4.3.7)

#: La guía reemplaza la presión triangular de antes por un **bloque rectangular** de presión uniforme, de largo Y, apoyado contra el borde comprimido. El momento se convierte en una excentricidad: la distancia a la que habría que poner P_{u}, ella sola, para producir el mismo momento.
e = M_u/P_u @@(DG1 ec. 4-39)
#: **Momento pequeño.** Mientras el bloque que hace falta quepa sin pasar la presión máxima, no se necesitan pernos. El bloque debe tener su centro justo debajo de la resultante; como arranca en el borde, su centro está a N/2 − Y/2 del centro de la placa, y eso tiene que ser e:
Y = N - 2*e @@(DG1 ec. 4-42)
f_p = P_u/(B*Y) @@(DG1 ec. 4-44)
#: Cuanto más grande es e, más corto el bloque y más alta la presión. El límite llega cuando la presión toca q_{max}: de ahí sale la excentricidad crítica.
e_crit = N/2 - P_u/(2*q_max) @@(DG1 ec. 4-40)
#: **Momento grande** (e mayor que e_{crit}): el bloque ya está a presión máxima y no alcanza; los pernos del otro lado tiran con T_{u}. Equilibrio de fuerzas y de momentos respecto a los pernos (a una distancia f del centro) dan:
Y = (f + N/2) - sqrt((f + N/2)^2 - 2*P_u*(e + f)/q_max) @@(DG1 ec. 4-58)
T_u = q_max*Y - P_u @@(DG1 ec. 4-55)

#: **El espesor, lado comprimido.** El voladizo de largo m recibe el bloque. Si el bloque cubre todo el voladizo (Y ≥ m) la carga es uniforme sobre m; si es más corto (Y < m), solo empuja un trozo Y, y su brazo al empotramiento es m − Y/2:
M_vol = f_p*m^2/2 @@(Y ≥ m)
M_vol = f_p*Y*(m - Y/2) @@(Y < m)
#: Igualando con el momento plástico de la franja, igual que en el apartado 3:
t_p = sqrt(4*M_vol/(phi_b*F_y))
#: Metiendo el primer caso y sacando los números de la raíz sale la forma que trae la guía; el 1.49 no sale de una tabla: es la raíz de 2/0.9, y el 2.11 la de 4/0.9:
t_p = 1.49*m*sqrt(f_p/F_y) @@(DG1 ec. 4-51a, Y ≥ m)
t_p = 2.11*sqrt(f_p*Y*(m - Y/2)/F_y) @@(DG1 ec. 4-52a, Y < m)
k_1 = dec(sqrt(2/0.9), 4) [-] ; k_2 = dec(sqrt(4/0.9), 4) [-]
#: **El espesor, lado traccionado.** Los pernos tiran de la placa con T_{u}, a una distancia x de la línea de empotramiento. El ancho que trabaja es B:
x = f - d/2 + t/2 @@(DG1 ec. 4-61)
t_p = 2.11*sqrt(T_u*x/(B*F_y)) @@(DG1 ec. 4-62a)

#: **Ahora los números.** En x, el momento mayor:
e_x = dec(120000000/600000, 1) [mm] ; e_y = dec(60000000/600000, 1) [mm]
e_crit = dec(600/2 - 600000/(2*12376), 1) [mm] 'excentricidad crítica
#: Las dos excentricidades (200 y 100 mm) quedan por debajo de 275.8 mm: **momento pequeño en los dos sentidos, los pernos no trabajan** (T_{u} = 0). En x:
Y = dec(600 - 2*200, 1) [mm] ; f_p = dec(600000/(600*200), 2) [MPa] ; f_pk = dec(5*10.19716, 1) [kgf/cm^2]
#: Y = 200 mm es mayor que m = 157.5 mm: el bloque cubre todo el voladizo, así que vale el primer caso.
M_vol = dec(5*157.5^2/2/1000, 3) [kN*m/m] 'momento en el empotramiento, por mm de ancho
t_px = dec(sqrt(4*62015.6/(0.9*345)), 2) [mm] 'espesor pedido por el eje x
t_px = dec(1.49*157.5*sqrt(5/345), 2) [mm] 'lo mismo con el 1.49 redondeado
#: (62.016 kN·m/m son 62 016 N·mm/mm, el número que entra en la raíz.)
#: En y, con la mitad de momento:
Y_y = dec(600 - 2*100, 1) [mm] ; f_py = dec(600000/(600*400), 2) [MPa]
t_py = dec(157.5*sqrt(2*2.5/(0.9*345)), 2) [mm] 'espesor pedido por el eje y

#dibujo("Corte en x: la placa como cuerpo libre (momento pequeño, e = 200 mm)", ud = mm, cotas = mm, ancho = 165, alto = 160)
#  achurado(-150, 38, 8, 190, "diagonal")
#  rect(-150, 38, 8, 190, "gruesa")
#  achurado(142, 38, 8, 190, "diagonal")
#  rect(142, 38, 8, 190, "gruesa")
#  achurado(-300, 0, 600, 38, "cruzado")
#  rect(-300, 0, 600, 38, "gruesa")
#  linea(0, -150, 0, 330, "eje")
#  flecha(0, 335, 0, 232, "rojo")
#  texto(12, 318, "P_{u} = 600 kN", 2.5, "i", estilo = "rojo")
#  flechamomento(0, 262, 58, 335, 205, "rojo")
#  texto(66, 262, "M_{ux} = 120 kN·m", 2.5, "i", estilo = "rojo")
#  carga(100, 0, 300, 0, -70, -70, "f_{p} = 5.00 MPa sobre el bloque Y", "rojo")
#  linea(142.5, -20, 142.5, 60, "trazos rojo")
#  linea(-142.5, -20, -142.5, 60, "trazos rojo")
#  rect(-232, 38, 24, 12, "media")
#  rect(208, 38, 24, 12, "media")
#  linea(-220, 50, -220, 80, "acero")
#  linea(220, 50, 220, 80, "acero")
#  texto(-220, 92, "perno: T_{u} = 0", 2.3, "c")
#  cota(142.5, 38, 300, 38, 55, "m = 157.5")
#  cota(100, -70, 300, -70, -30, "Y = N − 2e = 200")
#  cota(0, -150, 200, -150, -25, "e = 200: el centro del bloque cae bajo la resultante")
#  cota(-300, 0, -300, 38, 22, "t_{p}")
#fin
#: El centro del bloque (a 200 mm) cae exactamente debajo de la resultante: por eso Y = N − 2e. Las líneas rojas a trazos son los empotramientos del voladizo, a 0.95·d.

#: Cómo cambia el espesor pedido con la excentricidad. El eje horizontal es e en mm (sale rotulado x) y el vertical el espesor en mm. La curva «compresion» es el voladizo comprimido; «traccion», el lado de los pernos, que aparece recién pasada la excentricidad crítica. Los puntos son los dos ejes de esta placa.
#fplot(compresion = sqrt(4*((1 - (1 + sign(x - 275.76))/2)*(1000/max(600 - 2*x, 40))*min(max(600 - 2*x, 40), 157.5)*(157.5 - min(max(600 - 2*x, 40), 157.5)/2) + (1 + sign(x - 275.76))/2*20.627*min(520 - sqrt(270400 - 96.962*(x + 220)), 157.5)*(157.5 - min(520 - sqrt(270400 - 96.962*(x + 220)), 157.5)/2))/310.5), traccion = sqrt(max(4*(12376*(520 - sqrt(270400 - 96.962*(x + 220))) - 600000)*73.72/186300, 0)), eje_x = [200 28.27], eje_y = [100 19.99], e_crit = [275.76 41.43], [0 600])
#: Hasta e = 150 mm el bloque es largo y la presión baja: el espesor sube despacio. Entre 150 y 275.8 mm el bloque se acorta por debajo de m, la presión se dispara y la curva se empina. Pasada la crítica la presión ya no puede subir más (es q_{max}) y quien crece es la tracción de los pernos.

#: Si el momento fuese grande, el cuerpo libre cambia así (dibujo cualitativo, no son los números de esta placa):
#dibujo("Momento grande (e > e_crit): bloque a presión máxima y pernos traccionados", ud = mm, cotas = mm, ancho = 165, alto = 120)
#  achurado(-300, 0, 600, 38, "cruzado")
#  rect(-300, 0, 600, 38, "gruesa")
#  rect(-150, 38, 300, 60, "media")
#  linea(0, -110, 0, 150, "eje")
#  carga(210, 0, 300, 0, -80, -80, "q_{max}", "rojo", n = 5)
#  flecha(-220, 20, -220, -95, "azul")
#  texto(-212, -85, "T_{u} (pernos)", 2.4, "i", estilo = "azul")
#  linea(-142.5, -15, -142.5, 60, "trazos rojo")
#  linea(142.5, -15, 142.5, 60, "trazos rojo")
#  cota(-220, 38, -142.5, 38, 30, "x")
#  cota(210, -80, 300, -80, -45, "Y")
#  cota(-220, 150, 0, 150, 18, "f")
#  flecha(0, 150, 0, 100, "rojo")
#  texto(8, 140, "P_{u}", 2.5, "i", estilo = "rojo")
#  flechamomento(0, 120, 45, 335, 205, "rojo")
#fin
#: Del lado de los pernos el voladizo cuelga de la tracción T_{u}, con brazo x hasta su empotramiento: es el mismo voladizo, cargado al revés.

## 5 · Los dos momentos a la vez (DG1 §4.3.11)

#: La guía no suma los dos casos: usa una interacción elíptica. M_{cx} y M_{cy} son los momentos que aguanta la unión en cada eje, con la misma carga axial, revisando todos los modos (placa comprimida, placa traccionada, pernos, hormigón):
razon = (M_ux/M_cx)^2 + (M_uy/M_cy)^2 @@(DG1 ec. 4-69)
#: **Cuánto aguanta la placa elegida.** Se elige t_{p} = 38 mm. Su momento resistente por mm de ancho:
M_res = dec(0.9*345*38^2/4/1000, 3) [kN*m/m]
#: En N·mm por mm de ancho son 112 090.5, que es el número que entra abajo.
#: Con momento pequeño (sin pernos) y el bloque más corto que m, el momento del voladizo es f_{p}·Y·(m − Y/2), y como f_{p}·Y = P_{u}/B, queda (P_{u}/B)(m − Y/2). Igualándolo con M_{res} se despeja el bloque más corto que resiste; su excentricidad y el momento salen de las ecuaciones de arriba:
Y_c = 2*(m - M_res*B/P_u)
e_c = (N - Y_c)/2
M_c = P_u*e_c
#: Con los números:
Y_c = dec(2*(157.5 - 112090.5*600/600000), 2) [mm] 'más corto que el voladizo m: vale el segundo caso
e_c = dec((600 - 90.819)/2, 2) [mm] 'menor que la crítica: los pernos siguen sin trabajar
M_c = dec(600000*254.59/1000000, 2) [kN*m] 'placa comprimida: el modo que manda
#: La placa y el tubo son cuadrados, así que M_{cx} = M_{cy} = 152.75 kN·m. Los pernos no llegan a trabajar antes (T_{u} = 0 mientras e ≤ e_{crit}), así que manda la placa comprimida.
razon = dec((120/152.75)^2 + (60/152.75)^2, 3) [-] 'debe ser menor o igual que 1
#: **0.77 ≤ 1: la placa de 38 mm cumple.** El eje x solo pedía 28.3 mm; la interacción pide más porque los dos momentos se suman en la esquina.
#: Nota sobre el 0.78 de la referencia (calc_prediseno.py): allí M_{c} se busca subiendo el momento de 1 en 1 kN·m, y se queda en 152; aquí se despeja exacto, 152.75. Con 152 la razón da 0.779; es la misma cuenta.

## En una línea

#: La placa que sobresale del tubo es un voladizo empotrado a 0.95·d: con m = 157.5 mm y el bloque de presión de 5 MPa, el eje x pide 28.3 mm; la interacción de los dos momentos da 0.77 con 38 mm, así que **la placa de 600 × 600 × 38 mm cumple** y los pernos no trabajan a tracción con estas cargas (sí trabajarán a cortante y con el sismo, que no entran aquí).
