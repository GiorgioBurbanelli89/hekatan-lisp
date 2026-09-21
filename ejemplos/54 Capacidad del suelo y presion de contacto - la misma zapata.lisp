# Capacidad del suelo y presión de contacto: la misma zapata de 1.5 × 1.5 m

#: La hoja 48 repartió la presión bajo una zapata excéntrica y la comparó con cuatro programas. Antes de repartir nada hay dos preguntas que allí no se contestaron: **cuánto aguanta el suelo** (geotecnia) y **por qué se permite repartir la presión con una recta** (rigidez de la zapata). Esta hoja contesta las dos con la MISMA zapata del ejemplo 6.10 de Braja M. Das, *Principles of Foundation Engineering*, 9.ª ed. (2019): cuadrada de 1.5 × 1.5 m, desplantada a 0.7 m en arena con γ = 18 kN/m³, φ' = 30°, c' = 0, y la carga corrida 0.30 m en una dirección y 0.15 m en la otra.
#: Las fuerzas van en kilonewton [kN] y las presiones en kilopascal [kPa] mientras se sigue al libro, que trabaja en SI. Al final se pasa a tonelada-fuerza por metro cuadrado [tonf/m²], que es como salen los resultados de los programas y como se lee un estudio de suelos en Ecuador: 1 tonf/m² = 9.81 kPa.

## 0 · La zapata del ejemplo (figura 3.25 del libro)

#: Arriba, el corte: la columna baja, la zapata de 1.5 × 1.5 m apoya a 0.7 m y todo está en arena. Abajo, la planta: el punto negro es donde cae la carga, corrida 0.15 m en un sentido y 0.30 m en el otro respecto al centro. Es la misma figura del libro, redibujada a escala con las medidas reales.
#dibujo("Cimentación cargada excéntricamente · Das, figura 3.25 (ej. 3.8, p. 170-172)", ud = m, escala = 1:28, cotas = m, alto = 240)
#  linea(-0.35, 3.0, 2.15, 3.0, "media")
#  rect(0, 2.2, 1.5, 0.25, "gruesa")
#  achurado(0, 2.2, 1.5, 0.25, "diagonal")
#  rect(0.6, 2.45, 0.3, 0.95, "gruesa")
#  achurado(0.6, 2.45, 0.3, 0.95, "diagonal")
#  flecha(0.75, 3.95, 0.75, 3.46, "rojo")
#  texto(0.9, 3.8, "Q", 3, "i")
#  texto(0.75, 2.3, "1.5 × 1.5 m", 2.4, "c")
#  texto(1.75, 2.92, "Arena", 2.5, "i")
#  texto(1.75, 2.72, "γ = 18 kN/m³", 2.4, "i")
#  texto(1.75, 2.54, "φ' = 30°", 2.4, "i")
#  texto(1.75, 2.36, "c' = 0", 2.4, "i")
#  cota(-0.12, 2.2, -0.12, 3.0, 0.22, "D_{f} = 0.7")
#  linea(0.75, 2.2, 0.75, 1.75, "eje")
#  rect(0, 0, 1.5, 1.5, "gruesa")
#  linea(0.75, -0.25, 0.75, 1.75, "eje")
#  linea(-0.25, 0.75, 1.75, 0.75, "eje")
#  circulo(0.6, 1.05, 0.045)
#  circulo(0.6, 1.05, 0.022)
#  cota(0.6, 1.28, 0.75, 1.28, 0.1, "e_{B} = 0.15")
#  cota(0.95, 0.75, 0.95, 1.05, -0.12, "e_{L} = 0.30")
#  cota(0, -0.28, 1.5, -0.28, -0.12, "B = 1.50")
#  cota(-0.28, 0, -0.28, 1.5, 0.12, "L = 1.50")
#  texto(0.75, -0.62, "planta", 2.4, "c")
#fin
#: Las dos excentricidades pasan de B/6 = 0.25 m en un caso y no en el otro: 0.30 > 0.25 y 0.15 < 0.25. Por eso el libro va al caso II de Highter y Anders, y por eso el borde se levanta.

