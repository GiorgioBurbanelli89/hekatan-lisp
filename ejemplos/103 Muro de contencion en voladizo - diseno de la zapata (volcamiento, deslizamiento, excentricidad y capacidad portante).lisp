# Muro de contención en voladizo: diseño y verificación de la base
#numerico

#: **Qué se calcula.** El muro de Manabí de las hojas 96, 98 y 99 (fuste de 2.60 m sobre zapata de 3.00 x 0.40 m) ya no se mira deformado: aquí se **diseña y se verifica su base**. Los cuatro estados límite externos que pide la NEC-SE-GC: empuje activo, volcamiento, deslizamiento, excentricidad y presión de contacto, y capacidad portante del suelo de apoyo.
#: **Cómo se calcula.** Todo estático y por metro de muro. El empuje activo por **Rankine** (sin roce en la cara trasera) y la capacidad portante por **Meyerhof con el ancho efectivo**, la misma fórmula de la hoja 54. Al final viene el **diseño**: un barrido del ancho B para encontrar el más estrecho que cumple.
#: **Unidades.** kN, m y kPa, por metro de muro. Dentro de las fórmulas los ángulos van en radianes.
#: **Arbitros.** Factores: NEC-SE-GC (2022), tablas 5 y 6. Cargas: Struct (hojas 98 y 99) y la misma geometría que GEO5 (hoja 96). Capacidad portante: Meyerhof contra el ejemplo de Das de la hoja 54. **Esta hoja no dibuja**: el muro, la malla y el sismo viven en las otras tres.

## 1 · Datos

#: **La geometría**, en abscisa s medida **desde la puntera** (s = 0) hacia el relleno: la puntera es el voladizo de 0.70 m que sobresale hacia el terreno de delante, la cara trasera del fuste cae en s = 1.10 y el talón termina en s = 3.00.
B = 3 [m] 'ancho de la zapata, s = 0 a 3
hz = 0.4 [m] 'espesor de la zapata
pun = 0.7 [m] 'puntera: voladizo por delante del fuste
tal = 1.9 [m] 'talón: vuelo por detrás del fuste, queda bajo el relleno
s_f = pun + hz [m] 'abscisa de la cara trasera del fuste
hf = 2.6 [m] 'altura del fuste, de la cara superior de la zapata a la coronación
ts = 0.25 [m] 'espesor del fuste arriba
ti = 0.4 [m] 'espesor del fuste abajo
h = hf + hz [m] 'altura total del muro
Df = 0.7 [m] 'desplante: el terreno de delante llega a z = -2.30 y tapa la base de la zapata

#: **Materiales**, los del estudio de suelos (hoja 96):
gam_c = 23 [kN/m3] 'hormigón del muro
gam_r = 18.5 [kN/m3] 'arena SP del relleno
gam_f = 17.5 [kN/m3] 'arena con limo SP-SM bajo la zapata
phi_r = 30 'ángulo de fricción del relleno [grados]
phi_f = 29.97 'ángulo de fricción del suelo de apoyo [grados]
c_f = 0 [kPa] 'cohesión: los dos suelos son arenosos, no aporta nada
pr_r = phi_r·pi/180 'el mismo ángulo, en radianes, que es lo que quieren las fórmulas
pr_f = phi_f·pi/180

#: **Lo que exige la norma** (NEC-SE-GC, tablas 5 y 6):
req_des = 1.6 'deslizamiento, sin sismo
req_vol = 3 'volcamiento: MR/MA ≥ 3.00 (diseño con sismo ≥ 2.00)
kern = 1/6 'excentricidad: e/B ≤ 1/6 (diseño con sismo ≤ 1/4)
req_cap = 3 'capacidad portante con carga muerta + carga viva normal

## 2 · El empuje activo: Rankine

