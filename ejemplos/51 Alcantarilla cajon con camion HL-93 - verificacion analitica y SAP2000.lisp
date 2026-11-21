# Alcantarilla cajón con camión HL-93: ¿son congruentes los resultados?

#: Un camión cruza una alcantarilla cajón de dos celdas. Hekatan Struct lo resuelve con líneas de influencia y lo anima posición por posición. Esta hoja hace lo que hay que hacer antes de creerle a un programa: comprobar A MANO que los números respetan las leyes de la estática, encerrarlos entre dos cotas sencillas, y compararlos con SAP2000 (que trae su propio camión). El ejemplo está publicado en giorgioburbanelli89.github.io/hekatan-struct-lineal/workspace/?t=alcantarilla-carga-movil

## 1 · El modelo

#: Franja de 1 m de ancho. Dos celdas de luz L y alto H a ejes, losas y muros de espesor t, hormigón de módulo E. La losa inferior descansa sobre muelles de Winkler de módulo de balasto k_{s} (2 kg/cm³). Unidades: kN y m.
L = 3.0
H = 2.5
t = 0.30
B = 2*L
E = 24516625
k_s = 19613.3
#: El camión de diseño HL-93 (AASHTO LRFD, en SI): un eje delantero y dos traseros, separados 4.3 m. El largo total es 8.6 m: MÁS que la alcantarilla (B = {B} m). Por eso nunca hay más de dos ejes encima a la vez.
P_1 = 35
P_2 = 145
s_e = 4.3

## 2 · Primera ley: el suelo devuelve lo que pesa el camión

#: Los muelles son lo único que sostiene al cajón. Sumando la fuerza de todos (k por asiento) tiene que salir el peso de los ejes que están encima. Dicho de otra forma: el asiento MEDIO de la losa inferior no depende de la rigidez del cajón, solo del peso y del suelo:
w_med = dec(P_1/(k_s*B)*1000, 4)
#: Con el eje delantero solo (35 kN) sale w_{med} = {w_med} mm. El MEF da 0.29741723 mm: el mismo número hasta el octavo decimal. En las 147 posiciones del camión, |ΣR − ΣP| no pasa de 1e-10 kN, con los asientos de Hekatan y con los de SAP2000.
#: Segunda ley, de momentos: la resultante del suelo tiene que caer justo debajo de la resultante del camión (Σ k·w·x = Σ P·x). Peor diferencia en todo el recorrido: 7e-10 kN·m en Hekatan y 2e-9 en SAP2000.

## 3 · ¿El cajón es rígido o flexible frente al suelo?

#: Una viga sobre suelo elástico tiene una longitud característica 1/λ (Hetényi). Si λ·B es menor que 1 la pieza se comporta como un bloque rígido; si pasa de π, como una viga larga y flexible que concentra el asiento bajo la carga.
EI = dec(E*t^3/12, 1)
lam = dec((k_s/(4*E*t^3/12))^(1/4), 4)
lamB = dec(lam*B, 3)
#: λ·B = {lamB}: la losa inferior SOLA sería flexible. Pero no está sola: los muros y la losa superior la atan y forman un cajón mucho más rígido. El resultado real tiene que quedar ENTRE los dos extremos.

## 4 · Cotas del asiento: bloque rígido < MEF < losa sola

