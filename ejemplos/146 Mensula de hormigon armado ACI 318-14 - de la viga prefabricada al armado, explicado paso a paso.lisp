# Ménsula de hormigón armado (ACI 318-14, sección 16.5): de la viga prefabricada al armado
#numerico

#: **Para quién es esta hoja.** Para quien diseña una ménsula por primera vez. Cada paso dice **qué** se calcula, **por qué** y **de dónde** sale la fórmula. Si cambias un dato (la luz de la viga, las cargas, f'c), toda la hoja se recalcula.
#: **Qué es una ménsula.** Es un voladizo muy corto que sale de una columna y sirve de asiento a una viga prefabricada. Es tan corta que la carga cae casi **pegada a la columna**: la distancia de la carga a la cara de la columna (a_{v}) es menor que el peralte (d). Por eso **no se diseña como una viga**: no trabaja a flexión «larga», sino como una **biela de compresión** (el hormigón que empuja en diagonal) amarrada por un **tirante** (el acero de arriba que tira).
#: **El ejemplo.** Apuntes de Hormigón Armado III (Ing. Stalin Alcívar Moreira), unidad 1: una ménsula en una columna de 35 × 35 cm que apoya vigas prefabricadas de 15 m de luz, con f'c = 350 kgf/cm² y Fy = 4200 kgf/cm². Los números de los apuntes se reproducen aquí paso a paso (y se agrega la verificación del aplastamiento de la placa, que los apuntes dejan pendiente).
#: **Unidades.** kgf, cm y kgf/cm², como se usan en Ecuador. 1 tonf = 1000 kgf.

## 1 · Cómo falla una ménsula (y por qué se revisan tres cosas)

#: Los ensayos (Kriz y Raths, 1965) muestran tres formas de falla principales. El diseño del ACI las cubre **con tres aceros**, uno por cada falla:
#: **a) Flexión.** El acero de arriba fluye y el hormigón de abajo se aplasta, como en una viga. Se evita con el acero A_{f}.
#: **b) Tensión diagonal.** Una grieta inclinada nace en el borde de la placa de apoyo y cruza la ménsula. Se evita limitando el cortante (sección 3) y con los estribos horizontales A_{h}.
#: **c) Corte directo.** La ménsula se «despega» de la columna por una grieta casi vertical en la cara de la columna: el hormigón de la ménsula resbala sobre el de la columna. Se evita con el acero de **fricción-cortante** A_{vf}, que cose la grieta.
#: Además, la viga prefabricada se apoya sobre una placa y suele frenarse al dilatarse con la temperatura: eso mete una **tracción horizontal** N_{uc} en la ménsula, que se cubre con el acero A_{n}. Los estribos **verticales** (como los de una viga) casi no ayudan aquí, porque la grieta es casi vertical y pasa entre ellos; los que sirven son los **horizontales**.

## 2 · Datos del problema

f_c = 350 'resistencia del hormigón f'c [kgf/cm2]
F_y = 4200 'esfuerzo de fluencia del acero de refuerzo [kgf/cm2]
b_w = 35 'ancho de la ménsula = ancho de la columna de apoyo [cm]
L_n = 15 'luz libre de la viga prefabricada [m]
W_D = 2000 'carga muerta uniforme sobre la viga [kgf/m]
W_L = 2800 'carga viva uniforme sobre la viga [kgf/m]

#: **Cargas mayoradas.** El ACI no diseña con las cargas reales sino con cargas **aumentadas** (1.2 la muerta y 1.6 la viva), porque la viva es más incierta. Es el «margen de seguridad» del lado de las cargas:
W_u = 1.2·W_D + 1.6·W_L 'carga última sobre la viga [kgf/m]
#: **Reacción en el apoyo.** La viga es simple y simétrica: cada extremo carga la mitad del total, W_{u}·L_{n}/2. Esa es la carga vertical V_{u} que le llega a **una** ménsula:
V_u = W_u·L_n/2 'carga vertical última sobre la ménsula [kgf]