## 1 · Las tres cosas que sostienen a una zapata

#: Terzaghi (1943) parte el problema en tres sumandos, y cada uno es un mecanismo distinto del suelo: la COHESIÓN que pega las partículas, el PESO DEL TERRENO que hay encima del plano de apoyo (que estorba a la cuña de falla al querer subir) y el PESO DEL PROPIO SUELO bajo la zapata (la fricción que hay que vencer para que la cuña se mueva). En la forma de Meyerhof, con los factores de forma y de profundidad, y con la sobrecarga del terreno a la cota de apoyo:
q_ult = c*N_c*F_cs*F_cd + q_sob*N_q*F_qs*F_qd + 0.5*γ_s*B*N_γ*F_γs*F_γd
#: La presión última sale en [kPa] si la cohesión va en [kPa], el peso unitario en [kN/m³] y el ancho en [m]. Los seis factores F y los tres N son adimensionales. La sobrecarga es el peso de la tierra que quedó encima:
q_sob = γ_s*D_f
#: En esta arena c' = 0, así que el primer sumando desaparece entero: **en arena limpia la zapata se sostiene por fricción, no por cohesión**. Quedan la sobrecarga y el peso propio del suelo.

## 2 · Los factores N no son una tabla: son tres fórmulas

#: La tabla 6.2 del libro da 18.4 y 22.4 para φ' = 30°. Esos números no son un dato de ensayo: salen de la solución de Reissner (1924) para la cuña de falla, y los otros dos se deducen de ella. Con el ángulo de fricción en radianes, que aquí son π/6:
φ = pi/6
N_q = dec(exp(pi*tan(φ))*tan(pi/4 + φ/2)^2, 3)
N_c = dec((N_q - 1)/tan(φ), 2)
N_γ = dec(2*(N_q + 1)*tan(φ), 3)
#: El factor de sobrecarga vale {N_q} y el de peso propio {N_γ}: son los 18.4 y 22.4 de la tabla, con más cifras. El de cohesión, {N_c}, no se usa aquí porque c' = 0, pero es el que manda en arcilla.
#: Así crece cada uno con el ángulo de fricción. El eje horizontal es φ' en RADIANES (0.35 rad ≈ 20°, 0.70 rad ≈ 40°) y el vertical es el factor, adimensional. Entre 20° y 40° el de peso propio se multiplica por doce: por eso un ensayo que se equivoca 5° en el ángulo cambia la capacidad casi al doble.
#fila
#fplot(N_q = exp(pi*tan(x))*tan(pi/4 + x/2)^2, [0.26 0.79])
#fplot(N_γ = 2*(exp(pi*tan(x))*tan(pi/4 + x/2)^2 + 1)*tan(x), [0.26 0.79])
#finfila

## 3 · La excentricidad no baja la resistencia: recorta el área