#: Eje delantero (35 kN) sobre el muro central, caso simétrico. Cota inferior: el cajón es un bloque infinitamente rígido y se asienta parejo:
w_rig = dec(P_1/(k_s*B)*1000, 4)
#: Cota superior: la carga baja por el muro a la losa inferior y esta trabaja sola, como viga finita de extremos libres con carga en el centro (Hetényi):
#: Los cuatro valores de la fórmula para λ·B = 3.276 (radianes): cosh, sinh, cos y sin.
C_h = 13.2537
S_h = 13.2160
C_o = -0.9910
S_i = -0.1340
w_het = dec(P_1*lam/(2*k_s)*(C_h + C_o + 2)/(S_h + S_i)*1000, 4)
#tabla("Asiento bajo el muro central","w [mm]:4")({"Bloque rígido (cota inferior)","MEF — Hekatan y SAP2000","Losa inferior sola, Hetényi (cota superior)"}; [0.2974, 0.4039, 0.5311])
#: El MEF (0.4039 mm) queda dentro, más cerca del bloque rígido: es lo que se espera de un cajón cerrado.
#: Lo mismo con el eje pesado en el BORDE (x = B), que es donde sale el máximo de todo el recorrido. El bloque rígido se asienta y además CABECEA: asiento medio más giro por la excentricidad e = B/2.
w_borde = dec((P_2/(k_s*B) + P_2*(B/2)*(B/2)/(k_s*B^3/12))*1000, 4)
#: Bloque rígido: {w_borde} mm. MEF: 5.8512 mm. El MEF da más porque el cajón real se deforma y carga más el borde. Es el mismo orden y del lado correcto: congruente. De paso explica la animación: lo que más se mueve no es la losa flectando, es el CAJÓN ENTERO hundiéndose y cabeceando sobre el suelo.

## 5 · Cotas del momento bajo el eje

#: Eje de 145 kN solo, en el centro de una celda. La losa superior no está ni simplemente apoyada ni empotrada en los muros: está entre las dos.
M_emp = dec(P_2*L/8, 2)
M_apo = dec(P_2*L/4, 2)
#tabla("Momento bajo el eje de 145 kN","M [kN·m]:2")({"Empotrada en los muros, P·L/8 (cota inferior)","MEF — Hekatan y SAP2000","Simplemente apoyada, P·L/4 (cota superior)"}; [54.38, 71.25, 108.75])

## 6 · La estática de un vano, con los números del MEF

#: Esta no es una cota: es una ley exacta. En un vano con momentos M_{i} y M_{j} en los extremos y una carga P en el centro, el momento bajo la carga es el promedio de los extremos más el isostático P·L/4. Con los momentos de extremo que da el MEF (posición 131, eje en x = 4.5 m):
M_i = -45.2634
M_j = -29.7307
M_c = dec((M_i + M_j)/2 + P_2*L/4, 4)
#: Sale {M_c} kN·m y el MEF da 71.2530: idéntico. Comprobado en TODOS los nudos de la losa superior y en las 147 posiciones: diferencia máxima 5e-11 kN·m. Y el salto del cortante bajo cada eje vale el peso del eje con 6e-11 kN de diferencia.
#: Dos leyes más que también se cumplen: Maxwell–Betti (el asiento en i por una carga en j es igual al de j por una carga en i: diferencia 1e-19 m) y la simetría (un eje en x da el espejo de un eje en B − x: 6e-18 m/kN).

## 7 · «Entra el camión y el color no cambia»

#: En la animación el color es el desplazamiento dividido por el MAYOR desplazamiento de todo el recorrido (6.797 mm, con el eje de 145 kN en el borde). La escala es fija para que un color signifique lo mismo en todos los cuadros. Consecuencia: mientras solo está encima el eje delantero (35 kN) la fracción va de 0.24 a 0.06 y todo se ve azul. Cuando entra el primer eje de 145 kN salta a 0.79. No es un error de cálculo: es la escala. x es la posición del eje delantero:
#fplot(limite_azul = 0.125 + 0*x, Fraccion_del_color = [0.0 0.242; 0.6 0.198; 1.2 0.155; 1.8 0.115; 2.4 0.081; 3.0 0.061; 3.6 0.081; 4.2 0.115; 4.8 0.788; 5.4 0.585; 6.0 0.424; 6.6 0.357; 7.2 0.256; 7.8 0.314; 8.4 0.452; 9.0 0.656; 9.6 0.541; 10.2 0.787; 10.8 0.380; 11.4 0.265; 12.0 0.295; 12.6 0.427; 13.2 0.584; 13.8 0.761; 14.4 0.940; 14.6 1.000], [0 15])
#: El momento flector, en cambio, sí responde desde el primer cuadro (11 → 17 kN·m con el eje delantero). Para VER entrar al camión conviene el mapa de esfuerzos, no el de desplazamientos.