#dibujo("Planteamiento: la viga prefabricada de 15 m descansa en dos ménsulas, una en cada columna", ud = m, escala = auto, cotas = m, alto = 70)
#  rect(0, 1, 15, 0.6, "gruesa")
#  achurado(0, 1, 15, 0.6, "concreto")
#  rect(-0.35, -1.2, 0.35, 2.3, "media")
#  rect(15, -1.2, 0.35, 2.3, "media")
#  flecha(2, 3, 2, 1.7, "azul")
#  texto(2.2, 2.7, "W_{u} = 6880 kgf/m", 2.5, "i")
#  flecha(0.1, -0.4, 0.1, 1, "rojo")
#  flecha(14.9, -0.4, 14.9, 1, "rojo")
#  texto(0.5, -0.7, "V_{u} = W_{u}·L_{n}/2", 2.5, "i")
#  cota(0, -1.6, 15, -1.6, -0.1, "L_{n} = 15 m")
#fin

## 3 · Predimensionamiento: dar medidas a la ménsula

#: Antes de calcular aceros hay que **proponer** la forma. Se hace con cuatro reglas prácticas:
#: **i)** Entre la placa de apoyo y la cara de la columna se deja **3 cm** como mínimo, para poder montar la viga.
#: **ii)** El **claro de cortante** a_{v} (la distancia de la carga a la cara de la columna) se toma como **el doble del espacio** entre la viga y la columna **más la mitad de la placa**: la carga no actúa justo al borde de la placa sino hacia su centro.
#: **iii)** La relación a_{v}/d conviene entre **0.15 y 0.40**: menos es una ménsula casi un «muro», más ya se parece a una viga.
#: **iv)** La altura en el borde libre (h_{2}) debe ser al menos **la mitad** del peralte de la cara.
sep = 3 'separación entre la placa de apoyo y la cara de la columna (asumida) [cm]
l_p = 10 'longitud de la placa de apoyo en el sentido de la ménsula (asumida; se verifica en la sección 9) [cm]
a_v = 2·sep + l_p/2 'claro de cortante: distancia de la carga a la cara de la columna [cm]
r_a = 0.30 'relación a_v/d que se propone para empezar (entre 0.15 y 0.40) [-]
d_calc = a_v/r_a 'peralte que da esa relación [cm]
#: El peralte calculado sale 36.7 cm: **se redondea hacia arriba a 40 cm**, que es una medida constructiva y queda del lado seguro.
d = 40 'peralte efectivo de la ménsula, medido en la cara de la columna [cm]
rec = 5 'recubrimiento desde la cara superior hasta el centro del acero principal [cm]
h_1 = d + rec 'altura total de la ménsula en la cara de la columna [cm]
h_2 = 0.5·h_1 'altura en el borde libre (mitad de h_1, como pide el ACI) [cm]
l = sep + l_p + rec 'saliente de la ménsula: 3 cm de separación + placa + 5 cm de borde [cm]
r_real = a_v/d 'relación a_v/d que queda realmente (debe estar entre 0.15 y 0.40) [-]

#dibujo("Medidas de la ménsula (cm): la viga se apoya sobre una placa de 10 cm, a 3 cm de la columna", ud = cm, escala = auto, cotas = cm, alto = 175)
#  rect(-35, -30, 35, 110, "media")
#  achurado(-35, -30, 35, 110, "concreto")
#  polilinea([0, 18, 18, 0], [45, 45, 22.5, 0], "gruesa")
#  rect(3, 45, 10, 2, "gruesa rojo")
#  rect(3, 47, 45, 32, "media")
#  flecha(8, 90, 8, 49, "rojo")
#  texto(10, 88, "V_{u} = 51 600 kgf", 3, "i")
#  linea(0, 45, 0, 20, "trazos")
#  cota(0, 52, 3, 52, 4, "3")
#  cota(3, 52, 13, 52, 4, "10")
#  cota(13, 52, 18, 52, 4, "5")
#  cota(0, 60, 18, 60, 4, "l = 18")
#  cota(-37, 0, -37, 45, -6, "h_{1} = 45")
#  cota(24, 22.5, 24, 45, 7, "h_{2} = 22.5")
#  cota(-35, -35, 0, -35, -4, "b_{w} = 35")
#  cota(0, 36, 11, 36, -4, "a_{v} = 11")
#fin