#: Con la cara trasera vertical y el relleno horizontal, **Rankine no ve roce**: el suelo empuja paralelo a la superficie libre y el coeficiente sale del estado de ruptura en un campo de esfuerzos uniforme. Hay dos caminos para el mismo número, y los dos están aquí para que no haya fe:
ka1 = (1 - sin(pr_r))/(1 + sin(pr_r))
ka2 = tan(pi/4 - pr_r/2)^2
d_ka = round(ka1 - ka2, 4) 'los dos caminos, a cuatro decimales
ka = ka1
#: Con 30° sale **1/3 exacto**: tan²(45° − 15°) = tan²(30°) = 1/3. Y el empuje, por metro de muro:
h_a = hf [m] 'el plano de análisis es la cara trasera del fuste, de la zapata a la coronación
pa = 0.5·ka·gam_r·h_a^2 [kN/m]
z_a = h_a/3 [m] 'altura sobre la cara superior de la zapata
brazo = z_a + hz [m] 'brazo sobre la base de la zapata: es lo que vuelca el muro

#: **Coulomb, para comparar.** Si se le deja roce a la cara, δ = 2/3·φ, el empuje baja y ya trae componente vertical:
delta = 2/3·pr_r
ka_c = cos(pr_r)^2/(cos(delta)·(1 + sqrt(sin(pr_r + delta)·sin(pr_r)/cos(delta)))^2)
pa_c = 0.5·ka_c·gam_r·h_a^2 [kN/m]
#hide
r_pa = round(pa, 2)
r_pac = round(pa_c, 2)
#show
#: Coulomb da @{r_pac} frente a @{r_pa} de Rankine, y GEO5/Struct dan 17.47 kN/m (K = 0.280, con su plano crítico y su roce). **Rankine queda por encima de los dos: es el lado seguro**, y es el que se usa en todo lo que sigue.

## 3 · Las cargas verticales

#: **El fuste es un trapecio**, no un rectángulo: 0.25 m arriba y 0.40 abajo. Su peso es el área por el peso específico, y su brazo sale del centroide. Para un espesor que varía linealmente, el promedio del cuadrado sobre la altura es (ti² + ti·ts + ts²)/3 —la misma regla que da el momento de inercia del rectángulo—, y el centroide medido desde la cara plana (la trasera) es la mitad de ese promedio dividida entre el espesor medio:
t_med = (ts + ti)/2 [m] 'espesor medio
t_cua = (ti^2 + ti·ts + ts^2)/3 'promedio de t² sobre la altura [m2]
x_g = 0.5·t_cua/t_med [m] 'centroide desde la cara trasera del fuste
#: **Chequeo por integración**: no se verifica la fórmula con la misma fórmula, se integra la función espesor tal como es:
x_gi = 0.5·integral(@(u) (ti + (ts - ti)·u)^2, 0, 1)/integral(@(u) (ti + (ts - ti)·u), 0, 1)
d_xg = round(x_g - x_gi, 4) 'debe dar cero

a_fus = t_med·hf [m2] 'área de la sección del fuste, por metro de muro
W_fus = a_fus·gam_c [kN/m] 'peso del fuste
W_zap = B·hz·gam_c [kN/m] 'peso de la zapata
W_rel = tal·hf·gam_r [kN/m] 'peso del relleno que se apoya sobre el talón
Vtot = W_fus + W_zap + W_rel [kN/m] 'todas las cargas verticales
x_f = s_f - x_g [m] 'brazo de la resultante del fuste desde la puntera
x_z = B/2 [m] 'brazo de la zapata
x_r = s_f + tal/2 [m] 'brazo del relleno: el centro del talón