#: Meyerhof (1953) no toca la resistencia del suelo cuando la carga es excéntrica. Cambia la zapata: la sustituye por otra más chica, centrada bajo la carga, y le aplica presión uniforme. Esa es el área efectiva — la hoja 48 la calculó para este ejemplo (caso II de Highter y Anders) y dio 1.193 m², con lado largo 1.275 m y corto 0.936 m.
#: La razón es física: el suelo falla por donde está cargado. La franja que se levanta no aporta resistencia, y si se contara, la capacidad saldría alta e insegura.
A_e = 1.193 [m^2]
L_e = 1.275 [m]
B_e = 0.936 [m]
D_f = 0.7 [m]
γ_s = 18 [kN/m^3]
B = 1.5 [m]
q_sob = dec(γ_s*D_f, 1) [kPa]
#: La sobrecarga vale {q_sob} kPa: es lo que pesan 0.7 m de arena. Los factores de forma llevan el cociente de los lados EFECTIVOS, porque la zapata que falla es la efectiva; el de profundidad lleva la B real, porque la cuña arranca del ancho verdadero (Das, tabla 6.3):
F_qs = dec(1 + (B_e/L_e)*tan(φ), 4)
F_γs = dec(1 - 0.4*(B_e/L_e), 4)
F_qd = dec(1 + 2*tan(φ)*(1 - sin(φ))^2*D_f/B, 4)
#: Y con eso, la presión última sobre el área efectiva en [kPa] y la carga última en [kN]:
q_u = dec(q_sob*N_q*F_qs*F_qd + 0.5*γ_s*B_e*N_γ*F_γs, 1) [kPa]
Q_u = dec(A_e*q_u, 1) [kN]
#: {Q_u} kN es el 606 kN del libro. El primer término, el de sobrecarga, aporta 374.6 kPa y el de peso propio 133.3: **tres cuartas partes de lo que aguanta esta zapata vienen de estar enterrada 0.7 m**, no del suelo de debajo.

## 4 · De la rotura al servicio: el factor de seguridad

#: La carga última es con la que el suelo REVIENTA. La que se usa para dimensionar es esa dividida por un factor de seguridad, que en cimentaciones superficiales vale 3 — es alto porque el suelo se conoce con pocos ensayos y la falla es frágil y sin aviso:
FS = 3
Q_adm = dec(Q_u/FS, 1) [kN]
q_adm = dec(q_u/FS, 1) [kPa]
q_admt = dec(q_adm/9.81, 2) [tonf/m^2]
#: {Q_adm} kN es la carga de servicio que admite esta zapata CON esa excentricidad, y {q_adm} kPa la presión admisible sobre el área efectiva, o sea {q_admt} tonf/m². Ese es el número que va en la portada de un estudio de suelos, y ya lleva dentro los factores de forma, los de profundidad y el área efectiva de ESTA zapata: no es una propiedad del terreno que se copie a otra.

## 5 · De dónde sale el módulo de balasto

#: El modelo de elementos finitos de la hoja 48 necesitaba un dato que Das no da: el módulo de balasto, o sea cuánta presión hay que poner para hundir el suelo un metro, en [kN/m³]. Por definición es presión entre asentamiento, con la presión en [kPa] y el asentamiento en [m]:
ks_def = q_c/s_c
#: Bowles (1996) observó que si el asentamiento admisible es del orden de 25 mm, ese cociente queda atado a la presión admisible, y propuso una regla de bolsillo que da el balasto en [kN/m³] con la presión admisible en [kPa]:
k_sB = dec(40*FS*q_adm, 0) [kN/m^3]
k_sBt = dec(k_sB/9.81, 0) [tonf/m^3]
#: Son {k_sBt} tonf/m³. La hoja 48 modeló con 2000 tonf/m³: **el balasto del modelo no era un número inventado, sale de la misma capacidad de carga**, y la diferencia es de los redondeos del libro.
#: Conviene ver el otro camino, el del asentamiento elástico, porque enseña que el balasto NO es una propiedad del suelo. Para una carga uniforme sobre un área de ancho B_c, con el módulo del suelo en [kPa] y su Poisson, el asentamiento en [m] vale:
s_el = q_c*B_c*(1 - ν^2)*I_s/E_su
#: El ancho entra multiplicando. Dos zapatas sobre la MISMA arena, una de 1 m y otra de 3 m, con la misma presión, se hunden distinto: la grande el triple. Y como el balasto es presión entre asentamiento, la grande tiene un balasto tres veces menor. Por eso un balasto se pide para una zapata concreta y no se reutiliza.
E_su = 25000 [kPa]
ν = 0.3
s_e = dec(q_adm*B_e*(1 - ν^2)/E_su*1000, 2) [mm]
#: Con módulo del suelo de 25 MPa (arena media) y Poisson 0.3, esta zapata se asienta {s_e} mm bajo la presión admisible: por debajo de los 25 mm que se suelen aceptar, así que manda la capacidad de carga y no el asentamiento.