#: **Lectura del resultado.** a_{v}/d sale entre 0.15 y 0.40: la ménsula es corta y se diseña como ménsula, no como viga. La base de la ménsula se toma del **mismo ancho de la columna** (b_{w} = 35 cm).

## 4 · ¿Aguanta el hormigón? Revisión del cortante máximo

#: Antes de diseñar el acero se verifica que **el hormigón por sí solo** pueda llevar el cortante, sin que se «aplaste en diagonal». Si no, no hay cantidad de acero que lo arregle: hay que agrandar la ménsula.
#: El ACI pide que V_{u}/φ **no pase del menor** de tres valores, con φ = 0.75 para cortante. La razón de dividir entre φ: la resistencia se **reduce** por φ y la carga se **aumenta** por los factores, así que aquí se compara la carga ya dividida entre φ con la capacidad nominal.
phi_v = 0.75 'factor de reducción para cortante y fricción-cortante [-]
V_nec = V_u/phi_v 'cortante nominal que debe poder llevar el hormigón [kgf]
V_lim1 = 0.2·f_c·b_w·d 'límite 1: 0.2·f'c·b_w·d [kgf]
V_lim2 = (34 + 0.08·f_c)·b_w·d 'límite 2: (34 + 0.08·f'c)·b_w·d [kgf]
V_lim3 = 110·b_w·d 'límite 3: 110·b_w·d [kgf]
V_lim = min(V_lim1, min(V_lim2, V_lim3)) 'el menor de los tres: el que manda [kgf]
r_dc = V_nec/V_lim 'relación demanda/capacidad del hormigón (si es < 1 cumple) [-]
#: **Lectura.** Rige el **límite 2**. La relación demanda/capacidad da cerca de **0.79**: cumple (menor que 1) y no sobra demasiado (mayor que 0.5), así que las dimensiones son **razonables**: no hay que agrandar ni se puede reducir mucho.

## 5 · Qué fuerzas actúan en la cara de la columna

#: La sección crítica es la **cara de la columna**: ahí la ménsula tiende a despegarse. Allí actúan tres cosas a la vez:
#: **V_{u}**, el cortante: la carga vertical de la viga.
#: **N_{uc}**, una tracción horizontal. Aunque el diseño no la prevea, la viga siempre transmite algo por rozamiento (frenado, retracción, temperatura). El ACI exige **al menos el 20 % de V_{u}**, y se toma ese mínimo.
#: **M_{u}**, el momento: V_{u} por su brazo a_{v}, **más** N_{uc} por su brazo (h − d), porque la tracción horizontal actúa en la parte alta y está desviada del acero principal.
N_uc = 0.2·V_u 'tracción horizontal mínima que exige el ACI [kgf]
M_u = V_u·a_v + N_uc·(h_1 - d) 'momento en la cara de la columna [kgf·cm]

#dibujo("Fuerzas en la cara de la columna: V_{u} baja a a_{v} de la cara, N_{uc} jala hacia afuera", ud = cm, escala = auto, cotas = cm, alto = 130)
#  rect(-35, -30, 35, 110, "media")
#  achurado(-35, -30, 35, 110, "concreto")
#  polilinea([0, 18, 18, 0], [45, 45, 22.5, 0], "gruesa")
#  flecha(11, 80, 11, 47, "rojo")
#  texto(13, 75, "V_{u}", 3, "i")
#  flecha(0, 44, 22, 44, "azul")
#  texto(23, 41, "N_{uc}", 3, "i")
#  cota(0, 53, 11, 53, 4, "a_{v}")
#  cota(-8, 0, -8, 45, -3, "h_{1}")
#fin

## 6 · Los tres aceros