## 8 · Contra SAP2000, que trae su propio camión

#: SAP2000 tiene dos análisis nativos de carga móvil: «Multi-Step Static» (el vehículo avanza por un carril a una velocidad, paso a paso) y «Moving Load» (líneas de influencia → envolvente). Se definió el carril sobre las 60 barras de la losa superior y el vehículo 35/145/145 kN. Asiento máximo en cada posición: los puntos son el camión NATIVO de SAP2000 y los de Hekatan; la línea de referencia es el bloque rígido con un eje de 145 kN centrado.
#fplot(bloque_rigido_145 = 1.2322 + 0*x, Hekatan = [0.0 1.4124; 0.6 1.1887; 1.2 0.9414; 1.8 0.7046; 2.4 0.5161; 3.0 0.4136; 3.6 0.5161; 4.2 0.7046; 4.8 4.8482; 5.4 3.7072; 6.0 2.8041; 6.6 2.2554; 7.2 1.7322; 7.8 2.0286; 8.4 2.7796; 9.0 4.3427; 9.6 3.6617; 10.2 5.0639; 10.8 2.3799; 11.4 1.7784; 12.0 1.9306; 12.6 2.6430; 13.2 3.5483; 13.8 4.5906; 14.4 5.5571; 14.6 5.8512], SAP2000_nativo = [0.3 1.3044; 0.9 1.0670; 1.5 0.8139; 2.1 0.6057; 2.7 0.4456; 3.3 0.4456; 3.9 0.6057; 4.5 5.3807; 5.1 4.2884; 5.7 3.2256; 6.3 2.6430; 6.9 1.9306; 7.5 1.7784; 8.1 2.3799; 8.7 5.0639; 9.3 3.6617; 9.9 4.3427; 10.5 2.7796; 11.1 2.0286; 11.7 1.7322; 12.3 2.2554; 12.9 3.0620; 13.5 4.0749], [0 15])
#: Posición por posición (147 casos estáticos, todos los nudos y barras: Ux, Uz, Ry, P, V2, M3) el peor error es 6e-10 %. Con el camión nativo paso a paso, 5e-10 % en 134 pasos. Y las envolventes del «Moving Load» nativo:
#tabla("Comparación","Hekatan:4","SAP2000:4","Diferencia [%]:4")({"Envolvente camión, M3 máx [kN·m]","Envolvente camión, M3 mín [kN·m]","Envolvente camión, asiento [mm]","Envolvente HL-93 + carril, M3 máx [kN·m]","Envolvente HL-93 + carril, M3 mín [kN·m]","Envolvente HL-93 + carril, asiento [mm]"}; [71.5127, -77.7595, -5.8512, 77.3201, -89.6117, -6.5198]; [71.5128, -77.7599, -5.8512, 77.3194, -89.6053, -6.5198]; [0.0001, 0.0005, 0.0000, 0.0009, 0.0071, 0.0000])
#: Dos detalles medidos, no supuestos. Uno: el camión nativo de SAP2000 arranca con el eje delantero 1 m ANTES del carril (x = t − 1.0 m), así que sus diez primeros pasos son el estado cero, con el camión fuera. Dos: en el instante exacto en que un eje pisa el inicio del carril (x = 0) SAP2000 todavía no lo carga y Hekatan sí; son 3 pasos de 137 y por eso se comparan 134. Las envolventes difieren en la cuarta cifra porque SAP2000 discretiza el carril con puntos a ±1 mm de cada nudo.

## 9 · Veredicto

#: Las siete leyes exactas se cumplen a 1e-9 o mejor, con los números de Hekatan y con los de SAP2000. Las cotas a mano encierran al MEF por los dos lados. Y SAP2000, con su propio camión, da lo mismo. Los resultados son congruentes. Queda pendiente, y está avisado en pantalla, el ancho de reparto de AASHTO: hoy el eje entero va sobre la franja de 1 m, que es el lado seguro.
