# Zapata céntrica: el balasto sale del asiento, no de una tabla

#: La misma zapata de las hojas 48, 54 y 57, pero con la carga **centrada**: sin momentos. Parece el caso aburrido, y es justo al revés: es el único donde todo se puede despejar a mano, y por eso es el que sirve de **patrón** para comprobar que los seis programas están bien montados antes de meterles la carga excéntrica.
#: Y responde una pregunta que sale siempre: **si GEO5 no pide el módulo de balasto, ¿cómo calcula?** No lo pide porque no usa muelles. Integra la deformación capa a capa con el módulo del suelo. El balasto no es dato suyo: es **consecuencia**, y de ahí se saca para los programas de estructuras.

## 0 · El caso

B = 1.5 'lado de la zapata [m] ; L = 1.5 'el otro lado [m] ; D_f = 0.7 'desplante [m] ; t = 0.4 'canto de la zapata [m]
c_x = 0.3 'lado de la columna [m]
γ = 18 'peso unitario de la arena [kN/m³] ; φ = 30 'ángulo de fricción [°] ; c = 0 'cohesión [kPa]
γ_h = 23 'peso unitario del hormigón [kN/m³] ; γ_r = 20 'peso unitario del relleno [kN/m³]
N_col = 202 'carga de servicio que baja por la columna [kN]

## 1 · La carga que llega de verdad al suelo

#: Por la columna bajan {N_col} kN, pero el suelo no aguanta solo eso: aguanta además el peso de la propia zapata y el de la tierra que se echó encima de ella. Los tres son carga vertical y los tres se reparten sobre la misma área.
A_z = dec(1.5*1.5, 3) [m^2] 'área de la zapata
P_zap = dec(1.5*1.5*0.4*23, 2) [kN] 'peso de la zapata
h_rel = dec(0.7 - 0.4, 2) [m] 'espesor de tierra encima de la zapata
P_rel = dec((2.25 - 0.3*0.3)*0.3*20, 2) [kN] 'peso de esa tierra
N_tot = dec(202 + 20.7 + 12.96, 2) [kN] 'carga vertical total sobre el plano de apoyo
#: La zapata pesa {P_zap} kN y la tierra de encima {P_rel} kN: entre las dos añaden un 17 % a lo que baja por la columna. **No es despreciable y hay programas que lo olvidan.**

## 2 · La presión de contacto: aquí sí es una división

#: Con la carga centrada la resultante pasa por el centro de la zapata, no hay momento y la presión sale **uniforme**. Este es el único caso en que la presión de contacto es un cociente y no hace falta resolver ningún contacto:
q_c = dec(235.66/2.25, 2) [kPa] 'presión de contacto, uniforme
q_ct = dec(104.74/9.80665, 2) [tonf/m^2] 'la misma, en las unidades de obra
#: {q_c} kPa, o sea {q_ct} tonf/m². **GEO5 da exactamente 104.74 kPa**, lo que confirma que cuenta el peso propio igual que aquí.
#: En cuanto la carga se corre, esta división deja de valer: aparece un momento, la presión se inclina y, si la resultante sale del núcleo central, un borde se despega y hay que resolver el contacto con muelles que no trabajen a tracción. Eso es la hoja 48.

## 3 · La capacidad portante: ¿revienta el suelo?

#: Otra pregunta distinta. La presión de contacto dice cuánto aprieta la zapata; la capacidad dice cuánto aguanta el suelo antes de romper. Meyerhof, con la cohesión nula, deja dos sumandos: la sobrecarga de la tierra de encima y el peso del propio suelo bajo la zapata.
q_sob = dec(0.7*18, 2) [kPa] 'sobrecarga a la cota de apoyo
φ_r = dec(30*pi/180, 4) [rad] 'el ángulo en radianes
N_q = dec(exp(pi*tan(0.5236))*tan(pi/4 + 0.5236/2)^2, 3) [-] 'factor de sobrecarga
N_γ = dec(2*(18.401 + 1)*tan(0.5236), 3) [-] 'factor de peso propio
#: Los factores de forma y de profundidad, con la zapata cuadrada (B/L = 1):
F_qs = dec(1 + 1*tan(0.5236), 3) [-]
F_γs = dec(1 - 0.4*1, 3) [-]
F_qd = dec(1 + 2*tan(0.5236)*(1 - sin(0.5236))^2*0.7/1.5, 3) [-]
F_γd = 1 [-]
#: Y la capacidad última, término a término:
q_u1 = dec(12.6*18.401*1.577*1.135, 1) [kPa] 'lo que aporta estar enterrada 0.7 m
q_u2 = dec(0.5*18*1.5*22.402*0.6, 1) [kPa] 'lo que aporta el suelo de debajo
q_u = dec(415.0 + 181.5, 1) [kPa] 'capacidad última
#: {q_u} kPa. Y el reparto enseña algo: {q_u1} kPa vienen del desplante y solo {q_u2} del suelo de abajo. **Enterrar la zapata 70 cm aporta más del doble que el terreno que la sostiene.**
FS = dec(596.5/104.74, 2) [-] 'factor de seguridad frente a rotura
#: FS = {FS}, muy por encima de los 3 que pide la NEC-15. Con esta carga centrada la zapata sobra; lo que la ponía al límite en la hoja 57 era la excentricidad, no la carga.