#: **Cruce con Struct.** El mismo concreto y el mismo relleno en el modelo de muelles de las hojas 98 y 99:
peso_s = 47.035 'peso del concreto en Struct, hoja 99 [kN/m]
rel_s = 91.39 'relleno sobre el talón en Struct, hoja 99 [kN/m]
n_s = 144.78 'resultante vertical en Struct, hoja 98 [kN/m]
pv_s = 6.359 'componente vertical del empuje de Coulomb en Struct [kN/m]
d_pes = round(W_fus + W_zap - peso_s, 4) 'cero: el concreto pesa lo mismo
d_rel = round(W_rel - rel_s, 4) 'cero: el relleno pesa lo mismo
d_nor = round(peso_s + rel_s + pv_s - n_s, 2) 'la N de Struct, a dos decimales
#hide
r_vt = round(Vtot, 3)
#show
#: Los tres cruces dan cero. **Vtotal = @{r_vt} kN/m**, y Struct su 144.78: la diferencia entera es la componente vertical del empuje de Coulomb (6.359), que Rankine no tiene porque no hay roce.

## 4 · Volcamiento

#: La zapata gira sobre la **punta de la puntera**, el punto más lejano del empuje. De un lado todo lo que pesa, del otro el empuje:
mres = W_fus·x_f + W_zap·x_z + W_rel·x_r [kN] 'momento resistente respecto a la puntera
mot = pa·brazo [kN] 'momento volcante
FSvol = mres/mot
m_vol = round(100·(FSvol/req_vol - 1), 1) 'cuánto sobra, en %, sobre el 3.00
#hide
r_fsv = round(FSvol, 2)
#show
#: La NEC-SE-GC (tabla 5) exige MR/MA ≥ 3.00 sin sismo; sale @{r_fsv}, un @{m_vol} % por encima. **Por qué sobra tanto**: el talón está cargado de arena (91 kN a 2.05 m de la puntera), y esa palanca pesa mucho más que un empuje de 20.8 kN/m que además empuja bajo. El muro no volca por su peso, volcaría si le quitaran el relleno de encima.

## 5 · Deslizamiento

#: La zapata patina sobre el suelo de apoyo. Resiste la normal por tan del ángulo de roce y empuja la horizontal del empuje. El roce concreto-suelo se toma conservador, 2/3 de φ de la arena de apoyo:
delta_b = 2/3·pr_f 'roce entre la zapata y el SP-SM
FSdesl = Vtot·tan(delta_b)/pa
m_des = round(100·(FSdesl/req_des - 1), 1) 'cuánto sobra, en %, sobre el 1.60
#hide
r_fsd = round(FSdesl, 2)
#show
#: NEC-SE-GC tabla 5: ≥ 1.60 sin sismo. Sale @{r_fsd}, un @{m_des} % por encima. Es la verificación **más justa** de las cuatro: es la que manda en el diseño de la sección 9.
#: **Lo que aquí se deja fuera, y cuánto valdría.** (1) El **empuje pasivo** del suelo de delante: solo quedan 0.70 m de arena tapando la puntera, pero aun así sumaría:
kp = tan(pi/4 + pr_f/2)^2 'coeficiente pasivo
pp = 0.5·kp·gam_f·Df^2 [kN/m] 'empuje pasivo sobre esos 0.70 m
FSdesl_p = (Vtot + pp)·tan(delta_b)/pa 'FS si se contara el pasivo
#hide
r_pp = round(pp, 2)
r_fdp = round(FSdesl_p, 2)
#show
#: con él el FS subiría de @{r_fsd} a @{r_fdp}; se omite porque en obra ese suelo se remueve, se cava y se rellena, y porque **el lado seguro es no contarlo**. (2) La **cohesión de la base**: c = 0 en los dos suelos, no hay nada que sumar. (3) La **tierra de delante**: también se omite por conservador; con ella la normal sube y el roce también.

## 6 · Excentricidad y presión bajo la zapata

