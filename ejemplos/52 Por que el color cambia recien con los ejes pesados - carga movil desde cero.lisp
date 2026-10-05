# ¿Por qué el color cambia recién cuando entran los ejes pesados?

#: Pregunta real, mirando la animación del camión sobre la alcantarilla cajón: «entra el camión y todo sigue azul; el degradado de colores aparece recién con los ejes de atrás. ¿Está mal?». No está mal. Esta hoja lo explica desde cero, sin suponer que sabes de puentes. Tres ideas bastan: (1) qué significa el color, (2) cuánto pesa cada eje, (3) cómo se mueve el cajón sobre el suelo.

## 1 · Qué significa el color

#: El color NO es «cuánto se mueve ahora». Es «cuánto se mueve ahora, comparado con lo MÁS que se llega a mover en todo el viaje del camión». Azul = casi nada de ese máximo. Rojo = el máximo. La escala es fija a propósito: así un color vale lo mismo en todos los cuadros y puedes comparar un instante con otro. Es como un termómetro graduado hasta el día más caluroso del año: en un día fresco la columna apenas sube, y no por eso está roto.
#: En este ejemplo el máximo de todo el viaje es 6.80 mm. Por debajo de la octava parte de eso (0.85 mm) la paleta se queda en azules. Guarda ese número.

## 2 · Cuánto pesa cada eje

#: Unidades de esta hoja: fuerzas en kN (1 tonf = 9.81 kN; 145 kN son 14.8 tonf), largos en m y asientos en mm. La unidad se escribe entre corchetes al final de la línea y se dibuja pegada al número; es solo para leer, el cálculo va con números puros.
#: El camión de diseño HL-93 tiene TRES ejes (no es un tándem: son un eje delantero y dos traseros separados 4.3 m). El delantero es liviano, los dos de atrás son pesados:
P_1 = 35 [kN] @@(eje delantero)
P_2 = 145 [kN] @@(eje trasero)
P_3 = 145 [kN] @@(eje trasero)
r = dec(P_1/P_2, 2) @@(sin unidades: es una proporción)
#: El eje delantero pesa {r} veces un eje trasero: menos de la cuarta parte.
#: Segunda pieza: la estructura es LINEAL. Eso quiere decir que si pones el doble de carga en el mismo sitio, se mueve el doble; la cuarta parte de carga, la cuarta parte de movimiento. Entonces el eje delantero, puesto donde lo pongas, como mucho moverá la estructura el {r} de lo que la mueve un eje trasero en ese mismo sitio. Con eso solo ya se entiende casi todo: mientras únicamente el eje delantero está encima, el color NO PUEDE pasar del azul claro.

## 3 · Cómo se mueve el cajón: se hunde y cabecea

#: La alcantarilla no está empotrada en roca: descansa sobre el suelo, que cede como un colchón de muelles (a eso se le llama suelo de Winkler). Y el cajón cerrado es muy rígido comparado con ese colchón. Resultado: lo que más se ve moverse no es la losa doblándose, sino el CAJÓN ENTERO, que hace dos cosas a la vez: se HUNDE parejo (por el peso) y CABECEA hacia el lado donde está la carga (porque la carga no está en el centro).
#: Se puede calcular a mano tratando el cajón como un bloque rígido de largo B sobre muelles. Si encima hay una carga total S, y su «momento» respecto al centro es M_{o} (carga por distancia al centro), el asiento en un punto x es: una parte pareja S/(k·B) más una parte inclinada que crece hacia el borde.
B = 6 [m] @@(largo del cajón)
k_s = 19613.3 [kN/m^3] @@(balasto del suelo)
kB = dec(k_s*B/1000, 2) [kN/mm] @@(kN por cada mm de asiento)
#: k·B = {kB} (en kN por milímetro de asiento, para la franja de 1 m). Dos casos con UN solo eje para ver la diferencia entre estar en el centro y estar en el borde:
w_centro = dec(P_2/kB, 3) [mm]
w_borde = dec(P_2/kB*(1 + 3), 3) [mm]
#: Un eje de 145 kN en el CENTRO hunde el bloque {w_centro} mm, parejo. El mismo eje en el BORDE hunde ese borde {w_borde} mm: CUATRO veces más, porque además de hundir, inclina (el «1 + 3» sale de la geometría del bloque: 6·e/B con la carga en el extremo, e = B/2). Por eso el máximo del viaje ocurre con un eje pesado justo en un borde, y no con el camión en el medio.

### La animación: el bloque bajo el camión que pasa

#: Línea azul: la losa inferior vista de lado, hundiéndose e inclinándose mientras el camión avanza de izquierda a derecha (cada cuadro, el eje delantero avanza medio metro). Línea roja: el asiento máximo de todo el viaje, el que corresponde al color rojo. Mira los primeros cuadros: con solo el eje delantero encima la línea casi no se separa del cero. Cuando entra el primer eje pesado por la izquierda, el bloque cabecea de golpe hacia ese lado.
#anim fplot(asiento_mm = -((35*(1+sign(0.5*n+0.01))/2*(1+sign(6.01-0.5*n))/2 + 145*(1+sign(0.5*n-4.29))/2*(1+sign(10.31-0.5*n))/2 + 145*(1+sign(0.5*n-8.59))/2*(1+sign(14.61-0.5*n))/2) + (35*(1+sign(0.5*n+0.01))/2*(1+sign(6.01-0.5*n))/2*(0.5*n-3) + 145*(1+sign(0.5*n-4.29))/2*(1+sign(10.31-0.5*n))/2*(0.5*n-7.3) + 145*(1+sign(0.5*n-8.59))/2*(1+sign(14.61-0.5*n))/2*(0.5*n-11.6))*(x-3)/3)/117.68, maximo_del_viaje_mm = -4.93 + 0*x, cero = 0*x, [0 6]), n = 0:29