## 6 · La presión de contacto no la decide el suelo

#: Hasta aquí, geotecnia. Ahora lo estructural, que es otra pregunta: cómo se REPARTE esa presión bajo la zapata. Y la respuesta no depende solo del suelo, sino de lo rígida que sea la zapata comparada con él.
#dibujo("Cómo reparte la presión una zapata según su rigidez y el suelo", ud = m, escala = 1:45, cotas = m, alto = 115)
#  rect(0, 0, 2, 0.18, "gruesa")
#  flecha(1, 0.62, 1, 0.2, "rojo")
#  linea(0, -0.62, 0.5, -0.3, "azul")
#  linea(0.5, -0.3, 1, -0.24, "azul")
#  linea(1, -0.24, 1.5, -0.3, "azul")
#  linea(1.5, -0.3, 2, -0.62, "azul")
#  linea(0, 0, 0, -0.62, "azul")
#  linea(2, 0, 2, -0.62, "azul")
#  texto(1, 0.9, "RÍGIDA sobre ARCILLA", 2.4, "c")
#  texto(1, -0.95, "picos en el borde", 2.2, "c")
#  rect(2.6, 0, 4.6, 0.18, "gruesa")
#  flecha(3.6, 0.62, 3.6, 0.2, "rojo")
#  linea(2.6, 0, 2.6, -0.12, "azul")
#  linea(2.6, -0.12, 3.6, -0.75, "azul")
#  linea(3.6, -0.75, 4.6, -0.12, "azul")
#  linea(4.6, -0.12, 4.6, 0, "azul")
#  texto(3.6, 0.9, "RÍGIDA sobre ARENA", 2.4, "c")
#  texto(3.6, -0.95, "máximo al centro", 2.2, "c")
#  rect(5.2, 0, 7.2, 0.1, "media")
#  flecha(6.2, 0.62, 6.2, 0.16, "rojo")
#  linea(5.2, 0.1, 5.7, 0.04, "media")
#  linea(5.7, 0.04, 6.2, -0.16, "media")
#  linea(6.2, -0.16, 6.7, 0.04, "media")
#  linea(6.7, 0.04, 7.2, 0.1, "media")
#  linea(5.2, -0.28, 5.7, -0.34, "azul")
#  linea(5.7, -0.34, 6.2, -0.85, "azul")
#  linea(6.2, -0.85, 6.7, -0.34, "azul")
#  linea(6.7, -0.34, 7.2, -0.28, "azul")
#  linea(5.2, -0.2, 5.2, -0.28, "azul")
#  linea(7.2, -0.2, 7.2, -0.28, "azul")
#  texto(6.2, 0.9, "FLEXIBLE (cualquier suelo)", 2.4, "c")
#  texto(6.2, -1.05, "la presión sigue a la flecha", 2.2, "c")
#fin
#: La zapata rígida baja sin doblarse, y entonces el suelo decide la forma: la arcilla saturada resiste por cohesión y puede dar presión en el borde, así que se carga ahí; la arena del borde no está confinada, se escapa de lado y la presión se corre al centro. La zapata flexible hace lo contrario: se hunde más donde hay más carga, y la presión sigue a la flecha.
#: Das reparte con una recta (trapecio o triángulo) y eso solo vale para el caso RÍGIDO. El programa de elementos finitos no lo supone: resuelve la placa y deja que la presión salga. Que los dos coincidieran en el 0.36 % de la hoja 48 no es casualidad, y aquí se mide por qué.

## 7 · Cuándo una zapata es rígida: hay número, no criterio de ojo