#: El empuje vuelca y las verticales sujetan, así que la resultante **no cae en el centro** de la zapata. La distancia desde el centro es la excentricidad, medida aquí **hacia el talón**:
exx = (mres - mot)/Vtot - B/2 [m] 'positiva = hacia el talón
exxb = exx/B 'excentricidad relativa, sin unidades
m_e = round(100·(1 - abs(exxb)/kern), 1) 'cuánto sobra, en %, dentro del tercio central
#hide
r_ex = round(exx, 4)
r_exb = round(exxb, 4)
r_kern = round(kern, 4)
#show
#: La NEC exige e/B ≤ 1/6 = @{r_kern}. Sale @{r_exb} (e = @{r_ex} m), o sea @{m_e} % por dentro del límite. **Con eso la resultante cae dentro del tercio central y toda la zapata queda comprimida**: si se pasara, un borde se levanta y la presión saldría negativa, y el suelo no tracciona.
#: A esa distancia, la presión es una recta (flexión compuesta de la zapata, sección de 1 m de fondo):
q_tal = Vtot/B·(1 + 6·exx/B) [kPa] 'en el talón
q_pun = Vtot/B·(1 - 6·exx/B) [kPa] 'en la puntera
q_max = max(q_tal, q_pun)
q_min = min(q_tal, q_pun)
d_iden = round((q_tal + q_pun)/2·B - Vtot, 4) 'identidad: (q1+q2)/2·B = Vtot, debe dar cero
#hide
r_qt = round(q_tal, 2)
r_qp = round(q_pun, 2)
#show
#: **La mayor presión sale en el talón** (@{r_qt} frente a @{r_qp}), y es lógico: ahí está el relleno, que tira de la resultante hacia su lado, mientras que el empuje es más pequeño y además empuja bajo. Struct da el mismo par de números, 58.5 y 39.1 kPa con N = 144.78 kN/m.
#: **¿Es el método o son las cargas?** Se repite este mismo equilibrio con las cargas de Struct (concreto 47.035, relleno 91.390, empuje horizontal 17.470 y vertical 6.359, todas citadas de las hojas 98 y 99):
mres_s = W_fus·x_f + W_zap·x_z + W_rel·x_r + pv_s·s_f 'la vertical de Coulomb baja en la cara trasera
mot_s = 17.47·brazo 'la horizontal de Coulomb, al mismo brazo
exx_s = (mres_s - mot_s)/n_s - B/2
q_s1 = n_s/B·(1 + 6·exx_s/B) [kPa] 'máximo, con las cargas de Struct
q_s2 = n_s/B·(1 - 6·exx_s/B) [kPa] 'mínimo, con las cargas de Struct
q_1s = 58.5 'máximo citado de Struct, hoja 98 [kPa]
q_2s = 39.1 'mínimo citado de Struct, hoja 98 [kPa]
d_q1 = round(q_s1 - q_1s, 2)
d_q2 = round(q_s2 - q_2s, 2)
#hide
r_qs1 = round(q_s1, 2)
r_qs2 = round(q_s2, 2)
r_dq1 = round(abs(d_q1), 2)
r_dq2 = round(abs(d_q2), 2)
#show
#: Mismas cargas, mismo equilibrio: la estática da @{r_qs1} y @{r_qs2} frente a 58.5 y 39.1, es decir @{r_dq1} y @{r_dq2} kPa de diferencia (menos del 1.5 %). **La estática cierra**; lo que cambia al final no es el método sino las cargas: Rankine empuja más y no trae la componente vertical de Coulomb.

## 7 · Capacidad portante