#: Cada fuerza se cubre con un acero. La idea en las tres es la misma: **fuerza que debe llevar el acero = área × Fy × φ**, y de ahí se despeja el área.
#: **A_{n}** — el acero que resiste la **tracción** N_{uc}. Es simple: la fuerza entre lo que aguanta cada cm² de acero. Con φ = 0.90 (tracción).
phi_n = 0.90 'factor de reducción para tracción y flexión [-]
A_n = N_uc/(phi_n·F_y) 'acero para la tracción horizontal [cm2]
#: **A_{vf}** — el acero de **fricción-cortante**, que cose la grieta entre ménsula y columna. Funciona por rozamiento: al intentar resbalar, la grieta rugosa se abre un poco, el acero se estira y **aprieta** las caras. La fuerza que resiste es μ·A_{vf}·Fy, donde **μ** es el coeficiente de fricción de la superficie:
#: μ = 1.40 si la ménsula se hormigona **a la vez** que la columna (monolítico); 1.00 si va contra hormigón endurecido **rugoso** (6 mm); 0.60 si va contra hormigón endurecido **liso**; 0.70 si va contra acero estructural.
#: Las ménsulas se hacen **monolíticas** con la columna (se hormigonan juntas), por eso:
mu = 1.4 'coeficiente de fricción: hormigón monolítico [-]
A_vf = V_u/(phi_v·mu·F_y) 'acero de fricción-cortante [cm2]
#: **A_{f}** — el acero de **flexión**, que resiste el momento. Se trata como una viga con un brazo interno z; el ACI permite tomar **z = 0.8·d**: la distancia entre el acero de tracción y la resultante de compresión del hormigón.
z = 0.8·d 'brazo interno de la flexión [cm]
A_f = M_u/(phi_n·F_y·z) 'acero para el momento [cm2]

## 7 · Acero principal A_{sc} (el tirante de arriba)

#: Los tres aceros no se colocan por separado: se **combinan** en un solo acero principal arriba, A_{sc}, que es el tirante de la biela. El ACI da tres criterios y manda **el mayor**:
#: **a)** A_{f} + A_{n}: flexión más tracción (los dos tiran).
#: **b)** (2/3)·A_{vf} + A_{n}: dos tercios del acero de corte (el otro tercio va en los estribos horizontales) más la tracción.
#: **c)** 0.04·(f'c/Fy)·b_{w}·d: un mínimo para que la ménsula no falle de golpe con muy poco acero.
A_sc1 = A_f + A_n 'criterio a) flexión + tracción [cm2]
A_sc2 = (2/3)·A_vf + A_n 'criterio b) corte + tracción [cm2]
A_sc3 = 0.04·(f_c/F_y)·b_w·d 'criterio c) mínimo [cm2]
A_sc = max(A_sc1, max(A_sc2, A_sc3)) 'acero principal requerido: el mayor de los tres [cm2]
#: **Lectura.** Rige el criterio b): en una ménsula tan corta **manda el corte**, no la flexión. Es lo característico de a_{v}/d pequeño.
#: **Escoger las barras.** Se necesitan 10.53 cm². Con barras de Ø22 mm (3.80 cm² cada una):
d_b = 2.2 'diámetro de las barras principales [cm]
A_b = pi·d_b^2/4 'área de una barra Ø22 [cm2]
n_b = 3 'número de barras principales (se prueba con 3) [barras]
A_prov = n_b·A_b 'acero colocado [cm2]
c_prov = A_prov/A_sc 'colocado entre requerido (debe ser ≥ 1) [-]
#: Con **3 Ø22 mm** se colocan 11.40 cm² ≥ 10.53 cm²: cumple. Las barras se **sueldan a una barra transversal** del mismo diámetro (o a un ángulo) en el borde libre: así el tirante queda anclado como un «tirante con ancla», no solo por adherencia.

## 8 · Estribos horizontales A_{h} (el confinamiento)

