# Factor de seguridad por reducción de resistencia en GeoFEM: la escalera SRM de la Demo04, contra GEO5 y la NEC
#numerico

#: **Qué se hace.** GEO5 FEM (GeoFEM) da el factor de seguridad de un talud **sin dibujar superficies de rotura**: va **dividiendo la resistencia del suelo** por un factor F cada vez mayor y repite el cálculo de elementos finitos hasta que el talud ya no encuentra equilibrio. El último F que aguanta es el **FS**. Es el método de reducción de resistencia (SRM, *strength reduction method*).
#: **Qué se puede hacer en esta hoja y qué no.** Cada peldaño de la escalera es un Newton completo con los 2009 puntos de Gauss del talud (hojas 132 y 133): eso no se rehace aquí. Lo que sí: (1) la **reducción** de c y φ; (2) la **escalera** de GEO5, peldaño a peldaño, con el veredicto converge / no converge de cada peldaño tomado del cálculo (Geotechnic, que es GEO5 a 12 cifras); (3) lo que le pasa al **punto de Gauss de la hoja 133** en cada peldaño, con las tensiones que GEO5 tenía en memoria (Frida, 17 cifras); (4) por qué el FS del talud no es el de un punto; (5) la verificación con la **NEC-SE-GC 2015**.
#: **Juez.** GEO5 2024, Demo04.gmk, etapa 1 (peso propio): **FS = 1.69** (captura de la ventana Analysis, hekatan-school/VIDEOS/geo5_interfaz/geofem/captura_v2/etapa1/15ˍAnalysis.png). Hekatan Geotechnic: FS = 1.6935087808.

## 1 · La reducción: c/F y tan φ/F

#: La resistencia al corte de Mohr-Coulomb es τ_{f} = c + σ·tan φ. Dividirla entera por F es dividir sus **dos** términos:
#: c_{F} = c/F,     tan φ_{F} = tan φ/F
#: Ojo: se divide la **tangente**, no el ángulo. En el solver de GEO5 (verificado con Frida a 13 cifras el 4-sep-2026) es exactamente φ_{F} = atan(tan φ/F).
f_r(F, ϕ) = atan(tan(ϕ*pi/180)/F)*180/pi 'ángulo reducido por F [°]
#: Los dos suelos de la Demo04:
φ_1 = 22.7 'ángulo de rozamiento del suelo 1 (arriba, el del talud) [°]
c_1 = 9 'cohesión del suelo 1 [kPa]
φ_2 = 38 'ángulo de rozamiento del suelo 2 (abajo) [°]
c_2 = 120 'cohesión del suelo 2 [kPa]
#: Y con ellos el cono de Drucker-Prager de GeoFEM (hoja 133) se recalcula en cada peldaño con los valores reducidos:
a_F(F, ϕ) = 2*sin(atan(tan(ϕ*pi/180)/F))/(sqrt(3)*(3 + sin(atan(tan(ϕ*pi/180)/F)))) 'pendiente α del cono con φ reducido
k_F(F, ϕ, C) = 6*(C/F)*cos(atan(tan(ϕ*pi/180)/F))/(sqrt(3)*(3 + sin(atan(tan(ϕ*pi/180)/F)))) 'ordenada k del cono con c y φ reducidos [kPa]

## 2 · La escalera de GEO5

#: Cómo sube F GeoFEM (extraído del solver y comprobado con su «course of analysis», registros/talud_geo5.md): cada peldaño multiplica la resistencia que queda por un paso **s = 0.90**; si el Newton no converge, se vuelve al último peldaño bueno y el paso se **relaja a la mitad** de lo que faltaba (0.95, 0.975, 0.9875); a la **cuarta** relajación, o cuando s pasaría de 0.99, para. F no se redondea.
#: F_{nuevo} = 1/(R·s),   R = producto de los pasos que convergieron
#: Lo que el cálculo dijo en cada intento de la etapa 1 (1 = converge, 0 = no converge), del log de Geotechnic (igual al de GEO5 intento por intento, con los cuatro fallos):
c_v = [1; 1; 1; 1; 1; 0; 0; 0; 0] 'veredicto de los 9 intentos
#: Con eso la escalera se rehace sola:
#hide
F_t = zeros(9, 1)
s_t = zeros(9, 1)
R = 1
n_r = 0
F_S = 1
#show
for i = 1:9
  s_i = 1 - 0.1/2^n_r
  s_t(i) = s_i
  F_t(i) = 1/(R*s_i)
  if c_v(i) > 0.5
    R = R*s_i
    F_S = F_t(i)
  end
  if c_v(i) < 0.5
    n_r = n_r + 1
  end