#: El modelo de Winkler dice que cada punto del suelo responde a lo que se hunde justo ahí, con la presión en [kPa] y el hundimiento en [m]:
q_w = k_s*w
#: Metiendo eso en la ecuación de la viga apoyada en resorte continuo aparece una longitud característica, y su inversa es lo que se compara. Con el módulo del hormigón E en [kPa], la inercia de la franja I en [m⁴] y el balasto en [kN/m³], sale en [1/m]:
lam_def = (k_s/(4*E*I))^0.25
#: El producto de esa inversa por el lado es adimensional y es el que manda (Hetényi, 1946): por debajo de π/4 la zapata se comporta como un bloque rígido; por encima de π es una viga larga y la carga solo se siente cerca de donde entra.
#: Esta zapata tiene 0.40 m de canto y f'c = 240 kgf/cm², que son 23.54 MPa. El módulo del hormigón, por ACI 318-19, es 4700·√f'c en [MPa]:
h = 0.40 [m]
f_c = dec(240*0.0980665, 2) [MPa]
E_c = dec(4700*sqrt(f_c)*1000, 0) [kPa]
I_f = dec(h^3/12, 6) [m^4]
k_s = dec(2000*9.81, 0) [kN/m^3]
λ = dec((k_s/(4*E_c*I_f))^0.25, 4) [m^-1]
λL = dec(λ*B, 4)
lim = dec(pi/4, 4)
#: El módulo sale {E_c} kPa, la inercia {I_f} m⁴ por metro de ancho y el balasto {k_s} kN/m³. El producto vale {λL} contra el límite {lim}: **es rígida, pero por poco** — queda al 86 % del límite. Ese margen chico es exactamente el 0.36 % en que la fórmula de zapata rígida se pasa frente al FEM: la placa real se flexa un pelo y reparte un pelo mejor.
#: El segundo criterio, el de rigidez relativa del ACI 336, usa el módulo del suelo en vez del balasto y considera rígida si pasa de 0.5:
K_r = dec(E_c/E_su*(h/B)^3/12, 3)
#: Da {K_r}, casi el triple del límite. Los dos criterios dicen lo mismo con datos distintos.
#: ¿Desde qué canto dejaría de ser rígida? El eje horizontal es el canto en [m] y el vertical el producto adimensional. La zapata reparte con una recta mientras la curva esté por DEBAJO de 0.785:
#fplot(λL = 1.5*(19620/(4*22802000*x^3/12))^0.25, [0.15 0.6])
#: Con 0.40 m va sobrada; por debajo de unos 0.33 m esta misma zapata deja de repartir con una recta, y ahí hay que creerle al elemento finito y no a la fórmula.

## 8 · Las dos comprobaciones no se mezclan

#: Queda un punto que confunde y conviene cerrarlo. El FEM de la hoja 48 dio una presión máxima de 81.915 tonf/m², pero con la carga de ROTURA, 606 kN. En servicio la carga es tres veces menor, y una vez que el borde levantado se estabiliza el problema vuelve a ser lineal en la carga, así que el pico baja en la misma proporción:
q_max = dec(81.915/FS, 2) [tonf/m^2]
q_med = dec(Q_adm/A_e/9.81, 2) [tonf/m^2]
rel = dec(q_max/q_med, 2)
#: El pico vale {q_max} tonf/m² y la media sobre el área efectiva {q_med} tonf/m², que es la presión admisible del punto 4. **El pico es {rel} veces la media, y eso no es un fallo: las dos comprobaciones miden cosas distintas.** La geotécnica pregunta si la masa de suelo revienta, y para eso cuenta la carga total repartida en el área que trabaja, o sea medias. La estructural pregunta cuánto momento y cuánto punzonamiento le llega al hormigón, y ahí manda el pico y dónde está.
#: Dicho corto: con la presión admisible se decide el TAMAÑO de la zapata; con la distribución de presiones se decide su ARMADURA y su CANTO. Comparar el pico contra la admisible deja zapatas absurdamente grandes; armar con la media deja la esquina sin acero.
#tabla("Comprobación","Q_ué compara","Valor [tonf/m²]:2","Límite [tonf/m²]:2")({"Geotécnica (Meyerhof)","Estructural (contacto)"}; [17.26, 27.31]; [17.26, 0])
#: La fila estructural no lleva límite porque no se compara contra el suelo: ese 27.31 tonf/m² entra como carga en el cálculo de la placa, y de ahí salen los momentos y el punzonamiento.