#: El suelo tiene que aguantar la mayor de esas presiones sin romper. Meyerhof, con el ancho efectivo —la resultante excéntrica solo comprime B − 2·|e| de la zapata—:
qs = gam_f·Df [kPa] 'sobrecarga del terreno de delante: 0.70 m de arena
nq = exp(pi·tan(pr_f))·tan(pi/4 + pr_f/2)^2
ng = 2·(nq + 1)·tan(pr_f)
#: **¿Salen las tablas?** Con φ = 30° exacto, estas mismas fórmulas tienen que dar los valores de Das que usa la hoja 54:
nq30 = exp(pi·tan(pi/6))·tan(pi/4 + (pi/6)/2)^2
ng30 = 2·(nq30 + 1)·tan(pi/6)
d_nq = round(100·(nq30/18.4 - 1), 3) 'Das da 18.4, diferencia en %
d_ng = round(100·(ng30/22.4 - 1), 3) 'Das da 22.4, diferencia en %
#hide
r_nq = round(nq, 3)
r_ng = round(ng, 3)
#show
#: Das (tablas 6.2 y 6.3) da 18.4 y 22.4; aquí, con φ de la arena de apoyo, salen @{r_nq} y @{r_ng}. Para 30° exacto la diferencia con la tabla es de @{d_nq} % y @{d_ng} %: la tabla está redondeada, la fórmula no.
#: La fundación hunde un poco la base y eso la confina; entra el factor de profundidad de Meyerhof, y de forma el factor de Saric (es tan estrecha que va en corte, sin factores de forma):
f_qd = 1 + 2·tan(pr_f)·(1 - sin(pr_f))^2·Df/B
be = B - 2·abs(exx) [m] 'ancho efectivo
q_ult = qs·nq·f_qd + 0.5·gam_f·be·ng [kPa]
q_adm = q_ult/req_cap [kPa] 'FS = 3.0, NEC tabla 6
q_adm_t = q_adm/9.80665 [tonf/m2] 'para el que piensa en toneladas
FScap = q_ult/q_max
m_cap = round(100·(FScap/req_cap - 1), 1) 'cuánto sobra, en %, sobre el 3.00
#hide
r_qu = round(q_ult, 1)
r_qa = round(q_adm, 1)
r_qat = round(q_adm_t, 1)
r_qm = round(q_max, 2)
r_fsc = round(FScap, 2)
#show
#: NEC tabla 6: FS = 3.0 con carga muerta y carga viva normal, así que la presión admisible es @{r_qa} kPa (@{r_qat} tonf/m²) contra una presión máxima en la zapata de @{r_qm} kPa: sobra un @{m_cap} %, y el factor real es @{r_fsc}. El control aquí es de carrilera; lo que gobierna esta zapata es el deslizamiento.

## 8 · Las cuatro verificaciones

#| Qué se verifica | Calculado | Exigido (NEC-SE-GC) | Cuánto sobra [%] |
#|---|---:|---:|---:|
#| Volcamiento, MR/MA | @{r_fsv} | ≥ 3.00 | @{m_vol} |
#| Deslizamiento, FS | @{r_fsd} | ≥ 1.60 | @{m_des} |
#| Excentricidad, e/B | @{r_exb} | ≤ 0.1667 | @{m_e} |
#| Capacidad portante, q_{ult}/q_{max} | @{r_fsc} | ≥ 3.00 | @{m_cap} |

#: Las cuatro pasan. **La que menos sobra es el deslizamiento**: un @{m_des} % sobre el mínimo, contra un @{m_vol} % del volcamiento. Eso importa para la sección 9, porque es el deslizamiento el que manda sobre el ancho.

## 9 · El diseño: ¿cuánto ancho hace falta?

#: Los números de arriba son para B = 3.00 m. Ahora la pregunta de diseño: **¿cuánto se puede estrechar la zapata?** Al cambiar B cambian la normal, el brazo del relleno y la excentricidad, y con ellos los tres factores. Se recorta **el talón** (la puntera y el fuste quedan donde están), de 1.60 a 3.00 m:
#hide
Res = zeros(8, 6)
for i = 1:8
  Bi = 1.6 + 0.2·(i - 1)
  Vi = W_fus + gam_c·hz·Bi + gam_r·hf·(Bi - s_f)
  MRi = W_fus·x_f + gam_c·hz·Bi^2/2 + gam_r·hf·(Bi^2 - s_f^2)/2
  ei = (MRi - mot)/Vi - Bi/2
  q_ti = Vi/Bi·(1 + 6·ei/Bi)
  q_pi = Vi/Bi·(1 - 6·ei/Bi)
  q_mi = max(q_ti, q_pi)
  bei = Bi - 2·abs(ei)
  f_qi = 1 + 2·tan(pr_f)·(1 - sin(pr_f))^2·Df/Bi
  qu_i = qs·nq·f_qi + 0.5·gam_f·bei·ng
  Res(i, 1) = Bi
  Res(i, 2) = round(Vi·tan(delta_b)/pa, 3)
  Res(i, 3) = round(MRi/mot, 3)
  Res(i, 4) = round(ei/Bi, 4)
  Res(i, 5) = round(q_mi, 1)
  Res(i, 6) = round(qu_i/q_mi, 3)