end
s_t 'paso usado en cada intento
F_t 'F probado en cada intento
#: El siguiente paso sería s = 1 − 0.1/2⁴ = 0.99375 > 0.99 (y van 4 relajaciones): la escalera para. El FS es el último F que convergió:
F_S 'factor de seguridad de la etapa 1
#hide
h_F = round(F_S, 10)
t_1 = round(F_t(6), 4)
t_2 = round(F_t(7), 4)
t_3 = round(F_t(8), 4)
t_4 = round(F_t(9), 4)
#show
#: Es decir: aguanta con F = 1/0.9⁵ = **@{h_F}**, no aguanta con @{t_1}, ni con @{t_2}, ni con @{t_3}, ni con @{t_4}. El FS queda entre 1.6935 y 1.7149: la escalera de GEO5 lo da **por abajo**, con el último que convergió.
#: **Cómo se ve que el talud se va.** El desplazamiento horizontal máximo del talud al final de cada peldaño que convergió (log de Geotechnic, columna dx): casi constante hasta F = 1.52 y de golpe ×9 en el último. Ese salto es el mecanismo formándose.
#dibujo("Desplazamiento horizontal máximo [mm] contra F: el talud se va al acercarse al FS", ud = m, escala = auto, alto = 200)
#  linea(0, 0, 9, 0, "media")
#  linea(0, 0, 0, 6, "media")
#  texto(8.6, -0.35, "F", 3, "c")
#  texto(-0.6, 5.8, "dx [mm]", 2.6, "c")
#  texto(0, -0.35, "1.0", 2.4, "c")
#  texto(7.2, -0.35, "1.9", 2.4, "c")
#  texto(-0.4, 3.46, "17.3", 2.4, "c")
#  linea(0, 0.32, 0.889, 0.28, "gruesa azul")
#  linea(0.889, 0.28, 1.877, 0.24, "gruesa azul")
#  linea(1.877, 0.24, 2.974, 0.22, "gruesa azul")
#  linea(2.974, 0.22, 4.194, 0.40, "gruesa azul")
#  linea(4.194, 0.40, 5.548, 3.46, "gruesa azul")
#  circulo(0, 0.32, 0.08, "azul relleno")
#  circulo(0.889, 0.28, 0.08, "azul relleno")
#  circulo(1.877, 0.24, 0.08, "azul relleno")
#  circulo(2.974, 0.22, 0.08, "azul relleno")
#  circulo(4.194, 0.40, 0.08, "azul relleno")
#  circulo(5.548, 3.46, 0.1, "rojo relleno")
#  texto(4.5, 3.6, "FS = 1.6935", 2.6, "c", estilo = "rojo")
#  linea(7.054, 0, 7.054, 5.5, "trazos rojo")
#  texto(7.054, 5.7, "1.8817 no converge", 2.4, "c", estilo = "rojo")
#  linea(6.261, 0, 6.261, 5.0, "puntos rojo")
#  linea(5.895, 0, 5.895, 4.8, "puntos rojo")
#  linea(5.719, 0, 5.719, 4.6, "puntos rojo")
#fin
#: Eje horizontal: (F − 1)·8, de F = 1 a 1.9. Puntos azules: F = 1, 1.111, 1.235, 1.372, 1.524 (dx = 1.6, 1.4, 1.2, 1.1, 2.0 mm); rojo: 1.6935 (17.3 mm). Las verticales rojas son los cuatro intentos que no convergieron (1.8817 y, punteados, las relajaciones hacia 1.7149).

## 3 · Los suelos al llegar al FS

φ_1F = f_r(F_S, φ_1) 'φ reducido del suelo 1 [°]
c_1F = c_1/F_S 'c reducida del suelo 1 [kPa]
φ_2F = f_r(F_S, φ_2) 'φ reducido del suelo 2 [°]
c_2F = c_2/F_S 'c reducida del suelo 2 [kPa]
#: **Lo que imprime GEO5** bajo el FS (tabla «Soil parameters in the last finished iteration» de la captura): región 1 → φ = 13.40°, c = 5.31 kPa; región 2 → φ = 22.44°, c = 70.86 kPa. Las cohesiones son c/FS, las mismas de aquí. Los ángulos **no**: 13.40 = 22.7/1.6935 y 22.44 = 38/1.6935, o sea el ángulo dividido por F, que no es lo que usa su propio solver (atan(tan φ/F) = 13.87° y 24.77°, comprobado por punto de Gauss). Es solo lo que **imprime** la tabla; el FS no cambia.
φ_1g = φ_1/F_S 'lo que imprime la tabla de GEO5 para el suelo 1 [°]
φ_2g = φ_2/F_S 'lo que imprime la tabla de GEO5 para el suelo 2 [°]