#: Los estribos **horizontales** cierran la biela y detienen la grieta diagonal. Se reparten en los **2/3 superiores** del peralte. El ACI pide que su área total sea al menos la **mitad del acero que no es de tracción pura**:
A_h = 0.5·(A_sc - A_n) 'área total mínima de estribos horizontales [cm2]
#: Se usan estribos cerrados de Ø10 mm, cada uno con dos ramas dentro de la ménsula:
d_e = 1.0 'diámetro del estribo [cm]
A_e = pi·d_e^2/4 'área de una rama [cm2]
n_e = 3 'número de estribos cerrados (se prueba con 3) [estribos]
A_h_prov = 2·n_e·A_e 'área colocada: 2 ramas por estribo [cm2]
c_h = A_h_prov/A_h 'colocado entre requerido (debe ser ≥ 1) [-]
s_e = 8 'separación de los estribos, dentro de los 2/3 superiores [cm]
dos_tercios = (2/3)·d 'zona donde se reparten los estribos [cm]
n_c = 2·s_e 'extensión ocupada por 3 estribos a 8 cm (dos espacios de 8 cm) [cm]
#: **Lectura.** 3 estribos Ø10 (6 ramas) dan 4.71 cm² ≥ 3.90 cm²: cumple. Quedan a 8 cm entre sí: los tres caben dentro de los 27 cm de los 2/3 superiores (n_{c} es menor que dos_tercios).

#dibujo("Armado de la ménsula: 3 Ø22 arriba soldadas a una barra transversal y 3 estribos Ø10 @ 8 cm", ud = cm, escala = auto, cotas = cm, alto = 160)
#  rect(-35, -30, 35, 110, "media")
#  achurado(-35, -30, 35, 110, "concreto")
#  polilinea([0, 18, 18, 0], [45, 45, 22.5, 0], "gruesa")
#  linea(-20, 40, 15, 40, "gruesa verde")
#  linea(15, 40, 15, 33, "gruesa verde")
#  circulo(15.2, 40, 1.1, "gruesa verde")
#  polilinea([0, 15, 15, 0, 0], [32, 32, 30, 30, 32], "media rojo")
#  polilinea([0, 15, 15, 0, 0], [24, 24, 22, 22, 24], "media rojo")
#  polilinea([0, 9, 9, 0, 0], [16, 16, 14, 14, 16], "media rojo")
#  texto(22, 42, "A_{sc} = 3 Ø22 (soldada al extremo)", 2.5, "i")
#  texto(22, 30, "3 estribos Ø10 @ 8 cm", 2.5, "i")
#  cota(25, 14, 25, 32, 4, "2 espacios de 8")
#  cota(-8, 40, -8, 45, -3, "5")
#fin

## 9 · Placa de apoyo: que el hormigón no se aplaste (verificación adicional)

#: Los apuntes dejan **pendiente** verificar la placa de 10 cm. La viga transmite V_{u} por una superficie pequeña (la placa), y ahí el hormigón puede **aplastarse**. El ACI permite un esfuerzo de apoyo de 0.85·f'c, con φ = 0.65 para aplastamiento. La placa mide b_{w} de ancho y l_{p} de largo:
phi_a = 0.65 'factor de reducción para aplastamiento [-]
A_pl = b_w·l_p 'área de contacto de la placa [cm2]
P_apl = phi_a·0.85·f_c·A_pl 'carga que aguanta el hormigón bajo la placa [kgf]
r_apl = V_u/P_apl 'demanda entre capacidad del aplastamiento (si es < 1 cumple) [-]
#: **Lectura.** Con 10 cm de placa la relación da cerca de 0.76: **cumple**. Si diera más de 1, bastaría alargar la placa (l_{p}) y recalcular a_{v}: toda la hoja se actualiza.

## 10 · Resumen de lo que se construye

#: **Dimensiones:** columna 35 × 35 cm; ménsula b_{w} = 35 cm, h_{1} = 45 cm en la cara, h_{2} = 22.5 cm en el borde, saliente l = 18 cm.
#: **Armado:** acero principal 3 Ø22 mm (11.40 cm²) soldado a una barra transversal; 3 estribos cerrados Ø10 mm a 8 cm; 1 Ø12 mm de montaje para amarrar los estribos.
#: **Comentario de los apuntes.** El resultado es una ménsula **muy pequeña**: conviene ampliar su saliente para facilitar el montaje y dar más asiento a la viga, sin cambiar el armado.