## 4 · El balasto: presión entre asiento

#: El modelo de elementos finitos necesita un dato que ni el libro ni la capacidad portante dan: cuánta presión hay que poner para hundir el suelo un metro. Por definición, presión entre asiento:
k_s_def = q_c/s_c
#: GEO5 no pide ese número: lo produce. Integra la deformación capa a capa con el módulo edométrico y devuelve el asiento. Para esta zapata da 1.8 mm, y entonces el balasto se despeja:
s_c = 1.8 'asiento que calcula GEO5 [mm]
k_s = dec(104.74/0.0018, 0) [kN/m^3] 'balasto deducido del asiento
k_st = dec(58189/9.80665, 0) [tonf/m^3] 'el mismo, en unidades de obra
#: **{k_st} tonf/m³.** Ese es el muelle que hay que poner en Hekatan Struct, SAP2000, SAFE y ETABS para que los cuatro hablen del mismo suelo que GEO5.

## 5 · Por qué no vale la regla de bolsillo

#: Bowles propuso estimar el balasto desde la presión admisible, suponiendo que el asiento admisible ronda los 25 mm:
q_adm = dec(596.5/3, 1) [kPa] 'presión admisible con FS = 3
k_sB = dec(40*3*198.8, 0) [kN/m^3] 'balasto por la regla de Bowles
k_sBt = dec(23856/9.80665, 0) [tonf/m^3]
#tabla("De dónde sale","Balasto [tonf/m³]:0","Respecto a GEO5:2")({"del asiento que calcula GEO5","de la regla de Bowles"}; [5934, 2433]; [1.00, 0.41])
#: La regla de bolsillo da **menos de la mitad**. No es que una esté mal: Bowles supone un asiento de 25 mm y esta zapata se asienta 1.8, o sea catorce veces menos. Cuanto menos se hunde el suelo, más rígido es el muelle.
#: Y la consecuencia práctica: **el balasto no es una propiedad del terreno que se copie de una zapata a otra**. Depende del ancho. Con carga uniforme sobre un área de ancho B, el asiento elástico vale:
s_el = q_c*B*(1 - ν^2)*I_s/E_su
#: El ancho entra multiplicando, así que una zapata de 3 m sobre la misma arena se hunde el triple que una de 1 m con la misma presión, y su balasto es tres veces menor. Por eso se pide para una zapata concreta.

## 6 · Lo que hace cada programa

#tabla("Programa","¿Capacidad?","¿Presión de contacto?","¿Asiento?","¿Armadura?")({"GEO5 Spread Footing","Hekatan Struct, SAP2000, SAFE, ETABS, OpenSees","Hekatan LISP (esta hoja)"}; {"sí, Meyerhof","no","sí, a mano"}; {"uniforme, supuesta","sí, nudo a nudo con muelles","uniforme, a mano"}; {"sí, por capas","sí, del muelle","no"}; {"sí, ACI 318-19","no","no"})
#: Ninguno hace todo. GEO5 contesta **si aguanta**; los de estructuras contestan **cómo aguanta**, que es lo que arma el hormigón. Y esta hoja enseña de dónde sale cada número para que ninguno sea una caja negra.

## En una línea

#: Con carga centrada la presión es una división, la capacidad sale de una fórmula y el balasto se despeja del asiento: {q_ct} tonf/m² de contacto, FS = {FS} frente a rotura, y {k_st} tonf/m³ de muelle para los modelos. **Si los seis programas no coinciden en este caso, no tiene sentido pasarles el excéntrico.**