## 4 · El punto de Gauss de la hoja 133, peldaño a peldaño

#: Cada peldaño arranca **de tensión cero** con todo el peso (así lo hace GEO5 en la Demo04, hoja 133) y termina con una tensión en el punto. Estas son las de GEO5 al final de cada peldaño que convergió (σ_{x}, σ_{y}, σ_{z}, τ_{xy}, volcado con Frida, iteraciones 2, 4, 7, 11, 16 y 24 de la etapa 1):
S_g = [-39.6631230899876, -94.683769237691322, -42.537599968778423, -7.1021148426813845; -43.34524993719846, -95.478589898028474, -46.271756527094936, -7.7413436058394085; -47.304253750038058, -96.966967171156369, -50.785266397693036, -8.3990170215993309; -51.455693826540994, -98.229275555454734, -55.663087416394895, -9.2862464425630122; -56.076802908453388, -99.654483006604707, -61.534992940704946, -10.401709373184794; -60.540410922227004, -103.96829645085039, -72.373612343407927, -12.632082286473894] 'σ de GEO5 en el punto 1 del elemento 36 al final de cada peldaño [kPa]
#: Con cada σ, la función de fluencia con los parámetros **reducidos de ese peldaño**. Los F de los seis peldaños que convergieron son 1 (el arranque) y los cinco primeros intentos de la escalera:
#hide
f_p = zeros(6, 1)
J_p = zeros(6, 1)
I_p = zeros(6, 1)
for i = 1:6
  I_i = S_g(i, 1) + S_g(i, 2) + S_g(i, 3)
  m_i = I_i/3
  J_i = sqrt(0.5*((S_g(i, 1) - m_i)^2 + (S_g(i, 2) - m_i)^2 + (S_g(i, 3) - m_i)^2) + S_g(i, 4)^2)
  I_p(i) = I_i
  J_p(i) = J_i
end
F_6 = [1; F_t(1); F_t(2); F_t(3); F_t(4); F_t(5)]
for i = 1:6
  f_p(i) = round(J_p(i) + a_F(F_6(i), φ_1)*I_p(i) - k_F(F_6(i), φ_1, c_1), 6)
end
#show
F_6 'F de cada peldaño que convergió
J_p 'J del punto al final de cada peldaño [kPa]
f_p 'función de fluencia con c y φ reducidos de ese peldaño [kPa]
#: **Lectura.** f nunca es positiva (la tensión de GEO5 siempre es **admisible** con la resistencia reducida). En F = 1, 1.111 y 1.235 vale 0: el punto está **sobre** el cono, plastificado. En 1.372 y 1.524 queda un poco dentro (−0.12 y −0.46 kPa): en el último paso el talud le quitó algo de carga (descarga elástica). En el FS vuelve a tocar el cono (−0.002 kPa). Con cada peldaño el cono se encoge (k baja de 8.49 a 5.52 kPa) y J del punto baja con él de 31.8 a 25.8 kPa: el corte que el punto ya no puede llevar se va a los vecinos, hasta que no queda a dónde.

## 5 · Por qué el FS del talud no es el FS de un punto

#: Con la tensión **fija** de F = 1, cada punto tiene su propio «factor local»: el F con que su cono se encoge hasta tocarlo, f(F) = 0. Para el punto de la hoja 133 es 1 (ya está sobre el cono con F = 1). En el suelo 2 ningún punto plastifica con F = 1; el que tiene el factor local más bajo (el **más cargado**, buscado en los 1477 puntos del suelo 2 con las tensiones de Geotechnic) es el punto 5 del elemento 93, abajo a la derecha, en (33.0, −20.8) m:
S_93 = [-86.367808744574219, -345.97194709713648, -86.467951168342140, -1.5635952699674367] 'σ de GEO5 en ese punto con F = 1 [kPa]
I_93 = S_93(1) + S_93(2) + S_93(3) 'primer invariante [kPa]
m_93 = I_93/3 'tensión media [kPa]
J_93 = sqrt(0.5*((S_93(1) - m_93)^2 + (S_93(2) - m_93)^2 + (S_93(3) - m_93)^2) + S_93(4)^2) 'J [kPa]
#: Se busca el F que hace f = 0 partiendo el intervalo [1, 50] por la mitad 60 veces (bisección):
#hide
F_a = 1
F_b = 50
for i = 1:60
  F_m = (F_a + F_b)/2
  f_m = J_93 + a_F(F_m, φ_2)*I_93 - k_F(F_m, φ_2, c_2)
  if f_m < 0
    F_a = F_m
  end
  if f_m >= 0
    F_b = F_m
  end