## 9 · El ejemplo 3.8 de punta a punta, y su gráfica

#: Todo junto, en el orden en que se resuelve: primero la geometría efectiva —lo único que cambia con la excentricidad—, después la resistencia del suelo, que casi no cambia, y al final la carga, que es el producto de las dos.
#: El trapecio del caso II está elegido para que su centro de gravedad caiga bajo la carga. Con esa condición hay fórmula cerrada (deducida en la hoja 48) y no hace falta leer el ábaco a ojo. Con la excentricidad corta relativa 0.15/1.5 = 0.1:
m_c = dec((0.75 - 0.3)/(0.5 + 6*0.1^2), 4) [m]
L_1c = dec(1.6*0.8036, 4) [m]
A_ef = dec(1.5*0.8036, 4) [m^2]
B_ef = dec(1.2054/1.2857, 4) [m]
#: El área efectiva sale 1.2054 m² contra los 1.193 m² que el libro lee del ábaco: **un 1 % de diferencia, y es del ábaco, no del método**. El lado corto efectivo, 0.9375 m, **no depende de la excentricidad larga**: al correr la carga el trapecio se acorta, pero no se estrecha.
#: Con esa geometría, la presión última y la carga. Los factores de forma llevan ahora la relación efectiva 0.9375/1.2857 = 0.729:
F_qsc = dec(1 + 0.729*tan(pi/6), 4)
F_γsc = dec(1 - 0.4*0.729, 4)
q_uc = dec(12.6*18.401*1.4209*1.1347 + 0.5*18*0.9375*22.402*0.7084, 1) [kPa]
Q_uc = dec(1.2054*508.0, 1) [kN]
#: 612.3 kN contra los 606 kN del libro: la diferencia viene entera del ábaco leído a ojo.

### Lo que enseña la gráfica

#: El eje horizontal es la excentricidad larga en metros, de cero a medio metro; el vertical, la carga última en [kN]. La zapata es siempre la misma y el suelo también: lo único que se mueve es dónde cae la carga.
#fplot(Q_u = 2.678571*(452.1*(0.75 - x) + 25.03), [0 0.5])
#: Es una RECTA que baja. Centrada, la zapata aguanta 975 kN; con la carga corrida 0.30 m —el caso del libro— aguanta 612; a 0.45 m, 430. **La mitad de la capacidad se pierde en 45 centímetros de excentricidad.**
#: Y el porqué está en los dos factores. La resistencia del suelo apenas se mueve: 508 kPa con la carga corrida contra 485 kPa centrada, o sea **sube** un 5 % (el trapecio se hace más alargado y el factor de forma lo premia). Lo que se desploma es el área que trabaja: de 2.009 m² a 1.205 m², un 40 % menos. **La excentricidad no debilita el suelo: le quita superficie.**
#: Por eso una zapata excéntrica no se arregla mejorando el terreno, sino agrandándola del lado al que se corre la carga, o quitando la excentricidad con una viga de amarre.

## En una línea

#: La geotecnia dice cuánta carga aguanta el suelo, y de ahí salen el tamaño de la zapata y el balasto del modelo; la rigidez de la zapata dice si la presión se puede repartir con una recta; y solo cuando ese producto adimensional queda por debajo de π/4 la fórmula del libro y el elemento finito TIENEN que dar lo mismo, que es lo que se midió en la hoja 48.