end
#show
#: Columnas: **B [m]** · **FS deslizamiento** (≥ 1.60) · **FS volcamiento** (≥ 3.00) · **e/B** (≤ 0.1667) · **presión máxima [kPa]** · **FS capacidad** (≥ 3.00):
Res
#: **Chequeo de la última fila** contra las secciones 4 a 7 (redondeo incluido, debe dar cero):
d_b1 = round(Res(8, 2) - FSdesl, 3)
d_b2 = round(Res(8, 3) - FSvol, 3)
d_b3 = round(Res(8, 4) - exxb, 4)
#: **Lectura.** El deslizamiento es el que gobierna: a 2.00 m da 1.42 y no llega, a **2.20 m da 1.62 y ya pasa**; el volcamiento pasa desde 1.80 m y la excentricidad no se acerca al tercio central en todo el recorrido. **B mínimo = 2.20 m**, gobernado por el deslizamiento, y la zapata de 3.00 m trae un 51 % de holgura encima.
#: Las mismas curvas dibujadas contra B, con el mínimo normativo en línea discontinua:
#: Cada curva es su numerador por una constante de la hoja: el deslizamiento es V·tan(δ_{b})/p_{a} y el volcamiento M_{R}/M_{A}, con p_{a} y M_{A} que no cambian con B:
kdes = tan(delta_b)/pa 'factor del deslizamiento: FS = V·kdes [1/(kN/m)]
kvol = 1/mot 'factor del volcamiento: FS = M_R·kvol [1/kN]
#fila
#fplot(FSd = (W_fus + gam_c·hz·t + gam_r·hf·(t - s_f))·kdes, limite = 1.6, [1.6 3])
#fplot(FSv = (W_fus·x_f + gam_c·hz·t^2/2 + gam_r·hf·t^2/2 - gam_r·hf·s_f^2/2)·kvol, limite = 3, [1.6 3])
#finfila
#: A la izquierda el deslizamiento, que **cruza** el 1.60 cerca de 2.20 m; a la derecha el volcamiento, que pasa el 3.00 cerca de 1.80 m (la tabla de arriba: desde 1.80 m).

## 10 · Lo que queda fuera de esta hoja

#: ⏳ **Sismo.** No entra. El empuje dinámico sería de Mononobe-Okabe, y no está verificado: con δ = 2/3·φ y relleno horizontal da 38.9 kN/m frente a los 35.0 de Struct con k_{h} = 0.336 (hoja 99). Hasta que el oráculo cierre, aquí se calcula estático, y los límites de la tabla 5 bajan con sismo (volcamiento ≥ 2.00 y deslizamiento 1.05 en diseño).
#: ⏳ **Nivel freático.** El estudio de suelos lo da a −3.05 m, 5 cm bajo la zapata. Con agua, la presión de poros resta a la normal, baja el roce y todo el FS cae: es el pendiente que más puede cambiar estos números.
#: ⏳ **Empuje pasivo y tierra de delante.** Fuera por conservador; la sección 5 ya mostró cuánto sumaría el pasivo.
#: ⏳ **Armado del concreto, asentamientos y estabilidad global** (el vuelco sobre la superficie circular que sí calcula la hoja 96): son otras hojas, otras verificaciones. Esta se queda en la base.