## 4 · El color a lo largo del viaje: la cuenta a mano contra el programa

#: Con el mismo bloque rígido se puede predecir el color de cada instante: el asiento mayor del bloque en ese instante, dividido por el mayor de todo el viaje. La curva es esa cuenta a mano; los puntos son lo que pinta Hekatan (elementos finitos, con el cajón deformable). x es la posición del eje delantero, en metros desde que pisa la alcantarilla. La línea horizontal es el umbral del azul (1/8).
#fplot(bloque_rigido = (35*(1+sign(x+0.01))/2*(1+sign(6.01-x))/2 + 145*(1+sign(x-4.29))/2*(1+sign(10.31-x))/2 + 145*(1+sign(x-8.59))/2*(1+sign(14.61-x))/2 + abs(35*(1+sign(x+0.01))/2*(1+sign(6.01-x))/2*(x-3) + 145*(1+sign(x-4.29))/2*(1+sign(10.31-x))/2*(x-7.3) + 145*(1+sign(x-8.59))/2*(1+sign(14.61-x))/2*(x-11.6)))/580, umbral_del_azul = 0.125 + 0*x, Hekatan = [0.0 0.242; 0.6 0.198; 1.2 0.155; 1.8 0.115; 2.4 0.081; 3.0 0.061; 3.6 0.081; 4.2 0.115; 4.8 0.788; 5.4 0.585; 6.0 0.424; 6.6 0.357; 7.2 0.256; 7.8 0.314; 8.4 0.452; 9.0 0.656; 9.6 0.541; 10.2 0.787; 10.8 0.380; 11.4 0.265; 12.0 0.295; 12.6 0.427; 13.2 0.584; 13.8 0.761; 14.4 0.940; 14.6 1.000], [0 14.6])
#: Léela de izquierda a derecha, como la película:
#: • De 0 a 4.3 m solo está encima el eje delantero. El color arranca en 0.24 (eje liviano pero en el borde, que multiplica por cuatro), BAJA hasta 0.06 cuando el eje pasa por el centro (ahí solo hunde, no inclina) y vuelve a subir un poco. Casi todo ese tramo está por debajo o rozando el umbral del azul. Eso es lo que viste: «entra el camión y no cambia».
#: • En 4.3 m entra el primer eje de 145 kN, y entra por el BORDE: es la combinación más fuerte (eje pesado y posición que inclina). El color salta de 0.12 a casi 0.8 de un cuadro al siguiente. Ahí «aparece» el degradado.
#: • Después sube y baja según dónde estén los ejes pesados, y llega a 1.00 (rojo) al final, cuando el último eje pesado sale por el borde derecho.
#tabla("Instante","Bloque a mano:3","Hekatan:3")({"Eje delantero entrando, en el borde (x = 0)","Eje delantero sobre el muro central (x = 3)","Entra el primer eje pesado (x = 4.8)","Último eje pesado en el borde derecho (x = 14.6)"}; [0.241, 0.060, 0.827, 1.000]; [0.242, 0.061, 0.788, 1.000])
#: La cuenta a mano acierta los instantes con un solo eje casi exacto, y se pasa un poco cuando hay dos ejes (0.83 contra 0.79) porque el cajón real se deforma algo y reparte mejor. Que un modelo de tres líneas reproduzca al programa es la mejor señal de que el programa no está haciendo nada raro.

## 5 · Entonces, ¿cómo «veo» entrar al camión?

#: El desplazamiento es mal testigo del eje delantero, por lo dicho: es liviano y la escala es la del viaje entero. El MOMENTO FLECTOR de la losa superior sí responde desde el primer cuadro, porque es un efecto local: la losa se dobla justo debajo de la rueda aunque el cajón casi no se hunda. En la animación es el diagrama rojo y azul pegado a las piezas. Compara las dos curvas, cada una dividida por su propio máximo del viaje: con solo el eje delantero encima la del momento anda entre 0.15 y 0.24, mientras la del asiento baja hasta 0.06.
#fplot(umbral = 0.125 + 0*x, Asiento_relativo = [0.0 0.242; 0.6 0.198; 1.2 0.155; 1.8 0.115; 2.4 0.081; 3.0 0.061; 3.6 0.081; 4.2 0.115; 4.8 0.788; 5.4 0.585; 6.0 0.424; 6.6 0.357; 7.2 0.256], Momento_relativo = [0.0 0.160; 0.6 0.185; 1.2 0.238; 1.8 0.228; 2.4 0.163; 3.0 0.154; 3.6 0.163; 4.2 0.228; 4.8 0.715; 5.4 0.961; 6.0 0.936; 6.6 0.732; 7.2 0.637], [0 7.5])

## 6 · En una frase

#: El degradado aparece «tarde» por tres razones que se multiplican: el eje delantero pesa la cuarta parte; la escala de color es la del peor instante del viaje, que lo produce un eje pesado en el borde; y lo que se colorea es el hundimiento del cajón entero, que en el centro es cuatro veces menor que en el borde. 0.24 × (1/4) ≈ 0.06: azul. No es un error del programa, y SAP2000 da los mismos milímetros en cada posición (hoja 51).