end
#show
F_93 = (F_a + F_b)/2 'factor local del punto más cargado del suelo 2
#: **Lectura.** Hay puntos con factor local 1 (los 125 del suelo 1 ya plastificados con F = 1) y el peor del suelo 2 tiene 1.52: **los dos por debajo** del FS de 1.69. Un punto (o una franja) plastificado no tumba el talud: el suelo de alrededor toma lo que ese punto suelta. El talud cae cuando la zona plástica **une** el pie con la coronación (un mecanismo) y el Newton ya no encuentra equilibrio: eso es lo que mide la escalera. Por eso el FS de GeoFEM necesita el cálculo entero y no sale de mirar un punto.

## 6 · La NEC-SE-GC 2015

#: Tabla 4 de la NEC-SE-GC (2015), p. 31: factores de seguridad por corte mínimos para taludes, FS = τ_{f}/τ_{A} con τ_{f} = c′ + σ′·tan φ′ (la misma reducción de c y tan φ de la sección 1):
#| Condición | Diseño | Construcción |
#|---|---:|---:|
#| Talud estático, agua normal | 1.50 | 1.25 |
#| Talud pseudoestático, agua normal + k_{h} | 1.05 | 1.00 |
FS_n = 1.5 'FS mínimo NEC, talud estático de diseño
#: Las tres etapas de la Demo04 (GEO5 y Geotechnic, registros/hekatan_geotechnic.md):
#| Etapa | FS GEO5 | FS Geotechnic | NEC estático (≥ 1.50) |
#|---|---:|---:|---|
#| 1 · peso propio | 1.69 | 1.6935 | cumple |
#| 2 · + sobrecarga | 1.48 | 1.4810 | **no cumple** (le falta 1.3 %) |
#| 3 · + anclaje | 1.69 | 1.6935 | cumple |
#: La etapa 2 enseña para qué está el anclaje de la etapa 3: con la sobrecarga el talud baja de 1.50 y el anclaje lo devuelve a 1.69. El caso pseudoestático (1.05 con k_{h}) **no** se puede verificar: la Demo04 no tiene sismo.

## 7 · Hekatan LISP contra GEO5 y Geotechnic

#hide
r_FS = round(F_S, 4)
r_f1 = round(φ_1F, 2)
r_c1 = round(c_1F, 2)
r_f2 = round(φ_2F, 2)
r_c2 = round(c_2F, 2)
r_g1 = round(φ_1g, 2)
r_g2 = round(φ_2g, 2)
r_93 = round(F_93, 4)
d_FS = round(100*(F_S - 1.6935087808430282)/1.6935087808430282, 10)
d_G = round(100*(round(F_S, 2) - 1.69)/1.69, 4)
#show
#| Magnitud | Hekatan LISP | GEO5 2024 | Geotechnic | Diferencia |
#|---|---:|---:|---:|---:|
#| **FS, etapa 1** | @{r_FS} | 1.69 | 1.6935087808 | @{d_G} % con GEO5 (a 2 decimales), @{d_FS} % con Geotechnic |
#| intentos fallidos | 1.8817 / 1.7826 / 1.7369 / 1.7149 | los mismos 4 (log de GEO5) | los mismos | — |
#| c reducida, suelo 1 / 2 [kPa] | @{r_c1} / @{r_c2} | 5.31 / 70.86 | — | 0 |
#| φ reducido que usa el solver, suelo 1 / 2 [°] | @{r_f1} / @{r_f2} | (no lo imprime) | 13.87 / 24.77 | 0 |
#| φ que imprime la tabla de GEO5 [°] | @{r_g1} / @{r_g2} | 13.40 / 22.44 | — | 0 (es φ/FS) |
#| f del punto de la hoja 133 en los 6 peldaños [kPa] | ≤ 0 | σ de GEO5 | — | admisible en todos |
#| factor local, punto más cargado del suelo 2 | @{r_93} | — | — | < FS |
#: **Qué queda comprobado.** La reducción c/F y atan(tan φ/F), la escalera de GEO5 (paso 0.90, relajaciones a la mitad, tope de 4) y el FS = 1/0.9⁵ = 1.6935 que GEO5 imprime como 1.69; y que la tensión de GEO5 en un punto real es admisible con la resistencia reducida de cada peldaño.
#: **Qué NO se reproduce aquí.** Si cada peldaño converge o no (el Newton con 2009 puntos de Gauss): el veredicto se toma del cálculo de Geotechnic, que es GEO5 a 12 cifras por punto de Gauss en las 124 iteraciones de las tres etapas. Las hojas 132 y 133 comprueban por partes lo que hay dentro de cada iteración.
